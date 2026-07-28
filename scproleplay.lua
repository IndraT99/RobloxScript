-- =====================================================================
--  INDRAHUB | SCP Roleplay Edition
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

if getGlobal("IndraHubSCPRoleplayRunning") == true then
    return
end

local scpSession = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
setGlobal("IndraHubSCPRoleplaySession", scpSession)
setGlobal("IndraHubSCPRoleplayRunning", true)
setGlobal("IndraHubSCPRoleplayLastHeartbeat", os.clock())
setGlobal("IndraHubSCPRoleplayError", nil)

task.spawn(function()
    while getGlobal("IndraHubSCPRoleplayRunning") == true
        and getGlobal("IndraHubSCPRoleplaySession") == scpSession do
        setGlobal("IndraHubSCPRoleplayLastHeartbeat", os.clock())
        task.wait(5)
    end
end)

shared.IndraHub_SCPRoleplay_Unloaded = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Configuration and State
local flags = {
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    ShowFOV = false,
    FOVRadius = 150,
    Smoothness = 5,
    Prediction = 0.14,
    WallCheck = false,
    TargetPart = "Head",

    ESPMaster = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPDistance = false,
    ESPTracers = false,
    ESPMaxDistance = 3000,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Noclip = false,
    FastInteract = false,

    ShowFPS = false,
    FPSBoost = false,
    AntiAfk = true,
    HB = nil
}

-- Team Data
local TeamColors = {
    ["Civilian"] = Color3.fromRGB(150, 150, 150),
    ["Class-D"] = Color3.fromRGB(255, 120, 0),
    ["Chaos"] = Color3.fromRGB(0, 100, 0),
    ["Scientific"] = Color3.fromRGB(173, 216, 230),
    ["Medical"] = Color3.fromRGB(64, 224, 208),
    ["Security"] = Color3.fromRGB(0, 0, 139),
    ["MTF"] = Color3.fromRGB(25, 25, 112),
    ["ISD"] = Color3.fromRGB(128, 0, 0),
    ["Administrative"] = Color3.fromRGB(255, 255, 255),
    ["Ethics"] = Color3.fromRGB(34, 139, 34),
    ["O5"] = Color3.fromRGB(30, 30, 30),
}

local function GetPlayerTeamData(player)
    if not player.Team then return "Civilian", TeamColors["Civilian"] end
    local tn = player.Team.Name:lower()
    
    if tn:match("class%-d") or tn:match("class d") or tn:match("classd") or tn:match("d%-class") or tn:match("d class") then return "Class-D", TeamColors["Class-D"]
    elseif tn:match("chaos") then return "Chaos", TeamColors["Chaos"]
    elseif tn:match("scien") then return "Scientific", TeamColors["Scientific"]
    elseif tn:match("medic") then return "Medical", TeamColors["Medical"]
    elseif tn:match("secur") then return "Security", TeamColors["Security"]
    elseif tn:match("mobile") or tn:match("mtf") then return "MTF", TeamColors["MTF"]
    elseif tn:match("internal") or tn:match("isd") then return "ISD", TeamColors["ISD"]
    elseif tn:match("admin") then return "Administrative", TeamColors["Administrative"]
    elseif tn:match("ethic") then return "Ethics", TeamColors["Ethics"]
    elseif tn:match("o5") or tn:match("council") then return "O5", TeamColors["O5"]
    else return "Civilian", TeamColors["Civilian"] end
end

local function IsEnemy(myTeam, targetTeam)
    if myTeam == targetTeam then
        return false
    end
    return true
end

local function singleDropdownValue(value)
    if type(value) ~= "table" then
        return value
    end

    for key, selectedValue in pairs(value) do
        if selectedValue == true and type(key) == "string" then
            return key
        end
        if type(selectedValue) == "string" then
            return selectedValue
        end
    end
    return nil
end

-- Initialize WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - SCP Roleplay",
    Icon = "rbxassetid://10747382750", -- Wind Icon
    Author = "IndraHub",
    Folder = "IndraHub_SCPRoleplay",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    Home = Window:Tab({ Title = "Home", Icon = "home" }),
    Combat = Window:Tab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "sparkles" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "layout-grid" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

-- Home Tab Setup
Tabs.Home:Section({ Title = "RAGE HUB V3 // INDRAHUB EDITION" })
Tabs.Home:Paragraph({ Title = "WE ARE ANONYMOUS", Desc = "Refactored with WindUI, full security bypasses, and multi-executor compatibility." })
Tabs.Home:Paragraph({ Title = "Safe Usage Guidelines", Desc = "Keep aimbot smoothness above 5 to bypass player reports. Do not noclip when chased by ISD/admins." })
Tabs.Home:Paragraph({ Title = "How To Use", Desc = "Default Keybind for Menu is handled by WindUI.\nUse configured Keybind for Smart Aimbot targeting." })

