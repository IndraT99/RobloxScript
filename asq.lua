if not game:IsLoaded() then
    game.Loaded:Wait()
end
local env = getgenv and getgenv() or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

env.IndraHubAnimeSquadronRunning = true
env.IndraHubAnimeSquadronSession = sessionId
env.IndraHubAnimeSquadronLastHeartbeat = os.clock()
env.IndraHubAnimeSquadronError = nil

local function running()
    return env.IndraHubAnimeSquadronRunning and env.IndraHubAnimeSquadronSession == sessionId
end

task.spawn(function()
    while running() do
        env.IndraHubAnimeSquadronLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function fetch(url, cache)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end
    local data = game:HttpGet(url)
    if type(writefile) == "function" then pcall(function() writefile(cache, data) end) end
    return data
end

local WindUI = loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_AnimeSquadron_WindUI.lua"))()
if not WindUI then
    warn("[IndraHub Anime Squadron] WindUI load failed")
    return
end

local IndraUI = { Options = {} }

local function registerOption(id, option)
    option._callbacks = {}
    function option:OnChanged(callback)
        table.insert(self._callbacks, callback)
    end
    function option:_set(value)
        self.Value = value
        for _, callback in ipairs(self._callbacks) do
            pcall(callback, value)
        end
    end
    IndraUI.Options[id] = option
    return option
end

function IndraUI:Notify(data)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({
                Title = data.Title or "IndraHub",
                Content = data.Content or "",
                Icon = data.Icon or data.Image or "info",
                Duration = data.Duration or 3,
            })
        end)
    else
        print("[IndraHub Anime Squadron] " .. tostring(data.Title) .. ": " .. tostring(data.Content))
    end
end

local function wrapTab(tab)
    local wrapped = {}

    function wrapped:AddParagraph(data)
        local state = { Title = data.Title or "", Content = data.Content or "" }
        if tab.Section then tab:Section({ Title = state.Title, Icon = "info" }) end
        function state:SetDesc(content)
            self.Content = content
        end
        return state
    end

    function wrapped:AddToggle(id, data)
        local option = registerOption(id, { Value = data.Default == true })
        tab:Toggle({
            Title = data.Title or id,
            Desc = data.Description or "",
            Value = option.Value,
            Callback = function(value)
                option:_set(value)
                if data.Callback then data.Callback(value) end
            end,
        })
        return option
    end

    function wrapped:AddDropdown(id, data)
        local default = data.Default
        if type(default) == "number" then default = data.Values and data.Values[default] or default end
        if data.Multi and type(default) ~= "table" then default = {} end
        local option = registerOption(id, { Value = default or (data.Multi and {} or nil), Values = data.Values or {} })
        function option:SetValues(values)
            self.Values = values or {}
        end
        tab:Dropdown({
            Title = data.Title or id,
            Values = option.Values,
            Value = option.Value,
            Multi = data.Multi,
            Callback = function(value)
                option:_set(value)
                if data.Callback then data.Callback(value) end
            end,
        })
        return option
    end

    function wrapped:AddInput(id, data)
        local option = registerOption(id, { Value = data.Default or "" })
        tab:Input({
            Title = data.Title or id,
            Desc = data.Placeholder or "",
            Value = option.Value,
            Placeholder = data.Placeholder or "",
            Callback = function(value)
                option:_set(value)
                if data.Callback then data.Callback(value) end
            end,
        })
        return option
    end

    function wrapped:AddSlider(id, data)
        local option = registerOption(id, { Value = data.Default or data.Min or 0 })
        tab:Slider({
            Title = data.Title or id,
            Desc = data.Description or "",
            Value = { Min = data.Min or 0, Max = data.Max or 100, Default = option.Value },
            Step = data.Rounding == 0 and 1 or 0.1,
            Callback = function(value)
                option:_set(value)
                if data.Callback then data.Callback(value) end
            end,
        })
        return option
    end

    function wrapped:AddButton(data)
        return tab:Button({
            Title = data.Title or "Button",
            Desc = data.Description or "",
            Callback = data.Callback,
        })
    end

    return wrapped
end

function IndraUI:CreateWindow(data)
    if env.IndraHubAnimeSquadronWindow then pcall(function() env.IndraHubAnimeSquadronWindow:Destroy() end) end
    local window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "swords",
        Author = "Anime Squadron",
        Folder = "IndraHubAnimeSquadron",
        Size = data.Size or UDim2.fromOffset(580, 520),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = data.TabWidth or 160,
    })
    env.IndraHubAnimeSquadronWindow = window
    window:SetToggleKey(data.MinimizeKey or Enum.KeyCode.RightControl)
    window:EditOpenButton({ Title = "IndraHub", Icon = "swords", Draggable = true })

    function window:AddTab(tabData)
        return wrapTab(window:Tab({ Title = tabData.Title, Icon = tabData.Icon }))
    end
    function window:SelectTab() end
    return window
