-- ============================================================
-- TIMON HUB v2.9.2 — Scrollable Tabs + Native Mobile Walk Fly + Zero Gravity + Fling Suite
-- language: Lua, file: timonhub.lua, runtime: Roblox Luau (executor)
-- ============================================================

if getgenv().TIMON_LOADED then pcall(function() getgenv().TIMON_UNLOAD() end) end
getgenv().TIMON_LISTENING = nil

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Tween       = game:GetService("TweenService")
local CoreGui     = game:GetService("CoreGui")
local Workspace   = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local DEFAULT_GRAVITY = Workspace.Gravity
getgenv().TIMON_LOADED = true

-- ============================================================
-- SETTINGS
-- ============================================================
local S = {
    Aimbot = {
        Enabled = false, Mode = "Cursor", Smooth = 0.25,
        CameraFOV = 200, MobileFOV = 200,
        Part = "Head", ShowFOV = true, StickyLock = true,
        DistanceWeight = 1.0
    },
    ESP = {
        Enabled = false,
        OutlineColor = Color3.fromRGB(255, 20, 147),
        FillColor = Color3.fromRGB(180, 60, 255),
        FillTransparency = 0.7, OutlineTransparency = 0,
        ThroughWalls = true,
        ShowName = true, ShowDistance = true
    },
    Hitbox = {
        Enabled = false,
        HeadEnabled = true, BodyEnabled = true,
        HeadSize = 3, BodySize = 5,
        Transparency = 0.7,
        Color = Color3.fromRGB(128,128,128),
        NPCSupport = false
    },
    Player = {
        Fly = false, MobileFly = false, FlySpeed = 50,
        ZeroGravity = false,
        WalkSpeed = 16, JumpPower = 50,
        InfiniteJump = false, Noclip = false
    },
    Troll = {
        Spin = false, Invisible = false, ChatSpam = false,
        InvisibleFling = false, AntiFling = false
    },
    Fun = {
        Rainbow = false, Disco = false, LowGravity = false,
        RandomEmote = false, FireTrail = false
    },
    Hamster = { Coins = 0 },
    Binds = {}, MobileBtns = {},
    AutoSave = true, ConfigName = "auto"
}
getgenv().TIMON_SETTINGS = S

-- ============================================================
-- COLORS + HELPERS
-- ============================================================
local COL = {
    bg = Color3.fromRGB(18,12,24), bg2 = Color3.fromRGB(28,18,38),
    elem = Color3.fromRGB(52,36,68), elemHover = Color3.fromRGB(72,48,92),
    accent = Color3.fromRGB(180,60,255), accent2 = Color3.fromRGB(255,60,180),
    text = Color3.fromRGB(250,240,255), sub = Color3.fromRGB(200,180,220),
    stroke = Color3.fromRGB(130,80,170), off = Color3.fromRGB(80,68,90)
}
local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10); c.Parent = o; return c
end
local function stroke(o, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or COL.stroke; s.Thickness = t or 1.5
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
local CONFIG_DIR = "TimonHub"
local AUTOSAVE_FILE = "autosave"
local function ensureDir() pcall(function()
    if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
end) end
local function fileExists(p)
    local ok, r = pcall(function() return isfile(p) end); return ok and r
end
local function packC3(c) return {math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)} end
local function unpackC3(t) return Color3.fromRGB(t[1] or 128, t[2] or 128, t[3] or 128) end

local function packSettings()
    local d = {
        Aimbot = {}, ESP = {}, Hitbox = {}, Player = {},
        Troll = {}, Fun = {},
        Hamster = { Coins = S.Hamster.Coins },
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
    for k, v in pairs(S.Troll) do d.Troll[k] = v end
    for k, v in pairs(S.Fun) do d.Fun[k] = v end
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
    if d.Troll then for k,v in pairs(d.Troll) do if S.Troll[k] ~= nil then S.Troll[k]=v end end end
    if d.Fun then for k,v in pairs(d.Fun) do if S.Fun[k] ~= nil then S.Fun[k]=v end end end
    if d.Hamster and d.Hamster.Coins then S.Hamster.Coins = d.Hamster.Coins end
    if d.Binds then
        S.Binds = {}
        for a, n in pairs(d.Binds) do
            local ok, code = pcall(function() return Enum.KeyCode[n] end)
            if ok and code then S.Binds[a] = code end
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
ScreenGui.Name = "TimonHub_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local CONFIG_DIRTY = false
local function MarkDirty() CONFIG_DIRTY = true end

local function Notify(txt)
    task.spawn(function()
        local n = Instance.new("Frame")
        n.Size = UDim2.new(0, 260, 0, 46)
        n.Position = UDim2.new(1, -280, 1, -80)
        n.BackgroundColor3 = COL.bg2; n.BackgroundTransparency = 0.05
        n.BorderSizePixel = 0; n.Parent = ScreenGui
        corner(n, 12); stroke(n, COL.accent, 2)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-20,1,0); l.Position = UDim2.new(0,14,0,0)
        l.BackgroundTransparency = 1; l.Text = txt
        l.TextColor3 = COL.text; l.Font = Enum.Font.GothamBold
        l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = n
        Tween:Create(n, TweenInfo.new(0.3), {Position = UDim2.new(1,-280,1,-100)}):Play()
        task.wait(2.5)
        Tween:Create(n, TweenInfo.new(0.3),
            {Position = UDim2.new(1,-280,1,-40), BackgroundTransparency = 1}):Play()
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
    f.Size = UDim2.new(1,0,0,28); f.BackgroundTransparency = 1
    f.LayoutOrder = NextOrder(); f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = COL.accent2
    l.Font = Enum.Font.GothamBold; l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
end

local function Toggle(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,38)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,40,0,20); track.Position = UDim2.new(1,-52,0.5,-10)
    track.BackgroundColor3 = COL.off; track.BorderSizePixel = 0
    track.Parent = f; corner(track, 10)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    knob.Parent = track; corner(knob, 8)
    local function render()
        if getter() then
            track.BackgroundColor3 = COL.accent2
            Tween:Create(knob, TweenInfo.new(0.15),
                {Position = UDim2.new(1,-18,0.5,-8)}):Play()
        else
            track.BackgroundColor3 = COL.off
            Tween:Create(knob, TweenInfo.new(0.15),
                {Position = UDim2.new(0,2,0.5,-8)}):Play()
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
    f.Size = UDim2.new(1,0,0,54)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,18); lbl.Position = UDim2.new(0,14,0,8)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-28,0,8); bar.Position = UDim2.new(0,14,0,36)
    bar.BackgroundColor3 = Color3.fromRGB(15,10,20); bar.BorderSizePixel = 0
    bar.Parent = f; corner(bar, 4)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL.accent; fill.BorderSizePixel = 0
    fill.Parent = bar; corner(fill, 4)
    local function render()
        local v = getter()
        local rel = math.clamp((v - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = name .. ": " .. tostring(math.floor(v*100+0.5)/100)
    end
    render(); AddRefresh(render)
    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(1,14,1,24); ca.Position = UDim2.new(0,-7,0,-8)
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
    f.Size = UDim2.new(1,0,0,38)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-32,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0,20,1,0); arrow.Position = UDim2.new(1,-24,0,0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▾"
    arrow.TextColor3 = COL.accent2; arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16; arrow.Parent = f
    local function render() lbl.Text = name .. ": " .. tostring(getter()) end
    render(); AddRefresh(render)
    local popup
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        if popup and popup.Parent then popup:Destroy(); popup = nil; return end
        popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, f.AbsoluteSize.X, 0, #options*28+6)
        popup.Position = UDim2.new(0, f.AbsolutePosition.X,
            0, f.AbsolutePosition.Y + f.AbsoluteSize.Y + 2)
        popup.BackgroundColor3 = COL.bg2; popup.BorderSizePixel = 0
        popup.ZIndex = 50; popup.Parent = ScreenGui
        corner(popup, 10); stroke(popup, COL.accent, 1.5)
        for i, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1,-8,0,24); ob.Position = UDim2.new(0,4,0,(i-1)*28+4)
            ob.BackgroundColor3 = COL.elem; ob.BorderSizePixel = 0
            ob.Text = opt; ob.TextColor3 = COL.text
            ob.Font = Enum.Font.Gotham; ob.TextSize = 14
            ob.ZIndex = 51; ob.Parent = popup; corner(ob, 6)
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
    f.Size = UDim2.new(1,0,0,86)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,18); lbl.Position = UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local swatches = {}
    for i, c in ipairs(PALETTE) do
        local row = math.floor((i-1)/6); local col = (i-1) % 6
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,32,0,22); b.Position = UDim2.new(0,14+col*36,0,28+row*24)
        b.BackgroundColor3 = c; b.BorderSizePixel = 0
        b.Text = ""; b.Parent = f; corner(b, 6)
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
    f.Size = UDim2.new(1,0,0,58)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,20); lbl.Position = UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-28,0,24); box.Position = UDim2.new(0,14,0,28)
    box.BackgroundColor3 = COL.bg2; box.BorderSizePixel = 0
    box.Text = getter() or ""; box.PlaceholderText = placeholder or ""
    box.TextColor3 = COL.text; box.PlaceholderColor3 = COL.sub
    box.Font = Enum.Font.Gotham; box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false; box.Parent = f; corner(box, 6)
    stroke(box, COL.stroke, 1)
    box.FocusLost:Connect(function() setter(box.Text); MarkDirty() end)
