# Asset Pipeline สำหรับภาพ AI

เอกสารนี้กำหนด workflow การนำภาพที่สร้างจาก AI มาใช้จริงใน Godot 4

## 1. AI Raw

ไฟล์ที่ AI สร้างออกมาให้เก็บใน `_ai_raw/` ก่อนเสมอ ห้ามนำไปใช้ตรงใน scene เพราะภาพ AI มักมีปัญหา frame ไม่ตรงช่อง, baseline ไม่เท่ากัน, ตัวละครเลื่อนตำแหน่ง, หรือ weapon เพี้ยนระหว่างเฟรม

## 2. Cleanup / Alignment

ก่อนใช้ในเกม ให้ทำขั้นตอนนี้ก่อน:

1. ตัดแต่ละ frame ออกจากภาพ AI
2. ลบพื้นหลังให้โปร่งใส
3. วางทุก frame ลง canvas มาตรฐาน
4. จัดเท้าให้อยู่ baseline เดียวกัน
5. ตั้งชื่อไฟล์เรียงเลข เช่น `nameless_idle_000.png`
6. ตรวจว่า silhouette อ่านง่ายบนจอมือถือ

## 3. Ready Sprites

ไฟล์ที่จัดเสร็จแล้วให้เก็บใน `sprites/` โดยแยกเป็น:

- `frames/` สำหรับ PNG frame แยก
- `sheets/` สำหรับ sprite sheet ที่จัด grid แล้ว
- `resources/` สำหรับไฟล์ Godot เช่น `.tres` SpriteFrames

## 4. ขนาดแนะนำ

```text
Player: 64x64 หรือ 96x64
Boss: 96x96 หรือ 128x128
VFX: 64x64, 96x96, 128x128 ตามขนาดเอฟเฟค
Background: แยกเป็น layer แบบ 16:9 เช่น 1152x648 หรือ 1280x720
```

## 5. Naming Convention

ใช้ชื่อไฟล์แบบนี้:

```text
nameless_idle_000.png
nameless_idle_001.png
broken_master_heavy_slash_000.png
parry_spark_000.png
```

หลีกเลี่ยง:

- เว้นวรรคในชื่อไฟล์
- ภาษาไทยในชื่อไฟล์ asset หลัก
- ตัวพิมพ์ใหญ่ปนตัวพิมพ์เล็กแบบไม่จำเป็น
- ชื่อไฟล์ยาวเกินไป

## 6. Import Setting สำหรับ Pixel Art ใน Godot

แนะนำให้ตั้งค่าประมาณนี้เมื่อ import PNG pixel art:

```text
Filter: Off / Nearest
Mipmaps: Off
Repeat: Disabled
Compression: Lossless สำหรับ sprite ขนาดเล็ก
```

## 7. ลำดับการนำเข้าเกม

เริ่มจาก asset ที่จำเป็นที่สุดก่อน:

1. Player idle
2. Boss idle
3. Player attack / dash / parry
4. Boss normal / heavy / delayed / quick slash
5. VFX สำคัญ เช่น parry spark และ warning
6. Arena background layer
