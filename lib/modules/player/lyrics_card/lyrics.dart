
import "dart:ui";

import "package:bobomusic/modules/player/lyrics_card/lyric_scroller.dart";
import "package:flutter/material.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:provider/provider.dart";

class LyricsCard extends StatefulWidget {
  final ImageInfo? imageInfo;
  final ImageProvider? imageProvider;
  final String errorCoverUrl;

  const LyricsCard({
    super.key,
    this.imageInfo,
    this.imageProvider,
    required this.errorCoverUrl
  });

  @override
  State<LyricsCard> createState() => LyricsCardState();
}

class LyricsCardState extends State<LyricsCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTopBar(Color primaryColor) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 16, top: 30, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.keyboard_arrow_down,
                  color: primaryColor, size: 30),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<PlayerModel>(
      builder: (context, player, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: widget.imageInfo != null
                  ? Image(
                      image: widget.imageProvider!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.errorCoverUrl,
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            Container(
              width: screenSize.width, // 确保整体宽度占满屏幕
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.6),
              ),
              child: Column(
                children: [
                  _buildTopBar(primaryColor),
                  const Expanded(
                    child: LyricsScroller(),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
