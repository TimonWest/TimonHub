-- ============================================================================
-- UNIVERSAL ROBLOX EXECUTOR SCRIPT (PC & MOBILE) - FULLY FEATURED
-- ============================================================================

if getgenv().TWKS_LOADED then
    pcall(function() getgenv().TWKS_UNLOAD() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().TWKS_LOADED = true

local Settings = {
    Aimbot = {
        Enabled = false,
        Mode = "Cursor",
        Smoothness = 0.2,
        FOV = 100,
        TargetPart = "Head",
        TeamCheck = true,
        VisibleCheck = true,
        Key = Enum.KeyCode.E,
        MobileButton = true
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        TeamCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 100),
        InvisibleColor = Color3.fromRGB(255, 50, 50),
        Thickness = 1
    },
    Hitbox = {
        Enabled = false,
        Size = 5,
        Transparency = 0.7,
        Color = Color3.fromRGB(128, 128, 128),
        Parts = {Head = true, Torso = false, Arms = false, Legs = false}
    },
    Player = {
        Fly = false,
        FlySpeed = 50,
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        Noclip = false
    }
}

getgenv().TWKS_SETTINGS = Settings

-- ============================ NOTIFICATIONS ============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_GUI"
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function Notify(text)
    task.spawn(function()
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 220, 0, 40)
        notif.Position = UDim2.new(1, -230, 1, -60)
        notif.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
        notif.BackgroundTransparency = 0.2
        notif.BorderSizePixel = 0
        notif.Parent = ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notif

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(180, 0, 255)
        stroke.Thickness = 1
        stroke.Parent = notif

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.SourceSansBold
        label.Text = text
        label.Parent = notif

        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -230, 1, -80)}):Play()
        task.wait(2)
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -230, 1, -20), BackgroundTransparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

Notify("TWKS Fully Loaded")

-- ============================ AIMBOT ============================
local function GetClosestPlayer()
    local target = nil
    local shortestDist = Settings.Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = char:FindFirstChild(Settings.Aimbot.TargetPart) or char:FindFirstChild("Head")
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist
                        if Settings.Aimbot.Mode == "Cursor" then
                            local mouse = UserInputService:GetMouseLocation()
                            dist = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                        else
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        end

                        if dist < shortestDist then
                            if Settings.Aimbot.VisibleCheck then
                                local origin = Camera.CFrame.Position
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                                local result = Workspace:Raycast(origin, part.Position - origin, rayParams)
                                if not result then
                                    shortestDist = dist
                                    target = part
                                end
                            else
                                shortestDist = dist
                                target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target then
            local camPos = Camera.CFrame.Position
            local targetCFrame = CFrame.new(camPos, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothness)
        end
    end
end)

-- ============================ ESP ============================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }

    drawings.Box.Visible = false
    drawings.Box.Filled = false
    drawings.Box.Thickness = Settings.ESP.Thickness

    drawings.Name.Visible = false
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)

    drawings.Distance.Visible = false
    drawings.Distance.Size = 12
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color = Color3.fromRGB(200, 200, 200)

    ESPObjects[player] = drawings
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for _, obj in pairs(ESPObjects[p]) do pcall(function() obj:Remove() end) end
        ESPObjects[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if Settings.ESP.Enabled and char and root and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local head = char:FindFirstChild("Head")
                local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = math.abs(topPos.Y - bottomPos.Y)
                local width = height / 2

                if Settings.ESP.Boxes then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(pos.X - width / 2, topPos.Y)
                    local isVisible = true
                    if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                        isVisible = false
                    end
                    drawings.Box.Color = isVisible and Settings.ESP.VisibleColor or Settings.ESP.InvisibleColor
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end

                if Settings.ESP.Names then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(pos.X, topPos.Y - 18)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end

                if Settings.ESP.Distance then
                    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                    drawings.Distance.Text = tostring(dist) .. "m"
                    drawings.Distance.Position = Vector2.new(pos.X, bottomPos.Y + 2)
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end
            else
                for _, obj in pairs(drawings) do obj.Visible = false end
            end
        else
            for _, obj in pairs(drawings) do obj.Visible = false end
        end
    end
end)

-- ============================ HITBOX EDITOR ============================
local OriginalSizes = {}

task.spawn(function()
    while task.wait(1) do
        if Settings.Hitbox.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    for _, partName in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "UpperTorso", "LowerTorso"}) do
                        local part = char:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            if not OriginalSizes[part] then
                                OriginalSizes[part] = part.Size
                            end
                            if Settings.Hitbox.Parts[partName] or (partName == "Head" and Settings.Hitbox.Parts.Head) then
                                part.Size = OriginalSizes[part] * (Settings.Hitbox.Size / 2)
                                part.Transparency = Settings.Hitbox.Transparency
                                part.Color = Settings.Hitbox.Color
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        else
            for part, origSize in pairs(OriginalSizes) do
                if part and part.Parent then
                    part.Size = origSize
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
            OriginalSizes = {}
        end
    end
