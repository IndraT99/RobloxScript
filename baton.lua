local Env = (getgenv and getgenv()) or _G
rawset(Env, "IndraHubBatonRunning", true)
rawset(Env, "IndraHubBatonLastHeartbeat", os.clock())
rawset(Env, "IndraHubBatonError", nil)
task.spawn(function()
    while rawget(Env, "IndraHubBatonRunning") == true do
        rawset(Env, "IndraHubBatonLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        if cloneref(game:GetService("RunService")):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

local Window = WindUI:CreateWindow({
    Title = "IndraHub Baton Rouge",
    Folder = "IndraHub/BatonRouge",
    Icon = "solar:cpu-bolt-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "IndraHub Baton",
        CornerRadius = UDim.new((6*0+1), (4624+-4624)),
        StrokeThickness = (6*0+2),
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#FF4500"),
            Color3.fromHex("#FF8C00")
        ),
    },
    Topbar = {
        Height = bit32.bxor(40795,40823),
        ButtonsType = "Default",
    },
})

Window:Tag({
    Title = "v1.0",
    Icon = "star",
    Color = Color3.fromHex("#FF4500"),
    Border = true,
})

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local autoFarmTrashRunning = false
local autoFarmPopEyesRunning = false
local infStaminaConn = nil
local antiJumpCooldownConn = nil
local speedBoostConn = nil
local currentSpeed = (23*1+12)
local defaultGravity = workspace.Gravity

local espEnabled = {
    Box = false,
    CornerBox = false,
    Skeleton = false,
    Chams = false,
    Name = false,
    Distance = false,
    Weapon = false,
    Backpack = false,
}

local espObjects = {}

local SKELETON_JOINTS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
}

local function newLine(color, thickness)
    local d = Drawing.new("Line")
    d.Color = color
    d.Thickness = thickness or (4896-4895)
    d.Transparency = (-220-307+528)
    d.Visible = false
    return d
end

local function newText(color, size)
    local d = Drawing.new("Text")
    d.Color = color
    d.Size = size or (4120+-4106)
    d.Center = true
    d.Outline = true
    d.OutlineColor = Color3.fromRGB((379-773+394), (1-1), (1479-1479))
    d.Visible = false
    d.Text = ""
    return d
end

local function createPlayerESP(player)
    if player == lp then return end
    local data = {}
    data.box = {}
    for i = (31*0+1), bit32.bxor(44772,44768) do data.box[i] = newLine(Color3.fromRGB((47*5+20), bit32.bxor(7541,7495), bit32.bxor(37817,37771)), bit32.bxor(63356,63357)) end
    data.cornerBox = {}
    for i = (6522-6521), bit32.bxor(55334,55342) do data.cornerBox[i] = newLine(Color3.fromRGB((4340+-4290), bit32.bxor(9681,9518), bit32.bxor(64414,64428)), (9265+-9263)) end
    data.skeleton = {}
    for i = (336-515+180), #SKELETON_JOINTS do data.skeleton[i] = newLine(Color3.fromRGB((26*9+21), (8423-8168), (6582+-6327)), (32*0+1)) end
    data.highlight = nil
    data.nameLabel = newText(Color3.fromRGB((9977+-9722), bit32.bxor(51293,51362), bit32.bxor(34869,35018)), (9145-9131))
    data.distLabel = newText(Color3.fromRGB((18*14+3), (486-343+77), (5477-5427)), (5366+-5353))
    data.weaponLabel = newText(Color3.fromRGB((698-817+374), bit32.bxor(38959,39050), (7410-7410)), (41*0+13))
    data.backpackLabel = newText(Color3.fromRGB((7285+-7185), bit32.bxor(64065,64137), (301-509+463)), (594+-582))
    espObjects[player] = data
end

local function removePlayerESP(player)
    local data = espObjects[player]
    if not data then return end
    for _, l in ipairs(data.box) do l:Remove() end
    for _, l in ipairs(data.cornerBox) do l:Remove() end
    for _, l in ipairs(data.skeleton) do l:Remove() end
    if data.highlight then data.highlight:Destroy() end
    data.nameLabel:Remove()
    data.distLabel:Remove()
    data.weaponLabel:Remove()
    data.backpackLabel:Remove()
    espObjects[player] = nil
end

