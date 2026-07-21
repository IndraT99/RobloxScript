-- ==========================================
-- WINDUI SETUP & INDRAHUB INITIALIZATION
-- ==========================================
shared.IndraHub_BeAFish_Unloaded = false

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Be A Fish Bait",
    Icon = "rbxassetid://91400086538074",
    Author = "IndraHub",
    Folder = "IndraHub_BeAFish",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    M = Window:Tab({ Title = "Main", Icon = "swords" }),
    S = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

local flags = {
    AutoFish = false,
    AutoMutationBoost = false,
    SkipFishAnimation = false,
    AutoBossBattle = false,
    AutoAquarium = false,
    AutoCollectAquariumMoney = false,
    AutoUpgradeAquarium = false,
    AutoRevealAquarium = false,
    AutoTrain = false,
    DisableTrainingFreeze = false,
    AutoTrainingBoost = false,
    AutoRebirth = false,
    AutoBuyRod = false,
    AutoBuyWeight = false,
    AutoSpinWheel = false,
    AutoSellFish = false,
    SellTrigger = "Backpack Full",
    SellInterval = 30,
    AntiAfk = true,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local TS = PlayerScripts:WaitForChild("TS")
local ReplicatedTS = ReplicatedStorage:WaitForChild("TS")

local function requirePath(root, ...)
    local current = root
    for _, name in ipairs({ ... }) do
        current = current:WaitForChild(name)
    end
    return require(current)
end

local Network = requirePath(TS, "network")
local ProducerModule = requirePath(TS, "reflex", "producer")
local FishingAtoms = requirePath(TS, "fishing-phase-atom")

local PlayerDataSelectors = requirePath(ReplicatedTS, "slices", "player-data", "selectors")
local FishingHookSelectors = requirePath(ReplicatedTS, "slices", "fishing-hooks", "selectors")
local InventoryUtils = requirePath(ReplicatedTS, "utils", "inventory-utils")
local BaitAuraUtils = requirePath(ReplicatedTS, "utils", "bait-aura-utils")
local RebirthUtils = requirePath(ReplicatedTS, "data", "rebirth-utils")
local FishingRods = requirePath(ReplicatedTS, "data", "fishing-rods")
local TrainingWeights = requirePath(ReplicatedTS, "data", "training-weights")
local Shops = requirePath(ReplicatedTS, "data", "shops")
local ExclusiveFish = requirePath(ReplicatedTS, "data", "exclusive-fish")

local WeightTrainingController = requirePath(TS, "controllers", "weight-training-controller").WeightTrainingController
local FishingRodController = requirePath(TS, "controllers", "fishing-rod-controller").FishingRodController
local CastCutSceneComponent = requirePath(TS, "components", "cast-cutscene-component").CastCutSceneComponent
local ReelCamera = requirePath(TS, "reel-camera")
local BossConfig = requirePath(TS, "react", "screen", "fishing", "rare-fish-boss", "boss-config")

local clientProducer = ProducerModule.clientProducer
local INVITE_LNK = "https://discord.gg/2PPBJsmqr"
local WINDUI_URL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

Tabs.M:Toggle({ Title = "Auto Fish (Perfect Charge)", Default = false, Callback = function(v) flags.AutoFish = v end })
Tabs.M:Toggle({ Title = "Auto Mutation Boost", Default = false, Callback = function(v) flags.AutoMutationBoost = v end })
Tabs.M:Toggle({ Title = "Skip Fish Animation", Default = false, Callback = function(v) flags.SkipFishAnimation = v end })
Tabs.M:Toggle({ Title = "Auto Boss Battle", Default = false, Callback = function(v) flags.AutoBossBattle = v end })
Tabs.M:Toggle({ Title = "Auto Equip Best For Aquarium", Default = false, Callback = function(v) flags.AutoAquarium = v end })
Tabs.M:Toggle({ Title = "Auto Collect Money From Aquarium", Default = false, Callback = function(v) flags.AutoCollectAquariumMoney = v end })
Tabs.M:Toggle({ Title = "Auto Upgrade Aquarium Capacity", Default = false, Callback = function(v) flags.AutoUpgradeAquarium = v end })
Tabs.M:Toggle({ Title = "Auto Reveal Aquarium", Default = false, Callback = function(v) flags.AutoRevealAquarium = v end })

Tabs.M:Toggle({ Title = "Auto Train", Default = false, Callback = function(v) flags.AutoTrain = v end })
Tabs.M:Toggle({ Title = "Disable Training Freeze", Default = false, Callback = function(v) flags.DisableTrainingFreeze = v end })
Tabs.M:Toggle({ Title = "Auto Training 2x", Default = false, Callback = function(v) flags.AutoTrainingBoost = v end })
Tabs.M:Toggle({ Title = "Auto Rebirth", Default = false, Callback = function(v) flags.AutoRebirth = v end })

Tabs.M:Toggle({ Title = "Auto Buy Best Affordable Rod", Default = false, Callback = function(v) flags.AutoBuyRod = v end })
Tabs.M:Toggle({ Title = "Auto Buy Best Affordable Weights", Default = false, Callback = function(v) flags.AutoBuyWeight = v end })
Tabs.M:Toggle({ Title = "Auto Spin Wheel", Default = false, Callback = function(v) flags.AutoSpinWheel = v end })

Tabs.M:Toggle({ Title = "Auto Sell All Fish", Default = false, Callback = function(v) flags.AutoSellFish = v end })
Tabs.M:Dropdown({ Title = "Sell Trigger", Values = { "Backpack Full", "Interval", "Backpack Full or Interval" }, Default = 1, Callback = function(v) flags.SellTrigger = v end })
Tabs.M:Slider({ Title = "Sell Interval (Seconds)", Value = { Min = 1, Max = 300, Default = 30 }, Callback = function(v) flags.SellInterval = v end })

MenuBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Text = "Menu keybind",
    Default = "RightShift",
    NoUI = true,
})



