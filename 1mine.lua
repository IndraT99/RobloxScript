-- Deobfuscated from 1mineperclick.lua.
-- Decoder, anti-analysis checks, encrypted string pool, and slot indirection removed.
-- Analysis copy: unknownField marks property metadata erased from supplied input.
-- This file is for reading only; do not execute it as an exact recovered payload.

local state = {}

-- VALINC SYNDICATE - Mine Per Click Free

if game.PlaceId ~= 74193805629461 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "VALINC SYNDICATE",
        Text = "Unauthorized Game! This script only supports +1 Mine Per Click! ⛏️",
        Duration = 7
    
        })
    end)
    return
end

if ((28989*(28989+1))%2==0) then
else
  local value001="26" value001=value001:sub(1,0)
end
do
if (21 - 21) ~= 0 then
  local value002 = {}
  value002[711] = 986
  value002 = nil
end
end

state.playersService = game:GetService("Players")
state.replicatedStorage = game:GetService("ReplicatedStorage")
state.runService = game:GetService("RunService")
state.userInputService = game:GetService("UserInputService")
state.coreGui = game:GetService("CoreGui")

state.localPlayer = state.playersService.LocalPlayer
state.dataClient = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("DataClient"))
state.dataReplica = nil
task.spawn(function()
    local value003, value004 = pcall(function()
        return state.dataClient.unknownField.unknownField
    end)
    if value003 and value004 then
        state.dataReplica = value004
    else
        state.dataReplica = state.dataClient:GetReplica()
    end
end)

if ((58639>0)) then
state.scriptId = tostring(math.random()) .. "_" .. tostring(os.clock())

if _G.unknownField then
    _G.unknownField.unknownField = true
    pcall(function()
        if _G.unknownField.unknownField then
            _G.unknownField.unknownField:Destroy()
        end
    end)
    pcall(function()
        if _G.unknownField.unknownField then
            for value005, value006 in ipairs(_G.unknownField.unknownField) do
                if value006 and value006.unknownField then
                    pcall(function() value006:Disconnect() end)
                end
            end
        end
    end)
    pcall(function()
        local value007 = state.localPlayer.Character
        local value008 = value007 and value007:FindFirstChildOfClass("Humanoid")
        if value008 then
            value008.unknownField = 16
            value008.unknownField = 50
        end
    end)
end

state.connections = {}
else
  local value009=math.floor(240/240) value009=nil
end
_G.unknownField = {
    stopThreads = false,
    ScriptId = state.scriptId,
    UI = nil,
    Connections = state.connections,
}

state.stageNames = { "Auto (Highest Unlocked)" }
state.stagesList = nil
pcall(function()
    local value010 = state.replicatedStorage:WaitForChild("Databases", (((3)*3)-(((3))*2)))
    if value010 then
        state.stagesList = require(value010:WaitForChild("StagesList", (((3)*3)-(((3))*2))))
    end
end)

if type(state.stagesList) == "table" then
    for value011 = 1, #state.stagesList do
        table.insert(state.stageNames, "Stage " .. tostring(value011))
    end
else
    for value012 = 1, (((100)*1)-0) do
        table.insert(state.stageNames, "Stage " .. tostring(value012))
    end
end

state.autoMineToggle = nil
state.claimRarityDropdown = nil

state.config = {
    AutoTraining = false,
    SelectedOre = "Auto (Best Available)",
    SpeedDelay = 0.05,
    FastMining = false,
    MiningDelay = 0.05,
    AutoMine = false,
    SelectedMineStage = "Auto (Highest Unlocked)",
    AutoRebirth = false,
    AutoUpgradeCarry = false,
    AutoUpgradeWalkspeed = false,
    AutoBuyPickaxes = false,
    AutoBuyAuras = false,
    SelectedShopPickaxe = "Stone Pickaxe",
    SelectedShopAura = "Flame",
    SpeedHack = false,
    SpeedValue = 24,
    JumpHack = false,
    JumpValue = ((((80)+(80))*0+(80))),
    Noclip = false,
    InfiniteJump = false,
    ItemESP = false,
    ESPFilter = "All",
    AutoClaimLoot = false,
    AutoSellLoot = false,
    AutoClaimRarity = "Legendary & Above",
    AutoSellRarity = "All",
}

state.isActive = function()
    local value013 = _G.unknownField
    return value013 and not value013.unknownField and value013.unknownField == state.scriptId
end

state.getHumanoid = function()
    local value014 = state.localPlayer.Character
    return value014 and value014:FindFirstChildOfClass("Humanoid")
end

state.getRootPart = function()
    local value015 = state.localPlayer.Character
    return value015 and (value015:FindFirstChild("HumanoidRootPart") or value015.PrimaryPart)
end
do
if (187 * 0) > 0 then
  local value016 = ""
  local value017 = value016 .. "934"
  value017 = nil
end
end

state.rarityRanks = {
    Common = 1,
    Uncommon = ((2*1)+0),
    Rare = (((3)*3)-(((3))*2)),
    Epic = 4,
    Legendary = (((5)-0)),
    Mythic = 6,
    Secret = 7,
    Godly = (((8)*7)-(((8))*6)),
    Divine = 9,
    Celestial = 10
}