local function getCharBounds(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil end
    local topPos, topOn = Camera:WorldToViewportPoint(head.Position + Vector3.new((4099-4099), 0.7, (27-27)))
    local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(bit32.bxor(57817,57817), bit32.bxor(46026,46025), (31-31)))
    if not topOn and not botOn then return nil end
    if topPos.Z < (8176+-8176) then return nil end
    local top = Vector2.new(topPos.X, topPos.Y)
    local bot = Vector2.new(botPos.X, botPos.Y)
    local height = bot.Y - top.Y
    local width = height * 0.5
    local cx = (top.X + bot.X) / (2606+-2604)
    return {
        tl = Vector2.new(cx - width / (4271+-4269), top.Y),
        tr = Vector2.new(cx + width / (2087-2085), top.Y),
        bl = Vector2.new(cx - width / bit32.bxor(36845,36847), bot.Y),
        br = Vector2.new(cx + width / (3524-3522), bot.Y),
        cx = cx,
        topY = top.Y,
        botY = bot.Y,
        width = width,
        height = height,
    }
end

local function hideAll(data)
    for _, l in ipairs(data.box) do l.Visible = false end
    for _, l in ipairs(data.cornerBox) do l.Visible = false end
    for _, l in ipairs(data.skeleton) do l.Visible = false end
    data.nameLabel.Visible = false
    data.distLabel.Visible = false
    data.weaponLabel.Visible = false
    data.backpackLabel.Visible = false
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local data = espObjects[player]
        if not data then continue end
        local char = player.Character
        if not char then hideAll(data) continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then hideAll(data) continue end
        local b = getCharBounds(char)
        if not b then hideAll(data) continue end

        if espEnabled.Box then
            data.box[(187-210+24)].From = b.tl data.box[(-500-159+660)].To = b.tr data.box[(-155-13+169)].Visible = true
            data.box[(1792-1790)].From = b.tr data.box[(3078+-3076)].To = b.br data.box[bit32.bxor(20189,20191)].Visible = true
            data.box[(1516+-1513)].From = b.br data.box[(988+-985)].To = b.bl data.box[(4745+-4742)].Visible = true
            data.box[(-288-88+380)].From = b.bl data.box[(25*0+4)].To = b.tl data.box[bit32.bxor(51133,51129)].Visible = true
        else
            for _, l in ipairs(data.box) do l.Visible = false end
        end

        if espEnabled.CornerBox then
            local cw = b.width * 0.28
            local ch = b.height * 0.22
            data.cornerBox[bit32.bxor(47085,47084)].From = b.tl data.cornerBox[(16*0+1)].To = b.tl + Vector2.new(cw, (3345-3345)) data.cornerBox[(28*0+1)].Visible = true
            data.cornerBox[(19*0+2)].From = b.tl data.cornerBox[bit32.bxor(8175,8173)].To = b.tl + Vector2.new((219-219), ch) data.cornerBox[bit32.bxor(44807,44805)].Visible = true
            data.cornerBox[(5012+-5009)].From = b.tr data.cornerBox[bit32.bxor(61621,61622)].To = b.tr + Vector2.new(-cw, bit32.bxor(29382,29382)) data.cornerBox[(9450-9447)].Visible = true
            data.cornerBox[(8300-8296)].From = b.tr data.cornerBox[(5343-5339)].To = b.tr + Vector2.new((-279-201+480), ch) data.cornerBox[bit32.bxor(65061,65057)].Visible = true
            data.cornerBox[(6370-6365)].From = b.bl data.cornerBox[(7951-7946)].To = b.bl + Vector2.new(cw, (1062-1062)) data.cornerBox[(7991-7986)].Visible = true
            data.cornerBox[(9260+-9254)].From = b.bl data.cornerBox[(5324-5318)].To = b.bl + Vector2.new((-243-367+610), -ch) data.cornerBox[(7288-7282)].Visible = true
            data.cornerBox[bit32.bxor(63481,63486)].From = b.br data.cornerBox[(-437-480+924)].To = b.br + Vector2.new(-cw, bit32.bxor(36815,36815)) data.cornerBox[(6686+-6679)].Visible = true
            data.cornerBox[bit32.bxor(11417,11409)].From = b.br data.cornerBox[(647-699+60)].To = b.br + Vector2.new((722-894+172), -ch) data.cornerBox[(-218-553+779)].Visible = true
        else
            for _, l in ipairs(data.cornerBox) do l.Visible = false end
        end

        if espEnabled.Skeleton then
            for i, pair in ipairs(SKELETON_JOINTS) do
                local p1 = char:FindFirstChild(pair[(5411-5410)])
                local p2 = char:FindFirstChild(pair[(243-818+577)])
                if p1 and p2 then
                    local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                    local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                    if on1 and on2 and s1.Z > bit32.bxor(63274,63274) then
                        data.skeleton[i].From = Vector2.new(s1.X, s1.Y)
                        data.skeleton[i].To = Vector2.new(s2.X, s2.Y)
                        data.skeleton[i].Visible = true
                    else
                        data.skeleton[i].Visible = false
                    end
                else
                    data.skeleton[i].Visible = false
                end
            end
        else
            for _, l in ipairs(data.skeleton) do l.Visible = false end
        end

        if espEnabled.Chams then
            if not data.highlight or not data.highlight.Parent then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB((1547-1292), (-587-144+761), (2232-2202))
                hl.OutlineColor = Color3.fromRGB((946-821+130), (3170+-2915), (8239+-7984))
                hl.FillTransparency = 0.45
                hl.OutlineTransparency = (4478-4478)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = char
                hl.Parent = char
                data.highlight = hl
            end
        else
            if data.highlight then
                data.highlight:Destroy()
                data.highlight = nil
            end
        end

        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local dist = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or bit32.bxor(48182,48182)
        local labelY = b.topY - bit32.bxor(26050,26066)

        if espEnabled.Name then
            data.nameLabel.Text = player.Name
            data.nameLabel.Position = Vector2.new(b.cx, labelY)
            data.nameLabel.Visible = true
            labelY -= (4768+-4752)
        else
            data.nameLabel.Visible = false
        end

        if espEnabled.Distance then
            data.distLabel.Text = dist .. "m"
            data.distLabel.Position = Vector2.new(b.cx, labelY)
            data.distLabel.Visible = true
            labelY -= (1878+-1862)
        else
            data.distLabel.Visible = false
        end

        if espEnabled.Weapon then
            local weapon = "None"
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then weapon = item.Name break end
            end
            data.weaponLabel.Text = "[" .. weapon .. "]"
            data.weaponLabel.Position = Vector2.new(b.cx, b.botY + bit32.bxor(56926,56924))
            data.weaponLabel.Visible = true
        else
            data.weaponLabel.Visible = false
        end

        if espEnabled.Backpack then
            local items = {}
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then table.insert(items, item.Name) end
                end
            end
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then table.insert(items, item.Name .. "*") end
            end
            data.backpackLabel.Text = #items > (6506+-6506) and table.concat(items, "  ") or ""
            data.backpackLabel.Position = Vector2.new(b.cx, b.botY + (319-698+395))
            data.backpackLabel.Visible = #items > (527+-527)
        else
            data.backpackLabel.Visible = false
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    createPlayerESP(player)
end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

