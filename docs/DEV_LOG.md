# DEV LOG - Last Blade Trial

อัปเดตล่าสุด: 2026-06-26  
ขอบเขตการตรวจสอบ: โฟลเดอร์ `last-blade-trial` ทั้งหมด และเอกสารแผนพัฒนาใน `docs`

## สรุปภาพรวม

โปรเจกต์ `last-blade-trial` เป็น prototype เกม Godot 4 แนว 2D side-view arena combat ตามแผน "2D Mobile Souls-lite Boss Rush" โดยตอนนี้แกนต่อสู้หลักเริ่มเล่นได้แล้วในฉากเดียว มี Player, EnemyDummy, HUD และกล้องพร้อมเอฟเฟกต์พื้นฐาน ระบบที่คืบหน้าเด่นคือการโจมตี, Dash, Parry, Stamina, Focus, Posture, Critical, Focus Finisher, Hit Stop, Knockback, Camera Shake, Game Over/Victory และ Restart หลังจบเกม

สถานะโดยรวม: **playable combat prototype / vertical slice ระดับเริ่มต้น**  
ยังไม่ใช่ build มือถือจริง และยังไม่มีระบบด่าน บอสจริง อัปเกรด เซฟ โฆษณา เสียง อนิเมชันจริง หรือ UI touch controls

## ไฟล์ที่ตรวจสอบ

### ไฟล์หลักของ Godot

- `project.godot` - ตั้งค่าโปรเจกต์, main scene, rendering, input actions
- `scenes/main/Main.tscn` - ฉากทดสอบหลักที่ประกอบ Player, EnemyDummy, HUD และ GameCamera
- `player.gd` - ระบบควบคุมและ combat ของผู้เล่น
- `EnemyDummy.gd` - ระบบ AI และ combat ของศัตรูทดลอง
- `HUD.gd` - หน้าจอแสดง HP, Stamina, Focus, Enemy HP, Enemy Posture และผลลัพธ์เกม
- `game_camera.gd` - กล้องหลักและระบบ camera shake

### Asset และไฟล์ประกอบ

- `icon.svg` - asset placeholder ที่ใช้เป็น sprite ของทั้งผู้เล่นและศัตรู
- `icon.svg.import` - import metadata ของ Godot
- `*.gd.uid` - UID metadata ของสคริปต์ Godot
- `.editorconfig` - กำหนด charset เป็น UTF-8
- `.gitignore` - ignore `.godot/` และ `/android/`
- `.gitattributes` - normalize line endings เป็น LF
- `.godot/` - cache/editor state ของ Godot มีอยู่ในเครื่อง แต่ถูก ignore ตาม `.gitignore`

### เอกสารที่เกี่ยวข้อง

- `docs/แผนการพัฒนาเกม_Last_Blade_Trial.md` - แผนเกมฉบับใหญ่ ครอบคลุมวิสัยทัศน์, core loop, ระบบควบคุม, stats, posture, parry และระบบระยะยาว
- `docs/DEV_LOG.md` - ไฟล์บันทึกความก้าวหน้าฉบับนี้

## สถานะตามระบบ

### 1. Project Configuration

สถานะ: **ทำแล้วระดับพื้นฐาน**

สิ่งที่มีแล้ว:

- ใช้ Godot config version 5
- ตั้งชื่อโปรเจกต์เป็น `LastBladeTrial`
- ตั้ง main scene เป็น `scenes/main/Main.tscn` ผ่าน UID
- เปิด feature `4.7` และ `Mobile`
- ตั้ง stretch mode เป็น `canvas_items` และ aspect เป็น `expand`
- ใช้ renderer แบบ `mobile`
- ตั้ง physics engine 3D เป็น Jolt แม้เกมปัจจุบันเป็น 2D

Input actions ที่มี:

- `attack` ใช้ปุ่ม J
- `dash` ใช้ปุ่ม K
- `parry` ใช้ปุ่ม L
- การเดินใช้ action built-in `ui_left` และ `ui_right`

