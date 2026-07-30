local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Global Check to prevent multi-execution & disconnect old listeners
local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubGreedyGrowersRunning") then 
    setGlobal("IndraHubGreedyGrowersRunning", false)
    task.wait(0.2)
end
setGlobal("IndraHubGreedyGrowersRunning", true)
setGlobal("IndraHubGreedyGrowersLastHeartbeat", os.time())

-- Supervisor Watchdog Heartbeat Loop
task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubGreedyGrowersRunning") then break end
        setGlobal("IndraHubGreedyGrowersLastHeartbeat", os.time())
    end
end)

if getGlobal("IndraHubGreedyGrowersConnections") then
    for _, conn in ipairs(getGlobal("IndraHubGreedyGrowersConnections")) do
        pcall(function() conn:Disconnect() end)
    end
end
local scriptConnections = {}
setGlobal("IndraHubGreedyGrowersConnections", scriptConnections)

-- Load WindUI Library
local okWindUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not okWindUI or not WindUI then
    warn("Failed to load WindUI library")
    return
end

local GAME_NAME = "Greedy Growers"

-- Knit Services & Modules
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local SeedConfig = require(ReplicatedStorage.Shared.Info.SeedConfig)
local ExpandedRarities = require(ReplicatedStorage.Shared.Info.ExpandedRarities)
local RebirthConfig = require(ReplicatedStorage.Shared.Info.RebirthConfig)
local FertilizerConfig = require(ReplicatedStorage.Shared.Info.FertilizerConfig)
local CustomEnum = require(ReplicatedStorage.Shared.Info.CustomEnum)
local Constants = require(ReplicatedStorage.Shared.Info.Constants)
local WeatherConfig = require(ReplicatedStorage.Shared.Info.WeatherConfig)

local SeedConveyorService = Knit.GetService("SeedConveyorService")
local PlayerPlotService = Knit.GetService("PlayerPlotService")
local PlantRoundService = Knit.GetService("PlantRoundService")
local ToolService = Knit.GetService("ToolService")
local SellStandService = Knit.GetService("SellStandService")
local SellFruitsService = Knit.GetService("SellFruitsService")
local RebirthService = Knit.GetService("RebirthService")
local DataClient = Knit.GetController("DataClient")

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Greedy Growers",
    Icon = "sprout",
    Author = "IndraHub",
    Folder = "IndraHubGreedyGrowers",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

