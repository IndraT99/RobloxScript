-- ==========================================
-- WINDUI SETUP & INDRAHUB INITIALIZATION
-- ==========================================
shared.IndraHub_Builabase_Unloaded = false

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Build a Base RNG",
    Icon = "rbxassetid://91400086538074",
    Author = "IndraHub",
    Folder = "IndraHub_Builabase",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    R = Window:Tab({ Title = "Roll", Icon = "dices" }),
    Co = Window:Tab({ Title = "Combat", Icon = "swords" }),
    B = Window:Tab({ Title = "Build", Icon = "hammer" }),
    Cr = Window:Tab({ Title = "Craft", Icon = "flask-conical" }),
    St = Window:Tab({ Title = "Steal", Icon = "copy" }),
    Se = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

local flags = {
    AutoRoll = false,
    InstantRoll = true,
    RollDelay = 0.05,
    KillAura = false,
    OnlyDuringWave = true,
    ApproachEnemy = true,
    AuraMode = "Densest Cluster",
    AuraHover = 2,
    ClusterRadius = 14,
    AttackDelay = 0.14,
    IgnoreCooldown = false,
    AutoStartWave = false,
    AutoStopAtWave = false,
    StopWaveNumber = 50,
    WaveStartDelay = 2,
    AutoCollectGold = false,
    GoldRange = 250,
    AutoBuySkills = false,
    SkillDelay = 0.5,
    AutoPlace = false,
    AutoPlaceRandom = false,
    PlaceBuildings = {},
    PlaceCategory = "Any",
    PlaceMinRarity = "Basic",
    PlaceRotation = "0",
    PlaceKeep = 0,
    PlaceMax = 40,
    RespectLimit = true,
    StopOnFull = true,
    PlaceDelay = 0.2,
    AutoUpgrade = false,
    UpgradeAll = true,
    UpgradeBuildings = {},
    UpgradeMaxLevel = 64,
    UpgradeKeepMoney = 0,
    UpgradeDelay = 0.2,
    AutoCraft = false,
    CraftRecipes = {},
    CraftKeep = 0,
    CraftMaxRarity = "Lunatic",
    CraftDelay = 1,
    StealTarget = nil,
    StealClearFirst = true,
    StealSubstituteNormal = false,
    StealDelay = 0.2,
    AntiAfk = true,
}

