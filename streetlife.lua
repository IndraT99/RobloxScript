local Env = (getgenv and getgenv()) or _G
rawset(Env, "IndraHubStreetLifeRunning", true)
rawset(Env, "IndraHubStreetLifeLastHeartbeat", os.clock())
rawset(Env, "IndraHubStreetLifeError", nil)
task.spawn(function()
    while rawget(Env, "IndraHubStreetLifeRunning") == true do
        rawset(Env, "IndraHubStreetLifeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local function Fetch(url, cacheName)
    if type(readfile) == "function" then
        local ok, cached = pcall(readfile, cacheName)
        if ok and type(cached) == "string" and #cached > 1000 then return cached end
    end
    local source = game:HttpGet(url)
    if type(writefile) == "function" then pcall(writefile, cacheName, source) end
    return source
end

local WindUI = loadstring(Fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_StreetLife_WindUI.lua"))()
if not WindUI then warn("[IndraHub StreetLife] WindUI load failed") return end

local Library = { Options = {}, Toggles = {}, _unloadCallbacks = {}, KeybindFrame = { Visible = false }, CornerRadius = 8, ShowCustomCursor = true }
local Options = Library.Options
local Toggles = Library.Toggles
Library.ShowToggleFrameInKeybinds = true

local function NewOption(id, value)
    local option = { Value = value }
    function option:SetValue(v) self.Value = v end
    function option:SetValues(values) self.Values = values end
    Options[id] = option
    return option
end

local function NewToggle(id, value)
    local toggle = NewOption(id, value == true)
    Toggles[id] = toggle
    return toggle
end

local function WrapControl(control)
    return control or { Set = function() end, Refresh = function() end }
end

local function WrapGroup(tab)
    local group = {}
    function group:AddToggle(id, config)
        local toggle = NewToggle(id, config.Default == true)
        toggle.Control = WrapControl(tab:Toggle({ Title = config.Text or id, Value = toggle.Value, Callback = function(v)
            toggle.Value = v
            if config.Callback then config.Callback(v) end
        end }))
        return toggle
    end
    function group:AddSlider(id, config)
        local option = NewOption(id, config.Default or config.Min or 0)
        local step = config.Rounding and (1 / (10 ^ config.Rounding)) or 1
        option.Control = WrapControl(tab:Slider({ Title = config.Text or id, Value = { Min = config.Min or 0, Max = config.Max or 100, Default = option.Value }, Step = step, Callback = function(v)
            option.Value = v
            if config.Callback then config.Callback(v) end
        end }))
        return option
    end
    function group:AddDropdown(id, config)
        local values = config.Values or {}
        local option = NewOption(id, config.Default or values[1])
        option.Values = values
        function option:SetValues(newValues)
            self.Values = newValues
            if self.Control and self.Control.Refresh then pcall(self.Control.Refresh, self.Control, newValues) end
        end
        option.Control = WrapControl(tab:Dropdown({ Title = config.Text or id, Values = values, Value = option.Value, Callback = function(v)
            option.Value = v
            if config.Callback then config.Callback(v) end
        end }))
        return option
    end
    function group:AddButton(config, callback)
        if type(config) == "table" then
            return tab:Button({ Title = config.Text or config.Title or "Button", Desc = config.Tooltip, Callback = config.Func or config.Callback or function() end })
        end
        return tab:Button({ Title = tostring(config or "Button"), Callback = callback or function() end })
    end
    function group:AddLabel(text)
        if tab.Section then tab:Section({ Title = tostring(text or ""), Icon = "info" }) end
        local label = {}
        function label:AddKeyPicker(id, config)
            local option = NewOption(id, false)
            option.Mode = config.Mode or "Hold"
            option.Key = Enum.KeyCode[config.Default or "E"] or Enum.KeyCode.E
            function option:SetMode(mode) self.Mode = mode end
            function option:GetState() return game:GetService("UserInputService"):IsKeyDown(self.Key) end
            if tab.Keybind then
                option.Control = WrapControl(tab:Keybind({ Title = config.Text or text or id, Value = option.Key, Callback = function(key) option.Key = key end }))
            end
            return option
        end
        function label:AddColorPicker(id, config)
            local option = NewOption(id, config.Default or Color3.fromRGB(255, 255, 255))
            local colorFn = tab.Colorpicker or tab.ColorPicker
            if colorFn then
                option.Control = WrapControl(colorFn(tab, { Title = tostring(text or id), Value = option.Value, Callback = function(color)
                    option.Value = color
                    if config.Callback then config.Callback(color) end
                end }))
            end
            return option
        end
        return label
    end
    function group:AddDivider()
        if tab.Divider then tab:Divider() elseif tab.Section then tab:Section({ Title = " ", Icon = "minus" }) end
    end
    return group
end

function Library:CreateWindow()
    if Env.IndraHubStreetLifeWindow then pcall(function() Env.IndraHubStreetLifeWindow:Destroy() end) end
    local window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "map",
        Author = "StreetLife",
        Folder = "IndraHubStreetLife",
        Size = UDim2.fromOffset(620, 460),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 170,
    })
    Env.IndraHubStreetLifeWindow = window
    pcall(window.SetToggleKey, window, Enum.KeyCode.RightShift)
    pcall(window.EditOpenButton, window, { Title = "IndraHub", Icon = "map", Draggable = true })
    local wrapped = {}
    function wrapped:AddTab(title, icon)
        local tab = window:Tab({ Title = title, Icon = icon or "circle" })
        function tab:AddLeftGroupbox(name, groupIcon) if tab.Section then tab:Section({ Title = name, Icon = groupIcon or "list" }) end return WrapGroup(tab) end
        function tab:AddRightGroupbox(name, groupIcon) if tab.Section then tab:Section({ Title = name, Icon = groupIcon or "list" }) end return WrapGroup(tab) end
        return tab
    end
    function wrapped:SetCornerRadius(value) Library.CornerRadius = value end
    return wrapped
end

function Library:Notify(message, duration)
    local title = type(message) == "table" and (message.Title or "IndraHub StreetLife") or "IndraHub StreetLife"
    local content = type(message) == "table" and (message.Content or message.Description or "") or tostring(message)
    local time = type(message) == "table" and (message.Duration or message.Time) or duration
    pcall(WindUI.Notify, WindUI, { Title = title, Content = content, Icon = "info", Duration = time or 3 })
end
function Library:OnUnload(callback) table.insert(self._unloadCallbacks, callback) end
function Library:Unload() rawset(Env, "IndraHubStreetLifeRunning", false) for _, callback in ipairs(self._unloadCallbacks) do pcall(callback) end if Env.IndraHubStreetLifeWindow then pcall(function() Env.IndraHubStreetLifeWindow:Destroy() end) end end
function Library:SetNotifySide() end
function Library:SetDPIScale() end

local ThemeManager = { SetLibrary = function() end, SetFolder = function() end, ApplyToTab = function() end }
local SaveManager = { SetLibrary = function() end, IgnoreThemeSettings = function() end, SetIgnoreIndexes = function() end, SetFolder = function() end, BuildConfigSection = function() end, LoadAutoloadConfig = function() end }

local Window = Library:CreateWindow({ Title = "IndraHub StreetLife" })

local Tabs = {
    Main      = Window:AddTab("Main",      "shield"),
    Farm      = Window:AddTab("Farm",      "sprout"),
    Player    = Window:AddTab("Player",    "user"),
    Visual    = Window:AddTab("Visual",    "eye"),
    Mics      = Window:AddTab("Mics",      "wrench"),
    Teleport  = Window:AddTab("Teleport",  "map-pin"),
    Custom    = Window:AddTab("Custom",    "star"),
    UiSetting = Window:AddTab("UiSetting", "settings"),
}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local MainLeft = Tabs.Main:AddLeftGroupbox("Info", "info")
MainLeft:AddLabel("IndraHub StreetLife")
MainLeft:AddLabel("Version: 1.0")

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "IndraHubStreetLifeFOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.Parent = LocalPlayer.PlayerGui

local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = (6957-6956)
fovCircle.BorderSizePixel = (492-767+275)
fovCircle.Size = UDim2.fromOffset((10*40+0), (8194+-7794))
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Parent = fovGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new((2609+-2608), (6475-6475))

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB((1957+-1702), bit32.bxor(53907,53868), (30*8+15))
fovStroke.Thickness = 1.2
fovStroke.Transparency = 0.3
fovStroke.Parent = fovCircle

local fovSize = (226-917+891)
local fovMode = "Mouse"

local function getFovOrigin()
    if fovMode == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        local vp = Camera.ViewportSize
        return Vector2.new(vp.X / (3008-3006), vp.Y / (-917-74+993))
    end
end

RunService.RenderStepped:Connect(function()
    local origin = getFovOrigin()
    fovCircle.Position = UDim2.fromOffset(origin.X, origin.Y)
    fovCircle.Size = UDim2.fromOffset(fovSize * (7633+-7631), fovSize * (-150-582+734))
end)

local MainRight = Tabs.Main:AddRightGroupbox("FOV Circle", "circle")
MainRight:AddToggle("FovVisible", {
    Text = "FOV Circle Visible", Default = true,
    Callback = function(v) fovGui.Enabled = v end
})
MainRight:AddSlider("FovSize", {
    Text = "FOV Size", Default = (6*33+2), Min = (4053-4003), Max = bit32.bxor(22792,22780), Rounding = (23-23),
    Callback = function(v) fovSize = v end
})
MainRight:AddDropdown("FovMode", {
    Values = {"Mouse", "Center"}, Default = "Mouse", Text = "FOV Mode",
    Callback = function(v) fovMode = v end
})

local silentAimEnabled  = false
local silentAimFovOnly  = true
local silentAimHL       = false
local silentAimTracer   = false
local currentSilentTarget = nil

local saHighlight = Instance.new("Highlight")
saHighlight.FillColor       = Color3.fromRGB((4973+-4718), bit32.bxor(48882,48832), (46*1+4))
saHighlight.OutlineColor    = Color3.fromRGB((518-287+24), (9895+-9640), (741+-486))
saHighlight.FillTransparency    = 0.4
saHighlight.OutlineTransparency = (-341-239+580)
saHighlight.Enabled = false
saHighlight.Parent  = workspace

local saTracer = Drawing.new("Line")
saTracer.Visible   = false
saTracer.Color     = Color3.fromRGB((30*8+15), (23*2+4), bit32.bxor(60096,60146))
saTracer.Thickness = 1.5
saTracer.Transparency = bit32.bxor(18802,18802)

local function getClosestPlayer()
    local origin = getFovOrigin()
    local bestDist   = silentAimFovOnly and fovSize or math.huge
    local bestHead   = nil
    local bestPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum  = player.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > (5425+-5425) then
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and sp.Z > bit32.bxor(36144,36144) then
                    local dist = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
                    if dist < bestDist then
                        bestDist   = dist
                        bestHead   = head
                        bestPlayer = player
                    end
                end
            end
        end
    end
    return bestHead, bestPlayer
end

local function getClosestHead()
    local head = getClosestPlayer()
    return head
end

RunService.RenderStepped:Connect(function()
    local head, player = getClosestPlayer()
    currentSilentTarget = player

    if silentAimHL and player and player.Character then
        saHighlight.Adornee = player.Character
        saHighlight.Enabled = true
    else
        saHighlight.Enabled = false
        saHighlight.Adornee = nil
    end

    if silentAimTracer and head then
        local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen and sp.Z > (1191+-1191) then
            saTracer.Visible = true
            saTracer.From    = getFovOrigin()
            saTracer.To      = Vector2.new(sp.X, sp.Y)
        else
            saTracer.Visible = false
        end
    else
        saTracer.Visible = false
    end
end)

local aimbotEnabled    = false
local aimbotWallCheck  = false
local aimbotSmoothing  = 0.2
local aimbotFovOnly    = true
local aimbotHoldOnly   = false
local aimbotPrediction = (75-75)
local aimbotTargetPart = "Head"

local function getAimbotTarget()
    local origin = getFovOrigin()
    local bestDist   = aimbotFovOnly and fovSize or math.huge
    local bestPart   = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= (822-822) then continue end
        local part = player.Character:FindFirstChild(aimbotTargetPart)
            or player.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z <= (341-701+360) then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestPart = part
        end
    end
    return bestPart
end

local function aimbotPassesWall(part)
    if not aimbotWallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local dir = part.Position - Camera.CFrame.Position
    local result = workspace:Raycast(Camera.CFrame.Position, dir, params)
    return result == nil
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    if aimbotHoldOnly then
        local holding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            or (UserInputService.TouchEnabled and #UserInputService:GetTouchState() > (1243-1242))
        if not holding then return end
    end
    local part = getAimbotTarget()
    if not part then return end
    if not aimbotPassesWall(part) then return end
    local velocity = Vector3.zero
    local bp = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
    if bp and aimbotPrediction > bit32.bxor(1701,1701) then
        velocity = bp.AssemblyLinearVelocity * aimbotPrediction
    end
    local targetPos = part.Position + velocity
    local camCF     = Camera.CFrame
    local desired   = CFrame.new(camCF.Position, targetPos)
    Camera.CFrame   = camCF:Lerp(desired, aimbotSmoothing)
end)

local MainLeft2 = Tabs.Main:AddLeftGroupbox("Silent Aim", "crosshair")
MainLeft2:AddToggle("SilentAimToggle", {
    Text = "Silent Aim", Default = false,
    Callback = function(v) silentAimEnabled = v end
})
MainLeft2:AddToggle("SilentAimFov", {
    Text = "Only in FOV", Default = true,
    Callback = function(v) silentAimFovOnly = v end
})
MainLeft2:AddToggle("SilentAimHighlight", {
    Text = "Target Highlight", Default = false,
    Callback = function(v) silentAimHL = v end
})
MainLeft2:AddToggle("SilentAimTracer", {
    Text = "FOV Tracer", Default = false,
    Callback = function(v) silentAimTracer = v end
})

local AimbotGroup = Tabs.Main:AddLeftGroupbox("Aimbot", "crosshair")
AimbotGroup:AddToggle("AimbotToggle", {
    Text = "Aimbot", Default = false,
    Callback = function(v) aimbotEnabled = v end
})
AimbotGroup:AddToggle("AimbotFovOnly", {
    Text = "FOV Only", Default = true,
    Callback = function(v) aimbotFovOnly = v end
})
AimbotGroup:AddToggle("AimbotWallCheck", {
    Text = "Wall Check", Default = false,
    Callback = function(v) aimbotWallCheck = v end
})
AimbotGroup:AddToggle("AimbotHoldOnly", {
    Text = "Hold RMB to Aim", Default = false,
    Callback = function(v) aimbotHoldOnly = v end
})
AimbotGroup:AddDropdown("AimbotTargetPart", {
    Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    Default = "Head", Text = "Target Part",
    Callback = function(v) aimbotTargetPart = v end
})
AimbotGroup:AddSlider("AimbotSmoothing", {
    Text = "Smoothing", Default = bit32.bxor(29206,29186), Min = bit32.bxor(21424,21425), Max = (3492-3392), Rounding = (401-888+487),
    Callback = function(v) aimbotSmoothing = v / (4633+-4533) end
})
AimbotGroup:AddSlider("AimbotPrediction", {
    Text = "Prediction", Default = (7-7), Min = (6611+-6611), Max = (9*2+2), Rounding = (-584-383+968),
    Callback = function(v) aimbotPrediction = v / (-568-295+963) end
})

local ok, Projectile = pcall(require, game:GetService("ReplicatedStorage"):WaitForChild("Modules", (1632-1629)) and game:GetService("ReplicatedStorage").Modules:WaitForChild("GunFramework", (-724-203+930)) and game:GetService("ReplicatedStorage").Modules.GunFramework.Modules.Projectile)
if ok and Projectile then
    local originalNew = Projectile.new
    Projectile.new = function(params)
        if silentAimEnabled and params and params.Origin and params.Direction then
            local head = getClosestHead()
            if head then
                params.Direction = (head.Position - params.Origin).Unit
            end
        end
        return originalNew(params)
    end
end

local FarmLeft  = Tabs.Farm:AddLeftGroupbox("Box Job", "sprout")
local FarmRight = Tabs.Farm:AddRightGroupbox("Rob Car", "car")

local boxFarmEnabled = false
local boxFarmThread
local farmSpeed = (90-800+730)

local TAKE_CF = CFrame.new(205.24473571777344, 52.38993453979492, 340.7480773925781)
local DELIVER_WPS = {
    CFrame.new(206.5410919189453,  52.38993453979492, 290.61883544921875),
    CFrame.new(176.30322265625,    53.04217529296875, 289.3236083984375),
    CFrame.new(169.83602905273438, 53.06570053100586, 271.4105224609375),
    CFrame.new(131.48297119140625, 66.79084777832031, 271.680419921875),
    CFrame.new(131.69395446777344, 66.79085540771484, 253.75775146484375),
    CFrame.new(154.1554718017578,  66.99169158935547, 252.99505615234375),
}

local function tweenHRP(targetCF, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    local t = dist / math.max(speed, (30*0+1))
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tw:Play()
    tw.Completed:Wait()
end

local function fireProx(inst)
    local ok2, pp = pcall(function() return inst:FindFirstChildOfClass("ProximityPrompt") end)
    if ok2 and pp then pcall(fireproximityprompt, pp) else pcall(fireproximityprompt, inst) end
end

local function runBoxFarm()
    while boxFarmEnabled do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait((-314-622+937)) continue end
        tweenHRP(TAKE_CF, farmSpeed)
        if not boxFarmEnabled then break end
        task.wait(0.3)
        pcall(function() fireProx(workspace.Map.Jobs.BoxJob.Take.Take.Interact) end)
        task.wait(0.5)
        for _, wp in ipairs(DELIVER_WPS) do
            if not boxFarmEnabled then break end
            tweenHRP(wp, farmSpeed)
            task.wait(0.1)
        end
        if not boxFarmEnabled then break end
        task.wait(0.3)
        pcall(function() fireProx(workspace.Map.Jobs.BoxJob.Deliver.Deliver.Interact) end)
        task.wait(0.5)
        local rev = {}
        for i = #DELIVER_WPS, (9147-9146), -(13*0+1) do rev[#rev+(2640+-2639)] = DELIVER_WPS[i] end
        for _, wp in ipairs(rev) do
            if not boxFarmEnabled then break end
            tweenHRP(wp, farmSpeed)
            task.wait(0.1)
        end
        task.wait(0.2)
    end
end

FarmLeft:AddToggle("BoxFarm", {
    Text = "Box Job Autofarm", Default = false,
    Callback = function(v)
        boxFarmEnabled = v
        if v then
            boxFarmThread = task.spawn(runBoxFarm)
        else
            if boxFarmThread then task.cancel(boxFarmThread) boxFarmThread = nil end
        end
    end
})
FarmLeft:AddSlider("FarmSpeed", {
    Text = "Tween Speed", Default = (3568+-3548), Min = (8736-8735), Max = (87-869+817), Rounding = (-569-43+612), Suffix = " studs/s",
    Callback = function(v) farmSpeed = v end
})

local robCarEnabled = false
local robCarThread
local ROB_SPEED = (47*0+25)
local robCarMode = "Player"
local robCarVehSpeed = (4512+-4362)

local function getRobVehicleSeat()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end
    for _, v in ipairs(vehicles:GetChildren()) do
        if v.Name:lower():find(LocalPlayer.Name:lower()) then
            local ds = v:FindFirstChild("DriveSeat")
            if ds then return ds end
            for _, d in ipairs(v:GetDescendants()) do
                if d:IsA("VehicleSeat") then return d end
            end
        end
    end
    return nil
end

local function tweenVehicleToPos(targetPos, speed)
    local ds = getRobVehicleSeat()
    if not ds then return end
    local model = ds:FindFirstAncestorOfClass("Model")
    local startCF = ds.CFrame
    local targetCF = CFrame.new(targetPos)
    local dist = (startCF.Position - targetCF.Position).Magnitude
    local steps = math.max(math.floor(dist / math.max(speed, (-238-654+893)) * (8368-8308)), (15*0+1))
    for i = (9465+-9464), steps do
        if not ds or not ds.Parent then break end
        local alpha = i / steps
        if model and model.PrimaryPart then
            model:PivotTo(model:GetPivot():Lerp(targetCF, alpha))
        else
            ds.CFrame = startCF:Lerp(targetCF, alpha)
        end
        for _, part in ipairs(ds:GetConnectedParts(true)) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
            end
        end
        task.wait()
    end
end

local function sitInVehicle()
    local ds = getRobVehicleSeat()
    if not ds then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    ds:Sit(hum)
    task.wait(0.3)
end

local function getAllCarWindows()
    local results = {}
    local interactions = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Interactions")
    if not interactions then return results end
    for _, child in ipairs(interactions:GetChildren()) do
        local win = child:FindFirstChild("Window")
        if win then
            local h = win:FindFirstChild("H")
            if h then results[#results+bit32.bxor(27939,27938)] = h end
        end
        local h = child:FindFirstChild("H")
        if h then results[#results+(382-480+99)] = h end
    end
    return results
end

local function findCarWindow(exclude)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge
    for _, h in ipairs(getAllCarWindows()) do
        if h == exclude then continue end
        local pp = h:FindFirstChildOfClass("ProximityPrompt")
        if not pp then
            for _, v in ipairs(h:GetDescendants()) do
                if v:IsA("ProximityPrompt") then pp = v break end
            end
        end
        if pp and pp.Enabled then
            local dist = hrp and (h.Position - hrp.Position).Magnitude or bit32.bxor(60346,60346)
            if dist < bestDist then bestDist = dist best = h end
        end
    end
    if best then return best end
    for _, h in ipairs(getAllCarWindows()) do
        if h == exclude then continue end
        return h
    end
    return nil
end

local function getPromptByText(h, text)
    if not h then return nil end
    for _, v in ipairs(h:GetDescendants()) do
        if v:IsA("ProximityPrompt") and (v.ActionText == text or v.ObjectText == text) then
            return v
        end
    end
    return h:FindFirstChildOfClass("ProximityPrompt")
end

local function pathTween(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = (8209+-8207),
        AgentHeight = (9053+-9048),
        AgentCanJump = true,
        AgentCanClimb = false,
        WaypointSpacing = (2584-2580),
    })

    local ok3 = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
    if not ok3 or path.Status ~= Enum.PathStatus.Success then
        local dist = (hrp.Position - targetPos).Magnitude
        local t = dist / math.max(ROB_SPEED, (-313-234+548))
        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(targetPos) * (hrp.CFrame - hrp.CFrame.Position)
        })
        tw:Play()
        tw.Completed:Wait()
        return
    end

    local waypoints = path:GetWaypoints()
    for _, wp in ipairs(waypoints) do
        if not robCarEnabled then break end
        char = LocalPlayer.Character
        if not char then break end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then break end

        if wp.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end

        local dist = (hrp.Position - wp.Position).Magnitude
        local t = dist / math.max(ROB_SPEED, (28*0+1))
        if t < 0.05 then continue end

        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(wp.Position) * (hrp.CFrame - hrp.CFrame.Position)
        })
        tw:Play()
        tw.Completed:Wait()
        task.wait(0.05)
    end
