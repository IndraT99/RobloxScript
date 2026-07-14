local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Storage Hunters",
    Icon = "rbxassetid://10683767",
    Author = "IndraHub Premium",
    Folder = "IndraHub_StorageHunters",
    Size = UDim2.fromOffset(600, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

-- Supervisor Heartbeat
task.spawn(function()
    while task.wait(1) do
        if getgenv then
            getgenv().IndraHubStorageHuntersRunning = true
            getgenv().IndraHubStorageHuntersLastHeartbeat = os.time()
        end
    end
end)

-- ==========================================
-- 1. SHOP MANAGER TAB
-- ==========================================
local ShopTab = Window:Tab({ Title = "Shop Manager", Icon = "shopping-cart" })

ShopTab:Section({ Title = "Store Automation", TextSize = 16 })

ShopTab:Toggle({
    Title = "Auto Stock Shelves",
    Desc = "Automatically places items on empty shelves",
    Callback = function(state)
        getgenv().AutoStockShelves = state
    end,
})

ShopTab:Toggle({
    Title = "Auto Expand Shop Floor",
    Desc = "Buys shop floor expansions when affordable",
    Callback = function(state)
        getgenv().AutoExpandShopFloor = state
    end,
})

ShopTab:Toggle({
    Title = "Auto Expand Item Capacity",
    Desc = "Buys item capacity upgrades automatically",
    Callback = function(state)
        getgenv().AutoExpandItemCapacity = state
    end,
})

ShopTab:Section({ Title = "Staff Management", TextSize = 16 })

ShopTab:Toggle({
    Title = "Auto Hire & Upgrade Staff",
    Desc = "Automatically manages your shop assistants",
    Callback = function(state)
        getgenv().AutoStaff = state
    end,
})

ShopTab:Section({ Title = "Negotiation & Selling", TextSize = 16 })

ShopTab:Toggle({
    Title = "Auto Accept NPC Offers",
    Desc = "Accepts customer offers automatically",
    Callback = function(state)
        getgenv().AutoAcceptOffers = state
    end,
})

ShopTab:Toggle({
    Title = "Auto Decline Low Offers",
    Desc = "Declines lowball customer offers",
    Callback = function(state)
        getgenv().AutoDeclineOffers = state
    end,
})

ShopTab:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sells items from inventory",
    Callback = function(state)
        getgenv().AutoSell = state
    end,
})

ShopTab:Slider({
    Title = "Minimum Sell Value ($)",
    Step = 100,
    Value = {
        Min = 0,
        Max = 50000,
        Default = 1000,
    },
    Callback = function(value)
        getgenv().MinSellValue = value
    end,
})

ShopTab:Toggle({
    Title = "Auto Speed Up Slots",
    Desc = "Speeds up grading/repair/wash slots",
    Callback = function(state)
        getgenv().AutoSpeedUpSlots = state
    end,
})


-- ==========================================
-- 2. RESTORATION TAB
-- ==========================================
local RestoreTab = Window:Tab({ Title = "Restoration", Icon = "wrench" })

RestoreTab:Section({ Title = "Picklock Automation", TextSize = 16 })

RestoreTab:Toggle({
    Title = "Auto Picklock Inventory Safes",
    Callback = function(state)
        getgenv().AutoPicklockInventory = state
    end,
})

RestoreTab:Toggle({
    Title = "Auto Picklock World Safes",
    Callback = function(state)
        getgenv().AutoPicklockWorld = state
    end,
})

RestoreTab:Toggle({
    Title = "Auto Buy + Equip Best Lockpick",
    Callback = function(state)
        getgenv().AutoBestLockpick = state
    end,
})

RestoreTab:Section({ Title = "Processing", TextSize = 16 })

RestoreTab:Toggle({
    Title = "Auto Wash",
    Callback = function(state)
        getgenv().AutoWash = state
    end,
})

RestoreTab:Toggle({
    Title = "Auto Repair",
    Callback = function(state)
        getgenv().AutoRepair = state
    end,
})

RestoreTab:Toggle({
    Title = "Auto Grade",
    Callback = function(state)
        getgenv().AutoGrade = state
    end,
})

RestoreTab:Toggle({
    Title = "Auto X-Ray",
    Desc = "Automatically X-Rays mysterious boxes",
    Callback = function(state)
        getgenv().AutoXRay = state
    end,
})


-- ==========================================
-- 3. AUCTIONS TAB
-- ==========================================
local AuctionTab = Window:Tab({ Title = "Auctions", Icon = "gavel" })

