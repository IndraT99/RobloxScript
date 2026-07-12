-- IndraHub - TPS Supervisor Compatible
local env = getgenv and getgenv() or _G

rawset(_G, "IndraHubTPSRunning", true)
rawset(_G, "IndraHubTPSLastHeartbeat", os.clock())
rawset(_G, "IndraHubTPSError", nil)

task.spawn(function()
    while rawget(_G, "IndraHubTPSRunning") == true do
        rawset(_G, "IndraHubTPSLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.Name = "BypassGUI"

-- Create fullscreen frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 1  -- start transparent

-- Text label
local text = Instance.new("TextLabel", frame)
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextScaled = true
text.Font = Enum.Font.GothamBlack
text.TextTransparency = 1
text.Text = "WAIT A SEC..."

-- Fade in frame and text
TweenService:Create(frame, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
TweenService:Create(text, TweenInfo.new(1), {TextTransparency = 0}):Play()
task.wait(3)

-- Change message
text.Text = "INDRAHUB TPS PREMIUM"

-- Wait then fade out
task.wait(2)
TweenService:Create(frame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(text, TweenInfo.new(1), {TextTransparency = 1}):Play()

task.wait(1)
gui:Destroy()

local a = workspace.FE.Actions

if a:FindFirstChild("KeepYourHeadUp_") then
    a.KeepYourHeadUp_:Destroy()

    local r = Instance.new("RemoteEvent")
    r.Name = "KeepYourHeadUp_"
    r.Parent = a
else
    game.Players.LocalPlayer:Kick(
        "Anti-Cheat Updated! Send a photo of this Message in our Discord Server so we can fix it."
    )
end



local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()





if env and env.IndraHubTPSWindow then pcall(function() env.IndraHubTPSWindow:Destroy() end) end

local Window = WindUI:CreateWindow({
    Title = "IndraHub | TPS Premium",
    Icon = "circle-dot",
    Author = "TPS Auto",
    Folder = "IndraHubTPS",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})
if env then env.IndraHubTPSWindow = Window end



local Tab1 = Window:Tab({Title = "Read", Icon = "badge-info"}) do

    Tab1:Section({Title = "Read"})


Tab1:Label({ Title = "First time using this UI library.\nReport bugs: discord.gg/twistzzscripts" })

end


local Tab2 = Window:Tab({Title = "Reach Methods", Icon = "circle-user-round"}) do

    Tab2:Section({Title = "Reach Method 1 [Recommand this one] [ADDED AUTO ENABLE BACK]"})

    --------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local reachEnabled = false
local shouldReEnable = false
local selectedLegName = "Right Leg"
local reachDistance = 10
local currentConnection = nil
local storedHip = nil

--------------------------------------------------
-- ENABLE REACH
--------------------------------------------------
local function enableReach()
    if reachEnabled then return end
    reachEnabled = true
    shouldReEnable = true

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local leg = character:WaitForChild(selectedLegName)

    -- hide legs (visual only)
    if character:FindFirstChild("Right Leg") then
        character["Right Leg"].Transparency = 1
    end
    if character:FindFirstChild("Left Leg") then
        character["Left Leg"].Transparency = 1
    end

    -- disable hip safely
    storedHip = character:FindFirstChild(
        selectedLegName == "Right Leg" and "Right Hip" or "Left Hip",
        true
    )
    if storedHip then
        storedHip.Enabled = false
    end

    currentConnection = RunService.RenderStepped:Connect(function()
        local TPSSystem = workspace:FindFirstChild("TPSSystem")
        local TPS = TPSSystem and TPSSystem:FindFirstChild("TPS")
        if not TPS or not hrp or not leg then return end

        local direction = TPS.Position - hrp.Position
        local distance = direction.Magnitude

        if distance <= reachDistance then
            leg.CFrame = TPS.CFrame
        else
            leg.CFrame = CFrame.new(hrp.Position + direction.Unit * reachDistance)
        end
    end)
end

--------------------------------------------------
-- DISABLE REACH
--------------------------------------------------
local function disableReach()
    reachEnabled = false
    shouldReEnable = false

    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end

    local character = player.Character
    if character then
        if character:FindFirstChild("Right Leg") then
            character["Right Leg"].Transparency = 0
        end
        if character:FindFirstChild("Left Leg") then
            character["Left Leg"].Transparency = 0
        end
    end

    if storedHip then
        storedHip.Enabled = true
        storedHip = nil
    end
end

--------------------------------------------------
-- AUTO RE-ENABLE ON RESET
--------------------------------------------------
player.CharacterAdded:Connect(function()
    reachEnabled = false
    storedHip = nil

    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end

    if shouldReEnable then
        task.wait(0.25) -- let character load
        
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1

                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1,2,1)
                LeftLegM.Locked = true
                LeftLegM.Position = character["Left Leg"].Position

                local Attachment = Instance.new("Attachment", LeftLegM)
                Attachment.Name = "LeftFootAttachment"
                Attachment.Position = Vector3.new(0,-1,0)

                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Name = "Fake Left Hip"
                MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.MaxVelocity = 0.1
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM

                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1,2,1)
                RightLegM.Locked = true
                RightLegM.Position = character["Right Leg"].Position

                local Attachment2 = Instance.new("Attachment", RightLegM)
                Attachment2.Name = "RightFootAttachment"
                Attachment2.Position = Vector3.new(0,-1,0)

                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Name = "Fake Right Hip"
                MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.MaxVelocity = 0.1
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM

            end
        
        enableReach()
    end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------
Tab2:Toggle({
    Title = "Enable / Disable Reach",
    Desc = "Recommended to use this reach method.",
    Value = false,
    Callback = function(v)
        if v then
            enableReach()
        else
            disableReach()
        end
    end
})

Tab2:Slider({
    Title = "Reach Size",
    Min = 1,
    Max = 25,
    Step = 1,
    Value = reachDistance,
    Callback = function(val)
        reachDistance = val
    end
})



Tab2:Button({
    Title = "Fake Legs",
    Desc = "Using this your legs will appear normal.",
    Callback = function()
    

            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1

                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1,2,1)
                LeftLegM.Locked = true
                LeftLegM.Position = character["Left Leg"].Position

                local Attachment = Instance.new("Attachment", LeftLegM)
                Attachment.Name = "LeftFootAttachment"
                Attachment.Position = Vector3.new(0,-1,0)

                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Name = "Fake Left Hip"
                MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.MaxVelocity = 0.1
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM

                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1,2,1)
                RightLegM.Locked = true
                RightLegM.Position = character["Right Leg"].Position

                local Attachment2 = Instance.new("Attachment", RightLegM)
                Attachment2.Name = "RightFootAttachment"
                Attachment2.Position = Vector3.new(0,-1,0)

                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Name = "Fake Right Hip"
                MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.MaxVelocity = 0.1
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM

            end
    end
})


    Tab2:Section({Title = "Reach Method 2 "})



--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local reachEnabled = false
local autoEnableAfterReset = false
local wasReachEnabledBeforeReset = false

local normalLegsEnabled = false
local wasNormalLegsBeforeReset = false

local selectedLegName = "Right Leg"
local boxSize = Vector3.new(10, 10, 10)
local currentConnection = nil

--------------------------------------------------
-- VISUAL BOX
--------------------------------------------------
local visualBox = Instance.new("Part")
visualBox.Anchored = true
visualBox.CanCollide = false
visualBox.Transparency = 1
visualBox.Material = Enum.Material.Neon
visualBox.Color = Color3.fromRGB(255, 0, 0)
visualBox.Size = boxSize
visualBox.Parent = workspace

--------------------------------------------------
-- BOX CHECK
--------------------------------------------------
local function isBoxTouching(cf1, size1, cf2, size2)
    local min1 = cf1.Position - size1/2
    local max1 = cf1.Position + size1/2
    local min2 = cf2.Position - size2/2
    local max2 = cf2.Position + size2/2

    return (min1.X <= max2.X and max1.X >= min2.X)
       and (min1.Y <= max2.Y and max1.Y >= min2.Y)
       and (min1.Z <= max2.Z and max1.Z >= min2.Z)
end

--------------------------------------------------
-- REACH TOGGLE
--------------------------------------------------

    Tab2:Toggle({
        Title = "Enable / Disable Reach",
        Desc = "",
        Value = false,
        Callback = function(Value)
  reachEnabled = Value
      wasReachEnabledBeforeReset = Value

      if currentConnection then
         currentConnection:Disconnect()
         currentConnection = nil
      end
      if not Value then return end

      local character = player.Character or player.CharacterAdded:Wait()
      local hrp = character:WaitForChild("HumanoidRootPart")
      local leg = character:WaitForChild(selectedLegName)

      if character:FindFirstChild("Right Leg") then
         character["Right Leg"].Transparency = 1
      end
      if character:FindFirstChild("Left Leg") then
         character["Left Leg"].Transparency = 1
      end

      local originalLegCFrame = leg.CFrame

      local hip = character:FindFirstChild(
         selectedLegName == "Right Leg" and "Right Hip" or "Left Hip",
         true
      )
      if hip then hip:Destroy() end

      currentConnection = RunService.RenderStepped:Connect(function()
         local TPSSystem = workspace:FindFirstChild("TPSSystem")
         local TPS = TPSSystem and TPSSystem:FindFirstChild("TPS")
         if not TPS or not hrp or not leg then return end

         visualBox.Size = boxSize
         visualBox.CFrame = hrp.CFrame

         if isBoxTouching(hrp.CFrame, boxSize, TPS.CFrame, TPS.Size) then
            leg.CFrame = TPS.CFrame
         else
            leg.CFrame = originalLegCFrame
         end
      end)
        end
    })



    Tab2:Toggle({
        Title = "Enable / Disable Auto Enable After Death / Reset",
        Desc = "",
        Value = false,
        Callback = function(Value)
      autoEnableAfterReset = Value
        end
    })


    Tab2:Dropdown({
        Title = "Choose Your Leg",
        Values = {"Right Leg", "Left Leg"},
        Value = "Right Leg",
        Callback = function(Value)
         selectedLegName = Value[1]
      if reachEnabled then
         Toggle:Set(false)
         task.wait()
         Toggle:Set(true)
      end
        end
    })
    Tab2:Slider({
        Title = "Box Size X",
        Min = 1,
        Max = 20,
        Step = 1,
        Value = 1,
        Callback = function(v)
      boxSize = Vector3.new(v, boxSize.Y, boxSize.Z)
        end
    })

        Tab2:Slider({
        Title = "Box Size Y",
        Min = 1,
        Max = 20,
        Step = 1,
        Value = 1,
        Callback = function(v)
      boxSize = Vector3.new(boxSize.X, v, boxSize.Z)
        end
    })
    Tab2:Slider({
        Title = "Box Size Z",
        Min = 1,
        Max = 20,
        Step = 1,
        Value = 1,
        Callback = function(v)
      boxSize = Vector3.new(boxSize.X, boxSize.Y, v)
        end
    })
    Tab2:Slider({
        Title = "Box Size XYZ",
        Min = 1,
        Max = 20,
        Step = 1,
        Value = 1,
        Callback = function(v)
      boxSize = Vector3.new(v, v, v)
        end
    })

    Tab2:Input({
        Title = "Box Size XYZ",
        Desc = "Custom Size",
        Placeholder = "Number",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(v)
      boxSize = Vector3.new(v, v, v)
        end
    })

    Tab2:Input({
        Title = "Box Transperncy",
        Desc = "0-1",
        Placeholder = "Number",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(v)
      visualBox.Transparency = math.clamp(tonumber(v) or 0.5, 0, 1)
        end
    })

    Tab2:Toggle({
        Title = "Appear Normal",
        Desc = "",
        Value = false,
        Callback = function(Value)
        normalLegsEnabled = Value
        wasNormalLegsBeforeReset = Value

        if Value then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid.RigType == Enum.HumanoidRigType.R6 then
                -- R6 legs setup
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1

                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1,2,1)
                LeftLegM.Locked = true
                LeftLegM.Position = character["Left Leg"].Position

                local Attachment = Instance.new("Attachment", LeftLegM)
                Attachment.Name = "LeftFootAttachment"
                Attachment.Position = Vector3.new(0,-1,0)

                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Name = "Fake Left Hip"
                MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.MaxVelocity = 0.1
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM

                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1,2,1)
                RightLegM.Locked = true
                RightLegM.Position = character["Right Leg"].Position

                local Attachment2 = Instance.new("Attachment", RightLegM)
                Attachment2.Name = "RightFootAttachment"
                Attachment2.Position = Vector3.new(0,-1,0)

                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Name = "Fake Right Hip"
                MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.MaxVelocity = 0.1
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM

            elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
                character["RightLowerLeg"].Transparency = 1
                character["LeftLowerLeg"].Transparency = 1
            end
        end
        end
    })


