local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local env = getgenv and getgenv() or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then return value end
    return env[key]
end

setGlobal("IndraHubHazeRunning", true)
setGlobal("IndraHubHazeSession", sessionId)
setGlobal("IndraHubHazeLastHeartbeat", os.clock())
setGlobal("IndraHubHazeError", nil)

local function running()
    return getGlobal("IndraHubHazeRunning") and getGlobal("IndraHubHazeSession") == sessionId
end

task.spawn(function()
    while running() do
        setGlobal("IndraHubHazeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local Config = {
    AutoQuest = false,
    AutoFarm = false,
    AutoSkills = false,
    AutoDash = false,
    AutoStats = false,
    AutoUnlockSpawns = false,
    QuestLevel = "Level 1",
    QuestGiver = "1",
    SelectedMob = "",
    NpcZone = "Starter Island",
    NpcName = "Thief",
    StatName = "Combat",
    StatAmount = 1,
    StatDelay = 0.12,
    TweenSpeed = 85,
    FarmDistance = 2.5,
    PunchBurst = 4,
    ResetAfterTravel = true,
    PunchDelay = 0.18,
    NpcDelay = 0.75,
    DashDelay = 0.7,
    SkillDelay = 1.5,
    SpawnDelay = 0.35,
}

local Islands = {
    "Starter Island", "Clown Island", "Shark Park", "Desert Ruins", "Sea Restaurant",
    "Logue City", "Tall Woods", "Marine Base Town", "Three Islands", "Marine HQ",
    "Skypiean islands", "Sky Islands", "Revolutionary Base", "Impel Jail",
    "Half Hot Half Cold", "Fishman Island", "Skull Island", "Bubble Island", "Thriller Boat",
}

local StatValues = {"Combat 30 (+32)", "Defense 0", "Sword 0", "Fruit 0"}
local StatNames = {
    ["Combat 30 (+32)"] = "Combat",
    ["Defense 0"] = "Defense",
    ["Sword 0"] = "Sword",
    ["Fruit 0"] = "Fruit",
}

local MobEntries = {}
local MobValues = {"Thief"}
local QuestEntries = {}
local QuestValues = {"Level 1 / Thief"}
local MobDropdown
local QuestDropdown
local getRoot
local setSpawn
local refreshZone

local function cleanMobName(npc)
    local nickname = npc:GetAttribute("Nickname")
    if nickname and tostring(nickname) ~= "" then
        return tostring(nickname)
    end
    return (npc.Name:gsub("%d+$", "")):gsub("%s+$", "")
end

local function child(parent, ...)
    local current = parent
    for _, name in ipairs({...}) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function waitChild(parent, ...)
    local current = parent
    for _, name in ipairs({...}) do
        if not current then return nil end
        current = current:WaitForChild(name, 5)
    end
    return current
end

local ClientEvents = waitChild(ReplicatedStorage, "Replication", "ClientEvents")
local RemoteFunctions = child(ReplicatedStorage, "RemoteFunctions")

local function fire(remote, ...)
    if remote and remote:IsA("RemoteEvent") then
        return pcall(function(...) remote:FireServer(...) end, ...)
    end
end

local function invoke(remote, ...)
    if remote and remote:IsA("RemoteFunction") then
        return pcall(function(...) return remote:InvokeServer(...) end, ...)
    end
end

local function getPlayerFolder()
    return child(Workspace, "Players", LocalPlayer.Name)
end

local function getCombat()
    return child(getPlayerFolder(), "Combat")
end

local function findRemote(root, name, className)
    if not root then return nil end
    local direct = root:FindFirstChild(name, true)
    if direct and (not className or direct:IsA(className)) then
        return direct
    end
    for _, inst in ipairs(root:GetDescendants()) do
        if inst.Name == name and (not className or inst:IsA(className)) then
            return inst
        end
    end
end

local function getPunchRemote()
    return child(getCombat(), "Punch")
        or findRemote(getPlayerFolder(), "Punch", "RemoteEvent")
        or findRemote(LocalPlayer.Character, "Punch", "RemoteEvent")
        or findRemote(LocalPlayer:FindFirstChild("PlayerGui"), "Punch", "RemoteEvent")
        or findRemote(Workspace, "Punch", "RemoteEvent")
end

local function getDashRemote()
    return child(LocalPlayer, "PlayerGui", "FormerStarterCharacterScripts", "NormalSkills", "Dashing", "Events", "Dash")
end

local function getNpc()
    local selected = MobEntries[Config.SelectedMob]
    if selected and selected.Instance and selected.Instance.Parent then
        return selected.Instance
    end

    local zone = child(Workspace, "NPC Zones", Config.NpcZone)
    if not zone then return nil end

    local npcs = zone:FindFirstChild("NPCS") or zone:FindFirstChild("NPCs") or zone:FindFirstChild("Npcs") or zone

    local exact = npcs:FindFirstChild(Config.NpcName)
    if exact then return exact end

    local wanted = string.lower(Config.NpcName)
    for _, npc in ipairs(npcs:GetDescendants()) do
        if string.find(string.lower(npc.Name), wanted, 1, true) then
            return npc
        end
    end
end

local function isFightableNpc(npc)
    if not npc or not npc:IsA("Model") then return false end
    local humanoid = npc:FindFirstChildOfClass("Humanoid") or npc:FindFirstChild("Humanoid", true)
    if humanoid and humanoid.Health <= 0 then return false end
    return getRoot(npc) ~= nil or humanoid ~= nil
end

local function scanMobs()
    table.clear(MobEntries)
    table.clear(MobValues)

    local zones = Workspace:FindFirstChild("NPC Zones") or Workspace:WaitForChild("NPC Zones", 10)
    if not zones then
        MobValues[1] = Config.NpcName
        return MobValues
    end

    local seen = {}
    for _, zone in ipairs(zones:GetChildren()) do
        local containers = {}
        local direct = zone:FindFirstChild("NPCS") or zone:FindFirstChild("NPCs") or zone:FindFirstChild("Npcs")
        if direct then table.insert(containers, direct) end
        table.insert(containers, zone)

        for _, container in ipairs(containers) do
            for _, npc in ipairs(container:GetDescendants()) do
                if isFightableNpc(npc) then
                    local cleanName = cleanMobName(npc)
                    local label = zone.Name .. " / " .. cleanName
                    local key = string.lower(label)
                    if not seen[key] then
                        seen[key] = true
                        MobEntries[label] = {Zone = zone.Name, Name = cleanName, InstanceName = npc.Name, Instance = npc}
                        table.insert(MobValues, label)
                    end
                end
            end
        end
    end

    table.sort(MobValues)
    if #MobValues == 0 then
        MobValues[1] = Config.NpcName
    end
    return MobValues
end

local function refreshMobDropdown()
    scanMobs()
    if MobDropdown then
        pcall(function() MobDropdown:Refresh(MobValues) end)
        pcall(function() MobDropdown:SetValues(MobValues) end)
        pcall(function() MobDropdown:Set(MobValues[1]) end)
        pcall(function() MobDropdown:SetValue(MobValues[1]) end)
    end
    return MobValues
end

local function selectMob(label)
    local entry = MobEntries[label]
    if entry then
        Config.SelectedMob = label
        Config.NpcZone = entry.Zone
        Config.NpcName = entry.InstanceName or entry.Name
    else
        Config.NpcName = tostring(label or Config.NpcName)
    end
end

local function scanQuests()
    table.clear(QuestEntries)
    table.clear(QuestValues)

    local questGivers = child(Workspace, "Npc_Workspace", "QuestGivers")
    if not questGivers then
        QuestValues[1] = Config.QuestLevel .. " / " .. Config.NpcName
        return QuestValues
    end

    for _, giver in ipairs(questGivers:GetChildren()) do
        local quests = child(giver, "Configuration", "Quests")
        if quests then
            local display = child(giver, "DisplayName")
            local giverName = display and tostring(display.Value):match("^[^|]+") or giver.Name
            for _, levelFolder in ipairs(quests:GetChildren()) do
                if levelFolder:IsA("Folder") and string.match(levelFolder.Name, "^Level%s+%d+") then
                    local levelNumber = tonumber(string.match(levelFolder.Name, "%d+")) or 0
                    for _, quest in ipairs(levelFolder:GetChildren()) do
                        if quest:IsA("Folder") and quest.Name ~= "Rewards" then
                            local rewards = quest:FindFirstChild("Rewards")
                            local exp = rewards and rewards:FindFirstChild("Exp")
                            local beli = rewards and rewards:FindFirstChild("Beli")
                            local label = string.format("Lv %d / %s", levelNumber, quest.Name)
                            QuestEntries[label] = {
                                Giver = giver,
                                GiverId = giver.Name,
                                GiverName = giverName,
                                Level = levelFolder.Name,
                                LevelNumber = levelNumber,
                                Target = quest.Name,
                                Exp = exp and exp.Value or 0,
                                Beli = beli and beli.Value or 0,
                            }
                            table.insert(QuestValues, label)
                        end
                    end
                end
            end
        end
    end

    table.sort(QuestValues, function(a, b)
        local qa = QuestEntries[a]
        local qb = QuestEntries[b]
        if qa and qb and qa.LevelNumber ~= qb.LevelNumber then
            return qa.LevelNumber < qb.LevelNumber
        end
        return a < b
    end)

    if #QuestValues == 0 then
        QuestValues[1] = Config.QuestLevel .. " / " .. Config.NpcName
    end
    return QuestValues
end

local function selectQuest(label)
    local entry = QuestEntries[label]
    if not entry then return end
    Config.QuestGiver = entry.GiverId
    Config.QuestLevel = entry.Level
    Config.NpcName = entry.Target
end

local function refreshQuestDropdown()
    scanQuests()
    if QuestDropdown then
        pcall(function() QuestDropdown:Refresh(QuestValues) end)
        pcall(function() QuestDropdown:SetValues(QuestValues) end)
        pcall(function() QuestDropdown:Set(QuestValues[1]) end)
        pcall(function() QuestDropdown:SetValue(QuestValues[1]) end)
    end
    return QuestValues
end

function getRoot(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("HumanoidRootPart", true)
        or model:FindFirstChild("RootPart")
        or model:FindFirstChild("RootPart", true)
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Torso", true)
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("UpperTorso", true)
        or model.PrimaryPart
end

local function getModelCFrame(model)
    local root = getRoot(model)
    if root then return root.CFrame end
    local ok, pivot = pcall(function() return model:GetPivot() end)
    if ok then return pivot end
end

local function getCharacterRoot()
    return getRoot(LocalPlayer.Character)
end

local function tweenTo(cframe)
    local root = getCharacterRoot()
    if not root then return false end

    local distance = (root.Position - cframe.Position).Magnitude
    local duration = math.clamp(distance / Config.TweenSpeed, 0.08, 5)
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = cframe})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function getZoneCFrame(island)
    local zone = child(Workspace, "NPC Zones", island)
    if not zone then return nil end

    for _, inst in ipairs(zone:GetDescendants()) do
        if inst:IsA("BasePart") then
            return inst.CFrame + Vector3.new(0, 4, 0)
        end
    end

    local ok, pivot = pcall(function() return zone:GetPivot() end)
    if ok then return pivot + Vector3.new(0, 4, 0) end