AuctionTab:Section({ Title = "Auction Actions", TextSize = 16 })

AuctionTab:Toggle({
    Title = "Auto Start Auctions",
    Desc = "Automatically starts auctions for you",
    Callback = function(state)
        getgenv().AutoStartAuctions = state
    end,
})

AuctionTab:Toggle({
    Title = "Auto Enter Cargo Ship",
    Desc = "Automatically joins Cargo Ship events",
    Callback = function(state)
        getgenv().AutoEnterCargoShip = state
    end,
})

AuctionTab:Toggle({
    Title = "Auto Claim Auction Winnings",
    Callback = function(state)
        getgenv().AutoClaimWinnings = state
    end,
})

AuctionTab:Section({ Title = "Bidding System", TextSize = 16 })

AuctionTab:Toggle({
    Title = "Auto Bid",
    Desc = "Automatically bids in active auctions",
    Callback = function(state)
        getgenv().AutoBid = state
    end,
})

AuctionTab:Slider({
    Title = "Max Bid ($, 0 = no limit)",
    Step = 500,
    Value = {
        Min = 0,
        Max = 100000,
        Default = 0,
    },
    Callback = function(value)
        getgenv().MaxBidLimit = value
    end,
})

AuctionTab:Toggle({
    Title = "Auto Kick Top Bidder",
    Desc = "Kicks the highest bidder to secure your win",
    Callback = function(state)
        getgenv().AutoKick = state
    end,
})

AuctionTab:Toggle({
    Title = "Auto Calculator",
    Desc = "Calculates the net worth of a garage",
    Callback = function(state)
        getgenv().AutoCalculator = state
    end,
})


-- ==========================================
-- 4. VISUALS / ESP TAB
-- ==========================================
local EspTab = Window:Tab({ Title = "Visuals ESP", Icon = "eye" })

EspTab:Section({ Title = "Entities & Loot", TextSize = 16 })

EspTab:Toggle({
    Title = "Auction Garage ESP",
    Callback = function(state)
        getgenv().GarageEsp = state
    end,
})

EspTab:Toggle({
    Title = "Carryable ESP",
    Callback = function(state)
        getgenv().CarryableEsp = state
    end,
})

EspTab:Toggle({
    Title = "Safe ESP",
    Callback = function(state)
        getgenv().SafeEsp = state
    end,
})

EspTab:Toggle({
    Title = "Lost Item ESP",
    Callback = function(state)
        getgenv().LostItemEsp = state
    end,
})

EspTab:Toggle({
    Title = "Shop / NPC ESP",
    Callback = function(state)
        getgenv().ShopEsp = state
    end,
})

EspTab:Slider({
    Title = "ESP Max Distance (studs)",
    Step = 100,
    Value = {
        Min = 100,
        Max = 5000,
        Default = 1500,
    },
    Callback = function(value)
        getgenv().EspMaxDistance = value
    end,
})


-- ==========================================
-- 5. PLAYER & MISC TAB
-- ==========================================
local PlayerTab = Window:Tab({ Title = "Player & Misc", Icon = "user" })

PlayerTab:Section({ Title = "Player Mods", TextSize = 16 })

PlayerTab:Toggle({
    Title = "Walk Speed Enabled",
    Callback = function(state)
        getgenv().WalkSpeedEnabled = state
    end,
})

PlayerTab:Slider({
    Title = "Walk Speed Value",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        getgenv().WalkSpeedValue = value
    end,
})

PlayerTab:Toggle({
    Title = "Jump Power Enabled",
    Callback = function(state)
        getgenv().JumpPowerEnabled = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Transfer Truck to Inventory",
    Callback = function(state)
        getgenv().AutoUnloadTruck = state
    end,
})

PlayerTab:Section({ Title = "Auctions & Bidding", TextSize = 16 })

PlayerTab:Toggle({
    Title = "Auto Bid at Auctions",
    Desc = "Automatically places bids during live auctions",
    Callback = function(state)
        getgenv().AutoBid = state
    end,
})

PlayerTab:Section({ Title = "Auto Claims", TextSize = 16 })

