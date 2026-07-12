local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

-- Supervisor Check
if getGlobal("IndraHubGrowItRunning") then
    return
end
setGlobal("IndraHubGrowItRunning", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        setGlobal("IndraHubGrowItLastHeartbeat", os.time())
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Grow It RNG",
    Icon = "sprout",
    Author = "IndraHub",
    Folder = "IndraHubGrowIt",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PlantSeed = Remotes:WaitForChild("PlantSeed")
local DepositCrop = Remotes:WaitForChild("DepositCrop")
local CustomerOffer = Remotes:WaitForChild("CustomerOffer")
local CustomerOfferClear = Remotes:WaitForChild("CustomerOfferClear")
local CustomerDecision = Remotes:WaitForChild("CustomerDecision")
local BuySeedRequest = Remotes:WaitForChild("BuySeedRequest")
local BuyStructure = Remotes:WaitForChild("BuyStructure")
local OpenCrateCash = Remotes:WaitForChild("OpenCrateCash")
local BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
local QuestClaim = Remotes:WaitForChild("QuestClaim")
local PlaytimeClaim = Remotes:WaitForChild("PlaytimeClaim")
local RebirthRequest = Remotes:WaitForChild("RebirthRequest")
local RebirthBuyUpgrade = Remotes:WaitForChild("RebirthBuyUpgrade")
local RebirthBuyItem = Remotes:WaitForChild("RebirthBuyItem")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local SeedData = require(Modules:WaitForChild("SeedData"))
local PetData = require(Modules:WaitForChild("PetData"))
local RebirthConfig = require(Modules:WaitForChild("RebirthConfig"))
local BedData = require(Modules:WaitForChild("BedData"))
local SellTableData = require(Modules:WaitForChild("SellTableData"))
local TotemData = require(Modules:WaitForChild("TotemData"))
local DecorationData = require(Modules:WaitForChild("DecorationData"))
local GearData = require(Modules:WaitForChild("GearData"))
local CrateData = require(Modules:WaitForChild("CrateData"))

local Config = {
    AutoPlant = false, PlantInterval = 0.5,
    AutoBuySeeds = false, BuySeeds = {}, BuyAmount = 6, BuyInterval = 0.5,
    AutoGrow = false, GrowClicks = 10, GrowInterval = 0.3,
    AutoHarvest = false, HarvestInterval = 0.5,
    AutoExpand = false, ExpandInterval = 1,
    AutoUpgrade = false, FarmUpgrades = {}, UpgradeInterval = 1,
    AutoDeposit = false, DepositInterval = 0.5,
    AutoAccept = false, MinPrice = 0, DeclineBelow = false,
    AutoRush = false, RushInterval = 0.5,
    AutoCatch = false, CatchPets = {}, MaxCatchPrice = 0, CatchInterval = 0.5,
    AutoQuests = false, QuestInterval = 2,
    AutoPlaytime = false, PlaytimeInterval = 5,
    AutoRebirth = false, AutoRebirthUpgrades = false, RebirthUpgrades = {},
    AutoRebirthItems = false, RebirthItems = {}, RebirthInterval = 1,
    AutoBuyShop = false, ShopBuyAmount = 5, ShopInterval = 1, ShopKeepCash = 0,
    BuyBeds = {}, BuySellTables = {}, BuyTotems = {}, BuyGear = {}, BuyDecorations = {},
    AutoBuySprinklers = false, BuySprinklers = {}, SprinklerAmount = 1, SprinklerInterval = 1,
    AutoBuyCrates = false, BuyCrates = {}, CrateInterval = 2,
    AntiAFK = true
}

local seedNames, seedIdByName = {}, {}
for _, v in ipairs(SeedData.List) do
    local label = string.format("%s (t%s)", v.name, tostring(v.tier))
    table.insert(seedNames, label)
    seedIdByName[label] = v.id
end

local petNames = {}
for _, v in ipairs(PetData.Pets) do
    if v.model then table.insert(petNames, v.model) end
end

local rebirthUpgradeNames, rebirthUpgradeKey = {}, {}
for _, v in ipairs(RebirthConfig.Upgrades) do
    table.insert(rebirthUpgradeNames, v.name)
    rebirthUpgradeKey[v.name] = v.key
end

local rebirthItemNames, rebirthItemKey = {}, {}
for _, v in ipairs(RebirthConfig.Items) do
    table.insert(rebirthItemNames, v.name)
    rebirthItemKey[v.name] = v.key
end

local function buildShopEntries(list)
    local names, idByName, priceByName = {}, {}, {}
    for _, v in ipairs(list) do
        local price = v.cost or v.cashCost or 0
        local label = string.format("%s ($%s)", v.name, tostring(price))
        table.insert(names, label)
        idByName[label] = v.id
        priceByName[label] = price
    end
    return names, idByName, priceByName
end

local bedNames, bedIdByName, bedPriceByName = buildShopEntries(BedData.List)
local tableNames, tableIdByName, tablePriceByName = buildShopEntries(SellTableData.List)
local totemNames, totemIdByName, totemPriceByName = buildShopEntries(TotemData.List)
local decorNames, decorIdByName, decorPriceByName = buildShopEntries(DecorationData.List)
local gearNames, gearIdByName, gearPriceByName = buildShopEntries(GearData.List)
local crateNames, crateIdByName, cratePriceByName = buildShopEntries(CrateData.List)

local sprinklerList = {}
for _, v in ipairs(DecorationData.List) do
    if string.find(v.name, "Sprinkler") then table.insert(sprinklerList, v) end
end
local sprinklerNames, sprinklerIdByName, sprinklerPriceByName = buildShopEntries(sprinklerList)

local playtimeMinutes = {}
local playtimeCfg = ReplicatedStorage:FindFirstChild("PlaytimeRewardsConfig")
if playtimeCfg then
    for _, c in ipairs(playtimeCfg:GetChildren()) do
        local m = c:GetAttribute("Minutes") or c:GetAttribute("minutes") or tonumber(c.Name)
        if m then table.insert(playtimeMinutes, m) end
    end
    table.sort(playtimeMinutes)
end

local shopCategories = {
    { kind = "Bed", option = "BuyBeds", ids = bedIdByName, prices = bedPriceByName },
    { kind = "SellTable", option = "BuySellTables", ids = tableIdByName, prices = tablePriceByName },
    { kind = "Totem", option = "BuyTotems", ids = totemIdByName, prices = totemPriceByName },
    { kind = "Gear", option = "BuyGear", ids = gearIdByName, prices = gearPriceByName },
    { kind = "Decoration", option = "BuyDecorations", ids = decorIdByName, prices = decorPriceByName },
}

local function selectedList(value, map)
    local out = {}
    if type(value) == "table" then
        for k, v in pairs(value) do
            local name = type(k) == "number" and v or k
            local isSelected = type(k) == "number" and true or v
            if isSelected then
                local key = map[name]
                if key ~= nil then table.insert(out, key) end
            end
        end
    end
    return out
end

local function ownsModel(model)
    return model and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId
end

local function myPlot()
    local plots = workspace:FindFirstChild("Plots")
    local id = LocalPlayer:GetAttribute("PlotId")
    return plots and id and plots:FindFirstChild("Plot" .. tostring(id))
end

local function ownedToolsOfKind(kind)
    local result = {}
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("ToolKind") == kind then
                table.insert(result, child)
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("ToolKind") == kind then
                table.insert(result, child)
            end
        end
    end
    return result
end

local function equipTool(tool)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:EquipTool(tool) end
end

local function ownedBedSlots()
    local empty, growing, ripe = {}, {}, {}
    for _, slot in ipairs(CollectionService:GetTagged("GardenBedSlot")) do
        if slot:IsDescendantOf(workspace) and ownsModel(slot.Parent) then
            local seedId = slot:GetAttribute("SeedId") or 0
            if seedId == 0 then
                table.insert(empty, slot)
            elseif slot:GetAttribute("Ripe") == true then
                table.insert(ripe, slot)
            else
                table.insert(growing, slot)
            end
        end
    end
    return empty, growing, ripe
end

local function emptyTableSlots()
    local result = {}
    for _, slot in ipairs(CollectionService:GetTagged("SellTableSlot")) do
        if slot:IsDescendantOf(workspace) and ownsModel(slot.Parent) and (slot:GetAttribute("CropId") or 0) == 0 then
            table.insert(result, slot)
        end
    end
    return result
end

local function rootPart()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function safeFarmLoop(slots, maxDist, shouldContinueFunc, getInteractableFunc, actionFunc)
    local root = rootPart()
    if not root then return end
    local originalCFrame = root.CFrame
    local moved = false
    
    for _, slot in ipairs(slots) do
        if not getGlobal("IndraHubGrowItRunning") or not shouldContinueFunc() then break end
        
        local target = getInteractableFunc(slot)
        if target then
            if (root.Position - slot.Position).Magnitude > maxDist then
                root.CFrame = slot.CFrame + Vector3.new(0, 3, 0)
                moved = true
                task.wait(0.15)
            end
            
            if not getGlobal("IndraHubGrowItRunning") or not shouldContinueFunc() then break end
            actionFunc(slot, target)
        end
    end
    
    if moved then
        root.CFrame = originalCFrame
    end
end

local function affordable(price)
    local cash = LocalPlayer:GetAttribute("Cash") or 0
    local reserve = tonumber(Config.ShopKeepCash) or 0
    return cash - price >= reserve
end

-- TABS
local TabMain = Window:Tab({ Title = "Main", Icon = "home" })
local TabFarming = Window:Tab({ Title = "Farming", Icon = "leaf" })
local TabSelling = Window:Tab({ Title = "Selling", Icon = "coins" })
local TabPets = Window:Tab({ Title = "Pets & Rewards", Icon = "paw-print" })
local TabShop = Window:Tab({ Title = "Auto Shop", Icon = "shopping-cart" })

-- Main Tab
TabMain:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({Title="Success", Content="Discord invite copied to clipboard!"})
    end
})

