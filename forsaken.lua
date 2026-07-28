-- =====================================================================
--  INDRAHUB | Forsaken Edition
-- =====================================================================

local env = getgenv and getgenv() or _G

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = env[key]
    if value ~= nil then return value end
    return rawget(_G, key)
end

if getGlobal("IndraHubForsakenRunning") == true then
    return
end

local sessionKey = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
setGlobal("IndraHubForsakenSession", sessionKey)
setGlobal("IndraHubForsakenRunning", true)
setGlobal("IndraHubForsakenLastHeartbeat", os.clock())
setGlobal("IndraHubForsakenError", nil)

-- Heartbeat Updater
task.spawn(function()
    while getGlobal("IndraHubForsakenRunning") == true
        and getGlobal("IndraHubForsakenSession") == sessionKey do
        setGlobal("IndraHubForsakenLastHeartbeat", os.clock())
        task.wait(5)
    end
end)

shared.IndraHub_Forsaken_Unloaded = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Exploit Internal State
local flags = {
    -- Automation
    AutoGeneratorPuzzle = false,
    GeneratorCooldown = 1.5,
    SpeedUpCooldown = false,
    AutoPickup = false,

    -- Features
    Invincible = false,
    DisableKillerWalls = false,
    DisableToxicTrails = false,
    DisableFootprints = false,
    SmallerSpikeCollisions = false,
    EnableJumping = false,
    StaminaPreset = "Original",
    AntiSlowness = false,
    AnimationChanger = "Original",
    ChangeInLobby = false,
    NoliControl = false,
    ControllableDash = false,
    AutoBlock = false,

    -- Visuals
    DisableNoliNPC = false,
    Disable007n7NPC = false,
    ESPMaster = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPDistance = false,
    ESPTracers = false,
    ESPMaxDistance = 3000,
    KillersESP = false,
    KillersColor = "Red",
    SurvivorsESP = false,
    SurvivorsColor = "Green",
    GeneratorsESP = false,
    GeneratorsColor = "Cyan",
    GeneratorsCheck = true,
    ItemsESP = false,
    ItemsColor = "Gold",

    -- Misc
    ExtendedFOV = 70,
    ExtendedZoom = 10,
    ShowChat = false,
    ShowPrivacy = false,
    HideInjury = true,
    DeleteRagdolls = false,
    PlayerSelectCrash = "None",
    CrashTheTarget = false,
    SkyGlitch = false,
    InstaKill = false,
}

local colorMap = {
    White = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0),
    Blue = Color3.fromRGB(0, 0, 255),
    Cyan = Color3.fromRGB(0, 255, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Orange = Color3.fromRGB(255, 165, 0),
    Purple = Color3.fromRGB(158, 0, 179)
}

-- Workspace Folders
local PlayersFolder = workspace:FindFirstChild("Players")
local KillersFolder = PlayersFolder and PlayersFolder:FindFirstChild("Killers")
local SurvivorsFolder = PlayersFolder and PlayersFolder:FindFirstChild("Survivors")
local RagdollsFolder = workspace:FindFirstChild("Ragdolls")
local Hitboxes = workspace:FindFirstChild("Hitboxes")
local InGame = workspace:FindFirstChild("Map") and workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
local GameMap = InGame and InGame:FindFirstChild("Map")

local LocalCharacter = LocalPlayer.Character
local LocalHumanoid = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Humanoid")
local LocalHead = LocalCharacter and LocalCharacter:FindFirstChild("Head")
local LocalRoot = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")
local SpeedMultipliers = LocalCharacter and LocalCharacter:FindFirstChild("SpeedMultipliers")

-- Load modules
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
local MainUI = PlayerGui:FindFirstChild("MainUI") or PlayerGui:WaitForChild("MainUI", 60)
local PlayerData = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:WaitForChild("PlayerData", 20)

local MainModule = nil
local IsRequireSupported = false
local allAnimations = {
    ["RobloxDefault"] = {
        ["Idle"] = "http://www.roblox.com/asset/?id=180435571",
        ["Walk"] = "http://www.roblox.com/asset/?id=180426354",
        ["Run"] = "http://www.roblox.com/asset/?id=180426354"
    }
}
local overridenAnimations = {}
local lastAnimOriginalUsed = nil
local NoliConfig = nil

local function singleDropdownValue(value)
    if type(value) ~= "table" then return value end
    for key, selectedValue in pairs(value) do
        if selectedValue == true and type(key) == "string" then return key end
        if type(selectedValue) == "string" then return selectedValue end
    end
    return nil
end

local function isPlayersNear(distance)
    if LocalCharacter and LocalRoot then
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if (v.Character.HumanoidRootPart.Position - LocalRoot.Position).Magnitude < distance then
                    return true
                end
            end
        end
    end
    return false
end

local function getNumericId(url)
    if type(url) == "number" then return tostring(url) end
    if type(url) == "string" then
        return url:match("%d+")
    end
    return nil
end

