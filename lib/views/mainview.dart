part of views;

// game state
String gameModel = "";
String gameDest = "";
String gameSpec = "";
String gameRev = "";
String gameExt = "";
String _gameName = "";
String _gameServer = "";
Duration lastPing = Duration(seconds: 1);

bool toolbarHidden = false;

enum SpiceTheme { Light, Dark }

final spiceThemes = {
  SpiceTheme.Light: ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
  ),
  SpiceTheme.Dark: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
  )
};
SpiceTheme currentTheme;

class MainView extends StatefulWidget {
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  SpiceView _currentView;
  Widget _viewWidget;

  static Timer _gameTimer;
  static bool _gameTickActive = false;

  _MainViewState() {
    _setView(defaultSpiceView);
    _gameTimerReset();

    // subscribe to pool changes for quick info refresh
    ConnectionPool.inst.changes.stream.listen((pool) {
      _gameTimerTick(null);
    });
  }

  void _gameTimerReset() {
    // cancel old
    if (_gameTimer != null) _gameTimer.cancel();

    // create new timer
    _gameTimer = Timer.periodic(
        Duration(
          seconds: 1,
        ),
        _gameTimerTick);

    // instant tick
    _gameTimerTick(null);
  }

  void _gameTimerTick(Timer _) {
    // ignore if currently processing
    if (_gameTickActive) return;

    // query
    ConnectionPool.inst.get().then((con) {
      // lock
      if (_gameTickActive) return;
      _gameTickActive = true;

      var t1 = DateTime.now();
      infoAVS(con).then((avs) {
        var t2 = DateTime.now();
        lastPing = t2.difference(t1);
        var tDiff = lastPing.inMilliseconds;
        setState(() {
          // get info
          gameModel = avs["model"];
          gameDest = avs["dest"];
          gameSpec = avs["spec"];
          gameRev = avs["rev"];
          gameExt = avs["ext"];

          // set info
          _gameName = "$gameModel:$gameDest:$gameSpec:$gameRev:$gameExt";
          _gameServer = "${con.host}:${con.port}@${tDiff}ms";
        });
      }).whenComplete(() {
        con.free();
      });
    }).whenComplete(() {
      // unlock
      _gameTickActive = false;
    }).catchError((e) {
      // reset info
      gameModel = "";
      gameDest = "";
      gameSpec = "";
      gameRev = "";
      gameExt = "";

      // set title
      setState(() {
        _gameName = S.current.disconnected;
        _gameServer = S.current.connect_a_server;
      });
    });
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateTitle: (context) => 'Spice L3',
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: spiceThemes[currentTheme],
        home:
            StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Scaffold(
            body: _viewWidget,
            drawer: NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                selectedIndex = index;
                setState(() {
                  _setView(SpiceView.values[index]);
                  Navigator.of(context).pop();
                });
              },
              children: <Widget>[
                ListTile(
                  title: Text(_gameServer),
                  subtitle: Text(_gameName),
                  onTap: () => showModalBottomSheet(
                      context: context,
                      clipBehavior: Clip.antiAlias,
                      builder: (context) => ServerView()),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.info),
                  label: Text(getViewName(SpiceView.Info)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.credit_card),
                  label: Text(getViewName(SpiceView.CardManager)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.dialpad),
                  label: Text(getViewName(SpiceView.Keypad)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.memory),
                  label: Text(getViewName(SpiceView.Patches)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.cast),
                  label: Text(getViewName(SpiceView.Screen)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.gamepad),
                  label: Text(getViewName(SpiceView.Controller)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.keyboard),
                  label: Text(getViewName(SpiceView.Buttons)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.threesixty),
                  label: Text(getViewName(SpiceView.Analogs)),
                ),
                SizedBox(height: 2),
                NavigationDrawerDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text(getViewName(SpiceView.Lights)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.settings),
                  label: Text(getViewName(SpiceView.Settings)),
                ),
                SizedBox(height: 2 + kBottomNavigationBarHeight),
              ],
            ),
          );
        }));
  }

  void _setView(SpiceView view) {
    if (_currentView == view) return;
    _currentView = view;
    _viewWidget = getView(_currentView);
  }
}

SystemUiOverlayStyle getSystemUiOverlayStyle(BuildContext context) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        isDarkMode(context) ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness:
        isDarkMode(context) ? Brightness.light : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return true;
  } else {
    return false;
  }
}
