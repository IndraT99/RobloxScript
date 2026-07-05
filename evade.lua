-- [IndraHub] Evade Script - WindUI Edition
local env = getgenv and getgenv() or _G
local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then return value end
    return env[key]
end

setGlobal("IndraExecId", game:GetService("HttpService"):GenerateGUID(false))
local CurrentExecId = getGlobal("IndraExecId")
setGlobal("IndraHubEvadeRunning", true)
setGlobal("IndraHubEvadeLastHeartbeat", os.clock())
setGlobal("IndraHubEvadeError", nil)

task.spawn(function()
    while getGlobal("IndraHubEvadeRunning") and getGlobal("IndraExecId") == CurrentExecId do
        setGlobal("IndraHubEvadeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

if game.CoreGui:FindFirstChild("IndraHubToggle") then game.CoreGui.IndraHubToggle:Destroy() end

local vu1 = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer
local function IsScriptActive() return env.IndraExecId == CurrentExecId end

-- IH Toggle Button
task.spawn(function()
    if not IsScriptActive() then return end
    local CoreGui = game:GetService("CoreGui")
    local VIM = game:GetService("VirtualInputManager")
    local SG = Instance.new("ScreenGui") SG.Name = "IndraHubToggle"
    if syn and syn.protect_gui then syn.protect_gui(SG) SG.Parent = CoreGui
    elseif gethui then SG.Parent = gethui() else SG.Parent = CoreGui end
    local TB = Instance.new("TextButton") TB.Name = "ToggleButton" TB.Parent = SG
    TB.BackgroundColor3 = Color3.fromHex("#1a1a1a") TB.Position = UDim2.new(0,50,0,50)
    TB.Size = UDim2.new(0,45,0,45) TB.Text = "IH" TB.TextColor3 = Color3.fromRGB(255,255,255)
    TB.TextSize = 20 TB.Font = Enum.Font.GothamBold TB.Active = true TB.Draggable = true
    local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0,12) C.Parent = TB
    local S = Instance.new("UIStroke") S.Parent = TB S.Color = Color3.fromHex("#8b5cf6") S.Thickness = 2
    TB.MouseButton1Click:Connect(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.V, false, game) task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.V, false, game)
    end)
    task.spawn(function() while SG.Parent do task.wait(1) if not IsScriptActive() then SG:Destroy() break end end end)
end)

-- Themes
vu1:AddTheme({Name="Dark",Accent="#8b5cf6",Dialog="#1e293b",Outline="#334155",Text="#f8fafc",Placeholder="#94a3b8",Background="#0f172a",Button="#1e293b",Icon="#f8fafc"})
vu1:AddTheme({Name="Light",Accent="#f4f4f5",Dialog="#f4f4f5",Outline="#000000",Text="#000000",Placeholder="#666666",Background="#ffffff",Button="#e4e4e7",Icon="#52525b"})
vu1:AddTheme({Name="Gray",Accent="#374151",Dialog="#374151",Outline="#d1d5db",Text="#f9fafb",Placeholder="#9ca3af",Background="#1f2937",Button="#4b5563",Icon="#d1d5db"})
vu1:AddTheme({Name="Blue",Accent="#1e40af",Dialog="#1e3a8a",Outline="#93c5fd",Text="#f0f9ff",Placeholder="#60a5fa",Background="#1e293b",Button="#3b82f6",Icon="#93c5fd"})
vu1:AddTheme({Name="Green",Accent="#059669",Dialog="#047857",Outline="#6ee7b7",Text="#ecfdf5",Placeholder="#34d399",Background="#064e3b",Button="#10b981",Icon="#6ee7b7"})
vu1:AddTheme({Name="Purple",Accent="#7c3aed",Dialog="#6d28d9",Outline="#c4b5fd",Text="#faf5ff",Placeholder="#a78bfa",Background="#581c87",Button="#8b5cf6",Icon="#c4b5fd"})
vu1:SetNotificationLower(true)
local themeList = {"Dark","Light","Gray","Blue","Green","Purple"}
local themeIndex = 1
if not getgenv().TransparencyEnabled then getgenv().TransparencyEnabled = false end
local featureStates = {}

-- Window
local Window = vu1:CreateWindow({
    Title = "IndraHub",
    Icon = "star",
    Author = "Indra",
    Folder = "IndraHubEvade",
    Size = UDim2.fromOffset(580, 460),
    Transparent = getgenv().TransparencyEnabled,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            themeIndex = themeIndex + 1
            if themeIndex > #themeList then themeIndex = 1 end
            local t = themeList[themeIndex]
            vu1:SetTheme(t)
            vu1:Notify({Title="Theme Changed",Content="Switched to "..t.." theme!",Duration=2,Icon="palette"})
        end,
    },
})

-- Set toggle key to V
Window.SetToggleKey(Window, Enum.KeyCode.V)

-- Topbar Buttons
pcall(function()
    Window:CreateTopbarButton("TransparencyToggle", "eye", function()
        getgenv().TransparencyEnabled = not getgenv().TransparencyEnabled
        pcall(function() Window:ToggleTransparency(getgenv().TransparencyEnabled) end)
        vu1:Notify({Title="Transparency",Content="Transparency "..(getgenv().TransparencyEnabled and "Enabled" or "Disabled"),Duration=2,Icon="eye"})
    end, 990)
    Window:CreateTopbarButton("UnloadScript", "x", function()
        vu1:Notify({Title="Unloading...",Content="Script is unloading.",Duration=2,Icon="trash"})
        if game.CoreGui:FindFirstChild("IndraHubToggle") then game.CoreGui.IndraHubToggle:Destroy() end
        getgenv().IndraExecId = "UNLOADED"
        task.wait(0.5)
        for _,g in ipairs(game.CoreGui:GetChildren()) do if g.Name == "WindUI" or g:FindFirstChild("Main") then g:Destroy() end end
    end, 992)
end)

-- Edit Open Button
Window.EditOpenButton(Window, {
    Title = "Toggle",
    Icon = "zap",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(138, 43, 226), Color3.fromRGB(173, 216, 230)),
    Draggable = true,
})

