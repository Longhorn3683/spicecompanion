This is a fork of [SpiceCompanion](https://github.com/LupinThidr/spicecompanion) project.

# Spice L3
A companion app to SpiceTools. This app allows for remotely
controlling and managing a running instance with the API enabled and
configured.

Powered by Flutter 3.7

## Features
- Support Android, iOS (include Mac with Apple Chip), HarmonyOS, Windows (other platform coming soon)
- Game status overview
- Quick Screenshot (Save to companion device)
- Manage and insert cards
- Scan cards using NFC (currently support Android and iOS)
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

## How to use with SpiceTools
In your batch file setup to for usage with SpiceTools, enable the `-api` and
`-apipass` parameters with your desired port and password, respectively. After
you've done that, add your server in the app, connect to it, and you're good
to go!

Example usage of the parameters:
`-api 1337 -apipass changeme`
