import "package:bobomusic/components/markdown/markdown.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class Limit extends StatefulWidget {
  const Limit({super.key});

  @override
  State<Limit> createState() => LimitState();
}

class LimitState extends State<Limit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "声明与限制",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: MarkdownRenderer(markdownFilePath: path.join("assets", "markdown", "limit.md"))
    );
  }
}
