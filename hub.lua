-- ============================================================================
-- TWKS HUB v2.1 — Cursor Aim + Mobile Aim + Full Binds
-- ============================================================================

if getgenv().TWKS_LOADED then
    pcall(function() getgenv().TWKS_UNLOAD() end)
end

getgenv().TWKS_LISTENING = nil

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Tween      = game:GetService("TweenService")
local CoreGui    = game:GetService("CoreGui")
local Workspace  = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().TWKS_LOADED = true

-- ============================================================
-- SETTINGS
-- ============================================================
local S = {
    Aimbot = {
        Enabled = false,
        Mode = "Cursor",      -- Cursor / Camera / Mobile
        Smooth = 0.25,
        FOV = 200,
        Part = "Head",
        TeamCheck = true,
        VisibleCheck = false,
        ShowFOV = true,
        UseMouseMove = true   -- пробовать mousemoverel
    },
    ESP = {
        Enabled = false, Boxes = true, Names = true,
        Distance = true, Health = true,
        Color = Color3.fromRGB(255, 20, 147), Thickness = 1
    },
    Hitbox = {
        Enabled = false, Size = 5, Transparency = 0.6,
        Color = Color3.fromRGB(128,128,128),
        Parts = {Head=true, Torso=false, Arms=false, Legs=false}
    },
    Player = {
        Fly = false, FlySpeed = 50,
        WalkSpeed = 16, JumpPower = 50,
        InfiniteJump = false, Noclip = false
    },
    Binds = {},
    MobileBtns = {}
}
getgenv().TWKS_SETTINGS = S

-- ============================================================
-- COLORS + HELPERS
-- ============================================================
local COL = {
    bg = Color3.fromRGB(18,12,24), bg2 = Color3.fromRGB(28,18,38),
    elem = Color3.fromRGB(38,24,50),
    accent = Color3.fromRGB(180,60,255), accent2 = Color3.fromRGB(255,60,180),
    text = Color3.fromRGB(240,230,255), sub = Color3.fromRGB(160,140,180),
    stroke = Color3.fromRGB(80,40,110), off = Color3.fromRGB(60,50,70)
}

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c
end
local function stroke(o, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or COL.stroke; s.Thickness = t or 1
    s.Parent = o; return s
end
local function MakeDraggable(frame, dragBar)
    local dragging, dragStart, startPos
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,
                startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================
-- GUI BASE
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local function Notify(txt)
    task.spawn(function()
        local n = Instance.new("Frame")
        n.Size = UDim2.new(0, 250, 0, 42)
        n.Position = UDim2.new(1, -270, 1, -80)
        n.BackgroundColor3 = COL.bg2
        n.BackgroundTransparency = 0.1
        n.BorderSizePixel = 0
        n.Parent = ScreenGui
        corner(n, 8); stroke(n, COL.accent, 1.5)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-20,1,0); l.Position = UDim2.new(0,12,0,0)
        l.BackgroundTransparency = 1; l.Text = txt
        l.TextColor3 = COL.text; l.Font = Enum.Font.Gotham
        l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = n
        Tween:Create(n, TweenInfo.new(0.3), {Position = UDim2.new(1,-270,1,-100)}):Play()
        task.wait(2.5)
        Tween:Create(n, TweenInfo.new(0.3),
            {Position = UDim2.new(1,-270,1,-40), BackgroundTransparency = 1}):Play()
        Tween:Create(l, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.35); n:Destroy()
    end)
end

-- ============================================================
-- REFRESHERS
-- ============================================================
local Refreshers = {}
local function AddRefresh(fn) table.insert(Refreshers, fn) end
local function RefreshAll()
    for _, fn in ipairs(Refreshers) do pcall(fn) end
end

-- ============================================================
-- WIDGETS
-- ============================================================
local ORDER = 0
local function NextOrder() ORDER = ORDER + 1; return ORDER end

local function Section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = NextOrder()
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
    l.Text = string.upper(text)
    l.TextColor3 = COL.accent2; l.Font = Enum.Font.GothamBold
    l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

