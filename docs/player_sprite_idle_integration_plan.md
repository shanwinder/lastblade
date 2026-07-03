# Player Idle Sprite Integration Plan

แผนการนำไฟล์ idle sprite ของ The Nameless Blade / ดาบไร้นาม มาใช้แทนภาพ placeholder ปัจจุบันในเกม Last Blade Trial

> สถานะเอกสาร: แผนปฏิบัติงานก่อนเริ่มแก้โค้ดจริง  
> เป้าหมาย: เปลี่ยน Player จากภาพ `player_silhouette.svg` ไปสู่ sprite idle จริง โดยไม่ทำให้ระบบ combat, hitbox, dash, lock-on, deflect และ mobile readability พัง

---

## 1. เป้าหมายหลัก

นำไฟล์ `.png` idle ของ Player ที่จัดเก็บไว้ในโฟลเดอร์:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/
```

มาใช้แทนภาพต้นแบบปัจจุบันของ Player ที่ยังเป็น silhouette placeholder

```text
res://assets/sprites/player_silhouette.svg
```

เป้าหมายไม่ใช่แค่เปลี่ยนภาพ แต่ต้องวางรากฐานให้รองรับ animation จริงในอนาคต เช่น:

```text
idle
run
attack_1
dash
deflect / parry
hurt
death
focus_finisher
```

---

## 2. สถานะโค้ดปัจจุบันที่เกี่ยวข้อง

### 2.1 Scene หลักที่ใช้ Player

Scene หลักของเกมอยู่ที่:

```text
last-blade-trial/scenes/main/BossBrokenMaster.tscn
```

ใน scene นี้ Player ยังเป็น node:

```text
Player: CharacterBody2D
└── Sprite2D
```

โดย `Sprite2D` ยังใช้ texture placeholder:

```text
res://assets/sprites/player_silhouette.svg
```

### 2.2 Script หลักของ Player

ไฟล์หลักของ Player คือ:

```text
last-blade-trial/player.gd
```

ตอนนี้โค้ดผูกกับ node ชื่อ `Sprite2D` โดยตรง:

```gdscript
# อ้างอิงภาพตัวละครปัจจุบัน
@onready var sprite_2d: Sprite2D = $Sprite2D
```

ดังนั้น ถ้าเปลี่ยน node เป็น `AnimatedSprite2D` ทันทีโดยไม่แก้โค้ด จะมีความเสี่ยงสูงที่ระบบบางส่วนพัง

---

## 3. ฟีเจอร์ Godot ที่ช่วยเรื่องหันซ้าย / ขวา

Godot มี property ที่ใช้กลับภาพซ้าย-ขวาได้โดยตรง:

```gdscript
# Sprite2D
sprite_2d.flip_h = true
```

และถ้าใช้ `AnimatedSprite2D` ก็มีแนวคิดเดียวกัน:

```gdscript
# AnimatedSprite2D
animated_sprite_2d.flip_h = true
```

### 3.1 ข้อดีของ `flip_h`

ใช้ asset ที่มีแค่ฝั่งเดียวได้ เช่น มีเฉพาะภาพหันซ้าย แล้วให้ Godot mirror เพื่อแสดงเป็นหันขวา

ข้อดี:

```text
ลดจำนวน asset ที่ต้องวาด
ทดสอบในเกมได้เร็ว
เหมาะกับช่วง prototype / vertical slice
ลดภาระจัดไฟล์ left/right แยกในช่วงแรก
```

### 3.2 ข้อจำกัดของ `flip_h`

`flip_h` พลิกเฉพาะภาพ ไม่ได้พลิกทุกอย่างใน gameplay ให้อัตโนมัติ

สิ่งที่ต้องจัดการเอง:

```text
AttackHitbox position
ทิศทางดาบ
ทิศทาง dash
facing_direction
VFX ดาบ
ตำแหน่ง lock-on facing
```

โชคดีที่โค้ดปัจจุบันมีระบบย้าย `AttackHitbox` ตามทิศทางอยู่แล้ว:

```gdscript
# ตั้งทิศหันหน้าและย้าย hitbox ดาบให้ตรงกับทิศทาง
func set_facing_direction(new_direction: int) -> void:
	if new_direction == 0:
		return

	facing_direction = new_direction
	if is_instance_valid(sprite_2d):
		sprite_2d.flip_h = facing_direction < 0
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)
```

แต่โค้ดนี้สมมติว่า “ภาพต้นทางหันขวา” เพราะจะ `flip_h` เมื่อ `facing_direction < 0`

---

## 4. ปัญหาสำคัญ: idle asset หันซ้ายเท่านั้น

ผู้ใช้ระบุว่า asset idle ที่มีอยู่ตอนนี้เป็นท่าหันซ้ายเท่านั้น

ดังนั้นมีทางเลือก 2 แบบ:

### ทางเลือก A: ใช้ภาพหันซ้ายเป็น source จริง แล้วกลับ logic flip

ถ้า asset ต้นทางหันซ้าย:

```text
facing_direction = -1  → ไม่ flip
facing_direction = 1   → flip_h = true
```

แนวคิดโค้ดในอนาคตควรเป็น:

```gdscript
# หมายเหตุ: โค้ดนี้เป็นตัวอย่างแนวคิด ยังไม่ใช่ patch ที่นำไปใช้ทันที
# ถ้า source sprite หันซ้าย ให้ flip เมื่อ gameplay ต้องการหันขวา
sprite.flip_h = facing_direction > 0
```

ข้อดี:

```text
ใช้ asset ที่มีอยู่ได้ทันที
ไม่ต้องสร้างไฟล์ right-facing เพิ่ม
เหมาะกับ idle / run / hurt ช่วงแรก
```

ข้อเสีย:

```text
ถ้า sprite มีรายละเอียดที่ไม่ควร mirror เช่น มือจับดาบ ฝักดาบ ผ้าคลุม หรือแผลเฉพาะด้าน ภาพจะกลับด้านทั้งหมด
สำหรับ attack / finisher อาจดูผิดมือหรือผิดทิศ
```

### ทางเลือก B: สร้าง sprite ฝั่งขวาแยกในอนาคต

ใช้ไฟล์ left-facing เป็น source แล้วค่อยทำ right-facing แยกสำหรับ animation สำคัญ

เหมาะกับ animation ที่ต้องการความถูกต้องสูง:

```text
attack_1
focus_finisher
hurt หนัก
death
boss grab reaction
```

ข้อดี:

```text
ภาพถูกต้องที่สุด
ควบคุมมือจับดาบและ silhouette ได้ดีกว่า
ไม่เกิดปัญหา weapon hand ผิดด้าน
```

ข้อเสีย:

```text
ใช้เวลา asset production มากขึ้น
ต้องดูแล consistency ของ left/right เพิ่ม
```

ข้อเสนอแนะนำ:

```text
ระยะสั้น: ใช้ flip_h จากภาพหันซ้ายก่อน
ระยะยาว: ทำ animation สำคัญแยก left/right เฉพาะจุดที่ mirror แล้วดูผิด
```

---

## 5. แผนการดำเนินงานแบบละเอียด

## Phase 1: ตรวจ asset และมาตรฐานไฟล์

### 1.1 ตรวจว่า asset อยู่ใน repo จริงหรือยัง

ตรวจโฟลเดอร์:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/idle/
```

