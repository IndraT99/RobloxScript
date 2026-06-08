local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local executorName = ""
pcall(function()
    if type(identifyexecutor) == "function" then
        executorName = tostring(identifyexecutor())
    end
end)
local isXeno = string.find(string.lower(executorName), "xeno", 1, true) ~= nil

local function dumpError(tag, err)
    local msg = "[IndraHub] " .. tostring(tag) .. ": " .. tostring(err)
    warn(msg)
end

local require = (function()
    local oldRequire = require
    local getidentity = getthreadidentity or getidentity or getthreadcontext or (syn and syn.get_thread_identity)
    local setidentity = setthreadidentity or setidentity or setthreadcontext or (syn and syn.set_thread_identity)
    local nativeRequire = nil
    pcall(function()
        nativeRequire = type(getrenv) == "function" and getrenv().require or nil
    end)

    local function findTableByKeys(keys)
        if isXeno or type(getgc) ~= "function" then return nil end
        local ok, objects = pcall(getgc, true)
        if not ok or type(objects) ~= "table" then return nil end
        for _, v in ipairs(objects) do
            if type(v) == "table" then
                local match = true
                for _, k in ipairs(keys) do
                    local ok, val = pcall(function() return rawget(v, k) end)
                    if not ok or val == nil then
                        match = false
                        break
                    end
                end
                if match then
                    return v
                end
            end
        end
        return nil
    end

    local function findModuleInGC(module)
        if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
            return nil
        end
        local name = module.Name
        if name == "Controller" then
            return findTableByKeys({"StopAutoSkill", "GetCombatSlotActionIds", "RequestDrawWeapon"})
        elseif name == "TEvent" then
            return findTableByKeys({"FireRemote"})
        elseif name == "SummonBoss" then
            return findTableByKeys({"OP_EVENT", "OP"})
        elseif name == "Config" then
            return findTableByKeys({"Enemy"})
        end
        return nil
    end

    local cleanRequire = nil
    local function getCleanRequire()
        if cleanRequire then return cleanRequire end
        if isXeno or type(getgc) ~= "function" or type(getfenv) ~= "function" then return nil end
        local ok, objects = pcall(getgc)
        if not ok or type(objects) ~= "table" then return nil end
        for _, f in ipairs(objects) do
            if type(f) == "function" then
                local success, env = pcall(getfenv, f)
                if success and type(env) == "table" and env.require and env.script then
                    local s = env.script
                    if typeof(s) == "Instance" and s:IsA("LocalScript") and s.Parent and not s:IsDescendantOf(game:GetService("CoreGui")) then
                        cleanRequire = env.require
                        return cleanRequire
                    end
                end
            end
        end
        return nil
    end

    return function(module)
        local errs = {}

        local gcSuccess, gcVal = pcall(findModuleInGC, module)
        if gcSuccess and gcVal then
            return gcVal
        end

        local cleanReq = getCleanRequire()
        if cleanReq then
            local ok, result = pcall(cleanReq, module)
            if ok then
                return result
            else
                table.insert(errs, "CleanRequire: " .. tostring(result))
            end
        end

        if not isXeno and type(setidentity) == "function" and type(getidentity) == "function" then
            local old = getidentity()
            local success = pcall(setidentity, 2)
            if success then
                if nativeRequire then
                    local ok, result = pcall(nativeRequire, module)
                    if ok then
                        pcall(setidentity, old)
                        return result
                    else
                        table.insert(errs, "NativeRequire(Identity 2): " .. tostring(result))
                    end
                end

                local ok, result = pcall(oldRequire, module)
                pcall(setidentity, old)
                if ok then
                    return result
                else
                    table.insert(errs, "OldRequire(Identity 2): " .. tostring(result))
                end
            else
                table.insert(errs, "SetIdentityFailed")
            end
        end

        if nativeRequire then
            local ok, result = pcall(nativeRequire, module)
            if ok then
                return result
            else
                table.insert(errs, "NativeRequire(Current Identity): " .. tostring(result))
            end
        end

        local ok, result = pcall(oldRequire, module)
        if ok then
            return result
        else
            table.insert(errs, "OldRequire(Current Identity): " .. tostring(result))
        end

        local canClone = typeof(module) == "Instance" and module:IsA("ModuleScript")
        if canClone then
            local cloneSuccess, clonedModule = pcall(function() return module:Clone() end)
            if cloneSuccess and clonedModule then
                if cleanReq then
                    local ok, result = pcall(cleanReq, clonedModule)
                    if ok then
                        return result
                    else
                        table.insert(errs, "ClonedCleanRequire: " .. tostring(result))
                    end
                end

                if not isXeno and type(setidentity) == "function" and type(getidentity) == "function" then
                    local old = getidentity()
                    local success = pcall(setidentity, 2)
                    if success then
                        if nativeRequire then
                            local ok, result = pcall(nativeRequire, clonedModule)
                            if ok then
                                pcall(setidentity, old)
                                return result
                            else
                                table.insert(errs, "ClonedNativeRequire(Identity 2): " .. tostring(result))
                            end
                        end

                        local ok, result = pcall(oldRequire, clonedModule)
                        pcall(setidentity, old)
                        if ok then
                            return result
                        else
                            table.insert(errs, "ClonedOldRequire(Identity 2): " .. tostring(result))
                        end
                    end
                end

                if nativeRequire then
                    local ok, result = pcall(nativeRequire, clonedModule)
                    if ok then
                        return result
                    else
                        table.insert(errs, "ClonedNativeRequire(Current Identity): " .. tostring(result))
                    end
                end

                local ok, result = pcall(oldRequire, clonedModule)
                if ok then
                    return result
                else
                    table.insert(errs, "ClonedOldRequire(Current Identity): " .. tostring(result))
                end
            else
                table.insert(errs, "CloneFailed: " .. tostring(clonedModule))
            end
        end

        local errMsg = "IndraHub require failed for module: " .. tostring(module and module:GetFullName() or module) .. "\n" .. table.concat(errs, "\n")
        dumpError("require hard fail", errMsg)
        error(errMsg, 2)
    end
end)()

local function getChildPath(root, path)
    local current = root
    for _, name in ipairs(path) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function loadWindUI()
    if type(loadstring) ~= "function" then
        error("IndraHub requires loadstring support", 2)
    end

    local ok, source = pcall(function()
        return game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    end)
    if not ok or type(source) ~= "string" or source == "" then
        error("Failed to download WindUI: " .. tostring(source), 2)
    end

    local chunk, compileErr = loadstring(source)
    if type(chunk) ~= "function" then
        error("Failed to compile WindUI: " .. tostring(compileErr), 2)
    end

    local runOk, ui = pcall(chunk)
    if not runOk or type(ui) ~= "table" then
        error("Failed to load WindUI: " .. tostring(ui), 2)
    end

    return ui
end

local okWindUI, WindUI = pcall(loadWindUI)
if not okWindUI then
    dumpError("WindUI load failed", WindUI)
    return
end

local okJunkie, Junkie = pcall(function()
    return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
end)
if okJunkie and type(Junkie) == "table" then
    Junkie.service = "broken blade"
    Junkie.identifier = "1116993"
    Junkie.provider = "BrokenBlade"
else
    dumpError("Junkie load failed", Junkie)
    return
end

WindUI.Services.junkiedevelopment = {
    Name = "Junkie Development",
    Icon = "shield-check",
    Args = { "ServiceId", "ApiKey", "Provider" },

    New = function()
        local function Verify(key)
            local result = Junkie.check_key(key)
            if result and result.valid then
                if result.message == "KEYLESS" then
                    getgenv().SCRIPT_KEY = "KEYLESS"
                    return true, "Keyless mode"
                elseif result.message == "KEY_VALID" then
                    getgenv().SCRIPT_KEY = key
                    return true, "Key valid"
                end
            end

            return false, "Invalid key"
        end

        local function Copy()
            local link = Junkie.get_key_link()
            if setclipboard then setclipboard(link) end
            return link
        end

        return { Verify = Verify, Copy = Copy }
    end
}

local player = Players.LocalPlayer
local function requireWithRetry(module, retries, delaySeconds)
    if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
        return nil
    end

    if isXeno then
        retries = math.min(retries or 1, 2)
        delaySeconds = math.min(delaySeconds or 0.1, 0.1)
    end

    local lastError = nil

    for _ = 1, retries do
        local ok, result = pcall(require, module)
        if ok then return result end

        lastError = result
        task.wait(delaySeconds)
    end

    dumpError("require failed " .. module:GetFullName(), lastError)
    return nil
end

local moduleRetries = isXeno and 2 or 20
local moduleDelay = isXeno and 0.1 or 0.5
local Player3CController = requireWithRetry(getChildPath(ReplicatedStorage, { "Client", "System", "Player3C", "Internal", "Controller" }), moduleRetries, moduleDelay) or {}
local TEvent = requireWithRetry(getChildPath(ReplicatedStorage, { "Shared", "Core", "TEvent" }), moduleRetries, moduleDelay) or {}
local Config = requireWithRetry(ReplicatedStorage:FindFirstChild("Config"), moduleRetries, moduleDelay) or {}
local SummonBoss = requireWithRetry(getChildPath(ReplicatedStorage, { "Shared", "Features", "SummonBoss" }), moduleRetries, moduleDelay) or { OP = { Summon = "Summon" }, OP_EVENT = "SummonBossOp" }
local Quest = requireWithRetry(getChildPath(ReplicatedStorage, { "Shared", "Features", "Quest" }), moduleRetries, moduleDelay) or { OP = { Accept = "Accept", Abandon = "Abandon" }, OP_EVENT = "QuestOp" }
local QuestClient = requireWithRetry(getChildPath(ReplicatedStorage, { "Shared", "Features", "Quest", "client" }), moduleRetries, moduleDelay) or {}

local enemyNames = {
    "[Lv.10] Sailor",
    "[Lv.150] NameLess Hero",
    "[Lv.750] Moraros",
    "[Lv.1000] Flame Minion",
    "[Lv.2500] Magador",
    "[Lv.4000] Frost Minion",
    "[Lv.6000] Velik",
    "[Lv.13000] Frost Soldier",
    "[Lv.13000] Thunder Soldier",
    "[Lv.3000] Black Swordsman",
    "[Lv.15000] Hraegon",
    "[Lv.15000] Niflor",
    "[Lv.15000] Struggler",
    "[Lv.15000] Surtrik",
    "[Lv.15000] Thorvak",
    "[Nightmare] Mad Dog",
    "[Lv.???]Dummy",
    "[Lv.???] Gelaros",
}

