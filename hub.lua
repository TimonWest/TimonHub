-- TWKS // Timon Hub - Ultimate Advanced Suite (HamsterCombat Tab Restored & Cleaned)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
local FOVColor = Color3.fromRGB(180, 100, 255)

local TouchAssistActive = false
local TouchAssistSmooth = 0.5
local TouchAssistFOV = 150

local LockedTarget = nil

local VisualsEnabled = false
local VisualsColor = Color3.fromRGB(180, 100, 255)
local VisualsTransparency = 0.7
local VisualsMap = {}

local HitboxEnabled = false
local HitboxSize = 4
local HitboxTransparency = 0.5
local HitboxColor = Color3.fromRGB(150, 50, 255)
local OriginalSizes = {}

-- Переменная кликера Hamster Coin
local HamsterCoins = 0

local WalkSpeedEnabled = false
local CustomWalkSpeed = 16
local JumpPowerEnabled = false
local CustomJumpPower = 50
local FlyEnabled = false
local FlySpeed = 50
local FlyKey = Enum.KeyCode.F
local flying = false
local bodyGyro, bodyVelocity

local CurrentConfigName = "default"
local ConfigFolder = "TimonHub_Configs"

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
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 9, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(110, 50, 170)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local GlowTop = Instance.new("Frame")
GlowTop.Size = UDim2.new(1, 0, 0, 2)
GlowTop.BackgroundColor3 = Color3.fromRGB(200, 120, 255)
GlowTop.BorderSizePixel = 0
GlowTop.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(22, 13, 33)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = Color3.fromRGB(22, 13, 33)
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TIMON HUB  ✦  HAMSTER COMBAT"
Title.TextColor3 = Color3.fromRGB(245, 225, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

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

local function createMobileButton(name, pos, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
    btn.TextColor3 = Color3.fromRGB(225, 205, 250)
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
    stroke.Color = Color3.fromRGB(110, 50, 170)
    stroke.Thickness = 1.5
    stroke.Parent = btn
    
    return btn
end

local ToggleUIMobileBtn = createMobileButton("ToggleUI", UDim2.new(0, 20, 0, 20), "Menu")
local MobileAimToggleBtn = createMobileButton("MobileAim", UDim2.new(0, 140, 0, 20), "Mob.Aim: OFF")
local FlyMobileBtn = createMobileButton("FlyMob", UDim2.new(0, 260, 0, 20), "Fly: OFF")

ToggleUIMobileBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 155, 1, -70)
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
ContentArea.Size = UDim2.new(1, -185, 1, -70)
ContentArea.Position = UDim2.new(0, 177, 0, 62)
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
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
    btn.TextColor3 = Color3.fromRGB(195, 170, 225)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 40, 110)
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
createTabButton("ESP", ESPTab)
createTabButton("Hitbox", HitboxTab)
createTabButton("Player", PlayerTab)
createTabButton("HamsterCombat", HamsterTab)
createTabButton("Settings", SettingsTab)

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(150, 120, 190)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createActionBtn(parent, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
    btn.TextColor3 = Color3.fromRGB(225, 205, 250)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 40, 110)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    return btn
end

local function createInputBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 40)
    box.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
    box.TextColor3 = Color3.fromRGB(225, 205, 250)
    box.PlaceholderColor3 = Color3.fromRGB(130, 105, 165)
    box.TextSize = 13
    box.Font = Enum.Font.GothamMedium
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 40, 110)
    stroke.Thickness = 1
    stroke.Parent = box
    
    return box
end

-- === НАСТРОЙКИ COMBAT ===
createLabel(CombatTab, "ОСНОВНОЙ МОДУЛЬ (PC CURSOR)")
local ToggleBtn = createActionBtn(CombatTab, "Assist System: OFF")
local KeyBindBtn = createActionBtn(CombatTab, "Bind Key / Mouse: E")

createLabel(CombatTab, "МОБИЛЬНЫЙ МОДУЛЬ (MOBILE ASSIST)")
local MobileAimToggle = createActionBtn(CombatTab, "Mobile Assist: OFF")
local MobileAimSmoothInput = createInputBox(CombatTab, "Mobile Smooth (например: 0.5)")
local MobileAimFOVInput = createInputBox(CombatTab, "Mobile FOV (например: 150)")

