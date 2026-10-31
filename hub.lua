-- ============================================================================
-- TWKS HUB v2.3 — Sticky Aim + Clean Hitbox + Highlight ESP
-- ============================================================================

if getgenv().TWKS_LOADED then pcall(function() getgenv().TWKS_UNLOAD() end) end
getgenv().TWKS_LISTENING = nil

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Tween      = game:GetService("TweenService")
local CoreGui    = game:GetService("CoreGui")
local Workspace  = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
getgenv().TWKS_LOADED = true

-- ============================================================
-- SETTINGS
-- ============================================================
local S = {
    Aimbot = {
        Enabled = false, Mode = "Cursor", Smooth = 0.25,
        CameraFOV = 200, MobileFOV = 200,
        Part = "Head", TeamCheck = true, VisibleCheck = false,
        ShowFOV = true, StickyLock = true
    },
    ESP = {
        Enabled = false,
        OutlineColor = Color3.fromRGB(255, 20, 147),
        FillColor = Color3.fromRGB(180, 60, 255),
        FillTransparency = 0.7,
        OutlineTransparency = 0,
        ThroughWalls = true,
        ShowName = true, ShowDistance = true
    },
    Hitbox = {
        Enabled = false,
        HeadEnabled = true, BodyEnabled = true,
        HeadSize = 3, BodySize = 5,
        Transparency = 0.7,
        Color = Color3.fromRGB(128,128,128)
    },
    Player = {
        Fly = false, FlySpeed = 50,
        WalkSpeed = 16, JumpPower = 50,
        InfiniteJump = false, Noclip = false
    },
    Binds = {}, MobileBtns = {},
    AutoSave = true, ConfigName = "auto"
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
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
-- CONFIG SYSTEM
-- ============================================================
local CONFIG_DIR = "TWKS"
local AUTOSAVE_FILE = "autosave"
local function ensureDir() pcall(function()
    if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
end) end
local function fileExists(path)
    local ok, res = pcall(function() return isfile(path) end)
    return ok and res
end
local function packC3(c) return {math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)} end
local function unpackC3(t) return Color3.fromRGB(t[1] or 128, t[2] or 128, t[3] or 128) end

local function packSettings()
    local d = {
        Aimbot = {}, ESP = {}, Hitbox = {}, Player = {},
        Binds = {}, MobileBtns = {}, AutoSave = S.AutoSave,
    }
    for k, v in pairs(S.Aimbot) do d.Aimbot[k] = v end
    for k, v in pairs(S.ESP) do
        if k == "OutlineColor" or k == "FillColor" then d.ESP[k] = packC3(v)
        else d.ESP[k] = v end
    end
    for k, v in pairs(S.Hitbox) do
        if k == "Color" then d.Hitbox[k] = packC3(v)
        else d.Hitbox[k] = v end
    end
    for k, v in pairs(S.Player) do d.Player[k] = v end
    for action, key in pairs(S.Binds) do
        d.Binds[action] = tostring(key):gsub("Enum.KeyCode.","")
    end
    for k, v in pairs(S.MobileBtns) do d.MobileBtns[k] = v end
    return d
end
local function applySettings(d)
    if not d then return end
    if d.Aimbot then for k,v in pairs(d.Aimbot) do if S.Aimbot[k] ~= nil then S.Aimbot[k]=v end end end
    if d.ESP then for k,v in pairs(d.ESP) do
        if k == "OutlineColor" or k == "FillColor" then S.ESP[k] = unpackC3(v)
        elseif S.ESP[k] ~= nil then S.ESP[k] = v end
    end end
    if d.Hitbox then for k,v in pairs(d.Hitbox) do
        if k == "Color" then S.Hitbox[k] = unpackC3(v)
        elseif S.Hitbox[k] ~= nil then S.Hitbox[k] = v end
    end end
    if d.Player then for k,v in pairs(d.Player) do if S.Player[k] ~= nil then S.Player[k]=v end end end
    if d.Binds then
        S.Binds = {}
        for action, name in pairs(d.Binds) do
            local ok, code = pcall(function() return Enum.KeyCode[name] end)
            if ok and code then S.Binds[action] = code end
        end
    end
    if d.MobileBtns then for k,v in pairs(d.MobileBtns) do S.MobileBtns[k] = v end end
    if d.AutoSave ~= nil then S.AutoSave = d.AutoSave end
