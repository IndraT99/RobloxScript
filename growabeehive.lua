--[[ IndraHub Premium - Beehive Module ]]
getgenv().IndraHubBeehiveRunning = true
getgenv().IndraHubBeehiveLastHeartbeat = tick()
task.spawn(function()
    while task.wait(1) do
        if getgenv().IndraHubBeehiveRunning then
            getgenv().IndraHubBeehiveLastHeartbeat = tick()
        end
    end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Packets = require(Packages:WaitForChild("Packets"))
local client = require(Packages:WaitForChild("DataService")).client
local Configs = ReplicatedStorage:WaitForChild("Configs")
local GameConfig = require(Configs:WaitForChild("GameConfig"))
local UpgradeConfig = require(Configs:WaitForChild("UpgradeConfig"))
local HiveLayout = require(Configs:WaitForChild("HiveLayout"))
local RarityConfig = require(Configs:WaitForChild("RarityConfig"))
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ProductionMath = require(Modules:WaitForChild("ProductionMath"))
local ToolBuilderShared = require(Modules:WaitForChild("ToolBuilderShared"))
local BeeConfig = require(Configs:WaitForChild("BeeConfig"))
local MutationConfig = require(Configs:WaitForChild("MutationConfig"))


local IndraState = {
    Unloaded = false,
    
    -- Rolls
    AutoRoll = false,
    RollDelay = 1,
    RollAutoBuy = false,
    RollBuyMode = "Buy All",
    RollMinRarity = "Common",
    RollRarities = {},
    RollMinOdds = 0,
    RollNotify = false,
    
    -- Honey
    AutoTakeHoney = false,
    AutoSellHoney = false,
    MinHoneyToSell = 1000,
    HoneyDelay = 1,
    
    -- Equip
    AutoEquipBest = false,
    EquipDelay = 2,
    
    -- Upgrades
    AutoUpgrade = false,
    Upgrades = {},
    AutoExpandHive = false,
    UpgradeReserve = 0,
    UpgradeDelay = 1,
    
    -- Bee Upgrades
    AutoUpgradeBees = false,
    BeeMaxLevel = 10,
    BeeMaxCost = 1000000,
    BeeUpgradeReserve = 0,
    BeeUpgradeDelay = 1,
    
    -- Hives
    AutoBuyHives = false,
    HiveReserve = 0,
    HiveDelay = 1,
    
    -- Delete
    AutoDelete = false,
    DeleteMode = "Delete All",
    DeleteMinRarity = "Common",
    DeleteRarities = {},
    DeleteBees = {},
    DeleteMutations = {},
    
    DeleteProtectMutated = false,
    DeleteKeepPerType = 1,
    DeleteMaxPerCycle = 5,
    DeleteActionDelay = 0.1,
    DeleteLoopDelay = 3,
    DeleteNotify = false,
    
    -- Settings
    AntiAfk = true,
}

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function Notify(msg)
    WindUI:Notify({ Title = "IndraHub", Content = msg, Duration = 3 })
end
local DISCORD_LINK = "https://discord.gg/2PPBJsmqr"

local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_LINK)
    elseif toclipboard then
        toclipboard(DISCORD_LINK)
    end
    Notify("Copied Discord invite to clipboard")
end

