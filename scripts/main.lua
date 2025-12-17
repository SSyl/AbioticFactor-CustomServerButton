print("=== [Custom Server Button] MOD LOADING ===\n")

local UEHelpers = require("UEHelpers")
local Config = require("../config")
local DEBUG = Config.Debug or false
local hookRegistered = false

local SERVER_IP = Config.IP or "127.0.0.1"
local SERVER_PORT = Config.Port or 7777
local SERVER_PASSWORD = Config.Password or ""
local BUTTON_TEXT = Config.ButtonText or "Custom Server Button"
local BUTTON_ICON = Config.Icon

local function ConvertColor(colorConfig, defaultR, defaultG, defaultB)
    if not colorConfig then
        return {R = defaultR / 255, G = defaultG / 255, B = defaultB / 255, A = 1.0}
    end
    return {
        R = (colorConfig.R or defaultR) / 255,
        G = (colorConfig.G or defaultG) / 255,
        B = (colorConfig.B or defaultB) / 255,
        A = 1.0
    }
end

local BUTTON_TEXT_COLOR = ConvertColor(Config.TextColor, 42, 255, 45)

local function Log(message, level)
    level = level or "info"

    if level == "debug" and not DEBUG then
        return
    end

    local prefix = ""
    if level == "error" then
        prefix = "ERROR: "
    elseif level == "warning" then
        prefix = "WARNING: "
    end

    print("[Custom Server Button] " .. prefix .. tostring(message) .. "\n")
end

local function BuildConnectCommand()
    local cmd = "open " .. SERVER_IP .. ":" .. tostring(SERVER_PORT)
    if SERVER_PASSWORD ~= "" then
        cmd = cmd .. "?pw=" .. SERVER_PASSWORD
    end

    return cmd
end

local function TrySetButtonText(button, attempts)
    attempts = attempts or 0
    if attempts > 10 then
        Log("ButtonLabelText never initialized after 10 attempts", "error")
        return
    end

    local labelText = button.ButtonLabelText
    if labelText and labelText:IsValid() then
        labelText:SetText(FText(BUTTON_TEXT))
        Log("Button text set", "debug")
    else
        ExecuteWithDelay(100, function()
            TrySetButtonText(button, attempts + 1)
        end)
    end
end

local function CreateButton()
    Log("CreateButton called", "debug")

    local Canvas = nil
    local allCanvas = FindAllOf("CanvasPanel")
    for _, canvas in pairs(allCanvas) do
        if canvas and canvas:IsValid() then
            local fullName = canvas:GetFullName()
            if fullName:find("W_MainMenu_Play") and fullName:find("CanvasPanel_42") and fullName:find("/Engine/Transient") then
                Canvas = canvas
                Log("Canvas found: " .. fullName, "debug")
                break
            end
        end
    end

    if not Canvas then
        Log("Canvas not found", "debug")
        return
    end

    local ButtonClass = StaticFindObject("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C")
    if not ButtonClass then
        Log("Button class not found", "error")
        return
    end

    local CustomServerBtn = StaticConstructObject(ButtonClass, Canvas, FName("Button_CustomServer"))
    if not CustomServerBtn or not CustomServerBtn:IsValid() then
        Log("Failed to create button", "error")
        return
    end

    if BUTTON_ICON and BUTTON_ICON ~= "" then
        local iconTexture = StaticFindObject("/Game/Textures/GUI/Icons/" .. BUTTON_ICON .. "." .. BUTTON_ICON)
        if iconTexture then
            CustomServerBtn.Icon = iconTexture
        end
    end

    CustomServerBtn.RenderTransform.Scale = {X = 0.8, Y = 0.8}
    CustomServerBtn.DefaultTextColor = BUTTON_TEXT_COLOR

    local Slot = Canvas:AddChildToCanvas(CustomServerBtn)
    Slot:SetPosition({X = 155, Y = 680.0})
    Slot:SetAnchors({Min = {X = 0.0, Y = 1.0}, Max = {X = 0.0, Y = 1.0}})

    TrySetButtonText(CustomServerBtn)
    Log("Button created successfully", "debug")
end

local function OnButtonClick(Context)
    local btn = Context:get()
    if btn and btn:IsValid() and btn:GetFullName():find("Button_CustomServer") then
        Log("Custom button clicked", "debug")

        local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
        local Master = FindFirstOf("W_MainMenu_Master_C")
        local ServerBrowser = Master.W_ServerBrowser

        if ServerBrowser and ServerBrowser:IsValid() then
            local cmd = BuildConnectCommand()
            Log("Executing: " .. cmd, "debug")
            KismetSystemLibrary:ExecuteConsoleCommand(ServerBrowser, cmd, nil)
        else
            Log("ServerBrowser not found", "error")
        end
    end
end

RegisterLoadMapPostHook(function(Engine, WorldContext, URL, PendingGame, Error)
    local persistentLevel = UEHelpers.GetPersistentLevel()
    if persistentLevel:IsValid() then
        local levelFullName = persistentLevel:GetFullName()
        Log("Map loaded: " .. levelFullName, "debug")

        if levelFullName:find("MainMenu") then
            if not hookRegistered then
                RegisterHook("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C:BndEvt__AbioticButton_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature", OnButtonClick)
                hookRegistered = true
            end

            Log("MainMenu loaded, creating button", "debug")
            ExecuteWithDelay(500, function()
                ExecuteInGameThread(function()
                    CreateButton()
                end)
            end)
        end
    end
end)

-- Fallback initialization if hook doesn't fire
ExecuteWithDelay(3000, function()
    if not hookRegistered then
        Log("Fallback initialization triggered", "debug")
        RegisterHook("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C:BndEvt__AbioticButton_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature", OnButtonClick)
        hookRegistered = true

        ExecuteInGameThread(function()
            CreateButton()
        end)
    end
end)

Log("Mod loaded", "debug")