createLabel(CombatTab, "ВЫБОР ЧАСТИ ТЕЛА")
local PartDropdownBtn = createActionBtn(CombatTab, "Target: Head")
local PartFrame = Instance.new("Frame")
PartFrame.Size = UDim2.new(1, 0, 0, 140)
PartFrame.BackgroundColor3 = Color3.fromRGB(18, 11, 28)
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

createLabel(CombatTab, "ПЛАВНОСТЬ И FOV PC")
local SmoothInput = createInputBox(CombatTab, "Введите Smooth (например: 0.5)")
local FOVToggleBtn = createActionBtn(CombatTab, "FOV Circle: ON")
local FOVRadiusInput = createInputBox(CombatTab, "Введите размер FOV (например: 120)")

-- === НАСТРОЙКИ ESP ===
createLabel(ESPTab, "ПОДСВЕТКА ИГРОКОВ (VISUALS)")
local ESPToggleBtn = createActionBtn(ESPTab, "Visuals: OFF")
local ESPColorBtn = createActionBtn(ESPTab, "Color: Purple Neon")
local ESPColorIndex = 1
local ESPColors = {
    {Name = "Purple Neon", Color = Color3.fromRGB(180, 100, 255)},
    {Name = "Deep Violet", Color = Color3.fromRGB(120, 50, 255)},
    {Name = "Pink Orchid", Color = Color3.fromRGB(255, 100, 200)},
    {Name = "Pure White", Color = Color3.fromRGB(255, 255, 255)}
}

createLabel(ESPTab, "ПРОЗРАЧНОСТЬ ПОДСВЕТКИ (0 - 1)")
local ESPTransInput = createInputBox(ESPTab, "Введите прозрачность (например: 0.7)")

-- === НАСТРОЙКИ HITBOX ===
createLabel(HitboxTab, "УВЕЛИЧЕНИЕ ХИТБОКСОВ")
local HitboxToggle = createActionBtn(HitboxTab, "Hitbox Extender: OFF")

createLabel(HitboxTab, "РАЗМЕР ХИТБОКСА (Число)")
local HitboxSizeInput = createInputBox(HitboxTab, "Введите размер (например: 4)")

createLabel(HitboxTab, "ВИДИМОСТЬ ХИТБОКСА (Прозрачность 0 - 1)")
local HitboxTransInput = createInputBox(HitboxTab, "Введите прозрачность (например: 0.5)")

-- === НАСТРОЙКИ PLAYER ===
createLabel(PlayerTab, "СКОРОСТЬ И ПРЫЖОК")
local SpeedToggle = createActionBtn(PlayerTab, "WalkSpeed: OFF")
local SpeedInput = createInputBox(PlayerTab, "Скорость (например: 50)")
local JumpToggle = createActionBtn(PlayerTab, "JumpPower: OFF")
local JumpInput = createInputBox(PlayerTab, "Прыжок (например: 100)")

createLabel(PlayerTab, "ПОЛЕТ (FLY)")
local FlyToggle = createActionBtn(PlayerTab, "Fly: OFF")
local FlyBindBtn = createActionBtn(PlayerTab, "Fly Bind: F")
local FlySpeedInput = createInputBox(PlayerTab, "Скорость полета (например: 50)")

-- === НАСТРОЙКИ HAMSTER COMBAT (Кликер) ===
createLabel(HamsterTab, "КЛИКЕР HAMSTER COIN")

-- Текст баланса в правом верхнем углу меню
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

-- Кнопка с изображением хомяка для фарма
local HamsterClickBtn = Instance.new("ImageButton")
HamsterClickBtn.Size = UDim2.new(0, 180, 0, 180)
HamsterClickBtn.Position = UDim2.new(0.5, -90, 0, 30)
HamsterClickBtn.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
HamsterClickBtn.Image = "https://cdn.iphones.ru/wp-content/uploads/2024/06/IMG_4694-1.jpeg"
HamsterClickBtn.Parent = HamsterTab

