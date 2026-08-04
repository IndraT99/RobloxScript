local genv = getgenv()
if type(genv.IndraHubDriftTagUnload) == "function" then
	pcall(genv.IndraHubDriftTagUnload)
end
genv.IndraHubDriftTagUnload = nil

local cloneref = cloneref or function(v)
	return v
end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local LocalPlayer = Players.LocalPlayer

local Config = {
	GuiName = "IndraHub Drift Tag",
	GuiFooter = "IndraHub Premium",
	GuiFolder = "DriftTag",
	MenuKeybind = "RightControl",
	PassKeybind = "Z",
	VehiclesFolder = "Vehicles",
	ChassisName = "Chassis",
	TagInterval = 0.12,
	TagRange = 14,
	PassWindow = 1.2,
	RetpDistance = 6,
	ScanInterval = 0.1,
	ColorTolerance = 0.2,
	BlockWhenNotHolder = true,
	AutoFarm = false,
	SkyHeight = 1000,
	SideOffset = 1000,
	LobbyName = "lobby",
	GroundBand = 120,
	ParkTolerance = 4,
	PlatformSize = 80,
	PlatformDrop = 6,
	PlatformTransparency = 0.6,
	FarmDelay = 0.2,
	FarmRetry = 0.5,
	AfkPing = 45,
	Remotes = {
		TagContact = { "ReplicatedStorage", "Networking", "TagContact" },
	},
	AfkRemotes = {
		{ "ReplicatedStorage", "Storage", "Remotes", "AfkEvent" },
		{ "ReplicatedStorage", "Networking", "AfkEvent" },
	},
}

local IdleStatus = "Waiting for someone to get the bomb"

local indraState = {
	Holder = nil,
	MyColor = nil,
	Highlights = {},
	CarColors = {},
}

local indraPass = {
	active = false,
	target = nil,
	startTime = 0,
	lastFire = 0,
}

local indraFarm = {
	holderSince = nil,
	lastAttempt = 0,
	parkPosition = nil,
	platform = nil,
	ground = nil,
	lobby = nil,
}

local indraConns = {}
local indraStatusLabel = nil
local indraScanAcc = 0
local indraAfkAcc = 0

local function indraTrack(connection)
	if connection then
		table.insert(indraConns, connection)
	end
	return connection
end

local function indraResolve(path)
	local node = nil
	for index, name in ipairs(path) do
		if index == 1 then
			local ok, service = pcall(function()
				return game:GetService(name)
			end)
			if not ok then
				return nil
			end
			node = service
		else
			if not node then
				return nil
			end
			node = node:FindFirstChild(name)
		end
	end
	return node
end

local function indraResolveAny(paths)
	for _, path in ipairs(paths) do
		local node = indraResolve(path)
		if node then
			return node
		end
	end
	return nil
end

local TagContact = indraResolve(Config.Remotes.TagContact)
local AfkEvent = indraResolveAny(Config.AfkRemotes)

local function indraGetVehicles()
	return Workspace:FindFirstChild(Config.VehiclesFolder)
end

local function indraGetCar(player)
	local folder = indraGetVehicles()
	if not folder or not player then
		return nil
	end
	return folder:FindFirstChild(player.Name)
end

local function indraGetChassis(car)
	if not car then
		return nil
	end
	local chassis = car:FindFirstChild(Config.ChassisName)
	if chassis and chassis:IsA("BasePart") then
		return chassis
	end
	if car.PrimaryPart then
		return car.PrimaryPart
	end
	return car:FindFirstChildWhichIsA("BasePart")
end

local function indraStopPass()
	indraPass.active = false
	indraPass.target = nil
end

local function indraColorName(color)
	if not color then
		return "none"
	end
	if color.R > color.B + 0.15 and color.R > color.G + 0.15 then
		return "red"
	end
	if color.B > color.R + 0.15 and color.B > color.G + 0.15 then
		return "blue"
	end
	if color.G > color.R + 0.15 and color.G > color.B + 0.15 then
		return "green"
	end
	return "other"
