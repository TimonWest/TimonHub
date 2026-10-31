-- TWKS // Timon Hub - Ultimate Advanced Suite (Fly + Troll Edition)
local Players, RunService, UserInputService, HttpService, TweenService, LocalPlayer, Camera = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("HttpService"), game:GetService("TweenService"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera

pcall(function()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "TimonHub_Ultimate" or gui.Name == "TimonHub_MobileButtons" then gui:Destroy() end
    end
end)

local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible, FOVCircle.Thickness, FOVCircle.NumSides, FOVCircle.Filled, FOVCircle.Color = false, 1.5, 64, false, Color3.fromRGB(180, 100, 255)
    end
end)

local AssistActive, ToggleKey, AssistSmooth, TargetPartName, FOVEnabled, FOVRadius = false, Enum.KeyCode.LeftAlt, 0.5, "Head", true, 120
local TouchAssistActive, TouchAssistSmooth, TouchAssistFOV, LockedTarget = false, 0.5, 150, nil
local VisualsEnabled, VisualsTransparency, VisualsMap = false, 0.5, {}
local HitboxEnabled, HitboxSize, HitboxTransparency, HitboxTargetName, HitboxKey, OriginalSizes = false, 4, 0.5, "HumanoidRootPart", Enum.KeyCode.Q, {}
local InvisFlingEnabled, AntiFlingEnabled, HamsterCoins = false, false, 0
local WalkSpeedEnabled, CustomWalkSpeed, JumpPowerEnabled, CustomJumpPower = false, 16, false, 50

-- Переменные Fly
local FlyEnabled = false
local FlySpeed = 50
local FlyKey = Enum.KeyCode.F
local flyConnection = nil
local controlModule = nil
local bg, bv

-- Переменные Troll функций
local VisualSpinEnabled = false
local InvisibleEnabled = false
local JitterEnabled = false

pcall(function()
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        local playerModule = playerScripts:FindFirstChild("PlayerModule")
        if playerModule then
            controlModule = require(playerModule:FindFirstChild("ControlModule"))
        end
    end
end)

local ConfigFolder, AutoLoadFileName, CurrentConfigName, AutoLoadEnabled = "TimonHub_Configs", "TimonHub_Configs/autoload.json", "default", false
pcall(function() if makefolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end end)

local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TimonHub_Ultimate", false

local MobileGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
MobileGui.Name, MobileGui.ResetOnSpawn = "TimonHub_MobileButtons", false

local function createMobileButton(pos, text)
    local btn = Instance.new("TextButton", MobileGui)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.BackgroundTransparency, btn.TextColor3, btn.TextSize, btn.Font, btn.Text, btn.Active, btn.Draggable = UDim2.new(0, 105, 0, 42), pos, Color3.fromRGB(12, 8, 20), 0.2, Color3.fromRGB(235, 205, 255), 12, Enum.Font.GothamBold, text, true, true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color, stroke.Transparency, stroke.Thickness = Color3.fromRGB(190, 90, 255), 0.25, 1.8
    return btn
end

local ToggleUIMobileBtn = createMobileButton(UDim2.new(0, 20, 0, 20), "⚡ MENU")
local MobileAimToggleBtn = createMobileButton(UDim2.new(0, 135, 0, 20), "Mob.Aim: OFF")
local FlyMobileBtn = createMobileButton(UDim2.new(0, 250, 0, 20), "Fly: OFF")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.Active, MainFrame.Draggable = UDim2.new(0, 680, 0, 450), UDim2.new(0.5, -340, 0.5, -225), Color3.fromRGB(8, 5, 14), 0.15, true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color, MainStroke.Transparency, MainStroke.Thickness = Color3.fromRGB(170, 70, 255), 0.15, 2

local NeonGlow = Instance.new("Frame", MainFrame)
NeonGlow.Size, NeonGlow.BackgroundColor3, NeonGlow.BorderSizePixel = UDim2.new(1, 0, 0, 3), Color3.fromRGB(220, 130, 255), 0

ToggleUIMobileBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Header = Instance.new("Frame", MainFrame)
Header.Size, Header.BackgroundColor3, Header.BackgroundTransparency, Header.BorderSizePixel = UDim2.new(1, 0, 0, 54), Color3.fromRGB(14, 8, 24), 0.35, 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local HeaderCover = Instance.new("Frame", Header)
HeaderCover.Size, HeaderCover.Position, HeaderCover.BackgroundColor3, HeaderCover.BackgroundTransparency, HeaderCover.BorderSizePixel = UDim2.new(1, 0, 0, 10), UDim2.new(0, 0, 1, -10), Color3.fromRGB(14, 8, 24), 0.35, 0

