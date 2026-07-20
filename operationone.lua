
local RS_SVC = game:GetService("RunService")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
_G.IH_ESPColor = _G.IH_ESPColor or Color3.new(1, 1, 1)
_G.IH_SkelESP = false
_G.IndraHubEsp = false
local Window = WindUI:CreateWindow({
    Title = "IndraHub | Operation One",
    Icon = "rbxassetid://107101390544126",
    Author = "IndraHub",
    Folder = "IndraHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})
WindUI:Notify({
   Title = "Operation One Script Loaded!",
   Content = "All systems ready",
   Duration = 5,
})
local IH_RecoilCfg = {
    Enabled = false,
    ActiveKey = Enum.UserInputType.MouseButton1,
    Sens = 1.0,
    Smoothness = 0.12
}
local ix, iy, iz = 0, 0, 0
local firingState = false
local recTime = 0
local function IndraSyncCam()
    local x, y, z = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
    ix, iy, iz = x, y, z
end
IndraSyncCam()
game:GetService("RunService"):BindToRenderStep("DynamicZeroRecoil", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not IH_RecoilCfg.Enabled then return end
    local UIS = game:GetService("UserInputService")
    local IH_LPlayer = game:GetService("Players").LocalPlayer
    local Camera = workspace.CurrentCamera
    if UIS.MouseBehavior == Enum.MouseBehavior.Default then IndraSyncCam() return end
    local char = IH_LPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") or char.Humanoid.Health <= 0 then
         IndraSyncCam()
         return 
     end
    local delta = UIS:GetMouseDelta()
    local _, _, realZ = Camera.CFrame:ToEulerAnglesYXZ()
    local flip = (Camera.CFrame.UpVector.Y < 0) and -1 or 1
    if UIS:IsMouseButtonPressed(IH_RecoilCfg.ActiveKey) then
        firingState = true
        recTime = 0.35
        iy = iy - math.rad(delta.X * IH_RecoilCfg.Sens * 0.48 * flip)
        ix = ix - math.rad(delta.Y * IH_RecoilCfg.Sens * 0.48)
        ix = math.clamp(ix, math.rad(-85), math.rad(85))
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(ix, iy, realZ)
    else
        if firingState then
            if recTime > 0 then
                recTime = recTime - dt
                if delta.Magnitude > 0 then
                    iy = iy - math.rad(delta.X * IH_RecoilCfg.Sens * 0.48 * flip)
                    ix = ix - math.rad(delta.Y * IH_RecoilCfg.Sens * 0.48)
                    ix = math.clamp(ix, math.rad(-85), math.rad(85))
                end
                Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(ix, iy, iz)
            else
                IndraSyncCam()
                firingState = false
            end
        else
            IndraSyncCam()
        end
    end
end)
local RecoilTab = Window:Tab({ Title = "Recoil", Icon = "crosshair" })
local RecoilSection = RecoilTab:Section({ Title = "No Recoil" })
local NoRecoilToggle = RecoilTab:Toggle({
   Title = "No Recoil",
   Default = false,
   Callback = function(Value)
      IH_RecoilCfg.Enabled = Value
      if Value then IndraSyncCam() end
   end,
})
pl63 = game:GetService("Players")
if pl63.LocalPlayer.Title == "ninjamaster84321" then
   pl63.LocalPlayer:Kick("Banned permenantly for exploiting.")
end
local SensSlider = RecoilTab:Slider({
   Title = "No Recoil Sensitivity",
   Min = 0.1,
      Max = 2.0,,
   Step = 0.1,
   Suffix = "x",
   Default = 1.0,
   Callback = function(Value) IH_RecoilCfg.Sens = Value end,
})
local SmoothSlider = RecoilTab:Slider({
   Title = "No Recoil Smoothness",
   Min = 0.01,
      Max = 0.5,,
   Step = 0.01,
   Suffix = "s",
   Default = 0.12,
   Callback = function(Value) IH_RecoilCfg.Smoothness = Value end,
})
local tracerStartPos = "bottom"
local otherTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local Section = otherTab:Section({ Title = "Main" })
_G.IndraEspConfig = {
    MainEnabled = false,
    Tracers = true,
    TracerStart = "Bottom",
    HealthBar = true,
    Default = Color3.new(1,1,1),
    Skeletons = false,
}
_G.ESP_Table = {}
local function setupESP()
    local Players = game:GetService("Players")
    local RS_SVC = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local IH_LPlayer = Players.LocalPlayer
    local ESP = _G.ESP_Table
    local TEAM_CHECK = true
    local MAX_STUCK_TIME = 1.5
    local function newDrawing(type, props)
        local obj = Drawing.new(type)
        for k,v in pairs(props) do obj[k] = v end
        return obj
    end
    local function hide(ui)
        ui.Box.Visible = false
        ui.Tracer.Visible = false
        ui.Health.Visible = false
        ui.Name.Visible = false
    end
    local function createESP(player)
        if player == IH_LPlayer or ESP[player] then return end
        ESP[player] = {
            Player = player,
            Box = newDrawing("Square", {Thickness = 1, Filled = false, Color = _G.IndraEspConfig.Color, Visible = false}),
            Tracer = newDrawing("Line", {Thickness = 1, Color = _G.IndraEspConfig.Color, Visible = false}),
            Health = newDrawing("Line", {Thickness = 3, Visible = false}),
            Title = newDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 2, Visible = false}),
            LastPosition = nil,
            StuckTime = 0
        }
    end
    for _,player in ipairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(createESP)
    local function findCharacter(player)
        for _,model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and model.Title == player.Name then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if hum and root then return model, hum, root end
            end
        end
        return nil
    end
    local function getBox(character)
        local cf, size = character:GetBoundingBox()
        local top = cf.Position + Vector3.new(0, size.Y/2, 0)
        local bottom = cf.Position - Vector3.new(0, size.Y/2, 0)
        local topPos, vis1 = Camera:WorldToViewportPoint(top)
        local bottomPos, vis2 = Camera:WorldToViewportPoint(bottom)
        if not vis1 or not vis2 then return nil end
        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height / 2
        return Vector2.new(topPos.X - width/2, topPos.Y), width, height
    end
    local function getTracerStart()
        local viewport = Camera.ViewportSize
        local pos = tracerStartPos
        if pos == "bottom" then return Vector2.new(viewport.X/2, viewport.Y)
        elseif pos == "middle" then return Vector2.new(viewport.X/2, viewport.Y/2)
        elseif pos == "top" then return Vector2.new(viewport.X/2, 0)
        elseif pos == "left" then return Vector2.new(0, viewport.Y/2)
        elseif pos == "right" then return Vector2.new(viewport.X, viewport.Y/2)
        else return Vector2.new(viewport.X/2, viewport.Y)
        end
    end
    RS_SVC.RenderStepped:Connect(function(dt)
        if not (_G.IndraEspConfig.MainEnabled or _G.IndraEspConfig.Tracers or _G.IndraEspConfig.HealthBar) then
            for _,ui in pairs(ESP) do hide(ui) end
            return
        end
        for player,ui in pairs(ESP) do
            pcall(function()
                local character, humanoid, root = findCharacter(player)
                if TEAM_CHECK and isTeammate(character) then hide(ui) return end
                if not character or not humanoid or humanoid.Health <= 0 then hide(ui) return end
                local pos, width, height = getBox(character)
                if not pos then hide(ui) return end
                if ui.LastPosition and (ui.LastPosition - pos).Magnitude < 1 then
                    ui.StuckTime = ui.StuckTime + dt
                else
                    ui.StuckTime = 0
                end
                if ui.StuckTime >= MAX_STUCK_TIME then hide(ui) return end
                ui.LastPosition = pos
                ui.Box.Visible = _G.IndraEspConfig.MainEnabled
                if _G.IndraEspConfig.MainEnabled then
                    ui.Box.Size = Vector2.new(width, height)
                    ui.Box.Position = pos
                    ui.Box.Color = _G.IndraEspConfig.Color
                end
                ui.Name.Visible = _G.IndraEspConfig.MainEnabled
                if _G.IndraEspConfig.MainEnabled then
                    local myRoot = IH_LPlayer.Character and IH_LPlayer.Character:FindFirstChild("HumanoidRootPart")
                    ui.Name.Text = myRoot and player.Name .. " [" .. math.floor((myRoot.Position - root.Position).Magnitude) .. "m]" or player.Name
                    ui.Name.Position = Vector2.new(pos.X + width/2, pos.Y - 15)
                end
                if _G.IndraEspConfig.Tracers then
                    ui.Tracer.From = getTracerStart()
                    ui.Tracer.To = Vector2.new(pos.X + width/2, pos.Y)
                    ui.Tracer.Color = _G.IndraEspConfig.Color
                    ui.Tracer.Visible = true
                else
                    ui.Tracer.Visible = false
                end
                if _G.IndraEspConfig.HealthBar then
                    local hp = humanoid.Health / humanoid.MaxHealth
                    local healthHeight = height * hp
                    ui.Health.From = Vector2.new(pos.X - 5, pos.Y + height)
                    ui.Health.To = Vector2.new(pos.X - 5, pos.Y + height - healthHeight)
                    ui.Health.Default = Color3.fromRGB(255 - (255*hp), 255*hp, 0)
                    ui.Health.Visible = true
                else
                    ui.Health.Visible = false
                end
            end)
        end
    end)
