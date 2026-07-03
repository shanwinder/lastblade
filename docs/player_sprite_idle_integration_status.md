# Player Idle Sprite Integration Status

สถานะการดำเนินงานตามไฟล์:

```text
docs/player_sprite_idle_integration_plan.md
```

วันที่บันทึก: 2026-07-03

---

## สรุปสถานะล่าสุด

ดำเนินการผ่านแล้ว:

```text
Phase 1: ตรวจ asset และมาตรฐานไฟล์
Phase 2: เปลี่ยน placeholder แบบเสี่ยงต่ำก่อน
```

หยุดงานไว้ก่อนเข้าสู่:

```text
Phase 3: ทำให้โค้ดรองรับ source sprite ที่หันซ้ายโดยตรงใน player.gd
```

เหตุผลที่หยุด: Phase 2 สามารถทำแบบปลอดภัยได้โดยยังไม่รื้อ `player.gd` แต่ Phase 3 ต้องแก้ logic หลักของ `set_facing_direction()` และควรทดสอบจริงใน Godot ว่า direction / attack hitbox / dash trail / lock-on / boss grab ไม่เพี้ยนก่อนขยับไป Phase 4

---

## Phase 1: ผลการตรวจ asset

ตรวจ path ตามแผน:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/
```

พบไฟล์ PNG จริงแล้ว ได้แก่:

```text
nameless_idle_000_0001.png
nameless_idle_000_0002.png
nameless_idle_000_0003.png
nameless_idle_000_0004.png
nameless_idle_000_0005.png
nameless_idle_000_0006.png
nameless_idle_6f_256x256.png
```

ข้อมูลจาก PNG header ที่ตรวจได้:

```text
Frame เดี่ยว: 256x256 px
Spritesheet รวม: 1536x256 px
จำนวน frame: 6 frame
```

หมายเหตุ:

```text
ผู้ใช้ยืนยันว่า idle sprite ชุดนี้เป็นท่าหันซ้าย
ยังไม่ได้ตรวจ baseline / transparency ด้วยสายตาใน Godot Editor จากฝั่ง assistant
```

---

## Phase 2: สิ่งที่ดำเนินการแล้ว

แก้ไฟล์:

```text
last-blade-trial/scenes/main/BossBrokenMaster.tscn
```

เปลี่ยน texture ของ `Player/Sprite2D` จาก placeholder:

```text
res://assets/sprites/player_silhouette.svg
```

เป็น idle frame แรก:

```text
res://assets/sprites/player/nameless_blade/frames/idle/nameless_idle_000_0001.png
```

ยังคงใช้ node เดิม:

```text
Player
└── Sprite2D
```

ยังไม่ได้เปลี่ยนเป็น:

```text
AnimatedSprite2D
```

---

## Direction workaround ที่ใช้ใน Phase 2

โค้ด `player.gd` ปัจจุบันยังมี logic:

```gdscript
sprite_2d.flip_h = facing_direction < 0
```

logic นี้เหมาะกับ source sprite ที่หันขวา แต่ idle sprite ชุดใหม่หันซ้าย

เพื่อหลีกเลี่ยงการรื้อ `player.gd` ทันที จึงใช้วิธีเสี่ยงต่ำใน scene:

```text
Player/Sprite2D.scale = Vector2(-0.5, 0.5)
```

ผลที่ต้องการ:

```text
facing_direction = 1  → ภาพควรแสดงว่าหันขวา
facing_direction = -1 → ภาพควรแสดงว่าหันซ้าย
```

วิธีนี้เป็น workaround ชั่วคราวสำหรับ Phase 2 เท่านั้น

---

## ไฟล์ที่แก้แล้ว

```text
last-blade-trial/scenes/main/BossBrokenMaster.tscn
last-blade-trial/assets/sprites/player/nameless_blade/source_notes.md
docs/player_sprite_idle_integration_status.md
```

---

## สิ่งที่ยังไม่ได้ทำ

ยังไม่ได้แก้ไฟล์:

```text
last-blade-trial/player.gd
```

ยังไม่ได้เพิ่ม:

```text
sprite_source_faces_left
AnimatedSprite2D
SpriteFrames idle
animation state machine
helper สำหรับดึง current frame texture จาก AnimatedSprite2D
```

---

## เหตุผลที่ยังไม่เข้า Phase 3 / Phase 4

Phase 3 ต้องแก้ระบบ direction ใน `player.gd` โดยตรง เช่น:

```gdscript
@export var sprite_source_faces_left: bool = true
```

และแก้ `set_facing_direction()` ให้รองรับ source sprite ที่หันซ้ายโดยตรง

แต่ก่อนทำควรทดสอบ Phase 2 ใน Godot จริงก่อนว่า:

```text
1. Player แสดงภาพ idle frame ใหม่จริง
2. ขนาด sprite พอดีกับจอและ gameplay หรือไม่
3. Negative scale ทำให้ direction ถูกต้องหรือไม่
4. AttackHitbox ยังอยู่หน้าตัวละครถูกฝั่งหรือไม่
5. Dash trail ยังไม่ error และหันทิศถูกหรือไม่
6. Boss Grab ยังจับตำแหน่งไม่เพี้ยนหรือไม่
```

ถ้าผ่านทั้งหมด ค่อยทำ Phase 3 เพื่อแก้ให้เป็นระบบถาวร และเลิกใช้ negative scale workaround

---

## วิธีทดสอบสำหรับผู้ใช้

หลัง `git pull` ให้เปิด Godot แล้ว Run scene:

```text
res://scenes/main/BossBrokenMaster.tscn
```

ทดสอบดังนี้:

```text
1. ดูว่า Player ไม่ใช่ silhouette แล้ว
2. กดเดินซ้าย/ขวา ดูว่าทิศหันถูกไหม
3. เปิด Lock-on แล้ว Dash ข้าม Boss ดูว่าหันกลับถูกไหม
4. โจมตีซ้าย/ขวา ดูว่า hitbox ฟันโดนด้านหน้าถูกฝั่งไหม
5. ให้ Boss Grab ดูว่าตำแหน่งจับยังโอเคไหม
6. ดูขนาดตัวละครบนจอมือถือว่าใหญ่/เล็กเกินไปไหม
```

---

## เกณฑ์ที่จะกลับมาทำ Phase 3

กลับมาทำ Phase 3 ได้เมื่อผู้ใช้ยืนยันว่า:

```text
1. ภาพ idle frame ใหม่แสดงในเกมแล้ว
2. ขนาด visual พอใช้หรือระบุ scale ที่ต้องการแล้ว
3. ทิศหันซ้าย/ขวาใน Phase 2 ไม่มีปัญหาใหญ่
4. ไม่มี error ใน console จาก texture / Sprite2D / dash trail
```

งานถัดไปคือ:

```text
Phase 3: เพิ่ม sprite_source_faces_left ใน player.gd
```

และหลัง Phase 3 ผ่านจริง ค่อยเข้าสู่:

```text
Phase 4: AnimatedSprite2D idle animation
```
