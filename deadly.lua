-- Deobfuscated from deadly.
-- The supplied input had already collapsed some encrypted property expressions
-- to zero-index markers. Recoverable decoder, environment, state, service, and API indirection
-- has been removed; unresolved markers retain the input's missing information.

local state = {}
local noclipConnection

if game.PlaceId == 125810438250765 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IndraHub SYNDICATE",
            Text = "Please enter the game, do not execute in the lobby!",
            Duration = 7
        })
    end)
    return
end

state.supportedPlaces = {
    [88921463361464]  = true, -- Deadly Delivery
    [120697797916670] = true, -- Deadly Delivery (alt / lobby)
    [93044798454681]  = true, -- Deadly Delivery (Underground)
}

if not state.supportedPlaces[game.PlaceId] then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IndraHub SYNDICATE",
            Text = "Unauthorized Game! This script only supports Deadly Delivery.",
            Duration = 7
        })
    end)
    return
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "IndraHub SYNDICATE",
        Text = "Deadly Delivery script successfully loaded!",
        Duration = 5
    })
end)

-- Core Services
state.playersService = game:GetService("Players")
state.localPlayer = state.playersService.LocalPlayer
state.replicatedStorage = game:GetService("ReplicatedStorage")
state.userInputService = game:GetService("UserInputService")
state.runService = game:GetService("RunService")
state.coreGui = game:GetService("CoreGui")

-- Script Identity
state.scriptInstanceId = math.random() .. "_" .. os.clock()

state.returnCFrame = nil
pcall(function()
    local character = state.localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then state.returnCFrame = rootPart.CFrame end
end)

-- ============================================================
-- INSTANCE CLEANUP (kill previous run fully)
-- ============================================================
if _G.IndraHubPremiumState then
    _G.IndraHubPremiumState.stopThreads = true
    pcall(function()
        if _G.IndraHubPremiumState.cleanAll then
            _G.IndraHubPremiumState.cleanAll()
        end
    end)
    pcall(function()
        if _G.IndraHubPremiumState.UI then
            _G.IndraHubPremiumState.UI:Destroy()
        end
    end)
end

-- Initialize global state for this instance
_G.IndraHubPremiumState = {
    stopThreads    = false,
    ScriptInstanceId = state.scriptInstanceId,
    UI             = nil,
    cleanAll       = nil,
}

-- Config Default
state.config = {
    LootEsp = false,
    MonsterEsp = false,
    PlayerEsp = false,
    ContainerEsp = false,
    MinLootPrice = 0,
    AutoTakeItem = false,
    AutoOpenContainers = false,
    InfiniteStamina = false,
    Fullbright = false,
    Noclip = false,
    SpeedHack = false,
    SpeedValue = 16,
    KillAura = false,
}

-- ============================================================
-- HELPER FUNCTIONS & HOOKS
-- ============================================================
state.network = nil
pcall(function()
    state.network = require(state.replicatedStorage.Shared.Core.TEvent)
end)

-- 1. Hook PlayerMove Remote (Anti-Cheat Bypass)
pcall(function()
    if state.network then
        local playerMoveRemote = state.network.Remote.new("PlayerMove")
        local originalFireServer = playerMoveRemote.FireServer
        playerMoveRemote.FireServer = function(remoteSelf, ...)
            local arguments = {...}
            if arguments[1] == 1 or arguments[1] == 2 or arguments[1] == 3 then
                return -- Block speed/teleport anti-cheat reports
            end
            return originalFireServer(remoteSelf, ...)
        end
    end
end)

-- 2. Speed Bypass via Buff Event
state.applySpeed = function()
    if not state.config.SpeedHack then return end
    pcall(function()
        local buffTypes = require(state.replicatedStorage.Shared.Features.Buff.BuffType)
        buffTypes.WalkSpeed.Changed:Fire(nil, state.config.SpeedValue - 16, 1)
    end)
end

-- Keep speed applied if game resets it
task.spawn(function()
    while not _G.IndraHubPremiumState.stopThreads and _G.IndraHubPremiumState.ScriptInstanceId == state.scriptInstanceId do
        task.wait(1)
        if state.config.SpeedHack then
            state.applySpeed()
        end
        if state.config.InfiniteStamina then
            pcall(function()
                local buffTypes = require(state.replicatedStorage.Shared.Features.Buff.BuffType)
                buffTypes.StaminaInfinite.Changed:Fire(nil, 1)
            end)
        end
    end
end)

-- 3. Fullbright
state.lighting = game:GetService("Lighting")
state.originalAmbient = state.lighting.Ambient
state.originalOutdoorAmbient = state.lighting.OutdoorAmbient
state.originalBrightness = state.lighting.Brightness
state.originalClockTime = state.lighting.ClockTime
state.fullbrightConnection = nil