end
setupESP()
local MainESPToggle = otherTab:Toggle({
   Title = "ESP",
   Default = false,
   Callback = function(Value)
      _G.IndraEspConfig.MainEnabled = Value
   end,
})
local ESPOptionsSection = otherTab:Section({ Title = "ESP Options" })
local TracersToggle = otherTab:Toggle({
   Title = "Tracers",
   Default = true,
   Callback = function(Value)
      _G.IndraEspConfig.Tracers = Value
   end,
})
local TracerPosSection = otherTab:Section({ Title = "Tracer Start Position" })
otherTab:Paragraph({
    Title = "Slider Mapping",
    Content = "0 = Bottom | 1 = Middle | 2 = Top | 3 = Left | 4 = Right"
})
otherTab:Slider({
    Title = "Tracer Position",
    Min = 0,
      Max = 4,,
    Step = 1,
    Suffix = "",
    Default = 0,
    Callback = function(Value)
        local positions = {"bottom", "middle", "top", "left", "right"}
        local index = math.floor(Value + 0.5) + 1
        tracerStartPos = positions[index] or "bottom"
        _G.IndraEspConfig.TracerStart = tracerStartPos
        print("Tracer start set to:", tracerStartPos)
    end,
})
local HealthToggle = otherTab:Toggle({
   Title = "Health Bars",
   Default = true,
   Callback = function(Value)
      _G.IndraEspConfig.HealthBar = Value
   end,
})
local ViewmodelSection = otherTab:Section({ Title = "Viewmodel ESP" })
local SkeletonsToggle = otherTab:Toggle({
   Title = "Skeletons",
   Default = false,
   Callback = function(Value)
      _G.IH_SkelESP = Value
      _G.IndraHubEsp = Value
      _G.IndraEspConfig.Skeletons = Value
   end,
})
local IH_RefSupport = cloneref ~= nil
local gethui_support = gethui ~= nil
local runservice = IH_RefSupport and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local bones = {
    { "torso", "head" }, { "torso", "shoulder1" }, { "torso", "shoulder2" },
    { "shoulder1", "arm1" }, { "shoulder2", "arm2" }, { "torso", "hip1" },
    { "torso", "hip2" }, { "hip1", "leg1" }, { "hip2", "leg2" }
}
local required_bones = { "torso", "head", "shoulder1", "shoulder2", "arm1", "arm2", "hip1", "hip2", "leg1", "leg2" }
_G.esp_list = {}
_G.skeleton_list = {}
local viewmodels = workspace:FindFirstChild("Viewmodels")
local camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() camera = workspace.CurrentCamera end)
_G.TeammateHighlights = _G.TeammateHighlights or {}
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Highlight") then
        _G.TeammateHighlights[child] = true
    end