TabMain:Toggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(state) Config.AntiAFK = state end
})

-- Farming Tab
TabFarming:Toggle({ Title = "Auto Plant Seeds", Default = false, Callback = function(v) Config.AutoPlant = v end })
TabFarming:Slider({ Title = "Plant Interval (s)", Step = 0.1, Value = 0.5, Min = 0.1, Max = 5, Callback = function(v) Config.PlantInterval = v end })
TabFarming:Toggle({ Title = "Auto Grow Rush", Default = false, Callback = function(v) Config.AutoGrow = v end })
TabFarming:Slider({ Title = "Rush Taps per cycle", Step = 1, Value = 10, Min = 1, Max = 40, Callback = function(v) Config.GrowClicks = v end })
TabFarming:Toggle({ Title = "Auto Harvest", Default = false, Callback = function(v) Config.AutoHarvest = v end })
TabFarming:Toggle({ Title = "Auto Buy Seeds", Default = false, Callback = function(v) Config.AutoBuySeeds = v end })
TabFarming:Dropdown({ Title = "Seeds to Buy", Multi = true, Values = seedNames, Callback = function(v) Config.BuySeeds = v end })
TabFarming:Slider({ Title = "Seed Buy Amount", Step = 1, Value = 6, Min = 1, Max = 50, Callback = function(v) Config.BuyAmount = v end })
TabFarming:Toggle({ Title = "Auto Expansion", Default = false, Callback = function(v) Config.AutoExpand = v end })
TabFarming:Toggle({ Title = "Auto Farm Upgrades", Default = false, Callback = function(v) Config.AutoUpgrade = v end })
TabFarming:Dropdown({ Title = "Farm Upgrades", Multi = true, Values = {"Grow", "Eat"}, Callback = function(v) Config.FarmUpgrades = v end })

