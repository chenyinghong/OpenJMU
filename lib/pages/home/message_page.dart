import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/messages/app_message_preview_widget.dart';
//import 'package:openjmu/widgets/messages/message_preview_widget.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage>
    with TickerProviderStateMixin {
  final ScrollController _messageScrollController = ScrollController();

//  TabController _tabController;

//  @override
//  void initState() {
//    super.initState();
//    _tabController = TabController(
//      initialIndex: Provider.of<SettingsProvider>(
//        currentContext,
//        listen: false,
//      ).homeStartUpIndex[2],
//      length: 1,
//      vsync: this,
//    );
//  }

  Widget get _tabBar {
    return Row(
      children: <Widget>[
        Expanded(child: MainPage.selfPageOpener),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Consumer<MessagesProvider>(
                builder: (_, MessagesProvider provider, __) {
                  return Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Positioned(
                        top: kToolbarHeight / 4.h,
                        right: -10.w,
                        child: Visibility(
                          visible: provider.unreadCount > 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              color: currentThemeColor,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '通知',
                        style: MainPageState.tabUnselectedTextStyle,
                      ),
                    ],
                  );
                },
              ),
            ),
//              child: TabBar(
//                isScrollable: true,
//                indicator: RoundedUnderlineTabIndicator(
//                  borderSide: BorderSide(
//                    color: currentThemeColor,
//                    width: 3.h,
//                  ),
//                  width: 26.w,
//                  insets: EdgeInsets.only(bottom: 4.h),
//                ),
//                labelColor: Theme.of(context).textTheme.bodyText2.color,
//                labelStyle: MainPageState.tabSelectedTextStyle,
//                labelPadding: EdgeInsets.symmetric(
//                  horizontal: 20.w,
//                ),
//                unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
//                tabs: <Widget>[
//                  Consumer<MessagesProvider>(
//                    builder: (_, provider, __) {
//                      return Stack(
//                        overflow: Overflow.visible,
//                        children: <Widget>[
//                          Positioned(
//                            top: kToolbarHeight / 4.h,
//                            right: -10.w,
//                            child: Visibility(
//                              visible: provider.unreadCount > 0,
//                              child: ClipRRect(
//                                borderRadius: BorderRadius.circular(100),
//                                child: Container(
//                                  width: 12.w,
//                                  height: 12.w,
//                                  color: currentThemeColor,
//                                ),
//                              ),
//                            ),
//                          ),
//                          Tab(text: '通知'),
//                        ],
//                      );
//                    },
//                  ),
//                ],
//                controller: _tabController,
//              ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget get _messageList => Consumer2<MessagesProvider, WebAppsProvider>(
        builder: (
          _,
          MessagesProvider messageProvider,
          WebAppsProvider webAppsProvider,
          __,
        ) {
          final bool shouldDisplayAppsMessages =
              (messageProvider.appsMessages?.isNotEmpty ?? false) &&
                  (webAppsProvider.apps?.isNotEmpty ?? false);
//          final shouldDisplayPersonalMessages =
//            messageProvider.personalMessages.isNotEmpty;
          final bool shouldDisplayMessages = shouldDisplayAppsMessages
//                ||
//                shouldDisplayPersonalMessages
              ;

          if (!shouldDisplayMessages) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  R.IMAGES_PLACEHOLDER_NO_MESSAGE_SVG,
                  width: Screens.width / 3.5,
                  height: Screens.width / 3.5,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: Text(
                    '无新消息',
                    style: TextStyle(fontSize: 22.sp),
                  ),
                )
              ],
            );
          }
          return CustomScrollView(
            controller: _messageScrollController,
            slivers: <Widget>[
              if (shouldDisplayAppsMessages)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, int index) {
                      final Map<int, List<dynamic>> _list =
                          messageProvider.appsMessages;
                      final int _index = _list.keys.length - 1 - index;
                      final int appId = _list.keys.elementAt(_index);
                      final AppMessage message = _list[appId][0] as AppMessage;
                      return SlideItem(
                        menu: <SlideMenuItem>[
                          deleteWidget(messageProvider, appId),
                        ],
                        child: AppMessagePreviewWidget(message: message),
                        height: 88.h,
                      );
                    },
                    childCount: messageProvider.appsMessages.keys.length,
                  ),
                ),
//                if (shouldDisplayAppsMessages)
//                  SliverToBoxAdapter(
//                    child: Constants.separator(context),
//                  ),
//                if (shouldDisplayPersonalMessages)
//                  SliverList(
//                    delegate: SliverChildBuilderDelegate(
//                      (context, index) {
//                        final mine =
//                            messageProvider.personalMessages[currentUser.uid];
//                        final uid = mine.keys.elementAt(index);
//                        final Message message = mine[uid].first;
//                        return MessagePreviewWidget(
//                          uid: uid,
//                          message: message,
//                          unreadMessages: mine[uid],
//                        );
//                      },
//                      childCount: messageProvider
//                          .personalMessages[currentUser.uid].keys.length,
//                    ),
//                  ),
            ],
          );
        },
      );

  SlideMenuItem deleteWidget(MessagesProvider provider, int appId) {
    return SlideMenuItem(
      onTap: () {
        provider.deleteFromAppsMessages(appId);
      },
      child: Center(
        child: Text(
          '删除',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      color: currentThemeColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        title: _tabBar,
        centerTitle: false,
        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
      ),
      body: _messageList,
//      body: TabBarView(
//        controller: _tabController,
//        children: <Widget>[
//          _messageList,
//        ],
//      ),
    );
  }
}
