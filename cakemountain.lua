local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function hubGetHui()
	return CoreGui
end

local env = getgenv and getgenv() or _G
local function setGlobal(key, value)
	rawset(_G, key, value)
	if env ~= _G then env[key] = value end
end
local function getGlobal(key)
	local val = env[key]
	if val ~= nil then return val end
	return rawget(_G, key)
end

_G.__INDRA_CAKEMOUNTAIN = (_G.__INDRA_CAKEMOUNTAIN or 0) + 1
local GEN = _G.__INDRA_CAKEMOUNTAIN

setGlobal("IndraHubCakeMountainRunning", true)
setGlobal("IndraHubCakeMountainLastHeartbeat", os.clock())

task.spawn(function()
	while _G.__INDRA_CAKEMOUNTAIN == GEN and getGlobal("IndraHubCakeMountainRunning") do
		task.wait(2)
		setGlobal("IndraHubCakeMountainLastHeartbeat", os.clock())
		setGlobal("IndraHubCakeMountainRunning", true)
		if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubCakeMountainLastHeartbeat"] then
			_G.IndraHubStatus["IndraHubCakeMountainLastHeartbeat"].heartbeat = os.clock()
		end
	end
end)

if env.__IndraHubCakeMountainLib and env.__IndraHubCakeMountainLib.Unload then
	pcall(function()
		env.__IndraHubCakeMountainLib:Unload()
	end)
end
if env.__OuroborosCakeMountainLib and env.__OuroborosCakeMountainLib.Unload then
	pcall(function()
		env.__OuroborosCakeMountainLib:Unload()
	end)
end

if getgenv then
	getgenv().gethui = hubGetHui
end
pcall(function()
	gethui = hubGetHui
end)

if setthreadidentity then
	pcall(setthreadidentity, 8)
end

local GAME_NAME = "Cake Mountain"
local DISCORD_INVITE = "https://discord.gg/synapsex"
local RSCRIPTS_LINK = "https://rscripts.net/@Ouroboros"
local WEBSITE_LINK = "https://ouroboros-hub-rbx.web.app/"

local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"
local RED = "#e05a5a"

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DigRequest = Remotes:WaitForChild("DigRequest")
local SellAll = Remotes:WaitForChild("SellAll")
local BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
local GetInventory = Remotes:WaitForChild("GetInventory")

local CakeConfig = require(ReplicatedStorage:WaitForChild("CakeConfig"))

local RARITY_VALUES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }
local FLUSH_VALUES = { "50%", "100%" }
local SELL_MODE_VALUES = { "Full Backpack", "Selected KG", "Sell Anytime" }
local UPGRADE_VALUES = { "Arm", "Arm +10", "Stomach", "Legs", "Scoop" }
local UPGRADE_REMOTE = {
	Arm = "Arm",
	["Arm +10"] = "Arm10",
	Stomach = "Stomach",
	Legs = "Legs",
	Scoop = "ScoopLegacy",
}

local okWindUI, WindUI = pcall(function()
	local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
	return loadstring(source)()
end)

if not okWindUI or not WindUI then
	warn("[IndraHub] Failed to load WindUI")
	setGlobal("IndraHubCakeMountainError", "WINDUI FAIL")
	return
end

local RealWindow = WindUI:CreateWindow({
	Title = "IndraHub | Cake Mountain",
	Icon = "cake-slice",
	Author = "IndraHub",
	Folder = "IndraHub_CakeMountain",
	Size = UDim2.fromOffset(640, 500),
	Transparent = true,
	Theme = "Dark",
	SideBarWidth = 185,
	HasOutline = true
})

local Toggles = {}
local Options = {
	FarmSpeed = { Value = 45 },
	SellMode = { Value = "Full Backpack" },
	SellKG = { Value = 10 },
	FlushAt = { Value = "100%" },
	WalkSpeed = { Value = 32 },
	FlySpeed = { Value = 60 }
}

