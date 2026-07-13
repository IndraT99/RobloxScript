local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubGrowItRunning") then return end
setGlobal("IndraHubGrowItRunning", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        setGlobal("IndraHubGrowItLastHeartbeat", os.time())
    end
end)

local Inventory = Player:WaitForChild("Inventory", 30)
if not Inventory then Inventory = nil end

local SeedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon"}
local GearList = {"Common Watering Can", "Common Sprinkler", "Sign", "Lantern", "Wheelbarrow", "Uncommon Sprinkler", "Rare Sprinkler", "Legendary Sprinkler", "Super Sprinkler", "Trowel", "Speed Mushroom", "Jump Mushroom", "Gnome", "Shrink Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Teleporter", "Super Watering Can", "Basic Pot", "Flashbang"}
local FruitList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon"}

local SeedPrices = {
    Carrot = 1, Strawberry = 10, Blueberry = 25, Tulip = 40, Tomato = 200,
    Apple = 400, Bamboo = 700, Corn = 2500, Cactus = 5000, Pineapple = 10000,
    Mushroom = 15000, ["Green Bean"] = 20000, Banana = 30000, Grape = 50000,
    Coconut = 70000, Mango = 85000, ["Dragon Fruit"] = 120000, Acorn = 200000,
    Cherry = 250000, Sunflower = 300000, ["Venus Fly Trap"] = 400000,
    ["Poison Apple"] = 400000, Pomegranate = 2000000, ["Ghost Pepper"] = 2800000,
    ["Poison Ivy"] = 2800000, ["Moon Bloom"] = 7000000, ["Dragon's Breath"] = 9000000,
    ["Baby Cactus"] = 1, ["Glow Mushroom"] = 1, Romanesco = 1, ["Horned Melon"] = 1, Gold = 1
}

local GearPrices = {
    Trowel = 1000, ["Common Watering Can"] = 2000, ["Speed Mushroom"] = 1500,
    ["Jump Mushroom"] = 1800, ["Common Sprinkler"] = 3000, Sign = 4000,
    ["Shrink Mushroom"] = 4500, ["Supersize Mushroom"] = 4500, ["Uncommon Sprinkler"] = 10000,
    Flashbang = 8000, Teleporter = 18000, ["Rare Sprinkler"] = 50000, Lantern = 12000,
    Gnome = 50000, ["Legendary Sprinkler"] = 100000, ["Basic Pot"] = 60000,
    ["Super Sprinkler"] = 300000, ["Super Watering Can"] = 250000, Wheelbarrow = 500000
}

local BaseValues = {
    Carrot = 5, Strawberry = 3, Blueberry = 5, Tomato = 9, Apple = 12,
    Cactus = 40, Pineapple = 30, Banana = 35, Corn = 34, Grape = 45,
    Mango = 90, Coconut = 60, Cherry = 350, Pomegranate = 900, ["Dragon Fruit"] = 150,
    Mushroom = 13000, Sunflower = 1750, ["Venus Fly Trap"] = 3000, ["Moon Bloom"] = 9000,
    ["Dragon's Breath"] = 3400, ["Ghost Pepper"] = 2500, Lotus = 6500,
    Romanesco = 1500, ["Poison Apple"] = 900, ["Poison Ivy"] = 1700, ["Glow Mushroom"] = 700,
    ["Horned Melon"] = 200, ["Baby Cactus"] = 70, Tulip = 60, Bamboo = 800,
    Pumpkin = 350, Pinetree = 100, ["Green Bean"] = 10, Beanstalk = 2000,
    ["Thorn Rose"] = 140, Acorn = 200
}

local MutationMults = {
    Gold = 20, Rainbow = 50, Electric = 12, Frozen = 10, Bloodlit = 5, Chained = 8, Starstruck = 100
}

local RarityRank = { Common = 1, Uncommon = 2, Rare = 3, Legendary = 4, Epic = 4, Mythic = 5, Super = 6 }

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Grow It",
    Icon = "sprout",
    Author = "IndraHub",
    Folder = "IndraHubGrowIt",
    Size = UDim2.fromOffset(620, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

local Threads = {}
local States = {}

local function KillThread(name)
    if Threads[name] then
        task.cancel(Threads[name])
        Threads[name] = nil
    end
end

local Networking = nil
local NetworkingCache = {}

local function ResolveNetworking()
    if Networking then return Networking end
    local success, result = pcall(function()
        local shared = ReplicatedStorage:WaitForChild("SharedModules", 10)
        local net = shared:WaitForChild("Networking", 10)
        return require(net)
    end)
    if success and type(result) == "table" then
        Networking = result
        return result
    end
    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local hasPlant = type(v.Plant) == "table" and v.Plant.PlantSeed ~= nil
                local hasGarden = type(v.Garden) == "table" and v.Garden.CollectFruit ~= nil
                local hasSeedShop = type(v.SeedShop) == "table" and v.SeedShop.PurchaseSeed ~= nil
                if hasPlant and hasGarden and hasSeedShop then
                    Networking = v
                    return v
                end
            end
        end
    end
    return nil
end

local function ResolveRemote(path)
    if NetworkingCache[path] then return NetworkingCache[path] end
    local module = ResolveNetworking()
    if not module then return nil end
    local parts = {}
    for part in string.gmatch(path, "[^%.]+") do
        table.insert(parts, part)
    end
    local current = module
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then return nil end
        if current[part] == nil then
            local found = nil
            for k, v in pairs(current) do
                if string.lower(k) == string.lower(part) then
                    found = v
                    break
                end
            end
            if found == nil then return nil end
            current = found
        else
            current = current[part]
        end
    end
    NetworkingCache[path] = current
    return current
end

local LastPacketTime = 0
local PacketCooldown = 0.15

local function FireRemote(path, ...)
    local remote = ResolveRemote(path)
    if not remote then return false end
    local currentTime = tick()
    if currentTime - LastPacketTime < PacketCooldown then
        task.wait(PacketCooldown - (currentTime - LastPacketTime))
    end
    local success = pcall(function(...)
        if type(remote) == "function" then
            remote(...)
        elseif type(remote) == "table" and remote.Fire then
            remote:Fire(...)
        elseif type(remote) == "userdata" and remote.FireServer then
            remote:FireServer(...)
        elseif type(remote) == "table" and remote.fire then
            remote:fire(...)
        else
            error("No valid fire method")
        end
    end)
    LastPacketTime = tick()
    return success
end

local function InvokeRemote(path, ...)
    local remote = ResolveRemote(path)
    if not remote then return nil end
    local success, result = pcall(function(...)
        if remote.Invoke then
            return remote:Invoke(...)
        elseif remote.InvokeServer then
            return remote:InvokeServer(...)
        else
            error("No valid invoke method")
        end
    end)
    if not success then return nil end
    return result
end

local function OnRemote(path, callback)
    local remote = ResolveRemote(path)
    if not remote then return nil end
    local connection
    if remote.OnClientEvent then
        connection = remote.OnClientEvent:Connect(callback)
    elseif remote.Connect then
        connection = remote:Connect(callback)
    else
        return nil
    end
    return connection
end

local function GetCharacter()
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    Character = Player.Character
    if not Character then return nil, nil, nil end
    local hum = Character:FindFirstChild("Humanoid")
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if hum then Humanoid = hum end
    if hrp then HumanoidRootPart = hrp end
    return Character, hum, hrp
end

local function Notify(title, content, icon, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = icon or "info",
        Duration = duration or 4,
    })
