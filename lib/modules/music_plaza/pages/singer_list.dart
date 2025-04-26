import "package:bobomusic/modules/music_plaza/components/detail.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bobomusic/utils/read_data_from_json.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;

final dio = Dio();

class SingerList extends StatefulWidget {
  const SingerList({super.key});

  @override
  State<SingerList> createState() => SingerListViewState();
}

class SingerListViewState extends State<SingerList> with AutomaticKeepAliveClientMixin {
  final double _coverSize = 40;
  List singerList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSingerList();
  }

  Future<void> _loadSingerList() async {
    final jsonData = await readDataFromJson(filePath: path.join("assets", "chinese.json"));
    final list = jsonData.map((item) {
      return MusicOrderItem.fromJson(item as Map<String, dynamic>);
    }).toList();

    setState(() {
      singerList = list;
    });
  }

  // 歌单封面
  Widget builderCover(MusicOrderItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: item.cover != null && item.cover!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: item.cover!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromARGB(179, 209, 205, 205),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "歌手列表",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          ..._buildList(),
          const SizedBox(height: 60)
        ]
      ),
    );
  }

  _buildList() {
    return singerList.map((item) {
      return ListTile(
        title: Text(item.name),
        minTileHeight: _coverSize + 20,
        leading: SizedBox(
          width: _coverSize,
          height: _coverSize,
          child: Stack(
            children: [
              Positioned(
                child: builderCover(item),
              ),
            ],
          ),
        ),
        subtitle: item.desc.isNotEmpty ? Text(item.desc) : null,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return MusicOrderDetail(
                musicOrderItem: item,
                shouldLoadData: true,
              );
            },
          ));
        },
      );
    }).toList();
  }
}
