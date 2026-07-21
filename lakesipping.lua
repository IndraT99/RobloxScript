

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local BASE_URL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local DISCORD_INVITE = "https://discord.gg/2PPBJsmqr"

local function LoadWindUI()
    local windui = nil
    pcall(function()
        windui = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
    end)
    return windui
end
local WindUI = LoadWindUI()
if not WindUI then return end

local Toggles = {}
local Options = {}

local Flamework = require(
    ReplicatedStorage:WaitForChild("rbxts_include")
        .node_modules["@flamework"]
        .core.out
).Flamework


local IH_SipCtrl = Flamework.resolveDependency("NA")
local IH_InvCtrl = Flamework.resolveDependency("yv")
local IH_SellCtrl = Flamework.resolveDependency("ABp")
local IH_CharCtrl = Flamework.resolveDependency("O0")
local IH_SipFx = Flamework.resolveDependency("lmg")
local IH_LakeChest = Flamework.resolveDependency("jo")
local IH_MapChest = Flamework.resolveDependency("BL7")
local IH_SellerCtrl = Flamework.resolveDependency("5Nj")
local IH_AlbumCtrl = Flamework.resolveDependency("4vJ")
local IH_LakeReg = Flamework.resolveDependency("We")
local IH_ZoneCtrl = Flamework.resolveDependency("EK")
local IH_Components = Flamework.resolveDependency("$c:components@IH_Components")

local Toggles = Library.Toggles
local Options = Library.Options

local PERFECT_LUCK = 2
local LAKE_REUSE_DISTANCE = 8
local originalGetCurrentLuck = IH_SipCtrl.getCurrentLuck

local bodyVelocity
local bodyGyro
local connections = {}
local lastInputClock = tick()
local lastVirtualClickClock = tick()

local function IH_GetRoot()
    return IH_CharCtrl:getPrimaryPart()
end

local function IH_GetHum()
    return IH_CharCtrl:IH_GetHum()
end

local function IH_SafeCall(callback)
    local ok, result = pcall(callback)
    return ok, result
end

local function IH_PerformSell()
    IH_SafeCall(function()
        IH_SellCtrl.net:call("sellAll"):await()
    end)
end

local function IH_StopFly()
    local humanoid = IH_GetHum()
    if humanoid then
        humanoid.PlatformStand = false
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

local function IH_UpdateFly()
    if not Toggles.Fly.Value then
        IH_StopFly()
        return
    end

    local rootPart = IH_GetRoot()
    local humanoid = IH_GetHum()
    local camera = workspace.CurrentCamera
    if not rootPart or not humanoid or not camera then
        IH_StopFly()
        return
    end

    if not bodyVelocity or bodyVelocity.Parent ~= rootPart then
        IH_StopFly()

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 9000
        bodyGyro.Parent = rootPart
    end

    humanoid.PlatformStand = true

    local direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction += camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction -= camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction += camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction -= camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction += Vector3.yAxis
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        direction -= Vector3.yAxis
    end

    bodyVelocity.Velocity = if direction.Magnitude > 0
        then direction.Unit * Options.FlySpeed.Value
        else Vector3.zero
    bodyGyro.CFrame = camera.CFrame
end

local function IH_UpdateWalkSpeed()
    if not Toggles.WalkSpeedEnabled.Value then
        return
    end

    local humanoid = IH_GetHum()
    if humanoid and humanoid.WalkSpeed ~= Options.WalkSpeed.Value then
        humanoid.WalkSpeed = Options.WalkSpeed.Value
    end
end

local function IH_UpdateNoClip()
    if not Toggles.NoClip.Value then
        return
    end

    local character = LocalPlayer.Character
    if not character then
        return
    end

    for _, descendant in character:GetDescendants() do
        if descendant:IsA("BasePart") and descendant.CanCollide then
            descendant.CanCollide = false
        end
    end
end

local function IH_OnInfJump()
    if not Toggles.InfiniteJump.Value then
        return
    end

    local humanoid = IH_GetHum()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function IH_OnWsToggle(enabled)
    local humanoid = IH_GetHum()
    if not humanoid then
        return
    end

    humanoid.WalkSpeed = if enabled then Options.WalkSpeed.Value else 16
end

