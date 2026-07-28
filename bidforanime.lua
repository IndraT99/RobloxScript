local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local Misc = ReplicatedStorage:WaitForChild("BrainrotsThings"):WaitForChild("Misc")
local BrainrotEconomy = require(Misc:WaitForChild("BrainrotEconomy"))
local Events = Misc:WaitForChild("Events")
local PlayerEvents = Events:WaitForChild("Player")
local TableEvents = Events:WaitForChild("Tables")

local QuickJoin = PlayerEvents:WaitForChild("QuickJoin")
local RequestInventory = PlayerEvents:WaitForChild("RequestInventory")
local InventoryUpdated = PlayerEvents:WaitForChild("InventoryUpdated")
local CollectCash = PlayerEvents:WaitForChild("CollectCash")
local ClaimOfflineEarnings = PlayerEvents:WaitForChild("ClaimOfflineEarnings")
local EquipBestBrainrots = PlayerEvents:WaitForChild("EquipBestBrainrots")
local ToggleFavourite = PlayerEvents:WaitForChild("ToggleFavourite")
local SellAll = PlayerEvents:WaitForChild("SellAll")
local SellItem = PlayerEvents:WaitForChild("SellItem")
local RebirthRequest = PlayerEvents:WaitForChild("RebirthRequest")
local PurchaseLuckUpgrade = PlayerEvents:WaitForChild("PurchaseLuckUpgrade")
local RequestIndex = PlayerEvents:WaitForChild("RequestIndex")
local IndexUpdated = PlayerEvents:WaitForChild("IndexUpdated")
local LuckBroadcast = PlayerEvents:WaitForChild("LuckBroadcast")
local MoneyBroadcast = PlayerEvents:WaitForChild("MoneyBroadcast")
local ChairShopUpdated = PlayerEvents:WaitForChild("ChairShopUpdated")
local PurchaseChair = PlayerEvents:WaitForChild("PurchaseChair")
local EquipChair = PlayerEvents:WaitForChild("EquipChair")

local AuctionStarted = TableEvents:WaitForChild("AuctionStarted")
local AuctionStateUpdated = TableEvents:WaitForChild("AuctionStateUpdated")
local AuctionEnded = TableEvents:WaitForChild("AuctionEnded")
local AuctionCancelled = TableEvents:WaitForChild("AuctionCancelled")
local AuctionPrompt = TableEvents:WaitForChild("AuctionPrompt")
local BidSubmitted = TableEvents:WaitForChild("BidSubmitted")
local BidRejected = TableEvents:WaitForChild("BidRejected")
local PlayWithAIRequest = TableEvents:WaitForChild("PlayWithAIRequest")
local TableOptionRequest = TableEvents:WaitForChild("TableOptionRequest")
local GetTableOptionConfig = TableEvents:WaitForChild("GetTableOptionConfig")

local SpinWheelRemotes = ReplicatedStorage:WaitForChild("SpinWheelRemotes")
local SpinRequest = SpinWheelRemotes:WaitForChild("SpinRequest")
local SpinResult = SpinWheelRemotes:WaitForChild("SpinResult")
local RewardedAdSpinRequest = SpinWheelRemotes:WaitForChild("RewardedAdSpinRequest")

local GAME_NAME = "Bid for Anime!"
local DISCORD_INVITE = "https://discord.gg/2PPBJsmqr"



local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_INVITE)
    elseif toclipboard then
        toclipboard(DISCORD_INVITE)
    end
    WindUI:Notify("Copied Discord invite to clipboard")
end

local RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Celestial",
    "Divine",
    "Anime God",
}

local SELLABLE_RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Celestial",
}

local VARIANTS = {
    "Normal",
    "Golden",
    "Diamond",
    "Galaxy",
    "Lava",
    "Volcanic",
    "Rainbow",
    "Hacked",
    "Void",
}

local BID_TIERS = { "Small", "Medium", "High", "Extreme" }
local TABLE_OPTIONS = { "GuaranteedSecret", "GuaranteedDivine", "LuckyBlock" }

local inventory = {}
local favourites = {}
local indexEntries = {}
local playerLuck = {}
local playerMoney = {}
local chairShop = nil
local activeAuction = nil
local activePrompt = nil
local lastPromptId = nil
local spinning = false