local HamsterCorner = Instance.new("UICorner")
HamsterCorner.CornerRadius = UDim.new(1, 0)
HamsterCorner.Parent = HamsterClickBtn

local HamsterStroke = Instance.new("UIStroke")
HamsterStroke.Color = Color3.fromRGB(255, 215, 0)
HamsterStroke.Thickness = 3
HamsterStroke.Parent = HamsterClickBtn

HamsterClickBtn.MouseButton1Click:Connect(function()
    HamsterCoins = HamsterCoins + 1
    HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
    
    HamsterClickBtn:TweenSize(UDim2.new(0, 160, 0, 160), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.05, true, function()
        HamsterClickBtn:TweenSize(UDim2.new(0, 180, 0, 180), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.05, true)
    end)
end)

-- === НАСТРОЙКИ SETTINGS ===
createLabel(SettingsTab, "ВИДИМОСТЬ МОБИЛЬНЫХ КНОПОК")
local HideMobileBtnsToggle = createActionBtn(SettingsTab, "Mobile Buttons: VISIBLE")

createLabel(SettingsTab, "УПРАВЛЕНИЕ КОНФИГАМИ")
local ConfigNameInput = createInputBox(SettingsTab, "Имя конфига (например: pro)")
local SaveConfigBtn = createActionBtn(SettingsTab, "Save Config")
local LoadConfigBtn = createActionBtn(SettingsTab, "Load Config")
local AutoLoadBtn = createActionBtn(SettingsTab, "Auto-Load: OFF")

createLabel(SettingsTab, "ДЕИНСТАЛЛЯЦИЯ СКРИПТА")
local UnloadBtn = createActionBtn(SettingsTab, "Unload Script (Full Delete)")
UnloadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)

local AutoLoadConfigName = "default"
local AutoLoadEnabled = false
local AutoloadFileName = ConfigFolder .. "/autoload.txt"

local function applyConfigData(data)
    if not data then return end
    
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
    
    if data.AimKeyName then
        pcall(function() AssistKey = Enum.KeyCode[data.AimKeyName] end)
    end
    if data.AimMouseTypeStr then
        pcall(function() AssistMouseType = Enum.UserInputType[data.AimMouseTypeStr] end)
    end
    if data.FlyKeyName then
        pcall(function() FlyKey = Enum.KeyCode[data.FlyKeyName] end)
    end
    
    ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
    ToggleBtn.TextColor3 = AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    
    MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
    MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
    
    MobileAimSmoothInput.Text = tostring(TouchAssistSmooth)
    MobileAimFOVInput.Text = tostring(TouchAssistFOV)
    
    if AssistKey then KeyBindBtn.Text = "Bind Key: " .. AssistKey.Name
    elseif AssistMouseType then KeyBindBtn.Text = "Bind Mouse: " .. AssistMouseType.Name end
    
    PartDropdownBtn.Text = "Target: " .. TargetPartName
    SmoothInput.Text = tostring(AssistSmooth)
    FOVToggleBtn.Text = FOVEnabled and "FOV Circle: ON" or "FOV Circle: OFF"
    FOVRadiusInput.Text = tostring(FOVRadius)
    
    ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
    ESPToggleBtn.TextColor3 = VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    ESPTransInput.Text = tostring(VisualsTransparency)
    
    HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
    HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    HitboxSizeInput.Text = tostring(HitboxSize)
    HitboxTransInput.Text = tostring(HitboxTransparency)
    
    SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
    SpeedInput.Text = tostring(CustomWalkSpeed)
    JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
    JumpInput.Text = tostring(CustomJumpPower)
    FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlySpeedInput.Text = tostring(FlySpeed)
    FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyBindBtn.Text = "Fly Bind: " .. FlyKey.Name
end

