-- IndraHub - ERLC Supervisor Compatible
local env = getgenv and getgenv() or _G
rawset(_G, "IndraHubERLCRunning", true)
rawset(_G, "IndraHubERLCLastHeartbeat", os.clock())
rawset(_G, "IndraHubERLCError", nil)
task.spawn(function()
    while rawget(_G, "IndraHubERLCRunning") == true do
        rawset(_G, "IndraHubERLCLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local LocalPlayer = game.Players.LocalPlayer

local function isHandcuffed()
    if LocalPlayer:FindFirstChild("In_Handcuffs") and LocalPlayer.In_Handcuffs.Value ~= LocalPlayer.Name then
        return true
    end
    return false
end

while wait() do
    if isHandcuffed() then
        pcall(function(...)
            game:GetService("ReplicatedStorage").FE.Actions.Environmental:FireServer(100)
            task.defer(function()
                wait(0.1)
                game:GetService("ReplicatedStorage").FE.DeathRespawn:FireServer()
            end)
        end)
    end
end

-- infinite fuel

pcall(function()
    local vehicles = workspace.Vehicles

    local function getLocalCar()
        for _, car in next, vehicles:GetChildren() do
            if car:GetAttribute("Owner") and car:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
                return car
            end
        end
        return nil 
    end

    task.spawn(function()
        while wait(1) do
            pcall(function(...)
                getLocalCar().Control_Values.CurrentFuel.Value = math.huge
            end)
        end
    end)
end)

pcall(function()
    local vehicles = workspace.Vehicles

    local function getLocalCar()
        for _, car in next, vehicles:GetChildren() do
            if car:GetAttribute("Owner") and car:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
                return car
            end
        end
        return nil 
    end

    -- No Car Damage From Poles/etc

    task.spawn(function()
        while wait() do
            pcall(function(...)
                getLocalCar().Body.CollisionPart.CanTouch = false
            end)
        end
    end)

    -- wheel invincibility

    task.spawn(function()
        while wait() do
            pcall(function(...)
                for _, v in next, getLocalCar().Wheels:GetChildren() do
                    v.CanTouch = false
                    v.Transparency = 1
                    v.CanCollide = true
                end
            end)
        end
    end)
end)

-- for high end executors method 1

--[[for _, func in next, getgc() do
    if type(func) == "function" and debug.getinfo(func).name == "sprintInput" then
        game:GetService("RunService").RenderStepped:Connect(function()

            pcall(function()
                debug.setupvalue(func, 6, 100)
            end)
        end)
    end
end--]]

-- works on xeno ( didnt test ) method 2

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function(...)
        game.Players.LocalPlayer.PlayerGui.GameGui.MainHUD.Values.CurrStamina.Value = 100
    end)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    for _, conn in ipairs(getconnections(game:GetService("ScriptContext").Error)) do
        conn:Disable()
    end
end)

local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

local Window
if WindUI then
    pcall(function()
        Window = WindUI:CreateWindow({
            Title = "IndraHub | ERLC Premium",
            Icon = "circle-dot",
            Author = "Vehicle Popper",
            Folder = "IndraHubERLC",
            Size = UDim2.fromOffset(580, 460),
            Transparent = true,
            Theme = "Dark",
            SideBarWidth = 180,
            HasOutline = true
        })
    end)
end

local Tabs = {}
if Window then
    pcall(function()
        Tabs.Main = Window:Tab({Title = "Main", Icon = "car"})
    end)
end

local VehicleDropdown = nil
local currentVehicles = {}
local targetRemote = nil
local hasGotten = false

local function getVehicles()
    local success, result = pcall(function()
        local tbl = {}
        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then return tbl end

        for _, v in next, vehiclesFolder:GetChildren() do
            pcall(function()
                local driverSeat = v:FindFirstChild("DriverSeat")
                if driverSeat then
                    local occupant = driverSeat.Occupant
                    if occupant and occupant.Parent then
                        local player = game.Players:GetPlayerFromCharacter(occupant.Parent)
                        if player then
                            table.insert(tbl, player.Name)
                        end
                    end
                end
            end)
        end
        return tbl
    end)
    
    if success and result then
        currentVehicles = result
        return result
    else
        return {}
    end
end

local function updateDropdown()
    pcall(function()
        local vehicles = getVehicles()
        if VehicleDropdown and VehicleDropdown.Refresh then
            pcall(function()
                VehicleDropdown:Refresh(vehicles)
            end)
        end
    end)
end

local function getVehicleByName(name)
    local success, result = pcall(function()
        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then return nil end

        for _, v in next, vehiclesFolder:GetChildren() do
            local foundVehicle = nil
            pcall(function()
                local driverSeat = v:FindFirstChild("DriverSeat")
                if driverSeat then
                    local occupant = driverSeat.Occupant
                    if occupant and occupant.Parent then
                        local player = game.Players:GetPlayerFromCharacter(occupant.Parent)
                        if player and player.Name == name then
                            foundVehicle = v
                        end
                    end
                end
            end)
            if foundVehicle then return foundVehicle end
        end
        return nil
    end)
    return success and result or nil
