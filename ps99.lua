local function xorDecrypt(encryptedString, key)
    local result = ""
    for i = 1, #encryptedString do
        local charCode = string.byte(encryptedString, i)
        local keyCode = string.byte(key, (i - 1) % #key + 1)
        result = result .. string.char(bit32.bxor(charCode, keyCode))
    end
    return result
end

local function base64Decode(input)
    local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = input:gsub("[^" .. base64Chars .. "=]", "")
    
    local binary = result:gsub(".", function(char)
        if char == "=" then return "" end
        local index = base64Chars:find(char) - 1
        local bits = ""
        for i = 6, 1, -1 do
            bits = bits .. (index % 2^i - index % 2^(i - 1) > 0 and "1" or "0")
        end
        return bits
    end)
    
    local output = ""
    for byteStr in binary:gmatch("%d%d%d?%d?%d?%d?%d?%d?") do
        if #byteStr == 8 then
            local byte = 0
            for i = 1, 8 do
                byte = byte + (byteStr:sub(i, i) == "1" and 2^(8 - i) or 0)
            end
            output = output .. string.char(byte)
        end
    end
    
    return output
end

local env = getfenv()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local GlobalEnv = env.getgenv()

local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubSoccerEventRunning") then return end
setGlobal("IndraHubSoccerEventRunning", true)

env.task.spawn(function()
    while env.task.wait(2) do
        if not getGlobal("IndraHubSoccerEventRunning") then break end
        setGlobal("IndraHubSoccerEventLastHeartbeat", os.time())
    end
end)

GlobalEnv.NEMX_Session = env.math.random()
local SessionID = GlobalEnv.NEMX_Session

GlobalEnv.SoccerConfig = GlobalEnv.SoccerConfig or {
    KickMode = "Auto",
    AutoOpenGifts = false,
    AutoKick = false,
    AutoCollectOrbs = false,
    AutoHatchEgg = false,
    KickPower = 95,
    AutoUpgrades = false,
    SelectedUpgrades = {
        BetterYeetEgg = false,
        YeetOrbStrength = false,
        YeetOrbsReach = false,
        CriticalThrowChance = false,
        TrickshotThrowChance = false,
        PowerStrikeRequirement = false,
        PowerStrikePower = false
    }
}

local Config = GlobalEnv.SoccerConfig

env.pcall(function()
    local PlayerPetModule = env.require(ReplicatedStorage.Library.Client.PlayerPet)
    PlayerPetModule.CalculateSpeedMultiplier = function()
        return 9999
    end
end)

if not GlobalEnv.NEMX_AntiAfkHooked then
    GlobalEnv.NEMX_AntiAfkHooked = true
    
    LocalPlayer.Idled:Connect(function()
        env.pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local UnlockRemote = NetworkFolder:WaitForChild("WR_Unlock")
local InvokeCustomRemote = NetworkFolder:WaitForChild("Instancing_InvokeCustomFromClient")
local FireCustomRemote = NetworkFolder:WaitForChild("Instancing_FireCustomFromClient")
local NetworkModule = env.require(ReplicatedStorage.Library.Client.Network)

if not GlobalEnv.NEMX_NamecallHooked then
    GlobalEnv.NEMX_NamecallHooked = true
    
    local OriginalNamecall
    OriginalNamecall = env.hookmetamethod(game, "__namecall", env.newcclosure(function(self, ...)
        local method = env.getnamecallmethod()
        local args = {...}
        
        if not GlobalEnv.NEMX_CapturedArgs and self == UnlockRemote and method == "InvokeServer" then
            if #args >= 2 then
                GlobalEnv.NEMX_CapturedArgs = args
                env.print("✅ Gift args captured!")
            end
        end
        
        return OriginalNamecall(self, ...)
    end))
end

local function GetKickPower()
    if Config.KickMode == "Auto" then
        return Config.KickPower / 100
    elseif Config.KickMode == "Normal" then
        return env.math.random(98, 100) / 100
    elseif Config.KickMode == "Infinite" then
        return 1
    end
    return Config.KickPower / 100
end

local function GetKickTier()
    if Config.KickMode == "Infinite" then
        return 26
    else
        return env.math.floor((Config.KickPower / 100) * 26)
    end
end

local IsOrbLoopRunning = false

env.task.spawn(function()
    while true do
        if env.task.wait(0.1) then
            if GlobalEnv.NEMX_Session ~= SessionID then
                return
            end
            
            if Config.AutoCollectOrbs then
                env.pcall(function()
                    local InstancingCmds = env.require(game.ReplicatedStorage.Library.Client.InstancingCmds)
                    local SoccerNonce = env.require(game.ReplicatedStorage.Library.Util.SoccerNonce)
                    local InstanceModel = InstancingCmds.GetModel()
                    local ClientModule = InstanceModel:FindFirstChild("ClientModule")
                    
                    if not ClientModule then return end
                    
                    local OrbFrontend = env.require(ClientModule.OrbFrontend)
                    local getUpvalues = env.debug.getupvalues or env.getupvalues
                    local setupValue = env.debug.setupvalue or env.setupvalue
                    
                    local claimUpvalues = getUpvalues(OrbFrontend.Claim)
                    local orbsTable = claimUpvalues[1]
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    
                    if not character then return end
                    
                    for orbId, orbData in env.pairs(orbsTable) do
                        local playerPivot = character:GetPivot()
                        orbData.Model:PivotTo(playerPivot)
                        env.task.wait(0.05)
                        
                        env.pcall(function()
                            InstancingCmds.FireCustom("SG_Note", orbId, SoccerNonce.Roll())
                        end)
                        
                        orbsTable[orbId] = nil
                        
                        env.task.spawn(function()
                            while true do
                                if orbData.Model then
                                    orbData.Model:Destroy()
                                    break
                                end
                                env.task.wait(0.1)
                            end
                        end)
                    end
                end)
            end
        end
    end
end)

if not GlobalEnv.NEMX_EggAnimHooked then
    GlobalEnv.NEMX_EggAnimHooked = true
    
    env.pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
        local ScriptsFolder = PlayerScripts and PlayerScripts:FindFirstChild("Scripts")
        local GameFolder = ScriptsFolder and ScriptsFolder:FindFirstChild("Game")
        local EggFrontend = GameFolder and GameFolder:FindFirstChild("Egg Opening Frontend")
        
        if EggFrontend and env.getsenv then
            local EggEnv = env.getsenv(EggFrontend)
            if EggEnv and EggEnv.PlayEggAnimation then
                EggEnv.PlayEggAnimation = function() end
                env.print("✅ Egg animation disabled!")
            end
        end
    end)
end

local IsTeleportingToEgg = false

env.task.spawn(function()
    while true do
        if env.task.wait(1) then
            if GlobalEnv.NEMX_Session ~= SessionID then
                return
            end
            
            if Config.AutoHatchEgg and not IsTeleportingToEgg then
                env.pcall(function()
                    local NetworkModule = env.require(ReplicatedStorage.Library.Client.Network)
                    local EggCmds = env.require(ReplicatedStorage.Library.Client.EggCmds)
                    local MaxHatch = EggCmds.GetMaxHatch() or 1
                    
                    local ThingsFolder = Workspace:FindFirstChild("__THINGS")
                    if not ThingsFolder then return end
                    
                    local CustomEggs = ThingsFolder:FindFirstChild("CustomEggs")
                    if not CustomEggs then return end
                    
                    local TargetEgg = nil
                    local BestDistance = math.huge
                    local SearchPosition = Vector3.new(1909, 13, -32029)
                    
                    for _, egg in pairs(CustomEggs:GetChildren()) do
                        if not (egg:IsA("Model") or egg:IsA("Part")) then
                            continue
                        end
                        
                        local Display = egg:FindFirstChild("Display")
                        if not Display then continue end
                        
                        local Billboard = Display:FindFirstChildOfClass("BillboardGui")
                        if not Billboard then continue end
                        
                        local TextLabel = Billboard:FindFirstChildOfClass("TextLabel")
                        if not TextLabel then continue end
                        
                        local Text = TextLabel.Text
                        if Text:find("Soccer Egg 8") or Text:find("Soccer Egg8") then
                            local Distance = (egg:GetPivot().Position - SearchPosition).Magnitude
                            if Distance < BestDistance and Distance < 200 then
                                BestDistance = Distance
                                TargetEgg = egg
                            end
                        end
                    end
                    
                    if not TargetEgg then
                        for _, egg in pairs(CustomEggs:GetChildren()) do
                            if not (egg:IsA("Model") or egg:IsA("Part")) then
                                continue
                            end
                            
                            local Distance = (egg:GetPivot().Position - SearchPosition).Magnitude
                            if Distance < BestDistance then
                                BestDistance = Distance
                                TargetEgg = egg
                            end
                        end
                    end
                    
                    if TargetEgg and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        env.print("✅ Found Soccer Egg 8 by display:", TargetEgg.Name)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = TargetEgg:GetPivot() + Vector3.new(0, 5, 0)
                        IsTeleportingToEgg = true
                        env.task.wait(0.5)
                        
                        env.task.spawn(function()
                            NetworkModule.Invoke("CustomEggs_Hatch", TargetEgg.Name, MaxHatch)
                        end)
                    end
                end)
            end
        end
    end
end)

env.task.spawn(function()
    while true do
        if env.task.wait(0.1) then
            if GlobalEnv.NEMX_Session ~= SessionID then
                return
            end
            
            if Config.AutoKick then
                env.pcall(function()
                    InvokeCustomRemote:InvokeServer("SoccerEvent", "CX_Merge", GetKickPower(), GetKickTier())
                end)
                
                env.pcall(function()
                    InvokeCustomRemote:InvokeServer("SoccerEvent", "ZN_Poll", 1)
                end)
            end
        end
    end
end)

local IsAutoOpeningGifts = false
local IsGiftLoopRunning = false
local GiftStatusLabel

local function StartAutoOpenGifts()
    if not GlobalEnv.NEMX_CapturedArgs then
        return false
    end
    
    IsAutoOpeningGifts = true
    IsGiftLoopRunning = true
    
    env.task.spawn(function()
        while IsGiftLoopRunning do
            env.pcall(function()
                UnlockRemote:InvokeServer(env.unpack(GlobalEnv.NEMX_CapturedArgs))
            end)
            env.task.wait(0.1)
        end
    end)
    
    return true
end

local function StopAutoOpenGifts()
    IsAutoOpeningGifts = false
    IsGiftLoopRunning = false
end

env.task.spawn(function()
    while true do
        if env.task.wait(10) then
            if GlobalEnv.NEMX_Session ~= SessionID then
                return
            end
            
            if Config.AutoUpgrades then
                local UpgradeList = {
                    {id = "SoccerPowerStrikeRequirement", enabled = Config.UpgradePowerStrikeMetter, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerPowerStrikeRequirement or 1},
                    {id = "SoccerPowerStrikePower", enabled = Config.UpgradeStrongPowerStrikes, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerPowerStrikePower or 2},
                    {id = "SoccerBetterYeetEgg", enabled = Config.UpgradeFinalEgg, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerBetterYeetEgg or 3},
                    {id = "SoccerYeetOrbStrength", enabled = Config.UpgradeMoreOrbStrength, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerYeetOrbStrength or 4},
                    {id = "SoccerYeetOrbsReach", enabled = Config.UpgradeYeetOrbsReach, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerYeetOrbsReach or 5},
                    {id = "SoccerCriticalThrowChance", enabled = Config.UpgradeCriticalYeetChance, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerCriticalThrowChance or 6},
                    {id = "SoccerTrickshotThrowChance", enabled = Config.UpgradeTrickshotYeetChance, priority = Config.UpgradePriorities and Config.UpgradePriorities.SoccerTrickshotThrowChance or 7}
                }
                
                env.table.sort(UpgradeList, function(a, b)
                    return a.priority < b.priority
                end)
                
                for _, upgrade in ipairs(UpgradeList) do
                    if upgrade.enabled then
                        env.task.spawn(function()
                            env.pcall(function()
                                local EventUpgradesFolder = ReplicatedStorage.Network:FindFirstChild("EventUpgrades")
                                if not EventUpgradesFolder then return end
                                
                                local PurchaseRemote = EventUpgradesFolder:FindFirstChild("Purchase")
                                if not PurchaseRemote then return end
                                
                                PurchaseRemote:InvokeServer(upgrade.id)
                            end)
                        end)
                        env.task.wait(0.1)
                    end
                end
            end
        end
    end
end)

env.task.spawn(function()
    while true do
        if env.task.wait(10) then
            if GlobalEnv.NEMX_Session ~= SessionID then
                return
            end
            
            if Config.AutoUpgrades then
                env.pcall(function()
                    local EventUpgradeCmds = env.require(ReplicatedStorage.Library.Client.EventUpgradeCmds)
                    local EventUpgradesDirectory = env.require(ReplicatedStorage.Library.Directory.EventUpgrades)
                    
                    local UpgradeMapping = {
                        BetterYeetEgg = "SoccerBetterYeetEgg",
                        YeetOrbStrength = "SoccerYeetOrbStrength",
                        YeetOrbsReach = "SoccerYeetOrbsReach",
                        CriticalThrowChance = "SoccerCriticalThrowChance",
                        TrickshotThrowChance = "SoccerTrickshotThrowChance",
                        PowerStrikeRequirement = "SoccerPowerStrikeRequirement",
                        PowerStrikePower = "SoccerPowerStrikePower"
                    }
                    
                    local function IsUpgradeMaxed(upgradeId)
                        local upgradeData = EventUpgradesDirectory[upgradeId]
                        if not upgradeData then return true end
                        
                        local currentTier = EventUpgradeCmds.GetTier(upgradeId) or 0
                        return currentTier >= #upgradeData.TierPowers
                    end
                    
                    for upgradeName, isEnabled in pairs(Config.SelectedUpgrades) do
                        if isEnabled then
                            local upgradeId = UpgradeMapping[upgradeName]
                            if upgradeId and not IsUpgradeMaxed(upgradeId) then
                                EventUpgradeCmds.Purchase(upgradeId)
                                env.task.wait(0.5)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

env.pcall(function()
    local Camera = Workspace.CurrentCamera
    if Camera then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Soccer Event",
    Icon = "infinity",
    Author = "IndraHub",
    Folder = "IndraHubSoccer",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local TabSoccer = Window:Tab({ Title = "Soccer Event", Icon = "zap" })
local TabUpgrades = Window:Tab({ Title = "Upgrades", Icon = "trending-up" })
local TabGifts = Window:Tab({ Title = "Gifts", Icon = "gift" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

TabSettings:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({Title="Success", Content="Discord invite copied to clipboard!"})
    end
})

-- Soccer Tab
TabSoccer:Toggle({
    Title = "Auto Kick",
    Default = Config.AutoKick,
    Callback = function(v) Config.AutoKick = v end
})
TabSoccer:Toggle({
    Title = "Auto Collect Orbs",
    Default = Config.AutoCollectOrbs,
    Callback = function(v) Config.AutoCollectOrbs = v end
})
TabSoccer:Toggle({
    Title = "Auto Hatch Soccer Egg 8",
    Default = Config.AutoHatchEgg,
    Callback = function(v) Config.AutoHatchEgg = v end
})

TabSoccer:Slider({
    Title = "Kick Strength",
    Value = {Min = 1, Max = 100, Default = Config.KickPower},
    Step = 1,
    Callback = function(v) Config.KickPower = v end
})
TabSoccer:Dropdown({
    Title = "Kick Mode",
    Values = {"Auto", "Normal", "Infinite"},
    Value = Config.KickMode,
    Callback = function(v) Config.KickMode = v end
})

TabSoccer:Button({
    Title = "Teleport To Zone 8",
    Callback = function()
        local args = {"__Zone_8"}
        ReplicatedStorage.Network.Teleports_RequestInstanceTeleport:InvokeServer(unpack(args))
    end
})
TabSoccer:Button({
    Title = "Teleport To Zone 8 Egg",
    Callback = function()
        local character = LocalPlayer.Character
        if not (character and character.PrimaryPart) then return end
        character:PivotTo(CFrame.new(1899.4434814453125, 16.924051284790039, -32054.552734375))
    end
})

-- Upgrades Tab
TabUpgrades:Toggle({
    Title = "Better Yeet Egg",
    Default = Config.SelectedUpgrades.BetterYeetEgg,
    Callback = function(v) Config.SelectedUpgrades.BetterYeetEgg = v end
})
TabUpgrades:Toggle({
    Title = "Yeet Orb Strength",
    Default = Config.SelectedUpgrades.YeetOrbStrength,
    Callback = function(v) Config.SelectedUpgrades.YeetOrbStrength = v end
})
TabUpgrades:Toggle({
    Title = "Yeet Orbs Reach",
    Default = Config.SelectedUpgrades.YeetOrbsReach,
    Callback = function(v) Config.SelectedUpgrades.YeetOrbsReach = v end
})
TabUpgrades:Toggle({
    Title = "Critical Throw Chance",
    Default = Config.SelectedUpgrades.CriticalThrowChance,
    Callback = function(v) Config.SelectedUpgrades.CriticalThrowChance = v end
})
TabUpgrades:Toggle({
    Title = "Trickshot Throw Chance",
    Default = Config.SelectedUpgrades.TrickshotThrowChance,
    Callback = function(v) Config.SelectedUpgrades.TrickshotThrowChance = v end
})
TabUpgrades:Toggle({
    Title = "Power Strike Requirement",
    Default = Config.SelectedUpgrades.PowerStrikeRequirement,
    Callback = function(v) Config.SelectedUpgrades.PowerStrikeRequirement = v end
})
TabUpgrades:Toggle({
    Title = "Power Strike Power",
    Default = Config.SelectedUpgrades.PowerStrikePower,
    Callback = function(v) Config.SelectedUpgrades.PowerStrikePower = v end
})
TabUpgrades:Toggle({
    Title = "Auto Buy Selected Upgrades",
    Default = Config.AutoUpgrades,
    Callback = function(v) Config.AutoUpgrades = v end
})

-- Gifts Tab
TabGifts:Button({
    Title = "Start Auto Open Gifts",
    Desc = "Ensure you've captured gift args manually first.",
    Callback = function()
        if StartAutoOpenGifts() then
            WindUI:Notify({Title="Started", Content="Auto opening gifts..."})
        else
            WindUI:Notify({Title="Error", Content="Open World Cup Gift Manually First."})
        end
    end
})

TabGifts:Button({
    Title = "Stop Auto Open Gifts",
    Callback = function()
        StopAutoOpenGifts()
        WindUI:Notify({Title="Stopped", Content="Stopped auto opening."})
    end
})

env.print("[Void] loaded")