end

local function getQuestCFrame(island)
    local questGivers = child(Workspace, "Npc_Workspace", "QuestGivers")
    if not questGivers then return nil end
    for _, giver in ipairs(questGivers:GetChildren()) do
        local questPart = giver:FindFirstChild("Quest") or giver:FindFirstChild("HumanoidRootPart") or giver:FindFirstChild("Head")
        if questPart and questPart:IsA("BasePart") then
            local quests = child(giver, "Configuration", "Quests")
            if quests then
                for _, levelFolder in ipairs(quests:GetChildren()) do
                    for _, quest in ipairs(levelFolder:GetChildren()) do
                        local target = quest.Name
                        local selected = string.lower(island or "")
                        if selected ~= "" and (string.find(string.lower(target), selected, 1, true) or string.find(string.lower(giver.Name), selected, 1, true)) then
                            return questPart.CFrame + Vector3.new(0, 4, 0)
                        end
                    end
                end
            end
        end
    end
end

local function travelToIsland(island)
    island = island or Config.NpcZone
    setSpawn(island)
    refreshZone(island)
    if Config.ResetAfterTravel then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    else
        local cf = getZoneCFrame(island) or getQuestCFrame(island)
        if cf then tweenTo(cf) end
    end
    return true
end

local function tweenToNpc(npc)
    local cf = getModelCFrame(npc)
    if not cf then return false end
    local pos = cf.Position - (cf.LookVector * Config.FarmDistance)
    return tweenTo(CFrame.lookAt(pos, cf.Position))
