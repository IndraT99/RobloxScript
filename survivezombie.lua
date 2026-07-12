local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubSurviveZombieRunning") then return end
setGlobal("IndraHubSurviveZombieRunning", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        setGlobal("IndraHubSurviveZombieLastHeartbeat", os.time())
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Survive Zombie",
    Icon = "swords",
    Author = "IndraHub",
    Folder = "IndraHubSurviveZombie",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local TabMain = Window:Tab({ Title = "Main", Icon = "home" })
local TabGears = Window:Tab({ Title = "Gears", Icon = "package" })

TabMain:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({Title="Success", Content="Discord invite copied to clipboard!"})
    end
})


local function findIn(parent, ...)
    local node = parent
    for _, name in ipairs({ ... }) do
        if not node then return nil end
        node = node:FindFirstChild(name)
    end
    return node
end

local ServiceRegistry
do
    local sr = findIn(ReplicatedStorage, "Modules", "ServiceRegistry")
    if sr then
        local ok, mod = pcall(require, sr)
        if ok then ServiceRegistry = mod end
    end
end

local function getService(name, timeout)
    if not ServiceRegistry then return nil end
    if ServiceRegistry.WaitFor then
        local ok, svc = pcall(function() return ServiceRegistry.WaitFor(name, timeout or 10) end)
        if ok then return svc end
    end
    local ok, svc = pcall(function() return ServiceRegistry.Get(name) end)
    return ok and svc or nil
end

local httpGet = game.HttpGet or game.HttpGetAsync
local function fetch(url)
    return httpGet(game, url)
end



local GameStateRemotes = ReplicatedStorage:FindFirstChild("GameStateRemotes")
local WaveRemotes = ReplicatedStorage:FindFirstChild("WaveRemotes")
local UpgradeRemotes = ReplicatedStorage:FindFirstChild("UpgradeRemotes")
local GearRemotes = ReplicatedStorage:FindFirstChild("GearRemotes")

local GearData
do
    local mod = findIn(ReplicatedStorage, "Data", "GearData")
    if mod then
        local ok, m = pcall(require, mod)
        if ok then GearData = m end
    end
end

local function fireRemote(remote, ...)
    if remote then
        pcall(function(...) remote:FireServer(...) end, ...)
    end
end

local AutoReplayEnabled = false
local hasVotedReplay = false

if GameStateRemotes then
    local GameOverStarted = GameStateRemotes:FindFirstChild("GameOverStarted")
    local GameOverEnded = GameStateRemotes:FindFirstChild("GameOverEnded")
    local VotePlayAgain = GameStateRemotes:FindFirstChild("VotePlayAgain")

    if GameOverStarted then
        GameOverStarted.OnClientEvent:Connect(function()
            if AutoReplayEnabled and not hasVotedReplay and VotePlayAgain then
                hasVotedReplay = true
                task.delay(1, function()
                    fireRemote(VotePlayAgain)
                end)
            end
        end)
    end

    if GameOverEnded then
        GameOverEnded.OnClientEvent:Connect(function()
            hasVotedReplay = false
        end)
    end
end

local AutoNextWaveEnabled = false

task.spawn(function()
    local SettingsClient = getService("SettingsClient", 20)
    if SettingsClient then
        task.spawn(function()
            while task.wait(1) do
                if not getGlobal("IndraHubSurviveZombieRunning") then break end
                if AutoNextWaveEnabled and SettingsClient:Get("AutoVote") ~= true then
                    pcall(function() SettingsClient:Set("AutoVote", true) end)
                elseif not AutoNextWaveEnabled and SettingsClient:Get("AutoVote") == true then
                    pcall(function() SettingsClient:Set("AutoVote", false) end)
                end
                end
    end\)
    elseif WaveRemotes then
        local SkipUpdate = WaveRemotes:FindFirstChild("SkipUpdate")
        local SkipVote = WaveRemotes:FindFirstChild("SkipVote")
        if SkipUpdate then
            SkipUpdate.OnClientEvent:Connect(function(data)
                if AutoNextWaveEnabled and data and data.Action == "SpawningComplete" then
                    fireRemote(SkipVote, true)
                end
            end)
        end
    end
end)

local AutoSkipWaveEnabled = false

