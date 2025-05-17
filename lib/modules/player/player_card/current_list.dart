import "package:bobomusic/components/music_list_tile/music_list_tile.dart";
import "package:bobomusic/modules/download/model.dart";
import "package:bobomusic/modules/music_order/utils.dart";
import "package:bobomusic/utils/check_music_local_repeat.dart";
import "package:flutter/material.dart";
import "package:bobomusic/components/sheet/bottom_sheet.dart";
import "package:bobomusic/modules/player/model.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:provider/provider.dart";

class CurrentList extends StatefulWidget {
  final List<MusicItem> musicList;
  const CurrentList({super.key, required this.musicList});

  @override
  State<CurrentList> createState() => CurrentListState();
}

class CurrentListState extends State<CurrentList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.6;
    double topHeight = 56;
    return Consumer<PlayerModel>(
      builder: (context, player, child) {
        return SizedBox(
          height: height,
          width: MediaQuery.of(context).size.width,
          child: Flex(
            direction: Axis.vertical,
            children: [
              _buildTopBar(context, player, topHeight),
              _buildList(context, player, height - topHeight)
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerModel player, double topHeight) {
    return Container(
      height: topHeight,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Text(
                  "当前播放列表",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  "${widget.musicList.length}首歌曲",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, PlayerModel player, double h) {
    if (widget.musicList.isEmpty) {
      return const Center(child: Text("没有歌曲"));
    }

    return SizedBox(
      height: h,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: widget.musicList.length,
        itemBuilder: (context, index) {
          final item = widget.musicList[index];
          return MusicListTile(
            item,
            showAddIcon: false,
            onMore: () => showItemSheet(context, item, player),
          );
        },
      ),
    );
  }

  void showItemSheet(BuildContext context, MusicItem data, PlayerModel player) {
    openBottomSheet(context, [
      SheetItem(
        title: Text(
          data.name,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      SheetItem(
        title: const Text("播放"),
        onPressed: () => player.play(music: data),
      ),
      SheetItem(
        title: const Text("添加到歌单"),
        onPressed: () => collectToMusicOrder(context: context, musicList: [data]),
      ),
      SheetItem(
        title: const Text("添加到待播放列表"),
        onPressed: () => player.addPlayerList([data], showToast: true),
      ),
      SheetItem(
        title: const Text("下载"),
        onPressed: () {
          checkMusicLocalRepeat(context, data, () {
            final downloadModel = Provider.of<DownloadModel>(context, listen: false);
            downloadModel.download([data]);
          });
        },
      ),
    ]);
  }
}
