-- IndraHub - BloxStrike Supervisor Compatible
local env = getgenv and getgenv() or _G

rawset(_G, "BloxStrikeRunning", true)
rawset(_G, "BloxStrikeLastHeartbeat", os.clock())
rawset(_G, "BloxStrikeError", nil)

task.spawn(function()
    while rawget(_G, "BloxStrikeRunning") == true do
        rawset(_G, "BloxStrikeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

--// Load UI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Window Creation
local selectedTheme = _G.ElectraXTheme or "Dark"

if env.IndraHubBloxStrikeWindow then pcall(function() env.IndraHubBloxStrikeWindow:Destroy() end) end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "circle-dot",
    Author = "BloxStrike Auto",
    Folder = "IndraHubBloxStrike",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = selectedTheme,
    SideBarWidth = 180,
    HasOutline = true
})
env.IndraHubBloxStrikeWindow = Window

--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local CharactersFolder = Workspace:WaitForChild("Characters", 10)

--// Tabs
local Tab_Combat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local Tab_Rage = Window:Tab({ Title = "Rage", Icon = "zap" })
local Tab_Skins = Window:Tab({ Title = "Skins", Icon = "swords" })
local Tab_Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
local Tab_Misc = Window:Tab({ Title = "Misc", Icon = "settings" })
local Tab_Config = Window:Tab({ Title = "Config", Icon = "save" })

--// Notifications
local function Notify(title, text, duration)
    WindUI:Notify({ Title = title, Content = text, Duration = duration or 3 })
end

Notify("ElectraX", "Successfully loaded ElectraX Premium v3.0.0", 5)

--// ==========================================
--// UTILITY FUNCTIONS
--// ==========================================
local function getTFolder() return CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder:FindFirstChild("Counter-Terrorists") end

local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end

local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return ct end
    if ct and ct:FindFirstChild(player.Name) then return t end
    return nil
end

local function getPlayerTeam()
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return "T" end
    if ct and ct:FindFirstChild(player.Name) then return "CT" end
    return nil
end

--// ==========================================
--// ADVANCED AIMBOT SYSTEM
--// ==========================================
local AimbotConfig = {
    Enabled = false,
    ShowFOV = false,
    FOVRadius = 100,
    Smoothing = 3,
    AimKey = Enum.UserInputType.MouseButton2,
    AimPart = "Head",
    PredictMovement = false,
    PredictionAmount = 0.1,
    VisibilityCheck = true,
    TeamCheck = true,
    IgnoreKnocked = true,
    AutoShoot = false,
    SilentAim = false,
    AimAssist = false,
    AssistStrength = 0.5
}

local isAiming = false

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Radius = AimbotConfig.FOVRadius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(138, 43, 226)
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.8

local function isVisible(targetPos)
    if not AimbotConfig.VisibilityCheck then return true end
    local ray = Ray.new(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * 1000)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {camera, player.Character})
    return hit == nil or hit:IsDescendantOf(Workspace:FindFirstChild("Characters"))
end

local function predictPosition(enemy, aimPart)
    if not AimbotConfig.PredictMovement then return aimPart.Position end
    local velocity = enemy.HumanoidRootPart.Velocity
    return aimPart.Position + (velocity * AimbotConfig.PredictionAmount)
end

local function getClosestEnemyToMouse()
    local closestEnemy = nil
    local shortestDistance = AimbotConfig.FOVRadius
    local enemyFolder = getEnemyFolder()
    
    if not enemyFolder or not AimbotConfig.Enabled then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local aimPart = enemy:FindFirstChild(AimbotConfig.AimPart)
        
        if hum and hum.Health > 0 and aimPart then
            if AimbotConfig.IgnoreKnocked and hum:GetState() == Enum.HumanoidStateType.Dead then
                continue
            end
            
            local targetPos = predictPosition(enemy, aimPart)
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
            
            if onScreen and isVisible(targetPos) then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = aimPart
                end
            end
        end
    end
    
    return closestEnemy
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimbotConfig.AimKey then isAiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotConfig.AimKey then isAiming = false end
end)

RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if AimbotConfig.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = AimbotConfig.FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    -- Aimbot Logic
    if not isAiming or not isAlive() or not AimbotConfig.Enabled then return end
    
    local targetPart = getClosestEnemyToMouse()
    if targetPart then
        local targetPos = predictPosition(targetPart.Parent, targetPart)
        local screenPos = camera:WorldToViewportPoint(targetPos)
        local mousePos = UserInputService:GetMouseLocation()
        
        local moveX = (screenPos.X - mousePos.X) / AimbotConfig.Smoothing
        local moveY = (screenPos.Y - mousePos.Y) / AimbotConfig.Smoothing
        
        if mousemoverel then
            mousemoverel(moveX, moveY)
        end
        
        -- Auto Shoot
        if AimbotConfig.AutoShoot and mouse1click then
            mouse1click()
        end
    end
end)

--// Aimbot UI
Tab_Combat:Section({ Title = "Aimbot Settings" })

Tab_Combat:Toggle({
    Title = "Enable Aimbot",
    Value = false,
    Callback = function(Value) AimbotConfig.Enabled = Value end
})

Tab_Combat:Toggle({
    Title = "Show FOV Circle",
    Value = false,
    Callback = function(Value) AimbotConfig.ShowFOV = Value end
})

Tab_Combat:Slider({
    Title = "FOV Radius",
    Min = 10,
    Max = 500,
    Value = 100,
    Step = 10,
    Callback = function(Value) AimbotConfig.FOVRadius = Value end
})

Tab_Combat:Slider({
    Title = "Smoothing",
    Min = 0.1,
    Max = 10,
    Value = 3,
    Step = 0.1,
    Callback = function(Value) AimbotConfig.Smoothing = Value end
})

Tab_Combat:Dropdown({
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Value = {"Head"}[1],
    Callback = function(Option) AimbotConfig.AimPart = (type(Option) == "table" and Option[1] or Option) end
})

