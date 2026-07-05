local env = getgenv and getgenv() or _G

local function setGlobal(key, value)
    rawset(_G, key, value)
    if env ~= _G then env[key] = value end
end

local function getGlobal(key)
    local value = rawget(_G, key)
    if value ~= nil then return value end
    return env[key]
end

setGlobal("IndraHubAdoptMeRunning", true)
setGlobal("IndraHubAdoptMeLastHeartbeat", os.clock())
setGlobal("IndraHubAdoptMeError", nil)

task.spawn(function()
    while getGlobal("IndraHubAdoptMeRunning") do
        setGlobal("IndraHubAdoptMeLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

task.spawn(function()
    local fsys = require(game.ReplicatedStorage:WaitForChild("Fsys"))
    local load = fsys.load

    set_thread_identity(2)
    local store = load("ClientData")
    local kindDb = load("KindDB")
    local net = load("RouterClient")
    local assets = load("DownloadClient")
    local anims = load("AnimationManager")
    local rigs = load("new:PetRigs")
    set_thread_identity(8)

    local cache = {}
    local spawned = {}
    local equipped = nil
    local mounted = nil
    local rideTrack = nil

    local function mutate(key, fn)
        local value = store.get(key)
        store.predict(key, fn(table.clone(value)))
    end

    local function guid()
        return game:GetService("HttpService"):GenerateGUID(false)
    end

    local function modelFor(kind)
        if cache[kind] then return cache[kind] end
        local copy = assets.promise_download_copy("Pets", kind):expect()
        cache[kind] = copy
        return copy
    end

    local function makePet(id, props)
        local uid = guid()
        local record = nil
        set_thread_identity(2)
        mutate("inventory", function(inv)
            local bag = table.clone(inv.pets)
            local info = kindDb[id]
            record = {unique = uid, category = "pets", id = id, kind = info.kind, newness_order = 0, properties = props}
            bag[uid] = record
            inv.pets = bag
            return inv
        end)
        set_thread_identity(8)
        spawned[uid] = {data = record, model = nil}
        return record
    end

    local function paintNeon(model, meta)
        local petRoot = model:FindFirstChild("PetModel")
        if not petRoot or not meta.neon_parts then return end
        for partName, cfg in pairs(meta.neon_parts) do
            local part = rigs.get(petRoot).get_geo_part(petRoot, partName)
            if part then
                part.Material = cfg.Material
                part.Color = cfg.Color
            end
        end
    end

    local function pushWrapper(wrapper)
        mutate("pet_char_wrappers", function(list)
            wrapper.unique = #list + 1
            wrapper.index = #list + 1
            list[#list + 1] = wrapper
            return list
        end)
    end

    local function pushState(state)
        mutate("pet_state_managers", function(list)
            list[#list + 1] = state
            return list
        end)
    end

    local function firstIndex(list, fn)
        for i, v in pairs(list) do
            if fn(v, i) then return i end
        end
        return nil
    end

    local function dropWrapper(uid)
        mutate("pet_char_wrappers", function(list)
            local idx = firstIndex(list, function(v) return v.pet_unique == uid end)
            if not idx then return list end
            table.remove(list, idx)
            for i, v in pairs(list) do
                v.unique = i
                v.index = i
            end
            return list
        end)
    end

    local function resetPetState(uid)
        local pet = spawned[uid]
        if not pet or not pet.model then return end
        mutate("pet_state_managers", function(list)
            local idx = firstIndex(list, function(v) return v.char == pet.model end)
            if not idx then return list end
            local copy = table.clone(list)
            copy[idx] = table.clone(copy[idx])
            copy[idx].states = {}
            return copy
        end)
    end

    local function applyPetState(uid, stateId)
        local pet = spawned[uid]
        if not pet or not pet.model then return end
        mutate("pet_state_managers", function(list)
            local idx = firstIndex(list, function(v) return v.char == pet.model end)
            if not idx then return list end
            local copy = table.clone(list)
            copy[idx] = table.clone(copy[idx])
            copy[idx].states = {{id = stateId}}
            return copy
        end)
    end

    local function setHumanState(stateId)
        mutate("state_manager", function(state)
            local copy = table.clone(state)
            copy.states = stateId and {{id = stateId}} or {}
            copy.is_sitting = stateId ~= nil
            return copy
        end)
    end

    local function bindSeat(model)
        local char = game.Players.LocalPlayer.Character
        if not char or not char.PrimaryPart then return false end
        local spot = model:FindFirstChild("RidePosition", true)
        if not spot then return false end
        local attach = Instance.new("Attachment")
        attach.Name = "SourceAttachment"
        attach.Position = Vector3.new(0, 1.237, 0)
        attach.Parent = spot
        local joint = Instance.new("RigidConstraint")
        joint.Name = "StateConnection"
        joint.Attachment0 = attach
        joint.Attachment1 = char.PrimaryPart.RootAttachment
        joint.Parent = char
        return true
    end

    local function removePetState(uid)
        local pet = spawned[uid]
        if not pet or not pet.model then return end
        mutate("pet_state_managers", function(list)
            local idx = firstIndex(list, function(v) return v.char == pet.model end)
            if idx then table.remove(list, idx) end
            return list
        end)
    end

    local function unseat(uid)
        local pet = spawned[uid]
        if not pet or not pet.model then return end
        if rideTrack then rideTrack:Stop() rideTrack:Destroy() rideTrack = nil end
        local attach = pet.model:FindFirstChild("SourceAttachment", true)
        if attach then attach:Destroy() end
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, item in pairs(char:GetDescendants()) do
                if item:IsA("BasePart") and item:GetAttribute("HaveMass") then
                    item.Massless = false
                    item:SetAttribute("HaveMass", nil)
                end
            end
        end
        resetPetState(uid)
        setHumanState(nil)
        pet.model:ScaleTo(1)
        mounted = nil
    end

    local function seat(uid, humanState, petState)
        local pet = spawned[uid]
        local player = game.Players.LocalPlayer
        if not pet or not pet.model or not player.Character or not player.Character.PrimaryPart then return end
        mounted = uid
        applyPetState(uid, petState)
        setHumanState(humanState)
        pet.model:ScaleTo(2)
        bindSeat(pet.model)
        rideTrack = player.Character.Humanoid.Animator:LoadAnimation(anims.get_track("PlayerRidingPet"))
        player.Character.Humanoid.Sit = true
        for _, item in pairs(player.Character:GetDescendants()) do
            if item:IsA("BasePart") and item.Massless == false then
                item.Massless = true
                item:SetAttribute("HaveMass", true)
            end
        end
        rideTrack:Play()
    end

    local function unequipPet(item)
        local pet = spawned[item.unique]
        if not pet or not pet.model then return end
        unseat(item.unique)
        dropWrapper(item.unique)
        removePetState(item.unique)
        pet.model:Destroy()
        pet.model = nil
        equipped = nil
    end

    local function equipPet(item)
        if equipped then unequipPet(equipped) end
        local model = modelFor(item.kind):Clone()
        model.Parent = workspace
        spawned[item.unique].model = model
        if item.properties.neon or item.properties.mega_neon then paintNeon(model, kindDb[item.kind]) end
        equipped = item
        pushWrapper({
            char = model, mega_neon = item.properties.mega_neon, neon = item.properties.neon,
            player = game.Players.LocalPlayer, entity_controller = game.Players.LocalPlayer,
            controller = game.Players.LocalPlayer, rp_name = item.properties.rp_name or "",
            pet_trick_level = item.properties.pet_trick_level, pet_unique = item.unique, pet_id = item.id,
            location = {full_destination_id = "housing", destination_id = "housing", house_owner = game.Players.LocalPlayer},
            pet_progression = {friendship_level = item.properties.friendship_level, age = item.properties.age, percentage = 0},
            are_colors_sealed = false, is_pet = true,
        })
        pushState({char = model, player = game.Players.LocalPlayer, store_key = "pet_state_managers", is_sitting = false, chars_connected_to_me = {}, states = {}})
    end

    local rawGet = net.get
    local function rf(fn) return {InvokeServer = function(_, ...) return fn(...) end} end
    local function re(fn) return {FireServer = function(_, ...) return fn(...) end} end

    local rEquip = rf(function(uid)
        local pet = spawned[uid]
        if not pet then return end
        equipPet(pet.data)
        return true, {action = "equip", is_server = true}
    end)
    local rUnequip = rf(function(uid)
        local pet = spawned[uid]
        if not pet then return end
        unequipPet(pet.data)
        return true, {action = "unequip", is_server = true}
    end)

    net.get = function(name)
        if name == "ToolAPI/Equip" then return rEquip end
        if name == "ToolAPI/Unequip" then return rUnequip end
        if name == "AdoptAPI/RidePet" then return rf(function(item) seat(item.pet_unique, "PlayerRidingPet", "PetBeingRidden") end) end
        if name == "AdoptAPI/FlyPet" then return rf(function(item) seat(item.pet_unique, "PlayerFlyingPet", "PetBeingFlown") end) end
        if name == "AdoptAPI/ExitSeatStatesYield" then return rf(function() unseat(mounted) end) end
        if name == "AdoptAPI/ExitSeatStates" then return re(function() unseat(mounted) end) end
        return rawGet(name)
    end

    for _, wrapper in pairs(store.get("pet_char_wrappers")) do
        rawGet("ToolAPI/Unequip"):InvokeServer(wrapper.pet_unique)
    end

    local invDb = fsys.load("InventoryDB")

    local function petIdByName(name)
        local needle = tostring(name or ""):lower()
        for _, data in pairs(invDb.pets) do
            if type(data) == "table" and data.name and data.name:lower() == needle then return data.id, data.name end
        end
        return nil, nil
    end

    local function propsFor(mode)
        local p = {pet_trick_level = 0, rideable = true, flyable = true, friendship_level = 0, age = 1, ailments_completed = 0, rp_name = ""}
        if mode == "NFR" then p.neon = true end
        if mode == "MFR" then p.mega_neon = true end
        return p
    end

    local function fetch(url, file)
        if type(readfile) == "function" then
            local ok, src = pcall(readfile, file)
            if ok and type(src) == "string" and #src > 1000 then return src end
        end
        local src = game:HttpGet(url)
        if type(writefile) == "function" then pcall(function() writefile(file, src) end) end
        return src
    end

    local okUi, WindUI = pcall(function()
        return loadstring(fetch("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", "IndraHub_AdoptMe_WindUI.lua"))()
    end)
    if not okUi or type(WindUI) ~= "table" then
        warn("IndraHub Adopt Me: WindUI load failed")
        return
    end

    local env = getgenv and getgenv() or _G
    if env.IndraHubAdoptMeWindow then pcall(function() env.IndraHubAdoptMeWindow:Destroy() end) end

    local selectedRarity = "FR"
    local chosenPet = nil
    local chosenName = nil
    local cashFarm = false
    local compassFarm = false
    local petNames = {}

    local function notify(title, text, icon)
        pcall(function() WindUI:Notify({Title = title, Content = text, Icon = icon or "paw-print", Duration = 3}) end)
    end

    local function spawnById(id, name, rarity)
        if not id then notify("IndraHub", "Pet not found", "x") return end
        makePet(id, propsFor(rarity or selectedRarity))
        notify("IndraHub", "Spawned " .. tostring(name or id) .. " (" .. tostring(rarity or selectedRarity) .. ")", "check")
    end

    local function amountLabel(app)
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        local root = pg and pg:FindFirstChild(app)
        local indicator = root and root:FindFirstChild("CurrencyIndicator")
        local container = indicator and indicator:FindFirstChild("Container")
        return container and container:FindFirstChild("Amount")
    end

    local function parseCash(text)
        local clean = tostring(text or ""):gsub(",", ""):gsub("%s", "")
        local n = tonumber(clean:match("[%d%.]+") or "") or 0
        local suf = clean:upper():match("[KMB]")
        if suf == "K" then n = n * 1000 elseif suf == "M" then n = n * 1000000 elseif suf == "B" then n = n * 1000000000 end
        return n
    end

    local function comma(n)
        local s = tostring(math.floor(n + 0.5))
        local k
        repeat s, k = s:gsub("^(%d+)(%d%d%d)", "%1,%2") until k == 0
        return s
    end

    local function fakeFarm(flagFn, app, minAdd, maxAdd)
        local label = amountLabel(app)
        local value = parseCash(label and label.Text)
        while flagFn() do
            local current = amountLabel(app)
            if current then
                value = math.max(value, parseCash(current.Text)) + math.random(minAdd, maxAdd)
                current.Text = comma(value)
            end
            task.wait(1)
        end
    end

    for _, pet in pairs(invDb.pets) do
        if type(pet) == "table" and pet.name and pet.id then petNames[#petNames + 1] = pet.name end
    end
    table.sort(petNames, function(a, b) return a:lower() < b:lower() end)

    local Window = WindUI:CreateWindow({
        Title = "IndraHub",
        Icon = "paw-print",
        Author = "Adopt Me",
        Folder = "IndraHubAdoptMe",
        Size = UDim2.fromOffset(560, 420),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 160,
    })

    env.IndraHubAdoptMeWindow = Window
    Window:SetToggleKey(Enum.KeyCode.RightControl)
    Window:EditOpenButton({Title = "IndraHub", Icon = "paw-print", Draggable = true})

    local Tabs = {
        Pets = Window:Tab({Title = "Pets", Icon = "paw-print"}),
        Farm = Window:Tab({Title = "Farm", Icon = "coins"}),
        Info = Window:Tab({Title = "Info", Icon = "info"}),
    }

    Tabs.Pets:Input({
        Title = "Pet Name",
        Desc = "Exact Adopt Me pet name.",
        Placeholder = "Shadow Dragon",
        Callback = function(text)
            local id, realName = petIdByName(text)
            chosenPet = id
            chosenName = realName or text
        end,
    })

    Tabs.Pets:Dropdown({
        Title = "Rarity",
        Values = {"FR", "NFR", "MFR"},
        Value = "FR",
        Callback = function(value)
            selectedRarity = type(value) == "table" and value[1] or value or "FR"
        end,
    })

    Tabs.Pets:Button({
        Title = "Spawn Typed Pet",
        Desc = "Creates selected pet variant.",
        Callback = function()
            if not chosenPet then notify("IndraHub", "Enter valid pet name first", "search") return end
            spawnById(chosenPet, chosenName, selectedRarity)
        end,
    })

    Tabs.Pets:Dropdown({
        Title = "Pet Browser",
        Desc = "Pick pet from database.",
        Values = petNames,
        Value = petNames[1],
        Callback = function(value)
            local name = type(value) == "table" and value[1] or value
            local id, realName = petIdByName(name)
            chosenPet = id
            chosenName = realName or name
        end,
    })

    Tabs.Pets:Button({
        Title = "Spawn Browser Pet",
        Desc = "Uses current rarity.",
        Callback = function()
            spawnById(chosenPet, chosenName, selectedRarity)
        end,
    })

    Tabs.Farm:Toggle({
        Title = "Money Farm",
        Desc = "Animates bucks counter.",
        Value = false,
        Callback = function(v)
            cashFarm = v
            notify("Money Farm", v and "ON" or "OFF", "coins")
            if v then task.spawn(function() fakeFarm(function() return cashFarm end, "BucksIndicatorApp", 80, 100) end) end
        end,
    })

    Tabs.Farm:Toggle({
        Title = "Compass Farm",
        Desc = "Animates alt currency counter.",
        Value = false,
        Callback = function(v)
            compassFarm = v
            notify("Compass Farm", v and "ON" or "OFF", "navigation")
            if v then task.spawn(function() fakeFarm(function() return compassFarm end, "AltCurrencyIndicatorApp", 23, 43) end) end
        end,
    })

    Tabs.Info:Section({Title = "IndraHub Adopt Me", Icon = "paw-print"})
    Tabs.Info:Section({Title = "RightControl toggles UI", Icon = "keyboard"})
    Tabs.Info:Section({Title = tostring(#petNames) .. " pets loaded", Icon = "database"})

    notify("IndraHub", "Adopt Me loaded", "paw-print")
    print("IndraHub Adopt Me loaded")
end)