สิ่งที่ต้องตรวจ:

```text
มีไฟล์ .png จริงหรือไม่
ชื่อไฟล์เรียงลำดับหรือไม่ เช่น idle_00.png, idle_01.png
ทุก frame มีขนาดเท่ากันหรือไม่
baseline เท้าตรงกันทุก frame หรือไม่
พื้นหลังโปร่งใสจริงหรือไม่
ตัวละครหันซ้ายทุก frame หรือไม่
มี spritesheet รวมอยู่ด้วยหรือไม่
```

### 1.2 มาตรฐานแนะนำของ frame

อ้างอิงจาก `source_notes.md` ใน repo:

```text
Default frame size: 64x64 หรือ 96x64
Baseline: เท้าอยู่ระดับเดียวกันทุก frame
Primary node target: Player/AnimatedSprite2D
```

สำหรับ mobile readability แนะนำ:

```text
ถ้าตัวละครอ่านยากที่ 64x64 ให้ใช้ 96x64 หรือ 96x96
ห้ามให้ดาบบางเกินไป
ควรมี silhouette ชัดเมื่อดูบนจอมือถือ
ควรรักษาจุด pivot / baseline ให้ตรงกันทุก frame
```

### 1.3 เกณฑ์ผ่าน Phase 1

```text
ไฟล์ idle frame แยกเปิดดูได้ใน Godot
ทุก frame มีขนาดเท่ากัน
ไม่มีพื้นหลังเขียวหรือดำติดมาใน texture จริง ถ้าต้องการ transparency
เท้าไม่เด้งขึ้นลงผิดธรรมชาติ
รู้แน่ชัดว่า source sprite หันซ้าย
```

