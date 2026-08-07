part of views;

class ButtonsView extends StatefulWidget {
  @override
  _ButtonsViewState createState() => _ButtonsViewState();
}

class _ButtonsViewState extends State<ButtonsView> {
  List<ButtonState> _buttonStates = [];
  Timer refreshTimer;
  int updateCount = 0;
  bool locked = false;

  @override
  void initState() {
    super.initState();
    if (!locked) freeList();
    update();
  }

  @override
  void dispose() {
    if (refreshTimer != null) refreshTimer.cancel();
    if (!locked) freeList();
    super.dispose();
  }

  Future<void> writeSingle(ButtonState state) async {
    return ConnectionPool.inst.get().then((con) {
      return buttonsWrite(con, [state]).whenComplete(() {
        locked = true;
        state.active = true;
        con.free();
      });
    }, onError: (e) {});
  }

  Future<void> writeList() async {
    return ConnectionPool.inst.get().then((con) {
      if (_buttonStates == null || _buttonStates.length == 0) return null;
      return buttonsWrite(con, _buttonStates).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  Future<void> freeList() async {
    return ConnectionPool.inst.get().then((con) {
      buttonsWriteReset(con, []).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  void update() {
    // update timer
    if (refreshTimer == null || refreshTimer.tick >= 64) {
      if (refreshTimer != null) refreshTimer.cancel();
      refreshTimer = Timer.periodic(
          Duration(milliseconds: max(128, lastPing.inMilliseconds)),
          (timer) => update());
    }

    // update buttons
    if (updateCount < 2) {
      updateCount++;
      ConnectionPool.inst.get().then((con) {
        buttonsRead(con).then((stateList) {
          // check lock
          for (var state in _buttonStates) {
            if (state.active) {
              locked = true;
              break;
            }
          }

          // apply new list
          _buttonStates = stateList;
          try {
            setState(() {});
          } on Error {}
        }).whenComplete(() => con.free());
      }, onError: (e) {
        // clear list on disconnect
        _buttonStates = [];
      }).whenComplete(() => updateCount--);
    }
  }

  @override
  Widget build(BuildContext context) {
    // empty view
    if (_buttonStates.length == 0)
      return CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            systemOverlayStyle: getSystemUiOverlayStyle(context),
            title: Text(getViewName(SpiceView.Buttons)),
          ),
          SliverFillRemaining(
            child: Center(
              child: Text(S.current.no_buttons),
            ),
          ),
        ],
      );

    // list view
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          systemOverlayStyle: getSystemUiOverlayStyle(context),
          title: Text(getViewName(SpiceView.Buttons)),
          actions: <Widget>[
            IconButton(
              icon: Icon(locked ? Icons.lock : Icons.lock_open),
              onPressed: () {
                if (locked) {
                  locked = false;
                  freeList();
                } else {
                  locked = true;
                  writeList();
                }
                setState(() {});
              },
              color: locked ? Colors.red : null,
            ),
          ],
        ),
        SliverList(
            delegate: SliverChildListDelegate(
          _buttonStates.map((button) {
            // desc
            var desc = button.state.toString();
            if (button.state == 0)
              desc = "Not Pressed";
            else if (button.state == 1) desc = "Pressed";

            // desc color
            var descColor = Colors.red;
            if (button.state >= 0.5) descColor = Colors.green;

            // title color
            var titleColor = button.active ? Colors.orange : null;

            return ListTile(
              title: Text(button.name, style: TextStyle(color: titleColor)),
              subtitle: Text(desc, style: TextStyle(color: descColor)),
              onTap: () async {
                if (button.state >= 0.5)
                  button.state = 0;
                else
                  button.state = 1;
                await writeSingle(button);
                setState(() {});
              },
            );
          }).toList(),
        )),
        SliverPadding(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight)),
      ],
    );
  }
}