--------------------------------------------------
-- HANDLE CHARACTER RESET (WITH 5s DELAY)
--------------------------------------------------
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")

    hum.Died:Connect(function()
        wasReachEnabledBeforeReset = reachEnabled
        wasNormalLegsBeforeReset = normalLegsEnabled
    end)

    task.wait(5) -- wait 5 seconds after respawn

    if autoEnableAfterReset and wasReachEnabledBeforeReset then
        Toggle:Set(false)
        task.wait(0.1)
        Toggle:Set(true)
    end

    if wasNormalLegsBeforeReset then
        NormalLegsToggle:Set(false)
        task.wait(0.1)
        NormalLegsToggle:Set(true)
    end
end)

end
local Tab3 = Window:Tab({Title = "Reacts", Icon = "apple"}) do
    Tab3:Section({Title = "Twistzz React"})



        Tab3:Button({
        Title = "OP REACT NEW ITS FIREEEEEE",
        Desc = "W REACT BY TWISTZZ ",
        Callback = function()

            --------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local reachEnabled = false
local selectedLegName = "Right Leg"
local reachDistance = 2.3 -- how far your leg can reach
local currentConnection = nil

--------------------------------------------------
-- ENABLE REACH
--------------------------------------------------
local function enableReach()
    if reachEnabled then return end
    reachEnabled = true

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local leg = character:WaitForChild(selectedLegName)

    -- Hide legs
    if character:FindFirstChild("Right Leg") then
        character["Right Leg"].Transparency = 1
    end
    if character:FindFirstChild("Left Leg") then
        character["Left Leg"].Transparency = 1
    end

    -- Destroy hip joint for free movement
    local hip = character:FindFirstChild(
        selectedLegName == "Right Leg" and "Right Hip" or "Left Hip",
        true
    )
    if hip then hip:Destroy() end

    currentConnection = RunService.RenderStepped:Connect(function()
        local TPSSystem = workspace:FindFirstChild("TPSSystem")
        local TPS = TPSSystem and TPSSystem:FindFirstChild("TPS")
        if not TPS or not hrp or not leg then return end

        local direction = (TPS.Position - hrp.Position)
        local distance = direction.Magnitude

        if distance <= reachDistance then
            -- Snap leg to TPS CFrame (touch)
            leg.CFrame = TPS.CFrame
        else
            -- Move leg closer to target but within max reach
            local moveVector = direction.Unit * reachDistance
            leg.CFrame = CFrame.new(hrp.Position + moveVector)
        end
    end)
end

--------------------------------------------------
-- DISABLE REACH
--------------------------------------------------
local function disableReach()
    reachEnabled = false
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end

    local character = player.Character
    if character then
        if character:FindFirstChild("Right Leg") then
            character["Right Leg"].Transparency = 0
        end
        if character:FindFirstChild("Left Leg") then
            character["Left Leg"].Transparency = 0
        end
    end
end

--------------------------------------------------
-- CHANGE REACH DISTANCE
--------------------------------------------------
local function setReachDistance(dist)
    reachDistance = dist
end

--------------------------------------------------
-- USAGE EXAMPLE
--------------------------------------------------
enableReach()          -- enable reach
setReachDistance(2.3)   -- optional: set max reach distance
-- disableReach()       -- disable reach when done




            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1

                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1,2,1)
                LeftLegM.Locked = true
                LeftLegM.Position = character["Left Leg"].Position

                local Attachment = Instance.new("Attachment", LeftLegM)
                Attachment.Name = "LeftFootAttachment"
                Attachment.Position = Vector3.new(0,-1,0)

                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Name = "Fake Left Hip"
                MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.MaxVelocity = 0.1
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM

                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1,2,1)
                RightLegM.Locked = true
                RightLegM.Position = character["Right Leg"].Position

                local Attachment2 = Instance.new("Attachment", RightLegM)
                Attachment2.Name = "RightFootAttachment"
                Attachment2.Position = Vector3.new(0,-1,0)

                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Name = "Fake Right Hip"
                MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.MaxVelocity = 0.1
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM

            end
