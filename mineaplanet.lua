
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Env = (getgenv and getgenv()) or _G
local SessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

local function setGlobal(key, value)
    rawset(_G, key, value)
    if Env ~= _G then
        Env[key] = value
    end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then
        return value
    end
    return Env[key]
end

-- Re-executing the script replaces the previous session instead of stacking loops.
setGlobal("IndraHubMineAPlanetRunning", true)
setGlobal("IndraHubMineAPlanetSession", SessionId)
setGlobal("IndraHubMineAPlanetLastHeartbeat", os.clock())
setGlobal("IndraHubMineAPlanetError", nil)

local function isRunning()
    return getGlobal("IndraHubMineAPlanetRunning") == true
        and getGlobal("IndraHubMineAPlanetSession") == SessionId
end

local function fetchSource(url, cacheName)
    if type(readfile) == "function" then
        local ok, source = pcall(readfile, cacheName)
        if ok and type(source) == "string" and #source > 1000 then
            return source
        end
    end

    local source = game:HttpGet(url)
    if type(writefile) == "function" then
        pcall(writefile, cacheName, source)
    end
    return source
end

local okWindUI, WindUI = pcall(function()
    local source = fetchSource(
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "IndraHub_MineAPlanet_WindUI.lua"
    )
    return loadstring(source)()
end)

if not okWindUI or type(WindUI) ~= "table" then
    setGlobal("IndraHubMineAPlanetRunning", false)
    setGlobal("IndraHubMineAPlanetError", "WindUI failed to load")
    warn("[IndraHub Mine a Planet] WindUI failed to load")
    return
end

if Env.IndraHubMineAPlanetWindow then
    pcall(function()
        Env.IndraHubMineAPlanetWindow:Destroy()
    end)
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Mine a Planet",
    Icon = "pickaxe",
    Author = "IndraHub",
    Folder = "IndraHubMineAPlanet",
    Size = UDim2.fromOffset(610, 470),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 175,
})

Env.IndraHubMineAPlanetWindow = Window
pcall(Window.SetToggleKey, Window, Enum.KeyCode.RightControl)
pcall(Window.EditOpenButton, Window, {
    Title = "IndraHub",
    Icon = "pickaxe",
    Draggable = true,
})

local function notify(title, content, icon, duration)
    pcall(WindUI.Notify, WindUI, {
        Title = title or "IndraHub",
        Content = tostring(content or ""),
        Icon = icon or "info",
        Duration = duration or 3,
    })
end

local Net = ReplicatedStorage:FindFirstChild("Net") or ReplicatedStorage:WaitForChild("Net", 15)
if not Net then
    setGlobal("IndraHubMineAPlanetRunning", false)
    setGlobal("IndraHubMineAPlanetError", "ReplicatedStorage.Net was not found")
    notify("IndraHub", "Remote folder ReplicatedStorage.Net was not found.", "triangle-alert", 6)
    pcall(function()
        Window:Destroy()
    end)
    if Env.IndraHubMineAPlanetWindow == Window then
        Env.IndraHubMineAPlanetWindow = nil
    end
    return
end

local function getRemote(name)
    local remote = Net:FindFirstChild(name)
    if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        return remote
    end
    return nil
end

local function safeFire(name, ...)
    if not isRunning() then
        return false
    end

    local remote = getRemote(name)
    if not remote then
        return false
    end

    local args = {...}
    local ok = pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args))
        else
            remote:FireServer(unpack(args))
        end
    end)
    return ok
end

local Config = {
    AutoCollectDocks = false,
    CollectDelay = 0.6,
    DockCount = 6,
    AutoSell = false,

    AutoRollDrones = false,
    AutoPickUpDrones = false,
    AutoPlaceDrones = false,
    AutoUnlockDocks = false,
    DroneSlots = 3,
    DroneDelay = 1,

    AutoUpgrade = false,
    UpgradeFloor = 1,
    UpgradeDelay = 0.8,
    SelectedUpgrades = {},

    AutoBuyGear = false,
    AutoBuyAlienItem = false,
    AutoBuyUpgradeItem = false,
    SelectedGear = "Battery1",
    SelectedAlienItem = "AlienTreat1",
    UpgradeItemId = "jetpack",
    ShopDelay = 2,

    AutoDailyRewards = false,
    AutoPlaytimeRewards = false,
    AntiAfk = false,
}

