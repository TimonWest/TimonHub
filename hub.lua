-- ============================================================================
-- TIMON HUB v4.0 — Jitter + Anti-AFK + ZeroG-Ragdoll + Lazy + FPS Booster
-- language: Lua, file: timonhub.lua, runtime: Roblox Luau (executor)
-- ============================================================================

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
        DistanceWeight = 1.0, WallCheck = false,
        PredictLead = false, BulletSpeed = 1000,
        LeadMultiplier = 1.0, HitscanMode = false,
        TargetNPCs = false,
        -- Jitter
        JitterEnabled = false,
        Jitter = 1.5,
    },
    ESP = {
        Enabled = false,
        OutlineColor = Color3.fromRGB(255, 20, 147),
        FillColor = Color3.fromRGB(180, 60, 255),
        FillTransparency = 0.7, OutlineTransparency = 0,
        ThroughWalls = true,
        ShowName = true, ShowDistance = true,
        NickColor = Color3.fromRGB(255, 255, 255),
        NickSize = 15,
        ShowHPBar = true,
        HPBarWidth = 55,
        HPBarHeight = 5,
        HPDynamicColor = true,
        HPBarColor = Color3.fromRGB(0, 255, 100),
        NPCEnabled = false,
        NPCName = true,
        NPCDistance = false,
        NPCHPBar = true,
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
        InfiniteJump = false, Noclip = false,
        -- New
        AntiAFK = false,
        LazyMode = false,
        FPSBooster = false,
    },
    Troll = {
        Spin = false, Invisible = false,
        AntiFling = false
    },
    Hamster = { Coins = 0 },
    Binds = {}, MobileBtns = {},
    FloatingLock = false, FloatingPos = {},
    AutoSave = true, ConfigName = "auto"
}
getgenv().TIMON_SETTINGS = S

local COL = {
    bg = Color3.fromRGB(18,12,24), bg2 = Color3.fromRGB(28,18,38),
    elem = Color3.fromRGB(52,36,68), elemHover = Color3.fromRGB(72,48,92),
    accent = Color3.fromRGB(180,60,255), accent2 = Color3.fromRGB(255,60,180),
    text = Color3.fromRGB(250,240,255), sub = Color3.fromRGB(200,180,220),
    stroke = Color3.fromRGB(130,80,170), off = Color3.fromRGB(80,68,90),
    green = Color3.fromRGB(120, 255, 160)
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
        Troll = {},
        Hamster = { Coins = S.Hamster.Coins },
        Binds = {}, MobileBtns = {}, AutoSave = S.AutoSave,
        FloatingLock = S.FloatingLock, FloatingPos = S.FloatingPos,
    }
    for k, v in pairs(S.Aimbot) do d.Aimbot[k] = v end
    for k, v in pairs(S.ESP) do
        if k == "OutlineColor" or k == "FillColor"
        or k == "NickColor" or k == "HPBarColor" then
            d.ESP[k] = packC3(v)
        else d.ESP[k] = v end
    end
    for k, v in pairs(S.Hitbox) do
        if k == "Color" then d.Hitbox[k] = packC3(v)
        else d.Hitbox[k] = v end
    end
    for k, v in pairs(S.Player) do d.Player[k] = v end
    for k, v in pairs(S.Troll) do d.Troll[k] = v end
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
        if k == "OutlineColor" or k == "FillColor"
        or k == "NickColor" or k == "HPBarColor" then S.ESP[k] = unpackC3(v)
        elseif S.ESP[k] ~= nil then S.ESP[k] = v end
    end end
    if d.Hitbox then for k,v in pairs(d.Hitbox) do
        if k == "Color" then S.Hitbox[k] = unpackC3(v)
        elseif S.Hitbox[k] ~= nil then S.Hitbox[k] = v end
    end end
    if d.Player then for k,v in pairs(d.Player) do if S.Player[k] ~= nil then S.Player[k]=v end end end
    if d.Troll then for k,v in pairs(d.Troll) do if S.Troll[k] ~= nil then S.Troll[k]=v end end end
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
    if d.FloatingLock ~= nil then S.FloatingLock = d.FloatingLock end
    if d.FloatingPos then S.FloatingPos = d.FloatingPos end
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

