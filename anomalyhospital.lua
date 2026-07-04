-- IndraHub Hospital - WindUI
-- Features: anti sanity, anomaly ESP, cash visual-only spoof.

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local unpackArgs = table.unpack or unpack

local env = getgenv and getgenv() or _G
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
env.IndraHubHospitalRunning = true
env.IndraHubHospitalSession = sessionId
env.IndraHubHospitalLastHeartbeat = os.clock()
env.IndraHubHospitalError = nil

local state = {
    antiSanity = false,
    sanityMode = "zero",
    sanityValue = 100,
    anomalyEsp = false,
    cashVisual = false,
    cashValue = 999999,
    localCashValue = 999999,
    unlockMouse = false,
    mouseKey = Enum.KeyCode.LeftControl,
}

local espFolder = CoreGui:FindFirstChild("IndraHubHospitalAnomalyESP")
if espFolder then espFolder:Destroy() end
espFolder = Instance.new("Folder")
espFolder.Name = "IndraHubHospitalAnomalyESP"
espFolder.Parent = CoreGui

local trackedEsp = {}
local sanityHooked = false
local originalMouseBehavior = UserInputService.MouseBehavior
local originalMouseIconEnabled = UserInputService.MouseIconEnabled

task.spawn(function()
    while env.IndraHubHospitalRunning and env.IndraHubHospitalSession == sessionId do
        env.IndraHubHospitalLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local function notify(title, content, icon)
    if env.IndraHubHospitalWindUI and type(env.IndraHubHospitalWindUI.Notify) == "function" then
        pcall(function()
            env.IndraHubHospitalWindUI:Notify({Title = title, Content = content, Icon = icon or "info", Duration = 3})
        end)
    else
        print("[IndraHub] " .. tostring(title) .. ": " .. tostring(content))
    end
end

local function findRemote(name)
    local util = ReplicatedStorage:FindFirstChild("Util")
    local net = util and util:FindFirstChild("Net")
    local root = net or ReplicatedStorage
    for _, inst in ipairs(root:GetDescendants()) do
        if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) and inst.Name == name then return inst end
    end
    for _, inst in ipairs(root:GetDescendants()) do
        if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) and string.find(inst.Name, name, 1, true) then return inst end
    end
    return nil
end

local function setText(path, value)
    local current = PlayerGui
    for _, name in ipairs(path) do
        current = current and current:FindFirstChild(name)
        if not current then return false end
    end
    if current:IsA("TextLabel") or current:IsA("TextButton") or current:IsA("TextBox") then
        current.Text = tostring(value)
        return true
    end
    return false
end

local function applySanityUi()
    setText({"Sanity", "Frame", "Frame", "textbox", "amount"}, tostring(state.sanityValue) .. "%")
end

local function applyCashUi()
    setText({"Sanity", "Frame", "cash"}, "$" .. tostring(state.localCashValue))
    setText({"Coins", "coins"}, "$" .. tostring(state.cashValue))
    setText({"RoundStatsDetailed", "Frame", "Info", "cash"}, tostring(state.cashValue))
    setText({"RoundStatsDetailed", "Frame", "Info", "localcash"}, "$" .. tostring(state.localCashValue))
    setText({"RoundStatsDetailed", "Frame", "bonus", "cash"}, "$" .. tostring(state.localCashValue))
end

local function hookSanityRemote()
    if sanityHooked then return end
    local remote = findRemote("PlayerLostSanity")
    if not remote then
        notify("Anti Sanity", "PlayerLostSanity remote not found", "triangle-alert")
        return
    end

    local mt = getrawmetatable and getrawmetatable(game)
    if not mt or not setreadonly or not newcclosure or not getnamecallmethod then
        notify("Anti Sanity", "Remote hook unsupported", "triangle-alert")
        return
    end

    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if state.antiSanity and self == remote and method == "FireServer" then
            local args = {...}
            if state.sanityMode == "block" then return nil end
            args[1] = 0
            return oldNamecall(self, unpackArgs(args))
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    sanityHooked = true
end

local espKeywords = {"anomaly", "monster", "stalker", "npc", "enemy", "creature", "jojo", "nurse", "bed"}

