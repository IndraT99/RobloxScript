
local env = getgenv and getgenv() or _G
env.IndraHubMVSRunning = true
task.spawn(function()
    while env.IndraHubMVSRunning do
        env.IndraHubMVSLastHeartbeat = os.clock()
        task.wait(1)
    end
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub  |  [DUELS] Murderers VS Sheriffs",
    Icon = "solar:folder-2-bold-duotone",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
})

local GunTab = Window:Tab({
    Title = "Gun",
    Icon = "solar:target-bold",
})

local Tab3 = Window:Tab({
    Title = "UI Settings",
    Icon = "solar:paint-bold",
})

GunTab:Section({ Title = "🔫  Only Gun" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")
local mouse = LocalPlayer:GetMouse()

do
local running = false
local MAX_DISTANCE = 150
local function inMatch()
    return LocalPlayer:GetAttribute("Map") ~= nil
end
local function getGunTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("showBeam") then
            local showBeam = tool.showBeam
            if showBeam:IsA("RemoteEvent") then
                return tool
            end
        end
    end
    return nil
end
local function equipGun()
    if not inMatch() then
        return
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end
    local tool = getGunTool()
    if tool then
        humanoid:EquipTool(tool)
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if running and inMatch() then
        equipGun()
    end
end)
local function setupBackpackWatcher()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    backpack.ChildAdded:Connect(function(child)
        if running and inMatch() and child:IsA("Tool") then
            task.wait(0.1)
            equipGun()
        end
    end)
end
setupBackpackWatcher()
local AKgun = GunTab:Toggle({
    Title = "Auto Kill All Players",
    Default = false,
    Callback = function(state)
        running = state
        if running then
            task.spawn(function()
                while running do
                    task.wait(0.1)
                    if not inMatch() then
                        continue
                    end
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then
                        continue
                    end
                    local equippedTool = character:FindFirstChildOfClass("Tool")
                    if not equippedTool or not equippedTool:FindFirstChild("showBeam") then
                        equipGun()
                    end
                    local myTeam = LocalPlayer:GetAttribute("Team")
                    local closestPlayer = nil
                    local shortestDistance = MAX_DISTANCE
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local playerTeam = player:GetAttribute("Team")
                            if playerTeam ~= myTeam then
                                local enemyCharacter = player.Character
                                local enemyRoot = enemyCharacter and enemyCharacter:FindFirstChild("HumanoidRootPart")
                                if enemyRoot then
                                    local distance = (enemyRoot.Position - rootPart.Position).Magnitude
                                    if distance <= MAX_DISTANCE and distance < shortestDistance then
                                        shortestDistance = distance
                                        closestPlayer = player
                                    end
                                end
                            end
                        end
                    end
                    local tool = character:FindFirstChildOfClass("Tool")
                    if closestPlayer and tool then
                        local killEvent = tool:FindFirstChild("kill")
                        if killEvent and killEvent:IsA("RemoteEvent") then
                            killEvent:FireServer(
                                closestPlayer,
                                Vector3.new(
                                    0.149008110165596,
                                    0.019326409325003624,
                                    0.9886471033096313
                                )
                            )
                        end
                    end
                end
            end)
        end
    end
})
end
do
local enabled = false
local MAX_DISTANCE = 150
local FIRE_DELAY = 0.12
local function getGunTool()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool")
                and tool:FindFirstChild("showBeam")
                and tool:FindFirstChild("kill") then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool")
                and tool:FindFirstChild("showBeam")
                and tool:FindFirstChild("kill") then
                return tool
            end
        end
    end
    return nil
end
local function equipGun()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return nil
    end
    local tool = getGunTool()
    if tool and tool.Parent ~= character then
        humanoid:EquipTool(tool)
        task.wait(0.05)
    end
    return tool
end
local function canSeeTarget(targetCharacter)
    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        return false
    end
    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then
        return false
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        myCharacter,
        targetCharacter
    }
    local result = Workspace:Raycast(
        myRoot.Position,
        targetRoot.Position - myRoot.Position,
        params
    )
    return result == nil
