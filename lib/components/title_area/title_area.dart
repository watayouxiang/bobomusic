import "package:flutter/material.dart";

class TitleAreaView extends StatefulWidget {
  final String title;
  final VoidCallback? onTapNextPage;

  const TitleAreaView({super.key, required this.title, this.onTapNextPage});

  @override
  State<TitleAreaView> createState() => TitleAreaViewState();
}

class TitleAreaViewState extends State<TitleAreaView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.onTapNextPage != null)
            InkWell(
              child: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                widget.onTapNextPage!();
              },
            )
          ]),
          const SizedBox(height: 16),
        ],
      )
    );
  }
}