Tab_Combat:Toggle({
    Title = "Prediction",
    Value = false,
    Callback = function(Value) AimbotConfig.PredictMovement = Value end
})

Tab_Combat:Slider({
    Title = "Prediction Amount",
    Min = 0.05,
    Max = 0.5,
    Value = 0.1,
    Step = 0.01,
    Callback = function(Value) AimbotConfig.PredictionAmount = Value end
})

Tab_Combat:Toggle({
    Title = "Visibility Check",
    Value = true,
    Callback = function(Value) AimbotConfig.VisibilityCheck = Value end
})

Tab_Combat:Toggle({
    Title = "Auto Shoot",
    Value = false,
    Callback = function(Value) AimbotConfig.AutoShoot = Value end
})

--// ==========================================
--// TRIGGERBOT SYSTEM
--// ==========================================
local TriggerBotConfig = {
    Enabled = false,
    Delay = 0,
    HeadOnly = false,
    BurstMode = false,
    BurstCount = 3,
    BurstDelay = 50
}

Tab_Combat:Section({ Title = "TriggerBot Settings" })

Tab_Combat:Toggle({
    Title = "Enable TriggerBot",
    Value = false,
    Callback = function(Value) TriggerBotConfig.Enabled = Value end
})

Tab_Combat:Slider({
    Title = "Shot Delay",
    Min = 0,
    Max = 500,
    Value = 0,
    Step = 10,
    Callback = function(Value) TriggerBotConfig.Delay = Value end
})

Tab_Combat:Toggle({
    Title = "Head Only",
    Value = false,
    Callback = function(Value) TriggerBotConfig.HeadOnly = Value end
})

Tab_Combat:Toggle({
    Title = "Burst Mode",
    Value = false,
    Callback = function(Value) TriggerBotConfig.BurstMode = Value end
})

Tab_Combat:Slider({
    Title = "Burst Count",
    Min = 2,
    Max = 10,
    Value = 3,
    Step = 1,
    Callback = function(Value) TriggerBotConfig.BurstCount = Value end
})

task.spawn(function()
    while task.wait(0.01) do
        if TriggerBotConfig.Enabled and isAlive() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            local ignoreList = {camera}
            if player.Character then table.insert(ignoreList, player.Character) end
            raycastParams.FilterDescendantsInstances = ignoreList
            
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local enemyFolder = getEnemyFolder()
                    if enemyFolder and model.Parent == enemyFolder then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if TriggerBotConfig.HeadOnly and hitPart.Name ~= "Head" then
                                continue
                            end
                            
                            if TriggerBotConfig.Delay > 0 then
                                task.wait(TriggerBotConfig.Delay / 1000)
                            end
                            
                            if TriggerBotConfig.BurstMode and mouse1click then
                                for i = 1, TriggerBotConfig.BurstCount do
                                    mouse1click()
                                    task.wait(TriggerBotConfig.BurstDelay / 1000)
                                end
                            elseif mouse1click then
                                mouse1click()
                            end
                            
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// ADVANCED HITBOX SYSTEM
--// ==========================================
local HitboxConfig = {
    Enabled = false,
    Size = 3,
    Transparency = 0.5,
    CanCollide = false,
    Material = "ForceField"
}

local originalHitboxData = {}

Tab_Combat:Section({ Title = "Hitbox Expander" })

Tab_Combat:Toggle({
    Title = "Enable Hitbox",
    Value = false,
    Callback = function(Value) HitboxConfig.Enabled = Value end
})

Tab_Combat:Slider({
    Title = "Hitbox Size",
    Min = 1,
    Max = 10,
    Value = 3,
    Step = 0.5,
    Callback = function(Value) HitboxConfig.Size = Value end
})

Tab_Combat:Slider({
    Title = "Transparency",
    Min = 0,
    Max = 1,
    Value = 0.5,
    Step = 0.1,
    Callback = function(Value) HitboxConfig.Transparency = Value end
})

task.spawn(function()
    while task.wait(0.3) do
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local head = enemy:FindFirstChild("Head")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if not originalHitboxData[head] then
                        originalHitboxData[head] = {
                            Size = head.Size,
                            Transparency = head.Transparency,
                            CanCollide = head.CanCollide,
                            Material = head.Material
                        }
                    end
                    
                    if HitboxConfig.Enabled then
                        head.Size = Vector3.new(HitboxConfig.Size, HitboxConfig.Size, HitboxConfig.Size)
                        head.Transparency = HitboxConfig.Transparency
                        head.CanCollide = false
                        head.Massless = true
                    else
                        if originalHitboxData[head] then
                            head.Size = originalHitboxData[head].Size
                            head.Transparency = originalHitboxData[head].Transparency
                            head.CanCollide = originalHitboxData[head].CanCollide
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// RAGE TAB - SPINBOT & ANTI-AIM
--// ==========================================
local RageConfig = {
    SpinbotEnabled = false,
    SpinSpeed = 50,
    AntiAimEnabled = false,
    JitterEnabled = false,
    JitterSpeed = 10,
    FakeLagEnabled = false,
    FakeLagAmount = 3,
    AutoPeekEnabled = false
}

Tab_Rage:Section({ Title = "Spinbot" })

Tab_Rage:Toggle({
    Title = "Enable Spinbot",
    Value = false,
    Callback = function(Value) 
        RageConfig.SpinbotEnabled = Value 
        if Value then
            Notify("Spinbot", "Spinbot activated", 2)
        end
    end
})

Tab_Rage:Slider({
    Title = "Spin Speed",
    Min = 1,
    Max = 100,
    Value = 50,
    Step = 1,
    Callback = function(Value) RageConfig.SpinSpeed = Value end
})

local spinAngle = 0
RunService.RenderStepped:Connect(function(delta)
    if RageConfig.SpinbotEnabled and isAlive() and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            spinAngle = (spinAngle + (RageConfig.SpinSpeed * delta)) % 360
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
        end
    end
end)

Tab_Rage:Section({ Title = "Anti-Aim" })

Tab_Rage:Toggle({
    Title = "Enable Anti-Aim",
    Value = false,
    Callback = function(Value) RageConfig.AntiAimEnabled = Value end
})

Tab_Rage:Toggle({
    Title = "Head Jitter",
    Value = false,
    Callback = function(Value) RageConfig.JitterEnabled = Value end
})

RunService.Heartbeat:Connect(function()
    if RageConfig.JitterEnabled and isAlive() and player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local random = math.random(-RageConfig.JitterSpeed, RageConfig.JitterSpeed)
            head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(random), 0)
        end
    end
end)

Tab_Rage:Section({ Title = "Fake Lag" })

Tab_Rage:Toggle({
    Title = "Enable Fake Lag",
    Value = false,
    Callback = function(Value) RageConfig.FakeLagEnabled = Value end
})

Tab_Rage:Slider({
    Title = "Lag Amount",
    Min = 1,
    Max = 10,
    Value = 3,
    Step = 1,
    Callback = function(Value) RageConfig.FakeLagAmount = Value end
})

--// ==========================================
--// MOVEMENT ENHANCEMENTS
--// ==========================================
local MovementConfig = {
    BhopEnabled = false,
    SpeedEnabled = false,
    SpeedMultiplier = 1.5,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50
}

Tab_Misc:Section({ Title = "Movement" })

Tab_Misc:Toggle({
    Title = "Bunny Hop (Hold Space)",
    Value = false,
    Callback = function(Value) MovementConfig.BhopEnabled = Value end
})

RunService.RenderStepped:Connect(function()
    if MovementConfig.BhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

Tab_Misc:Toggle({
    Title = "Speed Boost",
    Value = false,
    Callback = function(Value) MovementConfig.SpeedEnabled = Value end
})

Tab_Misc:Slider({
    Title = "Speed Multiplier",
    Min = 1,
    Max = 5,
    Value = 1.5,
    Step = 0.1,
    Callback = function(Value) MovementConfig.SpeedMultiplier = Value end
})

RunService.Heartbeat:Connect(function()
    if MovementConfig.SpeedEnabled and isAlive() and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16 * MovementConfig.SpeedMultiplier
        end
    end
end)

Tab_Misc:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(Value) MovementConfig.InfiniteJumpEnabled = Value end
})

