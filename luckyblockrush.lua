-- ==========================================
-- WINDUI SETUP
-- ==========================================
shared.IndraHub_LuckyRush_Unloaded = false

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Lucky Block Rush",
    Icon = "rbxassetid://91400086538074",
    Author = "IndraHub",
    Folder = "IndraHub_LuckyRush",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "swords" }),
    Auto = Window:Tab({ Title = "Auto", Icon = "zap" }),
    Suggestions = Window:Tab({ Title = "Suggestions", Icon = "message-square" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

-- Lucky Block Rush / Ouroboros Hub
-- Reconstructed from the obfuscated script's runtime trace.
-- The original symbol names and formatting cannot be recovered byte-for-byte.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Bosses = workspace:WaitForChild("Bosses")

local Knit = require(ReplicatedStorage.Packages.Knit)
local CombatConfig = require(ReplicatedStorage.Configs.CombatConfig)
local BossConfig = require(ReplicatedStorage.Configs.BossConfig)
local PlaytimeRewardConfig = require(ReplicatedStorage.Configs.PlaytimeRewardConfig)
local PlayerSkinConfig = require(ReplicatedStorage.Configs.PlayerSkinConfig)
local TrainToolConfig = require(ReplicatedStorage.Configs.TrainToolConfig)
local WorldUpgradesConfig = require(ReplicatedStorage.Configs.WorldUpgradesConfig)
local BiomeConfig = require(ReplicatedStorage.Configs.BiomeConfig)
local BrainrotsConfig = require(ReplicatedStorage.Configs.BrainrotsConfig)
local PotionsConfig = require(ReplicatedStorage.Configs.PotionsConfig)

local TrainingService = Knit.GetService("TrainingService")
local SkinService = Knit.GetService("SkinService")
local WorldUpgradesService = Knit.GetService("WorldUpgradesService")
local RebirthService = Knit.GetService("RebirthService")
local ContainerService = Knit.GetService("ContainerService")
local BiomeService = Knit.GetService("BiomeService")
local InventoryService = Knit.GetService("InventoryService")
local GlobalBossEventService = Knit.GetService("GlobalBossEventService")
local StarBlockService = Knit.GetService("StarBlockService")
local PotionService = Knit.GetService("PotionService")

local AutorunController = Knit.GetController("AutorunController")
local AttackController = Knit.GetController("AttackController")
local PlaytimeRewardController = Knit.GetController("PlaytimeRewardController")
local ReplicaController = Knit.GetController("ReplicaController")
local GlobalBossController = Knit.GetController("GlobalBossController")

local DISCORD_INVITE = "https://discord.gg/2PPBJsmqr"
local SUGGESTION_WEBHOOK = "https://discord.com/api/webhooks/1520528533791703184/sG6qAqt31YTOBoduDbVcKURG5jBUxnNbWEhKLp02J9LCVw_ztSUjezEU1Q0E7g-bglfR"

local flags = {
    autoFarm = false,
    attackSpeed = 1,
    autoTrain = false,
    trainDelay = 0.3,
    autoBonus = false,
    autoTimeReward = false,
    autoCollectCash = false,
    resetBoss = "Off",
    autoUpgradeBase = false,
    autoUnlockWorld = false,
    autoRebirth = false,
    autoBuyAura = false,
    autoEquipAura = false,
    autoBuyDummy = false,
    autoEquipDummy = false,
    autoUpgradeBrainrots = false,
    brainrotTarget = 0,
    autoPlaceBest = false,
    placeInterval = 30,
    autoSellBrainrots = false,
    autoSellLuckyBlock = false,
    sellMutationFilter = {Any = true},
    sellRarityFilter = {Any = true},
    autoBuyTrainUpgrade = false,
    autoBuyCashUpgrade = false,
    autoBuyDamageUpgrade = false,
    autoBuyHealthUpgrade = false,
    autoKillGlobalBoss = false,
    autoOpenBossChest = false,
    autoLeaveGlobalBoss = false,
    autoUsePotion = false,
    potionFilter = "Any",
    antiAfk = false,
}

local function getData()
    local replica = ReplicaController:GetReplica()
    return replica and replica.Data
end

local function owns(collection, id)
    if type(collection) ~= "table" then
        return false
    end
    return collection[id] ~= nil or table.find(collection, id) ~= nil
end

local function configTable(module, preferredKey)
    if type(module) ~= "table" then
        return {}
    end
    local preferred = preferredKey and module[preferredKey]
    return type(preferred) == "table" and preferred or module
end

local function uniqueValues(values)
    local seen = {}
    local result = {}
    for _, value in ipairs(values) do
        if value ~= nil and not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end
    return result
end

local function selected(filter, value)
    if type(filter) ~= "table" or filter.Any or filter["Any"] then
        return true
    end
    return filter[value] == true or table.find(filter, value) ~= nil
end

local function copyDiscord()
    setclipboard(DISCORD_INVITE)
    WindUI:Notify({
        Title = "Discord",
        Content = "Invite copied to clipboard",
        Duration = 4,
    })
end

local function executorRequest(options)
    local requestFunction = request or http_request or (syn and syn.request)
    if not requestFunction then
        return false, "Your executor does not provide an HTTP request function."
    end
    return pcall(requestFunction, options)
end

Tabs.Main:Toggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Desc = "Starts a fight and enables in-game Auto Fight",
    Callback = function(value)
        flags.autoFarm = value
        if value then
            AutorunController:Start()
        end
    end,
})