local function getAnimationType(id)
    local checkIdStr = getNumericId(id)
    if not checkIdStr then return nil end
    for name, animSet in pairs(allAnimations) do
        for animType, animId in pairs(animSet) do
            if type(animId) == "table" then
                for _, subId in ipairs(animId) do
                    local subIdStr = getNumericId(subId)
                    if subIdStr == checkIdStr then
                        return animType, name
                    end
                end
            else
                local subIdStr = getNumericId(animId)
                if subIdStr == checkIdStr then
                    return animType, name
                end
            end
        end
    end
    return nil
end

local function isHitboxNotNear(hitboxPart, position)
    if hitboxPart and position and LocalRoot then
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.MaxParts = 1
        params.FilterDescendantsInstances = {hitboxPart}
        local result = workspace:GetPartBoundsInRadius(position, 2.5, params)
        return #result == 0
    end
    return false
end

local function velocityToPosition(target)
    if not LocalRoot then return end
    local timeLimit = workspace.DistributedGameTime + 7
    local originalGroup = LocalRoot.CollisionGroup
    local allParts = {}
    for _, part in ipairs(LocalCharacter:GetDescendants()) do
        if part:IsA("BasePart") and part.CollisionGroup ~= "Default" then
            table.insert(allParts, part)
            part.CollisionGroup = "None"
        end
    end
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = LocalRoot
    while (LocalRoot.Position - target).Magnitude > 2 and (workspace.DistributedGameTime < timeLimit) do
        bodyVelocity.Velocity = (target - LocalRoot.Position).Unit * 100
        RunService.RenderStepped:Wait()
    end
    bodyVelocity:Destroy()
    for _, part in ipairs(allParts) do
        part.CollisionGroup = originalGroup
    end
end

local isUnderground = false
local function goUnderground(state)
    local offset = 22
    if state and not isUnderground then
        if not (LocalRoot and LocalHead and LocalHumanoid and MainUI.Enabled) then
            repeat task.wait(0.25) until (LocalRoot and LocalHead and LocalHumanoid and MainUI.Enabled)
        end
        local mapName = ""
        if GameMap and GameMap:FindFirstChild("Config") then
            local mapData = require(GameMap.Config)
            if mapData and mapData.DisplayName then
                mapName = mapData.DisplayName
            end
        end
        local oldCFrame = LocalRoot.CFrame
        local underCFrame
        if mapName == "Underground War" then
            local selfParams = OverlapParams.new()
            selfParams.FilterType = Enum.RaycastFilterType.Include
            selfParams.MaxParts = 1
            selfParams.FilterDescendantsInstances = {LocalRoot}
            local boxCheck = workspace:GetPartBoundsInBox(CFrame.new(-172, 4444, -20), Vector3.new(230, 35, 300), selfParams)
            if #boxCheck > 0 then
                offset = 50
            end
            local mapPart = GameMap:FindFirstChild("DirtSlabs", true) and GameMap:FindFirstChild("DirtSlabs", true):FindFirstChildWhichIsA("BasePart")
            if mapPart then
                underCFrame = CFrame.new(Vector3.new(oldCFrame.X + 0.5, mapPart.Position.Y - 7.5, oldCFrame.Z + 0.5))
            else
                underCFrame = oldCFrame * CFrame.new(0, -offset, 0)
            end
        else
            underCFrame = oldCFrame * CFrame.new(0, -offset, 0)
        end
        LocalHumanoid.CameraOffset = Vector3.new(0, 12e12, 0)
        task.wait(0.1)
        LocalRoot.CFrame = underCFrame
        local tries = 0
        local timerStop = workspace.DistributedGameTime + 3.5
        repeat
            tries = tries + 1
            LocalRoot.Velocity = Vector3.zero
            velocityToPosition(underCFrame.Position)
            LocalHead.Anchored = true
            repeat task.wait() until isHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"), oldCFrame.Position) or not LocalRoot or not LocalCharacter or timerStop < workspace.DistributedGameTime
            isUnderground = true
            task.wait()
            LocalRoot.Velocity = Vector3.zero
            LocalHead.Anchored = false
            LocalRoot.CFrame = oldCFrame
            RunService.Heartbeat:Wait()
            LocalRoot.Velocity = Vector3.zero
        until isHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"), oldCFrame.Position) or tries >= 3
        if tries >= 3 then
            isUnderground = false
            workspace:SetAttribute("Invincible", nil)
            flags.Invincible = false
            StarterGui:SetCore("SendNotification", {
                Title = "Fail",
                Text = "Failed to become invincible.",
                Duration = 4.5
            })
        end
    else
        isUnderground = false
        if LocalHumanoid then LocalHumanoid.CameraOffset = Vector3.new(0, 0, 0) end
    end
end