local Library = {
	Unloaded = false,
	Toggles = Toggles,
	Options = Options,
	_unloadCallbacks = {},
	OnUnload = function(self, cb)
		table.insert(self._unloadCallbacks, cb)
	end,
	Unload = function(self)
		if self.Unloaded then return end
		self.Unloaded = true
		setGlobal("IndraHubCakeMountainRunning", false)
		for _, cb in ipairs(self._unloadCallbacks) do
			pcall(cb)
		end
		pcall(function() RealWindow:Destroy() end)
		if getgenv then
			getgenv().__IndraHubCakeMountainLib = nil
		end
	end,
	Notify = function(self, msg)
		pcall(function()
			WindUI:Notify({
				Title = "IndraHub",
				Content = tostring(msg or ""),
				Duration = 3.5
			})
		end)
	end
}

if getgenv then
	getgenv().__IndraHubCakeMountainLib = Library
end

local function copyText(text, message)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	end
	Library:Notify(message)
end

local function copyDiscord()
	copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end

local function colored(text, color)
	return string.format('<font color="%s">%s</font>', color, text)
end

local function field(key, value, color)
	return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
end

local function isOn(name)
	if Library.Unloaded then
		return false
	end
	local toggle = Toggles[name]
	return toggle ~= nil and toggle.Value == true
end

local function optionValue(name, fallback)
	local option = Options[name]
	if option == nil then
		return fallback
	end
	return option.Value
end

local function multiSelected(name)
	local value = optionValue(name, {})
	if typeof(value) ~= "table" then
		return {}
	end
	local selected = {}
	for key, on in value do
		if on == true then
			selected[key] = true
		elseif typeof(key) == "number" and typeof(on) == "string" then
			selected[on] = true
		end
	end
	return selected
end

local function multiHasAny(name)
	return next(multiSelected(name)) ~= nil
end

local function getRoot()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(cf)
	local root = getRoot()
	if not root then
		return false
	end
	if typeof(cf) == "Vector3" then
		root.CFrame = CFrame.new(cf)
	else
		root.CFrame = cf
	end
	return true
end

local function getFullness()
	return tonumber(LocalPlayer:GetAttribute("Fullness")) or 0
end

local function getCrumbs()
	local crumbs = LocalPlayer:FindFirstChild("CrumbsNum")
	return crumbs and tonumber(crumbs.Value) or 0
end

local function getSpoonTier()
	return tonumber(LocalPlayer:GetAttribute("SpoonTier")) or 1
end

local function getInventory()
	local ok, inv = pcall(function()
		return GetInventory:InvokeServer()
	end)
	if ok and type(inv) == "table" then
		return inv
	end
	return nil
end

local function bagIsFull()
	local inv = getInventory()
	if not inv then
		return false
	end
	local used = tonumber(inv.used) or 0
	local capacity = tonumber(inv.capacity) or 0
	if capacity <= 0 then
		return false
	end
	return used >= capacity - 0.05
end

local function bagUsed()
	local inv = getInventory()
	if not inv then
		return 0
	end
	return tonumber(inv.used) or 0
end

local function bagCapacity()
	local inv = getInventory()
	if not inv then
		return 0
	end
	return tonumber(inv.capacity) or 0
end

local function bagRemaining()
	return math.max(bagCapacity() - bagUsed(), 0)
end

local function cakeWeight(model)
	return tonumber(model and model:GetAttribute("Weight")) or 0
end

local function shouldAutoSell()
	local mode = optionValue("SellMode", "Full Backpack")
	local used = bagUsed()
	if used <= 0 then
		return false
	end
	if mode == "Sell Anytime" then
		return true
	end
	if mode == "Selected KG" then
		local kg = tonumber(optionValue("SellKG", 10)) or 10
		return used >= kg
	end
	return bagIsFull()
end

local function getFarmSpeed()
	return math.max(tonumber(optionValue("FarmSpeed", 45)) or 45, 10)
end

local function holdingCake()
	return (tonumber(LocalPlayer:GetAttribute("HeldCakeIndex")) or 0) > 0