Tabs.Main:Slider("AttackSpeed", {
    Title = "Attack Speed",
    Default = 1,
    Min = 1,
    Max = 2,
    Rounding = 2,
    Suffix = "x",
    Callback = function(value)
        flags.attackSpeed = value
        CombatConfig.PLAYER_ATTACK_DEBOUNCE = CombatConfig.PLAYER_ATTACK_DEBOUNCE / value
    end,
})

Tabs.Main:Toggle("AutoTrain", {
    Title = "Auto Train",
    Default = false,
    Callback = function(value)
        flags.autoTrain = value
    end,
})

Tabs.Main:Slider("TrainDelay", {
    Title = "Train Attempt Delay",
    Default = 0.3,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Suffix = "s",
    Callback = function(value)
        flags.trainDelay = value
    end,
})

Tabs.Main:Toggle("AutoBonus", {
    Title = "Auto Claim Train Bonus",
    Default = false,
    Callback = function(value)
        flags.autoBonus = value
    end,
})

Tabs.Main:Toggle("AutoTimeReward", {
    Title = "Auto Claim Time Reward",
    Default = false,
    Callback = function(value)
        flags.autoTimeReward = value
    end,
})

Tabs.Main:Toggle("AutoCollectCash", {
    Title = "Auto Collect Brainrot Money",
    Default = false,
    Callback = function(value)
        flags.autoCollectCash = value
    end,
})

local bossNames = {"Off"}
for id, boss in pairs(configTable(BossConfig, "CONFIG")) do
    if type(boss) == "table" and boss.globalBoss then
        table.insert(bossNames, boss.name or boss.displayName or tostring(id))
    end
end

Tabs.Main:Dropdown("ResetBoss", {
    Title = "Reset After Boss",
    Values = uniqueValues(bossNames),
    Default = 1,
    Multi = false,
    Searchable = true,
    Callback = function(value)
        flags.resetBoss = value
    end,
})

Tabs.Main:Toggle("AutoUpgradeBase", {
    Title = "Auto Upgrade Base",
    Default = false,
    Callback = function(value)
        flags.autoUpgradeBase = value
    end,
})
Tabs.Main:Toggle("AutoUnlockWorld", {
    Title = "Auto Unlock Best World",
    Default = false,
    Callback = function(value)
        flags.autoUnlockWorld = value
    end,
})
Tabs.Main:Toggle("AutoRebirth", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(value)
        flags.autoRebirth = value
    end,
})

Tabs.Main:Toggle("AutoBuyAura", {
    Title = "Auto Buy Best Affordable Aura",
    Default = false,
    Callback = function(value)
        flags.autoBuyAura = value
    end,
})
Tabs.Main:Toggle("AutoEquipAura", {
    Title = "Auto Equip Best Owned Aura",
    Default = false,
    Callback = function(value)
        flags.autoEquipAura = value
    end,
})

