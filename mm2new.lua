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

if getGlobal("IndraHubMM2Running") then return end
setGlobal("IndraHubMM2Running", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubMM2Running") then break end
        setGlobal("IndraHubMM2LastHeartbeat", os.time())
    end
end)

local WindUI
local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then warn("WindUI failed to load: "..tostring(err)) return end

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n9owns/Files/refs/heads/main/antiafk", true))()
    end)
end)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera
local LocalPlayer       = Players.LocalPlayer
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local Stats             = game:GetService("Stats")

local Colors = {
    Dark        = Color3.fromHex("#0a0a0f"),
    Surface     = Color3.fromHex("#151520"),
    Accent      = Color3.fromHex("#ffffff"),
    AccentDark  = Color3.fromHex("#888888"),
    AccentLight = Color3.fromHex("#cccccc"),
    Text        = Color3.fromHex("#ffffff"),
    TextDim     = Color3.fromHex("#b0b0b0"),
    Murder      = Color3.fromHex("#ffffff"),
    Sheriff     = Color3.fromHex("#aaaaaa"),
    Innocent    = Color3.fromHex("#666666"),
    Success     = Color3.fromHex("#ffffff"),
    Error       = Color3.fromHex("#ff3333"),
    Warning     = Color3.fromHex("#cccccc"),
    Ghost       = Color3.fromHex("#c0c0c0"),
}

local function CreateGradientText(text, color1, color2)
    if not text or type(text) ~= "string" then return "" end
    local result = ""
    local length = #text
    for i = 1, length do
        local progress = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((color1.R + (color2.R - color1.R) * progress) * 255)
        local g = math.floor((color1.G + (color2.G - color1.G) * progress) * 255)
        local b = math.floor((color1.B + (color2.B - color1.B) * progress) * 255)
        result = result..string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local function CreateFPSPingCounter()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "IndraHubStats" sg.ResetOnSpawn = false sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local function makeFrame(pos)
        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0,150,0,70) f.Position = pos
        f.BackgroundColor3 = Colors.Surface f.BackgroundTransparency = 0.3 f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0.15, 0)
        local s = Instance.new("UIStroke", f)
        s.Color = Colors.Accent s.Thickness = 2 s.Transparency = 0.5
        return f
    end
    local function makeLabel(parent, pos, text, size, color, bold)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1,0,0.5,0) l.Position = pos l.BackgroundTransparency = 1
        l.Text = text l.TextColor3 = color l.TextSize = size
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        return l
    end

    local fpsF = makeFrame(UDim2.new(0,10,0,10))
    makeLabel(fpsF, UDim2.new(0,0,0,5), "FPS", 14, Colors.Accent, true)
    local fpsV = makeLabel(fpsF, UDim2.new(0,0,0.5,-5), "0", 24, Colors.Text, true)

    local pingF = makeFrame(UDim2.new(0,10,0,90))
    makeLabel(pingF, UDim2.new(0,0,0,5), "PING", 14, Colors.Accent, true)
    local pingV = makeLabel(pingF, UDim2.new(0,0,0.5,-5), "0 ms", 20, Colors.Text, true)

    local last, frames = tick(), 0
    RunService.Heartbeat:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - last >= 1 then
            local fps = frames/(now-last)
            fpsV.Text = tostring(math.floor(fps))
            fpsV.TextColor3 = fps>=60 and Color3.fromRGB(0,255,0) or (fps>=30 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
            frames = 0 last = now
        end
        local ok2, p = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok2 and p then
            pingV.Text = math.floor(p).." ms"
            pingV.TextColor3 = p<=100 and Color3.fromRGB(0,255,0) or (p<=200 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
        end
    end)
    return sg
end
local statsGui = CreateFPSPingCounter()

local function CreateDiscordBanner()
    local sg = Instance.new("ScreenGui")
    sg.Name = "IndraHubDiscordBanner"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui

    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(1, 0, 0, 38)
    banner.Position = UDim2.new(0, 0, 0, 0)
    banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    banner.BackgroundTransparency = 0.05
    banner.BorderSizePixel = 0
    banner.Parent = sg

    local stroke = Instance.new("UIStroke", banner)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local grad = Instance.new("UIGradient", banner)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    grad.Rotation = 90

    local icon = Instance.new("ImageLabel", banner)
    icon.Name = "DiscordIcon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 14, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://11156081701"
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    local text = Instance.new("TextLabel", banner)
    text.Name = "BannerText"
    text.Size = UDim2.new(1, -200, 1, 0)
    text.Position = UDim2.new(0, 42, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "discord.gg/2PPBJsmqr"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left

    local subText = Instance.new("TextLabel", banner)
    subText.Name = "SubText"
    subText.Size = UDim2.new(0, 150, 1, 0)
    subText.Position = UDim2.new(1, -160, 0, 0)
    subText.BackgroundTransparency = 1
    subText.Text = "Support & Updates"
    subText.TextColor3 = Color3.fromRGB(170, 170, 170)
    subText.TextSize = 12
    subText.Font = Enum.Font.Gotham
    subText.TextXAlignment = Enum.TextXAlignment.Right

    local shimmer = Instance.new("Frame", banner)
    shimmer.Name = "Shimmer"
    shimmer.Size = UDim2.new(0, 120, 1, 0)
    shimmer.Position = UDim2.new(0, -120, 0, 0)
    shimmer.BackgroundTransparency = 0.9
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shimmer.BorderSizePixel = 0

    local shimmerGrad = Instance.new("UIGradient", shimmer)
    shimmerGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.4, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(0.6, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    }
    shimmerGrad.Rotation = 0

    task.spawn(function()
        while banner and banner.Parent do
            for i = -120, banner.AbsoluteSize.X + 120, 4 do
                if not banner or not banner.Parent then break end
                shimmer.Position = UDim2.new(0, i, 0, 0)
                task.wait(0.008)
            end
            task.wait(2)
        end
    end)

    local btn = Instance.new("TextButton", banner)
    btn.Name = "ClickArea"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 2

    btn.MouseEnter:Connect(function()
        TweenService:Create(banner, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(banner, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/2PPBJsmqr")
        end)
        WindUI:Notify({Title="Discord", Content="Link copied to clipboard!", Icon="link", Duration=3})
    end)

    return sg
end
local discordBanner = CreateDiscordBanner()




local popupClosed = false
local popupOk = pcall(function()
    WindUI:Popup({
        Title   = CreateGradientText("IndraHub", Colors.Accent, Colors.AccentDark),
        Icon    = "ghost",
        Content = CreateGradientText("Welcome to the Shadows.", Colors.Text, Colors.TextDim)
            .."<br/>"..CreateGradientText("IndraHub — ESP | Silent Aim | Smart Autofarm", Colors.Accent, Colors.Ghost)
            .."<br/>"..CreateGradientText("Support: discord.gg/2PPBJsmqr", Colors.Text, Colors.TextDim),
        Buttons = {
            { Title="Leave", Callback=function() LocalPlayer:Kick("Shadows refused.") end, Variant="Tertiary" },
            { Title=CreateGradientText("Enter the Void", Colors.Accent, Colors.AccentDark),
              Callback=function()
                  popupClosed = true
                  WindUI:Notify({Title="Welcome", Content="You are now one with the shadows. 👻", Icon="ghost", Duration=4})
              end, Variant="Primary" },
        },
    })
end)
if not popupOk then popupClosed = true end
repeat task.wait() until popupClosed

local Window
local wOk, wErr = pcall(function()
    Window = WindUI:CreateWindow({
        Title = CreateGradientText("IndraHub", Colors.Accent, Colors.AccentDark).." | IndraHub",
        Author = "IndraHub 👻",
        Folder = "IndraHub",
        Icon   = "ghost",
        NewElements = true,
        Size   = UDim2.new(0,620,0,520),
        Transparent = true,
        BackgroundTransparency = 0.3,
        Theme  = "Dark",
        SideBarWidth = 235,
        HideSearchBar = false,
        ScrollBarEnabled = true,
        OpenButton = {
            Title="IndraHub", CornerRadius=UDim.new(0.5,0),
            StrokeThickness=2, Enabled=true, Draggable=true,
            OnlyMobile=false, Color=ColorSequence.new(Colors.Accent, Colors.Murder),
        },
        User = { Enabled=true, Anonymous=false, Callback=function() end },
    })
end)
if not wOk or not Window then error("Window creation failed: "..tostring(wErr)) end

getgenv().OldPos = nil

local character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid         = character:WaitForChild("Humanoid")

local highlightEnabled  = false
local lineESPEnabled    = false
local lineESPObjects    = {}
local espFilters        = {"Esp All"}

local silentAimEnabled      = false
local silentAimMode         = "Revert"   
local showSAPrediction      = false
local saJumpPrediction      = true
local horizontalPrediction  = 1.0
local verticalPrediction    = 1.0
local wallCheckEnabled      = false
local wallCheckDelayed      = false
local isWaitingForClearShot = false
local delayedShotConn       = nil
local predictionESP         = nil
local predictionPart        = nil
local ShotButtonGUI         = nil       
local SilentAimEnabled      = false     
local saButtonSize          = 100

local KnifeSilentAimEnabled   = false
local knifeSilentAimConnection = nil

local AimlockEnabled   = false
local AimlockActive    = false
local AimlockTarget    = nil
local AimlockConnection = nil
local AimlockGUI       = nil

local flickShotEnabled = false

local FlyEnabled         = false
local FlySpeed           = 50
local NoclipEnabled      = false
local speedGlitchEnabled = false
local speedGlitchConnection = nil
local BunnyHopEnabled    = false
local FullbrightEnabled  = false

local HitboxExpanderEnabled = false
local HitboxSize = 10

local GodModeEnabled = false

local dualGunEnabled   = false
local dualKnifeEnabled = false
local dualGunClones    = {}
local dualKnifeClones  = {}

local customCursorEnabled = false
local customCursorGUI     = nil

local GunSystem = {
    AutoGrabEnabled      = false,
    GunDropCheckInterval = 1,
    ActiveGunDrops       = {},
}

local MAP_NAMES = {
    "Factory","Prison","Bank2","Workplace","Office2","House2","MilBase",
    "ResearchFacility","Hotel2","Mansion2","PoliceStation","BioLab","Hospital3",
}

local CharacterStats = {
    WalkSpeed = { Value=16, Locked=false },
    JumpPower = { Value=50, Locked=false },
}

local coinAutofarmEnabled     = false
local autofarmSpeed           = 25
local roundActive             = false
local isTeleporting           = false
local coinsCollected          = 0
local startPosition           = nil
local smartAutofarmEnabled    = false
local autoFlingMurdererEnabled= false
local maxCandyCapacity        = 40

local function ApplyCharacterStats()
    if not LocalPlayer.Character then return end
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if not CharacterStats.WalkSpeed.Locked then h.WalkSpeed  = CharacterStats.WalkSpeed.Value  end
    if not CharacterStats.JumpPower.Locked  then h.JumpPower = CharacterStats.JumpPower.Value   end
end

local function GetPlayerRole(player)
    if not player then return "Innocent" end
    local ch = player.Character if not ch then return "Innocent" end
    local bp = player:FindFirstChild("Backpack")
    if ch:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "Murderer" end
    if ch:FindFirstChild("Gun")   or (bp and bp:FindFirstChild("Gun"))   then return "Sheriff"  end
    return "Innocent"
end
local function GetRoleColor(role)
    if role == "Murderer" then return Colors.Murder
    elseif role == "Sheriff" then return Colors.Sheriff
    else return Colors.Innocent end
end
local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if p.Character:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return p end
        end
    end
    return nil
end
local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if p.Character:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return p end
        end
    end
    return nil
end
local function isSheriff()
    local bp, ch = LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character
    return (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun"))
end
local function findMurderer() return GetMurderer() end

local function GetSAPrediction(target)
    if not target or not target.Character then return nil end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    if silentAimMode == "SnapAim" then
        local vel = root.AssemblyLinearVelocity
        return root.Position + (vel * Vector3.new(1, 0.5, 1)) * 0.14
    end
    local vel = root.AssemblyLinearVelocity
    local ok, pingRaw = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    local ping = (ok and pingRaw or 100) / 1000
    local x = vel.X * horizontalPrediction
    local z = vel.Z * horizontalPrediction
    local y = saJumpPrediction and (vel.Y * verticalPrediction) or 0
    return root.Position + Vector3.new(x, y, z) * ping
end

local function GetSATarget()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        local bp = plr.Backpack
        local hasKnife    = (bp and bp:FindFirstChild("Knife"))    or plr.Character:FindFirstChild("Knife")
        local hasRevolver = (bp and bp:FindFirstChild("Revolver")) or plr.Character:FindFirstChild("Revolver")
        if not (hasKnife or hasRevolver) then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local d = (root.Position - myRoot.Position).Magnitude
        if d < closestDist then closestDist = d closest = plr end
    end
    return closest
end

local function HasClearShot(target)
    if not target or not target.Character then return false end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local origin = myRoot.Position
    local dir = (Vector3.new(root.Position.X, origin.Y, root.Position.Z) - origin).Unit * 1000
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, params)
    return result and result.Instance and result.Instance:IsDescendantOf(target.Character)
end

local function CreatePredESP()
    if predictionESP then predictionESP:Destroy() end
    if predictionPart then predictionPart:Destroy() end
    predictionPart = Instance.new("Part")
    predictionPart.Name = "IndraHubPredPart"
    predictionPart.Size = Vector3.new(2,2,2)
    predictionPart.Transparency = 1 predictionPart.Anchored = true
    predictionPart.CanCollide = false predictionPart.Parent = workspace
    predictionESP = Instance.new("BoxHandleAdornment")
    predictionESP.Adornee = predictionPart
    predictionESP.Size = predictionPart.Size + Vector3.new(0.3,0.3,0.3)
    predictionESP.Color3 = Color3.fromRGB(0,255,140)
    predictionESP.Transparency = 0.35 predictionESP.AlwaysOnTop = true
    predictionESP.ZIndex = 10 predictionESP.Parent = predictionPart
end
local function UpdatePredESP(pos)
    if not showSAPrediction or not predictionESP then
        if predictionESP then predictionESP.Adornee = nil end return
    end
    if not pos then predictionESP.Adornee = nil return end
    predictionPart.CFrame = CFrame.new(pos) predictionESP.Adornee = predictionPart
end

local oldInvokeServer
local hookFuncAvailable = (hookfunction or hookfunc) ~= nil

local function saHookFunc(self, ...)
    if not silentAimEnabled then return oldInvokeServer(self, ...) end
    if wallCheckEnabled then
        local t = GetSATarget()
        if t and not HasClearShot(t) then UpdatePredESP(nil) return oldInvokeServer(self, ...) end
    end
    local args = {...}
    
    if #args < 3 or self.Name ~= "RemoteFunction"
        or (self.Parent and self.Parent.Name ~= "CreateBeam")
        or args[3] ~= "AH2" then
        return oldInvokeServer(self, ...)
    end
    local target = GetSATarget()
    if not target then UpdatePredESP(nil) return oldInvokeServer(self, ...) end
    local pred = GetSAPrediction(target)
    if not pred then UpdatePredESP(nil) return oldInvokeServer(self, ...) end
    UpdatePredESP(pred)
    
    return oldInvokeServer(self, args[1], pred, args[3])
end

if hookFuncAvailable then
    local hook = hookfunction or hookfunc
    local fake = Instance.new("RemoteFunction")
    local hOk, hErr = pcall(function()
        oldInvokeServer = hook(fake.InvokeServer, saHookFunc)
    end)
    fake:Destroy()
    if not hOk then
        hookFuncAvailable = false
        warn("[IndraHubHub] hookfunction failed: "..tostring(hErr))
    end
end

RunService.RenderStepped:Connect(function()
    if not showSAPrediction or not silentAimEnabled then UpdatePredESP(nil) return end
    local t = GetSATarget()
    if t then UpdatePredESP(GetSAPrediction(t)) else UpdatePredESP(nil) end
end)

local function SAShoot()
    local char = LocalPlayer.Character if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid") if not hum then return end

    local gunTool, wasEquipped = nil, false
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("revolver")) then
            gunTool = t wasEquipped = true break
        end
    end
    if not gunTool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("revolver")) then
                    gunTool = t break
                end
            end
        end
    end
    if not gunTool then return end

    if not wasEquipped then
        hum:EquipTool(gunTool)
        task.wait(0.12)   
    end

    local target = GetSATarget() if not target then
        if not wasEquipped then hum:UnequipTools() end
        return
    end
    local pred = GetSAPrediction(target) if not pred then
        if not wasEquipped then hum:UnequipTools() end
        return
    end

    task.spawn(function()
        
        local remote = gunTool:FindFirstChild("KnifeLocal")
            and gunTool.KnifeLocal:FindFirstChild("CreateBeam")
            and gunTool.KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction")

        if remote then
            
            pcall(function() remote:InvokeServer(1, pred, "AH2") end)
        else
            
            local shoot = gunTool:FindFirstChild("Shoot")
            if shoot then
                local rh = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char.PrimaryPart
                if rh then
                    pcall(function() shoot:FireServer(CFrame.new(rh.Position), CFrame.new(pred)) end)
                end
            else
                
                pcall(function() gunTool:Activate() end)
            end
        end

        task.wait(0.15)
        if not wasEquipped then
            pcall(function() hum:UnequipTools() end)
        end
    end)
end

local function doShoot(silent)
    
    SAShoot()
    return true
end

local function FlickShot()
    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        WindUI:Notify({Title="Shift Lock Off", Content="Enable Shift Lock!", Icon="lock", Duration=2}) return false
    end
    if not isSheriff() then return false end
    local murderer = findMurderer()
    if not murderer or not murderer.Character then
        WindUI:Notify({Title="No Murderer", Content="Murderer not found!", Icon="alert-triangle", Duration=2}) return false
    end
    local char = LocalPlayer.Character if not char then return false end
    local gun = char:FindFirstChild("Gun")
    if not gun then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local bpGun = bp and bp:FindFirstChild("Gun")
        local h2 = char:FindFirstChildOfClass("Humanoid")
        if bpGun and h2 then h2:EquipTool(bpGun) task.wait(0.1) gun = char:FindFirstChild("Gun") end
    end
    if not gun then return false end
    local mChar = murderer.Character
    local head = mChar:FindFirstChild("Head")
    local hrp  = mChar:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return false end
    local originalCam = Camera.CFrame
    local reactionMs = math.random(0, 50)
    if reactionMs > 0 then task.wait(reactionMs / 1000) end
    local vel = hrp.AssemblyLinearVelocity
    local ok2, pingVal = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"].Value end)
    local ping = (ok2 and pingVal or 60) / 1000
    local movePred = vel * ping * 2.0
    local jumpPred = Vector3.new(0,0,0)
    local h2 = mChar:FindFirstChildOfClass("Humanoid")
    if h2 then
        local state = h2:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            jumpPred = Vector3.new(0, vel.Y * ping * 2.0, 0)
        end
    end
    local targetPos = head.Position + movePred + jumpPred
    local conn conn = RunService.RenderStepped:Connect(function()
        conn:Disconnect()
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        local shoot = gun:FindFirstChild("Shoot")
        if shoot then
            local rh = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            if rh then pcall(function() shoot:FireServer(CFrame.new(rh.Position), CFrame.new(targetPos)) end) end
        end
        task.spawn(function()
            task.wait(0.05)
            local flickDeg = math.random(10,12)
            local flickDir = math.random(0,1)==0 and 1 or -1
            local cam = Camera.CFrame
            Camera.CFrame = cam * CFrame.Angles(0, math.rad(flickDeg)*flickDir, 0)
            task.wait(0.1)
            for i = 0, 1, 0.2 do Camera.CFrame = Camera.CFrame:Lerp(originalCam, i) task.wait() end
            Camera.CFrame = originalCam
        end)
    end)
    return true
end

local function EnableSpeedGlitch()
    if speedGlitchConnection then speedGlitchConnection:Disconnect() end
    local char = LocalPlayer.Character if not char then return end
    local h2 = char:FindFirstChildOfClass("Humanoid") if not h2 then return end
    speedGlitchConnection = h2.StateChanged:Connect(function(_, new)
        if speedGlitchEnabled and new == Enum.HumanoidStateType.Jumping then
            task.spawn(function()
                task.wait(0.05)
                local orig = h2.WalkSpeed h2.WalkSpeed = 250
                task.wait(0.4)
                if speedGlitchEnabled then h2.WalkSpeed = orig end
            end)
        end
    end)
end

local function EnableDualGun()
    for _, c in pairs(dualGunClones) do pcall(function() c:Destroy() end) end
    dualGunClones = {}
    task.spawn(function()
        local activeClone = nil
        while dualGunEnabled do
            local char = LocalPlayer.Character
            if char then
                local gun = char:FindFirstChild("Gun")
                if gun and not activeClone then
                    local handle = gun:FindFirstChild("Handle")
                    if handle then
                        local clone = Instance.new("Part")
                        clone.Name = "DualWeapon" clone.Size = handle.Size
                        clone.Transparency = handle.Transparency clone.CanCollide = false
                        clone.CastShadow = false clone.Anchored = false clone.Massless = true
                        for _, v in pairs(handle:GetDescendants()) do
                            if v:IsA("SpecialMesh") or v:IsA("Decal") or v:IsA("Texture") then v:Clone().Parent = clone end
                        end
                        clone.Parent = char
                        local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                        if leftHand then
                            local motor = Instance.new("Motor6D")
                            motor.Name = "DualMotor" motor.Part0 = leftHand motor.Part1 = clone
                            motor.C0 = CFrame.new(0,-0.5,0) motor.C1 = CFrame.new(0,0,0) motor.Parent = leftHand
                            clone.CFrame = leftHand.CFrame * CFrame.new(0,-0.5,0)
                        end
                        activeClone = clone table.insert(dualGunClones, clone)
                    end
                elseif not gun and activeClone then
                    activeClone:Destroy() activeClone = nil dualGunClones = {}
                    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                    if leftHand then local m = leftHand:FindFirstChild("DualMotor") if m then m:Destroy() end end
                end
            end
            task.wait(0.1)
        end
        for _, c in pairs(dualGunClones) do pcall(function() c:Destroy() end) end
        dualGunClones = {}
    end)
end

local function EnableDualKnife()
    for _, c in pairs(dualKnifeClones) do pcall(function() c:Destroy() end) end
    dualKnifeClones = {}
    task.spawn(function()
        local activeClone = nil
        while dualKnifeEnabled do
            local char = LocalPlayer.Character
            if char then
                local knife = char:FindFirstChild("Knife")
                if knife and not activeClone then
                    local handle = knife:FindFirstChild("Handle")
                    if handle then
                        local clone = Instance.new("Part")
                        clone.Name = "DualKnife" clone.Size = handle.Size
                        clone.Transparency = handle.Transparency clone.CanCollide = false
                        clone.CastShadow = false clone.Anchored = false clone.Massless = true
                        for _, v in pairs(handle:GetDescendants()) do
                            if v:IsA("SpecialMesh") or v:IsA("Decal") or v:IsA("Texture") then v:Clone().Parent = clone end
                        end
                        clone.Parent = char
                        local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                        if leftHand then
                            local motor = Instance.new("Motor6D")
                            motor.Name = "DualMotor" motor.Part0 = leftHand motor.Part1 = clone
                            motor.C0 = CFrame.new(0,-0.5,0) motor.C1 = CFrame.new(0,0,0) motor.Parent = leftHand
                        end
                        activeClone = clone table.insert(dualKnifeClones, clone)
                    end
                elseif not knife and activeClone then
                    activeClone:Destroy() activeClone = nil dualKnifeClones = {}
                    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                    if leftHand then local m = leftHand:FindFirstChild("DualMotor") if m then m:Destroy() end end
                end
            end
            task.wait(0.1)
        end
        for _, c in pairs(dualKnifeClones) do pcall(function() c:Destroy() end) end
        dualKnifeClones = {}
    end)
end

local function EnableCustomCursor(cursorId)
    if customCursorGUI then customCursorGUI:Destroy() end
    local sg = Instance.new("ScreenGui") sg.Name = "IndraHubCursor" sg.ResetOnSpawn = false sg.Parent = CoreGui
    local img = Instance.new("ImageLabel", sg) img.Size = UDim2.new(0,32,0,32)
    img.BackgroundTransparency = 1
    img.Image = cursorId ~= "" and ("rbxassetid://"..cursorId) or "rbxassetid://7394263520"
    img.ZIndex = 10 UserInputService.MouseIconEnabled = false customCursorGUI = sg
    RunService.RenderStepped:Connect(function()
        if not customCursorEnabled then return end
        local pos = UserInputService:GetMouseLocation()
        img.Position = UDim2.new(0, pos.X-16, 0, pos.Y-16)
    end)
end

local function ApplySkyboxPreset(preset)
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if not preset.bk then  
            if sky then sky:Destroy() end return
        end
        if not sky then sky = Instance.new("Sky", Lighting) end
        sky.SkyboxBk = "rbxassetid://"..preset.bk
        sky.SkyboxDn = "rbxassetid://"..preset.dn
        sky.SkyboxFt = "rbxassetid://"..preset.ft
        sky.SkyboxLf = "rbxassetid://"..preset.lf
        sky.SkyboxRt = "rbxassetid://"..preset.rt
        sky.SkyboxUp = "rbxassetid://"..preset.up
    end)