end

local function unequipTools()
	local humanoid = getHumanoid()
	if humanoid then
		pcall(function()
			humanoid:UnequipTools()
		end)
	end
end

local function rarityAllowed(rarity)
	if not multiHasAny("FarmRarity") then
		return true
	end
	local selected = multiSelected("FarmRarity")
	return selected[rarity] == true
end

local function claimedByOther(model)
	local digger = model:GetAttribute("DiggerUserId")
	local claimUntil = tonumber(model:GetAttribute("ClaimUntil")) or 0
	if type(digger) ~= "number" then
		return false
	end
	if digger == LocalPlayer.UserId then
		return false
	end
	return Workspace:GetServerTimeNow() < claimUntil
end

local function firePrompt(prompt, holdDuration)
	if not prompt or not fireproximityprompt then
		return false
	end
	local hold = holdDuration
	if hold == nil then
		hold = prompt.HoldDuration
	end
	local ok = pcall(fireproximityprompt, prompt, hold)
	if ok then
		return true
	end
	ok = pcall(fireproximityprompt, prompt)
	return ok
end

local function fireGuiSignal(signal)
	if getconnections then
		local ok, conns = pcall(getconnections, signal)
		if ok and conns then
			for _, conn in conns do
				if conn.Fire then
					pcall(function()
						conn:Fire()
					end)
				elseif conn.Function then
					pcall(conn.Function)
				end
			end
			return true
		end
	end
	if firesignal then
		return pcall(firesignal, signal)
	end
	return false
end

local function getPackButton()
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	local targetCard = gui and gui:FindFirstChild("UI_TargetCard")
	local card = targetCard and targetCard:FindFirstChild("Card")
	return card, card and card:FindFirstChild("PackButton")
end

local function waitForPackCard(timeout)
	local deadline = os.clock() + (timeout or 2)
	while os.clock() < deadline do
		local card = getPackButton()
		if card and card.Visible then
			task.wait(0.08)
			if card.Visible then
				return card
			end
		end
		task.wait(0.05)
	end
	local card = getPackButton()
	if card and card.Visible then
		return card
	end
	return nil
end

local function packCake(prompt)
	local card, packButton = getPackButton()
	if not (card and card.Visible and packButton and prompt) then
		return false
	end
	local hold = math.max(tonumber(prompt.HoldDuration) or 0, 0.15)
	fireGuiSignal(packButton.MouseButton1Down)
	local deadline = os.clock() + hold + 0.45
	while os.clock() < deadline do
		if not card.Visible then
			fireGuiSignal(packButton.MouseButton1Down)
		end
		task.wait(0.05)
	end
	fireGuiSignal(packButton.MouseButton1Up)
	fireGuiSignal(packButton.MouseLeave)
	task.wait(0.25)
	return true
end

local function getFlushPrompt()
	local toilet = Workspace:FindFirstChild("CakeHouse")
	toilet = toilet and toilet:FindFirstChild("Toilet")
	local tank = toilet and toilet:FindFirstChild("Tank")
	return tank and tank:FindFirstChild("FlushPrompt")
end

local lastDigAt = 0
local farmBusy = false
local farmAssistActive = false
local farmHoverCF = nil
local sellBusy = false
local flushBusy = false
local farmFailUntil = {}

local function digCooldown()
	return tonumber(LocalPlayer:GetAttribute("DigCooldown")) or CakeConfig.DigCooldown or 0.4
end

local function setFarmAssist(active, hoverCf)
	farmAssistActive = active == true
	farmHoverCF = hoverCf
	if not farmAssistActive then
		farmHoverCF = nil
		if not isOn("Fly") then
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
	end
end

local function applyFarmNoclip()
	local character = LocalPlayer.Character
	if not character then
		return
	end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function cakeHoverCf(part)
	return CFrame.lookAt(part.Position + Vector3.new(0, 7, 0), part.Position)
end

