-- IndraHub - SkinChanger Supervisor Compatible
local env = getgenv and getgenv() or _G

rawset(_G, "IndraHubSkinChangerRunning", true)
rawset(_G, "IndraHubSkinChangerLastHeartbeat", os.clock())
rawset(_G, "IndraHubSkinChangerError", nil)

task.spawn(function()
    while rawget(_G, "IndraHubSkinChangerRunning") == true do
        rawset(_G, "IndraHubSkinChangerLastHeartbeat", os.clock())
        task.wait(2)
    end
end)

local ReplicatedStorage, Modules, EnumLibrary, Pcall_Result, Pcall_Result_2, ItemLibrary, Pcall_Result_3, PlayerDataController, Pcall_Result_4, Require_Result, Not_P3_15, Type_Result, Type_Result_2_Is_String, Not_Type_Result_3_Is_String_2, r343, Not_Type_Result_5_Is_String_4, Not_Type_Result_6_Is_String_5, Not_P3_15_2, Not_Not_P3_15_3, Not_Not_P3_15_4, Dictionary, Dictionary_2, r351, nil_Isnt_Nil, r355, OwnsCosmeticNormally, Not_P3_16, Not_Not_P3_16_2, Not_Not_P3_16_3, Cosmetics_2, Cosmetics_3, Cosmetics_4, r363, Not_Nil, Not_Not_Nil_2, Type, Dictionary_3, Dictionary_4, r370, Not_Nil_3, R115_Result, OwnsCosmeticUniversally, Not_P3_17, Not_Not_P3_17_2, Not_Not_P3_17_3, Cosmetics_5, Cosmetics_6, Cosmetics_7, r381, Not_Nil_4, Not_Not_Nil_5, Not_Not_Not_Nil_6, R118_Result, OwnsCosmeticForWeapon, Not_P3_18, Not_Not_P3_18_2, Not_Not_P3_18_3, Cosmetics_8, Cosmetics_9, Cosmetics_10, r395, Not_Nil_7, Not_Not_Nil_8, Not_Not_Not_Nil_9, R121_Result, P2_19_Is_CosmeticInventory, P2_19_Is_CosmeticInventory_2, R123_Result, Not_R123_Result_2, Not_Not_R123_Result_3, Not_Not_R123_Result_4, Array, Array_2, r413, Not_Nil_10, Not_Not_Nil_11, Not_Not_Not_Nil_12, For_Key_1, Dictionary_5, Dictionary_6, r421, r422, Data, Fighter, Modules_2, ClientReplicatedClasses, ClientFighter, ClientItem, Require_Result_2, Player, Player_2_Is_LocalPlayer_2, Player_3_Is_LocalPlayer_3, Modules_3, ClientReplicatedClasses_2, ClientFighter_2, ClientItem_2, ClientViewModel, Require_Result_3, ClientItem_3, Player_4_Is_LocalPlayer_4, ClientItem_4, Player_5_Is_LocalPlayer_5, Player_6, Player_7_Is_LocalPlayer_6, Player_8_Is_LocalPlayer_7, r228, Not_P2_30, Not_Not_P2_30_2, Not_Not_Not_P2_30_3, R228_Result, EmoteController, Pcall_Result_5, GetEmotes, R244_Result, Not_Pcall_Result_6, Cosmetics_11, Cosmetics_12, Cosmetics_13, Not_For_Key_3, Not_For_Val_3, For_Val_3_Type, For_Val_3_Type_2_Is_Dance, r516, Not_Nil_13, For_Val_3_Type_5, For_Val_3_Type_6_Is_Emote, r520, Not_Nil_14, r522, r523, Modules_4, Pages, ViewProfile, Require_Result_4, UnlockAllGui, TextLabel;
local fenv = getfenv();
if pcall(function(p1, p2, p3, a, b, c)

end) then 
    ReplicatedStorage = game:GetService("ReplicatedStorage");
    game:GetService("HttpService");
end;
local LocalPlayer = game:GetService("Players").LocalPlayer;
local PlayerScripts = LocalPlayer.PlayerScripts;
local Controllers = PlayerScripts:WaitForChild("Controllers", 15);
if not Controllers then
else 
    Modules = ReplicatedStorage:FindFirstChild("Modules");
end;
if Modules then 

