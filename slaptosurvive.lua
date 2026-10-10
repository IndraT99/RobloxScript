local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Configs = ReplicatedStorage:WaitForChild("ReplicatedModules"):WaitForChild("Configs")
local WeaponConfig = require(Configs:WaitForChild("WeaponConfig"))
local ShopConfig = require(Configs:WaitForChild("ShopConfig"))

local Swing = Remotes:WaitForChild("Swing", 10)
local PlaceMine = Remotes:WaitForChild("PlaceMine", 10)
local Shop = Remotes:WaitForChild("Shop", 10)
local Quest = Remotes:WaitForChild("Quest", 10)

local GAME_NAME = "Slap to Survive"
local DISCORD_INVITE = "https://discord.gg/ehKVq7pf7v"
local RSCRIPTS_LINK = "https://rscripts.net/@Ouroboros"

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

_G.__INDRA_SLAP = (_G.__INDRA_SLAP or 0) + 1
local GEN = _G.__INDRA_SLAP

setGlobal("IndraHubSlapToSurviveRunning", true)
setGlobal("IndraHubSlapToSurviveLastHeartbeat", os.clock())

task.spawn(function()
    while _G.__INDRA_SLAP == GEN and getGlobal("IndraHubSlapToSurviveRunning") do
        task.wait(2)
        setGlobal("IndraHubSlapToSurviveLastHeartbeat", os.clock())
        setGlobal("IndraHubSlapToSurviveRunning", true)
        if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubSlapToSurviveLastHeartbeat"] then
            _G.IndraHubStatus["IndraHubSlapToSurviveLastHeartbeat"].heartbeat = os.clock()
        end
    end
end)

if env.__IndraHubSlapToSurviveLib and env.__IndraHubSlapToSurviveLib.Unload then
    pcall(function() env.__IndraHubSlapToSurviveLib:Unload() end)
end

local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI or not WindUI then
    warn("[IndraHub] Failed to load WindUI")
    setGlobal("IndraHubSlapToSurviveError", "WINDUI FAIL")
    return
end

