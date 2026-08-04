local Settings = {
	Title = "IndraHub DOD",
	Credits = "IndraHub Premium",
	Bind = "RightControl",
	SpheresDir = "Balls",
	TrainingArea = { "Lobby", "PracticeArea", "PracticeBalls" },
	SphereTags = { "ball", "practice" },
	DetectionRange = 200,
	HitboxX = 10,
	HitboxY = 10,
	HitboxZ = 10,
	HitboxYOff = 0,
	MaxVelocityStep = 4,
	CriticalVelocityStep = 9,
	ForecastSpan = 0.12,
	AheadSpan = 0.35,
	CriticalSpan = 0.16,
	BufferSpace = 0.35,
	AvoidSpace = 0.6,
	MaxSlices = 20,
	SliceLength = 2,
	CalcIterations = 3,
	ForecastEnabled = true,
	YAxisAvoidance = true,
	MaintainSpeed = true,
	DisableDrag = true,
	DragTolerance = 0.02,
	MiddleDeadzone = 0.6,
	CommitDuration = 0.4,
	MoveSmoothing = 0.55,
	CriticalSmoothing = 1,
	MinVelocityStep = 0.03,
	YDamping = 0.35,
	LowSpeedThreshold = 2,
	ProbeDistance = 14,
	MinClearance = 5,
	WallOffset = 1.2,
	FloorDrop = 60,
	UpdateRate = 0.2,
	MinTargetSpeed = 4,
	MinTargetSize = 3,
	MaxTargets = 24,
}

local clonefunc = cloneref or function(obj) return obj end

local SvcPlayers = clonefunc(game:GetService("Players"))
local SvcRun = clonefunc(game:GetService("RunService"))
local SvcGui = clonefunc(game:GetService("CoreGui"))
local SvcWorkspace = clonefunc(game:GetService("Workspace"))
local LocalClient = SvcPlayers.LocalPlayer

local v3New = Vector3.new
local v3Zero = Vector3.zero
local mHuge = math.huge
local mMin = math.min
local mMax = math.max
local mAbs = math.abs
local mCeil = math.ceil
local mClamp = math.clamp
local tInsert = table.insert
local tClear = table.clear
local timeNow = os.clock
local strLower = string.lower
local strFind = string.find

local uiContainer = SvcGui
if gethui then
	local success, h = pcall(gethui)
	if success and h then
		uiContainer = h
	end
end

if getgenv().IndraUnload then
	pcall(getgenv().IndraUnload)
	getgenv().IndraUnload = nil
end

local AppState = {
	AutoEvade = false,
}

local ActiveConnections = {}
local TargetCache = {}
local TargetVelocities = {}
local TargetSamples = {}
local ObstructedPaths = {}

local Char, Hum, RootPart
local MainContainer, TrainContainer
local lastUpdateTime = 0
local escapeDirection = 1
local escapeChosenTime = 0
local lastActionTime = 0

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function registerConn(conn)
	tInsert(ActiveConnections, conn)
	return conn
end

local function refreshFilter()
	local ignoreList = {}
	if Char then tInsert(ignoreList, Char) end
	if MainContainer then tInsert(ignoreList, MainContainer) end
	if TrainContainer then tInsert(ignoreList, TrainContainer) end
	rayParams.FilterDescendantsInstances = ignoreList
end

local function setupCharacter(model)
	Char = model
	Hum = model:FindFirstChildOfClass("Humanoid") or model:WaitForChild("Humanoid", 5)
	RootPart = model:FindFirstChild("HumanoidRootPart") or model:WaitForChild("HumanoidRootPart", 5)
	refreshFilter()
end

if LocalClient.Character then
	setupCharacter(LocalClient.Character)
end

registerConn(LocalClient.CharacterAdded:Connect(setupCharacter))

local function digPath(startNode, pathList)
	local curr = startNode
	for _, n in ipairs(pathList) do
		if not curr then return nil end
		curr = curr:FindFirstChild(n)
	end
	return curr
end