Tabs.Main:Toggle("AutoBuyDummy", {
    Title = "Auto Buy Best Affordable Dummy",
    Default = false,
    Callback = function(value)
        flags.autoBuyDummy = value
    end,
})
Tabs.Main:Toggle("AutoEquipDummy", {
    Title = "Auto Equip Best Owned Dummy",
    Default = false,
    Callback = function(value)
        flags.autoEquipDummy = value
    end,
})

Tabs.Auto:Toggle("AutoUpgradeBrainrots", {
    Title = "Auto Upgrade Owned Brainrots",
    Default = false,
    Callback = function(value)
        flags.autoUpgradeBrainrots = value
    end,
})
Tabs.Auto:Slider("BrainrotTarget", {
    Title = "Brainrot Target Level",
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        flags.brainrotTarget = value
    end,
})
Tabs.Auto:Toggle("AutoPlaceBest", {
    Title = "Auto Place Best Brainrots",
    Default = false,
    Callback = function(value)
        flags.autoPlaceBest = value
    end,
})
Tabs.Auto:Slider("PlaceInterval", {
    Title = "Best Brainrot Interval",
    Default = 30,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = "s",
    Callback = function(value)
        flags.placeInterval = value
    end,
})

local rarityValues = {"Any"}
for _, brainrot in pairs(configTable(BrainrotsConfig, "BRAINROTS")) do
    if type(brainrot) == "table" then
        table.insert(rarityValues, brainrot.rarity or brainrot.Rarity)
    end
end

Tabs.Auto:Toggle("AutoSellBrainrots", {
    Title = "Auto Sell Brainrots",
    Default = false,
    Callback = function(value)
        flags.autoSellBrainrots = value
    end,
})
Tabs.Auto:Toggle("AutoSellLuckyBlock", {
    Title = "Auto Sell Lucky Block",
    Default = false,
    Callback = function(value)
        flags.autoSellLuckyBlock = value
    end,
})
Tabs.Auto:Dropdown("SellMutationFilter", {
    Title = "Sell Mutation Filter",
    Values = {"Any", "NORMAL", "GOLD", "DIAMOND", "CANDY", "VOID"},
    Default = {"Any"},
    Multi = true,
    Callback = function(value)
        flags.sellMutationFilter = value
    end,
})
Tabs.Auto:Dropdown("SellRarityFilter", {
    Title = "Sell Rarity Filter",
    Values = uniqueValues(rarityValues),
    Default = {"Any"},
    Multi = true,
    Searchable = true,
    Callback = function(value)
        flags.sellRarityFilter = value
    end,
})

Tabs.Auto:Toggle("AutoBuyTrainUpgrade", {
    Title = "Auto Buy Train Upgrade",
    Default = false,
    Callback = function(value)
        flags.autoBuyTrainUpgrade = value
    end,
})
Tabs.Auto:Toggle("AutoBuyCashUpgrade", {
    Title = "Auto Buy Cash Upgrade",
    Default = false,
    Callback = function(value)
        flags.autoBuyCashUpgrade = value
    end,
})
Tabs.Auto:Toggle("AutoBuyDamageUpgrade", {
    Title = "Auto Buy Damage Upgrade",
    Default = false,
    Callback = function(value)
        flags.autoBuyDamageUpgrade = value
    end,
})
Tabs.Auto:Toggle("AutoBuyHealthUpgrade", {
    Title = "Auto Buy Health Upgrade",
    Default = false,
    Callback = function(value)
        flags.autoBuyHealthUpgrade = value
    end,
})

Tabs.Auto:Toggle("AutoKillGlobalBoss", {
    Title = "Auto Kill Global Boss",
    Default = false,
    Callback = function(value)
        flags.autoKillGlobalBoss = value
    end,
})
Tabs.Auto:Toggle("AutoOpenBossChest", {
    Title = "Auto Open Boss Chest",
    Default = false,
    Callback = function(value)
        flags.autoOpenBossChest = value
    end,
})
Tabs.Auto:Toggle("AutoLeaveGlobalBoss", {
    Title = "Auto Leave Global Bosses",
    Default = false,
    Callback = function(value)
        flags.autoLeaveGlobalBoss = value
    end,
})

local potionValues = {"Any"}
for id in pairs(configTable(PotionsConfig, "POTIONS")) do
    table.insert(potionValues, tostring(id))
end