local function Toggle(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,34)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,38,0,18); track.Position = UDim2.new(1,-50,0.5,-9)
    track.BackgroundColor3 = COL.off; track.BorderSizePixel = 0
    track.Parent = f; corner(track, 9)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    knob.Parent = track; corner(knob, 7)
    local function render()
        if getter() then
            track.BackgroundColor3 = COL.accent2
            Tween:Create(knob, TweenInfo.new(0.15),
                {Position = UDim2.new(1,-16,0.5,-7)}):Play()
        else
            track.BackgroundColor3 = COL.off
            Tween:Create(knob, TweenInfo.new(0.15),
                {Position = UDim2.new(0,2,0.5,-7)}):Play()
        end
    end
    render(); AddRefresh(render)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        setter(not getter()); render()
    end)
end

local function Slider(parent, name, minV, maxV, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,48)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,18); lbl.Position = UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-24,0,6); bar.Position = UDim2.new(0,12,0,32)
    bar.BackgroundColor3 = Color3.fromRGB(15,10,20); bar.BorderSizePixel = 0
    bar.Parent = f; corner(bar, 3)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL.accent; fill.BorderSizePixel = 0
    fill.Parent = bar; corner(fill, 3)
    local function render()
        local v = getter()
        local rel = math.clamp((v - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = name .. ": " .. tostring(math.floor(v*100+0.5)/100)
    end
    render(); AddRefresh(render)
    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(1,12,1,24); ca.Position = UDim2.new(0,-6,0,-9)
    ca.BackgroundTransparency = 1; ca.Text = ""; ca.Parent = bar
    local drag = false
    local function setX(px)
        local rel = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setter(minV + rel * (maxV - minV)); render()
    end
    ca.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; setX(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then setX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function Dropdown(parent, name, options, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,34)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-30,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0,20,1,0); arrow.Position = UDim2.new(1,-24,0,0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▾"
    arrow.TextColor3 = COL.sub; arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14; arrow.Parent = f
    local function render() lbl.Text = name .. ": " .. tostring(getter()) end
    render(); AddRefresh(render)
    local popup
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        if popup and popup.Parent then popup:Destroy(); popup = nil; return end
        popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, f.AbsoluteSize.X, 0, #options*26+6)
        popup.Position = UDim2.new(0, f.AbsolutePosition.X,
            0, f.AbsolutePosition.Y + f.AbsoluteSize.Y + 2)
        popup.BackgroundColor3 = COL.bg2; popup.BorderSizePixel = 0
        popup.ZIndex = 50; popup.Parent = ScreenGui
        corner(popup, 6); stroke(popup, COL.accent, 1)
        for i, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1,-8,0,22); ob.Position = UDim2.new(0,4,0,(i-1)*26+4)
            ob.BackgroundColor3 = COL.elem; ob.BorderSizePixel = 0
            ob.Text = opt; ob.TextColor3 = COL.text
            ob.Font = Enum.Font.Gotham; ob.TextSize = 13
            ob.ZIndex = 51; ob.Parent = popup; corner(ob, 4)
            ob.MouseButton1Click:Connect(function()
                setter(opt); render()
                if popup then popup:Destroy(); popup = nil end
            end)
        end
    end)
end

local PALETTE = {
    Color3.fromRGB(255,20,147), Color3.fromRGB(180,60,255),
    Color3.fromRGB(255,60,60),  Color3.fromRGB(60,255,60),
    Color3.fromRGB(60,120,255), Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,255,0),  Color3.fromRGB(255,150,0),
    Color3.fromRGB(255,255,255),Color3.fromRGB(128,128,128),
    Color3.fromRGB(180,0,255),  Color3.fromRGB(255,100,180)
}

