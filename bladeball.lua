-- IndraHub – Blade Ball Auto Parry
-- WindUI | Accuracy slider | Curves | Orbit + noclip

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

-- ===== CONFIG =====
local PARRIED_COOLDOWN = 0.8
local TIME_TO_IMPACT_THRESHOLD = 0.5
local ACCURACY_DEFAULT = 95
local CURVE_EXTRA_DELAY = 0.04
local SPAM_MODE_TRIGGER = 1
local SPAM_WINDOW = 0.8
local SPAM_FIRE_RATE = 0.015

local CURVE_HOLD_TIME = 0.12
local CURVE_RESTORE_AFTER = 0.15

local CIRCLE_COLOR_READY = Color3.fromRGB(50, 200, 50)
local CIRCLE_COLOR_WARNING = Color3.fromRGB(200, 50, 50)
local CIRCLE_RADIUS_STUDS = 15
local CIRCLE_TRANSPARENCY = 0.7
local CIRCLE_HEIGHT_OFFSET = 0.2

local ORBIT_RADIUS = 12
local ORBIT_ANGULAR_SPEED = 3
local ORBIT_HEIGHT_OFFSET = 3
-- ==================

local currentAccuracy = ACCURACY_DEFAULT
rawset(_G, "BladeBallRunning", true)
rawset(_G, "BladeBallLastHeartbeat", os.clock())
rawset(_G, "BladeBallError", nil)

local function getEarlyOffset()
    return (100 - currentAccuracy) * 0.0015
end

-- State
local enabled = false
local canParry = true
local spamMode = false
local parryHistory = {}
local currentCurve = "Default"
local lastTargetTime, retargetCount = 0, 0
local firedBallData = {}
local orbitEnabled = false

local pendingRestoreConnection = nil