end
local function saveConfig(name)
    ensureDir(); name = name or AUTOSAVE_FILE
    return pcall(function()
        writefile(CONFIG_DIR.."/"..name..".json", HttpService:JSONEncode(packSettings()))
    end)
end
local function loadConfigFile(name)
    name = name or AUTOSAVE_FILE
    local path = CONFIG_DIR.."/"..name..".json"
    if not fileExists(path) then return false end
    local ok, c = pcall(function() return readfile(path) end)
    if not ok or not c then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(c) end)
    if not ok2 or not data then return false end
    applySettings(data); return true
end
local function deleteConfig(name) pcall(function() delfile(CONFIG_DIR.."/"..name..".json") end) end
local function listConfigs()
    local out = {}
    pcall(function()
        if not isfolder(CONFIG_DIR) then return end
        for _, file in ipairs(listfiles(CONFIG_DIR)) do
            local n = file:match("([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
    end)
    return out
end

ensureDir()
if fileExists(CONFIG_DIR.."/"..AUTOSAVE_FILE..".json") then
    pcall(function() loadConfigFile(AUTOSAVE_FILE) end)
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

local CONFIG_DIRTY = false
local function MarkDirty() CONFIG_DIRTY = true end

local function Notify(txt)
    task.spawn(function()
        local n = Instance.new("Frame")
        n.Size = UDim2.new(0, 250, 0, 42)
        n.Position = UDim2.new(1, -270, 1, -80)
        n.BackgroundColor3 = COL.bg2
        n.BackgroundTransparency = 0.1
        n.BorderSizePixel = 0; n.Parent = ScreenGui
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
local function RefreshAll() for _, fn in ipairs(Refreshers) do pcall(fn) end end

-- ============================================================
-- WIDGETS
-- ============================================================
local ORDER = 0
local function NextOrder() ORDER = ORDER + 1; return ORDER end

local function Section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,26); f.BackgroundTransparency = 1
    f.LayoutOrder = NextOrder(); f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
    l.Text = string.upper(text); l.TextColor3 = COL.accent2
    l.Font = Enum.Font.GothamBold; l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
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
    btn.MouseButton1Click:Connect(function() setter(not getter()); render(); MarkDirty() end)
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
        setter(minV + rel * (maxV - minV)); render(); MarkDirty()
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
                setter(opt); render(); MarkDirty()
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
        swatches[#swatches+1] = {line = s}
        b.MouseButton1Click:Connect(function()
            setter(c); MarkDirty()
            for _, sw in ipairs(swatches) do sw.line.Thickness = 0 end
            s.Thickness = 2
        end)
    end
end

local function TextBox(parent, name, placeholder, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,52)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,18); lbl.Position = UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-24,0,22); box.Position = UDim2.new(0,12,0,26)
    box.BackgroundColor3 = COL.bg2; box.BorderSizePixel = 0
    box.Text = getter() or ""; box.PlaceholderText = placeholder or ""
    box.TextColor3 = COL.text; box.PlaceholderColor3 = COL.sub
    box.Font = Enum.Font.Gotham; box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false; box.Parent = f; corner(box, 4)
    stroke(box, COL.stroke, 1)
    box.FocusLost:Connect(function() setter(box.Text); MarkDirty() end)
end

local function Button(parent, label, callback, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = color or COL.elem
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0; b.Text = label
    b.TextColor3 = COL.text; b.Font = Enum.Font.Gotham
    b.TextSize = 13; b.LayoutOrder = NextOrder()
    b.Parent = parent; corner(b, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

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
    local function refresh()
        local k = S.Binds[action]
        if k then
            keyLbl.Text = tostring(k):gsub("Enum.KeyCode.","")
            keyLbl.TextColor3 = COL.accent2
        else
            keyLbl.Text = "None"; keyLbl.TextColor3 = COL.sub
        end
    end
    refresh(); BindRefreshers[action] = refresh
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,0,26); btn.Position = UDim2.new(1,-110,0.5,-13)
    btn.BackgroundTransparency = 1; btn.Text = ""
    btn.Active = true; btn.Parent = f
    btn.MouseButton1Down:Connect(function()
        getgenv().TWKS_LISTENING = action
        keyLbl.Text = "нажми..."; keyLbl.TextColor3 = Color3.fromRGB(255,200,100)
    end)
end

-- ============================================================
-- MAIN + TABS
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 620, 0, 430)
Main.Position = UDim2.new(0.5,-310,0.5,-215)
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 12); stroke(Main, COL.accent, 1.5)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = COL.bg2
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0; TitleBar.Parent = Main

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0); TitleLbl.Position = UDim2.new(0,14,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "TWKS HUB  ·  v2.3"
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
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0,4); LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Parent = Left
local LP2 = Instance.new("UIPadding")
LP2.PaddingTop = UDim.new(0,8); LP2.PaddingLeft = UDim.new(0,6)
LP2.PaddingRight = UDim.new(0,6); LP2.Parent = Left

