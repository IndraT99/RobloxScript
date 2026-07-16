local Env = (getgenv and getgenv()) or _G
local SessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
local function setGlobal(key, value) rawset(_G, key, value); if Env ~= _G then Env[key] = value end end
local function getGlobal(key) local value = rawget(_G, key); if value ~= nil then return value end return Env[key] end
setGlobal("IndraHubDieOfDeathRunning", true)
setGlobal("IndraHubDieOfDeathSession", SessionId)
setGlobal("IndraHubDieOfDeathLastHeartbeat", os.clock())

--[[

Your Variables and global variables

]]--

--[[ Don't change this ]]--
local LocalPlayer, LP = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer
local Character, Char
local HumanoidRootPart, HRP
local Humanoid, Hum
pcall(function()
Character, Char = LocalPlayer.Character, LocalPlayer.Character
end)
pcall(function()
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
end)
pcall(function()
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)
LocalPlayer.CharacterAdded:Connect(function(char)
pcall(function()
Character, Char = nil, nil
HumanoidRootPart, HRP = nil, nil
Humanoid, Hum = nil, nil
task.wait()
Character, Char = char, char
repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
HumanoidRootPart, HRP = char.HumanoidRootPart, char.HumanoidRootPart
repeat task.wait() until Character:FindFirstChild("Humanoid")
Humanoid, Hum = char.Humanoid, char.Humanoid
end)
end)





--[[

Loading Part ( mainmodule and rayfield )

]]--



function CreateMessage(a)
local instancename = (a=="Message" and a) or "Hint"
local msg = Instance.new(instancename,game:GetService("CoreGui"))
msg.Text = ""
return msg
end

--[[ Loading WindUI Wrapper ]]--
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

local Module = {}
function Module:GetWorkingRayfield()
    local RayfieldLibrary = {}
    function RayfieldLibrary:CreateWindow(config)
        local Window = WindUI:CreateWindow({
            Title = config.Name or "DieOfDeath Hub",
            Icon = "lucide-skull",
            Author = config.LoadingSubtitle or "IndraHub",
            Folder = "IndraHubDieOfDeath",
            Size = UDim2.fromOffset(580, 460),
            Transparent = true,
            Theme = "Dark",
            Resizable = true,
            SideBarWidth = 175,
        })
        local fakeWindow = {}
        function fakeWindow:CreateTab(name, icon)
            local iconStr = "list"
            if type(icon) == "string" and icon ~= "" then iconStr = icon end
            local realTab = Window:Tab({ Title = name or "Tab", Icon = iconStr })
            local fakeTab = {}
            function fakeTab:CreateParagraph(pconfig)
                return realTab:Paragraph({ Title = pconfig.Title or "", Desc = pconfig.Content or "" })
            end
            function fakeTab:CreateLabel(name)
                return realTab:Paragraph({ Title = name, Desc = "" })
            end
            function fakeTab:CreateButton(bconfig)
                return realTab:Button({ Title = bconfig.Name or "Button", Desc = bconfig.Description or "", Callback = bconfig.Callback or function() end })
            end
            function fakeTab:CreateToggle(tconfig)
                local currentVal = tconfig.CurrentValue or false
                local toggle = realTab:Toggle({ Title = tconfig.Name or "Toggle", Desc = tconfig.Description or "", Value = currentVal, Callback = tconfig.Callback or function() end })
                local fakeToggle = {}
                function fakeToggle:Set(val) pcall(function() toggle:Set(val) end) end
                return fakeToggle
            end
            function fakeTab:CreateSlider(sconfig)
                local slider = realTab:Slider({ Title = sconfig.Name or "Slider", Desc = sconfig.Description or "", Step = sconfig.Increment or 1, Min = sconfig.Range and sconfig.Range[1] or 0, Max = sconfig.Range and sconfig.Range[2] or 100, Value = sconfig.CurrentValue or (sconfig.Range and sconfig.Range[1] or 0), Callback = sconfig.Callback or function() end })
                local fakeSlider = {}
                function fakeSlider:Set(val) pcall(function() slider:Set(val) end) end
                return fakeSlider
            end
            function fakeTab:CreateDropdown(dconfig)
                local default = dconfig.CurrentOption
                if type(default) == "table" then default = default[1] end
                local dropdown = realTab:Dropdown({ Title = dconfig.Name or "Dropdown", Desc = dconfig.Description or "", Values = dconfig.Options or {}, Value = default, Multi = dconfig.MultipleOptions or false, Callback = dconfig.Callback or function() end })
                local fakeDd = {}
                function fakeDd:Set(val) pcall(function() dropdown:Select(val) end) end
                function fakeDd:Refresh(options, keepSelection) pcall(function() dropdown:Refresh(options) end) end
                return fakeDd
            end
            function fakeTab:CreateInput(iconfig)
                return realTab:Input({ Title = iconfig.Name or "Input", Desc = iconfig.PlaceholderText or "", Placeholder = iconfig.PlaceholderText or "", Callback = iconfig.Callback or function() end })
            end
            function fakeTab:CreateSection(name)
                return realTab:Section({ Title = name })
            end
            return fakeTab
        end
        function fakeWindow:CreateTabSection(name) return {} end
        return fakeWindow
    end
    function RayfieldLibrary:Notify(data)
        pcall(function() WindUI:Notify({ Title = data.Title or "Notification", Content = data.Content or "", Icon = "info", Duration = data.Duration or 3 }) end)
    end
    function RayfieldLibrary:Notification(title, content, duration, icon)
        pcall(function() WindUI:Notify({ Title = title or "Notification", Content = content or "", Icon = "info", Duration = duration or 3 }) end)
    end
    function RayfieldLibrary:Destroy()
    end
    return RayfieldLibrary
end

local Rayfield = Module:GetWorkingRayfield()


--[[ Re-writing variables ]]--
AuthorKey = ""..((AuthorKey ~= nil and AuthorKey) or "Unknown")..""
GameKey = ""..((GameKey ~= nil and GameKey) or "Unknown")..""


--[[ Creating Window ]]--
local Window = Rayfield:CreateWindow({
   Name = ""..AuthorKey.." Hub : "..GameKey.."",
   Icon = 0,    
   LoadingTitle = ""..string.sub(AuthorKey,1,1).."H:"..GameKey:gsub("(%S)%S+","%1"):gsub("%s+","").."",
   LoadingSubtitle = "By "..AuthorKey.."",
   Theme = "AmberGlow",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "",
      FileName = ""
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Verify yourself firstly!",
      Subtitle = "Key Needed!",
      Note = "The key is ''cheese''",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"cheese"}
   }
})