local Title = Instance.new("TextLabel", Header)
Title.Size, Title.Position, Title.BackgroundTransparency, Title.Text, Title.TextColor3, Title.TextSize, Title.Font, Title.TextXAlignment = UDim2.new(1, -20, 1, 0), UDim2.new(0, 24, 0, 0), true, "TIMON HUB  ✦  ULTIMATE SUITE v4.6", Color3.fromRGB(250, 230, 255), 15, Enum.Font.GothamBold, Enum.TextXAlignment.Left

local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size, Sidebar.Position, Sidebar.BackgroundTransparency, Sidebar.BorderSizePixel, Sidebar.CanvasSize, Sidebar.ScrollBarThickness = UDim2.new(0, 175, 1, -70), UDim2.new(0, 12, 0, 62), true, 0, UDim2.new(0, 0, 0, 0), 2
local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder, SidebarLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 8)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size, ContentArea.Position, ContentArea.BackgroundTransparency = UDim2.new(1, -205, 1, -70), UDim2.new(0, 195, 0, 62), true

local function createTabContent()
    local sf = Instance.new("ScrollingFrame", ContentArea)
    sf.Size, sf.BackgroundTransparency, sf.BorderSizePixel, sf.CanvasSize, sf.ScrollBarThickness, sf.Visible = UDim2.new(1, 0, 1, 0), true, 0, UDim2.new(0, 0, 0, 900), 3, false
    local layout = Instance.new("UIListLayout", sf)
    layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 10)
    return sf
end

local CombatTab, ESPTab, HitboxTab, PlayerTab, FlingTab, TrollTab, HamsterTab, SettingsTab = createTabContent(), createTabContent(), createTabContent(), createTabContent(), createTabContent(), createTabContent(), createTabContent(), createTabContent()
CombatTab.Visible = true

local function createTabButton(name, targetTab)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size, btn.BackgroundColor3, btn.BackgroundTransparency, btn.TextColor3, btn.TextSize, btn.Font, btn.Text = UDim2.new(1, 0, 0, 42), Color3.fromRGB(16, 9, 26), 0.3, Color3.fromRGB(210, 185, 245), 13, Enum.Font.GothamMedium, name
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color, stroke.Transparency, stroke.Thickness = Color3.fromRGB(110, 50, 160), 0.4, 1.2
    btn.MouseButton1Click:Connect(function()
        CombatTab.Visible, ESPTab.Visible, HitboxTab.Visible, PlayerTab.Visible, FlingTab.Visible, TrollTab.Visible, HamsterTab.Visible, SettingsTab.Visible = false, false, false, false, false, false, false, false
        targetTab.Visible = true
    end)
    return btn
end

createTabButton("Combat", CombatTab)
createTabButton("ESP & Visuals", ESPTab)
createTabButton("Hitbox", HitboxTab)
createTabButton("Player", PlayerTab)
createTabButton("Fling & Anti", FlingTab)
createTabButton("Troll", TrollTab)
createTabButton("HamsterCombat", HamsterTab)
createTabButton("Settings", SettingsTab)

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size, lbl.BackgroundTransparency, lbl.Text, lbl.TextColor3, lbl.TextSize, lbl.Font, lbl.TextXAlignment = UDim2.new(1, 0, 0, 24), true, text, Color3.fromRGB(175, 140, 220), 11, Enum.Font.GothamBold, Enum.TextXAlignment.Left
end

local function createActionBtn(parent, text)
    local btn = Instance.new("TextButton", parent)
    btn.Size, btn.BackgroundColor3, btn.BackgroundTransparency, btn.TextColor3, btn.TextSize, btn.Font, btn.Text = UDim2.new(1, 0, 0, 42), Color3.fromRGB(16, 9, 26), 0.3, Color3.fromRGB(240, 220, 255), 13, Enum.Font.GothamMedium, text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color, stroke.Transparency, stroke.Thickness = Color3.fromRGB(110, 50, 160), 0.4, 1.2
    return btn
end