local function markFarmFail(model)
	if model then
		farmFailUntil[model] = os.clock() + 10
	end
end

local function isFarmFailed(model)
	local untilTime = farmFailUntil[model]
	return untilTime ~= nil and os.clock() < untilTime
end

local function pruneFarmFails()
	local now = os.clock()
	for model, untilTime in pairs(farmFailUntil) do
		if now >= untilTime or not model.Parent then
			farmFailUntil[model] = nil
		end
	end
end

local function doAutoEat()
	if farmBusy or farmAssistActive or flushBusy then
		return
	end
	if getFullness() >= 0.999 then
		return
	end
	local now = os.clock()
	if now - lastDigAt < digCooldown() then
		return
	end
	local root = getRoot()
	local character = LocalPlayer.Character
	if not root or not character then
		return
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local origin = root.Position + Vector3.new(0, 1.5, 0)
	local look = root.CFrame.LookVector
	local hit = Workspace:Raycast(origin, look * 200, params)
	if not (hit and hit.Instance == Workspace.Terrain) then
		hit = Workspace:Raycast(origin, Vector3.new(0, -60, 0), params)
	end
	local range = CakeConfig.ClientDigRange or 13
	local lookFlat = Vector3.new(look.X, 0, look.Z)
	if lookFlat.Magnitude < 0.05 then
		lookFlat = Vector3.new(0, 0, -1)
	else
		lookFlat = lookFlat.Unit
	end
	local digPos = hit and hit.Position or (root.Position + lookFlat * 4)
	local digNormal = hit and hit.Normal or Vector3.new(0, 1, 0)
	if (digPos - root.Position).Magnitude > range then
		digPos = root.Position + lookFlat * math.min(range - 1, 6)
		digNormal = Vector3.new(0, 1, 0)
	end
	lastDigAt = now
	DigRequest:FireServer(digPos, digNormal)
end

local function pickFarmCake()
	pruneFarmFails()
	local folder = Workspace:FindFirstChild("MiniCakes")
	if not folder then
		return nil
	end
	local root = getRoot()
	local rootPos = root and root.Position or Vector3.zero
	local remaining = bagRemaining()
	local best, bestDist = nil, math.huge
	for _, model in folder:GetChildren() do
		if model:IsA("Model") and not claimedByOther(model) and not isFarmFailed(model) then
			local rarity = model:GetAttribute("Rarity") or "Common"
			if rarityAllowed(rarity) then
				local weight = cakeWeight(model)
				if weight <= remaining + 0.05 then
					local prompt = model:FindFirstChild("CollectPrompt", true)
					local part = prompt and prompt.Parent
					if prompt and prompt.Enabled and part and part:IsA("BasePart") then
						local dist = (part.Position - rootPos).Magnitude
						if dist < bestDist then
							bestDist = dist
							best = { model = model, prompt = prompt, part = part, weight = weight }
						end
					end
				end
			end
		end
	end
	return best
end

local function hoverNearCake(part, timeout)
	if not part then
		return false
	end
	local deadline = os.clock() + (timeout or 5)
	local speed = getFarmSpeed()
	setFarmAssist(true, cakeHoverCf(part))
	while os.clock() < deadline do
		if Library.Unloaded or not part.Parent then
			return false
		end
		local root = getRoot()
		if not root then
			return false
		end
		local targetPos = part.Position + Vector3.new(0, 7, 0)
		local delta = targetPos - root.Position
		if delta.Magnitude <= 3.5 then
			setFarmAssist(true, cakeHoverCf(part))
			return true
		end
		local dt = task.wait()
		local step = math.min(delta.Magnitude, math.max(speed * dt, 0.5))
		local nextPos = root.Position + delta.Unit * step
		setFarmAssist(true, CFrame.lookAt(nextPos, part.Position))
	end
	local root = getRoot()
	return root ~= nil and (root.Position - (part.Position + Vector3.new(0, 7, 0))).Magnitude <= 8
end

