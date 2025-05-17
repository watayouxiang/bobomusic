import "package:flutter/material.dart";

class RippleIcon extends StatelessWidget {
  final Widget child;       // 必传：图标数据
  final double size;        // 必传：图标尺寸（控制水波纹基准大小）
  final VoidCallback? onTap;     // 必传：点击回调
  final Color? splashColor;     // 可选：水波纹颜色（默认使用主题色）
  final Color? highlightColor;  // 可选：高亮颜色（默认透明）

  const RippleIcon({
    super.key,
    required this.child,
    required this.size,
    this.onTap,
    this.splashColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // 获取主题色（默认值）
    final themeColor = Theme.of(context).primaryColor;

    return Material(
      // 透明背景，避免遮挡图标颜色
      color: Colors.transparent,
      child: InkWell(
        // 水波纹颜色：优先使用传入值，否则用主题色+透明度
        splashColor: splashColor ?? themeColor.withValues(alpha: 0.2),
        // 关键：根据图标尺寸动态计算圆形半径
        borderRadius: BorderRadius.circular(size),
        // 水波纹最大扩散半径：图标尺寸的 1.5 倍（可自定义倍数）
        // radius: size * 1.5,
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Padding(padding: const EdgeInsets.all(8), child: child)
      )
    );
  }
}