local function ColorPicker(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,84)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,16); lbl.Position = UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local swatches = {}
    for i, c in ipairs(PALETTE) do
        local row = math.floor((i-1)/6); local col = (i-1) % 6
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,30,0,22); b.Position = UDim2.new(0,12+col*34,0,26+row*24)
        b.BackgroundColor3 = c; b.BorderSizePixel = 0
        b.Text = ""; b.Parent = f; corner(b, 3)
        local s = stroke(b, Color3.new(1,1,1), (c == getter()) and 2 or 0)
        swatches[#swatches+1] = {btn = b, line = s, color = c}
        b.MouseButton1Click:Connect(function()
            setter(c)
            for _, sw in ipairs(swatches) do sw.line.Thickness = 0 end
            s.Thickness = 2
        end)
    end
end

-- ============================================================
-- BINDS — фикс: MouseButton1Down + только Keyboard в InputBegan
-- ============================================================
local BindRefreshers = {}
local function BindButton(parent, action, name)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,34)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-120,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(0,100,0,26); keyLbl.Position = UDim2.new(1,-110,0.5,-13)
    keyLbl.BackgroundColor3 = COL.bg2; keyLbl.BorderSizePixel = 0
    keyLbl.TextColor3 = COL.accent2; keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 12; keyLbl.Parent = f; corner(keyLbl, 4)
    keyLbl.Active = false

    local function refresh()
        local k = S.Binds[action]
        if k then
            keyLbl.Text = tostring(k):gsub("Enum.KeyCode.","")
            keyLbl.TextColor3 = COL.accent2
        else
            keyLbl.Text = "None"
            keyLbl.TextColor3 = COL.sub
        end
    end
    refresh()
    BindRefreshers[action] = refresh

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,0,26); btn.Position = UDim2.new(1,-110,0.5,-13)
    btn.BackgroundTransparency = 1; btn.Text = ""
    btn.Active = true; btn.Parent = f

    btn.MouseButton1Down:Connect(function()
        getgenv().TWKS_LISTENING = action
        keyLbl.Text = "нажми..."
        keyLbl.TextColor3 = Color3.fromRGB(255,200,100)
    end)
end

-- ============================================================
-- MAIN FRAME + TABS
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 620, 0, 430)
Main.Position = UDim2.new(0.5,-310,0.5,-215)
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 12); stroke(Main, COL.accent, 1.5)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = COL.bg2
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0); TitleLbl.Position = UDim2.new(0,14,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "TWKS HUB  ·  v2.1"
TitleLbl.TextColor3 = COL.accent2; TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,26); CloseBtn.Position = UDim2.new(1,-34,0.5,-13)
CloseBtn.BackgroundColor3 = COL.accent2; CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
corner(CloseBtn, 4)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

MakeDraggable(Main, TitleBar)

local Left = Instance.new("Frame")
Left.Size = UDim2.new(0,140,1,-46)
Left.Position = UDim2.new(0,10,0,42)
Left.BackgroundColor3 = COL.bg2; Left.BackgroundTransparency = 0.1
Left.BorderSizePixel = 0; Left.Parent = Main
corner(Left, 8)

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0,4)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Parent = Left

local LeftPad = Instance.new("UIPadding")
LeftPad.PaddingTop = UDim.new(0,8)
LeftPad.PaddingLeft = UDim.new(0,6)
LeftPad.PaddingRight = UDim.new(0,6)
LeftPad.Parent = Left

local Right = Instance.new("Frame")
Right.Size = UDim2.new(1,-162,1,-46)
Right.Position = UDim2.new(0,156,0,42)
Right.BackgroundTransparency = 1
Right.Parent = Main

local TabScrolls = {}
local function Tab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = COL.elem; b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0; b.Text = name
    b.TextColor3 = COL.text; b.Font = Enum.Font.Gotham
    b.TextSize = 13; b.LayoutOrder = NextOrder()
    b.Parent = Left; corner(b, 6)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1,0,1,0)
    sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = COL.accent2
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false; sc.Parent = Right
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = sc
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,4)
    pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,10)
    pad.PaddingBottom = UDim.new(0,8)
    pad.Parent = sc
    TabScrolls[name] = {btn = b, scroll = sc}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(TabScrolls) do
            t.scroll.Visible = false
            t.btn.BackgroundColor3 = COL.elem
        end
        sc.Visible = true
        b.BackgroundColor3 = COL.accent
    end)
    return sc
end

