local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local env = getgenv and getgenv() or _G

env.IndraHubMergeNukeRunning = true
env.IndraHubMergeNukeLastHeartbeat = os.clock()
env.IndraHubMergeNukeError = nil

task.spawn(function()
    while env.IndraHubMergeNukeRunning do
        env.IndraHubMergeNukeLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

env.IndraHubMergeNukeEnabled = env.IndraHubMergeNukeEnabled or false
env.IndraHubMergeNukeDelay = env.IndraHubMergeNukeDelay or 0.8
env.IndraHubMergeNukeMergeDelay = env.IndraHubMergeNukeMergeDelay or 1
env.IndraHubMergeNukeMergeRetries = env.IndraHubMergeNukeMergeRetries or 3
env.IndraHubMergeNukePickUpRepeats = env.IndraHubMergeNukePickUpRepeats or 1
env.IndraHubMergeNukeAutoTeleport = env.IndraHubMergeNukeAutoTeleport ~= false
env.IndraHubMergeNukeTeleportOffset = env.IndraHubMergeNukeTeleportOffset or Vector3.new(0, 4, 0)
env.IndraHubMergeNukeDropIfNotMerged = env.IndraHubMergeNukeDropIfNotMerged ~= false
env.IndraHubMergeNukeDropCFrame = env.IndraHubMergeNukeDropCFrame or nil
env.IndraHubMergeNukeBaseName = env.IndraHubMergeNukeBaseName or nil
env.IndraHubMergeNukeUseDummyModel = env.IndraHubMergeNukeUseDummyModel ~= false
env.IndraHubMergeNukeTryBothArgs = env.IndraHubMergeNukeTryBothArgs ~= false
env.IndraHubMergeNukeTryAllCandidates = env.IndraHubMergeNukeTryAllCandidates ~= false
env.IndraHubMergeNukeSameTierOnly = env.IndraHubMergeNukeSameTierOnly ~= false
env.IndraHubMergeNukeOwnPlotOnly = env.IndraHubMergeNukeOwnPlotOnly ~= false

env.IndraHubMergeNukeAutoLock = env.IndraHubMergeNukeAutoLock or false
env.IndraHubMergeNukeAutoBuyMax = env.IndraHubMergeNukeAutoBuyMax or false
env.IndraHubMergeNukeAutoBuyTier = env.IndraHubMergeNukeAutoBuyTier or false
env.IndraHubMergeNukeAutoBuyLockBase = env.IndraHubMergeNukeAutoBuyLockBase or false



local function findRemote(path)
    local current = ReplicatedStorage
    for _, name in ipairs(path) do
        current = current and current:WaitForChild(name, 10)
    end
    return current
end

local MergeRequest = findRemote({"Packages", "Remotes", "Networking", "RE/Merge/MergeRequest"}) or findRemote({"NukeRemotes", "MergeRequest"})
local PickUp = findRemote({"NukeRemotes", "PickUp"})
local Drop = findRemote({"NukeRemotes", "Drop"})
local RequestLockBase = findRemote({"NukeRemotes", "RequestLockBase"})
local PurchaseUpgrade = findRemote({"NukeRemotes", "PurchaseUpgrade"})

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function setStatus(text)
    print("[MergeNuke] " .. tostring(text))
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({Title = "IndraHub Merge Nuke", Content = tostring(text), Icon = "rocket", Duration = 2})
        end)
    end
end

