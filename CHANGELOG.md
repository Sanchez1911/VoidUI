# VoidUI Changelog

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
