part of views;

class Settings {
  static const preferencesKey = "settings";

  static bool _darkMode;
  static get darkMode {
    return _darkMode;
  }

  static set darkMode(bool value) {
    if (_darkMode == value) return;
    switch (value) {
      case false:
        currentTheme = SpiceTheme.Light;
        break;
      case true:
        currentTheme = SpiceTheme.Dark;
        break;
    }
    _darkMode = value;
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
      if (json != null && json.length > 0) {
        // decode json
        var map = jsonDecode(json);
        darkMode = map["darkMode"] ?? darkMode;
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
  }
}

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text('Settings'),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SwitchListTile(
            secondary: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            value: Settings.darkMode,
            onChanged: (value) {
              Settings.darkMode = value;
              setState(() {});
            },
          ),
          Divider(),
          /*ListTile(
            title: Text("Button Vibration Duration: " +
                Settings.buttonVibrationDuration.toInt().toString() +
                "ms"),
            subtitle: Slider(
              value: Settings.buttonVibrationDuration,
              min: 0,
              max: 200,
              onChanged: (value) {
                Settings.buttonVibrationDuration = value;
                Settings.save();
                //Vibration.vibrate(duration: Settings.buttonVibrationDuration.toInt());
                setState(() {});
              },
            ),
          ),*/
          ListTile(
            title: Text("Screen Quality: " +
                Settings.screenQuality.toInt().toString() +
                "%"),
            subtitle: Slider(
              value: Settings.screenQuality,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                print(
                    "Settings: screen quality changed to " + value.toString());
                Settings.screenQuality = value;
                Settings.save();
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: Text(
                "Screen Threads: " + Settings.screenThreads.toInt().toString()),
            subtitle: Slider(
              value: Settings.screenThreads,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                Settings.screenThreads = value;
                Settings.save();
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: Text(
                "Screen Divide: " + Settings.screenDivide.toInt().toString()),
            subtitle: Slider(
              value: Settings.screenDivide,
              min: 1,
              max: 16,
              divisions: 15,
              onChanged: (value) {
                Settings.screenDivide = value;
                Settings.save();
                setState(() {});
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Licenses"),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          ListTile(
            title: Text("About"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AboutView()),
              );
            },
          ),
        ]))
      ],
    );
  }
}

class AboutView extends StatefulWidget {
  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  String content = "";

  @override
  void initState() {
    super.initState();

    // load file
    rootBundle.loadString("assets/about.txt").then((file) {
      content = file;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(fontSize: 23),
          ),
        ),
      ),
    );
  }
}
