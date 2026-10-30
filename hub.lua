-- TWKS // Timon Hub - Ultimate Advanced Suite (Classic Stable Fly Edition)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

pcall(function()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "TimonHub_Ultimate" or gui.Name == "TimonHub_MobileButtons" then
            gui:Destroy()
        end
    end
end)

local DrawingLib = (typeof(Drawing) == "table" and Drawing) or (typeof(Drawing) == "function" and Drawing) or nil
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
    end
end)

local AssistActive = false
local AssistKey = Enum.KeyCode.E
local ToggleKey = Enum.KeyCode.LeftAlt
local AssistSmooth = 0.5
local TargetPartName = "Head"
local FOVEnabled = true
local FOVRadius = 120

local TouchAssistActive = false
local TouchAssistSmooth = 0.5
local TouchAssistFOV = 150
local LockedTarget = nil

local VisualsEnabled = false
local VisualsTransparency = 0.5
local VisualsMap = {}

local HitboxEnabled = false
local HitboxSize = 4
local HitboxTransparency = 0.5
local HitboxTargetName = "HumanoidRootPart"
local HitboxKey = Enum.KeyCode.Q
local OriginalSizes = {}

local InvisFlingEnabled = false
local AntiFlingEnabled = false
local HamsterCoins = 0

local WalkSpeedEnabled = false
local CustomWalkSpeed = 16
local JumpPowerEnabled = false
local CustomJumpPower = 50

-- Возвращенный стабильный модуль Fly
local FlyEnabled = false
local FlySpeed = 50
local FlyKey = Enum.KeyCode.F
local flying = false
local flyConnection = nil
local controlModule = nil
local bg, bv

pcall(function()
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        local playerModule = playerScripts:FindFirstChild("PlayerModule")
        if playerModule then
            controlModule = require(playerModule:FindFirstChild("ControlModule"))
        end
    end
end)

local ConfigFolder = "TimonHub_Configs"
local AutoLoadFileName = ConfigFolder .. "/autoload.json"
local CurrentConfigName = "default"
local AutoLoadEnabled = false

pcall(function()
    if makefolder and not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TimonHub_Ultimate"
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
ScreenGui.ResetOnSpawn = false

local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "TimonHub_MobileButtons"
pcall(function()
    if gethui then
        MobileGui.Parent = gethui()
    else
        MobileGui.Parent = game:GetService("CoreGui")
    end
end)
if not MobileGui.Parent then
    MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
MobileGui.ResetOnSpawn = false

local function createMobileButton(pos, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 115, 0, 42)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(235, 205, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.Active = true
    btn.Draggable = true
    btn.Parent = MobileGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(190, 90, 255)
    stroke.Transparency = 0.25
    stroke.Thickness = 1.8
    stroke.Parent = btn
    return btn
end

local ToggleUIMobileBtn = createMobileButton(UDim2.new(0, 20, 0, 20), "⚡ MENU")
local MobileAimToggleBtn = createMobileButton(UDim2.new(0, 145, 0, 20), "Mob.Aim: OFF")
local FlyMobileBtn = createMobileButton(UDim2.new(0, 270, 0, 20), "Fly: OFF")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 450)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 5, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(170, 70, 255)
MainStroke.Transparency = 0.15
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local NeonGlow = Instance.new("Frame")
NeonGlow.Size = UDim2.new(1, 0, 0, 3)
NeonGlow.BackgroundColor3 = Color3.fromRGB(220, 130, 255)
NeonGlow.BorderSizePixel = 0
NeonGlow.Parent = MainFrame

ToggleUIMobileBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundColor3 = Color3.fromRGB(14, 8, 24)
Header.BackgroundTransparency = 0.35
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = Color3.fromRGB(14, 8, 24)
HeaderCover.BackgroundTransparency = 0.35
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 24, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TIMON HUB  ✦  ULTIMATE SUITE v4.3"
Title.TextColor3 = Color3.fromRGB(250, 230, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 175, 1, -70)
Sidebar.Position = UDim2.new(0, 12, 0, 62)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -205, 1, -70)
ContentArea.Position = UDim2.new(0, 195, 0, 62)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local function createTabContent()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.CanvasSize = UDim2.new(0, 0, 0, 850)
    sf.ScrollBarThickness = 3
    sf.Visible = false
    sf.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = sf
    return sf
end

local CombatTab = createTabContent()
local ESPTab = createTabContent()
local HitboxTab = createTabContent()
local PlayerTab = createTabContent()
local FlingTab = createTabContent()
local HamsterTab = createTabContent()
local SettingsTab = createTabContent()
CombatTab.Visible = true