end

local function Button(parent, label, callback, opts)
    opts = opts or {}
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = opts.color or COL.elem
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0; b.Text = label
    b.TextColor3 = opts.textColor or COL.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14; b.LayoutOrder = NextOrder()
    b.AutoButtonColor = false
    b.Parent = parent; corner(b, 10); stroke(b, opts.stroke or COL.stroke, 1.5)
    b.MouseEnter:Connect(function()
        Tween:Create(b, TweenInfo.new(0.1),
            {BackgroundColor3 = opts.hover or COL.elemHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(b, TweenInfo.new(0.1),
            {BackgroundColor3 = opts.color or COL.elem}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

local BindRefreshers = {}
local function BindButton(parent, action, name)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,38)
    f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = NextOrder()
    f.Parent = parent; corner(f, 10); stroke(f, COL.stroke, 1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-124,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(0,104,0,28); keyLbl.Position = UDim2.new(1,-114,0.5,-14)
    keyLbl.BackgroundColor3 = COL.bg2; keyLbl.BorderSizePixel = 0
    keyLbl.TextColor3 = COL.accent2; keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 13; keyLbl.Parent = f; corner(keyLbl, 8)
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
    btn.Size = UDim2.new(0,104,0,28); btn.Position = UDim2.new(1,-114,0.5,-14)
    btn.BackgroundTransparency = 1; btn.Text = ""
    btn.Active = true; btn.Parent = f
    btn.MouseButton1Down:Connect(function()
        getgenv().TIMON_LISTENING = action
        keyLbl.Text = "нажми..."; keyLbl.TextColor3 = Color3.fromRGB(255,200,100)
    end)
end

-- ============================================================
-- ADAPTIVE MAIN FRAME
-- ============================================================
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 16); stroke(Main, COL.accent, 2)

local UIScale = Instance.new("UIScale")
UIScale.Parent = Main

local function ApplyMainSize()
    local vp = Workspace.CurrentCamera.ViewportSize
    local baseW, baseH, scale
    if IsMobile then
        baseW, baseH, scale = 560, 420, 0.85
    else
        baseW, baseH, scale = 720, 520, 1.0
    end
    local maxW = vp.X * (IsMobile and 0.95 or 0.82)
    local maxH = vp.Y * (IsMobile and 0.85 or 0.82)
    local finalW = math.min(baseW, maxW / scale)
    local finalH = math.min(baseH, maxH / scale)
    Main.Size = UDim2.new(0, finalW, 0, finalH)
    Main.Position = UDim2.new(0.5, -finalW * scale / 2, 0.5, -finalH * scale / 2)
    UIScale.Scale = scale
end

ApplyMainSize()
pcall(function()
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyMainSize)
end)

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = COL.bg2
TitleBar.BackgroundTransparency = 0.05
TitleBar.BorderSizePixel = 0; TitleBar.Parent = Main
corner(TitleBar, 16)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0); TitleLbl.Position = UDim2.new(0,16,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚡ TIMON HUB · v2.9.2"
TitleLbl.TextColor3 = COL.accent2; TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28); CloseBtn.Position = UDim2.new(1,-36,0.5,-14)
CloseBtn.BackgroundColor3 = COL.accent2; CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
MakeDraggable(Main, TitleBar)

-- ============================================================
-- SCROLLABLE LEFT TAB BAR
-- ============================================================
local Left = Instance.new("ScrollingFrame")
Left.Size = UDim2.new(0,150,1,-52)
Left.Position = UDim2.new(0,10,0,48)
Left.BackgroundColor3 = COL.bg2; Left.BackgroundTransparency = 0.05
Left.BorderSizePixel = 0; Left.Parent = Main
Left.ScrollBarThickness = 4
Left.ScrollBarImageColor3 = COL.accent2
Left.ScrollBarImageTransparency = 0.3
Left.CanvasSize = UDim2.new(0,0,0,0)
Left.AutomaticCanvasSize = Enum.AutomaticSize.Y
Left.ScrollingDirection = Enum.ScrollingDirection.Y
Left.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
corner(Left, 12)
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0,4); LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Parent = Left
local LP2 = Instance.new("UIPadding")
LP2.PaddingTop = UDim.new(0,8); LP2.PaddingLeft = UDim.new(0,6)
LP2.PaddingRight = UDim.new(0,6); LP2.PaddingBottom = UDim.new(0,8)
LP2.Parent = Left

local Right = Instance.new("Frame")
Right.Size = UDim2.new(1,-172,1,-52)
Right.Position = UDim2.new(0,166,0,48)
Right.BackgroundTransparency = 1; Right.Parent = Main

