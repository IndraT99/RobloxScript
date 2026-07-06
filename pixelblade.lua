
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local env = getgenv and getgenv() or _G
local LocalPlayer = Players.LocalPlayer

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then return value end
    return env[key]
end

setGlobal("IndraHubPixelBladeRunning", true)
setGlobal("IndraHubPixelBladeLastHeartbeat", os.clock())
setGlobal("IndraHubPixelBladeError", nil)

task.spawn(function()
    while getGlobal("IndraHubPixelBladeRunning") do
        setGlobal("IndraHubPixelBladeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local state = {
    autoClick = false,
    autoInteract = false,
    autoNearest = false,
    autoSwing = false,
    autoParry = false,
    autoDash = false,
    autoBlock = false,
    autoHit = false,
    autoAbility = false,
    scanRadius = 300,
    damage = 9,
    stage = "Bootcamp",
    difficulty = "Normal",
    selectedRemote = nil,
}

local RemotesFolder = ReplicatedStorage:WaitForChild("remotes", 10)
local Remotes = {}
if RemotesFolder then
    for _, name in ipairs({
        "swing", "parry", "plrDash", "dodge", "block", "useAbility", "abilityHit",
        "onHit", "collectedSpirit", "levelStart", "levelComplete", "gameEndVote",
        "equipItem", "playPressed", "tpPlr", "playerTP", "requestSpin", "openLoot", "getProfile",
    }) do
        Remotes[name] = RemotesFolder:FindFirstChild(name)
    end
end

local CharacterFolder = ReplicatedStorage:FindFirstChild("Character")
if CharacterFolder then
    Remotes.characterDash = CharacterFolder:FindFirstChild("dash")
    Remotes.setSpeedStateRemote = CharacterFolder:FindFirstChild("setSpeedStateRemote")
end

local function notify(title, content)
    if env.IndraHubPixelBladeNotify then
        pcall(env.IndraHubPixelBladeNotify, title, content)
    else
        print("[IndraHub PixelBlade] " .. tostring(title) .. ": " .. tostring(content))
    end
end

local function loadRemoteSource(url, cacheName)
    if type(readfile) == "function" then
        local ok, cached = pcall(readfile, cacheName)
        if ok and type(cached) == "string" and #cached > 1000 then
            return cached
        end
    end
    local source = game:HttpGet(url)
    if type(writefile) == "function" then
        pcall(writefile, cacheName, source)
    end
    return source
end

local function pathOf(inst)
    local parts = {}
    local cur = inst
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(parts, ".")
end

local function rootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getWorld()
    return workspace:FindFirstChild("world") or workspace:FindFirstChild("World") or workspace
end

local function findNearestPart()
    local root = rootPart()
    if not root then return nil end
    local best, bestDist
    local world = getWorld()
    for _, inst in ipairs(world:GetDescendants()) do
        if inst:IsA("BasePart") and inst.CanCollide then
            local dist = (inst.Position - root.Position).Magnitude
            if dist <= state.scanRadius and (not bestDist or dist < bestDist) then
                best = inst
                bestDist = dist
            end
        end
    end
    return best, bestDist
end

local function findNearestEnemy()
    local root = rootPart()
    if not root then return nil end

    local best, bestDist
    for _, inst in ipairs(workspace:GetChildren()) do
        local humanoid = inst:FindFirstChildOfClass("Humanoid")
        local hrp = inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart
        if humanoid and hrp and humanoid.Health > 0 and inst ~= LocalPlayer.Character then
            local dist = (hrp.Position - root.Position).Magnitude
            local name = string.lower(inst.Name)
            if dist <= state.scanRadius and (string.find(name, "zombie") or not Players:FindFirstChild(inst.Name)) then
                if not bestDist or dist < bestDist then
                    best = inst
                    bestDist = dist
                end
            end
        end
    end
    return best, bestDist
end

local function tweenTo(part)
    local root = rootPart()
    if not root or not part then return end
    local target = part.CFrame + Vector3.new(0, 4, 0)
    local dist = (root.Position - target.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(math.clamp(dist / 90, 0.2, 4), Enum.EasingStyle.Linear), { CFrame = target })
    tween:Play()
    tween.Completed:Wait()
end

local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function clickCenter()
    local camera = workspace.CurrentCamera
    local size = camera and camera.ViewportSize or Vector2.new(800, 600)
    VirtualInputManager:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, true, game, 0)
    task.wait(0.03)
    VirtualInputManager:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, false, game, 0)
