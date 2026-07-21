local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local Directories = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Directories")
local DataClient = require(ReplicatedStorage.Modules.Client.DataClient)
local UpgradeConfig = require(Directories.UpgradeConfig)
local StarShopConfig = require(Directories.StarShopConfig)

local HoleService = Knit.GetService("HoleService")
local ShieldService = Knit.GetService("ShieldService")
local RebirthService = Knit.GetService("RebirthService")
local UpgradeService = Knit.GetService("UpgradeService")
local StarShopService = Knit.GetService("StarShopService")
local WheelService = Knit.GetService("WheelService")

local UPGRADE_DISPLAY = {}
local UPGRADE_KEY = {}
for _, upgrade in ipairs(UpgradeConfig.GetAll()) do
    local display = upgrade.Name or upgrade.Key
    table.insert(UPGRADE_DISPLAY, display)
    UPGRADE_KEY[display] = upgrade.Key
end
table.sort(UPGRADE_DISPLAY)

local SHOP_DISPLAY = {}
local SHOP_KEY = {}
local SHOP_RARITIES = {}
do
    local seen = {}
    for _, item in ipairs(StarShopConfig.Catalog) do
        local display = item.Name or item.Key
        table.insert(SHOP_DISPLAY, display)
        SHOP_KEY[display] = item.Key
        if item.Rarity and not seen[item.Rarity] then
            seen[item.Rarity] = true
            table.insert(SHOP_RARITIES, item.Rarity)
        end
    end
    table.sort(SHOP_DISPLAY)
end

local function holesFolder()
    local map = Workspace:FindFirstChild("Map")
    return map and map:FindFirstChild("Holes")
end

local function ownedHoles()
    local holes = {}
    local folder = holesFolder()
    if not folder then return holes end
    for _, model in folder:GetChildren() do
        if model:GetAttribute("OwnerUserId") == LocalPlayer.UserId and model:GetAttribute("InFlight") ~= true then
            local id = model:GetAttribute("HoleId")
            local tier = model:GetAttribute("Tier")
            if id and tier then
                table.insert(holes, {
                    Id = id,
                    Tier = tier,
                    Position = (model:GetAttribute("BaseCF") or model:GetPivot()).Position,
                })
            end
        end
    end
    return holes
end

local function groupByTier(holes, minTier, maxTier)
    local buckets = {}
    for _, hole in holes do
        if hole.Tier >= minTier and hole.Tier <= maxTier then
            local bucket = buckets[hole.Tier]
            if not bucket then
                bucket = {}
                buckets[hole.Tier] = bucket
            end
            table.insert(bucket, hole)
        end
    end
    local tiers = {}
    for tier in pairs(buckets) do table.insert(tiers, tier) end
    table.sort(tiers)
    return buckets, tiers
end

local function upgradeLevel(key)
    local upgrades = DataClient.Get("Upgrades")
    if type(upgrades) ~= "table" then return 0 end
    return tonumber(upgrades[key]) or 0
end

local function canAffordUpgrade(upgrade)
    local level = upgradeLevel(upgrade.Key)
    if not upgrade.Uncapped and upgrade.MaxLevel and level >= upgrade.MaxLevel then
        return false
    end
    local rebirths = tonumber(DataClient.Get("Rebirths")) or 0
    local cost = UpgradeConfig.CostForNextLevel(upgrade.Key, level, rebirths)
    local cash = tonumber(DataClient.Get("Cash")) or 0
    return cost ~= nil and cash >= cost
end

-- ==========================================
-- WINDUI SETUP
-- ==========================================
shared.IndraHub_MABH_Unloaded = false

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Merge A Black Hole",
    Icon = "rbxassetid://18657887261",
    Author = "IndraHub",
    Folder = "IndraHub_MABH",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local MainTab = Window:Tab({ Title = "Main", Icon = "gamepad-2" })
local ShopTab = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Helper to normalize WindUI multi-dropdowns
local function normalizeMulti(value)
    local selected = {}
    if type(value) ~= "table" then return selected end
    for key, enabled in pairs(value) do
        if type(key) == "number" then selected[enabled] = true
        elseif enabled then selected[key] = true end
    end
    return selected
end

-- Configuration State
local config = {
    AutoMerge = false,
    MergeMinTier = 1,
    MergeMaxTier = 55,
    MergeDelay = 0.4,
    AutoLockBase = false,
    AutoRebirth = false,
    AutoUpgrades = false,
    UpgradeList = {},
    AutoStarShop = false,
    StarShopList = {},
    StarShopRarities = {},
    AutoSpinWheel = false,
    AutoClaimDailySpin = false,
    AntiAFK = false,
    HeartbeatConn = nil
}

-- ==========================================
-- MAIN TAB
-- ==========================================
MainTab:Toggle({
    Title = "Auto Merge",
    Default = false,
    Callback = function(Value) config.AutoMerge = Value end
})

MainTab:Slider({
    Title = "Min Tier",
    Value = { Min = 1, Max = 55, Default = 1 },
    Step = 1,
    Callback = function(Value) config.MergeMinTier = Value end
})

MainTab:Slider({
    Title = "Max Tier",
    Value = { Min = 1, Max = 55, Default = 55 },
    Step = 1,
    Callback = function(Value) config.MergeMaxTier = Value end
})

MainTab:Slider({
    Title = "Merge Delay",
    Value = { Min = 0.1, Max = 3, Default = 0.4 },
    Step = 0.1,
    Callback = function(Value) config.MergeDelay = Value end
})

MainTab:Toggle({
    Title = "Enable In-Game Auto Merge",
    Default = false,
    Callback = function(Value)
        pcall(function() HoleService:SetAutoMergeEnabled(Value) end)
    end
})

