import "package:bobomusic/components/markdown/markdown.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class HelpDoc extends StatefulWidget {
  const HelpDoc({super.key});

  @override
  State<HelpDoc> createState() => HelpDocState();
}

class HelpDocState extends State<HelpDoc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "使用帮助",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: MarkdownRenderer(markdownFilePath: path.join("assets", "markdown", "help_doc.md"))
    );
  }
}
