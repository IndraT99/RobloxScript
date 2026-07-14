local IndraSettings = {
	TweenSpeed = 95,
	TargetCooldown = 2.3,
	InteractRadius = 10,
	InteractBurst = 36,
	ClickInterval = 0.018,
	JobTimeout = 1.15,
	AbortTimeout = 0.8,
	MaxRerolls = 60,
	AntiAFK = true,
	PosterESP = false,
	BoardName = "Corkboard",
	PostersName = "Posters",
	TargetWords = {"poster"},
}


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local GlobalEnvironment = typeof(getgenv) == "function" and getgenv() or _G

-- [INDRAHUB CORE MODULES]
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
	if IndraSettings.AntiAFK then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

local function updateESP()
	pcall(function()
		local espFolder = game.CoreGui:FindFirstChild("IndraESP_Kenomega")
		if not espFolder then
			espFolder = Instance.new("Folder")
			espFolder.Name = "IndraESP_Kenomega"
			espFolder.Parent = game.CoreGui
		end
		espFolder:ClearAllChildren()
		if not IndraSettings.PosterESP then return end
		
		for i, loc in ipairs(TARGET_LOCATIONS) do
			local p = Instance.new("Part")
			p.Size = Vector3.new(1, 1, 1)
			p.Position = loc
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 1
			p.Parent = espFolder
			local hl = Instance.new("Highlight")
			hl.Adornee = p
			hl.FillColor = Color3.new(1, 0.2, 0.2)
			hl.OutlineColor = Color3.new(1, 0, 0)
			hl.Parent = espFolder
		end
	end)
end


if typeof(GlobalEnvironment.IndraFarmCleanup) == "function" then
	pcall(GlobalEnvironment.IndraFarmCleanup)
end

local IndraState = {
	Alive = true,
	Enabled = false,
	ActiveMovement = nil,
	ExecutionCycle = 0,
	CollisionCache = {},
	Connections = {},
	Respawning = false,
	ForceJobRefresh = false,
	JobRefreshPending = false,
}

local JobData = {
	Active = false,
	Description = "",
	Remaining = nil,
	Revision = 0,
}

local function resetJobData()
	JobData.Revision = JobData.Revision + 1
	JobData.Active = false
	JobData.Description = ""
	JobData.Remaining = nil
end

local function getIndraChar()
	local model = LocalPlayer.Character
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or humanoid.Health <= 0 then return nil end
	return model, humanoid, root
end

local function restoreCollisions()
	for part, canCollide in pairs(IndraState.CollisionCache) do
		if part and part.Parent then part.CanCollide = canCollide end
	end
	table.clear(IndraState.CollisionCache)
end

local function IndraGhostMode()
	if not IndraState.Enabled or not IndraState.ActiveMovement then
		if next(IndraState.CollisionCache) then restoreCollisions() end
		return
	end
	local model = LocalPlayer.Character
	if not model then return end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if IndraState.CollisionCache[part] == nil then IndraState.CollisionCache[part] = part.CanCollide end
			part.CanCollide = false
		end
	end
end

table.insert(IndraState.Connections, RunService.Stepped:Connect(IndraGhostMode))

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
	if IndraState.Respawning then
		resetJobData()
		return
	end
	if IndraState.ForceJobRefresh and not IndraState.JobRefreshPending then
		resetJobData()
		return
	end
	if count == 0 or args[1] == nil then
		resetJobData()
		return
	end
	if IndraState.ForceJobRefresh then
		IndraState.ForceJobRefresh = false
		IndraState.JobRefreshPending = false
	end
	local description
	if typeof(args[1]) == "Instance" then
		description = args[2] and tostring(args[2]) or ""
	else
		description = tostring(args[1])
	end
	JobData.Revision = JobData.Revision + 1
	JobData.Active = description ~= ""
	JobData.Description = description
	JobData.Remaining = remainingFrom(description)
end

local function missionRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild("Mission")
	if remote and remote:IsA("RemoteEvent") then return remote end
	return nil
end

local activeMissionRemote = missionRemote()
if activeMissionRemote then
	table.insert(IndraState.Connections, activeMissionRemote.OnClientEvent:Connect(updateMission))
end

local function IsBountyActive()
	if IndraState.Respawning or IndraState.ForceJobRefresh then return false end
	return JobData.Active and containsAny(JobData.Description, IndraSettings.TargetWords)
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
	local container = workspace:FindFirstChild(IndraSettings.BoardName)
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
	local tween = IndraState.ActiveMovement
	IndraState.ActiveMovement = nil
	if tween then pcall(function() tween:Cancel() end) end