local bossNames = {
    "[Lv.150] NameLess Hero",
    "[Lv.750] Moraros",
    "[Lv.2500] Magador",
    "[Lv.6000] Velik",
    "[Lv.3000] Black Swordsman",
    "[Lv.15000] Hraegon",
    "[Lv.15000] Niflor",
    "[Lv.15000] Struggler",
    "[Lv.15000] Strugller",
    "[Lv.15000] Surtrik",
    "[Lv.15000] Thorvak",
    "[Nightmare] Mad Dog",
    "[Lv.???] Dummy",
    "[Lv.???] Gelaros",
}

local skillPayloads = {
    Z = "\147\205\tM\204\193\145\137\162tp\199\002\147\203\192\165\208v\192\000\000\000\203@L\159@\192\000\000\000\203\192\162*\135\160\000\000\000\172activationId\205\t'\168actionId\173\229\164\170\229\136\128/\230\139\148\229\136\128\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165\192\129 \000\000\000\203@K\031C \000\000\000\203\192\162\028w`\000\000\000\166facing\199\002\147\203\191\236\145\024\128\000\000\000\000\203\191\220\215\022`\000\000\000\170weaponType\166Katana\174basisDirection\199\002\147\203\191\232\0020@\000\000\000\000\203\191\229(\004`\000\000\000",
    X = "\147\205\tN\204\193\145\137\162tp\199\002\147\203\192\166\tM\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162^O\160\000\000\000\172activationId\205\t(\168actionId\173\229\164\170\229\136\128/\228\184\128\233\151\170\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\1659n\160\000\000\000\203@J\149\b\192\000\000\000\203\192\161\2161\128\000\000\000\166facing\199\002\147\203\191\236\145\024\128\000\000\000\000\203\191\220\215\022`\000\000\000\170weaponType\166Katana\174basisDirection\199\002\147\203\191\234\227\154\224\000\000\000\000\203\191\225YD@\000\000\000",
    C = "\147\205\tO\204\193\145\137\162tp\199\002\147\203\192\166\tM\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162^O\160\000\000\000\172activationId\205\t)\168actionId\176\229\164\170\229\136\128/\229\141\129\229\173\151\230\150\169\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165k\217\192\000\000\000\203@J\149\b\192\000\000\000\203\192\161\248\184\128\000\000\000\166facing\199\002\147\203\191\236\145\024\128\000\000\000\000\203\191\220\215\022`\000\000\000\170weaponType\166Katana\174basisDirection\199\002\147\203\191\234\227\142\160\000\000\000\000\203\191\225YW\000\000\000\000",
    V = "\147\205\tP\204\193\145\137\162tp\199\002\147\203\192\166\tM\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162^O\160\000\000\000\172activationId\205\t*\168actionId\173\229\164\170\229\136\128/\231\153\187\233\190\153\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165p\228`\000\000\000\203@J\149\b\224\000\000\000\203\192\161\251\249 \000\000\000\166facing\199\002\147\203\191\236\145\024\128\000\000\000\000\203\191\220\215\022`\000\000\000\170weaponType\166Katana\174basisDirection\199\002\147\203\191\234\227\140\192\000\000\000\000\203\191\225YZ@\000\000\000",
    BZ = "\147\205\t\162\204\193\145\137\162tp\199\002\147\203\192\166\022\175\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162d\139\160\000\000\000\172activationId\205\tm\168actionId\173\229\164\167\229\137\145/\232\163\130\229\156\176\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165\207M\224\000\000\000\203@K\031C \000\000\000\203\192\162{\028\160\000\000\000\166facing\199\002\147\203\191\238\130\176\192\000\000\000\000\203?\211Lo\192\000\000\000\170weaponType\166Buster\174basisDirection\199\002\147\203\191\238\130\249\160\000\000\000\000\203?\211J\162\160\000\000\000",
    BX = "\147\205\t\167\204\193\145\137\162tp\199\002\147\203\192\166\b\004\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162d\174\160\000\000\000\172activationId\205\tr\168actionId\176\229\164\167\229\137\145/\228\186\140\232\191\158\230\150\169\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165.\148`\000\000\000\203@J\149\b\224\000\000\000\203\192\162$Z\160\000\000\000\166facing\199\002\147\203\191\236\239\176\224\000\000\000\000\203\191\219S\181@\000\000\000\170weaponType\166Buster\174basisDirection\199\002\147\203\191\238\175p\192\000\000\000\000\203\191\210'\250`\000\000\000",
    BC = "\147\205\t\170\204\193\145\136\172skillUseType\166manual\166facing\199\002\147\203\191\236\239\176\224\000\000\000\000\203\191\219S\181@\000\000\000\170weaponType\166Buster\168position\199\002\147\203\192\1654\253\000\000\000\000\203@J\149\b\224\000\000\000\203\192\162&@\000\000\000\000\174basisDirection\199\002\147\203\191\236\2395\224\000\000\000\000\203\191\219U\189\192\000\000\000\172activationId\205\ts\168actionId\173\229\164\167\229\137\145/\231\139\188\232\183\179\162we\194",
    BV = "\147\205\t\171\204\193\145\137\162tp\199\002\147\203\192\166\b\004\192\000\000\000\203@L\210\192\224\000\000\000\203\192\162d\174\160\000\000\000\172activationId\205\tt\168actionId\173\229\164\167\229\137\145/\231\169\191\229\191\131\162we\195\172skillUseType\166manual\168position\199\002\147\203\192\165E\178\000\000\000\000\203@J\149\b\224\000\000\000\203\192\162+\135\000\000\000\000\166facing\199\002\147\203\191\236\239\176\224\000\000\000\000\203\191\219S\181@\000\000\000\170weaponType\166Buster\174basisDirection\199\002\147\203\191\238\179\028\192\000\000\000\000\203\191\210\015\020@\000\000\000",
}

local selectedEnemies = {}
local autoSkills = {}
local selectedAutoSkills = { Z = true }
local nativeAutoSkill = nil
local autoTeleport = false
local autoSpawnBossEvent = false
local autoStartQuest = false
local autoHolyFarm = false
local autoTowerFarm = false
local antiLag = false
local potatoMode = false
local ultraPotato = false
local antiLagCache = {}
local safeMode = true
local autoTeleportDelay = 1
local spawnBossEventDelay = 2
local questStartDelay = 5
local holyFarmDelay = 2
local towerFarmDelay = 0.8
local spawnBossMode = "Summon Boss"
local summonBossName = "Moraros"
local summonBossDifficulty = "Hard"
local eclipseDifficulty = "Easy"
local bossEventUid = "e25a2382-7ce2-4cda-a27c-865d8bb8638d"
local bossEventName = "Black Swordsman"
local autoSkillDelay = 0.8
local skillRange = 35
local hoverDistance = 4
local hoverHeight = -7
local moveMode = "Teleport"
local tweenSpeed = 120
local running = true
local sessionId = {}
local scriptSourceUrl = rawget(_G, "IndraHubReloadSource")
local currentTween = nil
local cachedEnemy = nil
local lastEnemyScan = 0
local targetIndex = 1
local targetInstanceIndex = 1
local currentTarget = nil
local lastTeleportedTarget = nil
local targetDeathConnection = nil
local currentTargetSince = 0
local targetLowHealthSince = nil
local forceSwitchDelay = 0
local lastNativeRefresh = 0
local lastCleanup = os.clock()
local lastHeartbeat = os.clock()
local lastHolyFarmStep = 0
local notifyCache = {}
local notifyThrottle = 3
local watchdogEnabled = true
local autoReloadEnabled = false
local autoReloadMinutes = 90
local sessionStartedAt = os.clock()
local skillKeys = { "Z", "X", "C", "V" }
local skillPriority = { "V", "C", "Z", "X" }
local skillKeyCodes = {
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
}
local summonBossNames = { "Moraros", "Magador", "Ragaros", "Velik", "Nivaron", "Gelaros", "Veyrath" }
local holyChestImage = "rbxassetid://95667940960287"
local holyQuestNames = {
    "Boss Quest 13000~15000 A",
    "Boss Quest 13000~15000 B",
    "Boss Quest 13000~15000 D",
    "Boss Quest 13000~15000 C",
}
local holyQuestBossByMission = {
    ["230008"] = "[Lv.15000] Niflor",
    ["230009"] = "[Lv.15000] Surtrik",
    ["230010"] = "[Lv.15000] Thorvak",
    ["230011"] = "[Lv.15000] Hraegon",
}
local holyQuestActions = {
    ["Boss Quest 13000~15000 A"] = { actionId = 290008, missionId = 230008 },
    ["Boss Quest 13000~15000 B"] = { actionId = 290009, missionId = 230009 },
    ["Boss Quest 13000~15000 D"] = { actionId = 290010, missionId = 230010 },
    ["Boss Quest 13000~15000 C"] = { actionId = 290011, missionId = 230011 },
}
local holyBossRespawnIds = {
    ["[Lv.15000] Niflor"] = "210008",
    ["[Lv.15000] Surtrik"] = "210009",
    ["[Lv.15000] Thorvak"] = "210010",
    ["[Lv.15000] Hraegon"] = "210011",
}

local function isTowerBossName(name)
    return string.match(tostring(name or ""), "^%[Layer%.%d+%]") ~= nil
