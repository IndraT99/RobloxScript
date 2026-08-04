local genv = (getgenv and getgenv()) or _G
if genv.__INDRA_CLEANUP then
    pcall(genv.__INDRA_CLEANUP)
    task.wait(0.1)
end

-- Services
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local marketplaceService = game:GetService("MarketplaceService")
local guiService = game:GetService("GuiService")
local virtualInputManager = game:GetService("VirtualInputManager")
local virtualUser = game:GetService("VirtualUser")

local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 15)
if not playerGui then return end
local camera = workspace.CurrentCamera

-- lobby check: this script only makes sense inside the real game
local TARGET_PLACE_ID = 111304265646194
local indraInLobby = false
local okInfo, productInfo = pcall(function()
    return marketplaceService:GetProductInfo(game.PlaceId)
end)
if okInfo and productInfo and productInfo.Name then
    local n = string.lower(productInfo.Name)
    if string.find(n, "lobby") or string.find(n, "start") or string.find(n, "menu") then
        indraInLobby = true
    end
end
if game.PlaceId == TARGET_PLACE_ID then
    indraInLobby = false
end

-- kill switch: cleanup flips this, every loop bails out
local indraUnloaded = false

-- State Variables
local indraState = {
    anomaliesESP = false,
    patientsESP = false,
    itemsESP = false,
    playerESP = false,
    drawLines = false,
    infSanity = false,
    thirdPerson = false,
    fasterActions = false,
    autoMinigames = false,
    autoTasks = false,
    autoHeal = false,
    mouseFree = false,
    antiAfk = true,
    speed = 16,
}

local indraHighlights = {}
local indraLines = {}
local indraMgClicked = {}
local indraMgQueue = {}
local indraSanityConns = {}
local indraHelperParts = {}

local indraConnections = {}
local function track(conn) table.insert(indraConnections, conn) return conn end

local function indraNotify(t, c, d)
    pcall(function()
        WindUI:Notify({ Title = t, Content = c, Duration = d or 3 })
    end)
end

-- character helpers
local function indraGetChar() return localPlayer.Character end
local function indraGetRoot()
    local c = indraGetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function indraGetHumanoid()
    local c = indraGetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ==========================================
-- ANOMALY DETECTOR
-- skinwalkers can't hide: attribute flags, camera effects,
-- and the classic face-swap tell
-- ==========================================
local function isAnomaly(model)
    if model:GetAttribute("Always Patient") == true then return false end
    if model:GetAttribute("Skinwalker") == true
        or model:GetAttribute("SkinwalkerEasy") == true
        or model:GetAttribute("PenaltyWhenLettingIn") == true
        or model:GetAttribute("HasCameraEffect") == true then
        return true
    end
    local camFx = model:GetAttribute("Camera Effect")
    local photoFx = model:GetAttribute("Photo Effect")
    if (camFx and camFx ~= "" and camFx ~= "None")
        or (photoFx and photoFx ~= "" and photoFx ~= "None") then
        return true
    end
    local originalFace = model:GetAttribute("OriginalFace")
    local head = model:FindFirstChild("Head")
    local decal = head and head:FindFirstChildOfClass("Decal")
    if originalFace and decal then
        if tostring(decal.Texture) ~= tostring(originalFace) then
            return true
        end
    end
    return false
end

-- ==========================================
-- ESP HIGHLIGHTS (cached: create once, recolor cheap)
-- ==========================================
local function indraApplyHighlight(indraTarget, fillColor, espType)
    if not indraTarget or not indraTarget.Parent then return end
    if indraHighlights[indraTarget] then
        indraHighlights[indraTarget].FillColor = fillColor
        indraHighlights[indraTarget]:SetAttribute("ESPType", espType)
        return
    end
    local hl = Instance.new("Highlight")
    hl.FillColor = fillColor
    hl.FillTransparency = 0.4
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Adornee = indraTarget
    hl:SetAttribute("ESPType", espType)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- glow through walls
    hl.Parent = indraTarget
    indraHighlights[indraTarget] = hl
end

local function indraClearESP(espType)
    for indraTarget, hl in pairs(indraHighlights) do
        if hl and hl.Parent and hl:GetAttribute("ESPType") == espType then
            hl:Destroy()
            indraHighlights[indraTarget] = nil
        end
    end
end

local function indraApplyObjHL(part, fillColor)
    if not part or not part.Parent then return end
    local indraTarget = (part:IsA("Model") and part) or part.Parent
    indraApplyHighlight(indraTarget, fillColor, "ObjectItem")
end

-- ==========================================
-- ESP DRAW LINES (screen-bottom beams to targets)
-- ==========================================
local indraLineGui = Instance.new("ScreenGui")
indraLineGui.Name = "IndraHubAH_Lines"
indraLineGui.ResetOnSpawn = false
indraLineGui.IgnoreGuiInset = true
indraLineGui.DisplayOrder = 9999
indraLineGui.Parent = playerGui

local function indraAddLine(indraTarget, color)
    if not indraTarget or not indraTarget.Parent then return end
    if indraLines[indraTarget] then
        indraLines[indraTarget].Frame.BackgroundColor3 = color
        return
    end
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = color
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Visible = false
    frame.Parent = indraLineGui
    indraLines[indraTarget] = { Frame = frame }
end

local function indraClearAllLines()
    for _, entry in pairs(indraLines) do
        if entry.Frame then entry.Frame:Destroy() end
    end
    indraLines = {}
end

local function indraClearLine(indraTarget)
    if indraLines[indraTarget] then
        if indraLines[indraTarget].Frame then
            indraLines[indraTarget].Frame:Destroy()
        end
        indraLines[indraTarget] = nil
    end
end

