-- IndraHub Rivals

local version = "1.252"
local HUB_NAME = "IndraHub Rivals"
local CONFIG_FOLDER = "IndraHub_Rivals"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

local function loadWindUI()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    local fn = loadstring(source)
    return fn()
end

local okWindUI, WindUI = pcall(loadWindUI)
if not okWindUI or type(WindUI) ~= "table" then
    warn("[IndraHub Rivals] WindUI load failed: " .. tostring(WindUI))
    return
end

local function notify(title, content, icon, duration)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({ Title = title, Content = content, Icon = icon or "info", Duration = duration or 3 })
        end)
    else
        print(tostring(title) .. ": " .. tostring(content))
    end
end

notify(HUB_NAME, "Loading...", "loader", 2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local hubRank = "Guest"

--config
local config_beta = {
    Aim = {
        enabled = false,
        raycast = false,
        bone = "Head",
    },
    Visual = {
        esp = false,
        night = false,
    },
    Skins = {
        Assault_Rifle = "none",
        Sniper = "none",
        Crossbow = "none",
        Handgun = "none",
        Revolver = "none",
        Knife = "none",
        Katana = "none",
    },
    Other = {
        ver = 2,
        gamever = version,
        
    },
}

makefolder(CONFIG_FOLDER)
if isfile(CONFIG_FILE) then
    local Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
    if Config.Other.ver == config_beta.Other.ver then
    else
        local jsonString = HttpService:JSONEncode(config_beta)
        local Config = writefile(CONFIG_FILE, jsonString)
        notify(HUB_NAME, "Your config is old, reset done", "triangle-alert", 4)
    end
else
    local jsonString = HttpService:JSONEncode(config_beta)
    local Config = writefile(CONFIG_FILE, jsonString)
    
end

local rankdatabase = {
    Developer = {"Ta1ovi"},
    Premium = {"Ta1ovi"},
    Banned = {"Roblox"},
}


function checkPlayerRank(playerName)
    for role, players in pairs(rankdatabase) do
        for _, name in ipairs(players) do
            if name == playerName then
                hubRank = role
                return
            end
        end
    end
end

checkPlayerRank(LocalPlayer.Name)

local skinAcess = false
if hubRank == "Developer" then
    skinAcess = true
elseif hubRank == "Premium" then
    skinAcess = true
end


local silentAimActive = false
local raycastAimEnabled = false
local raycastAimBone = "Head"
local raycastAimRange = math.huge
local raycastUtility = nil
local originalRaycast = nil
local esp = loadstring(game:HttpGet('https://pastebin.com/raw/HALrE6Z0'))()
esp.enabled = false

if true then
    local Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
    Config.Aim = Config.Aim or {}
    Config.Visual = Config.Visual or {}
    
    silentAimActive = Config.Aim.enabled
    raycastAimEnabled = Config.Aim.raycast == true
    raycastAimBone = Config.Aim.bone or "Head"
    esp.enabled = Config.Visual.esp
end

 
local noClip = false

local function getRaycastPool()
    local pool = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:FindFirstChildOfClass("Humanoid") then
            pool[#pool + 1] = obj
        elseif obj.Name == "HurtEffect" then
            for _, child in ipairs(obj:GetChildren()) do
                if child.ClassName ~= "Highlight" then
                    pool[#pool + 1] = child
                end
            end
        end
    end
    return pool
end

local function findRaycastTarget()
    local currentCamera = Workspace.CurrentCamera
    if not currentCamera then return nil end

    local center = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
    local winner, record = nil, raycastAimRange

    for _, model in ipairs(getRaycastPool()) do
        if model ~= LocalPlayer.Character and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild(raycastAimBone) then
            local point, visible = currentCamera:WorldToViewportPoint(model[raycastAimBone].Position)
            if visible then
                local distance = (center - Vector2.new(point.X, point.Y)).Magnitude
                if distance < record then
                    winner = model
                    record = distance
                end
            end
        end
    end

    return winner and winner:FindFirstChild(raycastAimBone)
end

local function installRaycastAim()
    if originalRaycast then return true end

    local ok, utility = pcall(function()
        return require(ReplicatedStorage.Modules.Utility)
    end)
    if not ok or type(utility) ~= "table" or type(utility.Raycast) ~= "function" then
        notify("Raycast Aim", "Utility.Raycast not found", "triangle-alert", 4)
        return false
    end

    raycastUtility = utility
    originalRaycast = utility.Raycast
    utility.Raycast = function(...)
        local args = { ... }
        if not raycastAimEnabled or args[4] ~= 999 then
            return originalRaycast(...)
        end

        local dir = args[3] - args[2]
        if dir.Magnitude > 0 and dir.Unit.Y < -0.7 then
            return originalRaycast(...)
        end

        local target = findRaycastTarget()
        if target then
            args[3] = target.Position
        end

        return originalRaycast(table.unpack(args))
    end

    return true
end

local function setRaycastAim(value)
    if value and not installRaycastAim() then
        raycastAimEnabled = false
        return
    end
    raycastAimEnabled = value
end

if raycastAimEnabled then setRaycastAim(true) end

local function applyNoClip(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not noClip
        end
    end
    if character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CanCollide = not noClip
    end
end
local function setNoClip(enabled)
    noClip = enabled
    applyNoClip(LocalPlayer.Character)
end
 
function toggleNoClip()
    setNoClip(not noClip)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 100
local maxFlySpeed = 1000
local speedIncrement = 0.4
local originalGravity = workspace.Gravity

LocalPlayer.CharacterAdded:Connect(function(newCharacter) 
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

local function randomizeValue(value, range)
    return value + (value * (math.random(-range, range) / 100))
end

local function fly()
    
    while flying do
        local MoveDirection = Vector3.new()
        local cameraCFrame = workspace.CurrentCamera.CFrame

        MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.W) and cameraCFrame.LookVector or Vector3.new())
        MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.S) and cameraCFrame.LookVector or Vector3.new())
        MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.A) and cameraCFrame.RightVector or Vector3.new())
        MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.D) and cameraCFrame.RightVector or Vector3.new())
        MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0, 1, 0) or Vector3.new())
        MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Vector3.new(0, 1, 0) or Vector3.new())

        if MoveDirection.Magnitude > 0 then
            flySpeed = math.min(flySpeed + speedIncrement, maxFlySpeed) 
            MoveDirection = MoveDirection.Unit * math.min(randomizeValue(flySpeed, 10), maxFlySpeed)
            HumanoidRootPart.Velocity = MoveDirection * 0.5
        else
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) 
        end

        RunService.RenderStepped:Wait() 
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        flying = not flying
        if flying then
            workspace.Gravity = 0 
            fly()
        else
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            workspace.Gravity = originalGravity    
        end
    end
