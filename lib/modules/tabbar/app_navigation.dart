import "package:bobomusic/modules/music_order/music_order.dart";
import "package:bobomusic/modules/music_plaza/music_plaza.dart";
import "package:bobomusic/modules/setting/setting.dart";
import "package:bobomusic/modules/tabbar/app_bottom_bar.dart";
import "package:flutter/material.dart";

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => AppNavigationState();
}

class AppNavigationState extends State<AppNavigation> {
  int _index = 0;
  final PageController _pageController = PageController();

  final List<MenuData> menus = const [
    MenuData(label: "歌单", icon: Icons.queue_music),
    MenuData(label: "广场", icon: Icons.people_outlined),
    MenuData(label: "设置", icon: Icons.settings),
  ]; 

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ 
        Expanded(child: _buildContent(_index)),
        AppBottomBar(
          currentIndex: _index,
          onItemTap: _onChangePage,
          menus: menus,
        )
      ],
    );
  }

  void _onChangePage(int index) {
    FocusScope.of(context).unfocus();
    _pageController.jumpToPage(index);
    setState(() {
      _index = index;
    });
  }

  Widget _buildContent(int index) {
     return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: const [
        MusicOrderView(),
        MusicPlazaView(),
        SettingView(),
      ],
    );
  }
}