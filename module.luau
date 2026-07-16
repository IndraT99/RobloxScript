local module = {}

--[[
Table Things
]]--
local SpecialCharacters = {['\a'] = '\\a', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\v'] = '\\v', ['\0'] = '\\0'}
local Keywords = { ['and'] = true, ['break'] = true, ['do'] = true, ['else'] = true, ['elseif'] = true, ['end'] = true, ['false'] = true, ['for'] = true, ['function'] = true, ['if'] = true, ['in'] = true, ['local'] = true, ['nil'] = true, ['not'] = true, ['or'] = true, ['repeat'] = true, ['return'] = true, ['then'] = true, ['true'] = true, ['until'] = true, ['while'] = true, ['continue'] = true}
local Functions = {
    [pairs] = "pairs",
    [ipairs] = "ipairs", 
    [next] = "next",
    [type] = "type",
    [tostring] = "tostring",
    [tonumber] = "tonumber",
    [print] = "print",
    [error] = "error",
    [assert] = "assert",
    [pcall] = "pcall",
    [xpcall] = "xpcall",
    [select] = "select",
    [rawget] = "rawget",
    [rawset] = "rawset",
    [rawequal] = "rawequal",
    [getmetatable] = "getmetatable",
    [setmetatable] = "setmetatable",
    [require] = "require",
}
if loadstring then Functions[loadstring] = "loadstring" end
if load then Functions[load] = "load" end
local function safeTypeof(value)
    if typeof then
        return typeof(value)
    else
        return type(value)
    end
end
function GetHierarchy(Object)
    if not Object or (type(Object) ~= "table" and safeTypeof(Object) ~= "Instance") then
        return tostring(Object)
    end
    local Hierarchy = {}
    local current = Object
    while current do
        local name = tostring(current.Name or current.name or "Unknown")
        name = string.gsub(name, '[%c%z]', SpecialCharacters)
        if current == game or current == _G.game then
            table.insert(Hierarchy, 1, "game")
        elseif Keywords[name] or not string.match(name, '^[_%a][_%w]*$') then
            table.insert(Hierarchy, 1, '["' .. name .. '"]')
        else
            table.insert(Hierarchy, 1, name)
        end
        current = current.Parent
    end
    
    return table.concat(Hierarchy, ".")
end
local function SerializeType(Value, Class)
    if Class == 'string' then
        return string.format('"%s"', string.gsub(Value, '[%c%z]', SpecialCharacters))
    elseif Class == 'Instance' then
        return GetHierarchy(Value)
    elseif Class == 'function' then
        return Functions[Value] or "'[Function: " .. tostring(Value) .. "]'"
    elseif Class == 'userdata' then
        return "'[userdata: " .. tostring(Value) .. "]'"
    elseif Class == 'thread' then
        if coroutine and coroutine.status then
            local status = pcall(function() return coroutine.status(Value) end)
            return "'[thread: " .. tostring(Value) .. (status and ", status: " .. coroutine.status(Value) or "") .. "]'"
        else
            return "'[thread: " .. tostring(Value) .. "]'"
        end
    else
        return tostring(Value)
    end
end
function TableToLuauString(Table, IgnoredTables, DepthData, Path)
    if type(Table) ~= "table" then
        return SerializeType(Table, safeTypeof(Table))
    end
    IgnoredTables = IgnoredTables or {}
    Path = Path or "ROOT"
    if not DepthData then
        DepthData = {0, Path}
    end
    local CyclicData = IgnoredTables[Table]
    if CyclicData then
        local currentDepth = DepthData[1] or 0
        local cyclicDepth = CyclicData[1] or 0
        return ((cyclicDepth == currentDepth - 1 and "'[Cyclic Parent " or "'[Cyclic ") .. tostring(Table) .. ', path: ' .. (CyclicData[2] or "unknown") .. "]'")
    end
    DepthData[1] = (DepthData[1] or 0) + 1
    DepthData[2] = Path
    IgnoredTables[Table] = {DepthData[1], DepthData[2]}
    local currentDepth = DepthData[1] or 1
    local Tab = string.rep('    ', currentDepth)
    local TrailingTab = string.rep('    ', currentDepth - 1)
    local Result = '{'
    local LineTab = '\n' .. Tab
    local HasOrder = true
    local Index = 1
    local IsEmpty = true
    for Key, Value in pairs(Table) do
        IsEmpty = false
        if Index ~= Key then
            HasOrder = false
        else
            Index = Index + 1
        end
        local KeyClass = safeTypeof(Key)
        local ValueClass = safeTypeof(Value)
        local HasBrackets = false
        local KeyStr
        if KeyClass == 'string' then
            local cleanKey = string.gsub(Key, '[%c%z]', SpecialCharacters)
            if Keywords[cleanKey] or not string.match(cleanKey, '^[_%a][_%w]*$') then
                HasBrackets = true
                KeyStr = string.format('["%s"]', cleanKey)
            else
                KeyStr = cleanKey
            end
        else
            HasBrackets = true
            if KeyClass == 'table' then
                KeyStr = '[' .. TableToLuauString(Key, IgnoredTables, {currentDepth + 1, Path}) .. ']'
            else
                KeyStr = '[' .. SerializeType(Key, KeyClass) .. ']'
            end
        end
        local ValueStr
        if ValueClass == 'table' then
            local newPath = Path .. (HasBrackets and '' or '.') .. KeyStr
            ValueStr = TableToLuauString(Value, IgnoredTables, {currentDepth + 1, Path}, newPath)
        else
            ValueStr = SerializeType(Value, ValueClass)
        end
        Result = Result .. LineTab .. (HasOrder and ValueStr or KeyStr .. ' = ' .. ValueStr) .. ','
    end
    local donetable = IsEmpty and Result .. '}' or string.sub(Result, 1, -2) .. '\n' .. TrailingTab .. '}'
    IgnoredTables[Table] = nil
    return donetable
end

local LocalPlayer, LP = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer
local Character, Char = nil, nil
local HumanoidRootPart, HRP = nil, nil
local Humanoid, Hum = nil, nil
pcall(function()
Character, Char = LocalPlayer.Character, LocalPlayer.Character
end)
pcall(function()
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
end)
pcall(function()
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)
LocalPlayer.CharacterAdded:Connect(function(char)
pcall(function()
Character, Char = nil, nil
HumanoidRootPart, HRP = nil, nil
Humanoid, Hum = nil, nil
task.wait()
Character, Char = char, char
repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
HumanoidRootPart, HRP = char.HumanoidRootPart, char.HumanoidRootPart
repeat task.wait() until Character:FindFirstChild("Humanoid")
Humanoid, Hum = char.Humanoid, char.Humanoid
end)
end)

function module.IsWorking()
return (module~=nil)
end

function module:ConvertToTable(a)
local b = TableToLuauString(a)
task.wait(0)
return "return "..b
end

function module:RequestModule(module)
if (string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "xeno") or string.find(identifyexecutor(), "XENO")) or (string.find(identifyexecutor(), "Solara") or string.find(identifyexecutor(), "solara") or string.find(identifyexecutor(), "SOLARA")) then return nil end
local result = nil
local Success, Error = pcall(function()
result = require(module)
function module:GetWorkingRayfield()
    local okWindUI, WindUI = pcall(function()
        local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
        return loadstring(source)()
    end)
    
    local RayfieldLibrary = {}
    
    function RayfieldLibrary:CreateWindow(config)
        local Window = WindUI:CreateWindow({
            Title = config.Name or "WindUI Window",
            Icon = "lucide-layout-dashboard",
            Author = config.LoadingSubtitle or "IndraHub",
            Folder = config.ConfigurationSaving and config.ConfigurationSaving.FolderName or "WindUI_Saves",
            Size = UDim2.fromOffset(580, 460),
            Transparent = true,
            Theme = "Dark",
            Resizable = true,
            SideBarWidth = 175,
        })
        
        local fakeWindow = {}
        
        function fakeWindow:CreateTab(name, icon)
            local iconStr = "list"
            if type(icon) == "string" and icon ~= "" then iconStr = icon end
            
            local realTab = Window:Tab({
                Title = name or "Tab",
                Icon = iconStr
            })
            
            local fakeTab = {}
            
            function fakeTab:CreateParagraph(pconfig)
                return realTab:Paragraph({
                    Title = pconfig.Title or "",
                    Desc = pconfig.Content or ""
                })
            end
            
            function fakeTab:CreateLabel(name)
                return realTab:Paragraph({
                    Title = name,
                    Desc = ""
                })
            end
            
            function fakeTab:CreateButton(bconfig)
                return realTab:Button({
                    Title = bconfig.Name or "Button",
                    Desc = bconfig.Description or "",
                    Callback = bconfig.Callback or function() end
                })
            end
            
            function fakeTab:CreateToggle(tconfig)
                local currentVal = tconfig.CurrentValue or false
                local toggle = realTab:Toggle({
                    Title = tconfig.Name or "Toggle",
                    Desc = tconfig.Description or "",
                    Value = currentVal,
                    Callback = tconfig.Callback or function() end
                })
                local fakeToggle = {}
                function fakeToggle:Set(val)
                    pcall(function() toggle:Set(val) end)
                end
                return fakeToggle
            end
            
            function fakeTab:CreateSlider(sconfig)
                local slider = realTab:Slider({
                    Title = sconfig.Name or "Slider",
                    Desc = sconfig.Description or "",
                    Step = sconfig.Increment or 1,
                    Min = sconfig.Range and sconfig.Range[1] or 0,
                    Max = sconfig.Range and sconfig.Range[2] or 100,
                    Value = sconfig.CurrentValue or (sconfig.Range and sconfig.Range[1] or 0),
                    Callback = sconfig.Callback or function() end
                })
                local fakeSlider = {}
                function fakeSlider:Set(val)
                    pcall(function() slider:Set(val) end)
                end
                return fakeSlider
            end
            
            function fakeTab:CreateDropdown(dconfig)
                local default = dconfig.CurrentOption
                if type(default) == "table" then default = default[1] end
                local dropdown = realTab:Dropdown({
                    Title = dconfig.Name or "Dropdown",
                    Desc = dconfig.Description or "",
                    Values = dconfig.Options or {},
                    Value = default,
                    Multi = dconfig.MultipleOptions or false,
                    Callback = dconfig.Callback or function() end
                })
                local fakeDd = {}
                function fakeDd:Set(val) pcall(function() dropdown:Select(val) end) end
                function fakeDd:Refresh(options, keepSelection) pcall(function() dropdown:Refresh(options) end) end
                return fakeDd
            end
            
            function fakeTab:CreateInput(iconfig)
                return realTab:Input({
                    Title = iconfig.Name or "Input",
                    Desc = iconfig.PlaceholderText or "",
                    Placeholder = iconfig.PlaceholderText or "",
                    Callback = iconfig.Callback or function() end
                })
            end
            
            function fakeTab:CreateSection(name)
                return realTab:Section({ Title = name })
            end
            
            return fakeTab
        end
        
        function fakeWindow:CreateTabSection(name)
            return {}
        end
        
        return fakeWindow
    end
    
    function RayfieldLibrary:Notify(data)
        pcall(function()
            WindUI:Notify({
                Title = data.Title or "Notification",
                Content = data.Content or "",
                Icon = "info",
                Duration = data.Duration or 3
            })
        end)
    end

    function RayfieldLibrary:Notification(title, content, duration, icon)
        pcall(function()
            WindUI:Notify({
                Title = title or "Notification",
                Content = content or "",
                Icon = "info",
                Duration = duration or 3
            })
        end)
    end
    
    return RayfieldLibrary
end

return module