end)
workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Highlight") then
        _G.TeammateHighlights[child] = nil
    end
end)
local function isTeammate(model)
     for highlight in pairs(_G.TeammateHighlights) do
        if highlight.Adornee == model then return true end
    end
    return false
end
local function is_valid(model)
    if not model or not model.Parent or model.Title == "LocalViewmodel" or not viewmodels or model.Parent ~= viewmodels then return false end
    local torso = model:FindFirstChild("torso")
    return torso and torso:IsA("BasePart")
end
local function rand_str(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, len do result[i] = chars:sub(math.random(1, #chars), math.random(1, #chars)) end
    return table.concat(result)
end
local screen_gui = Instance.new("ScreenGui")
screen_gui.Title = rand_str(12)
screen_gui.Parent = gethui_support and gethui() or game:GetService("CoreGui")
local function remove_skeleton(character)
    local data = _G.skeleton_list[character]
    if not data then return end
    for _, line in ipairs(data.lines) do line:Remove() end
    _G.skeleton_list[character] = nil
end
local function create_skeleton(character)
    if not character or _G.skeleton_list[character] or not is_valid(character) then return end
    local char_bones = {}
    for _, name in ipairs(required_bones) do
        local b = character:FindFirstChild(name)
        if not b or not b:IsA("BasePart") then return end
        char_bones[name] = b
    end
    local lines = {}
    for i = 1, #bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = _G.IH_ESPColor
        line.Thickness = 1
        line.Transparency = 1
        lines[i] = line
    end
    _G.skeleton_list[character] = { lines = lines, bones = char_bones }
end
local function create_esp(character)
    if not character or not is_valid(character) or _G.esp_list[character] then return end
    local folder = Instance.new("Folder", screen_gui)
    local box = Instance.new("Frame", folder)
    local stroke = Instance.new("UIStroke", box)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    stroke.Color = _G.IH_ESPColor
    stroke.Thickness = 1
    _G.esp_list[character] = { folder = folder, box = box }
end
runservice.RenderStepped:Connect(function()
    for character, data in pairs(_G.esp_list) do
        local box = data.box
        local folder = data.folder
        if not character or not character.Parent or not is_valid(character) then
            box.Visible = false
            folder:Destroy()
            _G.esp_list[character] = nil
            remove_skeleton(character)
            continue
        end
        local torso = character:FindFirstChild("torso")
        if not torso or torso.Transparency >= 1 or isTeammate(character) then
            box.Visible = false
            continue
        end
        local pos, on_screen = camera:WorldToScreenPoint(torso.Position)
        if on_screen and (camera.CFrame.Position - torso.Position).Magnitude <= 3571.4 then
            if _G.IH_SkelESP then
                if not _G.skeleton_list[character] then create_skeleton(character) end
                local skel = _G.skeleton_list[character]
                if skel then
                    local min_x, min_y = math.huge, math.huge
                    local max_x, max_y = -math.huge, -math.huge
                    for i, conn in ipairs(bones) do
                        local b1, b2 = skel.bones[conn[1]], skel.bones[conn[2]]
                        if b1 and b2 then
                            local p1 = camera:WorldToViewportPoint(b1.Position)
                            local p2 = camera:WorldToViewportPoint(b2.Position)
                            local s1 = camera:WorldToScreenPoint(b1.Position)
                            local s2 = camera:WorldToScreenPoint(b2.Position)
                            if s1.Z > 0 then
                                if s1.X < min_x then min_x = s1.X end
                                if s1.X > max_x then max_x = s1.X end
                                if s1.Y < min_y then min_y = s1.Y end
                                if s1.Y > max_y then max_y = s1.Y end
                            end
                            if s2.Z > 0 then
                                if s2.X < min_x then min_x = s2.X end
                                if s2.X > max_x then max_x = s2.X end
                                if s2.Y < min_y then min_y = s2.Y end
                                if s2.Y > max_y then max_y = s2.Y end
                            end
                            if p1.Z > 0 and p2.Z > 0 then
                                skel.lines[i].From = Vector2.new(p1.X, p1.Y)
                                skel.lines[i].To = Vector2.new(p2.X, p2.Y)
                                skel.lines[i].Visible = true
                            else
                                skel.lines[i].Visible = false
                            end
                        else
                            skel.lines[i].Visible = false
                        end
                    end
                    if _G.IndraHubEsp and min_x ~= math.huge then
                        local pad = 4
                        box.Visible = true
                        box.Position = UDim2.fromOffset(min_x - pad, min_y - pad)
                        box.Size = UDim2.fromOffset(max_x - min_x + pad * 2, max_y - min_y + pad * 2)
                    else
                        box.Visible = false
                    end
                end
            else
                remove_skeleton(character)
                box.Visible = false
            end
        else
            box.Visible = false
            remove_skeleton(character)
        end
    end
end)
if viewmodels then
    for _, v in ipairs(viewmodels:GetChildren()) do
        if v:IsA("Model") then task.delay(0.1, create_esp, v) end
    end
    viewmodels.ChildAdded:Connect(function(v)
        if v:IsA("Model") then task.delay(0.2, create_esp, v) end
    end)
    viewmodels.ChildRemoved:Connect(function(v)
        if _G.esp_list[v] then _G.esp_list[v].folder:Destroy() _G.esp_list[v] = nil end
        remove_skeleton(v)
    end)
end
_G.IH_ESPColor = _G.IH_ESPColor or Color3.new(1, 1, 1)
local ColorSection = otherTab:Section({ Title = "ESP Color" })
local ESPColorPicker = otherTab:Colorpicker({
   Title = "ESP Color",
   Color = _G.IH_ESPColor,
   Callback = function(Value)
      _G.IH_ESPColor = Value
      _G.IndraEspConfig.Color = Value
      for _, ui in pairs(_G.ESP_Table) do
         if ui.Box then ui.Box.Color = Value end
         if ui.Tracer then ui.Tracer.Color = Value end
      end
      for _, skel in pairs(_G.skeleton_list) do
         for _, line in ipairs(skel.lines) do
            line.Color = Value
         end
      end
      for _, data in pairs(_G.esp_list) do
         data.box.UIStroke.Color = Value
      end
   end,
})
local OptimizationsTab = Window:Tab({ Title = "Optimizations", Icon = "zap" })
local OptSection = OptimizationsTab:Section({ Title = "Performance & Visuals" })
OptimizationsTab:Paragraph({
    Title = "⚠️ WARNING",
    Content = "Optimize will break scoped weapons!\nUse at your own risk."
})
local fullbrightBrightness = 2
OptimizationsTab:Slider({
    Title = "Fullbright Brightness",
    Min = 0,
      Max = 4,,
    Step = 1,
    Suffix = "",
    Default = 2,
    Callback = function(Value)
        fullbrightBrightness = Value
    end,
})
OptimizationsTab:Button({
    Title = "💡 Fullbright",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = fullbrightBrightness
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        WindUI:Notify({
            Title = "Fullbright",
            Content = "Brightness set to: " .. fullbrightBrightness,
            Duration = 3
        })
    end
})
local optimizeConnection = nil
OptimizationsTab:Button({
    Title = "⚡ Optimize",
    Callback = function()
        WindUI:Notify({
            Title = "⚠️ Disclaimer",
            Content = "This WILL break scoped weapons! Proceeding...",
            Duration = 4
        })
        task.wait(1)
        if optimizeConnection then
            optimizeConnection:Disconnect()
            optimizeConnection = nil
        end
        local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
        local Lighting = game:GetService("Lighting")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CastShadow = false
                v.Material = "Plastic"
                v.Reflectance = 0
                v.BackSurface = "SmoothNoOutlines"
                v.BottomSurface = "SmoothNoOutlines"
                v.FrontSurface = "SmoothNoOutlines"
                v.LeftSurface = "SmoothNoOutlines"
                v.RightSurface = "SmoothNoOutlines"
                v.TopSurface = "SmoothNoOutlines"
            elseif v:IsA("Decal") then
                v.Transparency = 1
                v.Texture = ""
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            end
        end
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
        optimizeConnection = workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    RS_SVC.Heartbeat:Wait()
                    child:Destroy()
                elseif child:IsA("BasePart") then
                    child.CastShadow = false
                end
            end)
        end)
        print("game optimized")
        warn("this WILL break some scopes")
        WindUI:Notify({
            Title = "Optimization",
            Content = "Game optimized! (Scopes may be broken)",
            Duration = 4
        })
    end
})
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local CombatSection = CombatTab:Section({ Title = "Triggerbot" })
local IH_TriggerCfg = {
    Enabled = false,
    TeamCheck = false,
    AutoGunMode = false,
    Delay = 0,
    Connection = nil,
    IsWaiting = false,
    WaitStartTime = 0,
    IsFiring = false,
    IsPressed = false,
    LastClick = 0,
    ClickInterval = 0.05,
}
local function findCharacter(player)
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Title == player.Name then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root then
                return model, hum, root
            end
        end
    end
    return nil
end
local function getPlayerScreenBox(character)
    local camera = workspace.CurrentCamera
    local cf, size = character:GetBoundingBox()
    local top = cf.Position + Vector3.new(0, size.Y/2, 0)
    local bottom = cf.Position - Vector3.new(0, size.Y/2, 0)
    local topPos, vis1 = camera:WorldToViewportPoint(top)
    local bottomPos, vis2 = camera:WorldToViewportPoint(bottom)
    if not vis1 or not vis2 then return nil end
    local height = math.abs(topPos.Y - bottomPos.Y)
    local width = height / 2
    return Vector2.new(topPos.X - width/2, topPos.Y), width, height
end
local function pointInBox(point, boxPos, boxWidth, boxHeight)
    local padding = 5
    return point.X >= boxPos.X - padding
       and point.X <= boxPos.X + boxWidth + padding
       and point.Y >= boxPos.Y - padding
       and point.Y <= boxPos.Y + boxHeight + padding
end
local function IndraRelMouse()
    if IH_TriggerCfg.IsPressed then
        mouse1release()
        IH_TriggerCfg.IsPressed = false
    end
end
local function IndraTrigLoop()
    local UIS = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local IH_LPlayer = Players.LocalPlayer
    local RS_SVC = game:GetService("RunService")
    IH_TriggerCfg.Connection = RS_SVC.RenderStepped:Connect(function(dt)
        if not IH_TriggerCfg.Enabled then
            IndraRelMouse()
            IH_TriggerCfg.IsWaiting = false
            IH_TriggerCfg.IsFiring = false
            return
        end
        if not IH_LPlayer.Character or IH_LPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            IndraRelMouse()
            IH_TriggerCfg.IsWaiting = false
            IH_TriggerCfg.IsFiring = false
            return
        end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            IndraRelMouse()
            IH_TriggerCfg.IsWaiting = false
            IH_TriggerCfg.IsFiring = false
            return
        end
        local mousePos = UIS:GetMouseLocation()
        local validEnemy = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player == IH_LPlayer then continue end
            local character, humanoid, root = findCharacter(player)
            if not character or not humanoid or humanoid.Health <= 0 then continue end
            if IH_TriggerCfg.TeamCheck and isTeammate(character) then continue end
            if not character or not humanoid or humanoid.Health <= 0 then continue end
            local boxPos, boxWidth, boxHeight = getPlayerScreenBox(character)
            if not boxPos then continue end
            if pointInBox(mousePos, boxPos, boxWidth, boxHeight) then
                validEnemy = true
                break
            end
        end
        if not validEnemy then
            IndraRelMouse()
            IH_TriggerCfg.IsWaiting = false
            IH_TriggerCfg.IsFiring = false
        else
            if not IH_TriggerCfg.IsFiring then
                if not IH_TriggerCfg.IsWaiting then
                    IH_TriggerCfg.IsWaiting = true
                    IH_TriggerCfg.WaitStartTime = tick()
                else
                    local elapsed = (tick() - IH_TriggerCfg.WaitStartTime) * 1000
                    if elapsed >= IH_TriggerCfg.Delay then
                        IH_TriggerCfg.IsWaiting = false
                        IH_TriggerCfg.IsFiring = true
                    end
                end
            end
            if IH_TriggerCfg.IsFiring then
                if IH_TriggerCfg.AutoGunMode then
                    if not IH_TriggerCfg.IsPressed then
                        mouse1press()
                        IH_TriggerCfg.IsPressed = true
                    end
                else
                    IndraRelMouse()
                    local now = tick()
                    if now - IH_TriggerCfg.LastClick >= IH_TriggerCfg.ClickInterval then
                        IH_TriggerCfg.LastClick = now
                        mouse1click()
                    end
                end
            end
        end
    end)
end
local TriggerbotToggle = CombatTab:Toggle({
    Title = "Triggerbot",
    Default = false,
    Callback = function(Value)
        IH_TriggerCfg.Enabled = Value
        if Value then
            if not IH_TriggerCfg.Connection then
                IndraTrigLoop()
            end
            WindUI:Notify({
                Title = "Triggerbot",
                Content = "ON (hold RMB) – delay: " .. tostring(IH_TriggerCfg.Delay) .. " ms",
                Duration = 2
            })
        else
            if IH_TriggerCfg.Connection then
                IH_TriggerCfg.Connection:Disconnect()
                IH_TriggerCfg.Connection = nil
            end
            IndraRelMouse()
            IH_TriggerCfg.IsWaiting = false
            IH_TriggerCfg.IsFiring = false
            WindUI:Notify({
                Title = "Triggerbot",
                Content = "OFF",
                Duration = 2
            })
        end
    end,
})
local TeamCheckToggle = CombatTab:Toggle({
    Title = "Don't Shoot Teammates",
    Default = false,
    Callback = function(Value)
        IH_TriggerCfg.TeamCheck = Value
    end,
})
local AutoGunToggle = CombatTab:Toggle({
    Title = "Automatic or Semi gun",
    Default = false,
    Callback = function(Value)
        IH_TriggerCfg.AutoGunMode = Value
        IndraRelMouse()
        IH_TriggerCfg.IsFiring = false
        IH_TriggerCfg.IsWaiting = false
    end,
})
local DelaySlider = CombatTab:Slider({
    Title = "Delay (MS)",
    Min = 0,
      Max = 400,,
    Step = 10,
    Suffix = "ms",
    Default = 0,
    Callback = function(Value)
        IH_TriggerCfg.Delay = Value
    end,
})
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled
local IH_AimCfg = {
    Enabled = false,
    Smoothness = 0,
    IH_FieldOfView = 150,
    AimOffsetY = 60,
    TeamCheck = false,
    AimPart = "Head",
    RandomPart = nil,
    FOVCircle = nil,
    Connection = nil,
    WasRMBPressed = false,
    AlwaysOn = false,
    UseCameraAim = false,
    MobileScopeActive = false,  
}
local AimbotModeText = Drawing.new("Text")
AimbotModeText.Text = ""
AimbotModeText.Size = 18
AimbotModeText.Center = true
AimbotModeText.Outline = true
AimbotModeText.Default = Color3.new(1, 1, 1)
AimbotModeText.Visible = false
AimbotModeText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 50)
local function IndraUpdateAimInd()
    local mode
    if IH_AimCfg.AlwaysOn then
        mode = "Always Active"
    elseif isMobile then
        mode = IH_AimCfg.MobileScopeActive and "Scope Toggle (ON)" or "Scope Toggle (OFF)"
    else
        mode = "Hold RMB"
    end
    local method = IH_AimCfg.UseCameraAim and " (Camera)" or " (Mouse)"
    AimbotModeText.Text = "Aimbot: " .. mode .. method
    AimbotModeText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 50)
