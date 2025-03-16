import "package:flutter/material.dart";

class TextTags extends StatelessWidget {
  final List<String> tags;
  final TextStyle? textStyle;
  const TextTags({super.key, required this.tags, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tags.map((tag) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          child: Text(
            tag,
            style: textStyle ?? const TextStyle(
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }
}