local function createTabButton(name, targetTab)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(16, 9, 26)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(210, 185, 245)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(110, 50, 160)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.2
    stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        CombatTab.Visible = false
        ESPTab.Visible = false
        HitboxTab.Visible = false
        PlayerTab.Visible = false
        FlingTab.Visible = false
        HamsterTab.Visible = false
        SettingsTab.Visible = false
        targetTab.Visible = true
    end)
    return btn
end

createTabButton("Combat", CombatTab)
createTabButton("ESP & Visuals", ESPTab)
createTabButton("Hitbox", HitboxTab)
createTabButton("Player", PlayerTab)
createTabButton("Fling & Anti", FlingTab)
createTabButton("HamsterCombat", HamsterTab)
createTabButton("Settings", SettingsTab)

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(175, 140, 220)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createActionBtn(parent, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(16, 9, 26)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(240, 220, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(110, 50, 160)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.2
    stroke.Parent = btn
    return btn
end

local function createInputBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 42)
    box.BackgroundColor3 = Color3.fromRGB(16, 9, 26)
    box.BackgroundTransparency = 0.3
    box.TextColor3 = Color3.fromRGB(240, 220, 255)
    box.PlaceholderColor3 = Color3.fromRGB(140, 110, 185)
    box.TextSize = 13
    box.Font = Enum.Font.GothamMedium
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(110, 50, 160)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.2
    stroke.Parent = box
    return box
end

-- === COMBAT TAB ===
createLabel(CombatTab, "ОСНОВНОЙ МОДУЛЬ (PC)")
local ToggleBtn = createActionBtn(CombatTab, "Assist System: OFF")
local KeyBindBtn = createActionBtn(CombatTab, "Bind Key: E")

createLabel(CombatTab, "МОБИЛЬНЫЙ МОДУЛЬ (MOBILE)")
local MobileAimToggle = createActionBtn(CombatTab, "Mobile Assist: OFF")
local MobileAimSmoothInput = createInputBox(CombatTab, "Mobile Smooth (например: 0.5)")
local MobileAimFOVInput = createInputBox(CombatTab, "Mobile FOV (например: 150)")

createLabel(CombatTab, "ВЫБОР ЧАСТИ ТЕЛА")
local PartDropdownBtn = createActionBtn(CombatTab, "Target: Head")
local PartFrame = Instance.new("Frame")
PartFrame.Size = UDim2.new(1, 0, 0, 140)
PartFrame.BackgroundColor3 = Color3.fromRGB(12, 6, 20)
PartFrame.BackgroundTransparency = 0.2
PartFrame.Visible = false
PartFrame.Parent = CombatTab
local PartLayout = Instance.new("UIListLayout")
PartLayout.Padding = UDim.new(0, 5)
PartLayout.Parent = PartFrame

local parts = {
    {Name = "Голова (Head)", Part = "Head"},
    {Name = "Торс (Torso)", Part = "UpperTorso"},
    {Name = "Руки (Arms)", Part = "LeftLowerArm"},
    {Name = "Ноги (Legs)", Part = "LeftLowerLeg"}
}
for _, p in ipairs(parts) do
    local b = createActionBtn(PartFrame, p.Name)
    b.MouseButton1Click:Connect(function()
        TargetPartName = p.Part
        PartDropdownBtn.Text = "Target: " .. p.Name
        PartFrame.Visible = false
    end)
end

createLabel(CombatTab, "ПЛАВНОСТЬ И FOV")
local SmoothInput = createInputBox(CombatTab, "Smooth (например: 0.5)")
local FOVToggleBtn = createActionBtn(CombatTab, "FOV Circle: ON")
local FOVRadiusInput = createInputBox(CombatTab, "FOV Radius (например: 120)")

-- === ESP TAB ===
createLabel(ESPTab, "ПОДСВЕТКА ИГРОКОВ (ESP)")
local ESPToggleBtn = createActionBtn(ESPTab, "Visuals: OFF")
local ESPTransInput = createInputBox(ESPTab, "Fill Transparency (например: 0.5)")

-- === HITBOX TAB ===
createLabel(HitboxTab, "УВЕЛИЧЕНИЕ ХИТБОКСОВ")
local HitboxToggle = createActionBtn(HitboxTab, "Hitbox Extender: OFF")
local HitboxKeyBindBtn = createActionBtn(HitboxTab, "Hitbox Bind: Q")

createLabel(HitboxTab, "ВЫБОР ЧАСТИ ДЛЯ ХИТБОКСА")
local HitboxPartBtn = createActionBtn(HitboxTab, "Hitbox Part: RootPart")
local HitboxPartContainer = Instance.new("Frame")
HitboxPartContainer.Size = UDim2.new(1, 0, 0, 160)
HitboxPartContainer.BackgroundTransparency = 1
HitboxPartContainer.Visible = false
HitboxPartContainer.Parent = HitboxTab

local HitboxPartListLayout = Instance.new("UIListLayout")
HitboxPartListLayout.Padding = UDim.new(0, 5)
HitboxPartListLayout.Parent = HitboxPartContainer

local hitboxParts = {
    {Name = "Все тело (RootPart)", Part = "HumanoidRootPart"},
    {Name = "Голова (Head)", Part = "Head"},
    {Name = "Торс (Torso)", Part = "UpperTorso"},
    {Name = "Руки/Ноги (LeftLowerArm)", Part = "LeftLowerArm"}
}
for _, hp in ipairs(hitboxParts) do
    local b = createActionBtn(HitboxPartContainer, hp.Name)
    b.MouseButton1Click:Connect(function()
        HitboxTargetName = hp.Part
        HitboxPartBtn.Text = "Hitbox Part: " .. hp.Name
        HitboxPartContainer.Visible = false
    end)
end

HitboxPartBtn.MouseButton1Click:Connect(function()
    HitboxPartContainer.Visible = not HitboxPartContainer.Visible
end)

createLabel(HitboxTab, "НАСТРОЙКИ ХИТБОКСА")
local HitboxSizeInput = createInputBox(HitboxTab, "Hitbox Size (например: 4)")
local HitboxTransInput = createInputBox(HitboxTab, "Hitbox Transparency (например: 0.5)")

-- === PLAYER TAB ===
createLabel(PlayerTab, "СКОРОСТЬ И ПРЫЖОК")
local SpeedToggle = createActionBtn(PlayerTab, "WalkSpeed: OFF")
local SpeedInput = createInputBox(PlayerTab, "Speed Value (например: 50)")
local JumpToggle = createActionBtn(PlayerTab, "JumpPower: OFF")
local JumpInput = createInputBox(PlayerTab, "Jump Value (например: 100)")

createLabel(PlayerTab, "ПОЛЕТ (FLY)")
local FlyToggle = createActionBtn(PlayerTab, "Fly: OFF")
local FlyKeyBindBtn = createActionBtn(PlayerTab, "Fly Bind: F")
local FlySpeedInput = createInputBox(PlayerTab, "Fly Speed (например: 50)")

-- === FLING & ANTI-FLING TAB ===
createLabel(FlingTab, "МОДУЛЬ РАСКИДА (FLING)")
local InvisFlingToggle = createActionBtn(FlingTab, "Invis Fling: OFF")
local AntiFlingToggle = createActionBtn(FlingTab, "Anti Fling (No Collision): OFF")

-- === HAMSTER COMBAT TAB ===
createLabel(HamsterTab, "КЛИКЕР HAMSTER COIN")

local HamsterCounterLabel = Instance.new("TextLabel")
HamsterCounterLabel.Size = UDim2.new(0, 200, 0, 30)
HamsterCounterLabel.Position = UDim2.new(1, -210, 0, 12)
HamsterCounterLabel.BackgroundTransparency = 1
HamsterCounterLabel.Text = "Hamster Coins: 0"
HamsterCounterLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
HamsterCounterLabel.TextSize = 14
HamsterCounterLabel.Font = Enum.Font.GothamBold
HamsterCounterLabel.TextXAlignment = Enum.TextXAlignment.Right
HamsterCounterLabel.Parent = Header

local ClickerContainer = Instance.new("Frame")
ClickerContainer.Size = UDim2.new(1, 0, 1, -30)
ClickerContainer.BackgroundTransparency = 1
ClickerContainer.Parent = HamsterTab

local HamsterClickBtn = Instance.new("TextButton")
HamsterClickBtn.Size = UDim2.new(0, 190, 0, 190)
HamsterClickBtn.Position = UDim2.new(0.5, -95, 0.5, -95)
HamsterClickBtn.BackgroundColor3 = Color3.fromRGB(18, 10, 28)
HamsterClickBtn.BackgroundTransparency = 0.2
HamsterClickBtn.Text = "🐹"
HamsterClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HamsterClickBtn.TextSize = 68
HamsterClickBtn.Font = Enum.Font.GothamBold
HamsterClickBtn.Parent = ClickerContainer

local HamsterCorner = Instance.new("UICorner")
HamsterCorner.CornerRadius = UDim.new(1, 0)
HamsterCorner.Parent = HamsterClickBtn

local HamsterStroke = Instance.new("UIStroke")
HamsterStroke.Color = Color3.fromRGB(210, 130, 255)
HamsterStroke.Thickness = 3.5
HamsterStroke.Parent = HamsterClickBtn

HamsterClickBtn.MouseButton1Click:Connect(function()
    HamsterCoins = HamsterCoins + 1
    HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
    
    TweenService:Create(HamsterClickBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 165, 0, 165), Position = UDim2.new(0.5, -82.5, 0.5, -82.5)}):Play()
    task.delay(0.06, function()
        TweenService:Create(HamsterClickBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 190, 0, 190), Position = UDim2.new(0.5, -95, 0.5, -95)}):Play()
    end)
