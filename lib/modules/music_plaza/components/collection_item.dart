import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

class CollectionItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String author;
  final VoidCallback? onTap;

  const CollectionItem({super.key, required this.imageUrl, required this.name, required this.author, this.onTap});

  @override
  State<CollectionItem> createState() => CollectionItemViewState();
}

class CollectionItemViewState extends State<CollectionItem> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = (screenSize.width - 56) / 2;

    return SizedBox(
      width: width,
      height: width + 36,
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), // 设置足够大的圆角半径
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: width,
                height: width - 30,
                fit: BoxFit.cover,
              )
            ),
            Container(
              width: width,
              padding: const EdgeInsets.only(top: 10, left: 10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 214, 214, 214),
                    offset: Offset(0, 3),
                    blurRadius: 5,
                  ),
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, maxLines: 1, style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis)),
                  Text(widget.author, maxLines: 1, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}