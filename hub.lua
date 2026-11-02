if getgenv().TIMON_LOADED then pcall(function() getgenv().TIMON_UNLOAD() end) end
getgenv().TIMON_LISTENING = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Settings = game:GetService("Settings")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
if not Camera then
    task.wait(0.5)
    Camera = Workspace.CurrentCamera
end
if not Camera then warn("[LARP] Camera не найдена"); return end
local DEFAULT_GRAVITY = Workspace.Gravity
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

local CONNS = {}
local THREADS = {}

local LL = {}
LL.CONNS = CONNS
LL.THREADS = THREADS
LL.S = nil
LL.ScreenGui = nil
LL.Main = nil
LL.UIScale = nil
LL.xneoScriptRunning = false
LL.lastNPCRescan = 0
LL.Language = "ru"
LL.KeyValidated = false
LL.SECRET_KEY = "LARP333"
LL._acLast = 0

function LL.trackConn(c) CONNS[#CONNS+1] = c; return c end
function LL.trackThread(t) THREADS[#THREADS+1] = t; return t end

getgenv().TIMON_LOADED = true

function LL.corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = o
    return c
end
function LL.stroke(o, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(90,70,130)
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end
function LL.gradient(o, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)})
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

LL.Loc = {
    ru = {
        Title = "LARP(T) · 333 SINISTER",
        Tabs = {Combat="Бой", ESP="ESP", Player="Игрок", Hitbox="Хитбокс", Macro="Макросы", AutoClicker="Автокликер", Settings="Настройки", Binds="Бинды", Info="Инфо"},
        Combat = {Main="Основное",EnableAim="Включить Aimbot",TargetWho="Кого наводить",TargetPlayers="Игроки",TargetNPCs="NPC",AimBehavior="Поведение",StickyLock="Липкая цель",WallCheck="Проверка стен",AimMode="Режим",Smoothness="Плавность",DistanceWeight="Вес дистанции",FOV="FOV",CameraFOV="Камера FOV",MobileFOV="Мобильный FOV",ShowFOV="Показывать круг FOV",FOVColor="Цвет FOV",TargetPart="Часть цели",AimPart="Часть",Prediction="Предсказание",PredictLead="Упреждение",HitscanMode="Хитскан",BulletSpeed="Скорость пули",LeadMultiplier="Множитель упреждения",Jitter="Дрожание",EnableJitter="Включить дрожание",JitterAmount="Сила дрожания (px)",CombatVisuals="Визуалы",HitboxVisualizer="Показ хитбокса",AimAssistBeam="Луч наведения",BeamColor="Цвет луча",MicroAdjust="Микрокоррекция",MicroAdjustAmount="Сила коррекции (px)",SilentAim="Silent Aim",EnableSilent="Включить Silent Aim",SilentMode="Режим",SilentFOV="Silent FOV",SilentPart="Часть",SilentWallCheck="Проверка стен",SilentSmooth="Плавность",SilentShowFOV="Показывать круг"},
        ESP = {Toggle="ESP",EnableESP="Включить ESP (игроки)",AutoRefresh="Авто-обновление",MaxDistance="Макс. дистанция",Highlight="Подсветка",OutlineColor="Цвет обводки",FillColor="Цвет заливки",FillTransparency="Прозрачность заливки",OutlineTransparency="Прозрачность обводки",ThroughWalls="Сквозь стены",Nicks="Ники",ShowName="Показывать ники",NickColor="Цвет ников",NickSize="Размер ников",HPBar="ХП бар",ShowHPBar="Показывать ХП",HPDynamicColor="Динамический цвет ХП",HPBarColor="Цвет ХП",HPBarWidth="Ширина ХП",HPBarHeight="Высота ХП",Distance="Дистанция",ShowDistance="Показывать дистанцию",Tracer="Трейсеры",EnableTracer="Включить трейсеры",TracerFrom="Трейсер (низ)",TracerTo="Трейсер (цель)",NPCESP="NPC ESP",EnableNPCESP="Включить NPC ESP",NPCName="Имя NPC",NPCDistance="Дистанция NPC",NPCHPBar="ХП бар NPC"},
        Player = {Movement="Движение",WalkSpeedEnabled="Скорость ходьбы",WalkSpeed="Скорость",JumpPowerEnabled="Сила прыжка",JumpPower="Сила прыжка",InfiniteJump="Бесконечный прыжок",Noclip="Noclip",Fly="Полёт",FlySpeed="Скорость полёта",Gravity="Гравитация",ZeroGravity="Нулевая гравитация (ragdoll)",Coordinates="Координаты",SavePos="Сохранить позицию",LoadPos="Загрузить позицию",ClearPos="Очистить позицию",Utility="Утилиты",AntiAFK="Anti-AFK",LazyMode="Ленивый режим",FPSBooster="Бустер FPS",LowQuality="Низкое качество",Fullbright="Полная яркость",XNEO="XNEO Fly",XNEOBtn="Запустить XNEO Fly"},
        Hitbox = {Who="Кому хитбоксы",Mode="Режим",All="Все (игроки + NPC)",PlayersOnly="Только игроки",NPConly="Только NPC",Nobody="Никому",AutoRefresh="Авто-обновление",Parts="Части",HeadHitbox="Хитбокс головы",BodyHitbox="Хитбокс тела",Sizes="Размеры (реальный Size)",RootSize="Размер HRP",HeadSize="Размер головы",BodySize="Размер тела"},
        Macro = {Info="Записывает движение через MoveTo (без телепорта).",Settings="Настройки",MacroName="Имя макроса",SampleRate="Частота записи (сек)",Loop="Цикл",JumpDetection="Записывать прыжки",Advanced="Продвинутые режимы",IgnoreObstacles="Игнорировать стены",PushThrough="Пробивать стены",Record="Запись",StartRecord="🔴 Начать запись",StopRecord="⏹ Закончить запись",Play="Воспроизведение",PlayMacro="▶ Запустить макрос",StopMacro="⏹ Остановить макрос",StopAndReturn="⏸ Остановить и вернуться в начало",Manage="Управление",SaveRecord="💾 Сохранить запись",DeleteCurrent="🗑 Удалить текущий макрос",DeleteAll="🗑 Удалить все макросы",List="Список макросов",Empty="(нет макросов)"},
        AutoClicker = {Title="Автокликер",Enable="Включить автокликер",Speed="Скорость (кликов/сек)",Button="Кнопка",Left="ЛКМ",Right="ПКМ",Mode="Режим",ModeVirtual="Виртуальный",ModeReal="Реальный (курсор)",Info="Кликает автоматически с заданной скоростью. Виртуальный режим — без движения мыши, реальный — по позиции курсора."},
        Settings = {Actions="Действия",ResetSettings="Сбросить настройки",Unload="Выгрузить скрипт",UISettings="UI",UIScale="Масштаб UI",Notifications="Уведомления",AutoHideMobile="Авто-скрытие GUI на мобиле",Configs="Конфиги",ConfigName="Имя конфига",SaveConfig="Сохранить",LoadConfig="Загрузить",DeleteConfig="Удалить",AutoSave="Авто-сохранение",AvailableConfigs="Доступные конфиги",EmptyConfigs="(пусто)"},
        Binds = {Title="Бинды",Search="Поиск биндов...",Actions="Действия",Aimbot="Aimbot",AimbotHold="Удержание Aim",ESP="ESP",Hitbox="Hitbox",Fly="Полёт",Noclip="Noclip",InfiniteJump="Бесконечный прыжок",ZeroGravity="Нулевая гравитация",SavePos="Сохранить позицию",LoadPos="Загрузить позицию",Macro="Макрос (Play/Stop)",MacroRecord="Запись макроса",ResetBinds="Сбросить все бинды",FloatingLock="Фиксация кнопок",ResetPositions="Сбросить позиции кнопок",FloatingButtons="Плавающие кнопки"},
        Info = {Title="О скрипте LARP(T)",Owner="Владелец (Telegram)",Channel="Канал (Telegram)",Note="Скрипт полностью бесплатный. Ключ навсегда: @luaLARP (подпишись) и напиши @ForchanW, если ключ не опубликован.",Free="Скрипт полностью бесплатный.",Key="Ключ навсегда: @luaLARP / @ForchanW"},
        Key = {Title="Введите ключ для LARP(T)",Placeholder="Ключ доступа",Submit="Активировать",Error="Неверный ключ. Проверьте и попробуйте снова.",Success="Ключ активирован навсегда!"},
    },
    en = {
        Title = "LARP(T) · 333 SINISTER",
        Tabs = {Combat="Combat", ESP="ESP", Player="Player", Hitbox="Hitbox", Macro="Macro", AutoClicker="AutoClicker", Settings="Settings", Binds="Binds", Info="Info"},
        Combat = {Main="Main",EnableAim="Enable Aim",TargetWho="Target",TargetPlayers="Players",TargetNPCs="NPCs",AimBehavior="Aim Behavior",StickyLock="Sticky Lock",WallCheck="Wall Check",AimMode="Aim Mode",Smoothness="Smoothness",DistanceWeight="Distance Weight",FOV="FOV",CameraFOV="Camera FOV",MobileFOV="Mobile FOV",ShowFOV="Show FOV Circle",FOVColor="FOV Color",TargetPart="Target Part",AimPart="Aim Part",Prediction="Prediction",PredictLead="Predict Lead",HitscanMode="Hitscan Mode",BulletSpeed="Bullet Speed",LeadMultiplier="Lead Multiplier",Jitter="Jitter",EnableJitter="Enable Jitter",JitterAmount="Jitter Amount (px)",CombatVisuals="Combat Visuals",HitboxVisualizer="Hitbox Visualizer",AimAssistBeam="Aim Assist Beam",BeamColor="Beam Color",MicroAdjust="Micro Adjust",MicroAdjustAmount="Micro Adjust Amount (px)",SilentAim="Silent Aim",EnableSilent="Enable Silent Aim",SilentMode="Mode",SilentFOV="Silent FOV",SilentPart="Part",SilentWallCheck="Wall Check",SilentSmooth="Smoothness",SilentShowFOV="Show FOV Circle"},
        ESP = {Toggle="ESP",EnableESP="Enable ESP (Players)",AutoRefresh="Auto-Refresh",MaxDistance="Max Distance",Highlight="Highlight",OutlineColor="Outline Color",FillColor="Fill Color",FillTransparency="Fill Transparency",OutlineTransparency="Outline Transparency",ThroughWalls="Through Walls",Nicks="Names",ShowName="Show Name",NickColor="Nick Color",NickSize="Nick Size",HPBar="HP Bar",ShowHPBar="Show HP Bar",HPDynamicColor="Dynamic HP Color",HPBarColor="HP Bar Color",HPBarWidth="HP Bar Width",HPBarHeight="HP Bar Height",Distance="Distance",ShowDistance="Show Distance",Tracer="Tracer",EnableTracer="Enable Tracer",TracerFrom="Tracer From",TracerTo="Tracer To",NPCESP="NPC ESP",EnableNPCESP="Enable NPC ESP",NPCName="Show NPC Name",NPCDistance="Show NPC Distance",NPCHPBar="NPC HP Bar"},
        Player = {Movement="Movement",WalkSpeedEnabled="Walk Speed Override",WalkSpeed="Walk Speed",JumpPowerEnabled="Jump Power Override",JumpPower="Jump Power",InfiniteJump="Infinite Jump",Noclip="Noclip",Fly="Fly",FlySpeed="Fly Speed",Gravity="Gravity",ZeroGravity="Zero Gravity (ragdoll)",Coordinates="Coordinates",SavePos="Save Position",LoadPos="Load Position",ClearPos="Clear Position",Utility="Utility",AntiAFK="Anti-AFK",LazyMode="Lazy Mode",FPSBooster="FPS Booster",LowQuality="Low Quality",Fullbright="Fullbright",XNEO="XNEO Fly",XNEOBtn="Load XNEO Fly"},
        Hitbox = {Who="Hitbox Target",Mode="Mode",All="All (Players + NPC)",PlayersOnly="Players Only",NPConly="NPC Only",Nobody="Nobody",AutoRefresh="Auto-Refresh",Parts="Parts",HeadHitbox="Head Hitbox",BodyHitbox="Body Hitbox",Sizes="Sizes",RootSize="Root Size",HeadSize="Head Size",BodySize="Body Size"},
        Macro = {Info="Records movement via MoveTo.",Settings="Settings",MacroName="Macro Name",SampleRate="Sample Rate (sec)",Loop="Loop",JumpDetection="Record Jumps",Advanced="Advanced Modes",IgnoreObstacles="Ignore Obstacles",PushThrough="Push Through",Record="Record",StartRecord="🔴 Start Recording",StopRecord="⏹ Stop Recording",Play="Playback",PlayMacro="▶ Play Macro",StopMacro="⏹ Stop Macro",StopAndReturn="⏸ Stop and Return",Manage="Manage",SaveRecord="💾 Save Recording",DeleteCurrent="🗑 Delete Current",DeleteAll="🗑 Delete All",List="Macro List",Empty="(no macros)"},
        AutoClicker = {Title="AutoClicker",Enable="Enable AutoClicker",Speed="Speed (clicks/sec)",Button="Button",Left="Left",Right="Right",Mode="Mode",ModeVirtual="Virtual",ModeReal="Real (Cursor)",Info="Clicks automatically at set speed. Virtual — no mouse movement, Real — at cursor position."},
        Settings = {Actions="Actions",ResetSettings="Reset Settings",Unload="Unload Script",UISettings="UI Settings",UIScale="UI Scale",Notifications="Notifications",AutoHideMobile="Auto-hide GUI on Mobile",Configs="Configs",ConfigName="Config Name",SaveConfig="Save",LoadConfig="Load",DeleteConfig="Delete",AutoSave="Auto-save",AvailableConfigs="Available Configs",EmptyConfigs="(empty)"},
        Binds = {Title="Binds",Search="Search binds...",Actions="Actions",Aimbot="Aimbot",AimbotHold="Aim Hold",ESP="ESP",Hitbox="Hitbox",Fly="Fly",Noclip="Noclip",InfiniteJump="Infinite Jump",ZeroGravity="Zero Gravity",SavePos="Save Position",LoadPos="Load Position",Macro="Macro (Play/Stop)",MacroRecord="Macro Record",ResetBinds="Reset All Binds",FloatingLock="Floating Lock",ResetPositions="Reset Button Positions",FloatingButtons="Floating Buttons"},
        Info = {Title="About LARP(T)",Owner="Owner (Telegram)",Channel="Channel (Telegram)",Note="Script is 100% free. Forever key: @luaLARP (subscribe), message @ForchanW if not posted.",Free="Script is 100% free.",Key="Forever key: @luaLARP / @ForchanW"},
        Key = {Title="Enter LARP(T) Key",Placeholder="Access key",Submit="Activate",Error="Invalid key. Check and try again.",Success="Key activated forever!"},
    },
}

function LL.T(section, key)
    local lang = LL.Language == "en" and "en" or "ru"
    local tbl = LL.Loc[lang]
    if tbl and tbl[section] and tbl[section][key] then return tbl[section][key] end
    return key
end
function LL.CheckKey(input)
    return input == LL.SECRET_KEY
end
LL.S = {
    Aimbot = {Enabled=false, Mode="Camera", Smooth=0.25, CameraFOV=200, MobileFOV=200, Part="Head", ShowFOV=true, StickyLock=true, DistanceWeight=1.0, WallCheck=false, PredictLead=false, BulletSpeed=1000, LeadMultiplier=1.0, HitscanMode=false, TargetPlayers=true, TargetNPCs=false, JitterEnabled=false, Jitter=1.5, HitboxVisualizer=false, AimAssistBeam=false, MicroAdjust=false, MicroAdjustAmount=1.0, FOVColor = Color3.fromRGB(155,90,255), TracerColor = Color3.fromRGB(255,90,190), SilentAim=false, SilentMode="Silent", SilentFOV=200, SilentPart="Head", SilentWallCheck=false, SilentSmooth=0.3, SilentShowFOV=true},
    ESP = {Enabled=false, OutlineColor=Color3.fromRGB(180,100,255), FillColor=Color3.fromRGB(120,60,220), FillTransparency=0.75, OutlineTransparency=0.05, ThroughWalls=true, ShowName=true, ShowDistance=true, NickColor=Color3.fromRGB(245,235,255), NickSize=15, ShowHPBar=true, HPBarWidth=55, HPBarHeight=5, HPDynamicColor=true, HPBarColor=Color3.fromRGB(110,255,170), NPCEnabled=false, NPCName=true, NPCDistance=false, NPCHPBar=true, MaxDistance=1500, TracerEnabled=false, TracerFrom=Color3.fromRGB(180,100,255), TracerTo=Color3.fromRGB(255,90,190), RealTimeRefresh=false},
    Hitbox = {Enabled=false, HeadEnabled=true, BodyEnabled=true, HeadSize=3, BodySize=5, RootSize=12, NPCSupport=false, RealTimeRefresh=true},
    Player = {Fly=false, FlySpeed=50, ZeroGravity=false, WalkSpeed=16, JumpPower=50, WalkSpeedEnabled=false, JumpPowerEnabled=false, OrigWalkSpeed=nil, OrigJumpPower=nil, InfiniteJump=false, Noclip=false, AntiAFK=false, LazyMode=false, FPSBooster=false, LowQuality=false, Fullbright=false, SavedPos=nil},
    Troll = {Spin=false, Invisible=false, AntiFling=false},
    Hamster = {Coins=0},
    AutoClicker = {Enabled=false, Speed=10, Button="Left", Mode="Virtual"},
    Macro = {Recording = false, Playing = false, CurrentMacro = "macro1", Loop = true, SampleRate = 0.2, JumpDetection = true, IgnoreObstacles = false, PushThrough = false},
    Binds = {}, MobileBtns = {},
    FloatingLock=false, FloatingPos={},
    AutoSave=true, ConfigName="auto",
    UI = {Notifications = true, AutoHideOnMobile = true, GuiKeybind = Enum.KeyCode.LeftAlt, AnimationSpeed = 0.18, Scale = 1.0, CenterOnShow = true},
    KeyValidated = false,
}
local S = LL.S
getgenv().TIMON_SETTINGS = S

LL.XNEO_STATES = {Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics}
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
LL.Macros = {}
LL.MacroRecord = nil
LL.MacroPlayThread = nil
LL.Cache = {Character = nil, Humanoid = nil, HRP = nil, Camera = Camera, Viewport = Camera.ViewportSize}

LL.ScriptAvailable = {WriteFile = (typeof(writefile) == "function"), ReadFile = (typeof(readfile) == "function"), IsFile = (typeof(isfile) == "function"), IsFolder = (typeof(isfolder) == "function"), MakeFolder = (typeof(makefolder) == "function"), ListFiles = (typeof(listfiles) == "function"), DeleteFile = (typeof(delfile) == "function"), Drawing = (typeof(Drawing) == "table"), Hookfunction = (typeof(hookfunction) == "function"), GetConnections = (typeof(getconnections) == "function")}

LL.COL = {bg=Color3.fromRGB(14,12,20), bg2=Color3.fromRGB(22,18,32), panel=Color3.fromRGB(30,26,42), elem=Color3.fromRGB(42,36,58), elemHover=Color3.fromRGB(58,50,78), elemPress=Color3.fromRGB(34,28,48), accent=Color3.fromRGB(155,90,255), accent2=Color3.fromRGB(255,90,190), mint=Color3.fromRGB(120,240,200), text=Color3.fromRGB(245,240,255), sub=Color3.fromRGB(160,150,185), stroke=Color3.fromRGB(90,70,130), strokeBright=Color3.fromRGB(140,110,190), off=Color3.fromRGB(70,62,82), green=Color3.fromRGB(130,255,170), red=Color3.fromRGB(255,90,120)}
local COL = LL.COL
LL.Anim = {Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Normal = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)}

