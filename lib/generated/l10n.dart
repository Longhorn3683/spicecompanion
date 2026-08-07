// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Unknown View`
  String get view_unknown {
    return Intl.message(
      'Unknown View',
      name: 'view_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Cards`
  String get view_cardmanager {
    return Intl.message(
      'Cards',
      name: 'view_cardmanager',
      desc: '',
      args: [],
    );
  }

  /// `Keypad/NFC Reader`
  String get view_keypad {
    return Intl.message(
      'Keypad/NFC Reader',
      name: 'view_keypad',
      desc: '',
      args: [],
    );
  }

  /// `Patches`
  String get view_patches {
    return Intl.message(
      'Patches',
      name: 'view_patches',
      desc: '',
      args: [],
    );
  }

  /// `Screen (Beta)`
  String get view_screen {
    return Intl.message(
      'Screen (Beta)',
      name: 'view_screen',
      desc: '',
      args: [],
    );
  }

  /// `Controller`
  String get view_controller {
    return Intl.message(
      'Controller',
      name: 'view_controller',
      desc: '',
      args: [],
    );
  }

  /// `Buttons`
  String get view_buttons {
    return Intl.message(
      'Buttons',
      name: 'view_buttons',
      desc: '',
      args: [],
    );
  }

  /// `Analogs`
  String get view_analogs {
    return Intl.message(
      'Analogs',
      name: 'view_analogs',
      desc: '',
      args: [],
    );
  }

  /// `Lights`
  String get view_lights {
    return Intl.message(
      'Lights',
      name: 'view_lights',
      desc: '',
      args: [],
    );
  }

  /// `Server Information`
  String get view_info {
    return Intl.message(
      'Server Information',
      name: 'view_info',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get view_settings {
    return Intl.message(
      'Settings',
      name: 'view_settings',
      desc: '',
      args: [],
    );
  }

  /// `Please connect to a server`
  String get connect_a_server {
    return Intl.message(
      'Please connect to a server',
      name: 'connect_a_server',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect to`
  String get connect_failed_to {
    return Intl.message(
      'Failed to connect to',
      name: 'connect_failed_to',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect: Wrong password?`
  String get connect_failed_password {
    return Intl.message(
      'Failed to connect: Wrong password?',
      name: 'connect_failed_password',
      desc: '',
      args: [],
    );
  }

  /// `This game does not yet have a controller view :(`
  String get no_controller_view {
    return Intl.message(
      'This game does not yet have a controller view :(',
      name: 'no_controller_view',
      desc: '',
      args: [],
    );
  }

  /// `No analogs available :(`
  String get no_analogs {
    return Intl.message(
      'No analogs available :(',
      name: 'no_analogs',
      desc: '',
      args: [],
    );
  }

  /// `No buttons available :(`
  String get no_buttons {
    return Intl.message(
      'No buttons available :(',
      name: 'no_buttons',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Insert to P1`
  String get insert_p1 {
    return Intl.message(
      'Insert to P1',
      name: 'insert_p1',
      desc: '',
      args: [],
    );
  }

  /// `Insert to P2`
  String get insert_p2 {
    return Intl.message(
      'Insert to P2',
      name: 'insert_p2',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Inserting Card`
  String get card_inserting {
    return Intl.message(
      'Inserting Card',
      name: 'card_inserting',
      desc: '',
      args: [],
    );
  }

  /// `Insert Card`
  String get card_insert_keypad {
    return Intl.message(
      'Insert Card',
      name: 'card_insert_keypad',
      desc: '',
      args: [],
    );
  }

  /// `Tip: Tap your card to the back of your phone.`
  String get card_tap {
    return Intl.message(
      'Tip: Tap your card to the back of your phone.',
      name: 'card_tap',
      desc: '',
      args: [],
    );
  }

  /// `Add Card`
  String get card_add {
    return Intl.message(
      'Add Card',
      name: 'card_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit Card`
  String get card_edit {
    return Intl.message(
      'Edit Card',
      name: 'card_edit',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Main Card`
  String get card_main {
    return Intl.message(
      'Main Card',
      name: 'card_main',
      desc: '',
      args: [],
    );
  }

  /// `Card ID`
  String get card_id {
    return Intl.message(
      'Card ID',
      name: 'card_id',
      desc: '',
      args: [],
    );
  }

  /// `optional`
  String get optional {
    return Intl.message(
      'optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Insert 1 Coin`
  String get insert_coin_1 {
    return Intl.message(
      'Insert 1 Coin',
      name: 'insert_coin_1',
      desc: '',
      args: [],
    );
  }

  /// `Insert 5 Coins`
  String get insert_coin_5 {
    return Intl.message(
      'Insert 5 Coins',
      name: 'insert_coin_5',
      desc: '',
      args: [],
    );
  }

  /// `Insert 10 Coins`
  String get insert_coin_10 {
    return Intl.message(
      'Insert 10 Coins',
      name: 'insert_coin_10',
      desc: '',
      args: [],
    );
  }

  /// `Restart Game`
  String get restart_game {
    return Intl.message(
      'Restart Game',
      name: 'restart_game',
      desc: '',
      args: [],
    );
  }

  /// `Restart Game?`
  String get restart_game_prompt {
    return Intl.message(
      'Restart Game?',
      name: 'restart_game_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Quit Game`
  String get quit_game {
    return Intl.message(
      'Quit Game',
      name: 'quit_game',
      desc: '',
      args: [],
    );
  }

  /// `Quit Game?`
  String get quit_game_prompt {
    return Intl.message(
      'Quit Game?',
      name: 'quit_game_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message(
      'Restart',
      name: 'restart',
      desc: '',
      args: [],
    );
  }

  /// `Restart PC?`
  String get restart_prompt {
    return Intl.message(
      'Restart PC?',
      name: 'restart_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Shutdown`
  String get shutdown {
    return Intl.message(
      'Shutdown',
      name: 'shutdown',
      desc: '',
      args: [],
    );
  }

  /// `Shutdown PC?`
  String get shutdown_prompt {
    return Intl.message(
      'Shutdown PC?',
      name: 'shutdown_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Swipe card`
  String get swipe_card {
    return Intl.message(
      'Swipe card',
      name: 'swipe_card',
      desc: '',
      args: [],
    );
  }

  /// `or tap to select in cards`
  String get or_select_in_cards {
    return Intl.message(
      'or tap to select in cards',
      name: 'or_select_in_cards',
      desc: '',
      args: [],
    );
  }

  /// `Please add cards first.`
  String get add_cards_first {
    return Intl.message(
      'Please add cards first.',
      name: 'add_cards_first',
      desc: '',
      args: [],
    );
  }

  /// `Select Card`
  String get card_select {
    return Intl.message(
      'Select Card',
      name: 'card_select',
      desc: '',
      args: [],
    );
  }

  /// `Launch Args`
  String get launch_args {
    return Intl.message(
      'Launch Args',
      name: 'launch_args',
      desc: '',
      args: [],
    );
  }

  /// `Game`
  String get memory_game {
    return Intl.message(
      'Game',
      name: 'memory_game',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get memory_used {
    return Intl.message(
      'Used',
      name: 'memory_used',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get memory_total {
    return Intl.message(
      'Total',
      name: 'memory_total',
      desc: '',
      args: [],
    );
  }

  /// `No lights available :(`
  String get no_lights {
    return Intl.message(
      'No lights available :(',
      name: 'no_lights',
      desc: '',
      args: [],
    );
  }

  /// `Screen mirror not available :(`
  String get no_screen {
    return Intl.message(
      'Screen mirror not available :(',
      name: 'no_screen',
      desc: '',
      args: [],
    );
  }

  /// `Servers`
  String get servers {
    return Intl.message(
      'Servers',
      name: 'servers',
      desc: '',
      args: [],
    );
  }

  /// `Add Server`
  String get server_add {
    return Intl.message(
      'Add Server',
      name: 'server_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit Server`
  String get server_edit {
    return Intl.message(
      'Edit Server',
      name: 'server_edit',
      desc: '',
      args: [],
    );
  }

  /// `Main Computer`
  String get main_computer {
    return Intl.message(
      'Main Computer',
      name: 'main_computer',
      desc: '',
      args: [],
    );
  }

  /// `Host Address`
  String get host_address {
    return Intl.message(
      'Host Address',
      name: 'host_address',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get port {
    return Intl.message(
      'Port',
      name: 'port',
      desc: '',
      args: [],
    );
  }

  /// `Must be a valid integer!`
  String get vaild_int {
    return Intl.message(
      'Must be a valid integer!',
      name: 'vaild_int',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Can't be empty!`
  String get cannot_be_empty {
    return Intl.message(
      'Can\'t be empty!',
      name: 'cannot_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Fullscreen`
  String get fullscreen {
    return Intl.message(
      'Fullscreen',
      name: 'fullscreen',
      desc: '',
      args: [],
    );
  }

  /// `Tap screen top to show top bar`
  String get tap_to_show_bar {
    return Intl.message(
      'Tap screen top to show top bar',
      name: 'tap_to_show_bar',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Button Vibration Duration`
  String get button_vibration {
    return Intl.message(
      'Button Vibration Duration',
      name: 'button_vibration',
      desc: '',
      args: [],
    );
  }

  /// `Screen Quality`
  String get screen_quality {
    return Intl.message(
      'Screen Quality',
      name: 'screen_quality',
      desc: '',
      args: [],
    );
  }

  /// `Screen Threads`
  String get screen_threads {
    return Intl.message(
      'Screen Threads',
      name: 'screen_threads',
      desc: '',
      args: [],
    );
  }

  /// `Screen Divide`
  String get screen_divide {
    return Intl.message(
      'Screen Divide',
      name: 'screen_divide',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get licenses {
    return Intl.message(
      'Licenses',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `No patches known for this version :(`
  String get no_patch_known {
    return Intl.message(
      'No patches known for this version :(',
      name: 'no_patch_known',
      desc: '',
      args: [],
    );
  }

  /// `Enabled`
  String get enabled {
    return Intl.message(
      'Enabled',
      name: 'enabled',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: '',
      args: [],
    );
  }

  /// `Preset`
  String get patch_preset {
    return Intl.message(
      'Preset',
      name: 'patch_preset',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get patch_online {
    return Intl.message(
      'Online',
      name: 'patch_online',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get patch_custom {
    return Intl.message(
      'Custom',
      name: 'patch_custom',
      desc: '',
      args: [],
    );
  }

  /// `Patch is invalid: memory mismatch.`
  String get patch_memory_mismatch {
    return Intl.message(
      'Patch is invalid: memory mismatch.',
      name: 'patch_memory_mismatch',
      desc: '',
      args: [],
    );
  }

  /// `Patches require a password to be set.`
  String get patch_require_password {
    return Intl.message(
      'Patches require a password to be set.',
      name: 'patch_require_password',
      desc: '',
      args: [],
    );
  }

  /// `Error applying patch.`
  String get patch_apply_error {
    return Intl.message(
      'Error applying patch.',
      name: 'patch_apply_error',
      desc: '',
      args: [],
    );
  }

  /// `Online Patches`
  String get patch_online_patches {
    return Intl.message(
      'Online Patches',
      name: 'patch_online_patches',
      desc: '',
      args: [],
    );
  }

  /// `Download from URL`
  String get download_from_url {
    return Intl.message(
      'Download from URL',
      name: 'download_from_url',
      desc: '',
      args: [],
    );
  }

  /// `Export all online patches`
  String get patch_online_export_all {
    return Intl.message(
      'Export all online patches',
      name: 'patch_online_export_all',
      desc: '',
      args: [],
    );
  }

  /// `Remove all online patches`
  String get patch_online_remove_all {
    return Intl.message(
      'Remove all online patches',
      name: 'patch_online_remove_all',
      desc: '',
      args: [],
    );
  }

  /// `Add Custom Patch`
  String get patch_custom_add {
    return Intl.message(
      'Add Custom Patch',
      name: 'patch_custom_add',
      desc: '',
      args: [],
    );
  }

  /// `Add memory patch`
  String get patch_add_memory {
    return Intl.message(
      'Add memory patch',
      name: 'patch_add_memory',
      desc: '',
      args: [],
    );
  }

  /// `Export all custom patches`
  String get patch_custom_export_all {
    return Intl.message(
      'Export all custom patches',
      name: 'patch_custom_export_all',
      desc: '',
      args: [],
    );
  }

  /// `Remove all custom patches`
  String get patch_custom_remove_all {
    return Intl.message(
      'Remove all custom patches',
      name: 'patch_custom_remove_all',
      desc: '',
      args: [],
    );
  }

  /// `Download patches from URL`
  String get patch_download_from_url {
    return Intl.message(
      'Download patches from URL',
      name: 'patch_download_from_url',
      desc: '',
      args: [],
    );
  }

  /// `Download/Import`
  String get download_or_import {
    return Intl.message(
      'Download/Import',
      name: 'download_or_import',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `patches have been imported!`
  String get patch_imported {
    return Intl.message(
      'patches have been imported!',
      name: 'patch_imported',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Unable to parse from JSON :(`
  String get unable_parse_json {
    return Intl.message(
      'Unable to parse from JSON :(',
      name: 'unable_parse_json',
      desc: '',
      args: [],
    );
  }

  /// `Unable to download contents :(`
  String get unable_download_contents {
    return Intl.message(
      'Unable to download contents :(',
      name: 'unable_download_contents',
      desc: '',
      args: [],
    );
  }

  /// `Add Patch`
  String get patch_add {
    return Intl.message(
      'Add Patch',
      name: 'patch_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit Patch`
  String get patch_edit {
    return Intl.message(
      'Edit Patch',
      name: 'patch_edit',
      desc: '',
      args: [],
    );
  }

  /// `Invalid number!`
  String get invaild_number {
    return Intl.message(
      'Invalid number!',
      name: 'invaild_number',
      desc: '',
      args: [],
    );
  }

  /// `Must be 3 letters!`
  String get must_be_3_letters {
    return Intl.message(
      'Must be 3 letters!',
      name: 'must_be_3_letters',
      desc: '',
      args: [],
    );
  }

  /// `Invalid DLL name!`
  String get invaild_dll_name {
    return Intl.message(
      'Invalid DLL name!',
      name: 'invaild_dll_name',
      desc: '',
      args: [],
    );
  }

  /// `Must be a valid hex string!`
  String get must_be_vaild_hex {
    return Intl.message(
      'Must be a valid hex string!',
      name: 'must_be_vaild_hex',
      desc: '',
      args: [],
    );
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `System Time`
  String get system_time {
    return Intl.message(
      'System Time',
      name: 'system_time',
      desc: '',
      args: [],
    );
  }

  /// `Open configuration window`
  String get args_cfg {
    return Intl.message(
      'Open configuration window',
      name: 'args_cfg',
      desc: '',
      args: [],
    );
  }

  /// `Enable integrated EA server`
  String get args_ea {
    return Intl.message(
      'Enable integrated EA server',
      name: 'args_ea',
      desc: '',
      args: [],
    );
  }

  /// `Enable integrated EA server`
  String get args_eamaint {
    return Intl.message(
      'Enable integrated EA server',
      name: 'args_eamaint',
      desc: '',
      args: [],
    );
  }

  /// `Windowed mode`
  String get args_w {
    return Intl.message(
      'Windowed mode',
      name: 'args_w',
      desc: '',
      args: [],
    );
  }

  /// `Capture/clip mouse to window`
  String get args_c {
    return Intl.message(
      'Capture/clip mouse to window',
      name: 'args_c',
      desc: '',
      args: [],
    );
  }

  /// `Unhide cursor`
  String get args_s {
    return Intl.message(
      'Unhide cursor',
      name: 'args_s',
      desc: '',
      args: [],
    );
  }

  /// `Inject custom hook`
  String get args_k {
    return Intl.message(
      'Inject custom hook',
      name: 'args_k',
      desc: '',
      args: [],
    );
  }

  /// `Enable loading stubs`
  String get args_stubs {
    return Intl.message(
      'Enable loading stubs',
      name: 'args_stubs',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable ALL IO emulation`
  String get args_io {
    return Intl.message(
      'Manually enable ALL IO emulation',
      name: 'args_io',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable ACIO emulation`
  String get args_acio {
    return Intl.message(
      'Manually enable ACIO emulation',
      name: 'args_acio',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable ICCA emulation`
  String get args_icca {
    return Intl.message(
      'Manually enable ICCA emulation',
      name: 'args_icca',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable DEVICE emulation`
  String get args_device {
    return Intl.message(
      'Manually enable DEVICE emulation',
      name: 'args_device',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable EXTDEV emulation`
  String get args_extdev {
    return Intl.message(
      'Manually enable EXTDEV emulation',
      name: 'args_extdev',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable SCIUNIT emu`
  String get args_sciunit {
    return Intl.message(
      'Manually enable SCIUNIT emu',
      name: 'args_sciunit',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable SDVX module`
  String get args_sdvx {
    return Intl.message(
      'Manually enable SDVX module',
      name: 'args_sdvx',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable IIDX module`
  String get args_iidx {
    return Intl.message(
      'Manually enable IIDX module',
      name: 'args_iidx',
      desc: '',
      args: [],
    );
  }

  /// `Flip the camera order`
  String get args_iidxflipcams {
    return Intl.message(
      'Flip the camera order',
      name: 'args_iidxflipcams',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable JB module`
  String get args_jb {
    return Intl.message(
      'Manually enable JB module',
      name: 'args_jb',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable Reflec Beat module`
  String get args_rb {
    return Intl.message(
      'Manually enable Reflec Beat module',
      name: 'args_rb',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable Pop'n Music module`
  String get args_pnm {
    return Intl.message(
      'Manually enable Pop\'n Music module',
      name: 'args_pnm',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable Metal Gear module`
  String get args_mga {
    return Intl.message(
      'Manually enable Metal Gear module',
      name: 'args_mga',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable GitaDora module`
  String get args_gd {
    return Intl.message(
      'Manually enable GitaDora module',
      name: 'args_gd',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable Nostalgia module`
  String get args_nostalgia {
    return Intl.message(
      'Manually enable Nostalgia module',
      name: 'args_nostalgia',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable BishiBashi Channel module`
  String get args_bbc {
    return Intl.message(
      'Manually enable BishiBashi Channel module',
      name: 'args_bbc',
      desc: '',
      args: [],
    );
  }

  /// `Two channel audio for GitaDora`
  String get args_2ch {
    return Intl.message(
      'Two channel audio for GitaDora',
      name: 'args_2ch',
      desc: '',
      args: [],
    );
  }

  /// `Manually enable DDR module`
  String get args_ddr {
    return Intl.message(
      'Manually enable DDR module',
      name: 'args_ddr',
      desc: '',
      args: [],
    );
  }

  /// `Enable DDR 4:3 mode`
  String get args_ddrsd {
    return Intl.message(
      'Enable DDR 4:3 mode',
      name: 'args_ddrsd',
      desc: '',
      args: [],
    );
  }

  /// `Enable DDR 4:3 mode`
  String get args_o {
    return Intl.message(
      'Enable DDR 4:3 mode',
      name: 'args_o',
      desc: '',
      args: [],
    );
  }

  /// `Enable QMA module`
  String get args_qma {
    return Intl.message(
      'Enable QMA module',
      name: 'args_qma',
      desc: '',
      args: [],
    );
  }

  /// `Enable SC module`
  String get args_sc {
    return Intl.message(
      'Enable SC module',
      name: 'args_sc',
      desc: '',
      args: [],
    );
  }

  /// `Netfix network`
  String get args_network {
    return Intl.message(
      'Netfix network',
      name: 'args_network',
      desc: '',
      args: [],
    );
  }

  /// `Netfix subnet`
  String get args_subnet {
    return Intl.message(
      'Netfix subnet',
      name: 'args_subnet',
      desc: '',
      args: [],
    );
  }

  /// `Disable network patches`
  String get args_netfixdisable {
    return Intl.message(
      'Disable network patches',
      name: 'args_netfixdisable',
      desc: '',
      args: [],
    );
  }

  /// `Disable ACP patches`
  String get args_acphookdisable {
    return Intl.message(
      'Disable ACP patches',
      name: 'args_acphookdisable',
      desc: '',
      args: [],
    );
  }

  /// `Disable signal handling`
  String get args_signaldisable {
    return Intl.message(
      'Disable signal handling',
      name: 'args_signaldisable',
      desc: '',
      args: [],
    );
  }

  /// `CreateFile debug prints`
  String get args_createfiledebug {
    return Intl.message(
      'CreateFile debug prints',
      name: 'args_createfiledebug',
      desc: '',
      args: [],
    );
  }

  /// `Print PEB on startup`
  String get args_pebprint {
    return Intl.message(
      'Print PEB on startup',
      name: 'args_pebprint',
      desc: '',
      args: [],
    );
  }

  /// `Partial BT5 API compat layer`
  String get args_bt5api {
    return Intl.message(
      'Partial BT5 API compat layer',
      name: 'args_bt5api',
      desc: '',
      args: [],
    );
  }

  /// `SDVX Printer Emulation`
  String get args_printer {
    return Intl.message(
      'SDVX Printer Emulation',
      name: 'args_printer',
      desc: '',
      args: [],
    );
  }

  /// `SDVX Printer Output Directory`
  String get args_printerpath {
    return Intl.message(
      'SDVX Printer Output Directory',
      name: 'args_printerpath',
      desc: '',
      args: [],
    );
  }

  /// `SDVX Printer Format (png/bmp/tga/jpg)`
  String get args_printerformat {
    return Intl.message(
      'SDVX Printer Format (png/bmp/tga/jpg)',
      name: 'args_printerformat',
      desc: '',
      args: [],
    );
  }

  /// `SDVX Printer JPG quality`
  String get args_printerjpgquality {
    return Intl.message(
      'SDVX Printer JPG quality',
      name: 'args_printerjpgquality',
      desc: '',
      args: [],
    );
  }

  /// `Clean up images on start`
  String get args_printerclear {
    return Intl.message(
      'Clean up images on start',
      name: 'args_printerclear',
      desc: '',
      args: [],
    );
  }

  /// `Set urlslash value`
  String get args_urlslash {
    return Intl.message(
      'Set urlslash value',
      name: 'args_urlslash',
      desc: '',
      args: [],
    );
  }

  /// `Disable numpad for reader`
  String get args_disablenumpad {
    return Intl.message(
      'Disable numpad for reader',
      name: 'args_disablenumpad',
      desc: '',
      args: [],
    );
  }

  /// `Disable toprow for reader`
  String get args_disabletoprow {
    return Intl.message(
      'Disable toprow for reader',
      name: 'args_disabletoprow',
      desc: '',
      args: [],
    );
  }

  /// `Base process priority is RT`
  String get args_realtime {
    return Intl.message(
      'Base process priority is RT',
      name: 'args_realtime',
      desc: '',
      args: [],
    );
  }

  /// `Delay (5s before boot)`
  String get args_sleep {
    return Intl.message(
      'Delay (5s before boot)',
      name: 'args_sleep',
      desc: '',
      args: [],
    );
  }

  /// `Custom heap size in bytes`
  String get args_h {
    return Intl.message(
      'Custom heap size in bytes',
      name: 'args_h',
      desc: '',
      args: [],
    );
  }

  /// `Custom path to appargs_config.xml`
  String get args_a {
    return Intl.message(
      'Custom path to appargs_config.xml',
      name: 'args_a',
      desc: '',
      args: [],
    );
  }

  /// `Custom path to avsargs_config.xml`
  String get args_v {
    return Intl.message(
      'Custom path to avsargs_config.xml',
      name: 'args_v',
      desc: '',
      args: [],
    );
  }

  /// `Custom path to ea3args_config.xml`
  String get args_e {
    return Intl.message(
      'Custom path to ea3args_config.xml',
      name: 'args_e',
      desc: '',
      args: [],
    );
  }

  /// `Custom path to log.txt`
  String get args_y {
    return Intl.message(
      'Custom path to log.txt',
      name: 'args_y',
      desc: '',
      args: [],
    );
  }

  /// `Custom PCBID override`
  String get args_p {
    return Intl.message(
      'Custom PCBID override',
      name: 'args_p',
      desc: '',
      args: [],
    );
  }

  /// `Custom SOFTID override`
  String get args_r {
    return Intl.message(
      'Custom SOFTID override',
      name: 'args_r',
      desc: '',
      args: [],
    );
  }

  /// `Custom service URL`
  String get args_url {
    return Intl.message(
      'Custom service URL',
      name: 'args_url',
      desc: '',
      args: [],
    );
  }

  /// `Set path to modules`
  String get args_modules {
    return Intl.message(
      'Set path to modules',
      name: 'args_modules',
      desc: '',
      args: [],
    );
  }

  /// `Use HID SmartCard readers`
  String get args_scard {
    return Intl.message(
      'Use HID SmartCard readers',
      name: 'args_scard',
      desc: '',
      args: [],
    );
  }

  /// `Smartcard P1/P2 order flip`
  String get args_scardflip {
    return Intl.message(
      'Smartcard P1/P2 order flip',
      name: 'args_scardflip',
      desc: '',
      args: [],
    );
  }

  /// `Smartcard P1/P2 NumLock toggle`
  String get args_scardtoggle {
    return Intl.message(
      'Smartcard P1/P2 NumLock toggle',
      name: 'args_scardtoggle',
      desc: '',
      args: [],
    );
  }

  /// `COM ICCA card reader`
  String get args_reader {
    return Intl.message(
      'COM ICCA card reader',
      name: 'args_reader',
      desc: '',
      args: [],
    );
  }

  /// `With NumLock toggle`
  String get args_togglereader {
    return Intl.message(
      'With NumLock toggle',
      name: 'args_togglereader',
      desc: '',
      args: [],
    );
  }

  /// `Enable HID card readers`
  String get args_cardio {
    return Intl.message(
      'Enable HID card readers',
      name: 'args_cardio',
      desc: '',
      args: [],
    );
  }

  /// `Cardio P1/P2 order flip`
  String get args_cardioflip {
    return Intl.message(
      'Cardio P1/P2 order flip',
      name: 'args_cardioflip',
      desc: '',
      args: [],
    );
  }

  /// `Intel SDE automatic attach`
  String get args_sde {
    return Intl.message(
      'Intel SDE automatic attach',
      name: 'args_sde',
      desc: '',
      args: [],
    );
  }

  /// `Enable API`
  String get args_api {
    return Intl.message(
      'Enable API',
      name: 'args_api',
      desc: '',
      args: [],
    );
  }

  /// `Set API password`
  String get args_apipass {
    return Intl.message(
      'Set API password',
      name: 'args_apipass',
      desc: '',
      args: [],
    );
  }

  /// `Pretty JSON printing`
  String get args_apipretty {
    return Intl.message(
      'Pretty JSON printing',
      name: 'args_apipretty',
      desc: '',
      args: [],
    );
  }

  /// `Enable API logs (dec. perf.)`
  String get args_apilogging {
    return Intl.message(
      'Enable API logs (dec. perf.)',
      name: 'args_apilogging',
      desc: '',
      args: [],
    );
  }

  /// `Run API only on debug settings`
  String get args_apidebug {
    return Intl.message(
      'Run API only on debug settings',
      name: 'args_apidebug',
      desc: '',
      args: [],
    );
  }

  /// `Disable debug message logging`
  String get args_dbghookdisable {
    return Intl.message(
      'Disable debug message logging',
      name: 'args_dbghookdisable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}