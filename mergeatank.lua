local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local GAME_NAME = "Merge a Tank"
local DISCORD_INVITE = "https://discord.gg/ehKVq7pf7v"
local RSCRIPTS_LINK = "https://rscripts.net/@Ouroboros"

local env = getgenv and getgenv() or _G
local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end
local function getGlobal(key)
    local val = env[key]
    if val ~= nil then return val end
    return rawget(_G, key)
end

_G.__INDRA_MERGETANK = (_G.__INDRA_MERGETANK or 0) + 1
local GEN = _G.__INDRA_MERGETANK

setGlobal("IndraHubMergeATankRunning", true)
setGlobal("IndraHubMergeATankLastHeartbeat", os.clock())

task.spawn(function()
    while _G.__INDRA_MERGETANK == GEN and getGlobal("IndraHubMergeATankRunning") do
        task.wait(2)
        setGlobal("IndraHubMergeATankLastHeartbeat", os.clock())
        setGlobal("IndraHubMergeATankRunning", true)
        if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubMergeATankLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubMergeATankLastHeartbeat"].heartbeat = os.clock()
        end
    end
end)

if env.__IndraHubMergeATankLib and env.__IndraHubMergeATankLib.Unload then
    pcall(function() env.__IndraHubMergeATankLib:Unload() end)
end

local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI or not WindUI then
    warn("[IndraHub] Failed to load WindUI")
    setGlobal("IndraHubMergeATankError", "WINDUI FAIL")
    return
end

local RealWindow = WindUI:CreateWindow({
    Title = "IndraHub | Merge a Tank",
    Icon = "shield",
    Author = "IndraHub",
    Folder = "IndraHub_MergeATank",
    Size = UDim2.fromOffset(640, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 185,
    HasOutline = true
})

local Toggles = {
    AutoMerge = { Value = false },
    AutoPlace = { Value = false },
    AutoReplaceBetter = { Value = false },
    AutoEquipBestWorker = { Value = false },
    AutoAddWorkerToTanks = { Value = false },
    AutoBuyUnits = { Value = false },
    AutoBuyUpgrades = { Value = false },
    AutoCollect = { Value = false },
    AutoBuyWorkerCrates = { Value = false },
    AutoClaimFreeGifts = { Value = false },
    AutoUsePotions = { Value = false },
    AutoRebirth = { Value = false },
    AutoUnlockAether = { Value = false },
    AntiAfk = { Value = true }
}
local Options = {
    MergeDelay = { Value = 0.5 },
    AutoPlaceDelay = { Value = 2 },
    AutoReplaceDelay = { Value = 3 },
    WorkerDelay = { Value = 1 },
    BuyUnitsDelay = { Value = 1 },
    UpgradeList = { Value = {} },
    BuyUpgradesDelay = { Value = 1 },
    CollectDelay = { Value = 0.2 },
    WorkerCrateList = { Value = {} },
    WorkerCrateDelay = { Value = 1 },
    PotionList = { Value = {} },
    RebirthDelay = { Value = 3 }
}

local Library = {
    Unloaded = false,
    Toggles = Toggles,
    Options = Options,
    _unloadCallbacks = {},
    OnUnload = function(self, cb)
        table.insert(self._unloadCallbacks, cb)
    end,
    Unload = function(self)
        if self.Unloaded then return end
        self.Unloaded = true
        setGlobal("IndraHubMergeATankRunning", false)
        for _, cb in ipairs(self._unloadCallbacks) do
            pcall(cb)
        end
        pcall(function() RealWindow:Destroy() end)
        if getgenv then
            getgenv().__IndraHubMergeATankLib = nil
        end
    end,
    Notify = function(self, msg)
        pcall(function()
            WindUI:Notify({
                Title = "IndraHub",
                Content = tostring(msg or ""),
                Duration = 3.5
            })
        end)
    end
}

if getgenv then
    getgenv().__IndraHubMergeATankLib = Library
end

local Modules = ReplicatedStorage:WaitForChild("Modules")
local RemoteHandler = require(Modules:WaitForChild("RemoteHandler"))
local GenericFunctionUtil = require(Modules:WaitForChild("HGUtils"):WaitForChild("GenericFunctionUtil"))
local FarmGameModules = Modules:WaitForChild("FarmGame")
local FarmEggData = require(FarmGameModules:WaitForChild("FarmEggData"))
local BrainrotCalculationFunctions = require(Modules:WaitForChild("FishAGame"):WaitForChild("BrainrotCalculationFunctions"))
local PotionTypeData = require(Modules:WaitForChild("PotionTypeData"))
local PlaytimeRewardsData = require(Modules:WaitForChild("PlaytimeRewards"))

local MergeTower = RemoteHandler.GetRemoteFunction("MergeTower")
local UpgradeBoardEvent = RemoteHandler.GetRemoteEvent("UpgradeBoardEvent")
local UpgradeBoardState = RemoteHandler.GetRemoteFunction("UpgradeBoardState")
local EquipBestTowers = RemoteHandler.GetRemoteEvent("EquipBestTowers")
local RodShopPurchaseEvent = RemoteHandler.GetRemoteEvent("RodShopPurchaseEvent")
local GenerateWorkerInventoryEvent = RemoteHandler.GetRemoteFunction("GenerateWorkerInventoryEvent")
local EquipWorker = RemoteHandler.GetRemoteEvent("EquipWorker")
local UnequipWorker = RemoteHandler.GetRemoteEvent("UnequipWorker")
local MergeTankWorker = RemoteHandler.GetRemoteEvent("MergeTankWorker")
local CashRebirth = RemoteHandler.GetRemoteEvent("CashRebirth")
local PlaytimeRewardUpdateEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlaytimeRewardUpdateEvent")
local PlayerUsePotion = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerUsePotion")
local UpdatePotionsUI = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdatePotionsUI")

local UpgradeKeys = { "SpawnLevel", "BaseHealth", "CoinValue", "GemDropChance", "FireRate", "PickupRadius", "ActiveSlots" }
local WorkerCrateNames = {}
local WorkerCrateKeyByName = {}
local PotionNames = {}
local PotionKeyByName = {}

do
    local crates = {}
    for key, data in FarmEggData do
        if data.availableInShop ~= false and data.gemCost ~= nil then
            table.insert(crates, { key = key, name = data.name, cost = data.gemCost })
        end
    end
    table.sort(crates, function(a, b)
        return a.cost < b.cost
    end)
    for _, crate in crates do
        table.insert(WorkerCrateNames, crate.name)
        WorkerCrateKeyByName[crate.name] = crate.key
    end

    local potions = {}
    for key, data in PotionTypeData do
        table.insert(potions, { key = key, name = data.displayName or data.name or key })
    end
    table.sort(potions, function(a, b)
        return a.name < b.name
    end)
    for _, potion in potions do
        table.insert(PotionNames, potion.name)
        PotionKeyByName[potion.name] = potion.key
    end
end

local CurrencyCache = {}
local UpdatePlayerCurrency = ReplicatedStorage:WaitForChild("UpdatePlayerCurrency")
UpdatePlayerCurrency.OnClientEvent:Connect(function(currencyName, amount)
    if currencyName ~= nil and amount ~= nil then
        CurrencyCache[currencyName] = amount
    end
end)

local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_INVITE)
    elseif toclipboard then
        toclipboard(DISCORD_INVITE)
    end
    Library:Notify("Copied Discord invite to clipboard")
