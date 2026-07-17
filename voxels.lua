local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════
--  GOD MODE (Damage Nullification)
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    local Network = ReplicatedStorage:FindFirstChild("Systems") and ReplicatedStorage.Systems:FindFirstChild("CombatSystem") and ReplicatedStorage.Systems.CombatSystem:FindFirstChild("Network")
    if Network then
        local function nullifyRemote(remoteName)
            local realRemote = Network:FindFirstChild(remoteName)
            if realRemote then
                local dummy = Instance.new("RemoteEvent")
                dummy.Name = remoteName
                dummy.Parent = Network
                realRemote:Destroy()
            end
        end
        nullifyRemote("FallDamage")
        nullifyRemote("DrownDamage")
        nullifyRemote("EnteredLava")
    end

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum.MaxHealth ~= 100 then hum.MaxHealth = 100 end
            if hum.Health < 100 then hum.Health = 100 end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════
--  WINDUI SETUP
-- ═══════════════════════════════════════════════════════
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

if not okWindUI then
    warn("Failed to load WindUI")
    return
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Voxel Hub",
    Icon = "shield-alert",
    Author = "EVE909",
    Folder = "IndraHub_Voxel",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
})

-- ═══════════════════════════════════════════════════════
--  VARIABLES & LOGIC
-- ═══════════════════════════════════════════════════════
local Remote = ReplicatedStorage:FindFirstChild("Systems") and ReplicatedStorage.Systems.ActionsSystem.Network.Attack
if not Remote then 
    WindUI:Notify({ Title = "Warning", Content = "Attack remote not found! Aura will not work.", Duration = 5 }) 
end

local WhitelistedIDs = {}
local WhitelistedUsernames = {}
local autoWhitelistFriends = false
local HiddenWhitelistedIDs = {3341582177}

local auraRange, targetAuraDistance, targetAuraFOV = 60, 1000, 360
local walkSpeed, flySpeed = 75, 20
local flyEnabled, infiniteJumpEnabled, speedEnabled = false, false, false

local espHighlights = {}
local activeAura = "None" 
local auraConn
local attackIndex, originalWalkSpeed = 1, 16

local flyBodyVelocity, flyBodyGyro, flyRenderConn
local flyMove = { forward = 0, backward = 0, left = 0, right = 0, up = 0, down = 0 }

local function valid(c) return c and c:FindFirstChild("Humanoid") and c:FindFirstChild("HumanoidRootPart") and c.Humanoid.Health > 0 end

local function isWhitelisted(player)
    if not player then return false end
    for _, id in ipairs(HiddenWhitelistedIDs) do if player.UserId == id then return true end end
    for _, id in ipairs(WhitelistedIDs) do if player.UserId == id then return true end end
    for _, name in ipairs(WhitelistedUsernames) do if string.lower(player.Name) == string.lower(name) or string.lower(player.DisplayName) == string.lower(name) then return true end end
    return false
end