end

local function runRobCar()
    local lastH = nil
    while robCarEnabled do
        local h = findCarWindow(lastH)
        if not h then task.wait((19*0+2)) continue end
        lastH = h

        local prompt1 = h:FindFirstChildOfClass("ProximityPrompt")
        if not prompt1 then
            for _, v in ipairs(h:GetDescendants()) do
                if v:IsA("ProximityPrompt") then prompt1 = v break end
            end
        end
        if not prompt1 then task.wait((41*0+2)) continue end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait((30*0+1)) continue end

        if robCarMode == "Auto" then
            local vehTarget = h.Position + Vector3.new((96-96), (3294+-3294), bit32.bxor(64403,64404))
            tweenVehicleToPos(vehTarget, robCarVehSpeed)
            if not robCarEnabled then break end
            task.wait(0.1)
        end

        pathTween(h.Position + Vector3.new((604-954+350), bit32.bxor(18483,18481), bit32.bxor(25512,25515)))
        if not robCarEnabled then break end
        task.wait(0.1)

        pcall(fireproximityprompt, prompt1)
        task.wait(1.2)
        if not robCarEnabled then break end

        local grabH = h
        local prompt2 = getPromptByText(grabH, "Grab Cash")
        if not prompt2 then
            for _, v in ipairs(grabH:GetDescendants()) do
                if v:IsA("ProximityPrompt") then prompt2 = v break end
            end
        end

        if prompt2 then
            pathTween(grabH.Position + Vector3.new((6466+-6466), (5-512+509), (48*0+3)))
            if not robCarEnabled then break end
            task.wait(0.1)
            pcall(fireproximityprompt, prompt2)
            task.wait(0.2)

            if prompt2.Enabled == false then
                if robCarMode == "Auto" then
                    sitInVehicle()
                    local nextH = findCarWindow(grabH)
                    if nextH then
                        tweenVehicleToPos(nextH.Position + Vector3.new((5833+-5833), (9889-9889), bit32.bxor(60416,60423)), robCarVehSpeed)
                    end
                end
                lastH = nil
                task.wait(0.05)
                continue
            end
        end

        task.wait(0.1)
    end