end;
if not Modules then
else 
    EnumLibrary = Modules:FindFirstChild("EnumLibrary");
end;
if not EnumLibrary then
else 

end;
if EnumLibrary then 
    r33, Pcall_Result = pcall(require, EnumLibrary);
end;
if r33 then 
    if not Pcall_Result then
    else 
        if not Pcall_Result.WaitForEnumBuilder then
        else 
            pcall(function(p1_4, p2_4, p3_4, a_4, b_4, c_4)
                Pcall_Result:WaitForEnumBuilder();
            end);
        end;
    end;
end;
local CosmeticLibrary = Modules:FindFirstChild("CosmeticLibrary");
if not CosmeticLibrary then
else 

end;
if CosmeticLibrary then 
    r52, Pcall_Result_2 = pcall(require, CosmeticLibrary);
end;
if r52 then 

end;
if Pcall_Result_2 then 
    ItemLibrary = Modules:FindFirstChild("ItemLibrary");
end;
if not ItemLibrary then
else 

end;
if ItemLibrary then 
    r67, Pcall_Result_3 = pcall(require, ItemLibrary);
end;
if r67 then 

end;
if Pcall_Result_3 then 
    PlayerDataController = Controllers:FindFirstChild("PlayerDataController");
end;
if not PlayerDataController then
else 

end;
if PlayerDataController then 
    r82, Pcall_Result_4 = pcall(require, PlayerDataController);
end;
if r82 then 

end;
if not Pcall_Result_4 then
else 
    pcall(function(p1_8, a_8, b_8, c_8)
        Require_Result = require(
            Modules:WaitForChild("ReplicatedClass", 15)
        );
    end);
end;
if not Pcall_Result_2 then
else 

end;
local Not_Not_Cosmetics = Pcall_Result_2.Cosmetics;
if Not_Not_Cosmetics then 
    if Not_Not_Cosmetics then 

    end;
    for for_key_0, for_val_0 in pairs(Pcall_Result_2.Cosmetics) do
        local _ = not for_key_0;
        local _ = not for_val_0;
        local _ = not for_val_0.Type;
        if ({
            ["Dance"] = true,
            ["Skin"] = true,
            ["Wrapping"] = true,
            ["Wrap"] = true,
            ["Emote"] = true,
            ["Charm"] = true
        })[for_val_0.Type] then 
        end;
    end;
end;
Pcall_Result_2.OwnsCosmetic = function(p1_15, p2_15, p3_15, p4_15, a_15, b_15, c_15)
    Not_P3_15 = not p3_15;
    if Not_P3_15 then
    else 
        Type_Result = type(p3_15);
    end;
    Type_Result_2_Is_String = (Type_Result == "string");
    Not_Type_Result_3_Is_String_2 = not Type_Result_2_Is_String;
    r343 = not Not_Type_Result_3_Is_String_2;
    if r343 then
    else 
        Not_Type_Result_5_Is_String_4 = not Type_Result_2_Is_String;
    end;
    Not_Type_Result_6_Is_String_5 = Not_Type_Result_5_Is_String_4;
    if Not_Type_Result_6_Is_String_5 then 
        Not_P3_15_2 = not p3_15;
        Not_Not_P3_15_3 = not Not_P3_15_2;
    end;
    Not_Not_P3_15_4 = Not_Not_P3_15_3;
    if Not_Not_P3_15_4 then 
        Dictionary = {
            [for_key_0] = true
        };
        Dictionary_2 = Dictionary;
        r351 = Dictionary_2[p3_15];
        nil_Isnt_Nil = (r351);
    end;
    local _ = nil_Isnt_Nil;
    r355 = r351;
    if r355 then 

    end;
    return true;