--[[ Additional Connections Handler ]]--
local rs = game:GetService("RunService")
local Heartbeat = {}
rs.Heartbeat:Connect(function()
for i,v in next, Heartbeat do
if v~=nil then
task.spawn(v)
end
end
end)
--[[local TaskTick = {}
task.spawn(function()
while task.wait() do
for i,v in next, TaskTick do
if v~=nil then
task.spawn(v)
end
end
end
end)]]--
--upconnections: stepped, renderstepped, postsimulation



--[[

Tabs And Main Functions

]]--





local Announcements = Window:CreateTab("Announce",0)
Announcements:CreateParagraph({Title = "W.I.P.", Content = "A lot of stuff haven't been added yet. Work is in progress. As of right now ( June 12th ) script will be updating every 10 minutes or so. Make sure your new update notifier is turned on!"})
Announcements:CreateLabel("Version: "..Version)
Announcements:CreateButton({Name = "Copy discord server link"; Callback = function()
setclipboard(tostring("https://discord.gg/2PPBJsmqr"))
Rayfield:Notification("Success!", "Copied Link!", 3, true)
end; })
Announcements:CreateButton({Name = "Re-Launch script"; Callback = function()
loadstring(game:HttpGet(ScriptLink))()
Rayfield:Notification("Success!", "Re-Launching script...", 3, true)
end; })

Window:CreateTabSection("Movement")

local Movement = Window:CreateTab("Movement",0)

local function GetLegitMaxStamina()
local legitmaxstamina = 100
if Character:GetAttribute("Killer") then
if Character:GetAttribute("Killer")=="Pursuer" or Character:GetAttribute("Killer")=="Killdroid" then
legitmaxstamina = 110
elseif Character:GetAttribute("Killer")=="Harken" then
legitmaxstamina = 114
elseif Character:GetAttribute("Killer")=="Badware" then
legitmaxstamina = 110
end
end
return legitmaxstamina
end
local InfiniteStamina = false
Movement:CreateToggle({Name = "Infinite Stamina"; CurrentValue = false; Callback = function(Value)
InfiniteStamina = Value
Character:SetAttribute("MaxStamina",(Value==true and math.huge or GetLegitMaxStamina()))
if Character:IsDescendantOf(workspace.GameAssets.Teams) then
Rayfield:Notification("Success!", "Infinite stamina will automatically inject once the new round starts!", 3, true)
end
end; })
local CanJump = false
Movement:CreateToggle({Name = "Can Jump?"; CurrentValue = false; Callback = function(Value)
CanJump = Value
if Value==true then Humanoid.UseJumpPower=false else Humanoid.UseJumpPower=true end
end; })
local NoFatigue = false
Movement:CreateToggle({Name = "No Fatigue"; CurrentValue = NoFatigue; Callback = function(Value)
NoFatigue = Value
if Value == true then
task.spawn(function()
Heartbeat.LoopNoFatigue = function() if Character~=nil and Character:GetAttribute("Fatigue")~=nil and Character:GetAttribute("Fatigue") == 1 then Character:SetAttribute("Fatigue", 0) end end
repeat task.wait(0.1) until NoFatigue == false
if Heartbeat.LoopNoFatigue~=nil then
Heartbeat.LoopNoFatigue = nil
end
end)
end
end; })
local NoSpeedDebuffs = false
Movement:CreateToggle({Name = "No Speed Debuffs"; CurrentValue = NoFatigue; Callback = function(Value)
NoSpeedDebuffs = Value
if Value == true then
task.spawn(function()
Heartbeat.LoopNoSpeedDebuffs = function() if Character~=nil and Character:GetAttribute("WalkSpeedModifier")~=nil and Character:GetAttribute("WalkSpeedModifier")<0 then Character:SetAttribute("WalkSpeedModifier", 0) end end
repeat task.wait(0.1) until NoSpeedDebuffs == false
if Heartbeat.LoopNoSpeedDebuffs~=nil then
Heartbeat.LoopNoSpeedDebuffs = nil
end
end)
end
end; })

local Teleport = Window:CreateTab("Teleport",0)
Teleport:CreateParagraph({Title = "Teleports", Content = "Teleport to killer / survivors and others."})
function SafeTeleport(model)
pcall(function()
local time = tick()
while tick() - time < 1 do
for i,v in pairs(Character:GetDescendants()) do
if v and v:IsA("BasePart") then
v.Velocity = Vector3.new(0,0,0)
v.RotVelocity = Vector3.new(0,0,0)
end
end
HumanoidRootPart.CFrame = model.CFrame
task.wait()
end
end)
end
function GetChildNames(model)
local coolbalt = {}
for i,v in pairs(model:GetChildren()) do
if v then
table.insert(coolbalt, tostring(v.Name))
end
end
return coolbalt
end
Teleport:CreateSection("Team Teleport")
ChoosenKillerTarget = nil
ChoosenSurvivorTarget = nil
ChoosenGhostTarget = nil
local TeleportToKillerDropdown = Teleport:CreateDropdown({Name = "Target Killer"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenKillerTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Killer"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no killers!", 3, warn)
return nil
end
if ChoosenKillerTarget == nil or ChoosenKillerTarget == "" or not ChoosenKillerTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, false)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer"):FindFirstChild(ChoosenKillerTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer").ChildAdded:Connect(function(child)
pcall(function()
TeleportToKillerDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToKillerDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")))
end)
end)
local TeleportToSurvivorDropdown = Teleport:CreateDropdown({Name = "Target Survivor"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenSurvivorTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Survivor"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no survivors!", 3, false)
return nil
end
if ChoosenSurvivorTarget == nil or ChoosenSurvivorTarget == "" or not ChoosenSurvivorTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, warn)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor"):FindFirstChild(ChoosenSurvivorTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor").ChildAdded:Connect(function(child)
pcall(function()
TeleportToSurvivorDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToSurvivorDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")))
end)
end)
local TeleportToGhostDropdown = Teleport:CreateDropdown({Name = "Target Ghost"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenGhostTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Ghost"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no ghosts!", 3, warn)
return nil
end
if ChoosenGhostTarget == nil or ChoosenGhostTarget == "" or not ChoosenGhostTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, false)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost"):FindFirstChild(ChoosenGhostTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost").ChildAdded:Connect(function(child)
pcall(function()
TeleportToGhostDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToGhostDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")))
end)
end)

Window:CreateTabSection("Survivor")

local AbilityGiver = Window:CreateTab("Ability Giver",0)

local AbilityBugle = Window:CreateTab("Bugle",0)

