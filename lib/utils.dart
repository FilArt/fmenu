import 'dart:convert';
import 'dart:io';
import 'package:fmenu/menu_item.dart';

List<MenuItem> parseDesktopFile(File file, Map<String, String> icons) {
  final content = file.readAsStringSync();
  final menuItems = <MenuItem>[];
  final lines = LineSplitter.split(content).toList();

  var index = 0;

  String name = '';
  String executable = '';
  String icon = '';

  void addMenuItem() {
    menuItems.add(MenuItem(name, executable, icons[icon] ?? ''));
    name = '';
    executable = '';
  }

  while (index < lines.length) {
    final line = lines[index];
    if (line.startsWith('#')) {
      index++;
      continue;
    }

    if (line.startsWith('Name=')) {
      if (name.isNotEmpty) {
        addMenuItem();
      }
      name = line.substring(5).trim();
    } else if (line.startsWith('Exec=')) {
      executable = line.substring(5).trim();
    } else if (line.startsWith('Icon=')) {
      icon = line.substring(5).trim();
    }

    if (name.isNotEmpty && executable.isNotEmpty && icon.isNotEmpty) {
      addMenuItem();
    }

    index++;
  }
  return menuItems;
}

// String? name, executable, icon;
// for (final line in lines) {
//   final parts = line.split('=');
//   if (parts.length != 2) continue;
//   final key = parts[0];
//   final value = parts[1].trim();
//   switch (key) {
//     case 'Name':
//       name = value;
//       break;
//     case 'Exec':
//       executable = value;
//       break;
//     case 'Icon':
//       icon = value;
//       break;
//   }
// }
// return MenuItem(name ?? '', executable, icons[icon] ?? '');
// }

Map<String, String> getIcons() {
  final iconsDirs = ['/usr/share/icons', '/usr/share/pixmaps'];
  final icons = <String, String>{};
  for (final iconDir in iconsDirs) {
    final iconDirPath = Directory(iconDir);
    if (!iconDirPath.existsSync()) continue;
    final iconFiles = iconDirPath
        .listSync(recursive: true)
        .whereType<File>()
        .where((e) => e.path.endsWith('.png') || e.path.endsWith('.svg'));
    for (final iconFile in iconFiles) {
      final iconFileName = iconFile.path.split('/').last.split('.').first;
      icons[iconFileName] = iconFile.path;
    }
  }
  return icons;
}

List<MenuItem> getMenuItems() {
  final icons = getIcons();
  Iterable<Directory> directories = [
    Directory('/usr/share/applications'),
    Directory('/usr/local/share/applications'),
    Directory('~/.local/share/applications')
  ].where((directory) => directory.existsSync());

  Iterable files = directories
      .map((directory) => directory.listSync().whereType<File>())
      .expand((e) => e);

  List<MenuItem> items = files
      .map((file) => parseDesktopFile(file, icons))
      .expand((menuItem) => menuItem)
      .toList();

  // group by icon, and sort by name of the first executable in the group
  List<String> groupNames =
      items.map((e) => e.icon).whereType<String>().toSet().toList();
  List<List<MenuItem>> groups = groupNames
      .map((e) => items.where((item) => item.icon == e).toList())
      .toList();

  groups.sort(
      (a, b) => a[0].name.toLowerCase().compareTo(b[0].name.toLowerCase()));

  return groups.expand((e) => e).toList();
}