local RARITY_ORDER = {}
for _, tier in ipairs(RarityConfig.Ladder) do
    RARITY_ORDER[#RARITY_ORDER + 1] = tier.Name
end

local UPGRADE_IDS = { "BeeLuck", "BeeRolls", "FlowerLevel", "BeeSpeed", "VacuumRange" }

local RARITY_INDEX = {}
for i, name in ipairs(RARITY_ORDER) do
    RARITY_INDEX[name] = i
end

local BEE_NAMES = {}
local BEE_NAME_TO_ID = {}
for _, def in ipairs(BeeConfig.Roster) do
    if def.Id and def.Name and not BEE_NAME_TO_ID[def.Name] then
        BEE_NAMES[#BEE_NAMES + 1] = def.Name
        BEE_NAME_TO_ID[def.Name] = def.Id
    end
end
table.sort(BEE_NAMES)

local MUTATION_NAMES = {}
for _, m in ipairs(MutationConfig.List) do
    local name = type(m) == "table" and m.Name or m
    if name then
        MUTATION_NAMES[#MUTATION_NAMES + 1] = tostring(name)
    end
end
table.sort(MUTATION_NAMES)

local function getData(key)
    local ok, value = pcall(function()
        return client:get(key)
    end)
    if ok then
        return value
    end
    return nil
end

local function selectedSet(value)
    local set = {}
    for name, state in value do
        if state then
            set[name] = true
        end
    end
    return set
end

local wantedRarities = {}

local function shouldBuyRolled(result)
    local mode = IndraState.RollBuyMode
    local minOdds = tonumber(IndraState.RollMinOdds) or 0
    if (result.OddsOneInX or 1) < minOdds then
        return false
    end
    if mode == "Buy All" then
        return true
    elseif mode == "Minimum Rarity" then
        return RarityConfig.AtOrAbove(result.Rarity, IndraState.RollMinRarity)
    elseif mode == "Specific Rarities" then
        if next(wantedRarities) == nil then
            return false
        end
        return wantedRarities[result.Rarity] == true
    end
    return false
end

local function doRoll()
    local ok, fired, resp = pcall(function()
        return Packets.RequestRoll:Fire()
    end)
    if not ok or not fired or type(resp) ~= "table" or type(resp.Results) ~= "table" then
        return
    end
    if not IndraState.RollAutoBuy then
        return
    end
    for _, result in ipairs(resp.Results) do
        if IndraState.Unloaded or not IndraState.AutoRoll then
            return
        end
        if result.Podium and shouldBuyRolled(result) then
            local bok, bfired, bresp = pcall(function()
                return Packets.BuyBee:Fire({ Podium = result.Podium })
            end)
            if bok and bfired and type(bresp) == "table" and bresp.UUID then
                if IndraState.RollNotify then
                    Notify(("Bought %s (1 in %s)"):format(tostring(result.Rarity), tostring(result.OddsOneInX or 1)))
                end
            end
            task.wait(0.15)
        end
    end
end

local function doHoney()
    if IndraState.AutoTakeHoney then
        pcall(function()
            Packets.GrabHoney:Fire()
        end)
    end
    if IndraState.AutoSellHoney then
        local carried = tonumber(getData("CarriedHoney")) or 0
        local minSell = tonumber(IndraState.MinHoneyToSell) or 0
        if carried > 0 and carried >= minSell then
            pcall(function()
                Packets.SellHoney:Fire()
            end)
        end
    end
end

local function doEquipBest()
    pcall(function()
        Packets.EquipBest:Fire()
    end)
end

local selectedUpgrades = {}

local function upgradeLevel(id, floor)
    return tonumber(getData(UpgradeConfig.LevelPath(id, floor))) or 0
end

local function tryUpgrade(id, floor, reserve)
    local level = upgradeLevel(id, floor)
    if UpgradeConfig.IsMaxed(id, level) then
        return false
    end
    local cost = UpgradeConfig.GetCost(id, level, floor)
    local cash = tonumber(getData("Cash")) or 0
    if cost == math.huge or cash - cost < reserve then
        return false
    end
    pcall(function()
        Packets.BuyUpgrade:Fire({ HiveIndex = 0, UpgradeId = id, Floor = floor })
    end)
    return true
end

local function doUpgrades()
    local reserve = tonumber(IndraState.UpgradeReserve) or 0
    local revealedFloors = HiveLayout.RevealedFloors(tonumber(getData("ExpandLevel")) or 1)
    for _, id in ipairs(UPGRADE_IDS) do
        if IndraState.Unloaded or not IndraState.AutoUpgrade then
            return
        end
        if selectedUpgrades[id] then
            if UpgradeConfig.IsPerFloor(id) then
                for floor = 1, revealedFloors do
                    if tryUpgrade(id, floor, reserve) then
                        task.wait(0.15)
                    end
                end
            else
                if tryUpgrade(id, 1, reserve) then
                    task.wait(0.15)
                end
            end
        end
    end
    if IndraState.AutoExpandHive then
        local expandLevel = tonumber(getData("ExpandLevel")) or 1
        if expandLevel < HiveLayout.MaxExpandLevel then
            pcall(function()
                Packets.ExpandHive:Fire()
            end)
        end
    end
end

local function doUpgradeBees()
    local hives = getData("Hives") or {}
    local reserve = tonumber(IndraState.BeeUpgradeReserve) or 0
    local maxLevel = tonumber(IndraState.BeeMaxLevel) or ProductionMath.MaxLevel
    local maxCost = tonumber(IndraState.BeeMaxCost) or 0
    for key, entry in pairs(hives) do
        if IndraState.Unloaded or not IndraState.AutoUpgradeBees then
            return
        end
        if type(entry) == "table" and entry.BeeId and entry.Unlocked then
            local level = entry.OutputLevel or 0
            if level < maxLevel and not ProductionMath.IsMaxed(level) then
                local cost = ProductionMath.UpgradeCost(entry.BeeId, level)
                local cash = tonumber(getData("Cash")) or 0
                local costOk = cost ~= math.huge and cash - cost >= reserve
                if maxCost > 0 and cost > maxCost then
                    costOk = false
                end
                if costOk then
                    local floor, index = HiveLayout.ParseHiveKey(key)
                    if index then
                        pcall(function()
                            Packets.BuyUpgrade:Fire({ UpgradeId = "HoneyOutput", HiveIndex = index, Floor = floor })
                        end)
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end

local function doBuyHives()
    local hives = getData("Hives") or {}
    local owned = 0
    for _, v in pairs(hives) do
        if v then
            owned = owned + 1
        end
    end
    local prices = GameConfig.HivePrices
    local price = prices[math.clamp(owned, 1, #prices)]
    if not price then
        return
    end
    local reserve = tonumber(IndraState.HiveReserve) or 0
    local cash = tonumber(getData("Cash")) or 0
    if cash - price < reserve then
        return
    end
    local expand = tonumber(getData("ExpandLevel")) or 1
    local revealedFloors = HiveLayout.RevealedFloors(expand)
    for floor = 1, revealedFloors do
        for _, index in ipairs(HiveLayout.AllIndices()) do
            if IndraState.Unloaded or not IndraState.AutoBuyHives then
                return
            end
            local layer = HiveLayout.LayerOf(index)
            if layer and HiveLayout.IsFloorLayerUnlocked(floor, layer, expand) then
                local key = HiveLayout.HiveKey(floor, index)
                if not hives[key] then
                    pcall(function()
                        Packets.UnlockHive:Fire({ HiveIndex = index, Floor = floor })
                    end)
                    return
                end
            end
        end
    end
end

local wantedDeleteRarities = {}
local wantedDeleteBees = {}
local wantedDeleteMutations = {}

local function beeRarityName(beeId)
    local def = BeeConfig.Get(beeId)
    return def and def.Rarity
end

local function matchesDeleteFilter(entry)
    local mode = IndraState.DeleteMode
    if mode == "Below Minimum Rarity" then
        local keepIdx = RARITY_INDEX[IndraState.DeleteMinRarity]
        local rarity = beeRarityName(entry.BeeId)
        local idx = rarity and RARITY_INDEX[rarity]
        return keepIdx ~= nil and idx ~= nil and idx < keepIdx
    elseif mode == "Selected Rarities" then
        local rarity = beeRarityName(entry.BeeId)
        return rarity ~= nil and wantedDeleteRarities[rarity] == true
    elseif mode == "Selected Bees" then
        return wantedDeleteBees[entry.BeeId] == true
    elseif mode == "Selected Mutations" then
        return entry.Mutation ~= nil and wantedDeleteMutations[entry.Mutation] == true
    end
    return false
end

local function collectDeletable()
    local owned = getData("OwnedBees") or {}
    local counts = {}
    for _, entry in pairs(owned) do
        if type(entry) == "table" and entry.BeeId then
            counts[entry.BeeId] = (counts[entry.BeeId] or 0) + 1
        end
    end
    local keepPerType = tonumber(IndraState.DeleteKeepPerType) or 0
    local protectMutated = IndraState.DeleteProtectMutated
    local mode = IndraState.DeleteMode
    local result = {}
    for _, entry in pairs(owned) do
        if type(entry) == "table" and entry.BeeId and entry.UUID then
            local skip = false
            if protectMutated and entry.Mutation ~= nil and mode ~= "Selected Mutations" then
                skip = true
            end
            if not skip and keepPerType > 0 and (counts[entry.BeeId] or 0) <= keepPerType then
                skip = true
            end
            if not skip and matchesDeleteFilter(entry) then
                result[#result + 1] = entry
                counts[entry.BeeId] = (counts[entry.BeeId] or 1) - 1
            end
        end
    end
    return result
end

local function toolForUUID(uuid)
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local character = LocalPlayer.Character
    for _, container in ipairs({ backpack, character }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute(ToolBuilderShared.ATTR_UUID) == uuid then
                    return tool
                end
            end
        end
    end
    return nil
end

local function trashBee(uuid)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    local tool = toolForUUID(uuid)
    if not tool then
        return false
    end
    humanoid:EquipTool(tool)
    task.wait()
    local held = character:FindFirstChildOfClass("Tool")
    if not held or held:GetAttribute(ToolBuilderShared.ATTR_UUID) ~= uuid then
        return false
    end
    pcall(function()
        Packets.TrashBee:Fire()
    end)
    return true
end

local function doAutoDelete()
    local candidates = collectDeletable()
    local maxPer = tonumber(IndraState.DeleteMaxPerCycle) or 10
    local delay = tonumber(IndraState.DeleteActionDelay) or 0.3
    local done = 0
    for _, entry in ipairs(candidates) do
        if IndraState.Unloaded or not IndraState.AutoDelete then
            return
        end
        if done >= maxPer then
            return
        end
        if trashBee(entry.UUID) then
            done = done + 1
            if IndraState.DeleteNotify then
                local def = BeeConfig.Get(entry.BeeId)
                Notify(("Deleted %s"):format(def and def.Name or entry.BeeId))
            end
            task.wait(delay)
        end
    end
end

local function deleteMatchingNow()
    local maxPer = tonumber(IndraState.DeleteMaxPerCycle) or 10
    local delay = tonumber(IndraState.DeleteActionDelay) or 0.3
    local candidates = collectDeletable()
    local done = 0
    for _, entry in ipairs(candidates) do
        if IndraState.Unloaded or done >= maxPer then
            break
        end
        if trashBee(entry.UUID) then
            done = done + 1
            task.wait(delay)
        end
    end
    Notify(("Deleted %d bee(s)"):format(done))
end


local Window = WindUI:CreateWindow({
    Title = "IndraHub | Grow a Beehive",
    Icon = "hexagon",
    Author = "IndraHub Premium",
    Folder = "IndraHub",
    Transparent = true,
    Theme = "Dark",
})

-- ==================== ROLL TAB ====================
local RollTab = Window:Tab({ Title = "Rolling", Icon = "dices" })

RollTab:Section({ Title = "Auto Rolling", TextSize = 16 })
RollTab:Toggle({
    Title = "Auto Roll",
    Desc = "Automatically request rolls",
    Value = IndraState.AutoRoll,
    Callback = function(state) IndraState.AutoRoll = state end
})
RollTab:Slider({
    Title = "Roll Delay",
    Desc = "Time between rolls (seconds)",
    Value = IndraState.RollDelay,
    Min = 0, Max = 10, Step = 0.1,
    Callback = function(val) IndraState.RollDelay = val end
})
RollTab:Toggle({
    Title = "Notify on Buy",
    Desc = "Send notification when a bee is bought",
    Value = IndraState.RollNotify,
    Callback = function(state) IndraState.RollNotify = state end
})

RollTab:Section({ Title = "Auto Buy Filter", TextSize = 16 })
RollTab:Toggle({
    Title = "Auto Buy Rolled Bees",
    Desc = "Automatically purchase bees from rolls based on filters",
    Value = IndraState.RollAutoBuy,
    Callback = function(state) IndraState.RollAutoBuy = state end
})
RollTab:Input({
    Title = "Minimum Odds (1 in X)",
    Desc = "Only buy if odds are rarer than 1 in X (0 to ignore)",
    Value = tostring(IndraState.RollMinOdds),
    Callback = function(val) IndraState.RollMinOdds = tonumber(val) or 0 end
})
RollTab:Dropdown({
    Title = "Buy Mode",
    Desc = "How to filter which bees to buy",
    Values = {"Buy All", "Minimum Rarity", "Specific Rarities"},
    Value = IndraState.RollBuyMode,
    Callback = function(val) IndraState.RollBuyMode = val end
})
RollTab:Dropdown({
    Title = "Minimum Rarity",
    Desc = "Buy any bee this rarity or better (for Minimum Rarity mode)",
    Values = RARITY_ORDER,
    Value = IndraState.RollMinRarity,
    Callback = function(val) IndraState.RollMinRarity = val end
})

-- ==================== HONEY TAB ====================
local HoneyTab = Window:Tab({ Title = "Honey", Icon = "droplet" })

HoneyTab:Toggle({
    Title = "Auto Collect Honey",
    Desc = "Collect honey drops automatically",
    Value = IndraState.AutoTakeHoney,
    Callback = function(state) IndraState.AutoTakeHoney = state end
})
HoneyTab:Toggle({
    Title = "Auto Sell Honey",
    Desc = "Sell honey automatically",
    Value = IndraState.AutoSellHoney,
    Callback = function(state) IndraState.AutoSellHoney = state end
})
HoneyTab:Slider({
    Title = "Min Honey to Sell",
    Desc = "Wait until this much honey before selling",
    Value = IndraState.MinHoneyToSell,
    Min = 0, Max = 1000000, Step = 100,
    Callback = function(val) IndraState.MinHoneyToSell = val end
})
HoneyTab:Slider({
    Title = "Honey Loop Delay",
    Desc = "Seconds between honey checks",
    Value = IndraState.HoneyDelay,
    Min = 0, Max = 10, Step = 0.5,
    Callback = function(val) IndraState.HoneyDelay = val end
})

-- ==================== UPGRADE TAB ====================
local UpgradeTab = Window:Tab({ Title = "Upgrades", Icon = "trending-up" })

UpgradeTab:Section({ Title = "Player Upgrades", TextSize = 16 })
UpgradeTab:Toggle({
    Title = "Auto Buy Upgrades",
    Desc = "Automatically buy selected player upgrades",
    Value = IndraState.AutoUpgrade,
    Callback = function(state) IndraState.AutoUpgrade = state end
})
UpgradeTab:Dropdown({
    Title = "Select Upgrades to Buy",
    Multi = true,
    Values = UPGRADE_IDS,
    Value = {},
    Callback = function(val) IndraState.Upgrades = selectedSet(val) end
})
UpgradeTab:Input({
    Title = "Upgrade Reserve Money",
    Desc = "Keep this much money when upgrading",
    Value = "0",
    Callback = function(val) IndraState.UpgradeReserve = tonumber(val) or 0 end
})
UpgradeTab:Slider({
    Title = "Upgrade Loop Delay",
    Value = IndraState.UpgradeDelay,
    Min = 0, Max = 10, Step = 0.5,
    Callback = function(val) IndraState.UpgradeDelay = val end
})

UpgradeTab:Section({ Title = "Hives", TextSize = 16 })
UpgradeTab:Toggle({
    Title = "Auto Buy New Hives",
    Value = IndraState.AutoBuyHives,
    Callback = function(state) IndraState.AutoBuyHives = state end
})
UpgradeTab:Toggle({
    Title = "Auto Expand Hive Area",
    Value = IndraState.AutoExpandHive,
    Callback = function(state) IndraState.AutoExpandHive = state end
})

UpgradeTab:Section({ Title = "Bee Upgrading", TextSize = 16 })
UpgradeTab:Toggle({
    Title = "Auto Upgrade Bees",
    Desc = "Automatically level up your bees",
    Value = IndraState.AutoUpgradeBees,
    Callback = function(state) IndraState.AutoUpgradeBees = state end
})
UpgradeTab:Slider({
    Title = "Max Bee Level",
    Desc = "Don't upgrade past this level",
    Value = IndraState.BeeMaxLevel,
    Min = 1, Max = 100, Step = 1,
    Callback = function(val) IndraState.BeeMaxLevel = val end
})
UpgradeTab:Input({
    Title = "Max Upgrade Cost",
    Value = "1000000",
    Callback = function(val) IndraState.BeeMaxCost = tonumber(val) or 1000000 end
})

-- ==================== DELETE TAB ====================
local DeleteTab = Window:Tab({ Title = "Auto Delete", Icon = "trash" })

DeleteTab:Toggle({
    Title = "Enable Auto Delete",
    Desc = "WARNING: Cannot be undone!",
    Value = IndraState.AutoDelete,
    Callback = function(state) IndraState.AutoDelete = state end
})
DeleteTab:Dropdown({
    Title = "Delete Mode",
    Values = {"Delete All", "Minimum Rarity", "Specific Rarities", "Specific Bees"},
    Value = IndraState.DeleteMode,
    Callback = function(val) IndraState.DeleteMode = val end
})
DeleteTab:Dropdown({
    Title = "Delete Minimum Rarity",
    Desc = "Deletes ANY bee below this rarity",
    Values = RARITY_ORDER,
    Value = IndraState.DeleteMinRarity,
    Callback = function(val) IndraState.DeleteMinRarity = val end
})

DeleteTab:Section({ Title = "Safety Settings", TextSize = 16 })
DeleteTab:Toggle({
    Title = "Protect Mutated Bees",
    Value = IndraState.DeleteProtectMutated,
    Callback = function(state) IndraState.DeleteProtectMutated = state end
})
DeleteTab:Slider({
    Title = "Keep Per Type",
    Desc = "Always keep at least this many of each bee type",
    Value = IndraState.DeleteKeepPerType,
    Min = 0, Max = 50, Step = 1,
    Callback = function(val) IndraState.DeleteKeepPerType = val end
})
DeleteTab:Slider({
    Title = "Max Deletes Per Cycle",
    Desc = "Limit amount deleted per loop",
    Value = IndraState.DeleteMaxPerCycle,
    Min = 1, Max = 50, Step = 1,
    Callback = function(val) IndraState.DeleteMaxPerCycle = val end
})
DeleteTab:Slider({
    Title = "Loop Delay",
    Value = IndraState.DeleteLoopDelay,
    Min = 1, Max = 10, Step = 0.5,
    Callback = function(val) IndraState.DeleteLoopDelay = val end
})

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Toggle({
    Title = "Anti-AFK",
    Value = IndraState.AntiAfk,
    Callback = function(state) IndraState.AntiAfk = state end
})

SettingsTab:Button({
    Title = "Copy Discord Link",
    Callback = function()
        copyDiscord()
    end
})

SettingsTab:Button({
    Title = "Unload IndraHub",
    Callback = function()
        IndraState.Unloaded = true
        getgenv().IndraHubBeehiveRunning = false
        pcall(function() WindUI:Destroy() end)
    end
})
task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoRoll then
            doRoll()
        end
        task.wait(IndraState.RollDelay or 1)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoTakeHoney or IndraState.AutoSellHoney then
            doHoney()
        end
        task.wait(IndraState.HoneyDelay or 1)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoEquipBest then
            doEquipBest()
        end
        task.wait(IndraState.EquipDelay or 5)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoUpgrade or IndraState.AutoExpandHive then
            doUpgrades()
        end
        task.wait(IndraState.UpgradeDelay or 1)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoBuyHives then
            doBuyHives()
        end
        task.wait(IndraState.HiveDelay or 1)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoUpgradeBees then
            doUpgradeBees()
        end
        task.wait(IndraState.BeeUpgradeDelay or 1)
    end
end)

task.spawn(function()
    while not IndraState.Unloaded do
        if IndraState.AutoDelete then
            doAutoDelete()
        end
        task.wait(IndraState.DeleteLoopDelay or 3)
    end
end)

Notify("IndraHub: Beehive Module Loaded!")
