import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

Future<String> _preferencesPathGet() async {
  String filename = "spicecompanion.json";
  if (Platform.isWindows) {
    var configPath = Path.join(Platform.environment["APPDATA"], "Spice L3");
    Directory configDir = Directory(configPath);
    if (!(await configDir.exists())) configDir.create();
    return Path.join(configPath, filename);
  }
  if (Platform.isLinux || Platform.isMacOS) {
    var configPath = Path.join(Platform.environment["HOME"], ".spicel3");
    Directory configDir = Directory(configPath);
    if (!(await configDir.exists())) configDir.create();
    return Path.join(configPath, filename);
  }
  throw UnsupportedError("Unsupported platform for preferences file.");
}

Future<String> _preferencesFileRead() async {
  return File(await _preferencesPathGet()).readAsString();
}

Future<void> _preferencesFileWrite(String content) async {
  return File(await _preferencesPathGet()).writeAsString(content);
}

Map _preferencesMapCache;

Future<Map> _preferencesMapGet() async {
  // check cache first
  if (_preferencesMapCache != null) return _preferencesMapCache;

  // load from file
  try {
    var json = await _preferencesFileRead();
    return jsonDecode(json);
  } on Exception {
    _preferencesFileWrite(jsonEncode({}));
    return {};
  }
}

Future<void> _preferencesMapSet(Map map) {
  _preferencesMapCache = map;
  return _preferencesFileWrite(jsonEncode(map));
}

Future<void> preferencesSetString(String key, String value) async {
  if (Platform.isAndroid ||
          Platform.isIOS ||
          defaultTargetPlatform == TargetPlatform.ohos //|| Platform.isOhos
      ) {
    return SharedPreferences.getInstance().then((prefs) {
      prefs.setString(key, value);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    map[key] = value;
    await _preferencesMapSet(map);
  }
}

Future<void> preferencesSetStringList(String key, List<String> values) async {
  if (Platform.isAndroid ||
          Platform.isIOS ||
          defaultTargetPlatform == TargetPlatform.ohos //|| Platform.isOhos
      ) {
    return SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(key, values);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    map[key] = values;
    await _preferencesMapSet(map);
  }
}

Future<String> preferencesGetString(String key) async {
  if (Platform.isAndroid ||
          Platform.isIOS ||
          defaultTargetPlatform == TargetPlatform.ohos //|| Platform.isOhos
      ) {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getString(key);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    var val = map[key];
    if (val is String) return val;
    return null;
  }
  return null;
}

Future<List> preferencesGetStringList(String key) async {
  if (Platform.isAndroid ||
          Platform.isIOS ||
          defaultTargetPlatform == TargetPlatform.ohos //|| Platform.isOhos
      ) {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getStringList(key);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    var val = map[key];
    if (val is List) return val;
    return null;
  }
  return null;
}

bool isFullScreen = false;

void fullscreenToggle() async {
  if (!isFullScreen) {
    isFullScreen = true;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.setFullScreen(isFullScreen);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  } else {
    isFullScreen = false;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.setFullScreen(isFullScreen);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
