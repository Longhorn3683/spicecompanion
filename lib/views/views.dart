library views;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:spicecompanion/generated/l10n.dart';
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:spicecompanion/util/util.dart';
import 'package:spicecompanion/platform/platform.dart';
import 'package:mutex/mutex.dart';
import 'package:vibration/vibration.dart';

part 'servers.dart';
part 'cardmanager.dart';
part 'keypad.dart';
part 'buttons.dart';
part 'analogs.dart';
part 'lights.dart';
part 'patches.dart';
part 'info.dart';
part 'resources.dart';
part 'mainview.dart';
part 'settings.dart';
part 'screen.dart';
part 'controllers/controller.dart';
part 'controllers/buttoncontrol.dart';
part 'controllers/touchcontrol.dart';
part 'controllers/jb.dart';
part 'controllers/iidx.dart';
part 'controllers/popn.dart';
part 'controllers/nost.dart';
part 'controllers/sdvx.dart';
part 'controllers/ddr.dart';
part 'controllers/bbc.dart';
part 'controllers/hpm.dart';
part 'controllers/rf3d.dart';
part 'controllers/ftt.dart';
part 'controllers/lp.dart';
part 'controllers/drs.dart';
part 'controllers/we.dart';

enum SpiceView {
  Info,
  CardManager,
  Keypad,
  Patches,
  Screen,
  Controller,
  Buttons,
  Analogs,
  Lights,
  Settings,
}

SpiceView defaultSpiceView = SpiceView.Info;

Widget getView(SpiceView view) {
  switch (view) {
    case SpiceView.CardManager:
      return CardManagerView();
    case SpiceView.Keypad:
      return KeypadView();
    case SpiceView.Patches:
      return PatchesView();
    case SpiceView.Screen:
      return ScreenView();
    case SpiceView.Controller:
      return ControllerView();
    case SpiceView.Buttons:
      return ButtonsView();
    case SpiceView.Analogs:
      return AnalogsView();
    case SpiceView.Lights:
      return LightsView();
    case SpiceView.Info:
      return InfoView();
    case SpiceView.Settings:
      return SettingsView();
    default:
      return Material(
          color: Colors.red,
          child: Center(
            child: Text('${S.current.view_unknown} \'$view\'',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                )),
          ));
  }
}

Icon getViewIcon(SpiceView view) {
  switch (view) {
    case SpiceView.CardManager:
      return Icon(Icons.credit_card);
    case SpiceView.Keypad:
      return Icon(Icons.dialpad);
    case SpiceView.Patches:
      return Icon(Icons.memory);
    case SpiceView.Screen:
      return Icon(Icons.cast);
    case SpiceView.Controller:
      return Icon(Icons.gamepad);
    case SpiceView.Buttons:
      return Icon(Icons.keyboard);
    case SpiceView.Analogs:
      return Icon(Icons.threesixty);
    case SpiceView.Lights:
      return Icon(Icons.lightbulb_outline);
    case SpiceView.Info:
      return Icon(Icons.info);
    case SpiceView.Settings:
      return Icon(Icons.settings);
    default:
      return Icon(Icons.error);
  }
}

String getViewName(SpiceView view) {
  switch (view) {
    case SpiceView.CardManager:
      return S.current.view_cardmanager;
    case SpiceView.Keypad:
      return S.current.view_keypad;
    case SpiceView.Patches:
      return S.current.view_patches;
    case SpiceView.Screen:
      return S.current.view_screen;
    case SpiceView.Controller:
      return S.current.view_controller;
    case SpiceView.Buttons:
      return S.current.view_buttons;
    case SpiceView.Analogs:
      return S.current.view_analogs;
    case SpiceView.Lights:
      return S.current.view_lights;
    case SpiceView.Info:
      return S.current.view_info;
    case SpiceView.Settings:
      return S.current.view_settings;
    default:
      return S.current.view_unknown;
  }
}