end
local questNames = {
    "Boss Quest 51~200",
    "Boss Quest 551~1000",
    "Boss Quest 2001~3000",
    "Boss Quest 3001~4000",
    "Boss Quest 5001~7000",
    "Boss Quest 7001~10000",
    "Boss Quest 10001~15000",
    "Boss Quest 13000~15000 A",
    "Boss Quest 13000~15000 B",
    "Boss Quest 13000~15000 D",
    "Boss Quest 13000~15000 C",
    "Rank Quest Sword",
    "Rank Quest Katana",
    "Rank Quest Buster",
    "Skill Quest Block",
    "Skill Quest Parry",
    "Skill Quest Z",
    "Skill Quest X",
    "Skill Quest C",
    "Skill Quest V",
}
local selectedQuestName = "Boss Quest 13000~15000 B"
local questPromptIds = {
    ["Boss Quest 51~200"] = { folder = "BossTask", id = "240007" },
    ["Boss Quest 551~1000"] = { folder = "BossTask", id = "240001" },
    ["Boss Quest 2001~3000"] = { folder = "BossTask", id = "240002" },
    ["Boss Quest 3001~4000"] = { folder = "BossTask", id = "240003" },
    ["Boss Quest 5001~7000"] = { folder = "BossTask", id = "240004" },
    ["Boss Quest 7001~10000"] = { folder = "BossTask", id = "240005" },
    ["Boss Quest 10001~15000"] = { folder = "BossTask", id = "240006" },
    ["Boss Quest 13000~15000 A"] = { folder = "BossTask", id = "240008" },
    ["Boss Quest 13000~15000 B"] = { folder = "BossTask", id = "240009" },
    ["Boss Quest 13000~15000 D"] = { folder = "BossTask", id = "240010" },
    ["Boss Quest 13000~15000 C"] = { folder = "BossTask", id = "240011" },
    ["Rank Quest Sword"] = { folder = "Master", id = "241006" },
    ["Rank Quest Katana"] = { folder = "Master", id = "241007" },
    ["Rank Quest Buster"] = { folder = "Master", id = "241008" },
    ["Skill Quest Block"] = { folder = "Master", id = "241001" },
    ["Skill Quest Parry"] = { folder = "Master", id = "241002" },
    ["Skill Quest Z"] = { folder = "Master", id = "241003" },
    ["Skill Quest X"] = { folder = "Master", id = "241004" },
    ["Skill Quest C"] = { folder = "Master", id = "241005" },
    ["Skill Quest V"] = { folder = "Master", id = "241009" },
}
local eclipseDifficulties = { "Easy", "Hard", "Nightmare" }
local eclipseNpcIds = {
    Easy = "240605",
    Hard = "240606",
    Nightmare = "240607",
}
local bossEventUids = {
    "e25a2382-7ce2-4cda-a27c-865d8bb8638d",
    "9ed4f611-7d1f-4435-b423-74365b35262a",
}
local bossEventActions = {
    ["Black Swordsman"] = 440001,
    ["Struggler"] = 440002,
    ["Mad Dog"] = 440003,
}
local bossEventNames = { "Black Swordsman", "Struggler", "Mad Dog" }
local skillSlots = {
    Z = 1,
    X = 2,
    C = 3,
    V = 4,
}

local function isSessionActive()
    return running and _G.IndraHubRunning and _G.IndraHubSession == sessionId
end

local function cacheProperty(instance, property)
    antiLagCache[instance] = antiLagCache[instance] or {}
    if antiLagCache[instance][property] == nil then
        local ok, value = pcall(function()
            return instance[property]
        end)
        if ok then
            antiLagCache[instance][property] = value
        end
    end
end

local function setCachedProperty(instance, property, value)
    cacheProperty(instance, property)
    pcall(function()
        instance[property] = value
    end)
end

local function applyAntiLagTo(instance)
    if instance:IsA("BasePart") then
        setCachedProperty(instance, "Material", Enum.Material.SmoothPlastic)
        setCachedProperty(instance, "Reflectance", 0)
        setCachedProperty(instance, "CastShadow", false)
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        setCachedProperty(instance, "Transparency", 1)
    elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
        setCachedProperty(instance, "Enabled", false)
    elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") then
        setCachedProperty(instance, "Enabled", false)
    elseif potatoMode and (instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight")) then
        setCachedProperty(instance, "Enabled", false)
    elseif potatoMode and (instance:IsA("Explosion") or instance:IsA("ForceField")) then
        setCachedProperty(instance, "Visible", false)
    end
end

local function applyUltraPotatoTo(instance)
    applyAntiLagTo(instance)

    if instance:IsA("BasePart") then
        local keep = false
        local enemyService = workspace:FindFirstChild("EnemyService")
        if Players.LocalPlayer.Character and instance:IsDescendantOf(Players.LocalPlayer.Character) then keep = true end
        if enemyService and instance:IsDescendantOf(enemyService) then keep = true end
        if not keep then
            setCachedProperty(instance, "Transparency", 1)
        end
    elseif instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
        setCachedProperty(instance, "Enabled", false)
    end
end

local function setAntiLag(enabled)
    antiLag = enabled

    if enabled then
        setCachedProperty(Lighting, "GlobalShadows", false)
        setCachedProperty(Lighting, "FogEnd", 100000)
        pcall(function()
            local rendering = settings().Rendering
            rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        for _, item in ipairs(workspace:GetDescendants()) do
            applyAntiLagTo(item)
        end
    else
        for instance, props in pairs(antiLagCache) do
            if instance and instance.Parent then
                for property, value in pairs(props) do
                    pcall(function()
                        instance[property] = value
                    end)
                end
            end
        end
        antiLagCache = {}
    end
end

local function setPotatoMode(enabled)
    potatoMode = enabled
    if enabled then
        antiLag = true
        setCachedProperty(Lighting, "GlobalShadows", false)
        setCachedProperty(Lighting, "Brightness", 1)
        setCachedProperty(Lighting, "EnvironmentDiffuseScale", 0)
        setCachedProperty(Lighting, "EnvironmentSpecularScale", 0)
        setCachedProperty(Lighting, "FogEnd", 100000)

        pcall(function()
            cacheProperty(Lighting, "Technology")
            Lighting.Technology = Enum.Technology.Compatibility
        end)
        pcall(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                setCachedProperty(terrain, "WaterWaveSize", 0)
                setCachedProperty(terrain, "WaterWaveSpeed", 0)
                setCachedProperty(terrain, "WaterReflectance", 0)
                setCachedProperty(terrain, "WaterTransparency", 1)
            end
        end)
        pcall(function()
            local rendering = settings().Rendering
            rendering.QualityLevel = Enum.QualityLevel.Level01
            rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        end)

        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("PostEffect") then
                setCachedProperty(item, "Enabled", false)
            elseif item:IsA("Sound") then
                setCachedProperty(item, "Volume", 0)
            else
                applyAntiLagTo(item)
            end
        end
    else
        antiLag = false
        setAntiLag(false)
    end
end

local function setUltraPotato(enabled)
    ultraPotato = enabled
    if enabled then
        setPotatoMode(true)
        pcall(function()
            if type(setfpscap) == "function" then
                setfpscap(240)
            end
        end)

        for _, item in ipairs(workspace:GetDescendants()) do
            applyUltraPotatoTo(item)
        end
    else
        ultraPotato = false
        setPotatoMode(false)
    end
end

local function getSlotActionId(slot)
    if type(Player3CController.GetCombatSlotActionIds) ~= "function" then return nil end

    local ok, actionIds = pcall(Player3CController.GetCombatSlotActionIds)
    if not ok then return nil end
    if type(actionIds) ~= "table" then return nil end

    return actionIds[slot] or actionIds["Skill" .. tostring(slot)]
end

local function isSkillReady(skillKey)
    local slot = skillSlots[skillKey]
    if not slot then return false end

    local actionId = getSlotActionId(slot)
    if type(actionId) ~= "string" or actionId == "" then
        return true
    end

    if type(Player3CController.GetAbilityCooldown) ~= "function" then return true end

    local ok, cooldown = pcall(function()
        return Player3CController.GetAbilityCooldown(actionId)
    end)

    if not ok or type(cooldown) ~= "table" then
        return true
    end

    return tonumber(cooldown.remaining) == nil or cooldown.remaining <= 0
end

local function setControllerAutoSkill(skillKey, enabled)
    local slot = skillSlots[skillKey]
    if not slot then return false end

    if not enabled then
        return pcall(function()
            if type(Player3CController.StopAutoSkill) ~= "function" then return false end
            return Player3CController.StopAutoSkill()
        end)
    end

    local ok, result = pcall(function()
        if type(Player3CController.IsDrawn) == "function" and not Player3CController.IsDrawn() and type(Player3CController.RequestDrawWeapon) == "function" then
            Player3CController.RequestDrawWeapon()
            task.wait(0.2)
        end

        local actionName = "Skill" .. tostring(slot)
        local actionId = getSlotActionId(slot)

        if type(actionId) == "string" and actionId ~= "" then
            if type(Player3CController.SetAutoMappedAction) ~= "function" then return false end
            return Player3CController.SetAutoMappedAction(actionName, actionId)
        end

        if type(Player3CController.ToggleAutoMappedAction) ~= "function" then return false end
        return Player3CController.ToggleAutoMappedAction(actionName)
    end)

    return ok and result == true
end

local function hasControllerAutoSkill()
    return type(Player3CController.SetAutoMappedAction) == "function"
        or type(Player3CController.ToggleAutoMappedAction) == "function"
        or type(Player3CController.ActivateMappedAction) == "function"
end

local function rebuildNativeAutoSkill()
    if isXeno then
        nativeAutoSkill = nil
        return
    end

    if nativeAutoSkill and autoSkills[nativeAutoSkill] then
        setControllerAutoSkill(nativeAutoSkill, true)
        return
    end

    nativeAutoSkill = nil
    pcall(function()
        if type(Player3CController.StopAutoSkill) ~= "function" then return end
        Player3CController.StopAutoSkill()
    end)

    for _, skillKey in ipairs(skillKeys) do
        if autoSkills[skillKey] then
            nativeAutoSkill = skillKey
            setControllerAutoSkill(skillKey, true)
            return
        end
    end
end

local function refreshSkillAfterTargetChange()
    pcall(function()
        if type(Player3CController.StopAutoSkill) ~= "function" then return end
        Player3CController.StopAutoSkill()
    end)

    task.wait(0.15)

    if nativeAutoSkill and autoSkills[nativeAutoSkill] then
        setControllerAutoSkill(nativeAutoSkill, true)
        lastNativeRefresh = os.clock()
    end
end

local function notify(title, content, icon)
    local key = tostring(title) .. "|" .. tostring(content)
    local now = os.clock()
    if notifyCache[key] and now - notifyCache[key] < notifyThrottle then
        return
    end
    notifyCache[key] = now

    pcall(function()
        if type(WindUI.Notify) == "function" then
            WindUI:Notify({ Title = title, Content = content, Icon = icon or "info", Duration = 2 })
        end
    end)
end

local fireEclipseSummon

local function fireSpawnBossEvent()
    if spawnBossMode == "Eclipse" then
        fireEclipseSummon()
        return
    end

    if spawnBossMode == "Boss Event UID" then
        local actionId = bossEventActions[bossEventName] or 440001
        local uid = bossEventUid
        local bossTaskFolder = workspace:FindFirstChild("World")
            and workspace.World:FindFirstChild("NPC")
            and workspace.World.NPC:FindFirstChild("BossTask")

        if bossTaskFolder then
            for _, npc in ipairs(bossTaskFolder:GetChildren()) do
                local npcUid = npc:GetAttribute("NpcUID")
                if type(npcUid) == "string" and npcUid ~= "" then
                    uid = npcUid
                    break
                end
            end
        end

        if type(TEvent.FireRemote) == "function" then
            TEvent.FireRemote("NPCSummonWorldBossRequest", {
                actionId = actionId,
                npcUid = uid,
            })
        else
            dumpError("boss event", "TEvent not ready: cannot spawn event boss")
        end
        return
    end

    local summonId = nil

    local summonDefs = Config.Enemy and Config.Enemy.Summon and Config.Enemy.Summon._def or {}

    for _, summon in pairs(summonDefs) do
        if type(summon) == "table" and summon.type == "Boss" and tostring(summon.level) == summonBossDifficulty then
            local name = tostring(summon.name or "")

            if string.find(name, summonBossName, 1, true) then
                summonId = tonumber(summon.id)
                break
            end
        end
    end

    if summonId then
        if type(TEvent.FireRemote) == "function" then
            TEvent.FireRemote(SummonBoss.OP_EVENT, {
                op = SummonBoss.OP.Summon,
                summonId = summonId,
            })
        else
            dumpError("normal boss", "TEvent not ready: cannot spawn normal boss")
        end
    else
        dumpError("summon config missing", tostring(summonBossName) .. " " .. tostring(summonBossDifficulty))
    end
end

local function getRoot()
    local character = player.Character
    if not character then return nil end

    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("UpperTorso")
        or character.PrimaryPart
end

local function getPromptPart(prompt)
    local current = prompt and prompt.Parent
    while current and current ~= workspace do
        if current:IsA("BasePart") then return current end
        current = current.Parent
    end

    local model = prompt and prompt:FindFirstAncestorOfClass("Model")
    return model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or nil
end

local function findEclipsePrompt(npcId)
    local npcRoot = workspace:FindFirstChild("World")
        and workspace.World:FindFirstChild("NPC")
        and workspace.World.NPC:FindFirstChild("Other")

    local npc = npcRoot and npcRoot:FindFirstChild(tostring(npcId))
    if npc then
        local talk = npc:FindFirstChild("Talk", true)
        local prompt = talk and talk:FindFirstChildOfClass("ProximityPrompt")
        if prompt then return prompt end

        prompt = npc:FindFirstChildOfClass("ProximityPrompt", true)
        if prompt then return prompt end
    end

    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") then
            local fullName = string.lower(item:GetFullName())
            if string.find(fullName, tostring(npcId), 1, true)
                or string.find(fullName, "eclipse", 1, true)
                or string.find(fullName, "beherit", 1, true) then
                return item
            end
        end
    end

    return nil
end

local function clickConfirmationYes()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end

    local VirtualInput = VirtualInputManager
    if not VirtualInput then return false end

    local homePage = playerGui:FindFirstChild("Main")
        and playerGui.Main:FindFirstChild("HomePage")
    local eclipseConfirm = homePage and homePage:FindFirstChild("EclipseConfirm")
    eclipseConfirm = eclipseConfirm or playerGui:FindFirstChild("EclipseConfirm", true)
    local exactButton = eclipseConfirm and eclipseConfirm:FindFirstChild("Enter", true)
    if exactButton and exactButton:IsA("GuiObject") and exactButton.Visible then
        pcall(function()
            GuiService.SelectedObject = exactButton
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait()
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait()
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            GuiService.SelectedObject = nil
        end)
        local inset = GuiService:GetGuiInset()
        local position = exactButton.AbsolutePosition + (exactButton.AbsoluteSize / 2) + inset
        VirtualInput:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 1)
        task.wait()
        VirtualInput:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 1)
        return true
    end

    if eclipseConfirm then return false end
    return false
