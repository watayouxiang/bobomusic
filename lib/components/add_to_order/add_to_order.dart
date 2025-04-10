import "package:bobomusic/db/db.dart";
import "package:bobomusic/event_bus/event_bus.dart";
import "package:bobomusic/modules/music_order/components/edit_order.dart";
import "package:bobomusic/modules/music_order/utils.dart";
import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:uuid/uuid.dart";

const uuid = Uuid();

class AddToOrder extends StatefulWidget {
  final List<MusicItem> wantToCollectMusics;
  final Function? onConfirm;
  const AddToOrder({super.key, required this.wantToCollectMusics, this.onConfirm});

  @override
  State<AddToOrder> createState() => _AddToOrderState();
}

class _AddToOrderState extends State<AddToOrder> {
  List<String> orderList = [];
  double height = 0;
  List<String> selectedKeys = [];

  final DBOrder db = DBOrder();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await getCustomOrderList();
    final justOne = widget.wantToCollectMusics.length == 1;
    final List<String> wholeList = [TableName.musicILike, ...list];

    if (justOne) {
      for (var order in wholeList) {
        final dbMusics = await db.queryByParam(order, widget.wantToCollectMusics[0].id);

        if (dbMusics.isNotEmpty) {
          selectedKeys.add(order);
        }
      }
    }

    setState(() {
      orderList = wholeList;
      height = 55 * orderList.length + 140;
      selectedKeys = selectedKeys;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        height: height <= screenHeight - 80 ? height : screenHeight - 80,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  final order = orderList[index];
                  return CheckboxListTile(
                    value: selectedKeys.contains(order),
                    checkColor: Colors.white,
                    activeColor: Theme.of(context).primaryColor,
                    title: Text(order),
                    onChanged: (v) {
                      setState(() {
                        if (selectedKeys.contains(order)) {
                          selectedKeys.remove(order);
                        } else {
                          selectedKeys.add(order);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              width: MediaQuery.of(context).size.width - 32,
              child: FilledButton(
                onPressed: () async {
                  EasyLoading.show(maskType: EasyLoadingMaskType.black);
                  final musics = widget.wantToCollectMusics;
                  final len = musics.length;
                  try {
                    for (int index = 0; index < len; index++) {
                      for (var order in selectedKeys) {
                        final dbMusics = await db.queryByParam(order, musics[index].id);
                        // 如果数据库里有了，需要先把原来的记录删除
                        if (dbMusics.isNotEmpty) {
                          for (var dbm in dbMusics) {
                            await db.delete(order, dbm["mid"]);
                          }
                        }

                        final MusicItem newItem = musics[index].copyWith(
                          playId: uuid.v4(),
                          orderName: order,
                        );

                        final row = musicItem2Row(music: newItem);

                        await db.insert(order, row);

                        eventBus.fire(RefreshMusicList(tabName: order));
                      }
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (widget.onConfirm != null) {
                      widget.onConfirm!();
                    }
                  } catch(error) {
                    BotToast.showText(text: "添加歌单失败，请重试");
                  }

                  EasyLoading.dismiss();
                },
                child: const Text("确认"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTopBar(context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 16,
        bottom: 5,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Row(
              children: [
                Text(
                  "添加歌曲到歌单",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              final NavigatorState navigator = Navigator.of(context, rootNavigator: false);
                navigator.push(ModalBottomSheetRoute(
                  isScrollControlled: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: EditMusicOrder(name: "", update: () {
                        eventBus.fire(RefreshTabList());
                        _loadData();
                      }),
                    );
                  },
                ));
            },
            child: const Text("新建歌单"),
          )
        ],
      ),
    );
  }
}
