local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = getgenv and getgenv() or _G

local settings = {
    monitorVitals = true,
    monitorNetwork = false,
    proximityTags = true,
    showTagNames = true,
    showTagHealth = true,
    tagRange = 35,
    lowEnergyAt = 30,
    energyProbeRate = 0.1,
    worldProbeRate = 2,
}

local palette = {
    text = Color3.fromRGB(235, 240, 255),
    warning = Color3.fromRGB(255, 86, 86),
    rail = Color3.fromRGB(18, 22, 31),
    fill = Color3.fromRGB(116, 211, 255),
}

local function parentGui(gui)
    local ok, core = pcall(game.GetService, game, "CoreGui")
    gui.Parent = ok and core or player:WaitForChild("PlayerGui", 5)
end

local overlay = Instance.new("ScreenGui")
overlay.Name = "IndraHub_ReconOverlay"
overlay.ResetOnSpawn = false
parentGui(overlay)

local function windui()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end

local okUi, WindUI = pcall(windui)
if not okUi or type(WindUI) ~= "table" then
    warn("[IndraHub Recon] WindUI load failed: " .. tostring(WindUI))
    return
end

shared.IndraHubReconWindUI = WindUI
if shared.IndraHubReconWindow then pcall(function() shared.IndraHubReconWindow:Destroy() end) end

local function toast(title, body, icon)
    if type(WindUI.Notify) == "function" then
        pcall(function() WindUI:Notify({Title = title, Content = body, Icon = icon or "info", Duration = 3}) end)
    else
        print("[IndraHub Recon] " .. tostring(title) .. ": " .. tostring(body))
    end
end

local window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "radar",
    Author = "Recon HUD",
    Folder = "IndraHubRecon",
    Size = UDim2.fromOffset(575, 430),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 168,
})
shared.IndraHubReconWindow = window
if window.SetToggleKey then window:SetToggleKey(Enum.KeyCode.RightControl) end
if window.EditOpenButton then window:EditOpenButton({Title = "IndraHub", Icon = "radar", Draggable = true}) end

local tab = {
    status = window:Tab({Title = "Status", Icon = "activity"}),
    recon = window:Tab({Title = "Recon", Icon = "scan-eye"}),
    tuning = window:Tab({Title = "Tuning", Icon = "sliders-horizontal"}),
    about = window:Tab({Title = "About", Icon = "info"}),
}

local vitals = {
    humanoid = nil,
    root = nil,
    staminaSource = nil,
    staminaKind = nil,
    hp = "HP: ...",
    stamina = "STAMINA: ...",
    runtime = "00:00:00 | 0 FPS | 0ms",
}

local markers = {}

local function disconnectAll(list)
    for _, connection in ipairs(list) do
        pcall(function() connection:Disconnect() end)
    end
end

local function markerVisible(record)
    return settings.proximityTags and record.near == true
end

local function styleMarker(record)
    if record.name then record.name.Visible = settings.showTagNames end
    if record.bar then
        record.bar.Visible = settings.showTagHealth
        record.bar.Position = UDim2.new(0, 0, 0, settings.showTagNames and 17 or 7)
    end
    record.gui.Enabled = markerVisible(record)
end

local function removeMarker(model)
    local record = markers[model]
    if not record then return end
    disconnectAll(record.links)
    pcall(function() record.gui:Destroy() end)
    markers[model] = nil
end

local function updateHealthStrip(record)
    if not record.fill or not record.humanoid then return end
    local maxHealth = record.humanoid.MaxHealth
    local percent = maxHealth > 0 and math.clamp(record.humanoid.Health / maxHealth, 0, 1) or 0
    record.fill.Size = UDim2.new(percent, 0, 1, 0)
    record.fill.BackgroundColor3 = palette.warning:Lerp(palette.fill, percent)
end