local Tables = workspace:WaitForChild("Map"):WaitForChild("Tables")
local LeaveTableAction = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ConsoleActions"):WaitForChild("BidConsoleLeaveTable")

InventoryUpdated.OnClientEvent:Connect(function(items, _, favourited)
    inventory = type(items) == "table" and items or {}
    favourites = type(favourited) == "table" and favourited or {}
end)

IndexUpdated.OnClientEvent:Connect(function(mode, entries)
    if mode == "__FULL__" and type(entries) == "table" then
        indexEntries = entries
    end
end)

LuckBroadcast.OnClientEvent:Connect(function(userId, luck)
    playerLuck[userId] = tonumber(luck) or 0
end)

MoneyBroadcast.OnClientEvent:Connect(function(userId, money)
    playerMoney[userId] = tonumber(money) or 0
end)

ChairShopUpdated.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" then
        chairShop = payload
    end
end)

local function setAuction(payload)
    if type(payload) == "table" then
        activeAuction = payload
    end
end

AuctionStarted.OnClientEvent:Connect(setAuction)
AuctionStateUpdated.OnClientEvent:Connect(setAuction)

local function clearAuction()
    activeAuction = nil
    activePrompt = nil
end

AuctionEnded.OnClientEvent:Connect(clearAuction)
AuctionCancelled.OnClientEvent:Connect(clearAuction)

SpinResult.OnClientEvent:Connect(function()
    spinning = false
end)

RequestInventory:FireServer()

local function isOn(name)
    local toggle = Toggles[name]
    return toggle ~= nil and toggle.Value == true
end

local function getNumber(name, fallback)
    local option = Options[name]
    return option and tonumber(option.Value) or fallback
end

local function getSelected(name)
    local option = Options[name]
    local value = option and option.Value
    return type(value) == "table" and value or {}
end

local function getMoney()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local money = stats and stats:FindFirstChild("Money")
    return money and money.Value or 0
end

local function isFavourited(id)
    for _, favourite in favourites do
        if favourite == id then
            return true
        end
    end
    return false
end

local function isSeated()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    return seat ~= nil and seat:IsDescendantOf(Tables)
end

local function leaveTable()
    pcall(function()
        LeaveTableAction:Invoke()
    end)
    clearAuction()
end

local function currentBrainrot()
    if type(activeAuction) ~= "table" or type(activeAuction.brainrot) ~= "table" then
        return nil
    end
    return activeAuction.brainrot
end

local function isMissingFromIndex(brainrot)
    if not brainrot or not brainrot.sourceType or not brainrot.name or not brainrot.variant then
        return false
    end
    return indexEntries[brainrot.sourceType .. "|" .. brainrot.name .. "|" .. brainrot.variant] ~= true
end

local function matchesBidFilters(brainrot)
    local rarities = getSelected("BidRarities")
    local variants = getSelected("BidVariants")
    local hasRarity = next(rarities) ~= nil
    local hasVariant = next(variants) ~= nil

    if not hasRarity and not hasVariant then
        return true
    end

    if not brainrot then
        return true
    end

    return (hasRarity and rarities[brainrot.rarity] == true) or (hasVariant and variants[brainrot.variant] == true)
end

local function hasBadOpponent()
    local participants = type(activeAuction) == "table" and activeAuction.participants
    if type(participants) ~= "table" then
        return false
    end

    local minLuck = getNumber("MinOpponentLuck", 0)
    local minMoney = getNumber("MinOpponentMoney", 0)

    for _, participant in participants do
        local userId = type(participant) == "table" and participant.userId
        if userId and userId ~= LocalPlayer.UserId then
            local luck = playerLuck[userId] or 0
            local money = tonumber(participant.money) or playerMoney[userId] or 0
            if minLuck > 0 and luck < minLuck then
                return true
            end
            if minMoney > 0 and money < minMoney then
                return true
            end
        end
    end

    return false
end

local function isCheapAuction(prompt)
    local floor = getNumber("PassUnder", 0)
    if floor <= 0 then
        return false
    end

    local options = type(prompt.options) == "table" and prompt.options or {}
    local lowest = nil

    for _, option in options do
        local amount = tonumber(option and option.amount)
        if amount and (not lowest or amount < lowest) then
            lowest = amount
        end
    end

    return lowest ~= nil and lowest < floor
end