end

local function IsMurderer(player)
    if not player or not player.Character then return false end
    local bp = player:FindFirstChild("Backpack")
    return player.Character:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
end
local function FindClosestMurderer()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest, closestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsMurderer(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, vis = Camera:WorldToScreenPoint(hrp.Position)
                if vis then
                    local d = (Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if d < closestD then closestD = d closest = p end
                end
            end
        end
    end
    return closest
end

local function CreateAimlockButton()
    if AimlockGUI then AimlockGUI:Destroy() end
    local sg = Instance.new("ScreenGui") sg.Name = "AimlockButton" sg.ResetOnSpawn = false sg.Parent = CoreGui
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,60) btn.Position = UDim2.new(0,10,0.5,-30)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,35) btn.BackgroundTransparency = 0.2
    btn.Text = "" btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5,0)
    local gr = Instance.new("UIGradient", btn)
    gr.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128,128,128))
    } gr.Rotation = 45
    local stroke2 = Instance.new("UIStroke", btn)
    stroke2.Color = Color3.fromRGB(200,200,200) stroke2.Thickness = 2 stroke2.Transparency = 0.3
    local label2 = Instance.new("TextLabel", btn)
    label2.Size = UDim2.new(1,0,0.6,0) label2.Position = UDim2.new(0,0,0.2,0)
    label2.BackgroundTransparency = 1 label2.Text = "LOCK" label2.TextSize = 14
    label2.TextColor3 = Color3.fromRGB(255,255,255) label2.Font = Enum.Font.GothamBold label2.TextStrokeTransparency = 0.5
    local statusLabel = Instance.new("TextLabel", btn)
    statusLabel.Name = "Status" statusLabel.Size = UDim2.new(1,0,0.3,0)
    statusLabel.Position = UDim2.new(0,0,0.7,0) statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF" statusLabel.TextSize = 10
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200) statusLabel.Font = Enum.Font.Gotham statusLabel.TextStrokeTransparency = 0.7
    local dragging, dragInput, dragStart, startPos2 = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos2 = btn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+delta.X, startPos2.Y.Scale, startPos2.Y.Offset+delta.Y)
        end
    end)
    local function GetPredictedPos(hrp)
        local ok2, pingVal = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"].Value end)
        local ping = (ok2 and pingVal or 80) / 1000
        local vel = hrp.AssemblyLinearVelocity
        local isJumping = vel.Y > 5
        local gravComp = isJumping and Vector3.new(0,-workspace.Gravity*ping*0.5,0) or Vector3.new(0,0,0)
        return hrp.Position + (vel*ping*1.8) + gravComp
    end
    btn.MouseButton1Click:Connect(function()
        AimlockActive = not AimlockActive
        if AimlockActive then
            AimlockTarget = FindClosestMurderer()
            if AimlockTarget then
                statusLabel.Text = "ON" statusLabel.TextColor3 = Color3.fromRGB(0,255,100)
                AimlockConnection = RunService.RenderStepped:Connect(function()
                    if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild("HumanoidRootPart") then
                        if not IsMurderer(AimlockTarget) then
                            AimlockActive = false statusLabel.Text = "OFF" statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
                            if AimlockConnection then AimlockConnection:Disconnect() AimlockConnection = nil end return
                        end
                        local hrp = AimlockTarget.Character.HumanoidRootPart
                        local pred = GetPredictedPos(hrp)
                        local cf = Camera.CFrame
                        Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, pred+Vector3.new(0,1.5,0)), 0.35)
                    else
                        AimlockActive = false statusLabel.Text = "OFF" statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
                        if AimlockConnection then AimlockConnection:Disconnect() AimlockConnection = nil end
                    end
                end)
            else
                AimlockActive = false statusLabel.Text = "NO TARGET" task.wait(1) statusLabel.Text = "OFF"
            end
        else
            statusLabel.Text = "OFF" statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
            if AimlockConnection then AimlockConnection:Disconnect() AimlockConnection = nil end
            AimlockTarget = nil
        end
    end)
    AimlockGUI = sg
