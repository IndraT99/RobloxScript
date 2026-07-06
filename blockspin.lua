local Env = (getgenv and getgenv()) or _G

local function Fetch(url, cacheName)
        if type(readfile) == "function" then
                local ok, cached = pcall(readfile, cacheName)
                if ok and type(cached) == "string" and #cached > 1000 then return cached end
        end
        local source = game:HttpGet(url)
        if type(writefile) == "function" then pcall(writefile, cacheName, source) end
        return source
end

local WindUI = loadstring(Fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_BlockSpin_WindUI.lua"))()
if not WindUI then warn("[IndraHub BlockSpin] WindUI load failed") return end

local Library = { Options = {}, Toggles = {}, _unloadCallbacks = {}, KeybindFrame = { Visible = false }, CornerRadius = 8, ShowCustomCursor = true }
local Options = Library.Options
local Toggles = Library.Toggles

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
                local control = WrapControl(tab:Toggle({ Title = config.Text or id, Value = toggle.Value, Callback = function(v)
                        toggle.Value = v
                        if config.Callback then config.Callback(v) end
                end }))
                toggle.Control = control
                return toggle
        end
        function group:AddSlider(id, config)
                local option = NewOption(id, config.Default or config.Min or 0)
                local step = config.Rounding and (1 / (10 ^ config.Rounding)) or 1
                local control = WrapControl(tab:Slider({ Title = config.Text or id, Value = { Min = config.Min or 0, Max = config.Max or 100, Default = option.Value }, Step = step, Callback = function(v)
                        option.Value = v
                        if config.Callback then config.Callback(v) end
                end }))
                option.Control = control
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
                local control = WrapControl(tab:Dropdown({ Title = config.Text or id, Values = values, Value = option.Value, Callback = function(v)
                        option.Value = v
                        if config.Callback then config.Callback(v) end
                end }))
                option.Control = control
                return option
        end
        function group:AddButton(text, callback)
                return tab:Button({ Title = text, Callback = callback })
        end
        function group:AddLabel(text)
                if tab.Section then tab:Section({ Title = text, Icon = "info" }) end
                local label = {}
                function label:AddKeyPicker(id, config)
                        local option = NewOption(id, false)
                        option.Mode = config.Mode or "Hold"
                        option.Key = Enum.KeyCode[config.Default or "E"] or Enum.KeyCode.E
                        function option:SetMode(mode) self.Mode = mode end
                        function option:GetState()
                                return game:GetService("UserInputService"):IsKeyDown(self.Key)
                        end
                        if tab.Keybind then
                                option.Control = WrapControl(tab:Keybind({ Title = config.Text or text or id, Value = option.Key, Callback = function(key)
                                        option.Key = key
                                end }))
                        end
                        return option
                end
                function label:AddColorPicker(id, config)
                        local option = NewOption(id, config.Default or Color3.fromRGB(255, 255, 255))
                        local colorFn = tab.Colorpicker or tab.ColorPicker
                        if colorFn then
                                option.Control = WrapControl(colorFn(tab, { Title = text or id, Value = option.Value, Callback = function(color)
                                        option.Value = color
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

function Library:CreateWindow(config)
        if Env.IndraHubBlockSpinWindow then pcall(function() Env.IndraHubBlockSpinWindow:Destroy() end) end
        local window = WindUI:CreateWindow({
                Title = "IndraHub",
                Icon = "box",
                Author = "BlockSpin",
                Folder = "IndraHubBlockSpin",
                Size = UDim2.fromOffset(620, 460),
                Transparent = true,
                Theme = "Dark",
                Resizable = true,
                SideBarWidth = 170,
        })
        Env.IndraHubBlockSpinWindow = window
        pcall(window.SetToggleKey, window, Enum.KeyCode.RightShift)
        pcall(window.EditOpenButton, window, { Title = "IndraHub", Icon = "box", Draggable = true })
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
        local content = type(message) == "table" and (message.Content or message.Title or "") or tostring(message)
        pcall(WindUI.Notify, WindUI, { Title = "IndraHub BlockSpin", Content = content, Icon = "info", Duration = duration or 3 })
end
function Library:OnUnload(callback) table.insert(self._unloadCallbacks, callback) end
function Library:Unload() for _, callback in ipairs(self._unloadCallbacks) do pcall(callback) end if Env.IndraHubBlockSpinWindow then pcall(function() Env.IndraHubBlockSpinWindow:Destroy() end) end end
function Library:SetNotifySide() end
function Library:SetDPIScale() end

local Window = Library:CreateWindow({ Title = "IndraHub BlockSpin" })

local Tabs = {

        Autofarm        = Window:AddTab("Autofarm",    "wheat"),

        Player          = Window:AddTab("Player",      "user"),

        Aimbot          = Window:AddTab("Aimbot",      "crosshair"),

        ESP             = Window:AddTab("ESP",         "eye"),

        Misc            = Window:AddTab("Misc",        "wrench"),

        Teleport        = Window:AddTab("Teleport",    "map-pin"),

        General         = Window:AddTab("Settings",    "sliders-horizontal"),

        ["UI Settings"] = Window:AddTab("UI Settings", "settings"),

}

local Players            = game:GetService("Players")

local PathfindingService = game:GetService("PathfindingService")

local TweenService       = game:GetService("TweenService")

local RunService         = game:GetService("RunService")

local UserInputService   = game:GetService("UserInputService")

local TeleportService    = game:GetService("TeleportService")

local VirtualInputManager = game:GetService("VirtualInputManager")

local Camera             = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

local function setGlobal(key, value)
        rawset(_G, key, value)
        if env ~= _G then env[key] = value end
end

local function getGlobal(key)
        local value = rawget(_G, key)
        if value ~= nil then return value end
        return env[key]
end

setGlobal("IndraHubBlockSpinRunning", true)
setGlobal("IndraHubBlockSpinSession", sessionId)
setGlobal("IndraHubBlockSpinLastHeartbeat", os.clock())
setGlobal("IndraHubBlockSpinError", nil)

local function isRunning()
        return getGlobal("IndraHubBlockSpinRunning") and getGlobal("IndraHubBlockSpinSession") == sessionId
end

task.spawn(function()
        while isRunning() do
                setGlobal("IndraHubBlockSpinLastHeartbeat", os.clock())
                task.wait(2)
        end
end)

local GeneralGroup = Tabs.General:AddLeftGroupbox("Movement", "move")

GeneralGroup:AddDropdown("MovementMode", {

        Text    = "Movement Mode",

        Values  = { "Humanoid (Pathfinder)", "Tween (Fast)" },

        Default = "Humanoid (Pathfinder)",

})

local function getChar(player)

        local character = player.Character or player.CharacterAdded:Wait()

        local humanoid  = character:WaitForChild("Humanoid")

        local hrp       = character:WaitForChild("HumanoidRootPart")

        return character, humanoid, hrp

end

local function tweenTo(hrp, targetPosition)

        local dist     = (hrp.Position - targetPosition).Magnitude

        local duration = dist / 60

        hrp.Anchored   = true

        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {

                CFrame = CFrame.new(Vector3.new(targetPosition.X, hrp.Position.Y, targetPosition.Z))

        })

        tween:Play()

        tween.Completed:Wait()

        hrp.Anchored = false

end

local function pathfindTo(hrp, humanoid, targetPosition, runningFlag)

        if not runningFlag() then return end

        local agentParams = { AgentCanJump = true, AgentRadius = 2, AgentHeight = 5 }

        local path = PathfindingService:CreatePath(agentParams)

        local ok = pcall(function() path:ComputeAsync(hrp.Position, targetPosition) end)

        if not ok or path.Status ~= Enum.PathStatus.Success then

                humanoid:MoveTo(targetPosition)

                humanoid.MoveToFinished:Wait()

                return

        end

        for _, wp in ipairs(path:GetWaypoints()) do

                if not runningFlag() then return end

                if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end

                humanoid:MoveTo(wp.Position)

                local moved = humanoid.MoveToFinished:Wait()

                if not moved then

                        humanoid:MoveTo(targetPosition)

                        humanoid.MoveToFinished:Wait()

                        break

                end

        end

end

local function moveTo(hrp, humanoid, targetPosition, runningFlag)

        if Options.MovementMode.Value == "Tween (Fast)" then

                tweenTo(hrp, targetPosition)

        else

                pathfindTo(hrp, humanoid, targetPosition, runningFlag)

        end

end

local AutofarmGroup = Tabs.Autofarm:AddLeftGroupbox("Gas Station", "boxes")

AutofarmGroup:AddLabel("Take the Job before start")

local autofarmRunning = false

local autofarmThread  = nil

local function markDoors()

        for _, v in ipairs(workspace:GetDescendants()) do

                if v:IsA("BasePart") and v.Name:lower():find("door") then

                        pcall(function() v.CanQuery = false end)

                end

        end

end

local function findNearestAttachment(shelves, hrpPos)

        local bestDist   = math.huge

        local bestAttach = nil

        for _, shelf in ipairs(shelves) do

                local function checkAttach(a)

                        if a:IsA("Attachment") then

                                local d = (a.WorldPosition - hrpPos).Magnitude

                                if d < bestDist then

                                        bestDist   = d

                                        bestAttach = a

                                end

                        end

                end

                for _, child in ipairs(shelf:GetChildren()) do checkAttach(child) end

                for _, desc  in ipairs(shelf:GetDescendants()) do checkAttach(desc) end

        end

        return bestAttach

end

local function runAutofarm()

        local player = LocalPlayer

        markDoors()

local promptBox       = workspace.Map.Tiles.GasStationTile.Quick11.Interior.ShelfStockingJob.NormalBox

        local proximityPrompt = promptBox:WaitForChild("ProximityPrompt")

        local shelves         = workspace.Map.Tiles.GasStationTile.Quick11.Interior.ShelfStockingJob.Shelves:GetChildren()

local standPosition     = Vector3.new(149.9239959716797, 255.46714782714844, 208.3470001220703)

        local boxPickupPosition = Vector3.new(130.8084259033203, 255.46714782714844, 203.2950439453125)

local function running() return autofarmRunning end

while autofarmRunning do

                local _, humanoid, hrp = getChar(player)

pathfindTo(hrp, humanoid, standPosition, running)

                if not autofarmRunning then break end

                task.wait(0.3)

fireproximityprompt(proximityPrompt)

                task.wait(0.5)

_, humanoid, hrp = getChar(player)

                pathfindTo(hrp, humanoid, boxPickupPosition, running)

                if not autofarmRunning then break end

                task.wait(0.5)

local attachment = findNearestAttachment(shelves, hrp.Position)

                if attachment then

                        moveTo(hrp, humanoid, attachment.WorldPosition, running)

                        if not autofarmRunning then break end

                        task.wait(10)

                        _, humanoid, hrp = getChar(player)

                        pathfindTo(hrp, humanoid, standPosition, running)

                        if not autofarmRunning then break end

                end

task.wait(0.1)

        end

end

AutofarmGroup:AddToggle("AutofarmToggle", {

        Text    = "Autofarm Gas Station",

        Default = false,

        Callback = function(Value)

                autofarmRunning = Value

                if Value then

                        autofarmThread = task.spawn(runAutofarm)

                else

                        if autofarmThread then task.cancel(autofarmThread) autofarmThread = nil end

                end

        end,

})

local MopGroup = Tabs.Autofarm:AddRightGroupbox("Mop Job", "droplets")

MopGroup:AddLabel("Take the Mop Job before start")

MopGroup:AddDropdown("MopType", {

        Text    = "Mop Type",

        Values  = { "Default", "Silver", "Gold", "Diamond" },

        Default = "Default",

})

local mopRunning = false

local mopThread  = nil

local function findNearestPuddlePath(hrpPos)

        local puddlesFolder = workspace.Map.Tiles.BurgerPlaceTile.BurgerPlace.Interior.Puddles

        local bestDist = math.huge

        local bestPuddle = nil

        local bestPath   = nil

        for _, v in ipairs(puddlesFolder:GetChildren()) do

                if v:IsA("BasePart") and v.Parent

                and (v.Name == "SmallPuddle" or v.Name == "LargePuddle")

                and v.Size.X >= 1 and v.Size.Z >= 1

                and (v.Position - Vector3.new(150, 253, -250)).Magnitude > 3 then

                        local path = PathfindingService:CreatePath({

                                AgentRadius = 1, AgentHeight = 4,

                                AgentCanJump = false, AgentCanClimb = true,

                        })

                        path:ComputeAsync(hrpPos, v.Position + Vector3.new(0, 2, 0))

                        if path.Status ~= Enum.PathStatus.NoPath then

                                local dist = (hrpPos - v.Position).Magnitude

                                if dist < bestDist then

                                        bestDist   = dist

                                        bestPuddle = v

                                        bestPath   = path

                                end

                        end

                end

        end

        return bestPuddle, bestPath

end

local function runMopFarm()

        while mopRunning do

                task.wait(1)

                local char     = LocalPlayer.Character

                local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                local hrp      = char and char:FindFirstChild("HumanoidRootPart")

                if not humanoid or humanoid.Health <= 0 or not hrp then continue end

local puddle, path = findNearestPuddlePath(hrp.Position)

                if not puddle or not path or path.Status == Enum.PathStatus.NoPath then continue end

local mopMultiplier = ({

                        ["Default"] = 1, ["Silver"] = 0.8, ["Gold"] = 0.7, ["Diamond"] = 0.6,

                })[Options.MopType.Value] or 1

local baseTime = (puddle.Name == "SmallPuddle") and 5 or 10

                local waitTime = baseTime * mopMultiplier

VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)

                local waypoints = path:GetWaypoints()

for i, waypoint in ipairs(waypoints) do

                        if not mopRunning then break end

                        if not puddle or not puddle:IsDescendantOf(game) or puddle.Size.X < 1 then break end

                        humanoid:MoveTo(waypoint.Position)

                        humanoid.MoveToFinished:Wait()

                        if i == #waypoints then

                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)

VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)

                                task.wait(0.1)

                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)

                                task.wait(waitTime + 0.25)

                        end

                end

        end

