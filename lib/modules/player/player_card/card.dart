// ignore_for_file: use_build_context_synchronously, avoid_print

import "dart:async";
import "dart:ui";

import "package:bobomusic/icons/icons_svg.dart";
import "package:bobomusic/modules/music_order/components/top_bar.dart";
import "package:bobomusic/constants/covers.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/event_bus/event_bus.dart";
import "package:bobomusic/modules/download/model.dart";
import "package:bobomusic/modules/player/lyrics_card/lyric_search.dart";
import "package:bobomusic/modules/player/lyrics_card/lyrics.dart";
import "package:bobomusic/modules/player/player_card/vinyl_record.dart";
import "package:bobomusic/modules/player/utils.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bobomusic/utils/check_music_local_repeat.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:bobomusic/modules/player/player.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/utils/clear_html_tags.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:like_button/like_button.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uuid/uuid.dart";

const uuid = Uuid();
final DBOrder db = DBOrder(version: 2);

class PlayerCard extends StatefulWidget {
  const PlayerCard({super.key});

  @override
  State<PlayerCard> createState() => PlayerCardState();
}

class PlayerCardState extends State<PlayerCard> {
  bool isLike = false;
  String coverUrl = Covers.getRandomCover();
  String errorCoverUrl = Covers.getLocalCover();
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _imageProvider = NetworkImage(coverUrl);