local RealWindow = WindUI:CreateWindow({
    Title = "IndraHub | Slap to Survive",
    Icon = "swords",
    Author = "IndraHub",
    Folder = "IndraHub_SlapToSurvive",
    Size = UDim2.fromOffset(640, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 185,
    HasOutline = true
})

local Toggles = {}
local Options = {
    AuraMethod = { Value = "Strafe" },
    AuraRange = { Value = 250 },
    AuraDistance = { Value = 6 },
    AuraHeight = { Value = 5 },
    AuraStrafeSpeed = { Value = 4 },
    AuraSwingBurst = { Value = 1 },
    AuraDelay = { Value = 0.03 },
    BuyDelay = { Value = 2 },
    QuestDelay = { Value = 3 }
}

local Library = {
    Unloaded = false,
    Toggles = Toggles,
    Options = Options,
    _unloadCallbacks = {},
    OnUnload = function(self, cb)
        table.insert(self._unloadCallbacks, cb)
    end,
    Unload = function(self)
        if self.Unloaded then return end
        self.Unloaded = true
        setGlobal("IndraHubSlapToSurviveRunning", false)
        for _, cb in ipairs(self._unloadCallbacks) do
            pcall(cb)
        end
        pcall(function() RealWindow:Destroy() end)
        if getgenv then
            getgenv().__IndraHubSlapToSurviveLib = nil
        end
    end,
    Notify = function(self, msg)
        pcall(function()
            WindUI:Notify({
                Title = "IndraHub",
                Content = tostring(msg or ""),
                Duration = 3.5
            })
        end)
    end
}

if getgenv then
    getgenv().__IndraHubSlapToSurviveLib = Library
end

local function copyText(text, message)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    end
    Library:Notify(message)
end

local function copyDiscord()
    copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end

local function colored(text, color)
    return string.format('<font color="%s">%s</font>', color, text)
end

local function field(key, value, color)
    return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
end

local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"

local shopState = { owned = {}, cash = 0, equipped = nil }
local questState = {}
local questsClaimed = 0
local auraAnchor = nil
local lockedMonster = nil
local collisionState = {}
local anchoredRoot = nil
local anchoredState = false

local function isOn(name)
    local toggle = Toggles[name]
    return toggle ~= nil and toggle.Value == true
end

local function getNumber(name, fallback)
    local option = Options[name]
    return option and tonumber(option.Value) or fallback
end

local function getChoice(name, fallback)
    local option = Options[name]
    return option and option.Value or fallback
end

local function getRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function isAlive()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

local function getEquippedTool()
    local character = LocalPlayer.Character
    local tool = character and character:FindFirstChildOfClass("Tool")
    if tool and WeaponConfig.DefOf(tool) then
        return tool
    end
    return nil
end

local function requestShop(action, key)
    if not Shop then
        return nil
    end
    local ok, result = pcall(function()
        return Shop:InvokeServer(action, key)
    end)
    if not ok or type(result) ~= "table" then
        return nil
    end
    if type(result.owned) == "table" then
        shopState.owned = result.owned
    end
    if tonumber(result.cash) then
        shopState.cash = tonumber(result.cash)
    end
    if result.equipped then
        shopState.equipped = result.equipped
    end
    return result
end

local function bestOwnedWeapon()
    local best, bestDamage
    for key in shopState.owned do
        local def = WeaponConfig.Tools[key]
        local damage = def and def.damage or 0
        if damage > 0 and (not best or damage > bestDamage) then
            best, bestDamage = key, damage
        end
    end
    return best
end

local function equipBestWeapon()
    local best = bestOwnedWeapon()
    if best and best ~= shopState.equipped then
        requestShop("equip", best)
    end
end

local function nearestMonster(origin, range)
    local monsters = workspace:FindFirstChild("Monsters")
    if not monsters then
        return nil, nil
    end
    local best, bestPart, bestDistance
    for _, model in monsters:GetChildren() do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if humanoid and humanoid.Health > 0 and part then
            local distance = (part.Position - origin).Magnitude
            if distance <= range and (not bestDistance or distance < bestDistance) then
                best, bestPart, bestDistance = model, part, distance
            end
        end
    end
    return best, bestPart, bestDistance
end

local function validMonster(model)
    if not model or not model.Parent then
        return false
    end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    return humanoid ~= nil and humanoid.Health > 0 and part ~= nil
end

local function setFarmNoclip(enabled)
    local character = LocalPlayer.Character
    if enabled and character then
        for _, descendant in character:GetDescendants() do
            if descendant:IsA("BasePart") then
                if collisionState[descendant] == nil then
                    collisionState[descendant] = descendant.CanCollide
                end
                descendant.CanCollide = false
            end
        end
        return
    end
    for part, canCollide in collisionState do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    table.clear(collisionState)
end

local function clearFarmVelocity()
    local character = LocalPlayer.Character
    if not character then
        return
    end
    for _, descendant in character:GetDescendants() do
        if descendant:IsA("BasePart") then
            descendant.AssemblyLinearVelocity = Vector3.zero
            descendant.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function setAntiFling(enabled)
    local root = getRoot()
    if enabled and root then
        if anchoredRoot ~= root then
            if anchoredRoot and anchoredRoot.Parent then
                anchoredRoot.Anchored = anchoredState
            end
            anchoredRoot = root
            anchoredState = root.Anchored
        end
        clearFarmVelocity()
        root.Anchored = true
        return
    end
    if anchoredRoot and anchoredRoot.Parent then
        anchoredRoot.Anchored = anchoredState
    end
    anchoredRoot = nil
    anchoredState = false
end

local function farmCFrame(targetPart)
    local method = getChoice("AuraMethod", "Strafe")
    local distance = getNumber("AuraDistance", 6)
    local height = getNumber("AuraHeight", 5)
    local targetPosition = targetPart.Position
    local position

    if method == "Above" then
        position = targetPosition + Vector3.new(0, height, 0)
    elseif method == "Under" then
        position = targetPosition - Vector3.new(0, height, 0)
    elseif method == "Behind" then
        position = targetPosition - targetPart.CFrame.LookVector * distance + Vector3.new(0, 1.5, 0)
    else
        local angle = os.clock() * getNumber("AuraStrafeSpeed", 4)
        position = targetPosition + Vector3.new(math.cos(angle) * distance, height, math.sin(angle) * distance)
    end

    local upVector = (method == "Above" or method == "Under") and Vector3.new(0, 0, -1) or Vector3.new(0, 1, 0)
    return CFrame.lookAt(position, targetPosition, upVector)
end

local function restoreAnchor()
    local root = getRoot()
    if root and auraAnchor then
        root.CFrame = auraAnchor
    end
    setAntiFling(false)
    auraAnchor = nil
    lockedMonster = nil
    setFarmNoclip(false)
end

local CombatTab = RealWindow:Tab({ Title = "Combat", Icon = "swords" })
local ShopTab = RealWindow:Tab({ Title = "Shop & Quests", Icon = "shopping-bag" })
local SettingsTab = RealWindow:Tab({ Title = "Settings", Icon = "settings" })

CombatTab:Section({ Title = "Auto Farm" })

CombatTab:Toggle({
    Title = "Auto Farm",
    Desc = "Automatically targets and farms nearest monsters",
    Default = false,
    Callback = function(value)
        Toggles.KillAura = { Value = value }
        if value then
            local root = getRoot()
            auraAnchor = root and root.CFrame or nil
        else
            restoreAnchor()
        end
    end
})

CombatTab:Toggle({
    Title = "Equip Best Weapon",
    Default = true,
    Callback = function(val)
        Toggles.AuraEquipBest = { Value = val }
    end
})

CombatTab:Toggle({
    Title = "Move To Target",
    Default = true,
    Callback = function(val)
        Toggles.AuraTeleport = { Value = val }
    end
})

CombatTab:Dropdown({
    Title = "Farm Method",
    Values = { "Strafe", "Above", "Under", "Behind" },
    Value = "Strafe",
    Callback = function(val)
        Options.AuraMethod = { Value = val }
    end
})

CombatTab:Toggle({
    Title = "Lock Target Until Dead",
    Default = true,
    Callback = function(val)
        Toggles.AuraTargetLock = { Value = val }
    end
})

CombatTab:Toggle({
    Title = "Noclip While Farming",
    Default = true,
    Callback = function(val)
        Toggles.AuraNoclip = { Value = val }
    end
})

CombatTab:Toggle({
    Title = "Anti Fling / Knockback",
    Default = true,
    Callback = function(val)
        Toggles.AuraAntiKnockback = { Value = val }
    end
})

CombatTab:Toggle({
    Title = "Return To Start Position",
    Default = true,
    Callback = function(val)
        Toggles.AuraReturn = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Search Range",
    Default = 250,
    Min = 20,
    Max = 1000,
    Callback = function(val)
        Options.AuraRange = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Strafe / Behind Distance",
    Default = 6,
    Min = 2,
    Max = 25,
    Callback = function(val)
        Options.AuraDistance = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Vertical Offset",
    Default = 5,
    Min = 2,
    Max = 30,
    Callback = function(val)
        Options.AuraHeight = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Strafe Speed",
    Default = 4,
    Min = 0.5,
    Max = 15,
    Callback = function(val)
        Options.AuraStrafeSpeed = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Swing Burst",
    Default = 1,
    Min = 1,
    Max = 5,
    Callback = function(val)
        Options.AuraSwingBurst = { Value = val }
    end
})

CombatTab:Slider({
    Title = "Attack Delay",
    Default = 0.03,
    Min = 0.01,
    Max = 1,
    Callback = function(val)
        Options.AuraDelay = { Value = val }
    end
})

CombatTab:Section({ Title = "Manual Actions" })

CombatTab:Button({
    Title = "Equip Best Weapon",
    Desc = "Checks shop inventory and equips highest damage weapon",
    Callback = function()
        requestShop("state")
        equipBestWeapon()
    end
})

-- Shop Tab
ShopTab:Section({ Title = "Auto Buy Weapons" })

ShopTab:Toggle({
    Title = "Auto Buy Weapons",
    Desc = "Automatically purchases next tier weapon when affordable",
    Default = false,
    Callback = function(val)
        Toggles.AutoBuyWeapons = { Value = val }
    end
})

ShopTab:Toggle({
    Title = "Equip Best After Buying",
    Default = true,
    Callback = function(val)
        Toggles.AutoEquipBought = { Value = val }
    end
})

ShopTab:Slider({
    Title = "Buy Check Delay",
    Default = 2,
    Min = 0.5,
    Max = 30,
    Callback = function(val)
        Options.BuyDelay = { Value = val }
    end
})

ShopTab:Button({
    Title = "Refresh Shop State",
    Callback = function()
        requestShop("state")
    end
})

ShopTab:Section({ Title = "Auto Claim Quests" })

ShopTab:Toggle({
    Title = "Auto Claim Quests",
    Desc = "Claims completed quests automatically",
    Default = false,
    Callback = function(val)
        Toggles.AutoClaimQuests = { Value = val }
    end
})

ShopTab:Slider({
    Title = "Quest Check Delay",
    Default = 3,
    Min = 1,
    Max = 60,
    Callback = function(val)
        Options.QuestDelay = { Value = val }
    end
})

-- Settings Tab
SettingsTab:Section({ Title = "Anti-AFK & Automation" })

SettingsTab:Toggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(val)
        Toggles.AntiAfk = { Value = val }
    end
})