end

MopGroup:AddToggle("MopFarmToggle", {

        Text    = "Autofarm Mop Job",

        Default = false,

        Callback = function(Value)

                mopRunning = Value

                if Value then

                        mopThread = task.spawn(runMopFarm)

                else

                        if mopThread then task.cancel(mopThread) mopThread = nil end

                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)

                end

        end,

})

local PlayerGroup  = Tabs.Player:AddLeftGroupbox("Player", "user")

local PlayerGroupR = Tabs.Player:AddRightGroupbox("Visual", "eye")

local cframeSpeedConn = nil

local function stopCFrameSpeed()

        if cframeSpeedConn then cframeSpeedConn:Disconnect() cframeSpeedConn = nil end

end

PlayerGroup:AddSlider("SpeedBoostAmount", {

        Text     = "Speed Boost Amount",

        Default  = 8,

        Min      = 1,

        Max      = 50,

        Rounding = 0,

})

PlayerGroup:AddToggle("CFrameSpeed", {

        Text    = "Speed Boost",

        Default = false,

        Callback = function(Value)

                stopCFrameSpeed()

                if not Value then return end

                cframeSpeedConn = RunService.Heartbeat:Connect(function(dt)

                        if not Toggles.CFrameSpeed.Value then stopCFrameSpeed() return end

                        local char = LocalPlayer.Character

                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")

                        local hum  = char and char:FindFirstChildOfClass("Humanoid")

                        if not hrp or not hum then return end

                        local moveDir = hum.MoveDirection

                        if moveDir.Magnitude > 0 then

                                hrp.CFrame = hrp.CFrame + moveDir * Options.SpeedBoostAmount.Value * dt

                        end

                end)

        end,

})

