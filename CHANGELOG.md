# VoidUI Changelog

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