local Refreshers = {}
local function AddRefresh(fn) table.insert(Refreshers, fn) end
local function RefreshAll() for _, fn in ipairs(Refreshers) do pcall(fn) end end

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

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = COL.bg2
TitleBar.BackgroundTransparency = 0.05
TitleBar.BorderSizePixel = 0; TitleBar.Parent = Main
corner(TitleBar, 16)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0); TitleLbl.Position = UDim2.new(0,16,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚡ TIMON HUB · v4.0"
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

local XneoGui = nil
local launchXneoFlyGUI, closeXneoFlyGUI
local OpenBtn
-- ============================================================
-- TAB: COMBAT (бывший Aimbot)
-- ============================================================
local A = Tab("🎯 Combat")
Section(A, "🎮 Основное")
Toggle(A, "⚡ Enable Aim",
    function() return S.Aimbot.Enabled end,
    function(v) S.Aimbot.Enabled = v end)
Toggle(A, "🔒 Sticky Lock",
    function() return S.Aimbot.StickyLock end,
    function(v) S.Aimbot.StickyLock = v end)
Toggle(A, "🧱 Wall Check",
    function() return S.Aimbot.WallCheck end,
    function(v) S.Aimbot.WallCheck = v end)
Toggle(A, "🤖 Target NPCs (aim на NPC)",
    function() return S.Aimbot.TargetNPCs end,
    function(v) S.Aimbot.TargetNPCs = v end)
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

Section(A, "📐 FOV")
Slider(A, "📷 Camera FOV", 30, 800,
    function() return S.Aimbot.CameraFOV end,
    function(v) S.Aimbot.CameraFOV = v end)
Slider(A, "📱 Mobile FOV", 30, 800,
    function() return S.Aimbot.MobileFOV end,
    function(v) S.Aimbot.MobileFOV = v end)
Toggle(A, "⭕ Show FOV Circle",
    function() return S.Aimbot.ShowFOV end,
    function(v) S.Aimbot.ShowFOV = v end)

Section(A, "🎯 Target Part")
Dropdown(A, "🎯 Aim Part",
    {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"},
    function() return S.Aimbot.Part end,
    function(v) S.Aimbot.Part = v end)

Section(A, "🧠 Prediction (Lead)")
Toggle(A, "🧠 Predict Lead",
    function() return S.Aimbot.PredictLead end,
    function(v) S.Aimbot.PredictLead = v end)
Toggle(A, "⚡ Hitscan Mode (вырубает prediction)",
    function() return S.Aimbot.HitscanMode end,
    function(v) S.Aimbot.HitscanMode = v end)
Slider(A, "💨 Bullet Speed", 100, 5000,
    function() return S.Aimbot.BulletSpeed end,
    function(v) S.Aimbot.BulletSpeed = math.floor(v + 0.5) end)
Slider(A, "🎯 Lead Multiplier", 0.3, 2.0,
    function() return S.Aimbot.LeadMultiplier end,
    function(v) S.Aimbot.LeadMultiplier = v end)

Section(A, "🎯 Aim Smooth Jitter")
Toggle(A, "🌊 Enable Jitter",
    function() return S.Aimbot.JitterEnabled end,
    function(v) S.Aimbot.JitterEnabled = v end)
Slider(A, "📏 Jitter Amount (px)", 0, 5,
    function() return S.Aimbot.Jitter end,
    function(v) S.Aimbot.Jitter = v end)

-- ============================================================
-- TAB: ESP
-- ============================================================
local E = Tab("👁 ESP")
Section(E, "🔘 Toggle")
Toggle(E, "👁 Enable ESP (Players)",
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

Section(E, "📝 Ники")
Toggle(E, "👤 Show Name",
    function() return S.ESP.ShowName end,
    function(v) S.ESP.ShowName = v end)
ColorPicker(E, "🎨 Nick Color",
    function() return S.ESP.NickColor end,
    function(v) S.ESP.NickColor = v end)
Slider(E, "📏 Nick Size", 10, 24,
    function() return S.ESP.NickSize end,
    function(v) S.ESP.NickSize = math.floor(v + 0.5) end)

Section(E, "❤️ HP Bar")
Toggle(E, "❤️ Show HP Bar",
    function() return S.ESP.ShowHPBar end,
    function(v) S.ESP.ShowHPBar = v end)
Toggle(E, "🌈 Dynamic HP Color",
    function() return S.ESP.HPDynamicColor end,
    function(v) S.ESP.HPDynamicColor = v end)
ColorPicker(E, "🎨 HP Bar Color (static)",
    function() return S.ESP.HPBarColor end,
    function(v) S.ESP.HPBarColor = v end)
Slider(E, "📏 HP Bar Width", 20, 120,
    function() return S.ESP.HPBarWidth end,
    function(v) S.ESP.HPBarWidth = math.floor(v + 0.5) end)
Slider(E, "📏 HP Bar Height", 2, 12,
    function() return S.ESP.HPBarHeight end,
    function(v) S.ESP.HPBarHeight = math.floor(v + 0.5) end)

Section(E, "📏 Дистанция")
Toggle(E, "📏 Show Distance",
    function() return S.ESP.ShowDistance end,
    function(v) S.ESP.ShowDistance = v end)

Section(E, "🤖 NPC ESP")
Toggle(E, "🤖 Enable NPC ESP",
    function() return S.ESP.NPCEnabled end,
    function(v)
        S.ESP.NPCEnabled = v
        if v then
            refreshNPCCache()
            for model in pairs(NPCCache) do
                if not isPlayerCharacter(model) then CreateNPCESP(model) end
            end
        else
            for model in pairs(NPCESPObjs or {}) do RemoveNPCESP(model) end
        end
    end)
Toggle(E, "👤 Show NPC Name",
    function() return S.ESP.NPCName end,
    function(v) S.ESP.NPCName = v end)
Toggle(E, "📏 Show NPC Distance",
    function() return S.ESP.NPCDistance end,
    function(v) S.ESP.NPCDistance = v end)
Toggle(E, "❤️ NPC HP Bar",
    function() return S.ESP.NPCHPBar end,
    function(v) S.ESP.NPCHPBar = v end)

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
Toggle(P, "📱 Mobile Fly (XNEO GUI)",
    function() return XneoGui ~= nil end,
    function(v)
        if v then
            if not XneoGui then launchXneoFlyGUI() end
        else
            if XneoGui then closeXneoFlyGUI() end
        end
    end)
Slider(P, "🚀 Fly Speed (PC)", 10, 300,
    function() return S.Player.FlySpeed end,
    function(v) S.Player.FlySpeed = v end)
Section(P, "🪐 Gravity")
Toggle(P, "🪐 Zero Gravity (левитация в ragdoll)",
    function() return S.Player.ZeroGravity end,
    function(v) S.Player.ZeroGravity = v; applyGravityState() end)
Section(P, "🛠 Utility")
Toggle(P, "🛡 Anti-AFK",
    function() return S.Player.AntiAFK end,
    function(v)
        S.Player.AntiAFK = v
        if v then startAntiAFK() else stopAntiAFK() end
    end)
Toggle(P, "🌙 Lazy Mode (ESP каждый 2-й кадр)",
    function() return S.Player.LazyMode end,
    function(v) S.Player.LazyMode = v end)
Toggle(P, "🚀 FPS Booster (Quality 1 + no shadows)",
    function() return S.Player.FPSBooster end,
    function(v)
        S.Player.FPSBooster = v
        if v then enableFPSBooster() else disableFPSBooster() end
    end)
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

Section(T, "🛡 Anti Fling")
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

-- ============================================================
-- TAB: BINDS
-- ============================================================
local B = Tab("🔗 Binds")
Section(B, "⌨ Key Binds (ПК)")
BindButton(B, "Aimbot", "🎯 Aimbot Toggle")
BindButton(B, "AimbotHold", "🎯 Aim Hold")
BindButton(B, "ESP", "👁 ESP")
BindButton(B, "Hitbox", "📦 Hitbox")
BindButton(B, "Fly", "✈ Fly")
BindButton(B, "Noclip", "👻 Noclip")
BindButton(B, "InfiniteJump", "♾ Infinite Jump")
BindButton(B, "ZeroGravity", "🪐 Zero Gravity")
Button(B, "🗑 Сбросить все бинды", function()
    S.Binds = {}
    for action, fn in pairs(BindRefreshers) do pcall(fn) end
    MarkDirty()
    Notify("🗑 Все бинды сброшены")
end, {textColor = COL.accent2})

Section(B, "📌 Floating Lock")
Toggle(B, "🔒 Fix Floating Buttons",
    function() return S.FloatingLock end,
    function(v)
        S.FloatingLock = v
        ApplyFloatingLock()
        MarkDirty()
        Notify("🔒 Floating: "..(v and "LOCKED" or "FREE"))
    end)
Button(B, "🔄 Сбросить позиции кнопок", function()
    S.FloatingPos = {}
    RepositionAllFloatingBtns()
    MarkDirty()
    Notify("🔄 Позиции сброшены")
end, {textColor = COL.accent2})

Section(B, "📱 Floating Buttons (Mobile)")
Toggle(B, "🎯 Aimbot Button",
    function() return S.MobileBtns.Aimbot == true end,
    function(v) S.MobileBtns.Aimbot = v; ToggleMobileBtn("Aimbot", v) end)
Toggle(B, "✈ Fly Button (PC)",
    function() return S.MobileBtns.Fly == true end,
    function(v) S.MobileBtns.Fly = v; ToggleMobileBtn("Fly", v) end)
Toggle(B, "📱 Mobile Fly (XNEO) Button",
    function() return S.MobileBtns.MobileFly == true end,
    function(v) S.MobileBtns.MobileFly = v; ToggleMobileBtn("MobileFly", v) end)
Toggle(B, "🪐 Zero Gravity Button",
    function() return S.MobileBtns.ZeroGravity == true end,
    function(v) S.MobileBtns.ZeroGravity = v; ToggleMobileBtn("ZeroGravity", v) end)
Toggle(B, "👻 Noclip Button",
    function() return S.MobileBtns.Noclip == true end,
    function(v) S.MobileBtns.Noclip = v; ToggleMobileBtn("Noclip", v) end)
Toggle(B, "🛡 Anti Fling Button",
    function() return S.MobileBtns.AntiFling == true end,
    function(v) S.MobileBtns.AntiFling = v; ToggleMobileBtn("AntiFling", v) end)
Toggle(B, "👁 ESP Button",
    function() return S.MobileBtns.ESP == true end,
    function(v) S.MobileBtns.ESP = v; ToggleMobileBtn("ESP", v) end)
Toggle(B, "📦 Hitbox Button",
    function() return S.MobileBtns.Hitbox == true end,
    function(v) S.MobileBtns.Hitbox = v; ToggleMobileBtn("Hitbox", v) end)

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
    S.Aimbot.DistanceWeight=1; S.Aimbot.WallCheck=false
    S.Aimbot.JitterEnabled=false; S.Aimbot.Jitter=1.5
    S.ESP.Enabled=false; S.ESP.NPCEnabled=false
    S.Hitbox.Enabled=false; S.Hitbox.NPCSupport=false
    S.Player.Fly=false
    if XneoGui then closeXneoFlyGUI() end
    S.Player.Noclip=false; S.Player.InfiniteJump=false
    S.Player.ZeroGravity=false
    S.Player.AntiAFK=false; stopAntiAFK()
    S.Player.FPSBooster=false; disableFPSBooster()
    S.Troll.AntiFling=false
    S.FloatingLock=false
    S.FloatingPos={}
    ApplyFloatingLock(); RepositionAllFloatingBtns()
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
    for m in pairs(NPCESPObjs) do RemoveNPCESP(m) end
    if S.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then CreateESP(p) end
        end
    end
    if S.ESP.NPCEnabled then
        refreshNPCCache()
        for m in pairs(NPCCache) do
            if not isPlayerCharacter(m) then CreateNPCESP(m) end
        end
    end
    ClearAllHitboxes()
    ClearAllNPCHitboxes()
    if S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(ApplyHitbox, pl) end
    end
    if S.Hitbox.NPCSupport then
        refreshNPCCache()
        for model in pairs(NPCCache) do pcall(ApplyNPCHitbox, model) end
    end
    for action, state in pairs(S.MobileBtns) do
        ToggleMobileBtn(action, state)
    end
    RepositionAllFloatingBtns()
    ApplyFloatingLock()
    applyGravityState()
    if S.Player.AntiAFK then startAntiAFK() else stopAntiAFK() end
    if S.Player.FPSBooster then enableFPSBooster() else disableFPSBooster() end
    if S.Player.MobileFly then
        if not XneoGui then launchXneoFlyGUI() end
    else
        if XneoGui then closeXneoFlyGUI() end
    end
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
-- GRAVITY STATE (ZeroG + Ragdoll)
-- ============================================================
local origStateEnabled = nil

function applyGravityState()
    local chr = LP.Character
    local hum = chr and chr:FindFirstChildOfClass("Humanoid")
    if S.Player.ZeroGravity then
        Workspace.Gravity = 0
        if hum then
            -- Ragdoll-подобное состояние: PlatformStanding + Ragdoll разрешён
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Ragdoll) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.PlatformStanding) end)
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        end
    else
        Workspace.Gravity = DEFAULT_GRAVITY
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.Player.ZeroGravity then applyGravityState() end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
local antiAFKConn = nil
local antiAFKThread = nil