end

local function NavigateToTarget(position, generation)
	local _, _, root = getIndraChar()
	if not root then return false end
	local distance = (position - root.Position).Magnitude
	if distance <= 1 then return true end
	local duration = math.max(0.03, distance / IndraSettings.TweenSpeed)
	local target = CFrame.new(position) * root.CFrame.Rotation
	local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = target})
	IndraState.ActiveMovement = tween
	tween:Play()
	while tween.PlaybackState == Enum.PlaybackState.Playing do
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then
			tween:Cancel()
			if IndraState.ActiveMovement == tween then IndraState.ActiveMovement = nil end
			return false
		end
		RunService.Heartbeat:Wait()
	end
	if IndraState.ActiveMovement == tween then IndraState.ActiveMovement = nil end
	restoreCollisions()
	return tween.PlaybackState == Enum.PlaybackState.Completed
end

local function waitForChange(revision, timeout, generation, predicate)
	local deadline = os.clock() + timeout
	repeat
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then return false end
		if predicate and predicate() then return true end
		if JobData.Revision ~= revision and not predicate then return true end
		RunService.Heartbeat:Wait()
	until os.clock() >= deadline
	return predicate and predicate() or JobData.Revision ~= revision
end

local function SnatchBounty(generation)
	if IsBountyActive() then return true end
	local detector, board = findBoard()
	if not detector then
		return false
	end
	local boardPosition = board and board.Position + board.CFrame.LookVector * 4
	if boardPosition and not NavigateToTarget(boardPosition, generation) then return false end
	for attempt = 1, IndraSettings.MaxRerolls do
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then return false end
		if IsBountyActive() then
			return true
		end
		local previousDescription = JobData.Description
		if JobData.Active and not containsAny(previousDescription, IndraSettings.TargetWords) then
			for _ = 1, 3 do
				local revision = JobData.Revision
				if not cancelMission() then break end
				waitForChange(revision, IndraSettings.AbortTimeout, generation, function()
						return not JobData.Active
				end)
				if not JobData.Active then break end
			end
			if JobData.Active then
				return false
			end
		end
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then return false end
		local revision = JobData.Revision
		if IndraState.ForceJobRefresh then IndraState.JobRefreshPending = true end
		fireDetector(detector)
		waitForChange(revision, IndraSettings.JobTimeout, generation, function()
			return JobData.Active
		end)
	end
	return false
end

local function SortDistances(origin)
	local remaining = table.clone(TARGET_LOCATIONS)
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

local function ScanTargets()
	local container = workspace:FindFirstChild(IndraSettings.PostersName)
	local map = {}
	if not container then return map end
	local detectors = {}
	for _, object in ipairs(container:GetDescendants()) do
		if object:IsA("ClickDetector") then table.insert(detectors, object) end
	end
	for index, position in ipairs(TARGET_LOCATIONS) do
		local best
		local bestDistance = IndraSettings.InteractRadius
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
	local bestDistance = IndraSettings.InteractRadius
	for index, knownPosition in ipairs(TARGET_LOCATIONS) do
		local distance = (knownPosition - position).Magnitude
		if distance <= bestDistance and map[index] then
			best = map[index]
			bestDistance = distance
		end
	end
	return best
end

local function TriggerInteraction(position, map, generation)
	local detector = detectorFor(position, map)
	if not detector then
		return false
	end
	local startingRevision = JobData.Revision
	local startingProgress = JobData.Remaining
	for _ = 1, IndraSettings.InteractBurst do
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then return false end
		if not IsBountyActive() then return true end
		fireDetector(detector)
		if JobData.Revision ~= startingRevision then
			if not JobData.Active then return true end
			if startingProgress and JobData.Remaining and JobData.Remaining < startingProgress then return true end
		end
		task.wait(IndraSettings.ClickInterval)
	end
	return true
end

local function cooldown(generation)
	local deadline = os.clock() + IndraSettings.TargetCooldown
	while os.clock() < deadline do
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle or not IsBountyActive() then return false end
		RunService.Heartbeat:Wait()
	end
	return true
end

