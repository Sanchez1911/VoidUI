# VoidUI API — เขียนสคริปต์ยังไง / ทำ UI อะไรได้บ้าง

Library: `GUI/VoidUI.lua` · Repo: https://github.com/Sanchez1911/VoidUI  
เวอร์ชันปัจจุบันดูที่ `VoidUI.Version` · รายละเอียดอัพเดท: [CHANGELOG.md](./CHANGELOG.md)

---

## โหลด

```lua
-- พัฒนา: local ก่อน
-- ปล่อย: pin SHA (กัน cache เก่า)
local SHA = "COMMIT_SHA"
local VoidUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Sanchez1911/VoidUI/" .. SHA .. "/VoidUI.lua"
))()
```

---

## โครงสร้าง

```
CreateWindow
 └─ Tab (sidebar)
     └─ Page (subtab / คอลัมน์)
         └─ Section (การ์ด)
             └─ Toggle / Slider / Dropdown / Button / Input / Keybind
                Paragraph / Log / Divider / PriorityList
Window: Popup · Search · SetVisible · Toggle · Notify · SaveConfig/LoadConfig
VoidUI: Notify
```

---

## Assets (ไอคอน / รูป Roblox)

ใช้ซ้ำได้ทุกที่ที่มี `Icon` หรือ `Image`:

```lua
Icon = "rbxassetid://123456789"   -- asset Roblox
Icon = 123456789                  -- ตัวเลขก็ได้ (normalize ให้)
Icon = "lucide:skull"             -- pack ในตัว
```

รายการ values (Dropdown / PriorityList):

```lua
Values = {
  "Plain string",
  { Name = "Boss", Icon = "lucide:skull" },
  { Name = "Unit", Image = "rbxassetid://111" },
}
```

`VoidUI.NormalizeAsset(x)` — แปลงให้เป็นสตริง asset ที่ `makeIcon` กินได้

---

## Window

```lua
local W = VoidUI:CreateWindow({
  Title = "voidw0rld",
  Author = "discord.gg/voidw0rld",
  Icon = "rbxassetid://...",      -- โลโก้ sidebar
  Accent = Color3.fromRGB(162, 89, 255),
  Size = UDim2.fromOffset(720, 560),
  Transparency = 0.16,            -- glass
  Bloom = true,                   -- แสงหัวข้อ (ไม่ใช่กรอบนอก)
  Search = true,                  -- ค้นหาแถวใน UI
  OpenButton = true,              -- ปุ่มลอยมือถือ
  CornerRadius = 26,
  ToggleKey = Enum.KeyCode.G,
  Folder = "MyHub",               -- โฟลเดอร์ config
  -- Section header sizing (defaults: Title 14 · Icon 15 · Scale 1)
  SectionHeader = { TitleSize = 14, IconSize = 15, Scale = 1 },
  -- หรือแบบแบน: SectionTitleSize / SectionIconSize / SectionHeaderScale
})
```

| Method | ทำอะไร |
|---|---|
| `W:Tab({ Title, Icon, Selected })` | แท็บซ้าย |
| `W:Popup({ Title, Icon, Size })` | โมดอลเต็มจอแบบหน้า settings |
| `W:SetVisible(bool)` / `W:Toggle()` | เปิด-ปิด |
| `W:SetTransparency(n)` | glass |
| `W:SaveConfig(name)` / `W:LoadConfig(name)` | flag-based |

---

## Tab → Page → Section

```lua
local Tab = W:Tab({ Title = "Home", Icon = "lucide:house", Selected = true })
local Page = Tab:Page({ Title = "Home", Columns = 2 })  -- 1 หรือ 2 คอลัมน์
local S = Page:Section({
  Title = "TRAINING", Column = 1, Icon = "lucide:dumbbell",
  -- optional per-section override (wins over Window.SectionHeader):
  -- TitleSize = 14, IconSize = 16, HeaderScale = 1.1,
})

-- สั้น: Tab:Section(...) สร้าง Page ให้อัตโนมัติ
```

หัวข้อ Section: **default 14 / 15** (ไม่บวม) · เกมอื่นอยากใหญ่ขึ้นตั้งที่ `CreateWindow` หรือทีละ Section · `rbxassetid` ไม่ถูก tint accent

---

## Controls (ใน Section)

### Toggle
```lua
S:Toggle({
  Title = "Auto Train", Desc = "...", Icon = "lucide:bot",
  Value = false, Flag = "autoTrain",
  Callback = function(v) end,
})
```

### Slider (ลาก + พิมพ์ค่าได้)
```lua
S:Slider({
  Title = "Delay", Icon = "lucide:timer",
  Min = 0, Max = 5, Value = 1, Decimals = 1, Suffix = "s",
  Flag = "delay", Callback = function(v) end,
})
```

### Dropdown
```lua
S:Dropdown({
  Title = "Unit", Desc = "...", Icon = "lucide:users",
  Values = { { Name = "Luffy", Icon = "lucide:swords" }, ... },
  Value = nil, Multi = false, Search = true,
  Flag = "unit", Callback = function(v) end,
})
-- api:Set / :Refresh / .Value
```