local function createInputBox(parent, placeholder)
    local box = Instance.new("TextBox", parent)
    box.Size, box.BackgroundColor3, box.BackgroundTransparency, box.TextColor3, box.PlaceholderColor3, box.TextSize, box.Font, box.PlaceholderText, box.Text = UDim2.new(1, 0, 0, 42), Color3.fromRGB(16, 9, 26), 0.3, Color3.fromRGB(240, 220, 255), Color3.fromRGB(140, 110, 185), 13, Enum.Font.GothamMedium, placeholder, ""
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", box)
    stroke.Color, stroke.Transparency, stroke.Thickness = Color3.fromRGB(110, 50, 160), 0.4, 1.2
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
local PartFrame = Instance.new("Frame", CombatTab)
PartFrame.Size, PartFrame.BackgroundColor3, PartFrame.BackgroundTransparency, PartFrame.Visible = UDim2.new(1, 0, 0, 140), Color3.fromRGB(12, 6, 20), 0.2, false
Instance.new("UIListLayout", PartFrame).Padding = UDim.new(0, 5)

for _, p in ipairs({{Name = "Голова (Head)", Part = "Head"}, {Name = "Торс (Torso)", Part = "UpperTorso"}, {Name = "Руки (Arms)", Part = "LeftLowerArm"}, {Name = "Ноги (Legs)", Part = "LeftLowerLeg"}}) do
    local b = createActionBtn(PartFrame, p.Name)
    b.MouseButton1Click:Connect(function() TargetPartName, PartDropdownBtn.Text, PartFrame.Visible = p.Part, "Target: " .. p.Name, false end)
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
local HitboxPartContainer = Instance.new("Frame", HitboxTab)
HitboxPartContainer.Size, HitboxPartContainer.BackgroundTransparency, HitboxPartContainer.Visible = UDim2.new(1, 0, 0, 160), 1, false
Instance.new("UIListLayout", HitboxPartContainer).Padding = UDim.new(0, 5)

for _, hp in ipairs({{Name = "Все тело (RootPart)", Part = "HumanoidRootPart"}, {Name = "Голова (Head)", Part = "Head"}, {Name = "Торс (Torso)", Part = "UpperTorso"}, {Name = "Руки/Ноги (LeftLowerArm)", Part = "LeftLowerArm"}}) do
    local b = createActionBtn(HitboxPartContainer, hp.Name)
    b.MouseButton1Click:Connect(function() HitboxTargetName, HitboxPartBtn.Text, HitboxPartContainer.Visible = hp.Part, "Hitbox Part: " .. hp.Name, false end)
end
HitboxPartBtn.MouseButton1Click:Connect(function() HitboxPartContainer.Visible = not HitboxPartContainer.Visible end)

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

-- === FLING TAB ===
createLabel(FlingTab, "МОДУЛЬ РАСКИДА (FLING)")
local InvisFlingToggle = createActionBtn(FlingTab, "Invis Fling: OFF")
local AntiFlingToggle = createActionBtn(FlingTab, "Anti Fling (No Collision): OFF")

-- === TROLL TAB ===
createLabel(TrollTab, "ТРОЛЛИНГ И ФАН ФУНКЦИИ")
local VisualSpinToggle = createActionBtn(TrollTab, "Visual Spin: OFF")
local InvisibleToggle = createActionBtn(TrollTab, "Invisible (Ghost): OFF")
local JitterToggle = createActionBtn(TrollTab, "Jitter / Shake: OFF")

-- === HAMSTER TAB ===
createLabel(HamsterTab, "КЛИКЕР HAMSTER COIN")
local HamsterCounterLabel = Instance.new("TextLabel", Header)
HamsterCounterLabel.Size, HamsterCounterLabel.Position, HamsterCounterLabel.BackgroundTransparency, HamsterCounterLabel.Text, HamsterCounterLabel.TextColor3, HamsterCounterLabel.TextSize, HamsterCounterLabel.Font, HamsterCounterLabel.TextXAlignment = UDim2.new(0, 200, 0, 30), UDim2.new(1, -210, 0, 12), true, "Hamster Coins: 0", Color3.fromRGB(255, 215, 0), 14, Enum.Font.GothamBold, Enum.TextXAlignment.Right