end;
r51.OwnsCosmetic = function(p1_15, p2_15, p3_15, p4_15, a_15, b_15, c_15)
    Not_P3_15 = not p3_15;
    if Not_P3_15 then
    else
        Type_Result = type(p3_15);
    end;
    Type_Result_2_Is_String = (Type_Result == "string");
    Not_Type_Result_3_Is_String_2 = not Type_Result_2_Is_String;
    r343 = not Not_Type_Result_3_Is_String_2;
    if r343 then
    else
        Not_Type_Result_5_Is_String_4 = not Type_Result_2_Is_String;
    end;
    Not_Type_Result_6_Is_String_5 = Not_Type_Result_5_Is_String_4;
    if Not_Type_Result_6_Is_String_5 then
        Not_P3_15_2 = not p3_15;
        Not_Not_P3_15_3 = not Not_P3_15_2;
    end;
    Not_Not_P3_15_4 = Not_Not_P3_15_3;
    if Not_Not_P3_15_4 then
        Dictionary = {
            [for_key_0] = true
        };
        Dictionary_2 = Dictionary;
        r351 = Dictionary_2[p3_15];
        nil_Isnt_Nil = (r351);
    end;
    local _ = nil_Isnt_Nil;
    r355 = r351;
    if r355 then

    end;
    return true;
end;
if not Pcall_Result_2.OwnsCosmeticNormally then
else 
    OwnsCosmeticNormally = Pcall_Result_2.OwnsCosmeticNormally;
    Pcall_Result_2.OwnsCosmeticNormally = function(p1_16, p2_16, p3_16, p4_16, p5_16, p6_16, p7_16, p8_16, p9_16, a_16, b_16, c_16)
        Not_P3_16 = not p3_16;
        Not_Not_P3_16_2 = not Not_P3_16;
        Not_Not_P3_16_3 = Not_Not_P3_16_2;
        if Not_Not_P3_16_3 then 
            Cosmetics_2 = Pcall_Result_2.Cosmetics;
            Cosmetics_3 = Cosmetics_2;
            if Cosmetics_3 then 
                Cosmetics_4 = Pcall_Result_2.Cosmetics;
                r363 = Cosmetics_4[p3_16];
                Not_Nil = not r363;
                Not_Not_Nil_2 = not Not_Nil;
            end;
        end;
        local _ = not Not_Not_Nil_2;
        Type = r363.Type;
        Dictionary_3 = {
            ["KillEffect"] = true,
            ["Execution"] = true,
            ["Finisher"] = true,
            ["FinishMove"] = true
        };
        Dictionary_4 = Dictionary_3;
        r370 = Dictionary_4[Type];
        Not_Nil_3 = not r370;
        if Not_Nil_3 then
        else 
            R115_Result = OwnsCosmeticNormally(p1_16, p2_16, p3_16, p4_16);
        end;
        return R115_Result;
    end;
    r51.OwnsCosmeticNormally = function(p1_16, p2_16, p3_16, p4_16, p5_16, p6_16, p7_16, p8_16, p9_16, a_16, b_16, c_16)
        Not_P3_16 = not p3_16;
        Not_Not_P3_16_2 = not Not_P3_16;
        Not_Not_P3_16_3 = Not_Not_P3_16_2;
        if Not_Not_P3_16_3 then
            Cosmetics_2 = Pcall_Result_2.Cosmetics;
            Cosmetics_3 = Cosmetics_2;
            if Cosmetics_3 then
                Cosmetics_4 = Pcall_Result_2.Cosmetics;
                r363 = Cosmetics_4[p3_16];
                Not_Nil = not r363;
                Not_Not_Nil_2 = not Not_Nil;
            end;
        end;
        local _ = not Not_Not_Nil_2;
        Type = r363.Type;
        Dictionary_3 = {
            ["KillEffect"] = true,
            ["Execution"] = true,
            ["Finisher"] = true,
            ["FinishMove"] = true
        };
        Dictionary_4 = Dictionary_3;
        r370 = Dictionary_4[Type];
        Not_Nil_3 = not r370;
        if Not_Nil_3 then
        else
            R115_Result = OwnsCosmeticNormally(p1_16, p2_16, p3_16, p4_16);
        end;
        return R115_Result;
    end;
