local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubBuildAPetRunning") then return end
setGlobal("IndraHubBuildAPetRunning", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        setGlobal("IndraHubBuildAPetLastHeartbeat", os.time())
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Build a Pet Farm",
    Icon = "paw-print",
    Author = "IndraHub",
    Folder = "IndraHubBuildAPet",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local Toggles = {}
local Options = {}

setmetatable(Toggles, {
    __index = function(t, k)
        t[k] = {Value = false}
        return t[k]
    end
})
setmetatable(Options, {
    __index = function(t, k)
        t[k] = {Value = 0}
        return t[k]
    end
})

local DISCORD_LINK = "https://discord.gg/2PPBJsmqr"

local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_LINK)
    elseif toclipboard then
        toclipboard(DISCORD_LINK)
    end
    WindUI:Notify({Title="Success", Content="Discord invite copied to clipboard!"})
end


if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local State = require(Shared:WaitForChild("State"))

local SEED_ID_ATTR = State.Seed.Id
local TOOL_GUID_ATTR = State.Tool.Guid
local GRID_PURCHASABLE_ATTR = State.Grid.Purchasable
local TREE_GROUND_PILE_ATTR = State.TreeClicker.GroundPile
local TREE_LOCAL_VISUAL_ATTR = State.TreeClicker.LocalVisual
local TREE_SLOT_INDEX_ATTR = State.TreeClicker.SlotIndex
local FOOD_ID_ATTR = State.Food.Id
local FEED_CLASS_ATTR = State.Feed.Class

local function getRemote(name)
    return Remotes:FindFirstChild(name)
end

local AutoRollRemote = getRemote("AutoRollRequest")
local PlaceFeedMachine = getRemote("PlaceFeedMachine")
local TreeClicker = getRemote("TreeClickerRequest")
local RollLuckUpgrade = getRemote("RollLuckUpgradeRequest")
local RollDropAreaUpgrade = getRemote("RollDropAreaUpgradeRequest")
local RebirthRemote = getRemote("RebirthRequest")
local GearPurchase = getRemote("GearShopPurchaseRequest")
local CosmeticPurchase = getRemote("CosmeticShopPurchaseRequest")
local CrateRollPurchaseRequest = getRemote("CrateRollPurchaseRequest")
local CrateRollEffect = getRemote("CrateRollEffect")
local PromptInteract = getRemote("PromptInteract")

local RARITIES = { "Common", "Rare", "Epic", "Legendary", "Mythical", "Secret" }
local GEAR_IDS = { "JamBarrel", "UpgradedJamBarrel", "GoldenJamBarrel" }
local COSMETIC_IDS = { "Path", "GrassPath", "TikiTorch", "Arch", "Fountain", "Golden Fountain" }
local SEED_IDS = {
    "PineappleSeed", "PumpkinSeed", "PurpleShroomSeed", "WatermelonSeed", "GlowshroomSeed",
    "CornSeed", "CabbageSeed", "MushroomSeed", "PotatoSeed",
    "AppleTreeSeed", "CherryTreeSeed", "OrangeTreeSeed", "BananaTreeSeed", "FigTreeSeed",
    "PlumTreeSeed", "GoldenAppleTreeSeed", "CactusSeed", "BloodOrangeTreeSeed",
    "DurianTreeSeed", "DragonfruitTreeSeed",
}
local UPGRADE_NAMES = { "Roll Luck", "Roll Drop Area" }

local nonceCounter = 0
local function nextNonce()
    nonceCounter = nonceCounter + 1
    return nonceCounter
end

local function selectedSet(value)
    local set = {}
    if type(value) == "table" then
        for name, state in pairs(value) do
            if state then
                set[name] = true
            end
        end
    end
    return set
end

local cachedPlot = nil
local function getPlot()
    if cachedPlot and cachedPlot.Parent then
        return cachedPlot
    end
    cachedPlot = nil
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            cachedPlot = plot
            return plot
        end
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end
    local best, bestDist
    for _, plot in ipairs(plots:GetChildren()) do
        local part = plot:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local dist = (part.Position - root.Position).Magnitude
            if not bestDist or dist < bestDist then
                bestDist = dist
                best = plot
            end
        end
    end
    cachedPlot = best
    return best
end





local selectedRarities = {}
local selectedUpgrades = {}
local selectedSeeds = {}
local selectedGears = {}
local selectedCosmetics = {}
local petMoneyThresholds = {}
local movementBusy = false