function LL.AddRefresh(fn) table.insert(LL.Refreshers, fn) end
function LL.RefreshAll() for _, fn in ipairs(LL.Refreshers) do pcall(fn) end end
LL.ORDER = 0
function LL.NextOrder() LL.ORDER = LL.ORDER + 1; return LL.ORDER end

LL.CONFIG_DIR = "LARP_T"
LL.AUTOSAVE_FILE = "autosave_new"
LL.CONFIG_DIRTY = false
LL.lastDirtyTime = 0
LL.FS_AVAILABLE = LL.ScriptAvailable.WriteFile and LL.ScriptAvailable.ReadFile and LL.ScriptAvailable.IsFile and LL.ScriptAvailable.IsFolder and LL.ScriptAvailable.MakeFolder

function LL.MarkDirty() LL.CONFIG_DIRTY = true; LL.lastDirtyTime = tick() end
function LL.ensureDir() if not LL.FS_AVAILABLE then return end; pcall(function() if not isfolder(LL.CONFIG_DIR) then makefolder(LL.CONFIG_DIR) end end) end
function LL.fileExists(p) if not LL.FS_AVAILABLE then return false end; local ok, r = pcall(function() return isfile(p) end); return ok and r end

function LL.packC3(c) return {math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)} end
function LL.unpackC3(t) return Color3.fromRGB(t[1] or 128, t[2] or 128, t[3] or 128) end
local unpackFn = table.unpack or unpack

function LL.packSettings()
    local S = LL.S
    local d = {Aimbot={}, ESP={}, Hitbox={}, Player={}, Troll={}, Hamster={Coins=S.Hamster.Coins}, AutoClicker=S.AutoClicker, Binds={}, MobileBtns={}, AutoSave=S.AutoSave, FloatingLock=S.FloatingLock, FloatingPos=S.FloatingPos, ConfigName=S.ConfigName, UI={}, Macro={}, KeyValidated=S.KeyValidated, Language=LL.Language}
    for k,v in pairs(S.Aimbot) do if type(v)=="Color3" then d.Aimbot[k]=LL.packC3(v) else d.Aimbot[k]=v end end
    for k,v in pairs(S.ESP) do if type(v)=="Color3" then d.ESP[k]=LL.packC3(v) else d.ESP[k]=v end end
    for k,v in pairs(S.Hitbox) do d.Hitbox[k]=v end
    for k,v in pairs(S.Player) do if k=="SavedPos" then if v then d.Player[k]={v:GetComponents()} end else d.Player[k]=v end end
    for k,v in pairs(S.Troll) do d.Troll[k]=v end
    for a,k in pairs(S.Binds) do if typeof(k)=="EnumItem" then d.Binds[a]=tostring(k):gsub("Enum.KeyCode.","") end end
    for k,v in pairs(S.MobileBtns) do d.MobileBtns[k]=v end
    for k,v in pairs(S.UI) do if typeof(v)=="EnumItem" then d.UI[k]=tostring(v):gsub("Enum.KeyCode.","") else d.UI[k]=v end end
    for k,v in pairs(S.Macro) do d.Macro[k]=v end
    return d
end

function LL.applySettings(d)
    if not d then return end
    local S = LL.S
    if d.KeyValidated ~= nil then LL.S.KeyValidated = d.KeyValidated; LL.KeyValidated = d.KeyValidated end
    if d.Language then LL.Language = d.Language end
    if d.Aimbot then for k,v in pairs(d.Aimbot) do if S.Aimbot[k]~=nil then if type(S.Aimbot[k])=="Color3" and type(v)=="table" then S.Aimbot[k]=LL.unpackC3(v) else S.Aimbot[k]=v end end end end
    if d.ESP then for k,v in pairs(d.ESP) do if S.ESP[k]~=nil then if type(S.ESP[k])=="Color3" and type(v)=="table" then S.ESP[k]=LL.unpackC3(v) else S.ESP[k]=v end end end end
    if d.Hitbox then for k,v in pairs(d.Hitbox) do if S.Hitbox[k]~=nil then S.Hitbox[k]=v end end end
    if d.Player then for k,v in pairs(d.Player) do if k=="SavedPos" and type(v)=="table" and #v>=12 then local ok, cf = pcall(function() return CFrame.new(unpackFn(v)) end); if ok then S.Player.SavedPos=cf end elseif S.Player[k]~=nil then S.Player[k]=v end end end
    if d.Troll then for k,v in pairs(d.Troll) do if S.Troll[k]~=nil then S.Troll[k]=v end end end
    if d.Hamster and d.Hamster.Coins then S.Hamster.Coins=d.Hamster.Coins end
    if d.AutoClicker then for k,v in pairs(d.AutoClicker) do if S.AutoClicker[k]~=nil then S.AutoClicker[k]=v end end end
    S.Binds = {}
    if d.Binds then for a,n in pairs(d.Binds) do local ok, code = pcall(function() return Enum.KeyCode[n] end); if ok and code then S.Binds[a]=code end end end
    if d.MobileBtns then S.MobileBtns = {}; for k,v in pairs(d.MobileBtns) do S.MobileBtns[k]=v end end
    if d.AutoSave~=nil then S.AutoSave=d.AutoSave end
    if d.FloatingLock~=nil then S.FloatingLock=d.FloatingLock end
    if d.FloatingPos then S.FloatingPos=d.FloatingPos end
    if d.ConfigName then S.ConfigName=d.ConfigName end
    if d.UI then for k,v in pairs(d.UI) do if k=="GuiKeybind" and type(v)=="string" then local ok, code = pcall(function() return Enum.KeyCode[v] end); if ok and code then S.UI.GuiKeybind=code end elseif S.UI[k]~=nil then S.UI[k]=v end end end
    if d.Macro then for k,v in pairs(d.Macro) do if S.Macro[k]~=nil then S.Macro[k]=v end end end
end

function LL.saveConfig(name)
    if not LL.FS_AVAILABLE then return false, "writefile недоступен" end
    LL.ensureDir(); name = name or LL.AUTOSAVE_FILE
    return pcall(function() writefile(LL.CONFIG_DIR.."/"..name..".json", HttpService:JSONEncode(LL.packSettings())) end)
end
function LL.loadConfigFile(name)
    if not LL.FS_AVAILABLE then return false end
    name = name or LL.AUTOSAVE_FILE
    local path = LL.CONFIG_DIR.."/"..name..".json"
    if not LL.fileExists(path) then return false end
    local ok, c = pcall(function() return readfile(path) end)
    if not ok or not c then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(c) end)
    if not ok2 or not data then return false end
    LL.applySettings(data); LL.CONFIG_DIRTY = false; return true
end
function LL.deleteConfig(name)
    if not LL.FS_AVAILABLE then return end
    pcall(function() delfile(LL.CONFIG_DIR.."/"..name..".json") end)
end
function LL.listConfigs()
    local out = {}
    if not LL.FS_AVAILABLE then return out end
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LARP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end
LL.ScreenGui = ScreenGui

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
            if not getgenv().TIMON_LOADED then LL.NotifyActive = LL.NotifyActive - 1; return end
            local n = Instance.new("Frame")
            n.Size = UDim2.new(0, 280, 0, 48)
            n.Position = UDim2.new(1, -300, 1, -90)
            n.BackgroundColor3 = COL.bg2
            n.BackgroundTransparency = 0.02
            n.BorderSizePixel = 0
            n.Parent = ScreenGui
            LL.corner(n, 14); LL.stroke(n, COL.accent, 1.5); LL.gradient(n, COL.accent, COL.accent2, 20)
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, 4, 1, -14); bar.Position = UDim2.new(0, 8, 0, 7)
            bar.BackgroundColor3 = Color3.new(1,1,1); bar.BorderSizePixel = 0; bar.BackgroundTransparency = 0.55
            bar.Parent = n; LL.corner(bar, 2)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -24, 1, 0); l.Position = UDim2.new(0, 22, 0, 0)
            l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = COL.text
            l.Font = Enum.Font.GothamBold; l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = n
            Tween:Create(n, LL.Anim.Normal, {Position = UDim2.new(1, -300, 1, -110)}):Play()
            task.wait(2.4)
            if not getgenv().TIMON_LOADED or not n.Parent then LL.NotifyActive = LL.NotifyActive - 1; return end
            Tween:Create(n, LL.Anim.Slow, {Position = UDim2.new(1, -300, 1, -50), BackgroundTransparency = 1}):Play()
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
        table.insert(LL.NotifyQueue, txt); return
    end
    LL.lastNotifyTime = now
    table.insert(LL.NotifyQueue, txt)
    LL.processNotifyQueue()
end
function LL.Section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1
    f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Text = "› " .. text; l.TextColor3 = COL.mint
    l.Font = Enum.Font.GothamBold; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -3)
    line.BackgroundColor3 = COL.stroke; line.BorderSizePixel = 0; line.BackgroundTransparency = 0.4; line.Parent = f
end

function LL.Toggle(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -78, 1, 0); lbl.Position = UDim2.new(0, 16, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = name; lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 22); track.Position = UDim2.new(1, -58, 0.5, -11)
    track.BackgroundColor3 = COL.off; track.BorderSizePixel = 0; track.Parent = f
    LL.corner(track, 11)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18); knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BorderSizePixel = 0; knob.Parent = track
    LL.corner(knob, 9)
    local function render()
        local state = false; pcall(function() state = getter() end)
        if state then track.BackgroundColor3 = COL.accent; knob.Position = UDim2.new(1, -20, 0.5, -9)
        else track.BackgroundColor3 = COL.off; knob.Position = UDim2.new(0, 2, 0.5, -9) end
    end
    render(); LL.AddRefresh(render)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 10; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function() setter(not getter()) end)
        if not ok then warn("[LARP] "..name..": "..tostring(err)) end
        render(); LL.MarkDirty()
    end)
end

function LL.Slider(parent, name, minV, maxV, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58); f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 16, 0, 8); lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -32, 0, 8); bar.Position = UDim2.new(0, 16, 0, 38)
    bar.BackgroundColor3 = Color3.fromRGB(14, 10, 22); bar.BorderSizePixel = 0; bar.Parent = f
    LL.corner(bar, 4)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL.accent; fill.BorderSizePixel = 0; fill.Parent = bar
    LL.corner(fill, 4); LL.gradient(fill, COL.accent, COL.accent2, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14); dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.new(1, 1, 1); dot.BorderSizePixel = 0; dot.ZIndex = 3; dot.Parent = bar
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
    ca.Size = UDim2.new(1, 16, 0, 30); ca.Position = UDim2.new(0, -8, 0, -11)
    ca.BackgroundTransparency = 1; ca.Text = ""; ca.ZIndex = 10; ca.Parent = bar
    local drag = false
    local function setX(px)
        local rel = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setter(minV + rel * (maxV - minV)); render(); LL.MarkDirty()
    end
    ca.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; setX(i.Position.X) end
    end)
    LL.trackConn(UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setX(i.Position.X) end
    end))
    LL.trackConn(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end))
end

