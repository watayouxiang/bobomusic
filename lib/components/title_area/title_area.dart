import "package:flutter/material.dart";

class TitleAreaView extends StatefulWidget {
  final String title;
  final VoidCallback? onTapNextPage;
  final Widget? customRight;

  const TitleAreaView({super.key, required this.title, this.onTapNextPage, this.customRight});

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
                  child: const Icon(Icons.chevron_right, size: 24),
                  onTap: () {
                    widget.onTapNextPage!();
                  },
                ),
              if(widget.customRight != null)
                widget.customRight!,
            ]
          ),
          const SizedBox(height: 16),
        ],
      )
    );
  }
}