local TabScrolls = {}
local function Tab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = COL.elem; b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0; b.Text = name
    b.TextColor3 = COL.text; b.Font = Enum.Font.GothamBold
    b.TextSize = 13; b.LayoutOrder = NextOrder()
    b.AutoButtonColor = false
    b.Parent = Left; corner(b, 10); stroke(b, COL.stroke, 1.5)
    b.MouseEnter:Connect(function()
        if b.BackgroundColor3 ~= COL.accent then
            Tween:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = COL.elemHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if b.BackgroundColor3 ~= COL.accent then
            Tween:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = COL.elem}):Play()
        end
    end)
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
-- TAB: AIMBOT
-- ============================================================
local A = Tab("🎯 Aimbot")
Section(A, "🎮 Основное")
Toggle(A, "⚡ Enable Aimbot",
    function() return S.Aimbot.Enabled end,
    function(v) S.Aimbot.Enabled = v end)
Toggle(A, "🔒 Sticky Lock",
    function() return S.Aimbot.StickyLock end,
    function(v) S.Aimbot.StickyLock = v end)
Dropdown(A, "🎯 Aim Mode", {"Cursor","Camera","Mobile"},
    function() return S.Aimbot.Mode end,
    function(v) S.Aimbot.Mode = v end)
Slider(A, "💨 Smoothness", 0.01, 1,
    function() return S.Aimbot.Smooth end,
    function(v) S.Aimbot.Smooth = v end)
Section(A, "🎯 Targeting")
Slider(A, "📏 Distance Weight", 0, 5,
    function() return S.Aimbot.DistanceWeight end,
    function(v) S.Aimbot.DistanceWeight = v end)
Section(A, "📐 FOV (не для Cursor)")
Slider(A, "📷 Camera FOV", 30, 800,
    function() return S.Aimbot.CameraFOV end,
    function(v) S.Aimbot.CameraFOV = v end)
Slider(A, "📱 Mobile FOV", 30, 800,
    function() return S.Aimbot.MobileFOV end,
    function(v) S.Aimbot.MobileFOV = v end)
Toggle(A, "⭕ Show FOV Circle",
    function() return S.Aimbot.ShowFOV end,
    function(v) S.Aimbot.ShowFOV = v end)
