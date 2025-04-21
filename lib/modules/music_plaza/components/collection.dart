import "package:bobomusic/components/title_area/title_area.dart";
import "package:bobomusic/modules/music_plaza/components/collection_item.dart";
import "package:bobomusic/modules/music_plaza/components/detail.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bobomusic/utils/read_data_from_json.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => CollectionViewState();
}

class CollectionViewState extends State<Collection> {
  List<Widget> singerList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSingerList();
    });
  }

  Future<void> _loadSingerList() async {
    final jsonData = await readDataFromJson(filePath: path.join("assets", "chinese.json"));
    List<MusicOrderItem> list = [];
    list = jsonData.map((item) {
      return MusicOrderItem.fromJson(item as Map<String, dynamic>);
    }).toList();
    List<Widget> singerViewList = [];

    for (var i = 0; i < list.length - 1; i++) {
      if (i > 0 && i % 2 == 1) {
        continue;
      }

      singerViewList.add(
        Row(children: [
          CollectionItem(
            imageUrl: list[i].cover!,
            name: list[i].name,
            author: list[i].author.isNotEmpty ? list[i].author : "哔哩哔哩用户",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return MusicOrderDetail(
                    musicOrderItem: list[i],
                    shouldLoadData: true,
                  );
                },
              ));
            },
          ),
          const SizedBox(width: 16),
          CollectionItem(
            imageUrl: list[i + 1].cover!,
            name: list[i + 1].name,
            author: list[i].author.isNotEmpty ? list[i].author : "哔哩哔哩用户",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return MusicOrderDetail(
                    musicOrderItem: list[i + 1],
                    shouldLoadData: true,
                  );
                },
              ));
            },
          ),
        ])
      );
    }

    setState(() {
      singerList = singerViewList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        children: [
          const TitleAreaView(title: "收藏合集"),
          Column(children: singerList),
          const SizedBox(height: 50)
        ],
      )
    );
  }
}
