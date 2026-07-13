local function getGlobal(path)
    local keys = string.split(path, ".")
    local current = getgenv()
    for _, key in ipairs(keys) do
        if type(current) ~= "table" then return nil end
        current = current[key]
        if current == nil then return nil end
    end
    return current
end

local function setGlobal(path, value)
    local keys = string.split(path, ".")
    local current = getgenv()
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end
    current[keys[#keys]] = value
end

-- Initialize Supervisor State for this specific script
if getGlobal("IndraHubBombFishing.Running") then return end
setGlobal("IndraHubBombFishing.Running", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubBombFishing.Running") then break end
        setGlobal("IndraHubBombFishing.LastHeartbeat", os.time())
    end
end)
setGlobal("IndraHubBombFishing.AutoBomb", false)
setGlobal("IndraHubBombFishing.AutoSell", false)
setGlobal("IndraHubBombFishing.AutoRebirth", false)
setGlobal("IndraHubBombFishing.AutoRewards", false)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local src = ReplicatedStorage:WaitForChild("src")
local Modules = src:WaitForChild("Modules")
local KnitClient = Modules:WaitForChild("KnitClient")
local Services = KnitClient:WaitForChild("Services")

-- UI Library
local Library = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = Library:CreateWindow({
    Title = "IndraHub - Bomb Fishing",
    Icon = "rbxassetid://18228399671",
    Author = ".indrat99",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false
})

-- Handle Supervisor Shutdown
local originalClose = Window.Close
Window.Close = function(self)
    setGlobal("IndraHubBombFishing.Running", false)
    if originalClose then
        originalClose(self)
    end
end

-- Setup Heartbeat
local RunService = game:GetService("RunService")
local HeartbeatConnection
HeartbeatConnection = RunService.Heartbeat:Connect(function()
    if not getGlobal("IndraHubBombFishing.Running") then
        HeartbeatConnection:Disconnect()
        if Window and Window.Destroy then
            pcall(function() Window:Destroy() end)
        end
    end
end)

-- Tabs
local AutoFarmTab = Window:Tab({ Title = "Auto Farm", Icon = "home" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

-- Auto Farm Settings
AutoFarmTab:Toggle({
    Title = "Auto Bomb (Fish)",
    Desc = "Automatically throws bombs to catch fish",
    Value = getGlobal("IndraHubBombFishing.AutoBomb") or false,
    Callback = function(state)
        setGlobal("IndraHubBombFishing.AutoBomb", state)
    end
})

AutoFarmTab:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sells caught fish",
    Value = getGlobal("IndraHubBombFishing.AutoSell") or false,
    Callback = function(state)
        setGlobal("IndraHubBombFishing.AutoSell", state)
    end
})

MiscTab:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths when possible",
    Value = getGlobal("IndraHubBombFishing.AutoRebirth") or false,
    Callback = function(state)
        setGlobal("IndraHubBombFishing.AutoRebirth", state)
    end
})

MiscTab:Toggle({
    Title = "Auto Claim Rewards",
    Desc = "Automatically claims daily and playtime rewards",
    Value = getGlobal("IndraHubBombFishing.AutoRewards") or false,
    Callback = function(state)
        setGlobal("IndraHubBombFishing.AutoRewards", state)
    end
})

MiscTab:Button({
    Title = "Join Discord",
    Desc = "Join the IndraHub community",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        Library:Notify({
            Title = "Copied!",
            Content = "Discord link copied to clipboard.",
            Duration = 3
        })
    end
})

-- Background Logic
task.spawn(function()
    while task.wait(0.1) do
        if not getGlobal("IndraHubBombFishing.Running") then break end
        
        -- Auto Bomb
        if getGlobal("IndraHubBombFishing.AutoBomb") then
            pcall(function()
                if Services:FindFirstChild("BombService") and Services.BombService:FindFirstChild("RE") then
                    if Services.BombService.RE:FindFirstChild("Start") then
                        Services.BombService.RE.Start:FireServer()
                    end
                    task.wait(0.05)
                    if Services.BombService.RE:FindFirstChild("Throw") then
                        Services.BombService.RE.Throw:FireServer()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubBombFishing.Running") then break end
        
        -- Auto Sell
        if getGlobal("IndraHubBombFishing.AutoSell") then
            pcall(function()
                if Services:FindFirstChild("SellService") and Services.SellService:FindFirstChild("RE") then
                    Services.SellService.RE:FireServer()
                end
            end)
        end
        
        -- Auto Rebirth
        if getGlobal("IndraHubBombFishing.AutoRebirth") then
            pcall(function()
                if Services:FindFirstChild("RebirthService") and Services.RebirthService:FindFirstChild("RE") then
                    Services.RebirthService.RE:FireServer()
                end
            end)
        end
        
        -- Auto Rewards
        if getGlobal("IndraHubBombFishing.AutoRewards") then
            pcall(function()
                if Services:FindFirstChild("DailyRewardService") and Services.DailyRewardService:FindFirstChild("RE") then
                    Services.DailyRewardService.RE:FireServer()
                end
                if Services:FindFirstChild("PlaytimeRewardService") and Services.PlaytimeRewardService:FindFirstChild("RE") then
                    Services.PlaytimeRewardService.RE:FireServer()
                end
            end)
        end
    end
end)

Library:Notify({
    Title = "IndraHub Loaded",
    Content = "Bomb Fishing script initialized successfully.",
    Duration = 5
})