local function IH_OnWsChanged(value)
    if not Toggles.WalkSpeedEnabled.Value then
        return
    end

    local humanoid = IH_GetHum()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end

local function IH_OnPerfCharge(enabled)
    IH_SipCtrl.getCurrentLuck = if enabled
        then function()
            return PERFECT_LUCK
        end
        else originalGetCurrentLuck
end

local function IH_OnAutoSip(enabled)
    IH_SipCtrl:setAutoContext(enabled)
    if not enabled then
        IH_SipFx:setActive(false)
    end
end

local function IH_InstCatch()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    lastVirtualClickClock = tick()
end



local areaNames = {}
local areaFilters = {}
local orderedZones = {}

for _, zone in IH_ZoneCtrl:getAllZones() do
    table.insert(orderedZones, zone)
end

table.sort(orderedZones, function(left, right)
    return left.order < right.order
end)

for _, zone in orderedZones do
    if zone.name == "spawn" then
        areaFilters["Newbie Park"] = {
            zone = zone.name,
            prefix = "lakeNewbie",
        }
        areaFilters["Big Cosy Meadow"] = {
            zone = zone.name,
            prefix = "cosyMeadowLake",
        }
        table.insert(areaNames, "Newbie Park")
        table.insert(areaNames, "Big Cosy Meadow")
    else
        areaFilters[zone.displayName] = { zone = zone.name }
        table.insert(areaNames, zone.displayName)
    end
end

local function selectedAreaFilters()
    local selected = Options.Areas.Value
    local filters = {}

    for areaName, enabled in selected do
        if enabled and areaFilters[areaName] then
            table.insert(filters, areaFilters[areaName])
        end
    end

    return filters
end

