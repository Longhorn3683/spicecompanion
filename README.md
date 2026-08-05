This is a fork of [SpiceCompanion](https://github.com/LupinThidr/spicecompanion) project.

# Spice L3
A companion app to SpiceTools. This app allows for remotely
controlling and managing a running instance with the API enabled and
configured.

Powered by Flutter 3.7.

## Features
- Support various platforms
- Manage and insert cards
- Scan cards using NFC
- Virtual Keypad
- Live Patches: Enable/Disable hex edits on the fly
- Online patch list download
- Tons of preset patches, ability to add custom ones
- View/Override/Press Buttons/Analogs/Lights on the fly
- Game status overview
- Exit your games remotely
- Dark mode

## Requirements
- SpiceTools
- Android 4.4+
- NFC (optional)

## How to use with SpiceTools
In your batch file setup to for usage with SpiceTools, enable the `-api` and
`-apipass` parameters with your desired port and password, respectively. After
you've done that, add your server in the app, connect to it, and you're good
to go!

Example usage of the parameters:
`-api 1337 -apipass changeme`