end)

-- === SETTINGS TAB ===
createLabel(SettingsTab, "МЕНЮ КОНФИГОВ")
local ConfigNameInput = createInputBox(SettingsTab, "Имя конфига (например: pro)")
local SaveConfigBtn = createActionBtn(SettingsTab, "Save Config")
local LoadConfigBtn = createActionBtn(SettingsTab, "Load Config")
local AutoLoadBtn = createActionBtn(SettingsTab, "Auto-Load: OFF")

createLabel(SettingsTab, "УПРАВЛЕНИЕ СКРИПТОМ")
local UnloadBtn = createActionBtn(SettingsTab, "Unload Script (Full Delete)")
UnloadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)

local function saveConfig(name)
    if not writefile then return end
    if name == "" then name = "default" end
    CurrentConfigName = name
    
    local configData = {
        AssistActive = AssistActive,
        AssistKey = AssistKey and AssistKey.Name or "E",
        AssistSmooth = AssistSmooth,
        TargetPartName = TargetPartName,
        FOVEnabled = FOVEnabled,
        FOVRadius = FOVRadius,
        TouchAssistActive = TouchAssistActive,
        TouchAssistSmooth = TouchAssistSmooth,
        TouchAssistFOV = TouchAssistFOV,
        VisualsEnabled = VisualsEnabled,
        VisualsTransparency = VisualsTransparency,
        HitboxEnabled = HitboxEnabled,
        HitboxKey = HitboxKey and HitboxKey.Name or "Q",
        HitboxTargetName = HitboxTargetName,
        HitboxSize = HitboxSize,
        HitboxTransparency = HitboxTransparency,
        InvisFlingEnabled = InvisFlingEnabled,
        AntiFlingEnabled = AntiFlingEnabled,
        HamsterCoins = HamsterCoins,
        WalkSpeedEnabled = WalkSpeedEnabled,
        CustomWalkSpeed = CustomWalkSpeed,
        JumpPowerEnabled = JumpPowerEnabled,
        CustomJumpPower = CustomJumpPower,
        FlyEnabled = FlyEnabled,
        FlyKey = FlyKey and FlyKey.Name or "F",
        FlySpeed = FlySpeed
    }
    
    pcall(function()
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(configData))
    end)
