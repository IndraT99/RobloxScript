-- Anime Expedition: readable source reconstruction.
-- Constant VM, pool aliases, and verified callback state machines removed.

local IH_AE_Callbacks = {};
local IH_AE_slot_1, IH_AE_slot_2, runtimeSlot, IH_AE_slot_4, IH_AE_slot_5, IH_AE_slot_6, IH_AE_slot_7, IH_AE_slot_8, IH_AE_slot_9, IH_AE_slot_10, stateIndex, IH_AE_slot_12, IH_AE_slot_13, IH_VectorSlot_14, IH_AE_slot_15, IH_AE_slot_16, IH_AE_slot_17, IH_AE_slot_18, IH_AE_slot_19, IH_AE_slot_20, IH_AE_slot_21, IH_AE_slot_22, IH_VectorSlot_23, IH_AE_slot_24, IH_AE_slot_25, IH_AE_slot_26, IH_AE_slot_27, IH_AE_slot_28, IH_AE_slot_29, IH_AE_slot_30, IH_AE_slot_31, IH_VectorSlot_32, IH_AE_slot_33, IH_AE_slot_34, IH_AE_slot_35, IH_AE_slot_36, IH_AE_slot_37, IH_AE_slot_38, controlState, scratchSlot, IH_AE_slot_41, IH_AE_slot_42, IH_AE_slot_43, IH_AE_slot_44, IH_AE_slot_45, IH_AE_slot_46, IH_AE_slot_47, IH_AE_slot_48, scratchValue, IH_AE_slot_50, IH_AE_slot_51, IH_AE_slot_52, IH_AE_slot_53, IH_AE_slot_54, IH_AE_slot_55, IH_AE_slot_57, IH_AE_slot_58;
IH_AE_slot_1 = function(macro)
    if config.Replaying or not macro or type(macro.Actions) ~= "table" then return end
    config.Replaying = true
    config.Status = "Starting replay"
    config.StepText = "Starting replay"
    config.NextText = Am(macro.Actions[1])
    config.NewUnitQueue = {}
    config.ReplayStart = os.clock()
    local refs = {}
    local playerRemote = Ak("GamePlayerData")
    local hotbar = Ak("HotbarData")
    local votePrompt = Ak("VotePrompt")
    for index, action in macro.Actions do
        if not config.Replaying then break end
        if config.Mode == "Time" then yO(config.ReplayStart + (tonumber(action.T) or 0)) end
        config.StepText = Am(action)
        config.NextText = Am(macro.Actions[index + 1])
        local kind = action.Kind
        if kind == "Place" then
            local slot = action.Slot
            yE(playerRemote, hotbar, action, refs, index)
        elseif kind == "Upgrade" then
            yU(playerRemote, action, refs)
        elseif kind == "Sell" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Selling unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer("SellGameUnit", unitId) end)
            end
        elseif kind == "Ability" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Ability on unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer(action.Action, unitId) end)
            end
        elseif kind == "Vote" and votePrompt then
            pcall(function() votePrompt:FireServer("Response", action.Value) end)
        end
    end
    config.Replaying = false
    config.Status = "Replay finished"
    config.StepText = "Replay finished"
    config.NextText = ""
end
IH_AE_slot_2 = nil;
local yZ;
local getUnitData;
local yG;
local getBannerInfo;
local z4;
local zM;
local At;
local zt;
local za;
local zS;
local listAutoSellRarities;
local applyAutoSellSettings;
local autoSummonWorker;
local updateMatchResult;
local yF;
local hasClaimableQuest;
local z3;
local y3;
local getPlayerData;
local enableMaxSummon;
local zs;
local config;
local yL;
local ui;
local Ay;
local yR;
local zy;
local y9;
local claimAvailableRewards;
local zX;
local AE;
local zE;
local Al;
local loadCurrentMacro;
local y2;
local zK;
local yK;
local zr;
local z8;
local y8;
local claimBattlepassRewards;
local yQ;
local zx;
local Ae;
local loadUnitsModule;
local yW;
local AD;
local Ak;
local updateMatchAutomation;
local z1;
local y1;
local zJ;
local exportMacro;
local yJ;
local z7;
local Aw;
local getBannerData;
local handleSummonResult;
local claimCodes;
local yV;
local runMerchantPurchase;
local Aj;
local zI;
local zp;
local z6;
local y6;
local zc;
local zU;
local AB;
local paths;
local Ai;
local zi;
local y_;
local stopSummonUntilTarget;
local getItemData;
local zo;
local runtimeEnv;
local y5;
local zN;
local Au;
local zu;
local Ab;
local zT;
local yT;
local AA;
local Ah;
IH_AE_Callbacks.on_AutoClaimBattlepass = function(r_) config["AutoClaimBattlepass"] = r_;
zX()
end
IH_AE_Callbacks.cframeFromArray = function(values)
    if type(values) ~= "table" or #values < 12 then return nil end
    return CFrame.new(table.unpack(values))
end
IH_AE_Callbacks.hasClaimableQuest = function(j_) local J9, Ka, Kc, Kd, Ke, Kg, Ki, Kj, Kk, Km = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
local Kb = nil;
J9 = j_
if J9 then
J9 = j_["QuestData"]
Ka = J9
if type(Ka) ~= "table" then
return false
else
Kd = false
for j2, j3 in Ka do
Ke = j2;
Kg = j3;
local Kf = Ke;
local Kh = Kg;
local Kc = nil;
J9 = type(Kh) == "table"
if J9 then
J9 = type(Kh["Quests"]) == "table"
if J9 then
Kj = false
for j5, j6 in Kh["Quests"] do
Kk = j5;
Km = j6;
local Kl = Kk;
local Kn = Km;
local Ki = nil;
J9 = type(Kn) == "table"
if J9 then
J9 = Kn["Completed"] == true
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
else
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
end

if Kj then
break
end
end

else

end
else
if J9 then
Kj = false
for j5, j6 in Kh["Quests"] do
Kk = j5;
Km = j6;
local Kl = Kk;
local Kn = Km;
local Ki = nil;
J9 = type(Kn) == "table"
if J9 then
J9 = Kn["Completed"] == true
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
else
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
end

if Kj then
break
end
end

else

end
end

if Kd then
break
end
end
return false
end
else
Ka = J9
if type(Ka) ~= "table" then
return false
else
Kd = false
for j2, j3 in Ka do
Ke = j2;
Kg = j3;
local Kf = Ke;
local Kh = Kg;
local Kc = nil;
J9 = type(Kh) == "table"
if J9 then
J9 = type(Kh["Quests"]) == "table"
if J9 then
Kj = false
for j5, j6 in Kh["Quests"] do
Kk = j5;
Km = j6;
local Kl = Kk;
local Kn = Km;
local Ki = nil;
J9 = type(Kn) == "table"
if J9 then
J9 = Kn["Completed"] == true
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
else
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
end

if Kj then
break
end
end

else

end
else
if J9 then
Kj = false
for j5, j6 in Kh["Quests"] do
Kk = j5;
Km = j6;
local Kl = Kk;
local Kn = Km;
local Ki = nil;
J9 = type(Kn) == "table"
if J9 then
J9 = Kn["Completed"] == true
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
else
if J9 then
J9 = Kn["Claimed"] ~= true
if J9 then
return true
else

end
else
if J9 then
return true
else

end
end
end

if Kj then
break
end
end

else

end
end

if Kd then
break
end
end
return false
end
end

end
IH_AE_Callbacks.simulateRightClick = function()
    local camera = workspace.CurrentCamera
    if not camera then return end
    Ah:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    Ah:Button2Up(Vector2.new(0, 0), camera.CFrame)
    z4 = tick()
end
IH_AE_Callbacks.workspace = workspace
IH_AE_Callbacks.claimAvailableRewards = function()
    if not yT() then return end
    local data = getPlayerData()
    if not data then return end
    if config.AutoClaimQuests and hasClaimableQuest(data) then
        AD("QUEST_CLAIM_ALL_CATEGORIES")
        task.wait(0.3)
    end
    if config.AutoClaimIndex then
        AD("INDEX_CLAIM_ALL")
        task.wait(0.3)
    end
    if config.AutoClaimGroup then
        AD("GROUP_REWARDS_CLAIM")
        task.wait(0.3)
    end
    if config.AutoClaimMilestones then
        AD("CLAIM_LEVEL_MILESTONE")
        task.wait(0.3)
    end
    if config.AutoClaimEvents then
        AD("QUESTBOARD_CLAIM_ALL_MILESTONES")
        task.wait(0.3)
        AD("CLAIM_CALENDAR")
        task.wait(0.3)
    end
    if config.AutoClaimBattlepass then
        claimBattlepassRewards(data)
    end
    if config.AutoClaimCodes then claimCodes(data) end
end
IH_AE_Callbacks.listDifficulties = function(gamemode, mapName)
    local result = {}
    local data = y8(gamemode, mapName)
    if data and type(data.Difficulties) == "table" then
        local keys = {}
        for key in data.Difficulties do table.insert(keys, key) end
        table.sort(keys, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
        for _, key in keys do table.insert(result, tostring(data.Difficulties[key])) end
    end
    if #result == 0 then result[1] = "Normal" end
    return result
end
IH_AE_Callbacks.handleSummonResult = function()
    if not config.SummonUntilUnit or not next(config.SummonTargets) then return end
    local units = getUnitData()
    if not units then return end
    local wanted = {}
    for _, key in config.SummonTargets do wanted[key] = true end
    if zi == nil then
        zi = {}
        for key in units do zi[key] = true end
        return
    end
    local found = false
    for key, unit in units do
        if not zi[key] then
            zi[key] = true
            local asset = type(unit) == "table" and unit.Asset
            if asset and wanted[tostring(asset)] then
                found = true
                local label = zo[tostring(asset)] and zo[tostring(asset)].Display or tostring(asset)
                yF("Summoned " .. label .. "!", 6)
                task.spawn(y9, tostring(asset), unit)
            end
        end
    end
    if found then stopSummonUntilTarget() end
end
IH_AE_Callbacks.periodicRefreshLoop = function()
    while zt do
        pcall(claimAvailableRewards)
        pcall(runMerchantPurchase)
        task.wait(20)
    end
end
IH_AE_Callbacks.loadSelectedMacro = function()
    local ok, message = exportMacro(config.SelectedMacro)
    ui:Notify({
        Title = "AE Macro",
        Description = ok and "Copied to clipboard." or message,
        Time = 4,
    })
end
IH_AE_Callbacks.cframe = CFrame
IH_AE_Callbacks.debugLib = debug
IH_AE_Callbacks.on_MacroName = function(pj) config["MacroName"] = pj;
zX()
end
IH_AE_Callbacks.pcall = pcall
IH_AE_Callbacks.autoSummonWorker = function()
    if yT() or not (config.AutoSummon or config.SummonUntilUnit) then return end
    local banner = config.SummonBanner or "Standard"
    local amount = math.max(1, tonumber(config.SummonAmount) or 1)
    if amount > 1 then enableMaxSummon() end
    local cost = getBannerData(banner) * amount
    if getItemData("Gem") < cost then
        if not zp then yF("Out of Gems — auto summon paused.", 4) end
        zp = true
        return
    end
    zp = false
    AD("BANNER_SUMMON", banner, amount)
    task.spawn(function()
        for _ = 1, 3 do
            task.wait(0.35)
            if not config.AutoSummon then break end
            if config.SummonUntilUnit then z7() end
        end
    end)
end
IH_AE_Callbacks.on_SummonAmount = function(sy) config["SummonAmount"] = sy;
zX()
end
IH_AE_Callbacks.stopSummonUntilTarget = function() local NF = nil;
if config["SummonUntilUnit"] then
config["SummonUntilUnit"] = false
IH_AE_Callbacks.pcall(function() zN["SummonUntilUnit"]:SetValue(false)
end
)
zX()
else
zX()
end

end
IH_AE_Callbacks.isRoundUnitAvailable = function(state)
    return config.RoundStarted and AB(state) ~= nil
end
IH_AE_Callbacks.spawn = task.spawn
IH_AE_Callbacks.displayNameForId = function(id)
    return yQ[id] or tostring(id)
end
IH_AE_Callbacks.on_JoinDifficulty = function(q6) config["Joiner"]["Difficulty"] = q6;
zX()
end
IH_AE_Callbacks.on_AutoBuyMerchant = function(tm) config["AutoBuyMerchant"] = tm;
zX()
end
IH_AE_Callbacks.camera = workspace.CurrentCamera
IH_AE_Callbacks.getMatchOutcome = function(state)
    if not state then return nil end
    local victory = zr()
    if victory then return victory end
    if zI(state) then return "Defeat" end
    local wave = tonumber(state.Wave) or 0
    local maxWave = tonumber(state.MaxWave) or 0
    local enemies = tonumber(state.EnemyCount) or -1
    if maxWave > 0 and wave >= maxWave and enemies == 0
        and tostring(state.Active) ~= "true" then
        return "Victory"
    end
    return nil
end
IH_AE_Callbacks.runMerchantPurchase = function()
    if config.AutoBuyMerchant then zc() end
end
IH_AE_Callbacks.listMaps = function()
    local result = {}
    local maps = yZ and yZ:FindFirstChild("Maps")
    if not maps then return result end
    for _, folder in maps:GetChildren() do
        if #folder:GetChildren() > 0 then table.insert(result, folder.Name) end
    end
    table.sort(result)
    return result
end
IH_AE_Callbacks.wait = task.wait
IH_AE_Callbacks.on_SelectedMacro = function(pz) config["SelectedMacro"] = pz;
zX()
end
IH_AE_Callbacks.on_PlayMacro = function(enabled)
    config.PlayMacro = enabled
    zX()
    if not enabled then
        config.Replaying = false
        return
    end
    if not loadCurrentMacro() then
        ui:Notify({ Title = "AE Macro", Description = "No macro selected.", Time = 3 })
        config.PlayMacro = false
        pcall(function() zN.PlayMacro:SetValue(false) end)
        return
    end
    task.spawn(function()
        while config.PlayMacro and yT() and Ab(zu()) and not config.Replaying
            and not config.ReplayedThisMatch do
            local macro = loadCurrentMacro()
            if not macro then break end
            config.ReplayedThisMatch = true
            IH_AE_slot_1(macro)
            task.wait()
        end
    end)
end
IH_AE_Callbacks.installNetworkHooks = function()
    if IH_AE_slot_2 and IH_AE_slot_2.Parent and zT and zT.Parent then return true end
    pcall(function()
        local playerScripts = Ai:FindFirstChild("PlayerScripts")
        IH_AE_slot_2 = playerScripts and playerScripts:FindFirstChild("FireRelay")
        local nodes = At:FindFirstChild("Nodes")
        local network = nodes and nodes:FindFirstChild("Network")
        local events = network and network:FindFirstChild("NetworkEvents")
        zT = events and events:FindFirstChild("_updateNode")
    end)
    return zT ~= nil and IH_AE_slot_2 ~= nil
end
IH_AE_Callbacks.formatDuration = function(value)
    local seconds = math.floor(tonumber(value) or 0)
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end
IH_AE_Callbacks.unloadUiSafe = function()
    pcall(function() ui:Unload() end)
end
IH_AE_Callbacks.sortedDisplayNames = function()
    local names, ids = {}, {}
    for id, name in yQ do
        table.insert(names, name)
        ids[name] = id
    end
    table.sort(names)
    return names, ids
end
IH_AE_Callbacks.disconnectRecordingHooks = function()
    zt = false
    config.Recording = false
    config.Replaying = false
    runtimeEnv.AeRecordCallback = nil
    y2:Disconnect()
    yJ:Disconnect()
end
IH_AE_Callbacks.on_JoinMap = function(q0) config["Joiner"]["Map"] = q0;
zU()
end
IH_AE_Callbacks.startRecording = function()
    if config.Recording then return end
    config.Current = { Name = "Untitled", Actions = {} }
    config.RecPlacementSeq = 0
    config.LiveIdToIndex = {}
    config.PendingPlace = nil
    config.StepText = "Recording started"
    config.RecordStart = os.clock()
    config.Recording = true
end
IH_AE_Callbacks.vector2New = Vector2.new
IH_AE_Callbacks.claimCodes = function(data)
    local codesFolder = yZ and yZ:FindFirstChild("Codes")
    local ok, module = pcall(require, codesFolder)
    if not ok or type(module) ~= "table" then return end
    local codes = module.Codes or module
    if type(codes) ~= "table" then return end
    local claimed = {}
    if data and type(data.ClaimedCodes) == "table" then
        for _, code in data.ClaimedCodes do claimed[tostring(code)] = true end
    end
    for code, info in codes do
        code = tostring(code)
        if not claimed[code] and type(info) == "table" then
            local now = os.time()
            local from = tonumber(info.ActiveFrom) or 0
            local untilTime = tonumber(info.ActiveUntil) or math.huge
            local role = info.RequiredRole or info.MinimumRole or info.MinumumRole
            if now >= from and now <= untilTime and not z1[code] and not role then
                z6 += 1
                z1[code] = true
                AD("CLAIM_CODE_RequestNODE", z6, code)
                task.wait(0.6)
            end
        end
    end
end
IH_AE_Callbacks.isMatchActive = function(state)
    if not state then return false end
    if tostring(state.Active) == "true" then return true end
    return (tonumber(state.Wave) or 0) >= 1
end
IH_AE_Callbacks.addDiscordButton = function(tab)
    tab:AddLeftGroupbox("Discord"):AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(y1)
            ui:Notify("Copied Discord invite to clipboard")
        end,
    })
