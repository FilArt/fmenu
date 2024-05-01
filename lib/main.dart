import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main(List<String> args) async {
  // kill other fmenu instances
  String pids = Process.runSync('pidof', ['fmenu']).stdout;
  List<int> pidList = pids.split(' ').map((e) => int.parse(e)).toList();
  for (int _pid in pidList) {
    if (pid == _pid) continue;
    Process.killPid(_pid, ProcessSignal.sigterm);
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomeScreen(), theme: ThemeData.dark());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool dialog = false;

  @override
  Widget build(BuildContext context) {
    return const RofiLikeDialog();
  }
}

class RofiLikeDialog extends StatefulWidget {
  const RofiLikeDialog({super.key});

  @override
  _RofiLikeDialogState createState() => _RofiLikeDialogState();
}

// class for application: with name, executable and icon
class DesktopApp {
  String name;
  String command;
  String icon;
  DesktopApp(this.name, this.command, this.icon);

  void run() {
    String exe = command.split(' ')[0];
    // String args = command.split(' ').sublist(1).join(' ');
    Process.start(exe, []).then((value) => exit(0));
  }
}

class _RofiLikeDialogState extends State<RofiLikeDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<DesktopApp> _allItems = [];
  List<DesktopApp> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _allItems.addAll(getApps());
    _filteredItems = _allItems;
  }

  void _filterItems(String enteredKeyword) {
    List<DesktopApp> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allItems;
    } else {
      results = _allItems
          .where((item) =>
              item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredItems = results;
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
                autofocus: true,
                controller: _controller,
                onChanged: _filterItems,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
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
        return ListTile(
          title: Text(_filteredItems[index].name),
          subtitle: Text(_filteredItems[index].icon),
          leading: SizedBox(
            width: 32,
            child: _filteredItems[index].icon.isEmpty
                ? null
                : Image.file(File(_filteredItems[index].icon)),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _filteredItems[index].run();
          },
        );
      },
    );
  }
}

List<DesktopApp> getApps() {
  final iconsDirs = ['/usr/share/icons', '/usr/share/pixmaps'];
  final icons = Set.from(iconsDirs.expand((d) => Directory(d)
      .listSync()
      .whereType<File>()
      .where((e) => e.path.endsWith('.png'))
      .map((e) => e.path)
      .toList()));
  final tempDir = Directory('/usr/share/applications');
  final apps = <DesktopApp>[];
  for (final entity in tempDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.desktop')) continue;
    final content = entity.readAsStringSync();
    final lines = LineSplitter.split(content);
    String? name, executable, icon;
    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length != 2) continue;
      final key = parts[0];
      final value = parts[1].trim();
      switch (key) {
        case 'Name':
          name = value;
          break;
        case 'Exec':
          executable = value;
          break;
        case 'Icon':
          icon = value;
          break;
      }
      if (name != null && executable != null && icon != null) break;
    }
    if (name != null && executable != null) {
      final iconPath = icon == null
          ? ''
          : icons.firstWhere(
              (element) =>
                  element.contains(icon) &&
                  (element.endsWith('.png') ||
                      element.endsWith('.svg') ||
                      element.endsWith('.xpm')),
              orElse: () => '');
      apps.add(DesktopApp(name, executable, iconPath));
    }
  }
  apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return apps;
}