end

local function getQuestGiver()
    for _, entry in pairs(QuestEntries) do
        if entry.GiverId == Config.QuestGiver and entry.Level == Config.QuestLevel then
            return entry.Giver
        end
    end
    return child(Workspace, "Npc_Workspace", "QuestGivers", Config.QuestGiver)
end

function setSpawn(island)
    fire(child(ClientEvents, "SetSpawnPoint"), island)
end

function refreshZone(island)
    invoke(child(ClientEvents, "GetNpcZoneData"), "")
    fire(child(getPlayerFolder(), "Location", "Change"), 1)
    invoke(child(ReplicatedStorage, "UpdatePlatform"), "PC")
    if island and island ~= "" then
        invoke(child(ClientEvents, "GetNpcZoneData"), island)
    end
end

local function acceptQuest()
    invoke(child(LocalPlayer, "PlayerGui", "QuestGui", "QuestFunction"), getQuestGiver(), Config.QuestLevel)
end

local function activateNpc(npc)
    npc = npc or getNpc()
    if npc then
        fire(child(ClientEvents, "ActivateNPC"), npc)
        return true
    end
    return false
end

local function clickPunch()
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end

local function faceNpc(npc)
    local playerRoot = getCharacterRoot()
    local cf = getModelCFrame(npc)
    if playerRoot and cf then
        playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, cf.Position)
    end