local function pickBidIndex(prompt, ignoreLimits)
    local cap = ignoreLimits and 0 or getNumber("MaxBid", 0)
    local strategy = ignoreLimits and "Highest Affordable"
        or (flags.BidStrategy)
    local options = type(prompt.options) == "table" and prompt.options or {}

    local function usable(index)
        local option = options[index]
        if not option or option.canAfford ~= true then
            return false
        end
        local amount = tonumber(option.amount) or 0
        return cap <= 0 or amount <= cap
    end

    for tier, name in BID_TIERS do
        if strategy == name then
            return usable(tier) and tier or nil
        end
    end

    if strategy == "Lowest" then
        for index = 1, #BID_TIERS do
            if usable(index) then
                return index
            end
        end
        return nil
    end

    for index = #BID_TIERS, 1, -1 do
        if usable(index) then
            return index
        end
    end
    return nil
end

local function respondToPrompt(prompt)
    local brainrot = currentBrainrot()
    local index = nil

    if isOn("IndexPriority") and isMissingFromIndex(brainrot) then
        index = pickBidIndex(prompt, true)
    elseif matchesBidFilters(brainrot) and not (isOn("AutoPassCheap") and isCheapAuction(prompt)) then
        index = pickBidIndex(prompt, false)
    end

    if index then
        local option = prompt.options[index]
        BidSubmitted:FireServer({
            action = "bid",
            auctionId = prompt.auctionId,
            promptId = prompt.promptId,
            amount = option.amount,
        })
        return
    end

    if prompt.canPass == true then
        BidSubmitted:FireServer({
            action = "pass",
            auctionId = prompt.auctionId,
            promptId = prompt.promptId,
        })
    end
end

AuctionStarted.OnClientEvent:Connect(function()
    if Library.Unloaded or not isOn("AutoLeaveBad") then
        return
    end

    if hasBadOpponent() then
        leaveTable()
    end
end)

AuctionPrompt.OnClientEvent:Connect(function(prompt)
    if type(prompt) ~= "table" then
        return
    end

    activePrompt = prompt

    if not prompt.active or Library.Unloaded or not isOn("AutoBid") then
        return
    end

    lastPromptId = prompt.promptId

    task.delay(getNumber("BidDelay", 0.5), function()
        if Library.Unloaded or not isOn("AutoBid") or activePrompt ~= prompt then
            return
        end
        respondToPrompt(prompt)
    end)
end)

BidRejected.OnClientEvent:Connect(function(payload)
    if not isOn("AutoBid") or type(activePrompt) ~= "table" or not activePrompt.active then
        return
    end

    if type(payload) == "table" and payload.promptId and payload.promptId ~= lastPromptId then
        return
    end

    if activePrompt.canPass == true then
        BidSubmitted:FireServer({
            action = "pass",
            auctionId = activePrompt.auctionId,
            promptId = activePrompt.promptId,
        })
    end
end)


-------------------------------------------------------------------------
-- WINDUI INTEGRATION & SUPERVISOR INIT
-------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local flags = {
    AutoJoin = false,
    AutoPlayAI = false,
    JoinDelay = 0.5,
    AutoLeaveBad = false,
    MinOpponentLuck = 0,
    MinOpponentMoney = 0,
    AutoBid = false,
    BidStrategy = "Highest Affordable",
    MaxBid = 0,
    BidRarities = {},
    BidVariants = {},
    IndexPriority = false,
    AutoPassCheap = false,
    PassUnder = 0,
    BidDelay = 0.5,
    AutoSpin = false,
    SpinDelay = 8,
    AutoLuck = false,
    LuckAmount = "100",
    LuckReserve = 0,
    LuckDelay = 2,
    AutoBuyChair = false,
    ChairDelay = 5,
    AutoTableOption = false,
    TableOption = "GuaranteedSecret",
    AutoCollect = false,
    AutoEquipBest = false,
    AutoRebirth = false,
    CashDelay = 2,
    AutoFavourite = false,
    FavouriteRarities = {},
    FavouriteVariants = {},
    AutoUnfavourite = false,
    UnfavouriteRarities = {},
    UnfavouriteVariants = {},
    AutoSell = false,
    SellRarities = {},
    AutoSellEarn = false,
    SellUnderEarn = 0,
    SellDelay = 5,
    AntiAfk = true,
}

getgenv().IndraHub_Unloaded = false