local function fireProxPrompt(prompt)
    local oldDist = prompt.MaxActivationDistance
    local oldHold = prompt.HoldDuration
    prompt.MaxActivationDistance = 9999999999999999
    prompt.HoldDuration = bit32.bxor(442,442)
    fireproximityprompt(prompt)
    prompt.MaxActivationDistance = oldDist
    prompt.HoldDuration = oldHold
end

local function tweenToInstance(instance)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { CFrame = instance.CFrame * CFrame.new((9527+-9527), (92-92), (-296-447+746)) }
    )
    tween:Play()
    tween.Completed:Wait()
end

local FarmSection = Window:Section({ Title = "Farm" })
local PlayerSection = Window:Section({ Title = "Player" })
local MovementSection = Window:Section({ Title = "Movement" })
local VisualSection = Window:Section({ Title = "Visual" })
local ConfigSection = Window:Section({ Title = "Config" })

local FarmTab = FarmSection:Tab({
    Title = "Farm",
    Icon = "solar:sledgehammer-bold",
    IconColor = Color3.fromHex("#ECA201"),
    IconShape = "Square",
    Border = true,
})

local TrashSection = FarmTab:Section({ Title = "AutoFarm Trash" })

TrashSection:Toggle({
    Title = "AutoFarm Trash",
    Desc = "Farms trash at StoreJob automatically",
    Flag = "AutoFarmTrash",
    Callback = function(Value)
        autoFarmTrashRunning = Value
        if Value then
            WindUI:Notify({ Title = "AutoFarm Trash", Content = "Started!", Duration = (8332-8329) })
            task.spawn(function()
                RS.Remotes.SpawnHandler:FireServer("FairField")
                task.wait(1.5)
                local jobPrompt = workspace.StoreJob.JobNPC.Torso.ProximityPrompt
                tweenToInstance(workspace.StoreJob.JobNPC.Torso)
                fireProxPrompt(jobPrompt)
                task.wait(0.5)
                local char = lp.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(104.8477554321289, 3.812452793121338, 47.91452407836914)
                    end
                end
                task.wait(0.3)
                while autoFarmTrashRunning do
                    local bagPrompt = workspace.StoreJob.BagSpawn.binbags.ProximityPrompt
                    local bagOldDist = bagPrompt.MaxActivationDistance
                    local bagOldHold = bagPrompt.HoldDuration
                    bagPrompt.MaxActivationDistance = 9999999999999999
                    bagPrompt.HoldDuration = (9648+-9648)
                    for i = (363-851+489), bit32.bxor(62748,62742) do
                        if not autoFarmTrashRunning then break end
                        fireproximityprompt(bagPrompt)
                        task.wait(0.05)
                    end
                    bagPrompt.MaxActivationDistance = bagOldDist
                    bagPrompt.HoldDuration = bagOldHold
                    local throwPrompt = workspace.StoreJob.Throw.ProximityPrompt
                    local throwOldDist = throwPrompt.MaxActivationDistance
                    local throwOldHold = throwPrompt.HoldDuration
                    throwPrompt.MaxActivationDistance = 9999999999999999
                    throwPrompt.HoldDuration = (-296-500+796)
                    for i = (9836+-9835), (602-637+45) do
                        if not autoFarmTrashRunning then break end
                        fireproximityprompt(throwPrompt)
                        task.wait(0.05)
                    end
                    throwPrompt.MaxActivationDistance = throwOldDist
                    throwPrompt.HoldDuration = throwOldHold
                    task.wait(0.1)
                end
            end)
        else
            WindUI:Notify({ Title = "AutoFarm Trash", Content = "Stopped.", Duration = (-328-60+391) })
        end
    end
})

