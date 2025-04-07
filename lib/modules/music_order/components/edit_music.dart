import "dart:async";

import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:flutter/services.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";

// 编辑歌单内的歌曲信息
class EditMusic extends StatefulWidget {
  final MusicItem musicItem;
  final Function(MusicItem music) onOk;

  const EditMusic({
    super.key,
    required this.musicItem,
    required this.onOk,
  });

  @override
  State<EditMusic> createState() => EditMusicState();
}

class EditMusicState extends State<EditMusic> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = widget.musicItem.name;
      _authorController.text = widget.musicItem.author;
      _durationController.text = "${widget.musicItem.duration}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "修改歌曲信息",
              maxLines: 1,
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            maxLength: 100,
            autofocus: true,
            cursorColor: Colors.grey,
            decoration: const InputDecoration(
              // 正常状态下的边框样式和颜色
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              // 获得焦点时的边框样式和颜色
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              label: Text("歌曲名称 (必填)", style: TextStyle(color: Colors.grey)),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[\w\u4e00-\u9fa5\-\s]")),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _authorController,
            maxLength: 100,
            cursorColor: Colors.grey,
            decoration: const InputDecoration(
              // 正常状态下的边框样式和颜色
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              // 获得焦点时的边框样式和颜色
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              label: Text("歌手名称 (必填)", style: TextStyle(color: Colors.grey)),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[\w\u4e00-\u9fa5\-\s]")),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _durationController,
            maxLength: 100,
            cursorColor: Colors.grey,
            decoration: const InputDecoration(
              // 正常状态下的边框样式和颜色
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              // 获得焦点时的边框样式和颜色
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              label: Text("歌曲时长 (输入秒数)", style: TextStyle(color: Colors.grey)),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"\d+")),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                try {
                  final music = widget.musicItem.copyWith(
                    name: _nameController.text,
                    author: _authorController.text,
                    duration: int.parse(_durationController.text),
                  );

                  await widget.onOk(music);

                  Timer(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    EasyLoading.dismiss();
                  });
                } catch (e) {
                  EasyLoading.dismiss();
                  BotToast.showText(text: "歌曲更新失败");
                }
              },
              child: const Text("确认"),
            ),
          ),
        ],
      ),
    );
  }
}