end)

function GetPlayerViewModels()
    if workspace:FindFirstChild("ViewModels") then
        local ViewModelsObject = workspace.ViewModels
        if ViewModelsObject.FirstPerson:GetChildren()[1] ~= nil then
            local PlayerViewModels = ViewModelsObject.FirstPerson:GetChildren()[1]
            return PlayerViewModels
        else
            return nil
        end
    else
        return nil
    end
end

function MakeNight()
    for _, obj in game:GetDescendants() do
        if true then
            pcall(function()
                if obj.Reflectance == 0 then
                    obj.Reflectance = 0.15
                end
            end)
        else
            pcall(function()
                obj.Reflectance = 0.15
            end)
        end
    end
    while wait(0.25) do
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.ClockTime = 0
    end
end

function CustomGunMaterial()
    while task.wait(.1) do
        local PlayerViewModels = GetPlayerViewModels()
        if PlayerViewModels ~= nil then
            if true then
                for _, obj in PlayerViewModels:GetDescendants() do
                    if obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("UnionOperation") then
                        obj.Material = "Neon"
                        obj.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    end
end

local activeWeapons = {} local playerName = game:GetService("Players").LocalPlayer.Name local assetFolder = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels local skinlib = {}
function skinlib:change(normalWeaponName, skinName)
    if not normalWeaponName then return end
    local normalWeapon = assetFolder:FindFirstChild(normalWeaponName)
    if not normalWeapon then return end
    if true then
        if skinName then
            local skin = assetFolder:FindFirstChild(skinName)
            if not skin then
                return
            end
 
            normalWeapon:ClearAllChildren()
            for _, child in pairs(skin:GetChildren()) do
                local newChild = child:Clone()
                newChild.Parent = normalWeapon
            end
            activeWeapons[normalWeaponName] = true
        end
    else
        activeWeapons[normalWeaponName] = nil
    end