end

local function getPlayerPlot()
    local ok, plot = pcall(GenericFunctionUtil.getPlayerPlot, LocalPlayer)
    if ok then
        return plot
    end
    return nil
end

local function collectTanks()
    local plot = getPlayerPlot()
    if not plot then
        return {}
    end

    local Interactive = plot:FindFirstChild("Interactive")
    if not Interactive then
        return {}
    end

    local tanks = {}
    for _, folderName in { "Merge", "Frontline" } do
        local folder = Interactive:FindFirstChild(folderName)
        if folder then
            for _, tile in folder:GetChildren() do
                if tile:IsA("Model") then
                    for _, child in tile:GetChildren() do
                        if child:IsA("Model") and child:GetAttribute("UUID") then
                            table.insert(tanks, child)
                        end
                    end
                end
            end
        end
    end
    return tanks
end

local function getBoardState()
    local ok, result = pcall(function()
        return UpgradeBoardState:InvokeServer()
    end)
    if ok then
        return result
    end
    return nil
end

local function canAfford(entry)
    if not entry or entry.isMaxed or entry.cost == nil then
        return false
    end
    local currencyName = entry.currency == "gems" and "Gems" or "Coins"
    local total = CurrencyCache[currencyName]
    if total == nil then
        return true
    end
    return entry.cost <= total
end

local function SelectedSet(value)
    local set = {}
    if typeof(value) == "table" then
        for name, on in value do
            if on then
                set[name] = true
            end
        end
    end
    return set
