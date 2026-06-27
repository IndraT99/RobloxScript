-- IndraHub - MM2 Coin Autofarm
-- WindUI | Auto farm | Anti-AFK | Tween speed | Noclip while farming

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local env = getgenv and getgenv() or _G

local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1
collectSound.Parent = player:WaitForChild("PlayerGui")

local visitedPositions = {}
local isActive = false
local flySpeed = 15
local collected = 0
local startTime = 0
local antiAFK = false
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

env.IndraHubMM2Running = true
env.IndraHubMM2Session = sessionId
env.IndraHubMM2LastHeartbeat = os.clock()
env.IndraHubMM2Error = nil

local function running()
    return env.IndraHubMM2Running and env.IndraHubMM2Session == sessionId
end

task.spawn(function()
    while running() do
        env.IndraHubMM2LastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function fetch(url, cache)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end
    local data = game:HttpGet(url)
    if type(writefile) == "function" then pcall(function() writefile(cache, data) end) end
    return data
end

local WindUI = loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_MM2_WindUI.lua"))()

local function notify(title, content, icon)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function() WindUI:Notify({ Title = title, Content = content, Icon = icon or "info", Duration = 3 }) end)
    else
        print("[IndraHub MM2] " .. tostring(title) .. ": " .. tostring(content))
    end
end

if env.IndraHubMM2Window then pcall(function() env.IndraHubMM2Window:Destroy() end) end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "gem",
    Author = "MM2 Coin Autofarm",
    Folder = "IndraHubMM2",
    Size = UDim2.fromOffset(560, 410),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 160,
})

env.IndraHubMM2Window = Window
Window:SetToggleKey(Enum.KeyCode.RightControl)
Window:EditOpenButton({ Title = "IndraHub", Icon = "gem", Draggable = true })

local Tabs = {
    Farm = Window:Tab({ Title = "Farm", Icon = "coins" }),
    Stats = Window:Tab({ Title = "Stats", Icon = "chart-line" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

local function resetStats()
    collected = 0
    startTime = tick()
    visitedPositions = {}
end

local function getElapsed()
    return startTime > 0 and math.floor(tick() - startTime) or 0
end

local function getRate()
    local elapsed = tick() - startTime
    return elapsed > 0 and math.floor((collected / elapsed) * 3600) or 0
end

local function refreshStatsNotify()
    notify("Stats", "Coins: " .. collected .. " | Time: " .. getElapsed() .. "s | CPH: " .. getRate(), "chart-line")
end

local function setCharacter(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
end

player.CharacterAdded:Connect(setCharacter)

player.Idled:Connect(function()
    if not antiAFK then return end
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

RunService.Stepped:Connect(function()
    if not isActive or not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

local function flyTo(pos, speed)
    if not rootPart then return end
    local distance = (pos - rootPart.Position).Magnitude
    local duration = math.max(distance / math.max(speed, 1), 0.05)
    local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = CFrame.new(pos) })
    tween:Play()
    tween.Completed:Wait()
end

local function findClosestCoin()
    if not rootPart then return nil end
    local closest, shortest = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Coin_Server" and not visitedPositions[obj] then
            local dist = (obj.Position - rootPart.Position).Magnitude
            if dist < shortest and dist < 250 then
                closest = obj
                shortest = dist
            end
        end
    end
    return closest
end

local function startFarmLoop()
    task.spawn(function()
        while running() and isActive do
            character = player.Character or player.CharacterAdded:Wait()
            rootPart = character:FindFirstChild("HumanoidRootPart")
            local coin = findClosestCoin()
            if coin and coin.Parent and coin:IsDescendantOf(workspace) then
                flyTo(coin.Position, flySpeed)
                if coin and coin.Parent and coin:IsDescendantOf(workspace) then
                    visitedPositions[coin] = true
                    collected = collected + 1
                    pcall(function() collectSound:Play() end)
                end
            end
            task.wait(0.1)
        end
    end)
end

Tabs.Farm:Toggle({
    Title = "Auto Farm Coins",
    Desc = "Tweens to nearby MM2 coins and enables noclip while active.",
    Value = false,
    Callback = function(value)
        isActive = value
        if value then
            resetStats()
            notify("Auto Farm", "ON", "coins")
            startFarmLoop()
        else
            notify("Auto Farm", "OFF", "coins")
        end
    end,
})

Tabs.Farm:Slider({
    Title = "Tween Speed",
    Desc = "Higher = faster movement to coins.",
    Value = { Min = 10, Max = 25, Default = flySpeed },
    Step = 1,
    Callback = function(value)
        flySpeed = value
    end,
})

Tabs.Settings:Toggle({
    Title = "Anti-AFK",
    Desc = "Uses VirtualUser on idle.",
    Value = false,
    Callback = function(value)
        antiAFK = value
        notify("Anti-AFK", value and "ON" or "OFF", "shield")
    end,
})

Tabs.Stats:Button({
    Title = "Show Stats",
    Desc = "Notify current coins, time, and coins/hour.",
    Callback = refreshStatsNotify,
})

Tabs.Stats:Button({
    Title = "Reset Counter",
    Desc = "Clear collected count and visited coin cache.",
    Callback = function()
        resetStats()
        notify("Stats", "Counter reset", "rotate-ccw")
    end,
})

Tabs.Stats:Section({ Title = "Stats are shown via notification to avoid fragile custom labels.", Icon = "info" })

Tabs.Settings:Button({
    Title = "Unload",
    Desc = "Stop this IndraHub MM2 session.",
    Callback = function()
        isActive = false
        env.IndraHubMM2Running = false
        if env.IndraHubMM2Window then pcall(function() env.IndraHubMM2Window:Destroy() end) end
        notify("IndraHub MM2", "Unloaded", "trash")
    end,
})

task.spawn(function()
    while running() do
        if isActive and startTime > 0 then
            print("[IndraHub MM2] Coins=" .. collected .. " Time=" .. getElapsed() .. "s CPH=" .. getRate())
        end
        task.wait(30)
    end
end)

notify("IndraHub MM2", "Loaded. Toggle UI: RightControl", "gem")
print("IndraHub MM2 loaded")
