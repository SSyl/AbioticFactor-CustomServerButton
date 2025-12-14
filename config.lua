-- Custom Server Button Configuration
-- Edit the values below to connect to your server

return {
    -- Server IP address (no http:// or slashes)
    -- Example: "192.168.1.100" or "myserver.example.com"
    IP = "192.168.1.100",
    
    -- Server port (default: 7777)
    -- Leave as 7777 unless your server uses a different port
    Port = 7777,
    
    -- Server password (optional: leave as "" if no password)
    -- Example: "MyPassword123"
    Password = "",
    
    -- Button text shown in menu
    -- Example: "My Server" or "Join Friends"
    ButtonText = "Custom Server Button",

    -- Icon path (optional: leave as "" for no icon)
    -- Available icons in /Game/Textures/GUI/Icons/
    -- Examples: "icon_hackingdevice", "icon_objective_circle", "icon_suv_64", "icon_gate_64"
    Icon = "icon_hackingdevice"
}