function startAntiAFK()
    stopAntiAFK()
    pcall(function()
        if typeof(hookfunction) == "function"
           and typeof(getconnections) == "function" then
            for _, c in ipairs(getconnections(LP.Idled)) do
                if c and typeof(c.Disable) == "function" then c:Disable() end
            end
        end
    end)
    antiAFKThread = task.spawn(function()
        while S.Player.AntiAFK do
            task.wait(60)
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end)
end

function stopAntiAFK()
    if antiAFKThread then
        pcall(function() task.cancel(antiAFKThread) end)
        antiAFKThread = nil
    end
end

-- ============================================================
-- FPS BOOSTER
-- ============================================================
local fpsBackup = nil

function enableFPSBooster()
    if fpsBackup then return end
    fpsBackup = {}
    pcall(function()
        local lighting = game:GetService("Lighting")
        local rs = game:GetService("RenderSettings")
        fpsBackup.Quality = rs.QualityLevel
        rs.QualityLevel = 1
        fpsBackup.GlobalShadows = lighting.GlobalShadows
        lighting.GlobalShadows = false
        fpsBackup.FogEnd = lighting.FogEnd
        lighting.FogEnd = 1e6
        fpsBackup.Technology = lighting.Technology
        fpsBackup.ShadowSoftness = lighting.ShadowSoftness
        lighting.ShadowSoftness = 0
    end)
end

function disableFPSBooster()
    if not fpsBackup then return end
    pcall(function()
        local lighting = game:GetService("Lighting")
        local rs = game:GetService("RenderSettings")
        if fpsBackup.Quality then rs.QualityLevel = fpsBackup.Quality end
        if fpsBackup.GlobalShadows ~= nil then lighting.GlobalShadows = fpsBackup.GlobalShadows end
        if fpsBackup.FogEnd then lighting.FogEnd = fpsBackup.FogEnd end
        if fpsBackup.ShadowSoftness then lighting.ShadowSoftness = fpsBackup.ShadowSoftness end
    end)
    fpsBackup = nil
end

-- ============================================================
-- FLOATING LAYER
-- ============================================================
local AllFloating = {}

local function saveBtnPos(id, pos)
    S.FloatingPos[id] = {
        xS = pos.X.Scale, xO = pos.X.Offset,
        yS = pos.Y.Scale, yO = pos.Y.Offset,
    }
end

local function loadBtnPos(id, defaultPos)
    local p = S.FloatingPos[id]
    if p then
        return UDim2.new(p.xS or 0, p.xO or 0, p.yS or 0, p.yO or 0)
    end
    return defaultPos
end

local function MakeDraggableLockable(frame, dragBar, id, defaultPos)
    local dragging, dragStart, startPos
    dragBar.InputBegan:Connect(function(input)
        if S.FloatingLock then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if S.FloatingLock then dragging = false; return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,
                startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if id then saveBtnPos(id, frame.Position); MarkDirty() end
        end
    end)
    if id then
        AllFloating[id] = {btn = frame, defaultPos = defaultPos or frame.Position}
    end
end

function RepositionAllFloatingBtns()
    for id, entry in pairs(AllFloating) do
        if entry.btn and entry.btn.Parent then
            entry.btn.Position = loadBtnPos(id, entry.defaultPos)
        end
    end
end

function ApplyFloatingLock()
    for _, entry in pairs(AllFloating) do
        local b = entry.btn
        if b and b.Parent then
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then
                if S.FloatingLock then
                    s.Color = COL.green
                else
                    s.Color = COL.accent2
                end
                s.Thickness = 2
            end
        end
    end
end

-- ============================================================
-- AIMBOT — Jitter + Prediction + NPC
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 1
fovCircle.Color = COL.accent; fovCircle.Transparency = 0.7

local StickyTarget = nil
local StickyTargetIsNPC = false
local aimHoldDown = false
local aimHoldAvailable = false
local wasHoldActive = false

local wallCheckRayParams = RaycastParams.new()
wallCheckRayParams.FilterType = Enum.RaycastFilterType.Exclude
wallCheckRayParams.IgnoreWater = true

pcall(function()
    local _ = UIS:IsKeyDown(Enum.KeyCode.LeftShift)
    aimHoldAvailable = true
end)

local function IsCursorAimActive()
    if S.Aimbot.Mode ~= "Cursor" then return true end
    if not S.Binds.AimbotHold then return true end
    if aimHoldAvailable then
        local ok, isDown = pcall(function()
            return UIS:IsKeyDown(S.Aimbot.HoldBind or S.Binds.AimbotHold)
        end)
        if ok then return isDown == true end
    end
    return aimHoldDown