end

local function IsEmptySet(set)
    return next(set) == nil
end

local function getWorkerInventory()
    local ok, inventory = pcall(function()
        return GenerateWorkerInventoryEvent:InvokeServer()
    end)
    if ok and typeof(inventory) == "table" then
        return inventory
    end
    return {}
end

local function getBestUnplacedWorker(inventory)
    local bestID
    local bestValue = -math.huge
    for workerID, worker in inventory do
        if worker.placed ~= true then
            local ok, value = pcall(BrainrotCalculationFunctions.CalculateBrainrotValue, worker, true)
            if ok and value > bestValue then
                bestID = workerID
                bestValue = value
            end
        end
    end
    return bestID
end

local function equipBestWorker()
    local inventory = getWorkerInventory()
    local bestID = getBestUnplacedWorker(inventory)
    if not bestID then
        return false
    end

    for workerID, worker in inventory do
        if worker.equipped and workerID ~= bestID then
            pcall(function()
                UnequipWorker:FireServer(workerID, true, true)
            end)
            task.wait(0.15)
        end
    end

    if not inventory[bestID].equipped then
        pcall(function()
            EquipWorker:FireServer(bestID, true, true)
        end)
        task.wait(0.25)
    end
    return true
end

local function getEmptyFrontlineTank()
    local plot = getPlayerPlot()
    local Interactive = plot and plot:FindFirstChild("Interactive")
    local Frontline = Interactive and Interactive:FindFirstChild("Frontline")
    if not Frontline then
        return nil
    end

    for _, tile in Frontline:GetChildren() do
        for _, tank in tile:GetChildren() do
            if tank:IsA("Model") and tank:GetAttribute("UUID") then
                local workerID = tank:GetAttribute("WorkerID")
                if workerID == nil or workerID == "" then
                    return tank
                end
            end
        end
    end
    return nil
end