end

local function CreateShotButton()
    if ShotButtonGUI then ShotButtonGUI:Destroy() end
    local sg = Instance.new("ScreenGui") sg.Name = "IndraHubShotButton" sg.ResetOnSpawn = false sg.Parent = CoreGui
    local cont = Instance.new("Frame") cont.Size = UDim2.new(0,120,0,120)
    cont.Position = UDim2.new(0.88,0,0.5,-60) cont.BackgroundTransparency = 1 cont.Parent = sg
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0,115,0,115)
    btn.Position = UDim2.new(0.5,0,0.5,0) btn.AnchorPoint = Vector2.new(0.5,0.5)
    btn.BackgroundColor3 = Colors.Surface btn.BackgroundTransparency = 0.05 btn.Text = "" btn.Parent = cont
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.28,0)
    local g = Instance.new("UIGradient", btn)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(0.5, Colors.AccentLight),
        ColorSequenceKeypoint.new(1, Colors.AccentDark)
    } g.Rotation = 45
    local str = Instance.new("UIStroke", btn) str.Color = Colors.AccentLight str.Thickness = 3.5 str.Transparency = 0.2
    task.spawn(function()
        while btn.Parent do
            for i = 0, 360, 5 do if btn.Parent then g.Rotation = i task.wait(0.03) end end
        end
    end)
    local glow = Instance.new("ImageLabel", btn) glow.Size = UDim2.new(1.4,0,1.4,0)
    glow.Position = UDim2.new(0.5,0,0.5,0) glow.AnchorPoint = Vector2.new(0.5,0.5)
    glow.BackgroundTransparency = 1 glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = Colors.Accent glow.ImageTransparency = 0.6 glow.ZIndex = 0
    local cross = Instance.new("Frame", btn) cross.Size = UDim2.new(0,50,0,50)
    cross.Position = UDim2.new(0.5,0,0.5,-5) cross.AnchorPoint = Vector2.new(0.5,0.5) cross.BackgroundTransparency = 1
    local hl = Instance.new("Frame", cross) hl.Size = UDim2.new(0,40,0,3)
    hl.Position = UDim2.new(0.5,0,0.5,0) hl.AnchorPoint = Vector2.new(0.5,0.5)
    hl.BackgroundColor3 = Colors.Text hl.BorderSizePixel = 0 Instance.new("UICorner", hl).CornerRadius = UDim.new(1,0)
    local vl = Instance.new("Frame", cross) vl.Size = UDim2.new(0,3,0,40)
    vl.Position = UDim2.new(0.5,0,0.5,0) vl.AnchorPoint = Vector2.new(0.5,0.5)
    vl.BackgroundColor3 = Colors.Text vl.BorderSizePixel = 0 Instance.new("UICorner", vl).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", cross) dot.Size = UDim2.new(0,8,0,8)
    dot.Position = UDim2.new(0.5,0,0.5,0) dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundColor3 = Colors.Murder dot.BorderSizePixel = 0 Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local lbl = Instance.new("TextLabel", btn) lbl.Size = UDim2.new(1,0,0.35,0)
    lbl.Position = UDim2.new(0,0,0.65,0) lbl.BackgroundTransparency = 1
    lbl.Text = "SHOOT" lbl.TextSize = 15 lbl.TextColor3 = Colors.Text lbl.Font = Enum.Font.GothamBold lbl.TextStrokeTransparency = 0.7
    TweenService:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {ImageTransparency=0.85, Size=UDim2.new(1.6,0,1.6,0)}):Play()
    TweenService:Create(cross, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Rotation=360}):Play()
    local drag, di, mp2, fp = false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true mp2 = i.Position fp = cont.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    btn.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i == di then
            local delta = i.Position - mp2
            cont.Position = UDim2.new(fp.X.Scale, fp.X.Offset+delta.X, fp.Y.Scale, fp.Y.Offset+delta.Y)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if flickShotEnabled then FlickShot()
        elseif silentAimEnabled then SAShoot()
        else doShoot(false) end
    end)
    ShotButtonGUI = sg
end

local function GetClosestToCursor()
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, vis = Camera:WorldToViewportPoint(hrp.Position)
                if vis then
                    local d = (Vector2.new(sp.X,sp.Y)-mousePos).Magnitude
                    if d < closestDist then closestDist = d closest = player end
                end
            end
        end
    end
    return closest
end
local function GetKnifePrediction(hrp)
    local ok2, pingVal = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"].Value end)
    local ping = (ok2 and pingVal or 80) / 1000
    local vel  = hrp.AssemblyLinearVelocity
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    local dist = myRoot and (hrp.Position - myRoot.Position).Magnitude or 20
    local travelTime = dist / 90
    local totalTime  = ping + travelTime
    
    local gravComp = Vector3.new(0, workspace.Gravity * totalTime * 0.35, 0)
    return hrp.Position + (vel * totalTime) + gravComp
end

local function FindKnifeThrowRemote(knife)
    
    local names = {"Throw", "ThrowKnife", "KnifeThrow", "Fire", "Activate"}
    for _, n in ipairs(names) do
        local r = knife:FindFirstChild(n)
        if r and (r:IsA("RemoteEvent") or r:IsA("BindableEvent")) then
            return r, "event"
        end
    end
    
    local kl = knife:FindFirstChild("KnifeLocal")
    if kl then
        local cb = kl:FindFirstChild("CreateBeam")
        if cb then
            local rf = cb:FindFirstChild("RemoteFunction")
            if rf then return rf, "function" end
        end
    end
    
    for _, child in ipairs(knife:GetDescendants()) do
        if child:IsA("RemoteEvent") then return child, "event" end
    end
    return nil, nil
end

local knifeHookConn = nil  

local function StartKnifeSilentAim()
    
    if knifeSilentAimConnection then knifeSilentAimConnection:Disconnect() knifeSilentAimConnection = nil end
    if knifeHookConn then pcall(function() knifeHookConn:Disconnect() end) knifeHookConn = nil end

    if hookFuncAvailable then
        local function hookKnifeOnEquip(knife)
            local remote, rtype = FindKnifeThrowRemote(knife)
            if not remote then return end

            if rtype == "event" then
                
                local fakeEvt = Instance.new("RemoteEvent")
                local ok3, hooked = pcall(function()
                    return hookfunction(fakeEvt.FireServer, function(self, ...)
                        if self ~= remote then return hooked(self, ...) end
                        if not KnifeSilentAimEnabled then return hooked(self, ...) end
                        local target = GetClosestToCursor()
                        if not target or not target.Character then return hooked(self, ...) end
                        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return hooked(self, ...) end
                        local pred = GetKnifePrediction(hrp)
                        
                        local args = {...}
                        args[1] = CFrame.new(pred)
                        return hooked(self, table.unpack(args))
                    end)
                end)
                fakeEvt:Destroy()
            end
        end

        local function bindChar(char)
            if not char then return end
            
            char.ChildAdded:Connect(function(child)
                if child.Name == "Knife" or child:IsA("Tool") and child.Name:lower():find("knife") then
                    task.wait(0.1)
                    hookKnifeOnEquip(child)
                end
            end)
            
            for _, child in ipairs(char:GetChildren()) do
                if child.Name == "Knife" or (child:IsA("Tool") and child.Name:lower():find("knife")) then
                    hookKnifeOnEquip(child)
                end
            end
        end

        bindChar(LocalPlayer.Character)
        knifeSilentAimConnection = LocalPlayer.CharacterAdded:Connect(bindChar)
        return
    end

    knifeSilentAimConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not KnifeSilentAimEnabled then return end

        local isThrowInput = (input.KeyCode == Enum.KeyCode.E)
            or (input.UserInputType == Enum.UserInputType.MouseButton2)

        if not isThrowInput then return end

        local ch = LocalPlayer.Character if not ch then return end

        local knife = nil
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and (t.Name == "Knife" or t.Name:lower():find("knife")) then
                knife = t break
            end
        end
        if not knife then return end

        local target = GetClosestToCursor()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local pred = GetKnifePrediction(hrp)

        local remote, rtype = FindKnifeThrowRemote(knife)
        if remote then
            if rtype == "event" then
                pcall(function() remote:FireServer(CFrame.new(pred)) end)
            elseif rtype == "function" then
                pcall(function() remote:InvokeServer(CFrame.new(pred)) end)
            end
        else
            
            pcall(function() knife:Activate() end)
        end
    end)
end

local function ShouldHighlightPlayer(player, filters)
    if not filters or type(filters) ~= "table" then return false end
    local role = GetPlayerRole(player)
    if table.find(filters, "Esp All") then return true end
    if table.find(filters, "Esp Murder") and role == "Murderer" then return true end
    if table.find(filters, "Esp Sheriff") and role == "Sheriff" then return true end
    if table.find(filters, "Esp Sheriff / Murder") and (role=="Sheriff" or role=="Murderer") then return true end
    return false
end
local function CreateHighlight(ch, color)
    if not ch then return end
    local hl = ch:FindFirstChild("RoleHighlight")
    if not hl then
        hl = Instance.new("Highlight") hl.Name = "RoleHighlight" hl.FillTransparency = 0.5
        hl.OutlineTransparency = 1 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = ch hl.Parent = ch
    end
    hl.FillColor = color
end
local function RemoveHighlight(ch)
    if not ch then return end local hl = ch:FindFirstChild("RoleHighlight") if hl then hl:Destroy() end
end
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local ch = player.Character if not ch then continue end
        if highlightEnabled and ShouldHighlightPlayer(player, espFilters) then
            CreateHighlight(ch, GetRoleColor(GetPlayerRole(player)))
        else RemoveHighlight(ch) end
    end
end
local function BindPlayerESP(player)
    player.CharacterAdded:Connect(function(ch)
        task.wait(1) if not highlightEnabled then return end
        CreateHighlight(ch, GetRoleColor(GetPlayerRole(player)))
    end)
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then BindPlayerESP(p) end end
Players.PlayerAdded:Connect(BindPlayerESP)
task.spawn(function() while true do task.wait(0.5) if highlightEnabled then UpdateESP() end end end)

