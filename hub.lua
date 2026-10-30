-- TWKS // Timon Hub - Ultimate Advanced Suite (Configs & Auto-Load Edition)
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
local AssistMouseType = nil
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
local VisualsTransparency = 0.7
local VisualsMap = {}

local HitboxEnabled = false
local HitboxSize = 4
local HitboxTransparency = 0.5
local OriginalSizes = {}

local HamsterCoins = 0

local WalkSpeedEnabled = false
local CustomWalkSpeed = 16
local JumpPowerEnabled = false
local CustomJumpPower = 50
local FlyEnabled = false
local FlySpeed = 50
local flying = false
local bodyGyro, bodyVelocity

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
    btn.Size = UDim2.new(0, 110, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    btn.TextColor3 = Color3.fromRGB(220, 180, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.Active = true
    btn.Draggable = true
    btn.Parent = MobileGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(160, 70, 240)
    stroke.Thickness = 1.8
    stroke.Parent = btn
    return btn
end

local ToggleUIMobileBtn = createMobileButton(UDim2.new(0, 20, 0, 20), "⚡ MENU")
local MobileAimToggleBtn = createMobileButton(UDim2.new(0, 135, 0, 20), "Mob.Aim: OFF")
local FlyMobileBtn = createMobileButton(UDim2.new(0, 250, 0, 20), "Fly: OFF")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 430)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(160, 70, 240)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local NeonGlow = Instance.new("Frame")
NeonGlow.Size = UDim2.new(1, 0, 0, 3)
NeonGlow.BackgroundColor3 = Color3.fromRGB(210, 130, 255)
NeonGlow.BorderSizePixel = 0
NeonGlow.Parent = MainFrame

ToggleUIMobileBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TIMON HUB  ✦  ULTIMATE SUITE"
Title.TextColor3 = Color3.fromRGB(240, 215, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 160, 1, -65)
Sidebar.Position = UDim2.new(0, 12, 0, 58)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -190, 1, -65)
ContentArea.Position = UDim2.new(0, 180, 0, 58)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local function createTabContent()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.CanvasSize = UDim2.new(0, 0, 0, 650)
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
local HamsterTab = createTabContent()
local SettingsTab = createTabContent()
CombatTab.Visible = true

local function createTabButton(name, targetTab)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
    btn.TextColor3 = Color3.fromRGB(200, 175, 235)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 40, 120)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        CombatTab.Visible = false
        ESPTab.Visible = false
        HitboxTab.Visible = false
        PlayerTab.Visible = false
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
createTabButton("HamsterCombat", HamsterTab)
createTabButton("Settings", SettingsTab)

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(160, 130, 205)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createActionBtn(parent, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
    btn.TextColor3 = Color3.fromRGB(230, 210, 250)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 40, 120)
    stroke.Thickness = 1
    stroke.Parent = btn
    return btn
end

local function createInputBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 38)
    box.BackgroundColor3 = Color3.fromRGB(18, 12, 28)
    box.TextColor3 = Color3.fromRGB(230, 210, 250)
    box.PlaceholderColor3 = Color3.fromRGB(130, 105, 165)
    box.TextSize = 13
    box.Font = Enum.Font.GothamMedium
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 40, 120)
    stroke.Thickness = 1
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
PartFrame.BackgroundColor3 = Color3.fromRGB(14, 8, 22)
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
createLabel(ESPTab, "ПОДСВЕТКА ИГРОКОВ")
local ESPToggleBtn = createActionBtn(ESPTab, "Visuals: OFF")
local ESPTransInput = createInputBox(ESPTab, "Fill Transparency (например: 0.7)")

-- === HITBOX TAB ===
createLabel(HitboxTab, "УВЕЛИЧЕНИЕ ХИТБОКСОВ")
local HitboxToggle = createActionBtn(HitboxTab, "Hitbox Extender: OFF")
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
local FlySpeedInput = createInputBox(PlayerTab, "Fly Speed (например: 50)")

-- === HAMSTER COMBAT TAB ===
createLabel(HamsterTab, "КЛИКЕР HAMSTER COIN")

local HamsterCounterLabel = Instance.new("TextLabel")
HamsterCounterLabel.Size = UDim2.new(0, 200, 0, 30)
HamsterCounterLabel.Position = UDim2.new(1, -210, 0, 10)
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
HamsterClickBtn.BackgroundColor3 = Color3.fromRGB(22, 14, 35)
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

-- === SETTINGS TAB (МЕНЮ КОНФИГОВ) ===
createLabel(SettingsTab, "МЕНЮ КОНФИГОВ")
local ConfigNameInput = createInputBox(SettingsTab, "Имя конфига (например: pro)")
local SaveConfigBtn = createActionBtn(SettingsTab, "Save Config")
local LoadConfigBtn = createActionBtn(SettingsTab, "Load Config")
local AutoLoadBtn = createActionBtn(SettingsTab, "Auto-Load: OFF")

createLabel(SettingsTab, "УПРАВЛЕНИЕ СКРИПТОМ")
local UnloadBtn = createActionBtn(SettingsTab, "Unload Script (Full Delete)")
UnloadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)

-- Функция сохранения конфига
local function saveConfig(name)
    if not writefile then return end
    if name == "" then name = "default" end
    CurrentConfigName = name
    
    local configData = {
        AssistActive = AssistActive,
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
        HitboxSize = HitboxSize,
        HitboxTransparency = HitboxTransparency,
        HamsterCoins = HamsterCoins,
        WalkSpeedEnabled = WalkSpeedEnabled,
        CustomWalkSpeed = CustomWalkSpeed,
        JumpPowerEnabled = JumpPowerEnabled,
        CustomJumpPower = CustomJumpPower,
        FlyEnabled = FlyEnabled,
        FlySpeed = FlySpeed
    }
    
    pcall(function()
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(configData))
    end)