local function trackModel(model)
    if markers[model] or model == player.Character then return end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local anchor = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    if not humanoid or not anchor then return end

    local gui = Instance.new("BillboardGui")
    gui.Adornee = anchor
    gui.Size = UDim2.fromOffset(132, 38)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 3.25, 0)
    gui.LightInfluence = 0
    gui.AlwaysOnTop = false
    gui.Enabled = false
    gui.Parent = overlay

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = palette.text
    label.TextStrokeTransparency = 0.15
    label.Text = humanoid.DisplayName ~= "" and humanoid.DisplayName or model.Name
    label.Parent = gui

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.BackgroundColor3 = palette.rail
    bar.BorderSizePixel = 0
    bar.Parent = gui

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = palette.fill
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local record = {model = model, humanoid = humanoid, anchor = anchor, gui = gui, name = label, bar = bar, fill = fill, near = false, links = {}}
    markers[model] = record

    table.insert(record.links, humanoid:GetPropertyChangedSignal("Health"):Connect(function() updateHealthStrip(record) end))
    table.insert(record.links, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function() updateHealthStrip(record) end))
    table.insert(record.links, humanoid.Died:Connect(function() task.delay(1, function() removeMarker(model) end) end))
    table.insert(record.links, model.AncestryChanged:Connect(function(_, parent) if not parent then removeMarker(model) end end))

    updateHealthStrip(record)
    styleMarker(record)
end

local function sweepWorld()
    task.spawn(function()
        local visited = 0
        for _, item in ipairs(Workspace:GetChildren()) do
            trackModel(item)
            visited = visited + 1
            if visited % 35 == 0 then task.wait() end

            local canInspect = item:IsA("Folder") or item:IsA("Model")
            local blocked = item.Name == "Map" or item.Name == "Terrain" or item.Name == "Geometry"
            if canInspect and not blocked then
                for _, child in ipairs(item:GetChildren()) do
                    trackModel(child)
                    visited = visited + 1
                    if visited % 35 == 0 then task.wait() end
                end
            end
        end
    end)
end

local function locateEnergy()
    local character = player.Character
    if not character then return end

    local holders = {character:FindFirstChild("Stats"), character:FindFirstChild("Data"), character:FindFirstChild("Folder"), character}
    for _, holder in ipairs(holders) do
        if holder then
            local candidate = holder:FindFirstChild("Stamina") or holder:FindFirstChild("stamina") or holder:FindFirstChild("Energy")
            if candidate and candidate:IsA("ValueObject") then
                vitals.staminaSource = candidate
                vitals.staminaKind = "value"
                return
            end
        end
    end

    if character:GetAttribute("Stamina") ~= nil then
        vitals.staminaSource = character
        vitals.staminaKind = "characterAttribute"
    elseif player:GetAttribute("Stamina") ~= nil then
        vitals.staminaSource = player
        vitals.staminaKind = "playerAttribute"
    end
end

local function readEnergy()
    if not vitals.staminaSource then return nil end
    local ok, value = pcall(function()
        if vitals.staminaKind == "value" then return vitals.staminaSource.Value end
        return vitals.staminaSource:GetAttribute("Stamina")
    end)
    return ok and value or nil
end

local function bindAvatar(character)
    vitals.humanoid = character:WaitForChild("Humanoid", 3)
    vitals.root = character:FindFirstChild("HumanoidRootPart")
    vitals.staminaSource = nil
    vitals.staminaKind = nil

    if not vitals.humanoid then
        vitals.hp = "HP: unavailable"
        return
    end

    local function refreshHp()
        vitals.hp = string.format("HP: %.0f / %.0f", vitals.humanoid.Health, vitals.humanoid.MaxHealth)
    end
    vitals.humanoid:GetPropertyChangedSignal("Health"):Connect(refreshHp)
    vitals.humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refreshHp)
    refreshHp()
end

local function applyMarkerVisibility()
    for _, record in pairs(markers) do styleMarker(record) end
end

tab.status:Section({Title = "Live Readout", Icon = "activity"})
tab.status:Toggle({
    Title = "Vitals Monitor",
    Desc = "Updates health and stamina readouts.",
    Value = settings.monitorVitals,
    Callback = function(value) settings.monitorVitals = value end,
})
tab.status:Toggle({
    Title = "Network Readout",
    Desc = "Tracks clock, FPS, and ping.",
    Value = settings.monitorNetwork,
    Callback = function(value) settings.monitorNetwork = value end,
})
tab.status:Button({
    Title = "Send Readout",
    Callback = function()
        local line = vitals.hp .. " | " .. vitals.stamina .. " | " .. vitals.runtime
        print("[IndraHub Recon] " .. line)
        toast("Readout", line, "activity")
    end,
})

