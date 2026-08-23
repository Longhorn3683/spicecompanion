This is a fork of [SpiceCompanion](https://github.com/LupinThidr/spicecompanion) project.

# Spice L3
A companion app to spice2x. This app allows for remotely
controlling and managing a running instance with the API enabled and
configured.

Powered by Flutter 3.7

## Features
- Support Android, iOS, HarmonyOS, Windows, macOS
- Game status overview
- Quick Screenshot (Save to companion device, different from PrtScr on spice2x)
- Screen mirror and IIDX LDJ LED Ticker display
- Virtual Keypad
- Manage and insert cards
- Scan cards using NFC (Android only)
- Live Patches: Enable/Disable hex edits on the fly
- Online patch list download
- Tons of preset patches, ability to add custom ones
- View/Override/Press Buttons/Analogs/Lights on the fly
- Exit your games remotely
- Dark mode

## Requirements
- spice2x
### OS
- Android 5.0+
- iOS 15.0+
- HarmonyOS 5.0.0+
- Windows 10+
- macOS 10.14+

## iOS, macOS and HarmonyOS
iOS, macOS and HarmonyOS packages were unsigned.
- iOS: [Sideloadly](https://sideloadly.io)
- HarmonyOS: [小白调试助手](https://github.com/likuai2010/auto-installer)

## macOS (Intel), Linux and Web
Currently no plan to support

## Known issues
- NFC scan not available on iOS and HarmonyOS
- Vibration not available on HarmonyOS
- No H264 support in screen mirror, and touch is not smooth (Please use [substream](https://github.com/spice2x/substream))

## How to use with spice2x
1. Open spicecfg.exe
2. Click 'Options'
3. Click 'API'
4. Set 'API TCP Port' ('API Password' is optional)
5. Restart spicecfg.exe

If firewall window appears, please click 'Allow'.

After you've done that, add your server in the app, connect to it, and you're good to go!

You can also use `-api` and `-apipass` parameters with your desired port and password, respectively. 

Example usage of the parameters: `-api 1337 -apipass changeme`

## IIDX LDJ LED Ticker Font
- [JetBrains Mono (under SIL Open Font License 1.1)](https://github.com/JetBrains/JetBrainsMono)