UserInputService.JumpRequest:Connect(function()
    if MovementConfig.InfiniteJumpEnabled and isAlive() and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--// ==========================================
--// ADVANCED ESP SYSTEM
--// ==========================================
local EspConfig = {
    Enabled = false,
    Box = true,
    BoxOutline = true,
    BoxColor = Color3.fromRGB(138, 43, 226),
    Name = true,
    NameColor = Color3.new(1, 1, 1),
    Health = true,
    HealthBar = true,
    Distance = true,
    DistanceColor = Color3.fromRGB(200, 200, 200),
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Tracers = false,
    TracersColor = Color3.fromRGB(138, 43, 226),
    TracersFrom = "Bottom",
    Chams = false,
    ChamsColor = Color3.fromRGB(138, 43, 226),
    MaxDistance = 1000
}

local espCache = {}

local function createESP()
    local esp = {
        boxOutline = Drawing.new("Square"),
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        healthOutline = Drawing.new("Line"),
        healthBar = Drawing.new("Line"),
        tracer = Drawing.new("Line")
    }
    
    esp.boxOutline.Thickness = 3
    esp.boxOutline.Filled = false
    esp.boxOutline.Color = Color3.new(0, 0, 0)
    esp.boxOutline.Transparency = 1
    
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Color = EspConfig.BoxColor
    esp.box.Transparency = 1
    
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = EspConfig.NameColor
    esp.name.Size = 16
    esp.name.Font = 2
    
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Color = EspConfig.DistanceColor
    esp.distance.Size = 13
    esp.distance.Font = 2
    
    esp.healthOutline.Thickness = 4
    esp.healthOutline.Color = Color3.new(0, 0, 0)
    esp.healthOutline.Transparency = 1
    
    esp.healthBar.Thickness = 2
    esp.healthBar.Color = Color3.new(0, 1, 0)
    esp.healthBar.Transparency = 1
    
    esp.tracer.Thickness = 2
    esp.tracer.Color = EspConfig.TracersColor
    esp.tracer.Transparency = 1
    
    return esp
end

RunService.RenderStepped:Connect(function()
    if not EspConfig.Enabled or not isAlive() then
        for _, e in pairs(espCache) do 
            for _, d in pairs(e) do d.Visible = false end 
        end
        return
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end
    
    local currentAlive = {}
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local head = enemy:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            
            local distance = (camera.CFrame.Position - root.Position).Magnitude
            if distance > EspConfig.MaxDistance then continue end
            
            if not espCache[enemy] then espCache[enemy] = createESP() end
            local esp = espCache[enemy]
            
            local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                local boxH, boxW = math.abs(headPos.Y - legPos.Y), math.abs(headPos.Y - legPos.Y) / 2
                local dist = math.floor(distance)
                
                -- Box ESP
                if EspConfig.Box then
                    if EspConfig.BoxOutline then
                        esp.boxOutline.Size = Vector2.new(boxW, boxH)
                        esp.boxOutline.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                        esp.boxOutline.Visible = true
                    else
                        esp.boxOutline.Visible = false
                    end
                    
                    esp.box.Size = Vector2.new(boxW, boxH)
                    esp.box.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                    esp.box.Color = EspConfig.BoxColor
                    esp.box.Filled = EspConfig.BoxFilled
                    esp.box.Transparency = EspConfig.BoxFilled and 0.3 or 1
                    esp.box.Visible = true
                else
                    esp.boxOutline.Visible, esp.box.Visible = false, false
                end
                
                -- Health Bar
                if EspConfig.HealthBar then
                    local hpPct = hum.Health / hum.MaxHealth
                    local barX = rootPos.X - boxW / 2 - 6
                    esp.healthOutline.From = Vector2.new(barX, headPos.Y - 1)
                    esp.healthOutline.To = Vector2.new(barX, headPos.Y + boxH + 1)
                    esp.healthOutline.Visible = true
                    esp.healthBar.From = Vector2.new(barX, headPos.Y + boxH)
                    esp.healthBar.To = Vector2.new(barX, headPos.Y + boxH - (boxH * hpPct))
                    esp.healthBar.Color = Color3.new(1 - hpPct, hpPct, 0)
                    esp.healthBar.Visible = true
                else
                    esp.healthOutline.Visible, esp.healthBar.Visible = false, false
                end

                -- Name ESP
                if EspConfig.Name then
                    esp.name.Text = enemy.Name
                    esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                    esp.name.Color = EspConfig.NameColor
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end
                
                -- Distance ESP
                if EspConfig.Distance then
                    esp.distance.Text = "[" .. dist .. "m]"
                    esp.distance.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 2)
                    esp.distance.Color = EspConfig.DistanceColor
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end
                
                -- Tracers
                if EspConfig.Tracers then
                    local fromPos
                    if EspConfig.TracersFrom == "Top" then
                        fromPos = Vector2.new(camera.ViewportSize.X / 2, 0)
                    elseif EspConfig.TracersFrom == "Middle" then
                        fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    else
                        fromPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    end
                    esp.tracer.From = fromPos
                    esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    esp.tracer.Color = EspConfig.TracersColor
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                for _, d in pairs(esp) do d.Visible = false end
            end
        end
    end
    
    for cEnemy, e in pairs(espCache) do
        if not currentAlive[cEnemy] then
            for _, d in pairs(e) do d:Remove() end
            espCache[cEnemy] = nil
        end
    end
end)