-- Tabs (directly on Window, matching script99 API)
-- ESP Tab removed
local PlayerTab = Window:Tab({Title="Player",Icon="user",Desc="IndraHub"})
local AutoFarmTab = Window:Tab({Title="Auto Farm",Icon="clock",Desc="IndraHub"})
local CombatTab = Window:Tab({Title="Combat",Icon="sword",Desc="IndraHub"})
local MiscTab = Window:Tab({Title="Misc",Icon="star",Desc="IndraHub"})
local VisualsTab = Window:Tab({Title="Visuals",Icon="palette",Desc="IndraHub"})
local EventTab = Window:Tab({Title="Event",Icon="calendar",Desc="IndraHub"})
local InfoTab = Window:Tab({Title="Info",Icon="badge-info",Desc="IndraHub"})

-- isNextbotModel (used by Combat Anti-Nextbot)
local function isNextbotModel(model)
    if not model or not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return not Players:GetPlayerFromCharacter(model)
end

-- ==================== PLAYER TAB ====================
PlayerTab:Section({Title="Movement"})
local flyEnabled = false
local flySpeed = 50
local flyConnection, bodyGyro, bodyVelocity = nil, nil, nil

local function startFly()
    local ch = LocalPlayer.Character if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    bodyGyro = Instance.new("BodyGyro") bodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge) bodyGyro.P = 9e4 bodyGyro.Parent = hrp
    bodyVelocity = Instance.new("BodyVelocity") bodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge) bodyVelocity.Velocity = Vector3.new(0,0,0) bodyVelocity.Parent = hrp
    hum.PlatformStand = true
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local cam = workspace.CurrentCamera bodyGyro.CFrame = cam.CFrame
        local md = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then md = md - Vector3.new(0,1,0) end
        if md.Magnitude > 0 then md = md.Unit end
        bodyVelocity.Velocity = md * flySpeed
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    local ch = LocalPlayer.Character
    if ch then local h = ch:FindFirstChild("Humanoid") if h then h.PlatformStand = false end end
end

PlayerTab:Toggle({Title="Fly",Value=false,Callback=function(s) flyEnabled = s if s then startFly() else stopFly() end end})
PlayerTab:Input({Title="Fly Speed",Value="50",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 then flySpeed = n end end})

-- Noclip
local noclipEnabled = false
local noclipConnection = nil
local function toggleNoclip(state)
    noclipEnabled = state
    if state then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            local ch = LocalPlayer.Character if ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end end
end
PlayerTab:Toggle({Title="Noclip",Value=false,Callback=function(s) toggleNoclip(s) end})
LocalPlayer.CharacterAdded:Connect(function() if noclipEnabled then task.wait(0.5) toggleNoclip(false) task.wait(0.1) toggleNoclip(true) end end)

-- Bug Emote
local sitLoopConnection = nil
local function updateSit()
    local ch = player.Character if not ch then return end
    local hum = ch:FindFirstChild("Humanoid")
    if not hum then
        local gp = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gp then local pm = gp:FindFirstChild(player.Name) if pm then hum = pm:FindFirstChild("Humanoid") end end
    end
    if hum then hum.Sit = true end
end
PlayerTab:Toggle({Title="Bug Emote",Value=false,Callback=function(s)
    if s then if sitLoopConnection then sitLoopConnection:Disconnect() end sitLoopConnection = RunService.Heartbeat:Connect(updateSit) updateSit()
    else if sitLoopConnection then sitLoopConnection:Disconnect() sitLoopConnection = nil end
        local ch = player.Character if ch then local h = ch:FindFirstChild("Humanoid") if h then h.Sit = false end end
    end
end})

PlayerTab:Section({Title="Barriers"})
PlayerTab:Toggle({Title="Remove Barriers",Value=false,Callback=function(s)
    local ip = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("InvisParts")
    if not ip then vu1:Notify({Title="Barriers",Content="InvisParts not found!",Duration=3}) return end
    for _,o in ipairs(ip:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide = not s o.CanQuery = not s end end
end})
PlayerTab:Toggle({Title="Barriers Visible",Value=false,Callback=function(s)
    local ip = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("InvisParts")
    if not ip then return end
    for _,o in ipairs(ip:GetDescendants()) do if o:IsA("BasePart") or o:IsA("Decal") then o.Transparency = s and 0 or 1 end end
end})

-- ==================== AUTO FARM TAB ====================
if not workspace:FindFirstChild("SecurityPart") then
    local sp = Instance.new("Part") sp.Name = "SecurityPart" sp.Size = Vector3.new(10,1,10)
    sp.Position = Vector3.new(5000,5000,5000) sp.Anchored = true sp.CanCollide = true sp.Parent = workspace
end
AutoFarmTab:Section({Title="Farming"})
local AutoMoneyFarmConnection = nil
local AutoWinConnection = nil
local AutoTicketFarmConnection = nil
local AutoReviveModule = nil
local autoMoneyFarmEnabled = false
local autoTicketFarmEnabled = false
local afkFarmEnabled = false
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

function startAutoWin()
    if AutoWinConnection then return end
    AutoWinConnection = RunService.Heartbeat:Connect(function()
        local sp = workspace:FindFirstChild("SecurityPart") if not sp then return end
        local ch = LocalPlayer.Character if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
        if not ch:GetAttribute("Downed") then hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) end
    end)
end
function stopAutoWin() if AutoWinConnection then AutoWinConnection:Disconnect() AutoWinConnection = nil end end

function startAutoMoneyFarm()
    if AutoMoneyFarmConnection then return end
    AutoMoneyFarmConnection = RunService.Heartbeat:Connect(function()
        local sp = workspace:FindFirstChild("SecurityPart") if not sp then return end
        local ch = LocalPlayer.Character if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local found = false
        local gp = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gp then
            for _,v in pairs(gp:GetChildren()) do
                if v:IsA("Model") and v:GetAttribute("Downed") then
                    if not v:FindFirstChild("RagdollConstraints") then
                        local vh = v:FindFirstChild("HumanoidRootPart")
                        if vh then
                            hrp.CFrame = vh.CFrame + Vector3.new(0,3,0)
                            pcall(function() ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, v) end)
                            task.wait(0.5) found = true break
                        end
                    end
                end
            end
        end
        if not found then hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) end
    end)
end
function stopAutoMoneyFarm() if AutoMoneyFarmConnection then AutoMoneyFarmConnection:Disconnect() AutoMoneyFarmConnection = nil end end