MainTab:Toggle({
    Title = "Auto Lock Base",
    Default = false,
    Callback = function(Value) config.AutoLockBase = Value end
})

MainTab:Toggle({
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(Value) config.AutoRebirth = Value end
})

MainTab:Toggle({
    Title = "Auto Buy Upgrades",
    Default = false,
    Callback = function(Value) config.AutoUpgrades = Value end
})

MainTab:Dropdown({
    Title = "Upgrades",
    Values = UPGRADE_DISPLAY,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = function(Value) config.UpgradeList = normalizeMulti(Value) end
})

-- ==========================================
-- SHOP TAB
-- ==========================================
ShopTab:Toggle({
    Title = "Auto Buy Star Shop",
    Default = false,
    Callback = function(Value) config.AutoStarShop = Value end
})

ShopTab:Dropdown({
    Title = "Star Shop Items",
    Values = SHOP_DISPLAY,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = function(Value) config.StarShopList = normalizeMulti(Value) end
})

ShopTab:Dropdown({
    Title = "Star Shop Rarities",
    Values = SHOP_RARITIES,
    Default = {},
    Multi = true,
    Callback = function(Value) config.StarShopRarities = normalizeMulti(Value) end
})

ShopTab:Toggle({
    Title = "Auto Spin Wheel",
    Default = false,
    Callback = function(Value) config.AutoSpinWheel = Value end
})

ShopTab:Toggle({
    Title = "Auto Claim Daily Spin",
    Default = false,
    Callback = function(Value) config.AutoClaimDailySpin = Value end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
SettingsTab:Toggle({
    Title = "Anti-AFK (Heartbeat)",
    Desc = "Spams VirtualUser clicks to prevent AFK kick entirely.",
    Default = false,
    Callback = function(Value)
        config.AntiAFK = Value
        if Value then
            if not config.HeartbeatConn then
                config.HeartbeatConn = RunService.Heartbeat:Connect(function()
                    pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
                end)
            end
        else
            if config.HeartbeatConn then 
                config.HeartbeatConn:Disconnect()
                config.HeartbeatConn = nil
            end
        end
    end
})

SettingsTab:Button({
    Title = "Unload UI",
    Callback = function()
        shared.IndraHub_MABH_Unloaded = true
        if config.HeartbeatConn then config.HeartbeatConn:Disconnect() end
        if Window and Window.Destroy then Window:Destroy() end
    end
})

-- ==========================================
-- BACKGROUND LOOPS
-- ==========================================

-- Auto Merge
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        local delay = config.MergeDelay or 0.4
        if config.AutoMerge then
            local buckets, tiers = groupByTier(ownedHoles(), config.MergeMinTier, config.MergeMaxTier)
            for _, tier in ipairs(tiers) do
                local bucket = buckets[tier]
                for index = 1, #bucket - 1, 2 do
                    if shared.IndraHub_MABH_Unloaded or not config.AutoMerge then break end
                    local source = bucket[index]
                    local target = bucket[index + 1]
                    pcall(function() HoleService:RequestMerge(source.Id, target.Id, target.Position) end)
                    task.wait(delay)
                end
            end
        end
        task.wait(delay)
    end
end)

-- Auto Lock Base
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        task.wait(1)
        if config.AutoLockBase then
            local ok, remaining = pcall(function() return ShieldService:GetShieldState() end)
            if ok and (tonumber(remaining) or 0) <= 0 then
                pcall(function() ShieldService:ActivateShield() end)
            end
        end
    end
end)

-- Auto Rebirth
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        task.wait(5)
        if config.AutoRebirth then
            local ok, info = pcall(function() return RebirthService:GetRebirthInfo() end)
            if ok and type(info) == "table" and info.CanRebirth then
                pcall(function() RebirthService:RequestRebirth() end)
            end
        end
    end
end)

-- Auto Upgrades
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        task.wait(1)
        if config.AutoUpgrades then
            for display in pairs(config.UpgradeList) do
                local key = UPGRADE_KEY[display]
                local upgrade = key and UpgradeConfig.GetByKey(key)
                if upgrade and canAffordUpgrade(upgrade) then
                    pcall(function() UpgradeService:PurchaseUpgrade(key) end)
                end
            end
        end
    end
end)

-- Auto Star Shop
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        task.wait(3)
        if config.AutoStarShop then
            local ok, state = pcall(function() return StarShopService:GetState() end)
            if ok and type(state) == "table" and state.Open and type(state.Stock) == "table" then
                local wantedKeys = {}
                for display in pairs(config.StarShopList) do
                    local key = SHOP_KEY[display]
                    if key then wantedKeys[key] = true end
                end
                local wantedRarities = config.StarShopRarities
                local stars = tonumber(state.Stars) or 0
                for _, entry in ipairs(state.Stock) do
                    if entry.Available and (wantedKeys[entry.Key] or wantedRarities[entry.Rarity]) then
                        local price = tonumber(entry.Price) or 0
                        if price <= stars then
                            local bought = pcall(function() return StarShopService:Purchase(entry.Key) end)
                            if bought then stars = stars - price end
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Spin Wheel
task.spawn(function()
    while not shared.IndraHub_MABH_Unloaded do
        task.wait(2)
        if config.AutoSpinWheel or config.AutoClaimDailySpin then
            local ok, state = pcall(function() return WheelService:GetState() end)
            if ok and type(state) == "table" then
                if config.AutoClaimDailySpin and state.DailyClaimable then
                    pcall(function() WheelService:ClaimDaily() end)
                end
                if config.AutoSpinWheel and (tonumber(state.Tickets) or 0) > 0 then
                    pcall(function() WheelService:Spin() end)
                    task.wait(6)
                end
            end
        end
    end
end)

WindUI:Notify({ Title = "IndraHub", Content = "Loaded Merge A Black Hole successfully!", Duration = 5 })