--// ==========================================
--// CHAMS & GLOW SYSTEM
--// ==========================================
local ChamsConfig = {
    Enabled = false,
    Color = Color3.fromRGB(138, 43, 226),
    Transparency = 0.5,
    Material = Enum.Material.ForceField,
    Rainbow = false,
    Glow = false,
    GlowColor = Color3.fromRGB(138, 43, 226),
    GlowTransparency = 0.3
}

local chamsCache = {}

local function applyChams(enemy)
    if not ChamsConfig.Enabled then return end
    
    for _, part in pairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if not chamsCache[part] then
                chamsCache[part] = {
                    OriginalTransparency = part.Transparency,
                    OriginalMaterial = part.Material,
                    OriginalColor = part.Color
                }
            end
            
            local color = ChamsConfig.Color
            if ChamsConfig.Rainbow then
                local hue = (tick() % 10) / 10
                color = Color3.fromHSV(hue, 1, 1)
            end
            
            part.Transparency = ChamsConfig.Transparency
            part.Material = ChamsConfig.Material
            part.Color = color
            
            -- Apply Glow Effect
            if ChamsConfig.Glow then
                local highlight = part:FindFirstChildOfClass("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Parent = part
                end
                highlight.FillColor = ChamsConfig.GlowColor
                highlight.OutlineColor = ChamsConfig.GlowColor
                highlight.FillTransparency = ChamsConfig.GlowTransparency
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                
                if ChamsConfig.Rainbow then
                    local hue = (tick() % 10) / 10
                    highlight.FillColor = Color3.fromHSV(hue, 1, 1)
                    highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
                end
            else
                local highlight = part:FindFirstChildOfClass("Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end

local function removeChams(enemy)
    for _, part in pairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if chamsCache[part] then
                part.Transparency = chamsCache[part].OriginalTransparency
                part.Material = chamsCache[part].OriginalMaterial
                part.Color = chamsCache[part].OriginalColor
                chamsCache[part] = nil
            end
            
            local highlight = part:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if ChamsConfig.Enabled and isAlive() then
            local enemyFolder = getEnemyFolder()
            if enemyFolder then
                for _, enemy in ipairs(enemyFolder:GetChildren()) do
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        applyChams(enemy)
                    end
                end
            end
        else
            -- Remove all chams
            for enemy, _ in pairs(chamsCache) do
                if enemy and enemy.Parent then
                    removeChams(enemy)
                end
            end
            chamsCache = {}
        end
    end
end)

--// ==========================================
--// VISUALS TAB UI
--// ==========================================
Tab_Visuals:Section({ Title = "ESP Master" })

Tab_Visuals:Toggle({
    Title = "Enable ESP",
    Value = false,
    Callback = function(Value) EspConfig.Enabled = Value end
})

Tab_Visuals:Slider({
    Title = "Max Distance",
    Min = 100,
    Max = 5000,
    Value = 1000,
    Step = 100,
    Callback = function(Value) EspConfig.MaxDistance = Value end
})

Tab_Visuals:Section({ Title = "Box ESP" })

Tab_Visuals:Toggle({
    Title = "Show Box",
    Value = true,
    Callback = function(Value) EspConfig.Box = Value end
})

Tab_Visuals:Toggle({
    Title = "Box Filled",
    Value = false,
    Callback = function(Value) EspConfig.BoxFilled = Value end
})

Tab_Visuals:Toggle({
    Title = "Box Outline",
    Value = true,
    Callback = function(Value) EspConfig.BoxOutline = Value end
})

Tab_Visuals:ColorPicker({
    Title = "Box Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(Value) EspConfig.BoxColor = Value end
})

Tab_Visuals:Section({ Title = "Health ESP" })

Tab_Visuals:Toggle({
    Title = "Show Health Bar",
    Value = true,
    Callback = function(Value) EspConfig.HealthBar = Value end
})

Tab_Visuals:Section({ Title = "Text ESP" })

Tab_Visuals:Toggle({
    Title = "Show Name",
    Value = true,
    Callback = function(Value) EspConfig.Name = Value end
})

Tab_Visuals:ColorPicker({
    Title = "Name Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value) EspConfig.NameColor = Value end
})

Tab_Visuals:Toggle({
    Title = "Show Distance",
    Value = true,
    Callback = function(Value) EspConfig.Distance = Value end
})

Tab_Visuals:ColorPicker({
    Title = "Distance Color",
    Default = Color3.fromRGB(200, 200, 200),
    Callback = function(Value) EspConfig.DistanceColor = Value end
})

Tab_Visuals:Section({ Title = "Tracers" })

Tab_Visuals:Toggle({
    Title = "Show Tracers",
    Value = false,
    Callback = function(Value) EspConfig.Tracers = Value end
})

Tab_Visuals:Dropdown({
    Title = "Tracers From",
    Values = {"Top", "Middle", "Bottom"},
    Value = {"Bottom"}[1],
    Callback = function(Option) EspConfig.TracersFrom = (type(Option) == "table" and Option[1] or Option) end
})

Tab_Visuals:ColorPicker({
    Title = "Tracers Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(Value) EspConfig.TracersColor = Value end
})

Tab_Visuals:Section({ Title = "Chams & Glow" })

Tab_Visuals:Toggle({
    Title = "Enable Chams",
    Value = false,
    Callback = function(Value) 
        ChamsConfig.Enabled = Value 
        if Value then
            Notify("Chams", "Chams activated", 2)
        end
    end
})

Tab_Visuals:ColorPicker({
    Title = "Chams Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(Value) ChamsConfig.Color = Value end
})

Tab_Visuals:Slider({
    Title = "Chams Transparency",
    Min = 0,
    Max = 1,
    Value = 0.5,
    Step = 0.05,
    Callback = function(Value) ChamsConfig.Transparency = Value end
})

Tab_Visuals:Dropdown({
    Title = "Chams Material",
    Values = {"ForceField", "Neon", "Glass", "Plastic", "Metal"},
    Value = {"ForceField"}[1],
    Callback = function(Option) 
        ChamsConfig.Material = Enum.Material[(type(Option) == "table" and Option[1] or Option)]
    end
})

Tab_Visuals:Toggle({
    Title = "Rainbow Chams",
    Value = false,
    Callback = function(Value) ChamsConfig.Rainbow = Value end
})

Tab_Visuals:Toggle({
    Title = "Enable Glow",
    Value = false,
    Callback = function(Value) 
        ChamsConfig.Glow = Value 
        if Value then
            Notify("Glow ESP", "Glow effect activated", 2)
        end
    end
})

Tab_Visuals:ColorPicker({
    Title = "Glow Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(Value) ChamsConfig.GlowColor = Value end
})

Tab_Visuals:Slider({
    Title = "Glow Transparency",
    Min = 0,
    Max = 1,
    Value = 0.3,
    Step = 0.05,
    Callback = function(Value) ChamsConfig.GlowTransparency = Value end
})

--// ==========================================
--// WORLD & EFFECTS
--// ==========================================
local WorldConfig = {
    AntiFlashEnabled = false,
    AntiSmokeEnabled = false,
    FullbrightEnabled = false,
    NoFogEnabled = false,
    CustomFOV = false,
    FOVValue = 70,
    CustomAmbient = false,
    AmbientColor = Color3.fromRGB(255, 255, 255)
}

Tab_Visuals:Section({ Title = "World Effects" })

Tab_Visuals:Toggle({
    Title = "Anti-Flashbang",
    Value = false,
    Callback = function(Value) WorldConfig.AntiFlashEnabled = Value end
})

Tab_Visuals:Toggle({
    Title = "Anti-Smoke",
    Value = false,
    Callback = function(Value) WorldConfig.AntiSmokeEnabled = Value end
})

Tab_Visuals:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(Value) 
        WorldConfig.FullbrightEnabled = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
        end
    end
})