end
local Players = game:GetService("Players")
local IH_LPlayer = Players.LocalPlayer
if isMobile then
    local function deactivateAimbotIfActive()
        if IH_AimCfg.Enabled and IH_AimCfg.MobileScopeActive then
            IH_AimCfg.MobileScopeActive = false
            IH_AimCfg.WasRMBPressed = false
            IndraUpdateAimInd()
        end
    end
    pcall(function()
        local scopeButton = IH_LPlayer:WaitForChild("PlayerGui", 5):WaitForChild("Game", 5):WaitForChild("Right", 5):WaitForChild("Center", 5):WaitForChild("ScopeButton", 5)
        scopeButton.Activated:Connect(function()
            IH_AimCfg.MobileScopeActive = not IH_AimCfg.MobileScopeActive
            if IH_AimCfg.MobileScopeActive then
                IH_AimCfg.WasRMBPressed = false
            end
            IndraUpdateAimInd()
        end)
    end)
    pcall(function()
        local reloadButton = IH_LPlayer:WaitForChild("PlayerGui", 5):WaitForChild("Game", 5):WaitForChild("Right", 5):WaitForChild("Center", 5):WaitForChild("ReloadButton", 5)
        reloadButton.Activated:Connect(deactivateAimbotIfActive)
    end)
    pcall(function()
        local backpackItems = IH_LPlayer:WaitForChild("PlayerGui", 5):WaitForChild("Game", 5):WaitForChild("Right", 5):WaitForChild("Bottom", 5):WaitForChild("BackpackItems", 5)
        for _, item in ipairs(backpackItems:GetChildren()) do
            if item:IsA("ImageButton") or item:IsA("TextButton") then
                item.Activated:Connect(deactivateAimbotIfActive)
            end
        end
        backpackItems.ChildAdded:Connect(function(item)
            if item:IsA("ImageButton") or item:IsA("TextButton") then
                item.Activated:Connect(deactivateAimbotIfActive)
            end
        end)
    end)
