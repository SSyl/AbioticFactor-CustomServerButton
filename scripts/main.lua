print("=== [Custom Server Button] MOD LOADING ===\n")

local UEHelpers = require("UEHelpers")
local DEBUG = true

local function DebugLog(message)
    if DEBUG then
        print("[Custom Server Button] " .. tostring(message) .. "\n")
    end
end

local function CreateButton()
    DebugLog("CreateButton called")


    local Canvas = nil
    local allCanvas = FindAllOf("CanvasPanel")
    for _, canvas in pairs(allCanvas) do
        if canvas and canvas:IsValid() then
            local fullName = canvas:GetFullName()
            if fullName:find("W_MainMenu_Play") and fullName:find("CanvasPanel_42") then
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

    local Slot = Canvas:AddChildToCanvas(CustomServerBtn)

    Slot:SetPosition({X = 125, Y = 700.0})
    Slot:SetAnchors({Min = {X = 0.0, Y = 1.0}, Max = {X = 0.0, Y = 1.0}})
    CustomServerBtn:SetVisibility(4)
    CustomServerBtn.ButtonLabelText:SetText(FText("Direct Connect"))

    DebugLog("Button created successfully")
end


RegisterHook("/Game/Blueprints/Widgets/MenuSystem/W_MainMenuButton.W_MainMenuButton_C:BndEvt__AbioticButton_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature", function(Context)
    local btn = Context:get()
    if btn and btn:IsValid() and btn:GetFullName():find("Button_CustomServer") then
        DebugLog("Custom button clicked")

        local KismetSystemLibrary = UEHelpers.GetKismetSystemLibrary()
        local Master = FindFirstOf("W_MainMenu_Master_C")
        local ServerBrowser = Master.W_ServerBrowser

        if ServerBrowser and ServerBrowser:IsValid() then
            local cmd = "open a.b.c.d:7777" --a.b.c.d as it causes the connection to timeout immediately. Good for testing.
            DebugLog("Executing: " .. cmd)
            KismetSystemLibrary:ExecuteConsoleCommand(ServerBrowser, cmd, nil)
        else
            DebugLog("ERROR: ServerBrowser not found")
        end
    end
end)

-- Create on startup
ExecuteWithDelay(1000, function()
    ExecuteInGameThread(function()
        CreateButton()
    end)
end)

DebugLog("Mod loaded")