local cframeFlyConn = nil

local cframeFlyActive = false

local function stopCFrameFly()

        cframeFlyActive = false

        if cframeFlyConn then cframeFlyConn:Disconnect() cframeFlyConn = nil end

        local char = LocalPlayer.Character

        if char then

                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum then hum.PlatformStand = false end

        end

end

PlayerGroup:AddToggle("CFrameFly", {

        Text    = "Player Fly",

        Default = false,

        Callback = function(Value)

                stopCFrameFly()

                if not Value then return end

                cframeFlyActive = true

                cframeFlyConn = RunService.Heartbeat:Connect(function(dt)

                        if not Toggles.CFrameFly.Value then stopCFrameFly() return end

                        local char = LocalPlayer.Character

                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")

                        local hum  = char and char:FindFirstChildOfClass("Humanoid")

                        if not hrp or not hum then return end

                        hum.PlatformStand = true

local speed = 28

                        local vel   = Vector3.zero

                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector  end

                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector  end

                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end

                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end

                        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then vel = vel + Vector3.new(0, 1, 0) end

                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, 1, 0) end

if vel.Magnitude > 0 then

                                hrp.CFrame = hrp.CFrame + vel.Unit * speed * dt

                        end

                end)

        end,

})

local ghostConn = nil

local originalMaterials = {}

local function applyGhost(enabled)

        local char = LocalPlayer.Character

        if not char then return end

        if enabled then

                originalMaterials = {}

                for _, part in ipairs(char:GetDescendants()) do

                        if part:IsA("BasePart") then

                                originalMaterials[part] = { mat = part.Material, trans = part.Transparency }

                                pcall(function()

                                        part.Material     = Enum.Material.ForceField

                                        part.Transparency = 0.4

                                end)

                        end

                end

        else

                for part, data in pairs(originalMaterials) do

                        pcall(function()

                                if part and part.Parent then

                                        part.Material     = data.mat

                                        part.Transparency = data.trans

                                end

                        end)

                end

                originalMaterials = {}

        end

end

PlayerGroupR:AddToggle("Ghost", {

        Text    = "Ghost",

        Default = false,

        Callback = function(Value)

                applyGhost(Value)

                if Value then

                        if ghostConn then ghostConn:Disconnect() end

                        ghostConn = LocalPlayer.CharacterAdded:Connect(function()

                                task.wait(1)

                                if Toggles.Ghost.Value then applyGhost(true) end

                        end)

                else

                        if ghostConn then ghostConn:Disconnect() ghostConn = nil end

                end

        end,

})

local MiscGroup  = Tabs.Misc:AddLeftGroupbox("Performance", "zap")

local MiscGroupR = Tabs.Misc:AddRightGroupbox("Session", "refresh-cw")

local fpsBoostConn = nil

MiscGroup:AddToggle("FPSBoost", {

        Text    = "FPS Boost",

        Default = false,

        Callback = function(Value)

                if Value then

                        pcall(function() settings().Rendering.QualityLevel = 1 end)

                        pcall(function() workspace.StreamingEnabled = false end)

                        fpsBoostConn = RunService.Heartbeat:Connect(function()

                                if not Toggles.FPSBoost.Value then

                                        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end

                                        pcall(function() settings().Rendering.QualityLevel = 10 end)

                                        return

                                end

                                pcall(function()

                                        for _, v in ipairs(workspace:GetDescendants()) do

                                                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then

                                                        v.Enabled = false

                                                end

                                        end

                                end)

                        end)

                else

                        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end

                        pcall(function() settings().Rendering.QualityLevel = 10 end)

                end

        end,

})

MiscGroupR:AddButton("Server Hop", function()

        local servers = {}

        local ok, result = pcall(function()

                local HttpService = game:GetService("HttpService")

                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"

                local data = HttpService:JSONDecode(game:HttpGet(url))

                for _, server in ipairs(data.data) do

                        if server.id ~= game.JobId and server.playing < server.maxPlayers then

                                table.insert(servers, server.id)

                        end

                end

        end)

        if ok and #servers > 0 then

                local chosen = servers[math.random(1, #servers)]

                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, LocalPlayer)

        else

                TeleportService:Teleport(game.PlaceId, LocalPlayer)

        end

end)

MiscGroupR:AddButton("Rejoin", function()

        TeleportService:Teleport(game.PlaceId, LocalPlayer)

end)

local targetPlayerNames = { "None" }

for _, p in ipairs(Players:GetPlayers()) do

        if p ~= LocalPlayer then

                table.insert(targetPlayerNames, p.Name)

        end

end

Players.PlayerAdded:Connect(function(p)

        table.insert(targetPlayerNames, p.Name)

        Options.TargetPlayer:SetValues(targetPlayerNames)

end)

Players.PlayerRemoving:Connect(function(p)

        for i, name in ipairs(targetPlayerNames) do

                if name == p.Name then

                        table.remove(targetPlayerNames, i)

                        break

                end

        end

        Options.TargetPlayer:SetValues(targetPlayerNames)

end)

local TargetGroup = Tabs.Misc:AddLeftGroupbox("Target Player", "crosshair")

TargetGroup:AddDropdown("TargetPlayer", {

        Text    = "Select Player",

        Values  = targetPlayerNames,

        Default = "None",

})

local targetGui = nil

local function destroyTargetGui()

        if targetGui and targetGui.Parent then

                targetGui:Destroy()

        end

        targetGui = nil

end

local targetUpdateConn = nil

local function createTargetGui()

        destroyTargetGui()

        local gui = Instance.new("ScreenGui")

        gui.Name = "TargetPlayerGUI"

        gui.ResetOnSpawn = false

        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ok = pcall(function() gui.Parent = gethui() end)

        if not ok then

                pcall(function() gui.Parent = game:GetService("CoreGui") end)

                if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        end

local frame = Instance.new("Frame")

        frame.Size = UDim2.new(0, 220, 0, 180)

        frame.Position = UDim2.new(0, 10, 0.5, -90)

        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)

        frame.BackgroundTransparency = 0.15

        frame.BorderSizePixel = 0

        frame.Parent = gui

