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
local esp = loadstring(game:HttpGet('https://pastebin.com/raw/HALrE6Z0'))()
esp.enabled = false

if true then
    local Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
    
    silentAimActive = Config.Aim.enabled
    esp.enabled = Config.Visual.esp
end

 
local noClip = false

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