สิ่งที่ยังขาด:

- ยังไม่มี touch input / virtual joystick สำหรับ Android
- ยังไม่มี Android export preset
- ยังไม่มี project setting เฉพาะ production เช่น orientation, resolution target, icon/splash จริง

### 2. Main Scene / Arena Prototype

สถานะ: **ทำแล้วระดับ prototype**

สิ่งที่มีแล้วใน `Main.tscn`:

- Root node เป็น `Node2D`
- มี `Player` เป็น `CharacterBody2D` พร้อม sprite, collision, attack hitbox และ hurtbox
- มี `EnemyDummy` เป็น `CharacterBody2D` พร้อม sprite, collision, attack hitbox และ hurtbox
- มี `HUD` เป็น `CanvasLayer`
- มี `GameCamera` เป็น `Camera2D`
- ใช้ `icon.svg` เป็น placeholder sprite ทั้งผู้เล่นและศัตรู
- วางตำแหน่งเริ่มต้น Player ที่ประมาณ `(576, 324)` และ EnemyDummy ที่ประมาณ `(750, 324)`
- CollisionShape และ Area2D ถูกจัดไว้ครบสำหรับการโจมตี/รับดาเมจ

สิ่งที่ยังขาด:

- ยังไม่มีพื้น ฉากหลัง arena หรือ boundary
- ยังไม่มี level selection หรือระบบโหลดด่าน
- ยังไม่มี animation player / animation tree
- ยังไม่มี resource แยกสำหรับ character data หรือ enemy data

### 3. Player Movement

สถานะ: **ทำแล้วระดับควบคุมพื้นฐาน**

สิ่งที่มีแล้วใน `player.gd`:

- Player extends `CharacterBody2D`
- เดินซ้าย/ขวาด้วย `Input.get_axis("ui_left", "ui_right")`
- ความเร็วเดินตั้งค่าได้ผ่าน `@export var speed = 300.0`
- หันซ้าย/ขวาด้วย `Sprite2D.flip_h`
- ย้ายตำแหน่ง attack hitbox ตามทิศที่หัน
- หยุดเคลื่อนที่ระหว่าง attack และ parry
- หยุดควบคุมเมื่อ dead, dash หรือ knockback

สิ่งที่ยังขาด:

- ยังไม่มี joystick/touch movement
- ยังไม่มี acceleration/deceleration หรือ movement smoothing
- ยังไม่มีแรงโน้มถ่วงหรือ platforming เพราะ prototype เป็นแนวแกน X ล้วน
- ยังไม่มี animation เดิน/หยุด/โดนตี

### 4. Player Attack System

สถานะ: **ทำแล้วระดับใช้งานได้**

สิ่งที่มีแล้ว:

- ปุ่ม attack เรียก `attack()` เมื่อไม่ได้ทำ action อื่น
- ใช้ stamina ก่อนโจมตี
- ค่าโจมตีพื้นฐาน `attack_damage = 10`
- เปิด `AttackHitbox` ชั่วคราวตาม `attack_active_time = 0.18`
- มี recovery หลังโจมตี `attack_recovery_time = 0.12`
- กันการโดนซ้ำใน swing เดียวด้วย `hit_targets`
- ตรวจเฉพาะ Area ชื่อ `Hurtbox`
- ไม่โจมตีโดนตัวเอง
- ถ้าเป้าหมายมี `take_damage()` จะส่งดาเมจเข้าไป

สิ่งที่ยังขาด:

- ยังไม่มี combo chain
- ยังไม่มี attack animation/sfx/vfx จริง
- ยังไม่มี attack buffering หรือ input queue
- ยังไม่มีระบบโจมตีหนัก/เบา

### 5. Stamina System

สถานะ: **ทำแล้วระดับแกนหลัก**

สิ่งที่มีแล้ว:

- Player มี `max_stamina = 100.0`
- Stamina เริ่มเต็มตอน `_ready()`
- ฟื้น stamina ทุกเฟรมด้วย `stamina_regen_rate = 10.0`
- Attack ใช้ stamina 18
- Dash ใช้ stamina 30
- Parry ใช้ stamina 20
- ถ้า stamina ไม่พอ action จะไม่ทำงาน
- อัปเดต HUD ผ่าน signal `stats_changed`

ข้อสังเกต:

- ระบบ regen ทำงานตลอด แม้กำลังต่อสู้ ไม่มี delay หลังใช้ stamina
- HUD ลดการอัปเดตถี่เกินไปด้วยการเทียบค่า `int()`

สิ่งที่ยังขาด:

- ยังไม่มี exhaustion state
- ยังไม่มี tuning สำหรับมือถือจริง
- ยังไม่มี visual feedback ตอน stamina ไม่พอ นอกจาก `print()`

### 6. Dash และ Invincibility Frame

สถานะ: **ทำแล้วระดับ prototype**

สิ่งที่มีแล้ว:

- Dash ใช้ปุ่ม K
- มี `dash_speed = 850.0`
- ระยะเวลา dash `dash_time = 0.18`
- cooldown `dash_cooldown = 0.45`
- ปิด hurtbox ระหว่าง dash เพื่อทำ i-frame
- กัน dash ซ้ำด้วย `can_dash`
- ถ้าถูกตรวจดาเมจระหว่าง dash ยังมี guard ใน `take_damage()` อีกชั้น

สิ่งที่ยังขาด:

- ยังไม่มี dash trail / vfx
- ยังไม่มี animation dash
- ยังไม่มี dodge direction อิสระ นอกจากพุ่งตามทิศที่หัน
- ยังไม่มีระบบจำกัดพื้นที่ไม่ให้ dash หลุด arena

### 7. Parry System

สถานะ: **ทำแล้วระดับเล่นได้**

สิ่งที่มีแล้ว:

- Parry ใช้ปุ่ม L
- ใช้ stamina ก่อนเริ่ม parry
- มี active window `parry_active_time = 0.45`
- มี recovery `parry_recovery_time = 0.1`
- Player เปลี่ยนสีเป็น cyan ระหว่าง parry
- Enemy ตรวจ `target.is_parry_active()` ตอน hitbox ชน Player hurtbox
- Parry สำเร็จจะไม่ทำดาเมจผู้เล่น
- Parry สำเร็จเรียก `on_successful_parry()`
- Parry สำเร็จเพิ่ม Focus 20
- Enemy เสีย Posture 35 และ stagger ถ้า posture ยังไม่แตก

ข้อสังเกต:

- ใน `player.gd` comment บางจุดยังบอกว่า "ยังไม่ทำ Posture ตอนนี้" แต่ implementation ฝั่ง `EnemyDummy.gd` ทำ posture แล้ว
- Parry window ค่อนข้างกว้างเพื่อทดสอบง่าย เหมาะกับ prototype แต่ต้อง tune ใหม่ตอนลงมือถือ

สิ่งที่ยังขาด:

- ยังไม่มี perfect parry / late parry / failed parry feedback
- ยังไม่มีเสียงหรือ effect ชัดเจน
- ยังไม่มี parry tutorial หรือ timing indicator จริง

### 8. Focus และ Focus Finisher

สถานะ: **ทำแล้วเกินระดับพื้นฐานของแผน**

สิ่งที่มีแล้ว:

- Player มี `max_focus = 100.0`
- Focus เริ่มที่ 0
- Parry สำเร็จได้ Focus 20
- มี `focus_finisher_cost = 100.0`
- เมื่อ Focus เต็มและศัตรูอยู่ในสถานะรับ finisher ได้ การโจมตีจะเปลี่ยนเป็น Focus Finisher
- Finisher damage คำนวณจาก `focus_finisher_damage_ratio = 0.40` ของ HP สูงสุดศัตรู
- มี minimum damage อย่างน้อย `attack_damage * 2`
- ใช้ Focus แล้วลดกลับผ่าน `spend_focus()`
- Enemy มี `take_focus_finisher_damage()`
- Damage popup แสดงข้อความ `FINISHER!`
- ใช้ hit stop และ camera shake แบบ critical