-- Selling Tab
TabSelling:Toggle({ Title = "Auto Place Seeds on Table", Default = false, Callback = function(v) Config.AutoDeposit = v end })
TabSelling:Toggle({ Title = "Auto Accept Customer Offer", Default = false, Callback = function(v) Config.AutoAccept = v end })
TabSelling:Input({ Title = "Minimum Offer Price", Default = "0", Callback = function(v) Config.MinPrice = tonumber(v) or 0 end })
TabSelling:Toggle({ Title = "Decline Offers Below Min", Default = false, Callback = function(v) Config.DeclineBelow = v end })
TabSelling:Toggle({ Title = "Auto Rush Customer", Default = false, Callback = function(v) Config.AutoRush = v end })

-- Pets & Rewards Tab
TabPets:Toggle({ Title = "Auto Catch Wild Pets", Default = false, Callback = function(v) Config.AutoCatch = v end })
TabPets:Dropdown({ Title = "Pets to Catch", Multi = true, Values = petNames, Callback = function(v) Config.CatchPets = v end })
TabPets:Input({ Title = "Max Catch Price", Default = "0", Callback = function(v) Config.MaxCatchPrice = tonumber(v) or 0 end })
TabPets:Toggle({ Title = "Auto Claim Quests", Default = false, Callback = function(v) Config.AutoQuests = v end })
TabPets:Toggle({ Title = "Auto Claim Playtime", Default = false, Callback = function(v) Config.AutoPlaytime = v end })
TabPets:Toggle({ Title = "Auto Rebirth", Default = false, Callback = function(v) Config.AutoRebirth = v end })
TabPets:Toggle({ Title = "Auto Buy Rebirth Upgrades", Default = false, Callback = function(v) Config.AutoRebirthUpgrades = v end })
TabPets:Dropdown({ Title = "Rebirth Upgrades", Multi = true, Values = rebirthUpgradeNames, Callback = function(v) Config.RebirthUpgrades = v end })

