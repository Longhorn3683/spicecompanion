import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spicecompanion/views/views.dart';
import 'package:spicecompanion/util/util.dart';

import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 600),
      minimumSize: Size(350, 600),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // load settings
  await Settings.load();

  // pre-load patches
  PatchManager.inst.importDefaults();

  // reset patch states on connection change
  ConnectionPool.inst.changes.stream.listen((pool) {
    PatchManager.inst.resetStates();
  });

  // start tag manager
  TagManager.inst.start();

  // run app
  runApp(const MainView());
}
