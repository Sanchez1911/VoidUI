--[[
    VoidUI Example — voidw0rld demo
    รันบน executor — ใช้ SHA ตรงๆ กัน cache เก่า
]]

-- HARD cache-bust: pin commit SHA (query ?v= อย่างเดียวไม่พอบน executor หลายตัว)
local VOIDUI_SHA = "a9cb85db6e9a6fff44f3ed5220800613e6d7d872"
local VOIDUI_URL = "https://raw.githubusercontent.com/Sanchez1911/VoidUI/" .. VOIDUI_SHA .. "/VoidUI.lua"

local function loadLib()
    local ok, body = pcall(function()
        return game:HttpGet(VOIDUI_URL)
    end)
    if ok and type(body) == "string" and #body > 500 then
        -- reject stale builds that still have bloomLabel-before-mk bug signature
        if body:find("Soft text bloom %(accent glow", 1, true) and not body:find("after mk", 1, true) then
            error("VoidUI stale cache — reopen with SHA URL")
        end
        local fn, err = loadstring(body, "@VoidUI")
        if fn then
            local ok2, lib = pcall(fn)
            if ok2 then return lib end
            error("VoidUI exec: " .. tostring(lib))
        end
        error("VoidUI compile: " .. tostring(err))
    end

    -- fallback: ไฟล์ local
    if readfile and isfile then
        for _, p in ipairs({ "GUI/VoidUI.lua", "VoidUI.lua" }) do
            if isfile(p) then
                local fn = loadstring(readfile(p), "@VoidUI")
                if fn then return fn() end
            end
        end
    end
    error("VoidUI load failed — check HttpGet / URL")
end

local VoidUI = loadLib()
print("[VoidUI] loaded", VoidUI.Version, "sha", VOIDUI_SHA)

local Window = VoidUI:CreateWindow({
    Title = "voidw0rld",
    Author = "discord.gg/voidw0rld",
    Icon = "rbxassetid://111627748770819", -- hub logo (Tap Sim / brand)
    Accent = Color3.fromRGB(162, 89, 255), -- void purple
    Size = UDim2.fromOffset(720, 560),
    Transparency = 0.16, -- glass
    Bloom = true, -- header/title accent bloom (not outer glow)
    Search = true, -- top search bar
    OpenButton = true, -- floating icon for mobile toggle
    CornerRadius = 26,
    ToggleKey = Enum.KeyCode.G,
    Folder = "VoidUI_Demo",
})

---------------------------------------------------------------------------
-- Sidebar: Home (2-col Training / Auto)
---------------------------------------------------------------------------
local Home = Window:Tab({ Title = "Home", Icon = "lucide:house", Selected = true })
local HomePage = Home:Page({ Title = "Home", Columns = 2 })

do
    local train = HomePage:Section({ Title = "TRAINING", Column = 1 })

    train:Dropdown({
        Title = "Stats",
        Desc = "Which stats to train",
        Values = { "Melee", "Defense", "Sword", "Gun", "Power" },
        Value = nil,
        Placeholder = "Select...",
        Flag = "stats",
        Multi = true,
        Callback = function(v)
            print("Stats:", typeof(v) == "table" and table.concat(v, ", ") or v)
        end,
    })

    train:Toggle({
        Title = "Auto Train",
        Desc = "Train selected stats automatically",
        Value = false,
        Flag = "autoTrain",
        Callback = function(v) print("Auto Train", v) end,
    })

    train:Toggle({
        Title = "Auto Upgrade",
        Desc = "Spend points when available",
        Value = false,
        Flag = "autoUpgrade",
        Callback = function(v) print("Auto Upgrade", v) end,
    })

    train:Toggle({
        Title = "Best Zone",
        Desc = "Warp to the best farming zone",
        Value = false,
        Flag = "bestZone",
        Callback = function(v) print("Best Zone", v) end,
    })

    train:Slider({
        Title = "Switch Delay",
        Desc = "Delay between zone / task switches",
        Min = 1,
        Max = 30,
        Value = 5,
        Suffix = "s",
        Flag = "switchDelay",
        Callback = function(v) print("Switch Delay", v) end,
    })
end

