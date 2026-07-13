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
local HumanTab = Window:Tab({ Title = "Human Auto", Icon = "shield" })
local DemonTab = Window:Tab({ Title = "Demon Auto", Icon = "skull" })
local TPTab = Window:Tab({ Title = "Teleports", Icon = "map-pin" })

-- DISCORD SECTION
MainTab:Section({ Title = "Information" })
MainTab:Button({
    Title = "Copy Discord Link",
    Desc = "Join our community for updates!",
    Callback = function()
        setclipboard("https://discord.gg/AeuSH2EQK")
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
    TargetWeapon = "M4A1"
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
local PurchaseUpgradeRE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PurchaseUpgrade")
local KnitPlotUpgradeRF = ReplicatedStorage:FindFirstChild("CommonComponents") and ReplicatedStorage.CommonComponents.Packages.Knit.Services.PlotService.RF:FindFirstChild("Upgrade")

local function interactWith(keyword)
    -- Fire the ReplicatedStorage Remotes directly with guessed arguments based on the keyword
    if PurchaseUpgradeRE then
        pcall(function() PurchaseUpgradeRE:FireServer(keyword) end)
        pcall(function() PurchaseUpgradeRE:FireServer(string.lower(keyword)) end)
    end
    if KnitPlotUpgradeRF then
        -- Since it's a RemoteFunction, we wrap it in a pcall inside a coroutine so it doesn't yield/block the loop
        task.spawn(function()
            pcall(function() KnitPlotUpgradeRF:InvokeServer(keyword) end)
            pcall(function() KnitPlotUpgradeRF:InvokeServer(string.lower(keyword)) end)
        end)
    end
    
    -- Fallback: Check for generic ProximityPrompts with matching ActionText/ObjectText
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if string.match(string.lower(prompt.ObjectText), string.lower(keyword)) or string.match(string.lower(prompt.ActionText), string.lower(keyword)) then
                fireproximityprompt(prompt, 1, true)
            end
        end
    end
    
    return true
end

-- HUMAN TAB
HumanTab:Section({ Title = "Priorities" })

HumanTab:Dropdown({
    Title = "Priority 1",
    Values = {"Door", "Turret", "Cash", "Gold", "Decomposer", "Armory"},
    Default = "Cash",
    Callback = function(val) Config.HumanPriority1 = val end
})

HumanTab:Dropdown({
    Title = "Priority 2",
    Values = {"Door", "Turret", "Cash", "Gold", "Decomposer", "Armory"},
    Default = "Door",
    Callback = function(val) Config.HumanPriority2 = val end
})

HumanTab:Dropdown({
    Title = "Priority 3",
    Values = {"Door", "Turret", "Cash", "Gold", "Decomposer", "Armory"},
    Default = "Turret",
    Callback = function(val) Config.HumanPriority3 = val end
})

HumanTab:Section({ Title = "Auto Upgrades" })

HumanTab:Toggle({
    Title = "Auto Upgrades Loop",
    Desc = "Follows the priority list above",
    Default = false,
    Callback = function(state)
        Config.HumanAuto = state
        while Config.HumanAuto do
            local KnitServices = game:GetService("ReplicatedStorage"):FindFirstChild("CommonComponents") and game:GetService("ReplicatedStorage").CommonComponents.Packages.Knit.Services
            local PlotRF = KnitServices and KnitServices:FindFirstChild("PlotService") and KnitServices.PlotService:FindFirstChild("RF")
            
            if PlotRF then
                local idMap = {
                    Door = {35},
                    Turret = {32},
                    Cash = {31, 34, 36, 37, 38},
                    Gold = {39},
                    Decomposer = {40},
                    Armory = {33}
                }
                
                local priorities = {Config.HumanPriority1, Config.HumanPriority2, Config.HumanPriority3}
                for _, p in ipairs(priorities) do
                    local ids = idMap[p]
                    if ids then
                        for _, id in ipairs(ids) do
                            local argObj = {
                                parameterType = "PositiveInteger",
                                parameter = id
                            }
                            
                            -- Always attempt to Unlock first
                            if PlotRF:FindFirstChild("Unlock") then
                                task.spawn(function() pcall(function() PlotRF.Unlock:InvokeServer(argObj) end) end)
                            end
                            -- Then attempt to Upgrade
                            if PlotRF:FindFirstChild("Upgrade") then
                                task.spawn(function() pcall(function() PlotRF.Upgrade:InvokeServer(argObj) end) end)
                            end
                            -- Specific handling for Decomposer
                            if id == 40 and PlotRF:FindFirstChild("Decompose") then
                                task.spawn(function() pcall(function() PlotRF.Decompose:InvokeServer(argObj) end) end)
                            end
                        end
                        task.wait(0.1) -- Small delay between priority actions
                    end
                end
            else
                -- Priority generic fallback (ProximityPrompts/Touch)
                local priorities = {Config.HumanPriority1, Config.HumanPriority2, Config.HumanPriority3}
                for _, p in ipairs(priorities) do
                    interactWith(p)
                    task.wait(0.5)
                end
            end
            task.wait(1)
        end
    end
})

HumanTab:Section({ Title = "Weapon Shop" })

local weaponList = {"M4A1", "Inferno", "Tesla"}
HumanTab:Dropdown({
    Title = "Select Weapon",
    Values = weaponList,
    Default = "M4A1",
    Callback = function(val)
        Config.TargetWeapon = val
    end
})

HumanTab:Toggle({
    Title = "Auto Buy & Equip Weapon",
    Desc = "Automatically buys and equips the selected weapon when you have enough money",
    Default = false,
    Callback = function(state)
        Config.AutoWeapon = state
        while Config.AutoWeapon do
            local WeaponShopRF = game:GetService("ReplicatedStorage"):FindFirstChild("CommonComponents") and game:GetService("ReplicatedStorage").CommonComponents.Packages.Knit.Services.WeaponShopService.RF
            if WeaponShopRF and Config.TargetWeapon then
                local args = {{parameterType = "String", parameter = Config.TargetWeapon}}
                task.spawn(function()
                    if WeaponShopRF:FindFirstChild("BuyWeapon") then
                        pcall(function() WeaponShopRF.BuyWeapon:InvokeServer(unpack(args)) end)
                    end
                    if WeaponShopRF:FindFirstChild("EquipWeapon") then
                        pcall(function() WeaponShopRF.EquipWeapon:InvokeServer(unpack(args)) end)
                    end
                end)
            end
            task.wait(1)
        end
    end
})

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
    end
})