PlayerTab:Toggle({
    Title = "Auto Claim Achievements",
    Callback = function(state)
        getgenv().AutoAchievements = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Claim Collections",
    Callback = function(state)
        getgenv().AutoCollections = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Claim Daily Reward",
    Callback = function(state)
        getgenv().AutoDailyReward = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Claim Meteor Drops",
    Callback = function(state)
        getgenv().AutoMeteors = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Time Capsule",
    Callback = function(state)
        getgenv().AutoCapsule = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Pickup / Interact Aura",
    Desc = "Automatically picks up items and opens crates near you",
    Callback = function(state)
        getgenv().AutoPickup = state
    end,
})

PlayerTab:Section({ Title = "Auto Buy", TextSize = 16 })

PlayerTab:Toggle({
    Title = "Auto Buy Luck Energy Drinks",
    Callback = function(state)
        getgenv().AutoBuyDrinks = state
    end,
})

PlayerTab:Toggle({
    Title = "Auto Buy Powers",
    Callback = function(state)
        getgenv().AutoBuyPowers = state
    end,
})

-- ==========================================
-- 4. SETTINGS & CREDITS TAB
-- ==========================================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Section({ Title = "Community", TextSize = 16 })
SettingsTab:Button({
    Title = "Join our Discord",
    Desc = "Click to copy invite link: https://discord.gg/2PPBJsmqr",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/2PPBJsmqr")
            WindUI:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard." })
        end
    end,
})

-- ==========================================
-- BACKEND ENGINE (Dynamic Remote Caller, ESP & Auto-UI)
-- ==========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local function FireStorageRemote(name, ...)
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then return false end
    
    for _, obj in ipairs(eventsFolder:GetDescendants()) do
        if obj.Name == name then
            if obj:IsA("RemoteEvent") then
                obj:FireServer(...)
                return true
            elseif obj:IsA("RemoteFunction") then
                pcall(function(...) obj:InvokeServer(...) end, ...)
                return true
            end
        end
    end
    return false
end

-- --- ESP SYSTEM ---
local ESP_Highlights = {}

local function CreateESP(instance, color, text)
    if not instance or not instance.Parent then return end
    if ESP_Highlights[instance] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = instance
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = instance
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = billboard
    billboard.Parent = instance
    
    ESP_Highlights[instance] = {Highlight = highlight, Billboard = billboard}
end

local function ClearESP()
    for instance, data in pairs(ESP_Highlights) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ESP_Highlights = {}
end

local function UpdateESP()
    local config = getgenv()
    if not (config.SafeEsp or config.GarageEsp or config.LostItemEsp or config.ShopEsp or config.CarryableEsp) then
        ClearESP()
        return
    end

    -- Loop workspace objects for ESP targets
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            -- Safes
            if config.SafeEsp and string.find(string.lower(obj.Name), "safe") then
                CreateESP(obj, Color3.fromRGB(255, 255, 0), "Safe")
            end
            -- Garages
            if config.GarageEsp and string.find(string.lower(obj.Name), "garage") then
                CreateESP(obj, Color3.fromRGB(0, 255, 0), "Garage")
            end
            -- Lost Items
            if config.LostItemEsp and string.find(string.lower(obj.Name), "lost") then
                CreateESP(obj, Color3.fromRGB(255, 0, 255), "Lost Item")
            end
            -- Shop / NPCs
            if config.ShopEsp and (string.find(string.lower(obj.Name), "npc") or string.find(string.lower(obj.Name), "customer")) then
                CreateESP(obj, Color3.fromRGB(0, 255, 255), "Customer/NPC")
            end
            -- Carryable
            if config.CarryableEsp and obj:GetAttribute("IsCarryable") then
                CreateESP(obj, Color3.fromRGB(255, 100, 100), "Carryable")
            end
        end
    end
    
    -- Cleanup destroyed objects
    for instance, data in pairs(ESP_Highlights) do
        if not instance.Parent then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            ESP_Highlights[instance] = nil
        end
    end
end

-- Run ESP every second to prevent lag
task.spawn(function()
    while task.wait(1) do
        pcall(UpdateESP)
    end
end)


-- --- AUTO GUI CLICKER (Offers / Sell) ---
local function ClickButton(button)
    if not button or not button.Visible then return end
    pcall(function()
        if type(firesignal) == "function" then
            firesignal(button.MouseButton1Click)
            firesignal(button.Activated)
        else
            -- Fallback to VirtualInputManager if firesignal is not supported
            local pos = button.AbsolutePosition + (button.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end
    end)
end

local function ProcessGUI()
    local config = getgenv()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    
    -- Search all GUI elements for Offers or Sell buttons
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = string.lower(obj.Text)
            
            -- Auto Accept / Decline Offers
            if config.AutoAcceptOffers and string.find(text, "accept") then
                ClickButton(obj)
            elseif config.AutoDeclineOffers and string.find(text, "decline") then
                ClickButton(obj)
            end
            
            -- Auto Sell Button
            if config.AutoSell and (string.find(text, "sell") or string.find(text, "sell items")) then
                ClickButton(obj)
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(ProcessGUI)
    end
end)