function LL.Dropdown(parent, name, options, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -36, 1, 0); lbl.Position = UDim2.new(0, 16, 0, 0); lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -28, 0, 0); arrow.BackgroundTransparency = 1
    arrow.Text = "▾"; arrow.TextColor3 = COL.accent2; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 16; arrow.Parent = f
    local function render() lbl.Text = name .. ": " .. tostring(getter()) end
    render(); LL.AddRefresh(render)
    local popup
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 10; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        if popup and popup.Parent then popup:Destroy(); popup = nil; return end
        local popH = #options*30+8
        local popupFrame = Instance.new("Frame")
        popupFrame.Size = UDim2.new(0, f.AbsoluteSize.X, 0, popH)
        local vp = Camera.ViewportSize
        local yPos = f.AbsolutePosition.Y + f.AbsoluteSize.Y + 4
        if yPos + popH > vp.Y - 20 then yPos = f.AbsolutePosition.Y - popH - 4 end
        popupFrame.Position = UDim2.new(0, f.AbsolutePosition.X, 0, yPos)
        popupFrame.BackgroundColor3 = COL.bg2; popupFrame.BorderSizePixel = 0; popupFrame.ZIndex = 50
        popupFrame.Parent = ScreenGui
        LL.corner(popupFrame, 12); LL.stroke(popupFrame, COL.accent, 1.5)
        popup = popupFrame
        for i, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, -8, 0, 26); ob.Position = UDim2.new(0, 4, 0, (i-1)*30 + 4)
            ob.BackgroundColor3 = COL.elem; ob.BorderSizePixel = 0; ob.Text = opt; ob.TextColor3 = COL.text
            ob.Font = Enum.Font.Gotham; ob.TextSize = 14; ob.ZIndex = 51; ob.AutoButtonColor = false; ob.Parent = popupFrame
            LL.corner(ob, 6)
            ob.MouseEnter:Connect(function() Tween:Create(ob, LL.Anim.Fast, {BackgroundColor3 = COL.elemHover}):Play() end)
            ob.MouseLeave:Connect(function() Tween:Create(ob, LL.Anim.Fast, {BackgroundColor3 = COL.elem}):Play() end)
            ob.MouseButton1Click:Connect(function()
                local ok, err = pcall(function() setter(opt) end)
                if not ok then warn("[LARP Dropdown] "..name..": "..tostring(err)) end
                render(); LL.MarkDirty()
                if popup then popup:Destroy(); popup = nil end
            end)
        end
    end)
end

LL.PALETTE = {Color3.fromRGB(255,20,147), Color3.fromRGB(180,60,255), Color3.fromRGB(255,60,60),  Color3.fromRGB(60,255,60), Color3.fromRGB(60,120,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,255,0),  Color3.fromRGB(255,150,0), Color3.fromRGB(255,255,255),Color3.fromRGB(128,128,128), Color3.fromRGB(180,0,255),  Color3.fromRGB(255,100,180)}
function LL.ColorPicker(parent, name, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 90); f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 16, 0, 6); lbl.BackgroundTransparency = 1
    lbl.Text = name; lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local swatches = {}
    for i, c in ipairs(LL.PALETTE) do
        local row = math.floor((i-1)/6)
        local col = (i-1) % 6
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 22); b.Position = UDim2.new(0, 16+col*36, 0, 32+row*24)
        b.BackgroundColor3 = c; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 10; b.Parent = f
        LL.corner(b, 6)
        local s = LL.stroke(b, Color3.new(1,1,1), (c == getter()) and 2 or 0)
        swatches[#swatches+1] = {line = s, color = c}
        b.MouseButton1Click:Connect(function()
            local ok, err = pcall(function() setter(c) end)
            if not ok then warn("[LARP Color] "..name..": "..tostring(err)) end
            LL.MarkDirty()
            for _, sw in ipairs(swatches) do sw.line.Thickness = 0 end
            s.Thickness = 2
        end)
    end
end

function LL.TextBox(parent, name, placeholder, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62); f.BackgroundColor3 = COL.elem; f.BackgroundTransparency = 0.05
    f.BorderSizePixel = 0; f.LayoutOrder = LL.NextOrder(); f.Parent = parent
    LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20); lbl.Position = UDim2.new(0, 16, 0, 6); lbl.BackgroundTransparency = 1
    lbl.Text = name; lbl.TextColor3 = COL.text; lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -32, 0, 26); box.Position = UDim2.new(0, 16, 0, 30)
    box.BackgroundColor3 = COL.bg2; box.BorderSizePixel = 0; box.Text = getter() or ""
    box.PlaceholderText = placeholder or ""; box.TextColor3 = COL.text; box.PlaceholderColor3 = COL.sub
    box.Font = Enum.Font.Gotham; box.TextSize = 13; box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false; box.ZIndex = 10; box.Parent = f
    LL.corner(box, 8); LL.stroke(box, COL.stroke, 1)
    box.FocusLost:Connect(function() setter(box.Text); LL.MarkDirty() end)
end

function LL.Button(parent, label, callback, opts)
    opts = opts or {}
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42); b.BackgroundColor3 = opts.color or COL.elem
    b.BackgroundTransparency = 0.05; b.BorderSizePixel = 0; b.Text = label
    b.TextColor3 = opts.textColor or COL.text; b.Font = Enum.Font.GothamBold
    b.TextSize = 14; b.LayoutOrder = LL.NextOrder(); b.AutoButtonColor = false; b.ZIndex = 5; b.Parent = parent
    LL.corner(b, 12); LL.stroke(b, opts.stroke or COL.stroke, 1)
    b.MouseEnter:Connect(function() Tween:Create(b, LL.Anim.Fast, {BackgroundColor3 = opts.hover or COL.elemHover}):Play() end)
    b.MouseLeave:Connect(function() Tween:Create(b, LL.Anim.Fast, {BackgroundColor3 = opts.color or COL.elem}):Play() end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("[LARP Button] "..label..": "..tostring(err)) end
    end)
    return b
end
function LL.ShowKeyScreen()
    local keyGui = Instance.new("Frame")
    keyGui.Name = "KeyScreen"
    keyGui.Size = UDim2.new(0, 360, 0, 220)
    keyGui.Position = UDim2.new(0.5, -180, 0.5, -110)
    keyGui.BackgroundColor3 = COL.bg
    keyGui.BorderSizePixel = 0
    keyGui.Parent = ScreenGui
    LL.corner(keyGui, 16)
    LL.stroke(keyGui, COL.accent, 1.5)
    LL.makeShadow(keyGui, 20, 0.6)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -32, 0, 30)
    title.Position = UDim2.new(0, 16, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = LL.T("Key", "Title")
    title.TextColor3 = COL.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = keyGui
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -32, 0, 44)
    box.Position = UDim2.new(0, 16, 0, 70)
    box.BackgroundColor3 = COL.bg2
    box.BorderSizePixel = 0
    box.PlaceholderText = LL.T("Key", "Placeholder")
    box.PlaceholderColor3 = COL.sub
    box.TextColor3 = COL.text
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.ClearTextOnFocus = false
    box.Parent = keyGui
    LL.corner(box, 10)
    LL.stroke(box, COL.stroke, 1)
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -32, 0, 44)
    submitBtn.Position = UDim2.new(0, 16, 0, 130)
    submitBtn.BackgroundColor3 = COL.accent
    submitBtn.Text = LL.T("Key", "Submit")
    submitBtn.TextColor3 = Color3.new(1,1,1)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 15
    submitBtn.Parent = keyGui
    LL.corner(submitBtn, 10)
    submitBtn.MouseButton1Click:Connect(function()
        if LL.CheckKey(box.Text) then
            LL.KeyValidated = true
            LL.S.KeyValidated = true
            LL.Notify(LL.T("Key", "Success"))
            LL.MarkDirty()
            if LL.saveConfig then LL.saveConfig(LL.AUTOSAVE_FILE) end
            keyGui:Destroy()
            LL.ShowMainUI()
        else
            box.Text = ""
            box.PlaceholderText = LL.T("Key", "Error")
            box.PlaceholderColor3 = COL.red
            submitBtn.BackgroundColor3 = COL.red
            task.wait(1)
            submitBtn.BackgroundColor3 = COL.accent
        end
    end)
end

function LL.RebuildUI()
    if LL.Main then
        LL.Main:Destroy()
        LL.Main = nil
    end
    for tn, t in pairs(LL.TabScrolls) do
        if t.scroll then t.scroll:Destroy() end
        if t.btn then t.btn:Destroy() end
    end
    LL.TabScrolls = {}
    LL.TabOrder = {}
    LL.CurrentTab = nil
    LL.Refreshers = {}
    LL.BindRefreshers = {}
    LL.AllFloating = {}
    LL.MobileButtons = {}
    LL.ShowMainUI()
end

