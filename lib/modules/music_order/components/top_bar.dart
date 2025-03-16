// ignore_for_file: must_be_immutable, use_build_context_synchronously
import "dart:async";

import "package:bobomusic/components/round_rect_tab_indicator/round_rect_tab_indocator.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/event_bus/event_bus.dart";
import "package:bobomusic/main.dart";
import "package:bobomusic/modules/music_order/utils.dart";
import "package:flutter/material.dart";

class FrozenTab {
  static String local = "本地";
  static String iLike = "我喜欢";
}

class TopBar extends StatefulWidget {
  List<String> tabList;
  List<Widget> contentList;
  ValueChanged<int>? onTap;

  TopBar({
    super.key,
    required this.tabList,
    required this.contentList,
    onTap
  });

  @override
  State<TopBar> createState() => TopBarState();
}

class TopBarState extends State<TopBar> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    _tabController = TabController(length: widget.tabList.length, vsync: this);
    // 添加监听器
    _tabController.addListener(_handleTabSelection);

    final index = await getCurrentTabIndex();
    _tabController.index = index;
  }

  @override
  void didUpdateWidget(covariant TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabList.length != oldWidget.tabList.length) {
      _tabController.dispose();
      // 重新初始化 TabController
      _initState();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index != _tabController.previousIndex) {
      // 这里处理索引变化的逻辑
      setCurrentTabIndex(index: _tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildTabBar(),
        Expanded(child: _buildTabbarView())
      ],
    );
  }

  Widget _buildTabBar() => Theme(
    data: Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    ),
    child: TabBar(
      indicator: RoundRectTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      enableFeedback: false,
      padding: const EdgeInsets.only(left: 10, right: 4, bottom: 4),
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      tabAlignment: TabAlignment.start,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      controller: _tabController,
      isScrollable: true,
      labelColor: Theme.of(context).primaryColor,
      indicatorWeight: 3,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      dividerColor: Colors.transparent,
      tabs: List.generate(widget.tabList.length, (index) {
        final String tabName = widget.tabList[index];
        return GestureDetector(
          onLongPress: () async {
            if (index == 0) {
              final dbMusics = await db.queryAll(TableName.musicLocal);

              if (dbMusics.isEmpty) {
                return;
              }
            }

            _tabController.index = index;

            if (tabName == TableName.musicLocal) {
              eventBus.fire(ShowLocalAction());
            } else {
              eventBus.fire(ShowDeleteListDialog(tabName: tabName));
            }
          },
          child: Tab(text: tabName, height: 40)
        );
      }),
      onTap: (int index) async {
        if (widget.onTap != null) {
          widget.onTap!(index);
        }
      },
    ),
  );

  Widget _buildTabbarView() => TabBarView(
    controller: _tabController,
    children: widget.contentList.map((e) => e).toList(),
  );
}