end

FarmRight:AddToggle("RobCar", {
    Text = "Rob Car Autofarm", Default = false,
    Callback = function(v)
        robCarEnabled = v
        if v then
            robCarThread = task.spawn(runRobCar)
        else
            if robCarThread then task.cancel(robCarThread) robCarThread = nil end
        end
    end
})
FarmRight:AddDropdown("RobCarMode", {
    Values = {"Player", "Auto"}, Default = "Player", Text = "Rob Mode",
    Callback = function(v) robCarMode = v end
})
FarmRight:AddSlider("RobCarVehSpeed", {
    Text = "Auto Speed", Default = (5984-5834), Min = bit32.bxor(21836,21830), Max = (-76-20+596), Rounding = (100-100), Suffix = " studs/s",
    Callback = function(v) robCarVehSpeed = v end
})

local PlayerLeft = Tabs.Player:AddLeftGroupbox("Movement", "move")

local speedBoostEnabled = false
local speedAmount = (6513-6493)
local speedConn

local function startSpeed()
    if speedConn then speedConn:Disconnect() end
    speedConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > (3791+-3791) then
            hrp.CFrame = hrp.CFrame + dir * speedAmount * 0.016
        end
    end)
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect() speedConn = nil end
end

PlayerLeft:AddToggle("SpeedBoost", {
    Text = "Speed Boost (CFrame)", Default = false,
    Callback = function(v)
        speedBoostEnabled = v
        if v then startSpeed() else stopSpeed() end
    end
})
PlayerLeft:AddSlider("SpeedAmount", {
    Text = "Speed Amount", Default = (9690+-9670), Min = (-191-418+610), Max = (4*8+3), Rounding = bit32.bxor(5075,5075), Suffix = " studs/s",
    Callback = function(v)
        speedAmount = v
        if speedBoostEnabled then startSpeed() end
    end
})

