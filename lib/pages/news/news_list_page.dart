import 'dart:async';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';

import 'package:openjmu/constants/constants.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  List<News> newsList;
  int lastTimeStamp = 0;

  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getNewsList(isLoadMore: false);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> getNewsList({bool isLoadMore}) async {
    if (!_isLoading) {
      _isLoading = true;
      if (!isLoadMore) {
        lastTimeStamp = 0;
      }
      final String _url = API.newsList(
        maxTimeStamp: isLoadMore ? lastTimeStamp : null,
      );
      final Map<String, dynamic> data =
          (await NetUtils.getWithHeaderSet<Map<String, dynamic>>(
        _url,
        headers: Constants.teamHeader,
      ))
              .data;

      final List<News> _newsList = <News>[];
      final List<dynamic> _news = data['data'] as List<dynamic>;
      final int _total = data['total'].toString().toInt();
      final int _count = data['count'].toString().toInt();
      final int _lastTimeStamp = data['min_ts'].toString().toInt();

      for (final dynamic _newsData in _news) {
        final Map<String, dynamic> newsData = _newsData as Map<String, dynamic>;
        _newsList.add(News.fromJson(newsData));
      }
      if (isLoadMore) {
        newsList.addAll(_newsList);
      } else {
        newsList = _newsList;
      }

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = newsList.length < _total && _count != 0;
      lastTimeStamp = _lastTimeStamp;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget getTitle(News news) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            news.title,
            style: TextStyle(fontSize: 18.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (news.relateTopicId != null)
          Container(
            margin: EdgeInsets.only(left: 6.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: currentThemeColor,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(
              '专题',
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
          ),
      ],
    );
  }

  Widget getSummary(News news) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            news.summary,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget getInfo(News news) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            news.postTime,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '${news.glances} ',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
                size: 14.w,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget coverImg(News news) {
    final String imageUrl =
        '${API.showFile}${news.cover}/sid/${UserAPI.currentUser.sid}';
    final ImageProvider coverImg = ExtendedNetworkImageProvider(imageUrl);
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: FadeInImage(
        fadeInDuration: 100.milliseconds,
        placeholder: const AssetImage(R.ASSETS_AVATAR_PLACEHOLDER_PNG),
        image: coverImg,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget newsItem(News news) {
    return Container(
      height: 96.w,
      padding: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: () {
          navigatorState.pushNamed(
            Routes.openjmuNewsDetail,
            arguments: <String, dynamic>{'news': news},
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.w).copyWith(right: 10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getTitle(news),
                    getSummary(news),
                    const Spacer(),
                    getInfo(news),
                  ],
                ),
              ),
            ),
            if (news.cover != null)
              coverImg(news)
            else
              Padding(
                padding: EdgeInsets.all(4.w),
                child: SizedBox.fromSize(size: Size.square(80.w)),
              ),
          ],
        ),
      ),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        return RefreshIndicator(
          onRefresh: () => getNewsList(isLoadMore: false),
          child: newsList.isEmpty
              ? const SizedBox.shrink()
              : ExtendedListView.separated(
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: (List<int> garbage) {
                      for (final int index in garbage) {
                        if (newsList.length >= index + 1) {
                          final News element = newsList.elementAt(index);
                          ExtendedNetworkImageProvider(
                            '${API.showFile}${element.cover}'
                            '/sid/${UserAPI.currentUser.sid}',
                          ).evict();
                        }
                      }
                    },
                  ),
                  shrinkWrap: true,
                  controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) =>
                      separator(context, height: 1.0),
                  itemCount: newsList.length + 1,
                  itemBuilder: (_, int index) {
                    if (index == newsList.length) {
                      return LoadMoreIndicator(canLoadMore: _canLoadMore);
                    } else if (index < newsList.length) {
                      return newsItem(newsList[index]);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
        );
      } else {
        return const SpinKitWidget();
      }
    } else {
      return const Center(child: SpinKitWidget());
    }
  }
}
