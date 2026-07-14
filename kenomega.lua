local CONFIG = {
	TweenSpeed = 95,
	PosterCooldown = 2.3,
	ClickRadius = 10,
	ClickBurst = 36,
	ClickInterval = 0.018,
	MissionTimeout = 1.15,
	CancelTimeout = 0.8,
	MaxRerolls = 60,
	BoardName = "Corkboard",
	PostersName = "Posters",
	TargetWords = {"poster"},
}

local POSTER_POSITIONS = {
	Vector3.new(-1694.8, 95.1, -174.4),
	Vector3.new(-1681.3, 95.1, -247.4),
	Vector3.new(-1612.8, 94.1, -255.3),
	Vector3.new(-1617.8, 94.1, -219.3),
	Vector3.new(-1615.8, 94.1, -209.1),
	Vector3.new(-1612.6, 93.5, -187.8),
	Vector3.new(-1612.8, 94.1, -173.3),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local GlobalEnvironment = typeof(getgenv) == "function" and getgenv() or _G

if typeof(GlobalEnvironment.UniversePosterFarmCleanup) == "function" then
	pcall(GlobalEnvironment.UniversePosterFarmCleanup)
end

local runtime = {
	Alive = true,
	Enabled = false,
	CurrentTween = nil,
	Generation = 0,
	CollisionStates = {},
	Connections = {},
	Respawning = false,
	ForceMissionRetake = false,
	MissionRetakeRequested = false,
}

local mission = {
	Active = false,
	Description = "",
	Remaining = nil,
	Revision = 0,
}

local function clearMissionState()
	mission.Revision = mission.Revision + 1
	mission.Active = false
	mission.Description = ""
	mission.Remaining = nil
end

local function character()
	local model = LocalPlayer.Character
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or humanoid.Health <= 0 then return nil end
	return model, humanoid, root
end

local function restoreCollisions()
	for part, canCollide in pairs(runtime.CollisionStates) do
		if part and part.Parent then part.CanCollide = canCollide end
	end
	table.clear(runtime.CollisionStates)
end

local function enforceNoclip()
	if not runtime.Enabled or not runtime.CurrentTween then
		if next(runtime.CollisionStates) then restoreCollisions() end
		return
	end
	local model = LocalPlayer.Character
	if not model then return end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if runtime.CollisionStates[part] == nil then runtime.CollisionStates[part] = part.CanCollide end
			part.CanCollide = false
		end
	end
end

table.insert(runtime.Connections, RunService.Stepped:Connect(enforceNoclip))

local function lowercase(value)
	return string.lower(tostring(value or ""))
end

local function containsAny(value, words)
	local text = lowercase(value)
	if text == "" then return false end
	for _, word in ipairs(words) do
		if string.find(text, lowercase(word), 1, true) then return true end
	end
	return false
end

local function remainingFrom(text)
	local amount = string.match(tostring(text or ""), "(%d+)")
	return amount and tonumber(amount) or nil
end

local function updateMission(...)
	local count = select("#", ...)
	local args = {...}
	if runtime.Respawning then
		clearMissionState()
		return
	end
	if runtime.ForceMissionRetake and not runtime.MissionRetakeRequested then
		clearMissionState()
		return
	end
	if count == 0 or args[1] == nil then
		clearMissionState()
		return
	end
	if runtime.ForceMissionRetake then
		runtime.ForceMissionRetake = false
		runtime.MissionRetakeRequested = false
	end
	local description
	if typeof(args[1]) == "Instance" then
		description = args[2] and tostring(args[2]) or ""
	else
		description = tostring(args[1])
	end
	mission.Revision = mission.Revision + 1
	mission.Active = description ~= ""
	mission.Description = description
	mission.Remaining = remainingFrom(description)
end

local function missionRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild("Mission")
	if remote and remote:IsA("RemoteEvent") then return remote end
	return nil
end

local activeMissionRemote = missionRemote()
if activeMissionRemote then
	table.insert(runtime.Connections, activeMissionRemote.OnClientEvent:Connect(updateMission))
end

local function isPosterMission()
	if runtime.Respawning or runtime.ForceMissionRetake then return false end
	return mission.Active and containsAny(mission.Description, CONFIG.TargetWords)
end

local function fireMissionClose(button)
	if not button or typeof(getconnections) ~= "function" then return false end
	for _, signalName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
		local okSignal, signal = pcall(function() return button[signalName] end)
		if okSignal and signal then
			local okConnections, connections = pcall(getconnections, signal)
			if okConnections and connections and #connections > 0 then
				for _, connection in ipairs(connections) do
					local fired = pcall(function() connection:Fire() end)
					if not fired and connection.Function then pcall(connection.Function) end
				end
				return true
			end
		end
	end
	return false
end

local function cancelMission()
	local interface = LocalPlayer:FindFirstChild("PlayerGui")
	local missionInterface = interface and interface:FindFirstChild("Mission")
	local frame = missionInterface and missionInterface:FindFirstChild("Frame")
	local button = frame and frame:FindFirstChild("close")
	if not missionInterface or not missionInterface.Enabled then return false end
	if not frame or not frame.Visible then return false end
	if not button or not button.Visible then return false end
	return fireMissionClose(button)
end

local function fireDetector(detector)
	if not detector or typeof(fireclickdetector) ~= "function" then return false end
	local ok = pcall(fireclickdetector, detector, 0)
	if not ok then ok = pcall(fireclickdetector, detector) end
	return ok
end

local function findBoard()
	local container = workspace:FindFirstChild(CONFIG.BoardName)
	if not container then return nil, nil end
	local board = container:FindFirstChild("Board")
	local part = board and board:FindFirstChild("Color this to paint the board")
	local detector = part and part:FindFirstChild("ClickDetector")
	if detector and not detector:IsA("ClickDetector") then detector = nil end
	if not detector then detector = container:FindFirstChildWhichIsA("ClickDetector", true) end
	if not detector then return nil, nil end
	part = detector.Parent
	if not part or not part:IsA("BasePart") then
		part = container:FindFirstChildWhichIsA("BasePart", true)
	end
	return detector, part
end

local function stopMovement()
	local tween = runtime.CurrentTween
	runtime.CurrentTween = nil
	if tween then pcall(function() tween:Cancel() end) end
end

local function moveTo(position, generation)
	local _, _, root = character()
	if not root then return false end
	local distance = (position - root.Position).Magnitude
	if distance <= 1 then return true end
	local duration = math.max(0.03, distance / CONFIG.TweenSpeed)
	local target = CFrame.new(position) * root.CFrame.Rotation
	local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = target})
	runtime.CurrentTween = tween
	tween:Play()
	while tween.PlaybackState == Enum.PlaybackState.Playing do
		if not runtime.Enabled or generation ~= runtime.Generation then
			tween:Cancel()
			if runtime.CurrentTween == tween then runtime.CurrentTween = nil end
			return false
		end
		RunService.Heartbeat:Wait()
	end
	if runtime.CurrentTween == tween then runtime.CurrentTween = nil end
	restoreCollisions()
	return tween.PlaybackState == Enum.PlaybackState.Completed