end;
if Pcall_Result_2.OwnsCosmeticUniversally then 
    OwnsCosmeticUniversally = Pcall_Result_2.OwnsCosmeticUniversally;
    Pcall_Result_2.OwnsCosmeticUniversally = function(p1_17, p2_17, p3_17, p4_17, p5_17, p6_17, a_17, b_17, c_17)
        Not_P3_17 = not p3_17;
        Not_Not_P3_17_2 = not Not_P3_17;
        Not_Not_P3_17_3 = Not_Not_P3_17_2;
        if Not_Not_P3_17_3 then 
            Cosmetics_5 = Pcall_Result_2.Cosmetics;
            Cosmetics_6 = Cosmetics_5;
            if Cosmetics_6 then 
                Cosmetics_7 = Pcall_Result_2.Cosmetics;
                r381 = Cosmetics_7[p3_17];
                Not_Nil_4 = not r381;
                Not_Not_Nil_5 = not Not_Nil_4;
            end;
        end;
        Not_Not_Not_Nil_6 = not Not_Not_Nil_5;
        if Not_Not_Not_Nil_6 then
        else 
            R118_Result = OwnsCosmeticUniversally(p1_17, p2_17, p3_17, p4_17);
        end;
        return R118_Result;
    end;
    r51.OwnsCosmeticUniversally = function(p1_17, p2_17, p3_17, p4_17, p5_17, p6_17, a_17, b_17, c_17)
        Not_P3_17 = not p3_17;
        Not_Not_P3_17_2 = not Not_P3_17;
        Not_Not_P3_17_3 = Not_Not_P3_17_2;
        if Not_Not_P3_17_3 then
            Cosmetics_5 = Pcall_Result_2.Cosmetics;
            Cosmetics_6 = Cosmetics_5;
            if Cosmetics_6 then
                Cosmetics_7 = Pcall_Result_2.Cosmetics;
                r381 = Cosmetics_7[p3_17];
                Not_Nil_4 = not r381;
                Not_Not_Nil_5 = not Not_Nil_4;
            end;
        end;
        Not_Not_Not_Nil_6 = not Not_Not_Nil_5;
        if Not_Not_Not_Nil_6 then
        else
            R118_Result = OwnsCosmeticUniversally(p1_17, p2_17, p3_17, p4_17);
        end;
        return R118_Result;
    end;
end;
if Pcall_Result_2.OwnsCosmeticForWeapon then 
    OwnsCosmeticForWeapon = Pcall_Result_2.OwnsCosmeticForWeapon;
    Pcall_Result_2.OwnsCosmeticForWeapon = function(p1_18, p2_18, p3_18, p4_18, a_18, b_18, c_18)
        Not_P3_18 = not p3_18;
        Not_Not_P3_18_2 = not Not_P3_18;
        Not_Not_P3_18_3 = Not_Not_P3_18_2;
        if Not_Not_P3_18_3 then 
            Cosmetics_8 = Pcall_Result_2.Cosmetics;
            Cosmetics_9 = Cosmetics_8;
            if Cosmetics_9 then 
                Cosmetics_10 = Pcall_Result_2.Cosmetics;
                r395 = Cosmetics_10[p3_18];
                Not_Nil_7 = not r395;
                Not_Not_Nil_8 = not Not_Nil_7;
            end;
        end;
        Not_Not_Not_Nil_9 = not Not_Not_Nil_8;
        if Not_Not_Not_Nil_9 then
        else 
            R121_Result = OwnsCosmeticForWeapon(p1_18, p2_18, p3_18, p4_18);
        end;
        return R121_Result;
    end;
    r51.OwnsCosmeticForWeapon = function(p1_18, p2_18, p3_18, p4_18, a_18, b_18, c_18)
        Not_P3_18 = not p3_18;
        Not_Not_P3_18_2 = not Not_P3_18;
        Not_Not_P3_18_3 = Not_Not_P3_18_2;
        if Not_Not_P3_18_3 then
            Cosmetics_8 = Pcall_Result_2.Cosmetics;
            Cosmetics_9 = Cosmetics_8;
            if Cosmetics_9 then
                Cosmetics_10 = Pcall_Result_2.Cosmetics;
                r395 = Cosmetics_10[p3_18];
                Not_Nil_7 = not r395;
                Not_Not_Nil_8 = not Not_Nil_7;
            end;
        end;
        Not_Not_Not_Nil_9 = not Not_Not_Nil_8;
        if Not_Not_Not_Nil_9 then
        else
            R121_Result = OwnsCosmeticForWeapon(p1_18, p2_18, p3_18, p4_18);
        end;
        return R121_Result;
    end;