FarmTab:Space()

local PopEyesSection = FarmTab:Section({ Title = "AutoFarm Pop Eyes" })

PopEyesSection:Toggle({
    Title = "AutoFarm Pop Eyes",
    Desc = "Farms at PopEyes job automatically",
    Flag = "AutoFarmPopEyes",
    Callback = function(Value)
        autoFarmPopEyesRunning = Value
        if Value then
            WindUI:Notify({ Title = "AutoFarm Pop Eyes", Content = "Started!", Duration = bit32.bxor(11919,11916) })
            task.spawn(function()
                RS.Remotes.SpawnHandler:FireServer("GhostTown")
                task.wait(1.5)
                local jobPrompt = workspace.PopEyesJob.JobNPC.Torso.ProximityPrompt
                tweenToInstance(workspace.PopEyesJob.JobNPC.Torso)
                fireProxPrompt(jobPrompt)
                task.wait(0.5)
                local char = lp.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(-135.9095458984375, 3.6908910274505615, -372.69952392578125)
                    end
                end
                task.wait(0.3)
                while autoFarmPopEyesRunning do
                    local chickenPrompt = workspace.PopEyesJob.ChickenSpawn.Spawn.ProximityPrompt
                    local chickenOldDist = chickenPrompt.MaxActivationDistance
                    local chickenOldHold = chickenPrompt.HoldDuration
                    chickenPrompt.MaxActivationDistance = 9999999999999999
                    chickenPrompt.HoldDuration = (-271-158+429)
                    for i = (7181-7180), (2796+-2786) do
                        if not autoFarmPopEyesRunning then break end
                        fireproximityprompt(chickenPrompt)
                        task.wait(0.05)
                    end
                    chickenPrompt.MaxActivationDistance = chickenOldDist
                    chickenPrompt.HoldDuration = chickenOldHold
                    local fryPrompt = workspace.PopEyesJob.Fry.ProximityPrompt
                    local fryOldDist = fryPrompt.MaxActivationDistance
                    local fryOldHold = fryPrompt.HoldDuration
                    fryPrompt.MaxActivationDistance = 9999999999999999
                    fryPrompt.HoldDuration = (2433-2433)
                    for i = (45*0+1), (34*0+10) do
                        if not autoFarmPopEyesRunning then break end
                        fireproximityprompt(fryPrompt)
                        task.wait(0.05)
                    end
                    fryPrompt.MaxActivationDistance = fryOldDist
                    fryPrompt.HoldDuration = fryOldHold
                    task.wait(0.1)
                end
            end)
        else
            WindUI:Notify({ Title = "AutoFarm Pop Eyes", Content = "Stopped.", Duration = (50*0+3) })
        end
    end
})