Tabs.Auto:Toggle("AutoUsePotion", {
    Title = "Auto Use Potion",
    Default = false,
    Callback = function(value)
        flags.autoUsePotion = value
    end,
})
Tabs.Auto:Dropdown("PotionFilter", {
    Title = "Potions To Use",
    Values = uniqueValues(potionValues),
    Default = 1,
    Multi = false,
    Callback = function(value)
        flags.potionFilter = value
    end,
})

local function openSuggestionDialog()
    local parent = gethui()
    local previous = parent:FindFirstChild("OuroborosSuggestion")
    if previous then
        previous:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OuroborosSuggestion"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent

    local backdrop = Instance.new("TextButton")
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.AutoButtonColor = false
    backdrop.Text = ""
    backdrop.Parent = screenGui

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(420, 280)
    panel.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
    panel.BorderSizePixel = 0
    panel.Parent = backdrop

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(124, 77, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.45
    stroke.Parent = panel

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Send a Suggestion"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(237, 233, 254)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local inputFrame = Instance.new("Frame")
    inputFrame.Position = UDim2.fromOffset(0, 36)
    inputFrame.Size = UDim2.new(1, 0, 1, -92)
    inputFrame.BackgroundColor3 = Color3.fromRGB(12, 11, 16)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = panel

    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingTop = UDim.new(0, 10)
    inputPadding.PaddingBottom = UDim.new(0, 10)
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.PaddingRight = UDim.new(0, 10)
    inputPadding.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.fromScale(1, 1)
    textBox.BackgroundTransparency = 1
    textBox.Font = Enum.Font.Gotham
    textBox.Text = ""
    textBox.PlaceholderText = "Write your suggestion here..."
    textBox.PlaceholderColor3 = Color3.fromRGB(108, 104, 126)
    textBox.TextColor3 = Color3.fromRGB(228, 225, 238)
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.TextWrapped = true
    textBox.ClearTextOnFocus = false
    textBox.MultiLine = true
    textBox.Parent = inputFrame

    local status = Instance.new("TextLabel")
    status.Position = UDim2.new(0, 0, 1, -40)
    status.Size = UDim2.new(1, -210, 0, 32)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.Text = ""
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(150, 146, 168)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextWrapped = true
    status.Parent = panel

    local cancel = Instance.new("TextButton")
    cancel.AnchorPoint = Vector2.new(1, 1)
    cancel.Position = UDim2.new(1, -105, 1, 0)
    cancel.Size = UDim2.fromOffset(95, 32)
    cancel.BackgroundColor3 = Color3.fromRGB(30, 27, 38)
    cancel.Font = Enum.Font.GothamSemibold
    cancel.Text = "Cancel"
    cancel.TextSize = 14
    cancel.TextColor3 = Color3.fromRGB(237, 233, 254)
    cancel.Parent = panel

    local send = Instance.new("TextButton")
    send.AnchorPoint = Vector2.new(1, 1)
    send.Position = UDim2.new(1, 0, 1, 0)
    send.Size = UDim2.fromOffset(95, 32)
    send.BackgroundColor3 = Color3.fromRGB(124, 77, 255)
    send.Font = Enum.Font.GothamSemibold
    send.Text = "Send"
    send.TextSize = 14
    send.TextColor3 = Color3.fromRGB(237, 233, 254)
    send.Parent = panel

    cancel.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    backdrop.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    panel.InputBegan:Connect(function()
        -- Prevent clicks in the dialog from acting like backdrop clicks.
    end)

    send.MouseButton1Click:Connect(function()
        local suggestion = textBox.Text
        if suggestion:gsub("%s", "") == "" then
            status.Text = "Please enter a suggestion first."
            status.TextColor3 = Color3.fromRGB(220, 130, 130)
            return
        end

        send.AutoButtonColor = false
        status.Text = "Sending..."
        status.TextColor3 = Color3.fromRGB(180, 180, 190)

        task.spawn(function()
            local body = HttpService:JSONEncode({
                username = "Ouroboros Suggestions",
                embeds = {{
                    title = "New Suggestion",
                    description = suggestion,
                    color = 8519847,
                    fields = {{name = "Game", value = "Lucky Block Rush", inline = true}},
                    footer = {text = "Ouroboros Hub"},
                }},
            })

            local ok = executorRequest({
                Url = SUGGESTION_WEBHOOK,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body,
            })

            if ok then
                status.Text = "Thank you. Your suggestion was sent."
                status.TextColor3 = Color3.fromRGB(130, 200, 140)
                task.wait(1.2)
                screenGui:Destroy()
            else
                status.Text = "Failed to send your suggestion."
                status.TextColor3 = Color3.fromRGB(220, 130, 130)
                send.AutoButtonColor = true
            end
        end)
    end)
end

Tabs.Suggestions:Button({Title = "Send a Suggestion", Callback = openSuggestionDialog})

Tabs.Settings:Toggle("KeybindMenuOpen", {
    Title = "Open Keybind Menu",
    Default = false,
    Callback = function(value)
        -- Kept for structural compatibility, but WindUI handles this natively
    end,
})











TrainingService.SpawnBonus:Connect(function(bonusId)
    if flags.autoBonus then
        TrainingService:ClaimBonus(bonusId)
    end
end)

LocalPlayer.Idled:Connect(function()
    if flags.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while true do
        -- The original maintained its combat timing at this interval.
        -- AutorunController performs the actual fight after Start().
        LocalPlayer:GetAttribute("InCombat")
        task.wait(CombatConfig.PLAYER_ATTACK_DEBOUNCE / flags.attackSpeed)
    end
end)

task.spawn(function()
    while true do
        if flags.autoTrain and not LocalPlayer:GetAttribute("InCombat") then
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") and child:HasTag("TrainTool") then
                        TrainingService:Train()
                        break
                    end
                end
            end
        end
        task.wait(flags.trainDelay)
    end
end)

task.spawn(function()
    while true do
        if flags.autoTimeReward then
            local sessionTime = PlaytimeRewardController:GetSessionTime()
            for id, reward in pairs(PlaytimeRewardConfig) do
                if type(reward) == "table"
                    and sessionTime >= (reward.time or math.huge)
                    and not PlaytimeRewardController:IsGiftClaimed(id) then
                    PlaytimeRewardController:ClaimGift(id)
                end
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if flags.autoCollectCash then
            local screen = LocalPlayer.PlayerGui:FindFirstChild("LuckyBlockDropScreen")
            local root = screen and screen:FindFirstChild("StarDropRoot")
            if screen and screen.Enabled and root and root.Visible then
                local viewport = workspace.CurrentCamera.ViewportSize
                local x, y = viewport.X / 2, viewport.Y * 0.45
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)

                local button = root:FindFirstChild("Frame")
                button = button and button:FindFirstChild("TextButton")
                if button and getconnections then
                    for _, signal in ipairs({button.MouseButton1Click, button.MouseButton1Down}) do
                        for _, connection in ipairs(getconnections(signal)) do
                            if connection.Fire then
                                connection:Fire()
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.07)
    end