---

## Phase 2: เปลี่ยน placeholder แบบเสี่ยงต่ำก่อน

เป้าหมายของ phase นี้คือเปลี่ยนจาก silhouette เป็น idle sprite จริงโดยยังไม่รื้อระบบ animation

### 2.1 วิธีทำ

เลือก idle frame ที่ชัดที่สุด 1 frame เช่น:

```text
idle_00.png
```

แล้วนำมาแทน texture ของ:

```text
Player/Sprite2D
```

ใน scene:

```text
last-blade-trial/scenes/main/BossBrokenMaster.tscn
```

### 2.2 ต้องปรับอะไรบ้าง

ต้องตรวจและอาจปรับ:

```text
Sprite2D.scale
CollisionShape2D size
Hurtbox size
AttackHitbox position
AttackHitbox shape
ตำแหน่ง Player เริ่มต้น
```

### 2.3 จุดสำคัญเรื่องทิศ

เพราะ asset หันซ้าย แต่โค้ดปัจจุบันเหมือนสมมติว่า source หันขวา จึงต้องเพิ่มตัวแปรในอนาคต เช่น:

```gdscript
# ตัวอย่างแนวคิด ยังไม่ใช่ patch ทันที
# true = ภาพต้นทางหันซ้าย
@export var sprite_source_faces_left: bool = true
```

แล้วให้ `set_facing_direction()` ใช้ logic กลับด้านตาม source orientation

### 2.4 เกณฑ์ผ่าน Phase 2

```text
Player แสดงเป็นตัวละครจริงแทน silhouette
Player ยืน idle frame เดียวได้
เดินซ้าย/ขวาแล้วหันถูกทิศ
AttackHitbox ยังอยู่หน้าตัวละครถูกฝั่ง
Dash ข้าม boss แล้วหันกลับถูกเมื่อ lock-on เปิด
ไม่เกิด error จาก Sprite2D
```

---

## Phase 3: ทำให้โค้ดรองรับ source sprite ที่หันซ้าย

ตอนนี้ฟังก์ชันสำคัญคือ:

```gdscript
# ปัจจุบัน source ถูกตีความเหมือนหันขวา
sprite_2d.flip_h = facing_direction < 0
```

ควรแก้เป็นระบบที่รู้ว่า source sprite หันทางไหน

### 3.1 แนวคิดที่ควรใช้

เพิ่ม export variable:

```gdscript
# ภาพต้นทางของ Player หันซ้ายหรือไม่
@export var sprite_source_faces_left: bool = true
```

แล้วแก้ logic ใน `set_facing_direction()` ให้เป็น:

```gdscript
# ตัวอย่างแนวคิดพร้อมคอมเมนต์ไทย
# ถ้าภาพต้นทางหันซ้าย: ต้อง flip เมื่อ gameplay ต้องการหันขวา
# ถ้าภาพต้นทางหันขวา: ต้อง flip เมื่อ gameplay ต้องการหันซ้าย
if sprite_source_faces_left:
	sprite_2d.flip_h = facing_direction > 0
else:
	sprite_2d.flip_h = facing_direction < 0
```

### 3.2 ทำไมต้องทำแบบนี้

เพราะจะทำให้ asset pipeline ยืดหยุ่นขึ้น:

```text
ถ้า sprite ชุดหนึ่ง source หันซ้าย ใช้ได้
ถ้า sprite ชุดใหม่ source หันขวา ก็ยังใช้ได้
ไม่ต้องไล่แก้ logic หลายจุด
```

### 3.3 จุดที่ต้องตรวจหลังแก้