tab.recon:Section({Title = "Proximity Tags", Icon = "scan-eye"})
tab.recon:Toggle({
    Title = "Enable Tags",
    Desc = "Nearby humanoid models get compact world labels.",
    Value = settings.proximityTags,
    Callback = function(value)
        settings.proximityTags = value
        if value then sweepWorld() end
        applyMarkerVisibility()
    end,
})
tab.recon:Toggle({Title = "Names", Value = settings.showTagNames, Callback = function(value) settings.showTagNames = value; applyMarkerVisibility() end})
tab.recon:Toggle({Title = "Health Bars", Value = settings.showTagHealth, Callback = function(value) settings.showTagHealth = value; applyMarkerVisibility() end})
tab.recon:Button({Title = "Refresh Tags", Callback = function() sweepWorld(); toast("Recon", "Refresh started", "search") end})
tab.recon:Button({
    Title = "Remove Tags",
    Callback = function()
        for model in pairs(markers) do removeMarker(model) end
        toast("Recon", "Tags removed", "trash")
    end,
})

tab.tuning:Slider({
    Title = "Tag Range",
    Desc = "Maximum distance for world labels.",
    Value = {Min = 10, Max = 150, Default = settings.tagRange},
    Step = 1,
    Callback = function(value) settings.tagRange = tonumber(value) or settings.tagRange end,
})
tab.tuning:Slider({
    Title = "Low Stamina Line",
    Value = {Min = 1, Max = 100, Default = settings.lowEnergyAt},
    Step = 1,
    Callback = function(value) settings.lowEnergyAt = tonumber(value) or settings.lowEnergyAt end,
})

tab.about:Section({Title = "IndraHub Recon HUD", Icon = "radar"})
tab.about:Section({Title = "WindUI controls with independent world-space tags", Icon = "scan-eye"})
tab.about:Section({Title = "RightControl toggles the window", Icon = "keyboard"})

if player.Character then bindAvatar(player.Character) end
player.CharacterAdded:Connect(bindAvatar)
player.CharacterRemoving:Connect(function()
    vitals.humanoid = nil
    vitals.root = nil
    vitals.staminaSource = nil
    vitals.staminaKind = nil
end)

sweepWorld()

local cadence = {energy = 0, sweep = 0, range = 0, runtime = 0, frames = 0}
RunService.Heartbeat:Connect(function(dt)
    cadence.frames = cadence.frames + 1

    cadence.runtime = cadence.runtime + dt
    if settings.monitorNetwork and cadence.runtime >= 3 then
        local fps = math.floor(cadence.frames / cadence.runtime)
        local ping = 0
        pcall(function() if player.GetNetworkPing then ping = math.floor(player:GetNetworkPing() * 1000) end end)
        local clock = "00:00:00"
        pcall(function() clock = os.date("%H:%M:%S") end)
        vitals.runtime = string.format("%s | %d FPS | %dms", clock, fps, ping)
        cadence.runtime = 0
        cadence.frames = 0
    elseif not settings.monitorNetwork and cadence.runtime >= 3 then
        cadence.runtime = 0
        cadence.frames = 0
    end

    cadence.energy = cadence.energy + dt
    if settings.monitorVitals and cadence.energy >= settings.energyProbeRate then
        cadence.energy = 0
        if not vitals.staminaSource then locateEnergy() end
        local energy = readEnergy()
        if energy == nil then
            vitals.staminaSource = nil
            vitals.staminaKind = nil
            vitals.stamina = "STAMINA: scanning"
        else
            vitals.stamina = string.format("STAMINA: %.0f%s", energy, energy < settings.lowEnergyAt and " LOW" or "")
        end
    end

    cadence.sweep = cadence.sweep + dt
    if settings.proximityTags and cadence.sweep >= settings.worldProbeRate then
        cadence.sweep = 0
        sweepWorld()
    end

    cadence.range = cadence.range + dt
    if settings.proximityTags and vitals.root and cadence.range >= 0.15 then
        cadence.range = 0
        local origin = vitals.root.Position
        local limit = settings.tagRange * settings.tagRange
        for _, record in pairs(markers) do
            if record.anchor and record.anchor:IsDescendantOf(Workspace) then
                local offset = record.anchor.Position - origin
                record.near = offset.X ^ 2 + offset.Y ^ 2 + offset.Z ^ 2 <= limit
                record.gui.Enabled = markerVisible(record)
            else
                record.gui.Enabled = false
            end
        end
    elseif not settings.proximityTags then
        for _, record in pairs(markers) do record.gui.Enabled = false end
    end
end)

toast("IndraHub", "Recon HUD loaded", "radar")