AutoFarmTab:Toggle({Title="Auto Farm Money",Value=false,Callback=function(s) autoMoneyFarmEnabled = s if s then startAutoMoneyFarm() else stopAutoMoneyFarm() end end})
AutoFarmTab:Toggle({Title="Auto Farm Tickets",Value=false,Callback=function(s)
    autoTicketFarmEnabled = s
    if s then
        local sp = workspace:FindFirstChild("SecurityPart") if not sp then return end
        if AutoTicketFarmConnection then AutoTicketFarmConnection:Disconnect() end
        local currentTicket = nil
        AutoTicketFarmConnection = RunService.Heartbeat:Connect(function()
            local ch = LocalPlayer.Character if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
            if ch:GetAttribute("Downed") then
                pcall(function() ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true) end)
                hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) return
            end
            local tickets = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Effects") and workspace.Game.Effects:FindFirstChild("Tickets")
            if tickets then
                local at = tickets:GetChildren()
                if #at > 0 then
                    if not currentTicket or not currentTicket.Parent then currentTicket = at[1] end
                    if currentTicket and currentTicket.Parent then
                        local tp = currentTicket:FindFirstChild("HumanoidRootPart") or (currentTicket:IsA("BasePart") and currentTicket)
                        if tp then hrp.CFrame = tp.CFrame else currentTicket = nil end
                    else hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) currentTicket = nil end
                else hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) currentTicket = nil end
            else hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) currentTicket = nil end
        end)
    else if AutoTicketFarmConnection then AutoTicketFarmConnection:Disconnect() AutoTicketFarmConnection = nil end end
end})
AutoFarmTab:Toggle({Title="AFK Farm",Value=false,Callback=function(s) afkFarmEnabled = s if s then startAutoWin() else stopAutoWin() end end})

AutoFarmTab:Section({Title="Teleports"})
AutoFarmTab:Button({Title="Custom Server",Callback=function()
    vu1:Notify({Title="Server",Content="Creating Custom Server...",Duration=3})
    task.wait(1) pcall(function() game:GetService("TeleportService"):Teleport(99214917572799) end)
end})

-- ==================== COMBAT TAB ====================
CombatTab:Section({Title="Anti-Nextbot"})
featureStates.AntiNextbot = false
featureStates.AntiNextbotDistance = 50
local antiNextbotConnection = nil
local farmsSuppressedByAntiNextbot = false
local previousMoneyFarm, previousTicketFarm, previousAutoWin = false, false, false

CombatTab:Toggle({Title="Anti-Nextbot",Value=false,Callback=function(s)
    featureStates.AntiNextbot = s
    if s then
        antiNextbotConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AntiNextbot then return end
            local ch = player.Character local hrp = ch and ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
            local nearest = math.huge
            local function checkFolder(folder)
                if not folder then return end
                for _,m in pairs(folder:GetChildren()) do
                    if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and isNextbotModel(m) then
                        local d = (m.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < nearest then nearest = d end
                    end
                end
            end
            checkFolder(workspace:FindFirstChild("NPCs"))
            local gp = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            checkFolder(gp)
            local tooClose = nearest < featureStates.AntiNextbotDistance
            if tooClose and not farmsSuppressedByAntiNextbot then
                previousMoneyFarm = autoMoneyFarmEnabled previousTicketFarm = autoTicketFarmEnabled previousAutoWin = afkFarmEnabled
                if autoMoneyFarmEnabled then stopAutoMoneyFarm() autoMoneyFarmEnabled = false end
                if autoTicketFarmEnabled and AutoTicketFarmConnection then AutoTicketFarmConnection:Disconnect() AutoTicketFarmConnection = nil autoTicketFarmEnabled = false end
                if afkFarmEnabled then stopAutoWin() afkFarmEnabled = false end
                farmsSuppressedByAntiNextbot = true
            elseif not tooClose and farmsSuppressedByAntiNextbot then
                if previousMoneyFarm then startAutoMoneyFarm() autoMoneyFarmEnabled = true end
                if previousAutoWin then startAutoWin() afkFarmEnabled = true end
                farmsSuppressedByAntiNextbot = false
            end
            if tooClose then
                local safe = workspace:FindFirstChild("SecurityPart")
                if safe then hrp.CFrame = safe.CFrame + Vector3.new(math.random(-5,5),3,math.random(-5,5)) end
            end
        end)
    else
        if antiNextbotConnection then antiNextbotConnection:Disconnect() antiNextbotConnection = nil end
        if farmsSuppressedByAntiNextbot then
            if previousMoneyFarm then startAutoMoneyFarm() autoMoneyFarmEnabled = true end
            if previousAutoWin then startAutoWin() afkFarmEnabled = true end
            farmsSuppressedByAntiNextbot = false
        end
    end
end})
CombatTab:Input({Title="Detection Distance",Value="50",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 then featureStates.AntiNextbotDistance = n end end})

-- ==================== MISC TAB ====================
MiscTab:Section({Title="Player Adjustments"})
local currentSettings = {Speed="1500",JumpCap="1",AirStrafeAcceleration="187"}
local requiredFields = {Friction=true,AirStrafeAcceleration=true,JumpHeight=true,RunDeaccel=true,JumpSpeedMultiplier=true,JumpCap=true,SprintCap=true,WalkSpeedMultiplier=true,BhopEnabled=true,Speed=true,AirAcceleration=true,RunAccel=true,SprintAcceleration=true}
local function hasAllFields(t) if type(t) ~= "table" then return false end for f in pairs(requiredFields) do if rawget(t,f) == nil then return false end end return true end
local function getConfigTables() local r = {} for _,o in ipairs(getgc(true)) do local s,v = pcall(function() if hasAllFields(o) then return o end end) if s and v then table.insert(r,v) end end return r end
local function applyToTables(cb) for _,t in ipairs(getConfigTables()) do if t and typeof(t)=="table" then pcall(cb,t) end end end