do
    local auto = HomePage:Section({ Title = "AUTO", Column = 2 })

    auto:Toggle({
        Title = "Auto Equip Best Sword",
        Desc = "Keep the strongest sword equipped",
        Value = true,
        Flag = "autoSword",
        Callback = function(v) print("Sword", v) end,
    })

    auto:Toggle({
        Title = "Auto Unlock Classes",
        Desc = "Buy class unlocks when rich enough",
        Value = true,
        Flag = "autoClass",
        Callback = function(v) print("Class", v) end,
    })

    auto:Toggle({
        Title = "Auto Claim",
        Desc = "Claim daily / offline rewards",
        Value = true,
        Flag = "autoClaim",
        Callback = function(v) print("Claim", v) end,
    })

    auto:Toggle({
        Title = "Auto Haki",
        Desc = "Keep haki enabled in combat",
        Value = true,
        Flag = "autoHaki",
        Callback = function(v) print("Haki", v) end,
    })
end

do
    local quest = HomePage:Section({ Title = "AUTO QUEST", Column = 2 })

    quest:Dropdown({
        Title = "Quest Type",
        Desc = "Main story or side quests",
        Values = { "Main", "Side", "Daily" },
        Value = "Main",
        Flag = "questType",
        Callback = function(v) print("Quest", v) end,
    })

    quest:Toggle({
        Title = "Auto Quest",
        Desc = "Accept and complete quests",
        Value = false,
        Flag = "autoQuest",
        Callback = function(v) print("Auto Quest", v) end,
    })
end

---------------------------------------------------------------------------
-- Sidebar: Farming (subtabs Farming / Skill / Priority Farm)
---------------------------------------------------------------------------
local Farm = Window:Tab({ Title = "Farming", Icon = "lucide:swords" })

local pageFarming = Farm:Page({ Title = "Farming" })
local pageSkill = Farm:Page({ Title = "Skill" })
local pagePriority = Farm:Page({ Title = "Priority Farm" })

do
    local sec = pageFarming:Section({ Title = "AUTOMATION" })

    sec:Toggle({
        Title = "Auto collect",
        Desc = "Harvest ripe fruit and plants.",
        Value = false,
        Flag = "autoCollect",
        Callback = function(v) print("collect", v) end,
    })

    sec:Toggle({
        Title = "Auto plant",
        Desc = "Plant best seed in empty tiles.",
        Value = false,
        Flag = "autoPlant",
        Callback = function(v) print("plant", v) end,
    })

    sec:Toggle({
        Title = "Auto sell",
        Desc = "Sell inventory when full.",
        Value = false,
        Flag = "autoSell",
        Callback = function(v) print("sell", v) end,
    })

    sec:Toggle({
        Title = "Auto water",
        Desc = "Water dry plants.",
        Value = false,
        Flag = "autoWater",
        Callback = function(v) print("water", v) end,
    })
end

do
    local status = pageFarming:Section({ Title = "STATUS" })
    local para = status:Paragraph({
        Title = "Live",
        Content = "Nothing removed | plants: 203/300 | garden full: false | waiting seed: none tier 0",
    })

    -- demo: update status text every few seconds
    task.spawn(function()
        while task.wait(5) do
            if not Window.ScreenGui or not Window.ScreenGui.Parent then break end
            para:Set(("plants: %d/300 | garden full: %s | tick: %d"):format(
                math.random(180, 300),
                tostring(math.random() > 0.7),
                os.clock() // 1
            ))
        end
    end)

    local limits = pageFarming:Section({ Title = "LIMITS" })
    limits:Dropdown({
        Title = "Plant count cap",
        Desc = "Stop planting above this count",
        Values = { "100", "200", "300", "400", "500" },
        Value = "300",
        Flag = "plantCap",
        Callback = function(v) print("cap", v) end,
    })
    limits:Input({
        Title = "Min sell value",
        Desc = "Skip fruit below this value",
        Value = "1000",
        Placeholder = "1000",
        Flag = "minSell",
        Callback = function(v) print("minSell", v) end,
    })
end

do
    local sk = pageSkill:Section({ Title = "SKILL" })
    sk:Toggle({
        Title = "Auto skill",
        Desc = "Spam combat skills on cooldown",
        Value = false,
        Flag = "autoSkill",
        Callback = function(v) print("skill", v) end,
    })
    sk:Slider({
        Title = "Skill delay",
        Desc = "Wait between skill casts",
        Min = 0.1,
        Max = 5,
        Value = 0.5,
        Decimals = 1,
        Suffix = "s",
        Flag = "skillDelay",
        Callback = function(v) print("skillDelay", v) end,
    })
    sk:Keybind({
        Title = "Panic key",
        Desc = "Disable all farm loops",
        Value = Enum.KeyCode.P,
        Flag = "panicKey",
        Callback = function(k) print("bind", k) end,
        Pressed = function()
            VoidUI:Notify({ Title = "Panic", Content = "All loops paused", Duration = 2 })
        end,
    })
end

