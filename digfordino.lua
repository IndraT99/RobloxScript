-- [[ IndraHub: Dig for Dinos 🦕 ]]
-- WindUI & Supervisor Integration

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local pcall = pcall

-- ==========================================
-- SUPERVISOR GLOBAL & HEARTBEAT INTEGRATION
-- ==========================================
local env = getgenv and getgenv() or _G
local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = env[key]
    if value ~= nil then return value end
    return rawget(_G, key)
end

-- Stop any previous instance running
if getGlobal("IndraHubDigForDinoRunning") and type(getGlobal("IndraHubDigForDinoUnload")) == "function" then
    pcall(getGlobal("IndraHubDigForDinoUnload"))
end

setGlobal("IndraHubDigForDinoRunning", true)
setGlobal("IndraHubDigForDinoLastHeartbeat", os.clock())
setGlobal("IndraHubDigForDinoError", nil)

task.spawn(function()
    while getGlobal("IndraHubDigForDinoRunning") do
        setGlobal("IndraHubDigForDinoLastHeartbeat", os.clock())
        if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubDigForDinoLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubDigForDinoLastHeartbeat"].heartbeat = os.clock()
        end
        task.wait(1)
    end
end)

-- Require Game Data
local Data = require(ReplicatedStorage:WaitForChild("Data"))
local Dinos = Data.Dinos
local Rebirths = Data.Rebirths

-- ==========================================
-- WINDUI SETUP
-- ==========================================
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI or not WindUI then
    warn("[IndraHub] Failed to load WindUI library")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub - Dig for Dinos 🦕",
    Icon = "pickaxe",
    Author = "IndraHub",
    Folder = "IndraHub_DigForDino",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local function notify(content, duration)
    pcall(function()
        if Window and Window.Notify then
            Window:Notify({
                Title = "IndraHub",
                Content = tostring(content),
                Duration = duration or 3,
            })
        elseif WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "IndraHub",
                Content = tostring(content),
                Duration = duration or 3,
            })
        end
    end)
end

-- Tabs
local MainTab = Window:Tab({ Title = "Main Farm", Icon = "pickaxe" })
local TeleportsTab = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- GAME DATA & WORLDS CONFIG
-- ==========================================
local ClaimDinosCFrame = CFrame.new(256.277588, 6.22658443, -134.723221, -0.0700938404, -1.28709514e-08, -0.997540414, -1.46516808e-08, 1, -1.1873162e-08, 0.997540414, 1.37834082e-08, -0.0700938404)

local activeConnections = {}