local GEAR_ITEMS = {
    "Battery1", "CpuClean", "CpuBlizzard", "Battery2", "CpuIon",
    "CpuSolarFlare", "CpuRadioactive", "Battery3", "CpuUFO",
    "CpuJellyFish", "Battery4",
}
local ALIEN_ITEMS = {
    "AlienTreat1", "AlienBall1", "AlienTreat2", "AlienBall2",
    "AlienBall3", "AlienTreat3", "AlienBall4", "AlienTreat4",
}
local UPGRADE_ORDER = {
    "Cargo", "Platform", "Dock Storage", "Laser Power",
    "Planet", "Drone Rolls", "Luck",
}
local UPGRADE_REMOTES = {
    ["Cargo"] = {Name = "RequestUpgradeCargo", Floor = true},
    ["Platform"] = {Name = "RequestPlatformUpgrade", Floor = true},
    ["Dock Storage"] = {Name = "RequestUpgradeDockStorage", Floor = true},
    ["Laser Power"] = {Name = "RequestUpgradeLaserPower", Floor = true},
    ["Planet"] = {Name = "RequestUpgradePlanet"},
    ["Drone Rolls"] = {Name = "RequestUpgradeDroneRolls"},
    ["Luck"] = {Name = "RequestUpgradeLuck"},
}

local function singleValue(value, fallback)
    if type(value) ~= "table" then
        return value or fallback
    end

    for key, state in pairs(value) do
        if type(key) == "number" then
            return state or fallback
        elseif state == true then
            return key
        end
    end
    return fallback
end

local function selectedSet(value)
    local result = {}
    if type(value) == "string" then
        result[value] = true
    elseif type(value) == "table" then
        for key, state in pairs(value) do
            if type(key) == "number" and type(state) == "string" then
                result[state] = true
            elseif state == true then
                result[key] = true
            end
        end
    end
    return result
end

local function getOwnedPlatform()
    local farmStar = workspace:FindFirstChild("FarmStar")
    local platforms = farmStar and farmStar:FindFirstChild("Platforms")
    if not platforms then
        return nil
    end

    local direct = platforms:FindFirstChild(tostring(LocalPlayer.UserId))
    if direct then
        return direct
    end

    for _, platform in ipairs(platforms:GetChildren()) do
        local owner = platform:GetAttribute("OwnerUserId")
            or platform:GetAttribute("UserId")
            or platform:GetAttribute("Owner")
        if owner == LocalPlayer.UserId or tostring(owner) == tostring(LocalPlayer.UserId) then
            return platform
        end
    end
    return nil
end

local function looksLikeNodeId(value)
    if type(value) ~= "string" or value == "" then
        return false
    end
    return value:match("^c%d+[hs]%d*$") ~= nil
        or value:match("^[Cc]ell%d+.+") ~= nil
end

local function looksLikePetId(value)
    return type(value) == "string" and value:match("^pet%d+$") ~= nil
end

