# Player Idle Sprite Integration Status

สถานะการดำเนินงานตามไฟล์:

```text
docs/player_sprite_idle_integration_plan.md
```

วันที่บันทึก: 2026-07-03

---

## สรุปสถานะล่าสุด

หยุดงานไว้ที่:

```text
Phase 1: ตรวจ asset และมาตรฐานไฟล์
```

ยังไม่เข้าสู่:

```text
Phase 2: เปลี่ยน placeholder แบบเสี่ยงต่ำก่อน
```

เหตุผลที่หยุด: ยังไม่พบไฟล์ `.png` idle frame ใน repo ที่ GitHub ตรวจได้จริง

---

## สิ่งที่ตรวจแล้ว

ตรวจ path ตามแผน:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/
```

ผลการค้นหาใน GitHub repo พบเฉพาะ:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/.gitkeep
```

ยังไม่พบไฟล์ลักษณะ:

```text
idle_00.png
idle_01.png
idle_02.png
*.png
```

---

## ข้อจำกัดที่พบ

Phase 1 กำหนดไว้ว่าต้องตรวจให้ผ่านก่อนว่า:

```text
มีไฟล์ .png จริงหรือไม่
ชื่อไฟล์เรียงลำดับหรือไม่
ทุก frame มีขนาดเท่ากันหรือไม่
baseline เท้าตรงกันทุก frame หรือไม่
พื้นหลังโปร่งใสจริงหรือไม่
ตัวละครหันซ้ายทุก frame หรือไม่
มี spritesheet รวมอยู่ด้วยหรือไม่
```

แต่ตอนนี้ repo มีแค่ `.gitkeep` ในโฟลเดอร์ idle จึงยังไม่สามารถตรวจรายการเหล่านี้ได้

ดังนั้นไม่ควรแก้ scene ไปใช้ texture ใหม่ เพราะยังไม่มี path ของไฟล์ภาพจริงที่ปลอดภัยให้ใช้งาน

---

## สิ่งที่ยังไม่ได้ทำ

ยังไม่ได้แก้ไฟล์เหล่านี้:

```text
last-blade-trial/scenes/main/BossBrokenMaster.tscn
last-blade-trial/player.gd
```

ยังไม่ได้เปลี่ยน texture ของ:

```text
Player/Sprite2D
```

ยังไม่ได้เพิ่ม:

```text
sprite_source_faces_left
AnimatedSprite2D
SpriteFrames idle
```

---

## ขั้นตอนที่ต้องทำต่อก่อนเริ่ม Phase 2

ให้เพิ่มไฟล์ idle `.png` เข้า repo จริงก่อน เช่น:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_00.png
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_01.png
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_02.png
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_03.png
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_04.png
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/idle_05.png
```

หรือถ้ามี spritesheet รวม ให้เก็บใน path ที่ชัดเจน เช่น:

```text
last-blade-trial/assets/sprites/player/nameless_blade/sheets/idle_left.png
```

จากนั้น commit และ push ขึ้น GitHub

---

## คำแนะนำชื่อไฟล์

แนะนำใช้ชื่อเรียงลำดับแบบ zero-padded เพื่อให้ง่ายต่อการสร้าง animation:

```text
idle_00.png
idle_01.png
idle_02.png
idle_03.png
idle_04.png
idle_05.png
```

ถ้าเป็นไฟล์หันซ้ายทั้งหมด ให้ระบุใน `source_notes.md` หรือชื่อโฟลเดอร์ เช่น:

```text
frames/idle/left/idle_00.png
```

แต่ถ้ายังต้องการคง path เดิมตามแผน ก็ใช้:

```text
frames/idle/idle_00.png
```

แล้วจดไว้ว่า source sprite หันซ้าย

---

## เกณฑ์ที่จะกลับมาดำเนินการต่อ

กลับมาทำ Phase 2 ได้เมื่อ:

```text
1. GitHub repo มีไฟล์ idle .png จริง
2. ระบุได้ว่า frame แรกที่ควรใช้แทน placeholder คือไฟล์ใด
3. ขนาด frame และ baseline ผ่านการตรวจเบื้องต้น
4. ยืนยันว่า source sprite หันซ้าย
```

เมื่อครบเงื่อนไขนี้ งานถัดไปคือ:

```text
Phase 2: เปลี่ยน placeholder แบบเสี่ยงต่ำก่อน
```

โดยจะยังใช้ `Sprite2D` เดิมก่อน ยังไม่เปลี่ยนเป็น `AnimatedSprite2D` ทันที