end

local function loadConfig(name)
    if not readfile or not isfile then return end
    if name == "" then name = "default" end
    local path = ConfigFolder .. "/" .. name .. ".json"
    
    if isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success and data then
            AssistActive = data.AssistActive or false
            if data.AssistKey and Enum.KeyCode[data.AssistKey] then
                AssistKey = Enum.KeyCode[data.AssistKey]
                KeyBindBtn.Text = "Bind Key: " .. AssistKey.Name
            end
            AssistSmooth = data.AssistSmooth or 0.5
            TargetPartName = data.TargetPartName or "Head"
            FOVEnabled = data.FOVEnabled ~= false
            FOVRadius = data.FOVRadius or 120
            TouchAssistActive = data.TouchAssistActive or false
            TouchAssistSmooth = data.TouchAssistSmooth or 0.5
            TouchAssistFOV = data.TouchAssistFOV or 150
            VisualsEnabled = data.VisualsEnabled or false
            VisualsTransparency = data.VisualsTransparency or 0.5
            HitboxEnabled = data.HitboxEnabled or false
            if data.HitboxKey and Enum.KeyCode[data.HitboxKey] then
                HitboxKey = Enum.KeyCode[data.HitboxKey]
                HitboxKeyBindBtn.Text = "Hitbox Bind: " .. HitboxKey.Name
            end
            HitboxTargetName = data.HitboxTargetName or "HumanoidRootPart"
            HitboxSize = data.HitboxSize or 4
            HitboxTransparency = data.HitboxTransparency or 0.5
            InvisFlingEnabled = data.InvisFlingEnabled or false
            AntiFlingEnabled = data.AntiFlingEnabled or false
            HamsterCoins = data.HamsterCoins or 0
            HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
            WalkSpeedEnabled = data.WalkSpeedEnabled or false
            CustomWalkSpeed = data.CustomWalkSpeed or 16
            JumpPowerEnabled = data.JumpPowerEnabled or false
            CustomJumpPower = data.CustomJumpPower or 50
            FlyEnabled = data.FlyEnabled or false
            if data.FlyKey and Enum.KeyCode[data.FlyKey] then
                FlyKey = Enum.KeyCode[data.FlyKey]
                FlyKeyBindBtn.Text = "Fly Bind: " .. FlyKey.Name
            end
            FlySpeed = data.FlySpeed or 50

            ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
            ToggleBtn.TextColor3 = AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
            MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
            ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
            ESPToggleBtn.TextColor3 = VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
            HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            InvisFlingToggle.Text = InvisFlingEnabled and "Invis Fling: ON" or "Invis Fling: OFF"
            InvisFlingToggle.TextColor3 = InvisFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            AntiFlingToggle.Text = AntiFlingEnabled and "Anti Fling (No Collision): ON" or "Anti Fling (No Collision): OFF"
            AntiFlingToggle.TextColor3 = AntiFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
            SpeedToggle.TextColor3 = WalkSpeedEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
            JumpToggle.TextColor3 = JumpPowerEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
            FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
            PartDropdownBtn.Text = "Target: " .. TargetPartName
            HitboxPartBtn.Text = "Hitbox Part: " .. HitboxTargetName
            
            CurrentConfigName = name
        end
    end