-- Shop Tab
TabShop:Toggle({ Title = "Auto Buy Shop", Default = false, Callback = function(v) Config.AutoBuyShop = v end })
TabShop:Input({ Title = "Keep Cash Reserve", Default = "0", Callback = function(v) Config.ShopKeepCash = tonumber(v) or 0 end })
TabShop:Slider({ Title = "Shop Buy Amount", Step = 1, Value = 5, Min = 1, Max = 50, Callback = function(v) Config.ShopBuyAmount = v end })
TabShop:Dropdown({ Title = "Beds to buy", Multi = true, Values = bedNames, Callback = function(v) Config.BuyBeds = v end })
TabShop:Dropdown({ Title = "Sell Tables to buy", Multi = true, Values = tableNames, Callback = function(v) Config.BuySellTables = v end })
TabShop:Dropdown({ Title = "Totems to buy", Multi = true, Values = totemNames, Callback = function(v) Config.BuyTotems = v end })
TabShop:Dropdown({ Title = "Gear to buy", Multi = true, Values = gearNames, Callback = function(v) Config.BuyGear = v end })
TabShop:Toggle({ Title = "Auto Buy Sprinklers", Default = false, Callback = function(v) Config.AutoBuySprinklers = v end })
TabShop:Dropdown({ Title = "Sprinklers to buy", Multi = true, Values = sprinklerNames, Callback = function(v) Config.BuySprinklers = v end })
TabShop:Toggle({ Title = "Auto Buy Crates", Default = false, Callback = function(v) Config.AutoBuyCrates = v end })
TabShop:Dropdown({ Title = "Crates to buy", Multi = true, Values = crateNames, Callback = function(v) Config.BuyCrates = v end })