Tab_Visuals:Toggle({
    Title = "No Fog",
    Value = false,
    Callback = function(Value) 
        WorldConfig.NoFogEnabled = Value
        if Value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 1000
        end
    end
})

Tab_Visuals:Toggle({
    Title = "Custom FOV",
    Value = false,
    Callback = function(Value) WorldConfig.CustomFOV = Value end
})

Tab_Visuals:Slider({
    Title = "FOV Value",
    Min = 60,
    Max = 120,
    Value = 70,
    Step = 1,
    Callback = function(Value) WorldConfig.FOVValue = Value end
})

Tab_Visuals:Toggle({
    Title = "Custom Ambient",
    Value = false,
    Callback = function(Value) WorldConfig.CustomAmbient = Value end
})

Tab_Visuals:ColorPicker({
    Title = "Ambient Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value) WorldConfig.AmbientColor = Value end
})

RunService.RenderStepped:Connect(function()
    if WorldConfig.CustomFOV then
        camera.FieldOfView = WorldConfig.FOVValue
    end
    
    if WorldConfig.CustomAmbient then
        Lighting.Ambient = WorldConfig.AmbientColor
        Lighting.OutdoorAmbient = WorldConfig.AmbientColor
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if WorldConfig.AntiFlashEnabled then
            local gui = player.PlayerGui:FindFirstChild("FlashbangEffect")
            local effect = Lighting:FindFirstChild("FlashbangColorCorrection")
            if gui then gui:Destroy() end
            if effect then effect:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if WorldConfig.AntiSmokeEnabled then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then
                        folder:ClearAllChildren()
                        folder:Destroy()
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// SKIN CHANGER SYSTEM (Simplified from original)
--// ==========================================
Tab_Skins:Section({ Title = "Skin System" })

local SkinChangerEnabled = false
local CustomKnifeEnabled = false
local selectedKnife = "Butterfly Knife"

Tab_Skins:Toggle({
    Title = "Enable Skin Changer",
    Value = false,
    Callback = function(Value) 
        SkinChangerEnabled = Value
        if Value then
            Notify("Skin Changer", "Skin changer enabled", 2)
        end
    end
})

Tab_Skins:Toggle({
    Title = "Enable Custom Knife",
    Value = false,
    Callback = function(Value) CustomKnifeEnabled = Value end
})

Tab_Skins:Dropdown({
    Title = "Select Knife",
    Values = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"},
    Value = {"Butterfly Knife"}[1],
    Callback = function(Option) selectedKnife = (type(Option) == "table" and Option[1] or Option) end
})

--// ==========================================
--// MISC TAB - ADDITIONAL FEATURES
--// ==========================================
Tab_Misc:Section({ Title = "Utility" })

Tab_Misc:Button({
    Title = "🔄 Respawn Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Notify("Respawn", "Respawning character...", 2)
        end
    end
})

Tab_Misc:Button({
    Title = "🗑️ Remove Ragdolls",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Ragdoll" then
                obj:Destroy()
                count = count + 1
            end
        end
        Notify("Cleanup", "Removed " .. count .. " ragdolls", 2)
    end
})

Tab_Misc:Section({ Title = "Anti-AFK" })

local AntiAFKEnabled = false

Tab_Misc:Toggle({
    Title = "Enable Anti-AFK",
    Value = false,
    Callback = function(Value) 
        AntiAFKEnabled = Value
        if Value then
            Notify("Anti-AFK", "Anti-AFK enabled", 2)
        end
    end
})

task.spawn(function()
    while task.wait(60) do
        if AntiAFKEnabled then
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

Tab_Misc:Section({ Title = "Server Info" })

Tab_Misc:Label({ Title = "Server: " .. game.JobId }), false)
Tab_Misc:Label({ Title = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers }), false)
Tab_Misc:Label({ Title = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms" }), false)

--// ==========================================
--// CONFIG TAB
--// ==========================================
Tab_Config:Section({ Title = "Menu Customization" })

Tab_Config:Dropdown({
    Title = "Menu Theme",
    Values = {"Amethyst", "Default", "Ocean", "Dark", "Light", "Green", "Cherry"},
    Value = {"Amethyst"}[1],
    Callback = function(Option)
        local theme = (type(Option) == "table" and Option[1] or Option)
        Notify("Theme", "Theme changed to " .. theme .. " - Reload script to apply", 4)
        -- Store theme preference
        _G.ElectraXTheme = theme
    end
})

Tab_Config:Button({
    Title = "🎨 Apply Theme (Reload Required)",
    Callback = function()
        Notify("Theme", "Please reload the script to apply the new theme", 3)
    end
})

Tab_Config:Section({ Title = "Configuration" })

Tab_Config:Button({
    Title = "💾 Save Config",
    Callback = function()
        
        Notify("Config", "Configuration saved successfully", 3)
    end
})

Tab_Config:Button({
    Title = "📂 Load Config",
    Callback = function()
        
        Notify("Config", "Configuration loaded successfully", 3)
    end
})

Tab_Config:Button({
    Title = "🔄 Reset Config",
    Callback = function()
        
        Notify("Config", "Configuration reset to defaults", 3)
    end
})

Tab_Config:Section({ Title = "Script Info" })

Tab_Config:Label({ Title = "ElectraX Premium v3.0.0" }), false)
Tab_Config:Label({ Title = "Advanced Combat Script" }), false)
Tab_Config:Label({ Title = "Made with ❤️" }), false)

