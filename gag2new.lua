-- Deobfuscated from gag2new.lua.
-- Decoder, environment proxy, encrypted string pool, and numeric upvalue slots
-- were removed. The supplied input had already collapsed encrypted property
-- expressions to [0]; those remaining markers require the original obfuscated
-- source (or runtime metadata) for byte-exact recovery.

local state = {}

-- VALINC SYNDICATE - Grow a Garden 2 v1.0.3

if game.PlaceId ~= 121864768012064 and game.PlaceId ~= 97598239454123 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "VALINC SYNDICATE",
            Text = "Unauthorized Game! This script only supports Grow a Garden 2 🌿",
            Duration = 7
        })
    end)
    return
end

state.playersService = game:GetService("Players")
state.localPlayer = state.playersService.LocalPlayer
state.replicatedStorage = game:GetService("ReplicatedStorage")
state.tweenService = game:GetService("TweenService")

-- ponytail: Direct loading of UI library with local wait fallback
local okWindUI, WindUI = pcall(function()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    return loadstring(source)()
end)

local MockValincUi = {}
function MockValincUi.CreateWindow(config)
    local Window = WindUI:CreateWindow({
        Title = "IndraHub | Grow a Garden 2",
        Icon = "leaf",
        Author = "IndraHub",
        Folder = "IndraHub_GAG2",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
    })
    
    local mockWindow = {}
    function mockWindow:CreateTab(name, icon)
        local Tab = Window:Tab({ Title = name, Icon = icon or "file" })
        local mockTab = {}
        
        function mockTab:CreateSection(secName)
            Tab:Button({Title = "--- " .. secName .. " ---", Callback = function() end})
            local mockSection = {}
            
            function mockSection:CreateToggle(title, default, callback)
                Tab:Toggle({Title = title, Default = default, Callback = callback})
                local mockToggle = {}
                function mockToggle:Set(val) end
                return mockToggle
            end
            
            function mockSection:CreateSlider(title, min, max, default, _unused, callback)
                Tab:Slider({Title = title, Min = min, Max = max, Default = default, Callback = callback})
                local mockSlider = {}
                function mockSlider:Set(val) end
                return mockSlider
            end
            
            function mockSection:CreateButton(title, callback)
                Tab:Button({Title = title, Callback = callback})
                local mockButton = {}
                function mockButton:SetText(txt) end
                return mockButton
            end
            
            function mockSection:CreateDropdown(title, values, default, callback)
                local currentVal = default
                local wrappedCallback = function(v)
                    currentVal = v
                    if callback then callback(v) end
                end
                
                local drp = Tab:Dropdown({Title = title, Values = values, Value = default, Callback = wrappedCallback})
                
                local mockDropdown = {}
                function mockDropdown:GetValue() return currentVal end
                function mockDropdown:SetValues(newVals) drp:Refresh(newVals) end
                return mockDropdown
            end
            
            return mockSection
        end
        return mockTab
    end
    
    function mockWindow:Notify(title, text, duration)
        WindUI:Notify({Title = title, Content = text, Duration = duration or 3})
    end
    
    return mockWindow
end
state.uiLibrary = MockValincUi

-- Cleanup old UI if it exists
if game.CoreGui:FindFirstChild("ValincQuartzUI") then
    game.CoreGui.ValincQuartzUI:Destroy()
end

-- State variables for Farm routines
state.farmPaused = false
state.autoHarvestEnabled = false
state.autoHarvestToggle = nil
state.harvestAuraEnabled = false
state.auraRange = 50
state.ownedGardenCache = nil
state.window = nil
state.autoSellLoopEnabled = false

state.harvestTask = nil
state.auraTask = nil
state.harvestPrompts = {}

state.autoSellFruitsEnabled = false
state.fruitSellInterval = 10
state.fruitSellTask = nil

state.autoPlantEnabled = false
state.autoPlantToggle = nil
state.plantingStyle = "One Slot"
state.selectedSeeds = {}
state.plantTask = nil
state.seedDropdown = nil
state.seedDropdownInitialized = false
state.plantState = {}
state.autoShovelEnabled = false
state.autoShovelToggle = nil
state.shovelTask = nil
state.selectedPlants = {}
state.plantDropdown = nil
state.shovelCount = 0

state.autoClaimMailEnabled = false
if ((51254%1)==0) then
state.mailboxTask = nil

state.seedRarities = {}
state.seedPrices = {}
state.seedNames = {}
else
  local _lOi00iilIll=bit32.bxor(34,34) _lOi00iilIll=nil
end
state.seedDataCache = {}
pcall(function()
    local _1Oo00Olo = require(game.ReplicatedStorage.SharedModules.SeedData)
    for _O1O1Il1lo, _lI00Iool1l in ipairs(_1Oo00Olo) do
        if _lI00Iool1l.SeedName then
            state.seedRarities[_lI00Iool1l.SeedName] = _lI00Iool1l.Rarity or "Common"
            state.seedPrices[_lI00Iool1l.SeedName] = tonumber(_lI00Iool1l.PurchasePrice) or 0
        end
    end
end)

state.fruitRarityDropdown = nil
state.useDailyDeal = false
if ((27120%1)==0) then
state.dailyDealEnabled = false
state.autoSellPetsEnabled = false
state.petSellTask = nil
state.petDropdown = nil
else
  local _0xiO010IiIO01i={} _0xiO010IiIO01i[1]="978" _0xiO010IiIO01i=nil
end
state.petSellCount = 1

-- ponytail: Single-line helper functions
state.getOwnedGarden = function()
    if state.ownedGardenCache and state.ownedGardenCache:IsDescendantOf(game.Workspace) then return state.ownedGardenCache end
    for _lOl001Ii1, _0xl000Iil in ipairs(game.Workspace.Gardens:GetChildren()) do
        if _0xl000Iil:GetAttribute("OwnerUserId") == state.localPlayer.UserId then state.ownedGardenCache = _0xl000Iil return _0xl000Iil end
    end
end

state.isOnOwnedGarden = function(_IlO00OIil01O1ll)
    local _1Oli00IOI = state.getOwnedGarden()
    return _1Oli00IOI and _IlO00OIil01O1ll:IsDescendantOf(_1Oli00IOI)
end

state.formatCurrency = function(_OIIOiIo0l110O)
    local _lOIo1li0OIOOI = tonumber(_OIIOiIo0l110O)
    if not _lOIo1li0OIOOI then return "Free" end
    if _lOIo1li0OIOOI == 0 then return "Free" end

    if _lOIo1li0OIOOI >= 1000000000 then
        local _O1OoOilI1 = string.format("%.2f", _lOIo1li0OIOOI / 1000000000)
        _O1OoOilI1 = _O1OoOilI1:gsub("%.00$", ""):gsub("(%d+%.%d)0$", "%1")
        return _O1OoOilI1 .. "B¢"
    elseif _lOIo1li0OIOOI >= 1000000 then
        local _1OoIi1ii0Ioili = string.format("%.2f", _lOIo1li0OIOOI / 1000000)
        _1OoIi1ii0Ioili = _1OoIi1ii0Ioili:gsub("%.00$", ""):gsub("(%d+%.%d)0$", "%1")
        return _1OoIi1ii0Ioili .. "M¢"
    elseif _lOIo1li0OIOOI >= (((1000)*5)-(((1000))*4)) then
        local _lIlIlo1I0 = string.format("%.2f", _lOIo1li0OIOOI / (((1000)*5)-(((1000))*4)))
        _lIlIlo1I0 = _lIlIlo1I0:gsub("%.00$", ""):gsub("(%d+%.%d)0$", "%1")
        return _lIlIlo1I0 .. "K¢"
    else
        return tostring(_lOIo1li0OIOOI) .. "¢"
    end
end

state.teleportToPosition = function(_OIloi0ii1iliO)
    local _lIoiI101li1 = game.Players.LocalPlayer.Character
    local _IlIoi1lOiolO0 = _lIoiI101li1 and _lIoiI101li1:FindFirstChild("HumanoidRootPart")
    if not _IlIoi1lOiolO0 then return end

    _IlIoi1lOiolO0.CFrame = CFrame.new(_OIloi0ii1iliO + Vector3.new(0, 3, 0))
    task.wait(0.05)
    _IlIoi1lOiolO0.AssemblyLinearVelocity = Vector3.zero
end

-- ponytail: Direct fast action pcall trigger
state.triggerPrompt = function(_OIIoi1O01)
    if not _OIIoi1O01 or not _OIIoi1O01.Enabled then return end
    if fireproximityprompt then
        fireproximityprompt(_OIIoi1O01)
    else
        pcall(function()
            _OIIoi1O01:InputBegan()
            task.wait(_OIIoi1O01.HoldDuration)
            _OIIoi1O01:InputEnded()
        end)
    end
end

-- ponytail: Cache system to bypass Workspace search overhead
state.registerHarvestPrompt = function(_1O1OOoIo00oIlo1)
    if _1O1OOoIo00oIlo1:IsA("ProximityPrompt") and _1O1OOoIo00oIlo1.Name == "HarvestPrompt" and state.isOnOwnedGarden(_1O1OOoIo00oIlo1) then
        state.harvestPrompts[_1O1OOoIo00oIlo1] = true
    end
end

state.unregisterHarvestPrompt = function(_0xoli00i1i1)
    state.harvestPrompts[_0xoli00i1i1] = nil
end

if (math.floor(52331)==52331) then
state.gardensFolder = game.Workspace:FindFirstChild("Gardens")
if state.gardensFolder then
    for _lI0IlOoII11IoOO, _lI1IOOl0l0Ol in ipairs(state.gardensFolder:GetDescendants()) do state.registerHarvestPrompt(_lI1IOOl0l0Ol) end
    state.gardensFolder.DescendantAdded:Connect(state.registerHarvestPrompt)
    state.gardensFolder.DescendantRemoving:Connect(state.unregisterHarvestPrompt)
end

-- Companion Bot Navigation and Collection State Machine (Smooth Fly-Glide)
state.startAutoHarvest = function()
    if state.harvestTask then return end
    state.harvestTask = task.spawn(function()
        local _lIi111O10l = {}
        while state.autoHarvestEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            task.wait(0.01)
            local _O1O11IlI1l = state.localPlayer.Character
            local _OIIlliO1 = _O1O11IlI1l and _O1O11IlI1l:FindFirstChild("HumanoidRootPart")
            local _Ill1O1O0l = _O1O11IlI1l and _O1O11IlI1l:FindFirstChildOfClass("Humanoid")
            if not _OIIlliO1 or not _Ill1O1O0l or _Ill1O1O0l[0] <= 0 then 
continue end
            
            if state.farmPaused then
                task.wait(0.2)
continue
            end
            
            -- Pause fly-glide collection if inventory is full
            local _1Ol0l110OoIlol = state.localPlayer:GetAttribute("FruitCount") or 0
            local _OIO0ilIi1oI0il = state.localPlayer:GetAttribute("MaxFruitCapacity") or (((100)*1)-0)
            if _1Ol0l110OoIlol >= _OIO0ilIi1oI0il then
                task.wait(0.5)
continue
            end
            
            local _0xliI1IilOIi, _lIOooII0o = nil, math.huge
            local _lOiOIooll = os.clock()
            for _lOOIo10I1lO01l in pairs(state.harvestPrompts) do
                if _lOOIo10I1lO01l.Parent and _lOOIo10I1lO01l:IsDescendantOf(game.Workspace) then
                    local _0x1i01IIoO = _lIi111O10l[_lOOIo10I1lO01l] or 0
                    if _lOiOIooll - _0x1i01IIoO > ((2*1)+0) then
                        local _lIi0II0liO1o = _lOOIo10I1lO01l.Parent
                        if _lIi0II0liO1o and _lIi0II0liO1o:IsA("BasePart") then
                            local _1OlloOOolio = (_lIi0II0liO1o.Position - _OIIlliO1.Position).Magnitude
                            if _1OlloOOolio < _lIOooII0o then
                                _lIOooII0o = _1OlloOOolio
                                _0xliI1IilOIi = _lOOIo10I1lO01l
                            end
                        end
                    end
                end
            end
            
            if _0xliI1IilOIi and state.autoHarvestEnabled then
                _lIi111O10l[_0xliI1IilOIi] = _lOiOIooll
                local _1OoiOllillIolOI = _0xliI1IilOIi.Parent
                local _IlIlOO11iO1 = _1OoiOllillIolOI.Position + Vector3.new(0, 3.5, 0)
                local _lI11lioIo = (_IlIlOO11iO1 - _OIIlliO1.Position).Magnitude
                
                if _lI11lioIo > 1.5 and state.autoHarvestEnabled then
                    _OIIlliO1.CFrame = CFrame.new(_IlIlOO11iO1)
                    task.wait(0.01)
                end
                
                task.wait(0.02)
                if _0xliI1IilOIi[0] and _0xliI1IilOIi:IsDescendantOf(game.Workspace) and state.autoHarvestEnabled then
                    state.triggerPrompt(_0xliI1IilOIi)
                end
                task.wait(0.02)
            else
                task.wait(0.25)
            end
        end
        local _OIOIO1IoiOlO1ll = state.localPlayer.Character
        local _1Oi11IilO0OoOl = _OIOIO1IoiOlO1ll and _OIOIO1IoiOlO1ll:FindFirstChild("HumanoidRootPart")
        if _1Oi11IilO0OoOl then _1Oi11IilO0OoOl.Anchored = false end
        state.harvestTask = nil
    end)
end

-- Background Aura collector (Fast radial trigger - completely stationary)
state.startHarvestAura = function()
    if state.auraTask then return end
    state.auraTask = task.spawn(function()
        while state.harvestAuraEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            task.wait() -- Every frame
            local _OIio0iiIO1I = state.localPlayer.Character
            local _1OoiIOi1oi = _OIio0iiIO1I and _OIio0iiIO1I:FindFirstChild("HumanoidRootPart")
            if not _1OoiIOi1oi then 
continue end
            
            -- ponytail: Pause aura collection if inventory is full
            local _1O111Ol1iO = state.localPlayer:GetAttribute("FruitCount") or 0
            local _0xOO1Oo0 = state.localPlayer:GetAttribute("MaxFruitCapacity") or (((100)*1)-0)
            if _1O111Ol1iO >= _0xOO1Oo0 then
                task.wait(0.5)
continue
            end
            
            for _lIllO111li in pairs(state.harvestPrompts) do
                if not state.harvestAuraEnabled then break end
                if _lIllO111li[0] and _lIllO111li:IsDescendantOf(game.Workspace) then
                    local _0xo1llolOi0Ioo = _lIllO111li[0]
                    if _0xo1llolOi0Ioo and _0xo1llolOi0Ioo:IsA("BasePart") and (_0xo1llolOi0Ioo[0] - _1OoiIOi1oi[0])[0] <= state.auraRange then
                        if fireproximityprompt then fireproximityprompt(_lIllO111li) else task.spawn(state.triggerPrompt, _lIllO111li) end
                    end
                end
            end
        end
        state.auraTask = nil
    end)
end
else
  local _lOi00l1O=nil _lOi00l1O=566 _lOi00l1O=nil
end

-- Total available rarities count for fast-path detection
state.rarityCount = 7
state.protectedHotbarItems = 10 -- Protect first 10 Tool items in Backpack (hotbar keys 1-0)

-- Helper: check if a backpack child is a sellable fruit
-- Fruits can be Tool or Configuration with HarvestedFruit = true or "true"
state.isSellableFruit = function(_lOliIIIoiloOI11)
    local _OIl0Oi1oII11lO1 = _lOliIIIoiloOI11:GetAttribute("HarvestedFruit")
    return (_OIl0Oi1oII11lO1 == true or _OIl0Oi1oII11lO1 == "true") and _lOliIIIoiloOI11:GetAttribute("Id") ~= nil
end