end
IH_AE_Callbacks.getBannerInfo = function()
    local object = yZ and yZ:FindFirstChild("BannerInfo")
    local ok, result = pcall(require, object)
    return ok and type(result) == "table" and result or nil
end
IH_AE_Callbacks.loadSettings = function()
    local settings = Aj(paths.SettingsFile)
    if not settings then return end
    config.Mode = settings.Mode or config.Mode
    config.MacroName = settings.MacroName or config.MacroName
    config.SelectedMacro = settings.SelectedMacro
    config.PlayMacro = settings.PlayMacro == true
    config.AutoRetry = settings.AutoRetry == true
    config.AutoStart = settings.AutoStart ~= false
    config.AutoJoin = settings.AutoJoin ~= false
    if type(settings.Joiner) == "table" then config.Joiner = settings.Joiner end
    if type(settings.StageCounts) == "table" then config.StageCounts = settings.StageCounts end
    config.WebhookUrl = settings.WebhookUrl or ""
    config.WebhookEnabled = settings.WebhookEnabled == true
    if type(settings.WebhookItems) == "table" and #settings.WebhookItems > 0 then
        config.WebhookItems = settings.WebhookItems
    end
    config.AutoClaimQuests = settings.AutoClaimQuests == true
    config.AutoClaimEvents = settings.AutoClaimEvents == true
    config.AutoClaimIndex = settings.AutoClaimIndex == true
    config.AutoClaimMilestones = settings.AutoClaimMilestones == true
    config.AutoClaimGroup = settings.AutoClaimGroup == true
    config.AutoClaimCodes = settings.AutoClaimCodes == true
    config.AutoClaimBattlepass = settings.AutoClaimBattlepass == true
    config.AutoSellEnabled = settings.AutoSellEnabled == true
    if type(settings.AutoSellRarities) == "table" then config.AutoSellRarities = settings.AutoSellRarities end
    config.AutoSummon = settings.AutoSummon == true
    config.SummonBanner = settings.SummonBanner or config.SummonBanner
    config.SummonAmount = tonumber(settings.SummonAmount) or config.SummonAmount
    if type(settings.SummonTargets) == "table" then config.SummonTargets = settings.SummonTargets end
    config.SummonUntilUnit = settings.SummonUntilUnit == true
    config.DiscordId = settings.DiscordId or ""
    config.SummonPing = settings.SummonPing == true
    config.GameDropPing = settings.GameDropPing == true
    config.AutoBuyMerchant = settings.AutoBuyMerchant == true
    if type(settings.MerchantItems) == "table" then config.MerchantItems = settings.MerchantItems end
end
IH_AE_Callbacks.unloadUi = function()  ui:Unload()
end
IH_AE_Callbacks.getPlayerData = function()
    local replica = Ak("PlayerData")
    return replica and replica.Data or nil
end
IH_AE_Callbacks.on_GameDropPing = function(tI) config["GameDropPing"] = tI;
zX()
end
IH_AE_Callbacks.stopRecording = function()
    config.Recording = false
    return config.Current
end
IH_AE_Callbacks.resume = coroutine.resume
IH_AE_Callbacks.listBanners = function()
    local result = {}
    local info = getBannerInfo()
    if info and type(info.Banners) == "table" then
        for banner in info.Banners do table.insert(result, tostring(banner)) end
    end
    if #result == 0 then result = { "Standard", "Mini" } end
    table.sort(result)
    return result
end
IH_AE_Callbacks.discordSpoiler = function(value)
    return "||" .. tostring(value) .. "||"
end
IH_AE_Callbacks.on_SummonUntilUnit = function(sX) config["SummonUntilUnit"] = sX;
zX()
end
IH_AE_Callbacks.buildMerchantItemOptions = function()
    local labels, labelToName, nameToLabel = {}, {}, {}
    for _, item in za() do
        table.insert(labels, item.Label)
        labelToName[item.Label] = item.Name
        nameToLabel[item.Name] = item.Label
    end
    return labels, labelToName, nameToLabel
end
IH_AE_Callbacks.updateMatchAutomation = function()
    if not yT() then
        if config.Recording then Al() end
        config.Replaying = false
        config.ReplayedThisMatch = false
        config.RoundStarted = false
        if config.AutoJoin then task.wait(3); yK() end
        return
    end
    local state = zu()
    if zJ(state) then
        if config.Recording then Al() end
        config.Replaying = false
        return
    end
    if not Ab(state) then
        if config.AutoStart then y_() end
        return
    end
    config.RoundStarted = true
    local shouldReplay = config.PlayMacro or config.AutoRetry
    if shouldReplay and not config.Replaying and not config.ReplayedThisMatch then
        local macro = loadCurrentMacro()
        if macro then
            config.ReplayedThisMatch = true
            IH_AE_slot_1(macro)
        end
    end
end
IH_AE_Callbacks.on_AutoRetry = function(rA) config["AutoRetry"] = rA;
zX()
end
IH_AE_Callbacks.requireMapModule = function(gamemode, mapName)
    local maps = yZ and yZ:FindFirstChild("Maps")
    local mode = maps and maps:FindFirstChild(gamemode or "")
    local map = mode and mode:FindFirstChild(mapName or "")
    if not map then return nil end
    local ok, result = pcall(require, map)
    return ok and result or nil
end
IH_AE_Callbacks.isInMap = function()
    local character = Ai.Character
    return (character and character:GetAttribute("InMap") == true) or workspace:FindFirstChild("Map") ~= nil
end
IH_AE_Callbacks.isActiveFlag = function(value)
    return value ~= nil and tostring(value.Active) == "true"
end
IH_AE_Callbacks.on_AutoClaimGroup = function(rX) config["AutoClaimGroup"] = rX;
zX()
end
IH_AE_Callbacks.listAutoSellRarities = function()
    local result, seen = {}, {}
    local data = getPlayerData()
    local standard = data and data.Settings and data.Settings.AutoSell
        and data.Settings.AutoSell.Standard
    if type(standard) == "table" then
        for rarity in standard do
            if not seen[rarity] then
                seen[rarity] = true
                table.insert(result, tostring(rarity))
            end
        end
    end
    for _, rarity in AE do
        if not seen[rarity] then
            seen[rarity] = true
            table.insert(result, rarity)
        end
    end
    return result
end
IH_AE_Callbacks.antiAfkLoop = function()
    while not ui.Unloaded do
        task.wait(2)
        if zN.AntiAfk.Value then
            local sinceInput = tick() - z8
            local sinceClick = tick() - z4
            if sinceInput >= 300 or sinceClick >= 300 then pcall(zx) end
        end
    end
end
IH_AE_Callbacks.on_WebhookEnabled = function(tu) config["WebhookEnabled"] = tu;
zX()
end
IH_AE_Callbacks.runtimeUpdateLoop = function()
    zt = true
    while zt do
        pcall(function() y6(zu()) end)
        pcall(updateMatchResult)
        pcall(updateMatchAutomation)
        pcall(autoSummonWorker)
        pcall(handleSummonResult)
        task.wait(2)
    end
end
IH_AE_Callbacks.exportMacro = function(name)
    if not name then return false, "No macro selected" end
    local path = paths.MacroFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false, "Macro not found" end
    local content = readfile(path)
    if setclipboard then pcall(setclipboard, content) end
    return true, content
end
IH_AE_Callbacks.on_WebhookUrl = function(tr) config["WebhookUrl"] = tr;
zX()
end
IH_AE_Callbacks.isUnitDefeated = function(unit)
    return unit ~= nil and (tonumber(unit.BaseHealth) or 1) <= 0
end
IH_AE_Callbacks.updateMatchResult = function()
    if not config.WebhookEnabled then return end
    if not yT() then
        config.ResultSent = false
        config.MatchActive = false
        config.Snapshot = nil
        config.UnitDamage = {}
        return
    end
    local state = zu()
    if not config.MatchActive then
        local active = zS(state)
        if active then
            config.MatchActive = true
            config.RoundStarted = true
            config.Snapshot = zs()
            config.UnitDamage = {}
        end
    end
    if config.MatchActive then zK() end
    if config.RoundStarted then
        local result = AB(state)
        if result and not config.ResultSent then
            config.ResultSent = true
            local outcome = yW()
            config.StageCounts[outcome] = (config.StageCounts[outcome] or 0) + 1
            zX()
            zM(Ay(result))
        end
    end
end
IH_AE_Callbacks.startMerchantWorker = function()
    task.spawn(zc)
end
IH_AE_Callbacks.describeMacroAction = function(action)
    if not action then return "—" end
    local kind = action.Kind
    if kind == "Place" then
        local name = action.Name or ("slot " .. tostring(action.Slot))
        local cost = action.Cost and " (¥" .. yG(action.Cost) .. ")" or ""
        return "Place " .. name .. cost
    elseif kind == "Upgrade" then
        local name = action.Name or ("unit #" .. tostring(action.Ref))
        local count = (action.Count and action.Count > 1) and (" x" .. tostring(action.Count)) or ""
        return "Upgrade " .. name .. count
    elseif kind == "Sell" then
        return "Sell " .. (action.Name or ("unit #" .. tostring(action.Ref)))
    elseif kind == "Ability" then
        return "Ability " .. (action.Name or ("unit #" .. tostring(action.Ref)))
    elseif kind == "Vote" then
        return "Vote " .. tostring(action.Value)
    end
    return tostring(kind)
end
IH_AE_Callbacks.on_AutoClaimQuests = function(rL) config["AutoClaimQuests"] = rL;
zX()
end
IH_AE_Callbacks.loadItemMetadata = function()
    local object = yZ and yZ:FindFirstChild("Items")
    local ok, items = pcall(require, object)
    if ok and type(items) == "table" then
        for id, item in items do
            if type(item) == "table" then
                yQ[tostring(id)] = item.Name or item.DisplayName or yV[id] or tostring(id)
            end
        end
    end
    for id, display in yV do
        if not yQ[id] then yQ[id] = display end
    end