```text
set_facing_direction()
update_facing_to_locked_target()
AttackHitbox.position.x
Dash direction
BossGrab hold position
Focus VFX direction
```

---

## Phase 4: เปลี่ยนจาก Sprite2D เป็น AnimatedSprite2D

Phase นี้คือการทำ idle animation จริง

### 4.1 โครงสร้าง node ที่ต้องการ

จากเดิม:

```text
Player
└── Sprite2D
```

เปลี่ยนเป็น:

```text
Player
└── AnimatedSprite2D
```

หรือระยะเปลี่ยนผ่านอาจใช้ทั้งคู่ชั่วคราว:

```text
Player
├── Sprite2D               ใช้ระบบเดิมชั่วคราว
└── AnimatedSprite2D        ทดสอบ idle animation
```

แต่ใน production ควรเหลือหลักเพียงตัวเดียวเพื่อไม่ซ้อนภาพ

### 4.2 สร้าง SpriteFrames

ใน Godot สร้าง `SpriteFrames` resource แล้วเพิ่ม animation:

```text
animation name: idle
loop: true
fps: 6 ถึง 8 สำหรับ idle
frames: idle_00.png ถึง idle_05.png หรือจำนวนที่มีจริง
```

### 4.3 ปรับ player.gd ให้รองรับ AnimatedSprite2D

ปัญหาคือโค้ดปัจจุบันประกาศเป็น `Sprite2D`:

```gdscript
@onready var sprite_2d: Sprite2D = $Sprite2D
```

ถ้าเปลี่ยนเป็น `AnimatedSprite2D` ต้องแก้ให้ตรงชนิด หรือทำ adapter function สำหรับ visual node

แนวทางปลอดภัย:

```gdscript
# ตัวอย่างแนวคิด ยังไม่ใช่ patch ทันที
# ใช้ CanvasItem เพราะ Sprite2D และ AnimatedSprite2D ต่างก็สืบทอดจาก CanvasItem
@onready var player_visual: CanvasItem = $AnimatedSprite2D
```

แต่ถ้าต้องใช้ property เฉพาะ เช่น `flip_h`, `modulate`, `texture`, ต้องจัดการแยกตามชนิด node

### 4.4 จุดเสี่ยง: Dash Trail

โค้ด dash trail ปัจจุบันดึง texture จาก `Sprite2D.texture`

```gdscript
# โค้ดปัจจุบันใช้แนวคิด texture ตรง ๆ ของ Sprite2D
var ghost := Sprite2D.new()
ghost.texture = sprite_2d.texture
```

ถ้าเปลี่ยนเป็น `AnimatedSprite2D`, texture ปัจจุบันต้องดึงจาก `SpriteFrames` แทน

แนวคิดในอนาคต:

```gdscript
# ตัวอย่างแนวคิดพร้อมคอมเมนต์ไทย
# ดึง texture frame ปัจจุบันจาก AnimatedSprite2D เพื่อทำ dash ghost
var current_texture: Texture2D = animated_sprite.sprite_frames.get_frame_texture(
	animated_sprite.animation,
	animated_sprite.frame
)
```

### 4.5 เกณฑ์ผ่าน Phase 4

```text
Idle animation เล่นวนได้
Player หันซ้าย/ขวาถูก
Dash trail ยังแสดง texture ปัจจุบันถูกต้อง
Hitbox ไม่เพี้ยน
Hurtbox ยังรับดาเมจถูก
ไม่มีภาพซ้อนจาก Sprite2D เก่า
```

---

## Phase 5: เพิ่ม Animation State พื้นฐาน

หลังจาก idle ใช้งานได้ ควรต่อยอดเป็นระบบ animation state ใน `player.gd`

### 5.1 Animation ขั้นต่ำที่ควรมี

```text
idle
run
attack_1
dash
hurt
posture_broken
death
focus_ready / focus_finisher ในอนาคต
```

### 5.2 เงื่อนไขเปลี่ยน animation

```text
ถ้า is_dead → death
ถ้า is_posture_broken → posture_broken
ถ้า is_knocked_back → hurt หรือ thrown
ถ้า is_dashing → dash
ถ้า is_attacking → attack_1
ถ้า direction != 0 → run
ถ้าไม่มี action → idle
```