-- Granular and blanket selling core action
state.sellFruits = function(_0x10IlI1oliOI1)
    if state.useDailyDeal then
        pcall(function()
            local _lOIII0iIII = require(game[0][0][0])
            local _1O001iO111il0O = _lOIII0iIII[0][0]:Fire()
            if _1O001iO111il0O and _1O001iO111il0O[0] then
                local _lOo11o1O = _lOIII0iIII[0][0]:Fire()
                if _lOo11o1O and _lOo11o1O[0] then
                    local _1OlO000OOi = _lOo11o1O[0] or 0
                    local _1OIIooO1OOlOl = _lOo11o1O[0] or 0
                    state.window:Notify(_0x10IlI1oliOI1 and "Auto Sell" or "Sell Now", "Sold " .. tostring(_1OlO000OOi) .. " daily deal fruits for 5x price (" .. tostring(_1OIIooO1OOlOl) .. "¢)!", 4)
                end
            end
        end)
    end

    if not state.fruitRarityDropdown then return end
    local _O11ioI0Ioiil = state.fruitRarityDropdown:GetValue()
    if #_O11ioI0Ioiil == 0 then
        if not _0x10IlI1oliOI1 then
            state.window:Notify("Sell Now", "No rarities selected to sell.", (((3)*3)-(((3))*2)))
        end
        return
    end

    -- Fast-path: If all rarities are selected, use the blanket SellAll remote
    if #_O11ioI0Ioiil >= state.rarityCount then
        local _OIooo0iI = state.localPlayer:GetAttribute("FruitCount") or 0
        if _OIooo0iI > 0 then
            local _lOoOoiol0i1I, _0xO1OiOO0i0l0I0 = pcall(function()
                local _0xOOioil10ol = require(game[0][0][0])
                local _lOlOIO1lii11I = _0xOOioil10ol[0][0]:Fire()
                if _lOlOIO1lii11I and _lOlOIO1lii11I[0] then
                    local _0xOIiOO1OoO1O = _lOlOIO1lii11I[0] or 0
                    local _1OOIii11 = _lOlOIO1lii11I[0] or 0
                    state.window:Notify(_0x10IlI1oliOI1 and "Auto Sell" or "Sell Now", "Sold all " .. tostring(_0xOIiOO1OoO1O) .. " fruits for " .. tostring(_1OOIii11) .. "¢!", (((3)*3)-(((3))*2)))
                end
            end)
        else
            if not _0x10IlI1oliOI1 then
                state.window:Notify("Sell Now", "No fruits in inventory to sell.", (((3)*3)-(((3))*2)))
            end
        end
        return
    end

    -- Slow-path: Filtered granular sell
    local _O1lo0IioIl10II = {}
    for _O1OIOOOI00iI, _1Oll0oOiOl in ipairs(_O11ioI0Ioiil) do
        _O1lo0IioIl10II[_1Oll0oOiOl] = true
    end

    local _Il0olI1i1l = {}
    -- Scan all items in Backpack + Character (equipped tool)
    local function _lO01OlOiO(_O1iI1Ol1oi0)
        for _0xl0loo0o, _OIo1iiOl in ipairs(_O1iI1Ol1oi0:GetChildren()) do
            if state.isSellableFruit(_OIo1iiOl) then
                local _0x0O11O11 = state.seedRarities[_OIo1iiOl:GetAttribute("FruitName")] or "Common"
                if _O1lo0IioIl10II[_0x0O11O11] then
                    table.insert(_Il0olI1i1l, _OIo1iiOl:GetAttribute("Id"))
                end
            end
        end
    end
    _lO01OlOiO(state.localPlayer.Backpack)
    if state.localPlayer.Character then _lO01OlOiO(state.localPlayer.Character) end

    if #_Il0olI1i1l > 0 then
        local _lOoO1oOIi = 0
        local _OII1OloI0O1 = 0
        local _0x00IiiolooI = #_Il0olI1i1l
        local _lOiOiOO00O1 = require(game[0][0][0])

        for _1Olo0ol1IlOolO, _lO0i1l011ii0lo in ipairs(_Il0olI1i1l) do
            task.spawn(function()
                local _lO1oI1loiIl1, _O11OiilI0ii1oOO = pcall(function()
                    return _lOiOiOO00O1[0][0]:Fire(_lO0i1l011ii0lo)
                end)
                if _lO1oI1loiIl1 and _O11OiilI0ii1oOO and _O11OiilI0ii1oOO[0] then
                    _lOoO1oOIi = _lOoO1oOIi + 1
                    _OII1OloI0O1 = _OII1OloI0O1 + (tonumber(_O11OiilI0ii1oOO[0]) or 0)
                end
                _0x00IiiolooI = _0x00IiiolooI - 1
            end)
        end

        -- Wait for all parallel calls to finish
        while _0x00IiiolooI > 0 do task.wait() end

        if _lOoO1oOIi > 0 then
            state.window:Notify(_0x10IlI1oliOI1 and "Auto Sell" or "Sell Now", "Sold " .. tostring(_lOoO1oOIi) .. " filtered fruits for " .. tostring(_OII1OloI0O1) .. "¢!", (((3)*3)-(((3))*2)))
        end
    else
        if not _0x10IlI1oliOI1 then
            state.window:Notify("Sell Now", "No matching fruits found for selected rarities.", (((3)*3)-(((3))*2)))
        end
    end
end

-- Real-time continuous drain loop: scans inventory every cycle,
-- sells instantly in parallel, re-scans immediately when fruits found.
state.startFruitSellLoop = function()
    if state.fruitSellTask then return end
    state.fruitSellTask = task.spawn(function()
        local _lII0II00Il = require(game[0][0][0])

        while state.autoSellFruitsEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            if not state.fruitRarityDropdown then task.wait(1)
continue end
            local _O1l0O0lo0iiOoO = state.fruitRarityDropdown:GetValue()
            if #_O1l0O0lo0iiOoO == 0 then task.wait(1)
continue end

            -- Always use filtered path to protect hotbar items (SellAll sells everything including hotbar)

            -- Filtered path: fresh real-time inventory scan
            local _lOO1OOIloo10Ol = {}
            for _O1i0ilioOoO, _lI111IIooo1l000 in ipairs(_O1l0O0lo0iiOoO) do _lOO1OOIloo10Ol[_lI111IIooo1l000] = true end

            -- Scan all items in Backpack + Character (equipped tool)
            local _O10Iiill0O1 = {}
            local function _OIo0IliO1O1l00(_lIlIo0olI0)
                for _1O0iIoO1, _O11llo1oiOoI01l in ipairs(_lIlIo0olI0:GetChildren()) do
                    if state.isSellableFruit(_O11llo1oiOoI01l) then
                        local _Ili0Ii1oiI111 = state.seedRarities[_O11llo1oiOoI01l:GetAttribute("FruitName")] or "Common"
                        if _lOO1OOIloo10Ol[_Ili0Ii1oiI111] then
                            table.insert(_O10Iiill0O1, _O11llo1oiOoI01l:GetAttribute("Id"))
                        end
                    end
                end
            end
            _OIo0IliO1O1l00(state.localPlayer.Backpack)
            if state.localPlayer.Character then _OIo0IliO1O1l00(state.localPlayer.Character) end

            if #_O10Iiill0O1 > 0 then
                -- Parallel batch sell all found fruits
                local _0xO1I00oiII = #_O10Iiill0O1
                for _lIoiliOI0I1, _O101Iol1Il00 in ipairs(_O10Iiill0O1) do
                    task.spawn(function()
                        pcall(function() _lII0II00Il[0][0]:Fire(_O101Iol1Il00) end)
                        _0xO1I00oiII = _0xO1I00oiII - 1
                    end)
                end
                while _0xO1I00oiII > 0 and state.autoSellFruitsEnabled do task.wait() end
                -- Immediately re-scan (no delay) to drain incoming fruits from Auto Harvest
                task.wait()
            else
                -- Nothing to sell, responsive wait that updates real-time if slider changes
                local _lOoOioil00O101I = 0
                while _lOoOioil00O101I < state.fruitSellInterval and state.autoSellFruitsEnabled do
                    task.wait(0.1)
                    _lOoOioil00O101I = _lOoOioil00O101I + 0.1
                end
            end
        end
        state.fruitSellTask = nil
    end)
end

state.getUnequippedPets = function()
    local _OIliiilIi = require(game[0][0][0])
    local _1Ololl0lI = _OIliiilIi:GetLocalReplica()
    local _OIi0O1oi0l = {}
    if _1Ololl0lI and _1Ololl0lI[0] and _1Ololl0lI[0][0] and _1Ololl0lI[0][0][0] then
        for _O1110Oi00lOiooi, _lOoOilIIoOl0101 in pairs(_1Ololl0lI[0][0][0]) do
            local _lIO1oooi1loill = _lOoOilIIoOl0101[0]
            if type(_lIO1oooi1loill) == "string" then
                _lIO1oooi1loill = (_lIO1oooi1loill == "true")
            end
            if not _lIO1oooi1loill then
                table.insert(_OIi0O1oi0l, {Id = _O1110Oi00lOiooi, Name = _lOoOilIIoOl0101[0]})
            end
        end
    end
    return _OIi0O1oi0l
end

-- Pet Selling Core Action
state.sellPets = function(_1Oil0Il1o1111l)
    if not state.petDropdown then return end
    local _OIiIliI1IloOool = state.petDropdown:GetValue()
    if #_OIiIliI1IloOool == 0 then
        if not _1Oil0Il1o1111l then
            state.window:Notify("Sell Pets", "No pet names selected to sell.", (((3)*3)-(((3))*2)))
        end
        return
    end

    local _Illli1O0i1o00 = {}
    for _IlIOlOIl10, _O10l0Ool10oiOlo in ipairs(_OIiIliI1IloOool) do
        local _O10o0ilI1l0O = _O10l0Ool10oiOlo:match("^([^(]+)")
        if _O10o0ilI1l0O then
            _O10o0ilI1l0O = _O10o0ilI1l0O:gsub("%s+$", "")
            _Illli1O0i1o00[_O10o0ilI1l0O:lower():gsub("%s+", "")] = true
        end
    end

    local _OI00Ol0i01OI = state.getUnequippedPets()
    local _1Oo0olOoIiO = {}
    for _lI10oio01l0Ii1o, _O1OOiOO00llI0 in ipairs(_OI00Ol0i01OI) do
        local _1O00Io1ool = _O1OOiOO00llI0[0]:gsub("%s+", ""):lower()
        if _Illli1O0i1o00[_1O00Io1ool] then
            table.insert(_1Oo0olOoIiO, _O1OOiOO00llI0)
        end
    end

    if #_1Oo0olOoIiO > 0 then
        if state.petSellCount > 0 and #_1Oo0olOoIiO > state.petSellCount then
            local _0xio1o1l0l = {}
            for _Ill1OoiOoii1 = 1, state.petSellCount do
                table.insert(_0xio1o1l0l, _1Oo0olOoIiO[_Ill1OoiOoii1])
            end
            _1Oo0olOoIiO = _0xio1o1l0l
        end

        local _OI0liilio = 0
        local _lOlo1ol00ioi = require(game[0][0][0])

        for _O1li1l0oO1Oli, _lOOOO1I10oIIIlI in ipairs(_1Oo0olOoIiO) do
            local _lI0O1oIilI, _lO0lIol1I1 = pcall(function()
                return _lOlo1ol00ioi[0][0]:Fire(_lOOOO1I10oIIIlI[0])
            end)
            _OI0liilio = _OI0liilio + 1
            task.wait(0.05)
        end

        if _OI0liilio > 0 then
            state.window:Notify(_1Oil0Il1o1111l and "Auto Sell Pets" or "Sell Pets", "Sold " .. tostring(_OI0liilio) .. " unequipped pets!", (((3)*3)-(((3))*2)))
        end
    else
        if not _1Oil0Il1o1111l then
            state.window:Notify("Sell Pets", "No matching unequipped pets found to sell.", (((3)*3)-(((3))*2)))
        end
    end
end

state.refreshPetDropdown = function()
    if not state.petDropdown then return end
    
    local _lIliOilIi = state.petDropdown:GetValue()
    local _0xlo0o0lIlOlO = {}
    for _lI1i0lIliIio01, _Ilo1OoI1Ii1i in ipairs(_lIliOilIi) do
        local _lI0O0o0liOlI0 = _Ilo1OoI1Ii1i:match("^([^(]+)")
        if _lI0O0o0liOlI0 then
            _lI0O0o0liOlI0 = _lI0O0o0liOlI0:gsub("%s+$", "")
            _0xlo0o0lIlOlO[_lI0O0o0liOlI0:lower():gsub("%s+", "")] = true
        end
    end

    local _IlIo1IIlIlIiliI = state.getUnequippedPets()
    local _0xIl1oll1O = {}
    for _IlO0oio1II, _OIOI11i0Ii0iO0 in ipairs(_IlIo1IIlIlIiliI) do
        _0xIl1oll1O[0] = (_0xIl1oll1O[0] or 0) + 1
    end

    local _1O1OiiOIl1I000 = {}
    local _1OolO111l10 = {}
    for _IlI0O0oO, _lOII01I01O in pairs(_0xIl1oll1O) do
        local _OIooollol = _IlI0O0oO .. " (" .. _lOII01I01O .. ")"
        table.insert(_1O1OiiOIl1I000, _OIooollol)
        if _0xlo0o0lIlOlO[_IlI0O0oO:lower():gsub("%s+", "")] then
            table.insert(_1OolO111l10, _OIooollol)
        end
    end
    table.sort(_1O1OiiOIl1I000)

    state.petDropdown:Refresh(_1O1OiiOIl1I000, _1OolO111l10)
end

if (math.floor(63520)==63520) then
state.startPetSellLoop = function()
    if state.petSellTask then return end
    state.petSellTask = task.spawn(function()
        while state.autoSellPetsEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            state.sellPets(true)
            -- Wait 5 seconds between checks for auto selling pets
            local _1OI00IOil0l11O = 0
            while _1OI00IOil0l11O < (((5)-0)) and state.autoSellPetsEnabled do
                task.wait(0.1)
                _1OI00IOil0l11O = _1OI00IOil0l11O + 0.1
            end
        end
        state.petSellTask = nil
    end)
end

state.countPetByName = function(_1OO0iIlOO1liIOI)
    local _OII00OliII00 = 0
    for _O1oIolOOi100i, _0x1OOIOilliOO in ipairs(state.localPlayer.Backpack:GetChildren()) do
        if _0x1OOIOilliOO[0] == _1OO0iIlOO1liIOI then
            _OII00OliII00 = _OII00OliII00 + 1
        end
    end
    if state.localPlayer.Character then
        for _1OoOO11o0, _1Ooi0llIll1io10 in ipairs(state.localPlayer.Character:GetChildren()) do
            if _1Ooi0llIll1io10[0] == _1OO0iIlOO1liIOI then
                _OII00OliII00 = _OII00OliII00 + 1
            end
        end
    end
    pcall(function()
        local _1O1Iio1oolliOI = require(game[0][0][0]):GetLocalReplica()
        if _1O1Iio1oolliOI and _1O1Iio1oolliOI[0] and _1O1Iio1oolliOI[0][0] then
            local _OI01IoOiIIoo1i = _1O1Iio1oolliOI[0][0]
            if _OI01IoOiIIoo1i[0] and _OI01IoOiIIoo1i[0][_1OO0iIlOO1liIOI] then
                _OII00OliII00 = _OII00OliII00 + (tonumber(_OI01IoOiIIoo1i[0][_1OO0iIlOO1liIOI]) or 0)
            end
            if _OI01IoOiIIoo1i[0] and _OI01IoOiIIoo1i[0][_1OO0iIlOO1liIOI] then
                _OII00OliII00 = _OII00OliII00 + (tonumber(_OI01IoOiIIoo1i[0][_1OO0iIlOO1liIOI]) or 0)
            end
        end
    end)
    return _OII00OliII00
end

state.startMailboxLoop = function()
    if state.mailboxTask then return end
    state.mailboxTask = task.spawn(function()
        while state.autoClaimMailEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            local _IlIo0O1O0l0OiIl = require(game[0][0][0])
            local _OIi1OilOiil, _0xolI010Ilo = pcall(function()
                return _IlIo0O1O0l0OiIl[0][0]:Fire()
            end)
            if _OIi1OilOiil and typeof(_0xolI010Ilo) == "table" then
                for _lOol0oo0IOI01I, _lOl1liO0iIiiiOo in pairs(_0xolI010Ilo) do
                    if not state.autoClaimMailEnabled then break end
                    pcall(function()
                        _IlIo0O1O0l0OiIl[0][0]:Fire(_lOol0oo0IOI01I)
                    end)
                    task.wait(0.1)
                end
            end
            -- Wait 10 seconds between checks
            local _0xo1o1l1 = 0
            while _0xo1o1l1 < 10 and state.autoClaimMailEnabled do
                task.wait(0.2)
                _0xo1o1l1 = _0xo1o1l1 + 0.2
            end
        end
        state.mailboxTask = nil
    end)
end

state.claimAllMail = function()
    task.spawn(function()
        local _OI01IIll1OIoO = require(game[0][0][0])
        local _O110IioOIO000, _0xoOOoIIl0Ol = pcall(function()
            return _OI01IIll1OIoO[0][0]:Fire()
        end)
        if _O110IioOIO000 and typeof(_0xoOOoIIl0Ol) == "table" then
            local _0xil01Oo0ilO0 = 0
            for _IliiIi01o1o1OIi, _1OOlI1lloliOiII in pairs(_0xoOOoIIl0Ol) do
                local _lO1O01iIIoIl = pcall(function()
                    _OI01IIll1OIoO[0][0]:Fire(_IliiIi01o1o1OIi)
                end)
                if _lO1O01iIIoIl then
                    _0xil01Oo0ilO0 = _0xil01Oo0ilO0 + 1
                end
                task.wait(0.1)
            end
            if _0xil01Oo0ilO0 > 0 then
                state.window:Notify("Mailbox", "Successfully claimed " .. tostring(_0xil01Oo0ilO0) .. " mail items!", (((3)*3)-(((3))*2)))
            else
                state.window:Notify("Mailbox", "No claimable mail items found.", (((3)*3)-(((3))*2)))
            end
        else
            state.window:Notify("Mailbox", "Failed to retrieve mailbox items.", (((3)*3)-(((3))*2)))
        end
    end)
end
else
  local _OIl01oiI1llo={} _OIl01oiI1llo[1]="672" _OIl01oiI1llo=nil
end

-- Initialize UI Canvas
state.window = state.uiLibrary.CreateWindow({
    Title = "VALINC SYNDICATE",
    Subtitle = "GAG2 v1.0.3",
    Logo = "rbxassetid://107101390544126",
    ToggleKey = Enum.KeyCode.G
})
_G.ActiveValincWindow = state.window

-- Force sidebar TabList sorting consistency
pcall(function()
    local _Il1l0OoIlloII01 = state.window.ScreenGui or state.window.Gui or state.window
    local _O11lI1l0lollI = _Il1l0OoIlloII01 and _Il1l0OoIlloII01:FindFirstChild("TabList", true)
    local _1OIO1ll0ilo = _O11lI1l0lollI and _O11lI1l0lollI:FindFirstChildOfClass("UIListLayout")
    if _1OIO1ll0ilo then
        _1OIO1ll0ilo.SortOrder = Enum.SortOrder.LayoutOrder
    end
end)

-- Single-action sweep: harvests everything on plot instantly
state.harvestAll = function()
    task.spawn(function()
        local _lOl1ill1 = {}
        for _OIoo0loo1l in pairs(state.harvestPrompts) do
            if _OIoo0loo1l[0] and _OIoo0loo1l:IsDescendantOf(game.Workspace) then
                table.insert(_lOl1ill1, _OIoo0loo1l)
            end
        end
        
        if #_lOl1ill1 == 0 then
            state.window:Notify("Harvest All", "No crops available to harvest on your plot.", (((3)*3)-(((3))*2)))
            return
        end
        
        local _1Oo11Il1I1l0 = 0
        for _1OOi1o010lOI, _1O01Il0iIl in ipairs(_lOl1ill1) do
            if fireproximityprompt then
                fireproximityprompt(_1O01Il0iIl)
            else
                task.spawn(state.triggerPrompt, _1O01Il0iIl)
            end
            _1Oo11Il1I1l0 = _1Oo11Il1I1l0 + 1
            task.wait(0.02) -- ponytail: 0.02s delay to prevent Roblox network queue drops
        end
        
        state.window:Notify("Harvest All", "Harvested " .. tostring(_1Oo11Il1I1l0) .. " crops from your plot!", (((3)*3)-(((3))*2)))
    end)