local corner = Instance.new("UICorner")

        corner.CornerRadius = UDim.new(0, 8)

        corner.Parent = frame

local stroke = Instance.new("UIStroke")

        stroke.Color = Color3.fromRGB(80, 80, 120)

        stroke.Thickness = 1

        stroke.Parent = frame

local title = Instance.new("TextLabel")

        title.Size = UDim2.new(1, 0, 0, 26)

        title.Position = UDim2.new(0, 0, 0, 0)

        title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)

        title.BackgroundTransparency = 0

        title.BorderSizePixel = 0

        title.Text = "Target Player"

        title.TextColor3 = Color3.fromRGB(200, 200, 255)

        title.TextSize = 13

        title.Font = Enum.Font.GothamBold

        title.Parent = frame

local titleCorner = Instance.new("UICorner")

        titleCorner.CornerRadius = UDim.new(0, 8)

        titleCorner.Parent = title

local lines = {}

        local lineNames = { "Name", "Health", "Distance", "Weapon", "Backpack" }

        for i, name in ipairs(lineNames) do

                local lbl = Instance.new("TextLabel")

                lbl.Size = UDim2.new(1, -10, 0, 22)

                lbl.Position = UDim2.new(0, 5, 0, 26 + (i - 1) * 23)

                lbl.BackgroundTransparency = 1

                lbl.TextColor3 = Color3.fromRGB(220, 220, 220)

                lbl.TextSize = 12

                lbl.Font = Enum.Font.Gotham

                lbl.TextXAlignment = Enum.TextXAlignment.Left

                lbl.Text = name .. ": -"

                lbl.Parent = frame

                lines[name] = lbl

        end

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

        title.InputBegan:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1 then

                        dragging = true

                        dragStart = input.Position

                        startPos = frame.Position

                end

        end)

        title.InputEnded:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end

        end)

        UserInputService.InputChanged:Connect(function(input)

                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                        local delta = input.Position - dragStart

                        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

                end

        end)

targetGui = gui

if targetUpdateConn then targetUpdateConn:Disconnect() end

        targetUpdateConn = RunService.Heartbeat:Connect(function()

                local targetName = Options.TargetPlayer and Options.TargetPlayer.Value

                if not targetName or targetName == "None" then

                        for _, lbl in pairs(lines) do lbl.Text = lbl.Text:match("^(%w+):") .. ": -" end

                        return

                end

local target = Players:FindFirstChild(targetName)

                if not target then

                        for _, lbl in pairs(lines) do lbl.Text = lbl.Text:match("^(%w+):") .. ": -" end

                        return

                end

local char = target.Character

                local localChar = LocalPlayer.Character

                local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

lines["Name"].Text = "Name: " .. target.DisplayName .. " (@" .. target.Name .. ")"

if char then

                        local hum = char:FindFirstChildOfClass("Humanoid")

                        if hum then

                                lines["Health"].Text = "HP: " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)

                        else

                                lines["Health"].Text = "HP: -"

                        end

local hrp = char:FindFirstChild("HumanoidRootPart")

                        if hrp and localHRP then

                                local dist = (hrp.Position - localHRP.Position).Magnitude

                                lines["Distance"].Text = "Distance: " .. math.floor(dist) .. " studs"

                        else

                                lines["Distance"].Text = "Distance: -"

                        end

local tool = char:FindFirstChildOfClass("Tool")

                        lines["Weapon"].Text = "Weapon: " .. (tool and tool.Name or "None")

local backpack = target:FindFirstChild("Backpack")

                        local items = {}

                        if tool then table.insert(items, tool.Name .. "[E]") end

                        if backpack then

                                for _, item in ipairs(backpack:GetChildren()) do

                                        if item:IsA("Tool") then table.insert(items, item.Name) end

                                end

                        end

                        lines["Backpack"].Text = "Inv: " .. (#items > 0 and table.concat(items, ", ") or "Empty")

                else

                        lines["Health"].Text   = "HP: -"

                        lines["Distance"].Text = "Distance: -"

                        lines["Weapon"].Text   = "Weapon: -"

                        lines["Backpack"].Text = "Inv: -"

                end

        end)

end

TargetGroup:AddToggle("ShowTargetGUI", {

        Text    = "Show Target Info",

        Default = false,

        Callback = function(Value)

                if Value then

                        createTargetGui()

                else

                        if targetUpdateConn then targetUpdateConn:Disconnect() targetUpdateConn = nil end

                        destroyTargetGui()

                end

        end,

})

local AimbotGroup       = Tabs.Aimbot:AddLeftGroupbox("Aimbot",  "crosshair")

local AimbotVisualGroup = Tabs.Aimbot:AddRightGroupbox("Visuals","eye")

AimbotGroup:AddToggle("AimbotEnabled",  { Text = "Aimbot On",          Default = false })

AimbotGroup:AddToggle("AimbotMobile",   { Text = "Mobile Mode (Auto)", Default = false })

AimbotGroup:AddToggle("AimbotLockHead", { Text = "Target: Head",       Default = true  })

AimbotGroup:AddToggle("AimbotWallCheck",   { Text = "Wall Check",   Default = false })

AimbotGroup:AddToggle("AimbotMaxDistanceToggle", { Text = "Max Distance", Default = false })

AimbotGroup:AddToggle("AimbotFriendCheck", { Text = "Friend Check", Default = false })

AimbotGroup:AddLabel("Aimbot Key"):AddKeyPicker("AimbotKeybind", {

        Default = "E",

        SyncToggleState = false,

        Mode = "Hold",

        Text = "Aimbot Key",

        NoUI = false,

})

AimbotGroup:AddDropdown("AimbotMode", {

        Text    = "Aimbot Mode",

        Values  = { "Hold", "Toggle" },

        Default = "Hold",

        Callback = function(Value)

                Options.AimbotKeybind:SetMode(Value)

                Library:Notify("Aimbot Mode set to: " .. Value)

        end,

})