DemonTab:Toggle({
    Title = "Auto Evolve",
    Desc = "Automatically evolves your demon when ready",
    Default = false,
    Callback = function(state)
        Config.DemonAutoEvolve = state
        while Config.DemonAutoEvolve do
            local KnitServices = game:GetService("ReplicatedStorage"):FindFirstChild("CommonComponents") and game:GetService("ReplicatedStorage").CommonComponents.Packages.Knit.Services
            local HunterRF = KnitServices and KnitServices:FindFirstChild("HunterService") and KnitServices.HunterService:FindFirstChild("RF")
            
            if HunterRF and HunterRF:FindFirstChild("EvolveHunter") then
                pcall(function() HunterRF.EvolveHunter:InvokeServer() end)
            end
            task.wait(2)
        end
    end
})

-- Lag server feature removed

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
                        table.insert(drops, model.Name)
                    end
                else
                    table.insert(drops, model.Name)
                end
            end
        end
    end
    
    scanFolder("AirdropFolder")
    scanFolder("DropItemFolder")
    
    return drops
end

TPTab:Toggle({
    Title = "Auto Farm Airdrops",
    Desc = "Automatically scans and teleports to any active airdrops",
    Default = false,
    Callback = function(state)
        Config.AutoAirdrop = state
        while Config.AutoAirdrop do
            local drops = refreshAirdrops()
            if #drops > 0 then
                -- Target the first valid drop
                local targetName = drops[1]
                local target = nil
                
                local airdropFolder = Workspace:FindFirstChild("AirdropFolder")
                local dropItemFolder = Workspace:FindFirstChild("DropItemFolder")
                
                if airdropFolder then target = airdropFolder:FindFirstChild(targetName) end
                if not target and dropItemFolder then target = dropItemFolder:FindFirstChild(targetName) end
                
                if target then
                    local targetPos = nil
                    if target:IsA("Model") and target.PrimaryPart then
                        targetPos = target.PrimaryPart.CFrame
                    elseif target:IsA("BasePart") then
                        targetPos = target.CFrame
                    elseif target:IsA("Model") then
                        local firstPart = target:FindFirstChildWhichIsA("BasePart", true)
                        if firstPart then targetPos = firstPart.CFrame end
                    end
                    
                    if targetPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        -- Strip rotation and add height
                        hrp.CFrame = CFrame.new(targetPos.Position + Vector3.new(0, 5, 0))
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
            task.wait(0.5) -- Fast check for new airdrops
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
                char.HumanoidRootPart.CFrame = Config.SavedBaseCFrame
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                WindUI:Notify({ Title = "Teleported", Content = "Returned to base!", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "No base location saved yet.", Duration = 3 })
        end
    end
})

WindUI:Notify({ Title = "IndraHub", Content = "IndraHub Script Loaded Successfully!", Duration = 5 })
