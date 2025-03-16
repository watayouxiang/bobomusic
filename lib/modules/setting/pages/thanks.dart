import "package:bobomusic/components/markdown/markdown.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class Thanks extends StatefulWidget {
  const Thanks({super.key});

  @override
  State<Thanks> createState() => ThanksState();
}

class ThanksState extends State<Thanks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "鸣谢",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: MarkdownRenderer(markdownFilePath: path.join("assets", "markdown", "thanks.md"))
    );
  }
}
