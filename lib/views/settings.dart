part of views;

class Settings {
  static const preferencesKey = "settings";

  static bool _darkMode;
  static get darkMode {
    return _darkMode;
  }

  static bool _blackMode;
  static get blackMode {
    return _blackMode;
  }

  static bool _alwaysOn;
  static get alwaysOn {
    return _alwaysOn;
  }

  static set darkMode(bool value) {
    if (_darkMode == value) return;
    switch (value) {
      case false:
        currentTheme = SpiceTheme.Light;
        break;
      case true:
        currentTheme = _blackMode ? SpiceTheme.Black : SpiceTheme.Dark;
        break;
    }
    _darkMode = value;
    save();
  }

  static set blackMode(bool value) {
    if (_blackMode == value) return;
    switch (value) {
      case false:
        if (_darkMode == true) {
          currentTheme = SpiceTheme.Dark;
        }
        break;
      case true:
        if (_darkMode == true) {
          currentTheme = SpiceTheme.Black;
        }
        break;
    }
    _blackMode = value;
    save();
  }

  static set alwaysOn(bool value) {
    if (_alwaysOn == value) return;
    switch (value) {
      case false:
        WakelockPlus.disable();
        break;
      case true:
        WakelockPlus.enable();
        break;
    }
    _alwaysOn = value;
    save();
  }

  static double buttonVibrationDuration = 0;
  static double screenQuality = 40;
  static double screenThreads = 2;
  static double screenDivide = 2;

  static Future<void> save() {
    // build json
    var map = {};
    map["darkMode"] = darkMode;
    map["blackMode"] = blackMode;
    map["alwaysOn"] = alwaysOn;
    map["buttonVibrationDuration"] = buttonVibrationDuration;
    map["screenQuality"] = screenQuality;
    map["screenThreads"] = screenThreads;
    map["screenDivide"] = screenDivide;
    var json = jsonEncode(map);

    // save
    return preferencesSetString(preferencesKey, json);
  }

  static Future<void> load() async {
    // load defaults first
    defaults();

    // load from preferences
    try {
      var json = await preferencesGetString(preferencesKey);
      if (json != null && json.isNotEmpty) {
        // decode json
        var map = jsonDecode(json);
        darkMode = map["darkMode"] ?? darkMode;
        blackMode = map["blackMode"] ?? blackMode;
        alwaysOn = map["alwaysOn"] ?? alwaysOn;
        buttonVibrationDuration =
            map["buttonVibrationDuration"] ?? buttonVibrationDuration;
        screenQuality = map["screenQuality"] ?? screenQuality;
        screenThreads = map["screenThreads"] ?? screenThreads;
        screenDivide = map["screenDivide"] ?? screenDivide;
      }
    } catch (e) {
      preferencesSetString(preferencesKey, "");
    }
  }

  static void defaults() {
    currentTheme = SpiceTheme.Dark;
    _darkMode = true;
    _blackMode = false;
    _alwaysOn = false;
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({Key key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    Widget getVibrationTile() {
      if (Platform.isAndroid || Platform.isIOS) {
        return ListTile(
          title: Text(
              "${S.current.button_vibration}: ${Settings.buttonVibrationDuration.toInt()}ms"),
          subtitle: Slider(
            value: Settings.buttonVibrationDuration,
            min: 0,
            max: 200,
            divisions: 200,
            onChanged: (value) {
              Settings.buttonVibrationDuration = value;
              Settings.save();
              setState(() {});
            },
            onChangeEnd: (value) {
              if (value > 0) {
                Vibration.vibrate(
                    duration: Settings.buttonVibrationDuration.toInt());
              }
            },
          ),
        );
      } else {
        return const SizedBox();
      }
    }

    Widget getOpenScreenshotsTile() {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return ListTile(
            title: Text(S.current.open_screenshots),
            onTap: () async {
              var dir = await getApplicationDocumentsDirectory();
              var screenshots = Directory('${dir.path}/Spice L3');
              if (!screenshots.existsSync()) {
                await screenshots.create();
              }
              launchUrl(Uri.parse('file:///${screenshots.path}'));
            });
      } else {
        return const SizedBox();
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          systemOverlayStyle: getSystemUiOverlayStyle(context),
          title: Text(getViewName(SpiceView.Settings)),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              StatefulBuilder(
                builder: (context, fullscreenState) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.aspect_ratio),
                    title: Text(S.current.fullscreen),
                    value: isFullScreen,
                    onChanged: (value) {
                      fullscreenToggle();
                      setState(() {});
                    },
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_high),
                title: Text(S.current.screen_always_on),
                value: Settings.alwaysOn,
                onChanged: (value) {
                  Settings.alwaysOn = value;
                  setState(() {});
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text(S.current.dark_mode),
                value: Settings.darkMode,
                onChanged: (value) {
                  Settings.darkMode = value;
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: Text(S.current.pure_black),
                value: Settings.blackMode,
                onChanged: (value) {
                  Settings.blackMode = value;
                  setState(() {});
                },
              ),
              const Divider(),
              getVibrationTile(),
              getOpenScreenshotsTile(),
              ListTile(
                title: Text(S.current.licenses),
                onTap: () {
                  // fix locale bug
                  final String locale = Intl.defaultLocale;
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LicensePage()))
                      .then((val) => Intl.defaultLocale = locale);
                },
              ),
              ListTile(
                title: Text(S.current.about),
                onTap: () async {
                  String about =
                      await rootBundle.loadString('assets/about.txt');
                  showModalBottomSheet(
                    context: context,
                    clipBehavior: Clip.antiAlias,
                    builder: (context) => SingleChildScrollView(
                      child: Column(children: [
                        AppBar(
                            systemOverlayStyle:
                                getSystemUiOverlayStyle(context),
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.transparent,
                            title: Text(S.current.about)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(about),
                        ),
                        const SizedBox(height: kBottomNavigationBarHeight + 16),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SliverPadding(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight)),
      ],
    );
  }
}
