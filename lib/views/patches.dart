part of views;

class PatchCache {
  Patch patch;
  PatchState state;
  PatchCache(this.patch, this.state);
}

class PatchesView extends StatefulWidget {
  @override
  _PatchesViewState createState() => _PatchesViewState();
}

class _PatchesViewState extends State<PatchesView> {
  var subViews = [
    PatchesSubView(setting: _PatchesSubViewSetting.Preset),
    PatchesSubView(setting: _PatchesSubViewSetting.Online),
    PatchesSubView(setting: _PatchesSubViewSetting.Custom),
  ];

  var titles = [
    S.current.patch_preset,
    S.current.patch_online,
    S.current.patch_custom
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: subViews.length,
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: getSystemUiOverlayStyle(context),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: Text(getViewName(SpiceView.Patches)),
            bottom: TabBar(
              tabs: subViews.map((PatchesSubView subView) {
                return Tab(
                  text: titles[subView.setting.index],
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: subViews,
          ),
        ));
  }
}

class PatchesSubView extends StatefulWidget {
  final _PatchesSubViewSetting setting;
  PatchesSubView({this.setting});

  @override
  _PatchesSubViewState createState() =>
      _PatchesSubViewState(setting: this.setting);
}

enum _PatchesSubViewSetting { Preset, Online, Custom }

class _PatchesSubViewState extends State<PatchesSubView> {
  // keys
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  // state
  _PatchesSubViewSetting setting;
  List<PatchCache> patchList = [];

  _PatchesSubViewState({this.setting});

