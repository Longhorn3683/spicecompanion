part of views;

const cStoredServers = 'server_list'; // preferences key
List<ServerInfo> serverList = [];

class ServerInfo {
  String name = "Server";
  String address = "127.0.0.1";
  String port = "1337";
  String pass = "";

  ServerInfo(
      {@required this.name,
      @required this.address,
      @required this.port,
      @required this.pass});

  ServerInfo.fromJson(String json) {
    Map obj = jsonDecode(json);
    name = obj["name"] ?? name;
    address = obj["address"] ?? address;
    port = obj["port"] ?? port;
    pass = obj["pass"] ?? pass;
  }

  String toJson() {
    return jsonEncode({
      "name": name,
      "address": address,
      "port": port,
      "pass": pass,
    });
  }
}

class ServerView extends StatefulWidget {
  const ServerView({Key key}) : super(key: key);

  @override
  _ServerViewState createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  Timer serverViewTimer;

  @override
  void initState() {
    super.initState();
    if (serverViewTimer != null) serverViewTimer.cancel();
    serverViewTimer =
        Timer.periodic(const Duration(milliseconds: 500), serverViewTick);

    // reload server list
    preferencesGetStringList(cStoredServers).then((storedList) {
      if (storedList != null) {
        List<ServerInfo> newList = [];
        for (var json in storedList) {
          try {
            var server = ServerInfo.fromJson(json);
            newList.add(server);
          } on Exception {
            debugPrint("Couldn't parse ServerInfo: $json");
          }
        }
        serverList = newList;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (serverViewTimer != null) serverViewTimer.cancel();
    serverViewTimer = null;
    super.dispose();
  }

  void serverViewTick(Timer _) {
    // auto refresh state for connected/disconnected state
    try {
      setState(() {});
    } on Exception {}
  }

  Future<void> saveServerList() {
    return preferencesSetStringList(
        cStoredServers, serverList.map((s) => s.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    var hasConnection = ConnectionPool.inst.hasConnection();
    // Build server list from `serverList`
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          systemOverlayStyle: getSystemUiOverlayStyle(context),
          title: Text(S.current.servers),
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            // 'Add Server' Button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ServerEditView(
                      onSave: (ServerInfo server) {
                        setState(() => serverList.add(server));
                        saveServerList();
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              serverList.map((ServerInfo s) {
                var isCon =
                    ConnectionPool.inst.isActive(s.address, s.port, s.pass);
                var isConStr = isCon ? " (${S.current.active})" : "";
                if (isCon && !hasConnection) {
                  isConStr = " (${S.current.disconnected})";
                }
                return Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: !isCon
                      ? null
                      : hasConnection
                          ? Colors.lightGreen
                          : Colors.orange,
                  child: ListTile(
                    title: Text("${s.name}$isConStr"),
                    subtitle: Text('${s.address}:${s.port}'),
                    onTap: () {
                      // check for connect/disconnect
                      if (!isCon) {
                        _tryConnect(s);
                      } else {
                        // show disconnect info
                        /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Disconnected."),
                      backgroundColor: Colors.orange,
                      duration: Duration(milliseconds: 500),
                    ));*/

                        ConnectionPool.inst.disconnect();
                        setState(() {});
                      }
                    },
                    trailing: MenuAnchor(
                      builder: (
                        BuildContext context,
                        MenuController controller,
                        Widget child,
                      ) {
                        return IconButton(
                          icon: const Icon(Icons.more_vert),
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
                            leadingIcon: const Icon(Icons.edit),
                            child: Text(S.current.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ServerEditView(
                                    baseDetails: s,
                                    onSave: (ServerInfo newServer) {
                                      setState(() {
                                        s.name = newServer.name;
                                        s.address = newServer.address;
                                        s.port = newServer.port;
                                        s.pass = newServer.pass;
                                      });
                                      saveServerList();
                                    },
                                  );
                                },
                              );
                            }),
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.delete),
                          child: Text(S.current.remove),
                          onPressed: () {
                            setState(() => serverList.remove(s));
                            saveServerList();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SliverPadding(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight)),
      ],
    );
  }

  bool connecting = false;

  void _tryConnect(ServerInfo server) {
    // abort if already trying to connect
    if (connecting) return;

    // change server details
    ConnectionPool.inst
        .changeServer(server.address, int.parse(server.port), server.pass);

    // attempt to get a connection
    connecting = true;
    Connection connection;
    ConnectionPool.inst.get().then((con) {
      // accept connection
      connection = con;

      // show info
      /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Connected to ${server.address}:${server.port}"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));*/

      // query avs info to test
      return infoAVS(con);
    }, onError: (err) {
      ConnectionPool.inst.disconnect();

      // show error
      var text = "";
      if (err is APIError) {
        text = S.current.connect_failed_password;
      } else {
        text =
            "${S.current.connect_failed_to} ${server.address}:${server.port}";
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: Text(S.current.ok),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));*/
    }).then((avs) {
      if (connection != null) connection.free();
    }, onError: (err) {
      ConnectionPool.inst.disconnect();
    }).whenComplete(() {
      connecting = false;

      // update state since the active server changed
      if (mounted) setState(() {});
    });
  }
}

class ServerEditView extends StatefulWidget {
  const ServerEditView({Key key, @required this.onSave, this.baseDetails})
      : super(key: key);

  final void Function(ServerInfo) onSave;
  // If none provided, the UI will say 'Add' not 'Edit'/'Save'
  final ServerInfo baseDetails;

  @override
  _ServerEditViewState createState() => _ServerEditViewState();
}

class _ServerEditViewState extends State<ServerEditView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  AutovalidateMode _autoValidateFields = AutovalidateMode.disabled;
  ServerInfo _data;

  @override
  void initState() {
    super.initState();
    if (widget.baseDetails == null) {
      _data = ServerInfo(name: '', address: '', port: '', pass: '');
    } else {
      _data = ServerInfo(
          name: widget.baseDetails.name,
          address: widget.baseDetails.address,
          port: widget.baseDetails.port,
          pass: widget.baseDetails.pass);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.baseDetails == null
          ? S.current.server_add
          : S.current.server_edit),
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
                    labelText: S.current.name,
                    hintText: S.current.main_computer,
                  ),
                  onSaved: (String s) => _data.name = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.cloud),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.address,
                  decoration: InputDecoration(
                    labelText: S.current.host_address,
                    hintText: '127.0.0.1',
                  ),
                  keyboardType: TextInputType.url,
                  onSaved: (String s) => _data.address = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.storage),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.port,
                  decoration: InputDecoration(
                    labelText: S.current.port,
                    hintText: '1337',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (String s) => _data.port = s,
                  validator: (String s) {
                    var basic = validateBasic(s);
                    if (basic != null) return basic;
                    if (int.tryParse(s) == null) return S.current.vaild_int;
                    return null;
                  },
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                //leading: Icon(Icons.lock),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.pass,
                  decoration: InputDecoration(
                    labelText: S.current.password,
                    hintText: 'changeme (optional)',
                  ),
                  obscureText: true,
                  onSaved: (String s) => _data.pass = s,
                  validator: null,
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
    if (s.isEmpty) return S.current.cannot_be_empty;
    return null;
  }
}