pcall(function()
    if readfile and isfile and isfile(AutoloadFileName) then
        local autoData = HttpService:JSONDecode(readfile(AutoloadFileName))
        if autoData and autoData.Enabled and autoData.ConfigName then
            AutoLoadEnabled = true
            AutoLoadConfigName = autoData.ConfigName
            AutoLoadBtn.Text = "Auto-Load: " .. AutoLoadConfigName
            AutoLoadBtn.TextColor3 = Color3.fromRGB(160, 255, 120)
            
            local targetPath = ConfigFolder .. "/" .. AutoLoadConfigName .. ".json"
            if isfile(targetPath) then
                local conf = HttpService:JSONDecode(readfile(targetPath))
                applyConfigData(conf)
            end
        end
    end
end)

SaveConfigBtn.MouseButton1Click:Connect(function()
    if writefile then
        local name = ConfigNameInput.Text
        if name == "" then name = "default" end
        CurrentConfigName = name
        
        local configData = {
            AssistActive = AssistActive,
            AimKeyName = AssistKey and AssistKey.Name or nil,
            AimMouseTypeStr = AssistMouseType and AssistMouseType.Name or nil,
            AssistSmooth = AssistSmooth,
            TargetPartName = TargetPartName,
            FOVEnabled = FOVEnabled,
            FOVRadius = FOVRadius,
            TouchAssistActive = TouchAssistActive,
            TouchAssistSmooth = TouchAssistSmooth,
            TouchAssistFOV = TouchAssistFOV,
            HamsterCoins = HamsterCoins,
            
            VisualsEnabled = VisualsEnabled,
            VisualsTransparency = VisualsTransparency,
            
            HitboxEnabled = HitboxEnabled,
            HitboxSize = HitboxSize,
            HitboxTransparency = HitboxTransparency,
            
            WalkSpeedEnabled = WalkSpeedEnabled,
            CustomWalkSpeed = CustomWalkSpeed,
            JumpPowerEnabled = JumpPowerEnabled,
            CustomJumpPower = CustomJumpPower,
            FlyEnabled = FlyEnabled,
            FlySpeed = FlySpeed,
            FlyKeyName = FlyKey.Name
        }
        
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(configData))
        SaveConfigBtn.Text = "Saved (" .. name .. ")!"
        task.delay(1.5, function() SaveConfigBtn.Text = "Save Config" end)
    else
        SaveConfigBtn.Text = "Not supported!"
    end
end)

LoadConfigBtn.MouseButton1Click:Connect(function()
    if readfile and isfile then
        local name = ConfigNameInput.Text
        if name == "" then name = "default" end
        local path = ConfigFolder .. "/" .. name .. ".json"
        
        if isfile(path) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            if success and data then
                applyConfigData(data)
                CurrentConfigName = name
                LoadConfigBtn.Text = "Loaded (" .. name .. ")!"
                task.delay(1.5, function() LoadConfigBtn.Text = "Load Config" end)
            end
        else
            LoadConfigBtn.Text = "Config not found!"
            task.delay(1.5, function() LoadConfigBtn.Text = "Load Config" end)
        end
    end
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
            writefile(AutoloadFileName, HttpService:JSONEncode({Enabled = true, ConfigName = name}))
        end
    else
        AutoLoadBtn.Text = "Auto-Load: OFF"
        AutoLoadBtn.TextColor3 = Color3.fromRGB(225, 205, 250)
        if writefile then
            writefile(AutoloadFileName, HttpService:JSONEncode({Enabled = false, ConfigName = name}))
        end
    end
end)

local mobileButtonsVisible = true
HideMobileBtnsToggle.MouseButton1Click:Connect(function()
    mobileButtonsVisible = not mobileButtonsVisible
    ToggleUIMobileBtn.Visible = mobileButtonsVisible
    MobileAimToggleBtn.Visible = mobileButtonsVisible
    FlyMobileBtn.Visible = mobileButtonsVisible
    if mobileButtonsVisible then
        HideMobileBtnsToggle.Text = "Mobile Buttons: VISIBLE"
        HideMobileBtnsToggle.TextColor3 = Color3.fromRGB(160, 255, 120)
    else
        HideMobileBtnsToggle.Text = "Mobile Buttons: HIDDEN"
        HideMobileBtnsToggle.TextColor3 = Color3.fromRGB(225, 205, 250)
    end
end)

UnloadBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if FOVCircle then FOVCircle:Remove() end
    end)
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
    for _, hl in pairs(VisualsMap) do
        if hl then hl:Destroy() end
    end
    ScreenGui:Destroy()
    MobileGui:Destroy()
end)

local bindingCombatKey = false
ToggleBtn.MouseButton1Click:Connect(function()
    AssistActive = not AssistActive
    ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
    ToggleBtn.TextColor3 = AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
end)

MobileAimToggle.MouseButton1Click:Connect(function()
    TouchAssistActive = not TouchAssistActive
    MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
    MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
end)

MobileAimToggleBtn.MouseButton1Click:Connect(function()
    TouchAssistActive = not TouchAssistActive
    MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
    MobileAimToggle.TextColor3 = TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
end)

MobileAimSmoothInput.FocusLost:Connect(function()
    local val = tonumber(MobileAimSmoothInput.Text)
    if val then
        TouchAssistSmooth = math.clamp(val, 0, 0.99)
        MobileAimSmoothInput.Text = tostring(TouchAssistSmooth)
    end
end)

MobileAimFOVInput.FocusLost:Connect(function()
    local val = tonumber(MobileAimFOVInput.Text)
    if val then
        TouchAssistFOV = math.clamp(val, 10, 500)
        MobileAimFOVInput.Text = tostring(TouchAssistFOV)
    end
end)

KeyBindBtn.MouseButton1Click:Connect(function()
    bindingCombatKey = true
    KeyBindBtn.Text = "Press any key or mouse button..."
end)
PartDropdownBtn.MouseButton1Click:Connect(function()
    PartFrame.Visible = not PartFrame.Visible
end)
SmoothInput.FocusLost:Connect(function()
    local val = tonumber(SmoothInput.Text)
    if val then
        AssistSmooth = math.clamp(val, 0, 0.99)
        SmoothInput.Text = tostring(AssistSmooth)
    end
end)
FOVToggleBtn.MouseButton1Click:Connect(function()
    FOVEnabled = not FOVEnabled
    FOVToggleBtn.Text = FOVEnabled and "FOV Circle: ON" or "FOV Circle: OFF"
    FOVToggleBtn.TextColor3 = FOVEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
end)
FOVRadiusInput.FocusLost:Connect(function()
    local val = tonumber(FOVRadiusInput.Text)
    if val then
        FOVRadius = math.clamp(val, 10, 500)
        FOVRadiusInput.Text = tostring(FOVRadius)
    end
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    VisualsEnabled = not VisualsEnabled
    ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
    ESPToggleBtn.TextColor3 = VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
    if not VisualsEnabled then
        for _, hl in pairs(VisualsMap) do
            if hl then hl:Destroy() end
        end
        VisualsMap = {}
    end
end)
ESPColorBtn.MouseButton1Click:Connect(function()
    ESPColorIndex = (ESPColorIndex % #ESPColors) + 1
    VisualsColor = ESPColors[ESPColorIndex].Color
    ESPColorBtn.Text = "Color: " .. ESPColors[ESPColorIndex].Name
    for _, hl in pairs(VisualsMap) do
        if hl then hl.FillColor = VisualsColor hl.OutlineColor = VisualsColor end
    end
end)
ESPTransInput.FocusLost:Connect(function()
    local val = tonumber(ESPTransInput.Text)
    if val then
        VisualsTransparency = math.clamp(val, 0, 1)
        ESPTransInput.Text = tostring(VisualsTransparency)
    end
end)

HitboxToggle.MouseButton1Click:Connect(function()
    HitboxEnabled = not HitboxEnabled
    HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
    HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
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
    if val then
        HitboxSize = math.clamp(val, 1, 30)
        HitboxSizeInput.Text = tostring(HitboxSize)
    end
end)
HitboxTransInput.FocusLost:Connect(function()
    local val = tonumber(HitboxTransInput.Text)
    if val then
        HitboxTransparency = math.clamp(val, 0, 1)
        HitboxTransInput.Text = tostring(HitboxTransparency)
    end
end)

local bindingFlyKey = false
SpeedToggle.MouseButton1Click:Connect(function()
    WalkSpeedEnabled = not WalkSpeedEnabled
    SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
    SpeedToggle.TextColor3 = WalkSpeedEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
end)
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then CustomWalkSpeed = val end
end)
JumpToggle.MouseButton1Click:Connect(function()
    JumpPowerEnabled = not JumpPowerEnabled
    JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
    JumpToggle.TextColor3 = JumpPowerEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
end)
JumpInput.FocusLost:Connect(function()
    local val = tonumber(JumpInput.Text)
    if val then CustomJumpPower = val end
end)