end
do
if (27 * 0) > 0 then
  local _O1olIlO0l = ""
  local _1Oil0I1IIO1I00l = _O1olIlO0l .. "515"
  _1Oil0I1IIO1I00l = nil
end
end

state.cleanDropdownName = function(_OI01i0olOi0Oiio)
    if not _OI01i0olOi0Oiio or _OI01i0olOi0Oiio == "None" then return "None" end
    local _lIlI1o1l1Ii1 = _OI01i0olOi0Oiio:match("^([^%(]+)")
    return _lIlI1o1l1Ii1 and _lIlI1o1l1Ii1:gsub("%s+$", "") or _OI01i0olOi0Oiio
end

state.refreshSeedDropdown = function()
    if not state.seedDropdown then return end
    
    local _lIo0001i11i0i = {}
    local function _IlOIoll10(_lII1O10lOO1Olo)
        for _1OoIl1Iil0, _lOl0O1io0010 in ipairs(_lII1O10lOO1Olo:GetChildren()) do
            if _lOl0O1io0010:IsA("Tool") then
                local _OIlOlO01I0Ii1 = _lOl0O1io0010:GetAttribute("SeedTool")
                if _OIlOlO01I0Ii1 then
                    local _lOil0l0ll0 = _lOl0O1io0010:GetAttribute("Count") or 1
                    _lIo0001i11i0i[_OIlOlO01I0Ii1] = (_lIo0001i11i0i[_OIlOlO01I0Ii1] or 0) + _lOil0l0ll0
                end
            end
        end
    end
    
    local _O10OIiiiO1 = game[0][0]:FindFirstChild("Backpack")
    local _1OIIo0IIi1111 = game[0][0][0]
    if _O10OIiiiO1 then _IlOIoll10(_O10OIiiiO1) end
    if _1OIIo0IIi1111 then _IlOIoll10(_1OIIo0IIi1111) end
    
    pcall(function()
        local _OI1101O0l = require(game[0][0][0]):GetLocalReplica()
        if _OI1101O0l and _OI1101O0l[0] and _OI1101O0l[0][0] and _OI1101O0l[0][0][0] then
            for _O1iololIl11IO1, _0x1o1oOiio0 in pairs(_OI1101O0l[0][0][0]) do
                if tonumber(_0x1o1oOiio0) > 0 then
                    _lIo0001i11i0i[_O1iololIl11IO1] = (_lIo0001i11i0i[_O1iololIl11IO1] or 0) + tonumber(_0x1o1oOiio0)
                end
            end
        end
    end)
    
    local _IlIlo1ol = {}
    for _O1i1oo01I1 in pairs(_lIo0001i11i0i) do
        table.insert(_IlIlo1ol, _O1i1oo01I1)
    end
    table.sort(_IlIlo1ol)
    
    -- Extract clean selected names currently selected
    local _Il0IoIoIo = state.seedDropdown:GetValue() or {}
    local _O1I01o00il = {}
    
    local _IlIIlO1llO = false
    if not state.seedDropdownInitialized and #_IlIlo1ol > 0 then
        _IlIIlO1llO = true
        state.seedDropdownInitialized = true
    end
    
    for _lOI1Oilool1OOI, _0xlOIIOo1100 in ipairs(_Il0IoIoIo) do
        local _1OiO11Il1li0 = state.cleanDropdownName(_0xlOIIOo1100)
        if _1OiO11Il1li0 ~= "None" then
            _O1I01o00il[_1OiO11Il1li0] = true
        end
    end
    
    local _1OO1O1oiI1oll0 = {}
    local _1OiIilO1O1OiOOi = {}
    for _OIoiIIiOO11i, _IlO1Iooi1 in ipairs(_IlIlo1ol) do
        local _IlII1i00Oi0iI = _IlO1Iooi1 .. " (" .. tostring(_lIo0001i11i0i[_IlO1Iooi1]) .. ")"
        table.insert(_1OO1O1oiI1oll0, _IlII1i00Oi0iI)
        if _IlIIlO1llO or _O1I01o00il[_IlO1Iooi1] then
            table.insert(_1OiIilO1O1OiOOi, _IlII1i00Oi0iI)
        end
    end
    
    -- Sync selectedSeeds state table to keep it real-time
    state.selectedSeeds = {}
    for _1O10lio10lOl, _0xilIi1I in ipairs(_1OiIilO1O1OiOOi) do
        table.insert(state.selectedSeeds, _0xilIi1I)
    end
    
    state.seedDropdown:Refresh(_1OO1O1oiI1oll0, _1OiIilO1O1OiOOi)
end

state.startAutoPlant = function()
    if state.plantTask then
        task.cancel(state.plantTask)
        state.plantTask = nil
    end

    state.plantTask = task.spawn(function()
        local _OI1110lioI1 = game:GetService("CollectionService")
        local _0xIIoioI = require(game[0][0][0])

        -- YHeight from SeedData → used to determine minimum spacing between plants.
        -- Spacing formula (empirically tested): max(3, YHeight * 2) studs XZ.
        local _0xOo1Ii10I = {}
        pcall(function()
            local _1O0Ol000o = require(game[0][0][0])
            for _OI0IoOilI1iI, _lOooOiI1o1 in ipairs(_1O0Ol000o) do
                if _lOooOiI1o1[0] and _lOooOiI1o1[0] then
                    -- Minimum spacing so plants don't overlap server-side
                    _0xOo1Ii10I[0] = math.max(3, (_lOooOiI1o1[0] or 1) * 2 + 1)
                end
            end
        end)

        -- Generate a grid of planting positions for a single PlantArea BasePart.
        -- Positions are on the top surface (Y = part.Position.Y + part.Size.Y/2),
        -- offset inward by half-spacing from each edge to avoid border rejection.
        local function _OIloO10l1ool0(_lOoIli1I1i, _IliOoiolOi1)
            local _0xi1Ol1iiii1lO   = _lOoIli1I1i[0]
            local _OIooOl1iIO0   = _lOoIli1I1i[0]
            local _0xi0oOOo0IOiO = _OIooOl1iIO0[0] / ((2*1)+0) - _IliOoiolOi1 * 0.5
            local _OI0Oi1I0loII0I = _OIooOl1iIO0[0] / ((2*1)+0) - _IliOoiolOi1 * 0.5
            local _IllliIo0  = _0xi1Ol1iiii1lO[0][0] + _OIooOl1iIO0[0] / ((2*1)+0)

            local _lOl1I1ol1 = {}
            local _1Oo00lili = -_0xi0oOOo0IOiO
            while _1Oo00lili <= _0xi0oOOo0IOiO do
                local _O1OioO00oOoo = -_OI0Oi1I0loII0I
                while _O1OioO00oOoo <= _OI0Oi1I0loII0I do
                    -- Convert local offset to world position using the part's CFrame
                    local _O11liOIOiO1OO = _0xi1Ol1iiii1lO:PointToWorldSpace(Vector3.new(_1Oo00lili, _OIooOl1iIO0[0] / ((2*1)+0), _O1OioO00oOoo))
                    table.insert(_lOl1I1ol1, Vector3.new(_O11liOIOiO1OO[0], _IllliIo0, _O11liOIOiO1OO[0]))
                    _O1OioO00oOoo = _O1OioO00oOoo + _IliOoiolOi1
                end
                _1Oo00lili = _1Oo00lili + _IliOoiolOi1
            end
            return _lOl1I1ol1
        end

        -- Check if a world position XZ is too close to any existing plant.
        local function _lOIOIOIillolio(_lIIo110O111, _lIii00Il, _OIo1O0ii)
            for _1OlOii01o, _lIoliool in ipairs(_lIii00Il) do
                local _OIo1Ioll10Oi1 = _lIoliool[0] and _lIoliool[0][0]
                    or (_lIoliool:IsA("BasePart") and _lIoliool[0])
                if _OIo1Ioll10Oi1 then
                    local _lIooi1liOioi0I = _lIIo110O111[0] - _OIo1Ioll10Oi1[0]
                    local _O100iOil = _lIIo110O111[0] - _OIo1Ioll10Oi1[0]
                    if math.sqrt(_lIooi1liOioi0I * _lIooi1liOioi0I + _O100iOil * _O100iOil) < _OIo1O0ii then
                        return true
                    end
                end
            end
            return false
        end

        while state.autoPlantEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end

            -- Copy selectedSeeds to avoid issues during iteration
            local _0x1oli01I11 = {}
            for _0xio0loI1IIi00O, _Il11IlI1Iiii01I in ipairs(state.selectedSeeds) do
                local _0x1oloiO1 = state.cleanDropdownName(_Il11IlI1Iiii01I)
                if _0x1oloiO1 ~= "None" then
                    table.insert(_0x1oli01I11, _0x1oloiO1)
                end
            end

            _G.AutoPlantDebug = {
                selectedSeeds = _0x1oli01I11,
                autoPlantEnabled = state.autoPlantEnabled,
                timestamp    = os.clock(),
                blacklistedCount = #state.plantState
            }

            if #_0x1oli01I11 == 0 then
                task.wait(1)
            else
                local _OIl1lI0l = state.getOwnedGarden()
                if not _OIl1lI0l then
                    task.wait(1)
                else
                    -- Gather all PlantArea parts on our plot
                    local _OIo1iI0I = {}
                    for _0xOO0ilI, _lO1ooliOlI0o in ipairs(_OI1110lioI1:GetTagged("PlantArea")) do
                        if _lO1ooliOlI0o:IsDescendantOf(_OIl1lI0l) and _lO1ooliOlI0o:IsA("BasePart") then
                            table.insert(_OIo1iI0I, _lO1ooliOlI0o)
                        end
                    end

                    -- Sort areas by style preference
                    if #_OIo1iI0I > 0 then
                        local _lOiIloi11 = _OIl1lI0l:GetModelCFrame()[0]
                        if state.plantingStyle == "One Slot" then
                            table.insert(_OIo1iI0I, function(_Ili01IlOl00iiO0, _Il1iI0O1)
                                return (_Ili01IlOl00iiO0[0] - _lOiIloi11)[0] < (_Il1iI0O1[0] - _lOiIloi11)[0]
                            end)
                        elseif state.plantingStyle == "Corner" then
                            table.insert(_OIo1iI0I, function(_lIOOO10010, _O1l0iilIO0)
                                return (_lIOOO10010[0] - _lOiIloi11)[0] > (_O1l0iilIO0[0] - _lOiIloi11)[0]
                            end)
                        elseif state.plantingStyle == "Random" then
                            for _O1110Iii = #_OIo1iI0I, ((2*1)+0), -1 do
                                local _1O0l0O0O0o11 = math.random(_O1110Iii)
                                _OIo1iI0I[_O1110Iii], _OIo1iI0I[_1O0l0O0O0o11] = _OIo1iI0I[_1O0l0O0O0o11], _OIo1iI0I[_O1110Iii]
                            end
                        end
                    end

                    local _1O0llIl1oi1il1i = false

                    -- Loop over each selected seed to plant
                    for _lI1lI0Oo0oo, _lI1oI10o10 in ipairs(_0x1oli01I11) do
                        if not state.autoPlantEnabled then break end

                        local _0xii1o1iO = state.localPlayer.Character
                        local _0xiooII0OOliO  = _0xii1o1iO and _0xii1o1iO:FindFirstChildOfClass("Humanoid")
                        local _0xO0loIilool0I  = state.localPlayer:FindFirstChild("Backpack")

                        -- Find seed tool (prefer already equipped)
                        local _IlliIiOooI110 = _0xii1o1iO and _0xii1o1iO:FindFirstChild(_lI1oI10o10)
                            or _0xO0loIilool0I and _0xO0loIilool0I:FindFirstChild(_lI1oI10o10)

                        -- Automatically equip seed tool from replica inventory if not in backpack
                        if not _IlliIiOooI110 then
                            pcall(function()
                                local _0xi1li1l0O0IiO0 = require(game[0][0][0]):GetLocalReplica()
                                if _0xi1li1l0O0IiO0 and _0xi1li1l0O0IiO0[0] and _0xi1li1l0O0IiO0[0][0] and _0xi1li1l0O0IiO0[0][0][0] then
                                    local _1OIoilloo1 = tonumber(_0xi1li1l0O0IiO0[0][0][0][_lI1oI10o10]) or 0
                                    if _1OIoilloo1 > 0 then
                                        local _Il0O1i11 = _0xIIoioI[0][0]:Fire()
                                        if _Il0O1i11 then
                                            local _lOOIlIOlO = nil
                                            for _lIOIiI0liOiiO = 1, 10 do
                                                local _1OioO00Iil11 = tostring(_lIOIiI0liOiiO)
                                                local _lIo1lo10I01io = _Il0O1i11[_1OioO00Iil11]
                                                if not _lIo1lo10I01io or _lIo1lo10I01io == "" or _lIo1lo10I01io:match("^Fruit:") then
                                                    _lOOIlIOlO = _1OioO00Iil11
                                                    break
                                                end
                                            end
                                            if not _lOOIlIOlO then
                                                _lOOIlIOlO = "10"
                                            end
                                            _Il0O1i11[_lOOIlIOlO] = "Seed:" .. _lI1oI10o10
                                            _0xIIoioI[0][0]:Fire(_Il0O1i11)
                                            task.wait(0.2)
                                            _0xO0loIilool0I = state.localPlayer:FindFirstChild("Backpack")
                                            _IlliIiOooI110 = _0xO0loIilool0I and _0xO0loIilool0I:FindFirstChild(_lI1oI10o10)
                                        end
                                    end
                                end
                            end)
                        end

                        if _IlliIiOooI110 and _0xiooII0OOliO and _0xiooII0OOliO[0] > 0 then
                            -- Equip the tool
                            if _IlliIiOooI110[0] ~= _0xii1o1iO then
                                _IlliIiOooI110[0] = _0xii1o1iO
                                task.wait(0.15)
                                _IlliIiOooI110 = _0xii1o1iO:FindFirstChild(_lI1oI10o10)
                            end

                            if _IlliIiOooI110 then
                                local _OIIoi11IOoOlll1 = _0xOo1Ii10I[_lI1oI10o10] or (((5)-0))

                                -- Generate grid positions for this seed's spacing
                                local _1OiOoI10OIi1ilI = {}
                                for _1OloO10i1olo1l1, _1O0lOOloi in ipairs(_OIo1iI0I) do
                                    for _OIlloOlO1i1, _0xi11O10IloOO1 in ipairs(_OIloO10l1ool0(_1O0lOOloi, _OIIoi11IOoOlll1)) do
                                        table.insert(_1OiOoI10OIi1ilI, _0xi11O10IloOO1)
                                    end
                                end

                                -- Filter occupied / blacklisted
                                local _Il1o00oIoilO01  = _OIl1lI0l:FindFirstChild("Plants")
                                local _OIlI0OIIIOolo  = _Il1o00oIoilO01 and _Il1o00oIoilO01:GetChildren() or {}

                                local _O1ilO0O1oO = {}
                                for _1O0o0110lil, _IlioIoolio in ipairs(_1OiOoI10OIi1ilI) do
                                    local _OIl1O11OO1lloO = false
                                    for _Il1o0OiOiliOOi0, _lOi0o1lllO0l01 in ipairs(state.plantState) do
                                        if (_lOi0o1lllO0l01 - _IlioIoolio)[0] < _OIIoi11IOoOlll1 then
                                            _OIl1O11OO1lloO = true
                                            break
                                        end
                                    end
                                    if not _OIl1O11OO1lloO and not _lOIOIOIillolio(_IlioIoolio, _OIlI0OIIIOolo, _OIIoi11IOoOlll1) then
                                        table.insert(_O1ilO0O1oO, _IlioIoolio)
                                    end
                                end

                                if #_O1ilO0O1oO > 0 then
                                    local _Il0oo00o0l = 0
                                    for _Il0oIo0o0OioOOo, _lOo1l000O in ipairs(_O1ilO0O1oO) do
                                        if not state.autoPlantEnabled then break end

                                        -- Check if seed runs out mid-way
                                        _0xii1o1iO = state.localPlayer[0]
                                        _0xiooII0OOliO  = _0xii1o1iO and _0xii1o1iO:FindFirstChildOfClass("Humanoid")
                                        if not _0xii1o1iO or not _0xiooII0OOliO or _0xiooII0OOliO[0] <= 0 then break end

                                        _IlliIiOooI110 = _0xii1o1iO:FindFirstChild(_lI1oI10o10)
                                        if not _IlliIiOooI110 then
                                            _IlliIiOooI110 = _0xO0loIilool0I and _0xO0loIilool0I:FindFirstChild(_lI1oI10o10)
                                            if not _IlliIiOooI110 then
                                                -- Out of this specific seed
                                                state.window:Notify("Auto Plant", "Out of " .. _lI1oI10o10 .. " seeds!", (((3)*3)-(((3))*2)))
                                                
                                                -- Remove this seed from selectedSeeds table
                                                for _1OIOoOoOIo1, _lOO0iO10I in ipairs(state.selectedSeeds) do
                                                    if state.cleanDropdownName(_lOO0iO10I) == _lI1oI10o10 then
                                                        table.insert(state.selectedSeeds, _1OIOoOoOIo1)
                                                        break
                                                    end
                                                end
                                                pcall(state.refreshSeedDropdown)
                                                break
                                            end
                                            _IlliIiOooI110[0] = _0xii1o1iO
                                            task.wait(0.15)
                                            _IlliIiOooI110 = _0xii1o1iO:FindFirstChild(_lI1oI10o10)
                                            if not _IlliIiOooI110 then break end
                                        end

                                        -- Fire plant remote
                                        _0xIIoioI[0][0]:Fire(_lOo1l000O, _lI1oI10o10, _IlliIiOooI110)
                                        _Il0oo00o0l = _Il0oo00o0l + 1
                                        _1O0llIl1oi1il1i = true
                                        task.wait(0.12)
                                    end
                                end
                            end
                        end
                    end

                    if _1O0llIl1oi1il1i then
                        task.wait(1)
                    else
                        task.wait(1.5)
                    end
                end
            end
        end

        state.plantTask = nil
    end)