end

local function punch()
    local remote = getPunchRemote()
    if not remote then
        warn("[IndraHub Haze] Punch remote not found")
        return false
    end
    fire(child(getPlayerFolder(), "CharacterRotator", "Upd"), true)
    fire(remote)
    clickPunch()
    return true
end

local function punchBurst(npc)
    faceNpc(npc)
    for _ = 1, math.max(1, Config.PunchBurst) do
        punch()
        task.wait(Config.PunchDelay)
    end
end

local function useSkills()
    local combat = getCombat()
    local events = child(combat, "Events")
    local root = child(LocalPlayer.Character, "HumanoidRootPart")
    local target = root and root.CFrame or CFrame.new()

    fire(child(events, "DetriotSmash"), 1, target)
    fire(child(getPlayerFolder(), "CharacterRotator", "Upd"), true)
    fire(child(ClientEvents, "SkillUsed"), "Heavy Punch")
    task.wait(0.12)
    fire(child(events, "GroundSmash"))
    task.wait(0.12)
    fire(child(events, "Gattling"), 0.125, true)
end

local function dash()
    invoke(getDashRemote(), "NoShiftLock")
end

local function claimData()
    fire(child(ClientEvents, "AllyRemotes", "GetData"))
    invoke(child(RemoteFunctions, "RequestPlaytimeReward"), "Data")
end

local function addStats()
    fire(child(ClientEvents, "Stats_Event"), Config.StatName, Config.StatAmount)
end

local function loop(name, delayFn, callback)
    task.spawn(function()
        while task.wait(delayFn()) do
            if Config[name] then
                pcall(callback)
            end
        end
    end)
end

loop("AutoQuest", function() return 4 end, function()
    acceptQuest()
end)

loop("AutoFarm", function() return Config.PunchDelay end, function()
    local npc = getNpc()
    if npc then
        tweenToNpc(npc)
    end
    activateNpc(npc)
    punchBurst(npc)
end)

loop("AutoSkills", function() return Config.SkillDelay end, function()
    useSkills()
end)

loop("AutoDash", function() return Config.DashDelay end, function()
    dash()
end)

loop("AutoStats", function() return Config.StatDelay end, function()
    addStats()
end)

