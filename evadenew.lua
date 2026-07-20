--[[
    IndraHub | Evade
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local SCRIPT_ID = tostring(math.random()) .. "_" .. tostring(os.clock())
local STATE_KEY = "IndraHubEvadeState"

local espObjects = {}

local function removeEsp(target)
    local objects = espObjects[target]
    if not objects then return end
    pcall(function() objects.Highlight:Destroy() end)
    pcall(function() objects.Billboard:Destroy() end)
    pcall(function() if objects.Tracer then objects.Tracer:Remove() end end)
    pcall(function() if objects.SelectionBox then objects.SelectionBox:Destroy() end end)
    espObjects[target] = nil
end

local function cleanAllEsp()
    for target in pairs(espObjects) do
        removeEsp(target)
    end
end

-- Cleanup previous instance
local previousState = _G[STATE_KEY]
if previousState then
    previousState.stopThreads = true
    pcall(function() if previousState.tpCamConn then previousState.tpCamConn:Disconnect() previousState.tpCamConn = nil end end)
    pcall(function() if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end end)
    pcall(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 humanoid.JumpPower = 50 humanoid.JumpHeight = 7.2 end
    end)
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end)
    pcall(function() if previousState.radarLabel then previousState.radarLabel:Destroy() previousState.radarLabel = nil end end)
    pcall(function() if previousState.cleanAllEsp then previousState.cleanAllEsp() end end)
end

local state = {
    stopThreads = false,
    ScriptInstanceId = SCRIPT_ID,
    cleanAllEsp = cleanAllEsp,
    tpCamConn = nil,
    radarLabel = nil,
}
_G[STATE_KEY] = state

getgenv().IndraConfig = {
    SpeedHack = false,
    SpeedValue = 40,
    JumpHack = false,
    JumpValue = 65,
    InfiniteJump = false,
    Noclip = false,
    ThirdPerson = false,
    AutoRevive = false,
    AutoReviveTeleport = false,
    AutoReviveReturn = false,
    FreezeNextbots = false,
    AutoCollect = false,
    EspNextbots = false,
    EspPlayers = false,
    EspDowned = false,
    NextbotRadar = false,
}

local Config = getgenv().IndraConfig

-- UI INITIALIZATION (WINDUI)
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI then
    warn("Failed to load WindUI")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Evade",
    Icon = "shield",
    Author = "IndraHub",
    Folder = "IndraHub_Evade",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

local MainTab = Window:Tab({ Title = "Main", Icon = "user" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "shield" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

-- Main Tab
MainTab:Toggle({
    Title = "Speed Hack",
    Default = Config.SpeedHack,
    Callback = function(val) 
        Config.SpeedHack = val 
        if not val then
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end)
        end
    end
})

MainTab:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 150,
    Default = 40,
    Callback = function(val) Config.SpeedValue = val end
})

MainTab:Toggle({
    Title = "Jump Hack",
    Default = Config.JumpHack,
    Callback = function(val) 
        Config.JumpHack = val 
        if not val then
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.JumpPower = 50 humanoid.JumpHeight = 7.2 end
            end)
        end
    end
})

MainTab:Slider({
    Title = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 65,
    Callback = function(val) Config.JumpValue = val end
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Default = Config.InfiniteJump,
    Callback = function(val) Config.InfiniteJump = val end
})

MainTab:Toggle({
    Title = "Noclip",
    Default = Config.Noclip,
    Callback = function(val) 
        Config.Noclip = val 
        if not val then
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end)
        end
    end
})

local cameraYaw = 0
local cameraPitch = 15
local cameraDistance = 12

local function stopThirdPerson()
    Config.ThirdPerson = false
    if state.tpCamConn then
        state.tpCamConn:Disconnect()
        state.tpCamConn = nil
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

