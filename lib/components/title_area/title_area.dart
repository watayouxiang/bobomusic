import "package:bobomusic/components/ripple_icon/ripple_icon.dart";
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
    final primaryColor = Theme.of(context).primaryColor;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
              if (widget.onTapNextPage != null)
                Transform.translate(
                  offset: const Offset(6, 0),
                  child: RippleIcon(
                    size: 24,
                    splashColor: Colors.transparent,
                    onTap: () {
                      widget.onTapNextPage!();
                    },
                    child: Icon(Icons.chevron_right, size: 24, color: primaryColor),
                  ),
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