### Button
```lua
-- Clean row: ทั้งแถวคลิกได้ · ไอคอนขวาเสมอ (default chevron-right ถ้าไม่ใส่)
S:Button({
  Title = "Skip Wave",
  Icon = "lucide:skip-forward",  -- แนะนำใส่ต่อ action
  Callback = function() end,
})
-- Style = "Accent" | "Soft" | "Ghost" → ปุ่มเต็มแถว
```

### Input (เต็มความกว้าง)
```lua
S:Input({
  Title = "Webhook", Icon = "lucide:link",
  Placeholder = "https://...", Value = "", Flag = "wh",
  Callback = function(text) end,
})
```

### Keybind
```lua
S:Keybind({
  Title = "Panic", Icon = "lucide:keyboard",
  Value = Enum.KeyCode.P, Flag = "panic",
  Callback = function() end,
})
```

### Paragraph / Divider / Log
```lua
S:Paragraph({ Title = "Note", Icon = "lucide:info", Content = "..." })
S:Divider()

local log = S:Log({ Height = 100, Max = 24 })

log:Set({
  { Kind = "head", Icon = "lucide:activity", Label = "Live", Value = "in match" },
  { Kind = "stat", Icon = "lucide:coins", Label = "Cash", Value = "$1,247,990" },
  { Kind = "stat", Icon = "lucide:gem", Label = "Gems", Value = "180,695" },
  { Kind = "sep", Text = "Match" },
  { Kind = "line", Icon = "lucide:swords", Text = "Wave 10  ·  Yen 1,276  ·  HP 3" },
  { Kind = "state", Label = "Daily FlowerForest", State = "go" },   -- go done skip limit
  { Kind = "item", Icon = "lucide:sparkles", Label = "Secret", Value = "Megumi", Tone = "warn" },
})

log:Stat("Cash", "$1,250,000")
log:Push({ Tag = "INFO", Text = "Sold fruit" })
log:Push({ Tag = "WARN", Text = "Inventory full — selling" })
log:Push({ Tag = "LAUNCH", Text = "match started" })
```

`Set` = snapshot ของเกม (overview / pool / challenge)  
`Push` = เหตุการณ์ มี badge สี  
`Feed = false` ถ้าต้องการแค่บอร์ด ไม่เอา activity

---

### PriorityList — ลากเรียงลำดับ
```lua
local prio = S:PriorityList({
  Title = "Farm Priority",
  Desc = "Drag to reorder · pull bottom to resize",
  Icon = "lucide:list-ordered",
  Values = {
    { Name = "Boss", Icon = "lucide:skull" },
    { Name = "Quest", Image = "rbxassetid://123" },
  },
  RowHeight = 40,
  ShowItemIcons = true, -- false = เหลือ grip + #N + ชื่อ (clean)
  MaxVisible = 5,       -- scroll ถ้ายาวเกิน
  MinHeight = 120,
  MaxHeight = 360,
  Resizable = true,     -- ลากเส้นบางล่างปรับสูง
  Flag = "farmPrio",
  Callback = function(list) end,
  OnResize = function(h) end,
})
-- prio:Get() / prio:Set(newList, silent?) / prio:SetHeight(h) / prio:GetHeight()
```

UX: กดค้างแล้วลาก — ghost ตามเมาส์ · viewport เลื่อนได้ · เส้นม่วงบางล่าง = resize

---

## Popup (โมดอล)

```lua
local pop = W:Popup({
  Title = "Expedition Goals",
  Icon = "lucide:settings",
  Size = UDim2.fromOffset(400, 460),
})
local sec = pop:Section({ Title = "STOP WHEN", Icon = "lucide:flag" })
sec:Toggle({ Title = "Match All", Value = true })
sec:Button({ Title = "Close", Icon = "lucide:check", Callback = function() pop:Close() end })
```

`Popup:Section` ได้ controls ชุดเดียวกับ Section ปกติ  
สร้างบน hidden page (`Tab:Page({ Hidden = true })`) — ไม่โผล่เป็น subtab และไม่ไปปนหน้า Auto Join

---

## Notify

```lua
VoidUI:Notify({ Title=, Content=, Tag=, Tone=, Icon=, Duration= })
W:Notify({ Title=, Content=, Tag=, Tone= }) -- uses window accent
```

Tag/Tone optional — มีแล้วได้ chip + แถบโทนซ้าย (ไม่ใช่ม่วงตกแต่ง)

---

## Flags / Config

ใส่ `Flag = "name"` บน control → `W:SaveConfig("demo")` / `W:LoadConfig("demo")` เก็บใน `Folder`

---

## สไตล์ที่ทำได้ (เช็คลิสต์ตอนเขียนสคริปต์)

- [ ] Hub ม่วงแก้ว + โลโก้ asset
- [ ] Sidebar แท็บ + tooltip + OpenButton มือถือ
- [ ] Search กระโดดไปแถว + แฟลช
- [ ] 2-column Page
- [ ] Section / แถวมีไอคอน asset
- [ ] Dropdown มีรูปในรายการ
- [ ] PriorityList ลากเรียง
- [ ] Popup settings แยกหน้า
- [ ] Notify มี Tag/Tone + timer
- [ ] Status ใช้ `Section:Log` ไม่ใช่ Paragraph ทิ้ง ๆ
- [ ] Config save/load

ดูตัวอย่างครบ: `VoidUI.Example.lua`
