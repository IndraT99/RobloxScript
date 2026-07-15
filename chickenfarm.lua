local env = getgenv and getgenv() or _G

if env.IndraHubChickenCleanup then
	pcall(env.IndraHubChickenCleanup)
end

if env.IndraHubChickenRunning then return end
env.IndraHubChickenRunning = true

task.spawn(function()
	while task.wait(2) do
		if not env.IndraHubChickenRunning then break end
		env.IndraHubChickenLastHeartbeat = os.clock()
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Paper = ReplicatedStorage:WaitForChild("Paper")
local Remotes = Paper:WaitForChild("Remotes")
local RemoteEvent = Remotes:WaitForChild("__remoteevent")
local RemoteFunction = Remotes:WaitForChild("__remotefunction")

local Config = {
	AutoCollectEggs = false,
	AutoDepositEggs = false,
	AutoCollectCash = false,
	AutoMergeChickens = false,
	AutoBuyChickens = false,
	BuyCount = 5,
	AutoUpgradeProcess = false,
	AutoUpgradeBuyTier = false,
	AutoRebirth = false,
	AutoClaimGroup = false,
	AutoCollectLucky = false,
	AutoOpenLucky = false,
	AntiAFK = true,
	MenuKeybind = "RightShift"
}

local collectedUuids = {}
local collectedLuckyUuids = {}

local function isUuid(str)
	if typeof(str) ~= "string" then return false end
	return str:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Hook Client Event for Auto Egg Collection
local eggConnection
eggConnection = RemoteEvent.OnClientEvent:Connect(function(action, uuid, ...)
	if not env.IndraHubChickenRunning then
		if eggConnection then
			eggConnection:Disconnect()
		end
		return
	end
	if Config.AutoCollectEggs and action == "Egg Dropped" and typeof(uuid) == "string" then
		collectedUuids[uuid] = true
		pcall(function()
			RemoteEvent:FireServer("Collect Egg", uuid)
		end)
	end
end)

-- WindUI Setup
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "IndraHub  |  Chicken Tycoon",
	Icon = "egg",
	Author = "IndraHub",
	Folder = "IndraHubChicken",
	Size = UDim2.fromOffset(560, 420),
	Transparent = true,
	Theme = "Dark",
})

Window:SetToggleKey(Enum.KeyCode[Config.MenuKeybind] or Enum.KeyCode.RightShift)

local TabMain = Window:Tab({ Title = "Main / Farm", Icon = "home" })
local TabUpgrades = Window:Tab({ Title = "Upgrades", Icon = "trending-up" })
local TabMisc = Window:Tab({ Title = "Misc & Settings", Icon = "settings" })

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
TabMain:Section({ Title = "Egg Harvesting" })

TabMain:Toggle({
	Title = "Auto Collect Eggs",
	Desc = "Instantly collects dropped eggs via remote events",
	Value = Config.AutoCollectEggs,
	Callback = function(v) Config.AutoCollectEggs = v end
})

TabMain:Toggle({
	Title = "Auto Deposit Eggs",
	Desc = "Deposits collected eggs to nesting area",
	Value = Config.AutoDepositEggs,
	Callback = function(v) Config.AutoDepositEggs = v end
})

TabMain:Section({ Title = "Cash & Merging" })

TabMain:Toggle({
	Title = "Auto Collect Cash",
	Desc = "Collects accumulated cash automatically",
	Value = Config.AutoCollectCash,
	Callback = function(v) Config.AutoCollectCash = v end
})

TabMain:Toggle({
	Title = "Auto Merge Chickens",
	Desc = "Merges duplicate tier chickens automatically",
	Value = Config.AutoMergeChickens,
	Callback = function(v) Config.AutoMergeChickens = v end
})

TabMain:Section({ Title = "Lucky Blocks" })

TabMain:Toggle({
	Title = "Auto Collect Lucky Blocks",
	Desc = "Automatically collects spawned lucky blocks",
	Value = Config.AutoCollectLucky,
	Callback = function(v) Config.AutoCollectLucky = v end
})

TabMain:Toggle({
	Title = "Auto Open Lucky Blocks",
	Desc = "Automatically opens collected lucky blocks",
	Value = Config.AutoOpenLucky,
	Callback = function(v) Config.AutoOpenLucky = v end
})

-- ===================================================
-- TAB UPGRADES
-- ===================================================
TabUpgrades:Section({ Title = "Chicken Purchase" })

TabUpgrades:Toggle({
	Title = "Auto Buy Chickens",
	Desc = "Buys chickens automatically",
	Value = Config.AutoBuyChickens,
	Callback = function(v) Config.AutoBuyChickens = v end
})

TabUpgrades:Dropdown({
	Title = "Buy Count",
	Desc = "Number of chickens to buy per invocation",
	Values = { "1", "5", "10" },
	Value = tostring(Config.BuyCount),
	Callback = function(v)
		local val = type(v) == "table" and v[1] or v
		Config.BuyCount = tonumber(val) or 5
	end
})

TabUpgrades:Section({ Title = "Base Upgrades" })

TabUpgrades:Toggle({
	Title = "Auto Upgrade Process Level",
	Desc = "Automatically levels up egg processing",
	Value = Config.AutoUpgradeProcess,
	Callback = function(v) Config.AutoUpgradeProcess = v end
})

TabUpgrades:Toggle({
	Title = "Auto Upgrade Buy Tier Level",
	Desc = "Automatically increases purchase tier",
	Value = Config.AutoUpgradeBuyTier,
	Callback = function(v) Config.AutoUpgradeBuyTier = v end
})

-- ===================================================
-- TAB MISC & SETTINGS
-- ===================================================
TabMisc:Section({ Title = "Game Extras" })

