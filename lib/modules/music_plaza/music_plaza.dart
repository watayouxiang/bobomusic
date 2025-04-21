import "package:bobomusic/db/db.dart";
import "package:bobomusic/modules/music_plaza/components/collection.dart";
import "package:bobomusic/modules/music_plaza/components/singer_row.dart";
import "package:bobomusic/modules/music_plaza/search/search.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";

final dio = Dio();
final DBOrder db = DBOrder();

class MusicPlazaView extends StatefulWidget {
  const MusicPlazaView({super.key});

  @override
  State<MusicPlazaView> createState() => MusicPlazaViewState();
}

class MusicPlazaViewState extends State<MusicPlazaView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      body: SafeArea(
        bottom: true,
        child: Container(
          color: const Color.fromARGB(255, 245, 245, 245),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: const SingleChildScrollView(
            child: Column(
              children: [
                SingerRow(),
                SizedBox(height: 16),
                Collection()
              ],
            ),
          )
        )
      ),
    );
  }
}