end
IH_AE_Callbacks.parseAbbreviatedNumber = function(text)
    if type(text) ~= "string" then return nil end
    local cleaned = text:gsub("[^%d%.KkMmBb]", "")
    local value = tonumber(cleaned:match("[%d%.]+"))
    if not value then return nil end
    local suffix = (cleaned:match("%a") or ""):lower()
    if suffix == "k" then return value * 1e3 end
    if suffix == "m" then return value * 1e6 end
    if suffix == "b" then return value * 1e9 end
    return value
end
IH_AE_Callbacks.captureReplicaFromId = function() AA = IH_AE_Callbacks.debugLib["getupvalue"](Ae["FromId"], 1)
end
IH_AE_Callbacks.on_JoinGamemode = function(qY) config["Joiner"]["Gamemode"] = qY;
z3()
end
IH_AE_Callbacks.getBannerData = function(bannerId)
    local info = getBannerInfo()
    local banner = info and type(info.Banners) == "table" and info.Banners[bannerId]
    return tonumber(type(banner) == "table" and banner.Cost) or 0
end
IH_AE_Callbacks.cframeToArray = function(value)
    if typeof(value) ~= "CFrame" then return nil end
    return { value:GetComponents() }
end
IH_AE_Callbacks.cframeNew = CFrame.new
IH_AE_Callbacks.markInputActivity = function()
    z8 = tick()
end
IH_AE_Callbacks.listActs = function(gamemode, mapName)
    local data = y8(gamemode, mapName)
    local acts = {}
    if data and type(data.ActProgression) == "table" then
        for _, act in data.ActProgression do table.insert(acts, tostring(act)) end
    elseif data and type(data.Acts) == "table" then
        for act in data.Acts do table.insert(acts, tostring(act)) end
    end
    if #acts == 0 then table.insert(acts, "Act 1") end
    table.sort(acts)
    return acts
end
IH_AE_Callbacks.on_AutoSummon = function(sB) config["AutoSummon"] = sB;
zX()
end
IH_AE_Callbacks.listSummonUnits = function()
    local values, metadata = {}, {}
    local units = loadUnitsModule()
    if type(units) == "table" then
        for id, unit in units do
            if type(unit) == "table" and type(unit.Summonable) == "table"
                and next(unit.Summonable) then
                local key = tostring(id)
                metadata[key] = {
                    Display = tostring(unit.DisplayName or id),
                    Rarity = tostring(unit.Rarity or "?"),
                }
                table.insert(values, key)
            end
        end
    end
    table.sort(values)
    zo = metadata
    return values
end
IH_AE_Callbacks.on_DiscordId = function(tC) config["DiscordId"] = tC;
zX()
end
IH_AE_Callbacks.on_AutoClaimEvents = function(rO) config["AutoClaimEvents"] = rO;
zX()
end
IH_AE_Callbacks.discordMention = function(enabled)
    local id = tostring(config.DiscordId or ""):gsub("%D", "")
    if enabled and id ~= "" then return "<@" .. id .. ">" end
    return nil
end
IH_AE_Callbacks.on_AutoJoin = function(rG) config["AutoJoin"] = rG;
zX()
end
IH_AE_Callbacks.vector2 = Vector2
IH_AE_Callbacks.maxTrackedStat = function(primary, secondary, keys)
    local maximum = 0
    for _, key in keys do
        local first = primary[key]
        if type(first) == "number" and first > maximum then maximum = first end
        local second = secondary and secondary[key]
        if type(second) == "number" and second > maximum then maximum = second end
    end
    return maximum
end
IH_AE_Callbacks.on_SummonPing = function(tF) config["SummonPing"] = tF;
zX()
end
IH_AE_Callbacks.on_JoinAct = function(q3) config["Joiner"]["Act"] = q3;
zX()
end
IH_AE_Callbacks.on_SummonTargets = function(selected)
    local targets = {}
    for label, enabled in selected do
        if enabled and y5[label] then table.insert(targets, y5[label]) end
    end
    config.SummonTargets = targets
    zX()
end
IH_AE_Callbacks.enableMaxSummon = function()
    if Aw then return end
    Aw = true
    AD("CLIENT_CHANGE_SETTING", "SummonMax", true)
end
IH_AE_Callbacks.on_SummonBanner = function(sv) config["SummonBanner"] = sv;
zX()
end
IH_AE_Callbacks.trackMouseActivity = function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement
        or inputType == Enum.UserInputType.Touch
        or inputType == Enum.UserInputType.Gamepad1 then
        z8 = tick()
    end
end
IH_AE_Callbacks.on_AutoSellRarities = function(rarity, enabled)
    local selected = {}
    for _, value in config.AutoSellRarities do selected[value] = true end
    selected[rarity] = enabled or nil
    local result = {}
    for _, value in listAutoSellRarities() do
        if selected[value] then table.insert(result, value) end
    end
    config.AutoSellRarities = result
    zX()
    task.spawn(applyAutoSellSettings)
end
IH_AE_Callbacks.nextEntry = next
IH_AE_Callbacks.ensureDataFolders = function()
    if not zy then return end
    pcall(function()
        if not isfolder(paths.Folder) then makefolder(paths.Folder) end
        if not isfolder(paths.MacroFolder) then makefolder(paths.MacroFolder) end
    end)
end
IH_AE_Callbacks.getItemData = function(itemId)
    local playerData = getPlayerData()
    local item = playerData and playerData.ItemData and playerData.ItemData[itemId]
    return tonumber(item and item.Amount) or 0
end
IH_AE_Callbacks.on_Mode = function(pC) config["Mode"] = pC;
zX()
end
IH_AE_Callbacks.on_AutoStart = function(rD) config["AutoStart"] = rD;
zX()
end
IH_AE_Callbacks.getUnitData = function()
    local replica = Ak("PlayerData")
    local data = replica and replica.Data
    return data and type(data.UnitData) == "table" and data.UnitData or nil
end
IH_AE_Callbacks.loadUnitsModule = function()
    local object = yZ and yZ:FindFirstChild("Units")
    local ok, result = pcall(require, object)
    return ok and type(result) == "table" and result or nil
end
IH_AE_Callbacks.on_AutoSellEnabled = function(sl)   config["AutoSellEnabled"] = sl;
zX();
local RI = IH_AE_Callbacks.taskLib["spawn"];
IH_AE_Callbacks.spawn(applyAutoSellSettings)
end
IH_AE_Callbacks.on_WebhookItems = function(selected)
    local items = {}
    for label, enabled in selected do
        if enabled and zE[label] then table.insert(items, zE[label]) end
    end
    table.sort(items, function(a, b) return yR(a) < yR(b) end)
    config.WebhookItems = items
    zX()
end
IH_AE_Callbacks.applyAutoSellSettings = function()
    local selected = {}
    if config.AutoSellEnabled then
        for _, rarity in config.AutoSellRarities do selected[rarity] = true end
    end
    for _, rarity in listAutoSellRarities() do
        AD("CHANGE_AUTOSELL_SETTING", rarity, selected[rarity] == true)
        task.wait(0.2)
    end
end
IH_AE_Callbacks.saveSettings = function() y3(paths["SettingsFile"], { ["Mode"] = config["Mode"], ["MacroName"] = config["MacroName"], ["SelectedMacro"] = config["SelectedMacro"], ["PlayMacro"] = config["PlayMacro"], ["AutoRetry"] = config["AutoRetry"], ["AutoStart"] = config["AutoStart"], ["AutoJoin"] = config["AutoJoin"], ["Joiner"] = config["Joiner"], ["StageCounts"] = config["StageCounts"], ["WebhookUrl"] = config["WebhookUrl"], ["WebhookEnabled"] = config["WebhookEnabled"], ["WebhookItems"] = config["WebhookItems"], ["AutoClaimQuests"] = config["AutoClaimQuests"], ["AutoClaimEvents"] = config["AutoClaimEvents"], ["AutoClaimIndex"] = config["AutoClaimIndex"], ["AutoClaimMilestones"] = config["AutoClaimMilestones"], ["AutoClaimGroup"] = config["AutoClaimGroup"], ["AutoClaimCodes"] = config["AutoClaimCodes"], ["AutoClaimBattlepass"] = config["AutoClaimBattlepass"], ["AutoSellEnabled"] = config["AutoSellEnabled"], ["AutoSellRarities"] = config["AutoSellRarities"], ["AutoSummon"] = config["AutoSummon"], ["SummonBanner"] = config["SummonBanner"], ["SummonAmount"] = config["SummonAmount"], ["SummonTargets"] = config["SummonTargets"], ["SummonUntilUnit"] = config["SummonUntilUnit"], ["DiscordId"] = config["DiscordId"], ["SummonPing"] = config["SummonPing"], ["GameDropPing"] = config["GameDropPing"], ["AutoBuyMerchant"] = config["AutoBuyMerchant"], ["MerchantItems"] = config["MerchantItems"] })
end
IH_AE_Callbacks.enum = Enum
IH_AE_Callbacks.testWebhook = function()
    local ok = zM(Ay("Test"))
    ui:Notify({
        Title = "AE Macro",
        Description = ok and "Test sent." or "Failed (check URL / executor http).",
        Time = 4,
    })
end
IH_AE_Callbacks.gameApi = game
IH_AE_Callbacks.saveRecording = function()
    if not config.Recording then return nil end
    local macro = Au()
    if not macro then return nil end
    local name = config.MacroName
    if not name or name == "" then name = "MyMacro" end
    macro.Name = name
    y3(paths.MacroFolder .. "/" .. name .. ".json", macro)
    config.SelectedMacro = name
    config.LastSavedMacro = name
    zX()
    return name, #macro.Actions