task.spawn(function()
    local SkipVote = WaveRemotes and WaveRemotes:FindFirstChild("SkipVote")
    local SkipUpdate = WaveRemotes and WaveRemotes:FindFirstChild("SkipUpdate")
    if not SkipVote then return end

    if SkipUpdate then
        SkipUpdate.OnClientEvent:Connect(function(data)
            if AutoSkipWaveEnabled and data
                and (data.Action == "SpawningComplete" or data.Action == "Update") then
                fireRemote(SkipVote, true)
            end
        end)
    end

    while task.wait(2) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        if AutoSkipWaveEnabled then
            fireRemote(SkipVote, true)
        end
        end
    end\)

local AutoEquipWeaponEnabled = false

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        if AutoEquipWeaponEnabled then
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and humanoid and not character:FindFirstChildOfClass("Tool") then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local tool = backpack and backpack:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() humanoid:EquipTool(tool) end)
                end
            end
        end
        end
    end\)

local HideCrosshairEnabled = false

task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.25) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        local gui = PlayerGui:FindFirstChild("CrosshairGui")
        if gui then
            local target = not HideCrosshairEnabled
            if gui.Enabled ~= target then
                gui.Enabled = target
            end
        end
        end
    end\)

local AutoUpgradeHealthEnabled = false
local AutoUpgradeWeaponEnabled = false

task.spawn(function()
    local PurchaseHealthUpgrade = UpgradeRemotes and UpgradeRemotes:FindFirstChild("PurchaseHealthUpgrade")
    local PurchaseWeaponUpgrade = UpgradeRemotes and UpgradeRemotes:FindFirstChild("PurchaseWeaponUpgrade")
    while task.wait(1) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        if AutoUpgradeHealthEnabled then
            fireRemote(PurchaseHealthUpgrade)
        end
        if AutoUpgradeWeaponEnabled then
            fireRemote(PurchaseWeaponUpgrade)
        end
        end
    end\)

local AutoUseGearEnabled = false
local SelectedGearNames = {}
local GearPurchase = GearRemotes and GearRemotes:FindFirstChild("GearPurchase")

local GearDisplayToKey = {}
local GearDisplayList = {}

if GearData then
    local ok, names = pcall(function() return GearData.GetAllGearNames() end)
    if ok and names then
        table.sort(names)
        for _, key in ipairs(names) do
            local cfgOk, cfg = pcall(function() return GearData.GetConfig(key) end)
            local display = (cfgOk and cfg and cfg.DisplayName) or key
            GearDisplayToKey[display] = key
            table.insert(GearDisplayList, display)
        end
    end
end

local nextGearFire = {}

task.spawn(function()
    while task.wait(0.1) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        if AutoUseGearEnabled and GearPurchase then
            local now = os.clock()
            for _, key in ipairs(SelectedGearNames) do
                if not nextGearFire[key] or now >= nextGearFire[key] then
                    local cooldown = 1
                    if GearData then
                        local ok, cfg = pcall(function() return GearData.GetConfig(key) end)
                        if ok and cfg and cfg.Cooldown then
                            cooldown = cfg.Cooldown
                        end
                    end
                    fireRemote(GearPurchase, key)
                    nextGearFire[key] = now + math.max(cooldown, 0.1)
                end
            end
        end
        end
    end\)

local KillAuraEnabled = false
local KillAuraRadius = 60
local KILL_AURA_TICK = 0.03
local KILL_AURA_MAX_TARGETS = 18

local GunHit = nil
do
    local GunRemotes = ReplicatedStorage:FindFirstChild("GunRemotes")
    if GunRemotes then
        GunHit = GunRemotes:FindFirstChild("GunHit")
    end
end

local function getZombiePosition(record)
    if not record then return nil end
    local model = record.Model
    if not (model and model.Parent) then return nil end
    local pp = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    return pp and pp.Position or nil
end

local function resolveGunName(gunClient)
    if gunClient and gunClient.EquippedGun then
        return gunClient.EquippedGun.Name
    end
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
    end
    return "Pistol"
end

local function isAlive(rec)
    return rec and not rec.IsDying and (rec.Health == nil or rec.Health > 0)
end

