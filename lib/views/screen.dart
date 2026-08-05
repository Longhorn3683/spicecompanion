part of views;

final screensViewNo = ValueNotifier<int>(1);
var screensCaptureNo = 0;

class ScreenView extends StatefulWidget {
  @override
  _ScreenViewState createState() => _ScreenViewState();
}

class _ScreenViewState extends State<ScreenView> {
  Image captureImage;
  int captureTimestamp = 0;
  bool captureActive = false;
  List<int> captureScreens = [];
  TouchControl touchControl = TouchControl();
  Map touchPoints = Map();

  @override
  void initState() {
    super.initState();
    captureActive = true;

    // get list of screens
    ConnectionPool.inst.get().then((con) {
      captureGetScreens(con).then((screens) {
        captureScreens = [];
        for (var screen in screens) {
          captureScreens.add(screen);
        }
      }).whenComplete(() => con.free());
    }, onError: (e) {
      // connection fail
    });

    // start worker threads
    for (int i = 0; i < Settings.screenThreads.toInt(); i++) {
      update();
    }
  }

  @override
  void dispose() {
    captureActive = false;
    super.dispose();
  }

  void update() async {
    ConnectionPool.inst.get().then((con) async {
      if (!captureActive || captureScreens.isEmpty) {
        con.free();
        await Future.delayed(Duration(milliseconds: 100));
        return;
      }
      var quality = Settings.screenQuality.toInt();
      var divide = Settings.screenDivide.toInt();
      var screens = captureScreens;
      screensCaptureNo = screensViewNo.value % screens.length;
      captureGetJPG(
        con,
        screen: screens[screensCaptureNo],
        quality: quality,
        divide: divide,
      ).then((newCaptureData) async {
        if (!captureActive) return;
        if (newCaptureData.data != null &&
            (captureTimestamp <= newCaptureData.timestamp)) {
          var imageMemory = MemoryImage(newCaptureData.data);
          await precacheImage(imageMemory, context);
          if (captureTimestamp <= newCaptureData.timestamp) {
            captureImage = Image(
              image: imageMemory,
              gaplessPlayback: true,
              width: newCaptureData.width.toDouble(),
              height: newCaptureData.height.toDouble(),
              isAntiAlias: false,
              filterQuality: FilterQuality.low,
            );
            captureTimestamp = newCaptureData.timestamp;
          }
        }
        if (!captureActive) return;
        setState(() {});
      }, onError: (e) {
        con.dispose();
      }).whenComplete(() => con.free());
    }, onError: (e) {
      // connection fail
    }).whenComplete(() async {
      if (captureActive) {
        await Future.delayed(Duration(milliseconds: 1));
        update();
      }
    });
  }

  void updateTouch(var pointer, int x, int y, bool active) async {
    // check if active
    if (active) {
      // check if inserted
      if (touchPoints.containsKey(pointer)) {
        // update
        var touchID = touchPoints[pointer];
        touchControl.touchMove(touchID, x, y);
      } else {
        // create
        var touchID = await touchControl.touchDown(x, y);
        touchPoints[pointer] = touchID;
      }
    } else {
      // erase if existing
      if (touchPoints.containsKey(pointer)) {
        var touchID = touchPoints[pointer];
        touchControl.touchUp(touchID);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          systemOverlayStyle: getSystemUiOverlayStyle(context),
          title: Text(getViewName(SpiceView.Screen)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                screensViewNo.value++;
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                ConnectionPool.inst.get().then((con) {
                  captureGetJPG(con,
                          screen: screensCaptureNo, divide: 2, quality: 50)
                      .then((capture) async {
                    var dir = await getApplicationDocumentsDirectory();
                    var path = dir.path;
                    var file = File("$path/capture.jpg");
                    await file.writeAsBytes(
                        capture.data.toList(growable: false),
                        flush: true);
                    Share.shareFiles(<String>[file.path],
                        mimeTypes: <String>["image/jpeg"]);
                    setState(() {});
                  }).whenComplete(() => con.free());
                });
              },
            ),
            /*IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      //title: Text("Screen Settings"),
                      content: SingleChildScrollView(
                          child: Column(children: [
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
                              print("Settings: screen quality changed to " +
                                  value.toString());
                              Settings.screenQuality = value;
                              Settings.save();
                              setState(() {});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("Screen Threads: " +
                              Settings.screenThreads.toInt().toString()),
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
                          title: Text("Screen Divide: " +
                              Settings.screenDivide.toInt().toString()),
                          subtitle: Slider(
                            value: Settings.screenDivide,
                            min: 1,
                            max: 16,
                            divisions: 15,
                            onChanged: (value) {
                              Settings.screenDivide = value;
                            },
                            onChangeEnd: (value) {
                              Settings.save();
                              setState(() {});
                            },
                          ),
                        ),
                      ])),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),*/
          ],
        ),
        SliverFillRemaining(
          child: () {
            var image = captureImage;
            if (image != null) {
              return Padding(
                padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: image.width / image.height,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: () {
                        RenderBox rb = context.findRenderObject() as RenderBox;
                        Size rbSize = rb?.size ?? Size(1280, 720);
                        var divide = Settings.screenDivide.toInt();

                        // get padding
                        double padX = 0;
                        double padY = 0;
                        double imageAspect = image.width / image.height;
                        double boxAspect = rbSize.width / rbSize.height;
                        if (imageAspect > boxAspect) {
                          padY = rbSize.height - rbSize.width / imageAspect;
                        }
                        if (imageAspect < boxAspect) {
                          padX = rbSize.width - imageAspect * rbSize.height;
                        }

                        // get scale
                        double horScale = image.width / (rbSize.width - padX);
                        double verScale = image.height / (rbSize.height - padY);
                        horScale *= divide;
                        verScale *= divide;

                        return Listener(
                          onPointerDown: (p) {
                            var pos = Offset(p.position.dx - padX * 0.5,
                                p.position.dy - padY * 0.5);
                            var local = rb.globalToLocal(pos);
                            int touchX = (local.dx * horScale).toInt();
                            int touchY = (local.dy * verScale).toInt();
                            updateTouch(p.pointer, touchX, touchY, true);
                          },
                          onPointerMove: (p) {
                            var pos = Offset(p.position.dx - padX * 0.5,
                                p.position.dy - padY * 0.5);
                            var local = rb.globalToLocal(pos);
                            int touchX = (local.dx * horScale).toInt();
                            int touchY = (local.dy * verScale).toInt();
                            updateTouch(p.pointer, touchX, touchY, true);
                          },
                          onPointerUp: (p) {
                            updateTouch(p.pointer, 0, 0, false);
                          },
                          onPointerCancel: (p) {
                            updateTouch(p.pointer, 0, 0, false);
                          },
                          child: image,
                        );
                      }(),
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
              child: Center(child: Text(S.current.no_screen)),
            );
          }(),
        ),
      ],
    );
  }
}