-- Tabs
local TabMain = Window:Tab({ Title = "Main", Icon = "gamepad-2" })
local TabSeeds = Window:Tab({ Title = "Seeds", Icon = "shopping-cart" })
local TabFarm = Window:Tab({ Title = "Farm", Icon = "trees" })
local TabAutomation = Window:Tab({ Title = "Automation", Icon = "refresh-cw" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Configurations
local Config = {
    -- Seeds
    AutoBuySeeds = false,
    BuyMode = "Minimum Rarity",
    BuyMinRarity = "COMMON",
    BuyMutatedOnly = false,
    BuyMaxCost = 0,
    BuyReserve = 0,
    BuyNotify = false,
    BuyActionDelay = 0.2,
    BuyLoopDelay = 0.5,

    -- Plant
    AutoPlant = false,
    PlantMode = "Any Seed",
    PlantFertilizer = "None",
    PlantDuringWeatherOnly = false,
    AutoPlantTrees = false,
    PlantNotify = false,
    PlantLoopDelay = 1.0,

    -- Harvest
    AutoHarvest = false,
    HarvestMultiplier = 2.0,
    AutoCollectDead = true,
    HarvestNotify = false,
    AutoCollectFruit = false,
    HarvestTeleport = false,
    HarvestCollectAll = false,
    HarvestActionDelay = 0.1,
    HarvestLoopDelay = 1.0,

    -- Sell
    AutoSellFruits = false,
    AutoSellAll = false,
    SellDeadTreesOnly = false,
    SellTeleport = false,
    SellMinFruits = 1,
    SellActionDelay = 0.2,
    SellLoopDelay = 2.0,

    -- Rebirth
    AutoRebirth = false,
    RebirthMaxLevel = RebirthConfig.MaxLevel,
    RebirthNotify = true,
    RebirthLoopDelay = 5.0,

    -- Movement
    WalkSpeed = 16,
    EnableWalkSpeed = false,
    JumpPower = 50,
    EnableJumpPower = false,
    Noclip = false,
    AntiAFK = true
}

local RARITY_ORDER = {
    "COMMON",
    "UNCOMMON",
    "RARE",
    "EPIC",
    "LEGENDARY",
    "MYTHIC",
    "CELESTIAL",
    "SECRET",
    "DIVINE",
}

local RARITY_INDEX = {}
local RARITY_NAMES = {}
local RARITY_NAME_TO_KEY = {}
for i, key in ipairs(RARITY_ORDER) do
    RARITY_INDEX[key] = i
    local name = ExpandedRarities[key] and ExpandedRarities[key].name or key
    RARITY_NAMES[i] = name
    RARITY_NAME_TO_KEY[name] = key
end

local SEED_NAMES = {}
local SEED_NAME_TO_KEY = {}
for key in pairs(SeedConfig.Seeds) do
    local name = SeedConfig.SeedDisplayName(key)
    SEED_NAMES[#SEED_NAMES + 1] = name
    SEED_NAME_TO_KEY[name] = key
end
table.sort(SEED_NAMES)

local FERTILIZER_NAMES = {}
for _, key in ipairs(FertilizerConfig.Order) do
    FERTILIZER_NAMES[#FERTILIZER_NAMES + 1] = key
end

local WEATHER_NAMES = {}
local WEATHER_NAME_TO_KEY = {}
for _, key in ipairs(WeatherConfig.Order) do
    local weather = WeatherConfig.Weathers[key]
    local name = weather and weather.displayName or key
    WEATHER_NAMES[#WEATHER_NAMES + 1] = name
    WEATHER_NAME_TO_KEY[name] = key
end

local wantedSeeds = {}
local wantedPlantSeeds = {}
local wantedWeathers = {}
for _, key in ipairs(WeatherConfig.Order) do
    wantedWeathers[key] = true
end

local function getData()
    return DataClient.currentData
end

local function getCoins()
    local data = getData()
    if not data or not data.Currency then
        return 0
    end
    return data.Currency[CustomEnum.CURRENCIES.COINS] or 0
end

local function hasInventorySpace()
    local data = getData()
    if not data or not data.Inventory then
        return true
    end
    for _, slot in pairs(data.Inventory.Hotbar or {}) do
        if slot and slot.empty == true then
            return true
        end
    end
    return #(data.Inventory.Storage or {}) < Constants.STORAGE_MAX_SIZE
end

local function getMyPlot()
    local field = workspace:FindFirstChild("BigField")
    local plots = field and field:FindFirstChild("PlayerPlots")
    if not plots then
        return nil
    end
    for _, plot in pairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function getRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local purchasedSpawns = {}

local function shouldBuySeed(seedType, rarity, mutation)
    if Config.BuyMutatedOnly and (mutation == nil or mutation == "") then
        return false
    end

    local seed = SeedConfig.GetSeed(seedType)
    local cost = seed and seed.plantCost or 0
    local maxCost = Config.BuyMaxCost or 0
    if maxCost > 0 and cost > maxCost then
        return false
    end
    local reserve = Config.BuyReserve or 0
    if getCoins() - cost < reserve then
        return false
    end

    local mode = Config.BuyMode
    if mode == "Buy All" then
        return true
    elseif mode == "Selected Seeds" then
        return wantedSeeds[seedType] == true
    end

    local minKey = RARITY_NAME_TO_KEY[Config.BuyMinRarity]
    local have = RARITY_INDEX[rarity]
    local want = RARITY_INDEX[minKey]
    if not have or not want then
        return false
    end
    return have >= want
end

local function doBuySeeds()
    if not hasInventorySpace() then
        return
    end

    local field = workspace:FindFirstChild("BigField")
    local folder = field and field:FindFirstChild("ConveyorSeeds")
    if not folder then
        return
    end

    for _, holder in pairs(folder:GetChildren()) do
        local spawnId = holder:GetAttribute("SpawnId")
        if spawnId and not purchasedSpawns[spawnId] then
            local seedType = holder:GetAttribute("SeedType")
            local rarity = holder:GetAttribute("Rarity")
            if seedType and rarity and shouldBuySeed(seedType, rarity, holder:GetAttribute("Mutation")) then
                purchasedSpawns[spawnId] = true
                local ok, success = SeedConveyorService:RequestPurchase(spawnId):await()
                if ok and success then
                    if Config.BuyNotify then
                        WindUI:Notify({ Title = "Buy Seed", Content = ("Purchased %s"):format(SeedConfig.SeedDisplayName(seedType)) })
                    end
                    if not hasInventorySpace() then
                        return
                    end
                end
                task.wait(Config.BuyActionDelay or 0.2)
            end
        end
    end

    for spawnId in pairs(purchasedSpawns) do
        local stillThere = false
        for _, holder in pairs(folder:GetChildren()) do
            if holder:GetAttribute("SpawnId") == spawnId then
                stillThere = true
                break
            end
        end
        if not stillThere then
            purchasedSpawns[spawnId] = nil
        end
    end
end

local activeRound = nil
local harvestedRoundId = nil

local function roundMultiplier(startTime)
    local elapsed = math.max(0, workspace:GetServerTimeNow() - startTime)
    return math.max(0, math.floor((math.exp(elapsed * 0.28) - 1) * 100) / 100)
end

local function refreshRound()
    local ok, rounds = PlantRoundService:GetActiveRounds():await()
    if not ok or type(rounds) ~= "table" then
        return
    end
    for _, round in pairs(rounds) do
        if round.userId == LocalPlayer.UserId then
            activeRound = round
            return
        end
    end
    activeRound = nil
end

local function doRoundHarvest()
    local round = activeRound
    if not round then
        return
    end

    if round.crashed then
        if Config.AutoCollectDead and harvestedRoundId ~= round.roundId then
            harvestedRoundId = round.roundId
            PlantRoundService:CollectDeadTree():await()
        end
        return
    end

    if round.stopped or harvestedRoundId == round.roundId or not Config.AutoHarvest then
        return
    end

    local target = Config.HarvestMultiplier or 2.0
    local multiplier = roundMultiplier(round.startTime)
    if multiplier < target then
        return
    end

    harvestedRoundId = round.roundId
    local ok = PlantRoundService:StopPlant():await()
    if ok and Config.HarvestNotify then
        WindUI:Notify({ Title = "Harvest", Content = ("Harvested at %.2fx Multiplier"):format(multiplier) })
    end
end

local function getActiveWeatherKey()
    local value = ReplicatedStorage:FindFirstChild("CurrentWeather")
    return value and WeatherConfig.Normalize(value.Value)
end

local function getEquippedSeedTool()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
            return tool
        end
    end
    return nil
end

local function findPlantableSlot()
    local data = getData()
    if not data or not data.Inventory then
        return nil
    end

    local mode = Config.PlantMode
    local best, bestSlot, bestHotbar = nil, nil, nil
    for _, container in ipairs({ { data.Inventory.Hotbar, true }, { data.Inventory.Storage, false } }) do
        local items, isHotbar = container[1], container[2]
        for slot, item in pairs(items or {}) do
            if item and item.itemType == "Seed" and item.seedType then
                local allowed = mode == "Any Seed" or wantedPlantSeeds[item.seedType] == true
                if allowed then
                    local seed = SeedConfig.GetSeed(item.seedType)
                    local cost = seed and seed.plantCost or 0
                    if mode == "Highest Value" then
                        if not best or cost > best then
                            best, bestSlot, bestHotbar = cost, slot, isHotbar
                        end
                    elseif mode == "Lowest Value" then
                        if not best or cost < best then
                            best, bestSlot, bestHotbar = cost, slot, isHotbar
                        end
                    else
                        return slot, isHotbar
                    end
                end
            end
        end
    end
    return bestSlot, bestHotbar
end

local function doPlant()
    if activeRound and not activeRound.stopped and not activeRound.crashed then
        return
    end

    if Config.PlantDuringWeatherOnly then
        local weather = getActiveWeatherKey()
        if not weather or not wantedWeathers[weather] then
            return
        end
    end

    local tool = getEquippedSeedTool()
    if not tool then
        local slot, isHotbar = findPlantableSlot()
        if not slot then
            return
        end
        ToolService.ToggleEquip:Fire(isHotbar, slot)
        local deadline = tick() + 3
        repeat
            task.wait(0.1)
            tool = getEquippedSeedTool()
        until tool or tick() > deadline
    end

    if not tool then
        return
    end

    local seedType = tool:GetAttribute("SeedType")
    if not seedType then
        return
    end

    local fertilizer = Config.PlantFertilizer or "None"
    local data = getData()
    if (data and data.Rebirth or 0) < 1 then
        fertilizer = "None"
    end

    local ok, started = PlantRoundService:StartRound(seedType, fertilizer):await()
    if ok and started then
        harvestedRoundId = nil
        pcall(refreshRound)
        if Config.PlantNotify then
            WindUI:Notify({ Title = "Planting", Content = ("Planted %s"):format(SeedConfig.SeedDisplayName(seedType)) })
        end
    end
end

local function isTreeItem(item)
    if not item or item.empty == true or not item.seedType then
        return false
    end
    local itemType = item.itemType
    return itemType ~= "Seed" and itemType ~= "Fruit" and itemType ~= "Decor" and itemType ~= "Axe"
end

local function findTreeSlot(dead)
    local data = getData()
    if not data or not data.Inventory then
        return nil
    end
    for _, container in ipairs({ { data.Inventory.Hotbar, true }, { data.Inventory.Storage, false } }) do
        local items, isHotbar = container[1], container[2]
        for slot, item in pairs(items or {}) do
            if isTreeItem(item) and (item.isDead == true) == dead then
                return slot, isHotbar
            end
        end
    end
    return nil
end

local function getEquippedTreeTool(dead)
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("IsTree") and (tool:GetAttribute("IsDead") == true) == dead then
            return tool
        end
    end
    return nil
end

local function equipTree(dead)
    local tool = getEquippedTreeTool(dead)
    if tool then
        return tool
    end

    local slot, isHotbar = findTreeSlot(dead)
    if not slot then
        return nil
    end

    ToolService.ToggleEquip:Fire(isHotbar, slot)
    local deadline = tick() + 3
    repeat
        task.wait(0.1)
        tool = getEquippedTreeTool(dead)
    until tool or tick() > deadline
    return tool
end

local function getDirtParts()
    local plot = getMyPlot()
    if not plot then
        return {}
    end
    local parts = {}
    for _, descendant in pairs(plot:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "Dirt" then
            parts[#parts + 1] = descendant
        end
    end
    return parts
end

local function randomDirtPoint(dirt)
    local offset = Vector3.new(
        (math.random() - 0.5) * dirt.Size.X * 0.8,
        dirt.Size.Y / 2,
        (math.random() - 0.5) * dirt.Size.Z * 0.8
    )
    return dirt.CFrame:PointToWorldSpace(offset)
end

local function doPlantTrees()
    local dirts = getDirtParts()
    if #dirts == 0 then
        return
    end

    while getGlobal("IndraHubGreedyGrowersRunning") and Config.AutoPlantTrees do
        local tool = equipTree(false)
        if not tool then
            return
        end

        local itemId = tool:GetAttribute("ItemId")
        if not itemId then
            return
        end

        local planted = false
        for _ = 1, 10 do
            local dirt = dirts[math.random(#dirts)]
            local ok, success = PlayerPlotService:PlantTree(itemId, randomDirtPoint(dirt), 0):await()
            if ok and success then
                planted = true
                break
            end
            task.wait(0.1)
        end

        if not planted then
            return
        end

        if Config.PlantNotify then
            WindUI:Notify({ Title = "Plant Tree", Content = "Planted a grown tree" })
        end
        task.wait(0.2)
    end
end

local function collectTreePrompts(tree)
    local prompts = {}
    for _, descendant in pairs(tree:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Collect" then
            prompts[#prompts + 1] = descendant
        end
    end
    return prompts
end

local function doHarvest()
    local plot = getMyPlot()
    if not plot then
        return
    end

    if Config.HarvestCollectAll then
        pcall(function()
            PlayerPlotService:CollectAllFruits():await()
        end)
    end

    local root = getRoot()
    local returnCFrame = root and root.CFrame

    for _, tree in pairs(plot:GetChildren()) do
        if tree.Name:match("^PlotTree_") then
            local prompts = collectTreePrompts(tree)
            if #prompts > 0 then
                if Config.HarvestTeleport and root then
                    local base = tree:FindFirstChild("Base")
                    if base then
                        root.CFrame = base.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.1)
                    end
                end
                for _, prompt in pairs(prompts) do
                    if not getGlobal("IndraHubGreedyGrowersRunning") or not Config.AutoCollectFruit then
                        break
                    end
                    pcall(fireproximityprompt, prompt)
                    task.wait(Config.HarvestActionDelay or 0.1)
                end
            end
        end
    end

    if Config.HarvestTeleport and root and returnCFrame then
        root.CFrame = returnCFrame
    end
end

local function countFruitTools()
    local count = 0
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    for _, container in ipairs({ character, backpack }) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("IsFruit") then
                    count += 1
                end
            end
        end
    end
    return count
end

local function doSellFruits()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not humanoid or not backpack then
        return
    end

    if countFruitTools() < (Config.SellMinFruits or 1) then
        return
    end

    if Config.SellTeleport then
        local field = workspace:FindFirstChild("BigField")
        local stand = field and field:FindFirstChild("SellStand")
        local root = getRoot()
        local pivot = stand and stand:GetPivot()
        if root and pivot then
            root.CFrame = pivot + Vector3.new(0, 5, 0)
            task.wait(0.2)
        end
    end

    while getGlobal("IndraHubGreedyGrowersRunning") and Config.AutoSellFruits do
        local fruit
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("IsFruit") then
                fruit = tool
                break
            end
        end
        if not fruit then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("IsFruit") then
                    humanoid:EquipTool(tool)
                    fruit = tool
                    break
                end
            end
        end
        if not fruit then
            break
        end
        SellFruitsService:SellFruit():await()
        task.wait(Config.SellActionDelay or 0.2)
    end
end

local function doSellAll()
    SellStandService:SellAll():await()
end

local function doSellDeadTrees()
    if Config.SellTeleport then
        local field = workspace:FindFirstChild("BigField")
        local stand = field and field:FindFirstChild("SellStand")
        local root = getRoot()
        local pivot = stand and stand:GetPivot()
        if root and pivot then
            root.CFrame = pivot + Vector3.new(0, 5, 0)
            task.wait(0.2)
        end
    end

    while getGlobal("IndraHubGreedyGrowersRunning") and Config.AutoSellAll and Config.SellDeadTreesOnly do
        local tool = equipTree(true)
        if not tool then
            return
        end
        local ok, sold = SellStandService:SellTree():await()
        if not ok or not sold then
            return
        end
        task.wait(Config.SellActionDelay or 0.2)
    end
end

local function doRebirth()
    local data = getData()
    if not data then
        return
    end

    local current = data.Rebirth or 0
    if current >= (Config.RebirthMaxLevel or RebirthConfig.MaxLevel) then
        return
    end

    local nextRebirth = RebirthConfig.GetNext(current)
    if not nextRebirth or getCoins() < nextRebirth.cost then
        return
    end

    RebirthService:DoRebirth():await()
    if Config.RebirthNotify then
        WindUI:Notify({ Title = "Rebirth", Content = ("Rebirthed to level %d"):format(current + 1) })
    end
end

-- Movement Enforcer Function
local function applyMovement()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.EnableWalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if Config.EnableJumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                pcall(function()
                    hum.JumpHeight = Config.JumpPower * 0.15
                end)
            end
        end
    end
end

-- ==========================================
-- UI DEFINITIONS (WIND UI - ENGLISH)
-- ==========================================

-- Main Tab
TabMain:Section({ Title = "Feature Overview" })

TabMain:Toggle({
    Title = "Auto Buy Seeds",
    Desc = "Automatically buys seeds passing on the conveyor belt",
    Default = false,
    Callback = function(v) Config.AutoBuySeeds = v end
})

TabMain:Toggle({
    Title = "Auto Plant",
    Desc = "Automatically plants seeds in your plot",
    Default = false,
    Callback = function(v) Config.AutoPlant = v end
})

TabMain:Toggle({
    Title = "Auto Harvest",
    Desc = "Automatically harvests plants at target multiplier",
    Default = false,
    Callback = function(v) Config.AutoHarvest = v end
})

TabMain:Toggle({
    Title = "Auto Sell Fruits",
    Desc = "Automatically sells harvested fruits at the sell stand",
    Default = false,
    Callback = function(v) Config.AutoSellFruits = v end
})

-- Seeds Tab
TabSeeds:Section({ Title = "Auto Buy Seeds Config" })

TabSeeds:Toggle({
    Title = "Enable Auto Buy Seeds",
    Default = false,
    Callback = function(v) Config.AutoBuySeeds = v end
})

TabSeeds:Dropdown({
    Title = "Buy Mode",
    Values = { "Minimum Rarity", "Selected Seeds", "Buy All" },
    Default = "Minimum Rarity",
    Callback = function(v) Config.BuyMode = v end
})

TabSeeds:Dropdown({
    Title = "Minimum Rarity",
    Values = RARITY_NAMES,
    Default = RARITY_NAMES[1],
    Callback = function(v) Config.BuyMinRarity = v end
})

TabSeeds:Toggle({
    Title = "Only Mutated Seeds",
    Desc = "Only buy seeds with mutation attributes",
    Default = false,
    Callback = function(v) Config.BuyMutatedOnly = v end
})

TabSeeds:Toggle({
    Title = "Notify On Buy",
    Default = false,
    Callback = function(v) Config.BuyNotify = v end
})

TabSeeds:Slider({
    Title = "Buy Action Delay (Seconds)",
    Value = { Min = 0.1, Max = 2.0, Default = 0.2, Step = 0.1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 0.2
        Config.BuyActionDelay = val
    end
})

-- Farm Tab
TabFarm:Section({ Title = "Planting Settings" })

TabFarm:Toggle({
    Title = "Auto Plant Seeds",
    Default = false,
    Callback = function(v) Config.AutoPlant = v end
})

TabFarm:Dropdown({
    Title = "Seed Selection Mode",
    Values = { "Any Seed", "Selected Seeds", "Highest Value", "Lowest Value" },
    Default = "Any Seed",
    Callback = function(v) Config.PlantMode = v end
})

TabFarm:Dropdown({
    Title = "Fertilizer Type",
    Values = FERTILIZER_NAMES,
    Default = "None",
    Callback = function(v) Config.PlantFertilizer = v end
})

TabFarm:Toggle({
    Title = "Auto Plant Grown Trees",
    Default = false,
    Callback = function(v) Config.AutoPlantTrees = v end
})

TabFarm:Section({ Title = "Harvesting Settings" })

TabFarm:Toggle({
    Title = "Auto Harvest",
    Default = false,
    Callback = function(v) Config.AutoHarvest = v end
})

TabFarm:Slider({
    Title = "Harvest Multiplier Target",
    Value = { Min = 1.0, Max = 10.0, Default = 2.0, Step = 0.1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 2.0
        Config.HarvestMultiplier = val
    end
})

TabFarm:Toggle({
    Title = "Auto Collect Dead Tree",
    Default = true,
    Callback = function(v) Config.AutoCollectDead = v end
})

TabFarm:Toggle({
    Title = "Auto Collect Fruit",
    Default = false,
    Callback = function(v) Config.AutoCollectFruit = v end
})

TabFarm:Toggle({
    Title = "Use Collect All",
    Default = false,
    Callback = function(v) Config.HarvestCollectAll = v end
})

TabFarm:Toggle({
    Title = "Teleport To Trees",
    Default = false,
    Callback = function(v) Config.HarvestTeleport = v end
})

TabFarm:Section({ Title = "Selling Settings" })

TabFarm:Toggle({
    Title = "Auto Sell Fruits",
    Default = false,
    Callback = function(v) Config.AutoSellFruits = v end
})

TabFarm:Toggle({
    Title = "Auto Sell All",
    Default = false,
    Callback = function(v) Config.AutoSellAll = v end
})

TabFarm:Toggle({
    Title = "Sell Dead Trees Only",
    Default = false,
    Callback = function(v) Config.SellDeadTreesOnly = v end
})

TabFarm:Toggle({
    Title = "Teleport To Sell Stand",
    Default = false,
    Callback = function(v) Config.SellTeleport = v end
})

-- Automation Tab
TabAutomation:Section({ Title = "Rebirth Settings" })

TabAutomation:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths when cash requirements are met",
    Default = false,
    Callback = function(v) Config.AutoRebirth = v end
})

TabAutomation:Slider({
    Title = "Max Rebirth Level",
    Value = { Min = 1, Max = RebirthConfig.MaxLevel, Default = RebirthConfig.MaxLevel, Step = 1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or RebirthConfig.MaxLevel
        Config.RebirthMaxLevel = val
    end
})

TabAutomation:Toggle({
    Title = "Notify On Rebirth",
    Default = true,
    Callback = function(v) Config.RebirthNotify = v end
})

-- Player Tab
TabPlayer:Section({ Title = "Movement & Character" })

TabPlayer:Toggle({
    Title = "Enable Custom WalkSpeed",
    Default = false,
    Callback = function(v)
        Config.EnableWalkSpeed = v
        if not v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        else
            applyMovement()
        end
    end
})

TabPlayer:Slider({
    Title = "WalkSpeed Amount",
    Value = { Min = 16, Max = 250, Default = 16, Step = 1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 16
        Config.WalkSpeed = val
        Config.EnableWalkSpeed = true
        applyMovement()
    end
})

TabPlayer:Toggle({
    Title = "Enable Custom JumpPower",
    Default = false,
    Callback = function(v)
        Config.EnableJumpPower = v
        if not v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = 50 
            end
        else
            applyMovement()
        end
    end
})

TabPlayer:Slider({
    Title = "JumpPower Amount",
    Value = { Min = 50, Max = 300, Default = 50, Step = 1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 50
        Config.JumpPower = val
        Config.EnableJumpPower = true
        applyMovement()
    end
})

TabPlayer:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v) Config.Noclip = v end
})

-- Settings Tab
TabSettings:Section({ Title = "Script Settings" })

TabSettings:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox from disconnecting you after 20 minutes",
    Default = true,
    Callback = function(v) Config.AntiAFK = v end
})

TabSettings:Button({
    Title = "Join Discord",
    Desc = "Copy Discord invite link to clipboard",
    Callback = function()
        setclipboard("https://discord.gg/ehKVq7pf7v")
        WindUI:Notify({ Title = "Copied", Content = "Discord invite link copied to clipboard!" })
    end
})

-- ==========================================
-- LOOPS & BACKEND LOGIC
-- ==========================================

-- Anti AFK Connection
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Character Movement & Noclip Loop (Runs every frame)
local function onStep()
    if not getGlobal("IndraHubGreedyGrowersRunning") then return end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.EnableWalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if Config.EnableJumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                pcall(function()
                    hum.JumpHeight = Config.JumpPower * 0.15
                end)
            end
        end
        
        if Config.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end

local c1 = RunService.Heartbeat:Connect(onStep)
local c2 = RunService.Stepped:Connect(onStep)
table.insert(scriptConnections, c1)
table.insert(scriptConnections, c2)

-- Auto Buy Seeds Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoBuySeeds then
            pcall(doBuySeeds)
        end
        task.wait(Config.BuyLoopDelay or 0.5)
    end
end)

-- Round Refresh Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoHarvest or Config.AutoCollectDead or Config.AutoPlant then
            pcall(refreshRound)
        else
            activeRound = nil
        end
        task.wait(0.5)
    end
end)

-- Round Harvest Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoHarvest or Config.AutoCollectDead then
            pcall(doRoundHarvest)
        end
        task.wait(0.05)
    end
end)

-- Auto Plant Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoPlant then
            pcall(doPlant)
        end
        task.wait(Config.PlantLoopDelay or 1.0)
    end
end)

-- Auto Plant Trees Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoPlantTrees then
            pcall(doPlantTrees)
        end
        task.wait(Config.PlantLoopDelay or 1.0)
    end
end)

-- Auto Collect Fruit Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoCollectFruit then
            pcall(doHarvest)
        end
        task.wait(Config.HarvestLoopDelay or 1.0)
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoSellFruits then
            pcall(doSellFruits)
        end
        if Config.AutoSellAll then
            if Config.SellDeadTreesOnly then
                pcall(doSellDeadTrees)
            else
                pcall(doSellAll)
            end
        end
        task.wait(Config.SellLoopDelay or 2.0)
    end
end)

-- Auto Rebirth Loop
task.spawn(function()
    while getGlobal("IndraHubGreedyGrowersRunning") do
        if Config.AutoRebirth then
            pcall(doRebirth)
        end
        task.wait(Config.RebirthLoopDelay or 5.0)
    end
end)

WindUI:Notify({
    Title = "IndraHub Loaded",
    Content = "Greedy Growers Script successfully loaded!",
    Duration = 4
})
