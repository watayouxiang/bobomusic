import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class EmptyPage extends StatefulWidget {
  // 将成员变量声明为 final
  final List<Widget> btns;
  final String text;
  final double imageTopPadding;
  final double imageBottomPadding;
  final double? imageWidth;

  const EmptyPage({
    super.key,
    required this.btns,
    required this.text,
    required this.imageBottomPadding,
    required this.imageTopPadding,
    this.imageWidth,
  });

  @override
  State<EmptyPage> createState() => EmptyPageState();
}

class EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.all(16),
      child: isLandscape
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      path.join("assets", "images", "empty.png"),
                      width: widget.imageWidth ?? screenSize.height - 550 / 2,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.text),
                    ...widget.btns,
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: widget.imageTopPadding),
                    Image.asset(
                      path.join("assets", "images", "empty.png"),
                      width: screenSize.width / 2 + 50,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: widget.imageBottomPadding),
                    Text(widget.text),
                    const SizedBox(height: 32),
                    ...widget.btns,
                  ],
                ),
              ),
            ],
          ),
    );
  }
}