local Players = game:GetService("Players")

local player = Players.LocalPlayer

player.CharacterAdded:Connect(function(character)
--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local reachEnabled = false
local selectedLegName = "Right Leg"
local reachDistance = 2.3 -- how far your leg can reach
local currentConnection = nil

--------------------------------------------------
-- ENABLE REACH
--------------------------------------------------
local function enableReach()
    if reachEnabled then return end
    reachEnabled = true

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local leg = character:WaitForChild(selectedLegName)

    -- Hide legs
    if character:FindFirstChild("Right Leg") then
        character["Right Leg"].Transparency = 1
    end
    if character:FindFirstChild("Left Leg") then
        character["Left Leg"].Transparency = 1
    end

    -- Destroy hip joint for free movement
    local hip = character:FindFirstChild(
        selectedLegName == "Right Leg" and "Right Hip" or "Left Hip",
        true
    )
    if hip then hip:Destroy() end

    currentConnection = RunService.RenderStepped:Connect(function()
        local TPSSystem = workspace:FindFirstChild("TPSSystem")
        local TPS = TPSSystem and TPSSystem:FindFirstChild("TPS")
        if not TPS or not hrp or not leg then return end

        local direction = (TPS.Position - hrp.Position)
        local distance = direction.Magnitude

        if distance <= reachDistance then
            -- Snap leg to TPS CFrame (touch)
            leg.CFrame = TPS.CFrame
        else
            -- Move leg closer to target but within max reach
            local moveVector = direction.Unit * reachDistance
            leg.CFrame = CFrame.new(hrp.Position + moveVector)
        end
    end)
end

--------------------------------------------------
-- DISABLE REACH
--------------------------------------------------
local function disableReach()
    reachEnabled = false
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end

    local character = player.Character
    if character then
        if character:FindFirstChild("Right Leg") then
            character["Right Leg"].Transparency = 0
        end
        if character:FindFirstChild("Left Leg") then
            character["Left Leg"].Transparency = 0
        end
    end
end

--------------------------------------------------
-- CHANGE REACH DISTANCE
--------------------------------------------------
local function setReachDistance(dist)
    reachDistance = dist
end

--------------------------------------------------
-- USAGE EXAMPLE
--------------------------------------------------
enableReach()          -- enable reach
setReachDistance(2.3)   -- optional: set max reach distance
-- disableReach()       -- disable reach when done




            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1

                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1,2,1)
                LeftLegM.Locked = true
                LeftLegM.Position = character["Left Leg"].Position

                local Attachment = Instance.new("Attachment", LeftLegM)
                Attachment.Name = "LeftFootAttachment"
                Attachment.Position = Vector3.new(0,-1,0)

                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Name = "Fake Left Hip"
                MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                MotorHip.MaxVelocity = 0.1
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM

                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1,2,1)
                RightLegM.Locked = true
                RightLegM.Position = character["Right Leg"].Position

                local Attachment2 = Instance.new("Attachment", RightLegM)
                Attachment2.Name = "RightFootAttachment"
                Attachment2.Position = Vector3.new(0,-1,0)

                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Name = "Fake Right Hip"
                MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                MotorHip2.MaxVelocity = 0.1
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM

            end