end

local function indraSameColor(a, b)
	if not a or not b then
		return false
	end
	local tolerance = Config.ColorTolerance
	return math.abs(a.R - b.R) <= tolerance
		and math.abs(a.G - b.G) <= tolerance
		and math.abs(a.B - b.B) <= tolerance
end

local function indraRegisterHighlight(instance)
	if instance and instance:IsA("Highlight") then
		indraState.Highlights[instance] = true
	end
end

local function indraScanContainer(container, depth)
	if not container or depth <= 0 then
		return
	end
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Highlight") then
			indraRegisterHighlight(child)
		elseif depth > 1 then
			indraScanContainer(child, depth - 1)
		end
	end
end

local function indraCarFromHighlight(highlight, folder)
	local adornee = highlight.Adornee
	local node = adornee or highlight.Parent
	while node and node ~= folder do
		if node.Parent == folder then
			return node
		end
		node = node.Parent
	end
	return nil
end

local function indraRefreshHighlights()
	local folder = indraGetVehicles()
	table.clear(indraState.CarColors)
	if not folder then
		indraState.Holder = nil
		indraState.MyColor = nil
		indraFarm.holderSince = nil
		return
	end
	for _, car in ipairs(folder:GetChildren()) do
		indraScanContainer(car, 3)
	end
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	if gui then
		indraScanContainer(gui, 2)
	end
	for highlight in pairs(indraState.Highlights) do
		if not highlight.Parent then
			indraState.Highlights[highlight] = nil
		else
			local car = indraCarFromHighlight(highlight, folder)
			if car and highlight.Enabled then
				local color = highlight.FillColor
				if highlight.FillTransparency >= 1 then
					color = highlight.OutlineColor
				end
				indraState.CarColors[car] = color
			end
		end
	end
	local myCar = indraGetCar(LocalPlayer)
	indraState.MyColor = myCar and indraState.CarColors[myCar] or nil
	local holder = nil
	if indraState.MyColor then
		holder = LocalPlayer
	else
		local single = nil
		local count = 0
		for car in pairs(indraState.CarColors) do
			count = count + 1
			single = car
		end
		if count == 1 then
			holder = Players:FindFirstChild(single.Name)
		end
	end
	if holder ~= indraState.Holder then
		indraState.Holder = holder
		if holder == LocalPlayer then
			indraFarm.holderSince = os.clock()
		else
			indraFarm.holderSince = nil
			indraStopPass()
		end
	end
end

local function setStatus()
	if not indraStatusLabel then
		return
	end
	local text = IdleStatus
	if indraState.Holder == LocalPlayer then
		text = "Bomb: YOU (" .. indraColorName(indraState.MyColor) .. ")"
	elseif indraState.Holder then
		local car = indraGetCar(indraState.Holder)
		text = "Bomb: " .. indraState.Holder.DisplayName .. " (" .. indraColorName(car and indraState.CarColors[car]) .. ")"
	else
		local count = 0
		for _ in pairs(indraState.CarColors) do
			count = count + 1
		end
		if count > 1 then
			text = "Bomb: team mode (" .. count .. " marked)"
		end
	end
	pcall(function()
		indraStatusLabel:SetDesc(text)
	end)
end

local function indraPickTarget(origin)
	local folder = indraGetVehicles()
	if not folder then
		return nil, "No target"
	end
	local bestEnemy = nil
	local bestEnemyDistance = nil
	local bestPlain = nil
	local bestPlainDistance = nil
	local sameTeamSeen = false
	for _, car in ipairs(folder:GetChildren()) do
		local player = Players:FindFirstChild(car.Name)
		if player and player ~= LocalPlayer then
			local chassis = indraGetChassis(car)
			if chassis then
				local distance = (chassis.Position - origin).Magnitude
				local color = indraState.CarColors[car]
				if color and indraState.MyColor and indraSameColor(color, indraState.MyColor) then
					sameTeamSeen = true
				elseif color then
					if not bestEnemyDistance or distance < bestEnemyDistance then
						bestEnemy = player
						bestEnemyDistance = distance
					end
				else
					if not bestPlainDistance or distance < bestPlainDistance then
						bestPlain = player
						bestPlainDistance = distance
					end
				end
			end
		end
	end
	if bestEnemy then
		return bestEnemy
	end
	if bestPlain then
		return bestPlain
	end
	if sameTeamSeen then
		return nil, "Only same team nearby"
	end
	return nil, "No target"
