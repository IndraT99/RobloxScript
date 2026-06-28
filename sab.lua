-- IndraHubSAB - WindUI merged Steal A Brainrot hub.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local State = {
    speedEnabled = false,
    speed = 50,
    jumpPower = 120,
    infJump = false,
    doubleJump = false,
    highJump = false,
    noclip = false,
    godmode = false,
    float = false,
    cameraFloat = false,
    proxInstant = false,
    playerESP = false,
    brainrotESP = false,
    savedCFrame = nil,
    selectedBrainrots = {},
}

local PlayerESP = {}
local BrainrotESP = {}
local FloatMover
local MarkerPart

local Brainrots = {
    Common = {"Noobini Pizzanini", "Tim Cheese", "Talpa Di Fero", "Svinina Bombardino", "Pipi Kiwi", "Lirili Larila", "Fluriflura"},
    Rare = {"Trippi Troppi", "Tung Tung Tung Sahur", "Gangster Footera", "Bandito Bobritto", "Boneca Ambalabu", "Ta Ta Ta Ta Sahur", "Tric Trac Baraboom"},
    Epic = {"Cappuccino Assassino", "Brr Brr Patapim", "Trulimero Trulicina", "Bambini Crostini", "Bananita Dolphinita", "Perochello Lemonchello", "Brri Brri Bicus Dicus Bombicus"},
    Legendary = {"Burbaloni Luliloli", "Chimpanzini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra", "Lionel Cactuseli", "Glorbo Fruttodrillo", "Blueberrinni Octopusini"},
    Mythic = {"Frigo Camelo", "Orangutini Ananassini", "Rhino Toasterino", "Bombardiro Crocodilo", "Bombombini Gusini", "Cavallo Virtuoso"},
    ["Brainrot God"] = {"Cocofanto Elefanto", "Girafa Celestre", "Matteo", "Tralalero Tralala", "Odin Din Din Dun", "Unclito Samito", "Trenostruzzo Turbo 3000", "Gattatino Nyanino"},
    Secret = {"La Vacca Saturno Saturnita", "Sammyni Spyderini", "Los Tralaleritos", "Graipuss Medussi", "La Grande Combinasion", "Garama and Madundung"},
}

local function notify(title, content, icon)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function() WindUI:Notify({Title = title, Content = content, Icon = icon or "info", Duration = 3}) end)
    else
        pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = content, Duration = 3}) end)
    end
end

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getChar()
    return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart"), char
end

local function removePlayerESP(player)
    if PlayerESP[player] then
        for _, inst in ipairs(PlayerESP[player]) do pcall(function() inst:Destroy() end) end
    end
    PlayerESP[player] = nil
end

local function addPlayerESP(player)
    if player == LocalPlayer or not State.playerESP then return end
    removePlayerESP(player)
    local char = player.Character
    if not char then return end
    local list = {}
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 80, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char
    table.insert(list, highlight)
    local head = char:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Name = "IndraPlayerESP"
        bill.Size = UDim2.new(0, 120, 0, 32)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Adornee = head
        bill.Parent = head
        local label = Instance.new("TextLabel", bill)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        table.insert(list, bill)
    end
    PlayerESP[player] = list
end

local function refreshPlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do addPlayerESP(player) end
end

local function removeBrainrotESP(model)
    if BrainrotESP[model] then pcall(function() BrainrotESP[model]:Destroy() end) end
    BrainrotESP[model] = nil
end

local function addBrainrotESP(model)
    if BrainrotESP[model] then return end
    local part = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "IndraBrainrotESP"
    bill.Size = UDim2.new(0, 150, 0, 40)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 800
    bill.Adornee = part
    bill.Parent = model
    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = model.Name
    label.TextColor3 = Color3.fromRGB(190, 80, 255)
    label.TextStrokeTransparency = 0.35
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    BrainrotESP[model] = bill
end

local function refreshBrainrotESP()
    for model in pairs(BrainrotESP) do
        if not model.Parent or not State.selectedBrainrots[model.Name] then removeBrainrotESP(model) end
    end
    if not State.brainrotESP then return end
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and State.selectedBrainrots[model.Name] then addBrainrotESP(model) end
    end
end