end)

RunService.Heartbeat:Connect(function()
    if flags.resetBoss == "Off" or LocalPlayer:GetAttribute("InCombat") then
        return
    end

    local selectedBossStillExists = false
    for _, boss in ipairs(Bosses:GetChildren()) do
        if boss.Name == flags.resetBoss then
            selectedBossStillExists = true
            break
        end
    end

    if not selectedBossStillExists then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end)

task.spawn(function()
    while true do
        if flags.autoUpgradeBase then
            WorldUpgradesService:BuyUpgrade(1)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if flags.autoUnlockWorld then
            local data = getData()
            if data then
                local bestId, bestOrder = nil, -math.huge
                for id, biome in pairs(BiomeConfig) do
                    local order = type(biome) == "table" and biome.layoutOrder or 0
                    if order > bestOrder and not owns(data.UnlockedBiomes, id) then
                        bestId, bestOrder = id, order
                    end
                end
                if bestId and data.CurrentBiome ~= bestId then
                    BiomeService:ChangeBiome(bestId)
                end
            end
        end
        task.wait(8)
    end
end)

task.spawn(function()
    while true do
        if flags.autoRebirth then
            RebirthService:Rebirth()
        end
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        if flags.autoBuyAura then
            local data = getData()
            if data then
                local cash = data.Currencies and data.Currencies.Cash or 0
                local bestId, bestDamage = nil, -math.huge
                for id, skin in pairs(PlayerSkinConfig) do
                    if type(skin) == "table" and not owns(data.OwnedSkins, id)
                        and (skin.cost or math.huge) <= cash
                        and (skin.damageMulti or 0) > bestDamage then
                        bestId, bestDamage = id, skin.damageMulti or 0
                    end
                end
                if bestId then
                    SkinService:BuySkin(bestId)
                end
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if flags.autoEquipAura then
            local data = getData()
            if data then
                local bestId, bestDamage = nil, -math.huge
                for id, skin in pairs(PlayerSkinConfig) do
                    if type(skin) == "table" and owns(data.OwnedSkins, id)
                        and (skin.damageMulti or 0) > bestDamage then
                        bestId, bestDamage = id, skin.damageMulti or 0
                    end
                end
                if bestId and data.EquippedPlayerSkin ~= bestId then
                    SkinService:EquipSkin(bestId)
                end
            end
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        if flags.autoBuyDummy then
            local data = getData()
            if data then
                local tools = configTable(TrainToolConfig, "TRAIN_TOOLS")
                local bestId, bestOrder = nil, -math.huge
                for id, tool in pairs(tools) do
                    if type(tool) == "table" and not owns(data.OwnedTrainTools, id)
                        and (tool.cost or math.huge) <= (data.Strength or 0)
                        and (tool.layoutOrder or 0) > bestOrder then
                        bestId, bestOrder = id, tool.layoutOrder or 0
                    end
                end
                if bestId then
                    TrainingService:BuyTrainTool(bestId)
                end
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if flags.autoEquipDummy then
            local data = getData()
            if data then
                local tools = configTable(TrainToolConfig, "TRAIN_TOOLS")
                local bestId, bestGain = nil, -math.huge
                for id, tool in pairs(tools) do
                    if type(tool) == "table" and owns(data.OwnedTrainTools, id)
                        and (tool.gainPerTrain or 0) > bestGain then
                        bestId, bestGain = id, tool.gainPerTrain or 0
                    end
                end
                if bestId and data.EquippedTrainTool ~= bestId then
                    TrainingService:EquipTrainTool(bestId)
                end
            end
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        if flags.autoUpgradeBrainrots and flags.brainrotTarget > 0 then
            local data = getData()
            for containerId, container in pairs(data and data.Containers or {}) do
                local brainrot = type(container) == "table" and container.brainrot
                if brainrot and (brainrot.level or 0) < flags.brainrotTarget then
                    ContainerService:UpgradeBrainrot(containerId)
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if flags.autoPlaceBest then
            ContainerService:PlaceBest()
        end
        task.wait(flags.placeInterval)
    end
end)