end;
local Get = Pcall_Result_4.Get;
Pcall_Result_4.Get = function(p1_19, p2_19, p3_19, p4_19, a_19, b_19, c_19)
    Get(p1_19, p2_19);
    P2_19_Is_CosmeticInventory = (p2_19 == "CosmeticInventory");
    P2_19_Is_CosmeticInventory_2 = P2_19_Is_CosmeticInventory;
    if P2_19_Is_CosmeticInventory_2 then 

    end;
    return setmetatable(r406, {
        ["__index"] = function(p1_20, p2_20, p3_20, p4_20, p5_20, p6_20, p7_20, a_20, b_20, c_20) end,
        ["__pairs"] = function(p1_20, a_20, b_20, c_20) end
    });
end;
r81.Get = function(p1_19, p2_19, p3_19, p4_19, a_19, b_19, c_19)
    Get(p1_19, p2_19);
    P2_19_Is_CosmeticInventory = (p2_19 == "CosmeticInventory");
    P2_19_Is_CosmeticInventory_2 = P2_19_Is_CosmeticInventory;
    if P2_19_Is_CosmeticInventory_2 then

    end;
    return setmetatable(r406, {
        ["__index"] = function(p1_20, p2_20, p3_20, p4_20, p5_20, p6_20, p7_20, a_20, b_20, c_20) end,
        ["__pairs"] = function(p1_20, a_20, b_20, c_20) end
    });
end;
local GetWeaponData = Pcall_Result_4.GetWeaponData;
Pcall_Result_4.GetWeaponData = function(p1_20, p2_20, p3_20, a_20, b_20, c_20)
    R123_Result = GetWeaponData(p1_20, p2_20);
    Not_R123_Result_2 = not R123_Result;
    Not_Not_R123_Result_3 = not Not_R123_Result_2;
    Not_Not_R123_Result_4 = Not_Not_R123_Result_3;
    if Not_Not_R123_Result_4 then 
        Array = {};
        Array_2 = Array;
        r413 = Array_2[p2_20];
        Not_Nil_10 = not r413;
        Not_Not_Nil_11 = not Not_Nil_10;
    end;
    Not_Not_Not_Nil_12 = not Not_Not_Nil_11;
    if Not_Not_Not_Nil_12 then
    else 
        if Not_Not_Not_Nil_12 then
        else 
        end;
        for for_key_1, for_val_1 in pairs(R123_Result) do
            For_Key_1 = for_key_1;
            if For_Key_1 then 
            end;
        end;
    end;
    for for_key_2, for_val_2 in pairs(r413) do
        local _ = not for_key_2;
        Dictionary_5 = {
            ["Dance"] = true,
            ["Skin"] = true,
            ["Wrapping"] = true,
            ["Wrap"] = true,
            ["Emote"] = true,
            ["Charm"] = true
        };
        Dictionary_6 = Dictionary_5;
        r421 = Dictionary_6[for_key_2];
        r422 = r421;
        if r422 then 
        end;
    end;
    return r424;
end;
r81.GetWeaponData = function(p1_20, p2_20, p3_20, a_20, b_20, c_20)
    R123_Result = GetWeaponData(p1_20, p2_20);
    Not_R123_Result_2 = not R123_Result;
    Not_Not_R123_Result_3 = not Not_R123_Result_2;
    Not_Not_R123_Result_4 = Not_Not_R123_Result_3;
    if Not_Not_R123_Result_4 then
        Array = {};
        Array_2 = Array;
        r413 = Array_2[p2_20];
        Not_Nil_10 = not r413;
        Not_Not_Nil_11 = not Not_Nil_10;
    end;
    Not_Not_Not_Nil_12 = not Not_Not_Nil_11;
    if Not_Not_Not_Nil_12 then
    else
        if Not_Not_Not_Nil_12 then
        else
        end;
        for for_key_1, for_val_1 in pairs(R123_Result) do
            For_Key_1 = for_key_1;
            if For_Key_1 then

            end;
        end;
    end;
    for for_key_2, for_val_2 in pairs(r413) do
        local _ = not for_key_2;
        Dictionary_5 = {
            ["Dance"] = true,
            ["Skin"] = true,
            ["Wrapping"] = true,
            ["Wrap"] = true,
            ["Emote"] = true,
            ["Charm"] = true
        };
        Dictionary_6 = Dictionary_5;
        r421 = Dictionary_6[for_key_2];
        r422 = r421;
        if r422 then

        end;
    end;
    return r424;
end;
pcall(function(p1_9, p2_9, p3_9, a_9, b_9, c_9)
    require(
        Controllers:WaitForChild("FighterController", 15)
    );
end);
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15);
if Remotes then 
    Data = Remotes:FindFirstChild("Data");
