--// IndraHub Flick - WindUI
--// Aim Assist, Smoothness, WalkSpeed, Infinite Jump, ESP, Aim FOV

repeat task.wait() until game:IsLoaded()

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

setGlobal("IndraHubFlickRunning", true)
setGlobal("IndraHubFlickSession", sessionId)
setGlobal("IndraHubFlickLastHeartbeat", os.clock())
setGlobal("IndraHubFlickError", nil)

local function running()
	return getGlobal("IndraHubFlickRunning") == true and getGlobal("IndraHubFlickSession") == sessionId
end

task.spawn(function()
	while running() do
		setGlobal("IndraHubFlickLastHeartbeat", os.clock())
		task.wait(2)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function fetch(url, cacheName)
	if type(readfile) == "function" then
		local ok, cached = pcall(readfile, cacheName)
		if ok and type(cached) == "string" and #cached > 1000 then return cached end
	end
	local source = game:HttpGet(url)
	if type(writefile) == "function" then pcall(writefile, cacheName, source) end
	return source
end

local WindUI = loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_Flick_WindUI.lua"))()
if not WindUI then
	setGlobal("IndraHubFlickError", "WINDUI FAIL")
	warn("[IndraHub Flick] WindUI load failed")
	return
end

local function notify(title, content, duration)
	pcall(WindUI.Notify, WindUI, {
		Title = title or "IndraHub Flick",
		Content = content or "",
		Icon = "crosshair",
		Duration = duration or 3,
	})
end

if env.IndraHubFlickWindow then pcall(function() env.IndraHubFlickWindow:Destroy() end) end
local Window = WindUI:CreateWindow({
	Title = "IndraHub",
	Icon = "crosshair",
	Author = "Flick",
	Folder = "IndraHub/Flick",
	Size = UDim2.fromOffset(520, 420),
	Transparent = true,
	Theme = "Dark",
	Resizable = true,
	SideBarWidth = 150,
})
env.IndraHubFlickWindow = Window
pcall(Window.SetToggleKey, Window, Enum.KeyCode.RightControl)
pcall(Window.EditOpenButton, Window, { Title = "IndraHub", Icon = "crosshair", Draggable = true })

--// State
local Settings = {
	AimAssist = false,
	AimSmoothness = 5,
	AimFOV = 200,
	WalkSpeed = 16,
	InfiniteJump = false,
	ESP = false,
	NameESP = false,
	BoxESP = false,
	SkeletonESP = false,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(130, 90, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6
FOVCircle.Radius = Settings.AimFOV
FOVCircle.Visible = false
FOVCircle.NumSides = 64

--// Helpers
local function getCharacter(player)
	return player and player.Character
end

local function isAlive(character)
	if not character then return false end
	local hum = character:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function getClosestTarget()
	local closest = nil
	local shortestDist = Settings.AimFOV
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local char = getCharacter(player)
		if not char or not isAlive(char) then continue end

		-- Prefer Crit (head hitbox) then Head
		local target = char:FindFirstChild("Crit") or char:FindFirstChild("Head")
		if not target then continue end

		local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		if dist < shortestDist then
			shortestDist = dist
			closest = target
		end
	end

	return closest
end

--// Aim Assist Loop
RunService.RenderStepped:Connect(function()
	-- FOV circle
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	FOVCircle.Radius = Settings.AimFOV
	FOVCircle.Visible = Settings.AimAssist

	if not Settings.AimAssist then return end
	if not isAlive(getCharacter(LocalPlayer)) then return end

	-- Only aim while holding mouse button (shooting)
	if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and
		not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	local target = getClosestTarget()
	if not target then return end

	local targetPos = Camera:WorldToViewportPoint(target.Position)
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local targetScreen = Vector2.new(targetPos.X, targetPos.Y)

	local smoothFactor = math.clamp(Settings.AimSmoothness, 1, 50)
	local delta = (targetScreen - screenCenter) / smoothFactor

	mousemoverel(delta.X, delta.Y)
end)

--// Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if not Settings.InfiniteJump then return end
	local char = getCharacter(LocalPlayer)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--// WalkSpeed Loop
RunService.Heartbeat:Connect(function()
	local char = getCharacter(LocalPlayer)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Settings.WalkSpeed
	end
end)

--// ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "FlickESP"
espFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local espCache = {} -- [player] = { highlight, nameTag, box {lines}, skeleton {lines} }

local function newLine(color, thickness)
	local l = Drawing.new("Line")
	l.Color = color or Color3.fromRGB(255, 255, 255)
	l.Thickness = thickness or 1.5
	l.Visible = false
	l.Transparency = 1
	return l
end

local function newText()
	local t = Drawing.new("Text")
	t.Color = Color3.fromRGB(255, 255, 255)
	t.Size = 14
	t.Center = true
	t.Outline = true
	t.OutlineColor = Color3.fromRGB(0, 0, 0)
	t.Font = Drawing.Fonts.Plex
	t.Visible = false
	t.Transparency = 1
	return t
end

local function createESPCache(player)
	if espCache[player] then return end
	espCache[player] = {
		highlight = nil,
		nameTag = newText(),
		box = { newLine(), newLine(), newLine(), newLine() }, -- top, right, bottom, left
		skeleton = {
			newLine(Color3.fromRGB(130, 90, 255), 1.5), -- head -> torso
			newLine(Color3.fromRGB(130, 90, 255), 1.5), -- torso -> left arm
			newLine(Color3.fromRGB(130, 90, 255), 1.5), -- torso -> right arm
			newLine(Color3.fromRGB(130, 90, 255), 1.5), -- torso -> left leg
			newLine(Color3.fromRGB(130, 90, 255), 1.5), -- torso -> right leg
		},
	}
end

local function removeESPCache(player)
	local cache = espCache[player]
	if not cache then return end
	if cache.highlight then cache.highlight:Destroy() end
	if cache.nameTag then cache.nameTag:Remove() end
	for _, l in ipairs(cache.box) do l:Remove() end
	for _, l in ipairs(cache.skeleton) do l:Remove() end
	espCache[player] = nil
end

local function clearAllESP()
	for player in pairs(espCache) do
		removeESPCache(player)
	end
end

local function worldToScreen(pos)
	local vec, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(vec.X, vec.Y), onScreen, vec.Z
end

local function updateESP()
	local anyEnabled = Settings.ESP or Settings.NameESP or Settings.BoxESP or Settings.SkeletonESP

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local char = getCharacter(player)
		local alive = char and isAlive(char)

		if not anyEnabled or not alive then
			local cache = espCache[player]
			if cache then
				if cache.highlight then cache.highlight:Destroy(); cache.highlight = nil end
				cache.nameTag.Visible = false
				for _, l in ipairs(cache.box) do l.Visible = false end
				for _, l in ipairs(cache.skeleton) do l.Visible = false end
			end
			continue
		end

		createESPCache(player)
		local cache = espCache[player]

		-- Highlight ESP
		if Settings.ESP then
			if not cache.highlight or not cache.highlight.Parent then
				if cache.highlight then cache.highlight:Destroy() end
				local hl = Instance.new("Highlight")
				hl.Name = player.Name .. "_ESP"
				hl.Adornee = char
				hl.FillColor = Color3.fromRGB(130, 90, 255)
				hl.FillTransparency = 0.6
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.OutlineTransparency = 0.3
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = espFolder
				cache.highlight = hl
			end
			cache.highlight.Adornee = char
		else
			if cache.highlight then cache.highlight:Destroy(); cache.highlight = nil end
		end

		local rootPart = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")
		if not rootPart or not head then continue end

		local rootPos, rootOnScreen, rootDepth = worldToScreen(rootPart.Position)
		if not rootOnScreen then
			cache.nameTag.Visible = false
			for _, l in ipairs(cache.box) do l.Visible = false end
			for _, l in ipairs(cache.skeleton) do l.Visible = false end
			continue
		end

		-- Bounding box calc
		local scaleFactor = 1 / rootDepth * 1000
		local boxHeight = 4.5 * scaleFactor
		local boxWidth = boxHeight * 0.55

		local topLeft = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
		local topRight = Vector2.new(rootPos.X + boxWidth / 2, rootPos.Y - boxHeight / 2)
		local bottomLeft = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y + boxHeight / 2)
		local bottomRight = Vector2.new(rootPos.X + boxWidth / 2, rootPos.Y + boxHeight / 2)

		-- Name ESP
		if Settings.NameESP then
			cache.nameTag.Text = player.DisplayName
			cache.nameTag.Position = Vector2.new(rootPos.X, topLeft.Y - 16)
			cache.nameTag.Visible = true
		else
			cache.nameTag.Visible = false
		end

		-- Box ESP
		if Settings.BoxESP then
			cache.box[1].From = topLeft; cache.box[1].To = topRight; cache.box[1].Visible = true
			cache.box[2].From = topRight; cache.box[2].To = bottomRight; cache.box[2].Visible = true
			cache.box[3].From = bottomRight; cache.box[3].To = bottomLeft; cache.box[3].Visible = true
			cache.box[4].From = bottomLeft; cache.box[4].To = topLeft; cache.box[4].Visible = true
		else
			for _, l in ipairs(cache.box) do l.Visible = false end
		end

		-- Skeleton ESP
		if Settings.SkeletonESP then
			local joints = {
				{ "Head", "Torso" },
				{ "Torso", "Left Arm" },
				{ "Torso", "Right Arm" },
				{ "Torso", "Left Leg" },
				{ "Torso", "Right Leg" },
			}
			for i, pair in ipairs(joints) do
				local p1 = char:FindFirstChild(pair[1])
				local p2 = char:FindFirstChild(pair[2])
				if p1 and p2 then
					local s1, on1 = worldToScreen(p1.Position)
					local s2, on2 = worldToScreen(p2.Position)
					if on1 and on2 then
						cache.skeleton[i].From = s1
						cache.skeleton[i].To = s2
						cache.skeleton[i].Visible = true
					else
						cache.skeleton[i].Visible = false
					end
				else
					cache.skeleton[i].Visible = false
				end
			end
		else
			for _, l in ipairs(cache.skeleton) do l.Visible = false end
		end
	end
end

RunService.Heartbeat:Connect(updateESP)

Players.PlayerRemoving:Connect(function(player)
	removeESPCache(player)
end)

--// UI Tabs
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "move" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

-- Combat
CombatTab:Toggle({ Title = "Aim Assist", Value = false, Callback = function(state)
	Settings.AimAssist = state
end })

CombatTab:Slider({ Title = "Smoothness", Value = { Min = 1, Max = 50, Default = Settings.AimSmoothness }, Step = 1, Callback = function(val)
	Settings.AimSmoothness = val
end })

CombatTab:Slider({ Title = "Aim FOV", Value = { Min = 50, Max = 600, Default = Settings.AimFOV }, Step = 1, Callback = function(val)
	Settings.AimFOV = val
end })

-- Movement
MovementTab:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 200, Default = Settings.WalkSpeed }, Step = 1, Callback = function(val)
	Settings.WalkSpeed = val
end })

MovementTab:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(state)
	Settings.InfiniteJump = state
end })

-- Visuals
VisualsTab:Toggle({ Title = "ESP", Value = false, Callback = function(state)
	Settings.ESP = state
end })

VisualsTab:Toggle({ Title = "Name ESP", Value = false, Callback = function(state)
	Settings.NameESP = state
end })

VisualsTab:Toggle({ Title = "Box ESP", Value = false, Callback = function(state)
	Settings.BoxESP = state
end })

VisualsTab:Toggle({ Title = "Skeleton ESP", Value = false, Callback = function(state)
	Settings.SkeletonESP = state
end })

notify("IndraHub Flick", "Script loaded successfully!", 3)
