

import "package:bobomusic/constants/cache_key.dart";
import "package:bobomusic/constants/theme_color.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<Color> getCacheColor() async {
  final localStorage = await SharedPreferences.getInstance();
  final colorName = localStorage.getString(CacheKey.themeColor);
  final index = colorName != null ? ThemeColor.colorNames.indexWhere((name) => name == colorName) : 7;
  return ThemeColor.availableColors[index];
}
