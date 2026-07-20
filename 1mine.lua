-- Deobfuscated from 1mineperclick.lua.
-- Decoder, anti-analysis checks, encrypted string pool, and slot indirection removed.
-- [0] markers remain where original property names were already erased by the input.

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
  local _IliloiooIlIoIO="26" _IliloiooIlIoIO=_IliloiooIlIoIO:sub(1,0)
end
do
if (21 - 21) ~= 0 then
  local _IliloOil = {}
  _IliloOil[711] = 986
  _IliloOil = nil
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
    local _OI01lOi1O0ii1iI, _O1lolIOo1I00IO1 = pcall(function()
        return state.dataClient[0][0]
    end)
    if _OI01lOi1O0ii1iI and _O1lolIOo1I00IO1 then
        state.dataReplica = _O1lolIOo1I00IO1
    else
        state.dataReplica = state.dataClient:GetReplica()
    end
end)

if ((58639>0)) then
state.scriptId = tostring(math.random()) .. "_" .. tostring(os.clock())

if _G[0] then
    _G[0][0] = true
    pcall(function()
        if _G[0][0] then
            _G[0][0]:Destroy()
        end
    end)
    pcall(function()
        if _G[0][0] then
            for _1OOiilol, _lOooiO1Ili01iIO in ipairs(_G[0][0]) do
                if _lOooiO1Ili01iIO and _lOooiO1Ili01iIO[0] then
                    pcall(function() _lOooiO1Ili01iIO:Disconnect() end)
                end
            end
        end
    end)
    pcall(function()
        local _0xI1i1O0OoiI = state.localPlayer.Character
        local _Illl0011Ill = _0xI1i1O0OoiI and _0xI1i1O0OoiI:FindFirstChildOfClass("Humanoid")
        if _Illl0011Ill then
            _Illl0011Ill[0] = 16
            _Illl0011Ill[0] = 50
        end
    end)
end

state.connections = {}
else
  local _O1loI11ii1I=math.floor(240/240) _O1loI11ii1I=nil
end
_G[0] = {
    stopThreads = false,
    ScriptId = state.scriptId,
    UI = nil,
    Connections = state.connections,
}

state.stageNames = { "Auto (Highest Unlocked)" }
state.stagesList = nil
pcall(function()
    local _OI0l1i0IiiIloO = state.replicatedStorage:WaitForChild("Databases", (((3)*3)-(((3))*2)))
    if _OI0l1i0IiiIloO then
        state.stagesList = require(_OI0l1i0IiiIloO:WaitForChild("StagesList", (((3)*3)-(((3))*2))))
    end
end)

if type(state.stagesList) == "table" then
    for _Ill1O1l1 = 1, #state.stagesList do
        table.insert(state.stageNames, "Stage " .. tostring(_Ill1O1l1))
    end
else
    for _lO0lolOlIo = 1, (((100)*1)-0) do
        table.insert(state.stageNames, "Stage " .. tostring(_lO0lolOlIo))
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
    local _lO0OO0iii = _G[0]
    return _lO0OO0iii and not _lO0OO0iii[0] and _lO0OO0iii[0] == state.scriptId
end

state.getHumanoid = function()
    local _OIIo0lO01I1oo1o = state.localPlayer.Character
    return _OIIo0lO01I1oo1o and _OIIo0lO01I1oo1o:FindFirstChildOfClass("Humanoid")
end

state.getRootPart = function()
    local _OIIoOlOi0io0o = state.localPlayer.Character
    return _OIIoOlOi0io0o and (_OIIoOlOi0io0o:FindFirstChild("HumanoidRootPart") or _OIIoOlOi0io0o.PrimaryPart)
