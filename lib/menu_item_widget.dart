import 'package:flutter/material.dart';
import 'package:fmenu/menu_item.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    super.key,
    required MenuItem menuItem,
  }) : _menuItem = menuItem;

  final MenuItem _menuItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_menuItem.name),
      subtitle: Text(_menuItem.command ?? ''),
      leading: SizedBox(
        width: 32,
        child: _menuItem.getImage(),
      ),
      onTap: () {
        Navigator.of(context).pop();
        _menuItem.onSelect();
      },
    );
  }
}
