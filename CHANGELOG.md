# VoidUI Changelog

## 1.7.2 — Drag stick + hard Notify

### PriorityList drag
- Ghost ติดจุดที่กดค้างแล้ว (sticky offset) — แก้สูตรหักครึ่งสูงซ้ำ + หัก GuiInset ผิดตอน `IgnoreGuiInset`
- ตามเมาส์ด้วย `GetMouseLocation` ตอน MouseMovement
- แถวแน่นขึ้น · ไอคอนเปล่าไม่มี chip ม่วง

### Notify (ตึง / ไม่ AI)
- ไม่มี icon chip / accent wash / sparkle default
- เส้นม่วงซ้าย 2px + ข้อความแน่น · มุม 8px · stroke เทา
- Timer 1px ด้านล่าง · `Icon` ใส่เมื่อต้องการเท่านั้น

---

## 1.7.1 — PriorityList / Assets / Notify

### PriorityList (drag)
- ไม่ rebuild ทั้ง list ตอนลาก — ghost + LayoutOrder swap
- Assets ทุกจุด (`Icon` / `Image` / rbxassetid / lucide)
- Helper: `VoidUI.NormalizeAsset(x)`

### Notify (1.7.1)
- การ์ด glass + icon chip (แทนที่ด้วย hard toast ใน 1.7.2)

---

## 1.7.0

- Sidebar tab tooltips · editable slider · full-width input
- Dropdown images + search · PriorityList · Popup modal

## Cache note

Pin commit SHA ใน `HttpGet` เสมอ — executor cache แรง
