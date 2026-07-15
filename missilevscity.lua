local env = getgenv and getgenv() or _G

if env.IndraHubMisileVsCityCleanup then
	pcall(env.IndraHubMisileVsCityCleanup)
end

if env.IndraHubMisileVsCityRunning then return end
env.IndraHubMisileVsCityRunning = true

task.spawn(function()
	while task.wait(2) do
		if not env.IndraHubMisileVsCityRunning then break end
		env.IndraHubMisileVsCityLastHeartbeat = os.clock()
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("remotes")
local prompt_action = remotes:WaitForChild("prompt_action")
local naval_action = remotes:WaitForChild("naval_action")
local naval_sync = remotes:WaitForChild("naval_sync")
local fire_missile = remotes:WaitForChild("fire_missile")
local enter_targeting = remotes:WaitForChild("enter_targeting")
local fire_jet = remotes:WaitForChild("fire_jet")
local enter_jet_targeting = remotes:WaitForChild("enter_jet_targeting")
local state = require(ReplicatedStorage:WaitForChild("state"))

local DISTRICTS = {
	"district_downtown",
	"district_houses",
	"district_silos",
	"district_farm",
	"district_military_airport",
	"district_naval_dock",
	"district_nuclear_reactors",
	"district_solar_field",
	"district_warehouses",
}

local INDRAHUB_DISCORD = "https://discord.gg/2PPBJsmqr"

local Config = {
	AutoCollect = false,
	AutoUpgrade = false,
	AutoAttack = false,
	TargetPlayer = "Random",
	StrictTarget = false,
	TargetDistrict = "Random",
	AttackDelay = 1,
	AutoCounter = false,
	CounterDuration = 30,
	AutoScramble = false,
	ScrambleDelay = 2,
	AutoHangars = false,
	AutoShips = false,
	ShipRarities = {},
	MaxShipLevel = 100,
	MaxUpgradeCost = 0,
	CashReserve = 0,
	AutoDeploy = false,
	DeployMode = "Highest Gem Rate",
	DeployIsland = nil,
	SkipOwnedIslands = true,
	MinDeployLevel = 1,
	AutoCrates = false,
	CrateType = "wooden",
	GemReserve = 0,
	AntiAFK = true,
	MenuKeybind = "RightShift"
}

local function get_plot()
	local plots = workspace:FindFirstChild("map") and workspace.map:FindFirstChild("plots")
	if not plots then
		return nil
	end

	for _, plot in plots:GetChildren() do
		if plot:GetAttribute("owner_name") == LocalPlayer.Name then
			return plot
		end
	end

	return nil
end

local function get_root()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function teleport_to(position)
	local root = get_root()
	if root and typeof(position) == "Vector3" then
		root.CFrame = CFrame.new(position + Vector3.new(0, 6, 0))
	end
end

local function touch(root, part)
	firetouchinterest(root, part, 0)
	task.wait()
	firetouchinterest(root, part, 1)
end

local function collect_money()
	local plot = get_plot()
	local root = get_root()
	if not plot or not root then
		return
	end

	for _, part in plot:GetDescendants() do
		if part.Name == "collector" and part:IsA("BasePart") and part.CanTouch then
			touch(root, part)
		end
	end
end

local function press_buttons()
	local plot = get_plot()
	local root = get_root()
	if not plot or not root then
		return
	end

	for _, cap in plot:GetDescendants() do
		if cap.Name == "cap" and cap:IsA("BasePart") and cap.CanTouch and cap.Transparency == 0 then
			local model = cap.Parent
			if model:FindFirstChild("base") and cap.Color.G > 0.5 and cap.Color.R < 0.5 then
				touch(root, cap)
			end
		end
	end
end

local function enemy_plots()
	local plots = workspace:FindFirstChild("map") and workspace.map:FindFirstChild("plots")
	if not plots then
		return {}
	end

	local list = {}
	for _, plot in plots:GetChildren() do
		local owner = plot:GetAttribute("owner_name")
		if typeof(owner) == "string" and owner ~= "" and owner ~= LocalPlayer.Name then
			list[#list + 1] = { plot = plot, owner = owner }
		end
	end

	return list
end

local function pick_target()
	local list = enemy_plots()
	if #list == 0 then
		return nil
	end

	local wanted = Config.TargetPlayer
	if wanted and wanted ~= "Random" then
		for _, entry in list do
			if entry.owner == wanted then
				return entry.plot
			end
		end
		if Config.StrictTarget then
			return nil
		end
	end

	return list[math.random(#list)].plot
end

local function pick_district(plot)
	local wanted = Config.TargetDistrict
	if wanted and wanted ~= "Random" then
		return plot:FindFirstChild(wanted)
	end

	local found = {}
	for _, name in DISTRICTS do
		local district = plot:FindFirstChild(name)
		if district then
			found[#found + 1] = district
		end
	end

	return found[math.random(#found)]
end

local function aim_position(plot)
	local district = pick_district(plot)
	if not district then
		return plot:GetPivot().Position
	end

	local buildings = {}
	for _, child in district:GetChildren() do
		if child:IsA("Model") and child.PrimaryPart then
			buildings[#buildings + 1] = child
		end
	end

	if #buildings > 0 then
		return buildings[math.random(#buildings)]:GetPivot().Position
	end

	return district:GetPivot().Position
end

local function silo_anchors()
	local plot = get_plot()
	local list = {}
	if not plot then
		return list
	end

	for _, prompt in state.prompts() do
		if prompt.kind == "silo" and prompt.anchor and prompt.anchor:IsDescendantOf(plot) then
			list[#list + 1] = prompt.anchor
		end
	end

	return list
end

local native_targeting = {}
local native_jet_targeting = {}

pcall(function()
	native_targeting = getconnections(enter_targeting.OnClientEvent)
	native_jet_targeting = getconnections(enter_jet_targeting.OnClientEvent)
end)

local function set_connections(list, enabled)
	for _, connection in list do
		pcall(function()
			if enabled then
				connection:Enable()
			else
				connection:Disable()
			end
		end)
	end
end

local function set_native_targeting(enabled)
	set_connections(native_targeting, enabled)
end

local function set_native_jet_targeting(enabled)
	set_connections(native_jet_targeting, enabled)
end

local targeting_open = false
local jet_targeting_open = false

enter_targeting.OnClientEvent:Connect(function()
	targeting_open = true
end)

enter_jet_targeting.OnClientEvent:Connect(function()
	jet_targeting_open = true
end)

local function fire_silo(anchor, plot)
	targeting_open = false
	prompt_action:FireServer(anchor, "shoot")

	local deadline = os.clock() + 3
	while not targeting_open and os.clock() < deadline do
		task.wait(0.1)
	end

	if targeting_open then
		targeting_open = false
		fire_missile:FireServer(aim_position(plot))
		task.wait(Config.AttackDelay)
	end
end

local function attack()
	local anchors = silo_anchors()
	if #anchors == 0 then
		return
	end

	for _, anchor in anchors do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoAttack then
			return
		end

		local plot = pick_target()
		if not plot then
			return
		end

		fire_silo(anchor, plot)
	end
end

local counter_target = nil
local counter_deadline = 0

local function find_player_name(value, depth)
	if depth > 5 then
		return nil
	end

	local kind = typeof(value)
	if kind == "string" then
		if value ~= LocalPlayer.Name and Players:FindFirstChild(value) then
			return value
		end
	elseif kind == "Instance" and value:IsA("Player") then
		if value ~= LocalPlayer then
			return value.Name
		end
	elseif kind == "table" then
		for _, inner in value do
			local found = find_player_name(inner, depth + 1)
			if found then
				return found
			end
		end
	end

	return nil
end

local combat_signals = {
	"revenge_offer",
	"jet_defend_offer",
	"naval_contested",
	"naval_strike",
	"combat_alert",
	"missile_impact",
}

for _, signal in combat_signals do
	local event = remotes:FindFirstChild(signal)
	if event and event:IsA("RemoteEvent") then
		event.OnClientEvent:Connect(function(...)
			if not env.IndraHubMisileVsCityRunning or not Config.AutoCounter then
				return
			end

			local attacker = find_player_name({ ... }, 0)
			if attacker then
				counter_target = attacker
				counter_deadline = os.clock() + (tonumber(Config.CounterDuration) or 30)
			end
		end)
	end
end

local function counter_attack()
	if not counter_target or os.clock() > counter_deadline then
		return
	end

	local plot
	for _, entry in enemy_plots() do
		if entry.owner == counter_target then
			plot = entry.plot
			break
		end
	end

	if not plot then
		return
	end

	local anchors = silo_anchors()
	for _, anchor in anchors do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoCounter then
			return
		end
		if os.clock() > counter_deadline then
			return
		end

		fire_silo(anchor, plot)
	end
end

local function scramble_jets()
	local plot = get_plot()
	if not plot then
		return
	end

	for _, prompt in state.prompts() do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoScramble then
			return
		end

		local info = prompt.state
		if
			prompt.kind == "jet"
			and prompt.anchor
			and prompt.anchor:IsDescendantOf(plot)
			and typeof(info) == "table"
			and info.scramble_ready
			and not info.scramble_flying
			and not info.scramble_knocked
		then
			local target = pick_target()
			if not target then
				return
			end

			jet_targeting_open = false
			prompt_action:FireServer(prompt.anchor, "scramble")

			local deadline = os.clock() + 3
			while not jet_targeting_open and os.clock() < deadline do
				task.wait(0.1)
			end

			if jet_targeting_open then
				jet_targeting_open = false
				fire_jet:FireServer({ positions = { aim_position(target) } })
				task.wait(Config.ScrambleDelay)
			end
		end
	end
end

local function cash()
	local currency = LocalPlayer:FindFirstChild("currency")
	local value = currency and currency:FindFirstChild("Cash")
	return value and value.Value or 0
end

local function reserve()
	return tonumber(Config.CashReserve) or 0
end

local function affordable(cost)
	local limit = tonumber(Config.MaxUpgradeCost) or 0
	if limit > 0 and cost > limit then
		return false
	end

	return cash() - cost >= reserve()
end

local function upgrade_hangars()
	local plot = get_plot()
	if not plot then
		return
	end

	for _, prompt in state.prompts() do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoHangars then
			return
		end

		if prompt.kind == "jet" and prompt.anchor and prompt.anchor:IsDescendantOf(plot) then
			local info = prompt.state
			if typeof(info) == "table" and info.up_affordable and affordable(info.up_cost or 0) then
				prompt_action:FireServer(prompt.anchor, "upgrade")
				task.wait(0.4)
			end
		end
	end
end

local fleet = {}
local islands = {}
local crates = {}
local rarities = {}
local island_names = {}
local last_targets = ""

local ShipRaritiesDropdown = nil
local DeployIslandDropdown = nil

naval_sync.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or typeof(data.fleet) ~= "table" then
		return
	end

	fleet = data.fleet
	islands = typeof(data.islands) == "table" and data.islands or {}
	crates = typeof(data.crates) == "table" and data.crates or {}

	local seen, values = {}, {}
	for _, ship in fleet do
		if ship.rarity and not seen[ship.rarity] then
			seen[ship.rarity] = true
			values[#values + 1] = ship.rarity
		end
	end

	table.sort(values)
	if table.concat(values, ",") ~= table.concat(rarities, ",") then
		rarities = values
		if ShipRaritiesDropdown then
			ShipRaritiesDropdown:Refresh(values)
		end
	end

	local names = {}
	for _, island in islands do
		if typeof(island.name) == "string" and island.name ~= "" then
			names[#names + 1] = island.name
		end
	end

	table.sort(names)
	if table.concat(names, ",") ~= table.concat(island_names, ",") then
		island_names = names
		if DeployIslandDropdown then
			DeployIslandDropdown:Refresh(names)

			if not table.find(names, Config.DeployIsland) then
				DeployIslandDropdown:Set({names[1]})
			end
		end
	end
end)

local function selectedSet(value)
	local set = {}
	for name, state in pairs(value) do
		if state then
			set[name] = true
		end
	end
	return set
end

local function rarity_allowed(rarity)
	if type(Config.ShipRarities) ~= "table" or not next(Config.ShipRarities) then
		return true
	end

	return Config.ShipRarities[rarity] == true
end

local function upgrade_ships()
	naval_action:FireServer("sync")
	task.wait(0.5)

	for _, ship in fleet do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoShips then
			return
		end

		local cost = ship.upgrade_cost or 0
		if
			not ship.maxed
			and ship.upgrade_afford
			and rarity_allowed(ship.rarity)
			and (ship.level or 1) < Config.MaxShipLevel
			and affordable(cost)
		then
			naval_action:FireServer("upgrade_ship", ship.id)
			task.wait(0.4)
		end
	end
end

local function gems()
	local currency = LocalPlayer:FindFirstChild("currency")
	local value = currency and currency:FindFirstChild("Gems")
	return value and value.Value or 0
end

local function buy_crates()
	naval_action:FireServer("sync")
	task.wait(0.5)

	local key = Config.CrateType
	local crate = crates[key]
	if typeof(crate) ~= "table" or not crate.gems then
		return
	end

	local keep = tonumber(Config.GemReserve) or 0
	while gems() - crate.gems >= keep do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoCrates then
			return
		end

		naval_action:FireServer("roll", key, "gems")
		task.wait(1)
	end
end

local function pick_island(taken)
	local mode = Config.DeployMode
	local best

	for _, island in islands do
		local free = not taken[island.slot]
		local owned = island.mine == true
		local enemy = island.controller ~= nil and not owned

		if free and not (owned and Config.SkipOwnedIslands) then
			if mode == "Specific Island" then
				if island.name == Config.DeployIsland then
					return island
				end
			elseif mode == "Empty Islands" then
				if island.controller == nil then
					return island
				end
			elseif mode == "Enemy Islands" then
				if enemy and (not best or (island.rate or 0) > (best.rate or 0)) then
					best = island
				end
			elseif not best or (island.rate or 0) > (best.rate or 0) then
				best = island
			end
		end
	end

	return best
end

local function deploy_ships()
	naval_action:FireServer("sync")
	task.wait(0.5)

	local taken = {}

	for _, ship in fleet do
		if not env.IndraHubMisileVsCityRunning or not Config.AutoDeploy then
			return
		end

		if
			not ship.deployed
			and not ship.repairing
			and (ship.ready_in or 0) <= 0
			and rarity_allowed(ship.rarity)
			and (ship.level or 1) >= Config.MinDeployLevel
		then
			local island = pick_island(taken)
			if island then
				taken[island.slot] = true
				naval_action:FireServer("deploy", ship.id, island.slot)
				task.wait(0.4)
			end
		end
	end
end

-- ===================================================
-- WINDUI SETUP
-- ===================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "IndraHub  |  Missiles vs Cities",
	Icon = "rocket",
	Author = "IndraHub",
	Folder = "IndraHubMissilesVsCities",
	Size = UDim2.fromOffset(580, 460),
	Transparent = true,
	Theme = "Dark",
})

Window:SetToggleKey(Enum.KeyCode[Config.MenuKeybind] or Enum.KeyCode.RightShift)

local TabMain = Window:Tab({ Title = "Main", Icon = "home" })
local TabUpgrades = Window:Tab({ Title = "Upgrades", Icon = "trending-up" })
local TabNavy = Window:Tab({ Title = "Navy", Icon = "ship" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

local function notify(title, content, duration)
	pcall(function()
		WindUI:Notify({
			Title = title,
			Content = content,
			Duration = duration or 3
		})
	end)
end

-- ===================================================
-- TAB MAIN
-- ===================================================
TabMain:Section({ Title = "Farm" })

TabMain:Toggle({
	Title = "Auto Collect Money",
	Desc = "Automatically collects money from plots",
	Value = Config.AutoCollect,
	Callback = function(v) Config.AutoCollect = v end
})

TabMain:Toggle({
	Title = "Auto Upgrade Plot",
	Desc = "Automatically purchases building upgrades",
	Value = Config.AutoUpgrade,
	Callback = function(v) Config.AutoUpgrade = v end
})

TabMain:Section({ Title = "Attack" })

TabMain:Toggle({
	Title = "Auto Attack",
	Desc = "Automatically targets and launches missiles",
	Value = Config.AutoAttack,
	Callback = function(v)
		Config.AutoAttack = v
		set_native_targeting(not v)
	end
})

local TargetPlayerDropdown = TabMain:Dropdown({
	Title = "Target Player",
	Values = { "Random" },
	Value = Config.TargetPlayer,
	Callback = function(v)
		Config.TargetPlayer = type(v) == "table" and v[1] or v
	end
})

TabMain:Toggle({
	Title = "Only Attack Target",
	Value = Config.StrictTarget,
	Callback = function(v) Config.StrictTarget = v end
})

local district_values = { "Random" }
for _, name in DISTRICTS do
	district_values[#district_values + 1] = name
end

TabMain:Dropdown({
	Title = "Target District",
	Values = district_values,
	Value = Config.TargetDistrict,
	Callback = function(v)
		Config.TargetDistrict = type(v) == "table" and v[1] or v
	end
})

TabMain:Slider({
	Title = "Delay Between Missiles",
	Value = { Min = 0.5, Max = 10, Default = Config.AttackDelay },
	Step = 0.1,
	Callback = function(v) Config.AttackDelay = v end
})

TabMain:Toggle({
	Title = "Auto Counter-Attack",
	Value = Config.AutoCounter,
	Callback = function(v) Config.AutoCounter = v end
})

TabMain:Slider({
	Title = "Counter Duration",
	Value = { Min = 5, Max = 120, Default = Config.CounterDuration },
	Step = 1,
	Callback = function(v) Config.CounterDuration = v end
})

TabMain:Toggle({
	Title = "Auto Scramble Jets",
	Value = Config.AutoScramble,
	Callback = function(v)
		Config.AutoScramble = v
		set_native_jet_targeting(not v)
	end
})

TabMain:Slider({
	Title = "Delay Between Jets",
	Value = { Min = 0.5, Max = 10, Default = Config.ScrambleDelay },
	Step = 0.1,
	Callback = function(v) Config.ScrambleDelay = v end
})

TabMain:Button({
	Title = "Refresh Targets",
	Callback = function()
		pcall(refresh_targets)
	end
})

TabMain:Section({ Title = "Teleports" })

TabMain:Button({
	Title = "Teleport To Target",
	Callback = function()
		local wanted = Config.TargetPlayer
		if wanted and wanted ~= "Random" then
			local player = Players:FindFirstChild(wanted)
			local character = player and player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				teleport_to(root.Position)
				return
			end

			for _, entry in enemy_plots() do
				if entry.owner == wanted then
					teleport_to(entry.plot:GetPivot().Position)
					return
				end
			end
		end
		notify("Teleport", "No target selected or player not in game", 3)
	end
})

TabMain:Button({
	Title = "Back Home",
	Callback = function()
		local plot = get_plot()
		if plot then
			teleport_to(plot:GetPivot().Position)
		end
	end
})

local function refresh_targets()
	local values = { "Random" }
	for _, entry in enemy_plots() do
		values[#values + 1] = entry.owner
	end

	local key = table.concat(values, ",")
	if key == last_targets then
		return
	end

	last_targets = key
	if TargetPlayerDropdown then
		TargetPlayerDropdown:Refresh(values)
	end
end

pcall(refresh_targets)

-- ===================================================
-- TAB UPGRADES
-- ===================================================
TabUpgrades:Toggle({
	Title = "Auto Upgrade Hangars",
	Value = Config.AutoHangars,
	Callback = function(v) Config.AutoHangars = v end
})

TabUpgrades:Toggle({
	Title = "Auto Upgrade Ships",
	Value = Config.AutoShips,
	Callback = function(v) Config.AutoShips = v end
})

ShipRaritiesDropdown = TabUpgrades:Dropdown({
	Title = "Ship Rarities",
	Multi = true,
	Values = rarities,
	Value = {},
	Callback = function(v)
		Config.ShipRarities = selectedSet(v)
	end
})

TabUpgrades:Slider({
	Title = "Max Ship Level",
	Value = { Min = 1, Max = 100, Default = Config.MaxShipLevel },
	Step = 1,
	Callback = function(v) Config.MaxShipLevel = v end
})

TabUpgrades:Input({
	Title = "Max Upgrade Cost",
	Placeholder = "0",
	Value = tostring(Config.MaxUpgradeCost),
	Callback = function(v) Config.MaxUpgradeCost = tonumber(v) or 0 end
})

TabUpgrades:Input({
	Title = "Keep Cash",
	Placeholder = "0",
	Value = tostring(Config.CashReserve),
	Callback = function(v) Config.CashReserve = tonumber(v) or 0 end
})

-- ===================================================
-- TAB NAVY
-- ===================================================
TabNavy:Toggle({
	Title = "Auto Deploy Ships",
	Value = Config.AutoDeploy,
	Callback = function(v) Config.AutoDeploy = v end
})

TabNavy:Dropdown({
	Title = "Deploy Mode",
	Values = { "Highest Gem Rate", "Empty Islands", "Enemy Islands", "Specific Island" },
	Value = Config.DeployMode,
	Callback = function(v)
		Config.DeployMode = type(v) == "table" and v[1] or v
	end
})

DeployIslandDropdown = TabNavy:Dropdown({
	Title = "Island",
	Values = island_names,
	Value = Config.DeployIsland,
	Callback = function(v)
		Config.DeployIsland = type(v) == "table" and v[1] or v
	end
})

TabNavy:Button({
	Title = "Refresh Islands",
	Callback = function()
		naval_action:FireServer("sync")
	end
})

TabNavy:Toggle({
	Title = "Skip Islands I Hold",
	Value = Config.SkipOwnedIslands,
	Callback = function(v) Config.SkipOwnedIslands = v end
})

TabNavy:Slider({
	Title = "Min Ship Level",
	Value = { Min = 1, Max = 100, Default = Config.MinDeployLevel },
	Step = 1,
	Callback = function(v) Config.MinDeployLevel = v end
})

TabNavy:Toggle({
	Title = "Auto Buy Naval Crates",
	Value = Config.AutoCrates,
	Callback = function(v) Config.AutoCrates = v end
})

TabNavy:Dropdown({
	Title = "Crate",
	Values = { "wooden", "iron", "gold" },
	Value = Config.CrateType,
	Callback = function(v)
		Config.CrateType = type(v) == "table" and v[1] or v
	end
})

TabNavy:Input({
	Title = "Keep Gems",
	Placeholder = "0",
	Value = tostring(Config.GemReserve),
	Callback = function(v) Config.GemReserve = tonumber(v) or 0 end
})

-- ===================================================
-- TAB SETTINGS
-- ===================================================
TabSettings:Toggle({
	Title = "Anti-AFK",
	Value = Config.AntiAFK,
	Callback = function(v) Config.AntiAFK = v end
})

TabSettings:Keybind({
	Title = "Toggle UI",
	Key = Config.MenuKeybind,
	Callback = function(key)
		pcall(function() Window:SetToggleKey(key) end)
	end
})

TabSettings:Button({
	Title = "Copy IndraHub Discord",
	Desc = INDRAHUB_DISCORD,
	Callback = function()
		if setclipboard then
			setclipboard(INDRAHUB_DISCORD)
		elseif toclipboard then
			toclipboard(INDRAHUB_DISCORD)
		end
		notify("Discord", "IndraHub Discord link copied to clipboard!", 2)
	end
})

TabSettings:Button({
	Title = "Copy Owner's Discord",
	Desc = DISCORD_INVITE,
	Callback = function()
		if setclipboard then
			setclipboard(DISCORD_INVITE)
		elseif toclipboard then
			toclipboard(DISCORD_INVITE)
		end
		notify("Discord", "Owner's Discord link copied to clipboard!", 2)
	end
})

local function unload()
	env.IndraHubMisileVsCityRunning = false
	set_native_targeting(true)
	set_native_jet_targeting(true)
	pcall(function() Window:Destroy() end)
end

env.IndraHubMisileVsCityCleanup = unload

TabSettings:Button({
	Title = "Unload Script",
	Callback = unload
})

-- ===================================================
-- BACKGROUND LOOPS & CONNECTIONS
-- ===================================================
LocalPlayer.Idled:Connect(function()
	if not env.IndraHubMisileVsCityRunning then
		return
	end
	if not Config.AntiAFK then
		return
	end
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubMisileVsCityRunning then
			break
		end
		if Config.AutoCollect then
			pcall(collect_money)
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if not env.IndraHubMisileVsCityRunning then
			break
		end
		if Config.AutoUpgrade then
			pcall(press_buttons)
		end
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubMisileVsCityRunning then
			break
		end
		if Config.AutoAttack then
			pcall(attack)
		end
		if Config.AutoScramble then
			pcall(scramble_jets)
		end
		if Config.AutoCounter then
			pcall(counter_attack)
		end
	end
end)

task.spawn(function()
	while task.wait(5) do
		if not env.IndraHubMisileVsCityRunning then
			break
		end
		pcall(refresh_targets)
	end
end)

task.spawn(function()
	while task.wait(2) do
		if not env.IndraHubMisileVsCityRunning then
			break
		end
		if Config.AutoHangars then
			pcall(upgrade_hangars)
		end
		if Config.AutoShips then
			pcall(upgrade_ships)
		end
		if Config.AutoDeploy then
			pcall(deploy_ships)
		end
		if Config.AutoCrates then
			pcall(buy_crates)
		end
	end
end)

-- Initial Sync
naval_action:FireServer("sync")
notify("IndraHub", "Missiles vs Cities script loaded successfully!", 4)
