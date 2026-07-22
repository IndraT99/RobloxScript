local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Initialize WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "swords",
    Author = "IndraHub Studio",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

local DemonTab = Window:Tab({ Title = "Demon Auto", Icon = "skull" })
local TPTab = Window:Tab({ Title = "Teleports", Icon = "map-pin" })

-- DISCORD SECTION
MainTab:Section({ Title = "Information" })
MainTab:Button({
    Title = "Copy Discord Link",
    Desc = "Join our community for updates!",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({
            Title = "IndraHub",
            Content = "Discord link copied to clipboard!",
            Duration = 3
        })
    end
})

-- STATE
local Config = {
    ESPHumans = false,
    ESPDemons = false,
    HumanPriority1 = "Cash",
    HumanPriority2 = "Door",
    HumanPriority3 = "Turret",
    DemonPriority1 = "Attack",
    DemonPriority2 = "HP",
    DemonPriority3 = "Lucky",
    TargetWeapon = "M4A1",
    HumanAuto = false,
    AutoAirdrop = false,
    MaxLootBoxId = 10,
    AutoDecompose = false,
    AutoRepair = false,
}

-- ESP SYSTEM
local ESPCache = {}

local function createESP(player)
    if ESPCache[player] then return ESPCache[player] end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Visible = false
    
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Distance.Size = 14
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Visible = false
    
    ESPCache[player] = esp
    return esp
end

local function removeESP(player)
    if ESPCache[player] then
        for _, draw in pairs(ESPCache[player]) do
            draw:Remove()
        end
        ESPCache[player] = nil
    end
end

local ManualDemons = {}

local function isDemon(player)
    -- 1. Manual Override
    if ManualDemons[player.Name] then return true end
    
    local char = player.Character
    if not char then return false end
    
    -- 2. Check Health (Demons usually have boss-level health, humans have 100)
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.MaxHealth > 150 then
        return true
    end
    
    -- 3. Check Character Name (Sometimes renamed to "Hunter" or something custom)
    if string.match(string.lower(char.Name), "hunter") or string.match(string.lower(char.Name), "demon") then
        return true
    end
    
    -- 4. Check for Hunter-specific tools or items
    local function checkInventory(container)
        if not container then return false end
        for _, item in pairs(container:GetChildren()) do
            local itemName = string.lower(item.Name)
            if string.match(itemName, "hunter") or string.match(itemName, "monster") or string.match(itemName, "claw") or string.match(itemName, "demon") then
                return true
            end
        end
        return false
    end
    
    if checkInventory(player:FindFirstChild("Backpack")) or checkInventory(char) then
        return true
    end

    -- 5. Heuristic checks on Player and Character Attributes/Values
    local function checkRole(obj)
        if not obj then return false end
        for k, v in pairs(obj:GetAttributes()) do
            local val = string.lower(tostring(v))
            if val == "hunter" or val == "demon" or val == "monster" then return true end
        end
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("StringValue") then
                local val = string.lower(child.Value)
                if val == "hunter" or val == "demon" or val == "monster" then return true end
            end
            if child:IsA("BoolValue") and child.Value == true then
                local name = string.lower(child.Name)
                if name == "ishunter" or name == "isdemon" then return true end
            end
        end
        return false
    end

    if checkRole(player) or checkRole(char) then return true end
    
    return false
end

RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local esp = createESP(player)
                
                local isDemonPlayer = isDemon(player)
                local showESP = (isDemonPlayer and Config.ESPDemons) or (not isDemonPlayer and Config.ESPHumans)
                
                if showESP then
                    local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local distance = (camera.CFrame.Position - hrp.Position).Magnitude
                        local color = isDemonPlayer and Color3.new(1, 0.2, 0.2) or Color3.new(0.2, 1, 0.2)
                        
                        -- Scale based on distance
                        local size = Vector2.new(2000 / distance, 3000 / distance)
                        
                        esp.Box.Size = size
                        esp.Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                        esp.Box.Color = color
                        esp.Box.Visible = true
                        
                        esp.Name.Text = player.Name .. (isDemonPlayer and " [DEMON]" or " [HUMAN]")
                        esp.Name.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 20)
                        esp.Name.Color = color
                        esp.Name.Visible = true
                        
                        esp.Distance.Text = math.floor(distance) .. " studs"
                        esp.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 5)
                        esp.Distance.Color = Color3.new(1, 1, 1)
                        esp.Distance.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.Distance.Visible = false
                    end
                else
                    if ESPCache[player] then
                        ESPCache[player].Box.Visible = false
                        ESPCache[player].Name.Visible = false
                        ESPCache[player].Distance.Visible = false
                    end
                end
            elseif ESPCache[player] then
                ESPCache[player].Box.Visible = false
                ESPCache[player].Name.Visible = false
                ESPCache[player].Distance.Visible = false
            end
        end
    end
end)

