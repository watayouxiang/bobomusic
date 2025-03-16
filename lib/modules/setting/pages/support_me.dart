import "package:bobomusic/components/round_rect_tab_indicator/round_rect_tab_indocator.dart";
import "package:flutter/material.dart";

class SupportMe extends StatelessWidget {
  const SupportMe({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "支持项目",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicator: RoundRectTabIndicator(
              borderSide: BorderSide(color: primaryColor, width: 3),
            ),
            dividerColor: Colors.transparent,
            enableFeedback: false,
            padding: const EdgeInsets.only(left: 10, right: 4),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            labelColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "微信"),
              Tab(text: "支付宝"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 70),
              child: Image.asset("assets/images/wx.jpg")
            ),
            Container(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 70),
              child: Image.asset("assets/images/zfb.jpg")
            ),
          ],
        ),
      ),
    );
  }
}