สิ่งที่ยังขาด:

- ยังไม่มีปุ่ม Finisher แยกหรือ confirmation ทำให้ finisher ถูกใช้โดยอัตโนมัติเมื่อเงื่อนไขครบ
- ยังไม่มี animation/cut-in ของท่าพิเศษ
- ยังไม่มี balancing ว่า Focus ควรได้จาก action อื่นนอกจาก parry หรือไม่

### 9. Player Damage, Hurt Invincibility และ Death

สถานะ: **ทำแล้วระดับใช้งานได้**

สิ่งที่มีแล้ว:

- Player มี `max_hp = 100`
- รับดาเมจผ่าน `take_damage(amount)`
- กันดาเมจซ้ำเมื่อ dead, hurt invincible หรือ dash
- โดนตีแล้วลด HP, emit stats, knockback, camera shake และ flash red
- มี hurt invincibility `hurt_invincible_time = 0.65`
- ระหว่าง invincible ปิด hurtbox และกระพริบตัวละคร
- เมื่อตาย ปิด action, ปิด hitbox/hurtbox, emit `player_died`, ซ่อนตัวละคร และปิด physics process

สิ่งที่ยังขาด:

- ยังไม่มี death animation
- ยังไม่มี respawn/checkpoint
- ยังไม่มี sound feedback
- HP อาจติดลบใน print ก่อน clamp เพราะ player ลด HP โดยไม่ clamp ก่อน emit/die

### 10. EnemyDummy AI

สถานะ: **ทำแล้วระดับ dummy combat AI**

สิ่งที่มีแล้วใน `EnemyDummy.gd`:

- Enemy extends `CharacterBody2D`
- หา Player จาก parent node ชื่อ `Player`
- เดินเข้าหาผู้เล่นในแกน X ด้วย `move_speed = 120.0`
- หยุดเมื่อเข้าใกล้ `stop_distance = 90.0`
- หันหน้าเข้าหา Player และเลื่อน attack hitbox ตามทิศ
- เมื่ออยู่ในระยะและ cooldown พร้อม จะเริ่มโจมตี
- หยุดเคลื่อนที่ระหว่าง wind-up, attack, stagger, posture break และ knockback

สิ่งที่ยังขาด:

- ยังเป็น enemy dummy ตัวเดียว ไม่มี state machine แยกชัดเจน
- ยังไม่มี pattern หลายท่า, boss phase, telegraph หลายแบบ
- ยังผูก path กับ node ชื่อ `Player` โดยตรง
- ยังไม่มี navigation หรือการจัดการหลายศัตรู

### 11. Enemy Attack System

สถานะ: **ทำแล้วระดับใช้งานได้**

สิ่งที่มีแล้ว:

- Enemy มี wind-up ก่อนโจมตี `attack_windup_time = 0.35`
- เปลี่ยนสีเป็นเหลืองตอนเตรียมโจมตี
- เปิด attack hitbox ช่วง `attack_active_time = 0.18`
- cooldown `attack_cooldown = 1.2`
- ใช้ `attack_sequence_id` เพื่อยกเลิก coroutine เก่าหากถูก parry/break/dead
- ใช้ `set_deferred("disabled", false/true)` กับ hitbox เพื่อเลี่ยงปัญหา physics flush
- ตรวจ overlapping areas หลังเปิด hitbox เพื่อให้โดนแม้ area ซ้อนอยู่แล้ว
- กันการตีโดน Player ซ้ำใน attack เดียวด้วย `has_hit_player`

สิ่งที่ยังขาด:

- ยังไม่มี animation timing จริง
- ยังไม่มี hitbox หลายรูปแบบ
- ยังไม่มี recovery visual ที่ผู้เล่นอ่านได้ชัด

### 12. Enemy HP, Posture, Stagger และ Posture Break

สถานะ: **ทำแล้วระดับแกนหลัก**