task.spawn(function()
    while true do
        if flags.autoBuyTrainUpgrade then
            WorldUpgradesService:BuyUpgrade("TrainUpgrade1")
            WorldUpgradesService:BuyUpgrade("TrainUpgrade2")
        end
        if flags.autoBuyCashUpgrade then
            WorldUpgradesService:BuyUpgrade("CashUpgrade1")
        end
        if flags.autoBuyDamageUpgrade then
            WorldUpgradesService:BuyUpgrade("DamageUpgrade1")
        end
        if flags.autoBuyHealthUpgrade then
            WorldUpgradesService:BuyUpgrade("HealthUpgrade1")
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if flags.autoCollectCash then
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, container in ipairs(CollectionService:GetTagged("Container")) do
                    if container:GetAttribute("OwnerId") == LocalPlayer.UserId then
                        local collection = container:FindFirstChild("Collection")
                        local pad = collection and collection:FindFirstChild("CollectionPad")
                        if pad then
                            firetouchinterest(root, pad, 0)
                            firetouchinterest(root, pad, 1)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if flags.autoKillGlobalBoss and LocalPlayer:GetAttribute("InGlobalBossWorld") then
            for _, boss in ipairs(Bosses:GetChildren()) do
                if boss:HasTag("GlobalBoss") and boss.PrimaryPart then
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if humanoid and root then
                        humanoid:MoveTo(boss.PrimaryPart.Position, boss.PrimaryPart)
                        GlobalBossController:AttackBoss()
                    end
                end
            end
        end
        task.wait(0.12)
    end
end)