end

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local dist = dir.Magnitude
    if dist < 1 then return true end
    local ignore = {Camera}
    if LP.Character then table.insert(ignore, LP.Character) end
    wallCheckRayParams.FilterDescendantsInstances = ignore
    local res = Workspace:Raycast(origin, dir, wallCheckRayParams)
    if not res then return true end
    local hit = res.Instance
    if hit == part then return true end
    local cur = hit
    while cur do
        if cur == part or cur == part.Parent then return true end
        cur = cur.Parent
    end
    return false
end

local function IsOnScreen(part)
    if not part then return false end
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    return onScreen and sp.Z > 0
end

-- Prediction
local function GetLeadPos(part, origin)
    if not S.Aimbot.PredictLead or S.Aimbot.HitscanMode then
        return part.Position
    end
    local ch = part.Parent
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then return part.Position end

    local md = hum.MoveDirection
    local walkSpeed = hum.WalkSpeed
    local vel = Vector3.new(
        md.X * walkSpeed,
        part.Velocity.Y,
        md.Z * walkSpeed
    )
    -- clamp скорости для защиты от лагов
    if vel.Magnitude > 500 then vel = vel.Unit * 500 end

    local bs = math.max(S.Aimbot.BulletSpeed, 1)
    local mult = S.Aimbot.LeadMultiplier or 1.0
    local aimPos = part.Position
    for i = 1, 3 do
        local t = (aimPos - origin).Magnitude / bs * mult
        aimPos = part.Position + vel * t
    end
    return aimPos
end

-- Валидация игрока (с NPC)
local function IsTargetValid(target, isNPC, requireVisible, requireOnScreen)
    if not target then return false end
    if isNPC then
        if not target.Parent or not target:IsA("Model") then return false end
        local hum = target:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local part = target:FindFirstChild(S.Aimbot.Part) or target:FindFirstChild("Head")
        if not part then return false end
        if requireOnScreen ~= false and not IsOnScreen(part) then return false end
        if requireVisible and not IsVisible(part) then return false end
        return true, part
    else
        local pl = target
        if not pl or pl.Parent ~= Players then return false end
        local ch = pl.Character; if not ch then return false end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        if not part then return false end
        if requireOnScreen ~= false and not IsOnScreen(part) then return false end
        if requireVisible and not IsVisible(part) then return false end
        return true, part
    end
end

local function FindTarget()
    local isCursor = (S.Aimbot.Mode == "Cursor")
    local holdActive = isCursor and S.Binds.AimbotHold and IsCursorAimActive()

    -- Sticky (учитываем и NPC)
    if S.Aimbot.StickyLock and StickyTarget then
        local ok, part = IsTargetValid(StickyTarget, StickyTargetIsNPC, false, true)
        if holdActive and wasHoldActive then
            if ok then return part end
            StickyTarget = nil; StickyTargetIsNPC = false
        elseif isCursor and S.Binds.AimbotHold and not holdActive then
            StickyTarget = nil; StickyTargetIsNPC = false
            return nil
        else
            local ok2, part2 = IsTargetValid(StickyTarget, StickyTargetIsNPC,
                S.Aimbot.WallCheck, true)
            if ok2 then return part2 end
            StickyTarget = nil; StickyTargetIsNPC = false
        end
    end

    local target, targetIsNPC, bestScore = nil, false, math.huge
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

    -- Игроки
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        local ch = pl.Character
        if not ch then continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z <= 0 then continue end
        local pixDist = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
        if pixDist > fovLimit then continue end
        if S.Aimbot.WallCheck and not IsVisible(part) then continue end
        local worldDist = (part.Position - myPos).Magnitude
        local score = pixDist + worldDist * S.Aimbot.DistanceWeight
        if score < bestScore then
            bestScore = score; target = pl; targetIsNPC = false
        end
    end

    -- NPC
    if S.Aimbot.TargetNPCs then
        refreshNPCCache()
        for model in pairs(NPCCache) do
            if not isPlayerCharacter(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = model:FindFirstChild(S.Aimbot.Part) or model:FindFirstChild("Head")
                    if part then
                        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and sp.Z > 0 then
                            local pixDist = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
                            if pixDist <= fovLimit then
                                if not S.Aimbot.WallCheck or IsVisible(part) then
                                    local worldDist = (part.Position - myPos).Magnitude
                                    local score = pixDist + worldDist * S.Aimbot.DistanceWeight
                                    if score < bestScore then
                                        bestScore = score
                                        target = model
                                        targetIsNPC = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if S.Aimbot.StickyLock then
        StickyTarget = target
        StickyTargetIsNPC = targetIsNPC
    end
    if target then
        if targetIsNPC then
            return target:FindFirstChild(S.Aimbot.Part) or target:FindFirstChild("Head")
        else
            local ch = target.Character
            return ch and (ch:FindFirstChild(S.Aimbot.Part) or ch:FindFirstChild("Head")) or nil
        end
    end
    return nil
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

    if not S.Aimbot.Enabled then StickyTarget = nil; wasHoldActive = false; return end
    if not IsCursorAimActive() then wasHoldActive = false; return end

    local t = FindTarget()
    wasHoldActive = true
    if not t then return end

    local aimPos = GetLeadPos(t, Camera.CFrame.Position)

    local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
    if not onScreen or sp.Z <= 0 then return end

    if S.Aimbot.Mode == "Cursor" then
        local mp = UIS:GetMouseLocation()
        local dx = (sp.X - mp.X) * S.Aimbot.Smooth
        local dy = (sp.Y - mp.Y) * S.Aimbot.Smooth
        -- Jitter
        if S.Aimbot.JitterEnabled and S.Aimbot.Jitter > 0 then
            dx += (math.random() * 2 - 1) * S.Aimbot.Jitter
            dy += (math.random() * 2 - 1) * S.Aimbot.Jitter
        end
        if tryMouse(dx, dy) then return end
    end

    local lookCF = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, S.Aimbot.Smooth)
end)

-- ============================================================
-- ESP helpers — Player + NPC
-- ============================================================
ESPObjs = {}
NPCESPObjs = {}
local espCharConn = {}

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
    for _, d in pairs(NPCESPObjs or {}) do
        if d.hl then applyHighlight(d.hl) end
    end
end

local function makeNickText()
    local t = Drawing.new("Text")
    t.Visible = false; t.Center = true; t.Outline = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Size = S.ESP.NickSize or 15
    t.Color = S.ESP.NickColor or Color3.new(1,1,1)
    pcall(function()
        if Drawing.Fonts then t.Font = Drawing.Fonts.System or 1
        else t.Font = 1 end
    end)
    return t
end

local function makeHPBar()
    local bg = Drawing.new("Square")
    bg.Visible = false; bg.Filled = true
    bg.Thickness = 1; bg.Color = Color3.fromRGB(0,0,0)
    bg.Transparency = 0.35
    local fill = Drawing.new("Square")
    fill.Visible = false; fill.Filled = true
    fill.Thickness = 0; fill.Color = Color3.fromRGB(0,255,0)
    fill.Transparency = 1
    return bg, fill
end

local function refreshEspCache(d)
    local c = d.player and d.player.Character
    d.cacheChar = c
    d.cacheHead = c and c:FindFirstChild("Head") or nil
    d.cacheRoot = c and c:FindFirstChild("HumanoidRootPart") or nil
    d.cacheHum  = c and c:FindFirstChildOfClass("Humanoid") or nil
end

