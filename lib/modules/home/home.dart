import "package:flutter/material.dart";
import "package:bobomusic/modules/player/player.dart";
import "package:bobomusic/modules/tabbar/app_navigation.dart";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: PlayerView(),
      body: AppNavigation(),
    );
  }
}