local function getBase()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then return nil end

    if env.IndraHubMergeNukeBaseName then
        local chosen = bases:FindFirstChild(tostring(env.IndraHubMergeNukeBaseName))
        if chosen then return chosen end
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local bestBase = nil
    local bestDistance = math.huge

    local function isOwnBase(base)
        local playerName = LocalPlayer.Name
        local displayName = LocalPlayer.DisplayName

        for _, key in ipairs({"Owner", "owner", "OwnerName", "Player", "Username"}) do
            local ok, value = pcall(function() return base:GetAttribute(key) end)
            if ok and value ~= nil then
                value = tostring(value)
                if value == playerName or value == displayName or value == tostring(LocalPlayer.UserId) then return true end
            end
        end

        for _, child in ipairs(base:GetDescendants()) do
            if child:IsA("StringValue") or child:IsA("ObjectValue") or child:IsA("IntValue") then
                local name = string.lower(child.Name)
                if string.find(name, "owner", 1, true) or string.find(name, "player", 1, true) then
                    local value = child:IsA("ObjectValue") and child.Value or child.Value
                    if value == LocalPlayer or tostring(value) == playerName or tostring(value) == displayName or tostring(value) == tostring(LocalPlayer.UserId) then
                        return true
                    end
                end
            end
        end

        local lowerName = string.lower(base.Name)
        return string.find(lowerName, string.lower(playerName), 1, true) ~= nil or string.find(lowerName, string.lower(displayName), 1, true) ~= nil
    end

    for _, base in ipairs(bases:GetChildren()) do
        if isOwnBase(base) then return base end
    end

    for _, base in ipairs(bases:GetChildren()) do
        local nuke = base:FindFirstChild("Nukes") and base.Nukes:FindFirstChild("Nuke")
        if nuke then
            if root and nuke:IsA("Model") then
                local pivot = nuke:GetPivot()
                local distance = (pivot.Position - root.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestBase = base
                end
            elseif root and nuke:IsA("BasePart") then
                local distance = (nuke.Position - root.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestBase = base
                end
            elseif not bestBase then
                bestBase = base
            end
        end
    end

    return bestBase
end

local function getNuke()
    local base = getBase()
    if not base then return nil end
    local nukes = base:FindFirstChild("Nukes")
    return nukes and nukes:FindFirstChild("Nuke") or nil
end

local function getNukeCandidates()
    local candidates = {}
    local seen = {}

    local function add(inst)
        if inst and typeof(inst) == "Instance" and not seen[inst] then
            seen[inst] = true
            candidates[#candidates + 1] = inst
        end
    end

    add(getNuke())

    local base = getBase()
    if env.IndraHubMergeNukeOwnPlotOnly and base then
        for _, inst in ipairs(base:GetDescendants()) do
            local name = string.lower(inst.Name)
            if (inst:IsA("Model") or inst:IsA("BasePart") or inst:IsA("Folder")) and (name == "nuke" or string.find(name, "nuke", 1, true)) then
                add(inst)
            end
        end
        return candidates
    end

    for _, root in ipairs({Workspace, ReplicatedStorage}) do
        for _, inst in ipairs(root:GetDescendants()) do
            local name = string.lower(inst.Name)
            if (inst:IsA("Model") or inst:IsA("BasePart") or inst:IsA("Folder")) and (name == "nuke" or string.find(name, "nuke", 1, true)) then
                add(inst)
            end
        end
    end

    return candidates
end

local function nukeTier(inst)
    if not inst then return "?" end

    for _, key in ipairs({"Tier", "TIER", "Level", "LEVEL", "Rank", "Value"}) do
        local ok, value = pcall(function() return inst:GetAttribute(key) end)
        if ok and value ~= nil then return tostring(value) end
    end

    for _, key in ipairs({"Tier", "TIER", "Level", "LEVEL", "Rank", "Value"}) do
        local child = inst:FindFirstChild(key, true)
        if child and child:IsA("ValueBase") then return tostring(child.Value) end
    end

    local nameTier = string.match(inst.Name, "%d+")
    return nameTier or inst.Name
end

local function getMergePairs()
    local candidates = getNukeCandidates()
    local pairs = {}

    for _, pickup in ipairs(candidates) do
        local pickupTier = nukeTier(pickup)
        for _, mergeTarget in ipairs(candidates) do
            if mergeTarget ~= pickup then
                local sameTier = nukeTier(mergeTarget) == pickupTier
                if sameTier or not env.IndraHubMergeNukeSameTierOnly then
                    pairs[#pairs + 1] = {pickup = pickup, target = mergeTarget, tier = pickupTier}
                end
            end
        end
    end

    return pairs
end

local function bestMergePair()
    local pairs = getMergePairs()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return pairs[1], #pairs end

    local best = pairs[1]
    local bestDistance = math.huge
    for _, pair in ipairs(pairs) do
        local ok, pivot = pcall(function()
            if pair.pickup:IsA("Model") then return pair.pickup:GetPivot() end
            if pair.pickup:IsA("BasePart") then return pair.pickup.CFrame end
            return nil
        end)
        local distance = ok and pivot and (pivot.Position - root.Position).Magnitude or math.huge
        if distance < bestDistance then
            bestDistance = distance
            best = pair
        end
    end
    return best, #pairs
end

local function getMergeArg()
    if env.IndraHubMergeNukeUseDummyModel then
        return Instance.new("Model")
    end
    return getNuke() or Instance.new("Model")
end

local function getArgsToTry()
    local args = {}
    if env.IndraHubMergeNukeTryAllCandidates then
        for _, candidate in ipairs(getNukeCandidates()) do
            args[#args + 1] = candidate
        end
    end

    if env.IndraHubMergeNukeUseDummyModel then
        args[#args + 1] = Instance.new("Model")
        local nuke = getNuke()
        if env.IndraHubMergeNukeTryBothArgs and nuke then args[#args + 1] = nuke end
    else
        local nuke = getNuke()
        if nuke then args[#args + 1] = nuke end
        if env.IndraHubMergeNukeTryBothArgs then args[#args + 1] = Instance.new("Model") end
    end
    return args
end

local function dumpCandidates()
    local candidates = getNukeCandidates()
    setStatus("candidates: " .. tostring(#candidates))
    for i, inst in ipairs(candidates) do
        print("[MergeNuke] candidate[" .. i .. "]", inst.ClassName, "tier=" .. nukeTier(inst), inst:GetFullName())
    end
    return candidates
end

local function fire(remote, ...)
    if not remote then
        setStatus("remote missing")
        return false
    end
    local args = {...}
    local remotePath = remote:GetFullName()
    local argText = typeof(args[1]) == "Instance" and args[1]:GetFullName() or tostring(args[1])
    print("[MergeNuke] fire", remotePath, "arg=", argText)
    local ok, err = pcall(function()
        remote:FireServer(unpack(args))
    end)
    if not ok then setStatus("remote failed: " .. tostring(err)) end
    return ok
end

local function teleportTo(inst)
    if env.IndraHubMergeNukeAutoTeleport ~= true then return false end
    if typeof(inst) ~= "Instance" then return false end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local ok, cf = pcall(function()
        if inst:IsA("Model") then return inst:GetPivot() end
        if inst:IsA("BasePart") then return inst.CFrame end
        local part = inst:FindFirstChildWhichIsA("BasePart", true)
        return part and part.CFrame or nil
    end)
    if ok and cf then
        root.CFrame = cf + env.IndraHubMergeNukeTeleportOffset
        return true
    end
    return false
end

local function dropHeldNuke()
    if not env.IndraHubMergeNukeDropIfNotMerged then return false end
    if not Drop then
        setStatus("drop remote missing")
        return false
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local cf = env.IndraHubMergeNukeDropCFrame or (root and root.CFrame)
    if not cf then
        setStatus("drop cframe missing")
        return false
    end

    fire(Drop, cf)
    setStatus("dropped held nuke")
    return true
end

local function mergeOnce()
    local pickupNuke = getNuke()
    if not pickupNuke then
        setStatus("pickup nuke not found")
        return false
    end

    for _ = 1, env.IndraHubMergeNukePickUpRepeats do
        teleportTo(pickupNuke)
        task.wait(0.15)
        if PickUp then fire(PickUp, pickupNuke) end
        task.wait(0.12)
    end

    for i = 1, env.IndraHubMergeNukeMergeRetries do
        task.wait(env.IndraHubMergeNukeMergeDelay)
        local mergeNuke = getNuke()
        if mergeNuke then
            teleportTo(mergeNuke)
            task.wait(0.15)
            fire(MergeRequest, mergeNuke)
            setStatus("merge retry " .. tostring(i) .. ": " .. mergeNuke:GetFullName())
        else
            setStatus("merge nuke not found retry " .. tostring(i))
        end
    end

    dropHeldNuke()
    return true
end

local function lockBase()
    fire(RequestLockBase)
    setStatus("lock requested")
end

local function buyUpgrade(kind)
    fire(PurchaseUpgrade, kind)
    setStatus("upgrade requested: " .. tostring(kind))
end

local function runCapturedSequence()
    mergeOnce()
end

-- ================== WIND UI ================== --

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "rocket",
    Author = "IndraT99",
    Folder = "IndraHubMergeNuke",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 170,
    HideSearchBar = false,
})

local Tabs = {
    Main = Window:Tab({Title = "Merge Nuke", Icon = "zap"}),
    Upgrades = Window:Tab({Title = "Upgrades", Icon = "trending-up"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}),
}

Tabs.Main:Section({Title = "Automation", Icon = "zap"})
Tabs.Main:Toggle({Title = "Auto Merge", Desc = "Continuously merge nukes", Value = env.IndraHubMergeNukeEnabled, Callback = function(v)
    env.IndraHubMergeNukeEnabled = v
    setStatus(v and "Auto merge enabled" or "Auto merge disabled")
end})

Tabs.Main:Section({Title = "Actions", Icon = "mouse-pointer"})
Tabs.Main:Button({Title = "Merge + PickUp Once", Callback = mergeOnce})
Tabs.Main:Button({Title = "Run Captured Sequence", Callback = runCapturedSequence})
Tabs.Main:Toggle({Title = "Auto Lock Base", Desc = "Continuously attempt to lock your base", Value = env.IndraHubMergeNukeAutoLock, Callback = function(v)
    env.IndraHubMergeNukeAutoLock = v
    setStatus(v and "Auto Lock Base enabled" or "Auto Lock Base disabled")
end})
Tabs.Main:Button({Title = "Dump Candidates", Callback = dumpCandidates})

Tabs.Upgrades:Section({Title = "Buy Upgrades", Icon = "shopping-cart"})
Tabs.Upgrades:Toggle({Title = "Auto Buy MAX Upgrade", Desc = "Continuously buy MAX upgrades", Value = env.IndraHubMergeNukeAutoBuyMax, Callback = function(v)
    env.IndraHubMergeNukeAutoBuyMax = v
    setStatus(v and "Auto Buy MAX enabled" or "Auto Buy MAX disabled")
end})
Tabs.Upgrades:Toggle({Title = "Auto Buy TIER Upgrade", Desc = "Continuously buy TIER upgrades", Value = env.IndraHubMergeNukeAutoBuyTier, Callback = function(v)
    env.IndraHubMergeNukeAutoBuyTier = v
    setStatus(v and "Auto Buy TIER enabled" or "Auto Buy TIER disabled")
end})
Tabs.Upgrades:Toggle({Title = "Auto Buy LOCKBASE Upgrade", Desc = "Continuously buy LOCKBASE upgrades", Value = env.IndraHubMergeNukeAutoBuyLockBase, Callback = function(v)
    env.IndraHubMergeNukeAutoBuyLockBase = v
    setStatus(v and "Auto Buy LOCKBASE enabled" or "Auto Buy LOCKBASE disabled")
end})

Tabs.Settings:Section({Title = "Delays & Retries", Icon = "clock"})
Tabs.Settings:Slider({Title = "Auto Merge Loop Delay", Value = {Min = 0.1, Max = 5, Default = env.IndraHubMergeNukeDelay}, Step = 0.1, Callback = function(v) env.IndraHubMergeNukeDelay = v end})
Tabs.Settings:Slider({Title = "Merge Action Delay", Value = {Min = 0.1, Max = 5, Default = env.IndraHubMergeNukeMergeDelay}, Step = 0.1, Callback = function(v) env.IndraHubMergeNukeMergeDelay = v end})
Tabs.Settings:Slider({Title = "Merge Retries", Value = {Min = 1, Max = 10, Default = env.IndraHubMergeNukeMergeRetries}, Step = 1, Callback = function(v) env.IndraHubMergeNukeMergeRetries = v end})
Tabs.Settings:Slider({Title = "PickUp Repeats", Value = {Min = 1, Max = 5, Default = env.IndraHubMergeNukePickUpRepeats}, Step = 1, Callback = function(v) env.IndraHubMergeNukePickUpRepeats = v end})

Tabs.Settings:Section({Title = "Preferences", Icon = "sliders"})
Tabs.Settings:Toggle({Title = "Auto Teleport", Value = env.IndraHubMergeNukeAutoTeleport, Callback = function(v) env.IndraHubMergeNukeAutoTeleport = v end})
Tabs.Settings:Toggle({Title = "Drop If Not Merged", Value = env.IndraHubMergeNukeDropIfNotMerged, Callback = function(v) env.IndraHubMergeNukeDropIfNotMerged = v end})
Tabs.Settings:Toggle({Title = "Own Plot Only", Value = env.IndraHubMergeNukeOwnPlotOnly, Callback = function(v) env.IndraHubMergeNukeOwnPlotOnly = v end})
Tabs.Settings:Toggle({Title = "Same Tier Only", Value = env.IndraHubMergeNukeSameTierOnly, Callback = function(v) env.IndraHubMergeNukeSameTierOnly = v end})

task.spawn(function()
    while true do
        if env.IndraHubMergeNukeEnabled then
            mergeOnce()
            task.wait(env.IndraHubMergeNukeDelay)
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while true do
        if env.IndraHubMergeNukeAutoLock then
            lockBase()
        end
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        if env.IndraHubMergeNukeAutoBuyMax then
            buyUpgrade("MAX")
        end
        if env.IndraHubMergeNukeAutoBuyTier then
            buyUpgrade("TIER")
        end
        if env.IndraHubMergeNukeAutoBuyLockBase then
            buyUpgrade("LOCKBASE")
        end
        task.wait(0.5)
    end
end)

env.IndraHubMergeNukeMergeOnce = mergeOnce
env.IndraHubMergeNukeRunSequence = runCapturedSequence
env.IndraHubMergeNukeLockBase = lockBase
env.IndraHubMergeNukeBuyUpgrade = buyUpgrade
env.IndraHubMergeNukeDumpCandidates = dumpCandidates
env.IndraHubMergeNukeDrop = dropHeldNuke

setStatus("IndraHub Merge Nuke Loaded!")