-- ============================================================
-- AIMBOT TAB
-- ============================================================
local A = Tab("Aimbot")
Section(A, "Основное")
Toggle(A, "Enable Aimbot",
    function() return S.Aimbot.Enabled end,
    function(v) S.Aimbot.Enabled = v end)
Dropdown(A, "Aim Mode", {"Cursor","Camera","Mobile"},
    function() return S.Aimbot.Mode end,
    function(v) S.Aimbot.Mode = v end)
Slider(A, "Smoothness", 0.01, 1,
    function() return S.Aimbot.Smooth end,
    function(v) S.Aimbot.Smooth = v end)
Slider(A, "FOV", 30, 500,
    function() return S.Aimbot.FOV end,
    function(v) S.Aimbot.FOV = v end)
Dropdown(A, "Target Part",
    {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"},
    function() return S.Aimbot.Part end,
    function(v) S.Aimbot.Part = v end)
Toggle(A, "Team Check",
    function() return S.Aimbot.TeamCheck end,
    function(v) S.Aimbot.TeamCheck = v end)
Toggle(A, "Visible Check",
    function() return S.Aimbot.VisibleCheck end,
    function(v) S.Aimbot.VisibleCheck = v end)
Toggle(A, "Show FOV Circle",
    function() return S.Aimbot.ShowFOV end,
    function(v) S.Aimbot.ShowFOV = v end)
Toggle(A, "Use mousemoverel (Cursor mode)",
    function() return S.Aimbot.UseMouseMove end,
    function(v) S.Aimbot.UseMouseMove = v end)

-- ============================================================
-- ESP TAB
-- ============================================================
local E = Tab("ESP")
Section(E, "Toggle")
Toggle(E, "Enable ESP",
    function() return S.ESP.Enabled end,
    function(v)
        S.ESP.Enabled = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
        else
            for p in pairs(ESPObjs or {}) do RemoveESP(p) end
        end
    end)
Section(E, "Elements")
Toggle(E, "Boxes", function() return S.ESP.Boxes end, function(v) S.ESP.Boxes = v end)
Toggle(E, "Names", function() return S.ESP.Names end, function(v) S.ESP.Names = v end)
Toggle(E, "Distance", function() return S.ESP.Distance end, function(v) S.ESP.Distance = v end)
Toggle(E, "Health Bar", function() return S.ESP.Health end, function(v) S.ESP.Health = v end)
Slider(E, "Thickness", 1, 5,
    function() return S.ESP.Thickness end,
    function(v) S.ESP.Thickness = v end)
Section(E, "Colors")
ColorPicker(E, "ESP Color",
    function() return S.ESP.Color end,
    function(v) S.ESP.Color = v end)

-- ============================================================
-- HITBOX TAB
-- ============================================================
local H = Tab("Hitbox")
Section(H, "Toggle")
Toggle(H, "Enable Hitbox",
    function() return S.Hitbox.Enabled end,
    function(v)
        S.Hitbox.Enabled = v
        if not v then RestoreAllHitboxes() end
    end)
Section(H, "Parts")
Toggle(H, "Head", function() return S.Hitbox.Parts.Head end,
    function(v) S.Hitbox.Parts.Head = v end)
Toggle(H, "Torso", function() return S.Hitbox.Parts.Torso end,
    function(v) S.Hitbox.Parts.Torso = v end)
Toggle(H, "Arms", function() return S.Hitbox.Parts.Arms end,
    function(v) S.Hitbox.Parts.Arms = v end)
Toggle(H, "Legs", function() return S.Hitbox.Parts.Legs end,
    function(v) S.Hitbox.Parts.Legs = v end)
Section(H, "Visual")
Slider(H, "Size", 2, 30,
    function() return S.Hitbox.Size end,
    function(v) S.Hitbox.Size = v end)
Slider(H, "Transparency", 0, 1,
    function() return S.Hitbox.Transparency end,
    function(v) S.Hitbox.Transparency = v end)
ColorPicker(H, "Hitbox Color",
    function() return S.Hitbox.Color end,
    function(v) S.Hitbox.Color = v end)

-- ============================================================
-- PLAYER TAB
-- ============================================================
local P = Tab("Player")
Section(P, "Movement")
Slider(P, "Walk Speed", 16, 300,
    function() return S.Player.WalkSpeed end,
    function(v) S.Player.WalkSpeed = v end)
Slider(P, "Jump Power", 50, 300,
    function() return S.Player.JumpPower end,
    function(v) S.Player.JumpPower = v end)
Toggle(P, "Infinite Jump",
    function() return S.Player.InfiniteJump end,
    function(v) S.Player.InfiniteJump = v end)
Toggle(P, "Noclip",
    function() return S.Player.Noclip end,
    function(v) S.Player.Noclip = v end)
Section(P, "Fly")
Toggle(P, "Fly",
    function() return S.Player.Fly end,
    function(v) S.Player.Fly = v end)
Slider(P, "Fly Speed", 10, 300,
    function() return S.Player.FlySpeed end,
    function(v) S.Player.FlySpeed = v end)

-- ============================================================
-- BINDS TAB
-- ============================================================
local B = Tab("Binds")
Section(B, "Key Binds (ПК)")
BindButton(B, "Aimbot", "Aimbot")
BindButton(B, "ESP", "ESP")
BindButton(B, "Hitbox", "Hitbox")
BindButton(B, "Fly", "Fly")
BindButton(B, "Noclip", "Noclip")
BindButton(B, "InfiniteJump", "Infinite Jump")
Section(B, "Floating Buttons (Mobile)")
Toggle(B, "Aimbot Button",
    function() return S.MobileBtns.Aimbot == true end,
    function(v) S.MobileBtns.Aimbot = v; ToggleMobileBtn("Aimbot", v) end)
Toggle(B, "Fly Button",
    function() return S.MobileBtns.Fly == true end,
    function(v) S.MobileBtns.Fly = v; ToggleMobileBtn("Fly", v) end)
Toggle(B, "Noclip Button",
    function() return S.MobileBtns.Noclip == true end,
    function(v) S.MobileBtns.Noclip = v; ToggleMobileBtn("Noclip", v) end)

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local ST = Tab("Settings")
Section(ST, "Actions")
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1,0,0,36)
resetBtn.BackgroundColor3 = COL.elem; resetBtn.BorderSizePixel = 0
resetBtn.Text = "Сбросить все настройки"
resetBtn.TextColor3 = COL.text; resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 13; resetBtn.LayoutOrder = NextOrder()
resetBtn.Parent = ST; corner(resetBtn, 6)
resetBtn.MouseButton1Click:Connect(function()
    S.Aimbot.Enabled=false; S.Aimbot.Smooth=0.25; S.Aimbot.FOV=200
    S.ESP.Enabled=false; S.Hitbox.Enabled=false
    S.Player.Fly=false; S.Player.Noclip=false; S.Player.InfiniteJump=false
    RefreshAll(); Notify("Настройки сброшены")
end)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1,0,0,36)
unloadBtn.BackgroundColor3 = COL.elem; unloadBtn.BorderSizePixel = 0
unloadBtn.Text = "Выгрузить скрипт"
unloadBtn.TextColor3 = COL.accent2; unloadBtn.Font = Enum.Font.Gotham
unloadBtn.TextSize = 13; unloadBtn.LayoutOrder = NextOrder()
unloadBtn.Parent = ST; corner(unloadBtn, 6)
unloadBtn.MouseButton1Click:Connect(function()
    pcall(function() getgenv().TWKS_UNLOAD() end)
end)