local function getPotionState()
    local inventory = {}
    local active = {}
    local bestInventoryCount = 0
    if not getconnections or not getupvalues then
        return inventory, active
    end

    pcall(function()
        for _, connection in ipairs(getconnections(UpdatePotionsUI.OnClientEvent)) do
            local callback = connection.Function
            if callback then
                for _, callbackUpvalue in pairs(getupvalues(callback)) do
                    if type(callbackUpvalue) == "function" then
                        for _, candidate in pairs(getupvalues(callbackUpvalue)) do
                            if type(candidate) == "table" then
                                local potionCount = 0
                                local activeCount = 0
                                for _, potion in pairs(candidate) do
                                    if type(potion) == "table" and potion.potionName then
                                        potionCount = potionCount + 1
                                        if potion.endTime then
                                            activeCount = activeCount + 1
                                        end
                                    end
                                end
                                if potionCount > 0 then
                                    if activeCount > 0 then
                                        for _, potion in pairs(candidate) do
                                            if type(potion) == "table" and potion.potionName and potion.endTime and potion.endTime > os.time() then
                                                active[potion.potionName] = true
                                            end
                                        end
                                    elseif potionCount > bestInventoryCount then
                                        inventory = candidate
                                        bestInventoryCount = potionCount
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return inventory, active
end

local lastEquipBestFire = 0
local function fireEquipBest()
    local now = os.clock()
    if now - lastEquipBestFire < 0.5 then
        return
    end
    lastEquipBestFire = now
    pcall(function()
        EquipBestTowers:FireServer()
    end)
end

local MergeTab = RealWindow:Tab({ Title = "Merge & Units", Icon = "swords" })
local EconomyTab = RealWindow:Tab({ Title = "Economy", Icon = "coins" })
local RebirthTab = RealWindow:Tab({ Title = "Rebirth", Icon = "sparkles" })
local SettingsTab = RealWindow:Tab({ Title = "Settings", Icon = "settings" })

-- Merge Tab
MergeTab:Section({ Title = "Auto Merge" })

MergeTab:Toggle({
    Title = "Auto Merge",
    Desc = "Merges identical tanks automatically",
    Default = false,
    Callback = function(val)
        Toggles.AutoMerge.Value = val
    end
})

MergeTab:Slider({
    Title = "Merge Delay",
    Default = 0.5,
    Min = 0.2,
    Max = 3,
    Callback = function(val)
        Options.MergeDelay.Value = val
    end
})

MergeTab:Section({ Title = "Auto Place" })

MergeTab:Toggle({
    Title = "Auto Place Tanks",
    Desc = "Automatically places available tanks onto open slots",
    Default = false,
    Callback = function(val)
        Toggles.AutoPlace.Value = val
    end
})

MergeTab:Slider({
    Title = "Place Delay",
    Default = 2,
    Min = 0.5,
    Max = 10,
    Callback = function(val)
        Options.AutoPlaceDelay.Value = val
    end
})

MergeTab:Section({ Title = "Auto Replace" })

MergeTab:Toggle({
    Title = "Auto Replace with Better",
    Desc = "Swaps lower tier tanks with higher tier ones",
    Default = false,
    Callback = function(val)
        Toggles.AutoReplaceBetter.Value = val
    end
})

MergeTab:Slider({
    Title = "Replace Delay",
    Default = 3,
    Min = 0.5,
    Max = 10,
    Callback = function(val)
        Options.AutoReplaceDelay.Value = val
    end
})

MergeTab:Section({ Title = "Workers" })

MergeTab:Toggle({
    Title = "Equip Best Worker",
    Desc = "Equips the best worker automatically",
    Default = false,
    Callback = function(val)
        Toggles.AutoEquipBestWorker.Value = val
    end
})

MergeTab:Toggle({
    Title = "Auto Add Workers to Tanks",
    Desc = "Assigns available workers to deployed tanks",
    Default = false,
    Callback = function(val)
        Toggles.AutoAddWorkerToTanks.Value = val
    end
})

MergeTab:Slider({
    Title = "Worker Delay",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Callback = function(val)
        Options.WorkerDelay.Value = val
    end
})

-- Economy Tab
EconomyTab:Section({ Title = "Auto Buy Units" })

EconomyTab:Toggle({
    Title = "Auto Buy Units",
    Desc = "Automatically purchases next tier tanks",
    Default = false,
    Callback = function(val)
        Toggles.AutoBuyUnits.Value = val
    end
})

EconomyTab:Slider({
    Title = "Buy Units Delay",
    Default = 1,
    Min = 0.2,
    Max = 5,
    Callback = function(val)
        Options.BuyUnitsDelay.Value = val
    end
})

EconomyTab:Section({ Title = "Board Upgrades" })

EconomyTab:Toggle({
    Title = "Auto Buy Upgrades",
    Desc = "Purchases board upgrades automatically",
    Default = false,
    Callback = function(val)
        Toggles.AutoBuyUpgrades.Value = val
    end
})

EconomyTab:Dropdown({
    Title = "Upgrade List",
    Values = UpgradeKeys,
    Value = {},
    Multi = true,
    Callback = function(val)
        Options.UpgradeList.Value = val
    end
})

EconomyTab:Slider({
    Title = "Buy Upgrades Delay",
    Default = 1,
    Min = 0.2,
    Max = 5,
    Callback = function(val)
        Options.BuyUpgradesDelay.Value = val
    end
})

EconomyTab:Section({ Title = "Auto Collect Money" })

EconomyTab:Toggle({
    Title = "Auto Collect Money on Ground",
    Desc = "Gathers all spawned cash/gems on the ground",
    Default = false,
    Callback = function(val)
        Toggles.AutoCollect.Value = val
    end
})

EconomyTab:Slider({
    Title = "Collect Delay",
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Callback = function(val)
        Options.CollectDelay.Value = val
    end
})

EconomyTab:Section({ Title = "Worker Crates" })

EconomyTab:Toggle({
    Title = "Auto Buy Worker Crates",
    Desc = "Automatically opens selected worker crates",
    Default = false,
    Callback = function(val)
        Toggles.AutoBuyWorkerCrates.Value = val
    end
})

EconomyTab:Dropdown({
    Title = "Worker Crates",
    Values = WorkerCrateNames,
    Value = {},
    Multi = true,
    Callback = function(val)
        Options.WorkerCrateList.Value = val
    end
})

EconomyTab:Slider({
    Title = "Crate Delay",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Callback = function(val)
        Options.WorkerCrateDelay.Value = val
    end
})

EconomyTab:Section({ Title = "Potions & Free Gifts" })

EconomyTab:Toggle({
    Title = "Auto Claim Free Gifts",
    Desc = "Claims playtime free gifts as they unlock",
    Default = false,
    Callback = function(val)
        Toggles.AutoClaimFreeGifts.Value = val
    end
})

EconomyTab:Toggle({
    Title = "Auto Use Potions",
    Desc = "Consumes selected potions when inactive",
    Default = false,
    Callback = function(val)
        Toggles.AutoUsePotions.Value = val
    end
})

EconomyTab:Dropdown({
    Title = "Potions",
    Values = PotionNames,
    Value = {},
    Multi = true,
    Callback = function(val)
        Options.PotionList.Value = val
    end
})

-- Rebirth Tab
RebirthTab:Section({ Title = "Auto Rebirth" })

RebirthTab:Toggle({
    Title = "Auto Rebirth",
    Desc = "Performs cash rebirth automatically when affordable",
    Default = false,
    Callback = function(val)
        Toggles.AutoRebirth.Value = val
    end
})

RebirthTab:Slider({
    Title = "Rebirth Delay",
    Default = 3,
    Min = 1,
    Max = 15,
    Callback = function(val)
        Options.RebirthDelay.Value = val
    end
})

RebirthTab:Section({ Title = "Aether" })

RebirthTab:Toggle({
    Title = "Auto Unlock Aether",
    Desc = "Automatically unlocks Aether ascension",
    Default = false,
    Callback = function(val)
        Toggles.AutoUnlockAether.Value = val
    end
})

-- Settings Tab
SettingsTab:Section({ Title = "Anti-AFK & Automation" })

SettingsTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents idle kicks after 20 minutes",
    Default = true,
    Callback = function(val)
        Toggles.AntiAfk.Value = val
    end
})