local function doAutoFarmCake()
	if farmBusy or flushBusy or sellBusy then
		return
	end
	if Library.Unloaded then
		return
	end
	if bagIsFull() then
		return
	end
	if holdingCake() then
		return
	end
	local target = pickFarmCake()
	if not target then
		return
	end
	farmBusy = true
	local packed = false
	local keepHover = false
	local ok = pcall(function()
		local part = target.part
		local model = target.model
		local prompt = target.prompt
		if not (part and part.Parent and model and model.Parent and prompt and prompt.Parent) then
			return
		end
		if claimedByOther(model) or cakeWeight(model) > bagRemaining() + 0.05 then
			return
		end

		prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 30)
		prompt.RequiresLineOfSight = false
		prompt.Enabled = true
		unequipTools()

		if not hoverNearCake(part, 6) then
			markFarmFail(model)
			return
		end
		if not model.Parent or claimedByOther(model) then
			return
		end

		keepHover = true
		task.spawn(function()
			while keepHover and farmBusy and part.Parent and model.Parent and not Library.Unloaded do
				setFarmAssist(true, cakeHoverCf(part))
				task.wait(0.03)
			end
		end)

		task.wait(0.2)
		unequipTools()
		local card = waitForPackCard(2.5)
		if not card or not model.Parent then
			markFarmFail(model)
			return
		end

		local hold = math.max(tonumber(prompt.HoldDuration) or 0, 0.15)
		local usedBefore = bagUsed()
		packCake(prompt)
		if model.Parent then
			pcall(function()
				prompt:InputHoldBegin()
			end)
			firePrompt(prompt, hold)
			task.wait(hold + 0.45)
			pcall(function()
				prompt:InputHoldEnd()
			end)
		end
		packed = not model.Parent or bagUsed() > usedBefore + 0.01
		if not packed then
			markFarmFail(model)
		end
	end)
	keepHover = false
	setFarmAssist(false)
	farmBusy = false
	if not ok then
		pcall(markFarmFail, target.model)
	end
	return packed
end

local function doAutoSell()
	if sellBusy or farmBusy or flushBusy then
		return
	end
	if not shouldAutoSell() then
		return
	end
	sellBusy = true
	pcall(function()
		SellAll:InvokeServer()
	end)
	task.wait(0.35)
	sellBusy = false
end

local function flushThreshold()
	local value = optionValue("FlushAt", "100%")
	if value == "50%" then
		return 0.5
	end
	return 0.999
end

local function doAutoFlush()
	if flushBusy or farmBusy or farmAssistActive then
		return
	end
	if getFullness() < flushThreshold() then
		return
	end
	local prompt = getFlushPrompt()
	if not prompt then
		return
	end
	local part = prompt.Parent
	if not part or not part:IsA("BasePart") then
		return
	end
	flushBusy = true
	pcall(function()
		teleportTo(CFrame.lookAt((part.CFrame * CFrame.new(0, 0, -5)).Position, part.Position))
		task.wait(0.2)
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 50
		prompt.RequiresLineOfSight = false
		firePrompt(prompt, 0)
		task.wait(0.8)
	end)
	flushBusy = false
end

local buyBusy = false

local function doAutoBuySpoon()
	if buyBusy or farmBusy or flushBusy then
		return
	end
	local tier = getSpoonTier()
	if tier >= 20 then
		return
	end
	local okCost, cost = pcall(CakeConfig.spoonCost, tier)
	if not okCost or type(cost) ~= "number" then
		return
	end
	if getCrumbs() < cost then
		return
	end
	buyBusy = true
	pcall(function()
		BuyUpgrade:InvokeServer("Spoon")
	end)
	task.wait(0.25)
	buyBusy = false
end

local function doAutoBuyUpgrades()
	if buyBusy or farmBusy or flushBusy then
		return
	end
	if not multiHasAny("BuyUpgrades") then
		return
	end
	local selected = multiSelected("BuyUpgrades")
	buyBusy = true
	for _, label in UPGRADE_VALUES do
		if selected[label] then
			local remoteKey = UPGRADE_REMOTE[label]
			if remoteKey then
				pcall(function()
					BuyUpgrade:InvokeServer(remoteKey)
				end)
				task.wait(0.12)
			end
		end
	end
	task.wait(0.15)
	buyBusy = false