end)

            WindUI:Notify({
    Title = "React",
    Content = "Action performed successfully.",
    Duration = 3
})
        end
    })

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Helper function using Tab3 UI
local function CreateReactSection(name, velocity, isGoalkeeper)
    -- Section
    Tab3:Section({
        Title = name
    })

    -- Button
    Tab3:Button({
        Title = name,
        Desc = "Activate "..name,
        Callback = function()

            if isGoalkeeper then
                local gkActions = {
                    "SaveRA", "SaveLA", "SaveRL",
                    "SaveLL", "SaveT", "Tackle", "Header"
                }

                for _, action in ipairs(gkActions) do
                    local meta = getrawmetatable(game)
                    local oldNamecall = meta.__namecall
                    setreadonly(meta, false)

                    meta.__namecall = newcclosure(function(self, ...)
                        local method = getnamecallmethod()

                        if method == "FireServer" and tostring(self) == action then
                            local args = { ... }
                            args[2] = player.Character.Humanoid.LLCL
                            return oldNamecall(self, unpack(args))
                        end

                        return oldNamecall(self, ...)
                    end)

                    setreadonly(meta, true)
                end

            else
                game.Workspace.TPSSystem.TPS.Velocity = velocity
            end

            WindUI:Notify({
    Title = name,
    Content = "React enabled successfully",
    Duration = 3
})
        end
    })