if ((73+158)>=0) then
state.numberSuffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg" }
state.formatNumber = function(value018)
    if not value018 or value018 < (((1000)*5)-(((1000))*4)) then
        return tostring(math.floor(value018 or 0))
    end
    local value019 = math.floor(math.log(value018, 1000))
    local value020 = math.min(value019, #state.numberSuffixes - 1)
    local value021 = value018 / ((((1000)*5)-(((1000))*4)) ^ value020)
    local value022 = state.numberSuffixes[1]
    
    if value021 >= (((100)*1)-0) then
        return string.format("%.0f%s", value021, value022)
    elseif value021 >= 10 then
        return string.format("%.1f%s", value021, value022)
    else
        return string.format("%.2f%s", value021, value022)
    end
end

state.getBackpackAmount = function()
    local value023 = nil
    pcall(function()
        value023 = state.localPlayer.Character:FindFirstChild("Main")
            and state.localPlayer.Character.unknownField:FindFirstChild("Wins")
            and state.localPlayer.Character.unknownField.unknownField:FindFirstChild("BackpackFrame")
            and state.localPlayer.Character.unknownField.unknownField.unknownField:FindFirstChild("Amount")
    end)
    
    local value024 = nil
    if value023 then
        pcall(function()
            local value025 = value023.unknownField
            value024 = tonumber(value025:match("^(%d+)%s*/"))
        end)
    end
    if value024 then
        return value024
    end
    
    local value026 = 0
    if state.dataReplica and state.dataReplica.unknownField and state.dataReplica.unknownField.unknownField then
        for value027, value028 in pairs(state.dataReplica.unknownField.unknownField) do
            value026 = value026 + 1
        end
    end
    return value026
end
else
  local value029={} value029[1]="953" value029=nil
end

state.getBackpackMax = function()
    local value030 = nil
    pcall(function()
        value030 = state.localPlayer.Character:FindFirstChild("Main")
            and state.localPlayer.Character.unknownField:FindFirstChild("Wins")
            and state.localPlayer.Character.unknownField.unknownField:FindFirstChild("BackpackFrame")
            and state.localPlayer.Character.unknownField.unknownField.unknownField:FindFirstChild("Amount")
    end)
    
    local value031 = nil
    if value030 then
        pcall(function()
            local value032 = value030.unknownField
            value031 = tonumber(value032:match("/%s*(%d+)"))
        end)
    end
    if value031 then
        return value031
    end
    
    if state.dataReplica and state.dataReplica.unknownField then
        return state.dataReplica.unknownField.unknownField or 10
    end
    return 10
end

state.getCurrentStage = function()
    local value033 = nil
    pcall(function()
        value033 = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)
    if value033 and value033.unknownField then
        return "Stage " .. tostring(value033.unknownField)
    end
    
    local value034 = workspace:FindFirstChild("Stages")
    if value034 then
        local value035 = nil
        local value036 = math.huge
        local value037 = state.getRootPart()
        if value037 then
            for value038, value039 in ipairs(value034:GetChildren()) do
                local value040 = value039:FindFirstChild("Hitbox")
                if value040 then
                    local value041 = (value037.Position - value040.Position).Magnitude
                    if value041 < value036 then
                        value036 = value041
                        value035 = value039.unknownField
                    end
                end
            end
        end
        if value035 then
            return value035
        end
    end
    return "Stage 1"
end

state.uiLibraryState = _G.unknownField
if ((63747*(63747+1))%2==0) then
if not state.uiLibraryState then
    local value042, value043 = pcall(function()
        state.uiLibraryState = loadstring(game:HttpGet(
            "https://cdn.vinzhub.com/scripts/Liblery%20Ui/VALINC%20QUARTZ/1e72163d8c3b5ce2340659f7f67776e3/ff342f0b0e66c7835ba0697c21422a0229a990d57e7c2f6f.lua"
        ))()
    end)
    if not value042 then return end
end

state.window = state.uiLibraryState.CreateWindow({
    Title = "VALINC SYNDICATE",
    Subtitle = "Mine Per Click Free v1.0.0",
    Logo = "rbxassetid://107101390544126",
    ToggleKey = Enum.KeyCode.G
})

_G.unknownField.unknownField = state.window.unknownField or state.window.unknownField or state.window
else
  local value044=math.floor(914/914) value044=nil
end

if ((38406>0)) then
pcall(function()
    local value045 = _G.unknownField.unknownField
    local value046 = value045:FindFirstChild("TabList", true)
    local value047 = value046 and value046:FindFirstChildOfClass("UIListLayout")
    if value047 then value047.SortOrder = Enum.SortOrder.LayoutOrder end
end)

state.tabs = {
    Automatic = state.window:CreateTab("Automatic", "repeat"),
    Shop = state.window:CreateTab("Shop", "shopping-cart"),
    Movement = state.window:CreateTab("Movement", "zap"),
    Teleport = state.window:CreateTab("Teleport", "map-pin"),
    Visuals = state.window:CreateTab("Visuals", "eye"),
    Info = state.window:CreateTab("Info", "info"),
}

state.autoSection = state.tabs.Automatic:CreateSection("Auto Farming")
else
  local value048=nil value048=212 value048=nil
end

state.autoSection:CreateToggle("Auto Training", false, function(value049)
    state.config.AutoTraining = value049
end)

state.autoSection:CreateDropdown("Select Ore / Strength", {
    "Auto (Best Available)",
    "Coal Ore",
    "Iron Ore",
    "Gold Ore",
    "Quartz Ore",
    "Diamond Ore",
    "Demonite",
    "Amethyst (Gamepass)",
    "Emerald (Gamepass)",
    "Azurite (Gamepass)"
}, "Auto (Best Available)", function(value050)
    state.config.SelectedOre = value050
end)

state.autoSection:CreateSlider("Training Speed (Seconds)", 0.01, 1.0, 0.05, false, function(value051)
    state.config.SpeedDelay = value051
end)

if ((228+208)>=0) then
state.autoSection:CreateToggle("Fast Mining (Wall)", false, function(value052)
    state.config.FastMining = value052
end)

state.autoSection:CreateSlider("Mining Speed (Seconds)", 0.001, 1.0, 0.05, false, function(value053)
    state.config.MiningDelay = value053
end)

state.autoMineToggle = state.autoSection:CreateToggle("Auto Mine", false, function(value054)
    state.config.AutoMine = value054
    _G.unknownField = value054
    if value054 then
        _G.unknownField = nil
        _G.unknownField = state.scriptId
    end
end)
else
  local value055=bit32.bxor(522,522) value055=nil
end

state.autoSection:CreateDropdown("Select Stage", state.stageNames, state.stageNames[1], function(value056)
    state.config.SelectedMineStage = value056
end)

state.sellSection = state.tabs.Automatic:CreateSection("Auto Sell Settings")
do
if (1 - 1) ~= 0 then
  local value057, value058, value059 = nil, nil, nil
  value057 = 869
  value058 = value057 - value057
  value059 = value058
end
end

state.sellSection:CreateToggle("Auto Claim Loot", false, function(value060)
    state.config.AutoClaimLoot = value060
end)

if ((58191>0)) then
state.claimRarityDropdown = state.sellSection:CreateMultiDropdown(
    "Select Claim Rarity",
    { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" },
    { "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" },
    function() end
)

state.sellSection:CreateToggle("Auto Sell Loot", false, function(value061)
    state.config.AutoSellLoot = value061
end)

state.sellRarities = { "All", "Common", "Uncommon & Below", "Rare & Below", "Epic & Below", "Legendary & Below", "Mythic & Below" }
else
  local value062=nil value062=213 value062=nil
end
state.sellSection:CreateDropdown("Select Sell Rarity", state.sellRarities, state.sellRarities[1], function(value063)
    state.config.AutoSellRarity = value063
end)

state.sellSection:CreateButton("Teleport to Surface (GotoSurface)", function()
    pcall(function()
        local value064 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
        local value065 = value064 and value064:WaitForChild("Server", (((5)-0)))
        local value066 = value065 and value065:WaitForChild("GotoSurface", (((5)-0)))
        if value066 then
            value066:FireServer()
        end
    end)
end)

state.upgradeSection = state.tabs.Automatic:CreateSection("Auto Upgrades")

if ((19670>0)) then
state.upgradeSection:CreateToggle("Auto Rebirth", false, function(value067)
    state.config.AutoRebirth = value067
end)

state.upgradeSection:CreateToggle("Auto Upgrade Carry (Slots)", false, function(value068)
    state.config.AutoUpgradeCarry = value068
end)

state.upgradeSection:CreateToggle("Auto Upgrade Walkspeed", false, function(value069)
    state.config.AutoUpgradeWalkspeed = value069
end)
else
  local value070={} value070[1]="184" value070=nil
end

if ((42877-42877)==0) then
state.upgradeStatus = state.upgradeSection:CreateStatusList("Upgrade Statistics Status", {
    { name = "Current Rebirths", value = "-" },
    { name = "Carry Slots", value = "-" },
    { name = "Extra Walkspeed", value = "-" }
})

state.shopSection = state.tabs.Shop:CreateSection("Manual Shop")

state.pickaxeDropdown = state.shopSection:CreateDropdown("Select Pickaxe", { "-" }, "-", function(value071)
    state.config.SelectedShopPickaxe = value071
end)
else
  local value072=nil value072=655 value072=nil
end

state.shopSection:CreateButton("Purchase Selected Pickaxe", function()
    local value073 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchasePickaxe", (((5)-0)))
    if value073 and state.config.SelectedShopPickaxe then
        pcall(function()
            local value074 = state.config.SelectedShopPickaxe:match("^(.-)%s*%(%$.-%)$") or state.config.SelectedShopPickaxe
            if value074 ~= "All Pickaxes Purchased" and value074 ~= "-" then
                value073:FireServer(value074, "Cash")
            end
        end)
    end
end)

state.auraDropdown = state.shopSection:CreateDropdown("Select Aura", { "-" }, "-", function(value075)
    state.config.SelectedShopAura = value075
end)

state.shopSection:CreateButton("Purchase Selected Aura", function()
    local value076 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchaseAura", (((5)-0)))
    if value076 and state.config.SelectedShopAura then
        pcall(function()
            local value077 = state.config.SelectedShopAura:match("^(.-)%s*%(%$.-%)$") or state.config.SelectedShopAura
            if value077 ~= "All Auras Purchased" and value077 ~= "-" then
                value076:FireServer(value077)
            end
        end)
    end
end)

state.autoBuySection = state.tabs.Shop:CreateSection("Auto Buy Shop")

state.autoBuySection:CreateToggle("Auto Buy Pickaxes", false, function(value078)
    state.config.AutoBuyPickaxes = value078
end)

state.autoBuySection:CreateToggle("Auto Buy Auras", false, function(value079)
    state.config.AutoBuyAuras = value079
end)
do
if (223 - 223) ~= 0 then
  local value080 = ""
  local value081 = value080 .. "611"
  value081 = nil
end
end

state.physicsSection = state.tabs.Movement:CreateSection("Custom Physics")

state.physicsSection:CreateToggle("Walk Speed Hack", false, function(value082)
    state.config.SpeedHack = value082
    if not value082 then
        local value083 = state.getHumanoid()
        if value083 then value083.WalkSpeed = 16 end
    end
end)

state.physicsSection:CreateSlider("Walk Speed Value", 16, (((150)*5)-(((150))*4)), 24, false, function(value084)
    state.config.SpeedValue = value084
end)

state.physicsSection:CreateToggle("Jump Hack", false, function(value085)
    state.config.JumpHack = value085
    if not value085 then
        local value086 = state.getHumanoid()
        if value086 then value086.JumpPower = 50 end
    end
end)

state.physicsSection:CreateSlider("Jump Value", 50, 300, ((((80)+(80))*0+(80))), false, function(value087)
    state.config.JumpValue = value087
end)

state.physicsSection:CreateToggle("Noclip", false, function(value088)
    state.config.Noclip = value088
    if not value088 then
        pcall(function()
            local value089 = state.localPlayer.Character
            if value089 then
                for value090, value091 in ipairs(value089:GetDescendants()) do
                    if value091:IsA("BasePart") then
                        value091.CanCollide = true
                    end
                end
            end
        end)
    end
end)

state.physicsSection:CreateToggle("Infinite Jump", false, function(value092)
    state.config.InfiniteJump = value092
end)

state.teleportSection = state.tabs.Teleport:CreateSection("Instant Teleports")

state.teleportTo = function(value093)
    local value094 = state.getRootPart()
    if value094 then
        value094.unknownField = value093
    end
end

state.teleportSection:CreateButton("Teleport to Lobby Spawn", function()
    pcall(function()
        local value095 = workspace:FindFirstChild("SpawnLocations")
        if value095 then
            local value096 = value095:GetChildren()
            if #value096 > 0 then
                state.teleportTo(value096.unknownField.unknownField + Vector3.new(0, (((3)*3)-(((3))*2)), 0))
                return
            end
        end
        state.teleportTo(CFrame.new(0, 10, 0))
    end)
end)

state.teleportSection:CreateButton("Teleport to Surface (GotoSurface)", function()
    pcall(function()
        local value097 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
        local value098 = value097 and value097:WaitForChild("Server", (((5)-0)))
        local value099 = value098 and value098:WaitForChild("GotoSurface", (((5)-0)))
        if value099 then
            value099:FireServer()
        end
    end)
end)

state.espSection = state.tabs.Visuals:CreateSection("Item ESP Settings")

if (math.ceil(24072)==24072) then
state.rarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Uncommon = Color3.fromRGB(50, 220, 50),
    Rare = Color3.fromRGB(50, (((150)*5)-(((150))*4)), 255),
    Epic = Color3.fromRGB(180, 50, 255),
    Legendary = Color3.fromRGB(255, ((((165)+(165))*0+(165))), 0),
    Mythic = Color3.fromRGB(255, 0, 128),
    Secret = Color3.fromRGB(0, 255, 255),
    Godly = Color3.fromRGB(255, 60, 60),
    Divine = Color3.fromRGB(255, 215, 0),
    Celestial = Color3.fromRGB((((100)*1)-0), (((240)*11)-(((240))*10)), 255),
}

state.rarityColor = function(value100)
    return state.rarityColors[value100] or Color3.fromRGB(255, 255, 255)
end

state.getItemInfo = function(value101)
    local value102 = value101
    if value102:IsA("BasePart") and value102.unknownField and not value102.unknownField:IsA("Folder") and not value102.unknownField:IsA("Workspace") then
        if value102.unknownField:FindFirstChild("ItemStats", true) then
            value102 = value102.unknownField
        end
    end

    local value103 = value102.unknownField
    local value104 = "Common"
    local value105 = "$0"
    
    local value106 = value102:FindFirstChild("ItemStats", true)
    
    if value106 then
        local value107 = value106:FindFirstChildWhichIsA("BillboardGui") or value106:WaitForChild("BillboardGui", 0.5)
        if value107 then
            local value108 = value107:WaitForChild("Rarity", 0.5)
            if value108 and value108:IsA("TextLabel") then value104 = value108.unknownField end
            
            local value109 = value107:WaitForChild("Revenue", 0.5)
            if value109 and value109:IsA("TextLabel") then value105 = value109.unknownField end
            
            local value110 = value107:WaitForChild("Name", 0.5)
            if value110 and value110:IsA("TextLabel") then value103 = value110.unknownField end
        end
    end
    
    return value103, value104, value105
end
else
  local value111={} value111[1]="996" value111=nil
end
do
if (69 - 69) ~= 0 then
  local value112 = (777 * 347)
  local value113 = value112 / 777
  value113 = nil
end
end

state.matchesRarity = function(value114)
    if not state.config.ESPFilter then return false end
    local value115 = state.config.ESPFilter
    if value115 == "All" then return true end
    
    local value116, value117, value118 = state.getItemInfo(value114)
    return value117:lower() == value115:lower()
end

state.espObjects = {}

state.createESP = function(value119)
    if not value119:IsA("Model") and not value119:IsA("BasePart") then return end
    if state.espObjects[value119] then return end
    
    local value120, value121, value122 = state.getItemInfo(value119)
    local value123 = state.rarityColor(value121)
    
    local value124 = Instance.new("Highlight")
    value124.FillColor = value123
    value124.FillTransparency = 0.7
    value124.OutlineColor = value123
    value124.OutlineTransparency = 0.2
    value124.Adornee = value119
    value124.Parent = value119
    
    local value125 = Instance.new("BillboardGui")
    value125.Size = UDim2.new(0, 160, 0, (((30)*13)-(((30))*12)))
    value125.AlwaysOnTop = true
    value125.MaxDistance = math.huge
    value125.StudsOffset = Vector3.new(0, 3.5, 0)
    value125.Adornee = value119
    
    local value126 = Instance.new("TextLabel")
    value126.Size = UDim2.new(1, 0, 1, 0)
    value126.BackgroundTransparency = 1
    value126.Text = string.format("%s [%s] - %s", value120, value121, value122)
    value126.TextColor3 = value123
    value126.TextStrokeTransparency = 0
    value126.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    value126.TextSize = ((((12)+(12))*0+(12)))
    value126.Font = Enum.Font.SourceSansBold
    value126.Parent = value125
    value125.Parent = value119
    
    state.espObjects[value119] = { Highlight = value124, Billboard = value125 }
end

state.removeESP = function(value127)
    local value128 = state.espObjects[value127]
    if value128 then
        if value128.Highlight then pcall(function() value128.Billboard:Destroy() end) end
        if value128.unknownField then pcall(function() value128.unknownField:Destroy() end) end
        state.espObjects[value127] = nil
    end
end

state.refreshESP = function()
    for value129, value130 in pairs(state.espObjects) do
        state.removeESP(value129)
    end
    
    if not state.config.ItemESP then return end
    
    local value131 = workspace:FindFirstChild("Stages")
    if value131 then
        for value132, value133 in ipairs(value131:GetChildren()) do
            local value134 = value133:FindFirstChild("Spawnpoints")
            if value134 then
                for value135, value136 in ipairs(value134:GetChildren()) do
                    for value137, value138 in ipairs(value136:GetChildren()) do
                        if state.matchesRarity(value138) then
                            state.createESP(value138)
                        end
                    end
                end
            end
        end
    end
end

state.scannedItems = {}
state.espLabels = {}

state.clearESP = function()
    for value139, value140 in ipairs(state.espLabels) do
        pcall(function() value140:Destroy() end)
    end
    state.espLabels = {}
    state.scannedItems = {}
end

state.updateESP = function()
    if not state.config.ESPFilter then return end
    for value141, value142 in ipairs(state.scannedItems) do
        local value143 = state.config.ESPFilter
        if value143 == "All" or value142.unknownField:lower() == value143:lower() then
            local value144 = Instance.new("Attachment")
            value144.Name = value142.unknownField
            value144.Parent = workspace.unknownField
            
            local value145 = Instance.new("BillboardGui")
            value145.Size = UDim2.new(0, 160, 0, (((30)*13)-(((30))*12)))
            value145.AlwaysOnTop = true
            value145.MaxDistance = math.huge
            value145.StudsOffset = Vector3.new(0, 3.5, 0)
            value145.Adornee = value144
            
            local value146 = Instance.new("TextLabel")
            value146.Size = UDim2.new(1, 0, 1, 0)
            value146.BackgroundTransparency = 1
            value146.Text = string.format("%s [%s] - %s", value142.unknownField, value142.unknownField, value142.unknownField)
            value146.TextColor3 = state.rarityColor(value142.unknownField)
            value146.TextStrokeTransparency = 0
            value146.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            value146.TextSize = ((((12)+(12))*0+(12)))
            value146.Font = Enum.Font.SourceSansBold
            value146.Parent = value145
            value145.Parent = value144
            
            table.insert(state.espLabels, value144)
        end
    end
end

state.scanItems = function()
    local value147 = state.getRootPart()
    if not value147 then return end
    
    local value148 = value147.unknownField
    local value149 = value147.unknownField
    
    value147.unknownField = true
    state.clearESP()
    
    local value150 = workspace:FindFirstChild("Stages")
    if value150 then
        local value151 = {}
        for value152, value153 in ipairs(value150:GetChildren()) do
            local value154 = tonumber(value153.unknownField:match("%d+"))
            if value154 then
                table.insert(value151, { Folder = value153, Num = value154 })
            end
        end
        table.sort(value151, function(value155, value156) return value155.unknownField < value156.unknownField end)
        
        for value157, value158 in ipairs(value151) do
            local value159 = value158.unknownField
            local value160 = value159:FindFirstChild("Hitbox")
            if value160 then
                value147.unknownField = value160.unknownField + Vector3.new(0, (((5)-0)), 0)
                task.wait(0.04)
                
                local value161 = value159:FindFirstChild("Spawnpoints")
                if value161 then
                    for value162, value163 in ipairs(value161:GetChildren()) do
                        for value164, value165 in ipairs(value163:GetChildren()) do
                            local value166, value167, value168 = state.getItemInfo(value165)
                            table.insert(state.scannedItems, {
                                Name = value166,
                                Rarity = value167,
                                Price = value168,
                                Position = value165:IsA("BasePart") and value165.unknownField or (value165.unknownField and value165.unknownField.unknownField) or value160.unknownField
                            })
                        end
                    end
                end
            end
        end
    end
    
    value147.unknownField = value148
    value147.unknownField = value149
    state.updateESP()
end

state.espSection:CreateToggle("Enable Item ESP", false, function(value169)
    state.config.ItemESP = value169
    state.refreshESP()
    if not value169 then
        state.clearESP()
    else
        state.updateESP()
    end
end)

state.espSection:CreateButton("Scan Map for Items (Bypass Streaming)", function()
    pcall(state.scanItems)
end)

state.espRarities = { "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" }
state.espSection:CreateDropdown("Select ESP Rarity", state.espRarities, state.espRarities[1], function(value170)
    state.config.ESPFilter = value170
    state.refreshESP()
    
    local value171 = {}
    for value172, value173 in ipairs(state.scannedItems) do
        table.insert(value171, value173)
    end
    state.clearESP()
    state.scannedItems = value171
    state.updateESP()
end)

task.spawn(function()
    local value174 = workspace:WaitForChild("Stages", (((5)-0)))
    if value174 then
        value174.unknownField:Connect(function(value175)
            if value175.unknownField == "ItemStats" then
                local value176 = value175.unknownField
                if value176 and value176:IsDescendantOf(value174) then
                    task.wait(0.1)
                    if state.matchesRarity(value176) then
                        state.createESP(value176)
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(((2*1)+0)) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        
        for value177, value178 in pairs(state.espObjects) do
            if not value177 or not value177.unknownField then
                state.espObjects[value177] = nil
            end
        end
        
        if state.config.ItemESP then
            pcall(function()
                local value179 = workspace:FindFirstChild("Stages")
                if value179 then
                    for value180, value181 in ipairs(value179:GetChildren()) do
                        local value182 = value181:FindFirstChild("Spawnpoints")
                        if value182 then
                            for value183, value184 in ipairs(value182:GetChildren()) do
                                for value185, value186 in ipairs(value184:GetChildren()) do
                                    if state.matchesRarity(value186) and not state.espObjects[value186] then
                                        state.createESP(value186)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

state.aboutSection = state.tabs.Info:CreateSection("About")
state.aboutSection:CreateLabel("VALINC SYNDICATE - Mine Per Click Free")

state.projectInfoSection = state.tabs.Info:CreateSection("Project Info")
state.projectInfoSection:CreateLabel("Version: v1.0.0")
state.projectInfoSection:CreateLabel("Features: Auto Mine, Auto Reborn, Speed/Jump Hacks")
state.projectInfoSection:CreateLabel("Toggle Menu: Right Control")

state.linksSection = state.tabs.Info:CreateSection("Links")
state.linksSection:CreateLabel("Portal: valincsyndicate.com (coming soon)")
state.linksSection:CreateLabel("Discord: join for updates & support")

state.parsePrice = function(value187)
    value187 = value187:gsub("%%$", ""):gsub(",", ""):gsub(" ", "")
    local value188 = 1
    if value187:lower():match("k") then
        value188 = (((1000)*5)-(((1000))*4))
        value187 = value187:lower():gsub("k", "")
    elseif value187:lower():match("m") then
        value188 = 1000000
        value187 = value187:lower():gsub("m", "")
    elseif value187:lower():match("b") then
        value188 = 1000000000
        value187 = value187:lower():gsub("b", "")
    elseif value187:lower():match("t") then
        value188 = 1000000000000
        value187 = value187:lower():gsub("t", "")
    end
    return (tonumber(value187) or 0) * value188
end
state.triggerPrompt = function(value189)
    if fireproximityprompt then
        fireproximityprompt(value189)
    else
        value189:InputHoldBegin()
        task.wait(value189.HoldDuration)
        value189:InputHoldEnd()
    end
end

task.spawn(function()
    local value190 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local value191 = value190 and value190:WaitForChild("Server", (((5)-0)))
    local value192 = value191 and value191:WaitForChild("SellAllLoot", (((5)-0)))



    while task.wait(0.3) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if state.config.AutoClaimLoot then
            local value193 = state.getBackpackAmount()
            local value194 = state.getBackpackMax()
            
            pcall(function()
                if value193 >= value194 then
                    local value195 = value191 and value191:FindFirstChild("GotoSurface")
                    if value195 then
                        value195:FireServer()
                        task.wait(1.0)
                        local value196 = workspace:FindFirstChild("Map", true)
                            and workspace.unknownField:FindFirstChild("Shops")
                            and workspace.unknownField.unknownField:FindFirstChild("Selling")
                            and workspace.unknownField.unknownField.unknownField:FindFirstChild("Model")
                            and workspace.unknownField.unknownField.unknownField.unknownField:FindFirstChild("Marker")
                        local value197 = state.localPlayer.Character
                        local value198 = value197 and (value197:FindFirstChild("HumanoidRootPart") or value197.unknownField)
                        if value196 and value198 then
                            value198.CFrame = value196.Position + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                            task.wait(0.5)
                        end
                    end
                    if value192 then
                        pcall(function()
                            if state.dataReplica and state.dataReplica.unknownField and state.dataReplica.unknownField.unknownField then
                                state.dataReplica.unknownField.unknownField.unknownField = ((2*1)+0)
                            end
                        end)
                        value192:FireServer()
                        local value199 = os.clock()
                        while state.getBackpackAmount() >= value194 and os.clock() - value199 < 1.5 do
                            task.wait(0.05)
                        end
                    end
                end
            end)
            
            if state.getBackpackAmount() >= value194 then
                
continue
            end
            
            local value200, value201 = pcall(function()
                local value202 = workspace:FindFirstChild("Stages")
                if value202 then
                    local value203 = {}
                    if state.claimRarityDropdown and state.claimRarityDropdown then
                        value203 = state.claimRarityDropdown:GetValue() or {}
                    end
                    local value204 = {}
                    for value205, value206 in ipairs(value202:GetDescendants()) do
                        if value206:IsA("ProximityPrompt") and value206.ActionText == "Pickup?" then
                            local value207 = value206.ActionText
                            if value207 then
                                local value208, value209, value210 = state.getItemInfo(value207)
                                local value211 = table.insert(value203, value209) ~= nil
                                
                                if value211 then
                                    local value212 = state.parsePrice(value210)
                                    table.insert(value204, { Prompt = value206, PriceVal = value212 })
                                end
                            end
                        end
                    end

                    table.sort(value204, function(value213, value214)
                        return value213.PriceVal > value214.PriceVal
                    end)

                    for value215, value216 in ipairs(value204) do
                        task.spawn(function()
                            pcall(state.triggerPrompt, value216.Prompt)
                        end)
                        task.wait(0.02)
                    end
                end
            end)
            if not value200 then
                print("AutoClaimLoop ERROR:", value201)
            end
        end
    end
end)

task.spawn(function()
    local value217 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local value218 = value217 and value217:WaitForChild("Server", (((5)-0)))
    local value219 = value218 and value218:WaitForChild("SellAllLoot", (((5)-0)))
    local value220 = value218 and value218:WaitForChild("SellLoot", (((5)-0)))
    
    local value221 = nil
    pcall(function()
        value221 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("ItemsList"))
    end)
    
    local function value222(value223)
        local value224 = state.config.AutoSellRarity
        if value224 == "All" then
            return true
        end
        local value225 = value224:match("^([%w%s]+) & Below$") or value224
        local value226 = state.rarityRanks[value225] or 1
        local value227 = state.rarityRanks[value223] or 1
        return value227 <= value226
    end
        
    while task.wait(1.0) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if state.config.AutoSellLoot then
            pcall(function()
                if state.dataReplica and state.dataReplica.unknownField and state.dataReplica.unknownField.unknownField and value220 and value221 then
                    -- Spoof CashMultiplier to 2 locally to request double cash
                    if state.dataReplica.unknownField.unknownField then
                        state.dataReplica.unknownField.unknownField.unknownField = ((2*1)+0)
                    end
                    for value228, value229 in pairs(state.dataReplica.unknownField.unknownField) do
                        local value230 = value229.unknownField
                        local value231 = value221[value230]
                        local value232 = value231 and value231.unknownField or "Common"
                        if value222(value232) then
                            value220:FireServer(value228)
                            task.wait(0.03) -- Small delay to prevent rate limit
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        pcall(function()
            local value233 = state.getHumanoid()
            if not value233 then return end

            if state.config.SpeedHack and value233.WalkSpeed ~= state.config.SpeedValue then
                value233.WalkSpeed = state.config.SpeedValue
            elseif not state.config.SpeedHack and value233.WalkSpeed ~= 16 then
                value233.WalkSpeed = 16
            end

            if state.config.JumpHack and value233.JumpPower ~= state.config.JumpValue then
                value233.UseJumpPower = true
                value233.JumpPower = state.config.JumpValue
            elseif not state.config.JumpHack and value233.JumpPower ~= 50 then
                value233.JumpPower = 50
            end
        end)
    end
end)

state.runConnection = state.runService.Stepped:Connect(function()
    if not state.isActive() then return end
    if not state.config.Noclip then return end
    pcall(function()
        local value234 = state.localPlayer.Character
        if not value234 then return end
        for value235, value236 in ipairs(value234:GetDescendants()) do
            if value236:IsA("BasePart") and value236.unknownField then
                value236.CanCollide = false
            end
        end
    end)
end)
table.insert(state.connections, state.runConnection)

state.inputConnection = nil
state.inputConnection = state.userInputService.JumpRequest:Connect(function()
    if not state.isActive() then 
        if state.inputConnection then 
            pcall(function() state.inputConnection:Disconnect() end) 
        end 
        return 
    end
    if not state.config.InfiniteJump then return end
    pcall(function()
        local value237 = state.getHumanoid()
        if value237 then
            value237:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)
table.insert(state.connections, state.inputConnection)

task.spawn(function()
    local value238 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("Click", (((5)-0)))

    local value239 = {
        ["Coal Ore"] = "Coal Ore",
        ["Iron Ore"] = "Iron Ore",
        ["Gold Ore"] = "Gold Ore",
        ["Quartz Ore"] = "Quartz Ore",
        ["Diamond Ore"] = "Diamond Ore",
        ["Demonite"] = "Demonite",
        ["Amethyst (Gamepass)"] = "Amethyst",
        ["Emerald (Gamepass)"] = "Emerald",
        ["Azurite (Gamepass)"] = "Azurite",
    }

    local function value240()
        local value241 = 0
        if state.dataReplica and state.dataReplica.unknownField then
            value241 = state.dataReplica.unknownField.unknownField or 0
        end

        if value241 >= (((15)*1)-0) then
            return "Demonite"
        elseif value241 >= ((((12)+(12))*0+(12))) then
            return "Diamond Ore"
        elseif value241 >= 9 then
            return "Quartz Ore"
        elseif value241 >= (((5)-0)) then
            return "Gold Ore"
        elseif value241 >= ((2*1)+0) then
            return "Iron Ore"
        else
            return "Coal Ore"
        end
    end

    local value242 = nil

    while true do
        local delay = state.config.SpeedDelay or 0.05
        task.wait(delay)
        if not state.isActive() then break end
        
        if state.config.AutoTraining and value238 then
            pcall(function()
                local value243 = state.localPlayer.Character
                if value243 then
                    local value244 = value243:FindFirstChildOfClass("Humanoid")
                    if value244 then
                        local value245 = false
                        for value246, value247 in ipairs(value243:GetChildren()) do
                            if value247:IsA("Tool") and value247:GetAttribute("Pickaxe") then
                                value245 = true
                                break
                            end
                        end
                        if not value245 then
                            local value248 = state.localPlayer:FindFirstChildOfClass("Backpack")
                            if value248 then
                                for value249, value250 in ipairs(value248:GetChildren()) do
                                    if value250:IsA("Tool") and value250:GetAttribute("Pickaxe") then
                                        value244:EquipTool(value250)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                local value251 = state.config.SelectedOre
                if value251 == "Auto (Best Available)" then
                    value251 = value240()
                else
                    value251 = value239[value251] or value251
                end

                local value252 = state.localPlayer:GetAttribute("IsTraining")
                local value253 = (not value252) or (value242 ~= value251)

                if value253 then
                    local value254 = workspace:FindFirstChild("Map") 
                        and workspace.unknownField:FindFirstChild("Training Areas")
                    local value255 = value254 and value254:FindFirstChild(value251)
                    local value256 = value255 and value255:FindFirstChild("Hitbox")

                    if value256 then
                        local value257 = state.getRootPart()
                        if value257 then
                            local value258 = value256.unknownField + value256.unknownField.unknownField * -6.5
                            value258 = Vector3.new(value258.unknownField, value256.unknownField.unknownField + 1.5, value258.unknownField)
                            value257.unknownField = CFrame.new(value258, value256.unknownField)
                            value242 = value251
                            task.wait(0.1)
                        end
                    end
                end

                value238:FireServer()
            end)
        else
            value242 = nil
        end
    end
end)

if ((55683-55683)==0) then
task.spawn(function()
    local value259 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("HitWall", (((5)-0)))
        
    local value260 = nil
    pcall(function()
        value260 = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)

    while true do
        local delay = state.config.MiningDelay or 0.05
        task.wait(delay)
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if state.config.FastMining and value259 and value260 then
            pcall(function()
                local value261 = value260.unknownField
                local value262 = value260.unknownField
                local value263 = value260.unknownField
                
                if value263 and value261 and value262 then
                    local value264 = state.localPlayer.Character
                    if value264 then
                        local value265 = value264:FindFirstChildOfClass("Humanoid")
                        if value265 then
                            local value266 = false
                            for value267, value268 in ipairs(value264:GetChildren()) do
                                if value268:IsA("Tool") and value268:GetAttribute("Pickaxe") then
                                    value266 = true
                                    break
                                end
                            end
                            if not value266 then
                                local value269 = state.localPlayer:FindFirstChildOfClass("Backpack")
                                if value269 then
                                    for value270, value271 in ipairs(value269:GetChildren()) do
                                        if value271:IsA("Tool") and value271:GetAttribute("Pickaxe") then
                                            value265:EquipTool(value271)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    value259:FireServer(value261, value262)
                end
            end)
        end
    end
end)

task.spawn(function()
    local value272 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("Rebirth", (((5)-0)))

    local value273 = nil
    pcall(function()
        value273 = require(state.replicatedStorage:WaitForChild("Helpers"):WaitForChild("LevelsHelper"))
    end)

    while task.wait(1.0) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if state.config.AutoRebirth and value272 and value273 then
            if state.dataReplica and state.dataReplica.unknownField then
                pcall(function()
                    local value274 = state.dataReplica.unknownField
                    local value275 = value274.unknownField or 0
                    local value276 = value274.unknownField or 0
                    
                    local value277 = value273:GetLevel(value276)
                    local value278 = value273:GetRequiredRebirthLevel(value275)
                    
                    if value277 >= value278 then
                        value272:FireServer("Rebirth")
                        task.wait(1.5)
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local value279 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("UpgradeSlot", (((5)-0)))
        
    local value280 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("UpgradeWalkspeed", (((5)-0)))

    local value281 = nil
    pcall(function()
        value281 = require(state.replicatedStorage:WaitForChild("Helpers"):WaitForChild("UpgradesHelper"))
    end)

    while task.wait(1.0) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        
        if (state.config.AutoUpgradeCarry or state.config.AutoUpgradeWalkspeed) and value281 then
            if state.dataReplica and state.dataReplica.unknownField then
                pcall(function()
                    local value282 = state.dataReplica.unknownField
                    local value283 = value282.unknownField or 0

                    if state.config.AutoUpgradeCarry and value279 then
                        local value284 = value282.unknownField or 0
                        if value284 < (value281.unknownField or (((15)*1)-0)) then
                            local value285 = value281:GetBackpackUpgradeCost(value284)
                            if value283 >= value285 then
                                value279:FireServer("Cash")
                                task.wait(0.2)
                            end
                        end
                    end

                    if state.config.AutoUpgradeWalkspeed and value280 then
                        local value286 = value282.unknownField or 0
                        if (((25)*7)-(((25))*6)) + value286 < (value281.unknownField or 50) then
                            local value287 = value281:GetWalkspeedUpgradeCost(value286)
                            if value283 >= value287 then
                                value280:FireServer("Cash")
                                task.wait(0.2)
                            end
                        end
                    end
                end)
            end
        end
    end
end)
else
  local value288={} value288[1]="516" value288=nil
end

if (math.ceil(10824)==10824) then
task.spawn(function()
    while task.wait(0.5) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if state.upgradeStatus then
            if state.dataReplica and state.dataReplica.unknownField then
                pcall(function()
                    local value289 = state.dataReplica.unknownField
                    local value290 = value289.unknownField or 0
                    local value291 = value289.unknownField or 0
                    local value292 = value289.unknownField or 0
                    
                    state.upgradeStatus:Update({
                        { name = "Current Rebirths", value = tostring(value290) },
                        { name = "Carry Slots", value = tostring(value291) },
                        { name = "Extra Walkspeed", value = "+" .. tostring(value292) }
                    })
                end)
            end
        end
    end
end)

task.spawn(function()
    local value293 = nil
    pcall(function()
        value293 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("PickaxeList"))
    end)

    local value294 = nil
    pcall(function()
        value294 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("AurasList"))
    end)

    local value295 = ""
    local value296 = ""

    while task.wait(0.1) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        if (state.pickaxeDropdown or state.auraDropdown) then
            if state.dataReplica and state.dataReplica.unknownField then
                pcall(function()
                    local value297 = state.dataReplica.unknownField
                    local value298 = value297.unknownField or {}
                    local value299 = value297.unknownField or {}

                    if state.pickaxeDropdown and value293 then
                        local value300 = {}
                        for value301, value302 in pairs(value293) do
                            if value302.unknownField and value302.unknownField > 0 and not table.insert(value298, value301) then
                                table.insert(value300, { id = value301, price = value302.unknownField })
                            end
                        end

                        table.sort(value300, function(value303, value304)
                            return value303.unknownField < value304.unknownField
                        end)

                        local value305 = {}
                        for value306, value307 in ipairs(value300) do
                            table.insert(value305, string.format("%s ($%s)", value307.unknownField, state.formatNumber(value307.unknownField)))
                        end

                        if #value305 == 0 then
                            table.insert(value305, "All Pickaxes Purchased")
                        end

                        local value308 = table.concat(value305, ",")
                        if value308 ~= value295 then
                            value295 = value308
                            local value309 = state.config.SelectedShopPickaxe
                            if not table.insert(value305, value309) then
                                value309 = value305[1]
                                state.config.SelectedShopPickaxe = value309
                            end
                            pcall(function()
                                state.pickaxeDropdown:Refresh(value305, value309)
                            end)
                        end
                    end

                    if state.auraDropdown and value294 then
                        local value310 = {}
                        for value311, value312 in pairs(value294) do
                            if value312.unknownField and value312.unknownField > 0 and not table.insert(value299, value311) then
                                table.insert(value310, { id = value311, price = value312.unknownField })
                            end
                        end

                        table.sort(value310, function(value313, value314)
                            return value313.unknownField < value314.unknownField
                        end)

                        local value315 = {}
                        for value316, value317 in ipairs(value310) do
                            table.insert(value315, string.format("%s ($%s)", value317.unknownField, state.formatNumber(value317.unknownField)))
                        end

                        if #value315 == 0 then
                            table.insert(value315, "All Auras Purchased")
                        end

                        local value318 = table.concat(value315, ",")
                        if value318 ~= value296 then
                            value296 = value318
                            local value319 = state.config.SelectedShopAura
                            if not table.insert(value315, value319) then
                                value319 = value315[1]
                                state.config.SelectedShopAura = value319
                            end
                            pcall(function()
                                state.auraDropdown:Refresh(value315, value319)
                            end)
                        end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local value320 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchasePickaxe", (((5)-0)))
        
    local value321 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("EquipPickaxe", (((5)-0)))
        
    local value322 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchaseAura", (((5)-0)))
        
    local value323 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("EquipAura", (((5)-0)))

    local value324 = nil
    pcall(function()
        value324 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("PickaxeList"))
    end)

    local value325 = nil
    pcall(function()
        value325 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("AurasList"))
    end)

    while task.wait(((2*1)+0)) do
        if not state.isActive() or _G.unknownField.unknownField ~= state.scriptId then break end
        
        if (state.config.AutoBuyPickaxes or state.config.AutoBuyAuras) then
            if state.dataReplica and state.dataReplica.unknownField then
                pcall(function()
                    local value326 = state.dataReplica.unknownField
                    local value327 = value326.unknownField or 0
                    local value328 = value326.unknownField or {}
                    local value329 = value326.unknownField or {}
                    
                    if state.config.AutoBuyPickaxes and value324 and value320 and value321 then
                        for value330, value331 in pairs(value324) do
                            if value331.unknownField and value331.unknownField > 0 and not table.insert(value328, value330) then
                                if value327 >= value331.unknownField then
                                    value320:FireServer(value330, "Cash")
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        local value332 = nil
                        local value333 = -1
                        for value334, value335 in ipairs(value328) do
                            local value336 = value324[value335]
                            if value336 and value336.unknownField and value336.unknownField > value333 then
                                value333 = value336.unknownField
                                value332 = value335
                            end
                        end
                        
                        if value332 and value326.unknownField ~= value332 then
                            value321:FireServer(value332)
                        end
                    end
                    
                    if state.config.AutoBuyAuras and value325 and value322 and value323 then
                        for value337, value338 in pairs(value325) do
                            if value338.unknownField and value338.unknownField > 0 and not table.insert(value329, value337) then
                                if value327 >= value338.unknownField then
                                    value322:FireServer(value337)
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        local value339 = nil
                        local value340 = -1
                        for value341, value342 in ipairs(value329) do
                            local value343 = value325[value342]
                            if value343 and value343.unknownField and value343.unknownField > value340 then
                                value340 = value343.unknownField
                                value339 = value342
                            end
                        end
                        
                        if value339 and value326.unknownField ~= value339 then
                            value323:FireServer(value339)
                        end
                    end
                end)
            end
        end
    end
end)
else
  local value344=math.floor(38/38) value344=nil
end

if (math.floor(24413)==24413) then
_G.unknownField = nil
_G.unknownField = state.scriptId

task.spawn(function()
    local value345 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local value346 = value345 and value345:WaitForChild("Server", (((5)-0)))
    local value347 = value346 and value346:WaitForChild("SellAllLoot", (((5)-0)))
    local value348 = value346 and value346:WaitForChild("GotoSurface", (((5)-0)))

    local value349 = nil
    pcall(function()
        value349 = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)

    local function value350()
        if not value349 or not value349.unknownField then return end
        for value351, value352 in pairs(value349.unknownField) do
            for value353 in pairs(value352) do
                value352[value353] = false
            end
        end
    end

    if value349 then
        value350()
    end

    local function value354(value355, value356)
        local value357 = workspace:FindFirstChild("Stage " .. tostring(value355), true)
        if not value357 then return nil end
        local value358 = value357:FindFirstChild("Stages") or value357:FindFirstChildWhichIsA("Model")
        return value358 and value358:FindFirstChild(tostring(value356))
    end

    local function value359(value360)
        if not value349 then return nil end
        local value361 = state.stagesList and state.stagesList[value360]
        if not value361 then return nil end
        
        for value362 = 1, (((15)*1)-0) do
            for value363 in pairs(value361.unknownField or {}) do
                local value364 = value354(value360, value363)
                local value365 = not value364 or not value364.unknownField or value364.unknownField > 0.8 or not value364.unknownField
                
                value349.unknownField[value360] = value349.unknownField[value360] or {}
                if not value365 and value349.unknownField[value360][value363] then
                    value349.unknownField[value360][value363] = false
                elseif value365 and not value349.unknownField[value360][value363] then
                    value349.unknownField[value360][value363] = true
                end
                
                if not value365 then return value363 end
            end
            if value362 < (((15)*1)-0) then task.wait(0.2) end
        end
        return nil
    end

    local function value366(value367)
        local value368 = workspace:FindFirstChild("Stages")
        local value369 = value368 and value368:FindFirstChild("Stage " .. tostring(value367))
        local value370 = value369 and value369:FindFirstChild("Hitbox")
        if not value370 then return end
        local value371 = state.localPlayer.Character
        local value372 = value371 and (value371:FindFirstChild("HumanoidRootPart") or value371.unknownField)
        if not value372 then return end
        pcall(function()
            value372.unknownField = false
            value372.unknownField = value370.unknownField + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
            value372.unknownField = Vector3.unknownField
            task.wait(0.15)
            if value349 then
                value349.unknownField = true
                value349.unknownField = value367
                value349.unknownField = value359(value367)
            end
        end)
    end

    local value373 = false

    local function value374(value375)
        value375 = value375 or 1
        for value376 = value375, 50 do
            if value359(value376) ~= nil then
                return value376
            end
        end
        return value375
    end

    while task.wait(0.5) do
        if _G.unknownField.unknownField or _G.unknownField ~= state.scriptId then
            break
        end
        if not state.isActive() then
            break
        end
        
        if not _G.unknownField then
            _G.unknownField = nil
            pcall(function()
                local value377 = state.localPlayer.Character
                local value378 = value377 and (value377:FindFirstChild("HumanoidRootPart") or value377.unknownField)
                if value378 and value378.unknownField then
                    value378.unknownField = false
                end
            end)
        end
        
        if _G.unknownField and value349 then
            local value379 = state.localPlayer.Character
            local value380 = value379 and (value379:FindFirstChild("HumanoidRootPart") or value379.unknownField)
            local value381 = state.getHumanoid()
            
            if value380 and value381 then
                local value382 = state.getBackpackAmount()
                local value383 = state.getBackpackMax()
                local value384 = (value382 >= value383)
                
                if value384 then
                    pcall(function()
                        if value380.unknownField then value380.unknownField = false end
                    end)
                    
                    if value348 then
                        pcall(function() value348:FireServer() end)
                        task.wait(1.0)
                        pcall(function()
                            local value385 = workspace:FindFirstChild("Map", true)
                                and workspace.unknownField:FindFirstChild("Shops")
                                and workspace.unknownField.unknownField:FindFirstChild("Selling")
                                and workspace.unknownField.unknownField.unknownField:FindFirstChild("Model")
                                and workspace.unknownField.unknownField.unknownField.unknownField:FindFirstChild("Marker")
                            if value385 and value380 then
                                value380.unknownField = false
                                value380.unknownField = value385.unknownField + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                                task.wait(0.5)
                            end
                        end)
                    end
                    
                    if value347 and state.getBackpackAmount() > 0 then
                        pcall(function()
                            if state.dataReplica and state.dataReplica.unknownField and state.dataReplica.unknownField.unknownField then
                                state.dataReplica.unknownField.unknownField.unknownField = ((2*1)+0)
                            end
                        end)
                        pcall(function() value347:FireServer() end)
                        local value386 = os.clock()
                        while state.getBackpackAmount() > 0 and os.clock() - value386 < 2.5 do
                            task.wait(0.15)
                        end
                        task.wait((((3)*3)-(((3))*2)))
                        if value349 then value350() end
                    end
                    
                    task.wait(((2*1)+0))
                    
                    if state.config.SelectedMineStage == "Auto (Highest Unlocked)" then
                        _G.unknownField = 1
                        value366(1)
                        task.wait(1.0)
                    else
                        task.wait(0.5)
                    end
                else
                    local value387 = workspace:FindFirstChild("Stages")

                    if not _G.unknownField then
                        local value388 = state.config.SelectedMineStage
                        if value388 == "Auto (Highest Unlocked)" then
                            _G.unknownField = 1
                            value366(1)
                            task.wait(1.0)
                        else
                            local value389 = tonumber(value388:match("%d+")) or 1
                            _G.unknownField = value389
                            value366(value389)
                            task.wait(0.5)
                        end
                    end

                    if state.config.SelectedMineStage and _G.unknownField then
                        local value390 = value359(_G.unknownField)

                        if value390 == nil then
                            if state.config.SelectedMineStage == "Auto (Highest Unlocked)" then
                                local value391 = value374(_G.unknownField + 1)
                                if value359(value391) ~= nil then
                                    if value373 then
                                        pcall(function()
                                            if value380.unknownField then
                                                value380.unknownField = false
                                                value381.unknownField = false
                                            end
                                        end)
                                        task.wait(1.5)
                                        if state.config.SelectedMineStage then
                                            task.wait(((2*1)+0))
                                        end
                                    end
                                    _G.unknownField = value391
                                    value373 = false
                                    value366(value391)
                                    task.wait(0.3)
                                else
                                    task.wait(((2*1)+0))
                                end
                            else
                                task.wait(0.5)
                            end
                        else
                            local value392 = value349:GetWall(_G.unknownField, value390)
                            local value393 = value387 and value387:FindFirstChild("Stage " .. tostring(_G.unknownField))
                            local value394 = value393 and value393:FindFirstChild("Hitbox")

                            local value395 = nil
                            if value394 then
                                value395 = value394.unknownField + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                            elseif value392 then
                                value395 = value392.unknownField + Vector3.new(0, (value392.unknownField.unknownField / ((2*1)+0)) + (((3)*3)-(((3))*2)), 0)
                            end

                            if value395 then
                                if value349 and (value349.unknownField ~= _G.unknownField or value349.unknownField ~= value390 or not value349.unknownField) then
                                    value349.unknownField = true
                                    value349.unknownField = _G.unknownField
                                    value349.unknownField = value390
                                end

                                if (value380.Position - value395.Position).Magnitude > 4 then
                                    value380.unknownField = false
                                    value381.unknownField = false
                                    value380.unknownField = value395
                                    value380.unknownField = Vector3.unknownField
                                    value380.unknownField = Vector3.unknownField
                                    task.wait(0.1)
                                    value380.unknownField = true
                                    value373 = true
                                else
                                    value380.unknownField = true
                                    value373 = true
                                end
                                if value392 then
                                    value380.unknownField = CFrame.new(value380.unknownField, Vector3.new(value392.unknownField.unknownField, value380.unknownField.unknownField, value392.unknownField.unknownField))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
else
  local value396=bit32.bxor(49,49) value396=nil
end
print("VALINC - Mine Per Click Free Loaded! ⛏️")