local function checkTags(objName)
	local lName = strLower(objName)
	for _, tag in ipairs(Settings.SphereTags) do
		if strFind(lName, tag, 1, true) then
			return true
		end
	end
	return false
end

local function checkPlayerOwner(obj)
	local m = obj:FindFirstAncestorOfClass("Model")
	while m do
		if SvcPlayers:GetPlayerFromCharacter(m) then
			return true
		end
		m = m:FindFirstAncestorOfClass("Model")
	end
	return false
end

local function isValidTarget(p)
	if not p:IsA("Part") then return false end
	if p.Shape ~= Enum.PartType.Ball then return false end
	if p.Size.X < Settings.MinTargetSize then return false end
	if p.AssemblyLinearVelocity.Magnitude < Settings.MinTargetSpeed then return false end
	return not checkPlayerOwner(p)
end

local function gatherTargets(folder, list, memo)
	for _, desc in ipairs(folder:GetDescendants()) do
		if desc:IsA("BasePart") and not memo[desc] then
			memo[desc] = true
			tInsert(list, desc)
		end
	end
end

local function updateTargets(currentT)
	if currentT - lastUpdateTime < Settings.UpdateRate then return end
	lastUpdateTime = currentT
	local needsRescan = false
	if not MainContainer or not MainContainer.Parent then
		MainContainer = SvcWorkspace:FindFirstChild(Settings.SpheresDir)
		needsRescan = true
	end
	if not TrainContainer or not TrainContainer.Parent then
		TrainContainer = digPath(SvcWorkspace, Settings.TrainingArea)
		needsRescan = true
	end
	if needsRescan then refreshFilter() end
	
	local found = {}
	local memo = {}
	if MainContainer then gatherTargets(MainContainer, found, memo) end
	if TrainContainer then gatherTargets(TrainContainer, found, memo) end
	
	for _, c in ipairs(SvcWorkspace:GetChildren()) do
		if c ~= MainContainer and not SvcPlayers:GetPlayerFromCharacter(c) then
			if c:IsA("BasePart") then
				if not memo[c] and (checkTags(c.Name) or isValidTarget(c)) then
					memo[c] = true
					tInsert(found, c)
				end
			elseif c:IsA("Folder") or c:IsA("Model") then
				if checkTags(c.Name) then
					gatherTargets(c, found, memo)
				else
					for _, s in ipairs(c:GetChildren()) do
						if s:IsA("BasePart") and not memo[s] then
							if checkTags(s.Name) or isValidTarget(s) then
								memo[s] = true
								tInsert(found, s)
							end
						end
					end
				end
			end
		end
	end
	
	tClear(TargetCache)
	for i, tPart in ipairs(found) do
		if i > Settings.MaxTargets then break end
		tInsert(TargetCache, tPart)
	end
	
	for tPart in pairs(TargetSamples) do
		if not tPart.Parent then
			TargetSamples[tPart] = nil
			TargetVelocities[tPart] = nil
		end
	end
end

local function estimateVelocity(tPart, pos, currentT)
	local v = tPart.AssemblyLinearVelocity
	if v.Magnitude > 1 then
		TargetVelocities[tPart] = v
		TargetSamples[tPart] = { pos, currentT }
		return v
	end
	local s = TargetSamples[tPart]
	if s then
		local dt = currentT - s[2]
		if dt > 0.05 then
			local calcV = (pos - s[1]) / dt
			TargetVelocities[tPart] = calcV
			TargetSamples[tPart] = { pos, currentT }
			return calcV
		end
		return TargetVelocities[tPart] or v
	end
	TargetSamples[tPart] = { pos, currentT }
	return TargetVelocities[tPart] or v
end

local function getHitboxDistance(localP, r)
	local dx = mAbs(localP.X) - (Settings.HitboxX * 0.5 + r)
	local dy = mAbs(localP.Y - Settings.HitboxYOff) - (Settings.HitboxY * 0.5 + r)
	local dz = mAbs(localP.Z) - (Settings.HitboxZ * 0.5 + r)
	return mMax(dx, mMax(dy, dz))