end

-- Create buttons
CreateReactSection("Better React", Vector3.new(100, 100, 100), false)
CreateReactSection("Alz React", Vector3.new(100, 100, 100), false)
CreateReactSection("Foxtede React", Vector3.new(110, 110, 110), false)
CreateReactSection("Goalkeeper React", nil, true)





local Tab5 = Window:Tab({Title = "Moss & Head Reach", Icon = "headset"}) do


    Tab5:Section({Title = "Moss"})


    local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

local originalHeadSize = head.Size
local originalHeadY = head.Position.Y

local enabled = false
local afterResetEnabled = false
local sizeX, sizeY, sizeZ = 5, 5, 5

local function removeHair(char)
	for _, item in ipairs(char:GetChildren()) do
		if item:IsA("Accessory") then
			local handle = item:FindFirstChild("Handle")
			if handle and handle:FindFirstChild("HairAttachment") then
				item:Destroy()
			end
		end
	end
end

local function updateHead()
	if not enabled or not head then return end

	local newSize = Vector3.new(sizeX, sizeY, sizeZ)
	head.Size = newSize

	local offset = (newSize.Y - originalHeadSize.Y) / 2 + 0.5
	head.Position = Vector3.new(
		head.Position.X,
		originalHeadY + offset,
		head.Position.Z
	)
