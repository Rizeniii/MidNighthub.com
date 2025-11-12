# MidNight UI Library - Basic Tutorial

## Installation
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rizeniii/MidNighthub.com/refs/heads/main/main.lua"))()


---

Create Window

local Window = Library:CreateWindow({
    Title = "My Script",
    Size = UDim2.new(0, 600, 0, 500)
})


---

Create Tab

local Tab = Window:AddTab("Home")


---

Elements

Toggle (On/Off Button)

Tab:AddToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end
})


---

Button

Tab:AddButton({
    Title = "Teleport Spawn",
    Callback = function()
        print("Button clicked!")
    end
})


---

Slider

Tab:AddSlider({
    Title = "Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        print("Speed:", value)
    end
})


---

Dropdown (Select Menu)

Tab:AddDropdown({
    Title = "Select Weapon",
    Options = {"Sword", "Pistol", "Rifle"},
    Default = "Sword",
    Callback = function(value)
        print("Selected:", value)
    end
})


---

Change Theme

Window:SetTheme("Purple")

Available Themes: Red, Purple, Green, Yellow, Blue, Cyan, Orange, Pink


---

Change Language

Window:SetLanguage("Portuguese")

Languages: English, Portuguese, Spanish


---

Notification

Window:Notify({
    Title = "Success!",
    Content = "Script loaded",
    Duration = 3
})


---

Complete Example

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rizeniii/MidNighthub.com/refs/heads/main/main.lua"))()

local Window = Library:CreateWindow({
    Title = "My Hub",
    Size = UDim2.new(0, 600, 0, 500)
})

local Tab = Window:AddTab("Main")

Tab:AddToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

Tab:AddButton({
    Title = "Teleport",
    Callback = function()
        print("Teleported!")
    end
})

Tab:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

Tab:AddDropdown({
    Title = "Select Map",
    Options = {"Map 1", "Map 2", "Map 3"},
    Default = "Map 1",
    Callback = function(value)
        print("Selected map:", value)
    end
})