Section(A, "🎯 Target")
Dropdown(A, "🎯 Target Part",
    {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"},
    function() return S.Aimbot.Part end,
    function(v) S.Aimbot.Part = v end)

-- ============================================================
-- TAB: ESP
-- ============================================================
local E = Tab("👁 ESP")
Section(E, "🔘 Toggle")
Toggle(E, "👁 Enable ESP",
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
Section(E, "✨ Highlight")
ColorPicker(E, "🎨 Outline Color",
    function() return S.ESP.OutlineColor end,
    function(v) S.ESP.OutlineColor = v; RefreshESPColors() end)
ColorPicker(E, "🎨 Fill Color",
    function() return S.ESP.FillColor end,
    function(v) S.ESP.FillColor = v; RefreshESPColors() end)
Slider(E, "💧 Fill Transparency", 0, 1,
    function() return S.ESP.FillTransparency end,
    function(v) S.ESP.FillTransparency = v; RefreshESPColors() end)
Slider(E, "💧 Outline Transparency", 0, 1,
    function() return S.ESP.OutlineTransparency end,
    function(v) S.ESP.OutlineTransparency = v; RefreshESPColors() end)
Toggle(E, "🧱 Through Walls",
    function() return S.ESP.ThroughWalls end,
    function(v) S.ESP.ThroughWalls = v; RefreshESPColors() end)
Section(E, "📝 Text")
Toggle(E, "👤 Show Name",
    function() return S.ESP.ShowName end,
    function(v) S.ESP.ShowName = v end)
Toggle(E, "📏 Show Distance",
    function() return S.ESP.ShowDistance end,
    function(v) S.ESP.ShowDistance = v end)

-- ============================================================
-- TAB: HITBOX
-- ============================================================
local H = Tab("📦 Hitbox")
Section(H, "🔘 Toggle")
Toggle(H, "📦 Enable Hitbox",
    function() return S.Hitbox.Enabled end,
    function(v)
        S.Hitbox.Enabled = v
        if not v then ClearAllHitboxes() end
    end)
Section(H, "🎯 Parts")
Toggle(H, "👤 Head Hitbox",
    function() return S.Hitbox.HeadEnabled end,
    function(v) S.Hitbox.HeadEnabled = v; RefreshHitboxes() end)
Toggle(H, "🧍 Body Hitbox",
    function() return S.Hitbox.BodyEnabled end,
    function(v) S.Hitbox.BodyEnabled = v; RefreshHitboxes() end)
Section(H, "📐 Sizes")
Slider(H, "👤 Head Size", 1, 15,
    function() return S.Hitbox.HeadSize end,
    function(v) S.Hitbox.HeadSize = v; RefreshHitboxes() end)
Slider(H, "🧍 Body Size", 2, 25,
    function() return S.Hitbox.BodySize end,
    function(v) S.Hitbox.BodySize = v; RefreshHitboxes() end)
Section(H, "🎨 Visual")
Slider(H, "💧 Transparency", 0, 1,
    function() return S.Hitbox.Transparency end,
    function(v) S.Hitbox.Transparency = v; RefreshHitboxes() end)
ColorPicker(H, "🎨 Hitbox Color",
    function() return S.Hitbox.Color end,
    function(v) S.Hitbox.Color = v; RefreshHitboxes() end)
Section(H, "🎯 NPC Hitbox")
Toggle(H, "🎯 Enable NPC Hitbox",
    function() return S.Hitbox.NPCSupport end,
    function(v)
        S.Hitbox.NPCSupport = v
        if not v then ClearAllNPCHitboxes() end
    end)

-- ============================================================
-- TAB: PLAYER
-- ============================================================
local P = Tab("🏃 Player")
Section(P, "🏃 Movement")
Slider(P, "⚡ Walk Speed", 16, 300,
    function() return S.Player.WalkSpeed end,
    function(v) S.Player.WalkSpeed = v end)
Slider(P, "🦘 Jump Power", 50, 300,
    function() return S.Player.JumpPower end,
    function(v) S.Player.JumpPower = v end)
Toggle(P, "♾ Infinite Jump",
    function() return S.Player.InfiniteJump end,
    function(v) S.Player.InfiniteJump = v end)
Toggle(P, "👻 Noclip",
    function() return S.Player.Noclip end,
    function(v) S.Player.Noclip = v end)
Section(P, "✈ Fly")
Toggle(P, "✈ Fly (ПК)",
    function() return S.Player.Fly end,
    function(v) S.Player.Fly = v end)
Toggle(P, "📱 Mobile Fly (Native Joystick)",
    function() return S.Player.MobileFly end,
    function(v) S.Player.MobileFly = v end)
Slider(P, "🚀 Fly Speed", 10, 300,
    function() return S.Player.FlySpeed end,
    function(v) S.Player.FlySpeed = v end)
Section(P, "🪐 Gravity")
Toggle(P, "🪐 Zero Gravity",
    function() return S.Player.ZeroGravity end,
    function(v) S.Player.ZeroGravity = v; applyGravityState() end)

-- ============================================================
-- TAB: TROLL
-- ============================================================
local T = Tab("😈 Troll")

Section(T, "🌀 Движение")
Toggle(T, "🌀 Spin Self",
    function() return S.Troll.Spin end,
    function(v) S.Troll.Spin = v end)
Button(T, "🚀 Fling Self", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(800, 500, 800)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
        task.wait(0.4)
        pcall(function() bv:Destroy() end)
        Notify("🚀 Fling!")
    end
end, {color = COL.accent2, hover = Color3.fromRGB(255, 90, 200), textColor = Color3.new(1,1,1)})

Section(T, "🎭 Внешность")
Toggle(T, "👻 Invisible Self",
    function() return S.Troll.Invisible end,
    function(v)
        S.Troll.Invisible = v
        if not v and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0
                elseif p:IsA("Decal") then p.Transparency = 0 end
            end
        end
    end)
Button(T, "🥷 Strip Accessories", function()
    if LP.Character then
        for _, acc in ipairs(LP.Character:GetDescendants()) do
            if acc:IsA("Accessory") or acc:IsA("Hat") then
                pcall(function() acc:Destroy() end)
            end
        end
        Notify("🥷 Аксессуары сняты")
    end
end)

Section(T, "🎯 Fling Suite")
Toggle(T, "👻 Invisible Fling",
    function() return S.Troll.InvisibleFling end,
    function(v)
        S.Troll.InvisibleFling = v
        if not v and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0
                elseif p:IsA("Decal") then p.Transparency = 0 end
            end
        end
    end)
Slider(T, "📏 Fling Radius", 3, 30,
    function() return S.Troll.FlingRadius or 10 end,
    function(v) S.Troll.FlingRadius = v end)
Toggle(T, "🛡 Anti Fling",
    function() return S.Troll.AntiFling end,
    function(v)
        S.Troll.AntiFling = v
        if not v and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end)

Section(T, "💬 Чат")
Toggle(T, "💬 Chat Spam",
    function() return S.Troll.ChatSpam end,
    function(v) S.Troll.ChatSpam = v end)
TextBox(T, "📝 Сообщение", "Timon Hub on top 🔥",
    function() return S.Troll.SpamMsg or "Timon Hub on top 🔥" end,
    function(v) S.Troll.SpamMsg = v end)

-- ============================================================
-- TAB: FUN
-- ============================================================
local FN = Tab("🎉 Fun")
Section(FN, "✨ Внешность")
Toggle(FN, "🌈 Rainbow Character",
    function() return S.Fun.Rainbow end,
    function(v)
        S.Fun.Rainbow = v
        if not v and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.Plastic
                    p.Color = Color3.fromRGB(163,162,165)
                end
            end
        end
    end)
Toggle(FN, "🎆 Disco Lights",
    function() return S.Fun.Disco end,
    function(v) S.Fun.Disco = v end)
Toggle(FN, "🔥 Fire Trail",
    function() return S.Fun.FireTrail end,
    function(v) S.Fun.FireTrail = v end)
Section(FN, "🌌 Мир")
Toggle(FN, "🪐 Low Gravity",
    function() return S.Fun.LowGravity end,
    function(v)
        S.Fun.LowGravity = v
        applyGravityState()
    end)
Section(FN, "🎭 Анимации")
Toggle(FN, "🎵 Random Emote Loop",
    function() return S.Fun.RandomEmote end,
    function(v) S.Fun.RandomEmote = v end)

-- ============================================================
-- TAB: BINDS
-- ============================================================
local B = Tab("🔗 Binds")
Section(B, "⌨ Key Binds (ПК)")
BindButton(B, "Aimbot", "🎯 Aimbot")
BindButton(B, "ESP", "👁 ESP")
BindButton(B, "Hitbox", "📦 Hitbox")
BindButton(B, "Fly", "✈ Fly")
BindButton(B, "Noclip", "👻 Noclip")
BindButton(B, "InfiniteJump", "♾ Infinite Jump")
BindButton(B, "ZeroGravity", "🪐 Zero Gravity")
Section(B, "📱 Floating Buttons (Mobile)")
Toggle(B, "🎯 Aimbot Button",
    function() return S.MobileBtns.Aimbot == true end,
    function(v) S.MobileBtns.Aimbot = v; ToggleMobileBtn("Aimbot", v) end)
Toggle(B, "✈ Fly Button (PC)",
    function() return S.MobileBtns.Fly == true end,
    function(v) S.MobileBtns.Fly = v; ToggleMobileBtn("Fly", v) end)
Toggle(B, "📱 Mobile Fly Button",
    function() return S.MobileBtns.MobileFly == true end,
    function(v) S.MobileBtns.MobileFly = v; ToggleMobileBtn("MobileFly", v) end)
Toggle(B, "🪐 Zero Gravity Button",
    function() return S.MobileBtns.ZeroGravity == true end,
    function(v) S.MobileBtns.ZeroGravity = v; ToggleMobileBtn("ZeroGravity", v) end)
Toggle(B, "👻 Noclip Button",
    function() return S.MobileBtns.Noclip == true end,
    function(v) S.MobileBtns.Noclip = v; ToggleMobileBtn("Noclip", v) end)
Toggle(B, "👻 Invisible Fling Button",
    function() return S.MobileBtns.InvisibleFling == true end,
    function(v) S.MobileBtns.InvisibleFling = v; ToggleMobileBtn("InvisibleFling", v) end)
Toggle(B, "🛡 Anti Fling Button",
    function() return S.MobileBtns.AntiFling == true end,
    function(v) S.MobileBtns.AntiFling = v; ToggleMobileBtn("AntiFling", v) end)

-- ============================================================
-- TAB: HAMSTER
-- ============================================================
local HT = Tab("🐹 Hamster")

local coinLbl = Instance.new("TextLabel")
coinLbl.Size = UDim2.new(1,0,0,48)
coinLbl.BackgroundColor3 = COL.bg2; coinLbl.BackgroundTransparency = 0.05
coinLbl.BorderSizePixel = 0; coinLbl.LayoutOrder = -1
coinLbl.Font = Enum.Font.GothamBold; coinLbl.TextSize = 22
coinLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLbl.TextXAlignment = Enum.TextXAlignment.Right
coinLbl.Text = "💰 " .. tostring(S.Hamster.Coins)
coinLbl.Parent = HT; corner(coinLbl, 10); stroke(coinLbl, Color3.fromRGB(255, 215, 0), 2)
local pad1 = Instance.new("UIPadding")
pad1.PaddingRight = UDim.new(0, 16); pad1.Parent = coinLbl

local function refreshCoin() coinLbl.Text = "💰 " .. tostring(S.Hamster.Coins) end
AddRefresh(refreshCoin)

local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(0, 180, 0, 180)
spamBtn.AnchorPoint = Vector2.new(0.5, 0.5)
spamBtn.Position = UDim2.new(0.5, 0, 0.55, 0)
spamBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
spamBtn.BorderSizePixel = 0
spamBtn.Text = "🐹"
spamBtn.Font = Enum.Font.GothamBold
spamBtn.TextSize = 110
spamBtn.AutoButtonColor = false
spamBtn.LayoutOrder = NextOrder()
spamBtn.Parent = HT
corner(spamBtn, 90)
stroke(spamBtn, Color3.fromRGB(255, 180, 0), 3)

local spamLabel = Instance.new("TextLabel")
spamLabel.Size = UDim2.new(1,0,0,32)
spamLabel.BackgroundTransparency = 1
spamLabel.LayoutOrder = NextOrder()
spamLabel.Text = "🐹 ЖМИ ХОМЯКА 🐹"
spamLabel.Font = Enum.Font.GothamBold
spamLabel.TextSize = 17
spamLabel.TextColor3 = COL.accent2
spamLabel.Parent = HT

local spamInfo = Instance.new("TextLabel")
spamInfo.Size = UDim2.new(1,0,0,32)
spamInfo.BackgroundTransparency = 1
spamInfo.LayoutOrder = NextOrder()
spamInfo.Text = "💰 Каждый клик = +1 монета"
spamInfo.Font = Enum.Font.Gotham
spamInfo.TextSize = 14
spamInfo.TextColor3 = COL.sub
spamInfo.Parent = HT

local clickCooldown = false
spamBtn.MouseButton1Click:Connect(function()
    if clickCooldown then return end
    clickCooldown = true
    S.Hamster.Coins = S.Hamster.Coins + 1
    refreshCoin(); MarkDirty()
    Tween:Create(spamBtn, TweenInfo.new(0.08), {Size = UDim2.new(0, 160, 0, 160)}):Play()
    task.delay(0.09, function()
        Tween:Create(spamBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 180, 0, 180)}):Play()
    end)
    task.delay(0.05, function() clickCooldown = false end)
end)

