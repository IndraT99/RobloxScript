local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Global Check to prevent multi-execution & disconnect old listeners
local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubUnboxASMRRunning") then 
    setGlobal("IndraHubUnboxASMRRunning", false)
    task.wait(0.2)
end
setGlobal("IndraHubUnboxASMRRunning", true)
setGlobal("IndraHubUnboxASMRLastHeartbeat", os.time())

-- Supervisor Watchdog Heartbeat Loop
task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubUnboxASMRRunning") then break end
        setGlobal("IndraHubUnboxASMRLastHeartbeat", os.time())
    end
end)

if getGlobal("IndraHubUnboxASMRConnections") then
    for _, conn in ipairs(getGlobal("IndraHubUnboxASMRConnections")) do
        pcall(function() conn:Disconnect() end)
    end
end
local scriptConnections = {}
setGlobal("IndraHubUnboxASMRConnections", scriptConnections)

-- Load WindUI Library
local okWindUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not okWindUI or not WindUI then
    warn("Failed to load WindUI library")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Unbox ASMR Simulator",
    Icon = "box",
    Author = "IndraHub",
    Folder = "IndraHubUnboxASMR",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

-- Tabs
local TabMain = Window:Tab({ Title = "Main", Icon = "gamepad-2" })
local TabAutomation = Window:Tab({ Title = "Automation", Icon = "bot" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Configurations
local Config = {
    AutoConveyor = false,
    ConveyorDelay = 0.5,
    AutoBuyConveyorCrates = false,
    AutoTapASMR = false,
    AutoSell = false,
    AutoBuyWorker = false,
    AutoClaimDaily = false,
    AutoUpgradeASMR = false,
    AutoRebirth = false,
    AutoExpandPlot = false,
    AutoUpgradeConveyor = false,
    
    TapDelay = 0.05,
    TapRange = 9999,
    MaxKeysPerItem = 15,
    
    WalkSpeed = 16,
    EnableWalkSpeed = false,
    JumpPower = 50,
    EnableJumpPower = false,
    Noclip = false,
    AntiAFK = true
}

-- Movement Enforcer Function
local function applyMovement()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.EnableWalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if Config.EnableJumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                pcall(function()
                    hum.JumpHeight = Config.JumpPower * 0.15
                end)
            end
        end
    end
end

-- Bulletproof Player Plot Finder
local function getMyPlot()
    local activePlots = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild("ActivePlots")
    if not activePlots then 
        return Workspace:FindFirstChild("Plots") or Workspace
    end

    -- 1. Direct owner matching
    for _, plot in ipairs(activePlots:GetChildren()) do
        for _, childName in ipairs({"Owner", "Player", "OwnerValue", "OwnerName", "PlotOwner"}) do
            local obj = plot:FindFirstChild(childName)
            if obj then
                local val = obj.Value
                if val == LocalPlayer or val == LocalPlayer.Name or tostring(val) == LocalPlayer.Name or tostring(val) == tostring(LocalPlayer.UserId) then
                    return plot
                end
            end
        end
        
        for _, attrName in ipairs({"Owner", "UserId", "Player", "OwnerName"}) do
            local attrVal = plot:GetAttribute(attrName)
            if attrVal and (attrVal == LocalPlayer.Name or tostring(attrVal) == tostring(LocalPlayer.UserId)) then
                return plot
            end
        end

        if string.find(plot.Name:lower(), LocalPlayer.Name:lower()) then
            return plot
        end
    end

    -- 2. Distance check (closest plot to character)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrpPos = char.HumanoidRootPart.Position
        local closestPlot = nil
        local minDistance = math.huge

        for _, plot in ipairs(activePlots:GetChildren()) do
            local primary = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart", true)
            if primary then
                local dist = (primary.Position - hrpPos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestPlot = plot
                end
            end
        end
        if closestPlot and minDistance < 500 then
            return closestPlot
        end
    end

    -- 3. Fallback: Return first plot in ActivePlots or Plot1
    return activePlots:FindFirstChild("Plot1") or activePlots:GetChildren()[1]
end

-- ASMR Items Finder for Cash Tapping
local function getASMRCashItems()
    local myPlot = getMyPlot()
    if not myPlot then return {}, nil end

    local items = {}
    
    -- Check ASMR folder in plot
    local asmrFolder = myPlot:FindFirstChild("ASMR") or myPlot:FindFirstChild("PlacedASMR")
    if asmrFolder then
        for _, item in ipairs(asmrFolder:GetChildren()) do
            table.insert(items, item)
        end
    end

    -- Fallback: Check folders or models starting with Placed_
    if #items == 0 then
        for _, child in ipairs(myPlot:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                local nameLower = child.Name:lower()
                if string.find(nameLower, "asmr") or string.find(nameLower, "placed") or string.find(nameLower, "item") then
                    for _, sub in ipairs(child:GetChildren()) do
                        if sub:IsA("Model") then
                            table.insert(items, sub)
                        end
                    end
                elseif child:IsA("Model") and (child.Name:sub(1, 7) == "Placed_" or string.find(nameLower, "asmr")) then
                    table.insert(items, child)
                end
            end
        end
    end

    -- Second Fallback: Scan descendants
    if #items == 0 then
        for _, desc in ipairs(myPlot:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name:sub(1, 7) == "Placed_" or desc.Parent.Name == "ASMR") then
                table.insert(items, desc)
            end
        end
    end

    return items, myPlot
end

-- ==========================================
-- MAIN TAB (ENGLISH)
-- ==========================================
TabMain:Section({ Title = "Conveyor & Tapping" })

TabMain:Toggle({
    Title = "Auto Conveyor Button",
    Desc = "Automatically presses the conveyor button",
    Default = false,
    Callback = function(v)
        Config.AutoConveyor = v
    end
})

TabMain:Slider({
    Title = "Conveyor Speed (Seconds)",
    Desc = "Adjust delay between conveyor button presses",
    Value = { Min = 0.1, Max = 3.0, Default = 0.5, Step = 0.1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 0.5
        Config.ConveyorDelay = val
    end
})

TabMain:Toggle({
    Title = "Auto Buy Conveyor Crates",
    Desc = "Automatically buys crates passing on the conveyor",
    Default = false,
    Callback = function(v)
        Config.AutoBuyConveyorCrates = v
    end
})

TabMain:Toggle({
    Title = "Auto Tap ASMR (Cash)",
    Desc = "Taps all ASMR objects in plot to generate cash",
    Default = false,
    Callback = function(v)
        Config.AutoTapASMR = v
        if v then
            local items, myPlot = getASMRCashItems()
            local plotName = myPlot and myPlot.Name or "Plot"
            WindUI:Notify({ 
                Title = "Auto Tap Enabled", 
                Content = "Tapping " .. tostring(#items) .. " ASMR items in " .. plotName .. "." 
            })
        end
    end
})

TabMain:Slider({
    Title = "Auto Tap Speed (Seconds)",
    Desc = "Adjust tapping delay (lower is faster)",
    Value = { Min = 0.01, Max = 0.5, Default = 0.05, Step = 0.01 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 0.05
        Config.TapDelay = val
    end
})

TabMain:Toggle({
    Title = "Auto Sell ASMR",
    Desc = "Automatically sells ASMR items to NPC Showcase",
    Default = false,
    Callback = function(v)
        Config.AutoSell = v
    end
})

-- ==========================================
-- AUTOMATION TAB (ENGLISH)
-- ==========================================
TabAutomation:Section({ Title = "Rebirth & Plot Expansion" })

TabAutomation:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths when cash requirement is met",
    Default = false,
    Callback = function(v)
        Config.AutoRebirth = v
    end
})

TabAutomation:Button({
    Title = "Rebirth Now",
    Desc = "Manually execute rebirth request",
    Callback = function()
        pcall(function()
            if ReplicatedStorage:FindFirstChild("RebirthRemotes") and ReplicatedStorage.RebirthRemotes:FindFirstChild("RequestRebirth") then
                ReplicatedStorage.RebirthRemotes.RequestRebirth:FireServer()
                WindUI:Notify({ Title = "Success", Content = "Rebirth request sent!" })
            end
        end)
    end
})

TabAutomation:Toggle({
    Title = "Auto Expand Plot",
    Desc = "Automatically purchases plot expansions",
    Default = false,
    Callback = function(v)
        Config.AutoExpandPlot = v
    end
})

TabAutomation:Toggle({
    Title = "Auto Upgrade Conveyor",
    Desc = "Automatically upgrades conveyor luck level",
    Default = false,
    Callback = function(v)
        Config.AutoUpgradeConveyor = v
    end
})

TabAutomation:Section({ Title = "Workers & Upgrades" })

TabAutomation:Toggle({
    Title = "Auto Buy Worker",
    Desc = "Automatically hires additional workers",
    Default = false,
    Callback = function(v)
        Config.AutoBuyWorker = v
    end
})

TabAutomation:Toggle({
    Title = "Auto Upgrade ASMR (Optional)",
    Desc = "Automatically upgrades ASMR item levels (uses cash)",
    Default = false,
    Callback = function(v)
        Config.AutoUpgradeASMR = v
    end
})

TabAutomation:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Automatically claims daily rewards",
    Default = false,
    Callback = function(v)
        Config.AutoClaimDaily = v
    end
})

TabAutomation:Button({
    Title = "Claim Daily Reward Now",
    Desc = "Manually claim daily reward",
    Callback = function()
        pcall(function()
            ReplicatedStorage.DailyRewardRemotes.ClaimDailyReward:FireServer()
        end)
        WindUI:Notify({ Title = "Success", Content = "Daily reward claimed!" })
    end
})

-- ==========================================
-- PLAYER TAB (ENGLISH)
-- ==========================================
TabPlayer:Section({ Title = "Movement & Character" })

TabPlayer:Toggle({
    Title = "Enable Custom WalkSpeed",
    Desc = "Adjust character walking speed",
    Default = false,
    Callback = function(v)
        Config.EnableWalkSpeed = v
        if not v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        else
            applyMovement()
        end
    end
})

TabPlayer:Slider({
    Title = "WalkSpeed Amount",
    Value = { Min = 16, Max = 250, Default = 16, Step = 1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 16
        Config.WalkSpeed = val
        Config.EnableWalkSpeed = true
        applyMovement()
    end
})

TabPlayer:Toggle({
    Title = "Enable Custom JumpPower",
    Desc = "Adjust character jump power",
    Default = false,
    Callback = function(v)
        Config.EnableJumpPower = v
        if not v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = 50 
            end
        else
            applyMovement()
        end
    end
})

TabPlayer:Slider({
    Title = "JumpPower Amount",
    Value = { Min = 50, Max = 300, Default = 50, Step = 1 },
    Callback = function(v)
        local val = typeof(v) == "table" and (v.Value or v[1]) or tonumber(v) or 50
        Config.JumpPower = val
        Config.EnableJumpPower = true
        applyMovement()
    end
})

TabPlayer:Toggle({
    Title = "Noclip",
    Desc = "Character can pass through walls and obstacles",
    Default = false,
    Callback = function(v)
        Config.Noclip = v
    end
})

-- ==========================================
-- SETTINGS TAB (ENGLISH)
-- ==========================================
TabSettings:Section({ Title = "Script Settings" })

TabSettings:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox from disconnecting you after 20 minutes",
    Default = true,
    Callback = function(v)
        Config.AntiAFK = v
    end
})

TabSettings:Button({
    Title = "Join Discord",
    Desc = "Copy Discord invite link to clipboard",
    Callback = function()
        setclipboard("https://discord.gg/2PPBJsmqr")
        WindUI:Notify({ Title = "Copied", Content = "Discord invite link copied to clipboard!" })
    end
})

-- ==========================================
-- LOOPS & BACKEND LOGIC
-- ==========================================

-- Anti AFK Connection
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Character Movement & Noclip Loop (Runs every frame)
local function onStep()
    if not getGlobal("IndraHubUnboxASMRRunning") then return end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.EnableWalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if Config.EnableJumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                pcall(function()
                    hum.JumpHeight = Config.JumpPower * 0.15
                end)
            end
        end
        
        if Config.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end

local c1 = RunService.Heartbeat:Connect(onStep)
local c2 = RunService.Stepped:Connect(onStep)
table.insert(scriptConnections, c1)
table.insert(scriptConnections, c2)

-- Dedicated Auto Conveyor Loop
task.spawn(function()
    while true do
        local delayVal = Config.ConveyorDelay or 0.5
        task.wait(delayVal)
        if not getGlobal("IndraHubUnboxASMRRunning") then break end
        
        if Config.AutoConveyor then
            pcall(function()
                ReplicatedStorage.PlotSystemRemotes.ConveyorButtonPress:FireServer()
            end)
        end
    end
end)

-- Fast Main Loop (Auto Buy Conveyor Crates & Auto Tap ASMR)
task.spawn(function()
    while true do
        local delayVal = Config.TapDelay or 0.05
        task.wait(delayVal)
        if not getGlobal("IndraHubUnboxASMRRunning") then break end

        -- Auto Buy Conveyor Crates (Auto Press E - Bulletproof Crate Detector)
        if Config.AutoBuyConveyorCrates then
            pcall(function()
                local prompts = {}
                local myPlot = getMyPlot()
                if myPlot then
                    for _, desc in ipairs(myPlot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            table.insert(prompts, desc)
                        end
                    end
                end

                -- Also check Conveyor / Crates in Workspace
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") or obj:IsA("Folder") then
                        local nameLower = obj.Name:lower()
                        if string.find(nameLower, "crate") or string.find(nameLower, "conveyor") or string.find(nameLower, "drop") then
                            for _, desc in ipairs(obj:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    table.insert(prompts, desc)
                                end
                            end
                        end
                    end
                end

                for _, desc in ipairs(prompts) do
                    local nameLower = desc.Parent and desc.Parent.Name:lower() or ""
                    local actionLower = desc.ActionText and desc.ActionText:lower() or ""
                    local objectLower = desc.ObjectText and desc.ObjectText:lower() or ""
                    
                    -- Blacklist Feedback, Social, Mailbox, and UI prompts
                    local isBlacklisted = string.find(nameLower, "feedback") 
                        or string.find(actionLower, "feedback") 
                        or string.find(objectLower, "feedback")
                        or string.find(nameLower, "mailbox")
                        or string.find(objectLower, "mailbox")
                        or string.find(nameLower, "social")
                        or string.find(nameLower, "ui")
                        
                    if not isBlacklisted then
                        local textCombo = (nameLower .. " " .. actionLower .. " " .. objectLower)
                        if string.find(textCombo, "crate") 
                            or string.find(textCombo, "buy") 
                            or string.find(textCombo, "open") 
                            or string.find(textCombo, "unbox") 
                            or string.find(textCombo, "claim")
                            or string.find(textCombo, "purchase") then
                            if fireproximityprompt then
                                fireproximityprompt(desc)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Auto Tap ASMR (Pure Cash Generation - Max Power)
        if Config.AutoTapASMR then
            pcall(function()
                local items = getASMRCashItems()
                for _, asmrItem in ipairs(items) do
                    -- Check direct children BaseParts first, fallback to descendants
                    local childrenParts = {}
                    for _, child in ipairs(asmrItem:GetChildren()) do
                        if child:IsA("BasePart") then
                            table.insert(childrenParts, child)
                        end
                    end

                    if #childrenParts == 0 then
                        for _, desc in ipairs(asmrItem:GetDescendants()) do
                            if desc:IsA("BasePart") then
                                table.insert(childrenParts, desc)
                            end
                        end
                    end
                    
                    if #childrenParts > 0 then
                        -- Tap all keys per item automatically
                        local maxKeys = math.min(#childrenParts, 15)
                        for i = 1, maxKeys do
                            local keyPart = childrenParts[i]
                            if keyPart then
                                ReplicatedStorage.ASMRRewardRemotes.RequestInteraction:FireServer(
                                    asmrItem,
                                    keyPart,
                                    "Keyboard",
                                    keyPart.Position
                                )
                                
                                if ReplicatedStorage:FindFirstChild("KeyboardWorkerPressEvent") then
                                    pcall(function()
                                        ReplicatedStorage.KeyboardWorkerPressEvent:Fire(asmrItem, keyPart, false)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Optional Auto Upgrade ASMR Loop
task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubUnboxASMRRunning") then break end
        
        if Config.AutoUpgradeASMR then
            pcall(function()
                local items = getASMRCashItems()
                for _, asmrItem in ipairs(items) do
                    if ReplicatedStorage:FindFirstChild("ASMRRewardRemotes") and ReplicatedStorage.ASMRRewardRemotes:FindFirstChild("RequestUpgrade") then
                        ReplicatedStorage.ASMRRewardRemotes.RequestUpgrade:FireServer(asmrItem)
                    end
                end
            end)
        end
    end
end)

-- Medium Loop (Rebirth, Plot Expansion, Conveyor Upgrade, Selling & Buying Worker)
task.spawn(function()
    while task.wait(0.5) do
        if not getGlobal("IndraHubUnboxASMRRunning") then break end
        
        -- Auto Rebirth
        if Config.AutoRebirth then
            pcall(function()
                if ReplicatedStorage:FindFirstChild("RebirthRemotes") and ReplicatedStorage.RebirthRemotes:FindFirstChild("RequestRebirth") then
                    ReplicatedStorage.RebirthRemotes.RequestRebirth:FireServer()
                end
            end)
        end

        -- Auto Expand Plot
        if Config.AutoExpandPlot then
            pcall(function()
                if ReplicatedStorage:FindFirstChild("PlotExpansionRemotes") then
                    local remote = ReplicatedStorage.PlotExpansionRemotes:FindFirstChild("RequestExpansion") 
                        or ReplicatedStorage.PlotExpansionRemotes:FindFirstChild("BuyExpansion")
                        or ReplicatedStorage.PlotExpansionRemotes:FindFirstChildWhichIsA("RemoteEvent")
                    if remote then
                        for i = 1, 36 do
                            local expId = string.format("EXPANSION_%02d", i)
                            remote:FireServer(expId)
                        end
                    end
                end
            end)
        end

        -- Auto Upgrade Conveyor
        if Config.AutoUpgradeConveyor then
            pcall(function()
                if ReplicatedStorage:FindFirstChild("PlotSystemRemotes") then
                    local remote = ReplicatedStorage.PlotSystemRemotes:FindFirstChild("ConveyorUpgrade") 
                        or ReplicatedStorage.PlotSystemRemotes:FindFirstChild("RequestConveyorUpgrade")
                    if remote then
                        remote:FireServer()
                    end
                end
            end)
        end

        -- Auto Sell
        if Config.AutoSell then
            pcall(function()
                local npc = Workspace:FindFirstChild("showcase npc", true) or Workspace:FindFirstChild("NPC", true)
                if npc then
                    ReplicatedStorage.ASMRSellRemotes.SellASMRRequest:InvokeServer(npc)
                end
            end)
        end
        
        -- Auto Buy Worker
        if Config.AutoBuyWorker then
            pcall(function()
                ReplicatedStorage.WorkerRemotes.BuyWorker:FireServer()
            end)
        end
    end
end)

-- Slow Loop (Daily Claims)
task.spawn(function()
    while task.wait(5) do
        if not getGlobal("IndraHubUnboxASMRRunning") then break end
        
        if Config.AutoClaimDaily then
            pcall(function()
                ReplicatedStorage.DailyRewardRemotes.ClaimDailyReward:FireServer()
            end)
        end
    end
end)

WindUI:Notify({
    Title = "IndraHub Loaded",
    Content = "Unbox ASMR Simulator Script successfully loaded!",
    Duration = 4
})