function LL.ShowMainUI()
    if LL.Main then return end
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = 0.02
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    LL.corner(Main, 18); LL.stroke(Main, COL.accent, 1.2)
    LL.Main = Main
    LL.makeShadow(Main, 20, 0.75)
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = Main
    LL.UIScale = UIScale
    function LL.ApplyMainSize()
        local vp = Camera.ViewportSize
        local baseW, baseH, baseScale
        if IS_MOBILE then
            baseW, baseH, baseScale = 600, 460, 0.78
        else
            baseW, baseH, baseScale = 760, 540, 1.0
        end
        local userScale = LL.S.UI.Scale or 1.0
        local finalScale = baseScale * userScale
        local maxW = vp.X * (IS_MOBILE and 0.96 or 0.85)
        local maxH = vp.Y * (IS_MOBILE and 0.88 or 0.85)
        local finalW = math.min(baseW, maxW / finalScale)
        local finalH = math.min(baseH, maxH / finalScale)
        Main.Size = UDim2.new(0, finalW, 0, finalH)
        Main.Position = UDim2.new(0.5, -finalW * finalScale / 2, 0.5, -finalH * finalScale / 2)
        UIScale.Scale = finalScale
    end
    LL.ApplyMainSize()
    LL.trackConn(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        LL.Cache.Viewport = Camera.ViewportSize
        LL.ApplyMainSize()
    end))
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = COL.bg2
    TitleBar.BackgroundTransparency = 0.02
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    LL.corner(TitleBar, 18); LL.gradient(TitleBar, COL.accent, COL.accent2, 25)
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -180, 1, 0); TitleLbl.Position = UDim2.new(0, 20, 0, 0)
    TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = LL.Loc[LL.Language].Title
    TitleLbl.TextColor3 = Color3.new(1, 1, 1); TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = TitleBar
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 44, 0, 28)
    LangBtn.Position = UDim2.new(1, -86, 0.5, -14)
    LangBtn.BackgroundColor3 = COL.accent2
    LangBtn.Text = LL.Language == "ru" and "RU" or "EN"
    LangBtn.TextColor3 = Color3.new(1,1,1)
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.TextSize = 13
    LangBtn.Parent = TitleBar
    LL.corner(LangBtn, 8)
    LangBtn.MouseButton1Click:Connect(function()
        LL.Language = LL.Language == "ru" and "en" or "ru"
        LL.Notify("Language: " .. LL.Language:upper())
        LL.RebuildUI()
    end)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
    CloseBtn.BackgroundColor3 = COL.red; CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 20; CloseBtn.BorderSizePixel = 0
    CloseBtn.AutoButtonColor = false; CloseBtn.Parent = TitleBar
    LL.corner(CloseBtn, 10)
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
    function LL.MakeDraggable(frame, dragBar)
        local dragging, dragStart, startPos
        dragBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        LL.trackConn(UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local sc = UIScale.Scale > 0 and UIScale.Scale or 1
                local d = (input.Position - dragStart) / sc
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
    end
    LL.MakeDraggable(Main, TitleBar)
    LL.BuildTabs(Main)
    LL.RefreshAll()
    LL.applyLoadedSettings()
end
function LL.BuildTabs(Main)
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
        b.Text = LL.Loc[LL.Language].Tabs[name] or name
        b.TextColor3 = COL.text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.LayoutOrder = LL.NextOrder()
        b.AutoButtonColor = false
        b.ZIndex = 5
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
            local ok, err = pcall(LL.TabBuilders[name], t.scroll)
            if not ok then warn("[LARP Tab] "..name..": "..tostring(err)) end
            t.built = true
        end
        t.scroll.Visible = true
        t.btn.BackgroundColor3 = COL.accent
        LL.CurrentTab = name
    end
    LL.Tab("Combat", function(parent)
        local L = LL.Loc[LL.Language].Combat
        LL.Section(parent, L.Main)
        LL.Toggle(parent, L.EnableAim, function() return LL.S.Aimbot.Enabled end, function(v) LL.S.Aimbot.Enabled = v end)
        LL.Section(parent, L.TargetWho)
        LL.Toggle(parent, L.TargetPlayers, function() return LL.S.Aimbot.TargetPlayers end, function(v) LL.S.Aimbot.TargetPlayers = v end)
        LL.Toggle(parent, L.TargetNPCs, function() return LL.S.Aimbot.TargetNPCs end, function(v) LL.S.Aimbot.TargetNPCs = v end)
        LL.Section(parent, L.AimBehavior)
        LL.Toggle(parent, L.StickyLock, function() return LL.S.Aimbot.StickyLock end, function(v) LL.S.Aimbot.StickyLock = v end)
        LL.Toggle(parent, L.WallCheck, function() return LL.S.Aimbot.WallCheck end, function(v) LL.S.Aimbot.WallCheck = v end)
        LL.Dropdown(parent, L.AimMode, {"Cursor", "Camera", "Mobile"}, function() return LL.S.Aimbot.Mode end, function(v) LL.S.Aimbot.Mode = v end)
        LL.Slider(parent, L.Smoothness, 0.01, 1, function() return LL.S.Aimbot.Smooth end, function(v) LL.S.Aimbot.Smooth = math.min(v, 0.95) end)
        LL.Slider(parent, L.DistanceWeight, 0, 5, function() return LL.S.Aimbot.DistanceWeight end, function(v) LL.S.Aimbot.DistanceWeight = v end)
        LL.Section(parent, L.FOV)
        LL.Slider(parent, L.CameraFOV, 30, 800, function() return LL.S.Aimbot.CameraFOV end, function(v) LL.S.Aimbot.CameraFOV = v end)
        LL.Slider(parent, L.MobileFOV, 30, 800, function() return LL.S.Aimbot.MobileFOV end, function(v) LL.S.Aimbot.MobileFOV = v end)
        LL.Toggle(parent, L.ShowFOV, function() return LL.S.Aimbot.ShowFOV end, function(v) LL.S.Aimbot.ShowFOV = v end)
        LL.ColorPicker(parent, L.FOVColor, function() return LL.S.Aimbot.FOVColor end, function(v) LL.S.Aimbot.FOVColor = v end)
        LL.Section(parent, L.TargetPart)
        LL.Dropdown(parent, L.AimPart, {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, function() return LL.S.Aimbot.Part end, function(v) LL.S.Aimbot.Part = v end)
        LL.Section(parent, L.Prediction)
        LL.Toggle(parent, L.PredictLead, function() return LL.S.Aimbot.PredictLead end, function(v) LL.S.Aimbot.PredictLead = v end)
        LL.Toggle(parent, L.HitscanMode, function() return LL.S.Aimbot.HitscanMode end, function(v) LL.S.Aimbot.HitscanMode = v end)
        LL.Slider(parent, L.BulletSpeed, 100, 5000, function() return LL.S.Aimbot.BulletSpeed end, function(v) LL.S.Aimbot.BulletSpeed = math.floor(v + 0.5) end)
        LL.Slider(parent, L.LeadMultiplier, 0.3, 2.0, function() return LL.S.Aimbot.LeadMultiplier end, function(v) LL.S.Aimbot.LeadMultiplier = v end)
        LL.Section(parent, L.Jitter)
        LL.Toggle(parent, L.EnableJitter, function() return LL.S.Aimbot.JitterEnabled end, function(v) LL.S.Aimbot.JitterEnabled = v end)
        LL.Slider(parent, L.JitterAmount, 0, 5, function() return LL.S.Aimbot.Jitter end, function(v) LL.S.Aimbot.Jitter = v end)
        LL.Section(parent, L.CombatVisuals)
        LL.Toggle(parent, L.HitboxVisualizer, function() return LL.S.Aimbot.HitboxVisualizer end, function(v) LL.S.Aimbot.HitboxVisualizer = v end)
        LL.Toggle(parent, L.AimAssistBeam, function() return LL.S.Aimbot.AimAssistBeam end, function(v) LL.S.Aimbot.AimAssistBeam = v end)
        LL.ColorPicker(parent, L.BeamColor, function() return LL.S.Aimbot.TracerColor end, function(v) LL.S.Aimbot.TracerColor = v end)
        LL.Toggle(parent, L.MicroAdjust, function() return LL.S.Aimbot.MicroAdjust end, function(v) LL.S.Aimbot.MicroAdjust = v end)
        LL.Slider(parent, L.MicroAdjustAmount, 0.1, 3.0, function() return LL.S.Aimbot.MicroAdjustAmount end, function(v) LL.S.Aimbot.MicroAdjustAmount = v end)
        LL.Section(parent, L.SilentAim or "Silent Aim")
        LL.Toggle(parent, L.EnableSilent or "Enable Silent Aim", function() return LL.S.Aimbot.SilentAim end, function(v) LL.S.Aimbot.SilentAim = v end)
        LL.Toggle(parent, L.TargetPlayers or "Players", function() return LL.S.Aimbot.TargetPlayers end, function(v) LL.S.Aimbot.TargetPlayers = v end)
        LL.Toggle(parent, L.TargetNPCs or "NPCs", function() return LL.S.Aimbot.TargetNPCs end, function(v) LL.S.Aimbot.TargetNPCs = v end)
        LL.Dropdown(parent, L.SilentMode or "Mode", {"Silent", "Camera"}, function() return LL.S.Aimbot.SilentMode end, function(v) LL.S.Aimbot.SilentMode = v end)
        LL.Dropdown(parent, L.SilentPart or "Part", {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, function() return LL.S.Aimbot.SilentPart end, function(v) LL.S.Aimbot.SilentPart = v end)
        LL.Slider(parent, L.SilentFOV or "Silent FOV", 30, 800, function() return LL.S.Aimbot.SilentFOV end, function(v) LL.S.Aimbot.SilentFOV = v end)
        LL.Toggle(parent, L.SilentWallCheck or "Wall Check", function() return LL.S.Aimbot.SilentWallCheck end, function(v) LL.S.Aimbot.SilentWallCheck = v end)
        LL.Slider(parent, L.SilentSmooth or "Smoothness", 0.01, 1, function() return LL.S.Aimbot.SilentSmooth end, function(v) LL.S.Aimbot.SilentSmooth = math.min(v, 0.95) end)
        LL.Toggle(parent, L.SilentShowFOV or "Show FOV Circle", function() return LL.S.Aimbot.SilentShowFOV end, function(v) LL.S.Aimbot.SilentShowFOV = v end)
    end)
LL.Tab("ESP", function(parent)
    local L = LL.Loc[LL.Language].ESP
    LL.Section(parent, L.Toggle)
    LL.Toggle(parent, L.EnableESP, function() return LL.S.ESP.Enabled end, function(v) LL.S.ESP.Enabled = v end)
    LL.Toggle(parent, L.AutoRefresh, function() return LL.S.ESP.RealTimeRefresh end, function(v) LL.S.ESP.RealTimeRefresh = v end)
    LL.Slider(parent, L.MaxDistance, 100, 3000, function() return LL.S.ESP.MaxDistance end, function(v) LL.S.ESP.MaxDistance = math.floor(v + 0.5) end)
    LL.Section(parent, L.Highlight)
    LL.ColorPicker(parent, L.OutlineColor, function() return LL.S.ESP.OutlineColor end, function(v) LL.S.ESP.OutlineColor = v; LL.RefreshESPColors() end)
    LL.ColorPicker(parent, L.FillColor, function() return LL.S.ESP.FillColor end, function(v) LL.S.ESP.FillColor = v; LL.RefreshESPColors() end)
    LL.Slider(parent, L.FillTransparency, 0, 1, function() return LL.S.ESP.FillTransparency end, function(v) LL.S.ESP.FillTransparency = v; LL.RefreshESPColors() end)
    LL.Slider(parent, L.OutlineTransparency, 0, 1, function() return LL.S.ESP.OutlineTransparency end, function(v) LL.S.ESP.OutlineTransparency = v; LL.RefreshESPColors() end)
    LL.Toggle(parent, L.ThroughWalls, function() return LL.S.ESP.ThroughWalls end, function(v) LL.S.ESP.ThroughWalls = v; LL.RefreshESPColors() end)
    LL.Section(parent, L.Nicks)
    LL.Toggle(parent, L.ShowName, function() return LL.S.ESP.ShowName end, function(v) LL.S.ESP.ShowName = v end)
    LL.ColorPicker(parent, L.NickColor, function() return LL.S.ESP.NickColor end, function(v) LL.S.ESP.NickColor = v end)
    LL.Slider(parent, L.NickSize, 10, 24, function() return LL.S.ESP.NickSize end, function(v) LL.S.ESP.NickSize = math.floor(v + 0.5) end)
    LL.Section(parent, L.HPBar)
    LL.Toggle(parent, L.ShowHPBar, function() return LL.S.ESP.ShowHPBar end, function(v) LL.S.ESP.ShowHPBar = v end)
    LL.Toggle(parent, L.HPDynamicColor, function() return LL.S.ESP.HPDynamicColor end, function(v) LL.S.ESP.HPDynamicColor = v end)
    LL.ColorPicker(parent, L.HPBarColor, function() return LL.S.ESP.HPBarColor end, function(v) LL.S.ESP.HPBarColor = v end)
    LL.Slider(parent, L.HPBarWidth, 20, 120, function() return LL.S.ESP.HPBarWidth end, function(v) LL.S.ESP.HPBarWidth = math.floor(v + 0.5) end)
    LL.Slider(parent, L.HPBarHeight, 2, 12, function() return LL.S.ESP.HPBarHeight end, function(v) LL.S.ESP.HPBarHeight = math.floor(v + 0.5) end)
    LL.Section(parent, L.Distance)
    LL.Toggle(parent, L.ShowDistance, function() return LL.S.ESP.ShowDistance end, function(v) LL.S.ESP.ShowDistance = v end)
    LL.Section(parent, L.Tracer)
    LL.Toggle(parent, L.EnableTracer, function() return LL.S.ESP.TracerEnabled end, function(v) LL.S.ESP.TracerEnabled = v end)
    LL.ColorPicker(parent, L.TracerFrom, function() return LL.S.ESP.TracerFrom end, function(v) LL.S.ESP.TracerFrom = v end)
    LL.ColorPicker(parent, L.TracerTo, function() return LL.S.ESP.TracerTo end, function(v) LL.S.ESP.TracerTo = v end)
    LL.Section(parent, L.NPCESP)
    LL.Toggle(parent, L.EnableNPCESP, function() return LL.S.ESP.NPCEnabled end, function(v)
        LL.S.ESP.NPCEnabled = v
        if v then pcall(function() LL.refreshNPCCache() end) end
    end)
    LL.Toggle(parent, L.NPCName, function() return LL.S.ESP.NPCName end, function(v) LL.S.ESP.NPCName = v end)
    LL.Toggle(parent, L.NPCDistance, function() return LL.S.ESP.NPCDistance end, function(v) LL.S.ESP.NPCDistance = v end)
    LL.Toggle(parent, L.NPCHPBar, function() return LL.S.ESP.NPCHPBar end, function(v) LL.S.ESP.NPCHPBar = v end)
end)
LL.Tab("Player", function(parent)
    local L = LL.Loc[LL.Language].Player
    local function captureOriginals()
        local hum = LL.Cache.Humanoid
        if hum then
            if not LL.S.Player.OrigWalkSpeed then LL.S.Player.OrigWalkSpeed = hum.WalkSpeed end
            if not LL.S.Player.OrigJumpPower then LL.S.Player.OrigJumpPower = hum.JumpPower end
        end
    end
    LL.Section(parent, L.Movement)
    LL.Toggle(parent, L.WalkSpeedEnabled, function() return LL.S.Player.WalkSpeedEnabled end, function(v)
        if v then captureOriginals() end
        LL.S.Player.WalkSpeedEnabled = v
    end)
    LL.Slider(parent, L.WalkSpeed, 16, 300, function() return LL.S.Player.WalkSpeed end, function(v) LL.S.Player.WalkSpeed = v end)
    LL.Toggle(parent, L.JumpPowerEnabled, function() return LL.S.Player.JumpPowerEnabled end, function(v)
        if v then captureOriginals() end
        LL.S.Player.JumpPowerEnabled = v
    end)
    LL.Slider(parent, L.JumpPower, 50, 300, function() return LL.S.Player.JumpPower end, function(v) LL.S.Player.JumpPower = v end)
    LL.Toggle(parent, L.InfiniteJump, function() return LL.S.Player.InfiniteJump end, function(v) LL.S.Player.InfiniteJump = v end)
    LL.Toggle(parent, L.Noclip, function() return LL.S.Player.Noclip end, function(v) LL.S.Player.Noclip = v end)
    LL.Section(parent, L.Fly)
    LL.Toggle(parent, L.Fly, function() return LL.S.Player.Fly end, function(v) LL.S.Player.Fly = v end)
    LL.Slider(parent, L.FlySpeed, 10, 300, function() return LL.S.Player.FlySpeed end, function(v) LL.S.Player.FlySpeed = v end)
    LL.Section(parent, L.Gravity)
    LL.Toggle(parent, L.ZeroGravity, function() return LL.S.Player.ZeroGravity end, function(v) LL.S.Player.ZeroGravity = v; LL.applyGravityState() end)
    LL.Section(parent, L.Coordinates)
    LL.Button(parent, L.SavePos, function()
        local hrp = LL.Cache.HRP
        if hrp then
            LL.S.Player.SavedPos = hrp.CFrame
            LL.MarkDirty()
            LL.Notify("Позиция сохранена")
        end
    end)
    LL.Button(parent, L.LoadPos, function()
        local hrp = LL.Cache.HRP
        if hrp and LL.S.Player.SavedPos then
            hrp.CFrame = LL.S.Player.SavedPos
            LL.Notify("Позиция загружена")
        else
            LL.Notify("Нет сохранённой позиции")
        end
    end)
    LL.Button(parent, L.ClearPos, function()
        LL.S.Player.SavedPos = nil
        LL.MarkDirty()
        LL.Notify("Позиция очищена")
    end)
    LL.Section(parent, L.Utility)
    LL.Toggle(parent, L.AntiAFK, function() return LL.S.Player.AntiAFK end, function(v)
        LL.S.Player.AntiAFK = v
        if v then LL.startAntiAFK() else LL.stopAntiAFK() end
    end)
    LL.Toggle(parent, L.LazyMode, function() return LL.S.Player.LazyMode end, function(v) LL.S.Player.LazyMode = v end)
    LL.Toggle(parent, L.FPSBooster, function() return LL.S.Player.FPSBooster end, function(v)
        LL.S.Player.FPSBooster = v
        if v then LL.enableFPSBooster() else LL.disableFPSBooster() end
    end)
    LL.Toggle(parent, L.LowQuality, function() return LL.S.Player.LowQuality end, function(v)
        LL.S.Player.LowQuality = v
        if v then LL.enableLowQuality() else LL.disableLowQuality() end
    end)
    LL.Toggle(parent, L.Fullbright, function() return LL.S.Player.Fullbright end, function(v)
        LL.S.Player.Fullbright = v
        if v then LL.enableFullbright() else LL.disableFullbright() end
    end)
    LL.Section(parent, L.XNEO)
    LL.Button(parent, L.XNEOBtn, function()
        if LL.Actions and LL.Actions.XNEO then
            LL.Actions.XNEO()
        else
            LL.Notify("XNEO ещё не готов")
        end
    end, {color = COL.accent, hover = Color3.fromRGB(180, 120, 255), textColor = Color3.new(1,1,1)})
end)
LL.Tab("Hitbox", function(parent)
    local L = LL.Loc[LL.Language].Hitbox
    LL.Section(parent, L.Who)
    LL.Dropdown(parent, L.Mode,
        {L.All, L.PlayersOnly, L.NPConly, L.Nobody},
        function()
            if LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport then return L.All
            elseif LL.S.Hitbox.Enabled and not LL.S.Hitbox.NPCSupport then return L.PlayersOnly
            elseif not LL.S.Hitbox.Enabled and LL.S.Hitbox.NPCSupport then return L.NPConly
            else return L.Nobody end
        end,
        function(v)
            if v == L.All then
                LL.S.Hitbox.Enabled = true
                LL.S.Hitbox.NPCSupport = true
            elseif v == L.PlayersOnly then
                LL.S.Hitbox.Enabled = true
                LL.S.Hitbox.NPCSupport = false
                LL.ClearAllNPCHitboxes()
            elseif v == L.NPConly then
                LL.S.Hitbox.Enabled = false
                LL.S.Hitbox.NPCSupport = true
                LL.ClearAllHitboxes()
            else
                LL.S.Hitbox.Enabled = false
                LL.S.Hitbox.NPCSupport = false
                LL.ClearAllHitboxes()
                LL.ClearAllNPCHitboxes()
            end
        end)
    LL.Toggle(parent, L.AutoRefresh, function() return LL.S.Hitbox.RealTimeRefresh end, function(v) LL.S.Hitbox.RealTimeRefresh = v end)
    LL.Section(parent, L.Parts)
    LL.Toggle(parent, L.HeadHitbox, function() return LL.S.Hitbox.HeadEnabled end, function(v) LL.S.Hitbox.HeadEnabled = v; LL.RefreshHitboxes() end)
    LL.Toggle(parent, L.BodyHitbox, function() return LL.S.Hitbox.BodyEnabled end, function(v) LL.S.Hitbox.BodyEnabled = v; LL.RefreshHitboxes() end)
    LL.Section(parent, L.Sizes)
    LL.Slider(parent, L.RootSize, 2, 30, function() return LL.S.Hitbox.RootSize end, function(v) LL.S.Hitbox.RootSize = v; LL.RefreshHitboxes() end)
    LL.Slider(parent, L.HeadSize, 1, 15, function() return LL.S.Hitbox.HeadSize end, function(v) LL.S.Hitbox.HeadSize = v; LL.RefreshHitboxes() end)
    LL.Slider(parent, L.BodySize, 2, 25, function() return LL.S.Hitbox.BodySize end, function(v) LL.S.Hitbox.BodySize = v; LL.RefreshHitboxes() end)
end)
LL.Tab("Macro", function(parent)
    local L = LL.Loc[LL.Language].Macro
    LL.Section(parent, L.Settings)
    LL.TextBox(parent, L.MacroName, "macro1", function() return LL.S.Macro.CurrentMacro end, function(v) LL.S.Macro.CurrentMacro = (v ~= "" and v) or "macro1" end)
    LL.Slider(parent, L.SampleRate, 0.05, 1.0, function() return LL.S.Macro.SampleRate end, function(v) LL.S.Macro.SampleRate = math.floor(v * 100 + 0.5) / 100 end)
    LL.Toggle(parent, L.Loop, function() return LL.S.Macro.Loop end, function(v) LL.S.Macro.Loop = v end)
    LL.Toggle(parent, L.JumpDetection, function() return LL.S.Macro.JumpDetection end, function(v) LL.S.Macro.JumpDetection = v end)
    LL.Section(parent, L.Advanced)
    LL.Toggle(parent, L.IgnoreObstacles, function() return LL.S.Macro.IgnoreObstacles end, function(v)
        LL.S.Macro.IgnoreObstacles = v
        LL.Notify("Ignore Obstacles: "..(v and "ON" or "OFF"))
    end)
    LL.Toggle(parent, L.PushThrough, function() return LL.S.Macro.PushThrough end, function(v)
        LL.S.Macro.PushThrough = v
        LL.Notify("Push Through: "..(v and "ON" or "OFF"))
    end)
    LL.Section(parent, L.Record)
    local recBtn = LL.Button(parent, L.StartRecord, function()
        if LL.S.Macro.Recording then
            LL.MacroStopRecording()
        else
            LL.MacroStartRecording()
        end
    end)
    LL.MacroRecBtn = recBtn
    LL.MacroRecBtnUpdate = function()
        if LL.S.Macro.Recording then
            recBtn.Text = L.StopRecord.." ("..tostring(#(LL.MacroRecord or {}))..")"
            recBtn.BackgroundColor3 = COL.red
            recBtn.TextColor3 = Color3.new(1,1,1)
        else
            recBtn.Text = L.StartRecord
            recBtn.BackgroundColor3 = COL.elem
            recBtn.TextColor3 = COL.text
        end
    end
    LL.MacroRecBtnUpdate()
    LL.AddRefresh(LL.MacroRecBtnUpdate)
    LL.Section(parent, L.Play)
    local playBtn = LL.Button(parent, L.PlayMacro, function()
        if LL.S.Macro.Playing then
            LL.MacroStopPlaying()
        else
            LL.MacroStartPlaying(LL.S.Macro.CurrentMacro)
        end
    end, {color = COL.accent, hover = Color3.fromRGB(180, 120, 255), textColor = Color3.new(1,1,1)})
    LL.AddRefresh(function()
        if LL.S.Macro.Playing then
            playBtn.Text = L.StopMacro
            playBtn.BackgroundColor3 = COL.red
        else
            playBtn.Text = L.PlayMacro
            playBtn.BackgroundColor3 = COL.accent
        end
    end)
    LL.Button(parent, L.StopAndReturn, function()
        LL.MacroStopPlaying()
        LL.MacroReturnToStart()
    end, {color = COL.elemHover})
    LL.Section(parent, L.Manage)
    LL.Button(parent, L.SaveRecord, function()
        if not LL.MacroRecord or #LL.MacroRecord < 2 then
            LL.Notify("Нечего сохранять — запиши сначала")
            return
        end
        local name = LL.S.Macro.CurrentMacro or "macro1"
        LL.Macros[name] = LL.MacroRecord
        LL.MacroRecord = nil
        LL.Notify("Сохранён: "..name.." ("..#LL.Macros[name].." точек)")
        if LL.MacroRefreshList then LL.MacroRefreshList() end
        if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
    end)
    LL.Button(parent, L.DeleteCurrent, function()
        local name = LL.S.Macro.CurrentMacro or "macro1"
        LL.Macros[name] = nil
        LL.Notify("Удалён: "..name)
        if LL.MacroRefreshList then LL.MacroRefreshList() end
    end, {textColor = COL.red})
    LL.Button(parent, L.DeleteAll, function()
        LL.Macros = {}
        LL.MacroRecord = nil
        LL.Notify("Все макросы удалены")
        if LL.MacroRefreshList then LL.MacroRefreshList() end
    end, {textColor = COL.red})
    LL.Section(parent, L.List)
    local listLbl = Instance.new("TextLabel")
    listLbl.Size = UDim2.new(1, 0, 0, 120)
    listLbl.BackgroundColor3 = COL.elem
    listLbl.BackgroundTransparency = 0.05
    listLbl.BorderSizePixel = 0
    listLbl.LayoutOrder = LL.NextOrder()
    listLbl.TextColor3 = COL.sub
    listLbl.Font = Enum.Font.Gotham
    listLbl.TextSize = 13
    listLbl.TextWrapped = true
    listLbl.TextXAlignment = Enum.TextXAlignment.Left
    listLbl.TextYAlignment = Enum.TextYAlignment.Top
    listLbl.Parent = parent
    LL.corner(listLbl, 12)
    LL.stroke(listLbl, COL.stroke, 1)
    LL.padding(listLbl, 8, 12, 12, 8)
    LL.MacroRefreshList = function()
        local lines = {}
        for name, pts in pairs(LL.Macros) do
            table.insert(lines, "• "..name.." ("..#pts.." точек)")
        end
        if #lines == 0 then
            listLbl.Text = L.Empty
        else
            table.sort(lines)
            listLbl.Text = table.concat(lines, "\n")
        end
    end
    LL.MacroRefreshList()
end)
LL.Tab("AutoClicker", function(parent)
    local L = LL.Loc[LL.Language].AutoClicker or {}
    LL.Section(parent, L.Title or "AutoClicker")
    LL.Toggle(parent, L.Enable or "Enable AutoClicker", function() return LL.S.AutoClicker.Enabled end, function(v)
        LL.S.AutoClicker.Enabled = v
        LL.Notify("AutoClicker: " .. (v and "ON" or "OFF"))
    end)
    LL.Section(parent, L.Speed or "Speed")
    LL.Slider(parent, L.Speed or "Speed (clicks/sec)", 1, 100, function() return LL.S.AutoClicker.Speed end, function(v) LL.S.AutoClicker.Speed = math.floor(v + 0.5) end)
    LL.Section(parent, L.Button or "Button")
    LL.Dropdown(parent, L.Button or "Button", {L.Left or "Left", L.Right or "Right"}, function() return LL.S.AutoClicker.Button == "Right" and (L.Right or "Right") or (L.Left or "Left") end, function(v) LL.S.AutoClicker.Button = (v == (L.Right or "Right")) and "Right" or "Left" end)
    LL.Section(parent, L.Mode or "Mode")
    LL.Dropdown(parent, L.Mode or "Mode", {L.ModeVirtual or "Virtual", L.ModeReal or "Real (Cursor)"}, function() return LL.S.AutoClicker.Mode == "Real" and (L.ModeReal or "Real (Cursor)") or (L.ModeVirtual or "Virtual") end, function(v) LL.S.AutoClicker.Mode = (v == (L.ModeReal or "Real (Cursor)")) and "Real" or "Virtual" end)
    LL.Section(parent, "Info")
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(1, 0, 0, 80)
    infoLbl.BackgroundColor3 = COL.elem
    infoLbl.BackgroundTransparency = 0.05
    infoLbl.BorderSizePixel = 0
    infoLbl.LayoutOrder = LL.NextOrder()
    infoLbl.TextColor3 = COL.sub
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 13
    infoLbl.TextWrapped = true
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.TextYAlignment = Enum.TextYAlignment.Top
    infoLbl.Text = L.Info or ""
    infoLbl.Parent = parent
    LL.corner(infoLbl, 12)
    LL.stroke(infoLbl, COL.stroke, 1)
    LL.padding(infoLbl, 8, 12, 12, 8)
end)
LL.Tab("Settings", function(parent)
    local L = LL.Loc[LL.Language].Settings
    LL.Section(parent, L.Actions)
    LL.Button(parent, L.ResetSettings, function()
        local S = LL.S
        S.Aimbot.Enabled=false; S.Aimbot.Smooth=0.25
        S.Aimbot.CameraFOV=200; S.Aimbot.MobileFOV=200
        S.Aimbot.DistanceWeight=1; S.Aimbot.WallCheck=false
        S.Aimbot.JitterEnabled=false; S.Aimbot.Jitter=1.5
        S.Aimbot.HitboxVisualizer=false; S.Aimbot.AimAssistBeam=false
        S.Aimbot.MicroAdjust=false; S.Aimbot.MicroAdjustAmount=1.0
        S.Aimbot.SilentAim=false; S.Aimbot.SilentMode="Silent"
        S.Aimbot.SilentFOV=200; S.Aimbot.SilentPart="Head"
        S.Aimbot.SilentWallCheck=false; S.Aimbot.SilentSmooth=0.3
        S.Aimbot.SilentShowFOV=true
        S.ESP.Enabled=false; S.ESP.NPCEnabled=false
        S.Hitbox.Enabled=false; S.Hitbox.NPCSupport=false
        S.Player.Fly=false
        S.Player.Noclip=false; S.Player.InfiniteJump=false
        S.Player.ZeroGravity=false
        S.Player.WalkSpeed=16; S.Player.JumpPower=50
        S.Player.WalkSpeedEnabled=false; S.Player.JumpPowerEnabled=false
        S.Player.AntiAFK=false; LL.stopAntiAFK()
        S.Player.FPSBooster=false; LL.disableFPSBooster()
        S.Player.LowQuality=false; LL.disableLowQuality()
        S.Player.Fullbright=false; LL.disableFullbright()
        S.Troll.AntiFling=false
        S.AutoClicker.Enabled=false; S.AutoClicker.Speed=10
        S.AutoClicker.Button="Left"; S.AutoClicker.Mode="Virtual"
        S.Macro.IgnoreObstacles=false; S.Macro.PushThrough=false
        S.FloatingLock=false; S.FloatingPos={}
        LL.ApplyFloatingLock()
        LL.RepositionAllFloatingBtns()
        LL.applyGravityState()
        LL.RefreshAll(); LL.MarkDirty(); LL.Notify("Настройки сброшены")
    end)
    LL.Button(parent, L.Unload, function()
        if getgenv().TIMON_UNLOAD then pcall(getgenv().TIMON_UNLOAD)
        else LL.Notify("Unload не готов") end
    end, {color = COL.accent2, hover = Color3.fromRGB(255, 120, 210), textColor = Color3.new(1,1,1)})
    LL.Section(parent, L.UISettings)
    LL.Slider(parent, L.UIScale, 0.6, 1.2, function() return LL.S.UI.Scale end, function(v) LL.S.UI.Scale = v; LL.ApplyMainSize() end)
    LL.Toggle(parent, L.Notifications, function() return LL.S.UI.Notifications end, function(v) LL.S.UI.Notifications = v end)
    LL.Toggle(parent, L.AutoHideMobile, function() return LL.S.UI.AutoHideOnMobile end, function(v) LL.S.UI.AutoHideOnMobile = v end)
    LL.Section(parent, L.Configs)
    if not LL.FS_AVAILABLE then
        local warnLbl = Instance.new("TextLabel")
        warnLbl.Size = UDim2.new(1, 0, 0, 40); warnLbl.BackgroundColor3 = COL.red
        warnLbl.BackgroundTransparency = 0.7; warnLbl.BorderSizePixel = 0; warnLbl.LayoutOrder = LL.NextOrder()
        warnLbl.Text = "⚠ Экзекутор не поддерживает файловую систему"; warnLbl.TextColor3 = COL.text
        warnLbl.Font = Enum.Font.GothamBold; warnLbl.TextSize = 13; warnLbl.Parent = parent
        LL.corner(warnLbl, 12)
    end
    LL.TextBox(parent, L.ConfigName, "auto", function() return LL.S.ConfigName end, function(v) LL.S.ConfigName = (v ~= "" and v) or "auto" end)
    LL.Button(parent, L.SaveConfig, function()
        local name = LL.S.ConfigName or "auto"
        local ok, err = LL.saveConfig(name)
        if ok then
            LL.Notify("Сохранено: "..name)
            if LL.RefreshCfgList then LL.RefreshCfgList() end
        else LL.Notify("Ошибка: "..tostring(err)) end
    end)
    LL.Button(parent, L.LoadConfig, function()
        local name = LL.S.ConfigName or "auto"
        if LL.loadConfigFile(name) then
            LL.applyLoadedSettings()
            LL.Notify("Загружено: "..name)
        else LL.Notify("Не найден: "..name) end
    end)
    LL.Button(parent, L.DeleteConfig, function()
        local name = LL.S.ConfigName or "auto"
        LL.deleteConfig(name)
        LL.Notify("Удалено: "..name)
        if LL.RefreshCfgList then LL.RefreshCfgList() end
    end)
    LL.Toggle(parent, L.AutoSave, function() return LL.S.AutoSave end, function(v) LL.S.AutoSave = v end)
    LL.Section(parent, L.AvailableConfigs)
    local cfgListLbl = Instance.new("TextLabel")
    cfgListLbl.Size = UDim2.new(1, 0, 0, 100); cfgListLbl.BackgroundColor3 = COL.elem
    cfgListLbl.BackgroundTransparency = 0.05; cfgListLbl.BorderSizePixel = 0; cfgListLbl.LayoutOrder = LL.NextOrder()
    cfgListLbl.TextColor3 = COL.sub; cfgListLbl.Font = Enum.Font.Gotham; cfgListLbl.TextSize = 13
    cfgListLbl.TextWrapped = true; cfgListLbl.TextXAlignment = Enum.TextXAlignment.Left
    cfgListLbl.TextYAlignment = Enum.TextYAlignment.Top; cfgListLbl.Parent = parent
    LL.corner(cfgListLbl, 12); LL.stroke(cfgListLbl, COL.stroke, 1)
    LL.padding(cfgListLbl, 8, 16, 12, 8)
    LL.RefreshCfgList = function()
        local list = LL.listConfigs()
        if #list == 0 then cfgListLbl.Text = L.EmptyConfigs
        else table.sort(list); cfgListLbl.Text = table.concat(list, "\n") end
    end
    LL.RefreshCfgList()
end)
    LL.Tab("Binds", function(parent)
        local L = LL.Loc[LL.Language].Binds
        LL.Section(parent, L.Title)
        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 36); searchBox.BackgroundColor3 = COL.elem
        searchBox.BorderSizePixel = 0; searchBox.PlaceholderText = L.Search
        searchBox.Text = ""; searchBox.TextColor3 = COL.text; searchBox.PlaceholderColor3 = COL.sub
        searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 13; searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ClearTextOnFocus = false; searchBox.LayoutOrder = LL.NextOrder(); searchBox.ZIndex = 10; searchBox.Parent = parent
        LL.corner(searchBox, 12); LL.stroke(searchBox, COL.stroke, 1); LL.padding(searchBox, 0, 12, 0, 0)
        local bindList = Instance.new("Frame")
        bindList.Size = UDim2.new(1, 0, 0, 0); bindList.BackgroundTransparency = 1
        bindList.AutomaticSize = Enum.AutomaticSize.Y; bindList.LayoutOrder = LL.NextOrder(); bindList.Parent = parent
        local bindLayout = Instance.new("UIListLayout")
        bindLayout.Padding = UDim.new(0, 6); bindLayout.SortOrder = Enum.SortOrder.LayoutOrder; bindLayout.Parent = bindList
        local bindEntries = {}
        local function addBind(action, name)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = COL.elem
            f.BackgroundTransparency = 0.05; f.BorderSizePixel = 0; f.Parent = bindList
            f.Visible = true
            LL.corner(f, 12); LL.stroke(f, COL.stroke, 1)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -130, 1, 0); lbl.Position = UDim2.new(0, 16, 0, 0)
            lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = COL.text
            lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
            local keyLbl = Instance.new("TextLabel")
            keyLbl.Size = UDim2.new(0, 108, 0, 28); keyLbl.Position = UDim2.new(1, -120, 0.5, -14)
            keyLbl.BackgroundColor3 = COL.bg2; keyLbl.BorderSizePixel = 0; keyLbl.TextColor3 = COL.accent2
            keyLbl.Font = Enum.Font.GothamBold; keyLbl.TextSize = 13; keyLbl.Parent = f
            LL.corner(keyLbl, 8)
            local function refresh()
                local k = LL.S.Binds[action]
                if k then
                    keyLbl.Text = tostring(k):gsub("Enum.KeyCode.","")
                    keyLbl.TextColor3 = COL.accent2
                else
                    keyLbl.Text = "None"; keyLbl.TextColor3 = COL.sub
                end
            end
            refresh(); LL.BindRefreshers[action] = refresh
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 108, 0, 28); btn.Position = UDim2.new(1, -120, 0.5, -14)
            btn.BackgroundTransparency = 1; btn.Text = ""; btn.Active = true; btn.ZIndex = 10; btn.Parent = f
            btn.MouseButton1Down:Connect(function()
                getgenv().TIMON_LISTENING = action
                keyLbl.Text = "нажми..."; keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            end)
            bindEntries[#bindEntries+1] = {frame = f, name = name, action = action}
        end
        addBind("Aimbot", L.Aimbot)
        addBind("AimbotHold", L.AimbotHold)
        addBind("ESP", L.ESP)
        addBind("Hitbox", L.Hitbox)
        addBind("Fly", L.Fly)
        addBind("Noclip", L.Noclip)
        addBind("InfiniteJump", L.InfiniteJump)
        addBind("ZeroGravity", L.ZeroGravity)
        addBind("SavePos", L.SavePos)
        addBind("LoadPos", L.LoadPos)
        addBind("Macro", L.Macro)
        addBind("MacroRecord", L.MacroRecord)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(searchBox.Text)
            for _, e in ipairs(bindEntries) do
                if q == "" or string.find(string.lower(e.name), q, 1, true) then e.frame.Visible = true
                else e.frame.Visible = false end
            end
        end)
        LL.Button(parent, L.ResetBinds, function()
            LL.S.Binds = {}
            for _, fn in pairs(LL.BindRefreshers) do pcall(fn) end
            LL.MarkDirty(); LL.Notify("Бинды сброшены")
        end, {textColor = COL.accent2})
        LL.Section(parent, L.FloatingLock)
        LL.Toggle(parent, L.FloatingLock, function() return LL.S.FloatingLock end, function(v)
            LL.S.FloatingLock = v
            LL.ApplyFloatingLock(); LL.MarkDirty()
            LL.Notify("Floating: "..(v and "LOCKED" or "FREE"))
        end)
        LL.Button(parent, L.ResetPositions, function()
            LL.S.FloatingPos = {}
            LL.RepositionAllFloatingBtns()
            LL.MarkDirty(); LL.Notify("Позиции сброшены")
        end, {textColor = COL.accent2})
        LL.Section(parent, L.FloatingButtons)
        LL.Toggle(parent, "Aimbot Button", function() return LL.S.MobileBtns.Aimbot == true end, function(v) LL.S.MobileBtns.Aimbot = v; LL.ToggleMobileBtn("Aimbot", v) end)
        LL.Toggle(parent, "Noclip Button", function() return LL.S.MobileBtns.Noclip == true end, function(v) LL.S.MobileBtns.Noclip = v; LL.ToggleMobileBtn("Noclip", v) end)
        LL.Toggle(parent, "Anti Fling Button", function() return LL.S.MobileBtns.AntiFling == true end, function(v) LL.S.MobileBtns.AntiFling = v; LL.ToggleMobileBtn("AntiFling", v) end)
        LL.Toggle(parent, "Zero Gravity Button", function() return LL.S.MobileBtns.ZeroGravity == true end, function(v) LL.S.MobileBtns.ZeroGravity = v; LL.ToggleMobileBtn("ZeroGravity", v) end)
        LL.Toggle(parent, "ESP Button", function() return LL.S.MobileBtns.ESP == true end, function(v) LL.S.MobileBtns.ESP = v; LL.ToggleMobileBtn("ESP", v) end)
        LL.Toggle(parent, "Hitbox Button", function() return LL.S.MobileBtns.Hitbox == true end, function(v) LL.S.MobileBtns.Hitbox = v; LL.ToggleMobileBtn("Hitbox", v) end)
        LL.Toggle(parent, "Macro Button", function() return LL.S.MobileBtns.Macro == true end, function(v) LL.S.MobileBtns.Macro = v; LL.ToggleMobileBtn("Macro", v) end)
        LL.Toggle(parent, "Macro Record Button", function() return LL.S.MobileBtns.MacroRecord == true end, function(v) LL.S.MobileBtns.MacroRecord = v; LL.ToggleMobileBtn("MacroRecord", v) end)
    end)
    LL.Tab("Info", function(parent)
        local L = LL.Loc[LL.Language].Info
        LL.Section(parent, L.Title)
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(1, 0, 0, 180)
        infoFrame.BackgroundColor3 = COL.elem
        infoFrame.BackgroundTransparency = 0.05
        infoFrame.BorderSizePixel = 0
        infoFrame.LayoutOrder = LL.NextOrder()
        infoFrame.Parent = parent
        LL.corner(infoFrame, 12); LL.stroke(infoFrame, COL.stroke, 1)
        LL.padding(infoFrame, 12, 16, 16, 12)
        local ownerLbl = Instance.new("TextLabel")
        ownerLbl.Size = UDim2.new(1, 0, 0, 24)
        ownerLbl.BackgroundTransparency = 1
        ownerLbl.Text = L.Owner..": @ForchanW"
        ownerLbl.TextColor3 = COL.accent2
        ownerLbl.Font = Enum.Font.GothamBold
        ownerLbl.TextSize = 15
        ownerLbl.TextXAlignment = Enum.TextXAlignment.Left
        ownerLbl.Parent = infoFrame
        local channelLbl = Instance.new("TextLabel")
        channelLbl.Size = UDim2.new(1, 0, 0, 24)
        channelLbl.Position = UDim2.new(0, 0, 0, 28)
        channelLbl.BackgroundTransparency = 1
        channelLbl.Text = L.Channel..": @luaLARP"
        channelLbl.TextColor3 = COL.accent2
        channelLbl.Font = Enum.Font.GothamBold
        channelLbl.TextSize = 15
        channelLbl.TextXAlignment = Enum.TextXAlignment.Left
        channelLbl.Parent = infoFrame
        local noteLbl = Instance.new("TextLabel")
        noteLbl.Size = UDim2.new(1, 0, 0, 100)
        noteLbl.Position = UDim2.new(0, 0, 0, 60)
        noteLbl.BackgroundTransparency = 1
        noteLbl.Text = L.Note
        noteLbl.TextColor3 = COL.text
        noteLbl.Font = Enum.Font.Gotham
        noteLbl.TextSize = 13
        noteLbl.TextWrapped = true
        noteLbl.TextXAlignment = Enum.TextXAlignment.Left
        noteLbl.TextYAlignment = Enum.TextYAlignment.Top
        noteLbl.Parent = infoFrame
    end)
    LL.SwitchTab("Combat")
end
function LL.refreshCharCache()
    local char = LP.Character
    LL.Cache.Character = char
    LL.Cache.Humanoid = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)) or nil
    LL.Cache.HRP = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 2)) or nil
