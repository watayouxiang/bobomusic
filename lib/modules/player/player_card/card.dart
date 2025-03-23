// ignore_for_file: unnecessary_string_interpolations

import "dart:async";
import "dart:ui";

import "package:bobomusic/modules/music_order/components/top_bar.dart";
import "package:bobomusic/constants/covers.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/event_bus/event_bus.dart";
import "package:bobomusic/modules/download/model.dart";
import "package:bobomusic/modules/player/player_card/vinyl_record.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:bobomusic/modules/player/player.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/utils/clear_html_tags.dart";
import "package:provider/provider.dart";
import "package:uuid/uuid.dart";

const uuid = Uuid();

final DBOrder db = DBOrder();

class PlayerCard extends StatefulWidget {
  const PlayerCard({super.key});

  @override
  State<PlayerCard> createState() => PlayerCardState();
}

class PlayerCardState extends State<PlayerCard> {
  bool isLike = false;
  String coverUrl = Covers.getRandomCover();
  String errorCoverUrl = Covers.getLocalRandomCover();
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _imageProvider = NetworkImage(coverUrl);

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

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, player, child) {
        final musicItem = player.current as MusicItem;
        final isLocal = musicItem.localPath.isNotEmpty;
        String subTitle = player.current!.orderName.isEmpty ? "未知歌单" : player.current!.orderName;
        final Color primaryColor = Theme.of(context).primaryColor;

        if (player.current!.author.isNotEmpty) {
          subTitle = "$subTitle  ${player.current!.author}";
        }

        return Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 16, top: 40, right: 20),
                    child: Row(
                      children: [
                        InkWell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 30),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: VinylRecordWidget(
                                albumCoverUrl: coverUrl,
                                errorAlbumCoverUrl: errorCoverUrl,
                                isPlaying: player.isPlaying,
                              )
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              left: 30,
                              top:30,
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
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    subTitle,
                                    style: TextStyle(
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.only(right: 95, left: 95),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Icon(Icons.download_outlined, color: primaryColor, size: 30),
                                  onTap: () {
                                    if (isLocal) {
                                      BotToast.showText(text: "本地音乐，无需下载");
                                      return;
                                    }

                                    final downloadModel = Provider.of<DownloadModel>(context, listen: false);
                                    downloadModel.download([musicItem]);
                                  },
                                ),
                                const SizedBox(width: 50),
                                InkWell(
                                  child: isLike ? const Icon(Icons.favorite, size: 30, color: Colors.red) : Icon(Icons.favorite_border_rounded, color: primaryColor, size: 30),
                                  onTap: () async {
                                    try {
                                      if (!isLike) {
                                        await db.insert(
                                          TableName.musicILike,
                                          musicItem2Row(music: player.current!.copyWith(orderName: TableName.musicILike, playId: uuid.v4()))
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
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const PlayerProgress(),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ModeButton(size: 30, color: primaryColor),
                              const SizedBox(width: 10),
                              PrevButton(size: 40, color: primaryColor),
                              const SizedBox(width: 10),
                              PlayButton(size: 50, color: primaryColor),
                              const SizedBox(width: 10),
                              NextButton(size: 40, color: primaryColor),
                              const SizedBox(width: 10),
                              PlayerListButton(size: 30, color: primaryColor),
                            ],
                          ),
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

class PlayerProgress extends StatefulWidget {
  const PlayerProgress({
    super.key,
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
    final Color primaryColor = Theme.of(context).primaryColor;

    return Consumer<PlayerModel>(builder: (context, player, child) {
      int total = (player.duration?.inSeconds ?? 0);

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: CustomTrackShape(context),
              thumbShape: CustomThumbShape(context),
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
                  style: TextStyle(color: primaryColor, fontSize: 12)
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

  CustomThumbShape(this.context);

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
    final primaryColor = Theme.of(this.context).primaryColor;
    final canvas = context.canvas;
    final paint = Paint()..color = primaryColor;
    canvas.drawCircle(center, 4, paint);
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  final BuildContext context;

  CustomTrackShape(this.context);

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
    final primaryColor = Theme.of(this.context).primaryColor;
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