end

pcall(function()
    if readfile and isfile and isfile(AutoLoadFileName) then
        local autoData = HttpService:JSONDecode(readfile(AutoLoadFileName))
        if autoData and autoData.Enabled and autoData.ConfigName then
            AutoLoadEnabled = true
            AutoLoadConfigName = autoData.ConfigName
            AutoLoadBtn.Text = "Auto-Load: " .. AutoLoadConfigName
            AutoLoadBtn.TextColor3 = Color3.fromRGB(160, 255, 120)
            loadConfig(AutoLoadConfigName)
        end
    end
end)

SaveConfigBtn.MouseButton1Click:Connect(function()
    local name = ConfigNameInput.Text
    if name == "" then name = "default" end
    saveConfig(name)
    SaveConfigBtn.Text = "Saved (" .. name .. ")!"
    task.delay(1.5, function() SaveConfigBtn.Text = "Save Config" end)
end)

LoadConfigBtn.MouseButton1Click:Connect(function()
    local name = ConfigNameInput.Text
    if name == "" then name = "default" end
    loadConfig(name)
    LoadConfigBtn.Text = "Loaded (" .. name .. ")!"
    task.delay(1.5, function() LoadConfigBtn.Text = "Load Config" end)
end)

AutoLoadBtn.MouseButton1Click:Connect(function()
    AutoLoadEnabled = not AutoLoadEnabled
    local name = ConfigNameInput.Text
    if name == "" then name = CurrentConfigName end
    
    if AutoLoadEnabled then
        AutoLoadConfigName = name
        AutoLoadBtn.Text = "Auto-Load: " .. name
        AutoLoadBtn.TextColor3 = Color3.fromRGB(160, 255, 120)
        if writefile then
            writefile(AutoLoadFileName, HttpService:JSONEncode({Enabled = true, ConfigName = name}))
        end
    else
        AutoLoadBtn.Text = "Auto-Load: OFF"
        AutoLoadBtn.TextColor3 = Color3.fromRGB(230, 210, 250)
        if writefile then
            writefile(AutoLoadFileName, HttpService:JSONEncode({Enabled = false, ConfigName = name}))
        end
    end
end)

local function autoSaveOnExit()
    if AutoLoadEnabled and AutoLoadConfigName ~= "" then
        saveConfig(AutoLoadConfigName)
    else
        saveConfig(CurrentConfigName)
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LocalPlayer then
        autoSaveOnExit()
    end
end)

UnloadBtn.MouseButton1Click:Connect(function()
    autoSaveOnExit()
    pcall(function()
        if FOVCircle then FOVCircle:Remove() end
    end)
    for _, data in pairs(VisualsMap) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ScreenGui:Destroy()
    MobileGui:Destroy()
end)

