--!strict
local env = getgenv and getgenv() or _G

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

setGlobal("IndraHubPrisonLifeRunning", true)
setGlobal("IndraHubPrisonLifeError", nil)
setGlobal("IndraHubPrisonLifeLastHeartbeat", os.clock())

task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubPrisonLifeRunning") then break end
        setGlobal("IndraHubPrisonLifeLastHeartbeat", os.clock())
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================= STATE =================
local State = {
    AimbotEnabled = false,
    LockTeammates = false,
    DisableWallLock = false,
    ShowFOV = false,
    AimbotFOV = 50,
    AimbotTargetPart = "Head"
}

-- ================= FOV CIRCLE =================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ================= WINDUI INIT =================
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub - Prison Life",
    Icon = "rbxassetid://10618928818", 
    Author = "IndraHub Team",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

-- ================= TABS =================
local CombatTab = Window:Tab({ Title = "Combat", Icon = "rbxassetid://10709768652" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "rbxassetid://10709768652" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "rbxassetid://10709768652" })
local MoreTab = Window:Tab({ Title = "More", Icon = "rbxassetid://10709768652" })
local InfoTab = Window:Tab({ Title = "Info", Icon = "rbxassetid://10709768652" })

-- ================= COMBAT =================
CombatTab:Toggle({
    Title = "Aimbot",
    Desc = "Enables aimbot",
    Value = State.AimbotEnabled,
    Callback = function(v) State.AimbotEnabled = v end
})

CombatTab:Toggle({
    Title = "Target Teammates",
    Desc = "Target players on your team",
    Value = State.LockTeammates,
    Callback = function(v) State.LockTeammates = v end
})

CombatTab:Toggle({
    Title = "Wall Check",
    Desc = "Disable to aim through walls",
    Value = not State.DisableWallLock,
    Callback = function(v) State.DisableWallLock = not v end
})

CombatTab:Toggle({
    Title = "Show FOV",
    Desc = "Shows aimbot FOV circle",
    Value = State.ShowFOV,
    Callback = function(v) 
        State.ShowFOV = v
        FOVCircle.Visible = v 
    end
})

CombatTab:Slider({
    Title = "Aimbot FOV",
    Desc = "Adjust FOV radius",
    Step = 1,
    Min = 10,
    Max = 500,
    Default = State.AimbotFOV,
    Callback = function(v) State.AimbotFOV = v end
})

CombatTab:Dropdown({
    Title = "Target Part",
    Desc = "Part of the body to target",
    Values = {"Head", "Torso"},
    Value = State.AimbotTargetPart,
    Callback = function(v) State.AimbotTargetPart = v end
})

local TargetTeam = "All"
CombatTab:Dropdown({
    Title = "Choose Team",
    Desc = "Team to lock onto",
    Values = {"All", "Guards", "Inmates", "Criminals"},
    Value = TargetTeam,
    Callback = function(v) TargetTeam = v end
})

-- ================= COMBAT LOGIC =================
local function IsVisible(part)
    if State.DisableWallLock then return true end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestTarget()
    local bestPart = nil
    local shortestDistance = State.AimbotFOV

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
		
        local teamName = player.Team and player.Team.Name or "Criminals"
        
        if TargetTeam ~= "All" and teamName ~= TargetTeam then
            continue
        end

        if not State.LockTeammates and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            continue
        end

        local targetPart = character:FindFirstChild(State.AimbotTargetPart)
        if not targetPart then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        if not IsVisible(targetPart) then continue end

        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if magnitude < shortestDistance then
            shortestDistance = magnitude
            bestPart = targetPart
        end
    end

    return bestPart
end

RunService.Heartbeat:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        FOVCircle.Radius = State.AimbotFOV
        FOVCircle.Visible = State.ShowFOV
    end

    if not State.AimbotEnabled then return end

    local target = GetClosestTarget()
    if target then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
    end
end)

-- ================= ESP =================
local ESPSettings = {BoxESP=false, OutlineESP=false, ShowName=false, ShowDistance=false, ESPTeammates=false}
local NO_TEAM_COLOR = Color3.fromRGB(0, 255, 0)
local ESPObjects = {}

ESPTab:Toggle({ Title = "Box ESP", Value = ESPSettings.BoxESP, Callback = function(v) ESPSettings.BoxESP = v end })
ESPTab:Toggle({ Title = "Outline ESP", Value = ESPSettings.OutlineESP, Callback = function(v) ESPSettings.OutlineESP = v end })
ESPTab:Toggle({ Title = "Show Name", Value = ESPSettings.ShowName, Callback = function(v) ESPSettings.ShowName = v end })
ESPTab:Toggle({ Title = "Show Distance", Value = ESPSettings.ShowDistance, Callback = function(v) ESPSettings.ShowDistance = v end })
ESPTab:Toggle({ Title = "ESP Teammates", Value = ESPSettings.ESPTeammates, Callback = function(v) ESPSettings.ESPTeammates = v end })

local function shouldESP(p)
    if p == LocalPlayer then return false end
    if not ESPSettings.ESPTeammates and LocalPlayer.Team and p.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function getColor(p)
    return (p.Team and p.Team.TeamColor.Color) or NO_TEAM_COLOR
end

