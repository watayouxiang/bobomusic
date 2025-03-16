import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class EmptyPage extends StatefulWidget {
  // 将成员变量声明为 final
  final List<Widget> btns;
  final String text;
  
  const EmptyPage({super.key, required this.btns, required this.text});

  @override
  State<EmptyPage> createState() => EmptyPageState();
}

class EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height - 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height / 2 - 100,
            child: Image.asset(path.join("assets", "images", "empty.png"), width: screenSize.width / 2 + 50, height: screenSize.height / 2 + 50),
          ),
          Text(widget.text),
          const SizedBox(height: 32),
          ...widget.btns,
        ],
      ),
    );
  }
}