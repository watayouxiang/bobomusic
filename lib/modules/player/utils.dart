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