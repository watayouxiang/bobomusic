import "package:bobomusic/modules/user_music_order/common.dart";
import "package:bobomusic/modules/user_music_order/github/constants.dart";
import "package:bobomusic/modules/user_music_order/github/github.dart";
import "package:bobomusic/modules/user_music_order/local/constants.dart";
import "package:bobomusic/modules/user_music_order/local/local.dart";

final Map<String, UserMusicOrderOrigin Function()> userMusicOrderOrigin = {
  LocalOriginConst.name: () => UserMusicOrderForLocal(),
  GithubOriginConst.name: () => UserMusicOrderForGithub(),
};