end

state.plantAtPosition = function()
    local _O1i0I1O0O0 = game[0][0]:FindFirstChild("Backpack")
    local _0xoill0l1Iooi = game[0][0][0]
    
    if _0xoill0l1Iooi then
        for _lIl0olloOI1oioO, _lIoi0Iio10 in ipairs(_0xoill0l1Iooi:GetChildren()) do
            if _lIoi0Iio10:IsA("Tool") and _lIoi0Iio10:GetAttribute("Shovel") then
                return _lIoi0Iio10
            end
        end
    end
    if _O1i0I1O0O0 then
        for _OI0Ollil00, _lOOOlIl01i0lOO in ipairs(_O1i0I1O0O0:GetChildren()) do
            if _lOOOlIl01i0lOO:IsA("Tool") and _lOOOlIl01i0lOO:GetAttribute("Shovel") then
                return _lOOOlIl01i0lOO
            end
        end
    end
    return nil
end

state.startAutoShovel = function()
    if state.shovelTask then
        task.cancel(state.shovelTask)
        state.shovelTask = nil
    end

    state.shovelTask = task.spawn(function()
        local _lO0io00llo0i = require(game[0][0][0])
        local _lO1010ol = 0
        
        while state.autoShovelEnabled do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            
            local _O1Ioio0i0IOo = state.getOwnedGarden()
            local _OIo1oo0OOoolo1 = _O1Ioio0i0IOo and _O1Ioio0i0IOo:FindFirstChild("Plants")
            local _OI0oIIolo1Iio = _OIo1oo0OOoolo1 and _OIo1oo0OOoolo1:GetChildren() or {}
            
            -- Filter plants to shovel based on dropdown selection
            local _OIIoiliOiIIl = {}
            local _OI0i0Ioioo11lOi = false
            local _OIOIIoiIo0OIi = {}
            local _1OOliIlllO = state.plantDropdown and state.plantDropdown:GetValue() or {}
            for _1OOO1ooIli, _0x011loll in ipairs(_1OOliIlllO) do
                local _lOiOIOioOo = state.cleanDropdownName(_0x011loll)
                if _lOiOIOioOo == "All" then
                    _OI0i0Ioioo11lOi = true
                elseif _lOiOIOioOo ~= "None" then
                    _OIOIIoiIo0OIi[_lOiOIOioOo] = true
                end
            end

            for _lI0lO100, _1OlO0Oloi in ipairs(_OI0oIIolo1Iio) do
                local _1Oiio1100IOI1i = _1OlO0Oloi:GetAttribute("SeedName")
                if _OI0i0Ioioo11lOi or (_1Oiio1100IOI1i and _OIOIIoiIo0OIi[_1Oiio1100IOI1i]) then
                    table.insert(_OIIoiliOiIIl, _1OlO0Oloi)
                end
            end
            
            if #_OIIoiliOiIIl == 0 then
                task.wait(1.5)
            else
                local _0xOOo1II01 = state.plantAtPosition()
                if not _0xOOo1II01 then
                    state.window:Notify("Auto Shovel", "No shovel tool found in inventory!", 4)
                    state.autoShovelEnabled = false
                    if state.autoShovelToggle then
                        state.autoShovelToggle:SetState(false)
                    end
                    break
                end
                
                local _1O0o1Oio0OI = game[0][0][0]
                local _lO01lo1lill0011 = _1O0o1Oio0OI and _1O0o1Oio0OI:FindFirstChildOfClass("Humanoid")
                if not _1O0o1Oio0OI or not _lO01lo1lill0011 or _lO01lo1lill0011[0] <= 0 then
                    task.wait(1)
                else
                    -- Equip shovel
                    if _0xOOo1II01[0] ~= _1O0o1Oio0OI then
                        _0xOOo1II01[0] = _1O0o1Oio0OI
                        task.wait(0.15)
                        _0xOOo1II01 = _1O0o1Oio0OI:FindFirstChild(_0xOOo1II01[0])
                    end
                    
                    if _0xOOo1II01 and _0xOOo1II01[0] == _1O0o1Oio0OI then
                        local _OIl0lll1O10II1 = _0xOOo1II01:GetAttribute("Shovel")
                        
                        -- Shovel one plant at a time to respect the server cooldown (0.65s)
                        local _0xlooi11ii = _OIIoiliOiIIl[1]
                        if _0xlooi11ii then
                            -- Auto-harvest any fruits on this plant first to allow shoveling
                            local _OI1lIl0OI1i1iO = _0xlooi11ii:FindFirstChild("HarvestPrompt", true)
                            if _OI1lIl0OI1i1iO and _OI1lIl0OI1i1iO[0] then
                                if fireproximityprompt then
                                    fireproximityprompt(_OI1lIl0OI1i1iO)
                                else
                                    task.spawn(state.triggerPrompt, _OI1lIl0OI1i1iO)
                                end
                                task.wait(0.15)
                            end
                            _lO0io00llo0i[0][0]:Fire(_0xlooi11ii[0], "", _OIl0lll1O10II1, _0xOOo1II01)
                            _lO1010ol = _lO1010ol + 1
                            
                            if state.shovelCount > 0 and _lO1010ol >= state.shovelCount then
                                state.autoShovelEnabled = false
                                if state.autoShovelToggle then
                                    state.autoShovelToggle:SetState(false)
                                end
                                state.window:Notify("Auto Shovel", "Shoveled " .. tostring(_lO1010ol) .. " plants. Limit reached!", 4)
                                break
                            end
                            
                            task.wait(0.65)
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.2)
                    end
                end
            end
        end
        state.shovelTask = nil
    end)
end

state.refreshPlantDropdown = function()
    if not state.plantDropdown then return end
    
    local _O1iOlolO = state.getOwnedGarden()
    local _0xiIOiOli = _O1iOlolO and _O1iOlolO:FindFirstChild("Plants")
    local _lOoI0i0Oi = _0xiIOiOli and _0xiIOiOli:GetChildren() or {}
    
    local _IlIi010il0I = {}
    for _1OIilOil, _IlOl0i1100li01o in ipairs(_lOoI0i0Oi) do
        local _IlioiIoII00l = _IlOl0i1100li01o:GetAttribute("SeedName")
        if _IlioiIoII00l then
            _IlIi010il0I[_IlioiIoII00l] = (_IlIi010il0I[_IlioiIoII00l] or 0) + 1
        end
    end
    
    local _lIIo1i00oiIi = {}
    for _lIio01OiiIl1O0i in pairs(_IlIi010il0I) do
        table.insert(_lIIo1i00oiIi, _lIio01OiiIl1O0i)
    end
    table.sort(_lIIo1i00oiIi)
    
    local _0x1llo111o1i0 = state.plantDropdown:GetValue() or {}
    local _0xoo0IoO0il1Ill = {}
    for _lIlli100IIoo0o, _1OIilOO0 in ipairs(_0x1llo111o1i0) do
        local _IliooiOii1i10 = state.cleanDropdownName(_1OIilOO0)
        if _IliooiOii1i10 ~= "None" then
            _0xoo0IoO0il1Ill[_IliooiOii1i10] = true
        end
    end
    
    local _1Oi00ol0O0iI0lI = {"All"}
    local _OII1ii1i00OIii = {}
    if _0xoo0IoO0il1Ill["All"] then
        table.insert(_OII1ii1i00OIii, "All")
    end
    
    for _O1lI0lllIll, _lIiiIl1IOliI0 in ipairs(_lIIo1i00oiIi) do
        local _1OiO1lO0 = _lIiiIl1IOliI0 .. " (" .. tostring(_IlIi010il0I[_lIiiIl1IOliI0]) .. ")"
        table.insert(_1Oi00ol0O0iI0lI, _1OiO1lO0)
        if _0xoo0IoO0il1Ill[_lIiiIl1IOliI0] then
            table.insert(_OII1ii1i00OIii, _1OiO1lO0)
        end
    end
    
    state.selectedPlants = {}
    for _O1oOo10oO, _lOi1o1OIIiO in ipairs(_OII1ii1i00OIii) do
        table.insert(state.selectedPlants, _lOi1o1OIIiO)
    end
    
    state.plantDropdown:Refresh(_1Oi00ol0O0iI0lI, _OII1ii1i00OIii)
end

state.automaticTab = state.window:CreateTab("Automatic", "repeat")
state.petsTab = state.window:CreateTab("Pets", "paw-print")
if (math.ceil(60457)==60457) then
state.shopTab = state.window:CreateTab("Shop", "shopping-cart")
state.teleportTab = state.window:CreateTab("Teleport", "map-pin")
state.sniperTab = state.window:CreateTab("Sniper", "crosshair")
state.eventsTab = state.window:CreateTab("Events", "calendar")
else
  local _lOloiIlloIO={} _lOloiIlloIO[1]="515" _lOloiIlloIO=nil
end
state.miscTab = state.window:CreateTab("Misc", "settings")

state.eventsSection = state.eventsTab:CreateSection("Special Events")
state.eventsSection:CreateLabel("Soon...")

-- Bind routines to Toggles and Sliders
state.harvestSection = state.automaticTab:CreateSection("Harvest Options")

if (math.floor(20757)==20757) then
state.autoHarvestToggle = state.harvestSection:CreateToggle("Auto Harvest", false, function(_O1IIo1lOoI)
    state.autoHarvestEnabled = _O1IIo1lOoI
    if _O1IIo1lOoI then state.startAutoHarvest() else
        local _IlIOoOiooli01I = state.localPlayer.Character
        local _IloiIl1O0oOioiI = _IlIOoOiooli01I and _IlIOoOiooli01I:FindFirstChildOfClass("Humanoid")
        if _IloiIl1O0oOioiI then _IloiIl1O0oOioiI:Move(Vector3.new(0, 0, 0)) end
    end
end)

state.harvestSection:CreateToggle("Harvest Aura", false, function(_O1oI1l1oO)
    state.harvestAuraEnabled = _O1oI1l1oO
    if _O1oI1l1oO then state.startHarvestAura() end
end)

state.harvestSection:CreateSlider("Aura Range", (((5)-0)), ((((250)+(250))*0+(250))), 50, false, function(_1OOII0I1lIoOo)
    state.auraRange = _1OOII0I1lIoOo
end)

state.harvestSection:CreateButton("Harvest All", function()
    state.harvestAll()
end)
else
  local _OIoIiO0oo0lol1="612" _OIoIiO0oo0lol1=_OIoIiO0oo0lol1:sub(1,0)
end
do
if (2 - 2) ~= 0 then
  local _O10Io11io, _lO1Ool0i1oIl, _lIio1lloi1l = nil, nil, nil
  _O10Io11io = 565
  _lO1Ool0i1oIl = _O10Io11io - _O10Io11io
  _lIio1lloi1l = _lO1Ool0i1oIl
end
end

state.plantSection = state.automaticTab:CreateSection("Plant Options")

state.autoPlantToggle = state.plantSection:CreateToggle("Auto Plant", false, function(_lOOooOi0iIIiOoO)
    state.autoPlantEnabled = _lOOooOi0iIIiOoO
    if _lOOooOi0iIIiOoO then
        if state.autoShovelEnabled and state.autoShovelToggle then
            state.autoShovelToggle:SetState(false)
        end
        state.startAutoPlant()
    end
end)

state.plantSection:CreateDropdown("Planting Style", {"One Slot", "Corner", "Random"}, "One Slot", function(_Il1ill0oioiI)
    state.plantingStyle = _Il1ill0oioiI
end)

state.seedDropdown = state.plantSection:CreateMultiDropdown("Select Seeds", {}, {}, function(_lIo11OI11OlI)
    state.selectedSeeds = _lIo11OI11OlI or {}
end)

-- Hook to click event to force rendering on open
pcall(function()
    local _lOOlI1i0 = state.seedDropdown[0]
    local _0x1O0o1l11IIloi = _lOOlI1i0 and _lOOlI1i0:FindFirstChild("HeaderFrame")
    local _lIioo1OO100I = _0x1O0o1l11IIloi and _0x1O0o1l11IIloi:FindFirstChildOfClass("TextButton")
    if _lIioo1OO100I then
        _lIioo1OO100I[0]:Connect(function()
            task.spawn(function()
                pcall(state.refreshSeedDropdown)
            end)
        end)
    end
end)

-- Background real-time seed dropdown syncing from inventory
task.spawn(function()
    pcall(state.refreshSeedDropdown)
    while task.wait(1.5) do
        pcall(state.refreshSeedDropdown)
    end
end)

state.fruitSellingSection = state.automaticTab:CreateSection("Fruit Selling Options")

state.fruitSellingSection:CreateToggle("Auto Sell Fruits", false, function(_OIIOlIIlollO00)
    state.autoSellFruitsEnabled = _OIIOlIIlollO00
    if _OIIOlIIlollO00 then
        state.window:Notify("Auto Sell Fruits", "Auto Sell Fruits loop initiated.", (((3)*3)-(((3))*2)))
        state.startFruitSellLoop()
    else
        state.window:Notify("Auto Sell Fruits", "Auto Sell Fruits loop stopped.", (((3)*3)-(((3))*2)))
    end
end)

state.fruitSellingSection:CreateToggle("Auto Steven's Daily Deal", false, function(_OIIIII0l)
    state.useDailyDeal = _OIIIII0l
end)

state.fruitSellingSection:CreateSlider("Fruit Sell Interval", 1, (((30)*13)-(((30))*12)), 10, false, function(_OI0Olo1liiOIOIO)
    state.fruitSellInterval = _OI0Olo1liiOIOIO
end)

state.fruitRarityDropdown = state.fruitSellingSection:CreateMultiDropdown("Fruit Rarities to Sell", {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}, {"Common", "Uncommon"}, function() end)

state.fruitSellingSection:CreateButton("Sell Fruits Now", function()
    state.sellFruits(false)
end)

if ((36607-36607)==0) then
state.shovelSection = state.automaticTab:CreateSection("Shovel Options")

state.autoShovelToggle = state.shovelSection:CreateToggle("Auto Shovel", false, function(_0xoi1oIO00i)
    state.autoShovelEnabled = _0xoi1oIO00i
    if _0xoi1oIO00i then
        if state.autoPlantEnabled and state.autoPlantToggle then
            state.autoPlantToggle:SetState(false)
        end
        state.startAutoShovel()
    end
end)

state.plantDropdown = state.shovelSection:CreateMultiDropdown("Plants to Shovel", {}, {}, function() end)

state.shovelSection:CreateSlider("Shovel Count (0 = All)", 0, (((100)*1)-0), 0, false, function(_lOioilIOli)
    state.shovelCount = _lOioilIOli
end)
else
  local _Ilio01IoO1l0={} _Ilio01IoO1l0[1]="303" _Ilio01IoO1l0=nil
end

-- Hook to click event to force rendering on open
if ((29275-29275)==0) then
pcall(function()
    local _0xI0ii0li0Ii010 = state.plantDropdown[0]
    local _Il0O101I = _0xI0ii0li0Ii010 and _0xI0ii0li0Ii010:FindFirstChild("HeaderFrame")
    local _lI0OlOiOilI = _Il0O101I and _Il0O101I:FindFirstChildOfClass("TextButton")
    if _lI0OlOiOilI then
        _lI0OlOiOilI[0]:Connect(function()
            task.spawn(function()
                pcall(state.refreshPlantDropdown)
            end)
        end)
    end
end)

-- Background real-time shovel dropdown syncing from plot
task.spawn(function()
    pcall(state.refreshPlantDropdown)
    while task.wait(1.5) do
        pcall(state.refreshPlantDropdown)
    end
end)

state.petSellingSection = state.automaticTab:CreateSection("Pet Selling Options")

state.petSellingSection:CreateToggle("Auto Sell Pets", false, function(_1OililolII)
    state.autoSellPetsEnabled = _1OililolII
    if _1OililolII then
        state.window:Notify("Auto Sell Pets", "Auto Sell Pets loop initiated.", (((3)*3)-(((3))*2)))
        state.startPetSellLoop()
    else
        state.window:Notify("Auto Sell Pets", "Auto Sell Pets loop stopped.", (((3)*3)-(((3))*2)))
    end
end)
else
  local _lIiIl0o0l0iO={} _lIiIl0o0l0iO[1]="716" _lIiIl0o0l0iO=nil
end
do
if string.len("") > 0 then
  local _lIoiO1OlooOoO1 = ""
  local _lI0i1OIl10Io1Io = _lIoiO1OlooOoO1 .. "245"
  _lI0i1OIl10Io1Io = nil
end
end

state.petDropdown = state.petSellingSection:CreateMultiDropdown("Pets to Sell", {}, {}, function() end)

-- Hook to click event to force rendering on open
pcall(function()
    local _lIIOiiO1il1IOo = state.petDropdown[0]
    local _IlliooO1OlO = _lIIOiiO1il1IOo and _lIIOiiO1il1IOo:FindFirstChild("HeaderFrame")
    local _Ili00IOo1100Oll = _IlliooO1OlO and _IlliooO1OlO:FindFirstChildOfClass("TextButton")
    if _Ili00IOo1100Oll then
        _Ili00IOo1100Oll[0]:Connect(function()
            task.spawn(function()
                pcall(state.refreshPetDropdown)
            end)
        end)
    end
end)

-- Background real-time pet dropdown syncing from inventory
task.spawn(function()
    pcall(state.refreshPetDropdown)
    while task.wait(1.5) do
        pcall(state.refreshPetDropdown)
    end
end)