ESPTab:Toggle({
    Title = "ESP Humans",
    Desc = "Show generic Human players",
    Default = false,
    Callback = function(state) Config.ESPHumans = state end
})

ESPTab:Toggle({
    Title = "ESP Demons",
    Desc = "Show Demon/Monster players",
    Default = false,
    Callback = function(state) Config.ESPDemons = state end
})

-- MANUAL DEMON SETUP REMOVED

-- AUTO UPGRADE REMOTE LOGIC
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local function getServiceRF(serviceName)
    local ok, rf = pcall(function()
        return ReplicatedStorage.CommonComponents.Packages.Knit.Services[serviceName].RF
    end)
    return ok and rf or nil
end

local function positiveIntegerArg(id)
    return {
        parameterType = "PositiveInteger",
        parameter = id
    }
end

local function invokePlotRemote(remoteName, id)
    local plotRF = getServiceRF("PlotService")
    local remote = plotRF and plotRF:FindFirstChild(remoteName)
    if not remote then return false end

    return pcall(function()
        remote:InvokeServer(positiveIntegerArg(id))
    end)
end
-- DEMON TAB
DemonTab:Section({ Title = "Demon Upgrades" })

DemonTab:Dropdown({
    Title = "Priority 1",
    Values = {"Attack", "HP", "Lucky"},
    Default = "Attack",
    Callback = function(val) Config.DemonPriority1 = val end
})

DemonTab:Dropdown({
    Title = "Priority 2",
    Values = {"Attack", "HP", "Lucky"},
    Default = "HP",
    Callback = function(val) Config.DemonPriority2 = val end
})

DemonTab:Dropdown({
    Title = "Priority 3",
    Values = {"Attack", "HP", "Lucky"},
    Default = "Lucky",
    Callback = function(val) Config.DemonPriority3 = val end
})