MiscTab:Input({Title="Player Speed",Value="1500",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n >= 1450 then currentSettings.Speed = tostring(n) applyToTables(function(o) o.Speed = n end) end end})
local JumpPowerValue = 3.5
MiscTab:Input({Title="Player Jump",Value="3.5",Numeric=true,Callback=function(v) if v and tonumber(v) then JumpPowerValue = tonumber(v) end end})
MiscTab:Input({Title="Player Jump Cap",Value="1",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n >= 0.1 then applyToTables(function(o) o.JumpCap = n end) end end})
MiscTab:Input({Title="Strafe Acceleration",Value="187",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n >= 1 then applyToTables(function(o) o.AirStrafeAcceleration = n end) end end})

local ChangeSettingRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Data"):WaitForChild("ChangeSetting")
local UpdatedEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Settings"):WaitForChild("Updated")
MiscTab:Input({Title="Player FOV",Value="",Numeric=true,Callback=function(v) local n = tonumber(v) if n then ChangeSettingRemote:InvokeServer(2,n) UpdatedEvent:Fire(2,n) end end})

-- Multi-jump
local MaxJumpsValue = math.huge
local CurrentJumpCount = 0
local JumpHumanoid, JumpRootPart = nil, nil
Players.LocalPlayer.CharacterAdded:Connect(function(nc)
    task.wait(0.5) JumpHumanoid = nc:FindFirstChild("Humanoid") JumpRootPart = nc:FindFirstChild("HumanoidRootPart")
    if JumpHumanoid and JumpRootPart then CurrentJumpCount = 0
        JumpHumanoid.StateChanged:Connect(function(_,n) if n == Enum.HumanoidStateType.Landed then CurrentJumpCount = 0 end end)
        JumpHumanoid.Jumping:Connect(function(j) if j and CurrentJumpCount < MaxJumpsValue then CurrentJumpCount = CurrentJumpCount + 1 JumpHumanoid.JumpHeight = JumpPowerValue if CurrentJumpCount > 1 and JumpRootPart then JumpRootPart:ApplyImpulse(Vector3.new(0,JumpPowerValue*JumpRootPart.Mass,0)) end end end)
    end
end)
LocalPlayer.CharacterAdded:Connect(function(nc) character = nc task.wait(0.5) humanoid = nc:WaitForChild("Humanoid") rootPart = nc:WaitForChild("HumanoidRootPart") end)

MiscTab:Section({Title="Bounce"})
local bounceEnabled = false
local bounceConnection = nil
local bounceSpeed = 110
MiscTab:Toggle({Title="Modify Bounce",Value=false,Callback=function(s)
    bounceEnabled = s
    if s then
        if bounceConnection then bounceConnection:Disconnect() end
        bounceConnection = RunService.Heartbeat:Connect(function()
            if not bounceEnabled then return end
            local gp = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") if not gp then return end
            local pm = gp:FindFirstChild(player.Name) if not pm then return end
            local h = pm:FindFirstChild("Humanoid") if h then h.WalkSpeed = bounceSpeed end
        end)
    else if bounceConnection then bounceConnection:Disconnect() bounceConnection = nil end end
end})
MiscTab:Input({Title="Bounce Speed",Value="110",Numeric=true,Callback=function(v) local n = tonumber(v) if n then bounceSpeed = n end end})

MiscTab:Section({Title="Revive Players"})
local instantReviveDelay = 0.15
local InstantReviveModule = (function()
    local LP = Players.LocalPlayer
    local enabled = false local handle = nil
    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")
    local loopDelay = 0.15
    local function reviveLoop()
        while enabled do
            local myChar = LP.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myHRP = myChar.HumanoidRootPart
                for _,pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        if pl.Character:GetAttribute("Downed") or (pl.Character:FindFirstChild("Humanoid") and pl.Character.Humanoid.Health <= 0) then
                            local d = (myHRP.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                            if d <= 10 then pcall(function() interactEvent:FireServer("Revive", true, pl.Name) end) end
                        end
                    end
                end
            end
            task.wait(loopDelay)
        end
    end
    return {
        Start = function() if handle then return end enabled = true handle = task.spawn(reviveLoop) end,
        Stop = function() enabled = false if handle then task.cancel(handle) handle = nil end end,
        SetDelay = function(d) loopDelay = d end,
    }
end)()
MiscTab:Toggle({Title="Instant Revive",Value=false,Callback=function(s) if s then InstantReviveModule.SetDelay(instantReviveDelay) InstantReviveModule.Start() else InstantReviveModule.Stop() end end})
MiscTab:Slider({Title="Revive Delay",Step=0.01,Value={Min=0,Max=1,Default=0.15},Callback=function(v) instantReviveDelay = v InstantReviveModule.SetDelay(v) end})

MiscTab:Section({Title="Carry Players"})
local AutoCarryConnection = nil
featureStates.AutoCarry = false
MiscTab:Toggle({Title="Auto Carry",Value=false,Callback=function(s)
    featureStates.AutoCarry = s
    if s then
        if AutoCarryConnection then return end
        AutoCarryConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AutoCarry then return end
            local ch = player.Character local hrp = ch and ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
            for _,o in ipairs(Players:GetPlayers()) do
                if o ~= player and o.Character and o.Character:FindFirstChild("HumanoidRootPart") then
                    if (hrp.Position - o.Character.HumanoidRootPart.Position).Magnitude <= 20 then
                        pcall(function() ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact"):FireServer("Carry", nil, o.Name) end)
                    end
                end
            end
        end)
    else if AutoCarryConnection then AutoCarryConnection:Disconnect() AutoCarryConnection = nil end end
end})

MiscTab:Section({Title="Auto Drink"})
local AutoDrinkConn = nil
featureStates.AutoDrink = false
featureStates.DrinkDelay = 0.5
MiscTab:Toggle({Title="Auto Drink Cola",Value=false,Callback=function(s)
    featureStates.AutoDrink = s
    if s then
        AutoDrinkConn = task.spawn(function()
            while featureStates.AutoDrink do
                pcall(function() player.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Forced=true,Key="Cola",Down=true}) end)
                task.wait(featureStates.DrinkDelay)
            end
        end)
    else if AutoDrinkConn then task.cancel(AutoDrinkConn) AutoDrinkConn = nil end end
end})
MiscTab:Input({Title="Drink Delay",Value="0.5",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 then featureStates.DrinkDelay = n end end})