do
    local pf = pagePriority:Section({ Title = "PRIORITY FARM" })
    local tasks = { "Auto Quest", "Auto Train", "Auto Boss", "Auto Farm", "Idle" }

    for i = 1, 4 do
        pf:Dropdown({
            Title = "Slot " .. i,
            Desc = "A task for this priority slot (Boss interrupts when a world boss is up)",
            Values = tasks,
            Value = tasks[((i - 1) % #tasks) + 1],
            Flag = "prioSlot" .. i,
            Callback = function(v) print("slot", i, v) end,
        })
    end

    pf:Slider({
        Title = "Swap Delay",
        Desc = "Seconds on each core task before rotating",
        Min = 1,
        Max = 60,
        Value = 5,
        Suffix = "s",
        Flag = "prioSwap",
        Callback = function(v) print("swap", v) end,
    })

    pf:Toggle({
        Title = "Enable Priority Farm",
        Desc = "Rotate the picked tasks; Boss interrupts when one is up",
        Value = false,
        Flag = "prioEnable",
        Callback = function(v)
            VoidUI:Notify({
                Title = "Priority Farm",
                Content = v and "Enabled" or "Disabled",
                Duration = 2,
            })
        end,
    })
end

---------------------------------------------------------------------------
-- More sidebar tabs (visual only)
---------------------------------------------------------------------------
local Misc = Window:Tab({ Title = "Misc", Icon = "lucide:dices" })
Misc:Section({ Title = "MISC" }):Paragraph({
    Title = "Ready",
    Content = "Icons = Lucide / Geist / Craft — ใช้แบบ lucide:swords หรือ geist:window",
})

Window:Tab({ Title = "Inventory", Icon = "lucide:backpack" })
    :Section({ Title = "BAG" })
    :Button({
        Title = "Notify test",
        Icon = "lucide:bell",
        Desc = "Fire a sample notification",
        Callback = function()
            VoidUI:Notify({ Title = "VoidUI", Content = "Library ready", Duration = 3 })
        end,
    })

Window:Tab({ Title = "Travel", Icon = "lucide:compass" })
    :Section({ Title = "TP" })
    :Dropdown({
        Title = "Island",
        Values = { "Starter", "Jungle", "Desert", "Frozen", "Magma" },
        Value = "Starter",
        Callback = function(v) print("tp", v) end,
    })

local Settings = Window:Tab({ Title = "Settings", Icon = "lucide:settings" })

do
    local look = Settings:Section({ Title = "APPEARANCE" })
    look:Slider({
        Title = "Transparency",
        Desc = "Glass amount on the main panel",
        Min = 0,
        Max = 45,
        Value = 16,
        Suffix = "%",
        Flag = "uiGlass",
        Callback = function(v)
            Window:SetTransparency(v / 100)
        end,
    })
    look:Paragraph({
        Title = "voidw0rld look",
        Content = "Purple accent · clean borders · header bloom. Search up top finds any option across tabs.",
    })
end

do
    local cfg = Settings:Section({ Title = "CONFIG" })
    cfg:Button({
        Title = "Save config",
        Icon = "lucide:save",
        Desc = "Write flags to demo.json",
        Callback = function()
            Window:SaveConfig("demo")
            VoidUI:Notify({ Title = "Config", Content = "Saved demo.json", Duration = 2 })
        end,
    })
    cfg:Button({
        Title = "Load config",
        Icon = "lucide:folder-open",
        Desc = "Restore the last saved flags",
        Callback = function()
            if Window:LoadConfig("demo") then
                VoidUI:Notify({ Title = "Config", Content = "Loaded", Duration = 2 })
            else
                VoidUI:Notify({ Title = "Config", Content = "No file", Duration = 2 })
            end
        end,
    })
    cfg:Button({
        Title = "Reset UI",
        Icon = "lucide:rotate-ccw",
        Desc = "Clear search & show hub",
        Callback = function()
            Window:Search("")
            Window:SetVisible(true)
            VoidUI:Notify({ Title = "UI", Content = "Reset", Duration = 1.5 })
        end,
    })
end

do
    local kb = Settings:Section({ Title = "KEYBINDS" })
    kb:Keybind({
        Title = "UI Toggle",
        Desc = "Show / hide the hub (or use the float icon)",
        Value = Enum.KeyCode.G,
        WindowToggle = true,
        Flag = "uiToggle",
    })
end

VoidUI:Notify({
    Title = "VoidUI " .. VoidUI.Version,
    Content = "Search · G = toggle · float icon on mobile",
    Duration = 4,
})

print("[VoidUI] demo loaded")