MainTab:Toggle({
    Title = "Third Person View",
    Default = Config.ThirdPerson,
    Callback = function(val) 
        Config.ThirdPerson = val 
        if not val then
            stopThirdPerson()
            return
        end

        if state.tpCamConn then
            state.tpCamConn:Disconnect()
            state.tpCamConn = nil
        end

        pcall(function()
            local character = LocalPlayer.Character
            local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
            if root then
                local look = root.CFrame.LookVector
                cameraYaw = math.deg(math.atan2(-look.X, -look.Z))
            end
        end)

        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        state.tpCamConn = RunService.RenderStepped:Connect(function()
            if state.ScriptInstanceId ~= SCRIPT_ID or not Config.ThirdPerson then
                stopThirdPerson()
                return
            end

            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local delta = UserInputService:GetMouseDelta()
                cameraYaw -= delta.X * 0.4
                cameraPitch = math.clamp(cameraPitch + delta.Y * 0.4, -15, 60)
            end

            pcall(function()
                local character = LocalPlayer.Character
                local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                if not root then return end

                local target = root.Position + Vector3.new(0, 2, 0)
                local yaw = math.rad(cameraYaw)
                local pitch = math.rad(cameraPitch)
                local offset = Vector3.new(
                    math.sin(yaw) * math.cos(pitch) * cameraDistance,
                    math.sin(pitch) * cameraDistance,
                    math.cos(yaw) * math.cos(pitch) * cameraDistance
                )
                workspace.CurrentCamera.CFrame = CFrame.lookAt(root.Position + offset + Vector3.new(0, 2, 0), target)
            end)
        end)
    end
})

MainTab:Toggle({
    Title = "Auto Revive",
    Default = Config.AutoRevive,
    Callback = function(val) Config.AutoRevive = val end
})

MainTab:Toggle({
    Title = "Teleport to Downed Player",
    Default = Config.AutoReviveTeleport,
    Callback = function(val) Config.AutoReviveTeleport = val end
})

MainTab:Toggle({
    Title = "Return to Original Position",
    Default = Config.AutoReviveReturn,
    Callback = function(val) Config.AutoReviveReturn = val end
})

-- Combat Tab
CombatTab:Toggle({
    Title = "Freeze Nextbots",
    Default = Config.FreezeNextbots,
    Callback = function(val) Config.FreezeNextbots = val end
})

CombatTab:Toggle({
    Title = "Auto Collect Items",
    Default = Config.AutoCollect,
    Callback = function(val) Config.AutoCollect = val end
})

CombatTab:Button({
    Title = "Whistle (Alert Nearby)",
    Callback = function()
        pcall(function() ReplicatedStorage.Events.Game.Whistle:FireServer() end)
    end
})

-- ESP Tab
ESPTab:Toggle({
    Title = "ESP Nextbots",
    Default = Config.EspNextbots,
    Callback = function(val) 
        Config.EspNextbots = val 
        if not val then cleanAllEsp() end
    end
})

ESPTab:Toggle({
    Title = "ESP Players",
    Default = Config.EspPlayers,
    Callback = function(val) 
        Config.EspPlayers = val 
        if not val then cleanAllEsp() end
    end
})

ESPTab:Toggle({
    Title = "ESP Downed Players",
    Default = Config.EspDowned,
    Callback = function(val) 
        Config.EspDowned = val 
        if not val then cleanAllEsp() end
    end
})

ESPTab:Toggle({
    Title = "Show Nearest Nextbot Info (Radar)",
    Default = Config.NextbotRadar,
    Callback = function(val) Config.NextbotRadar = val end
})

-- Teleport Tab
TeleportTab:Button({
    Title = "Teleport to Safe Spot (Sky)",
    Callback = function()
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            if root then root.Position += Vector3.new(0, 500, 0) end
        end)
    end
})