local Right = Instance.new("Frame")
Right.Size = UDim2.new(1,-162,1,-46)
Right.Position = UDim2.new(0,156,0,42)
Right.BackgroundTransparency = 1; Right.Parent = Main

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
    sc.ScrollBarThickness = 4; sc.ScrollBarImageColor3 = COL.accent2
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false; sc.Parent = Right
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = sc
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,4); pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,10); pad.PaddingBottom = UDim.new(0,8)
    pad.Parent = sc
    TabScrolls[name] = {btn = b, scroll = sc}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(TabScrolls) do
            t.scroll.Visible = false; t.btn.BackgroundColor3 = COL.elem
        end
        sc.Visible = true; b.BackgroundColor3 = COL.accent
    end)
    return sc
end

-- ============================================================
-- TABS
-- ============================================================
local A = Tab("Aimbot")
Section(A, "Основное")
Toggle(A, "Enable Aimbot",
    function() return S.Aimbot.Enabled end,
    function(v) S.Aimbot.Enabled = v end)
Toggle(A, "Sticky Lock",
    function() return S.Aimbot.StickyLock end,
    function(v) S.Aimbot.StickyLock = v end)
Dropdown(A, "Aim Mode", {"Cursor","Camera","Mobile"},
    function() return S.Aimbot.Mode end,
    function(v) S.Aimbot.Mode = v end)
Slider(A, "Smoothness", 0.01, 1,
    function() return S.Aimbot.Smooth end,
    function(v) S.Aimbot.Smooth = v end)
Section(A, "FOV (не для Cursor)")
Slider(A, "Camera FOV", 30, 800,
    function() return S.Aimbot.CameraFOV end,
    function(v) S.Aimbot.CameraFOV = v end)
Slider(A, "Mobile FOV", 30, 800,
    function() return S.Aimbot.MobileFOV end,
    function(v) S.Aimbot.MobileFOV = v end)
Toggle(A, "Show FOV Circle",
    function() return S.Aimbot.ShowFOV end,
    function(v) S.Aimbot.ShowFOV = v end)
Section(A, "Target")
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

local E = Tab("ESP")
Section(E, "Toggle")
Toggle(E, "Enable ESP",
    function() return S.ESP.Enabled end,
    function(v)
        S.ESP.Enabled = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then CreateESP(p) end
            end
        else
            for p in pairs(ESPObjs or {}) do RemoveESP(p) end
        end
    end)
Section(E, "Highlight")
ColorPicker(E, "Outline Color",
    function() return S.ESP.OutlineColor end,
    function(v) S.ESP.OutlineColor = v; RefreshESPColors() end)
ColorPicker(E, "Fill Color",
    function() return S.ESP.FillColor end,
    function(v) S.ESP.FillColor = v; RefreshESPColors() end)
Slider(E, "Fill Transparency", 0, 1,
    function() return S.ESP.FillTransparency end,
    function(v) S.ESP.FillTransparency = v; RefreshESPColors() end)
Slider(E, "Outline Transparency", 0, 1,
    function() return S.ESP.OutlineTransparency end,
    function(v) S.ESP.OutlineTransparency = v; RefreshESPColors() end)
Toggle(E, "Through Walls",
    function() return S.ESP.ThroughWalls end,
    function(v) S.ESP.ThroughWalls = v; RefreshESPColors() end)
Section(E, "Text")
Toggle(E, "Show Name",
    function() return S.ESP.ShowName end,
    function(v) S.ESP.ShowName = v end)
Toggle(E, "Show Distance",
    function() return S.ESP.ShowDistance end,
    function(v) S.ESP.ShowDistance = v end)

local H = Tab("Hitbox")
Section(H, "Toggle")
Toggle(H, "Enable Hitbox",
    function() return S.Hitbox.Enabled end,
    function(v)
        S.Hitbox.Enabled = v
        if not v then ClearAllHitboxes() end
    end)