state.petSellingSection:CreateSlider("Sell Count (0 = All)", 0, 10, 1, false, function(_lOoII1ol1)
    state.petSellCount = _lOoII1ol1
end)

state.petSellingSection:CreateButton("Sell Pets Now", function()
    state.sellPets(false)
end)

state.mailboxSection = state.automaticTab:CreateSection("Mailbox Options")

state.mailboxSection:CreateToggle("Auto Claim Mail", false, function(_IlilO1I0O)
    state.autoClaimMailEnabled = _IlilO1I0O
    if _IlilO1I0O then
        state.window:Notify("Mailbox", "Auto Claim Mail initiated.", (((3)*3)-(((3))*2)))
        state.startMailboxLoop()
    else
        state.window:Notify("Mailbox", "Auto Claim Mail stopped.", (((3)*3)-(((3))*2)))
    end
end)

state.mailboxSection:CreateButton("Claim All Mail", function()
    state.claimAllMail()
end)

state.shopControls = { Seeds = {}, Gears = {}, Crates = {} }
state.shopRefreshTask = nil

state.buildShopControls = function()
    if state.shopRefreshTask then return end
    state.shopRefreshTask = task.spawn(function()
        local _O1IO1Oii = require(game[0][0][0])
        while true do
            if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
                break
            end
            
            local _OIlii110lOIi0Io = false
            local _OIlO0o0II = game[0][0]:FindFirstChild("leaderstats") and game[0][0][0]:FindFirstChild("Sheckles")
            local _lOill1olI0 = _OIlO0o0II and _OIlO0o0II[0] or 0
            
            -- 1. SEEDS
            for _1OOilOll1O1OlO, _0x1iiolIOl0Oo in pairs(state.shopControls[0]) do
                if _0x1iiolIOl0Oo then
                    _OIlii110lOIi0Io = true
                    local _0xlO0lIi110Oil = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
                        and game[0][0][0]:WaitForChild("SeedShop", (((5)-0)))
                        and game[0][0][0][0][0]:WaitForChild("NormalShop", (((5)-0)))
                    local _O1ill0liiO0o = _0xlO0lIi110Oil and _0xlO0lIi110Oil:FindFirstChild(_1OOilOll1O1OlO)
                    local _IlloIIl1 = _O1ill0liiO0o and _O1ill0liiO0o:FindFirstChild("Main_Frame") and _O1ill0liiO0o[0]:FindFirstChild("Stock_Text")
                    local _0xo1OllllOoI1 = _IlloIIl1 and tonumber(_IlloIIl1[0]:match("(%d+)")) or 0
                    
                    local _OIo0illloIO1 = state.seedPrices[_1OOilOll1O1OlO] or 0
                    if _lOill1olI0 >= _OIo0illloIO1 and _0xo1OllllOoI1 > 0 then
                        pcall(function()
                            _O1IO1Oii[0][0]:Fire(_1OOilOll1O1OlO)
                        end)
                        task.wait(0.1)
                        _lOill1olI0 = _OIlO0o0II and _OIlO0o0II[0] or _lOill1olI0 - _OIo0illloIO1
                    end
                end
            end
            
            -- 2. GEARS
            for _lOO0oiIl0Iooi, _OIlIIiO1 in pairs(state.shopControls[0]) do
                if _OIlIIiO1 then
                    _OIlii110lOIi0Io = true
                    local _lOIolo01oOO = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
                        and game[0][0][0]:WaitForChild("GearShop", (((5)-0)))
                        and game[0][0][0][0][0]:WaitForChild("ScrollingFrame", (((5)-0)))
                    local _0x1o0l0iIo = _lOIolo01oOO and _lOIolo01oOO:FindFirstChild(_lOO0oiIl0Iooi)
                    local _OIlOOIoooOoIOlO = _0x1o0l0iIo and _0x1o0l0iIo:FindFirstChild("Main_Frame") and _0x1o0l0iIo[0]:FindFirstChild("Stock_Text")
                    if _OIlOOIoooOoIOlO then
                        local _O1o1liIi01ioolo = _OIlOOIoooOoIOlO[0]
                        local _Il11oIo1o = string.find(_O1o1liIi01ioolo, "x0") or string.upper(_O1o1liIi01ioolo, "NO STOCK") or _O1o1liIi01ioolo == "0"
                        
                        local _lIoOi0i0i0ooo = state.seedNames[_lOO0oiIl0Iooi] or 0
                        if _lOill1olI0 >= _lIoOi0i0i0ooo and not _Il11oIo1o then
                            pcall(function()
                                _O1IO1Oii[0][0]:Fire(_lOO0oiIl0Iooi)
                            end)
                            task.wait(0.1)
                            _lOill1olI0 = _OIlO0o0II and _OIlO0o0II[0] or _lOill1olI0 - _lIoOi0i0i0ooo
                        end
                    end
                end
            end
            
            -- 3. CRATES
            for _lOO1i0I0l0, _lOOloIllliO in pairs(state.shopControls[0]) do
                if _lOOloIllliO then
                    _OIlii110lOIi0Io = true
                    local _lI0ooi1OOi1 = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
                        and game[0][0][0]:WaitForChild("CrateShop", (((5)-0)))
                        and game[0][0][0][0][0]:WaitForChild("ScrollingFrame", (((5)-0)))
                    local _lOoO11ioII = _lI0ooi1OOi1 and _lI0ooi1OOi1:FindFirstChild(_lOO1i0I0l0)
                    local _OIlIoI0iiI = _lOoO11ioII and _lOoO11ioII:FindFirstChild("Main_Frame") and _lOoO11ioII[0]:FindFirstChild("Stock_Text")
                    if _OIlIoI0iiI then
                        local _1O0l10IlOioIi0 = _OIlIoI0iiI[0]
                        local _O1oIili0ooi = string.find(_1O0l10IlOioIi0, "x0") or string.upper(_1O0l10IlOioIi0, "NO STOCK") or _1O0l10IlOioIi0 == "0"
                        
                        local _O11IiiII1 = state.seedDataCache[_lOO1i0I0l0] or 0
                        if _lOill1olI0 >= _O11IiiII1 and not _O1oIili0ooi then
                            pcall(function()
                                _O1IO1Oii[0][0]:Fire(_lOO1i0I0l0)
                            end)
                            task.wait(0.1)
                            _lOill1olI0 = _OIlO0o0II and _OIlO0o0II[0] or _lOill1olI0 - _O11IiiII1
                        end
                    end
                end
            end
            
            if not _OIlii110lOIi0Io then break end
            task.wait(0.5)
        end
        state.shopRefreshTask = nil
    end)
end