TeleportTab:Button({
    Title = "Teleport to Map Center",
    Callback = function()
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            local map = workspace.Game:FindFirstChild("Map")
            local mapPart = map and map:FindFirstChildOfClass("BasePart")
            if root and mapPart then
                root.Position = mapPart.Position + Vector3.new(0, 10, 0)
            end
        end)
    end
})

TeleportTab:Button({
    Title = "Teleport to Random Teammate",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character
            local root = character and character.PrimaryPart
            local playerFolder = workspace.Game:FindFirstChild("Players")
            if not root or not playerFolder then return end

            local teammates = {}
            for _, model in ipairs(playerFolder:GetChildren()) do
                local modelRoot = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                if modelRoot and model.Name ~= character.Name
                    and model:GetAttribute("Team") == "PlayerTeam"
                    and not model:GetAttribute("Downed") then
                    table.insert(teammates, modelRoot)
                end
            end

            if #teammates > 0 then
                local target = teammates[math.random(1, #teammates)]
                root.Position = target.Position + Vector3.new(0, 3, 0)
            end
        end)
    end
})

TeleportTab:Button({
    Title = "Teleport to Nearest Player",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character
            local root = character and character.PrimaryPart
            local playerFolder = workspace.Game:FindFirstChild("Players")
            if not root or not playerFolder then return end

            local nearestRoot
            local nearestDistance = math.huge
            for _, model in ipairs(playerFolder:GetChildren()) do
                local modelRoot = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                if modelRoot and model.Name ~= character.Name then
                    local distance = (modelRoot.Position - root.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestRoot = modelRoot
                    end
                end
            end

            if nearestRoot then
                root.Position = nearestRoot.Position + Vector3.new(0, 3, 0)
            end
        end)
    end
})

-- Info Tab
InfoTab:Button({
    Title = "Join IndraHub Discord",
    Desc = "Get updates and support.",
    Callback = function()
        setclipboard("https://discord.gg/indrahub")
        WindUI:Notify({ Title = "Discord Link Copied!", Duration = 3 })
    end
})

local function isActive()
    return not state.stopThreads and state.ScriptInstanceId == SCRIPT_ID
end

-- LOOPS
task.spawn(function()
    while isActive() do
        task.wait()
        pcall(function()
            local character = LocalPlayer.Character
            local root = character and character.PrimaryPart
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            if Config.SpeedHack then
                humanoid.WalkSpeed = Config.SpeedValue
                if root and humanoid.MoveDirection.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(
                        humanoid.MoveDirection.X * Config.SpeedValue,
                        root.AssemblyLinearVelocity.Y,
                        humanoid.MoveDirection.Z * Config.SpeedValue
                    )
                end
            end
            if Config.JumpHack then
                humanoid.JumpPower = Config.JumpValue
                humanoid.JumpHeight = Config.JumpValue
            end
        end)
    end
end)

local jumpConnection
jumpConnection = UserInputService.JumpRequest:Connect(function()
    if not isActive() then
        jumpConnection:Disconnect()
        return
    end
    if Config.InfiniteJump then
        pcall(function()
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

local noclipConnection
noclipConnection = RunService.Stepped:Connect(function()
    if not isActive() then
        noclipConnection:Disconnect()
        return
    end
    if Config.Noclip then
        pcall(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

local reviveBusy = false
task.spawn(function()
    while isActive() do
        task.wait(0.1)
        if Config.AutoRevive and not reviveBusy then
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and character.PrimaryPart
                local playerFolder = workspace.Game:FindFirstChild("Players")
                if not root or not playerFolder then return end

                for _, model in ipairs(playerFolder:GetChildren()) do
                    if model ~= character and model:GetAttribute("Downed") == true then
                        local targetRoot = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local distance = (targetRoot.Position - root.Position).Magnitude
                            if Config.AutoReviveTeleport then
                                reviveBusy = true
                                task.spawn(function()
                                    local oldPosition = root.Position
                                    root.Position = targetRoot.Position + Vector3.new(0, 2, 0)
                                    task.wait(0.15)
                                    ReplicatedStorage.Events.Game.Interact:FireServer("Revive", nil, model.PrimaryPart)
                                    ReplicatedStorage.Events.Game.Interact:FireServer("Revive", true, model.PrimaryPart)
                                    task.wait(0.15)
                                    if Config.AutoReviveReturn then
                                        root.Position = oldPosition
                                    end
                                    task.wait(0.5)
                                    reviveBusy = false
                                end)
                                break
                            elseif distance <= 8.5 then
                                ReplicatedStorage.Events.Game.Interact:FireServer("Revive", nil, model.PrimaryPart)
                                ReplicatedStorage.Events.Game.Interact:FireServer("Revive", true, model.PrimaryPart)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local function updateEsp(target)
    if not target or not target.Parent then
        removeEsp(target)
        return
    end

    local character = LocalPlayer.Character
    if target == character then
        removeEsp(target)
        return
    end

    local root = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
    if not root then
        removeEsp(target)
        return
    end

    local isNextbot = target:GetAttribute("Team") == "Nextbot" or target:GetAttribute("AI") == true
    local isDowned = target:GetAttribute("Downed") == true
    local isPlayer = target:GetAttribute("Team") == "PlayerTeam" and not isDowned

    local visible = false
    local color = Color3.fromRGB(1, 1, 1)
    local fillTransparency = 1
    local prefix = ""
    local textSize = 13

    if isNextbot then
        visible = Config.EspNextbots
        color = Color3.fromRGB(255, 50, 50)
        textSize = 14
    elseif isDowned then
        visible = Config.EspDowned
        color = Color3.fromRGB(255, 170, 0)
        prefix = "Downed: "
    elseif isPlayer then
        visible = Config.EspPlayers
        color = Color3.fromRGB(50, 255, 50)
    end

    if not visible then
        removeEsp(target)
        return
    end

    local distance = 0
    if character and character.PrimaryPart then
        distance = math.floor((root.Position - character.PrimaryPart.Position).Magnitude)
    end
    local labelText = prefix .. target.Name .. " [" .. tostring(distance) .. "m]"

    local objects = espObjects[target]
    if not objects then
        local highlight = Instance.new("Highlight")
        highlight.Name = "IndraEspHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = color
        highlight.FillTransparency = fillTransparency
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0
        highlight.Adornee = target
        highlight.Parent = target

        local selectionBox
        if isNextbot then
            selectionBox = Instance.new("SelectionBox")
            selectionBox.Name = "IndraEspSelectionBox"
            selectionBox.Color3 = color
            selectionBox.LineThickness = 0.05
            selectionBox.Adornee = target
            selectionBox.Parent = target
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "IndraEspBillboard"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.Adornee = target:FindFirstChild("Head") or root
        billboard.Parent = CoreGui

        local label = Instance.new("TextLabel", billboard)
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = labelText
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = textSize

        local tracer
        pcall(function()
            if isNextbot and typeof(Drawing) == "table" and Drawing.new then
                tracer = Drawing.new("Line")
                tracer.Color = color
                tracer.Thickness = 2
                tracer.Transparency = 1
                tracer.Visible = false
            end
        end)

        espObjects[target] = {
            Highlight = highlight,
            Billboard = billboard,
            Label = label,
            Tracer = tracer,
            SelectionBox = selectionBox,
        }
        return
    end

    if objects.Highlight and objects.Highlight.Parent then
        objects.Highlight.FillColor = color
        objects.Highlight.FillTransparency = fillTransparency
        objects.Highlight.OutlineColor = color
    end
    if objects.Label and objects.Label.Parent then
        objects.Label.Text = labelText
        objects.Label.TextColor3 = color
        objects.Label.TextSize = textSize
    end
    if objects.Tracer then
        local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if onScreen and Config.EspNextbots then
            objects.Tracer.From = Vector2.new(
                workspace.CurrentCamera.ViewportSize.X / 2,
                workspace.CurrentCamera.ViewportSize.Y - 50
            )
            objects.Tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
            objects.Tracer.Visible = true
        else
            objects.Tracer.Visible = false
        end
    end
end

task.spawn(function()
    while isActive() do
        task.wait(0.1)
        pcall(function()
            local seen = {}
            local playerFolder = workspace.Game:FindFirstChild("Players")
            if playerFolder then
                for _, target in ipairs(playerFolder:GetChildren()) do
                    seen[target] = true
                    updateEsp(target)
                end
            end
            for target in pairs(espObjects) do
                if not seen[target] then
                    removeEsp(target)
                end
            end
        end)
    end
    cleanAllEsp()
end)

local frozenPositions = {}
task.spawn(function()
    while isActive() do
        task.wait(0.05)
        pcall(function()
            local playerFolder = workspace.Game:FindFirstChild("Players")
            if not playerFolder then return end

            for _, model in ipairs(playerFolder:GetChildren()) do
                local isNextbot = model:GetAttribute("AI") == true or model:GetAttribute("Team") == "Nextbot"
                if isNextbot then
                    local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                    if root then
                        if Config.FreezeNextbots then
                            frozenPositions[model] = frozenPositions[model] or root.Position
                            root.Position = frozenPositions[model]
                            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        else
                            frozenPositions[model] = nil
                        end
                    end
                end
            end
        end)
    end
    frozenPositions = {}
end)

task.spawn(function()
    while isActive() do
        task.wait(0.5)
        if Config.AutoCollect then
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and character.PrimaryPart
                if not root then return end

                local effects = workspace.Game:FindFirstChild("Effects")
                local tools = effects and effects:FindFirstChild("Tools")
                if tools then
                    for _, item in ipairs(tools:GetChildren()) do
                        local part = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                        if part and (part.Position - root.Position).Magnitude <= 60 then
                            root.Position = part.Position + Vector3.new(0, 3, 0)
                            task.wait(0.15)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

pcall(function()
    local radar = Instance.new("BillboardGui")
    radar.Name = "IndraRadar"
    radar.AlwaysOnTop = true
    radar.Size = UDim2.new(0, 280, 0, 20)
    radar.StudsOffset = Vector3.new(0, 8, 0)
    radar.Parent = CoreGui

    local text = Instance.new("TextLabel", radar)
    text.Name = "Txt"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 15
    text.TextColor3 = Color3.fromRGB(255, 80, 80)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Text = ""

    state.radarLabel = radar

    task.spawn(function()
        while isActive() do
            task.wait(0.1)
            if Config.NextbotRadar then
                radar.Enabled = true
                local playerFolder = workspace.Game:FindFirstChild("Players")
                local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                if playerFolder and root then
                    local nearest, dist = nil, math.huge
                    for _, model in ipairs(playerFolder:GetChildren()) do
                        local isNextbot = model:GetAttribute("AI") == true or model:GetAttribute("Team") == "Nextbot"
                        if isNextbot then
                            local botRoot = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                            if botRoot then
                                local d = (botRoot.Position - root.Position).Magnitude
                                if d < dist then
                                    dist = d
                                    nearest = model
                                end
                            end
                        end
                    end
                    if nearest then
                        text.Text = "Nearest Nextbot: " .. nearest.Name .. " (" .. math.floor(dist) .. "m)"
                    else
                        text.Text = "No Nextbots detected"
                    end
                end
            else
                radar.Enabled = false
            end
        end
    end)
end)

-- SUPERVISOR HEARTBEAT
task.spawn(function()
    while isActive() do
        task.wait(1)
        if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubEvadeLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubEvadeLastHeartbeat"].heartbeat = os.clock()
        end
    end
end)

WindUI:Notify({
    Title = "IndraHub",
    Content = "Evade script loaded successfully!",
    Duration = 5
})