end

local function applyAll()
	if not enabled or not head then return end

	originalHeadSize = head.Size
	originalHeadY = head.Position.Y

	head.Transparency = 1
	removeHair(character)
	updateHead()
end


player.CharacterAdded:Connect(function(char)
	character = char
	head = char:WaitForChild("Head")

	originalHeadSize = head.Size
	originalHeadY = head.Position.Y

	if afterResetEnabled then
		task.wait(0.1)
		applyAll()
	end
end)

Tab5:Toggle({
	Title = "Enable / Disable Moss (MAKE SURE Y SIZE IS HIGHER THEN X AND Y OTHERWISE IT WONT WORK GOOD !!)",
	Desc = "Head Reach",
	Value = false,
	Callback = function(v)
		enabled = v

		if v then
			applyAll()
		else
			head.Size = originalHeadSize
			head.Position = Vector3.new(
				head.Position.X,
				originalHeadY,
				head.Position.Z
			)
			head.Transparency = 0
		end
	end
})

Tab5:Slider({
	Title = "Set Size X",
	Min = 1,
	Max = 10,
	Step = 1,
	Value = 5,
	Callback = function(val)
		sizeX = val
		updateHead()
	end
})

Tab5:Slider({
	Title = "Set Size Y",
	Min = 1,
	Max = 10,
	Step = 1,
	Value = 5,
	Callback = function(val)
		sizeY = val
		updateHead()
	end
})

Tab5:Slider({
	Title = "Set Size Z",
	Min = 1,
	Max = 10,
	Step = 1,
	Value = 5,
	Callback = function(val)
		sizeZ = val
		updateHead()
	end
})
local RunService = game:GetService("RunService")
local fakeHead = nil
local fakeHeadConn = nil

Tab5:Toggle({
	Title = "Enable / Disable After Reset",
	Desc = "Reapply on Respawn",
	Value = false,
	Callback = function(v)
		afterResetEnabled = v
	end
})


local Tab6 = Window:Tab({Title = "Help", Icon = "circle-help"}) do


Tab6:Section({ Title = "Air Dribble Helper" })

local airDribbleEnabled = false
local airPart
local airConn

Tab6:Toggle({
    Title = "Enable / Disable Air Dribble Helper",
    Desc = "Shows helper under the ball",
    Value = false,
    Callback = function(v)
        airDribbleEnabled = v

        if not v then
            if airConn then airConn:Disconnect() end
            if airPart then airPart:Destroy() end
        end
    end
})

Tab6:Slider({
    Title = "Air Dribble Helper Size",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 10,
    Callback = function(val)
        if not airDribbleEnabled then return end

        if airPart then airPart:Destroy() end

        local part = Instance.new("Part")
        part.Name = "TPS"
        part.Size = Vector3.new(val, 0.001, val)
        part.Anchored = true
        part.Transparency = 1
        part.BrickColor = BrickColor.new("Bright red")
        part.Parent = workspace
        airPart = part

        local tpsSystem = workspace:FindFirstChild("TPSSystem")
        local tpsTarget = tpsSystem and tpsSystem:FindFirstChild("TPS")

        airConn = game:GetService("RunService").RenderStepped:Connect(function()
            if tpsTarget and airPart then
                airPart.Position = tpsTarget.Position - Vector3.new(0, 1, 0)
            end
        end)
    end
})


Tab6:Section({ Title = "ZZZZ Helper" })

local zzzzPart
local zzzzConn

Tab6:Toggle({
    Title = "ZZZZ Helper",
    Desc = "Static helper under ball",
    Value = false,
    Callback = function(state)
        if state then
            local part = Instance.new("Part")
            part.Name = "TPS1"
            part.Size = Vector3.new(9, 0.001, 9)
            part.Anchored = true
            part.Transparency = 1
            part.BrickColor = BrickColor.new("Bright red")
            part.Parent = workspace
            zzzzPart = part

            local tpsSystem = workspace:FindFirstChild("TPSSystem")
            local tpsTarget = tpsSystem and tpsSystem:FindFirstChild("TPS")

            zzzzConn = game:GetService("RunService").RenderStepped:Connect(function()
                if tpsTarget and zzzzPart then
                    zzzzPart.Position = tpsTarget.Position - Vector3.new(0, 1, 0)
                end
            end)
        else
            if zzzzConn then zzzzConn:Disconnect() end
            if zzzzPart then zzzzPart:Destroy() end
        end
    end
})

