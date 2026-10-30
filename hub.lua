-- TWKS // Timon Hub - Ultimate Advanced Suite (Rayfield Edition)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Timon Hub ✦ Ultimate Suite",
   LoadingTitle = "Loading Timon Hub...",
   LoadingSubtitle = "by TWKS",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TimonHub_Configs",
      FileName = "TimonHub_Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Вкладки
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ESPTab = Window:CreateTab("ESP & Visuals", 4483345998)
local HitboxTab = Window:CreateTab("Hitbox", 4483345998)
local PlayerTab = Window:CreateTab("Player", 4483345998)
local HamsterTab = Window:CreateTab("HamsterCombat", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483345998)

-- Сервисы и переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AssistActive = false
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

-- FOV Круг
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

-- === COMBAT TAB ===
CombatTab:CreateSection("Основной модуль (PC)")

CombatTab:CreateToggle({
   Name = "Assist System (PC)",
   CurrentValue = false,
   Flag = "AssistPC",
   Callback = function(Value)
      AssistActive = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Smoothness",
   Range = {0, 0.99},
   Increment = 0.05,
   CurrentValue = 0.5,
   Flag = "SmoothPC",
   Callback = function(Value)
      AssistSmooth = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "UpperTorso", "LeftLowerArm", "LeftLowerLeg"},
   CurrentOption = "Head",
   Flag = "TargetPart",
   Callback = function(Option)
      TargetPartName = Option
   end,
})

CombatTab:CreateSection("Мобильный модуль (Mobile)")

CombatTab:CreateToggle({
   Name = "Mobile Assist",
   CurrentValue = false,
   Flag = "AssistMob",
   Callback = function(Value)
      TouchAssistActive = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Mobile Smooth",
   Range = {0, 0.99},
   Increment = 0.05,
   CurrentValue = 0.5,
   Flag = "SmoothMob",
   Callback = function(Value)
      TouchAssistSmooth = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Mobile FOV",
   Range = {10, 500},
   Increment = 5,
   CurrentValue = 150,
   Flag = "FOVMob",
   Callback = function(Value)
      TouchAssistFOV = Value
   end,
})

CombatTab:CreateSection("FOV Circle")

CombatTab:CreateToggle({
   Name = "FOV Circle Visible",
   CurrentValue = true,
   Flag = "FOVVis",
   Callback = function(Value)
      FOVEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "FOV Radius",
   Range = {10, 500},
   Increment = 5,
   CurrentValue = 120,
   Flag = "FOVRad",
   Callback = function(Value)
      FOVRadius = Value
   end,
})

-- === ESP TAB ===
ESPTab:CreateSection("Подсветка игроков")

ESPTab:CreateToggle({
   Name = "Visuals (ESP)",
   CurrentValue = false,
   Flag = "ESPVis",
   Callback = function(Value)
      VisualsEnabled = Value
      if not Value then
          for _, hl in pairs(VisualsMap) do
              if hl then hl:Destroy() end
          end
          VisualsMap = {}
      end
   end,
})

ESPTab:CreateSlider({
   Name = "Fill Transparency",
   Range = {0, 1},
   Increment = 0.05,
   CurrentValue = 0.7,
   Flag = "ESPTrans",
   Callback = function(Value)
      VisualsTransparency = Value
   end,
})

-- === HITBOX TAB ===
HitboxTab:CreateSection("Увеличение хитбоксов")

HitboxTab:CreateToggle({
   Name = "Hitbox Extender",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      HitboxEnabled = Value
      if not Value then
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
   end,
})

HitboxTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 30},
   Increment = 1,
   CurrentValue = 4,
   Flag = "HitboxSize",
   Callback = function(Value)
      HitboxSize = Value
   end,
})

HitboxTab:CreateSlider({
   Name = "Hitbox Transparency",
   Range = {0, 1},
   Increment = 0.05,
   CurrentValue = 0.5,
   Flag = "HitboxTrans",
   Callback = function(Value)
      HitboxTransparency = Value
   end,
})

-- === PLAYER TAB ===
PlayerTab:CreateSection("Скорость и прыжок")

PlayerTab:CreateToggle({
   Name = "WalkSpeed Enable",
   CurrentValue = false,
   Flag = "SpeedTgl",
   Callback = function(Value)
      WalkSpeedEnabled = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "WalkSpeed Value",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "SpeedVal",
   Callback = function(Value)
      CustomWalkSpeed = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "JumpPower Enable",
   CurrentValue = false,
   Flag = "JumpTgl",
   Callback = function(Value)
      JumpPowerEnabled = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower Value",
   Range = {50, 300},
   Increment = 5,
   CurrentValue = 50,
   Flag = "JumpVal",
   Callback = function(Value)
      CustomJumpPower = Value
   end,
})

PlayerTab:CreateSection("Полет (Fly)")

PlayerTab:CreateToggle({
   Name = "Fly Enable",
   CurrentValue = false,
   Flag = "FlyTgl",
   Callback = function(Value)
      FlyEnabled = Value
      flying = Value
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
   end,
})

PlayerTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = 50,
   Flag = "FlySpd",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

-- === HAMSTER COMBAT TAB ===
HamsterTab:CreateSection("Кликер Hamster Coin")

local HamsterLabel = HamsterTab:CreateLabel("Hamster Coins: 0")

HamsterTab:CreateButton({
   Name = "🐹 TAP HERE (Hamster Clicker)",
   Callback = function()
      HamsterCoins = HamsterCoins + 1
      HamsterLabel:Set("Hamster Coins: " .. HamsterCoins)
   end,
})

-- === SETTINGS TAB ===
SettingsTab:CreateSection("Управление интерфейсом")

SettingsTab:CreateButton({
   Name = "Unload Hub (Full Delete)",
   Callback = function()
      pcall(function()
          if FOVCircle then FOVCircle:Remove() end
      end)
      for _, hl in pairs(VisualsMap) do
          if hl then hl:Destroy() end
      end
      Rayfield:Destroy()
   end,
})

-- Логика работы (RenderStepped)
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
                        hl.OutlineColor = Color3.fromRGB(180, 100, 255)
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