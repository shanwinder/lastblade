# The Nameless Blade Sprite Notes

ใช้บันทึกข้อมูลการจัด sprite ของ Player

## มาตรฐานแนะนำ

```text
Default frame size: 64x64 หรือ 96x64
Baseline: ให้เท้าอยู่ระดับเดียวกันทุก frame
Facing: ทำแยก left/right เฉพาะเมื่อจำเป็น
Primary node target: Player/AnimatedSprite2D
```

## Animation หลัก

- idle
- run
- attack_1
- dash
- parry
- hurt
- death
- focus_finisher

---

## Idle Asset ปัจจุบัน

เพิ่มไฟล์ idle sprite แล้วใน path:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/
```

ไฟล์ frame แยก:

```text
nameless_idle_000_0001.png
nameless_idle_000_0002.png
nameless_idle_000_0003.png
nameless_idle_000_0004.png
nameless_idle_000_0005.png
nameless_idle_000_0006.png
```

ไฟล์ spritesheet รวม:

```text
nameless_idle_6f_256x256.png
```

ข้อมูลที่ตรวจจาก PNG header:

```text
Frame เดี่ยว: 256x256 px
Spritesheet รวม: 1536x256 px
จำนวน frame: 6 frame
```

หมายเหตุสำคัญ:

```text
Source idle sprite ชุดนี้เป็นท่าหันซ้าย
Scene ปัจจุบันยังใช้ Sprite2D เดิมก่อน ยังไม่เปลี่ยนเป็น AnimatedSprite2D
ใน BossBrokenMaster.tscn ใช้ frame แรก nameless_idle_000_0001.png แทน player_silhouette.svg
```

## Direction / Flip Convention ปัจจุบัน

โค้ด `player.gd` ปัจจุบันยังใช้ logic เดิมภายใน `set_facing_direction()`:

```gdscript
sprite_2d.flip_h = facing_direction < 0
```

logic นี้สมมติว่า source sprite หันขวา แต่ idle sprite ชุดใหม่หันซ้าย

เพื่อไม่รื้อ `player.gd` ทั้งไฟล์ทันที จึงเพิ่มตัวช่วย:

```text
res://player_sprite_orientation_manager.gd
```

และเพิ่ม node ใน scene:

```text
Player
└── PlayerSpriteOrientationManager
```

ค่าที่ใช้ใน scene:

```text
sprite_source_faces_left = true
force_positive_scale_x = true
```

ดังนั้น `Player/Sprite2D.scale` กลับมาเป็นค่าบวกแล้ว:

```text
Vector2(0.5, 0.5)
```

การหันซ้าย/ขวาของภาพจะถูกแก้โดย `PlayerSpriteOrientationManager` ตาม `facing_direction` ของ `player.gd`:

```text
facing_direction = 1  → source หันซ้ายจึง flip_h = true เพื่อให้ภาพหันขวา
facing_direction = -1 → source หันซ้ายจึง flip_h = false เพื่อให้ภาพหันซ้าย
```

## ข้อควรทำใน Phase ถัดไป

Phase ถัดไปคือการเปลี่ยนจาก `Sprite2D` ไปเป็น `AnimatedSprite2D` เพื่อใช้ idle animation จริง 6 frame

ก่อนทำต้องแก้/ออกแบบจุดต่อไปนี้ให้ปลอดภัย:

```text
player.gd ยังอ้าง @onready var sprite_2d: Sprite2D = $Sprite2D
dash trail ยังใช้ sprite_2d.texture
feedback สี เช่น Deflect / Focus / Hurt ยัง modulate ผ่าน Sprite2D
ต้องมี helper สำหรับดึง current frame texture จาก AnimatedSprite2D
```
