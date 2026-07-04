local P_S = game:GetService("Players")
local R_S = game:GetService("ReplicatedStorage")
local R_UN = game:GetService("RunService")
local L_P = P_S.LocalPlayer

local env = getgenv and getgenv() or _G
env.IndraHubGardenRunning = true
env.IndraHubGardenLastHeartbeat = os.clock()
env.IndraHubGardenError = nil

task.spawn(function()
    while env.IndraHubGardenRunning do
        env.IndraHubGardenLastHeartbeat = os.clock()
        task.wait(2)
    end
end)

local W_UI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local GUI_Win = W_UI:CreateWindow({
    Title = "IndraHub",
    Icon = "leaf",
    Author = "IndraT99",
    Folder = "IndraConfig",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 170,
    HideSearchBar = false,
})

local T_Farm = GUI_Win:Tab({Title = "Farming", Icon = "tractor"})
local T_Shop = GUI_Win:Tab({Title = "Shop", Icon = "shopping-cart"})
local T_Ext = GUI_Win:Tab({Title = "Misc", Icon = "moon"})

local ToggleFlags = {
    HarvestAll = false,
    SellItems = false,
    ThiefMode = false,
    BuyS = false,
    BuyG = false,
    BuyC = false,
}

local function alertMsg(t, c, i)
    if W_UI and type(W_UI.Notify) == "function" then
        pcall(function() W_UI:Notify({Title = t, Content = c, Icon = i or "info", Duration = 3}) end)
    end
end

local function retrieveModule(mod)
    local s, r = pcall(function() return require(mod) end)
    return s and r or nil
end

local SharedData = R_S:WaitForChild("SharedModules", 5)
local NetFolder = SharedData and SharedData:WaitForChild("Networking", 5)
local FlagData = SharedData and SharedData:WaitForChild("Flags", 5)
local StealConf = FlagData and FlagData:WaitForChild("StealFlags", 5)
local ValCalc = SharedData and SharedData:WaitForChild("FruitValueCalc", 5)

local Net = NetFolder and retrieveModule(NetFolder)
local StealAPI = StealConf and retrieveModule(StealConf)
local FruitAPI = ValCalc and retrieveModule(ValCalc)

local FarmArea = workspace:WaitForChild("Gardens", 5)
local PS_Scripts = L_P:WaitForChild("PlayerScripts", 5)
local ControlDir = PS_Scripts and PS_Scripts:WaitForChild("Controllers", 5)
local LifecycleScript = ControlDir and ControlDir:WaitForChild("PlantLifecycleHandler", 5)
local LifeAPI = LifecycleScript and retrieveModule(LifecycleScript)
local NightVal = R_S:WaitForChild("Night", 5)

local StockVal = R_S:FindFirstChild("StockValues")
local SS_Stock = StockVal and StockVal:FindFirstChild("SeedShop") and StockVal.SeedShop:FindFirstChild("Items")
local GS_Stock = StockVal and StockVal:FindFirstChild("GearShop") and StockVal.GearShop:FindFirstChild("Items")
local CS_Stock = StockVal and StockVal:FindFirstChild("CrateShop") and StockVal.CrateShop:FindFirstChild("Items")

local CmdSeed = Net and Net.SeedShop and Net.SeedShop.PurchaseSeed
local CmdGear = Net and Net.GearShop and Net.GearShop.PurchaseGear
local CmdCrate = Net and Net.CrateShop and Net.CrateShop.PurchaseCrate

local MyZone = nil
local function locateMyPlot()
    if MyZone then return MyZone end
    if not FarmArea then return nil end
    for _, z in ipairs(FarmArea:GetChildren()) do
        if z:GetAttribute("Owner") == L_P.Name then
            MyZone = z
            return z
        end
    end
    return nil
end

task.spawn(function()
    while not MyZone do
        locateMyPlot()
        task.wait(1)
    end
end)

local LunarRates = {
    {N = "Rainbow Moon", C = 6},
    {N = "Goldmoon", C = 13},
    {N = "Bloodmoon", C = 2},
    {N = "Moon", C = 79}
}

local function evalLunarPhase(cID, ord)
    local ran = Random.new(cID * 1000 + ord)
    local r = ran:NextNumber() * 100
    local accum = 0
    for _, m in ipairs(LunarRates) do
        accum = accum + m.C
        if r <= accum then return m.N end
    end
    return "Moon" 
end

local function generate24hLunar()
    local st = os.time()
    local ed = st + 86400 
    local out = {}
    for t = st, ed, 600 do
        local id = math.floor(t / 600)
        local tm = os.date("%I:%M %p", t)
        local ph = evalLunarPhase(id, 3)
        table.insert(out, string.format("[%s] %s", tm, ph))
    end
    return out
end

local function verifyStealTarget(plr)
    if not plr then return false end
    local ok, res = pcall(function() return plr:GetAttribute("IsInOwnGarden") end)
    return ok and (res or false)