task.spawn(function()
    while true do
        if flags.autoOpenBossChest then
            GlobalBossEventService:Claim()
            local data = getData()
            for starBlockId, count in pairs(data and data.StarBlocksInventory or {}) do
                if count > 0 then
                    StarBlockService:Open(starBlockId)
                end
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if flags.autoLeaveGlobalBoss and LocalPlayer:GetAttribute("InGlobalBossWorld") then
            GlobalBossEventService:End()
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        if flags.autoUsePotion then
            local data = getData()
            local inventory = data and data.PotionInventory or {}
            local active = data and data.ActivePotions or {}
            for potionId, count in pairs(inventory) do
                if count > 0 and active[potionId] == nil
                    and (flags.potionFilter == "Any" or tostring(potionId) == tostring(flags.potionFilter)) then
                    PotionService:UsePotion(potionId)
                end
            end
        end
        task.wait(2)
    end
end)

local function sellInventoryItem(uuid)
    InventoryService:Sell(uuid)
end

task.spawn(function()
    while true do
        if flags.autoSellBrainrots then
            local data = getData()
            for key, item in pairs(data and data.Inventory or {}) do
                if type(item) == "table" and not item.locked then
                    local entity = item.innerEntity or item
                    local itemType = item.itemType or entity.itemType
                    if (itemType == "Brainrot" or entity.brainrot ~= nil)
                        and selected(flags.sellMutationFilter, entity.mutation)
                        and selected(flags.sellRarityFilter, entity.rarity) then
                        sellInventoryItem(item.uuid or key)
                    end
                end
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if flags.autoSellLuckyBlock then
            local data = getData()
            for key, item in pairs(data and data.Inventory or {}) do
                if type(item) == "table" then
                    local itemType = item.itemType or (item.innerEntity and item.innerEntity.itemType)
                    if itemType == "LuckyBlock" or itemType == "StarBlock" then
                        sellInventoryItem(item.uuid or key)
                    end
                end
            end
        end
        task.wait(3)
    end
end)

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "OuroborosToggle"
toggleGui.ResetOnSpawn = false
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.Parent = gethui()

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.fromOffset(52, 52)
toggleButton.Position = UDim2.fromScale(0.5, 0.04)
toggleButton.AnchorPoint = Vector2.new(0.5, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Image = "rbxassetid://91400086538074"
toggleButton.ScaleType = Enum.ScaleType.Fit
toggleButton.AutoButtonColor = true
toggleButton.Parent = toggleGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = toggleButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(80, 80, 95)
buttonStroke.Thickness = 1
buttonStroke.Transparency = 0.3
buttonStroke.Parent = toggleButton

local buttonPadding = Instance.new("UIPadding")
buttonPadding.PaddingTop = UDim.new(0, 6)
buttonPadding.PaddingBottom = UDim.new(0, 6)
buttonPadding.PaddingLeft = UDim.new(0, 6)
buttonPadding.PaddingRight = UDim.new(0, 6)
buttonPadding.Parent = toggleButton

local dragging = false
local dragStart
local startPosition

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = toggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)


-- Kept because the original resolves this controller even though the traced
-- automation path delegates combat to AutorunController and global boss code.
if not AttackController then
    warn("AttackController was not available")
end


-- ==========================================
-- HEARTBEAT ANTI-AFK & UNLOAD
-- ==========================================

Tabs.Settings:Toggle({
    Title = "Anti-AFK (Heartbeat)",
    Desc = "Spams VirtualUser clicks to prevent AFK kick entirely.",
    Default = false,
    Callback = function(Value)
        flags.antiAfk = Value
        if Value then
            if not flags.HeartbeatConn then
                flags.HeartbeatConn = RunService.Heartbeat:Connect(function()
                    pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
                end)
            end
        else
            if flags.HeartbeatConn then 
                flags.HeartbeatConn:Disconnect()
                flags.HeartbeatConn = nil
            end
        end
    end
})

Tabs.Settings:Button({
    Title = "Unload UI",
    Callback = function()
        shared.IndraHub_LuckyRush_Unloaded = true
        if flags.HeartbeatConn then flags.HeartbeatConn:Disconnect() end
        if Window and Window.Destroy then Window:Destroy() end
    end
})

WindUI:Notify({ Title = "IndraHub", Content = "Loaded Lucky Block Rush successfully!", Duration = 5 })
