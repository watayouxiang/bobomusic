import "package:bobomusic/constants/cache_key.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<bool> getLaunchBilibiliConfirm() async {
  final localStorage = await SharedPreferences.getInstance();
  final bool res = localStorage.getBool(CacheKey.launchBilibiliConfirm) ?? true;
  return res;
}

setLaunchBilibiliConfirm({required bool confirm}) async {
  final localStorage = await SharedPreferences.getInstance();
  await localStorage.setBool(CacheKey.launchBilibiliConfirm, confirm);
}

List<Map<String, dynamic>> parseLyrics(String lyrics) {
  List<Map<String, dynamic>> parsedLyrics = [];
  List<String> lines = lyrics.split('\n');
  for (String line in lines) {
    final newLine = line.replaceAll("&apos;", "'");
    RegExp regExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)');
    Match? match = regExp.firstMatch(newLine);
    if (match != null) {
      int minutes = int.parse(match.group(1)!);
      int seconds = int.parse(match.group(2)!);
      int milliseconds = int.parse(match.group(3)!);
      String text = match.group(4)!;
      if (text.trim().isNotEmpty) {
        int totalMilliseconds = (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;
        parsedLyrics.add({
          'time': totalMilliseconds,
          'text': text,
        });
      }
    }
  }
  parsedLyrics.sort((a, b) => a['time'].compareTo(b['time']));
  return parsedLyrics;
}