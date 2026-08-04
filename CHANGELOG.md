# VoidUI Changelog

## 1.7.1 — PriorityList / Assets / Notify

### PriorityList (drag)
- ไม่ rebuild ทั้ง list ตอนลากแล้ว (อันนี้ทำให้กัง)
- Ghost ลอยตามเมาส์ + แถวต้นทางจาง + highlight ช่องปลายทาง
- สลับด้วย `LayoutOrder` + array swap ตามตำแหน่ง Y จริง
- แถวสวยขึ้น: grip, icon chip, accent bar, `#N` อัปเดตสด

### Assets ทุกจุด
รับได้ทั้ง `"rbxassetid://N"` / `number` / `"lucide:name"` ผ่าน `Icon` หรือ `Image`:

| ที่ | ฟิลด์ |
|---|---|
| Window / Tab / Popup | `Icon` |
| Section header | `Icon` / `Image` |
| Toggle / Dropdown / Keybind / Slider / Input / Paragraph | `Icon` / `Image` |
| Button (ไอคอนซ้ายหัวข้อ) | `LeadingIcon` / `LeadingImage` |
| Button (ไอคอนขวา / CTA) | `Icon` (เหมือนเดิม) |
| Dropdown / PriorityList values | `{ Name=, Icon= }` หรือ `{ Image= }` |
| Notify | `Icon` |

Helper: `VoidUI.NormalizeAsset(x)`

### Notify
- การ์ด glass + accent wash + icon chip
- Slide-in จากขวา + timer bar ด้านล่าง
- `VoidUI:Notify({ Title, Content, Icon, Duration, Accent })`

---

## 1.7.0

- Sidebar tab tooltips
- Slider แก้ค่าผ่าน TextBox
- Input เต็มความกว้าง (URL ยาวไม่พัง)
- Dropdown: สูงสูงสุด + scrollbar + search ในเมนู + ค่าเป็น `{ Name, Image/Icon }`
- PriorityList ตัวแรก (drag แบบ rebuild — แทนที่ใน 1.7.1)
- `Window:Popup` modal

## 1.6.x (สรุปสั้น)

- Glass + header bloom (ไม่ bloom กรอบนอก)
- Search expandable → dropdown ผลลัพธ์ + flash แถว
- Subtabs โผล่รอบแรก (defer SelectTab)
- Button style `Clean` (ทั้งแถวคลิกได้)
- OpenButton ลอย (มือถือ)
- Fix blank UI (`CanvasGroup` → `Frame`), bloomLabel-before-mk, HttpGet cache → **pin SHA**

---

## Cache note (สำคัญ)

Executor หลายตัว cache `HttpGet` แรง — โหลดด้วย **commit SHA** เสมอ:

```lua
local SHA = "xxxxxxxx" -- จาก github.com/Sanchez1911/VoidUI
loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Sanchez1911/VoidUI/" .. SHA .. "/VoidUI.lua"
))()
```

หรืออ่านไฟล์ local `GUI/VoidUI.lua` ตอนพัฒนา