DemonTab:Toggle({
    Title = "Auto Upgrade Stats",
    Desc = "Spams upgrade remotes based on your priority",
    Default = false,
    Callback = function(state)
        Config.DemonAutoStats = state
        if state then
            task.spawn(function()
                while Config.DemonAutoStats do
                    local KnitServices = game:GetService("ReplicatedStorage"):FindFirstChild("CommonComponents") and game:GetService("ReplicatedStorage").CommonComponents.Packages.Knit.Services
                    local HunterAttrRF = KnitServices and KnitServices:FindFirstChild("HunterAttributeService") and KnitServices.HunterAttributeService:FindFirstChild("RF")
                    
                    if HunterAttrRF and HunterAttrRF:FindFirstChild("Upgrade") then
                        local priorities = {Config.DemonPriority1 or "Attack", Config.DemonPriority2 or "HP", Config.DemonPriority3 or "Lucky"}
                        for _, stat in ipairs(priorities) do
                            task.spawn(function()
                                pcall(function() HunterAttrRF.Upgrade:InvokeServer(stat) end)
                            end)
                            task.wait(0.2)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

DemonTab:Toggle({
    Title = "Auto Evolve",
    Desc = "Automatically evolves your demon when ready",
    Default = false,
    Callback = function(state)
        Config.DemonAutoEvolve = state
        if state then
            task.spawn(function()
                while Config.DemonAutoEvolve do
                    local KnitServices = game:GetService("ReplicatedStorage"):FindFirstChild("CommonComponents") and game:GetService("ReplicatedStorage").CommonComponents.Packages.Knit.Services
                    local HunterRF = KnitServices and KnitServices:FindFirstChild("HunterService") and KnitServices.HunterService:FindFirstChild("RF")
                    
                    if HunterRF and HunterRF:FindFirstChild("EvolveHunter") then
                        pcall(function() HunterRF.EvolveHunter:InvokeServer() end)
                    end
                    task.wait(2)
                end
            end)
        end
    end
})



-- TELEPORTS
local function refreshAirdrops()
    local drops = {}
    
    local function scanFolder(folderName)
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, model in pairs(folder:GetChildren()) do
                local pos = nil
                if model:IsA("Model") and model.PrimaryPart then
                    pos = model.PrimaryPart.Position
                elseif model:IsA("BasePart") then
                    pos = model.Position
                elseif model:IsA("Model") then
                    local p = model:FindFirstChildWhichIsA("BasePart", true)
                    if p then pos = p.Position end
                end
                
                -- Check if the item is staged out of bounds (underground or very high)
                if pos then
                    if pos.Y > -100 and pos.Y < 2000 then
                        table.insert(drops, model)
                    end
                else
                    table.insert(drops, model)
                end
            end
        end
    end
    
    scanFolder("AirdropFolder")
    scanFolder("DropItemFolder")
    
    return drops
end

local function getDropCFrame(drop)
    if drop:IsA("BasePart") then
        return drop.CFrame
    end
    if drop:IsA("Model") then
        if drop.PrimaryPart then
            return drop.PrimaryPart.CFrame
        end
        local firstPart = drop:FindFirstChildWhichIsA("BasePart", true)
        return firstPart and firstPart.CFrame
    end
end

local function fireNearbyPrompts(radius)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local fired = 0
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local parent = prompt.Parent
            local promptPart = parent and (parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart"))
            if promptPart and (hrp.Position - promptPart.Position).Magnitude <= radius then
                local ok = pcall(fireproximityprompt, prompt, 1, true)
                if ok then fired = fired + 1 end
            end
        end
    end
    return fired
end

TPTab:Toggle({
    Title = "Auto Farm Airdrops & Lootbox",
    Desc = "Teleports to any airdrops and automatically opens them",
    Default = false,
    Callback = function(state)
        Config.AutoAirdrop = state
        if state then
            task.spawn(function()
                while Config.AutoAirdrop do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local positionBefore = hrp and hrp.Position

                    local airdropRF = getServiceRF("AirdropService")
                    local lootBox = airdropRF and airdropRF:FindFirstChild("LootBox")
                    if lootBox then
                        for lootBoxId = 1, Config.MaxLootBoxId do
                            if not Config.AutoAirdrop then break end
                            pcall(function() lootBox:InvokeServer(lootBoxId) end)
                            task.wait(0.1)
                        end
                    end

                    task.wait(0.5)
                    char = LocalPlayer.Character
                    hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local serverTeleported = positionBefore and hrp and (hrp.Position - positionBefore).Magnitude > 10

                    -- Use the workspace scan only when the server remote did not teleport us.
                    if not serverTeleported and hrp then
                        local drops = refreshAirdrops()
                        local targetCFrame = drops[1] and getDropCFrame(drops[1])
                        if targetCFrame then
                            hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.3)
                        end
                    end

                    fireNearbyPrompts(30)
                    task.wait(1.5)
                end
            end)
        end
    end
})

TPTab:Section({ Title = "Base Teleport" })

TPTab:Button({
    Title = "Save Current Location as Base",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Config.SavedBaseCFrame = char.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "Base Saved", Content = "Your current position has been saved!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 3 })
        end
    end
})

TPTab:Button({
    Title = "Teleport to Saved Base",
    Callback = function()
        if Config.SavedBaseCFrame then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = Config.SavedBaseCFrame + Vector3.new(0, 3, 0)
                char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                WindUI:Notify({ Title = "Teleported", Content = "Returned to base!", Duration = 2 })
            end
        else
            -- Fallback
            local spawnPoint = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Base")
            if spawnPoint then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
                    WindUI:Notify({ Title = "Teleported", Content = "Returned to Spawn/Base!", Duration = 2 })
                end
            else
                WindUI:Notify({ Title = "Error", Content = "No base location saved yet.", Duration = 3 })
            end
        end
    end
})

-- UTILITY / PLAYER MODS
local MiscTab = Window:Tab({ Title = "Misc & Player", Icon = "user" })
MiscTab:Section({ Title = "Player Settings" })

MiscTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 120, Default = 16 },
    Callback = function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

MiscTab:Toggle({
    Title = "Noclip (Walk Through Walls)",
    Desc = "Disables collision for your character",
    Default = false,
    Callback = function(state)
        Config.Noclip = state
        if state then
            task.spawn(function()
                while Config.Noclip do
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                    game:GetService("RunService").Stepped:Wait()
                end
            end)
        end
    end
})

MiscTab:Section({ Title = "Combat & Aura" })

MiscTab:Slider({
    Title = "Attack Aura Range",
    Step = 1,
    Value = { Min = 5, Max = 30, Default = 15 },
    Callback = function(value)
        Config.AttackRange = value
    end
})

MiscTab:Toggle({
    Title = "Demon Attack Aura",
    Desc = "Automatically attacks nearby players/demons",
    Default = false,
    Callback = function(state)
        Config.AttackAura = state
        if state then
            task.spawn(function()
                Config.AttackRange = Config.AttackRange or 15
                while Config.AttackAura do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    
                    if root and tool then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                local targetHum = player.Character:FindFirstChild("Humanoid")
                                
                                if targetRoot and targetHum and targetHum.Health > 0 then
                                    local distance = (root.Position - targetRoot.Position).Magnitude
                                    if distance <= Config.AttackRange then
                                        tool:Activate()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

MiscTab:Section({ Title = "Automation" })

MiscTab:Toggle({
    Title = "Auto-Collect Proximity Prompts",
    Desc = "Automatically activates nearby prompts (e.g. loots)",
    Default = false,
    Callback = function(state)
        Config.AutoCollect = state
        if state then
            task.spawn(function()
                while Config.AutoCollect do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, prompt in pairs(Workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Parent then
                                local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                                if part and (root.Position - part.Position).Magnitude <= 15 then
                                    pcall(function() fireproximityprompt(prompt, 1, true) end)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

WindUI:Notify({ Title = "IndraHub", Content = "IndraHub Script Loaded Successfully!", Duration = 5 })