local function matchesEspName(name)
    name = string.lower(tostring(name or ""))
    for _, keyword in ipairs(espKeywords) do
        if string.find(name, keyword, 1, true) then return true end
    end
    return false
end

local function getRoot(model)
    return model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true))
end

local function getDistance(model)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local root = getRoot(model)
    if not hrp or not root then return nil end
    return math.floor((hrp.Position - root.Position).Magnitude)
end

local function isEspCandidate(inst)
    if not inst:IsA("Model") or inst == LocalPlayer.Character then return false end
    if matchesEspName(inst.Name) then return true end
    if inst:FindFirstChildOfClass("Humanoid") or inst:FindFirstChildOfClass("AnimationController") then
        local parent = inst.Parent
        return parent and (parent.Name == "NPCs" or parent.Name == "Misc" or matchesEspName(parent.Name))
    end
    return false
end

local function addEsp(model)
    if trackedEsp[model] or not getRoot(model) then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "IndraHubAnomalyHighlight"
    highlight.FillColor = Color3.fromRGB(255, 60, 90)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.55
    highlight.Adornee = model
    highlight.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "IndraHubAnomalyBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(190, 42)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = getRoot(model)
    billboard.Parent = espFolder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.25
    label.TextColor3 = Color3.fromRGB(255, 235, 235)
    label.Parent = billboard

    trackedEsp[model] = {highlight = highlight, billboard = billboard, label = label}
end

local function clearEsp()
    for model, data in pairs(trackedEsp) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        trackedEsp[model] = nil
    end
end

local function scanEsp()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if isEspCandidate(inst) then addEsp(inst) end
    end
end

Workspace.DescendantAdded:Connect(function(inst)
    task.defer(function()
        if state.anomalyEsp and isEspCandidate(inst) then addEsp(inst) end
    end)
end)

Workspace.DescendantRemoving:Connect(function(inst)
    local data = trackedEsp[inst]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        trackedEsp[inst] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == state.mouseKey then
        state.unlockMouse = not state.unlockMouse
        UserInputService.MouseIconEnabled = state.unlockMouse or originalMouseIconEnabled
        UserInputService.MouseBehavior = state.unlockMouse and Enum.MouseBehavior.Default or originalMouseBehavior
        notify("Unlock Mouse", state.unlockMouse and "Enabled" or "Disabled", "mouse-pointer")
    end
end)

RunService.RenderStepped:Connect(function()
    if state.antiSanity then applySanityUi() end
    if state.cashVisual then applyCashUi() end
    if state.unlockMouse then
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    if not state.anomalyEsp then return end
    for model, data in pairs(trackedEsp) do
        if not model.Parent then
            trackedEsp[model] = nil
        else
            local root = getRoot(model)
            local distance = getDistance(model)
            if root and data.billboard then data.billboard.Adornee = root end
            if data.label then data.label.Text = model.Name .. (distance and (" [" .. distance .. "m]") or "") end
        end
    end
end)

local function loadWindUI()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end

local okWind, WindUI = pcall(loadWindUI)
if not okWind or type(WindUI) ~= "table" then
    warn("[IndraHub Hospital] WindUI load failed: " .. tostring(WindUI))
    return
end
env.IndraHubHospitalWindUI = WindUI

if env.IndraHubHospitalWindow then pcall(function() env.IndraHubHospitalWindow:Destroy() end) end

local Window = WindUI:CreateWindow({
    Title = "IndraHub",
    Icon = "hospital",
    Author = "Hospital",
    Folder = "IndraHubHospital",
    Size = UDim2.fromOffset(560, 410),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 160,
})
env.IndraHubHospitalWindow = Window
if Window.SetToggleKey then Window:SetToggleKey(Enum.KeyCode.RightControl) end
if Window.EditOpenButton then Window:EditOpenButton({Title = "IndraHub", Icon = "hospital", Draggable = true}) end

local Tabs = {
    Main = Window:Tab({Title = "Main", Icon = "shield"}),
    Visual = Window:Tab({Title = "Visual", Icon = "eye"}),
    Cash = Window:Tab({Title = "Cash", Icon = "coins"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}),
    Info = Window:Tab({Title = "Info", Icon = "info"}),
}

