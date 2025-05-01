import "package:bobomusic/constants/cache_key.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/modules/player/utils.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "dart:async";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<int?> getMusicPosition() async {
  final localStorage = await SharedPreferences.getInstance();
  final pos = localStorage.getInt(
    CacheKey.playerPosition,
  );
  return pos;
}

final db = DBOrder(version: 2);

class LyricsScroller extends StatefulWidget {
  const LyricsScroller({super.key});

  @override
  LyricsScrollerState createState() => LyricsScrollerState();
}

class LyricsScrollerState extends State<LyricsScroller> {
  String lyric = "";
  List<Map<String, dynamic>> parsedLyrics = [];
  int currentLine = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int currentTime = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      doScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    lyric = "";
    parsedLyrics = [];
    currentLine = 0;
    currentTime = 0;
    super.dispose();
  }

  Future<void> doScroll() async {
    final player = context.read<PlayerModel>();

    final dbMusic = await db.queryByParam(player.current!.orderName, player.current!.playId);

    if (dbMusic.isNotEmpty) {
      final MusicItem musicItem = row2MusicItem(dbRow: dbMusic[0]);

      setState(() {
        lyric = musicItem.lyric;
        parsedLyrics = parseLyrics(lyric);
      });
    }

    final initialPosition = await getMusicPosition();

    for (int i = 0; i < parsedLyrics.length; i++) {
      if (parsedLyrics[i]["time"] > initialPosition) {
        currentLine = i > 0 ? i - 1 : 0;
        break;
      }
      if (i == parsedLyrics.length - 1) {
        currentLine = i;
      }
    }

    currentTime = parsedLyrics[currentLine]["time"];
    scrollToCenter(currentLine);

    if (!player.isPlaying) {
      return;
    }

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTime += 100;
        while (currentLine < parsedLyrics.length - 1 &&
          currentTime >= parsedLyrics[currentLine + 1]["time"]) {
          currentLine++;
          scrollToCenter(currentLine);
        }
      });
    });
  }

  void scrollToCenter(int line) {
    const itemHeight = 47.0;
    final screenHeight = MediaQuery.of(context).size.height;
    // 计算将当前行置于屏幕中心所需的偏移量
    final targetOffset = line * itemHeight - (screenHeight / 2 - itemHeight / 2);

    // 确保目标偏移量在有效范围内
    final clampedOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void updateCurrentLine(int position) {
    for (int i = 0; i < parsedLyrics.length; i++) {
      if (parsedLyrics[i]["time"] > position) {
        setState(() {
          currentLine = i > 0 ? i - 1 : 0;
        });
        scrollToCenter(currentLine);
        break;
      }
      if (i == parsedLyrics.length - 1) {
        setState(() {
          currentLine = i;
        });
        scrollToCenter(currentLine);
      }
    }
  }

  void moveLyricsBackward() {
    BotToast.showText(text: "-0.5s");
    setState(() {
      currentTime -= 500;
      for (int i = 0; i < parsedLyrics.length; i++) {
        if (parsedLyrics[i]["time"] > currentTime) {
          currentLine = i > 0 ? i - 1 : 0;
          break;
        }
        if (i == parsedLyrics.length - 1) {
          currentLine = i;
        }
      }
      scrollToCenter(currentLine);
    });
  }

  void moveLyricsForward() {
    BotToast.showText(text: "+0.5s");
    setState(() {
      currentTime += 500;
      for (int i = 0; i < parsedLyrics.length; i++) {
        if (parsedLyrics[i]["time"] > currentTime) {
          currentLine = i > 0 ? i - 1 : 0;
          break;
        }
        if (i == parsedLyrics.length - 1) {
          currentLine = i;
        }
      }
      scrollToCenter(currentLine);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        Consumer<PlayerModel>(
          builder: (context, player, child) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.only(top: 16, bottom: 100, left: 24, right: 24),
                child: Center(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: parsedLyrics.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          parsedLyrics[index]["text"],
                          style: TextStyle(
                            color: index == currentLine ? primaryColor : Colors.white,
                            fontSize: 16,
                            fontWeight: index == currentLine ? FontWeight.bold : FontWeight.w500
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            );
          }
        ),
        Positioned(
          left: 80,
          bottom: 40,
          child: InkWell(
            onTap: () {
              moveLyricsBackward();
            },
            child: Icon(Icons.keyboard_double_arrow_left_rounded, color: primaryColor, size: 30),
          )
        ),
        Positioned(
          right: 80,
          bottom: 40,
          child: InkWell(
            onTap: () {
              moveLyricsForward();
            },
            child: Icon(Icons.keyboard_double_arrow_right_rounded, color: primaryColor, size: 30),
          )
        ),
      ],
    );
  }
}