local function spawnMarker(root)
    if MarkerPart then MarkerPart:Destroy() end
    MarkerPart = Instance.new("Part")
    MarkerPart.Name = "IndraHubSAB_TeleportMarker"
    MarkerPart.Anchored = true
    MarkerPart.CanCollide = false
    MarkerPart.Size = Vector3.new(3, 0.15, 3)
    MarkerPart.Material = Enum.Material.Neon
    MarkerPart.Color = Color3.fromRGB(0, 255, 255)
    MarkerPart.Position = Vector3.new(root.Position.X, root.Position.Y - 4, root.Position.Z)
    MarkerPart.Parent = workspace
    task.delay(8, function()
        if MarkerPart then MarkerPart:Destroy(); MarkerPart = nil end
    end)
end

local Window = WindUI:CreateWindow({
    Title = "IndraHubSAB",
    Icon = "brain",
    Author = "Merged SAB Scripts",
    Folder = "IndraHubSAB",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 170,
    HideSearchBar = false,
})

pcall(function() Window:SetToggleKey(Enum.KeyCode.RightControl) end)
pcall(function() Window:EditOpenButton({Title = "IndraHubSAB", Icon = "brain", Draggable = true}) end)

local Tabs = {
    Main = Window:Tab({Title = "Main", Icon = "zap"}),
    Visual = Window:Tab({Title = "Visual", Icon = "eye"}),
    Steal = Window:Tab({Title = "Steal", Icon = "diamond"}),
    Server = Window:Tab({Title = "Server", Icon = "globe"}),
    Shop = Window:Tab({Title = "Shop", Icon = "shopping-cart"}),
    Info = Window:Tab({Title = "Info", Icon = "info"}),
}

Tabs.Main:Section({Title = "Movement", Icon = "zap"})
Tabs.Main:Slider({Title = "WalkSpeed", Value = {Min = 0, Max = 300, Default = State.speed}, Step = 1, Callback = function(v) State.speed = v end})
Tabs.Main:Slider({Title = "JumpPower", Value = {Min = 0, Max = 250, Default = State.jumpPower}, Step = 1, Callback = function(v) State.jumpPower = v end})
Tabs.Main:Toggle({Title = "Speed Boost", Value = false, Callback = function(v) State.speedEnabled = v end})
Tabs.Main:Button({Title = "Apply JumpPower", Callback = function()
    local hum = getHumanoid()
    if hum then hum.JumpPower = State.jumpPower; hum.UseJumpPower = true end
end})
Tabs.Main:Toggle({Title = "Infinite Jump", Value = false, Callback = function(v) State.infJump = v end})
Tabs.Main:Toggle({Title = "Double Jump", Value = false, Callback = function(v) State.doubleJump = v end})
Tabs.Main:Toggle({Title = "High Jump", Value = false, Callback = function(v) State.highJump = v end})
Tabs.Main:Toggle({Title = "Noclip", Value = false, Callback = function(v) State.noclip = v end})
Tabs.Main:Toggle({Title = "Godmode", Value = false, Callback = function(v) State.godmode = v end})
Tabs.Main:Button({Title = "Anti-Glitch Fix", Callback = function()
    local _, root = getHumanoid()
    if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
end})
Tabs.Main:Toggle({Title = "Instant ProximityPrompt", Value = false, Callback = function(v)
    State.proxInstant = v
    if v then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
        end
    end
end})
Tabs.Main:Button({Title = "Anti Lag", Callback = function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            pcall(function() v:Destroy() end)
        elseif v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then
            v.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 0
    Lighting.ClockTime = 14
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 1
    notify("Anti Lag", "Applied", "cpu")
end})