TabMisc:Toggle({
	Title = "Auto Rebirth",
	Desc = "Performs rebirth automatically when possible",
	Value = Config.AutoRebirth,
	Callback = function(v) Config.AutoRebirth = v end
})

TabMisc:Toggle({
	Title = "Auto Claim Group Rewards",
	Desc = "Claims group rewards automatically",
	Value = Config.AutoClaimGroup,
	Callback = function(v) Config.AutoClaimGroup = v end
})

TabMisc:Section({ Title = "System" })

TabMisc:Toggle({
	Title = "Anti-AFK",
	Value = Config.AntiAFK,
	Callback = function(v) Config.AntiAFK = v end
})

TabMisc:Keybind({
	Title = "Toggle UI",
	Key = Config.MenuKeybind,
	Callback = function(key)
		pcall(function() Window:SetToggleKey(key) end)
	end
})

TabMisc:Button({
	Title = "Copy Discord Link",
	Desc = "https://discord.gg/2PPBJsmqr",
	Callback = function()
		if setclipboard then
			setclipboard("https://discord.gg/2PPBJsmqr")
		elseif toclipboard then
			toclipboard("https://discord.gg/2PPBJsmqr")
		end
		notify("Discord", "IndraHub Discord link copied!", 2)
	end
})

local function unload()
	env.IndraHubChickenRunning = false
	if eggConnection then
		eggConnection:Disconnect()
	end
	pcall(function() Window:Destroy() end)
end

env.IndraHubChickenCleanup = unload

TabMisc:Button({
	Title = "Unload Script",
	Callback = unload
})

-- ===================================================
-- LOOPS
-- ===================================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
	if not env.IndraHubChickenRunning then return end
	if not Config.AntiAFK then return end
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoDepositEggs then
			pcall(function()
				RemoteFunction:InvokeServer("Deposit Eggs")
			end)
		end
	end
end)

local function collectEggs()
	local plot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(LocalPlayer.Name)
	local nest = plot and plot:FindFirstChild("Chickens") and plot.Chickens:FindFirstChild("ChickenNest")
	if nest then
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		for _, child in ipairs(nest:GetChildren()) do
			-- Approach 1: Attribute & Name scan
			local uuid = child:GetAttribute("UUID") or child:GetAttribute("uuid") or child:GetAttribute("Id") or child:GetAttribute("id") or child:GetAttribute("EggId")
			if not uuid and isUuid(child.Name) then
				uuid = child.Name
			end
			if uuid and typeof(uuid) == "string" and not collectedUuids[uuid] then
				collectedUuids[uuid] = true
				pcall(function()
					RemoteEvent:FireServer("Collect Egg", uuid)
				end)
			end

			-- Approach 2: Physical Touch Simulation
			if root and (child:IsA("BasePart") or (child:IsA("Model") and child.PrimaryPart)) then
				local part = child:IsA("BasePart") and child or child.PrimaryPart
				if part then
					pcall(function()
						firetouchinterest(root, part, 0)
						firetouchinterest(root, part, 1)
					end)
				end
			end
		end
	end
end

task.spawn(function()
	while task.wait(0.2) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoCollectEggs then
			pcall(collectEggs)
		end
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoCollectCash then
			pcall(function()
				RemoteFunction:InvokeServer("Collect Cash")
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoMergeChickens then
			pcall(function()
				RemoteFunction:InvokeServer("Merge Chickens")
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoBuyChickens then
			pcall(function()
				RemoteFunction:InvokeServer("Buy Chickens", Config.BuyCount)
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoUpgradeProcess then
			pcall(function()
				RemoteFunction:InvokeServer("Upgrade Process Level")
			end)
		end
		if Config.AutoUpgradeBuyTier then
			pcall(function()
				RemoteFunction:InvokeServer("Upgrade Buy Tier Level")
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(5) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoRebirth then
			pcall(function()
				RemoteFunction:InvokeServer("Rebirth")
			end)
		end
	end
end)

task.spawn(function()
	while task.wait(30) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoClaimGroup then
			pcall(function()
				RemoteFunction:InvokeServer("Claim Group Reward")
			end)
		end
	end
end)

local function collectLuckyBlocks()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local plot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(LocalPlayer.Name)
	local searchTargets = { plot, workspace }
	for _, parent in ipairs(searchTargets) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if parent == workspace and (not child:IsA("Model") and not child:IsA("BasePart")) then
					continue
				end
				
				if child.Name:lower():find("lucky") or child.Name:lower():find("block") then
					local uuid = child:GetAttribute("UUID") or child:GetAttribute("uuid") or child:GetAttribute("Id") or child:GetAttribute("id")
					if not uuid and isUuid(child.Name) then
						uuid = child.Name
					end
					if uuid and typeof(uuid) == "string" and not collectedLuckyUuids[uuid] then
						collectedLuckyUuids[uuid] = true
						task.spawn(function()
							RemoteFunction:InvokeServer("Collect Lucky Block", uuid)
						end)
					end
					
					-- TouchTransmitter touch simulation
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("TouchTransmitter") then
							local part = desc.Parent
							if part and part:IsA("BasePart") then
								task.spawn(function()
									firetouchinterest(root, part, 0)
									firetouchinterest(root, part, 1)
								end)
							end
						end
					end
				end
			end
		end
	end
end

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoCollectLucky then
			pcall(collectLuckyBlocks)
		end
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if not env.IndraHubChickenRunning then break end
		if Config.AutoOpenLucky then
			pcall(function()
				RemoteFunction:InvokeServer("Open Lucky Block")
			end)
		end
	end
end)

notify("IndraHub", "Chicken Tycoon script loaded successfully!", 4)