end

local function checkClearance(orig, dir)
	local hit = SvcWorkspace:Raycast(orig, dir * Settings.ProbeDistance, rayParams)
	if not hit then return Settings.ProbeDistance end
	return hit.Distance
end

local function determineEscapeSide(cframe, latWorld, latOffset, currentT)
	local pref
	if mAbs(latOffset) > Settings.MiddleDeadzone then
		pref = latOffset >= 0 and -1 or 1
	else
		pref = escapeDirection
	end
	if currentT - escapeChosenTime < Settings.CommitDuration then
		return escapeDirection
	end
	local orig = cframe.Position
	local space = checkClearance(orig, latWorld * pref)
	if space < Settings.MinClearance then
		local otherSpace = checkClearance(orig, latWorld * -pref)
		if otherSpace > space then
			pref = -pref
		end
	end
	if pref ~= escapeDirection then
		escapeDirection = pref
		escapeChosenTime = currentT
	end
	return escapeDirection
end

local function getAxialExtent(ax)
	return Settings.HitboxX * 0.5 * mAbs(ax.X)
		+ Settings.HitboxY * 0.5 * mAbs(ax.Y)
		+ Settings.HitboxZ * 0.5 * mAbs(ax.Z)
end

local function calculateStaticEscape(localP, r)
	local hX = Settings.HitboxX * 0.5 + r + Settings.BufferSpace
	local hY = Settings.HitboxY * 0.5 + r + Settings.BufferSpace
	local hZ = Settings.HitboxZ * 0.5 + r + Settings.BufferSpace
	local oY = localP.Y - Settings.HitboxYOff
	local px = hX - mAbs(localP.X)
	local py = hY - mAbs(oY)
	local pz = hZ - mAbs(localP.Z)
	
	if px <= 0 or py <= 0 or pz <= 0 then return nil end
	
	local ax = "X"
	local dep = px
	if pz < dep then ax = "Z"; dep = pz end
	if Settings.YAxisAvoidance and py * (1 / Settings.YDamping) < dep then
		ax = "Y"; dep = py
	end
	
	if ax == "X" then return localP.X >= 0 and v3New(-1, 0, 0) or v3New(1, 0, 0), dep end
	if ax == "Z" then return localP.Z >= 0 and v3New(0, 0, -1) or v3New(0, 0, 1), dep end
	return oY >= 0 and v3New(0, -1, 0) or v3New(0, 1, 0), dep
end

local function getSafeDistance(orig, dir, dist)
	local hit = SvcWorkspace:Raycast(orig, dir * (dist + Settings.WallOffset), rayParams)
	if not hit then return dist end
	local allow = hit.Distance - Settings.WallOffset
	if allow <= 0.05 then return 0 end
	return mMin(dist, allow)
end

local function removeDrag(force)
	if not Settings.DisableDrag then return force end
	for i = 1, #ObstructedPaths do
		local ax = ObstructedPaths[i]
		local dot = force:Dot(ax)
		if dot > 0 then force = force - ax * dot end
	end
	return force
end