end

local MainTab = RealWindow:Tab({ Title = "Main", Icon = "cake-slice" })
local PlayerTab = RealWindow:Tab({ Title = "Player", Icon = "user" })
local SettingsTab = RealWindow:Tab({ Title = "Settings", Icon = "settings" })

-- Main Tab: Mini Cakes Farm
MainTab:Section({ Title = "Mini Cakes Farm" })

MainTab:Toggle({
	Title = "Auto Farm Cake",
	Desc = "Collects nearest mini cakes and packs them",
	Default = false,
	Callback = function(val)
		Toggles.AutoFarmCake = { Value = val }
	end
})

MainTab:Dropdown({
	Title = "Rarity Filter",
	Desc = "Collect only selected cake rarities",
	Values = RARITY_VALUES,
	Value = {},
	Multi = true,
	Callback = function(val)
		Options.FarmRarity = { Value = val }
	end
})

MainTab:Slider({
	Title = "Farm Speed",
	Desc = "Movement speed while approaching mini cakes",
	Min = 10,
	Max = 120,
	Default = 45,
	Callback = function(val)
		Options.FarmSpeed = { Value = val }
	end
})

-- Main Tab: Eating & Digging
MainTab:Section({ Title = "Eat & Dig" })

MainTab:Toggle({
	Title = "Auto Eat",
	Desc = "Automatically digs and eats the terrain cake",
	Default = false,
	Callback = function(val)
		Toggles.AutoEat = { Value = val }
	end
})

-- Main Tab: Selling
MainTab:Section({ Title = "Selling" })

MainTab:Toggle({
	Title = "Auto Sell",
	Desc = "Automatically sells collected cake from backpack",
	Default = false,
	Callback = function(val)
		Toggles.AutoSell = { Value = val }
	end
})

MainTab:Dropdown({
	Title = "Sell Mode",
	Desc = "When to trigger sell remote",
	Values = SELL_MODE_VALUES,
	Value = "Full Backpack",
	Callback = function(val)
		Options.SellMode = { Value = val }
	end
})

MainTab:Slider({
	Title = "Sell KG",
	Desc = "KG threshold if using Selected KG mode",
	Min = 1,
	Max = 100,
	Default = 10,
	Callback = function(val)
		Options.SellKG = { Value = val }
	end
})

-- Main Tab: Stomach & Flush
MainTab:Section({ Title = "Stomach & Toilet" })

MainTab:Toggle({
	Title = "Auto Flush",
	Desc = "Teleports to toilet and flushes stomach when full",
	Default = false,
	Callback = function(val)
		Toggles.AutoFlush = { Value = val }
	end
})

MainTab:Dropdown({
	Title = "Flush At",
	Desc = "Fullness percentage before flushing",
	Values = FLUSH_VALUES,
	Value = "100%",
	Callback = function(val)
		Options.FlushAt = { Value = val }
	end
})

-- Main Tab: Shop & Upgrades
MainTab:Section({ Title = "Shop Upgrades" })

MainTab:Toggle({
	Title = "Auto Buy Spoon",
	Desc = "Purchases spoon upgrades when affordable",
	Default = false,
	Callback = function(val)
		Toggles.AutoBuySpoon = { Value = val }
	end
})

MainTab:Toggle({
	Title = "Auto Buy Upgrades",
	Desc = "Purchases stat upgrades from the shop",
	Default = false,
	Callback = function(val)
		Toggles.AutoBuyUpgrades = { Value = val }
	end
})

MainTab:Dropdown({
	Title = "Buy Upgrades",
	Desc = "Upgrades to purchase automatically",
	Values = UPGRADE_VALUES,
	Value = {},
	Multi = true,
	Callback = function(val)
		Options.BuyUpgrades = { Value = val }
	end
})