local PlayerLeft2 = Tabs.Player:AddLeftGroupbox("Stamina", "zap")
local staminaEnabled = false
local staminaConn

PlayerLeft2:AddToggle("InfStamina", {
    Text = "Inf Stamina", Default = false,
    Callback = function(v)
        staminaEnabled = v
        if v then
            staminaConn = RunService.Heartbeat:Connect(function()
                pcall(function() LocalPlayer.Data.Stamina.Value = bit32.bxor(9980945,55918) end)
            end)
        else
            if staminaConn then staminaConn:Disconnect() staminaConn = nil end
        end
    end
})

local PlayerRight = Tabs.Player:AddRightGroupbox("CFrame Fly", "wind")

local flyEnabled  = false
local flySpeed    = (4835+-4815)
local flyConn
local flyGui
local flyUp       = false
local flyDown     = false
local thumbLFly   = Vector2.zero

local function makeFlyBtn(parent, lbl, ap, pos, onDown, onUp)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset((9216+-9140), (28*2+20))
    f.AnchorPoint = ap
    f.Position = pos
    f.BackgroundColor3 = Color3.fromRGB((1759+-1749), (8819+-8809), (8072+-8062))
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = (4218+-4218)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new((194-194), bit32.bxor(19214,19228))
    local st = Instance.new("UIStroke", f)
    st.Color = Color3.fromRGB((856-903+247), (495-754+459), (10*20+0))
    st.Transparency = 0.55
    st.Thickness = 1.2
    local tx = Instance.new("TextLabel", f)
    tx.Size = UDim2.fromScale((23*0+1),bit32.bxor(21852,21853))
    tx.BackgroundTransparency = (-562-360+923)
    tx.Text = lbl
    tx.TextColor3 = Color3.new(bit32.bxor(44814,44815),(22*0+1),(6802-6801))
    tx.Font = Enum.Font.GothamBold
    tx.TextSize = (8555+-8525)
    tx.ZIndex = (41*0+2)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.fromScale((7543-7542),(48*0+1))
    btn.BackgroundTransparency = (3575-3574)
    btn.Text = ""
    btn.ZIndex = (48*0+3)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            f.BackgroundTransparency = bit32.bxor(63633,63633)
            onDown()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            f.BackgroundTransparency = 0.15
            onUp()
        end
    end)
end