-- Combat Tab Setup
Tabs.Combat:Section({ Title = "Aimbot Assist" })
Tabs.Combat:Toggle({ Title = "Enable Aimbot", Default = false, Callback = function(v) flags.AimbotEnabled = v end })
Tabs.Combat:Toggle({ Title = "Show FOV Circle", Default = false, Callback = function(v) flags.ShowFOV = v end })
Tabs.Combat:Slider({ Title = "FOV Radius", Value = { Min = 10, Max = 500, Default = 150 }, Callback = function(v) flags.FOVRadius = v end })
Tabs.Combat:Slider({ Title = "Aimbot Smoothness", Value = { Min = 1, Max = 20, Default = 5 }, Callback = function(v) flags.Smoothness = v end })
Tabs.Combat:Slider({ Title = "Aimbot Prediction", Value = { Min = 0, Max = 0.5, Default = 0.14 }, Callback = function(v) flags.Prediction = v end })
Tabs.Combat:Toggle({ Title = "Wall Check", Default = false, Callback = function(v) flags.WallCheck = v end })
Tabs.Combat:Dropdown({ Title = "Target Part", Values = { "Head", "HumanoidRootPart" }, Default = 1, Multi = false, Callback = function(v) flags.TargetPart = singleDropdownValue(v) or flags.TargetPart end })
Tabs.Combat:Dropdown({ Title = "Aimbot Keybind", Values = { "Right Click", "Left Click", "E", "Q" }, Default = 1, Multi = false, Callback = function(v)
    local selected = singleDropdownValue(v)
    if selected == "Right Click" then
        flags.AimbotKey = Enum.UserInputType.MouseButton2
    elseif selected == "Left Click" then
        flags.AimbotKey = Enum.UserInputType.MouseButton1
    elseif selected == "E" then
        flags.AimbotKey = Enum.KeyCode.E
    elseif selected == "Q" then
        flags.AimbotKey = Enum.KeyCode.Q
    end
end })

-- Visuals Tab Setup
Tabs.Visuals:Section({ Title = "ESP Master Control" })
Tabs.Visuals:Toggle({ Title = "ESP Enable", Default = false, Callback = function(v) flags.ESPMaster = v end })
Tabs.Visuals:Slider({ Title = "Max Distance", Value = { Min = 100, Max = 5000, Default = 3000 }, Callback = function(v) flags.ESPMaxDistance = v end })

Tabs.Visuals:Section({ Title = "Render Elements" })
Tabs.Visuals:Toggle({ Title = "Boxes", Default = false, Callback = function(v) flags.ESPBoxes = v end })
Tabs.Visuals:Toggle({ Title = "Names & Roles", Default = false, Callback = function(v) flags.ESPNames = v end })
Tabs.Visuals:Toggle({ Title = "Distance", Default = false, Callback = function(v) flags.ESPDistance = v end })
Tabs.Visuals:Toggle({ Title = "Tracers", Default = false, Callback = function(v) flags.ESPTracers = v end })

-- Movement Tab Setup
Tabs.Movement:Section({ Title = "Bypasses & Modifiers" })
Tabs.Movement:Slider({ Title = "WalkSpeed Override", Value = { Min = 16, Max = 45, Default = 16 }, Callback = function(v) flags.WalkSpeed = v end })
Tabs.Movement:Toggle({ Title = "Infinite Jump (Fly)", Default = false, Callback = function(v) flags.InfJump = v end })
Tabs.Movement:Toggle({ Title = "Noclip", Default = false, Callback = function(v) flags.Noclip = v end })
Tabs.Movement:Toggle({ Title = "Fast Interact", Default = false, Callback = function(v) flags.FastInteract = v end })