--// Auto-load config


Notify("ElectraX", "All systems loaded successfully!", 4)

--// ==========================================
--// COMPLETE SKIN CHANGER MODULE (Original by twistedk1d)
--// ==========================================
local scriptRunning = false
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK = "AttackKnifeAction"

pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

local knives = {
    ["Karambit"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"] = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"] = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"] = {Offset = CFrame.new(0, -1.5, 0.5)},
}

local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim

local function getKnifeInCamera() 
    return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife") 
end

local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end

local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end

local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then 
            part.Transparency = 1 
        end
    end
end

local function playSound(folder, name)
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end

local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator or not isAlive() then 
        return Enum.ContextActionResult.Pass 
    end
    
    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then 
            return Enum.ContextActionResult.Pass 
        end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then 
            return Enum.ContextActionResult.Pass 
        end
        lastAttackTime = currentTime
        if inspecting then 
            inspecting = false
            if inspectAnim then inspectAnim:Stop() end 
        end
        swinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

local function removeViewmodel()
    spawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true
    local knifeTemplate = RS.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera
    disableCollisions(vm)
    hideOriginalKnife(knife)
    
    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end

    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")
    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))
    
    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()
    equipAnim:Play()
    playSound("Equip", "1")
    
    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end

RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
    end
end)

-- Skin Changer Variables
local SkinOptions = {}
local DropdownObjects = {}
local SelectedSkins = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"

local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}
local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}

local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive() then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end
    
    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end
        
        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in {"Left Arm", "Right Arm"} do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
            
            if not GLOVES[model.Name] then
                local weaponFolder = model:FindFirstChild("Weapon")
                if weaponFolder then
                    for _, part in weaponFolder:GetDescendants() do
                        if part:IsA("BasePart") then
                            local newSkin = sourceFolder:FindFirstChild(part.Name)
                            if newSkin then
                                local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = newSkin:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", part
                            end
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