local function createFlyGui()
    if flyGui then flyGui:Destroy() end
    flyGui = Instance.new("ScreenGui")
    flyGui.Name = "IndraHubStreetLifeFlyGui"
    flyGui.ResetOnSpawn = false
    flyGui.IgnoreGuiInset = true
    flyGui.Parent = LocalPlayer.PlayerGui
    makeFlyBtn(flyGui, "\9650", Vector2.new((2345-2344),(-361-30+392)), UDim2.new((488-840+353),-(6806+-6786),(11*0+1),-(45*4+0)),
        function() flyUp   = true  end,
        function() flyUp   = false end)
    makeFlyBtn(flyGui, "\9660", Vector2.new((38*0+1),(-132-127+260)), UDim2.new((7286+-7285),-(25*0+20),bit32.bxor(6739,6738),-bit32.bxor(37855,37823)),
        function() flyDown = true  end,
        function() flyDown = false end)
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            thumbLFly = Vector2.new(input.Position.X, input.Position.Y)
        end
    end
end)

local function enableFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    flyUp = false
    flyDown = false
    if UserInputService.TouchEnabled then
        createFlyGui()
    end
    flyConn = RunService.RenderStepped:Connect(function(dt)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end

        if hum then
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end

        local cam = Camera
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local flatLook = Vector3.new(look.X, bit32.bxor(34301,34301), look.Z)
        local flatRight = Vector3.new(right.X, (-218-218+436), right.Z)
        if flatLook.Magnitude > bit32.bxor(34621,34621) then flatLook = flatLook.Unit end
        if flatRight.Magnitude > (575-575) then flatRight = flatRight.Unit end

        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= flatRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += flatRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) or flyUp then dir += Vector3.new((-551-323+874),bit32.bxor(35185,35184),bit32.bxor(48402,48402)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or flyDown then dir += Vector3.new((7421+-7421),-(5086-5085),(-808-80+888)) end

        if thumbLFly.Magnitude > 0.15 then
            dir += flatLook * thumbLFly.Y + flatRight * thumbLFly.X
        end

        if UserInputService.TouchEnabled and hum then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0.1 then
                dir += Vector3.new(moveDir.X, (17-17), moveDir.Z)
            end
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if dir.Magnitude > bit32.bxor(46807,46807) then
            hrp.CFrame = hrp.CFrame + dir.Unit * flySpeed * dt
        end
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyGui then flyGui:Destroy() flyGui = nil end
    flyUp = false
    flyDown = false
    thumbLFly = Vector2.zero
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

PlayerRight:AddToggle("FlyToggle", {
    Text = "CFrame Fly", Default = false,
    Callback = function(v)
        flyEnabled = v
        if v then enableFly() else disableFly() end
    end
})
PlayerRight:AddSlider("FlySpeed", {
    Text = "Fly Speed", Default = (7530+-7510), Min = (9767+-9766), Max = bit32.bxor(58665,58701), Rounding = bit32.bxor(56989,56989), Suffix = " studs/s",
    Callback = function(v) flySpeed = v end
})

local PlayerRight2 = Tabs.Player:AddRightGroupbox("Vehicle Fly", "car")

local vflyEnabled = false
local vflySpeed   = (101-910+869)
local vflyConn
local vflyGui
local vflyUp      = false
local vflyDown    = false
local vthumbL     = Vector2.zero

local function createVFlyGui()
    if vflyGui then vflyGui:Destroy() end
    vflyGui = Instance.new("ScreenGui")
    vflyGui.Name = "IndraHubStreetLifeVFlyGui"
    vflyGui.ResetOnSpawn = false
    vflyGui.IgnoreGuiInset = true
    vflyGui.Parent = LocalPlayer.PlayerGui
    makeFlyBtn(vflyGui, "\9650", Vector2.new((8389+-8389),(2586-2585)), UDim2.new((66-66),(3302-3282),(-130-634+765),-(8447+-8267)),
        function() vflyUp   = true  end,
        function() vflyUp   = false end)
    makeFlyBtn(vflyGui, "\9660", Vector2.new(bit32.bxor(64302,64302),(3895+-3894)), UDim2.new((40-40),(-22-133+175),(4452+-4451),-(37*2+22)),
        function() vflyDown = true  end,
        function() vflyDown = false end)
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            vthumbL = Vector2.new(input.Position.X, input.Position.Y)
        end
    end
end)

local function getVehicleSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("VehicleSeat") then return seat end
    return nil
end

local function getVehicleModel(seat)
    if not seat then return nil end
    return seat:FindFirstAncestorOfClass("Model")
end