local function executeMove(force, isCritical, currentT)
	force = removeDrag(force)
	local len = force.Magnitude
	if len < Settings.MinVelocityStep then return false end
	
	local dir = force.Unit
	if isCritical then
		len = mMin(len * Settings.CriticalSmoothing, Settings.CriticalVelocityStep)
	else
		len = mMin(len * Settings.MoveSmoothing, Settings.MaxVelocityStep)
	end
	
	if len < Settings.MinVelocityStep then return false end
	local orig = RootPart.Position
	local allow = getSafeDistance(orig, dir, len)
	
	if allow <= 0.02 then
		local lat = v3New(-dir.Z, 0, dir.X)
		if lat.Magnitude < 0.05 then return false end
		lat = removeDrag(lat.Unit)
		if lat.Magnitude < 0.05 then return false end
		lat = lat.Unit
		
		local latAllow = getSafeDistance(orig, lat, len)
		if latAllow <= 0.02 then
			local flip = removeDrag(-lat)
			if flip.Magnitude < 0.05 then return false end
			lat = flip.Unit
			latAllow = getSafeDistance(orig, lat, len)
		end
		if latAllow <= 0.02 then return false end
		
		escapeDirection = -escapeDirection
		escapeChosenTime = currentT
		dir = lat
		allow = latAllow
	end
	
	local moveVec = dir * allow
	local dest = orig + moveVec
	if mAbs(moveVec.Y) < 0.05 then
		local floor = SvcWorkspace:Raycast(dest + v3New(0, 5, 0), v3New(0, -Settings.FloorDrop, 0), rayParams)
		if not floor then return false end
	end
	
	local oldV = RootPart.AssemblyLinearVelocity
	RootPart.CFrame = RootPart.CFrame + moveVec
	if Settings.MaintainSpeed then
		RootPart.AssemblyLinearVelocity = oldV
	end
	return true
end

local function calculateAvoidance(currentT, dTime)
	local cf = RootPart.CFrame
	local orig = cf.Position
	local myV = RootPart.AssemblyLinearVelocity
	local fSpan = dTime + (Settings.ForecastEnabled and Settings.ForecastSpan or 0)
	local aSpan = fSpan + Settings.AheadSpan
	local totalForce = v3Zero
	local isCrit = false
	local evasionCount = 0
	
	tClear(ObstructedPaths)
	
	for _, tPart in ipairs(TargetCache) do
		if tPart.Parent then
			local pos = tPart.Position
			if (pos - orig).Magnitude < Settings.DetectionRange then
				local r = tPart.Size.X * 0.5
				local v = estimateVelocity(tPart, pos, currentT)
				local rel = v - myV
				local spd = rel.Magnitude
				local trav = rel * aSpan
				local slices = 1
				local tSpan = trav.Magnitude
				
				if tSpan > Settings.SliceLength then
					slices = mClamp(mCeil(tSpan / Settings.SliceLength), 1, Settings.MaxSlices)
				end
				
				local isThreat = false
				local tTime = mHuge
				
				for sIdx = 0, slices do
					local frac = sIdx / slices
					local sPoint = pos + trav * frac
					local lPoint = cf:PointToObjectSpace(sPoint)
					if getHitboxDistance(lPoint, r) < Settings.BufferSpace then
						isThreat = true
						tTime = frac * aSpan
						break
					end
				end
				
				if isThreat then
					local esc = nil
					if spd > Settings.LowSpeedThreshold then
						local app = rel.Unit
						tInsert(ObstructedPaths, app)
						local lat = v3New(app.Z, 0, -app.X)
						if lat.Magnitude > 0.05 then
							lat = lat.Unit
							local offsetV = pos - orig
							local sep = offsetV:Dot(lat)
							local sSign = determineEscapeSide(cf, lat, sep, currentT)
							local lLat = cf:VectorToObjectSpace(lat)
							local width = getAxialExtent(lLat) + r + Settings.BufferSpace + Settings.AvoidSpace
							local req = width - mAbs(sep)
							if sep * sSign > 0 then
								req = width + mAbs(sep)
							end
							if req > 0 then
								esc = lat * sSign * req
							end
						end
					end
					if not esc then
						local lPoint = cf:PointToObjectSpace(pos)
						local pDir, pDep = calculateStaticEscape(lPoint, r)
						if pDir then
							esc = cf:VectorToWorldSpace(pDir) * pDep
						end
					end
					if esc then
						if tTime <= Settings.CriticalSpan then isCrit = true end
						totalForce = totalForce + esc
						evasionCount = evasionCount + 1
					end
				end
			end
		end
	end
	
	if evasionCount == 0 then return false end
	lastActionTime = currentT
	totalForce = v3New(totalForce.X, totalForce.Y * Settings.YDamping, totalForce.Z)
	return executeMove(totalForce, isCrit, currentT)
end