end

local function waitForChange(revision, timeout, generation, predicate)
	local deadline = os.clock() + timeout
	repeat
		if not runtime.Enabled or generation ~= runtime.Generation then return false end
		if predicate and predicate() then return true end
		if mission.Revision ~= revision and not predicate then return true end
		RunService.Heartbeat:Wait()
	until os.clock() >= deadline
	return predicate and predicate() or mission.Revision ~= revision
end

local function acquirePosterMission(generation)
	if isPosterMission() then return true end
	local detector, board = findBoard()
	if not detector then
		return false
	end
	local boardPosition = board and board.Position + board.CFrame.LookVector * 4
	if boardPosition and not moveTo(boardPosition, generation) then return false end
	for attempt = 1, CONFIG.MaxRerolls do
		if not runtime.Enabled or generation ~= runtime.Generation then return false end
		if isPosterMission() then
			return true
		end
		local previousDescription = mission.Description
		if mission.Active and not containsAny(previousDescription, CONFIG.TargetWords) then
			for _ = 1, 3 do
				local revision = mission.Revision
				if not cancelMission() then break end
				waitForChange(revision, CONFIG.CancelTimeout, generation, function()
						return not mission.Active
				end)
				if not mission.Active then break end
			end
			if mission.Active then
				return false
			end
		end
		if not runtime.Enabled or generation ~= runtime.Generation then return false end
		local revision = mission.Revision
		if runtime.ForceMissionRetake then runtime.MissionRetakeRequested = true end
		fireDetector(detector)
		waitForChange(revision, CONFIG.MissionTimeout, generation, function()
			return mission.Active
		end)
	end
	return false