Tabs.Main:Toggle({
    Title = "Block Sanity Loss",
    Desc = "Intercepts PlayerLostSanity and locks sanity UI.",
    Value = state.antiSanity,
    Callback = function(value)
        state.antiSanity = value
        if value then hookSanityRemote(); applySanityUi() end
        notify("Anti Sanity", value and "Enabled" or "Disabled", value and "shield-check" or "shield-x")
    end,
})

Tabs.Main:Dropdown({
    Title = "Sanity Remote Mode",
    Values = {"zero", "block"},
    Value = state.sanityMode,
    Callback = function(value)
        state.sanityMode = value
    end,
})

Tabs.Main:Input({
    Title = "Sanity UI Value",
    Value = tostring(state.sanityValue),
    Callback = function(value)
        state.sanityValue = tonumber(value) or state.sanityValue
        applySanityUi()
    end,
})

Tabs.Visual:Toggle({
    Title = "Anomaly ESP",
    Desc = "Highlights likely anomalies/NPCs with name + distance.",
    Value = state.anomalyEsp,
    Callback = function(value)
        state.anomalyEsp = value
        if value then scanEsp() else clearEsp() end
        notify("Anomaly ESP", value and "Enabled" or "Disabled", "eye")
    end,
})

Tabs.Visual:Button({
    Title = "Rescan Anomalies",
    Callback = function()
        clearEsp()
        scanEsp()
        notify("Anomaly ESP", "Rescan complete", "search")
    end,
})

Tabs.Cash:Toggle({
    Title = "Cash Visual Only",
    Desc = "Spoofs local UI only. Server cash is unchanged.",
    Value = state.cashVisual,
    Callback = function(value)
        state.cashVisual = value
        if value then applyCashUi() end
        notify("Cash Visual", value and "Enabled" or "Disabled", "coins")
    end,
})

Tabs.Cash:Input({
    Title = "Total Cash UI",
    Value = tostring(state.cashValue),
    Callback = function(value)
        state.cashValue = tonumber(value) or state.cashValue
        applyCashUi()
    end,
})

Tabs.Cash:Input({
    Title = "Round Cash UI",
    Value = tostring(state.localCashValue),
    Callback = function(value)
        state.localCashValue = tonumber(value) or state.localCashValue
        applyCashUi()
    end,
})

Tabs.Settings:Toggle({
    Title = "Unlock Mouse",
    Desc = "Forces visible cursor + default mouse behavior.",
    Value = state.unlockMouse,
    Callback = function(value)
        state.unlockMouse = value
        UserInputService.MouseIconEnabled = value or originalMouseIconEnabled
        UserInputService.MouseBehavior = value and Enum.MouseBehavior.Default or originalMouseBehavior
        notify("Unlock Mouse", value and "Enabled" or "Disabled", "mouse-pointer")
    end,
})

Tabs.Settings:Dropdown({
    Title = "Unlock Mouse Key",
    Values = {"LeftControl", "RightControl", "LeftAlt", "RightAlt", "V", "B", "M"},
    Value = state.mouseKey.Name,
    Callback = function(value)
        local key = Enum.KeyCode[value]
        if key then
            state.mouseKey = key
            notify("Mouse Key", tostring(value), "keyboard")
        end
    end,
})

if Tabs.Info.Paragraph then
    Tabs.Info:Paragraph({
        Title = "Cash Note",
        Desc = "Cash feature is visual only. Game sends real cash from server via Stats/DisplayRoundStats.",
    })
    Tabs.Info:Paragraph({
        Title = "Detected Remotes",
        Desc = "Sanity loss: ReplicatedStorage.Util.Net.RE/PlayerLostSanity. Cash stats: RE/Stats and RE/DisplayRoundStats.",
    })
else
    Tabs.Info:Button({Title = "Cash is visual only", Callback = function() notify("Cash", "Server cash is unchanged", "coins") end})
    Tabs.Info:Button({Title = "Detected remotes", Callback = function() notify("Remotes", "PlayerLostSanity, Stats, DisplayRoundStats", "info") end})
end

if Window.SelectTab then Window:SelectTab(1) end
notify("IndraHub", "Hospital loaded", "hospital")