end

-- Функция загрузки конфига
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
            AssistSmooth = data.AssistSmooth or 0.5
            TargetPartName = data.TargetPartName or "Head"
            FOVEnabled = data.FOVEnabled ~= false
            FOVRadius = data.FOVRadius or 120
            TouchAssistActive = data.TouchAssistActive or false
            TouchAssistSmooth = data.TouchAssistSmooth or 0.5
            TouchAssistFOV = data.TouchAssistFOV or 150
            VisualsEnabled = data.VisualsEnabled or false
            VisualsTransparency = data.VisualsTransparency or 0.7
            HitboxEnabled = data.HitboxEnabled or false
            HitboxSize = data.HitboxSize or 4
            HitboxTransparency = data.HitboxTransparency or 0.5
            HamsterCoins = data.HamsterCoins or 0
            HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
            WalkSpeedEnabled = data.WalkSpeedEnabled or false
            CustomWalkSpeed = data.CustomWalkSpeed or 16
            JumpPowerEnabled = data.JumpPowerEnabled or false
            CustomJumpPower = data.CustomJumpPower or 50
            FlyEnabled = data.FlyEnabled or false
            FlySpeed = data.FlySpeed or 50

            -- Обновление текста кнопок в интерфейсе
            ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
            ToggleBtn.TextColor3 = AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
            MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
            ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
            ESPToggleBtn.TextColor3 = VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
            HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
            SpeedToggle.TextColor3 = WalkSpeedEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
            JumpToggle.TextColor3 = JumpPowerEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
            FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
            FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
            PartDropdownBtn.Text = "Target: " .. TargetPartName
            
            CurrentConfigName = name
        end
    end
end

-- Автозагрузка конфига при старте
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

-- Автосохранение конфига при выходе или деинсталляции
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
    for _, hl in pairs(VisualsMap) do
        if hl then hl:Destroy() end
    end
    ScreenGui:Destroy()
    MobileGui:Destroy()
end)

-- Логика кнопок и функционала
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
        for _, hl in pairs(VisualsMap) do
            if hl then hl:Destroy() end
        end
        VisualsMap = {}
    end
end)

ESPTransInput.FocusLost:Connect(function()
    local val = tonumber(ESPTransInput.Text)
    if val then VisualsTransparency = math.clamp(val, 0, 1) end
end)

HitboxToggle.MouseButton1Click:Connect(function()
    HitboxEnabled = not HitboxEnabled
    HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
    HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if not HitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if OriginalSizes[hrp] then
                    hrp.Size = OriginalSizes[hrp]
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

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

local function toggleFlyFunc()
    FlyEnabled = not FlyEnabled
    FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    flying = FlyEnabled
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if flying then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            bodyVelocity.Parent = hrp
        else
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end
end

FlyToggle.MouseButton1Click:Connect(toggleFlyFunc)
FlyMobileBtn.MouseButton1Click:Connect(toggleFlyFunc)

FlySpeedInput.FocusLost:Connect(function()
    local val = tonumber(FlySpeedInput.Text)
    if val then FlySpeed = val end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

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

    if AssistActive and not TouchAssistActive and UserInputService:IsKeyDown(Enum.KeyCode.E) then
        local target = nil
        local bestScore = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local part = player.Character:FindFirstChild(TargetPartName) or player.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist <= activeFOV and dist < bestScore then
                            bestScore = dist
                            target = part
                        end
                    end
                end
            end
        end
        if target then
            local curMouse = UserInputService:GetMouseLocation()
            local scrPos = Camera:WorldToViewportPoint(target.Position)
            local delta = Vector2.new(scrPos.X, scrPos.Y) - curMouse
            if AssistSmooth > 0 then
                mousemoverel(delta.X * (1 - AssistSmooth), delta.Y * (1 - AssistSmooth))
            else
                mousemoverel(delta.X, delta.Y)
            end
        end
    elseif TouchAssistActive then
        local target = nil
        local bestScore = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local part = player.Character:FindFirstChild(TargetPartName) or player.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist <= activeFOV and dist < bestScore then
                            bestScore = dist
                            target = part
                        end
                    end
                end
            end
        end
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            if TouchAssistSmooth > 0 then
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - TouchAssistSmooth)
            else
                Camera.CFrame = targetCF
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

        if FlyEnabled and bodyGyro and bodyVelocity and char:FindFirstChild("HumanoidRootPart") then
            bodyGyro.CFrame = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            bodyVelocity.Velocity = moveDir * FlySpeed
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if VisualsEnabled then
                local character = player.Character
                if character and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    if not VisualsMap[player] or VisualsMap[player].Parent ~= character then
                        if VisualsMap[player] then VisualsMap[player]:Destroy() end
                        local hl = Instance.new("Highlight")
                        hl.Adornee = character
                        hl.FillColor = Color3.fromRGB(180, 100, 255)
                        hl.OutlineColor = Color3.fromRGB(220, 130, 255)
                        hl.FillTransparency = VisualsTransparency
                        hl.Parent = character
                        VisualsMap[player] = hl
                    else
                        VisualsMap[player].FillTransparency = VisualsTransparency
                    end
                else
                    if VisualsMap[player] then VisualsMap[player]:Destroy() VisualsMap[player] = nil end
                end
            else
                if VisualsMap[player] then VisualsMap[player]:Destroy() VisualsMap[player] = nil end
            end
        end
    end

    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not OriginalSizes[hrp] then OriginalSizes[hrp] = hrp.Size end
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Transparency = HitboxTransparency
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end
end)