end
local hasNotified = false

local function popTiresOnVehicle(vehicle)
    pcall(function()
        if not targetRemote or not vehicle then return end
        task.spawn(function()
            pcall(function()
                local wheels = vehicle:FindFirstChild("Wheels")
                if not wheels then return end
                
                for _, wheel in next, wheels:GetChildren() do
                    pcall(function()
                        if wheel and wheel.CanCollide == true then
                            local targetPart = wheel:FindFirstChild("Base")
                            if targetPart and targetPart:IsA("BasePart") then
                                pcall(function()
                                    local arg = {
                                        Normal = Vector3.new(0,0,-1),
                                        Instance = targetPart,
                                        Position = targetPart.Position
                                    }
                                    
                                    local t3 = {{targetPart, 1}}
                                    
                                    targetRemote:FireServer({
                                        "5.56x45mm",          
                                        Vector3.zero,  
                                        Vector3.zero,
                                        Vector3.new(0,0,0),    
                                        arg,                   
                                        t3                    
                                    })
                                end)

                                task.defer(function()
                                    if not hasNotified then
                                        hasNotified = true
                                        wait(1)
                                        pcall(function()
                                            local FE = game:GetService("ReplicatedStorage").FE
                                            FE.Weapons.ForceReload:Fire()
                                            FE.Weapons.UpdateHUD:Fire()
                                            WindUI:Notify({
                                                Title = "Reload",
                                                Content = "Your weapon is reloading now",
                                                Duration = 2
                                            })
                                            task.defer(function()
                                                wait(5)
                                                WindUI:Notify({
                                                    Title = "Reload",
                                                    Content = "Your weapon should have reloaded",
                                                    Duration = 2
                                                })
                                                hasNotified = false
                                            end)
                                        end)
                                    end
                                end)
                                task.wait(0.15)
                            end
                        end
                    end)
                end
            end)
        end)
    end)
end