end

fireEclipseSummon = function()
    local npcId = eclipseNpcIds[eclipseDifficulty] or eclipseNpcIds.Easy
    local prompt = findEclipsePrompt(npcId)

    if prompt then
        local root = getRoot()
        local oldCFrame = root and root.CFrame
        local promptPart = getPromptPart(prompt)

        if root and promptPart and promptPart:IsA("BasePart") then
            root.CFrame = promptPart.CFrame * CFrame.new(0, 0, -4)
            task.wait(0.15)
        end

        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        elseif type(fireproximityprompt) == "function" then
            fireproximityprompt(prompt)
        end

        for _ = 1, 6 do
            task.wait(0.25)
            if clickConfirmationYes() then break end
        end

        if root and oldCFrame then
            task.wait(0.1)
            root.CFrame = oldCFrame
        end
        return
    end

    dumpError("eclipse summon", "Prompt not found: " .. tostring(npcId))
end

local function startSelectedQuest()
    local quest = questPromptIds[selectedQuestName]
    local npcRoot = workspace:FindFirstChild("World")
        and workspace.World:FindFirstChild("NPC")
    local npc = quest and npcRoot
        and npcRoot:FindFirstChild(quest.folder)
        and npcRoot[quest.folder]:FindFirstChild(quest.id)
    local prompt = npc
        and npc:FindFirstChild("Talk", true)
        and npc:FindFirstChild("Talk", true):FindFirstChildOfClass("ProximityPrompt")

    if not prompt and npc then
        prompt = npc:FindFirstChildOfClass("ProximityPrompt", true)
    end

    if not prompt then
        dumpError("quest start", "Prompt not found: " .. tostring(selectedQuestName))
        return false
    end

    local root = getRoot()
    local oldCFrame = root and root.CFrame
    local promptPart = getPromptPart(prompt)

    if root and promptPart and promptPart:IsA("BasePart") then
        root.CFrame = promptPart.CFrame * CFrame.new(0, 0, -4)
        task.wait(0.15)
    end

    if VirtualInputManager then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    elseif type(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    end

    if root and oldCFrame then
        task.wait(0.1)
        root.CFrame = oldCFrame
    end

    return true
end

local function directAcceptQuest(questName)
    local action = holyQuestActions[questName]
    if not action then return false end

    if type(QuestClient.AcceptQuest) == "function" then
        local ok, result = pcall(QuestClient.AcceptQuest, action.missionId)
        if ok and result ~= false then return true end
    end

    if type(TEvent.FireRemote) == "function" then
        local eventName = Quest.OP_EVENT or "QuestOp"
        local acceptOp = Quest.OP and Quest.OP.Accept or "Accept"
        local payloads = {
            { op = acceptOp, questId = action.missionId },
        }
        for _, payload in ipairs(payloads) do
            local ok = pcall(function()
                TEvent.FireRemote(eventName, payload)
            end)
            if ok then task.wait(0.05) end
        end
    end

    return false
end

local giveUpQuestCard
local teleportSelected
local hoverBehindSelected
local useSkill
local moveToCFrame
local getEnemyRoot
local findEnemyByName
local isMarkedDead

local function directAbandonQuest(missionId)
    local id = tonumber(missionId)
    if not id then return false end

    if type(QuestClient.AbandonQuest) == "function" then
        local ok, result = pcall(QuestClient.AbandonQuest, id)
        if ok and result ~= false then
            task.wait(0.15)
            if type(QuestClient.GetActiveQuest) == "function" then
                local activeOk, active = pcall(QuestClient.GetActiveQuest, id)
                if activeOk and active == nil then return true end
            end
        end
    end

    if type(TEvent.FireRemote) == "function" then
        local eventName = Quest.OP_EVENT or "QuestOp"
        local abandonOp = Quest.OP and Quest.OP.Abandon or "Abandon"
        local payloads = {
            { op = abandonOp, questId = id },
        }
        for _, payload in ipairs(payloads) do
            local ok = pcall(function()
                TEvent.FireRemote(eventName, payload)
            end)
            if ok then task.wait(0.05) end
        end
    end

    return false
end

local function abandonQuestCard(card, missionId)
    local abandoned = directAbandonQuest(missionId)
    task.wait(0.15)
    if not abandoned and card and card.Parent then
        giveUpQuestCard(card)
    end
    return abandoned
end

local clearHover

local function getActiveHolyQuestCard()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for missionId, bossName in pairs(holyQuestBossByMission) do
        local card = playerGui:FindFirstChild("Quest_" .. missionId, true)
        if card and card:IsA("GuiObject") and card.Visible then
            return card, missionId, bossName
        end
    end

    return nil
end

local function questCardHasHolyChest(card)
    local icon = card
        and card:FindFirstChild("Outline", true)
        and card:FindFirstChild("Outline", true):FindFirstChild("Task", true)
        and card:FindFirstChild("Outline", true):FindFirstChild("Task", true):FindFirstChild("Icon", true)

    local image = icon and icon:FindFirstChild("ImageLabel", true)
    if image and image:IsA("ImageLabel") and tostring(image.Image) == holyChestImage then
        local number = icon:FindFirstChild("Number", true)
        return true, number and tostring(number.Text or "") or "?"
    end

    return false, ""
end

local function questCardCompleted(card)
    local defeated = card and card:FindFirstChild("Defeated", true)
    if defeated and (defeated:IsA("TextLabel") or defeated:IsA("TextButton")) then
        local text = tostring(defeated.Text or "")
        local current, total = string.match(text, "(%d+)%s*/%s*(%d+)")
        return tonumber(current) ~= nil and tonumber(total) ~= nil and tonumber(current) >= tonumber(total)
    end
    return false
end

giveUpQuestCard = function(card)
    local button = card and card:FindFirstChild("GiveUp", true)
    if not button or not button:IsA("GuiObject") then return false end
    if not VirtualInputManager then return false end

    local inset = GuiService:GetGuiInset()
    local pos = button.AbsolutePosition + (button.AbsoluteSize / 2) + inset
    pcall(function()
        GuiService.SelectedObject = button
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        GuiService.SelectedObject = nil
    end)
    task.wait(0.15)
    clickConfirmationYes()
    return true
end

local function setHolyBossTarget(bossName)
    selectedEnemies = {}
    selectedEnemies[bossName] = true
    autoSkills = {}
    nativeAutoSkill = nil
    for _, skillKey in ipairs(skillKeys) do
        if selectedAutoSkills[skillKey] or skillKey == "Z" then
            autoSkills[skillKey] = true
            if not isXeno then
                nativeAutoSkill = nativeAutoSkill or skillKey
            end
        end
    end
    rebuildNativeAutoSkill()
    currentTarget = nil
    cachedEnemy = nil
    targetIndex = 1
    targetInstanceIndex = 1
end

local function engageHolyBoss(bossName)
    setHolyBossTarget(bossName)
    autoTeleport = true

    cachedEnemy = nil
    local enemy = findEnemyByName(bossName, true)
    local enemyRoot = enemy and getEnemyRoot(enemy)
    local root = getRoot()
    if enemy and enemyRoot and root then
        currentTarget = enemy
        lastTeleportedTarget = enemy
        currentTargetSince = os.clock()
        targetLowHealthSince = nil
        moveToCFrame(root, enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance))
    else
        teleportSelected()
    end

    hoverBehindSelected()
    useSkill("Z")
    return currentTarget ~= nil or enemy ~= nil