-- line projector (every frame but EARLY-OUT when lines are off)
track(runService.RenderStepped:Connect(function()
    if indraUnloaded then return end
    if not indraState.drawLines then
        if next(indraLines) then indraClearAllLines() end
        return
    end
    local vpSize = camera.ViewportSize
    local screenBottom = Vector2.new(vpSize.X / 2, vpSize.Y)
    for indraTarget, entry in pairs(indraLines) do
        if not indraTarget or not indraTarget.Parent then
            indraClearLine(indraTarget)
        else
            local part = nil
            if indraTarget:IsA("Model") then
                part = indraTarget:FindFirstChild("HumanoidRootPart")
                    or indraTarget:FindFirstChildWhichIsA("BasePart")
            elseif indraTarget:IsA("BasePart") then
                part = indraTarget
            end
            if part and part.Parent and part:IsDescendantOf(workspace) then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local target2D = Vector2.new(screenPos.X, screenPos.Y)
                    local delta = target2D - screenBottom
                    local dist = delta.Magnitude
                    local angle = math.atan2(delta.Y, delta.X)
                    entry.Frame.Size = UDim2.new(0, dist, 0, 1.5)
                    entry.Frame.Position = UDim2.new(0, (screenBottom.X + target2D.X) / 2,
                        0, (screenBottom.Y + target2D.Y) / 2)
                    entry.Frame.Rotation = math.deg(angle)
                    entry.Frame.Visible = true
                else
                    entry.Frame.Visible = false
                end
            else
                entry.Frame.Visible = false
            end
        end
    end
end))

