--========================================================--
--  IndraHub | Ride A Pet (PlaceId: 124216119978534, GameId: 10035204815)
--  Rebuilt with WindUI & Supervisor Watchdog Heartbeat.
--  Full Automation: Eggs, Nests, Pets, Upgrades, Rebirths.
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

--================ Supervisor & Global Heartbeat ================--
local env = getgenv and getgenv() or _G
local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local val = env[key]
    if val ~= nil then return val end
    return rawget(_G, key)
end

_G.__INDRA_RIDEAPET = (_G.__INDRA_RIDEAPET or 0) + 1
local GEN = _G.__INDRA_RIDEAPET

setGlobal("IndraHubRideAPetRunning", true)
setGlobal("IndraHubRideAPetLastHeartbeat", os.clock())

task.spawn(function()
    while _G.__INDRA_RIDEAPET == GEN and getGlobal("IndraHubRideAPetRunning") do
        task.wait(2)
        setGlobal("IndraHubRideAPetLastHeartbeat", os.clock())
        setGlobal("IndraHubRideAPetRunning", true)
        if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubRideAPetLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubRideAPetLastHeartbeat"].heartbeat = os.clock()
        end
    end
end)

--================ Load WindUI ================--
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI or not WindUI then
    warn("[IndraHub] Failed to load WindUI")
    setGlobal("IndraHubRideAPetError", "WINDUI FAIL")
    return
end

--================ Configuration & State ================--
local Config = {
    Tag = "[IndraHub RideAPet]",
    Discord = "https://discord.gg/2PPBJsmqr",
    EggHover = 4, HomeHover = 3, NestHover = 5,
    TeleportSettle = 0.25, EquipSettle = 0.15,
    PickupWait = 0.6, DeliverWait = 0.6,
    ClaimBatch = 64, EggSkipFor = 30, EggStock = 40,
    DeliverBackoff = 3, SnapshotTtl = 0.2, LockWait = 6,
    EggTick = 0.1, StepTick = 0.5, HatchGap = 1.5, HatchRetry = 30,
    PlaceGap = 0.4, NestSkipFor = 30, PetSpread = 0.35, PetLift = 0.5,
    PetFailBackoff = 20, FeedGap = 1, FeedEvery = 5, ClaimGap = 30,
    UpgradeGap = 2, NestsGap = 5, RebirthGap = 5, RebirthBackoff = 60, RebirthReserve = 2,
    HuntHopAfter = 45, HuntMaxHops = 15, HopPick = 15, HopReset = 15,
    EspRange = 8000, EspRefresh = 0.5, EspLift = 4,
    RarityColors = {
        Common = Color3.fromRGB(200, 200, 200),
        Rare = Color3.fromRGB(90, 170, 255),
        Epic = Color3.fromRGB(190, 110, 255),
        Legendary = Color3.fromRGB(255, 200, 60),
        Mythic = Color3.fromRGB(255, 90, 90),
        Divine = Color3.fromRGB(120, 255, 220),
        Ethereal = Color3.fromRGB(255, 130, 230),
    },
}

local State = {
    Alive = true, Connections = {}, Status = "Idle", Lock = nil,
    EggsCollected = 0, EggSkip = {}, NestSkip = {}, Snapshot = nil,
    StockFloor = 0, SnapshotAt = 0, DeliverFailUntil = 0, PetFailUntil = 0,
    LastHatch = 0, LastHatchAll = 0, LastClaim = 0, LastUpgrade = 0,
    LastNests = 0, LastRebirth = 0, RebirthBlockedUntil = 0, LastFeed = 0,
    NextRebirthCost = math.huge, EmptySince = nil, Hopping = false,
    EspBoards = {}, Plot = nil, HuntHops = 0,
}

local Options = {
    AutoEggs = false,
    SwapSmarter = true,
    ReturnAfter = false,
    MinLuck = 0,
    EggHunter = false,
    HuntMinRarity = "Mythic",
    AutoPlaceEggs = false,
    FastestFirst = false,
    AutoHatch = false,
    AutoNests = false,
    AutoEquipBest = false,
    AutoCollectCash = false,
    AutoFeed = false,
    FoodTypes = {},
    AutoUpgrade = false,
    SaveForRebirth = false,
    AutoRebirth = false,
    AutoClaim = false,
    EggEsp = false,
    EspMinRarity = "Common",
    TPPlace = "Home (Plot)",
    AntiAfk = true,
}

local V3, CF = Vector3.new, CFrame.new
local Clock = os.clock

--================ Game Remotes & Data ================--
local function Need(parent, name)
    local c = parent and parent:WaitForChild(name, 30)
    if not c then error(Config.Tag .. " missing: " .. tostring(name)) end
    return c
end

local GameRemotes = Need(Need(ReplicatedStorage, "Remotes"), "Game")
local PlotRemotes = Need(GameRemotes, "Plot")
local Net = {
    EggPickup = Need(GameRemotes, "EggPickup"),
    EggArrivalClaim = Need(GameRemotes, "EggArrivalClaim"),
    EggPlaced = Need(GameRemotes, "EggPlaced"),
    Hatch = Need(GameRemotes, "Hatch"),
    PlacePet = Need(GameRemotes, "PlacePet"),
    PickupPet = Need(GameRemotes, "PickupPet"),
    PetCollect = Need(GameRemotes, "PetCollect"),
    FeedPet = Need(GameRemotes, "FeedPet"),
    Rebirth = Need(GameRemotes, "Rebirth"),
    Upgrades = Need(PlotRemotes, "Upgrades"),
    Nests = Need(PlotRemotes, "Nests"),
    ClaimIndexReward = Need(GameRemotes, "ClaimIndexReward"),
    OfflineEarnings = Need(GameRemotes, "OfflineEarnings"),
}