-- Misc Tab Setup
Tabs.Misc:Section({ Title = "Client & Graphics" })
Tabs.Misc:Toggle({ Title = "Show FPS Counter", Default = false, Callback = function(v) flags.ShowFPS = v end })
Tabs.Misc:Button({ Title = "FPS Overclock & Texture Boost", Callback = function()
    task.spawn(function()
        pcall(function()
            if setfpscap then setfpscap(999) end
        end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        pcall(function()
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                    v.Enabled = false
                end
            end
        end)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
        end
        local toDestroy = {}
        local descendants = workspace:GetDescendants()
        for i, obj in ipairs(descendants) do
            local ok, cls = pcall(function() return obj.ClassName end)
            if ok then
                if cls == "Texture" or cls == "Decal" or cls == "ParticleEmitter"
                or cls == "Trail" or cls == "Beam" or cls == "Fire"
                or cls == "Smoke" or cls == "Sparkles" then
                    table.insert(toDestroy, obj)
                elseif obj:IsA("BasePart") then
                    pcall(function()
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                        obj.CastShadow = false
                    end)
                end
            end
            if i % 1000 == 0 then task.wait() end
        end
        for _, obj in pairs(toDestroy) do
            pcall(function() obj:Destroy() end)
        end
        WindUI:Notify({ Title = "IndraHub", Content = "FPS Overclock Applied!", Duration = 5 })
    end)
end })

Tabs.Misc:Section({ Title = "Server Actions" })
Tabs.Misc:Button({ Title = "Rejoin Server", Callback = function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end })
Tabs.Misc:Button({ Title = "Server Hop", Callback = function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

-- Settings Tab Setup
Tabs.Settings:Section({ Title = "Security & Anti-AFK" })
Tabs.Settings:Toggle({
    Title = "Anti-AFK (Heartbeat)",
    Default = true,
    Callback = function(v)
        flags.AntiAfk = v
        if v then
            if not flags.HB then
                flags.HB = game:GetService("RunService").Heartbeat:Connect(function()
                    pcall(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
                end)
            end
        else
            if flags.HB then flags.HB:Disconnect(); flags.HB = nil end
        end
    end
})

local connections = {}

Tabs.Settings:Button({
    Title = "Unload Script",
    Callback = function()
        shared.IndraHub_SCPRoleplay_Unloaded = true
        setGlobal("IndraHubSCPRoleplayRunning", false)
        setGlobal("IndraHubSCPRoleplayLastHeartbeat", os.clock())
        if getGlobal("IndraHubSCPRoleplaySession") == scpSession then
            setGlobal("IndraHubSCPRoleplaySession", nil)
        end
        if flags.HB then flags.HB:Disconnect() end
        
        -- Disconnect connections
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        
        -- Remove drawings
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
        if FPSLabel then pcall(function() FPSLabel:Remove() end) end
        for _, esp in pairs(ESP_Cache) do
            for _, obj in pairs(esp) do
                pcall(function() obj:Remove() end)
            end
        end
        
        if Window then Window:Destroy() end
    end
})

-- Background logic
local holdingSpace = false
local isAiming = false

local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then holdingSpace = true end
    if input.UserInputType == flags.AimbotKey or input.KeyCode == flags.AimbotKey then isAiming = true end
end)
table.insert(connections, inputBeganConn)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.Space then holdingSpace = false end
    if input.UserInputType == flags.AimbotKey or input.KeyCode == flags.AimbotKey then isAiming = false end
end)
table.insert(connections, inputEndedConn)

-- Stepped Logic (Movement)
local steppedConnection = RunService.Stepped:Connect(function()
    if shared.IndraHub_SCPRoleplay_Unloaded then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        
        -- WalkSpeed (CFrame Bypass)
        if flags.WalkSpeed > 16 and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * ((flags.WalkSpeed - 16) / 200))
        end
        
        -- Infinite Jump
        if flags.InfJump and holdingSpace then
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, flags.JumpPower, vel.Z)
        end
        
        -- Noclip
        if flags.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)
table.insert(connections, steppedConnection)

-- Heavy Loop
task.spawn(function()
    while not shared.IndraHub_SCPRoleplay_Unloaded do
        task.wait(1)
        
        -- Fast Interact
        if flags.FastInteract then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 25
                    end
                end
            end)
        end
    end
end)

-- Visuals & Aimbot
local ESP_Cache = {}

local function CreateESP(player)
    if player == LocalPlayer or ESP_Cache[player] then return end
    
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
    
    esp.Box.Filled = false; esp.Box.Thickness = 1
    esp.BoxOutline.Filled = false; esp.BoxOutline.Thickness = 3; esp.BoxOutline.Color = Color3.new(0,0,0)
    
    esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Size = 14; esp.Name.Font = 2
    esp.Dist.Center = true; esp.Dist.Outline = true; esp.Dist.Size = 12; esp.Dist.Font = 2
    esp.Tracer.Thickness = 1
    
    ESP_Cache[player] = esp
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, obj in pairs(ESP_Cache[player]) do
            pcall(function() obj.Visible = false; obj:Remove() end)
        end
        ESP_Cache[player] = nil
    end
end

local function HideESP(espObj)
    for _, obj in pairs(espObj) do
        pcall(function() obj.Visible = false end)
    end
end

local playerAddedConn = Players.PlayerAdded:Connect(CreateESP)
table.insert(connections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(RemoveESP)
table.insert(connections, playerRemovingConn)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- Extra Drawing Elements
local FPSLabel = nil
pcall(function()
    FPSLabel = Drawing.new("Text")
    FPSLabel.Visible = false
    FPSLabel.Size = 15
    FPSLabel.Font = 2
    FPSLabel.Outline = true
    FPSLabel.Color = Color3.fromRGB(255, 255, 255)
    FPSLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    FPSLabel.Text = "FPS: 0"
end)

local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
end)