local function toggleFlyFunc()
    FlyEnabled = not FlyEnabled
    FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(225, 205, 250)
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

FlyBindBtn.MouseButton1Click:Connect(function()
    bindingFlyKey = true
    FlyBindBtn.Text = "Press any key..."
end)
FlySpeedInput.FocusLost:Connect(function()
    local val = tonumber(FlySpeedInput.Text)
    if val then FlySpeed = val end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if bindingCombatKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            AssistKey = input.KeyCode
            AssistMouseType = nil
            KeyBindBtn.Text = "Bind Key: " .. AssistKey.Name
            bindingCombatKey = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            AssistMouseType = input.UserInputType
            AssistKey = nil
            KeyBindBtn.Text = "Bind Mouse: " .. AssistMouseType.Name
            bindingCombatKey = false
        end
        return
    end

    if bindingFlyKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            FlyKey = input.KeyCode
            FlyBindBtn.Text = "Fly Bind: " .. FlyKey.Name
            bindingFlyKey = false
        end
        return
    end

    if input.KeyCode == ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == FlyKey then
        toggleFlyFunc()
    end
end)

local function isAssistKeyDown()
    if TouchAssistActive then
        return true
    end
    if AssistKey and UserInputService:IsKeyDown(AssistKey) then
        return true
    end
    if AssistMouseType and UserInputService:IsMouseButtonPressed(AssistMouseType) then
        return true
    end
    if not AssistKey and not AssistMouseType and UserInputService:IsKeyDown(Enum.KeyCode.E) then
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
                if distToRef <= activeFOV then
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
    if not isAssistKeyDown() then
        LockedTarget = nil
    end

    local activeFOV = TouchAssistActive and TouchAssistFOV or FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if FOVCircle then
        if FOVEnabled or TouchAssistActive then
            FOVCircle.Visible = true
            FOVCircle.Radius = activeFOV
            FOVCircle.Position = TouchAssistActive and screenCenter or UserInputService:GetMouseLocation()
            FOVCircle.Color = FOVColor
        else
            FOVCircle.Visible = false
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

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if WalkSpeedEnabled then humanoid.WalkSpeed = CustomWalkSpeed end
            if JumpPowerEnabled then humanoid.JumpPower = CustomJumpPower end
        end

        if FlyEnabled and bodyGyro and bodyVelocity and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
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
                if character and character:FindFirstChildOfClass("Humanoid") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid.Health > 0 then
                        if not VisualsMap[player] or VisualsMap[player].Parent ~= character then
                            if VisualsMap[player] then
                                VisualsMap[player]:Destroy()
                            end
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = character
                            highlight.FillColor = VisualsColor
                            highlight.OutlineColor = VisualsColor
                            highlight.FillTransparency = VisualsTransparency
                            highlight.OutlineTransparency = 0.1
                            highlight.Parent = character
                            VisualsMap[player] = highlight
                        else
                            VisualsMap[player].FillTransparency = VisualsTransparency
                            VisualsMap[player].FillColor = VisualsColor
                            VisualsMap[player].OutlineColor = VisualsColor
                        end
                    else
                        if VisualsMap[player] then
                            VisualsMap[player]:Destroy()
                            VisualsMap[player] = nil
                        end
                    end
                end
            else
                if VisualsMap[player] then
                    VisualsMap[player]:Destroy()
                    VisualsMap[player] = nil
                end
            end
        end
    end

    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not OriginalSizes[hrp] then
                        OriginalSizes[hrp] = hrp.Size
                    end
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Transparency = HitboxTransparency
                    hrp.Color = HitboxColor
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end
end)