state.applyFullbright = function()
    if state.fullbrightConnection then state.fullbrightConnection:Disconnect() end
    state.fullbrightConnection = state.runService.Heartbeat:Connect(function()
        if state.config.Fullbright then
            state.lighting.Ambient = Color3.fromRGB(255, 255, 255)
            state.lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            state.lighting.Brightness = 2
            state.lighting.ClockTime = 12
        else
            state.lighting.Ambient = state.originalAmbient
            state.lighting.OutdoorAmbient = state.originalOutdoorAmbient
            state.lighting.Brightness = state.originalBrightness
            state.lighting.ClockTime = state.originalClockTime
            state.fullbrightConnection:Disconnect()
            state.fullbrightConnection = nil
        end
    end)
end

-- 4. Noclip Loop
noclipConnection = state.runService.Stepped:Connect(function()
    if _G.IndraHubPremiumState.stopThreads or _G.IndraHubPremiumState.ScriptInstanceId ~= state.scriptInstanceId then
        if noclipConnection then noclipConnection:Disconnect() end
        return
    end
    pcall(function()
        if state.config.Noclip then
            local character = state.localPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- 5. Unified ESP System
state.espRegistry = {
    Loot = {},
    Monster = {},
    Player = {},
    Container = {}
}

state.priorityLootIds = {
    [101] = true,  -- Coin
    [201] = true,  -- Gold
    [301] = true,  -- Mini Coin
    [1301] = true, -- Revive Ticket
}

-- Loot ESP
state.createLootEsp = function(loot)
    if not state.config.LootEsp then return end
    if state.espRegistry.Loot[loot] then return end

    local lootPrice = 0
    local lootUi = loot:FindFirstChild("LootUI", true)
    if lootUi then
        local priceLabel = lootUi:FindFirstChild("Price", true)
        if priceLabel then
            lootPrice = tonumber(priceLabel.Text:match("%d+")) or 0
        end
    end

    local lootId = loot:GetAttribute("id")
    local isPriorityLoot = state.priorityLootIds[lootId]

    if lootPrice < state.config.MinLootPrice and not isPriorityLoot then
        return
    end

    local lootName = loot.Name
    pcall(function()
        local configModule = require(state.replicatedStorage.Config)
        local lootMetadata = configModule.GetGlobal(lootId)
        if lootMetadata and lootMetadata.name then lootName = lootMetadata.name end
    end)

    local lootRoot = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")
    if not lootRoot then return end

    -- Custom colors for currencies
    local espColor = Color3.fromRGB(235, 180, 50) -- Default Gold/Yellow
    if lootId == 1301 then
        espColor = Color3.fromRGB(220, 50, 220) -- Magenta for Revive Ticket
    elseif lootId == 201 then
        espColor = Color3.fromRGB(255, 215, 0) -- Bright Gold for Gold
    elseif lootId == 101 or lootId == (301) then
        espColor = Color3.fromRGB(255, 230, 100) -- Light Gold for Coins
    end

    local lootBillboard = Instance.new("BillboardGui")
    lootBillboard.Name = "IndraHubLootEsp"
    lootBillboard.AlwaysOnTop = true
    lootBillboard.Size = UDim2.new(0, 150, 0, 40)
    lootBillboard.StudsOffset = Vector3.new(0, 2, 0)
    lootBillboard.Adornee = lootRoot

    local lootLabel = Instance.new("TextLabel")
    lootLabel.Parent = lootBillboard
    lootLabel.Size = UDim2.new(1, 0, 1, 0)
    lootLabel.BackgroundTransparency = 1
    lootLabel.TextColor3 = espColor
    lootLabel.TextStrokeTransparency = 0.2
    lootLabel.TextSize = 13
    lootLabel.Font = Enum.Font.SourceSansBold
    lootLabel.Text = lootName .. (lootPrice > 0 and (" ($" .. tostring(lootPrice) .. ")") or "")

    local lootHighlight = Instance.new("Highlight")
    lootHighlight.Name = "IndraHubLootHighlight"
    lootHighlight.Adornee = loot
    lootHighlight.FillColor = espColor
    lootHighlight.FillTransparency = 0.6
    lootHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    lootHighlight.OutlineTransparency = 0

    lootBillboard.Parent = state.coreGui
    lootHighlight.Parent = state.coreGui
    state.espRegistry.Loot[loot] = { Billboard = lootBillboard, Box = lootHighlight }
end

state.clearLootEsp = function()
    for target, espObjects in pairs(state.espRegistry.Loot) do
        pcall(function() espObjects.Billboard:Destroy() end)
        pcall(function() espObjects.Box:Destroy() end)
    end
    table.clear(state.espRegistry.Loot)
end

state.refreshLootEsp = function()
    state.clearLootEsp()
    if not state.config.LootEsp then return end

    local lootsFolder = workspace.GameSystem:FindFirstChild("Loots")
    if not lootsFolder then return end

    local function scanLootFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Model") or item:IsA("Tool") then
                state.createLootEsp(item)
            end
        end
    end

    scanLootFolder(lootsFolder:FindFirstChild("World"))
    scanLootFolder(lootsFolder:FindFirstChild("Player"))
end

-- Monster ESP
state.createMonsterEsp = function(monster)
    if not state.config.MonsterEsp then return end
    if state.espRegistry.Monster[monster] then return end

    local configId = monster:GetAttribute("ConfigId")
    local monsterName = "Monster"
    pcall(function()
        local configModule = require(state.replicatedStorage.Config)
        local monsterMetadata = configModule.GetGlobal(configId)
        if monsterMetadata and monsterMetadata.name then monsterName = monsterMetadata.name end
    end)

    local monsterRoot = monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart")
    if not monsterRoot then return end

    local monsterBillboard = Instance.new("BillboardGui")
    monsterBillboard.Name = "IndraHubMonsterEsp"
    monsterBillboard.AlwaysOnTop = true
    monsterBillboard.Size = UDim2.new(0, 150, 0, 40)
    monsterBillboard.StudsOffset = Vector3.new(0, 3, 0)
    monsterBillboard.Adornee = monsterRoot

    local monsterLabel = Instance.new("TextLabel")
    monsterLabel.Parent = monsterBillboard
    monsterLabel.Size = UDim2.new(1, 0, 1, 0)
    monsterLabel.BackgroundTransparency = 1
    monsterLabel.TextColor3 = Color3.fromRGB(240, 70, 70)
    monsterLabel.TextStrokeTransparency = 0.2
    monsterLabel.TextSize = 13
    monsterLabel.Font = Enum.Font.SourceSansBold

    local monsterHighlight = Instance.new("Highlight")
    monsterHighlight.Name = "IndraHubMonsterHighlight"
    monsterHighlight.Adornee = monster
    monsterHighlight.FillColor = Color3.fromRGB(240, 70, 70)
    monsterHighlight.FillTransparency = 0.6
    monsterHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    monsterHighlight.OutlineTransparency = 0

    task.spawn(function()
        while monsterBillboard.Parent and not _G.IndraHubPremiumState.stopThreads do
            pcall(function()
                local monsterHumanoid = monster:FindFirstChildWhichIsA("Humanoid")
                local healthText = ""
                if monsterHumanoid then
                    healthText = " [" .. math.round(monsterHumanoid.Health) .. "/" .. math.round(monsterHumanoid.MaxHealth) .. " HP]"
                end

                local character = state.localPlayer.Character
                local localRoot = character and character:FindFirstChild("HumanoidRootPart")
                local distanceText = ""
                if localRoot and monsterRoot then
                    distanceText = " (" .. math.round((localRoot.Position - monsterRoot.Position).Magnitude) .. "m)"
                end
                monsterLabel.Text = monsterName .. healthText .. distanceText
            end)
            task.wait(0.2)
        end
    end)

    monsterBillboard.Parent = state.coreGui
    monsterHighlight.Parent = state.coreGui
    state.espRegistry.Monster[monster] = { Billboard = monsterBillboard, Box = monsterHighlight }
end

state.clearMonsterEsp = function()
    for target, espObjects in pairs(state.espRegistry.Monster) do
        pcall(function() espObjects.Billboard:Destroy() end)
        pcall(function() espObjects.Box:Destroy() end)
    end
    table.clear(state.espRegistry.Monster)
end

state.refreshMonsterEsp = function()
    state.clearMonsterEsp()
    if not state.config.MonsterEsp then return end

    local monstersFolder = workspace.GameSystem:FindFirstChild("Monsters")
    if not monstersFolder then return end

    for _, monsterModel in ipairs(monstersFolder:GetChildren()) do
        if monsterModel:IsA("Model") then
            state.createMonsterEsp(monsterModel)
        end
    end
end

-- Player ESP
state.watchPlayerEsp = function(player)
    if not state.config.PlayerEsp then return end
    if player == state.localPlayer then return end

    local function attachPlayerEsp(playerCharacter)
        if state.espRegistry.Player[player] then
            pcall(function() state.espRegistry.Player[player].Billboard:Destroy() end)
            pcall(function() state.espRegistry.Player[player].Box:Destroy() end)
            state.espRegistry.Player[player] = nil
        end

        local playerRoot = playerCharacter:WaitForChild("HumanoidRootPart", 5) or playerCharacter:FindFirstChildWhichIsA("BasePart")
        if not playerRoot then return end

        local playerBillboard = Instance.new("BillboardGui")
        playerBillboard.Name = "IndraHubPlayerEsp"
        playerBillboard.AlwaysOnTop = true
        playerBillboard.Size = UDim2.new(0, 150, 0, 40)
        playerBillboard.StudsOffset = Vector3.new(0, 3, 0)
        playerBillboard.Adornee = playerRoot

        local playerLabel = Instance.new("TextLabel")
        playerLabel.Parent = playerBillboard
        playerLabel.Size = UDim2.new(1, 0, 1, 0)
        playerLabel.BackgroundTransparency = 1
        playerLabel.TextColor3 = Color3.fromRGB(80, 170, 240)
        playerLabel.TextStrokeTransparency = 0.2
        playerLabel.TextSize = 13
        playerLabel.Font = Enum.Font.SourceSansBold

        local playerHighlight = Instance.new("Highlight")
        playerHighlight.Name = "IndraHubPlayerHighlight"
        playerHighlight.Adornee = playerCharacter
        playerHighlight.FillColor = Color3.fromRGB(80, 170, 240)
        playerHighlight.FillTransparency = 0.6
        playerHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        playerHighlight.OutlineTransparency = 0

        task.spawn(function()
            while playerBillboard.Parent and not _G.IndraHubPremiumState.stopThreads do
                pcall(function()
                    local playerHumanoid = playerCharacter:FindFirstChildWhichIsA("Humanoid")
                    local healthText = ""
                    if playerHumanoid then
                        healthText = " [" .. math.round(playerHumanoid.Health) .. "/" .. math.round(playerHumanoid.MaxHealth) .. " HP]"
                    end

                    local character = state.localPlayer.Character
                    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
                    local distanceText = ""
                    if localRoot and playerRoot then
                        distanceText = " (" .. math.round((localRoot.Position - playerRoot.Position).Magnitude) .. "m)"
                    end
                    playerLabel.Text = player.DisplayName .. healthText .. distanceText
                end)
                task.wait(0.2)
            end
        end)

        playerBillboard.Parent = state.coreGui
        playerHighlight.Parent = state.coreGui
        state.espRegistry.Player[player] = { Billboard = playerBillboard, Box = playerHighlight }
    end

    if player.Character then
        task.spawn(function() attachPlayerEsp(player.Character) end)
    end

    player.CharacterAdded:Connect(function(character)
        if state.config.PlayerEsp then
            task.spawn(function() attachPlayerEsp(character) end)
        end
    end)
end

state.clearPlayerEsp = function()
    for target, espObjects in pairs(state.espRegistry.Player) do
        pcall(function() espObjects.Billboard:Destroy() end)
        pcall(function() espObjects.Box:Destroy() end)
    end
    table.clear(state.espRegistry.Player)
end

state.refreshPlayerEsp = function()
    state.clearPlayerEsp()
    if not state.config.PlayerEsp then return end

    for _, player in ipairs(state.playersService:GetPlayers()) do
        state.watchPlayerEsp(player)
    end
end

-- Container ESP
state.createContainerEsp = function(container)
    if not state.config.ContainerEsp then return end
    if state.espRegistry.Container[container] then return end

    local containerName = container.Name
    if container:GetAttribute("Looted") or container:GetAttribute("Open") then
        return
    end

    local containerRoot = container.PrimaryPart or container:FindFirstChildWhichIsA("BasePart")
    if not containerRoot then return end

    local containerBillboard = Instance.new("BillboardGui")
    containerBillboard.Name = "IndraHubContainerEsp"
    containerBillboard.AlwaysOnTop = true
    containerBillboard.Size = UDim2.new(0, 150, 0, 40)
    containerBillboard.StudsOffset = Vector3.new(0, 2, 0)
    containerBillboard.Adornee = containerRoot

    local containerLabel = Instance.new("TextLabel")
    containerLabel.Parent = containerBillboard
    containerLabel.Size = UDim2.new(1, 0, 1, 0)
    containerLabel.BackgroundTransparency = 1
    containerLabel.TextColor3 = Color3.fromRGB(150, 220, 220)
    containerLabel.TextStrokeTransparency = 0.2
    containerLabel.TextSize = 13
    containerLabel.Font = Enum.Font.SourceSansBold

    local containerHighlight = Instance.new("Highlight")
    containerHighlight.Name = "IndraHubContainerHighlight"
    containerHighlight.Adornee = container
    containerHighlight.FillColor = Color3.fromRGB(150, 220, 220)
    containerHighlight.FillTransparency = 0.6
    containerHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    containerHighlight.OutlineTransparency = 0

    task.spawn(function()
        while containerBillboard.Parent and not _G.IndraHubPremiumState.stopThreads do
            pcall(function()
                if container:GetAttribute("Looted") or container:GetAttribute("Open") then
                    containerBillboard:Destroy()
                    containerHighlight:Destroy()
                    state.espRegistry.Container[container] = nil
                    return
                end

                local character = state.localPlayer.Character
                local localRoot = character and character:FindFirstChild("HumanoidRootPart")
                local distanceText = ""
                if localRoot and containerRoot then
                    distanceText = " (" .. math.round((localRoot.Position - containerRoot.Position).Magnitude) .. "m)"
                end
                containerLabel.Text = containerName .. distanceText
            end)
            task.wait(0.3)
        end
    end)

    containerBillboard.Parent = state.coreGui
    containerHighlight.Parent = state.coreGui
    state.espRegistry.Container[container] = { Billboard = containerBillboard, Box = containerHighlight }
end

state.clearContainerEsp = function()
    for target, espObjects in pairs(state.espRegistry.Container) do
        pcall(function() espObjects.Billboard:Destroy() end)
        pcall(function() espObjects.Box:Destroy() end)
    end
    table.clear(state.espRegistry.Container)
end

state.refreshContainerEsp = function()
    state.clearContainerEsp()
    if not state.config.ContainerEsp then return end

    local containersFolder = workspace.GameSystem:FindFirstChild("InteractiveItem")
    if not containersFolder then return end

    for _, containerModel in ipairs(containersFolder:GetChildren()) do
        if containerModel:IsA("Model") then
            state.createContainerEsp(containerModel)
        end
    end
end

-- ESP Listeners
state.espConnections = {}
state.setupEspListeners = function()
    local lootsFolder = workspace.GameSystem:FindFirstChild("Loots")
    local monstersFolder = workspace.GameSystem:FindFirstChild("Monsters")
    local containersFolder = workspace.GameSystem:FindFirstChild("InteractiveItem")

    if lootsFolder then
        local function connectLootFolder(folder)
            if not folder then return end
            table.insert(state.espConnections, folder.ChildAdded:Connect(function(addedItem)
                task.spawn(function()
                    task.wait(0.2)
                    if addedItem.Parent then state.createLootEsp(addedItem) end
                end)
            end))
            table.insert(state.espConnections, folder.ChildRemoved:Connect(function(removedItem)
                if state.espRegistry.Loot[removedItem] then
                    pcall(function() state.espRegistry.Loot[removedItem].Billboard:Destroy() end)
                    pcall(function() state.espRegistry.Loot[removedItem].Box:Destroy() end)
                    state.espRegistry.Loot[removedItem] = nil
                end
            end))
        end
        connectLootFolder(lootsFolder:FindFirstChild("World"))
        connectLootFolder(lootsFolder:FindFirstChild("Player"))
    end

    if monstersFolder then
        table.insert(state.espConnections, monstersFolder.ChildAdded:Connect(function(addedMonster)
            task.spawn(function()
                task.wait(0.2)
                if addedMonster.Parent then state.createMonsterEsp(addedMonster) end
            end)
        end))
        table.insert(state.espConnections, monstersFolder.ChildRemoved:Connect(function(removedMonster)
            if state.espRegistry.Monster[removedMonster] then
                pcall(function() state.espRegistry.Monster[removedMonster].Billboard:Destroy() end)
                pcall(function() state.espRegistry.Monster[removedMonster].Box:Destroy() end)
                state.espRegistry.Monster[removedMonster] = nil
            end
        end))
    end

    if containersFolder then
        table.insert(state.espConnections, containersFolder.ChildAdded:Connect(function(addedContainer)
            task.spawn(function()
                task.wait(0.2)
                if addedContainer.Parent then state.createContainerEsp(addedContainer) end
            end)
        end))
        table.insert(state.espConnections, containersFolder.ChildRemoved:Connect(function(removedContainer)
            if state.espRegistry.Container[removedContainer] then
                pcall(function() state.espRegistry.Container[removedContainer].Billboard:Destroy() end)
                pcall(function() state.espRegistry.Container[removedContainer].Box:Destroy() end)
                state.espRegistry.Container[removedContainer] = nil
            end
        end))
    end

    table.insert(state.espConnections, state.playersService.PlayerAdded:Connect(function(player)
        state.watchPlayerEsp(player)
    end))
    table.insert(state.espConnections, state.playersService.PlayerRemoving:Connect(function(player)
        if state.espRegistry.Player[player] then
            pcall(function() state.espRegistry.Player[player].Billboard:Destroy() end)
            pcall(function() state.espRegistry.Player[player].Box:Destroy() end)
            state.espRegistry.Player[player] = nil
        end
    end))

    table.insert(state.espConnections, state.localPlayer.CharacterAdded:Connect(function(character)
        task.spawn(function()
            local rootPart = character:WaitForChild("HumanoidRootPart", 10)
            if rootPart then state.returnCFrame = rootPart.CFrame end
        end)
    end))
end

state.disconnectEspListeners = function()
    for _, connection in ipairs(state.espConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(state.espConnections)
end

-- Initialize listeners
state.setupEspListeners()

-- Global cleanup function for double execution safety
_G.IndraHubPremiumState.cleanAll = function()
    state.disconnectEspListeners()
    state.clearLootEsp()
    state.clearMonsterEsp()
    state.clearPlayerEsp()
    state.clearContainerEsp()
end

-- 6. Auto Take Ground Loot Loop
task.spawn(function()
    while not _G.IndraHubPremiumState.stopThreads and _G.IndraHubPremiumState.ScriptInstanceId == state.scriptInstanceId do
        task.wait(0.3)
        if state.config.AutoTakeItem and state.network then
            pcall(function()
                local character = state.localPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                -- Check backpack capacity initially (if full, go back to base and pause)
                pcall(function()
                    local playerStateModule = require(state.replicatedStorage[0][0][0])
                    local playerState = playerStateModule.Value
                    local backpackState = playerState and playerState.Backpack
                    if backpackState and backpackState.count and backpackState.size and backpackState.count >= backpackState.size then
                        if not state.returnCFrame then
                            state.returnCFrame = rootPart.CFrame
                        end
                        if state.returnCFrame then
                            rootPart.CFrame = state.returnCFrame
                        end
                        task.wait(2)
                        while playerState.Backpack and playerState.Backpack.count and playerState.Backpack.size and playerState.Backpack.count >= playerState.Backpack.size and state.config.AutoTakeItem and not _G.IndraHubPremiumState.stopThreads do
                            task.wait(1)
                        end
                    end
                end)

                local lootCandidates = {}
                local lootsFolder = workspace.GameSystem:FindFirstChild("Loots")
                if lootsFolder then
                    local worldLootFolder = lootsFolder:FindFirstChild("World")
                    local playerLootFolder = lootsFolder:FindFirstChild("Player")
                    if worldLootFolder then
                        for _, item in ipairs(worldLootFolder:GetChildren()) do table.insert(lootCandidates, item) end
                    end
                    if playerLootFolder then
                        for _, item in ipairs(playerLootFolder:GetChildren()) do table.insert(lootCandidates, item) end
                    end
                end

                for _, item in ipairs(lootCandidates) do
                    -- Double check capacity before taking each item
                    local isBackpackFull = false
                    pcall(function()
                        local playerStateModule = require(state.replicatedStorage[0][0][0])
                        local playerState = playerStateModule.Value
                        local backpackState = playerState and playerState.Backpack
                        if backpackState and backpackState.count and backpackState.size and backpackState.count >= backpackState.size then
                            isBackpackFull = true
                            if not state.returnCFrame then
                                state.returnCFrame = rootPart.CFrame
                            end
                            if state.returnCFrame then
                                rootPart.CFrame = state.returnCFrame
                            end
                            task.wait(2)
                            while playerState.Backpack and playerState.Backpack.count and playerState.Backpack.size and playerState.Backpack.count >= playerState.Backpack.size and state.config.AutoTakeItem and not _G.IndraHubPremiumState.stopThreads do
                                task.wait(1)
                            end
                        end
                    end)
                    if isBackpackFull then
                        break -- Exit item loop immediately to prevent further teleports
                    end

                    if item:IsA("Model") or item:IsA("Tool") then
                        local itemId = item:GetAttribute("id")
                        local isPriorityLoot = state.priorityLootIds[itemId]
                        local itemPrice = 0
                        local lootUi = item:FindFirstChild("LootUI", true)
                        if lootUi then
                            local priceLabel = lootUi:FindFirstChild("Price", true)
                            if priceLabel then
                                itemPrice = tonumber(priceLabel.Text:match("%d+")) or 0
                            end
                        end

                        if itemPrice >= state.config.MinLootPrice or isPriorityLoot then
                            -- Teleport-pickup
                            local originalCFrame = rootPart.CFrame
                            rootPart.CFrame = item:GetPivot()
                            task.wait(0.1)
                            state.network.FireRemote("Interactable", item)
                            task.wait(0.1)
                            rootPart.CFrame = originalCFrame
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Auto Open Containers Loop
task.spawn(function()
    while not _G.IndraHubPremiumState.stopThreads and _G.IndraHubPremiumState.ScriptInstanceId == state.scriptInstanceId do
        task.wait(0.5)
        if state.config.AutoOpenContainers and state.network then
            pcall(function()
                local character = state.localPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                local containersFolder = workspace.GameSystem:FindFirstChild("InteractiveItem")
                if containersFolder then
                    for _, container in ipairs(containersFolder:GetChildren()) do
                        if container:IsA("Model") and not container:GetAttribute("Looted") and not container:GetAttribute("Open") then
                            local originalCFrame = rootPart.CFrame
                            rootPart.CFrame = container:GetPivot() * CFrame.new(0, 0, 2)
                            task.wait(0.15)
                            state.network.FireRemote("Interactable", container)
                            state.network.FireRemote("Interactable", container)
                            task.wait(0.2)
                            rootPart.CFrame = originalCFrame
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end
end)

-- 8. Kill Aura Loop
task.spawn(function()
    while not _G.IndraHubPremiumState.stopThreads and _G.IndraHubPremiumState.ScriptInstanceId == state.scriptInstanceId do
        task.wait(0.15)
        if state.config.KillAura and state.network then
            pcall(function()
                local character = state.localPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                local playerStateModule = require(state.replicatedStorage[0][0][0])
                local playerState = playerStateModule.GetLocalReplica()
                local equippedItem = playerState and playerState.Hotbar.Items.cur
                if not equippedItem or not equippedItem.uid then return end

                local monstersFolder = workspace.GameSystem:FindFirstChild("Monsters")
                if monstersFolder then
                    for _, monster in ipairs(monstersFolder:GetChildren()) do
                        if monster:IsA("Model") then
                            local monsterRoot = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                            local monsterHumanoid = monster:FindFirstChildWhichIsA("Humanoid")

                            if monsterRoot and (not monsterHumanoid or monsterHumanoid.Health > 0) then
                                local distance = (rootPart.Position - monsterRoot.Position).Magnitude
                                if distance < 20 then
                                    -- Face the target
                                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, monsterRoot.Position)

                                    -- Perform attack based on weapon type
                                    if equippedItem.id == 10241 then -- Z-Ray Gun
                                        state.network.FireRemote("UseTool", equippedItem.uid, monster, state.network.UnixTimeFloat())
                                    else -- Melee (Baseball Bat, etc.)
                                        state.network.FireRemote("UseTool", equippedItem.uid, state.network.UnixTimeFloat())
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

-- ============================================================
-- UI LIBRARY (NATIVE WINDUI)
-- ============================================================
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI then
    warn("Failed to load WindUI!")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Deadly Delivery",
    Icon = "box",
    Author = "IndraHub",
    Folder = "IndraHub_DeadlyDelivery",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

-- Keep track of the WindUI GUI instance for the watchdog
_G.IndraHubPremiumState.UI = game:GetService("CoreGui"):FindFirstChild("WindUI") or game:GetService("CoreGui"):FindFirstChild("Window") or nil

-- Tabs
local MainTab = Window:Tab({ Title = "Main", Icon = "zap" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

-- =============================================================
-- 1. Main Tab
-- =============================================================
MainTab:Button({ Title = " Auto Farm ", Callback = function() end })
MainTab:Toggle({
    Title = "Auto Take Item (Loot Ground)",
    Default = false,
    Callback = function(enabled)
        state.config.AutoTakeItem = enabled
    end
})
MainTab:Toggle({
    Title = "Auto Open Containers (Fridge/Chest)",
    Default = false,
    Callback = function(enabled)
        state.config.AutoOpenContainers = enabled
    end
})

MainTab:Button({ Title = " Combat ", Callback = function() end })
MainTab:Toggle({
    Title = "Kill Aura (Auto Attack)",
    Default = false,
    Callback = function(enabled)
        state.config.KillAura = enabled
    end
})

-- =============================================================
-- 2. Visuals Tab
-- =============================================================
VisualsTab:Button({ Title = " ESP ", Callback = function() end })
VisualsTab:Toggle({
    Title = "Loot ESP",
    Default = false,
    Callback = function(enabled)
        state.config.LootEsp = enabled
        state.refreshLootEsp()
    end
})
VisualsTab:Toggle({
    Title = "Monster ESP",
    Default = false,
    Callback = function(enabled)
        state.config.MonsterEsp = enabled
        state.refreshMonsterEsp()
    end
})
VisualsTab:Toggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(enabled)
        state.config.PlayerEsp = enabled
        state.refreshPlayerEsp()
    end
})
VisualsTab:Toggle({
    Title = "Container ESP",
    Default = false,
    Callback = function(enabled)
        state.config.ContainerEsp = enabled
        state.refreshContainerEsp()
    end
})
VisualsTab:Slider({
    Title = "Min Loot Price",
    Min = 0,
    Max = 1000,
    Default = 0,
    Callback = function(value)
        state.config.MinLootPrice = value
        state.refreshLootEsp()
    end
})

VisualsTab:Button({ Title = " Environment ", Callback = function() end })
VisualsTab:Toggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(enabled)
        state.config.Fullbright = enabled
        if enabled then
            state.applyFullbright()
        end
    end
})

-- =============================================================
-- 3. Misc Tab
-- =============================================================
MiscTab:Button({ Title = " Player Movement ", Callback = function() end })
MiscTab:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(enabled)
        state.config.SpeedHack = enabled
        if not enabled then
            pcall(function()
                local buffTypes = require(state.replicatedStorage.Shared.Features.Buff.BuffType)
                buffTypes.WalkSpeed.Changed:Fire(nil, 0, 1)
            end)
        else
            state.applySpeed()
        end
    end
})
MiscTab:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 25,
    Callback = function(value)
        state.config.SpeedValue = value
        if state.config.SpeedHack then
            state.applySpeed()
        end
    end
})
MiscTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(enabled)
        state.config.Noclip = enabled
        if not enabled then
            pcall(function()
                local character = state.localPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then rootPart.CanCollide = true end
                    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                    if torso then torso.CanCollide = true end
                    local head = character:FindFirstChild("Head")
                    if head then head.CanCollide = true end
                end
            end)
        end
    end
})
MiscTab:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(enabled)
        state.config.InfiniteStamina = enabled
        pcall(function()
            local buffTypes = require(state.replicatedStorage.Shared.Features.Buff.BuffType)
            if enabled then
                buffTypes.StaminaInfinite.Changed:Fire(nil, 1)
            else
                buffTypes.StaminaInfinite.Changed:Fire(nil, 0)
            end
        end)
    end
})