Section(ST, "Info")
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1,0,0,90)
infoLbl.BackgroundColor3 = COL.elem; infoLbl.BackgroundTransparency = 0.15
infoLbl.BorderSizePixel = 0; infoLbl.LayoutOrder = NextOrder()
infoLbl.Text = "Открыть/закрыть: Left Alt\nНа мобильном — кнопка TWKS\n\nAim Mode:\n• Cursor — наводка от курсора\n• Camera — наводка на ближайшего к центру\n• Mobile — как Camera, для тача"
infoLbl.TextColor3 = COL.sub; infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 12; infoLbl.TextWrapped = true
infoLbl.Parent = ST; corner(infoLbl, 6)

-- Активируем Aimbot по умолчанию
for _, t in pairs(TabScrolls) do
    t.scroll.Visible = false
    t.btn.BackgroundColor3 = COL.elem
end
TabScrolls["Aimbot"].scroll.Visible = true
TabScrolls["Aimbot"].btn.BackgroundColor3 = COL.accent

-- ============================================================
-- AIMBOT LOGIC
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 1
fovCircle.Color = COL.accent; fovCircle.Transparency = 0.7

local function GetMousePos()
    return UIS:GetMouseLocation()
end

local function FindTarget()
    local target, best = nil, math.huge
    local cmpPos
    if S.Aimbot.Mode == "Mobile" then
        cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    else
        cmpPos = GetMousePos()
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        if S.Aimbot.TeamCheck and pl.Team == LP.Team then continue end
        local ch = pl.Character
        if not ch then continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z < 0 then continue end
        if S.Aimbot.VisibleCheck then
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {LP.Character, ch}
            local r = Workspace:Raycast(Camera.CFrame.Position,
                part.Position - Camera.CFrame.Position, rp)
            if r then continue end
        end
        local d = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
        if d < S.Aimbot.FOV and d < best then
            best = d; target = part
        end
    end
    return target