AimbotGroup:AddSlider("AimbotFOV", {

        Text     = "FOV",

        Default  = 150,

        Min      = 10,

        Max      = 500,

        Rounding = 0,

})

AimbotGroup:AddSlider("AimbotSmooth", {

        Text     = "Smoothness",

        Default  = 5,

        Min      = 1,

        Max      = 20,

        Rounding = 1,

})

AimbotGroup:AddSlider("AimbotMaxDistance", {

        Text     = "Max Distance",

        Default  = 300,

        Min      = 50,

        Max      = 1000,

        Rounding = 0,

        Visible  = function() return Toggles.AimbotMaxDistanceToggle.Value end,

})

AimbotVisualGroup:AddToggle("AimbotFOVCircle", { Text = "Show FOV Circle", Default = true })

AimbotVisualGroup:AddLabel("FOV Color"):AddColorPicker("AimbotFOVColor", { Default = Color3.fromRGB(255, 255, 255) })

local fovCircle     = Drawing.new("Circle")

fovCircle.Visible   = false

fovCircle.Thickness = 1.5

fovCircle.Filled    = false

fovCircle.NumSides  = 64

fovCircle.Color     = Color3.fromRGB(255, 255, 255)

local function isVisible(part, char)

        if not Toggles.AimbotWallCheck.Value then return true end

        local params = RaycastParams.new()

        params.FilterType = Enum.RaycastFilterType.Exclude

        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

local origin = Camera.CFrame.Position

        local result = workspace:Raycast(origin, part.Position - origin, params)

        return not result or result.Instance:IsDescendantOf(char)

end

local function getAimbotTarget()

        local localChar = LocalPlayer.Character

        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

        if not localHRP then return nil end

local fov      = Options.AimbotFOV.Value

        local center   = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        local bestDist = math.huge

        local bestPart = nil

for _, player in ipairs(Players:GetPlayers()) do

                if player == LocalPlayer then continue end

if Toggles.AimbotFriendCheck.Value and LocalPlayer:IsFriendsWith(player.UserId) then continue end

local char = player.Character

                if not char then continue end

                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if not humanoid or humanoid.Health <= 0 then continue end

if Toggles.AimbotMaxDistanceToggle.Value then

                    local dist = (localHRP.Position - char:FindFirstChild("HumanoidRootPart").Position).Magnitude

                    if dist > Options.AimbotMaxDistance.Value then continue end

                end

local targetPart = Toggles.AimbotLockHead.Value

                        and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))

                        or char:FindFirstChild("HumanoidRootPart")

                if not targetPart then continue end

local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)

                if not onScreen or screenPos.Z < 0 then continue end

if not isVisible(targetPart, char) then continue end

local screenV2       = Vector2.new(screenPos.X, screenPos.Y)

                local distFromCenter = (screenV2 - center).Magnitude

if distFromCenter < fov and distFromCenter < bestDist then

                        bestDist = distFromCenter

                        bestPart = targetPart

                end

        end

return bestPart

end

local aimbotConn = nil

local function startAimbot()

        if aimbotConn then aimbotConn:Disconnect() end

        aimbotConn = RunService.RenderStepped:Connect(function()

                local fov     = Options.AimbotFOV.Value

                local center  = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

fovCircle.Visible  = Toggles.AimbotFOVCircle.Value and Toggles.AimbotEnabled.Value

                fovCircle.Radius   = fov

                fovCircle.Position = center

                fovCircle.Color    = Options.AimbotFOVColor.Value

if not Toggles.AimbotEnabled.Value then return end

local isMobile  = Toggles.AimbotMobile.Value

                local shouldAim = isMobile or Options.AimbotKeybind:GetState()

                if not shouldAim then return end

local target = getAimbotTarget()

                if not target then return end

local smooth   = Options.AimbotSmooth.Value

                local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)

                Camera.CFrame  = Camera.CFrame:Lerp(targetCF, 1 / smooth)

        end)

end

startAimbot()

local ESPLeftGroup  = Tabs.ESP:AddLeftGroupbox("Players", "users")

local ESPRightGroup = Tabs.ESP:AddRightGroupbox("Visuals", "layers")

ESPLeftGroup:AddToggle("ESPEnabled",  { Text = "ESP Enabled",          Default = false })

ESPLeftGroup:AddToggle("CornerBox",   { Text = "Corner Box",           Default = false })

ESPLeftGroup:AddToggle("FullBox",     { Text = "Full Box",             Default = false })

ESPLeftGroup:AddToggle("HealthBar",   { Text = "Health Bar",           Default = false })

ESPLeftGroup:AddToggle("HealthText",  { Text = "Health Text",          Default = false })

ESPLeftGroup:AddToggle("FriendCheck", { Text = "Friend Check (Green)", Default = false })

ESPLeftGroup:AddToggle("NameESP",     { Text = "Name ESP",             Default = false })

ESPLeftGroup:AddToggle("DistanceESP", { Text = "Distance ESP",         Default = false })

ESPLeftGroup:AddToggle("WeaponESP",   { Text = "Weapon ESP",           Default = false })

ESPLeftGroup:AddToggle("BackpackESP", { Text = "Backpack ESP",         Default = false })

ESPLeftGroup:AddToggle("SkeletonESP", { Text = "Skeleton ESP",         Default = false })

ESPLeftGroup:AddToggle("ChamsESP",    { Text = "Chams",                Default = false })

ESPLeftGroup:AddSlider("ESPMaxDistance", {

        Text     = "Max Distance",

        Default  = 500,

        Min      = 50,

        Max      = 2000,

        Rounding = 0,

})

ESPRightGroup:AddLabel("Box Color"):AddColorPicker("BoxColor",          { Default = Color3.fromRGB(255, 255, 255) })

ESPRightGroup:AddLabel("Health Color"):AddColorPicker("HealthColor",    { Default = Color3.fromRGB(0, 255, 0)    })

ESPRightGroup:AddLabel("Skeleton Color"):AddColorPicker("SkeletonColor",{ Default = Color3.fromRGB(255, 255, 255) })

ESPRightGroup:AddLabel("Chams Color"):AddColorPicker("ChamsColor",      { Default = Color3.fromRGB(255, 0, 0)    })

ESPRightGroup:AddLabel("Friend Color"):AddColorPicker("FriendColor",    { Default = Color3.fromRGB(0, 255, 100)  })

ESPRightGroup:AddLabel("Text Color"):AddColorPicker("TextColor",        { Default = Color3.fromRGB(255, 255, 255) })

ESPRightGroup:AddLabel("Backpack Color"):AddColorPicker("BackpackColor",{ Default = Color3.fromRGB(255, 200, 0)  })