local BugleDelay = 0
AbilityBugle:CreateSlider({Name = "Delay Between using Bugle"; Range = {0, 2}; Increment = .1; Suffix = " seconds"; CurrentValue = 0; Callback = function(Value)
BugleDelay = tonumber(Value)
end; })

local AutoBugle = false
AbilityBugle:CreateToggle({Name = "Auto Bugle"; CurrentValue = false; Callback = function(Value)
AutoBugle = Value
end; })
LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle:GetPropertyChangedSignal("Visible"):Connect(function()
if LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle.Visible and AutoBugle then
for i=1,100 do
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Abilities"):WaitForChild("Bugle"):FireServer(true)
if BugleDelay~=0 then
task.wait(BugleDelay)
end
if not LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle.Visible then
break
end
end
end
end)

local AbilityPie = Window:CreateTab("Pie",0)

AbilityPie:CreateMarkdown({Title = "Coordinates Guide", Content = [[
By using coordinates you can decide where will the pie be thrown. The pie is being launched from HumanoidRootPart's front.
The default is Vector3.new(0,0,-100). This will shoot the pie just like the bullet from the revolver and will explode after flying -100 studs on Z coordinate.

Examples:
Vector3.new(X,Y,Z) - The coordinates you can set below
Vector3.new(0,0,0) - On Yourself
Vector3.new(-100,0,0) - Left (relative to where HumanoidRootPart is facing)
Vector3.new(100,0,0) - Right (relative to where HumanoidRootPart is facing)
Vector3.new(0,-100,0) - Down (relative to where HumanoidRootPart is facing)
Vector3.new(0,100,0) - Up (relative to where HumanoidRootPart is facing)
Vector3.new(0,0,-100) - Forward (relative to where HumanoidRootPart is facing)
Vector3.new(0,0,100) - Backward (relative to where HumanoidRootPart is facing)]]})

local Pie_X = 0
AbilityPie:CreateInput({Name = "X Coordinate"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_X = tonumber(Value)
end; })

local Pie_Y = 0
AbilityPie:CreateInput({Name = "Y Coordinate"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_Y = tonumber(Value)
end; })

local Pie_Z = -100
AbilityPie:CreateInput({Name = "Z Coordinate"; PlaceholderText = "-100"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_Z = tonumber(Value)
end; })

local PieDelay = 0
AbilityPie:CreateSlider({Name = "Delay Before using Pie"; Range = {0, 3}; Increment = .1; Suffix = " seconds"; CurrentValue = 0; Callback = function(Value)
PieDelay = tonumber(Value)
end; })

local AutoPie = false
AbilityPie:CreateToggle({Name = "Auto Pie"; CurrentValue = false; Callback = function(Value)
AutoPie = Value
end; })
LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Pie:GetPropertyChangedSignal("Visible"):Connect(function()
if LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Pie.Visible and AutoPie then
if PieDelay~=0 then
task.wait(PieDelay)
end
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Abilities"):WaitForChild("Pie"):FireServer(Vector3.new(Pie_X,Pie_Y,Pie_Z))
end
end)

Window:CreateTabSection("Killer")

local AbilitySwing = Window:CreateTab("M1",0)

local NoCDSwing = false
AbilitySwing:CreateToggle({Name = "No Cooldown M1"; CurrentValue = false; Callback = function(Value)
NoCDSwing = Value
if NoCDSwing~=true then return end
Character:SetAttribute("SwingCooldown","")
Character:GetAttributeChangedSignal("SwingCooldown"):Connect(function()
if NoCDSwing~=true then return end
Character:SetAttribute("SwingCooldown","")
end)
Character:SetAttribute("EjectCooldown","")
Character:GetAttributeChangedSignal("EjectCooldown"):Connect(function()
if NoCDSwing~=true then return end
Character:SetAttribute("EjectCooldown","")
end)
end; })
LocalPlayer.CharacterAdded:Connect(function(cac)
task.spawn(function()
if InfiniteStamina~=true then return end
cac:SetAttribute("MaxStamina",math.huge)
cac:GetAttributeChangedSignal("MaxStamina"):Connect(function()
if InfiniteStamina~=true then return end
cac:SetAttribute("MaxStamina",math.huge)
end)
end)
task.spawn(function()
if CanJump~=true then return end
cac:WaitForChild("Humanoid",9e9).UseJumpPower=true
end)
task.spawn(function()
if NoCDSwing~=true then return end
cac:SetAttribute("SwingCooldown","")
cac:GetAttributeChangedSignal("SwingCooldown"):Connect(function()
if NoCDSwing~=true then return end
cac:SetAttribute("SwingCooldown","")
end)
end)
task.spawn(function()
if NoCDSwing~=true then return end
cac:SetAttribute("EjectCooldown","")
cac:GetAttributeChangedSignal("EjectCooldown"):Connect(function()
if NoCDSwing~=true then return end
cac:SetAttribute("EjectCooldown","")
end)
end)
end)

Window:CreateTabSection("Animations")

