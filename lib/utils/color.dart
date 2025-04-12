import "package:flutter/material.dart";

class ColorPallette {
  // 增强版颜色混合函数（支持深色模式自动反转）
  static  colorMix(BuildContext context, [double ratio = 0.05]) {
    final baseColor = Theme.of(context).primaryColor;
    final brightness = Theme.of(context).brightness;

    // 深色模式使用黑色作为混合基色
    final mixer = brightness == Brightness.dark ? Colors.black : Colors.white;

    return Color.lerp(mixer, baseColor, ratio.clamp(0, 0.2))!;
  }
}