end
LL.refreshCharCache()
LL.trackConn(LP.CharacterAdded:Connect(function(char)
    LL.Cache.Character = char
    LL.Cache.Humanoid = char:WaitForChild("Humanoid", 10)
    LL.Cache.HRP = char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.2)
    LL.refreshCharCache()
    if LL.applyGravityState then pcall(LL.applyGravityState) end
    if LL.S and LL.S.Player and LL.S.Player.AntiAFK then pcall(LL.startAntiAFK) end
end))
LL.trackConn(LP.CharacterRemoving:Connect(function()
    LL.Cache.Character = nil
    LL.Cache.Humanoid = nil
    LL.Cache.HRP = nil
end))
LL.LightingMgr = { original=nil, boosterApplied=false, fullbrightApplied=false }
function LL.captureLightingOriginal()
    if LL.LightingMgr.original then return end
    LL.LightingMgr.original = {Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient, Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart, GlobalShadows=Lighting.GlobalShadows}
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
function LL.setBooster(on) LL.captureLightingOriginal(); LL.LightingMgr.boosterApplied = on; LL.applyLightingState() end
function LL.setFullbright(on) LL.captureLightingOriginal(); LL.LightingMgr.fullbrightApplied = on; LL.applyLightingState() end

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

LL.antiAFKThread = nil
LL.lastUserAction = tick()
function LL.startAntiAFK()
    if LL.antiAFKThread then return end
    local hookOk = false
    if LL.ScriptAvailable.Hookfunction and LL.ScriptAvailable.GetConnections then
        pcall(function()
            for _, c in ipairs(getconnections(LP.Idled)) do
                if c and typeof(c.Disable) == "function" then c:Disable() end
            end
            hookOk = true
        end)
    end
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
function LL.applyHitboxToCharacter(entry, character)
    if not character or not entry then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not entry.original then entry.original = {} end
    if hrp then
        if not entry.original.hrpSize then entry.original.hrpSize = hrp.Size end
        if not entry.original.hrpTransparency then entry.original.hrpTransparency = hrp.Transparency end
        if LL.S.Hitbox.BodyEnabled then
            hrp.Size = Vector3.new(LL.S.Hitbox.RootSize, LL.S.Hitbox.RootSize, LL.S.Hitbox.RootSize)
            hrp.Transparency = 1
        else
            hrp.Size = entry.original.hrpSize
            hrp.Transparency = entry.original.hrpTransparency
        end
        hrp.CanCollide = false
    end
    if head then
        if not entry.original.headSize then entry.original.headSize = head.Size end
        if not entry.original.headTransparency then entry.original.headTransparency = head.Transparency end
        if LL.S.Hitbox.HeadEnabled then
            head.Size = Vector3.new(LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize, LL.S.Hitbox.HeadSize)
            head.Transparency = 1
        else
            head.Size = entry.original.headSize
            head.Transparency = entry.original.headTransparency
        end
    end
    if torso then
        if not entry.original.torsoSize then entry.original.torsoSize = torso.Size end
        if not entry.original.torsoTransparency then entry.original.torsoTransparency = torso.Transparency end
        if LL.S.Hitbox.BodyEnabled then
            torso.Size = Vector3.new(LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize, LL.S.Hitbox.BodySize)
            torso.Transparency = 1
        else
            torso.Size = entry.original.torsoSize
            torso.Transparency = entry.original.torsoTransparency
        end
    end