end

local function findActiveTowerBoss()
    local enemyFolder = workspace:FindFirstChild("EnemyService")
    if not enemyFolder then return nil end

    local bestEnemy = nil
    local bestLayer = -1

    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local layer = tonumber(string.match(enemy.Name, "^%[Layer%.(%d+)%]"))
        if layer and layer > bestLayer and getEnemyRoot(enemy) and not isMarkedDead(enemy) then
            bestLayer = layer
            bestEnemy = enemy
        end
    end

    return bestEnemy, bestLayer
end

local function engageTowerBoss()
    local enemy, layer = findActiveTowerBoss()
    if not enemy then return false end

    selectedEnemies = { [enemy.Name] = true }
    autoTeleport = true
    autoSkills = {}
    nativeAutoSkill = nil
    for _, skillKey in ipairs(skillKeys) do
        if selectedAutoSkills[skillKey] or skillKey == "Z" then
            autoSkills[skillKey] = true
            if not isXeno then nativeAutoSkill = nativeAutoSkill or skillKey end
        end
    end
    rebuildNativeAutoSkill()

    local enemyRoot = getEnemyRoot(enemy)
    local root = getRoot()
    if enemyRoot and root then
        currentTarget = enemy
        lastTeleportedTarget = enemy
        currentTargetSince = os.clock()
        targetLowHealthSince = nil
        moveToCFrame(root, enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance))
        hoverBehindSelected()
        useSkill("Z")
        return true, layer, enemy.Name
    end

    return false
end

local function isHolyBossAvailable(bossName)
    local respawnId = holyBossRespawnIds[bossName]
    local respawnRoot = respawnId
        and workspace:FindFirstChild("World")
        and workspace.World:FindFirstChild("BossRespawn")
        and workspace.World.BossRespawn:FindFirstChild(respawnId)

    if respawnRoot then
        for _, item in ipairs(respawnRoot:GetDescendants()) do
            if item:IsA("TextLabel") or item:IsA("TextButton") then
                local rawText = tostring(item.Text or "")
                local minutes, seconds = string.match(rawText, "^%s*(%d+):(%d+)%s*$")
                if minutes and seconds then
                    local totalSeconds = (tonumber(minutes) or 0) * 60 + (tonumber(seconds) or 0)
                    if totalSeconds > 0 then
                        return false
                    end
                end
            end
        end
    end

    cachedEnemy = nil
    local enemy = findEnemyByName(bossName, true)
    return enemy ~= nil and enemy.Parent ~= nil and getEnemyRoot(enemy) ~= nil and not isMarkedDead(enemy)
end

local function waitForHolyBossAvailable(bossName, timeout)
    local deadline = os.clock() + (timeout or 2)
    repeat
        if isHolyBossAvailable(bossName) then
            return true
        end
        task.wait(0.2)
    until os.clock() >= deadline
    return false
end

local function runHolyFarmStep()
    local card, missionId, bossName = getActiveHolyQuestCard()
    if card then
        local hasHoly, amount = questCardHasHolyChest(card)
        if hasHoly then
            if questCardCompleted(card) then
                notify("Holy Farm", "Quest selesai, cari Holy lain", "check")
            elseif not waitForHolyBossAvailable(bossName, safeMode and 2.5 or 1.5) then
                autoTeleport = false
                clearHover()
                abandonQuestCard(card, missionId)
                notify("Holy Farm", bossName .. " cooldown/no boss, skip", "clock")
            elseif engageHolyBoss(bossName) then
                notify("Holy Farm", bossName .. " Holy Chest x" .. tostring(amount), "gift")
            else
                autoTeleport = false
                clearHover()
            abandonQuestCard(card, missionId)
                notify("Holy Farm", bossName .. " cooldown/no boss, skip", "clock")
            end
        else
            autoTeleport = false
            clearHover()
            abandonQuestCard(card, missionId)
            notify("Holy Farm", "Skip non-Holy quest " .. tostring(missionId), "x")
        end
        return
    end

    autoTeleport = false
    clearHover()
    local oldQuestName = selectedQuestName
    for _, questName in ipairs(holyQuestNames) do
        selectedQuestName = questName
        local usedDirect = directAcceptQuest(questName)
        task.wait(safeMode and 0.2 or 0.1)
        if not getActiveHolyQuestCard() and not usedDirect then
            startSelectedQuest()
        elseif not getActiveHolyQuestCard() and usedDirect then
            startSelectedQuest()
        end
        task.wait(safeMode and 0.25 or 0.12)
        local newCard, newMissionId, newBossName = getActiveHolyQuestCard()
        if newCard then
            local hasHoly, amount = questCardHasHolyChest(newCard)
            if hasHoly then
                if questCardCompleted(newCard) then
                    notify("Holy Farm", "Quest selesai, cari Holy lain", "check")
                elseif not waitForHolyBossAvailable(newBossName, safeMode and 2.5 or 1.5) then
                    autoTeleport = false
                    clearHover()
                    abandonQuestCard(newCard, newMissionId)
                    notify("Holy Farm", newBossName .. " cooldown/no boss, skip", "clock")
                elseif engageHolyBoss(newBossName) then
                    notify("Holy Farm", newBossName .. " Holy Chest x" .. tostring(amount), "gift")
                else
                    autoTeleport = false
                    clearHover()
                    abandonQuestCard(newCard, newMissionId)
                    notify("Holy Farm", newBossName .. " cooldown/no boss, skip", "clock")
                end
            else
                abandonQuestCard(newCard, newMissionId)
                notify("Holy Farm", "Skip non-Holy quest " .. tostring(newMissionId), "x")
            end
            break
        end
    end
    selectedQuestName = oldQuestName
end

local function moveCharacterByParts(targetCFrame)
    local character = player.Character
    local root = getRoot()
    if not character or not root then return false end

    local offset = targetCFrame.Position - root.Position

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                if part == root then
                    part.CFrame = targetCFrame
                else
                    part.CFrame = part.CFrame + offset
                end
            end)
        end
    end

    return true
end

moveToCFrame = function(root, targetCFrame)
    if moveMode == "Tween" then
        local distance = (root.Position - targetCFrame.Position).Magnitude
        local duration = math.clamp(distance / tweenSpeed, 0.15, safeMode and 2 or 3)

        if currentTween then
            pcall(function()
                currentTween:Cancel()
            end)
            currentTween = nil
        end

        currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
        currentTween:Play()
    else
        if currentTween then
            pcall(function()
                currentTween:Cancel()
            end)
            currentTween = nil
        end

        if moveMode == "Part Teleport" then
            moveCharacterByParts(targetCFrame)
        else
            root.CFrame = targetCFrame
        end
    end
end

getEnemyRoot = function(enemy)
    return enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso") or enemy:FindFirstChild("UpperTorso") or enemy.PrimaryPart
end

findEnemyByName = function(enemyName, forceScan)
    if cachedEnemy and cachedEnemy.Parent and cachedEnemy.Name == enemyName then
        return cachedEnemy
    end

    if not forceScan and os.clock() - lastEnemyScan < 0.5 then
        return nil
    end

    lastEnemyScan = os.clock()
    local enemyFolder = workspace:WaitForChild("EnemyService")

    for _, enemy in ipairs(enemyFolder:GetDescendants()) do
        if enemy.Name == enemyName then
            cachedEnemy = enemy
            return enemy
        end
    end

    return nil
end

local isEnemyAlive

local function getSelectedEnemyInstances()
    local result = {}
    local enemyFolder = workspace:FindFirstChild("EnemyService")
    if not enemyFolder then return result end

    for _, enemy in ipairs(enemyFolder:GetDescendants()) do
        if selectedEnemies[enemy.Name] and isEnemyAlive(enemy) then
            table.insert(result, enemy)
        end
    end

    table.sort(result, function(a, b)
        if a.Name == b.Name then
            return tostring(a) < tostring(b)
        end

        return a.Name < b.Name
    end)

    return result
end

local function readNumberValue(instance, names)
    for _, name in ipairs(names) do
        local attr = instance:GetAttribute(name)
        if tonumber(attr) ~= nil then
            return tonumber(attr)
        end

        local child = instance:FindFirstChild(name, true)
        if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return tonumber(child.Value)
        end
    end

    return nil
end

local function nameLooksLikeHealth(name)
    local lowered = string.lower(tostring(name))
    if string.find(lowered, "max", 1, true) then return false end
    return string.find(lowered, "health", 1, true)
        or string.find(lowered, "hp", 1, true)
        or string.find(lowered, "life", 1, true)
end