end

local function indraTeleportTo(car, targetChassis)
	local pivot = car:GetPivot()
	car:PivotTo(pivot.Rotation + targetChassis.Position)
end

local function indraFireTag(target, now)
	indraPass.lastFire = now
	pcall(function()
		TagContact:FireServer(target, Workspace:GetServerTimeNow())
	end)
end

local function indraStartPass()
	if not TagContact then
		return false, "Remote not found"
	end
	pcall(indraRefreshHighlights)
	setStatus()
	if Config.BlockWhenNotHolder and indraState.Holder ~= LocalPlayer then
		if indraState.Holder then
			return false, "Bomb is on " .. indraState.Holder.DisplayName
		end
		return false, "You don't have the bomb"
	end
	local car = indraGetCar(LocalPlayer)
	local chassis = indraGetChassis(car)
	if not car or not chassis then
		return false, "No car"
	end
	local target, reason = indraPickTarget(chassis.Position)
	if not target then
		return false, reason or "No target"
	end
	local targetChassis = indraGetChassis(indraGetCar(target))
	if not targetChassis then
		return false, "No target"
	end
	indraPass.active = true
	indraPass.target = target
	indraPass.startTime = os.clock()
	indraTeleportTo(car, targetChassis)
	indraFireTag(target, os.clock())
	return true, target.DisplayName
end

local function indraStepPass(now, car, chassis)
	if now - indraPass.startTime > Config.PassWindow then
		indraStopPass()
		return
	end
	if Config.BlockWhenNotHolder and indraState.Holder ~= LocalPlayer then
		indraStopPass()
		return
	end
	local target = indraPass.target
	if not target or not target.Parent then
		indraStopPass()
		return
	end
	local targetCar = indraGetCar(target)
	local targetChassis = indraGetChassis(targetCar)
	if not targetChassis then
		indraStopPass()
		return
	end
	local targetColor = indraState.CarColors[targetCar]
	if targetColor and indraState.MyColor and indraSameColor(targetColor, indraState.MyColor) then
		indraStopPass()
		return
	end
	local distance = (targetChassis.Position - chassis.Position).Magnitude
	if distance > Config.RetpDistance then
		indraTeleportTo(car, targetChassis)
		distance = (targetChassis.Position - chassis.Position).Magnitude
	end
	if distance <= Config.TagRange and now - indraPass.lastFire >= Config.TagInterval then
		indraFireTag(target, now)
	end
end

local function indraRemovePlatform()
	if indraFarm.platform then
		pcall(function()
			indraFarm.platform:Destroy()
		end)
		indraFarm.platform = nil
	end
end

local function indraEnsurePlatform()
	if not indraFarm.parkPosition then
		return nil
	end
	if indraFarm.platform and indraFarm.platform.Parent then
		return indraFarm.platform
	end
	local part = Instance.new("Part")
	part.Name = "Baseplate"
	part.Size = Vector3.new(Config.PlatformSize, 2, Config.PlatformSize)
	part.Transparency = Config.PlatformTransparency
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(30, 30, 30)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = false
	part.Locked = true
	part.Position = indraFarm.parkPosition - Vector3.new(0, Config.PlatformDrop, 0)
	part.Anchored = true
	part.CanCollide = true
	part.Parent = Workspace
	indraFarm.platform = part
	return part
end

