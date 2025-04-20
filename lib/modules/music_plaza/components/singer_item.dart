import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

class SingerItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final VoidCallback? onTap;

  const SingerItem({super.key, required this.imageUrl, required this.name, this.onTap});

  @override
  State<SingerItem> createState() => SingerViewState();
}

class SingerViewState extends State<SingerItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 80,
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25), // 设置足够大的圆角半径
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            ),
            const SizedBox(height: 6),
            Text(widget.name, maxLines: 1, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis))
          ],
        ),
      )
    );
  }
}