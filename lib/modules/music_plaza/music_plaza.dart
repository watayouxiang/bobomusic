import "dart:convert";

import "package:bobomusic/components/add_to_order/add_to_order.dart";
import "package:bobomusic/db/db.dart";
import "package:bobomusic/modules/music_plaza/components/detail.dart";
import "package:bobomusic/modules/music_plaza/search/search.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:path/path.dart" as path;
import "package:flutter/services.dart" show rootBundle;

final dio = Dio();
final DBOrder db = DBOrder();

class MusicPlazaView extends StatefulWidget {
  const MusicPlazaView({super.key});

  @override
  State<MusicPlazaView> createState() => MusicPlazaViewState();
}

class MusicPlazaViewState extends State<MusicPlazaView> with AutomaticKeepAliveClientMixin {
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
    final list = await readDataFromJson(filePath: path.join("assets", "chinese.json"));
    setState(() {
      singerList = list;
    });

    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    for (var order in singerList) {
      if (!await db.isTableExists(order.name)) {
        await db.createOrderTable(order.name);

        for (var music in order.musicList) {
          final newM = (music as MusicItem).copyWith(playId: music.playId.isEmpty ? uuid.v4() : music.playId, orderName: order.name);
          await db.insert(order.name, musicItem2Row(music: newM));
        }
      }
    }

    EasyLoading.dismiss();
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

  // 信息
  Widget builderInfo(MusicOrderItem item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromRGBO(0, 0, 0, 0.4),
      alignment: AlignmentDirectional.center,
      child: Text(
        item.musicList.length.toString(),
        style: const TextStyle(
          height: 1,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const SearchView();
                },
              ),
            )
          },
          child: Container(
            padding: const EdgeInsets.only(right: 4),
            child: const TextField(
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 239, 240, 241),
                constraints: BoxConstraints(maxHeight: 35),
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: "搜索互联网歌曲",
                hintStyle: TextStyle(fontSize: 12),
                contentPadding: EdgeInsets.symmetric(vertical: 13.5, horizontal: 16),
              ),
            ),
          ),
        )
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
              Positioned(
                child: builderInfo(item),
              )
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

Future<List> readDataFromJson({required String filePath}) async {
  try {
    String jsonString = await rootBundle.loadString(filePath);
    dynamic jsonData = json.decode(jsonString);

    List targetList = jsonData.map((item) {
      return MusicOrderItem.fromJson(item as Map<String, dynamic>);
    }).toList();

    return targetList;
  } catch(error) {
    return [];
  }
}
