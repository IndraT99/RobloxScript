local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Settings = {
    XRayEnabled = false,
    ESPEnabled = false,
    SpeedBoost = false,
    SpeedValue = 16,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    FriendlyColor = Color3.fromRGB(0, 255, 0),
    TransparencyValue = 0.5,
    KeybindToggle = Enum.KeyCode.RightShift,
}

local Connections = {}
local ESPObjects = {}
local XRayParts = {}
local IsRunning = true
local env = getgenv and getgenv() or _G

env.IndraHubHideAndSeekRunning = true
env.IndraHubHideAndSeekLastHeartbeat = os.clock()
env.IndraHubHideAndSeekError = nil

task.spawn(function()
    while env.IndraHubHideAndSeekRunning and IsRunning do
        env.IndraHubHideAndSeekLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[HideNSeek] Error: " .. tostring(result))
    end
    return success, result
end

local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("Humanoid")
end

local function GetRootPart(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
    local humanoid = GetHumanoid(player)
    return humanoid and humanoid.Health > 0
end

local function GetDistance(player)
    local myRoot = GetRootPart(LocalPlayer)
    local theirRoot = GetRootPart(player)
    if myRoot and theirRoot then
        return (myRoot.Position - theirRoot.Position).Magnitude
    end
    return math.huge
end

local function SetXRay(enabled)
    Settings.XRayEnabled = enabled

    for _, part in ipairs(XRayParts) do
        pcall(function()
            part.LocalTransparencyModifier = 0
        end)
    end
    table.clear(XRayParts)
    
    if not enabled then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local isPlayerPart = false
            for _, player in ipairs(Players:GetPlayers()) do
                local char = GetCharacter(player)
                if char and obj:IsDescendantOf(char) then
                    isPlayerPart = true
                    break
                end
            end
            
            if not isPlayerPart then
                pcall(function()
                    obj.LocalTransparencyModifier = Settings.TransparencyValue
                    table.insert(XRayParts, obj)
                end)
            end
        end
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
        ESPObjects[player] = nil
    end
    
    if not Settings.ESPEnabled then return end
    
    local character = GetCharacter(player)
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "HNS_ESP"
    highlight.FillColor = Settings.HighlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HNS_Info"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = rootPart
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "PlayerName"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Text = player.Name
        nameLabel.Parent = billboard
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "Distance"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 12
        distLabel.Text = "0m"
        distLabel.Parent = billboard

        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not billboard.Parent or not Settings.ESPEnabled then
                if conn then conn:Disconnect() end
                return
            end
            local dist = math.floor(GetDistance(player))
            distLabel.Text = tostring(dist) .. "m"
        end)
        table.insert(Connections, conn)
    end
    
    ESPObjects[player] = highlight
end

local function RefreshESP()
    for player, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(ESPObjects)
    
    if not Settings.ESPEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        SafeCall(CreateESP, player)
    end
end

local function SetSpeedBoost(enabled)
    Settings.SpeedBoost = enabled
    
    local humanoid = GetHumanoid(LocalPlayer)
    if humanoid then
        if enabled then
            humanoid.WalkSpeed = Settings.SpeedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
end

local function UpdateSpeed(value)
    Settings.SpeedValue = value
    if Settings.SpeedBoost then
        local humanoid = GetHumanoid(LocalPlayer)
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

local function SetupGUI()
    if env.IndraHubHideNSeekWindow then
        pcall(function() env.IndraHubHideNSeekWindow:Destroy() end)
    end

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    local function notify(title, content, icon)
        if WindUI and type(WindUI.Notify) == "function" then
            pcall(function()
                WindUI:Notify({ Title = title, Content = content, Icon = icon or "info", Duration = 3 })
            end)
        else
            print("[IndraHub] " .. tostring(title) .. ": " .. tostring(content))
        end
    end

    local Window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "search",
        Author = "Hide & Seek",
        Folder = "IndraHubHideNSeek",
        Size = UDim2.fromOffset(560, 420),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 160,
    })

    env.IndraHubHideNSeekWindow = Window
    if Window.SetToggleKey then Window:SetToggleKey(Settings.KeybindToggle) end
    if Window.EditOpenButton then Window:EditOpenButton({ Title = "IndraHub", Icon = "search", Draggable = true }) end

    local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

    VisualsTab:Section({ Title = "See hidden players through walls and track positions.", Icon = "eye" })

    VisualsTab:Toggle({
        Title = "X-Ray (Wallhack)",
        Value = false,
        Callback = function(value)
            SetXRay(value)
        end,
    })

    VisualsTab:Toggle({
        Title = "Player ESP",
        Value = false,
        Callback = function(value)
            Settings.ESPEnabled = value
            RefreshESP()
        end,
    })

    VisualsTab:Slider({
        Title = "X-Ray Transparency",
        Value = { Min = 0.1, Max = 0.9, Default = 0.5 },
        Step = 0.1,
        Callback = function(value)
            Settings.TransparencyValue = value
            if Settings.XRayEnabled then
                SetXRay(true)
            end
        end,
    })

    VisualsTab:Button({
        Title = "Refresh ESP",
        Callback = function()
            RefreshESP()
            notify("ESP Refreshed", "Player highlights have been updated.", "eye")
        end,
    })

    local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })

    MovementTab:Section({ Title = "Speed boost and movement helpers.", Icon = "zap" })

    MovementTab:Toggle({
        Title = "Speed Boost",
        Value = false,
        Callback = function(value)
            SetSpeedBoost(value)
        end,
    })

    MovementTab:Slider({
        Title = "Walk Speed",
        Value = { Min = 16, Max = 100, Default = 16 },
        Step = 1,
        Callback = function(value)
            UpdateSpeed(value)
        end,
    })

    MovementTab:Button({
        Title = "Reset Speed",
        Callback = function()
            UpdateSpeed(16)
            SetSpeedBoost(false)
            notify("Speed Reset", "Walk speed has been reset to default (16).", "zap")
        end,
    })

    local PlayersTab = Window:Tab({ Title = "Players", Icon = "users" })

    PlayersTab:Section({ Title = "Player distances and teleport tools.", Icon = "users" })

    PlayersTab:Button({
        Title = "Print Player Distances",
        Callback = function()
            print("\n=== Player Distances ===")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local dist = math.floor(GetDistance(player))
                    local alive = IsAlive(player) and "Alive" or "Dead"
                    print(string.format("  %s - %dm [%s]", player.Name, dist, alive))
                end
            end
            print("========================\n")
        end,
    })
    
    PlayersTab:Button({
        Title = "Teleport to Nearest Player",
        Callback = function()
            local nearestPlayer = nil
            local nearestDist = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsAlive(player) then
                    local dist = GetDistance(player)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
            
            if nearestPlayer then
                local myRoot = GetRootPart(LocalPlayer)
                local theirRoot = GetRootPart(nearestPlayer)
                if myRoot and theirRoot then
                    myRoot.CFrame = theirRoot.CFrame * CFrame.new(0, 0, 5)
                    notify("Teleported", "Teleported to " .. nearestPlayer.Name .. " (" .. math.floor(nearestDist) .. "m)", "users")
                end
            else
                notify("No Target", "No alive players found to teleport to.", "users")
            end
        end,
    })

    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

    SettingsTab:Section({ Title = "IndraHub Hide & Seek", Icon = "search" })
    SettingsTab:Section({ Title = "RightShift toggles UI", Icon = "keyboard" })

    SettingsTab:Button({
        Title = "Destroy Script",
        Callback = function()
            IsRunning = false
            SetXRay(false)
            Settings.ESPEnabled = false
            RefreshESP()
            SetSpeedBoost(false)
            
            for _, conn in ipairs(Connections) do
                pcall(function() conn:Disconnect() end)
            end
            table.clear(Connections)
            
            if Window and Window.Destroy then pcall(function() Window:Destroy() end) end
            env.IndraHubHideNSeekWindow = nil
            print("[IndraHub Hide & Seek] Script destroyed.")
        end,
    })

    return WindUI
end

local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if Settings.ESPEnabled then
            SafeCall(CreateESP, player)
        end
    end)
end)
table.insert(Connections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
        ESPObjects[player] = nil
    end
end)
table.insert(Connections, playerRemovingConn)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        local charAddedConn = player.CharacterAdded:Connect(function()
            task.wait(1)
            if Settings.ESPEnabled then
                SafeCall(CreateESP, player)
            end
        end)
        table.insert(Connections, charAddedConn)
    end
end

local myCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Settings.SpeedBoost then
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = Settings.SpeedValue
        end
    end
end)
table.insert(Connections, myCharConn)

local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.KeybindToggle then
    end
end)
table.insert(Connections, inputConn)

local function Init()
    print("[IndraHub Hide & Seek] Script loaded!")
    print("[IndraHub Hide & Seek] Press RightShift to toggle GUI")
    
    SafeCall(SetupGUI)
end

Init()