สิ่งที่มีแล้ว:

- Enemy มี `max_hp = 50`
- Enemy มี `max_posture = 100.0`
- Parry สำเร็จลด posture 35
- ถ้า posture ยังไม่หมด enemy จะ `stagger()` 0.45 วินาที และพักอีก 0.25 วินาที
- ถ้า posture หมด จะเข้า `posture_break()` 1.2 วินาที
- ระหว่าง posture break ศัตรูหยุดนิ่ง เปลี่ยนสีม่วง ปิด hitbox และเปิดช่อง critical
- เมื่อหมด posture break จะ reset posture เต็ม
- HUD แสดง Enemy Posture

ข้อสังเกต:

- แผนเอกสารอธิบาย posture แบบ "สะสมจนเต็มแล้วแตก" แต่โค้ดปัจจุบันใช้แบบ "ลดจากเต็มจนเหลือ 0 แล้วแตก" ซึ่งใช้งานได้ แค่ต้องใช้คำอธิบายใน UI/เอกสารให้ตรงกัน

สิ่งที่ยังขาด:

- ยังไม่มี posture damage จากการโจมตีปกติ
- ยังไม่มี posture regen
- ยังไม่มีแยก posture behavior ระหว่างศัตรูธรรมดาและ boss

### 13. Critical Attack

สถานะ: **ทำแล้ว**

สิ่งที่มีแล้ว:

- ระหว่าง enemy posture break เปิด `can_receive_critical`
- การโจมตีครั้งแรกในช่วงนี้คูณดาเมจด้วย `critical_damage_multiplier = 3.0`
- ใช้ได้ 1 ครั้งต่อ posture break
- แสดง damage popup แบบ `CRITICAL!`
- ใช้ hit stop นานกว่าโจมตีปกติ
- ใช้ camera shake แรงกว่าโจมตีปกติ
- flash ศัตรูเป็นสีส้มทอง

สิ่งที่ยังขาด:

- ยังไม่มี animation เฉพาะ critical
- ยังไม่มี input prompt หรือ UI บอกโอกาส critical
- ยังไม่มี logic แยก priority ระหว่าง Critical ปกติและ Focus Finisher นอกจากฝั่ง Player เลือก Finisher ก่อนเมื่อ Focus เต็ม

### 14. Hit Stop, Knockback และ Combat Feedback

สถานะ: **ทำแล้วระดับ prototype ที่ดี**

สิ่งที่มีแล้ว:

- Enemy รับดาเมจแล้วเกิด hit stop
- Hit stop ใช้ `Engine.time_scale = 0.08`
- Timer ของ hit stop ใช้ `ignore_time_scale = true`
- มี `hit_stop_id` กัน hit stop ซ้อนแล้ว reset เวลาผิด
- โจมตีปกติ hit stop 0.06 วินาที
- Critical hit stop 0.12 วินาที
- Enemy โดนตีแล้ว knockback 0.12 วินาที แรง 220
- Player โดนตีแล้ว knockback 0.14 วินาที แรง 260
- มี damage popup ลอยขึ้นและ fade out ด้วย Tween
- มีสี feedback: เหลืองตอน enemy wind-up, cyan ตอน parry/stagger, ม่วงตอน posture break, แดงตอนโดนตี, ส้มตอน critical

สิ่งที่ยังขาด:

- ยังไม่มี particle/vfx
- ยังไม่มี screen flash
- ยังไม่มี sound effects
- ยังไม่มี animation จริง ทำให้ feedback ตอนนี้อาศัยสีและตัวเลขเป็นหลัก

### 15. Camera System

สถานะ: **ทำแล้วระดับพื้นฐาน**

สิ่งที่มีแล้วใน `game_camera.gd`:

- Camera2D เรียก `make_current()`
- เก็บ `original_offset`
- add เข้า group `game_camera`
- node อื่นเรียก `get_tree().call_group("game_camera", "shake", strength, duration)` ได้
- shake ลดแรงลงตามเวลา
- ใช้ random offset ในแกน X/Y
- ศัตรูโดนตี, critical และ player โดนตีเรียก camera shake แล้ว

