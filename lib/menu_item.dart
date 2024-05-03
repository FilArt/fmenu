import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem {
  String name;
  String? command;
  String icon;
  MenuItem(this.name, this.command, this.icon);

  Future<void> onSelect() async {
    if (command == null) return;
    String exe = command!.split(' ')[0];
    // String args = command.split(' ').sublist(1).join(' ');
    await Process.start(exe, []);
    exit(0);
  }

  getImage() {
    if (icon.isEmpty) {
      return null;
    }
    if (icon.endsWith('.svg')) {
      return SvgPicture.file(File(icon));
    } else {
      return Image.file(File(icon));
    }
  }
}