end

local cosmeticUnlockerInstalled = false
local cosmeticEquipped = {}
local cosmeticFavorites = {}
local cosmeticSaveLock = false
local COSMETIC_CONFIG_FILE = CONFIG_FOLDER .. "/cosmetics.json"

local function installSkinchangerBypass()
    pcall(function()
        if type(hookfunction) ~= "function" or type(newcclosure) ~= "function" or type(getrenv) ~= "function" then return end
        local originalSetMetatable
        originalSetMetatable = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
            if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                local trace = debug.traceback()
                if type(trace) == "string" and trace:find("MiscellaneousController", 1, true) then
                    return originalSetMetatable({ 1, 2, 3 }, {})
                end
            end
            return originalSetMetatable(tbl, mt)
        end))
    end)

    task.spawn(function()
        pcall(function()
            local tags = { "anticheat", "ac", "detection", "ban", "kick", "security", "moderation" }
            local function processScript(obj)
                pcall(function()
                    if not (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then return end
                    local okName, name = pcall(function() return obj.Name:lower() end)
                    if not okName or not name then return end
                    for _, tag in ipairs(tags) do
                        if name:find(tag, 1, true) then
                            pcall(function() obj.Disabled = true end)
                            break
                        end
                    end
                end)
            end

            for _, obj in ipairs(game:GetDescendants()) do
                processScript(obj)
            end
            game.DescendantAdded:Connect(processScript)
        end)

        pcall(function()
            local networkClient = game:GetService("NetworkClient")
            if not networkClient then return end
            networkClient.ChildAdded:Connect(function(child)
                pcall(function()
                    local okName, name = pcall(function() return child.Name:lower() end)
                    if okName and name and (name:find("anticheat", 1, true) or name:find("detection", 1, true)) then
                        pcall(function() child:Destroy() end)
                    end
                end)
            end)
        end)
    end)

    pcall(function()
        local fakeEvent = Instance.new("RemoteEvent")
        fakeEvent.Name = "ClientAlert"
        fakeEvent.Parent = LocalPlayer
    end)

    pcall(function()
        if type(getgc) ~= "function" or type(getfenv) ~= "function" or not debug or type(debug.getconstants) ~= "function" or type(hookfunction) ~= "function" then return end
        local replicatedFirst = game:GetService("ReplicatedFirst")
        local targetScript = replicatedFirst:WaitForChild("LocalScript3", 10)
        for _, fn in ipairs(getgc(false)) do
            repeat
                if type(fn) ~= "function" then break end
                local okEnv, env = pcall(getfenv, fn)
                if not okEnv or type(env) ~= "table" then break end
                local okScript, scriptObj = pcall(function() return rawget(env, "script") end)
                if not okScript or not scriptObj or typeof(scriptObj) ~= "Instance" then break end
                local okString, scriptName = pcall(tostring, scriptObj)
                if not okString then break end
                if not (scriptObj == targetScript or (type(scriptName) == "string" and scriptName:find("LoadingScreen", 1, true))) then break end
                local okConstants, constants = pcall(debug.getconstants, fn)
                if not okConstants or type(constants) ~= "table" then break end
                for _, constant in ipairs(constants) do
                    if type(constant) == "string" and (constant:find("TakeTheL", 1, true) or constant:find("ban", 1, true) or constant:find("kick", 1, true)) then
                        pcall(function() hookfunction(fn, function() end) end)
                        break
                    end
                end
            until true
        end
    end)
end

local function installCosmeticUnlocker()
    if cosmeticUnlockerInstalled then
        notify("Skinchanger", "Unlocker already enabled", "check", 3)
        return true
    end

    installSkinchangerBypass()

    local ok, err = pcall(function()
        local modules = ReplicatedStorage:WaitForChild("Modules", 10)
        local controllers = LocalPlayer.PlayerScripts:WaitForChild("Controllers", 10)
        local enumLib = require(modules:WaitForChild("EnumLibrary", 10))
        local cosmeticLib = require(modules:WaitForChild("CosmeticLibrary", 10))
        local dataCtrl = require(controllers:WaitForChild("PlayerDataController", 10))

        if enumLib then pcall(function() enumLib:WaitForEnumBuilder() end) end

        local cosmeticTypes = { Skin = true, Wrap = true, Charm = true, Dance = true, Emote = true }
        local function isCosmeticType(cosmetic)
            return cosmetic and cosmeticTypes[cosmetic.Type] == true
        end

        local function cloneCosmetic(name, cosmeticType, options)
            local base = cosmeticLib.Cosmetics[name]
            if not base then return nil end

            local cloned = {}
            for key, value in pairs(base) do cloned[key] = value end
            cloned.Name = name
            cloned.Type = cloned.Type or cosmeticType
            cloned.Seed = cloned.Seed or math.random(1, 1000000)
            if enumLib then
                local enumOk, enumId = pcall(enumLib.ToEnum, enumLib, name)
                if enumOk and enumId then
                    cloned.Enum = enumId
                    cloned.ObjectID = cloned.ObjectID or enumId
                end
            end
            if options then
                if options.IsInverted ~= nil then cloned.Inverted = options.IsInverted end
                if options.OnlyUseFavorites ~= nil then cloned.OnlyUseFavorites = options.OnlyUseFavorites end
            end
            return cloned
        end

        local function stripCosmeticsForSave()
            local equipped = {}
            for weaponName, cosmetics in pairs(cosmeticEquipped) do
                equipped[weaponName] = {}
                for cosmeticType, cosmetic in pairs(cosmetics) do
                    if cosmetic and cosmetic.Name then
                        equipped[weaponName][cosmeticType] = {
                            Name = cosmetic.Name,
                            Inverted = cosmetic.Inverted,
                            OnlyUseFavorites = cosmetic.OnlyUseFavorites,
                        }
                    end
                end
            end
            return { equipped = equipped, favorites = cosmeticFavorites }
        end

        local function saveCosmeticConfig()
            if type(writefile) ~= "function" or cosmeticSaveLock then return end
            cosmeticSaveLock = true
            task.spawn(function()
                task.wait(1)
                local payload = stripCosmeticsForSave()
                local okEncode, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
                if okEncode then pcall(writefile, COSMETIC_CONFIG_FILE, encoded) end
                cosmeticSaveLock = false
            end)
        end

        local function loadCosmeticConfig()
            if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
            local okExists, exists = pcall(isfile, COSMETIC_CONFIG_FILE)
            if not okExists or not exists then return end

            local okRead, raw = pcall(readfile, COSMETIC_CONFIG_FILE)
            if not okRead or type(raw) ~= "string" or raw == "" then return end

            local okDecode, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if not okDecode or type(decoded) ~= "table" then return end

            cosmeticFavorites = type(decoded.favorites) == "table" and decoded.favorites or {}
            cosmeticEquipped = {}
            if type(decoded.equipped) == "table" then
                for weaponName, cosmetics in pairs(decoded.equipped) do
                    cosmeticEquipped[weaponName] = {}
                    for cosmeticType, saved in pairs(cosmetics) do
                        if saved and saved.Name and cosmeticLib.Cosmetics[saved.Name] then
                            local cloned = cloneCosmetic(saved.Name, cosmeticType, {
                                IsInverted = saved.Inverted,
                                OnlyUseFavorites = saved.OnlyUseFavorites,
                            })
                            if cloned then cosmeticEquipped[weaponName][cosmeticType] = cloned end
                        end
                    end
                    if not next(cosmeticEquipped[weaponName]) then cosmeticEquipped[weaponName] = nil end
                end
            end
        end

        loadCosmeticConfig()

        cosmeticLib.OwnsCosmeticNormally = function(_, _, name)
            return isCosmeticType(cosmeticLib.Cosmetics[name]) or false
        end
        cosmeticLib.OwnsCosmeticUniversally = function(_, _, name)
            return isCosmeticType(cosmeticLib.Cosmetics[name]) or false
        end
        cosmeticLib.OwnsCosmeticForWeapon = function(_, _, name)
            return isCosmeticType(cosmeticLib.Cosmetics[name]) or false
        end

        local originalOwnsCosmetic = cosmeticLib.OwnsCosmetic
        cosmeticLib.OwnsCosmetic = function(self, inventory, name, weapon)
            if type(name) == "string" and (name:find("MISSING_", 1, true) or name == "Bubble Gun") then
                return originalOwnsCosmetic(self, inventory, name, weapon)
            end
            return isCosmeticType(cosmeticLib.Cosmetics[name]) or originalOwnsCosmetic(self, inventory, name, weapon)
        end

        local originalGet = dataCtrl.Get
        dataCtrl.Get = function(self, key)
            local value = originalGet(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if type(value) == "table" then
                    for name, owned in pairs(value) do
                        if isCosmeticType(cosmeticLib.Cosmetics[name]) then proxy[name] = owned end
                    end
                end
                return setmetatable(proxy, {
                    __index = function(_, name)
                        return isCosmeticType(cosmeticLib.Cosmetics[name]) or nil
                    end,
                })
            elseif key == "FavoritedCosmetics" then
                local favorites = type(value) == "table" and table.clone(value) or {}
                for weapon, list in pairs(cosmeticFavorites) do
                    favorites[weapon] = favorites[weapon] or {}
                    for name, enabled in pairs(list) do
                        if isCosmeticType(cosmeticLib.Cosmetics[name]) then favorites[weapon][name] = enabled end
                    end
                end
                return favorites
            end
            return value
        end

        local originalGetWeaponData = dataCtrl.GetWeaponData
        dataCtrl.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponData(self, weaponName)
            if not data then return nil end

            local cloned = {}
            for key, value in pairs(data) do cloned[key] = value end
            cloned.Name = weaponName
            if cosmeticEquipped[weaponName] then
                for cosmeticType, cosmetic in pairs(cosmeticEquipped[weaponName]) do
                    cloned[cosmeticType] = cosmetic
                end
            end
            return cloned
        end

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = { ... }

                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        cosmeticEquipped[weaponName] = cosmeticEquipped[weaponName] or {}
                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                            cosmeticEquipped[weaponName][cosmeticType] = nil
                            if not next(cosmeticEquipped[weaponName]) then cosmeticEquipped[weaponName] = nil end
                        else
                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, options)
                            if cloned then cosmeticEquipped[weaponName][cosmeticType] = cloned end
                        end
                        task.defer(function()
                            pcall(function() dataCtrl.CurrentData:Replicate("WeaponInventory") end)
                        end)
                        saveCosmeticConfig()
                        return
                    elseif self == favoriteRemote then
                        local weaponName, cosmeticName, enabled = args[1], args[2], args[3]
                        if isCosmeticType(cosmeticLib.Cosmetics[cosmeticName]) then
                            cosmeticFavorites[weaponName] = cosmeticFavorites[weaponName] or {}
                            cosmeticFavorites[weaponName][cosmeticName] = enabled or nil
                            task.defer(function()
                                pcall(function() dataCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                            end)
                            saveCosmeticConfig()
                            return
                        end
                    end

                    return oldNamecall(self, ...)
                end)
            end
        end

        local fighterController = nil
        pcall(function()
            fighterController = require(controllers:WaitForChild("FighterController", 10))
        end)

        local clientItem = nil
        pcall(function()
            clientItem = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        end)

        local buildingWeapon = nil
        if clientItem and clientItem._CreateViewModel then
            local originalCreateViewModel = clientItem._CreateViewModel
            clientItem._CreateViewModel = function(self, viewModelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                buildingWeapon = weaponPlayer == LocalPlayer and weaponName or nil

                if weaponPlayer == LocalPlayer and cosmeticEquipped[weaponName] then
                    local dataKey = self:ToEnum("Data")
                    local data = viewModelRef[dataKey] or viewModelRef.Data
                    if data then
                        local cosmetics = cosmeticEquipped[weaponName]
                        if cosmetics.Skin then
                            data[self:ToEnum("Skin")] = cosmetics.Skin
                            data[self:ToEnum("Name")] = cosmetics.Skin.Name
                            data.Skin = cosmetics.Skin
                            data.Name = cosmetics.Skin.Name
                        end
                        if cosmetics.Charm then
                            data[self:ToEnum("Charm")] = cosmetics.Charm
                            data.Charm = cosmetics.Charm
                        end
                        if cosmetics.Wrap then
                            data[self:ToEnum("Wrap")] = cosmetics.Wrap
                            data.Wrap = cosmetics.Wrap
                        end
                    end
                end

                local result = originalCreateViewModel(self, viewModelRef)
                buildingWeapon = nil
                return result
            end
        end

        local viewModelModule = LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if viewModelModule then
            local clientViewModel = require(viewModelModule)
            local originalNew = clientViewModel.new
            clientViewModel.new = function(repData, clientItemObject)
                local weaponPlayer = clientItemObject.ClientFighter and clientItemObject.ClientFighter.Player
                local weaponName = buildingWeapon or clientItemObject.Name
                if weaponPlayer == LocalPlayer and cosmeticEquipped[weaponName] then
                    local replicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                    local dataKey = replicatedClass:ToEnum("Data")
                    repData[dataKey] = repData[dataKey] or {}
                    local cosmetics = cosmeticEquipped[weaponName]
                    if cosmetics.Skin then repData[dataKey][replicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                    if cosmetics.Charm then repData[dataKey][replicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                    if cosmetics.Wrap then repData[dataKey][replicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                end
                return originalNew(repData, clientItemObject)
            end
        end

        if fighterController then
            pcall(function()
                dataCtrl.CurrentData:Replicate("WeaponInventory")
                dataCtrl.CurrentData:Replicate("FavoritedCosmetics")
            end)
        end
    end)

    if not ok then
        notify("Skinchanger", "Unlocker failed: " .. tostring(err), "triangle-alert", 5)
        return false
    end

    cosmeticUnlockerInstalled = true
    notify("Skinchanger", "All cosmetics unlocked locally", "sparkles", 4)
    return true
end

if skinAcess == true then
    local Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
    if Config.Skins.Sniper == "none" then else skinlib:change("Sniper", Config.Skins.Sniper) end
    if Config.Skins.Assault_Rifle == "none" then else skinlib:change("Assault Rifle", Config.Skins.Assault_Rifle) end
    if Config.Skins.Crossbow == "none" then else skinlib:change("Crossbow", Config.Skins.Crossbow) end
    if Config.Skins.Handgun == "none" then else skinlib:change("Handgun", Config.Skins.Handgun) end
    if Config.Skins.Revolver == "none" then else skinlib:change("Revolver", Config.Skins.Revolver) end
    if Config.Skins.Knife == "none" then else skinlib:change("Knife", Config.Skins.Knife) end
    if Config.Skins.Katana == "none" then else skinlib:change("Katana", Config.Skins.Katana) end
end

local function getNearestHead()
local closestPlayer = nil
local shortestDistance = math.huge
 
for _, player in pairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
if distance < shortestDistance then
shortestDistance = distance
closestPlayer = player
end
end
end
 
if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
return closestPlayer.Character.Head
end
 
return nil
end
 
 
UserInputService.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimActive then
local targetHead = getNearestHead()
if targetHead then
local aimPosition = targetHead.Position
Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
ReplicatedStorage.Remotes.Attack:FireServer(targetHead)
end
end
end)


local function updateConfig(mutator)
    local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
    data.Aim = data.Aim or {}
    data.Visual = data.Visual or {}
    data.Skins = data.Skins or {}
    mutator(data)
    writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "crosshair",
    Author = "Rivals v" .. version .. " | " .. hubRank,
    Folder = CONFIG_FOLDER,
    Size = UDim2.fromOffset(580, 430),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 160,
})

Window:SetToggleKey(Enum.KeyCode.RightControl)
Window:EditOpenButton({ Title = "IndraHub", Icon = "crosshair", Draggable = true })

local Tabs = {
    Aim = Window:Tab({ Title = "Aim", Icon = "crosshair" }),
    Visual = Window:Tab({ Title = "Visual", Icon = "eye" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" }),
    Skin = Window:Tab({ Title = "Skinchanger", Icon = "palette" }),
}

if hubRank == "Developer" then
    local DevTab = Window:Tab({ Title = "Developer", Icon = "wrench" })
    DevTab:Button({
        Title = "Neon Weapon",
        Desc = "Apply neon material to current viewmodel.",
        Callback = CustomGunMaterial,
    })
end

Tabs.Aim:Toggle({
    Title = "Silent Aim",
    Desc = "Targets nearest head on mouse click.",
    Value = silentAimActive,
    Callback = function(value)
        silentAimActive = value
        updateConfig(function(cfg) cfg.Aim.enabled = value end)
    end,
})

Tabs.Aim:Toggle({
    Title = "Raycast Aim",
    Desc = "Redirects Rivals raycasts to the closest target on screen.",
    Value = raycastAimEnabled,
    Callback = function(value)
        setRaycastAim(value)
        updateConfig(function(cfg)
            cfg.Aim.raycast = raycastAimEnabled
            cfg.Aim.bone = raycastAimBone
        end)
    end,
})

Tabs.Aim:Dropdown({
    Title = "Raycast Bone",
    Values = { "Head", "HumanoidRootPart" },
    Value = raycastAimBone,
    Callback = function(value)
        raycastAimBone = value
        updateConfig(function(cfg) cfg.Aim.bone = value end)
    end,
})

Tabs.Visual:Toggle({
    Title = "ESP",
    Value = esp.enabled,
    Callback = function(value)
        esp.enabled = value
        updateConfig(function(cfg) cfg.Visual.esp = value end)
    end,
})

Tabs.Visual:Toggle({
    Title = "ESP Arrows",
    Value = false,
    Callback = function(value)
        esp.team_arrow = { value, Color3.new(1, 1, 1), 0.5 }
    end,
})

Tabs.Visual:Button({
    Title = "Meme Skybox",
    Desc = "Not implemented yet.",
    Callback = function()
        notify("Skybox", "In development", "triangle-alert", 4)
    end,
})

Tabs.Visual:Toggle({
    Title = "Night",
    Desc = "Rejoin to fully disable.",
    Value = false,
    Callback = function(value)
        updateConfig(function(cfg) cfg.Visual.night = value end)
        if value then task.spawn(MakeNight) end
    end,
})

Tabs.Player:Section({ Title = "Press X to toggle fly", Icon = "info" })
Tabs.Player:Slider({
    Title = "Flying Speed",
    Value = { Min = 50, Max = 1000, Default = flySpeed },
    Step = 1,
    Callback = function(value)
        flySpeed = value
    end,
})

Tabs.Player:Toggle({
    Title = "Noclip",
    Value = noClip,
    Callback = setNoClip,
})

local function addSkinDropdown(title, weaponName, configKey, values)
    Tabs.Skin:Dropdown({
        Title = title,
        Values = values,
        Value = "None",
        Callback = function(skin)
            skinlib:change(weaponName, skin)
            updateConfig(function(cfg) cfg.Skins[configKey] = skin end)
        end,
    })
end

Tabs.Skin:Section({ Title = "Cosmetic Unlocker", Icon = "sparkles" })
Tabs.Skin:Button({
    Title = "Unlock All Skins / Wraps / Charms",
    Desc = "Enables local cosmetic ownership hooks from skinchangerrivals.lua.",
    Callback = installCosmeticUnlocker,
})

if skinAcess == true then
    Tabs.Skin:Section({ Title = "Primary", Icon = "rifle" })
    addSkinDropdown("Assault Rifle", "Assault Rifle", "Assault_Rifle", { "AK-47", "AKEY-47", "Boneclaw Rifle" })
    addSkinDropdown("Sniper", "Sniper", "Sniper", { "Pixel Sniper", "Keyper", "Gingerbread Sniper", "Hyper Sniper", "Sniper" })
    addSkinDropdown("Crossbow", "Crossbow", "Crossbow", { "Pixel Crossbow", "Frostbite Crossbow" })
    Tabs.Skin:Section({ Title = "Secondary", Icon = "target" })
    addSkinDropdown("Handgun", "Handgun", "Handgun", { "Pixel Handgun", "Blaster", "Gingerbread Handgun", "Pumpkin Handgun", "Chainsaw" })
    addSkinDropdown("Revolver", "Revolver", "Revolver", { "Boneclaw Revolver" })
    Tabs.Skin:Section({ Title = "Melee", Icon = "swords" })
    addSkinDropdown("Katana", "Katana", "Katana", { "Pixel Katana", "Saber", "2025 Katana" })
    addSkinDropdown("Knife", "Knife", "Knife", { "Candy Cane", "Karambit", "Chancla", "Machete", "Invisible" })
else
    Tabs.Skin:Section({ Title = "Skinchanger allowed only for premium users", Icon = "lock" })
end

notify(HUB_NAME, "Loaded v" .. version .. ". Toggle UI: RightControl", "check", 4)

local Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
if Config.Visual.night == true then
    task.spawn(MakeNight)
end