local function lakeMatchesFilters(lake, filters)
    local lakeName = lake.attributes.lakeName
    if lakeName == nil or not IH_LakeReg:exists(lakeName) then
        return false
    end

    if filters == nil then
        return true
    end

    local zoneName = IH_LakeReg:getByName(lakeName).zone.name
    for _, filter in filters do
        local prefixMatches = filter.prefix == nil
            or lakeName:sub(1, #filter.prefix) == filter.prefix
        if filter.zone == zoneName and prefixMatches then
            return true
        end
    end

    return false
end

local function IH_FindLake()
    local rootPart = IH_GetRoot()
    if not rootPart then
        return nil
    end

    local filters = selectedAreaFilters()
    local closestLake
    local closestDistance = math.huge

    for _, lake in IH_Components:getAllComponents("Q2") do
        local primaryPart = lake.instance.PrimaryPart
        if primaryPart and not lake:isEmpty() and lakeMatchesFilters(lake, filters) then
            local distance = lake:getDistanceToPrimary(rootPart.Position)
            if distance and distance < closestDistance then
                closestLake = lake
                closestDistance = distance
            end
        end
    end

    return closestLake, closestDistance
end

local function IH_FindStand(lake)
    local water = lake.instance.Water
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { LocalPlayer.Character, water }

    local radius = math.max(water.Size.X, water.Size.Z) / 2
    for angle = 0, 315, 45 do
        local direction = CFrame.Angles(0, math.rad(angle), 0).LookVector
        for _, offset in { 3, 6, 9 } do
            local origin = water.Position + direction * (radius + offset) + Vector3.new(0, 50, 0)
            local hit = workspace:Raycast(origin, Vector3.new(0, -150, 0), raycastParams)
            if hit then
                local position = hit.Position + Vector3.new(0, 3, 0)
                if lake:getDistanceToPrimary(position) <= LAKE_REUSE_DISTANCE then
                    return CFrame.lookAt(
                        position,
                        Vector3.new(water.Position.X, position.Y, water.Position.Z)
                    )
                end
            end
        end
    end

    return nil
end

local function IH_EnsureLake()
    local lake, distance = IH_FindLake()
    if not lake then
        return false
    end

    if distance <= LAKE_REUSE_DISTANCE then
        return true
    end

    local target = IH_FindStand(lake)
    local rootPart = IH_GetRoot()
    if not target or not rootPart then
        return false
    end

    rootPart.CFrame = target
    task.wait(0.3)

    rootPart = IH_GetRoot()
    if rootPart then
        rootPart.CFrame = target
    end
    task.wait(0.2)
    return true
end



local function chestMatchesPosition(chest, positions)
    for _, position in positions do
        if (chest.cFrame.Position - position).Magnitude <= 1 then
            return true
        end
    end
    return false
end

local function getMapChestPositions()
    local positions = {}
    for _, component in IH_Components:getAllComponents("Q2") do
        local chestRef = component.instance:FindFirstChild("ChestRef")
        if chestRef then
            table.insert(
                positions,
                chestRef.Position - Vector3.new(0, chestRef.Size.Y / 2, 0)
            )
        end
    end
    return positions
end

local function IH_GetLakeChests()
    local positions = getMapChestPositions()
    local chests = {}

    for id, chest in IH_LakeChest:getChests() do
        if not IH_LakeChest:isOpened(id) and chestMatchesPosition(chest, positions) then
            table.insert(chests, {
                id = id,
                chest = chest,
            })
        end
    end

    return chests
end

local function IH_CollectLakeChests()
    if not Toggles.AutoLakeChest.Value then
        return
    end

    local chests = IH_GetLakeChests()
    if #chests == 0 then
        return
    end

    local rootPart = IH_GetRoot()
    if not rootPart then
        return
    end

    local returnCFrame = rootPart.CFrame
    for _, entry in chests do
        rootPart = IH_GetRoot()
        if not rootPart then
            return
        end

        local target = entry.chest.cFrame + Vector3.new(0, 3, 0)
        for _ = 1, 3 do
            rootPart.CFrame = target
            task.wait(0.6)

            local opened = false
            IH_SafeCall(function()
                opened = IH_LakeChest:open(entry.id):await()
            end)
            if opened then
                break
            end
        end
        task.wait(0.3)
    end

    rootPart = IH_GetRoot()
    if rootPart and not Toggles.AutoSwapLake.Value then
        rootPart.CFrame = returnCFrame
    end
end

local function IH_CollectMapChests()
    if not Toggles.AutoMapChest.Value then
        return
    end

    local rootPart = IH_GetRoot()
    if not rootPart then
        return
    end

    local returnCFrame = rootPart.CFrame
    local moved = false

    for _, chest in IH_Components:getAllComponents("gme") do
        local worldChestName = chest.attributes.worldChestName
        if worldChestName and not IH_MapChest:hasOpened(worldChestName) then
            for _ = 1, 3 do
                rootPart = IH_GetRoot()
                if not rootPart then
                    return
                end

                rootPart.CFrame = chest.instance:GetPivot() + Vector3.new(0, 4, 0)
                task.wait(0.6)

                local opened = false
                IH_SafeCall(function()
                    opened = IH_MapChest:tryOpen(chest.instance):await()
                end)
                moved = true
                if opened then
                    break
                end
            end
        end
    end

    rootPart = IH_GetRoot()
    if moved and rootPart then
        rootPart.CFrame = returnCFrame
    end
end

local function getClosestSeller()
    local rootPart = IH_GetRoot()
    if rootPart then
        return IH_SellerCtrl:getClosestSeller(rootPart.Position)
    end
    return nil
end

local function IH_AutoSell()
    if not Toggles.AutoSell.Value or not IH_InvCtrl:isFull() then
        return
    end

    local rootPart = IH_GetRoot()
    local seller = getClosestSeller()
    if not rootPart or not seller then
        IH_PerformSell()
        task.wait(0.4)
        return
    end

    local returnCFrame = rootPart.CFrame
    rootPart.CFrame = seller.instance:GetPivot() + Vector3.new(0, 5, 0)
    task.wait(0.7)
    IH_PerformSell()
    task.wait(0.4)

    rootPart = IH_GetRoot()
    if rootPart then
        rootPart.CFrame = returnCFrame
    end
end

local function IH_ClaimAlbum()
    for id, entry in IH_AlbumCtrl:getEntries() do
        if entry.claimed ~= true then
            IH_SafeCall(function()
                IH_AlbumCtrl:claim(id):await()
            end)
        end
    end
end



local function IH_SipLake()
    while Toggles.AutoSip.Value and not Library.Unloaded do
        local activeSipping = IH_SipCtrl.activeSipping
        if not activeSipping then
            return
        end

        if activeSipping.done then
            if Toggles.InstantCatch.Value then
                activeSipping.lastSipClock = 0
            end

            IH_SafeCall(function()
                IH_SipCtrl:sip()
            end)
        end

        task.wait(if Toggles.InstantCatch.Value then 0.16 else 0)
    end
end

local function IH_SipLoop()
    while not Library.Unloaded do
        task.wait(0.1)

        if Toggles.AutoSip and Toggles.AutoSip.Value then
            IH_SafeCall(function()
                IH_CollectLakeChests()
                IH_CollectMapChests()

                if Toggles.AutoSwapLake.Value and not IH_EnsureLake() then
                    task.wait(0.5)
                    return
                end

                IH_AutoSell()

                if not IH_SipCtrl:isSipping() then
                    IH_SipCtrl:startLoading()
                    task.wait(0.1)
                    if not IH_SipCtrl:launch():await() then
                        task.wait(0.5)
                        return
                    end
                end

                IH_SipLake()
            end)
        else
            task.wait(0.5)
        end
    end
end

local function IH_AlbumLoop()
    while not Library.Unloaded do
        task.wait(5)
        if Toggles.AutoAlbum and Toggles.AutoAlbum.Value then
            IH_ClaimAlbum()
        end
    end
end

local function IH_AfkLoop()
    game:GetService("RunService").Heartbeat:Connect(function()
        if Toggles.AntiAfk and Toggles.AntiAfk.Value then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end
        end
    end
end



local function IH_Teleport()
    local filter = areaFilters[Options.TeleportArea.Value]
    if not filter then
        return
    end

    local rootPart = IH_GetRoot()
    if not rootPart then
        return
    end

    local closestLake
    local closestDistance
    for _, lake in IH_Components:getAllComponents("Q2") do
        if lake.instance.PrimaryPart and lakeMatchesFilters(lake, { filter }) then
            local distance = lake:getDistanceToPrimary(rootPart.Position)
            if closestDistance == nil or distance < closestDistance then
                closestLake = lake
                closestDistance = distance
            end
        end
    end

    if not closestLake then
        Library:Notify("No lake found in that area")
        return
    end

    local target = IH_FindStand(closestLake)
    if not target then
        target = CFrame.new(closestLake.instance:GetPivot().Position + Vector3.new(0, 6, 0))
    end
    rootPart.CFrame = target
end




local Window = WindUI:CreateWindow({
    Title = "IndraHub - Lake Sipping",
    Icon = "rbxassetid://18657887261",
    Author = "IndraHub",
    Folder = "IndraHub_LakeSipping",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = false,
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "coffee" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}


Tabs.Main:Section({ Title = "Sipping" })
Tabs.Main:Toggle({
    Title = "Auto Sip",
    Default = false,
    Callback = function(v)
        Toggles.AutoSip = { Value = v }
        IH_OnAutoSip(v)
    end
})
Tabs.Main:Toggle({
    Title = "Perfect Charge",
    Default = false,
    Callback = function(v)
        Toggles.PerfectCharge = { Value = v }
        IH_OnPerfCharge(v)
    end
})
Tabs.Main:Toggle({
    Title = "Instant Catch",
    Default = false,
    Callback = function(v) Toggles.InstantCatch = { Value = v } end
})
Tabs.Main:Toggle({
    Title = "Auto Swap Lake When Empty",
    Default = false,
    Callback = function(v) Toggles.AutoSwapLake = { Value = v } end
})
Tabs.Main:Dropdown({
    Title = "Areas",
    Multi = true,
    Values = areaNames,
    Value = {areaNames[1]},
    Callback = function(v)
        local mapped = {}
        for _, area in ipairs(v) do mapped[area] = true end
        Options.Areas = { Value = mapped }
    end
})


Tabs.Main:Section({ Title = "Selling" })
Tabs.Main:Toggle({
    Title = "Auto Sell When Full",
    Default = false,
    Callback = function(v) Toggles.AutoSell = { Value = v } end
})
Tabs.Main:Button({
    Title = "Sell All Now",
    Callback = function() task.spawn(IH_PerformSell) end
})


Tabs.Main:Section({ Title = "Extras" })
Tabs.Main:Toggle({
    Title = "Auto Collect Lake Chests",
    Default = false,
    Callback = function(v) Toggles.AutoLakeChest = { Value = v } end
})
Tabs.Main:Toggle({
    Title = "Auto Collect Map Chests",
    Default = false,
    Callback = function(v) Toggles.AutoMapChest = { Value = v } end
})
Tabs.Main:Toggle({
    Title = "Auto Claim Album Index",
    Default = false,
    Callback = function(v) Toggles.AutoAlbum = { Value = v } end
})


Tabs.Player:Section({ Title = "Movement" })
Tabs.Player:Toggle({
    Title = "Walk Speed",
    Default = false,
    Callback = function(v)
        Toggles.WalkSpeedEnabled = { Value = v }
        IH_OnWsToggle(v)
    end
})
Tabs.Player:Slider({
    Title = "Walk Speed Value",
    Default = 16,
    Min = 16,
    Max = 200,
    Callback = function(v)
        Options.WalkSpeed = { Value = v }
        IH_OnWsChanged(v)
    end
})
Tabs.Player:Toggle({
    Title = "No Clip",
    Default = false,
    Callback = function(v) Toggles.NoClip = { Value = v } end
})
Tabs.Player:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) Toggles.InfiniteJump = { Value = v } end
})
Tabs.Player:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(v) Toggles.Fly = { Value = v } end
})
Tabs.Player:Slider({
    Title = "Fly Speed",
    Default = 60,
    Min = 20,
    Max = 300,
    Callback = function(v) Options.FlySpeed = { Value = v } end
})