local skeletonBones = {

        { "Head","UpperTorso" },{ "UpperTorso","LowerTorso" },

        { "UpperTorso","RightUpperArm" },{ "RightUpperArm","RightLowerArm" },{ "RightLowerArm","RightHand" },

        { "UpperTorso","LeftUpperArm"  },{ "LeftUpperArm","LeftLowerArm"   },{ "LeftLowerArm","LeftHand"   },

        { "LowerTorso","RightUpperLeg" },{ "RightUpperLeg","RightLowerLeg" },{ "RightLowerLeg","RightFoot" },

        { "LowerTorso","LeftUpperLeg"  },{ "LeftUpperLeg","LeftLowerLeg"   },{ "LeftLowerLeg","LeftFoot"   },

}

local MAX_BACKPACK_SLOTS = 10

local espObjects     = {}

local espConnections = {}

local function newDrawing(drawType, props)

        local d = Drawing.new(drawType)

        for k, v in pairs(props) do d[k] = v end

        return d

end

local function removeESPForPlayer(player)

        local data = espObjects[player]

        if not data then return end

        for key, obj in pairs(data) do

                if key == "skeleton" then

                        for _, line in pairs(obj) do pcall(function() line:Remove() end) end

                elseif key == "chams" then

                        for _, entry in pairs(obj) do pcall(function() entry.SelectionBox:Destroy() end) end

                elseif key == "backpackTexts" then

                        for _, txt in pairs(obj) do pcall(function() txt:Remove() end) end

                elseif type(obj) ~= "boolean" then

                        pcall(function() obj:Remove() end)

                end

        end

        espObjects[player] = nil

end

local function setupESPForPlayer(player)

        if player == LocalPlayer then return end

        removeESPForPlayer(player)

        local d = {}

        d.boxTop      = newDrawing("Line", { Visible=false, Thickness=1.5, ZIndex=5 })

        d.boxBottom   = newDrawing("Line", { Visible=false, Thickness=1.5, ZIndex=5 })

        d.boxLeft     = newDrawing("Line", { Visible=false, Thickness=1.5, ZIndex=5 })

        d.boxRight    = newDrawing("Line", { Visible=false, Thickness=1.5, ZIndex=5 })

        d.cTL1 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cTL2 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cTR1 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cTR2 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cBL1 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cBL2 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cBR1 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.cBR2 = newDrawing("Line",{Visible=false,Thickness=1.5,ZIndex=5})

        d.healthBarBG  = newDrawing("Line",{Visible=false,Thickness=4,Color=Color3.fromRGB(0,0,0),ZIndex=4})

        d.healthBar    = newDrawing("Line",{Visible=false,Thickness=3,ZIndex=5})

        d.nameText     = newDrawing("Text",{Visible=false,Size=13,Center=true,Outline=true,ZIndex=5})

        d.healthText   = newDrawing("Text",{Visible=false,Size=12,Center=true,Outline=true,ZIndex=5})

        d.distanceText = newDrawing("Text",{Visible=false,Size=12,Center=true,Outline=true,ZIndex=5})

        d.weaponText   = newDrawing("Text",{Visible=false,Size=12,Center=true,Outline=true,ZIndex=5})

        d.skeleton = {}

        for i = 1, #skeletonBones do

                d.skeleton[i] = newDrawing("Line",{Visible=false,Thickness=1,ZIndex=5})

        end

        d.backpackTexts = {}

        for i = 1, MAX_BACKPACK_SLOTS do

                d.backpackTexts[i] = newDrawing("Text",{Visible=false,Size=11,Center=true,Outline=true,ZIndex=5})

        end

        d.chams        = {}

        d._chamsActive = false

        espObjects[player] = d

end

local function applyChams(player, color, enabled)

        local d = espObjects[player]

        if not d then return end

        for _, entry in pairs(d.chams) do pcall(function() entry.Highlight:Destroy() end) end

        d.chams = {}

        if not enabled or not color then return end

        local character = player.Character

        if not character then return end

        local highlight                  = Instance.new("Highlight")

        highlight.FillColor              = color

        highlight.OutlineColor           = color

        highlight.FillTransparency       = 0.4

        highlight.OutlineTransparency    = 0

        highlight.DepthMode              = Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Adornee                = character

        highlight.Parent                 = character

        table.insert(d.chams, { Highlight = highlight })

end

local function hideAll(d)

        for k, obj in pairs(d) do

                if k == "skeleton" then

                        for _, line in pairs(obj) do pcall(function() line.Visible = false end) end

                elseif k == "backpackTexts" then

                        for _, txt in pairs(obj) do pcall(function() txt.Visible = false end) end

                elseif k ~= "chams" and k ~= "_chamsActive" then

                        pcall(function() obj.Visible = false end)

                end

        end

end

local function toScreen(worldPos)

        local sv, onScreen = Camera:WorldToViewportPoint(worldPos)

        return Vector2.new(sv.X, sv.Y), onScreen, sv.Z

end

local function updateESP()

        local localChar = LocalPlayer.Character

        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

for _, player in ipairs(Players:GetPlayers()) do

                if player == LocalPlayer then continue end

                local d = espObjects[player]

                if not d then continue end

local character = player.Character

                local humanoid  = character and character:FindFirstChildOfClass("Humanoid")

                local hrp       = character and character:FindFirstChild("HumanoidRootPart")

if not Toggles.ESPEnabled.Value or not character or not humanoid or not hrp then

                        hideAll(d) continue

                end

local dist = localHRP and (hrp.Position - localHRP.Position).Magnitude or 0

                if dist > Options.ESPMaxDistance.Value then hideAll(d) continue end

local headScrn, headOn, headDepth = toScreen(hrp.Position + Vector3.new(0, 3.2, 0))

                local footScrn                    = toScreen(hrp.Position - Vector3.new(0, 3.2, 0))

if not headOn or headDepth < 0 then hideAll(d) continue end

local top = math.min(headScrn.Y, footScrn.Y)

                local bot = math.max(headScrn.Y, footScrn.Y)

                local h   = bot - top

                if h < 5 then hideAll(d) continue end

local cx    = headScrn.X

                local w     = h * 0.55

                local left  = cx - w / 2

                local right = cx + w / 2

local isFriend = Toggles.FriendCheck.Value and LocalPlayer:IsFriendsWith(player.UserId)

                local boxColor  = isFriend and Options.FriendColor.Value or Options.BoxColor.Value

                local textColor = Options.TextColor.Value

if Toggles.FullBox.Value then

                        d.boxTop.From=Vector2.new(left,top)    d.boxTop.To=Vector2.new(right,top)    d.boxTop.Color=boxColor    d.boxTop.Visible=true

                        d.boxBottom.From=Vector2.new(left,bot) d.boxBottom.To=Vector2.new(right,bot) d.boxBottom.Color=boxColor d.boxBottom.Visible=true

                        d.boxLeft.From=Vector2.new(left,top)   d.boxLeft.To=Vector2.new(left,bot)    d.boxLeft.Color=boxColor   d.boxLeft.Visible=true

                        d.boxRight.From=Vector2.new(right,top) d.boxRight.To=Vector2.new(right,bot)  d.boxRight.Color=boxColor  d.boxRight.Visible=true

                else

                        d.boxTop.Visible=false d.boxBottom.Visible=false d.boxLeft.Visible=false d.boxRight.Visible=false

                end