local function pivotPosition(instance)
	if instance:IsA("BasePart") then
		return instance.Position
	end
	if instance:IsA("Model") then
		local ok, pivot = pcall(function()
			return instance:GetPivot()
		end)
		if ok and pivot then
			return pivot.Position
		end
	end
	return nil
end

local function findLobbyInstance(container, depth)
	if not container or depth <= 0 then
		return nil
	end
	for _, child in ipairs(container:GetChildren()) do
		if string.find(string.lower(child.Name), Config.LobbyName, 1, true) then
			local position = pivotPosition(child)
			if position then
				return position
			end
		end
		if depth > 1 and not child:IsA("BasePart") then
			local found = findLobbyInstance(child, depth - 1)
			if found then
				return found
			end
		end
	end
	return nil
end

local function findLobbyPosition()
	local direct = findLobbyInstance(Workspace, 2)
	if direct then
		return direct
	end
	local folder = indraGetVehicles()
	if not folder then
		return nil
	end
	local total = Vector3.zero
	local count = 0
	for _, car in ipairs(folder:GetChildren()) do
		local player = Players:FindFirstChild(car.Name)
		local chassis = indraGetChassis(car)
		if player and chassis and player.Team and string.find(string.lower(player.Team.Name), Config.LobbyName, 1, true) then
			total = total + chassis.Position
			count = count + 1
		end
	end
	if count > 0 then
		return total / count
	end
	return nil
end

local function awayDirection(origin)
	if not indraFarm.lobby then
		indraFarm.lobby = findLobbyPosition()
	end
	if indraFarm.lobby then
		local delta = origin - indraFarm.lobby
		local flat = Vector3.new(delta.X, 0, delta.Z)
		if flat.Magnitude > 1 then
			return flat.Unit
		end
	end
	return Vector3.new(1, 0, 0)
end

local function indraRecordGround(chassis)
	local position = chassis.Position
	if not indraFarm.ground then
		indraFarm.ground = position
	elseif math.abs(position.Y - indraFarm.ground.Y) <= Config.GroundBand then
		indraFarm.ground = position
	end
end

local function indraStepPark(car, chassis)
	if not indraFarm.parkPosition then
		if not indraFarm.ground then
			indraRecordGround(chassis)
		end
		local origin = indraFarm.ground
		if not origin then
			return
		end
		local away = awayDirection(origin)
		indraFarm.parkPosition = origin
			+ away * Config.SideOffset
			+ Vector3.new(0, Config.SkyHeight, 0)
	end
	local platform = indraEnsurePlatform()
	if not platform then
		return
	end
	local offset = chassis.Position - indraFarm.parkPosition
	local flat = Vector3.new(offset.X, 0, offset.Z).Magnitude
	if flat <= Config.PlatformSize * 0.4 and offset.Y > -Config.PlatformDrop * 2 then
		return
	end
	local pivot = car:GetPivot()
	car:PivotTo(pivot.Rotation + indraFarm.parkPosition)
end

local function indraStepFarm(now)
	if not Config.AutoFarm or indraPass.active then
		return
	end
	if indraState.Holder ~= LocalPlayer or not indraFarm.holderSince then
		return
	end
	if now - indraFarm.holderSince < Config.FarmDelay then
		return
	end
	if now - indraFarm.lastAttempt < Config.FarmRetry then
		return
	end
	indraFarm.lastAttempt = now
	indraStartPass()
end

local function indraPingAfk()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
	end)
	if AfkEvent then
		pcall(function()
			AfkEvent:FireServer(false)
		end)
	end
end

indraTrack(LocalPlayer.Idled:Connect(function()
	indraPingAfk()
end))

indraTrack(Workspace.DescendantAdded:Connect(function(instance)
	if instance:IsA("Highlight") then
		indraRegisterHighlight(instance)
	end
end))

indraTrack(Players.PlayerRemoving:Connect(function(player)
	if indraPass.target == player then
		indraStopPass()
	end
	if indraState.Holder == player then
		indraState.Holder = nil
		setStatus()
	end
end))