end
local function getClosestPlayerToCursor()
    if not enabled then
        return nil
    end
    if not LocalPlayer:GetAttribute("Map") then
        return nil
    end
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        return nil
    end
    local myTeam = LocalPlayer:GetAttribute("Team")
    local myGame = LocalPlayer:GetAttribute("Game")
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid
                and humanoid.Health > 0
                and root
                and player:GetAttribute("Game") == myGame
                and player:GetAttribute("Team") ~= myTeam then
                local worldDistance =
                    (root.Position - myRoot.Position).Magnitude
                if worldDistance <= MAX_DISTANCE
                    and canSeeTarget(character) then
                    local screenPos, onScreen =
                        Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local cursorDistance =
                            (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if cursorDistance < shortestDistance then
                            shortestDistance = cursorDistance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if enabled
        and not checkcaller()
        and self == mouse
        and key == "Hit" then
        local target = getClosestPlayerToCursor()
        if target then
            local root =
                target.Character
                and target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                return CFrame.new(root.Position)
            end
        end
    end
    return oldIndex(self, key)
end))
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if enabled then
        equipGun()
    end
end)
local backpack = LocalPlayer:WaitForChild("Backpack")
backpack.ChildAdded:Connect(function(child)
    if enabled and child:IsA("Tool") then
        task.wait(0.1)
        equipGun()
    end
end)
task.spawn(function()
    while true do
        task.wait(FIRE_DELAY)
        if not enabled then
            continue
        end
        if not LocalPlayer:GetAttribute("Map") then
            continue
        end
        local target = getClosestPlayerToCursor()
        if target then
            local tool = equipGun()
            if tool and tool.Parent == LocalPlayer.Character then
                tool:Activate()
            end
        end
    end
end)
local AKWVgun = GunTab:Toggle({
    Title = "Auto Shoot When Visible",
    Default = false,
    Callback = function(state)
        enabled = state
        if enabled then
            equipGun()
        end
    end
})
end
do
local MAX_DISTANCE = 150
local enabled = false
local function getClosestPlayerToCursor()
    if not enabled then
        return nil
    end
    if not LocalPlayer:GetAttribute("Map") then
        return nil
    end
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        return nil
    end
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local myTeam = LocalPlayer:GetAttribute("Team")
    local myGame = LocalPlayer:GetAttribute("Game")
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root
            and player:GetAttribute("Game") == myGame
            and player:GetAttribute("Team") ~= myTeam then
                local worldDistance =
                    (root.Position - myRoot.Position).Magnitude
                if worldDistance <= MAX_DISTANCE then
                    local screenPos, onScreen =
                        Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local dist =
                            (
                                Vector2.new(screenPos.X, screenPos.Y)
                                - mousePos
                            ).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if enabled
    and not checkcaller()
    and self == mouse
    and key == "Hit" then
        local target = getClosestPlayerToCursor()
        if target then
            local root =
                target.Character
                and target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                return CFrame.new(root.Position)
            end
        end
    end
    return oldIndex(self, key)
end))
local SAgun = GunTab:Toggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(state)
        enabled = state
    end
})
end

-- ══════════════════════════════════════════════
--  UI SETTINGS TAB
-- ══════════════════════════════════════════════
Tab3:Section({ Title = "Theme" })
Tab3:Dropdown({
    Title = "UI Theme",
    Values = { "Dark", "Light", "Amethyst", "Rose", "Emerald", "Sapphire", "Ruby" },
    Value = "Dark",
    Callback = function(theme)
        if WindUI.SetTheme then
            pcall(function() WindUI:SetTheme(theme) end)
        end
    end,
})
Tab3:Section({ Title = "UI" })
Tab3:Keybind({
    Title = "Toggle UI",
    Key = "P",
    Callback = function()
        if Window.Toggle then
            Window:Toggle()
        end
    end,
})
