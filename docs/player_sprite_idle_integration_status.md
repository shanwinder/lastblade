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
Phase 3: ทำให้ source sprite หันซ้ายใช้งานกับ gameplay direction ได้โดยไม่พึ่ง negative scale
Phase 3.1: แก้ bug หันผิดฝั่งเสี้ยววินาทีหลัง lock-on dash
```

หยุดงานไว้ก่อนเข้าสู่:

```text
Phase 4: เปลี่ยนจาก Sprite2D เป็น AnimatedSprite2D
```

เหตุผลที่หยุด: Phase 4 ต้องเปลี่ยนระบบ visual node ของ Player จาก `Sprite2D` เป็น `AnimatedSprite2D` ซึ่งจะกระทบ `player.gd` หลายจุด เช่น `@onready var sprite_2d: Sprite2D = $Sprite2D`, dash trail ที่ใช้ `sprite_2d.texture`, และ feedback สีตัวละครที่ใช้ `sprite_2d.modulate` จึงควรทดสอบ Phase 3.1 ใน Godot ก่อน

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

## Phase 3: สิ่งที่ดำเนินการแล้ว

เพิ่มไฟล์ใหม่:

```text
last-blade-trial/player_sprite_orientation_manager.gd
```

เพิ่ม node ใหม่ใต้ Player ใน scene:

```text
Player
├── Sprite2D
├── CollisionShape2D
├── AttackHitbox
├── Hurtbox
└── PlayerSpriteOrientationManager
```

ค่าที่ใช้:

```text
orientation_enabled = true
sprite_source_faces_left = true
force_positive_scale_x = true
orientation_process_priority = 1000
```

เปลี่ยน `Player/Sprite2D.scale` จาก workaround เดิม:

```text
Vector2(-0.5, 0.5)
```

กลับเป็นค่าปกติ:

```text
Vector2(0.5, 0.5)
```

ตอนนี้การกลับซ้าย/ขวาของภาพไม่ได้พึ่ง negative scale แล้ว แต่ใช้ `flip_h` ผ่าน `PlayerSpriteOrientationManager` โดยอ่านค่า `facing_direction` จาก `player.gd`

หลักการ:

```text
Source sprite หันซ้าย
facing_direction = 1  → flip_h = true  เพื่อให้ภาพหันขวา
facing_direction = -1 → flip_h = false เพื่อให้ภาพหันซ้าย
```

---

## Phase 3.1: Bugfix หลังทดสอบ lock-on dash

ข้อสังเกตจากการทดสอบ:

```text
เมื่อ lock boss แล้วกดทิศถอยหลังค้างไว้ จากนั้นกด dash
หลัง dash จบ ภาพตัวละครหันผิดฝั่งประมาณเสี้ยววินาที
```

สาเหตุ:

```text
player.gd ยังเรียก update_facing_to_locked_target() หลัง dash จบ
ฟังก์ชันนี้เรียก set_facing_direction()
set_facing_direction() ยังตั้ง sprite_2d.flip_h ด้วย logic เก่า ที่สมมติว่า source sprite หันขวา
PlayerSpriteOrientationManager เดิมแก้ใน physics frame ถัดไป จึงมีโอกาสเห็นภาพผิดฝั่งสั้น ๆ
```

วิธีแก้:

```text
ให้ PlayerSpriteOrientationManager ทำงานทั้งใน _physics_process() และ _process()
ตั้ง process_priority = 1000 เพื่อให้ manager ทำงานหลัง player.gd
บันทึก orientation_process_priority = 1000 ใน scene แบบ explicit
```

ผลที่ต้องการ:

```text
หลัง dash จบ ถ้า player.gd ตั้ง flip_h ผิดจาก logic เก่า
manager จะรีบแก้ใน idle frame เดียวกันก่อน render หรือเร็วที่สุดเท่าที่ทำได้
ลด/กำจัดภาพหันผิดฝั่งชั่วคราว
```

---

## ทำไม Phase 3 ยังไม่แก้ player.gd โดยตรง

แผนเดิมเสนอให้เพิ่ม:

```gdscript
@export var sprite_source_faces_left: bool = true
```

ใน `player.gd` และแก้ `set_facing_direction()` โดยตรง

แต่รอบนี้เลือกใช้ manager แยกก่อน เพราะ:

```text
1. ลดความเสี่ยงจากการรื้อ player.gd ทั้งไฟล์
2. ไม่กระทบ combat logic, dash, hitbox, deflect, focus, hurt feedback
3. rollback ง่าย ถ้ามีปัญหาให้ลบ node PlayerSpriteOrientationManager ออกได้
4. เป็นสะพานก่อนเข้าสู่ AnimatedSprite2D ใน Phase 4
```

---

## ไฟล์ที่แก้แล้ว

```text
last-blade-trial/player_sprite_orientation_manager.gd
last-blade-trial/scenes/main/BossBrokenMaster.tscn
last-blade-trial/assets/sprites/player/nameless_blade/source_notes.md
docs/player_sprite_idle_integration_status.md
```

---

## สิ่งที่ยังไม่ได้ทำ

ยังไม่ได้เปลี่ยน:

```text
Player/Sprite2D → Player/AnimatedSprite2D
```

ยังไม่ได้เพิ่ม:

```text
SpriteFrames idle
animation state machine
helper สำหรับดึง current frame texture จาก AnimatedSprite2D
```

ยังไม่ได้แก้ `player.gd` ให้รองรับ visual node หลายชนิดแบบถาวร

---

## เหตุผลที่หยุดก่อน Phase 4

Phase 4 ต้องทำให้ Player ใช้ `AnimatedSprite2D` เพื่อเล่น idle animation 6 frame จริง แต่มีจุดเสี่ยงดังนี้:

```text
player.gd ยังอ้าง @onready var sprite_2d: Sprite2D = $Sprite2D
dash trail ยังใช้ sprite_2d.texture
feedback สี เช่น Hurt / Deflect / Focus Ready ใช้ sprite_2d.modulate
ถ้าเปลี่ยน node ทันที อาจทำให้ dash trail หรือ feedback พัง
```

ดังนั้นควรทดสอบ Phase 3.1 ก่อนว่า orientation manager ไม่ทำให้ทิศทางเพี้ยน

---

## วิธีทดสอบสำหรับผู้ใช้

หลัง `git pull` ให้เปิด Godot แล้ว Run scene:

```text
res://scenes/main/BossBrokenMaster.tscn
```

ทดสอบดังนี้:

```text
1. ดูว่า Player ยังแสดง idle frame ใหม่เหมือนเดิม
2. กดเดินซ้าย/ขวา ดูว่าทิศหันถูกไหม
3. เปิด Lock-on แล้ว Dash ข้าม Boss ดูว่าหันกลับถูกไหม
4. เปิด Lock-on กดถอยหลังค้าง แล้วกด Dash ดูว่ายังมีภาพหันผิดฝั่งเสี้ยววินาทีไหม
5. โจมตีซ้าย/ขวา ดูว่า hitbox ฟันโดนด้านหน้าถูกฝั่งไหม
6. ให้ Boss Grab ดูว่าตำแหน่งจับยังโอเคไหม
7. ดู console ว่ามีข้อความ PlayerSpriteOrientationManager ready หรือ error ใด ๆ หรือไม่
```

---

## เกณฑ์ที่จะกลับมาทำ Phase 4

กลับมาทำ Phase 4 ได้เมื่อผู้ใช้ยืนยันว่า:

```text
1. ภาพ idle frame ใหม่ยังแสดงถูก
2. หันซ้าย/ขวาถูกหลังเลิกใช้ negative scale
3. อาการหันผิดฝั่งเสี้ยววินาทีหลัง lock-on dash หายไป
4. AttackHitbox ยังถูกฝั่ง
5. Dash trail ยังไม่ error
6. Boss Grab ยังไม่เพี้ยน
```

งานถัดไปคือ:

```text
Phase 4: เปลี่ยนจาก Sprite2D เป็น AnimatedSprite2D
```