task.spawn(function()
    while task.wait(1) do
        local config = getgenv()
        
        -- Player Mods
        if config.WalkSpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = config.WalkSpeedValue or 50 end
        end
        if config.JumpPowerEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = 100 
            end
        end

        -- Auto Claims
        if config.AutoDailyReward then FireStorageRemote("ClaimDailyReward") end
        if config.AutoAchievements then FireStorageRemote("ClaimAchievementReward") end
        if config.AutoMeteors then FireStorageRemote("ClaimLostItem") end
        if config.AutoCollections then FireStorageRemote("ClaimRemote") end

        -- Auto Shop Manager
        if config.AutoBuyDrinks then FireStorageRemote("BuyDrink") end
        if config.AutoBuyPowers then FireStorageRemote("BuyPower") end
        if config.AutoExpandShopFloor then FireStorageRemote("BuyUpgrade", "ShopFloor") end
        if config.AutoExpandItemCapacity then FireStorageRemote("BuyUpgrade", "InventorySpace") end

        -- Auto Auctions
        if config.AutoBid then FireStorageRemote("Bid") end

        -- Auto Restoration (Guesses based on strings)
        if config.AutoWash then FireStorageRemote("StartWash") end
        if config.AutoRepair then FireStorageRemote("StartRepair") end
        if config.AutoGrade then FireStorageRemote("StartGrading") end
        if config.AutoPicklockInventory then FireStorageRemote("StartPicklockSession") end
        if config.AutoBestLockpick then FireStorageRemote("BuyLockpick") end

        -- Advanced Auto Unload Truck
        if config.AutoUnloadTruck then
            pcall(function()
                local getVehicleItems = ReplicatedStorage.Events.Vehicles:FindFirstChild("GetVehicleItems")
                local transferItems = ReplicatedStorage.Events.Vehicles:FindFirstChild("TransferVehicleItemsToInventory")
                if getVehicleItems and transferItems then
                    -- Default car name is STARTER-DUSTER, you can expand this list later
                    local items = getVehicleItems:InvokeServer("STARTER-DUSTER")
                    if items and type(items) == "table" and #items > 0 then
                        local itemIds = {}
                        for _, item in pairs(items) do
                            table.insert(itemIds, item.Id or item.Guid or item.ID or item[1])
                        end
                        if #itemIds > 0 then
                            transferItems:FireServer(itemIds)
                        end
                    end
                end
            end)
        end

        -- Advanced Auto Claim Lost Items
        if config.AutoMeteors then
            pcall(function()
                local getLost = ReplicatedStorage.Events.UI:FindFirstChild("GetLostItems")
                local claimLost = ReplicatedStorage.Events.UI:FindFirstChild("ClaimLostItem")
                if getLost and claimLost then
                    local zones = {"Junk Yard", "Pawn Shop", "Harbor"}
                    for _, zone in ipairs(zones) do
                        local items = getLost:InvokeServer(zone)
                        if items and type(items) == "table" then
                            for _, item in pairs(items) do
                                local id = item.Id or item.Guid or item.ID
                                if id then claimLost:InvokeServer(zone, id) end
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Pickup / Interact Aura
        if config.AutoPickup then
            pcall(function()
                if fireproximityprompt and LocalPlayer.Character then
                    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        for _, prompt in ipairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                local part = prompt.Parent
                                if part and part:IsA("BasePart") then
                                    local dist = (part.Position - rootPart.Position).Magnitude
                                    if dist <= 20 then
                                        fireproximityprompt(prompt, 0)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Sell
        if config.AutoSell then FireStorageRemote("SellItems") end
    end
end)

-- Heartbeat Bypass / Anti-AFK
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
            if eventsFolder then
                local misc = eventsFolder:FindFirstChild("Misc")
                if misc and misc:FindFirstChild("HeartbeatAudit") then
                    -- Sends dummy heartbeat to prevent being kicked by anti-cheat
                    misc.HeartbeatAudit:FireServer(1170652202, {}, 1471881959, {})
                end
            end
        end)
    end
end)

Window:SelectTab(1)