local function ExecuteBounty(generation)
	local _, _, root = getIndraChar()
	if not root then return false end
	local map = ScanTargets()
	local order = SortDistances(root.Position)
	for index, position in ipairs(order) do
		if not IndraState.Enabled or generation ~= IndraState.ExecutionCycle then return false end
		if not IsBountyActive() then return true end
		if not NavigateToTarget(position, generation) then return false end
		if not TriggerInteraction(position, map, generation) then return false end
		if not IsBountyActive() then return true end
		if not cooldown(generation) then return not IsBountyActive() end
	end
	return true
end

local function IndraRespawnProtocol()
	if IndraState.Respawning then return end
	IndraState.Respawning = true
	IndraState.Enabled = false
	IndraState.ExecutionCycle = IndraState.ExecutionCycle + 1
	IndraState.ForceJobRefresh = false
	IndraState.JobRefreshPending = false
	stopMovement()
	restoreCollisions()
	resetJobData()
end

local function IndraRecoveryPhase(model)
	IndraRespawnProtocol()
	task.spawn(function()
		local root = model:WaitForChild("HumanoidRootPart", 10)
		if not root or LocalPlayer.Character ~= model or not IndraState.Alive then return end
		task.wait(3)
		if LocalPlayer.Character ~= model or not IndraState.Alive then return end
		resetJobData()
		IndraState.ForceJobRefresh = true
		IndraState.JobRefreshPending = false
		IndraState.Respawning = false
		IndraState.Enabled = true
		IndraState.ExecutionCycle = IndraState.ExecutionCycle + 1
	end)
end

table.insert(IndraState.Connections, LocalPlayer.CharacterRemoving:Connect(function()
	IndraRespawnProtocol()
end))
table.insert(IndraState.Connections, LocalPlayer.CharacterAdded:Connect(IndraRecoveryPhase))

local function IndraEngineCore()
	while IndraState.Alive do
		if IndraState.Enabled and not IndraState.Respawning then
			local generation = IndraState.ExecutionCycle
			local _, _, root = getIndraChar()
			if not root then
				repeat RunService.Heartbeat:Wait() until not IndraState.Enabled or getIndraChar()
			elseif not IsBountyActive() then
				SnatchBounty(generation)
			elseif generation == IndraState.ExecutionCycle then
				ExecuteBounty(generation)
			end
		else
			RunService.Heartbeat:Wait()
		end
		RunService.Heartbeat:Wait()
	end
end

GlobalEnvironment.IndraFarmCleanup = function()
	if not IndraState.Alive then return end
	IndraState.Alive = false
	IndraState.Enabled = false
	IndraState.ExecutionCycle = IndraState.ExecutionCycle + 1
	stopMovement()
	restoreCollisions()
	for _, connection in ipairs(IndraState.Connections) do
		pcall(function() connection:Disconnect() end)
	end
	IndraState.Connections = {}
end

local TARGET_LOCATIONS = {
	Vector3.new(-1694.8, 95.1, -174.4),
	Vector3.new(-1681.3, 95.1, -247.4),
	Vector3.new(-1612.8, 94.1, -255.3),
	Vector3.new(-1617.8, 94.1, -219.3),
	Vector3.new(-1615.8, 94.1, -209.1),
	Vector3.new(-1612.6, 93.5, -187.8),
	Vector3.new(-1612.8, 94.1, -173.3),
}

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
        IndraState.Enabled = state
        IndraState.ExecutionCycle = IndraState.ExecutionCycle + 1
    end,
})

FarmTab:Button({
    Title = "Force Cleanup & Stop",
    Desc = "Stops the farm and restores collisions instantly",
    Callback = function()
        if typeof(GlobalEnvironment.IndraFarmCleanup) == "function" then
            pcall(GlobalEnvironment.IndraFarmCleanup)
        end
    end,
})


FarmTab:Section({ Title = "Advanced Features", TextSize = 16 })
FarmTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents you from disconnecting due to inactivity",
    Value = IndraSettings.AntiAFK,
    Callback = function(state)
        IndraSettings.AntiAFK = state
    end,
})

FarmTab:Toggle({
    Title = "Poster Location ESP",
    Desc = "Highlights poster locations through walls",
    Value = IndraSettings.PosterESP,
    Callback = function(state)
        IndraSettings.PosterESP = state
        updateESP()
    end,
})

FarmTab:Slider({
    Title = "Tween Speed",
    Desc = "Adjusts character movement speed",
    Step = 1,
    Value = IndraSettings.TweenSpeed,
    Max = 200,
    Min = 50,
    Callback = function(val)
        IndraSettings.TweenSpeed = val
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
task.spawn(IndraEngineCore)
print("[IndraHub] Auto Poster loaded.")