indraTrack(RunService.PostSimulation:Connect(function(delta)
	local now = os.clock()
	indraAfkAcc = indraAfkAcc + delta
	if indraAfkAcc >= Config.AfkPing then
		indraAfkAcc = 0
		indraPingAfk()
	end
	indraScanAcc = indraScanAcc + delta
	if indraScanAcc >= Config.ScanInterval then
		indraScanAcc = 0
		pcall(indraRefreshHighlights)
		setStatus()
		indraStepFarm(now)
	end
	local car = indraGetCar(LocalPlayer)
	local chassis = indraGetChassis(car)
	if indraPass.active then
		if not car or not chassis then
			indraStopPass()
			return
		end
		indraStepPass(now, car, chassis)
		return
	end
	if not car or not chassis then
		return
	end
	if Config.AutoFarm then
		indraStepPark(car, chassis)
	else
		indraRecordGround(chassis)
	end
end))

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = Config.GuiName,
    Author = Config.GuiFooter,
    Theme = "Dark",
    Size = UDim2.new(0, 500, 0, 400),
    Acrylic = false,
    Icon = "lucide:bomb",
})

local MainTab = Window:Tab({ Title = "Bomb", Icon = "lucide:bomb" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "lucide:settings" })

local function runPass()
    if indraPass.active then return end
    local ok, info = indraStartPass()
    if not ok then
        WindUI:Notify({ Title = "Pass Failed", Content = info, Duration = 2 })
    end
end

MainTab:Button({
    Title = "Pass Bomb",
    Desc = "Pass the bomb to the nearest opponent",
    Icon = "lucide:crosshair",
    Callback = function() runPass() end
})

MainTab:Toggle({
    Title = "Auto Farm Wins",
    Desc = "Hides you high in the sky and auto passes",
    Value = false,
    Callback = function(value)
        Config.AutoFarm = value
        indraFarm.lastAttempt = 0
        indraFarm.parkPosition = nil
        indraRemovePlatform()
    end,
})

MainTab:Toggle({
    Title = "Only when I have the bomb",
    Desc = "Blocks the indraPass while the bomb is on someone else",
    Value = true,
    Callback = function(value)
        Config.BlockWhenNotHolder = value
    end,
})

indraStatusLabel = MainTab:Paragraph({
    Title = "Bomb Status",
    Desc = IdleStatus
})

SettingsTab:Button({
    Title = "Unload",
    Desc = "Unload the script",
    Icon = "lucide:power",
    Callback = function()
        Window:Destroy()
        if genv.IndraHubDriftTagUnload then
            pcall(genv.IndraHubDriftTagUnload)
        end
    end
})

pcall(function()
	local chassis = indraGetChassis(indraGetCar(LocalPlayer))
	if chassis then
		indraRecordGround(chassis)
	end
end)
pcall(indraRefreshHighlights)
setStatus()

local function cleanup()
	for _, connection in ipairs(indraConns) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(indraConns)
	table.clear(indraState.Highlights)
	table.clear(indraState.CarColors)
	indraStopPass()
	indraState.Holder = nil
	indraState.MyColor = nil
	indraFarm.holderSince = nil
	indraFarm.parkPosition = nil
	indraFarm.ground = nil
	indraFarm.lobby = nil
	indraRemovePlatform()
	indraStatusLabel = nil
	genv.IndraHubDriftTagUnload = nil
end

	cleanup()
end)

genv.IndraHubDriftTagUnload = function()
	local ok = pcall(function()
		Window:Destroy()
	end)
	if not ok then
		cleanup()
	end
end

-- IndraHub Heartbeat
local function pingSupervisor()
    local clock = os.clock()
    if getgenv then
        getgenv().IndraHubDriftTagLastHeartbeat = clock
        getgenv().IndraHubDriftTagRunning = true
    end
end
task.spawn(function()
    while true do
        pingSupervisor()
        task.wait(1)
    end
end)