local function scanEnemyHealth(enemy)
    for _, item in ipairs(enemy:GetDescendants()) do
        if nameLooksLikeHealth(item.Name) then
            for _, attrName in ipairs({ "Value", "Health", "HP", "Hp", "Current", "CurrentHealth", "CurrentHP" }) do
                local attr = item:GetAttribute(attrName)
                if tonumber(attr) ~= nil then
                    return tonumber(attr)
                end
            end

            if item:IsA("NumberValue") or item:IsA("IntValue") then
                return tonumber(item.Value)
            end
        end

        if item:IsA("TextLabel") or item:IsA("TextButton") then
            local text = tostring(item.Text or "")
            local current = string.match(text, "^%s*(%-?%d+%.?%d*)%s*/") or string.match(text, "^%s*(%-?%d+%.?%d*)%s*%%")
            if current and tonumber(current) ~= nil then
                return tonumber(current)
            end
        end
    end

    return nil
end

isMarkedDead = function(enemy)
    for _, name in ipairs({ "Dead", "IsDead", "Killed", "Defeated", "IsKilled", "IsDefeated" }) do
        if enemy:GetAttribute(name) == true then
            return true
        end
    end

    local state = enemy:GetAttribute("State") or enemy:GetAttribute("Status")
    if type(state) == "string" then
        local lowered = string.lower(state)
        if lowered == "dead" or lowered == "death" or lowered == "killed" or lowered == "defeated" then
            return true
        end
    end

    return false
end

local function getEnemyHealth(enemy)
    local humanoid = enemy:FindFirstChildOfClass("Humanoid") or enemy:FindFirstChild("Humanoid", true)
    if humanoid then
        if humanoid:GetState() == Enum.HumanoidStateType.Dead then
            return 0
        end
        return humanoid.Health
    end

    return readNumberValue(enemy, { "Health", "HP", "Hp", "Life", "CurrentHealth", "CurrentHP", "CurrentHp", "CurrentLife" }) or scanEnemyHealth(enemy)
end

isEnemyAlive = function(enemy)
    if not enemy or not enemy.Parent then return false end
    if not selectedEnemies[enemy.Name] then return false end
    if not getEnemyRoot(enemy) then return false end
    if isMarkedDead(enemy) then return false end

    local health = getEnemyHealth(enemy)
    if health ~= nil and health <= 0.05 then return false end

    return true
end

local function teleportToEnemy(enemyName)
    local enemy = findEnemyByName(enemyName)
    if not isEnemyAlive(enemy) then return false end

    local enemyRoot = getEnemyRoot(enemy)
    if not enemyRoot then return false end

    local root = getRoot()
    if not root then return false end

    local targetCFrame = enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance)

    moveToCFrame(root, targetCFrame)

    return true
end

hoverBehindSelected = function()
    if currentTween and currentTween.PlaybackState == Enum.PlaybackState.Playing then
        return true
    end

    local root = getRoot()
    if not root then return false end

    if isEnemyAlive(currentTarget) then
        local enemyRoot = getEnemyRoot(currentTarget)
        local targetCFrame = enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance)
        moveToCFrame(root, CFrame.lookAt(targetCFrame.Position, enemyRoot.Position))
        root.AssemblyLinearVelocity = Vector3.zero
        return true
    end

    for _, enemyName in ipairs(enemyNames) do
        if selectedEnemies[enemyName] then
            local enemy = findEnemyByName(enemyName)
            local enemyRoot = enemy and getEnemyRoot(enemy)

            if enemyRoot and isEnemyAlive(enemy) then
                local targetCFrame = enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance)
                moveToCFrame(root, CFrame.lookAt(targetCFrame.Position, enemyRoot.Position))
                root.AssemblyLinearVelocity = Vector3.zero
                return true
            end
        end
    end

    return false
end

clearHover = function()
    local root = getRoot()
    if not root then return end

    if currentTween then
        pcall(function()
            currentTween:Cancel()
        end)
        currentTween = nil
    end

    for _, name in ipairs({ "EmberHoverAlignPosition", "EmberHoverAlignOrientation", "EmberHoverAttachment" }) do
        local item = root:FindFirstChild(name)
        if item then pcall(function() item:Destroy() end) end
    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function setCurrentTarget(enemy)
    if targetDeathConnection then
        targetDeathConnection:Disconnect()
        targetDeathConnection = nil
    end

    currentTarget = enemy
    lastTeleportedTarget = enemy
    currentTargetSince = os.clock()
    targetLowHealthSince = nil

    local humanoid = enemy and (enemy:FindFirstChildOfClass("Humanoid") or enemy:FindFirstChild("Humanoid", true))
    if humanoid then
        targetDeathConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if currentTarget == enemy and humanoid.Health <= 0.05 then
                targetLowHealthSince = targetLowHealthSince or os.clock()
            elseif currentTarget == enemy then
                targetLowHealthSince = nil
            end
        end)
    end
end

local function shouldLeaveCurrentTarget()
    if not currentTarget then return true end
    if forceSwitchDelay > 0 and os.clock() - currentTargetSince >= forceSwitchDelay then return true end

    local health = getEnemyHealth(currentTarget)
    if health ~= nil and health <= 0.05 then
        targetLowHealthSince = targetLowHealthSince or os.clock()
        return os.clock() - targetLowHealthSince >= 0.4
    end

    targetLowHealthSince = nil
    return not isEnemyAlive(currentTarget)
end

teleportSelected = function()
    if currentTarget and not shouldLeaveCurrentTarget() then
        return true
    else
        currentTarget = nil
        lastTeleportedTarget = nil
        targetLowHealthSince = nil
    end

    local instances = getSelectedEnemyInstances()

    if #instances > 0 then
        if targetInstanceIndex > #instances then targetInstanceIndex = 1 end

        for i = 1, #instances do
            local index = ((targetInstanceIndex + i - 2) % #instances) + 1
            local enemyRoot = getEnemyRoot(instances[index])
            local root = getRoot()

            if enemyRoot and root and isEnemyAlive(instances[index]) then
                local targetCFrame = enemyRoot.CFrame * CFrame.new(0, hoverHeight, hoverDistance)

                moveToCFrame(root, targetCFrame)

                if currentTarget ~= instances[index] then
                    setCurrentTarget(instances[index])
                    task.spawn(refreshSkillAfterTargetChange)
                end
                targetInstanceIndex = index + 1
                return true
            end
        end
    end

    local selectedList = {}

    for _, enemyName in ipairs(enemyNames) do
        if selectedEnemies[enemyName] then
            table.insert(selectedList, enemyName)
        end
    end

    if #selectedList == 0 then return false end

    if targetIndex > #selectedList then targetIndex = 1 end

    for i = 1, #selectedList do
        local index = ((targetIndex + i - 2) % #selectedList) + 1

        if teleportToEnemy(selectedList[index]) then
            targetIndex = index + 1
            return true
        end
    end

    return false
end

local function hasSelectedEnemyInRange()
    local root = getRoot()
    if not root then return false end

    if isEnemyAlive(currentTarget) then
        local enemyRoot = getEnemyRoot(currentTarget)
        return enemyRoot and (root.Position - enemyRoot.Position).Magnitude <= skillRange
    end

    return false
end

useSkill = function(skillKey)
    local slot = skillSlots[skillKey]
    if slot then
        local ok = true
        if not isXeno then
            local usedController
            ok, usedController = pcall(function()
                if type(Player3CController.IsDrawn) == "function" and not Player3CController.IsDrawn() and type(Player3CController.RequestDrawWeapon) == "function" then
                    Player3CController.RequestDrawWeapon()
                    task.wait(0.25)
                end

                local actionName = "Skill" .. tostring(slot)
                if type(Player3CController.ActivateMappedAction) ~= "function" then return false end
                Player3CController.ActivateMappedAction(actionName)
                task.wait(0.08)
                if type(Player3CController.ReleaseMappedAction) == "function" then
                    Player3CController.ReleaseMappedAction(actionName)
                end
                return true
            end)

            if ok and usedController then
                return true
            end
        end

        local keyCode = skillKeyCodes[skillKey]
        if VirtualInputManager and keyCode then
            local inputOk = pcall(function()
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.08)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end)
            if inputOk then
                return true
            end
        end

        if not ok then
            dumpError("skill activation failed", skillKey)
        end
    end

    return false
end

if _G.IndraHubWindUI then
    _G.IndraHubRunning = false
    pcall(function() _G.IndraHubWindUI:Destroy() end)
end
if _G.IndraHubConnections then
    for _, connection in ipairs(_G.IndraHubConnections) do
        pcall(function() connection:Disconnect() end)
    end
end
_G.IndraHubConnections = {}
_G.IndraHubRunning = true
_G.IndraHubSession = sessionId
_G.IndraHubLastHeartbeat = os.clock()

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "swords",
    Author = "Enemy Teleport + Auto Skill",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(560, 430),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    KeySystem = {
        Note = "Enter your key to continue.",
        SaveKey = true,
        API = {
            {
                Title = "Junkie",
                Desc = "Click to copy link",
                Icon = "key-round",
                Type = "junkiedevelopment"
            }
        }
    },
})
_G.IndraHubWindUI = Window

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end

Window:SetToggleKey(Enum.KeyCode.RightControl)
Window:EditOpenButton({
    Title = "IH",
    Icon = "swords",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(255, 85, 35), Color3.fromRGB(255, 190, 85)),
    Draggable = true,
})

