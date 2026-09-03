# VoidUI Changelog

## 1.9.0 — Stream log

Status ไม่ใช่ Paragraph เทาทิ้ง ๆ แล้ว

- **`Section:Log`** — แผง STREAM: เวลา + tag chip + แถบโทน 2px + บรรทัดล่าสุด + Clear
- `log:Push({ Tag, Text, Tone })` · `log:Clear()` · `log:Filter("Farm")` · `Set` ต่อท้ายแบบ Paragraph
- Tone: `ok` / `err` / `warn` / `mute` — infer จาก Tag ถ้าไม่ส่ง
- `Filters = { "All", "Farm", "Check", "Fail" }` หรือ `Filters = true`
- **Notify:** แถบโทน + chip `Tag` · ตัวอักษรเล็กลง · `W:Notify(...)`

---

## 1.8.5 — Dropdown search + count

- เปิดเมนูแล้วไม่แย่งโฟกัสไปช่องค้นหา — คลิกช่องเองถ้าจะพิมพ์
- Multi: แถบ `N selected` ค้างบนลิสต์ + ปุ่ม Clear

---

## 1.8.4 — Multi dropdown keeps scroll

- ติ๊กหลายตัวไม่ rebuild ลิสต์ → ไม่เด้งขึ้นบน
- ถ้ายัง rebuild (ค้นหา) จะจำ `CanvasPosition` ไว้
- ตัดแท่งม่วงซ้ายในเมนู — เหลือแค่ check

---

## 1.8.3 — Chrome match (Notify / lists / slider)

- **Notify:** การ์ดเดียวกับหน้าต่าง — ไม่มีแท่งม่วงซ้าย เหลือ timer 1px
- **PriorityList:** ไม่มี tick ม่วง · #N เทา · hover/ghost ใช้ BgHover
- **Slider value box:** ตัวเลขขาว ขอบเทา
- **Dropdown / search / Panel / filled buttons:** ตัดโทนม่วงตกแต่ง
- **Tab tooltip** เล็กลง

---

## 1.8.2 — Compact rows + chrome

- **Compact (default on):** ซ่อน `Desc` ทุกแถว — `CreateWindow({ Compact = false })` ถ้าอยากได้คำอธิบายคืน
- **Section ALL CAPS → Title Case** อัตโนมัติ (`TRAINING` → `Training`, คำสั้น `UI`/`PVE` คงเดิม)
- **Scrollbar** เทา 2px ทั้งหน้า / dropdown / popup / PriorityList
- **Popup** มุม/ขอบ/ปุ่มปิด ชุดเดียวกับหน้าหลัก
- **Sidebar** 52px · โลโก้/แท็บเล็กลง

---

## 1.8.1 — Density + subtab pills

- **Row icons off:** Toggle/Slider/Input/Button leading icons ไม่โผล่ในแถว — เหลือไอคอนที่หัว Section + รายการ Dropdown/PriorityList
- **ไม่มีเส้นแบ่งแถว:** ใช้ padding อย่างเดียว
- **ช่องว่างแน่นขึ้น:** section gap 10 · wrap 6
- **Subtabs:** pill เทา (ไม่มี underline ม่วง)

---

## 1.8.0 — Flat charcoal (anti-slop)

เทียบ Callisto / Lumen / Hydroxide แล้วตัดของที่ทำให้ดู AI:

- **Theme กลาง:** charcoal เทา ไม่ใช่ดำม่วงทุกชั้น
- **Accent เฉพาะ active:** toggle ON, slider fill, tab ที่เลือก — ไม่ใช่เส้น sidebar / search / tooltip / dropdown rail
- **Bloom ปิด default** + ไม่มีแท่งม่วงใต้หัวข้อ
- **มุมเท่ากัน:** window 12 · card/control 8 (ไม่ใช่ 26/17/14 ปน)
- **Sidebar:** วงกลมจางหลังไอคอน (แบบ Lumen) ไม่มี pill ซ้าย
- **Section title:** เทาธรรมดา ไม่ ALL CAPS glow
- **Slider:** รางบาง 4px + knob ขาว 12px
- **Open button:** วงกลมแบน ไม่มี glow ม่วง
- **Notify / search / dropdown menu:** ขอบเทาบาง ไม่มี wash

`CreateWindow({ Bloom = false, Transparency = 0.06, CornerRadius = 12 })`

---

## 1.7.15 — Dropdown above Popup

- Dropdown menus use ZIndex 920+ so they show on top of `W:Popup` (700)
- Dropdown label resolves `{Id, Name}` so saved ids display the pretty name (Tower not TowerOfGod)

## 1.7.14 — Popup host page

- `W:Popup`: sections build on a hidden `_popup_host` page (no extra Farm subtab, no steal from Auto Join)
- `Tab:Page({ Hidden = true })` stays off the subtab bar

## 1.7.13 — Panel (item / progress rows)

### Panel
- `Section:Panel({ Title, Desc, Icon, Values, EmptyText, RowHeight, Flag })`
- แต่ละแถว: ไอคอน + ชื่อ + ตัวเลขขวา + บรรทัดรอง
- `api:Set(values)` รีเฟรชได้ (ใช้โชว์ goal / ของในกระเป๋า)

```lua
S:Panel({
  Title = "Daily Goals",
  Desc = "Farm to Goal. Start again when below Restock.",
  Values = {
    { Name = "Fuel Cell", Id = "ExpeditionFuel", Image = "rbxassetid://…", Right = "320 / 1000", Sub = "Restock under 500" },
  },
})
```

---

## 1.7.12 — Flexible Section headers (sane default)