end

local function orderedPositions(origin)
	local remaining = table.clone(POSTER_POSITIONS)
	local result = {}
	local current = origin
	while #remaining > 0 do
		local bestIndex = 1
		local bestDistance = math.huge
		for index, position in ipairs(remaining) do
			local distance = (position - current).Magnitude
			if distance < bestDistance then
				bestIndex = index
				bestDistance = distance
			end
		end
		local selected = table.remove(remaining, bestIndex)
		table.insert(result, selected)
		current = selected
	end
	return result
end

local function posterDetectors()
	local container = workspace:FindFirstChild(CONFIG.PostersName)
	local map = {}
	if not container then return map end
	local detectors = {}
	for _, object in ipairs(container:GetDescendants()) do
		if object:IsA("ClickDetector") then table.insert(detectors, object) end
	end
	for index, position in ipairs(POSTER_POSITIONS) do
		local best
		local bestDistance = CONFIG.ClickRadius
		for _, detector in ipairs(detectors) do
			local part = detector.Parent
			if part and part:IsA("BasePart") then
				local distance = (part.Position - position).Magnitude
				if distance <= bestDistance then
					best = detector
					bestDistance = distance
				end
			end
		end
		map[index] = best
	end
	return map
end

local function detectorFor(position, map)
	local best
	local bestDistance = CONFIG.ClickRadius
	for index, knownPosition in ipairs(POSTER_POSITIONS) do
		local distance = (knownPosition - position).Magnitude
		if distance <= bestDistance and map[index] then
			best = map[index]
			bestDistance = distance
		end
	end
	return best
end

local function clickPoster(position, map, generation)
	local detector = detectorFor(position, map)
	if not detector then
		return false
	end
	local startingRevision = mission.Revision
	local startingProgress = mission.Remaining
	for _ = 1, CONFIG.ClickBurst do
		if not runtime.Enabled or generation ~= runtime.Generation then return false end
		if not isPosterMission() then return true end
		fireDetector(detector)
		if mission.Revision ~= startingRevision then
			if not mission.Active then return true end
			if startingProgress and mission.Remaining and mission.Remaining < startingProgress then return true end
		end
		task.wait(CONFIG.ClickInterval)
	end
	return true
end

local function cooldown(generation)
	local deadline = os.clock() + CONFIG.PosterCooldown
	while os.clock() < deadline do
		if not runtime.Enabled or generation ~= runtime.Generation or not isPosterMission() then return false end
		RunService.Heartbeat:Wait()
	end
	return true
end

local function farmMission(generation)
	local _, _, root = character()
	if not root then return false end
	local map = posterDetectors()
	local order = orderedPositions(root.Position)
	for index, position in ipairs(order) do
		if not runtime.Enabled or generation ~= runtime.Generation then return false end
		if not isPosterMission() then return true end
		if not moveTo(position, generation) then return false end
		if not clickPoster(position, map, generation) then return false end
		if not isPosterMission() then return true end
		if not cooldown(generation) then return not isPosterMission() end
	end
	return true