end

local function smoothMove(root, startPos, endPos, vel)
    local dist = (endPos.Position - startPos.Position).Magnitude
    local maxTime = dist / vel
    local elapsed = 0
    local conn
    conn = R_UN.RenderStepped:Connect(function(dt)
        pcall(function()
            elapsed = elapsed + dt
            if elapsed >= maxTime then
                if root and root.Parent then root.CFrame = endPos end
                if conn then conn:Disconnect() end
                return
            end
            local frac = elapsed / maxTime
            if root and root.Parent then
                root.CFrame = startPos:Lerp(endPos, frac)
            else
                if conn then conn:Disconnect() end
            end
        end)
    end)
    local initT = os.clock()
    while conn.Connected and os.clock() - initT < maxTime + 2 do task.wait() end
    if conn.Connected then pcall(function() conn:Disconnect() end) end
end

local function checkNight()
    if not NightVal then return false end
    local ok, t = pcall(function() return NightVal:IsA("BoolValue") end)
    if not ok or not t then return false end
    return NightVal.Value == true
end

local function assessDecay(mdl)
    if not LifeAPI then return 0 end
    local ok, rec = pcall(function() return LifeAPI:GetActiveEntries() end)
    if not ok or type(rec) ~= "table" then return 0 end
    for pID, pData in pairs(rec) do
        local isM = false
        local dcy = 0
        pcall(function()
            if pData and pData.Model == mdl then
                local pre, suf = string.match(pID, "^(%d+)_(.+)$")
                if pre and suf then
                    local sOk, sVal = pcall(function() return LifeAPI:GetDecayAlpha(tonumber(pre), suf) end)
                    if sOk then
                        dcy = sVal or 0
                        isM = true
                    end
                end
            end
        end)
        if isM then return dcy end
    end
    return 0
end

local function scanForLoot()
    local topTarget, topScore = nil, -1
    local zones = FarmArea and FarmArea:GetChildren()
    if type(zones) ~= "table" then return topTarget, topScore end

    for _, z in ipairs(zones) do
        if z:IsA("Model") then
            local pFol = z:FindFirstChild("Plants")
            if pFol then
                for _, crop in ipairs(pFol:GetChildren()) do
                    if crop:IsA("Model") then
                        local fFol = crop:FindFirstChild("Fruits")
                        if fFol then
                            for _, frt in ipairs(fFol:GetChildren()) do
                                if frt:IsA("Model") then
                                    local sName = crop:GetAttribute("SeedName") or crop:GetAttribute("CorePartName")
                                    local pId = crop:GetAttribute("PlantId")
                                    if sName and pId and StealAPI and StealAPI.IsPlantStealable then
                                        if StealAPI.IsPlantStealable(sName) then
                                            local uId = crop:GetAttribute("UserId")
                                            if uId then
                                                local tPlr = P_S:GetPlayerByUserId(tonumber(uId))
                                                if tPlr and not verifyStealTarget(tPlr) then
                                                    local mut = frt:GetAttribute("Mutation") or ""
                                                    local sz = frt:GetAttribute("SizeMulti") or 1
                                                    local dAlpha = assessDecay(crop)
                                                    if FruitAPI then
                                                        local wok, wval = pcall(function()
                                                            return FruitAPI(sName, sz, mut, L_P, dAlpha)
                                                        end)
                                                        if wok and wval and wval > topScore then
                                                            topScore = wval
                                                            topTarget = crop
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return topTarget, topScore
end

local function commitTheft(obj)
    if not checkNight() or not obj then return end

    local oId = tonumber(obj:GetAttribute("UserId"))
    local pId = obj:GetAttribute("PlantId")
    local fId = obj:GetAttribute("FruitId") or ""
    
    if not oId or type(pId) ~= "string" or type(fId) ~= "string" then return end
    
    local c = L_P.Character
    local hRoot = c and c:FindFirstChild("HumanoidRootPart")
    if not hRoot then return end

    local plot = locateMyPlot()
    local ref = plot and plot:FindFirstChild("PlotSizeReference")
    if not ref then return end
    
    local baseCFrame = ref.CFrame
    local bPart = obj:FindFirstChildWhichIsA("BasePart")
    if not bPart then return end
    
    local dest = bPart.CFrame + Vector3.new(0, 3, 0)

    smoothMove(hRoot, baseCFrame, dest, 33.8)
    task.wait(1)

    if Net and Net.Steal then
        if Net.Steal.BeginSteal then Net.Steal.BeginSteal:Fire(oId, pId, fId) end
        if Net.Steal.CompleteSteal then Net.Steal.CompleteSteal:Fire() end
    end

    task.wait(1)
    smoothMove(hRoot, dest, baseCFrame, 33.8)
end