สิ่งที่ยังขาด:

- ยังไม่มี camera follow player/enemy
- ยังไม่มี arena framing หรือ boss fight framing
- ยังไม่มี trauma-based shake หรือ shake profile หลายแบบ

### 16. HUD และ Game Result

สถานะ: **ทำแล้วระดับ prototype**

สิ่งที่มีแล้วใน `HUD.gd`:

- แสดง Player HP
- แสดง Player Stamina
- แสดง Player Focus
- แสดง Enemy HP
- แสดง Enemy Posture
- ใช้ ProgressBar ทุกค่า
- เชื่อม signal จาก Player และ EnemyDummy
- แสดง `GAME OVER` เมื่อ Player ตาย
- แสดง `VICTORY!` เมื่อ Enemy ตาย
- เมื่อเกมจบ กด R เพื่อ reload scene
- `_ready()` reset `Engine.time_scale = 1.0` กันค้างจาก hit stop

สิ่งที่ยังขาด:

- ยังเป็น HUD แบบ debug/prototype ไม่มี mobile layout
- ยังไม่มีปุ่ม touch Attack/Dash/Parry
- ยังไม่มี pause/menu/settings
- ยังไม่มี visual state สำหรับ stamina ไม่พอ, focus เต็ม, posture break opportunity

### 17. Win/Lose Loop และ Restart

สถานะ: **ทำแล้วระดับ prototype**

สิ่งที่มีแล้ว:

- Player ตาย emit `player_died`
- Enemy ตาย emit `enemy_died`
- HUD รับ signal แล้วแสดงผลลัพธ์
- มี guard `is_game_finished` ป้องกันแสดงซ้ำ
- กด R หลังจบเกมเพื่อ reload scene

สิ่งที่ยังขาด:

- ยังไม่มี reward screen
- ยังไม่มีเลือก retry/next stage ผ่าน UI
- ยังไม่มีระบบปลดล็อก/อัปเกรดหลังชนะ
- ยังไม่มี transition

### 18. Asset / Visual / Animation

สถานะ: **placeholder**

สิ่งที่มีแล้ว:

- ใช้ `icon.svg` เป็น sprite ชั่วคราว
- ศัตรูใช้ sprite เดียวกับ player แต่ modulate เป็นสีแดงเข้ม
- ใช้สีของ Sprite เป็น gameplay feedback
- มี damage popup เป็น Label

สิ่งที่ยังขาด:

- ยังไม่มีตัวละครจริง
- ยังไม่มี sprite sheet หรือ animation
- ยังไม่มีฉากหลัง, พื้น, VFX, SFX, music
- ยังไม่มี visual identity แบบ silhouette ตามแผน

### 19. Mobile / Android Readiness

สถานะ: **ยังไม่เริ่มจริง**

สิ่งที่มีแล้ว:

- Project feature ระบุ `Mobile`
- Rendering method เป็น `mobile`
- แนวคิดในเอกสารตั้งเป้า Android

สิ่งที่ยังขาด:

- ยังไม่มี `/android/` export output หรือ export preset
- ยังไม่มี virtual joystick และปุ่ม touch
- ยังไม่มี responsive HUD สำหรับจอมือถือ
- ยังไม่มีทดสอบบน OPPO Reno 14F 5G
- ยังไม่มี rewarded ads หรือ integration ใด ๆ

### 20. Progress เทียบกับแผนพัฒนาใหญ่

ระบบที่เริ่มทำแล้ว:

- 2D side-view arena prototype
- ตัวละครหลัก 1 ตัว
- ศัตรูพื้นฐาน 1 ตัว
- ระบบโจมตี
- ระบบ Dash
- ระบบ Parry
- ระบบ Stamina
- ระบบ Focus
- ระบบ Posture
- ระบบ Critical/Finisher
- ระบบ HP
- ระบบชนะ/แพ้
- Combat feedback พื้นฐาน