end

local function GetMyPlot()
    if not Player then return nil end
    local plotId = Player:GetAttribute("PlotId")
    if not plotId then return nil end
    local gardens = Workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    return gardens:FindFirstChild("Plot" .. tostring(plotId))
end

local function GetPlants(plot)
    if not plot then return {} end
    local folder = plot:FindFirstChild("Plants")
    if not folder then return {} end
    local plants = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:GetAttribute("PlantId") then
            table.insert(plants, child)
        end
    end
    return plants
end

local function GetFruits(plant)
    local folder = plant:FindFirstChild("Fruits")
    if not folder then return {} end
    local fruits = {}
    for _, fruit in ipairs(folder:GetChildren()) do
        if fruit:GetAttribute("FruitId") then
            table.insert(fruits, fruit)
        end
    end
    return fruits
end

local function IsPlantHarvestable(plant)
    if not plant or not plant.Parent then return false end
    local growth = plant:GetAttribute("Growth") or 0
    if growth >= 1 then return true end
    local fruits = GetFruits(plant)
    if #fruits > 0 then return true end
    local harvestPart = plant:FindFirstChild("HarvestPart", true)
    if harvestPart then
        local prompt = harvestPart:FindFirstChild("HarvestPrompt")
        if prompt and prompt.Enabled then return true end
    end
    return false
end

