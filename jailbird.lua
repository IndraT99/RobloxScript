local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local env = getgenv and getgenv() or _G
env.IndraHubJailbirdLastHeartbeat = os.clock()


-- ==========================================
-- INDRAHUB WINDUI SETUP
-- ==========================================
local WindUI = loadstring(game:HttpGet('https://tree-hub.vercel.app/api/UI/WindUI'))()
local Window = WindUI:CreateWindow({
    Title = 'IndraHub | Jailbird',
    Theme = 'Dark',
    Transparent = true,
    Resizable = true,
})

local Tabs = {
    Combat = Window:Tab({ Title = 'Combat', Icon = 'swords' }),
    Visuals = Window:Tab({ Title = 'Visuals', Icon = 'eye' }),
    Misc = Window:Tab({ Title = 'Misc', Icon = 'layers' }),
    Info = Window:Tab({ Title = 'Info', Icon = 'info' })
}

-- ==========================================
-- CONFIGURATION
-- ==========================================
local Config = {
    -- Silent Aim
    SilentAimEnabled = false,
    TeamCheck = true,
    VisibleCheck = false,
    AimPart = 'Closest',
    FOVRadius = 45,
    DrawFOV = false,
    
    -- Visuals
    ESPEnabled = false,
    SkeletonEnabled = false,
    BoxEnabled = false,
    NameEnabled = false,
    HealthBarEnabled = false,
    TeamColors = true,
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TeamColor = Color3.fromRGB(0, 255, 0),
    
    -- Misc
    NoClip = false,
    NoClipSpeed = 0.5
}

-- ==========================================
-- SILENT AIM LOGIC
-- ==========================================
local Circle = Drawing.new('Circle')
Circle.Thickness = 1
Circle.Filled = false
Circle.Color = Color3.fromRGB(255, 255, 255)

local Line = Drawing.new('Line')
Line.Thickness = 1
Line.Color = Color3.fromRGB(255, 255, 255)

local BodyPartNames = {
    'Head', 'Torso', 'UpperTorso', 'LowerTorso', 'HumanoidRootPart',
    'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg',
    'LeftUpperArm', 'RightUpperArm', 'LeftUpperLeg', 'RightUpperLeg',
    'LeftLowerArm', 'RightLowerArm', 'LeftLowerLeg', 'RightLowerLeg'
}

local function GetClosestTarget()
    if not Config.SilentAimEnabled then return nil end
    local BestTarget = nil
    local BestScreenDist = math.huge
    local CenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local partsToCheck = (Config.AimPart == 'Head') and {'Head'} or BodyPartNames

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and (player.Team == LocalPlayer.Team or player.Team == 'Spectator') then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid or humanoid.Health <= 0 then continue end

        for _, partName in ipairs(partsToCheck) do
            local part = character:FindFirstChild(partName)
            if part and part:IsA('BasePart') then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - CenterPosition).Magnitude
                    if dist <= Config.FOVRadius then
                        if Config.VisibleCheck then
                            local obscured = #Camera:GetPartsObscuringTarget({Camera.CFrame.Position, part.Position}, {LocalPlayer.Character, character})
                            if obscured > 0 then continue end
                        end
                        if dist < BestScreenDist then
                            BestScreenDist = dist
                            BestTarget = part
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

-- Hook Silent Aim
local OldBulletRayCast = nil
local OldKnifeRayCast = nil

local function Redirect(origin, direction, distance, ignoreList, isKnife)
    local target = GetClosestTarget()
    if target then
        local newDirection = (target.Position - origin).Unit
        if isKnife and OldKnifeRayCast then
            return OldKnifeRayCast(origin, newDirection, distance, ignoreList)
        elseif OldBulletRayCast then
            return OldBulletRayCast(origin, newDirection, distance, ignoreList)
        end
    end
    if isKnife and OldKnifeRayCast then
        return OldKnifeRayCast(origin, direction, distance, ignoreList)
    elseif OldBulletRayCast then
        return OldBulletRayCast(origin, direction, distance, ignoreList)
    end
end

task.spawn(function()
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == 'table' and rawget(v, 'BulletRayCast') then
            if not OldBulletRayCast then
                OldBulletRayCast = v.BulletRayCast
                OldKnifeRayCast = v.KnifeRayCast
                v.BulletRayCast = function(a, b, c, d) return Redirect(a, b, c, d, false) end
                if v.KnifeRayCast then
                    v.KnifeRayCast = function(a, b, c, d) return Redirect(a, b, c, d, true) end
                end
            end
        end
    end
end)