local ClickerContainer = Instance.new("Frame", HamsterTab)
ClickerContainer.Size, ClickerContainer.BackgroundTransparency = UDim2.new(1, 0, 1, -30), 1
local HamsterClickBtn = Instance.new("TextButton", ClickerContainer)
HamsterClickBtn.Size, HamsterClickBtn.Position, HamsterClickBtn.BackgroundColor3, HamsterClickBtn.BackgroundTransparency, HamsterClickBtn.Text, HamsterClickBtn.TextColor3, HamsterClickBtn.TextSize, HamsterClickBtn.Font = UDim2.new(0, 190, 0, 190), UDim2.new(0.5, -95, 0.5, -95), Color3.fromRGB(18, 10, 28), 0.2, "🐹", Color3.fromRGB(255, 255, 255), 68, Enum.Font.GothamBold
Instance.new("UICorner", HamsterClickBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", HamsterClickBtn).Color, Instance.new("UIStroke", HamsterClickBtn).Thickness = Color3.fromRGB(210, 130, 255), 3.5

HamsterClickBtn.MouseButton1Click:Connect(function()
    HamsterCoins = HamsterCoins + 1
    HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
    TweenService:Create(HamsterClickBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 165, 0, 165), Position = UDim2.new(0.5, -82.5, 0.5, -82.5)}):Play()
    task.delay(0.06, function() TweenService:Create(HamsterClickBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 190, 0, 190), Position = UDim2.new(0.5, -95, 0.5, -95)}):Play() end)
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
    local configData = {AssistActive = AssistActive, AssistKey = AssistKey and AssistKey.Name or "E", AssistSmooth = AssistSmooth, TargetPartName = TargetPartName, FOVEnabled = FOVEnabled, FOVRadius = FOVRadius, TouchAssistActive = TouchAssistActive, TouchAssistSmooth = TouchAssistSmooth, TouchAssistFOV = TouchAssistFOV, VisualsEnabled = VisualsEnabled, VisualsTransparency = VisualsTransparency, HitboxEnabled = HitboxEnabled, HitboxKey = HitboxKey and HitboxKey.Name or "Q", HitboxTargetName = HitboxTargetName, HitboxSize = HitboxSize, HitboxTransparency = HitboxTransparency, InvisFlingEnabled = InvisFlingEnabled, AntiFlingEnabled = AntiFlingEnabled, HamsterCoins = HamsterCoins, WalkSpeedEnabled = WalkSpeedEnabled, CustomWalkSpeed = CustomWalkSpeed, JumpPowerEnabled = JumpPowerEnabled, CustomJumpPower = CustomJumpPower, FlyEnabled = FlyEnabled, FlyKey = FlyKey and FlyKey.Name or "F", FlySpeed = FlySpeed}
    pcall(function() writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(configData)) end)
end

local function loadConfig(name)
    if not readfile or not isfile then return end
    if name == "" then name = "default" end
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if success and data then
            AssistActive, AssistSmooth, TargetPartName, FOVEnabled, FOVRadius = data.AssistActive or false, data.AssistSmooth or 0.5, data.TargetPartName or "Head", data.FOVEnabled ~= false, data.FOVRadius or 120
            if data.AssistKey and Enum.KeyCode[data.AssistKey] then AssistKey = Enum.KeyCode[data.AssistKey]; KeyBindBtn.Text = "Bind Key: " .. AssistKey.Name end
            TouchAssistActive, TouchAssistSmooth, TouchAssistFOV = data.TouchAssistActive or false, data.TouchAssistSmooth or 0.5, data.TouchAssistFOV or 150
            VisualsEnabled, VisualsTransparency = data.VisualsEnabled or false, data.VisualsTransparency or 0.5
            HitboxEnabled, HitboxTargetName, HitboxSize, HitboxTransparency = data.HitboxEnabled or false, data.HitboxTargetName or "HumanoidRootPart", data.HitboxSize or 4, data.HitboxTransparency or 0.5
            if data.HitboxKey and Enum.KeyCode[data.HitboxKey] then HitboxKey = Enum.KeyCode[data.HitboxKey]; HitboxKeyBindBtn.Text = "Hitbox Bind: " .. HitboxKey.Name end
            InvisFlingEnabled, AntiFlingEnabled, HamsterCoins = data.InvisFlingEnabled or false, data.AntiFlingEnabled or false, data.HamsterCoins or 0
            HamsterCounterLabel.Text = "Hamster Coins: " .. HamsterCoins
            WalkSpeedEnabled, CustomWalkSpeed, JumpPowerEnabled, CustomJumpPower = data.WalkSpeedEnabled or false, data.CustomWalkSpeed or 16, data.JumpPowerEnabled or false, data.CustomJumpPower or 50
            FlyEnabled = data.FlyEnabled or false
            if data.FlyKey and Enum.KeyCode[data.FlyKey] then FlyKey = Enum.KeyCode[data.FlyKey]; FlyKeyBindBtn.Text = "Fly Bind: " .. FlyKey.Name end
            FlySpeed = data.FlySpeed or 50
            ToggleBtn.Text = AssistActive and "Assist System: ON" or "Assist System: OFF"
            MobileAimToggle.Text = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF"
            MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF"
            ESPToggleBtn.Text = VisualsEnabled and "Visuals: ON" or "Visuals: OFF"
            HitboxToggle.Text = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF"
            InvisFlingToggle.Text = InvisFlingEnabled and "Invis Fling: ON" or "Invis Fling: OFF"
            AntiFlingToggle.Text = AntiFlingEnabled and "Anti Fling (No Collision): ON" or "Anti Fling (No Collision): OFF"
            SpeedToggle.Text = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF"
            JumpToggle.Text = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF"
            FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
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
            AutoLoadEnabled, AutoLoadConfigName = true, autoData.ConfigName
            AutoLoadBtn.Text, AutoLoadBtn.TextColor3 = "Auto-Load: " .. AutoLoadConfigName, Color3.fromRGB(160, 255, 120)
            loadConfig(AutoLoadConfigName)
        end
    end
