part of views;

final screensViewNo = ValueNotifier<int>(1);
var screensCaptureNo = 0;
var screenMode = 'screen';

class ScreenTab extends StatefulWidget {
  const ScreenTab({Key key}) : super(key: key);

  @override
  _ScreenTabState createState() => _ScreenTabState();
}

class _ScreenTabState extends State<ScreenTab> {
  Image captureImage;
  String ledTickerString;
  int captureTimestamp = 0;
  bool captureActive = false;
  List<int> captureScreens = [];
  TouchControl touchControl = TouchControl();
  Map touchPoints = {};

  @override
  void initState() {
    super.initState();
    // get list of screens
    ConnectionPool.inst.get().then((con) {
      captureGetScreens(con).then((screens) {
        captureScreens = [];
        for (var screen in screens) {
          captureScreens.add(screen);
        }
        screensCaptureNo = screensViewNo.value % captureScreens.length;
      }).whenComplete(() {
        con.free();
      });
    }, onError: (e) {
      // connection fail
    });
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
        await Future.delayed(const Duration(milliseconds: 100));
        return;
      }

      if (screenMode == 'screen') {
        var quality = Settings.screenQuality.toInt();
        var divide = Settings.screenDivide.toInt();
        var screens = captureScreens;

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
      } else if (screenMode == 'led') {
        if (!captureActive) return;

        ledTickerString = await iidxTickerGet(con);
        if (!captureActive) return;

        setState(() {});
        con.free();
      }
    }, onError: (e) {
      // connection fail
    }).whenComplete(() async {
      if (captureActive) {
        await Future.delayed(const Duration(milliseconds: 1));
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
    return Listener(
      onPointerDown: (p) {
        if (p.position.dy < MediaQuery.of(context).padding.top + 16) {
          toolbarHidden.value = false;
        }
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder<bool>(
            builder: (BuildContext context, bool value, Widget child) {
              return AppBar(
                toolbarHeight: toolbarHidden.value ? 0 : kToolbarHeight,
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                systemOverlayStyle: getSystemUiOverlayStyle(context),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(S.current.view_screen),
                actions: <Widget>[
                  StatefulBuilder(builder: (context, connectState) {
                    return IconButton(
                      icon: captureActive
                          ? const Icon(Icons.link_off)
                          : const Icon(Icons.link),
                      onPressed: () {
                        captureActive = !captureActive;

                        if (screenMode == 'screen') {
                          // Screen Mirror
                          if (captureScreens.isNotEmpty) {
                            // start worker threads
                            for (int i = 0;
                                i < Settings.screenThreads.toInt();
                                i++) {
                              update();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              width: 300,
                              content: Text(S.current.no_screen),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ));
                            captureActive = false;
                          }
                        } else if (screenMode == 'led') {
                          // IIDX LED Ticker
                          update();
                        }
                        connectState(() {});
                        setState(() {});
                      },
                    );
                  }),
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
                        captureGetJPG(con,
                                screen: screensCaptureNo,
                                divide: 1,
                                quality: 100)
                            .then((capture) async {
                          await file.writeAsBytes(
                              capture.data.toList(growable: false),
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
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        clipBehavior: Clip.antiAlias,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                              builder: (context, sheetState) {
                            getScreenSelection() {
                              if (captureScreens.isNotEmpty) {
                                List<ButtonSegment> screenSegments = [];
                                for (int i = 0;
                                    i < captureScreens.length;
                                    i++) {
                                  screenSegments.add(
                                    ButtonSegment(
                                      value: captureScreens[i],
                                      label: Text('${captureScreens[i]}'),
                                    ),
                                  );
                                }
                                return ListTile(
                                  title: Text(S.current.screen_select),
                                  subtitle: SegmentedButton(
                                    showSelectedIcon: false,
                                    segments: screenSegments,
                                    selected: {screensCaptureNo},
                                    onSelectionChanged: (Set newSelection) {
                                      screensCaptureNo = newSelection.first;
                                      sheetState(() {});
                                    },
                                  ),
                                );
                              } else {
                                return ListTile(
                                  title: Text(S.current.no_screen),
                                );
                              }
                            }

                            return SingleChildScrollView(
                                child: Column(children: [
                              const SizedBox(
                                  height: kFloatingActionButtonMargin),
                              ListTile(
                                title: Text(S.current.screen_mode),
                                subtitle: SegmentedButton(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment(
                                      value: 'screen',
                                      label: Text(S.current.screen_mode_screen),
                                    ),
                                    ButtonSegment(
                                      value: 'led',
                                      label: Text(S.current.screen_mode_led),
                                    ),
                                  ],
                                  selected: {screenMode},
                                  onSelectionChanged: (Set newSelection) {
                                    screenMode = newSelection.first;
                                    sheetState(() {});
                                    setState(() {});
                                  },
                                ),
                              ),
                              getScreenSelection(),
                              ListTile(
                                title: Text(
                                    "${S.current.screen_quality}: ${Settings.screenQuality.toInt()}%"),
                                subtitle: Slider(
                                  value: Settings.screenQuality,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (value) {
                                    Settings.screenQuality = value;
                                    Settings.save();
                                    sheetState(() {});
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                    "${S.current.screen_threads}: ${Settings.screenThreads.toInt()}"),
                                subtitle: Slider(
                                  value: Settings.screenThreads,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  onChanged: (value) {
                                    Settings.screenThreads = value;
                                    Settings.save();
                                    sheetState(() {});
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                    "${S.current.screen_divide}: ${Settings.screenDivide.toInt()}"),
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
                                    sheetState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(
                                  height: kFloatingActionButtonMargin),
                            ]));
                          });
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less),
                    onPressed: () {
                      toolbarHidden.value = !toolbarHidden.value;

                      if (toolbarHidden.value == true) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          width: 300,
                          content: Text(S.current.tap_to_show_bar),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ));
                      }
                    },
                  ),
                ],
              );
            },
            valueListenable: toolbarHidden,
          ),
        ),
        body: Container(
          child: () {
            var image = captureImage;
            if (captureActive && screenMode == 'screen' && image != null) {
              return Center(
                child: AspectRatio(
                  aspectRatio: image.width / image.height,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: () {
                      RenderBox rb = context.findRenderObject() as RenderBox;
                      Size rbSize = rb?.size ?? const Size(1280, 720);
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
                          if (captureActive) {
                            var pos = Offset(p.position.dx - padX * 0.5,
                                p.position.dy - padY * 0.5);
                            var local = rb.globalToLocal(pos);
                            int touchX = (local.dx * horScale).toInt();
                            int touchY = (local.dy * verScale).toInt();
                            updateTouch(p.pointer, touchX, touchY, true);
                          }
                        },
                        onPointerMove: (p) {
                          if (captureActive) {
                            var pos = Offset(p.position.dx - padX * 0.5,
                                p.position.dy - padY * 0.5);
                            var local = rb.globalToLocal(pos);
                            int touchX = (local.dx * horScale).toInt();
                            int touchY = (local.dy * verScale).toInt();
                            updateTouch(p.pointer, touchX, touchY, true);
                          }
                        },
                        onPointerUp: (p) {
                          if (captureActive) {
                            updateTouch(p.pointer, 0, 0, false);
                          }
                        },
                        onPointerCancel: (p) {
                          if (captureActive) {
                            updateTouch(p.pointer, 0, 0, false);
                          }
                        },
                        child: image,
                      );
                    }(),
                  ),
                ),
              );
            } else if (captureActive &&
                screenMode == 'led' &&
                ledTickerString != null) {
              return Center(
                child: Container(
                  color: Colors.black,
                  child: AutoSizeText.rich(
                    TextSpan(children: [
                      const TextSpan(
                        text: '[',
                        style: TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                        ),
                      ),
                      TextSpan(text: ledTickerString),
                      const TextSpan(
                        text: ']',
                        style: TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                        ),
                      ),
                    ]),
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 999999999999,
                        fontFamily: 'JetBrains Mono'),
                    maxLines: 1,
                  ),
                ),
              );
            } else {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                child: Center(child: Text(S.current.screen_off)),
              );
            }
          }(),
        ),
      ),
    );
  }
}