local Tabs = {
    Farm = Window:Tab({ Title = "Farm", Icon = "target" }),
    Quest = Window:Tab({ Title = "Quest", Icon = "scroll" }),
    Holy = Window:Tab({ Title = "Holy Farm", Icon = "gift" }),
    Tower = Window:Tab({ Title = "Tower Farm", Icon = "layers" }),
    Skills = Window:Tab({ Title = "Skills", Icon = "zap" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

Tabs.Farm:Section({ Title = "Targets", Icon = "crosshair" })
Tabs.Farm:Dropdown({
    Title = "Enemy Selector",
    Desc = "Multi-select target enemy. Ordered by level.",
    Values = enemyNames,
    Multi = true,
    Callback = function(values)
        selectedEnemies = {}

        for _, value in ipairs(values or {}) do
            selectedEnemies[value] = true
        end

        notify("Targets Updated", tostring(#(values or {})) .. " selected", "target")
    end,
})

Tabs.Farm:Button({
    Title = "Boss Only Preset",
    Desc = "Select boss targets only. Dropdown visual may not update.",
    Callback = function()
        selectedEnemies = {}
        currentTarget = nil
        targetIndex = 1
        targetInstanceIndex = 1

        for _, enemyName in ipairs(bossNames) do
            selectedEnemies[enemyName] = true
        end

        notify("Boss Preset", tostring(#bossNames) .. " bosses selected", "crown")
    end,
})

Tabs.Farm:Button({
    Title = "Clear Targets",
    Desc = "Clear script-side target selection.",
    Callback = function()
        selectedEnemies = {}
        currentTarget = nil
        targetIndex = 1
        targetInstanceIndex = 1
        notify("Targets", "Cleared", "x")
    end,
})

Tabs.Farm:Button({
    Title = "Teleport Once",
    Desc = "Teleport to first available selected enemy.",
    Callback = function()
        notify("Teleport", teleportSelected() and "Moved to target" or "No selected enemy found", "map-pin")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Teleport",
    Desc = "Teleport once, follow target, switch after death.",
    Value = false,
    Callback = function(value)
        autoTeleport = value
        if not value then clearHover() end
        notify("Auto Teleport", value and "ON" or "OFF", "navigation")
    end,
})

Tabs.Quest:Section({ Title = "Quest", Icon = "scroll" })

Tabs.Quest:Dropdown({
    Title = "Quest Selector",
    Desc = "Choose boss, rank, or skill quest.",
    Values = questNames,
    Value = selectedQuestName,
    Callback = function(value)
        selectedQuestName = value or selectedQuestName
    end,
})

Tabs.Quest:Button({
    Title = "Start Quest Once",
    Desc = "Goes to selected quest NPC and presses E.",
    Callback = function()
        notify("Quest", startSelectedQuest() and (selectedQuestName .. " requested") or "Quest prompt not found", "scroll")
    end,
})

Tabs.Quest:Toggle({
    Title = "Auto Start Quest",
    Desc = "Loops selected quest start.",
    Value = false,
    Callback = function(value)
        autoStartQuest = value
        notify("Quest", value and "Auto start ON" or "Auto start OFF", "scroll")
    end,
})

Tabs.Holy:Section({ Title = "Holy Chest Quest", Icon = "gift" })

Tabs.Holy:Button({
    Title = "Holy Farm Step Once",
    Desc = "Check active Lv15000 quest: kill if Holy Chest, skip otherwise.",
    Callback = function()
        local ok, err = pcall(runHolyFarmStep)
        notify("Holy Farm", ok and "Step done" or tostring(err), ok and "gift" or "triangle-alert")
    end,
})

Tabs.Tower:Section({ Title = "Boss Tower", Icon = "layers" })

Tabs.Tower:Button({
    Title = "Tower Farm Step Once",
    Desc = "Detects active [Layer.X] boss and engages it.",
    Callback = function()
        local ok, moved, layer, bossName = pcall(engageTowerBoss)
        if ok and moved then
            notify("Tower Farm", "Layer " .. tostring(layer) .. " " .. tostring(bossName), "layers")
        else
            notify("Tower Farm", "No active tower boss", "search")
        end
    end,
})

Tabs.Tower:Toggle({
    Title = "Auto Tower Farm",
    Desc = "Auto detects [Layer.1-100] boss, teleports, and uses selected skills.",
    Value = false,
    Callback = function(value)
        autoTowerFarm = value
        if not value then
            autoTeleport = false
            clearHover()
        end
        notify("Tower Farm", value and "ON" or "OFF", "layers")
    end,
})

Tabs.Tower:Button({
    Title = "Stop Tower Farm",
    Desc = "Disables tower farm and target follow.",
    Callback = function()
        autoTowerFarm = false
        autoTeleport = false
        clearHover()
        notify("Tower Farm", "Stopped", "square")
    end,
})

Tabs.Holy:Toggle({
    Title = "Auto Farm Holy Chest",
    Desc = "Loops Lv15000 quests. Only farms quest with Holy Chest bonus icon.",
    Value = false,
    Callback = function(value)
        autoHolyFarm = value
        if value then
            autoStartQuest = false
        else
            autoTeleport = false
            clearHover()
        end
        notify("Holy Farm", value and "ON" or "OFF", "gift")
    end,
})

Tabs.Holy:Button({
    Title = "Stop Holy Farm",
    Desc = "Disables Holy Farm and target follow.",
    Callback = function()
        autoHolyFarm = false
        autoTeleport = false
        clearHover()
        notify("Holy Farm", "Stopped", "square")
    end,
})

Tabs.Farm:Section({ Title = "Normal Boss Summon", Icon = "skull" })
Tabs.Farm:Dropdown({
    Title = "Normal Boss",
    Desc = "Choose world boss to summon.",
    Values = summonBossNames,
    Value = summonBossName,
    Callback = function(value)
        summonBossName = value or summonBossName
    end,
})

Tabs.Farm:Dropdown({
    Title = "Normal Boss Difficulty",
    Desc = "Choose Hard or Nightmare.",
    Values = { "Hard", "Nightmare" },
    Value = summonBossDifficulty,
    Callback = function(value)
        summonBossDifficulty = value or summonBossDifficulty
    end,
})

Tabs.Farm:Button({
    Title = "Spawn Normal Boss Once",
    Desc = "Summons selected normal boss.",
    Callback = function()
        spawnBossMode = "Summon Boss"
        fireSpawnBossEvent()
        notify("Normal Boss", "Spawn request sent", "skull")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Spawn Normal Boss",
    Desc = "Loops selected normal boss.",
    Value = false,
    Callback = function(value)
        autoSpawnBossEvent = value
        spawnBossMode = "Summon Boss"
        notify("Normal Boss", value and "Auto spawn ON" or "Auto spawn OFF", "skull")
    end,
})

Tabs.Farm:Section({ Title = "Eclipse Summon", Icon = "flame" })

Tabs.Farm:Dropdown({
    Title = "Eclipse Difficulty",
    Desc = "Easy needs x1, Hard x5, Nightmare x10 Crimson Beherit.",
    Values = eclipseDifficulties,
    Value = eclipseDifficulty,
    Callback = function(value)
        eclipseDifficulty = value or eclipseDifficulty
    end,
})

Tabs.Farm:Button({
    Title = "Start Eclipse Once",
    Desc = "Uses altar prompt.",
    Callback = function()
        spawnBossMode = "Eclipse"
        fireSpawnBossEvent()
        notify("Eclipse", eclipseDifficulty .. " request sent", "flame")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Start Eclipse",
    Desc = "Loops selected Eclipse difficulty.",
    Value = false,
    Callback = function(value)
        autoSpawnBossEvent = value
        spawnBossMode = "Eclipse"
        notify("Eclipse", value and "Auto start ON" or "Auto start OFF", "flame")
    end,
})

Tabs.Farm:Section({ Title = "Event Boss Summon", Icon = "flame" })

Tabs.Farm:Dropdown({
    Title = "Event Boss",
    Desc = "440001 Black Swordsman, 440002 Struggler, 440003 Mad Dog.",
    Values = bossEventNames,
    Value = bossEventName,
    Callback = function(value)
        bossEventName = value or bossEventName
    end,
})

Tabs.Farm:Dropdown({
    Title = "Event Boss UID",
    Desc = "Auto uses live BossTask UID when available.",
    Values = bossEventUids,
    Value = bossEventUid,
    Callback = function(value)
        bossEventUid = value or bossEventUid
    end,
})

Tabs.Farm:Button({
    Title = "Spawn Event Boss Once",
    Desc = "Uses Config.Action.SummonWorldBosss._def.",
    Callback = function()
        spawnBossMode = "Boss Event UID"
        fireSpawnBossEvent()
        notify("Event Boss", "Spawn request sent", "flame")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Spawn Selected Boss",
    Desc = "Loops current last-used spawn type.",
    Value = false,
    Callback = function(value)
        autoSpawnBossEvent = value
        notify("Boss Spawn", value and "Auto spawn ON" or "Auto spawn OFF", "skull")
    end,
})

Tabs.Skills:Section({ Title = "Auto Skill", Icon = "zap" })
Tabs.Skills:Dropdown({
    Title = "Skill Keys",
    Desc = "Multi-select skills to auto use.",
    Values = skillKeys,
    Value = { "Z" },
    Multi = true,
    Callback = function(value)
        selectedAutoSkills = {}
        for _, skillKey in ipairs(value or {}) do
            selectedAutoSkills[skillKey] = true
        end
        if nativeAutoSkill then
            autoSkills = {}
            nativeAutoSkill = nil
            for _, skillKey in ipairs(skillKeys) do
                if selectedAutoSkills[skillKey] then
                    autoSkills[skillKey] = true
                    nativeAutoSkill = nativeAutoSkill or skillKey
                end
            end
            rebuildNativeAutoSkill()
        end
        notify("Auto Skill", "Selected " .. tostring(#(value or {})), "zap")
    end,
})

Tabs.Skills:Toggle({
    Title = "Auto Skill",
    Desc = "Auto use selected skills.",
    Value = false,
    Callback = function(value)
        autoSkills = {}
        nativeAutoSkill = nil
        if value then
            for _, skillKey in ipairs(skillKeys) do
                if selectedAutoSkills[skillKey] then
                    autoSkills[skillKey] = true
                    if not isXeno then
                        nativeAutoSkill = nativeAutoSkill or skillKey
                    end
                end
            end
        end
        rebuildNativeAutoSkill()
        notify("Auto Skill", value and "ON" or "OFF", "zap")
    end,
})

Tabs.Settings:Section({ Title = "Delays", Icon = "clock" })
Tabs.Settings:Toggle({
    Title = "Anti Lag",
    Desc = "Disables shadows, particles, trails, beams, textures locally.",
    Value = antiLag,
    Callback = function(value)
        setAntiLag(value)
        notify("Anti Lag", value and "ON" or "OFF", "gauge")
    end,
})

Tabs.Settings:Toggle({
    Title = "Potato Mode",
    Desc = "Max FPS: also kills lights, post effects, water, sounds, low mesh detail.",
    Value = potatoMode,
    Callback = function(value)
        setPotatoMode(value)
        notify("Potato Mode", value and "ON" or "OFF", "cpu")
    end,
})

Tabs.Settings:Toggle({
    Title = "Ultra Potato",
    Desc = "Extreme FPS: hides non-player/non-enemy world parts and GUI clutter locally.",
    Value = ultraPotato,
    Callback = function(value)
        setUltraPotato(value)
        notify("Ultra Potato", value and "ON" or "OFF", "cpu")
    end,
})

Tabs.Settings:Toggle({
    Title = "Safe Mode",
    Desc = "Keeps features running but reduces crash risk.",
    Value = safeMode,
    Callback = function(value)
        safeMode = value
        notify("Safe Mode", value and "ON" or "OFF", "shield")
    end,
})

Tabs.Settings:Toggle({
    Title = "Watchdog",
    Desc = "Keeps loops recoverable and clears stale targets.",
    Value = watchdogEnabled,
    Callback = function(value)
        watchdogEnabled = value
        notify("Watchdog", value and "ON" or "OFF", "activity")
    end,
})

Tabs.Settings:Toggle({
    Title = "Auto Reload Script",
    Desc = "Reloads script after selected minutes if source URL is set.",
    Value = autoReloadEnabled,
    Callback = function(value)
        autoReloadEnabled = value
        notify("Auto Reload", value and "ON" or "OFF", "refresh-cw")
    end,
})

Tabs.Settings:Slider({
    Title = "Auto Reload Minutes",
    Value = { Min = 30, Max = 180, Default = autoReloadMinutes },
    Step = 15,
    Callback = function(value)
        autoReloadMinutes = value
    end,
})

Tabs.Settings:Slider({
    Title = "Auto Teleport Delay",
    Value = { Min = 0.2, Max = 5, Default = autoTeleportDelay },
    Step = 0.1,
    Callback = function(value)
        autoTeleportDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Force Switch After",
    Value = { Min = 0, Max = 30, Default = forceSwitchDelay },
    Step = 1,
    Callback = function(value)
        forceSwitchDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Spawn Boss Event Delay",
    Value = { Min = 1, Max = 10, Default = spawnBossEventDelay },
    Step = 1,
    Callback = function(value)
        spawnBossEventDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Quest Start Delay",
    Value = { Min = 2, Max = 30, Default = questStartDelay },
    Step = 1,
    Callback = function(value)
        questStartDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Holy Farm Delay",
    Value = { Min = 0.5, Max = 20, Default = holyFarmDelay },
    Step = 0.5,
    Callback = function(value)
        holyFarmDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Tower Farm Delay",
    Value = { Min = 0.3, Max = 5, Default = towerFarmDelay },
    Step = 0.1,
    Callback = function(value)
        towerFarmDelay = value
    end,
})

Tabs.Settings:Dropdown({
    Title = "Move Mode",
    Desc = "Teleport = HRP, Part Teleport = every body part, Tween = smooth HRP.",
    Values = { "Teleport", "Part Teleport", "Tween" },
    Value = "Teleport",
    Callback = function(value)
        moveMode = value or "Teleport"
    end,
})

Tabs.Settings:Slider({
    Title = "Tween Speed",
    Value = { Min = 30, Max = 300, Default = tweenSpeed },
    Step = 10,
    Callback = function(value)
        tweenSpeed = value
    end,
})

Tabs.Settings:Slider({
    Title = "Auto Skill Delay",
    Value = { Min = 0.2, Max = 5, Default = autoSkillDelay },
    Step = 0.1,
    Callback = function(value)
        autoSkillDelay = value
    end,
})

Tabs.Settings:Slider({
    Title = "Skill Proximity Range",
    Value = { Min = 5, Max = 150, Default = skillRange },
    Step = 1,
    Callback = function(value)
        skillRange = value
    end,
})

Tabs.Settings:Slider({
    Title = "Hover Behind Distance",
    Value = { Min = 1, Max = 30, Default = hoverDistance },
    Step = 1,
    Callback = function(value)
        hoverDistance = value
    end,
})

Tabs.Settings:Slider({
    Title = "Hover Height",
    Value = { Min = -15, Max = 15, Default = hoverHeight },
    Step = 1,
    Callback = function(value)
        hoverHeight = value
    end,
})

Tabs.Settings:Button({
    Title = "Stop Everything",
    Desc = "Disable auto teleport and all auto skills.",
    Callback = function()
        autoTeleport = false
        autoSpawnBossEvent = false
        autoStartQuest = false
        autoHolyFarm = false
        autoTowerFarm = false
        autoReloadEnabled = false
        running = false
        _G.IndraHubRunning = false
        clearHover()
        autoSkills = {}
        nativeAutoSkill = nil
        pcall(function()
            if type(Player3CController.StopAutoSkill) == "function" then
                Player3CController.StopAutoSkill()
            end
        end)
        notify("Stopped", "Re-run script to refresh toggles visually", "square")
    end,
})

Window:SelectTab(1)
notify("IndraHub", "Loaded. Toggle UI: RightControl", "flame")

task.spawn(function()
    while isSessionActive() do
        _G.IndraHubLastHeartbeat = os.clock()
        task.wait(5)
    end
end)

local descendantAddedConnection = workspace.DescendantAdded:Connect(function(instance)
    if not isSessionActive() then return end
    if antiLag or potatoMode or ultraPotato then
        pcall(function()
            if potatoMode and instance:IsA("Sound") then
                setCachedProperty(instance, "Volume", 0)
                return
            end
            if ultraPotato then
                applyUltraPotatoTo(instance)
                return
            end
            applyAntiLagTo(instance)
        end)
    end
end)
table.insert(_G.IndraHubConnections, descendantAddedConnection)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(autoTeleportDelay, safeMode and 0.9 or 0.5))
        if autoTeleport then
            local ok, err = pcall(teleportSelected)
            if not ok then dumpError("auto teleport", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(safeMode and 0.35 or 0.2)
        if autoTeleport and currentTarget and shouldLeaveCurrentTarget() then
            currentTarget = nil
            lastTeleportedTarget = nil
            targetLowHealthSince = nil
            cachedEnemy = nil
            local ok, err = pcall(teleportSelected)
            if not ok then dumpError("fast retarget", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(spawnBossEventDelay, safeMode and 3 or 1))
        if autoSpawnBossEvent then
            local ok, err = pcall(fireSpawnBossEvent)
            if not ok then dumpError("boss spawn", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(questStartDelay, safeMode and 5 or 2))
        if autoStartQuest then
            local ok, err = pcall(startSelectedQuest)
            if not ok then dumpError("quest start", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(holyFarmDelay, safeMode and 1 or 0.5))
        if autoHolyFarm and os.clock() - lastHolyFarmStep >= math.max(holyFarmDelay, 0.5) then
            lastHolyFarmStep = os.clock()
            local ok, err = pcall(runHolyFarmStep)
            if not ok then dumpError("holy farm", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(towerFarmDelay, safeMode and 0.8 or 0.3))
        if autoTowerFarm then
            local ok, moved, layer, bossName = pcall(engageTowerBoss)
            if not ok then
                dumpError("tower farm", moved)
            elseif moved then
                notify("Tower Farm", "Layer " .. tostring(layer) .. " " .. tostring(bossName), "layers")
            end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(safeMode and 0.75 or 0.6)
        if autoTeleport then
            local ok, err = pcall(hoverBehindSelected)
            if not ok then dumpError("follow", err) end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        lastHeartbeat = os.clock()
        task.wait(math.max(autoSkillDelay, safeMode and 0.8 or 0.5))
        local ok, err = pcall(function()
            if nativeAutoSkill and autoSkills[nativeAutoSkill] and os.clock() - lastNativeRefresh > 5 then
                setControllerAutoSkill(nativeAutoSkill, true)
                lastNativeRefresh = os.clock()
            end

            if hasSelectedEnemyInRange() then
                for _, skillKey in ipairs(skillPriority) do
                    if autoSkills[skillKey] and (skillKey ~= nativeAutoSkill or not hasControllerAutoSkill()) then
                        if isSkillReady(skillKey) then
                            local didSet = false
                            if not isXeno then
                                didSet = setControllerAutoSkill(skillKey, true)
                            end
                            if isXeno or not didSet then
                                useSkill(skillKey)
                            end
                            task.wait(math.max(autoSkillDelay, safeMode and 1.0 or 0.5))

                            if nativeAutoSkill and autoSkills[nativeAutoSkill] then
                                setControllerAutoSkill(nativeAutoSkill, true)
                                lastNativeRefresh = os.clock()
                            elseif didSet then
                                pcall(function()
                                    if type(Player3CController.StopAutoSkill) == "function" then
                                        Player3CController.StopAutoSkill()
                                    end
                                end)
                            end
                        end
                    end
                end
            elseif nativeAutoSkill and autoSkills[nativeAutoSkill] then
                setControllerAutoSkill(nativeAutoSkill, true)
            end
        end)

        if not ok then dumpError("skill rotator", err) end
    end
end)

task.spawn(function()
    while isSessionActive() do
        task.wait(30)
        local ok, err = pcall(function()
            lastCleanup = os.clock()
            lastHeartbeat = lastCleanup
            cachedEnemy = nil
            for instance in pairs(antiLagCache) do
                if not instance or not instance.Parent then
                    antiLagCache[instance] = nil
                end
            end

            if currentTween then
                pcall(function()
                    currentTween:Cancel()
                end)
                currentTween = nil
            end

            if not autoTeleport then
                clearHover()
            end

        end)

        if not ok then dumpError("cleanup", err) end
    end
end)

task.spawn(function()
    while isSessionActive() do
        task.wait(10)
        local ok, err = pcall(function()
            if not watchdogEnabled then return end

            if os.clock() - lastHeartbeat > 45 then
                currentTarget = nil
                cachedEnemy = nil
                targetLowHealthSince = nil
                if currentTween then
                    pcall(function() currentTween:Cancel() end)
                    currentTween = nil
                end
                lastHeartbeat = os.clock()
                notify("Watchdog", "Soft reset targets", "activity")
            end

            if targetDeathConnection and (not currentTarget or not currentTarget.Parent) then
                targetDeathConnection:Disconnect()
                targetDeathConnection = nil
            end

            if autoReloadEnabled and scriptSourceUrl and os.clock() - sessionStartedAt >= autoReloadMinutes * 60 then
                autoReloadEnabled = false
                running = false
                _G.IndraHubRunning = false
                notify("Auto Reload", "Reloading script", "refresh-cw")
                task.wait(1)
                loadstring(game:HttpGet(scriptSourceUrl))()
            end
        end)

        if not ok then dumpError("watchdog", err) end
    end
end)
