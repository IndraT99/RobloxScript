-- [[ IndraHub: Ninja Legends ]] --

local env = getgenv and getgenv() or _G
local getgenv = getgenv or function() return env end
local sessionId = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then return value end
    return env[key]
end

setGlobal("IndraHubNinjaLegendRunning", true)
setGlobal("IndraHubNinjaLegendSession", sessionId)
setGlobal("IndraHubNinjaLegendLastHeartbeat", os.clock())
setGlobal("IndraHubNinjaLegendError", nil)

local function running()
    return getGlobal("IndraHubNinjaLegendRunning") and getGlobal("IndraHubNinjaLegendSession") == sessionId
end

task.spawn(function()
    while running() do
        setGlobal("IndraHubNinjaLegendLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local function fetch(url, cache)
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, cache)
        if ok and type(data) == "string" and #data > 1000 then return data end
    end
    local data = game:HttpGet(url)
    if type(writefile) == "function" then pcall(function() writefile(cache, data) end) end
    return data
end

local okWind, WindUI = pcall(function()
    return loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_NinjaLegend_WindUI.lua"))()
end)

if not okWind or type(WindUI) ~= "table" then
    setGlobal("IndraHubNinjaLegendError", "WINDUI FAIL")
    setGlobal("IndraHubNinjaLegendRunning", false)
    warn("[IndraHub Ninja Legends] WindUI load failed: " .. tostring(WindUI))
    return
end

local Library = {}

function Library.CreateLib()
    local oldWindow = env.IndraHubNinjaLegendWindow
    if oldWindow then pcall(function() oldWindow:Destroy() end) end

    local window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "swords",
        Author = "Ninja Legends",
        Folder = "IndraHubNinjaLegend",
        Size = UDim2.fromOffset(580, 520),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 160,
    })
    env.IndraHubNinjaLegendWindow = window
    pcall(function() window:SetToggleKey(Enum.KeyCode.RightControl) end)
    pcall(function() window:EditOpenButton({ Title = "IndraHub", Icon = "swords", Draggable = true }) end)

    function window:NewTab(name)
        local tab = window:Tab({ Title = name, Icon = "circle" })

        function tab:NewSection(sectionTitle)
            if tab.Section then pcall(function() tab:Section({ Title = sectionTitle, Icon = "minus" }) end) end
            local section = {}

            function section:NewToggle(toggleTitle, description, callback)
                return tab:Toggle({
                    Title = toggleTitle,
                    Desc = description or "",
                    Value = false,
                    Callback = callback,
                })
            end

            function section:NewButton(buttonTitle, description, callback)
                return tab:Button({
                    Title = buttonTitle,
                    Desc = description or "",
                    Callback = callback,
                })
            end

            function section:NewSlider(sliderTitle, description, maxValue, minValue, callback)
                return tab:Slider({
                    Title = sliderTitle,
                    Desc = description or "",
                    Value = { Min = minValue or 0, Max = maxValue or 100, Default = minValue or 0 },
                    Step = 1,
                    Callback = callback,
                })
            end

            return section
        end

        return tab
    end

    return window
end

local Window = Library.CreateLib()

-- [[ TABS ]] --
local Main = Window:NewTab("Main")
local Elements = Window:NewTab("Elements")
local Chests = Window:NewTab("Chests")
local Combat = Window:NewTab("Combat")
local Misc = Window:NewTab("Misc")

-- [[ SECTIONS ]] --
local MainSection = Main:NewSection("Auto Farm")
local ElementsSection = Elements:NewSection("Auto Buy Elements")
local ChestsSection = Chests:NewSection("Auto Collect Chests")
local CombatSection = Combat:NewSection("Combat Utilities")
local MiscSection = Misc:NewSection("Miscellaneous")

-- [[ VARIABLES ]] --
getgenv().AutoSwing = false
getgenv().AutoSell = false
getgenv().AutoBuyNinjutsu = false
getgenv().AutoBuySwords = false
getgenv().AutoBuyRank = false
getgenv().AutoBuyBelts = false
getgenv().AutoBuyShurikens = false
getgenv().AutoEvolvePets = false
getgenv().AutoElements = false
getgenv().AutoChests = false