if Tabs.Main then
    pcall(function()
        Tabs.Main:Section({Title = "Vehicle Controls"})
    end)

    pcall(function()
        VehicleDropdown = Tabs.Main:Dropdown({
            Name = "Select Vehicle",
            Values = getVehicles(),
            Value = {},
            MultipleValues = false,
            Flag = "VehicleDropdown",
            Callback = function(Options) end,
        })
    end)

    pcall(function()
        Tabs.Main:Button({
            Title = "Refresh Vehicles",
            Callback = function()
                pcall(function()
                    updateDropdown()
                    if WindUI then
                        pcall(function()
                            WindUI:Notify({
                                Title = "Refreshed",
                                Content = "Vehicle list updated!",
                                Duration = 2
                            })
                        end)
                    end
                end)
            end,
        })
    end)

    pcall(function()
        Tabs.Main:Button({
            Title = "Pop All Tyres (Selected)",
            Callback = function()
                pcall(function()
                    local currentOpt = VehicleDropdown and VehicleDropdown.CurrentOption
                    local playerName = type(currentOpt) == "table" and currentOpt[1] or type(currentOpt) == "string" and currentOpt or nil
                    
                    if not playerName or playerName == "" then
                        if WindUI then
                            pcall(function()
                                WindUI:Notify({
                                    Title = "Error",
                                    Content = "No vehicle selected!",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    local vehicle = getVehicleByName(playerName)
                    if not vehicle then
                        if WindUI then
                            pcall(function()
                                WindUI:Notify({
                                    Title = "Error",
                                    Content = "Vehicle not found!",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    if not targetRemote then 
                        if WindUI then
                            pcall(function()
                                WindUI:Notify({
                                    Title = "Remote not retrieved",
                                    Content = "Please spawn a car or shoot once to retrieve the remote.",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    task.spawn(function()
                        pcall(function()
                            popTiresOnVehicle(vehicle)
                        end)
                    end)
                end)
            end,
        })
    end)

    pcall(function()
        Tabs.Main:Button({
            Title = "Pop All Tyres (ALL Vehicles)",
            Callback = function()
                pcall(function()
                    if not targetRemote then 
                        if WindUI then
                            pcall(function()
                                WindUI:Notify({
                                    Title = "Remote not retrieved",
                                    Content = "Please spawn a car or shoot once to retrieve the remote.",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    pcall(function()
                        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
                        if not vehiclesFolder then return end
                        
                        for _, vehicle in next, vehiclesFolder:GetChildren() do
                            pcall(function()
                                popTiresOnVehicle(vehicle)
                            end)
                        end
                    end)
                end)
            end,
        })
    end)
end

task.spawn(function()
    while task.wait(5) do
        pcall(updateDropdown)
    end
end)



pcall(function()
    for _, v in next, getgc(true) do
        pcall(function()
            if type(v) == "table" then
                if rawget(v, "getRemote") then
                    local old
                    old = hookfunction(v.getRemote, function(name)
                        local result
                        pcall(function()
                            result = old(name)
                        end)
                        
                        pcall(function()
                            if not hasGotten then
                                task.defer(function()
                                    pcall(function()
                                        targetRemote = old("Weapons.ReplicateProjectile")
                                        if targetRemote then
                                            hasGotten = true
                                        end
                                    end) 
                                end)
                            end
                        end)
                        return result
                    end)
                end
            end
        end)
    end
end)

task.spawn(function()
    while not targetRemote do 
        task.wait(0.5) 
    end
    if WindUI then
        pcall(function()
            WindUI:Notify({
                Title = "Remote retrieved!",
                Content = "Hold a gun and press Pop All Tyres to pop tires!",
                Duration = 3
            })
        end)
    end
end)

local vehicles = workspace.Vehicles

local function getLocalCar()
    for _, car in next, vehicles:GetChildren() do
        if car:GetAttribute("Owner") and car:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
            return car
        end
    end
    return nil 
end

local carinfo = {}

local function saveCarStat(car, stat, value)
    if not carinfo[car] then
        carinfo[car] = {}
    end
    
    if carinfo[car][stat] == nil then
        carinfo[car][stat] = value
    end
end

local function setCarStat(stat, value)
    local currentCar = getLocalCar()
    if not currentCar then
        return
    end
    
    local info = require(currentCar["Drive Controller"])
    if not info then
        return
    end
    
    saveCarStat(currentCar, "Horsepower", info.Horsepower)
    saveCarStat(currentCar, "PeakRPM", info.PeakRPM)
    saveCarStat(currentCar, "PeakSharpness", info.PeakSharpness)
    saveCarStat(currentCar, "FinalDrive", info.FinalDrive)
    saveCarStat(currentCar, "Ratios", info.Ratios)
    saveCarStat(currentCar, "Redline", info.Redline)
    saveCarStat(currentCar, "EqPoint", info.EqPoint)
    
    info[stat] = value
end

local function ResetCarStat(car, stat)
    if not car or not carinfo[car] or carinfo[car][stat] == nil then
        warn("No saved value to reset for " .. stat)
        return
    end
    
    local info = require(car["Drive Controller"])
    if info then
        info[stat] = carinfo[car][stat]
    end
end

local function ResetAllCarStats()
    local currentCar = getLocalCar()
    if not currentCar then
        return
    end
    
    if not carinfo[currentCar] then
        return
    end
    
    local stats = {"Horsepower", "PeakRPM", "PeakSharpness", "FinalDrive", "Ratios", "Redline", "EqPoint", "BrakeForce", "PBrakeForce", "BrakeBias", "BrakeAccel"}
    for _, stat in ipairs(stats) do
        ResetCarStat(currentCar, stat)
    end
end

setCarStat("Horsepower", 9999)
setCarStat("PeakRPM", 10000)
setCarStat("PeakSharpness", 999)
setCarStat("FinalDrive", 1)
setCarStat("Ratios", {0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03})
setCarStat("Redline", 25000)
setCarStat("EqPoint", 15000)

for index, value in next, getgc(true) do
    if type(value) == "function" then
        if debug.getinfo(value).name == "accelerate" then
            hookfunction(value, function()
                return
            end)
        end
    end
end

local target = nil 

local function isVisible(part, origin)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {game.Players.LocalPlayer}
	params.IgnoreWater = true
	
	local ray = workspace:Raycast(origin.Position, (part.Position - origin.Position), params)
	
	if ray then
		local char = ray.Instance:FindFirstAncestorWhichIsA("Model")
		if game.Players:GetPlayerFromCharacter(char) then	
			return true
		else
			return false
		end
	else
		return false
	end
end

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = workspace.CurrentCamera

    for _, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then continue end


        --local team = v.Team and v.Team.Name 
       -- if team and team ~= "Police" or team and team ~= "Sheriff" then continue end
        local char = v.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        --if not isVisible(hrp, camera.CFrame) then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closest = hrp
            end
        end
    end

    return closest
end

for _, func in next, getgc() do
    if type(func) == "function" then
        if debug.getinfo(func).name == "addProjectile" and debug.getinfo(func).name ~= "addProjectileVisual"  then
            local old
            old = hookfunction(func, function(p1,p2,p3,p4,p5,p6,p7)
                if p6 == nil then
                    if target then
                        p5 = {
                            Normal = Vector3.new(0,0,-1),
                            Instance = target,
                            Position = target.Position
                        }
                    end
                end
                return old(p1,p2,p3,p4,p5,p6,p7)
            end)
        end
    end
end
