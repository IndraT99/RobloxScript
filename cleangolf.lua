-- [[ INDRA HUB — Golf Yard / Clean Golf ]]
-- Rebuilt with WindUI & Supervisor Heartbeat integration.

--=====================================================================
-- SUPERVISOR HEARTBEAT INTEGRATION
--=====================================================================

local setGlobal = setgenv or function(k, v) _G[k] = v end
local getGlobal = getgenv or function(k) return _G[k] end

setGlobal("IndraHubCleanGolfRunning", true)
if type(_G.IndraHubStatus) ~= "table" then
    _G.IndraHubStatus = {}
end
_G.IndraHubStatus["IndraHubCleanGolfLastHeartbeat"] = {
    script = "cleangolf.lua",
    heartbeat = os.clock(),
}

task.spawn(function()
    while setGlobal do
        setGlobal("IndraHubCleanGolfLastHeartbeat", os.clock())
        if type(_G.IndraHubStatus) == "table" and _G.IndraHubStatus["IndraHubCleanGolfLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubCleanGolfLastHeartbeat"].heartbeat = os.clock()
        end
        task.wait(1)
    end
end)

--=====================================================================
-- CONFIGURATION & SERVICES
--=====================================================================

local CONFIG = {
    AutoFarm = false,
    TeleportMode = false,
    AutoSell = false,
    SellOnlyWhenFull = false,
    AutoUpgradeAll = false,
    BatchSize = 100,
}

local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local balls = workspace:WaitForChild("ActiveGolfBalls")
local remotes = Storage:WaitForChild("RemotesNew")

local sharedEnvironment = (getgenv and getgenv()) or _G

local resumeSnapshot

