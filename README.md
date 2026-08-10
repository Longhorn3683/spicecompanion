This is a fork of [SpiceCompanion](https://github.com/LupinThidr/spicecompanion) project.

# Spice L3
A companion app to SpiceTools. This app allows for remotely
controlling and managing a running instance with the API enabled and
configured.

Powered by Flutter 3.7

## Features
- Support Android, iOS (include Mac with Apple Chip), HarmonyOS, Windows (other platform coming soon)
- Game status overview
- Quick Screenshot (Save to companion device, different from PrtScr on spice2x)
- Manage and insert cards
- Scan cards using NFC (Android only)
- Virtual Keypad
- Live Patches: Enable/Disable hex edits on the fly
- Online patch list download
- Tons of preset patches, ability to add custom ones
- View/Override/Press Buttons/Analogs/Lights on the fly
- Exit your games remotely
- Dark mode

## Requirements
- SpiceTools
### OS
- Android 5.0+
- iOS 15.0+
- HarmonyOS 5.0.0+
- Windows 10+

## iOS and HarmonyOS
iOS and HarmonyOS packages were unsigned. Use sideload tools to install.
- iOS: [Sideloadly](https://sideloadly.io)
- HarmonyOS: [小白调试助手](https://github.com/likuai2010/auto-installer)
- macOS (arm64): [PlayCover](https://playcover.io) (remember to remove PlayTools).

## How to use with spice2x
1. Open spicecfg.exe
2. Click 'Options'
3. Click 'API'
4. Set 'API TCP Port' ('API Password' is optional)
5. Restart spicecfg.exe

If firewall window appears, please click 'Allow'.

After
you've done that, add your server in the app, connect to it, and you're good
to go!

You can also use `-api` and
`-apipass` parameters with your desired port and password, respectively. 

Example usage of the parameters:
`-api 1337 -apipass changeme`