end

local function fireRemote(remote, ...)
    if not remote then return false end
    local ok, err = pcall(function(...)
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end, ...)
    if not ok then
        setGlobal("IndraHubPixelBladeError", tostring(err))
    end
    return ok
end

local function swing()
    if not fireRemote(Remotes.swing) then
        clickCenter()
    end
end

local function parry()
    if not fireRemote(Remotes.parry) then
        pressKey(Enum.KeyCode.F)
    end
end

local function dash()
    if not fireRemote(Remotes.plrDash, "ground") and not fireRemote(Remotes.characterDash) then
        pressKey(Enum.KeyCode.Q)
    end
end

local function block(value)
    if not fireRemote(Remotes.block, value) then
        pressKey(Enum.KeyCode.F)
    end
end

local function hitNearest()
    local enemy = findNearestEnemy()
    local humanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    swing()
    return fireRemote(Remotes.onHit, humanoid, state.damage, {}, 0)
end

local function useAbility()
    return fireRemote(Remotes.useAbility, "tornado")
end

local function selectStage()
    return fireRemote(Remotes.playerTP, state.stage, state.difficulty, true)
end

local function collectRemotes()
    local items = {}
    for _, root in ipairs({ ReplicatedStorage, workspace }) do
        for _, inst in ipairs(root:GetDescendants()) do
            if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
                items[#items + 1] = inst
            end
        end
    end
    table.sort(items, function(a, b) return pathOf(a) < pathOf(b) end)
    return items
end

local function loadWindUI()
    local ok, lib = pcall(function()
        return loadstring(loadRemoteSource("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_PixelBlade_WindUI.lua"))()
    end)
    if ok and type(lib) == "table" then
        return lib
    end
    return nil
end

local WindUI = loadWindUI()
if not WindUI then
    notify("UI", "WindUI failed; loops still available via globals")
else
    env.IndraHubPixelBladeNotify = function(title, content)
        pcall(WindUI.Notify, WindUI, {
            Title = title,
            Content = content,
            Icon = "swords",
            Duration = 4,
        })
    end

    local window = WindUI:CreateWindow({
        Title = "IndraHub",
        Author = "Pixel Blade",
        Folder = "IndraHubPixelBlade",
        Icon = "swords",
        Size = UDim2.fromOffset(560, 420),
        Theme = "Dark",
        Transparent = true,
        Resizable = true,
    })
    pcall(window.SetToggleKey, window, Enum.KeyCode.RightControl)
    pcall(window.EditOpenButton, window, { Title = "IndraHub", Icon = "swords", Draggable = true })

    local main = window:Tab({ Title = "Main", Icon = "play" })
    local stage = window:Tab({ Title = "Stage", Icon = "map" })
    local tools = window:Tab({ Title = "Tools", Icon = "wrench" })
    local info = window:Tab({ Title = "Info", Icon = "info" })

    main:Toggle({
        Title = "Auto Click",
        Default = false,
        Callback = function(value) state.autoClick = value end,
    })
    main:Toggle({
        Title = "Auto Swing Remote",
        Default = false,
        Callback = function(value) state.autoSwing = value end,
    })
    main:Toggle({
        Title = "Auto Hit Nearest",
        Default = false,
        Callback = function(value) state.autoHit = value end,
    })
    main:Toggle({
        Title = "Auto Tornado Ability",
        Default = false,
        Callback = function(value) state.autoAbility = value end,
    })
    main:Slider({
        Title = "Damage Arg",
        Value = { Min = 1, Max = 50, Default = state.damage },
        Callback = function(value) state.damage = tonumber(value) or state.damage end,
    })
    main:Toggle({
        Title = "Auto Parry",
        Default = false,
        Callback = function(value) state.autoParry = value end,
    })
    main:Toggle({
        Title = "Auto Dash",
        Default = false,
        Callback = function(value) state.autoDash = value end,
    })
    main:Toggle({
        Title = "Hold Block",
        Default = false,
        Callback = function(value)
            state.autoBlock = value
            block(value)
        end,
    })
    main:Toggle({
        Title = "Auto Interact (E)",
        Default = false,
        Callback = function(value) state.autoInteract = value end,
    })
    main:Toggle({
        Title = "Tween Nearest World Part",
        Default = false,
        Callback = function(value) state.autoNearest = value end,
    })
    main:Slider({
        Title = "Scan Radius",
        Value = { Min = 50, Max = 1000, Default = state.scanRadius },
        Callback = function(value) state.scanRadius = tonumber(value) or state.scanRadius end,
    })

    stage:Dropdown({
        Title = "Stage",
        Values = { "Bootcamp" },
        Value = state.stage,
        Callback = function(value) state.stage = tostring(value) end,
    })
    stage:Dropdown({
        Title = "Difficulty",
        Values = { "Normal", "Hard", "Nightmare" },
        Value = state.difficulty,
        Callback = function(value) state.difficulty = tostring(value) end,
    })
    stage:Button({
        Title = "Select Stage / Teleport",
        Callback = function()
            local ok = selectStage()
            notify("Stage", ok and (state.stage .. " / " .. state.difficulty) or "playerTP failed")
        end,
    })
    stage:Button({
        Title = "Auto Play Bootcamp Normal",
        Callback = function()
            state.stage = "Bootcamp"
            state.difficulty = "Normal"
            selectStage()
            task.wait(0.5)
            fireRemote(Remotes.playPressed)
            fireRemote(Remotes.levelStart)
            notify("Auto Play", "Bootcamp Normal fired")
        end,
    })

    tools:Button({
        Title = "Start Level / Play",
        Callback = function()
            selectStage()
            task.wait(0.3)
            fireRemote(Remotes.playPressed)
            fireRemote(Remotes.levelStart)
            notify("Level", "Start remotes fired")
        end,
    })
    tools:Button({
        Title = "Collect Spirits",
        Callback = function()
            fireRemote(Remotes.collectedSpirit)
            notify("Spirits", "Collect remote fired")
        end,
    })
    tools:Button({
        Title = "Use Ability",
        Callback = function()
            useAbility()
            notify("Ability", "Use remote fired")
        end,
    })
    tools:Button({
        Title = "Hit Nearest Enemy",
        Callback = function()
            local ok = hitNearest()
            notify("Hit", ok and "onHit fired" or "No enemy found")
        end,
    })
    tools:Button({
        Title = "Print Remotes",
        Callback = function()
            for _, remote in ipairs(collectRemotes()) do
                print("[PixelBlade Remote] " .. pathOf(remote) .. " <" .. remote.ClassName .. ">")
            end
            notify("Remotes", "Printed to console")
        end,
    })
    tools:Button({
        Title = "Run Dumper",
        Callback = function()
            loadstring(readfile and readfile("active/dump_pixelblade.lua") or game:HttpGet("https://raw.githubusercontent.com/IndraT99/RobloxScript/refs/heads/main/active/dump_pixelblade.lua"))()
        end,
    })
    tools:Button({
        Title = "Queue On Teleport",
        Callback = function()
            if type(queue_on_teleport) == "function" then
                queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/IndraT99/RobloxScript/refs/heads/main/active/pixelblade.lua'))()")
                notify("Queue", "Queued")
            else
                notify("Queue", "Executor does not support queue_on_teleport")
            end
        end,
    })
    info:Paragraph({
        Title = "Status",
        Desc = "Reconstructed from partial Prometheus trace. Run dumper to capture exact remotes/actions.",
    })
end

task.spawn(function()
    while getGlobal("IndraHubPixelBladeRunning") do
        setGlobal("IndraHubPixelBladeLastHeartbeat", os.clock())
        local ok, err = pcall(function()
            if state.autoClick then
                clickCenter()
            end
            if state.autoSwing then
                swing()
            end
            if state.autoHit then
                hitNearest()
            end
            if state.autoAbility then
                useAbility()
            end
            if state.autoParry then
                parry()
            end
            if state.autoDash then
                dash()
            end
            if state.autoBlock then
                fireRemote(Remotes.block, true)
            end
            if state.autoInteract then
                pressKey(Enum.KeyCode.E)
            end
            if state.autoNearest then
                local part = findNearestPart()
                if part then tweenTo(part) end
            end
        end)
        if not ok then
            setGlobal("IndraHubPixelBladeError", tostring(err))
            warn("[IndraHub PixelBlade]", err)
        end
        task.wait(0.25)
    end
end)

env.IndraHubPixelBladeStop = function()
    setGlobal("IndraHubPixelBladeRunning", false)
    notify("PixelBlade", "Stopped")
end

notify("PixelBlade", "Loaded reconstructed shell")
