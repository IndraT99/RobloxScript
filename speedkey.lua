local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local HUB_NAME = "IndraHub"

-- godmode (bypasses client traps/npc)
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if not checkcaller() and key == "Health" and self:IsA("Humanoid") then
        local character = LocalPlayer.Character
        if character and self:IsDescendantOf(character) then
            if type(value) == "number" and value <= 0 then
                return 
            end
        end
    end
    return oldNewIndex(self, key, value)
end)

-- npc zones
local npcZoneTags = {
    "NPC9_Zone",
    "NPC10_AttackZone",
    "NPC12_LabyrinthZone",
    "NPC15_Zone",
    "NPC15_SpeedZone",
    "MacaronMonster_AttackZone"
}

local function destroyZone(inst)
    if inst and inst.Parent then
        inst:Destroy()
    end
end

for _, tag in ipairs(npcZoneTags) do
    for _, inst in ipairs(CollectionService:GetTagged(tag)) do
        destroyZone(inst)
    end
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
        task.defer(destroyZone, inst)
    end)
end

-- npc destroy
local npcNames = {
    ["NPC9"] = true,
    ["NPC10"] = true,
    ["NPC12"] = true,
    ["NPC15"] = true,
    ["NPC_MacaronMonster"] = true
}

local function handleWorkspaceDescendant(desc)
    if npcNames[desc.Name] then
        task.defer(function()
            if desc.Parent then
                desc:Destroy()
            end
        end)
    end
end

for _, desc in ipairs(workspace:GetDescendants()) do
    handleWorkspaceDescendant(desc)
end
workspace.DescendantAdded:Connect(handleWorkspaceDescendant)

-- trap disarmer
local trapTags = {
    "CrushTrap",
    "LavaTrap",
    "MovingWallModel",
    "TsunamiModel"
}

local function disableTrapPart(part)
    if part:IsA("BasePart") then
        local name = part.Name
        if string.find(name, "MovingWall") 
            or name == "WallL" 
            or name == "WallR" 
            or name == "LavaPart" 
            or name == "Tsunami" 
        then
            part.CanCollide = false
            part.CanTouch = false
            part.Transparency = 0.6
        end
    end
end

for _, tag in ipairs(trapTags) do
    for _, trap in ipairs(CollectionService:GetTagged(tag)) do
        for _, desc in ipairs(trap:GetDescendants()) do
            disableTrapPart(desc)
        end
        trap.DescendantAdded:Connect(disableTrapPart)
    end
    
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(trap)
        for _, desc in ipairs(trap:GetDescendants()) do
            disableTrapPart(desc)
        end
        trap.DescendantAdded:Connect(disableTrapPart)
    end)
end

-- path to follow
local path = {
    Vector3.new(-538.81, 54.73, 1467.41),
    Vector3.new(-1087.84, 54.72, 1467.17),
    Vector3.new(-1092.34, 296.73, 1467.14),
    Vector3.new(-1240.36, 302.92, 1469.17),
    Vector3.new(-1378.21, 290.70, 1468.16),
    Vector3.new(-1422.84, 335.34, 1469.52),
    Vector3.new(-1506.04, 337.10, 1469.52),
    Vector3.new(-1622.44, 321.50, 1469.52),
    Vector3.new(-1816.66, 301.41, 1467.65),
    Vector3.new(-1861.17, 317.35, 1468.30),
    Vector3.new(-2012.61, 307.68, 1467.25),
    Vector3.new(-2155.17, 317.56, 1467.23),
    Vector3.new(-2176.93, 325.10, 1467.23),
    Vector3.new(-2314.67, 315.22, 1467.26),
    Vector3.new(-2345.06, 326.15, 1467.24),
    Vector3.new(-2515.24, 322.99, 1467.24),
    Vector3.new(-2664.66, 294.50, 1480.21),
    Vector3.new(-2780.65, 306.12, 1477.10),
    Vector3.new(-2789.97, 309.54, 1477.40),
    Vector3.new(-2946.51, 296.72, 1477.03),
    Vector3.new(-3943.46, 296.73, 1475.96),
    Vector3.new(-4302.24, 296.71, 1473.44),
    Vector3.new(-4303.76, 343.73, 1473.44),
    Vector3.new(-4310.13, 343.75, 1488.40),
    Vector3.new(-4319.32, 398.57, 1603.56),
    Vector3.new(-4347.34, 400.42, 1610.86),
    Vector3.new(-4347.62, 407.62, 1571.09),
    Vector3.new(-4348.67, 418.48, 1438.44),
    Vector3.new(-4349.52, 434.76, 1406.09),
    Vector3.new(-4327.20, 434.89, 1393.84),
    Vector3.new(-4238.68, 436.17, 1393.75),
    Vector3.new(-4322.98, 440.25, 1493.15),
    Vector3.new(-4325.81, 471.13, 1509.14),
    Vector3.new(-4383.67, 471.24, 1537.19),
    Vector3.new(-5346, 477, 1460)
}