local PlayerTab = PlayerSection:Tab({
    Title = "Player",
    Icon = "solar:user-bold",
    IconColor = Color3.fromHex("#257AF7"),
    IconShape = "Square",
    Border = true,
})

local PlayerCoreSection = PlayerTab:Section({ Title = "Player Mods" })

PlayerCoreSection:Toggle({
    Title = "Inf Stamina",
    Desc = "Keeps your stamina at maximum",
    Flag = "InfStamina",
    Callback = function(Value)
        if Value then
            infStaminaConn = RunService.Heartbeat:Connect(function()
                local playerFolder = workspace:FindFirstChild(lp.Name)
                local staminaVal = playerFolder and playerFolder:FindFirstChild("StaminaValue")
                if staminaVal then staminaVal.Value = 9999999999999999 end
            end)
        else
            if infStaminaConn then infStaminaConn:Disconnect() infStaminaConn = nil end
        end
    end
})

PlayerTab:Space()

PlayerCoreSection:Toggle({
    Title = "Anti JumpCooldown",
    Desc = "Deletes the JumpCooldown script from your character",
    Flag = "AntiJumpCooldown",
    Callback = function(Value)
        if Value then
            antiJumpCooldownConn = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                if not char then return end
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("LocalScript") and obj.Name:lower():find("jump") then
                        obj:Destroy()
                    end
                end
            end)
        else
            if antiJumpCooldownConn then antiJumpCooldownConn:Disconnect() antiJumpCooldownConn = nil end
        end
    end
})

local MovementTab = MovementSection:Tab({
    Title = "Movement",
    Icon = "solar:running-bold",
    IconColor = Color3.fromHex("#10C550"),
    IconShape = "Square",
    Border = true,
})

local MovementCoreSection = MovementTab:Section({ Title = "Movement Mods" })

MovementCoreSection:Toggle({
    Title = "Speed Boost",
    Desc = "Boosts movement speed via body velocity",
    Flag = "SpeedBoost",
    Callback = function(Value)
        if Value then
            speedBoostConn = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")
                if not hrp or not humanoid then return end
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > (400+-400) then
                    local bv = hrp:FindFirstChild("SpeedBV")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "SpeedBV"
                        bv.MaxForce = Vector3.new((5923+94077), bit32.bxor(27636,27636), bit32.bxor(71347,36883))
                        bv.Parent = hrp
                    end
                    bv.Velocity = moveDir * currentSpeed
                else
                    local bv = hrp:FindFirstChild("SpeedBV")
                    if bv then bv:Destroy() end
                end
            end)
        else
            if speedBoostConn then speedBoostConn:Disconnect() speedBoostConn = nil end
            local char = lp.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("SpeedBV")
                    if bv then bv:Destroy() end
                end
            end
        end
    end
})

MovementTab:Space()

MovementCoreSection:Slider({
    Title = "Speed Value",
    Desc = "Set the speed boost amount",
    Min = (236-938+712),
    Max = (271+29),
    Default = (-214-22+271),
    Increment = (-11-545+557),
    Flag = "SpeedSlider",
    Callback = function(Value)
        currentSpeed = Value
    end
})

MovementTab:Space()

