local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

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

_G.__INDRA_DUELINGGROUND = (_G.__INDRA_DUELINGGROUND or 0) + 1
local GEN = _G.__INDRA_DUELINGGROUND

setGlobal("IndraHubDuelingGroundRunning", true)
setGlobal("IndraHubDuelingGroundLastHeartbeat", os.clock())

task.spawn(function()
	while _G.__INDRA_DUELINGGROUND == GEN and getGlobal("IndraHubDuelingGroundRunning") do
		task.wait(2)
		setGlobal("IndraHubDuelingGroundLastHeartbeat", os.clock())
		setGlobal("IndraHubDuelingGroundRunning", true)
		if _G.IndraHubStatus and _G.IndraHubStatus["IndraHubDuelingGroundLastHeartbeat"] then
			_G.IndraHubStatus["IndraHubDuelingGroundLastHeartbeat"].heartbeat = os.clock()
		end
	end
end)

if env.__IndraHubDuelingGroundLib and env.__IndraHubDuelingGroundLib.Unload then
	pcall(function() env.__IndraHubDuelingGroundLib:Unload() end)
end

local registerImpact = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerCharacter").Update:WaitForChild("RegisterImpact")
local tbl = {}

local function fn(arg)
	tbl[#tbl + 1] = arg
	return arg
end

local v = nil
local v2 = {
	AP_Enabled = { Value = false },
	AP_Notify = { Value = false },
	GM_Enabled = { Value = false },
	CS_Apply = { Value = true },
	AntiAfk = { Value = true }
}
local v3 = {
	AP_Chance = { Value = 100 }
}
local tbl2 = { parried = 0, blocked = 0, missed = 0 }

local function fn2(arg)
	local v4 = v2 and v2[arg]
	return v4 and v4.Value
end

local function fn3(arg, arg2)
	local v4 = v3 and v3[arg]
	if v4 and v4.Value ~= nil then
		return v4.Value
	end
	return arg2
end

local CharacterController = nil

pcall(function()
	CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
end)

local function fn4()
	if not CharacterController then
		return nil
	end
	local ok, result = pcall(CharacterController.GetLocalCharacterHandler, CharacterController)
	if ok and type(result) == "table" and result.ActionManager then
		return result
	end
	return nil
end

local function fn5(arg)
	return arg and arg.IsParrying == true
end

local flag = false

local function fn6(arg)
	local v4 = fn4()
	if not v4 then
		return
	end

	if fn5(v4) then
		return
	end
	local actionManager = v4.ActionManager
	local isParrying = v4.IsParrying
	v4.IsParrying = true
	flag = true

	task.spawn(function()
		local n = os.clock() + 0.6

		while true do
			RunService.Heartbeat:Wait()
			if not (not (actionManager and actionManager.UnresolvedImpacts and actionManager.UnresolvedImpacts[arg] ~= nil) or os.clock() > n) then
				continue
			end
			break
		end

		local v5 = fn4()

		if v5 == v4 and v5.IsParrying == true then
			v5.IsParrying = isParrying
		end

		flag = false
	end)
end

fn(registerImpact.OnClientEvent:Connect(function(arg, arg2)
	if not fn2("AP_Enabled") then
		return
	end

	if type(arg) ~= "number" and type(arg) ~= "string" then
		return
	end

	if type(arg2) == "table" and arg2.sourceModule == nil then
		return
	end
	local n = math.random() * 100
	if fn3("AP_Chance", 100) < n then
		tbl2.missed = tbl2.missed + 1
		return
	end
	tbl2.parried = tbl2.parried + 1
	fn6(arg)

	if fn2("AP_Notify") and v then
		v:Notify("Parried impact #" .. tostring(arg), 1)
	end
end))

local function fn7(arg)
	local v4 = fn4()
	if not v4 then
		return
	end
	local actionManager = v4.ActionManager
	local isDodging = v4.IsDodging
	v4.IsDodging = true

	task.spawn(function()
		local n = os.clock() + 0.6

		while true do
			RunService.Heartbeat:Wait()
			if not (not (actionManager and actionManager.UnresolvedImpacts and actionManager.UnresolvedImpacts[arg] ~= nil) or os.clock() > n) then
				continue
			end
			break
		end

		local v5 = fn4()

		if v5 == v4 and v5.IsDodging == true then
			v5.IsDodging = isDodging
		end
	end)
end

fn(registerImpact.OnClientEvent:Connect(function(arg)
	if not fn2("GM_Enabled") then
		return
	end

	if type(arg) ~= "number" and type(arg) ~= "string" then
		return
	end
	fn7(arg)
end))

local tbl3 = {
	Katana = {
		"DefaultKatana",
		"BloodlusterKatana",
		"DeepBlueKatana",
		"DarkMatterKatana",
		"ChristmasKatana",
		"FlamingKatana",
		"ChampionKatana",
	},
	Daggers = {
		"DefaultDaggers",
		"CrimsonFangsDaggers",
		"BronzeViperDaggers",
		"DarkMatterDaggers",
		"ChristmasDaggers",
		"GoldenDaggers",
	},
	Naginata = {
		"DefaultNaginata",
		"SerpentSlayerNaginata",
		"DeepBlueNaginata",
		"DarkMatterNaginata",
		"ChristmasNaginata",
	},
	Gauntlets = { "DefaultGauntlets", "GoldenGauntlets", "BloodlusterGauntlets" },
	Kusarigama = { "DefaultKusarigama", "MagmaKusarigama", "BronzeViperKusarigama", "CelestialKusarigama" },
	Warhammer = {
		"DefaultWarhammer",
		"IcebornWarhammer",
		"DarkMatterWarhammer",
		"ViperWarhammer",
		"SoulEaterWarhammer",
	},
	CurvedBlades = { "DefaultCurvedBlades", "ScorchflowerCurvedBlades" },
	BoStaff = { "DefaultBoStaff" },
}

local tbl4 = {}
local tbl5 = {}

for k, v4 in pairs(tbl3) do
	table.sort(v4)
	tbl5[#tbl5 + 1] = k

	for _, v5 in ipairs(v4) do
		tbl4[v5] = k
	end
end

table.sort(tbl5)
local requestSetCurrentWeapon = ReplicatedStorage.Remotes:WaitForChild("WeaponInventory"):WaitForChild("Request_SetCurrentWeapon")
local skinApplied = "DefaultKatana"

local function fn8(arg, arg2)
	return arg:gsub(arg2, "")
end

local function fn9(arg, currentCosmetic)
	local cosmetics = arg.WeaponInfo and arg.WeaponInfo.Cosmetics and arg.WeaponInfo.Cosmetics[currentCosmetic]
	if not cosmetics then
		return false
	end
	local module = require(cosmetics)
	if type(module) ~= "table" or not module.WeaponModel then
		return false
	end
	local clone = module.WeaponModel:Clone()

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true
		end
	end

	local parent = arg.WeaponModel and arg.WeaponModel.Parent or arg.WeaponInstance

	if arg.WeaponModel then
		pcall(function()
			arg.WeaponModel:Destroy()
		end)
	end

	local blade = clone:FindFirstChild("Blade")
	local trail = blade and blade:FindFirstChild("Trail") or nil
	local ultimateTrail = blade and blade:FindFirstChild("UltimateTrail") or nil

	if trail then
		pcall(function()
			trail:SetAttribute("WidthScale", trail.WidthScale)
			trail:SetAttribute("MaxLength", trail.MaxLength)
			trail.Enabled = false
		end)
	end

	if ultimateTrail then
		pcall(function()
			ultimateTrail:SetAttribute("WidthScale", ultimateTrail.WidthScale)
			ultimateTrail:SetAttribute("MaxLength", ultimateTrail.MaxLength)
			ultimateTrail.Enabled = false
		end)
	end

	clone.Parent = parent
	arg.WeaponModel = clone
	arg.Blade = blade
	arg.Trail = trail
	arg.UltimateTrail = ultimateTrail
	arg.CurrentCosmetic = currentCosmetic
	arg.CosmeticInfo = module
	return true
end

local function fn10()
	local v4 = fn4()
	local equippedWeaponHandler = v4 and v4:GetEquippedWeaponHandler()
	if not equippedWeaponHandler then
		return false
	end
	local v5 = tbl4[skinApplied]
	if not v5 then
		return false
	end
	local v6 = fn8(skinApplied, v5)
	if equippedWeaponHandler.CurrentCosmetic == v6 then
		return true
	end
	local flag2 = false
	local flag3 = false

	local thread = coroutine.create(function()
		flag3 = pcall(fn9, equippedWeaponHandler, v6)
		flag2 = true
	end)

	pcall(setthreadcontext, thread, 8)
	pcall(coroutine.resume, thread)
	local n = os.clock() + 2

	while not flag2 and os.clock() < n do
		task.wait()
	end

	return flag3
end

fn(RunService.Heartbeat:Connect(function()
	if not fn2("CS_Apply") then
		return
	end
	local v4 = fn4()
	if not v4 then
		return
	end
	local v5 = tbl4[skinApplied]
	if not v5 or v4.EquippedWeapon ~= v5 then
		return
	end
	local equippedWeaponHandler = v4:GetEquippedWeaponHandler()

	if equippedWeaponHandler then
		local v6 = fn8(skinApplied, v5)

		if equippedWeaponHandler.CurrentCosmetic ~= v6 then
			pcall(function()
				fn9(equippedWeaponHandler, v6)
			end)
		end
	end
end))

local okWindUI, WindUI = pcall(function()
	local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
	return loadstring(source)()
end)

if not okWindUI or not WindUI then
	warn("[IndraHub] Failed to load WindUI")
	setGlobal("IndraHubDuelingGroundError", "WINDUI FAIL")
	return
end

local RealWindow = WindUI:CreateWindow({
	Title = "IndraHub | Dueling Grounds",
	Icon = "swords",
	Author = "IndraHub",
	Folder = "IndraHub_DuelingGrounds",
	Size = UDim2.fromOffset(640, 500),
	Transparent = true,
	Theme = "Dark",
	SideBarWidth = 185,
	HasOutline = true
})

local Library = {
	Unloaded = false,
	Unload = function(self)
		if self.Unloaded then return end
		self.Unloaded = true
		setGlobal("IndraHubDuelingGroundRunning", false)
		for _, conn in ipairs(tbl) do
			if typeof(conn) == "RBXScriptConnection" then
				pcall(function() conn:Disconnect() end)
			end
		end
		local ch = fn4()
		if ch and flag then ch.IsParrying = nil end
		pcall(function() RealWindow:Destroy() end)
		if getgenv then getgenv().__IndraHubDuelingGroundLib = nil end
	end,
	Notify = function(self, msg, duration)
		pcall(function()
			WindUI:Notify({
				Title = "IndraHub",
				Content = tostring(msg or ""),
				Duration = duration or 3
			})
		end)
	end
}
v = Library
if getgenv then getgenv().__IndraHubDuelingGroundLib = Library end

local CombatTab = RealWindow:Tab({ Title = "Combat", Icon = "swords" })
local CosmeticsTab = RealWindow:Tab({ Title = "Cosmetics", Icon = "sparkles" })
local SettingsTab = RealWindow:Tab({ Title = "Settings", Icon = "settings" })

-- Combat Tab
CombatTab:Section({ Title = "Auto Parry" })

CombatTab:Toggle({
	Title = "Enable Auto Parry",
	Desc = "Resolves incoming impacts as parries on client",
	Default = false,
	Callback = function(val)
		v2.AP_Enabled.Value = val
	end
})

CombatTab:Slider({
	Title = "Parry Chance",
	Desc = "Percentage of incoming impacts to parry",
	Default = 100,
	Min = 1,
	Max = 100,
	Callback = function(val)
		v3.AP_Chance.Value = val
	end
})

CombatTab:Toggle({
	Title = "Parry Notifications",
	Desc = "Shows toast notification for every successful parry",
	Default = false,
	Callback = function(val)
		v2.AP_Notify.Value = val
	end
})

CombatTab:Section({ Title = "God Mode" })

CombatTab:Toggle({
	Title = "Enable God Mode",
	Desc = "Resolves incoming impacts as dodges on client (takes no damage)",
	Default = false,
	Callback = function(val)
		v2.GM_Enabled.Value = val
	end
})

CombatTab:Section({ Title = "Combat Statistics" })

local StatsParagraph = CombatTab:Paragraph({
	Title = "Parry Counter",
	Desc = "Parried: 0 | Missed: 0 | Blocked: 0"
})

CombatTab:Button({
	Title = "Reset Counter",
	Desc = "Resets parry and miss statistics to zero",
	Callback = function()
		tbl2.parried = 0
		tbl2.blocked = 0
		tbl2.missed = 0
		pcall(function()
			StatsParagraph:SetDesc("Parried: 0 | Missed: 0 | Blocked: 0")
		end)
	end
})

task.spawn(function()
	while not Library.Unloaded do
		pcall(function()
			StatsParagraph:SetDesc(string.format("Parried: %d | Missed: %d | Blocked: %d", tbl2.parried, tbl2.missed, tbl2.blocked))
		end)
		task.wait(0.5)
	end
end)

-- Cosmetics Tab
CosmeticsTab:Section({ Title = "Skin Changer" })

CosmeticsTab:Toggle({
	Title = "Apply Skin",
	Desc = "Client-side: swaps equipped weapon model to chosen skin",
	Default = true,
	Callback = function(val)
		v2.CS_Apply.Value = val
	end
})

CosmeticsTab:Button({
	Title = "Apply Now",
	Desc = "Forces chosen skin onto currently equipped weapon",
	Callback = function()
		local v12 = tbl4[skinApplied]
		local v13 = fn4()
		if v13 and v13.EquippedWeapon == v12 then
			fn10()
			v:Notify("Skin applied: " .. skinApplied, 2)
		else
			v:Notify("Equip " .. tostring(v12 or "weapon") .. " first.", 2)
		end
	end
})

CosmeticsTab:Section({ Title = "Equip Weapon" })

CosmeticsTab:Dropdown({
	Title = "Equip Weapon",
	Desc = "Sends Request_SetCurrentWeapon for owned weapons",
	Values = tbl5,
	Value = tbl5[1] or "Katana",
	Callback = function(requestedWeapon)
		if type(requestedWeapon) ~= "string" then return end
		pcall(function()
			requestSetCurrentWeapon:FireServer(requestedWeapon)
		end)
		v:Notify("Requested weapon: " .. requestedWeapon, 2)
	end
})

CosmeticsTab:Section({ Title = "Weapon Skins" })

for k, v12 in pairs(tbl3) do
	CosmeticsTab:Dropdown({
		Title = k .. " Skin",
		Values = v12,
		Value = v12[1] or "",
		Callback = function(arg)
			if type(arg) ~= "string" then return end
			skinApplied = arg
			v:Notify(k .. " skin: " .. arg, 1.5)
		end
	})
end

-- Settings Tab
SettingsTab:Section({ Title = "Anti-AFK & Automation" })

local antiAfkLastInput = tick()
local antiAfkLastTap = tick()

pcall(function()
	for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
		pcall(function()
			connection:Disable()
		end)
	end
end)

local function antiAfkTap()
	local camera = workspace.CurrentCamera
	if not camera then return end
	VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
	task.wait(0.1)
	VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
	antiAfkLastTap = tick()
end

local antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
	antiAfkLastInput = tick()
end)

local antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
		antiAfkLastInput = tick()
	end
end)

SettingsTab:Toggle({
	Title = "Anti-AFK",
	Desc = "Prevents idle kicks after 20 minutes",
	Default = true,
	Callback = function(val)
		v2.AntiAfk.Value = val
	end
})

task.spawn(function()
	while not Library.Unloaded do
		task.wait(2)
		if v2.AntiAfk.Value then
			local idle = tick() - antiAfkLastInput
			local sinceTap = tick() - antiAfkLastTap
			if idle >= 300 and sinceTap >= 60 then
				pcall(antiAfkTap)
			elseif idle < 300 and sinceTap >= 300 then
				pcall(antiAfkTap)
			end
		end
	end
end)

SettingsTab:Section({ Title = "Script Management" })

SettingsTab:Button({
	Title = "Unload IndraHub",
	Desc = "Stops all loops and unloads user interface cleanly",
	Callback = function()
		Library:Unload()
	end
})

Library:Notify("Dueling Grounds module loaded successfully!")
