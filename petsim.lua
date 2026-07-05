local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Network = ReplicatedStorage:WaitForChild("Network")
local Directory = ReplicatedStorage:WaitForChild("__DIRECTORY", 10)
local Things = workspace:WaitForChild("__THINGS", 10)
local Breakables = Things and Things:WaitForChild("Breakables", 10)
local env = getgenv and getgenv() or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

env.IndraHubPetSimRunning = true
env.IndraHubPetSimSession = sessionId
env.IndraHubPetSimLastHeartbeat = os.clock()
env.IndraHubPetSimError = nil

local function running()
    return env.IndraHubPetSimRunning and env.IndraHubPetSimSession == sessionId
end

task.spawn(function()
    while running() do
        env.IndraHubPetSimLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function waitRemote(name)
    local remote = Network:WaitForChild(name, 10)

    if not remote then
        warn("[AlurTest] missing remote", name)
    end

    return remote
end

local Remotes = {
    SetTarget = waitRemote("BR_SetTarget"),
    JoinPetBulk = waitRemote("Breakables_JoinPetBulk"),
    DealDamage = waitRemote("Breakables_PlayerDealDamage"),
    RequestPurchase = waitRemote("Zones_RequestPurchase"),
    GetStats = waitRemote("Get Stats"),
    EggsRequestPurchase = waitRemote("Eggs_RequestPurchase"),
    HatchCount = waitRemote("Index: Request Hatch Count"),
    EggsPlayOpenAnimation = waitRemote("Eggs_PlayOpenAnimation"),
}

local Config = {
    AutoFarm = false,
    AutoBuyArea = false,
    AutoHatch = false,
    AutoTeleportArea = false,
    TargetIds = {},
    PetIds = { "16042", "16043", "16044", "16045", "16198", "16199", "16325", "17754" },
    TargetType = 2,
    DamageDelay = 0.05,
    JoinDelay = 1,
    BuyDelay = 3,
    HatchDelay = 0.5,
    BuyZones = {},
    SelectedBuyZone = "Farm",
    SelectedAreaNumber = "1",
    AreaByNumber = {},
    ZoneList = {},
    EggList = {},
    EggName = "",
    EggSearch = "",
    EggAmount = 3,
    AutoFindBreakables = true,
    ScanDelay = 3,
    AllowedZones = {},
    IncludeVIP = false,
    NearestFirst = true,
}

getgenv().AlurTest = Config

local function sortedValues(set)
    local values = {}

    for value in pairs(set) do
        table.insert(values, value)
    end

    table.sort(values, function(a, b)
        local aNum = tonumber(tostring(a):match("^(%d+)")) or math.huge
        local bNum = tonumber(tostring(b):match("^(%d+)")) or math.huge

        if aNum ~= bNum then
            return aNum < bNum
        end

        return tostring(a) < tostring(b)
    end)

    return values
end

local function collectRuntimeLists()
    local zones = {}
    local eggs = {}
    local areaByNumber = {}

    zones.Farm = true
    zones.Backyard = true

    local map = workspace:FindFirstChild("Map")
    if map then
        for _, child in ipairs(map:GetChildren()) do
            local areaNumber, zoneName = child.Name:match("^(%d+)%s*|%s*(.+)$")
            if zoneName and zoneName ~= "" then
                zones[zoneName] = true
                areaByNumber[areaNumber] = zoneName
            end
        end
    end

    local zoneDir = Directory and Directory:FindFirstChild("Zones")
    if zoneDir then
        for _, inst in ipairs(zoneDir:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                local zoneName = inst.Name:match("^%d+%s*|%s*(.+)$") or inst.Name
                if zoneName ~= "" then
                    zones[zoneName] = true
                end
            end
        end
    end

    local eggDir = Directory and Directory:FindFirstChild("Eggs")
    if eggDir then
        for _, inst in ipairs(eggDir:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                eggs[inst.Name] = true
            end
        end
    end

    Config.BuyZones = sortedValues(zones)
    Config.AreaByNumber = areaByNumber
    Config.ZoneList = sortedValues(areaByNumber)
    Config.EggList = sortedValues(eggs)

    Config.SelectedAreaNumber = Config.ZoneList[#Config.ZoneList] or "1"
    Config.SelectedBuyZone = Config.AreaByNumber[Config.SelectedAreaNumber] or Config.BuyZones[1] or "Farm"

    if Config.EggName == "" then
        Config.EggName = Config.EggList[1] or ""
    elseif not table.find(Config.EggList, Config.EggName) then
        table.insert(Config.EggList, 1, Config.EggName)
    end
end

collectRuntimeLists()

local function firstValues(values, maxCount)
    local output = {}

    for index, value in ipairs(values) do
        if index > maxCount then break end
        table.insert(output, value)
    end

    return output
end

local function filterValues(values, query, maxCount)
    local output = {}
    local lowerQuery = tostring(query or ""):lower()

    for _, value in ipairs(values) do
        if lowerQuery == "" or tostring(value):lower():find(lowerQuery, 1, true) then
            table.insert(output, value)

            if #output >= maxCount then
                break
            end
        end
    end

    return output
end

local function safeCall(remote, method, ...)
    if not remote then
        return false, "missing remote"
    end

    local ok, result = pcall(function(...)
        return remote[method](remote, ...)
    end, ...)

    if not ok then
        warn("[AlurTest]", remote.Name, result)
    end

    return ok, result
end

local function makePetTargetMap(targetId)
    local targets = {}

    for _, petId in ipairs(Config.PetIds) do
        targets[petId] = {
            v = targetId,
            t = Config.TargetType,
        }
    end

    return targets
end

local function addTarget(targets, seen, value)
    local id = tostring(value or "")

    if id:match("^%d+$") and not seen[id] then
        seen[id] = true
        table.insert(targets, id)
    end
end

local function findBreakableIds()
    local targets = {}
    local seen = {}

    for _, targetId in ipairs(Config.TargetIds) do
        addTarget(targets, seen, targetId)
    end

    if not Config.AutoFindBreakables or not Breakables then
        return targets
    end

    local allowedZones = {}

    for _, zoneValue in ipairs(Config.AllowedZones) do
        allowedZones[Config.AreaByNumber[tostring(zoneValue)] or zoneValue] = true
    end

    local candidates = {}
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, inst in ipairs(Breakables:GetChildren()) do
        if inst:IsA("Model") then
            local uid = inst:GetAttribute("BreakableUID") or inst.Name
            local parentId = inst:GetAttribute("ParentID")
            local isVIP = inst:GetAttribute("VIPBreakable") == true
            local zoneAllowed = next(allowedZones) == nil or allowedZones[parentId] == true

            if zoneAllowed and (Config.IncludeVIP or not isVIP) then
                local distance = 0

                if rootPart then
                    local ok, pivot = pcall(function()
                        return inst:GetPivot()
                    end)

                    if ok then
                        distance = (pivot.Position - rootPart.Position).Magnitude
                    end
                end

                table.insert(candidates, { id = uid, distance = distance })
            end
        end
    end

    if Config.NearestFirst then
        table.sort(candidates, function(a, b)
            return a.distance < b.distance
        end)
    end

    for _, candidate in ipairs(candidates) do
        addTarget(targets, seen, candidate.id)
    end

    return targets
end

local function assignPets(targetId)
    safeCall(Remotes.SetTarget, "FireServer", makePetTargetMap(targetId))

    for _, petId in ipairs(Config.PetIds) do
        safeCall(Remotes.JoinPetBulk, "FireServer", { [petId] = targetId })
        task.wait(0.05)
    end
end

local function buySelectedArea()
    local zoneName = Config.AreaByNumber[Config.SelectedAreaNumber] or Config.SelectedBuyZone

    if zoneName then
        Config.SelectedBuyZone = zoneName
        safeCall(Remotes.RequestPurchase, "InvokeServer", zoneName)
    end
end

local function eggRemoteName(name)
    return tostring(name or ""):gsub("^%d+%s*|%s*", "")
end

local function selectedEggName()
    if Config.EggSearch and Config.EggSearch ~= "" then
        local matches = filterValues(Config.EggList, Config.EggSearch, 1)
        if matches[1] then
            return matches[1]
        end

        return Config.EggSearch
    end

    return Config.EggName
end

local function hatchOnce()
    safeCall(Remotes.HatchCount, "InvokeServer")

    local eggName = eggRemoteName(selectedEggName())
    local ok, result = safeCall(Remotes.EggsRequestPurchase, "InvokeServer", eggName, Config.EggAmount)

    print("[AlurTest] Hatch", ok, result)
    return ok, result
end

if Remotes.EggsPlayOpenAnimation and Remotes.EggsPlayOpenAnimation.OnClientEvent then
    Remotes.EggsPlayOpenAnimation.OnClientEvent:Connect(function(...)
        print("[AlurTest] hatch animation", ...)
    end)
end

local function teleportToArea(areaNumber)
    if not Breakables then return false end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local zoneName = Config.AreaByNumber[tostring(areaNumber or Config.SelectedAreaNumber)]
    if not zoneName then return false end

    local nearest
    local nearestDistance = math.huge

    for _, inst in ipairs(Breakables:GetChildren()) do
        if inst:IsA("Model") and inst:GetAttribute("ParentID") == zoneName and (Config.IncludeVIP or inst:GetAttribute("VIPBreakable") ~= true) then
            local parentId = inst:GetAttribute("ParentID")
            local ok, pivot = pcall(function()
                return inst:GetPivot()
            end)

            if ok then
                local distance = (pivot.Position - root.Position).Magnitude
                if distance < nearestDistance then
                    nearest = pivot
                    nearestDistance = distance
                end
            end
        end
    end

    if nearest then
        root.CFrame = nearest + Vector3.new(0, 6, 0)
        return true
    end

    return false
end

local function fetch(url, cache)
    if readfile then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end

    local data = game:HttpGet(url)

    if writefile then
        pcall(function() writefile(cache, data) end)
    end

    return data
end

local function createUi()
    local okWindUI, WindUI = pcall(function()
        return loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_Alur_WindUI.lua"))()
    end)

    if not okWindUI or type(WindUI) ~= "table" then
        warn("[AlurTest] WindUI load failed", WindUI)
        return
    end

    if getgenv().AlurTestWindow then
        pcall(function() getgenv().AlurTestWindow:Destroy() end)
    end

    local Window = WindUI:CreateWindow({
        Title = "IndraHub Alur",
        Icon = "paw-print",
        Author = "Pet, Egg, Area Automation",
        Folder = "IndraHubAlur",
        Size = UDim2.fromOffset(560, 430),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 170,
    })

    getgenv().AlurTestWindow = Window
    Window:SetToggleKey(Enum.KeyCode.RightControl)

    if Window.EditOpenButton then
        Window:EditOpenButton({ Title = "Alur", Icon = "paw-print", Draggable = true })
    end

    local Tabs = {
        Main = Window:Tab({ Title = "Main", Icon = "play" }),
        Area = Window:Tab({ Title = "Area", Icon = "map" }),
        Egg = Window:Tab({ Title = "Egg", Icon = "egg" }),
        Info = Window:Tab({ Title = "Info", Icon = "info" }),
    }

    Tabs.Main:Toggle({ Title = "Auto Farm Breakables", Value = Config.AutoFarm, Callback = function(value) Config.AutoFarm = value end })
    Tabs.Main:Toggle({ Title = "Include VIP Breakables", Value = Config.IncludeVIP, Callback = function(value) Config.IncludeVIP = value end })
    Tabs.Main:Button({ Title = "Teleport Selected Area Now", Callback = function() teleportToArea(Config.SelectedAreaNumber) end })

    Tabs.Area:Toggle({ Title = "Auto Purchase Selected Area", Value = Config.AutoBuyArea, Callback = function(value) Config.AutoBuyArea = value end })
    Tabs.Area:Toggle({ Title = "Auto Teleport Selected Area", Value = Config.AutoTeleportArea, Callback = function(value) Config.AutoTeleportArea = value end })
    Tabs.Area:Dropdown({ Title = "Buy Area Number", Values = Config.ZoneList, Value = Config.SelectedAreaNumber, Callback = function(value)
        Config.SelectedAreaNumber = tostring(value or Config.SelectedAreaNumber)
        Config.SelectedBuyZone = Config.AreaByNumber[Config.SelectedAreaNumber] or Config.SelectedBuyZone
    end })
    Tabs.Area:Button({ Title = "Purchase Selected Area", Callback = function()
        buySelectedArea()
    end })
    Tabs.Area:Button({ Title = "Teleport Selected Area", Callback = function() teleportToArea(Config.SelectedAreaNumber) end })
    Tabs.Egg:Toggle({ Title = "Auto Hatch", Value = Config.AutoHatch, Callback = function(value) Config.AutoHatch = value end })
    local eggDropdown
    local function eggSearchValues()
        if Config.EggSearch == "" then
            return Config.EggList
        end

        return filterValues(Config.EggList, Config.EggSearch, #Config.EggList)
    end

    Tabs.Egg:Input({ Title = "Search Egg", Value = Config.EggSearch, Callback = function(value)
        Config.EggSearch = value or ""
        local values = eggSearchValues()

        if values[1] then
            Config.EggName = values[1]
        end

        if eggDropdown then
            if eggDropdown.Refresh then
                eggDropdown:Refresh(values)
            elseif eggDropdown.SetValues then
                eggDropdown:SetValues(values)
            end
        end
    end })

    Tabs.Egg:Button({ Title = "Refresh Egg List", Callback = function()
        collectRuntimeLists()
        local values = eggSearchValues()

        if values[1] then
            Config.EggName = values[1]
        end

        if eggDropdown then
            if eggDropdown.Refresh then
                eggDropdown:Refresh(values)
            elseif eggDropdown.SetValues then
                eggDropdown:SetValues(values)
            end
        end

        print("[AlurTest] eggs loaded", #Config.EggList)
    end })

    eggDropdown = Tabs.Egg:Dropdown({ Title = "Egg Results", Values = eggSearchValues(), Value = Config.EggName, Callback = function(value)
        Config.EggName = value or Config.EggName
    end })
    Tabs.Egg:Input({ Title = "Hatch Amount", Value = tostring(Config.EggAmount), Numeric = true, Callback = function(value)
        local amount = tonumber(value)
        if amount and amount > 0 then Config.EggAmount = amount end
    end })
    Tabs.Egg:Button({ Title = "Hatch Once", Callback = function()
        hatchOnce()
    end })

    Tabs.Info:Button({ Title = "Copy Discord Link", Callback = function()
        local link = "https://discord.gg/RSKhtQm3J8"

        if setclipboard then
            setclipboard(link)
        end

        print("[AlurTest] Discord", link)
    end })

    if Window.SelectTab then Window:SelectTab(1) end
end

task.spawn(function()
    local lastJoin = 0
    local lastScan = 0
    local lastBuy = 0
    local lastHatch = 0
    local lastTeleport = 0
    local targetIndex = 1
    local targets = {}

    while true do
        local now = os.clock()

        if Config.AutoFarm then
            if now - lastScan >= Config.ScanDelay then
                targets = findBreakableIds()
                targetIndex = 1
                lastScan = now
            end

            local targetId = targets[targetIndex]

            if targetId then
                if now - lastJoin >= Config.JoinDelay then
                    assignPets(targetId)
                    lastJoin = now
                end

                safeCall(Remotes.DealDamage, "FireServer", targetId)
                targetIndex = targetIndex + 1

                if targetIndex > #targets then
                    targetIndex = 1
                end
            end
        end

        if Config.AutoBuyArea and now - lastBuy >= Config.BuyDelay then
            buySelectedArea()
            lastBuy = now
        end

        if Config.AutoTeleportArea and now - lastTeleport >= 5 then
            teleportToArea(Config.SelectedAreaNumber)
            lastTeleport = now
        end

        if Config.AutoHatch and now - lastHatch >= Config.HatchDelay then
            local ok, result = hatchOnce()
            if not ok or result == false then
                warn("[AlurTest] hatch failed", result, eggRemoteName(Config.EggName), Config.EggAmount)
            end
            lastHatch = now
        end

        task.wait(Config.DamageDelay)
    end
end)

createUi()

print("[AlurTest] UI loaded. Config: getgenv().AlurTest")