local function discoverNodeIds()
    local ids = {}
    local seen = {}
    local petIds = {}
    local seenPets = {}
    local sourceCounts = {Instances = 0, Runtime = 0}

    local function add(value, source)
        if looksLikeNodeId(value) and not seen[value] then
            seen[value] = true
            ids[#ids + 1] = value
            sourceCounts[source] = (sourceCounts[source] or 0) + 1
        end
        if looksLikePetId(value) and not seenPets[value] then
            seenPets[value] = true
            petIds[#petIds + 1] = value
            sourceCounts.Pets = (sourceCounts.Pets or 0) + 1
        end
    end

    local function scanInstanceRoot(root)
        if not root then
            return
        end

        local objects = {root}
        for _, descendant in ipairs(root:GetDescendants()) do
            objects[#objects + 1] = descendant
        end

        for _, object in ipairs(objects) do
            add(object.Name, "Instances")

            if object:IsA("StringValue") then
                add(object.Value, "Instances")
            elseif object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                add(object.Text, "Instances")
            end

            local ok, attributes = pcall(object.GetAttributes, object)
            if ok then
                for _, value in pairs(attributes) do
                    add(value, "Instances")
                end
            end
        end
    end

    -- Node state can live outside the player's platform, so scan replicated and UI trees too.
    scanInstanceRoot(workspace)
    scanInstanceRoot(ReplicatedStorage)
    scanInstanceRoot(LocalPlayer:FindFirstChild("PlayerGui"))
    scanInstanceRoot(LocalPlayer:FindFirstChild("PlayerScripts"))

    -- Many games keep opaque node IDs only in client-side state tables.
    if type(getgc) == "function" then
        local okGc, gcObjects = pcall(getgc, true)
        if okGc and type(gcObjects) == "table" then
            local visited = {}
            local inspected = 0
            local maxInspected = 30000
            local gcObjectCount = 0
            local functionCount = 0
            local maxGcObjects = 12000
            local maxFunctions = 1500

            local function scanRuntimeValue(value, depth)
                if inspected >= maxInspected then
                    return
                end
                inspected = inspected + 1

                if type(value) == "string" then
                    add(value, "Runtime")
                    return
                end
                if type(value) ~= "table" or depth >= 3 or visited[value] then
                    return
                end

                visited[value] = true
                local okPairs, entries = pcall(function()
                    local result = {}
                    for key, child in pairs(value) do
                        result[#result + 1] = {key, child}
                        if #result >= 250 then
                            break
                        end
                    end
                    return result
                end)
                if okPairs then
                    for _, entry in ipairs(entries) do
                        scanRuntimeValue(entry[1], depth + 1)
                        scanRuntimeValue(entry[2], depth + 1)
                    end
                end
            end

            for _, object in ipairs(gcObjects) do
                gcObjectCount = gcObjectCount + 1
                if inspected >= maxInspected or gcObjectCount > maxGcObjects then
                    break
                end
                if type(object) == "table" then
                    scanRuntimeValue(object, 0)
                elseif type(object) == "function"
                    and type(getconstants) == "function"
                    and functionCount < maxFunctions then
                    functionCount = functionCount + 1
                    local okConstants, constants = pcall(getconstants, object)
                    if okConstants and type(constants) == "table" then
                        for _, constant in ipairs(constants) do
                            if type(constant) == "string" then
                                add(constant, "Runtime")
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(ids)
    table.sort(petIds)
    return ids, sourceCounts, petIds
end

local CachedNodeIds = {}
local CachedPetIds = {}
local CachedNodeSources = {Instances = 0, Runtime = 0, Pets = 0}
local LastNodeScan = 0

local function getNodeIds(forceRefresh)
    if forceRefresh or os.clock() - LastNodeScan > 8 then
        CachedNodeIds, CachedNodeSources, CachedPetIds = discoverNodeIds()
        LastNodeScan = os.clock()
    end

    local result = {}
    local seen = {}
    local function add(id)
        if id and id ~= "" and not seen[id] then
            seen[id] = true
            result[#result + 1] = id
        end
    end

    if Config.MineMode == "Manual ID" then
        add(Config.ManualNodeId)
    else
        for _, id in ipairs(CachedNodeIds) do
            add(id)
        end
    end
    return result
end

local function getPetIds(forceRefresh)
    getNodeIds(forceRefresh)
    local result = {}
    for _, petId in ipairs(CachedPetIds) do
        result[#result + 1] = petId
    end
    return result
end

local function triggerSellPrompt()
    if type(fireproximityprompt) ~= "function" then
        return false
    end

    local platform = getOwnedPlatform()
    if not platform then
        return false
    end

    local fallback
    for _, object in ipairs(platform:GetDescendants()) do
        if object:IsA("ProximityPrompt") then
            fallback = fallback or object
            local text = (object.Name .. " " .. object.ActionText .. " " .. object.ObjectText):lower()
            if text:find("sell", 1, true) then
                return pcall(fireproximityprompt, object)
            end
        end
    end

    if fallback and fallback.Parent and fallback.Parent.Name:lower():find("sell", 1, true) then
        return pcall(fireproximityprompt, fallback)
    end
    return false
end

local function mineOnce()
    local nodeIds = getNodeIds(false)
    for _, nodeId in ipairs(nodeIds) do
        if not isRunning() then
            break
        end
        safeFire("RequestShootOre", {nodeId = nodeId})
        task.wait(Config.MineDelay)
    end
    return #nodeIds
end

local function shootPetsOnce()
    local petIds = getPetIds(false)
    for _, petId in ipairs(petIds) do
        if not isRunning() then
            break
        end
        safeFire("RequestShootPet", {petId = petId})
        task.wait(Config.PetDelay)
    end
    return #petIds
end

local function collectDocksOnce()
    for dockIndex = 1, Config.DockCount do
        if not isRunning() then
            break
        end
        safeFire("RequestCollectDockOre", {dockIndex = dockIndex})
        task.wait(0.04)
    end
end

local function rollDronesOnce()
    safeFire("RequestRollDrones", {})
end

local function pickUpDronesOnce()
    for slotIndex = 1, Config.DroneSlots do
        safeFire("RequestPickUpDrone", {slotIndex = slotIndex})
        task.wait(0.08)
    end
end

local function placeDronesOnce()
    local slotIndex = 1
    for dockIndex = 1, Config.DockCount do
        if not isRunning() then
            break
        end

        if Config.AutoUnlockDocks then
            safeFire("RequestUnlockDock", {dockIndex = dockIndex})
            task.wait(0.05)
        end

        safeFire("RequestSelectHotbar", {slot = slotIndex})
        task.wait(0.05)
        safeFire("RequestPlaceDrone", {dockIndex = dockIndex})
        slotIndex = slotIndex + 1
        if slotIndex > Config.DroneSlots then
            slotIndex = 1
        end
        task.wait(0.08)
    end
    safeFire("RequestSelectHotbar", {slot = false})
end

local function upgradeOnce()
    for _, label in ipairs(UPGRADE_ORDER) do
        if Config.SelectedUpgrades[label] then
            local upgrade = UPGRADE_REMOTES[label]
            if upgrade.Floor then
                safeFire(upgrade.Name, {floor = Config.UpgradeFloor})
            else
                safeFire(upgrade.Name, {})
            end
            task.wait(0.08)
        end
    end
end

local function buySelectedGear()
    return safeFire("RequestGearShopCashPurchase", {consumableId = Config.SelectedGear})
end

local function buySelectedAlienItem()
    return safeFire("RequestAlienPetShopCashPurchase", {consumableId = Config.SelectedAlienItem})
end

local function discoverUpgradeShopItems()
    local items = {}
    local seen = {}
    local inspected = 0
    local maxInspected = 30000

    local function add(value)
        if type(value) ~= "string" then
            return
        end
        value = value:match("^%s*(.-)%s*$")
        if value ~= "" and #value <= 80 and not seen[value] then
            seen[value] = true
            items[#items + 1] = value
        end
    end

    local visited = {}
    local function scanTable(value, depth, allowGenericId, insideItems)
        if type(value) ~= "table" or depth > 5 or visited[value] or inspected >= maxInspected then
            return
        end
        visited[value] = true

        local ok, entries = pcall(function()
            local result = {}
            for key, child in pairs(value) do
                result[#result + 1] = {key, child}
                if #result >= 500 then
                    break
                end
            end
            return result
        end)
        if not ok then
            return
        end

        for _, entry in ipairs(entries) do
            inspected = inspected + 1
            if inspected >= maxInspected then
                break
            end
            local key, child = entry[1], entry[2]
            local lowerKey = type(key) == "string" and key:lower() or ""
            if (lowerKey == "itemid" or lowerKey == "item_id" or (allowGenericId and lowerKey == "id"))
                and type(child) == "string" then
                add(child)
            end
            if insideItems and type(key) == "string" and type(child) == "table" then
                add(key)
            end
            if type(child) == "table" then
                local childIsItems = insideItems
                    or lowerKey == "items"
                    or lowerKey == "upgrades"
                    or lowerKey == "shopitems"
                scanTable(child, depth + 1, allowGenericId, childIsItems)
            end
        end
    end

    local configRoot = ReplicatedStorage:FindFirstChild("Config")
    if configRoot then
        for _, module in ipairs(configRoot:GetDescendants()) do
            if module:IsA("ModuleScript") then
                local lowerName = module.Name:lower()
                if lowerName:find("upgrade", 1, true) and lowerName:find("shop", 1, true) then
                    local ok, config = pcall(require, module)
                    if ok then
                        scanTable(config, 0, true, false)
                    end
                end
            end
        end
    end

    if type(getgc) == "function" then
        local okGc, gcObjects = pcall(getgc, true)
        if okGc and type(gcObjects) == "table" then
            local checked = 0
            for _, object in ipairs(gcObjects) do
                if type(object) == "table" then
                    scanTable(object, 0, false, false)
                    checked = checked + 1
                    if checked >= 5000 then
                        break
                    end
                end
            end
        end
    end

    if #items == 0 then
        add("jetpack")
    end
    table.sort(items)
    return items
end

local function buyUpgradeItem()
    local itemId = tostring(Config.UpgradeItemId or ""):match("^%s*(.-)%s*$")
    if itemId == "" then
        return false
    end
    return safeFire("RequestUpgradeShopCashPurchase", {itemId = itemId})
end

local function claimDailyRewards()
    for rewardIndex = 1, 7 do
        safeFire("ClaimDailyReward", rewardIndex)
        task.wait(0.06)
    end
end

local function claimPlaytimeRewards()
    for rewardIndex = 1, 12 do
        safeFire("ClaimPlaytimeReward", rewardIndex)
        task.wait(0.06)
    end
end

local Tabs = {
    Cargo = Window:Tab({Title = "Collect & Sell", Icon = "package"}),
    Drones = Window:Tab({Title = "Drones", Icon = "bot"}),
    Upgrades = Window:Tab({Title = "Upgrades", Icon = "trending-up"}),
    Shop = Window:Tab({Title = "Shop", Icon = "shopping-cart"}),
    Rewards = Window:Tab({Title = "Rewards", Icon = "gift"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}),
}

local UiErrors = {}
local function buildTab(name, callback)
    local ok, err = pcall(callback)
    if not ok then
        local message = name .. ": " .. tostring(err)
        UiErrors[#UiErrors + 1] = message
        warn("[IndraHub Mine a Planet] UI error - " .. message)
    end
end

if false then
buildTab("Farm", function()
Tabs.Farm:Section({Title = "Ore Mining", Icon = "gem"})
Tabs.Farm:Toggle({
    Title = "Auto Mine Ore",
    Desc = "Continuously fires at the selected ore node IDs.",
    Value = false,
    Callback = function(value)
        Config.AutoMine = value
    end,
})
Tabs.Farm:Dropdown({
    Title = "Mining Mode",
    Desc = "Auto Scan searches instances and client runtime tables.",
    Values = {"Auto Scan", "Manual ID"},
    Value = "Auto Scan",
    Callback = function(value)
        Config.MineMode = singleValue(value, "Auto Scan")
        getNodeIds(true)
    end,
})
Tabs.Farm:Input({
    Title = "Manual Node ID",
    Desc = "Optional fallback for debugging; Auto Scan uses no static IDs.",
    Value = "",
    Placeholder = "Example: c6h",
    Callback = function(value)
        if type(value) == "string" and value ~= "" then
            Config.ManualNodeId = value
        end
    end,
})
Tabs.Farm:Slider({
    Title = "Mining Delay",
    Step = 0.01,
    Min = 0.03,
    Max = 1,
    Value = 0.08,
    Callback = function(value)
        Config.MineDelay = tonumber(value) or 0.08
    end,
})
Tabs.Farm:Button({
    Title = "Mine Once",
    Desc = "Runs one pass over the current node list.",
    Callback = function()
        task.spawn(function()
            local count = mineOnce()
            notify("Mine a Planet", "Sent mining requests to " .. tostring(count) .. " node(s).", "pickaxe")
        end)
    end,
})
Tabs.Farm:Button({
    Title = "Refresh Ore Nodes",
    Desc = "Scans instances and runtime state for ore and pet IDs.",
    Callback = function()
        local ids = getNodeIds(true)
        local sourceText = tostring(CachedNodeSources.Instances or 0) .. " instance, "
            .. tostring(CachedNodeSources.Runtime or 0) .. " runtime"
        local idText = #ids > 0 and table.concat(ids, ", ") or "none"
        notify("Ore Scan", tostring(#ids) .. " found (" .. sourceText .. "): " .. idText, "scan-search", 7)
    end,
})

Tabs.Farm:Section({Title = "Pet Shooting", Icon = "paw-print"})
Tabs.Farm:Toggle({
    Title = "Auto Shoot Pets",
    Desc = "Scans pet IDs and fires RequestShootPet for each detected pet.",
    Value = false,
    Callback = function(value)
        Config.AutoShootPets = value
    end,
})
Tabs.Farm:Slider({
    Title = "Pet Shoot Delay",
    Step = 0.01,
    Min = 0.05,
    Max = 2,
    Value = 0.12,
    Callback = function(value)
        Config.PetDelay = tonumber(value) or 0.12
    end,
})
Tabs.Farm:Button({
    Title = "Shoot Detected Pets Once",
    Callback = function()
        task.spawn(function()
            local count = shootPetsOnce()
            notify("Pet Scan", "Sent requests to " .. tostring(count) .. " detected pet(s).", "paw-print")
        end)
    end,
})
Tabs.Farm:Button({
    Title = "Refresh Pet IDs",
    Callback = function()
        local ids = getPetIds(true)
        notify("Pet Scan", tostring(#ids) .. " found: " .. (#ids > 0 and table.concat(ids, ", ") or "none"), "scan-search", 7)
    end,
})

end)
end
buildTab("Collect & Sell", function()
Tabs.Cargo:Section({Title = "Dock Ore", Icon = "package"})
Tabs.Cargo:Toggle({
    Title = "Auto Collect Ore (All Docks)",
    Desc = "Collects stored ore from every configured dock.",
    Value = false,
    Callback = function(value)
        Config.AutoCollectDocks = value
    end,
})
Tabs.Cargo:Toggle({
    Title = "Auto Sell Ore",
    Desc = "Triggers the sell ProximityPrompt on your platform.",
    Value = false,
    Callback = function(value)
        Config.AutoSell = value
        if value and type(fireproximityprompt) ~= "function" then
            notify("Auto Sell", "Your executor does not support fireproximityprompt.", "triangle-alert", 5)
        end
    end,
})
Tabs.Cargo:Slider({
    Title = "Dock Count",
    Step = 1,
    Min = 1,
    Max = 12,
    Value = 6,
    Callback = function(value)
        Config.DockCount = math.floor(tonumber(value) or 6)
    end,
})
Tabs.Cargo:Slider({
    Title = "Collect Delay",
    Step = 0.1,
    Min = 0.2,
    Max = 5,
    Value = 0.6,
    Callback = function(value)
        Config.CollectDelay = tonumber(value) or 0.6
    end,
})
Tabs.Cargo:Button({Title = "Collect All Docks", Callback = collectDocksOnce})
Tabs.Cargo:Button({Title = "Sell Once", Callback = function()
    if not triggerSellPrompt() then
        notify("Sell", "Sell prompt was not found or could not be triggered.", "triangle-alert")
    end
end})

end)
buildTab("Drones", function()
Tabs.Drones:Section({Title = "Drone Automation", Icon = "bot"})
Tabs.Drones:Toggle({
    Title = "Auto Roll Drones",
    Desc = "Repeatedly requests a drone roll.",
    Value = false,
    Callback = function(value)
        Config.AutoRollDrones = value
    end,
})
Tabs.Drones:Toggle({
    Title = "Auto Pick Up Rolled Drones",
    Desc = "Picks drone result slots into the hotbar.",
    Value = false,
    Callback = function(value)
        Config.AutoPickUpDrones = value
    end,
})
Tabs.Drones:Toggle({
    Title = "Auto Place Drones",
    Desc = "Cycles hotbar slots across configured docks.",
    Value = false,
    Callback = function(value)
        Config.AutoPlaceDrones = value
    end,
})
Tabs.Drones:Toggle({
    Title = "Unlock Docks Before Place",
    Desc = "Requests each dock unlock before placing a drone.",
    Value = false,
    Callback = function(value)
        Config.AutoUnlockDocks = value
    end,
})
Tabs.Drones:Slider({
    Title = "Drone Result Slots",
    Step = 1,
    Min = 1,
    Max = 6,
    Value = 3,
    Callback = function(value)
        Config.DroneSlots = math.floor(tonumber(value) or 3)
    end,
})
Tabs.Drones:Slider({
    Title = "Drone Loop Delay",
    Step = 0.1,
    Min = 0.3,
    Max = 10,
    Value = 1,
    Callback = function(value)
        Config.DroneDelay = tonumber(value) or 1
    end,
})
Tabs.Drones:Button({Title = "Roll Once", Callback = rollDronesOnce})
Tabs.Drones:Button({Title = "Pick Up Slots Once", Callback = pickUpDronesOnce})
Tabs.Drones:Button({Title = "Place Across Docks Once", Callback = placeDronesOnce})

end)
buildTab("Upgrades", function()
Tabs.Upgrades:Section({Title = "Automatic Upgrades", Icon = "trending-up"})
Tabs.Upgrades:Toggle({
    Title = "Auto Buy Selected Upgrades",
    Desc = "Server rejects purchases when requirements are not met.",
    Value = false,
    Callback = function(value)
        Config.AutoUpgrade = value
    end,
})
Tabs.Upgrades:Dropdown({
    Title = "Upgrades",
    Values = UPGRADE_ORDER,
    Multi = true,
    Value = {},
    Callback = function(value)
        Config.SelectedUpgrades = selectedSet(value)
    end,
})
Tabs.Upgrades:Slider({
    Title = "Upgrade Floor",
    Desc = "Used for cargo, platform, dock storage, and laser power.",
    Step = 1,
    Min = 1,
    Max = 20,
    Value = 1,
    Callback = function(value)
        Config.UpgradeFloor = math.floor(tonumber(value) or 1)
    end,
})
Tabs.Upgrades:Slider({
    Title = "Upgrade Delay",
    Step = 0.1,
    Min = 0.3,
    Max = 10,
    Value = 0.8,
    Callback = function(value)
        Config.UpgradeDelay = tonumber(value) or 0.8
    end,
})
Tabs.Upgrades:Button({Title = "Buy Selected Once", Callback = upgradeOnce})

end)
buildTab("Shop", function()
Tabs.Shop:Section({Title = "Gear Shop", Icon = "battery-charging"})
Tabs.Shop:Dropdown({
    Title = "Gear Item",
    Values = GEAR_ITEMS,
    Value = "Battery1",
    Callback = function(value)
        Config.SelectedGear = singleValue(value, "Battery1")
    end,
})
Tabs.Shop:Toggle({Title = "Auto Buy Gear", Value = false, Callback = function(value)
    Config.AutoBuyGear = value
end})
Tabs.Shop:Button({Title = "Buy Selected Gear", Callback = buySelectedGear})

Tabs.Shop:Section({Title = "Alien Pet Shop", Icon = "paw-print"})
Tabs.Shop:Dropdown({
    Title = "Alien Item",
    Values = ALIEN_ITEMS,
    Value = "AlienTreat1",
    Callback = function(value)
        Config.SelectedAlienItem = singleValue(value, "AlienTreat1")
    end,
})
Tabs.Shop:Toggle({Title = "Auto Buy Alien Item", Value = false, Callback = function(value)
    Config.AutoBuyAlienItem = value
end})
Tabs.Shop:Button({Title = "Buy Selected Alien Item", Callback = buySelectedAlienItem})

Tabs.Shop:Section({Title = "Upgrade Shop", Icon = "rocket"})
local UpgradeShopItems = discoverUpgradeShopItems()
Config.UpgradeItemId = UpgradeShopItems[1]
local UpgradeItemDropdown = Tabs.Shop:Dropdown({
    Title = "Upgrade Item",
    Desc = "Items scanned from game configuration and runtime state.",
    Values = UpgradeShopItems,
    Value = UpgradeShopItems[1],
    Callback = function(value)
        Config.UpgradeItemId = singleValue(value, UpgradeShopItems[1])
    end,
})
Tabs.Shop:Toggle({Title = "Auto Buy Upgrade Item", Value = false, Callback = function(value)
    Config.AutoBuyUpgradeItem = value
end})
Tabs.Shop:Button({Title = "Buy Upgrade Item", Callback = buyUpgradeItem})
Tabs.Shop:Button({
    Title = "Refresh Upgrade Items",
    Desc = "Scans the current game state and refreshes the dropdown.",
    Callback = function()
        UpgradeShopItems = discoverUpgradeShopItems()
        Config.UpgradeItemId = UpgradeShopItems[1]
        if UpgradeItemDropdown then
            if type(UpgradeItemDropdown.Refresh) == "function" then
                pcall(UpgradeItemDropdown.Refresh, UpgradeItemDropdown, UpgradeShopItems)
            elseif type(UpgradeItemDropdown.SetValues) == "function" then
                pcall(UpgradeItemDropdown.SetValues, UpgradeItemDropdown, UpgradeShopItems)
            end
        end
        notify("Upgrade Shop", tostring(#UpgradeShopItems) .. " item(s) found.", "scan-search")
    end,
})
Tabs.Shop:Slider({
    Title = "Shop Loop Delay",
    Step = 0.5,
    Min = 1,
    Max = 30,
    Value = 2,
    Callback = function(value)
        Config.ShopDelay = tonumber(value) or 2
    end,
})

end)
buildTab("Rewards", function()
Tabs.Rewards:Section({Title = "Reward Claims", Icon = "gift"})
Tabs.Rewards:Toggle({
    Title = "Auto Claim Daily Rewards",
    Desc = "Attempts daily reward indexes 1 through 7 every 30 seconds.",
    Value = false,
    Callback = function(value)
        Config.AutoDailyRewards = value
    end,
})
Tabs.Rewards:Toggle({
    Title = "Auto Claim Playtime Rewards",
    Desc = "Attempts playtime reward indexes 1 through 12 every 30 seconds.",
    Value = false,
    Callback = function(value)
        Config.AutoPlaytimeRewards = value
    end,
})
Tabs.Rewards:Button({Title = "Claim Daily Rewards", Callback = claimDailyRewards})
Tabs.Rewards:Button({Title = "Claim Playtime Rewards", Callback = claimPlaytimeRewards})

end)
buildTab("Settings", function()
Tabs.Settings:Section({Title = "IndraHub", Icon = "pickaxe"})
Tabs.Settings:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents Roblox idle disconnects while the hub is running.",
    Value = false,
    Callback = function(value)
        Config.AntiAfk = value
    end,
})
Tabs.Settings:Button({
    Title = "Copy Discord Invite",
    Desc = "Copies the IndraHub community link.",
    Callback = function()
        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(setclipboard, "https://discord.gg/2PPBJsmqr")
        elseif type(toclipboard) == "function" then
            copied = pcall(toclipboard, "https://discord.gg/2PPBJsmqr")
        end
        notify("IndraHub", copied and "Discord invite copied." or "Clipboard is not supported.", copied and "check" or "triangle-alert")
    end,
})
Tabs.Settings:Button({
    Title = "Check Required Remotes",
    Callback = function()
        local required = {
            "RequestCollectDockOre", "RequestRollDrones",
            "RequestPickUpDrone", "RequestSelectHotbar", "RequestUnlockDock",
            "RequestPlaceDrone", "RequestUpgradeCargo", "RequestPlatformUpgrade",
            "RequestUpgradeDockStorage", "RequestUpgradeLaserPower",
            "RequestUpgradePlanet", "RequestUpgradeDroneRolls", "RequestUpgradeLuck",
            "ClaimDailyReward", "ClaimPlaytimeReward",
            "RequestGearShopCashPurchase", "RequestAlienPetShopCashPurchase",
            "RequestUpgradeShopCashPurchase",
        }
        local found = 0
        for _, name in ipairs(required) do
            if getRemote(name) then
                found = found + 1
            end
        end
        notify("Remote Check", tostring(found) .. "/" .. tostring(#required) .. " remotes found.", "radio", 5)
    end,
})
Tabs.Settings:Button({
    Title = "Unload IndraHub",
    Desc = "Stops every loop and removes this window.",
    Callback = function()
        setGlobal("IndraHubMineAPlanetRunning", false)
        if Env.IndraHubMineAPlanetWindow == Window then
            pcall(function()
                Window:Destroy()
            end)
            Env.IndraHubMineAPlanetWindow = nil
        end
    end,
})

end)

if #UiErrors > 0 then
    setGlobal("IndraHubMineAPlanetError", table.concat(UiErrors, " | "))
    notify("WindUI", "Some tabs failed to build. Check the executor console.", "triangle-alert", 6)
end

task.spawn(function()
    while isRunning() do
        setGlobal("IndraHubMineAPlanetLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

task.spawn(function()
    while isRunning() do
        if Config.AutoCollectDocks then
            collectDocksOnce()
            task.wait(Config.CollectDelay)
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while isRunning() do
        if Config.AutoSell then
            triggerSellPrompt()
            task.wait(2)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while isRunning() do
        if Config.AutoRollDrones then
            rollDronesOnce()
            task.wait(0.2)
        end
        if Config.AutoPickUpDrones then
            pickUpDronesOnce()
        end
        if Config.AutoPlaceDrones then
            placeDronesOnce()
        end

        if Config.AutoRollDrones or Config.AutoPickUpDrones or Config.AutoPlaceDrones then
            task.wait(Config.DroneDelay)
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while isRunning() do
        if Config.AutoUpgrade and next(Config.SelectedUpgrades) ~= nil then
            upgradeOnce()
            task.wait(Config.UpgradeDelay)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while isRunning() do
        local activeShop = false
        if Config.AutoBuyGear then
            activeShop = true
            buySelectedGear()
        end
        if Config.AutoBuyAlienItem then
            activeShop = true
            buySelectedAlienItem()
        end
        if Config.AutoBuyUpgradeItem then
            activeShop = true
            buyUpgradeItem()
        end
        task.wait(activeShop and Config.ShopDelay or 0.25)
    end
end)

task.spawn(function()
    while isRunning() do
        if Config.AutoDailyRewards then
            claimDailyRewards()
        end
        if Config.AutoPlaytimeRewards then
            claimPlaytimeRewards()
        end
        task.wait((Config.AutoDailyRewards or Config.AutoPlaytimeRewards) and 30 or 0.5)
    end
end)

local idledConnection = LocalPlayer.Idled:Connect(function()
    if isRunning() and Config.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not isRunning() then
        heartbeatConnection:Disconnect()
        idledConnection:Disconnect()
        if Env.IndraHubMineAPlanetWindow == Window then
            pcall(function()
                Window:Destroy()
            end)
            Env.IndraHubMineAPlanetWindow = nil
        end
    end
end)

notify("IndraHub", "Mine a Planet loaded. Press RightControl to toggle the UI.", "pickaxe", 5)
print("[IndraHub] Mine a Planet loaded")