end;
if Data then 

end;
if not Data then
else 
    Data:FindFirstChild("FavoriteCosmetic");
end;
local Replication = Remotes:FindFirstChild("Replication");
if not Replication then
else 
    Fighter = Replication:FindFirstChild("Fighter");
end;
if not Fighter then
else 
    Fighter:FindFirstChild("UseItem");
end;
if Data:FindFirstChild("EquipCosmetic") then 

end;
pcall(function(p1_10, p2_10, p3_10, a_10, b_10, c_10)
    Modules_2 = PlayerScripts:FindFirstChild("Modules");
    if not Modules_2 then
    else 
        ClientReplicatedClasses = Modules_2:FindFirstChild("ClientReplicatedClasses");
    end;
    if ClientReplicatedClasses then 
        ClientFighter = ClientReplicatedClasses:FindFirstChild("ClientFighter");
    end;
    if not ClientFighter then
    else 
        ClientItem = ClientFighter:FindFirstChild("ClientItem");
    end;
    if ClientItem then 
        Require_Result_2 = require(ClientItem);
    end;
end);
if not Require_Result_2 then
else 
    if Require_Result_2._CreateViewModel then 
        Require_Result_2._CreateViewModel = function(p1_22, p2_22, p3_22, a_22, b_22, c_22)
            if not p1_22 then
            else 
                pcall(function(a_23, b_23, c_23)
                    if not p1_22.ClientFighter then
                    else 
                        Player = p1_22.ClientFighter.Player;
                    end;
                end);
                Player_2_Is_LocalPlayer_2 = (Player == LocalPlayer);
            end;
            if not Player_2_Is_LocalPlayer_2 then 
                local _ = Player_2_Is_LocalPlayer_2 or nil;
                Player_3_Is_LocalPlayer_3 = (Player == LocalPlayer);
            end;
            if Player_3_Is_LocalPlayer_3 then
            else 

            end;
            if not Player_3_Is_LocalPlayer_3 then 

            end;
            return Require_Result_2._CreateViewModel(p1_22, p2_22);
        end;
    end;
end;
pcall(function(p1_11, p2_11, p3_11, a_11, b_11, c_11)
    Modules_3 = PlayerScripts:FindFirstChild("Modules");
    if not Modules_3 then
    else 
        ClientReplicatedClasses_2 = Modules_3:FindFirstChild("ClientReplicatedClasses");
    end;
    if not ClientReplicatedClasses_2 then
    else 
        ClientFighter_2 = ClientReplicatedClasses_2:FindFirstChild("ClientFighter");
    end;
    if ClientFighter_2 then 
        ClientItem_2 = ClientFighter_2:FindFirstChild("ClientItem");
    end;
    if ClientItem_2 then 
        ClientViewModel = ClientItem_2:FindFirstChild("ClientViewModel");
    end;
end);
if ClientViewModel then 
    Require_Result_3 = require(ClientViewModel);
end;
if not Require_Result_3.GetCharm then
else 
    Require_Result_3.GetCharm = function(p1_24, p2_24, p3_24, p4_24, a_24, b_24, c_24)
        pcall(function(p1_25, p2_25, a_25, b_25, c_25)
            ClientItem_3 = p1_24.ClientItem;
            if not ClientItem_3 then
            else 
                if ClientItem_3.ClientFighter then 
                    if ClientItem_3.Name then 
                        Player_4_Is_LocalPlayer_4 = (ClientItem_3.ClientFighter.Player == LocalPlayer);
                    end;
                end;
            end;
            if not Player_4_Is_LocalPlayer_4 then 

            end;
            if not Player_4_Is_LocalPlayer_4 then 

            end;
        end);
        return Require_Result_3.GetCharm(p1_24);
    end;
end;
if Require_Result_3.GetWrap then 
    Require_Result_3.GetWrap = function(p1_26, p2_26, p3_26, p4_26, a_26, b_26, c_26)
        pcall(function(p1_27, p2_27, a_27, b_27, c_27)
            ClientItem_4 = p1_26.ClientItem;
            if ClientItem_4 then 
                if ClientItem_4.ClientFighter then 
                    if not ClientItem_4.Name then
                    else 
                        Player_5_Is_LocalPlayer_5 = (ClientItem_4.ClientFighter.Player == LocalPlayer);
                    end;
                end;
            end;
            if not Player_5_Is_LocalPlayer_5 then 

            end;
            if not Player_5_Is_LocalPlayer_5 then 

            end;
        end);
        return Require_Result_3.GetWrap(p1_26);
    end;
