part of views;

// game state
String gameModel = "";
String gameDest = "";
String gameSpec = "";
String gameRev = "";
String gameExt = "";
Duration lastPing = Duration(seconds: 1);

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

  String _gameName = "";
  String _gameServer = "";
  Widget _gameAvatar;
  static Timer _gameTimer;
  static bool _gameTickActive = false;
  static bool toolbarHidden = false;

  _MainViewState() {
    _setView(defaultSpiceView);
    _gameTimerReset();
    _gameAvatar = Image.asset("assets/spice.png");

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
        _gameName = "Disconnected";
        _gameServer = "Please connect to a server.";
        _gameAvatar = Image.asset("assets/spice.png");
      });
    });
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: spiceThemes[currentTheme],
        home:
            StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Scaffold(
            body: Listener(
              onPointerDown: (p) {
                if (toolbarHidden && p.position.dy < 16) {
                  setState(() {
                    toolbarHidden = false;
                  });
                }
              },
              child: _viewWidget,
            ),
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
                /*UserAccountsDrawerHeader(
                    accountName: Text(_gameName),
                    accountEmail: Text(_gameServer),
                    //currentAccountPicture: _gameAvatar,
                  ),*/
                NavigationDrawerDestination(
                  icon: Icon(Icons.info),
                  label: Text(getViewName(SpiceView.Info)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.credit_card),
                  label: Text(getViewName(SpiceView.CardManager)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.dialpad),
                  label: Text(getViewName(SpiceView.Keypad)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.memory),
                  label: Text(getViewName(SpiceView.Patches)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.cast),
                  label: Text(getViewName(SpiceView.Screen)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.gamepad),
                  label: Text(getViewName(SpiceView.Controller)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.keyboard),
                  label: Text(getViewName(SpiceView.Buttons)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.threesixty),
                  label: Text(getViewName(SpiceView.Analogs)),
                ),
                NavigationDrawerDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text(getViewName(SpiceView.Lights)),
                ),
                Divider(),
                NavigationDrawerDestination(
                  icon: Icon(Icons.settings),
                  label: Text(getViewName(SpiceView.Settings)),
                ),
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