### 5.3 ต้องระวัง animation กับ gameplay frame

Attack animation ไม่ควรเปิด hitbox ทั้ง animation แต่ต้องเปิดเฉพาะช่วง active time เดิม

ดังนั้นระบบที่มีอยู่ยังควรรักษาไว้:

```text
attack_active_time
attack_recovery_time
AttackHitbox/CollisionShape2D disabled true/false
```

animation เป็น visual เท่านั้นในระยะแรก อย่าให้ animation timeline คุมดาเมจจนกว่า logic เสถียร

---

## Phase 6: จัดการ right-facing asset ในอนาคต

แม้ Godot ใช้ `flip_h` ได้ แต่สำหรับเกมดาบบาง animation อาจไม่ควร mirror ตรง ๆ

### 6.1 Animation ที่ใช้ mirror ได้ก่อน

```text
idle
run
hurt เบา
posture_broken
```

### 6.2 Animation ที่ควรพิจารณาทำ left/right แยก

```text
attack_1
focus_finisher
boss grab reaction
death ถ้ามี pose เฉพาะทิศ
```

เหตุผล:

```text
มือจับดาบอาจผิดด้าน
ฝักดาบอาจกลับข้าง
ผ้าคลุมหรือ scarf อาจเสีย silhouette
slash VFX อาจไม่ตรงกับดาบ
```

### 6.3 รูปแบบโฟลเดอร์ที่แนะนำ

```text
assets/sprites/player/nameless_blade/
├── frames/
│   ├── idle/
│   │   ├── left/
│   │   └── right/        optional ในอนาคต
│   ├── run/
│   ├── attack_1/
│   ├── dash/
│   ├── hurt/
│   └── death/
├── sheets/
│   ├── idle_left.png
│   ├── idle_right.png
│   └── attack_1_left.png
└── source_notes.md
```

ถ้าระยะสั้นยังมีแต่ left:

```text
assets/sprites/player/nameless_blade/frames/idle/left/
```

หรือถ้าไม่อยากย้ายไฟล์ทันที ให้คง path เดิมไว้ก่อน แล้วจด convention ใน `source_notes.md`

---

## Phase 7: การทดสอบหลังเปลี่ยน sprite

### 7.1 Test visual

```text
Run scene BossBrokenMaster.tscn
ยืน idle 10 วินาที
เช็กว่า animation ไม่กระตุก
เช็กว่า baseline เท้าไม่เด้ง
เช็กว่า pixel art ไม่เบลอเกินไปบน viewport
```

### 7.2 Test direction

```text
กดซ้าย → ตัวละครควรหันซ้าย
กดขวา → ตัวละครควรหันขวา
เปิด Lock-on → ตัวละครควรหันเข้าหา Boss
Dash ข้าม Boss → หลัง Dash จบควรหันกลับเข้าหา Boss
```

### 7.3 Test combat

```text
Attack ด้านซ้ายและขวา → hitbox ต้องอยู่หน้าตัวละคร
Boss โจมตี → Hurtbox ต้องรับดาเมจถูก
Movement/Tap Deflect → feedback ยังทำงาน
Boss Grab → ตำแหน่งจับยังไม่เพี้ยน
Focus Finisher → ยัง trigger ได้ตามเงื่อนไขเดิม
```

### 7.4 Test mobile readability

```text
เล่นบน viewport ขนาดมือถือ
ดูว่าตัวละครอ่านออกไหม
ดาบเห็นชัดไหม
ผ้าคลุม/scarf ไม่กลืนพื้นหลังไหม
เมื่อ Boss กับ Player ซ้อนใกล้กันยังแยกร่างได้หรือไม่
```

---

## 8. ความเสี่ยงและวิธีลดความเสี่ยง