local bindingAimKey = false
local bindingFlyKey = false
local bindingHitboxKey = false

KeyBindBtn.MouseButton1Click:Connect(function()
    bindingAimKey = true
    bindingFlyKey = false
    bindingHitboxKey = false
    KeyBindBtn.Text = "Press any key..."
end)

FlyKeyBindBtn.MouseButton1Click:Connect(function()
    bindingFlyKey = true
    bindingAimKey = false
    bindingHitboxKey = false
    FlyKeyBindBtn.Text = "Press any key..."
end)

HitboxKeyBindBtn.MouseButton1Click:Connect(function()
    bindingHitboxKey = true
    bindingAimKey = false
    bindingFlyKey = false
    HitboxKeyBindBtn.Text = "Press any key..."
end)

-- НАДЕЖНЫЙ КЛАССИЧЕСКИЙ FLY ЧЕРЕЗ BODYVELOCITY И BODYGYRO (Работает во всех направлениях без багов)
local function toggleFlyFunc()
    FlyEnabled = not FlyEnabled
    FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if FlyEnabled then
        hum.PlatformStand = true
        
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end

        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        bv.Parent = hrp

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if flyConnection then flyConnection:Disconnect() end
                return
            end

            local currentHrp = LocalPlayer.Character.HumanoidRootPart
            local currentHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if currentHum then currentHum.PlatformStand = true end

            if bg and bv then
                bg.CFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)

                if controlModule then
                    local rawMove = controlModule:GetMoveVector()
                    if rawMove.Magnitude > 0 then
                        moveDir = (Camera.CFrame.RightVector * rawMove.X + Camera.CFrame.LookVector * rawMove.Z)
                    end
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end

                bv.Velocity = moveDir * FlySpeed
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end

        if hum then hum.PlatformStand = false end
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function toggleHitboxFunc()
    HitboxEnabled = not HitboxEnabled
    HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
    HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if not HitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, partName in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "LeftLowerArm"}) do
                    local part = p.Character:FindFirstChild(partName)
                    if part and OriginalSizes[part] then
                        part.Size = OriginalSizes[part]
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end

