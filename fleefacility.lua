local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
end)

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "IndraHub - Flee The Facility",
    Icon = "rbxassetid://18657887261",
    Author = "IndraHub",
    Folder = "IndraHub_FTF",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

-- Global State
local highlights = {}
local billboards = {}
local IH_FTF_State = {
    WalkSpeed = 16,
    InfJump = false,
    Noclip = false,
    AntiAFK = false,
    SelectedPlayer = nil,
    PlayerESP = false,
    BeastESP = false,
    ComputerESP = false,
    NoclipConn = nil,
    HeartbeatConn = nil
}

-- ESP Helpers
local function createHighlight(target, color)
    if highlights[target] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(0, 0, 0)
    hl.FillTransparency = 0.5
    hl.Parent = target
    highlights[target] = hl
end

local function createBillboard(target, text, color)
    if billboards[target] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    billboard.Parent = target
    billboards[target] = billboard
end

local function cleanupESP()
    for _, v in pairs(highlights) do pcall(function() v:Destroy() end) end
    for _, v in pairs(billboards) do pcall(function() v:Destroy() end) end
    highlights = {}
    billboards = {}
end

local function getPlayerList()
    local opts = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(opts, plr.Name)
        end
    end
    return opts
end

-- ==============================================
-- MAIN TAB
-- ==============================================

MainTab:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Step = 1,
    Callback = function(Value)
        IH_FTF_State.WalkSpeed = Value
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

MainTab:Toggle({
    Title = "Inf Jump",
    Default = false,
    Callback = function(Value) IH_FTF_State.InfJump = Value end
})

UserInputService.JumpRequest:Connect(function()
    if IH_FTF_State.InfJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        IH_FTF_State.Noclip = Value
        if Value then
            IH_FTF_State.NoclipConn = RunService.Stepped:Connect(function()
                pcall(function()
                    if not character then return end
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end)
            end)
        else
            if IH_FTF_State.NoclipConn then IH_FTF_State.NoclipConn:Disconnect() end
            pcall(function()
                if not character then return end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end)
        end
    end
})

MainTab:Toggle({
    Title = "Anti-AFK (Heartbeat)",
    Desc = "Spams VirtualUser clicks every frame to bypass AFK kick.",
    Default = false,
    Callback = function(Value)
        IH_FTF_State.AntiAFK = Value
        if Value then
            IH_FTF_State.HeartbeatConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        else
            if IH_FTF_State.HeartbeatConn then 
                IH_FTF_State.HeartbeatConn:Disconnect()
                IH_FTF_State.HeartbeatConn = nil
            end
        end
    end
})

local playerDropdown = MainTab:Dropdown({
    Title = "Select Player to Teleport",
    Values = getPlayerList(),
    Default = {},
    Callback = function(Option)
        -- WindUI returns a table for single selection if Multi=false is implicit, or a string.
        if type(Option) == "table" then
            for k,v in pairs(Option) do if v then IH_FTF_State.SelectedPlayer = k end end
        else
            IH_FTF_State.SelectedPlayer = Option
        end
    end
})

MainTab:Button({
    Title = "Refresh Player List",
    Callback = function()
        playerDropdown:Refresh(getPlayerList())
        WindUI:Notify({ Title = "IndraHub", Content = "Player list refreshed!" })
    end
})

MainTab:Button({
    Title = "Go to Selected Player",
    Callback = function()
        if not IH_FTF_State.SelectedPlayer then 
            WindUI:Notify({ Title = "IndraHub", Content = "No player selected!" })
            return 
        end
        local target = Players:FindFirstChild(IH_FTF_State.SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 4, 0)
                WindUI:Notify({ Title = "IndraHub", Content = "Teleported to " .. IH_FTF_State.SelectedPlayer })
            end
        else
            WindUI:Notify({ Title = "IndraHub", Content = "Player not found or dead!" })
        end
    end
})

MainTab:Button({
    Title = "Goto Captured (Rescue)",
    Callback = function()
        local found = false
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr:FindFirstChild("TempPlayerStatsModule") then
                local stats = plr.TempPlayerStatsModule
                if stats:FindFirstChild("Captured") and stats.Captured.Value == true then
                    WindUI:Notify({ Title = "IndraHub", Content = "Found captured: " .. plr.Name })
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                       plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    end
                    found = true
                    break
                end
            end
        end
        if not found then
            WindUI:Notify({ Title = "IndraHub", Content = "No captured players found" })
        end
    end
})

-- ==============================================
-- VISUALS TAB
-- ==============================================

VisualTab:Toggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(Value)
        IH_FTF_State.PlayerESP = Value
        if not Value then cleanupESP() end
    end
})

VisualTab:Toggle({
    Title = "Beast ESP",
    Default = false,
    Callback = function(Value)
        IH_FTF_State.BeastESP = Value
        if not Value then cleanupESP() end
    end
})

VisualTab:Toggle({
    Title = "Computer ESP (Facility_0)",
    Default = false,
    Callback = function(Value)
        IH_FTF_State.ComputerESP = Value
        if not Value then cleanupESP() end
    end
})

-- Active ESP Loop
RunService.RenderStepped:Connect(function()
    if IH_FTF_State.PlayerESP or IH_FTF_State.BeastESP or IH_FTF_State.ComputerESP then
        if IH_FTF_State.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    createHighlight(plr.Character, Color3.fromRGB(255, 0, 0))
                end
            end
        end
        
        if IH_FTF_State.BeastESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr:FindFirstChild("TempPlayerStatsModule") then
                    local stats = plr.TempPlayerStatsModule
                    if stats:FindFirstChild("IsBeast") and stats.IsBeast.Value then
                        createHighlight(plr.Character, Color3.fromRGB(0, 255, 0))
                        createBillboard(plr.Character, "BEAST", Color3.fromRGB(0, 255, 0))
                    end
                end
            end
        end

        if IH_FTF_State.ComputerESP then
            local facility = Workspace:FindFirstChild("Facility_0 by MrWindy")
            if facility then
                for _, obj in pairs(facility:GetDescendants()) do
                    if obj.Name == "ComputerTable" then
                        createHighlight(obj, Color3.fromRGB(0, 170, 255))
                        createBillboard(obj, "COMPUTER", Color3.fromRGB(0, 170, 255))
                    end
                end
            end
        end
    end
end)

WindUI:Notify({ Title = "IndraHub", Content = "Loaded Flee The Facility successfully!", Duration = 5 })