| ความเสี่ยง | สาเหตุ | วิธีลดความเสี่ยง |
|---|---|---|
| Player หันผิดด้าน | asset source หันซ้าย แต่โค้ดคิดว่าหันขวา | เพิ่ม `sprite_source_faces_left` |
| AttackHitbox ผิดฝั่ง | flip ภาพแต่ไม่ได้เลื่อน hitbox | ใช้ `attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction` ต่อไป |
| Dash trail พัง | AnimatedSprite2D ไม่มี `.texture` แบบ Sprite2D | ทำ helper ดึง current frame texture |
| ภาพเบลอ | import filter ไม่เหมาะกับ pixel art | ตั้ง import เป็น nearest / ปิด filter |
| เท้ากระโดดใน idle | baseline ของ frame ไม่ตรง | ตรวจ frame ก่อน import |
| ภาพซ้อน | ใช้ Sprite2D และ AnimatedSprite2D พร้อมกัน | ปิด/ลบ node เก่าหลังย้ายเสร็จ |
| Godot save scene แล้วค่า export เพี้ยน | scene override ค่า script | ใส่ค่า explicit เฉพาะที่ต้องการ หรือ reset property ใน Inspector |

---

## 9. ลำดับงานที่แนะนำแบบลงมือจริง

### Step 1: ตรวจไฟล์ asset

```text
เปิดโฟลเดอร์ idle
เช็กชื่อไฟล์
เช็กขนาด frame
เช็กทิศทาง left-facing
เช็ก transparency
```

### Step 2: ใช้ idle frame เดียวแทน placeholder

```text
เปลี่ยน texture ของ Player/Sprite2D
ปรับ scale ให้พอดี
เช็ก collision/hurtbox
```

### Step 3: เพิ่ม source orientation config

```text
เพิ่ม sprite_source_faces_left ใน player.gd
แก้ set_facing_direction ให้ flip_h ตาม source orientation
ทดสอบซ้าย/ขวา/lock-on/dash
```

### Step 4: ทำ AnimatedSprite2D idle

```text
เพิ่ม AnimatedSprite2D
สร้าง SpriteFrames idle
เล่น idle loop
แก้ player.gd ให้รองรับ visual node ใหม่
```

### Step 5: แก้ dash trail ให้รองรับ AnimatedSprite2D

```text
สร้าง helper get_current_player_visual_texture()
ถ้าเป็น Sprite2D ใช้ texture
ถ้าเป็น AnimatedSprite2D ใช้ sprite_frames.get_frame_texture()
```

### Step 6: เปิดใช้ animation state ขั้นต่ำ

```text
idle
run
dash
attack_1 แบบ visual เท่านั้น
hurt / posture_broken
```

### Step 7: ทดสอบ combat เต็มรอบ

```text
Tutorial
Skip tutorial
Lock-on
Dash cross-up
Attack
Deflect
Boss Grab
Focus Finisher
Game Over
```

---

## 10. ข้อเสนอเชิงเทคนิคสุดท้าย

แนะนำให้ทำแบบค่อยเป็นค่อยไป ไม่ควรเปลี่ยนเป็น AnimatedSprite2D ทั้งระบบทันที

ลำดับที่ปลอดภัยที่สุดคือ:

```text
1. Sprite2D + idle frame เดียว
2. แก้ flip_h ให้รองรับ source หันซ้าย
3. AnimatedSprite2D เฉพาะ idle
4. แก้ dash trail
5. เพิ่ม animation state อื่น ๆ
```

เหตุผลคือระบบ combat ตอนนี้มีหลายส่วนที่พึ่งพา Player visual node ทางอ้อม เช่น:

```text
flip_h
modulate ตอนโดนตี / focus ready / deflect
dash trail ghost
attack hitbox offset
lock-on facing
```

ถ้าเปลี่ยน visual node เร็วเกินไป อาจเกิด bug หลายจุดพร้อมกันและ debug ยาก

---

## 11. Definition of Done

งานนี้ถือว่าเสร็จสมบูรณ์เมื่อ:

```text
Player ไม่ใช้ player_silhouette.svg แล้ว
Idle sprite ของ The Nameless Blade แสดงในเกมจริง
หันซ้าย/ขวาถูกต้องแม้ source asset มีแค่หันซ้าย
AttackHitbox อยู่หน้าตัวละครถูกทิศ
Dash trail ยังไม่ error
Lock-on ยังหันเข้าหา Boss ถูก
Boss Grab ยังจับตำแหน่งถูก
ไม่มี error ใน console จาก Sprite2D / AnimatedSprite2D
พร้อมต่อยอด run / attack / dash animation ได้
```