local function petKey(pet)
    return tostring(pet:GetAttribute("PetID") or pet:GetAttribute("PetIndex") or pet:GetDebugId())
end

local function beginMovement()
    if movementBusy then
        return false
    end
    movementBusy = true
    return true
end

local function endMovement()
    movementBusy = false
end

local function selectedRarityArray()
    local array = {}
    for _, rarity in ipairs(RARITIES) do
        if selectedRarities[rarity] then
            array[#array + 1] = rarity
        end
    end
    if #array == 0 then
        for _, rarity in ipairs(RARITIES) do
            array[#array + 1] = rarity
        end
    end
    return array
end

local function sendAutoRoll(action)
    if not AutoRollRemote then
        return
    end
    pcall(function()
        AutoRollRemote:FireServer({
            action = action,
            autoPurchase = Toggles.RollAutoPurchase.Value == true,
            selectedRarities = selectedRarityArray(),
        })
    end)
end

local purchasedOfferIds = {}

if CrateRollEffect and CrateRollPurchaseRequest then
    CrateRollEffect.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" then return end
        if not Toggles.AutoRoll or not Toggles.AutoRoll.Value then return end
        
        if data.action == "showOffers" and type(data.offers) == "table" then
            if data.ownerUserId ~= LocalPlayer.UserId then return end
            
            for _, offer in ipairs(data.offers) do
                if type(offer) == "table" and offer.offerId then
                    local rarity = offer.rarity
                    local shouldPurchase = false
                    
                    if Toggles.RollAutoPurchase and Toggles.RollAutoPurchase.Value then
                        if next(selectedRarities) == nil or selectedRarities[rarity] then
                            shouldPurchase = true
                        end
                    end
                    
                    if shouldPurchase then
                        if not purchasedOfferIds[offer.offerId] then
                            purchasedOfferIds[offer.offerId] = true
                            pcall(function()
                                CrateRollPurchaseRequest:FireServer(offer.offerId)
                            end)
                            task.delay(10, function()
                                purchasedOfferIds[offer.offerId] = nil
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function refreshAutoRoll()
    if Toggles.AutoRoll.Value then
        sendAutoRoll("settings")
    end
end

local function firePromptsByTheme(theme, filter, tpToPrompts)
    local plot = getPlot()
    if not plot then
        return
    end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local oldCFrame = hrp and hrp.CFrame
    local didTeleport = false

    local prompts = {}
    for _, descendant in ipairs(plot:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "__LocalPrompt_" .. theme then
            table.insert(prompts, descendant)
        end
    end

    for _, descendant in ipairs(prompts) do
        if not getGlobal("IndraHubBuildAPetRunning") then
            break
        end
        if descendant:IsDescendantOf(workspace) and descendant.Parent then
            local part = descendant.Parent
            if part:IsA("Attachment") then
                part = part.Parent
            end
            if not filter or (part and filter(part, descendant)) then
                if tpToPrompts and hrp and part and part:IsA("BasePart") then
                    local dist = (hrp.Position - part.Position).Magnitude
                    if dist > descendant.MaxActivationDistance then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new()
                        task.wait(0.1)
                        didTeleport = true
                    end
                end
                
                if descendant:IsDescendantOf(workspace) then
                    pcall(fireproximityprompt, descendant)
                    task.wait(0.08)
                end
            end
        end
    end

    if didTeleport and hrp and oldCFrame then
        hrp.CFrame = oldCFrame
        hrp.AssemblyLinearVelocity = Vector3.new()
        task.wait(0.1)
    end
end

local function seedTools(includeAll)
    local tools = {}
    local containers = { LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local seedId = item:GetAttribute(SEED_ID_ATTR)
                    if type(seedId) == "string" and seedId ~= "" then
                        if includeAll or selectedSeeds[seedId] then
                            tools[#tools + 1] = item
                        end
                    end
                end
            end
        end
    end
    return tools
end

local function unlockedGridParts(plot)
    local parts = {}
    for _, folderName in ipairs({ "StarterArea", "GridAreas" }) do
        local folder = plot:FindFirstChild(folderName)
        if folder then
            for _, part in ipairs(folder:GetChildren()) do
                if part:IsA("BasePart") and part:GetAttribute("GridUnlocked") == true then
                    parts[#parts + 1] = part
                end
            end
        end
    end
    return parts
end

local function plantCFrames(plot, parts)
    local positions = {}
    for _, model in ipairs(plot:GetChildren()) do
        if model:IsA("Model") and model:GetAttribute(FEED_CLASS_ATTR) ~= nil then
            local ok, cframe = pcall(function()
                return (model:GetBoundingBox())
            end)
            if ok and cframe then
                positions[#positions + 1] = cframe.Position
            end
        end
    end
    local cframes = {}
    for _, part in ipairs(parts) do
        for _, x in ipairs({ -5, 0, 5 }) do
            for _, z in ipairs({ -5, 0, 5 }) do
                local cframe = part.CFrame * CFrame.new(x, part.Size.Y / 2 + 1.5, z)
                local available = true
                for _, position in ipairs(positions) do
                    if Vector2.new(cframe.Position.X - position.X, cframe.Position.Z - position.Z).Magnitude < 4.5 then
                        available = false
                        break
                    end
                end
                if available then
                    cframes[#cframes + 1] = cframe
                end
            end
        end
    end
    return cframes
end

local function doPlant(includeAll)
    if not PlaceFeedMachine then
        return
    end
    local plot = getPlot()
    if not plot then
        return
    end
    local tools = seedTools(includeAll)
    if #tools == 0 then
        return
    end
    local parts = unlockedGridParts(plot)
    if #parts == 0 then
        return
    end
    local cframes = plantCFrames(plot, parts)
    if #cframes == 0 then
        return
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return
    end
    local cframeIndex = 1
    for _, tool in ipairs(tools) do
        if not getGlobal("IndraHubBuildAPetRunning") or not (Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value) then
            return
        end
        local guid = tool:GetAttribute(TOOL_GUID_ATTR)
        if type(guid) == "string" and guid ~= "" then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            task.wait(0.1)
            while tool.Parent and cframes[cframeIndex] do
                if not getGlobal("IndraHubBuildAPetRunning") or not (Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value) then
                    return
                end
                local cframe = cframes[cframeIndex]
                cframeIndex = cframeIndex + 1
                pcall(function()
                    PlaceFeedMachine:FireServer(nextNonce(), cframe, guid)
                end)
                task.wait(0.3)
            end
            pcall(function()
                if tool.Parent == character then
                    humanoid:UnequipTools()
                end
            end)
            task.wait(Options.PlantDelay.Value or 0.5)
        end
    end
end

local function doCollectPetMoney()
    local plot = getPlot()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plot or not root then
        return
    end
    if not beginMovement() then
        return
    end
    local oldCFrame = root.CFrame
    local moved = false
    for _, pet in ipairs(plot:GetChildren()) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoCollectPetMoney.Value then
            break
        end
        if pet:IsA("Model") and pet:GetAttribute("PetIndex") ~= nil
            and (tonumber(pet:GetAttribute("Money")) or 0) >= (petMoneyThresholds[petKey(pet)] or 1000) then
            root.CFrame = pet:GetPivot() + Vector3.new(0, 2, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.2)
            moved = true
        end
    end
    if moved and root.Parent then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    endMovement()
end

local function treeModels(plot)
    local trees = {}
    for _, model in ipairs(plot:GetChildren()) do
        if model:IsA("Model") then
            if model:FindFirstChild("LeafShake", true) or string.find(model.Name, "Tree") then
                trees[#trees + 1] = model
            end
        end
    end
    return trees
end

local function doShake()
    if not TreeClicker then
        return
    end
    local plot = getPlot()
    if not plot then
        return
    end
    local shakes = math.floor(tonumber(Options.ShakeCount.Value) or 3)
    for _, tree in ipairs(treeModels(plot)) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoShake.Value then
            return
        end
        for _ = 1, shakes do
            if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoShake.Value then
                return
            end
            pcall(function()
                TreeClicker:FireServer(tree)
            end)
            task.wait(0.05)
        end
    end
end

local function doHarvest()
    local plot = getPlot()
    if not plot or not PromptInteract then
        return
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return
    end
    local oldCFrame = root and root.CFrame
    local moved = false

    local function collect(action, target)
        if root then
            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.1)
            moved = true
        end
        pcall(function()
            PromptInteract:FireServer(action, target, false)
        end)
        task.wait(0.15)
    end

    for _, descendant in ipairs(plot:GetDescendants()) do
        if not getGlobal("IndraHubBuildAPetRunning") then
            break
        end
        if Toggles.HarvestPatches.Value
            and descendant:IsA("ProximityPrompt")
            and descendant.Name == "__LocalPrompt_PatchHarvest"
            and descendant.Parent
            and descendant.Parent:IsA("Attachment")
            and descendant.Parent.Parent
            and descendant.Parent.Parent:IsA("BasePart") then
            collect("PatchHarvest", descendant.Parent.Parent)
        elseif Toggles.HarvestTreeGround.Value
            and descendant:IsA("BasePart")
            and descendant:GetAttribute(TREE_GROUND_PILE_ATTR) == true
            and descendant:GetAttribute(TREE_LOCAL_VISUAL_ATTR) ~= true
            and descendant:GetAttribute(TREE_SLOT_INDEX_ATTR) ~= nil
            and descendant:GetAttribute(FOOD_ID_ATTR) ~= nil then
            collect("TreeGroundPickup", descendant)
        end
    end

    if moved and root and oldCFrame then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    if root then
        endMovement()
    end
end

local function doFeed()
    firePromptsByTheme("PetFeed")
end

local function doUpgrades()
    for _, name in ipairs(UPGRADE_NAMES) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoUpgrade.Value then
            return
        end
        if selectedUpgrades[name] then
            if name == "Roll Luck" and RollLuckUpgrade then
                pcall(function()
                    RollLuckUpgrade:FireServer(nextNonce())
                end)
            elseif name == "Roll Drop Area" and RollDropAreaUpgrade then
                pcall(function()
                    RollDropAreaUpgrade:FireServer(nextNonce())
                end)
            end
            task.wait(0.15)
        end
    end
end

local function doRebirth()
    if RebirthRemote then
        pcall(function()
            RebirthRemote:FireServer(nextNonce())
        end)
    end
end

local function doBuyGears()
    if not GearPurchase then
        return
    end
    for _, id in ipairs(GEAR_IDS) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoBuyGears.Value then
            return
        end
        if selectedGears[id] then
            pcall(function()
                GearPurchase:FireServer(nextNonce(), id)
            end)
            task.wait(0.15)
        end
    end
end

local function doBuyCosmetics()
    if not CosmeticPurchase then
        return
    end
    for _, id in ipairs(COSMETIC_IDS) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoBuyCosmetics.Value then
            return
        end
        if selectedCosmetics[id] then
            pcall(function()
                CosmeticPurchase:FireServer(nextNonce(), id)
            end)
            task.wait(0.15)
        end
    end
end

local function doExpand()
    local plot = getPlot()
    if not plot or not PromptInteract then
        return
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return
    end
    local oldCFrame = root and root.CFrame
    local moved = false
    for _, part in ipairs(plot:GetDescendants()) do
        if not getGlobal("IndraHubBuildAPetRunning") or not Toggles.AutoExpand.Value then
            break
        end
        if part:IsA("BasePart") and part:GetAttribute(GRID_PURCHASABLE_ATTR) == true then
            if root then
                root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                root.AssemblyLinearVelocity = Vector3.new()
                task.wait(0.1)
                moved = true
            end
            pcall(function()
                PromptInteract:FireServer("GridPartUnlock", part, false)
            end)
            task.wait(0.15)
        end
    end
    if moved and root and oldCFrame then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    if root then
        endMovement()
    end
end

local function moveToRollButton()
    local plot = getPlot()
    if not plot then
        return nil
    end

    local prompt
    for _, descendant in ipairs(plot:GetDescendants()) do
        if descendant.Name == "__LocalPrompt_CrateRoll" and descendant:IsA("ProximityPrompt") then
            prompt = descendant
            break
        end
    end

    local button = prompt and prompt.Parent and prompt.Parent.Parent
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return nil
    end
    if button and button:IsA("BasePart") and root then
        if (root.Position - button.Position).Magnitude > 6 then
            root.CFrame = button.CFrame + Vector3.new(0, 3, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.15)
        end
    end
    if root then
        endMovement()
    end
    return prompt
end

local function doManualAutoRoll()
    local prompt = moveToRollButton()
    if prompt and prompt.Parent then
        pcall(fireproximityprompt, prompt)
    end
end


local TabFarm = Window:Tab({ Title = "Farm", Icon = "sprout" })
local TabRoll = Window:Tab({ Title = "Roll", Icon = "dices" })
local TabShop = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })

TabFarm:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = copyDiscord
})

TabFarm:Toggle({Title = "Auto Plant", Default = false, Callback = function(v) Toggles.AutoPlant.Value = v end})
TabFarm:Toggle({Title = "Auto Plant All", Default = false, Callback = function(v) Toggles.AutoPlantAll.Value = v end})
TabFarm:Dropdown({Title = "Seeds To Plant", Values = SEED_IDS, Multi = true, Callback = function(v) selectedSeeds = selectedSet(v) end})
TabFarm:Slider({Title = "Plant Delay", Step = 0.1, Min = 0.2, Max = 5, Value = 0.5, Callback = function(v) Options.PlantDelay.Value = v end})

TabFarm:Toggle({Title = "Auto Shake Trees", Default = false, Callback = function(v) Toggles.AutoShake.Value = v end})
TabFarm:Slider({Title = "Shakes Per Tree", Step = 1, Min = 1, Max = 20, Value = 3, Callback = function(v) Options.ShakeCount.Value = v end})

TabFarm:Toggle({Title = "Harvest Patches", Default = false, Callback = function(v) Toggles.HarvestPatches.Value = v end})
TabFarm:Toggle({Title = "Collect Tree Fruit", Default = false, Callback = function(v) Toggles.HarvestTreeGround.Value = v end})
TabFarm:Toggle({Title = "Auto Feed Pets", Default = false, Callback = function(v) Toggles.AutoFeed.Value = v end})
TabFarm:Toggle({Title = "Auto Collect Money From Pets", Default = false, Callback = function(v) Toggles.AutoCollectPetMoney.Value = v end})
TabFarm:Toggle({Title = "Auto Expand", Default = false, Callback = function(v) Toggles.AutoExpand.Value = v end})

TabRoll:Toggle({Title = "Auto Roll", Default = false, Callback = function(v) Toggles.AutoRoll.Value = v; refreshAutoRoll() end})
TabRoll:Toggle({Title = "Auto Purchase (Gems/Money)", Default = false, Callback = function(v) Toggles.RollAutoPurchase.Value = v; refreshAutoRoll() end})
TabRoll:Dropdown({Title = "Rarities to Auto Purchase", Values = RARITIES, Multi = true, Callback = function(v) selectedRarities = selectedSet(v); refreshAutoRoll() end})

TabShop:Toggle({Title = "Auto Buy Upgrades", Default = false, Callback = function(v) Toggles.AutoUpgrade.Value = v end})
TabShop:Dropdown({Title = "Upgrades To Buy", Values = UPGRADE_NAMES, Multi = true, Callback = function(v) selectedUpgrades = selectedSet(v) end})
TabShop:Toggle({Title = "Auto Buy Gears", Default = false, Callback = function(v) Toggles.AutoBuyGears.Value = v end})
TabShop:Dropdown({Title = "Gears To Buy", Values = GEAR_IDS, Multi = true, Callback = function(v) selectedGears = selectedSet(v) end})
TabShop:Toggle({Title = "Auto Buy Cosmetics", Default = false, Callback = function(v) Toggles.AutoBuyCosmetics.Value = v end})
TabShop:Dropdown({Title = "Cosmetics To Buy", Values = COSMETIC_IDS, Multi = true, Callback = function(v) selectedCosmetics = selectedSet(v) end})

TabShop:Button({Title = "Rebirth", Callback = doRebirth})

-- Loops Setup
task.spawn(function()
    while task.wait(Options.PlantLoopDelay and Options.PlantLoopDelay.Value or 1) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value then
            doPlant(Toggles.AutoPlantAll.Value)
        end
    end
end)

task.spawn(function()
    while task.wait(Options.ShakeDelay and Options.ShakeDelay.Value or 0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoShake.Value then
            doShake()
        end
    end
end)

task.spawn(function()
    while task.wait(Options.HarvestDelay and Options.HarvestDelay.Value or 0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.HarvestPatches.Value or Toggles.HarvestTreeGround.Value then
            doHarvest()
        end
    end
end)

task.spawn(function()
    while task.wait(Options.FeedDelay and Options.FeedDelay.Value or 0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoFeed.Value then
            doFeed()
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoCollectPetMoney.Value then
            doCollectPetMoney()
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoExpand.Value then
            doExpand()
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoUpgrade.Value then
            doUpgrades()
        end
        if Toggles.AutoBuyGears.Value then
            doBuyGears()
        end
        if Toggles.AutoBuyCosmetics.Value then
            doBuyCosmetics()
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubBuildAPetRunning") then break end
        if Toggles.AutoRoll.Value then
            if not purchasedOfferIds or next(purchasedOfferIds) == nil then
                doManualAutoRoll()
            end
        end
    end
end)