end

-- основной поток aim — приоритет после камеры
RunService:BindToRenderStep("TWKS_AIM", Enum.RenderPriority.Camera.Value + 1, function()
    if S.Aimbot.ShowFOV then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = S.Aimbot.FOV
    else
        fovCircle.Visible = false
    end

    if not S.Aimbot.Enabled then return end

    local t = FindTarget()
    if not t then return end

    if S.Aimbot.Mode == "Cursor" and S.Aimbot.UseMouseMove then
        -- пробуем двигать физический курсор
        local sp, onScreen = Camera:WorldToViewportPoint(t.Position)
        if onScreen then
            local mp = GetMousePos()
            local dx = (sp.X - mp.X) * S.Aimbot.Smooth
            local dy = (sp.Y - mp.Y) * S.Aimbot.Smooth
            local moved = false
            pcall(function()
                if syn and syn.mousemoverel then
                    syn.mousemoverel(dx, dy); moved = true
                elseif mousemoverel then
                    mousemoverel(dx, dy); moved = true
                elseif mouse and mouse.move then
                    mouse.move(dx, dy); moved = true
                end
            end)
            if moved then return end
        end
    end

    -- fallback / основная логика: камера плавно к цели
    local lookCF = CFrame.new(Camera.CFrame.Position, t.Position)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, S.Aimbot.Smooth)
end)

-- ============================================================
-- ESP LOGIC
-- ============================================================
ESPObjs = {}

function CreateESP(pl)
    if pl == LP or ESPObjs[pl] then return end
    local box = Drawing.new("Square")
    box.Visible = false; box.Filled = false
    box.Color = S.ESP.Color; box.Thickness = 1
    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.Size = 14; nm.Color = Color3.new(1,1,1)
    local ds = Drawing.new("Text")
    ds.Visible = false; ds.Center = true; ds.Outline = true
    ds.Size = 12; ds.Color = Color3.new(0.85,0.85,0.85)
    local hp = Drawing.new("Line")
    hp.Visible = false; hp.Thickness = 2
    hp.Color = Color3.new(0,1,0)
    ESPObjs[pl] = {box=box, name=nm, dist=ds, hp=hp}
end