Tabs.Player:Section({ Title = "Teleport" })
Tabs.Player:Dropdown({
    Title = "Teleport Area",
    Values = areaNames,
    Value = areaNames[1],
    Callback = function(v) Options.TeleportArea = { Value = v } end
})
Tabs.Player:Button({
    Title = "Teleport",
    Callback = IH_Teleport
})


Tabs.Settings:Section({ Title = "Menu" })
Tabs.Settings:Toggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(v) Toggles.AntiAfk = { Value = v } end
})

Tabs.Settings:Section({ Title = "Discord" })
Tabs.Settings:Button({
    Title = "Join Discord",
    Callback = function()
        setclipboard(DISCORD_INVITE)
        WindUI:Notify({ Title = "Success", Content = "Copied Discord invite to clipboard", Duration = 3 })
    end
})

local function unload()
    for _, connection in connections do
        connection:Disconnect()
    end
    table.clear(connections)

    IH_StopFly()
    IH_SipCtrl.getCurrentLuck = originalGetCurrentLuck
    IH_SipCtrl:setAutoContext(false)
end


Toggles.AutoSip = { Value = false }
Toggles.PerfectCharge = { Value = false }
Toggles.InstantCatch = { Value = false }
Toggles.AutoSwapLake = { Value = false }
Options.Areas = { Value = {[areaNames[1]] = true} }
Toggles.AutoSell = { Value = false }
Toggles.AutoLakeChest = { Value = false }
Toggles.AutoMapChest = { Value = false }
Toggles.AutoAlbum = { Value = false }
Toggles.WalkSpeedEnabled = { Value = false }
Options.WalkSpeed = { Value = 16 }
Toggles.NoClip = { Value = false }
Toggles.InfiniteJump = { Value = false }
Toggles.Fly = { Value = false }
Options.FlySpeed = { Value = 60 }
Options.TeleportArea = { Value = areaNames[1] }
Toggles.AntiAfk = { Value = true }


IH_SafeCall(function()
    for _, connection in getconnections(LocalPlayer.Idled) do
        IH_SafeCall(function()
            connection:Disable()
        end)
    end
end)

table.insert(connections, RunService.Stepped:Connect(IH_UpdateWalkSpeed))
table.insert(connections, RunService.Stepped:Connect(IH_UpdateNoClip))
table.insert(connections, RunService.RenderStepped:Connect(IH_UpdateFly))
table.insert(connections, UserInputService.JumpRequest:Connect(IH_OnInfJump))
table.insert(connections, UserInputService.InputBegan:Connect(function()
    lastInputClock = tick()
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement
        or inputType == Enum.UserInputType.Gamepad1
    then
        lastInputClock = tick()
    end
end))

task.spawn(IH_SipLoop)
task.spawn(IH_AlbumLoop)
task.spawn(IH_AfkLoop)

WindUI:Notify({ Title = "IndraHub", Content = "Lake Sipping Loaded!", Duration = 5 })
