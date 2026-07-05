-- IndraHub PNS.
-- Targets Workspace.ClientCoins and ReplicatedStorage.Remotes.CoinCollect.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local env = getgenv and getgenv() or _G

env.IndraHubAutoCoinRunning = true

local function setShared(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

setShared("IndraHubPNSRunning", true)
setShared("IndraHubPNSError", nil)
setShared("IndraHubPNSLastHeartbeat", os.clock())

local config = {
    Enabled = true,
    WalkToCoins = false,
    TeleportToCoins = false,
    BringCoins = true,
    FireRemote = true,
    TouchCoins = true,
    ScanDelay = 0.15,
    ReturnAfterCollect = false,
    MaxDistance = 10000,
    CollectDistance = 6,
    MoveTimeout = 4,
    InfiniteJump = false,
    AutoWhistle = false,
    WhistleDelay = 3,
    EspEnabled = false,
    EspHighlights = true,
    EspNames = true,
    EspDistance = true,
    EspTeamCheck = false,
}

local espOverlay = nil

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

UserInputService.JumpRequest:Connect(function()
    if not config.InfiniteJump then return end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function getCoinRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("CoinCollect")
end

local function getTauntRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("TauntEvent")
end

local function whistle()
    local remote = getTauntRemote()
    if remote then
        pcall(function() remote:FireServer("Whistle") end)
    end
end

local function coinContainer()
    return Workspace:FindFirstChild("ClientCoins")
end

local function coinPart(coin)
    if coin:IsA("BasePart") then return coin end
    if coin:IsA("Model") then
        return coin.PrimaryPart or coin:FindFirstChildWhichIsA("BasePart", true)
    end
    return coin:FindFirstChildWhichIsA("BasePart", true)
end

local function getCoinId(coin)
    for _, key in ipairs({"Id", "ID", "CoinId", "CoinID", "Guid", "GUID"}) do
        local value = coin:GetAttribute(key)
        if value ~= nil then return value end
    end
    local valueObj = coin:FindFirstChild("Id") or coin:FindFirstChild("ID") or coin:FindFirstChild("CoinId") or coin:FindFirstChild("CoinID")
    if valueObj and valueObj:IsA("ValueBase") then return valueObj.Value end
    return coin.Name
end

local function tryFireRemote(remote, coin)
    if not remote or not config.FireRemote then return end
    local numericId = tonumber(tostring(coin.Name):match("(%d+)$"))
    if numericId then
        pcall(function() remote:FireServer(numericId) end)
    end
end

local function tryTouch(part)
    if not part or not config.TouchCoins then return end
    local root = getRoot()
    if not root then return end
    pcall(function() firetouchinterest(root, part, 0) end)
    task.wait(0.03)
    pcall(function() firetouchinterest(root, part, 1) end)
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function moveNear(part)
    if not config.WalkToCoins then return true end
    local humanoid = getHumanoid()
    local root = getRoot()
    if not humanoid or not root or not part then return false end

    local target = part.Position + Vector3.new(0, 0.5, 0)
    humanoid:MoveTo(target)

    local start = os.clock()
    while config.Enabled and part.Parent and root.Parent do
        if (root.Position - part.Position).Magnitude <= config.CollectDistance then
            return true
        end
        if os.clock() - start >= config.MoveTimeout then
            return false
        end
        task.wait(0.05)
    end
    return false
end

local function collectCoin(coin)
    local root = getRoot()
    local part = coinPart(coin)
    if not root or not part then return end

    local distance = (root.Position - part.Position).Magnitude
    if distance > config.MaxDistance then return end

    if not moveNear(part) and not config.TeleportToCoins then
        return
    end

    root = getRoot()
    if not root then return end

    local original = root.CFrame
    local originalCoinCFrame = part.CFrame
    local movedCoin = false

    if config.BringCoins then
        local targetCFrame = root.CFrame + root.CFrame.LookVector * 1.5
        targetCFrame = targetCFrame + Vector3.new(0, -1.5, 0)
        pcall(function()
            if coin:IsA("Model") then
                coin:PivotTo(targetCFrame)
            else
                part.CFrame = targetCFrame
            end
            movedCoin = true
        end)
        task.wait(0.05)
    end

    if config.TeleportToCoins then
        pcall(function()
            root.CFrame = part.CFrame + Vector3.new(0, 0.75, 0)
        end)
        task.wait(0.08)
    end

    if (root.Position - part.Position).Magnitude <= config.CollectDistance + 2 or config.TeleportToCoins then
        tryTouch(part)
        pressE()
        tryFireRemote(getCoinRemote(), coin)
    end

    if config.ReturnAfterCollect and config.TeleportToCoins then
        task.wait(0.03)
        pcall(function() root.CFrame = original end)
    end

    if movedCoin and coin.Parent then
        task.delay(0.2, function()
            pcall(function()
                if coin:IsA("Model") then
                    coin:PivotTo(originalCoinCFrame)
                elseif part and part.Parent then
                    part.CFrame = originalCoinCFrame
                end
            end)
        end)
    end
end

local function collectAll()
    local folder = coinContainer()
    if not folder then return 0 end

    local coins = folder:GetChildren()
    table.sort(coins, function(a, b)
        local root = getRoot()
        if not root then return a.Name < b.Name end
        local ap = coinPart(a)
        local bp = coinPart(b)
        if not ap or not bp then return a.Name < b.Name end
        return (root.Position - ap.Position).Magnitude < (root.Position - bp.Position).Magnitude
    end)

    local count = 0
    for _, coin in ipairs(coins) do
        if not config.Enabled then break end
        if coin.Parent == folder then
            collectCoin(coin)
            count = count + 1
            task.wait(config.ScanDelay)
        end
    end
    return count
end

local function notify(title, content)
    if env.IndraHubAutoCoinWindUI and type(env.IndraHubAutoCoinWindUI.Notify) == "function" then
        pcall(function() env.IndraHubAutoCoinWindUI:Notify({Title = title, Content = content, Icon = "coins", Duration = 3}) end)
    else
        print("[IndraHub AutoCoin] " .. tostring(title) .. ": " .. tostring(content))
    end
end

local function espParent()
    if gethui then return gethui() end
    return CoreGui
end

local function playerRoot(player)
    local character = player and player.Character
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head"))
end

local function espColor(player)
    if player.TeamColor then return player.TeamColor.Color end
    return Color3.fromRGB(255, 90, 90)
end

local function clearPlayerEsp(player)
    local character = player and player.Character
    if character then
        local highlight = character:FindFirstChild("IndraHubPNS_PlayerESP_Highlight")
        if highlight then pcall(function() highlight:Destroy() end) end
    end
    if espOverlay then
        local billboard = espOverlay:FindFirstChild("IndraHubPNS_PlayerESP_" .. tostring(player.UserId))
        if billboard then pcall(function() billboard:Destroy() end) end
    end
end

local function ensureEspOverlay()
    if espOverlay and espOverlay.Parent then return espOverlay end
    espOverlay = Instance.new("ScreenGui")
    espOverlay.Name = "IndraHubPNS_PlayerESP"
    espOverlay.ResetOnSpawn = false
    espOverlay.Parent = espParent()
    return espOverlay
end

local function updatePlayerEsp(player)
    if player == LocalPlayer then return end
    local character = player.Character
    local root = playerRoot(player)
    if not character or not root then return end
    if config.EspTeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
        clearPlayerEsp(player)
        return
    end

    local color = espColor(player)
    local visible = config.EspEnabled

    local highlight = character:FindFirstChild("IndraHubPNS_PlayerESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "IndraHubPNS_PlayerESP_Highlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end
    highlight.Adornee = character
    highlight.Enabled = visible and config.EspHighlights
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.55
    highlight.OutlineTransparency = 0

    local overlay = ensureEspOverlay()
    local billboard = overlay:FindFirstChild("IndraHubPNS_PlayerESP_" .. tostring(player.UserId))
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "IndraHubPNS_PlayerESP_" .. tostring(player.UserId)
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(220, 42)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.35, 0)
        billboard.Parent = overlay
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0.25
        label.Parent = billboard
    end

    billboard.Adornee = root
    billboard.Enabled = visible and config.EspNames
    local label = billboard:FindFirstChild("Label")
    if label then
        local text = player.DisplayName ~= player.Name and (player.DisplayName .. " (@" .. player.Name .. ")") or player.Name
        local localRoot = playerRoot(LocalPlayer)
        if config.EspDistance and localRoot then
            text = text .. " [" .. tostring(math.floor((localRoot.Position - root.Position).Magnitude)) .. "m]"
        end
        label.Text = text
        label.TextColor3 = color
    end
end

local function refreshEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerEsp(player)
    end
end

local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if okWind and type(WindUI) == "table" then
    env.IndraHubAutoCoinWindUI = WindUI
    if env.IndraHubAutoCoinWindow then pcall(function() env.IndraHubAutoCoinWindow:Destroy() end) end

    local Window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "coins",
        Author = "Auto Coin",
        Folder = "IndraHubAutoCoin",
        Size = UDim2.fromOffset(500, 360),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 150,
    })
    env.IndraHubAutoCoinWindow = Window
    if Window.SetToggleKey then Window:SetToggleKey(Enum.KeyCode.RightControl) end
    if Window.EditOpenButton then Window:EditOpenButton({Title = "IndraHub", Icon = "coins", Draggable = true}) end

    local Main = Window:Tab({Title = "Coins", Icon = "coins"})
    local Settings = Window:Tab({Title = "Settings", Icon = "settings"})
    local Esp = Window:Tab({Title = "ESP", Icon = "eye"})

    Main:Toggle({Title = "Auto Collect", Value = config.Enabled, Callback = function(value) config.Enabled = value end})
    Main:Button({Title = "Collect Once", Callback = function() notify("Collect", "Collected " .. tostring(collectAll()) .. " coins") end})
    Main:Section({Title = "Target: Workspace.ClientCoins", Icon = "folder"})

    Settings:Toggle({Title = "Walk To Coins", Value = config.WalkToCoins, Callback = function(value) config.WalkToCoins = value end})
    Settings:Toggle({Title = "Bring Coins To You", Value = config.BringCoins, Callback = function(value) config.BringCoins = value end})
    Settings:Toggle({Title = "Teleport To Coins", Value = config.TeleportToCoins, Callback = function(value) config.TeleportToCoins = value end})
    Settings:Toggle({Title = "Fire CoinCollect Remote", Value = config.FireRemote, Callback = function(value) config.FireRemote = value end})
    Settings:Toggle({Title = "Touch Coins", Value = config.TouchCoins, Callback = function(value) config.TouchCoins = value end})
    Settings:Toggle({Title = "Return After Collect", Value = config.ReturnAfterCollect, Callback = function(value) config.ReturnAfterCollect = value end})
    Settings:Toggle({Title = "Infinite Jump", Value = config.InfiniteJump, Callback = function(value) config.InfiniteJump = value end})
    Settings:Slider({Title = "Delay", Value = {Min = 0.05, Max = 1, Default = config.ScanDelay}, Step = 0.05, Callback = function(value) config.ScanDelay = tonumber(value) or config.ScanDelay end})
    Settings:Slider({Title = "Collect Distance", Value = {Min = 2, Max = 15, Default = config.CollectDistance}, Step = 1, Callback = function(value) config.CollectDistance = tonumber(value) or config.CollectDistance end})

    Main:Section({Title = "Taunt", Icon = "volume-2"})
    Main:Toggle({Title = "Auto Whistle", Value = config.AutoWhistle, Callback = function(value) config.AutoWhistle = value end})
    Main:Button({Title = "Whistle Once", Callback = whistle})
    Main:Slider({Title = "Whistle Delay", Value = {Min = 1, Max = 15, Default = config.WhistleDelay}, Step = 1, Callback = function(value) config.WhistleDelay = tonumber(value) or config.WhistleDelay end})

    Esp:Section({Title = "Player ESP", Icon = "users"})
    Esp:Toggle({Title = "Enabled", Value = config.EspEnabled, Callback = function(value) config.EspEnabled = value; refreshEsp() end})
    Esp:Toggle({Title = "Highlights", Value = config.EspHighlights, Callback = function(value) config.EspHighlights = value; refreshEsp() end})
    Esp:Toggle({Title = "Names", Value = config.EspNames, Callback = function(value) config.EspNames = value; refreshEsp() end})
    Esp:Toggle({Title = "Distance", Value = config.EspDistance, Callback = function(value) config.EspDistance = value; refreshEsp() end})
    Esp:Toggle({Title = "Team Check", Value = config.EspTeamCheck, Callback = function(value) config.EspTeamCheck = value; refreshEsp() end})
end

Players.PlayerRemoving:Connect(clearPlayerEsp)

task.spawn(function()
    while env.IndraHubAutoCoinRunning do
        setShared("IndraHubPNSRunning", true)
        setShared("IndraHubPNSLastHeartbeat", os.clock())
        refreshEsp()
        if config.Enabled then collectAll() end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while env.IndraHubAutoCoinRunning do
        if config.AutoWhistle then whistle() end
        task.wait(config.WhistleDelay)
    end
end)

notify("IndraHub", "Auto coin collector loaded")
print("[IndraHub AutoCoin] loaded")