Button(HT, "🔄 Сбросить монеты", function()
    S.Hamster.Coins = 0; refreshCoin(); MarkDirty()
    Notify("💰 Монеты сброшены")
end, {textColor = COL.accent2})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local ST = Tab("⚙ Settings")
Section(ST, "🛠 Действия")
Button(ST, "🔄 Сбросить настройки", function()
    S.Aimbot.Enabled=false; S.Aimbot.Smooth=0.25
    S.Aimbot.CameraFOV=200; S.Aimbot.MobileFOV=200
    S.Aimbot.DistanceWeight=1
    S.ESP.Enabled=false; S.Hitbox.Enabled=false
    S.Hitbox.NPCSupport=false
    S.Player.Fly=false; S.Player.MobileFly=false
    S.Player.Noclip=false; S.Player.InfiniteJump=false
    S.Player.ZeroGravity=false
    S.Troll.InvisibleFling=false; S.Troll.AntiFling=false
    applyGravityState()
    RefreshAll(); MarkDirty(); Notify("⚙ Настройки сброшены")
end)
Button(ST, "🚪 Выгрузить скрипт", function()
    pcall(function() getgenv().TIMON_UNLOAD() end)
end, {color = COL.accent2, hover = Color3.fromRGB(255, 90, 200), textColor = Color3.new(1,1,1)})

Section(ST, "💾 Конфиги")
TextBox(ST, "📝 Имя конфига", "auto",
    function() return S.ConfigName end,
    function(v) S.ConfigName = (v ~= "" and v) or "auto" end)
Button(ST, "💾 Сохранить (перезапись)", function()
    local name = S.ConfigName or "auto"
    if saveConfig(name) then
        Notify("💾 Сохранено: "..name)
        if RefreshCfgList then RefreshCfgList() end
    else Notify("⚠ Ошибка") end
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
    ClearAllNPCHitboxes()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(ApplyHitbox, pl) end
    end
    if S.Hitbox.NPCSupport then
        refreshNPCCache()
        for model in pairs(NPCCache) do
            pcall(ApplyNPCHitbox, model)
        end
    end
    for action, state in pairs(S.MobileBtns) do
        ToggleMobileBtn(action, state)
    end
    applyGravityState()
    MarkDirty()
end

Button(ST, "📂 Загрузить", function()
    local name = S.ConfigName or "auto"
    if loadConfigFile(name) then
        applyLoadedSettings(); Notify("📂 Загружено: "..name)
    else Notify("⚠ Не найден: "..name) end
end)
Button(ST, "🗑 Удалить", function()
    local name = S.ConfigName or "auto"
    deleteConfig(name); Notify("🗑 Удалено: "..name)
    if RefreshCfgList then RefreshCfgList() end
end)
Toggle(ST, "💾 Авто-сохранение",
    function() return S.AutoSave end,
    function(v) S.AutoSave = v end)

Section(ST, "📁 Доступные конфиги")
local cfgListLbl = Instance.new("TextLabel")
cfgListLbl.Size = UDim2.new(1,0,0,90)
cfgListLbl.BackgroundColor3 = COL.elem; cfgListLbl.BackgroundTransparency = 0.05
cfgListLbl.BorderSizePixel = 0; cfgListLbl.LayoutOrder = NextOrder()
cfgListLbl.TextColor3 = COL.sub; cfgListLbl.Font = Enum.Font.Gotham
cfgListLbl.TextSize = 13; cfgListLbl.TextWrapped = true
cfgListLbl.TextXAlignment = Enum.TextXAlignment.Left
cfgListLbl.TextYAlignment = Enum.TextYAlignment.Top
cfgListLbl.Parent = ST; corner(cfgListLbl, 10); stroke(cfgListLbl, COL.stroke, 1.5)
local pad2 = Instance.new("UIPadding")
pad2.PaddingLeft = UDim.new(0, 12); pad2.PaddingTop = UDim.new(0, 6)
pad2.Parent = cfgListLbl

function RefreshCfgList()
    local list = listConfigs()
    if #list == 0 then cfgListLbl.Text = "(пусто)"
    else
        table.sort(list)
        cfgListLbl.Text = table.concat(list, "\n")
    end
end
RefreshCfgList()

-- ============================================================
-- GRAVITY STATE
-- ============================================================
function applyGravityState()
    if S.Player.ZeroGravity then
        Workspace.Gravity = 0
    elseif S.Fun.LowGravity then
        Workspace.Gravity = 50
    else
        Workspace.Gravity = DEFAULT_GRAVITY
    end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 1
fovCircle.Color = COL.accent; fovCircle.Transparency = 0.7

local StickyTarget = nil

local function IsPlayerValid(pl)
    if not pl or pl.Parent ~= Players then return false end
    local ch = pl.Character; if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
    if not part then return false end
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    return onScreen and sp.Z >= 0
end

local function FindTarget()
    if S.Aimbot.StickyLock and StickyTarget then
        if IsPlayerValid(StickyTarget) then
            local ch = StickyTarget.Character
            return ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        else StickyTarget = nil end
    end

    local target, targetPlayer, bestScore = nil, nil, math.huge
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

    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.zero

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        local ch = pl.Character
        if not ch then continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z < 0 then continue end

        local pixelDist = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
        if pixelDist > fovLimit then continue end

        local worldDist = (part.Position - myPos).Magnitude
        local score = pixelDist + worldDist * S.Aimbot.DistanceWeight

        if score < bestScore then
            bestScore = score; target = part; targetPlayer = pl
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

RunService:BindToRenderStep("TIMON_AIM", Enum.RenderPriority.Camera.Value + 1, function()
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
-- ESP
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
    for _, d in pairs(ESPObjs or {}) do
        if d.hl then applyHighlight(d.hl) end
    end
end

function CreateESP(pl)
    if pl == LP or ESPObjs[pl] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TimonHub_HL_" .. pl.Name
    applyHighlight(hl)
    if pl.Character then hl.Adornee = pl.Character end
    hl.Parent = ScreenGui

    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.Size = 14; nm.Color = S.ESP.OutlineColor

    local ds = Drawing.new("Text")
    ds.Visible = false; ds.Center = true; ds.Outline = true
    ds.Size = 13; ds.Color = Color3.fromRGB(230,230,230)

    ESPObjs[pl] = {hl = hl, name = nm, dist = ds}

    pl.CharacterAdded:Connect(function(ch)
        task.wait(0.3)
        local e = ESPObjs[pl]
        if e and e.hl then e.hl.Adornee = ch end
    end)
end

function RemoveESP(pl)
    local e = ESPObjs[pl]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.name:Remove() end)
        pcall(function() e.dist:Remove() end)
        ESPObjs[pl] = nil
    end
end

Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        if S.ESP.Enabled then CreateESP(pl) end
    end)
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
-- HITBOX (Players)
-- ============================================================
local HitboxParts = {}