end
do
if (187 * 0) > 0 then
  local _OI1i010oIliI0l = ""
  local _IlOOoiOlIoII0 = _OI1i010oIliI0l .. "934"
  _IlOOoiOlIoII0 = nil
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
state.formatNumber = function(_O10ooo011101l)
    if not _O10ooo011101l or _O10ooo011101l < (((1000)*5)-(((1000))*4)) then
        return tostring(math.floor(_O10ooo011101l or 0))
    end
    local _O1l1l0oOOI0i = math.floor(math.log(_O10ooo011101l, 1000))
    local _0xiIII11OIO1iIl = math.min(_O1l1l0oOOI0i, #state.numberSuffixes - 1)
    local _lOliolOIiIli = _O10ooo011101l / ((((1000)*5)-(((1000))*4)) ^ _0xiIII11OIO1iIl)
    local _lII11II0oOIoOI = state.numberSuffixes[1]
    
    if _lOliolOIiIli >= (((100)*1)-0) then
        return string.format("%.0f%s", _lOliolOIiIli, _lII11II0oOIoOI)
    elseif _lOliolOIiIli >= 10 then
        return string.format("%.1f%s", _lOliolOIiIli, _lII11II0oOIoOI)
    else
        return string.format("%.2f%s", _lOliolOIiIli, _lII11II0oOIoOI)
    end
end

state.getBackpackAmount = function()
    local _0xl1ii0oOollI1i = nil
    pcall(function()
        _0xl1ii0oOollI1i = state.localPlayer.Character:FindFirstChild("Main")
            and state.localPlayer.Character[0]:FindFirstChild("Wins")
            and state.localPlayer.Character[0][0]:FindFirstChild("BackpackFrame")
            and state.localPlayer.Character[0][0][0]:FindFirstChild("Amount")
    end)
    
    local _1Ol1IloOo110 = nil
    if _0xl1ii0oOollI1i then
        pcall(function()
            local _OIllliOo0 = _0xl1ii0oOollI1i[0]
            _1Ol1IloOo110 = tonumber(_OIllliOo0:match("^(%d+)%s*/"))
        end)
    end
    if _1Ol1IloOo110 then
        return _1Ol1IloOo110
    end
    
    local _0xloOOiI0o0 = 0
    if state.dataReplica and state.dataReplica[0] and state.dataReplica[0][0] then
        for _lIiIio0i, _OIOII0olI in pairs(state.dataReplica[0][0]) do
            _0xloOOiI0o0 = _0xloOOiI0o0 + 1
        end
    end
    return _0xloOOiI0o0
end
else
  local _1O1IIiOOi={} _1O1IIiOOi[1]="953" _1O1IIiOOi=nil
end

state.getBackpackMax = function()
    local _0xOiO010 = nil
    pcall(function()
        _0xOiO010 = state.localPlayer.Character:FindFirstChild("Main")
            and state.localPlayer.Character[0]:FindFirstChild("Wins")
            and state.localPlayer.Character[0][0]:FindFirstChild("BackpackFrame")
            and state.localPlayer.Character[0][0][0]:FindFirstChild("Amount")
    end)
    
    local _lIoli1lO = nil
    if _0xOiO010 then
        pcall(function()
            local _lIi01iII1l0 = _0xOiO010[0]
            _lIoli1lO = tonumber(_lIi01iII1l0:match("/%s*(%d+)"))
        end)
    end
    if _lIoli1lO then
        return _lIoli1lO
    end
    
    if state.dataReplica and state.dataReplica[0] then
        return state.dataReplica[0][0] or 10
    end
    return 10
end

state.getCurrentStage = function()
    local _O1i10i0I = nil
    pcall(function()
        _O1i10i0I = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)
    if _O1i10i0I and _O1i10i0I[0] then
        return "Stage " .. tostring(_O1i10i0I[0])
    end
    
    local _lIOOOl0loiiI = workspace:FindFirstChild("Stages")
    if _lIOOOl0loiiI then
        local _0x1oi0111OioolO = nil
        local _lI00I0il1i = math.huge
        local _0xii0O0I1iI1Ioo = state.getRootPart()
        if _0xii0O0I1iI1Ioo then
            for _1OO0iio0i, _OI11I0o1ol0o11 in ipairs(_lIOOOl0loiiI:GetChildren()) do
                local _0xIOoii1i1 = _OI11I0o1ol0o11:FindFirstChild("Hitbox")
                if _0xIOoii1i1 then
                    local _O10IoOo1Ioo = (_0xii0O0I1iI1Ioo.Position - _0xIOoii1i1.Position).Magnitude
                    if _O10IoOo1Ioo < _lI00I0il1i then
                        _lI00I0il1i = _O10IoOo1Ioo
                        _0x1oi0111OioolO = _OI11I0o1ol0o11[0]
                    end
                end
            end
        end
        if _0x1oi0111OioolO then
            return _0x1oi0111OioolO
        end
    end
    return "Stage 1"
end

state.uiLibraryState = _G[0]
if ((63747*(63747+1))%2==0) then
if not state.uiLibraryState then
    local _lO0OoOI0IOi00, _lIo0loIlio1 = pcall(function()
        state.uiLibraryState = loadstring(game:HttpGet(
            "https://cdn.vinzhub.com/scripts/Liblery%20Ui/VALINC%20QUARTZ/1e72163d8c3b5ce2340659f7f67776e3/ff342f0b0e66c7835ba0697c21422a0229a990d57e7c2f6f.lua"
        ))()
    end)
    if not _lO0OoOI0IOi00 then return end
end

state.window = state.uiLibraryState[0]({
    Title = "VALINC SYNDICATE",
    Subtitle = "Mine Per Click Free v1.0.0",
    Logo = "rbxassetid://107101390544126",
    ToggleKey = Enum.KeyCode.G
})

_G[0][0] = state.window[0] or state.window[0] or state.window
else
  local _1O0IloOlooiI010=math.floor(914/914) _1O0IloOlooiI010=nil
end

if ((38406>0)) then
pcall(function()
    local _lOooOO1oill = _G[0][0]
    local _O1Il1i00IIl = _lOooOO1oill:FindFirstChild("TabList", true)
    local _lOI1l101oi11ioI = _O1Il1i00IIl and _O1Il1i00IIl:FindFirstChildOfClass("UIListLayout")
    if _lOI1l101oi11ioI then _lOI1l101oi11ioI.SortOrder = Enum.SortOrder.LayoutOrder end
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
  local _lIlOIIi000lIo0=nil _lIlOIIi000lIo0=212 _lIlOIIi000lIo0=nil
end

state.autoSection:CreateToggle("Auto Training", false, function(_OI0IIilOOl)
    state.config.AutoTraining = _OI0IIilOOl
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
}, "Auto (Best Available)", function(_lOO0iioiliO)
    state.config.SelectedOre = _lOO0iioiliO
end)

state.autoSection:CreateSlider("Training Speed (Seconds)", 0.01, 1.0, 0.05, false, function(_lIoOl0ii)
    state.config.SpeedDelay = _lIoOl0ii
end)

if ((228+208)>=0) then
state.autoSection:CreateToggle("Fast Mining (Wall)", false, function(_lO0OolI0oO1Oo)
    state.config.FastMining = _lO0OolI0oO1Oo
end)

state.autoSection:CreateSlider("Mining Speed (Seconds)", 0.001, 1.0, 0.05, false, function(_O1Oilil00loIi)
    state.config.MiningDelay = _O1Oilil00loIi
end)

state.autoMineToggle = state.autoSection:CreateToggle("Auto Mine", false, function(_lOlO01l0o0il)
    state.config.AutoMine = _lOlO01l0o0il
    _G[0] = _lOlO01l0o0il
    if _lOlO01l0o0il then
        _G[0] = nil
        _G[0] = state.scriptId
    end
end)
else
  local _lI0000io0lI0I0I=bit32.bxor(522,522) _lI0000io0lI0I0I=nil
end

state.autoSection:CreateDropdown("Select Stage", state.stageNames, state.stageNames[1], function(_lIiioIolilio0O1)
    state.config.SelectedMineStage = _lIiioIolilio0O1
end)

state.sellSection = state.tabs.Automatic:CreateSection("Auto Sell Settings")
do
if (1 - 1) ~= 0 then
  local _OI01IlOO, _OI0oll1ooi, _O1IlIlo0 = nil, nil, nil
  _OI01IlOO = 869
  _OI0oll1ooi = _OI01IlOO - _OI01IlOO
  _O1IlIlo0 = _OI0oll1ooi
end
end

state.sellSection:CreateToggle("Auto Claim Loot", false, function(_OIlillIIiOil01i)
    state.config.AutoClaimLoot = _OIlillIIiOil01i
end)

if ((58191>0)) then
state.claimRarityDropdown = state.sellSection:CreateMultiDropdown(
    "Select Claim Rarity",
    { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" },
    { "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" },
    function() end
)

state.sellSection:CreateToggle("Auto Sell Loot", false, function(_lOoil00ioO)
    state.config.AutoSellLoot = _lOoil00ioO
end)

state.sellRarities = { "All", "Common", "Uncommon & Below", "Rare & Below", "Epic & Below", "Legendary & Below", "Mythic & Below" }
else
  local _O1O1liOoiliil=nil _O1O1liOoiliil=213 _O1O1liOoiliil=nil
end
state.sellSection:CreateDropdown("Select Sell Rarity", state.sellRarities, state.sellRarities[1], function(_O1l1OlIIo0l)
    state.config.AutoSellRarity = _O1l1OlIIo0l
end)

state.sellSection:CreateButton("Teleport to Surface (GotoSurface)", function()
    pcall(function()
        local _1OI1l1I1IIooI1l = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
        local _0xOIIoio01io = _1OI1l1I1IIooI1l and _1OI1l1I1IIooI1l:WaitForChild("Server", (((5)-0)))
        local _1Oll0IlO01iO = _0xOIIoio01io and _0xOIIoio01io:WaitForChild("GotoSurface", (((5)-0)))
        if _1Oll0IlO01iO then
            _1Oll0IlO01iO:FireServer()
        end
    end)
end)

state.upgradeSection = state.tabs.Automatic:CreateSection("Auto Upgrades")

if ((19670>0)) then
state.upgradeSection:CreateToggle("Auto Rebirth", false, function(_OIlI11li)
    state.config.AutoRebirth = _OIlI11li
end)

state.upgradeSection:CreateToggle("Auto Upgrade Carry (Slots)", false, function(_1OiOOi1lIO0lI)
    state.config.AutoUpgradeCarry = _1OiOOi1lIO0lI
end)

state.upgradeSection:CreateToggle("Auto Upgrade Walkspeed", false, function(_OIlolo00ioi)
    state.config.AutoUpgradeWalkspeed = _OIlolo00ioi
end)
else
  local _1OO1OlOllIioOOi={} _1OO1OlOllIioOOi[1]="184" _1OO1OlOllIioOOi=nil
end

if ((42877-42877)==0) then
state.upgradeStatus = state.upgradeSection:CreateStatusList("Upgrade Statistics Status", {
    { name = "Current Rebirths", value = "-" },
    { name = "Carry Slots", value = "-" },
    { name = "Extra Walkspeed", value = "-" }
})

state.shopSection = state.tabs.Shop:CreateSection("Manual Shop")

state.pickaxeDropdown = state.shopSection:CreateDropdown("Select Pickaxe", { "-" }, "-", function(_OIil1iliIoi1OO)
    state.config.SelectedShopPickaxe = _OIil1iliIoi1OO
end)
else
  local _lOiillO1l1o=nil _lOiillO1l1o=655 _lOiillO1l1o=nil
end

state.shopSection:CreateButton("Purchase Selected Pickaxe", function()
    local _O11OIIOl111 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchasePickaxe", (((5)-0)))
    if _O11OIIOl111 and state.config.SelectedShopPickaxe then
        pcall(function()
            local _OIli0lili01oiIo = state.config.SelectedShopPickaxe:match("^(.-)%s*%(%$.-%)$") or state.config.SelectedShopPickaxe
            if _OIli0lili01oiIo ~= "All Pickaxes Purchased" and _OIli0lili01oiIo ~= "-" then
                _O11OIIOl111:FireServer(_OIli0lili01oiIo, "Cash")
            end
        end)
    end
end)

state.auraDropdown = state.shopSection:CreateDropdown("Select Aura", { "-" }, "-", function(_Il00Oi0O1II)
    state.config.SelectedShopAura = _Il00Oi0O1II
end)

state.shopSection:CreateButton("Purchase Selected Aura", function()
    local _lOI1i00Ilii = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchaseAura", (((5)-0)))
    if _lOI1i00Ilii and state.config.SelectedShopAura then
        pcall(function()
            local _1O0oOOo1IiOlo = state.config.SelectedShopAura:match("^(.-)%s*%(%$.-%)$") or state.config.SelectedShopAura
            if _1O0oOOo1IiOlo ~= "All Auras Purchased" and _1O0oOOo1IiOlo ~= "-" then
                _lOI1i00Ilii:FireServer(_1O0oOOo1IiOlo)
            end
        end)
    end
end)

state.autoBuySection = state.tabs.Shop:CreateSection("Auto Buy Shop")

state.autoBuySection:CreateToggle("Auto Buy Pickaxes", false, function(_O1lliio1oIOIII1)
    state.config.AutoBuyPickaxes = _O1lliio1oIOIII1
end)

state.autoBuySection:CreateToggle("Auto Buy Auras", false, function(_0x0lOiO0)
    state.config.AutoBuyAuras = _0x0lOiO0
end)
do
if (223 - 223) ~= 0 then
  local _lIo1iIl0I = ""
  local _OIOIoolI = _lIo1iIl0I .. "611"
  _OIOIoolI = nil
end
end

state.physicsSection = state.tabs.Movement:CreateSection("Custom Physics")

state.physicsSection:CreateToggle("Walk Speed Hack", false, function(_1OI10oOoOOO1lO)
    state.config.SpeedHack = _1OI10oOoOOO1lO
    if not _1OI10oOoOOO1lO then
        local _lO0OOioiO00 = state.getHumanoid()
        if _lO0OOioiO00 then _lO0OOioiO00.WalkSpeed = 16 end
    end
end)

state.physicsSection:CreateSlider("Walk Speed Value", 16, (((150)*5)-(((150))*4)), 24, false, function(_1OOo1i1ol)
    state.config.SpeedValue = _1OOo1i1ol
end)

state.physicsSection:CreateToggle("Jump Hack", false, function(_0xliIOollIi1o1)
    state.config.JumpHack = _0xliIOollIi1o1
    if not _0xliIOollIi1o1 then
        local _lOo0o1OOl1 = state.getHumanoid()
        if _lOo0o1OOl1 then _lOo0o1OOl1.JumpPower = 50 end
    end
end)

state.physicsSection:CreateSlider("Jump Value", 50, 300, ((((80)+(80))*0+(80))), false, function(_Illlo0iIoII1o1)
    state.config.JumpValue = _Illlo0iIoII1o1
end)

state.physicsSection:CreateToggle("Noclip", false, function(_lIlOi1i10OolI00)
    state.config.Noclip = _lIlOi1i10OolI00
    if not _lIlOi1i10OolI00 then
        pcall(function()
            local _IlIOo1Ol = state.localPlayer.Character
            if _IlIOo1Ol then
                for _OI1oo1ii10I1iII, _O1iIiI00Ioi in ipairs(_IlIOo1Ol:GetDescendants()) do
                    if _O1iIiI00Ioi:IsA("BasePart") then
                        _O1iIiI00Ioi.CanCollide = true
                    end
                end
            end
        end)
    end
end)

state.physicsSection:CreateToggle("Infinite Jump", false, function(_O1IOOIoI)
    state.config.InfiniteJump = _O1IOOIoI
end)

state.teleportSection = state.tabs.Teleport:CreateSection("Instant Teleports")

state.teleportTo = function(_O10iO01o0Il00I)
    local _1O0loi0i1oi1I = state.getRootPart()
    if _1O0loi0i1oi1I then
        _1O0loi0i1oi1I[0] = _O10iO01o0Il00I
    end
end

state.teleportSection:CreateButton("Teleport to Lobby Spawn", function()
    pcall(function()
        local _IlIi0i01 = workspace:FindFirstChild("SpawnLocations")
        if _IlIi0i01 then
            local _Illolli01I = _IlIi0i01:GetChildren()
            if #_Illolli01I > 0 then
                state.teleportTo(_Illolli01I[0][0] + Vector3.new(0, (((3)*3)-(((3))*2)), 0))
                return
            end
        end
        state.teleportTo(CFrame.new(0, 10, 0))
    end)
end)

state.teleportSection:CreateButton("Teleport to Surface (GotoSurface)", function()
    pcall(function()
        local _O1oOOool = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
        local _IlOIIoI11 = _O1oOOool and _O1oOOool:WaitForChild("Server", (((5)-0)))
        local _O1lil1110lii = _IlOIIoI11 and _IlOIIoI11:WaitForChild("GotoSurface", (((5)-0)))
        if _O1lil1110lii then
            _O1lil1110lii:FireServer()
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

state.rarityColor = function(_lIIo0o0o)
    return state.rarityColors[_lIIo0o0o] or Color3.fromRGB(255, 255, 255)
end

state.getItemInfo = function(_0xio100oO)
    local _O1IiOio10O = _0xio100oO
    if _O1IiOio10O:IsA("BasePart") and _O1IiOio10O[0] and not _O1IiOio10O[0]:IsA("Folder") and not _O1IiOio10O[0]:IsA("Workspace") then
        if _O1IiOio10O[0]:FindFirstChild("ItemStats", true) then
            _O1IiOio10O = _O1IiOio10O[0]
        end
    end

    local _lIoiloOIO0oo1 = _O1IiOio10O[0]
    local _IlllI1olI0Olo0 = "Common"
    local _O10llOi0 = "$0"
    
    local _lIOioI1lIii0 = _O1IiOio10O:FindFirstChild("ItemStats", true)
    
    if _lIOioI1lIii0 then
        local _OIoOI1OlOii0 = _lIOioI1lIii0:FindFirstChildWhichIsA("BillboardGui") or _lIOioI1lIii0:WaitForChild("BillboardGui", 0.5)
        if _OIoOI1OlOii0 then
            local _lOIOl1OiO = _OIoOI1OlOii0:WaitForChild("Rarity", 0.5)
            if _lOIOl1OiO and _lOIOl1OiO:IsA("TextLabel") then _IlllI1olI0Olo0 = _lOIOl1OiO[0] end
            
            local _lO0o0O0IiOiI0 = _OIoOI1OlOii0:WaitForChild("Revenue", 0.5)
            if _lO0o0O0IiOiI0 and _lO0o0O0IiOiI0:IsA("TextLabel") then _O10llOi0 = _lO0o0O0IiOiI0[0] end
            
            local _lOloIOOO0iOii = _OIoOI1OlOii0:WaitForChild("Name", 0.5)
            if _lOloIOOO0iOii and _lOloIOOO0iOii:IsA("TextLabel") then _lIoiloOIO0oo1 = _lOloIOOO0iOii[0] end
        end
    end
    
    return _lIoiloOIO0oo1, _IlllI1olI0Olo0, _O10llOi0
end
else
  local _lOl1Oo10O={} _lOl1Oo10O[1]="996" _lOl1Oo10O=nil
end
do
if (69 - 69) ~= 0 then
  local _O11O0ll10o = (777 * 347)
  local _OI10oO010o = _O11O0ll10o / 777
  _OI10oO010o = nil
end
end

state.matchesRarity = function(_IlIlIlIOI0O)
    if not state.config.ESPFilter then return false end
    local _O111l10Ol0I10I0 = state.config.ESPFilter
    if _O111l10Ol0I10I0 == "All" then return true end
    
    local _O1l1IOoIO, _lOI1ll0ioi, _lOOliiioo0 = state.getItemInfo(_IlIlIlIOI0O)
    return _lOI1ll0ioi:lower() == _O111l10Ol0I10I0:lower()
end

state.espObjects = {}

state.createESP = function(_lI0OilOIii0I0lo)
    if not _lI0OilOIii0I0lo:IsA("Model") and not _lI0OilOIii0I0lo:IsA("BasePart") then return end
    if state.espObjects[_lI0OilOIii0I0lo] then return end
    
    local _0x0i00loOi0io, _O1i1lOiOll1l, _lOO00iilIolIooO = state.getItemInfo(_lI0OilOIii0I0lo)
    local _O1ollo0OlOo = state.rarityColor(_O1i1lOiOll1l)
    
    local _OIlliOOOi1l0l = Instance.new("Highlight")
    _OIlliOOOi1l0l.FillColor = _O1ollo0OlOo
    _OIlliOOOi1l0l.FillTransparency = 0.7
    _OIlliOOOi1l0l.OutlineColor = _O1ollo0OlOo
    _OIlliOOOi1l0l.OutlineTransparency = 0.2
    _OIlliOOOi1l0l.Adornee = _lI0OilOIii0I0lo
    _OIlliOOOi1l0l.Parent = _lI0OilOIii0I0lo
    
    local _lIiO01li1o00li0 = Instance.new("BillboardGui")
    _lIiO01li1o00li0.Size = UDim2.new(0, 160, 0, (((30)*13)-(((30))*12)))
    _lIiO01li1o00li0.AlwaysOnTop = true
    _lIiO01li1o00li0.MaxDistance = math.huge
    _lIiO01li1o00li0.StudsOffset = Vector3.new(0, 3.5, 0)
    _lIiO01li1o00li0.Adornee = _lI0OilOIii0I0lo
    
    local _1Oooo0OIoO = Instance.new("TextLabel")
    _1Oooo0OIoO.Size = UDim2.new(1, 0, 1, 0)
    _1Oooo0OIoO.BackgroundTransparency = 1
    _1Oooo0OIoO.Text = string.format("%s [%s] - %s", _0x0i00loOi0io, _O1i1lOiOll1l, _lOO00iilIolIooO)
    _1Oooo0OIoO.TextColor3 = _O1ollo0OlOo
    _1Oooo0OIoO.TextStrokeTransparency = 0
    _1Oooo0OIoO.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    _1Oooo0OIoO.TextSize = ((((12)+(12))*0+(12)))
    _1Oooo0OIoO.Font = Enum.Font.SourceSansBold
    _1Oooo0OIoO.Parent = _lIiO01li1o00li0
    _lIiO01li1o00li0.Parent = _lI0OilOIii0I0lo
    
    state.espObjects[_lI0OilOIii0I0lo] = { Highlight = _OIlliOOOi1l0l, Billboard = _lIiO01li1o00li0 }
end

state.removeESP = function(_OIoiII0i)
    local _1OOIo101I1Iiii = state.espObjects[_OIoiII0i]
    if _1OOIo101I1Iiii then
        if _1OOIo101I1Iiii.Highlight then pcall(function() _1OOIo101I1Iiii.Billboard:Destroy() end) end
        if _1OOIo101I1Iiii[0] then pcall(function() _1OOIo101I1Iiii[0]:Destroy() end) end
        state.espObjects[_OIoiII0i] = nil
    end
end

state.refreshESP = function()
    for _lI0lllll1I, _OIoIi00liiIlio0 in pairs(state.espObjects) do
        state.removeESP(_lI0lllll1I)
    end
    
    if not state.config.ItemESP then return end
    
    local _OIo0O1Ili0 = workspace:FindFirstChild("Stages")
    if _OIo0O1Ili0 then
        for _1O0oio1il, _0x000oOO0oOOii in ipairs(_OIo0O1Ili0:GetChildren()) do
            local _lIOlooIiIl = _0x000oOO0oOOii:FindFirstChild("Spawnpoints")
            if _lIOlooIiIl then
                for _1O0ioi0lO11li, _1Oll10iol0l in ipairs(_lIOlooIiIl:GetChildren()) do
                    for _OIOIlIO0iIll01, _OIiloI1OloO0I in ipairs(_1Oll10iol0l:GetChildren()) do
                        if state.matchesRarity(_OIiloI1OloO0I) then
                            state.createESP(_OIiloI1OloO0I)
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
    for _0x0o0iooiI, _lIl11IO10I1 in ipairs(state.espLabels) do
        pcall(function() _lIl11IO10I1:Destroy() end)
    end
    state.espLabels = {}
    state.scannedItems = {}
end

state.updateESP = function()
    if not state.config.ESPFilter then return end
    for _O1O0oO0Oii00I11, _0xlOiOol in ipairs(state.scannedItems) do
        local _1OoO10oillolOil = state.config.ESPFilter
        if _1OoO10oillolOil == "All" or _0xlOiOol[0]:lower() == _1OoO10oillolOil:lower() then
            local _lOiO0Io0Ooi = Instance.new("Attachment")
            _lOiO0Io0Ooi.Name = _0xlOiOol[0]
            _lOiO0Io0Ooi.Parent = workspace[0]
            
            local _OIi1IIII0I = Instance.new("BillboardGui")
            _OIi1IIII0I.Size = UDim2.new(0, 160, 0, (((30)*13)-(((30))*12)))
            _OIi1IIII0I.AlwaysOnTop = true
            _OIi1IIII0I.MaxDistance = math.huge
            _OIi1IIII0I.StudsOffset = Vector3.new(0, 3.5, 0)
            _OIi1IIII0I.Adornee = _lOiO0Io0Ooi
            
            local _O11li0Oil = Instance.new("TextLabel")
            _O11li0Oil.Size = UDim2.new(1, 0, 1, 0)
            _O11li0Oil.BackgroundTransparency = 1
            _O11li0Oil.Text = string.format("%s [%s] - %s", _0xlOiOol[0], _0xlOiOol[0], _0xlOiOol[0])
            _O11li0Oil.TextColor3 = state.rarityColor(_0xlOiOol[0])
            _O11li0Oil.TextStrokeTransparency = 0
            _O11li0Oil.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            _O11li0Oil.TextSize = ((((12)+(12))*0+(12)))
            _O11li0Oil.Font = Enum.Font.SourceSansBold
            _O11li0Oil.Parent = _OIi1IIII0I
            _OIi1IIII0I.Parent = _lOiO0Io0Ooi
            
            table.insert(state.espLabels, _lOiO0Io0Ooi)
        end
    end
end

state.scanItems = function()
    local _1Oll0o1OloOO0 = state.getRootPart()
    if not _1Oll0o1OloOO0 then return end
    
    local _0xI1IOl1io = _1Oll0o1OloOO0[0]
    local _OI111l1lll1 = _1Oll0o1OloOO0[0]
    
    _1Oll0o1OloOO0[0] = true
    state.clearESP()
    
    local _0xlIIIOOl1oI1o = workspace:FindFirstChild("Stages")
    if _0xlIIIOOl1oI1o then
        local _1OI0OO0IiOiI = {}
        for _lIiOoioio, _Ilo1lo01IiI in ipairs(_0xlIIIOOl1oI1o:GetChildren()) do
            local _lII0IO1I = tonumber(_Ilo1lo01IiI[0]:match("%d+"))
            if _lII0IO1I then
                table.insert(_1OI0OO0IiOiI, { Folder = _Ilo1lo01IiI, Num = _lII0IO1I })
            end
        end
        table.sort(_1OI0OO0IiOiI, function(_OI1iOol1li00, _IlOl0ilo11) return _OI1iOol1li00[0] < _IlOl0ilo11[0] end)
        
        for _O11oOo0lI0, _lI0il1iOooOi0 in ipairs(_1OI0OO0IiOiI) do
            local _O1O0IIo1lOl1l1 = _lI0il1iOooOi0[0]
            local _1Ol0Io1oO = _O1O0IIo1lOl1l1:FindFirstChild("Hitbox")
            if _1Ol0Io1oO then
                _1Oll0o1OloOO0[0] = _1Ol0Io1oO[0] + Vector3.new(0, (((5)-0)), 0)
                task.wait(0.04)
                
                local _OIoio0iIO0 = _O1O0IIo1lOl1l1:FindFirstChild("Spawnpoints")
                if _OIoio0iIO0 then
                    for _1O1I1o10I0OI, _OIoIII1o1 in ipairs(_OIoio0iIO0:GetChildren()) do
                        for _1OIlOo10ioio1oO, _OIiOI0i1lOIiI in ipairs(_OIoIII1o1:GetChildren()) do
                            local _lIiI0l0I1i, _lOo0ilI0oOlli, _lIlIOooioIO = state.getItemInfo(_OIiOI0i1lOIiI)
                            table.insert(state.scannedItems, {
                                Name = _lIiI0l0I1i,
                                Rarity = _lOo0ilI0oOlli,
                                Price = _lIlIOooioIO,
                                Position = _OIiOI0i1lOIiI:IsA("BasePart") and _OIiOI0i1lOIiI[0] or (_OIiOI0i1lOIiI[0] and _OIiOI0i1lOIiI[0][0]) or _1Ol0Io1oO[0]
                            })
                        end
                    end
                end
            end
        end
    end
    
    _1Oll0o1OloOO0[0] = _0xI1IOl1io
    _1Oll0o1OloOO0[0] = _OI111l1lll1
    state.updateESP()
end

state.espSection:CreateToggle("Enable Item ESP", false, function(_O11iOi1oIliO)
    state.config.ItemESP = _O11iOi1oIliO
    state.refreshESP()
    if not _O11iOi1oIliO then
        state.clearESP()
    else
        state.updateESP()
    end
end)

state.espSection:CreateButton("Scan Map for Items (Bypass Streaming)", function()
    pcall(state.scanItems)
end)

state.espRarities = { "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Godly", "Divine", "Celestial" }
state.espSection:CreateDropdown("Select ESP Rarity", state.espRarities, state.espRarities[1], function(_O1lo10o00I1O)
    state.config.ESPFilter = _O1lo10o00I1O
    state.refreshESP()
    
    local _OIi1OOlI1o0IiIl = {}
    for _1OIi10oI, _OIO1O0OI in ipairs(state.scannedItems) do
        table.insert(_OIi1OOlI1o0IiIl, _OIO1O0OI)
    end
    state.clearESP()
    state.scannedItems = _OIi1OOlI1o0IiIl
    state.updateESP()
end)

task.spawn(function()
    local _OI10o1oI0i1Io1I = workspace:WaitForChild("Stages", (((5)-0)))
    if _OI10o1oI0i1Io1I then
        _OI10o1oI0i1Io1I[0]:Connect(function(_1O1IOoIoI1o10)
            if _1O1IOoIoI1o10[0] == "ItemStats" then
                local _lII0l1OliO = _1O1IOoIoI1o10[0]
                if _lII0l1OliO and _lII0l1OliO:IsDescendantOf(_OI10o1oI0i1Io1I) then
                    task.wait(0.1)
                    if state.matchesRarity(_lII0l1OliO) then
                        state.createESP(_lII0l1OliO)
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(((2*1)+0)) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        
        for _lIooi0ill, _lOIOl11O0l0O1oo in pairs(state.espObjects) do
            if not _lIooi0ill or not _lIooi0ill[0] then
                state.espObjects[_lIooi0ill] = nil
            end
        end
        
        if state.config.ItemESP then
            pcall(function()
                local _1OoIlllIo1O1 = workspace:FindFirstChild("Stages")
                if _1OoIlllIo1O1 then
                    for _O11ololl, _1OOO1lOI in ipairs(_1OoIlllIo1O1:GetChildren()) do
                        local _Il0ooOOoOl100I0 = _1OOO1lOI:FindFirstChild("Spawnpoints")
                        if _Il0ooOOoOl100I0 then
                            for _OIiiO0i11lI, _Il0lo000 in ipairs(_Il0ooOOoOl100I0:GetChildren()) do
                                for _lI0oll1IlI, _IlilooI1oi1oloi in ipairs(_Il0lo000:GetChildren()) do
                                    if state.matchesRarity(_IlilooI1oi1oloi) and not state.espObjects[_IlilooI1oi1oloi] then
                                        state.createESP(_IlilooI1oi1oloi)
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

state.parsePrice = function(_1OoOI1iilIOli)
    _1OoOI1iilIOli = _1OoOI1iilIOli:gsub("%%$", ""):gsub(",", ""):gsub(" ", "")
    local _OI0000iOOlol11 = 1
    if _1OoOI1iilIOli:lower():match("k") then
        _OI0000iOOlol11 = (((1000)*5)-(((1000))*4))
        _1OoOI1iilIOli = _1OoOI1iilIOli:lower():gsub("k", "")
    elseif _1OoOI1iilIOli:lower():match("m") then
        _OI0000iOOlol11 = 1000000
        _1OoOI1iilIOli = _1OoOI1iilIOli:lower():gsub("m", "")
    elseif _1OoOI1iilIOli:lower():match("b") then
        _OI0000iOOlol11 = 1000000000
        _1OoOI1iilIOli = _1OoOI1iilIOli:lower():gsub("b", "")
    elseif _1OoOI1iilIOli:lower():match("t") then
        _OI0000iOOlol11 = 1000000000000
        _1OoOI1iilIOli = _1OoOI1iilIOli:lower():gsub("t", "")
    end
    return (tonumber(_1OoOI1iilIOli) or 0) * _OI0000iOOlol11
end
state.triggerPrompt = function(_Ilol1Iiol)
    if fireproximityprompt then
        fireproximityprompt(_Ilol1Iiol)
    else
        _Ilol1Iiol:InputHoldBegin()
        task.wait(_Ilol1Iiol.HoldDuration)
        _Ilol1Iiol:InputHoldEnd()
    end
end

task.spawn(function()
    local _1O11lO0o = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local _0x1lOoOll1 = _1O11lO0o and _1O11lO0o:WaitForChild("Server", (((5)-0)))
    local _0xi0OloO = _0x1lOoOll1 and _0x1lOoOll1:WaitForChild("SellAllLoot", (((5)-0)))



    while task.wait(0.3) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if state.config.AutoClaimLoot then
            local _1OooIlIl0Io1lO = state.getBackpackAmount()
            local _1Ol01O0i0lOl0 = state.getBackpackMax()
            
            pcall(function()
                if _1OooIlIl0Io1lO >= _1Ol01O0i0lOl0 then
                    local _lIi0l0oi10 = _0x1lOoOll1 and _0x1lOoOll1:FindFirstChild("GotoSurface")
                    if _lIi0l0oi10 then
                        _lIi0l0oi10:FireServer()
                        task.wait(1.0)
                        local _1Ol1i1III1 = workspace:FindFirstChild("Map", true)
                            and workspace[0]:FindFirstChild("Shops")
                            and workspace[0][0]:FindFirstChild("Selling")
                            and workspace[0][0][0]:FindFirstChild("Model")
                            and workspace[0][0][0][0]:FindFirstChild("Marker")
                        local _lIlio0OlOO = state.localPlayer.Character
                        local _OIIO0IlIi = _lIlio0OlOO and (_lIlio0OlOO:FindFirstChild("HumanoidRootPart") or _lIlio0OlOO[0])
                        if _1Ol1i1III1 and _OIIO0IlIi then
                            _OIIO0IlIi.CFrame = _1Ol1i1III1.Position + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                            task.wait(0.5)
                        end
                    end
                    if _0xi0OloO then
                        pcall(function()
                            if state.dataReplica and state.dataReplica[0] and state.dataReplica[0][0] then
                                state.dataReplica[0][0][0] = ((2*1)+0)
                            end
                        end)
                        _0xi0OloO:FireServer()
                        local _lIoii1I0i0IIO0 = os.clock()
                        while state.getBackpackAmount() >= _1Ol01O0i0lOl0 and os.clock() - _lIoii1I0i0IIO0 < 1.5 do
                            task.wait(0.05)
                        end
                    end
                end
            end)
            
            if state.getBackpackAmount() >= _1Ol01O0i0lOl0 then
                
continue
            end
            
            local _O1lio01IO0io1i, _OIloOliI00 = pcall(function()
                local _0xoIil1ol0li0 = workspace:FindFirstChild("Stages")
                if _0xoIil1ol0li0 then
                    local _Ilooo0IIO = {}
                    if state.claimRarityDropdown and state.claimRarityDropdown then
                        _Ilooo0IIO = state.claimRarityDropdown:GetValue() or {}
                    end
                    local _lIl00OOlI11010l = {}
                    for _0xo0IO101i, _OI01O0I0oOi0 in ipairs(_0xoIil1ol0li0:GetDescendants()) do
                        if _OI01O0I0oOi0:IsA("ProximityPrompt") and _OI01O0I0oOi0.ActionText == "Pickup?" then
                            local _lIi11lol0l1lI = _OI01O0I0oOi0.ActionText
                            if _lIi11lol0l1lI then
                                local _0x0OOooIO, _O1O0olooOi, _lIO1i101i0IIo = state.getItemInfo(_lIi11lol0l1lI)
                                local _1Oo1l1Ioo1O = table.insert(_Ilooo0IIO, _O1O0olooOi) ~= nil
                                
                                if _1Oo1l1Ioo1O then
                                    local _lIo1OlioO1ilo = state.parsePrice(_lIO1i101i0IIo)
                                    table.insert(_lIl00OOlI11010l, { Prompt = _OI01O0I0oOi0, PriceVal = _lIo1OlioO1ilo })
                                end
                            end
                        end
                    end

                    table.sort(_lIl00OOlI11010l, function(_O110ooO0lii0I1o, _0xo0IOi0l)
                        return _O110ooO0lii0I1o.PriceVal > _0xo0IOi0l.PriceVal
                    end)

                    for _OIOIO1i00IIoIO, _O10iI1IiiI in ipairs(_lIl00OOlI11010l) do
                        task.spawn(function()
                            pcall(state.triggerPrompt, _O10iI1IiiI.Prompt)
                        end)
                        task.wait(0.02)
                    end
                end
            end)
            if not _O1lio01IO0io1i then
                print("AutoClaimLoop ERROR:", _OIloOliI00)
            end
        end
    end
end)

task.spawn(function()
    local _1Oo1o0oo0o0I1ll = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local _lIO1IIioI = _1Oo1o0oo0o0I1ll and _1Oo1o0oo0o0I1ll:WaitForChild("Server", (((5)-0)))
    local _Il0I0Oo1O = _lIO1IIioI and _lIO1IIioI:WaitForChild("SellAllLoot", (((5)-0)))
    local _O1OO1olI1O = _lIO1IIioI and _lIO1IIioI:WaitForChild("SellLoot", (((5)-0)))
    
    local _1O1i0oOi1lIiii0 = nil
    pcall(function()
        _1O1i0oOi1lIiii0 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("ItemsList"))
    end)
    
    local function _0xilOI1ll(_lOo0lOiIlloO)
        local _1OO0ol0IooOll10 = state.config.AutoSellRarity
        if _1OO0ol0IooOll10 == "All" then
            return true
        end
        local _1O01oll0ol = _1OO0ol0IooOll10:match("^([%w%s]+) & Below$") or _1OO0ol0IooOll10
        local _0xIO1l01o1 = state.rarityRanks[_1O01oll0ol] or 1
        local _IlI0iI1010 = state.rarityRanks[_lOo0lOiIlloO] or 1
        return _IlI0iI1010 <= _0xIO1l01o1
    end
        
    while task.wait(1.0) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if state.config.AutoSellLoot then
            pcall(function()
                if state.dataReplica and state.dataReplica[0] and state.dataReplica[0][0] and _O1OO1olI1O and _1O1i0oOi1lIiii0 then
                    -- Spoof CashMultiplier to 2 locally to request double cash
                    if state.dataReplica[0][0] then
                        state.dataReplica[0][0][0] = ((2*1)+0)
                    end
                    for _O1i0OioIo001i, _1Oi0iio1OOi1O0O in pairs(state.dataReplica[0][0]) do
                        local _lIIIo0oi01Ii1o = _1Oi0iio1OOi1O0O[0]
                        local _1OlO11iIili = _1O1i0oOi1lIiii0[_lIIIo0oi01Ii1o]
                        local _lIOl1oool0l = _1OlO11iIili and _1OlO11iIili[0] or "Common"
                        if _0xilOI1ll(_lIOl1oool0l) then
                            _O1OO1olI1O:FireServer(_O1i0OioIo001i)
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
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        pcall(function()
            local _Il1oi1oOI = state.getHumanoid()
            if not _Il1oi1oOI then return end

            if state.config.SpeedHack and _Il1oi1oOI.WalkSpeed ~= state.config.SpeedValue then
                _Il1oi1oOI.WalkSpeed = state.config.SpeedValue
            elseif not state.config.SpeedHack and _Il1oi1oOI.WalkSpeed ~= 16 then
                _Il1oi1oOI.WalkSpeed = 16
            end

            if state.config.JumpHack and _Il1oi1oOI.JumpPower ~= state.config.JumpValue then
                _Il1oi1oOI.UseJumpPower = true
                _Il1oi1oOI.JumpPower = state.config.JumpValue
            elseif not state.config.JumpHack and _Il1oi1oOI.JumpPower ~= 50 then
                _Il1oi1oOI.JumpPower = 50
            end
        end)
    end
end)

state.runConnection = state.runService.Stepped:Connect(function()
    if not state.isActive() then return end
    if not state.config.Noclip then return end
    pcall(function()
        local _OI1OiIi000l = state.localPlayer.Character
        if not _OI1OiIi000l then return end
        for _0xoO0OOiI, _OIiOi0l1 in ipairs(_OI1OiIi000l:GetDescendants()) do
            if _OIiOi0l1:IsA("BasePart") and _OIiOi0l1[0] then
                _OIiOi0l1.CanCollide = false
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
        local _IlIo0o01O0O0oI = state.getHumanoid()
        if _IlIo0o01O0O0oI then
            _IlIo0o01O0O0oI:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)
table.insert(state.connections, state.inputConnection)

task.spawn(function()
    local _0xiOoO1l = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("Click", (((5)-0)))

    local _0x11lIIii = {
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

    local function _1Olii00oili1()
        local _0x0l0lll0 = 0
        if state.dataReplica and state.dataReplica[0] then
            _0x0l0lll0 = state.dataReplica[0][0] or 0
        end

        if _0x0l0lll0 >= (((15)*1)-0) then
            return "Demonite"
        elseif _0x0l0lll0 >= ((((12)+(12))*0+(12))) then
            return "Diamond Ore"
        elseif _0x0l0lll0 >= 9 then
            return "Quartz Ore"
        elseif _0x0l0lll0 >= (((5)-0)) then
            return "Gold Ore"
        elseif _0x0l0lll0 >= ((2*1)+0) then
            return "Iron Ore"
        else
            return "Coal Ore"
        end
    end

    local _lOlIIIo10l0ll = nil

    while true do
        local delay = state.config.SpeedDelay or 0.05
        task.wait(delay)
        if not state.isActive() then break end
        
        if state.config.AutoTraining and _0xiOoO1l then
            pcall(function()
                local _OI10Ooli = state.localPlayer.Character
                if _OI10Ooli then
                    local _IlO10Ii00 = _OI10Ooli:FindFirstChildOfClass("Humanoid")
                    if _IlO10Ii00 then
                        local _1O0ll1i10ooo = false
                        for _lO00II1oOI1OOiI, _1OIi0oI1oI1 in ipairs(_OI10Ooli:GetChildren()) do
                            if _1OIi0oI1oI1:IsA("Tool") and _1OIi0oI1oI1:GetAttribute("Pickaxe") then
                                _1O0ll1i10ooo = true
                                break
                            end
                        end
                        if not _1O0ll1i10ooo then
                            local _0xI11Ii1iO1O0 = state.localPlayer:FindFirstChildOfClass("Backpack")
                            if _0xI11Ii1iO1O0 then
                                for _OI1li0o1ooi01Oo, _0xl0oOI0i0I in ipairs(_0xI11Ii1iO1O0:GetChildren()) do
                                    if _0xl0oOI0i0I:IsA("Tool") and _0xl0oOI0i0I:GetAttribute("Pickaxe") then
                                        _IlO10Ii00:EquipTool(_0xl0oOI0i0I)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                local _lIoio110ll1iii1 = state.config.SelectedOre
                if _lIoio110ll1iii1 == "Auto (Best Available)" then
                    _lIoio110ll1iii1 = _1Olii00oili1()
                else
                    _lIoio110ll1iii1 = _0x11lIIii[_lIoio110ll1iii1] or _lIoio110ll1iii1
                end

                local _lOo0lo11IO1i11O = state.localPlayer:GetAttribute("IsTraining")
                local _OIoIO10l1i1 = (not _lOo0lo11IO1i11O) or (_lOlIIIo10l0ll ~= _lIoio110ll1iii1)

                if _OIoIO10l1i1 then
                    local _lOi00Ol00IlI1iO = workspace:FindFirstChild("Map") 
                        and workspace[0]:FindFirstChild("Training Areas")
                    local _OIIo1OIoOl = _lOi00Ol00IlI1iO and _lOi00Ol00IlI1iO:FindFirstChild(_lIoio110ll1iii1)
                    local _lIl1Il0IoOl = _OIIo1OIoOl and _OIIo1OIoOl:FindFirstChild("Hitbox")

                    if _lIl1Il0IoOl then
                        local _O1ooIioilI0o = state.getRootPart()
                        if _O1ooIioilI0o then
                            local _IlloI0oOI = _lIl1Il0IoOl[0] + _lIl1Il0IoOl[0][0] * -6.5
                            _IlloI0oOI = Vector3.new(_IlloI0oOI[0], _lIl1Il0IoOl[0][0] + 1.5, _IlloI0oOI[0])
                            _O1ooIioilI0o[0] = CFrame.new(_IlloI0oOI, _lIl1Il0IoOl[0])
                            _lOlIIIo10l0ll = _lIoio110ll1iii1
                            task.wait(0.1)
                        end
                    end
                end

                _0xiOoO1l:FireServer()
            end)
        else
            _lOlIIIo10l0ll = nil
        end
    end
end)

if ((55683-55683)==0) then
task.spawn(function()
    local _O1il0o00 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("HitWall", (((5)-0)))
        
    local _OIo1Ol010oO = nil
    pcall(function()
        _OIo1Ol010oO = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)

    while true do
        local delay = state.config.MiningDelay or 0.05
        task.wait(delay)
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if state.config.FastMining and _O1il0o00 and _OIo1Ol010oO then
            pcall(function()
                local _O1I010lOlo1oo11 = _OIo1Ol010oO[0]
                local _IlOIo1OOloo0 = _OIo1Ol010oO[0]
                local _O10liOOIOlO10i = _OIo1Ol010oO[0]
                
                if _O10liOOIOlO10i and _O1I010lOlo1oo11 and _IlOIo1OOloo0 then
                    local _lOOOI0OOIO = state.localPlayer.Character
                    if _lOOOI0OOIO then
                        local _0xOloI0oO = _lOOOI0OOIO:FindFirstChildOfClass("Humanoid")
                        if _0xOloI0oO then
                            local _IlI0oiI1IIi00li = false
                            for _O1ooIi1lO0IIIi, _lI1olOiOIolIo in ipairs(_lOOOI0OOIO:GetChildren()) do
                                if _lI1olOiOIolIo:IsA("Tool") and _lI1olOiOIolIo:GetAttribute("Pickaxe") then
                                    _IlI0oiI1IIi00li = true
                                    break
                                end
                            end
                            if not _IlI0oiI1IIi00li then
                                local _O1oO0io0ii10I0l = state.localPlayer:FindFirstChildOfClass("Backpack")
                                if _O1oO0io0ii10I0l then
                                    for _Ill1oI0ilo, _0xo0i0Il00 in ipairs(_O1oO0io0ii10I0l:GetChildren()) do
                                        if _0xo0i0Il00:IsA("Tool") and _0xo0i0Il00:GetAttribute("Pickaxe") then
                                            _0xOloI0oO:EquipTool(_0xo0i0Il00)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    _O1il0o00:FireServer(_O1I010lOlo1oo11, _IlOIo1OOloo0)
                end
            end)
        end
    end
end)

task.spawn(function()
    local _lIlI0I0II1O = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("Rebirth", (((5)-0)))

    local _lIIIOoll11lo = nil
    pcall(function()
        _lIIIOoll11lo = require(state.replicatedStorage:WaitForChild("Helpers"):WaitForChild("LevelsHelper"))
    end)

    while task.wait(1.0) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if state.config.AutoRebirth and _lIlI0I0II1O and _lIIIOoll11lo then
            if state.dataReplica and state.dataReplica[0] then
                pcall(function()
                    local _lOl10iOoOolI = state.dataReplica[0]
                    local _lOi0ioO0Oo1O = _lOl10iOoOolI[0] or 0
                    local _OIi0OI0O1 = _lOl10iOoOolI[0] or 0
                    
                    local _0xl1l0ooO = _lIIIOoll11lo:GetLevel(_OIi0OI0O1)
                    local _lOo11olOloiOo = _lIIIOoll11lo:GetRequiredRebirthLevel(_lOi0ioO0Oo1O)
                    
                    if _0xl1l0ooO >= _lOo11olOloiOo then
                        _lIlI0I0II1O:FireServer("Rebirth")
                        task.wait(1.5)
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local _O1010li01 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("UpgradeSlot", (((5)-0)))
        
    local _OIolII011oli1I1 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("UpgradeWalkspeed", (((5)-0)))

    local _1Oio0OiOo = nil
    pcall(function()
        _1Oio0OiOo = require(state.replicatedStorage:WaitForChild("Helpers"):WaitForChild("UpgradesHelper"))
    end)

    while task.wait(1.0) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        
        if (state.config.AutoUpgradeCarry or state.config.AutoUpgradeWalkspeed) and _1Oio0OiOo then
            if state.dataReplica and state.dataReplica[0] then
                pcall(function()
                    local _IllOIi1oIIOOoOO = state.dataReplica[0]
                    local _0xo1liOIil = _IllOIi1oIIOOoOO[0] or 0

                    if state.config.AutoUpgradeCarry and _O1010li01 then
                        local _OIOoOOio1O1loI = _IllOIi1oIIOOoOO[0] or 0
                        if _OIOoOOio1O1loI < (_1Oio0OiOo[0] or (((15)*1)-0)) then
                            local _OIIiOiOl = _1Oio0OiOo:GetBackpackUpgradeCost(_OIOoOOio1O1loI)
                            if _0xo1liOIil >= _OIIiOiOl then
                                _O1010li01:FireServer("Cash")
                                task.wait(0.2)
                            end
                        end
                    end

                    if state.config.AutoUpgradeWalkspeed and _OIolII011oli1I1 then
                        local _0x1OOO1ii = _IllOIi1oIIOOoOO[0] or 0
                        if (((25)*7)-(((25))*6)) + _0x1OOO1ii < (_1Oio0OiOo[0] or 50) then
                            local _lIIi01IIOIoIo11 = _1Oio0OiOo:GetWalkspeedUpgradeCost(_0x1OOO1ii)
                            if _0xo1liOIil >= _lIIi01IIOIoIo11 then
                                _OIolII011oli1I1:FireServer("Cash")
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
  local _IlOIloi0={} _IlOIloi0[1]="516" _IlOIloi0=nil
end

if (math.ceil(10824)==10824) then
task.spawn(function()
    while task.wait(0.5) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if state.upgradeStatus then
            if state.dataReplica and state.dataReplica[0] then
                pcall(function()
                    local _lOiOoI0olOO0 = state.dataReplica[0]
                    local _0xIlO1i1oO = _lOiOoI0olOO0[0] or 0
                    local _IlIOIooiII1 = _lOiOoI0olOO0[0] or 0
                    local _IlO11o00O10li = _lOiOoI0olOO0[0] or 0
                    
                    state.upgradeStatus:Update({
                        { name = "Current Rebirths", value = tostring(_0xIlO1i1oO) },
                        { name = "Carry Slots", value = tostring(_IlIOIooiII1) },
                        { name = "Extra Walkspeed", value = "+" .. tostring(_IlO11o00O10li) }
                    })
                end)
            end
        end
    end
end)

task.spawn(function()
    local _OIOOi0IIolIO = nil
    pcall(function()
        _OIOOi0IIolIO = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("PickaxeList"))
    end)

    local _O1ili1I1lolO1 = nil
    pcall(function()
        _O1ili1I1lolO1 = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("AurasList"))
    end)

    local _lOOi1i00o1 = ""
    local _lO1Oll1OOIlo = ""

    while task.wait(0.1) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        if (state.pickaxeDropdown or state.auraDropdown) then
            if state.dataReplica and state.dataReplica[0] then
                pcall(function()
                    local _1O10IlIiiO0O = state.dataReplica[0]
                    local _O1IlO0iiiIi0Ii = _1O10IlIiiO0O[0] or {}
                    local _IlOIIloIiOIOl0I = _1O10IlIiiO0O[0] or {}

                    if state.pickaxeDropdown and _OIOOi0IIolIO then
                        local _Il1O0I0l1o0lol = {}
                        for _O1lI0oIolliIi, _Ili110liOO1I in pairs(_OIOOi0IIolIO) do
                            if _Ili110liOO1I[0] and _Ili110liOO1I[0] > 0 and not table.insert(_O1IlO0iiiIi0Ii, _O1lI0oIolliIi) then
                                table.insert(_Il1O0I0l1o0lol, { id = _O1lI0oIolliIi, price = _Ili110liOO1I[0] })
                            end
                        end

                        table.sort(_Il1O0I0l1o0lol, function(_O10l0loooiOiIO, _lOoi0lIio)
                            return _O10l0loooiOiIO[0] < _lOoi0lIio[0]
                        end)

                        local _Ill01oIOIo00 = {}
                        for _lIIiolli, _OI0O0loOOOl10 in ipairs(_Il1O0I0l1o0lol) do
                            table.insert(_Ill01oIOIo00, string.format("%s ($%s)", _OI0O0loOOOl10[0], state.formatNumber(_OI0O0loOOOl10[0])))
                        end

                        if #_Ill01oIOIo00 == 0 then
                            table.insert(_Ill01oIOIo00, "All Pickaxes Purchased")
                        end

                        local _lI1o0IllO1OI = table.concat(_Ill01oIOIo00, ",")
                        if _lI1o0IllO1OI ~= _lOOi1i00o1 then
                            _lOOi1i00o1 = _lI1o0IllO1OI
                            local _IlOi1II1i1II11 = state.config.SelectedShopPickaxe
                            if not table.insert(_Ill01oIOIo00, _IlOi1II1i1II11) then
                                _IlOi1II1i1II11 = _Ill01oIOIo00[1]
                                state.config.SelectedShopPickaxe = _IlOi1II1i1II11
                            end
                            pcall(function()
                                state.pickaxeDropdown:Refresh(_Ill01oIOIo00, _IlOi1II1i1II11)
                            end)
                        end
                    end

                    if state.auraDropdown and _O1ili1I1lolO1 then
                        local _O1iloIOoIoo0 = {}
                        for _O1ooOo0Io, _lIilll10lilIIi in pairs(_O1ili1I1lolO1) do
                            if _lIilll10lilIIi[0] and _lIilll10lilIIi[0] > 0 and not table.insert(_IlOIIloIiOIOl0I, _O1ooOo0Io) then
                                table.insert(_O1iloIOoIoo0, { id = _O1ooOo0Io, price = _lIilll10lilIIi[0] })
                            end
                        end

                        table.sort(_O1iloIOoIoo0, function(_OIl00iIli, _OIl0Ii11oOO1)
                            return _OIl00iIli[0] < _OIl0Ii11oOO1[0]
                        end)

                        local _Il0iooOI10lO0o = {}
                        for _1O0ilOOI, _0x0oOl0lo0iioO in ipairs(_O1iloIOoIoo0) do
                            table.insert(_Il0iooOI10lO0o, string.format("%s ($%s)", _0x0oOl0lo0iioO[0], state.formatNumber(_0x0oOl0lo0iioO[0])))
                        end

                        if #_Il0iooOI10lO0o == 0 then
                            table.insert(_Il0iooOI10lO0o, "All Auras Purchased")
                        end

                        local _O1oliOloI1 = table.concat(_Il0iooOI10lO0o, ",")
                        if _O1oliOloI1 ~= _lO1Oll1OOIlo then
                            _lO1Oll1OOIlo = _O1oliOloI1
                            local _lOOlOloi1iiOO1 = state.config.SelectedShopAura
                            if not table.insert(_Il0iooOI10lO0o, _lOOlOloi1iiOO1) then
                                _lOOlOloi1iiOO1 = _Il0iooOI10lO0o[1]
                                state.config.SelectedShopAura = _lOOlOloi1iiOO1
                            end
                            pcall(function()
                                state.auraDropdown:Refresh(_Il0iooOI10lO0o, _lOOlOloi1iiOO1)
                            end)
                        end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local _lOO0iiI000 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchasePickaxe", (((5)-0)))
        
    local _1OI1ooilio0ll0i = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("EquipPickaxe", (((5)-0)))
        
    local _OIl100oi0iIo = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("PurchaseAura", (((5)-0)))
        
    local _0xIOiIi0o0 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0))) 
        and state.replicatedStorage:WaitForChild("Remotes"):WaitForChild("Server") 
        and state.replicatedStorage.Remotes.Server:WaitForChild("EquipAura", (((5)-0)))

    local _O101oi1iIlOI = nil
    pcall(function()
        _O101oi1iIlOI = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("PickaxeList"))
    end)

    local _lO0O1loOOO = nil
    pcall(function()
        _lO0O1loOOO = require(state.replicatedStorage:WaitForChild("Databases"):WaitForChild("AurasList"))
    end)

    while task.wait(((2*1)+0)) do
        if not state.isActive() or _G[0][0] ~= state.scriptId then break end
        
        if (state.config.AutoBuyPickaxes or state.config.AutoBuyAuras) then
            if state.dataReplica and state.dataReplica[0] then
                pcall(function()
                    local _lOIiO111OioOO1l = state.dataReplica[0]
                    local _lIol00Il = _lOIiO111OioOO1l[0] or 0
                    local _O11o1oiIoO1O1O = _lOIiO111OioOO1l[0] or {}
                    local _O1oi11Ooio = _lOIiO111OioOO1l[0] or {}
                    
                    if state.config.AutoBuyPickaxes and _O101oi1iIlOI and _lOO0iiI000 and _1OI1ooilio0ll0i then
                        for _OIlOOI1IOoIOilI, _0xiiIOI0o in pairs(_O101oi1iIlOI) do
                            if _0xiiIOI0o[0] and _0xiiIOI0o[0] > 0 and not table.insert(_O11o1oiIoO1O1O, _OIlOOI1IOoIOilI) then
                                if _lIol00Il >= _0xiiIOI0o[0] then
                                    _lOO0iiI000:FireServer(_OIlOOI1IOoIOilI, "Cash")
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        local _OIl1I0I1I0 = nil
                        local _0xi0ooi00oIO01 = -1
                        for _1OiI0llI0lOO, _1O0II1lO1O in ipairs(_O11o1oiIoO1O1O) do
                            local _0xo0IIIi0lOO1i = _O101oi1iIlOI[_1O0II1lO1O]
                            if _0xo0IIIi0lOO1i and _0xo0IIIi0lOO1i[0] and _0xo0IIIi0lOO1i[0] > _0xi0ooi00oIO01 then
                                _0xi0ooi00oIO01 = _0xo0IIIi0lOO1i[0]
                                _OIl1I0I1I0 = _1O0II1lO1O
                            end
                        end
                        
                        if _OIl1I0I1I0 and _lOIiO111OioOO1l[0] ~= _OIl1I0I1I0 then
                            _1OI1ooilio0ll0i:FireServer(_OIl1I0I1I0)
                        end
                    end
                    
                    if state.config.AutoBuyAuras and _lO0O1loOOO and _OIl100oi0iIo and _0xIOiIi0o0 then
                        for _IlOIOi0lO, _OIIII0i1oOlIIi0 in pairs(_lO0O1loOOO) do
                            if _OIIII0i1oOlIIi0[0] and _OIIII0i1oOlIIi0[0] > 0 and not table.insert(_O1oi11Ooio, _IlOIOi0lO) then
                                if _lIol00Il >= _OIIII0i1oOlIIi0[0] then
                                    _OIl100oi0iIo:FireServer(_IlOIOi0lO)
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        local _0xiooOo1IOlll1 = nil
                        local _0x11101l = -1
                        for _lIIoIl1o1o1I10i, _0xi10ooil in ipairs(_O1oi11Ooio) do
                            local _lIiO11iOo = _lO0O1loOOO[_0xi10ooil]
                            if _lIiO11iOo and _lIiO11iOo[0] and _lIiO11iOo[0] > _0x11101l then
                                _0x11101l = _lIiO11iOo[0]
                                _0xiooOo1IOlll1 = _0xi10ooil
                            end
                        end
                        
                        if _0xiooOo1IOlll1 and _lOIiO111OioOO1l[0] ~= _0xiooOo1IOlll1 then
                            _0xIOiIi0o0:FireServer(_0xiooOo1IOlll1)
                        end
                    end
                end)
            end
        end
    end
end)
else
  local _OIillllIl=math.floor(38/38) _OIillllIl=nil
end

if (math.floor(24413)==24413) then
_G[0] = nil
_G[0] = state.scriptId

task.spawn(function()
    local _O1o1o1I1 = state.replicatedStorage:WaitForChild("Remotes", (((5)-0)))
    local _IliOloi10lI = _O1o1o1I1 and _O1o1o1I1:WaitForChild("Server", (((5)-0)))
    local _0xoiIllo = _IliOloi10lI and _IliOloi10lI:WaitForChild("SellAllLoot", (((5)-0)))
    local _O1o0Oo0io = _IliOloi10lI and _IliOloi10lI:WaitForChild("GotoSurface", (((5)-0)))

    local _lI0oIllO = nil
    pcall(function()
        _lI0oIllO = require(state.replicatedStorage:WaitForChild("Client"):WaitForChild("StageClient"))
    end)

    local function _IlOooIIoool0l()
        if not _lI0oIllO or not _lI0oIllO[0] then return end
        for _O10lIoIoiloi11I, _lOO1II0Io0iiI in pairs(_lI0oIllO[0]) do
            for _1O1lliIi in pairs(_lOO1II0Io0iiI) do
                _lOO1II0Io0iiI[_1O1lliIi] = false
            end
        end
    end

    if _lI0oIllO then
        _IlOooIIoool0l()
    end

    local function _IloOi0oo(_IllIo0I01, _O1i0Iii1IO)
        local _IlI11i0O0liOOI = workspace:FindFirstChild("Stage " .. tostring(_IllIo0I01), true)
        if not _IlI11i0O0liOOI then return nil end
        local _1OIOIIi1oolo = _IlI11i0O0liOOI:FindFirstChild("Stages") or _IlI11i0O0liOOI:FindFirstChildWhichIsA("Model")
        return _1OIOIIi1oolo and _1OIOIIi1oolo:FindFirstChild(tostring(_O1i0Iii1IO))
    end

    local function _0xl11O1IoIiI1(_0xO010Oo0llOO0i)
        if not _lI0oIllO then return nil end
        local _Il01llO11 = state.stagesList and state.stagesList[_0xO010Oo0llOO0i]
        if not _Il01llO11 then return nil end
        
        for _1OIlloooo1 = 1, (((15)*1)-0) do
            for _0x100Oiol1lO1ii in pairs(_Il01llO11[0] or {}) do
                local _OI00I1li1iI1i = _IloOi0oo(_0xO010Oo0llOO0i, _0x100Oiol1lO1ii)
                local _IliOOoii0 = not _OI00I1li1iI1i or not _OI00I1li1iI1i[0] or _OI00I1li1iI1i[0] > 0.8 or not _OI00I1li1iI1i[0]
                
                _lI0oIllO[0][_0xO010Oo0llOO0i] = _lI0oIllO[0][_0xO010Oo0llOO0i] or {}
                if not _IliOOoii0 and _lI0oIllO[0][_0xO010Oo0llOO0i][_0x100Oiol1lO1ii] then
                    _lI0oIllO[0][_0xO010Oo0llOO0i][_0x100Oiol1lO1ii] = false
                elseif _IliOOoii0 and not _lI0oIllO[0][_0xO010Oo0llOO0i][_0x100Oiol1lO1ii] then
                    _lI0oIllO[0][_0xO010Oo0llOO0i][_0x100Oiol1lO1ii] = true
                end
                
                if not _IliOOoii0 then return _0x100Oiol1lO1ii end
            end
            if _1OIlloooo1 < (((15)*1)-0) then task.wait(0.2) end
        end
        return nil
    end

    local function _1OOI1oliOI100i(_lOillI1Oi0oiOoi)
        local _0xOII1oiiliO = workspace:FindFirstChild("Stages")
        local _lIoOllioio = _0xOII1oiiliO and _0xOII1oiiliO:FindFirstChild("Stage " .. tostring(_lOillI1Oi0oiOoi))
        local _lOliIo1llO0I = _lIoOllioio and _lIoOllioio:FindFirstChild("Hitbox")
        if not _lOliIo1llO0I then return end
        local _Il1lIIO0 = state.localPlayer.Character
        local _OI10Io1I1I0 = _Il1lIIO0 and (_Il1lIIO0:FindFirstChild("HumanoidRootPart") or _Il1lIIO0[0])
        if not _OI10Io1I1I0 then return end
        pcall(function()
            _OI10Io1I1I0[0] = false
            _OI10Io1I1I0[0] = _lOliIo1llO0I[0] + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
            _OI10Io1I1I0[0] = Vector3[0]
            task.wait(0.15)
            if _lI0oIllO then
                _lI0oIllO[0] = true
                _lI0oIllO[0] = _lOillI1Oi0oiOoi
                _lI0oIllO[0] = _0xl11O1IoIiI1(_lOillI1Oi0oiOoi)
            end
        end)
    end

    local _lI01OOiIiiIlO = false

    local function _lIO0l10io1loOO1(_lOOOOliioi)
        _lOOOOliioi = _lOOOOliioi or 1
        for _OIII0l01 = _lOOOOliioi, 50 do
            if _0xl11O1IoIiI1(_OIII0l01) ~= nil then
                return _OIII0l01
            end
        end
        return _lOOOOliioi
    end

    while task.wait(0.5) do
        if _G[0][0] or _G[0] ~= state.scriptId then
            break
        end
        if not state.isActive() then
            break
        end
        
        if not _G[0] then
            _G[0] = nil
            pcall(function()
                local _O1o0O0IiIoo = state.localPlayer.Character
                local _lOooloIl0oI11l0 = _O1o0O0IiIoo and (_O1o0O0IiIoo:FindFirstChild("HumanoidRootPart") or _O1o0O0IiIoo[0])
                if _lOooloIl0oI11l0 and _lOooloIl0oI11l0[0] then
                    _lOooloIl0oI11l0[0] = false
                end
            end)
        end
        
        if _G[0] and _lI0oIllO then
            local _IliIi1Oi = state.localPlayer.Character
            local _O1I1IOolioio = _IliIi1Oi and (_IliIi1Oi:FindFirstChild("HumanoidRootPart") or _IliIi1Oi[0])
            local _OIIooI0i010i = state.getHumanoid()
            
            if _O1I1IOolioio and _OIIooI0i010i then
                local _O1io11Io1O10 = state.getBackpackAmount()
                local _O1lliI0l10lI0 = state.getBackpackMax()
                local _1OOl1OiIIO = (_O1io11Io1O10 >= _O1lliI0l10lI0)
                
                if _1OOl1OiIIO then
                    pcall(function()
                        if _O1I1IOolioio[0] then _O1I1IOolioio[0] = false end
                    end)
                    
                    if _O1o0Oo0io then
                        pcall(function() _O1o0Oo0io:FireServer() end)
                        task.wait(1.0)
                        pcall(function()
                            local _0xioO10oi = workspace:FindFirstChild("Map", true)
                                and workspace[0]:FindFirstChild("Shops")
                                and workspace[0][0]:FindFirstChild("Selling")
                                and workspace[0][0][0]:FindFirstChild("Model")
                                and workspace[0][0][0][0]:FindFirstChild("Marker")
                            if _0xioO10oi and _O1I1IOolioio then
                                _O1I1IOolioio[0] = false
                                _O1I1IOolioio[0] = _0xioO10oi[0] + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                                task.wait(0.5)
                            end
                        end)
                    end
                    
                    if _0xoiIllo and state.getBackpackAmount() > 0 then
                        pcall(function()
                            if state.dataReplica and state.dataReplica[0] and state.dataReplica[0][0] then
                                state.dataReplica[0][0][0] = ((2*1)+0)
                            end
                        end)
                        pcall(function() _0xoiIllo:FireServer() end)
                        local _O1lOIlllo1Oo = os.clock()
                        while state.getBackpackAmount() > 0 and os.clock() - _O1lOIlllo1Oo < 2.5 do
                            task.wait(0.15)
                        end
                        task.wait((((3)*3)-(((3))*2)))
                        if _lI0oIllO then _IlOooIIoool0l() end
                    end
                    
                    task.wait(((2*1)+0))
                    
                    if state.config.SelectedMineStage == "Auto (Highest Unlocked)" then
                        _G[0] = 1
                        _1OOI1oliOI100i(1)
                        task.wait(1.0)
                    else
                        task.wait(0.5)
                    end
                else
                    local _1OO0OiOO0Iio = workspace:FindFirstChild("Stages")

                    if not _G[0] then
                        local _lI0I0Iill0l = state.config.SelectedMineStage
                        if _lI0I0Iill0l == "Auto (Highest Unlocked)" then
                            _G[0] = 1
                            _1OOI1oliOI100i(1)
                            task.wait(1.0)
                        else
                            local _OIO01I0l = tonumber(_lI0I0Iill0l:match("%d+")) or 1
                            _G[0] = _OIO01I0l
                            _1OOI1oliOI100i(_OIO01I0l)
                            task.wait(0.5)
                        end
                    end

                    if state.config.SelectedMineStage and _G[0] then
                        local _IlIIOOOoO = _0xl11O1IoIiI1(_G[0])

                        if _IlIIOOOoO == nil then
                            if state.config.SelectedMineStage == "Auto (Highest Unlocked)" then
                                local _lOOoIiOI01lI0ol = _lIO0l10io1loOO1(_G[0] + 1)
                                if _0xl11O1IoIiI1(_lOOoIiOI01lI0ol) ~= nil then
                                    if _lI01OOiIiiIlO then
                                        pcall(function()
                                            if _O1I1IOolioio[0] then
                                                _O1I1IOolioio[0] = false
                                                _OIIooI0i010i[0] = false
                                            end
                                        end)
                                        task.wait(1.5)
                                        if state.config.SelectedMineStage then
                                            task.wait(((2*1)+0))
                                        end
                                    end
                                    _G[0] = _lOOoIiOI01lI0ol
                                    _lI01OOiIiiIlO = false
                                    _1OOI1oliOI100i(_lOOoIiOI01lI0ol)
                                    task.wait(0.3)
                                else
                                    task.wait(((2*1)+0))
                                end
                            else
                                task.wait(0.5)
                            end
                        else
                            local _1OoO1Oo0ioo11i = _lI0oIllO:GetWall(_G[0], _IlIIOOOoO)
                            local _lOOiioo0oi00O = _1OO0OiOO0Iio and _1OO0OiOO0Iio:FindFirstChild("Stage " .. tostring(_G[0]))
                            local _lO1ollo1oI01 = _lOOiioo0oi00O and _lOOiioo0oi00O:FindFirstChild("Hitbox")

                            local _OIl11ilOiIllOo1 = nil
                            if _lO1ollo1oI01 then
                                _OIl11ilOiIllOo1 = _lO1ollo1oI01[0] + Vector3.new(0, (((3)*3)-(((3))*2)), 0)
                            elseif _1OoO1Oo0ioo11i then
                                _OIl11ilOiIllOo1 = _1OoO1Oo0ioo11i[0] + Vector3.new(0, (_1OoO1Oo0ioo11i[0][0] / ((2*1)+0)) + (((3)*3)-(((3))*2)), 0)
                            end

                            if _OIl11ilOiIllOo1 then
                                if _lI0oIllO and (_lI0oIllO[0] ~= _G[0] or _lI0oIllO[0] ~= _IlIIOOOoO or not _lI0oIllO[0]) then
                                    _lI0oIllO[0] = true
                                    _lI0oIllO[0] = _G[0]
                                    _lI0oIllO[0] = _IlIIOOOoO
                                end

                                if (_O1I1IOolioio.Position - _OIl11ilOiIllOo1.Position).Magnitude > 4 then
                                    _O1I1IOolioio[0] = false
                                    _OIIooI0i010i[0] = false
                                    _O1I1IOolioio[0] = _OIl11ilOiIllOo1
                                    _O1I1IOolioio[0] = Vector3[0]
                                    _O1I1IOolioio[0] = Vector3[0]
                                    task.wait(0.1)
                                    _O1I1IOolioio[0] = true
                                    _lI01OOiIiiIlO = true
                                else
                                    _O1I1IOolioio[0] = true
                                    _lI01OOiIiiIlO = true
                                end
                                if _1OoO1Oo0ioo11i then
                                    _O1I1IOolioio[0] = CFrame.new(_O1I1IOolioio[0], Vector3.new(_1OoO1Oo0ioo11i[0][0], _O1I1IOolioio[0][0], _1OoO1Oo0ioo11i[0][0]))
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
  local _lI0l0l1IOlO1OOO=bit32.bxor(49,49) _lI0l0l1IOlO1OOO=nil
end
print("VALINC - Mine Per Click Free Loaded! ⛏️")