local fpsLastTime = tick()
local fpsCount = 0
local fpsDisplay = 0

local renderConnection = RunService.RenderStepped:Connect(function(dt)
    if shared.IndraHub_SCPRoleplay_Unloaded then return end
    
    local cam = workspace.CurrentCamera
    local mouseLoc = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    -- FPS Counter
    if FPSLabel then
        fpsCount = fpsCount + 1
        local now = tick()
        if now - fpsLastTime >= 0.5 then
            fpsDisplay = math.floor(fpsCount / (now - fpsLastTime))
            fpsCount = 0
            fpsLastTime = now
        end
        FPSLabel.Visible = flags.ShowFPS
        if flags.ShowFPS then
            local vp = cam.ViewportSize
            FPSLabel.Text = "FPS: " .. fpsDisplay
            FPSLabel.Position = Vector2.new(vp.X - 70, 10)
        end
    end

    -- FOV Circle
    if FOVCircle then
        FOVCircle.Visible = flags.ShowFOV
        FOVCircle.Radius = flags.FOVRadius
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Position = mouseLoc
    end

    local target = nil
    local shortestDist = flags.FOVRadius
    local myTeamType, _ = GetPlayerTeamData(LocalPlayer)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            
            local hrp = p.Character.HumanoidRootPart
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            local dist2D = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
            local dist3D = (hrp.Position - cam.CFrame.Position).Magnitude
            
            local tType, tColor = GetPlayerTeamData(p)
            
            -- ESP Rendering
            if flags.ESPMaster and ESP_Cache[p] and dist3D <= flags.ESPMaxDistance then
                local esp = ESP_Cache[p]
                if onScreen then
                    local head = p.Character:FindFirstChild("Head")
                    local headPos = head and cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                    local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    if flags.ESPBoxes then
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                        esp.Box.Color = tColor
                        esp.Box.Visible = true
                        
                        esp.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                        esp.BoxOutline.Position = Vector2.new(pos.X - width/2 - 1, headPos.Y - 1)
                        esp.BoxOutline.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                    end
                    
                    if flags.ESPNames then
                        esp.Name.Position = Vector2.new(pos.X, headPos.Y - 18)
                        esp.Name.Text = "[" .. tType .. "] " .. p.Name
                        esp.Name.Color = tColor
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end
                    
                    if flags.ESPDistance then
                        esp.Dist.Position = Vector2.new(pos.X, legPos.Y + 4)
                        esp.Dist.Text = math.floor(dist3D) .. " studs"
                        esp.Dist.Color = Color3.fromRGB(150, 150, 160)
                        esp.Dist.Visible = true
                    else
                        esp.Dist.Visible = false
                    end
                    
                    if flags.ESPTracers then
                        esp.Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, legPos.Y)
                        esp.Tracer.Color = tColor
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end
                else
                    HideESP(ESP_Cache[p])
                end
            elseif ESP_Cache[p] then
                HideESP(ESP_Cache[p])
            end
            
            -- Aimbot Targeting
            if flags.AimbotEnabled and onScreen and dist2D < shortestDist then
                if IsEnemy(myTeamType, tType) then
                    local targPart = p.Character:FindFirstChild(flags.TargetPart) or hrp
                    local canSee = true
                    
                    if flags.WallCheck then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character, cam}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local result = workspace:Raycast(cam.CFrame.Position, targPart.Position - cam.CFrame.Position, params)
                        if result and not result.Instance:IsDescendantOf(p.Character) then
                            canSee = false
                        end
                    end
                    
                    if canSee then
                        target = targPart
                        shortestDist = dist2D
                    end
                end
            end
            
        elseif ESP_Cache[p] then
            HideESP(ESP_Cache[p])
        end
    end
    
    -- Execute Aimbot
    if isAiming and target and flags.AimbotEnabled then
        local predPos = target.Position
        if flags.Prediction > 0 and target.Parent:FindFirstChild("HumanoidRootPart") then
            predPos = predPos + (target.Parent.HumanoidRootPart.AssemblyLinearVelocity * flags.Prediction)
        end
        local pos, onScreen = cam:WorldToViewportPoint(predPos)
        if onScreen then
            if mousemoverel then
                local smooth = math.max(flags.Smoothness, 1)
                mousemoverel((pos.X - mouseLoc.X) / smooth, (pos.Y - mouseLoc.Y) / smooth)
            else
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, predPos), 1 / (flags.Smoothness * 2))
            end
        end
    end
end)
table.insert(connections, renderConnection)

-- Default settings check
if flags.AntiAfk then
    flags.HB = game:GetService("RunService").Heartbeat:Connect(function()
        pcall(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
    end)
end

WindUI:Notify({ Title = "IndraHub", Content = "Loaded SCP Roleplay Script", Duration = 5 })