function CreateESP(pl)
    if pl == LP or ESPObjs[pl] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TimonHub_HL_" .. pl.Name
    applyHighlight(hl)
    if pl.Character then hl.Adornee = pl.Character end
    hl.Parent = ScreenGui

    local nm = makeNickText()
    local ds = Drawing.new("Text")
    ds.Visible = false; ds.Center = true; ds.Outline = true
    ds.OutlineColor = Color3.fromRGB(0,0,0)
    ds.Size = 12; ds.Color = Color3.fromRGB(230, 230, 230)

    local hpBg, hpFill = makeHPBar()

    local d = {hl = hl, name = nm, dist = ds,
        hpBg = hpBg, hpFill = hpFill, player = pl}
    refreshEspCache(d)
    ESPObjs[pl] = d

    if espCharConn[pl] then
        pcall(function() espCharConn[pl]:Disconnect() end)
    end
    espCharConn[pl] = pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        local e = ESPObjs[pl]
        if not e then return end
        local c = pl.Character
        if c and e.hl then e.hl.Adornee = c; e.hl.Enabled = true end
        refreshEspCache(e)
    end)
    pcall(function()
        pl.CharacterAppearanceLoaded:Connect(function()
            task.wait(0.1)
            local e = ESPObjs[pl]
            if not e then return end
            local c = pl.Character
            if c and e.hl then e.hl.Adornee = c; e.hl.Enabled = true end
            refreshEspCache(e)
        end)
    end)
end

function RemoveESP(pl)
    local e = ESPObjs[pl]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.name:Remove() end)
        pcall(function() e.dist:Remove() end)
        if e.hpBg then pcall(function() e.hpBg:Remove() end) end
        if e.hpFill then pcall(function() e.hpFill:Remove() end) end
        ESPObjs[pl] = nil
    end
    if espCharConn[pl] then
        pcall(function() espCharConn[pl]:Disconnect() end)
        espCharConn[pl] = nil
    end
end

local function refreshNPCEspCache(d)
    local m = d.model
    if not m or not m.Parent then
        d.cacheHead = nil; d.cacheRoot = nil; d.cacheHum = nil
        return
    end
    d.cacheHead = m:FindFirstChild("Head")
    d.cacheRoot = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
    d.cacheHum  = m:FindFirstChildOfClass("Humanoid")
end

function CreateNPCESP(model)
    if not model or NPCESPObjs[model] then return end
    if isPlayerCharacter(model) then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TimonHub_NPC_HL"
    applyHighlight(hl)
    hl.Adornee = model
    hl.Parent = ScreenGui

    local nm = makeNickText()
    local ds = Drawing.new("Text")
    ds.Visible = false; ds.Center = true; ds.Outline = true
    ds.OutlineColor = Color3.fromRGB(0,0,0)
    ds.Size = 12; ds.Color = Color3.fromRGB(230, 230, 230)
    local hpBg, hpFill = makeHPBar()

    local d = {hl = hl, name = nm, dist = ds,
        hpBg = hpBg, hpFill = hpFill, model = model}
    refreshNPCEspCache(d)
    NPCESPObjs[model] = d
end

function RemoveNPCESP(model)
    local e = NPCESPObjs[model]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.name:Remove() end)
        pcall(function() e.dist:Remove() end)
        if e.hpBg then pcall(function() e.hpBg:Remove() end) end
        if e.hpFill then pcall(function() e.hpFill:Remove() end) end
        NPCESPObjs[model] = nil
    end
end

Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        if S.ESP.Enabled then CreateESP(pl) end
    end)
end)
Players.PlayerRemoving:Connect(function(pl)
    RemoveESP(pl)
    RemoveHitboxFor(pl)
end)
-- ============================================================
-- HITBOX (Players)
-- ============================================================
HitboxParts = {}

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
    if not entry then entry = {srcHead = nil, srcTorso = nil}; HitboxParts[pl] = entry end

    if S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = createHitboxPart("Head")
        end
        local head = ch:FindFirstChild("Head")
        if head then
            entry.srcHead = head
            entry.head.Size = Vector3.new(S.Hitbox.HeadSize, S.Hitbox.HeadSize, S.Hitbox.HeadSize)
            entry.head.CFrame = head.CFrame
            entry.head.Color = S.Hitbox.Color
            entry.head.Transparency = S.Hitbox.Transparency
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil; entry.srcHead = nil
    end

    if S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = createHitboxPart("Body")
        end
        local torso = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        if torso then
            entry.srcTorso = torso
            entry.body.Size = Vector3.new(S.Hitbox.BodySize, S.Hitbox.BodySize, S.Hitbox.BodySize)
            entry.body.CFrame = torso.CFrame
            entry.body.Color = S.Hitbox.Color
            entry.body.Transparency = S.Hitbox.Transparency
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil; entry.srcTorso = nil
    end
end

function RemoveHitboxFor(pl)
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
-- NPC HITBOX + NPC CACHE
-- ============================================================
NPCCache = {}
NPCHitboxes = {}

function isPlayerCharacter(model)
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
            entry.srcHead = head
            entry.head.Size = Vector3.new(S.Hitbox.HeadSize, S.Hitbox.HeadSize, S.Hitbox.HeadSize)
            entry.head.CFrame = head.CFrame
            entry.head.Color = S.Hitbox.Color
            entry.head.Transparency = S.Hitbox.Transparency
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil; entry.srcHead = nil
    end

    if S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = createHitboxPart("NPCBody")
        end
        local torso = model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("HumanoidRootPart")
        if torso then
            entry.srcTorso = torso
            entry.body.Size = Vector3.new(S.Hitbox.BodySize, S.Hitbox.BodySize, S.Hitbox.BodySize)
            entry.body.CFrame = torso.CFrame
            entry.body.Color = S.Hitbox.Color
            entry.body.Transparency = S.Hitbox.Transparency
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil; entry.srcTorso = nil
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
            for model in pairs(NPCCache) do pcall(ApplyNPCHitbox, model) end
            for model in pairs(NPCHitboxes) do
                if not model.Parent or not NPCCache[model] then
                    RemoveNPCHitbox(model)
                end
            end
        end
    end
end)

-- NPC ESP scanner
task.spawn(function()
    while task.wait(1) do
        if S.ESP.NPCEnabled then
            refreshNPCCache()
            for model in pairs(NPCCache) do
                if not isPlayerCharacter(model) and not NPCESPObjs[model] then
                    pcall(CreateNPCESP, model)
                end
            end
            for model in pairs(NPCESPObjs) do
                if not model.Parent or not NPCCache[model] then
                    RemoveNPCESP(model)
                end
            end
        end
    end
end)

-- ============================================================
-- XNEO FLY GUI
-- ============================================================
local XneoState = {
    gui = nil, nowe = false, speeds = 1, tpWalking = false,
    bg = nil, bv = nil, flyLoopConn = nil,
}

local XNEO_STATES = {
    Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
    Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
    Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
    Enum.HumanoidStateType.Swimming,
}

local function xneoTurnOffFlight()
    local chr = LP.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    XneoState.nowe = false
    XneoState.tpWalking = false
    if XneoState.flyLoopConn then
        pcall(function() XneoState.flyLoopConn:Disconnect() end)
        XneoState.flyLoopConn = nil
    end
    if XneoState.bg then pcall(function() XneoState.bg:Destroy() end); XneoState.bg = nil end
    if XneoState.bv then pcall(function() XneoState.bv:Destroy() end); XneoState.bv = nil end
    if chr and hum then
        for _, st in ipairs(XNEO_STATES) do
            pcall(function() hum:SetStateEnabled(st, true) end)
        end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        hum.PlatformStand = false
        local animate = chr:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end