Tab6:Section({ Title = "Infinite Dribble Helper" })

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ball = workspace.TPSSystem.TPS
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local followBall = false
local toggleEnabled = false
local isMovingManually = false

local function follow()
    if followBall and toggleEnabled and not isMovingManually then
        character.Humanoid:MoveTo(ball.Position)
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.B and not gp and toggleEnabled then
        followBall = not followBall
    end
end)

UIS.InputEnded:Connect(function(input)
    isMovingManually = false
end)

RunService.RenderStepped:Connect(function()
    follow()
end)

player.CharacterAdded:Connect(function(char)
    character = char
end)

Tab6:Toggle({
    Title = "Infinite Dribble Helper (B to Toggle)",
    Desc = "Automatically follows the ball",
    Value = false,
    Callback = function(v)
        toggleEnabled = v
        if not v then
            followBall = false
        end
    end
})


local Tab7 = Window:Tab({Title = "Game Modifaction", Icon = "volleyball"}) do

    Tab7:Section({Title = "Ball Modification"})

    Tab7:Input({
        Title = "Ball Size",
        Desc = "",
        Placeholder = "",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(text)
        game:GetService("Workspace").TPSSystem.TPS.Size = Vector3.new(text, text, text)
if         game.Workspace["FollowerPart"] then 
            game.Workspace["FollowerPart"].Size = Vector3.new(text,text,text)
end
        end
    })

    Tab7:Button({
        Title = "Default Ball Size",
        Desc = "Press this shit to reset the ball size",
        Callback = function()
        game:GetService("Workspace").TPSSystem.TPS.Size = Vector3.new(    2.5, 2.5, 2.5)
if         game.Workspace["FollowerPart"] then 
            game.Workspace["FollowerPart"].Size = Vector3.new(    2.5, 2.5, 2.5)
end
            WindUI:Notify({
    Title = "Ball Size Returned Back To Normal",
    Content = "Action performed successfully.",
    Duration = 3
})
        end
    })

        Tab7:Toggle({
        Title = "Ball Collision",
        Desc = "gives back old collision (2019).",
        Value = false,
        Callback = function(v)
  if v then
local TPS = workspace:WaitForChild("TPSSystem"):WaitForChild("TPS")

-- Create the part
local follower = Instance.new("Part")
follower.Name = "FollowerPart"
follower.Shape = Enum.PartType.Ball
follower.Anchored = true
follower.CanCollide = true
follower.Material = Enum.Material.Air
follower.Color = TPS.Color -- Start with same color
follower.Parent = workspace

-- Sync function
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    if TPS then
        -- Match size
        follower.Size = TPS.Size
        
        -- Match position (and rotation)
        follower.CFrame = TPS.CFrame
        
        -- Match color
        follower.Color = TPS.Color
    end
end)

else 

    if workspace.FollowerPart then 
        workspace.FollowerPart:Destroy()
    end

end
        end
    })