    eventBus.on<RefresPlayerCard>().listen((event) {
      _initState();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initState();
      _loadImage();
    });
  }

  Future<void> _initState() async {
    try {
      final current = Provider.of<PlayerModel>(context, listen: false).current;
      final List<Map<String, dynamic>> dbMusics = await db.queryByParam(TableName.musicILike, current?.id ?? current!.name);

      if (dbMusics.isNotEmpty) {
        setState(() {
          isLike = true;
        });
      } else {
        setState(() {
          isLike = false;
        });
      }
    } catch (error) {
      print("$error");
    }
  }

  @override
  void dispose() {
    _imageStream?.removeListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {},
        onError: (dynamic exception, StackTrace? stackTrace) {},
      ),
    );
    super.dispose();
  }

  void _loadImage() {
    _imageStream = _imageProvider?.resolve(const ImageConfiguration());
    _imageStream?.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          setState(() {
            _imageInfo = info;
          });
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          print("Image loading error: $exception");
        },
      ),
    );
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

  Widget _buildRecordWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: VinylRecordWidget(
          albumCoverUrl: coverUrl,
          errorAlbumCoverUrl: errorCoverUrl,
          isPlaying: Provider.of<PlayerModel>(context, listen: false).isPlaying,
        ),
      ),
    );
  }

  Widget _buildMusicInfo(Color primaryColor) {
    final player = Provider.of<PlayerModel>(context, listen: false);
    String subTitle =
        player.current!.orderName.isEmpty ? "未知歌单" : (player.current!.orderName.contains("musicList_") ? "合集" : player.current!.orderName);
    if (player.current!.author.isNotEmpty) {
      subTitle = "$subTitle  ${player.current!.author}";
    }

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Container(
      padding: const EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 20,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              player.current!.name,
              style: TextStyle(
                fontSize: isLandscape ? 54 : 18,
                overflow: TextOverflow.ellipsis,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: isLandscape ? 20 : 10,
                overflow: TextOverflow.ellipsis,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _launchBilibiliVideo(String bvId, PlayerModel player) async {
    try {
      final res = await getLaunchBilibiliConfirm();

      if (res) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (ctx) => Container(
            alignment: Alignment.bottomCenter,
            child: CupertinoActionSheet(
              title: const Text("打开哔哩哔哩", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              message: Container(
                margin: const EdgeInsets.only(top: 6),
                child: const Text("请授权始终打开，授权后需要重新操作", style: TextStyle(fontSize: 10)),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setLaunchBilibiliConfirm(confirm: false);
                    final url = "bilibili://video/$bvId";
                    await launchUrl(Uri.parse(url));
                  },
                  child: const Text("确认且不再提示", style: TextStyle(fontSize: 12, color: Colors.deepPurple))
                ),
              ],
              cancelButton: CupertinoActionSheetAction(onPressed: () {
                Navigator.of(context).pop();
              }, child: Text("取消", style: TextStyle(fontSize: 12, color: Colors.grey[800]))),
            ),
          )
        );
      } else {
        final url = "bilibili://video/$bvId";
        await launchUrl(Uri.parse(url));
      }
    } catch(error) {
      final webUrl = "https://www.bilibili.com/video/$bvId/?spm_id_from=333.1007.tianma.1-2-2.click";
      await launchUrl(Uri.parse(webUrl));
    }
  }

  Widget _buildActionButtons(Color primaryColor) {
    final player = Provider.of<PlayerModel>(context, listen: false);
    final musicItem = player.current as MusicItem;
    final isLocal = musicItem.localPath.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Transform.translate(
              offset: const Offset(0, 0),
              child: Icon(Icons.download_outlined, color: primaryColor, size: 28),
            ),
            onTap: () {
              if (isLocal) {
                BotToast.showText(text: "本地音乐，无需下载");
                return;
              }

              checkMusicLocalRepeat(context, musicItem, () {
                final downloadModel = Provider.of<DownloadModel>(context, listen: false);
                downloadModel.download([musicItem]);
              });
            },
          ),
          LikeButton(
            size: 28,
            animationDuration: const Duration(seconds: 1),
            circleColor: const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xff33b5e5),
              dotSecondaryColor: Color.fromARGB(255, 198, 121, 44),
              dotThirdColor: Color.fromARGB(255, 204, 33, 33),
              dotLastColor: Color.fromARGB(255, 44, 198, 80),
            ),
            likeBuilder: (bool isLiked) {
              return isLike
                ? const Icon(Icons.favorite, size: 28, color: Colors.redAccent)
                : Icon(Icons.favorite_border_rounded, color: primaryColor, size: 28);
            },
            onTap: (bool isLiked) async {
              try {
                if (!isLike) {
                  await db.insert(
                    TableName.musicILike,
                    musicItem2Row(
                      music: player.current!.copyWith(
                        orderName: TableName.musicILike,
                        playId: uuid.v4()
                      )
                    ),
                  );

                  setState(() {
                    isLike = true;
                  });

                  BotToast.showText(text: "已喜欢");
                } else {
                  await db.delete(TableName.musicILike, player.current!.name);

                  setState(() {
                    isLike = false;
                  });

                  BotToast.showText(text: "取消喜欢");
                }

                eventBus.fire(RefreshMusicList(tabName: FrozenTab.iLike));
              } catch (error) {
                print(error);
              }

              return isLike;
            },
          ),
          InkWell(
            child: SvgPicture.string(
              IconsSVG.bilibili,
              // ignore: deprecated_member_use
              color: primaryColor,
              width: 28,
              height: 28,
            ),
            onTap: () {
              final biliVIDs = player.current!.id.split("_").where((e) => e.startsWith("BV")).toList();

              if (biliVIDs.isNotEmpty) {
                _launchBilibiliVideo(biliVIDs[0], player);
              } else {
                BotToast.showText(text: "找不到视频");
              }
            },
          ),
          if (player.current!.orderName.isNotEmpty)
            InkWell(
              child: SvgPicture.string(
                IconsSVG.lyric,
                // ignore: deprecated_member_use
                color: primaryColor,
                width: 28,
                height: 28,
              ),
              onTap: () async {
                if (context.mounted) {
                  List<Map<String, dynamic>> dbMusic = [];

                  dbMusic = await db.queryByParam(player.current!.orderName, player.current!.playId);

                  if (dbMusic.isEmpty) {
                    dbMusic = await db.queryByParam(player.current!.orderName, player.current!.id);
                  }

                  if (dbMusic.isEmpty) {
                    BotToast.showText(text: "找不到歌曲 QAQ");
                    return;
                  }

                  final musicItem = row2MusicItem(dbRow: dbMusic[0]);
                  final navigator = Navigator.of(context);

                  if (musicItem.lyric.isNotEmpty) {
                    navigator.push(ModalBottomSheetRoute(
                      isScrollControlled: true,
                      builder: (context) {
                        return LyricsCard(
                          imageInfo: _imageInfo,
                          imageProvider: _imageProvider,
                          errorCoverUrl: errorCoverUrl,
                        );
                      },
                    ));
                  } else {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const SearchLyricMusicView();
                        },
                      ),
                    );
                  }
                }
              }
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Color primaryColor) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double gap = isLandscape ? 20 : 10;
    final double sizeA = isLandscape ? 50 : 30;
    final double sizeB = isLandscape ? 60 : 40;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ModeButton(size: sizeA, color: primaryColor),
        SizedBox(width: gap),
        PrevButton(size: sizeB, color: primaryColor),
        SizedBox(width: gap),
        PlayButton(size: sizeB, color: primaryColor),
        SizedBox(width: gap),
        NextButton(size: sizeB, color: primaryColor),
        SizedBox(width: gap),
        PlayerListButton(size: sizeA, color: primaryColor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<PlayerModel>(
      builder: (context, player, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: _imageInfo != null
                  ? Image(
                      image: _imageProvider!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      errorCoverUrl,
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            Container(
              width: screenSize.width, // 确保整体宽度占满屏幕
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              ),
              padding: EdgeInsets.only(bottom: isLandscape ? 30 : 0),
              child: Column(
                children: [
                  _buildTopBar(primaryColor),
                  Expanded(
                    child: isLandscape
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildRecordWidget(),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildMusicInfo(primaryColor),
                                    const SizedBox(height: 30),
                                    _buildActionButtons(primaryColor),
                                    const SizedBox(height: 20),
                                    PlayerProgress(color: primaryColor),
                                    const SizedBox(height: 30),
                                    _buildControlButtons(primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildRecordWidget(),
                              _buildMusicInfo(primaryColor),
                              const SizedBox(height: 30),
                              _buildActionButtons(primaryColor),
                              const SizedBox(height: 20),
                              PlayerProgress(color: primaryColor),
                              const SizedBox(height: 30),
                              _buildControlButtons(primaryColor),
                            ],
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ignore: must_be_immutable
class PlayerProgress extends StatefulWidget {
  Color? color;

  PlayerProgress({
    super.key,
    this.color,
  });

  @override
  State<PlayerProgress> createState() => _PlayerProgressState();
}

class _PlayerProgressState extends State<PlayerProgress> {
  double _value = 0;
  bool _isChanged = false;
  List<StreamSubscription<Duration>?> listens = [];

  @override
  void initState() {
    final player = Provider.of<PlayerModel>(context, listen: false);
    super.initState();

    listens.add(player.listenPosition((event) {
      if (_isChanged || !mounted) return;
      double c = event.inSeconds.toDouble();
      double total = player.duration?.inSeconds.toDouble() ?? 0.0;
      double v = c / total;
      if (v.isNaN) return;
      if (v > 1.0) {
        v = 1.0;
      }
      if (v < 0.0) {
        v = 0;
      }
      setState(() {
        _value = v;
      });
    }));
  }

  @override
  void dispose() {
    for (final listen in listens) {
      listen?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.color ?? Theme.of(context).primaryColor;

    return Consumer<PlayerModel>(builder: (context, player, child) {
      int total = (player.duration?.inSeconds ?? 0);

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: CustomTrackShape(context, primaryColor),
              thumbShape: CustomThumbShape(context, primaryColor),
            ),
            child: Slider(
              value: _value,
              onChanged: (v) {
                setState(() {
                  _value = v;
                });
              },
              onChangeStart: (value) {
                setState(() {
                  _isChanged = true;
                });
              },
              onChangeEnd: (value) {
                final player = Provider.of<PlayerModel>(context, listen: false);
                int v = (value * total).toInt();
                player.seek(Duration(seconds: v));
                setState(() {
                  _isChanged = false;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  seconds2duration((_value * total).toInt()),
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
                Text(
                  seconds2duration(total),
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class CustomThumbShape extends SliderComponentShape {
  final BuildContext context;
  Color? color;

  CustomThumbShape(this.context, this.color);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, 0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final primaryColor = color ?? Theme.of(this.context).primaryColor;
    final canvas = context.canvas;
    final paint = Paint()..color = primaryColor;
    canvas.drawCircle(center, 4, paint);
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  final BuildContext context;
  Color? color;

  CustomTrackShape(this.context, this.color);

  Rect getPreferredSize({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    double trackHeight = 2;
    double trackWidth = parentBox.size.width - 48;
    return Rect.fromLTWH(offset.dx, offset.dy, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final canvas = context.canvas;
    final primaryColor = color ?? Theme.of(this.context).primaryColor;
    final Rect trackRect = getPreferredSize(
      parentBox: parentBox,
      offset: Offset(24, thumbCenter.dy - 1),
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Paint activeTrackPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final double thumbX = thumbCenter.dx;
    final Rect activeTrackRect = Rect.fromLTWH(
      trackRect.left,
      trackRect.top,
      thumbX - trackRect.left,
      trackRect.height,
    );
    canvas.drawRect(activeTrackRect, activeTrackPaint);

    final Paint inactiveTrackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final Rect inactiveTrackRect = Rect.fromLTWH(
      thumbX,
      trackRect.top,
      trackRect.right - thumbX,
      trackRect.height,
    );
    canvas.drawRect(inactiveTrackRect, inactiveTrackPaint);
  }
}