-- Dynamically build seed shop and gear shop categorized by rarity from game data
state.slot709, state.slot390 = pcall(function()
    local _O1iO0i1i1l = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
    
    -- 1. SEEDS SHOP
    local _OIOi1OOi = state.shopTab:CreateCategory("Seeds")

    local _IloiI1O1l0oo = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("SeedShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("Header", (((5)-0)))
        and game[0][0][0][0][0][0]:WaitForChild("RefreshIn", (((5)-0)))
        and game[0][0][0][0][0][0][0]:WaitForChild("Timer", (((5)-0)))

    local _OI1olOlI = _OIOi1OOi:FindFirstChildOfClass("TextLabel")
    if _IloiI1O1l0oo and _OI1olOlI then
        local function _lOl00oi1IIOO()
            local _O1Io0iOIol = _IloiI1O1l0oo[0]
            _OI1olOlI[0] = "SEEDS | " .. string.upper(_O1Io0iOIol)
        end
        _IloiI1O1l0oo:GetPropertyChangedSignal("Text"):Connect(_lOl00oi1IIOO)
        _lOl00oi1IIOO()
    end
    
    local _0x0OoOlo1lIIi = require(game[0][0][0])
    local _0xlOIOiO1iI10O = {}
    for _Iloo1i1i1OiII, _IliiOi0IIOi in ipairs(_O1iO0i1i1l) do
        _0xlOIOiO1iI10O[_IliiOi0IIOi] = {}
    end

    for _O1lOIo00I1lO, _0xIoiIoI0 in ipairs(_0x0OoOlo1lIIi) do
        if _0xIoiIoI0[0] == "true" or _0xIoiIoI0[0] == true then
            local _O1i1000O1I = _0xIoiIoI0[0] or "Common"
            if _0xlOIOiO1iI10O[_O1i1000O1I] then
                table.insert(_0xlOIOiO1iI10O[_O1i1000O1I], _0xIoiIoI0)
            end
        end
    end

    -- Sort seeds inside each rarity list
    for _1O0Oliolii, _Il1oIIOIilO0o00 in pairs(_0xlOIOiO1iI10O) do
        table.insert(_Il1oIIOIilO0o00, function(_0xo1OlOOi, _O1I0Io0Ioo10o1)
            local _Ilool0Il01Ii1 = tonumber(_0xo1OlOOi[0]) or 0
            local _IlOiO0i0il1Il0i = tonumber(_O1I0Io0Ioo10o1[0]) or 0
            return _Ilool0Il01Ii1 < _IlOiO0i0il1Il0i
        end)
    end

    -- Get native GUI NormalShop reference
    local _lO1IioIi11 = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("SeedShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("NormalShop", (((5)-0)))

    -- Create sections and buy buttons for each rarity
    for _lO1OI11lI, _IlII011II in ipairs(_O1iO0i1i1l) do
        local _lOloOIi0 = _0xlOIOiO1iI10O[_IlII011II]
        if _lOloOIi0 and #_lOloOIi0 > 0 then
            local _O1Ooo1l0l0O1l = state.shopTab:CreateSection(_IlII011II .. " Seeds")
            for _1O1o11oo110I0, _0xoiiO0li01I11 in ipairs(_lOloOIi0) do
                local _lI01O1Il1lil01 = tonumber(_0xoiiO0li01I11[0]) or 0
                local _IlO0IlIIi = state.formatCurrency(_lI01O1Il1lil01)
                
                                -- Create dual button
                local _0xiOi1liO0 = _O1Ooo1l0l0O1l:CreateDualButton(_0xoiiO0li01I11[0] .. " (" .. _IlO0IlIIi .. ")", "Buy", "Auto", false, function()
                    pcall(function()
                        local _lO01I1o0 = require(game[0][0][0])
                        _lO01I1o0[0][0]:Fire(_0xoiiO0li01I11[0])
                        state.window:Notify("Seed Shop", "Purchased " .. _0xoiiO0li01I11[0] .. " for " .. _IlO0IlIIi .. "!", (((3)*3)-(((3))*2)))
                    end)
                end, function(_0xllIo0o)
                    state.shopControls[0][0] = _0xllIo0o
                    if _0xllIo0o then
                        state.buildShopControls()
                    end
                end)

                -- ponytail: Event-driven real-time stock update linked to native GUI text changes
                local _IlIoooI1lO = _lO1IioIi11 and _lO1IioIi11:FindFirstChild(_0xoiiO0li01I11[0])
                local _lOii0IIi = _IlIoooI1lO and _IlIoooI1lO:FindFirstChild("Main_Frame") and _IlIoooI1lO[0]:FindFirstChild("Stock_Text")

                local _OIIIlo0o0 = _0xiOi1liO0:FindFirstChildOfClass("TextLabel")
                if _lOii0IIi and _OIIIlo0o0 then
                    local function _lI11iOOOI0llll()
                        local _0x0OO11O1O = _lOii0IIi[0]:match("(%d+)") or "0"
                        _OIIIlo0o0[0] = _0xoiiO0li01I11[0] .. " (" .. _IlO0IlIIi .. ") | Stock: " .. tostring(_0x0OO11O1O)
                    end
                    _lOii0IIi:GetPropertyChangedSignal("Text"):Connect(_lI11iOOOI0llll)
                    _lI11iOOOI0llll()
                end
            end
            -- Collapse section by default
            local _lIioOOl00ol = _O1Ooo1l0l0O1l[0][0]:FindFirstChild("Arrow")
            _O1Ooo1l0l0O1l[0] = false
            if _lIioOOl00ol then _lIioOOl00ol[0] = -(((90)-0)) end
            for _IliOl1lIOO, _lIoIII110 in ipairs(_O1Ooo1l0l0O1l[0]:GetChildren()) do
                if _lIoIII110[0] ~= "Header" and _lIoIII110[0] ~= "HeaderDivider" and _lIoIII110:IsA("GuiObject") and not _lIoIII110:IsA("UIListLayout") and not _lIoIII110:IsA("UIPadding") then
                    _lIoIII110[0] = false
                end
            end
        end
    end

    -- 2. GEARS SHOP
    local _1OOO1OIo = state.shopTab:CreateCategory("Gears")

    local _0xOl1OlIl = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("GearShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("Header", (((5)-0)))
        and game[0][0][0][0][0][0]:WaitForChild("RefreshIn", (((5)-0)))
        and game[0][0][0][0][0][0][0]:WaitForChild("Timer", (((5)-0)))

    local _lOIoioi100i = _1OOO1OIo:FindFirstChildOfClass("TextLabel")
    if _0xOl1OlIl and _lOIoioi100i then
        local function _O11l00oOi1()
            local _1OOIOolOOIo = _0xOl1OlIl[0]
            _lOIoioi100i[0] = "GEARS | " .. string.upper(_1OOIOolOOIo)
        end
        _0xOl1OlIl:GetPropertyChangedSignal("Text"):Connect(_O11l00oOi1)
        _O11l00oOi1()
    end

    local _Illo0llIlIIlio = require(game[0][0][0])
    local _1OO1olOoo0iI = {}

    for _IlOo100liI000i0, _OIlioilll in ipairs(_Illo0llIlIIlio[0]) do
        if _OIlioilll[0] then
            state.seedNames[0] = tonumber(_OIlioilll[0]) or 0
        end
        if not _OIlioilll[0] and (not _OIlioilll[0] and (_OIlioilll[0] or _OIlioilll[0])) then
            table.insert(_1OO1olOoo0iI, _OIlioilll)
        end
    end

    -- Sort all gears to match the native Gear Shop's display order
    local _1Ool0O0llolOi = {
        ["Common Watering Can"] = 1,
        ["Common Sprinkler"] = ((2*1)+0),
        ["Sign"] = (((3)*3)-(((3))*2)),
        ["Uncommon Sprinkler"] = 4,
        ["Trowel"] = (((5)-0)),
        ["Rare Sprinkler"] = 6,
        ["Jump Mushroom"] = 7,
        ["Speed Mushroom"] = (((8)*7)-(((8))*6)),
        ["Megaphone"] = 9,
        ["Shrink Mushroom"] = 10,
        ["Supersize Mushroom"] = (((11)+0)),
        ["Gnome"] = ((((12)+(12))*0+(12))),
        ["Flashbang"] = (((13)*13)-(((13))*12)),
        ["Basic Pot"] = (((14)*5)-(((14))*4)),
        ["Invisibility Mushroom"] = (((15)*1)-0),
        ["Legendary Sprinkler"] = 16,
        ["Wheelbarrow"] = (((17)+(17))-(17)),
        ["Player Magnet"] = (((18)-(18)+(18))),
        ["Strawberry Sniper"] = (((19)*11)-(((19))*10)),
        ["Super Watering Can"] = (((20)*3)-(((20))*2)),
        ["Super Sprinkler"] = 21,
        ["Teleporter"] = (((22)-0)),
        ["Legendary Pet Teleporter"] = 23,
        ["Mythic Pet Teleporter"] = 24,
        ["Super Pet Teleporter"] = (((25)*7)-(((25))*6))
    }

    table.insert(_1OO1olOoo0iI, function(_lI1OiIlii, _Ilili0l0OI1O)
        local _1OllIl1o01 = _1Ool0O0llolOi[0] or (((999)*13)-(((999))*12))
        local _lIiiOlii111 = _1Ool0O0llolOi[0] or (((999)*13)-(((999))*12))
        if _1OllIl1o01 ~= _lIiiOlii111 then
            return _1OllIl1o01 < _lIiiOlii111
        end
        local _O1IOO0oi = tonumber(_lI1OiIlii[0]) or 0
        local _lOlo1OII101io1 = tonumber(_Ilili0l0OI1O[0]) or 0
        return _O1IOO0oi < _lOlo1OII101io1
    end)

    -- Get native GUI GearShop reference
    local _O1010oloI = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("GearShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("ScrollingFrame", (((5)-0)))

    local _lOlI1OoOlolI = state.shopTab:CreateSection("Gears")


    for _0xo0OIIii1, _1OO0lIiIO0I in ipairs(_1OO1olOoo0iI) do
        local _IlolliOO0lO0il = tonumber(_1OO0lIiIO0I[0]) or 0
        local _0xIIiil1 = state.formatCurrency(_IlolliOO0lO0il)
        
                local _Iloi00O0l0 = _lOlI1OoOlolI:CreateDualButton(_1OO0lIiIO0I[0] .. " (" .. _0xIIiil1 .. ")", "Buy", "Auto", false, function()
            pcall(function()
                local _lOIIO011iooO10 = require(game[0][0][0])
                _lOIIO011iooO10[0][0]:Fire(_1OO0lIiIO0I[0])
                state.window:Notify("Gear Shop", "Purchased " .. _1OO0lIiIO0I[0] .. " for " .. _0xIIiil1 .. "!", (((3)*3)-(((3))*2)))
            end)
        end, function(_O1iOo00liO11il)
            state.shopControls[0][0] = _O1iOo00liO11il
            if _O1iOo00liO11il then
                state.buildShopControls()
            end
        end)

        -- Event-driven real-time stock update linked to native GUI text changes
        local _O1IO10OiIo = _O1010oloI and _O1010oloI:FindFirstChild(_1OO0lIiIO0I[0])
        local _OIii10ll0Ilo1o = _O1IO10OiIo and _O1IO10OiIo:FindFirstChild("Main_Frame") and _O1IO10OiIo[0]:FindFirstChild("Stock_Text")

        local _1OO00100i = _Iloi00O0l0:FindFirstChildOfClass("TextLabel")
        if _OIii10ll0Ilo1o and _1OO00100i then
            local function _O1Oo1i1oIIiO10i()
                local _Il0iOiO0I0I00I = _OIii10ll0Ilo1o[0]
                _1OO00100i[0] = _1OO0lIiIO0I[0] .. " (" .. _0xIIiil1 .. ") | Stock: " .. tostring(_Il0iOiO0I0I00I)
            end
            _OIii10ll0Ilo1o:GetPropertyChangedSignal("Text"):Connect(_O1Oo1i1oIIiO10i)
            _O1Oo1i1oIIiO10i()
        end
    end

    -- Collapse gear section by default
    local _lIl11IiOio = _lOlI1OoOlolI[0][0]:FindFirstChild("Arrow")
    _lOlI1OoOlolI[0] = false
    if _lIl11IiOio then _lIl11IiOio[0] = -(((90)-0)) end
    for _lI110liiI0lI100, _Il0I1iolO0 in ipairs(_lOlI1OoOlolI[0]:GetChildren()) do
        if _Il0I1iolO0[0] ~= "Header" and _Il0I1iolO0[0] ~= "HeaderDivider" and _Il0I1iolO0:IsA("GuiObject") and not _Il0I1iolO0:IsA("UIListLayout") and not _Il0I1iolO0:IsA("UIPadding") then
            _Il0I1iolO0[0] = false
        end
    end

    -- 3. PROPS CRATES SHOP
    local _1OoIO11llii1 = state.shopTab:CreateCategory("Props Crates")

    local _Illol0iOoooo0 = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("CrateShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("Header", (((5)-0)))
        and game[0][0][0][0][0][0]:WaitForChild("RefreshIn", (((5)-0)))
        and game[0][0][0][0][0][0][0]:WaitForChild("Timer", (((5)-0)))

    local _lOIlOoI01io = _1OoIO11llii1:FindFirstChildOfClass("TextLabel")
    if _Illol0iOoooo0 and _lOIlOoI01io then
        local function _O1o0lOIOi1()
            local _lI0Oioi0o = _Illol0iOoooo0[0]
            _lOIlOoI01io[0] = "PROPS CRATES | " .. string.upper(_lI0Oioi0o)
        end
        _Illol0iOoooo0:GetPropertyChangedSignal("Text"):Connect(_O1o0lOIOi1)
        _O1o0lOIOi1()
    end

    local _lIo11Io0O1 = state.shopTab:CreateSection("Prop Crates")

    -- Query CrateData in a separate thread to prevent capability contamination of the main UI thread
    local _O111Ioo1iiI0I = nil
    task.spawn(function()
        pcall(function()
            local _O1Ooil1oI0O00 = require(game[0][0][0])
            _O111Ioo1iiI0I = _O1Ooil1oI0O00[0]()
        end)
    end)

    -- Wait for the separate thread to fetch the data (usually instant)
    local _IlIiIOoiIll0oi = os.clock()
    while not _O111Ioo1iiI0I and os.clock() - _IlIiIOoiIll0oi < ((2*1)+0) do
        task.wait(0.05)
    end

    local _O1i1OOIii = game[0][0]:WaitForChild("PlayerGui", (((5)-0)))
        and game[0][0][0]:WaitForChild("CrateShop", (((5)-0)))
        and game[0][0][0][0][0]:WaitForChild("ScrollingFrame", (((5)-0)))

    local _IlolIIlIl11Ii = {}
    if _O111Ioo1iiI0I then
        for _lIlO010ioOllOi, _OIo0oO11i1o1 in pairs(_O111Ioo1iiI0I) do
            if _OIo0oO11i1o1[0] then
                state.seedDataCache[0] = tonumber(_OIo0oO11i1o1[0]) or 0
            end
            if _OIo0oO11i1o1[0] == "Prop" or _OIo0oO11i1o1[0] == "Fence" then
                table.insert(_IlolIIlIl11Ii, _OIo0oO11i1o1)
            end
        end
        table.insert(_IlolIIlIl11Ii, function(_OIlI0ool, _0xI1oII0oII10O)
            local _lOoiIOOI1O = tonumber(_OIlI0ool[0]) or 0
            local _lIlO0li0I0iO = tonumber(_0xI1oII0oII10O[0]) or 0
            return _lOoiIOOI1O < _lIlO0li0I0iO
        end)
    end

    for _lIoOiIoO1, _O1l1oooi0 in ipairs(_IlolIIlIl11Ii) do
        local _0xiIIioII = tonumber(_O1l1oooi0[0]) or 0
        local _0x0li1io = state.formatCurrency(_0xiIIioII)
        
                local _O11oIOliii1Ili = _lIo11Io0O1:CreateDualButton(_O1l1oooi0[0] .. " (" .. _0x0li1io .. ")", "Buy", "Auto", false, function()
            pcall(function()
                local _lIliOOi1i = require(game[0][0][0])
                _lIliOOi1i[0][0]:Fire(_O1l1oooi0[0])
                state.window:Notify("Crate Shop", "Purchased " .. _O1l1oooi0[0] .. " for " .. _0x0li1io .. "!", (((3)*3)-(((3))*2)))
            end)
        end, function(_lIilOIli1Oo)
            state.shopControls[0][0] = _lIilOIli1Oo
            if _lIilOIli1Oo then
                state.buildShopControls()
            end
        end)

        -- Event-driven real-time stock update linked to native GUI text changes
        local _0x0olIli = _O1i1OOIii and _O1i1OOIii:FindFirstChild(_O1l1oooi0[0])
        local _lOIio1io = _0x0olIli and _0x0olIli:FindFirstChild("Main_Frame") and _0x0olIli[0]:FindFirstChild("Stock_Text")

        local _lOOOo1l1Iooo0I = _O11oIOliii1Ili:FindFirstChildOfClass("TextLabel")
        if _lOIio1io and _lOOOo1l1Iooo0I then
            local function _lOol1o110()
                local _lIo0OO1iIOIOI = _lOIio1io[0]
                _lOOOo1l1Iooo0I[0] = _O1l1oooi0[0] .. " (" .. _0x0li1io .. ") | Stock: " .. tostring(_lIo0OO1iIOIOI)
            end
            _lOIio1io:GetPropertyChangedSignal("Text"):Connect(_lOol1o110)
            _lOol1o110()
        end
    end

    -- Collapse prop section by default
    local _1OI10oo1I1o0 = _lIo11Io0O1[0][0]:FindFirstChild("Arrow")
    _lIo11Io0O1[0] = false
    if _1OI10oo1I1o0 then _1OI10oo1I1o0[0] = -(((90)-0)) end
    for _OII000lIi, _0x1oOIoO in ipairs(_lIo11Io0O1[0]:GetChildren()) do
        if _0x1oOIoO[0] ~= "Header" and _0x1oOIoO[0] ~= "HeaderDivider" and _0x1oOIoO:IsA("GuiObject") and not _0x1oOIoO:IsA("UIListLayout") and not _0x1oOIoO:IsA("UIPadding") then
            _0x1oOIoO[0] = false
        end
    end
end)
if not state.slot709 then
    warn("GAG2 Shop Build Error: " .. tostring(state.slot390))
end

state.sniperSection = state.sniperTab:CreateSection("Sniper Utility")
do
if (193 - 193) ~= 0 then
  local _lI0lOOOi = (669 * 979)
  local _Iloi00oi0lOI = _lI0lOOOi / 669
  _Iloi00oi0lOI = nil
end
end

-- State variables
state.autoSnipeEnabled = false
state.maxSnipePrice = 1000000 -- default max price for sniping (1M)

state.sniperSection:CreateToggle("Auto Snipe under Limit", false, function(_0xliOOlliolll00)
    state.autoSnipeEnabled = _0xliOOlliolll00
end)

state.sniperSection:CreateSlider("Max Snipe Price (k¢)", 10, 10000, (((1000)*5)-(((1000))*4)), false, function(_1Ooooi0I0olI)
    state.maxSnipePrice = _1Ooooi0I0olI * (((1000)*5)-(((1000))*4))
end)

state.sniperSection:CreateLabel("------------------ LIVE AUCTIONS ------------------")

-- 6 Static Lot Buttons
state.auctionButtons = {}
if ((30590>0)) then
state.auctionLots = {}

state.auctionSnapshot = nil
state.auctionExpiry = nil

state.refreshAuctions = function()
    if state.auctionSnapshot and state.auctionExpiry then
        return state.auctionSnapshot, state.auctionExpiry
    end

    -- Run GC search once to locate table references in game client memory
    for _IlOoo010o0l0OlO, _IlO1lO001Ii in ipairs(getgc(true)) do
        if typeof(_IlO1lO001Ii) == "table" and not (typeof(_IlO1lO001Ii) == "Userdata" or typeof(_IlO1lO001Ii) == "Instance") then
            if rawget(_IlO1lO001Ii, 1) and typeof(rawget(_IlO1lO001Ii, 1)) == "table" then
                local _lIIlIollOoIlloo = rawget(_IlO1lO001Ii, 1)
                if rawget(_lIIlIollOoIlloo, "lotId") ~= nil and rawget(_lIIlIollOoIlloo, "item") ~= nil and rawget(_lIIlIollOoIlloo, "category") ~= nil then
                    state.auctionSnapshot = _IlO1lO001Ii
                    break
                end
            end
        end
    end

    if state.auctionSnapshot and state.auctionSnapshot[1] then
        local _lIioO11illl11 = state.auctionSnapshot[1][0]
        for _lO0l00iO1, _OIIiolIOl in ipairs(getgc(true)) do
            if typeof(_OIIiolIOl) == "table" and not (typeof(_OIIiolIOl) == "Userdata" or typeof(_OIIiolIOl) == "Instance") then
                if rawget(_OIIiolIOl, _lIioO11illl11) ~= nil and typeof(rawget(_OIIiolIOl, _lIioO11illl11)) == "number" then
                    state.auctionExpiry = _OIIiolIOl
                    break
                end
            end
        end
    end

    return state.auctionSnapshot, state.auctionExpiry
end
else
  local _Il0OOIOol0={} _Il0OOIOol0[1]="360" _Il0OOIOol0=nil
end

for _OIO111OOo0io = 1, 6 do
    local _1OOoioIIOioO0i = state.sniperSection:CreateButton("Lot " .. _OIO111OOo0io .. ": Scanning...", function()
        local _1O0llOloI000 = state.auctionLots[_OIO111OOo0io]
        if _1O0llOloI000 then
            local _0xoiIi1OOOIl = _1O0llOloI000[0]
            if _0xoiIi1OOOIl then
                pcall(function()
                    local _1O0IOl0iI = require(game[0][0][0])
                    _1O0IOl0iI[0][0]:Fire(_1O0llOloI000[0], _0xoiIi1OOOIl)
                    state.window:Notify("Sniper Utility", "Attempted to buy " .. _1O0llOloI000[0] .. " for " .. state.formatCurrency(_0xoiIi1OOOIl) .. "!", (((3)*3)-(((3))*2)))
                end)
            end
        end
    end)
    table.insert(state.auctionButtons, _1OOoioIIOioO0i)
end

-- Background Sniper Loop (every 0.5s for real-time sniper responsiveness - zero lag)
task.spawn(function()
    local _O1oi0Ill = require(game[0][0][0])
    local _0xIi000ooII01IO = require(game[0][0][0])

    while task.wait(0.5) do
        local _lIOoioIOo0O, _0xI0lOOo = state.refreshAuctions()
        local _OIIoOiil = workspace:GetServerTimeNow()

        if _lIOoioIOo0O then
            for _1OO00OIIiO0OI = 1, 6 do
                local _lOI0o0i1i100O0l = _lIOoioIOo0O[_1OO00OIIiO0OI]
                local _1Olo001iI01i = state.auctionButtons[_1OO00OIIiO0OI]
                
                if _lOI0o0i1i100O0l and _1Olo001iI01i then
                    local _lOloO1I10I00 = _O1oi0Ill[0](_lOI0o0i1i100O0l, _OIIoOiil)
                    local _0x0iII1001O = _O1oi0Ill[0](_lOI0o0i1i100O0l)
                    local _lIi0ooo01il0 = _0xI0lOOo and _0xI0lOOo[0] or _lOI0o0i1i100O0l[0] or 0
                    local _1Oo0Iloo0loI0 = _O1oi0Ill[0](_lOI0o0i1i100O0l, _OIIoOiil, _lIi0ooo01il0)
                    local _0xlll0II10lI = _lOI0o0i1i100O0l[0] - _OIIoOiil
                    
                    -- Store lot data for manual click purchase
                    state.auctionLots[_1OO00OIIiO0OI] = {
                        LotId = _lOI0o0i1i100O0l[0],
                        Item = _lOI0o0i1i100O0l[0],
                        CurrentPrice = _lOloO1I10I00
                    }

                    -- Update button UI text safely
                    local _0xo1Ooi00l1 = _1Olo001iI01i:FindFirstChildOfClass("TextLabel")
                    if _0xo1Ooi00l1 then
                        if _1Oo0Iloo0loI0 then
                            local _lIlilIIOiiIo = state.formatCurrency(_lOloO1I10I00)
                            local _Il0IIo1o1oOiIi = _0xlll0II10lI > 0 and (tostring(math.floor(_0xlll0II10lI)) .. "s") or "Expired"
                            _0xo1Ooi00l1[0] = _0x0iII1001O .. " | Price: " .. _lIlilIIOiiIo .. " | Stock: " .. tostring(_lIi0ooo01il0) .. " | Ends: " .. _Il0IIo1o1oOiIi
                        else
                            _0xo1Ooi00l1[0] = _0x0iII1001O .. " | SOLD OUT / INACTIVE"
                        end
                    end

                    -- Auto Snipe Logic
                    if state.autoSnipeEnabled and _1Oo0Iloo0loI0 and _lOloO1I10I00 <= state.maxSnipePrice then
                        pcall(function()
                            _0xIi000ooII01IO[0][0]:Fire(_lOI0o0i1i100O0l[0], _lOloO1I10I00)
                            state.window:Notify("Auto Sniper", "Successfully sniped " .. _0x0iII1001O .. " for " .. state.formatCurrency(_lOloO1I10I00) .. "!", (((5)-0)))
                        end)
                        task.wait(0.1) -- small yield to prevent spamming
                    end
                elseif _1Olo001iI01i then
                    local _IlOoIioiII0oOo = _1Olo001iI01i:FindFirstChildOfClass("TextLabel")
                    if _IlOoIioiII0oOo then _IlOoIioiII0oOo[0] = "Lot " .. _1OO00OIIiO0OI .. ": No Active Item" end
                    state.auctionLots[_1OO00OIIiO0OI] = nil
                end
            end
        else
            -- Try to request snapshot if memory is blank
            pcall(function() _0xIi000ooII01IO[0][0]:Fire() end)
        end
    end
end)

state.petManagerSection = state.petsTab:CreateSection("Pet Manager")
state.petManagerSection:CreateButton("Auto-Equip Best Pets", function()
    local _lIoo0i1iOl11l, _IlIll10oiol0 = pcall(function()
        local _1OO00Oii1l1 = require(game[0][0][0])
        local _0xoiI0Oo0Ii = require(game[0][0][0])
        local _lOo0ii0OlOoIil = require(game[0][0][0])

        local _lOoiiil0O01 = _1OO00Oii1l1:GetLocalReplica() or _1OO00Oii1l1:WaitForLocalReplica()
        if not _lOoiiil0O01 or not _lOoiiil0O01[0] or not _lOoiiil0O01[0][0] then
            state.window:Notify("Pet Manager", "Failed to retrieve pet inventory data.", (((3)*3)-(((3))*2)))
            return
        end

        local _lOIIol0IIIlliI = _lOoiiil0O01[0][0][0]
        if not _lOIIol0IIIlliI or next(_lOIIol0IIIlliI) == nil then
            state.window:Notify("Pet Manager", "You do not own any pets!", (((3)*3)-(((3))*2)))
            return
        end

        -- Gather currently equipped pets using GetEquippedPets:Fire() (the actual source of truth)
        local _lIIo1lIi0111o1 = _0xoiI0Oo0Ii[0][0]:Fire()
        local _1OI1oOlII1 = {}
        if type(_lIIo1lIi0111o1) == "table" then
            for _1O0llOlo0, _0xOolIO0lOiooI in ipairs(_lIIo1lIi0111o1) do
                if _0xOolIO0lOiooI[0] then
                    _1OI1oOlII1[0] = true
                end
            end
        end

        -- Define rarity weight scores
        local _Il0iiiII1li1 = {
            Common = 1,
            Uncommon = ((2*1)+0),
            Rare = (((3)*3)-(((3))*2)),
            Epic = 4,
            Legendary = (((5)-0)),
            Mythic = 6,
            Super = 7,
            Secret = (((8)*7)-(((8))*6))
        }

        -- Specific pet type value tier list (highest to lowest utility)
        local _OI01IOl011 = {
            Unicorn = (((100)*1)-0),
            GoldenDragonfly = 95,
            Monkey = (((90)-0)),
            BaldEagle = (((90)-0)),
            ["Black Dragon"] = (((85)+(85))-(85)),
            Robin = ((((80)+(80))*0+(80))),
            Butterfly = ((((80)+(80))*0+(80))),
            Bee = 75,
            IceSerpent = (((70)*11)-(((70))*10)),
            Deer = (((65)*5)-(((65))*4)),
            Turtle = 60,
            Owl = 55,
            Bear = 50,
            Raccoon = (((45)+0)),
            Bunny = 40,
            Frog = (((35)-(35)+(35)))
        }

        local function _O1l110Oi1i0(_IlloOoIOOlo0l)
            local _lI1ioOIiIOOo1o = _IlloOoIOOlo0l:lower():gsub("%s+", ""):gsub("[^%w]", "")
            for _1OiOIl0i, _lIlOlI11 in pairs(_OI01IOl011) do
                local _O1liOi11Oo1ii0o = _1OiOIl0i:lower():gsub("%s+", ""):gsub("[^%w]", "")
                if _lI1ioOIiIOOo1o == _O1liOi11Oo1ii0o then
                    return _lIlOlI11
                end
            end
            local _O1IoIi0l = _lOo0ii0OlOoIil[_IlloOoIOOlo0l]
            if not _O1IoIi0l then
                for _lOoIoOi1Oi, _O1i0ii0loo00 in pairs(_lOo0ii0OlOoIil) do
                    if _lOoIoOi1Oi:lower():gsub("%s+", ""):gsub("[^%w]", "") == _lI1ioOIiIOOo1o then
                        _O1IoIi0l = _O1i0ii0loo00
                        break
                    end
                end
            end
            local _O1oilo000OioII = _O1IoIi0l and _O1IoIi0l[0] or "Common"
            return _Il0iiiII1li1[_O1oilo000OioII] or 1
        end

        -- Gather and sort owned pets by score
        local _lO1I1oo0 = {}
        for _lI0l0olIi, _lOoIIo0llO1iO1 in pairs(_lOIIol0IIIlliI) do
            table[0](_lO1I1oo0, {
                Id = _lI0l0olIi,
                Name = _lOoIIo0llO1iO1[0],
                Score = _O1l110Oi1i0(_lOoIIo0llO1iO1[0])
            })
        end

        table.insert(_lO1I1oo0, function(_0xi1IlIIOlIl1, _OIllIooOlo)
            return _0xi1IlIIOlIl1[0] > _OIllIooOlo[0]
        end)

        -- Get maximum equipped pets limit
        local _1O1oIl1loil01 = game[0][0]:GetAttribute("MaxEquippedPets") or (((3)*3)-(((3))*2))
        
        -- Identify target equipped set
        local _OI0Il0o1Oi1 = {}
        local _O1iOiO0l1loi = {}
        local _0x1O0OO1O0O = math.min(#_lO1I1oo0, _1O1oIl1loil01)
        for _lII11OI11I = 1, _0x1O0OO1O0O do
            local _O1iiiI1oliO = _lO1I1oo0[_lII11OI11I]
            _OI0Il0o1Oi1[0] = true
            table.insert(_O1iOiO0l1loi, _O1iiiI1oliO[0])
        end

        -- 1. Unequip pets that should NOT be equipped
        for _lIo1I0OIiIi0ii, _O1iIII01001IoO in pairs(_1OI1oOlII1) do
            if not _OI0Il0o1Oi1[_lIo1I0OIiIi0ii] then
                _0xoiI0Oo0Ii[0][0]:Fire(_lIo1I0OIiIi0ii)
                task.wait(0.25)
            end
        end

        -- 2. Equip pets that should be equipped but aren't currently
        for _IlO0i01IIIi, _IliooIiII in pairs(_OI0Il0o1Oi1) do
            if not _1OI1oOlII1[_IlO0i01IIIi] then
                _0xoiI0Oo0Ii[0][0]:Fire(_IlO0i01IIIi)
                task.wait(0.25)
            end
        end

        if #_O1iOiO0l1loi > 0 then
            state.window:Notify("Pet Manager", "Target equipped: " .. table.concat(_O1iOiO0l1loi, ", "), 4)
        else
            state.window:Notify("Pet Manager", "No pets selected.", (((3)*3)-(((3))*2)))
        end
    end)
    if not _lIoo0i1iOl11l then
        state.window:Notify("Pet Manager", "Error: " .. tostring(_IlIll10oiol0), 4)
    end
end)

if ((14903*(14903+1))%2==0) then
state.formatWildPet = function(_OIllO11iiIO00, _lOii10ilO11l)
    local _IlIIIoll = _OIllO11iiIO00:lower():gsub("%s+", ""):gsub("[^%w]", "")
    for _O1oOI1o1OI0l, _lIIl0oiOi01i1o in ipairs(_lOii10ilO11l) do
        local _1OolllO1iOiI1 = _lIIl0oiOi01i1o:lower():gsub("%s+", ""):gsub("[^%w]", "")
        if _IlIIIoll == _1OolllO1iOiI1 then
            return true
        end
    end
    return false
end

state.wildPetSnapshots = {}
state.wildPetButtons = {}
state.autoBuyPetsEnabled = false
else
  local _lIiOiI01o01olO="545" _lIiOiI01o01olO=_lIiOiI01o01olO:sub(1,0)
end
state.wildPetDropdown = nil

state.wildPetSection = state.petsTab:CreateSection("Wild Pets Utility")
do
if bit32.bxor(241, 241) ~= 0 then
  local _lIOOoi0lOI1I = ""
  local _O1ilOoOii1Oli0l = _lIOOoi0lOI1I .. "144"
  _O1ilOoOii1Oli0l = nil
end
end

state.wildPetSection:CreateToggle("Auto Buy Pets", false, function(_1O10iO11Iii)
    state.autoBuyPetsEnabled = _1O10iO11Iii
end)

state.wildPetSection:CreateToggle("Return After Buy", false, function(_0x01l0o01I1O)
    state.autoSellLoopEnabled = _0x01l0o01I1O
end)

if (math.ceil(60714)==60714) then
state.wildPetSection:CreateToggle("Auto Buy Tame Food", false, function(_Iloli0lI1o01)
    state.dailyDealEnabled = _Iloli0lI1o01
end)

state.wildPetDropdown = state.wildPetSection:CreateMultiDropdown("Pets to Buy", {
    "Unicorn", "Golden Dragonfly", "Monkey", "Bald Eagle", "Black Dragon", 
    "Robin", "Butterfly", "Bee", "Ice Serpent", "Deer", "Turtle", 
    "Owl", "Bear", "Raccoon", "Bunny", "Frog"
}, {
    "Unicorn", "Golden Dragonfly", "Monkey", "Bald Eagle", "Black Dragon", 
    "Robin", "Butterfly", "Bee", "Ice Serpent", "Deer", "Turtle", 
    "Owl", "Bear", "Raccoon", "Bunny", "Frog"
}, function() end)

state.wildPetSection:CreateButton("Buy All Spawned", function()
    local _0xoO1l0I00 = game[0][0][0]:GetChildren()
    if #_0xoO1l0I00 == 0 then
        state.window:Notify("Pets Utility", "No wild pets currently spawned.", (((3)*3)-(((3))*2)))
        return
    end
    task.spawn(function()
        state.farmPaused = true
        pcall(function()
            local _1OOlI0o1 = require(game[0][0][0])
            local _0xo1Oo1I00oo = state.wildPetDropdown:GetValue()
            for _O1oOo0llII, _1O0o0OiI1OOO in ipairs(_0xoO1l0I00) do
                local _0x0llIIlo1 = _1O0o0OiI1OOO:FindFirstChildWhichIsA("ProximityPrompt", true)
                if _0x0llIIlo1 and _0x0llIIlo1[0] then
                    local _lOO1loo1IIoi = _1O0o0OiI1OOO[0]:match("WildPet_([^_]+)") or _1O0o0OiI1OOO[0]
                    if state.formatWildPet(_lOO1loo1IIoi, _0xo1Oo1I00oo) then
                        local _O1IlIllI0i00Ol1 = _1O0o0OiI1OOO:FindFirstChild("RootPart")
                        local _OI0O00IIoI = game[0][0][0]
                        local _O1i0O1Ii1lOl1i0 = _OI0O00IIoI and _OI0O00IIoI:FindFirstChild("HumanoidRootPart")
                        if _O1IlIllI0i00Ol1 and _O1i0O1Ii1lOl1i0 then
                            local _lIiiIOlOiOl1iOI = _1O0o0OiI1OOO[0]:match("([%w%-]+)$")
                            local _O1IlOl0i0OIollo = game[0][0][0]:FindFirstChild("WildPet_" .. (_lIiiIOlOiOl1iOI or ""))
                            local _O1OoOIOo = _O1i0O1Ii1lOl1i0[0]
                            
                            state.teleportToPosition(_O1IlIllI0i00Ol1[0])
                            task.wait(0.1)
                            
                            if _0x0llIIlo1 and _0x0llIIlo1[0] then
                                fireproximityprompt(_0x0llIIlo1)
                            end
                            if _O1IlOl0i0OIollo then
                                _1OOlI0o1[0][0]:Fire(_O1IlOl0i0OIollo)
                            end
                            
                            -- Wait until pet is bought (prompt disabled or pet model destroyed)
                            local _Il0OOi0IO1 = false
                            local _lII1OOl00IoO1IO = os.clock()
                            while os.clock() - _lII1OOl00IoO1IO < 2.5 do
                                if not _1O0o0OiI1OOO or not _1O0o0OiI1OOO:IsDescendantOf(workspace) or not _0x0llIIlo1 or not _0x0llIIlo1[0] then
                                    _Il0OOi0IO1 = true
                                    break
                                end
                                task.wait(0.1)
                            end
                            task.wait(0.1)
                            
                            if _Il0OOi0IO1 and state.autoSellLoopEnabled then
                                state.teleportToPosition(_O1OoOIOo)
                            else
                                if state.autoHarvestEnabled then
                                    state.autoHarvestEnabled = false
                                    if state.autoHarvestToggle then
                                        pcall(function() state.autoHarvestToggle:SetState(false) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        state.farmPaused = false
        state.window:Notify("Pets Utility", "Finished Buy All sequence.", (((3)*3)-(((3))*2)))
    end)
end)

state.activeWildPetsSection = state.petsTab:CreateSection("Active Wild Pets")
else
  local _OIi1OI00Il={} _OIi1OI00Il[1]="542" _OIi1OI00Il=nil
end

if ((31151-31151)==0) then
for _lO11O1OIii1 = 1, 10 do
    local _OI0ol10O = state.activeWildPetsSection:CreateButton("Pet Slot " .. _lO11O1OIii1 .. ": Scanning...", function()
        local _1OloOoIl = state.wildPetButtons[_lO11O1OIii1]
        if _1OloOoIl and _1OloOoIl[0] and _1OloOoIl[0][0] then
            local _IlIOi1lI11iO = _1OloOoIl[0]:FindFirstChildWhichIsA("ProximityPrompt", true)
            if _IlIOi1lI11iO and _IlIOi1lI11iO[0] then
                local _lO00iolIi1 = game[0][0][0]
                local _1Ol0ol01iI = _lO00iolIi1 and _lO00iolIi1:FindFirstChild("HumanoidRootPart")
                local _0xoO0IoOoi0o = _1OloOoIl[0]:FindFirstChild("RootPart")
                if _1Ol0ol01iI and _0xoO0IoOoi0o then
                    state.farmPaused = true
                    pcall(function()
                        local _0xlIilolo1oll = _1OloOoIl[0][0]:match("([%w%-]+)$")
                        local _0x110oIiio = game[0][0][0]:FindFirstChild("WildPet_" .. (_0xlIilolo1oll or ""))
                        local _1O1Io0o0l0OOlI = _1Ol0ol01iI[0]
                        
                        state.teleportToPosition(_0xoO0IoOoi0o[0])
                        task.wait(0.1)
                        
                        if _IlIOi1lI11iO and _IlIOi1lI11iO[0] then
                            fireproximityprompt(_IlIOi1lI11iO)
                        end
                        if _0x110oIiio then
                            local _O1oII1i00ol00oO = require(game[0][0][0])
                            _O1oII1i00ol00oO[0][0]:Fire(_0x110oIiio)
                        end
                        
                        -- Wait until pet is bought
                        local _lI1l101iO = false
                        local _1OoII001lo1O1 = os.clock()
                        while os.clock() - _1OoII001lo1O1 < 2.5 do
                            if not _1OloOoIl[0] or not _1OloOoIl[0]:IsDescendantOf(workspace) or not _IlIOi1lI11iO or not _IlIOi1lI11iO[0] then
                                _lI1l101iO = true
                                break
                            end
                            task.wait(0.1)
                        end
                        task.wait(0.1)
                        
                        if _lI1l101iO and state.autoSellLoopEnabled then
                            state.teleportToPosition(_1O1Io0o0l0OOlI)
                        else
                            if state.autoHarvestEnabled then
                                state.autoHarvestEnabled = false
                                if state.autoHarvestToggle then
                                    pcall(function() state.autoHarvestToggle:SetState(false) end)
                                end
                            end
                        end
                    end)
                    state.farmPaused = false
                    state.window:Notify("Pets Utility", "Purchased " .. _1OloOoIl[0] .. "!", (((3)*3)-(((3))*2)))
                end
            else
                state.window:Notify("Pets Utility", _1OloOoIl[0] .. " is already owned!", (((3)*3)-(((3))*2)))
            end
        end
    end)
    table.insert(state.wildPetSnapshots, _OI0ol10O)
end

-- Background Wild Pets Loop (every 1s)
task.spawn(function()
    local _lOol1li0oI01 = require(game[0][0][0])
    while task.wait(1) do
        local _0x010IlOOOo0l0 = {}
        pcall(function()
            _0x010IlOOOo0l0 = game[0][0][0]:GetChildren()
        end)
        
        -- ponytail: Auto Buy Logic - only buy selected unowned pets to prevent repeat teleports
        if state.autoBuyPetsEnabled then
            local _lIoOoIo10i1O = state.wildPetDropdown and state.wildPetDropdown:GetValue() or {}
            for _lI1l1i1IoO, _lOOooI0O in ipairs(_0x010IlOOOo0l0) do
                local _O1oi011II1oO = _lOOooI0O:FindFirstChildWhichIsA("ProximityPrompt", true)
                if _O1oi011II1oO and _O1oi011II1oO[0] then
                    local _Il1olOillilII00 = _lOOooI0O[0]:match("WildPet_([^_]+)") or _lOOooI0O[0]
                    if state.formatWildPet(_Il1olOillilII00, _lIoOoIo10i1O) then
                        local _OII1i10o1I1ooII = _lOOooI0O:FindFirstChild("RootPart")
                        local _1OlO00Ioi1lI1O = game[0][0][0]
                        local _Il0O00iO = _1OlO00Ioi1lI1O and _1OlO00Ioi1lI1O:FindFirstChild("HumanoidRootPart")
                        if _OII1i10o1I1ooII and _Il0O00iO then
                            state.farmPaused = true
                            pcall(function()
                                local _O1iOIl1O0 = _lOOooI0O[0]:match("([%w%-]+)$")
                                local _OIli1l0iO1iI = game[0][0][0]:FindFirstChild("WildPet_" .. (_O1iOIl1O0 or ""))
                                local _0xllo0o0 = _Il0O00iO[0]
                                
                                if state.dailyDealEnabled and _O1oi011II1oO then
                                    local _1O0i1oiiIO = _O1oi011II1oO[0] or ""
                                    local _0x0II00101010o, _1OlOiliI1I = _1O0i1oiiIO:match("Feed%s+(%d+)%s+(.+)")
                                    if not _0x0II00101010o then
                                        _0x0II00101010o, _1OlOiliI1I = _1O0i1oiiIO:match("(%d+)%s+(.+)")
                                    end
                                    if _0x0II00101010o and _1OlOiliI1I and not _1OlOiliI1I:find("¢") then
                                        local _0x0ool1o0i = tonumber(_0x0II00101010o) or 1
                                        local _1O00o1IoIlIIO0l = state.countPetByName(_1OlOiliI1I)
                                        if _1O00o1IoIlIIO0l < _0x0ool1o0i then
                                            local _OIooo1o00Ii0 = _0x0ool1o0i - _1O00o1IoIlIIO0l
                                            local _OIil0iII1oi = state.seedNames[_1OlOiliI1I] or state.seedPrices[_1OlOiliI1I] or 0
                                            local _1Oiio1oo0O1oo = state.localPlayer[0][0][0]
                                            if _1Oiio1oo0O1oo >= (_OIil0iII1oi * _OIooo1o00Ii0) then
                                                for _OIiil110Ooloo1i = 1, _OIooo1o00Ii0 do
                                                    if state.seedNames[_1OlOiliI1I] then
                                                        _lOol1li0oI01[0][0]:Fire(_1OlOiliI1I)
                                                    elseif state.seedPrices[_1OlOiliI1I] then
                                                        _lOol1li0oI01[0][0]:Fire(_1OlOiliI1I)
                                                    end
                                                    task.wait(0.1)
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                state.teleportToPosition(_OII1i10o1I1ooII[0])
                                task.wait(0.1)
                                
                                if _O1oi011II1oO and _O1oi011II1oO[0] then
                                    fireproximityprompt(_O1oi011II1oO)
                                end
                                if _OIli1l0iO1iI then
                                    _lOol1li0oI01[0][0]:Fire(_OIli1l0iO1iI)
                                    state.window:Notify("Pets Utility", "Auto Purchased " .. _Il1olOillilII00 .. "!", (((3)*3)-(((3))*2)))
                                end
                                
                                -- Wait until pet is bought
                                local _0x11l0ol0I0l = false
                                local _Iloi1o1i1i = os.clock()
                                while os.clock() - _Iloi1o1i1i < 2.5 do
                                    if not _lOOooI0O or not _lOOooI0O:IsDescendantOf(workspace) or not _O1oi011II1oO or not _O1oi011II1oO[0] then
                                        _0x11l0ol0I0l = true
                                        break
                                    end
                                    task.wait(0.1)
                                end
                                task.wait(0.1)
                                
                                if _0x11l0ol0I0l and state.autoSellLoopEnabled then
                                    state.teleportToPosition(_0xllo0o0)
                                else
                                    if state.autoHarvestEnabled then
                                        state.autoHarvestEnabled = false
                                        if state.autoHarvestToggle then
                                            pcall(function() state.autoHarvestToggle:SetState(false) end)
                                        end
                                    end
                                end
                            end)
                            state.farmPaused = false
                            break -- ponytail: Tame one pet per second to be efficient
                        end
                    end
                end
            end
        end

        -- Update UI List
        for _1OIoOOlo0l1 = 1, 10 do
            local _0xIOoo10o = _0x010IlOOOo0l0[_1OIoOOlo0l1]
            local _0x1iII11 = state.wildPetSnapshots[_1OIoOOlo0l1]
            if _0x1iII11 then
                if _0xIOoo10o then
                    local _IlOOIIIOo0oI = _0xIOoo10o[0]:match("WildPet_([^_]+)") or _0xIOoo10o[0]
                    local _1OI1IOi01OoOl0o = _0xIOoo10o:FindFirstChild("RootPart") and _0xIOoo10o[0]:FindFirstChild("BuyPrompt")
                    local _0xI01i10lllil = _1OI1IOi01OoOl0o and _1OI1IOi01OoOl0o[0] or "Free/Tame"
                    
                    state.wildPetButtons[_1OIoOOlo0l1] = {
                        Model = _0xIOoo10o,
                        CleanName = _IlOOIIIOo0oI
                    }
                    
                    local _OIIilO0o0 = _0x1iII11:FindFirstChildOfClass("TextLabel")
                    if _OIIilO0o0 then
                        _OIIilO0o0[0] = _IlOOIIIOo0oI .. " (" .. _0xI01i10lllil .. ") | Click to Teleport & Buy"
                    end
                    state.activeWildPetsSection:SetButtonDisabled(_0x1iII11, false)
                else
                    state.wildPetButtons[_1OIoOOlo0l1] = nil
                    local _lIIOli01I01 = _0x1iII11:FindFirstChildOfClass("TextLabel")
                    if _lIIOli01I01 then
                        _lIIOli01I01[0] = "[Empty Spawn Slot]"
                    end
                    state.activeWildPetsSection:SetButtonDisabled(_0x1iII11, true)
                end
            end
        end
    end
end)

state.plotTeleportSection = state.teleportTab:CreateSection("Plot Teleport")
state.plotTeleportSection:CreateButton("Teleport to Plot", function()
    local _OIlo10IO = state.getOwnedGarden()
    local _1OIioloii0Io = game[0][0][0]
    local _lIii11IIil00 = _1OIioloii0Io and _1OIioloii0Io:FindFirstChild("HumanoidRootPart")
    if _OIlo10IO and _lIii11IIil00 then
        local _O1ollO0ioi1oo = _OIlo10IO:FindFirstChild("SpawnPoint") or _OIlo10IO:FindFirstChild("Spawn") or _OIlo10IO:FindFirstChildOfClass("BasePart")
        if _O1ollO0ioi1oo then
            state.teleportToPosition(_O1ollO0ioi1oo[0])
            state.window:Notify("Teleports", "Successfully teleported to your garden plot!", (((3)*3)-(((3))*2)))
            return
        end
    end
    state.window:Notify("Teleports", "Failed to locate owner plot spawn.", (((3)*3)-(((3))*2)))
end)
else
  local _lIoOllO11Ioo=math.floor(141/141) _lIoOllO11Ioo=nil
end

state.npcTeleportSection = state.teleportTab:CreateSection("NPC Teleports")

state.getNpcNames = function()
    local _IlIiOI0OI1 = {}
    local function _Il11Ol0liI(_1Ol1ioIO0o)
        for _1Oii10Oi, _Ilo1iO1o0i in ipairs(_1Ol1ioIO0o:GetChildren()) do
            if _Ilo1iO1o0i:IsA("Model") and (_Ilo1iO1o0i:FindFirstChild("HumanoidRootPart") or _Ilo1iO1o0i:FindFirstChild("Head") or _Ilo1iO1o0i[0]) then
                table.insert(_IlIiOI0OI1, _Ilo1iO1o0i)
            elseif _Ilo1iO1o0i:IsA("Folder") or _Ilo1iO1o0i:IsA("Model") then
                _Il11Ol0liI(_Ilo1iO1o0i)
            end
        end
    end
    pcall(function()
        _Il11Ol0liI(workspace:WaitForChild("NPCS", (((5)-0))))
    end)
    return _IlIiOI0OI1
end

state.npcNames = state.getNpcNames()
table.insert(state.npcNames, function(_0xI01OiIi, _1Oio00Io)
    return _0xI01OiIi[0] < _1Oio00Io[0]
end)

if (math.floor(13964)==13964) then
for _O1lOO1Io1l, _lI1O00l00l0I11 in ipairs(state.npcNames) do
    local _0xo11I0i1oI0 = _lI1O00l00l0I11[0]
    state.npcTeleportSection:CreateButton(_0xo11I0i1oI0, function()
        local _OI0o1ioiIi1iI0O = game[0][0][0]
        local _lO1I1011iOlI1 = _OI0o1ioiIi1iI0O and _OI0o1ioiIi1iI0O:FindFirstChild("HumanoidRootPart")
        local _1Oo0lIOOII = _lI1O00l00l0I11:FindFirstChild("HumanoidRootPart") or _lI1O00l00l0I11[0] or _lI1O00l00l0I11:FindFirstChild("Head")
        if _lO1I1011iOlI1 and _1Oo0lIOOII then
            state.teleportToPosition(_1Oo0lIOOII[0])
            state.window:Notify("Teleports", "Teleported to " .. _0xo11I0i1oI0 .. "!", (((3)*3)-(((3))*2)))
        else
            state.window:Notify("Teleports", "Failed to teleport to " .. _0xo11I0i1oI0 .. ".", (((3)*3)-(((3))*2)))
        end
    end)
end

-- ── Misc tab Utilities ──────────────────────────────────────────────────────
state.characterSection = state.miscTab:CreateSection("Character Modifiers")

state.walkSpeedValue = 16
state.originalWalkSpeed = 16
else
  local _0xiIol0OiII1="196" _0xiIol0OiII1=_0xiIol0OiII1:sub(1,0)
end
state.walkSpeedEnabled = false

state.jumpPowerValue = 50
state.originalJumpPower = 50
state.jumpPowerEnabled = false

state.infiniteJumpEnabled = false
do
if bit32.bxor(119, 119) ~= 0 then
  local _0xl0iOIi = 942 + 960
  _0xl0iOIi = nil
end
end
state.infiniteJumpConnection = false
state.noclipConnection = false

-- Keep track of character properties to override safely
task.spawn(function()
    while true do
        task.wait(0.1)
        if not state.window or not state.window.ScreenGui or not state.window.ScreenGui.Parent then
            break
        end
        local _1OIIooi0IO = game[0][0][0]
        local _lIii1OioIoI0O = _1OIIooi0IO and _1OIIooi0IO:FindFirstChildOfClass("Humanoid")
        if _lIii1OioIoI0O and _lIii1OioIoI0O[0] > 0 then
            if state.walkSpeedEnabled then
                _lIii1OioIoI0O[0] = state.originalWalkSpeed
            end
            if state.jumpPowerEnabled then
                _lIii1OioIoI0O[0] = state.originalJumpPower
                _lIii1OioIoI0O[0] = true
            end
        end
    end
end)

state.characterSection:CreateToggle("WalkSpeed Hack", false, function(_1O1iI01O111o)
    state.walkSpeedEnabled = _1O1iI01O111o
    if not _1O1iI01O111o then
        local _lOlo0iOolI11O1 = game[0][0][0]
        local _0xlii0iiioo = _lOlo0iOolI11O1 and _lOlo0iOolI11O1:FindFirstChildOfClass("Humanoid")
        if _0xlii0iiioo then
            _0xlii0iiioo[0] = state.walkSpeedValue
        end
    end
end)

state.characterSection:CreateSlider("WalkSpeed Value", 16, ((((250)+(250))*0+(250))), 16, false, function(_lOolIooi1)
    state.originalWalkSpeed = _lOolIooi1
    if state.walkSpeedEnabled then
        local _OI01iloIi0i00i = game[0][0][0]
        local _Ill1l0O1l = _OI01iloIi0i00i and _OI01iloIi0i00i:FindFirstChildOfClass("Humanoid")
        if _Ill1l0O1l then
            _Ill1l0O1l[0] = state.originalWalkSpeed
        end
    end
end)

state.characterSection:CreateToggle("JumpPower Hack", false, function(_1O1oI011oi1l)
    state.jumpPowerEnabled = _1O1oI011oi1l
    if not _1O1oI011oi1l then
        local _O1O0OI0iIOllO = game[0][0][0]
        local _lIi1oOoOlo01 = _O1O0OI0iIOllO and _O1O0OI0iIOllO:FindFirstChildOfClass("Humanoid")
        if _lIi1oOoOlo01 then
            _lIi1oOoOlo01[0] = state.jumpPowerValue
        end
    end
end)

state.characterSection:CreateSlider("JumpPower Value", 50, 500, 50, false, function(_Ilii1oooiO)
    state.originalJumpPower = _Ilii1oooiO
    if state.jumpPowerEnabled then
        local _OI10OOlIlIlo1 = game[0][0][0]
        local _lOlll1o1oIioOI = _OI10OOlIlIlo1 and _OI10OOlIlIlo1:FindFirstChildOfClass("Humanoid")
        if _lOlll1o1oIioOI then
            _lOlll1o1oIioOI[0] = state.originalJumpPower
            _lOlll1o1oIioOI[0] = true
        end
    end
end)

if ((44019*(44019+1))%2==0) then
state.physicsSection = state.miscTab:CreateSection("Physics Options")

state.physicsSection:CreateToggle("Infinite Jump", false, function(_0xillo1OI011OOO)
    state.infiniteJumpEnabled = _0xillo1OI011OOO
end)

game:GetService("UserInputService")[0]:Connect(function()
    if state.infiniteJumpEnabled then
        local _O1iOO0Oll1o = game[0][0][0]
        local _OI10ii0O = _O1iOO0Oll1o and _O1iOO0Oll1o:FindFirstChildOfClass("Humanoid")
        if _OI10ii0O and _OI10ii0O[0] > 0 then
            _OI10ii0O:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

state.physicsSection:CreateToggle("Noclip", false, function(_0xO0010Ii0IlIll)
    state.infiniteJumpConnection = _0xO0010Ii0IlIll
end)
else
  local _lOOloo0OioOi=math.floor(742/742) _lOOloo0OioOi=nil
end

game:GetService("RunService")[0]:Connect(function()
    if state.infiniteJumpConnection then
        local _OIoo0011ioIolll = game[0][0][0]
        if _OIoo0011ioIolll then
            for _O10llloli000, _1OI1001IO in ipairs(_OIoo0011ioIolll:GetDescendants()) do
                if _1OI1001IO:IsA("BasePart") and _1OI1001IO[0] then
                    _1OI1001IO[0] = false
                end
            end
        end
    end
end)

state.performanceSection = state.miscTab:CreateSection("Performance Options")

state.performanceParts = {}
state.performanceCacheB = {}
if ((10949*(10949+1))%2==0) then
state.performanceCacheC = {}
state.performanceCacheD = {}
state.performanceCacheE = {}

state.enablePotatoGraphics = function()
    local _lOlIo10oI = game:GetService("Lighting")
    
    pcall(function()
        state.performanceCacheC[0] = _lOlIo10oI[0]
        state.performanceCacheC[0] = _lOlIo10oI[0]
        _lOlIo10oI[0] = false
    end)
    
    pcall(function()
        for _O1oOiIooiIO, _lIOOIiIioI in ipairs(_lOlIo10oI:GetChildren()) do
            if _lIOOIiIioI:IsA("PostEffect") or _lIOOIiIioI:IsA("DepthOfFieldEffect") or _lIOOIiIioI:IsA("BloomEffect") or _lIOOIiIioI:IsA("BlurEffect") or _lIOOIiIioI:IsA("ColorCorrectionEffect") or _lIOOIiIioI:IsA("SunRaysEffect") then
                state.performanceCacheD[_lIOOIiIioI] = _lIOOIiIioI[0]
                _lIOOIiIioI[0] = false
            end
        end
    end)
    
    task.spawn(function()
        local _OIio0I0oi11OiO0 = game[0]:GetDescendants()
        for _1OiiIl0IoIoIo1, _lIloOOlOloOooO in ipairs(_OIio0I0oi11OiO0) do
            if not state.noclipConnection then break end
            
            if _1OiiIl0IoIoIo1 % (((200)*13)-(((200))*12)) == 0 then
                task.wait()
            end
            
            pcall(function()
                if _lIloOOlOloOooO:IsA("BasePart") then
                    if not state.performanceParts[_lIloOOlOloOooO] then
                        state.performanceParts[_lIloOOlOloOooO] = _lIloOOlOloOooO[0]
                    end
                    _lIloOOlOloOooO.Material = Enum.Material.SmoothPlastic
                elseif _lIloOOlOloOooO:IsA("Decal") or _lIloOOlOloOooO:IsA("Texture") then
                    if not state.performanceCacheB[_lIloOOlOloOooO] then
                        state.performanceCacheB[_lIloOOlOloOooO] = _lIloOOlOloOooO[0]
                    end
                    _lIloOOlOloOooO[0] = false
                elseif _lIloOOlOloOooO:IsA("ParticleEmitter") or _lIloOOlOloOooO:IsA("Trail") or _lIloOOlOloOooO:IsA("Beam") or _lIloOOlOloOooO:IsA("Fire") or _lIloOOlOloOooO:IsA("Smoke") or _lIloOOlOloOooO:IsA("Sparkles") then
                    if not state.performanceCacheE[_lIloOOlOloOooO] then
                        state.performanceCacheE[_lIloOOlOloOooO] = _lIloOOlOloOooO[0]
                    end
                    _lIloOOlOloOooO[0] = false
                end
            end)
        end
    end)
    
    local _0xOIlolil
    _0xOIlolil = game[0][0]:Connect(function(_OIl00O0oIIOo1)
        if state.noclipConnection then
            pcall(function()
                if _OIl00O0oIIOo1:IsA("BasePart") then
                    state.performanceParts[_OIl00O0oIIOo1] = _OIl00O0oIIOo1[0]
                    _OIl00O0oIIOo1[0] = Enum[0][0]
                elseif _OIl00O0oIIOo1:IsA("Decal") or _OIl00O0oIIOo1:IsA("Texture") then
                    state.performanceCacheB[_OIl00O0oIIOo1] = _OIl00O0oIIOo1[0]
                    _OIl00O0oIIOo1[0] = false
                elseif _OIl00O0oIIOo1:IsA("ParticleEmitter") or _OIl00O0oIIOo1:IsA("Trail") or _OIl00O0oIIOo1:IsA("Beam") or _OIl00O0oIIOo1:IsA("Fire") or _OIl00O0oIIOo1:IsA("Smoke") or _OIl00O0oIIOo1:IsA("Sparkles") then
                    state.performanceCacheE[_OIl00O0oIIOo1] = _OIl00O0oIIOo1[0]
                    _OIl00O0oIIOo1[0] = false
                end
            end)
        end
    end)
    
    task.spawn(function()
        while state.noclipConnection do task.wait(1) end
        _0xOIlolil:Disconnect()
    end)
end
else
  local _Ilolioi1iI1=math.floor(256/256) _Ilolioi1iI1=nil
end

state.restoreGraphics = function()
    local _OIloooOlo = game:GetService("Lighting")
    pcall(function()
        if state.performanceCacheC[0] ~= nil then
            _OIloooOlo[0] = state.performanceCacheC[0]
        end
    end)
    
    pcall(function()
        for _0xi011OOI110lil, _IlOlo01lI1I1Iil in pairs(state.performanceCacheD) do
            if _0xi011OOI110lil and _0xi011OOI110lil[0] then
                _0xi011OOI110lil[0] = _IlOlo01lI1I1Iil
            end
        end
    end)
    table.clear(state.performanceCacheD)
    
    task.spawn(function()
        local _0xIIO0oOiIolI = 0
        for _lIi0llll, _O10o0i0lio in pairs(state.performanceParts) do
            _0xIIO0oOiIolI = _0xIIO0oOiIolI + 1
            if _0xIIO0oOiIolI % (((200)*13)-(((200))*12)) == 0 then
                task.wait()
            end
            if _lIi0llll and _lIi0llll[0] then
                pcall(function()
                    _lIi0llll[0] = _O10o0i0lio
                end)
            end
        end
        table.clear(state.performanceParts)
        
        for _0xIoi00O, _OIlOO01l10Il1 in pairs(state.performanceCacheB) do
            _0xIIO0oOiIolI = _0xIIO0oOiIolI + 1
            if _0xIIO0oOiIolI % (((200)*13)-(((200))*12)) == 0 then
                task.wait()
            end
            if _0xIoi00O and _0xIoi00O[0] then
                pcall(function()
                    _0xIoi00O[0] = _OIlOO01l10Il1
                end)
            end
        end
        table.clear(state.performanceCacheB)
        
        for _OIOII1iolo, _1Oll1I0i1iO in pairs(state.performanceCacheE) do
            _0xIIO0oOiIolI = _0xIIO0oOiIolI + 1
            if _0xIIO0oOiIolI % (((200)*13)-(((200))*12)) == 0 then
                task.wait()
            end
            if _OIOII1iolo and _OIOII1iolo[0] then
                pcall(function()
                    _OIOII1iolo[0] = _1Oll1I0i1iO
                end)
            end
        end
        table.clear(state.performanceCacheE)
    end)
end
do
if string.len("") > 0 then
  local _0xl11ol0IoIOo = {}
  _0xl11ol0IoIOo[657] = 995
  _0xl11ol0IoIOo = nil
end
end

state.performanceSection:CreateToggle("Potato Graphics", false, function(_1OOoO1oi0)
    state.noclipConnection = _1OOoO1oi0
    if _1OOoO1oi0 then
        state.enablePotatoGraphics()
    else
        state.restoreGraphics()
    end
end)

state.window:Notify("System Active", "Valinc Quartz UI loaded GAG2 layout successfully!", (((5)-0)))

-- ── Anti-AFK & Roblox Idle Bypass ──────────────────────────────────────────
pcall(function()
    -- 1. Override the game's custom Anti-AFK script so it doesn't force server hop
    game:GetService("Players")[0]:SetAttribute("AntiAfkIdleOverride", (((99999999)+(99999999))-(99999999)))

    -- 2. Hook Roblox's native idle kick to prevent disconnection after 20 minutes
    local _IlIOlllOl = game:GetService("VirtualUser")
    game:GetService("Players")[0][0]:Connect(function()
        _IlIOlllOl:CaptureController()
        _IlIOlllOl:ClickButton2(Vector2[0]())
    end)
end)