local function FlingPlayers(playerNames)
    if not playerNames or type(playerNames) ~= "table" or #playerNames == 0 then return end
    local flingAll = false
    local function GetPlayerFromName(name)
        if not name or type(name) ~= "string" then return nil end
        name = name:lower()
        if name == "all" or name == "others" then flingAll = true return nil end
        if name == "random" then
            local all = {} for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(all, p) end end
            return #all > 0 and all[math.random(1,#all)] or nil
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if player.Name:lower():match("^"..name) or player.DisplayName:lower():match("^"..name) then return player end
            end
        end
        return nil
    end
    local function FlingPlayer(targetPlayer)
        if not targetPlayer then return end
        local localChar    = LocalPlayer.Character
        local localHum     = localChar and localChar:FindFirstChildOfClass("Humanoid")
        local localRoot    = localHum and localHum.RootPart
        local targetChar   = targetPlayer.Character
        local targetHum    = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        local targetRoot   = targetHum and targetHum.RootPart
        local targetHead   = targetChar and targetChar:FindFirstChild("Head")
        if not localChar or not localHum or not localRoot then return end
        if localRoot.Velocity.Magnitude < 50 then getgenv().OldPos = localRoot.CFrame end
        if targetHum and targetHum.Sit and not flingAll then return end
        if targetHead then workspace.CurrentCamera.CameraSubject = targetHead
        elseif targetHum then workspace.CurrentCamera.CameraSubject = targetHum end
        local function Teleport(part, offset, rotation)
            if not part or not localRoot then return end
            localRoot.CFrame = CFrame.new(part.Position) * offset * rotation
            localChar:SetPrimaryPartCFrame(CFrame.new(part.Position) * offset * rotation)
            localRoot.Velocity    = Vector3.new(9e8,9e8,9e8)
            localRoot.RotVelocity = Vector3.new(9e8,9e8,9e8)
        end
        local function PerformFling(part)
            if not part then return end
            local spin = 0 local st = tick()
            while localRoot and part and part.Parent do
                if targetHum then
                    local ok3, _ = pcall(function()
                        if part.Velocity.Magnitude < 50 then
                            spin = spin + 100
                            Teleport(part, CFrame.new(0,1.5,0)+targetHum.MoveDirection*part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(spin),0,0)) task.wait()
                            Teleport(part, CFrame.new(0,-1.5,0)+targetHum.MoveDirection*part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(spin),0,0)) task.wait()
                            Teleport(part, CFrame.new(2.25,1.5,-2.25)+targetHum.MoveDirection*part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(spin),0,0)) task.wait()
                            Teleport(part, CFrame.new(-2.25,-1.5,2.25)+targetHum.MoveDirection*part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(spin),0,0)) task.wait()
                        else
                            Teleport(part, CFrame.new(0,1.5,targetHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
                            Teleport(part, CFrame.new(0,-1.5,-targetHum.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
                        end
                    end)
                    if not ok3 then break end
                    if part.Velocity.Magnitude > 500 then break end
                    if part.Parent ~= targetPlayer.Character then break end
                    if targetPlayer.Parent ~= Players then break end
                    if targetPlayer.Character ~= targetChar then break end
                    if targetHum.Sit then break end
                    if localHum.Health <= 0 then break end
                    if tick() > st + 2 then break end
                else break end
            end
        end
        workspace.FallenPartsDestroyHeight = 0/0
        local bv = Instance.new("BodyVelocity") bv.Name = "EpixVel" bv.Parent = localRoot
        bv.Velocity = Vector3.new(9e8,9e8,9e8) bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        localHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if targetRoot and targetHead then
            if (targetRoot.CFrame.p-targetHead.CFrame.p).Magnitude > 5 then PerformFling(targetHead) else PerformFling(targetRoot) end
        elseif targetRoot then PerformFling(targetRoot)
        elseif targetHead then PerformFling(targetHead) end
        bv:Destroy() localHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = localHum
        repeat
            if not localRoot or not getgenv().OldPos then break end
            localRoot.CFrame = getgenv().OldPos * CFrame.new(0,0.5,0)
            localChar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0,0.5,0))
            localHum:ChangeState("GettingUp")
            for _, p in pairs(localChar:GetChildren()) do
                if p:IsA("BasePart") then p.Velocity = Vector3.new() p.RotVelocity = Vector3.new() end
            end
            task.wait()
        until not localRoot or not getgenv().OldPos or (localRoot.Position-getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = -500
    end
    if flingAll then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then FlingPlayer(p) end end
    else for _, name in pairs(playerNames) do
        local tp = GetPlayerFromName(name) if tp and tp ~= LocalPlayer then FlingPlayer(tp) end
    end end
end

local function FlingMurderer()
    local murderer = GetMurderer()
    if murderer and murderer.Character then
        WindUI:Notify({Title="Flinging Murderer", Content=murderer.Name.."!", Icon="zap", Duration=2})
        pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local mRoot  = murderer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and mRoot then
                myRoot.CFrame = mRoot.CFrame * CFrame.new(0,0,2) task.wait(0.05)
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(math.random(-200,200),300,math.random(-200,200))
                bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge) bv.Parent = mRoot
                game:GetService("Debris"):AddItem(bv, 0.2)
            end
        end)
        pcall(function() FlingPlayers({murderer.Name}) end)
        WindUI:Notify({Title="Fling Complete", Content="Done!", Icon="check-circle", Duration=1.5})
    else WindUI:Notify({Title="No Murderer", Content="Not found!", Icon="alert-circle", Duration=2}) end
end
local function FlingSheriff()
    local sheriff = GetSheriff()
    if sheriff and sheriff.Character then
        WindUI:Notify({Title="Flinging Sheriff", Content=sheriff.Name.."!", Icon="zap", Duration=3})
        FlingPlayers({sheriff.Name})
        WindUI:Notify({Title="Fling Complete", Content="Sheriff flung!", Icon="check-circle", Duration=2})
        return true
    end
    WindUI:Notify({Title="Fling Error", Content="No sheriff!", Icon="x-circle", Duration=3}) return false
end

local function FindGunDrops()
    GunSystem.ActiveGunDrops = {}
    for _, mapName in ipairs(MAP_NAMES) do
        local map = workspace:FindFirstChild(mapName)
        if map then local gd = map:FindFirstChild("GunDrop") if gd then table.insert(GunSystem.ActiveGunDrops, gd) end end
    end
    local mgd = workspace:FindFirstChild("GunDrop")
    if mgd then table.insert(GunSystem.ActiveGunDrops, mgd) end
end
local function GrabGun(specificGun)
    if not specificGun then
        FindGunDrops()
        if #GunSystem.ActiveGunDrops == 0 then
            WindUI:Notify({Title="Gun System", Content="No gun on map", Icon="x-circle", Duration=3})
            return false
        end
        local nearest, nearestD = nil, math.huge
        local ch = LocalPlayer.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root then
            for _, g in ipairs(GunSystem.ActiveGunDrops) do
                local d = (root.Position - g.Position).Magnitude
                if d < nearestD then nearest = g nearestD = d end
            end
        end
        specificGun = nearest
    end
    if specificGun and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            getgenv().OldPos = root.CFrame
            root.CFrame = specificGun.CFrame
            task.wait(0.3)
            local prompt = specificGun:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.2)
                if getgenv().OldPos then root.CFrame = getgenv().OldPos end
                WindUI:Notify({Title="Gun System", Content="Gun picked up!", Icon="check-circle", Duration=3})
                return true
            else
                if getgenv().OldPos then root.CFrame = getgenv().OldPos end
            end
        end
    end
    return false
end

local function AutoGrabGunLoop()
    while GunSystem.AutoGrabEnabled do
        FindGunDrops()
        if #GunSystem.ActiveGunDrops > 0 and LocalPlayer.Character and roundActive then
            local h2 = LocalPlayer.Character:FindFirstChild("Humanoid")
            if not h2 or h2.Health <= 0 then task.wait(1) continue end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local ng, nd = nil, math.huge
                for _, g in ipairs(GunSystem.ActiveGunDrops) do
                    if g and g.Parent then
                        local d = (root.Position-g.Position).Magnitude
                        if d < nd then ng = g nd = d end
                    end
                end
                if ng then
                    ng.CFrame = root.CFrame task.wait(0.3)
                    local p = ng:FindFirstChildOfClass("ProximityPrompt")
                    if p then fireproximityprompt(p) task.wait(1) end
                    WindUI:Notify({Title="Auto Grab", Content="Gun picked up!", Icon="check-circle", Duration=1.5})
                end
            end
        end
        task.wait(GunSystem.GunDropCheckInterval) 
    end
end

local function GetHumanoidRootPart()
    local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return ch:WaitForChild("HumanoidRootPart")
end
local function FindNearestCoin()
    local root = GetHumanoidRootPart()
    local nearestCoin, nearestDist = nil, math.huge
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") then
            for _, coin in pairs(obj.CoinContainer:GetChildren()) do
                if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                    local d = (root.Position - coin.Position).Magnitude
                    if d < nearestDist then nearestDist = d nearestCoin = coin end
                end
            end
        end
    end
    return nearestCoin, nearestDist
end

task.spawn(function()
    while true do
        if coinAutofarmEnabled and roundActive and not isTeleporting then
            local ok4, err4 = pcall(function()
                local root = GetHumanoidRootPart()
                local targetItem, distance = FindNearestCoin()
                if targetItem then
                    if distance > 150 then
                        root.CFrame = targetItem.CFrame
                    else
                        local tween = TweenService:Create(root, TweenInfo.new(distance/autofarmSpeed, Enum.EasingStyle.Linear), {CFrame=targetItem.CFrame})
                        tween:Play()
                        while true do
                            task.wait()
                            if not targetItem:FindFirstChild("TouchInterest") then break end
                            if not roundActive or not coinAutofarmEnabled then break end
                        end
                        tween:Cancel()
                    end
                    coinsCollected = coinsCollected + 1
                end
            end)
            if not ok4 then warn("[Autofarm] "..tostring(err4)) end
        end
        task.wait(0.05)
    end
end)