pcall(function()
AnimationsModule = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Animation control system
local AnimationController = {}
AnimationController.Enabled = true
AnimationController.ActiveAnimations = {}
AnimationController.CharacterConnections = {}
AnimationController.CharacterAnimators = {}
AnimationController.LoadedTracks = {}

-- Initialize workspace attributes
if workspace:GetAttribute("AnimationsEnabled") == nil then
	workspace:SetAttribute("AnimationsEnabled", true)
end

-- Listen for attribute changes
workspace:GetAttributeChangedSignal("AnimationsEnabled"):Connect(function()
	AnimationController.Enabled = workspace:GetAttribute("AnimationsEnabled")
	if not AnimationController.Enabled then
		AnimationController:UnloadAllAnimations()
	else
		for character, _ in pairs(AnimationController.CharacterAnimators) do
			if character and character.Parent and character:IsDescendantOf(workspace) then
				if character:FindFirstChild("Humanoid") and character:FindFirstChild("Animations") then
					task.spawn(function()
						AnimationController:LoadCharacterAnimations(character)
					end)
				end
			else
				AnimationController.CharacterAnimators[character] = nil
			end
		end
	end
end)

function AnimationController:UnloadAllAnimations()
	for character, tracks in pairs(self.LoadedTracks) do
		for trackName, track in pairs(tracks) do
			if track and track.IsPlaying then
				track:Stop()
			end
		end
	end
	self.LoadedTracks = {}
	self:StopAllAnimations()
end

function AnimationController:StopAllAnimations()
	for character, animations in pairs(self.ActiveAnimations) do
		for animName, track in pairs(animations) do
			if track and track.IsPlaying then
				track:Stop()
			end
		end
	end
	self.ActiveAnimations = {}
end

function AnimationController:CleanupCharacter(character)
	if self.LoadedTracks[character] then
		for trackName, track in pairs(self.LoadedTracks[character]) do
			if track and track.IsPlaying then
				track:Stop()
			end
		end
		self.LoadedTracks[character] = nil
	end
	
	if self.ActiveAnimations[character] then
		for animName, track in pairs(self.ActiveAnimations[character]) do
			if track and track.IsPlaying then
				track:Stop()
			end
		end
		self.ActiveAnimations[character] = nil
	end

	if self.CharacterConnections[character] then
		for _, connection in ipairs(self.CharacterConnections[character]) do
			connection:Disconnect()
		end
		self.CharacterConnections[character] = nil
	end

	self.CharacterAnimators[character] = nil
end

function AnimationController:LoadAnimationTrack(character, animationName, animationId)
	if not self.Enabled then return nil end
	if not character or not character.Parent then return nil end
	
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return nil end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	
	local track = animator:LoadAnimation(animation)
	
	if not self.LoadedTracks[character] then
		self.LoadedTracks[character] = {}
	end
	self.LoadedTracks[character][animationName] = track
	
	return track
end

function AnimationController:AdjustAnimationSpeed(character, track)
	if not character or not track then return end
	if track.Name ~= "Walk" and track.Name ~= "HurtWalk" and track.Name ~= "Sprint" and track.Name ~= "HurtSprint" then
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	
	local speed = humanoid.WalkSpeed
	local isSprint = track.Name == "Sprint" or track.Name == "HurtSprint"
	local baseSpeed = isSprint and (character:GetAttribute("SprintSpeed") or 26) or (character:GetAttribute("WalkSpeed") or 6)
	local adjustedSpeed = math.clamp(speed / baseSpeed, 0.1, 10)
	
	track:AdjustSpeed(adjustedSpeed)
end

function AnimationController:PlayAnimation(character, animationName, stopExisting, fadeTime)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local animationsFolder = character:FindFirstChild("Animations")
	
	if not humanoid or not animationsFolder then
		return
	end
	
	-- Check if animation is already playing
	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		if track.Name == animationName then
			if stopExisting then
				track:Stop(fadeTime or 0.25)
				return
			end
			if not track.IsPlaying then
				track:Play()
			end
			self:AdjustAnimationSpeed(character, track)
			return
		end
	end
	
	if stopExisting then
		return
	end
	
	-- Find animation in Animations folder
	local animationObj = animationsFolder:FindFirstChild(animationName, true)
	if not animationObj then
		return
	end
	
	local track = humanoid:LoadAnimation(animationObj)
	track.Name = animationName
	track:Play(fadeTime or 0.25)
	
	-- Set priority based on animation type
	if animationName == "Idle" or animationName == "HurtIdle" then
		track.Priority = Enum.AnimationPriority.Core
	elseif animationName == "Walk" or animationName == "HurtWalk" then
		track.Priority = Enum.AnimationPriority.Idle
	elseif animationName == "Sprint" or animationName == "HurtSprint" then
		track.Priority = Enum.AnimationPriority.Movement
	else
		track.Priority = Enum.AnimationPriority.Action
	end
	
	self:AdjustAnimationSpeed(character, track)
	
	-- Store active animation
	if not self.ActiveAnimations[character] then
		self.ActiveAnimations[character] = {}
	end
	self.ActiveAnimations[character][animationName] = track
end

function AnimationController:LoadCharacterAnimations(character)
	if not self.Enabled then return end
	if not character or not character.Parent then return end
	if not character:FindFirstChild("Humanoid") then return end
	if not character:FindFirstChild("Animations") then return end

	local animationsFolder = character:FindFirstChild("Animations")
	if not animationsFolder then return end

	self:CleanupCharacter(character)

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	
	character:SetAttribute("Animated", true)

	if not animationsFolder:FindFirstChild("Idle") then
		return
	end

	self:PlayAnimation(character, "Idle")

	if animationsFolder:FindFirstChild("PassiveAnimation") then
		self:PlayAnimation(character, "PassiveAnimation")
	end

	if not animationsFolder:FindFirstChild("Walk") then
		return
	end

	local GameAssets = workspace:WaitForChild("GameAssets")
	local Teams = GameAssets.Teams
	local isMoving = false
	local lastStepTime = tick()
	local trailTime = tick()
	local hurtAnimations = animationsFolder:FindFirstChild("HurtAnimations")

	-- Setup connections
	local connections = {}
	if not self.CharacterConnections[character] then
		self.CharacterConnections[character] = {}
	end

	-- Step smoke function
	local function StepSmoke()
		if character:GetAttribute("Undetectable") or not character.PrimaryPart then
			return
		end
		
		local smoke = ReplicatedStorage.Assets.VFX.StepSmoke:Clone()
		smoke.Parent = GameAssets.Debris.Cleanable
		smoke.Transparency = 0.5
		Debris:AddItem(smoke, 0.75)
		
		local offset = Vector3.new(math.random(-10, 10) / 10, character.PrimaryPart.Size.Y, math.random(-10, 10) / 10)
		local pos = character.PrimaryPart.CFrame - offset
		smoke:PivotTo(pos * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90))))
		TweenService:Create(smoke, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
	end

	-- Land smoke function
	local function LandSmoke()
		if character:GetAttribute("Undetectable") or not character.PrimaryPart then
			return
		end
		
		local smoke = ReplicatedStorage.Assets.VFX.StepSmoke:Clone()
		smoke.Parent = GameAssets.Debris.Cleanable
		smoke.Transparency = 0.65
		smoke.Mesh.Scale = Vector3.new(1, 0.7, 1)
		Debris:AddItem(smoke, 0.75)
		
		local pos = character.PrimaryPart.CFrame - Vector3.new(0, 2, 0)
		smoke:PivotTo(pos * CFrame.Angles(0, math.rad(math.random(-90, 90)), 0))
		TweenService:Create(smoke.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Scale = Vector3.new(2.1, 0.4, 2.1)}):Play()
		TweenService:Create(smoke, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
	end

	-- Trail function
	local function Trail(color, duration, transparency)
		local model = Instance.new("Model", GameAssets.Debris.Cleanable)
		
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Shadow" then
				local clone = part:Clone()
				clone:ClearAllChildren()
				clone.Parent = model
				clone.Anchored = true
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CanTouch = false
				clone.Transparency = (transparency or 0.6) * 1.3
				clone.Color = color or Color3.fromRGB(255, 255, 255)
				TweenService:Create(clone, TweenInfo.new(duration or 1), {Transparency = 1}):Play()
			end
		end
		
		Debris:AddItem(model, duration or 1)
	end

	-- Movement animations function
	local function PlayMovementAnims(hurtAnimations)
		local isSprinting = character:GetAttribute("Sprinting")
		local health = humanoid.Health
		local maxHealth = humanoid.MaxHealth
		local isHurt = health <= maxHealth / 2 and hurtAnimations

		if isSprinting then
			if not isHurt then
				self:PlayAnimation(character, "Sprint")
				local tracks = humanoid:GetPlayingAnimationTracks()
				for _, track in pairs(tracks) do
					if track.Name == "HurtSprint" then track:Stop(0.25) end
				end
			else
				self:PlayAnimation(character, "HurtSprint")
				local tracks = humanoid:GetPlayingAnimationTracks()
				for _, track in pairs(tracks) do
					if track.Name == "Sprint" then track:Stop(0.25) end
				end
			end
			
			local tracks = humanoid:GetPlayingAnimationTracks()
			for _, track in pairs(tracks) do
				if track.Name == "Walk" then track:Stop(0.25) end
				if track.Name == "HurtWalk" then track:Stop(0.25) end
			end
			return
		end

		if not isHurt then
			self:PlayAnimation(character, "Walk")
			local tracks = humanoid:GetPlayingAnimationTracks()
			for _, track in pairs(tracks) do
				if track.Name == "HurtWalk" then track:Stop(0.25) end
			end
		else
			self:PlayAnimation(character, "HurtWalk")
			local tracks = humanoid:GetPlayingAnimationTracks()
			for _, track in pairs(tracks) do
				if track.Name == "Walk" then track:Stop(0.25) end
			end
		end
		
		local tracks = humanoid:GetPlayingAnimationTracks()
		for _, track in pairs(tracks) do
			if track.Name == "Sprint" then track:Stop(0.25) end
			if track.Name == "HurtSprint" then track:Stop(0.25) end
		end
	end

	-- Idle animations function
	local function PlayIdleAnims()
		local tracks = humanoid:GetPlayingAnimationTracks()
		for _, track in pairs(tracks) do
			if track.Name == "Walk" then track:Stop(0.25) end
			if track.Name == "Sprint" then track:Stop(0.25) end
			if track.Name == "HurtWalk" then track:Stop(0.25) end
			if track.Name == "HurtSprint" then track:Stop(0.25) end
		end

		local health = humanoid.Health
		local maxHealth = humanoid.MaxHealth
		local isHurt = health <= maxHealth / 2 and hurtAnimations

		if not isHurt then
			self:PlayAnimation(character, "Idle")
		else
			self:PlayAnimation(character, "HurtIdle")
		end
	end

	-- Running connection
	local runningConnection = humanoid.Running:Connect(function(speed)
		isMoving = speed > 0.5
		
		if character:GetAttribute("Trail") and tick() - trailTime >= 0.1 then
			local duration = character:IsDescendantOf(Teams.Other) and 0.75 or 2
			local transparency = character:IsDescendantOf(Teams.Other) and 0.85 or 0.6
			local color = character.PrimaryPart.Color
			
			if character:GetAttribute("KillerName") == "Badware" then
				color = Color3.fromRGB(146, 212, 70)
				transparency = 0.8
			end
			
			trailTime = tick()
			Trail(color, duration, transparency)
		end

		if isMoving and not character.PrimaryPart.Anchored then
			if tick() - lastStepTime >= 0.15 then
				if character:GetAttribute("Sprinting") then
					StepSmoke()
				end
				lastStepTime = tick()
			end
			
			PlayMovementAnims(hurtAnimations)
		else
			PlayIdleAnims()
		end
	end)
	table.insert(self.CharacterConnections[character], runningConnection)

	-- Jump animation connection
	if animationsFolder:FindFirstChild("Jump") then
		local stateConnection = humanoid.StateChanged:Connect(function(oldState, newState)
			if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
				if newState == Enum.HumanoidStateType.Jumping then
					if character.PrimaryPart:FindFirstChild("Jump") then
						character.PrimaryPart.Jump:Play()
						character.PrimaryPart.Jump.PlaybackSpeed = 1 + math.random(-100, 100) / 1000
					end
				end
				
				self:PlayAnimation(character, "Jump", false, 0.1)
			else
				local tracks = humanoid:GetPlayingAnimationTracks()
				for _, track in pairs(tracks) do
					if track.Name == "Jump" then
						track:Stop(0.05)
					end
				end
				
				if not character:IsDescendantOf(Teams) then
					self:PlayAnimation(character, "Land", false, 0)
				end
				
				LandSmoke()
			end
		end)
		table.insert(self.CharacterConnections[character], stateConnection)
	end

	-- Store animator reference
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		self.CharacterAnimators[character] = animator
	end
end

function AnimationController:SetupDefaultCharacter(character)
	if not self.Enabled then return end
	if not character or not character.Parent then return end
	if not character:FindFirstChild("Humanoid") then return end

	local civilian = ReplicatedStorage:FindFirstChild("Characters") and 
					ReplicatedStorage.Characters.Survivor:FindFirstChild("Civilian")
	local defaultAnimations = civilian and civilian:FindFirstChild("Animations")

	if defaultAnimations then
		local existingAnimations = character:FindFirstChild("Animations")
		if existingAnimations then
			existingAnimations:Destroy()
		end

		local newAnimations = defaultAnimations:Clone()
		newAnimations.Parent = character

		if character:FindFirstChild("HumanoidRootPart") then
			character.PrimaryPart = character:WaitForChild("HumanoidRootPart")
		end

		self:LoadCharacterAnimations(character)
		character:SetAttribute("WalkSpeed", 10)
		character:SetAttribute("SprintSpeed", 26)
	end
end

-- Initialize
AnimationController.Enabled = workspace:GetAttribute("AnimationsEnabled")

local localPlayer = Players.LocalPlayer

localPlayer.CharacterAdded:Connect(function(character)
	task.wait(1)
	if AnimationController.Enabled then
		if character:FindFirstChild("Animations") then
			AnimationController:LoadCharacterAnimations(character)
		else
			AnimationController:SetupDefaultCharacter(character)
		end
	end
end)

localPlayer.CharacterRemoving:Connect(function(character)
	AnimationController:CleanupCharacter(character)
end)

task.spawn(function()
	if AnimationController.Enabled and localPlayer.Character then
		AnimationController:SetupDefaultCharacter(localPlayer.Character)
	end
end)

-- NPC handling
local GameAssets = workspace:WaitForChild("GameAssets")
local Teams = GameAssets:WaitForChild("Teams")
local otherTeam = Teams:WaitForChild("Other")
local survivorTeam = Teams:WaitForChild("Survivor")
local killerTeam = Teams:WaitForChild("Killer")

local function SetupCharacter(character)
	if not AnimationController.Enabled then return end
	if not character:FindFirstChild("Humanoid") then return end
	if not character:FindFirstChild("Animations") then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		AnimationController:LoadCharacterAnimations(character)
	end
end

otherTeam.ChildAdded:Connect(SetupCharacter)
survivorTeam.ChildAdded:Connect(SetupCharacter)
killerTeam.ChildAdded:Connect(SetupCharacter)

-- Clean up when NPCs are removed
local function CleanupCharacter(character)
	AnimationController:CleanupCharacter(character)
end

otherTeam.ChildRemoved:Connect(CleanupCharacter)
survivorTeam.ChildRemoved:Connect(CleanupCharacter)
killerTeam.ChildRemoved:Connect(CleanupCharacter)

-- Periodic cleanup
RunService.Heartbeat:Connect(function()
	for character, _ in pairs(AnimationController.CharacterAnimators) do
		if not character or not character.Parent or not character:IsDescendantOf(workspace) then
			AnimationController:CleanupCharacter(character)
		end
	end
end)

-- Initialize existing NPCs
task.spawn(function()
	for _, character in pairs(otherTeam:GetChildren()) do
		SetupCharacter(character)
	end
	for _, character in pairs(survivorTeam:GetChildren()) do
		SetupCharacter(character)
	end
	for _, character in pairs(killerTeam:GetChildren()) do
		SetupCharacter(character)
	end
end)
]]
if workspace:GetAttribute("AnimationsEnabled") == nil and LocalPlayer.PlayerScripts.Character:FindFirstChild("ClientAnimations") and Humanoid then
    local SavedHum = Humanoid
    repeat task.wait(.05) until Humanoid~=SavedHum or (Humanoid and Humanoid.Health<1)
	LocalPlayer.PlayerScripts.Character.ClientAnimations:Destroy()
	task.wait()
	loadstring(AnimationsModule)()