  Future<void> update() async {
    return ConnectionPool.inst.get().then((con) {
      infoAVS(con).then((avs) async {
        // get info
        var gameCode = avs["model"];
        var dateCode = int.parse(avs["ext"]);

        // get patches
        List<Patch> patches = [];
        switch (this.setting) {
          case _PatchesSubViewSetting.Preset:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (patch.preset) patches.add(patch);
            break;
          case _PatchesSubViewSetting.Online:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (patch.online) patches.add(patch);
            break;
          case _PatchesSubViewSetting.Custom:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (!patch.preset) patches.add(patch);
            break;
        }

        // add patches to cache
        List<PatchCache> newList = [];
        for (var patch in patches) {
          newList.add(PatchCache(patch, await patch.getState(con)));
        }
        this.patchList = newList;

        // update state
        if (mounted) setState(() {});
      }).whenComplete(() => con.free());
    }, onError: (e) {
      this.patchList = [];
    });
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {
    // action button
    FloatingActionButton actionButton;
    switch (this.setting) {
      case _PatchesSubViewSetting.Preset:
        break;
      case _PatchesSubViewSetting.Online:
        actionButton = FloatingActionButton(
          heroTag: "online",
          child: Icon(Icons.settings),
          onPressed: () async {
            _showAddOnlineDialog();
          },
        );
        break;
      case _PatchesSubViewSetting.Custom:
        actionButton = FloatingActionButton(
          heroTag: "custom",
          child: Icon(Icons.settings),
          onPressed: () async {
            _showAddCustomDialog();
          },
        );
        break;
    }

    // check patches
    if (!ConnectionPool.inst.hasConnection() || patchList.length == 0) {
      var error = S.current.connect_a_server;
      if (ConnectionPool.inst.hasConnection()) error = S.current.no_patch_known;
      return Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: update,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(error),
              ),
            ],
          ),
        ),
        floatingActionButton: actionButton,
      );
    }

    // patch list
    return Scaffold(
      floatingActionButton: actionButton,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: update,
        child: ListView(
            children: patchList.map((PatchCache cache) {
          // decide on title and color
          String title;
          Color color;
          switch (cache.state) {
            case PatchState.Unknown:
              title = cache.patch.name;
              color = Colors.grey;
              break;
            case PatchState.Enabled:
              title = "${cache.patch.name} (${S.current.enabled})";
              color = Colors.green;
              break;
            case PatchState.Disabled:
              title = "${cache.patch.name} (${S.current.disabled})";
              color = Colors.red;
              break;
          }

          // build item
          return ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: color,
              ),
            ),
            subtitle: Text(cache.patch.description),
            onLongPress: () {
              switch (this.setting) {
                case _PatchesSubViewSetting.Preset:
                  break;
                case _PatchesSubViewSetting.Online:
                  break;
                case _PatchesSubViewSetting.Custom:
                  _showCustomOptions(cache.patch);
                  break;
              }
            },
            onTap: () {
              // decide on new state
              var newState = PatchState.Unknown;
              switch (cache.state) {
                case PatchState.Unknown:
                  newState = PatchState.Unknown;
                  break;
                case PatchState.Disabled:
                  newState = PatchState.Enabled;
                  break;
                case PatchState.Enabled:
                  newState = PatchState.Disabled;
                  break;
              }

              // check if no state change takes place
              if (newState == PatchState.Unknown) {
                var error = S.current.patch_memory_mismatch;
                if (!ConnectionPool.inst.hasPassword())
                  error = S.current.patch_require_password;

                // show error
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                  duration: Duration(milliseconds: 700),
                ));
                return;
              }

              // get connection
              ConnectionPool.inst.get().then((con) async {
                // apply new state
                bool error = false;
                try {
                  bool result = await cache.patch
                      .setState(con, newState)
                      .whenComplete(() {
                    con.free();
                    update();
                  });
                  if (result == null || !result) error = true;
                } catch (Exception) {
                  con.free();
                  error = true;
                }

                // show error
                if (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.current.patch_apply_error),
                    backgroundColor: Colors.red,
                    duration: Duration(milliseconds: 700),
                  ));
                }
              }, onError: (e) {
                // show error
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(S.current.connect_a_server),
                  backgroundColor: Colors.red,
                  duration: Duration(milliseconds: 700),
                ));
              });
            },
          );
        }).toList()),
      ),
    );
  }

  _showAddOnlineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(S.current.patch_online_patches),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.file_download),
                title: Text(S.current.download_from_url),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PatchDownloadView();
                    },
                  ).then((_) => update());
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text(S.current.patch_online_export_all),
                onTap: () {
                  Navigator.of(context).pop();
                  String json = PatchManager.inst.getPatchesJSONOnline();
                  if (Platform.isAndroid ||
                          Platform.isIOS ||
                          defaultTargetPlatform ==
                              TargetPlatform.ohos //|| Platform.isOhos
                      ) {
                    Share.share(json);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text(S.current.patch_online_remove_all),
                onTap: () {
                  Navigator.of(context).pop();
                  PatchManager.inst.removeOnlinePatches();
                  update();
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(S.current.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  _showAddCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(S.current.patch_custom_add),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.memory),
                title: Text(S.current.patch_add_memory),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PatchAddCustomView(
                        baseDetails: null,
                        onSave: (patch) {
                          PatchManager.inst.addPatch(patch);
                          update();
                        },
                      );
                    },
                  ).then((_) => update());
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text(S.current.patch_custom_export_all),
                onTap: () {
                  Navigator.of(context).pop();
                  String json = PatchManager.inst.getPatchesJSONCustom();
                  if (Platform.isAndroid ||
                          Platform.isIOS ||
                          defaultTargetPlatform ==
                              TargetPlatform.ohos //|| Platform.isOhos
                      ) Share.share(json);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text(S.current.patch_custom_remove_all),
                onTap: () {
                  PatchManager.inst.removeCustomPatches();
                  update();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(S.current.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showCustomOptions(Patch patch) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text('${S.current.edit} \'${patch.name}\''),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) {
                    return PatchAddCustomView(
                      baseDetails: patch,
                      onSave: (patchNew) {
                        PatchManager.inst.removePatch(patch);
                        PatchManager.inst.addPatch(patchNew);
                        update();
                      },
                    );
                  },
                );
              }),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.delete),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(S.current.remove),
                ),
              ],
            ),
            onPressed: () {
              PatchManager.inst.removePatch(patch);
              update();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class PatchDownloadView extends StatefulWidget {
  @override
  _PatchDownloadViewState createState() => _PatchDownloadViewState();
}

class _PatchDownloadViewState extends State<PatchDownloadView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  AutovalidateMode _autoValidateFields = AutovalidateMode.disabled;
  String _urlInput = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.patch_download_from_url),
      content: Form(
        key: _formState,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                //leading: Icon(Icons.cloud_download),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _urlInput,
                  decoration: InputDecoration(
                    labelText: "URL",
                    hintText: "http://pastebin.com/raw/example",
                  ),
                  onSaved: (String s) => _urlInput = s,
                  validator: validateURL,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.current.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(S.current.download_or_import),
          onPressed: () async {
            if (_formState.currentState.validate()) {
              _formState.currentState.save();

              // download
              await downloadTextFromURL(_urlInput).then((json) async {
                try {
                  // parse patches
                  int no1 = PatchManager.inst.countPatches();
                  PatchManager.inst.addPatchesFromJson(json, online: true);
                  int no2 = PatchManager.inst.countPatches();
                  int count = no2 - no1;

                  // show success
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(S.current.success),
                          content: Text("$count ${S.current.patch_imported}"),
                          actions: [
                            TextButton(
                                child: Text(S.current.ok),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })
                          ],
                        );
                      });
                } on Exception {
                  // show error
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(S.current.error),
                          content: Text(S.current.unable_parse_json),
                          actions: [
                            TextButton(
                                child: Text(S.current.ok),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })
                          ],
                        );
                      });
                }
              }, onError: (e) async {
                // show error
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(S.current.error),
                        content: Text(S.current.unable_download_contents),
                        actions: [
                          TextButton(
                              child: Text(S.current.ok),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })
                        ],
                      );
                    });
              });

              Navigator.of(context).pop();
            } else {
              setState(() {
                // upon trying to add/write invalid data,
                // it'll be validated every time the fields change
                // until you save it.
                _autoValidateFields = AutovalidateMode.disabled;
              });
            }
          },
        ),
      ],
    );
  }

  String validateURL(String cardID) {
    if (!RegExp(r"^(https?:\/\/)?(www\.)?" +
            r"[-a-zA-Z0-9@:%._\+~#=]{1,256}\." +
            r"[a-z]{1,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$")
        .hasMatch(cardID)) return "Invalid URL!";
    return null;
  }
}

