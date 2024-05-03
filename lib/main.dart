import 'package:flutter/material.dart';
import 'package:fmenu/hooks.dart';
import 'package:fmenu/menu_item_widget.dart';
import 'package:fmenu/menu_item.dart';
import 'package:fmenu/search_field.dart';
import 'package:fmenu/utils.dart';

void main(List<String> args) async {
  preInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Fmenu(), theme: ThemeData.dark());
  }
}

class Fmenu extends StatefulWidget {
  const Fmenu({super.key});

  @override
  FmenuState createState() => FmenuState();
}

class FmenuState extends State<Fmenu> {
  final TextEditingController _searchController = TextEditingController();
  final List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _allItems.addAll(getMenuItems());
    _filteredItems = _allItems;
  }

  void _filterItems(String enteredKeyword) {
    final search = enteredKeyword.toLowerCase().trim();
    setState(() {
      _filteredItems = (_allItems.where((item) =>
          item.name.toLowerCase().contains(search) ||
          (item.command != null &&
              item.command!.toLowerCase().contains(search)))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Fmenu')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: _searchController,
                  onChanged: (value) => Debouncer(milliseconds: 250).run(() {
                        _filterItems(value);
                      })),
            ),
            Expanded(
              child: buildListView(),
            ),
          ],
        ));
  }

  ListView buildListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return MenuItemWidget(menuItem: _filteredItems[index]);
      },
    );
  }
}