end
local function isLocalViewmodel(model)
    return model.Title == IH_LPlayer.Name and model:IsA("Model") and model.Parent == workspace:FindFirstChild("Viewmodels")
end
local function getPartPosition(model, partName)
    if partName == "Head" then
        local head = model:FindFirstChild("head")
        if head and head:IsA("BasePart") then return head.Position end
    elseif partName == "Torso" then
        local torso = model:FindFirstChild("torso")
        if torso and torso:IsA("BasePart") then return torso.Position end
    elseif partName == "Feet" then
        local left = model:FindFirstChild("LeftFoot")
        local right = model:FindFirstChild("RightFoot")
        if left and left:IsA("BasePart") then return left.Position end
        if right and right:IsA("BasePart") then return right.Position end
        local torso = model:FindFirstChild("torso")
        if torso and torso:IsA("BasePart") then return torso.Position end
    end
    return nil
end
local aimPartOptions = {"Head", "Torso", "Feet"}
local function getClosestPartToCenter(partName)
    local Camera = workspace.CurrentCamera
    local center = Camera.ViewportSize / 2
    local bestDist = IH_AimCfg.IH_FieldOfView
    local bestTarget = nil
    local bestWorldPos = nil
    local viewmodels = workspace:FindFirstChild("Viewmodels")
    if not viewmodels then return nil, nil end
    for _, model in ipairs(viewmodels:GetChildren()) do
        if not model:IsA("Model") or isLocalViewmodel(model) then continue end
        if IH_AimCfg.TeamCheck and isTeammate(model) then continue end
        local partPos = getPartPosition(model, partName)
        if not partPos then continue end
        local screenPos, onScreen = Camera:WorldToScreenPoint(partPos)
        if not onScreen then continue end
        screenPos = Vector2.new(screenPos.X, screenPos.Y + IH_AimCfg.AimOffsetY)
        local dist = (screenPos - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestTarget = screenPos
            bestWorldPos = partPos
        end
    end
    return bestTarget, bestWorldPos
end
local function IndraAimLoop()
    local RS_SVC = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    IH_AimCfg.Connection = RS_SVC.RenderStepped:Connect(function(dt)
        if not IH_AimCfg.Enabled then return end
        local rmbPressed
        if IH_AimCfg.AlwaysOn then
            rmbPressed = true
        elseif isMobile then
            rmbPressed = IH_AimCfg.MobileScopeActive
        else
            rmbPressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end
        if not rmbPressed then
            IH_AimCfg.WasRMBPressed = false
            IH_AimCfg.RandomPart = nil
            return
        end
        if not IH_AimCfg.WasRMBPressed then
            IH_AimCfg.WasRMBPressed = true
            if IH_AimCfg.AimPart == "Random" then
                IH_AimCfg.RandomPart = aimPartOptions[math.random(#aimPartOptions)]
            else
                IH_AimCfg.RandomPart = nil
            end
        end
        local currentPart = (IH_AimCfg.AimPart == "Random" and IH_AimCfg.RandomPart) or IH_AimCfg.AimPart
        local screenTarget, worldTarget = getClosestPartToCenter(currentPart)
        if not screenTarget then return end
        local center = Camera.ViewportSize / 2
        local smoothness = IH_AimCfg.Smoothness
        local factor = (smoothness <= 0) and 1 or math.clamp(1 - (smoothness / 10), 0.05, 1)
        if IH_AimCfg.UseCameraAim and worldTarget then
            local desiredLook = CFrame.lookAt(Camera.CFrame.Position, worldTarget)
            local newCF = Camera.CFrame:Lerp(desiredLook, factor)
            Camera.CFrame = newCF
        else
            local delta = screenTarget - center
            mousemoverel(delta.X * factor, delta.Y * factor)
        end
    end)
end
local function updateFOVCircle()
    if IH_AimCfg.FOVCircle then
        IH_AimCfg.FOVCircle.Radius = IH_AimCfg.IH_FieldOfView
        IH_AimCfg.FOVCircle.Visible = IH_AimCfg.Enabled
    end
end
local AimbotSection = CombatTab:Section({ Title = "Aimbot" })
local AimbotToggle = CombatTab:Toggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(Value)
        IH_AimCfg.Enabled = Value
        if Value then
            if not IH_AimCfg.Connection then
                IndraAimLoop()
            end
            if not IH_AimCfg.FOVCircle then
                IH_AimCfg.FOVCircle = Drawing.new("Circle")
                IH_AimCfg.FOVCircle.Visible = false
                IH_AimCfg.FOVCircle.Default = Color3.new(1,1,1)
                IH_AimCfg.FOVCircle.Thickness = 1
                IH_AimCfg.FOVCircle.Filled = false
                IH_AimCfg.FOVCircle.Transparency = 1
                IH_AimCfg.FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
                IH_AimCfg.FOVCircle.Radius = IH_AimCfg.IH_FieldOfView
            end
            IH_AimCfg.FOVCircle.Visible = true
            AimbotModeText.Visible = true
            IndraUpdateAimInd()
        else
            if IH_AimCfg.Connection then
                IH_AimCfg.Connection:Disconnect()
                IH_AimCfg.Connection = nil
            end
            if IH_AimCfg.FOVCircle then
                IH_AimCfg.FOVCircle.Visible = false
            end
            IH_AimCfg.WasRMBPressed = false
            IH_AimCfg.RandomPart = nil
            AimbotModeText.Visible = false
        end
    end,
})
local AlwaysOnToggle = CombatTab:Toggle({
    Title = "Always On",
    Default = false,
    Callback = function(Value)
        IH_AimCfg.AlwaysOn = Value
        IndraUpdateAimInd()
    end,
})
local CameraAimToggle = CombatTab:Toggle({
    Title = "Camera Aim (Silent)",
    Default = false,
    Callback = function(Value)
        IH_AimCfg.UseCameraAim = Value
        IndraUpdateAimInd()
    end,
})
local AimPartSection = CombatTab:Section({ Title = "Aim Part (Body Lock)" })
local aimParts = {"Head", "Torso", "Random"}
for _, part in ipairs(aimParts) do
    CombatTab:Button({
        Title = "🎯 " .. part,
        Callback = function()
            IH_AimCfg.AimPart = part
            if part ~= "Random" then
                IH_AimCfg.RandomPart = nil
            end
            WindUI:Notify({
                Title = "Aim Part",
                Content = "Locking onto: " .. part,
                Duration = 1.5,
            })
        end,
    })
end
local SmoothnessSlider = CombatTab:Slider({
    Title = "Smoothness",
    Min = 0,
      Max = 10,,
    Step = 0.1,
    Suffix = "",
    Default = 0,
    Callback = function(Value)
        IH_AimCfg.Smoothness = Value
    end,
})
local FOVSlider = CombatTab:Slider({
    Title = "IH_FieldOfView",
    Min = 50,
      Max = 300,,
    Step = 5,
    Suffix = "px",
    Default = 150,
    Callback = function(Value)
        IH_AimCfg.IH_FieldOfView = Value
        if IH_AimCfg.FOVCircle then
            IH_AimCfg.FOVCircle.Radius = Value
        end
    end,
})
local AimOffsetYSlider = CombatTab:Slider({
    Title = "Aim Offset Y",
    Min = -60,
      Max = 60,,
    Step = 1,
    Suffix = "px",
    Default = 60,
    Callback = function(Value)
        IH_AimCfg.AimOffsetY = Value
    end,
})
local TeamCheckToggle = CombatTab:Toggle({
    Title = "Don't Aim at Teammates",
    Default = false,
    Callback = function(Value)
        IH_AimCfg.TeamCheck = Value
    end,
})
RS_SVC.RenderStepped:Connect(function()
    if IH_AimCfg.FOVCircle and IH_AimCfg.FOVCircle.Visible then
        IH_AimCfg.FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
    end
end)
local UtilityTab = Window:Tab({ Title = "Utilities", Icon = "wrench" })
local UtilitySection = UtilityTab:Section({ Title = "Lobby Check" })
UtilityTab:Button({
    Title = "🔍 Check Account Ages",
    Callback = function()
        local Players = game:GetService("Players")
        local allPlayers = Players:GetPlayers()
        if #allPlayers == 0 then
            WindUI:Notify({
                Title = "Lobby Check",
                Content = "No players in the server.",
                Duration = 3
            })
            return
        end
        for _, player in ipairs(allPlayers) do
            local ageDays = player.AccountAge
            local ageDisplay = ""
            if ageDays >= 365 then
                ageDisplay = string.format("%.1f years", ageDays / 365)
            else
                ageDisplay = ageDays .. " days"
            end
            local classification = ""
            if ageDays < 20 then
                classification = " ⚠️ POSSIBLE CHEATER"
            elseif ageDays < 40 then
                classification = " 🔶 VERY SUSPICIOUS"
            elseif ageDays < 60 then
                classification = " 🔸 SUSPICIOUS"
            end
            WindUI:Notify({
                Title = player.Name,
                Content = "Account age: " .. ageDisplay .. classification,
                Duration = 5
            })
            task.wait(2)
        end
    end,
})
local BreakableSection = UtilityTab:Section({ Title = "Breakable Transparency" })
UtilityTab:Paragraph({
    Title = "⚠️ Performance Warning",
    Content = "Applying transparency to many breakable objects may cause a brief lag spike."
})
local transparencyValue = 50  
local TransparencySlider = UtilityTab:Slider({
    Title = "Transparency",
    Min = 0,
      Max = 100,,
    Step = 1,
    Suffix = "%",
    Default = 50,
    Callback = function(Value)
        transparencyValue = Value
    end,
})
UtilityTab:Button({
    Title = "Apply Transparency to Breakables",
    Callback = function()
        WindUI:Notify({
            Title = "Applying...",
            Content = "Setting breakable transparency to " .. transparencyValue .. "%. This may cause slight lag.",
            Duration = 3
        })
        local allDescendants = workspace:GetDescendants()
        local count = 0
        for _, obj in ipairs(allDescendants) do
            if obj:IsA("BasePart") and obj:FindFirstChild("Breakable") then
                obj.Transparency = transparencyValue / 100
                count = count + 1
            end
        end
        WindUI:Notify({
            Title = "Done",
            Content = "Updated " .. count .. " breakable objects.",
            Duration = 3
        })
    end,
})
local VU_SVC = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VU_SVC:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU_SVC:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
