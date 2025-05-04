import "package:bobomusic/constants/cache_key.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/modules/player/utils.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:flutter_lyric/lyric_ui/ui_netease.dart";
import "package:flutter_lyric/lyrics_model_builder.dart";
import "package:flutter_lyric/lyrics_reader_model.dart";
import "package:flutter_lyric/lyrics_reader_widget.dart";
import 'dart:async';
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

class LyricsScrollerState extends State<LyricsScroller> with SingleTickerProviderStateMixin {
  String lyric = "";
  List<Map<String, dynamic>> parsedLyrics = [];
  int currentLine = 0;
  Timer? _timer;
  int currentTime = 0;
  late LyricsReaderModel lyricModel;
  var lyricUI = UINetease();

  @override
  void initState() {
    super.initState();
    // 初始化一个空的 lyricModel
    lyricModel = LyricsModelBuilder.create().getModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      doScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    lyric = "";
    parsedLyrics = [];
    currentLine = 0;
    currentTime = 0;
    super.dispose();
  }

  Future<void> doScroll() async {
    final player = context.read<PlayerModel>();

    List<Map<String, dynamic>> dbMusic = [];

    dbMusic = await db.queryByParam(player.current!.orderName, player.current!.playId);

    if (dbMusic.isEmpty) {
      dbMusic = await db.queryByParam(player.current!.orderName, player.current!.id);
    }

    if (dbMusic.isEmpty) {
      BotToast.showText(text: "找不到歌词 QAQ");
      return;
    }

    if (dbMusic.isNotEmpty) {
      final MusicItem musicItem = row2MusicItem(dbRow: dbMusic[0]);

      setState(() {
        lyric = musicItem.lyric;
        parsedLyrics = parseLyrics(lyric);
        lyricModel = LyricsModelBuilder.create()
           .bindLyricToMain(lyric)
           .getModel();
      });
    }

    final initialPosition = await getMusicPosition();

    // 找到初始位置对应的歌词行
    for (int i = 0; i < parsedLyrics.length; i++) {
      if (parsedLyrics[i]["time"] > initialPosition) {
        currentLine = i > 0? i - 1 : 0;
        break;
      }
      if (i == parsedLyrics.length - 1) {
        currentLine = i;
      }
    }

    currentTime = parsedLyrics[currentLine]["time"];

    if (!player.isPlaying) {
      return;
    }

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTime += 100;
      });
    });
  }

  void moveLyricsBackward() {
    BotToast.showText(text: "-0.5s");
    setState(() {
      currentTime -= 500;
      // 重新找到后退后的歌词行
      for (int i = 0; i < parsedLyrics.length; i++) {
        if (parsedLyrics[i]["time"] > currentTime) {
          currentLine = i > 0? i - 1 : 0;
          break;
        }
        if (i == parsedLyrics.length - 1) {
          currentLine = i;
        }
      }
    });
  }

  void moveLyricsForward() {
    BotToast.showText(text: "+0.5s");
    setState(() {
      currentTime += 500;
      // 重新找到前进后的歌词行
      for (int i = 0; i < parsedLyrics.length; i++) {
        if (parsedLyrics[i]["time"] > currentTime) {
          currentLine = i > 0? i - 1 : 0;
          break;
        }
        if (i == parsedLyrics.length - 1) {
          currentLine = i;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        Consumer<PlayerModel>(
          builder: (context, player, child) {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: LyricsReader(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                model: lyricModel,
                position: currentTime,
                lyricUi: lyricUI,
                playing: player.isPlaying,
                size: Size(double.infinity, MediaQuery.of(context).size.height - 160),
                emptyBuilder: () => Center(
                  child: Text(
                    "没有歌词",
                    style: lyricUI.getOtherMainTextStyle(),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 50,
          bottom: 40,
          child: InkWell(
            onTap: () {
              moveLyricsBackward();
            },
            child: Icon(Icons.keyboard_double_arrow_left_rounded, color: primaryColor, size: 30),
          ),
        ),
        Positioned(
          right: 50,
          bottom: 40,
          child: InkWell(
            onTap: () {
              moveLyricsForward();
            },
            child: Icon(Icons.keyboard_double_arrow_right_rounded, color: primaryColor, size: 30),
          ),
        ),
      ],
    );
  }
}