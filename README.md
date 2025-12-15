# Custom Server Button

A UE4SS mod for Abiotic Factor that adds a customizable button to the main menu for quickly connecting to a specific server.

## What it does

Adds a button to the main menu that connects to a server you specify. Useful for quickly joining a friend's server, your own dedicated server, or any server you play on regularly.

The button is fully customizable - you can set the text, icon, and color to whatever you want.

## Installation

1. Install [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) if you haven't already
2. Extract this mod folder to `Abiotic Factor/AbioticFactor/Binaries/Win64/Mods/`
3. Make sure `enabled.txt` exists in the mod folder
4. Edit `config.lua` with your server details

## Configuration

Edit `config.lua` to set your server connection and customize the button appearance.

### Server Connection

```lua
IP = "192.168.1.100"  -- Server IP or hostname
Port = 7777           -- Server port (default: 7777)
Password = ""         -- Server password (leave empty if none)
```

Works with both LAN servers and internet servers.

### Button Customization

```lua
ButtonText = "My Server"  -- Text displayed on the button
Icon = "icon_hackingdevice"  -- Icon name (see icon-list.txt for options)
```

Leave `Icon` as an empty string (`""`) if you don't want an icon.

### Button Color

```lua
TextColor = {
    R = 42,
    G = 255,
    B = 45
}
```

RGB values are 0-255. Default is bright green.

## Technical Notes

- Uses `RegisterLoadMapPostHook` to detect main menu load
- Button is created via `StaticConstructObject` and added to the canvas
- Includes retry mechanism for button text initialization
- Hooks button click events to execute the connection command

## Requirements

- UE4SS 3.x
- Abiotic Factor version 1.1+