local function enableVFly()
    if vflyConn then vflyConn:Disconnect() vflyConn = nil end
    vflyUp = false
    vflyDown = false

    if UserInputService.TouchEnabled then createVFlyGui() end

    vflyConn = RunService.Heartbeat:Connect(function(dt)
        local seat = getVehicleSeat()
        if not seat then return end

        local model = getVehicleModel(seat)
        local root = model and (model.PrimaryPart or seat)
        if not root then return end

        local cam = Camera
        local look  = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local flatLook  = Vector3.new(look.X, (71-71), look.Z)
        local flatRight = Vector3.new(right.X, (64-64), right.Z)
        if flatLook.Magnitude > (3-3) then flatLook = flatLook.Unit end
        if flatRight.Magnitude > (3255-3255) then flatRight = flatRight.Unit end

        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= flatRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += flatRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) or vflyUp then dir += Vector3.new((8694-8694),bit32.bxor(21442,21443),(8056+-8056)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or vflyDown then dir += Vector3.new(bit32.bxor(14052,14052),-bit32.bxor(51228,51229),(3795+-3795)) end

        if vthumbL.Magnitude > 0.15 then
            dir += flatLook * vthumbL.Y + flatRight * vthumbL.X
        end

        if UserInputService.TouchEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    dir += Vector3.new(moveDir.X, (8914-8914), moveDir.Z)
                end
            end
        end

        if dir.Magnitude > (501-708+207) then
            local delta = dir.Unit * vflySpeed * dt
            if model and model.PrimaryPart then
                model:PivotTo(model:GetPivot() + delta)
            else
                root.CFrame = root.CFrame + delta
            end
        end

        for _, part in ipairs(root:GetConnectedParts(true)) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local function disableVFly()
    if vflyConn then vflyConn:Disconnect() vflyConn = nil end
    if vflyGui  then vflyGui:Destroy()  vflyGui  = nil end
    vflyUp    = false
    vflyDown  = false
    vthumbL   = Vector2.zero
end

PlayerRight2:AddToggle("VehicleFly", {
    Text = "Vehicle Fly", Default = false,
    Callback = function(v)
        vflyEnabled = v
        if v then enableVFly() else disableVFly() end
    end
})
PlayerRight2:AddSlider("VehicleFlySpeed", {
    Text = "Vehicle Fly Speed", Default = (8927-8867), Min = (9108+-9107), Max = (5968-5668), Rounding = (4879-4879), Suffix = " studs/s",
    Callback = function(v) vflySpeed = v end
})

local PlayerRight3 = Tabs.Player:AddRightGroupbox("Vehicle", "car")
PlayerRight3:AddButton({
    Text = "Enter Own Car",
    Func = function()
        sitInVehicle()
    end,
    Tooltip = "Sit in your vehicle's DriveSeat"
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait((9616-9615))
    if flyEnabled then enableFly() end
    if vflyEnabled then enableVFly() end
    if speedBoostEnabled then startSpeed() end
    if staminaEnabled then
        if staminaConn then staminaConn:Disconnect() end
        staminaConn = RunService.Heartbeat:Connect(function()
            pcall(function() LocalPlayer.Data.Stamina.Value = (16*624999+15) end)
        end)
    end
end)

local VisualLeft  = Tabs.Visual:AddLeftGroupbox("ESP", "eye")
local VisualRight = Tabs.Visual:AddRightGroupbox("ESP Colors", "palette")

local ESP = {
    Box = false, Healthbar = false, HealthText = false, Name = false,
    Distance = false, Backpack = false, Weapon = false, Skeleton = false, Chams = false,
}

local espColor  = Color3.fromRGB((641+-386), bit32.bxor(13033,12822), (9291+-9036))
local chamColor = Color3.fromRGB((424+-169), (3487+-3437), (6*8+2))
local espObjects = {}

local SKEL_JOINTS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function newDraw(type, props)
    local obj = Drawing.new(type)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

local function removeESP(player)
    local d = espObjects[player]
    if not d then return end
    for _, obj in pairs(d) do
        if typeof(obj) == "table" then
            for _, line in pairs(obj) do pcall(function() line:Remove() end) end
        else
            pcall(function() obj:Remove() end)
        end
    end
    espObjects[player] = nil
end

local function buildESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    local d = {}
    d.box      = newDraw("Square", { Visible=false, Filled=false, Color=espColor, Thickness=(29*0+2) })
    d.hpBg     = newDraw("Square", { Visible=false, Filled=true,  Color=Color3.fromRGB((15-759+744),(1317-1317),(-409-297+706)), Thickness=(982+-981) })
    d.hpBar    = newDraw("Square", { Visible=false, Filled=true,  Color=Color3.fromRGB(bit32.bxor(24792,24810),(9947-9692),(-280-349+679)), Thickness=bit32.bxor(2281,2280) })
    d.hpText   = newDraw("Text",   { Visible=false, Center=true,  Color=Color3.new((164-384+221),(196-778+583),(11*0+1)), Size=(12*1+1), Font=(3493-3491), Outline=true })
    d.nameText = newDraw("Text",   { Visible=false, Center=true,  Color=espColor, Size=(571-783+226), Font=(496-959+465), Outline=true })
    d.distText = newDraw("Text",   { Visible=false, Center=true,  Color=Color3.fromRGB((713-989+476),bit32.bxor(45284,45100),(8046-7846)), Size=(29*0+12), Font=(33*0+2), Outline=true })
    d.bpText   = newDraw("Text",   { Visible=false, Center=true,  Color=Color3.fromRGB((25*10+5),(4553-4353),bit32.bxor(43698,43698)), Size=(2341+-2329), Font=(578+-576), Outline=true })
    d.wpText   = newDraw("Text",   { Visible=false, Center=true,  Color=Color3.fromRGB((8413+-8313),(1001-801),(21*12+3)), Size=bit32.bxor(10922,10918), Font=bit32.bxor(20704,20706), Outline=true })
    d.skelLines = {}
    for i = (1633+-1632), #SKEL_JOINTS do
        d.skelLines[i] = newDraw("Line", { Visible=false, Color=espColor, Thickness=(3375+-3374) })
    end
    d.chamParts = {}
    espObjects[player] = d
end

local function applyChams(player, enable)
    local d = espObjects[player]
    if not d then return end
    for _, p in pairs(d.chamParts) do
        pcall(function() p.Material = Enum.Material.SmoothPlastic end)
    end
    d.chamParts = {}
    if not enable then return end
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                part.Material = Enum.Material.Neon
                part.Color = chamColor
            end)
            d.chamParts[#d.chamParts+bit32.bxor(34915,34914)] = part
        end
    end
end

local function hideAll(d)
    for _, obj in pairs(d) do
        if typeof(obj) == "table" then
            for _, line in pairs(obj) do pcall(function() line.Visible = false end) end
        else
            pcall(function() obj.Visible = false end)
        end
    end
end

local function getCharBoundsOnScreen(char)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyOnScreen = false
    local partsChecked = bit32.bxor(13234,13234)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local size = part.Size
            local cf   = part.CFrame
            local corners = {
                cf * CFrame.new( size.X/(5*0+2),  size.Y/(3449-3447),  size.Z/(46*0+2)),
                cf * CFrame.new(-size.X/(50*0+2),  size.Y/(10*0+2),  size.Z/(3514-3512)),
                cf * CFrame.new( size.X/(-798-6+806), -size.Y/(11*0+2),  size.Z/(-943-31+976)),
                cf * CFrame.new(-size.X/bit32.bxor(39779,39777), -size.Y/(5584+-5582),  size.Z/(3727-3725)),
                cf * CFrame.new( size.X/(7217+-7215),  size.Y/(34-611+579), -size.Z/(193-368+177)),
                cf * CFrame.new(-size.X/(24*0+2),  size.Y/(177-175), -size.Z/bit32.bxor(60503,60501)),
                cf * CFrame.new( size.X/(7013-7011), -size.Y/(6981-6979), -size.Z/(2282+-2280)),
                cf * CFrame.new(-size.X/(-5-407+414), -size.Y/(9363+-9361), -size.Z/(24*0+2)),
            }
            for _, cornerCF in ipairs(corners) do
                local sp, onScreen = Camera:WorldToViewportPoint(cornerCF.Position)
                if onScreen and sp.Z > (1-1) then
                    anyOnScreen = true
                    if sp.X < minX then minX = sp.X end
                    if sp.Y < minY then minY = sp.Y end
                    if sp.X > maxX then maxX = sp.X end
                    if sp.Y > maxY then maxY = sp.Y end
                end
            end
            partsChecked += bit32.bxor(64867,64866)
        end
    end
    if not anyOnScreen or partsChecked == (8190-8190) then return nil end
    local pad = bit32.bxor(3162,3161)
    return minX - pad, minY - pad, maxX + pad, maxY + pad
end

local function updateESP(player, d)
    local char = player.Character
    if not char then hideAll(d) return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hrp or not hum or not head then hideAll(d) return end

    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local dist = lhrp and math.floor((hrp.Position - lhrp.Position).Magnitude) or (1235-1235)

    local rootSP, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then hideAll(d) return end

    local minX, minY, maxX, maxY = getCharBoundsOnScreen(char)
    local boxX, boxY, boxW, boxH
    if minX then
        boxX = minX
        boxY = minY
        boxW = maxX - minX
        boxH = maxY - minY
    else
        local headSP = Camera:WorldToViewportPoint(head.Position)
        local scaleFactor = (4321+-4320) / math.max(rootSP.Z, 0.1) * (919-819)
        boxH = math.clamp(scaleFactor * 5.8, bit32.bxor(42721,42751), (5997-5497))
        boxW = boxH * 0.55
        boxX = rootSP.X - boxW / (251-878+629)
        boxY = headSP.Y - bit32.bxor(64406,64402)
    end

    d.box.Visible   = ESP.Box
    d.box.Position  = Vector2.new(boxX, boxY)
    d.box.Size      = Vector2.new(boxW, boxH)
    d.box.Color     = espColor
    d.box.Thickness = (8638+-8636)

    local hp    = math.clamp(hum.Health, (-589-51+640), hum.MaxHealth)
    local hpPct = hum.MaxHealth > (698-698) and hp / hum.MaxHealth or (96-96)
    local barH  = boxH
    local barX  = boxX - (8692-8685)
    d.hpBg.Visible   = ESP.Healthbar
    d.hpBg.Position  = Vector2.new(barX - (696-774+79), boxY - bit32.bxor(15187,15186))
    d.hpBg.Size      = Vector2.new((3757+-3752), barH + (429-502+75))
    d.hpBar.Visible  = ESP.Healthbar
    d.hpBar.Position = Vector2.new(barX, boxY + barH * (bit32.bxor(52937,52936) - hpPct))
    d.hpBar.Size     = Vector2.new((33*0+4), barH * hpPct)
    d.hpBar.Color    = Color3.fromRGB(math.floor(bit32.bxor(42802,42957)*(bit32.bxor(3309,3308)-hpPct)), math.floor((6882-6627)*hpPct), (26-26))

    d.hpText.Visible  = ESP.HealthText
    d.hpText.Text     = math.floor(hp) .. " HP"
    d.hpText.Position = Vector2.new(boxX + boxW/(2997-2995), boxY + boxH + (481-680+201))

    d.nameText.Visible  = ESP.Name
    d.nameText.Text     = player.DisplayName
    d.nameText.Position = Vector2.new(boxX + boxW/(42*0+2), boxY - (4560+-4544))
    d.nameText.Color    = espColor

    d.distText.Visible  = ESP.Distance
    d.distText.Text     = dist .. " m"
    d.distText.Position = Vector2.new(boxX + boxW/(6594+-6592), boxY + boxH + (9*1+5))

    local textY = boxY - (641-755+130)
    if ESP.Name then textY -= (7333-7319) end

    local bp = player.Backpack
    local bpList = {}
    if bp then for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") then bpList[#bpList+(16*0+1)] = t.Name end end end
    d.bpText.Visible  = ESP.Backpack and #bpList > (-94-61+155)
    d.bpText.Text     = "BP: " .. table.concat(bpList, ", ")
    d.bpText.Position = Vector2.new(boxX + boxW/bit32.bxor(15222,15220), textY - (159-770+623))
    if ESP.Backpack and #bpList > bit32.bxor(64373,64373) then textY -= (6217+-6205) end

    local equipped = char:FindFirstChildOfClass("Tool")
    d.wpText.Visible  = ESP.Weapon and equipped ~= nil
    d.wpText.Text     = equipped and equipped.Name or ""
    d.wpText.Position = Vector2.new(boxX + boxW/(17*0+2), textY - (4441-4429))

    for i, pair in ipairs(SKEL_JOINTS) do
        local line = d.skelLines[i]
        local p0   = char:FindFirstChild(pair[bit32.bxor(64533,64532)])
        local p1   = char:FindFirstChild(pair[(9773-9771)])
        if ESP.Skeleton and p0 and p1 then
            local s0, v0 = Camera:WorldToViewportPoint(p0.Position)
            local s1, v1 = Camera:WorldToViewportPoint(p1.Position)
            line.Visible = v0 and v1
            line.From    = Vector2.new(s0.X, s0.Y)
            line.To      = Vector2.new(s1.X, s1.Y)
            line.Color   = espColor
        else
            line.Visible = false
        end
    end
end

local espRenderConn

local function startESP()
    for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
    espRenderConn = RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not espObjects[p] then buildESP(p) end
            updateESP(p, espObjects[p])
        end
    end)
    Players.PlayerAdded:Connect(buildESP)
    Players.PlayerRemoving:Connect(removeESP)
end

local function stopESP()
    if espRenderConn then espRenderConn:Disconnect() espRenderConn = nil end
    for _, p in ipairs(Players:GetPlayers()) do removeESP(p) end
end

local function refreshChams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then applyChams(p, ESP.Chams) end
    end
end

local anyESP = false
local function checkESP()
    local wasOn = anyESP
    anyESP = ESP.Box or ESP.Healthbar or ESP.HealthText or ESP.Name or
             ESP.Distance or ESP.Backpack or ESP.Weapon or ESP.Skeleton
    if anyESP and not wasOn then startESP()
    elseif not anyESP and wasOn then stopESP() end
end

local function addESPToggle(name, key, text)
    VisualLeft:AddToggle(name, {
        Text = text, Default = false,
        Callback = function(v) ESP[key] = v checkESP() end
    })
end

addESPToggle("ESPBox",        "Box",        "Box")
addESPToggle("ESPHealthbar",  "Healthbar",  "Healthbar")
addESPToggle("ESPHealthText", "HealthText", "Health Text")
addESPToggle("ESPName",       "Name",       "Name")
addESPToggle("ESPDistance",   "Distance",   "Distance")
addESPToggle("ESPBackpack",   "Backpack",   "Backpack ESP")
addESPToggle("ESPWeapon",     "Weapon",     "Weapon ESP")
addESPToggle("ESPSkeleton",   "Skeleton",   "Skeleton")

VisualLeft:AddToggle("ESPChams", {
    Text = "Chams", Default = false,
    Callback = function(v) ESP.Chams = v refreshChams() end
})

VisualRight:AddLabel("ESP Color"):AddColorPicker("ESPColor", {
    Default = Color3.fromRGB((764+-509),(2974+-2719),(5722+-5467)),
    Callback = function(v) espColor = v end
})
VisualRight:AddLabel("Chams Color"):AddColorPicker("ChamColor", {
    Default = Color3.fromRGB((2625+-2370),(6*8+2),bit32.bxor(30831,30813)),
    Callback = function(v) chamColor = v if ESP.Chams then refreshChams() end end
})

local MicsLeft  = Tabs.Mics:AddLeftGroupbox("Server", "server")
local MicsRight = Tabs.Mics:AddRightGroupbox("ATM", "dollar-sign")

MicsRight:AddSlider("ATMWithdrawAmount", {
    Text = "Withdraw Amount", Default = (16891-6884), Min = (9179-9178), Max = (102283-2283), Rounding = (4132+-4132),
})
MicsRight:AddButton({
    Text = "Withdraw",
    Func = function()
        local amt = Options.ATMWithdrawAmount.Value
        game:GetService("ReplicatedStorage").Remotes.ATM:FireServer("Withdraw", amt)
    end,
    Tooltip = "Withdraw money from ATM"
})
MicsRight:AddDivider()
MicsRight:AddSlider("ATMDepositAmount", {
    Text = "Deposit Amount", Default = (4272-975+718), Min = bit32.bxor(44458,44459), Max = (103867-3867), Rounding = (531-837+306),
})
MicsRight:AddButton({
    Text = "Deposit",
    Func = function()
        local amt = Options.ATMDepositAmount.Value
        game:GetService("ReplicatedStorage").Remotes.ATM:FireServer("Deposit", amt)
    end,
    Tooltip = "Deposit money to ATM"
})

MicsLeft:AddButton({
    Text = "Instant ProximityPrompt",
    Func = function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled then
                local part = v.Parent
                if part and part:IsA("BasePart") then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist <= v.MaxActivationDistance + (402-981+629) then
                        pcall(fireproximityprompt, v)
                    end
                end
            end
        end
    end,
    Tooltip = "Fires all nearby proximity prompts instantly"
})

MicsLeft:AddButton({
    Text = "Server Hop",
    Func = function()
        local placeId = game.PlaceId
        local servers = {}
        local ok4 = pcall(function()
            local decoded = HttpService:JSONDecode(game:HttpGetAsync(
                ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
            ))
            for _, s in ipairs(decoded.data) do
                if s.playing < s.maxPlayers then servers[#servers+(2424+-2423)] = s.id end
            end
        end)
        if ok4 and #servers > (91-91) then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random((1047-1046),#servers)], LocalPlayer)
        else
            TeleportService:Teleport(placeId, LocalPlayer)
        end
    end,
    Tooltip = "Hops to a different server"
})

MicsLeft:AddButton({
    Text = "Rejoin Server",
    Func = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
    Tooltip = "Rejoins the current server"
})

local TpLeft  = Tabs.Teleport:AddLeftGroupbox("Player Teleport", "user")
local TpRight = Tabs.Teleport:AddRightGroupbox("Vehicle TP", "car")

local function getMyVehicleSeat()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end
    for _, v in ipairs(vehicles:GetChildren()) do
        if v.Name:lower():find(LocalPlayer.Name:lower()) then
            local ds = v:FindFirstChild("DriveSeat")
            if ds then return ds end
            for _, d in ipairs(v:GetDescendants()) do
                if d:IsA("VehicleSeat") then return d end
            end
        end
    end
    return nil
end

local function getPlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then names[#names+(24*0+1)] = p.Name end
    end
    return names
end

local selectedTpPlayer = nil

TpLeft:AddDropdown("TpPlayerSelect", {
    Values = getPlayerList(),
    Default = (-313-4+318),
    Text = "Select Player",
    Callback = function(v) selectedTpPlayer = v end,
})

TpLeft:AddButton({
    Text = "Refresh List",
    Func = function()
        local names = getPlayerList()
        Options.TpPlayerSelect:SetValues(names)
        if #names > (8478+-8478) then Options.TpPlayerSelect:SetValue(names[(4809+-4808)]) end
    end,
    Tooltip = "Refresh the player list"
})

local TpLocations = Tabs.Teleport:AddLeftGroupbox("Locations", "map-pin")

local LOCATIONS = {
    { "Box Job",     Vector3.new(224.9457550048828,  52.297630310058594, 306.7882080078125)  },
    { "Gun Store",   Vector3.new(606.1477661132812,  52.297630310058594, -372.3825988769531) },
    { "Dealership",  Vector3.new(484.2879638671875,  52.297630310058594, 64.97356414794922)  },
    { "Bank",        Vector3.new(397.7641296386719,  52.29762649536133,  61.28957748413086)  },
}

for _, loc in ipairs(LOCATIONS) do
    local name, pos = loc[(9896-9895)], loc[(4914-4912)]
    TpLocations:AddButton({
        Text = name,
        Func = function()
            sitInVehicle()
            tweenVehicleToPos(pos + Vector3.new((232-232), (839-838), bit32.bxor(162,162)), robCarVehSpeed)
        end,
        Tooltip = "Tween vehicle to " .. name
    })
end

local vTweenSpeed = bit32.bxor(450,402)

local function tweenDriveSeat(ds, targetCF)
    local startCF = ds.CFrame
    local dist    = (startCF.Position - targetCF.Position).Magnitude
    local steps   = math.max(math.floor(dist / vTweenSpeed * (732+-672)), (1139-1138))
    for i = (38*0+1), steps do
        if not ds or not ds.Parent then break end
        local alpha = i / steps
        ds.CFrame = startCF:Lerp(targetCF, alpha)
        task.wait()
    end
    if ds and ds.Parent then
        ds.CFrame = targetCF
    end
end

TpRight:AddSlider("VTweenSpeed", {
    Text = "Tween Speed", Default = (168-954+866), Min = (195-579+394), Max = (840-826+486), Rounding = (8653-8653), Suffix = " studs/s",
    Callback = function(v) vTweenSpeed = v end
})
TpRight:AddDivider()

TpRight:AddButton({
    Text = "Tween Car to Player",
    Func = function()
        if not selectedTpPlayer then
            Library:Notify({ Title = "Teleport", Description = "No player selected!", Time = (39*0+3) })
            return
        end
        local target = Players:FindFirstChild(selectedTpPlayer)
        if not target or not target.Character then
            Library:Notify({ Title = "Teleport", Description = "Player not found or no character!", Time = (249-528+282) })
            return
        end
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local ds = getMyVehicleSeat()
        if not ds then
            Library:Notify({ Title = "Teleport", Description = "No vehicle found!", Time = (6*0+4) })
            return
        end
        local targetCF = targetHRP.CFrame * CFrame.new((50*0+4), (-63-574+637), (626-740+114))
        task.spawn(tweenDriveSeat, ds, targetCF)
    end,
    Tooltip = "Smoothly tween your car to the selected player"
})

TpRight:AddButton({
    Text = "Tween Car to Me",
    Func = function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ds = getMyVehicleSeat()
        if not ds then
            Library:Notify({ Title = "Teleport", Description = "No vehicle found!", Time = bit32.bxor(27957,27958) })
            return
        end
        local targetCF = hrp.CFrame * CFrame.new((691+-687), (50-50), (3447-3447))
        task.spawn(tweenDriveSeat, ds, targetCF)
    end,
    Tooltip = "Smoothly tween your car next to yourself"
})

local rainbowEnabled = false
local headlessEnabled = false
local rainbowHue = (6878-6878)

local function applyHeadless(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    for _, part in ipairs(head:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("SpecialMesh") then
            part.Transparency = enabled and (42*0+1) or (5256+-5256)
        end
    end
    head.Transparency = enabled and (-348-376+725) or (7348+-7348)
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local att = acc:FindFirstChild("HatAttachment")
                or acc:FindFirstChild("HairAttachment")
                or acc:FindFirstChild("FaceFrontAttachment")
                or acc:FindFirstChild("FaceRearAttachment")
            if att then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = enabled and (8*0+1) or (37-37)
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait((704-966+263))
    if headlessEnabled then applyHeadless(true) end
end)

RunService.RenderStepped:Connect(function()
    if not rainbowEnabled then return end
    rainbowHue = (rainbowHue + 0.002) % (9164+-9163)
    local color = Color3.fromHSV(rainbowHue, (3*0+1), (5*0+1))
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "Head" then
            part.Color = color
        end
    end
end)

local CustomLeft = Tabs.Custom:AddLeftGroupbox("Appearance", "user")
CustomLeft:AddToggle("HeadlessToggle", {
    Text = "Headless", Default = false,
    Callback = function(v)
        headlessEnabled = v
        applyHeadless(v)
    end
})
CustomLeft:AddToggle("RainbowToggle", {
    Text = "Rainbow Body", Default = false,
    Callback = function(v)
        rainbowEnabled = v
        if not v then
            local char = LocalPlayer.Character
            if not char then return end
            local desc = LocalPlayer:GetHumanoidDescription()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:ApplyDescription(desc) end)
            end
        end
    end
})

local MenuGroup = Tabs.UiSetting:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor", Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = {"Left","Right"}, Default = "Right", Text = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end
})
MenuGroup:AddDropdown("DPIDropdown", {
    Values = {"50%","75%","100%","125%","150%","175%","200%"}, Default = "100%", Text = "DPI Scale",
    Callback = function(v)
        v = v:gsub("%%","")
        Library:SetDPIScale(tonumber(v))
    end
})
MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius", Default = Library.CornerRadius, Min = (2427+-2427), Max = bit32.bxor(34288,34276), Rounding = bit32.bxor(35116,35116),
    Callback = function(v) Window:SetCornerRadius(v) end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton({ Text = "Unload", Func = function() Library:Unload() end })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("IndraHub/StreetLife")
SaveManager:SetFolder("IndraHub/StreetLife/configs")
SaveManager:BuildConfigSection(Tabs.UiSetting)
ThemeManager:ApplyToTab(Tabs.UiSetting)
SaveManager:LoadAutoloadConfig()


