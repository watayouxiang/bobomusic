import "package:flutter/material.dart";

class MenuData {
  final String label;
  final IconData icon;
  const MenuData({
    required this.label,
    required this.icon,
  });
}

class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final List<MenuData> menus;
  final ValueChanged<int>? onItemTap;

  const AppBottomBar({
    super.key,
    this.onItemTap,
    this.currentIndex = 0,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: SizedBox(
        height: 50,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            onTap: onItemTap,
            currentIndex: currentIndex,
            elevation: 3,
            type: BottomNavigationBarType.fixed,
            iconSize: 20,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedItemColor: Theme.of(context).primaryColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            showUnselectedLabels: true,
            showSelectedLabels: true,
            items: menus.map(_buildItemByMenuMeta).toList(),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItemByMenuMeta(MenuData menu) {
    return BottomNavigationBarItem(
      label: menu.label,
      icon: Icon(menu.icon),
    );
  }
}