--[[
    Ouroboros Hub - Build a Base RNG
    Semantic reconstruction of active/builabase.lua.

    The original uses a shuffled constant pool and flattened control flow.
    UI, modules, remote names, defaults, filters, and automation flow were
    recovered through sandboxed trace emulation.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local function requirePath(root, ...)
    local current = root
    for _, name in ipairs({ ... }) do
        current = current:WaitForChild(name)
    end
    return require(current)
end

local DataService = requirePath(Modules, "Core", "DataService")
local GameModule = require(ReplicatedStorage:WaitForChild("GameModule"))
local Warp = requirePath(Modules, "Core", "Warp")
local RandModule = requirePath(Modules, "Core", "RandModule")
local BuildingsUtility = requirePath(Modules, "Features", "Buildings", "Utility")
local SkillsUtility = requirePath(Modules, "Features", "Skills", "Utility")
local RecipesUtility = requirePath(Modules, "Features", "Recipes", "Utility")
local WeaponsConfig = requirePath(Modules, "Features", "Weapons", "WeaponsConfig")
local SharedPlacement = requirePath(Modules, "Gameplay", "PlacementModule", "SharedPlacementModule")
local ClientBuildModule = requirePath(Modules, "Gameplay", "ClientBuildModule")
local ClientRollModule = requirePath(Modules, "Gameplay", "ClientRollModule")

local Remotes = {
    Roll = Warp.Client("Roll"),
    PlaceBuilding = Warp.Client("PlaceBuilding"),
    BuySkill = Warp.Client("BuySkill"),
    Craft = Warp.Client("Craft"),
    ClearPlot = Warp.Client("ClearPlot"),
    AttackWeapon = Warp.Client("AttackWeapon"),
    StartWave = Warp.Client("StartWave"),
    StopWave = Warp.Client("StopWave"),
    SetAutoWave = Warp.Client("SetAutoWave"),
    UpgradeBuilding = Warp.Client("UpgradeBuilding"),
}

local getIdentity = getthreadidentity or getidentity or get_thread_identity
local setIdentity = setthreadidentity or setidentity or set_thread_identity

local function withIdentity(callback)
    local previous = getIdentity and getIdentity()
    if setIdentity then
        setIdentity(2)
    end

    local result = table.pack(pcall(callback))
    if setIdentity and previous then
        setIdentity(previous)
    end

    if not result[1] then
        warn(result[2])
        return nil
    end
    return table.unpack(result, 2, result.n)
end

local function invoke(remote, ...)
    local arguments = table.pack(...)
    return withIdentity(function()
        return remote:Invoke(table.unpack(arguments, 1, arguments.n))
    end)
end

local function fire(remote, ...)
    local arguments = table.pack(...)
    return withIdentity(function()
        return remote:Fire(table.unpack(arguments, 1, arguments.n))
    end)
end

local INVITE_LNK = "https://discord.gg/2PPBJsmqr"
local WINDUI_URL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"





local RARITIES = {
    "Basic", "Rare", "Refined", "Epic", "Legendary", "Mythic",
    "Glorious", "Primordial", "Atomic", "Divine", "Lunatic",
}

Tabs.R:Toggle({ Title = "Auto Roll", Default = false, Callback = function(v) flags.AutoRoll = v end })
Tabs.R:Toggle({ Title = "Instant Roll", Default = false, Callback = function(v) flags.InstantRoll = v end })
Tabs.R:Label({
    DoesWrap = true,
    Text = '<font color="rgb(255,70,70)">Instant Roll can look frozen for a while with no rolls coming through. That is normal, it is still faster than the normal auto roll. Do not report this in the Discord as a bug.</font>',
})
Tabs.R:Slider({ Title = "Roll Delay", Value = { Min = 0, Max = 2, Default = 0.05 }, Callback = function(v) flags.RollDelay = v end })

local RollsLabel = Tabs.R:Label({ Title = "Rolls this session: 0" })
local LastRollLabel = Tabs.R:Label({ Title = "Last: none" })

Tabs.Co:Toggle({ Title = "Auto Farm", Default = false, Callback = function(v) flags.KillAura = v end })
Tabs.Co:Toggle({ Title = "Only During Wave", Default = false, Callback = function(v) flags.OnlyDuringWave = v end })
Tabs.Co:Toggle({ Title = "Move To Enemies", Default = false, Callback = function(v) flags.ApproachEnemy = v end })
Tabs.Co:Dropdown({ Title = "Target Mode", Values = { "Nearest", "Densest Cluster", "Cycle All" }, Default = 1, Multi = false, Callback = function(v) flags.AuraMode = v end })
Tabs.Co:Slider({ Title = "Hover Distance", Value = { Min = 0, Max = 20, Default = 2 }, Callback = function(v) flags.AuraHover = v end })
Tabs.Co:Slider({ Title = "Cluster Radius", Value = { Min = 4, Max = 60, Default = 14 }, Callback = function(v) flags.ClusterRadius = v end })
Tabs.Co:Slider({ Title = "Attack Delay", Value = { Min = 0.05, Max = 1, Default = 0.14 }, Callback = function(v) flags.AttackDelay = v end })
Tabs.Co:Toggle({ Title = "Ignore Weapon Cooldown", Default = false, Callback = function(v) flags.IgnoreCooldown = v end })

Tabs.Co:Toggle({ Title = "Auto Start Wave", Default = false, Callback = function(v) flags.AutoStartWave = v end })
Tabs.Co:Toggle({ Title = "Auto Stop At Wave", Default = false, Callback = function(v) flags.AutoStopAtWave = v end })
Tabs.Co:Slider({ Title = "Stop At Wave", Value = { Min = 1, Max = 500, Default = 50 }, Callback = function(v) flags.StopWaveNumber = v end })
Tabs.Co:Slider({ Title = "Start Delay", Value = { Min = 0.5, Max = 30, Default = 2 }, Callback = function(v) flags.WaveStartDelay = v end })
local WaveStatus = Tabs.Co:Label({ Title = "Idle" })

Tabs.Co:Toggle({ Title = "Auto Collect Gold", Default = false, Callback = function(v) flags.AutoCollectGold = v end })
Tabs.Co:Slider({ Title = "Search Range", Value = { Min = 25, Max = 1000, Default = 250 }, Callback = function(v) flags.GoldRange = v end })

Tabs.Co:Toggle({ Title = "Auto Buy Affordable Skills", Default = false, Callback = function(v) flags.AutoBuySkills = v end })
Tabs.Co:Slider({ Title = "Buy Delay", Value = { Min = 0.1, Max = 5, Default = 0.5 }, Callback = function(v) flags.SkillDelay = v end })

Tabs.B:Toggle({ Title = "Auto Place", Default = false, Callback = function(v) flags.AutoPlace = v end })
Tabs.B:Toggle({ Title = "Auto Place Random", Default = false, Callback = function(v) flags.AutoPlaceRandom = v end })
Tabs.B:Dropdown({ Title = "Buildings", Values = {}, Default = 1, Multi = true, Callback = function(v) flags.PlaceBuildings = v end })
Tabs.B:Dropdown({ Title = "Category", Values = { "Any", "Block", "Turret" }, Default = 1, Multi = false, Callback = function(v) flags.PlaceCategory = v end })
Tabs.B:Dropdown({ Title = "Minimum Rarity", Values = RARITIES, Default = 1, Multi = false, Callback = function(v) flags.PlaceMinRarity = v end })
Tabs.B:Dropdown({ Title = "Rotation", Values = { "0", "90", "180", "270" }, Default = 1, Multi = false, Callback = function(v) flags.PlaceRotation = v end })

Tabs.B:Slider({ Title = "Keep In Inventory", Value = { Min = 0, Max = 50, Default = 0 }, Callback = function(v) flags.PlaceKeep = v end })
Tabs.B:Slider({ Title = "Max Per Building", Value = { Min = 1, Max = 200, Default = 40 }, Callback = function(v) flags.PlaceMax = v end })
Tabs.B:Toggle({ Title = "Respect Placement Limit", Default = false, Callback = function(v) flags.RespectLimit = v end })
Tabs.B:Toggle({ Title = "Pause When Nothing Fits", Default = false, Callback = function(v) flags.StopOnFull = v end })
Tabs.B:Slider({ Title = "Place Delay", Value = { Min = 0.05, Max = 3, Default = 0.2 }, Callback = function(v) flags.PlaceDelay = v end })

Tabs.B:Toggle({ Title = "Auto Upgrade", Default = false, Callback = function(v) flags.AutoUpgrade = v end })
Tabs.B:Toggle({ Title = "Upgrade Everything Unlocked", Default = false, Callback = function(v) flags.UpgradeAll = v end })
Tabs.B:Dropdown({ Title = "Buildings", Values = {}, Default = 1, Multi = true, Callback = function(v) flags.UpgradeBuildings = v end })
Tabs.B:Slider({ Title = "Max Level", Value = { Min = 2, Max = 64, Default = 64 }, Callback = function(v) flags.UpgradeMaxLevel = v end })
Tabs.B:Slider({ Title = "Keep Money", Value = { Min = 0, Max = 1000000, Default = 0 }, Callback = function(v) flags.UpgradeKeepMoney = v end })
Tabs.B:Slider({ Title = "Upgrade Delay", Value = { Min = 0.05, Max = 3, Default = 0.2 }, Callback = function(v) flags.UpgradeDelay = v end })
local UpgradeStatus = Tabs.B:Label({ Title = "Idle" })

Tabs.Cr:Toggle({ Title = "Auto Craft", Default = false, Callback = function(v) flags.AutoCraft = v end })
Tabs.Cr:Dropdown({ Title = "Recipes", Values = {}, Default = 1, Multi = true, Callback = function(v) flags.CraftRecipes = v end })

Tabs.Cr:Slider({ Title = "Keep In Inventory", Value = { Min = 0, Max = 50, Default = 0 }, Callback = function(v) flags.CraftKeep = v end })
Tabs.Cr:Dropdown({ Title = "Never Consume Above", Values = RARITIES, Default = 1, Multi = false, Callback = function(v) flags.CraftMaxRarity = v end })
Tabs.Cr:Slider({ Title = "Craft Delay", Value = { Min = 0.2, Max = 10, Default = 1 }, Callback = function(v) flags.CraftDelay = v end })
local CraftStatus = Tabs.Cr:Label({ Title = "Idle" })

Tabs.St:Dropdown({ Title = "Player", Values = {}, Default = 1, Multi = false, Callback = function(v) flags.StealTarget = v end })

Tabs.St:Toggle({ Title = "Clear My Plot First", Default = false, Callback = function(v) flags.StealClearFirst = v end })
Tabs.St:Toggle({ Title = "Use Normal If Missing Mutated/Shiny", Default = false, Callback = function(v) flags.StealSubstituteNormal = v end })
Tabs.St:Slider({ Title = "Place Delay", Value = { Min = 0.05, Max = 3, Default = 0.2 }, Callback = function(v) flags.StealDelay = v end })
local StealStatus = Tabs.St:Label({ Title = "Idle" })

local rollCount = 0
local cycleIndex = 0

local function dataGet(name, default)
    local ok, value = pcall(DataService.client.get, DataService.client, name)
    return ok and value ~= nil and value or default
end

local function dataAll()
    local ok, value = pcall(DataService.client.getAll, DataService.client)
    return ok and value or {}
end

local function getPlot(player)
    local ok, plot = pcall(GameModule.GetPlayerPlot, player)
    return ok and plot or nil
end

local function getOwnedBuildings()
    local ok, owned = pcall(BuildingsUtility.GetOwnedBuildings, LocalPlayer)
    if not ok then
        ok, owned = pcall(BuildingsUtility.GetOwnedBuildings)
    end
    return ok and owned or {}
end

local function listOwnedBuildingNames()
    local names, seen = {}, {}
    for key, value in pairs(getOwnedBuildings()) do
        local name = type(key) == "string" and key
            or type(value) == "string" and value
            or type(value) == "table" and (value.Identifier or value.Name)
        if name and not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

local function refreshBuildings()
    local names = listOwnedBuildingNames()
    -- SetValues not directly supported in flags: PlaceBuildings(names)
    WindUI:Notify(string.format("Found %d owned buildings", #names))
end

local function refreshUpgrades()
    local values, seen = {}, {}
    for key, value in pairs(dataAll().UnlockedBuildings or {}) do
        local name = type(key) == "string" and key or type(value) == "string" and value
        if name and not seen[name] then
            seen[name] = true
            table.insert(values, name)
        end
    end
    table.sort(values)
    -- SetValues not directly supported in flags: UpgradeBuildings(values)
    WindUI:Notify(string.format("Found %d upgradable buildings", #values))
end

local function refreshRecipes()
    local ok, recipes = pcall(RecipesUtility.GetUnlockedRecipes, LocalPlayer)
    if not ok then
        ok, recipes = pcall(RecipesUtility.GetUnlockedRecipes)
    end
    recipes = ok and recipes or {}
    local values = {}
    for key, value in pairs(recipes) do
        table.insert(values, type(key) == "string" and key or value)
    end
    table.sort(values)
    -- SetValues not directly supported in flags: CraftRecipes(values)
    WindUI:Notify(string.format("Found %d unlocked recipes", #values))
end

local function refreshPlayers()
    local values = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getPlot(player) then
            table.insert(values, player.Name)
        end
    end
    table.sort(values)
    -- SetValues not directly supported in flags: StealTarget(values)
    WindUI:Notify(string.format("Found %d bases", #values))
end

Tabs.B:Button({ Title = "Refresh Buildings", Callback = refreshBuildings })
Tabs.B:Button({ Title = "Refresh Upgradable", Callback = refreshUpgrades })
Tabs.Cr:Button({ Title = "Refresh Recipes", Callback = refreshRecipes })
Tabs.St:Button({ Title = "Refresh Players", Callback = refreshPlayers })

Tabs.B:Button({
    Text = "Clear My Plot",
    Func = function()
        fire(Remotes.ClearPlot, true)
        WindUI:Notify("Cleared plot")
    end,
})

local function selected(option, name)
    local value = option.Value
    return type(value) == "table" and value[name] == true
end

local rarityIndex = {}
for index, rarity in ipairs(RARITIES) do
    rarityIndex[rarity] = index
end

local function buildingAllowed(identifier)
    local ok, config = pcall(BuildingsUtility.GetConfig, identifier)
    if not ok or not config then
        return false
    end
    local category = config.Category or config.Type or "Any"
    local rarity = config.Rarity or "Basic"
    return (flags.PlaceCategory.Value == "Any" or category == flags.PlaceCategory.Value)
        and (rarityIndex[rarity] or 1) >= (rarityIndex[flags.PlaceMinRarity.Value] or 1)
end

local function findPlacement(plot, sequence)
    local origin = SharedPlacement.GetOrigin(plot)
    local grid = SharedPlacement.CONFIG.GridSize or 4
    local maxHeight = SharedPlacement.CONFIG.MaxStackHeight or 20
    local radius = math.max(1, math.ceil(math.sqrt(sequence)))
    for y = 0, maxHeight do
        for x = -radius, radius do
            for z = -radius, radius do
                local position = origin * CFrame.new(x * grid, y * grid, z * grid)
                local ok, empty = pcall(SharedPlacement.IsPlacementEmpty, plot, position)
                if not ok or empty then
                    return position
                end
            end
        end
    end
    return nil
end

local function placeBuilding(identifier, transform)
    local rotation = math.rad(tonumber(flags.PlaceRotation.Value) or 0)
    local finalTransform = transform * CFrame.Angles(0, rotation, 0)
    return invoke(Remotes.PlaceBuilding, identifier, finalTransform)
end

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoRoll then
            local power = SkillsUtility.GetPowerForSkillSubtype(LocalPlayer, "DoubleRoll")
            local chance = RandModule.RollChance(power)
            local vipMultiplier = LocalPlayer:GetAttribute("IsVip") and 3 or 1
            local result = invoke(Remotes.Roll, 8, vipMultiplier, power)
            rollCount += 1
            RollsLabel:SetTitle("Rolls this session: " .. rollCount)
            if result ~= nil then
                LastRollLabel:SetTitle("Last: " .. tostring(result))
                if not flags.InstantRoll and ClientRollModule.PlayRoll then
                    pcall(ClientRollModule.PlayRoll, result, chance)
                end
            end
        end
        task.wait(flags.RollDelay.Value)
    end
end)

local function enemyRoot(enemy)
    return enemy and (enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart"))
end

local function chooseEnemy(enemies, root)
    local valid = {}
    for _, enemy in ipairs(enemies) do
        if enemyRoot(enemy) then
            table.insert(valid, enemy)
        end
    end
    if #valid == 0 then
        return nil
    end

    if flags.AuraMode.Value == "Cycle All" then
        cycleIndex = cycleIndex % #valid + 1
        return valid[cycleIndex]
    end

    local best, bestScore
    for _, enemy in ipairs(valid) do
        local targetRoot = enemyRoot(enemy)
        local score
        if flags.AuraMode.Value == "Densest Cluster" then
            score = 0
            for _, other in ipairs(valid) do
                if (enemyRoot(other).Position - targetRoot.Position).Magnitude <= flags.ClusterRadius.Value then
                    score += 1
                end
            end
            score = -score
        else
            score = (targetRoot.Position - root.Position).Magnitude
        end
        if not bestScore or score < bestScore then
            best, bestScore = enemy, score
        end
    end
    return best
end

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.KillAura and (not flags.OnlyDuringWave or ClientBuildModule.WaveActive) then
            local plot = getPlot(LocalPlayer)
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local enemies = plot and plot:FindFirstChild("Enemies")
            local target = root and enemies and chooseEnemy(enemies:GetChildren(), root)
            local targetRoot = enemyRoot(target)

            if targetRoot then
                if flags.ApproachEnemy then
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, flags.AuraHover.Value, 0)
                end
                local identifier = target:GetAttribute("Identifier") or target.Name
                fire(Remotes.AttackWeapon, identifier, flags.IgnoreCooldown)
            elseif character then
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
        task.wait(flags.AttackDelay.Value)
    end
end)

local function currentWave()
    local ok, text = pcall(function()
        return PlayerGui.HUD.Wave.Layout.WaveCounter.Counter.Text
    end)
    return ok and tonumber(string.match(text, "Wave (%d+)")) or 0
end

task.spawn(function()
    local requestedStart = false
    while not shared.IndraHub_Builabase_Unloaded do
        local wave = currentWave()
        local active = ClientBuildModule.WaveActive == true

        if flags.AutoStartWave and not active and not requestedStart then
            requestedStart = true
            WaveStatus:SetTitle("Starting wave")
            task.wait(flags.WaveStartDelay.Value)
            fire(Remotes.StartWave)
        elseif active then
            requestedStart = false
            WaveStatus:SetTitle(string.format("Wave %d running", wave))
            if flags.AutoStopAtWave and wave >= flags.StopWaveNumber.Value then
                fire(Remotes.StopWave)
                WaveStatus:SetTitle(string.format("Reached wave %d, stopped", wave))
            end
        else
            WaveStatus:SetTitle("Idle")
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoCollectGold then
            local temp = workspace:FindFirstChild("Temp")
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if temp and root then
                for _, object in ipairs(temp:GetDescendants()) do
                    if object:IsA("BasePart")
                        and (object.Name == "Gold" or object.Name == "Coin" or object.Name == "CoinBag")
                        and (object.Position - root.Position).Magnitude <= flags.GoldRange.Value then
                        firetouchinterest(root, object, 0)
                        firetouchinterest(root, object, 1)
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

local function findAffordableSkills()
    local money = dataGet("Money", 0)
    local rolls = dataGet("Rolls", 0)
    local owned = SkillsUtility.GetAllOwned(LocalPlayer) or {}
    local queue, seen, affordable = { "TreeStart" }, {}, {}

    while #queue > 0 do
        local name = table.remove(queue, 1)
        if not seen[name] then
            seen[name] = true
            local config = SkillsUtility.GetConfig(name)
            if config then
                local connections = type(config.Connections) == "function" and config.Connections() or config.Connections or {}
                for _, child in pairs(connections) do
                    table.insert(queue, child)
                end
                if not owned[name]
                    and money >= (config.MoneyPrice or 0)
                    and rolls >= (config.RollsPrice or 0) then
                    table.insert(affordable, name)
                end
            end
        end
    end
    return affordable
end

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoBuySkills then
            local affordable = findAffordableSkills()
            if affordable[1] then
                invoke(Remotes.BuySkill, affordable[1])
            end
        end
        task.wait(flags.SkillDelay.Value)
    end
end)

task.spawn(function()
    local placed = 0
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoPlace then
            local plot = getPlot(LocalPlayer)
            local candidates = {}
            for _, identifier in ipairs(listOwnedBuildingNames()) do
                if selected(flags.PlaceBuildings, identifier) and buildingAllowed(identifier) then
                    table.insert(candidates, identifier)
                end
            end

            if #candidates > 0 and plot then
                local identifier = flags.AutoPlaceRandom
                    and candidates[math.random(1, #candidates)] or candidates[1]
                local transform = findPlacement(plot, placed + 1)
                if transform then
                    placeBuilding(identifier, transform)
                    placed += 1
                elseif flags.StopOnFull then
                    task.wait(1)
                end
            end
        end
        task.wait(flags.PlaceDelay.Value)
    end
end)

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoUpgrade then
            local unlocked = dataAll().UnlockedBuildings or {}
            local money = dataGet("Money", 0)
            local target
            for identifier, value in pairs(unlocked) do
                identifier = type(identifier) == "string" and identifier or value
                if type(identifier) == "string"
                    and (flags.UpgradeAll or selected(flags.UpgradeBuildings, identifier)) then
                    local config = BuildingsUtility.GetConfig(identifier)
                    local level = BuildingsUtility.GetLevel and BuildingsUtility.GetLevel(identifier) or 1
                    local maxLevel = BuildingsUtility.GetMaxLevel and BuildingsUtility.GetMaxLevel(identifier) or 64
                    local price = config and (config.UpgradePrice or config.MoneyPrice or 0) or 0
                    if level < math.min(maxLevel, flags.UpgradeMaxLevel.Value)
                        and money - price >= flags.UpgradeKeepMoney.Value then
                        target = identifier
                        break
                    end
                end
            end

            if target then
                UpgradeStatus:SetTitle(string.format("Upgrading %s", target))
                invoke(Remotes.UpgradeBuilding, target)
            else
                UpgradeStatus:SetTitle("Nothing affordable")
            end
        else
            UpgradeStatus:SetTitle("Idle")
        end
        task.wait(flags.UpgradeDelay.Value)
    end
end)

task.spawn(function()
    while not shared.IndraHub_Builabase_Unloaded do
        if flags.AutoCraft then
            local crafted = false
            for recipe, enabled in pairs(flags.CraftRecipes.Value or {}) do
                if enabled then
                    CraftStatus:SetTitle("Crafting " .. tostring(recipe))
                    invoke(Remotes.Craft, recipe, flags.CraftKeep.Value, flags.CraftMaxRarity.Value)
                    crafted = true
                    break
                end
            end
            if not crafted then
                CraftStatus:SetTitle("Idle")
            end
        end
        task.wait(flags.CraftDelay.Value)
    end
end)

local function targetPlacementData()
    local targetName = flags.StealTarget.Value
    local player = targetName and Players:FindFirstChild(targetName)
    local sourcePlot = player and getPlot(player)
    local destinationPlot = getPlot(LocalPlayer)
    if not sourcePlot or not destinationPlot then
        return nil, "player has no plot"
    end

    local placement = sourcePlot:FindFirstChild("Placement")
    if not placement then
        return nil, "no target selected"
    end

    local sourceOrigin = SharedPlacement.GetOrigin(sourcePlot)
    local destinationOrigin = SharedPlacement.GetOrigin(destinationPlot)
    local owned = {}
    for _, name in ipairs(listOwnedBuildingNames()) do
        owned[name] = (owned[name] or 0) + 1
    end

    local result, missing = {}, {}
    for _, model in ipairs(placement:GetChildren()) do
        local identifier = model:GetAttribute("Identifier") or model.Name
        local chosen = identifier
        if not owned[chosen] and flags.StealSubstituteNormal then
            chosen = identifier:gsub("^UnlockWeapon%d+$", "Normal")
        end
        if owned[chosen] and owned[chosen] > 0 then
            owned[chosen] -= 1
            local pivot = model:IsA("Model") and model:GetPivot() or model.CFrame
            local relative = sourceOrigin:ToObjectSpace(pivot)
            table.insert(result, { identifier = chosen, transform = destinationOrigin * relative })
        else
            missing[identifier] = (missing[identifier] or 0) + 1
        end
    end
    return result, missing
end

Tabs.St:Button({
    Title = "Check Materials",
    Callback = function()
        local buildings, missing = targetPlacementData()
        if not buildings then
            StealStatus:SetTitle(tostring(missing))
            return
        end
        local missingTypes = 0
        for _ in pairs(missing) do
            missingTypes += 1
        end
        StealStatus:SetTitle(string.format(
            '<font color="rgb(90,220,120)">Ready: %d buildings, %d types</font>\n',
            #buildings,
            missingTypes
        ))
    end,
})

Tabs.St:Button({
    Title = "Steal Base",
    Callback = function()
        task.spawn(function()
            local buildings, reason = targetPlacementData()
            if not buildings then
                StealStatus:SetTitle(tostring(reason))
                return
            end
            if flags.StealClearFirst then
                fire(Remotes.ClearPlot, true)
                task.wait(1)
            end
            for index, entry in ipairs(buildings) do
                if shared.IndraHub_Builabase_Unloaded then
                    return
                end
                StealStatus:SetTitle(string.format("Placing %d/%d", index, #buildings))
                invoke(Remotes.PlaceBuilding, entry.identifier, entry.transform)
                task.wait(flags.StealDelay.Value)
            end
            StealStatus:SetTitle(string.format("Copied %d buildings", #buildings))
        end)
    end,
})

-- Cleaned up old UI artifacts
Tabs.Se:Toggle({
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

Tabs.Se:Button({
    Title = "Unload Script",
    Callback = function()
        shared.IndraHub_Builabase_Unloaded = true
        if flags.HB then flags.HB:Disconnect() end
        if Window then Window:Destroy() end
        fire(Remotes.SetAutoWave, false)
    end
})

WindUI:Notify({ Title = "IndraHub", Content = "Loaded Build a Base RNG", Duration = 5 })