Section(H, "Parts")
Toggle(H, "Head Hitbox",
    function() return S.Hitbox.HeadEnabled end,
    function(v) S.Hitbox.HeadEnabled = v; RefreshHitboxes() end)
Toggle(H, "Body Hitbox",
    function() return S.Hitbox.BodyEnabled end,
    function(v) S.Hitbox.BodyEnabled = v; RefreshHitboxes() end)
Section(H, "Sizes")
Slider(H, "Head Size", 1, 15,
    function() return S.Hitbox.HeadSize end,
    function(v) S.Hitbox.HeadSize = v; RefreshHitboxes() end)
Slider(H, "Body Size", 2, 25,
    function() return S.Hitbox.BodySize end,
    function(v) S.Hitbox.BodySize = v; RefreshHitboxes() end)
Section(H, "Visual")
Slider(H, "Transparency", 0, 1,
    function() return S.Hitbox.Transparency end,
    function(v) S.Hitbox.Transparency = v; RefreshHitboxes() end)
ColorPicker(H, "Hitbox Color",
    function() return S.Hitbox.Color end,
    function(v) S.Hitbox.Color = v; RefreshHitboxes() end)

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

local ST = Tab("Settings")

-- ============================================================
-- AIMBOT с STICKY LOCK
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 1
fovCircle.Color = COL.accent; fovCircle.Transparency = 0.7

local StickyTarget = nil

local function IsPlayerValid(pl)
    if not pl or pl.Parent ~= Players then return false end
    local ch = pl.Character
    if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if S.Aimbot.TeamCheck and pl.Team == LP.Team then return false end
    local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
    if not part then return false end
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen or sp.Z < 0 then return false end
    if S.Aimbot.VisibleCheck then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {LP.Character, ch}
        local r = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rp)
        if r then return false end
    end
    return true
end

local function FindTarget()
    if S.Aimbot.StickyLock and StickyTarget then
        if IsPlayerValid(StickyTarget) then
            local ch = StickyTarget.Character
            return ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        else
            StickyTarget = nil
        end
    end

    local target, targetPlayer, best = nil, nil, math.huge
    local cmpPos, fovLimit
    if S.Aimbot.Mode == "Cursor" then
        cmpPos = UIS:GetMouseLocation(); fovLimit = math.huge
    elseif S.Aimbot.Mode == "Mobile" then
        cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovLimit = S.Aimbot.MobileFOV
    else
        cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovLimit = S.Aimbot.CameraFOV
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
        if d < fovLimit and d < best then
            best = d; target = part; targetPlayer = pl
        end
    end
    if S.Aimbot.StickyLock then StickyTarget = targetPlayer end
    return target
end

local function tryMouse(dx, dy)
    if syn and syn.mousemoverel then
        if pcall(syn.mousemoverel, dx, dy) then return true end
    end
    if mousemoverel then
        if pcall(mousemoverel, dx, dy) then return true end
    end
    if mouse and mouse.Move then
        if pcall(mouse.Move, mouse, dx, dy) then return true end
    end
    if mouse and mouse.move then
        if pcall(mouse.move, dx, dy) then return true end
    end
    return false
end

RunService:BindToRenderStep("TWKS_AIM", Enum.RenderPriority.Camera.Value + 1, function()
    if S.Aimbot.ShowFOV and S.Aimbot.Mode ~= "Cursor" then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = (S.Aimbot.Mode == "Mobile") and S.Aimbot.MobileFOV or S.Aimbot.CameraFOV
    else
        fovCircle.Visible = false
    end

    if not S.Aimbot.Enabled then StickyTarget = nil; return end
    local t = FindTarget()
    if not t then return end

    if S.Aimbot.Mode == "Cursor" then
        local sp, onScreen = Camera:WorldToViewportPoint(t.Position)
        if onScreen and sp.Z > 0 then
            local mp = UIS:GetMouseLocation()
            local dx = (sp.X - mp.X) * S.Aimbot.Smooth
            local dy = (sp.Y - mp.Y) * S.Aimbot.Smooth
            if tryMouse(dx, dy) then return end
        end
    end

    local lookCF = CFrame.new(Camera.CFrame.Position, t.Position)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, S.Aimbot.Smooth)
end)

-- ============================================================
-- ESP через Highlight
-- ============================================================
ESPObjs = {}