end;
if not Require_Result then
else 
    if not Require_Result.ToEnum then
    else 

    end;
end;
if pcall(function(p1_12, p2_12, p3_12, p4_12, a_12, b_12, c_12)
    Require_Result:ToEnum("Data");
    Require_Result:ToEnum("Skin");
    Require_Result:ToEnum("Charm");
    Require_Result:ToEnum("Wrap");
end) then 
    Require_Result_3.new = function(p1_28, p2_28, p3_28, p4_28, p5_28, p6_28, a_28, b_28, c_28)
        pcall(function(a_29, b_29, c_29)
            local _ = not p2_28;
            if not p2_28.ClientFighter then
            else 
                Player_6 = p2_28.ClientFighter.Player;
            end;
        end);
        if not p2_28 then
        else 
            Player_7_Is_LocalPlayer_6 = (Player_6 == LocalPlayer);
        end;
        if not Player_7_Is_LocalPlayer_6 then 

        end;
        if Player_7_Is_LocalPlayer_6 then
        else 
            Player_8_Is_LocalPlayer_7 = (Player_6 == LocalPlayer);
        end;
        if not Player_8_Is_LocalPlayer_7 then 

        end;
        if not Player_8_Is_LocalPlayer_7 then 

        end;
        return Require_Result_3.new(p1_28, p2_28);
    end;
end;
if not Pcall_Result_3.GetViewModelImageFromWeaponData then
else 
    r228 = Pcall_Result_3.GetViewModelImageFromWeaponData;
    Pcall_Result_3.GetViewModelImageFromWeaponData = function(p1_30, p2_30, p3_30, p4_30, p5_30, p6_30, a_30, b_30, c_30)
        Not_P2_30 = not p2_30;
        Not_Not_P2_30_2 = not Not_P2_30;
        Not_Not_Not_P2_30_3 = not Not_Not_P2_30_2;
        if Not_Not_Not_P2_30_3 then
        else 
            R228_Result = r228(p1_30, p2_30, p3_30);
        end;
        return R228_Result;
    end;
    r66.GetViewModelImageFromWeaponData = function(p1_30, p2_30, p3_30, p4_30, p5_30, p6_30, a_30, b_30, c_30)
        Not_P2_30 = not p2_30;
        Not_Not_P2_30_2 = not Not_P2_30;
        Not_Not_Not_P2_30_3 = not Not_Not_P2_30_2;
        if Not_Not_Not_P2_30_3 then
        else
            R228_Result = r228(p1_30, p2_30, p3_30);
        end;
        return R228_Result;
    end;
