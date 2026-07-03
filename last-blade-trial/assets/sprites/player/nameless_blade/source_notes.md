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

โค้ด `player.gd` ปัจจุบันยังใช้ logic เดิม:

```gdscript
sprite_2d.flip_h = facing_direction < 0
```

logic นี้สมมติว่า source sprite หันขวา แต่ idle sprite ชุดใหม่หันซ้าย ดังนั้นใน Phase 2 ใช้วิธีเสี่ยงต่ำก่อนคือกำหนด scale ของ `Player/Sprite2D` เป็น:

```text
Vector2(-0.5, 0.5)
```

เพื่อกลับภาพ source ให้เข้ากับ gameplay direction เดิมโดยยังไม่รื้อ `player.gd`

ข้อควรทำใน Phase ถัดไป:

```text
เพิ่ม sprite_source_faces_left ใน player.gd
แก้ set_facing_direction() ให้รองรับ source sprite ที่หันซ้ายโดยตรง
หลังจากนั้นค่อยเปลี่ยน scale.x กลับเป็นค่าบวกตามปกติ
```
