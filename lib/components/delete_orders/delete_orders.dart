import "package:bobomusic/db/db.dart";
import "package:bobomusic/modules/music_order/utils.dart";
import "package:bot_toast/bot_toast.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";

class DeleteOrders extends StatefulWidget {
  final Function? onConfirm;
  const DeleteOrders({super.key, this.onConfirm});

  @override
  State<DeleteOrders> createState() => _DeleteOrdersState();
}

class _DeleteOrdersState extends State<DeleteOrders> {
  List<String> customOrderList = [];
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

    setState(() {
      customOrderList = list;
      height = 55 * customOrderList.length + 140;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 16),
        height: height <= screenHeight - 80 ? height : screenHeight - 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "删除歌单",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: customOrderList.length,
                itemBuilder: (context, index) {
                  final order = customOrderList[index];
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
              padding: const EdgeInsets.only(top: 2),
              width: MediaQuery.of(context).size.width - 32,
              child: FilledButton(
                onPressed: () async {
                  if (selectedKeys.isNotEmpty) {
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    try {
                      for (var key in selectedKeys) {
                        await db.dropTable(key);
                        delCustomOrderItem(name: key);
                      }
                    } catch(error) {
                      for (var key in selectedKeys) {
                        delCustomOrderItem(name: key);
                      }
                    }

                    final orderList = await getAllOrderList();

                    setCurrentTabIndex(index: orderList.length - 1);

                    if (widget.onConfirm != null) {
                      widget.onConfirm!();
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    EasyLoading.dismiss();
                  } else {
                    BotToast.showText(text: "至少选择一个歌单");
                  }
                },
                child: const Text("删除"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}