end

local function beginRespawnRecovery()
	if runtime.Respawning then return end
	runtime.Respawning = true
	runtime.Enabled = false
	runtime.Generation = runtime.Generation + 1
	runtime.ForceMissionRetake = false
	runtime.MissionRetakeRequested = false
	stopMovement()
	restoreCollisions()
	clearMissionState()
end

local function recoverAfterRespawn(model)
	beginRespawnRecovery()
	task.spawn(function()
		local root = model:WaitForChild("HumanoidRootPart", 10)
		if not root or LocalPlayer.Character ~= model or not runtime.Alive then return end
		task.wait(3)
		if LocalPlayer.Character ~= model or not runtime.Alive then return end
		clearMissionState()
		runtime.ForceMissionRetake = true
		runtime.MissionRetakeRequested = false
		runtime.Respawning = false
		runtime.Enabled = true
		runtime.Generation = runtime.Generation + 1
	end)
end

table.insert(runtime.Connections, LocalPlayer.CharacterRemoving:Connect(function()
	beginRespawnRecovery()
end))
table.insert(runtime.Connections, LocalPlayer.CharacterAdded:Connect(recoverAfterRespawn))

local function automation()
	while runtime.Alive do
		if runtime.Enabled and not runtime.Respawning then
			local generation = runtime.Generation
			local _, _, root = character()
			if not root then
				repeat RunService.Heartbeat:Wait() until not runtime.Enabled or character()
			elseif not isPosterMission() then
				acquirePosterMission(generation)
			elseif generation == runtime.Generation then
				farmMission(generation)
			end
		else
			RunService.Heartbeat:Wait()
		end
		RunService.Heartbeat:Wait()
	end
end

GlobalEnvironment.UniversePosterFarmCleanup = function()
	if not runtime.Alive then return end
	runtime.Alive = false
	runtime.Enabled = false
	runtime.Generation = runtime.Generation + 1
	stopMovement()
	restoreCollisions()
	for _, connection in ipairs(runtime.Connections) do
		pcall(function() connection:Disconnect() end)
	end
	runtime.Connections = {}
end

-- ==========================================
-- INDRAHUB & WINDUI INTEGRATION
-- ==========================================

-- Supervisor Heartbeat
task.spawn(function()
    while task.wait(1) do
        if getgenv then
            getgenv().IndraHubKenomegaRunning = true
            getgenv().IndraHubKenomegaLastHeartbeat = os.time()
        end
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Auto Poster",
    Icon = "rbxassetid://10683767",
    Author = "IndraHub Premium",
    Folder = "IndraHub_Kenomega",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

-- ==========================================
-- 1. MAIN FARM TAB
-- ==========================================
local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "swords" })

FarmTab:Section({ Title = "Poster Mission Farm", TextSize = 16 })
FarmTab:Toggle({
    Title = "Enable Auto Poster",
    Desc = "Automatically accepts and completes poster missions",
    Callback = function(state)
        runtime.Enabled = state
        runtime.Generation = runtime.Generation + 1
    end,
})

FarmTab:Button({
    Title = "Force Cleanup & Stop",
    Desc = "Stops the farm and restores collisions instantly",
    Callback = function()
        if typeof(GlobalEnvironment.UniversePosterFarmCleanup) == "function" then
            pcall(GlobalEnvironment.UniversePosterFarmCleanup)
        end
    end,
})

-- ==========================================
-- 2. SETTINGS & CREDITS
-- ==========================================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Section({ Title = "Community", TextSize = 16 })
SettingsTab:Button({
    Title = "Join our Discord",
    Desc = "Click to copy invite link: https://discord.gg/2PPBJsmqr",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/2PPBJsmqr")
            WindUI:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard." })
        end
    end,
})

Window:SelectTab(1)
task.spawn(automation)
print("[IndraHub] Auto Poster loaded.")