end
end)

local function ReturnAnimFolder()
if Character:FindFirstChild("Animations") then
return Character:WaitForChild("Animations")
end
return nil
end
local Animations = Window:CreateTab("Animations",0)
function SetRunAnim(run)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("HurtSprint") then
AnimationFolder:FindFirstChild("HurtSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("NormalSprint") then
AnimationFolder:FindFirstChild("NormalSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldSprint") then
AnimationFolder:FindFirstChild("OldSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("Sprint") then
AnimationFolder:FindFirstChild("Sprint").AnimationId = run
end
end)
end
function SetWalkAnim(walk)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("Walk") then
AnimationFolder:FindFirstChild("Walk").AnimationId = walk
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldWalk") then
AnimationFolder:FindFirstChild("OldWalk").AnimationId = walk
end
end)
end
function SetIdleAnim(idle)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("Idle") then
AnimationFolder:FindFirstChild("Idle").AnimationId = idle
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldIdle") then
AnimationFolder:FindFirstChild("OldIdle").AnimationId = idle
end
end)
end
function ApplyNewAnimations()
pcall(function()
workspace:SetAttribute("AnimationsEnabled", false)
task.wait()
workspace:SetAttribute("AnimationsEnabled", true)
end)
end
task.wait()

Animations:CreateSection("Pre-loaded animations")
Animations:CreateLabel("Civilian animations")
Animations:CreateButton({Name = "Apply New Civilian Animations"; Callback = function()
local RunAnim = "rbxassetid://137375023685630"
local WalkAnim = "rbxassetid://84388941697203"
local IdleAnim = "rbxassetid://100930402371608"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateButton({Name = "Apply Old Civilian animations"; Callback = function()
local RunAnim = "rbxassetid://79488319304371"
local WalkAnim = "rbxassetid://138161225743614"
local IdleAnim = "rbxassetid://74309548749074"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateLabel("Ghost Animations")
Animations:CreateButton({Name = "Apply Ghost animations"; Callback = function()
local RunAnim = "rbxassetid://124260679864309"
local WalkAnim = "rbxassetid://124260679864309"
local IdleAnim = "rbxassetid://110395159339100"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateSection("Auto-loaded animations")
pcall(function()
for i,v in pairs(game:GetService("ReplicatedStorage").ClientModules.Characters:GetChildren()) do if v.Name=="Civilian" or v.Name=="Ghost" then continue elseif v then
Animations:CreateLabel(v.Name.." Animations")
local temp_table = {}
for _,e in pairs(v.Skins:GetChildren()) do if e and e:FindFirstChildWhichIsA("Model") and e:FindFirstChildWhichIsA("Model"):FindFirstChild("Animations") then
table.insert(temp_table, e:FindFirstChildWhichIsA("Model").Name)
end; end
local Hi = v:WaitForChild("Default")
Animations:CreateDropdown({Name = "Choose "..v.Name.." animations"; Options = temp_table; CurrentOption = "Default"; MultiSelection = false; Callback = function(Value)
Hi = v.Skins:WaitForChild(Rayfield:GetDropdownValue(Value)):WaitForChild(Rayfield:GetDropdownValue(Value))
end; })
Animations:CreateButton({Name = "Apply "..v.Name.." animations"; Callback = function()
local RunAnim = Hi:WaitForChild("Animations"):WaitForChild("Sprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldSprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("NormalSprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("HurtSprint").AnimationId
local WalkAnim = Hi:WaitForChild("Animations"):WaitForChild("Walk").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldWalk").AnimationId
local IdleAnim = Hi:WaitForChild("Animations"):WaitForChild("Idle").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldIdle").AnimationId
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
end; end
end)

Window:CreateTabSection("Visual")

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FOLDER_NAME = "DOD_ESP_HANDLER"
local TEAM_PATHS = {
    Lobby = Workspace:WaitForChild("GameAssets"):WaitForChild("Other"):WaitForChild("LobbyPlayers", 5),
    Ghost = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost", 5),
    Killer = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer", 5),
    Survivor = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor", 5)
}

local TEAM_COLORS = {
    Lobby = Color3.fromRGB(255, 255, 255),
    Ghost = Color3.fromRGB(255, 255, 255),
    Killer = Color3.fromRGB(255, 0, 0),
    Survivor = Color3.fromRGB(0, 255, 0),
    Unknown = Color3.fromRGB(128, 128, 128)
}

_G.ESP_Settings = _G.ESP_Settings or {
    Enabled = false,
    Transparency = 0.3,
    ShowName = true,
    ShowHealth = true,
    ShowStamina = true
}

local function safeWaitForChild(parent, name, timeout)
    timeout = timeout or 3
    local startTime = tick()
    local child = parent:FindFirstChild(name)
    
    while not child and tick() - startTime < timeout do
        task.wait(0.1)
        child = parent:FindFirstChild(name)
    end
    
    return child
end

local function GetESPFolder()
    local folder = CoreGui:FindFirstChild(FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = FOLDER_NAME
        folder.Parent = CoreGui
    end
    return folder
end

local function GetPlayerTeamColor(character)
    if not character or not character.Parent then 
        return TEAM_COLORS.Unknown 
    end
    
    local success, result = pcall(function()
        for teamName, teamPath in pairs(TEAM_PATHS) do
            if teamPath and character:IsDescendantOf(teamPath) then
                return TEAM_COLORS[teamName]
            end
        end
        return TEAM_COLORS.Unknown
    end)
    
    return success and result or TEAM_COLORS.Unknown
end

local function CreateESP(player)
    if not player or not player:IsA("Player") then return end
    
    local success, err = pcall(function()
        local espFolder = GetESPFolder()
        local folderName = "ESP_" .. player.UserId
        
        local existing = espFolder:FindFirstChild(folderName)
        if existing then
            local oldConnections = existing:GetAttribute("Connections")
            if oldConnections then
                for _, conn in ipairs(oldConnections) do
                    if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                        conn:Disconnect()
                    end
                end
            end
            existing:Destroy()
        end
        
        local playerFolder = Instance.new("Folder")
        playerFolder.Name = folderName
        playerFolder.Parent = espFolder
        
        local connections = {}
        local isDestroyed = false
        
        local function disconnectAll()
            for _, conn in ipairs(connections) do
                if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                    conn:Disconnect()
                end
            end
            connections = {}
        end
        
        local function cleanup()
            if isDestroyed then return end
            isDestroyed = true
            
            disconnectAll()
            
            if playerFolder and playerFolder.Parent then
                playerFolder:Destroy()
            end
        end
        
        local folderRemoving = playerFolder.AncestryChanged:Connect(function(_, parent)
            if not parent then
                isDestroyed = true
                disconnectAll()
            end
        end)
        table.insert(connections, folderRemoving)
        
        local function setupESPOnCharacter(character)
            if isDestroyed or not playerFolder.Parent then return end

            pcall(function()
                if playerFolder then
                    for _, child in ipairs(playerFolder:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end)
            
            if not character or not character.Parent then return end
            
            local humanoid = safeWaitForChild(character, "Humanoid", 5)
            local rootPart = safeWaitForChild(character, "HumanoidRootPart", 5)
            
            if not humanoid or not rootPart then 
                task.wait(0.5)
                humanoid = character:FindFirstChildOfClass("Humanoid")
                rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if not humanoid or not rootPart then
                    warn("Failed to find Humanoid/RootPart for " .. player.Name)
                    return
                end
            end

            local highlightParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            local highlights = {}
            
            local function getPartHighlight(partName)
                local part = character:FindFirstChild(partName)
                if not part or not part:IsA("BasePart") then return nil end
                
                if isDestroyed or not playerFolder.Parent then return nil end
                
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = partName
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 1
                highlight.Size = part.Size
                highlight.Transparency = _G.ESP_Settings.Transparency
                highlight.Color3 = GetPlayerTeamColor(character)
                highlight.Parent = playerFolder
                
                local partAncestry
                partAncestry = part.AncestryChanged:Connect(function(_, parent)
                    if not parent and highlight and highlight.Parent then
                        highlight:Destroy()
                    end
                    if partAncestry and partAncestry.Connected then
                        partAncestry:Disconnect()
                    end
                end)
                table.insert(connections, partAncestry)
                
                return highlight
            end
            
            for _, partName in ipairs(highlightParts) do
                local highlight = getPartHighlight(partName)
                if highlight then
                    table.insert(highlights, highlight)
                end
            end
            
            local head = character:FindFirstChild("Head")
            if head and not isDestroyed and playerFolder.Parent then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "NameTag"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 100, 0, 60)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = playerFolder
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.SourceSansSemibold
                textLabel.TextSize = 14
                textLabel.Parent = billboard
                
                local headAncestry
                headAncestry = head.AncestryChanged:Connect(function(_, parent)
                    if not parent and billboard and billboard.Parent then
                        billboard:Destroy()
                    end
                    if headAncestry and headAncestry.Connected then
                        headAncestry:Disconnect()
                    end
                end)
                table.insert(connections, headAncestry)

                local updateConnection
                updateConnection = RunService.Heartbeat:Connect(function()
                    if isDestroyed then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    
                    if not playerFolder.Parent then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    
                    if not _G.ESP_Settings.Enabled then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    
                    pcall(function()
                        local info = {}

                        if _G.ESP_Settings.ShowName then
                            table.insert(info, player.Name)
                        end

                        if _G.ESP_Settings.ShowHealth and humanoid and humanoid.Parent then
                            table.insert(info, "HP: " .. math.floor(humanoid.Health))
                        elseif not humanoid or not humanoid.Parent then
                            local newHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                            if newHumanoid then
                                humanoid = newHumanoid
                            end
                        end

                        if _G.ESP_Settings.ShowStamina and character and character.Parent then
                            local stamina = character:GetAttribute("StaminaServer")
                            if stamina ~= nil then
                                table.insert(info, "SP: " .. tostring(math.floor(stamina)))
                            end
                        end
                        
                        if textLabel and textLabel.Parent then
                            textLabel.Text = table.concat(info, "\n")
                        end

                        if character and character.Parent then
                            local currentColor = GetPlayerTeamColor(character)
                            for _, highlight in ipairs(highlights) do
                                if highlight and highlight.Parent then
                                    highlight.Color3 = currentColor
                                end
                            end
                        end
                    end)
                end)
                
                table.insert(connections, updateConnection)
            end
        end
        
        if player.Character then
            setupESPOnCharacter(player.Character)
        end
        local characterAdded = player.CharacterAdded:Connect(function(character)
            if isDestroyed then return end
            task.wait(0.2)
            local attempts = 0
            local maxAttempts = 3
            while attempts < maxAttempts and not isDestroyed do
                if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
                    setupESPOnCharacter(character)
                    break
                end
                attempts = attempts + 1
                task.wait(0.5)
            end
        end)
        table.insert(connections, characterAdded)
        local characterRemoving = player.CharacterRemoving:Connect(function()
            if isDestroyed then return end
            pcall(function()
                if playerFolder then
                    for _, child in ipairs(playerFolder:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end)
        end)
        table.insert(connections, characterRemoving)
        local playerLeaving
        playerLeaving = player.AncestryChanged:Connect(function(_, parent)
            if not parent then
                cleanup()
                if playerLeaving and playerLeaving.Connected then
                    playerLeaving:Disconnect()
                end
            end
        end)
        table.insert(connections, playerLeaving)
        playerFolder:SetAttribute("Connections", connections)
    end)
    if not success then end
end

local function RemoveESP(player)
    pcall(function()
        local espFolder = GetESPFolder()
        local playerFolder = espFolder:FindFirstChild("ESP_" .. player.UserId)
        
        if playerFolder then
            local connections = playerFolder:GetAttribute("Connections")
            if connections then
                for _, conn in ipairs(connections) do
                    if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                        conn:Disconnect()
                    end
                end
            end
            playerFolder:Destroy()
        end
    end)
end

local function ClearAllESP()
    pcall(function()
        local espFolder = GetESPFolder()
        for _, folder in ipairs(espFolder:GetChildren()) do
            if folder:IsA("Folder") then
                local connections = folder:GetAttribute("Connections")
                if connections then
                    for _, conn in ipairs(connections) do
                        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                            conn:Disconnect()
                        end
                    end
                end
                folder:Destroy()
            end
        end
    end)
end

local mainConnections = {}

local function EnableESP()
    _G.ESP_Settings.Enabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            task.spawn(function()
                CreateESP(player)
            end)
        end
    end
    
    mainConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            task.spawn(function()
                task.wait(0.5)
                CreateESP(player)
            end)
        end
    end)
    
    mainConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    mainConnections.folderMonitor = GetESPFolder().AncestryChanged:Connect(function(_, parent)
        if not parent and _G.ESP_Settings.Enabled then
            task.wait(0.1)
            local newFolder = Instance.new("Folder")
            newFolder.Name = FOLDER_NAME
            newFolder.Parent = CoreGui
            
            mainConnections.folderMonitor = newFolder.AncestryChanged:Connect(function(_, p)
                if not p and _G.ESP_Settings.Enabled then
                    EnableESP()
                end
            end)
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    task.spawn(function()
                        CreateESP(player)
                    end)
                end
            end
        end
    end)
end

local function DisableESP()
    _G.ESP_Settings.Enabled = false
    
    for _, conn in pairs(mainConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    mainConnections = {}
    
    ClearAllESP()
end

local FESP = {}

function FESP.Toggle(enabled)
    if enabled then
        EnableESP()
    else
        DisableESP()
    end
end

function FESP.SetTransparency(value)
    _G.ESP_Settings.Transparency = math.clamp(value, 0, 1)
    pcall(function()
        local espFolder = GetESPFolder()
        for _, folder in ipairs(espFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, adornment in ipairs(folder:GetChildren()) do
                    if adornment:IsA("BoxHandleAdornment") then
                        adornment.Transparency = _G.ESP_Settings.Transparency
                    end
                end
            end
        end
    end)
end

local ESP = Window:CreateTab("ESP",0)

ESP:CreateToggle({Name = "ESP Enabled?"; CurrentValue = false; Callback = function(Value)
FESP.Toggle(Value)
end; })
ESP:CreateSlider({Name = "ESP Transparency"; Range = {0, 100}; Increment = 1; Suffix = "%"; CurrentValue = 30; Callback = function(Value)
FESP.SetTransparency(Value / 100)
end; })
ESP:CreateToggle({Name = "Show Username"; CurrentValue = false; Callback = function(Value)
_G.ESP_Settings.ShowName = Value
end; })
ESP:CreateToggle({Name = "Show Health"; CurrentValue = false; Callback = function(Value)
_G.ESP_Settings.ShowHealth = Value
end; })
ESP:CreateToggle({Name = "Show Stamina"; CurrentValue = false; Callback = function(Value)
_G.ESP_Settings.ShowStamina = Value
end; })

Window:CreateTabSection("Other")

local Other = Window:CreateTab("Other",0)

Other:CreateButton({Name = "Get All Client Achievements ( FE )"; Callback = function()
local Achievements = {"I'm Very Hungry!";"Violent Golf";"Laundry List";"I'm Your Biggest Fan";"Lifesaver";"Studious Scholar";"Best of Both Worlds";"Karma Called";"Sight Slaying";"Measuring Minutes";"I'm Just Saiyan'";"Here Lies: You";"Stealing The Spotlight";"Bloodshed";"Double Or Nothing";"Counting Seconds";"Golf Enthusiast";"Survivor's Guilt";"Fear And Hunger";"High Noon";"Big Spender";"Hot Stuff";"Born Again";"Biggest Threat In The Room";"Humble Beginnings";"Never-Ending Shift";"The First Of Many";"Little Spender";"Still Standing";"Sizable Wallet";"Live And Let Die.";"Another Mark On The Tally";"Vivid Recollection";"[MISSION SUCCESS]";"Les Misérables";"[SYSTEM_PURGE]";"Thrill Of the Hunt";"Participation Trophy";"The Best Defense...";"Meet The Sniper";"Give Em' Hell!";"Teetering On The Edge Of Life";"Every DoD Youtuber Be Like:";"Deep Dive";"Die Of Death Any% WR";"Tis But A Scratch";"Mulligan";"Albatross";"Combat Medic";"Spec-Tater";"Lucid Nightmare";"Slaughterhouse";"3-POINTER";"Born, Again?";"For Those We Lost Along The Way";"I'm Not Afraid Of You Anymore!";"Two Birds, One Stone!";"Help Wanted";"Luck of the Draw";"Mann Vs Machine";"Don't Call It A Comeback!";"Water Baby";"My spine hurts every night";"KABOOOM!"}
for i,v in pairs(Achievements) do
game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("RemoteEvents", 9e9):WaitForChild("Achievement", 9e9):FireServer(v)
end
end; })
Other:CreateButton({Name = "Close Hub"; Callback = function()
Rayfield:Destroy()
end; })

task.spawn(function()
    while true do
        if getGlobal and getGlobal("IndraHubDieOfDeathSession") == SessionId then
            setGlobal("IndraHubDieOfDeathLastHeartbeat", os.clock())
        else
            break
        end
        task.wait(5)
    end
end)