ระบบที่ยังไม่เริ่ม:

- ศัตรูพื้นฐาน 3-5 แบบ
- บอสหลัก 1-3 ตัว
- ระบบด่าน/เลือกด่าน
- ระบบอัปเกรดพื้นฐาน
- เครื่องราง/ท่าดาบ/ปลดล็อก
- Daily challenge
- Economy/reward
- Rewarded ads
- Save/load
- Audio
- Art production
- Android export และทดสอบเครื่องจริง

## ประเด็นทางเทคนิคที่ควรติดตาม

1. **Coroutine safety:** โค้ด enemy ใช้ `attack_sequence_id` และ `hit_stop_id` ช่วยกัน coroutine ค้างได้ดีแล้ว ฝั่ง player ยังมี coroutine หลายจุด เช่น attack, dash, parry, invincibility, flash ที่ควรตรวจเพิ่มเมื่อมี animation หรือ scene transition
2. **Node path coupling:** `HUD.gd` และ `EnemyDummy.gd` อ้าง node ชื่อ `Player`/`EnemyDummy` โดยตรง เหมาะกับ prototype แต่ควร refactor เมื่อมีหลายด่านหรือหลายศัตรู
3. **Posture wording:** เอกสารแผนกับโค้ดใช้โมเดลคนละภาษานิดหน่อย เอกสารบอกสะสมจนเต็ม ส่วนโค้ดลดจากเต็มลงศูนย์ ควรเลือกแนวเดียวก่อนทำ UI จริง
4. **Player HP clamp:** Enemy HP clamp แล้ว แต่ Player HP ยังไม่ clamp ก่อน emit/print อาจเห็นค่าติดลบใน HUD/console หากโดนดาเมจเกินเลือดที่เหลือ
5. **Hit stop global time_scale:** มีการ reset ใน HUD `_ready()` และ Enemy `die()` แล้ว แต่ในอนาคตควรมี manager กลางถ้าระบบซับซ้อนขึ้น
6. **Touch controls:** เป็น blocker สำคัญที่สุดสำหรับเป้าหมาย Android เพราะตอนนี้ playable ด้วย keyboard เป็นหลัก

## ลำดับงานแนะนำถัดไป

1. ทำ touch control layer: joystick ซ้าย + ปุ่ม Attack/Dash/Parry ขวา
2. เพิ่ม arena พื้นฐาน: พื้น, boundary, camera framing
3. เพิ่ม animation placeholder อย่างน้อย idle/run/attack/dash/parry/hurt/death
4. ปรับ HUD ให้เหมาะกับมือถือ และเพิ่ม feedback สำหรับ Focus เต็ม / Posture Break
5. แยก enemy state ให้ชัดขึ้น หรือเริ่มสร้าง enemy/boss base class
6. เพิ่ม enemy pattern อย่างน้อย 2 ท่า เพื่อทดสอบว่า Parry/Dash มี decision จริง
7. ทำ Android export preset และทดสอบบนเครื่องจริง
8. หลัง core feel ดีแล้ว ค่อยเริ่มระบบ reward/upgrade ตามแผน

## สรุปสถานะล่าสุด

Prototype ตอนนี้มีแกนดวลดาบที่จับต้องได้แล้ว จุดแข็งคือระบบ combat feedback คืบหน้าเร็วกว่า milestone เริ่มต้นมาก โดยเฉพาะ posture, critical, focus finisher, hit stop และ camera shake ซึ่งช่วยให้จังหวะโจมตีมีน้ำหนักตั้งแต่ยังใช้ placeholder art

จุดที่ควรโฟกัสต่อคือการทำให้ prototype เล่นได้บนมือถือจริง เพราะเป้าหมายของเกมคือ Android การมี touch controls และ layout ที่อ่านง่ายบนจอมือถือจะเป็นก้าวถัดไปที่สำคัญกว่าเพิ่มระบบใหญ่ใหม่ในตอนนี้
