import 'dart:io';

import 'package:flutter/material.dart';

void preInit() {
  _killOtherInstances();

  WidgetsFlutterBinding.ensureInitialized();
}

void _killOtherInstances() {
  String pids = Process.runSync('pidof', ['fmenu']).stdout;
  List<int> pidList = pids.split(' ').map((e) => int.parse(e)).toList();
  for (int fmenuPid in pidList) {
    if (pid == fmenuPid) continue;
    Process.killPid(fmenuPid, ProcessSignal.sigterm);
  }
}
