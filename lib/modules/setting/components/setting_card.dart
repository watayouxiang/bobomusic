import "package:flutter/material.dart";

class SettingItem {
  final IconData? leadingIcon;
  final String? title;
  final Widget? customTitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  SettingItem({
    this.leadingIcon,
    this.title,
    this.onTap,
    this.trailing,
    this.customTitle
  });
}

class SettingCard extends StatefulWidget {
  final List<SettingItem> settingItems;

  const SettingCard({super.key, required this.settingItems});

  @override
  State<SettingCard> createState() => SettingCardState();
}

class SettingCardState extends State<SettingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.settingItems.length * 55 + 20,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true, // 让 ListView 根据内容自适应高度
          physics: const NeverScrollableScrollPhysics(), // 禁止滚动
          itemCount: widget.settingItems.length,
          itemBuilder: (context, index) {
            final item = widget.settingItems[index];
            return _buildItem(
              leadingIcon: item.leadingIcon,
              title: item.title,
              customTitle: item.customTitle,
              onTap: item.onTap,
              trailing: item.trailing,
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem({
    IconData? leadingIcon,
    required String? title,
    VoidCallback? onTap,
    Widget? trailing,
    Widget? customTitle,
  }) {
    return ListTile(
      leading: leadingIcon != null
        ? Icon(
            leadingIcon,
            color: Theme.of(context).primaryColor,
          )
        : null,
      title: customTitle ?? Text(
        title ?? "",
        style: TextStyle(
          fontSize: 16,
          color: leadingIcon == null ? Colors.black : Colors.grey[700],
        ),
      ),
      trailing: trailing,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}