local function applyDisableKillerWalls(state)
    local val = state
    local vertexColor = val and Vector3.new(0, 255, 0) or Vector3.new(255, 0, 0)
    local color = val and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    local killerDoorsFolder = GameMap and (GameMap:FindFirstChild("KillerDoors", true) or GameMap:FindFirstChild("Killer Doors", true))
    local killerCollisions = GameMap and GameMap:FindFirstChild("KillerOnly", true)
    if killerDoorsFolder then
        for _, v in ipairs(killerDoorsFolder:GetChildren()) do
            v.Color = color
            if v:GetAttribute("OriginalCanCollide") == nil then
                v:SetAttribute("OriginalCanCollide", v.CanCollide)
            end
            v.CanCollide = v:GetAttribute("OriginalCanCollide") ~= false and not val or false
            if killerCollisions then
                local params = OverlapParams.new()
                params.FilterType = Enum.RaycastFilterType.Include
                params.CollisionGroup = "Killers"
                params.FilterDescendantsInstances = {killerCollisions}
                local hitboxes = workspace:GetPartBoundsInRadius(v.Position, 10, params)
                for _, h in ipairs(hitboxes) do
                    h.CanCollide = not val
                end
            end
            if v:FindFirstChildOfClass("SpecialMesh") then
                v:FindFirstChildOfClass("SpecialMesh").VertexColor = vertexColor
            end
        end
    end
end

local function applyToxicTrails(val)
    if not InGame then return end
    for _, v in ipairs(InGame:GetChildren()) do
        if v:IsA("Folder") and v.Name:find("JohnDoeTrail") then
            for _, v2 in ipairs(v:GetChildren()) do
                if v2:IsA("BasePart") then
                    v2.CanTouch = not val
                end
            end
        end
    end
end

local function applyFootprints(val)
    if not InGame then return end
    for _, v in ipairs(InGame:GetChildren()) do
        if v:IsA("Folder") and v.Name:find("Shadows") then
            for _, v2 in ipairs(v:GetChildren()) do
                if v2:IsA("BasePart") then
                    v2.CanTouch = not val
                end
            end
        end
    end
end

local function applySpikes(val)
    if not InGame then return end
    for _, v in ipairs(InGame:GetChildren()) do
        if v.Name == "SpikeCollision" then
            v.Size = val and Vector3.new(11, 3.5, 3.5) or Vector3.new(11, 5, 5)
            v.Shape = val and Enum.PartType.Cylinder or Enum.PartType.Block
        end
    end
end

local function checkSlowness(child)
    if flags.AntiSlowness and child and child.Name ~= "Sprinting" then
        if child.Name == "DirectionalMovement" or child.Name == "FixingGenerator" or child.Name:upper() == "ENRAGED" then
            if child.Value < 1 then
                child.Value = 1
            end
        elseif child.Value > 0.05 and child.Value < 1 then
            child:Destroy()
        else
            child:GetPropertyChangedSignal("Value"):Connect(function()
                if child.Value > 0.05 and child.Value < 1 then
                    child:Destroy()
                end
            end)
        end
    end
end

local blockableAttacks = {"slash", "stab", "attack", "punch", "behead", "swing", "tosow", "sow"}
local selfParams = OverlapParams.new()
selfParams.MaxParts = 1
selfParams.FilterType = Enum.RaycastFilterType.Include

local function setupKillerAutoBlock(killer)
    local hum = killer:FindFirstChildOfClass("Humanoid")
    local queryHitbox = killer:FindFirstChild("QueryHitbox")
    if not hum or not queryHitbox then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if flags.AutoBlock and Players:GetPlayerFromCharacter(killer) then
                local animType, killerName = getAnimationType(track.Animation.AnimationId)
                if animType and type(animType) == "string" and table.find(blockableAttacks, animType:lower()) then
                    if LocalCharacter and LocalCharacter:FindFirstChild("QueryHitbox") and LocalCharacter.Parent == SurvivorsFolder then
                        if MainUI:FindFirstChild("AbilityContainer") and MainUI.AbilityContainer:FindFirstChild("Block") then
                            for i = 1, 12 do
                                selfParams.FilterDescendantsInstances = {LocalCharacter:FindFirstChild("QueryHitbox")}
                                local detect = Instance.new("Part")
                                detect.Size = Vector3.new(5.2, 6, 5.5) * 2.2
                                detect.CFrame = queryHitbox.CFrame * CFrame.new(0, 0, -3.25)
                                detect.CanCollide = false
                                detect.Anchored = true
                                detect.Parent = Hitboxes
                                Debris:AddItem(detect, 0.4)
                                local hit = workspace:GetPartsInPart(detect, selfParams)
                                if #hit > 0 then
                                    if firesignal then
                                        firesignal(MainUI.AbilityContainer.Block.MouseButton1Click)
                                    else
                                        local actorRemote = Network:FindFirstChildOfClass("RemoteEvent")
                                        if actorRemote then
                                            actorRemote:FireServer("UseActorAbility", {"Block"})
                                        end
                                    end
                                    break
                                end
                                task.wait(0.02)
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Network hook desync setup
local Network = ReplicatedStorage:FindFirstChild("Modules") and (ReplicatedStorage.Modules:FindFirstChild("Network", true) and ReplicatedStorage.Modules:FindFirstChild("Network", true):FindFirstChild("Network")) or ReplicatedStorage.Modules:FindFirstChild("Network", true)
local hookmetamethod = hookmetamethod or hook_metamethod
if hookmetamethod and Network then
    local unreliableEvent = Network:WaitForChild("UnreliableRemoteEvent")
    local dummy = function(x) return x end
    local newcclosure = newcclosure or dummy
    local checkcaller = checkcaller or dummy
    local typeEnum = {"invalidnumber"}
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() then
            -- 1. Invincibility Network desync
            if isUnderground and method == "FireServer" and self == unreliableEvent and flags.Invincible then
                local args = {...}
                if args[1] == 1 and args[2] then
                    local desyncNum = 6e9
                    args[4] = table.create(3)
                    local outsideVector = Vector3.new(9999, desyncNum, 9999)
                    task.spawn(function()
                        for index = 1, 2 do
                            if index + 100 > 100 and typeEnum[1] then
                                local closure = buffer.create
                                args[index + 1][#typeEnum] = closure(0)
                                args[index + 3][#typeEnum] = closure(0)
                                break
                            end
                        end
                    end)
                    local success, buggedCFrame = coroutine.resume(coroutine.create(function()
                        return CFrame.fromMatrix(outsideVector, Vector3.zero, Vector3.one, Vector3.new(1, 0, 1)):Orthonormalize()
                    end))
                    args[4][1] = outsideVector.Unit
                    args[4][2] = utf8.offset(tostring(buffer.fromstring(tostring(success) .. tostring(buggedCFrame.LookVector.Unit))), 2, -1)
                    return oldNamecall(self, table.unpack(args))
                end
            end
            
            -- 2. Animation Changer
            if (method == "LoadAnimation" or method == "loadAnimation") and flags.AnimationChanger ~= "Original" then
                local inLobby = GameMap == nil
                if flags.ChangeInLobby or not inLobby then
                    local args = {...}
                    local anim = args[1]
                    if anim and anim:IsA("Animation") then
                        local animType = getAnimationType(anim.AnimationId)
                        if animType then
                            local animSet = allAnimations[flags.AnimationChanger]
                            if animSet then
                                local overrideId = animSet[animType]
                                if overrideId then
                                    if type(overrideId) == "table" then overrideId = overrideId[1] end
                                    local newAnim = Instance.new("Animation")
                                    newAnim.AnimationId = "rbxassetid://" .. tostring(getNumericId(overrideId))
                                    return oldNamecall(self, newAnim)
                                end
                            end
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end))
end