end

local function xneoTurnOnFlight()
    local chr = LP.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    if not chr or not hum then return end
    if S.Player.Fly then S.Player.Fly = false; RefreshAll() end

    XneoState.nowe = true
    XneoState.tpWalking = true
    XneoState.flyLoopConn = RunService.Heartbeat:Connect(function()
        if not XneoState.tpWalking then return end
        local c = LP.Character
        local h = c and c:FindFirstChildWhichIsA("Humanoid")
        if not c or not h or h.Health <= 0 then return end
        if h.MoveDirection.Magnitude > 0 then
            c:TranslateBy(h.MoveDirection)
        end
    end)

    local animate = chr:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() track:AdjustSpeed(0) end)
    end
    for _, st in ipairs(XNEO_STATES) do
        pcall(function() hum:SetStateEnabled(st, false) end)
    end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end)

    local part = (hum.RigType == Enum.HumanoidRigType.R6)
        and chr:FindFirstChild("Torso")
        or chr:FindFirstChild("UpperTorso")
    if part then
        local bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = part.CFrame
        bg.Parent = part
        XneoState.bg = bg

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0.1, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = part
        XneoState.bv = bv
    end

    hum.PlatformStand = true
    task.spawn(function()
        while XneoState.nowe do
            task.wait()
            if XneoState.bg then
                pcall(function() XneoState.bg.CFrame = Camera.CFrame end)
            end
        end
    end)
end

function launchXneoFlyGUI()
    if XneoState.gui then return end

    local main = Instance.new("ScreenGui")
    main.Name = "XneoFlyGui"
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false
    main.IgnoreGuiInset = true
    pcall(function() main.Parent = CoreGui end)
    if not main.Parent then main.Parent = LP:WaitForChild("PlayerGui") end
    XneoState.gui = main

    local Frame = Instance.new("Frame")
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
    Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
    Frame.Position = UDim2.new(0.100, 0, 0.379, 0)
    Frame.Size = UDim2.new(0, 190, 0, 57)
    Frame.Active = true
    Frame.Draggable = true
    corner(Frame, 8); stroke(Frame, Color3.fromRGB(103, 221, 213), 2)

    local up = Instance.new("TextButton")
    up.Name = "up"; up.Parent = Frame
    up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "UP"; up.TextColor3 = Color3.fromRGB(0,0,0); up.TextSize = 14
    corner(up, 6)

    local down = Instance.new("TextButton")
    down.Name = "down"; down.Parent = Frame
    down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
    down.Position = UDim2.new(0, 0, 0.491, 0)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "DOWN"; down.TextColor3 = Color3.fromRGB(0,0,0); down.TextSize = 14
    corner(down, 6)

    local onof = Instance.new("TextButton")
    onof.Name = "onof"; onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    onof.Position = UDim2.new(0.702, 0, 0.491, 0)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "fly"; onof.TextColor3 = Color3.fromRGB(0,0,0); onof.TextSize = 14
    corner(onof, 6)

    local title = Instance.new("TextLabel")
    title.Parent = Frame
    title.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
    title.Position = UDim2.new(0.469, 0, 0, 0)
    title.Size = UDim2.new(0, 100, 0, 28)
    title.Font = Enum.Font.SourceSans
    title.Text = "FLY GUI V3"; title.TextColor3 = Color3.fromRGB(0,0,0)
    title.TextScaled = true

    local plus = Instance.new("TextButton")
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
    plus.Position = UDim2.new(0.231, 0, 0, 0)
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"; plus.TextColor3 = Color3.fromRGB(0,0,0); plus.TextScaled = true
    corner(plus, 6)

    local speedLbl = Instance.new("TextLabel")
    speedLbl.Parent = Frame
    speedLbl.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    speedLbl.Position = UDim2.new(0.468, 0, 0.491, 0)
    speedLbl.Size = UDim2.new(0, 44, 0, 28)
    speedLbl.Font = Enum.Font.SourceSans
    speedLbl.Text = tostring(XneoState.speeds); speedLbl.TextColor3 = Color3.fromRGB(0,0,0)
    speedLbl.TextScaled = true

    local mine = Instance.new("TextButton")
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
    mine.Position = UDim2.new(0.231, 0, 0.491, 0)
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"; mine.TextColor3 = Color3.fromRGB(0,0,0); mine.TextScaled = true
    corner(mine, 6)

    local closebutton = Instance.new("TextButton")
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 45, 0, 28)
    closebutton.Text = "X"; closebutton.TextSize = 30
    closebutton.TextColor3 = Color3.fromRGB(0,0,0)
    closebutton.Position = UDim2.new(0, 0, -1, 27)
    corner(closebutton, 6)

    local mini = Instance.new("TextButton")
    mini.Parent = Frame
    mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini.Font = Enum.Font.SourceSans
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Text = "-"; mini.TextSize = 40
    mini.TextColor3 = Color3.fromRGB(0,0,0)
    mini.Position = UDim2.new(0, 44, -1, 27)
    corner(mini, 6)

    local mini2 = Instance.new("TextButton")
    mini2.Parent = Frame
    mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini2.Font = Enum.Font.SourceSans
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Text = "+"; mini2.TextSize = 40
    mini2.TextColor3 = Color3.fromRGB(0,0,0)
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false
    corner(mini2, 6)

    onof.MouseButton1Click:Connect(function()
        if XneoState.nowe then xneoTurnOffFlight() else xneoTurnOnFlight() end
    end)

    local upHeld = false
    up.MouseButton1Down:Connect(function()
        upHeld = true
        task.spawn(function()
            while upHeld do
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
                task.wait()
            end
        end)
    end)
    local function upRel() upHeld = false end
    up.MouseButton1Up:Connect(upRel); up.MouseLeave:Connect(upRel)

    local downHeld = false
    down.MouseButton1Down:Connect(function()
        downHeld = true
        task.spawn(function()
            while downHeld do
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
                task.wait()
            end
        end)
    end)
    local function downRel() downHeld = false end
    down.MouseButton1Up:Connect(downRel); down.MouseLeave:Connect(downRel)

    plus.MouseButton1Click:Connect(function()
        XneoState.speeds = XneoState.speeds + 1
        speedLbl.Text = tostring(XneoState.speeds)
    end)
    mine.MouseButton1Click:Connect(function()
        if XneoState.speeds <= 1 then
            speedLbl.Text = "min 1"; task.wait(1)
            speedLbl.Text = tostring(XneoState.speeds)
        else
            XneoState.speeds = XneoState.speeds - 1
            speedLbl.Text = tostring(XneoState.speeds)
        end
    end)

    closebutton.MouseButton1Click:Connect(function() closeXneoFlyGUI() end)

    mini.MouseButton1Click:Connect(function()
        up.Visible = false; down.Visible = false; onof.Visible = false
        plus.Visible = false; speedLbl.Visible = false; mine.Visible = false
        mini.Visible = false; mini2.Visible = true
        Frame.BackgroundTransparency = 1
        closebutton.Position = UDim2.new(0, 0, -1, 57)
    end)
    mini2.MouseButton1Click:Connect(function()
        up.Visible = true; down.Visible = true; onof.Visible = true
        plus.Visible = true; speedLbl.Visible = true; mine.Visible = true
        mini.Visible = true; mini2.Visible = false
        Frame.BackgroundTransparency = 0
        closebutton.Position = UDim2.new(0, 0, -1, 27)
    end)

    S.Player.MobileFly = true
    RefreshAll(); MarkDirty()