-- ==========================================
-- ESP LOGIC
-- ==========================================
local ESPObjects = {}
local bonesR15 = {
    {'Head', 'UpperTorso'}, {'UpperTorso', 'LowerTorso'}, {'UpperTorso', 'LeftUpperArm'},
    {'LeftUpperArm', 'LeftLowerArm'}, {'LeftLowerArm', 'LeftHand'}, {'UpperTorso', 'RightUpperArm'},
    {'RightUpperArm', 'RightLowerArm'}, {'RightLowerArm', 'RightHand'}, {'LowerTorso', 'LeftUpperLeg'},
    {'LeftUpperLeg', 'LeftLowerLeg'}, {'LeftLowerLeg', 'LeftFoot'}, {'LowerTorso', 'RightUpperLeg'},
    {'RightUpperLeg', 'RightLowerLeg'}, {'RightLowerLeg', 'RightFoot'}
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local objects = {
        Box = Drawing.new('Square'),
        HealthBar = Drawing.new('Square'),
        Name = Drawing.new('Text'),
        SkeletonLines = {},
    }
    objects.Box.Thickness = 1.5
    objects.Box.Filled = false
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Filled = true
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true
    for i = 1, 14 do
        local line = Drawing.new('Line')
        line.Thickness = 1.5
        table.insert(objects.SkeletonLines, line)
    end
    ESPObjects[player] = objects
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        ESPObjects[player].HealthBar:Remove()
        ESPObjects[player].Name:Remove()
        for _, line in ipairs(ESPObjects[player].SkeletonLines) do line:Remove() end
        ESPObjects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==========================================
-- NOCLIP LOGIC
-- ==========================================
local NoClipConnection = nil
local function SetNoClip(enabled)
    if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
    if enabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA('BasePart') then part.CanCollide = false end
                end
            end
        end)
    else
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA('BasePart') then part.CanCollide = true end
            end
        end
    end
end

local function UpdateNoClip()
    if not Config.NoClip or not LocalPlayer.Character then return end
    local rootPart = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then return end
    
    local moveDir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
    
    if moveDir.Magnitude > 0 then
        rootPart.Velocity = moveDir.Unit * 50 * Config.NoClipSpeed
        rootPart.CFrame = rootPart.CFrame + (moveDir.Unit * Config.NoClipSpeed)
    end
end

-- ==========================================
-- HEARTBEAT (MAIN LOOP)
-- ==========================================
RunService.Heartbeat:Connect(function()
    env.IndraHubJailbirdLastHeartbeat = os.clock()
    
    -- Update FOV
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.Position = Center
    Circle.Radius = Config.FOVRadius
    Circle.Visible = Config.DrawFOV
    
    Line.From = Center
    local Target = GetClosestTarget()
    if Target and Config.SilentAimEnabled and Config.DrawFOV then
        local pos, onScreen = Camera:WorldToViewportPoint(Target.Position)
        if onScreen then
            Line.To = Vector2.new(pos.X, pos.Y)
            Line.Visible = true
        else
            Line.Visible = false
        end
    else
        Line.Visible = false
    end
    
    -- Update ESP
    for player, objs in pairs(ESPObjects) do
        local hide = true
        if Config.ESPEnabled and player.Character then
            local hum = player.Character:FindFirstChildOfClass('Humanoid')
            local root = player.Character:FindFirstChild('HumanoidRootPart')
            local head = player.Character:FindFirstChild('Head')
            
            local isTeammate = (Config.TeamCheck and player.Team == LocalPlayer.Team)
            local color = (Config.TeamColors and isTeammate) and Config.TeamColor or Config.EnemyColor
            
            if hum and root and head and hum.Health > 0 and not isTeammate then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    hide = false
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.5
                    local boxPos = Vector2.new(rootPos.X - width/2, headPos.Y)
                    
                    -- Box
                    objs.Box.Visible = Config.BoxEnabled
                    objs.Box.Size = Vector2.new(width, height)
                    objs.Box.Position = boxPos
                    objs.Box.Color = color
                    
                    -- HealthBar
                    objs.HealthBar.Visible = Config.HealthBarEnabled
                    local hp = hum.Health / hum.MaxHealth
                    objs.HealthBar.Size = Vector2.new(3, height * hp)
                    objs.HealthBar.Position = Vector2.new(boxPos.X - 5, boxPos.Y + (height - height * hp))
                    objs.HealthBar.Color = Color3.fromRGB(255 - (255 * hp), 255 * hp, 0)
                    
                    -- Name
                    objs.Name.Visible = Config.NameEnabled
                    objs.Name.Text = player.Name
                    objs.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 15)
                    objs.Name.Color = color
                    
                    -- Skeleton
                    if Config.SkeletonEnabled then
                        for i, conn in ipairs(bonesR15) do
                            local p1 = player.Character:FindFirstChild(conn[1])
                            local p2 = player.Character:FindFirstChild(conn[2])
                            if p1 and p2 then
                                local pos1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                local pos2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    objs.SkeletonLines[i].Visible = true
                                    objs.SkeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                                    objs.SkeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                                    objs.SkeletonLines[i].Color = color
                                else
                                    objs.SkeletonLines[i].Visible = false
                                end
                            else
                                objs.SkeletonLines[i].Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(objs.SkeletonLines) do line.Visible = false end
                    end
                end
            end
        end
        if hide then
            objs.Box.Visible = false
            objs.HealthBar.Visible = false
            objs.Name.Visible = false
            for _, line in ipairs(objs.SkeletonLines) do line.Visible = false end
        end
    end