local function applyHighlight(hl)
    hl.FillColor = S.ESP.FillColor
    hl.FillTransparency = S.ESP.FillTransparency
    hl.OutlineColor = S.ESP.OutlineColor
    hl.OutlineTransparency = S.ESP.OutlineTransparency
    hl.DepthMode = S.ESP.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded
end

function RefreshESPColors()
    for pl, d in pairs(ESPObjs or {}) do
        if d.hl then applyHighlight(d.hl) end
    end
end

function CreateESP(pl)
    if pl == LP or ESPObjs[pl] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TWKS_HL_" .. pl.Name
    applyHighlight(hl)
    if pl.Character then hl.Adornee = pl.Character end
    hl.Parent = ScreenGui

    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.Size = 14; nm.Color = S.ESP.OutlineColor

    local ds = Drawing.new("Text")
    ds.Visible = false; ds.Center = true; ds.Outline = true
    ds.Size = 12; ds.Color = Color3.fromRGB(220,220,220)

    ESPObjs[pl] = {hl = hl, name = nm, dist = ds}

    pl.CharacterAdded:Connect(function(ch)
        task.wait(0.3)
        if ESPObjs[pl] and ESPObjs[pl].hl then
            ESPObjs[pl].hl.Adornee = ch
        end
    end)
end

function RemoveESP(pl)
    if ESPObjs[pl] then
        pcall(function() ESPObjs[pl].hl:Destroy() end)
        pcall(function() ESPObjs[pl].name:Remove() end)
        pcall(function() ESPObjs[pl].dist:Remove() end)
        ESPObjs[pl] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for pl, d in pairs(ESPObjs) do
        local ch = pl.Character
        if not S.ESP.Enabled or not ch then
            d.name.Visible = false; d.dist.Visible = false
            if d.hl then d.hl.Enabled = false end
            continue
        end
        if d.hl then
            d.hl.Enabled = true
            if d.hl.Adornee ~= ch then d.hl.Adornee = ch end
        end
        local head = ch:FindFirstChild("Head")
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then
            d.name.Visible = false; d.dist.Visible = false
            continue
        end
        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        if top.Z < 0 then
            d.name.Visible = false; d.dist.Visible = false
            continue
        end
        if S.ESP.ShowName then
            d.name.Text = pl.Name
            d.name.Position = Vector2.new(top.X, top.Y - 20)
            d.name.Color = S.ESP.OutlineColor
            d.name.Visible = true
        else
            d.name.Visible = false
        end
        if S.ESP.ShowDistance then
            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            d.dist.Text = dist .. "m"
            d.dist.Position = Vector2.new(top.X, top.Y - 4)
            d.dist.Visible = true
        else
            d.dist.Visible = false
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
-- HITBOX через невидимые части (не трогаем тело/одежду)
-- ============================================================
local HitboxParts = {}  -- [player] = {head = Part, body = Part}

local function getRealPart(ch, name)
    return ch:FindFirstChild(name)
end

local function createHitboxPart(name)
    local p = Instance.new("Part")
    p.Name = "TWKS_HB_" .. name
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.Massless = true
    p.Material = Enum.Material.SmoothPlastic
    p.Color = S.Hitbox.Color
    p.Transparency = S.Hitbox.Transparency
    p.Size = Vector3.new(1,1,1)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = Workspace
    return p
end

local function ApplyHitbox(pl)
    if pl == LP or not pl.Character then return end
    local ch = pl.Character
    local entry = HitboxParts[pl]
    if not entry then
        entry = {}; HitboxParts[pl] = entry
    end

    -- Head
    if S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = createHitboxPart("Head")
        end
        local head = getRealPart(ch, "Head")
        if head then
            entry.head.Size = Vector3.new(S.Hitbox.HeadSize, S.Hitbox.HeadSize, S.Hitbox.HeadSize)
            entry.head.CFrame = head.CFrame
            entry.head.Color = S.Hitbox.Color
            entry.head.Transparency = S.Hitbox.Transparency
            entry.head.Visible = true
        else
            entry.head.Transparency = 1
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil
    end

    -- Body (Torso / UpperTorso)
    if S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = createHitboxPart("Body")
        end
        local torso = getRealPart(ch, "UpperTorso") or getRealPart(ch, "Torso")
        if torso then
            entry.body.Size = Vector3.new(S.Hitbox.BodySize, S.Hitbox.BodySize, S.Hitbox.BodySize)
            entry.body.CFrame = torso.CFrame
            entry.body.Color = S.Hitbox.Color
            entry.body.Transparency = S.Hitbox.Transparency
            entry.body.Visible = true
        else
            entry.body.Transparency = 1
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil
    end
