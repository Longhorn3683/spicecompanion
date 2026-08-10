part of views;

class InfoView extends StatefulWidget {
  const InfoView({Key key}) : super(key: key);

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  Timer updateTimer;
  bool updateLock = false;

  final String _disconnectMsg = S.current.disconnected;
  String _avsModel = '';
  String _avsDest = '';
  String _avsSpec = '';
  String _avsRev = '';
  String _avsExt = '';
  String _avsTitle = '';
  String _avsServices = '';

  String _launcherVersion = '';
  String _launcherCompileDate;
  String _launcherCompileTime;
  DateTime _launcherSystemTime;
  List<String> _launcherArgs = [];

  num _memTotal = 1;
  num _memTotalUsed = 0;
  num _memUsed = 0;
  num _vmemTotal = 1;
  num _vmemTotalUsed = 0;
  num _vmemUsed = 0;

  int currentMode = 0;

  StreamSubscription<String> cardSubscription;

  _InfoViewState() {
    if (updateTimer != null) updateTimer.cancel();
    updateTimer = Timer.periodic(
        const Duration(
          seconds: 1,
        ),
        infoTimerTick);

    // call it immediately for first update
    infoTimerTick(null);
  }

  @override
  void initState() {
    super.initState();

    cardSubscription = TagManager.inst.tagStream.stream.listen((id) {
      insertCardID(id);
    });
  }

  @override
  void dispose() {
    if (updateTimer != null) updateTimer.cancel();
    if (cardSubscription != null) cardSubscription.cancel();
    super.dispose();
  }