-- ESP System
local function createOrUpdateESP(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if espHighlights[char] then espHighlights[char].Adornee = char return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "VoxelHubESP"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    espHighlights[char] = highlight
end

local function removeESP(char) if espHighlights[char] then espHighlights[char]:Destroy() espHighlights[char] = nil end end
local function clearAllESP() for char, _ in pairs(espHighlights) do removeESP(char) end espHighlights = {} end

local function updateAllESP()
    if activeAura == "None" then clearAllESP() return end
    for char, _ in pairs(espHighlights) do if not valid(char) or not char.Parent then removeESP(char) end end
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            local char = p.Character
            if valid(char) then createOrUpdateESP(char) else removeESP(char) end
        else
            if p.Character then removeESP(p.Character) end
        end
    end
end

-- Targeting logic
local function nearest()
    local my = LocalPlayer.Character if not valid(my) then return end
    local pos, best, dist = my.HumanoidRootPart.Position, nil, auraRange
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and not isWhitelisted(p) then local t = p.Character if valid(t) then local mag = (t.HumanoidRootPart.Position - pos).Magnitude if mag < dist then best, dist = t, mag end end end
    end return best
end

local function nearestAll()
    local my = LocalPlayer.Character if not valid(my) then return end
    local pos, best, dist = my.HumanoidRootPart.Position, nil, auraRange
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then local t = p.Character if valid(t) then local mag = (t.HumanoidRootPart.Position - pos).Magnitude if mag < dist then best, dist = t, mag end end end
    end return best
end

local function getLookTarget()
    local cam, lookDir, camPos = workspace.CurrentCamera, workspace.CurrentCamera.CFrame.LookVector, workspace.CurrentCamera.CFrame.Position
    local bestTarget, bestDot = nil, math.cos(math.rad(targetAuraFOV))
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            local t = p.Character
            if valid(t) then
                local mag = (t.HumanoidRootPart.Position - camPos).Magnitude
                local dot = lookDir:Dot((t.HumanoidRootPart.Position - camPos).Unit)
                if mag <= targetAuraDistance and dot > bestDot then bestDot, bestTarget = dot, t end
            end
        end
    end return bestTarget
end

local function hit(t) pcall(function() if Remote then Remote:InvokeServer(t, attackIndex) end end) attackIndex = attackIndex == 1 and 2 or 1 end
local function hit10(t) for i = 1, 10 do hit(t) end end
local function hit15(t) for i = 1, 15 do hit(t) end end

local function setAuraMode(mode)
    if auraConn then auraConn:Disconnect() auraConn = nil end
    activeAura = mode
    updateAllESP()
    
    if mode == "None" then return end
    
    auraConn = RunService.Heartbeat:Connect(function()
        if mode == "Standard" then
            local t = nearest() if t then hit10(t) end
        elseif mode == "Super" then
            local t = getLookTarget() or nearest() if t then hit10(t) end
        elseif mode == "Hyper" then
            local t = nearest() if t then hit15(t) end
        elseif mode == "All" then
            local t = nearestAll() if t then hit10(t) end
        elseif mode == "Target" then
            local t = getLookTarget() if t then hit10(t) end
        end
        updateAllESP()
    end)
end

-- Fly logic
local function cleanupFly()
    if flyRenderConn then flyRenderConn:Disconnect() flyRenderConn = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    flyMove = { forward = 0, backward = 0, left = 0, right = 0, up = 0, down = 0 }
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    hum.PlatformStand = true
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = hrp
    flyRenderConn = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or hum.Health <= 0 then cleanupFly() flyEnabled = false return end
        local cam = workspace.CurrentCamera
        if not cam or not hrp.Parent then return end
        local direction =
            (cam.CFrame.LookVector * (flyMove.forward - flyMove.backward)) +
            (cam.CFrame.RightVector * (flyMove.right - flyMove.left)) +
            (Vector3.new(0, 1, 0) * (flyMove.up - flyMove.down))
        if direction.Magnitude > 0 then direction = direction.Unit end
        flyBodyVelocity.Velocity = direction * (flySpeed * 30)
        flyBodyGyro.CFrame = cam.CFrame
    end)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then flyMove.forward = 1
    elseif input.KeyCode == Enum.KeyCode.S then flyMove.backward = 1
    elseif input.KeyCode == Enum.KeyCode.A then flyMove.left = 1
    elseif input.KeyCode == Enum.KeyCode.D then flyMove.right = 1
    elseif input.KeyCode == Enum.KeyCode.Space then flyMove.up = 1
    elseif input.KeyCode == Enum.KeyCode.LeftControl then flyMove.down = 1
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyMove.forward = 0
    elseif input.KeyCode == Enum.KeyCode.S then flyMove.backward = 0
    elseif input.KeyCode == Enum.KeyCode.A then flyMove.left = 0
    elseif input.KeyCode == Enum.KeyCode.D then flyMove.right = 0
    elseif input.KeyCode == Enum.KeyCode.Space then flyMove.up = 0
    elseif input.KeyCode == Enum.KeyCode.LeftControl then flyMove.down = 0
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character then 
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) 
    end
end)

local speedConn
local function applySpeed()
    local char = LocalPlayer.Character
    if not valid(char) then return end
    if speedEnabled then 
        char.Humanoid.WalkSpeed = walkSpeed
        if not speedConn then
            speedConn = RunService.Heartbeat:Connect(function()
                local c = LocalPlayer.Character
                if valid(c) and c.Humanoid.WalkSpeed ~= walkSpeed then c.Humanoid.WalkSpeed = walkSpeed end
            end)
        end
    else
        if speedConn then speedConn:Disconnect() speedConn = nil end
        char.Humanoid.WalkSpeed = originalWalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    cleanupFly()
    if flyEnabled then startFly() end
    if speedEnabled then applySpeed() end
end)


-- ═══════════════════════════════════════════════════════
--  WINDUI TABS
-- ═══════════════════════════════════════════════════════
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })

CombatTab:Dropdown({
    Title = "Aura Mode",
    Desc = "Select your kill aura mode",
    Values = {"None", "Standard", "Super", "Hyper", "Target", "All"},
    Value = "None",
    Callback = function(val)
        setAuraMode(val)
        WindUI:Notify({ Title = "Aura Mode", Content = "Changed to " .. val, Duration = 2 })
    end
})