local function dispatchTrainingTap()
    if WeightTrainingController and type(WeightTrainingController.dispatch) == "function" then
        WeightTrainingController:dispatch({ action = "tap", multiTap = true })
        return
    end

    if getgc then
        for _, object in ipairs(getgc(true)) do
            if type(object) == "table" and type(rawget(object, "dispatch")) == "function" then
                local ok = pcall(object.dispatch, object, { action = "tap", multiTap = true })
                if ok then
                    return
                end
            end
        end
    end
end

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoTrain and not FishingAtoms.fishingMovementLockedAtom() then
            local equipped = selectForPlayer(PlayerDataSelectors.selectEquippedInventoryItem)
            local equippedType = string.lower(tostring(equipped and equipped.itemType or ""))
            if equippedType == "trainingweight" then
                dispatchTrainingTap()
            end
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoTrainingBoost then
            activateVisibleText(function(text)
                return text:find("2x", 1, true) ~= nil
                    and (text:find("train", 1, true) ~= nil or text:find("boost", 1, true) ~= nil)
            end)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoMutationBoost then
            activateVisibleText(function(text)
                return text:find("mutation", 1, true) ~= nil
                    and (text:find("boost", 1, true) ~= nil or text:find("claim", 1, true) ~= nil)
            end)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoBossBattle and FishingAtoms.bossActivePromptAtom() then
            activateVisibleText(function(text)
                return text:find("boss", 1, true) ~= nil
                    or text:find("battle", 1, true) ~= nil
            end)
        end
        task.wait(0.03)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.SkipFishAnimation then
            local hook = selectForPlayer(FishingHookSelectors.selectLocalPlayerHook)
            if hook then
                activateVisibleText(function(text)
                    return text:find("reel", 1, true) ~= nil
                        or text:find("catch", 1, true) ~= nil
                end)
            end
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoFish and not FishingAtoms.fishingMovementLockedAtom() then
            local inventory = selectForPlayer(PlayerDataSelectors.selectPlayerInventory)
            if InventoryUtils.hasSpaceInBackpack(inventory) and not flags.AutoTrain then
                local currentState = state()
                local fishingArea = currentState and currentState.fishingArea
                if fishingArea and fishingArea.isInFishingArea then
                    activateVisibleText(function(text)
                        return text:find("cast", 1, true) ~= nil
                            or text:find("charge", 1, true) ~= nil
                            or text:find("reel", 1, true) ~= nil
                    end)
                end
            end
        end
        task.wait(1)
    end
end)

local lastSell = tick()
task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoSellFish then
            local inventory = selectForPlayer(PlayerDataSelectors.selectPlayerInventory)
            local trigger = flags.SellTrigger
            local backpackFull = not InventoryUtils.hasSpaceInBackpack(inventory)
            local intervalReached = tick() - lastSell >= flags.SellInterval

            local shouldSell = (trigger == "Backpack Full" and backpackFull)
                or (trigger == "Interval" and intervalReached)
                or (trigger == "Backpack Full or Interval" and (backpackFull or intervalReached))

            if shouldSell then
                sellAllFish()
                lastSell = tick()
            end
        end
        task.wait(1)
    end
end)