end
function LL.restoreHitbox(entry)
    if not entry or not entry.original then return end
    local chr = entry.character
    if chr then
        local hrp = chr:FindFirstChild("HumanoidRootPart")
        if hrp then
            if entry.original.hrpSize then hrp.Size = entry.original.hrpSize end
            hrp.Transparency = entry.original.hrpTransparency or 0
            hrp.CanCollide = true
        end
        local head = chr:FindFirstChild("Head")
        if head then
            if entry.original.headSize then head.Size = entry.original.headSize end
            head.Transparency = entry.original.headTransparency or 0
        end
        local torso = chr:FindFirstChild("UpperTorso") or chr:FindFirstChild("Torso")
        if torso then
            if entry.original.torsoSize then torso.Size = entry.original.torsoSize end
            torso.Transparency = entry.original.torsoTransparency or 0
        end
    end
end
function LL.ApplyHitbox(pl)
    if pl == LP or not pl.Character then return end
    if not LL.S.Hitbox.Enabled then return end
    local entry = LL.HitboxParts[pl]
    if not entry then
        entry = { character = pl.Character, original = {} }
        LL.HitboxParts[pl] = entry
    end
    if entry.character ~= pl.Character then
        LL.restoreHitbox(entry)
        entry.character = pl.Character
        entry.original = {}
    end
    LL.applyHitboxToCharacter(entry, pl.Character)
end
function LL.RemoveHitboxFor(pl)
    local e = LL.HitboxParts[pl]
    if e then
        LL.restoreHitbox(e)
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
    if LL.S.Hitbox.NPCSupport then
        for model in pairs(LL.NPCHitboxes) do pcall(LL.RemoveNPCHitbox, model) end
        for model in pairs(LL.NPCCache) do pcall(LL.ApplyNPCHitbox, model) end
    end
end
LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(0.2)
        if LL.S.Hitbox.Enabled and not LL.S.Hitbox.RealTimeRefresh then
            for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
        end
    end
end))
function LL.isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end
function LL.isNPC(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if LL.isPlayerCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") and not model:FindFirstChild("Torso") then return false end
    return true
end
function LL.scanWorkspaceOnce()
    local newCache = {}
    local count = 0
    local ok, descendants = pcall(function() return Workspace:GetDescendants() end)
    if not ok or not descendants then return end
    for _, d in ipairs(descendants) do
        if d:IsA("Model") and LL.isNPC(d) then newCache[d] = true end
        count = count + 1
        if count % 200 == 0 then
            task.wait()
            if not getgenv().TIMON_LOADED then return end
        end
    end
    LL.NPCCache = newCache
end
function LL.refreshNPCCache()
    LL.lastNPCRescan = tick()
    LL.scanWorkspaceOnce()
end
LL.trackConn(Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") or d.Name == "HumanoidRootPart" or d.Name == "Torso" or d.Name == "UpperTorso" then
        local m = d.Parent
        if m and m:IsA("Model") and LL.isNPC(m) then LL.NPCCache[m] = true end
    elseif d:IsA("Model") then
        if LL.isNPC(d) then LL.NPCCache[d] = true
        else
            for _, c in ipairs(d:GetChildren()) do
                if (c:IsA("Humanoid") or c.Name == "HumanoidRootPart") and LL.isNPC(d) then
                    LL.NPCCache[d] = true; break
                end
            end
        end
    end
end))
LL.trackConn(Workspace.DescendantRemoving:Connect(function(d)
    if d:IsA("Model") then
        if LL.NPCCache[d] then LL.NPCCache[d] = nil end
        if LL.NPCESPObjs[d] then pcall(LL.RemoveNPCESP, d) end
        if LL.NPCHitboxes[d] then pcall(LL.RemoveNPCHitbox, d) end
    end
end))
LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(10)
        if LL.S.ESP.NPCEnabled or LL.S.Hitbox.NPCSupport or LL.S.Aimbot.TargetNPCs or LL.S.Aimbot.SilentAim then
            pcall(LL.refreshNPCCache)
        end
    end
end))
function LL.ApplyNPCHitbox(model)
    if not model or not model.Parent then return end
    if LL.isPlayerCharacter(model) then return end
    if not LL.S.Hitbox.NPCSupport then LL.RemoveNPCHitbox(model); return end
    local entry = LL.NPCHitboxes[model]
    if not entry then
        entry = { character = model, original = {} }
        LL.NPCHitboxes[model] = entry
    end
    if entry.character ~= model then
        LL.restoreHitbox(entry)
        entry.character = model
        entry.original = {}
    end
    LL.applyHitboxToCharacter(entry, model)
end
function LL.RemoveNPCHitbox(model)
    local e = LL.NPCHitboxes[model]
    if e then
        LL.restoreHitbox(e)
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
        if LL.S.Hitbox.NPCSupport and not LL.S.Hitbox.RealTimeRefresh then
            for model in pairs(LL.NPCCache) do
                if model.Parent then pcall(LL.ApplyNPCHitbox, model) end
            end
            for model in pairs(LL.NPCHitboxes) do
                if not model.Parent or not LL.NPCCache[model] then LL.RemoveNPCHitbox(model) end
            end
        elseif not LL.S.Hitbox.NPCSupport and next(LL.NPCHitboxes) then
            LL.ClearAllNPCHitboxes()
        end
    end
end))
LL.DRAW_AVAILABLE = LL.ScriptAvailable.Drawing
LL.fovCircle = nil
LL.aimBeam = nil
LL.hitboxBox = nil
LL.silentFovCircle = nil
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
        LL.silentFovCircle = Drawing.new("Circle")
        LL.silentFovCircle.Visible = false
        LL.silentFovCircle.Thickness = 1.5
        LL.silentFovCircle.Color = Color3.fromRGB(255, 220, 100)
        LL.silentFovCircle.Transparency = 0.7
    end)
end
function LL.applyHighlight(hl)
    hl.FillColor = LL.S.ESP.FillColor
    hl.FillTransparency = LL.S.ESP.FillTransparency
    hl.OutlineColor = LL.S.ESP.OutlineColor
    hl.OutlineTransparency = LL.S.ESP.OutlineTransparency
    hl.DepthMode = LL.S.ESP.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
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
        pcall(function() t.Font = (Drawing.Fonts and Drawing.Fonts.System) or 1 end)
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
    if not LL.S.ESP.Enabled then return end
    local hl = Instance.new("Highlight")
    hl.Name = "LARP_HL_" .. pl.Name
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
    if not LL.S.ESP.NPCEnabled then return end
    local hl = Instance.new("Highlight")
    hl.Name = "LARP_NPC_HL"
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

