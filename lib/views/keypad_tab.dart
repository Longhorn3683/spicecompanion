part of views;

enum KeypadKey {
  KeyBlank,
  Key00,
  Key0,
  Key1,
  Key2,
  Key3,
  Key4,
  Key5,
  Key6,
  Key7,
  Key8,
  Key9,
  KeyMode,
  KeyInsert,
  KeyNone
}

const _keyLookup = {
  KeypadKey.KeyBlank: 'D',
  KeypadKey.Key00: 'A',
  KeypadKey.Key0: '0',
  KeypadKey.Key1: '1',
  KeypadKey.Key2: '2',
  KeypadKey.Key3: '3',
  KeypadKey.Key4: '4',
  KeypadKey.Key5: '5',
  KeypadKey.Key6: '6',
  KeypadKey.Key7: '7',
  KeypadKey.Key8: '8',
  KeypadKey.Key9: '9',
  KeypadKey.KeyMode: '',
  KeypadKey.KeyInsert: '',
  KeypadKey.KeyNone: '',
};

class _KeypadButton extends StatelessWidget {
  final KeypadKey _key;
  final String _label;
  final Function(KeypadKey) _cb;
  final Color fontColor;
  final double fontSize;

  const _KeypadButton(this._key, this._label, this._cb,
      {this.fontColor, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          enableFeedback: true, // may want to make this an option?
          child: Center(
            child: Text(_label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize ?? 42.0, color: fontColor)),
          ),
          onTap: () {
            if (_cb != null) _cb(_key);
          }),
    );
  }
}

class KeypadTab extends StatefulWidget {
  const KeypadTab({Key key}) : super(key: key);

  @override
  _KeypadTabState createState() => _KeypadTabState();
}

class _KeypadTabState extends State<KeypadTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String keyBuffer = "";
  Future<void> keyBufferSend;
  int currentMode = 0;

  _KeypadTabState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getModeString() {
    switch (currentMode) {
      case 0:
        if (getPlayerCount(gameModel) <= 1) return "";
        return "P1";
      case 1:
        return "P2";
      default:
        return "??";
    }
  }

  int getModePlayer() {
    switch (currentMode) {
      case 0:
        return 0;
      case 1:
        return 1;
      default:
        return 0;
    }
  }

  Color getModeColor() {
    switch (currentMode) {
      case 0:
        return Colors.teal;
      case 1:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  void nextMode() {
    currentMode = (currentMode + 1) % 2;
    if (getPlayerCount(gameModel) <= 1) currentMode = 0;
    setState(() {});
  }

  void insertCard() async {
    // check if cards are loaded
    if (!cardListLoaded) await cardListLoad();

    // check if cards are defined
    if (cardList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 300,
        content: Text(S.current.add_cards_first),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ));
      return;
    }

    // check if we only have one card
    var card;
    if (cardList.length == 1) {
      // just use that one then
      card = cardList[0];
    } else if (cardList.any((i) => i.active)) {
      // use the active card
      card = cardList.firstWhere((i) => i.active);
    } else {
      // show card selection dialog
      card = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(S.current.card_select),
              children: cardList.map((CardInfo card) {
                return SimpleDialogOption(
                  child: Text("${card.name} (${card.id})"),
                  onPressed: () {
                    Navigator.pop(context, card);
                  },
                );
              }).toList(),
            );
          });
    }

    // check result
    if (card != null && card is CardInfo) {
      // move card to index 0 since we want the last used cards at the top
      cardList.remove(card);
      cardList.insert(0, card);
      cardListSave();

      // insert
      insertCardID(card.id);
    }
  }

  void insertCardID(String id) {
    // get connection
    ConnectionPool.inst.get().then((con) {
      // show info
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 300,
        content: Text("${S.current.card_inserting}: $id"),
        backgroundColor: getModeColor(),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ));

      // insert card
      cardInsert(con, getModePlayer(), id).whenComplete(() {
        con.free();
      });
    }, onError: (err) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 300,
        content: Text(S.current.connect_a_server),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ));
    });
  }

  void keyCallback(KeypadKey key) {
    // switch mode on blank key instead
    switch (key) {
      case KeypadKey.KeyMode:
        nextMode();
        return;
      case KeypadKey.KeyInsert:
        insertCard();
        return;
      case KeypadKey.KeyNone:
        return;
      default:
        break;
    }

    // check length
    if (keyBuffer.length < 8) keyBuffer += _keyLookup[key];

    // update
    if (keyBuffer.isNotEmpty) keyUpdate();
  }

  void keyUpdate() {
    keyBufferSend ??= ConnectionPool.inst.get().then((con) {
      keypadsWrite(con, getModePlayer(), keyBuffer).whenComplete(() {
        con.free();
        keyBufferSend = null;
        if (keyBuffer.isNotEmpty) keyUpdate();
      });
    }, onError: (e) {}).whenComplete(() {
      keyBuffer = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getSystemUiOverlayStyle(context),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(S.current.view_keypad),
        /*actions: [
          IconButton(
            icon: SizedBox(
              width: 24,
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: Text(
                    getModeString(),
                    style: TextStyle(color: getModeColor()),
                  ),
                ),
              ),
            ),
            onPressed: () => nextMode(),
          ),
          IconButton(
            tooltip: S.current.card_insert_keypad,
            icon: const Icon(Icons.credit_card),
            onPressed: () => insertCard(),
          ),
        ],*/
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: kBottomNavigationBarHeight + kFloatingActionButtonMargin),
          child: AspectRatio(
            aspectRatio: 12 / 19,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  children: [
                    _KeypadButton(KeypadKey.Key7, '7', keyCallback),
                    _KeypadButton(KeypadKey.Key8, '8', keyCallback),
                    _KeypadButton(KeypadKey.Key9, '9', keyCallback),
                    _KeypadButton(KeypadKey.Key4, '4', keyCallback),
                    _KeypadButton(KeypadKey.Key5, '5', keyCallback),
                    _KeypadButton(KeypadKey.Key6, '6', keyCallback),
                    _KeypadButton(KeypadKey.Key1, '1', keyCallback),
                    _KeypadButton(KeypadKey.Key2, '2', keyCallback),
                    _KeypadButton(KeypadKey.Key3, '3', keyCallback),
                    _KeypadButton(KeypadKey.Key0, '0', keyCallback),
                    _KeypadButton(KeypadKey.Key00, '00', keyCallback),
                    _KeypadButton(KeypadKey.KeyBlank, '.', keyCallback),
                  ],
                ),
                GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 2 / 1),
                  children: [
                    _KeypadButton(
                      KeypadKey.KeyMode,
                      getModeString(),
                      keyCallback,
                      fontSize: 28,
                      fontColor: getModeColor(),
                    ),
                    _KeypadButton(
                      KeypadKey.KeyInsert,
                      S.current.card_insert_keypad,
                      keyCallback,
                      fontSize: 28,
                      fontColor: Colors.deepOrange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