-- ==========================================
-- ESP SCAN LOOP (0.5s heartbeat, prunes indraUnloaded targets first)
-- ==========================================
task.spawn(function()
    while not indraUnloaded do
        task.wait(0.5)
        -- prune gone targets from the cache
        for indraTarget, hl in pairs(indraHighlights) do
            if not indraTarget or not indraTarget.Parent then
                if hl and hl.Parent then hl:Destroy() end
                indraHighlights[indraTarget] = nil
            end
        end

        if not indraState.anomaliesESP then indraClearESP("Anomaly") end
        if not indraState.patientsESP then indraClearESP("Patient") end
        if not indraState.itemsESP then indraClearESP("ObjectItem") end

        -- patients & anomalies live as top-level models AND inside
        -- any folder named npc / patient / item / tool (dive in!)
        local candidates = {}
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and child ~= localPlayer.Character then
                table.insert(candidates, child)
            else
                local name = string.lower(child.Name)
                if string.find(name, "item") or string.find(name, "tool")
                    or string.find(name, "npc") or string.find(name, "patient") then
                    for _, desc in ipairs(child:GetDescendants()) do
                        if desc:IsA("Model") then
                            table.insert(candidates, desc)
                        end
                    end
                end
            end
        end

        for _, model in ipairs(candidates) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
                if not players:GetPlayerFromCharacter(model) then
                    if isAnomaly(model) then
                        if indraState.anomaliesESP then
                            if indraHighlights[model]
                                and indraHighlights[model]:GetAttribute("ESPType") == "Patient" then
                                indraHighlights[model]:Destroy()
                                indraHighlights[model] = nil
                            end
                            indraApplyHighlight(model, Color3.fromRGB(255, 0, 0), "Anomaly")
                            if indraState.drawLines then
                                indraAddLine(model, Color3.fromRGB(255, 0, 0))
                            end
                        end
                    else
                        if indraState.patientsESP then
                            if indraHighlights[model]
                                and indraHighlights[model]:GetAttribute("ESPType") == "Anomaly" then
                                indraHighlights[model]:Destroy()
                                indraHighlights[model] = nil
                            end
                            indraApplyHighlight(model, Color3.fromRGB(0, 255, 0), "Patient")
                            if indraState.drawLines then
                                indraAddLine(model, Color3.fromRGB(0, 255, 0))
                            end
                        end
                    end
                end
            end
        end

        -- items = loose prompts that don't belong to a breathing creature
        if indraState.itemsESP then
            pcall(function()
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local parent = desc.Parent
                        if parent then
                            local hasHumanoid =
                                (parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid"))
                                or (parent:FindFirstChild("Humanoid"))
                                or (parent.Name == "Head" and parent.Parent
                                    and parent.Parent:FindFirstChild("Humanoid"))
                                or (parent.Parent and parent.Parent:IsA("Model")
                                    and parent.Parent:FindFirstChildOfClass("Humanoid"))
                            if not hasHumanoid then
                                local indraTarget = (parent:IsA("Model") or parent:IsA("BasePart"))
                                    and parent or nil
                                if indraTarget then
                                    indraApplyObjHL(indraTarget, Color3.fromRGB(255, 255, 0))
                                    if indraState.drawLines then
                                        indraAddLine(indraTarget, Color3.fromRGB(255, 255, 0))
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- PLAYER ESP (cyan, applies when someone respawns too)
-- ==========================================
local function indraApplyPlayerESP(player)
    local char = player.Character
    if not char or char == localPlayer.Character then return end
    if not char:FindFirstChild("IndraHubHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "IndraHubHighlight"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(0, 255, 255)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
    if indraState.drawLines then
        indraAddLine(char, Color3.fromRGB(0, 255, 255))
    end
end

local function indraRemovePlayerESP(player)
    local char = player.Character
    if char then
        local hl = char:FindFirstChild("IndraHubHighlight")
        if hl then hl:Destroy() end
        indraClearLine(char)
    end
end

track(runService.RenderStepped:Connect(function()
    if indraUnloaded or not indraState.playerESP then return end
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer then indraApplyPlayerESP(p) end
    end
end))

-- ==========================================
-- WALKSPEED (change-only writes, never spam)
-- cola boost indraWindow overrides your indraTarget speed while active
-- ==========================================
local indraColaBoost = 0
local INDRA_COLA_SPEED = 32

task.spawn(function()
    while not indraUnloaded do
        task.wait(0.4)
        local hum = indraGetHumanoid()
        if hum and hum.WalkSpeed ~= 0 then
            local indraTarget = (os.clock() < indraColaBoost) and INDRA_COLA_SPEED or indraState.speed
            if hum.WalkSpeed ~= indraTarget then
                hum.WalkSpeed = indraTarget
            end
        end
    end
end)

-- ==========================================
-- INF SANITY (attributes + stray value objects, locked at 100)
-- ==========================================
local function hookSanityValue(valueObj)
    if valueObj:IsA("ValueBase") then
        local name = string.lower(valueObj.Name)
        if string.find(name, "sanity") or string.find(name, "sanidad")
            or string.find(name, "cordura") then
            valueObj.Value = 100
            if not indraSanityConns[valueObj] then
                indraSanityConns[valueObj] = valueObj.Changed:Connect(function(newVal)
                    if indraState.infSanity and newVal ~= 100 then
                        valueObj.Value = 100
                    end
                end)
            end
        end
    end
end

task.spawn(function()
    while not indraUnloaded do
        task.wait(0.25)
        if indraState.infSanity then
            pcall(function()
                if localPlayer:GetAttribute("Sanity") ~= 100 then
                    localPlayer:SetAttribute("Sanity", 100)
                end
                if localPlayer:GetAttribute("Sanidad") ~= 100 then
                    localPlayer:SetAttribute("Sanidad", 100)
                end
                local char = indraGetChar()
                if char then
                    if char:GetAttribute("Sanity") ~= 100 then
                        char:SetAttribute("Sanity", 100)
                    end
                    if char:GetAttribute("Sanidad") ~= 100 then
                        char:SetAttribute("Sanidad", 100)
                    end
                    for _, child in ipairs(char:GetChildren()) do
                        hookSanityValue(child)
                    end
                end
                local stats = localPlayer:FindFirstChild("leaderstats")
                    or localPlayer:FindFirstChild("Data")
                    or localPlayer:FindFirstChild("Stats")
                if stats then
                    for _, child in ipairs(stats:GetChildren()) do
                        hookSanityValue(child)
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- 3RD PERSON CAMERA
-- ==========================================
local function indraThirdPerson()
    local hum = indraGetHumanoid()
    if hum then
        hum.CameraOffset = indraState.thirdPerson
            and Vector3.new(0, 3, 12)
            or Vector3.new(0, 0, 0)
    end
end

-- ==========================================
-- FASTER ACTIONS (every prompt fires instantly)
-- ==========================================
local function indraFasterActions()
    pcall(function()
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = indraState.fasterActions and 0 or 1
            end
        end
    end)
end

track(workspace.DescendantAdded:Connect(function(inst)
    if indraUnloaded then return end
    if indraState.fasterActions and inst:IsA("ProximityPrompt") then
        task.wait(0.1)
        pcall(function() inst.HoldDuration = 0 end)
    end
end))

-- ==========================================
-- ANTI AFK
-- ==========================================
track(localPlayer.Idled:Connect(function()
    if indraUnloaded or not indraState.antiAfk then return end
    pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end))

-- ==========================================
-- AUTO MINIGAMES
-- clicks the heartbeat game buttons, queues the color game,
-- skips exits and danger buttons like they owe us money
-- ==========================================
local minigameLastTrigger = os.clock()

local function indraClickBtn(btn)
    if not btn or not btn.Parent then return end
    if indraMgClicked[btn] then return end
    local absPos = btn.AbsolutePosition
    local absSize = btn.AbsoluteSize
    if absSize.X == 0 or absSize.Y == 0 or (absPos.X == 0 and absPos.Y == 0) then
        return
    end
    indraMgClicked[btn] = true
    task.spawn(function()
        pcall(function()
            local inset = guiService:GetGuiInset()
            local x = absPos.X + (absSize.X / 2) + inset.X
            local y = absPos.Y + (absSize.Y / 2) + inset.Y
            virtualInputManager:SendMouseMoveEvent(x, y, game)
            task.wait(0.04)
            virtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.01)
            virtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
        pcall(function()
            if firesignal then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
            end
        end)
    end)
    task.delay(1.5, function() indraMgClicked[btn] = nil end)
end

local function indraHookColorMG()
    local rooms = workspace:FindFirstChild("Rooms")
    local emergency = rooms and rooms:FindFirstChild("Emergency")
    local emergRooms = emergency and emergency:FindFirstChild("Rooms")
    local room6 = emergRooms and emergRooms:FindFirstChild("Room6")
    local minigame = room6 and room6:FindFirstChild("Minigame")
    if minigame and minigame:FindFirstChild("Colors") then
        for _, colorBtn in ipairs(minigame.Colors:GetChildren()) do
            local button = colorBtn:FindFirstChild("Button")
            if button and not button:GetAttribute("IndraHubHooked") then
                button:SetAttribute("IndraHubHooked", true)
                button:SetAttribute("IndraHubOriginalColor", tostring(button.Color))
                track(button:GetPropertyChangedSignal("Color"):Connect(function()
                    if indraState.autoMinigames then
                        local origStr = button:GetAttribute("IndraHubOriginalColor")
                        if origStr and tostring(button.Color) ~= origStr then
                            if not indraMgClicked[button] then
                                table.insert(indraMgQueue, button)
                                minigameLastTrigger = os.clock()
                            end
                        end
                    end
                end))
            end
        end
    end
end

local function indraIsExitBtn(btn)
    local name = string.lower(btn.Name)
    local text = (btn:IsA("TextButton") and string.lower(btn.Text)) or ""
    return string.find(name, "close") or string.find(name, "exit")
        or string.find(name, "leave") or string.find(name, "salir")
        or name == "x" or text == "x" or string.find(text, "salir")
end

local function indraIsDangerBtn(btn)
    local name = string.lower(btn.Name)
    return string.find(name, "danger") or btn:FindFirstChild("Skull")
        or btn:FindFirstChild("skull")
end

-- heartbeat minigame + button minigame auto clicks
track(runService.Heartbeat:Connect(function()
    if indraUnloaded or not indraState.autoMinigames then return end
    local hbUI = playerGui:FindFirstChild("HeartbeatMinigameUI")
    if hbUI then
        local frame = hbUI:FindFirstChild("Frame")
        if frame and frame.Visible then
            for _, desc in ipairs(frame:GetDescendants()) do
                if desc:IsA("GuiButton") and desc.Visible
                    and desc.Parent.Name ~= "Folder" then
                    if not indraIsExitBtn(desc) and not indraIsDangerBtn(desc) then
                        indraClickBtn(desc)
                    end
                end
            end
        end
    end
    local mg = playerGui:FindFirstChild("Minigame")
    if mg then
        local frame = mg:FindFirstChild("Frame")
        if frame and frame.Visible then
            local holder = frame:FindFirstChild("ButtonsHolder")
            if holder then
                for _, btn in ipairs(holder:GetChildren()) do
                    if btn:IsA("GuiButton") and btn.Visible then
                        indraClickBtn(btn)
                    end
                end
            end
        end
    end
end))

-- color minigame queue: fires the world prompt after the UI goes quiet
task.spawn(function()
    while not indraUnloaded do
        if indraState.autoMinigames and #indraMgQueue > 0
            and (os.clock() - minigameLastTrigger) > 3 then
            for _, btn in ipairs(indraMgQueue) do
                if btn and btn.Parent then
                    local cd = btn:FindFirstChild("ClickDetector")
                    local pp = btn:FindFirstChild("PP")
                        or btn:FindFirstChildOfClass("ProximityPrompt")
                    pcall(function()
                        if cd and fireclickdetector then
                            fireclickdetector(cd)
                        elseif pp and fireproximityprompt then
                            fireproximityprompt(pp)
                        end
                    end)
                    task.wait(0.6)
                end
            end
            indraMgQueue = {}
            indraMgClicked = {}
        end
        task.wait(0.2)
    end
end)

-- drop buttons from the clicked-set once they're gone
task.spawn(function()
    while not indraUnloaded do
        task.wait(0.25)
        if indraState.autoMinigames then
            for btn in pairs(indraMgClicked) do
                if not btn or not btn.Parent or btn.Visible == false
                    or (btn.Parent and btn.Parent.Name == "Folder") then
                    indraMgClicked[btn] = nil
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO TASKS (BETA)
-- the full checkin dance: form, camera, computer, badge,
-- printer, photo — and it slams the shutter on skinwalkers
-- ==========================================
local taskStepCFrames = {
    [1] = {
        Camera = CFrame.new(-104.082085, 5.211154, 0.033473, 0.999763, 0.012997, -0.017454, 0, 0.802057, -0.597106, 0.021762, 0.597248, 0.801867),
        Root   = CFrame.new(-104.073357, 3.412531, -0.367461, 0.999763, 0, -0.021764, 0, 1, 0, 0.021764, 0, 0.999763),
    },
    [2] = {
        Camera = CFrame.new(-108.414391, 5.097577, 0.123036, 0.991486, -0.048192, 0.12097, 0, 0.928995, 0.370083, -0.130216, -0.366942, 0.921085),
        Root   = CFrame.new(-108.474876, 3.412531, -0.337506, 0.991485, 0, 0.130218, 0, 1, 0, -0.130218, 0, 0.991485),
    },
    [3] = {
        Camera = CFrame.new(-99.982895, 5.015163, 0.411147, 0.706237, 0.145322, -0.6929, 0, 0.978707, 0.205264, 0.707976, -0.144965, 0.69119),
        Root   = CFrame.new(-99.636444, 3.412531, 0.065548, 0.706236, 0, -0.707976, 0, 1, 0, 0.707976, 0, 0.706236),
    },
    [4] = {
        Camera = CFrame.new(-99.491142, 5.3251, 1.201594, -0.018005, 0.825005, -0.564838, 0, 0.56493, 0.825139, 0.999838, 0.014857, -0.010172),
        Root   = CFrame.new(-99.208725, 3.412531, 1.20668, -0.018005, 0, -0.999838, 0, 1, 0, 0.999838, 0, -0.018005),
    },
    [5] = {
        Camera = CFrame.new(-106.80722, 5.164389, -6.988466, 0.04727, 0.513142, -0.857001, 0, 0.85796, 0.513117, 0.998882, -0.024283, 0.040556),
        Root   = CFrame.new(-106.378723, 3.407531, -7.008744, 0.047271, 0, -0.998882, 0, 1, 0, 0.998882, 0, 0.047271),
    },
    [6] = {
        Root = CFrame.new(-99.208725, 3.412531, 1.20668, -0.018005, 0, -0.999838, 0, 1, 0, 0.999838, 0, -0.018005),
    },
}

local checkinSubTargets = { "Form", "Camera", "Computer", "PatientBadgeBase", "Printer", "Photo" }

local function indraDoTask(prompt, stepIndex)
    local char = indraGetChar()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not prompt or not hum then return end
    root.Anchored = true
    local step = taskStepCFrames[stepIndex]
    if step then
        if step.Camera then camera.CFrame = step.Camera end
        if step.Root then root.CFrame = step.Root end
        if stepIndex == 6 and prompt.Parent then
            local targetPos = prompt.Parent:GetPivot().Position
            root.CFrame = step.Root
            camera.CFrame = CFrame.lookAt(Vector3.new(-99.208725, 5, 1.20668), targetPos)
        end
    end
    task.wait(0.6)
    pcall(function()
        if fireproximityprompt then fireproximityprompt(prompt) end
    end)
    task.wait(0.6)
    camera.CameraSubject = hum
    root.Anchored = false
end

local function indraAutoTasks()
    -- invisible helper blocks (marker spots from the original dance)
    local cubo1 = Instance.new("Part")
    cubo1.Name = "Cubo1Ref"
    cubo1.Size = Vector3.new(2, 2, 2)
    cubo1.Position = Vector3.new(-107.448, 7.435, 7.999)
    cubo1.Anchored = true
    cubo1.Transparency = 1
    cubo1.CanCollide = false
    cubo1.Parent = workspace
    table.insert(indraHelperParts, cubo1)

    local npcsFolder = workspace:FindFirstChild("NPCs")
    local checkinFolder = workspace:FindFirstChild("Misc")
        and workspace.Misc:FindFirstChild("Checkin")

    while indraState.autoTasks and not indraUnloaded do
        if npcsFolder then
            local npc = npcsFolder:GetChildren()[1]
            if npc and npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                local isAnom = (npc:GetAttribute("Skinwalker") == true)
                    or (npc:GetAttribute("SkinwalkerEasy") == true)
                    or (npc:GetAttribute("PenaltyWhenLettingIn") == true)
                    or (npc:GetAttribute("HasCameraEffect") == true)
                if isAnom then
                    -- skinwalker at the door? shutter SLAMS
                    if checkinFolder then
                        local shutter = checkinFolder:FindFirstChild("ShutterButton")
                        local pp = shutter and (shutter:FindFirstChild("PP")
                            or shutter:FindFirstChildOfClass("ProximityPrompt"))
                        if pp then
                            pcall(function()
                                if fireproximityprompt then fireproximityprompt(pp) end
                            end)
                            task.wait(4)
                            pcall(function()
                                if fireproximityprompt then fireproximityprompt(pp) end
                            end)
                        end
                    end
                else
                    if checkinFolder then
                        for idx, name in ipairs(checkinSubTargets) do
                            if not indraState.autoTasks or indraUnloaded then break end
                            local obj = checkinFolder:FindFirstChild(name)
                            local pp = obj and (obj:FindFirstChild("PP")
                                or obj:FindFirstChildOfClass("ProximityPrompt"))
                            if pp then
                                indraDoTask(pp, idx)
                                task.wait(1.4)
                            end
                        end
                        task.wait(2)
                    end
                end
            end
        end
        local char = indraGetChar()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and cubo1 and cubo1.Parent then
            root.Anchored = true
            root.CFrame = CFrame.new(cubo1.Position + Vector3.new(0, 3, 0))
            task.wait(0.1)
            root.Anchored = false
        end
        task.wait(0.5)
    end

    if cubo1 and cubo1.Parent then cubo1:Destroy() end
end

-- ==========================================
-- AUTO HEAL (BETA)
-- walks the whole fix-a-patient circuit by itself
-- ==========================================
local function indraAutoHeal()
    while indraState.autoHeal and not indraUnloaded do
        local rooms = workspace:FindFirstChild("Misc")
            and workspace.Misc:FindFirstChild("Rooms")
        local prompt, roomParent
        if rooms then
            for _, r in ipairs(rooms:GetChildren()) do
                local inner = r:FindFirstChildOfClass("Model")
                if inner then
                    local pp = inner:FindFirstChild("PP")
                        or inner:FindFirstChildOfClass("ProximityPrompt")
                    if pp and pp.Enabled then
                        prompt, roomParent = pp, inner
                        break
                    end
                end
            end
        end

        if prompt and roomParent then
            local root = indraGetRoot()
            if root then
                root.CFrame = roomParent:GetPivot() * CFrame.new(0, 0, 2)
                task.wait(0.3)
                pcall(function()
                    if fireproximityprompt then fireproximityprompt(prompt) end
                end)
                task.wait(4)

                local analyzer = roomParent:FindFirstChild("Analyzer")
                    or roomParent:FindFirstChild("Processor")
                local analyzerPP = analyzer and (analyzer:FindFirstChild("PP")
                    or analyzer:FindFirstChildOfClass("ProximityPrompt"))
                if analyzerPP and analyzerPP.Enabled then
                    root.CFrame = analyzerPP.Parent:GetPivot() * CFrame.new(0, 0, 2)
                    task.wait(0.3)
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(analyzerPP) end
                    end)
                    task.wait(5)
                end

                local comp = roomParent:FindFirstChild("Computer")
                    or roomParent:FindFirstChild("PC")
                local compPP = comp and (comp:FindFirstChild("PP")
                    or comp:FindFirstChildOfClass("ProximityPrompt"))
                if compPP and compPP.Enabled then
                    root.CFrame = compPP.Parent:GetPivot() * CFrame.new(0, 0, 3)
                    task.wait(0.3)
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(compPP) end
                    end)
                    task.wait(1.5)
                end

                local supplies = workspace:FindFirstChild("Misc")
                    and workspace.Misc:FindFirstChild("Supplies")
                if supplies then
                    for _, desc in ipairs(supplies:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            root.CFrame = desc.Parent:GetPivot() * CFrame.new(0, 0, 3)
                            task.wait(0.3)
                            pcall(function()
                                if fireproximityprompt then fireproximityprompt(desc) end
                            end)
                            task.wait(1)
                            break
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end

-- ==========================================
-- RUN FAST COLA
-- first hunt for the REAL cola tool and clone it; if the game
-- hides it, craft our own: drink = zoom + purple sparkles, 30s
-- ==========================================
local function indraFindRealCola()
    local lowered = function(s) return string.lower(s) end
    for _, spot in ipairs({ replicatedStorage, workspace, game:GetService("Lighting") }) do
        for _, d in ipairs(spot:GetDescendants()) do
            if d:IsA("Tool") then
                local n = lowered(d.Name)
                if string.find(n, "cola") or string.find(n, "run fast")
                    or string.find(n, "speed boost") then
                    return d
                end
            end
        end
    end
    return nil
end

local function indraCraftCola()
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return false end

    local tool = Instance.new("Tool")
    tool.Name = "Run Fast Cola"
    tool.ToolTip = "🥤 zoom juice — 30s of purple speed"
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.8, 1.4, 0.8)
    handle.Color = Color3.fromRGB(160, 60, 255)
    handle.Parent = tool

    local drinking = false
    tool.Activated:Connect(function()
        if drinking or indraUnloaded then return end
        drinking = true
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- open the 30 second zoom indraWindow (the speed loop holds it)
            indraColaBoost = os.clock() + 30
            local sparkles = Instance.new("Sparkles")
            sparkles.SparkleColor = Color3.fromRGB(170, 0, 255)
            local torso = char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("HumanoidRootPart")
            if torso then sparkles.Parent = torso end
            task.delay(30, function()
                if sparkles and sparkles.Parent then
                    pcall(function() sparkles:Destroy() end)
                end
            end)
        end
        task.wait(2) -- sip break, no chugging the whole six pack
        drinking = false
    end)

    tool.Parent = backpack
    return true
end

local function indraGetCola()
    -- real one first: if the game offers the tool, take the legit copy
    local real = indraFindRealCola()
    if real then
        local backpack = localPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local okClone = pcall(function()
                real:Clone().Parent = backpack
            end)
            if okClone then return true end
        end
    end
    -- no cola lying around? we brew our own
    return indraCraftCola()
end

-- ==========================================
-- GET OBJECT (the snatch-and-return trick:
-- hop in, fire the prompt, hop back like nothing happened)
-- ==========================================
local busy = false
local function indraFetchObj(itemName)
    if busy then return false end
    busy = true

    local char = indraGetChar()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local head = char and char:FindFirstChild("Head")
    if not root or not hum or not head then
        busy = false
        return false
    end

    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            if desc.ActionText == itemName or desc.ObjectText == itemName then
                local parent = desc.Parent
                local basePart = (parent:IsA("BasePart") and parent)
                    or parent:FindFirstChildWhichIsA("BasePart")
                if basePart then
                    local savedCFrame = root.CFrame
                    local savedLOS = desc.RequiresLineOfSight
                    local savedCollide = basePart.CanCollide

                    desc.RequiresLineOfSight = false
                    basePart.CanCollide = false
                    pcall(function() desc.HoldDuration = 0 end)

                    local targetPos = basePart.Position
                    local attachment = parent:FindFirstChildOfClass("Attachment")
                    if attachment then targetPos = attachment.WorldPosition end

                    -- invisible platform so we don't bonk the shelf
                    local platform = Instance.new("Part")
                    platform.Size = Vector3.new(5, 1, 5)
                    platform.Anchored = true
                    platform.Transparency = 1
                    platform.CanCollide = true
                    platform.CFrame = CFrame.new(targetPos + Vector3.new(0, -2, 0))
                    platform.Parent = workspace

                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 2))
                    task.wait(0.05)
                    root.Velocity = Vector3.new(0, 0, 0)

                    task.wait(0.2)
                    camera.CFrame = CFrame.lookAt(head.Position, targetPos)
                    task.wait(0.05)
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(desc) end
                    end)

                    task.wait(0.3)
                    desc.RequiresLineOfSight = savedLOS
                    basePart.CanCollide = savedCollide
                    platform:Destroy()

                    root.CFrame = savedCFrame
                    root.Velocity = Vector3.new(0, 0, 0)
                    task.wait(0.05)
                    camera.CameraSubject = hum

                    busy = false
                    return true
                end
            end
        end
    end

    busy = false
    return false
end

-- ==========================================
-- DELETE ALL DOORS (hospital with no doors = speedrun)
-- ==========================================
local function indraDeleteAllDoors()
    pcall(function()
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("Model") then
                local name = string.lower(desc.Name)
                if string.find(name, "door") or string.find(name, "puerta")
                    or string.find(name, "porton") then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end)
    indraNotify("🚪", "Doors wiped! ✨", 2)
end

-- ==========================================
-- ROOM TELEPORTS (every wall of the hospital mapped)
-- ==========================================
local roomCFrames = {
    ["checkzone"]            = CFrame.new(-107.333389, 3.412531, 8.237826, -0.954479, 0, -0.298277, 0, 1, 0, 0.298277, 0, -0.954479),
    ["entrance"]             = CFrame.new(-78.983574, 3.407531, -12.504811, -0.021113, 0, -0.999777, 0, 1, 0, 0.999777, 0, -0.021113),
    ["room halfway A (1-5)"] = CFrame.new(-145.037628, 3.457531, -65.147362, -0.996587, 0, 0.08254, 0, 1, 0, -0.082549, 0, -0.996587),
    ["room 1"]               = CFrame.new(-169.766663, 3.457531, -50.727806, 0.025003, 0, -0.999687, 0, 1, 0, 0.999687, 0, 0.025003),
    ["room 2"]               = CFrame.new(-123.374763, 3.457531, -51.833504, -0.611116, 0, 0.79154, 0, 1, 0, -0.791541, 0, -0.611116),
    ["room 3"]               = CFrame.new(-173.209396, 3.457531, -90.922246, 0.008945, 0, -0.99996, 0, 1, 0, 0.99996, 0, 0.008945),
    ["room 4"]               = CFrame.new(-117.447639, 3.457531, -89.03093, 0.020848, 0, 0.999783, 0, 1, 0, -0.999783, 0, 0.020848),
    ["room 5"]               = CFrame.new(-145.94075, 3.457531, -113.268204, 0.999244, 0, 0.03886, 0, 1, 0, -0.038867, 0, 0.999244),
    ["shop"]                 = CFrame.new(-166.514618, 3.45753, -12.773237, 0.012568, 0, 0.999921, 0, 1, 0, -0.999921, 0, 0.012568),
    ["halfway B (6-8)"]      = CFrame.new(-144.837326, 3.45753, 36.86932, 0.99922, 0, 0.039477, 0, 1, 0, -0.039477, 0, 0.99922),
    ["room 6"]               = CFrame.new(-171.039078, 3.45753, 52.27216, 0.399193, 0, -0.916867, 0, 1, 0, 0.916867, 0, 0.399193),
    ["room 7"]               = CFrame.new(-124.463058, 3.45753, 45.395046, -0.985264, 0, -0.171038, 0, 1, 0, 0.171038, 0, -0.985264),
    ["room 8"]               = CFrame.new(-145.123749, 3.45753, 77.844215, -0.999892, 0, 0.014681, 0, 1, 0, -0.014681, 0, -0.999892),
}

local tpCooldown = false
local function indraTeleportTo(roomName)
    if tpCooldown then
        indraNotify("📍", "Chill, cooldown! ⏳", 2)
        return
    end
    local cf = roomCFrames[roomName]
    local root = indraGetRoot()
    if cf and root then
        pcall(function()
            root.CFrame = cf
        end)
        tpCooldown = true
        indraNotify("📍", "You're there! ✨", 2)
        task.wait(0.5)
        tpCooldown = false
    else
        indraNotify("📍", "Couldn't hop there! 😢", 2)
    end
end

-- free mouse (Z): keep the cursor usable while the menu is up
track(runService.RenderStepped:Connect(function()
    if indraUnloaded or not indraState.mouseFree then return end
    if userInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end))

-- ==========================================
-- KEYBINDS (for the keyboard warriors)
-- H anomalies · J patients · K items · Z free mouse
-- ==========================================
track(userInputService.InputBegan:Connect(function(input, processed)
    if indraUnloaded or processed then return end
    if input.KeyCode == Enum.KeyCode.H then
        indraState.anomaliesESP = not indraState.anomaliesESP
        if not indraState.anomaliesESP then indraClearESP("Anomaly") end
    elseif input.KeyCode == Enum.KeyCode.J then
        indraState.patientsESP = not indraState.patientsESP
        if not indraState.patientsESP then indraClearESP("Patient") end
    elseif input.KeyCode == Enum.KeyCode.K then
        indraState.itemsESP = not indraState.itemsESP
        if not indraState.itemsESP then indraClearESP("ObjectItem") end
    elseif input.KeyCode == Enum.KeyCode.Z then
        indraState.mouseFree = not indraState.mouseFree
        userInputService.MouseIconEnabled = true
    end
end))

-- ==========================================
-- UI (WindUI)
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local indraWindow = WindUI:CreateWindow({
    Title = "IndraHub",
    Author = "IndraHub Premium",
    Theme = "Dark",
    Size = UDim2.new(0, 500, 0, 500),
    Acrylic = false, -- IMPORTANT: Acrylic blur = GPU drain on mobile
    Icon = "lucide:cross",
})

-- ==========================================
-- TAB 1: ESP
-- ==========================================
local espTab = indraWindow:Tab({ Title = "ESP", Icon = "lucide:eye" })

espTab:Toggle({
    Title = "💀 Anomalies ESP",
    Desc = "Skinwalkers & camera-effect patients glow RED",
    Default = false,
    Callback = function(s)
        indraState.anomaliesESP = s
        if not s then indraClearESP("Anomaly") end
    end,
})

espTab:Toggle({
    Title = "🙂 Normal Patients ESP",
    Desc = "Regular patients glow green",
    Default = false,
    Callback = function(s)
        indraState.patientsESP = s
        if not s then indraClearESP("Patient") end
    end,
})

espTab:Toggle({
    Title = "🔧 Tools / Item ESP",
    Desc = "Grab-able tools & items glow yellow",
    Default = false,
    Callback = function(s)
        indraState.itemsESP = s
        if not s then indraClearESP("ObjectItem") end
    end,
})

espTab:Toggle({
    Title = "👥 Player ESP",
    Desc = "Other players glow cyan",
    Default = false,
    Callback = function(s)
        indraState.playerESP = s
        if not s then
            for _, p in ipairs(players:GetPlayers()) do
                indraRemovePlayerESP(p)
            end
        end
    end,
})

espTab:Toggle({
    Title = "📏 Draw Lines",
    Desc = "Beams from your screen to every ESP indraTarget",
    Default = false,
    Callback = function(s)
        indraState.drawLines = s
        if not s then indraClearAllLines() end
    end,
})

-- ==========================================
-- TAB 2: PLAYER
-- ==========================================
local playerTab = indraWindow:Tab({ Title = "Player", Icon = "lucide:user" })

playerTab:Input({
    Title = "WalkSpeed",
    Desc = "Type a number, it loops so the game can't reset it",
    Placeholder = "e.g. 16 or 40",
    Type = "Input",
    Callback = function(text)
        local n = tonumber(text)
        if n then
            indraState.speed = n
            indraNotify("🏃", "Speed set to " .. n, 2)
        end
    end,
})

playerTab:Button({
    Title = "Reset Speed",
    Desc = "Back to a normal 16",
    Icon = "lucide:rotate-ccw",
    Callback = function()
        indraState.speed = 16
        indraNotify("🏃", "Speed reset! ✨", 2)
    end,
})

playerTab:Toggle({
    Title = "⚡ Faster Actions",
    Desc = "Everything you hold to interact goes instant",
    Default = false,
    Callback = function(s)
        indraState.fasterActions = s
        indraFasterActions()
    end,
})

playerTab:Toggle({
    Title = "🧠 Inf Sanity",
    Desc = "Your sanity never drops again",
    Default = false,
    Callback = function(s) indraState.infSanity = s end,
})

playerTab:Toggle({
    Title = "🎥 3rd Person Camera",
    Desc = "Camera chills behind you",
    Default = false,
    Callback = function(s)
        indraState.thirdPerson = s
        indraThirdPerson()
    end,
})

playerTab:Toggle({
    Title = "😴 Anti-AFK",
    Desc = "Roblox can't kick you for being idle",
    Default = true,
    Callback = function(s) indraState.antiAfk = s end,
})

playerTab:Toggle({
    Title = "🖱️ Free Mouse  [Z]",
    Desc = "Unlocks the cursor while the menu is up",
    Default = false,
    Callback = function(s)
        indraState.mouseFree = s
        userInputService.MouseIconEnabled = true
    end,
})

-- ==========================================
-- TAB 3: AUTO
-- ==========================================
local autoTab = indraWindow:Tab({ Title = "Auto", Icon = "lucide:bot" })

autoTab:Section({
    Title = "⚠️ Beta zone",
    Text = "Auto Tasks & Auto Heal are still beta babies — they work but might hiccup. Skinwalkers beware anyway.",
})

autoTab:Toggle({
    Title = "🎮 Auto play Minigames",
    Desc = "Plays the color game and heartbeat game for you",
    Default = false,
    Callback = function(s)
        indraState.autoMinigames = s
        if s then
            indraMgQueue = {}
            indraMgClicked = {}
            indraHookColorMG()
            minigameLastTrigger = os.clock()
        end
    end,
})

autoTab:Toggle({
    Title = "📋 Auto Tasks (BETA)",
    Desc = "Runs the whole check-in dance for every patient",
    Default = false,
    Callback = function(s)
        indraState.autoTasks = s
        if s then
            task.spawn(indraAutoTasks)
        else
            local hum = indraGetHumanoid()
            if hum then camera.CameraSubject = hum end
        end
    end,
})

autoTab:Toggle({
    Title = "💊 Auto Heal (BETA)",
    Desc = "Runs the whole fix-a-patient circuit by itself",
    Default = false,
    Callback = function(s)
        indraState.autoHeal = s
        if s then
            task.spawn(indraAutoHeal)
        end
    end,
})

-- ==========================================
-- TAB 4: ITEMS
-- ==========================================
local itemsTab = indraWindow:Tab({ Title = "Items", Icon = "lucide:package" })

itemsTab:Button({
    Title = "🥤 Get Run Fast Cola",
    Desc = "A cola lands in your backpack — drink it for 30s of zoom + purple sparkles",
    Icon = "lucide:cup-soda",
    Callback = function()
        local got = indraGetCola()
        if got then
            indraNotify("🥤", "Cola secured! Check your backpack ✨", 2)
        else
            indraNotify("🥤", "Couldn't grab one! 😢", 3)
        end
    end,
})

itemsTab:Section({
    Title = "Get Object",
    Text = "Tap any item — you blink over, grab it, blink back.",
})

local itemNames = {
    { name = "Herbs",        icon = "lucide:leaf" },
    { name = "Eye Drops",    icon = "lucide:eye" },
    { name = "IV Drops",     icon = "lucide:droplets" },
    { name = "Medkit",       icon = "lucide:briefcase-medical" },
    { name = "Thermo",       icon = "lucide:thermometer" },
    { name = "Ointment",     icon = "lucide:pill" },
    { name = "Bandages",     icon = "lucide:bandage" },
    { name = "Maple Syrup",  icon = "lucide:flask-conical" },
    { name = "Cough Syrup",  icon = "lucide:flask-round" },
    { name = "Medicine",     icon = "lucide:pills" },
}

for _, item in ipairs(itemNames) do
    itemsTab:Button({
        Title = item.name,
        Icon = item.icon,
        Callback = function()
            indraNotify("🧰", "Grabbing " .. item.name .. "...", 2)
            local got = indraFetchObj(item.name)
            if got then
                indraNotify("🧰", item.name .. " secured! ✨", 2)
            else
                indraNotify("🧰", "Couldn't find it! 😢", 3)
            end
        end,
    })
end

-- ==========================================
-- TAB 5: TELEPORT
-- ==========================================
local tpTab = indraWindow:Tab({ Title = "Teleport", Icon = "lucide:map-pin" })

tpTab:Section({ Title = "General", Text = "" })
for _, name in ipairs({ "checkzone", "entrance", "shop" }) do
    tpTab:Button({
        Title = name,
        Icon = "lucide:door-open",
        Callback = function() indraTeleportTo(name) end,
    })
end

tpTab:Section({ Title = "Patient Rooms", Text = "" })
for _, name in ipairs({ "room 1", "room 2", "room 3", "room 4",
    "room 5", "room 6", "room 7", "room 8" }) do
    tpTab:Button({
        Title = name,
        Icon = "lucide:door-open",
        Callback = function() indraTeleportTo(name) end,
    })
end

tpTab:Section({ Title = "Hallways", Text = "" })
for _, name in ipairs({ "room halfway A (1-5)", "halfway B (6-8)" }) do
    tpTab:Button({
        Title = name,
        Icon = "lucide:door-open",
        Callback = function() indraTeleportTo(name) end,
    })
end

-- ==========================================
-- TAB 6: MISC
-- ==========================================
local miscTab = indraWindow:Tab({ Title = "Misc", Icon = "lucide:settings-2" })

miscTab:Button({
    Title = "🚪 Delete all doors",
    Desc = "Every door in the hospital, gone. Speedrun route unlocked",
    Icon = "lucide:door-closed",
    Callback = function() indraDeleteAllDoors() end,
})

miscTab:Button({
    Title = "♻️ Unload Script",
    Desc = "Cleanly shuts everything off and closes the menu",
    Icon = "lucide:power",
    Callback = function()
        indraNotify("♻️", "Unloaded! Re-execute anytime 💚", 3)
        if genv.__INDRA_CLEANUP then
            pcall(genv.__INDRA_CLEANUP)
        end
    end,
})

-- ==========================================
-- CLEANUP (re-execution safe — never stacks copies,
-- every loop bails, every glow & line disappears)
-- ==========================================
genv.__INDRA_CLEANUP = function()
    indraUnloaded = true
    for k in pairs(indraState) do
        if type(indraState[k]) == "boolean" then indraState[k] = false end
    end
    for _, p in ipairs(indraHelperParts) do
        if p and p.Parent then pcall(function() p:Destroy() end) end
    end
    indraHelperParts = {}
    for _, conn in pairs(indraSanityConns) do
        pcall(function() conn:Disconnect() end)
    end
    indraSanityConns = {}
    indraClearAllLines()
    for indraTarget, hl in pairs(indraHighlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    indraHighlights = {}
    for _, p in ipairs(players:GetPlayers()) do
        indraRemovePlayerESP(p)
    end
    for _, c in ipairs(indraConnections) do
        pcall(function() c:Disconnect() end)
    end
    indraConnections = {}
    pcall(function()
        if indraLineGui and indraLineGui.Parent then indraLineGui:Destroy() end
    end)
    pcall(function() indraWindow:Destroy() end)
end

-- Boot it up (v1.6.65 windows auto-open, just pick the first tab)
indraWindow:SelectTab(1)
if indraInLobby then
    indraNotify("IndraHub", "Join the actual game first — lobby detected! 🏥", 6)
else
    indraNotify("IndraHub", "Loaded! 🏥💚", 4)
end

-- IndraHub Heartbeat
local function pingSupervisor()
    local clock = os.clock()
    if getgenv then
        getgenv().IndraHubAnomalyESPLastHeartbeat = clock
        getgenv().IndraHubAnomalyESPRunning = true
    end
end
task.spawn(function()
    while not indraUnloaded do
        pingSupervisor()
        task.wait(1)
    end
end)