end

function closeXneoFlyGUI()
    xneoTurnOffFlight()
    if XneoState.gui then
        pcall(function() XneoState.gui:Destroy() end)
        XneoState.gui = nil
    end
    XneoState.speeds = 1
    S.Player.MobileFly = false
    RefreshAll(); MarkDirty()
end

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

task.spawn(function()
    while task.wait(0.1) do
        if S.Player.Noclip and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ============================================================
-- ANTI FLING
-- ============================================================
local ANTI_FLING_PARTS = {
    "BodyVelocity","BodyAngularVelocity","BodyGyro","BodyThrust","BodyForce"
}
task.spawn(function()
    while task.wait(0.1) do
        if S.Troll.AntiFling and LP.Character then
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    local skip = XneoState.nowe and (
                        p.Name == "Torso" or p.Name == "UpperTorso"
                    )
                    if not skip then
                        for _, class in ipairs(ANTI_FLING_PARTS) do
                            for _, inst in ipairs(p:GetChildren()) do
                                if inst:IsA(class) then
                                    pcall(function() inst:Destroy() end)
                                end
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
-- HP BAR helper
-- ============================================================
local function drawHPBar(hpBg, hpFill, vpPos, maxHP, curHP, barW, barH)
    if not vpPos then
        hpBg.Visible = false; hpFill.Visible = false; return
    end
    local x = vpPos.X - barW/2
    local y = vpPos.Y
    hpBg.Position = Vector2.new(x, y); hpBg.Size = Vector2.new(barW, barH)
    hpBg.Visible = true
    local pct = math.clamp(curHP / math.max(maxHP, 1), 0, 1)
    hpFill.Position = Vector2.new(x + 1, y + 1)
    hpFill.Size = Vector2.new(math.max(0, (barW - 2) * pct), math.max(1, barH - 2))
    if S.ESP.HPDynamicColor then
        hpFill.Color = Color3.fromHSV((1/3) * pct, 1, 1)
    else
        hpFill.Color = S.ESP.HPBarColor
    end
    hpFill.Visible = true
end

-- ============================================================
-- RENDER LOOP — PC Fly + Hitbox sync + ESP (Lazy Mode)
-- ============================================================
local FlyBV, FlyBG
local SpinBV
local effectAccum = 0
local EFFECT_INTERVAL = 1/30
local lazyFrame = 0

RunService.RenderStepped:Connect(function(dt)
    local ch = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")

    -- PC Fly
    if S.Player.Fly and not XneoState.nowe and hrp then
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
    elseif FlyBV then
        FlyBV:Destroy(); FlyBV = nil
        if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    end

    -- Hitbox sync (каждый кадр — критично)
    if S.Hitbox.Enabled then
        for _, e in pairs(HitboxParts) do
            if e.head and e.srcHead and e.srcHead.Parent then
                e.head.CFrame = e.srcHead.CFrame
            end
            if e.body and e.srcTorso and e.srcTorso.Parent then
                e.body.CFrame = e.srcTorso.CFrame
            end
        end
    end
    if S.Hitbox.NPCSupport then
        for _, e in pairs(NPCHitboxes) do
            if e.head and e.srcHead and e.srcHead.Parent then
                e.head.CFrame = e.srcHead.CFrame
            end
            if e.body and e.srcTorso and e.srcTorso.Parent then
                e.body.CFrame = e.srcTorso.CFrame
            end
        end
    end

    -- Lazy Mode: пропускаем ESP update каждый 2-й кадр
    lazyFrame = lazyFrame + 1
    local skipESP = S.Player.LazyMode and (lazyFrame % 2 == 0)

    if not skipESP then
        -- ESP PLAYER
        if S.ESP.Enabled then
            for _, d in pairs(ESPObjs) do
                local c = d.player.Character
                if c ~= d.cacheChar then
                    refreshEspCache(d)
                    if d.hl and c then d.hl.Adornee = c end
                end
                if not c or not d.cacheHead or not d.cacheRoot then
                    d.name.Visible = false; d.dist.Visible = false
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                    if d.hl then d.hl.Enabled = false end
                    if c then refreshEspCache(d) end
                    continue
                end
                if d.hl then
                    d.hl.Enabled = true
                    if d.hl.Adornee ~= c then d.hl.Adornee = c end
                end
                local top = Camera:WorldToViewportPoint(d.cacheHead.Position + Vector3.new(0, 1, 0))
                if top.Z <= 0 then
                    d.name.Visible = false; d.dist.Visible = false
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                    continue
                end
                if S.ESP.ShowName then
                    d.name.Text = d.player.Name
                    d.name.Size = S.ESP.NickSize
                    d.name.Color = S.ESP.NickColor
                    d.name.Position = Vector2.new(top.X, top.Y - 24)
                    d.name.Visible = true
                else d.name.Visible = false end
                if S.ESP.ShowHPBar and d.cacheHum then
                    drawHPBar(d.hpBg, d.hpFill,
                        Vector2.new(top.X, top.Y - 34 - S.ESP.HPBarHeight),
                        d.cacheHum.MaxHealth, d.cacheHum.Health,
                        S.ESP.HPBarWidth, S.ESP.HPBarHeight)
                else
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                end
                if S.ESP.ShowDistance then
                    local dist = math.floor((Camera.CFrame.Position - d.cacheRoot.Position).Magnitude)
                    d.dist.Text = dist .. "m"
                    d.dist.Position = Vector2.new(top.X, top.Y - 6)
                    d.dist.Visible = true
                else d.dist.Visible = false end
            end
        end

        -- ESP NPC
        if S.ESP.NPCEnabled then
            for model, d in pairs(NPCESPObjs) do
                if not model.Parent then
                    d.name.Visible = false; d.dist.Visible = false
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                    if d.hl then d.hl.Enabled = false end
                    continue
                end
                if not d.cacheHead or not d.cacheHead.Parent then
                    refreshNPCEspCache(d)
                end
                if not d.cacheHead or not d.cacheRoot then
                    d.name.Visible = false; d.dist.Visible = false
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                    if d.hl then d.hl.Enabled = false end
                    continue
                end
                if d.hl then
                    d.hl.Enabled = true
                    if d.hl.Adornee ~= model then d.hl.Adornee = model end
                end
                local top = Camera:WorldToViewportPoint(d.cacheHead.Position + Vector3.new(0, 1, 0))
                if top.Z <= 0 then
                    d.name.Visible = false; d.dist.Visible = false
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                    continue
                end
                if S.ESP.NPCName then
                    d.name.Text = model.Name
                    d.name.Size = S.ESP.NickSize
                    d.name.Color = S.ESP.NickColor
                    d.name.Position = Vector2.new(top.X, top.Y - 24)
                    d.name.Visible = true
                else d.name.Visible = false end
                if S.ESP.NPCHPBar and d.cacheHum then
                    drawHPBar(d.hpBg, d.hpFill,
                        Vector2.new(top.X, top.Y - 34 - S.ESP.HPBarHeight),
                        d.cacheHum.MaxHealth, d.cacheHum.Health,
                        S.ESP.HPBarWidth, S.ESP.HPBarHeight)
                else
                    d.hpBg.Visible = false; d.hpFill.Visible = false
                end
                if S.ESP.NPCDistance then
                    local dist = math.floor((Camera.CFrame.Position - d.cacheRoot.Position).Magnitude)
                    d.dist.Text = dist .. "m"
                    d.dist.Position = Vector2.new(top.X, top.Y - 6)
                    d.dist.Visible = true
                else d.dist.Visible = false end
            end
        end
    end

    -- Throttled troll-эффекты (30 fps)
    effectAccum = effectAccum + dt
    if effectAccum < EFFECT_INTERVAL then return end
    effectAccum = 0

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

    if S.Troll.Invisible and ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = 1
            elseif p:IsA("Decal") then p.Transparency = 1 end
        end
    end
end)

-- ============================================================
-- ACTIONS
-- ============================================================
local Actions = {}
Actions.Aimbot = function()
    S.Aimbot.Enabled = not S.Aimbot.Enabled; RefreshAll(); MarkDirty()
    if not S.Aimbot.Enabled then StickyTarget = nil; wasHoldActive = false end
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
    if not S.Player.Fly and XneoState.nowe then closeXneoFlyGUI() end
    S.Player.Fly = not S.Player.Fly; RefreshAll(); MarkDirty()
    Notify("✈ Fly: "..tostring(S.Player.Fly))
end
Actions.MobileFly = function()
    if XneoState.gui then closeXneoFlyGUI(); Notify("📱 XNEO: OFF")
    else launchXneoFlyGUI(); Notify("📱 XNEO: ON") end
end
Actions.ZeroGravity = function()
    S.Player.ZeroGravity = not S.Player.ZeroGravity
    applyGravityState(); RefreshAll(); MarkDirty()
    Notify("🪐 ZeroG+Ragdoll: "..tostring(S.Player.ZeroGravity))
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
Actions.AntiFling = function()
    S.Troll.AntiFling = not S.Troll.AntiFling; RefreshAll(); MarkDirty()
    Notify("🛡 AntiFling: "..tostring(S.Troll.AntiFling))
end

-- ============================================================
-- INPUT
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

    if S.Binds.AimbotHold and input.KeyCode == S.Binds.AimbotHold then
        aimHoldDown = true
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftAlt and not gp then
        Main.Visible = not Main.Visible; return
    end
    if gp then return end

    for action, key in pairs(S.Binds) do
        if action ~= "AimbotHold" and input.KeyCode == key and Actions[action] then
            Actions[action]()
        end
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if S.Binds.AimbotHold and input.KeyCode == S.Binds.AimbotHold then
        aimHoldDown = false
    end
end)

-- ============================================================
-- MOBILE FLOATING BUTTONS
-- ============================================================
local MobileButtons = {}
local MOBILE_POS_INDEX = 0

function ToggleMobileBtn(action, show)
    if MobileButtons[action] then
        if AllFloating[action] then AllFloating[action] = nil end
        MobileButtons[action]:Destroy(); MobileButtons[action] = nil
        MOBILE_POS_INDEX = math.max(0, MOBILE_POS_INDEX - 1)
    end
    if not show then return end
    MOBILE_POS_INDEX = MOBILE_POS_INDEX + 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,58,0,58)
    local defaultPos = UDim2.new(0, 20, 0, 120 + (MOBILE_POS_INDEX - 1) * 68)
    b.Position = loadBtnPos(action, defaultPos)
    b.BackgroundColor3 = COL.bg2; b.BackgroundTransparency = 0.1
    b.TextColor3 = COL.accent2; b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    local LABEL = {
        Aimbot = "AIM", Fly = "FLY", MobileFly = "XNEO",
        ZeroGravity = "GRAV", Noclip = "NOCLIP",
        AntiFling = "AFLNG", InfiniteJump = "IJMP",
        ESP = "ESP", Hitbox = "HITBX"
    }
    b.Text = LABEL[action] or action
    b.BorderSizePixel = 0
    b.Parent = ScreenGui; corner(b, 29)
    local s = stroke(b, COL.accent2, 2)
    if S.FloatingLock then s.Color = COL.green end
    MakeDraggableLockable(b, b, action, defaultPos)
    local function activeState()
        if action == "Aimbot" then return S.Aimbot.Enabled
        elseif action == "ESP" then return S.ESP.Enabled
        elseif action == "Hitbox" then return S.Hitbox.Enabled
        elseif action == "Fly" then return S.Player.Fly
        elseif action == "MobileFly" then return XneoState.gui ~= nil
        elseif action == "ZeroGravity" then return S.Player.ZeroGravity
        elseif action == "Noclip" then return S.Player.Noclip
        elseif action == "InfiniteJump" then return S.Player.InfiniteJump
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
    paint(); AddRefresh(paint)
    b.MouseButton1Click:Connect(function()
        if Actions[action] then Actions[action]() end
        paint()
    end)
    MobileButtons[action] = b