-- Player Tab
PlayerTab:Section({ Title = "Movement" })

PlayerTab:Toggle({
	Title = "WalkSpeed",
	Desc = "Modify character walk speed",
	Default = false,
	Callback = function(val)
		Toggles.WalkSpeedEnabled = { Value = val }
		if not val then
			local humanoid = getHumanoid()
			if humanoid then humanoid.WalkSpeed = 16 end
		end
	end
})

PlayerTab:Slider({
	Title = "WalkSpeed Amount",
	Min = 16,
	Max = 250,
	Default = 32,
	Callback = function(val)
		Options.WalkSpeed = { Value = val }
	end
})

PlayerTab:Toggle({
	Title = "Infinite Jump",
	Desc = "Jump continuously in the air",
	Default = false,
	Callback = function(val)
		Toggles.InfJump = { Value = val }
	end
})

PlayerTab:Toggle({
	Title = "NoClip",
	Desc = "Walk through walls and obstacles",
	Default = false,
	Callback = function(val)
		Toggles.NoClip = { Value = val }
	end
})

PlayerTab:Toggle({
	Title = "Instant ProximityPrompt",
	Desc = "Eliminates hold duration on proximity prompts",
	Default = false,
	Callback = function(val)
		Toggles.InstantProximityPrompt = { Value = val }
	end
})

PlayerTab:Section({ Title = "Flight" })

PlayerTab:Toggle({
	Title = "Fly",
	Desc = "Fly freely using WASD + Space/Ctrl",
	Default = false,
	Callback = function(val)
		Toggles.Fly = { Value = val }
		if not val and not farmAssistActive then
			local humanoid = getHumanoid()
			if humanoid then humanoid.PlatformStand = false end
		end
	end
})

PlayerTab:Slider({
	Title = "Fly Speed",
	Min = 10,
	Max = 400,
	Default = 60,
	Callback = function(val)
		Options.FlySpeed = { Value = val }
	end
})

PlayerTab:Section({ Title = "Safety" })

local function applyAntiGameplayPause(enabled)
	pcall(function()
		GuiService:SetGameplayPausedNotificationEnabled(not enabled)
	end)
	pcall(function()
		local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
		if notification then
			notification.Enabled = not enabled
		end
	end)
	if not enabled then
		return
	end
	pcall(function()
		if sethiddenproperty then
			sethiddenproperty(LocalPlayer, "GameplayPaused", false)
		else
			LocalPlayer.GameplayPaused = false
		end
	end)
end

PlayerTab:Toggle({
	Title = "No Gameplay Paused",
	Desc = "Disables Roblox network pause overlay",
	Default = true,
	Callback = function(val)
		Toggles.AntiGameplayPause = { Value = val }
		applyAntiGameplayPause(val)
	end
})

-- Settings Tab
SettingsTab:Section({ Title = "Anti-AFK & Automation" })

local antiAfkTriggerCount = 0
local antiAfkLastPulse = tick()

local function antiAfkTap()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0), camera.CFrame)
		antiAfkTriggerCount += 1
		antiAfkLastPulse = tick()
	end)
end

SettingsTab:Toggle({
	Title = "Anti-AFK",
	Desc = "Prevents idle kicks after 20 minutes",
	Default = true,
	Callback = function(val)
		Toggles.AntiAfk = { Value = val }
	end
})

SettingsTab:Section({ Title = "Script Management" })

SettingsTab:Button({
	Title = "Unload IndraHub",
	Desc = "Stops all loops and unloads user interface cleanly",
	Callback = function()
		Library:Unload()
	end
})

-- Setup connections & loops
local function applyInstantPrompt(prompt)
	if not prompt:IsA("ProximityPrompt") then return end
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 50
	prompt.RequiresLineOfSight = false
end

local instantPromptConnection = Workspace.DescendantAdded:Connect(function(descendant)
	if isOn("InstantProximityPrompt") then
		pcall(applyInstantPrompt, descendant)
	end
end)

