-- ИСПРАВЛЕННЫЙ UNIVERSAL FLY (работает во всех направлениях: W, A, S, D)
local function toggleFlyFunc()
    FlyEnabled = not FlyEnabled
    FlyToggle.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyToggle.TextColor3 = FlyEnabled and Color3.fromRGB(160, 255, 120) or Color3.fromRGB(230, 210, 250)
    FlyMobileBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if FlyEnabled then
        hum.PlatformStand = true
        
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end

        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        bv.Parent = hrp

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if flyConnection then flyConnection:Disconnect() end
                return
            end

            local currentHrp = LocalPlayer.Character.HumanoidRootPart
            local currentHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if currentHum then currentHum.PlatformStand = true end

            if bg and bv then
                bg.CFrame = Camera.CFrame
                
                -- Универсальный сбор векторов движения (камера + клавиатура)
                local moveDir = Vector3.new(0, 0, 0)
                local camCF = Camera.CFrame
                
                -- Проверяем оси через считывание матриц камеры (гарантированно работает везде)
                local forwardVector = camCF.LookVector
                local rightVector = camCF.RightVector

                -- Считываем состояние клавиатуры через стандартные буквенные кейкоды
                pcall(function()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forwardVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forwardVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVector end
                end)

                -- Поддержка мобильного джойстика
                if controlModule then
                    local rawMove = controlModule:GetMoveVector()
                    if rawMove.Magnitude > 0 then
                        moveDir = moveDir + (rightVector * rawMove.X + forwardVector * rawMove.Z)
                    end
                end

                if moveDir.Magnitude > 0 then
                    bv.Velocity = moveDir.Unit * FlySpeed
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0) -- зависание на месте без падения
                end
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end

        if hum then hum.PlatformStand = false end
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end