SettingsTab:Section({ Title = "Script Management" })

SettingsTab:Button({
    Title = "Unload IndraHub",
    Desc = "Stops all loops and unloads user interface cleanly",
    Callback = function()
        Library:Unload()
    end
})

-- Auto Merge loop

task.spawn(function()
    while task.wait(Options.MergeDelay and Options.MergeDelay.Value or 0.5) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoMerge.Value then
            local tanks = collectTanks()
            local groups = {}
            for _, tank in tanks do
                local list = groups[tank.Name]
                if not list then
                    list = {}
                    groups[tank.Name] = list
                end
                table.insert(list, tank)
            end

            for _, list in groups do
                if Library.Unloaded then
                    break
                end
                if #list >= 2 then
                    local uuidA = list[1]:GetAttribute("UUID")
                    local uuidB = list[2]:GetAttribute("UUID")
                    pcall(function()
                        MergeTower:InvokeServer(uuidA, uuidB)
                    end)
                    task.wait(0.15)
                end
            end
        end
    end
end)

-- Auto Place / Auto Replace loops

task.spawn(function()
    while task.wait(Options.AutoPlaceDelay and Options.AutoPlaceDelay.Value or 2) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoPlace.Value then
            fireEquipBest()
        end
    end
end)

task.spawn(function()
    while task.wait(Options.AutoReplaceDelay and Options.AutoReplaceDelay.Value or 3) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoReplaceBetter.Value then
            fireEquipBest()
        end
    end
end)