end

local function RemoveHitboxFor(pl)
    local e = HitboxParts[pl]
    if e then
        if e.head and e.head.Parent then e.head:Destroy() end
        if e.body and e.body.Parent then e.body:Destroy() end
        HitboxParts[pl] = nil
    end
end

function ClearAllHitboxes()
    for pl, _ in pairs(HitboxParts) do RemoveHitboxFor(pl) end
    HitboxParts = {}
end

function RefreshHitboxes()
    for pl, e in pairs(HitboxParts) do
        if e.head then e.head:Destroy() end
        if e.body then e.body:Destroy() end
        HitboxParts[pl] = nil
    end
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            pcall(ApplyHitbox, pl)
        end
    end
end

-- Update hitbox CFrames every frame
RunService.RenderStepped:Connect(function()
    if not S.Hitbox.Enabled then return end
    for pl, entry in pairs(HitboxParts) do
        local ch = pl.Character
        if not ch then continue end
        if entry.head then
            local h = ch:FindFirstChild("Head")
            if h then entry.head.CFrame = h.CFrame end
        end
        if entry.body then
            local t = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
            if t then entry.body.CFrame = t.CFrame end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                pcall(ApplyHitbox, pl)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveHitboxFor)

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
-- ACTIONS + INPUT
-- ============================================================
local Actions = {}
Actions.Aimbot = function()
    S.Aimbot.Enabled = not S.Aimbot.Enabled; RefreshAll(); MarkDirty()
    if not S.Aimbot.Enabled then StickyTarget = nil end
    Notify("Aimbot: "..tostring(S.Aimbot.Enabled))
end
Actions.ESP = function()
    S.ESP.Enabled = not S.ESP.Enabled; RefreshAll(); MarkDirty()
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
    S.Hitbox.Enabled = not S.Hitbox.Enabled; RefreshAll(); MarkDirty()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(ApplyHitbox, pl) end
    else
        ClearAllHitboxes()
    end
    Notify("Hitbox: "..tostring(S.Hitbox.Enabled))
end
Actions.Fly = function()
    S.Player.Fly = not S.Player.Fly; RefreshAll(); MarkDirty()
    Notify("Fly: "..tostring(S.Player.Fly))
end
Actions.Noclip = function()
    S.Player.Noclip = not S.Player.Noclip; RefreshAll(); MarkDirty()
    if not S.Player.Noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    Notify("Noclip: "..tostring(S.Player.Noclip))
end
Actions.InfiniteJump = function()
    S.Player.InfiniteJump = not S.Player.InfiniteJump; RefreshAll(); MarkDirty()
    Notify("InfJump: "..tostring(S.Player.InfiniteJump))
end

UIS.InputBegan:Connect(function(input, gp)
    if getgenv().TWKS_LISTENING then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = getgenv().TWKS_LISTENING
            getgenv().TWKS_LISTENING = nil
            S.Binds[action] = input.KeyCode
            if BindRefreshers[action] then BindRefreshers[action]() end
            MarkDirty()
            Notify("Bind: "..action.." → "..tostring(input.KeyCode):gsub("Enum.KeyCode.",""))
        end
        return
    end
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        Main.Visible = not Main.Visible; return
    end
    for action, key in pairs(S.Binds) do
        if input.KeyCode == key and Actions[action] then Actions[action]() end
    end
end)

-- ============================================================
-- MOBILE BUTTONS
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
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============================================================
-- SETTINGS TAB
-- ============================================================
Section(ST, "Действия")
Button(ST, "Сбросить все настройки", function()
    S.Aimbot.Enabled=false; S.Aimbot.Smooth=0.25
    S.Aimbot.CameraFOV=200; S.Aimbot.MobileFOV=200
    S.ESP.Enabled=false; S.Hitbox.Enabled=false
    S.Player.Fly=false; S.Player.Noclip=false; S.Player.InfiniteJump=false
    RefreshAll(); MarkDirty(); Notify("Настройки сброшены")
end)
Button(ST, "Выгрузить скрипт", function()
    pcall(function() getgenv().TWKS_UNLOAD() end)
end, COL.accent2)

Section(ST, "Конфиги")
TextBox(ST, "Имя конфига", "auto",
    function() return S.ConfigName end,
    function(v) S.ConfigName = (v ~= "" and v) or "auto" end)