local farmSpeed = 200
local farmingEnabled = false

-- get character and hrp
local function getCharacterAndHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    return char, hrp
end

-- simulate touch
local function triggerTouchInterest(targetPart, playerPart)
    if firetouchinterest and targetPart and playerPart then
        firetouchinterest(targetPart, playerPart, 0)
        task.wait(0.05)
        firetouchinterest(targetPart, playerPart, 1)
    end
end

-- farm loop
local function startFarm()
    task.spawn(function()
        while farmingEnabled do
            local character, hrp = getCharacterAndHRP()
            
            if character and hrp then
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                local checkpointEvent = remotes and remotes:FindFirstChild("RequestCheckpointTp")
                
                if checkpointEvent then
                    checkpointEvent:FireServer(6, "wins")
                end
                
                task.wait(0.5)
                if not farmingEnabled then break end
                
                for _, targetPos in ipairs(path) do
                    if not farmingEnabled then break end
                    
                    character, hrp = getCharacterAndHRP()
                    if not hrp or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
                        break
                    end
                    
                    local distance = (hrp.Position - targetPos).Magnitude
                    local duration = distance / farmSpeed
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
                    
                    tween:Play()
                    
                    local completed = false
                    local connection
                    connection = tween.Completed:Connect(function()
                        completed = true
                    end)
                    
                    while not completed and farmingEnabled do
                        task.wait()
                        if not hrp or not hrp.Parent or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
                            tween:Cancel()
                            if connection then connection:Disconnect() end
                            break
                        end
                    end
                    
                    if connection then connection:Disconnect() end
                    if not completed then break end
                end
                
                if not farmingEnabled then break end
                
                local winBlock = workspace:FindFirstChild("Structure") 
                    and workspace.Structure:FindFirstChild("Stage13") 
                    and workspace.Structure.Stage13:FindFirstChild("WinBlock12")
                    
                if winBlock then
                    character, hrp = getCharacterAndHRP()
                    if hrp then
                        triggerTouchInterest(winBlock, hrp)
                    end
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- windui gui
local okWindUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not okWindUI then
    return warn("[" .. HUB_NAME .. "] WindUI failed to load")
end

local function notify(title, content)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = 3
        })
    end)
end

local Window = WindUI:CreateWindow({
    Title = HUB_NAME .. " | Speed Key",
    Icon = "zap",
    Size = UDim2.fromOffset(480, 360),
    Transparent = true,
    Theme = "Dark"
})
Window:SetToggleKey(Enum.KeyCode.RightControl)

local MainTab = Window:Tab({ Title = "Auto Farm", Icon = "route" })
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

MainTab:Paragraph({
    Title = "Requirement",
    Desc = "Need at least 200 wins before using checkpoint farm."
})

MainTab:Paragraph({
    Title = "Bypass Status",
    Desc = "Godmode hook active. NPC zones, NPCs, and trap parts are disabled."
})

MainTab:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(value)
        farmingEnabled = value
        if value then
            notify(HUB_NAME, "Auto farm started")
            startFarm()
        else
            notify(HUB_NAME, "Auto farm stopped")
        end
    end
})

MainTab:Slider({
    Title = "Fly Speed",
    Value = { Min = 50, Max = 500, Default = farmSpeed },
    Step = 10,
    Callback = function(value)
        farmSpeed = value
    end
})

local currentExecutor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "web / unknown exploit"

InfoTab:Paragraph({
    Title = "Executor",
    Desc = "Running on: " .. tostring(currentExecutor)
})

InfoTab:Button({
    Title = "Copy Executor Name",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(currentExecutor))
            notify(HUB_NAME, "Executor copied")
        else
            notify(HUB_NAME, "Clipboard not supported")
        end
    end
})

Window:SelectTab(1)
notify(HUB_NAME, "Loaded. Press RightControl to toggle menu.")
