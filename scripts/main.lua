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

local function DebugLog(message)
    if DEBUG then
        print("[Custom Server Button] " .. tostring(message) .. "\n")
    end
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
        DebugLog("ERROR: ButtonLabelText never initialized after 10 attempts")
        return
    end

    local labelText = button.ButtonLabelText
    if labelText and labelText:IsValid() then
        labelText:SetText(FText(BUTTON_TEXT))
        DebugLog("Button text set")
    else
        ExecuteWithDelay(100, function()
            TrySetButtonText(button, attempts + 1)
        end)
    end
end

local function CreateButton()
    DebugLog("CreateButton called")

    local Canvas = nil
    local allCanvas = FindAllOf("CanvasPanel")
    for _, canvas in pairs(allCanvas) do
        if canvas and canvas:IsValid() then
            local fullName = canvas:GetFullName()
            if fullName:find("W_MainMenu_Play") and fullName:find("CanvasPanel_42") and fullName:find("/Engine/Transient") then
                Canvas = canvas
                DebugLog("Canvas found: " .. fullName)
                break
            end
        end
    end

    if not Canvas then
        DebugLog("Canvas not found")
        return
    end

    local ButtonClass = StaticFindObject("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C")
    if not ButtonClass then
        DebugLog("ERROR: Button class not found")
        return
    end

    local CustomServerBtn = StaticConstructObject(ButtonClass, Canvas, FName("Button_CustomServer"))
    if not CustomServerBtn or not CustomServerBtn:IsValid() then
        DebugLog("ERROR: Failed to create button")
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
    DebugLog("Button created successfully")
end

local function OnButtonClick(Context)
    local btn = Context:get()
    if btn and btn:IsValid() and btn:GetFullName():find("Button_CustomServer") then
        DebugLog("Custom button clicked")

        local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
        local Master = FindFirstOf("W_MainMenu_Master_C")
        local ServerBrowser = Master.W_ServerBrowser

        if ServerBrowser and ServerBrowser:IsValid() then
            local cmd = BuildConnectCommand()
            DebugLog("Executing: " .. cmd)
            KismetSystemLibrary:ExecuteConsoleCommand(ServerBrowser, cmd, nil)
        else
            DebugLog("ERROR: ServerBrowser not found")
        end
    end
end

RegisterLoadMapPostHook(function(Engine, WorldContext, URL, PendingGame, Error)
    local persistentLevel = UEHelpers.GetPersistentLevel()
    if persistentLevel:IsValid() then
        local levelFullName = persistentLevel:GetFullName()
        DebugLog("Map loaded: " .. levelFullName)

        if levelFullName:find("MainMenu") then
            if not hookRegistered then
                RegisterHook("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C:BndEvt__AbioticButton_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature", OnButtonClick)
                hookRegistered = true
            end

            DebugLog("MainMenu loaded, creating button")
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
        DebugLog("Fallback initialization triggered")
        RegisterHook("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C:BndEvt__AbioticButton_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature", OnButtonClick)
        hookRegistered = true

        ExecuteInGameThread(function()
            CreateButton()
        end)
    end
end)

DebugLog("Mod loaded")