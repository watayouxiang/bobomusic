import "package:flutter/material.dart";

class VinylRecordWidget extends StatefulWidget {
  final String albumCoverUrl;
  final String errorAlbumCoverUrl;
  final bool isPlaying;

  const VinylRecordWidget({
    super.key,
    required this.albumCoverUrl,
    required this.errorAlbumCoverUrl,
    required this.isPlaying,
  });

  @override
  VinylRecordWidgetState createState() => VinylRecordWidgetState();
}

class VinylRecordWidgetState extends State<VinylRecordWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  late ImageStreamListener _imageStreamListener;
  ImageInfo? _localImageInfo;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    if (widget.isPlaying) {
      _animationController.repeat(reverse: false);
    }

    _imageProvider = NetworkImage(widget.albumCoverUrl);
    _imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        setState(() {
          _imageInfo = info;
        });
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        print("Image loading error: $exception");
        _loadLocalImage();
      },
    );
    _loadImage();
    _loadLocalImage();
  }

  void _loadImage() {
    _imageStream = _imageProvider?.resolve(const ImageConfiguration());
    _imageStream?.addListener(_imageStreamListener);
  }

  void _loadLocalImage() {
    final ImageProvider localImageProvider =
        AssetImage(widget.errorAlbumCoverUrl);
    localImageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          setState(() {
            _localImageInfo = info;
          });
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant VinylRecordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
    if (widget.albumCoverUrl != oldWidget.albumCoverUrl) {
      _imageProvider = NetworkImage(widget.albumCoverUrl);
      _loadImage();
    }
    if (widget.errorAlbumCoverUrl != oldWidget.errorAlbumCoverUrl) {
      _loadLocalImage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageStream?.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 整体宽高缩小一半
    final containerSize = screenWidth * 0.9;
    final recordSize = containerSize * 0.9;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerSize / 2,
              height: containerSize,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 50, 50, 50),
                    offset: Offset(5, 3), // 阴影偏移量
                    blurRadius: 5, // 阴影模糊半径
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                image: _imageInfo != null
                  ? DecorationImage(
                      image: _imageProvider!,
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(widget.errorAlbumCoverUrl),
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.5,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: CustomPaint(
                    size: Size(recordSize, recordSize),
                    painter: VinylRecordPainter(
                      imageInfo: _imageInfo,
                      localImageInfo: _localImageInfo,
                      albumCoverSize: Size(containerSize, containerSize),
                      localImagePath: widget.errorAlbumCoverUrl,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VinylRecordPainter extends CustomPainter {
  final ImageInfo? imageInfo;
  final ImageInfo? localImageInfo;
  final Size albumCoverSize;
  final String localImagePath;

  VinylRecordPainter({
    required this.imageInfo,
    required this.localImageInfo,
    required this.albumCoverSize,
    required this.localImagePath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制黑胶唱片的背景
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制唱片的纹路，添加明度渐变
    for (double r = radius * 0.2; r < radius * 0.9; r += 5) {
      // 计算当前半径对应的明度（从中心向外逐渐变暗）
      final brightness = 1.0 - (r / radius); // 明度从 1.0（最亮）到 0.1（最暗）
      final randomColor = Color.fromRGBO(
        (20 + (r % 30) * brightness).toInt(), // R 分量
        (20 + (r % 30) * brightness).toInt(), // G 分量
        (20 + (r % 30) * brightness).toInt(), // B 分量
        1, // 不透明度
      );
      final groovePaint = Paint()
        ..color = randomColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1 + (r % 3) / 3); // 线条粗细
      canvas.drawCircle(center, r, groovePaint);
    }

    // 扩大唱片中心区域并绘制圆形裁切后的专辑封面
    final coverRadius = radius * 0.05 * 5; // 扩大 5 倍
    final coverRect = Rect.fromCircle(center: center, radius: coverRadius);

    // 创建圆形裁剪路径
    final path = Path();
    path.addOval(coverRect);
    canvas.clipPath(path);

    if (imageInfo != null) {
      // 计算适配后的图片区域
      final sourceSize = Size(imageInfo!.image.width.toDouble(),
          imageInfo!.image.height.toDouble());
      final destinationSize = coverRect.size;
      final fittedSizes =
          applyBoxFit(BoxFit.cover, sourceSize, destinationSize);
      final sourceRect = Alignment.center
          .inscribe(fittedSizes.source, Offset.zero & sourceSize);
      final destinationRect =
          Alignment.center.inscribe(fittedSizes.destination, coverRect);

      canvas.drawImageRect(
        imageInfo!.image,
        sourceRect,
        destinationRect,
        Paint(),
      );
    } else if (localImageInfo != null) {
      // 计算适配后的图片区域
      final sourceSize = Size(localImageInfo!.image.width.toDouble(),
          localImageInfo!.image.height.toDouble());
      final destinationSize = coverRect.size;
      final fittedSizes =
          applyBoxFit(BoxFit.cover, sourceSize, destinationSize);
      final sourceRect = Alignment.center
          .inscribe(fittedSizes.source, Offset.zero & sourceSize);
      final destinationRect =
          Alignment.center.inscribe(fittedSizes.destination, coverRect);

      canvas.drawImageRect(
        localImageInfo!.image,
        sourceRect,
        destinationRect,
        Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant VinylRecordPainter oldDelegate) {
    return oldDelegate.imageInfo != imageInfo ||
        oldDelegate.localImageInfo != localImageInfo;
  }
}