task.spawn(function()
    while rawget(_G, "BladeBallRunning") == true do
        rawset(_G, "BladeBallLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

-- ===== FLOOR CIRCLE =====
local circlePart = Instance.new("Part")
circlePart.Name = "ParryCircle"
circlePart.Anchored = true
circlePart.CanCollide = false
circlePart.Transparency = CIRCLE_TRANSPARENCY
circlePart.BrickColor = BrickColor.new(CIRCLE_COLOR_WARNING)
circlePart.Size = Vector3.new(CIRCLE_RADIUS_STUDS * 2, 0.05, CIRCLE_RADIUS_STUDS * 2)
circlePart.Shape = Enum.PartType.Cylinder
circlePart.Material = Enum.Material.Neon
circlePart.Parent = Workspace

local function updateFloorCircle(ballDistance)
    if not enabled or not Player.Character then
        circlePart.Visible = false
        return
    end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        circlePart.Visible = false
        return
    end
    circlePart.Visible = true
    circlePart.Position = hrp.Position + Vector3.new(0, CIRCLE_HEIGHT_OFFSET, 0)

    if ballDistance and ballDistance <= CIRCLE_RADIUS_STUDS and canParry then
        circlePart.BrickColor = BrickColor.new(CIRCLE_COLOR_READY)
    else
        circlePart.BrickColor = BrickColor.new(CIRCLE_COLOR_WARNING)
    end
end

-- ===== CAMERA CURVES =====
local function cancelPendingRestore()
    if pendingRestoreConnection then
        pendingRestoreConnection:Disconnect()
        pendingRestoreConnection = nil
    end
end

local function applyCameraCurve(ball, callback)
    if currentCurve == "Default" then
        callback()
        return
    end

    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        callback()
        return
    end

    cancelPendingRestore()

    local originalCF = camera.CFrame
    local playerPos = root.Position
    local right, up, look = root.CFrame.RightVector, root.CFrame.UpVector, root.CFrame.LookVector
    local lookDir

    if currentCurve == "Up" then
        lookDir = Vector3.new(0, 1, 0)
    elseif currentCurve == "Backwards" then
        lookDir = -look
    elseif currentCurve == "Down" then
        lookDir = Vector3.new(0, -1, 0)
    elseif currentCurve == "Up-Left" then
        lookDir = (up - right).Unit
    elseif currentCurve == "Up-Right" then
        lookDir = (up + right).Unit
    elseif currentCurve == "Random" then
        local options = {Vector3.new(0,1,0), Vector3.new(0,-1,0), up-right, up+right, -look}
        lookDir = options[math.random(#options)]
    end

    if lookDir then
        camera.CFrame = CFrame.new(camera.CFrame.Position, playerPos + lookDir * 10)
    end

    task.wait(0.03)
    callback()

    pendingRestoreConnection = task.delay(CURVE_RESTORE_AFTER, function()
        camera.CFrame = originalCF
        pendingRestoreConnection = nil
    end)
end

-- ===== BALL DETECTION =====
function GetBall()
    for _, b in ipairs(workspace.Balls:GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
    return nil
end

-- ===== ANTI-DOUBLE-CLICK =====
local function canParryThisBall(ball, currentDist)
    local data = firedBallData[ball]
    if not data then return true end
    if currentDist > data.dist + 3 then
        firedBallData[ball] = nil
        return true
    end
    return false
end
local function recordFire(ball, dist)
    firedBallData[ball] = {dist = dist, time = tick()}
end

-- ===== SPAM DETECTION =====
local function recordParry()
    table.insert(parryHistory, tick())
    local cutoff = tick() - SPAM_WINDOW
    while #parryHistory > 0 and parryHistory[1] < cutoff do table.remove(parryHistory, 1) end
    retargetCount = retargetCount + 1
    if tick() - lastTargetTime > 1 then retargetCount = 1 end
    lastTargetTime = tick()
end
local function shouldSpam() return #parryHistory >= SPAM_MODE_TRIGGER or retargetCount >= 2 end
local function exitSpam() if spamMode then spamMode = false; canParry = true end end

workspace.Balls.ChildAdded:Connect(function()
    local ball = GetBall()
    if not ball then return end
    exitSpam()
    parryHistory, retargetCount = {}, 0
    canParry = true
    firedBallData = {}
    ball:GetAttributeChangedSignal("target"):Connect(function()
        if ball:GetAttribute("target") == Player.Name then
            retargetCount = retargetCount + 1
            lastTargetTime = tick()
            if retargetCount >= 2 and not spamMode then
                spamMode = true; canParry = true
            end
            if firedBallData[ball] then
                firedBallData[ball] = nil
            end
        end
    end)
end)

-- ===== ORBIT MOVEMENT + NOCLIP =====
local function setNoclip(state)
    local char = Player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local lastOrbitTime = tick()
RunService.PreSimulation:Connect(function()
    if not orbitEnabled or not enabled then return end
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ball = GetBall()
    if not ball then return end

    local dt = tick() - lastOrbitTime
    lastOrbitTime = tick()

    local targetY = ball.Position.Y + ORBIT_HEIGHT_OFFSET
    local ballPos = ball.Position

    local dir = (hrp.Position - ballPos).Unit
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    if dir.Magnitude < 0.01 then return end

    local angle = ORBIT_ANGULAR_SPEED * dt
    local newDir = (CFrame.Angles(0, angle, 0) * dir).Unit
    local newXZ = ballPos + newDir * ORBIT_RADIUS
    local newPos = Vector3.new(newXZ.X, targetY, newXZ.Z)

    hrp.CFrame = CFrame.new(newPos) * CFrame.Angles(0, math.atan2(newDir.X, newDir.Z), 0)
end)

local function updateOrbitState()
    if orbitEnabled then
        setNoclip(true)
    else
        setNoclip(false)
    end
end

-- ===== MAIN PARRY LOOP =====
RunService.PreSimulation:Connect(function()
    if not enabled then return end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        updateFloorCircle(nil)
        return
    end

    local ball = GetBall()
    if not ball then
        exitSpam()
        updateFloorCircle(nil)
        return
    end

    local dist = (hrp.Position - ball.Position).Magnitude
    local vel = ball.zoomies.VectorVelocity
    local speed = vel.Magnitude
    if speed < 0.1 then
        updateFloorCircle(dist)
        return
    end

    local toMe = (hrp.Position - ball.Position).Unit
    local approach = vel:Dot(toMe)
    local eta = (approach > 0 and dist > 0) and (dist / approach) or math.huge
    local target = ball:GetAttribute("target")
    local targetingUs = (target == Player.Name)

    if spamMode and not targetingUs then exitSpam(); return end

    if not canParryThisBall(ball, dist) then
        updateFloorCircle(dist)
        return
    end

    local baseThreshold = TIME_TO_IMPACT_THRESHOLD
    local earlyOffset = getEarlyOffset()
    local threshold = baseThreshold + earlyOffset
    if currentCurve ~= "Default" then
        threshold = threshold + CURVE_EXTRA_DELAY
    end

    local fire = false
    if targetingUs and eta <= threshold then
        if spamMode then
            if canParry then fire = true end
        else
            if canParry then fire = true end
        end
    end

    if fire then
        recordFire(ball, dist)
        recordParry()

        if not spamMode then
            canParry = false
            if shouldSpam() then
                spamMode = true; canParry = false
                task.delay(SPAM_FIRE_RATE, function() canParry = true end)
            else
                task.delay(PARRIED_COOLDOWN, function() canParry = true end)
            end
        else
            canParry = false
            task.delay(SPAM_FIRE_RATE, function() canParry = true end)
        end

        applyCameraCurve(ball, function()
            local blockBtn = Player.PlayerGui.Hotbar:FindFirstChild("Block")
            if blockBtn and blockBtn.Activated then
                for _, conn in pairs(getconnections(blockBtn.Activated)) do
                    pcall(function() conn:Fire() end)
                end
            end
        end)
    end

    updateFloorCircle(dist)
end)

-- ===== WINDUI =====
local env = getgenv and getgenv() or _G

local function fetch(url, cache)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end
    local data = game:HttpGet(url)
    if type(writefile) == "function" then pcall(function() writefile(cache, data) end) end
    return data
end

local WindUI = loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_BladeBall_WindUI.lua"))()

if env.IndraHubBladeBallWindow then pcall(function() env.IndraHubBladeBallWindow:Destroy() end) end

local function notify(title, content, icon)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function() WindUI:Notify({ Title = title, Content = content, Icon = icon or "info", Duration = 3 }) end)
    else
        print("[IndraHub] " .. tostring(title) .. ": " .. tostring(content))
    end
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "circle-dot",
    Author = "Blade Ball Auto Parry",
    Folder = "IndraHubBladeBall",
    Size = UDim2.fromOffset(560, 420),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 160,
})

env.IndraHubBladeBallWindow = Window
Window:SetToggleKey(Enum.KeyCode.RightControl)
Window:EditOpenButton({ Title = "IndraHub", Icon = "circle-dot", Draggable = true })

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "shield" }),
    Curves = Window:Tab({ Title = "Curves", Icon = "activity" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "orbit" }),
    Info = Window:Tab({ Title = "Info", Icon = "info" }),
}