end)

SaveConfigBtn.MouseButton1Click:Connect(function() saveConfig(ConfigNameInput.Text ~= "" and ConfigNameInput.Text or "default"); SaveConfigBtn.Text = "Saved!"; task.delay(1.5, function() SaveConfigBtn.Text = "Save Config" end) end)
LoadConfigBtn.MouseButton1Click:Connect(function() loadConfig(ConfigNameInput.Text ~= "" and ConfigNameInput.Text or "default"); LoadConfigBtn.Text = "Loaded!"; task.delay(1.5, function() LoadConfigBtn.Text = "Load Config" end) end)
AutoLoadBtn.MouseButton1Click:Connect(function()
    AutoLoadEnabled = not AutoLoadEnabled
    local name = ConfigNameInput.Text ~= "" and ConfigNameInput.Text or CurrentConfigName
    AutoLoadBtn.Text, AutoLoadBtn.TextColor3 = AutoLoadEnabled and ("Auto-Load: " .. name) or "Auto-Load: OFF", AutoLoadEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if writefile then writefile(AutoLoadFileName, HttpService:JSONEncode({Enabled = AutoLoadEnabled, ConfigName = name})) end
end)

Players.PlayerRemoving:Connect(function(plr) if plr == LocalPlayer then saveConfig(AutoLoadEnabled and AutoLoadConfigName or CurrentConfigName) end end)
UnloadBtn.MouseButton1Click:Connect(function()
    saveConfig(AutoLoadEnabled and AutoLoadConfigName or CurrentConfigName)
    pcall(function() if FOVCircle then FOVCircle:Remove() end end)
    for _, data in pairs(VisualsMap) do if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end end
    ScreenGui:Destroy(); MobileGui:Destroy()
end)

local bindingAimKey, bindingFlyKey, bindingHitboxKey = false, false, false
KeyBindBtn.MouseButton1Click:Connect(function() bindingAimKey, bindingFlyKey, bindingHitboxKey, KeyBindBtn.Text = true, false, false, "Press any key..." end)
FlyKeyBindBtn.MouseButton1Click:Connect(function() bindingFlyKey, bindingAimKey, bindingHitboxKey, FlyKeyBindBtn.Text = true, false, false, "Press any key..." end)
HitboxKeyBindBtn.MouseButton1Click:Connect(function() bindingHitboxKey, bindingAimKey, bindingFlyKey, HitboxKeyBindBtn.Text = true, false, false, "Press any key..." end)