end
IH_AE_Callbacks.unpackArgs = unpack
IH_AE_Callbacks.formatNumber = function(value)
    local text = tostring(math.floor(tonumber(value) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (text:gsub("^,", ""))
end
IH_AE_Callbacks.on_AutoClaimMilestones = function(rU) config["AutoClaimMilestones"] = rU;
zX()
end
IH_AE_Callbacks.on_AutoClaimCodes = function(r2) config["AutoClaimCodes"] = r2;
zX()
end
IH_AE_Callbacks.waitWhileReplaying = function(deadline)
    while config.Replaying and os.clock() < deadline do task.wait() end
end
IH_AE_Callbacks.loadCurrentMacro = function()
    if not config.SelectedMacro then return nil end
    return Aj(paths.MacroFolder .. "/" .. config.SelectedMacro .. ".json")
end
IH_AE_Callbacks.on_MerchantItems = function(selected)
    local result = {}
    for name, enabled in selected do
        if enabled and yL[name] then table.insert(result, yL[name]) end
    end
    config.MerchantItems = result
    zX()
end
IH_AE_Callbacks.claimBattlepassRewards = function(data)
    local battlepasses = data and data.BattlepassData
    if type(battlepasses) ~= "table" then return end
    for season in battlepasses do
        AD("CLAIM_ALL_BATTLEPASS_REWARDS", tostring(season))
        task.wait(0.3)
    end
end
IH_AE_Callbacks.ipairsIter = ipairs
IH_AE_Callbacks.on_AutoClaimIndex = function(rR) config["AutoClaimIndex"] = rR;
zX()
end
IH_AE_Callbacks.taskLib = task
IH_AE_Callbacks.listMapChildren = function(mapName)
    local maps = yZ and yZ:FindFirstChild("Maps")
    local folder = maps and maps:FindFirstChild(mapName or "")
    local names = {}
    if not folder then return names end
    for _, child in folder:GetChildren() do table.insert(names, child.Name) end
    table.sort(names)
    return names
end
paths = nil;
yF = nil;
yG = nil;
getItemData = function(itemId)
    local playerData = getPlayerData()
    local item = playerData and playerData.ItemData and playerData.ItemData[itemId]
    return tonumber(item and item.Amount) or 0
end
yJ = nil;
yK = nil;
yL = nil;
getBannerData = function(bannerId)
    local info = getBannerInfo()
    local banner = info and type(info.Banners) == "table" and info.Banners[bannerId]
    return tonumber(type(banner) == "table" and banner.Cost) or 0
end
yQ = nil;
yR = nil;
yT = nil;
yV = nil;
yW = nil;
updateMatchResult = function()
    if not config.WebhookEnabled then return end
    if not yT() then
        config.ResultSent = false
        config.MatchActive = false
        config.Snapshot = nil
        config.UnitDamage = {}
        return
    end
    local state = zu()
    if not config.MatchActive then
        local active = zS(state)
        if active then
            config.MatchActive = true
            config.RoundStarted = true
            config.Snapshot = zs()
            config.UnitDamage = {}
        end
    end
    if config.MatchActive then zK() end
    if config.RoundStarted then
        local result = AB(state)
        if result and not config.ResultSent then
            config.ResultSent = true
            local outcome = yW()
            config.StageCounts[outcome] = (config.StageCounts[outcome] or 0) + 1
            zX()
            zM(Ay(result))
        end
    end
end
yZ = nil;
y_ = nil;
y1 = nil;
y2 = nil;
y3 = function(path, value)
    if not zy then return false end
    local ok, encoded = pcall(function() return An:JSONEncode(value) end)
    if not ok then return false end
    return pcall(function() writefile(path, encoded) end)
end
y5 = nil;
y6 = function(state)
    if not state or not zy then return end
    local signature = tostring(state.CurrentGameState) .. "|" .. tostring(state.Active) .. "|" .. tostring(zI(state))
    if signature == ze then return end
    ze = signature
    local line = os.date("%H:%M:%S") .. " | " .. tostring(state.CurrentGameState)
        .. " | Active=" .. tostring(state.Active) .. " HP=" .. tostring(state.BaseHealth)
        .. " Wave=" .. tostring(state.Wave) .. "/" .. tostring(state.MaxWave)
        .. " Enemies=" .. tostring(state.EnemyCount) .. "\n"
    pcall(function()
        local path = paths.Folder .. "/statelog.txt"
        writefile(path, (isfile(path) and readfile(path) or "") .. line)
    end)
end
y8 = nil;
y9 = function(unitId, unitData)
    if not Ag or config.WebhookUrl == "" then return false end
    local metadata = zo[unitId] or {}
    local display = metadata.Display or unitId
    local rarity = metadata.Rarity or (unitData and unitData.Rarity) or "?"
    local body = An:JSONEncode({
        username = "Euroboros | Anime Expedition",
        content = discordMention(config.SummonPing),
        embeds = {{
            title = "Summon hit!",
            description = "**[USER]** " .. discordSpoiler(Ai.Name)
                .. "\n**[UNIT]** " .. tostring(display) .. " (" .. tostring(unitId) .. ")"
                .. "\n**[RARITY]** " .. tostring(rarity)
                .. "\n**[BANNER]** " .. tostring(config.SummonBanner or "?"),
            color = 16766720,
            footer = { text = tostring(os.time()) },
        }},
    })
    return pcall(function()
        Ag({ Url = config.WebhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end
za = function()
    local result = {}
    local shop = Af(yM)
    if not shop then return result end
    pcall(function()
        local items = shop.Data.Shops[yI] and shop.Data.Shops[yI].Items
        if type(items) ~= "table" then return end
        local history = shop.Data.PurchaseHistory
        history = history and history[yM]
        history = history and history[yI]
        for index, item in items do
            index = tonumber(index)
            if not index then break end
            local name = tostring(item.Name)
            local bought = type(history) == "table" and tonumber(history[name]) or 0
            table.insert(result, {
                Index = index,
                Name = name,
                Label = yR(name),
                Price = tonumber(item.Price) or 0,
                Remaining = (tonumber(item.Stock) or 0) - (bought or 0),
            })
        end
    end)
    table.sort(result, function(a, b) return a.Price < b.Price end)
    return result
end
zc = function()
    if yT() or not next(config.MerchantItems) then return end
    local shop = Af(yM)
    if not shop then return end
    local selected = {}
    for _, name in config.MerchantItems do selected[name] = true end
    local gold = getItemData("Gold")
    local insufficient = false
    for _, item in za() do
        if selected[item.Name] and item.Remaining > 0 then
            if item.Price <= gold then
                pcall(function() shop:FireServer("PurchaseItem", yI, item.Index, 1) end)
                gold -= item.Price
                task.wait(0.4)
            else
                insufficient = true
            end
        end
    end
    if insufficient then yF("Not enough Gold for all selected merchant items.", 4) end
end
handleSummonResult = function()
    if not config.SummonUntilUnit or not next(config.SummonTargets) then return end
    local units = getUnitData()
    if not units then return end
    local wanted = {}
    for _, key in config.SummonTargets do wanted[key] = true end
    if zi == nil then
        zi = {}
        for key in units do zi[key] = true end
        return
    end
    local found = false
    for key, unit in units do
        if not zi[key] then
            zi[key] = true
            local asset = type(unit) == "table" and unit.Asset
            if asset and wanted[tostring(asset)] then
                found = true
                local label = zo[tostring(asset)] and zo[tostring(asset)].Display or tostring(asset)
                yF("Summoned " .. label .. "!", 6)
                task.spawn(y9, tostring(asset), unit)
            end
        end
    end
    if found then stopSummonUntilTarget() end
end
claimAvailableRewards = function()
    if not yT() then return end
    local data = getPlayerData()
    if not data then return end
    if config.AutoClaimQuests and hasClaimableQuest(data) then
        AD("QUEST_CLAIM_ALL_CATEGORIES")
        task.wait(0.3)
    end
    if config.AutoClaimIndex then
        AD("INDEX_CLAIM_ALL")
        task.wait(0.3)
    end
    if config.AutoClaimGroup then
        AD("GROUP_REWARDS_CLAIM")
        task.wait(0.3)
    end
    if config.AutoClaimMilestones then
        AD("CLAIM_LEVEL_MILESTONE")
        task.wait(0.3)
    end
    if config.AutoClaimEvents then
        AD("QUESTBOARD_CLAIM_ALL_MILESTONES")
        task.wait(0.3)
        AD("CLAIM_CALENDAR")
        task.wait(0.3)
    end
    if config.AutoClaimBattlepass then
        claimBattlepassRewards(data)
    end
    if config.AutoClaimCodes then claimCodes(data) end
end
autoSummonWorker = function()
    if yT() or not (config.AutoSummon or config.SummonUntilUnit) then return end
    local banner = config.SummonBanner or "Standard"
    local amount = math.max(1, tonumber(config.SummonAmount) or 1)
    if amount > 1 then enableMaxSummon() end
    local cost = getBannerData(banner) * amount
    if getItemData("Gem") < cost then
        if not zp then yF("Out of Gems — auto summon paused.", 4) end
        zp = true
        return
    end
    zp = false
    AD("BANNER_SUMMON", banner, amount)
    task.spawn(function()
        for _ = 1, 3 do
            task.wait(0.35)
            if not config.AutoSummon then break end
            if config.SummonUntilUnit then z7() end
        end
    end)
end
IH_AE_slot_1 = function(macro)
    if config.Replaying or not macro or type(macro.Actions) ~= "table" then return end
    config.Replaying = true
    config.Status = "Starting replay"
    config.StepText = "Starting replay"
    config.NextText = Am(macro.Actions[1])
    config.NewUnitQueue = {}
    config.ReplayStart = os.clock()
    local refs = {}
    local playerRemote = Ak("GamePlayerData")
    local hotbar = Ak("HotbarData")
    local votePrompt = Ak("VotePrompt")
    for index, action in macro.Actions do
        if not config.Replaying then break end
        if config.Mode == "Time" then yO(config.ReplayStart + (tonumber(action.T) or 0)) end
        config.StepText = Am(action)
        config.NextText = Am(macro.Actions[index + 1])
        local kind = action.Kind
        if kind == "Place" then
            local slot = action.Slot
            yE(playerRemote, hotbar, action, refs, index)
        elseif kind == "Upgrade" then
            yU(playerRemote, action, refs)
        elseif kind == "Sell" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Selling unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer("SellGameUnit", unitId) end)
            end
        elseif kind == "Ability" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Ability on unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer(action.Action, unitId) end)
            end
        elseif kind == "Vote" and votePrompt then
            pcall(function() votePrompt:FireServer("Response", action.Value) end)
        end
    end
    config.Replaying = false
    config.Status = "Replay finished"
    config.StepText = "Replay finished"
    config.NextText = ""
end
zi = nil;
loadCurrentMacro = function()
    if not config.SelectedMacro then return nil end
    return Aj(paths.MacroFolder .. "/" .. config.SelectedMacro .. ".json")
end
hasClaimableQuest = nil;
getBannerInfo = function()
    local object = yZ and yZ:FindFirstChild("BannerInfo")
    local ok, result = pcall(require, object)
    return ok and type(result) == "table" and result or nil
end
local yC, yD, yE, yI, yM, yN, yO, yS, yU, yX, y0, y4, y7, zb, ze, zj, zk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
zo = nil;
zp = nil;
zr = function()
    local playerGui = Ai:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    for _, object in playerGui:GetDescendants() do
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            local text = string.lower(object.Text or "")
            if text:find("victory") or text:find("you win") or text:find("cleared") then
                return "Victory"
            end
            if text:find("defeat") or text:find("you los") or text:find("game over") then
                return "Defeat"
            end
        end
    end
    return nil
end
zs = function()
    local replica = Ak("PlayerData")
    local snapshot = { Items = {}, Level = 0, Exp = 0, Units = {} }
    pcall(function()
        local data = replica.Data
        snapshot.Level = tonumber(data.Level) or 0
        snapshot.Exp = tonumber(data.Exp) or 0
        if type(data.ItemData) == "table" then
            for id, item in data.ItemData do
                if type(item) == "table" and item.Amount then
                    snapshot.Items[tostring(id)] = tonumber(item.Amount) or 0
                end
            end
        end
        if type(data.UnitData) == "table" then
            for id, unit in data.UnitData do
                snapshot.Units[tostring(id)] = tonumber(unit.EXP) or 0
            end
        end
    end)
    return snapshot
end
zt = nil;
zu = nil;
zx = nil;
zy = nil;
applyAutoSellSettings = function()
    local selected = {}
    if config.AutoSellEnabled then
        for _, rarity in config.AutoSellRarities do selected[rarity] = true end
    end
    for _, rarity in listAutoSellRarities() do
        AD("CHANGE_AUTOSELL_SETTING", rarity, selected[rarity] == true)
        task.wait(0.2)
    end
end
runMerchantPurchase = function()
    if config.AutoBuyMerchant then zc() end
end
updateMatchAutomation = function()
    if not yT() then
        if config.Recording then Al() end
        config.Replaying = false
        config.ReplayedThisMatch = false
        config.RoundStarted = false
        if config.AutoJoin then task.wait(3); yK() end
        return
    end
    local state = zu()
    if zJ(state) then
        if config.Recording then Al() end
        config.Replaying = false
        return
    end
    if not Ab(state) then
        if config.AutoStart then y_() end
        return
    end
    config.RoundStarted = true
    local shouldReplay = config.PlayMacro or config.AutoRetry
    if shouldReplay and not config.Replaying and not config.ReplayedThisMatch then
        local macro = loadCurrentMacro()
        if macro then
            config.ReplayedThisMatch = true
            IH_AE_slot_1(macro)
        end
    end
end
zE = nil;
getUnitData = function()
    local replica = Ak("PlayerData")
    local data = replica and replica.Data
    return data and type(data.UnitData) == "table" and data.UnitData or nil
end
stopSummonUntilTarget = nil;
zI = nil;
zJ = nil;
zK = function()
    local replicas
    pcall(function() replicas = debug.getupvalue(Ae.FromId, 1) end)
    if type(replicas) ~= "table" then return end
    for _, replica in replicas do
        local class
        pcall(function() class = tostring(replica.Token or replica.Class) end)
        if class == "GameUnit" then
            pcall(function()
                local data = replica.Data
                local unitData = type(data.UnitData) == "table" and data.UnitData or nil
                local name = tostring((unitData and unitData.Asset) or data.Asset or data.Name or "Unit")
                local id = tostring(replica.Id)
                local kills = Av(data, unitData, yD)
                local damage = Av(data, unitData, AC)
                local level = tonumber(data.Upgrade) or 0
                local old = config.UnitDamage[id]
                if not old or kills >= old.Kills or damage >= old.Damage then
                    config.UnitDamage[id] = {
                        Name = name,
                        Kills = math.max(kills, old and old.Kills or 0),
                        Damage = math.max(damage, old and old.Damage or 0),
                        Level = level,
                    }
                end
            end)
        end
    end
end
getPlayerData = function()
    local replica = Ak("PlayerData")
    return replica and replica.Data or nil
end
zM = function(report)
    if not Ag or config.WebhookUrl == "" then return false end
    local victory = report.Result == "Victory"
    local color = victory and 5763719 or 15548997
    local itemLines = {}
    for _, id in config.WebhookItems do
        table.insert(itemLines, "**" .. yR(id) .. ":** " .. yG(report.Items and report.Items[id] or 0))
    end
    if #itemLines == 0 then itemLines = { "—" } end
    local rewardLines = {}
    for id, value in report.Gained or {} do
        table.insert(rewardLines, "+" .. yG(value.Delta) .. " " .. id .. " [ Total: " .. yG(value.Total) .. " ]")
    end
    if report.ExpGained and report.ExpGained > 0 then
        table.insert(rewardLines, "+" .. yG(report.ExpGained) .. " EXP [ Level " .. tostring(report.Level) .. " ]")
    end
    if report.UnitExpGained and report.UnitExpGained > 0 then
        table.insert(rewardLines, "+" .. yG(report.UnitExpGained) .. " Unit EXP")
    end
    if #rewardLines == 0 then rewardLines = { "—" } end
    local unitLines = {}
    for _, unit in report.Units or {} do
        table.insert(unitLines, "[" .. tostring(unit.Level) .. "] **[" .. unit.Name .. "]**")
        if #unitLines >= 12 then break end
    end
    if #unitLines == 0 then unitLines = { "—" } end
    local match = formatDuration(report.Duration) .. " - Wave " .. tostring(report.Wave)
        .. "\n**[" .. tostring(report.Gamemode or "?") .. "]** **[" .. tostring(report.Difficulty or "?")
        .. "]** - " .. tostring(report.Map or "?") .. ": " .. tostring(report.Act or "?")
        .. " - **[" .. (victory and "VICTORY" or "DEFEAT") .. "]**"
    local body = An:JSONEncode({
        username = "Euroboros | Anime Expedition",
        content = discordMention(config.GameDropPing),
        embeds = {{
            title = "Euroboros | Anime Expedition",
            description = "**<**\n**[USER]** " .. report.User .. "\n**[LEVEL]** " .. tostring(report.Level),
            color = color,
            fields = {
                { name = "Player stats", value = table.concat(itemLines, "\n"), inline = true },
                { name = "Rewards", value = table.concat(rewardLines, "\n"), inline = true },
                { name = "Units", value = table.concat(unitLines, "\n"), inline = false },
                { name = "Match results", value = match, inline = false },
            },
            footer = { text = tostring(os.time()) },
        }},
    })
    return pcall(function()
        Ag({ Url = config.WebhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end
zN = nil;
claimBattlepassRewards = function(data)
    local battlepasses = data and data.BattlepassData
    if type(battlepasses) ~= "table" then return end
    for season in battlepasses do
        AD("CLAIM_ALL_BATTLEPASS_REWARDS", tostring(season))
        task.wait(0.3)
    end
end
ui = nil;
zS = nil;
zT = nil;
zU = function()
    local acts = Ap(config.Joiner.Gamemode, config.Joiner.Map)
    local difficulties = zq(config.Joiner.Gamemode, config.Joiner.Map)
    pcall(function() y7.JoinAct:SetValues(acts) end)
    pcall(function() y7.JoinDifficulty:SetValues(difficulties) end)
    if not table.find(acts, config.Joiner.Act) then config.Joiner.Act = acts[1] end
    if not table.find(difficulties, config.Joiner.Difficulty) then
        local index = tonumber(config.Joiner.Difficulty)
        config.Joiner.Difficulty = index and difficulties[index] or difficulties[1]
    end
    pcall(function() y7.JoinAct:SetValue(config.Joiner.Act) end)
    pcall(function() y7.JoinDifficulty:SetValue(config.Joiner.Difficulty) end)
    zX()
end
claimCodes = function(data)
    local codesFolder = yZ and yZ:FindFirstChild("Codes")
    local ok, module = pcall(require, codesFolder)
    if not ok or type(module) ~= "table" then return end
    local codes = module.Codes or module
    if type(codes) ~= "table" then return end
    local claimed = {}
    if data and type(data.ClaimedCodes) == "table" then
        for _, code in data.ClaimedCodes do claimed[tostring(code)] = true end
    end
    for code, info in codes do
        code = tostring(code)
        if not claimed[code] and type(info) == "table" then
            local now = os.time()
            local from = tonumber(info.ActiveFrom) or 0
            local untilTime = tonumber(info.ActiveUntil) or math.huge
            local role = info.RequiredRole or info.MinimumRole or info.MinumumRole
            if now >= from and now <= untilTime and not z1[code] and not role then
                z6 += 1
                z1[code] = true
                AD("CLAIM_CODE_RequestNODE", z6, code)
                task.wait(0.6)
            end
        end
    end
end
loadUnitsModule = function()
    local object = yZ and yZ:FindFirstChild("Units")
    local ok, result = pcall(require, object)
    return ok and type(result) == "table" and result or nil
end
zX = nil;
IH_AE_slot_2 = nil;
z1 = nil;
z3 = function()
    local maps = Aa(config.Joiner.Gamemode)
    pcall(function() y7.JoinMap:SetValues(maps) end)
    if not table.find(maps, config.Joiner.Map) then config.Joiner.Map = maps[1] end
    pcall(function() y7.JoinMap:SetValue(config.Joiner.Map) end)
    zU()
end
z4 = nil;
runtimeEnv = nil;
z6 = nil;
z7 = nil;
z8 = nil;
config = nil;
local zq, zv, zw, zA, formatDuration, zF, installNetworkHooks, zP, zY, discordMention, z0, z2, Aa = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
Ab = nil;
Ae = nil;
Ah = nil;
Ai = nil;
Aj = function(path)
    if not zy or not isfile(path) then return nil end
    local ok, value = pcall(function() return An:JSONDecode(readfile(path)) end)
    return ok and type(value) == "table" and value or nil
end
Ak = nil;
Al = nil;
exportMacro = function(name)
    if not name then return false, "No macro selected" end
    local path = paths.MacroFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false, "Macro not found" end
    local content = readfile(path)
    if setclipboard then pcall(setclipboard, content) end
    return true, content
end
enableMaxSummon = function()
    if Aw then return end
    Aw = true
    AD("CLIENT_CHANGE_SETTING", "SummonMax", true)
end
At = nil;
Au = nil;
Aw = nil;
Ay = function(result)
    local mapData, gameState, gamePlayerData = Ak("MapData"), Ak("GameState"), Ak("GamePlayerData")
    local current = zs()
    local report = {
        Result = result,
        User = discordSpoiler(Ai.Name),
        Level = current.Level,
        MatchCount = config.StageCounts[yW()] or 0,
        Items = current.Items,
        Gained = {},
    }
    pcall(function()
        local parameters = mapData.Data.Parameters
        report.Gamemode = tostring(parameters.Gamemode)
        report.Map = tostring(parameters.MapName)
        report.Act = tostring(parameters.ActName)
        report.Difficulty = tostring(parameters.Difficulty)
    end)
    pcall(function()
        if gameState then
            report.Duration = gameState.Data.GameTime or gameState.Data.SessionTime
            report.Wave = gameState.Data.Wave
            report.MaxWave = gameState.Data.MaxWave
        end
    end)
    pcall(function()
        if gamePlayerData then
            report.Kills = gamePlayerData.Data.TotalKills
            report.Damage = gamePlayerData.Data.TotalDamage
            report.Takedowns = gamePlayerData.Data.TotalTakedowns
        end
    end)
    local previous = config.Snapshot
    if previous then
        for id, total in current.Items do
            local old = previous.Items[id] or total
            local delta = total - old
            if delta > 0 then report.Gained[id] = { Delta = delta, Total = total } end
        end
        report.ExpGained = current.Exp - previous.Exp
        local unitExp = 0
        for id, total in current.Units do
            local old = previous.Units[id] or total
            unitExp += math.max(0, total - old)
        end
        report.UnitExpGained = unitExp
    end
    local units = {}
    for _, unit in config.UnitDamage do table.insert(units, unit) end
    table.sort(units, function(a, b) return (a.Kills or 0) > (b.Kills or 0) end)
    report.Units = units
    return report
end
listAutoSellRarities = function()
    local result, seen = {}, {}
    local data = getPlayerData()
    local standard = data and data.Settings and data.Settings.AutoSell
        and data.Settings.AutoSell.Standard
    if type(standard) == "table" then
        for rarity in standard do
            if not seen[rarity] then
                seen[rarity] = true
                table.insert(result, tostring(rarity))
            end
        end
    end
    for _, rarity in AE do
        if not seen[rarity] then
            seen[rarity] = true
            table.insert(result, rarity)
        end
    end
    return result
end
AA = nil;
AB = nil;
AD = nil;
AE = nil;
local discordSpoiler, Ad, Af, Ag, Am, An, Ao, Ap, Ar, Av, Ax, AC;
discordSpoiler = function(value)
    return "||" .. tostring(value) .. "||"
end
Ad = nil;
Af = nil;
Ag = nil;
Am = nil;
An = nil;
Ao = nil;
Ap = nil;
Ar = nil;
Av = nil;
Ax = nil;
AC = nil;
stateIndex = nil;
runtimeSlot = nil;
scratchValue = nil;
scratchSlot = nil;
IH_VectorSlot_32 = nil;
IH_VectorSlot_23 = nil;
IH_VectorSlot_14 = function()
    runtimeEnv.AeRecordCallback = function(remote, args)
        if config.Recording and not config.Replaying then Ao(remote, args) end
    end
    if runtimeEnv.AeHookInstalled then return end
    local original
    original = hookfunction(Ae.FireServer, function(self, ...)
        local callback = runtimeEnv.AeRecordCallback
        if callback then pcall(callback, self, table.pack(...)) end
        return original(self, ...)
    end)
    runtimeEnv.AeHookInstalled = true
end
IH_AE_slot_5 = nil;
IH_AE_slot_52 = nil;
IH_AE_slot_43 = nil;
IH_AE_slot_35 = nil;
IH_AE_slot_26 = nil;
IH_AE_slot_17 = nil;
IH_AE_slot_7 = nil;
IH_AE_slot_55 = nil;
IH_AE_slot_46 = nil;
IH_AE_slot_38 = nil;
IH_AE_slot_29 = nil;
IH_AE_slot_20 = nil;
IH_AE_slot_10 = nil;
local A4, Ba;
IH_AE_slot_58 = nil;
IH_AE_slot_48 = nil;
IH_AE_slot_31 = nil;
IH_AE_slot_22 = nil;
IH_AE_slot_13 = nil;
A4 = nil;
IH_AE_slot_51 = nil;
IH_AE_slot_42 = nil;
IH_AE_slot_25 = nil;
Ba = nil;
IH_AE_slot_54 = nil;
IH_AE_slot_45 = nil;
IH_AE_slot_28 = nil;
IH_AE_slot_9 = nil;
IH_AE_slot_47 = nil;
IH_AE_slot_30 = nil;
IH_AE_slot_12 = nil;
IH_AE_slot_50 = nil;
IH_AE_slot_33 = nil;
IH_AE_slot_15 = nil;
IH_AE_slot_53 = nil;
IH_AE_slot_36 = nil;
IH_AE_slot_18 = nil;
controlState = nil;
-- Top-level VM lifted from verified offline state trace.
do
paths = { ["Folder"] = "AeMacro", ["MacroFolder"] = "AeMacro/Macros", ["SettingsFile"] = "AeMacro/settings.json" }
end
do
stateIndex = (stateIndex + 7) % 16
end
do
runtimeSlot = IH_AE_Callbacks.gameApi:GetService("Players")
At = IH_AE_Callbacks.gameApi:GetService("ReplicatedStorage")
An = IH_AE_Callbacks.gameApi:GetService("HttpService")
Ai = runtimeSlot["LocalPlayer"]
Ae = require(At["Shared"]["ReplicaClient"])
end
do
stateIndex = (stateIndex + 3) % 16
end
do
config = { ["Recording"] = false, ["Replaying"] = false, ["RecordStart"] = 0, ["ReplayStart"] = 0, ["Current"] = nil, ["RecPlacementSeq"] = 0, ["LiveIdToIndex"] = {}, ["NewUnitQueue"] = {}, ["Status"] = "Idle", ["StepText"] = "", ["NextText"] = "", ["Mode"] = "Yen", ["MacroName"] = "MyMacro", ["SelectedMacro"] = nil, ["PlayMacro"] = false, ["AutoRetry"] = false, ["AutoStart"] = true, ["AutoJoin"] = true, ["ReplayedThisMatch"] = false, ["LastSavedMacro"] = nil, ["ResultSent"] = false, ["MatchActive"] = false, ["RoundStarted"] = false, ["StageCounts"] = {}, ["Snapshot"] = nil, ["UnitDamage"] = {}, ["Joiner"] = { ["Gamemode"] = "Story", ["Map"] = "SchoolGrounds", ["Act"] = "Act 1", ["Difficulty"] = "Normal" }, ["WebhookUrl"] = "", ["WebhookEnabled"] = false, ["WebhookItems"] = { "Gem", "Gold", "TraitReroll" }, ["AutoClaimQuests"] = false, ["AutoClaimEvents"] = false, ["AutoClaimIndex"] = false, ["AutoClaimMilestones"] = false, ["AutoClaimGroup"] = false, ["AutoClaimCodes"] = false, ["AutoClaimBattlepass"] = false, ["AutoSellEnabled"] = false, ["AutoSellRarities"] = {}, ["AutoSummon"] = false, ["SummonBanner"] = "Standard", ["SummonAmount"] = 1, ["SummonTargets"] = {}, ["SummonUntilUnit"] = false, ["DiscordId"] = "", ["SummonPing"] = false, ["GameDropPing"] = false, ["AutoBuyMerchant"] = false, ["MerchantItems"] = {} }
end
do
stateIndex = (stateIndex + 15) % 16
end
    if runtimeEnv.AeHookInstalled then return end
    local original
    original = hookfunction(Ae.FireServer, function(self, ...)
        local callback = runtimeEnv.AeRecordCallback
        if callback then pcall(callback, self, table.pack(...)) end
        return original(self, ...)
    end)
    runtimeEnv.AeHookInstalled = true
end
end
do
runtimeEnv = getgenv()
end
do
zX, ui, zN, runtimeSlot, stateIndex = nil, nil, nil, nil, nil
stateIndex = 2
end
do
local Tu = (stateIndex * 1 + 0) % 1 + 1
end
do
runtimeSlot = typeof(writefile) == "function"
end
do
zy, AA, ze, scratchSlot, IH_VectorSlot_32, y3, Aj, zA, yN, Ak, zv, yS, z0, zu, yT, yG, Ar, z2, Ax, zP, zF, Ao, IH_VectorSlot_14, yC, Au, Al, zw, yO, yE, yU, Am, IH_AE_slot_1, y_, yK, Ab, zS, zI, zr, AB, zJ, y6, IH_VectorSlot_23, scratchValue = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
scratchValue = 93
end
do
zy = runtimeSlot
end
do
scratchValue = (scratchValue + 6) % 152
end
do
local TD = bit32.rrotate(bit32.bxor(bit32.lrotate(scratchValue, 9), string.byte(tostring(zS))), 6)
end
do
IH_VectorSlot_32 = IH_AE_Callbacks.ensureDataFolders
end
do
scratchValue = (scratchValue + 101) % 152
end
do
y3 = function(path, value)
    if not zy then return false end
    local ok, encoded = pcall(function() return An:JSONEncode(value) end)
    if not ok then return false end
    return pcall(function() writefile(path, encoded) end)
end
Aj = function(path)
    if not zy or not isfile(path) then return nil end
    local ok, value = pcall(function() return An:JSONDecode(readfile(path)) end)
    return ok and type(value) == "table" and value or nil
end
zA = function() local B_ = nil;
local B0 = nil;
B_ = {}
if not zy then
return B_
else
IH_AE_Callbacks.pcall(function() local BS, BU, BV, BW, BY = nil, nil, nil, nil, nil;
local BT = nil;
BV = false
for ad, ae in listfiles(paths["MacroFolder"]) do
BW = ad;
BY = ae;
local BX = BW;
local BZ = BY;
local BU = nil;
BS = string.match(BZ, "([^/\\]+)%.json$")
if BS then
table.insert(B_, BS)
else

end

if BV then
break
end
end

end
)
return B_
end

end
yN = function(ai) local B1, B2, B3, B4 = nil, nil, nil, nil;
local B5 = nil;
if type(ai) ~= "table" then
return false
else
B1, B2 = IH_AE_Callbacks.pcall(function() return ai["Data"]
end
)
B3 = B2 ~= nil
B4 = B1
if B4 then
B4 = B3
return B4
else
return B4
end
end

end
IH_AE_Callbacks.pcall(IH_AE_Callbacks.captureReplicaFromId)
Ak = function(aq) local B8, B9, Ca, Cb, Cd, Ce, Cf, Ch = nil, nil, nil, nil, nil, nil, nil, nil;
local Cc = nil;
if type(AA) ~= "table" then
return nil
else
Ce = false
for as, at in AA do
Cf = as;
Ch = at;
local Cg = Cf;
local Ci = Ch;
local Cd = nil;
B8, B9 = IH_AE_Callbacks.pcall(function() local B6 = nil;
local B7 = nil;
B6 = Ci["Token"]
if B6 then
return tostring(B6)
else
B6 = Ci["Class"]
return tostring(B6)
end

end
)
Ca = B9 == aq
Cb = B8
if Cb then
Cb = Ca
if Cb then
return Ci
else

end
else
if Cb then
return Ci
else

end
end

if Ce then
break
end
end
return nil
end

end
end
do
scratchValue = (scratchValue + 6) % 152
end
do
zv = function(az) local aA = nil;
IH_AE_Callbacks.pcall(function() aA = Ae["FromId"](tonumber(az))
end
);
return aA
end
yS = function(value)
    if type(value) ~= "table" then
        local resolved = zv(value)
        return resolved and yS(resolved) or nil
    end
    local data = value.Data
    local units = data and data.UnitData
    if type(units) == "table" then
        return tostring(units.Asset or units.Name or "Unit")
    end
    return "Unit"
end
z0 = function()
    local replica = Ak("GamePlayerData")
    return tonumber(replica and replica.Data and replica.Data.Yen) or 0
end
end
do
scratchValue = (scratchValue + 6) % 152
end
do
zu = function() local CC;
local CD;
CC = nil;
CD = nil;
local CE = nil;
CC = Ak("GameState")
if not CC then
return nil
else
CD = nil
IH_AE_Callbacks.pcall(function() CD = CC["Data"]
end
)
return CD
end

end
end
do
scratchValue = (scratchValue + 82) % 152
end
do
yT = IH_AE_Callbacks.isInMap
yG = IH_AE_Callbacks.formatNumber
Ar = IH_AE_Callbacks.parseAbbreviatedNumber
z2 = function(layoutOrder)
    local playerGui = Ai:FindFirstChild("PlayerGui")
    local hud = playerGui and playerGui:FindFirstChild("BottomHUD")
    if not hud then return nil end
    for _, child in hud:GetDescendants() do
        if (child:IsA("TextButton") or child:IsA("ImageButton"))
            and child.LayoutOrder == layoutOrder then
            for _, label in child:GetDescendants() do
                if label:IsA("TextLabel") and string.find(label.Text, "¥") then
                    return Ar(label.Text)
                end
            end
        end
    end
    return nil
end
Ax = function(bA) local Dg;
local Df;
Df = nil;
Dg = nil;
local Dh = nil;
Dg = zv(bA)
if not Dg then
return nil
else
Df = nil
IH_AE_Callbacks.pcall(function() local Dd = nil;
local De = nil;
Dd = Dg["Data"]["NextStats"]
if Dd then
Dd = Dg["Data"]["NextStats"]["Cost"]
Df = tonumber(Dd)
else
Df = tonumber(Dd)
end

end
)
return Df
end

end
end
do
scratchValue = (scratchValue + 6) % 152
end
do
zP = IH_AE_Callbacks.cframeToArray
zF = IH_AE_Callbacks.cframeFromArray
IH_AE_Callbacks.pcall(function() Ae["OnNew"]("GameUnit", function(bN) local Do;
Do = nil;
local Dp, Dq, Dr = nil, nil, nil;
local Ds = nil;
if config["Replaying"] then
table.insert(config["NewUnitQueue"], bN)
return
else
if config["Recording"] then
config["RecPlacementSeq"] = config["RecPlacementSeq"] + 1
Do = nil
IH_AE_Callbacks.pcall(function() Do = tostring(bN["Id"])
end
)
if Do then
config["LiveIdToIndex"][Do] = config["RecPlacementSeq"]
Dp = config["PendingPlace"]
if Dp then
Dq = yS(bN)
Dp["Name"] = Dq
Dr = Dp["Cost"]
if Dr then
Dr = " (\194\165" .. yG(Dp["Cost"]) .. ")"
Dp = Dr
if Dp then
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
else
Dp = ""
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
end
else
Dp = Dr
if Dp then
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
else
Dp = ""
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
end
end
else

end
else
Dp = config["PendingPlace"]
if Dp then
Dq = yS(bN)
Dp["Name"] = Dq
Dr = Dp["Cost"]
if Dr then
Dr = " (\194\165" .. yG(Dp["Cost"]) .. ")"
Dp = Dr
if Dp then
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
else
Dp = ""
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
end
else
Dp = Dr
if Dp then
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
else
Dp = ""
config["StepText"] = "Unit Placed : " .. Dq .. Dp
config["PendingPlace"] = nil
end
end
else

end
end
else

end
end

end
)
end
)
Ao = function(b0, b1) local Qo = table.insert;
local Dv;
local Dw;
Dv = nil;
Dw = nil;
local Dx, Dy, Dz, DA, DB, DC, DD, DE, DG, DH, DI = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
local DF = nil;
Dv, Dw = "", nil
IH_AE_Callbacks.pcall(function() local Dt = nil;
local Du = nil;
Dt = b0["Token"]
if Dt then
Dv = tostring(Dt)
Dw = b0["Id"]
else
Dt = b0["Class"]
Dv = tostring(Dt)
Dw = b0["Id"]
end

end
)
Dx = tostring(b1[1])
Dy = os["clock"]() - config["RecordStart"]
Dz = config["Current"]["Actions"]
if Dv == "GamePlayerData" then
if Dx == "PlaceGameUnit" then
DA = z2(b1[2])
DB = { ["Kind"] = "Place", ["T"] = Dy, ["Slot"] = b1[2], ["CFrame"] = zP(b1[3]), ["Yen"] = z0(), ["Cost"] = DA }
Qo(Dz, DB)
config["PendingPlace"] = DB
else
if Dx == "UpgradeGameUnit" then
DA = tostring(b1[2])
DB = config["LiveIdToIndex"][DA]
DC = yS(DA)
DD = Ax(DA)
DA = Dz[#Dz]
DE = DA
if DE then
DE = DA["Kind"] == "Upgrade"
if DE then
DE = DA["Ref"] == DB
if DE then
DA["Count"] = DA["Count"] + 1
DA["TEnd"] = Dy
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
else
Qo(Dz, { ["Kind"] = "Upgrade", ["T"] = Dy, ["Ref"] = DB, ["Count"] = 1, ["Yen"] = z0(), ["Name"] = DC })
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
end
else
if DE then
DA["Count"] = DA["Count"] + 1
DA["TEnd"] = Dy
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
else
Qo(Dz, { ["Kind"] = "Upgrade", ["T"] = Dy, ["Ref"] = DB, ["Count"] = 1, ["Yen"] = z0(), ["Name"] = DC })
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
end
end
else
if DE then
DE = DA["Ref"] == DB
if DE then
DA["Count"] = DA["Count"] + 1
DA["TEnd"] = Dy
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
else
Qo(Dz, { ["Kind"] = "Upgrade", ["T"] = Dy, ["Ref"] = DB, ["Count"] = 1, ["Yen"] = z0(), ["Name"] = DC })
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
end
else
if DE then
DA["Count"] = DA["Count"] + 1
DA["TEnd"] = Dy
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
else
Qo(Dz, { ["Kind"] = "Upgrade", ["T"] = Dy, ["Ref"] = DB, ["Count"] = 1, ["Yen"] = z0(), ["Name"] = DC })
DA = DD
if DA then
DA = " (\194\165" .. yG(DD) .. ")"
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
else
DB = DA
if DB then
config["StepText"] = "Unit Upgraded : " .. DC .. DB
else
DB = ""
config["StepText"] = "Unit Upgraded : " .. DC .. DB
end
end
end
end
end
else
if Dx == "SellGameUnit" then
DA = tostring(b1[2])
DB = yS(DA)
Qo(Dz, { ["Kind"] = "Sell", ["T"] = Dy, ["Ref"] = config["LiveIdToIndex"][DA], ["Name"] = DB })
config["StepText"] = "Unit Sold : " .. DB
else
if string.find(Dx, "Ability") then
DA = tostring(b1[2])
DB = yS(DA)
Qo(Dz, { ["Kind"] = "Ability", ["T"] = Dy, ["Action"] = Dx, ["Ref"] = config["LiveIdToIndex"][DA], ["Name"] = DB })
config["StepText"] = "Ability Used : " .. DB
else

end
end
end
end
else
if Dv == "VotePrompt" and Dx == "Response" then
    Qo(Dz, { Kind = "Vote", T = Dy, Value = b1[2] })
    config.StepText = "Vote : " .. tostring(b1[2])
end
end

end
end
do
scratchValue = (scratchValue + 139) % 152
end
do
IH_VectorSlot_14 = function()
    runtimeEnv.AeRecordCallback = function(remote, args)
        if config.Recording and not config.Replaying then Ao(remote, args) end
    end
    if runtimeEnv.AeHookInstalled then return end
    local original
    original = hookfunction(Ae.FireServer, function(self, ...)
        local callback = runtimeEnv.AeRecordCallback
        if callback then pcall(callback, self, table.pack(...)) end
        return original(self, ...)
    end)
    runtimeEnv.AeHookInstalled = true
end
end
do
scratchValue = (scratchValue + 25) % 152
end
do

local Tj = scratchValue

end
do
yC = IH_AE_Callbacks.startRecording
end
do
scratchValue = (scratchValue + 139) % 152
end
do

Al = IH_AE_Callbacks.saveRecording
end
do
scratchValue = (scratchValue + 25) % 152
end
do
local SG = bit32.rrotate(bit32.bxor(bit32.lrotate(scratchValue, 15), string.byte(tostring(zJ))), 10)
IH_AE_slot_13 = if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(SG, 1870152349), 2664513944), (bit32.bxor(bit32.band(SG, 2424814946), 3928630806))), 2664513944), 3928630806) ~= SG then
1
else
0


end
do
zw = function()
    local data = Ak("GamePlayerData")
    return tonumber(data and data.Data and data.Data.Yen) or 0
end
yO = IH_AE_Callbacks.waitWhileReplaying
yE = function(remote, selectRemote, action, state, index)
    local cframe = zF(action.CFrame)
    if not cframe or not config.Replaying then return end
    if config.Mode ~= "Yen" then
        local cost
        repeat
            cost = z2(action.Slot)
            if cost and z0() < cost then
                config.Status = "Waiting ¥" .. math.floor(cost) .. " to place slot " .. tostring(action.Slot) .. " (have " .. tostring(z0()) .. ")"
                task.wait()
            end
        until not cost or z0() >= cost or not config.Replaying
        if not config.Replaying then return end
    end
    config.Status = "Placing slot " .. tostring(action.Slot)
    config.NewUnitQueue = {}
    if selectRemote then pcall(function() selectRemote:FireServer("SelectSlot", action.Slot) end) end
    pcall(function() remote:FireServer("PlaceGameUnit", action.Slot, cframe) end)
    local balance = zw()
    if balance then state[index] = balance end
end
yU = function(remote, action, refs)
    local unitId = action.Ref and refs[action.Ref]
    if not unitId then return end
    local count = tonumber(action.Count) or 1
    for step = 1, count do
        if not config.Replaying then break end
        local replica = zv(unitId)
        if not replica or not yN(replica) then break end
        local data = replica.Data
        local level = tonumber(data.Upgrade) or 0
        local maxLevel = tonumber(data.MaxUpgrade) or math.huge
        if level >= maxLevel then break end
        local nextStats = data.NextStats
        local cost = tonumber(nextStats and nextStats.Cost) or math.huge
        if config.Mode == "Yen" then
            while z0() < cost and config.Replaying do
                config.Status = "Waiting ¥" .. math.floor(cost) .. " to upgrade unit " .. tostring(unitId) .. " (have " .. tostring(z0()) .. ")"
                task.wait()
            end
            if not config.Replaying then break end
        end
        config.Status = "Upgrading unit " .. tostring(unitId) .. " (" .. step .. "/" .. count .. ")"
        pcall(function() remote:FireServer("UpgradeGameUnit", unitId) end)
        for _ = 1, 180 do
            task.wait()
            replica = zv(unitId)
            data = replica and replica.Data
            local upgraded = tonumber(data and data.Upgrade) or level
            if upgraded > level then break end
            if not config.Replaying or not yN(replica) then break end
        end
    end
end
Am = IH_AE_Callbacks.describeMacroAction
end
do
scratchValue = (scratchValue + 101) % 152
end
do
local SA = bit32.rrotate(bit32.bxor(bit32.lrotate(scratchValue, 25), string.byte(tostring(Aj))), 23)
end
do
IH_AE_slot_1 = function(macro)
    if config.Replaying or not macro or type(macro.Actions) ~= "table" then return end
    config.Replaying = true
    config.Status = "Starting replay"
    config.StepText = "Starting replay"
    config.NextText = Am(macro.Actions[1])
    config.NewUnitQueue = {}
    config.ReplayStart = os.clock()
    local refs = {}
    local playerRemote = Ak("GamePlayerData")
    local hotbar = Ak("HotbarData")
    local votePrompt = Ak("VotePrompt")
    for index, action in macro.Actions do
        if not config.Replaying then break end
        if config.Mode == "Time" then yO(config.ReplayStart + (tonumber(action.T) or 0)) end
        config.StepText = Am(action)
        config.NextText = Am(macro.Actions[index + 1])
        local kind = action.Kind
        if kind == "Place" then
            local slot = action.Slot
            yE(playerRemote, hotbar, action, refs, index)
        elseif kind == "Upgrade" then
            yU(playerRemote, action, refs)
        elseif kind == "Sell" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Selling unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer("SellGameUnit", unitId) end)
            end
        elseif kind == "Ability" then
            local unitId = action.Ref and refs[action.Ref]
            if unitId and playerRemote then
                config.Status = "Ability on unit " .. tostring(unitId)
                pcall(function() playerRemote:FireServer(action.Action, unitId) end)
            end
        elseif kind == "Vote" and votePrompt then
            pcall(function() votePrompt:FireServer("Response", action.Value) end)
        end
    end
    config.Replaying = false
    config.Status = "Replay finished"
    config.StepText = "Replay finished"
    config.NextText = ""
end
y_ = function() local E0;
E0 = nil;
local E1 = nil;
E0 = Ak("VotePrompt")
if E0 then
IH_AE_Callbacks.pcall(function() E0:FireServer("Response", true)
end
)
else

end

end
end
do
scratchValue = (scratchValue + 101) % 152
end
do
yK = function() local E2;
E2 = nil;
local E3 = nil;
E2 = Ak("PlayerGroupData")
if E2 then
IH_AE_Callbacks.pcall(function() E2:FireServer("StartGame")
end
)
return
else
IH_AE_Callbacks.pcall(function()   local eI = require(At["FusionPackage"]["Actions"]);
eI["PartyStartGame"]({ ["Gamemode"] = config["Joiner"]["Gamemode"], ["MapName"] = config["Joiner"]["Map"], ["ActName"] = config["Joiner"]["Act"], ["Difficulty"] = config["Joiner"]["Difficulty"] })
end
)
end

end
end
do
scratchValue = (scratchValue + 82) % 152
end
do


zI = IH_AE_Callbacks.isUnitDefeated
zr = function()
    local playerGui = Ai:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    for _, object in playerGui:GetDescendants() do
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            local text = string.lower(object.Text or "")
            if text:find("victory") or text:find("you win") or text:find("cleared") then
                return "Victory"
            end
            if text:find("defeat") or text:find("you los") or text:find("game over") then
                return "Defeat"
            end
        end
    end
    return nil
end
end
do
scratchValue = (scratchValue + 44) % 152
end
do
scratchValue = (scratchValue + 44) % 152
end
do
y6 = function(state)
    if not state or not zy then return end
    local signature = tostring(state.CurrentGameState) .. "|" .. tostring(state.Active) .. "|" .. tostring(zI(state))
    if signature == ze then return end
    ze = signature
    local line = os.date("%H:%M:%S") .. " | " .. tostring(state.CurrentGameState)
        .. " | Active=" .. tostring(state.Active) .. " HP=" .. tostring(state.BaseHealth)
        .. " Wave=" .. tostring(state.Wave) .. "/" .. tostring(state.MaxWave)
        .. " Enemies=" .. tostring(state.EnemyCount) .. "\n"
    pcall(function()
        local path = paths.Folder .. "/statelog.txt"
        writefile(path, (isfile(path) and readfile(path) or "") .. line)
    end)
end
end
do
scratchValue = (scratchValue + 139) % 152
end
do
zX = IH_AE_Callbacks.saveSettings
end
do
scratchValue = (scratchValue + 63) % 152
end
do
IH_VectorSlot_23 = IH_AE_Callbacks.loadSettings
end
do
scratchValue = (scratchValue + 82) % 152
end
do
scratchSlot = (At:FindFirstChild("Shared"))
end
do

stateIndex = 3
end
do
local Sz = (stateIndex * 1 + 0) % 1 + 1
end
do
scratchSlot = At["Shared"]:FindFirstChild("Information")
end
do

scratchValue = 12
end
do



runtimeSlot = IH_AE_Callbacks.loadItemMetadata
runtimeSlot()
IH_AE_slot_43 = IH_AE_Callbacks.sortedDisplayNames
end
do
scratchValue = (scratchValue + 1) % 32
end
do
yR = IH_AE_Callbacks.displayNameForId
end
do
scratchValue = (scratchValue + 5) % 32
end
do
IH_AE_slot_52 = IH_AE_Callbacks.listMaps
Aa = IH_AE_Callbacks.listMapChildren

Ap = IH_AE_Callbacks.listActs
zq = IH_AE_Callbacks.listDifficulties
end
do
scratchValue = (scratchValue + 25) % 32
end
do
IH_AE_slot_5 = syn["request"]
end
do
stateIndex = IH_AE_slot_5
end
do
Ag = stateIndex
discordSpoiler = function(value)
    return "||" .. tostring(value) .. "||"
end
discordMention = function(enabled)
    local id = tostring(config.DiscordId or ""):gsub("%D", "")
    if enabled and id ~= "" then return "<@" .. id .. ">" end
    return nil
end
formatDuration = function(value)
    local seconds = math.floor(tonumber(value) or 0)
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end
zs = function()
    local replica = Ak("PlayerData")
    local snapshot = { Items = {}, Level = 0, Exp = 0, Units = {} }
    pcall(function()
        local data = replica.Data
        snapshot.Level = tonumber(data.Level) or 0
        snapshot.Exp = tonumber(data.Exp) or 0
        if type(data.ItemData) == "table" then
            for id, item in data.ItemData do
                if type(item) == "table" and item.Amount then
                    snapshot.Items[tostring(id)] = tonumber(item.Amount) or 0
                end
            end
        end
        if type(data.UnitData) == "table" then
            for id, unit in data.UnitData do
                snapshot.Units[tostring(id)] = tonumber(unit.EXP) or 0
            end
        end
    end)
    return snapshot
end
AC = { "TotalDamage", "Damage", "DamageDealt", "DamageDone" }
yD = { "Kills", "Takedowns", "TotalTakedowns" }
Av = IH_AE_Callbacks.maxTrackedStat
zK = function()
    local replicas
    pcall(function() replicas = debug.getupvalue(Ae.FromId, 1) end)
    if type(replicas) ~= "table" then return end
    for _, replica in replicas do
        local class
        pcall(function() class = tostring(replica.Token or replica.Class) end)
        if class == "GameUnit" then
            pcall(function()
                local data = replica.Data
                local unitData = type(data.UnitData) == "table" and data.UnitData or nil
                local name = tostring((unitData and unitData.Asset) or data.Asset or data.Name or "Unit")
                local id = tostring(replica.Id)
                local kills = Av(data, unitData, yD)
                local damage = Av(data, unitData, AC)
                local level = tonumber(data.Upgrade) or 0
                local old = config.UnitDamage[id]
                if not old or kills >= old.Kills or damage >= old.Damage then
                    config.UnitDamage[id] = {
                        Name = name,
                        Kills = math.max(kills, old and old.Kills or 0),
                        Damage = math.max(damage, old and old.Damage or 0),
                        Level = level,
                    }
                end
            end)
        end
    end
end
yW = function() local Im;
local Il;
Il = nil;
Im = nil;
local In = nil;
local Io = nil;
Im = Ak("MapData")
Il = nil
IH_AE_Callbacks.pcall(function()   local ib = Im["Data"]["Parameters"];
Il = tostring(ib["Gamemode"]) .. "|" .. tostring(ib["MapName"]) .. "|" .. tostring(ib["ActName"]) .. "|" .. tostring(ib["Difficulty"])
end
)
In = Il
if In then
return In
else
In = "Unknown"
return In
end

end
Ay = function(result)
    local mapData, gameState, gamePlayerData = Ak("MapData"), Ak("GameState"), Ak("GamePlayerData")
    local current = zs()
    local report = {
        Result = result,
        User = discordSpoiler(Ai.Name),
        Level = current.Level,
        MatchCount = config.StageCounts[yW()] or 0,
        Items = current.Items,
        Gained = {},
    }
    pcall(function()
        local parameters = mapData.Data.Parameters
        report.Gamemode = tostring(parameters.Gamemode)
        report.Map = tostring(parameters.MapName)
        report.Act = tostring(parameters.ActName)
        report.Difficulty = tostring(parameters.Difficulty)
    end)
    pcall(function()
        if gameState then
            report.Duration = gameState.Data.GameTime or gameState.Data.SessionTime
            report.Wave = gameState.Data.Wave
            report.MaxWave = gameState.Data.MaxWave
        end
    end)
    pcall(function()
        if gamePlayerData then
            report.Kills = gamePlayerData.Data.TotalKills
            report.Damage = gamePlayerData.Data.TotalDamage
            report.Takedowns = gamePlayerData.Data.TotalTakedowns
        end
    end)
    local previous = config.Snapshot
    if previous then
        for id, total in current.Items do
            local old = previous.Items[id] or total
            local delta = total - old
            if delta > 0 then report.Gained[id] = { Delta = delta, Total = total } end
        end
        report.ExpGained = current.Exp - previous.Exp
        local unitExp = 0
        for id, total in current.Units do
            local old = previous.Units[id] or total
            unitExp += math.max(0, total - old)
        end
        report.UnitExpGained = unitExp
    end
    local units = {}
    for _, unit in config.UnitDamage do table.insert(units, unit) end
    table.sort(units, function(a, b) return (a.Kills or 0) > (b.Kills or 0) end)
    report.Units = units
    return report
end
zM = function(report)
    if not Ag or config.WebhookUrl == "" then return false end
    local victory = report.Result == "Victory"
    local color = victory and 5763719 or 15548997
    local itemLines = {}
    for _, id in config.WebhookItems do
        table.insert(itemLines, "**" .. yR(id) .. ":** " .. yG(report.Items and report.Items[id] or 0))
    end
    if #itemLines == 0 then itemLines = { "—" } end
    local rewardLines = {}
    for id, value in report.Gained or {} do
        table.insert(rewardLines, "+" .. yG(value.Delta) .. " " .. id .. " [ Total: " .. yG(value.Total) .. " ]")
    end
    if report.ExpGained and report.ExpGained > 0 then
        table.insert(rewardLines, "+" .. yG(report.ExpGained) .. " EXP [ Level " .. tostring(report.Level) .. " ]")
    end
    if report.UnitExpGained and report.UnitExpGained > 0 then
        table.insert(rewardLines, "+" .. yG(report.UnitExpGained) .. " Unit EXP")
    end
    if #rewardLines == 0 then rewardLines = { "—" } end
    local unitLines = {}
    for _, unit in report.Units or {} do
        table.insert(unitLines, "[" .. tostring(unit.Level) .. "] **[" .. unit.Name .. "]**")
        if #unitLines >= 12 then break end
    end
    if #unitLines == 0 then unitLines = { "—" } end
    local match = formatDuration(report.Duration) .. " - Wave " .. tostring(report.Wave)
        .. "\n**[" .. tostring(report.Gamemode or "?") .. "]** **[" .. tostring(report.Difficulty or "?")
        .. "]** - " .. tostring(report.Map or "?") .. ": " .. tostring(report.Act or "?")
        .. " - **[" .. (victory and "VICTORY" or "DEFEAT") .. "]**"
    local body = An:JSONEncode({
        username = "Euroboros | Anime Expedition",
        content = discordMention(config.GameDropPing),
        embeds = {{
            title = "Euroboros | Anime Expedition",
            description = "**<**\n**[USER]** " .. report.User .. "\n**[LEVEL]** " .. tostring(report.Level),
            color = color,
            fields = {
                { name = "Player stats", value = table.concat(itemLines, "\n"), inline = true },
                { name = "Rewards", value = table.concat(rewardLines, "\n"), inline = true },
                { name = "Units", value = table.concat(unitLines, "\n"), inline = false },
                { name = "Match results", value = match, inline = false },
            },
            footer = { text = tostring(os.time()) },
        }},
    })
    return pcall(function()
        Ag({ Url = config.WebhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end
zk = function(content, requestedName)
    if type(content) ~= "string" or content == "" then return false, "Nothing to import" end
    local ok, macro = pcall(function() return An:JSONDecode(content) end)
    if not ok or type(macro) ~= "table" or type(macro.Actions) ~= "table" then
        return false, "Invalid macro"
    end
    local name = requestedName and requestedName ~= "" and requestedName or macro.Name or "Imported"
    macro.Name = name
    y3(paths.MacroFolder .. "/" .. name .. ".json", macro)
    return true, name
end

IH_AE_slot_2, zT = nil, nil
installNetworkHooks = function()
    if IH_AE_slot_2 and IH_AE_slot_2.Parent and zT and zT.Parent then return true end
    pcall(function()
        local playerScripts = Ai:FindFirstChild("PlayerScripts")
        IH_AE_slot_2 = playerScripts and playerScripts:FindFirstChild("FireRelay")
        local nodes = At:FindFirstChild("Nodes")
        local network = nodes and nodes:FindFirstChild("Network")
        local events = network and network:FindFirstChild("NetworkEvents")
        zT = events and events:FindFirstChild("_updateNode")
    end)
    return zT ~= nil and IH_AE_slot_2 ~= nil
end
AD = function(jM, ...) local J1 = nil;
local J2 = nil;
if not installNetworkHooks() then
return false
else
J1 = table.pack(...)
return IH_AE_Callbacks.pcall(function() IH_AE_slot_2:SendMessage("Fire", zT, { ["Type"] = "Post" }, jM, table.unpack(J1, 1, J1["n"]))
end
)
end

end


yF = function(j9, ka) local Kq = nil;
if ui then
IH_AE_Callbacks.pcall(function() local Ko = nil;
local Kp = nil;
Ko = ka
if Ko then
ui:Notify({ ["Title"] = "AE Macro", ["Description"] = j9, ["Time"] = Ko })
else
Ko = 4
ui:Notify({ ["Title"] = "AE Macro", ["Description"] = j9, ["Time"] = Ko })
end

end
)
else

end

end






listAutoSellRarities = function()
    local result, seen = {}, {}
    local data = getPlayerData()
    local standard = data and data.Settings and data.Settings.AutoSell
        and data.Settings.AutoSell.Standard
    if type(standard) == "table" then
        for rarity in standard do
            if not seen[rarity] then
                seen[rarity] = true
                table.insert(result, tostring(rarity))
            end
        end
    end
    for _, rarity in AE do
        if not seen[rarity] then
            seen[rarity] = true
            table.insert(result, rarity)
        end
    end
    return result
end

yI = "GoldShop1"
yM = "GoldShop"
getItemData = function(itemId)
    local playerData = getPlayerData()
    local item = playerData and playerData.ItemData and playerData.ItemData[itemId]
    return tonumber(item and item.Amount) or 0
end
Af = function(lq) local LE, LF, LG, LI = nil, nil, nil, nil;
local LD = nil;
if type(AA) ~= "table" then
return nil
else
LF = false
for ls, lt in AA do
local LC = nil;
LG = ls;
LI = lt;
local LH = LG;
local LJ = LI;
local LE = nil;
LC = false
IH_AE_Callbacks.pcall(function() local Lz, LA = nil, nil;
local LB = nil;
Lz = LJ["Token"]
if Lz then
LA = tostring(Lz) == "ShopData"
if LA then
LA = tostring(LJ["Data"]["DataKey"]) == lq
LC = LA
else
LC = LA
end
else
Lz = LJ["Class"]
LA = tostring(Lz) == "ShopData"
if LA then
LA = tostring(LJ["Data"]["DataKey"]) == lq
LC = LA
else
LC = LA
end
end

end
)
if LC then
return LJ
else

end

if LF then
break
end
end
return nil
end

end
za = function()
    local result = {}
    local shop = Af(yM)
    if not shop then return result end
    pcall(function()
        local items = shop.Data.Shops[yI] and shop.Data.Shops[yI].Items
        if type(items) ~= "table" then return end
        local history = shop.Data.PurchaseHistory
        history = history and history[yM]
        history = history and history[yI]
        for index, item in items do
            index = tonumber(index)
            if not index then break end
            local name = tostring(item.Name)
            local bought = type(history) == "table" and tonumber(history[name]) or 0
            table.insert(result, {
                Index = index,
                Name = name,
                Label = yR(name),
                Price = tonumber(item.Price) or 0,
                Remaining = (tonumber(item.Stock) or 0) - (bought or 0),
            })
        end
    end)
    table.sort(result, function(a, b) return a.Price < b.Price end)
    return result
end
zc = function()
    if yT() or not next(config.MerchantItems) then return end
    local shop = Af(yM)
    if not shop then return end
    local selected = {}
    for _, name in config.MerchantItems do selected[name] = true end
    local gold = getItemData("Gold")
    local insufficient = false
    for _, item in za() do
        if selected[item.Name] and item.Remaining > 0 then
            if item.Price <= gold then
                pcall(function() shop:FireServer("PurchaseItem", yI, item.Index, 1) end)
                gold -= item.Price
                task.wait(0.4)
            else
                insufficient = true
            end
        end
    end
    if insufficient then yF("Not enough Gold for all selected merchant items.", 4) end
end



stateIndex = IH_AE_Callbacks.listBanners

zo = {}
runtimeSlot = IH_AE_Callbacks.listSummonUnits


Ad = IH_AE_Callbacks.gameApi:GetService("VirtualInputManager")
z7 = function() local M8, M9, Na = nil, nil, nil;
local Nb = nil;
local S5 = IH_AE_Callbacks.workspace["CurrentCamera"]
Na = IH_AE_Callbacks.camera
if not Na then
return
else
M8, M9 = Na["ViewportSize"]["X"] / 2, Na["ViewportSize"]["Y"] / 2
IH_AE_Callbacks.pcall(function()   Ad:SendMouseButtonEvent(M8, M9, 0, true, IH_AE_Callbacks.gameApi, 0);
local S9 = IH_AE_Callbacks.taskLib["wait"];
IH_AE_Callbacks.wait();
Ad:SendMouseButtonEvent(M8, M9, 0, false, IH_AE_Callbacks.gameApi, 0)
end
)
end

end




y9 = function(unitId, unitData)
    if not Ag or config.WebhookUrl == "" then return false end
    local metadata = zo[unitId] or {}
    local display = metadata.Display or unitId
    local rarity = metadata.Rarity or (unitData and unitData.Rarity) or "?"
    local body = An:JSONEncode({
        username = "Euroboros | Anime Expedition",
        content = discordMention(config.SummonPing),
        embeds = {{
            title = "Summon hit!",
            description = "**[USER]** " .. discordSpoiler(Ai.Name)
                .. "\n**[UNIT]** " .. tostring(display) .. " (" .. tostring(unitId) .. ")"
                .. "\n**[RARITY]** " .. tostring(rarity)
                .. "\n**[BANNER]** " .. tostring(config.SummonBanner or "?"),
            color = 16766720,
            footer = { text = tostring(os.time()) },
        }},
    })
    return pcall(function()
        Ag({ Url = config.WebhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end


zt = false



local Tb = IH_AE_Callbacks.taskLib["spawn"]
IH_AE_Callbacks.spawn(IH_AE_Callbacks.runtimeUpdateLoop)

IH_AE_Callbacks.spawn(IH_AE_Callbacks.periodicRefreshLoop)
IH_VectorSlot_32()
IH_VectorSlot_23()
IH_VectorSlot_14()
scratchValue = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

do
    runtimeEnv.AeRecordCallback = function(remote, args)
        if config.Recording and not config.Replaying then Ao(remote, args) end
    end
    if not runtimeEnv.AeHookInstalled then
        local original
        original = hookfunction(Ae.FireServer, function(self, ...)
            local callback = runtimeEnv.AeRecordCallback
            if callback then pcall(callback, self, table.pack(...)) end
            return original(self, ...)
        end)
        runtimeEnv.AeHookInstalled = true
    end
end

-- WindUI Setup for IndraHub
local WindUI = nil
pcall(function()
    WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
end)
if not WindUI then return end

local Window = WindUI:CreateWindow({
    Title = "IndraHub - Anime Expedition",
    Icon = "rbxassetid://18657887261",
    Author = "IndraHub",
    Folder = "IndraHub_AnimeExpedition",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local MacroTab = Window:Tab({ Title = "Macro", Icon = "list-video" })
local JoinerTab = Window:Tab({ Title = "Joiner", Icon = "swords" })
local LobbyTab = Window:Tab({ Title = "Lobby", Icon = "gift" })
local WebhookTab = Window:Tab({ Title = "Webhook", Icon = "webhook" })

local statusPara = MacroTab:Paragraph({ Title = "Status", Desc = "Idle" })
local yenPara = MacroTab:Paragraph({ Title = "Economy", Desc = "Yen: --" })
local wavePara = MacroTab:Paragraph({ Title = "Match", Desc = "Wave: -- | State: --" })

-- Macro Configs
MacroTab:Input({
    Title = "Macro name",
    Default = config["MacroName"] or "",
    Callback = IH_AE_Callbacks.on_MacroName
})

MacroTab:Toggle({
    Title = "Record macro",
    Desc = "On = record your actions. Off = save under the name above.",
    Default = false,
    Callback = function(pm)
        if pm then
            yC()
            WindUI:Notify({ Title = "AE Macro", Content = "Recording - play your round.", Duration = 3 })
        else
            local Or, Os = Al()
            if not Or then return end
            config["LastSavedMacro"] = nil
            WindUI:Notify({ Title = "AE Macro", Content = "Saved '" .. Or .. "' (" .. tostring(Os) .. " actions).", Duration = 4 })
        end
    end
})

MacroTab:Dropdown({
    Title = "Selected macro",
    Values = zA() or {"Default"},
    Default = config["SelectedMacro"],
    Callback = IH_AE_Callbacks.on_SelectedMacro
})

MacroTab:Dropdown({
    Title = "Replay Mode",
    Values = { "Yen", "Time" },
    Default = config["Mode"] or "Yen",
    Callback = IH_AE_Callbacks.on_Mode
})

MacroTab:Toggle({
    Title = "Play macro",
    Default = config["PlayMacro"] or false,
    Callback = IH_AE_Callbacks.on_PlayMacro
})

-- Joiner Tab
JoinerTab:Dropdown({ Title = "Gamemode", Values = IH_AE_slot_52() or {"Default"}, Default = config["Joiner"]["Gamemode"], Callback = IH_AE_Callbacks.on_JoinGamemode })
JoinerTab:Dropdown({ Title = "Map", Values = Aa(config["Joiner"]["Gamemode"]) or {"Default"}, Default = config["Joiner"]["Map"], Callback = IH_AE_Callbacks.on_JoinMap })
JoinerTab:Dropdown({ Title = "Act", Values = Ap(config["Joiner"]["Gamemode"], config["Joiner"]["Map"]) or {"Default"}, Default = config["Joiner"]["Act"], Callback = IH_AE_Callbacks.on_JoinAct })
JoinerTab:Dropdown({ Title = "Difficulty", Values = zq(config["Joiner"]["Gamemode"], config["Joiner"]["Map"]) or {"Default"}, Default = config["Joiner"]["Difficulty"], Callback = IH_AE_Callbacks.on_JoinDifficulty })
JoinerTab:Toggle({ Title = "Auto retry", Default = config["AutoRetry"] or false, Callback = IH_AE_Callbacks.on_AutoRetry })
JoinerTab:Toggle({ Title = "Auto start round", Default = config["AutoStart"] or false, Callback = IH_AE_Callbacks.on_AutoStart })
JoinerTab:Toggle({ Title = "Auto join stage", Default = config["AutoJoin"] or false, Callback = IH_AE_Callbacks.on_AutoJoin })

-- Lobby Tab
LobbyTab:Toggle({ Title = "Auto claim quests", Default = config["AutoClaimQuests"] or false, Callback = IH_AE_Callbacks.on_AutoClaimQuests })
LobbyTab:Toggle({ Title = "Auto claim event rewards", Default = config["AutoClaimEvents"] or false, Callback = IH_AE_Callbacks.on_AutoClaimEvents })
LobbyTab:Toggle({ Title = "Auto claim index", Default = config["AutoClaimIndex"] or false, Callback = IH_AE_Callbacks.on_AutoClaimIndex })
LobbyTab:Toggle({ Title = "Auto claim level milestones", Default = config["AutoClaimMilestones"] or false, Callback = IH_AE_Callbacks.on_AutoClaimMilestones })
LobbyTab:Toggle({ Title = "Auto claim group rewards", Default = config["AutoClaimGroup"] or false, Callback = IH_AE_Callbacks.on_AutoClaimGroup })
LobbyTab:Toggle({ Title = "Auto claim battlepass", Default = config["AutoClaimBattlepass"] or false, Callback = IH_AE_Callbacks.on_AutoClaimBattlepass })
LobbyTab:Toggle({ Title = "Auto claim codes", Default = config["AutoClaimCodes"] or false, Callback = IH_AE_Callbacks.on_AutoClaimCodes })
LobbyTab:Toggle({ Title = "Auto sell", Default = config["AutoSellEnabled"] or false, Callback = IH_AE_Callbacks.on_AutoSellEnabled })

LobbyTab:Dropdown({ Title = "Summon Banner", Values = stateIndex() or {"Default"}, Default = config["SummonBanner"], Callback = IH_AE_Callbacks.on_SummonBanner })
LobbyTab:Toggle({ Title = "Auto summon", Default = config["AutoSummon"] or false, Callback = IH_AE_Callbacks.on_AutoSummon })

-- Background Loop
IH_AE_Callbacks.spawn(function()
    while true do
        pcall(function()
            if config.Recording then
                local step = config.StepText ~= "" and config.StepText or "Waiting for an action..."
                statusPara:SetDesc(step .. "\nRecording - " .. #config.Current.Actions .. " actions")
            elseif config.Replaying then
                local step = config.StepText ~= "" and config.StepText or "--"
                local nextStep = config.NextText ~= "" and config.NextText or "--"
                statusPara:SetDesc("Current Step: " .. step .. "\nNext Step: " .. nextStep)
            else
                statusPara:SetDesc("Step: Idle")
            end
            
            yenPara:SetDesc("Yen: " .. tostring(z0()))
            
            local state = zu()
            if state then
                wavePara:SetDesc("Wave: " .. tostring(state.Wave) .. " / " .. tostring(state.MaxWave) .. "\nState: " .. tostring(state.CurrentGameState))
            else
                wavePara:SetDesc("Wave: (lobby)\nState: lobby")
            end
        end)
        task.wait(1)
    end
end)