Tabs.Visual:Section({Title = "Players", Icon = "users"})
Tabs.Visual:Toggle({Title = "Player ESP", Value = false, Callback = function(v)
    State.playerESP = v
    if v then refreshPlayerESP() else for p in pairs(PlayerESP) do removePlayerESP(p) end end
end})
Tabs.Visual:Button({Title = "Player Count", Callback = function() notify("Player Count", tostring(#Players:GetPlayers()) .. " players", "users") end})
Tabs.Visual:Button({Title = "Analyze Richest", Callback = function()
    local richest, highest = nil, -math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local cash = stats and stats:FindFirstChild("Cash")
        if cash and type(cash.Value) == "number" and cash.Value > highest then richest, highest = player, cash.Value end
    end
    notify("Richest", richest and (richest.Name .. " (" .. tostring(highest) .. ")") or "No Cash data", "bar-chart")
end})

Tabs.Visual:Section({Title = "Brainrot ESP", Icon = "brain"})
Tabs.Visual:Toggle({Title = "Brainrot ESP Master", Value = false, Callback = function(v)
    State.brainrotESP = v
    if not v then for model in pairs(BrainrotESP) do removeBrainrotESP(model) end end
    refreshBrainrotESP()
end})
for rarity, names in pairs(Brainrots) do
    Tabs.Visual:Toggle({Title = rarity, Desc = "Select/unselect all " .. rarity, Value = false, Callback = function(v)
        for _, name in ipairs(names) do State.selectedBrainrots[name] = v or nil end
        refreshBrainrotESP()
    end})
end

Tabs.Steal:Section({Title = "Teleport", Icon = "map-pin"})
Tabs.Steal:Button({Title = "Teleport Up 100", Callback = function() local _, root = getHumanoid(); if root then root.CFrame = root.CFrame + Vector3.new(0, 100, 0); spawnMarker(root) end end})
Tabs.Steal:Button({Title = "Teleport Up 193", Callback = function() local _, root = getHumanoid(); if root then root.CFrame = root.CFrame + Vector3.new(0, 193, 0); spawnMarker(root) end end})
Tabs.Steal:Button({Title = "Teleport Down 193", Callback = function() local _, root = getHumanoid(); if root then root.CFrame = root.CFrame - Vector3.new(0, 193, 0) end; if MarkerPart then MarkerPart:Destroy(); MarkerPart = nil end end})
Tabs.Steal:Button({Title = "Save Base Position", Callback = function() local _, root = getHumanoid(); if root then State.savedCFrame = root.CFrame; notify("Position", "Saved", "save") end end})
Tabs.Steal:Button({Title = "Teleport Saved Position", Callback = function() local _, root = getHumanoid(); if root and State.savedCFrame then root.CFrame = State.savedCFrame else notify("Position", "No saved position", "alert-circle") end end})
Tabs.Steal:Button({Title = "Steal/Ragdoll Down", Callback = function()
    local hum = nil
    local root = nil
    hum, root = getHumanoid()
    if not (hum and root) then return end
    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    local start = os.clock()
    while os.clock() - start < 1 do
        local _, liveRoot = getHumanoid()
        if liveRoot then liveRoot.CFrame = CFrame.new(0, -500, 0) end
        task.wait()
    end
    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.Running)
end})
Tabs.Steal:Section({Title = "Modes", Icon = "feather"})
Tabs.Steal:Toggle({Title = "Float Hover", Value = false, Callback = function(v)
    State.float = v
    local _, root = getHumanoid()
    if FloatMover then FloatMover:Destroy(); FloatMover = nil end
    if v and root then
        FloatMover = Instance.new("BodyPosition")
        FloatMover.Name = "IndraHubSAB_Float"
        FloatMover.MaxForce = Vector3.new(0, 100000, 0)
        FloatMover.D = 1000
        FloatMover.P = 3000
        FloatMover.Position = root.Position + Vector3.new(0, 0.65, 0)
        FloatMover.Parent = root
    end
end})
Tabs.Steal:Toggle({Title = "Camera Float", Value = false, Callback = function(v) State.cameraFloat = v end})
Tabs.Steal:Section({Title = "External Tools", Icon = "scroll"})
Tabs.Steal:Button({Title = "Load Freecam", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Freecam"))() end) end})
Tabs.Steal:Button({Title = "Load Infinite Yield", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))() end) end})
Tabs.Steal:Button({Title = "Load Arbix Steal Hub", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Youifpg/Steal-a-Brianrot/refs/heads/main/ArbixHubBEST.lua"))() end) end})
Tabs.Steal:Button({Title = "Load Anti-Kick", Callback = function() pcall(function() loadstring(game:HttpGet("https://pastefy.app/dAjYZBnq/raw"))() end) end})

Tabs.Server:Button({Title = "Rejoin", Callback = function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end})
Tabs.Server:Button({Title = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
Tabs.Server:Button({Title = "Join Low Player Server", Callback = function()
    local servers, cursor = {}, nil
    for _ = 1, 10 do
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end
        local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if not (ok and result and result.data) then break end
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then table.insert(servers, server) end
        end
        cursor = result.nextPageCursor
        if not cursor then break end
    end
    table.sort(servers, function(a, b) return a.playing < b.playing end)
    if servers[1] then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer) else notify("Server", "No server found", "alert-circle") end
end})
Tabs.Server:Button({Title = "Random Public Server", Callback = function()
    local ok, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    local ids = {}
    if ok and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing and server.playing < server.maxPlayers then table.insert(ids, server.id) end
        end
    end
    if #ids > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, ids[math.random(1, #ids)], LocalPlayer) else notify("Server", "No server found", "alert-circle") end
end})

local function buyPower(item)
    local remote = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Net")
        and ReplicatedStorage.Packages.Net:FindFirstChild("RF/CoinsShopService/RequestBuy")
    if not remote then notify("Shop", "Buy remote not found", "alert-circle"); return end
    local ok = pcall(function() remote:InvokeServer(item) end)
    notify("Shop", ok and ("Requested " .. item) or ("Failed " .. item), ok and "check" or "x")
end

for _, item in ipairs({"Quantum Cloner", "Medusa's Head", "Invisibility Cloak"}) do
    Tabs.Shop:Button({Title = "Buy " .. item, Callback = function() buyPower(item) end})
end

Tabs.Info:Section({Title = "IndraHubSAB", Icon = "brain"})
Tabs.Info:Section({Title = "Merged from sab/Very op Steal a brainrot gui 1-8.txt", Icon = "files"})
Tabs.Info:Section({Title = "Toggle UI: RightControl", Icon = "keyboard"})

local canDoubleJump = true
UserInputService.JumpRequest:Connect(function()
    local hum, root = getHumanoid()
    if not hum then return end
    if State.infJump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    if State.highJump and root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, State.jumpPower, root.AssemblyLinearVelocity.Z) end
    if State.doubleJump then
        if hum.FloorMaterial ~= Enum.Material.Air then
            canDoubleJump = true
        elseif canDoubleJump then
            canDoubleJump = false
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    canDoubleJump = true
    if State.playerESP then refreshPlayerESP() end
    if State.float then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if FloatMover then FloatMover:Destroy() end
            FloatMover = Instance.new("BodyPosition")
            FloatMover.Name = "IndraHubSAB_Float"
            FloatMover.MaxForce = Vector3.new(0, 100000, 0)
            FloatMover.D = 1000
            FloatMover.P = 3000
            FloatMover.Position = root.Position + Vector3.new(0, 0.65, 0)
            FloatMover.Parent = root
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() task.wait(0.5); addPlayerESP(player) end)
end)
Players.PlayerRemoving:Connect(removePlayerESP)

workspace.DescendantAdded:Connect(function(obj)
    if State.proxInstant and obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
    if State.brainrotESP and obj:IsA("Model") and State.selectedBrainrots[obj.Name] then task.wait(0.1); addBrainrotESP(obj) end
end)

RunService.Heartbeat:Connect(function()
    local hum, root, char = getHumanoid()
    if not (hum and root and char) then return end
    if State.speedEnabled and hum.MoveDirection.Magnitude > 0 then
        local dir = hum.MoveDirection
        root.AssemblyLinearVelocity = Vector3.new(dir.X * State.speed, root.AssemblyLinearVelocity.Y, dir.Z * State.speed)
    end
    if State.noclip then
        for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
    if State.godmode and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    if State.float and FloatMover and FloatMover.Parent == root then FloatMover.Position = root.Position + Vector3.new(0, 0.65, 0) end
    if State.cameraFloat and Camera then
        local dir = Camera.CFrame.LookVector
        root.AssemblyLinearVelocity = Vector3.new(dir.X * 40, 4, dir.Z * 40)
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.playerESP then refreshPlayerESP() end
        if State.brainrotESP then refreshBrainrotESP() end
    end
end)

notify("IndraHubSAB", "WindUI loaded", "brain")
