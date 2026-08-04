part of views;

const cCards = 'cards'; // preferences key
List<CardInfo> cardList = new List<CardInfo>();
bool cardListLoaded = false;

Future<void> cardListSave() {
  if (cardList == null) return null;
  return preferencesSetStringList(
      cCards, cardList.map((card) => card.toJson()).toList());
}

Future<void> cardListLoad() async {
  var storedList = await preferencesGetStringList(cCards);
  if (storedList != null) {
    List<CardInfo> newList = List<CardInfo>();
    for (var json in storedList) {
      try {
        var card = CardInfo.fromJson(json);
        newList.add(card);
      } catch (e) {
        print("Couldn't parse CardInfo: $json");
      }
    }
    cardList = newList;
  } else {
    cardList = new List<CardInfo>();
  }
  cardListLoaded = true;
}

class CardInfo {
  String name = "-";
  String id = "0" * 16;
  String idTrigger = "";
  bool active = false;

  CardInfo({this.name, this.id, this.idTrigger});
  CardInfo.fromJson(String json) {
    Map obj = jsonDecode(json);
    name = obj["name"] ?? name;
    id = (obj["id"] ?? id).toUpperCase();
    idTrigger = (obj["idTrigger"] ?? idTrigger).toUpperCase();
    active = obj["active"] ?? active;
  }

  String toJson() {
    return jsonEncode({
      "name": name,
      "id": id.toUpperCase(),
      "idTrigger": idTrigger.toUpperCase(),
      "active": active,
    });
  }
}

class CardManagerView extends StatefulWidget {
  _CardManagerViewState createState() => _CardManagerViewState();
}

class _CardManagerViewState extends State<CardManagerView> {
  DateTime insertLast = DateTime.now();
  Duration insertGap = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    cardListLoad().then((v) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // build card list from `cardList`
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Text('Cards'),
          actions: <Widget>[
            // 'Add Card' Button
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CardEditView(
                      onSave: (CardInfo card) {
                        setState(() => cardList.add(card));
                        cardListSave();
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate(cardList.map((CardInfo card) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 16, right: 8),
                  title: Text(
                    card.name + (card.active ? " (Active)" : ""),
                    style: TextStyle(color: card.active ? Colors.green : null),
                  ),
                  subtitle: Text(card.id),
                  trailing: MenuAnchor(
                    builder: (
                      BuildContext context,
                      MenuController controller,
                      Widget child,
                    ) {
                      return IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          // ask which player if multiple readers are present
                          if (getPlayerCount(gameModel) <= 1) {
                            // check if enough time has passed since last insert
                            var now = DateTime.now();
                            if (now.difference(insertLast) > insertGap) {
                              insertLast = now;
                              _insertCard(0, card.id);
                            }
                          } else {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          }
                        },
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: Icon(Icons.send),
                        child: Text('Insert to P1'),
                        onPressed: () => _insertCard(0, card.id),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.send),
                        child: Text('Insert to P2'),
                        onPressed: () => _insertCard(1, card.id),
                      ),
                      Divider(),
                      MenuItemButton(
                          leadingIcon: Icon(Icons.edit),
                          child: Text('Edit \'${card.name}\''),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CardEditView(
                                  baseDetails: card,
                                  onSave: (CardInfo newCard) {
                                    setState(() {
                                      card.name = newCard.name;
                                      card.id = newCard.id;
                                      card.idTrigger = newCard.idTrigger;
                                    });
                                    cardListSave();
                                  },
                                );
                              },
                            );
                          }),
                      MenuItemButton(
                        leadingIcon: Icon(card.active
                            ? Icons.indeterminate_check_box
                            : Icons.check_box),
                        child: Text(card.active
                            ? "Remove active status"
                            : "Set to active card"),
                        onPressed: () {
                          setState(() {
                            if (!card.active) {
                              for (var i in cardList) i.active = false;
                              card.active = true;
                            } else
                              card.active = false;
                          });
                          cardListSave();
                        },
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.delete),
                        child: Text('Remove'),
                        onPressed: () {
                          setState(() => cardList.remove(card));
                          cardListSave();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList()),
          ),
        ),
      ],
    );
  }

  void _insertCard(int unit, String cardID) {
    ConnectionPool.inst.get().then((con) {
      // show info
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserting Card: $cardID"),
        backgroundColor: Colors.deepOrange,
        duration: insertGap,
      ));

      // insert card
      cardInsert(con, unit, cardID).whenComplete(() {
        con.free();
      });
    }, onError: (err) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please connect to a server first."),
        backgroundColor: Colors.deepOrange,
        duration: insertGap,
      ));
    });
  }
}