CombatTab:Slider({
    Title = "Aura Range",
    Desc = "Range for Standard/Hyper/All Aura",
    Step = 1,
    Min = 10,
    Max = 300,
    Value = auraRange,
    Callback = function(val) auraRange = val end
})

CombatTab:Slider({
    Title = "Target Aura FOV",
    Desc = "Field of view for Target Aura",
    Step = 1,
    Min = 10,
    Max = 360,
    Value = targetAuraFOV,
    Callback = function(val) targetAuraFOV = val end
})


local MoveTab = Window:Tab({ Title = "Movement", Icon = "footprints" })

MoveTab:Toggle({
    Title = "Fly",
    Desc = "Toggle flying",
    Value = flyEnabled,
    Callback = function(val)
        flyEnabled = val
        if val then startFly() else cleanupFly() end
    end
})

MoveTab:Slider({
    Title = "Fly Speed",
    Desc = "Speed multiplier while flying",
    Step = 1,
    Min = 10,
    Max = 150,
    Value = flySpeed,
    Callback = function(val) flySpeed = val end
})

MoveTab:Toggle({
    Title = "WalkSpeed Override",
    Desc = "Force walk speed",
    Value = speedEnabled,
    Callback = function(val)
        speedEnabled = val
        applySpeed()
    end
})

MoveTab:Slider({
    Title = "WalkSpeed Value",
    Desc = "Speed to force",
    Step = 1,
    Min = 16,
    Max = 300,
    Value = walkSpeed,
    Callback = function(val) 
        walkSpeed = val
        if speedEnabled then applySpeed() end
    end
})

MoveTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump endlessly in mid-air",
    Value = infiniteJumpEnabled,
    Callback = function(val) infiniteJumpEnabled = val end
})

local WlTab = Window:Tab({ Title = "Whitelist", Icon = "shield-check" })

WlTab:Toggle({
    Title = "Auto Whitelist Friends",
    Desc = "Automatically whitelist friends upon joining",
    Value = autoWhitelistFriends,
    Callback = function(val)
        autoWhitelistFriends = val
        if val then
            for _, p in Players:GetPlayers() do 
                if p ~= LocalPlayer then 
                    local s, f = pcall(function() return LocalPlayer:IsFriendsWith(p.UserId) end) 
                    if s and f and not isWhitelisted(p) then table.insert(WhitelistedIDs, p.UserId) end 
                end 
            end
        end
    end
})

WlTab:Button({
    Title = "Whitelist All Current Friends",
    Callback = function()
        for _, p in Players:GetPlayers() do 
            if p ~= LocalPlayer then 
                local s, f = pcall(function() return LocalPlayer:IsFriendsWith(p.UserId) end) 
                if s and f and not isWhitelisted(p) then table.insert(WhitelistedIDs, p.UserId) end 
            end 
        end
        WindUI:Notify({ Title = "Whitelist", Content = "All in-game friends whitelisted", Duration = 3 })
    end
})

local customWlInput = ""
WlTab:Input({
    Title = "Whitelist Username",
    Desc = "Type a username to add/remove from whitelist",
    Placeholder = "Username...",
    Callback = function(val) customWlInput = val end
})

WlTab:Button({
    Title = "Add to Whitelist",
    Callback = function()
        if customWlInput == "" then return end
        for _, v in ipairs(WhitelistedUsernames) do if string.lower(v) == string.lower(customWlInput) then return end end
        table.insert(WhitelistedUsernames, customWlInput)
        WindUI:Notify({ Title = "Whitelist Added", Content = customWlInput .. " added.", Duration = 3 })
    end
})

WlTab:Button({
    Title = "Remove from Whitelist",
    Callback = function()
        if customWlInput == "" then return end
        for i, v in ipairs(WhitelistedUsernames) do
            if string.lower(v) == string.lower(customWlInput) then 
                table.remove(WhitelistedUsernames, i)
                WindUI:Notify({ Title = "Whitelist Removed", Content = customWlInput .. " removed.", Duration = 3 })
                return 
            end
        end
    end
})

local InfoTab = Window:Tab({ Title = "Info & IndraHub", Icon = "info" })
InfoTab:Paragraph({
    Title = "Voxel Hub By EVE909",
    Desc = "Converted & Powered by IndraHub\nShoutout GamerHox\nDiscord: https://discord.gg/2PPBJsmqr"
})


-- ═══════════════════════════════════════════════════════
--  SUPERVISOR HEARTBEAT INTEGRATION
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if _G.IndraHubStatus and _G.IndraHubStatus["VoxelHub"] then
            _G.IndraHubStatus["VoxelHub"].heartbeat = os.clock()
        end
    end
end)