local function collectTargets(ZombieClient, root, radius, maxTargets)
    local ok, ids = pcall(function()
        return ZombieClient:GetNearbyZombieIds(root.Position, radius)
    end)
    if not ok or not ids then return {} end
    local zombies = ZombieClient.Zombies

    local alive = {}
    for _, id in ipairs(ids) do
        local rec = zombies and zombies[id]
        if isAlive(rec) then
            alive[#alive + 1] = { id = id, hp = rec.Health or math.huge, rec = rec }
        end
    end
    table.sort(alive, function(a, b) return a.hp < b.hp end)

    local out = {}
    for i = 1, math.min(#alive, maxTargets) do
        local pos = getZombiePosition(alive[i].rec)
        if pos then
            out[#out + 1] = { id = alive[i].id, pos = pos }
        end
    end
    return out
end

task.spawn(function()
    local ZombieClient = getService("ZombieClient", 30)
    local GunClient = getService("GunClient", 30)
    while task.wait(KILL_AURA_TICK) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        if KillAuraEnabled and GunHit and ZombieClient then
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local gunName = resolveGunName(GunClient)
                local targets = collectTargets(ZombieClient, root, KillAuraRadius, KILL_AURA_MAX_TARGETS)
                for _, t in ipairs(targets) do
                    pcall(function() GunHit:FireServer(gunName, t.id, t.pos) end)
                end
            end
        end
        task.wait(KILL_AURA_TICK)
    end
end)

local RapidFireEnabled = false
local RapidFireInterval = 0.02

task.spawn(function()
    local GunClient = getService("GunClient", 30)
    local originalRate = setmetatable({}, { __mode = "k" })
    while task.wait(0.1) do
        if not getGlobal("IndraHubSurviveZombieRunning") then break end
        local cfg = GunClient and GunClient.EquippedConfig
        if cfg then
            if RapidFireEnabled then
                if originalRate[cfg] == nil then
                    originalRate[cfg] = cfg.FireRate
                end
                if cfg.FireRate ~= RapidFireInterval then
                    cfg.FireRate = RapidFireInterval
                end
            elseif originalRate[cfg] ~= nil then
                cfg.FireRate = originalRate[cfg]
                originalRate[cfg] = nil
            end
        end
        end
    end\)


TabMain:Toggle({
    Title = "Auto Replay",
    Default = false,
    Callback = function(v) AutoReplayEnabled = v end
})
TabMain:Toggle({
    Title = "Auto Next Wave",
    Default = false,
    Callback = function(v) AutoNextWaveEnabled = v end
})
TabMain:Toggle({
    Title = "Auto Skip Wave",
    Desc = "Casts the skip vote as soon as it's available each wave",
    Default = false,
    Callback = function(v) AutoSkipWaveEnabled = v end
})
TabMain:Toggle({
    Title = "Auto Equip Weapon",
    Desc = "Re-equips your gun if it gets unequipped",
    Default = false,
    Callback = function(v) AutoEquipWeaponEnabled = v end
})
TabMain:Toggle({
    Title = "Hide Built In Crosshair",
    Default = false,
    Callback = function(v) HideCrosshairEnabled = v end
})
TabMain:Toggle({
    Title = "Kill Aura",
    Desc = "Damages zombies around you with your equipped gun",
    Default = false,
    Callback = function(v) KillAuraEnabled = v end
})
TabMain:Toggle({
    Title = "Rapid Fire",
    Desc = "Removes your gun's fire-rate cooldown while held",
    Default = false,
    Callback = function(v) RapidFireEnabled = v end
})
TabMain:Slider({
    Title = "Rapid Fire Interval",
    Desc = "Seconds between shots (lower = faster)",
    Step = 0.01,
    Value = 0.02,
    Min = 0.01,
    Max = 0.2,
    Callback = function(v) RapidFireInterval = v end
})
TabMain:Slider({
    Title = "Kill Aura Radius",
    Desc = "Range (studs) zombies are hit within",
    Step = 1,
    Value = 60,
    Min = 10,
    Max = 200,
    Callback = function(v) KillAuraRadius = v end
})
TabMain:Toggle({
    Title = "Auto Upgrade Health",
    Default = false,
    Callback = function(v) AutoUpgradeHealthEnabled = v end
})
TabMain:Toggle({
    Title = "Auto Upgrade Weapon",
    Default = false,
    Callback = function(v) AutoUpgradeWeaponEnabled = v end
})

TabGears:Toggle({
    Title = "Auto Use Gear",
    Default = false,
    Callback = function(v) AutoUseGearEnabled = v end
})
TabGears:Dropdown({
    Title = "Gears to auto-use",
    Desc = "Select which gears should be auto-fired",
    Multi = true,
    Values = GearDisplayList,
    Callback = function(v)
        local keys = {}
        for display, state in next, v do
            if state and GearDisplayToKey[display] then
                table.insert(keys, GearDisplayToKey[display])
            end
        end
        SelectedGearNames = keys
    end
})