  void infoTimerTick(Timer _) {
    if (updateLock) return;
    updateLock = true;
    ConnectionPool.inst.get().then((con) {
      Map respAVS, respLauncher;

      return infoAVS(con).then((avs) {
        respAVS = avs;
        return infoLauncher(con);
      }).then((launcher) {
        respLauncher = launcher;
        return infoMemory(con);
      }).then((memory) {
        if (mounted) {
          //var tDiff = lastPing.inMilliseconds;
          setState(() {
            //_gameName = "$gameModel:$gameDest:$gameSpec:$gameRev:$gameExt";
            //_gameServer = "${con.host}:${con.port}@${tDiff}ms";
            _avsModel = respAVS['model'] ?? "";
            _avsDest = respAVS['dest'] ?? "";
            _avsSpec = respAVS['spec'] ?? "";
            _avsRev = respAVS['rev'] ?? "";
            _avsExt = respAVS['ext'] ?? "";
            _avsTitle =
                '${respAVS['model']}:${respAVS['dest']}:${respAVS['spec']}:${respAVS['rev']}:${respAVS['ext']}' ??
                    "";
            _avsServices = respAVS['services'] ?? "";

            _launcherVersion = respLauncher['version'] ?? "";
            _launcherCompileDate = respLauncher['compile_date'] ?? "";
            _launcherCompileTime = respLauncher['compile_time'] ?? "";
            try {
              _launcherSystemTime =
                  DateTime.parse((respLauncher['system_time'] ?? "") as String);
            } on FormatException {
              _launcherSystemTime = null;
            }
            if (respLauncher['args'] != null) {
              _launcherArgs = (respLauncher['args'] as List).cast<String>();
            } else {
              _launcherArgs = [""];
            }

            _memTotal = memory['mem_total'] ?? 1;
            _memTotalUsed = memory['mem_total_used'] ?? 0;
            _memUsed = memory['mem_used'] ?? 0;
            _vmemTotal = memory['vmem_total'] ?? 1;
            _vmemTotalUsed = memory['vmem_total_used'] ?? 0;
            _vmemUsed = memory['vmem_used'] ?? 0;
          });
        }
      }).whenComplete(() {
        con.free();
      });
    }).catchError((e) {
      setState(() {
        _avsModel = _disconnectMsg;
        _avsDest = _disconnectMsg;
        _avsSpec = _disconnectMsg;
        _avsRev = _disconnectMsg;
        _avsExt = _disconnectMsg;
        _avsTitle = _disconnectMsg;
        _avsServices = _disconnectMsg;
        _launcherVersion = _disconnectMsg;
        _launcherCompileDate = null;
        _launcherCompileTime = null;
        _launcherSystemTime = null;
        _launcherArgs = [""];
        _memTotal = 1;
        _memTotalUsed = 0;
        _memUsed = 0;
        _vmemTotal = 1;
        _vmemTotalUsed = 0;
        _vmemUsed = 0;
      });
    }).whenComplete(() {
      updateLock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        systemOverlayStyle: getSystemUiOverlayStyle(context),
        actions: [
          IconButton(
            tooltip: S.current.screenshot,
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              var dir = await getApplicationDocumentsDirectory();
              String name =
                  'SpiceCapture_${DateTime.now().toString().replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '').replaceAll('.', '')}';
              var screenshots = Directory('${dir.path}/Spice L3');
              if (!screenshots.existsSync()) {
                await screenshots.create();
              }
              var file = File("${screenshots.path}/$name.jpg");

              ConnectionPool.inst.get().then((con) {
                captureGetJPG(con, screen: 0, divide: 1, quality: 100)
                    .then((capture) async {
                  await file.writeAsBytes(capture.data.toList(growable: false),
                      flush: true);
                  await Navigator.push(
                      context,
                      DialogRoute(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) =>
                              PhotoViewPage(name, file.path)));
                }).whenComplete(() {
                  if (Platform.isAndroid ||
                      Platform.isIOS ||
                      defaultTargetPlatform == TargetPlatform.ohos) {
                    file.deleteSync();
                  }
                  con.free();
                });
              }, onError: (err) {
                // show error
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  width: 300,
                  content: Text(S.current.connect_a_server),
                  backgroundColor: Colors.red,
                  showCloseIcon: true,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ));
              });
            },
          ),
          MenuAnchor(
            builder: (
              BuildContext context,
              MenuController controller,
              Widget child,
            ) {
              return IconButton(
                tooltip: S.current.insert_coin,
                icon: const Icon(Icons.monetization_on),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                child: Text(S.current.insert_coin_1),
                onPressed: () => ConnectionPool.inst.get().then((con) {
                  coinInsert(con, 1).whenComplete(() {
                    con.free();
                  });
                }, onError: (e) {}),
              ),
              MenuItemButton(
                child: Text(S.current.insert_coin_5),
                onPressed: () => ConnectionPool.inst.get().then((con) {
                  coinInsert(con, 5).whenComplete(() {
                    con.free();
                  });
                }, onError: (e) {}),
              ),
              MenuItemButton(
                child: Text(S.current.insert_coin_10),
                onPressed: () => ConnectionPool.inst.get().then((con) {
                  coinInsert(con, 10).whenComplete(() {
                    con.free();
                  });
                }, onError: (e) {}),
              ),
            ],
          ),
          MenuAnchor(
            builder: (
              BuildContext context,
              MenuController controller,
              Widget child,
            ) {
              return IconButton(
                tooltip: S.current.game_menu,
                icon: const Icon(Icons.power_settings_new),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.restart_alt),
                child: Text(S.current.restart_game),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(S.current.restart_game_prompt),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                            child: Text(S.current.ok),
                            onPressed: () {
                              ConnectionPool.inst.get().then((con) {
                                controlRestart(con)
                                    .catchError((e) {})
                                    .whenComplete(() => con.free());
                              }, onError: (e) {});
                              Navigator.pop(context);
                            }),
                      ],
                    );
                  },
                ),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.close),
                child: Text(S.current.quit_game),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(S.current.quit_game_prompt),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text(S.current.ok),
                          onPressed: () {
                            ConnectionPool.inst.get().then((con) {
                              controlExit(con, 0)
                                  .catchError((e) {})
                                  .whenComplete(() => con.free());
                            }, onError: (e) {});
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              MenuItemButton(
                leadingIcon: const Icon(Icons.restart_alt),
                child: Text(S.current.restart),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(S.current.restart_prompt),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                            child: Text(S.current.ok),
                            onPressed: () {
                              ConnectionPool.inst.get().then((con) {
                                controlReboot(con)
                                    .catchError((e) {})
                                    .whenComplete(() => con.free());
                              }, onError: (e) {});
                              Navigator.pop(context);
                            }),
                      ],
                    );
                  },
                ),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.power_settings_new),
                child: Text(S.current.shutdown),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(S.current.shutdown_prompt),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                            child: Text(S.current.ok),
                            onPressed: () {
                              ConnectionPool.inst.get().then((con) {
                                controlShutdown(con)
                                    .catchError((e) {})
                                    .whenComplete(() => con.free());
                              }, onError: (e) {});
                              Navigator.pop(context);
                            }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        pinned: true,
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        StatefulBuilder(
                          builder: (context, cardState) {
                            //cardRefresh = () => cardState(() {});

                            void nextMode() {
                              currentMode = (currentMode + 1) % 2;
                              if (getPlayerCount(gameModel) <= 1) {
                                currentMode = 0;
                              }
                              cardState(() {});
                            }

                            return Theme(
                              data: spiceThemes[SpiceTheme.Dark],
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                ),
                                color: getModeColor(),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    trailing: IconButton(
                                      icon: AspectRatio(
                                        aspectRatio: 1,
                                        child: Center(
                                          child: Text(
                                            'P${currentMode + 1}',
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        nextMode();
                                      },
                                    ),
                                    title: Text(S.current.insert_card,
                                        style: const TextStyle(fontSize: 24)),
                                    onTap: () async {
                                      // check if cards are loaded
                                      if (!cardListLoaded) await cardListLoad();

                                      // check if cards are defined
                                      if (cardList.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          width: 300,
                                          content:
                                              Text(S.current.add_cards_first),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ));
                                        return;
                                      }

                                      // check if we only have one card
                                      var card;
                                      if (cardList.length == 1) {
                                        // just use that one then
                                        card = cardList[0];
                                      } else if (cardList
                                          .any((i) => i.active)) {
                                        // use the active card
                                        card = cardList
                                            .firstWhere((i) => i.active);
                                      } else {
                                        // show card selection dialog
                                        card = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return SimpleDialog(
                                                clipBehavior: Clip.antiAlias,
                                                title:
                                                    Text(S.current.card_select),
                                                children: cardList
                                                    .map((CardInfo card) {
                                                  return SimpleDialogOption(
                                                    child: Text(
                                                        "${card.name} (${card.id})"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, card);
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
                                    }),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        // AVS
                        Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(_gameServer),
                            subtitle: Text('$_avsTitle\n$_avsServices'),
                            onTap: () => showModalBottomSheet(
                                context: context,
                                clipBehavior: Clip.antiAlias,
                                builder: (context) => const ServerView()),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Memory Usage
                        Row(
                          children: [
                            Expanded(
                              child: _createMemoryDisplay('RAM', _memUsed,
                                  _memTotalUsed, _memTotal, context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _createMemoryDisplay('Swap', _vmemUsed,
                                  _vmemTotalUsed, _vmemTotal, context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        // Launcher Info
                        _createCard('spice2x',
                            '$_launcherVersion\n${_launcherCompileDate != null ? _getDateTimeFromGCC(_launcherCompileDate, _launcherCompileTime) : _disconnectMsg}'),

                        const SizedBox(height: 4),

                        _createCard(
                            S.current.system_time,
                            _launcherSystemTime != null
                                ? _formatSystemTime(
                                    _launcherSystemTime.toLocal())
                                : _disconnectMsg),

                        const SizedBox(height: 4),

                        Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text(
                                    '${S.current.launch_args} (${_launcherArgs.length - 1})'),
                              ),
                              ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _getArgList(_launcherArgs),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kBottomNavigationBarHeight),
            ],
          ),
        ),
      )
    ]);
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
      cardInsert(con, currentMode, id).whenComplete(() {
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
}

String _formatSystemTime(DateTime date) =>
    '${DateFormat('hh:mm:ssa').format(date)} on ${DateFormat.yMMMMd().format(date)}';

// guaranteed format, see: https://gcc.gnu.org/onlinedocs/cpp/Standard-Predefined-Macros.html
String _getDateTimeFromGCC(String date, String time) {
  var tmp = date.replaceAll('  ', ' ').split(' ');
  if (tmp.length < 3) return "";
  return '${tmp[2]} ${tmp[0]} ${tmp[1]} at $time';
}

// currently skips arg0 and provides a description for the rest from ./info_args (and a default for arg1)
// title is the argument followed by any additional associated parameters, subtitle is the description
List<Widget> _getArgList(List<String> args) {
  List<Widget> list = [];
  for (int i = 1; i < args.length; i++) {
    String option = args[i], desc = '';
    bool skipNext = false;

    if (info2PartArgsLookup.contains(args[i])) {
      option += ' ${args[i + 1]}';
      skipNext = true;
    }

    if (infoArgsLookup.containsKey(args[i])) {
      desc = infoArgsLookup[args[i]];
    } else {
      if (args[i].startsWith('-')) {
        desc = 'Unknown Argument ${args[i]}';
      } else {
        desc = 'Game Binary';
      }
    }

    list.add(
      ListTile(
        title: Text(option),
        subtitle: Text(desc),
      ),
    );
    if (skipNext) i++;
  }
  return list;
}

Widget _createCard(String title, String desc) {
  return Card(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(24),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(title),
      subtitle: Text(desc),
    ),
  );
}

// converts a bytecount to mebi and gibibytes (because multiples of 2 are 2 hard apparently)
String _getMiB(num bytes) => (bytes * 9.53674e-7).toStringAsFixed(2);
String _getGiB(num bytes) => (bytes * 9.31323e-10).toStringAsFixed(2);

Widget _createMemoryDisplay(String name, num used, num usedOutOfTotal,
    num total, BuildContext context) {
  return Card(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(24),
      ),
    ),
    child: Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.25),
                    value: usedOutOfTotal / total,
                    strokeWidth: 8,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${(usedOutOfTotal / total * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 36)),
                      Text(name),
                    ],
                  )
                ],
              )),
        ),
        Text('${S.current.memory_game} ${_getMiB(used)}MiB',
            style: const TextStyle(fontSize: 14, color: Colors.lightGreen)),
        Text('${S.current.memory_used} ${_getGiB(usedOutOfTotal)}GiB',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            )),
        Text('${S.current.memory_total} ${_getGiB(total)}GiB',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            )),
        const SizedBox(
          height: 16,
        )
      ],
    ),
  );
}
