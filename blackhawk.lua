local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end

local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

-- Supervisor Check
if getGlobal("IndraHubBlackhawkRunning") then
    return
end
setGlobal("IndraHubBlackhawkRunning", true)

task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubBlackhawkRunning") then break end
        setGlobal("IndraHubBlackhawkLastHeartbeat", os.time())
    end
end)

-- WindUI Initialization
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Blackhawk",
    Icon = "radar",
    Author = "IndraHub",
    Folder = "IndraHubBlackhawk",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Variables
local ESPEnabled = false
local ESPMode = "Outline" -- "Outline", "Fill", "Wall"
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPTransparency = 0.5
local CrosshairEnabled = false
local DisableNVG = false

-- Crosshair Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IndraHubBlackhawkGUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local crosshairH = Instance.new("Frame")
crosshairH.Size = UDim2.new(0, 20, 0, 1)
crosshairH.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairH.BackgroundColor3 = Color3.new(1,1,1)
crosshairH.BorderSizePixel = 0
crosshairH.Parent = screenGui
crosshairH.Visible = false

local crosshairV = Instance.new("Frame")
crosshairV.Size = UDim2.new(0, 1, 0, 20)
crosshairV.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairV.BackgroundColor3 = Color3.new(1,1,1)
crosshairV.BorderSizePixel = 0
crosshairV.Parent = screenGui
crosshairV.Visible = false

local function updateCrosshair()
    local invertedColor = Color3.new(1 - ESPColor.R, 1 - ESPColor.G, 1 - ESPColor.B)
    crosshairH.BackgroundColor3 = invertedColor
    crosshairV.BackgroundColor3 = invertedColor
    crosshairH.Visible = CrosshairEnabled
    crosshairV.Visible = CrosshairEnabled
end

-- ESP Logic
local highlightedObjects = {}
local maxHighlights = 200
local highlightCount = 0

local function applyHighlightStyle(highlight)
    if ESPMode == "Fill" then
        highlight.OutlineTransparency = 1
        highlight.FillTransparency = ESPTransparency
        highlight.FillColor = ESPColor
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    elseif ESPMode == "Wall" then
        highlight.OutlineTransparency = 1
        highlight.FillTransparency = ESPTransparency
        highlight.FillColor = ESPColor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    elseif ESPMode == "Outline" then
        highlight.OutlineTransparency = 0.8
        highlight.FillTransparency = 1
        highlight.OutlineColor = ESPColor
    end
end

local function isValidObject(obj)
    return obj.Name == "Male" and obj:FindFirstChild("Humanoid")
end

local function addHighlight(obj)
    if highlightCount < maxHighlights and not highlightedObjects[obj] and isValidObject(obj) then
        highlightedObjects[obj] = true
        highlightCount = highlightCount + 1
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "IndraHubESP"
        highlight.Parent = obj
        highlight.Adornee = obj
        highlight.Enabled = ESPEnabled
        applyHighlightStyle(highlight)
    end
end

local function removeHighlight(obj)
    if highlightedObjects[obj] then
        highlightedObjects[obj] = nil
        highlightCount = highlightCount - 1
        local highlight = obj:FindFirstChild("IndraHubESP")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function updateHighlights()
    for obj in pairs(highlightedObjects) do
        if not obj or not obj.Parent then
            highlightedObjects[obj] = nil
            highlightCount = highlightCount - 1
            continue
        end
        local highlight = obj:FindFirstChild("IndraHubESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "IndraHubESP"
            highlight.Parent = obj
            highlight.Adornee = obj
        end
        highlight.Enabled = ESPEnabled
        if ESPEnabled then
            applyHighlightStyle(highlight)
        end
    end
end

-- Initial ESP Scan
task.spawn(function()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        addHighlight(desc)
    end
end)

local descAddedConn = Workspace.DescendantAdded:Connect(function(desc)
    addHighlight(desc)
end)

local descRemovingConn = Workspace.DescendantRemoving:Connect(function(desc)
    removeHighlight(desc)
end)

-- NVG / ColorCorrection Logic
local function getColorCorrection()
    local effect = Lighting:FindFirstChild("ColorCorrection")
    if effect and effect:IsA("ColorCorrectionEffect") then
        return effect
    end
    return Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
end

local function updateNVG()
    local nvgInterface = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NVGInterface")
    if nvgInterface then
        nvgInterface.Enabled = not DisableNVG
    end
    local colorCorrection = getColorCorrection()
    if colorCorrection then
        colorCorrection.Enabled = not DisableNVG
    end
end

-- Heartbeat checks
task.spawn(function()
    while task.wait(1) do
        if DisableNVG then
            updateNVG()
        end
    end
end)

-- WindUI Tabs
local TabESP = Window:Tab({Title = "ESP Visuals", Icon = "eye"})
local TabCombat = Window:Tab({Title = "Combat & Visuals", Icon = "crosshair"})

TabESP:Toggle({
    Title = "Enable ESP",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        updateHighlights()
    end
})

TabESP:Dropdown({
    Title = "ESP Mode",
    Values = {"Outline", "Fill", "Wall"},
    Default = "Outline",
    Callback = function(value)
        ESPMode = value
        updateHighlights()
    end
})

TabESP:Colorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        ESPColor = color
        updateHighlights()
        updateCrosshair()
    end
})

TabESP:Slider({
    Title = "Fill Transparency",
    Step = 0.1,
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.5
    },
    Callback = function(value)
        ESPTransparency = value
        updateHighlights()
    end
})

TabCombat:Toggle({
    Title = "Crosshair",
    Default = false,
    Callback = function(state)
        CrosshairEnabled = state
        updateCrosshair()
    end
})

TabCombat:Toggle({
    Title = "Disable NVG & Color Correction",
    Default = false,
    Callback = function(state)
        DisableNVG = state
        updateNVG()
    end
})

-- Handle cleanup when script is disabled
task.spawn(function()
    while task.wait(1) do
        if not getGlobal("IndraHubBlackhawkRunning") then
            descAddedConn:Disconnect()
            descRemovingConn:Disconnect()
            for obj in pairs(highlightedObjects) do
                local h = obj:FindFirstChild("IndraHubESP")
                if h then h:Destroy() end
            end
            screenGui:Destroy()
            break
        end
    end
end)