### Section header sizing
- **Default กลับมาพอดี:** Title **14** · Icon **15** (1.7.11's 16/20 ใหญ่เกิน · lucide เบลอ)
- ปรับได้ทั้งหน้าต่าง / ทีละ Section:

```lua
CreateWindow({
  SectionHeader = { TitleSize = 14, IconSize = 15, Scale = 1 },
  -- หรือ: SectionTitleSize, SectionIconSize, SectionHeaderScale
})
Page:Section({ Title = "...", Icon = "...", TitleSize = 15, IconSize = 18, HeaderScale = 1.1 })
```

- ยังเก็บ: `rbxassetid` สีเต็ม · lucide tint accent · จัดกลางแนวตั้ง
- `W.SectionHeader` อ่านค่าที่ใช้จริงได้

---

## 1.7.11 — Clearer Section headers

### Section
- หัวข้อ **16px** (เดิม 14) · สว่างขึ้น
- ไอคอนหัวข้อ **20px** · จัดกลางแนวตั้ง
- `rbxassetid` ไม่ถูก tint ม่วง (เห็นสีเกมจริง) · lucide ยัง accent
- เส้นใต้หัวข้อยาวขึ้นเล็กน้อย
- ⚠️ ใหญ่เกิน → ใช้ 1.7.12 + `SectionHeader` แทน

---

## 1.7.10 — Dropdown text size locked

### Fix
- แถวที่เลือกเคยใช้ `Fonts.Title` → ตัวหนังสือดูโตตามไอคอนเกม
- ตอนนี้ข้อความ **Body 13px คงที่** · เลือกแล้วเปลี่ยนแค่สี + ติ๊ก
- ไอคอนอยู่ในช่องคงที่ `28×28` + clip (ไม่ดันเลย์เอาต์)

---

## 1.7.9 — Bigger dropdown asset icons

### Dropdown menu
- แถวสูง **44** · ไอคอนเกม **28px** (เดิม ~18 ในแถว 34)
- จัดกลางแนวตั้ง · ข้อความ 13px
- เมนูสูงสุดกว้างขึ้นเล็กน้อย · preview บน chip 20px

---

## 1.7.8 — PriorityList light + ShowItemIcons

### PriorityList
- `ShowItemIcons = false` — ซ่อน icon ต่อแถว (เหลือ grip + #N + ชื่อ) ลดความรก
- Resize grip บางลง (เส้นม่วง 2px · ไม่มีแท่งหนา)
- แถว default ยัง 40 · AE ใช้ 36 ได้

### AE Auto Join (companion)
- Status สั้น 2 บรรทัด · ย้ายไปคอลัมน์ Modes
- Queue Next = Accent CTA · Cancel = Soft

---

## 1.7.7 — Button affordance always on

### Button
- ทุกปุ่มมีไอคอนขวาเสมอ — ใส่ `Icon`/`Image` เอง หรือ default **`lucide:chevron-right`**
- ไม่กลับไป default `play` (ทำให้ทุกปุ่มเหมือนกัน)

---

## 1.7.6 — Clean actions + PriorityList resize

### Button
- ไม่ default `lucide:play` — ใส่ `Icon` เอง (1.7.7 คืน affordance เป็น chevron)

### PriorityList
- Default `RowHeight = 40` (แน่นพอดี)
- `MaxVisible` / `Height` → scroll viewport
- `Resizable = true` → ลากแถบล่างปรับความสูง (`MinHeight` / `MaxHeight`)
- `api:SetHeight` / `api:GetHeight` / `OnResize`

### UX
- ยัง clean: icon ที่หัวข้อ Section + action ที่จำเป็น + game `rbxassetid` ใน Dropdown Values

---

## 1.7.5 — Balanced comfort scale

1.7.4 แน่น/จิ๋วเกิน — ดึงกลับกลาง ๆ ให้คลิกง่าย สมดุลกับข้อความ

### Controls
- Row pad 7/10 · title 14px · desc 12px
- Toggle **50×28** · knob 24
- Dropdown chip **136×30** · label 13px
- Input box **32px** · text 13
- Slider track 8 · knob 18 · value box 56×22
- Clean Button icon slot 34 · icon 18
- PriorityList row **48px** · gap 6 · label 14
- Section header 14 · page tab สูงขึ้นเล็กน้อย

ยังคงแนว clean: ไม่บังคับ icon ทุกแถว

---

## 1.7.4 — Dense controls (clean UX)

### Density
- Row pad แน่นขึ้น · title 13px · desc 11px (mute)
- Input box สูง 26px · TextSize 12
- Dropdown chip 120×26 (เดิม ~136×30)
- Slider value box 48×18 · TextSize 11
- Toggle right slot 42×24

### UX note
- Icon/Image ยังรองรับทุกแถว แต่แนะนำใส่เฉพาะ **Section / Tab / PriorityList values** — ไม่ spam ทุก Toggle

---

## 1.7.3 — Eager swap + denser clean

### PriorityList
- Swap ไวขึ้น: วัดจาก**กลาง ghost** + threshold ตามทิศ (ขึ้น ~78% / ลง ~22%) — ไม่ต้องลากพ้น midpoint
- แถวแน่นขึ้น · tick บาง · มุม 8 · สีแบนลง

### Density
- Section card มุม 12 · stroke จาง · row pad แน่นขึ้น

---

## 1.7.2 — Drag stick + hard Notify

### PriorityList drag
- Ghost sticky offset (แก้หักครึ่งสูงซ้ำ + GuiInset ผิด)
- ตามเมาส์ด้วย `GetMouseLocation`

### Notify
- Hard toast: ไม่มี chip/wash · เส้นม่วงซ้าย · timer 1px

---

## 1.7.1

- PriorityList ghost drag · assets ทุกจุด · `NormalizeAsset`

## 1.7.0

- Tooltips · editable slider · full-width input · dropdown images · Popup

## Cache note

Pin commit SHA ใน `HttpGet` เสมอ