do
    local existingMarker = workspace:FindFirstChild("GolfYardBallStackMarker")
    if existingMarker then
        local clusters = {}
        local largestCluster

        for _, entity in ipairs(balls:GetChildren()) do
            local part

            if entity:IsA("BasePart") then
                part = entity
            elseif entity:IsA("Model") then
                part = entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                local position = part.Position
                local key = string.format(
                    "%d:%d:%d",
                    math.round(position.X * 4),
                    math.round(position.Y * 4),
                    math.round(position.Z * 4)
                )

                local cluster = clusters[key]
                if not cluster then
                    cluster = {
                        entities = {},
                        cframe = entity:IsA("Model") and entity:GetPivot() or part.CFrame,
                    }
                    clusters[key] = cluster
                end

                cluster.entities[#cluster.entities + 1] = entity

                if not largestCluster or #cluster.entities > #largestCluster.entities then
                    largestCluster = cluster
                end
            end
        end

        if largestCluster and #largestCluster.entities > 1 then
            resumeSnapshot = largestCluster
        end
    end
end

if type(sharedEnvironment.__GolfYardCleanup) == "function" then
    pcall(sharedEnvironment.__GolfYardCleanup, true)
end

local running = true
local connections = {}

local networker
pcall(function()
    local modules = Storage:WaitForChild("Modules", 5)
    local packageRoot = modules and modules:WaitForChild("rwque", 5)
    local packages = packageRoot and packageRoot:WaitForChild("Packages", 5)
    local module = packages and packages:WaitForChild("Networker", 5)
    if module then
        networker = require(module).new()
    end
end)

local function fireServer(name, ...)
    if networker then
        networker:FireServer(name, ...)
    else
        remotes:WaitForChild(name):FireServer(...)
    end
end

local function safeFire(name, ...)
    local arguments = table.pack(...)
    return pcall(function()
        fireServer(name, table.unpack(arguments, 1, arguments.n))
    end)
end

local function numericAttribute(name, fallback)
    local value = player:GetAttribute(name)
    return type(value) == "number" and value or fallback
end

local function bagIsFull()
    local count = player:GetAttribute("BagCount")
    local capacity = player:GetAttribute("BagCapacity")
    return type(count) == "number"
        and type(capacity) == "number"
        and count >= capacity
end

local function bagHasBalls()
    return numericAttribute("BagCount", 0) > 0
end

local function getCharacterParts()
    local character = player.Character
    if not character then
        return nil, nil, nil
    end

    return character,
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChildWhichIsA("Humanoid")
end

local function collectBatch(origin)
    local radius = numericAttribute("CollectionRange", 60)
    local batch = {}

    for _, ball in ipairs(balls:GetChildren()) do
        if ball:IsA("BasePart") and (ball.Position - origin).Magnitude <= radius then
            table.insert(batch, ball)
            if #batch >= CONFIG.BatchSize then
                break
            end
        end
    end

    return batch
end

local targetList = {}
local targetIndex = 0

local function refreshTargets()
    targetList = balls:GetChildren()
    targetIndex = 0
end

local function nextTarget()
    for _ = 1, 2 do
        while targetIndex < #targetList do
            targetIndex += 1
            local target = targetList[targetIndex]
            if target.Parent == balls and target:IsA("BasePart") then
                return target
            end
        end
        refreshTargets()
    end
    return nil
end

local selling = false
local lastSellAt = -math.huge
local sellStatus = "Ready"

local function sellBag(waitForBagChange)
    if selling or os.clock() - lastSellAt < 0.25 then
        return false
    end

    selling = true
    sellStatus = "Selling"
    local startingCount = numericAttribute("BagCount", -1)
    local sold = false

    for _ = 1, 3 do
        local fired = safeFire("Fill")
        if fired and (not waitForBagChange or startingCount < 0) then
            sold = true
            break
        end

        if fired then
            local deadline = os.clock() + 0.8
            repeat
                task.wait(0.08)
                local currentCount = numericAttribute("BagCount", startingCount)
                if currentCount < startingCount then
                    sold = true
                    break
                end
            until os.clock() >= deadline
        end

        if sold then
            break
        end
        task.wait(0.15)
    end

    lastSellAt = os.clock()
    sellStatus = sold and "Sold" or "Sell retry"
    selling = false
    return sold
end

local persistedStackState = sharedEnvironment.__GolfYardStackState
if type(persistedStackState) ~= "table" then
    persistedStackState = {
        active = false,
        stackCFrame = nil,
        originals = {},
        partStates = {},
        visualStates = {},
    }
    sharedEnvironment.__GolfYardStackState = persistedStackState
end

persistedStackState.originals = type(persistedStackState.originals) == "table"
    and persistedStackState.originals
    or {}
persistedStackState.partStates = type(persistedStackState.partStates) == "table"
    and persistedStackState.partStates
    or {}
persistedStackState.visualStates = type(persistedStackState.visualStates) == "table"
    and persistedStackState.visualStates
    or {}

local ballStackActive = persistedStackState.active == true
local ballStackCFrame = persistedStackState.stackCFrame
local ballStackMarker
local ballStackLabel

local stackedEntities = persistedStackState.originals
local hiddenParts = persistedStackState.partStates
local hiddenVisuals = persistedStackState.visualStates

local stackedCountCache = 0
local maintenanceEntities = {}
local maintenanceIndex = 0

local function syncPersistedStackState()
    persistedStackState.active = ballStackActive
    persistedStackState.stackCFrame = ballStackCFrame
    persistedStackState.originals = stackedEntities
    persistedStackState.partStates = hiddenParts
    persistedStackState.visualStates = hiddenVisuals
    sharedEnvironment.__GolfYardStackState = persistedStackState
end

local function getEntityPart(entity)
    if entity:IsA("BasePart") then
        return entity
    end

    if entity:IsA("Model") then
        return entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

local function rebuildStackCache()
    table.clear(maintenanceEntities)
    stackedCountCache = 0
    maintenanceIndex = 0

    for entity in pairs(stackedEntities) do
        if entity and entity.Parent == balls and getEntityPart(entity) then
            maintenanceEntities[#maintenanceEntities + 1] = entity
            stackedCountCache += 1
        else
            stackedEntities[entity] = nil
        end
    end
end

local function forgetEntityVisualState(entity)
    local objects = { entity }

    for _, descendant in ipairs(entity:GetDescendants()) do
        objects[#objects + 1] = descendant
    end

    for _, object in ipairs(objects) do
        hiddenParts[object] = nil
        hiddenVisuals[object] = nil
    end
end

local function getEntityCFrame(entity)
    if entity:IsA("BasePart") then
        return entity.CFrame
    end

    if entity:IsA("Model") and getEntityPart(entity) then
        return entity:GetPivot()
    end

    return nil
end

local function setEntityCFrame(entity, targetCFrame)
    if entity:IsA("BasePart") then
        entity.AssemblyLinearVelocity = Vector3.zero
        entity.AssemblyAngularVelocity = Vector3.zero
        entity.CFrame = targetCFrame
        return true
    end

    if entity:IsA("Model") and getEntityPart(entity) then
        entity:PivotTo(targetCFrame)

        for _, descendant in ipairs(entity:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.AssemblyLinearVelocity = Vector3.zero
                descendant.AssemblyAngularVelocity = Vector3.zero
            end
        end

        return true
    end

    return false
end

local function moveEntitiesTogether(entities, targetCFrame)
    local bulkParts = {}
    local bulkCFrames = {}
    local models = {}
    local movedCount = 0

    for _, entity in ipairs(entities) do
        if entity and entity.Parent == balls then
            if entity:IsA("BasePart") then
                entity.AssemblyLinearVelocity = Vector3.zero
                entity.AssemblyAngularVelocity = Vector3.zero
                bulkParts[#bulkParts + 1] = entity
                bulkCFrames[#bulkCFrames + 1] = targetCFrame
            elseif entity:IsA("Model") and getEntityPart(entity) then
                models[#models + 1] = entity
            end
        end
    end

    if #bulkParts > 0 then
        local ok = pcall(function()
            workspace:BulkMoveTo(
                bulkParts,
                bulkCFrames,
                Enum.BulkMoveMode.FireCFrameChanged
            )
        end)

        if not ok then
            for _, part in ipairs(bulkParts) do
                pcall(setEntityCFrame, part, targetCFrame)
            end
        end

        movedCount += #bulkParts
    end

    for _, model in ipairs(models) do
        local ok, moved = pcall(setEntityCFrame, model, targetCFrame)
        if ok and moved then
            movedCount += 1
        end
    end

    return movedCount
end

local function hideEntityRendering(entity)
    local objects = { entity }

    for _, descendant in ipairs(entity:GetDescendants()) do
        objects[#objects + 1] = descendant
    end

    for _, object in ipairs(objects) do
        if object:IsA("BasePart") then
            if hiddenParts[object] == nil then
                hiddenParts[object] = {
                    LocalTransparencyModifier = object.LocalTransparencyModifier,
                    CastShadow = object.CastShadow,
                    CanCollide = object.CanCollide,
                    CanTouch = object.CanTouch,
                    CanQuery = object.CanQuery,
                    Massless = object.Massless,
                    Anchored = object.Anchored,
                }
            else
                local saved = hiddenParts[object]
                if saved.CanTouch == nil then
                    saved.CanTouch = object.CanTouch
                end
                if saved.CanQuery == nil then
                    saved.CanQuery = object.CanQuery
                end
                if saved.Anchored == nil then
                    saved.Anchored = object.Anchored
                end
            end

            if object.LocalTransparencyModifier ~= 1 then
                object.LocalTransparencyModifier = 1
            end
            if object.CastShadow then
                object.CastShadow = false
            end
            if object.CanCollide then
                object.CanCollide = false
            end
            if object.CanTouch then
                object.CanTouch = false
            end
            if object.CanQuery then
                object.CanQuery = false
            end
            if not object.Massless then
                object.Massless = true
            end
            if not object.Anchored then
                object.Anchored = true
                object.AssemblyLinearVelocity = Vector3.zero
                object.AssemblyAngularVelocity = Vector3.zero
            end
        elseif (
            object:IsA("ParticleEmitter")
            or object:IsA("Trail")
            or object:IsA("Beam")
            or object:IsA("Smoke")
            or object:IsA("Fire")
            or object:IsA("Sparkles")
            or object:IsA("BillboardGui")
            or object:IsA("SurfaceGui")
            or object:IsA("Highlight")
            or object:IsA("PointLight")
            or object:IsA("SpotLight")
            or object:IsA("SurfaceLight")
        ) then
            if hiddenVisuals[object] == nil then
                hiddenVisuals[object] = {
                    property = "Enabled",
                    value = object.Enabled,
                }
            end
            if object.Enabled then
                object.Enabled = false
            end
        elseif object:IsA("Decal") or object:IsA("Texture") then
            if hiddenVisuals[object] == nil then
                hiddenVisuals[object] = {
                    property = "Transparency",
                    value = object.Transparency,
                }
            end
            if object.Transparency ~= 1 then
                object.Transparency = 1
            end
        end
    end
end

local function restorePart(part)
    local saved = hiddenParts[part]
    if saved == nil then
        return
    end

    if part.Parent then
        pcall(function()
            part.LocalTransparencyModifier = saved.LocalTransparencyModifier
            part.CastShadow = saved.CastShadow
            part.CanCollide = saved.CanCollide
            if saved.CanTouch ~= nil then
                part.CanTouch = saved.CanTouch
            end
            if saved.CanQuery ~= nil then
                part.CanQuery = saved.CanQuery
            end
            part.Massless = saved.Massless
            if saved.Anchored ~= nil then
                part.Anchored = saved.Anchored
            end
        end)
    end

    hiddenParts[part] = nil
end

local function restoreVisual(object)
    local saved = hiddenVisuals[object]
    if saved == nil then
        return
    end

    if object.Parent then
        pcall(function()
            if type(saved) == "table" then
                object[saved.property] = saved.value
            else
                object.Enabled = saved
            end
        end)
    end

    hiddenVisuals[object] = nil
end

local function showEntityRendering(entity)
    local objects = { entity }

    for _, descendant in ipairs(entity:GetDescendants()) do
        objects[#objects + 1] = descendant
    end

    for _, object in ipairs(objects) do
        if object:IsA("BasePart") then
            restorePart(object)
        else
            restoreVisual(object)
        end
    end
end

local function restoreAllRendering()
    for part in pairs(hiddenParts) do
        restorePart(part)
    end

    for object in pairs(hiddenVisuals) do
        restoreVisual(object)
    end
end

local function destroyBallStackMarker()
    local existingMarker = workspace:FindFirstChild("GolfYardBallStackMarker")
    if existingMarker and existingMarker ~= ballStackMarker then
        existingMarker:Destroy()
    end

    if ballStackMarker then
        ballStackMarker:Destroy()
        ballStackMarker = nil
        ballStackLabel = nil
    end
end

local collectingStack = false

local function collectHiddenStack()
    if collectingStack or not ballStackActive then
        return
    end

    collectingStack = true
    task.spawn(function()
        local entities = {}

        for entity in pairs(stackedEntities) do
            if entity and entity.Parent == balls then
                entities[#entities + 1] = entity
            end
        end

        local batchSize = math.clamp(CONFIG.BatchSize, 1, 1000)
        local sent = 0

        for first = 1, #entities, batchSize do
            if not running or not ballStackActive then
                break
            end

            local batch = {}
            local last = math.min(first + batchSize - 1, #entities)

            for index = first, last do
                batch[#batch + 1] = entities[index]
            end

            if #batch > 0 then
                safeFire("Collect2", batch)
                sent += #batch
                sellStatus = string.format("Collecting hidden stack: %d/%d", sent, #entities)
                task.wait(math.max(0.03, numericAttribute("CollectCooldown", 0.1)))
            end
        end

        collectingStack = false
        updateBallStackMarker()
    end)
end

local function createBallStackMarker(stackCFrame, count)
    destroyBallStackMarker()

    local marker = Instance.new("Part")
    marker.Name = "GolfYardBallStackMarker"
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(0.3, 4, 4)
    marker.CFrame = stackCFrame
        * CFrame.new(0, -2.65, 0)
        * CFrame.Angles(0, 0, math.rad(90))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.CastShadow = false
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(170, 100, 255)
    marker.Transparency = 0.2
    marker.Parent = workspace

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "CollectHiddenBalls"
    prompt.ActionText = "Collect Balls"
    prompt.ObjectText = string.format("%d Hidden Balls", count)
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 18
    prompt.RequiresLineOfSight = false
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.Parent = marker

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer == player then
            collectHiddenStack()
        end
    end)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "StackDisplay"
    billboard.Size = UDim2.fromOffset(190, 58)
    billboard.StudsOffset = Vector3.new(0, 3.1, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = marker

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    label.BackgroundTransparency = 0.1
    label.BorderSizePixel = 0
    label.Text = string.format("BALL STACK\n%d hidden balls", count)
    label.TextColor3 = Color3.fromRGB(245, 247, 252)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = billboard

    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 7)
    labelCorner.Parent = label

    ballStackMarker = marker
    ballStackLabel = label
end

local function updateBallStackMarker()
    local count = stackedCountCache

    if ballStackLabel then
        ballStackLabel.Text = string.format("BALL STACK\n%d hidden balls", count)
    end

    if ballStackActive and count == 0 then
        ballStackActive = false
        ballStackCFrame = nil
        restoreAllRendering()
        destroyBallStackMarker()
        table.clear(stackedEntities)
        syncPersistedStackState()
        sellStatus = "All stacked balls collected"
    end

    return count
end

local function restoreBallStack(restorePositions)
    ballStackActive = false

    for entity, originalCFrame in pairs(stackedEntities) do
        if entity and entity.Parent then
            if restorePositions and originalCFrame then
                pcall(setEntityCFrame, entity, originalCFrame)
            end

            showEntityRendering(entity)
        end
    end

    table.clear(stackedEntities)
    table.clear(maintenanceEntities)
    stackedCountCache = 0
    maintenanceIndex = 0
    restoreAllRendering()
    destroyBallStackMarker()
    ballStackCFrame = nil
    syncPersistedStackState()
end

local function applyExistingStack()
    local entities = {}

    if ballStackActive and ballStackCFrame then
        for entity in pairs(stackedEntities) do
            if entity and entity.Parent == balls and getEntityPart(entity) then
                hideEntityRendering(entity)
                entities[#entities + 1] = entity
            else
                stackedEntities[entity] = nil
            end
        end
    elseif resumeSnapshot and resumeSnapshot.cframe then
        ballStackCFrame = resumeSnapshot.cframe

        for _, entity in ipairs(resumeSnapshot.entities) do
            if entity and entity.Parent == balls and getEntityPart(entity) then
                local originalCFrame = getEntityCFrame(entity)
                if originalCFrame then
                    stackedEntities[entity] = originalCFrame
                    hideEntityRendering(entity)
                    entities[#entities + 1] = entity
                end
            end
        end

        ballStackActive = #entities > 0
    end

    if ballStackActive and ballStackCFrame and #entities > 0 then
        moveEntitiesTogether(entities, ballStackCFrame)
        createBallStackMarker(ballStackCFrame, #entities)
        sellStatus = string.format("Resumed %d hidden balls", #entities)
    elseif ballStackActive then
        ballStackActive = false
        ballStackCFrame = nil
    end

    rebuildStackCache()
    syncPersistedStackState()
end

local function bringAllBallsStacked()
    if ballStackActive then
        restoreBallStack(true)
        sellStatus = "Ball stack restored"
        return
    end

    local _, root = getCharacterParts()
    if not root then
        sellStatus = "No character"
        return
    end

    local stackCFrame = root.CFrame * CFrame.new(0, 0, -6)
    local entities = {}

    for _, entity in ipairs(balls:GetChildren()) do
        if getEntityPart(entity) then
            local originalCFrame = getEntityCFrame(entity)
            if originalCFrame then
                stackedEntities[entity] = originalCFrame
                hideEntityRendering(entity)
                entities[#entities + 1] = entity
            end
        end
    end

    if #entities == 0 then
        restoreBallStack(false)
        sellStatus = "No balls found"
        return
    end

    local movedCount = moveEntitiesTogether(entities, stackCFrame)
    if movedCount == 0 then
        restoreBallStack(true)
        sellStatus = "Ball move failed"
        return
    end

    ballStackActive = true
    ballStackCFrame = stackCFrame
    rebuildStackCache()
    createBallStackMarker(stackCFrame, stackedCountCache)
    syncPersistedStackState()
    sellStatus = string.format("Stacked %d hidden balls", movedCount)
end

applyExistingStack()

--=====================================================================
-- WINDUI INTERFACE SETUP
--=====================================================================

local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI or not WindUI then
    warn("Failed to load WindUI for Clean Golf")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Golf Yard",
    Icon = "flag",
    Author = "IndraHub",
    Folder = "IndraHub_GolfYard",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
})

local Tabs = {
    farming  = Window:Tab({ Title = "Auto Farm",     Icon = "circle-dot" }),
    stacking = Window:Tab({ Title = "Ball Stacking", Icon = "layers" }),
    settings = Window:Tab({ Title = "Settings",      Icon = "settings" }),
}

--=====================================================================
-- AUTO FARM TAB
--=====================================================================

Tabs.farming:Section({ Title = "Farming Toggles" })

Tabs.farming:Toggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(value)
        CONFIG.AutoFarm = value
    end,
})

Tabs.farming:Toggle({
    Title = "Teleport Mode",
    Default = false,
    Callback = function(value)
        CONFIG.TeleportMode = value
    end,
})

Tabs.farming:Toggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(value)
        CONFIG.AutoSell = value
    end,
})

Tabs.farming:Toggle({
    Title = "Sell Only When Full",
    Default = false,
    Callback = function(value)
        CONFIG.SellOnlyWhenFull = value
    end,
})

Tabs.farming:Toggle({
    Title = "Auto Upgrade All (Shop)",
    Default = false,
    Callback = function(value)
        CONFIG.AutoUpgradeAll = value
    end,
})

Tabs.farming:Slider({
    Title = "Batch Size",
    Default = 100,
    Min = 1,
    Max = 1000,
    Step = 5,
    Callback = function(value)
        CONFIG.BatchSize = value
    end,
})

Tabs.farming:Divider()

local farmStatusParagraph = Tabs.farming:Paragraph({
    Title = "Farm Status",
    Desc = "Bag: ?/? | Range: 60\nStatus: Ready",
})

--=====================================================================
-- BALL STACKING TAB
--=====================================================================

Tabs.stacking:Section({ Title = "Ball Stacking & Quick Actions" })

local bringBallsButton = Tabs.stacking:Button({
    Title = "Bring All Balls",
    Callback = bringAllBallsStacked,
})

Tabs.stacking:Button({
    Title = "Collect Hidden Stack",
    Callback = function()
        if not ballStackActive then
            sellStatus = "No active ball stack"
            return
        end
        collectHiddenStack()
    end,
})

Tabs.stacking:Button({
    Title = "Sell Now",
    Callback = function()
        if not bagHasBalls() then
            sellStatus = "Bag empty"
            return
        end
        sellBag(true)
    end,
})

Tabs.stacking:Button({
    Title = "Toggle Golf Kart",
    Callback = function()
        safeFire("ToggleGolfKart")
    end,
})

Tabs.stacking:Divider()

local stackStatusParagraph = Tabs.stacking:Paragraph({
    Title = "Ball Stack Status",
    Desc = "Stack State: INACTIVE",
})

--=====================================================================
-- SETTINGS TAB & CLEANUP
--=====================================================================

local function cleanup(preserveStack)
    if not running then
        return
    end

    running = false

    if preserveStack and ballStackActive then
        syncPersistedStackState()
        destroyBallStackMarker()
    else
        restoreBallStack(true)
        sharedEnvironment.__GolfYardStackState = nil
    end

    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(connections)

    setGlobal("IndraHubCleanGolfRunning", false)

    if sharedEnvironment.__GolfYardCleanup == cleanup then
        sharedEnvironment.__GolfYardCleanup = nil
    end
end

sharedEnvironment.__GolfYardCleanup = cleanup

Tabs.settings:Section({ Title = "Information" })

Tabs.settings:Paragraph({
    Title = "IndraHub | Golf Yard",
    Desc = "Rebuilt with WindUI & Supervisor Heartbeat integration.",
})

Tabs.settings:Section({ Title = "Script Control" })

Tabs.settings:Button({
    Title = "Unload Hub",
    Callback = function()
        cleanup(false)
        if Window then
            Window:Destroy()
        end
    end,
})

--=====================================================================
-- BACKGROUND TASKS
--=====================================================================

task.spawn(function()
    while running do
        local stackedCount = updateBallStackMarker()
        if bringBallsButton and bringBallsButton.SetTitle then
            bringBallsButton:SetTitle(ballStackActive and "Restore Ball Stack" or "Bring All Balls")
        end
        if farmStatusParagraph then
            farmStatusParagraph:SetDesc(string.format(
                "Bag: %s/%s | Range: %s\nStatus: %s",
                tostring(player:GetAttribute("BagCount") or "?"),
                tostring(player:GetAttribute("BagCapacity") or "?"),
                tostring(player:GetAttribute("CollectionRange") or 60),
                sellStatus
            ))
        end
        if stackStatusParagraph then
            stackStatusParagraph:SetDesc(ballStackActive
                and string.format("Stack State: ACTIVE (%d hidden balls)", stackedCount)
                or "Stack State: INACTIVE"
            )
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while running do
        if ballStackActive and #maintenanceEntities > 0 then
            maintenanceIndex += 1
            if maintenanceIndex > #maintenanceEntities then
                maintenanceIndex = 1
            end

            local entity = maintenanceEntities[maintenanceIndex]
            if entity and entity.Parent == balls and stackedEntities[entity] ~= nil then
                hideEntityRendering(entity)
            else
                rebuildStackCache()
                updateBallStackMarker()
                syncPersistedStackState()
            end
        end

        task.wait(0.05)
    end
end)

connections[#connections + 1] = balls.ChildAdded:Connect(function(entity)
    if not ballStackActive or not ballStackCFrame then
        return
    end

    task.defer(function()
        if not running or not ballStackActive or entity.Parent ~= balls then
            return
        end

        local part = getEntityPart(entity)
        if not part then
            return
        end

        if (part.Position - ballStackCFrame.Position).Magnitude <= 3 then
            if stackedEntities[entity] == nil then
                stackedEntities[entity] = getEntityCFrame(entity) or ballStackCFrame
            end
            hideEntityRendering(entity)
            pcall(setEntityCFrame, entity, ballStackCFrame)
            rebuildStackCache()
            updateBallStackMarker()
            syncPersistedStackState()
        end
    end)
end)

connections[#connections + 1] = balls.ChildRemoved:Connect(function(entity)
    if stackedEntities[entity] == nil then
        return
    end

    stackedEntities[entity] = nil
    forgetEntityVisualState(entity)
    rebuildStackCache()
    updateBallStackMarker()
    syncPersistedStackState()
end)

task.spawn(function()
    while running do
        if CONFIG.AutoUpgradeAll then
            safeFire("BuyAllShop")
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while running do
        if CONFIG.AutoSell and bagHasBalls() then
            local shouldSell = not CONFIG.SellOnlyWhenFull or bagIsFull()
            if shouldSell then
                sellBag(true)
            end
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while running do
        if not CONFIG.AutoFarm then
            task.wait(0.2)
            continue
        end

        local cooldown = math.max(0.05, numericAttribute("CollectCooldown", 0.1))

        if CONFIG.AutoSell and bagIsFull() then
            task.wait(cooldown)
            continue
        end

        local _, root = getCharacterParts()
        local readyToCollect = root ~= nil

        if root and CONFIG.TeleportMode then
            local target = nextTarget()
            readyToCollect = target ~= nil
            if target then
                local moved = pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                end)
                readyToCollect = moved
                if moved then
                    task.wait(0.05)
                end
            end
        end

        if root and readyToCollect then
            local batch = collectBatch(root.Position)
            if #batch > 0 then
                safeFire("Collect2", batch)
            end
        end

        task.wait(cooldown)
    end
end)
