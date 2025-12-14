-- Custom Server Button Configuration
-- Edit the values below to connect to your server

return {
    -- Server IP address (no http:// or slashes)
    -- Example: "192.168.1.100" or "myserver.example.com"
    -- Note: Can be a server over the internet or a local (LAN) server
    IP = "192.168.1.100",

    -- Server port (default: 7777)
    -- Default is 7777 which most servers use. Leave as is unless you know your server uses a different port
    Port = 7777,

    -- Server password (optional: leave as "" if no password)
    -- Example: "MyPassword123"
    Password = "",

    -- Button text shown in menu
    -- Example: "My Server" or "Join Friend's Server"
    -- Default is "Custom Server Button"
    ButtonText = "Custom Server Button",

    -- Icon name (check icon-list.txt) (optional: leave as "" for no icon)
    -- Available icons in /Game/Textures/GUI/Icons/
    -- Examples: "icon_hackingdevice", "icon_keypad_white", "icon_objective_circle", "icon_suv_64", "icon_gate_64"
    -- Note: Invalid icon will just appear blank
    Icon = "icon_hackingdevice",

    -- Color of the button's text and icon
    -- Text color (0-255 RGB values)
    -- Default is Red = 42, Green = 255, Blue = 45
    TextColorRed = 42,
    TextColorGreen = 255,
    TextColorBlue = 45
}