end)

-- ============================ PLAYER FUNCTIONS ============================
local function ApplyPlayerMods()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Player.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.Player.JumpPower
    end
end

RunService.Heartbeat:Connect(ApplyPlayerMods)

UserInputService.JumpRequest:Connect(function()
    if Settings.Player.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Player.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly System
local BodyVelocity, BodyGyro
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if Settings.Player.Fly and root then
        if not BodyVelocity then
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.Parent = root
        end
        if not BodyGyro then
            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            BodyGyro.Parent = root
        end
        
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        
        BodyVelocity.Velocity = moveDir * Settings.Player.FlySpeed
        BodyGyro.CFrame = Camera.CFrame
    else
        if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    end
end)

-- ============================ MENU (GUI) ============================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(180, 0, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 20, 147)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "TWKS - Universal Hub"
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "×"
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Sidebar Tabs
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -145, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Pages = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 4
    page.Parent = ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page

    Pages[name] = page
    return page
end

-- Tabs creation
local tabNames = {"Aimbot", "ESP", "Hitbox", "Player", "Settings"}
local firstTab = true
for _, tName in ipairs(tabNames) do
    local page = CreatePage(tName)
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    tabBtn.BackgroundTransparency = firstTab and 0.2 or 0.6
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.Text = tName
    tabBtn.Parent = Sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = tabBtn

    if firstTab then
        page.Visible = true
        firstTab = false
    end

    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundTransparency = 0.6 end
        end
        page.Visible = true
        tabBtn.BackgroundTransparency = 0.2
    end)
end

-- Helper to add Toggles
local function AddToggle(page, text, state, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 35)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.SourceSans
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.Text = "  " .. text .. ": " .. (state and "ON" or "OFF")
    toggleBtn.Parent = page

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = "  " .. text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Populate Aimbot Page
AddToggle(Pages.Aimbot, "Aimbot Enabled", Settings.Aimbot.Enabled, function(v) Settings.Aimbot.Enabled = v end)
AddToggle(Pages.Aimbot, "Team Check", Settings.Aimbot.TeamCheck, function(v) Settings.Aimbot.TeamCheck = v end)
AddToggle(Pages.Aimbot, "Visible Check", Settings.Aimbot.VisibleCheck, function(v) Settings.Aimbot.VisibleCheck = v end)

-- Populate ESP Page
AddToggle(Pages.ESP, "ESP Enabled", Settings.ESP.Enabled, function(v) Settings.ESP.Enabled = v end)
AddToggle(Pages.ESP, "Draw Boxes", Settings.ESP.Boxes, function(v) Settings.ESP.Boxes = v end)
AddToggle(Pages.ESP, "Show Names", Settings.ESP.Names, function(v) Settings.ESP.Names = v end)
AddToggle(Pages.ESP, "Show Distance", Settings.ESP.Distance, function(v) Settings.ESP.Distance = v end)

-- Populate Hitbox Page
AddToggle(Pages.Hitbox, "Hitbox Expander", Settings.Hitbox.Enabled, function(v) Settings.Hitbox.Enabled = v end)

-- Populate Player Page
AddToggle(Pages.Player, "Fly", Settings.Player.Fly, function(v) Settings.Player.Fly = v end)
AddToggle(Pages.Player, "Infinite Jump", Settings.Player.InfiniteJump, function(v) Settings.Player.InfiniteJump = v end)
AddToggle(Pages.Player, "Noclip", Settings.Player.Noclip, function(v) Settings.Player.Noclip = v end)

-- Populate Settings Page
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 35)
unloadBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
unloadBtn.BackgroundTransparency = 0.3
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.TextSize = 14
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.Text = "Unload Script"
unloadBtn.Parent = Pages.Settings

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 6)
uc.Parent = unloadBtn

unloadBtn.MouseButton1Click:Connect(function()
    pcall(function() getgenv().TWKS_UNLOAD() end)
end)

-- Accent animation
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            UIStroke.Color = Color3.fromHSV(i, 0.8, 1)
            task.wait(0.05)
        end
    end
end)

-- Mobile Open Button
local MobileBtn = Instance.new("TextButton")
MobileBtn.Size = UDim2.new(0, 50, 0, 50)
MobileBtn.Position = UDim2.new(0, 20, 0.5, -25)
MobileBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
MobileBtn.BackgroundTransparency = 0.3
MobileBtn.TextColor3 = Color3.fromRGB(180, 0, 255)
MobileBtn.TextSize = 14
MobileBtn.Font = Enum.Font.SourceSansBold
MobileBtn.Text = "TWKS"
MobileBtn.Draggable = true
MobileBtn.Parent = ScreenGui

local MBoras = Instance.new("UICorner")
MBoras.CornerRadius = UDim.new(1, 0)
MBoras.Parent = MobileBtn

MobileBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Keybind to toggle menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftAlt then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

getgenv().TWKS_UNLOAD = function()
    ScreenGui:Destroy()
    getgenv().TWKS_LOADED = false
end