LL.StickyTarget = nil
LL.StickyTargetIsNPC = false
LL.aimHoldDown = false
LL.wasHoldActive = false
LL.tryMouseFn = nil
do
    pcall(function() if syn and syn.mousemoverel then LL.tryMouseFn = syn.mousemoverel; return end end)
    if not LL.tryMouseFn then pcall(function() if mousemoverel then LL.tryMouseFn = mousemoverel; return end end) end
    if not LL.tryMouseFn then pcall(function() if mouse and mouse.Move then LL.tryMouseFn = function(dx,dy) mouse.Move(mouse, dx, dy) end end end) end
    if not LL.tryMouseFn then pcall(function() if mouse and mouse.move then LL.tryMouseFn = function(dx,dy) mouse.move(dx, dy) end end end) end
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
            if cur:IsA("Part") and cur.Name:sub(1, 12) == "LARP_HB_" then
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
        if part and LL.IsOnScreen(part) and (not LL.S.Aimbot.WallCheck or LL.IsVisible(part)) then
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
            if pl ~= LP then
                local ch = pl.Character
                if ch then
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
                        if part then
                            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen and sp.Z > 0 then
                                local pd = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
                                if pd <= fovLimit then
                                    if not wallCheck or LL.IsVisible(part) then
                                        local wd = (part.Position - myPos).Magnitude
                                        local score = pd + wd * dw
                                        if score < bestScore then
                                            bestScore = score; target = pl; targetIsNPC = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if targetNPCs then
        if next(LL.NPCCache) == nil and (tick() - LL.lastNPCRescan) > 2 then
            pcall(LL.refreshNPCCache)
        end
        for model in pairs(LL.NPCCache) do
            if not model.Parent then LL.NPCCache[model] = nil end
        end
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
function LL.SilentFindTarget()
    local targetPlayers = LL.S.Aimbot.TargetPlayers
    local targetNPCs = LL.S.Aimbot.TargetNPCs
    if not targetPlayers and not targetNPCs then return nil end
    local cmpPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local fovLimit = LL.S.Aimbot.SilentFOV
    local best, bestScore = nil, math.huge
    local myHRP = LL.Cache.HRP
    local myPos = myHRP and myHRP.Position or Vector3.zero
    local partName = LL.S.Aimbot.SilentPart
    local wallCheck = LL.S.Aimbot.SilentWallCheck
    if targetPlayers then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local ch = pl.Character
                if ch then
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
                        if part then
                            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen and sp.Z > 0 then
                                local pd = (Vector2.new(sp.X, sp.Y) - cmpPos).Magnitude
                                if pd <= fovLimit then
                                    if not wallCheck or LL.IsVisible(part) then
                                        local wd = (part.Position - myPos).Magnitude
                                        local score = pd + wd * 0.1
                                        if score < bestScore then
                                            bestScore = score; best = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if targetNPCs then
        for model in pairs(LL.NPCCache) do
            if model.Parent and not LL.isPlayerCharacter(model) then
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
                                    local score = pd + wd * 0.1
                                    if score < bestScore then
                                        bestScore = score; best = part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end
RunService:BindToRenderStep("LARP_AIM", Enum.RenderPriority.Camera.Value + 1, function()
    if not getgenv().TIMON_LOADED then return end
    if LL.silentFovCircle then
        if LL.S.Aimbot.SilentAim and LL.S.Aimbot.SilentShowFOV then
            LL.silentFovCircle.Visible = true
            LL.silentFovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            LL.silentFovCircle.Radius = LL.S.Aimbot.SilentFOV
        else
            LL.silentFovCircle.Visible = false
        end
    end
    if not LL.S.Aimbot.Enabled then
        if LL.fovCircle then LL.fovCircle.Visible = false end
        if LL.aimBeam then LL.aimBeam.Visible = false end
        if LL.hitboxBox then LL.hitboxBox.Visible = false end
        return
    end
    if LL.S.Aimbot.ShowFOV and LL.S.Aimbot.Mode ~= "Cursor" and LL.fovCircle then
        LL.fovCircle.Visible = true
        LL.fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        LL.fovCircle.Radius = (LL.S.Aimbot.Mode == "Mobile") and LL.S.Aimbot.MobileFOV or LL.S.Aimbot.CameraFOV
        LL.fovCircle.Color = LL.S.Aimbot.FOVColor
    elseif LL.fovCircle then
        LL.fovCircle.Visible = false
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
            dx = dx + (math.random()*2-1) * LL.S.Aimbot.Jitter
            dy = dy + (math.random()*2-1) * LL.S.Aimbot.Jitter
        end
        if LL.S.Aimbot.MicroAdjust and LL.S.Aimbot.MicroAdjustAmount > 0 then
            dx = dx + (math.random()*2-1) * LL.S.Aimbot.MicroAdjustAmount
            dy = dy + (math.random()*2-1) * LL.S.Aimbot.MicroAdjustAmount
        end
        local ok = pcall(LL.tryMouseFn, dx, dy)
        if ok then return end
    end
    local lookCF = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookCF, LL.S.Aimbot.Smooth)
end)
LL.MacroRecordLoopThread = nil
LL.MacroJumpConn = nil
function LL.MacroStartRecording()
    if LL.S.Macro.Recording then return end
    if LL.refreshCharCache then LL.refreshCharCache() end
    local chr = LP.Character
    local hum = chr and chr:FindFirstChildOfClass("Humanoid")
    if not chr or not hum or hum.Health <= 0 then
        LL.Notify("Персонаж не загружен")
        return
    end
    LL.Cache.Character = chr
    LL.Cache.Humanoid = hum
    LL.Cache.HRP = chr:FindFirstChild("HumanoidRootPart")
    LL.S.Macro.Recording = true
    LL.MacroRecord = {}
    if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
    if LL.MacroJumpConn then pcall(function() LL.MacroJumpConn:Disconnect() end) end
    LL.MacroJumpConn = LL.trackConn(UIS.JumpRequest:Connect(function()
        if LL.S.Macro.Recording and LL.S.Macro.JumpDetection then
            local hrp = LL.Cache.HRP
            if hrp then
                table.insert(LL.MacroRecord, { pos = hrp.Position, jump = true })
                if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
            end
        end
    end))
    LL.MacroRecordLoopThread = LL.trackThread(task.spawn(function()
        while getgenv().TIMON_LOADED and LL.S.Macro.Recording do
            local chr2 = LL.Cache.Character
            local hum2 = LL.Cache.Humanoid
            if not chr2 or not hum2 or hum2.Health <= 0 then
                LL.MacroStopRecording()
                break
            end
            local pos = chr2.HumanoidRootPart and chr2.HumanoidRootPart.Position
            if pos then
                table.insert(LL.MacroRecord, { pos = pos, jump = false })
                if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
            end
            task.wait(LL.S.Macro.SampleRate)
        end
    end))
    LL.Notify("Запись пошла")
end
function LL.MacroStopRecording()
    if not LL.S.Macro.Recording then return end
    LL.S.Macro.Recording = false
    if LL.MacroRecordLoopThread then
        pcall(function() task.cancel(LL.MacroRecordLoopThread) end)
        LL.MacroRecordLoopThread = nil
    end
    if LL.MacroJumpConn then
        pcall(function() LL.MacroJumpConn:Disconnect() end)
        LL.MacroJumpConn = nil
    end
    local count = LL.MacroRecord and #LL.MacroRecord or 0
    LL.Notify("Запись остановлена: "..tostring(count).." точек")
    if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
end
function LL.MacroStartPlaying(name)
    name = name or LL.S.Macro.CurrentMacro
    local points = LL.Macros[name]
    if not points or #points < 2 then
        LL.Notify("Макрос пуст: "..tostring(name))
        return
    end
    if LL.refreshCharCache then LL.refreshCharCache() end
    if not LP.Character or not LP.Character:FindFirstChildOfClass("Humanoid") then
        LL.Notify("Персонаж не загружен")
        return
    end
    if LL.S.Macro.Playing then LL.MacroStopPlaying() end
    LL.S.Macro.Playing = true
    if LL.S.Macro.IgnoreObstacles and LL.Cache.Character then
        for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    LL.MacroPlayThread = LL.trackThread(task.spawn(function()
        local startPos = points[1].pos
        while getgenv().TIMON_LOADED and LL.S.Macro.Playing do
            for i, pt in ipairs(points) do
                if not LL.S.Macro.Playing or not getgenv().TIMON_LOADED then break end
                local chr = LL.Cache.Character
                local hum = LL.Cache.Humanoid
                if not chr or not hum or hum.Health <= 0 then
                    LL.S.Macro.Playing = false
                    break
                end
                local hrp = chr:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                if LL.S.Macro.PushThrough then
                    hum:MoveTo(pt.pos)
                    if pt.jump then
                        pcall(function() hum.Jump = true end)
                    end
                    task.wait(LL.S.Macro.SampleRate)
                else
                    if (hrp.Position - pt.pos).Magnitude > 2 then
                        hum:MoveTo(pt.pos)
                        if pt.jump then
                            task.wait(0.1)
                            pcall(function() hum.Jump = true end)
                        end
                        local t0 = tick()
                        local lastPos = hrp.Position
                        local stuckCount = 0
                        while (hrp.Position - pt.pos).Magnitude > 2 and (tick() - t0) < 3 and LL.S.Macro.Playing and getgenv().TIMON_LOADED do
                            task.wait(0.1)
                            if (hrp.Position - lastPos).Magnitude < 0.1 then
                                stuckCount = stuckCount + 1
                                if stuckCount > 5 then break end
                            else
                                stuckCount = 0
                                lastPos = hrp.Position
                            end
                        end
                    end
                end
            end
            if not LL.S.Macro.Loop then
                LL.S.Macro.Playing = false
                break
            end
            local chr = LL.Cache.Character
            local hum = LL.Cache.Humanoid
            if chr and hum and hum.Health > 0 then
                hum:MoveTo(startPos)
                local t0 = tick()
                while (chr.HumanoidRootPart.Position - startPos).Magnitude > 2 and (tick() - t0) < 5 and LL.S.Macro.Playing and getgenv().TIMON_LOADED do
                    task.wait(0.1)
                end
            end
        end
        if LL.S.Macro.IgnoreObstacles and LL.Cache.Character then
            for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
        LL.S.Macro.Playing = false
    end))
    LL.Notify("Макрос запущен: "..name)
end
function LL.MacroStopPlaying()
    if not LL.S.Macro.Playing then return end
    LL.S.Macro.Playing = false
    if LL.MacroPlayThread then
        pcall(function() task.cancel(LL.MacroPlayThread) end)
        LL.MacroPlayThread = nil
    end
    if LL.S.Macro.IgnoreObstacles and LL.Cache.Character then
        for _, p in ipairs(LL.Cache.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    local hum = LL.Cache.Humanoid
    if hum and LL.Cache.HRP then pcall(function() hum:MoveTo(LL.Cache.HRP.Position) end) end
    LL.Notify("Макрос остановлен")
end
function LL.MacroReturnToStart()
    local name = LL.S.Macro.CurrentMacro
    local points = LL.Macros[name]
    if not points or #points < 1 then return end
    local hum = LL.Cache.Humanoid
    if hum then hum:MoveTo(points[1].pos) end
end
function LL.saveBtnPos(id, pos)
    LL.S.FloatingPos[id] = { xS = pos.X.Scale, xO = pos.X.Offset, yS = pos.Y.Scale, yO = pos.Y.Offset }
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    LL.trackConn(UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if LL.S.FloatingLock then dragging = false; return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    LL.trackConn(UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if id then LL.saveBtnPos(id, frame.Position); LL.MarkDirty() end
        end
    end))
    if id then LL.AllFloating[id] = {btn = frame, defaultPos = defaultPos or frame.Position} end
end
function LL.RepositionAllFloatingBtns()
    for id, entry in pairs(LL.AllFloating) do
        if entry.btn and entry.btn.Parent then entry.btn.Position = LL.loadBtnPos(id, entry.defaultPos) end
    end
end
function LL.ApplyFloatingLock()
    for _, entry in pairs(LL.AllFloating) do
        local b = entry.btn
        if b and b.Parent then
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then s.Color = LL.S.FloatingLock and COL.green or COL.accent2; s.Thickness = 2 end
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
    b.BackgroundColor3 = COL.bg2; b.BackgroundTransparency = 0.1; b.TextColor3 = COL.accent2
    b.Font = Enum.Font.GothamBold; b.TextSize = 11
    local LABEL = { Aimbot="AIM", Noclip="NOCLIP", AntiFling="AFLNG", InfiniteJump="IJMP", ESP="ESP", Hitbox="HITBX", Macro="MACRO", MacroRecord="REC", ZeroGravity="ZERO G" }
    b.Text = LABEL[action] or action
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 5; b.Parent = ScreenGui
    LL.corner(b, 29)
    local s = LL.stroke(b, COL.accent2, 2)
    if LL.S.FloatingLock then s.Color = COL.green end
    LL.MakeDraggableLockable(b, b, action, defaultPos)
    local function activeState()
        if action == "Aimbot" then return LL.S.Aimbot.Enabled
        elseif action == "ESP" then return LL.S.ESP.Enabled
        elseif action == "Hitbox" then return LL.S.Hitbox.Enabled or LL.S.Hitbox.NPCSupport
        elseif action == "Noclip" then return LL.S.Player.Noclip
        elseif action == "InfiniteJump" then return LL.S.Player.InfiniteJump
        elseif action == "AntiFling" then return LL.S.Troll.AntiFling
        elseif action == "ZeroGravity" then return LL.S.Player.ZeroGravity
        elseif action == "Macro" then return LL.S.Macro.Playing
        elseif action == "MacroRecord" then return LL.S.Macro.Recording
        end
        return false
    end
    local function paint()
        if activeState() then b.BackgroundColor3 = COL.accent2; b.TextColor3 = Color3.new(1,1,1)
        else b.BackgroundColor3 = COL.bg2; b.TextColor3 = COL.accent2 end
    end
    paint(); LL.AddRefresh(paint)
    b.MouseButton1Click:Connect(function()
        if LL.Actions[action] then
            local ok, err = pcall(LL.Actions[action])
            if not ok then warn("[LARP Btn] "..action..": "..tostring(err)) end
        end
        paint()
    end)
    LL.MobileButtons[action] = b
end
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 54, 0, 54)
local openDefault = UDim2.new(0, 20, 1, -84)
OpenBtn.Position = LL.loadBtnPos("__OpenBtn", openDefault)
OpenBtn.BackgroundColor3 = COL.bg2; OpenBtn.BackgroundTransparency = 0.05
OpenBtn.TextColor3 = COL.accent2; OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16; OpenBtn.Text = "L"; OpenBtn.BorderSizePixel = 0; OpenBtn.AutoButtonColor = false; OpenBtn.ZIndex = 5
OpenBtn.Parent = ScreenGui
LL.corner(OpenBtn, 27); LL.stroke(OpenBtn, COL.accent2, 2)
LL.MakeDraggableLockable(OpenBtn, OpenBtn, "__OpenBtn", openDefault)
OpenBtn.MouseEnter:Connect(function() Tween:Create(OpenBtn, LL.Anim.Fast, {BackgroundColor3 = COL.elem}):Play() end)
OpenBtn.MouseLeave:Connect(function() Tween:Create(OpenBtn, LL.Anim.Fast, {BackgroundColor3 = COL.bg2}):Play() end)
OpenBtn.MouseButton1Click:Connect(function() if LL.Main then LL.Main.Visible = not LL.Main.Visible end end)
LL.Actions.Aimbot = function()
    LL.S.Aimbot.Enabled = not LL.S.Aimbot.Enabled; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("Aimbot: "..tostring(LL.S.Aimbot.Enabled))
end
LL.Actions.ESP = function()
    LL.S.ESP.Enabled = not LL.S.ESP.Enabled; LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("ESP: "..tostring(LL.S.ESP.Enabled))