task.spawn(function()
    while task.wait(10) do
        claimData()
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.AutoUnlockSpawns then
            for _, island in ipairs(Islands) do
                if not Config.AutoUnlockSpawns then break end
                setSpawn(island)
                refreshZone(island)
                task.wait(Config.SpawnDelay)
            end
            Config.AutoUnlockSpawns = false
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not okWind or type(WindUI) ~= "table" then
    warn("[IndraHub Haze] WindUI failed; use getgenv().IndraHubHaze.Config")
    setGlobal("IndraHubHazeError", "WINDUI FAIL")
    getgenv().IndraHubHaze = {Config = Config, Islands = Islands, ScanMobs = scanMobs, ScanQuests = scanQuests, MobEntries = MobEntries, MobValues = MobValues, QuestEntries = QuestEntries, QuestValues = QuestValues}
    return
end

scanMobs()
scanQuests()

local Window = WindUI:CreateWindow({
    Title = "IndraHub Haze",
    Icon = "swords",
    Author = "Remote log build",
    Size = UDim2.fromOffset(560, 420),
    Transparent = true,
    Theme = "Dark",
})

pcall(function() Window:SetToggleKey(Enum.KeyCode.RightControl) end)

local Farm = Window:Tab({Title = "Farm", Icon = "swords"})
local Travel = Window:Tab({Title = "Travel", Icon = "map"})
local Misc = Window:Tab({Title = "Misc", Icon = "settings"})

MobDropdown = Farm:Dropdown({Title = "Mob List", Values = MobValues, Value = MobValues[1], Callback = selectMob})
QuestDropdown = Farm:Dropdown({Title = "Quest List", Values = QuestValues, Value = QuestValues[1], Callback = selectQuest})
Farm:Input({Title = "Tween Speed", Value = tostring(Config.TweenSpeed), Callback = function(v) Config.TweenSpeed = tonumber(v) or Config.TweenSpeed end})
Farm:Input({Title = "Farm Distance", Value = tostring(Config.FarmDistance), Callback = function(v) Config.FarmDistance = tonumber(v) or Config.FarmDistance end})
Farm:Input({Title = "Punch Burst", Value = tostring(Config.PunchBurst), Callback = function(v) Config.PunchBurst = tonumber(v) or Config.PunchBurst end})
Farm:Toggle({Title = "Auto Quest", Value = false, Callback = function(v) Config.AutoQuest = v end})
Farm:Toggle({Title = "Auto Farm NPC", Value = false, Callback = function(v) Config.AutoFarm = v end})
Farm:Toggle({Title = "Auto Skills", Value = false, Callback = function(v) Config.AutoSkills = v end})
Farm:Toggle({Title = "Auto Dash", Value = false, Callback = function(v) Config.AutoDash = v end})

Farm:Button({Title = "Accept Quest Once", Callback = acceptQuest})
Farm:Button({Title = "Activate NPC Once", Callback = activateNpc})
Farm:Button({Title = "Punch Once", Callback = punch})
Farm:Button({Title = "Use Skills Once", Callback = useSkills})

Travel:Dropdown({Title = "Island", Values = Islands, Value = Config.NpcZone, Callback = function(v) Config.NpcZone = tostring(v) end})
Travel:Toggle({Title = "Reset After Travel", Value = Config.ResetAfterTravel, Callback = function(v) Config.ResetAfterTravel = v end})
Travel:Button({Title = "Set Spawn Selected", Callback = function() setSpawn(Config.NpcZone) end})
Travel:Button({Title = "Travel Selected", Callback = function() travelToIsland(Config.NpcZone) end})
Travel:Button({Title = "Refresh Zone Selected", Callback = function() refreshZone(Config.NpcZone) end})
Travel:Toggle({Title = "Auto Unlock All Spawns", Value = false, Callback = function(v) Config.AutoUnlockSpawns = v end})

Misc:Dropdown({Title = "Stat", Values = StatValues, Value = StatValues[1], Callback = function(v) Config.StatName = StatNames[tostring(v)] or tostring(v or Config.StatName) end})
Misc:Input({Title = "Stat Amount", Value = tostring(Config.StatAmount), Callback = function(v) Config.StatAmount = tonumber(v) or Config.StatAmount end})
Misc:Input({Title = "Stat Delay", Value = tostring(Config.StatDelay), Callback = function(v) Config.StatDelay = tonumber(v) or Config.StatDelay end})
Misc:Toggle({Title = "Auto Stats", Value = false, Callback = function(v) Config.AutoStats = v end})
Misc:Button({Title = "Claim/Refresh Data", Callback = claimData})
Misc:Button({Title = "Add Stats Once", Callback = addStats})

getgenv().IndraHubHaze = {
    Config = Config,
    Islands = Islands,
    MobEntries = MobEntries,
    MobValues = MobValues,
    QuestEntries = QuestEntries,
    QuestValues = QuestValues,
    ScanMobs = scanMobs,
    ScanQuests = scanQuests,
    SelectMob = selectMob,
    SelectQuest = selectQuest,
    SetSpawn = setSpawn,
    TravelToIsland = travelToIsland,
    RefreshZone = refreshZone,
    AcceptQuest = acceptQuest,
    ActivateNpc = activateNpc,
    TweenToNpc = function() return tweenToNpc(getNpc()) end,
    GetPunchRemote = getPunchRemote,
    Punch = punch,
    PunchBurst = function() return punchBurst(getNpc()) end,
    UseSkills = useSkills,
}

pcall(function()
    WindUI:Notify({Title = "IndraHub Haze", Content = "Loaded. RightControl toggles UI.", Icon = "swords", Duration = 4})
end)