task.spawn(function()
    while task.wait(Options.WorkerDelay and Options.WorkerDelay.Value or 1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoAddWorkerToTanks.Value then
            local tank = getEmptyFrontlineTank()
            if tank and equipBestWorker() then
                pcall(function()
                    MergeTankWorker:FireServer("Attach", tank:GetAttribute("UUID"))
                end)
            end
        elseif Toggles.AutoEquipBestWorker.Value then
            equipBestWorker()
        end
    end
end)

-- Auto Buy Units loop

task.spawn(function()
    while task.wait(Options.BuyUnitsDelay and Options.BuyUnitsDelay.Value or 1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoBuyUnits.Value then
            local state = getBoardState()
            if state and canAfford(state.BuyUnit) then
                pcall(function()
                    UpgradeBoardEvent:FireServer("BuyUnit")
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(Options.WorkerCrateDelay and Options.WorkerCrateDelay.Value or 1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoBuyWorkerCrates.Value then
            local selected = SelectedSet(Options.WorkerCrateList.Value)
            for _, crateName in WorkerCrateNames do
                if Library.Unloaded or not Toggles.AutoBuyWorkerCrates.Value then
                    break
                end
                if IsEmptySet(selected) or selected[crateName] then
                    local crateKey = WorkerCrateKeyByName[crateName]
                    local crateData = FarmEggData[crateKey]
                    local gems = CurrencyCache.Gems or (_G.TotalCurrency and _G.TotalCurrency.Gems)
                    if gems == nil or crateData.gemCost <= gems then
                        pcall(function()
                            RodShopPurchaseEvent:FireServer(crateKey)
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

-- Auto Buy Upgrades loop

task.spawn(function()
    while task.wait(Options.BuyUpgradesDelay and Options.BuyUpgradesDelay.Value or 1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoBuyUpgrades.Value then
            local set = SelectedSet(Options.UpgradeList.Value)
            local state = getBoardState()
            if state then
                for _, key in UpgradeKeys do
                    if Library.Unloaded then
                        break
                    end
                    if (IsEmptySet(set) or set[key]) and canAfford(state[key]) then
                        pcall(function()
                            UpgradeBoardEvent:FireServer(key)
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

-- Auto Collect Money loop

task.spawn(function()
    while task.wait(Options.CollectDelay and Options.CollectDelay.Value or 0.2) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoCollect.Value then
            local dropsFolder = workspace:FindFirstChild("ClientCoinsGems")
            local character = LocalPlayer.Character
            local touchPart = character and character:FindFirstChild("HumanoidRootPart")
            if dropsFolder and touchPart then
                for _, drop in dropsFolder:GetChildren() do
                    if Library.Unloaded then
                        break
                    end
                    if drop:IsA("BasePart") and drop.Name == "CurrencyDrop" then
                        pcall(function()
                            firetouchinterest(drop, touchPart, 0)
                            firetouchinterest(drop, touchPart, 1)
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoClaimFreeGifts.Value then
            local PlaytimeRewards = LocalPlayer.PlayerGui:FindFirstChild("PlaytimeRewards")
            local RewardsFrame = PlaytimeRewards and PlaytimeRewards:FindFirstChild("Frame")
            RewardsFrame = RewardsFrame and RewardsFrame:FindFirstChild("Frame")
            if RewardsFrame then
                for rewardID in PlaytimeRewardsData do
                    local Gift = RewardsFrame:FindFirstChild("Gift" .. tostring(rewardID))
                    local Timer = Gift and Gift:FindFirstChild("Timer")
                    if Timer and Timer.Text == "Claim!" then
                        pcall(function()
                            PlaytimeRewardUpdateEvent:FireServer(tostring(rewardID))
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoUsePotions.Value then
            local selectedNames = SelectedSet(Options.PotionList.Value)
            local selectedKeys = {}
            for potionName in selectedNames do
                selectedKeys[PotionKeyByName[potionName]] = true
            end
            local inventory, active = getPotionState()
            for potionID, potion in inventory do
                if (IsEmptySet(selectedKeys) or selectedKeys[potion.potionName]) and not active[potion.potionName] then
                    pcall(function()
                        PlayerUsePotion:FireServer(potionID)
                    end)
                    break
                end
            end
        end
    end
end)

-- Auto Rebirth loop

task.spawn(function()
    while task.wait(Options.RebirthDelay and Options.RebirthDelay.Value or 3) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoRebirth.Value then
            local plot = getPlayerPlot()
            local Interactive = plot and plot:FindFirstChild("Interactive")
            local Rebirths = Interactive and Interactive:FindFirstChild("Rebirths")
            local Model = Rebirths and Rebirths:FindFirstChild("Model")
            local Portal = Model and Model:FindFirstChild("EnterHeavenPortal")
            local EnterHeaven = Portal and Portal:FindFirstChild("EnterHeaven")
            local Prompt = EnterHeaven and EnterHeaven:FindFirstChildOfClass("ProximityPrompt")
            if Prompt then
                pcall(function()
                    fireproximityprompt(Prompt)
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if Library.Unloaded then
            break
        end
        if Toggles.AutoUnlockAether.Value and _G.isHeavenUnlocked ~= true then
            pcall(function()
                CashRebirth:FireServer("rebirth")
            end)
        end
    end
end)

local antiAfkLastInput = tick()
local antiAfkLastTap = tick()

pcall(function()
    for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
        pcall(function()
            connection:Disable()
        end)
    end
end)

local function antiAfkTap()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    antiAfkLastTap = tick()
end

local antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
    antiAfkLastInput = tick()
end)

local antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
        antiAfkLastInput = tick()
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local idle = tick() - antiAfkLastInput
            local sinceTap = tick() - antiAfkLastTap
            if idle >= 300 and sinceTap >= 60 then
                pcall(antiAfkTap)
            elseif idle < 300 and sinceTap >= 300 then
                pcall(antiAfkTap)
            end
        end
    end
end)

Library:OnUnload(function()
    antiAfkBeganConnection:Disconnect()
    antiAfkChangedConnection:Disconnect()
    print("[IndraHub] Merge a Tank unloaded")
end)

Library:Notify("Merge a Tank module loaded successfully!")