-- Стабильный классический Fly (BodyVelocity + BodyGyro)
local function toggleFlyFunc()
    FlyEnabled = not FlyEnabled
    FlyToggle.Text, FlyToggle.TextColor3 = FlyEnabled and "Fly: ON" or "Fly: OFF", FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if FlyEnabled then
        hum.PlatformStand = true
        if bg then bg:Destroy() end; if bv then bv:Destroy() end
        bg = Instance.new("BodyGyro", hrp); bg.P, bg.MaxTorque, bg.CFrame = 9e4, Vector3.new(9e4, 9e4, 9e4), hrp.CFrame
        bv = Instance.new("BodyVelocity", hrp); bv.Velocity, bv.MaxForce = Vector3.new(0, 0, 0), Vector3.new(9e4, 9e4, 9e4)

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if flyConnection then flyConnection:Disconnect() end; return
            end
            local currentHrp, currentHum = LocalPlayer.Character.HumanoidRootPart, LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if currentHum then currentHum.PlatformStand = true end
            if bg and bv then
                bg.CFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                local camCF = Camera.CFrame
                pcall(function()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                end)
                if controlModule then
                    local rawMove = controlModule:GetMoveVector()
                    if rawMove.Magnitude > 0 then moveDir = moveDir + (camCF.RightVector * rawMove.X + camCF.LookVector * rawMove.Z) end
                end
                bv.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * FlySpeed) or Vector3.new(0, 0.1, 0)
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bg then bg:Destroy() end; if bv then bv:Destroy() end
        if hum then hum.PlatformStand = false end
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end

-- Троллинг логика
VisualSpinToggle.MouseButton1Click:Connect(function()
    VisualSpinEnabled = not VisualSpinEnabled
    VisualSpinToggle.Text, VisualSpinToggle.TextColor3 = VisualSpinEnabled and "Visual Spin: ON" or "Visuals Spin: OFF", VisualSpinEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

InvisibleToggle.MouseButton1Click:Connect(function()
    InvisibleEnabled = not InvisibleEnabled
    InvisibleToggle.Text, InvisibleToggle.TextColor3 = InvisibleEnabled and "Invisible (Ghost): ON" or "Invisible (Ghost): OFF", InvisibleEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = InvisibleEnabled and 1 or (part.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
    end
end)

JitterToggle.MouseButton1Click:Connect(function()
    JitterEnabled = not JitterEnabled
    JitterToggle.Text, JitterToggle.TextColor3 = JitterEnabled and "Jitter / Shake: ON" or "Jitter / Shake: OFF", JitterEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
end)

local function toggleHitboxFunc()
    HitboxEnabled = not HitboxEnabled
    HitboxToggle.Text, HitboxToggle.TextColor3 = HitboxEnabled and "Hitbox Extender: ON" or "Hitbox Extender: OFF", HitboxEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if not HitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, partName in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "LeftLowerArm"}) do
                    local part = p.Character:FindFirstChild(partName)
                    if part and OriginalSizes[part] then part.Size, part.Transparency, part.CanCollide = OriginalSizes[part], 1, false end
                end
            end
        end
    end
end

InvisFlingToggle.MouseButton1Click:Connect(function() InvisFlingEnabled = not InvisFlingEnabled; InvisFlingToggle.Text, InvisFlingToggle.TextColor3 = InvisFlingEnabled and "Invis Fling: ON" or "Invis Fling: OFF", InvisFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250) end)
AntiFlingToggle.MouseButton1Click:Connect(function() AntiFlingEnabled = not AntiFlingEnabled; AntiFlingToggle.Text, AntiFlingToggle.TextColor3 = AntiFlingEnabled and "Anti Fling (No Collision): ON" or "Anti Fling (No Collision): OFF", AntiFlingEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250) end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if bindingAimKey then AssistKey, KeyBindBtn.Text, bindingAimKey = input.KeyCode, "Bind Key: " .. input.KeyCode.Name, false; return end
        if bindingFlyKey then FlyKey, FlyKeyBindBtn.Text, bindingFlyKey = input.KeyCode, "Fly Bind: " .. input.KeyCode.Name, false; return end
        if bindingHitboxKey then HitboxKey, HitboxKeyBindBtn.Text, bindingHitboxKey = input.KeyCode, "Hitbox Bind: " .. input.KeyCode.Name, false; return end
        if input.KeyCode == ToggleKey then MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == FlyKey then toggleFlyFunc()
        elseif input.KeyCode == HitboxKey then toggleHitboxFunc() end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function() AssistActive = not AssistActive; ToggleBtn.Text, ToggleBtn.TextColor3 = AssistActive and "Assist System: ON" or "Assist System: OFF", AssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250) end)
MobileAimToggle.MouseButton1Click:Connect(function() TouchAssistActive = not TouchAssistActive; MobileAimToggle.Text, MobileAimToggle.TextColor3 = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF", TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250); MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF" end)
MobileAimToggleBtn.MouseButton1Click:Connect(function() TouchAssistActive = not TouchAssistActive; MobileAimToggle.Text, MobileAimToggle.TextColor3 = TouchAssistActive and "Mobile Assist: ON" or "Mobile Assist: OFF", TouchAssistActive and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250); MobileAimToggleBtn.Text = TouchAssistActive and "Mob.Aim: ON" or "Mob.Aim: OFF" end)