if Toggles.CornerBox.Value then

                        local cw, ch = w * 0.25, h * 0.25

                        d.cTL1.From=Vector2.new(left,top)    d.cTL1.To=Vector2.new(left+cw,top)

                        d.cTL2.From=Vector2.new(left,top)    d.cTL2.To=Vector2.new(left,top+ch)

                        d.cTR1.From=Vector2.new(right,top)   d.cTR1.To=Vector2.new(right-cw,top)

                        d.cTR2.From=Vector2.new(right,top)   d.cTR2.To=Vector2.new(right,top+ch)

                        d.cBL1.From=Vector2.new(left,bot)    d.cBL1.To=Vector2.new(left+cw,bot)

                        d.cBL2.From=Vector2.new(left,bot)    d.cBL2.To=Vector2.new(left,bot-ch)

                        d.cBR1.From=Vector2.new(right,bot)   d.cBR1.To=Vector2.new(right-cw,bot)

                        d.cBR2.From=Vector2.new(right,bot)   d.cBR2.To=Vector2.new(right,bot-ch)

                        for _, k in ipairs({"cTL1","cTL2","cTR1","cTR2","cBL1","cBL2","cBR1","cBR2"}) do

                                d[k].Color=boxColor d[k].Visible=true

                        end

                else

                        for _, k in ipairs({"cTL1","cTL2","cTR1","cTR2","cBL1","cBL2","cBR1","cBR2"}) do d[k].Visible=false end

                end

local hp      = humanoid.Health

                local maxHp   = math.max(humanoid.MaxHealth, 1)

                local hpRatio = math.clamp(hp / maxHp, 0, 1)

                if Toggles.HealthBar.Value then

                        local barX = left - 5

                        d.healthBarBG.From=Vector2.new(barX,top) d.healthBarBG.To=Vector2.new(barX,bot) d.healthBarBG.Visible=true

                        d.healthBar.From=Vector2.new(barX,bot) d.healthBar.To=Vector2.new(barX,bot-h*hpRatio)

                        d.healthBar.Color=Color3.fromRGB(math.floor(255*(1-hpRatio)),math.floor(255*hpRatio),0)

                        d.healthBar.Visible=true

                else

                        d.healthBarBG.Visible=false d.healthBar.Visible=false

                end

if Toggles.NameESP.Value then

                        d.nameText.Text=player.DisplayName d.nameText.Position=Vector2.new(cx,top-15)

                        d.nameText.Color=textColor d.nameText.Visible=true

                else d.nameText.Visible=false end

local belowY = bot + 2

                if Toggles.HealthText.Value then

                        d.healthText.Text=math.floor(hp).." / "..math.floor(maxHp)

                        d.healthText.Position=Vector2.new(cx,belowY) d.healthText.Color=Options.HealthColor.Value d.healthText.Visible=true

                        belowY=belowY+13

                else d.healthText.Visible=false end

if Toggles.DistanceESP.Value then

                        d.distanceText.Text=math.floor(dist).."m"

                        d.distanceText.Position=Vector2.new(cx,belowY) d.distanceText.Color=textColor d.distanceText.Visible=true

                        belowY=belowY+13

                else d.distanceText.Visible=false end

if Toggles.WeaponESP.Value then

                        local tool = character:FindFirstChildOfClass("Tool")

                        if tool then

                                d.weaponText.Text="["..tool.Name.."]"

                                d.weaponText.Position=Vector2.new(cx,belowY) d.weaponText.Color=textColor d.weaponText.Visible=true

                                belowY=belowY+13

                        else d.weaponText.Visible=false end

                else d.weaponText.Visible=false end

if Toggles.BackpackESP.Value then

                        local backpackItems = {}

                        local equippedTool  = character:FindFirstChildOfClass("Tool")

                        if equippedTool then table.insert(backpackItems, equippedTool.Name .. " [E]") end

                        local backpack = player:FindFirstChild("Backpack")

                        if backpack then

                                for _, item in ipairs(backpack:GetChildren()) do

                                        if item:IsA("Tool") then table.insert(backpackItems, item.Name) end

                                end

                        end

                        local bpColor = Options.BackpackColor.Value

                        for i = 1, MAX_BACKPACK_SLOTS do

                                local slot = d.backpackTexts[i]

                                if backpackItems[i] then

                                        slot.Text     = backpackItems[i]

                                        slot.Position = Vector2.new(cx, belowY)

                                        slot.Color    = bpColor

                                        slot.Visible  = true

                                        belowY        = belowY + 12

                                else

                                        slot.Visible = false

                                end

                        end

                else

                        for i = 1, MAX_BACKPACK_SLOTS do d.backpackTexts[i].Visible = false end

                end

if Toggles.SkeletonESP.Value then

                        for i, bone in ipairs(skeletonBones) do

                                local p0 = character:FindFirstChild(bone[1])

                                local p1 = character:FindFirstChild(bone[2])

                                if p0 and p1 then

                                        local s0, on0 = Camera:WorldToViewportPoint(p0.Position)

                                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)

                                        if on0 and on1 then

                                                d.skeleton[i].From=Vector2.new(s0.X,s0.Y) d.skeleton[i].To=Vector2.new(s1.X,s1.Y)

                                                d.skeleton[i].Color=Options.SkeletonColor.Value d.skeleton[i].Visible=true

                                        else d.skeleton[i].Visible=false end

                                else d.skeleton[i].Visible=false end

                        end

                else

                        for _, line in pairs(d.skeleton) do line.Visible=false end

                end

if Toggles.ChamsESP.Value then

                        if not d._chamsActive then d._chamsActive=true applyChams(player, Options.ChamsColor.Value, true) end

                else

                        if d._chamsActive then d._chamsActive=false applyChams(player, nil, false) end

                end

        end

end

for _, player in ipairs(Players:GetPlayers()) do setupESPForPlayer(player) end

Players.PlayerAdded:Connect(setupESPForPlayer)

Players.PlayerRemoving:Connect(removeESPForPlayer)

local espRenderConn = RunService.RenderStepped:Connect(updateESP)

table.insert(espConnections, espRenderConn)

local TeleportLocGroup = Tabs.Teleport:AddLeftGroupbox("Locations", "map-pin")

local AutoVehGroup     = Tabs.Teleport:AddRightGroupbox("Vehicle Drive", "car")

local TELEPORT_LOCATIONS = {

        ["Quick Eleven"]   = Vector3.new(130.96791076660156,  255.1952362060547,  137.194580078125),

        ["Jacks Hardware"] = Vector3.new(-79.85430908203125,  255.0996856689453,  151.13352966308594),

        ["BurgerKing"]     = Vector3.new(109.45475006103516,  255.1714324951172,  -222.76136779785156),

        ["GunStore"]       = Vector3.new(-153.1615753173828,  255.29054260253906, -221.505859375),

        ["Dealership"]     = Vector3.new(116.21324157714844,  255.1833038330078,  440.7095031738281),

        ["Cook Job"]       = Vector3.new(-298.240234375,      255.1967010498047,  346.03729248046875),

}

