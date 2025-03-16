import "package:bobomusic/constants/theme_color.dart";
import "package:flutter/material.dart";

class ThemeColorSetting extends StatefulWidget {
  final Color initialColor;
  final Function(Color, String, VoidCallback) onColorChanged;

  const ThemeColorSetting({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  ThemeColorSettingState createState() => ThemeColorSettingState();
}

class ThemeColorSettingState extends State<ThemeColorSetting> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  // 获取对应颜色的 500 色值，如果不是 ColorSwatch 则使用原颜色
  Color getColorShade(Color color) {
    if (color is MaterialColor) {
      return color[300]!;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "更换主题色",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 8, right: 10),
        child: _buildColorCard(),
      )
    );
  }

  Widget _buildColorCard() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
      ),
      itemCount: ThemeColor.availableColors.length,
      itemBuilder: (context, index) {
        final color = ThemeColor.availableColors[index];
        final colorName = ThemeColor.colorNames[index];
        return GestureDetector(
          onTap: () {
            widget.onColorChanged(color, colorName, () {
              setState(() {
                _selectedColor = color;
              });
            });
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      getColorShade(color),
                      color,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    colorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Radio<Color>(
                  value: color,
                  groupValue: _selectedColor,
                  // activeColor: Colors.white,
                  // 设置环形颜色
                  fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // 选中时的颜色
                    }
                    return Colors.white70; // 未选中时的颜色
                  }),
                  onChanged: (Color? value) {
                    if (value != null) {
                      widget.onColorChanged(value, colorName, () {
                        setState(() {
                          _selectedColor = color;
                        });
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