-- LOOPS
task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoPlant then
            task.wait(Config.PlantInterval)
            for _, slot in ipairs((ownedBedSlots())) do
                if not getGlobal("IndraHubGrowItRunning") or not Config.AutoPlant then break end
                local seed = ownedToolsOfKind("Seed")[1]
                if not seed then break end
                equipTool(seed)
                pcall(function() PlantSeed:InvokeServer(slot, seed) end)
                task.wait(0.1)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoBuySeeds then
            task.wait(Config.BuyInterval)
            local ids = selectedList(Config.BuySeeds, seedIdByName)
            if #ids > 0 then
                for i = 1, Config.BuyAmount do
                    if not getGlobal("IndraHubGrowItRunning") or not Config.AutoBuySeeds then break end
                    local id = ids[(i - 1) % #ids + 1]
                    pcall(function() BuySeedRequest:InvokeServer(id) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoGrow then
            task.wait(Config.GrowInterval)
            local _, growing = ownedBedSlots()
            safeFarmLoop(growing, 14, function() return Config.AutoGrow end, function(slot)
                return slot:FindFirstChild("SpeedupClick", true) or slot:FindFirstChildOfClass("ClickDetector", true)
            end, function(slot, target)
                for _ = 1, Config.GrowClicks do
                    if slot:GetAttribute("Ripe") == true then break end
                    pcall(function() fireclickdetector(target) end)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoHarvest then
            task.wait(Config.HarvestInterval)
            local _, _, ripe = ownedBedSlots()
            safeFarmLoop(ripe, 6, function() return Config.AutoHarvest end, function(slot)
                return slot:FindFirstChild("HarvestPrompt", true)
            end, function(slot, target)
                pcall(function() fireproximityprompt(target) end)
                task.wait(0.05)
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoDeposit then
            task.wait(Config.DepositInterval)
            if #ownedToolsOfKind("Crop") > 0 then
                for _, slot in ipairs(emptyTableSlots()) do
                    if not getGlobal("IndraHubGrowItRunning") or not Config.AutoDeposit then break end
                    local crop = ownedToolsOfKind("Crop")[1]
                    if not crop then break end
                    equipTool(crop)
                    DepositCrop:FireServer(slot, crop)
                    task.wait(0.1)
                end
            end
        end
    end
end)

local pendingOffers = {}
local function resolveOffer(customer, price)
    if not customer or not customer.Parent then return end
    local minPrice = tonumber(Config.MinPrice) or 0
    if (price or 0) >= minPrice then
        pendingOffers[customer] = nil
        pcall(function() CustomerDecision:FireServer(customer, true) end)
    elseif Config.DeclineBelow then
        pendingOffers[customer] = nil
        pcall(function() CustomerDecision:FireServer(customer, false) end)
    end
end

local coConn = CustomerOffer.OnClientEvent:Connect(function(customer, _, price)
    if not customer then return end
    pendingOffers[customer] = price or 0
    if Config.AutoAccept then resolveOffer(customer, price or 0) end
end)

local cocConn = CustomerOfferClear.OnClientEvent:Connect(function(customer)
    if customer then pendingOffers[customer] = nil else table.clear(pendingOffers) end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoAccept then
            for customer, price in pairs(pendingOffers) do
                if customer.Parent then resolveOffer(customer, price) else pendingOffers[customer] = nil end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoRush then
            task.wait(Config.RushInterval)
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Name == "RushPrompt" then
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoExpand then
            task.wait(Config.ExpandInterval)
            local plot = myPlot()
            if plot then
                for _, prompt in ipairs(plot:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Name == "UnlockPrompt" then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoUpgrade then
            task.wait(Config.UpgradeInterval)
            for _, key in ipairs(selectedList(Config.FarmUpgrades, {Grow="Grow", Eat="Eat"})) do
                pcall(function() BuyUpgrade:FireServer(key) end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoCatch then
            task.wait(Config.CatchInterval)
            local runtime = workspace:FindFirstChild("PetsRuntime")
            local root = rootPart()
            if runtime and root then
                local wanted = type(Config.CatchPets) == "table" and Config.CatchPets or {}
                local hasFilter = next(wanted) ~= nil
                local maxPrice = tonumber(Config.MaxCatchPrice) or 0
                local origin = root.CFrame
                local moved = false
                for _, pet in ipairs(runtime:GetChildren()) do
                    if not getGlobal("IndraHubGrowItRunning") or not Config.AutoCatch then break end
                    local checkWanted = not hasFilter
                    if hasFilter then
                        for wKey, wVal in pairs(wanted) do
                            if wVal and (type(wKey) == "number" and wVal == pet.Name or wKey == pet.Name) then checkWanted = true break end
                        end
                    end
                    if checkWanted and pet:IsDescendantOf(workspace) then
                        local prompt = pet:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local target = prompt and prompt.Parent
                        if prompt and target and target:IsA("BasePart") then
                            local ok = true
                            if maxPrice > 0 then
                                local priceStr = tostring(prompt.ActionText):match("%$([%d,]+)")
                                local price = priceStr and tonumber((priceStr:gsub(",", ""))) or 0
                                ok = price <= maxPrice
                            end
                            if ok then
                                root = rootPart()
                                if not root then break end
                                root.CFrame = target.CFrame + Vector3.new(0, 4, 0)
                                moved = true
                                task.wait(0.15)
                                if prompt.Parent and prompt.Enabled then
                                    pcall(function() fireproximityprompt(prompt) end)
                                    task.wait(math.max(prompt.HoldDuration + 0.05, 0.1))
                                end
                            end
                        end
                    end
                end
                if moved then root = rootPart() if root then root.CFrame = origin end end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoQuests then
            task.wait(Config.QuestInterval)
            pcall(function() QuestClaim:FireServer() end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoPlaytime then
            task.wait(Config.PlaytimeInterval)
            for _, minutes in ipairs(playtimeMinutes) do
                pcall(function() PlaytimeClaim:InvokeServer(minutes) end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        task.wait(Config.RebirthInterval)
        if Config.AutoRebirthUpgrades then
            for _, key in ipairs(selectedList(Config.RebirthUpgrades, rebirthUpgradeKey)) do
                pcall(function() RebirthBuyUpgrade:InvokeServer(key) end)
            end
        end
        if Config.AutoRebirthItems then
            for _, key in ipairs(selectedList(Config.RebirthItems, rebirthItemKey)) do
                pcall(function() RebirthBuyItem:InvokeServer(key) end)
            end
        end
        if Config.AutoRebirth then
            local cash = LocalPlayer:GetAttribute("Cash") or 0
            if RebirthConfig.canRebirth(cash) then
                pcall(function() RebirthRequest:FireServer() end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoBuyShop then
            task.wait(Config.ShopInterval)
            local bought = 0
            for _, category in ipairs(shopCategories) do
                if not getGlobal("IndraHubGrowItRunning") or not Config.AutoBuyShop then break end
                for _, id in ipairs(selectedList(Config[category.option], category.ids)) do
                    if bought >= Config.ShopBuyAmount then break end
                    if id and affordable(500) then -- Generic affordable check
                        pcall(function() BuyStructure:InvokeServer(category.kind, id) end)
                        bought = bought + 1
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoBuySprinklers then
            task.wait(Config.SprinklerInterval)
            local bought = 0
            for _, id in ipairs(selectedList(Config.BuySprinklers, sprinklerIdByName)) do
                if not getGlobal("IndraHubGrowItRunning") or not Config.AutoBuySprinklers then break end
                if bought >= Config.SprinklerAmount then break end
                if id and affordable(500) then
                    pcall(function() BuyStructure:InvokeServer("Decoration", id) end)
                    bought = bought + 1
                    task.wait(0.1)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubGrowItRunning") then break end
        if Config.AutoBuyCrates then
            task.wait(Config.CrateInterval)
            for _, id in ipairs(selectedList(Config.BuyCrates, crateIdByName)) do
                if not getGlobal("IndraHubGrowItRunning") or not Config.AutoBuyCrates then break end
                if id and affordable(500) then
                    pcall(function() OpenCrateCash:InvokeServer(id) end)
                    task.wait(0.2)
                end
            end
        end
    end
end)

local idledConn = LocalPlayer.Idled:Connect(function()
    if not getGlobal("IndraHubGrowItRunning") then return end
    if not Config.AntiAFK then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubGrowItRunning") then
            if coConn then coConn:Disconnect() end
            if cocConn then cocConn:Disconnect() end
            if idledConn then idledConn:Disconnect() end
            break
        end
    end
end)