MovementCoreSection:Slider({
    Title = "Jump Boost",
    Desc = "Lower gravity = higher jumps (default 196)",
    Min = bit32.bxor(45716,45713),
    Max = (14*14+0),
    Default = (562-421+55),
    Increment = (38*0+1),
    Flag = "JumpSlider",
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

local VisualTab = VisualSection:Tab({
    Title = "Visual",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#7775F2"),
    IconShape = "Square",
    Border = true,
})

local LightingSection = VisualTab:Section({ Title = "Lighting" })

LightingSection:Toggle({
    Title = "Full Bright",
    Desc = "Sets ambient lighting to maximum",
    Flag = "FullBright",
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            Lighting.Brightness = (94-135+51)
            Lighting.ClockTime = bit32.bxor(53605,53611)
            Lighting.FogEnd = (13*7692+4)
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB((14*18+3), (-666-18+939), (161-391+485))
            Lighting.OutdoorAmbient = Color3.fromRGB((225-866+896), (46*5+25), (8694+-8439))
        else
            Lighting.Brightness = (31*0+1)
            Lighting.ClockTime = bit32.bxor(51514,51508)
            Lighting.FogEnd = bit32.bxor(76317,44221)
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB((-239-29+338), bit32.bxor(58430,58488), (41*1+29))
            Lighting.OutdoorAmbient = Color3.fromRGB((7*18+2), (-606-228+962), (572-713+269))
        end
    end
})

VisualTab:Space()

local ESPSection = VisualTab:Section({ Title = "ESP" })

ESPSection:Toggle({
    Title = "Box ESP",
    Desc = "Draws a box around each player",
    Flag = "ESPBox",
    Callback = function(Value)
        espEnabled.Box = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Corner Box",
    Desc = "Draws corner brackets around each player",
    Flag = "ESPCornerBox",
    Callback = function(Value)
        espEnabled.CornerBox = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Skeleton",
    Desc = "Draws joint lines on each player",
    Flag = "ESPSkeleton",
    Callback = function(Value)
        espEnabled.Skeleton = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Chams",
    Desc = "Highlights players through walls",
    Flag = "ESPChams",
    Callback = function(Value)
        espEnabled.Chams = Value
        if not Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player == lp then continue end
                local data = espObjects[player]
                if data and data.highlight then
                    data.highlight:Destroy()
                    data.highlight = nil
                end
            end
        end
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Name",
    Desc = "Shows player names above their head",
    Flag = "ESPName",
    Callback = function(Value)
        espEnabled.Name = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Distance",
    Desc = "Shows distance to each player in meters",
    Flag = "ESPDistance",
    Callback = function(Value)
        espEnabled.Distance = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Weapon",
    Desc = "Shows the tool a player is holding",
    Flag = "ESPWeapon",
    Callback = function(Value)
        espEnabled.Weapon = Value
    end
})

VisualTab:Space()

ESPSection:Toggle({
    Title = "Backpack",
    Desc = "Shows all items in a player's backpack",
    Flag = "ESPBackpack",
    Callback = function(Value)
        espEnabled.Backpack = Value
    end
})

local ConfigTab = ConfigSection:Tab({
    Title = "Config",
    Icon = "solar:folder-with-files-bold",
    IconColor = Color3.fromHex("#ECA201"),
    IconShape = "Square",
    Border = true,
})

local ConfigManagerSection = ConfigTab:Section({ Title = "Config Manager" })
local ConfigName = "default"

ConfigManagerSection:Input({
    Title = "Config Name",
    Desc = "Enter a config name",
    Placeholder = "default",
    Flag = "ConfigNameInput",
    Callback = function(Value)
        ConfigName = Value ~= "" and Value or "default"
    end
})

ConfigTab:Space()

local ConfigGroup = ConfigTab:Group({})

ConfigGroup:Button({
    Title = "Save",
    Icon = "floppy-disk",
    Justify = "Center",
    Callback = function()
        WindUI:SaveConfig(ConfigName)
        WindUI:Notify({ Title = "Config", Content = "Saved: " .. ConfigName, Duration = bit32.bxor(38628,38631) })
    end
})

ConfigGroup:Space()

ConfigGroup:Button({
    Title = "Load",
    Icon = "folder-open",
    Justify = "Center",
    Callback = function()
        WindUI:UseConfig(ConfigName)
        WindUI:Notify({ Title = "Config", Content = "Loaded: " .. ConfigName, Duration = bit32.bxor(619,616) })
    end
})

ConfigTab:Space()

local DangerSection = ConfigTab:Section({ Title = "Danger Zone" })

DangerSection:Button({
    Title = "Destroy UI",
    Icon = "shredder",
    Color = Color3.fromHex("#EF4F1D"),
    Justify = "Center",
    IconAlign = "Left",
    Callback = function()
        rawset(Env, "IndraHubBatonRunning", false)
        for _, player in ipairs(Players:GetPlayers()) do
            removePlayerESP(player)
        end
        Window:Destroy()
    end
})