SettingsTab:Section({ Title = "Script Management" })

SettingsTab:Button({
    Title = "Unload IndraHub",
    Desc = "Stops all loops and unloads user interface cleanly",
    Callback = function()
        Library:Unload()
    end
})

local antiAfkLastInput = tick()
local antiAfkLastTap = tick()

pcall(function()
    for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
        pcall(function()
            connection:Disable()
        end)
    end
end)

local function antiAfkTap()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    antiAfkLastTap = tick()
end

local antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
    antiAfkLastInput = tick()
end)

local antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
        antiAfkLastInput = tick()
    end
end)

Library:OnUnload(function()
    antiAfkBeganConnection:Disconnect()
    antiAfkChangedConnection:Disconnect()
    restoreAnchor()
    print("Slap to Survive unloaded")
end)

requestShop("state")

task.spawn(function()
    while not Library.Unloaded do
        if isOn("KillAura") and isOn("AuraTeleport") and isAlive() and validMonster(lockedMonster) then
            local root = getRoot()
            local character = LocalPlayer.Character
            local part = lockedMonster:FindFirstChild("HumanoidRootPart") or lockedMonster.PrimaryPart
            if root and character and part then
                setAntiFling(isOn("AuraAntiKnockback"))
                character:PivotTo(farmCFrame(part))
                clearFarmVelocity()
            end
        else
            setAntiFling(false)
        end
        task.wait(0.03)
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        if isOn("KillAura") and Swing and isAlive() then
            setFarmNoclip(isOn("AuraNoclip"))
            if isOn("AuraEquipBest") then
                equipBestWeapon()
            end
            local root = getRoot()
            local tool = getEquippedTool()
            local def = tool and WeaponConfig.DefOf(tool)
            if root and def then
                if not auraAnchor then
                    auraAnchor = root.CFrame
                end
                if not isOn("AuraTargetLock") or not validMonster(lockedMonster) then
                    lockedMonster = nearestMonster(root.Position, getNumber("AuraRange", 250))
                end
                local model = lockedMonster
                local part = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
                if part then
                    if isOn("AuraTeleport") then
                        setAntiFling(isOn("AuraAntiKnockback"))
                        local character = LocalPlayer.Character
                        if character then
                            character:PivotTo(farmCFrame(part))
                        end
                        clearFarmVelocity()
                    end
                    if def.behavior == "Mine" and PlaceMine then
                        pcall(function()
                            PlaceMine:FireServer(part.Position)
                        end)
                    else
                        local direction = nil
                        if def.behavior == "RayBlast" then
                            local handle = tool:FindFirstChild("Handle")
                            local origin = handle and handle.Position or root.Position
                            local delta = part.Position - origin
                            direction = delta.Magnitude > 0.5 and delta.Unit or nil
                        end
                        local burst = math.max(1, math.floor(getNumber("AuraSwingBurst", 1)))
                        for index = 1, burst do
                            pcall(function()
                                Swing:FireServer(0, direction)
                            end)
                            if index < burst then
                                task.wait(0.005)
                            end
                        end
                    end
                elseif isOn("AuraReturn") and auraAnchor and (root.Position - auraAnchor.Position).Magnitude > 5 then
                    root.CFrame = auraAnchor
                end
            end
        else
            setFarmNoclip(false)
            setAntiFling(false)
        end
        task.wait(getNumber("AuraDelay", 0.03))
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoBuyWeapons") and Shop then
            local state = requestShop("state")
            if state then
                local key = ShopConfig.NextBuyable(shopState.owned)
                local entry = key and ShopConfig.Weapons[key]
                local price = entry and entry.price or 0
                if key and price > 0 and price <= shopState.cash then
                    local result = requestShop("buy", key)
                    if result and result.bought then
                        Library:Notify("Bought " .. (entry.displayName or key))
                        if isOn("AutoEquipBought") then
                            equipBestWeapon()
                        end
                    end
                end
            end
        end
        task.wait(getNumber("BuyDelay", 2))
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        if Quest then
            local ok, state = pcall(function()
                return Quest:InvokeServer("state")
            end)
            if ok and type(state) == "table" and type(state.quests) == "table" then
                questState = state.quests
                if isOn("AutoClaimQuests") then
                    for _, quest in questState do
                        if quest.complete and not quest.claimed and quest.id then
                            local claimed = pcall(function()
                                return Quest:InvokeServer("claim", quest.id)
                            end)
                            if claimed then
                                questsClaimed += 1
                                Library:Notify("Claimed quest: " .. tostring(quest.name))
                            end
                        end
                    end
                end
            end
        end
        task.wait(getNumber("QuestDelay", 3))
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if isOn("AntiAfk") then
            local idle = tick() - antiAfkLastInput
            local sinceTap = tick() - antiAfkLastTap
            if (idle >= 180 and sinceTap >= 60) or sinceTap >= 300 then
                pcall(antiAfkTap)
            end
        end
    end
end)

Library:Notify("Slap to Survive module loaded successfully!")