function RemoveESP(pl)
    if ESPObjs[pl] then
        for _, d in pairs(ESPObjs[pl]) do pcall(function() d:Remove() end) end
        ESPObjs[pl] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for pl, d in pairs(ESPObjs) do
        local ch = pl.Character
        if not S.ESP.Enabled or not ch then
            for _, o in pairs(d) do o.Visible = false end
            continue
        end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        local head = ch:FindFirstChild("Head")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health <= 0 then
            for _, o in pairs(d) do o.Visible = false end
            continue
        end
        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
        if top.Z < 0 or bot.Z < 0 then
            for _, o in pairs(d) do o.Visible = false end
            continue
        end
        local height = math.abs(top.Y - bot.Y)
        local width = height * 0.5
        d.box.Size = Vector2.new(width, height)
        d.box.Position = Vector2.new(top.X - width/2, top.Y)
        d.box.Color = S.ESP.Color
        d.box.Thickness = S.ESP.Thickness
        d.box.Visible = S.ESP.Boxes
        d.name.Text = pl.Name
        d.name.Position = Vector2.new(top.X, top.Y - 18)
        d.name.Color = S.ESP.Color
        d.name.Visible = S.ESP.Names
        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
        d.dist.Text = dist .. "m"
        d.dist.Position = Vector2.new(top.X, bot.Y + 2)
        d.dist.Visible = S.ESP.Distance
        if S.ESP.Health then
            local hpPct = hum.Health / hum.MaxHealth
            d.hp.From = Vector2.new(top.X - width/2 - 4, bot.Y)
            d.hp.To = Vector2.new(top.X - width/2 - 4, bot.Y - height * hpPct)
            d.hp.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
            d.hp.Visible = true
        else
            d.hp.Visible = false
        end
    end
end)

Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        if S.ESP.Enabled then CreateESP(pl) end
    end)
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
-- HITBOX
-- ============================================================
local OrigHB = {}
local PartGroups = {
    Head = {"Head"},
    Torso = {"UpperTorso","LowerTorso","Torso"},
    Arms = {"LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
            "Left Arm","Right Arm"},
    Legs = {"LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg",
            "Left Leg","Right Leg"}
}

local function ApplyHitbox(pl)
    if pl == LP or not pl.Character then return end
    for group, names in pairs(PartGroups) do
        if S.Hitbox.Parts[group] then
            for _, name in ipairs(names) do
                local part = pl.Character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    if not OrigHB[part] then
                        OrigHB[part] = {
                            Size = part.Size,
                            Transparency = part.Transparency,
                            Color = part.Color,
                            CanCollide = part.CanCollide
                        }
                    end
                    part.Size = Vector3.new(S.Hitbox.Size, S.Hitbox.Size, S.Hitbox.Size)
                    part.Transparency = S.Hitbox.Transparency
                    part.Color = S.Hitbox.Color
                    part.CanCollide = false
                    part.Material = Enum.Material.SmoothPlastic
                end
            end
        end
    end
end

function RestoreAllHitboxes()
    for part, o in pairs(OrigHB) do
        if part and part.Parent then
            part.Size = o.Size
            part.Transparency = o.Transparency
            part.Color = o.Color
            part.CanCollide = o.CanCollide
        end
    end
    OrigHB = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                pcall(ApplyHitbox, pl)
            end
        end
    end
end)

-- ============================================================
-- PLAYER MODS
-- ============================================================
RunService.Heartbeat:Connect(function()
    local ch = LP.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = S.Player.WalkSpeed
        hum.JumpPower = S.Player.JumpPower
    end
end)