InvisFlingToggle.MouseButton1Click:Connect(function()
    InvisFlingEnabled = not InvisFlingEnabled
    InvisFlingToggle.Text = InvisFlingEnabled and "Invis Fling: ON" or "Invis Fling: OFF"
    InvisFlingToggle.TextColor3 = InvisFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

AntiFlingToggle.MouseButton1Click:Connect(function()
    AntiFlingEnabled = not AntiFlingEnabled
    AntiFlingToggle.Text = AntiFlingEnabled and "Anti Fling (No Collision): ON" or "Anti Fling (No Collision): OFF"
    AntiFlingToggle.TextColor3 = AntiFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if bindingAimKey then
            AssistKey = input.KeyCode
            KeyBindBtn.Text = "Bind Key: " .. AssistKey.Name
            bindingAimKey = false
            return
        end
        if bindingFlyKey then
            FlyKey = input.KeyCode
            FlyKeyBindBtn.Text = "Fly Bind: " .. FlyKey.Name
            bindingFlyKey = false
            return
        end
        if bindingHitboxKey then
            HitboxKey = input.KeyCode
            HitboxKeyBindBtn.Text = "Hitbox Bind: " .. HitboxKey.Name
            bindingHitboxKey = false
            return
        end

        if input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == FlyKey then
            toggleFlyFunc()
        elseif input.KeyCode == HitboxKey then
            toggleHitboxFunc()
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    AssistActive = not AssistActive
    ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
    ToggleBtn.TextColor3 = AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

MobileAimToggle.MouseButton1Click:Connect(function()
    TouchAssistActive = not TouchAssistActive
    MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
    MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
end)

MobileAimToggleBtn.MouseButton1Click:Connect(function()
    TouchAssistActive = not TouchAssistActive
    MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
    MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
end)

MobileAimSmoothInput.FocusLost:Connect(function()
    local val = tonumber(MobileAimSmoothInput.Text)
    if val then TouchAssistSmooth = math.clamp(val, 0, 0.99) end
end)

MobileAimFOVInput.FocusLost:Connect(function()
    local val = tonumber(MobileAimFOVInput.Text)
    if val then TouchAssistFOV = math.clamp(val, 10, 500) end
end)

PartDropdownBtn.MouseButton1Click:Connect(function()
    PartFrame.Visible = not PartFrame.Visible
end)

SmoothInput.FocusLost:Connect(function()
    local val = tonumber(SmoothInput.Text)
    if val then AssistSmooth = math.clamp(val, 0, 0.99) end
end)

FOVToggleBtn.MouseButton1Click:Connect(function()
    FOVEnabled = not FOVEnabled
    FOVToggleBtn.Text = FOVEnabled and "FOV Circle: ON" or "FOV Circle: OFF"
end)

FOVRadiusInput.FocusLost:Connect(function()
    local val = tonumber(FOVRadiusInput.Text)
    if val then FOVRadius = math.clamp(val, 10, 500) end
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    VisualsEnabled = not VisualsEnabled
    ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
    ESPToggleBtn.TextColor3 = VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if not VisualsEnabled then
        for _, data in pairs(VisualsMap) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end
        VisualsMap = {}
    end
end)

ESPTransInput.FocusLost:Connect(function()
    local val = tonumber(ESPTransInput.Text)
    if val then VisualsTransparency = math.clamp(val, 0, 1) end
end)

HitboxToggle.MouseButton1Click:Connect(toggleHitboxFunc)

HitboxSizeInput.FocusLost:Connect(function()
    local val = tonumber(HitboxSizeInput.Text)
    if val then HitboxSize = math.clamp(val, 1, 30) end
end)

HitboxTransInput.FocusLost:Connect(function()
    local val = tonumber(HitboxTransInput.Text)
    if val then HitboxTransparency = math.clamp(val, 0, 1) end
end)

SpeedToggle.MouseButton1Click:Connect(function()
    WalkSpeedEnabled = not WalkSpeedEnabled
    SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
    SpeedToggle.TextColor3 = WalkSpeedEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then CustomWalkSpeed = val end
end)

JumpToggle.MouseButton1Click:Connect(function()
    JumpPowerEnabled = not JumpPowerEnabled
    JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
    JumpToggle.TextColor3 = JumpPowerEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

JumpInput.FocusLost:Connect(function()
    local val = tonumber(JumpInput.Text)
    if val then CustomJumpPower = val end
end)

FlyToggle.MouseButton1Click:Connect(toggleFlyFunc)
FlyMobileBtn.MouseButton1Click:Connect(toggleFlyFunc)

FlySpeedInput.FocusLost:Connect(function()
    local val = tonumber(FlySpeedInput.Text)
    if val then FlySpeed = val end
end)

local function isAssistKeyDown()
    if TouchAssistActive then
        return true
    end
    if AssistKey and UserInputService:IsKeyDown(AssistKey) then
        return true
    end
    return false
end

local function getClosestTarget()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local refPos = TouchAssistActive and screenCenter or UserInputService:GetMouseLocation()
    local activeFOV = TouchAssistActive and TouchAssistFOV or FOVRadius

    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChildOfClass("Humanoid") then
        local humanoid = LockedTarget.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            if onScreen then
                local distToRef = (Vector2.new(screenPos.X, screenPos.Y) - refPos).Magnitude
                if distToRef <= (activeFOV * 1.5) then
                    return LockedTarget
                end
            end
        end
    end

    local closestTarget = nil
    local bestScore = math.huge
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(TargetPartName) or player.Character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distToRef = (Vector2.new(screenPos.X, screenPos.Y) - refPos).Magnitude
                    if distToRef <= activeFOV then
                        local distToMe = localHrp and (localHrp.Position - targetPart.Position).Magnitude or 0
                        local score = (distToRef * 0.7) + (distToMe * 0.3)
                        
                        if score < bestScore then
                            bestScore = score
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    LockedTarget = closestTarget
    return LockedTarget
end

RunService.RenderStepped:Connect(function()
    local activeFOV = TouchAssistActive and TouchAssistFOV or FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if FOVCircle then
        if FOVEnabled or TouchAssistActive then
            FOVCircle.Visible = true
            FOVCircle.Radius = activeFOV
            FOVCircle.Position = TouchAssistActive and screenCenter or UserInputService:GetMouseLocation()
        else
            FOVCircle.Visible = false
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not AntiFlingEnabled
                end
            end
        end
    end

    if InvisFlingEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = player.Character.HumanoidRootPart
                    if (hrp.Position - targetHrp.Position).Magnitude < 10 then
                        targetHrp.AssemblyLinearVelocity = Vector3.new(math.random(-80000, 80000), 150000, math.random(-80000, 80000))
                        targetHrp.AssemblyAngularVelocity = Vector3.new(math.random(-80000, 80000), 150000, math.random(-80000, 80000))
                    end
                end
            end
        end
    end

    if AssistActive and not TouchAssistActive and isAssistKeyDown() then
        local target = getClosestTarget()
        if target then
            local currentMouse = UserInputService:GetMouseLocation()
            local screenPos = Camera:WorldToViewportPoint(target.Position)
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            local moveDelta = targetPos - currentMouse
            if AssistSmooth > 0 then
                mousemoverel(moveDelta.X * (1 - AssistSmooth), moveDelta.Y * (1 - AssistSmooth))
            else
                mousemoverel(moveDelta.X, moveDelta.Y)
            end
        end
    elseif TouchAssistActive and isAssistKeyDown() then
        local target = getClosestTarget()
        if target then
            local currentCamCF = Camera.CFrame
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            if TouchAssistSmooth > 0 then
                Camera.CFrame = currentCamCF:Lerp(targetCF, 1 - TouchAssistSmooth)
            else
                Camera.CFrame = targetCF
            end
        end
    else
        LockedTarget = nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if VisualsEnabled then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local head = character and character:FindFirstChild("Head")
                
                if character and humanoid and head and humanoid.Health > 0 then
                    if not VisualsMap[player] then
                        VisualsMap[player] = {}
                    end
                    
                    if not VisualsMap[player].Highlight or VisualsMap[player].Highlight.Parent ~= character then
                        if VisualsMap[player].Highlight then VisualsMap[player].Highlight:Destroy() end
                        
                        local hl = Instance.new("Highlight")
                        hl.Adornee = character
                        hl.FillColor = Color3.fromRGB(170, 90, 255)
                        hl.OutlineColor = Color3.fromRGB(230, 180, 255)
                        hl.FillTransparency = VisualsTransparency
                        hl.OutlineTransparency = 0.1
                        hl.Parent = character
                        VisualsMap[player].Highlight = hl
                    else
                        VisualsMap[player].Highlight.FillTransparency = VisualsTransparency
                    end

                    if not VisualsMap[player].Billboard or VisualsMap[player].Billboard.Parent ~= head then
                        if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end

                        local bb = Instance.new("BillboardGui")
                        bb.Name = "TimonESP"
                        bb.Size = UDim2.new(0, 120, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = head
                        bb.Parent = head

                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Name = "NameLabel"
                        nameLabel.Size = UDim2.new(1, 0, 0, 20)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = Color3.fromRGB(245, 230, 255)
                        nameLabel.TextSize = 12
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.Parent = bb

                        local hpBg = Instance.new("Frame")
                        hpBg.Name = "HpBg"
                        hpBg.Size = UDim2.new(0.8, 0, 0, 6)
                        hpBg.Position = UDim2.new(0.1, 0, 0, 22)
                        hpBg.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
                        hpBg.BorderSizePixel = 0
                        hpBg.Parent = bb

                        local hpCorner = Instance.new("UICorner")
                        hpCorner.CornerRadius = UDim.new(1, 0)
                        hpCorner.Parent = hpBg

                        local hpBar = Instance.new("Frame")
                        hpBar.Name = "HpBar"
                        hpBar.Size = UDim2.new(1, 0, 1, 0)
                        hpBar.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
                        hpBar.BorderSizePixel = 0
                        hpBar.Parent = hpBg

                        local hpBarCorner = Instance.new("UICorner")
                        hpBarCorner.CornerRadius = UDim.new(1, 0)
                        hpBarCorner.Parent = hpBar

                        VisualsMap[player].Billboard = bb
                        VisualsMap[player].HpBar = hpBar
                    else
                        local hpBar = VisualsMap[player].HpBar
                        if hpBar then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            hpBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            hpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 80)
                        end
                    end
                else
                    if VisualsMap[player] then
                        if VisualsMap[player].Highlight then VisualsMap[player].Highlight:Destroy() end
                        if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end
                        VisualsMap[player] = nil
                    end
                end
            else
                if VisualsMap[player] then
                    if VisualsMap[player].Highlight then VisualsMap[player].Highlight:Destroy() end
                    if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end
                    VisualsMap[player] = nil
                end
            end
        end
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if WalkSpeedEnabled then hum.WalkSpeed = CustomWalkSpeed end
            if JumpPowerEnabled then hum.JumpPower = CustomJumpPower end
        end
    end

    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetPart = player.Character:FindFirstChild(HitboxTargetName)
                if targetPart then
                    if not OriginalSizes[targetPart] then OriginalSizes[targetPart] = targetPart.Size end
                    targetPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    targetPart.Transparency = HitboxTransparency
                    targetPart.Material = Enum.Material.Neon
                    targetPart.CanCollide = false
                end
            end
        end
    end
end)