class PatchAddCustomView extends StatefulWidget {
  PatchAddCustomView({@required this.onSave, this.baseDetails});

  final void Function(MemoryPatch) onSave;
  final MemoryPatch baseDetails;

  _PatchAddCustomViewState createState() => _PatchAddCustomViewState();
}

class _PatchAddCustomViewState extends State<PatchAddCustomView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  AutovalidateMode _autoValidateFields = AutovalidateMode.disabled;
  MemoryPatch _data;

  @override
  void initState() {
    super.initState();
    if (widget.baseDetails == null) {
      // create new patch
      _data = MemoryPatch.fromMap({
        "name": "",
        "type": "memory",
        "patches": [{}],
      });

      // pre fill data
      if (gameExt.length == 10) {
        _data.dateCodeMin = int.parse(gameExt, onError: (e) {});
        _data.dateCodeMax = int.parse(gameExt, onError: (e) {});
      }
      if (gameModel.length == 3) {
        _data.gameCode = gameModel;
      }
    } else {
      var map = {};
      widget.baseDetails.writeToMap(map);
      _data = MemoryPatch.fromMap(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.baseDetails == null
          ? S.current.patch_add
          : S.current.patch_edit),
      content: Form(
        key: _formState,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                //leading: Icon(Icons.person),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Unlock all songs',
                  ),
                  onSaved: (String s) => _data.name = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.chat_bubble),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.description,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'This patch unlocks all songs.',
                  ),
                  onSaved: (String s) => _data.description = s,
                  validator: null,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.code),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.gameCode,
                  decoration: InputDecoration(
                    labelText: 'Game Code',
                    hintText: 'LDJ',
                  ),
                  onSaved: (String s) => _data.gameCode = s,
                  validator: validateGameCode,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.calendar_today),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.dateCodeMax == 0
                      ? null
                      : _data.dateCodeMax.toString(),
                  decoration: InputDecoration(
                    labelText: 'Date Code',
                    hintText: '2019010100',
                  ),
                  onSaved: (String s) {
                    int dateCode = int.parse(s);
                    _data.dateCodeMin = dateCode;
                    _data.dateCodeMax = dateCode;
                  },
                  validator: validateNumber,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.library_books),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dllName,
                  decoration: InputDecoration(
                    labelText: 'DLL ${S.current.name}',
                    hintText: 'bm2dx.dll',
                  ),
                  onSaved: (s) => _data.getPatches()[0].dllName = s,
                  validator: validateDLL,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.memory),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataEnabled,
                  decoration: InputDecoration(
                    labelText: 'Data Enabled (Hex)',
                    hintText: '9090909090',
                  ),
                  onSaved: (s) {
                    _data.getPatches()[0].dataEnabled =
                        s.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                  },
                  validator: validateHex,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.memory),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataDisabled,
                  decoration: InputDecoration(
                    labelText: 'Data Disabled (Hex)',
                    hintText: 'E900000000',
                  ),
                  onSaved: (s) {
                    _data.getPatches()[0].dataDisabled =
                        s.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                  },
                  validator: validateHex,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.code),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataOffset == 0
                      ? null
                      : _data.getPatches()[0].dataOffset.toString(),
                  decoration: InputDecoration(
                    labelText: 'Offset',
                    hintText: '0xFFFF / 65535',
                  ),
                  onSaved: (String s) {
                    int parsed = int.parse(s);
                    _data.getPatches()[0].dataOffset = parsed;
                  },
                  validator: validateNumber,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.current.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child:
              Text(widget.baseDetails == null ? S.current.add : S.current.save),
          onPressed: () {
            if (_formState.currentState.validate()) {
              _formState.currentState.save();
              widget.onSave(_data);
              Navigator.of(context).pop();
            } else {
              setState(() {
                // upon trying to add/resave invalid data,
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
    if (s.length == 0) return S.current.cannot_be_empty;
    return null;
  }

  String validateNumber(String s) {
    if (s.length == 0) return S.current.cannot_be_empty;
    var parsed = int.tryParse(s);
    return parsed == null ? S.current.invaild_number : null;
  }

  String validateGameCode(String s) {
    if (s.length == 0) return S.current.cannot_be_empty;
    if (s.length != 3) return S.current.must_be_3_letters;
    return null;
  }

  String validateDLL(String s) {
    if (!RegExp(r"^[a-zA-Z0-9]+\.(dll|exe)$").hasMatch(s))
      return S.current.invaild_dll_name;
    return null;
  }

  String validateHex(String s) {
    s = s.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (!RegExp(r"^([a-zA-Z0-9][a-zA-Z0-9])+$").hasMatch(s))
      return S.current.must_be_vaild_hex;
    return null;
  }
}