local function setupESP(p)
    if ESPObjects[p] then return end
    local char = p.Character or p.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local box = Instance.new("SelectionBox")
    box.Adornee = hrp
    box.LineThickness = 0.05
    box.SurfaceTransparency = 1
    box.Color3 = getColor(p)
    box.Visible = false
    box.Parent = Workspace

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineColor = getColor(p)
    hl.Enabled = false
    hl.Parent = Workspace

    local bb = Instance.new("BillboardGui")
    bb.Adornee = hrp
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Enabled = false
    bb.Parent = Workspace

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.TextStrokeTransparency = 0
    txt.TextSize = 13
    txt.TextColor3 = getColor(p)

    ESPObjects[p] = {Box = box, HL = hl, BB = bb, TXT = txt}

    p.CharacterAdded:Connect(function()
        if ESPObjects[p] then
            ESPObjects[p].Box:Destroy()
            ESPObjects[p].HL:Destroy()
            ESPObjects[p].BB:Destroy()
            ESPObjects[p] = nil
            setupESP(p)
        end
    end)
end

for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then setupESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then setupESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for _,v in pairs(ESPObjects[p]) do v:Destroy() end
        ESPObjects[p] = nil
    end
end)

local lastUpdate = 0
local UPDATE_RATE = 1/30
RunService.Heartbeat:Connect(function(dt)
    lastUpdate += dt
    if lastUpdate < UPDATE_RATE then return end
    lastUpdate = 0

    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHRP = localChar.HumanoidRootPart

    for p, data in pairs(ESPObjects) do
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and shouldESP(p) then
            local hrp = char.HumanoidRootPart
            local col = getColor(p)

            data.Box.Adornee = hrp
            data.Box.Color3 = col
            data.Box.Visible = ESPSettings.BoxESP

            data.HL.Adornee = char
            data.HL.OutlineColor = col
            data.HL.Enabled = ESPSettings.OutlineESP

            data.BB.Adornee = hrp

            local text = ""
            if ESPSettings.ShowName then text ..= p.Name .. " " end
            if ESPSettings.ShowDistance then
                local dist = math.floor((hrp.Position - localHRP.Position).Magnitude)
                text ..= dist .. "m"
            end

            data.TXT.Text = text
            data.TXT.TextColor3 = col
            data.BB.Enabled = ESPSettings.ShowName or ESPSettings.ShowDistance
        else
            data.Box.Visible = false
            data.HL.Enabled = false
            data.BB.Enabled = false
        end
    end
end)

-- ================= TELEPORT =================
local locations = {
    {"Locker Room", Vector3.new(829.50,99.98,2242.46)},
    {"Cafeteria Outside", Vector3.new(918.71,99.99,2311.34)},
    {"Cafeteria Inside", Vector3.new(913.57,99.99,2226.93)},
    {"Sewer", Vector3.new(915.59,78.70,2154.49)},
    {"Rooftop", Vector3.new(819.45,118.99,2304.56)},
    {"Prison", Vector3.new(916.41,102.50,2460.09)},
    {"Yard", Vector3.new(778.49,98.00,2461.92)},
    {"Tower (Right)", Vector3.new(822.96,123.84,2588.11)},
    {"Tower Left", Vector3.new(823.60,125.84,2073.68)},
    {"Inside Gate", Vector3.new(621.38,98.04,2278.76)},
    {"Outside Gate", Vector3.new(457.70,98.04,2216.17)},
    {"Waiting Area", Vector3.new(693.24,100.00,2303.64)},
    {"Container", Vector3.new(251.92,72.52,2368.09)},
    {"Criminal Base", Vector3.new(-932.96,94.13,2052.68)}
}

for i, loc in ipairs(locations) do
    TeleportTab:Button({
        Title = loc[1],
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(loc[2])
            end
        end
    })
end

-- ================= MORE =================
MoreTab:Button({
    Title = "Fly Gui",
    Desc = "Press Once",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))()
    end
})

MoreTab:Button({
    Title = "Anti Taze",
    Desc = "Press Once",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ynHUaxuH", true))()
    end
})

MoreTab:Button({
    Title = "Delete Doors",
    Desc = "Unreversable",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Kku9MNM1", true))()
    end
})

local noJumpActive = false
MoreTab:Toggle({
    Title = "No Jump Cooldown",
    Desc = "Reset character to turn off",
    Value = false,
    Callback = function(v) noJumpActive = v end
})

task.spawn(function()
    while true do
        if noJumpActive then
            local char = LocalPlayer.Character
            if char then
                local antiJump = char:FindFirstChild("AntiJump")
                if antiJump then
                    antiJump:Destroy()
                end
            end
        end
        task.wait(0.1)
    end
end)

MoreTab:Section({ Title = "Get Guns" })
local GunLocations = {
    {"Get FAL (BUGGY)", CFrame.new(-915.80, 91.26, 2047.55)},
    {"Get AK (BUGGY)", CFrame.new(-931.90, 94.37, 2039.12)},
    {"Get Remington (BUGGY)", CFrame.new(-938.99, 91.28, 2039.26)},
    {"Get MP5 (BUGGY)", CFrame.new(813.70, 97.85, 2229.40)},
    {"Get M4A1 (BUGGY)", CFrame.new(847.50, 97.85, 2229.40)},
    {"Get M700 (BUGGY)", CFrame.new(835.80, 97.85, 2229.40)}
}

for _, data in ipairs(GunLocations) do
    MoreTab:Button({
        Title = data[1],
        Callback = function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local old = root.CFrame
            root.CFrame = data[2]
            task.wait(2)
            root.CFrame = old
        end
    })
end

-- ================= INFO =================
InfoTab:Paragraph({
    Title = "About IndraHub",
    Desc = "IndraHub Prison Life Script\nOriginally created by SARpastes.\nRebranded and enhanced with WindUI by the IndraHub team."
})