local function createHitboxPart(name)
    local p = Instance.new("Part")
    p.Name = "TimonHub_HB_" .. name
    p.Anchored = true; p.CanCollide = false
    p.CanQuery = false; p.CanTouch = false
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

function ApplyHitbox(pl)
    if pl == LP or not pl.Character then return end
    local ch = pl.Character
    local entry = HitboxParts[pl]
    if not entry then entry = {}; HitboxParts[pl] = entry end

    if S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = createHitboxPart("Head")
        end
        local head = ch:FindFirstChild("Head")
        if head then
            entry.head.Size = Vector3.new(S.Hitbox.HeadSize, S.Hitbox.HeadSize, S.Hitbox.HeadSize)
            entry.head.CFrame = head.CFrame
            entry.head.Color = S.Hitbox.Color
            entry.head.Transparency = S.Hitbox.Transparency
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil
    end

    if S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = createHitboxPart("Body")
        end
        local torso = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        if torso then
            entry.body.Size = Vector3.new(S.Hitbox.BodySize, S.Hitbox.BodySize, S.Hitbox.BodySize)
            entry.body.CFrame = torso.CFrame
            entry.body.Color = S.Hitbox.Color
            entry.body.Transparency = S.Hitbox.Transparency
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
    for pl in pairs(HitboxParts) do RemoveHitboxFor(pl) end
    HitboxParts = {}
end

function RefreshHitboxes()
    ClearAllHitboxes()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            pcall(ApplyHitbox, pl)
        end
    end
end

Players.PlayerRemoving:Connect(RemoveHitboxFor)

task.spawn(function()
    while task.wait(0.3) do
        if S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                pcall(ApplyHitbox, pl)
            end
        end
    end
end)