local teleportLocationNames = {}

for name, _ in pairs(TELEPORT_LOCATIONS) do

        table.insert(teleportLocationNames, name)

end

table.sort(teleportLocationNames)

TeleportLocGroup:AddDropdown("TeleportLocation", {

        Text    = "Select Location",

        Values  = teleportLocationNames,

        Default = teleportLocationNames[1],

})

local DRIVE_SPEED   = 45

local driveRunning  = false

local driveThread   = nil

local function tp_tweenVehicle(vehicle, goalPosition)

        if not vehicle.PrimaryPart then return end

local currentPivot = vehicle:GetPivot()

        local currentPos   = currentPivot.Position

        local direction    = (goalPosition - currentPos).Unit

        local distance     = (goalPosition - currentPos).Magnitude

        local duration     = distance / DRIVE_SPEED

local targetCFrame = CFrame.lookAt(goalPosition, goalPosition + direction)

local value = Instance.new("CFrameValue")

        value.Value = currentPivot

local conn

        conn = value:GetPropertyChangedSignal("Value"):Connect(function()

                if vehicle and vehicle.Parent then

                        vehicle:PivotTo(value.Value)

                end

        end)

local tween = TweenService:Create(

                value,

                TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),

                { Value = targetCFrame }

        )

        tween:Play()

        tween.Completed:Wait()

        conn:Disconnect()

        value:Destroy()

end

local function tp_driveTo(vehicle, targetPosition)

        if not vehicle.PrimaryPart then return end

local path = PathfindingService:CreatePath({

                AgentRadius     = 6,

                AgentHeight     = 6,

                AgentCanJump    = false,

                WaypointSpacing = 12,

        })

local attempts = 0

        local success  = false

        repeat

                attempts = attempts + 1

                path:ComputeAsync(vehicle.PrimaryPart.Position, targetPosition)

                if path.Status == Enum.PathStatus.Success then

                        success = true

                else

                        task.wait(0.5)

                end

        until success or attempts >= 3

if not success then

                Library:Notify("Pathfinding failed - could not find a clear road.", 4)

                driveRunning = false

                return

        end

for _, waypoint in ipairs(path:GetWaypoints()) do

                if not driveRunning then break end

                if not vehicle or not vehicle.Parent then break end

                tp_tweenVehicle(vehicle, waypoint.Position)

        end

end

local function tp_findPlayerVehicle()

        local vFolder = workspace:FindFirstChild("Vehicles")

        if not vFolder then return nil end

        for _, vehicle in ipairs(vFolder:GetChildren()) do

                local chassis = vehicle:FindFirstChild("Chassis")

                if chassis then

                        local att = chassis:FindFirstChild("DrivePromptAttachment")

                        if att then

                                local prompt = att:FindFirstChild("DrivePrompt")

                                if prompt and prompt.ObjectText == LocalPlayer.Name .. "'s car" then

                                        return vehicle

                                end

                        end

                end

        end

        return nil

end

AutoVehGroup:AddLabel("Vehicle: sit in your vehicle first.")

AutoVehGroup:AddButton("Start Drive", function()

        if driveRunning then

                Library:Notify("Already driving! Press Stop Drive first.", 3)

                return

        end

        local selectedName = Options.TeleportLocation.Value

        local targetPos    = TELEPORT_LOCATIONS[selectedName]

        if not targetPos then

                Library:Notify("Select a location first!", 3)

                return

        end

local vehicle = tp_findPlayerVehicle()

        if not vehicle then

                Library:Notify("No vehicle found! Sit in your vehicle first.", 4)

                return

        end

        local seat = vehicle:FindFirstChildOfClass("VehicleSeat", true)

                  or vehicle:FindFirstChildOfClass("Seat", true)

        if seat and not vehicle.PrimaryPart then

                vehicle.PrimaryPart = seat

        end

        driveRunning = true

        Library:Notify("Driving to " .. selectedName .. "...", 3)

        driveThread = task.spawn(function()

                tp_driveTo(vehicle, targetPos)

                if driveRunning then

                        driveRunning = false

                        Library:Notify("Arrived at " .. selectedName, 3)

                end

                driveThread = nil

        end)

end)

AutoVehGroup:AddButton("Stop Drive", function()

        if not driveRunning then

                Library:Notify("Not currently driving.", 2)

                return

        end

        driveRunning = false

        if driveThread then

                task.cancel(driveThread)

                driveThread = nil

        end

        Library:Notify("Drive stopped.", 2)

end)

Library:OnUnload(function()

        setGlobal("IndraHubBlockSpinRunning", false)

        autofarmRunning = false

        mopRunning      = false

        if autofarmThread    then task.cancel(autofarmThread) end

        if mopThread         then task.cancel(mopThread) end

        if driveThread       then task.cancel(driveThread) end

        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)

        if aimbotConn      then aimbotConn:Disconnect() end

        if cframeSpeedConn then cframeSpeedConn:Disconnect() end

        if cframeFlyConn   then cframeFlyConn:Disconnect() end

        if carFlyConn      then carFlyConn:Disconnect() end

        if fpsBoostConn    then fpsBoostConn:Disconnect() end

        if ghostConn       then ghostConn:Disconnect() end

        if targetUpdateConn then targetUpdateConn:Disconnect() end

        applyGhost(false)

        destroyTargetGui()

        fovCircle:Remove()

        for _, conn in ipairs(espConnections) do conn:Disconnect() end

        for _, player in ipairs(Players:GetPlayers()) do removeESPForPlayer(player) end

        local char = LocalPlayer.Character

        if char then

                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum then hum.PlatformStand = false end

        end

end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {

        Default  = Library.KeybindFrame.Visible,

        Text     = "Open Keybind Menu",

        Callback = function(value) Library.KeybindFrame.Visible = value end,

})

MenuGroup:AddToggle("ShowCustomCursor", {

        Text     = "Custom Cursor",

        Default  = true,

        Callback = function(Value) Library.ShowCustomCursor = Value end,

})

MenuGroup:AddDropdown("NotificationSide", {

        Values   = { "Left", "Right" },

        Default  = "Right",

        Text     = "Notification Side",

        Callback = function(Value) Library:SetNotifySide(Value) end,

})

MenuGroup:AddDropdown("DPIDropdown", {

        Values   = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },

        Default  = "100%",

        Text     = "DPI Scale",

        Callback = function(Value)

                Value = Value:gsub("%%", "")

                Library:SetDPIScale(tonumber(Value))

        end,

})

MenuGroup:AddSlider("UICornerSlider", {

        Text     = "Corner Radius",

        Default  = Library.CornerRadius,

        Min      = 0,

        Max      = 20,

        Rounding = 0,

        Callback = function(value) Window:SetCornerRadius(value) end,

})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