-- [[ MAIN FUNCTIONS ]] --

-- Auto Swing (Авто-удары)
MainSection:NewToggle("Auto Swing", "Automatically swings your weapon", function(state)
    getgenv().AutoSwing = state
    task.spawn(function()
        while running() and getgenv().AutoSwing do
            local args = { [1] = "swingNinjaWeapon" }
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

-- Auto Sell (Авто-продажа)
MainSection:NewToggle("Auto Sell", "Automatically sells your ninjutsu", function(state)
    getgenv().AutoSell = state
    task.spawn(function()
        while running() and getgenv().AutoSell do
            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Телепорт на спавн-зону продажи для надежности
                local currentPos = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 3, 0) -- Стандартные координаты Sell
                task.wait(0.2)
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
            end
            task.wait(1)
        end
    end)
end)

-- Auto Buy Swords (Авто-покупка мечей)
MainSection:NewToggle("Auto Buy Swords", "Automatically buys the next sword", function(state)
    getgenv().AutoBuySwords = state
    task.spawn(function()
        while running() and getgenv().AutoBuySwords do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyNextSword")
            task.wait(0.5)
        end
    end)
end)

-- Auto Buy Belts (Авто-покупка поясов)
MainSection:NewToggle("Auto Buy Belts", "Automatically buys the next belt", function(state)
    getgenv().AutoBuyBelts = state
    task.spawn(function()
        while running() and getgenv().AutoBuyBelts do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyNextBelt")
            task.wait(0.5)
        end
    end)
end)

-- Auto Buy Ranks (Авто-покупка рангов)
MainSection:NewToggle("Auto Buy Ranks", "Automatically buys the next rank", function(state)
    getgenv().AutoBuyRank = state
    task.spawn(function()
        while running() and getgenv().AutoBuyRank do
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyNextRank")
            task.wait(0.8)
        end
    end)
end)

-- [[ ELEMENTS TAB ]] --
ElementsSection:NewToggle("Auto Unlock Elements", "Unlocks all elements automatically", function(state)
    getgenv().AutoElements = state
    task.spawn(function()
        local elements = {"Inferno", "Frost", "Lightning", "Shadow", "Mastery"}
        while running() and getgenv().AutoElements do
            for _, element in pairs(elements) do
                game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("unlockElement", element)
            end
            task.wait(2)
        end
    end)
end)

-- [[ CHESTS TAB ]] --
ChestsSection:NewToggle("Auto Collect All Chests", "Teleports and collects all map chests", function(state)
    getgenv().AutoChests = state
    task.spawn(function()
        while running() and getgenv().AutoChests do
            local chests = game:GetService("Workspace"):FindFirstChild("ChestRewards")
            if chests then
                for _, chest in pairs(chests:GetChildren()) do
                    if chest:FindFirstChild("circleInner") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = chest.circleInner.CFrame
                        task.wait(0.3)
                    end
                end
            end
            task.wait(10) -- Интервал проверки сундуков
        end
    end)
end)

-- [[ COMBAT TAB ]] --
CombatSection:NewButton("Kill All (Requires Weapon)", "Attacks nearby players", function()
    local localPlayer = game:GetService("Players").LocalPlayer
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Логика хитбокса / атаки игрока
            local args = {
                [1] = "strikePlayer",
                [2] = player.Character.HumanoidRootPart
            }
            localPlayer.ninjaEvent:FireServer(unpack(args))
        end
    end
end)

-- [[ MISC TAB ]] --
MiscSection:NewSlider("WalkSpeed", "Changes your character speed", 250, 16, function(s)
    game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

MiscSection:NewSlider("JumpPower", "Changes your jump power", 300, 50, function(s)
    game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = s
end)

MiscSection:NewButton("Unlock All Islands", "Teleports to all islands once to unlock them", function()
    local islands = game:GetService("Workspace"):FindFirstChild("IslandBoards")
    if islands then
        for _, island in pairs(islands:GetChildren()) do
            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = island.CFrame + Vector3.new(0, 10, 0)
                task.wait(0.5)
            end
        end
    end
end)