RunService.Stepped:Connect(function()
    if coinAutofarmEnabled and roundActive and not isTeleporting then
        local char = LocalPlayer.Character
        if char and char:IsDescendantOf(workspace) then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

local killAllRunning = false
local function AutoKillAll()
    if killAllRunning then return end

    local char = LocalPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local knife = char:FindFirstChild("Knife")
    if not knife then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        knife = bp and bp:FindFirstChild("Knife")
        if not knife then
            WindUI:Notify({Title="Kill All", Content="No knife found.", Icon="x-circle", Duration=2})
            return
        end
        knife.Parent = char
    end

    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character.PrimaryPart then
            local h2 = p.Character:FindFirstChildOfClass("Humanoid")
            if h2 and h2.Health > 0 then
                table.insert(targets, p.Character)
            end
        end
    end

    if #targets == 0 then
        WindUI:Notify({Title="Kill All", Content="No targets.", Icon="alert-circle", Duration=2})
        return
    end

    killAllRunning = true
    WindUI:Notify({Title="Kill All!", Content="Eliminating "..#targets.." players 🔪", Icon="skull", Duration=3})

    local startTime = tick()
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() - startTime > 3 then
            con:Disconnect()
            killAllRunning = false
            if char and char:IsDescendantOf(workspace) then
                for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
            end
            for _, c in pairs(targets) do
                if c and c.Parent then
                    for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                end
            end
            WindUI:Notify({Title="Kill All Done", Content=#targets.." targets hit", Icon="check-circle", Duration=3})
            return
        end
        
        if char and char:IsDescendantOf(workspace) then
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
        
        for _, c in pairs(targets) do
            if c and c.Parent and c.PrimaryPart then
                for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                c:SetPrimaryPartCFrame(myRoot.CFrame * CFrame.new(0, 0, -2))
            end
        end
    end)
end

local sheriffActionRunning = false
local function AutoSheriffAction()
    
    if sheriffActionRunning then return end
    sheriffActionRunning = true
    task.spawn(function()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then sheriffActionRunning = false return end
        local murderer = GetMurderer()
        if not murderer or not murderer.Character then
            WindUI:Notify({Title="No Murderer", Content="Target not found", Icon="alert-circle", Duration=2})
            sheriffActionRunning = false return
        end
        local mRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not mRoot then sheriffActionRunning = false return end
        local savedPos = myRoot.CFrame
        
        myRoot.CFrame = behindCF
        task.wait(0.05)
        WindUI:Notify({Title="Behind target!", Content="Firing... 🔫", Icon="crosshair", Duration=1})
        SAShoot()
        task.wait(0.35)  
        myRoot.CFrame = savedPos
        WindUI:Notify({Title="Returned", Content="Action complete ✅", Icon="check-circle", Duration=2})
        sheriffActionRunning = false
    end)
end

local innocentFlingRunning = false
local function AutoInnocentAction()
    if innocentFlingRunning then return end
    innocentFlingRunning = true
    task.spawn(function()
        FlingMurderer()
        task.wait(2) innocentFlingRunning = false
    end)
end

local function OnBagFull()
    if not smartAutofarmEnabled then return end
    local myRole = GetPlayerRole(LocalPlayer)
    WindUI:Notify({
        Title  = "Bag Full! Role: "..myRole,
        Content= myRole=="Murderer" and "Starting Kill All 🔪"
              or myRole=="Sheriff"   and "Shooting murderer with silent aim 🔫"
              or "Flinging murderer 🌪️",
        Icon="zap", Duration=3,
    })
    if myRole == "Murderer" then AutoKillAll()
    elseif myRole == "Sheriff" then AutoSheriffAction()
    else AutoInnocentAction() end
end

local function BagFullAttackMurderer()
    local myRole = GetPlayerRole(LocalPlayer)
    if myRole == "Murderer" then AutoKillAll()
    elseif myRole == "Sheriff" then AutoSheriffAction()
    else AutoInnocentAction() end
end

local RoundStart, RoundEnd, CoinCollected
pcall(function()
    RoundStart    = ReplicatedStorage.Remotes.Gameplay.RoundStart
    RoundEnd      = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
    CoinCollected = ReplicatedStorage.Remotes.Gameplay:FindFirstChild("CoinCollected")
end)

if RoundStart then
    RoundStart.OnClientEvent:Connect(function()
        roundActive = true coinsCollected = 0
        if LocalPlayer.Character then startPosition = LocalPlayer.Character.HumanoidRootPart.CFrame end
        if coinAutofarmEnabled then
            WindUI:Notify({Title="Round Started!", Content="Coin autofarm running 💰", Icon="play-circle", Duration=2})
        end
    end)
end
if RoundEnd then
    RoundEnd.OnClientEvent:Connect(function() roundActive = false end)
end
if CoinCollected then
    CoinCollected.OnClientEvent:Connect(function(coinType, current, maxVal)
        if coinType ~= "Candy" and coinAutofarmEnabled then
            if current then coinsCollected = current end
            
            local cap = maxVal or maxCandyCapacity
            if current and current >= cap then
                if smartAutofarmEnabled then task.spawn(OnBagFull)
                elseif autoFlingMurdererEnabled then task.spawn(FlingMurderer) end
                WindUI:Notify({Title="Bag Full!", Content="Action triggered", Icon="package", Duration=2})
            end
        end
    end)
end

local function SafeCreateSection(window, config)
    local ok, r = pcall(function() return window:Section(config) end)
    if ok then return r else warn("Section error: "..tostring(r)) return nil end
end
local function SafeCreateTab(section, config)
    if not section then return nil end
    local ok, r = pcall(function() return section:Tab(config) end)
    if ok then return r else warn("Tab error: "..tostring(r)) return nil end
end
local function SafeCreateToggle(tab, config)
    if not tab then return nil end
    local ok, r = pcall(function() return tab:Toggle(config) end)
    if ok then return r else warn("Toggle error: "..tostring(r)) return nil end
end
local function SafeCreateButton(tab, config)
    if not tab then return nil end
    local ok, r = pcall(function() return tab:Button(config) end)
    if ok then return r else warn("Button error: "..tostring(r)) return nil end
end
local function SafeCreateDropdown(tab, config)
    if not tab then return nil end
    if not config.Values then config.Values = {} end
    if type(config.Values) ~= "table" then config.Values = {} end
    if #config.Values == 0 then config.Values = {{Title="None", Icon="minus"}} end
    if config.Value == nil then config.Value = type(config.Values[1])=="table" and config.Values[1].Title or config.Values[1] end
    local ok, r = pcall(function() return tab:Dropdown(config) end)
    if ok then return r else warn("Dropdown error: "..tostring(r)) return nil end
end
local function SafeCreateSlider(tab, config)
    if not tab then return nil end
    local ok, r = pcall(function() return tab:Slider(config) end)
    if ok then return r else warn("Slider error: "..tostring(r)) return nil end
end
local function SafeCreateInput(tab, config)
    if not tab then return nil end
    local ok, r = pcall(function() return tab:Input(config) end)
    if ok then return r else warn("Input error: "..tostring(r)) return nil end
end
local function SafeCreateKeybind(tab, config)
    if not tab then return nil end
    local ok, r = pcall(function() return tab:Keybind(config) end)
    if ok then return r else warn("Keybind error: "..tostring(r)) return nil end
end

local MainSection = SafeCreateSection(Window, {
    Title = CreateGradientText("COMBAT", Colors.Murder, Colors.Accent), Icon = "crosshair",
})

local GunTab = SafeCreateTab(MainSection, { Title="Gun 🔫", Icon="target" })
if GunTab then
    GunTab:Section({ Title="Gun Silent Aim (Hook)", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(GunTab, {
        Title="Silent Aim",
        Desc="",
        Icon="crosshair", Color=Colors.Murder, Justify="Left", Flag="SilentAim",
        Callback=function(v)
            silentAimEnabled = v SilentAimEnabled = v
            if v and showSAPrediction then CreatePredESP() end
            WindUI:Notify({Title=v and "Silent Aim ON" or "Silent Aim OFF",
                Content=v and "Active 🎯" or "Disabled",
                Icon="crosshair", Duration=2})
        end,
    })

    GunTab:Space()

    SafeCreateDropdown(GunTab, {
        Flag="SAMode", Title="Aim Modu",
        Values={"Revert (Ping Config)","SnapAim (Low Ping)"},
        Value="Revert (Ping Config)",
        Callback=function(v)
            silentAimMode = (v and v:find("Snap")) and "SnapAim" or "Revert"
            WindUI:Notify({Title="Mode: "..silentAimMode, Content="", Icon="settings", Duration=2})
        end,
    })

    GunTab:Space()

    SafeCreateToggle(GunTab, {
        Title="Prediction ESP (Box)",
        Desc="Show predicted position as green box",
        Icon="eye", Color=Colors.Success, Justify="Left", Flag="SAPredESP",
        Callback=function(v)
            showSAPrediction = v
            if v then CreatePredESP() else UpdatePredESP(nil) end
        end,
    })

    GunTab:Space()

    SafeCreateToggle(GunTab, {
        Title="Wall Check", Desc="Don't shoot if target is behind a wall",
        Icon="shield", Color=Colors.Warning, Justify="Left", Flag="SAWallCheck",
        Callback=function(v) wallCheckEnabled = v wallCheckDelayed = v end,
    })

    GunTab:Space()

    SafeCreateToggle(GunTab, {
        Title="Jump Prediction", Desc="Vertical axis prediction for jumping targets",
        Icon="arrow-up", Color=Colors.Sheriff, Justify="Left", Flag="SAJumpPred",
        Default=true,
        Callback=function(v) saJumpPrediction = v end,
    })

    GunTab:Space()

    GunTab:Section({ Title="Revert Mode Sensitivity", TextSize=16, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateSlider(GunTab, {
        Title="Horizontal Prediction", Icon="move-horizontal", Min=0, Max=500, Default=100, Increment=5, Flag="SAHoriz",
        Callback=function(v) horizontalPrediction = v/100 end,
    })
    SafeCreateSlider(GunTab, {
        Title="Vertical Prediction", Icon="move-vertical", Min=0, Max=500, Default=100, Increment=5, Flag="SAVert",
        Callback=function(v) verticalPrediction = v/100 end,
    })

    GunTab:Space()

    GunTab:Section({ Title="Shoot Button", TextSize=16, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(GunTab, {
        Title="Shot Button (Animated)", Desc="Draggable animated fire button",
        Icon="target", Color=Colors.Murder, Justify="Left", Flag="ShowShotButton",
        Callback=function(v)
            if v then CreateShotButton() WindUI:Notify({Title="Button ON", Content="Drag & tap! 🎯", Icon="check", Duration=2})
            else
                if ShotButtonGUI then ShotButtonGUI:Destroy() ShotButtonGUI = nil end
                WindUI:Notify({Title="Button OFF", Content="Disabled", Icon="x", Duration=2})
            end
        end,
    })

    GunTab:Space()

    GunTab:Space()

    SafeCreateToggle(GunTab, {
        Title="Flick Shot (Shift Lock)",
        Desc="Instant headshot with prediction",
        Icon="zap", Color=Colors.Sheriff, Justify="Left", Flag="FlickShot",
        Callback=function(v)
            flickShotEnabled = v
            WindUI:Notify({Title=v and "⚡ Flick Shot ON" or "Flick Shot OFF",
                Content=v and "Shift Lock must be active!" or "Normal mode", Icon="zap", Duration=2})
        end,
    })

    GunTab:Space()

    SafeCreateToggle(GunTab, {
        Title="Aimlock (Murderer)", Desc="Camera follows the murderer",
        Icon="crosshair", Color=Colors.Murder, Justify="Left", Flag="Aimlock",
        Callback=function(v)
            AimlockEnabled = v
            if v then
                CreateAimlockButton()
                WindUI:Notify({Title="Aimlock ON", Content="Press the LOCK button!", Icon="crosshair", Duration=2})
            else
                if AimlockGUI then AimlockGUI:Destroy() AimlockGUI = nil end
                if AimlockConnection then AimlockConnection:Disconnect() AimlockConnection = nil end
                AimlockActive = false AimlockTarget = nil
                WindUI:Notify({Title="Aimlock OFF", Content="Disabled", Icon="x-circle", Duration=2})
            end
        end,
    })
end

local KnifeTab = SafeCreateTab(MainSection, { Title="Knife 🔪", Icon="zap" })
if KnifeTab then
    KnifeTab:Section({ Title="Knife Features", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(KnifeTab, {
        Title="Knife Silent Aim", Desc="Throw → redirects to closest target near cursor",
        Icon="crosshair", Color=Colors.Murder, Justify="Left", Flag="KnifeSA",
        Callback=function(v)
            KnifeSilentAimEnabled = v
            if v then StartKnifeSilentAim() WindUI:Notify({Title="Knife SA ON", Content="Throw → target! 🎯", Icon="crosshair", Duration=2})
            else
                if knifeSilentAimConnection then knifeSilentAimConnection:Disconnect() knifeSilentAimConnection = nil end
                if knifeHookConn then pcall(function() knifeHookConn:Disconnect() end) knifeHookConn = nil end
                WindUI:Notify({Title="Knife SA OFF", Content="Disabled", Icon="x-circle", Duration=2})
            end
        end,
    })

    KnifeTab:Space()

    SafeCreateToggle(KnifeTab, {
        Title="Dual Knife", Desc="Visual second knife in left hand",
        Icon="scissors", Color=Colors.Murder, Justify="Left", Flag="DualKnife",
        Callback=function(v)
            dualKnifeEnabled = v
            if v then EnableDualKnife() WindUI:Notify({Title="Dual Knife ON", Content="", Icon="check", Duration=2})
            else WindUI:Notify({Title="Dual Knife OFF", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    KnifeTab:Space()

    SafeCreateButton(KnifeTab, {
        Title="Kill All", Desc="Kill all players (must be Murderer)",
        Icon="skull", Color=Colors.Murder, Justify="Center",
        Callback=function() AutoKillAll() end,
    })

    KnifeTab:Space()

    SafeCreateButton(KnifeTab, {
        Title="Kill Sheriff Only", Desc="Target Sheriff only",
        Icon="target", Color=Colors.Sheriff, Justify="Center",
        Callback=function()
            local char = LocalPlayer.Character if not char then return end
            local sheriff = GetSheriff()
            if not sheriff then WindUI:Notify({Title="No Sheriff", Content="", Icon="x-circle", Duration=2}) return end
            local knife = char:FindFirstChild("Knife")
            if not knife then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                local bpK = bp and bp:FindFirstChild("Knife")
                local h2 = char:FindFirstChildOfClass("Humanoid")
                if bpK and h2 then h2:EquipTool(bpK) task.wait(0.2) knife = char:FindFirstChild("Knife") end
            end
            if knife and sheriff.Character then
                local tRoot = sheriff.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                if tRoot and myRoot then
                    local saved = myRoot.CFrame
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,1.5) task.wait(0.03)
                    local stab = knife:FindFirstChild("Stab") or knife:FindFirstChild("Attack") or knife:FindFirstChild("Slash")
                    if stab then pcall(function() stab:FireServer("Stab", tRoot) end) end
                    task.wait(0.03) myRoot.CFrame = saved
                    WindUI:Notify({Title="Sheriff Killed", Content=sheriff.Name, Icon="check-circle", Duration=2})
                end
            end
        end,
    })
end

local FlingTab = SafeCreateTab(MainSection, { Title="Fling 🌪️", Icon="wind" })
local selectedFlingType = "Murderer"
local selectedFlingPlayer = nil
local playerDropdown = nil

if FlingTab then
    FlingTab:Section({ Title="Fling System", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateDropdown(FlingTab, {
        Flag="FlingType", Title="Target Type",
        Values={{Title="Murderer",Icon="crosshair"},{Title="Sheriff",Icon="shield"},{Title="Player",Icon="user"}},
        Value="Murderer",
        Callback=function(s) if s and s.Title then selectedFlingType = s.Title end end,
    })

    FlingTab:Space()

    local initialList = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(initialList, {Title=p.Name,Icon="user"}) end end
    if #initialList == 0 then initialList = {{Title="No Players Found",Icon="user"}} end

    playerDropdown = SafeCreateDropdown(FlingTab, {
        Flag="FlingPlayerSelect", Title="Select Player",
        Values=initialList, Value=initialList[1].Title,
        Callback=function(s) if s and s.Title and s.Title ~= "No Players Found" then selectedFlingPlayer = s.Title end end,
    })

    FlingTab:Space()

    SafeCreateButton(FlingTab, {
        Title="FLING TARGET", Icon="zap", Color=Colors.Murder, Justify="Center",
        Callback=function()
            if selectedFlingType == "Murderer" then FlingMurderer()
            elseif selectedFlingType == "Sheriff" then FlingSheriff()
            elseif selectedFlingType == "Player" then
                if not selectedFlingPlayer or selectedFlingPlayer == "No Players Found" then
                    WindUI:Notify({Title="Error", Content="Select a player first!", Icon="alert-triangle", Duration=2}) return
                end
                FlingPlayers({selectedFlingPlayer})
                WindUI:Notify({Title="Fling Complete", Content=selectedFlingPlayer.." flung!", Icon="check-circle", Duration=2})
            end
        end,
    })

    FlingTab:Space()

    SafeCreateButton(FlingTab, {
        Title="Refresh List", Icon="refresh-cw", Color=Colors.Success, Justify="Center",
        Callback=function()
            local nl = {}
            for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(nl, {Title=p.Name,Icon="user"}) end end
            if #nl == 0 then nl = {{Title="No Players Found",Icon="user"}} end
            if playerDropdown and typeof(playerDropdown)=="table" and playerDropdown.Set then
                pcall(function() playerDropdown:Set(nl) end)
            end
            WindUI:Notify({Title="List Updated", Content=#nl.." players", Icon="check-circle", Duration=2})
        end,
    })
end

local VisualSection = SafeCreateSection(Window, {
    Title = CreateGradientText("VISUAL", Colors.Accent, Colors.Ghost), Icon="eye",
})

local ESPTab = SafeCreateTab(VisualSection, { Title="ESP 👁️", Icon="eye" })
if ESPTab then
    ESPTab:Section({ Title="Player ESP", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(ESPTab, {
        Title="Highlight ESP", Desc="Color-coded highlight by role",
        Icon="eye", Color=Colors.Accent, Justify="Left", Flag="HighlightESP",
        Callback=function(v)
            highlightEnabled = v
            if not v then
                for _, p in ipairs(Players:GetPlayers()) do if p.Character then RemoveHighlight(p.Character) end end
                WindUI:Notify({Title="ESP OFF", Content="", Icon="x-circle", Duration=2})
            else WindUI:Notify({Title="ESP ON", Content="Players highlighted!", Icon="eye", Duration=2}) end
        end,
    })

    ESPTab:Space()

    SafeCreateDropdown(ESPTab, {
        Flag="ESPFilter", Title="ESP Filter",
        Values={"Esp All","Esp Murder","Esp Sheriff","Esp Sheriff / Murder"},
        Value="Esp All",
        Callback=function(v) if v then espFilters = {v} end end,
    })
end

local TeleportSection = SafeCreateSection(Window, {
    Title = CreateGradientText("TELEPORT", Colors.Accent, Colors.AccentDark), Icon="navigation",
})
local TeleportTab = SafeCreateTab(TeleportSection, { Title="Teleports", Icon="map-pin" })
local selectedPlayer = nil

if TeleportTab then
    TeleportTab:Section({ Title="Role Teleportation", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateButton(TeleportTab, {
        Title="TP to Murderer", Icon="crosshair", Color=Colors.Murder, Justify="Center",
        Callback=function()
            local m = GetMurderer()
            if m and m.Character then
                local tr = m.Character:FindFirstChild("HumanoidRootPart")
                local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then mr.CFrame = tr.CFrame WindUI:Notify({Title="Teleported", Content="→ "..m.Name, Icon="check-circle", Duration=2}) end
            else WindUI:Notify({Title="Murderer Yok", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    TeleportTab:Space()

    SafeCreateButton(TeleportTab, {
        Title="TP to Sheriff", Icon="shield", Color=Colors.Sheriff, Justify="Center",
        Callback=function()
            local s = GetSheriff()
            if s and s.Character then
                local tr = s.Character:FindFirstChild("HumanoidRootPart")
                local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then mr.CFrame = tr.CFrame WindUI:Notify({Title="Teleported", Content="→ "..s.Name, Icon="check-circle", Duration=2}) end
            else WindUI:Notify({Title="No Sheriff", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    TeleportTab:Space({Columns=2})

    TeleportTab:Section({ Title="Gun Teleportation", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateButton(TeleportTab, {
        Title="Silah Al (Gun Drop)", Icon="download", Color=Colors.Sheriff, Justify="Center",
        Callback=function()
            if not GrabGun() then WindUI:Notify({Title="No Weapon", Content="Not found on map", Icon="x-circle", Duration=2}) end
        end,
    })

    TeleportTab:Space({Columns=2})

    TeleportTab:Section({ Title="Auto Grab Gun", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(TeleportTab, {
        Title="Auto Grab Gun", Desc="Automatically pick up gun drops",
        Icon="download", Color=Colors.Sheriff, Justify="Left", Flag="AutoGrabGun",
        Callback=function(v)
            GunSystem.AutoGrabEnabled = v
            if v then task.spawn(AutoGrabGunLoop) WindUI:Notify({Title="Auto Grab ON", Content="Running...", Icon="download", Duration=2})
            else WindUI:Notify({Title="Auto Grab OFF", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    TeleportTab:Space({Columns=2})

    TeleportTab:Section({ Title="Player Teleportation", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    local tpList = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(tpList, {Title=p.Name,Icon="user"}) end end
    if #tpList == 0 then tpList = {{Title="No Players",Icon="user"}} end
    local tpDropdown = SafeCreateDropdown(TeleportTab, {
        Flag="TeleportPlayer", Title="Select Player", Values=tpList, Value=tpList[1].Title,
        Callback=function(s) if s and s.Title and s.Title ~= "No Players" then selectedPlayer = s.Title end end,
    })

    TeleportTab:Space()

    SafeCreateButton(TeleportTab, {
        Title="TP to Selected Player", Icon="users", Color=Colors.Accent, Justify="Center",
        Callback=function()
            if not selectedPlayer or selectedPlayer == "No Players" then
                WindUI:Notify({Title="Select Player", Content="", Icon="alert-triangle", Duration=2}) return
            end
            local tp = Players:FindFirstChild(selectedPlayer)
            if tp and tp.Character then
                local tr = tp.Character:FindFirstChild("HumanoidRootPart")
                local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then mr.CFrame = tr.CFrame WindUI:Notify({Title="Teleported", Content="→ "..selectedPlayer, Icon="check-circle", Duration=2}) end
            else WindUI:Notify({Title="Player Not Found", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    TeleportTab:Space()

    SafeCreateButton(TeleportTab, {
        Title="Refresh List", Icon="refresh-cw", Color=Colors.Success, Justify="Center",
        Callback=function()
            local nl = {}
            for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(nl, {Title=p.Name,Icon="user"}) end end
            if #nl == 0 then nl = {{Title="No Players",Icon="user"}} end
            if tpDropdown and typeof(tpDropdown)=="table" and tpDropdown.Set then pcall(function() tpDropdown:Set(nl) end) end
            WindUI:Notify({Title="List Updated", Content=#nl.." players", Icon="check-circle", Duration=2})
        end,
    })
end

local MiscSection = SafeCreateSection(Window, {
    Title = CreateGradientText("MISC", Colors.Ghost, Colors.Accent), Icon="settings",
})
local MiscTab = SafeCreateTab(MiscSection, { Title="Miscellaneous", Icon="tool" })

if MiscTab then
    MiscTab:Section({ Title="Character Modifications", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(MiscTab, {
        Title="Noclip", Desc="Walk through walls", Icon="box", Color=Colors.Murder, Justify="Left", Flag="Noclip",
        Callback=function(v) NoclipEnabled = v end,
    })
    RunService.Stepped:Connect(function()
        if NoclipEnabled and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Fly", Desc="Flight (WASD + Space/Shift)", Icon="send", Color=Colors.Accent, Justify="Left", Flag="Fly",
        Callback=function(value)
            FlyEnabled = value
            
            if value then
                local root = humanoidRootPart
                local flyBody = Instance.new("BodyVelocity", root)
                flyBody.MaxForce = Vector3.new(math.huge,math.huge,math.huge) flyBody.Velocity = Vector3.new(0,0,0)
                local flyGyro = Instance.new("BodyGyro", root)
                flyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge) flyGyro.P = 10000
                task.spawn(function()
                    while FlyEnabled and flyBody and flyBody.Parent and flyGyro and flyGyro.Parent do
                        task.wait()
                        local dir = Vector3.new(0,0,0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                        flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * FlySpeed or Vector3.new(0,0,0)
                        flyGyro.CFrame = Camera.CFrame
                    end
                    if flyBody and flyBody.Parent then flyBody:Destroy() end
                    if flyGyro and flyGyro.Parent then flyGyro:Destroy() end
                end)
            end
        end,
    })

    SafeCreateSlider(MiscTab, {
        Title="Fly Speed", Icon="gauge", Min=10, Max=200, Default=50, Increment=5, Flag="FlySpeed",
        Callback=function(v) FlySpeed = v end,
    })

    MiscTab:Space({Columns=2})

    MiscTab:Section({ Title="Character Speed Settings", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateSlider(MiscTab, {
        Title="Walk Speed", Icon="activity", Min=0, Max=200, Default=16, Increment=1, Flag="WalkSpeed",
        Callback=function(v) CharacterStats.WalkSpeed.Value = v ApplyCharacterStats() end,
    })
    SafeCreateToggle(MiscTab, {
        Title="Lock Walk Speed", Icon="lock", Justify="Left", Flag="BlockWalkSpeed",
        Callback=function(v) CharacterStats.WalkSpeed.Locked = v end,
    })
    MiscTab:Space()
    SafeCreateSlider(MiscTab, {
        Title="Jump Power", Icon="arrow-up", Min=0, Max=200, Default=50, Increment=1, Flag="JumpPower",
        Callback=function(v) CharacterStats.JumpPower.Value = v ApplyCharacterStats() end,
    })
    SafeCreateToggle(MiscTab, {
        Title="Lock Jump Power", Icon="lock", Justify="Left", Flag="BlockJumpPower",
        Callback=function(v) CharacterStats.JumpPower.Locked = v end,
    })

    MiscTab:Space({Columns=2})

    MiscTab:Section({ Title="Advanced Character Mods", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    local InfiniteJumpEnabled = false
    SafeCreateToggle(MiscTab, {
        Title="Infinite Jump", Desc="Jump infinitely in the air",
        Icon="arrow-up-circle", Color=Colors.Success, Justify="Left", Flag="InfiniteJump",
        Callback=function(v) InfiniteJumpEnabled = v end,
    })
    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Bunny Hop", Desc="Hold Space to continuously hop",
        Icon="zap", Color=Colors.Warning, Justify="Left", Flag="BunnyHop",
        Callback=function(v) BunnyHopEnabled = v end,
    })
    RunService.Heartbeat:Connect(function()
        if BunnyHopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h:GetState() == Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    MiscTab:Space()

    local AntiRagdollEnabled = false
    SafeCreateToggle(MiscTab, {
        Title="Anti-Ragdoll", Desc="Prevent ragdoll state",
        Icon="shield", Color=Colors.Murder, Justify="Left", Flag="AntiRagdoll",
        Callback=function(v)
            AntiRagdollEnabled = v
            if v then task.spawn(function()
                while AntiRagdollEnabled do task.wait()
                    if LocalPlayer.Character then
                        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h and h:GetState() == Enum.HumanoidStateType.Ragdoll then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
                    end
                end
            end) end
        end,
    })

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Fullbright", Desc="Max brightness",
        Icon="sun", Color=Colors.Accent, Justify="Left", Flag="Fullbright",
        Callback=function(v)
            FullbrightEnabled = v
            if v then Lighting.Brightness=10 Lighting.GlobalShadows=false Lighting.Ambient=Color3.fromRGB(255,255,255)
            else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) end
        end,
    })

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Hitbox Expander", Desc="Expand player hitboxes",
        Icon="maximize", Color=Colors.Murder, Justify="Left", Flag="HBExpand",
        Callback=function(v)
            HitboxExpanderEnabled = v
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            if v then part.Size = Vector3.new(HitboxSize,HitboxSize,HitboxSize) part.Transparency = 0.7 part.CanCollide = false
                            else part.Transparency = 0 end
                        end
                    end
                end
            end
        end,
    })
    SafeCreateSlider(MiscTab, {
        Title="Hitbox Size", Icon="maximize-2", Min=5, Max=30, Default=10, Increment=1, Flag="HBSize",
        Callback=function(v) HitboxSize = v end,
    })

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="God Mode", Desc="Infinite health",
        Icon="shield-off", Color=Colors.Success, Justify="Left", Flag="GodMode",
        Callback=function(v)
            GodModeEnabled = v
            if v and LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h.MaxHealth = math.huge h.Health = math.huge end
            end
        end,
    })

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Remove Fog", Desc="Remove map fog",
        Icon="eye", Color=Colors.Sheriff, Justify="Left", Flag="RemFog",
        Callback=function(v) Lighting.FogEnd = v and 1000000 or 100000 Lighting.FogStart = 0 end,
    })

    MiscTab:Space()

    SafeCreateSlider(MiscTab, {
        Title="Field of View", Icon="maximize", Min=70, Max=120, Default=70, Increment=1, Flag="FOV",
        Callback=function(v) Camera.FieldOfView = v end,
    })

    MiscTab:Space()

    SafeCreateToggle(MiscTab, {
        Title="Dual Gun", Desc="Visual second gun in left hand",
        Icon="target", Color=Colors.Sheriff, Justify="Left", Flag="DualGun",
        Callback=function(v)
            dualGunEnabled = v
            if v then EnableDualGun() WindUI:Notify({Title="Dual Gun ON", Content="", Icon="check", Duration=2})
            else WindUI:Notify({Title="Dual Gun OFF", Content="", Icon="x-circle", Duration=2}) end
        end,
    })

    MiscTab:Space()

    MiscTab:Section({ Title="Speed Glitch", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(MiscTab, {
        Title="Speed Glitch", Desc="Super speed while jumping",
        Icon="zap", Color=Colors.Success, Justify="Left", Flag="SpeedGlitch",
        Callback=function(v)
            speedGlitchEnabled = v
            if v then EnableSpeedGlitch() WindUI:Notify({Title="Speed Glitch ON", Content="Jump! 🚀", Icon="zap", Duration=2})
            else
                if speedGlitchConnection then speedGlitchConnection:Disconnect() speedGlitchConnection = nil end
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 16 end
                WindUI:Notify({Title="Speed Glitch OFF", Content="", Icon="x-circle", Duration=2})
            end
        end,
    })

    MiscTab:Space()

    MiscTab:Section({ Title="Cosmetics", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    local cursorPresets = {
        {name="Default",id=""},{name="Crosshair",id="6444569614"},{name="Dot",id="163023520"},
        {name="Sword",id="414645050"},{name="Heart",id="282927582"},{name="Star",id="187631972"},{name="Arrow",id="7394263520"},
    }
    SafeCreateDropdown(MiscTab, {
        Title="Custom Cursor", Icon="mouse-pointer",
        Values={"Default","Crosshair","Dot","Sword","Heart","Star","Arrow"},
        Default="Default", Flag="CursorPreset",
        Callback=function(value)
            for _, preset in ipairs(cursorPresets) do
                if preset.name == value then
                    if customCursorGUI then customCursorGUI:Destroy() customCursorGUI = nil end
                    if preset.id == "" then UserInputService.MouseIconEnabled = true customCursorEnabled = false
                    else customCursorEnabled = true EnableCustomCursor(preset.id) end
                    WindUI:Notify({Title="Cursor", Content=value=="Default" and "Default applied" or value.." applied", Icon="mouse-pointer", Duration=2})
                    break
                end
            end
        end,
    })

    MiscTab:Space()

    local skyboxPresets = {
        {name="Default"},  
        {name="Night Sky",    bk="159454286",  dn="159454286",  ft="159454286",  lf="159454286",  rt="159454286",  up="159454286"},
        {name="Galaxy",       bk="1012556613", dn="1012556613", ft="1012556613", lf="1012556613", rt="1012556613", up="1012556613"},
        {name="Bloxburg Sky", bk="276702452",  dn="276702452",  ft="276702452",  lf="276702452",  rt="276702452",  up="276702452"},
        {name="Neon Purple",  bk="6444320701", dn="6444320701", ft="6444320701", lf="6444320701", rt="6444320701", up="6444320701"},
        {name="Sunset",       bk="1560824536", dn="1560824536", ft="1560824536", lf="1560824536", rt="1560824536", up="1560824536"},
    }
    SafeCreateDropdown(MiscTab, {
        Title="Custom Skybox", Icon="cloud",
        Values={"Default","Night Sky","Galaxy","Bloxburg Sky","Neon Purple","Sunset"},
        Default="Default", Flag="SkyboxPreset",
        Callback=function(value)
            for _, preset in ipairs(skyboxPresets) do
                if preset.name == value then
                    ApplySkyboxPreset(preset)
                    WindUI:Notify({Title="Skybox", Content=value=="Default" and "Default applied" or value.." applied", Icon="cloud", Duration=2})
                    break
                end
            end
        end,
    })
end

local bjGui              = nil
local bjBtn              = nil
local timerGui_bj        = nil
local timerDisplay_bj    = nil
local onCooldown_bj      = false
local bombJumpEnabled    = false
local equipBombJump      = false
local bjGuiEnabled       = false
local timerGuiEnabled_bj = false
local debounce_bj        = false
local bjSize             = 40
local timerSize_bj       = 40
local autoGetBomb        = false
local justRespawned      = false
local activeTouches      = {}
local bombEquipConns     = {}

local BOMB_NAMES = {"Bomb", "PrankBomb", "FakeBomb"}
local TAP_MOVE_THRESH = 10
local TAP_TIME_THRESH = 0.3

local function BJ_GetCenter()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart.Position + (Camera.CFrame.LookVector * 5)
    end
end

local function BJ_Jump()
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end

local function BJ_ResetCooldown()
    onCooldown_bj = false
    if bjBtn and bjBtn.Parent then bjBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) bjBtn.Text = "Ready" end
    if timerDisplay_bj and timerDisplay_bj.Parent then timerDisplay_bj.Text = "Ready" timerDisplay_bj.BackgroundColor3 = Color3.fromRGB(60,60,60) end
end

local function BJ_StartCooldown()
    onCooldown_bj = true debounce_bj = false
    if bjBtn then bjBtn.BackgroundColor3 = Color3.fromRGB(40,40,40) bjBtn.Text = "Wait" end
    if timerDisplay_bj then timerDisplay_bj.Text = "Wait" timerDisplay_bj.BackgroundColor3 = Color3.fromRGB(40,40,40) end
    task.spawn(function()
        for i = 22, 1, -1 do
            if not onCooldown_bj then break end
            if bjBtn and bjBtn.Parent then bjBtn.Text = tostring(i) end
            if timerDisplay_bj then timerDisplay_bj.Text = tostring(i) end
            task.wait(1)
        end
        if onCooldown_bj then BJ_ResetCooldown() end
    end)
end

local function BJ_Unequip()
    task.spawn(function()
        task.wait(0.5)
        local c = LocalPlayer.Character
        if c then
            for _, n in ipairs(BOMB_NAMES) do
                local b = c:FindFirstChild(n)
                if b then b.Parent = LocalPlayer.Backpack or c break end
            end
        end
    end)
end

local function BJ_GetBombInHand()
    local c = LocalPlayer.Character
    if not c then return nil end
    for _, n in ipairs(BOMB_NAMES) do
        local b = c:FindFirstChild(n)
        if b then return b end
    end
end

local function BJ_GetAnyBomb()
    local c = LocalPlayer.Character
    if not c then return false, nil end
    for _, n in ipairs(BOMB_NAMES) do
        local b = c:FindFirstChild(n)
        if b then return true, b end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, n in ipairs(BOMB_NAMES) do
            local b = bp:FindFirstChild(n)
            if b then b.Parent = c return true, b end
        end
    end
    local ok2 = pcall(function()
        ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb")
    end)
    if ok2 then
        for _ = 1, 5 do
            for _, n in ipairs(BOMB_NAMES) do
                local b = c:FindFirstChild(n)
                if b then return true, b end
                if bp then b = bp:FindFirstChild(n) if b then b.Parent = c return true, b end end
            end
            task.wait(0.05)
        end
    end
    return false, nil
end

local function FastBombJump()
    if onCooldown_bj or debounce_bj or justRespawned then return end
    debounce_bj = true
    local ok3, bomb = BJ_GetAnyBomb()
    if ok3 and bomb then
        local pos = BJ_GetCenter()
        if pos then
            local remote = bomb:FindFirstChild("Remote")
            if remote then pcall(function() remote:FireServer(CFrame.new(pos), 50) end) end
            BJ_Jump()
            BJ_Unequip()
            task.spawn(function() task.wait(0.1) BJ_StartCooldown() end)
        end
    end
    task.spawn(function() task.wait(0.5) debounce_bj = false end)
end

local function BJ_CreateButton()
    if bjGui then bjGui:Destroy() end
    bjGui = Instance.new("ScreenGui")
    bjGui.Name = "IndraHubBJGui" bjGui.ResetOnSpawn = false bjGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    bjBtn = Instance.new("TextButton", bjGui)
    bjBtn.Name = "BJButton" bjBtn.Text = "BJ" bjBtn.TextSize = bjSize/3
    bjBtn.Size = UDim2.new(0, bjSize, 0, bjSize)
    bjBtn.Position = UDim2.new(0.5, -bjSize/2, 0.8, 0)
    bjBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) bjBtn.TextColor3 = Color3.new(1,1,1)
    bjBtn.Font = Enum.Font.GothamBold bjBtn.BackgroundTransparency = 0.3
    Instance.new("UICorner", bjBtn).CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke", bjBtn)
    stroke.Thickness = 2 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local grad = Instance.new("UIGradient", stroke)
    grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0,85,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,200))}
    grad.Rotation = 45
    bjBtn.MouseButton1Click:Connect(function()
        if not onCooldown_bj and not debounce_bj then FastBombJump() end
    end)
    local drg, drs, drp = false, nil, nil
    bjBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drg=true drs=inp.Position drp=bjBtn.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drg=false end end)
        end
    end)
    bjBtn.InputChanged:Connect(function(inp)
        if drg and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - drs
            bjBtn.Position = UDim2.new(drp.X.Scale, drp.X.Offset+d.X, drp.Y.Scale, drp.Y.Offset+d.Y)
        end
    end)
end

local function BJ_CreateTimer()
    if timerGui_bj then timerGui_bj:Destroy() end
    timerGui_bj = Instance.new("ScreenGui")
    timerGui_bj.Name = "IndraHubBJTimer" timerGui_bj.ResetOnSpawn = false timerGui_bj.Parent = LocalPlayer:WaitForChild("PlayerGui")
    timerDisplay_bj = Instance.new("TextLabel", timerGui_bj)
    timerDisplay_bj.Name = "TimerDisplay" timerDisplay_bj.Text = "Ready" timerDisplay_bj.TextSize = 13
    timerDisplay_bj.Size = UDim2.new(0, timerSize_bj, 0, timerSize_bj)
    timerDisplay_bj.Position = UDim2.new(0.5, -timerSize_bj/2+65, 0.8, 0)
    timerDisplay_bj.BackgroundColor3 = Color3.fromRGB(60,60,60) timerDisplay_bj.TextColor3 = Color3.new(1,1,1)
    timerDisplay_bj.Font = Enum.Font.GothamBold timerDisplay_bj.BackgroundTransparency = 0.3
    Instance.new("UICorner", timerDisplay_bj).CornerRadius = UDim.new(1,0)
    local stroke2 = Instance.new("UIStroke", timerDisplay_bj)
    stroke2.Thickness = 2 stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local grad2 = Instance.new("UIGradient", stroke2)
    grad2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0,85,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,200))}
    grad2.Rotation = 45
    local drg2, drs2, drp2 = false, nil, nil
    timerDisplay_bj.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drg2=true drs2=inp.Position drp2=timerDisplay_bj.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drg2=false end end)
        end
    end)
    timerDisplay_bj.InputChanged:Connect(function(inp)
        if drg2 and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - drs2
            timerDisplay_bj.Position = UDim2.new(drp2.X.Scale, drp2.X.Offset+d.X, drp2.Y.Scale, drp2.Y.Offset+d.Y)
        end
    end)
end

local function BJ_SetupEquipDetect()
    for _, c in pairs(bombEquipConns) do c:Disconnect() end
    bombEquipConns = {}
    if not equipBombJump then return end
    local char = LocalPlayer.Character
    if not char then return end
    local conn = char.ChildAdded:Connect(function(child)
        if not equipBombJump or justRespawned then return end
        for _, n in ipairs(BOMB_NAMES) do
            if child.Name == n then
                if not onCooldown_bj and not debounce_bj then FastBombJump() end
                break
            end
        end
    end)
    table.insert(bombEquipConns, conn)
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        activeTouches[inp] = {startPosition=inp.Position, startTime=tick(), moved=false}
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    local td = activeTouches[inp]
    if not td then return end
    local d = inp.Position - td.startPosition
    if math.sqrt(d.X*d.X + d.Y*d.Y) > TAP_MOVE_THRESH then td.moved = true end
end)
UserInputService.InputEnded:Connect(function(inp, gp)
    if gp then activeTouches[inp] = nil return end
    local td = activeTouches[inp]
    if not td then return end
    local dur = tick() - td.startTime
    if not td.moved and dur <= TAP_TIME_THRESH and bombJumpEnabled and not onCooldown_bj and not debounce_bj then
        if BJ_GetBombInHand() then FastBombJump() end
    end
    activeTouches[inp] = nil
end)

local _bjCharConn = LocalPlayer.CharacterAdded:Connect(function()
    BJ_ResetCooldown()
    activeTouches = {}
    justRespawned = true
    task.spawn(function()
        task.wait(1)
        justRespawned = false
    end)
    if autoGetBomb then
        task.wait(1.2)
        pcall(function() ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb") end)
    end
    if equipBombJump then
        task.wait(1.2)
        BJ_SetupEquipDetect()
    end
end)

local BombJumpTab = SafeCreateTab(MiscSection, { Title="Bomb Jump 💣", Icon="zap" })
if BombJumpTab then
    BombJumpTab:Section({ Title="Bomb Jump+ (ATAOs)", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(BombJumpTab, {
        Title="Auto Bomb Jump", Desc="Tap/click while holding bomb to launch",
        Icon="zap", Color=Colors.Warning, Justify="Left", Flag="BombJumpAuto",
        Callback=function(v) bombJumpEnabled = v end,
    })

    BombJumpTab:Space()

    SafeCreateToggle(BombJumpTab, {
        Title="Equip Bomb Jump", Desc="Jump fires automatically when you equip a bomb",
        Icon="arrow-up-circle", Color=Colors.Accent, Justify="Left", Flag="BombJumpEquip",
        Callback=function(v)
            equipBombJump = v
            if v then BJ_SetupEquipDetect()
            else for _, c in pairs(bombEquipConns) do c:Disconnect() end bombEquipConns = {} end
        end,
    })

    BombJumpTab:Space()

    SafeCreateToggle(BombJumpTab, {
        Title="Auto-Get Fake Bomb", Desc="Automatically get a Fake Bomb on spawn",
        Icon="package", Color=Colors.Success, Justify="Left", Flag="AutoGetBomb",
        Callback=function(v) autoGetBomb = v end,
    })

    BombJumpTab:Space()

    SafeCreateButton(BombJumpTab, {
        Title="Get Fake Bomb Now", Icon="download", Color=Colors.Success, Justify="Center",
        Callback=function()
            pcall(function() ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb") end)
            WindUI:Notify({Title="Bomb", Content="Fake Bomb requested!", Icon="package", Duration=2})
        end,
    })

    BombJumpTab:Space()

    SafeCreateButton(BombJumpTab, {
        Title="Manual Bomb Jump", Icon="arrow-up", Color=Colors.Murder, Justify="Center",
        Callback=function()
            if not onCooldown_bj and not debounce_bj then FastBombJump()
            else WindUI:Notify({Title="On Cooldown", Content="Wait for timer!", Icon="clock", Duration=2}) end
        end,
    })

    BombJumpTab:Space()

    BombJumpTab:Section({ Title="BJ Button & Timer", TextSize=16, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(BombJumpTab, {
        Title="Show BJ Button", Desc="Draggable on-screen bomb jump button",
        Icon="circle", Color=Colors.Accent, Justify="Left", Flag="BJButton",
        Callback=function(v)
            bjGuiEnabled = v
            if v then
                BJ_CreateButton()
            else
                if bjGui then bjGui:Destroy() bjGui=nil bjBtn=nil end
            end
        end,
    })

    SafeCreateSlider(BombJumpTab, {
        Title="BJ Button Size", Min=30, Max=150, Default=40, Increment=5, Flag="BJButtonSize",
        Icon="maximize",
        Callback=function(v)
            bjSize = v
            if bjBtn then bjBtn.Size = UDim2.new(0,v,0,v) bjBtn.Position = UDim2.new(0.5,-v/2,0.8,0) bjBtn.TextSize = v/3 end
        end,
    })

    BombJumpTab:Space()

    SafeCreateToggle(BombJumpTab, {
        Title="Show Cooldown Timer", Desc="Draggable countdown display",
        Icon="clock", Color=Colors.Warning, Justify="Left", Flag="BJTimer",
        Callback=function(v)
            timerGuiEnabled_bj = v
            if v then
                BJ_CreateTimer()
            else
                if timerGui_bj then timerGui_bj:Destroy() timerGui_bj=nil timerDisplay_bj=nil end
            end
        end,
    })

    SafeCreateSlider(BombJumpTab, {
        Title="Timer Size", Min=30, Max=150, Default=40, Increment=5, Flag="BJTimerSize",
        Icon="maximize",
        Callback=function(v)
            timerSize_bj = v
            if timerDisplay_bj then timerDisplay_bj.Size = UDim2.new(0,v,0,v) timerDisplay_bj.Position = UDim2.new(0.5,-v/2+65,0.8,0) end
        end,
    })

    BombJumpTab:Space()

    SafeCreateKeybind(BombJumpTab, {
        Flag="BJKeybind", Title="Manual Jump Keybind", Value="E",
        Callback=function(key)
            if key then
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.KeyCode == Enum.KeyCode[key] and not onCooldown_bj and not debounce_bj then
                        FastBombJump()
                    end
                end)
            end
        end,
    })
end

local AutofarmSection = SafeCreateSection(Window, {
    Title = CreateGradientText("AUTOFARM", Colors.Success, Colors.Warning), Icon="trending-up",
})
local AutofarmTab = SafeCreateTab(AutofarmSection, { Title="Auto Farm", Icon="dollar-sign" })

if AutofarmTab then
    AutofarmTab:Section({ Title="Coin Collection", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(AutofarmTab, {
        Title="Coin Autofarm", Desc="Automatically collect coins during round",
        Icon="dollar-sign", Color=Colors.Warning, Justify="Left", Flag="CoinAutofarm",
        Callback=function(v)
            coinAutofarmEnabled = v
            if v then coinsCollected = 0 WindUI:Notify({Title="Coin Autofarm ON", Content="Collecting coins 💰", Icon="dollar-sign", Duration=2})
            else WindUI:Notify({Title="Coin Autofarm OFF", Content="Total: "..coinsCollected, Icon="check-circle", Duration=2}) end
        end,
    })

    AutofarmTab:Space()

    AutofarmTab:Section({ Title="Smart Bag Full Action", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateToggle(AutofarmTab, {
        Title="Smart Bag Full Action",
        Desc="When bag fills, acts by role:\n🔪 Murderer → Kill All\n🔫 Sheriff → TP behind + Silent Aim + return\n😇 Innocent → Fling Murderer",
        Icon="zap", Color=Colors.Accent, Justify="Left", Flag="SmartBagFull",
        Callback=function(v)
            smartAutofarmEnabled = v
            local desc = v
                and "Role-based action active!\n🔪 Kill All | 🔫 TP+Shoot | 😇 Fling"
                or  "Disabled"
            WindUI:Notify({Title=v and "Smart Action ON" or "Smart Action OFF", Content=desc, Icon=v and "zap" or "x-circle", Duration=3})
        end,
    })

    AutofarmTab:Space()

    SafeCreateToggle(AutofarmTab, {
        Title="Auto Fling Murderer (Bag Full)", Desc="Fling murderer when bag is full (smart action off)",
        Icon="zap", Color=Colors.Murder, Justify="Left", Flag="AutoFlingMurderer",
        Callback=function(v)
            autoFlingMurdererEnabled = v
            WindUI:Notify({Title=v and "Auto Fling ON" or "Auto Fling OFF", Content=v and "Bag dolunca fling!" or "Disabled", Icon=v and "zap" or "x-circle", Duration=2})
        end,
    })

    AutofarmTab:Space()

    AutofarmTab:Section({ Title="Manual Actions", TextSize=16, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateButton(AutofarmTab, {
        Title="Trigger Role Action Now", Desc="Manually trigger bag full action for current role",
        Icon="play", Color=Colors.Accent, Justify="Center",
        Callback=function()
            local saved = smartAutofarmEnabled
            smartAutofarmEnabled = true
            OnBagFull()
            smartAutofarmEnabled = saved
        end,
    })

    AutofarmTab:Space()

    SafeCreateButton(AutofarmTab, {
        Title="🔪 Kill All", Icon="skull", Color=Colors.Murder, Justify="Center",
        Callback=function() AutoKillAll() end,
    })

    SafeCreateButton(AutofarmTab, {
        Title="🔫 Sheriff: TP + Shoot + Return", Icon="crosshair", Color=Colors.Sheriff, Justify="Center",
        Callback=function() AutoSheriffAction() end,
    })

    SafeCreateButton(AutofarmTab, {
        Title="🌪️ Innocent: Fling Murderer", Icon="wind", Color=Colors.Innocent, Justify="Center",
        Callback=function() FlingMurderer() end,
    })

    AutofarmTab:Space()

    SafeCreateSlider(AutofarmTab, {
        Title="Autofarm Speed", Desc="10=slow, 100=fast",
        Icon="zap", Min=10, Max=100, Value=25, Increment=5, Flag="AutofarmSpeed",
        Callback=function(v) autofarmSpeed = v end,
    })

    AutofarmTab:Space()

    SafeCreateSlider(AutofarmTab, {
        Title="Bag Capacity (Bag Full threshold)", Desc="Action triggers when this count is reached",
        Icon="package", Min=5, Max=100, Value=40, Increment=5, Flag="BagCap",
        Callback=function(v) maxCandyCapacity = v end,
    })

    AutofarmTab:Space()

    SafeCreateButton(AutofarmTab, {
        Title="Show Coin Count", Icon="dollar-sign", Color=Colors.Warning, Justify="Center",
        Callback=function()
            WindUI:Notify({Title="Coin Counter", Content="Total: "..coinsCollected.." 💰", Icon="dollar-sign", Duration=3})
        end,
    })
end


local GuideSection = SafeCreateSection(Window, {
    Title = CreateGradientText("GUIDE", Colors.Text, Colors.TextDim), Icon="book-open",
})
local GuideTab = SafeCreateTab(GuideSection, { Title="Info", Icon="info" })

if GuideTab then
    GuideTab:Section({ Title="Welcome", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateButton(GuideTab, {
        Title="Copy Discord Link", Desc="Support server & updates",
        Icon="link", Color=Colors.Accent, Justify="Center",
        Callback=function()
            pcall(function() setclipboard("https://discord.gg/2PPBJsmqr") end)
            WindUI:Notify({Title="Discord", Content="Link copied!", Icon="check-circle", Duration=3})
        end,
    })

    GuideTab:Space()

    SafeCreateButton(GuideTab, {
        Title="Join Discord", Desc="discord.gg/2PPBJsmqr",
        Icon="external-link", Color=Colors.Accent, Justify="Center",
        Callback=function()
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Discord",
                    Text = "discord.gg/2PPBJsmqr",
                    Duration = 10
                })
            end)
        end,
    })

    GuideTab:Space()

    GuideTab:Section({ Title="Features", TextSize=16, FontWeight=Enum.FontWeight.SemiBold })

    local featuresText = Instance.new("TextLabel")
    featuresText.Size = UDim2.new(1, 0, 0, 200)
    featuresText.BackgroundTransparency = 1
    featuresText.Text = [[
Combat:
• Silent Aim (Gun)
• Knife Silent Aim
• Flick Shot
• Aimlock
• Kill All

Visual:
• ESP
• Custom Cursor
• Custom Skybox

Movement:
• Fly
• Noclip
• Speed Glitch
• Bunny Hop

Utility:
• Auto Grab Gun
• Coin Autofarm
• Smart Bag Full
• Bomb Jump
• Fling System
    ]]
    featuresText.TextColor3 = Colors.TextDim
    featuresText.TextSize = 13
    featuresText.Font = Enum.Font.Gotham
    featuresText.TextXAlignment = Enum.TextXAlignment.Left
    featuresText.TextYAlignment = Enum.TextYAlignment.Top
    featuresText.Parent = GuideTab
end

local SettingsSection = SafeCreateSection(Window, {
    Title = CreateGradientText("SETTINGS", Colors.Ghost, Colors.Accent), Icon="settings",
})
local SettingsTab = SafeCreateTab(SettingsSection, { Title="Configuration", Icon="sliders" })

if SettingsTab then
    SettingsTab:Section({ Title="GUI Settings", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    SafeCreateKeybind(SettingsTab, {
        Flag="GUIKeybind", Title="GUI Toggle Key", Desc="Open/close keybind", Value="RightShift",
        Callback=function(key)
            if key then
                Window:SetToggleKey(Enum.KeyCode[key])
                WindUI:Notify({Title="Keybind Set", Content="GUI key set: "..key, Icon="keyboard", Duration=3})
            end
        end,
    })

    SettingsTab:Space()

    SafeCreateToggle(SettingsTab, {
        Title="FPS/Ping Counter", Desc="Top-left corner stats",
        Icon="activity", Color=Colors.Accent, Justify="Left", Flag="ShowStats",
        Callback=function(v) if statsGui then statsGui.Enabled = v end end,
    })

    SettingsTab:Space()

    SafeCreateToggle(SettingsTab, {
        Title="Blur Effect", Icon="droplet", Color=Colors.Accent, Justify="Left", Flag="BlurEffect", Default=false,
        Callback=function(v)
            local bl = Lighting:FindFirstChild("IndraHubBlur")
            if v then
                if not bl then bl = Instance.new("BlurEffect", Lighting) bl.Name = "IndraHubBlur" bl.Size = 10 end
            else
                if bl then bl:Destroy() end
            end
        end,
    })

    SettingsTab:Space()

    SafeCreateToggle(SettingsTab, {
        Title="Color Correction", Icon="sun", Color=Colors.Warning, Justify="Left", Flag="ColorCorrection", Default=false,
        Callback=function(v)
            local cc = Lighting:FindFirstChild("IndraHubCC")
            if v then
                if not cc then
                    cc = Instance.new("ColorCorrectionEffect", Lighting) cc.Name = "IndraHubCC"
                    cc.Brightness=0.05 cc.Contrast=0.1 cc.Saturation=0.2 cc.TintColor=Color3.fromRGB(255,255,255)
                end
            else
                if cc then cc:Destroy() end
            end
        end,
    })

    SettingsTab:Space({Columns=2})

    SettingsTab:Section({ Title="Config Management", TextSize=18, FontWeight=Enum.FontWeight.SemiBold })

    local configName   = "indrahub_default"
    local ConfigManager = Window.ConfigManager

    local configInput = SafeCreateInput(SettingsTab, {
        Flag="ConfigName", Title="Config Name", Icon="file", Value=configName,
        Callback=function(v) if v then configName = v end end,
    })

    SettingsTab:Space()

    local allConfigs = {}
    local cfgOk, cfgRes = pcall(function() return ConfigManager:AllConfigs() end)
    if cfgOk and cfgRes and type(cfgRes)=="table" then allConfigs = cfgRes else allConfigs = {"indrahub_default"} end

    SafeCreateDropdown(SettingsTab, {
        Flag="ConfigSelect", Title="Load Config",
        Values=allConfigs, Value=table.find(allConfigs,configName) and configName or allConfigs[1],
        Callback=function(s)
            if s then configName = s if configInput and configInput.Set then configInput:Set(s) end end
        end,
    })

    SettingsTab:Space()

    SafeCreateButton(SettingsTab, {
        Title="Save", Icon="save", Color=Colors.Success, Justify="Center",
        Callback=function()
            local ok5 = pcall(function() Window.CurrentConfig = ConfigManager:CreateConfig(configName) return Window.CurrentConfig:Save() end)
            WindUI:Notify({Title=ok5 and "Saved" or "Error", Content=ok5 and configName or "Save failed!", Icon=ok5 and "check-circle" or "x-circle", Duration=3})
        end,
    })

    SettingsTab:Space()

    SafeCreateButton(SettingsTab, {
        Title="Load", Icon="upload", Color=Colors.Accent, Justify="Center",
        Callback=function()
            local ok5 = pcall(function() Window.CurrentConfig = ConfigManager:CreateConfig(configName) return Window.CurrentConfig:Load() end)
            WindUI:Notify({Title=ok5 and "Loaded" or "Error", Content=ok5 and configName or "Load failed!", Icon=ok5 and "refresh-cw" or "x-circle", Duration=3})
        end,
    })

    SettingsTab:Space()

    SafeCreateButton(SettingsTab, {
        Title="Delete", Icon="trash-2", Color=Colors.Error, Justify="Center",
        Callback=function()
            local ok5 = pcall(function() Window.CurrentConfig = ConfigManager:CreateConfig(configName) return Window.CurrentConfig:Delete() end)
            WindUI:Notify({Title=ok5 and "Deleted" or "Error", Content=ok5 and configName or "Delete failed!", Icon=ok5 and "check-circle" or "x-circle", Duration=3})
        end,
    })
end

LocalPlayer.CharacterAdded:Connect(function(char)
    character        = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    humanoid         = char:WaitForChild("Humanoid")
    if speedGlitchEnabled then EnableSpeedGlitch() end
    WindUI:Notify({Title="Respawn", Content="Ready! 👻", Icon="user", Duration=2})
end)

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

WindUI:Notify({
    Title   = " IndraHub",
    Content = "Loaded!",
    Icon    = "ghost",
    Duration= 6,
})