local shopCosts = {}
local accData = nil
pcall(function()
    for _, fn in pairs(getgc()) do
        if type(fn) == "function" and debug.info(fn, "s"):match("RestockStoreController") and debug.info(fn, "l") == 575 then
            pcall(function()
                table.insert(shopCosts, debug.getupvalue(fn, 3))
                accData = debug.getupvalue(fn, 9)
            end)
        end
    end
end)

local function balanceCheck(itemName)
    if not accData then return false end
    for _, tbl in ipairs(shopCosts) do
        local ok, val = pcall(function()
            local d = tbl[itemName]
            if not d then return false end
            return (accData.Data.Sheckles or 0) >= d.price
        end)
        if ok and val then return true end
    end
    return false
end

local ignoreList = {}

local function checkMature(cObj)
    local mx = cObj:GetAttribute("MaxAge")
    local cur = cObj:GetAttribute("Age")
    return mx and cur and cur >= mx or false
end

local function gatherReadyCrops()
    local arr = {}
    local p = locateMyPlot()
    if not p then return arr end
    local pFol = p:FindFirstChild("Plants")
    if not pFol then return arr end

    for _, c in ipairs(pFol:GetChildren()) do
        local fFol = c:FindFirstChild("Fruits")
        if fFol then
            for _, fr in ipairs(fFol:GetChildren()) do
                if fr:IsA("Model") and checkMature(fr) then table.insert(arr, fr) end
            end
        elseif c:IsA("Model") and checkMature(c) then
            table.insert(arr, c)
        end
    end
    return arr
end

local function grabYield(cObj)
    if not cObj or not Net then return end
    local i = cObj:GetAttribute("PlantId")
    local fi = cObj:GetAttribute("FruitId") or ""
    if i and Net.Garden and Net.Garden.CollectFruit then
        Net.Garden.CollectFruit:Fire(i, fi)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if ToggleFlags.ThiefMode then
            pcall(function()
                local t, _ = scanForLoot()
                if t then commitTheft(t) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if ToggleFlags.BuyS and SS_Stock and CmdSeed then
            for _, s in ipairs(SS_Stock:GetChildren()) do
                if s:IsA("NumberValue") and s.Value > 0 and not table.find(ignoreList, s.Name) and balanceCheck(s.Name) then
                    pcall(function() CmdSeed:Fire(s.Name) end)
                end
            end
        end
        if ToggleFlags.BuyG and GS_Stock and CmdGear then
            for _, g in ipairs(GS_Stock:GetChildren()) do
                if g:IsA("NumberValue") and g.Value > 0 and not table.find(ignoreList, g.Name) and balanceCheck(g.Name) then
                    pcall(function() CmdGear:Fire(g.Name) end)
                end
            end
        end
        if ToggleFlags.BuyC and CS_Stock and CmdCrate then
            for _, c in ipairs(CS_Stock:GetChildren()) do
                if c:IsA("NumberValue") and c.Value > 0 and not table.find(ignoreList, c.Name) and balanceCheck(c.Name) then
                    pcall(function() CmdCrate:Fire(c.Name) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if ToggleFlags.HarvestAll then
            pcall(function()
                for _, cr in ipairs(gatherReadyCrops()) do grabYield(cr) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if ToggleFlags.SellItems and Net and Net.NPCS and Net.NPCS.SellAll then
            pcall(function() Net.NPCS.SellAll:Fire() end)
        end
    end
end)

T_Farm:Section({Title = "Farming", Icon = "tractor"})
T_Farm:Toggle({Title = "Auto Harvest", Desc = "Automatically harvest grown plants", Value = false, Callback = function(s) ToggleFlags.HarvestAll = s end})
T_Farm:Toggle({Title = "Auto Sell", Desc = "Automatically sell items", Value = false, Callback = function(s) ToggleFlags.SellItems = s end})
T_Farm:Toggle({Title = "Auto Steal", Desc = "Automatically teleport and steal best plants at night", Value = false, Callback = function(s) ToggleFlags.ThiefMode = s end})

T_Shop:Section({Title = "Auto Buy", Icon = "shopping-cart"})
T_Shop:Toggle({Title = "Auto Buy Seeds", Desc = "Automatically buy seeds when restocked", Value = false, Callback = function(s) ToggleFlags.BuyS = s end})
T_Shop:Toggle({Title = "Auto Buy Gears", Desc = "Automatically buy gears when restocked", Value = false, Callback = function(s) ToggleFlags.BuyG = s end})
T_Shop:Toggle({Title = "Auto Buy Crates", Desc = "Automatically buy crates when restocked", Value = false, Callback = function(s) ToggleFlags.BuyC = s end})

T_Ext:Section({Title = "Predictions", Icon = "moon"})

local moonData = generate24hLunar()
T_Ext:Dropdown({
    Title = "24h Moon Timeline",
    Desc = "Select to view the predicted moons for the next 24 hours.",
    Options = moonData,
    Value = moonData[1],
    Callback = function(s) end
})

alertMsg("IndraHub", "Garden features loaded!", "check")