local function stepEvasion(dt, passes)
	if not AppState.AutoEvade then return end
	local t = timeNow()
	updateTargets(t)
	if not RootPart or not RootPart.Parent or not Hum or Hum.Health <= 0 then return end
	if t - lastActionTime > 1 then escapeChosenTime = 0 end
	
	for _ = 1, passes do
		if not calculateAvoidance(t, dt) then break end
	end
end

registerConn(SvcRun.PreSimulation:Connect(function(dt) stepEvasion(dt, 1) end))
registerConn(SvcRun.PostSimulation:Connect(function(dt) stepEvasion(dt, Settings.CalcIterations) end))

local gEnv = getgenv and getgenv() or _G
local runtimeId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

local function exposeGlobal(k, v)
	rawset(_G, k, v)
	if gEnv ~= _G then gEnv[k] = v end
end

local function fetchGlobal(k)
	local v = rawget(_G, k)
	if v ~= nil then return v end
	return gEnv[k]
end

exposeGlobal("IndraHubDodgeOrDieRunning", true)
exposeGlobal("IndraHubDodgeOrDieSession", runtimeId)
exposeGlobal("IndraHubDodgeOrDieLastHeartbeat", os.clock())
exposeGlobal("IndraHubDodgeOrDieError", nil)

local function isEngineActive()
	return fetchGlobal("IndraHubDodgeOrDieRunning") and fetchGlobal("IndraHubDodgeOrDieSession") == runtimeId
end

task.spawn(function()
	while isEngineActive() do
		exposeGlobal("IndraHubDodgeOrDieLastHeartbeat", os.clock())
		task.wait(2)
	end
end)

local function fetchSource(url, fileCache)
	if type(readfile) == "function" then
		local success, body = pcall(readfile, fileCache)
		if success and type(body) == "string" and #body > 1000 then return body end
	end
	local body = game:HttpGet(url)
	if type(writefile) == "function" then pcall(function() writefile(fileCache, body) end) end
	return body
end

local uiSuccess, UI_Lib = pcall(function()
	return loadstring(fetchSource("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_DodgeOrDie_WindUI.lua"))()
end)

if not uiSuccess or type(UI_Lib) ~= "table" then
	exposeGlobal("IndraHubDodgeOrDieError", "WINDUI FAIL")
	exposeGlobal("IndraHubDodgeOrDieRunning", false)
	warn("[IndraHub Dodge or Die] Interface fail: " .. tostring(UI_Lib))
	return
end

local Interface = UI_Lib:CreateWindow({
	Title = "IndraHub | Dodge or Die",
	Icon = "shield",
	Author = "IndraHub",
	Folder = "IndraHubDodgeOrDie",
	Size = UDim2.fromOffset(580, 520),
	Transparent = true,
	Theme = "Dark",
	Resizable = true,
	SideBarWidth = 160,
})

pcall(function() Interface:SetToggleKey(Enum.KeyCode.RightControl) end)
pcall(function() Interface:EditOpenButton({ Title = "IndraHub", Icon = "shield", Draggable = true }) end)

local PrimaryTab = Interface:Tab({ Title = "Main", Icon = "home" })

PrimaryTab:Toggle({
	Title = "God Mode (Auto Evade)",
	Desc = "Automatically evades all hazardous spheres",
	Value = false,
	Callback = function(enabled)
		AppState.AutoEvade = enabled
		if not enabled then
			escapeChosenTime = 0
			lastActionTime = 0
			tClear(ObstructedPaths)
		end
	end,
})

local function destruct()
	for _, c in ipairs(ActiveConnections) do
		pcall(function() c:Disconnect() end)
	end
	tClear(ActiveConnections)
	tClear(TargetCache)
	tClear(TargetVelocities)
	tClear(TargetSamples)
	tClear(ObstructedPaths)
end

getgenv().IndraUnload = function()
	exposeGlobal("IndraHubDodgeOrDieRunning", false)
	destruct()
	getgenv().IndraUnload = nil
end