local function trackConnection(connection)
    activeConnections[#activeConnections + 1] = connection
    return connection
end

local Worlds = {
    {
        name = "World 7",
        zones = {
            { "Earthbound", CFrame.new(6734.52783, -245.821381, -8079.46728, 0.000436367206, 0, -0.999999905, 0, 1, 0, 0.999999905, 0, 0.000436367206) },
            { "Orbital", CFrame.new(6732.45117, -505.675629, -8079.54443, -0.0278344236, 0, -0.999612547, 0, 1, 0, 0.999612547, 0, -0.0278344236) },
            { "Lunar", CFrame.new(6735.14941, -826.826111, -8080.25147, -0.024693916, 0, -0.999695059, 0, 1, 0, 0.999695059, 0, -0.024693916) },
            { "Apollonian", CFrame.new(6737.40478, -1221.60498, -8078.99023, 0.0130023889, 0, -0.999915465, 0, 1, 0, 0.999915465, 0, 0.0130023889) },
            { "Artemisian", CFrame.new(6735.21924, -1728.43127, -8079.92725, -0.0152710373, 0, -0.999883391, 0, 1, 0, 0.999883391, 0, -0.0152710373) },
            { "Khonshian", CFrame.new(6734.80615, -2347.81812, -8079.44043, -0.0184121831, 0, -0.999830481, 0, 1, 0, 0.999830481, 0, -0.0184121831) },
            { "Xeno", CFrame.new(6733.70703, -3105.72021, -8080.12891, -0.00298447368, 0, -0.999995546, 0, 1, 0, 0.999995546, 0, -0.00298447368) },
            { "Extraterrestrial", CFrame.new(6736.88379, -4029.75293, -8077.57129, 0.00644027278, 0, -0.999979261, 0, 1, 0, 0.999979261, 0, 0.00644027278) },
        },
    },
    {
        name = "World 6",
        zones = {
            { "Charmed", CFrame.new(6737.00146, -249.197388, 6593.14404, -0.0169392861, -2.53930832e-08, -0.999856532, -2.31452635e-09, 1, -2.53575152e-08, 0.999856532, 1.88465621e-09, -0.0169392861) },
            { "Hexed", CFrame.new(6736.23438, -509.197357, 6594.07227, -0.00751324138, -7.56313767e-08, -0.999971747, 2.11650715e-08, 1, -7.57925349e-08, 0.999971747, -2.17339231e-08, -0.00751324138) },
            { "Enchanted", CFrame.new(6736.64551, -829.197388, 6593.16602, 0.0348937102, 2.77370993e-09, -0.9999391019, 1.56134021e-08, 1, 3.32054162e-09, 0.999391019, -1.57197597e-08, 0.0348937102) },
            { "Runic", CFrame.new(6736.25684, -1229.80103, 6593.03223, 0.0490193106, 1.66084728e-08, -0.998797834, 1.38920306e-08, 1, 1.73102599e-08, 0.998797834, -1.47238675e-08, 0.0490193106) },
            { "Leviathan", CFrame.new(6736.83203, -1722.28833, 6593.5542, 0.013791807, 6.10578565e-09, -0.999904871, 8.22807544e-10, 1, 6.11771567e-09, 0.999904871, -9.07103614e-10, 0.013791807) },
            { "Arcane", CFrame.new(6736.396, -2349.80127, 6594.15088, -0.0176249798, 6.35864197e-08, -0.99984467, 3.15268189e-09, 1, 6.35407247e-08, 0.99984467, -2.03228812e-09, -0.0176249798) },
            { "Dragonian", CFrame.new(6736.81104, -3109.80127, 6592.37891, 0.0389070176, -6.96779239e-08, -0.999242842, -1.18012782e-08, 1, -7.01902252e-08, 0.999242842, 1.45232351e-08, 0.0389070176) },
            { "Eldritch", CFrame.new(6737.31055, -4022.28882, 6594.25342, 0.0507960804, -8.8207166e-08, -0.998709023, 3.08041437e-09, 1, -8.81645121e-08, 0.998709023, 1.40197398e-09, 0.0507960804) },
        },
    },
    {
        name = "World 5",
        zones = {
            { "Sugared", CFrame.new(6736.05859, -249.197388, -872.862732, -0.0565745756, 8.77809256e-08, -0.998398364, -3.33523502e-08, 1, 8.9811671e-08, 0.998398364, 3.83799872e-08, -0.0565745756) },
            { "Sprinkled", CFrame.new(6736.92773, -509.197357, -873.004028, -0.0408848561, -4.8875556e-08, -0.999163866, 1.34183864e-08, 1, -4.94655268e-08, 0.999163866, -1.54295581e-08, -0.0408848561) },
            { "Sour", CFrame.new(6735.76123, -829.197388, -873.682556, -0.0630942881, -3.85886345e-09, -0.998007596, -1.41742795e-08, 1, -2.97046565e-09, 0.998007596, 1.39586191e-08, -0.0630942881) },
            { "Fizzy", CFrame.new(6734.69336, -1229.80103, -873.715393, 0.0206233561, -6.14434654e-08, -0.999787331, -3.7826247e-08, 1, -6.22368077e-08, 0.999787331, 3.91017352e-08, 0.0206233561) },
            { "Caramelized", CFrame.new(6736.13965, -1729.80103, -873.580078, 0.0376348719, -1.95005416e-08, -0.999291539, -5.76802321e-08, 1, -2.16866933e-08, 0.999291539, 5.84555444e-08, 0.0376348719) },
            { "Crystallized", CFrame.new(6736.31104, -2349.80127, -872.830994, 0.0313570052, 7.94116417e-09, -0.999508262, -7.37957695e-09, 1, 7.71355602e-09, 0.999508262, 7.13407422e-09, 0.0313570052) },
            { "Decadent", CFrame.new(6736.4541, -3109.80127, -872.143799, 0.037636254, 2.60526463e-08, -0.99929148, 5.98186887e-08, 1, 2.83240649e-08, 0.99929148, -6.08423179e-08, 0.037636254) },
            { "Insatiable", CFrame.new(6737.32666, -4022.28931, -874.700684, 0.0159449093, -1.09729015e-09, -0.999872863, 2.73234058e-08, 1, -6.61705024e-10, 0.999872863, -2.73093814e-08, 0.0159449093) },
        },
    },
    {
        name = "World 4",
        zones = {
            { "Blessed", CFrame.new(-24.4364166, -249.801025, -7450.4541, -0.0660624653, -2.38404905e-08, -0.99781549, -9.25590715e-09, 1, -2.32798776e-08, 0.99781549, 7.69776154e-09, -0.0660624653) },
            { "Ethereal", CFrame.new(-23.563242, -509.800995, -7449.56787, -0.0378356166, 2.2202058e-09, -0.999283969, 2.97153857e-09, 1, 2.1092863e-09, 0.999283969, -2.88960456e-09, -0.0378356166) },
            { "Elysian", CFrame.new(-23.6444321, -829.801025, -7449.00244, -0.000139891868, -2.95100531e-08, -1, -2.31165096e-08, 1, -2.95068183e-08, 1, 2.31123813e-08, -0.000139891868) },
            { "Celestial", CFrame.new(-24.4103031, -1229.80103, -7449.5, -0.05175988, 4.60532732e-08, -0.998659551, 1.83378468e-08, 1, 4.51646471e-08, 0.998659551, -1.59755498e-08, -0.05175988) },
            { "Angelic", CFrame.new(-24.2683601, -1729.80115, -7449.74268, 0.0549969785, 8.3733255e-08, -0.998486519, 2.97367997e-09, 1, 8.40239665e-08, 0.998486519, -7.59024399e-09, 0.0549969785) },
            { "Valhallan", CFrame.new(-24.7670135, -2349.80127, -7450.04102, -0.00465696305, -7.53203224e-08, -0.999989152, -2.54662282e-08, 1, -7.52025429e-08, 0.999989152, 2.5115737e-08, -0.00465696305) },
            { "Seraphic", CFrame.new(-25.0984173, -3109.80127, -7450.21387, -0.0674402043, -6.28672865e-08, -0.997723341, 2.19282263e-08, 1, -6.44929656e-08, 0.997723341, -2.62277222e-08, -0.0674402043) },
            { "Omnipotent", CFrame.new(-24.1282597, -4029.80127, -7450.09717, -0.157938108, 4.89414731e-08, -0.98744899, -4.40885408e-08, 1, 5.66153098e-08, 0.98744899, 5.24769028e-08, -0.157938108) },
        },
    },
    {
        name = "World 3",
        zones = {
            { "Frostbitten", CFrame.new(-7107.36621, -249.197388, -874.471191, -0.0724782571, -2.13126885e-08, -0.997370005, 2.43110398e-09, 1, -2.15455565e-08, 0.997370005, -3.98629441e-09, -0.0724782571) },
            { "Glacial", CFrame.new(-7108.75049, -509.197357, -873.803223, -0.077074565, 7.27362206e-08, -0.997025311, -3.26748477e-08, 1, 7.54791429e-08, 0.997025311, 3.8395175e-08, -0.077074565) },
            { "Whiteout", CFrame.new(-7108.66211, -829.197388, -873.737732, 0.0127838934, -6.14040943e-08, -0.999918282, -1.66610334e-08, 1, -6.16221172e-08, 0.999918282, 1.74474426e-08, 0.0127838934) },
            { "IceCrystal", CFrame.new(-7109.4502, -1229.80103, -873.838562, -0.0531642251, -3.60742582e-08, -0.998585761, 9.43748404e-08, 1, -4.11498178e-08, 0.998585761, -9.64290692e-08, -0.0531642251) },
            { "Borealis", CFrame.new(-7106.76416, -1722.28845, -874.505737, -0.0669314489, -9.89669058e-09, -0.997757554, 1.78751036e-09, 1, -1.00388426e-08, 0.997757554, -2.45541631e-09, -0.0669314489) },
            { "Prismatic", CFrame.new(-7107.93652, -2349.80127, -874.871521, -0.00647993153, 1.1946768e-08, -0.999979019, -2.42240414e-08, 1, 1.21039916e-08, 0.999979019, 2.43019667e-08, -0.00647993153) },
            { "Spectral", CFrame.new(-7107.68311, -3109.80127, -874.094238, -0.0519523956, -2.27088055e-08, -0.998649538, 9.29715114e-08, 1, -2.75761369e-08, 0.998649538, -9.42786045e-08, -0.0519523956) },
            { "Cosmic", CFrame.new(-7106.58301, -4022.28882, -874.4021, -0.00405639783, -1.07583062e-07, -0.999991775, -1.61965161e-08, 1, -1.07518247e-07, 0.999991775, 1.57602464e-08, -0.00405639783) },
        },
    },
    {
        name = "World 2",
        zones = {
            { "Primal", CFrame.new(130.773972, -249.932449, 6871.01367, 0.0377811268, -6.75098093e-08, 0.999286056, 1.57284158e-10, 1, 6.75520937e-08, -0.999286056, -2.3950224e-09, 0.0377811268) },
            { "Prehistoric", CFrame.new(132.319473, -509.34726, 6875.81543, 0.0213362593, -1.19052208e-08, 0.99977237, 3.91781079e-08, 1, 1.1071827e-08, -0.99977237, 3.893296e-08, 0.0213362593) },
            { "Fossilized", CFrame.new(131.826187, -829.932556, 6876.28369, 0.0315402187, -1.50500092e-08, 0.99950248, -3.02788763e-08, 1, 1.60129776e-08, -0.99950248, -3.0768863e-08, 0.0315402187) },
            { "Extinction", CFrame.new(131.858932, -1229.34717, 6874.91113, -0.00306858961, 6.39295266e-08, 0.999995291, 5.07487741e-08, 1, -6.37741024e-08, -0.999995291, 5.05528384e-08, -0.00306858961) },
            { "Genesis", CFrame.new(132.77272, -1729.93237, 6876.53223, 0.433732212, -8.8491106e-08, 0.901041806, 1.22371603e-07, 1, 3.93040587e-08, -0.901041806, 9.32144886e-08, 0.433732212) },
            { "Eternal", CFrame.new(131.48204, -2349.34741, 6874.25342, 0.0834260359, -5.47401946e-08, 0.996513963, -6.7618096e-08, 1, 6.05925266e-08, -0.996513963, -7.24373734e-08, 0.0834260359) },
            { "Meteoric", CFrame.new(131.900726, -3109.93262, 6876.49463, -0.0173395891, 5.45614434e-08, 0.999849677, -8.97345274e-08, 1, -5.61258418e-08, -0.999849677, -9.06942361e-08, -0.0173395891) },
            { "Apex", CFrame.new(128.974655, -4022.64941, 6877.00879, 0.0321365856, -2.32511628e-08, 0.999483466, 5.96797776e-08, 1, 2.13442828e-08, -0.999483466, 5.89630176e-08, 0.0321365856) },
        },
    },
    {
        name = "World 1",
        zones = {
            { "Common", CFrame.new(-32.7610817, -82.0928421, -116.216232, -0.0161483604, -9.88939419e-08, -0.999869585, 3.1562795e-08, 1, -9.94165887e-08, 0.999869585, -3.31640955e-08, -0.0161483604) },
            { "Uncommon", CFrame.new(-32.7610817, -342.05307, -116.216232, -0.0161483604, 1.18497944e-07, -0.999869585, -3.77434937e-08, 1, 1.19122973e-07, 0.999869585, 3.96622148e-08, -0.0161483604) },
            { "Rare", CFrame.new(-32.7610817, -662.092896, -116.216232, -0.0161483604, -2.32178952e-08, -0.999869585, 7.38395967e-09, 1, -2.33401778e-08, 0.999869585, -7.75990205e-09, -0.0161483604) },
            { "Epic", CFrame.new(-32.7610817, -1062.0929, -116.216232, -0.0161483604, -5.79326063e-08, -0.999869585, 1.83957969e-08, 1, -5.82372586e-08, 0.999869585, -1.93338341e-08, -0.0161483604) },
            { "Legendary", CFrame.new(-32.7610817, -1562.0929, -116.216232, -0.0161483604, -4.87015299e-08, -0.999869585, 1.54312669e-08, 1, -4.89571015e-08, 0.999869585, -1.62198308e-08, -0.0161483604) },
            { "Mythic", CFrame.new(-32.7610817, -2182.76489, -116.216232, -0.0161483604, -6.59061161e-09, -0.999869585, 2.08302264e-09, 1, -6.6251129e-09, 0.999869585, -2.18973573e-09, -0.0161483604) },
            { "Secret", CFrame.new(-32.7610817, -2942.09302, -116.216232, -0.0161483604, -6.58329853e-08, -0.999869585, 2.0741334e-08, 1, -6.6176554e-08, 0.999869585, -2.18072724e-08, -0.0161483604) },
            { "Ancient", CFrame.new(-32.7610817, -3860.76489, -116.216232, -0.0161483604, -9.14856524e-10, -0.999869585, 2.87143059e-10, 1, -9.19613274e-10, 0.999869585, -3.01955877e-10, -0.0161483604) },
        },
    },
}

for _, world in ipairs(Worlds) do
    local ordered = {}
    for index = #world.zones, 1, -1 do
        ordered[#ordered + 1] = world.zones[index]
    end
    world.zones = ordered
end

local Teleports = {}
local ZoneNames = {}
for _, world in ipairs(Worlds) do
    for _, zone in ipairs(world.zones) do
        Teleports[zone[1]] = zone[2]
        table.insert(ZoneNames, zone[1])
    end
end

-- Helper functions
local function getCharacterParts()
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return nil end
    return character, root, humanoid
end

local function pinToGround(humanoid)
    if not humanoid then return end
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end

local function releaseGround(humanoid)
    if not humanoid then return end
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
    end)
end

local function anchorTeleport(root, humanoid, cframe)
    pcall(function()
        pinToGround(humanoid)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = true
        root.CFrame = cframe
    end)
    RunService.Heartbeat:Wait()
    pcall(function()
        root.CFrame = cframe
        root.Anchored = false
    end)
end

local function pivotTo(cframe)
    local result = false
    local lastHumanoid
    for _ = 1, 4 do
        local deadline = os.clock() + 2
        local character, root, humanoid
        repeat
            character, root, humanoid = getCharacterParts()
            if not character then RunService.Heartbeat:Wait() end
        until character or os.clock() >= deadline
        lastHumanoid = humanoid or lastHumanoid
        if character and root then
            anchorTeleport(root, humanoid, cframe)
            local _, currentRoot, currentHumanoid = getCharacterParts()
            lastHumanoid = currentHumanoid or lastHumanoid
            if currentRoot and (currentRoot.Position - cframe.Position).Magnitude <= 20 then
                result = true
                break
            end
        end
        RunService.Heartbeat:Wait()
    end
    releaseGround(lastHumanoid)
    return result
end

local function teleportTo(zone, silent)
    local target = Teleports[zone]
    if not target then return false end
    local success = pivotTo(target)
    if not silent then
        if success then
            notify("Teleported to " .. zone, 2)
        else
            notify("Character unavailable", 2)
        end
    end
    return success
end

local function teleportClaimDinos(silent)
    local success = pivotTo(ClaimDinosCFrame)
    if success then
        local deadline = os.clock() + 0.3
        while os.clock() < deadline do
            local character, root, humanoid = getCharacterParts()
            if not character or not root then
                success = false
                break
            end
            pcall(function()
                pinToGround(humanoid)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if (root.Position - ClaimDinosCFrame.Position).Magnitude > 4 then
                    root.CFrame = ClaimDinosCFrame
                end
            end)
            RunService.Heartbeat:Wait()
        end
        local _, _, endHumanoid = getCharacterParts()
        releaseGround(endHumanoid)
        local _, root = getCharacterParts()
        success = root ~= nil and (root.Position - ClaimDinosCFrame.Position).Magnitude <= 18
    end
    if not silent then
        if success then
            notify("Teleported to Claim Dinos", 2)
        else
            notify("Claim teleport failed", 2)
        end
    end
    return success
end

local resetting = false

local function forceReset()
    if resetting then return false end
    resetting = true
    local _, root, humanoid = getCharacterParts()
    if root then
        pcall(function()
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    releaseGround(humanoid)
    local character = LocalPlayer.Character
    if character then
        pcall(function()
            local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            if currentHumanoid then
                currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                currentHumanoid.Health = 0
                currentHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
            end
        end)
        local deadline = os.clock() + 8
        while LocalPlayer.Character == character and os.clock() < deadline do
            RunService.Heartbeat:Wait()
        end
    end
    local deadline = os.clock() + 8
    while os.clock() < deadline do
        if getCharacterParts() then break end
        RunService.Heartbeat:Wait()
    end
    resetting = false
    return getCharacterParts() ~= nil
end

-- ==========================================
-- DINO FARMING & REBIRTH LOGIC
-- ==========================================
local firePrompt = fireproximityprompt
local selectedZone = ZoneNames[1]
local getDinoBusy = false
local getDinoGeneration = 0
local getDinoTeleportDelay = 0.12
local lastGetDinoTeleport = -math.huge
local cachedLocalStates

local moneySuffixes = { "", "k", "m", "b", "t", "q", "qi", "sx", "sp", "oc", "no", "dc" }

local function abbreviateNumber(value)
    local number = tonumber(value)
    if not number then return tostring(value) end
    local negative = number < 0
    number = math.abs(number)
    local index = 1
    while number >= 1000 and index < #moneySuffixes do
        number = number / 1000
        index += 1
    end
    local text
    if index == 1 then
        text = tostring(math.floor(number + 0.5))
    else
        text = (string.format("%.2f", number):gsub("%.?0+$", ""))
    end
    return (negative and "-" or "") .. text .. moneySuffixes[index]
end

local function actionActive(generation)
    return getDinoBusy and generation == getDinoGeneration
end

local function waitAction(seconds, generation)
    local deadline = os.clock() + seconds
    while os.clock() < deadline do
        if not actionActive(generation) then return false end
        task.wait(math.min(0.04, deadline - os.clock()))
    end
    return actionActive(generation)
end

local function waitForActionCharacter(generation, timeout)
    local deadline = os.clock() + timeout
    while actionActive(generation) and os.clock() < deadline do
        local character, root, humanoid = getCharacterParts()
        if character and root and humanoid then
            return character, root, humanoid
        end
        RunService.Heartbeat:Wait()
    end
    return nil
end

local function actionTeleport(targetSource, generation)
    for _ = 1, 4 do
        if not actionActive(generation) then return false end
        local remaining = getDinoTeleportDelay - (os.clock() - lastGetDinoTeleport)
        if remaining > 0 and not waitAction(remaining, generation) then return false end
        local character, root, humanoid = waitForActionCharacter(generation, 1.5)
        if not character or not root then return false end
        local cframe = type(targetSource) == "function" and targetSource() or targetSource
        if not cframe then return false end
        lastGetDinoTeleport = os.clock()
        anchorTeleport(root, humanoid, cframe)
        local currentCharacter, currentRoot = getCharacterParts()
        if currentCharacter == character and currentRoot and (currentRoot.Position - cframe.Position).Magnitude <= 14 then
            return true
        end
    end
    return false
end

local promptCache = setmetatable({}, { __mode = "k" })

local function getPickupPrompt(model)
    local cached = promptCache[model]
    if cached and cached.Parent then return cached end
    local root = model:FindFirstChild("HumanoidRootPart")
    if root then
        local prompt = root:FindFirstChild("PickupDinoProximityPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            promptCache[model] = prompt
            return prompt
        end
    end
    return nil
end

local function promptActive(prompt)
    local ok, active = pcall(function()
        return prompt.Enabled and prompt.Parent ~= nil and prompt:IsDescendantOf(Workspace)
    end)
    return ok and active
end

local function makePromptInstant(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true
    end)
end

local function fireInstantPrompt(prompt)
    makePromptInstant(prompt)
    pcall(firePrompt, prompt, 0)
    pcall(firePrompt, prompt)
    if type(firesignal) == "function" and promptActive(prompt) then
        pcall(firesignal, prompt.Triggered, LocalPlayer)
    end
end

local function dinoAvailable(model, prompt)
    local ok, available = pcall(function()
        return model:IsDescendantOf(Workspace)
            and model:GetAttribute("ItemType") == "Dino"
            and type(model:GetAttribute("CashPerSecond")) == "number"
            and promptActive(prompt)
    end)
    return ok and available
end

local dinoModels = {}
local watchedContainers = setmetatable({}, { __mode = "k" })
local pendingAttributes = setmetatable({}, { __mode = "k" })

local function trackDino(instance)
    if not instance:IsA("Model") then return end
    local itemType = instance:GetAttribute("ItemType")
    if itemType == "Dino" then
        dinoModels[instance] = true
        return
    end
    if itemType == nil and not pendingAttributes[instance] then
        local connection
        connection = trackConnection(instance:GetAttributeChangedSignal("ItemType"):Connect(function()
            if instance:GetAttribute("ItemType") == "Dino" then
                dinoModels[instance] = true
                pendingAttributes[instance] = nil
                connection:Disconnect()
            end
        end))
        pendingAttributes[instance] = connection
    end
end

local function watchContainer(container)
    if watchedContainers[container] or not container.Name:match("^MineDinos_") then return end
    watchedContainers[container] = true
    trackConnection(container.DescendantAdded:Connect(trackDino))
    trackConnection(container.DescendantRemoving:Connect(function(instance)
        dinoModels[instance] = nil
    end))
    for _, descendant in ipairs(container:GetDescendants()) do
        trackDino(descendant)
    end
end

for _, container in ipairs(Workspace:GetChildren()) do
    watchContainer(container)
end

trackConnection(Workspace.ChildAdded:Connect(watchContainer))

local function findBestDinoByFilter(filter)
    local bestModel, bestPrompt
    local bestCash = -math.huge
    for model in pairs(dinoModels) do
        if not model.Parent then
            dinoModels[model] = nil
        elseif filter(model) then
            local cash = model:GetAttribute("CashPerSecond")
            if type(cash) == "number" and cash > bestCash then
                local prompt = getPickupPrompt(model)
                if prompt and promptActive(prompt) then
                    bestModel = model
                    bestPrompt = prompt
                    bestCash = cash
                end
            end
        end
    end
    return bestModel, bestPrompt, bestCash
end

local function findBestDinoForZone(zone)
    return findBestDinoByFilter(function(model)
        return model:GetAttribute("Rarity") == zone
    end)
end

local function findDinoById(dinoId)
    return findBestDinoByFilter(function(model)
        return model:GetAttribute("DinoId") == dinoId
    end)
end

local function findDinoInSet(allowed)
    return findBestDinoByFilter(function(model)
        return allowed[model:GetAttribute("DinoId")] == true
    end)
end

local function waitForDino(finder, generation, timeout)
    local deadline = os.clock() + timeout
    while actionActive(generation) and os.clock() < deadline do
        local model, prompt, cash = finder()
        if model then return model, prompt, cash end
        RunService.Heartbeat:Wait()
    end
    return nil
end

local function isDinoTool(instance)
    return instance:IsA("Tool")
        and (instance:GetAttribute("InventoryType") == "Dino" or type(instance:GetAttribute("DinoId")) == "string")
end

local function getDinoToolSnapshot()
    local snapshot = {}
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if isDinoTool(child) then snapshot[child] = true end
        end
    end
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if isDinoTool(child) then snapshot[child] = true end
        end
    end
    return snapshot
end

local function findNewDinoTool(snapshot, dinoId)
    local function inspect(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if not snapshot[child] and isDinoTool(child) and child:GetAttribute("DinoId") == dinoId then
                return child
            end
        end
        return nil
    end
    return inspect(LocalPlayer:FindFirstChildOfClass("Backpack")) or inspect(LocalPlayer.Character)
end

local function waitForNewDinoTool(snapshot, dinoId, generation, timeout)
    local deadline = os.clock() + timeout
    while actionActive(generation) and os.clock() < deadline do
        if not getCharacterParts() then return nil end
        local tool = findNewDinoTool(snapshot, dinoId)
        if tool then return tool end
        RunService.Heartbeat:Wait()
    end
    return nil
end

local function captureDino(model, prompt, generation)
    local dinoId = model:GetAttribute("DinoId")
    if type(dinoId) ~= "string" then return false end
    local snapshot = getDinoToolSnapshot()
    for _ = 1, 14 do
        if not actionActive(generation) or not getCharacterParts() then
            return findNewDinoTool(snapshot, dinoId)
        end
        if not dinoAvailable(model, prompt) then
            return waitForNewDinoTool(snapshot, dinoId, generation, 0.5)
        end
        local promptRoot = prompt.Parent
        local _, playerRoot, playerHum = getCharacterParts()
        if promptRoot and promptRoot:IsA("BasePart") and playerRoot and (playerRoot.Position - promptRoot.Position).Magnitude > 6 then
            anchorTeleport(playerRoot, playerHum, promptRoot.CFrame * CFrame.new(0, 0, 4))
        end
        fireInstantPrompt(prompt)
        local tool = waitForNewDinoTool(snapshot, dinoId, generation, 0.1)
        if tool then return tool end
    end
    return findNewDinoTool(snapshot, dinoId)
end

local function ownsCapturedDino(tool, dinoId)
    if not tool or not tool.Parent or tool:GetAttribute("DinoId") ~= dinoId then return false end
    return tool.Parent == LocalPlayer.Character or tool.Parent == LocalPlayer:FindFirstChildOfClass("Backpack")
end

local function claimCapturedDino(tool, dinoId, generation)
    if not actionTeleport(ClaimDinosCFrame, generation) then return false end
    local claimed = false
    local deadline = os.clock() + 0.45
    while actionActive(generation) and os.clock() < deadline do
        local character, root, humanoid = getCharacterParts()
        if not character or not root or not humanoid then
            local _, _, deadHumanoid = getCharacterParts()
            releaseGround(deadHumanoid)
            return false
        end
        if not ownsCapturedDino(tool, dinoId) then
            claimed = true
            releaseGround(humanoid)
            break
        end
        pcall(function()
            pinToGround(humanoid)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            if (root.Position - ClaimDinosCFrame.Position).Magnitude > 4 then
                root.CFrame = ClaimDinosCFrame
            end
        end)
        if not waitAction(0.02, generation) then
            local _, _, cancelHumanoid = getCharacterParts()
            releaseGround(cancelHumanoid)
            return false
        end
    end
    local _, root, endHumanoid = getCharacterParts()
    releaseGround(endHumanoid)
    if claimed then return true end
    return root ~= nil and (root.Position - ClaimDinosCFrame.Position).Magnitude <= 18
end

local function resolveDinoTarget(model, prompt)
    if not dinoAvailable(model, prompt) then return nil end
    local root = prompt.Parent
    if not root or not root:IsA("BasePart") then return nil end
    return root.CFrame * CFrame.new(0, 0, 4)
end

local function collectBestDino(generation, finder, timeout)
    local lastDetail = "No dinos available"
    for _ = 1, 3 do
        if not actionActive(generation) then return false, "Action cancelled" end
        local model, prompt, cash = waitForDino(finder, generation, timeout)
        if not model then return false, lastDetail end
        local dinoId = model:GetAttribute("DinoId")
        if actionTeleport(function()
            return resolveDinoTarget(model, prompt)
        end, generation) and waitAction(0.04, generation) then
            prompt = getPickupPrompt(model)
            local capturedTool = prompt and captureDino(model, prompt, generation)
            if capturedTool then
                if not claimCapturedDino(capturedTool, dinoId, generation) then
                    return false, "Claim teleport failed"
                end
                return true, dinoId, cash
            end
            lastDetail = "Could not confirm pickup"
        else
            lastDetail = "Dino teleport failed"
        end
    end
    return false, lastDetail
end

local function executeGetDino(generation, zone)
    if not actionTeleport(Teleports[zone], generation) then
        return false, "Zone teleport failed"
    end
    if not waitAction(0.12, generation) then
        return false, "Action cancelled"
    end
    return collectBestDino(generation, function()
        return findBestDinoForZone(zone)
    end, 4)
end

local function validRebirthSummary(value)
    return type(value) == "table"
        and type(value.missingDinos) == "table"
        and (type(value.nextRebirthIndex) == "number" or value.nextRebirthIndex == nil)
end

local function readMemoryRebirthSummary()
    if cachedLocalStates then
        local ok, summary = pcall(cachedLocalStates.Peek, "RebirthSummary")
        if ok and validRebirthSummary(summary) then return summary end
        cachedLocalStates = nil
    end
    if type(getgc) ~= "function" then return nil end
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return nil end
    for _, object in ipairs(objects) do
        if type(object) == "table" then
            local peek = rawget(object, "Peek")
            local getAll = rawget(object, "GetAll")
            if type(peek) == "function" and type(getAll) == "function" then
                local success, summary = pcall(peek, "RebirthSummary")
                if success and validRebirthSummary(summary) then
                    cachedLocalStates = object
                    return summary
                end
            end
        end
    end
    return nil
end

local function normalizeDinoName(value)
    return tostring(value):lower():gsub("[^%w]", "")
end

local function readGuiRebirthSummary()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local index
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            index = tonumber(descendant.Text:match("Rebirth%s*#(%d+)%s*Requirements"))
            if index then break end
        end
    end
    local config = index and Rebirths.Definitions[index]
    if not config then return nil end
    local entries = {}
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("Frame") and descendant.Name == "RebirthDinoEntry_Runtime" then
            entries[#entries + 1] = descendant
        end
    end
    if #entries == 0 then return nil end
    local missing = {}
    local matched = 0
    for _, dinoId in ipairs(config.RequiredDinos or {}) do
        local definition = Dinos.GetDefinition(dinoId)
        local displayName = definition and definition.Name or dinoId
        local targetName = normalizeDinoName(displayName)
        for _, entry in ipairs(entries) do
            local label = entry:FindFirstChild("RebirthDinoEntry_Name", true)
            if label and normalizeDinoName(label.Text) == targetName then
                matched += 1
                local cross = entry:FindFirstChild("CrossOutIcon", true)
                if cross and cross.Visible then missing[#missing + 1] = dinoId end
                break
            end
        end
    end
    if matched ~= #(config.RequiredDinos or {}) then return nil end
    return {
        nextRebirthIndex = index,
        rebirthConfig = config,
        missingDinos = missing,
    }
end

local function getRebirthSummary()
    return readMemoryRebirthSummary() or readGuiRebirthSummary()
end

local function dinoDisplayName(dinoId)
    local definition = Dinos.GetDefinition(dinoId)
    return definition and definition.Name or tostring(dinoId)
end

local function listNames(ids, limit)
    local names = {}
    for index, dinoId in ipairs(ids) do
        if index > limit then
            names[#names + 1] = "+" .. (#ids - limit)
            break
        end
        names[#names + 1] = dinoDisplayName(dinoId)
    end
    return table.concat(names, ", ")
end

local function analyzeRebirth()
    local summary = getRebirthSummary()
    if not summary then return nil, "Open the Rebirth menu once and try again" end
    local config = summary.rebirthConfig
    if type(config) ~= "table" or type(config.RequiredDinos) ~= "table" then
        local ok, definition = pcall(function()
            return Rebirths.Definitions[summary.nextRebirthIndex]
        end)
        config = ok and definition or nil
    end
    if type(config) ~= "table" or type(config.RequiredDinos) ~= "table" then
        return nil, "Rebirth requirements unavailable"
    end
    local allowed = {}
    for _, dinoId in ipairs(config.RequiredDinos) do allowed[dinoId] = true end
    local missing = {}
    local seen = {}
    for _, dinoId in ipairs(summary.missingDinos or {}) do
        if allowed[dinoId] and not seen[dinoId] then
            seen[dinoId] = true
            missing[#missing + 1] = dinoId
        end
    end
    return {
        index = summary.nextRebirthIndex,
        requiredCount = #config.RequiredDinos,
        missing = missing,
    }
end

local function collectTargetDino(generation, dinoId)
    for _ = 1, 2 do
        if not actionActive(generation) then return false, "Action cancelled" end
        local model, prompt, cash = findDinoById(dinoId)
        if not model then return false, "missing" end
        if actionTeleport(function()
            return resolveDinoTarget(model, prompt)
        end, generation) and waitAction(0.04, generation) then
            prompt = getPickupPrompt(model)
            if prompt and model:GetAttribute("DinoId") == dinoId and dinoAvailable(model, prompt) then
                local capturedTool = captureDino(model, prompt, generation)
                if capturedTool and capturedTool:GetAttribute("DinoId") == dinoId then
                    if not claimCapturedDino(capturedTool, dinoId, generation) then
                        return false, "Claim teleport failed"
                    end
                    return true, dinoDisplayName(dinoId), cash
                end
            end
        end
    end
    return false, "missing"
end

local function executeGetRebirthDino(generation)
    local analysis, failure = analyzeRebirth()
    if not analysis then return false, failure end
    local missing = analysis.missing
    local label = "Rebirth #" .. tostring(analysis.index or "?")
    if #missing == 0 then
        return false, label .. ": " .. analysis.requiredCount .. "/" .. analysis.requiredCount .. " dinos ready"
    end
    notify(label .. ": missing " .. #missing .. "/" .. analysis.requiredCount .. " - " .. listNames(missing, 4), 4)
    local groups = {}
    local order = {}
    local unreachable = {}
    for _, dinoId in ipairs(missing) do
        local definition = Dinos.GetDefinition(dinoId)
        local rarity = definition and definition.Rarity
        if rarity and Teleports[rarity] then
            if not groups[rarity] then
                groups[rarity] = {}
                order[#order + 1] = rarity
            end
            groups[rarity][dinoId] = true
        else
            unreachable[#unreachable + 1] = dinoId
        end
    end
    if #order == 0 then
        return false, "No zone available for: " .. listNames(unreachable, 4)
    end
    for _, rarity in ipairs(order) do
        if not actionActive(generation) then return false, "Action cancelled" end
        if actionTeleport(Teleports[rarity], generation) then
            if not waitAction(0.12, generation) then return false, "Action cancelled" end
            local allowed = groups[rarity]
            local attempts = 0
            while attempts < 3 do
                attempts += 1
                local model = waitForDino(function()
                    return findDinoInSet(allowed)
                end, generation, 2.5)
                if not model then break end
                local dinoId = model:GetAttribute("DinoId")
                if type(dinoId) ~= "string" or not allowed[dinoId] then break end
                local ok, detail, cash = collectTargetDino(generation, dinoId)
                if ok then return true, detail, cash end
                if detail == "Action cancelled" or detail == "Claim teleport failed" then
                    return false, detail
                end
            end
        end
    end
    return false, "Rebirth dinos not spawned yet - waiting for: " .. listNames(missing, 4)
end

local function startDinoAction(executor)
    if getDinoBusy then
        notify("A Dino action is already running", 2)
        return
    end
    if type(firePrompt) ~= "function" then
        notify("Executor function unavailable", 3)
        return
    end
    getDinoBusy = true
    getDinoGeneration += 1
    local generation = getDinoGeneration
    lastGetDinoTeleport = -math.huge
    task.spawn(function()
        local callOk, success, detail, cash = pcall(executor, generation)
        if generation ~= getDinoGeneration then return end
        getDinoBusy = false
        if not callOk then
            notify("Dino action failed unexpectedly", 3)
        elseif success then
            notify(tostring(detail) .. " - $" .. abbreviateNumber(cash) .. "/s", 4)
        else
            notify(tostring(detail), 3)
        end
    end)
end

local function cancelDinoAction(reason)
    if not getDinoBusy then return false end
    getDinoBusy = false
    getDinoGeneration += 1
    local _, root, humanoid = getCharacterParts()
    if root then
        pcall(function() root.Anchored = false end)
    end
    releaseGround(humanoid)
    if reason then notify(reason, 3) end
    return true
end

local function watchCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    trackConnection(humanoid.Died:Connect(function()
        local wasBusy = cancelDinoAction("Died - Dino action stopped")
        task.spawn(function()
            if forceReset() and wasBusy then
                notify("Character reset", 2)
            end
        end)
    end))
end

if LocalPlayer.Character then watchCharacter(LocalPlayer.Character) end
trackConnection(LocalPlayer.CharacterAdded:Connect(watchCharacter))

-- Auto Respawn Handler
local respawnTag = "DeathMenu_RespawnButton"
local lastRespawnClick = -math.huge

local function effectivelyVisible(instance)
    local node = instance
    while node do
        if node:IsA("LayerCollector") then return node.Enabled end
        if node:IsA("GuiObject") and not node.Visible then return false end
        node = node.Parent
    end
    return false
end

local function clickRespawn(button)
    local fired = false
    if type(getconnections) == "function" then
        local ok, connections = pcall(getconnections, button.Activated)
        if ok and type(connections) == "table" then
            for _, connection in ipairs(connections) do
                if pcall(function() connection:Fire(1) end) then fired = true end
            end
        end
    end
    if not fired and type(firesignal) == "function" then
        fired = pcall(firesignal, button.Activated, 1)
        pcall(firesignal, button.MouseButton1Click)
    end
    return fired
end

local function tryAutoRespawn()
    if os.clock() - lastRespawnClick < 1.5 then return end
    for _, button in ipairs(CollectionService:GetTagged(respawnTag)) do
        if button:IsA("GuiButton")
            and button:IsDescendantOf(LocalPlayer)
            and button.Active
            and effectivelyVisible(button)
            and clickRespawn(button) then
            lastRespawnClick = os.clock()
            return
        end
    end
end

local respawnAccumulator = 0
trackConnection(RunService.Heartbeat:Connect(function(delta)
    respawnAccumulator += delta
    if respawnAccumulator < 0.2 then return end
    respawnAccumulator = 0
    pcall(tryAutoRespawn)
end))

trackConnection(CollectionService:GetInstanceAddedSignal(respawnTag):Connect(function()
    task.delay(0.1, function() pcall(tryAutoRespawn) end)
end))

-- WalkSpeed Logic
local walkSpeedEnabled = false
local walkSpeedValue = 45
local defaultWalkSpeed

local function setWalkSpeed(value)
    local _, _, humanoid = getCharacterParts()
    if humanoid then humanoid.WalkSpeed = value end
end

trackConnection(RunService.Heartbeat:Connect(function()
    if walkSpeedEnabled then setWalkSpeed(walkSpeedValue) end
end))

-- Auto Loop Flags
local autoGetDinoEnabled = false
local autoGetRebirthDinosEnabled = false
local antiAFKEnabled = false
local antiAFKConn = nil

task.spawn(function()
    while getGlobal("IndraHubDigForDinoRunning") do
        if autoGetDinoEnabled and not getDinoBusy then
            local zone = selectedZone
            if Teleports[zone] then
                startDinoAction(function(generation)
                    return executeGetDino(generation, zone)
                end)
            end
        elseif autoGetRebirthDinosEnabled and not getDinoBusy then
            startDinoAction(executeGetRebirthDino)
        end
        task.wait(1.5)
    end
end)

-- ==========================================
-- BUILD WINDUI INTERFACE
-- ==========================================

-- MAIN TAB: FARM & MOVEMENT
MainTab:Section({ Title = "Farm Settings" })

MainTab:Dropdown({
    Title = "Rarity / Zone",
    Values = ZoneNames,
    Value = selectedZone,
    Callback = function(value)
        if type(value) == "string" then selectedZone = value end
    end,
})

MainTab:Button({
    Title = "Get Dino",
    Callback = function()
        local zone = selectedZone
        if not Teleports[zone] then
            notify("Invalid rarity", 2)
            return
        end
        startDinoAction(function(generation)
            return executeGetDino(generation, zone)
        end)
    end,
})

MainTab:Toggle({
    Title = "Auto Get Dino",
    Value = false,
    Callback = function(v)
        autoGetDinoEnabled = v
        if v then autoGetRebirthDinosEnabled = false end
    end,
})

MainTab:Button({
    Title = "Get Rebirth Dinos",
    Callback = function()
        startDinoAction(executeGetRebirthDino)
    end,
})

MainTab:Toggle({
    Title = "Auto Get Rebirth Dinos",
    Value = false,
    Callback = function(v)
        autoGetRebirthDinosEnabled = v
        if v then autoGetDinoEnabled = false end
    end,
})

MainTab:Button({
    Title = "Force Reset Character",
    Callback = function()
        cancelDinoAction("Dino action stopped")
        task.spawn(forceReset)
    end,
})

MainTab:Section({ Title = "Movement & Utilities" })

MainTab:Toggle({
    Title = "WalkSpeed Toggle",
    Value = false,
    Callback = function(value)
        walkSpeedEnabled = value
        if value then
            local _, _, humanoid = getCharacterParts()
            if humanoid and not defaultWalkSpeed then
                defaultWalkSpeed = humanoid.WalkSpeed
            end
            setWalkSpeed(walkSpeedValue)
        else
            setWalkSpeed(defaultWalkSpeed or 16)
            defaultWalkSpeed = nil
        end
    end,
})

MainTab:Slider({
    Title = "WalkSpeed Value",
    Value = { Min = 25, Max = 125, Default = 45 },
    Step = 1,
    Callback = function(value)
        walkSpeedValue = value
        if walkSpeedEnabled then setWalkSpeed(walkSpeedValue) end
    end,
})

MainTab:Button({
    Title = "TP to Claim Dinos",
    Callback = function()
        teleportClaimDinos()
    end,
})

-- TELEPORTS TAB: WORLD BY WORLD
for _, world in ipairs(Worlds) do
    local zoneList = {}
    for _, z in ipairs(world.zones) do
        table.insert(zoneList, z[1])
    end

    TeleportsTab:Section({ Title = world.name })
    local selectedWorldZone = zoneList[1]

    TeleportsTab:Dropdown({
        Title = world.name .. " Zone",
        Values = zoneList,
        Value = selectedWorldZone,
        Callback = function(val)
            if type(val) == "string" then selectedWorldZone = val end
        end,
    })

    TeleportsTab:Button({
        Title = "Teleport to " .. world.name,
        Callback = function()
            if selectedWorldZone then
                teleportTo(selectedWorldZone)
            end
        end,
    })
end

-- SETTINGS TAB
SettingsTab:Section({ Title = "Anti-AFK & System" })

SettingsTab:Toggle({
    Title = "Anti-AFK (Heartbeat)",
    Desc = "Spams VirtualUser clicks to prevent AFK kick.",
    Value = false,
    Callback = function(v)
        antiAFKEnabled = v
        if v then
            if not antiAFKConn then
                antiAFKConn = RunService.Heartbeat:Connect(function()
                    pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
                end)
            end
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end,
})

local function unloadScript()
    setGlobal("IndraHubDigForDinoRunning", false)
    getDinoBusy = false
    getDinoGeneration += 1
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
    for _, connection in ipairs(activeConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(activeConnections)
    table.clear(dinoModels)
    if Window and Window.Destroy then
        pcall(function() Window:Destroy() end)
    end
    notify("IndraHub Dig for Dinos Unloaded", 3)
    print("[IndraHub] Dig for Dinos unloaded successfully.")
end

setGlobal("IndraHubDigForDinoUnload", unloadScript)

SettingsTab:Button({
    Title = "Unload UI",
    Callback = unloadScript,
})

notify("Loaded IndraHub Dig for Dinos 🦕", 4)