end

OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,52,0,52)
local openDefault = UDim2.new(0,20,1,-80)
OpenBtn.Position = loadBtnPos("__OpenBtn", openDefault)
OpenBtn.BackgroundColor3 = COL.bg2; OpenBtn.BackgroundTransparency = 0.1
OpenBtn.TextColor3 = COL.accent2; OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 13; OpenBtn.Text = "⚡"; OpenBtn.BorderSizePixel = 0
OpenBtn.Parent = ScreenGui; corner(OpenBtn, 26)
stroke(OpenBtn, COL.accent2, 2)
MakeDraggableLockable(OpenBtn, OpenBtn, "__OpenBtn", openDefault)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============================================================
-- FINAL
-- ============================================================
for _, t in pairs(TabScrolls) do
    t.scroll.Visible = false; t.btn.BackgroundColor3 = COL.elem
end
TabScrolls["🎯 Combat"].scroll.Visible = true
TabScrolls["🎯 Combat"].btn.BackgroundColor3 = COL.accent

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
if S.ESP.NPCEnabled then
    refreshNPCCache()
    for m in pairs(NPCCache) do
        if not isPlayerCharacter(m) then pcall(CreateNPCESP, m) end
    end
end
for action, state in pairs(S.MobileBtns) do
    if state then ToggleMobileBtn(action, true) end
end
applyGravityState()
ApplyFloatingLock()
RepositionAllFloatingBtns()
if S.Player.AntiAFK then startAntiAFK() end
if S.Player.FPSBooster then enableFPSBooster() end

getgenv().TIMON_UNLOAD = function()
    pcall(function() closeXneoFlyGUI() end)
    pcall(function() stopAntiAFK() end)
    pcall(function() disableFPSBooster() end)
    pcall(function() ScreenGui:Destroy() end)
    for p in pairs(ESPObjs) do RemoveESP(p) end
    for m in pairs(NPCESPObjs) do RemoveNPCESP(m) end
    for pl, conn in pairs(espCharConn) do
        pcall(function() conn:Disconnect() end)
    end
    espCharConn = {}
    ClearAllHitboxes()
    ClearAllNPCHitboxes()
    pcall(function() fovCircle:Remove() end)
    pcall(function() RunService:UnbindFromRenderStep("TIMON_AIM") end)
    if SpinBV then pcall(function() SpinBV:Destroy() end) end
    if FlyBV then pcall(function() FlyBV:Destroy() end) end
    if FlyBG then pcall(function() FlyBG:Destroy() end) end
    Workspace.Gravity = DEFAULT_GRAVITY
    StickyTarget = nil; StickyTargetIsNPC = false
    aimHoldDown = false; wasHoldActive = false
    getgenv().TIMON_LOADED = false
end

Notify("⚡ Timon Hub v4.0 · Loaded!")