end

local IndraConfig = {}
function IndraConfig:SetLibrary() end
function IndraConfig:IgnoreThemeSettings() end
function IndraConfig:SetIgnoreIndexes() end
function IndraConfig:SetFolder() end
function IndraConfig:BuildConfigSection(tab)
    if tab and tab.AddParagraph then tab:AddParagraph({ Title = "Config", Content = "WindUI compatibility mode; settings persist through script files." }) end
end
function IndraConfig:Load() end
function IndraConfig:Save() end

local IndraInterface = {}
function IndraInterface:SetLibrary() end
function IndraInterface:SetFolder() end
function IndraInterface:BuildInterfaceSection(tab)
    if tab and tab.AddParagraph then tab:AddParagraph({ Title = "Interface", Content = "IndraHub WindUI | Toggle: LeftControl" }) end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local LobbyID = 71132543521245
local isLobby = (game.PlaceId == LobbyID)

local function get_cap_string(mode, world, act, item)
    return string.lower(mode .. " " .. world .. " " .. tostring(act) .. " " .. item):gsub(" ", "_")
end

local traitMaps = {}

if isLobby then
    local succ, Worlds = pcall(function() return require(Players.LocalPlayer.PlayerScripts.Client.Play.Worlds) end)
    if succ and Worlds then
        for worldId, world in pairs(Worlds) do
            if type(worldId) == "number" and world.Rewards then
                for mode, diffs in pairs(world.Rewards) do
                    if mode == "Challenge" or mode == "Raid" then
                        local diffsToCheck = diffs["Normal"] or diffs["Hard"]
                        if diffsToCheck then
                            for act, drops in pairs(diffsToCheck) do
                                for dropName, dropData in pairs(drops) do
                                    if dropName == "Trait Shards" and dropData.cap then
                                        table.insert(traitMaps, {
                                            world = world.name,
                                            mode = mode,
                                            act = act,
                                            cap = dropData.cap
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(traitMaps, function(a, b)
            if a.mode == b.mode then return a.world < b.world end
            return a.mode < b.mode
        end)
        
        if isfile and writefile then
            pcall(function()
                writefile("AnimeSquadron_MapsCache.json", HttpService:JSONEncode(traitMaps))
            end)
        end
    end
else
    if isfile and readfile and isfile("AnimeSquadron_MapsCache.json") then
        local succ, data = pcall(function() return HttpService:JSONDecode(readfile("AnimeSquadron_MapsCache.json")) end)
        if succ and type(data) == "table" then
            traitMaps = data
        end
    end
end

local Window = IndraUI:CreateWindow({
    Title = "IndraHub",
    SubTitle = "Anime Squadron",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "play" }),
    Sniper = Window:AddTab({ Title = "Challenge Sniper", Icon = "target" }),
    Maps = Window:AddTab({ Title = "Trait Maps", Icon = "map" }),
    Ingame = Window:AddTab({ Title = "Ingame Helper", Icon = "swords" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "link" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = IndraUI.Options

local itemsList = {"Trait Shards", "Reroll Cubes", "Perfect Cubes", "Gems", "Gold"}

Tabs.Sniper:AddParagraph({ Title = "Sniper Configuration", Content = "Used in Lobby. Checked with highest priority." })

local Toggle1d = Tabs.Sniper:AddToggle("AutoJoin1d", { Title = "Enable Daily Challenge (1d)", Default = false })
local Toggle30m = Tabs.Sniper:AddToggle("AutoJoin30m", { Title = "Enable Regular Challenge (30m)", Default = false })

local itemDropdown = Tabs.Sniper:AddDropdown("TargetItem30m", {
    Title = "Target Items (Regular 30m)",
    Values = itemsList,
    Multi = true,
    Default = {},
})

if isLobby then
    task.spawn(function()
        local get_challenges = ReplicatedStorage.Remotes.Play:WaitForChild("get_challenges", 5)
        local send_challenges = ReplicatedStorage.Remotes.Play:WaitForChild("send_challenges", 5)
        
        if get_challenges and send_challenges then
            local succ, data = pcall(function() return get_challenges:InvokeServer() end)
            if succ and type(data) == "table" then
                for chType, chData in pairs(data) do
                    if chData.rewards then
                        for rewardName, _ in pairs(chData.rewards) do
                            if not table.find(itemsList, rewardName) then
                                table.insert(itemsList, rewardName)
                            end
                        end
                    end
                end
                itemDropdown:SetValues(itemsList)
            end
            
            send_challenges.OnClientEvent:Connect(function(data)
                if type(data) == "table" then
                    for chType, chData in pairs(data) do
                        if chData.rewards then
                            for rewardName, _ in pairs(chData.rewards) do
                                if not table.find(itemDropdown.Values, rewardName) then
                                    local current = itemDropdown.Values
                                    table.insert(current, rewardName)
                                    itemDropdown:SetValues(current)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local mapConfigs = {}
Tabs.Maps:AddParagraph({ Title = "Configuration Guide", Content = "Enter 'Priority' (lower number = higher priority). Enter 0 to skip." })

if #traitMaps == 0 then
    Tabs.Maps:AddParagraph({ Title = "No Data Found", Content = "Execute this script in the Lobby at least once to cache Map data!" })
else
    for i, map in ipairs(traitMaps) do
        local capStr = get_cap_string(map.mode, map.world, map.act, "Trait Shards")
        local titleStr = string.format("[%s] %s (Act %d)", map.mode, map.world, map.act)
        
        local paragraph = Tabs.Maps:AddParagraph({ Title = titleStr, Content = "Tracking current limit." })
        
        local input = Tabs.Maps:AddInput("Priority_"..i, {
            Title = "Priority (0 = Skip)",
            Default = tostring(i),
            Numeric = true,
            Finished = false,
        })
        
        local diff = Tabs.Maps:AddDropdown("Diff_"..i, {
            Title = "Difficulty",
            Values = {"Normal", "Hard"},
            Multi = false,
            Default = 1,
        })
        
        mapConfigs[i] = {
            mapData = map,
            capStr = capStr,
            paragraph = paragraph
        }
    end
end

Tabs.Ingame:AddParagraph({ Title = "Ingame Utilities", Content = "Only active during a match." })
local ToggleLeave = Tabs.Ingame:AddToggle("AutoLeaveToggle", { Title = "ENABLE Auto Leave (On Max Limit/Cant Replay)", Default = false })
local ToggleReplay = Tabs.Ingame:AddToggle("AutoReplayToggle", { Title = "ENABLE Auto Replay", Default = false })

Tabs.Ingame:AddParagraph({ Title = "Challenge Sniper Sync", Content = "Automatically return to lobby around XX:00 and XX:30 to check new challenges." })
local ToggleSniperSync = Tabs.Ingame:AddToggle("AutoSniperSync", { Title = "ENABLE Sniper Sync", Default = false })
local DropdownSniperSyncMode = Tabs.Ingame:AddDropdown("SniperSyncMode", {
    Title = "Sync Mode",
    Values = {"Safe (At EndScreen)", "Instant (Abort Match)"},
    Multi = false,
    Default = 1,
})



if isLobby then
    Tabs.AutoFarm:AddParagraph({ Title = "Status: LOBBY", Content = "Master Auto Farm system is ready." })
else
    Tabs.AutoFarm:AddParagraph({ Title = "Status: INGAME", Content = "NOTE: Auto Farm functions will NOT operate while in-game. It will resume automatically in the Lobby." })
end

local SessionStats = {
    Date = os.date("%Y-%m-%d"),
    Matches = 0,
    TraitShards = 0, PerfectCubes = 0, RerollCubes = 0,
    StartTrait = -1, StartPerfect = -1, StartReroll = -1
}

local StatsParagraph = Tabs.AutoFarm:AddParagraph({
    Title = "Session Stats (Farmed Today)",
    Content = "Matches Played: 0\nTrait Shards: 0 + 0\nPerfect Cubes: 0 + 0\nReroll Cubes: 0 + 0"
})

local function saveSessionStats()
    if writefile then
        pcall(function() writefile("AnimeSquadron_DailyStats.json", game:GetService("HttpService"):JSONEncode(SessionStats)) end)
    end
end

local function updateStatsUI()
    if StatsParagraph then
        local t_base = SessionStats.StartTrait == -1 and 0 or SessionStats.StartTrait
        local p_base = SessionStats.StartPerfect == -1 and 0 or SessionStats.StartPerfect
        local r_base = SessionStats.StartReroll == -1 and 0 or SessionStats.StartReroll
        StatsParagraph:SetDesc(string.format("Matches Played: %d\nTrait Shards: %d + %d\nPerfect Cubes: %d + %d\nReroll Cubes: %d + %d", SessionStats.Matches, t_base, SessionStats.TraitShards, p_base, SessionStats.PerfectCubes, r_base, SessionStats.RerollCubes))
    end
end

local function resetSessionStats()
    SessionStats.Matches = 0
    SessionStats.TraitShards = 0
    SessionStats.PerfectCubes = 0
    SessionStats.RerollCubes = 0
    SessionStats.StartTrait = -1
    SessionStats.StartPerfect = -1
    SessionStats.StartReroll = -1
    SessionStats.Date = os.date("%Y-%m-%d")
    saveSessionStats()
    updateStatsUI()
end

local function loadSessionStats()
    if isfile and readfile and isfile("AnimeSquadron_DailyStats.json") then
        local s, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile("AnimeSquadron_DailyStats.json")) end)
        if s and type(res) == "table" then
            if res.Date == os.date("%Y-%m-%d") then
                SessionStats.Matches = res.Matches or 0
                SessionStats.TraitShards = res.TraitShards or 0
                SessionStats.PerfectCubes = res.PerfectCubes or 0
                SessionStats.RerollCubes = res.RerollCubes or 0
                SessionStats.StartTrait = res.StartTrait or -1
                SessionStats.StartPerfect = res.StartPerfect or -1
                SessionStats.StartReroll = res.StartReroll or -1
                updateStatsUI()
            else
                resetSessionStats()
            end
        end
    end
end
loadSessionStats()
local friendToggle = Tabs.AutoFarm:AddToggle("FriendsOnly", { Title = "Friends Only", Default = true })
local AutoClaimDaily = Tabs.AutoFarm:AddToggle("AutoClaimDaily", { Title = "Auto Claim Daily Rewards", Default = false })
local AutoClaimBundle = Tabs.AutoFarm:AddToggle("AutoClaimBundle", { Title = "Auto Claim Free Bundle", Default = false })
local AutoToggle = Tabs.AutoFarm:AddToggle("MasterAutoRun", { Title = "ENABLE MASTER AUTO FARM", Default = false })

Tabs.Webhook:AddParagraph({ Title = "Discord Webhook", Content = "Automatic status reporter" })
local WebhookURL = Tabs.Webhook:AddInput("WebhookURL", { Title = "Webhook URL", Default = "", Numeric = false, Finished = false, Placeholder = "https://discord.com/api/webhooks/..." })
local WebhookOnDrop = Tabs.Webhook:AddToggle("WebhookOnDrop", { Title = "Send on Item Drop (Traits/Cubes)", Default = false })
local WebhookOnMatchEnd = Tabs.Webhook:AddToggle("WebhookOnMatchEnd", { Title = "Send on Match End (Win/Loss)", Default = false })
local WebhookOnInterval = Tabs.Webhook:AddToggle("WebhookOnInterval", { Title = "Send on Interval", Default = false })
local WebhookInterval = Tabs.Webhook:AddSlider("WebhookInterval", { Title = "Interval (Minutes)", Description = "How often to send", Default = 10, Min = 1, Max = 60, Rounding = 0 })

IndraConfig:SetLibrary(IndraUI)
IndraInterface:SetLibrary(IndraUI)
IndraConfig:IgnoreThemeSettings()
IndraConfig:SetIgnoreIndexes({})
IndraInterface:SetFolder("IndraHubAnimeSquadron")
IndraConfig:SetFolder("IndraHubAnimeSquadron/AutoFarm")

IndraInterface:BuildInterfaceSection(Tabs.Settings)
IndraConfig:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

pcall(function()
    IndraConfig:Load("AutoSave")
end)

local saveDebounce = false
for name, option in pairs(IndraUI.Options) do
    option:OnChanged(function()
        if not saveDebounce then
            saveDebounce = true
            task.delay(2, function()
                pcall(function()
                    IndraConfig:Save("AutoSave")
                end)
                saveDebounce = false
            end)
        end
    end)
end

if isLobby then
    print("[UniversalAutoFarm] LOBBY mode initialized")
    
    local create_room = ReplicatedStorage.Remotes.Play:WaitForChild("create_room", 10)
    local start_remote = ReplicatedStorage.Remotes.Play:WaitForChild("start", 10)
    local get_challenges = ReplicatedStorage.Remotes.Play:WaitForChild("get_challenges", 10)
    
    local dailyCompleted = false
    local lastDailyWorld = ""
    local lastDailyAct = -1
    
    local util
    pcall(function() util = require(Players.LocalPlayer.PlayerScripts.Client.Utility) end)
    
    local function joinRoom(act, diff, mode, world, rewards, capStr, maxCap)
        if capStr and maxCap and isfile and writefile then
            pcall(function()
                local dataToSave = {
                    capStr = capStr,
                    maxCap = maxCap,
                    worldName = world
                }
                writefile("AnimeSquadron_CurrentTarget.json", HttpService:JSONEncode(dataToSave))
            end)
        end

        local success, err = create_room:InvokeServer({
            boosted = true,
            act = act,
            difficulty = diff,
            mode = mode,
            rewards = rewards,
            only_friends = Options.FriendsOnly.Value,
            world = world
        })
        
        if success then
            task.wait(1.5)
            pcall(function() start_remote:InvokeServer() end)
            task.wait(10)
            return true
        else
            return false, err
        end
    end
    
    local function getSortedValidTraitMaps()
        local validMaps = {}
        for i, cfg in ipairs(mapConfigs) do
            local prio = tonumber(Options["Priority_"..i].Value) or 0
            if prio > 0 then
                validMaps[#validMaps + 1] = {
                    cfg = cfg,
                    priority = prio,
                    difficulty = Options["Diff_"..i].Value
                }
            end
        end
        table.sort(validMaps, function(a, b) return a.priority < b.priority end)
        return validMaps
    end
    
    task.spawn(function()
        local lastClaimTime = 0
        while true do
            task.wait(3)
            
            if os.time() - lastClaimTime > 60 then
                lastClaimTime = os.time()
                if Options.AutoClaimDaily and Options.AutoClaimDaily.Value then
                    pcall(function()
                        local r = ReplicatedStorage.Remotes.Daily_Rewards.claim
                        if r:IsA("RemoteFunction") then r:InvokeServer() else r:FireServer() end
                    end)
                end
                if Options.AutoClaimBundle and Options.AutoClaimBundle.Value then
                    pcall(function()
                        local r = ReplicatedStorage.Remotes.Monetization.free_bundle
                        if r:IsA("RemoteFunction") then r:InvokeServer() else r:FireServer() end
                    end)
                end
            end
            
            for i, cfg in ipairs(mapConfigs) do
                local currentCap = util and util.data and util.data.caps and util.data.caps[cfg.capStr] or 0
                local isFull = (currentCap >= cfg.mapData.cap)
                local prio = tonumber(Options["Priority_"..i].Value) or 0
                
                local contentStr = string.format("Limit: %d / %d", currentCap, cfg.mapData.cap)
                if isFull then contentStr = contentStr .. " [FULL - SKIPPED]" end
                if prio == 0 then contentStr = contentStr .. " [SKIPPED]" end
                cfg.paragraph:SetDesc(contentStr)
            end
            
            if Options.MasterAutoRun.Value and get_challenges and create_room then
                local succ, challengeData = pcall(function() return get_challenges:InvokeServer() end)
                local joinedSomething = false
                
                if succ and type(challengeData) == "table" then
                    if isfile and writefile then
                        pcall(function() writefile("AnimeSquadron_LastSnipeCheck.txt", tostring(math.floor(os.time() / 1800))) end)
                    end
                    
                    if Options.AutoJoin1d.Value and challengeData["1d"] then
                        local chData = challengeData["1d"]
                        if chData.world ~= lastDailyWorld or chData.act ~= lastDailyAct then
                            dailyCompleted = false
                            lastDailyWorld = chData.world
                            lastDailyAct = chData.act
                        end
                        
                        if not dailyCompleted then
                            IndraUI:Notify({ Title = "Sniper", Content = "Joining Daily Challenge!", Duration = 3 })
                            local s, err = joinRoom(chData.act, "1d", "Challenge", chData.world, chData.rewards, nil, nil)
                            if not s then
                                if err == "Already completed!" then
                                    dailyCompleted = true
                                end
                            else
                                joinedSomething = true
                            end
                        end
                    end
                    
                    if not joinedSomething and Options.AutoJoin30m.Value and challengeData["30m"] then
                        local chData = challengeData["30m"]
                        local shouldJoin = false
                        local targets = Options.TargetItem30m.Value
                        
                        if chData.rewards and type(targets) == "table" then
                            for rewardName, _ in pairs(chData.rewards) do
                                if targets[rewardName] then
                                    shouldJoin = true
                                    break
                                end
                            end
                        end
                        
                        if shouldJoin then
                            IndraUI:Notify({ Title = "Sniper", Content = "Target found! Joining Regular 30m!", Duration = 3 })
                            local s, err = joinRoom(chData.act, "30m", "Challenge", chData.world, chData.rewards, nil, nil)
                            if s then joinedSomething = true end
                        end
                    end
                end
                
                if not joinedSomething then
                    local targetData = nil
                    local sortedMaps = getSortedValidTraitMaps()
                    
                    for _, data in ipairs(sortedMaps) do
                        local currentCap = util and util.data and util.data.caps and util.data.caps[data.cfg.capStr] or 0
                        if currentCap < data.cfg.mapData.cap then
                            targetData = data
                            break
                        end
                    end
                    
                    if targetData then
                        IndraUI:Notify({ Title = "Trait Farm", Content = "Joining: " .. targetData.cfg.mapData.world .. " (" .. targetData.difficulty .. ")", Duration = 3 })
                        local s, err = joinRoom(targetData.cfg.mapData.act, targetData.difficulty, targetData.cfg.mapData.mode, targetData.cfg.mapData.world, nil, targetData.cfg.capStr, targetData.cfg.mapData.cap)
                        if s then joinedSomething = true end
                    end
                end
            end
        end
    end)
    
else
    print("[UniversalAutoFarm] INGAME mode initialized")
    
    local messageEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Players"):WaitForChild("message", 10)
    local replayEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("replay", 10)
    
    local util
    pcall(function() util = require(Players.LocalPlayer.PlayerScripts.Client.Utility) end)
    
    local targetCapStr = nil
    local targetMaxCap = nil
    
    if isfile and readfile and isfile("AnimeSquadron_CurrentTarget.json") then
        local succ, parsed = pcall(function() return HttpService:JSONDecode(readfile("AnimeSquadron_CurrentTarget.json")) end)
        if succ and parsed then
            targetCapStr = parsed.capStr
            targetMaxCap = parsed.maxCap
            print("[AutoFarm] Limit data loaded: " .. tostring(targetCapStr) .. " (Max: " .. tostring(targetMaxCap) .. ")")
        end
    end
    
    local isTeleporting = false
    
    local function forceTeleportToLobby(notifyTitle, notifyContent)
        if isTeleporting then return end
        isTeleporting = true
        if notifyTitle and notifyContent then
            IndraUI:Notify({ Title = notifyTitle, Content = notifyContent, Duration = 5 })
        end
        task.spawn(function()
            while true do
                local success, err = pcall(function()
                    local teleportRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    if teleportRemote then teleportRemote = teleportRemote:FindFirstChild("Players") end
                    if teleportRemote then teleportRemote = teleportRemote:FindFirstChild("teleport") end
                    
                    if teleportRemote and teleportRemote:IsA("RemoteEvent") then
                        teleportRemote:FireServer()
                    else
                        warn("[AutoFarm] Không tìm thấy RemoteEvent teleport của game!")
                    end
                end)
                if not success then
                    warn("[AutoFarm] Lỗi Teleport: " .. tostring(err))
                end
                task.wait(5)
            end
        end)
    end
    
    if messageEvent then
        messageEvent.OnClientEvent:Connect(function(msg, msgType)
            if not isTeleporting and Options.AutoLeaveToggle.Value and type(msg) == "string" then
                if string.find(msg, "cant replay this challenge") or msg == "You cant replay this challenge!" then
                    forceTeleportToLobby("Auto Leave", "Replay denied! Teleporting to Lobby...")
                end
            end
        end)
    end
    
    task.spawn(function()
        while true do
            task.wait(2)
            
            
            for i, cfg in ipairs(mapConfigs) do
                local currentCap = util and util.data and util.data.caps and util.data.caps[cfg.capStr] or 0
                local isFull = (currentCap >= cfg.mapData.cap)
                local prio = tonumber(Options["Priority_"..i].Value) or 0
                
                local contentStr = string.format("Limit: %d / %d", currentCap, cfg.mapData.cap)
                if isFull then contentStr = contentStr .. " [FULL - SKIPPED]" end
                if prio == 0 then contentStr = contentStr .. " [SKIPPED]" end
                cfg.paragraph:SetDesc(contentStr)
            end
            
            if not isTeleporting and Options.AutoSniperSync and Options.AutoSniperSync.Value and Options.SniperSyncMode.Value == "Instant (Abort Match)" then
                local currentBoundary = math.floor(os.time() / 1800)
                local lastCheck = 0
                if isfile and readfile and isfile("AnimeSquadron_LastSnipeCheck.txt") then
                    pcall(function() lastCheck = tonumber(readfile("AnimeSquadron_LastSnipeCheck.txt")) or 0 end)
                end
                
                if currentBoundary > lastCheck then
                    forceTeleportToLobby("Sniper Sync", "New 30m window! Instant aborting to check challenges...")
                end
            end
        end
    end)
    
    local webhookSentForMatch = false
    task.spawn(function()
        while true do
            task.wait(2)
            local menus = Players.LocalPlayer.PlayerGui:FindFirstChild("Menus")
            if menus then
                local endScreen = menus:FindFirstChild("EndScreen")
                if endScreen and endScreen.Visible then
                    if not webhookSentForMatch then
                        webhookSentForMatch = true
                        SessionStats.Matches = SessionStats.Matches + 1
                        saveSessionStats()
                        updateStatsUI()
                        
                        if Options.WebhookOnMatchEnd and Options.WebhookOnMatchEnd.Value and type(sendWebhookData) == "function" then
                            local matchStatus = "WIN"
                            for _, child in pairs(endScreen:GetDescendants()) do
                                if child:IsA("TextLabel") then
                                    local text = string.lower(child.Text)
                                    if string.find(text, "defeat") or string.find(text, "lose") or string.find(text, "fail") then
                                        matchStatus = "LOSS"
                                        break
                                    end
                                end
                            end
                            sendWebhookData(matchStatus)
                        end
                    end
                    
                    if not isTeleporting and Options.AutoSniperSync and Options.AutoSniperSync.Value and Options.SniperSyncMode.Value == "Safe (At EndScreen)" then
                        local currentBoundary = math.floor(os.time() / 1800)
                        local lastCheck = 0
                        if isfile and readfile and isfile("AnimeSquadron_LastSnipeCheck.txt") then
                            pcall(function() lastCheck = tonumber(readfile("AnimeSquadron_LastSnipeCheck.txt")) or 0 end)
                        end
                        if currentBoundary > lastCheck then
                            forceTeleportToLobby("Sniper Sync", "New 30m window! Returning to lobby for challenges...")
                        end
                    end
                    
                    if not isTeleporting and Options.AutoLeaveToggle.Value and targetCapStr and targetMaxCap and util and util.data and util.data.caps then
                        local currentVal = util.data.caps[targetCapStr] or 0
                        print("[AutoFarm] Current Limit post-match: " .. currentVal .. " / " .. targetMaxCap)
                        
                        if currentVal >= targetMaxCap then
                            forceTeleportToLobby("Limit Reached!", "Trait Shards reached " .. currentVal .. "/" .. targetMaxCap .. ". Teleporting to Lobby!")
                        end
                    end
                    
                    if not isTeleporting and Options.AutoReplayToggle.Value and replayEvent then
                        IndraUI:Notify({ Title = "Auto Replay", Content = "Replaying immediately...", Duration = 3 })
                        pcall(function() replayEvent:FireServer() end)
                        task.wait(10)
                    end
                else
                    webhookSentForMatch = false
                end
            end
        end
    end)
end
local function sendWebhookData(status, diffs)
    if WebhookURL.Value == "" then return false, "No URL configured" end
    
    local util
    pcall(function() util = require(game:GetService("Players").LocalPlayer.PlayerScripts.Client.Utility) end)
    
    local gems = util and util.data and util.data.stats and util.data.stats.Gems or 0
    local gold = util and util.data and util.data.stats and util.data.stats.Gold or 0
    local level = util and util.data and util.data.stats and util.data.stats.level or 0
    local traitShards = util and util.data and util.data.stats and util.data.stats["Trait Shards"] or 0
    local perfectCubes = util and util.data and util.data.stats and util.data.stats["Perfect Cubes"] or 0
    local rerollCubes = util and util.data and util.data.stats and util.data.stats["Reroll Cubes"] or 0
    
    local strTrait = tostring(traitShards)
    local strPerfect = tostring(perfectCubes)
    local strReroll = tostring(rerollCubes)
    local droppedItems = {}
    
    if status == "DROP" and type(diffs) == "table" then
        if diffs.trait and diffs.trait > 0 then
            table.insert(droppedItems, "Trait Shards +" .. diffs.trait)
            strTrait = tostring(traitShards - diffs.trait) .. " + " .. diffs.trait
        end
        if diffs.perfect and diffs.perfect > 0 then
            table.insert(droppedItems, "Perfect Cubes +" .. diffs.perfect)
            strPerfect = tostring(perfectCubes - diffs.perfect) .. " + " .. diffs.perfect
        end
        if diffs.reroll and diffs.reroll > 0 then
            table.insert(droppedItems, "Reroll Cubes +" .. diffs.reroll)
            strReroll = tostring(rerollCubes - diffs.reroll) .. " + " .. diffs.reroll
        end
    end
    
    local mapName = "Lobby"
    if game.PlaceId ~= 71132543521245 then
        local mode = util and util.data and util.data.ingame and util.data.ingame.mode or "Unknown"
        local world = util and util.data and util.data.ingame and util.data.ingame.world or "Map"
        local act = util and util.data and util.data.ingame and util.data.ingame.act or "1"
        mapName = string.format("%s (Act %s) [%s]", world, tostring(act), mode)
    end

    local embedColor = 16776960
    local statusText = "Idle (Checking...)"
    if status == "WIN" then 
        embedColor = 65280
        statusText = "Victory"
    elseif status == "LOSS" then 
        embedColor = 16711680
        statusText = "Defeat"
    elseif status == "DROP" then
        embedColor = 65280
        statusText = "Item Dropped!"
        if #droppedItems > 0 then
            statusText = "Item Dropped! (" .. table.concat(droppedItems, ", ") .. ")"
        end
    end
    
    local playerName = game.Players.LocalPlayer.Name
    local gameIconUrl = "https://tr.rbxcdn.com/180DAY-d29acf5020ecef8a89736cb5f23d934c/512/512/Image/Png/noFilter"
    
    local embed = {
        title = "Anime Squadron - Auto Farm Update",
        color = embedColor,
        thumbnail = { url = gameIconUrl },
        fields = {
            { name = "👤 Player", value = playerName, inline = true },
            { name = "⭐ Level", value = tostring(level), inline = true },
            { name = "🗺️ Map", value = mapName, inline = true },
            { name = "<:Gems:1521405276127760434> Gems", value = tostring(gems), inline = true },
            { name = "<:Gold:1521405249988989008> Gold", value = tostring(gold), inline = true },
            { name = "<:TraitShards:1521405216346607697> Trait Shards", value = strTrait, inline = true },
            { name = "<:PerfectCubes:1521405365416099950> Perfect Cubes", value = strPerfect, inline = true },
            { name = "<:RerollCubes:1521405341667954789> Reroll Cubes", value = strReroll, inline = true },
            { name = "📊 Status", value = statusText, inline = true }
        },
        footer = { text = "IndraHub Anime Squadron • " .. os.date("%Y-%m-%d %H:%M:%S") }
    }
    
    local msg = {
        username = "Anime Squadron",
        avatar_url = gameIconUrl,
        embeds = { embed }
    }
    
    local req = nil
    if type(http_request) == "function" then req = http_request
    elseif type(request) == "function" then req = request
    elseif type(syn) == "table" and type(syn.request) == "function" then req = syn.request
    elseif type(fluxus) == "table" and type(fluxus.request) == "function" then req = fluxus.request end
    
    if req then
        local success, res = pcall(function()
            return req({
                Url = WebhookURL.Value,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(msg)
            })
        end)
        return success, res
    else
        return false, "Executor does not support HTTP requests"
    end
end

Tabs.Webhook:AddButton({
    Title = "Test Send Webhook",
    Description = "Send a test message now",
    Callback = function()
        IndraUI:Notify({ Title = "Webhook", Content = "Sending...", Duration = 2 })
        local success, err = sendWebhookData("INTERVAL")
        if success then
            IndraUI:Notify({ Title = "Webhook", Content = "Sent successfully!", Duration = 3 })
        else
            IndraUI:Notify({ Title = "Webhook Error", Content = tostring(err), Duration = 5 })
        end
    end
})

task.spawn(function()
    while true do
        task.wait(60)
        if Options.WebhookOnInterval and Options.WebhookOnInterval.Value and Options.WebhookURL and Options.WebhookURL.Value ~= "" then
            local interval = tonumber(Options.WebhookInterval.Value) or 10
            local lastSend = 0
            if isfile and readfile and isfile("AnimeSquadron_LastWebhook.txt") then
                pcall(function() lastSend = tonumber(readfile("AnimeSquadron_LastWebhook.txt")) or 0 end)
            end
            
            if os.time() - lastSend >= (interval * 60) then
                local success = sendWebhookData("INTERVAL")
                if success and writefile then
                    pcall(function() writefile("AnimeSquadron_LastWebhook.txt", tostring(os.time())) end)
                end
            end
        end
    end
end)

task.spawn(function()
    local util
    local lastTrait, lastPerfect, lastReroll = -1, -1, -1
    while true do
        task.wait(5)
        pcall(function() util = require(game:GetService("Players").LocalPlayer.PlayerScripts.Client.Utility) end)
        if util and util.data and util.data.stats then
            local currentTrait = util.data.stats["Trait Shards"] or 0
            local currentPerfect = util.data.stats["Perfect Cubes"] or 0
            local currentReroll = util.data.stats["Reroll Cubes"] or 0
            
            if lastTrait ~= -1 and lastPerfect ~= -1 and lastReroll ~= -1 then
                if SessionStats.StartTrait == -1 then
                    SessionStats.StartTrait = currentTrait
                    SessionStats.StartPerfect = currentPerfect
                    SessionStats.StartReroll = currentReroll
                    saveSessionStats()
                    updateStatsUI()
                end
                
                local diffTrait = currentTrait - lastTrait
                local diffPerfect = currentPerfect - lastPerfect
                local diffReroll = currentReroll - lastReroll
                
                if diffTrait > 0 or diffPerfect > 0 or diffReroll > 0 then
                    SessionStats.TraitShards = SessionStats.TraitShards + (diffTrait > 0 and diffTrait or 0)
                    SessionStats.PerfectCubes = SessionStats.PerfectCubes + (diffPerfect > 0 and diffPerfect or 0)
                    SessionStats.RerollCubes = SessionStats.RerollCubes + (diffReroll > 0 and diffReroll or 0)
                    
                    saveSessionStats()
                    updateStatsUI()
                    
                    if Options.WebhookOnDrop and Options.WebhookOnDrop.Value and Options.WebhookURL and Options.WebhookURL.Value ~= "" then
                        sendWebhookData("DROP", {
                            trait = diffTrait,
                            perfect = diffPerfect,
                            reroll = diffReroll
                        })
                        task.wait(10)
                    end
                end
            end
            lastTrait = currentTrait
            lastPerfect = currentPerfect
            lastReroll = currentReroll
        end
    end
end)

local function createMobileToggle()
    local guiParent = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui")
    if not pcall(function() local _ = guiParent.Name end) then
        guiParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    if guiParent:FindFirstChild("IndraHubAnimeSquadronMobileToggle") then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IndraHubAnimeSquadronMobileToggle"
    ScreenGui.Parent = guiParent
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.BackgroundTransparency = 0.3
    ToggleBtn.Position = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = ToggleBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 60, 60)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = ToggleBtn

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = ToggleBtn
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.5, -12, 0.5, -12)
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Image = "rbxassetid://10734900011"
    
    local dragging = false
    local dragInput, dragStart, startPos

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        if vim then
            vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait()
            vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end
createMobileToggle()