MobileAimSmoothInput.FocusLost:Connect(function() local val = tonumber(MobileAimSmoothInput.Text); if val then TouchAssistSmooth = math.clamp(val, 0, 0.99) end end)
MobileAimFOVInput.FocusLost:Connect(function() local val = tonumber(MobileAimFOVInput.Text); if val then TouchAssistFOV = math.clamp(val, 10, 500) end end)
PartDropdownBtn.MouseButton1Click:Connect(function() PartFrame.Visible = not PartFrame.Visible end)
SmoothInput.FocusLost:Connect(function() local val = tonumber(SmoothInput.Text); if val then AssistSmooth = math.clamp(val, 0, 0.99) end end)
FOVToggleBtn.MouseButton1Click:Connect(function() FOVEnabled = not FOVEnabled; FOVToggleBtn.Text = FOVEnabled and "FOV Circle: ON" or "FOV Circle: OFF" end)
FOVRadiusInput.FocusLost:Connect(function() local val = tonumber(FOVRadiusInput.Text); if val then FOVRadius = math.clamp(val, 10, 500) end end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    VisualsEnabled = not VisualsEnabled
    ESPToggleBtn.Text, ESPToggleBtn.TextColor3 = VisualsEnabled and "Visuals: ON" or "Visuals: OFF", VisualsEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    if not VisualsEnabled then for _, data in pairs(VisualsMap) do if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end end; VisualsMap = {} end
end)
ESPTransInput.FocusLost:Connect(function() local val = tonumber(ESPTransInput.Text); if val then VisualsTransparency = math.clamp(val, 0, 1) end end)
HitboxToggle.MouseButton1Click:Connect(toggleHitboxFunc)
HitboxSizeInput.FocusLost:Connect(function() local val = tonumber(HitboxSizeInput.Text); if val then HitboxSize = math.clamp(val, 1, 30) end end)
HitboxTransInput.FocusLost:Connect(function() local val = tonumber(HitboxTransInput.Text); if val then HitboxTransparency = math.clamp(val, 0, 1) end end)

SpeedToggle.MouseButton1Click:Connect(function() WalkSpeedEnabled = not WalkSpeedEnabled; SpeedToggle.Text, SpeedToggle.TextColor3 = WalkSpeedEnabled and "WalkSpeed: ON" or "WalkSpeed: OFF", WalkSpeedEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250) end)
SpeedInput.FocusLost:Connect(function() local val = tonumber(SpeedInput.Text); if val then CustomWalkSpeed = val end end)
JumpToggle.MouseButton1Click:Connect(function() JumpPowerEnabled = not JumpPowerEnabled; JumpToggle.Text, JumpToggle.TextColor3 = JumpPowerEnabled and "JumpPower: ON" or "JumpPower: OFF", JumpPowerEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250) end)
JumpInput.FocusLost:Connect(function() local val = tonumber(JumpInput.Text); if val then CustomJumpPower = val end end)
FlyToggle.MouseButton1Click:Connect(toggleFlyFunc)
FlyMobileBtn.MouseButton1Click:Connect(toggleFlyFunc)
FlySpeedInput.FocusLost:Connect(function() local val = tonumber(FlySpeedInput.Text); if val then FlySpeed = val end end)