MiscTab:Section({Title="Gravity"})
local gravityEnabled = false
local originalGravity = workspace.Gravity
local gravityValue = 10
MiscTab:Toggle({Title="Gravity",Value=false,Callback=function(s) gravityEnabled = s if s then workspace.Gravity = gravityValue else workspace.Gravity = originalGravity end end})
MiscTab:Input({Title="Gravity Value",Value="10",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 then gravityValue = n if gravityEnabled then workspace.Gravity = n end end end})

MiscTab:Section({Title="Gun Functions"})
MiscTab:Button({Title="Grapplehook",Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/GrapplerGun.lua"))() end) end})
MiscTab:Button({Title="Breacher (Portal Gun)",Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/PortalGun.lua"))() end) end})
MiscTab:Button({Title="Smoke Grenade",Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/SmokeGrenade.lua"))() end) end})

MiscTab:Section({Title="Infinite Slide"})
local infiniteSlideEnabled = false
MiscTab:Toggle({Title="Infinite Slide",Value=false,Callback=function(s)
    infiniteSlideEnabled = s
    for _,obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "SlideTime") then
            pcall(function() obj.SlideTime = s and math.huge or 1.1 if rawget(obj,"SlideCooldown") then obj.SlideCooldown = s and 0 or 0.5 end end)
        end
    end
end})

MiscTab:Section({Title="Client Modification"})
MiscTab:Toggle({Title="Full Bright",Value=false,Callback=function(s)
    featureStates.FullBright = s
    local L = game:GetService("Lighting")
    if s then
        featureStates.origBright = L.Brightness featureStates.origAmb = L.Ambient featureStates.origOutAmb = L.OutdoorAmbient
        local function apply() L.Brightness=1 L.Ambient=Color3.new(1,1,1) L.OutdoorAmbient=Color3.new(1,1,1) L.ColorShift_Bottom=Color3.new(1,1,1) L.ColorShift_Top=Color3.new(1,1,1) end
        apply()
        if featureStates.fbConn then featureStates.fbConn:Disconnect() end
        featureStates.fbConn = RunService.Heartbeat:Connect(function() if featureStates.FullBright then apply() end end)
    else
        if featureStates.fbConn then featureStates.fbConn:Disconnect() featureStates.fbConn = nil end
        if featureStates.origBright then L.Brightness = featureStates.origBright L.Ambient = featureStates.origAmb L.OutdoorAmbient = featureStates.origOutAmb end
    end
end})
MiscTab:Button({Title="Anti Lag 1",Callback=function()
    local L = game:GetService("Lighting") L.GlobalShadows = false L.FogEnd = 1e10 L.Brightness = 1
    local T = workspace:FindFirstChildOfClass("Terrain") if T then T.WaterWaveSize=0 T.WaterWaveSpeed=0 T.WaterReflectance=0 T.WaterTransparency=1 end
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") then o.Material=Enum.Material.Plastic o.Reflectance=0
        elseif o:IsA("Decal") or o:IsA("Texture") or o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o:Destroy() end
    end
end})
MiscTab:Button({Title="Anti Lag 2",Callback=function()
    for _,v in next,game:GetDescendants() do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic end
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then v.Enabled=false end
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v.Enabled=false end
        if v:IsA("Decal") or v:IsA("Texture") then v.Texture="" end
        if v:IsA("Sky") then v.Parent=nil end
    end
end})
MiscTab:Button({Title="Remove Texture",Callback=function()
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("Part") then p.Material=Enum.Material.SmoothPlastic end
        if p:FindFirstChildWhichIsA("Texture") then p:FindFirstChildWhichIsA("Texture").Texture="rbxassetid://0" end
        if p:FindFirstChildWhichIsA("Decal") then p:FindFirstChildWhichIsA("Decal").Texture="rbxassetid://0" end
    end
end})
MiscTab:Toggle({Title="Remove Fog",Value=false,Callback=function(s)
    local L = game:GetService("Lighting")
    if s then featureStates.origFog = L.FogEnd L.FogEnd = 1000000 for _,v in pairs(L:GetDescendants()) do if v:IsA("Atmosphere") then v:Destroy() end end
    else if featureStates.origFog then L.FogEnd = featureStates.origFog end end
end})

MiscTab:Section({Title="Camera Adjustments"})
local camStretchConn = nil
local strH, strV = 0.80, 0.80
MiscTab:Toggle({Title="Camera Stretch",Value=false,Callback=function(s)
    if s then
        if camStretchConn then camStretchConn:Disconnect() end
        camStretchConn = RunService.RenderStepped:Connect(function() local c = workspace.CurrentCamera if c then c.CFrame = c.CFrame * CFrame.new(0,0,0,strH,0,0,0,strV,0,0,0,1) end end)
    else if camStretchConn then camStretchConn:Disconnect() camStretchConn = nil end end
end})
MiscTab:Input({Title="Stretch Horizontal",Value="0.80",Numeric=true,Callback=function(v) local n = tonumber(v) if n then strH = n end end})
MiscTab:Input({Title="Stretch Vertical",Value="0.80",Numeric=true,Callback=function(v) local n = tonumber(v) if n then strV = n end end})

MiscTab:Section({Title="Auto Jump / Bhop"})
getgenv().autoJumpType = "Bounce"
getgenv().bhopMode = "Acceleration"
getgenv().bhopAccelValue = -0.5
getgenv().bhopHoldActive = false
getgenv().autoJumpEnabled = false
getgenv().jumpCooldown = 0.7
featureStates.Bhop = false
featureStates.BhopHold = false
local bhopConnection = nil
local bhopLoaded = false
local characterConnection = nil
local frictionTables = {}
local Character = player.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local LastJump = 0

local function findFrictionTables()
    frictionTables = {}
    for _,obj in pairs(getgc(true)) do if type(obj)=="table" and rawget(obj,"Friction") then table.insert(frictionTables,{obj=obj,original=obj.Friction}) end end
end
local function applyBhopFriction()
    local active = getgenv().autoJumpEnabled or getgenv().bhopHoldActive
    if active and getgenv().bhopMode == "Acceleration" then
        if #frictionTables == 0 then findFrictionTables() end
        for _,td in ipairs(frictionTables) do pcall(function() td.obj.Friction = getgenv().bhopAccelValue or -0.5 end) end
    else for _,td in ipairs(frictionTables) do pcall(function() td.obj.Friction = td.original end) end end
end
local function IsOnGround()
    if not Character or not HumanoidRootPart or not Humanoid then return false end
    if Humanoid:GetState() == Enum.HumanoidStateType.Running then return true end
    if Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Freefall then return false end
    if HumanoidRootPart.Velocity.Y > -1 and HumanoidRootPart.Velocity.Y < 1 then return true end
    return false
end
local function updateBhop()
    if not bhopLoaded then return end
    local active = getgenv().autoJumpEnabled or getgenv().bhopHoldActive
    if active then
        if not Character or not Humanoid or not HumanoidRootPart then Character = player.Character if Character then Humanoid = Character:FindFirstChildOfClass("Humanoid") HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") end if not Humanoid or not HumanoidRootPart then return end end
        if Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
        local now = tick()
        if IsOnGround() and (now - LastJump) > getgenv().jumpCooldown then
            if getgenv().autoJumpType == "Realistic" then pcall(function() player.PlayerScripts.Events.temporary_events.JumpReact:Fire() task.wait(0.05) player.PlayerScripts.Events.temporary_events.EndJump:Fire() end)
            else Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            LastJump = now
        end
    end
end
local function loadBhop() if bhopLoaded then return end bhopLoaded = true findFrictionTables() applyBhopFriction() if bhopConnection then bhopConnection:Disconnect() end bhopConnection = RunService.Heartbeat:Connect(updateBhop) end
local function unloadBhop() if not bhopLoaded then return end bhopLoaded = false if bhopConnection then bhopConnection:Disconnect() bhopConnection = nil end getgenv().bhopHoldActive = false applyBhopFriction() end
local function checkBhopState() if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then loadBhop() else unloadBhop() end end

MiscTab:Dropdown({Title="Auto Jump Type",Values={"Bounce","Realistic"},Value="Bounce",Callback=function(v) getgenv().autoJumpType = v end})
MiscTab:Toggle({Title="Bunny Hop",Value=false,Callback=function(s) featureStates.Bhop = s getgenv().autoJumpEnabled = s checkBhopState() end})
MiscTab:Toggle({Title="Bhop Hold (Space)",Value=false,Callback=function(s) featureStates.BhopHold = s if not s then getgenv().bhopHoldActive = false checkBhopState() end end})
MiscTab:Dropdown({Title="Bhop Mode",Values={"Acceleration","No Acceleration"},Value="Acceleration",Callback=function(v) getgenv().bhopMode = v checkBhopState() end})
MiscTab:Input({Title="Bhop Acceleration",Value="-0.5",Numeric=true,Callback=function(v) local n = tonumber(v) if n and string.sub(v,1,1)=="-" then getgenv().bhopAccelValue = n if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then applyBhopFriction() end end end})
MiscTab:Input({Title="Jump Cooldown",Value="0.7",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 then getgenv().jumpCooldown = n end end})

RunService.Heartbeat:Connect(function()
    if not Character or not Character:IsDescendantOf(workspace) then
        Character = player.Character
        if Character then Humanoid = Character:FindFirstChildOfClass("Humanoid") HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        else Humanoid = nil HumanoidRootPart = nil end
    end
end)
if characterConnection then characterConnection:Disconnect() end
characterConnection = player.CharacterAdded:Connect(function(nc) Character = nc task.wait(0.5) Humanoid = nc:WaitForChild("Humanoid") HumanoidRootPart = nc:WaitForChild("HumanoidRootPart") end)
UserInputService.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode == Enum.KeyCode.Space and featureStates.BhopHold then getgenv().bhopHoldActive = true checkBhopState() end end)
UserInputService.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Space then getgenv().bhopHoldActive = false checkBhopState() end end)
task.spawn(function() task.wait(2) if player.Character then Character = player.Character Humanoid = Character:FindFirstChildOfClass("Humanoid") HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") end if featureStates.Bhop then checkBhopState() end end)

MiscTab:Section({Title="Lag Switch"})
local lagSwitchEnabled = false
local lagDelayValue = 0.1
local lagIntensity = 1000000
local lagSwitchMode = "Normal"
local isLagActive = false
MiscTab:Toggle({Title="Lag Switch",Value=false,Callback=function(s) lagSwitchEnabled = s end})
MiscTab:Dropdown({Title="Lag Mode",Values={"Normal","Demon"},Value="Normal",Callback=function(v) lagSwitchMode = v end})
MiscTab:Input({Title="Lag Delay",Value="0.1",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n > 0 and n <= 5 then lagDelayValue = n end end})
MiscTab:Input({Title="Lag Intensity",Value="1000000",Numeric=true,Callback=function(v) local n = tonumber(v) if n and n >= 1000 then lagIntensity = n end end})

MiscTab:Section({Title="Emote Speed"})
local emoteSpeedActive = false
local emoteSpeedValue = 1
local emoteSpeedConn = nil
MiscTab:Toggle({Title="Emote Speed",Value=false,Callback=function(s)
    emoteSpeedActive = s
    if s then
        if emoteSpeedConn then emoteSpeedConn:Disconnect() end
        emoteSpeedConn = RunService.Heartbeat:Connect(function()
            if not emoteSpeedActive then return end
            local ch = player.Character if not ch then return end
            local h = ch:FindFirstChildOfClass("Humanoid") if not h then return end
            for _,t in ipairs(h:GetPlayingAnimationTracks()) do if t.Name ~= "idle" and t.Speed ~= emoteSpeedValue then t:AdjustSpeed(emoteSpeedValue) end end
        end)
    else if emoteSpeedConn then emoteSpeedConn:Disconnect() emoteSpeedConn = nil end end
end})
MiscTab:Input({Title="Emote Speed Value",Value="1",Numeric=true,Callback=function(v) local n = tonumber(v) if n then emoteSpeedValue = n end end})

-- ==================== VISUALS TAB ====================
VisualsTab:Section({Title="Cosmetics Changer"})
local cosmetic1, cosmetic2 = "", ""
local originalCosmetic1, originalCosmetic2 = "", ""
local isSwapped = false

VisualsTab:Input({Title="Current Cosmetics",Value="",Callback=function(v) cosmetic1 = v if not isSwapped then originalCosmetic1 = v end end})
VisualsTab:Input({Title="Select Cosmetics",Value="",Callback=function(v) cosmetic2 = v if not isSwapped then originalCosmetic2 = v end end})
VisualsTab:Button({Title="Apply Cosmetics",Callback=function()
    pcall(function()
        if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then return end
        local RS = game:GetService("ReplicatedStorage")
        local Cosmetics = RS:WaitForChild("Items"):WaitForChild("Cosmetics")
        local function normalize(str) return str:gsub("%s+",""):lower() end
        local function levenshtein(s,t) local m,n=#s,#t local d={} for i=0,m do d[i]={[0]=i} end for j=0,n do d[0][j]=j end for i=1,m do for j=1,n do local c=(s:sub(i,i)==t:sub(j,j)) and 0 or 1 d[i][j]=math.min(d[i-1][j]+1,d[i][j-1]+1,d[i-1][j-1]+c) end end return d[m][n] end
        local function similarity(s,t) local nS,nT=normalize(s),normalize(t) return 1-levenshtein(nS,nT)/math.max(#nS,#nT) end
        local function findSimilar(name) local best,bs=name,0.5 for _,c in ipairs(Cosmetics:GetChildren()) do local sc=similarity(name,c.Name) if sc>bs then bs=sc best=c.Name end end return best end
        cosmetic1 = findSimilar(cosmetic1) cosmetic2 = findSimilar(cosmetic2)
        local a = Cosmetics:FindFirstChild(cosmetic1) local b = Cosmetics:FindFirstChild(cosmetic2)
        if not a or not b then return end
        if not isSwapped then originalCosmetic1 = cosmetic1 originalCosmetic2 = cosmetic2 end
        local tr = Instance.new("Folder",Cosmetics) tr.Name = "__temp_swap"
        local tA = Instance.new("Folder",tr) local tB = Instance.new("Folder",tr)
        for _,c in ipairs(a:GetChildren()) do c.Parent = tA end
        for _,c in ipairs(b:GetChildren()) do c.Parent = tB end
        for _,c in ipairs(tA:GetChildren()) do c.Parent = b end
        for _,c in ipairs(tB:GetChildren()) do c.Parent = a end
        tr:Destroy() isSwapped = true
        vu1:Notify({Title="Cosmetics",Content="Swapped "..cosmetic1.." with "..cosmetic2,Duration=3})
    end)
end})
VisualsTab:Button({Title="Reset Cosmetics",Callback=function()
    if not isSwapped then vu1:Notify({Title="Cosmetics",Content="Nothing to reset",Duration=3}) return end
    pcall(function()
        local Cosmetics = game:GetService("ReplicatedStorage"):WaitForChild("Items"):WaitForChild("Cosmetics")
        local a,b = Cosmetics:FindFirstChild(cosmetic1),Cosmetics:FindFirstChild(cosmetic2)
        if a and b then
            local tr = Instance.new("Folder",Cosmetics)
            local tA,tB = Instance.new("Folder",tr),Instance.new("Folder",tr)
            for _,c in ipairs(a:GetChildren()) do c.Parent = tA end for _,c in ipairs(b:GetChildren()) do c.Parent = tB end
            for _,c in ipairs(tA:GetChildren()) do c.Parent = b end for _,c in ipairs(tB:GetChildren()) do c.Parent = a end
            tr:Destroy() isSwapped = false
            vu1:Notify({Title="Cosmetics",Content="Reset to original",Duration=3})
        end
    end)
end})

VisualsTab:Section({Title="NameTag Changers"})
local function updateNametagList()
    local vals = {"Ignore","None"}
    pcall(function()
        local nf = game:GetService("ReplicatedStorage").Items.Nametags
        if nf then for _,m in ipairs(nf:GetChildren()) do if m:IsA("ModuleScript") then local s,d = pcall(require,m) if s and d and d.AppearanceInfo then table.insert(vals,d.AppearanceInfo.Name) end end end end
    end)
    return vals
end
VisualsTab:Dropdown({Title="Visual Nametag",Values=updateNametagList(),Value="Ignore",Callback=function(v)
    pcall(function()
        local pf = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
        if pf then if v == "None" then pf:SetAttribute("Nametag",nil) elseif v ~= "Ignore" then pf:SetAttribute("Nametag",v:gsub("%s+","")) end end
    end)
end})

VisualsTab:Section({Title="Fake Streaks"})
VisualsTab:Input({Title="Fake Streaks",Value="",Numeric=true,Callback=function(v) local n = tonumber(v) if n then game.Players.LocalPlayer:SetAttribute("Streak",n) end end})

VisualsTab:Section({Title="CarryAnimation Replacer"})
local currentCarryAnim, selectedCarryAnim = "", ""
VisualsTab:Input({Title="Current CarryAnimation",Value="",Callback=function(v) currentCarryAnim = v end})
VisualsTab:Input({Title="Selected CarryAnimation",Value="",Callback=function(v) selectedCarryAnim = v end})
VisualsTab:Button({Title="Apply CarryAnimation Swap",Callback=function()
    pcall(function()
        local ca = game:GetService("ReplicatedStorage"):FindFirstChild("Items") and game:GetService("ReplicatedStorage").Items:FindFirstChild("CarryAnimations")
        if not ca then vu1:Notify({Title="CarryAnim",Content="Folder not found",Duration=3}) return end
        local a,b = ca:FindFirstChild(currentCarryAnim),ca:FindFirstChild(selectedCarryAnim)
        if a and b then
            local tr = Instance.new("Folder",ca) local tA,tB = Instance.new("Folder",tr),Instance.new("Folder",tr)
            for _,c in ipairs(a:GetChildren()) do c.Parent = tA end for _,c in ipairs(b:GetChildren()) do c.Parent = tB end
            for _,c in ipairs(tA:GetChildren()) do c.Parent = b end for _,c in ipairs(tB:GetChildren()) do c.Parent = a end
            tr:Destroy()
            vu1:Notify({Title="CarryAnim",Content="Swapped successfully",Duration=3})
        end
    end)
end})

-- ==================== EVENT TAB ====================
EventTab:Section({Title="Battlepass Modifications"})
EventTab:Toggle({Title="Unlocked Time Pass",Value=false,Callback=function(s)
    if s then
        if not featureStates.UnlockedPassLoop then
            featureStates.UnlockedPassLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local m = Players.LocalPlayer.PlayerGui.Menu
                    if m and m.Views and m.Views.Battlepass and m.Views.Battlepass.ViewPass then
                        local c = m.Views.Battlepass.ViewPass.Center
                        if c and c.ViewPass and c.ViewPass.Unlocked then c.ViewPass.Unlocked.Visible = false end
                    end
                end)
            end)
        end
    else
        if featureStates.UnlockedPassLoop then featureStates.UnlockedPassLoop:Disconnect() featureStates.UnlockedPassLoop = nil
            pcall(function() local m = Players.LocalPlayer.PlayerGui.Menu if m and m.Views and m.Views.Battlepass and m.Views.Battlepass.ViewPass then local c = m.Views.Battlepass.ViewPass.Center if c and c.ViewPass and c.ViewPass.Unlocked then c.ViewPass.Unlocked.Visible = true end end end)
        end
    end
end})
EventTab:Toggle({Title="Open Exchange",Value=false,Callback=function(s)
    if s then
        if not featureStates.ExchangeOpenLoop then
            featureStates.ExchangeOpenLoop = RunService.Heartbeat:Connect(function()
                pcall(function() local m = Players.LocalPlayer.PlayerGui.Menu if m and m.Views and m.Views.Battlepass then if m.Views.Battlepass.Exchange then m.Views.Battlepass.Exchange.Visible = true end if m.Views.Battlepass.ViewPass then m.Views.Battlepass.ViewPass.Visible = false end end end)
            end)
        end
    else
        if featureStates.ExchangeOpenLoop then featureStates.ExchangeOpenLoop:Disconnect() featureStates.ExchangeOpenLoop = nil
            pcall(function() local m = Players.LocalPlayer.PlayerGui.Menu if m and m.Views and m.Views.Battlepass then if m.Views.Battlepass.Exchange then m.Views.Battlepass.Exchange.Visible = false end if m.Views.Battlepass.ViewPass then m.Views.Battlepass.ViewPass.Visible = true end end end)
        end
    end
end})
EventTab:Section({Title="Info"})
EventTab:Section({Title="Pass 1-9: Buy Items 5"})
EventTab:Section({Title="Pass 10-18: Buy Items 5"})
EventTab:Section({Title="Pass 19-25: Buy Items 5"})

-- ==================== INFO TAB ====================
InfoTab:Section({Title="Information"})
InfoTab:Section({Title="IndraHub - Evade Script with WindUI"})
InfoTab:Section({Title="Telegram Support - Join our channel for updates"})
InfoTab:Button({Title="Copy Telegram Link",Callback=function() setclipboard("https://t.me/DraconicHub") vu1:Notify({Title="Telegram",Content="Link copied!",Duration=3}) end})
InfoTab:Dropdown({Title="Theme",Values=themeList,Value="Dark",Callback=function(v) vu1:SetTheme(v) end})

-- ==================== FPS TIMER ====================
local function createSimpleTimer()
    local sg = Instance.new("ScreenGui") sg.Name = "IndraHubFPS" sg.ResetOnSpawn = false sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local container = Instance.new("Frame") container.Size = UDim2.new(0,165,0,48) container.Position = UDim2.new(0,10,0,10) container.BackgroundTransparency = 1 container.Parent = sg
    local mf = Instance.new("Frame") mf.Size = UDim2.new(1,0,1,0) mf.BackgroundColor3 = Color3.fromHex("#1a1a1a") mf.BackgroundTransparency = 0.3 mf.Parent = container
    Instance.new("UICorner",mf).CornerRadius = UDim.new(0,8)
    local sk = Instance.new("UIStroke",mf) sk.Color = Color3.fromHex("#8b5cf6") sk.Thickness = 2
    local tf = Instance.new("Frame") tf.Size = UDim2.new(1,-8,1,-8) tf.Position = UDim2.new(0,4,0,4) tf.BackgroundTransparency = 1 tf.Parent = mf
    local dragging,dragInput,dragStart,startPos = false,nil,nil,nil
    mf.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = i.Position startPos = container.Position
            local cn cn = i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false cn:Disconnect() end end)
        end
    end)
    mf.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i == dragInput or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart container.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    local st = Instance.new("TextLabel") st.Size = UDim2.new(1,-10,0.5,0) st.Position = UDim2.new(0,5,0,0) st.BackgroundTransparency = 1 st.TextColor3 = Color3.fromRGB(255,255,255) st.Font = Enum.Font.GothamBold st.TextSize = 13 st.TextXAlignment = Enum.TextXAlignment.Center st.Text = "FPS: 60 | Ping: 0ms" st.Parent = tf
    local tt = Instance.new("TextLabel") tt.Size = UDim2.new(1,-10,0.5,0) tt.Position = UDim2.new(0,5,0.5,0) tt.BackgroundTransparency = 1 tt.TextColor3 = Color3.fromRGB(255,255,255) tt.Font = Enum.Font.GothamBold tt.TextSize = 13 tt.TextXAlignment = Enum.TextXAlignment.Center tt.Text = "Time: 0h 0m 0s" tt.Parent = tf
    mf.MouseEnter:Connect(function() sk.Color = Color3.fromHex("#a78bfa") end)
    mf.MouseLeave:Connect(function() sk.Color = Color3.fromHex("#8b5cf6") end)
    local startTime = tick() local frameCount = 0 local lastUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1 local ct = tick()
        if ct - lastUpdate >= 0.5 then
            local fps = math.floor(frameCount/(ct-lastUpdate)) frameCount = 0 lastUpdate = ct
            local ping = 50 pcall(function() local ns = game:GetService("Stats"):FindFirstChild("Network") if ns then local ss = ns:FindFirstChild("ServerStatsItem") if ss then ping = math.floor(ss:GetValue()) end end end)
            st.Text = string.format("FPS: %d | Ping: %dms",fps,ping)
        end
        local el = ct - startTime
        tt.Text = string.format("Time: %dh %dm %ds",math.floor(el/3600),math.floor((el%3600)/60),math.floor(el%60))
    end)
end
createSimpleTimer()



vu1:Notify({Title="IndraHub",Content="Script loaded successfully! Click IH button to toggle UI.",Duration=5})