end
LL.Actions.Hitbox = function()
    local newEnabled = not (LL.S.Hitbox.Enabled or LL.S.Hitbox.NPCSupport)
    LL.S.Hitbox.Enabled = newEnabled
    LL.S.Hitbox.NPCSupport = newEnabled
    if not newEnabled then
        LL.ClearAllHitboxes()
        LL.ClearAllNPCHitboxes()
    end
    LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("Hitbox: "..tostring(newEnabled))
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
LL.Actions.Fly = function()
    LL.S.Player.Fly = not LL.S.Player.Fly
    LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("Fly: "..tostring(LL.S.Player.Fly))
end
LL.Actions.ZeroGravity = function()
    LL.S.Player.ZeroGravity = not LL.S.Player.ZeroGravity
    if LL.applyGravityState then pcall(LL.applyGravityState) end
    LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("ZeroGravity: "..tostring(LL.S.Player.ZeroGravity))
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
LL.Actions.Macro = function()
    if LL.S.Macro.Playing then LL.MacroStopPlaying()
    else LL.MacroStartPlaying(LL.S.Macro.CurrentMacro) end
end
LL.Actions.MacroRecord = function()
    if LL.S.Macro.Recording then LL.MacroStopRecording()
    else LL.MacroStartRecording() end
end
LL.Actions.AutoClicker = function()
    LL.S.AutoClicker.Enabled = not LL.S.AutoClicker.Enabled
    LL.RefreshAll(); LL.MarkDirty()
    LL.Notify("AutoClicker: "..tostring(LL.S.AutoClicker.Enabled))
end
function LL.applyLoadedSettings()
    LL.RefreshAll()
    for _, fn in pairs(LL.BindRefreshers) do pcall(fn) end
    if LL.MacroStopPlaying then pcall(LL.MacroStopPlaying) end
    if LL.MacroStopRecording then pcall(LL.MacroStopRecording) end
    if LL.S.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and not LL.ESPObjs[p] then pcall(LL.CreateESP, p) end
        end
    else
        for p in pairs(LL.ESPObjs) do pcall(LL.RemoveESP, p) end
    end
    if LL.S.ESP.NPCEnabled then
        pcall(LL.refreshNPCCache)
        for m in pairs(LL.NPCCache) do
            if not LL.isPlayerCharacter(m) and not LL.NPCESPObjs[m] then pcall(LL.CreateNPCESP, m) end
        end
    else
        for m in pairs(LL.NPCESPObjs) do pcall(LL.RemoveNPCESP, m) end
    end
    if LL.S.Hitbox.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
    else
        LL.ClearAllHitboxes()
    end
    if LL.S.Hitbox.NPCSupport then
        pcall(LL.refreshNPCCache)
        for model in pairs(LL.NPCCache) do pcall(LL.ApplyNPCHitbox, model) end
    else
        LL.ClearAllNPCHitboxes()
    end
    for action, state in pairs(LL.S.MobileBtns) do LL.ToggleMobileBtn(action, state) end
    LL.RepositionAllFloatingBtns()
    LL.ApplyFloatingLock()
    LL.applyGravityState()
    if LL.S.Player.AntiAFK then LL.startAntiAFK() else LL.stopAntiAFK() end
    if LL.S.Player.FPSBooster then LL.enableFPSBooster() else LL.disableFPSBooster() end
    if LL.S.Player.LowQuality then LL.enableLowQuality() else LL.disableLowQuality() end
    if LL.S.Player.Fullbright then LL.enableFullbright() else LL.disableFullbright() end
    if LL.MacroRecBtnUpdate then LL.MacroRecBtnUpdate() end
    LL.CONFIG_DIRTY = false
end
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
    if LL.S.Binds.AimbotHold and input.KeyCode == LL.S.Binds.AimbotHold then LL.aimHoldDown = true; return end
    if input.KeyCode == LL.S.UI.GuiKeybind and not gp then if LL.Main then LL.Main.Visible = not LL.Main.Visible end; return end
    if gp then return end
    for action, key in pairs(LL.S.Binds) do
        if action ~= "AimbotHold" and input.KeyCode == key and LL.Actions[action] then
            pcall(LL.Actions[action])
        end
    end
end))
LL.trackConn(UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if LL.S.Binds.AimbotHold and input.KeyCode == LL.S.Binds.AimbotHold then LL.aimHoldDown = false end
end))
LL.trackConn(UIS.JumpRequest:Connect(function()
    if LL.S.Player.InfiniteJump then
        local hum = LL.Cache.Humanoid
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
LL.trackThread(task.spawn(function()
    while getgenv().TIMON_LOADED do
        task.wait(2)
        if LL.CONFIG_DIRTY and LL.S.AutoSave and LL.FS_AVAILABLE and (tick() - LL.lastDirtyTime) >= 2 then
            LL.CONFIG_DIRTY = false
            local ok, err = LL.saveConfig(LL.AUTOSAVE_FILE)
            if not ok then warn("[LARP Autosave] "..tostring(err)) end
        end
    end
end))
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
    if LL.S.Aimbot.SilentAim then
        local st = LL.SilentFindTarget()
        if st then
            local aimPos = LL.GetLeadPos(st, Camera.CFrame.Position)
            if LL.S.Aimbot.SilentMode == "Camera" then
                local lookCF = CFrame.new(Camera.CFrame.Position, aimPos)
                Camera.CFrame = Camera.CFrame:Lerp(lookCF, LL.S.Aimbot.SilentSmooth)
            else
                local oldCF = Camera.CFrame
                Camera.CFrame = CFrame.new(oldCF.Position, aimPos)
                RunService.RenderStepped:Wait()
                Camera.CFrame = oldCF
            end
        end
    end
    if LL.S.AutoClicker and LL.S.AutoClicker.Enabled then
        local now = tick()
        local interval = 1 / math.max(LL.S.AutoClicker.Speed or 10, 1)
        if now - (LL._acLast or 0) >= interval then
            LL._acLast = now
            local btn = (LL.S.AutoClicker.Button == "Right") and 2 or 1
            if LL.S.AutoClicker.Mode == "Real" then
                pcall(function()
                    VirtualUser:CaptureController()
                    local pos = UIS:GetMouseLocation()
                    if btn == 1 then VirtualUser:ClickButton1(pos) else VirtualUser:ClickButton2(pos) end
                end)
            else
                pcall(function()
                    VirtualUser:CaptureController()
                    local pos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    if btn == 1 then VirtualUser:ClickButton1(pos) else VirtualUser:ClickButton2(pos) end
                end)
            end
        end
    end
    if LL.S.ESP.Enabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and not LL.ESPObjs[pl] then
                local ok, err = pcall(LL.CreateESP, pl)
                if not ok then warn("[LARP ESP] "..tostring(err)) end
            end
        end
        for pl in pairs(LL.ESPObjs) do
            if pl.Parent ~= Players then pcall(LL.RemoveESP, pl) end
        end
    else
        for pl in pairs(LL.ESPObjs) do pcall(LL.RemoveESP, pl) end
    end
    if LL.S.ESP.NPCEnabled then
        for model in pairs(LL.NPCCache) do
            if not LL.isPlayerCharacter(model) and not LL.NPCESPObjs[model] then
                pcall(LL.CreateNPCESP, model)
            end
        end
        for model in pairs(LL.NPCESPObjs) do
            if not model.Parent or not LL.NPCCache[model] then pcall(LL.RemoveNPCESP, model) end
        end
    else
        for model in pairs(LL.NPCESPObjs) do pcall(LL.RemoveNPCESP, model) end
    end
    if LL.S.Hitbox.RealTimeRefresh then
        if LL.S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then pcall(LL.ApplyHitbox, pl) end
            end
            for pl in pairs(LL.HitboxParts) do
                if pl.Parent ~= Players or not pl.Character then pcall(LL.RemoveHitboxFor, pl) end
            end
        end
        if LL.S.Hitbox.NPCSupport then
            for model in pairs(LL.NPCCache) do
                if model.Parent and not LL.isPlayerCharacter(model) then pcall(LL.ApplyNPCHitbox, model) end
            end
            for model in pairs(LL.NPCHitboxes) do
                if not model.Parent or not LL.NPCCache[model] then pcall(LL.RemoveNPCHitbox, model) end
            end
        end
    end
    if LL.S.Player.Fly and hrp then
        if not LL.FlyBV then
            local att = hrp:FindFirstChild("LARPFlyAtt") or Instance.new("Attachment")
            att.Name = "LARPFlyAtt"; att.Parent = hrp
            local lv = Instance.new("LinearVelocity")
            lv.MaxForce = math.huge; lv.Attachment0 = att; lv.Parent = hrp
            LL.FlyBV = lv
        end
        if not LL.FlyBG then
            local att = hrp:FindFirstChild("LARPFlyAtt") or Instance.new("Attachment")
            att.Name = "LARPFlyAtt"; att.Parent = hrp
            local al = Instance.new("AlignOrientation")
            al.Mode = Enum.OrientationAlignmentMode.OneAttachment
            al.MaxTorque = math.huge; al.Responsiveness = 200
            al.Attachment0 = att; al.Parent = hrp
            LL.FlyBG = al
        end
        local dir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        pcall(function() LL.FlyBV.VectorVelocity = dir * LL.S.Player.FlySpeed end)
        pcall(function() LL.FlyBG.CFrame = Camera.CFrame end)
    else
        if LL.FlyBV then pcall(function() LL.FlyBV:Destroy() end); LL.FlyBV = nil end
        if LL.FlyBG then pcall(function() LL.FlyBG:Destroy() end); LL.FlyBG = nil end
        if hrp then
            local att = hrp:FindFirstChild("LARPFlyAtt")
            if att then att:Destroy() end
        end
    end
    if hum then
        if LL.S.Player.WalkSpeedEnabled then hum.WalkSpeed = LL.S.Player.WalkSpeed end
        if LL.S.Player.JumpPowerEnabled then hum.JumpPower = LL.S.Player.JumpPower end
        if LL.S.Player.Noclip and ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
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
            else
                local dist = (camPos - d.cacheHead.Position).Magnitude
                if dist > LL.S.ESP.MaxDistance then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    if d.tracer then d.tracer.Visible = false end
                    if d.hl then d.hl.Enabled = false end
                else
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
                    else
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
                            drawTracerLine(d.tracer, vp.X/2, vp.Y, top.X, top.Y, LL.S.ESP.TracerFrom, LL.S.ESP.TracerTo)
                        elseif d.tracer then d.tracer.Visible = false end
                    end
                end
            end
        end
        if LL.S.ESP.NPCEnabled then
            for model, d in pairs(LL.NPCESPObjs) do
                if not model.Parent then
                    if d.name then d.name.Visible = false end
                    if d.dist then d.dist.Visible = false end
                    if d.hpBg then d.hpBg.Visible = false end
                    if d.hpFill then d.hpFill.Visible = false end
                    if d.hl then d.hl.Enabled = false end
                else
                    local head = model:FindFirstChild("Head")
                    local hum2 = model:FindFirstChildOfClass("Humanoid")
                    if not head or not hum2 then
                        if d.name then d.name.Visible = false end
                        if d.dist then d.dist.Visible = false end
                        if d.hpBg then d.hpBg.Visible = false end
                        if d.hpFill then d.hpFill.Visible = false end
                        if d.hl then d.hl.Enabled = false end
                    else
                        local dist = (camPos - head.Position).Magnitude
                        if dist > LL.S.ESP.MaxDistance then
                            if d.name then d.name.Visible = false end
                            if d.dist then d.dist.Visible = false end
                            if d.hpBg then d.hpBg.Visible = false end
                            if d.hpFill then d.hpFill.Visible = false end
                            if d.hl then d.hl.Enabled = false end
                        else
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
                            else
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
                end
            end
        end
    end
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
        local skip = LL.S.Player.Fly
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
local autoloaded = false
if LL.FS_AVAILABLE and LL.fileExists(LL.CONFIG_DIR.."/"..LL.AUTOSAVE_FILE..".json") then
    local ok = pcall(function() LL.loadConfigFile(LL.AUTOSAVE_FILE) end)
    if ok then autoloaded = true end
end
pcall(function() LL.RefreshAll() end)
if autoloaded then
    pcall(function() LL.applyLoadedSettings() end)
else
    pcall(function()
        if LL.S.ESP.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.CreateESP, pl) end
        end
        if LL.S.Hitbox.Enabled then
            for _, pl in ipairs(Players:GetPlayers()) do pcall(LL.ApplyHitbox, pl) end
        end
    end)
end
LL.applyGravityState()
LL.ApplyFloatingLock()
LL.RepositionAllFloatingBtns()
if LL.S.Player.AntiAFK then LL.startAntiAFK() end
if LL.S.Player.FPSBooster then LL.enableFPSBooster() end
if LL.S.Player.LowQuality then LL.enableLowQuality() end
if LL.S.Player.Fullbright then LL.enableFullbright() end
if LL.KeyValidated then
    LL.Notify("LARP(T) · 333 SINISTER · автозагрузка")
    LL.ShowMainUI()
else
    LL.ShowKeyScreen()
end
getgenv().TIMON_UNLOAD = function()
    local function step(name, fn)
        local ok, err = pcall(fn)
        if not ok then warn("[LARP Unload] "..name..": "..tostring(err)) end
    end
    getgenv().TIMON_LOADED = false
    step("macro", function()
        if LL.MacroStopPlaying then LL.MacroStopPlaying() end
        if LL.MacroStopRecording then LL.MacroStopRecording() end
    end)
    step("xneo", function()
        if LL.xneoScriptRunning then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                local m = pg:FindFirstChild("main")
                if m then m:Destroy() end
            end
            LL.xneoScriptRunning = false
        end
    end)
    step("antiAFK", function() LL.stopAntiAFK() end)
    step("lighting", function()
        LL.disableFPSBooster()
        LL.disableLowQuality()
        LL.disableFullbright()
    end)
    step("player", function()
        local hum = LL.Cache.Humanoid
        if hum then
            hum.WalkSpeed = LL.S.Player.OrigWalkSpeed or 16
            hum.JumpPower = LL.S.Player.OrigJumpPower or 50
        end
        Workspace.Gravity = DEFAULT_GRAVITY
    end)
    step("esp", function()
        for p in pairs(LL.ESPObjs) do LL.RemoveESP(p) end
        for m in pairs(LL.NPCESPObjs) do LL.RemoveNPCESP(m) end
    end)
    step("espConns", function()
        for _, conn in pairs(LL.espCharConn) do pcall(function() conn:Disconnect() end) end
        LL.espCharConn = {}
    end)
    step("hitbox", function()
        LL.ClearAllHitboxes()
        LL.ClearAllNPCHitboxes()
    end)
    step("drawing", function()
        if LL.fovCircle then pcall(function() LL.fovCircle:Remove() end) end
        if LL.aimBeam then pcall(function() LL.aimBeam:Remove() end) end
        if LL.hitboxBox then pcall(function() LL.hitboxBox:Remove() end) end
        if LL.silentFovCircle then pcall(function() LL.silentFovCircle:Remove() end) end
    end)
    step("aimRender", function() RunService:UnbindFromRenderStep("LARP_AIM") end)
    step("fly", function()
        if LL.FlyBV then LL.FlyBV:Destroy() end
        if LL.FlyBG then LL.FlyBG:Destroy() end
        if LL.SpinAV then LL.SpinAV:Destroy() end
    end)
    step("gui", function()
        if LL.ScreenGui then LL.ScreenGui:Destroy() end
    end)
    step("threads", function()
        for _, t in ipairs(THREADS) do pcall(function() task.cancel(t) end) end
        for i = #THREADS, 1, -1 do THREADS[i] = nil end
    end)
    step("conns", function()
        for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
        for i = #CONNS, 1, -1 do CONNS[i] = nil end
    end)
    LL.StickyTarget = nil
    LL.StickyTargetIsNPC = false
    LL.aimHoldDown = false
    LL.wasHoldActive = false
    LL.antiAFKThread = nil
    LL.MacroRecBtnUpdate = nil
    LL.MacroRecBtn = nil
end