class CardEditView extends StatefulWidget {
  final void Function(CardInfo) onSave;

  // If none provided, the UI will say 'Add' not 'Edit'/'Save'
  final CardInfo baseDetails;

  CardEditView({@required this.onSave, this.baseDetails});

  @override
  _CardEditViewState createState() => _CardEditViewState();
}

class _CardEditViewState extends State<CardEditView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  AutovalidateMode _autoValidateFields = AutovalidateMode.disabled;
  CardInfo _data;
  StreamSubscription<String> cardSubscription;
  TextEditingController cardIDController = TextEditingController();
  TextEditingController pubIDController = TextEditingController();

  _CardEditViewState() {
    cardIDController.addListener(() {
      if (cardIDController.text.length == 16) {
        try {
          pubIDController.text = CardCipher.encode(cardIDController.text);
        } on Exception {}
      }
    });
    pubIDController.addListener(() {
      var text = pubIDController.text;
      if (text != null && text.length == 16) {
        if (validatePublicID(text) == null) {
          var cardID = CardCipher.decode(text);
          var cardText = cardIDController.text;
          if (cardText != cardID) cardIDController.text = cardID;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.baseDetails == null) {
      _data = CardInfo();
    } else {
      _data = CardInfo(
        name: widget.baseDetails.name,
        id: widget.baseDetails.id,
        idTrigger: widget.baseDetails.idTrigger,
      );
    }

    // subscribe to tag input
    cardIDController.text = _data.id;
    this.cardSubscription = TagManager.inst.tagStream.stream.listen((id) {
      cardIDController.text = id;
    });
  }

  @override
  void dispose() {
    if (this.cardSubscription != null) this.cardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.baseDetails == null ? 'Add Card' : 'Edit Card'),
      content: Form(
        key: _formState,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                //leading: Icon(Icons.account_circle),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.name,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Main Card",
                  ),
                  onSaved: (String s) => _data.name = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.credit_card),
                title: TextFormField(
                  controller: cardIDController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Card ID",
                    hintText: "E0040123456789AB",
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (String s) => _data.id = s.toUpperCase(),
                  validator: validateCard,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.public),
                title: TextFormField(
                  controller: pubIDController,
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: "Public ID", hintText: "optional"),
                  keyboardType: TextInputType.text,
                  validator: validatePublicID,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.nfc),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.idTrigger,
                  decoration: InputDecoration(
                    labelText: "Insert when scanning ID",
                    hintText: "E004... (optional)",
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (String s) => _data.idTrigger = s.toUpperCase(),
                ),
              ),
              /*ListTile(
                title: Text(""),
                subtitle: Text("Tip: Tap your card to the back of your phone."),
              ),*/
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(widget.baseDetails == null ? 'Add' : 'Save'),
          onPressed: () {
            if (_formState.currentState.validate()) {
              _formState.currentState.save();
              widget.onSave(_data);
              Navigator.of(context).pop();
            } else {
              setState(() {
                // upon trying to add/write invalid data,
                // it'll be validated every time the fields change
                // until you save it.
                _autoValidateFields = AutovalidateMode.always;
              });
            }
          },
        ),
      ],
    );
  }

  String validateBasic(String s) {
    if (s.length == 0) return "Can't be empty!";
    return null;
  }

  String validateCard(String cardID) {
    if (cardID.length != 16) return "Must be 16 characters!";
    if (!RegExp(r"^[a-fA-F0-9]+$").hasMatch(cardID))
      return "Contains invalid characters!";
    return null;
  }

  String validatePublicID(String pubID) {
    if (pubID.length == 0) return null;
    if (pubID.length != 16) return "Must be empty or of length 16!";
    String allowedChars = "0123456789ABCDEFGHJKLMNPRSTUWXYZ";
    for (int i = 0; i < pubID.length; i++) {
      if (!allowedChars.contains(pubID[i]))
        return "Contains invalid characters!";
    }
    try {
      String decoded = CardCipher.decode(pubID);
      if (decoded != null && decoded.length == 16) return null;
    } on Exception {
    } on Error {}
    return "Unable to parse ID!";
  }
}