-- =============================================================
-- 4. Info Tab
-- =============================================================
InfoTab:Button({ Title = " About ", Callback = function() end })
InfoTab:Button({ Title = "IndraHub - Deadly Delivery", Callback = function() end })

InfoTab:Button({ Title = " Project Info ", Callback = function() end })
InfoTab:Button({ Title = "Advanced script automation platform", Callback = function() end })
InfoTab:Button({ Title = "Built for performance, stealth & reliability", Callback = function() end })

InfoTab:Button({ Title = " Links ", Callback = function() end })
InfoTab:Button({ Title = "Portal: indrahub.com (coming soon)", Callback = function() end })
InfoTab:Button({ Title = "Discord: join for updates & support", Callback = function() end })

-- =============================================================
-- UI Watchdog (Auto-disable all features if UI is closed/destroyed)
-- =============================================================
state.uiWatchdogConnection = nil

task.spawn(function()
    -- Wait a moment to ensure WindUI is parented to CoreGui
    task.wait(2)
    local screenGui = nil
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:match("WindUI") or gui:FindFirstChild("Main")) then
            screenGui = gui
            break
        end
    end
    _G.IndraHubPremiumState.UI = screenGui
    
    while not _G.IndraHubPremiumState.stopThreads and _G.IndraHubPremiumState.ScriptInstanceId == state.scriptInstanceId do
        task.wait(0.5)
        local uiAlive = false
        pcall(function()
            if screenGui and screenGui.Parent then uiAlive = true end
        end)
        
        -- If WindUI was detected but is now gone, trigger cleanup
        if screenGui and not uiAlive then
            _G.IndraHubPremiumState.stopThreads = true

            if noclipConnection then noclipConnection:Disconnect() end
            if state.uiWatchdogConnection then state.uiWatchdogConnection:Disconnect() end
            state.disconnectEspListeners()
            state.clearLootEsp()
            state.clearMonsterEsp()
            state.clearPlayerEsp()
            state.clearContainerEsp()
            if state.fullbrightConnection then state.fullbrightConnection:Disconnect() end

            -- Reset character speed & stamina
            pcall(function()
                local buffTypes = require(state.replicatedStorage.Shared.Features.Buff.BuffType)
                buffTypes.WalkSpeed.Changed:Fire(nil, 0, 1)
                buffTypes.StaminaInfinite.Changed:Fire(nil, 0)
            end)
            pcall(function()
                local character = state.localPlayer.Character
                local equippedTool = character and character:FindFirstChildOfClass("Tool")
                if equippedTool then equippedTool:Deactivate() end
            end)

            break
        end
    end
end)

-- =============================================================
-- SUPERVISOR HEARTBEAT
-- =============================================================
_G.IndraHubDeadlyDeliveryRunning = true
local RunService = game:GetService("RunService")
state.supervisorHeartbeatConnection = RunService.Heartbeat:Connect(function()
    _G.IndraHubDeadlyDeliveryLastHeartbeat = os.clock()
    if _G.IndraHubPremiumState.stopThreads then
        if state.supervisorHeartbeatConnection then
            state.supervisorHeartbeatConnection:Disconnect()
        end
        _G.IndraHubDeadlyDeliveryRunning = false
    end
end)