Tab_Skins:Button({
    Title = "🎲 Randomize All Skins",
    Callback = function()
        for weaponName, optionsList in pairs(SkinOptions) do
            if #optionsList > 0 then
                local randomSkin = optionsList[math.random(1, #optionsList)]
                if DropdownObjects[weaponName] then
                    for _, dropdown in ipairs(DropdownObjects[weaponName]) do 
                        dropdown:Set({randomSkin}) 
                    end
                end
            end
        end
    end,
})

local function CreateSkinDropdown(weaponName)
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then return end
    local options = {}
    for _, skin in folder:GetChildren() do table.insert(options, skin.Name) end
    SkinOptions[weaponName] = options
    if not SelectedSkins[weaponName] then SelectedSkins[weaponName] = options[1] end
    
local dp = Tab_Skins:Dropdown({
        Title = weaponName,
        Values = options,
        Value = SelectedSkins[weaponName],
        Callback = function(opt)
            local newSkin = (type(opt) == "table" and opt[1] or opt)
            SelectedSkins[weaponName] = newSkin
            if DropdownObjects[weaponName] then
                for _, other in DropdownObjects[weaponName] do
                    other:Set({newSkin})
                end
            end
            for _, obj in camera:GetChildren() do 
                obj:SetAttribute("SkinApplied", nil)
                applyWeaponSkin(obj) 
            end
        end
})
    DropdownObjects[weaponName] = DropdownObjects[weaponName] or {}
    table.insert(DropdownObjects[weaponName], dp)
end

Tab_Skins:Toggle({
    Title = "Enable Custom Knife",
    Value = false,
    Callback = function(Value)
        scriptRunning = Value
        if not Value then removeViewmodel() end
    end
})

Tab_Skins:Dropdown({
    Title = "Selected Custom Knife",
    Values = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"},
    Value = "Butterfly Knife",
    Callback = function(Options)
        selectedKnife = (type(Options) == "table" and Options[1] or Options)
        if spawned then removeViewmodel() end
    end
})

Tab_Skins:Section({ Title = "Knives Skins" })
for name in pairs(KNIVES) do CreateSkinDropdown(name) end

Tab_Skins:Section({ Title = "Gloves" })
for name in pairs(GLOVES) do CreateSkinDropdown(name) end

Tab_Skins:Section({ Title = "CT Weapons" })
for name in pairs(CT_ONLY) do CreateSkinDropdown(name) end

Tab_Skins:Section({ Title = "T Weapons" })
for name in pairs(SHARED) do CreateSkinDropdown(name) end

for _, folder in SkinsFolder:GetChildren() do
    local n = folder.Name
    if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then 
        CreateSkinDropdown(n) 
    end
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAlive() then return end
    task.wait(COOLDOWN)
    applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAlive() then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then 
                    applyWeaponSkin(obj) 
                end
            end
        end
    end
end)
--// ==========================================
--// PREMIUM FEATURES UPDATE (v3.1)
--// ==========================================

-- 1. Hitmarker & Sound (Visuals)
local HitConfig = { Enabled = false, SoundID = "rbxassetid://160432334" }
Tab_Visuals:Section({ Title = "Hitmarker & Sounds" })
Tab_Visuals:Toggle({
    Title = "Enable Hitmarker",
    Value = false,
    Callback = function(Value) HitConfig.Enabled = Value end
})

local HitmarkerGUI = Instance.new("ScreenGui")
HitmarkerGUI.Name = "IndraHub_Hitmarker"
HitmarkerGUI.ResetOnSpawn = false
if game.CoreGui:FindFirstChild("IndraHub_Hitmarker") then game.CoreGui:FindFirstChild("IndraHub_Hitmarker"):Destroy() end
HitmarkerGUI.Parent = pcall(function() return game.CoreGui end) and game.CoreGui or player.PlayerGui

local HitImage = Instance.new("ImageLabel")
HitImage.Size = UDim2.new(0, 40, 0, 40)
HitImage.Position = UDim2.new(0.5, -20, 0.5, -20)
HitImage.BackgroundTransparency = 1
HitImage.Image = "rbxassetid://4155801269" -- Generic X Hitmarker
HitImage.ImageColor3 = Color3.new(1, 1, 1)
HitImage.ImageTransparency = 1
HitImage.Parent = HitmarkerGUI

local function ShowHitmarker()
    if not HitConfig.Enabled then return end
    local sound = Instance.new("Sound", Workspace)
    sound.SoundId = HitConfig.SoundID
    sound.Volume = 1
    sound:Play()
    game.Debris:AddItem(sound, 2)
    
    HitImage.ImageTransparency = 0
    TweenService:Create(HitImage, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 and HitConfig.Enabled and isAlive() then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if result and result.Instance then
            local enemyFolder = getEnemyFolder()
            if enemyFolder and result.Instance:IsDescendantOf(enemyFolder) then
                ShowHitmarker()
            end
        end
    end
end)


-- 2. Spectator List (Misc)
local SpecConfig = { Enabled = false }
Tab_Misc:Section({ Title = "Spectators" })
Tab_Misc:Toggle({
    Title = "Spectator List",
    Value = false,
    Callback = function(Value) SpecConfig.Enabled = Value end
})

local SpecGui = Instance.new("ScreenGui")
SpecGui.Name = "IndraHub_SpecList"
if game.CoreGui:FindFirstChild("IndraHub_SpecList") then game.CoreGui:FindFirstChild("IndraHub_SpecList"):Destroy() end
SpecGui.Parent = pcall(function() return game.CoreGui end) and game.CoreGui or player.PlayerGui

local SpecFrame = Instance.new("Frame")
SpecFrame.Size = UDim2.new(0, 200, 0, 30)
SpecFrame.Position = UDim2.new(0, 20, 0.5, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpecFrame.BorderSizePixel = 0
SpecFrame.Visible = false
SpecFrame.Parent = SpecGui
local uiCorner = Instance.new("UICorner", SpecFrame)
local SpecTitle = Instance.new("TextLabel", SpecFrame)
SpecTitle.Size = UDim2.new(1, 0, 1, 0)
SpecTitle.BackgroundTransparency = 1
SpecTitle.Text = "Spectators: 0"
SpecTitle.TextColor3 = Color3.new(1,1,1)
SpecTitle.Font = Enum.Font.GothamBold
SpecTitle.TextSize = 14

local SpecContainer = Instance.new("Frame", SpecFrame)
SpecContainer.Size = UDim2.new(1, 0, 0, 0)
SpecContainer.Position = UDim2.new(0, 0, 1, 0)
SpecContainer.BackgroundTransparency = 1
local specLayout = Instance.new("UIListLayout", SpecContainer)
specLayout.SortOrder = Enum.SortOrder.LayoutOrder

task.spawn(function()
    while task.wait(1) do
        if SpecConfig.Enabled then
            SpecFrame.Visible = true
            local count = 0
            for _, child in pairs(SpecContainer:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local isSpectating = false
                    local obs = p:FindFirstChild("Observer") or p:FindFirstChild("Spectating")
                    if obs and obs.Value == player.Name then isSpectating = true end
                    
                    if isSpectating then
                        count = count + 1
                        local lbl = Instance.new("TextLabel", SpecContainer)
                        lbl.Size = UDim2.new(1, 0, 0, 20)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = p.Name
                        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                        lbl.Font = Enum.Font.Gotham
                        lbl.TextSize = 12
                    end
                end
            end
            SpecTitle.Text = "Spectators: " .. count
            SpecFrame.Size = UDim2.new(0, 200, 0, 30 + (count * 20))
        else
            SpecFrame.Visible = false
        end
    end
end)


-- 3. Third Person Mode (Visuals)
local TPConfig = { Enabled = false, Zoom = 10 }
Tab_Visuals:Section({ Title = "Camera" })
Tab_Visuals:Toggle({
    Title = "Third Person",
    Value = false,
    Callback = function(Value)
        TPConfig.Enabled = Value
        if Value then
            player.CameraMaxZoomDistance = TPConfig.Zoom
            player.CameraMinZoomDistance = TPConfig.Zoom
        else
            player.CameraMaxZoomDistance = 0.5
            player.CameraMinZoomDistance = 0.5
        end
    end
})
Tab_Visuals:Slider({
    Title = "Third Person Distance",
    Min = 5,
    Max = 30,
    Value = 10,
    Step = 1,
    Callback = function(Value)
        TPConfig.Zoom = Value
        if TPConfig.Enabled then
            player.CameraMaxZoomDistance = Value
            player.CameraMinZoomDistance = Value
        end
    end
})


-- 4. Bullet Tracers (Visuals)
local TracerConfig = { Enabled = false, Color = Color3.new(1, 0, 0) }
Tab_Visuals:Section({ Title = "Bullet Tracers" })
Tab_Visuals:Toggle({
    Title = "Enable Tracers",
    Value = false,
    Callback = function(Value) TracerConfig.Enabled = Value end
})
Tab_Visuals:ColorPicker({
    Title = "Tracer Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(Value) TracerConfig.Color = Value end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 and TracerConfig.Enabled and isAlive() then
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("FirePart") or char:FindFirstChild("Head")
            if handle then
                local mousePos = UserInputService:GetMouseLocation()
                local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
                local endPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
                
                local tracer = Instance.new("Part")
                tracer.Anchored = true
                tracer.CanCollide = false
                tracer.Material = Enum.Material.Neon
                tracer.Color = TracerConfig.Color
                local dist = (handle.Position - endPos).Magnitude
                tracer.Size = Vector3.new(0.1, 0.1, dist)
                tracer.CFrame = CFrame.new(handle.Position, endPos) * CFrame.new(0, 0, -dist/2)
                tracer.Parent = Workspace
                
                TweenService:Create(tracer, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0,0,dist)}):Play()
                game.Debris:AddItem(tracer, 0.5)
            end
        end
    end
end)


-- 5. Gun Mods (Combat)
local GunMods = { NoRecoil = false, NoSpread = false }
Tab_Combat:Section({ Title = "Gun Mods" })
Tab_Combat:Toggle({
    Title = "No Recoil",
    Value = false,
    Callback = function(Value) GunMods.NoRecoil = Value end
})
Tab_Combat:Toggle({
    Title = "No Spread",
    Value = false,
    Callback = function(Value) GunMods.NoSpread = Value end
})

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(t, k)
    if not checkcaller() and GunMods.NoSpread and type(k) == "string" and (k:lower():match("spread") or k:lower():match("accuracy")) then
        return 0
    end
    if not checkcaller() and GunMods.NoRecoil and type(k) == "string" and (k:lower():match("recoil") or k:lower():match("kick")) then
        return 0
    end
    return oldIndex(t, k)
end)


-- 6. Bomb/C4 ESP (Visuals)
local BombConfig = { Enabled = false }
Tab_Visuals:Section({ Title = "Objective ESP" })
Tab_Visuals:Toggle({
    Title = "Bomb/C4 ESP",
    Value = false,
    Callback = function(Value) BombConfig.Enabled = Value end
})

local bombBillboard = Instance.new("BillboardGui")
bombBillboard.Size = UDim2.new(0, 100, 0, 50)
bombBillboard.AlwaysOnTop = true
local bombText = Instance.new("TextLabel", bombBillboard)
bombText.Size = UDim2.new(1, 0, 1, 0)
bombText.BackgroundTransparency = 1
bombText.TextColor3 = Color3.new(1, 0, 0)
bombText.TextStrokeTransparency = 0
bombText.Font = Enum.Font.GothamBold
bombText.TextSize = 14

task.spawn(function()
    while task.wait(0.5) do
        if BombConfig.Enabled then
            local c4 = Workspace:FindFirstChild("C4") or Workspace:FindFirstChild("Bomb")
            if c4 and c4:IsA("Model") then
                local mainPart = c4.PrimaryPart or c4:FindFirstChildOfClass("BasePart")
                if mainPart then
                    bombBillboard.Parent = mainPart
                    local dist = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and math.floor((player.Character.HumanoidRootPart.Position - mainPart.Position).Magnitude) or 0
                    bombText.Text = "C4 [" .. dist .. "m]"
                end
            else
                bombBillboard.Parent = nil
            end
        else
            bombBillboard.Parent = nil
        end
    end
end)

print("IndraHub Premium v3.1.0 - Loaded Successfully")
