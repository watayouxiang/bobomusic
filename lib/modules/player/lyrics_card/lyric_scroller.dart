// ignore_for_file: use_build_context_synchronously

import "package:bobomusic/components/custom_dialog/custom_dialog.dart";
import "package:bobomusic/constants/cache_key.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/event_bus/event_bus.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/modules/player/utils.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
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

    eventBus.on<RefresPlayerCard>().listen((event) {
      doScroll();
    });

    // 初始化一个空的 lyricModel
    lyricModel = LyricsModelBuilder.create().getModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      doScroll();
    });
  }

  @override
  void dispose() {
    resetState();
    super.dispose();
  }

  resetState() {
    if (context.mounted && mounted) {
      setState(() {
        _timer?.cancel();
        lyric = "";
        parsedLyrics = [];
        currentLine = 0;
        currentTime = 0;
      });
    }
  }

  Future<void> doScroll() async {
    if (!context.mounted || !mounted) {
      return;
    }

    final player = context.read<PlayerModel>();

    List<Map<String, dynamic>> dbMusic = [];

    dbMusic = await db.queryByParam(player.current!.orderName, player.current!.playId);

    if (dbMusic.isEmpty) {
      dbMusic = await db.queryByParam(player.current!.orderName, player.current!.id);
    }

    if (dbMusic.isEmpty) {
      resetState();
      BotToast.showText(text: "找不到歌词 QAQ");
      return;
    }

    if (dbMusic.isNotEmpty) {
      final MusicItem musicItem = row2MusicItem(dbRow: dbMusic[0]);

      if (musicItem.lyric.isEmpty) {
        resetState();
        BotToast.showText(text: "找不到歌词 QAQ");
        return;
      }

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
    _timer?.cancel(); // 确保先取消之前的 Timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          currentTime += 100;
        });
      }
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

  Future<void> deleteLyric() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    try {
      final player = context.read<PlayerModel>();

      if (player.current!.lyric.isEmpty) {
        BotToast.showText(text: "没有歌词");
        return;
      }

      final music = player.current!.copyWith(lyric: "");
      await db.update(player.current!.orderName, musicItem2Row(music: music));

      resetState();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch(error) {
      BotToast.showText(text: "歌词删除失败");
    }

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerModel>();

    return Stack(
      children: [
        Consumer<PlayerModel>(
          builder: (context, player, child) {
            return Container(
              padding: const EdgeInsets.only(top: 20, bottom: 130),
              child: lyric.isNotEmpty ? LyricsReader(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                model: lyricModel,
                position: currentTime,
                lyricUi: lyricUI,
                playing: player.isPlaying,
                size: Size(double.infinity, MediaQuery.of(context).size.height - 160),
              ) : Center(
                child: Text(
                  "没有歌词",
                  style: lyricUI.getOtherMainTextStyle(),
                ),
              ),
            );
          },
        ),
        // 优化后的底部控制区域布局
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05, // 使用屏幕宽度的百分比
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 改用 spaceAround 以获得更均匀的分布
              children: [
                // 后退按钮 - 保持原有功能
                buildIconButton(
                  icon: Icons.keyboard_double_arrow_left_outlined,
                  onTap: () {
                    if (player.current!.lyric.isEmpty) {
                      BotToast.showText(text: "没有歌词");
                      return;
                    }
                    moveLyricsBackward();
                  },
                  width: getButtonWidth(context, 0.1), // 使用自适应宽度
                ),

                // 删除按钮 - 保持原有功能
                buildIconButton(
                  icon: Icons.delete_forever_rounded,
                  onTap: () {
                    if (player.current!.lyric.isEmpty) {
                      BotToast.showText(text: "没有歌词");
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          body: const Text("删除歌词?"),
                          onConfirm: () async {
                            deleteLyric();
                          },
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                  width: getButtonWidth(context, 0.12), // 中间按钮稍大一些
                  size: 32,
                ),

                // 前进按钮 - 保持原有功能
                buildIconButton(
                  icon: Icons.keyboard_double_arrow_right_outlined,
                  onTap: () {
                    if (player.current!.lyric.isEmpty) {
                      BotToast.showText(text: "没有歌词");
                      return;
                    }
                    moveLyricsForward();
                  },
                  width: getButtonWidth(context, 0.1), // 使用自适应宽度
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // 辅助方法：获取按钮的自适应宽度
  double getButtonWidth(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width - 80;
    return screenWidth * percentage;
  }

  // 辅助方法：构建图标按钮
  Widget buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double width = 50,
    double size = 30,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: width, // 使用相同的宽高比
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width / 2),
          color: primaryColor,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white70, size: size),
        ),
      ),
    );
  }
}
