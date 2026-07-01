# Last Blade Trial Asset Folder

โฟลเดอร์นี้ใช้เก็บ asset ทั้งหมดของเกม Last Blade Trial / ดาบไร้นาม

## หลักการจัดเก็บ

1. ไฟล์ AI ดิบ เก็บใน `_ai_raw/` เท่านั้น
2. ไฟล์ที่ตัดเฟรมและจัด baseline แล้ว เก็บใน `sprites/`, `ui/`, หรือ `backgrounds/`
3. ใช้ชื่อไฟล์ภาษาอังกฤษแบบ `snake_case`
4. หลีกเลี่ยงการใส่ไฟล์ดิบขนาดใหญ่มากในโฟลเดอร์ที่ Godot import จริง
5. ทุก asset ที่พร้อมใช้ควรมีขนาด frame ชัดเจน เช่น `64x64`, `96x96`, `128x128`

## โครงสร้างหลัก

```text
assets/
  _ai_raw/        # ภาพต้นฉบับจาก AI ยังไม่พร้อมใช้จริงในเกม
  sprites/        # sprite ที่ตัด จัดตำแหน่ง และพร้อมใช้ใน Godot
  ui/             # ปุ่ม touch control และ UI asset
  backgrounds/    # ฉากหลังและเลเยอร์ของ arena
  _work_in_progress/ # งานที่กำลังจัด alignment / cleanup
```

อ่านรายละเอียด workflow ได้ที่ `ASSET_PIPELINE.md`
