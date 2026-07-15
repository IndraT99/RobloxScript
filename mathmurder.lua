--[[
================================================================================
IndraHub: Math Murder
================================================================================

Description:
    Math Murder auto-answer script. Automatically solves math questions displayed
    on the in-game screen and shows the answer when it's your turn to type.

Features & Functionality:
    - Auto Answer: Continuously monitors the question board and solves equations.
    - On-Screen Answer Display: Shows the answer prominently when it's your turn.
    - Solve Current: One-click button to solve the current question.
    - Heartbeat: Reports status to the IndraHub Games Supervisor for watchdog monitoring.
    - Discord Integration: Quick link to join the IndraHub Discord server.

Requirements:
    - Requires an executor that supports `getgenv`, `gethui`, and `game:HttpGet`.
    - Managed by IndraHub Games Supervisor. Do not execute manually if using the supervisor.
================================================================================
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GLOBAL HELPERS (Supervisor Integration)
-- ==========================================
local getGlobal = function(name)
    return getgenv and getgenv()[name] or _G[name]
end
local setGlobal = function(name, value)
    if getgenv then getgenv()[name] = value else _G[name] = value end
end

if getGlobal("IndraHubMathMurderRunning") then return end
setGlobal("IndraHubMathMurderRunning", true)

-- ==========================================
-- HEARTBEAT (Supervisor Watchdog)
-- ==========================================
task.spawn(function()
    while task.wait(2) do
        if not getGlobal("IndraHubMathMurderRunning") then break end
        setGlobal("IndraHubMathMurderLastHeartbeat", os.clock())
    end
end)

-- ==========================================
-- GAME REFERENCES
-- ==========================================
local Map = workspace:WaitForChild("Map")
local Functional = Map:WaitForChild("Functional")
local Screen = Functional:WaitForChild("Screen")
local SurfaceGui = Screen:WaitForChild("SurfaceGui")
local MainFrame = SurfaceGui:WaitForChild("MainFrame")
local MainGameContainer = MainFrame:WaitForChild("MainGameContainer")
local MainTxtContainer = MainGameContainer:WaitForChild("MainTxtContainer")
local QuestionText = MainTxtContainer:WaitForChild("QuestionText")
local TypingText = MainTxtContainer:WaitForChild("TypingText")

local GameValues = ReplicatedStorage:WaitForChild("GameValues")
local CurrentSpeller = GameValues:WaitForChild("CurrentSpeller")

-- ==========================================
-- WINDUI SETUP
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Math Murder",
    Icon = "calculator",
    Author = "IndraHub",
    Folder = "IndraHubMathMurder",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local TabMain = Window:Tab({ Title = "Main", Icon = "home" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- ON-SCREEN ANSWER DISPLAY
-- ==========================================
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local AnswerGui = Instance.new("ScreenGui")
AnswerGui.Name = "IndraHubMathMurderAnswer"
AnswerGui.ResetOnSpawn = false
AnswerGui.Parent = CoreGui

local AnswerLabel = Instance.new("TextLabel")
AnswerLabel.Name = "AnswerDisplay"
AnswerLabel.Size = UDim2.new(0, 300, 0, 150)
AnswerLabel.Position = UDim2.new(0.5, 0, 0.35, 0)
AnswerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
AnswerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AnswerLabel.BackgroundTransparency = 0.4
AnswerLabel.BorderSizePixel = 0
AnswerLabel.Font = Enum.Font.GothamBold
AnswerLabel.Text = ""
AnswerLabel.TextSize = 72
AnswerLabel.TextColor3 = Color3.fromRGB(130, 255, 100)
AnswerLabel.TextScaled = true
AnswerLabel.Visible = false
AnswerLabel.ZIndex = 100
AnswerLabel.Parent = AnswerGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = AnswerLabel

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(130, 255, 100)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = AnswerLabel

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 20)
UIPadding.PaddingRight = UDim.new(0, 20)
UIPadding.Parent = AnswerLabel

-- ==========================================
-- SETTINGS / STATE
-- ==========================================
local Settings = {
    AutoAnswer = false,
}

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================
local function isMyTurn()
    local speller = CurrentSpeller.Value
    return speller ~= nil and speller == LocalPlayer
end

local function showAnswer(answer)
    AnswerLabel.Text = answer
    AnswerLabel.Visible = true
end

local function hideAnswer()
    AnswerLabel.Visible = false
    AnswerLabel.Text = ""
end

local function solveQuestion(text)
    local expr = text:match("^(.-)%s*=%s*$")
    if not expr then return nil end
    expr = expr:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

    local luaExpr = expr
        :gsub("×", "*")
        :gsub("÷", "/")
        :gsub("x", "*")
        :gsub("X", "*")

    local fn = loadstring("return " .. luaExpr)
    if fn then
        local ok, result = pcall(fn)
        if ok and result then
            if result == math.floor(result) then
                return tostring(math.floor(result))
            else
                return tostring(math.floor(result * 100 + 0.5) / 100)
            end
        end
    end

    return nil
end

-- ==========================================
-- WINDUI TABS
-- ==========================================
TabMain:Toggle({
    Title = "Auto Answer",
    Desc = "Automatically solves math questions and shows the answer on screen",
    Default = false,
    Callback = function(state)
        Settings.AutoAnswer = state
        if not state then hideAnswer() end
        if state then
            WindUI:Notify({Title = "Math Murder", Content = "Auto Answer enabled", Duration = 2})
        end
    end
})

TabMain:Button({
    Title = "Solve Current",
    Desc = "Solve the current question on the board",
    Callback = function()
        local question = QuestionText.Text
        if question and question:find("=") then
            local answer = solveQuestion(question)
            if answer then
                WindUI:Notify({Title = "Solved", Content = question .. " " .. answer, Duration = 3})
                if isMyTurn() then
                    showAnswer(answer)
                end
            else
                WindUI:Notify({Title = "Error", Content = "Could not solve: " .. question, Duration = 3})
            end
        else
            WindUI:Notify({Title = "Error", Content = "No question found on screen", Duration = 3})
        end
    end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
TabSettings:Button({
    Title = "Join Discord",
    Desc = "https://discord.gg/2PPBJsmqr",
    Callback = function()
        if setclipboard then
            pcall(setclipboard, "https://discord.gg/2PPBJsmqr")
        end
        WindUI:Notify({Title = "Success", Content = "Discord invite copied to clipboard!"})
    end
})

TabSettings:Paragraph({
    Title = "About",
    Desc = "IndraHub Math Murder Script\nShows the answer on screen when it's your turn.\nType the displayed answer to submit.\n\nPowered by IndraHub"
})

-- ==========================================
-- AUTO ANSWER LOOP
-- ==========================================
local lastQuestion = ""
task.spawn(function()
    while task.wait(0.1) do
        if not getGlobal("IndraHubMathMurderRunning") then break end

        if Settings.AutoAnswer then
            local question = QuestionText.Text
            if question ~= lastQuestion and question ~= "" and question:find("=") then
                lastQuestion = question
                local answer = solveQuestion(question)
                if answer then
                    WindUI:Notify({Title = "Answer", Content = question .. " " .. answer, Duration = 2})
                    if isMyTurn() then
                        showAnswer(answer)
                    end
                end
            end

            if AnswerLabel.Visible and not isMyTurn() then
                hideAnswer()
            end
        else
            lastQuestion = ""
            hideAnswer()
        end
    end
end)

-- ==========================================
-- GAME EVENT CONNECTIONS
-- ==========================================
CurrentSpeller.Changed:Connect(function()
    if not isMyTurn() then
        hideAnswer()
    end
end)

QuestionText:GetPropertyChangedSignal("Text"):Connect(function()
    hideAnswer()
end)

-- ==========================================
-- STARTUP NOTIFICATION
-- ==========================================
WindUI:Notify({Title = "IndraHub", Content = "Math Murder script loaded!", Duration = 3})
