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
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:spicecompanion/generated/l10n.dart';
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:spicecompanion/util/util.dart';
import 'package:spicecompanion/platform/platform.dart';
import 'package:mutex/mutex.dart';
import 'package:spicecompanion/views/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
      return const CardManagerView();
    case SpiceView.Keypad:
      return const KeypadView();
    case SpiceView.Patches:
      return const PatchesView();
    case SpiceView.Screen:
      return const ScreenView();
    case SpiceView.Controller:
      return ControllerView();
    case SpiceView.Buttons:
      return const ButtonsView();
    case SpiceView.Analogs:
      return const AnalogsView();
    case SpiceView.Lights:
      return const LightsView();
    case SpiceView.Info:
      return const InfoView();
    case SpiceView.Settings:
      return const SettingsView();
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
      return const Icon(Icons.credit_card);
    case SpiceView.Keypad:
      return const Icon(Icons.dialpad);
    case SpiceView.Patches:
      return const Icon(Icons.memory);
    case SpiceView.Screen:
      return const Icon(Icons.cast);
    case SpiceView.Controller:
      return const Icon(Icons.gamepad);
    case SpiceView.Buttons:
      return const Icon(Icons.keyboard);
    case SpiceView.Analogs:
      return const Icon(Icons.threesixty);
    case SpiceView.Lights:
      return const Icon(Icons.lightbulb_outline);
    case SpiceView.Info:
      return const Icon(Icons.info);
    case SpiceView.Settings:
      return const Icon(Icons.settings);
    default:
      return const Icon(Icons.error);
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