local function FindEmptySpots(plot)
    if not plot then return {} end
    local base = plot:FindFirstChild("SpawnPoint") or plot:FindFirstChildWhichIsA("BasePart")
    if not base then return {} end
    local spots = {}
    local spacing = States.GridSpacing or 3
    local origin = base.Position
    for x = -15, 15, spacing do
        for z = -15, 15, spacing do
            local pos = origin + Vector3.new(x, 0, z)
            local empty = true
            local plants = plot:FindFirstChild("Plants")
            if plants then
                for _, plant in ipairs(plants:GetChildren()) do
                    local part = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
                    if part then
                        if (Vector2.new(part.Position.X, part.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude < spacing * 0.8 then
                            empty = false
                            break
                        end
                    end
                end
            end
            if empty then
                table.insert(spots, pos)
            end
        end
    end
    return spots
end

local function GetEquippedSeed()
    if not Player.Character then return nil, nil end
    local tool = Player.Character:FindFirstChildWhichIsA("Tool")
    if not tool then return nil, nil end
    local seedName = tool:GetAttribute("SeedTool")
    if not seedName then return nil, nil end
    return seedName, tool
end

local function FindSeedsInBackpack(preferSeed)
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return {} end
    local seeds = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local seedName = tool:GetAttribute("SeedTool")
            if seedName then
                table.insert(seeds, { tool = tool, seedName = seedName })
            end
        end
    end
    table.sort(seeds, function(a, b)
        if preferSeed then
            local aMatch = a.seedName == preferSeed and 1 or 0
            local bMatch = b.seedName == preferSeed and 1 or 0
            if aMatch ~= bMatch then return aMatch > bMatch end
        end
        return a.seedName < b.seedName
    end)
    return seeds
end

local function EquipSeed(preferSeed)
    if not Player.Character then return nil, nil end
    local hum = Player.Character:FindFirstChildWhichIsA("Humanoid")
    if not hum then return nil, nil end
    local equipped, tool = GetEquippedSeed()
    if equipped then return equipped, tool end
    local seeds = FindSeedsInBackpack(preferSeed)
    if #seeds == 0 then return nil, nil end
    local success = pcall(function()
        hum:EquipTool(seeds[1].tool)
    end)
    if not success then return nil, nil end
    for i = 1, 30 do
        task.wait(0.1)
        local char = Player.Character
        if not char then return nil, nil end
        local newTool = char:FindFirstChild(seeds[1].tool.Name)
        if newTool and newTool:IsA("Tool") and newTool:GetAttribute("SeedTool") then
            return seeds[1].seedName, newTool
        end
    end
    return nil, nil
end

local function UnequipTool()
    if not Player.Character then return end
    local tool = Player.Character:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return end
    pcall(function()
        tool.Parent = backpack
    end)
end

local function GetSheckles()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return 0 end
    local sheckles = leaderstats:FindFirstChild("Sheckles")
    return sheckles and sheckles.Value or 0
end

local function IsNight()
    local nightBool = ReplicatedStorage:FindFirstChild("Night")
    if nightBool then return nightBool.Value == true end
    local clock = game:GetService("Lighting").ClockTime
    return clock >= 18 or clock < 6
end

local function GetStockFolder(shopType)
    local success, folder = pcall(function()
        local stock = ReplicatedStorage:WaitForChild("StockValues", 5)
        local shop = stock:WaitForChild(shopType, 5)
        return shop:WaitForChild("Items", 5)
    end)
    return success and folder or nil
end

local function GetStock(shopType, itemName)
    local folder = GetStockFolder(shopType)
    if not folder then return -1 end
    local item = folder:FindFirstChild(itemName)
    if not item then return 0 end
    if item:IsA("ValueBase") then
        return item.Value or 0
    end
    return 0
end

local function GetBackpackItems()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return {} end
    local items = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(items, {
                Name = tool.Name,
                Instance = tool,
                Type = tool:GetAttribute("ItemType") or "Unknown",
                FruitName = tool:GetAttribute("FruitName"),
                SeedName = tool:GetAttribute("SeedTool"),
                Mutation = tool:GetAttribute("Mutation"),
                Size = tool:GetAttribute("Size") or 1
            })
        end
    end
    return items
end

local function GetEquippedTool()
    local char = GetCharacter()
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local function GetPlantInfo(plant)
    if not plant then return nil end
    return {
        Name = plant:GetAttribute("SeedName") or plant.Name,
        Growth = plant:GetAttribute("Growth") or 0,
        Mutation = plant:GetAttribute("Mutation"),
        Age = plant:GetAttribute("Age") or 0,
        Size = plant:GetAttribute("Size") or 1,
        IsRipe = (plant:GetAttribute("Growth") or 0) >= 1,
        Owner = plant:GetAttribute("Owner"),
        Instance = plant
    }
end

local function CalculateFruitValue(baseValue, size, mutation)
    local mult = mutation and MutationMults[mutation] or 1
    return math.floor((baseValue or 0) * (size or 1) ^ 2.65 * mult)
end

local function FormatNumber(num)
    if num >= 1e12 then return string.format("%.1fT", num / 1e12)
    elseif num >= 1e9 then return string.format("%.1fB", num / 1e9)
    elseif num >= 1e6 then return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then return string.format("%.1fK", num / 1e3)
    else return tostring(num) end
end

local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    if hours > 0 then return string.format("%dh %dm %ds", hours, mins, secs)
    elseif mins > 0 then return string.format("%dm %ds", mins, secs)
    else return string.format("%ds", secs) end
end

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local FarmingTab = Window:Tab({ Title = "Farming", Icon = "wheat" })
local AutoBuyTab = Window:Tab({ Title = "Auto Buy", Icon = "shopping-cart" })
local EventsTab = Window:Tab({ Title = "Events", Icon = "zap" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local StatsTab = Window:Tab({ Title = "Stats", Icon = "bar-chart" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({Title="Success", Content="Discord invite copied to clipboard!"})
    end
})

MainTab:Section({ Title = "Movement", Icon = "move" })

MainTab:Toggle({
    Title = "Speed Hack",
    Desc = "Modify your walk speed",
    Icon = "zap",
    Value = false,
    Flag = "SpeedHack",
    Callback = function(state)
        States.SpeedHack = state
        if state then
            Threads.SpeedHack = task.spawn(function()
                while States.SpeedHack do
                    local char, hum = GetCharacter()
                    if hum and hum.Parent then
                        hum.WalkSpeed = States.SpeedValue or 32
                    end
                    task.wait(0.1)
                end
            end)
        else
            KillThread("SpeedHack")
            local char, hum = GetCharacter()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

MainTab:Slider({
    Title = "Speed Value",
    Icon = "gauge",
    Value = { Min = 16, Max = 120, Default = 32 },
    Step = 1,
    Flag = "SpeedValue",
    Callback = function(value)
        States.SpeedValue = value
    end,
})

MainTab:Toggle({
    Title = "Jump Power",
    Desc = "Modify your jump height",
    Icon = "arrow-up",
    Value = false,
    Flag = "JumpPower",
    Callback = function(state)
        States.JumpPower = state
        if state then
            Threads.JumpPower = task.spawn(function()
                while States.JumpPower do
                    local char, hum = GetCharacter()
                    if hum and hum.Parent then
                        hum.JumpPower = States.JumpValue or 75
                    end
                    task.wait(0.1)
                end
            end)
        else
            KillThread("JumpPower")
            local char, hum = GetCharacter()
            if hum then hum.JumpPower = 50 end
        end
    end,
})

MainTab:Slider({
    Title = "Jump Value",
    Icon = "arrow-up-circle",
    Value = { Min = 50, Max = 200, Default = 75 },
    Step = 1,
    Flag = "JumpValue",
    Callback = function(value)
        States.JumpValue = value
    end,
})

MainTab:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents being kicked for inactivity",
    Icon = "shield",
    Value = false,
    Flag = "AntiAFK",
    Callback = function(state)
        States.AntiAFK = state
        if state then
            Threads.AntiAFK = task.spawn(function()
                while States.AntiAFK do
                    VirtualInputManager:SendMouseMoveEvent(0, 0, game)
                    task.wait(60)
                end
            end)
        else
            KillThread("AntiAFK")
        end
    end,
})

MainTab:Section({ Title = "Teleport", Icon = "map-pin" })

MainTab:Button({
    Title = "Teleport to Shop",
    Desc = "Instant teleport to the seed shop",
    Icon = "store",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local shop = Workspace:FindFirstChild("Shop") or Workspace:FindFirstChild("Store")
            if shop then
                hrp.CFrame = shop:GetPivot() + Vector3.new(0, 5, 0)
                Notify("Teleported", "Arrived at the shop", "map-pin")
            else
                hrp.CFrame = CFrame.new(0, 50, 0)
                Notify("Teleported", "Arrived at spawn area", "map-pin")
            end
        end
    end,
})

MainTab:Button({
    Title = "Teleport to Garden",
    Desc = "Instant teleport to your garden plot",
    Icon = "flower-2",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local plot = GetMyPlot()
            if plot then
                local spawnPoint = plot:FindFirstChild("SpawnPoint") or plot:FindFirstChildWhichIsA("BasePart")
                if spawnPoint then
                    hrp.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
                    Notify("Teleported", "Arrived at garden", "map-pin")
                else
                    Notify("Error", "No spawn point found", "x")
                end
            else
                Notify("Error", "No garden found", "x")
            end
        end
    end,
})

MainTab:Button({
    Title = "Teleport to Sell Point",
    Desc = "Instant teleport to sell your fruits",
    Icon = "coins",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local sell = Workspace:FindFirstChild("Sell") or Workspace:FindFirstChild("SellPoint")
            if sell then
                hrp.CFrame = sell:GetPivot() + Vector3.new(0, 5, 0)
                Notify("Teleported", "Arrived at sell point", "map-pin")
            else
                hrp.CFrame = CFrame.new(50, 50, 50)
                Notify("Teleported", "Arrived at default sell area", "map-pin")
            end
        end
    end,
})

FarmingTab:Section({ Title = "Auto Harvest", Icon = "scissors" })

FarmingTab:Toggle({
    Title = "Auto Harvest",
    Desc = "Automatically harvests all ready crops",
    Icon = "wheat",
    Value = false,
    Flag = "AutoHarvest",
    Callback = function(state)
        States.AutoHarvest = state
        if state then
            Threads.AutoHarvest = task.spawn(function()
                while States.AutoHarvest do
                    local plot = GetMyPlot()
                    if plot then
                        local plants = GetPlants(plot)
                        for _, plant in ipairs(plants) do
                            if not States.AutoHarvest then break end
                            if IsPlantHarvestable(plant) then
                                local plantId = plant:GetAttribute("PlantId")
                                local fruits = GetFruits(plant)
                                if #fruits > 0 then
                                    for _, fruit in ipairs(fruits) do
                                        if not States.AutoHarvest then break end
                                        FireRemote("Garden.CollectFruit", plantId, fruit:GetAttribute("FruitId") or "")
                                        task.wait(States.FarmDelay or 0.1)
                                    end
                                else
                                    FireRemote("Garden.CollectFruit", plantId, "")
                                    task.wait(States.FarmDelay or 0.1)
                                end
                            end
                        end
                    end
                    task.wait(States.FarmDelay or 0.5)
                end
            end)
        else
            KillThread("AutoHarvest")
        end
    end,
})

FarmingTab:Toggle({
    Title = "Auto Plant",
    Desc = "Automatically plants seeds in empty plots",
    Icon = "sprout",
    Value = false,
    Flag = "AutoPlant",
    Callback = function(state)
        States.AutoPlant = state
        if state then
            Threads.AutoPlant = task.spawn(function()
                while States.AutoPlant do
                    local plot = GetMyPlot()
                    if plot then
                        local spots = FindEmptySpots(plot)
                        if #spots > 0 then
                            local seedName, tool = EquipSeed(States.PreferSeed)
                            if seedName and tool then
                                for _, pos in ipairs(spots) do
                                    if not States.AutoPlant then break end
                                    local currentSeed, currentTool = GetEquippedSeed()
                                    if not currentSeed then
                                        seedName, tool = EquipSeed(States.PreferSeed)
                                        if not seedName then break end
                                        currentTool = tool
                                    end
                                    FireRemote("Plant.PlantSeed", pos, seedName, currentTool or tool)
                                    task.wait(States.FarmDelay or 0.2)
                                end
                                UnequipTool()
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoPlant")
            UnequipTool()
        end
    end,
})

FarmingTab:Slider({
    Title = "Grid Spacing",
    Desc = "Spacing between plants",
    Icon = "layout-grid",
    Value = { Min = 2, Max = 8, Default = 3 },
    Step = 0.5,
    Flag = "GridSpacing",
    Callback = function(value)
        States.GridSpacing = value
    end,
})

FarmingTab:Dropdown({
    Title = "Prefer Seed",
    Desc = "Seed to prioritize when planting",
    Icon = "list",
    Values = SeedList,
    Value = SeedList[1],
    Multi = false,
    Flag = "PreferSeed",
    Callback = function(value)
        States.PreferSeed = value
    end,
})

FarmingTab:Toggle({
    Title = "Auto Water",
    Desc = "Automatically waters all plants",
    Icon = "droplets",
    Value = false,
    Flag = "AutoWater",
    Callback = function(state)
        States.AutoWater = state
        if state then
            Threads.AutoWater = task.spawn(function()
                while States.AutoWater do
                    local plot = GetMyPlot()
                    if plot then
                        local plants = GetPlants(plot)
                        for _, plant in ipairs(plants) do
                            if not States.AutoWater then break end
                            local part = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
                            if part then
                                FireRemote("WateringCan.UseWateringCan", part.Position)
                                task.wait(States.FarmDelay or 0.15)
                            end
                        end
                    end
                    task.wait(States.FarmDelay or 1)
                end
            end)
        else
            KillThread("AutoWater")
        end
    end,
})

FarmingTab:Section({ Title = "Smart Farming", Icon = "brain" })

FarmingTab:Toggle({
    Title = "Smart Farm Loop",
    Desc = "Auto harvest, plant, and water in sequence",
    Icon = "repeat",
    Value = false,
    Flag = "SmartFarm",
    Callback = function(state)
        States.SmartFarm = state
        if state then
            Threads.SmartFarm = task.spawn(function()
                while States.SmartFarm do
                    local plot = GetMyPlot()
                    if plot then
                        local plants = GetPlants(plot)
                        for _, plant in ipairs(plants) do
                            if not States.SmartFarm then break end
                            if IsPlantHarvestable(plant) then
                                local plantId = plant:GetAttribute("PlantId")
                                local fruits = GetFruits(plant)
                                if #fruits > 0 then
                                    for _, fruit in ipairs(fruits) do
                                        if not States.SmartFarm then break end
                                        FireRemote("Garden.CollectFruit", plantId, fruit:GetAttribute("FruitId") or "")
                                        task.wait(States.FarmDelay or 0.1)
                                    end
                                else
                                    FireRemote("Garden.CollectFruit", plantId, "")
                                    task.wait(States.FarmDelay or 0.1)
                                end
                            end
                        end
                        local spots = FindEmptySpots(plot)
                        if #spots > 0 then
                            local seedName, tool = EquipSeed(States.PreferSeed)
                            if seedName and tool then
                                for _, pos in ipairs(spots) do
                                    if not States.SmartFarm then break end
                                    local currentSeed, currentTool = GetEquippedSeed()
                                    if not currentSeed then
                                        seedName, tool = EquipSeed(States.PreferSeed)
                                        if not seedName then break end
                                        currentTool = tool
                                    end
                                    FireRemote("Plant.PlantSeed", pos, seedName, currentTool or tool)
                                    task.wait(States.FarmDelay or 0.2)
                                end
                                UnequipTool()
                            end
                        end
                        for _, plant in ipairs(plants) do
                            if not States.SmartFarm then break end
                            local part = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
                            if part then
                                FireRemote("WateringCan.UseWateringCan", part.Position)
                                task.wait(States.FarmDelay or 0.15)
                            end
                        end
                    end
                    task.wait(States.FarmDelay or 1)
                end
            end)
        else
            KillThread("SmartFarm")
            UnequipTool()
        end
    end,
})

FarmingTab:Slider({
    Title = "Farm Delay",
    Desc = "Delay between farm actions (ms)",
    Icon = "clock",
    Value = { Min = 50, Max = 1000, Default = 100 },
    Step = 10,
    Flag = "FarmDelay",
    Callback = function(value)
        States.FarmDelay = value / 1000
    end,
})

AutoBuyTab:Section({ Title = "Seeds", Icon = "package" })

AutoBuyTab:Toggle({
    Title = "Auto Buy All Seeds",
    Desc = "Automatically purchases every seed type",
    Icon = "shopping-bag",
    Value = false,
    Flag = "AutoBuySeeds",
    Callback = function(state)
        States.AutoBuySeeds = state
        if state then
            Threads.AutoBuySeeds = task.spawn(function()
                while States.AutoBuySeeds do
                    for _, name in ipairs(SeedList) do
                        if not States.AutoBuySeeds then break end
                        local price = SeedPrices[name] or 0
                        if price > 0 and GetSheckles() < price then
                        else
                            local stock = GetStock("SeedShop", name)
                            if stock > 0 then
                                FireRemote("SeedShop.PurchaseSeed", name)
                            end
                        end
                        task.wait(0.2)
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoBuySeeds")
        end
    end,
})

AutoBuyTab:Dropdown({
    Title = "Select Seed to Buy",
    Desc = "Choose specific seed to auto-buy",
    Icon = "list",
    Values = SeedList,
    Value = SeedList[1],
    Multi = false,
    Flag = "SelectedSeed",
    Callback = function(value)
        States.SelectedSeed = value
    end,
})

AutoBuyTab:Toggle({
    Title = "Auto Buy Selected Seed",
    Desc = "Buys only the selected seed type",
    Icon = "target",
    Value = false,
    Flag = "AutoBuySelectedSeed",
    Callback = function(state)
        States.AutoBuySelectedSeed = state
        if state then
            Threads.AutoBuySelectedSeed = task.spawn(function()
                while States.AutoBuySelectedSeed do
                    local selected = States.SelectedSeed or SeedList[1]
                    local price = SeedPrices[selected] or 0
                    if price > 0 and GetSheckles() < price then
                    else
                        local stock = GetStock("SeedShop", selected)
                        if stock > 0 then
                            FireRemote("SeedShop.PurchaseSeed", selected)
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoBuySelectedSeed")
        end
    end,
})

AutoBuyTab:Section({ Title = "Gear", Icon = "wrench" })

AutoBuyTab:Toggle({
    Title = "Auto Buy All Gear",
    Desc = "Automatically purchases every gear type",
    Icon = "tool",
    Value = false,
    Flag = "AutoBuyGear",
    Callback = function(state)
        States.AutoBuyGear = state
        if state then
            Threads.AutoBuyGear = task.spawn(function()
                while States.AutoBuyGear do
                    for _, name in ipairs(GearList) do
                        if not States.AutoBuyGear then break end
                        local price = GearPrices[name] or 0
                        if price > 0 and GetSheckles() < price then
                        else
                            local stock = GetStock("GearShop", name)
                            if stock > 0 then
                                FireRemote("GearShop.PurchaseGear", name)
                            end
                        end
                        task.wait(0.2)
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoBuyGear")
        end
    end,
})

AutoBuyTab:Dropdown({
    Title = "Select Gear to Buy",
    Desc = "Choose specific gear to auto-buy",
    Icon = "list",
    Values = GearList,
    Value = GearList[1],
    Multi = false,
    Flag = "SelectedGear",
    Callback = function(value)
        States.SelectedGear = value
    end,
})

AutoBuyTab:Toggle({
    Title = "Auto Buy Selected Gear",
    Desc = "Buys only the selected gear type",
    Icon = "target",
    Value = false,
    Flag = "AutoBuySelectedGear",
    Callback = function(state)
        States.AutoBuySelectedGear = state
        if state then
            Threads.AutoBuySelectedGear = task.spawn(function()
                while States.AutoBuySelectedGear do
                    local selected = States.SelectedGear or GearList[1]
                    local price = GearPrices[selected] or 0
                    if price > 0 and GetSheckles() < price then
                    else
                        local stock = GetStock("GearShop", selected)
                        if stock > 0 then
                            FireRemote("GearShop.PurchaseGear", selected)
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoBuySelectedGear")
        end
    end,
})

AutoBuyTab:Section({ Title = "Selling", Icon = "banknote" })

AutoBuyTab:Toggle({
    Title = "Auto Sell All Fruits",
    Desc = "Automatically sells all fruits in inventory",
    Icon = "coins",
    Value = false,
    Flag = "AutoSell",
    Callback = function(state)
        States.AutoSell = state
        if state then
            Threads.AutoSell = task.spawn(function()
                while States.AutoSell do
                    FireRemote("NPCS.SellAll")
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoSell")
        end
    end,
})

AutoBuyTab:Toggle({
    Title = "Auto Sell Specific Fruit",
    Desc = "Sells only selected fruit type",
    Icon = "filter",
    Value = false,
    Flag = "AutoSellSpecific",
    Callback = function(state)
        States.AutoSellSpecific = state
        if state then
            Threads.AutoSellSpecific = task.spawn(function()
                while States.AutoSellSpecific do
                    local selected = States.SellFruitType or FruitList[1]
                    FireRemote("NPCS.SellFruit", selected)
                    task.wait(0.5)
                end
            end)
        else
            KillThread("AutoSellSpecific")
        end
    end,
})

AutoBuyTab:Dropdown({
    Title = "Fruit to Sell",
    Values = FruitList,
    Value = FruitList[1],
    Multi = false,
    Flag = "SellFruitType",
    Callback = function(value)
        States.SellFruitType = value
    end,
})

AutoBuyTab:Section({ Title = "Inventory", Icon = "backpack" })

AutoBuyTab:Toggle({
    Title = "Inventory Optimizer",
    Desc = "Auto favorite, promote, and drop items",
    Icon = "package-check",
    Value = false,
    Flag = "InventoryOptimizer",
    Callback = function(state)
        States.InventoryOptimizer = state
        if state then
            Threads.InventoryOptimizer = task.spawn(function()
                while States.InventoryOptimizer do
                    local items = GetBackpackItems()
                    for _, item in ipairs(items) do
                        if not States.InventoryOptimizer then break end
                        if item.FruitName then
                            local mutation = item.Mutation or ""
                            local size = item.Size or 1
                            local base = BaseValues[item.FruitName] or 0
                            local mult = mutation ~= "" and MutationMults[mutation] or 1
                            local value = base * (size ^ 2.65) * mult
                            if value >= (States.FavoriteThreshold or 500) then
                                FireRemote("Backpack.SetFruitFavorite", item.Name, true)
                            end
                            FireRemote("Backpack.PromoteFruit", item.Name)
                            if States.DropThreshold and States.DropThreshold > 0 and value < States.DropThreshold then
                                if item.Type ~= "SeedTool" and item.Type ~= "WateringCan" and item.Type ~= "Sprinkler" and not item.Name:match("Seed") then
                                    FireRemote("DroppedItem.RequestDrop", item.Name, 1)
                                end
                            end
                        end
                    end
                    task.wait(States.InventoryCheckInterval or 10)
                end
            end)
        else
            KillThread("InventoryOptimizer")
        end
    end,
})

AutoBuyTab:Slider({
    Title = "Favorite Threshold",
    Desc = "Minimum value to auto-favorite",
    Icon = "star",
    Value = { Min = 0, Max = 10000, Default = 500 },
    Step = 100,
    Flag = "FavoriteThreshold",
    Callback = function(value)
        States.FavoriteThreshold = value
    end,
})

AutoBuyTab:Slider({
    Title = "Drop Threshold",
    Desc = "Maximum value to auto-drop",
    Icon = "trash-2",
    Value = { Min = 0, Max = 1000, Default = 5 },
    Step = 5,
    Flag = "DropThreshold",
    Callback = function(value)
        States.DropThreshold = value
    end,
})

AutoBuyTab:Slider({
    Title = "Check Interval",
    Desc = "Seconds between inventory checks",
    Icon = "clock",
    Value = { Min = 5, Max = 60, Default = 10 },
    Step = 5,
    Flag = "InventoryCheckInterval",
    Callback = function(value)
        States.InventoryCheckInterval = value
    end,
})

EventsTab:Section({ Title = "Mutations", Icon = "dna" })

EventsTab:Toggle({
    Title = "Mutation Tracker",
    Desc = "Track and alert rare mutations",
    Icon = "eye",
    Value = false,
    Flag = "MutationTracker",
    Callback = function(state)
        States.MutationTracker = state
        if state then
            local mutationLog = {}
            local alertMutations = States.AlertMutations or {"Rainbow", "Starstruck", "Gold", "Frozen", "Electric", "Bloodlit", "Chained"}
            local conn1 = OnRemote("Garden.PlantMutationUpdated", function(plantId, mutation)
                if mutation and mutation ~= "" then
                    table.insert(mutationLog, { source = "plant", plantId = plantId, mutation = mutation, time = os.time() })
                    if #mutationLog > 500 then table.remove(mutationLog, 1) end
                    if table.find(alertMutations, mutation) then
                        Notify("Mutation Alert", "Plant " .. plantId .. " got " .. mutation .. "!", "sparkles")
                    end
                end
            end)
            local conn2 = OnRemote("Garden.FruitMutationUpdated", function(plantId, fruitId, mutation)
                if mutation and mutation ~= "" then
                    table.insert(mutationLog, { source = "fruit", plantId = plantId, mutation = mutation, time = os.time() })
                    if #mutationLog > 500 then table.remove(mutationLog, 1) end
                    if table.find(alertMutations, mutation) then
                        Notify("Mutation Alert", "Fruit got " .. mutation .. "!", "sparkles")
                    end
                end
            end)
            Threads.MutationTracker = task.spawn(function()
                while States.MutationTracker do
                    local plot = GetMyPlot()
                    if plot then
                        local plants = GetPlants(plot)
                        for _, plant in ipairs(plants) do
                            if not States.MutationTracker then break end
                            local info = GetPlantInfo(plant)
                            if info and info.Mutation and info.Mutation ~= "" then
                                if table.find(alertMutations, info.Mutation) then
                                    Notify("Mutation Detected", info.Name .. " has " .. info.Mutation, "sparkles")
                                end
                            end
                        end
                    end
                    task.wait(States.MutationScanInterval or 3)
                end
            end)
        else
            KillThread("MutationTracker")
        end
    end,
})

EventsTab:Slider({
    Title = "Scan Interval",
    Desc = "Seconds between mutation scans",
    Icon = "clock",
    Value = { Min = 1, Max = 10, Default = 3 },
    Step = 1,
    Flag = "MutationScanInterval",
    Callback = function(value)
        States.MutationScanInterval = value
    end,
})

EventsTab:Section({ Title = "Weather", Icon = "cloud" })

EventsTab:Toggle({
    Title = "Weather Bot",
    Desc = "Track weather events and phases",
    Icon = "cloud-sun",
    Value = false,
    Flag = "WeatherBot",
    Callback = function(state)
        States.WeatherBot = state
        if state then
            local weatherEvents = {
                "WeatherEffects.BloodmoonBeam", "WeatherEffects.RainbowStart", "WeatherEffects.RainbowEnd",
                "WeatherEffects.GoldMoonStrike", "WeatherEffects.RainbowMoonStrike", "WeatherEffects.BlizzardStart",
                "WeatherEffects.BlizzardEnd", "WeatherEffects.ShootingStar", "WeatherEffects.ChainPull"
            }
            for _, ev in ipairs(weatherEvents) do
                OnRemote(ev, function(...)
                    local short = ev:match("WeatherEffects%.(.+)")
                    if short then
                        Notify("Weather Event", short .. " triggered!", "cloud-lightning")
                    end
                end)
            end
            local nightBool = ReplicatedStorage:FindFirstChild("Night")
            if nightBool then
                nightBool.Changed:Connect(function(value)
                    if value then
                        Notify("Night Started", "Night cycle has begun", "moon")
                    else
                        Notify("Day Started", "Day cycle has begun", "sun")
                    end
                end)
            end
            Threads.WeatherBot = task.spawn(function()
                while States.WeatherBot do
                    local weatherFolder = Workspace:FindFirstChild("Weather") or Workspace:FindFirstChild("WeatherEffects")
                    if weatherFolder then
                        for _, child in ipairs(weatherFolder:GetChildren()) do
                            if child:IsA("BoolValue") and child.Value then
                                Notify("Weather", "Current: " .. child.Name, "cloud")
                            end
                        end
                    end
                    task.wait(States.WeatherPollInterval or 5)
                end
            end)
        else
            KillThread("WeatherBot")
        end
    end,
})

EventsTab:Slider({
    Title = "Poll Interval",
    Desc = "Seconds between weather checks",
    Icon = "clock",
    Value = { Min = 1, Max = 15, Default = 5 },
    Step = 1,
    Flag = "WeatherPollInterval",
    Callback = function(value)
        States.WeatherPollInterval = value
    end,
})

EventsTab:Section({ Title = "Steal Bot", Icon = "moon" })

EventsTab:Toggle({
    Title = "Steal Bot",
    Desc = "Auto steal fruits from other gardens at night",
    Icon = "moon",
    Value = false,
    Flag = "StealBot",
    Callback = function(state)
        States.StealBot = state
        if state then
            Threads.StealBot = task.spawn(function()
                while States.StealBot do
                    if IsNight() then
                        local myPlotId = Player:GetAttribute("PlotId")
                        local gardens = Workspace:FindFirstChild("Gardens")
                        if gardens then
                            for _, garden in ipairs(gardens:GetChildren()) do
                                if not States.StealBot then break end
                                local plotId = tonumber(garden.Name:match("Plot(%d+)"))
                                if plotId and plotId ~= myPlotId then
                                    local plantsFolder = garden:FindFirstChild("Plants")
                                    if plantsFolder then
                                        for _, plant in ipairs(plantsFolder:GetChildren()) do
                                            if not States.StealBot then break end
                                            local fruitsFolder = plant:FindFirstChild("Fruits")
                                            if fruitsFolder then
                                                for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                                                    if not States.StealBot then break end
                                                    local prompt = fruit:FindFirstChild("StealPrompt", true)
                                                    if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                                        local plantId = plant:GetAttribute("PlantId")
                                                        local fruitId = fruit:GetAttribute("FruitId")
                                                        local owner = plant:GetAttribute("Owner")
                                                        FireRemote("Steal.BeginSteal", owner, plantId, fruitId)
                                                        task.wait(0.5)
                                                        if Player:GetAttribute("CarryingStolenFruit") then
                                                            FireRemote("Steal.CompleteSteal")
                                                            Notify("Stolen", "Successfully stole a fruit!", "moon")
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(States.StealInterval or 1.5)
                end
            end)
        else
            KillThread("StealBot")
        end
    end,
})

EventsTab:Slider({
    Title = "Steal Interval",
    Desc = "Seconds between steal attempts",
    Icon = "clock",
    Value = { Min = 0.5, Max = 5, Default = 1.5 },
    Step = 0.5,
    Flag = "StealInterval",
    Callback = function(value)
        States.StealInterval = value
    end,
})

EventsTab:Slider({
    Title = "Max Steals Per Night",
    Desc = "Maximum steal attempts per night",
    Icon = "shield",
    Value = { Min = 5, Max = 50, Default = 20 },
    Step = 5,
    Flag = "MaxStealAttempts",
    Callback = function(value)
        States.MaxStealAttempts = value
    end,
})

EventsTab:Slider({
    Title = "Min Fruit Value",
    Desc = "Minimum estimated value to steal",
    Icon = "coins",
    Value = { Min = 0, Max = 10000, Default = 100 },
    Step = 100,
    Flag = "MinFruitValue",
    Callback = function(value)
        States.MinFruitValue = value
    end,
})

EventsTab:Section({ Title = "Pets",  Icon = "cat" })

EventsTab:Toggle({
    Title = "Auto Hatch Pet",
    Desc = "Automatically hatch eggs from backpack",
    Icon = "egg",
    Value = false,
    Flag = "AutoBuyPet",
    Callback = function(state)
        States.AutoBuyPet = state
        if state then
            Threads.AutoBuyPet = task.spawn(function()
                while States.AutoBuyPet do
                    local backpack = Player:FindFirstChild("Backpack")
                    if backpack then
                        local eggs = {}
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                local eggName = tool:GetAttribute("Egg")
                                if eggName then
                                    table.insert(eggs, { tool = tool, eggName = eggName })
                                end
                            end
                        end
                        if #eggs > 0 then
                            FireRemote("Egg.OpenEgg", eggs[1].eggName)
                            task.wait(0.5)
                            local result = nil
                            for i = 1, 50 do
                                task.wait(0.1)
                            end
                            if States.PetAutoSellUnwanted then
                                local minRarity = States.PetMinRarity or "Rare"
                                local minRank = RarityRank[minRarity] or 3
                            end
                        end
                    end
                    task.wait(States.PetHatchInterval or 2)
                end
            end)
        else
            KillThread("AutoBuyPet")
        end
    end,
})

EventsTab:Slider({
    Title = "Hatch Interval",
    Desc = "Seconds between hatches",
    Icon = "clock",
    Value = { Min = 1, Max = 10, Default = 2 },
    Step = 0.5,
    Flag = "PetHatchInterval",
    Callback = function(value)
        States.PetHatchInterval = value
    end,
})

EventsTab:Dropdown({
    Title = "Min Rarity",
    Desc = "Minimum rarity to keep",
    Icon = "star",
    Values = {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Super"},
    Value = "Rare",
    Multi = false,
    Flag = "PetMinRarity",
    Callback = function(value)
        States.PetMinRarity = value
    end,
})

EventsTab:Toggle({
    Title = "Sell Unwanted",
    Desc = "Sell pets below min rarity",
    Icon = "trash-2",
    Value = false,
    Flag = "PetAutoSell",
    Callback = function(state)
        States.PetAutoSellUnwanted = state
    end,
})

MiscTab:Section({ Title = "Server", Icon = "server" })

MiscTab:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the current server",
    Icon = "refresh-cw",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, Player)
    end,
})

MiscTab:Button({
    Title = "Server Hop",
    Desc = "Join a different server",
    Icon = "shuffle",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if success then
            local servers = HttpService:JSONDecode(result)
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                    break
                end
            end
        else
            Notify("Error", "Failed to get server list", "x")
        end
    end,
})

MiscTab:Button({
    Title = "Lowest Player Server",
    Desc = "Join server with fewest players",
    Icon = "users",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if success then
            local servers = HttpService:JSONDecode(result)
            local lowest = nil
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId then
                    if not lowest or server.playing < lowest.playing then
                        lowest = server
                    end
                end
            end
            if lowest then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, lowest.id, Player)
            end
        else
            Notify("Error", "Failed to get server list", "x")
        end
    end,
})

MiscTab:Section({ Title = "Utility", Icon = "hammer" })

MiscTab:Button({
    Title = "Reset Character",
    Desc = "Respawn your character",
    Icon = "rotate-ccw",
    Callback = function()
        local char = Player.Character
        if char then
            char:BreakJoints()
        end
    end,
})

MiscTab:Button({
    Title = "Destroy GUI",
    Desc = "Close Eternal Hub completely",
    Icon = "trash-2",
    Callback = function()
        for name, thread in pairs(Threads) do
            if thread then task.cancel(thread) end
        end
        Window:Destroy()
    end,
})

StatsTab:Section({ Title = "Information", Icon = "info" })

local StatsLabel = StatsTab:Paragraph({
    Title = "Loading stats...",
    Desc = "",
})

local SessionStart = os.clock()
local StartSheckles = GetSheckles()

Threads.StatsUpdater = task.spawn(function()
    while true do
        local char, hum = GetCharacter()
        local inventoryCount = Inventory and #Inventory:GetChildren() or 0
        local gardenCount = 0
        local plot = GetMyPlot()
        if plot then
            local plants = plot:FindFirstChild("Plants")
            if plants then
                gardenCount = #plants:GetChildren()
            end
        end
        local elapsed = os.clock() - SessionStart
        local profit = GetSheckles() - StartSheckles
        local activeModules = 0
        for _, running in pairs(States) do
            if running then activeModules = activeModules + 1 end
        end

        local statsText = string.format([[
Player: %s
Health: %d/%d
Walk Speed: %d
Jump Power: %d
Inventory Items: %d
Garden Plants: %d
Server Players: %d/%d

Session: %s
Profit: %s%s
Active Modules: %d]],
            Player.DisplayName,
            hum and hum.Parent and math.floor(hum.Health) or 0,
            hum and hum.Parent and math.floor(hum.MaxHealth) or 0,
            hum and hum.Parent and math.floor(hum.WalkSpeed) or 0,
            hum and hum.Parent and math.floor(hum.JumpPower) or 0,
            inventoryCount,
            gardenCount,
            #Players:GetPlayers(),
            Players.MaxPlayers,
            FormatTime(elapsed),
            profit >= 0 and "+" or "",
            FormatNumber(profit),
            activeModules
        )

        StatsLabel:SetTitle("Player Stats")
        StatsLabel:SetDesc(statsText)

        task.wait(1)
    end
end)

StatsTab:Section({ Title = "Inventory", Icon = "backpack" })

StatsTab:Button({
    Title = "Refresh Inventory",
    Desc = "Update inventory display",
    Icon = "refresh-cw",
    Callback = function()
        local items = {}
        if Inventory then
            for _, item in ipairs(Inventory:GetChildren()) do
                table.insert(items, item.Name)
            end
        end
        if #items > 0 then
            Notify("Inventory", table.concat(items, ", "), "backpack")
        else
            Notify("Inventory", "Your inventory is empty", "backpack")
        end
    end,
})

StatsTab:Button({
    Title = "Clear Inventory Display",
    Desc = "Clear any inventory highlights",
    Icon = "x",
    Callback = function()
        Notify("Inventory", "Display cleared", "check")
    end,
})

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    if States.SpeedHack then
        Humanoid.WalkSpeed = States.SpeedValue or 32
    end
    if States.JumpPower then
        Humanoid.JumpPower = States.JumpValue or 75
    end
end)

local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.delay(2, function()
    Notify("IndraHub", "Loaded successfully! Press RightShift to toggle.", "infinity", 5)
end)