local function getClosestTarget()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local refPos = TouchAssistActive and screenCenter or UserInputService:GetMouseLocation()
    local activeFOV = TouchAssistActive and TouchAssistFOV or FOVRadius
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChildOfClass("Humanoid") then
        if LockedTarget.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
            local _, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            if onScreen and (Vector2.new(Camera:WorldToViewportPoint(LockedTarget.Position).X, Camera:WorldToViewportPoint(LockedTarget.Position).Y) - refPos).Magnitude <= (activeFOV * 1.5) then return LockedTarget end
        end
    end
    local closestTarget, bestScore = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum, part = player.Character:FindFirstChildOfClass("Humanoid"), player.Character:FindFirstChild(TargetPartName) or player.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - refPos).Magnitude
                    if dist <= activeFOV and dist < bestScore then bestScore, closestTarget = dist, part end
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
        FOVCircle.Visible = FOVEnabled or TouchAssistActive
        FOVCircle.Radius = activeFOV
        FOVCircle.Position = TouchAssistActive and screenCenter or UserInputService:GetMouseLocation()
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = not AntiFlingEnabled end end
        end
    end

    -- Обработка Troll функций
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if VisualSpinEnabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(25), 0)
        end
        if JitterEnabled then
            hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-0.3, 0.3), 0, math.random(-0.3, 0.3))
        end
    end

    if InvisFlingEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
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

    if (AssistActive or TouchAssistActive) and (TouchAssistActive or (AssistKey and UserInputService:IsKeyDown(AssistKey))) then
        local target = getClosestTarget()
        if target then
            if not TouchAssistActive then
                local curMouse, scrPos = UserInputService:GetMouseLocation(), Camera:WorldToViewportPoint(target.Position)
                local moveDelta = Vector2.new(scrPos.X, scrPos.Y) - curMouse
                mousemoverel(moveDelta.X * (1 - AssistSmooth), moveDelta.Y * (1 - AssistSmooth))
            else
                local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - TouchAssistSmooth)
            end
        end
    else
        LockedTarget = nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if VisualsEnabled then
                local char, hum, head = player.Character, player.Character and player.Character:FindFirstChildOfClass("Humanoid"), player.Character and player.Character:FindFirstChild("Head")
                if char and hum and head and hum.Health > 0 then
                    if not VisualsMap[player] then VisualsMap[player] = {} end
                    if not VisualsMap[player].Highlight or VisualsMap[player].Highlight.Parent ~= char then
                        if VisualsMap[player].Highlight then VisualsMap[player].Highlight:Destroy() end
                        local hl = Instance.new("Highlight", char)
                        hl.Adornee, hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.OutlineTransparency = char, Color3.fromRGB(170, 90, 255), Color3.fromRGB(230, 180, 255), VisualsTransparency, 0.1
                        VisualsMap[player].Highlight = hl
                    else VisualsMap[player].Highlight.FillTransparency = VisualsTransparency end

                    if not VisualsMap[player].Billboard or VisualsMap[player].Billboard.Parent ~= head then
                        if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end
                        local bb = Instance.new("BillboardGui", head)
                        bb.Name, bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Adornee = "TimonESP", UDim2.new(0, 120, 0, 50), Vector3.new(0, 2.5, 0), true, head
                        local nameLabel = Instance.new("TextLabel", bb)
                        nameLabel.Size, nameLabel.BackgroundTransparency, nameLabel.Text, nameLabel.TextColor3, nameLabel.TextSize, nameLabel.Font, nameLabel.TextStrokeTransparency = UDim2.new(1, 0, 0, 20), true, player.Name, Color3.fromRGB(245, 230, 255), 12, Enum.Font.GothamBold, 0.5
                        local hpBg = Instance.new("Frame", bb)
                        hpBg.Size, hpBg.Position, hpBg.BackgroundColor3, hpBg.BorderSizePixel = UDim2.new(0.8, 0, 0, 6), UDim2.new(0.1, 0, 0, 22), Color3.fromRGB(30, 20, 45), 0
                        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
                        local hpBar = Instance.new("Frame", hpBg)
                        hpBar.Size, hpBar.BackgroundColor3, hpBar.BorderSizePixel = UDim2.new(1, 0, 1, 0), Color3.fromRGB(120, 255, 120), 0
                        Instance.new("UICorner", hpBar).CornerRadius = UDim.new(1, 0)
                        VisualsMap[player].Billboard, VisualsMap[player].HpBar = bb, hpBar
                    else
                        local hpBar = VisualsMap[player].HpBar
                        if hpBar then
                            local p = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            hpBar.Size, hpBar.BackgroundColor3 = UDim2.new(p, 0, 1, 0), Color3.fromRGB(255 * (1 - p), 255 * p, 80)
                        end
                    end
                else
                    if VisualsMap[player] then if VisualsMap[player].Highlight then VisualsMap[Player].Highlight:Destroy() end if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end VisualsMap[player] = nil end
                end
            else
                if VisualsMap[player] then if VisualsMap[player].Highlight then VisualsMap[player].Highlight:Destroy() end if VisualsMap[player].Billboard then VisualsMap[player].Billboard:Destroy() end VisualsMap[player] = nil end
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
                    targetPart.Size, targetPart.Transparency, targetPart.Material, targetPart.CanCollide = Vector3.new(HitboxSize, HitboxSize, HitboxSize), HitboxTransparency, Enum.Material.Neon, false
                end
            end
        end
    end
end)