Tab7:Toggle({
    Title = "Ball Predication",
    Desc = "",
    Value = false,
    Callback = function(v)

        local RunService = game:GetService("RunService")
        local Workspace = game:GetService("Workspace")
        local ball = workspace.TPSSystem.TPS
        local gravity = Workspace.Gravity

        local predictionTime = 0.65
        local segments = 20
        local smoothness = 0.15
        local groundCheckDistance = 1.2

        -- create once
        if not _G.BallPredictionFolder then
            local folder = Instance.new("Folder", Workspace)
            folder.Name = "BallPrediction"
            _G.BallPredictionFolder = folder

            local attachments = {}
            for i = 1, segments do
                local att = Instance.new("Attachment")
                att.WorldPosition = ball.Position
                att.Parent = folder
                attachments[i] = att
            end
            _G.BallPredictionAttachments = attachments

            local beam = Instance.new("Beam")
            beam.Attachment0 = attachments[1]
            beam.Attachment1 = attachments[#attachments]
            beam.FaceCamera = true
            beam.Width0 = 0.18
            beam.Width1 = 0.18
            beam.Color = ColorSequence.new(Color3.fromRGB(0, 150, 255)) -- BLUE
            beam.Transparency = NumberSequence.new(0.25)
            beam.LightEmission = 1
            beam.Segments = segments * 2
            beam.Parent = folder
            beam.Enabled = false
            _G.BallPredictionBeam = beam
        end

        local beam = _G.BallPredictionBeam
        local attachments = _G.BallPredictionAttachments

        -- raycast params
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {ball}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist

        local function isBallInAir()
            return Workspace:Raycast(
                ball.Position,
                Vector3.new(0, -groundCheckDistance, 0),
                rayParams
            ) == nil
        end

        -- toggle logic
        if v then
            if _G.BallPredictionConn then
                _G.BallPredictionConn:Disconnect()
            end

            _G.BallPredictionConn = RunService.RenderStepped:Connect(function()
                if not ball or not ball:IsA("BasePart") then return end

                if not isBallInAir() then
                    beam.Enabled = false
                    return
                end

                beam.Enabled = true

                local startPos = ball.Position
                local startVel = ball.AssemblyLinearVelocity

                for i = 1, segments do
                    local t = (i / segments) * predictionTime
                    local predictedPos =
                        startPos +
                        (startVel * t) +
                        Vector3.new(0, -0.5 * gravity * t * t, 0)

                    local groundHit = Workspace:Raycast(
                        predictedPos,
                        Vector3.new(0, -2, 0),
                        rayParams
                    )

                    if groundHit then
                        predictedPos = groundHit.Position + Vector3.new(0, 0.25, 0)
                    end

                    attachments[i].WorldPosition =
                        attachments[i].WorldPosition:Lerp(predictedPos, smoothness)
                end
            end)
        else
            if _G.BallPredictionConn then
                _G.BallPredictionConn:Disconnect()
                _G.BallPredictionConn = nil
            end
            beam.Enabled = false
        end
    end
})

Tab7:Toggle({
    Title = "Block Ball",
    Desc = "Minecraft ball (it gives some crazy ass react for ball.)",
    Value = false,
    Callback = function(v)
if v  then 
      local A_1 = game:GetService("Workspace").TPSSystem.TPS -- you can delete this 
                        
                                    A_1.Shape = "Block" --HERE CHANGE THE SHAPE
else 
                                      local A_1 = game:GetService("Workspace").TPSSystem.TPS -- you can delete this 
                        
                                    A_1.Shape = "Sphere" --HERE CHANGE THE SHAPE
end
    end
})

    Tab7:Section({Title = "CFGS (Recommand using ball collision with it.)"})

       Tab7:Button({
        Title = "Best CFG",
        Desc = "",
        Callback = function()
    game:GetService("Workspace").TPSSystem.TPS.Size = Vector3.new(2.85, 2.85, 2.85)
            WindUI:Notify({
    Title = "CFG Used",
    Content = "Action performed successfully.",
    Duration = 3
})
        end
    })

           Tab7:Button({
        Title = "ZZZZ CFG",
        Desc = "",
        Callback = function()
    game:GetService("Workspace").TPSSystem.TPS.Size = Vector3.new(3, 3, 3)
            WindUI:Notify({
    Title = "CFG Used",
    Content = "Action performed successfully.",
    Duration = 3
})
        end
    })
               Tab7:Button({
        Title = "Inf Dribble CFG",
        Desc = "",
        Callback = function()
    game:GetService("Workspace").TPSSystem.TPS.Size = Vector3.new(3, 3, 3)
            WindUI:Notify({
    Title = "CFG Used",
    Content = "Action performed successfully.",
    Duration = 3
})
        end
    })




end -- close Tab7

local Tab8 = Window:Tab({Title = "Player", Icon = "user"}) do

    Tab8:Section({Title = "Walkspeed"})
    local WalkspeedEnabled = false
    local CurrentSpeed = 23 

    Tab8:Toggle({
        Title = "Enable / Disable Walkspeed",
        Desc = "",
        Value = false,
        Callback = function(v)
            WalkspeedEnabled = v
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if v then
                        humanoid.WalkSpeed = CurrentSpeed
                    else
                        humanoid.WalkSpeed = 16
                    end
                end
            end
        end
    })

    Tab8:Slider({
        Title = "Speed Value",
        Min = 16,
        Max = 100,
        Step = 1,
        Value = 23,
        Callback = function(val)
            CurrentSpeed = val
            if WalkspeedEnabled then
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = CurrentSpeed
                    end
                end
            end
        end
    })

end
