-- IndraHub - Drain The Lake
-- WindUI | Auto bucket | Token collect | Pour | Teleport helper

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local env = getgenv and getgenv() or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

env.IndraHubDrainTheLakeRunning = true
env.IndraHubDrainTheLakeSession = sessionId
env.IndraHubDrainTheLakeLastHeartbeat = os.clock()
env.IndraHubDrainTheLakeError = nil

local function running()
    return env.IndraHubDrainTheLakeRunning and env.IndraHubDrainTheLakeSession == sessionId
end

task.spawn(function()
    while running() do
        env.IndraHubDrainTheLakeLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function fetch(url, cache)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end

    local data = game:HttpGet(url)
    if type(writefile) == "function" then
        pcall(function() writefile(cache, data) end)
    end
    return data
end

local WindUI = loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_DrainTheLake_WindUI.lua"))()

local function notify(title, content, icon)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({
                Title = title,
                Content = content or "",
                Icon = icon or "info",
                Duration = 3,
            })
        end)
    else
        print("[IndraHub Drain The Lake] " .. tostring(title) .. ": " .. tostring(content or ""))
    end
end

if env.IndraHubDrainTheLakeWindow then
    pcall(function() env.IndraHubDrainTheLakeWindow:Destroy() end)
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "waves",
    Author = "Drain The Lake",
    Folder = "IndraHubDrainTheLake",
    Size = UDim2.fromOffset(560, 420),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 160,
})

env.IndraHubDrainTheLakeWindow = Window
Window:SetToggleKey(Enum.KeyCode.RightControl)
Window:EditOpenButton({ Title = "IndraHub", Icon = "waves", Draggable = true })

local Tabs = {
    Farm = Window:Tab({ Title = "Auto Farm", Icon = "droplets" }),
    Config = Window:Tab({ Title = "Config", Icon = "settings" }),
    Info = Window:Tab({ Title = "Info", Icon = "info" }),
}

-- ========== REMOTES ==========
local verdantRemotes = ReplicatedStorage:WaitForChild("VerdantRemotes", 5)
local bucketRemote = verdantRemotes and verdantRemotes:WaitForChild("VDT_Bucket.Used", 5)
local pourRemote = verdantRemotes and verdantRemotes:WaitForChild("VDT_Bucket.Poured", 5)
local tokenRemote = verdantRemotes and verdantRemotes:WaitForChild("VDT_Tokens.Take", 5)

local scripted = workspace:WaitForChild("Scripted", 10)
local checkpointParts = scripted and scripted:WaitForChild("CheckpointParts", 5)

-- ========== CONFIG ==========
local config = {
    autoBucket = false,
    autoToken = false,
    autoPour = false,
    autoTP = false,
    bucketDelay = 0.1,
    tokenDelay = 0.1,
    pourDelay = 0.1,
}

-- ========== RECURSIVE SCANNER ==========
local function getAllPrompts()
    local prompts = {}
    if not checkpointParts then return prompts end

    for _, obj in ipairs(checkpointParts:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(prompts, obj)
        end
    end

    return prompts
end

local function tpToPrompt(prompt)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not config.autoTP or not root then return end

    local targetPart = prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart or prompt.Parent
    if targetPart and targetPart:IsA("BasePart") then
        root.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
    end
end

-- ========== REMOTE FUNCTIONS ==========
local function useBucket()
    if bucketRemote then
        pcall(function() bucketRemote:FireServer() end)
    end
end

local function useToken()
    if not tokenRemote then return end

    local activePrompts = getAllPrompts()
    if #activePrompts == 0 then
        notify("Tokens", "No machines or prompts found.", "triangle-alert")
        return
    end

    for _, prompt in ipairs(activePrompts) do
        if config.autoToken then
            tpToPrompt(prompt)
            pcall(function() tokenRemote:FireServer(prompt) end)
            task.wait(0.05)
        end
    end
end

local function usePour()
    if not pourRemote then return end

    local activePrompts = getAllPrompts()
    if #activePrompts == 0 then return end

    for _, prompt in ipairs(activePrompts) do
        if config.autoPour then
            tpToPrompt(prompt)
            pcall(function() pourRemote:FireServer(prompt) end)
            task.wait(0.05)
        end
    end
end

-- ========== LOOPS ==========
local function startBucketLoop()
    while running() and config.autoBucket do
        useBucket()
        task.wait(config.bucketDelay)
    end
end

local function startTokenLoop()
    while running() and config.autoToken do
        useToken()
        task.wait(config.tokenDelay)
    end
end

local function startPourLoop()
    while running() and config.autoPour do
        usePour()
        task.wait(config.pourDelay)
    end
end

-- ========== UI ==========
Tabs.Farm:Toggle({
    Title = "Enable Automatic Teleport",
    Desc = "Teleport to each machine before token or pour actions.",
    Value = false,
    Callback = function(value)
        config.autoTP = value
        notify("Teleport", value and "ON" or "OFF", "map-pin")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Use Bucket",
    Desc = "Repeatedly fires bucket use remote.",
    Value = false,
    Callback = function(value)
        config.autoBucket = value
        if value then
            task.spawn(startBucketLoop)
        end
        notify("Bucket", value and "ON" or "OFF", "bucket")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Collect All Tokens",
    Desc = "Scans all checkpoint prompts and takes tokens.",
    Value = false,
    Callback = function(value)
        config.autoToken = value
        if value then
            task.spawn(startTokenLoop)
        end
        notify("Tokens", value and "Scanning all machines..." or "OFF", "coins")
    end,
})

Tabs.Farm:Toggle({
    Title = "Auto Pour Bucket (All)",
    Desc = "Scans all checkpoint prompts and pours bucket.",
    Value = false,
    Callback = function(value)
        config.autoPour = value
        if value then
            task.spawn(startPourLoop)
        end
        notify("Pour", value and "Scanning all machines..." or "OFF", "droplets")
    end,
})

Tabs.Config:Slider({
    Title = "Bucket Delay (s)",
    Value = { Min = 0.01, Max = 2, Default = 0.3 },
    Step = 0.05,
    Callback = function(value)
        config.bucketDelay = value
    end,
})

Tabs.Config:Slider({
    Title = "Token Delay (s)",
    Value = { Min = 0.01, Max = 2, Default = 0.3 },
    Step = 0.05,
    Callback = function(value)
        config.tokenDelay = value
    end,
})

Tabs.Config:Slider({
    Title = "Pour Delay (s)",
    Value = { Min = 0.01, Max = 2, Default = 0.3 },
    Step = 0.05,
    Callback = function(value)
        config.pourDelay = value
    end,
})

Tabs.Info:Section({ Title = "IndraHub Drain The Lake", Icon = "waves" })
Tabs.Info:Section({ Title = "RightControl toggles UI", Icon = "keyboard" })
Tabs.Info:Section({ Title = "Original farming remotes preserved", Icon = "server" })

-- ========== GLOBAL COMMANDS ==========
env.IndraHubDrainTheLakeStop = function()
    config.autoBucket = false
    config.autoToken = false
    config.autoPour = false
    config.autoTP = false
    env.IndraHubDrainTheLakeRunning = false
    if env.IndraHubDrainTheLakeWindow then
        pcall(function() env.IndraHubDrainTheLakeWindow:Destroy() end)
    end
    print("[IndraHub Drain The Lake] Stopped")
end

_G.stopAll = env.IndraHubDrainTheLakeStop