local function isOn(name) return flags[name] == true end
local function getNumber(name, fallback) return tonumber(flags[name]) or fallback end
local function getSelected(name) return type(flags[name]) == "table" and flags[name] or {} end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Bid For Anime",
    Icon = "image-play",
    Author = ".indrahub",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "IndraHub",
    Icon = "image-play",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29"))
})

local Tabs = {
    Info = Window:Tab({ Title = "Info", Icon = "info" }),
    Auction = Window:Tab({ Title = "Auction", Icon = "gavel" }),
    Luck = Window:Tab({ Title = "Luck", Icon = "clover" }),
    Economy = Window:Tab({ Title = "Economy", Icon = "coins" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" })
}

-- INFO TAB
Tabs.Info:Paragraph({
    Title = "Ouroboros Hub x IndraHub",
    Desc = "This is a refactored script for Bid for Anime! integrating IndraHub standard WindUI and anti-AFK."
})
Tabs.Info:Button({
    Title = "Join Discord",
    Desc = "Copy Ouroboros Discord link to clipboard",
    Callback = copyDiscord
})
Tabs.Info:Paragraph({
    Title = "Executor Info",
    Desc = "Game: " .. GAME_NAME .. "\nPlayer: " .. LocalPlayer.Name .. "\nStatus: Keyless"
})

-- AUCTION TAB
Tabs.Auction:Section({ Title = "Auto Join", TextXAlignment = "Left" })
Tabs.Auction:Toggle({
    Title = "Auto Join Auction",
    Default = flags.AutoJoin,
    Callback = function(val) flags.AutoJoin = val end
})
Tabs.Auction:Toggle({
    Title = "Duel AI When Empty",
    Default = flags.AutoPlayAI,
    Callback = function(val) flags.AutoPlayAI = val end
})
Tabs.Auction:Slider({
    Title = "Join Delay",
    Value = flags.JoinDelay,
    Step = 0.1,
    Min = 0.1,
    Max = 20,
    Callback = function(val) flags.JoinDelay = val end
})

Tabs.Auction:Section({ Title = "Auto Leave", TextXAlignment = "Left" })
Tabs.Auction:Toggle({
    Title = "Leave Bad Opponents",
    Default = flags.AutoLeaveBad,
    Callback = function(val) flags.AutoLeaveBad = val end
})
Tabs.Auction:Input({
    Title = "Min Opponent Luck",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.MinOpponentLuck = tonumber(val) or 0 end
})
Tabs.Auction:Input({
    Title = "Min Opponent Money",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.MinOpponentMoney = tonumber(val) or 0 end
})

Tabs.Auction:Section({ Title = "Auto Bid", TextXAlignment = "Left" })
Tabs.Auction:Toggle({
    Title = "Auto Bid",
    Default = flags.AutoBid,
    Callback = function(val) flags.AutoBid = val end
})
Tabs.Auction:Dropdown({
    Title = "Bid Strategy",
    Values = { "Highest Affordable", "Lowest", "Small", "Medium", "High", "Extreme" },
    Value = "Highest Affordable",
    Callback = function(val) flags.BidStrategy = val end
})
Tabs.Auction:Input({
    Title = "Max Bid",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.MaxBid = tonumber(val) or 0 end
})

local function syncMulti(flagName)
    return function(val)
        if type(val) == "table" then
            local map = {}
            for _, v in ipairs(val) do map[v] = true end
            flags[flagName] = map
        else
            if val then flags[flagName][val] = true else flags[flagName] = {} end
        end
    end
end

Tabs.Auction:Dropdown({
    Title = "Only Bid Rarities",
    MultiSelection = true,
    Values = RARITIES,
    Callback = syncMulti("BidRarities")
})
Tabs.Auction:Dropdown({
    Title = "Only Bid Variants",
    MultiSelection = true,
    Values = VARIANTS,
    Callback = syncMulti("BidVariants")
})
Tabs.Auction:Toggle({
    Title = "Always Bid For Index",
    Default = flags.IndexPriority,
    Callback = function(val) flags.IndexPriority = val end
})
Tabs.Auction:Toggle({
    Title = "Auto Pass Cheap Animes",
    Default = flags.AutoPassCheap,
    Callback = function(val) flags.AutoPassCheap = val end
})
Tabs.Auction:Input({
    Title = "Pass Under",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.PassUnder = tonumber(val) or 0 end
})
Tabs.Auction:Slider({
    Title = "Bid Delay",
    Value = flags.BidDelay,
    Step = 0.1,
    Min = 0,
    Max = 8,
    Callback = function(val) flags.BidDelay = val end
})

-- LUCK TAB
Tabs.Luck:Section({ Title = "Spin Wheel", TextXAlignment = "Left" })
Tabs.Luck:Toggle({
    Title = "Auto Spin",
    Default = flags.AutoSpin,
    Callback = function(val) flags.AutoSpin = val end
})
Tabs.Luck:Slider({
    Title = "Spin Delay",
    Value = flags.SpinDelay,
    Step = 1,
    Min = 3,
    Max = 30,
    Callback = function(val) flags.SpinDelay = val end
})
Tabs.Luck:Button({
    Title = "Use Rewarded Ad Spin",
    Callback = function()
        if (LocalPlayer:GetAttribute("RewardedAdSpinsRemaining") or 0) <= 0 then
            WindUI:Notify({ Title = "Spin", Content = "No rewarded ad spins left today", Duration = 3 })
            return
        end
        RewardedAdSpinRequest:FireServer()
    end
})

Tabs.Luck:Section({ Title = "Luck Upgrades", TextXAlignment = "Left" })
Tabs.Luck:Toggle({
    Title = "Auto Buy Luck",
    Default = flags.AutoLuck,
    Callback = function(val) flags.AutoLuck = val end
})
Tabs.Luck:Dropdown({
    Title = "Luck Per Purchase",
    Values = { "10", "50", "100" },
    Value = "100",
    Callback = function(val) flags.LuckAmount = val end
})
Tabs.Luck:Input({
    Title = "Keep Money Reserve",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.LuckReserve = tonumber(val) or 0 end
})
Tabs.Luck:Slider({
    Title = "Luck Loop Delay",
    Value = flags.LuckDelay,
    Step = 0.5,
    Min = 0.5,
    Max = 30,
    Callback = function(val) flags.LuckDelay = val end
})

Tabs.Luck:Section({ Title = "Chairs & Blocks", TextXAlignment = "Left" })
Tabs.Luck:Toggle({
    Title = "Auto Buy Best Chair",
    Default = flags.AutoBuyChair,
    Callback = function(val) flags.AutoBuyChair = val end
})
Tabs.Luck:Slider({
    Title = "Chair Loop Delay",
    Value = flags.ChairDelay,
    Step = 1,
    Min = 1,
    Max = 60,
    Callback = function(val) flags.ChairDelay = val end
})
Tabs.Luck:Toggle({
    Title = "Auto Use Tokens",
    Default = flags.AutoTableOption,
    Callback = function(val) flags.AutoTableOption = val end
})
Tabs.Luck:Dropdown({
    Title = "Token Type",
    Values = TABLE_OPTIONS,
    Value = "GuaranteedSecret",
    Callback = function(val) flags.TableOption = val end
})

-- ECONOMY TAB
Tabs.Economy:Section({ Title = "Cash", TextXAlignment = "Left" })
Tabs.Economy:Toggle({
    Title = "Auto Collect Cash",
    Default = flags.AutoCollect,
    Callback = function(val) flags.AutoCollect = val end
})
Tabs.Economy:Toggle({
    Title = "Auto Equip Best",
    Default = flags.AutoEquipBest,
    Callback = function(val) flags.AutoEquipBest = val end
})
Tabs.Economy:Toggle({
    Title = "Auto Rebirth",
    Default = flags.AutoRebirth,
    Callback = function(val) flags.AutoRebirth = val end
})
Tabs.Economy:Slider({
    Title = "Cash Loop Delay",
    Value = flags.CashDelay,
    Step = 0.5,
    Min = 0.5,
    Max = 30,
    Callback = function(val) flags.CashDelay = val end
})
Tabs.Economy:Button({
    Title = "Claim Offline Earnings",
    Callback = function() ClaimOfflineEarnings:FireServer() end
})

Tabs.Economy:Section({ Title = "Collection", TextXAlignment = "Left" })
Tabs.Economy:Toggle({
    Title = "Auto Favorite",
    Default = flags.AutoFavourite,
    Callback = function(val) flags.AutoFavourite = val end
})
Tabs.Economy:Dropdown({
    Title = "Favorite Rarities",
    MultiSelection = true,
    Values = RARITIES,
    Callback = syncMulti("FavouriteRarities")
})
Tabs.Economy:Dropdown({
    Title = "Favorite Variants",
    MultiSelection = true,
    Values = VARIANTS,
    Callback = syncMulti("FavouriteVariants")
})
Tabs.Economy:Toggle({
    Title = "Auto Unfavorite",
    Default = flags.AutoUnfavourite,
    Callback = function(val) flags.AutoUnfavourite = val end
})
Tabs.Economy:Dropdown({
    Title = "Unfavorite Rarities",
    MultiSelection = true,
    Values = RARITIES,
    Callback = syncMulti("UnfavouriteRarities")
})
Tabs.Economy:Dropdown({
    Title = "Unfavorite Variants",
    MultiSelection = true,
    Values = VARIANTS,
    Callback = syncMulti("UnfavouriteVariants")
})
Tabs.Economy:Button({
    Title = "Unfavorite Everything",
    Callback = function()
        local ids = table.clone(favourites)
        task.spawn(function()
            for _, id in ids do
                ToggleFavourite:FireServer(id)
                task.wait(0.15)
            end
            WindUI:Notify({ Title = "Success", Content = "Unfavorited " .. #ids .. " animes", Duration = 3 })
        end)
    end
})

Tabs.Economy:Section({ Title = "Auto Sell", TextXAlignment = "Left" })
Tabs.Economy:Toggle({
    Title = "Auto Sell",
    Default = flags.AutoSell,
    Callback = function(val) flags.AutoSell = val end
})
Tabs.Economy:Dropdown({
    Title = "Sell Rarities",
    MultiSelection = true,
    Values = SELLABLE_RARITIES,
    Callback = syncMulti("SellRarities")
})
Tabs.Economy:Toggle({
    Title = "Auto Sell By Earn",
    Default = flags.AutoSellEarn,
    Callback = function(val) flags.AutoSellEarn = val end
})
Tabs.Economy:Input({
    Title = "Sell Under Cash Per Second",
    PlaceholderText = "0",
    NumbersOnly = true,
    OnEnter = true,
    Callback = function(val) flags.SellUnderEarn = tonumber(val) or 0 end
})
Tabs.Economy:Slider({
    Title = "Sell Loop Delay",
    Value = flags.SellDelay,
    Step = 1,
    Min = 1,
    Max = 60,
    Callback = function(val) flags.SellDelay = val end
})

-- SETTINGS TAB
Tabs.Settings:Section({ Title = "System", TextXAlignment = "Left" })
Tabs.Settings:Toggle({
    Title = "Anti-AFK",
    Default = flags.AntiAfk,
    Callback = function(val) flags.AntiAfk = val end
})

Tabs.Settings:Button({
    Title = "Unload Script",
    Callback = function()
        getgenv().IndraHub_Unloaded = true
        pcall(function() Window:Destroy() end)
    end
})

-------------------------------------------------------------------------
-- HEARTBEAT & ANTI-AFK
-------------------------------------------------------------------------
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    local uis = game:GetService("UserInputService")
    
    local antiAfkLastInput = tick()
    local antiAfkLastTap = tick()

    pcall(function()
        for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
            pcall(function() connection:Disable() end)
        end
    end)
    
    local c1 = uis.InputBegan:Connect(function() antiAfkLastInput = tick() end)
    local c2 = uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Gamepad1 then
            antiAfkLastInput = tick()
        end
    end)
    
    while not IndraHub_Unloaded do
        task.wait(2)
        getgenv().IndraHubBidForAnimeLastHeartbeat = os.clock()
        getgenv().IndraHubBidForAnimeRunning = true

        if isOn("AntiAfk") then
            local idle = tick() - antiAfkLastInput
            local sinceTap = tick() - antiAfkLastTap
            if idle >= 300 and sinceTap >= 60 then
                pcall(function()
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                antiAfkLastTap = tick()
            end
        end
    end
    
    c1:Disconnect()
    c2:Disconnect()
    getgenv().IndraHubBidForAnimeRunning = false
end)



task.spawn(function()
    local lastAIRequest = 0

    while not IndraHub_Unloaded do
        if isOn("AutoJoin") and LocalPlayer:GetAttribute("ClientInDuel") ~= true then
            if not isSeated() then
                QuickJoin:FireServer()
            elseif isOn("AutoPlayAI") and not activeAuction and tick() - lastAIRequest >= 3 then
                lastAIRequest = tick()
                PlayWithAIRequest:FireServer()
            end
        end
        task.wait(getNumber("JoinDelay", 0.5))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoTableOption") and not activeAuction then
            local ok, config = pcall(function()
                return GetTableOptionConfig:InvokeServer()
            end)

            if ok and type(config) == "table" then
                local key = flags.TableOption
                local entry = key and config[key]
                if entry and (tonumber(entry.tokenCount) or 0) > 0 and config._activeKey ~= key then
                    TableOptionRequest:FireServer(key)
                end
            end
        end
        task.wait(5)
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoSpin") and not spinning and (LocalPlayer:GetAttribute("SpinRounds") or 0) > 0 then
            spinning = true
            SpinRequest:FireServer()
            task.delay(getNumber("SpinDelay", 8) + 5, function()
                spinning = false
            end)
        end
        task.wait(getNumber("SpinDelay", 8))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoLuck") and getMoney() > getNumber("LuckReserve", 0) then
            PurchaseLuckUpgrade:FireServer(flags.LuckAmount)
        end
        task.wait(getNumber("LuckDelay", 2))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoCollect") then
            CollectCash:FireServer()
        end
        if isOn("AutoEquipBest") then
            EquipBestBrainrots:FireServer()
        end
        if isOn("AutoRebirth") then
            RebirthRequest:FireServer()
        end
        task.wait(getNumber("CashDelay", 2))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoFavourite") then
            local rarities = getSelected("FavouriteRarities")
            local variants = getSelected("FavouriteVariants")

            for _, item in inventory do
                if type(item) == "table" and item.id and not isFavourited(item.id) then
                    if rarities[item.rarity] or variants[item.variant] then
                        ToggleFavourite:FireServer(item.id)
                        task.wait(0.15)
                    end
                end
            end
        end

        if isOn("AutoUnfavourite") then
            local rarities = getSelected("UnfavouriteRarities")
            local variants = getSelected("UnfavouriteVariants")

            for _, item in inventory do
                if type(item) == "table" and item.id and isFavourited(item.id) then
                    if rarities[item.rarity] or variants[item.variant] then
                        ToggleFavourite:FireServer(item.id)
                        task.wait(0.15)
                    end
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoSell") then
            local rarities = getSelected("SellRarities")
            for _, rarity in SELLABLE_RARITIES do
                if rarities[rarity] then
                    SellAll:FireServer(rarity)
                    task.wait(0.3)
                end
            end
        end

        if isOn("AutoSellEarn") then
            local threshold = getNumber("SellUnderEarn", 0)
            if threshold > 0 then
                for _, item in inventory do
                    if type(item) == "table" and item.id and not isFavourited(item.id) then
                        local ok, earn = pcall(BrainrotEconomy.getCashPerSecondForItem, item)
                        if ok and (tonumber(earn) or 0) < threshold then
                            SellItem:FireServer(item.id)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait(getNumber("SellDelay", 5))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        if isOn("AutoBuyChair") then
            if not chairShop then
                PurchaseChair:FireServer("DefaultChair")
            else
                local normal = type(chairShop.normal) == "table" and chairShop.normal or {}
                local money = getMoney()
                local target, targetLuck = nil, -1

                for name, chair in normal do
                    if type(chair) == "table" and chair.owned ~= true and (tonumber(chair.price) or math.huge) <= money then
                        local luck = tonumber(chair.luck) or 0
                        if luck > targetLuck then
                            target, targetLuck = name, luck
                        end
                    end
                end

                if target then
                    PurchaseChair:FireServer(target)
                else
                    local best, bestLuck = nil, -1

                    for _, group in { normal, type(chairShop.special) == "table" and chairShop.special or {} } do
                        for name, chair in group do
                            if type(chair) == "table" and chair.owned == true then
                                local luck = tonumber(chair.luck) or 0
                                if luck > bestLuck then
                                    best, bestLuck = name, luck
                                end
                            end
                        end
                    end

                    if best and chairShop.equippedChair ~= best then
                        EquipChair:FireServer(best)
                        chairShop.equippedChair = best
                    end
                end
            end
        end
        task.wait(getNumber("ChairDelay", 5))
    end
end)

task.spawn(function()
    while not IndraHub_Unloaded do
        RequestInventory:FireServer()
        RequestIndex:FireServer()
        task.wait(10)
    end
end)