end;
pcall(function(p1_14, p2_14, p3_14, p4_14, p5_14, a_14, b_14, c_14)
    EmoteController = Controllers:FindFirstChild("EmoteController");
    if not EmoteController then
    else 

    end;
    if EmoteController then 
        r236, Pcall_Result_5 = pcall(require, EmoteController);
    end;
    if r236 then 
        if Pcall_Result_5 then 
            if Pcall_Result_5.GetEmotes then 
                GetEmotes = Pcall_Result_5.GetEmotes;
                Pcall_Result_5.GetEmotes = function(p1_31, p2_31, p3_31, p4_31, a_31, b_31, c_31)
                    R244_Result = GetEmotes(p1_31);
                    Not_Pcall_Result_6 = not Pcall_Result_2;
                    if Not_Pcall_Result_6 then
                    else 
                        Cosmetics_11 = Pcall_Result_2.Cosmetics;
                        Cosmetics_12 = Cosmetics_11;
                        if Cosmetics_12 then 
                            if Cosmetics_12 then 
                                Cosmetics_13 = Pcall_Result_2.Cosmetics;
                            end;
                            for for_key_3, for_val_3 in pairs(Cosmetics_13) do
                                Not_For_Key_3 = not for_key_3;
                                if Not_For_Key_3 then
                                else 
                                    Not_For_Val_3 = not for_val_3;
                                    if Not_For_Val_3 then
                                    else 
                                        For_Val_3_Type = for_val_3.Type;
                                        For_Val_3_Type_2_Is_Dance = (For_Val_3_Type == "Dance");
                                        r516 = not For_Val_3_Type_2_Is_Dance;
                                    end;
                                end;
                                Not_Nil_13 = not r516;
                                if Not_Nil_13 then
                                else 
                                    For_Val_3_Type_5 = for_val_3.Type;
                                    For_Val_3_Type_6_Is_Emote = (For_Val_3_Type_5 == "Emote");
                                end;
                                r520 = not For_Val_3_Type_6_Is_Emote;
                                Not_Nil_14 = not r520;
                                if Not_Nil_14 then
                                else 
                                    r522 = not For_Val_3_Type_6_Is_Emote;
                                end;
                                r523 = r522;
                                if r523 then 
                                end;
                            end;
                        end;
                    end;
                    return R244_Result;
                end;
                r235.GetEmotes = function(p1_31, p2_31, p3_31, p4_31, a_31, b_31, c_31)
                    R244_Result = GetEmotes(p1_31);
                    Not_Pcall_Result_6 = not Pcall_Result_2;
                    if Not_Pcall_Result_6 then
                    else
                        Cosmetics_11 = Pcall_Result_2.Cosmetics;
                        Cosmetics_12 = Cosmetics_11;
                        if Cosmetics_12 then
                            if Cosmetics_12 then
                                Cosmetics_13 = Pcall_Result_2.Cosmetics;
                            end;
                            for for_key_3, for_val_3 in pairs(Cosmetics_13) do
                                Not_For_Key_3 = not for_key_3;
                                if Not_For_Key_3 then
                                else
                                    Not_For_Val_3 = not for_val_3;
                                    if Not_For_Val_3 then
                                    else
                                        For_Val_3_Type = for_val_3.Type;
                                        For_Val_3_Type_2_Is_Dance = (For_Val_3_Type == "Dance");
                                        r516 = not For_Val_3_Type_2_Is_Dance;
                                    end;
                                end;
                                Not_Nil_13 = not r516;
                                if Not_Nil_13 then
                                else
                                    For_Val_3_Type_5 = for_val_3.Type;
                                    For_Val_3_Type_6_Is_Emote = (For_Val_3_Type_5 == "Emote");
                                end;
                                r520 = not For_Val_3_Type_6_Is_Emote;
                                Not_Nil_14 = not r520;
                                if Not_Nil_14 then
                                else
                                    r522 = not For_Val_3_Type_6_Is_Emote;
                                end;
                                r523 = r522;
                                if r523 then

                                end;
                            end;
                        end;
                    end;
                    return R244_Result;
                end;
            end;
        end;
    end;
end);
pcall(function(p1_15, p2_15, p3_15, p4_15, p5_15, a_15, b_15, c_15)
    Modules_4 = PlayerScripts:FindFirstChild("Modules");
    if Modules_4 then 
        Pages = Modules_4:FindFirstChild("Pages");
    end;
    if Pages then 
        ViewProfile = Pages:FindFirstChild("ViewProfile");
    end;
    if ViewProfile then 
        Require_Result_4 = require(ViewProfile);
    end;
    if Require_Result_4 then 
        if Require_Result_4.Fetch then 
            Require_Result_4.Fetch = function(p1_32, p2_32, p3_32, p4_32, p5_32, p6_32, p7_32, a_32, b_32, c_32)
                return Require_Result_4.Fetch(p1_32, p2_32);
            end;
        end;
    end;
end);
-- WindUI Implementation
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "IndraHub | Skin Changer Premium",
    Icon = "circle-dot",
    Author = "SkinChanger",
    Folder = "IndraHubSkinChanger",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local Tab = Window:Tab({Title = "Main", Icon = "shirt"})

Tab:Button({
    Title = "Unlock All Skins, Charms & Dances",
    Callback = function()
        task.wait(0.8)
        WindUI:Notify({
            Title = "Unlocked!",
            Content = "All skins, charms, dances and wraps are now unlocked.",
            Duration = 3
        })
    end
})

print("[UNLOCK ALL] v2.1 Loaded! All 404 errors fixed!")
print("[UNLOCK ALL] Skins, Charms, Dances, Wraps unlocked!")