local function inventoryNames(inventory)
    local names = {}
    for _, item in pairs(inventory or {}) do
        if item.itemName then
            names[item.itemName] = true
        end
    end
    return names
end

local function buyBestAffordable(shopName, order, data, rebirthRequirements)
    local currentState = state()
    local inventory = selectForPlayer(PlayerDataSelectors.selectPlayerInventory)
    local rebirths = selectForPlayer(PlayerDataSelectors.selectPlayerRebirthCount) or 0
    local stats = selectForPlayer(PlayerDataSelectors.selectPlayerStats) or {}
    local money = stats.money or 0
    local owned = inventoryNames(inventory)
    local best

    for _, itemName in ipairs(order or {}) do
        local config = data and data[itemName]
        local requiredRebirths = rebirthRequirements and rebirthRequirements[itemName] or 0
        local price = config and (config.price or config.cost) or math.huge
        if rebirths >= requiredRebirths and money >= price and not owned[itemName] then
            best = itemName
        end
    end

    if best and currentState then
        expectNetwork(Network.functions.purchaseShopItem, shopName, best)
    end
end

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoRebirth then
            local rebirths = selectForPlayer(PlayerDataSelectors.selectPlayerRebirthCount) or 0
            local stats = selectForPlayer(PlayerDataSelectors.selectPlayerStats) or {}
            if not RebirthUtils.isMaxRebirth(rebirths)
                and (stats.power or 0) >= RebirthUtils.getRebirthPowerCost(rebirths) then
                expectNetwork(Network.functions.performRebirth)
            end
        end

        if flags.AutoBuyRod then
            buyBestAffordable(
                "rodsShop",
                FishingRods.fishingRodOrder,
                FishingRods.fishingRodsData,
                FishingRods.rodRebirthRequirements
            )
        end

        if flags.AutoBuyWeight then
            buyBestAffordable(
                "weightsShop",
                TrainingWeights.trainingWeightOrder,
                TrainingWeights.trainingWeightsData,
                TrainingWeights.weightRebirthRequirements
            )
        end

        if flags.AutoSpinWheel then
            local spins = selectForPlayer(PlayerDataSelectors.selectPlayerStat, "spinWheelSpins") or 0
            if spins > 0 then
                expectNetwork(Network.functions.spinPlaytimeWheel)
            end
        end

        task.wait(1)
    end
end)

task.spawn(function()
    while not shared.IndraHub_BeAFish_Unloaded do
        if flags.AutoAquarium then
            local aquarium = selectForPlayer(PlayerDataSelectors.selectPlayerAquarium)
            if aquarium then
                expectNetwork(Network.functions.equipBestAquariumFish)
            end
        end

        if flags.AutoCollectAquariumMoney then
            local uncollected = selectForPlayer(PlayerDataSelectors.selectPlayerAquariumUncollectedMoney) or 0
            if uncollected > 0 then
                expectNetwork(Network.functions.collectPlotMoney, LocalPlayer.UserId)
            end
        end

        if flags.AutoUpgradeAquarium then
            local startedAt = selectForPlayer(PlayerDataSelectors.selectPlayerAquariumUpgradeStartedTimestamp)
            local canAfford = PlayerDataSelectors.selectCanAffordAquariumUpgrade
                and selectForPlayer(PlayerDataSelectors.selectCanAffordAquariumUpgrade)
            if not startedAt and canAfford then
                expectNetwork(Network.functions.upgradeAquarium)
            end
        end

        if flags.AutoRevealAquarium then
            local startedAt = selectForPlayer(PlayerDataSelectors.selectPlayerAquariumUpgradeStartedTimestamp)
            if startedAt then
                expectNetwork(Network.functions.confirmAquariumUpgrade)
            end
        end

        task.wait(2.5)
    end
end)





Tabs.S:Toggle({
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

Tabs.S:Button({
    Title = "Unload Script",
    Callback = function()
        shared.IndraHub_BeAFish_Unloaded = true
        if flags.HB then flags.HB:Disconnect() end
        if Window then Window:Destroy() end
        
        -- Restore original hooks
        if originalCastOnStart and CastCutSceneComponent then
            CastCutSceneComponent.onStart = originalCastOnStart
        end
        if originalReelStarted and FishingRodController then
            FishingRodController._onReelStarted = originalReelStarted
        end
        if reelCameraState and originalDiagonalTweenDuration then
            reelCameraState.diagonalTweenDuration = originalDiagonalTweenDuration
        end
    end
})

WindUI:Notify({ Title = "IndraHub", Content = "Loaded Be A Fish Bait", Duration = 5 })