end)

RunService.RenderStepped:Connect(UpdateNoClip)

-- ==========================================
-- POPULATE WINDUI
-- ==========================================
local secSilentAim = Tabs.Combat:Section({ Title = 'Silent Aim' })
secSilentAim:Toggle({ Title = 'Enable Silent Aim', Default = false, Callback = function(v) Config.SilentAimEnabled = v end })
secSilentAim:Toggle({ Title = 'Team Check', Default = true, Callback = function(v) Config.TeamCheck = v end })
secSilentAim:Toggle({ Title = 'Visible Check', Default = false, Callback = function(v) Config.VisibleCheck = v end })
secSilentAim:Dropdown({ Title = 'Aim Part', Values = {'Closest', 'Head'}, Value = 'Closest', Callback = function(v) Config.AimPart = v end })
secSilentAim:Toggle({ Title = 'Draw FOV', Default = false, Callback = function(v) Config.DrawFOV = v end })
secSilentAim:Slider({ Title = 'FOV Radius', Min = 10, Max = 300, Default = 45, Callback = function(v) Config.FOVRadius = v end })

local secVisuals = Tabs.Visuals:Section({ Title = 'ESP Visuals' })
secVisuals:Toggle({ Title = 'Enable ESP', Default = false, Callback = function(v) Config.ESPEnabled = v end })
secVisuals:Toggle({ Title = 'Box ESP', Default = false, Callback = function(v) Config.BoxEnabled = v end })
secVisuals:Toggle({ Title = 'Skeleton ESP', Default = false, Callback = function(v) Config.SkeletonEnabled = v end })
secVisuals:Toggle({ Title = 'Name ESP', Default = false, Callback = function(v) Config.NameEnabled = v end })
secVisuals:Toggle({ Title = 'Health Bar ESP', Default = false, Callback = function(v) Config.HealthBarEnabled = v end })
secVisuals:Toggle({ Title = 'Use Team Colors', Default = true, Callback = function(v) Config.TeamColors = v end })

local secMisc = Tabs.Misc:Section({ Title = 'Character' })
secMisc:Toggle({ Title = 'Enable NoClip (Fly)', Default = false, Callback = function(v) Config.NoClip = v SetNoClip(v) end })
secMisc:Slider({ Title = 'NoClip Speed', Min = 0.1, Max = 2.0, Default = 0.5, Callback = function(v) Config.NoClipSpeed = v end })

local secInfo = Tabs.Info:Section({ Title = 'About' })
secInfo:Button({
    Title = 'Join Discord (discord.gg/2PPBJsmqr)',
    Callback = function()
        pcall(function() if setclipboard then setclipboard('https://discord.gg/2PPBJsmqr') end end)
        WindUI:Notify({ Title = 'Success', Content = 'Discord link copied to clipboard!', Duration = 3 })
    end
})
secInfo:Button({
    Title = 'Unload Script',
    Callback = function()
        Window:Destroy()
        Circle:Remove()
        Line:Remove()
        for _, objs in pairs(ESPObjects) do RemoveESP(_) end
        if NoClipConnection then NoClipConnection:Disconnect() end
    end
})
