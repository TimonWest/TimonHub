-- ============================================================================
-- TIMON HUB v4.6.0 — rebuild: polished UI, mobile-adaptive, LL namespace
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
local Lighting    = game:GetService("Lighting")
local Settings    = game:GetService("Settings")
local StarterGui  = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
if not Camera then
    repeat task.wait() until Workspace.CurrentCamera
    Camera = Workspace.CurrentCamera
end
local DEFAULT_GRAVITY = Workspace.Gravity
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

local CONNS = {}
local THREADS = {}

-- ЕДИНЫЙ NAMESPACE
local LL = {}
LL.CONNS = CONNS
LL.THREADS = THREADS
LL.S = nil
LL.ScreenGui = nil
LL.Main = nil
LL.UIScale = nil

function LL.trackConn(c)
    CONNS[#CONNS+1] = c
    return c
end
function LL.trackThread(t)
    THREADS[#THREADS+1] = t
    return t
end

getgenv().TIMON_LOADED = true

LL.S = {
    Aimbot = {
        Enabled=false, Mode="Camera", Smooth=0.25,
        CameraFOV=200, MobileFOV=200,
        Part="Head", ShowFOV=true, StickyLock=true,
        DistanceWeight=1.0, WallCheck=false,
        PredictLead=false, BulletSpeed=1000,
        LeadMultiplier=1.0, HitscanMode=false,
        TargetPlayers=true, TargetNPCs=false,
        JitterEnabled=false, Jitter=1.5,
        HitboxVisualizer=false, AimAssistBeam=false,
        MicroAdjust=false, MicroAdjustAmount=1.0,
        FOVColor = Color3.fromRGB(155,90,255),
        TracerColor = Color3.fromRGB(255,90,190),
    },
    ESP = {
        Enabled=false,
        OutlineColor=Color3.fromRGB(180,100,255),
        FillColor=Color3.fromRGB(120,60,220),
        FillTransparency=0.75, OutlineTransparency=0.05,
        ThroughWalls=true,
        ShowName=true, ShowDistance=true,
        NickColor=Color3.fromRGB(245,235,255), NickSize=15,
        ShowHPBar=true, HPBarWidth=55, HPBarHeight=5,
        HPDynamicColor=true,
        HPBarColor=Color3.fromRGB(110,255,170),
        NPCEnabled=false, NPCName=true, NPCDistance=false, NPCHPBar=true,
        PowerMode=true, MaxDistance=1500,
        TracerEnabled=false,
        TracerFrom=Color3.fromRGB(180,100,255),
        TracerTo=Color3.fromRGB(255,90,190),
    },
    Hitbox = {
        Enabled=false, HeadEnabled=true, BodyEnabled=true,
        HeadSize=3, BodySize=5,
        Transparency=0.7, Color=Color3.fromRGB(160,120,200),
        NPCSupport=false
    },
    Player = {
        Fly=false, MobileFly=false, FlySpeed=50,
        ZeroGravity=false,
        WalkSpeed=16, JumpPower=50,
        WalkSpeedEnabled=true, JumpPowerEnabled=true,
        OrigWalkSpeed=nil, OrigJumpPower=nil,
        InfiniteJump=false, Noclip=false,
        AntiAFK=false, LazyMode=false,
        FPSBooster=false, LowQuality=false, Fullbright=false,
        SavedPos=nil,
    },
    Troll = { Spin=false, Invisible=false, AntiFling=false },
    Hamster = { Coins=0 },
    Binds = {}, MobileBtns = {},
    FloatingLock=false, FloatingPos={},
    AutoSave=true, ConfigName="auto",
    UI = {
        Notifications = true,
        AutoHideOnMobile = true,
        GuiKeybind = Enum.KeyCode.LeftAlt,
        AnimationSpeed = 0.18,
    },
}
local S = LL.S
getgenv().TIMON_SETTINGS = S

LL.Xneo = {
    gui=nil, nowe=false, speeds=1, tpWalking=false,
    tpGen=0, bg=nil, bv=nil, flyLoopConn=nil,
}
local XneoState = LL.Xneo

LL.XNEO_STATES = {
    Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
    Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
    Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
}

-- ============================================================
-- STATE TABLES
-- ============================================================
LL.NPCCache = {}
LL.NPCHitboxes = {}
LL.NPCESPObjs = {}
LL.ESPObjs = {}
LL.HitboxParts = {}
LL.espCharConn = {}
LL.AllFloating = {}
LL.MobileButtons = {}
LL.MOBILE_POS_INDEX = 0
LL.Actions = {}
LL.Refreshers = {}
LL.BindRefreshers = {}
LL.TabScrolls = {}
LL.TabOrder = {}
LL.CurrentTab = nil

-- character cache
LL.Cache = {
    Character = nil,
    Humanoid = nil,
    HRP = nil,
    Camera = Camera,
    Viewport = Camera.ViewportSize,
}
-- ============================================================
-- PALETTE
-- ============================================================
LL.COL = {
    bg=Color3.fromRGB(14,12,20), bg2=Color3.fromRGB(22,18,32),
    panel=Color3.fromRGB(30,26,42), elem=Color3.fromRGB(42,36,58),
    elemHover=Color3.fromRGB(58,50,78), elemPress=Color3.fromRGB(34,28,48),
    accent=Color3.fromRGB(155,90,255), accent2=Color3.fromRGB(255,90,190),
    mint=Color3.fromRGB(120,240,200),
    text=Color3.fromRGB(245,240,255), sub=Color3.fromRGB(160,150,185),
    stroke=Color3.fromRGB(90,70,130), strokeBright=Color3.fromRGB(140,110,190),
    off=Color3.fromRGB(70,62,82),
    green=Color3.fromRGB(130,255,170), red=Color3.fromRGB(255,90,120),
}
local COL = LL.COL

-- ============================================================
-- ANIMATION PRESETS
-- ============================================================
LL.Anim = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- ============================================================
-- HELPERS
-- ============================================================
function LL.corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = o
    return c
end
function LL.stroke(o, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or COL.stroke
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end
function LL.gradient(o, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    if rot then g.Rotation = rot end
    g.Parent = o
    return g
end
function LL.padding(o, t, l, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = o
    return p
end
function LL.makeShadow(parent, radius, transparency)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.Position = UDim2.new(0.5, 0, 0.5, 3)
    s.Size = UDim2.new(1, 14, 1, 14)
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://1316045217"
    s.ImageColor3 = Color3.new(0, 0, 0)
    s.ImageTransparency = transparency or 0.7
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(10, 10, 118, 118)
    s.ZIndex = 0
    s.Parent = parent
    LL.corner(s, radius or 12)
    return s
end

LL.Refreshers = LL.Refreshers
function LL.AddRefresh(fn) table.insert(LL.Refreshers, fn) end
function LL.RefreshAll()
    for _, fn in ipairs(LL.Refreshers) do
        local ok = pcall(fn)
    end
end

LL.ORDER = 0
function LL.NextOrder() LL.ORDER = LL.ORDER + 1; return LL.ORDER end

-- ============================================================
-- CONFIG (async save)
-- ============================================================
LL.CONFIG_DIR = "TimonHub"
LL.AUTOSAVE_FILE = "autosave"
LL.CONFIG_DIRTY = false
LL.lastDirtyTime = 0

function LL.MarkDirty()
    LL.CONFIG_DIRTY = true
    LL.lastDirtyTime = tick()
end

function LL.ensureDir()
    pcall(function()
        if not isfolder(LL.CONFIG_DIR) then makefolder(LL.CONFIG_DIR) end
    end)
end
function LL.fileExists(p)
    local ok, r = pcall(function() return isfile(p) end)
    return ok and r
end
function LL.packC3(c)
    return {math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)}
end
function LL.unpackC3(t)
    return Color3.fromRGB(t[1] or 128, t[2] or 128, t[3] or 128)
end
local unpackFn = table.unpack or unpack

function LL.packSettings()
    local S = LL.S
    local d = {
        Aimbot={}, ESP={}, Hitbox={}, Player={}, Troll={},
        Hamster={Coins=S.Hamster.Coins}, Binds={}, MobileBtns={},
        AutoSave=S.AutoSave, FloatingLock=S.FloatingLock,
        FloatingPos=S.FloatingPos, ConfigName=S.ConfigName,
        UI={},
    }
    for k,v in pairs(S.Aimbot) do
        if type(v)=="Color3" then d.Aimbot[k]=LL.packC3(v) else d.Aimbot[k]=v end
    end
    for k,v in pairs(S.ESP) do
        if type(v)=="Color3" then d.ESP[k]=LL.packC3(v) else d.ESP[k]=v end
    end
    for k,v in pairs(S.Hitbox) do
        if type(v)=="Color3" then d.Hitbox[k]=LL.packC3(v) else d.Hitbox[k]=v end
    end
    for k,v in pairs(S.Player) do
        if k=="SavedPos" then
            if v then d.Player[k]={v:GetComponents()} end
        else d.Player[k]=v end
    end
    for k,v in pairs(S.Troll) do d.Troll[k]=v end
    for a,k in pairs(S.Binds) do
        if typeof(k)=="EnumItem" then
            d.Binds[a]=tostring(k):gsub("Enum.KeyCode.","")
        end
    end
    for k,v in pairs(S.MobileBtns) do d.MobileBtns[k]=v end
    for k,v in pairs(S.UI) do
        if typeof(v)=="EnumItem" then d.UI[k]=tostring(v):gsub("Enum.KeyCode.","")
        else d.UI[k]=v end
    end
    return d
end

function LL.applySettings(d)
    if not d then return end
    local S = LL.S
    if d.Aimbot then
        for k,v in pairs(d.Aimbot) do
            if S.Aimbot[k]~=nil then
                if type(S.Aimbot[k])=="Color3" and type(v)=="table" then
                    S.Aimbot[k]=LL.unpackC3(v)
                else S.Aimbot[k]=v end
            end
        end
    end
    if d.ESP then
        for k,v in pairs(d.ESP) do
            if S.ESP[k]~=nil then
                if type(S.ESP[k])=="Color3" and type(v)=="table" then
                    S.ESP[k]=LL.unpackC3(v)
                else S.ESP[k]=v end
            end
        end
    end
    if d.Hitbox then
        for k,v in pairs(d.Hitbox) do
            if S.Hitbox[k]~=nil then
                if type(S.Hitbox[k])=="Color3" and type(v)=="table" then
                    S.Hitbox[k]=LL.unpackC3(v)
                else S.Hitbox[k]=v end
            end
        end
    end
    if d.Player then
        for k,v in pairs(d.Player) do
            if k=="SavedPos" and type(v)=="table" and #v>=12 then
                local ok, cf = pcall(function() return CFrame.new(unpackFn(v)) end)
                if ok then S.Player.SavedPos=cf end
            elseif S.Player[k]~=nil then
                S.Player[k]=v
            end
        end
    end
    if d.Troll then
        for k,v in pairs(d.Troll) do
            if S.Troll[k]~=nil then S.Troll[k]=v end
        end
    end
    if d.Hamster and d.Hamster.Coins then S.Hamster.Coins=d.Hamster.Coins end
    S.Binds = {}
    if d.Binds then
        for a,n in pairs(d.Binds) do
            local ok, code = pcall(function() return Enum.KeyCode[n] end)
            if ok and code then S.Binds[a]=code end
        end
    end
    if d.MobileBtns then
        S.MobileBtns = {}
        for k,v in pairs(d.MobileBtns) do S.MobileBtns[k]=v end
    end
    if d.AutoSave~=nil then S.AutoSave=d.AutoSave end
    if d.FloatingLock~=nil then S.FloatingLock=d.FloatingLock end
    if d.FloatingPos then S.FloatingPos=d.FloatingPos end
    if d.ConfigName then S.ConfigName=d.ConfigName end
    if d.UI then
        for k,v in pairs(d.UI) do
            if k=="GuiKeybind" and type(v)=="string" then
                local ok, code = pcall(function() return Enum.KeyCode[v] end)
                if ok and code then S.UI.GuiKeybind=code end
            elseif S.UI[k]~=nil then
                S.UI[k]=v
            end
        end
    end
end

function LL.saveConfig(name)
    LL.ensureDir()
    name = name or LL.AUTOSAVE_FILE
    return pcall(function()
        writefile(LL.CONFIG_DIR.."/"..name..".json", HttpService:JSONEncode(LL.packSettings()))
    end)
end
function LL.loadConfigFile(name)
    name = name or LL.AUTOSAVE_FILE
    local path = LL.CONFIG_DIR.."/"..name..".json"
    if not LL.fileExists(path) then return false end
    local ok, c = pcall(function() return readfile(path) end)
    if not ok or not c then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(c) end)
    if not ok2 or not data then return false end
    LL.applySettings(data)
    return true
end
function LL.deleteConfig(name)
    pcall(function() delfile(LL.CONFIG_DIR.."/"..name..".json") end)
end
function LL.listConfigs()
    local out = {}
    pcall(function()
        if not isfolder(LL.CONFIG_DIR) then return end
        for _, file in ipairs(listfiles(LL.CONFIG_DIR)) do
            local n = file:match("([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
    end)
    return out
end

LL.ensureDir()
if LL.fileExists(LL.CONFIG_DIR.."/"..LL.AUTOSAVE_FILE..".json") then
    pcall(function() LL.loadConfigFile(LL.AUTOSAVE_FILE) end)
end
-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TimonHub_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end
LL.ScreenGui = ScreenGui

-- ============================================================
-- NOTIFY QUEUE (throttled)
-- ============================================================
LL.NotifyQueue = {}
LL.NotifyActive = 0
LL.NOTIFY_MAX = 3
LL.NOTIFY_COOLDOWN = 0.08
LL.lastNotifyTime = 0

function LL.processNotifyQueue()
    while LL.NotifyActive < LL.NOTIFY_MAX and #LL.NotifyQueue > 0 do
        local txt = table.remove(LL.NotifyQueue, 1)
        LL.NotifyActive = LL.NotifyActive + 1
        LL.trackThread(task.spawn(function()
            if not getgenv().TIMON_LOADED then
                LL.NotifyActive = LL.NotifyActive - 1
                return
            end
            local n = Instance.new("Frame")
            n.Size = UDim2.new(0, 270, 0, 48)
            n.Position = UDim2.new(1, -290, 1, -90)
            n.BackgroundColor3 = COL.bg2
            n.BackgroundTransparency = 0.02
            n.BorderSizePixel = 0
            n.Parent = ScreenGui
            LL.corner(n, 14)
            LL.stroke(n, COL.accent, 1.5)
            LL.gradient(n, COL.accent, COL.accent2, 20)
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, 4, 1, -14)
            bar.Position = UDim2.new(0, 8, 0, 7)
            bar.BackgroundColor3 = Color3.new(1,1,1)
            bar.BorderSizePixel = 0
            bar.BackgroundTransparency = 0.55
            bar.Parent = n
            LL.corner(bar, 2)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -24, 1, 0)
            l.Position = UDim2.new(0, 22, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = txt
            l.TextColor3 = COL.text
            l.Font = Enum.Font.GothamBold
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = n
            Tween:Create(n, LL.Anim.Normal,
                {Position = UDim2.new(1, -290, 1, -110)}):Play()
            task.wait(2.4)
            if not getgenv().TIMON_LOADED or not n.Parent then
                LL.NotifyActive = LL.NotifyActive - 1
                return
            end
            Tween:Create(n, LL.Anim.Slow,
                {Position = UDim2.new(1, -290, 1, -50), BackgroundTransparency = 1}):Play()
            Tween:Create(l, LL.Anim.Slow, {TextTransparency = 1}):Play()
            task.wait(0.35)
            if n.Parent then n:Destroy() end
            LL.NotifyActive = LL.NotifyActive - 1
        end))
    end
end

function LL.Notify(txt)
    if not LL.S.UI.Notifications then return end
    local now = tick()
    if now - LL.lastNotifyTime < LL.NOTIFY_COOLDOWN then
        if #LL.NotifyQueue >= 8 then table.remove(LL.NotifyQueue, 1) end
        table.insert(LL.NotifyQueue, txt)
        return
    end
    LL.lastNotifyTime = now
    table.insert(LL.NotifyQueue, txt)
    LL.processNotifyQueue()
end

-- ============================================================
-- SECTION (внутри скролла)
-- ============================================================
function LL.Section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "› " .. text
    l.TextColor3 = COL.mint
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -3)
    line.BackgroundColor3 = COL.stroke
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 0.4
    line.Parent = f
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
LL.corner(Main, 18)
LL.stroke(Main, COL.accent, 1.2)
LL.Main = Main
LL.makeShadow(Main, 20, 0.75)

local UIScale = Instance.new("UIScale")
UIScale.Parent = Main
LL.UIScale = UIScale

function LL.ApplyMainSize()
    local vp = Camera.ViewportSize
    local baseW, baseH, scale
    if IS_MOBILE then
        baseW, baseH, scale = 600, 460, 0.78
    else
        baseW, baseH, scale = 760, 540, 1.0
    end
    local maxW = vp.X * (IS_MOBILE and 0.96 or 0.85)
    local maxH = vp.Y * (IS_MOBILE and 0.88 or 0.85)
    local finalW = math.min(baseW, maxW / scale)
    local finalH = math.min(baseH, maxH / scale)
    local oldPos = Main.Position
    Main.Size = UDim2.new(0, finalW, 0, finalH)
    if oldPos.X.Offset == 0 and oldPos.Y.Offset == 0 and oldPos.X.Scale == 0.5 then
        Main.Position = UDim2.new(0.5, -finalW * scale / 2, 0.5, -finalH * scale / 2)
    end
    UIScale.Scale = scale
end

LL.ApplyMainSize()
LL.trackConn(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    LL.Cache.Viewport = Camera.ViewportSize
    LL.ApplyMainSize()
end))

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = COL.bg2
TitleBar.BackgroundTransparency = 0.02
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
LL.corner(TitleBar, 18)
LL.gradient(TitleBar, COL.accent, COL.accent2, 25)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -110, 1, 0)
TitleLbl.Position = UDim2.new(0, 20, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "TIMON HUB  ·  v4.6.0"
TitleLbl.TextColor3 = Color3.new(1, 1, 1)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 16
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = COL.red
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
LL.corner(CloseBtn, 10)
CloseBtn.MouseEnter:Connect(function()
    Tween:Create(CloseBtn, LL.Anim.Fast, {BackgroundColor3 = Color3.fromRGB(255,120,150)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    Tween:Create(CloseBtn, LL.Anim.Fast, {BackgroundColor3 = COL.red}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- ============================================================
-- DRAGGABLE (учитывает UIScale)
-- ============================================================
function LL.MakeDraggable(frame, dragBar)
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
    LL.trackConn(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local sc = UIScale.Scale > 0 and UIScale.Scale or 1
            local d = (input.Position - dragStart) / sc
            frame.Position = UDim2.new(startPos.X.Scale,
                startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end
LL.MakeDraggable(Main, TitleBar)

-- ============================================================
-- CHARACTER CACHE
-- ============================================================
function LL.refreshCharCache()
    LL.Cache.Character = LP.Character
    LL.Cache.Humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") or nil
    LL.Cache.HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") or nil
end

LL.trackConn(LP.CharacterAdded:Connect(function(ch)
    task.wait(0.3)
    LL.refreshCharCache()
    if LL.applyGravityState then LL.applyGravityState() end
    if LL.S.Player.Noclip and ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))
LL.trackConn(LP.CharacterRemoving:Connect(function()
    LL.Cache.Character = nil
    LL.Cache.Humanoid = nil
    LL.Cache.HRP = nil
end))
LL.refreshCharCache()
-- ============================================================
-- TOGGLE
-- ============================================================
function LL.Toggle(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -78, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -58, 0.5, -11)
    track.BackgroundColor3 = COL.off
    track.BorderSizePixel = 0
    track.Parent = f
    LL.corner(track, 11)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    LL.corner(knob, 9)
    local function render()
        if getter() then
            track.BackgroundColor3 = COL.accent
            Tween:Create(knob, LL.Anim.Fast,
                {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            track.BackgroundColor3 = COL.off
            Tween:Create(knob, LL.Anim.Fast,
                {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
    end
    render(); LL.AddRefresh(render)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        setter(not getter()); render(); LL.MarkDirty()
    end)
end

-- ============================================================
-- SLIDER
-- ============================================================
function LL.Slider(parent, name, minV, maxV, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 16, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -32, 0, 8)
    bar.Position = UDim2.new(0, 16, 0, 38)
    bar.BackgroundColor3 = Color3.fromRGB(14, 10, 22)
    bar.BorderSizePixel = 0
    bar.Parent = f
    LL.corner(bar, 4)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    LL.corner(fill, 4)
    LL.gradient(fill, COL.accent, COL.accent2, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = bar
    LL.corner(dot, 7)
    local function render()
        local v = getter()
        local rel = math.clamp((v - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        dot.Position = UDim2.new(rel, 0, 0.5, 0)
        lbl.Text = name .. ": " .. tostring(math.floor(v*100+0.5)/100)
    end
    render(); LL.AddRefresh(render)
    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(1, 16, 0, 30)
    ca.Position = UDim2.new(0, -8, 0, -11)
    ca.BackgroundTransparency = 1
    ca.Text = ""
    ca.Parent = bar
    local drag = false
    local function setX(px)
        local rel = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setter(minV + rel * (maxV - minV)); render(); LL.MarkDirty()
    end
    ca.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; setX(i.Position.X)
        end
    end)
    LL.trackConn(UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then setX(i.Position.X) end
    end))
    LL.trackConn(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end))
end

-- ============================================================
-- DROPDOWN
-- ============================================================
function LL.Dropdown(parent, name, options, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = COL.accent2
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16
    arrow.Parent = f
    local function render() lbl.Text = name .. ": " .. tostring(getter()) end
    render(); LL.AddRefresh(render)
    local popup
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        if popup and popup.Parent then popup:Destroy(); popup = nil; return end
        local popH = #options*30+8
        local popupFrame = Instance.new("Frame")
        popupFrame.Size = UDim2.new(0, f.AbsoluteSize.X, 0, popH)
        local vp = Camera.ViewportSize
        local yPos = f.AbsolutePosition.Y + f.AbsoluteSize.Y + 4
        if yPos + popH > vp.Y - 20 then
            yPos = f.AbsolutePosition.Y - popH - 4
        end
        popupFrame.Position = UDim2.new(0, f.AbsolutePosition.X, 0, yPos)
        popupFrame.BackgroundColor3 = COL.bg2
        popupFrame.BorderSizePixel = 0
        popupFrame.ZIndex = 50
        popupFrame.Parent = ScreenGui
        LL.corner(popupFrame, 12); LL.stroke(popupFrame, COL.accent, 1.5)
        popup = popupFrame
        for i, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, -8, 0, 26)
            ob.Position = UDim2.new(0, 4, 0, (i-1)*30 + 4)
            ob.BackgroundColor3 = COL.elem
            ob.BorderSizePixel = 0
            ob.Text = opt
            ob.TextColor3 = COL.text
            ob.Font = Enum.Font.Gotham
            ob.TextSize = 14
            ob.ZIndex = 51
            ob.AutoButtonColor = false
            ob.Parent = popupFrame
            LL.corner(ob, 6)
            ob.MouseEnter:Connect(function()
                Tween:Create(ob, LL.Anim.Fast, {BackgroundColor3 = COL.elemHover}):Play()
            end)
            ob.MouseLeave:Connect(function()
                Tween:Create(ob, LL.Anim.Fast, {BackgroundColor3 = COL.elem}):Play()
            end)
            ob.MouseButton1Click:Connect(function()
                setter(opt); render(); LL.MarkDirty()
                if popup then popup:Destroy(); popup = nil end
            end)
        end
    end)
end

-- ============================================================
-- COLOR PICKER
-- ============================================================
LL.PALETTE = {
    Color3.fromRGB(255,20,147), Color3.fromRGB(180,60,255),
    Color3.fromRGB(255,60,60),  Color3.fromRGB(60,255,60),
    Color3.fromRGB(60,120,255), Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,255,0),  Color3.fromRGB(255,150,0),
    Color3.fromRGB(255,255,255),Color3.fromRGB(128,128,128),
    Color3.fromRGB(180,0,255),  Color3.fromRGB(255,100,180),
}

function LL.ColorPicker(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 90)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 16, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local swatches = {}
    for i, c in ipairs(LL.PALETTE) do
        local row = math.floor((i-1)/6)
        local col = (i-1) % 6
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 22)
        b.Position = UDim2.new(0, 16+col*36, 0, 32+row*24)
        b.BackgroundColor3 = c
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.Parent = f
        LL.corner(b, 6)
        local s = LL.stroke(b, Color3.new(1,1,1), (c == getter()) and 2 or 0)
        swatches[#swatches+1] = {line = s, color = c}
        b.MouseButton1Click:Connect(function()
            setter(c); LL.MarkDirty()
            for _, sw in ipairs(swatches) do sw.line.Thickness = 0 end
            s.Thickness = 2
        end)
    end
end

-- ============================================================
-- TEXT BOX
-- ============================================================
function LL.TextBox(parent, name, placeholder, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 16, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -32, 0, 26)
    box.Position = UDim2.new(0, 16, 0, 30)
    box.BackgroundColor3 = COL.bg2
    box.BorderSizePixel = 0
    box.Text = getter() or ""
    box.PlaceholderText = placeholder or ""
    box.TextColor3 = COL.text
    box.PlaceholderColor3 = COL.sub
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = f
    LL.corner(box, 8)
    LL.stroke(box, COL.stroke, 1)
    box.FocusLost:Connect(function() setter(box.Text); LL.MarkDirty() end)
end

-- ============================================================
-- BUTTON
-- ============================================================
function LL.Button(parent, label, callback, opts)
    opts = opts or {}
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = opts.color or COL.elem
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = opts.textColor or COL.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.LayoutOrder = LL.NextOrder()
    b.AutoButtonColor = false
    b.Parent = parent
    LL.corner(b, 12)
    LL.stroke(b, opts.stroke or COL.stroke, 1)
    b.MouseEnter:Connect(function()
        Tween:Create(b, LL.Anim.Fast,
            {BackgroundColor3 = opts.hover or COL.elemHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(b, LL.Anim.Fast,
            {BackgroundColor3 = opts.color or COL.elem}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- ============================================================
-- BIND BUTTON
-- ============================================================
function LL.BindButton(parent, action, name)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = COL.elem
    f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0
    f.LayoutOrder = LL.NextOrder()
    f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -130, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(0, 108, 0, 28)
    keyLbl.Position = UDim2.new(1, -120, 0.5, -14)
    keyLbl.BackgroundColor3 = COL.bg2
    keyLbl.BorderSizePixel = 0
    keyLbl.TextColor3 = COL.accent2
    keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 13
    keyLbl.Parent = f
    LL.corner(keyLbl, 8)
    local function refresh()
        local k = LL.S.Binds[action]
        if k then
            keyLbl.Text = tostring(k):gsub("Enum.KeyCode.","")
            keyLbl.TextColor3 = COL.accent2
        else
            keyLbl.Text = "None"
            keyLbl.TextColor3 = COL.sub
        end
    end
    refresh()
    LL.BindRefreshers[action] = refresh
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 108, 0, 28)
    btn.Position = UDim2.new(1, -120, 0.5, -14)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Active = true
    btn.Parent = f
    btn.MouseButton1Down:Connect(function()
        getgenv().TIMON_LISTENING = action
        keyLbl.Text = "нажми..."
        keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)
end
-- ============================================================
-- LIGHTING MANAGER
-- ============================================================
LL.LightingMgr = { original=nil, boosterApplied=false, fullbrightApplied=false }

function LL.captureLightingOriginal()
    if LL.LightingMgr.original then return end
    LL.LightingMgr.original = {
        Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
        Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
        FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart,
        GlobalShadows=Lighting.GlobalShadows,
    }
end

function LL.applyLightingState()
    if not LL.LightingMgr.original then return end
    local o = LL.LightingMgr.original
    Lighting.Ambient=o.Ambient; Lighting.OutdoorAmbient=o.OutdoorAmbient
    Lighting.Brightness=o.Brightness; Lighting.ClockTime=o.ClockTime
    Lighting.FogEnd=o.FogEnd; Lighting.FogStart=o.FogStart
    Lighting.GlobalShadows=o.GlobalShadows
    if LL.LightingMgr.boosterApplied then
        pcall(function()
            local rs = Settings.Rendering
            rs.QualityLevel = 1
            rs.MeshPartHeadsAndAccessories = Enum.MeshPartHeadsAndAccessories.Disabled
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0.5
        end)
    end
    if LL.LightingMgr.fullbrightApplied then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    end
end

function LL.setBooster(on)
    LL.captureLightingOriginal()
    LL.LightingMgr.boosterApplied = on
    LL.applyLightingState()
end
function LL.setFullbright(on)
    LL.captureLightingOriginal()
    LL.LightingMgr.fullbrightApplied = on
    LL.applyLightingState()
end

LL.lowQualityRemoved = {}
function LL.enableLowQuality()
    LL.captureLightingOriginal()
    pcall(function()
        Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                table.insert(LL.lowQualityRemoved, obj)
                obj.Enabled = false
            end
        end
    end)
end
function LL.disableLowQuality()
    for _, obj in ipairs(LL.lowQualityRemoved) do
        if obj and obj.Parent then pcall(function() obj.Enabled = true end) end
    end
    LL.lowQualityRemoved = {}
    LL.applyLightingState()
end
function LL.enableFPSBooster() LL.setBooster(true) end
function LL.disableFPSBooster() LL.setBooster(false) end
function LL.enableFullbright() LL.setFullbright(true) end
function LL.disableFullbright() LL.setFullbright(false) end

-- ============================================================
-- GRAVITY
-- ============================================================
function LL.applyGravityState()
    local chr = LL.Cache.Character
    local hum = LL.Cache.Humanoid
    if LL.S.Player.ZeroGravity then
        Workspace.Gravity = 0
        if hum then
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

-- ============================================================
-- ANTI-AFK (умный)
-- ============================================================
LL.antiAFKThread = nil
LL.lastUserAction = tick()

function LL.startAntiAFK()
    if LL.antiAFKThread then return end
    local hookOk = false
    pcall(function()
        if typeof(hookfunction) == "function" and typeof(getconnections) == "function" then
            for _, c in ipairs(getconnections(LP.Idled)) do
                if c and typeof(c.Disable) == "function" then c:Disable() end
            end
            hookOk = true
        end
    end)
    if not hookOk then LL.Notify("Anti-AFK: fallback VirtualUser") end
    LL.antiAFKThread = LL.trackThread(task.spawn(function()
        while getgenv().TIMON_LOADED and LL.S.Player.AntiAFK do
            task.wait(30)
            if tick() - LL.lastUserAction >= 55 then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end
        LL.antiAFKThread = nil
    end))
end
function LL.stopAntiAFK()
    if LL.antiAFKThread then
        pcall(function() task.cancel(LL.antiAFKThread) end)
        LL.antiAFKThread = nil
    end
end

LL.trackConn(UIS.InputBegan:Connect(function()
    LL.lastUserAction = tick()
end))

-- ============================================================
-- TAB SYSTEM (lazy build)
-- ============================================================
local Left = Instance.new("ScrollingFrame")
Left.Size = UDim2.new(0, 170, 1, -60)
Left.Position = UDim2.new(0, 12, 0, 54)
Left.BackgroundColor3 = COL.bg2
Left.BackgroundTransparency = 0.05
Left.BorderSizePixel = 0
Left.Parent = Main
Left.ScrollBarThickness = 4
Left.ScrollBarImageColor3 = COL.accent2
Left.ScrollBarImageTransparency = 0.3
Left.CanvasSize = UDim2.new(0, 0, 0, 0)
Left.AutomaticCanvasSize = Enum.AutomaticSize.Y
Left.ScrollingDirection = Enum.ScrollingDirection.Y
Left.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
LL.corner(Left, 14)
LL.Left = Left

local LL_Layout = Instance.new("UIListLayout")
LL_Layout.Padding = UDim.new(0, 5)
LL_Layout.SortOrder = Enum.SortOrder.LayoutOrder
LL_Layout.Parent = Left
LL.padding(Left, 8, 8, 8, 8)

local Right = Instance.new("Frame")
Right.Size = UDim2.new(1, -196, 1, -60)
Right.Position = UDim2.new(0, 188, 0, 54)
Right.BackgroundTransparency = 1
Right.Parent = Main
LL.Right = Right

LL.TabBuilders = {}

function LL.Tab(name, builder)
    LL.TabBuilders[name] = builder
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = COL.elem
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = COL.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.LayoutOrder = LL.NextOrder()
    b.AutoButtonColor = false
    b.Parent = Left
    LL.corner(b, 12)
    LL.stroke(b, COL.stroke, 1)
    b.MouseEnter:Connect(function()
        if b.BackgroundColor3 ~= COL.accent then
            Tween:Create(b, LL.Anim.Fast, {BackgroundColor3 = COL.elemHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if b.BackgroundColor3 ~= COL.accent then
            Tween:Create(b, LL.Anim.Fast, {BackgroundColor3 = COL.elem}):Play()
        end
    end)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = COL.accent2
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false
    sc.Parent = Right
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = sc
    LL.padding(sc, 4, 4, 10, 8)
    LL.TabScrolls[name] = {btn = b, scroll = sc, built = false}
    table.insert(LL.TabOrder, name)
    b.MouseButton1Click:Connect(function()
        LL.SwitchTab(name)
    end)
    return sc
end

function LL.SwitchTab(name)
    if LL.CurrentTab == name then return end
    for tn, t in pairs(LL.TabScrolls) do
        t.scroll.Visible = false
        t.btn.BackgroundColor3 = COL.elem
    end
    local t = LL.TabScrolls[name]
    if not t then return end
    if not t.built and LL.TabBuilders[name] then
        pcall(LL.TabBuilders[name], t.scroll)
        t.built = true
    end
    t.scroll.Visible = true
    t.btn.BackgroundColor3 = COL.accent
    LL.CurrentTab = name
end

-- ============================================================
-- COMBAT TAB
-- ============================================================
LL.Tab("Combat", function(parent)
    LL.Section(parent, "Основное")
    LL.Toggle(parent, "Enable Aim",
        function() return LL.S.Aimbot.Enabled end,
        function(v) LL.S.Aimbot.Enabled = v end)
    LL.Section(parent, "Кого наводить")
    LL.Toggle(parent, "Target Players",
        function() return LL.S.Aimbot.TargetPlayers end,
        function(v) LL.S.Aimbot.TargetPlayers = v end)
    LL.Toggle(parent, "Target NPCs",
        function() return LL.S.Aimbot.TargetNPCs end,
        function(v) LL.S.Aimbot.TargetNPCs = v end)
    LL.Section(parent, "Aim поведение")
    LL.Toggle(parent, "Sticky Lock",
        function() return LL.S.Aimbot.StickyLock end,
        function(v) LL.S.Aimbot.StickyLock = v end)
    LL.Toggle(parent, "Wall Check",
        function() return LL.S.Aimbot.WallCheck end,
        function(v) LL.S.Aimbot.WallCheck = v end)
    LL.Dropdown(parent, "Aim Mode", {"Cursor", "Camera", "Mobile"},
        function() return LL.S.Aimbot.Mode end,
        function(v) LL.S.Aimbot.Mode = v end)
    LL.Slider(parent, "Smoothness", 0.01, 1,
        function() return LL.S.Aimbot.Smooth end,
        function(v) LL.S.Aimbot.Smooth = math.min(v, 0.95) end)
    LL.Slider(parent, "Distance Weight", 0, 5,
        function() return LL.S.Aimbot.DistanceWeight end,
        function(v) LL.S.Aimbot.DistanceWeight = v end)
    LL.Section(parent, "FOV")
    LL.Slider(parent, "Camera FOV", 30, 800,
        function() return LL.S.Aimbot.CameraFOV end,
        function(v) LL.S.Aimbot.CameraFOV = v end)
    LL.Slider(parent, "Mobile FOV", 30, 800,
        function() return LL.S.Aimbot.MobileFOV end,
        function(v) LL.S.Aimbot.MobileFOV = v end)
    LL.Toggle(parent, "Show FOV Circle",
        function() return LL.S.Aimbot.ShowFOV end,
        function(v) LL.S.Aimbot.ShowFOV = v end)
    LL.ColorPicker(parent, "FOV Circle Color",
        function() return LL.S.Aimbot.FOVColor end,
        function(v) LL.S.Aimbot.FOVColor = v end)
    LL.Section(parent, "Target Part")
    LL.Dropdown(parent, "Aim Part",
        {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
        function() return LL.S.Aimbot.Part end,
        function(v) LL.S.Aimbot.Part = v end)
    LL.Section(parent, "Prediction")
    LL.Toggle(parent, "Predict Lead",
        function() return LL.S.Aimbot.PredictLead end,
        function(v) LL.S.Aimbot.PredictLead = v end)
    LL.Toggle(parent, "Hitscan Mode",
        function() return LL.S.Aimbot.HitscanMode end,
        function(v) LL.S.Aimbot.HitscanMode = v end)
    LL.Slider(parent, "Bullet Speed", 100, 5000,
        function() return LL.S.Aimbot.BulletSpeed end,
        function(v) LL.S.Aimbot.BulletSpeed = math.floor(v + 0.5) end)
    LL.Slider(parent, "Lead Multiplier", 0.3, 2.0,
        function() return LL.S.Aimbot.LeadMultiplier end,
        function(v) LL.S.Aimbot.LeadMultiplier = v end)
    LL.Section(parent, "Jitter")
    LL.Toggle(parent, "Enable Jitter",
        function() return LL.S.Aimbot.JitterEnabled end,
        function(v) LL.S.Aimbot.JitterEnabled = v end)
    LL.Slider(parent, "Jitter Amount (px)", 0, 5,
        function() return LL.S.Aimbot.Jitter end,
        function(v) LL.S.Aimbot.Jitter = v end)
    LL.Section(parent, "Combat Visuals")
    LL.Toggle(parent, "Hitbox Visualizer",
        function() return LL.S.Aimbot.HitboxVisualizer end,
        function(v) LL.S.Aimbot.HitboxVisualizer = v end)
    LL.Toggle(parent, "Aim Assist Beam",
        function() return LL.S.Aimbot.AimAssistBeam end,
        function(v) LL.S.Aimbot.AimAssistBeam = v end)
    LL.ColorPicker(parent, "Beam Color",
        function() return LL.S.Aimbot.TracerColor end,
        function(v) LL.S.Aimbot.TracerColor = v end)
    LL.Toggle(parent, "Micro Adjust",
        function() return LL.S.Aimbot.MicroAdjust end,
        function(v) LL.S.Aimbot.MicroAdjust = v end)
    LL.Slider(parent, "Micro Adjust Amount (px)", 0.1, 3.0,
        function() return LL.S.Aimbot.MicroAdjustAmount end,
        function(v) LL.S.Aimbot.MicroAdjustAmount = v end)
end)

LL.SwitchTab("Combat")
-- ============================================================
-- ESP TAB
-- ============================================================
LL.Tab("ESP", function(parent)
    LL.Section(parent, "Toggle")
    LL.Toggle(parent, "Enable ESP (Players)",
        function() return LL.S.ESP.Enabled end,
        function(v)
            LL.S.ESP.Enabled = v
            if v then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then LL.CreateESP(p) end
                end
            else
                for p in pairs(LL.ESPObjs) do LL.RemoveESP(p) end
            end
        end)
    LL.Section(parent, "Power Mode")
    LL.Toggle(parent, "ESP после смерти",
        function() return LL.S.ESP.PowerMode end,
        function(v) LL.S.ESP.PowerMode = v end)
    LL.Slider(parent, "Max ESP Distance", 100, 3000,
        function() return LL.S.ESP.MaxDistance end,
        function(v) LL.S.ESP.MaxDistance = math.floor(v + 0.5) end)
    LL.Section(parent, "Highlight")
    LL.ColorPicker(parent, "Outline Color",
        function() return LL.S.ESP.OutlineColor end,
        function(v) LL.S.ESP.OutlineColor = v; LL.RefreshESPColors() end)
    LL.ColorPicker(parent, "Fill Color",
        function() return LL.S.ESP.FillColor end,
        function(v) LL.S.ESP.FillColor = v; LL.RefreshESPColors() end)
    LL.Slider(parent, "Fill Transparency", 0, 1,
        function() return LL.S.ESP.FillTransparency end,
        function(v) LL.S.ESP.FillTransparency = v; LL.RefreshESPColors() end)
    LL.Slider(parent, "Outline Transparency", 0, 1,
        function() return LL.S.ESP.OutlineTransparency end,
        function(v) LL.S.ESP.OutlineTransparency = v; LL.RefreshESPColors() end)
    LL.Toggle(parent, "Through Walls",
        function() return LL.S.ESP.ThroughWalls end,
        function(v) LL.S.ESP.ThroughWalls = v; LL.RefreshESPColors() end)
    LL.Section(parent, "Ники")
    LL.Toggle(parent, "Show Name",
        function() return LL.S.ESP.ShowName end,
        function(v) LL.S.ESP.ShowName = v end)
    LL.ColorPicker(parent, "Nick Color",
        function() return LL.S.ESP.NickColor end,
        function(v) LL.S.ESP.NickColor = v end)
    LL.Slider(parent, "Nick Size", 10, 24,
        function() return LL.S.ESP.NickSize end,
        function(v) LL.S.ESP.NickSize = math.floor(v + 0.5) end)
    LL.Section(parent, "HP Bar")
    LL.Toggle(parent, "Show HP Bar",
        function() return LL.S.ESP.ShowHPBar end,
        function(v) LL.S.ESP.ShowHPBar = v end)
    LL.Toggle(parent, "Dynamic HP Color",
        function() return LL.S.ESP.HPDynamicColor end,
        function(v) LL.S.ESP.HPDynamicColor = v end)
    LL.ColorPicker(parent, "HP Bar Color",
        function() return LL.S.ESP.HPBarColor end,
        function(v) LL.S.ESP.HPBarColor = v end)
    LL.Slider(parent, "HP Bar Width", 20, 120,
        function() return LL.S.ESP.HPBarWidth end,
        function(v) LL.S.ESP.HPBarWidth = math.floor(v + 0.5) end)
    LL.Slider(parent, "HP Bar Height", 2, 12,
        function() return LL.S.ESP.HPBarHeight end,
        function(v) LL.S.ESP.HPBarHeight = math.floor(v + 0.5) end)
    LL.Section(parent, "Дистанция")
    LL.Toggle(parent, "Show Distance",
        function() return LL.S.ESP.ShowDistance end,
        function(v) LL.S.ESP.ShowDistance = v end)
    LL.Section(parent, "Tracer (линия до цели)")
    LL.Toggle(parent, "Enable Tracer",
        function() return LL.S.ESP.TracerEnabled end,
        function(v) LL.S.ESP.TracerEnabled = v end)
    LL.ColorPicker(parent, "Tracer From (низ)",
        function() return LL.S.ESP.TracerFrom end,
        function(v) LL.S.ESP.TracerFrom = v end)
    LL.ColorPicker(parent, "Tracer To (цель)",
        function() return LL.S.ESP.TracerTo end,
        function(v) LL.S.ESP.TracerTo = v end)
    LL.Section(parent, "NPC ESP")
    LL.Toggle(parent, "Enable NPC ESP",
        function() return LL.S.ESP.NPCEnabled end,
        function(v)
            LL.S.ESP.NPCEnabled = v
            if v then
                LL.refreshNPCCache()
                for model in pairs(LL.NPCCache) do
                    if not LL.isPlayerCharacter(model) then LL.CreateNPCESP(model) end
                end
            else
                for model in pairs(LL.NPCESPObjs) do LL.RemoveNPCESP(model) end
            end
        end)
    LL.Toggle(parent, "Show NPC Name",
        function() return LL.S.ESP.NPCName end,
        function(v) LL.S.ESP.NPCName = v end)
    LL.Toggle(parent, "Show NPC Distance",
        function() return LL.S.ESP.NPCDistance end,
        function(v) LL.S.ESP.NPCDistance = v end)
    LL.Toggle(parent, "NPC HP Bar",
        function() return LL.S.ESP.NPCHPBar end,
        function(v) LL.S.ESP.NPCHPBar = v end)
end)

-- ============================================================
-- PLAYER TAB
-- ============================================================
LL.Tab("Player", function(parent)
    local function captureOriginals()
        local hum = LL.Cache.Humanoid
        if hum then
            if not LL.S.Player.OrigWalkSpeed then LL.S.Player.OrigWalkSpeed = hum.WalkSpeed end
            if not LL.S.Player.OrigJumpPower then LL.S.Player.OrigJumpPower = hum.JumpPower end
        end
    end

    LL.Section(parent, "Movement")
    LL.Toggle(parent, "Walk Speed Override",
        function() return LL.S.Player.WalkSpeedEnabled end,
        function(v)
            if v then captureOriginals() end
            LL.S.Player.WalkSpeedEnabled = v
        end)
    LL.Slider(parent, "Walk Speed", 16, 300,
        function() return LL.S.Player.WalkSpeed end,
        function(v) LL.S.Player.WalkSpeed = v end)
    LL.Toggle(parent, "Jump Power Override",
        function() return LL.S.Player.JumpPowerEnabled end,
        function(v)
            if v then captureOriginals() end
            LL.S.Player.JumpPowerEnabled = v
        end)
    LL.Slider(parent, "Jump Power", 50, 300,
        function() return LL.S.Player.JumpPower end,
        function(v) LL.S.Player.JumpPower = v end)
    LL.Toggle(parent, "Infinite Jump",
        function() return LL.S.Player.InfiniteJump end,
        function(v) LL.S.Player.InfiniteJump = v end)
    LL.Toggle(parent, "Noclip",
        function() return LL.S.Player.Noclip end,
        function(v) LL.S.Player.Noclip = v end)

    LL.Section(parent, "Fly")
    LL.Toggle(parent, "Fly (ПК)",
        function() return LL.S.Player.Fly end,
        function(v) LL.S.Player.Fly = v end)
    LL.Toggle(parent, "Mobile Fly (XNEO GUI)",
        function() return LL.S.Player.MobileFly == true and LL.Xneo.gui ~= nil end,
        function(v)
            if v then
                if not LL.Xneo.gui then LL.launchXneoFlyGUI() end
            else
                if LL.Xneo.gui then LL.closeXneoFlyGUI() end
            end
        end)
    LL.Slider(parent, "Fly Speed (PC)", 10, 300,
        function() return LL.S.Player.FlySpeed end,
        function(v) LL.S.Player.FlySpeed = v end)

    LL.Section(parent, "Gravity")
    LL.Toggle(parent, "Zero Gravity (ragdoll)",
        function() return LL.S.Player.ZeroGravity end,
        function(v) LL.S.Player.ZeroGravity = v; LL.applyGravityState() end)

    LL.Section(parent, "Coordinates (Save/Load)")
    LL.Button(parent, "Save Current Position", function()
        local hrp = LL.Cache.HRP
        if hrp then
            LL.S.Player.SavedPos = hrp.CFrame
            LL.MarkDirty()
            LL.Notify("Позиция сохранена")
        end
    end)
    LL.Button(parent, "Load Saved Position", function()
        local hrp = LL.Cache.HRP
        if hrp and LL.S.Player.SavedPos then
            hrp.CFrame = LL.S.Player.SavedPos
            LL.Notify("Позиция загружена")
        else
            LL.Notify("Нет сохранённой позиции")
        end
    end)
    LL.Button(parent, "Clear Saved Position", function()
        LL.S.Player.SavedPos = nil
        LL.MarkDirty()
        LL.Notify("Позиция очищена")
    end)

    LL.Section(parent, "Utility")
    LL.Toggle(parent, "Anti-AFK",
        function() return LL.S.Player.AntiAFK end,
        function(v)
            LL.S.Player.AntiAFK = v
            if v then LL.startAntiAFK() else LL.stopAntiAFK() end
        end)
    LL.Toggle(parent, "Lazy Mode (ESP каждый 2-й кадр)",
        function() return LL.S.Player.LazyMode end,
        function(v) LL.S.Player.LazyMode = v end)
    LL.Toggle(parent, "FPS Booster",
        function() return LL.S.Player.FPSBooster end,
        function(v)
            LL.S.Player.FPSBooster = v
            if v then LL.enableFPSBooster() else LL.disableFPSBooster() end
        end)
    LL.Toggle(parent, "Low Quality Mode",
        function() return LL.S.Player.LowQuality end,
        function(v)
            LL.S.Player.LowQuality = v
            if v then LL.enableLowQuality() else LL.disableLowQuality() end
        end)
    LL.Toggle(parent, "Fullbright",
        function() return LL.S.Player.Fullbright end,
        function(v)
            LL.S.Player.Fullbright = v
            if v then LL.enableFullbright() else LL.disableFullbright() end
        end)
end)

-- ============================================================
-- TROLL TAB
-- ============================================================
LL.Tab("Troll", function(parent)
    LL.Section(parent, "Движение")
    LL.Toggle(parent, "Spin Self",
        function() return LL.S.Troll.Spin end,
        function(v) LL.S.Troll.Spin = v end)
    LL.Button(parent, "Fling Self", function()
        local hrp = LL.Cache.HRP
        if hrp then
            local av = Instance.new("AngularVelocity")
            av.MaxTorque = math.huge
            av.AngularVelocity = Vector3.new(0, 60, 0)
            av.Parent = hrp
            task.wait(0.4)
            pcall(function() av:Destroy() end)
            LL.Notify("Fling!")
        end
    end, {color = COL.accent2, hover = Color3.fromRGB(255, 120, 210), textColor = Color3.new(1,1,1)})

    LL.Section(parent, "Внешность")
    LL.Toggle(parent, "Invisible Self (local)",
        function() return LL.S.Troll.Invisible end,
        function(v)
            LL.S.Troll.Invisible = v
            if not v and LL.Cache.Character then
                for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.LocalTransparencyModifier = 0
                    elseif p:IsA("Decal") then p.Transparency = 0 end
                end
            end
        end)

    LL.Section(parent, "Anti Fling")
    LL.Toggle(parent, "Anti Fling",
        function() return LL.S.Troll.AntiFling end,
        function(v)
            LL.S.Troll.AntiFling = v
            if not v and LL.Cache.Character then
                for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)

    LL.Section(parent, "Teleport / Spectate")
    LL.TextBox(parent, "Target Username", "username",
        function() return "" end,
        function(v) end)
    LL.Button(parent, "Teleport to Player", function()
        LL.Notify("Teleport: укажи юзера в поле и нажми — фича через Actions")
    end)
    LL.Button(parent, "Spectate Player", function()
        LL.Notify("Spectate: в разработке для v4.6.1")
    end)
end)

-- ============================================================
-- HAMSTER TAB
-- ============================================================
LL.Tab("Hamster", function(parent)
    local coinLbl = Instance.new("TextLabel")
    coinLbl.Size = UDim2.new(1, 0, 0, 52)
    coinLbl.BackgroundColor3 = COL.bg2
    coinLbl.BackgroundTransparency = 0.05
    coinLbl.BorderSizePixel = 0
    coinLbl.LayoutOrder = -1
    coinLbl.Font = Enum.Font.GothamBold
    coinLbl.TextSize = 22
    coinLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinLbl.TextXAlignment = Enum.TextXAlignment.Right
    coinLbl.Text = tostring(LL.S.Hamster.Coins) .. " монет"
    coinLbl.Parent = parent
    LL.corner(coinLbl, 12)
    LL.stroke(coinLbl, Color3.fromRGB(255, 215, 0), 1.5)
    LL.padding(coinLbl, 0, 0, 16, 0)

    local function refreshCoin()
        coinLbl.Text = tostring(LL.S.Hamster.Coins) .. " монет"
    end
    LL.AddRefresh(refreshCoin)

    local spamBtn = Instance.new("TextButton")
    spamBtn.Size = UDim2.new(0, 170, 0, 170)
    spamBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    spamBtn.Position = UDim2.new(0.5, 0, 0.55, 0)
    spamBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    spamBtn.BorderSizePixel = 0
    spamBtn.Text = "🐹"
    spamBtn.Font = Enum.Font.GothamBold
    spamBtn.TextSize = 100
    spamBtn.AutoButtonColor = false
    spamBtn.LayoutOrder = LL.NextOrder()
    spamBtn.Parent = parent
    LL.corner(spamBtn, 85)
    LL.stroke(spamBtn, Color3.fromRGB(255, 180, 0), 3)

    local spamLabel = Instance.new("TextLabel")
    spamLabel.Size = UDim2.new(1, 0, 0, 34)
    spamLabel.BackgroundTransparency = 1
    spamLabel.LayoutOrder = LL.NextOrder()
    spamLabel.Text = "ЖМИ ХОМЯКА"
    spamLabel.Font = Enum.Font.GothamBold
    spamLabel.TextSize = 16
    spamLabel.TextColor3 = COL.accent2
    spamLabel.Parent = parent

    local spamInfo = Instance.new("TextLabel")
    spamInfo.Size = UDim2.new(1, 0, 0, 28)
    spamInfo.BackgroundTransparency = 1
    spamInfo.LayoutOrder = LL.NextOrder()
    spamInfo.Text = "Каждый клик = +1 монета"
    spamInfo.Font = Enum.Font.Gotham
    spamInfo.TextSize = 13
    spamInfo.TextColor3 = COL.sub
    spamInfo.Parent = parent

    local clickCooldown = false
    spamBtn.MouseButton1Click:Connect(function()
        if clickCooldown then return end
        clickCooldown = true
        LL.S.Hamster.Coins = LL.S.Hamster.Coins + 1
        refreshCoin(); LL.MarkDirty()
        Tween:Create(spamBtn, LL.Anim.Fast, {Size = UDim2.new(0, 150, 0, 150)}):Play()
        task.delay(0.09, function()
            Tween:Create(spamBtn, LL.Anim.Fast, {Size = UDim2.new(0, 170, 0, 170)}):Play()
        end)
        task.delay(0.05, function() clickCooldown = false end)
    end)

    LL.Button(parent, "Сбросить монеты", function()
        LL.S.Hamster.Coins = 0; refreshCoin(); LL.MarkDirty()
        LL.Notify("Монеты сброшены")
    end, {textColor = COL.accent2})
end)
-- ============================================================
-- SETTINGS TAB
-- ============================================================
LL.Tab("Settings", function(parent)
    LL.Section(parent, "Действия")
    LL.Button(parent, "Сбросить настройки", function()
        local S = LL.S
        S.Aimbot.Enabled=false; S.Aimbot.Smooth=0.25
        S.Aimbot.CameraFOV=200; S.Aimbot.MobileFOV=200
        S.Aimbot.DistanceWeight=1; S.Aimbot.WallCheck=false
        S.Aimbot.JitterEnabled=false; S.Aimbot.Jitter=1.5
        S.Aimbot.HitboxVisualizer=false; S.Aimbot.AimAssistBeam=false
        S.Aimbot.MicroAdjust=false; S.Aimbot.MicroAdjustAmount=1.0
        S.ESP.Enabled=false; S.ESP.NPCEnabled=false; S.ESP.PowerMode=true
        S.Hitbox.Enabled=false; S.Hitbox.NPCSupport=false
        S.Player.Fly=false
        if LL.Xneo.gui then LL.closeXneoFlyGUI() end
        S.Player.Noclip=false; S.Player.InfiniteJump=false
        S.Player.ZeroGravity=false
        S.Player.WalkSpeed=16; S.Player.JumpPower=50
        S.Player.WalkSpeedEnabled=true; S.Player.JumpPowerEnabled=true
        S.Player.AntiAFK=false; LL.stopAntiAFK()
        S.Player.FPSBooster=false; LL.disableFPSBooster()
        S.Player.LowQuality=false; LL.disableLowQuality()
        S.Player.Fullbright=false; LL.disableFullbright()
        S.Troll.AntiFling=false
        S.FloatingLock=false; S.FloatingPos={}
        LL.ApplyFloatingLock()
        LL.RepositionAllFloatingBtns()
        LL.applyGravityState()
        LL.RefreshAll(); LL.MarkDirty(); LL.Notify("Настройки сброшены")
    end)
    LL.Button(parent, "Выгрузить скрипт", function()
        pcall(function() getgenv().TIMON_UNLOAD() end)
    end, {color = COL.accent2, hover = Color3.fromRGB(255, 120, 210), textColor = Color3.new(1,1,1)})

    LL.Section(parent, "Конфиги")
    LL.TextBox(parent, "Имя конфига", "auto",
        function() return LL.S.ConfigName end,
        function(v) LL.S.ConfigName = (v ~= "" and v) or "auto" end)
    LL.Button(parent, "Сохранить (перезапись)", function()
        local name = LL.S.ConfigName or "auto"
        if LL.saveConfig(name) then
            LL.Notify("Сохранено: "..name)
            LL.RefreshCfgList()
        else LL.Notify("Ошибка сохранения") end
    end)

    local function applyLoadedSettings()
        LL.RefreshAll()
        for _, fn in pairs(LL.BindRefreshers) do pcall(fn) end
        for p in pairs(LL.ESPObjs) do LL.RemoveESP(p) end
        for m in pairs(LL.NPCESPObjs) do LL.RemoveNPCESP(m) end
        if LL.S.ESP.Enabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then LL.CreateESP(p) end
            end
        end
        if LL.S.ESP.NPCEnabled then
            LL.refreshNPCCache()
            for m in pairs(LL.NPCCache) do
                if not LL.isPlayerCharacter(m) then LL.CreateNPCESP(m) end
            end
        end
        LL.ClearAllHitboxes()
        LL.ClearAllNPCHitboxes()
        if LL.S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
        end
        if LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport then
            LL.refreshNPCCache()
            for model in pairs(LL.NPCCache) do pcall(LL.ApplyNPCHitbox, model) end
        end
        for action, state in pairs(LL.S.MobileBtns) do
            LL.ToggleMobileBtn(action, state)
        end
        LL.RepositionAllFloatingBtns()
        LL.ApplyFloatingLock()
        LL.applyGravityState()
        if LL.S.Player.AntiAFK then LL.startAntiAFK() else LL.stopAntiAFK() end
        if LL.S.Player.FPSBooster then LL.enableFPSBooster() else LL.disableFPSBooster() end
        if LL.S.Player.LowQuality then LL.enableLowQuality() else LL.disableLowQuality() end
        if LL.S.Player.Fullbright then LL.enableFullbright() else LL.disableFullbright() end
        if LL.S.Player.MobileFly then
            if not LL.Xneo.gui then LL.launchXneoFlyGUI() end
        else
            if LL.Xneo.gui then LL.closeXneoFlyGUI() end
        end
        LL.MarkDirty()
    end
    LL.applyLoadedSettingsFn = applyLoadedSettings

    LL.Button(parent, "Загрузить", function()
        local name = LL.S.ConfigName or "auto"
        if LL.loadConfigFile(name) then
            LL.applyLoadedSettingsFn()
            LL.Notify("Загружено: "..name)
        else LL.Notify("Не найден: "..name) end
    end)
    LL.Button(parent, "Удалить", function()
        local name = LL.S.ConfigName or "auto"
        LL.deleteConfig(name)
        LL.Notify("Удалено: "..name)
        LL.RefreshCfgList()
    end)
    LL.Toggle(parent, "Авто-сохранение",
        function() return LL.S.AutoSave end,
        function(v) LL.S.AutoSave = v end)

    LL.Section(parent, "Доступные конфиги")
    local cfgListLbl = Instance.new("TextLabel")
    cfgListLbl.Size = UDim2.new(1, 0, 0, 100)
    cfgListLbl.BackgroundColor3 = COL.elem
    cfgListLbl.BackgroundTransparency = 0.05
    cfgListLbl.BorderSizePixel = 0
    cfgListLbl.LayoutOrder = LL.NextOrder()
    cfgListLbl.TextColor3 = COL.sub
    cfgListLbl.Font = Enum.Font.Gotham
    cfgListLbl.TextSize = 13
    cfgListLbl.TextWrapped = true
    cfgListLbl.TextXAlignment = Enum.TextXAlignment.Left
    cfgListLbl.TextYAlignment = Enum.TextYAlignment.Top
    cfgListLbl.Parent = parent
    LL.corner(cfgListLbl, 12)
    LL.stroke(cfgListLbl, COL.stroke, 1)
    LL.padding(cfgListLbl, 8, 16, 12, 8)

    function LL.RefreshCfgList()
        local list = LL.listConfigs()
        if #list == 0 then cfgListLbl.Text = "(пусто)"
        else
            table.sort(list)
            cfgListLbl.Text = table.concat(list, "\n")
        end
    end
    LL.RefreshCfgList()

    LL.Section(parent, "UI")
    LL.Toggle(parent, "Уведомления",
        function() return LL.S.UI.Notifications end,
        function(v) LL.S.UI.Notifications = v end)
    LL.Toggle(parent, "Авто-скрытие GUI на мобиле",
        function() return LL.S.UI.AutoHideOnMobile end,
        function(v) LL.S.UI.AutoHideOnMobile = v end)
end)

-- ============================================================
-- BINDS TAB (с поиском)
-- ============================================================
LL.Tab("Binds", function(parent)
    LL.Section(parent, "Key Binds")
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, 0, 0, 36)
    searchBox.BackgroundColor3 = COL.elem
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "Поиск биндов..."
    searchBox.Text = ""
    searchBox.TextColor3 = COL.text
    searchBox.PlaceholderColor3 = COL.sub
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.LayoutOrder = LL.NextOrder()
    searchBox.Parent = parent
    LL.corner(searchBox, 12)
    LL.stroke(searchBox, COL.stroke, 1)
    LL.padding(searchBox, 0, 12, 0, 0)

    local bindList = Instance.new("Frame")
    bindList.Size = UDim2.new(1, 0, 0, 0)
    bindList.BackgroundTransparency = 1
    bindList.AutomaticSize = Enum.AutomaticSize.Y
    bindList.LayoutOrder = LL.NextOrder()
    bindList.Parent = parent
    local bindLayout = Instance.new("UIListLayout")
    bindLayout.Padding = UDim.new(0, 6)
    bindLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bindLayout.Parent = bindList

    local bindEntries = {}
    local function addBind(action, name)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 42)
        f.BackgroundColor3 = COL.elem
        f.BackgroundTransparency = 0.05
        f.BorderSizePixel = 0
        f.Parent = bindList
        f.Visible = true
        LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -130, 1, 0)
        lbl.Position = UDim2.new(0, 16, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = COL.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = f
        local keyLbl = Instance.new("TextLabel")
        keyLbl.Size = UDim2.new(0, 108, 0, 28)
        keyLbl.Position = UDim2.new(1, -120, 0.5, -14)
        keyLbl.BackgroundColor3 = COL.bg2
        keyLbl.BorderSizePixel = 0
        keyLbl.TextColor3 = COL.accent2
        keyLbl.Font = Enum.Font.GothamBold
        keyLbl.TextSize = 13
        keyLbl.Parent = f
        LL.corner(keyLbl, 8)
        local function refresh()
            local k = LL.S.Binds[action]
            if k then
                keyLbl.Text = tostring(k):gsub("Enum.KeyCode.","")
                keyLbl.TextColor3 = COL.accent2
            else
                keyLbl.Text = "None"
                keyLbl.TextColor3 = COL.sub
            end
        end
        refresh()
        LL.BindRefreshers[action] = refresh
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 108, 0, 28)
        btn.Position = UDim2.new(1, -120, 0.5, -14)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Active = true
        btn.Parent = f
        btn.MouseButton1Down:Connect(function()
            getgenv().TIMON_LISTENING = action
            keyLbl.Text = "нажми..."
            keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
        end)
        bindEntries[#bindEntries+1] = {frame = f, name = name, action = action}
    end

    addBind("Aimbot", "Aimbot Toggle")
    addBind("AimbotHold", "Aim Hold")
    addBind("ESP", "ESP")
    addBind("Hitbox", "Hitbox")
    addBind("Fly", "Fly")
    addBind("Noclip", "Noclip")
    addBind("InfiniteJump", "Infinite Jump")
    addBind("ZeroGravity", "Zero Gravity")
    addBind("SavePos", "Save Position")
    addBind("LoadPos", "Load Position")

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for _, e in ipairs(bindEntries) do
            if q == "" or string.find(string.lower(e.name), q, 1, true) then
                e.frame.Visible = true
            else
                e.frame.Visible = false
            end
        end
    end)

    LL.Button(parent, "Сбросить все бинды", function()
        LL.S.Binds = {}
        for _, fn in pairs(LL.BindRefreshers) do pcall(fn) end
        LL.MarkDirty(); LL.Notify("Бинды сброшены")
    end, {textColor = COL.accent2})

    LL.Section(parent, "Floating Lock")
    LL.Toggle(parent, "Fix Floating Buttons",
        function() return LL.S.FloatingLock end,
        function(v)
            LL.S.FloatingLock = v
            LL.ApplyFloatingLock(); LL.MarkDirty()
            LL.Notify("Floating: "..(v and "LOCKED" or "FREE"))
        end)
    LL.Button(parent, "Сбросить позиции кнопок", function()
        LL.S.FloatingPos = {}
        LL.RepositionAllFloatingBtns()
        LL.MarkDirty(); LL.Notify("Позиции сброшены")
    end, {textColor = COL.accent2})

    LL.Section(parent, "Floating Buttons")
    LL.Toggle(parent, "Aimbot Button",
        function() return LL.S.MobileBtns.Aimbot == true end,
        function(v) LL.S.MobileBtns.Aimbot = v; LL.ToggleMobileBtn("Aimbot", v) end)
    LL.Toggle(parent, "Fly Button",
        function() return LL.S.MobileBtns.Fly == true end,
        function(v) LL.S.MobileBtns.Fly = v; LL.ToggleMobileBtn("Fly", v) end)
    LL.Toggle(parent, "XNEO MobileFly Button",
        function() return LL.S.MobileBtns.MobileFly == true end,
        function(v) LL.S.MobileBtns.MobileFly = v; LL.ToggleMobileBtn("MobileFly", v) end)
    LL.Toggle(parent, "Zero Gravity Button",
        function() return LL.S.MobileBtns.ZeroGravity == true end,
        function(v) LL.S.MobileBtns.ZeroGravity = v; LL.ToggleMobileBtn("ZeroGravity", v) end)
    LL.Toggle(parent, "Noclip Button",
        function() return LL.S.MobileBtns.Noclip == true end,
        function(v) LL.S.MobileBtns.Noclip = v; LL.ToggleMobileBtn("Noclip", v) end)
    LL.Toggle(parent, "Anti Fling Button",
        function() return LL.S.MobileBtns.AntiFling == true end,
        function(v) LL.S.MobileBtns.AntiFling = v; LL.ToggleMobileBtn("AntiFling", v) end)
    LL.Toggle(parent, "ESP Button",
        function() return LL.S.MobileBtns.ESP == true end,
        function(v) LL.S.MobileBtns.ESP = v; LL.ToggleMobileBtn("ESP", v) end)
    LL.Toggle(parent, "Hitbox Button",
        function() return LL.S.MobileBtns.Hitbox == true end,
        function(v) LL.S.MobileBtns.Hitbox = v; LL.ToggleMobileBtn("Hitbox", v) end)
end)
-- ============================================================
-- HITBOX LOGIC
-- ============================================================
function LL.createHitboxPart(character, name)
    local p = Instance.new("Part")
    p.Name = "TimonHub_HB_" .. name
    p.Anchored = false
    p.CanCollide = false
    p.CanQuery = true
    p.CanTouch = false
    p.Massless = true
    p.Material = Enum.Material.SmoothPlastic
    p.Color = LL.S.Hitbox.Color
    p.Transparency = LL.S.Hitbox.Transparency
    p.Size = Vector3.new(1, 1, 1)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = character
    return p
end

function LL.weldTo(part, target)
    if not part or not target then return end
    local existing = part:FindFirstChild("TimonHub_Weld")
    if existing and existing.Part0 == target then return end
    if existing then existing:Destroy() end
    part.CFrame = target.CFrame
    local w = Instance.new("WeldConstraint")
    w.Name = "TimonHub_Weld"
    w.Part0 = target
    w.Part1 = part
    w.Parent = part
end

function LL.ApplyHitbox(pl)
    if pl == LP or not pl.Character then return end
    local ch = pl.Character
    local entry = LL.HitboxParts[pl]
    if not entry then entry = {}; LL.HitboxParts[pl] = entry end
    if LL.S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = LL.createHitboxPart(ch, "Head")
        end
        local head = ch:FindFirstChild("Head")
        if head then
            entry.head.Size = Vector3.new(LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize)
            entry.head.Color = LL.S.Hitbox.Color
            entry.head.Transparency = LL.S.Hitbox.Transparency
            LL.weldTo(entry.head, head)
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil
    end
    if LL.S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = LL.createHitboxPart(ch, "Body")
        end
        local torso = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        if torso then
            entry.body.Size = Vector3.new(LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize)
            entry.body.Color = LL.S.Hitbox.Color
            entry.body.Transparency = LL.S.Hitbox.Transparency
            LL.weldTo(entry.body, torso)
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil
    end
end

function LL.RemoveHitboxFor(pl)
    local e = LL.HitboxParts[pl]
    if e then
        if e.head and e.head.Parent then e.head:Destroy() end
        if e.body and e.body.Parent then e.body:Destroy() end
        LL.HitboxParts[pl] = nil
    end
end

function LL.ClearAllHitboxes()
    local keys = {}
    for pl in pairs(LL.HitboxParts) do keys[#keys+1] = pl end
    for _, pl in ipairs(keys) do LL.RemoveHitboxFor(pl) end
end

function LL.RefreshHitboxes()
    LL.ClearAllHitboxes()
    if LL.S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
    end
    if LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport then
        for model in pairs(LL.NPCHitboxes) do pcall(LL.RemoveNPCHitbox, model) end
        for model in pairs(LL.NPCCache) do pcall(LL.ApplyNPCHitbox, model) end
    end
end

LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(0.2)
        if LL.S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
        end
    end
end))

-- ============================================================
-- NPC CACHE (инкрементальный)
-- ============================================================
function LL.isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

function LL.isNPC(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if LL.isPlayerCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") and not model:FindFirstChild("Torso") then
        return false
    end
    return true
end

function LL.scanWorkspaceOnce()
    local newCache = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and LL.isNPC(child) then
            newCache[child] = true
        elseif child:IsA("Folder") or child:IsA("Model") then
            local ok, sub = pcall(function() return child:GetChildren() end)
            if ok and sub then
                for _, sc in ipairs(sub) do
                    if sc:IsA("Model") and LL.isNPC(sc) then newCache[sc] = true end
                end
            end
        end
    end
    LL.NPCCache = newCache
end

function LL.refreshNPCCache()
    LL.scanWorkspaceOnce()
end

LL.trackConn(Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and LL.isNPC(d) then
        LL.NPCCache[d] = true
    end
end))
LL.trackConn(Workspace.DescendantRemoving:Connect(function(d)
    if d:IsA("Model") then LL.NPCCache[d] = nil end
end))

function LL.ApplyNPCHitbox(model)
    if not model or not model.Parent then return end
    if LL.isPlayerCharacter(model) then return end
    if not (LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport) then
        LL.RemoveNPCHitbox(model); return
    end
    local entry = LL.NPCHitboxes[model]
    if not entry then entry = {}; LL.NPCHitboxes[model] = entry end
    if LL.S.Hitbox.HeadEnabled then
        if not entry.head or not entry.head.Parent then
            entry.head = LL.createHitboxPart(model, "NPCHead")
        end
        local head = model:FindFirstChild("Head")
        if head then
            entry.head.Size = Vector3.new(LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize)
            entry.head.Color = LL.S.Hitbox.Color
            entry.head.Transparency = LL.S.Hitbox.Transparency
            LL.weldTo(entry.head, head)
        end
    elseif entry.head then
        entry.head:Destroy(); entry.head = nil
    end
    if LL.S.Hitbox.BodyEnabled then
        if not entry.body or not entry.body.Parent then
            entry.body = LL.createHitboxPart(model, "NPCBody")
        end
        local torso = model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("HumanoidRootPart")
        if torso then
            entry.body.Size = Vector3.new(LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize)
            entry.body.Color = LL.S.Hitbox.Color
            entry.body.Transparency = LL.S.Hitbox.Transparency
            LL.weldTo(entry.body, torso)
        end
    elseif entry.body then
        entry.body:Destroy(); entry.body = nil
    end
end

function LL.RemoveNPCHitbox(model)
    local e = LL.NPCHitboxes[model]
    if e then
        if e.head and e.head.Parent then e.head:Destroy() end
        if e.body and e.body.Parent then e.body:Destroy() end
        LL.NPCHitboxes[model] = nil
    end
end

function LL.ClearAllNPCHitboxes()
    local keys = {}
    for m in pairs(LL.NPCHitboxes) do keys[#keys+1] = m end
    for _, m in ipairs(keys) do LL.RemoveNPCHitbox(m) end
end

LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(1)
        if LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport then
            for model in pairs(LL.NPCCache) do pcall(LL.ApplyNPCHitbox, model) end
            for model in pairs(LL.NPCHitboxes) do
                if not model.Parent or not LL.NPCCache[model] then LL.RemoveNPCHitbox(model) end
            end
        elseif next(LL.NPCHitboxes) then
            LL.ClearAllNPCHitboxes()
        end
    end
end))

-- ============================================================
-- DRAWING
-- ============================================================
LL.DRAW_AVAILABLE = (typeof(Drawing) == "table")
LL.fovCircle = nil
LL.aimBeam = nil
LL.hitboxBox = nil
LL.tracers = {}

if LL.DRAW_AVAILABLE then
    pcall(function()
        LL.fovCircle = Drawing.new("Circle")
        LL.fovCircle.Visible = false
        LL.fovCircle.Thickness = 1.5
        LL.fovCircle.Color = LL.S.Aimbot.FOVColor
        LL.fovCircle.Transparency = 0.7

        LL.aimBeam = Drawing.new("Line")
        LL.aimBeam.Visible = false
        LL.aimBeam.Thickness = 1.5
        LL.aimBeam.Color = LL.S.Aimbot.TracerColor
        LL.aimBeam.Transparency = 0.5

        LL.hitboxBox = Drawing.new("Square")
        LL.hitboxBox.Visible = false
        LL.hitboxBox.Thickness = 1
        LL.hitboxBox.Color = Color3.fromRGB(255, 80, 120)
        LL.hitboxBox.Transparency = 0.7
        LL.hitboxBox.Filled = false
    end)
end

function LL.applyHighlight(hl)
    hl.FillColor = LL.S.ESP.FillColor
    hl.FillTransparency = LL.S.ESP.FillTransparency
    hl.OutlineColor = LL.S.ESP.OutlineColor
    hl.OutlineTransparency = LL.S.ESP.OutlineTransparency
    hl.DepthMode = LL.S.ESP.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded
end

function LL.RefreshESPColors()
    for _, d in pairs(LL.ESPObjs) do if d.hl then LL.applyHighlight(d.hl) end end
    for _, d in pairs(LL.NPCESPObjs) do if d.hl then LL.applyHighlight(d.hl) end end
    if LL.fovCircle then LL.fovCircle.Color = LL.S.Aimbot.FOVColor end
    if LL.aimBeam then LL.aimBeam.Color = LL.S.Aimbot.TracerColor end
end

function LL.makeText()
    if not LL.DRAW_AVAILABLE then return nil end
    local t
    pcall(function()
        t = Drawing.new("Text")
        t.Visible = false
        t.Center = true
        t.Outline = true
        t.OutlineColor = Color3.fromRGB(0,0,0)
        t.Size = LL.S.ESP.NickSize or 15
        t.Color = LL.S.ESP.NickColor
        pcall(function()
            t.Font = (Drawing.Fonts and Drawing.Fonts.System) or 1
        end)
    end)
    return t
end

function LL.makeHPBar()
    if not LL.DRAW_AVAILABLE then return nil, nil end
    local bg, fill
    pcall(function()
        bg = Drawing.new("Square")
        bg.Visible = false
        bg.Filled = true
        bg.Thickness = 1
        bg.Color = Color3.fromRGB(0,0,0)
        bg.Transparency = 0.35
        fill = Drawing.new("Square")
        fill.Visible = false
        fill.Filled = true
        fill.Thickness = 0
        fill.Color = Color3.fromRGB(0,255,0)
        fill.Transparency = 1
    end)
    return bg, fill
end

function LL.makeTracer()
    if not LL.DRAW_AVAILABLE then return nil end
    local l
    pcall(function()
        l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1.2
        l.Color = LL.S.ESP.TracerFrom
        l.Transparency = 0.6
    end)
    return l
end

function LL.refreshEspCache(d)
    local c = d.player and d.player.Character
    d.cacheChar = c
    d.cacheHead = c and c:FindFirstChild("Head") or nil
    d.cacheRoot = c and c:FindFirstChild("HumanoidRootPart") or nil
    d.cacheHum = c and c:FindFirstChildOfClass("Humanoid") or nil
end

function LL.CreateESP(pl)
    if pl == LP or LL.ESPObjs[pl] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TimonHub_HL_" .. pl.Name
    LL.applyHighlight(hl)
    if pl.Character then hl.Adornee = pl.Character end
    hl.Parent = ScreenGui
    local nm = LL.makeText()
    local ds = LL.makeText()
    if ds then ds.Size = 12; ds.Color = Color3.fromRGB(230,230,230) end
    local hpBg, hpFill = LL.makeHPBar()
    local tracer = LL.makeTracer()
    local d = {hl=hl, name=nm, dist=ds, hpBg=hpBg, hpFill=hpFill, tracer=tracer, player=pl}
    LL.refreshEspCache(d)
    LL.ESPObjs[pl] = d
    if LL.espCharConn[pl] then pcall(function() LL.espCharConn[pl]:Disconnect() end) end
    LL.espCharConn[pl] = pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        local e = LL.ESPObjs[pl]
        if not e then return end
        local c = pl.Character
        if c and e.hl then e.hl.Adornee = c; e.hl.Enabled = true end
        LL.refreshEspCache(e)
    end)
end

function LL.RemoveESP(pl)
    local e = LL.ESPObjs[pl]
    if e then
        pcall(function() e.hl:Destroy() end)
        if e.name then pcall(function() e.name:Remove() end) end
        if e.dist then pcall(function() e.dist:Remove() end) end
        if e.hpBg then pcall(function() e.hpBg:Remove() end) end
        if e.hpFill then pcall(function() e.hpFill:Remove() end) end
        if e.tracer then pcall(function() e.tracer:Remove() end) end
        LL.ESPObjs[pl] = nil
    end
    if LL.espCharConn[pl] then
        pcall(function() LL.espCharConn[pl]:Disconnect() end)
        LL.espCharConn[pl] = nil
    end
end

function LL.CreateNPCESP(model)
    if not model or LL.NPCESPObjs[model] or LL.isPlayerCharacter(model) then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TimonHub_NPC_HL"
    LL.applyHighlight(hl)
    hl.Adornee = model
    hl.Parent = ScreenGui
    local nm = LL.makeText()
    local ds = LL.makeText()
    if ds then ds.Size = 12; ds.Color = Color3.fromRGB(230,230,230) end
    local hpBg, hpFill = LL.makeHPBar()
    LL.NPCESPObjs[model] = {hl=hl, name=nm, dist=ds, hpBg=hpBg, hpFill=hpFill, model=model}
end

function LL.RemoveNPCESP(model)
    local e = LL.NPCESPObjs[model]
    if e then
        pcall(function() e.hl:Destroy() end)
        if e.name then pcall(function() e.name:Remove() end) end
        if e.dist then pcall(function() e.dist:Remove() end) end
        if e.hpBg then pcall(function() e.hpBg:Remove() end) end
        if e.hpFill then pcall(function() e.hpFill:Remove() end) end
        LL.NPCESPObjs[model] = nil
    end
end

LL.trackConn(Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        if LL.S.ESP.Enabled then LL.CreateESP(pl) end
    end)
end))
LL.trackConn(Players.PlayerRemoving:Connect(function(pl)
    LL.RemoveESP(pl)
    LL.RemoveHitboxFor(pl)
end))
-- ============================================================
-- AIMBOT
-- ============================================================
LL.StickyTarget = nil
LL.StickyTargetIsNPC = false
LL.aimHoldDown = false
LL.wasHoldActive = false

LL.tryMouseFn = nil
do
    pcall(function() if syn and syn.mousemoverel then LL.tryMouseFn = syn.mousemoverel; return end end)
    if not LL.tryMouseFn then
        pcall(function() if mousemoverel then LL.tryMouseFn = mousemoverel; return end end)
    end
    if not LL.tryMouseFn then
        pcall(function()
            if mouse and mouse.Move then
                LL.tryMouseFn = function(dx,dy) mouse.Move(mouse, dx, dy) end
            end
        end)
    end
    if not LL.tryMouseFn then
        pcall(function()
            if mouse and mouse.move then
                LL.tryMouseFn = function(dx,dy) mouse.move(dx, dy) end
            end
        end)
    end
end
LL.CURSOR_AIM_AVAILABLE = LL.tryMouseFn ~= nil

LL.wallCheckRayParams = RaycastParams.new()
LL.wallCheckRayParams.FilterType = Enum.RaycastFilterType.Exclude
LL.wallCheckRayParams.IgnoreWater = true

function LL.setupRayParams()
    local ignore = {Camera}
    if LL.Cache.Character then table.insert(ignore, LL.Cache.Character) end
    LL.wallCheckRayParams.FilterDescendantsInstances = ignore
end

function LL.IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local dist = dir.Magnitude
    if dist < 1 then return true end
    LL.setupRayParams()
    local remaining = dist
    local currentDir = dir
    for _ = 1, 4 do
        local res = Workspace:Raycast(origin, currentDir, LL.wallCheckRayParams)
        if not res then return true end
        local hit = res.Instance
        if hit == part then return true end
        local cur = hit
        local isHitbox = false
        while cur do
            if cur:IsA("Part") and cur.Name:sub(1, 12) == "TimonHub_HB_" then
                isHitbox = true; break
            end
            cur = cur.Parent
        end
        if not isHitbox then
            local walk = hit
            while walk do
                if walk == part or walk == part.Parent then return true end
                walk = walk.Parent
            end
            return false
        end
        local newOrigin = res.Position + currentDir.Unit * 0.1
        remaining = remaining - (newOrigin - origin).Magnitude
        origin = newOrigin
        currentDir = part.Position - origin
        if currentDir.Magnitude < 0.1 then return true end
    end
    return true
end

function LL.IsOnScreen(part)
    if not part then return false end
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    return onScreen and sp.Z > 0
end

function LL.GetLeadPos(part, origin)
    if not LL.S.Aimbot.PredictLead or LL.S.Aimbot.HitscanMode then return part.Position end
    local ch = part.Parent
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then return part.Position end
    local md = hum.MoveDirection
    local ws = hum.WalkSpeed
    local vel = Vector3.new(md.X*ws, part.Velocity.Y, md.Z*ws)
    if vel.Magnitude > 500 then vel = vel.Unit * 500 end
    local bs = math.max(LL.S.Aimbot.BulletSpeed, 1)
    local mult = LL.S.Aimbot.LeadMultiplier or 1.0
    local aimPos = part.Position
    for _ = 1, 3 do
        local t = (aimPos - origin).Magnitude / bs * mult
        aimPos = part.Position + vel * t
    end
    return aimPos
end

function LL.IsCursorAimActive()
    if LL.S.Aimbot.Mode ~= "Cursor" then return true end
    if not LL.S.Binds.AimbotHold then return true end
    if LL.aimHoldDown then return true end
    local ok, isDown = pcall(function() return UIS:IsKeyDown(LL.S.Binds.AimbotHold) end)
    if ok and isDown then return true end
    return false
end

function LL.FindTarget()
    local targetPlayers = LL.S.Aimbot.TargetPlayers
    local targetNPCs = LL.S.Aimbot.TargetNPCs
    if not targetPlayers and not targetNPCs then return nil end

    if LL.S.Aimbot.StickyLock and LL.StickyTarget then
        local isNPC = LL.StickyTargetIsNPC
        local part
        if isNPC then
            if LL.StickyTarget.Parent then
                local hum = LL.StickyTarget:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    part = LL.StickyTarget:FindFirstChild(LL.S.Aimbot.Part) or LL.StickyTarget:FindFirstChild("Head")
                end
            end
        else
            local ch = LL.StickyTarget.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    part = ch:FindFirstChild(LL.S.Aimbot.Part) or ch:FindFirstChild("Head")
                end
            end
        end
        if part and LL.IsOnScreen(part)
           and (not LL.S.Aimbot.WallCheck or LL.IsVisible(part)) then
            return part
        end
        LL.StickyTarget = nil; LL.StickyTargetIsNPC = false
    end

    local target, targetIsNPC, bestScore = nil, false, math.huge
    local mode = LL.S.Aimbot.Mode
    local fovLimit, cmpPos
    if mode == "Cursor" then
        cmpPos = UIS:GetMouseLocation(); fovLimit = math.huge
    elseif mode == "Mobile" then
        cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovLimit = LL.S.Aimbot.MobileFOV
    else
        cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovLimit = LL.S.Aimbot.CameraFOV
    end
    local myHRP = LL.Cache.HRP
    local myPos = myHRP and myHRP.Position or Vector3.zero
    local dw = LL.S.Aimbot.DistanceWeight
    local wallCheck = LL.S.Aimbot.WallCheck
    local partName = LL.S.Aimbot.Part

    if targetPlayers then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            local ch = pl.Character
            if not ch then continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local part = ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
            if not part then continue end
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen or sp.Z <= 0 then continue end
            local pd = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
            if pd > fovLimit then continue end
            if wallCheck and not LL.IsVisible(part) then continue end
            local wd = (part.Position - myPos).Magnitude
            local score = pd + wd * dw
            if score < bestScore then
                bestScore = score; target = pl; targetIsNPC = false
            end
        end
    end

    if targetNPCs then
        for model in pairs(LL.NPCCache) do
            if not LL.isPlayerCharacter(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = model:FindFirstChild(partName) or model:FindFirstChild("Head")
                    if part then
                        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and sp.Z > 0 then
                            local pd = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
                            if pd <= fovLimit then
                                if not wallCheck or LL.IsVisible(part) then
                                    local wd = (part.Position - myPos).Magnitude
                                    local score = pd + wd * dw
                                    if score < bestScore then
                                        bestScore = score; target = model; targetIsNPC = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if LL.S.Aimbot.StickyLock then
        LL.StickyTarget = target; LL.StickyTargetIsNPC = targetIsNPC
    end
    if target then
        if targetIsNPC then
            return target:FindFirstChild(partName) or target:FindFirstChild("Head")
        else
            local ch = target.Character
            return ch and (ch:FindFirstChild(partName) or ch:FindFirstChild("Head")) or nil
        end
    end
    return nil
end

-- ============================================================
-- AIM RENDER STEP
-- ============================================================
RunService:BindToRenderStep("TIMON_AIM", Enum.RenderPriority.Camera.Value + 1, function()
    if not getgenv().TIMON_LOADED then return end
    if LL.S.Aimbot.ShowFOV and LL.S.Aimbot.Mode ~= "Cursor" and LL.fovCircle then
        LL.fovCircle.Visible = true
        LL.fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        LL.fovCircle.Radius = (LL.S.Aimbot.Mode == "Mobile") and LL.S.Aimbot.MobileFOV or LL.S.Aimbot.CameraFOV
        LL.fovCircle.Color = LL.S.Aimbot.FOVColor
    elseif LL.fovCircle then
        LL.fovCircle.Visible = false
    end
    if not LL.S.Aimbot.Enabled then
        LL.StickyTarget = nil; LL.StickyTargetIsNPC = false
        LL.wasHoldActive = false
        if LL.aimBeam then LL.aimBeam.Visible = false end
        if LL.hitboxBox then LL.hitboxBox.Visible = false end
        return
    end
    if not LL.IsCursorAimActive() then
        LL.StickyTarget = nil; LL.StickyTargetIsNPC = false
        LL.wasHoldActive = false
        if LL.aimBeam then LL.aimBeam.Visible = false end
        if LL.hitboxBox then LL.hitboxBox.Visible = false end
        return
    end

    local t = LL.FindTarget()
    LL.wasHoldActive = true

    if not t then
        if LL.aimBeam then LL.aimBeam.Visible = false end
        if LL.hitboxBox then LL.hitboxBox.Visible = false end
        return
    end

    local aimPos = LL.GetLeadPos(t, Camera.CFrame.Position)
    local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
    if not onScreen or sp.Z <= 0 then
        if LL.aimBeam then LL.aimBeam.Visible = false end
        if LL.hitboxBox then LL.hitboxBox.Visible = false end
        return
    end

    if LL.S.Aimbot.HitboxVisualizer and LL.hitboxBox then
        local size = t.Size
        local cf = t.CFrame
        local top = Camera:WorldToViewportPoint(cf.Position + Vector3.new(0, size.Y/2, 0))
        local bottom = Camera:WorldToViewportPoint(cf.Position - Vector3.new(0, size.Y/2, 0))
        if top.Z > 0 and bottom.Z > 0 then
            local height = math.abs(top.Y - bottom.Y)
            local width = height * 0.6
            LL.hitboxBox.Size = Vector2.new(width, height)
            LL.hitboxBox.Position = Vector2.new(top.X - width/2, top.Y)
            LL.hitboxBox.Visible = true
        else
            LL.hitboxBox.Visible = false
        end
    elseif LL.hitboxBox then
        LL.hitboxBox.Visible = false
    end

    if LL.S.Aimbot.AimAssistBeam and LL.aimBeam then
        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if LL.S.Aimbot.Mode == "Cursor" then screenCenter = UIS:GetMouseLocation() end
        LL.aimBeam.From = screenCenter
        LL.aimBeam.To = Vector2.new(sp.X, sp.Y)
        LL.aimBeam.Color = LL.S.Aimbot.TracerColor
        LL.aimBeam.Visible = true
    elseif LL.aimBeam then
        LL.aimBeam.Visible = false
    end

    if LL.S.Aimbot.Mode == "Cursor" and LL.CURSOR_AIM_AVAILABLE then
        local mp = UIS:GetMouseLocation()
        local dx = (sp.X - mp.X) * LL.S.Aimbot.Smooth
        local dy = (sp.Y - mp.Y) * LL.S.Aimbot.Smooth
        if LL.S.Aimbot.JitterEnabled and LL.S.Aimbot.Jitter > 0 then
            dx += (math.random()*2-1) * LL.S.Aimbot.Jitter
            dy += (math.random()*2-1) * LL.S.Aimbot.Jitter
        end
        if LL.S.Aimbot.MicroAdjust and LL.S.Aimbot.MicroAdjustAmount > 0 then
            dx += (math.random()*2-1) * LL.S.Aimbot.MicroAdjustAmount
            dy += (math.random()*2-1) * LL.S.Aimbot.MicroAdjustAmount
        end
        local ok = pcall(LL.tryMouseFn, dx, dy)
        if ok then return end
    end

    local lookCF = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, LL.S.Aimbot.Smooth)
end)

-- ============================================================
-- XNEO MOBILE FLY
-- ============================================================
function LL.xneoStartTpWalking()
    local gen = (LL.Xneo.tpGen or 0) + 1
    LL.Xneo.tpGen = gen
    LL.Xneo.tpWalking = true
    for _ = 1, math.max(LL.Xneo.speeds, 1) do
        LL.trackThread(task.spawn(function()
            while getgenv().TIMON_LOADED and LL.Xneo.tpWalking and LL.Xneo.tpGen == gen do
                task.wait()
                local c = LL.Cache.Character
                local h = LL.Cache.Humanoid
                if not c or not h or h.Health <= 0 then break end
                if h.MoveDirection.Magnitude > 0 then c:TranslateBy(h.MoveDirection) end
            end
        end))
    end
end

function LL.xneoStopTpWalking()
    LL.Xneo.tpWalking = false
    LL.Xneo.tpGen = (LL.Xneo.tpGen or 0) + 1
end

function LL.xneoTurnOffFlight()
    local chr = LL.Cache.Character
    local hum = LL.Cache.Humanoid
    LL.Xneo.nowe = false
    LL.xneoStopTpWalking()
    if LL.Xneo.flyLoopConn then
        pcall(function() LL.Xneo.flyLoopConn:Disconnect() end)
        LL.Xneo.flyLoopConn = nil
    end
    if LL.Xneo.bg then pcall(function() LL.Xneo.bg:Destroy() end); LL.Xneo.bg = nil end
    if LL.Xneo.bv then pcall(function() LL.Xneo.bv:Destroy() end); LL.Xneo.bv = nil end
    if chr and hum then
        for _, st in ipairs(LL.XNEO_STATES) do
            pcall(function() hum:SetStateEnabled(st, true) end)
        end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        hum.PlatformStand = false
        local animate = chr:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end
end

function LL.xneoTurnOnFlight()
    local chr = LL.Cache.Character
    local hum = LL.Cache.Humanoid
    if not chr or not hum then return end
    if LL.S.Player.Fly then LL.S.Player.Fly = false; LL.RefreshAll() end
    LL.Xneo.nowe = true
    LL.xneoStartTpWalking()
    local animate = chr:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() track:AdjustSpeed(0) end)
    end
    for _, st in ipairs(LL.XNEO_STATES) do
        pcall(function() hum:SetStateEnabled(st, false) end)
    end
    local part = (hum.RigType == Enum.HumanoidRigType.R6)
        and chr:FindFirstChild("Torso") or chr:FindFirstChild("UpperTorso")
    if part then
        local al = Instance.new("AlignOrientation")
        al.Mode = Enum.OrientationAlignmentMode.OneAttachment
        al.MaxTorque = math.huge
        al.Responsiveness = 200
        local att = Instance.new("Attachment")
        att.Parent = part
        al.Attachment0 = att
        al.Parent = part
        LL.Xneo.bg = al
        local lv = Instance.new("LinearVelocity")
        lv.MaxForce = math.huge
        lv.VectorVelocity = Vector3.new(0, 0.1, 0)
        lv.Attachment0 = att
        lv.Parent = part
        LL.Xneo.bv = lv
    end
    hum.PlatformStand = true
    LL.Xneo.flyLoopConn = RunService.RenderStepped:Connect(function()
        if not getgenv().TIMON_LOADED or not LL.Xneo.nowe then return end
        if LL.Xneo.bg and LL.Xneo.bg.Parent and LL.Xneo.bg.Attachment0 then
            pcall(function()
                LL.Xneo.bg.Attachment0.WorldCFrame = Camera.CFrame
            end)
        end
        if LL.Xneo.bv and LL.Xneo.bv.Parent then
            pcall(function() LL.Xneo.bv.VectorVelocity = Vector3.new(0, 0.1, 0) end)
        end
    end)
end

function LL.launchXneoFlyGUI()
    if LL.Xneo.gui then return end
    local main = Instance.new("ScreenGui")
    main.Name = "XneoFlyGui"
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false
    main.IgnoreGuiInset = true
    pcall(function() main.Parent = CoreGui end)
    if not main.Parent then main.Parent = LP:WaitForChild("PlayerGui") end
    LL.Xneo.gui = main

    local Frame = Instance.new("Frame")
    Frame.Parent = main
    Frame.BackgroundColor3 = COL.bg2
    Frame.BorderColor3 = COL.accent
    Frame.Position = UDim2.new(0.10, 0, 0.38, 0)
    Frame.Size = UDim2.new(0, 210, 0, 64)
    Frame.Active = true
    Frame.Draggable = true
    LL.corner(Frame, 12); LL.stroke(Frame, COL.accent, 1.5)
    LL.gradient(Frame, COL.accent, COL.accent2, 25)

    local function miniBtn(parent, text, color, pos, size)
        local b = Instance.new("TextButton")
        b.Parent = parent
        b.BackgroundColor3 = color
        b.Size = size or UDim2.new(0, 46, 0, 28)
        b.Position = pos
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextColor3 = Color3.fromRGB(0,0,0)
        b.TextSize = 12
        b.AutoButtonColor = false
        LL.corner(b, 8)
        return b
    end

    local title = Instance.new("TextLabel")
    title.Parent = Frame
    title.BackgroundColor3 = COL.accent
    title.Position = UDim2.new(0, 100, 0, 4)
    title.Size = UDim2.new(0, 100, 0, 26)
    title.Font = Enum.Font.GothamBold
    title.Text = "XNEO V3"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 12
    LL.corner(title, 8)

    local up    = miniBtn(Frame, "UP", Color3.fromRGB(120,255,180), UDim2.new(0, 4, 0, 4))
    local down  = miniBtn(Frame, "DN", Color3.fromRGB(200,255,120), UDim2.new(0, 4, 0, 34))
    local plus  = miniBtn(Frame, "+", Color3.fromRGB(160,160,255), UDim2.new(0, 54, 0, 4))
    local mine  = miniBtn(Frame, "-", Color3.fromRGB(120,220,255), UDim2.new(0, 54, 0, 34))
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Parent = Frame
    speedLbl.BackgroundColor3 = Color3.fromRGB(255,140,80)
    speedLbl.Position = UDim2.new(0, 104, 0, 34)
    speedLbl.Size = UDim2.new(0, 40, 0, 26)
    speedLbl.Font = Enum.Font.GothamBold
    speedLbl.Text = tostring(LL.Xneo.speeds)
    speedLbl.TextColor3 = Color3.fromRGB(0,0,0)
    speedLbl.TextSize = 13
    LL.corner(speedLbl, 8)

    local onof = miniBtn(Frame, "FLY", Color3.fromRGB(255,220,80), UDim2.new(0, 152, 0, 34), UDim2.new(0, 52, 0, 26))
    local close = miniBtn(Frame, "X", Color3.fromRGB(255,90,120), UDim2.new(0, 152, 0, 4), UDim2.new(0, 52, 0, 26))

    onof.MouseButton1Click:Connect(function()
        if LL.Xneo.nowe then LL.xneoTurnOffFlight() else LL.xneoTurnOnFlight() end
    end)

    local upHeld = false
    up.MouseButton1Down:Connect(function() upHeld = true end)
    up.MouseButton1Up:Connect(function() upHeld = false end)
    up.MouseLeave:Connect(function() upHeld = false end)
    LL.trackThread(task.spawn(function()
        while getgenv().TIMON_LOADED and LL.Xneo.gui do
            task.wait()
            if upHeld then
                local hrp = LL.Cache.HRP
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
            end
        end
    end))
    local downHeld = false
    down.MouseButton1Down:Connect(function() downHeld = true end)
    down.MouseButton1Up:Connect(function() downHeld = false end)
    down.MouseLeave:Connect(function() downHeld = false end)
    LL.trackThread(task.spawn(function()
        while getgenv().TIMON_LOADED and LL.Xneo.gui do
            task.wait()
            if downHeld then
                local hrp = LL.Cache.HRP
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
            end
        end
    end))

    plus.MouseButton1Click:Connect(function()
        LL.Xneo.speeds = LL.Xneo.speeds + 1
        speedLbl.Text = tostring(LL.Xneo.speeds)
        if LL.Xneo.nowe then LL.xneoStartTpWalking() end
    end)
    mine.MouseButton1Click:Connect(function()
        if LL.Xneo.speeds > 1 then
            LL.Xneo.speeds = LL.Xneo.speeds - 1
            speedLbl.Text = tostring(LL.Xneo.speeds)
            if LL.Xneo.nowe then LL.xneoStartTpWalking() end
        end
    end)

    close.MouseButton1Click:Connect(function() LL.closeXneoFlyGUI() end)

    LL.S.Player.MobileFly = true
    LL.S.MobileBtns.MobileFly = true
    LL.RefreshAll(); LL.MarkDirty()
end

function LL.closeXneoFlyGUI()
    LL.xneoTurnOffFlight()
    if LL.Xneo.gui then
        pcall(function() LL.Xneo.gui:Destroy() end)
        LL.Xneo.gui = nil
    end
    LL.Xneo.speeds = 1
    LL.S.Player.MobileFly = false
    LL.S.MobileBtns.MobileFly = false
    LL.RefreshAll(); LL.MarkDirty()
end

-- ============================================================
-- FLOATING BUTTONS
-- ============================================================
function LL.saveBtnPos(id, pos)
    LL.S.FloatingPos[id] = {
        xS = pos.X.Scale, xO = pos.X.Offset,
        yS = pos.Y.Scale, yO = pos.Y.Offset,
    }
end
function LL.loadBtnPos(id, defaultPos)
    local p = LL.S.FloatingPos[id]
    if p then return UDim2.new(p.xS or 0, p.xO or 0, p.yS or 0, p.yO or 0) end
    return defaultPos
end

function LL.MakeDraggableLockable(frame, dragBar, id, defaultPos)
    local dragging, dragStart, startPos
    dragBar.InputBegan:Connect(function(input)
        if LL.S.FloatingLock then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    LL.trackConn(UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if LL.S.FloatingLock then dragging = false; return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,
                startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    LL.trackConn(UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if id then LL.saveBtnPos(id, frame.Position); LL.MarkDirty() end
        end
    end))
    if id then
        LL.AllFloating[id] = {btn = frame, defaultPos = defaultPos or frame.Position}
    end
end

function LL.RepositionAllFloatingBtns()
    for id, entry in pairs(LL.AllFloating) do
        if entry.btn and entry.btn.Parent then
            entry.btn.Position = LL.loadBtnPos(id, entry.defaultPos)
        end
    end
end

function LL.ApplyFloatingLock()
    for _, entry in pairs(LL.AllFloating) do
        local b = entry.btn
        if b and b.Parent then
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then
                s.Color = LL.S.FloatingLock and COL.green or COL.accent2
                s.Thickness = 2
            end
        end
    end
end

function LL.ToggleMobileBtn(action, show)
    if LL.MobileButtons[action] then
        if LL.AllFloating[action] then LL.AllFloating[action] = nil end
        LL.MobileButtons[action]:Destroy(); LL.MobileButtons[action] = nil
    end
    if not show then return end
    LL.MOBILE_POS_INDEX = LL.MOBILE_POS_INDEX + 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 58, 0, 58)
    local defaultPos = UDim2.new(0, 20, 0, 120 + (LL.MOBILE_POS_INDEX - 1) * 68)
    b.Position = LL.loadBtnPos(action, defaultPos)
    b.BackgroundColor3 = COL.bg2
    b.BackgroundTransparency = 0.1
    b.TextColor3 = COL.accent2
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    local LABEL = {
        Aimbot="AIM", Fly="FLY", MobileFly="XNEO", ZeroGravity="GRAV",
        Noclip="NOCLIP", AntiFling="AFLNG", InfiniteJump="IJMP",
        ESP="ESP", Hitbox="HITBX"
    }
    b.Text = LABEL[action] or action
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = ScreenGui; LL.corner(b, 29)
    local s = LL.stroke(b, COL.accent2, 2)
    if LL.S.FloatingLock then s.Color = COL.green end
    LL.MakeDraggableLockable(b, b, action, defaultPos)
    local function activeState()
        if action == "Aimbot" then return LL.S.Aimbot.Enabled
        elseif action == "ESP" then return LL.S.ESP.Enabled
        elseif action == "Hitbox" then return LL.S.Hitbox.Enabled
        elseif action == "Fly" then return LL.S.Player.Fly
        elseif action == "MobileFly" then return LL.Xneo.gui ~= nil
        elseif action == "ZeroGravity" then return LL.S.Player.ZeroGravity
        elseif action == "Noclip" then return LL.S.Player.Noclip
        elseif action == "InfiniteJump" then return LL.S.Player.InfiniteJump
        elseif action == "AntiFling" then return LL.S.Troll.AntiFling
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
    paint(); LL.AddRefresh(paint)
    b.MouseButton1Click:Connect(function()
        if LL.Actions[action] then LL.Actions[action]() end
        paint()
    end)
    LL.MobileButtons[action] = b
end
-- ============================================================
-- ACTIONS
-- ============================================================
LL.Actions.Aimbot = function()
    LL.S.Aimbot.Enabled = not LL.S.Aimbot.Enabled; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("Aimbot: "..tostring(LL.S.Aimbot.Enabled))
end
LL.Actions.ESP = function()
    LL.S.ESP.Enabled = not LL.S.ESP.Enabled; LL.RefreshAll(); LL.MarkDirty()
    if LL.S.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then LL.CreateESP(p) end
        end
    else
        for p in pairs(LL.ESPObjs) do LL.RemoveESP(p) end
    end
    LL.Notify("ESP: "..tostring(LL.S.ESP.Enabled))
end
LL.Actions.Hitbox = function()
    LL.S.Hitbox.Enabled = not LL.S.Hitbox.Enabled; LL.RefreshAll(); LL.MarkDirty()
    if LL.S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
    else LL.ClearAllHitboxes(); LL.ClearAllNPCHitboxes() end
    LL.Notify("Hitbox: "..tostring(LL.S.Hitbox.Enabled))
end
LL.Actions.Fly = function()
    if not LL.S.Player.Fly and LL.Xneo.nowe then LL.closeXneoFlyGUI() end
    LL.S.Player.Fly = not LL.S.Player.Fly; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("Fly: "..tostring(LL.S.Player.Fly))
end
LL.Actions.MobileFly = function()
    if LL.Xneo.gui then LL.closeXneoFlyGUI() else LL.launchXneoFlyGUI() end
end
LL.Actions.ZeroGravity = function()
    LL.S.Player.ZeroGravity = not LL.S.Player.ZeroGravity
    LL.applyGravityState(); LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("ZeroG: "..tostring(LL.S.Player.ZeroGravity))
end
LL.Actions.Noclip = function()
    LL.S.Player.Noclip = not LL.S.Player.Noclip; LL.RefreshAll(); LL.MarkDirty()
    if not LL.S.Player.Noclip and LL.Cache.Character then
        for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    LL.Notify("Noclip: "..tostring(LL.S.Player.Noclip))
end
LL.Actions.InfiniteJump = function()
    LL.S.Player.InfiniteJump = not LL.S.Player.InfiniteJump; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("InfJump: "..tostring(LL.S.Player.InfiniteJump))
end
LL.Actions.AntiFling = function()
    LL.S.Troll.AntiFling = not LL.S.Troll.AntiFling; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("AntiFling: "..tostring(LL.S.Troll.AntiFling))
end
LL.Actions.SavePos = function()
    local hrp = LL.Cache.HRP
    if hrp then
        LL.S.Player.SavedPos = hrp.CFrame
        LL.MarkDirty()
        LL.Notify("Позиция сохранена")
    end
end
LL.Actions.LoadPos = function()
    local hrp = LL.Cache.HRP
    if hrp and LL.S.Player.SavedPos then
        hrp.CFrame = LL.S.Player.SavedPos
        LL.Notify("Позиция загружена")
    else LL.Notify("Нет позиции") end
end

-- ============================================================
-- OPEN BUTTON
-- ============================================================
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 54, 0, 54)
local openDefault = UDim2.new(0, 20, 1, -84)
OpenBtn.Position = LL.loadBtnPos("__OpenBtn", openDefault)
OpenBtn.BackgroundColor3 = COL.bg2
OpenBtn.BackgroundTransparency = 0.05
OpenBtn.TextColor3 = COL.accent2
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.Text = "T"
OpenBtn.BorderSizePixel = 0
OpenBtn.AutoButtonColor = false
OpenBtn.Parent = ScreenGui
LL.corner(OpenBtn, 27)
LL.stroke(OpenBtn, COL.accent2, 2)
LL.makeShadow(OpenBtn, 27, 0.6)
LL.MakeDraggableLockable(OpenBtn, OpenBtn, "__OpenBtn", openDefault)
OpenBtn.MouseEnter:Connect(function()
    Tween:Create(OpenBtn, LL.Anim.Fast, {BackgroundColor3 = COL.elem}):Play()
end)
OpenBtn.MouseLeave:Connect(function()
    Tween:Create(OpenBtn, LL.Anim.Fast, {BackgroundColor3 = COL.bg2}):Play()
end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============================================================
-- INPUT
-- ============================================================
LL.trackConn(UIS.InputBegan:Connect(function(input, gp)
    if not getgenv().TIMON_LOADED then return end
    if getgenv().TIMON_LISTENING then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = getgenv().TIMON_LISTENING
            getgenv().TIMON_LISTENING = nil
            LL.S.Binds[action] = input.KeyCode
            if LL.BindRefreshers[action] then LL.BindRefreshers[action]() end
            LL.MarkDirty()
            LL.Notify("Bind: "..action.." -> "..tostring(input.KeyCode):gsub("Enum.KeyCode.",""))
        end
        return
    end
    if LL.S.Binds.AimbotHold and input.KeyCode == LL.S.Binds.AimbotHold then
        LL.aimHoldDown = true; return
    end
    if input.KeyCode == LL.S.UI.GuiKeybind and not gp then
        Main.Visible = not Main.Visible
        return
    end
    if gp then return end
    for action, key in pairs(LL.S.Binds) do
        if action ~= "AimbotHold" and input.KeyCode == key and LL.Actions[action] then
            LL.Actions[action]()
        end
    end
end))

LL.trackConn(UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if LL.S.Binds.AimbotHold and input.KeyCode == LL.S.Binds.AimbotHold then
        LL.aimHoldDown = false
    end
end))

-- ============================================================
-- RENDER LOOP (single)
-- ============================================================
LL.FlyBV = nil
LL.FlyBG = nil
LL.SpinAV = nil
LL.effectAccum = 0
LL.EFFECT_INTERVAL = 1/30
LL.lazyFrame = 0

local function drawTracerLine(line, fromX, fromY, toX, toY, fromColor, toColor)
    if not line then return end
    line.From = Vector2.new(fromX, fromY)
    line.To = Vector2.new(toX, toY)
    line.Color = fromColor
    line.Visible = true
end

LL.trackConn(RunService.RenderStepped:Connect(function(dt)
    if not getgenv().TIMON_LOADED then return end
    local ch = LL.Cache.Character
    local hrp = LL.Cache.HRP
    local hum = LL.Cache.Humanoid

    -- PC Fly
    if LL.S.Player.Fly and not LL.Xneo.nowe and hrp then
        if not LL.FlyBV then
            local att = hrp:FindFirstChild("TimonFlyAtt") or Instance.new("Attachment")
            att.Name = "TimonFlyAtt"; att.Parent = hrp
            local lv = Instance.new("LinearVelocity")
            lv.MaxForce = math.huge
            lv.Attachment0 = att
            lv.Parent = hrp
            LL.FlyBV = lv
        end
        if not LL.FlyBG then
            local att = hrp:FindFirstChild("TimonFlyAtt") or Instance.new("Attachment")
            att.Name = "TimonFlyAtt"; att.Parent = hrp
            local al = Instance.new("AlignOrientation")
            al.Mode = Enum.OrientationAlignmentMode.OneAttachment
            al.MaxTorque = math.huge
            al.Responsiveness = 200
            al.Attachment0 = att
            al.Parent = hrp
            LL.FlyBG = al
        end
        local dir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        pcall(function() LL.FlyBV.VectorVelocity = dir * LL.S.Player.FlySpeed end)
        pcall(function() LL.FlyBG.CFrame = Camera.CFrame end)
    else
        if LL.FlyBV then pcall(function() LL.FlyBV:Destroy() end); LL.FlyBV = nil end
        if LL.FlyBG then pcall(function() LL.FlyBG:Destroy() end); LL.FlyBG = nil end
        if hrp then
            local att = hrp:FindFirstChild("TimonFlyAtt")
            if att then att:Destroy() end
        end
    end

    -- Noclip / WalkSpeed / JumpPower (каждый кадр — дёшево)
    if hum then
        if LL.S.Player.WalkSpeedEnabled then hum.WalkSpeed = LL.S.Player.WalkSpeed end
        if LL.S.Player.JumpPowerEnabled then hum.JumpPower = LL.S.Player.JumpPower end
        if LL.S.Player.Noclip and ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end

    -- ESP / Tracer
    LL.lazyFrame = LL.lazyFrame + 1
    local skipESP = LL.S.Player.LazyMode and (LL.lazyFrame % 2 == 0)

    if not skipESP and LL.S.ESP.Enabled then
        local camPos = Camera.CFrame.Position
        local vp = Camera.ViewportSize
        for _, d in pairs(LL.ESPObjs) do
            local c = d.player.Character
            if c ~= d.cacheChar then
                LL.refreshEspCache(d)
                if d.hl and c then d.hl.Adornee = c end
            end
            if not c or not d.cacheHead or not d.cacheRoot then
                if d.name then d.name.Visible = false end
                if d.dist then d.dist.Visible = false end
                if d.hpBg then d.hpBg.Visible = false end
                if d.hpFill then d.hpFill.Visible = false end
                if d.tracer then d.tracer.Visible = false end
                if d.hl then d.hl.Enabled = false end
                continue
            end
            local dist = (camPos - d.cacheHead.Position).Magnitude
            if dist > LL.S.ESP.MaxDistance then
                if d.name then d.name.Visible = false end
                if d.dist then d.dist.Visible = false end
                if d.hpBg then d.hpBg.Visible = false end
                if d.hpFill then d.hpFill.Visible = false end
                if d.tracer then d.tracer.Visible = false end
                if d.hl then d.hl.Enabled = false end
                continue
            end
            if d.hl then
                d.hl.Enabled = true
                if d.hl.Adornee ~= c and c then d.hl.Adornee = c end
            end
            local top = Camera:WorldToViewportPoint(d.cacheHead.Position + Vector3.new(0, 1, 0))
            if top.Z <= 0 then
                if d.name then d.name.Visible = false end
                if d.dist then d.dist.Visible = false end
                if d.hpBg then d.hpBg.Visible = false end
                if d.hpFill then d.hpFill.Visible = false end
                if d.tracer then d.tracer.Visible = false end
                continue
            end
            if LL.S.ESP.ShowName and d.name then
                d.name.Text = d.player.Name
                d.name.Size = LL.S.ESP.NickSize
                d.name.Color = LL.S.ESP.NickColor
                d.name.Position = Vector2.new(top.X, top.Y - 24)
                d.name.Visible = true
            elseif d.name then d.name.Visible = false end
            if LL.S.ESP.ShowHPBar and d.cacheHum and d.hpBg and d.hpFill then
                local hpW, hpH = LL.S.ESP.HPBarWidth, LL.S.ESP.HPBarHeight
                local bx = top.X - hpW/2
                local by = top.Y - 34 - hpH
                d.hpBg.Position = Vector2.new(bx, by)
                d.hpBg.Size = Vector2.new(hpW, hpH)
                d.hpBg.Visible = true
                local pct = math.clamp(d.cacheHum.Health / math.max(d.cacheHum.MaxHealth,1), 0, 1)
                d.hpFill.Position = Vector2.new(bx + 1, by + 1)
                d.hpFill.Size = Vector2.new(math.max(0,(hpW-2)*pct), math.max(1, hpH-2))
                if LL.S.ESP.HPDynamicColor then
                    d.hpFill.Color = Color3.fromHSV((1/3)*pct, 1, 1)
                else
                    d.hpFill.Color = LL.S.ESP.HPBarColor
                end
                d.hpFill.Visible = true
            else
                if d.hpBg then d.hpBg.Visible = false end
                if d.hpFill then d.hpFill.Visible = false end
            end
            if LL.S.ESP.ShowDistance and d.dist then
                d.dist.Text = math.floor(dist).."m"
                d.dist.Position = Vector2.new(top.X, top.Y - 6)
                d.dist.Visible = true
            elseif d.dist then d.dist.Visible = false end
            if LL.S.ESP.TracerEnabled and d.tracer then
                drawTracerLine(d.tracer, vp.X/2, vp.Y,
                    top.X, top.Y,
                    LL.S.ESP.TracerFrom, LL.S.ESP.TracerTo)
            elseif d.tracer then d.tracer.Visible = false end
        end

        if LL.S.ESP.NPCEnabled then
            for model, d in pairs(LL.NPCESPObjs) do
                if not model.Parent then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    if d.hl then d.hl.Enabled = false end
                    continue
                end
                local head = model:FindFirstChild("Head")
                local hum2 = model:FindFirstChildOfClass("Humanoid")
                if not head or not hum2 then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    if d.hl then d.hl.Enabled = false end
                    continue
                end
                local dist = (camPos - head.Position).Magnitude
                if dist > LL.S.ESP.MaxDistance then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    if d.hl then d.hl.Enabled = false end
                    continue
                end
                if d.hl then
                    d.hl.Enabled = true
                    if d.hl.Adornee ~= model then d.hl.Adornee = model end
                end
                local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
                if top.Z <= 0 then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    continue
                end
                if LL.S.ESP.NPCName and d.name then
                    d.name.Text = model.Name
                    d.name.Size = LL.S.ESP.NickSize
                    d.name.Color = LL.S.ESP.NickColor
                    d.name.Position = Vector2.new(top.X, top.Y - 24)
                    d.name.Visible = true
                elseif d.name then d.name.Visible = false end
                if LL.S.ESP.NPCHPBar and hum2 and d.hpBg and d.hpFill then
                    local hpW, hpH = LL.S.ESP.HPBarWidth, LL.S.ESP.HPBarHeight
                    local bx = top.X - hpW/2
                    local by = top.Y - 34 - hpH
                    d.hpBg.Position = Vector2.new(bx, by)
                    d.hpBg.Size = Vector2.new(hpW, hpH)
                    d.hpBg.Visible = true
                    local pct = math.clamp(hum2.Health / math.max(hum2.MaxHealth,1), 0, 1)
                    d.hpFill.Position = Vector2.new(bx + 1, by + 1)
                    d.hpFill.Size = Vector2.new(math.max(0,(hpW-2)*pct), math.max(1, hpH-2))
                    d.hpFill.Color = LL.S.ESP.HPDynamicColor and Color3.fromHSV((1/3)*pct,1,1) or LL.S.ESP.HPBarColor
                    d.hpFill.Visible = true
                else
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                end
                if LL.S.ESP.NPCDistance and d.dist then
                    d.dist.Text = math.floor(dist).."m"
                    d.dist.Position = Vector2.new(top.X, top.Y - 6)
                    d.dist.Visible = true
                elseif d.dist then d.dist.Visible = false end
            end
        end
    end

    -- Effects (throttled)
    LL.effectAccum = LL.effectAccum + dt
    if LL.effectAccum < LL.EFFECT_INTERVAL then return end
    LL.effectAccum = 0

    if LL.S.Troll.Spin and hrp then
        if not LL.SpinAV or not LL.SpinAV.Parent then
            local av = Instance.new("AngularVelocity")
            av.MaxTorque = math.huge
            av.AngularVelocity = Vector3.new(0, 30, 0)
            av.Parent = hrp
            LL.SpinAV = av
        end
    elseif LL.SpinAV then
        LL.SpinAV:Destroy(); LL.SpinAV = nil
    end

    if LL.S.Troll.Invisible and ch then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = 1
            elseif p:IsA("Decal") then p.Transparency = 1 end
        end
    end

    if LL.S.Troll.AntiFling and ch then
        local ANTIFLING = {"BodyVelocity","BodyAngularVelocity","BodyGyro","BodyThrust","BodyForce"}
        local skip = LL.Xneo.nowe or LL.S.Player.Fly
        if not skip then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    for _, class in ipairs(ANTIFLING) do
                        for _, inst in ipairs(p:GetChildren()) do
                            if inst:IsA(class) then pcall(function() inst:Destroy() end) end
                        end
                    end
                    if p.Velocity.Magnitude > 500 and p.Velocity.Y < -10 then
                        p.Velocity = Vector3.zero
                        p.RotVelocity = Vector3.zero
                    end
                end
            end
        end
    end
end))

-- ============================================================
-- INFINITE JUMP
-- ============================================================
LL.trackConn(UIS.JumpRequest:Connect(function()
    if LL.S.Player.InfiniteJump then
        local hum = LL.Cache.Humanoid
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ============================================================
-- AUTOSAVE LOOP (debounced)
-- ============================================================
LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(2)
        if LL.CONFIG_DIRTY and LL.S.AutoSave and (tick() - LL.lastDirtyTime) >= 2 then
            LL.CONFIG_DIRTY = false
            pcall(function() LL.saveConfig(LL.AUTOSAVE_FILE) end)
        end
    end
end))

-- ============================================================
-- INIT
-- ============================================================
if LL.S.ESP.Enabled then
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then LL.CreateESP(p) end
    end
end
if LL.S.ESP.NPCEnabled then
    LL.refreshNPCCache()
    for m in pairs(LL.NPCCache) do
        if not LL.isPlayerCharacter(m) then pcall(LL.CreateNPCESP, m) end
    end
end
for action, state in pairs(LL.S.MobileBtns) do
    if state then LL.ToggleMobileBtn(action, true) end
end
LL.applyGravityState()
LL.ApplyFloatingLock()
LL.RepositionAllFloatingBtns()
if LL.S.Player.AntiAFK then LL.startAntiAFK() end
if LL.S.Player.FPSBooster then LL.enableFPSBooster() end
if LL.S.Player.LowQuality then LL.enableLowQuality() end
if LL.S.Player.Fullbright then LL.enableFullbright() end
if LL.S.Player.MobileFly and not LL.Xneo.gui then
    pcall(function() LL.launchXneoFlyGUI() end)
end

LL.Notify("Timon Hub v4.6.0 · загружен")

-- ============================================================
-- UNLOAD
-- ============================================================
getgenv().TIMON_UNLOAD = function()
    getgenv().TIMON_LOADED = false
    LL.xneoStopTpWalking()
    pcall(function() LL.closeXneoFlyGUI() end)
    pcall(function() LL.stopAntiAFK() end)
    pcall(function() LL.disableFPSBooster() end)
    pcall(function() LL.disableLowQuality() end)
    pcall(function() LL.disableFullbright() end)
    local hum = LL.Cache.Humanoid
    if hum then
        pcall(function()
            hum.WalkSpeed = LL.S.Player.OrigWalkSpeed or 16
            hum.JumpPower = LL.S.Player.OrigJumpPower or 50
        end)
    end
    pcall(function() Workspace.Gravity = DEFAULT_GRAVITY end)
    pcall(function() ScreenGui:Destroy() end)
    if LL.Xneo.gui then pcall(function() LL.Xneo.gui:Destroy() end); LL.Xneo.gui = nil end
    local espKeys = {}
    for p in pairs(LL.ESPObjs) do espKeys[#espKeys+1] = p end
    for _, p in ipairs(espKeys) do LL.RemoveESP(p) end
    local npcKeys = {}
    for m in pairs(LL.NPCESPObjs) do npcKeys[#npcKeys+1] = m end
    for _, m in ipairs(npcKeys) do LL.RemoveNPCESP(m) end
    for _, conn in pairs(LL.espCharConn) do pcall(function() conn:Disconnect() end) end
    LL.espCharConn = {}
    LL.ClearAllHitboxes(); LL.ClearAllNPCHitboxes()
    if LL.fovCircle then pcall(function() LL.fovCircle:Remove() end) end
    if LL.aimBeam then pcall(function() LL.aimBeam:Remove() end) end
    if LL.hitboxBox then pcall(function() LL.hitboxBox:Remove() end) end
    pcall(function() RunService:UnbindFromRenderStep("TIMON_AIM") end)
    if LL.SpinAV then pcall(function() LL.SpinAV:Destroy() end) end
    if LL.FlyBV then pcall(function() LL.FlyBV:Destroy() end) end
    if LL.FlyBG then pcall(function() LL.FlyBG:Destroy() end) end
    for _, t in ipairs(THREADS) do pcall(function() task.cancel(t) end) end
    THREADS = {}
    for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
    CONNS = {}
    LL.StickyTarget = nil; LL.StickyTargetIsNPC = false
    LL.aimHoldDown = false; LL.wasHoldActive = false
    LL.antiAFKThread = nil
end