local steppedConnection = RunService.Stepped:Connect(function()
	if Library.Unloaded then return end
	if isOn("NoClip") or farmAssistActive then
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
	if farmAssistActive then
		applyFarmNoclip()
	end
end)

local jumpConnection = UserInputService.JumpRequest:Connect(function()
	if Library.Unloaded then return end
	if isOn("InfJump") then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

local renderConnection = RunService.RenderStepped:Connect(function(dt)
	if Library.Unloaded then return end
	if isOn("WalkSpeedEnabled") then
		local humanoid = getHumanoid()
		local walkSpeed = optionValue("WalkSpeed", 32)
		if humanoid then
			humanoid.WalkSpeed = walkSpeed
		end
	end
	if farmAssistActive and farmHoverCF then
		local root = getRoot()
		local humanoid = getHumanoid()
		if root and humanoid then
			humanoid.PlatformStand = true
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.CFrame = farmHoverCF
		end
	elseif isOn("Fly") then
		local root = getRoot()
		local humanoid = getHumanoid()
		local flySpeed = optionValue("FlySpeed", 60)
		local cam = Workspace.CurrentCamera
		if root and humanoid and cam then
			humanoid.PlatformStand = true
			local direction = Vector3.zero
			if not UserInputService:GetFocusedTextBox() then
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					direction += cam.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					direction -= cam.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					direction -= cam.CFrame.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					direction += cam.CFrame.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					direction += Vector3.new(0, 1, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					direction -= Vector3.new(0, 1, 0)
				end
			end
			root.AssemblyLinearVelocity = Vector3.zero
			if direction.Magnitude > 0 then
				root.CFrame += direction.Unit * flySpeed * dt
			end
		end
	end
end)

local idledConnection = LocalPlayer.Idled:Connect(function()
	if isOn("AntiAfk") then
		pcall(antiAfkTap)
	end
end)

Library:OnUnload(function()
	setFarmAssist(false)
	farmBusy = false
	applyAntiGameplayPause(false)
	if instantPromptConnection then instantPromptConnection:Disconnect() end
	if steppedConnection then steppedConnection:Disconnect() end
	if jumpConnection then jumpConnection:Disconnect() end
	if renderConnection then renderConnection:Disconnect() end
	if idledConnection then idledConnection:Disconnect() end
end)

LocalPlayer.CharacterAdded:Connect(function()
	setFarmAssist(false)
	farmBusy = false
	flushBusy = false
end)

task.spawn(function()
	while not Library.Unloaded do
		if isOn("AntiAfk") and tick() - antiAfkLastPulse >= 60 then
			pcall(antiAfkTap)
		end
		if isOn("AntiGameplayPause") then
			applyAntiGameplayPause(true)
		end
		task.wait(2)
	end
end)

task.spawn(function()
	while not Library.Unloaded do
		if isOn("AutoFlush") then
			pcall(doAutoFlush)
		end
		if isOn("AutoEat") and getFullness() < flushThreshold() then
			pcall(doAutoEat)
			task.wait(math.max(digCooldown() * 0.5, 0.05))
		else
			task.wait(0.2)
		end
	end
end)

task.spawn(function()
	while not Library.Unloaded do
		if isOn("AutoFarmCake") then
			pcall(doAutoFarmCake)
			task.wait(0.2)
		else
			if farmAssistActive and not farmBusy then
				setFarmAssist(false)
			end
			task.wait(0.4)
		end
	end
end)

task.spawn(function()
	while not Library.Unloaded do
		if isOn("AutoSell") then
			pcall(doAutoSell)
		end
		if isOn("AutoBuyUpgrades") then
			pcall(doAutoBuyUpgrades)
		end
		if isOn("AutoBuySpoon") then
			pcall(doAutoBuySpoon)
		end
		task.wait(0.9)
	end
end)

Library:Notify("Cake Mountain module loaded successfully!")