-- ============================================================
-- NPC HITBOX
-- ============================================================
local NPCCache = {}
local NPCHitboxes = {}

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isNPC(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if isPlayerCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart")
       and not model:FindFirstChild("Torso") then return false end
    return true
end

function refreshNPCCache()
    local newCache = {}
    local function scanFolder(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and isNPC(child) then
                newCache[child] = true
            elseif child:IsA("Folder") then
                scanFolder(child)
            end
        end
    end
    scanFolder(Workspace)
    NPCCache = newCache
end

function ApplyNPCHitbox(model)
    if not model or not model.Parent then return end
    if isPlayerCharacter(model) then return end

    local entry = NPCHitboxes[model]
    if not entry then entry = {head = nil, body = nil}; NPCHitboxes[model] = entry end

    if S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = createHitboxPart("NPCHead")
        end
        local head = model:FindFirstChild("Head")
        if head then
            entry.head.Size = Vector3.new(S.Hitbox.HeadSize, S.Hitbox.HeadSize, S.Hitbox.HeadSize)
            entry.head.CFrame = head.CFrame
            entry.head.Color = S.Hitbox.Color
            entry.head.Transparency = S.Hitbox.Transparency
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil
    end

    if S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = createHitboxPart("NPCBody")
        end
        local torso = model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("HumanoidRootPart")
        if torso then
            entry.body.Size = Vector3.new(S.Hitbox.BodySize, S.Hitbox.BodySize, S.Hitbox.BodySize)
            entry.body.CFrame = torso.CFrame
            entry.body.Color = S.Hitbox.Color
            entry.body.Transparency = S.Hitbox.Transparency
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil
    end
end

function ClearAllNPCHitboxes()
    for model, e in pairs(NPCHitboxes) do
        if e.head and e.head.Parent then e.head:Destroy() end
        if e.body and e.body.Parent then e.body:Destroy() end
    end
    NPCHitboxes = {}
    NPCCache = {}
end

local function RemoveNPCHitbox(model)
    local e = NPCHitboxes[model]
    if e then
        if e.head and e.head.Parent then e.head:Destroy() end
        if e.body and e.body.Parent then e.body:Destroy() end
        NPCHitboxes[model] = nil
    end
end

task.spawn(function()
    while task.wait(1) do
        if S.Hitbox.NPCSupport then
            refreshNPCCache()
            for model in pairs(NPCCache) do
                pcall(ApplyNPCHitbox, model)
            end
            for model in pairs(NPCHitboxes) do
                if not model.Parent or not NPCCache[model] then
                    RemoveNPCHitbox(model)
                end
            end
        end
    end
end)

-- ============================================================
-- PLAYER MODS
-- ============================================================
RunService.Heartbeat:Connect(function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = S.Player.WalkSpeed
        hum.JumpPower = S.Player.JumpPower
    end
end)
UIS.JumpRequest:Connect(function()
    if S.Player.InfiniteJump then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip
task.spawn(function()
    while task.wait(0.1) do
        if S.Player.Noclip and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Chat Spam
task.spawn(function()
    while task.wait(2) do
        if S.Troll.ChatSpam then
            pcall(function()
                game:GetService("ReplicatedStorage")
                    .DefaultChatSystemChatEvents
                    .SayMessageRequest:FireServer(S.Troll.SpamMsg or "Timon Hub on top 🔥", "All")
            end)
        end
    end
end)

-- Random Emote
task.spawn(function()
    while task.wait(3) do
        if S.Fun.RandomEmote then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local emotes = {"wave", "dance", "point", "laugh", "cheer"}
                pcall(function()
                    hum:PlayEmote(emotes[math.random(#emotes)])
                end)
            end
        end
    end
end)

-- ============================================================
-- INVISIBLE FLING + ANTI FLING
-- ============================================================
local ActiveFlingBV = {}

local function clearFlingFor(pl)
    local list = ActiveFlingBV[pl]
    if list then
        for _, inst in ipairs(list) do
            pcall(function() inst:Destroy() end)
        end
        ActiveFlingBV[pl] = nil
    end
end

local function flingPlayer(pl)
    if not pl or pl == LP then return end
    local ch = pl.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if ActiveFlingBV[pl] then return end
    local list = {}
    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(99999, 99999, 99999)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = hrp
    table.insert(list, bav)

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(99999, 99999, 99999)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = hrp
    table.insert(list, bv)

    ActiveFlingBV[pl] = list
    task.delay(0.8, function()
        clearFlingFor(pl)
    end)
end

task.spawn(function()
    while task.wait(0.25) do
        if S.Troll.InvisibleFling and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 1
                elseif p:IsA("Decal") then p.Transparency = 1 end
            end
            local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local radius = S.Troll.FlingRadius or 10
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP and pl.Character then
                        local thrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if thrp then
                            local dist = (thrp.Position - myHRP.Position).Magnitude
                            if dist <= radius then
                                flingPlayer(pl)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local ANTI_FLING_PARTS = {
    "BodyVelocity","BodyAngularVelocity","BodyGyro","BodyThrust","BodyForce"
}

task.spawn(function()
    while task.wait(0.1) do
        if S.Troll.AntiFling and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    for _, class in ipairs(ANTI_FLING_PARTS) do
                        for _, inst in ipairs(p:GetChildren()) do
                            if inst:IsA(class) then
                                pcall(function() inst:Destroy() end)
                            end
                        end
                    end
                    if p.Velocity.Magnitude > 500 then
                        p.Velocity = Vector3.zero
                        p.RotVelocity = Vector3.zero
                    end
                    p.CanCollide = false
                end
            end
        end
    end
end)

-- ============================================================
-- FLY (PC) & MOBILE FLY (Native Joystick / MoveDirection)
-- ============================================================
local FlyBV, FlyBG
local SpinBV, DiscoLight, FireEmitter

RunService.RenderStepped:Connect(function(dt)
    local ch = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")

    -- Fly PC (WASD + Space/Shift)
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

    -- Mobile Fly (Native Joystick / MoveDirection: куда стик повернул — туда и летим)
    elseif S.Player.MobileFly and hrp and hum then
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
        
        -- Используем встроенный MoveDirection от стандартного джойстика Roblox
        local moveDir = hum.MoveDirection
        local camCF = Camera.CFrame
        
        -- Переводим направление стика относительно камеры
        local flyVelocity = Vector3.zero
        if moveDir.Magnitude > 0 then
            -- Проекция камеры на плоскость пола для горизонтального движения стиком
            local flatCamLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
            local flatCamRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
            
            local worldMoveDir = (flatCamLook * -moveDir.Z) + (flatCamRight * moveDir.X)
            flyVelocity = worldMoveDir.Unit * S.Player.FlySpeed
        end
        
        FlyBV.Velocity = flyVelocity
        FlyBG.CFrame = camCF

    elseif FlyBV then
        FlyBV:Destroy(); FlyBV = nil
        if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    end

    -- Hitbox CFrame sync (Players)
    if S.Hitbox.Enabled then
        for pl, e in pairs(HitboxParts) do
            local c = pl.Character
            if c then
                if e.head then
                    local h = c:FindFirstChild("Head")
                    if h then e.head.CFrame = h.CFrame end
                end
                if e.body then
                    local t = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
                    if t then e.body.CFrame = t.CFrame end
                end
            end
        end
    end

    -- NPC hitbox CFrame sync
    if S.Hitbox.NPCSupport then
        for model, e in pairs(NPCHitboxes) do
            if model.Parent then
                if e.head then
                    local h = model:FindFirstChild("Head")
                    if h then e.head.CFrame = h.CFrame end
                end
                if e.body then
                    local t = model:FindFirstChild("UpperTorso")
                        or model:FindFirstChild("Torso")
                        or model:FindFirstChild("HumanoidRootPart")
                    if t then e.body.CFrame = t.CFrame end
                end
            end
        end
    end

    -- ESP
    if S.ESP.Enabled then
        for pl, d in pairs(ESPObjs) do
            local c = pl.Character
            if not c then
                d.name.Visible = false; d.dist.Visible = false
                if d.hl then d.hl.Enabled = false end
                continue
            end
            if d.hl then
                d.hl.Enabled = true
                if d.hl.Adornee ~= c then d.hl.Adornee = c end
            end
            local head = c:FindFirstChild("Head")
            local root = c:FindFirstChild("HumanoidRootPart")
            if not head or not root then
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
            else d.name.Visible = false end
            if S.ESP.ShowDistance then
                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                d.dist.Text = dist .. "m"
                d.dist.Position = Vector2.new(top.X, top.Y - 4)
                d.dist.Visible = true
            else d.dist.Visible = false end
        end
    end

    -- Troll: Spin
    if S.Troll.Spin and hrp then
        if not SpinBV or not SpinBV.Parent then
            SpinBV = Instance.new("BodyAngularVelocity")
            SpinBV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            SpinBV.AngularVelocity = Vector3.new(0, 30, 0)
            SpinBV.Parent = hrp
        end
    elseif SpinBV then
        SpinBV:Destroy(); SpinBV = nil
    end

    -- Troll: Invisible Self
    if S.Troll.Invisible and ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = 1
            elseif p:IsA("Decal") then p.Transparency = 1 end
        end
    end

    -- Fun: Rainbow
    if S.Fun.Rainbow and ch then
        local hue = tick() % 1
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Color = Color3.fromHSV(hue, 1, 1)
                p.Material = Enum.Material.Neon
            end
        end
    end

    -- Fun: Disco
    if S.Fun.Disco and hrp then
        if not DiscoLight or not DiscoLight.Parent then
            DiscoLight = Instance.new("PointLight")
            DiscoLight.Brightness = 5
            DiscoLight.Range = 30
            DiscoLight.Parent = hrp
        end
        DiscoLight.Color = Color3.fromHSV(tick() % 1, 1, 1)
    elseif DiscoLight then
        DiscoLight:Destroy(); DiscoLight = nil
    end

    -- Fun: Fire Trail
    if S.Fun.FireTrail and hrp then
        if not FireEmitter or not FireEmitter.Parent then
            FireEmitter = Instance.new("ParticleEmitter")
            FireEmitter.Texture = "rbxasset://textures/particles/fire_main.dds"
            FireEmitter.Rate = 50
            FireEmitter.Lifetime = NumberRange.new(0.5, 1)
            FireEmitter.Speed = NumberRange.new(2, 5)
            FireEmitter.Size = NumberSequence.new(1, 0)
            FireEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0),
                Color3.fromRGB(255, 200, 0))
            FireEmitter.Parent = hrp
        end
    elseif FireEmitter then
        FireEmitter:Destroy(); FireEmitter = nil
    end
end)

-- ============================================================
-- ACTIONS
-- ============================================================
local Actions = {}
Actions.Aimbot = function()
    S.Aimbot.Enabled = not S.Aimbot.Enabled; RefreshAll(); MarkDirty()
    if not S.Aimbot.Enabled then StickyTarget = nil end
    Notify("🎯 Aimbot: "..tostring(S.Aimbot.Enabled))
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
    Notify("👁 ESP: "..tostring(S.ESP.Enabled))
end
Actions.Hitbox = function()
    S.Hitbox.Enabled = not S.Hitbox.Enabled; RefreshAll(); MarkDirty()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(ApplyHitbox, pl) end
    else ClearAllHitboxes() end
    Notify("📦 Hitbox: "..tostring(S.Hitbox.Enabled))
end
Actions.Fly = function()
    S.Player.Fly = not S.Player.Fly; RefreshAll(); MarkDirty()
    Notify("✈ Fly: "..tostring(S.Player.Fly))
end
Actions.MobileFly = function()
    S.Player.MobileFly = not S.Player.MobileFly; RefreshAll(); MarkDirty()
    Notify("📱 Mobile Fly (Joystick): "..tostring(S.Player.MobileFly))
end
Actions.ZeroGravity = function()
    S.Player.ZeroGravity = not S.Player.ZeroGravity
    applyGravityState(); RefreshAll(); MarkDirty()
    Notify("🪐 ZeroG: "..tostring(S.Player.ZeroGravity))
end
Actions.Noclip = function()
    S.Player.Noclip = not S.Player.Noclip; RefreshAll(); MarkDirty()
    if not S.Player.Noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    Notify("👻 Noclip: "..tostring(S.Player.Noclip))
end
Actions.InfiniteJump = function()
    S.Player.InfiniteJump = not S.Player.InfiniteJump; RefreshAll(); MarkDirty()
    Notify("♾ InfJump: "..tostring(S.Player.InfiniteJump))
end
Actions.InvisibleFling = function()
    S.Troll.InvisibleFling = not S.Troll.InvisibleFling; RefreshAll(); MarkDirty()
    Notify("👻 InvFling: "..tostring(S.Troll.InvisibleFling))
end
Actions.AntiFling = function()
    S.Troll.AntiFling = not S.Troll.AntiFling; RefreshAll(); MarkDirty()
    Notify("🛡 AntiFling: "..tostring(S.Troll.AntiFling))
end

-- ============================================================
-- INPUT (BINDS + LISTEN)
-- ============================================================
UIS.InputBegan:Connect(function(input, gp)
    if getgenv().TIMON_LISTENING then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = getgenv().TIMON_LISTENING
            getgenv().TIMON_LISTENING = nil
            S.Binds[action] = input.KeyCode
            if BindRefreshers[action] then BindRefreshers[action]() end
            MarkDirty()
            Notify("🔗 Bind: "..action.." → "..tostring(input.KeyCode):gsub("Enum.KeyCode.",""))
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
-- MOBILE FLOATING BUTTONS
-- ============================================================
local MobileButtons = {}
local MOBILE_POS_INDEX = 0

function ToggleMobileBtn(action, show)
    if MobileButtons[action] then
        MobileButtons[action]:Destroy(); MobileButtons[action] = nil
    end
    if not show then return end
    MOBILE_POS_INDEX = MOBILE_POS_INDEX + 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,58,0,58)
    b.Position = UDim2.new(0, 20, 0, 120 + (MOBILE_POS_INDEX - 1) * 68)
    b.BackgroundColor3 = COL.bg2; b.BackgroundTransparency = 0.1
    b.TextColor3 = COL.accent2; b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    local LABEL = {
        Aimbot = "AIM", Fly = "FLY", MobileFly = "MFLY",
        ZeroGravity = "GRAV", Noclip = "NOCLIP",
        InvisibleFling = "IFLNG", AntiFling = "AFLNG",
        InfiniteJump = "IJMP"
    }
    b.Text = LABEL[action] or action
    b.BorderSizePixel = 0
    b.Parent = ScreenGui; corner(b, 29); stroke(b, COL.accent2, 2)
    MakeDraggable(b, b)
    local function activeState()
        if action == "Aimbot" then return S.Aimbot.Enabled
        elseif action == "Fly" then return S.Player.Fly
        elseif action == "MobileFly" then return S.Player.MobileFly
        elseif action == "ZeroGravity" then return S.Player.ZeroGravity
        elseif action == "Noclip" then return S.Player.Noclip
        elseif action == "InfiniteJump" then return S.Player.InfiniteJump
        elseif action == "InvisibleFling" then return S.Troll.InvisibleFling
        elseif action == "AntiFling" then return S.Troll.AntiFling
        end
        return false
    end
    local function paint()
        if activeState() then
            b.BackgroundColor3 = COL.accent2
            b.TextColor3 = Color3.new(1,1,1)
        else
            b.BackgroundColor3 = COL.bg2
            b.TextColor3 = COL.accent2
        end
    end
    paint()
    AddRefresh(paint)
    b.MouseButton1Click:Connect(function()
        if Actions[action] then Actions[action]() end
        paint()
    end)
    MobileButtons[action] = b
end

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,52,0,52)
OpenBtn.Position = UDim2.new(0,20,1,-80)
OpenBtn.BackgroundColor3 = COL.bg2; OpenBtn.BackgroundTransparency = 0.1
OpenBtn.TextColor3 = COL.accent2; OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 13; OpenBtn.Text = "⚡"; OpenBtn.BorderSizePixel = 0
OpenBtn.Parent = ScreenGui; corner(OpenBtn, 26); stroke(OpenBtn, COL.accent2, 2)
MakeDraggable(OpenBtn, OpenBtn)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============================================================
-- FINAL
-- ============================================================
for _, t in pairs(TabScrolls) do
    t.scroll.Visible = false; t.btn.BackgroundColor3 = COL.elem
end
TabScrolls["🎯 Aimbot"].scroll.Visible = true
TabScrolls["🎯 Aimbot"].btn.BackgroundColor3 = COL.accent

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
applyGravityState()

getgenv().TIMON_UNLOAD = function()
    pcall(function() ScreenGui:Destroy() end)
    for p in pairs(ESPObjs) do RemoveESP(p) end
    for p in pairs(ActiveFlingBV) do clearFlingFor(p) end
    ClearAllHitboxes()
    ClearAllNPCHitboxes()
    pcall(function() fovCircle:Remove() end)
    pcall(function() RunService:UnbindFromRenderStep("TIMON_AIM") end)
    if SpinBV then pcall(function() SpinBV:Destroy() end) end
    if DiscoLight then pcall(function() DiscoLight:Destroy() end) end
    if FireEmitter then pcall(function() FireEmitter:Destroy() end) end
    Workspace.Gravity = DEFAULT_GRAVITY
    StickyTarget = nil
    getgenv().TIMON_LOADED = false
end

Notify("⚡ Timon Hub v2.9.2 · Native Joystick Mobile Fly")