local GameData = Need(ReplicatedStorage, "GameData")
local Data = {
    Eggs = require(Need(GameData, "Eggs")),
    Pets = require(Need(GameData, "Pets")),
    Rebirths = require(Need(GameData, "Rebirths")),
    Mutations = require(Need(GameData, "Mutations")),
    Foods = require(Need(GameData, "Foods")),
    Nests = require(Need(GameData, "Nests")),
    EggBaskets = require(Need(GameData, "EggBaskets")),
}

local Info, EggNames, Rarities, RarityRank, FoodNames = {}, {}, {}, {}, {}
local function BuildLists()
    table.clear(Info) table.clear(EggNames) table.clear(Rarities)
    table.clear(RarityRank) table.clear(FoodNames)
    local lowestLuck = {}
    for name, eggInfo in pairs(Data.Eggs) do
        local rarity = eggInfo.Rarity or "Common"
        local luck = tonumber(eggInfo.Luck) or math.huge
        Info[name] = { Rarity = rarity, Luck = luck, Growth = tonumber(eggInfo.GrowthTime) or 0 }
        EggNames[#EggNames + 1] = name
        lowestLuck[rarity] = math.min(lowestLuck[rarity] or math.huge, luck)
    end
    table.sort(EggNames, function(a, b) return Info[a].Luck > Info[b].Luck end)
    for r in pairs(lowestLuck) do Rarities[#Rarities + 1] = r end
    table.sort(Rarities, function(a, b) return lowestLuck[a] < lowestLuck[b] end)
    for i, r in ipairs(Rarities) do RarityRank[r] = i end
    for name in pairs(Data.Foods) do FoodNames[#FoodNames + 1] = name end
    table.sort(FoodNames, function(a, b) return (Data.Foods[a].XP or 0) > (Data.Foods[b].XP or 0) end)
end
BuildLists()

--================ Core Helpers ================--
local function ConnectSignal(sig, fn)
    local c = sig:Connect(fn)
    table.insert(State.Connections, c)
    return c
end

local function SetStatus(text)
    State.Status = text
end

local function AcquireLock(owner, patience)
    local deadline = Clock() + (patience or 0)
    while State.Lock and State.Lock ~= owner do
        if Clock() > deadline or not State.Alive or _G.__INDRA_RIDEAPET ~= GEN then return false end
        task.wait(0.05)
    end
    State.Lock = owner
    return true
end

local function ReleaseLock(owner)
    if State.Lock == owner then State.Lock = nil end
end

local function WithLock(owner, patience, fn, ...)
    if not AcquireLock(owner, patience) then return false end
    local ok, err = pcall(fn, ...)
    ReleaseLock(owner)
    if not ok then warn(Config.Tag, owner, err) end
    return ok
end

local function Saved()
    return LP:FindFirstChild("SavedData")
end

local function Cash()
    local s = Saved()
    return s and s.Cash.Value or 0
end

local function RebirthCount()
    local s = Saved()
    return s and s.Rebirths.Value or 0
end

local function GetPlot()
    if State.Plot and State.Plot.Parent then return State.Plot end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        local d = p:FindFirstChild("Data")
        local o = d and d:FindFirstChild("Owner")
        if o and o.Value == LP then
            State.Plot = p
            return p
        end
    end
end

local function HomeCFrame()
    local p = GetPlot()
    local b = p and p:FindFirstChild("Baseplate")
    if not b then return nil end
    return b.CFrame + V3(0, b.Size.Y / 2 + Config.HomeHover, 0)
end

local PlayerTrack = { Parts = {} }
function PlayerTrack:Bind(ch)
    self.Character = ch
    self.Humanoid = ch:WaitForChild("Humanoid", 30)
    self.Root = ch:WaitForChild("HumanoidRootPart", 30)
    table.clear(self.Parts)
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then self.Parts[#self.Parts + 1] = p end
    end
    ConnectSignal(ch.DescendantAdded, function(p)
        if p:IsA("BasePart") then self.Parts[#self.Parts + 1] = p end
    end)
end

function PlayerTrack:IsAlive()
    return self.Humanoid ~= nil and self.Humanoid.Health > 0
        and self.Root ~= nil and self.Root.Parent ~= nil
end

local function MoveTo(cf)
    if not cf or not PlayerTrack:IsAlive() then return false end
    PlayerTrack.Root.AssemblyLinearVelocity = Vector3.zero
    PlayerTrack.Root.CFrame = cf
    return true
end

local function BasketCount()
    local b = LP:FindFirstChild("Basket")
    return b and #b:GetChildren() or 0
end

local function BasketCapacity()
    local s = Saved()
    local basketInfo = Data.EggBaskets[s and s.EquippedEggBasket.Value or "Wooden"]
    return math.min(type(basketInfo) == "table" and tonumber(basketInfo.Capacity) or 1, Config.ClaimBatch)
end

local function FormatNumber(n)
    if n == math.huge then return "-" end
    local suf = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }
    local i = 1
    while math.abs(n) >= 1000 and i < #suf do
        n /= 1000
        i += 1
    end
    return i == 1 and tostring(math.floor(n)) or string.format("%.2f%s", n, suf[i])
end

--================ Hatchery Logic ================--
local Hatch = {}

function Hatch.BackpackEggs()
    local tools = {}
    for _, holder in ipairs({ LP:FindFirstChild("Backpack"), PlayerTrack.Character }) do
        if not holder then continue end
        for _, t in ipairs(holder:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("EggInventoryId") then tools[#tools + 1] = t end
        end
    end
    return tools
end

function Hatch.ToolInfo(tool)
    return Info[tool.Name:match("^(.-Egg)") or ""]
end

function Hatch.MyEggs()
    local plot = GetPlot()
    local folder = plot and plot:FindFirstChild("Eggs")
    local eggs = {}
    if not folder then return eggs end
    for _, e in ipairs(folder:GetChildren()) do
        if e:GetAttribute("EggKey") and e:GetAttribute("OwnerUserId") == LP.UserId then
            eggs[#eggs + 1] = e
        end
    end
    return eggs
end

function Hatch.IsReady(egg)
    for _, l in ipairs(egg:GetDescendants()) do
        if l.Name == "Timer" and l:IsA("TextLabel") then
            local t = l.Text
            return t == "" or not t:find("%d+:%d%d") or t:match("^0?0?:?0:00$") ~= nil
        end
    end
    return true
end

function Hatch.FreeNests()
    local plot = GetPlot()
    local nests = plot and plot:FindFirstChild("Nests")
    local free = {}
    if not nests then return free end
    for _, n in ipairs(nests:GetChildren()) do
        if n:GetAttribute("Unlocked") and not n:GetAttribute("Occupied") and (State.NestSkip[n] or 0) < Clock() then
            free[#free + 1] = n
        end
    end
    return free
end

function Hatch.Place()
    local tools = Hatch.BackpackEggs()
    local nests = Hatch.FreeNests()
    if #tools == 0 or #nests == 0 then return end
    local fastest = Options.FastestFirst
    table.sort(tools, function(a, b)
        local ia, ib = Hatch.ToolInfo(a), Hatch.ToolInfo(b)
        local ra = ia and (fastest and -ia.Growth or ia.Luck) or -math.huge
        local rb = ib and (fastest and -ib.Growth or ib.Luck) or -math.huge
        return ra > rb
    end)
    local origin = PlayerTrack.Root.CFrame
    for _, nest in ipairs(nests) do
        local tool = table.remove(tools, 1)
        if not tool or not PlayerTrack:IsAlive() then break end
        SetStatus("Placing " .. tool.Name)
        MoveTo(nest:GetPivot() + V3(0, Config.NestHover, 0))
        task.wait(Config.TeleportSettle)
        PlayerTrack.Humanoid:EquipTool(tool)
        task.wait(Config.EquipSettle)
        Net.EggPlaced:FireServer({ NestId = nest.Name })
        task.wait(Config.PlaceGap)
        if not nest:GetAttribute("Occupied") then
            State.NestSkip[nest] = Clock() + Config.NestSkipFor
        end
    end
    PlayerTrack.Humanoid:UnequipTools()
    MoveTo(origin)
end

function Hatch.HatchNow(force)
    for _, e in ipairs(Hatch.MyEggs()) do
        if force or Hatch.IsReady(e) then
            Net.Hatch:FireServer({ EggKey = e:GetAttribute("EggKey") })
        end
    end
end

function Hatch.Step()
    local now = Clock()
    if Options.AutoPlaceEggs and #Hatch.FreeNests() > 0 and #Hatch.BackpackEggs() > 0 then
        WithLock("place", 0, Hatch.Place)
    end
    if Options.AutoHatch and now - State.LastHatch > Config.HatchGap then
        State.LastHatch = now
        local sweep = now - State.LastHatchAll > Config.HatchRetry
        if sweep then State.LastHatchAll = now end
        Hatch.HatchNow(sweep)
    end
end

--================ Eggs Farm Logic ================--
local Eggs = {}

function Eggs.Wanted(name)
    local eggInfo = Info[name]
    if not eggInfo then return false end
    if Options.EggHunter then
        local floorRank = RarityRank[Options.HuntMinRarity or "Mythic"] or 1
        if (RarityRank[eggInfo.Rarity] or 1) < floorRank then return false end
    end
    if Options.SwapSmarter and eggInfo.Luck <= State.StockFloor then return false end
    return eggInfo.Luck >= (Options.MinLuck or 0)
end

function Eggs.StockFloor()
    local tools = Hatch.BackpackEggs()
    if #tools < Config.EggStock then return 0 end
    local lucks = table.create(#tools)
    for i, t in ipairs(tools) do
        local toolInfo = Hatch.ToolInfo(t)
        lucks[i] = toolInfo and toolInfo.Luck or 0
    end
    table.sort(lucks, function(a, b) return a > b end)
    return lucks[Config.EggStock]
end

function Eggs.OnMap()
    local now = Clock()
    if State.Snapshot and now - State.SnapshotAt < Config.SnapshotTtl then return State.Snapshot end
    State.StockFloor = Options.SwapSmarter and Eggs.StockFloor() or 0
    local folder = ReplicatedStorage:FindFirstChild("ServerData")
    folder = folder and folder:FindFirstChild("ActiveEggs")
    local list = {}
    if folder then
        local serverNow = Workspace:GetServerTimeNow()
        for _, egg in ipairs(folder:GetChildren()) do
            local name = egg:GetAttribute("Egg")
            local priv = egg:GetAttribute("PrivateTo")
            if not name or not egg:GetAttribute("Position") then continue end
            if priv and priv ~= LP.UserId then continue end
            if (tonumber(egg:GetAttribute("DropEndsAt")) or 0) > serverNow then continue end
            if (State.EggSkip[egg.Name] or 0) > now then continue end
            if not Eggs.Wanted(name) then continue end
            list[#list + 1] = { egg, Info[name].Luck * (egg:GetAttribute("Weight") or 1) }
        end
        table.sort(list, function(a, b) return a[2] > b[2] end)
        for i, p in ipairs(list) do list[i] = p[1] end
    end
    State.Snapshot, State.SnapshotAt = list, now
    return list
end

function Eggs.Grab(egg)
    local before = BasketCount()
    MoveTo(CF(egg:GetAttribute("Position") + V3(0, Config.EggHover, 0)))
    task.wait(Config.TeleportSettle)
    Net.EggPickup:FireServer(egg.Name)
    local deadline = Clock() + Config.PickupWait
    repeat task.wait() until BasketCount() > before or Clock() > deadline
    local got = BasketCount() > before
    if not got then State.EggSkip[egg.Name] = Clock() + Config.EggSkipFor end
    return got
end

function Eggs.Deliver()
    if BasketCount() == 0 then return true end
    if not MoveTo(HomeCFrame()) then return false end
    task.wait(Config.TeleportSettle)
    local names = {}
    if LP:FindFirstChild("Basket") then
        for _, e in ipairs(LP.Basket:GetChildren()) do
            names[#names + 1] = e.Name
            if #names >= Config.ClaimBatch then break end
        end
    end
    Net.EggArrivalClaim:FireServer(Workspace:GetServerTimeNow(), PlayerTrack.Root.Position, names)
    local deadline = Clock() + Config.DeliverWait
    repeat task.wait() until BasketCount() == 0 or Clock() > deadline
    return BasketCount() == 0
end

function Eggs.Run()
    local origin = PlayerTrack.Root.CFrame
    local cap = BasketCapacity()
    local got = 0
    for _, egg in ipairs(Eggs.OnMap()) do
        if not State.Alive or not PlayerTrack:IsAlive() or _G.__INDRA_RIDEAPET ~= GEN then break end
        if not egg.Parent then continue end
        SetStatus("Collecting " .. tostring(egg:GetAttribute("Egg")))
        if Eggs.Grab(egg) then got += 1 end
        if BasketCount() >= cap and not Eggs.Deliver() then
            State.DeliverFailUntil = Clock() + Config.DeliverBackoff
            SetStatus("Delivery rejected, backing off")
            break
        end
    end
    if BasketCount() > 0 and not Eggs.Deliver() then
        State.DeliverFailUntil = Clock() + Config.DeliverBackoff
    end
    State.Snapshot = nil
    State.EggsCollected += got
    if Options.ReturnAfter and got > 0 then MoveTo(origin) end
    if Clock() > State.DeliverFailUntil then
        SetStatus(got > 0 and ("Collected " .. got .. " eggs") or "Waiting for eggs")
    end
    return got
end

-- Server hopping for Egg Radar
local ServerHop = {}
function ServerHop.Hop()
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
    local open = {}
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok then
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(body) end)
        for _, s in ipairs(ok2 and decoded and decoded.data or {}) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then open[#open + 1] = s.id end
        end
    end
    if #open > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, open[math.random(1, math.min(#open, Config.HopPick))], LP)
        return
    end
    TeleportService:Teleport(game.PlaceId, LP)
end

function ServerHop.RadarHop()
    State.Hopping = true
    local hops = State.HuntHops + 1
    if hops > Config.HuntMaxHops then
        State.HuntHops = 0
        Options.EggHunter = false
        WindUI:Notify({ Title = "Egg Radar", Content = string.format("No match after %d servers. Radar paused.", Config.HuntMaxHops), Duration = 6 })
        return
    end
    local queue = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    if queue and Options.EggHunter then
        queue(string.format("getgenv().IndraHubHunt = { Hops = %d, Rarity = %q }\nloadstring(game:HttpGet('https://raw.githubusercontent.com/IndraT99/RobloxScript/refs/heads/main/rideapet.lua'))()", hops, Options.HuntMinRarity or "Mythic"))
    end
    task.delay(Config.HopReset, function()
        State.Hopping = false
        State.EmptySince = Clock()
    end)
    pcall(ServerHop.Hop)
end

function Eggs.Step()
    if not Options.AutoEggs and not Options.EggHunter then return end
    if Clock() < State.DeliverFailUntil then return end
    if #Eggs.OnMap() > 0 then
        State.EmptySince = nil
        WithLock("eggs", 0, Eggs.Run)
        return
    end
    State.EmptySince = State.EmptySince or Clock()
    if not Options.EggHunter then
        SetStatus("Waiting for eggs")
        return
    end
    local left = Config.HuntHopAfter - (Clock() - State.EmptySince)
    SetStatus(string.format("Egg Radar: empty, hopping in %ds", math.max(0, math.ceil(left))))
    if left <= 0 and not State.Hopping then ServerHop.RadarHop() end
end

--================ Ranch / Pets Logic ================--
local Ranch = {}

function Ranch.Score(inst)
    local petInfo = Data.Pets[inst:GetAttribute("PetName") or ""]
    local income = type(petInfo) == "table" and tonumber(petInfo.Income) or 0
    local mult = 1
    for _, attr in ipairs({ "Mutation", "SpawnMutation" }) do
        local m = Data.Mutations[inst:GetAttribute(attr) or ""]
        if type(m) == "table" then mult *= 1 + (tonumber(m.StatMultiplier) or 0) / 100 end
    end
    return income * (inst:GetAttribute("Weight") or 1) * mult
end

function Ranch.Ranked(list, asc)
    local ranked = table.create(#list)
    for i, inst in ipairs(list) do ranked[i] = { inst, Ranch.Score(inst) } end
    table.sort(ranked, function(a, b) return asc and a[2] < b[2] or a[2] > b[2] end)
    return ranked
end

function Ranch.Placed()
    local plot = GetPlot()
    local folder = plot and plot:FindFirstChild("Pets")
    local list = {}
    if not folder then return list end
    for _, p in ipairs(folder:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LP.UserId and p:GetAttribute("PetKey") then list[#list + 1] = p end
    end
    return list
end

function Ranch.Owned()
    local list = {}
    for _, holder in ipairs({ LP:FindFirstChild("Backpack"), PlayerTrack.Character }) do
        if not holder then continue end
        for _, t in ipairs(holder:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("PetKey") then list[#list + 1] = t end
        end
    end
    return list
end

function Ranch.MaxSlots()
    local s = Saved()
    return tonumber(s and s.MaxPets.Value) or Data.Rebirths.BasePetCapacity or 5
end

function Ranch.RandomSpot()
    local plot = GetPlot()
    local b = plot and plot:FindFirstChild("Baseplate")
    if not b then return nil end
    local half = b.Size * Config.PetSpread
    local off = V3((math.random() * 2 - 1) * half.X, b.Size.Y / 2 + Config.PetLift, (math.random() * 2 - 1) * half.Z)
    return (b.CFrame * CF(off)).Position
end

function Ranch.PlaceBest()
    if Clock() < State.PetFailUntil then return false end
    local placed = Ranch.Ranked(Ranch.Placed(), true)
    local owned = Ranch.Ranked(Ranch.Owned(), false)
    local free = Ranch.MaxSlots() - #placed
    local before = #placed
    local acted = false
    for _, pair in ipairs(owned) do
        local tool, score = pair[1], pair[2]
        local spot = Ranch.RandomSpot()
        if not spot then return false end
        if free > 0 then
            Net.PlacePet:FireServer(tool:GetAttribute("PetKey"), spot)
            free -= 1
            acted = true
            task.wait(Config.PlaceGap)
            continue
        end
        local worst = placed[1]
        if not worst or score <= worst[2] then break end
        table.remove(placed, 1)
        Net.PickupPet:FireServer(worst[1]:GetAttribute("PetKey"))
        task.wait(Config.PlaceGap)
        Net.PlacePet:FireServer(tool:GetAttribute("PetKey"), spot)
        acted = true
        task.wait(Config.PlaceGap)
    end
    if acted and #Ranch.Placed() < math.min(before + 1, Ranch.MaxSlots()) and before < Ranch.MaxSlots() then
        State.PetFailUntil = Clock() + Config.PetFailBackoff
    end
    return acted
end

function Ranch.CollectNow()
    for _, p in ipairs(Ranch.Placed()) do
        Net.PetCollect:FireServer(p:GetAttribute("PetKey"))
    end
end

function Ranch.FoodTool()
    local allowed = Options.FoodTypes
    local bp = LP:FindFirstChild("Backpack")
    for _, name in ipairs(FoodNames) do
        if allowed and next(allowed) and not allowed[name] then continue end
        local t = (bp and bp:FindFirstChild(name)) or (PlayerTrack.Character and PlayerTrack.Character:FindFirstChild(name))
        if t then return t end
    end
end

function Ranch.Feed()
    for _, pair in ipairs(Ranch.Ranked(Ranch.Placed(), false)) do
        local food = Ranch.FoodTool()
        if not food or not PlayerTrack:IsAlive() then break end
        PlayerTrack.Humanoid:EquipTool(food)
        task.wait(Config.EquipSettle)
        Net.FeedPet:FireServer(pair[1]:GetAttribute("PetKey"), food.Name, true)
        task.wait(Config.FeedGap)
    end
    if PlayerTrack.Humanoid then PlayerTrack.Humanoid:UnequipTools() end
end

function Ranch.Step()
    local now = Clock()
    if Options.AutoEquipBest then WithLock("ranch", 0, Ranch.PlaceBest) end
    if Options.AutoCollectCash then Ranch.CollectNow() end
    if Options.AutoFeed and now - State.LastFeed > Config.FeedGap * Config.FeedEvery then
        State.LastFeed = now
        WithLock("feed", 0, Ranch.Feed)
    end
end

--================ Progress / Rebirth Logic ================--
local Progress = {}

function Progress.RebirthCost()
    local lib = Data.Rebirths
    local nextRebirth = RebirthCount() + 1
    if nextRebirth > (lib.Cap or math.huge) then return math.huge end
    if lib.RiggedCost and lib.RiggedCost[nextRebirth] then return lib.RiggedCost[nextRebirth] end
    local ok, cost = pcall(lib.GetCost, RebirthCount())
    return ok and tonumber(cost) or math.huge
end

function Progress.RebirthNow()
    if RebirthCount() >= (Data.Rebirths.Cap or math.huge) then return end
    local before = RebirthCount()
    Net.Rebirth:FireServer()
    task.delay(3, function()
        if RebirthCount() == before then
            State.RebirthBlockedUntil = Clock() + Config.RebirthBackoff
            SetStatus("Rebirth pending requirements")
        end
    end)
end

function Progress.Step()
    local now = Clock()
    State.NextRebirthCost = Progress.RebirthCost()
    if Options.AutoRebirth and now - State.LastRebirth > Config.RebirthGap
        and now > State.RebirthBlockedUntil and Cash() >= State.NextRebirthCost then
        State.LastRebirth = now
        Progress.RebirthNow()
    end
    if Options.AutoNests and now - State.LastNests > Config.NestsGap then
        State.LastNests = now
        local plot = GetPlot()
        local nests = plot and plot:FindFirstChild("Nests")
        if nests then
            local prices = Data.Nests.Prices or {}
            for _, n in ipairs(nests:GetChildren()) do
                local idx = tonumber(n.Name)
                if n:GetAttribute("Unlocked") or not idx then continue end
                if Cash() < (prices[idx] or math.huge) then continue end
                Net.Nests:FireServer(idx)
                task.wait(Config.PlaceGap)
            end
        end
    end
    if Options.AutoUpgrade and now - State.LastUpgrade > Config.UpgradeGap then
        local saving = Options.SaveForRebirth and State.NextRebirthCost < math.huge
            and Cash() < State.NextRebirthCost * Config.RebirthReserve
        if not saving then
            State.LastUpgrade = now
            Net.Upgrades:FireServer("Max")
        end
    end
    if Options.AutoClaim and now - State.LastClaim > Config.ClaimGap then
        State.LastClaim = now
        Net.ClaimIndexReward:FireServer()
        Net.OfflineEarnings:FireServer()
    end
end

--================ Teleports & Places ================--
local Places = {}
function Places.List()
    local places = { ["Home (Plot)"] = function() return HomeCFrame() end }
    local stalls = Workspace:FindFirstChild("Stalls")
    for _, s in ipairs(stalls and stalls:GetChildren() or {}) do
        places["Shop: " .. s.Name] = function() return s:GetPivot() + V3(0, Config.HomeHover, 0) end
    end
    local volcano = Workspace:FindFirstChild("Volcano")
    for _, spot in ipairs({ "VolcanoEntrance", "VolcanoTop" }) do
        local part = volcano and volcano:FindFirstChild(spot)
        if part then places["Volcano: " .. spot:sub(8)] = function() return part.CFrame + V3(0, Config.NestHover, 0) end end
    end
    return places
end

function Places.Names()
    local n = {}
    for name in pairs(Places.List()) do n[#n + 1] = name end
    table.sort(n)
    return n
end

--================ Egg ESP ================--
local Esp = {}
function Esp.Clear()
    for k, e in pairs(State.EspBoards) do
        if e.Board and e.Board.Parent then e.Board:Destroy() end
        State.EspBoards[k] = nil
    end
end

function Esp.Refresh()
    if not Options.EggEsp then
        if next(State.EspBoards) then Esp.Clear() end
        return
    end
    local rendered = Workspace:FindFirstChild("RenderedEggs")
    if not rendered then return end
    local root = PlayerTrack.Root
    local minRank = RarityRank[Options.EspMinRarity or "Common"] or 1
    local seen = {}
    for _, model in ipairs(rendered:GetChildren()) do
        local eggInfo = Info[model.Name]
        if not eggInfo or (RarityRank[eggInfo.Rarity] or 1) < minRank then continue end
        local entry = State.EspBoards[model]
        if not entry or not entry.Board.Parent then
            local part = model:IsA("BasePart") and model or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            if not part then continue end
            local board = Instance.new("BillboardGui")
            board.Name = "IndraHub_EggEsp"
            board.AlwaysOnTop = true
            board.Size = UDim2.fromOffset(200, 40)
            board.StudsOffset = V3(0, Config.EspLift, 0)
            board.MaxDistance = Config.EspRange
            board.Adornee = part
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextStrokeTransparency = 0.2
            label.TextColor3 = Config.RarityColors[eggInfo.Rarity] or Color3.new(1, 1, 1)
            label.Parent = board
            board.Parent = (gethui and gethui()) or CoreGui
            entry = { Board = board, Label = label, Part = part }
            State.EspBoards[model] = entry
        end
        seen[model] = true
        local dist = root and math.floor((entry.Part.Position - root.Position).Magnitude) or 0
        entry.Label.Text = string.format("%s [%s]\n1 in %s | %dm", model.Name, eggInfo.Rarity, FormatNumber(eggInfo.Luck), dist)
    end
    for k, e in pairs(State.EspBoards) do
        if not seen[k] then
            if e.Board and e.Board.Parent then e.Board:Destroy() end
            State.EspBoards[k] = nil
        end
    end
end

--================ Anti-AFK ================--
if LP then
    ConnectSignal(LP.Idled, function()
        if Options.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end
    end)
end

--================ WindUI Window Creation ================--
local Window = WindUI:CreateWindow({
    Title = "IndraHub | Ride A Pet",
    Icon = "paw-print",
    Author = "IndraHub",
    Folder = "IndraHub_RideAPet",
    Size = UDim2.fromOffset(590, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true
})

local Tabs = {
    Farm        = Window:Tab({ Title = "Eggs Farm", Icon = "egg" }),
    Nests       = Window:Tab({ Title = "Hatchery", Icon = "clock" }),
    Ranch       = Window:Tab({ Title = "Pet Ranch", Icon = "sparkles" }),
    Progress    = Window:Tab({ Title = "Progression", Icon = "trending-up" }),
    Visuals     = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Teleports   = Window:Tab({ Title = "Teleports", Icon = "map-pin" }),
    Status      = Window:Tab({ Title = "Overview", Icon = "activity" }),
}

-- FARM TAB
Tabs.Farm:Section({ Title = "AUTOMATIC COLLECTION" })
Tabs.Farm:Toggle({
    Title = "Auto Collect Eggs",
    Desc = "Teleports to wanted eggs, grabs them, and deposits at base",
    Default = Options.AutoEggs,
    Callback = function(v) Options.AutoEggs = v end
})

Tabs.Farm:Toggle({
    Title = "Swap Smarter",
    Desc = "When backpack is full, only collect eggs better than current stock",
    Default = Options.SwapSmarter,
    Callback = function(v) Options.SwapSmarter = v end
})

Tabs.Farm:Toggle({
    Title = "Return To Spot",
    Desc = "Return to previous coordinates after delivery run completes",
    Default = Options.ReturnAfter,
    Callback = function(v) Options.ReturnAfter = v end
})

Tabs.Farm:Slider({
    Title = "Min Egg Luck (1 in X)",
    Min = 0,
    Max = 1000000,
    Default = Options.MinLuck,
    Callback = function(v) Options.MinLuck = v end
})

Tabs.Farm:Button({
    Title = "Grab Best Egg Now",
    Desc = "Teleport directly to highest luck egg currently spawned",
    Callback = function()
        local best = Eggs.OnMap()[1]
        if best then MoveTo(CF(best:GetAttribute("Position") + V3(0, Config.EggHover, 0))) end
    end
})

Tabs.Farm:Section({ Title = "EGG RADAR (SERVER HOP)" })
Tabs.Farm:Toggle({
    Title = "Egg Radar Server Hop",
    Desc = "Automatically switch servers when desired rare eggs are exhausted",
    Default = Options.EggHunter,
    Callback = function(v) Options.EggHunter = v end
})

Tabs.Farm:Dropdown({
    Title = "Radar Target Min Rarity",
    Values = Rarities,
    Value = Options.HuntMinRarity,
    Callback = function(v) Options.HuntMinRarity = v end
})

-- NESTS TAB
Tabs.Nests:Section({ Title = "EGG PLACEMENT & HATCHING" })
Tabs.Nests:Toggle({
    Title = "Auto Place Eggs",
    Desc = "Automatically insert best eggs into available nests",
    Default = Options.AutoPlaceEggs,
    Callback = function(v) Options.AutoPlaceEggs = v end
})

Tabs.Nests:Toggle({
    Title = "Fastest Growth First",
    Desc = "Prioritize shortest growth time eggs instead of highest luck",
    Default = Options.FastestFirst,
    Callback = function(v) Options.FastestFirst = v end
})

Tabs.Nests:Toggle({
    Title = "Auto Hatch Ready Eggs",
    Desc = "Remotely hatch eggs when ready without standing at nest",
    Default = Options.AutoHatch,
    Callback = function(v) Options.AutoHatch = v end
})

Tabs.Nests:Button({
    Title = "Place Eggs Now",
    Desc = "Immediately fill empty nests from backpack",
    Callback = function() WithLock("place", Config.LockWait, Hatch.Place) end
})

Tabs.Nests:Button({
    Title = "Hatch All Ready",
    Desc = "Trigger hatch on every ready egg on plot",
    Callback = function() Hatch.HatchNow(true) end
})

Tabs.Nests:Section({ Title = "NEST CAPACITY UPGRADES" })
Tabs.Nests:Toggle({
    Title = "Auto Unlock Nests",
    Desc = "Purchase new nest slots as soon as wallet balance allows",
    Default = Options.AutoNests,
    Callback = function(v) Options.AutoNests = v end
})

-- RANCH TAB
Tabs.Ranch:Section({ Title = "PET DEPLOYMENT & EARNINGS" })
Tabs.Ranch:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Keep ranch loaded with highest income and mutated earners",
    Default = Options.AutoEquipBest,
    Callback = function(v) Options.AutoEquipBest = v end
})

Tabs.Ranch:Toggle({
    Title = "Auto Collect Pet Coins",
    Desc = "Continuously collect generated income from placed pets",
    Default = Options.AutoCollectCash,
    Callback = function(v) Options.AutoCollectCash = v end
})

Tabs.Ranch:Button({
    Title = "Place Best Pets Now",
    Desc = "Recalculate and swap highest score pets into ranch slots",
    Callback = function() WithLock("ranch", Config.LockWait, Ranch.PlaceBest) end
})

Tabs.Ranch:Button({
    Title = "Collect Cash Now",
    Desc = "Trigger one-shot money sweep across all active pets",
    Callback = function() Ranch.CollectNow() end
})

Tabs.Ranch:Section({ Title = "FEEDING" })
Tabs.Ranch:Toggle({
    Title = "Auto Feed Ranch Pets",
    Desc = "Feed top pets using available food tools from inventory",
    Default = Options.AutoFeed,
    Callback = function(v) Options.AutoFeed = v end
})

-- PROGRESSION TAB
Tabs.Progress:Section({ Title = "PLOT UPGRADES" })
Tabs.Progress:Toggle({
    Title = "Auto Buy Plot Upgrades",
    Desc = "Purchase Max affordable base luck and multiplier upgrades",
    Default = Options.AutoUpgrade,
    Callback = function(v) Options.AutoUpgrade = v end
})

Tabs.Progress:Toggle({
    Title = "Save Cash For Rebirth",
    Desc = "Pause upgrades when approaching the next rebirth cost",
    Default = Options.SaveForRebirth,
    Callback = function(v) Options.SaveForRebirth = v end
})

Tabs.Progress:Button({
    Title = "Upgrade Max Now",
    Desc = "Fire one-shot Max plot upgrade request",
    Callback = function() Net.Upgrades:FireServer("Max") end
})

Tabs.Progress:Section({ Title = "REBIRTH & REWARDS" })
Tabs.Progress:Toggle({
    Title = "Auto Rebirth",
    Desc = "Trigger rebirth automatically when requirements are fulfilled",
    Default = Options.AutoRebirth,
    Callback = function(v) Options.AutoRebirth = v end
})

Tabs.Progress:Button({
    Title = "Rebirth Now",
    Desc = "Execute rebirth immediately",
    Callback = function() Progress.RebirthNow() end
})

Tabs.Progress:Toggle({
    Title = "Auto Claim Rewards",
    Desc = "Collect Index completion bonus and offline earnings periodically",
    Default = Options.AutoClaim,
    Callback = function(v) Options.AutoClaim = v end
})

Tabs.Progress:Button({
    Title = "Claim Rewards Now",
    Desc = "Claim index rewards and offline cash right now",
    Callback = function()
        Net.ClaimIndexReward:FireServer()
        Net.OfflineEarnings:FireServer()
    end
})

-- VISUALS TAB
Tabs.Visuals:Section({ Title = "EGG ESP OVERLAY" })
Tabs.Visuals:Toggle({
    Title = "Enable Egg ESP",
    Desc = "Render floating labels with rarity, luck, and distance over eggs",
    Default = Options.EggEsp,
    Callback = function(v) Options.EggEsp = v end
})

Tabs.Visuals:Dropdown({
    Title = "Min ESP Rarity",
    Values = Rarities,
    Value = Options.EspMinRarity,
    Callback = function(v) Options.EspMinRarity = v end
})

-- TELEPORTS TAB
Tabs.Teleports:Section({ Title = "FAST TRAVEL" })
local placeNames = Places.Names()
Tabs.Teleports:Dropdown({
    Title = "Destination Point",
    Values = placeNames,
    Value = placeNames[1] or "Home (Plot)",
    Callback = function(v) Options.TPPlace = v end
})

Tabs.Teleports:Button({
    Title = "Teleport To Selected",
    Desc = "Instantly move to the chosen location",
    Callback = function()
        local list = Places.List()
        local fn = list[Options.TPPlace or ""]
        if fn then MoveTo(fn()) end
    end
})

-- OVERVIEW & STATUS TAB
Tabs.Status:Section({ Title = "LIVE STATISTICS" })
local StatusParagraph = Tabs.Status:Paragraph({
    Title = "System Status",
    Desc = "Initializing IndraHub..."
})

Tabs.Status:Section({ Title = "UTILITY & CONTROLS" })
Tabs.Status:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Simulate virtual user input when idle to prevent disconnects",
    Default = Options.AntiAfk,
    Callback = function(v) Options.AntiAfk = v end
})

Tabs.Status:Button({
    Title = "PANIC - Stop Everything",
    Desc = "Disables all automation toggles immediately",
    Callback = function()
        Options.AutoEggs = false
        Options.SwapSmarter = false
        Options.AutoPlaceEggs = false
        Options.AutoHatch = false
        Options.AutoEquipBest = false
        Options.AutoCollectCash = false
        Options.AutoFeed = false
        Options.AutoUpgrade = false
        Options.AutoRebirth = false
        Options.AutoNests = false
        Options.AutoClaim = false
        Options.EggHunter = false
        Options.EggEsp = false
        Esp.Clear()
        SetStatus("Emergency Stop Activated")
        WindUI:Notify({ Title = "Panic", Content = "All automation toggles turned off.", Duration = 4 })
    end
})

Tabs.Status:Button({
    Title = "Copy Discord Link",
    Desc = "Copy IndraHub community invite to clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(Config.Discord)
        elseif toclipboard then
            toclipboard(Config.Discord)
        end
        WindUI:Notify({ Title = "Discord", Content = "Invite copied to clipboard!", Duration = 4 })
    end
})

--================ Main Run Loops ================--
if LP.Character then PlayerTrack:Bind(LP.Character) end
ConnectSignal(LP.CharacterAdded, function(ch) PlayerTrack:Bind(ch) end)

task.spawn(function()
    while _G.__INDRA_RIDEAPET == GEN and State.Alive do
        pcall(Eggs.Step)
        task.wait(Config.EggTick)
    end
end)

task.spawn(function()
    while _G.__INDRA_RIDEAPET == GEN and State.Alive do
        pcall(Hatch.Step)
        pcall(Ranch.Step)
        pcall(Progress.Step)
        task.wait(Config.StepTick)
    end
end)

task.spawn(function()
    while _G.__INDRA_RIDEAPET == GEN and State.Alive do
        pcall(Esp.Refresh)
        task.wait(Config.EspRefresh)
    end
end)

task.spawn(function()
    while _G.__INDRA_RIDEAPET == GEN and State.Alive do
        local onMapCount = #Eggs.OnMap()
        local bestEgg = Eggs.OnMap()[1]
        local bestName = bestEgg and tostring(bestEgg:GetAttribute("Egg")) or "None"
        local rebCost = State.NextRebirthCost < math.huge and FormatNumber(State.NextRebirthCost) or "Max"
        local text = string.format(
            "State: %s\n" ..
            "Cash: $%s | Rebirths: %d (Next: $%s)\n" ..
            "Eggs Collected: %d | On Map: %d (Best: %s)\n" ..
            "Backpack Capacity: %d/%d\n" ..
            "Placed Pets: %d/%d | Free Nests: %d\n" ..
            "Egg Radar Hops: %d/%d",
            State.Status,
            FormatNumber(Cash()),
            RebirthCount(),
            rebCost,
            State.EggsCollected,
            onMapCount,
            bestName,
            BasketCount(),
            BasketCapacity(),
            #Ranch.Placed(),
            Ranch.MaxSlots(),
            #Hatch.FreeNests(),
            State.HuntHops,
            Config.HuntMaxHops
        )
        pcall(function()
            if StatusParagraph.SetDesc then
                StatusParagraph:SetDesc(text)
            elseif StatusParagraph.Set then
                StatusParagraph:Set({ Title = "System Status", Desc = text })
            end
        end)
        task.wait(1)
    end
end)

-- Unload handler
getgenv().IndraHubRideAPetUnload = function()
    State.Alive = false
    setGlobal("IndraHubRideAPetRunning", false)
    Esp.Clear()
    for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(State.Connections)
    pcall(function() Window:Destroy() end)
    WindUI:Notify({ Title = "IndraHub", Content = "Ride A Pet script unloaded.", Duration = 4 })
end

-- Resume radar if teleported with Hunt params
local hunt = getgenv().IndraHubHunt
getgenv().IndraHubHunt = nil
if type(hunt) == "table" then
    State.HuntHops = tonumber(hunt.Hops) or 0
    Options.HuntMinRarity = hunt.Rarity or "Mythic"
    Options.EggHunter = true
    Options.AutoPlaceEggs = true
    Options.AutoHatch = true
    WindUI:Notify({ Title = "Egg Radar", Content = string.format("Radar resumed. Server %d/%d.", State.HuntHops, Config.HuntMaxHops), Duration = 5 })
end

WindUI:Notify({ Title = "IndraHub", Content = "Ride A Pet module loaded successfully!", Duration = 5 })
return { State = State, Options = Options, Config = Config }