UIS.JumpRequest:Connect(function()
    if S.Player.InfiniteJump then
        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.Player.Noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Fly
local FlyBV, FlyBG
RunService.RenderStepped:Connect(function()
    local ch = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if S.Player.Fly and hrp then
        if not FlyBV then
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBV.Parent = hrp
        end
        if not FlyBG then
            FlyBG = Instance.new("BodyGyro")
            FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyBG.Parent = hrp
        end
        local dir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        FlyBV.Velocity = dir * S.Player.FlySpeed
        FlyBG.CFrame = Camera.CFrame
    else
        if FlyBV then FlyBV:Destroy(); FlyBV = nil end
        if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    end
end)

-- ============================================================
-- ACTIONS
-- ============================================================
local Actions = {}
Actions.Aimbot = function()
    S.Aimbot.Enabled = not S.Aimbot.Enabled
    RefreshAll(); Notify("Aimbot: "..tostring(S.Aimbot.Enabled))
end
Actions.ESP = function()
    S.ESP.Enabled = not S.ESP.Enabled; RefreshAll()
    if S.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then CreateESP(p) end
        end
    else
        for p in pairs(ESPObjs) do RemoveESP(p) end
    end
    Notify("ESP: "..tostring(S.ESP.Enabled))
end
Actions.Hitbox = function()
    S.Hitbox.Enabled = not S.Hitbox.Enabled; RefreshAll()
    if not S.Hitbox.Enabled then RestoreAllHitboxes() end
    Notify("Hitbox: "..tostring(S.Hitbox.Enabled))
end
Actions.Fly = function()
    S.Player.Fly = not S.Player.Fly; RefreshAll()
    Notify("Fly: "..tostring(S.Player.Fly))
end
Actions.Noclip = function()
    S.Player.Noclip = not S.Player.Noclip; RefreshAll()
    if not S.Player.Noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    Notify("Noclip: "..tostring(S.Player.Noclip))
end
Actions.InfiniteJump = function()
    S.Player.InfiniteJump = not S.Player.InfiniteJump; RefreshAll()
    Notify("InfJump: "..tostring(S.Player.InfiniteJump))
end

-- ============================================================
-- INPUT (бинды)
-- ============================================================
UIS.InputBegan:Connect(function(input, gp)
    -- Слушатель бинда: реагируем ТОЛЬКО на клавиатуру
    if getgenv().TWKS_LISTENING then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = getgenv().TWKS_LISTENING
            getgenv().TWKS_LISTENING = nil
            S.Binds[action] = input.KeyCode
            if BindRefreshers[action] then BindRefreshers[action]() end
            Notify("Bind: "..action.." → "..tostring(input.KeyCode):gsub("Enum.KeyCode.",""))
        end
        return
    end

    if gp then return end

    if input.KeyCode == Enum.KeyCode.LeftAlt then
        Main.Visible = not Main.Visible
        return
    end

    for action, key in pairs(S.Binds) do
        if input.KeyCode == key and Actions[action] then
            Actions[action]()
        end
    end
end)

-- ============================================================
-- MOBILE FLOATING BUTTONS
-- ============================================================
local MobileButtons = {}
function ToggleMobileBtn(action, show)
    if MobileButtons[action] then
        MobileButtons[action]:Destroy(); MobileButtons[action] = nil
    end
    if not show then return end
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,56,0,56)
    b.Position = UDim2.new(0,20,0.5,0)
    b.BackgroundColor3 = COL.bg2; b.BackgroundTransparency = 0.2
    b.TextColor3 = COL.accent2; b.Font = Enum.Font.GothamBold
    b.TextSize = 11; b.Text = action; b.BorderSizePixel = 0
    b.Parent = ScreenGui; corner(b, 28); stroke(b, COL.accent2, 1.5)
    MakeDraggable(b, b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        if Actions[action] then Actions[action]() end
        b.BackgroundColor3 = active and COL.accent2 or COL.bg2
    end)
    MobileButtons[action] = b
end

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,50,0,50)
OpenBtn.Position = UDim2.new(0,20,1,-80)
OpenBtn.BackgroundColor3 = COL.bg2; OpenBtn.BackgroundTransparency = 0.2
OpenBtn.TextColor3 = COL.accent2; OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 11; OpenBtn.Text = "TWKS"; OpenBtn.BorderSizePixel = 0
OpenBtn.Parent = ScreenGui; corner(OpenBtn, 25); stroke(OpenBtn, COL.accent2, 1.5)
MakeDraggable(OpenBtn, OpenBtn)
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ============================================================
-- UNLOAD
-- ============================================================
getgenv().TWKS_UNLOAD = function()
    pcall(function() ScreenGui:Destroy() end)
    for p in pairs(ESPObjs) do RemoveESP(p) end
    RestoreAllHitboxes()
    pcall(function() fovCircle:Remove() end)
    pcall(function() RunService:UnbindFromRenderStep("TWKS_AIM") end)
    getgenv().TWKS_LOADED = false
end

Notify("TWKS v2.1 · Left Alt — меню · Cursor Aim готов")