Button(ST, "Сохранить текущий", function()
    local name = S.ConfigName or "auto"
    if saveConfig(name) then
        Notify("Сохранено: "..name)
        if RefreshCfgList then RefreshCfgList() end
    else Notify("Ошибка сохранения") end
end)

local function applyLoadedSettings()
    RefreshAll()
    for _, fn in pairs(BindRefreshers) do pcall(fn) end
    for p in pairs(ESPObjs) do RemoveESP(p) end
    if S.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then CreateESP(p) end
        end
    end
    ClearAllHitboxes()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(ApplyHitbox, pl) end
    end
    for action, state in pairs(S.MobileBtns) do
        ToggleMobileBtn(action, state)
    end
    MarkDirty()
end

Button(ST, "Загрузить", function()
    local name = S.ConfigName or "auto"
    if loadConfigFile(name) then
        applyLoadedSettings()
        Notify("Загружено: "..name)
    else Notify("Конфиг не найден: "..name) end
end)

Button(ST, "Удалить", function()
    local name = S.ConfigName or "auto"
    deleteConfig(name); Notify("Удалено: "..name)
    if RefreshCfgList then RefreshCfgList() end
end)

Toggle(ST, "Авто-сохранение",
    function() return S.AutoSave end,
    function(v) S.AutoSave = v end)

Section(ST, "Доступные конфиги")
local cfgListLbl = Instance.new("TextLabel")
cfgListLbl.Size = UDim2.new(1,0,0,90)
cfgListLbl.BackgroundColor3 = COL.elem; cfgListLbl.BackgroundTransparency = 0.15
cfgListLbl.BorderSizePixel = 0; cfgListLbl.LayoutOrder = NextOrder()
cfgListLbl.TextColor3 = COL.sub; cfgListLbl.Font = Enum.Font.Gotham
cfgListLbl.TextSize = 12; cfgListLbl.TextWrapped = true
cfgListLbl.TextXAlignment = Enum.TextXAlignment.Left
cfgListLbl.TextYAlignment = Enum.TextYAlignment.Top
cfgListLbl.Parent = ST; corner(cfgListLbl, 6)

function RefreshCfgList()
    local list = listConfigs()
    if #list == 0 then cfgListLbl.Text = "  (пусто)"
    else
        table.sort(list)
        cfgListLbl.Text = "  "..table.concat(list, "\n  ")
    end
end
RefreshCfgList()

Section(ST, "Info")
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1,0,0,110)
infoLbl.BackgroundColor3 = COL.elem; infoLbl.BackgroundTransparency = 0.15
infoLbl.BorderSizePixel = 0; infoLbl.LayoutOrder = NextOrder()
infoLbl.Text = "Left Alt — меню · Mobile — TWKS\n\nAim: Cursor без FOV, sticky lock\nХитбоксы: отдельные части над телом\nESP: Highlight, не портит визуал\n\nАвтосейв: "..CONFIG_DIR.."/autosave.json"
infoLbl.TextColor3 = COL.sub; infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 12; infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.Parent = ST; corner(infoLbl, 6)

-- ============================================================
-- FINAL SETUP
-- ============================================================
for _, t in pairs(TabScrolls) do
    t.scroll.Visible = false; t.btn.BackgroundColor3 = COL.elem
end
TabScrolls["Aimbot"].scroll.Visible = true
TabScrolls["Aimbot"].btn.BackgroundColor3 = COL.accent

task.spawn(function()
    while task.wait(2) do
        if CONFIG_DIRTY and S.AutoSave then
            CONFIG_DIRTY = false
            pcall(function() saveConfig(AUTOSAVE_FILE) end)
        end
    end
end)

if S.ESP.Enabled then
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then CreateESP(p) end
    end
end
for action, state in pairs(S.MobileBtns) do
    if state then ToggleMobileBtn(action, true) end
end

-- ============================================================
-- UNLOAD
-- ============================================================
getgenv().TWKS_UNLOAD = function()
    pcall(function() ScreenGui:Destroy() end)
    for p in pairs(ESPObjs) do RemoveESP(p) end
    ClearAllHitboxes()
    pcall(function() fovCircle:Remove() end)
    pcall(function() RunService:UnbindFromRenderStep("TWKS_AIM") end)
    StickyTarget = nil
    getgenv().TWKS_LOADED = false
end

Notify("TWKS v2.3 · Sticky Aim · Highlight ESP · чистые хитбоксы")