-- Core loading sequence for game modules & animations
task.spawn(function()
    local ok, res = pcall(function()
        return require(LocalPlayer:FindFirstChildOfClass("PlayerScripts"):FindFirstChild("PlayerModule"))
    end)
    local getgc = getgc or get_gc
    if getgc then
        local success, result = pcall(function()
            local sprintMod = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
            return require(sprintMod)
        end)
        if success and type(result) == "table" then
            IsRequireSupported = true
            MainModule = result
        else
            for _, obj in ipairs(getgc(true)) do
                if type(obj) == "table" and rawget(obj, "Stamina") and rawget(obj, "StaminaChanged") then
                    IsRequireSupported = true
                    MainModule = obj
                    break
                end
            end
        end
    end
    
    -- Load character animations
    local configList = {}
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if assets then
        local skins = assets:FindFirstChild("Skins")
        local surv = assets:FindFirstChild("Survivors")
        local killers = assets:FindFirstChild("Killers")
        if skins then for _, v in ipairs(skins:GetDescendants()) do if v.Name == "Config" and v:IsA("ModuleScript") then table.insert(configList, v) end end end
        if surv then for _, v in ipairs(surv:GetDescendants()) do if v.Name == "Config" and v:IsA("ModuleScript") then table.insert(configList, v) end end end
        if killers then for _, v in ipairs(killers:GetDescendants()) do if v.Name == "Config" and v:IsA("ModuleScript") then table.insert(configList, v) end end end
    end
    
    for _, mod in ipairs(configList) do
        pcall(function()
            local cfg = require(mod)
            if cfg and cfg.Animations then
                if mod.Parent.Name == "Noli" then NoliConfig = cfg end
                if mod.Parent.Name == "TwoTime" then
                    allAnimations["Crouch"] = {
                        ["Idle"] = cfg.Animations["CrouchIdle"],
                        ["Walk"] = cfg.Animations["CrouchWalk"],
                        ["Run"] = cfg.Animations["CrouchRun"]
                    }
                end
                if cfg.DisplayName then
                    allAnimations[cfg.DisplayName] = cfg.Animations
                end
            end
        end)
    end
end)