Tabs.Main:Toggle({
    Title = "Auto Parry",
    Desc = "Auto block when ball targets you.",
    Value = false,
    Callback = function(value)
        enabled = value
        if not enabled then spamMode = false end
        notify("Auto Parry", value and "ON" or "OFF", "shield")
    end,
})

Tabs.Main:Slider({
    Title = "Accuracy",
    Desc = "Higher = later parry. Lower = earlier parry.",
    Value = { Min = 0, Max = 100, Default = currentAccuracy },
    Step = 1,
    Callback = function(value)
        currentAccuracy = value
    end,
})

local curveOptions = {"Default", "Up", "Backwards", "Down", "Up-Left", "Up-Right", "Random"}

Tabs.Curves:Dropdown({
    Title = "Curve Direction",
    Desc = "Camera snap direction used before parry.",
    Values = curveOptions,
    Value = "Default",
    Callback = function(option)
        currentCurve = type(option) == "table" and option[1] or option or "Default"
    end,
})

Tabs.Movement:Toggle({
    Title = "Orbit + Noclip",
    Desc = "Circle around ball while noclip is enabled.",
    Value = false,
    Callback = function(value)
        orbitEnabled = value
        updateOrbitState()
        notify("Orbit", value and "ON" or "OFF", "orbit")
    end,
})

Tabs.Info:Section({ Title = "IndraHub Blade Ball", Icon = "circle-dot" })
Tabs.Info:Section({ Title = "95% accuracy = late parry. Lower = earlier.", Icon = "info" })
Tabs.Info:Section({ Title = "Curves snap camera on parry. Orbit circles ball with noclip.", Icon = "activity" })

notify("IndraHub", "Blade Ball loaded. Accuracy: " .. currentAccuracy .. "%", "circle-dot")
print("IndraHub Blade Ball loaded. Accuracy:", currentAccuracy, "%")