-- Highlight / Text ESP rendering helpers
local function drawHighlight(instance, color)
    local highlight = instance:FindFirstChild("IndraHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "IndraHighlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = instance
    end
    highlight.FillColor = color
    highlight.OutlineColor = color
end

local function removeHighlight(instance)
    local highlight = instance:FindFirstChild("IndraHighlight")
    if highlight then highlight:Destroy() end
end

local function drawText(instance, text, color)
    local billboard = instance:FindFirstChild("IndraBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "IndraBillboard"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextStrokeTransparency = 0.5
        label.Parent = billboard
        billboard.Parent = instance
    end
    billboard.TextLabel.Text = text
    billboard.TextLabel.TextColor3 = color
end

local function removeText(instance)
    local billboard = instance:FindFirstChild("IndraBillboard")
    if billboard then billboard:Destroy() end
end

local espCache = {}

local function createESP(player)
    if player == LocalPlayer or espCache[player] then return end
    
    local ok, esp = pcall(function()
        return {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Dist = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }
    end)
    if not ok then return end
    
    esp.Box.Filled = false
    esp.Box.Thickness = 1
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Size = 14
    esp.Name.Font = 2
    
    esp.Dist.Center = true
    esp.Dist.Outline = true
    esp.Dist.Size = 12
    esp.Dist.Font = 2
    
    esp.Tracer.Thickness = 1
    
    espCache[player] = esp
end

local function removeESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            pcall(function() obj.Visible = false; obj:Remove() end)
        end
        espCache[player] = nil
    end
end

local function hideESP(esp)
    for _, obj in pairs(esp) do
        pcall(function() obj.Visible = false end)
    end
end

local function updateESPRendering()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewportSize = cam.ViewportSize
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char.HumanoidRootPart
            if hum.Health > 0 then
                local dist3D = (hrp.Position - cam.CFrame.Position).Magnitude
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                
                local isKiller = char.Parent == KillersFolder
                local isSurvivor = char.Parent == SurvivorsFolder
                
                local isESPEnabled = (isKiller and flags.KillersESP) or (isSurvivor and flags.SurvivorsESP)
                local espColor = isKiller and colorMap[flags.KillersColor] or colorMap[flags.SurvivorsColor]
                
                if flags.ESPMaster and isESPEnabled and dist3D <= flags.ESPMaxDistance and espCache[p] then
                    local esp = espCache[p]
                    if onScreen then
                        local head = char:FindFirstChild("Head")
                        local headPos = head and cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                        local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height * 0.6
                        
                        -- Box
                        if flags.ESPBoxes then
                            esp.Box.Size = Vector2.new(width, height)
                            esp.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                            esp.Box.Color = espColor
                            esp.Box.Visible = true
                            
                            esp.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                            esp.BoxOutline.Position = Vector2.new(pos.X - width/2 - 1, headPos.Y - 1)
                            esp.BoxOutline.Visible = true
                        else
                            esp.Box.Visible = false
                            esp.BoxOutline.Visible = false
                        end
                        
                        -- Name & Role
                        if flags.ESPNames then
                            esp.Name.Position = Vector2.new(pos.X, headPos.Y - 18)
                            esp.Name.Text = "[" .. (isKiller and "Killer" or "Survivor") .. "] " .. p.Name
                            esp.Name.Color = espColor
                            esp.Name.Visible = true
                        else
                            esp.Name.Visible = false
                        end
                        
                        -- Distance
                        if flags.ESPDistance then
                            esp.Dist.Position = Vector2.new(pos.X, legPos.Y + 4)
                            esp.Dist.Text = math.floor(dist3D) .. " studs"
                            esp.Dist.Color = Color3.fromRGB(200, 200, 200)
                            esp.Dist.Visible = true
                        else
                            esp.Dist.Visible = false
                        end
                        
                        -- Tracers
                        if flags.ESPTracers then
                            esp.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                            esp.Tracer.To = Vector2.new(pos.X, legPos.Y)
                            esp.Tracer.Color = espColor
                            esp.Tracer.Visible = true
                        else
                            esp.Tracer.Visible = false
                        end
                    else
                        hideESP(espCache[p])
                    end
                elseif espCache[p] then
                    hideESP(espCache[p])
                end
            elseif espCache[p] then
                hideESP(espCache[p])
            end
        elseif espCache[p] then
            hideESP(espCache[p])
        end
    end
end

-- Initialize WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Forsaken",
    Icon = "rbxassetid://10747382750",
    Author = "IndraHub",
    Folder = "IndraHub_Forsaken",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    Home = Window:Tab({ Title = "Home", Icon = "home" }),
    Automation = Window:Tab({ Title = "Automation", Icon = "play" }),
    Features = Window:Tab({ Title = "Features", Icon = "shield" }),
    Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "layout-grid" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

-- Home Tab Setup
Tabs.Home:Section({ Title = "INDRAHUB | FORSAKEN" })
Tabs.Home:Paragraph({ Title = "Welcome to IndraHub", Desc = "Refactored with WindUI, custom heartbeat security, and optimized for smooth performance." })
Tabs.Home:Paragraph({ Title = "Bypass Advisory", Desc = "Use Invincibility/Invisibility with caution. Keep WalkSpeed at moderate levels to avoid server flag triggers." })

-- Automation Tab Setup
Tabs.Automation:Section({ Title = "Auto Farming" })
Tabs.Automation:Toggle({ Title = "Auto Generator Puzzle", Default = false, Callback = function(v) flags.AutoGeneratorPuzzle = v end })
Tabs.Automation:Slider({ Title = "Completion Cooldown (sec)", Value = { Min = 1.5, Max = 8, Default = 1.5, Step = 0.25 }, Callback = function(v) flags.GeneratorCooldown = v end })
Tabs.Automation:Toggle({ Title = "Speed Up When Alone", Default = false, Callback = function(v) flags.SpeedUpCooldown = v end })
Tabs.Automation:Toggle({ Title = "Auto Pickup Items", Default = false, Callback = function(v) flags.AutoPickup = v end })

-- Features Tab Setup
Tabs.Features:Section({ Title = "Player Modifications" })
Tabs.Features:Toggle({ Title = "Invincible / Invisible", Default = false, Callback = function(v) flags.Invincible = v; goUnderground(v) end })
Tabs.Features:Toggle({ Title = "Disable Killer Walls", Default = false, Callback = function(v) flags.DisableKillerWalls = v; pcall(applyDisableKillerWalls, v) end })
Tabs.Features:Toggle({ Title = "Disable Toxic Trails", Default = false, Callback = function(v) flags.DisableToxicTrails = v; pcall(applyToxicTrails, v) end })
Tabs.Features:Toggle({ Title = "Disable Footprints", Default = false, Callback = function(v) flags.DisableFootprints = v; pcall(applyFootprints, v) end })
Tabs.Features:Toggle({ Title = "Smaller Spike Collisions", Default = false, Callback = function(v) flags.SmallerSpikeCollisions = v; pcall(applySpikes, v) end })
Tabs.Features:Toggle({ Title = "Enable Jumping", Default = false, Callback = function(v) flags.EnableJumping = v; pcall(HandleAllowJumping, v) end })
Tabs.Features:Toggle({ Title = "Guest1337 Auto Block", Default = false, Callback = function(v) flags.AutoBlock = v end })
Tabs.Features:Toggle({ Title = "Make Coolkidd Dash Controllable", Default = false, Callback = function(v) flags.ControllableDash = v end })
Tabs.Features:Toggle({ Title = "Better Void Rush Turn", Default = false, Callback = function(v) flags.NoliControl = v end })
Tabs.Features:Dropdown({ Title = "Stamina Mode", Values = { "Original", "Realistic", "Semi-Realistic", "Infinite" }, Default = 1, Callback = function(v) flags.StaminaPreset = singleDropdownValue(v) or flags.StaminaPreset end })
Tabs.Features:Toggle({ Title = "Anti Slowness", Default = false, Callback = function(v) flags.AntiSlowness = v end })
Tabs.Features:Dropdown({ Title = "Animation Override", Values = { "Original", "Jason", "Slasher", "c00lkidd", "John Doe", "Noli", "Crouch" }, Default = 1, Callback = function(v) flags.AnimationChanger = singleDropdownValue(v) or flags.AnimationChanger end })
Tabs.Features:Toggle({ Title = "Change Animations In Lobby", Default = false, Callback = function(v) flags.ChangeInLobby = v end })

-- Visuals Tab Setup
Tabs.Visuals:Section({ Title = "ESP Controls" })
Tabs.Visuals:Toggle({ Title = "Master ESP Enable", Default = false, Callback = function(v) flags.ESPMaster = v end })
Tabs.Visuals:Slider({ Title = "Max Render Distance", Value = { Min = 100, Max = 5000, Default = 3000 }, Callback = function(v) flags.ESPMaxDistance = v end })
Tabs.Visuals:Toggle({ Title = "Show Boxes", Default = false, Callback = function(v) flags.ESPBoxes = v end })
Tabs.Visuals:Toggle({ Title = "Show Names & Roles", Default = false, Callback = function(v) flags.ESPNames = v end })
Tabs.Visuals:Toggle({ Title = "Show Distance", Default = false, Callback = function(v) flags.ESPDistance = v end })
Tabs.Visuals:Toggle({ Title = "Show Tracers", Default = false, Callback = function(v) flags.ESPTracers = v end })

Tabs.Visuals:Section({ Title = "Category Settings" })
Tabs.Visuals:Toggle({ Title = "Killers ESP", Default = false, Callback = function(v) flags.KillersESP = v end })
Tabs.Visuals:Dropdown({ Title = "Killers Color", Values = { "Red", "Orange", "Purple", "Gold" }, Default = 1, Callback = function(v) flags.KillersColor = singleDropdownValue(v) or flags.KillersColor end })
Tabs.Visuals:Toggle({ Title = "Survivors ESP", Default = false, Callback = function(v) flags.SurvivorsESP = v end })
Tabs.Visuals:Dropdown({ Title = "Survivors Color", Values = { "Green", "Orange", "Purple", "Gold" }, Default = 1, Callback = function(v) flags.SurvivorsColor = singleDropdownValue(v) or flags.SurvivorsColor end })
Tabs.Visuals:Toggle({ Title = "Generators ESP", Default = false, Callback = function(v) flags.GeneratorsESP = v end })
Tabs.Visuals:Dropdown({ Title = "Generators Color", Values = { "Cyan", "Blue", "Green", "White" }, Default = 1, Callback = function(v) flags.GeneratorsColor = singleDropdownValue(v) or flags.GeneratorsColor end })
Tabs.Visuals:Toggle({ Title = "Hide Completed Generators", Default = true, Callback = function(v) flags.GeneratorsCheck = v end })
Tabs.Visuals:Toggle({ Title = "Items ESP", Default = false, Callback = function(v) flags.ItemsESP = v end })
Tabs.Visuals:Dropdown({ Title = "Items Color", Values = { "Gold", "Cyan", "Purple", "White" }, Default = 1, Callback = function(v) flags.ItemsColor = singleDropdownValue(v) or flags.ItemsColor end })
Tabs.Visuals:Toggle({ Title = "Disable Noli NPC Distractions", Default = false, Callback = function(v) flags.DisableNoliNPC = v; pcall(HandleNoliNPC, v) end })
Tabs.Visuals:Toggle({ Title = "Disable 007n7 NPC Distractions", Default = false, Callback = function(v) flags.Disable007n7NPC = v; pcall(Handle007n7NPC, v) end })

-- Misc Tab Setup
Tabs.Misc:Section({ Title = "Client Adjustments" })
Tabs.Misc:Slider({ Title = "Extended Field of View", Value = { Min = 10, Max = 120, Default = 70 }, Callback = function(v) flags.ExtendedFOV = v end })
Tabs.Misc:Slider({ Title = "Camera Zoom Distance", Value = { Min = 0, Max = 100, Default = 10 }, Callback = function(v) flags.ExtendedZoom = v end })
Tabs.Misc:Toggle({ Title = "Show System Chat", Default = false, Callback = function(v) flags.ShowChat = v end })
Tabs.Misc:Toggle({ Title = "Show Privacy Information", Default = false, Callback = function(v) flags.ShowPrivacy = v end })
Tabs.Misc:Toggle({ Title = "Hide Injured Screen UI/Effects", Default = true, Callback = function(v) flags.HideInjury = v end })
Tabs.Misc:Toggle({ Title = "Delete All Ragdolls (Host Only)", Default = false, Callback = function(v) flags.DeleteRagdolls = v end })

Tabs.Misc:Section({ Title = "Moderator Alerts" })
Tabs.Misc:Paragraph({ Title = "Mod Detector Active", Desc = "Script will auto-disable all features if a moderator is found." })

Tabs.Misc:Section({ Title = "Server Actions" })
Tabs.Misc:Dropdown({ Title = "Crash Target Player", Values = { "None", "Everyone" }, Default = 1, Callback = function(v) flags.PlayerSelectCrash = singleDropdownValue(v) or flags.PlayerSelectCrash end })
Tabs.Misc:Button({ Title = "Execute Crash", Callback = function() pcall(executeCrash) end })
Tabs.Misc:Toggle({ Title = "Sky Glitch Effects (Host Only)", Default = false, Callback = function(v) flags.SkyGlitch = v end })
Tabs.Misc:Toggle({ Title = "Instant Kill Boost (Host Only)", Default = false, Callback = function(v) flags.InstaKill = v end })
Tabs.Misc:Button({ Title = "Join Official Server", Callback = function() pcall(joinOfficial) end })
Tabs.Misc:Button({ Title = "Rejoin Server Instance", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })

-- Settings Tab Setup
local connections = {}

Tabs.Settings:Section({ Title = "Unload Script" })
Tabs.Settings:Button({
    Title = "Complete Unload",
    Callback = function()
        shared.IndraHub_Forsaken_Unloaded = true
        setGlobal("IndraHubForsakenRunning", false)
        setGlobal("IndraHubForsakenLastHeartbeat", os.clock())
        if getGlobal("IndraHubForsakenSession") == sessionKey then
            setGlobal("IndraHubForsakenSession", nil)
        end
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, esp in pairs(espCache) do
            for _, obj in pairs(esp) do
                pcall(function() obj:Remove() end)
            end
        end
        if Window then Window:Destroy() end
    end
})

-- Implement helper logic & background loops
function HandleAllowJumping(val)
    if LocalHumanoid then
        LocalHumanoid.JumpPower = val and 47 or 0
    end
end

function HandleNoliNPC(val)
    if val then
        for _, v in ipairs(KillersFolder:GetChildren()) do
            if v.Name:lower() == "noli" and not Players:GetPlayerFromCharacter(v) then
                v.Parent = Lighting
                v:PivotTo(v:GetPivot() * CFrame.new(0, -100, 0))
            end
        end
    else
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.Name:lower() == "noli" then
                v.Parent = InGame
                v:PivotTo(v:GetPivot() * CFrame.new(0, 100, 0))
            end
        end
    end
end

function Handle007n7NPC(val)
    if val then
        for _, v in ipairs(InGame:GetChildren()) do
            if v.Name:lower() == "007n7" and not Players:GetPlayerFromCharacter(v) then
                v.Parent = Lighting
            end
        end
    else
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.Name:lower() == "007n7" then
                v.Parent = InGame
            end
        end
    end
end

function executeCrash()
    if flags.PlayerSelectCrash == "None" then return end
    local actorRemote = Network:WaitForChild("RemoteEvent")
    if flags.PlayerSelectCrash == "Everyone" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                task.spawn(function()
                    repeat
                        actorRemote:FireServer("ExecuteCommand", {"GiveStatus", p.Name, "Nausea", math.huge, 1})
                        task.wait(1.5)
                    until not Players:FindFirstChild(p.Name)
                end)
            end
        end
    else
        task.spawn(function()
            repeat
                actorRemote:FireServer("ExecuteCommand", {"GiveStatus", flags.PlayerSelectCrash, "Nausea", math.huge, 1})
                task.wait(1.5)
            until not Players:FindFirstChild(flags.PlayerSelectCrash)
        end)
    end
end

function joinOfficial()
    TeleportService:Teleport(83645629621104, LocalPlayer)
end

-- Map change and folder listener
local mapAddedConn = InGame.ChildAdded:Connect(function(child)
    if child.Name == "Map" then
        GameMap = child
        task.wait(0.5)
        applyDisableKillerWalls(flags.DisableKillerWalls)
    end
end)
table.insert(connections, mapAddedConn)

-- Character Action setup
local function setupCharacter(char)
    LocalCharacter = char
    LocalHumanoid = char:WaitForChild("Humanoid", 10)
    LocalHead = char:WaitForChild("Head", 10)
    LocalRoot = char:WaitForChild("HumanoidRootPart", 10)
    SpeedMultipliers = char:WaitForChild("SpeedMultipliers", 10)
    
    if SpeedMultipliers then
        local childConn = SpeedMultipliers.ChildAdded:Connect(function(child)
            if child:IsA("NumberValue") and child.Name ~= "Sprinting" then
                checkSlowness(child)
            end
        end)
        table.insert(connections, childConn)
        for _, child in ipairs(SpeedMultipliers:GetChildren()) do
            checkSlowness(child)
        end
    end
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(setupCharacter)
table.insert(connections, charAddedConn)
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

-- Background loops
task.spawn(function()
    while getGlobal("IndraHubForsakenRunning") == true do
        task.wait(1)
        if not GameMap then continue end
        
        -- Generators highlight & billboard
        for _, v in ipairs(GameMap:GetDescendants()) do
            if v.Name == "Generator" and v:IsA("Model") then
                local main = v:FindFirstChild("Main")
                local progress = v:FindFirstChild("Progress")
                if main and progress then
                    local isCompleted = progress.Value >= 100
                    local shouldShow = flags.ESPMaster and flags.GeneratorsESP and (not isCompleted or not flags.GeneratorsCheck)
                    if shouldShow then
                        local col = colorMap[flags.GeneratorsColor]
                        drawHighlight(v, col)
                        drawText(v, "Generator [" .. math.floor(progress.Value) .. "%]", col)
                    else
                        removeHighlight(v)
                        removeText(v)
                    end
                end
            end
        end

        -- Items highlight & billboard
        if InGame then
            for _, v in ipairs(InGame:GetDescendants()) do
                if v:IsA("Tool") then
                    local shouldShow = flags.ESPMaster and flags.ItemsESP
                    if shouldShow then
                        local col = colorMap[flags.ItemsColor]
                        drawHighlight(v, col)
                        drawText(v, v.Name, col)
                    else
                        removeHighlight(v)
                        removeText(v)
                    end
                end
            end
        end
    end
end)

-- Main rendering loop
local renderConn = RunService.RenderStepped:Connect(function()
    if shared.IndraHub_Forsaken_Unloaded then return end
    
    pcall(updateESPRendering)
    
    -- Extended Zoom & FOV
    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = flags.ExtendedFOV
        end
        LocalPlayer.CameraMaxZoomDistance = flags.ExtendedZoom
    end)
    
    -- Stamina / Speed modifications
    pcall(function()
        if flags.StaminaPreset ~= "Original" and MainModule and MainModule.MaxStamina then
            if flags.StaminaPreset == "Infinite" then
                rawset(MainModule, "Stamina", MainModule.MaxStamina)
            else
                local MaxStamina = MainModule.MaxStamina
                if MainModule.Stamina < MaxStamina * 0.8 then
                    rawset(MainModule, "Stamina", math.min(MainModule.Stamina + MaxStamina * (flags.StaminaPreset == "Semi-Realistic" and 0.005 or 0.0025), MaxStamina))
                end
            end
        end
    end)
end)
table.insert(connections, renderConn)

-- ESP Players setup
local playerAddedConn = Players.PlayerAdded:Connect(createESP)
table.insert(connections, playerAddedConn)
local playerRemovingConn = Players.PlayerRemoving:Connect(removeESP)
table.insert(connections, playerRemovingConn)
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end

-- Anti AFK
local idledConn = LocalPlayer.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)
table.insert(connections, idledConn)

-- Initialize Moderator detector
task.spawn(function()
    while getGlobal("IndraHubForsakenRunning") == true do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local rank = p:GetRoleInGroupAsync(33548380)
                if rank and rank:lower():find("mod") then
                    -- Shutdown exploit for security
                    flags.ESPMaster = false
                    flags.AutoGeneratorPuzzle = false
                    flags.Invincible = false
                    goUnderground(false)
                    StarterGui:SetCore("SendNotification", {
                        Title = "MODERATOR ALERT",
                        Text = "Moderator found: " .. p.Name .. ". Exploit functions disabled.",
                        Duration = 10
                    })
                end
            end
        end
        task.wait(10)
    end
end)

-- Kickoff character listener
if KillersFolder then
    for _, k in ipairs(KillersFolder:GetChildren()) do setupKillerAutoBlock(k) end
    local killerConn = KillersFolder.ChildAdded:Connect(setupKillerAutoBlock)
    table.insert(connections, killerConn)
end

WindUI:Notify({ Title = "IndraHub", Content = "Forsaken Script Loaded Successfully", Duration = 5 })
