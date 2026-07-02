# Mobile Combat Rework Plan

แผนการปรับปรุงระบบต่อสู้สำหรับ Last Blade Trial / ดาบไร้นาม

เอกสารนี้ใช้เป็นแผนก่อนลงมือแก้โค้ดจริง โดยโฟกัสที่การเล่นบนมือถือเป็นหลัก ลดจำนวนปุ่มที่ผู้เล่นต้องกดพร้อมกัน และทำให้ระบบต่อสู้ยังมีความท้าทายผ่านระบบ Lock-on, Movement Deflect และ Player Posture

---

## 1. เป้าหมายหลักของการปรับระบบ

### เป้าหมายด้าน UX บนมือถือ

- ลดจำนวนปุ่มฝั่งขวาจาก `ATTACK / DASH / PARRY` เหลือ `ATTACK / DASH / LOCK`
- เอาปุ่ม `PARRY` ออกจากหน้าจอ เพื่อไม่ให้ UI แน่นและกดยากบนมือถือ
- ใช้ Virtual Joystick ฝั่งซ้ายเป็นทั้งระบบเคลื่อนที่และระบบ Deflect
- เพิ่มปุ่ม Lock-on เพื่อช่วยให้ผู้เล่นหันหน้าเข้าหา Boss ได้ง่าย โดยเฉพาะหลัง Dash ข้ามตัว Boss

### เป้าหมายด้าน Gameplay

- เปลี่ยนระบบ Parry เดิมเป็นระบบ `Movement Deflect`
- ให้ผู้เล่น Deflect ได้จากการโยกซ้าย/ขวาในจังหวะที่ Boss โจมตี
- ท่า Heavy ของ Boss ต้องยังเป็นท่าที่ต้อง Dash หลบเท่านั้น ไม่สามารถ Deflect ได้
- เพิ่ม `Player Posture` เพื่อไม่ให้ระบบ Movement Deflect ทำให้เกมง่ายเกินไป
- คงจังหวะต่อสู้แบบอ่านท่าบอส ตัดสินใจเร็ว และสวนกลับให้ชัดเจน

---

## 2. สภาพระบบปัจจุบันโดยสรุป

### Touch Controls ปัจจุบัน

ปัจจุบัน `touch_controls.gd` สร้าง UI หลักดังนี้

- Virtual Joystick ฝั่งซ้าย
- ปุ่ม `ATTACK`
- ปุ่ม `DASH`
- ปุ่ม `PARRY`

ระบบปุ่มฝั่งขวายังส่ง action ตรง ๆ ได้แก่

- `attack`
- `dash`
- `parry`

### Player ปัจจุบัน

`player.gd` ใช้ระบบหลักดังนี้

- เดินจาก `Input.get_axis("ui_left", "ui_right")`
- Attack จาก `Input.is_action_just_pressed("attack")`
- Dash จาก `Input.is_action_just_pressed("dash")`
- Parry จาก `Input.is_action_just_pressed("parry")`
- Boss ตรวจ Parry ผ่าน `player.is_parry_active()`

### Boss ปัจจุบัน

`BossBrokenMaster.gd` มีระบบท่าโจมตีอยู่แล้ว เช่น

- `normal_slash`
- `quick_slash`
- `delayed_slash`
- `heavy_slash`

และมีตัวแปรสำคัญคือ

```gdscript
current_attack_can_be_parried
```

ตัวแปรนี้เหมาะมากสำหรับใช้แยกท่าที่ Movement Deflect ได้กับท่าที่ต้อง Dash เท่านั้น

### HUD ปัจจุบัน

HUD แสดงข้อมูลหลักแล้ว ได้แก่

- Player HP
- Player Stamina
- Player Focus
- Boss HP
- Boss Posture

แต่ยังไม่มี Player Posture

---

## 3. ระบบใหม่ที่ต้องการ

## 3.1 UI ใหม่บนมือถือ

### ปุ่มฝั่งซ้าย

คง Virtual Joystick ไว้เหมือนเดิม แต่เพิ่มหน้าที่ใหม่คือใช้เป็นตัวกระตุ้น Movement Deflect

### ปุ่มฝั่งขวา

เปลี่ยนเป็น 3 ปุ่มเท่านั้น

```text
ATTACK / DASH / LOCK
```

หรือถ้าพื้นที่ไม่พอ อาจใช้ข้อความสั้นลงเป็น

```text
ATK / DASH / LOCK
```

### ปุ่มที่ถูกลบ

ลบปุ่ม `PARRY` ออกจาก Touch UI

ข้อควรระวัง: ช่วงแรกยังไม่ควรลบ input action `parry` ออกจาก `project.godot` ทันที เพราะอาจมีระบบ Tutorial หรือ Duel เดิมอ้างถึงอยู่ ควรเลิกใช้ก่อน แล้วค่อย cleanup ใน phase หลัง

---

## 3.2 ระบบ Lock-on

### แนวคิด

เพิ่มระบบ Lock-on แบบ 2D Duel Lock

```text
Lock OFF = ผู้เล่นหันหน้าตามทิศที่เดิน
Lock ON  = ผู้เล่นหันหน้าเข้าหา Boss เสมอ
```

### พฤติกรรมที่ต้องการ

เมื่อเปิด Lock-on แล้ว

- Player หันหน้าเข้าหา Boss อัตโนมัติ
- ถ้า Player Dash ข้าม Boss ไปอีกฝั่ง หลัง Dash จบต้องหันหน้ากลับเข้าหา Boss ทันที
- ผู้เล่นกดปุ่ม Lock ซ้ำเพื่อเปิด/ปิดได้
- ปุ่ม Lock ต้องมี visual feedback ว่าตอนนี้ Lock อยู่หรือไม่

### สัญลักษณ์บนปุ่ม Lock

สถานะที่เสนอ

```text
LOCK OFF: LOCK
LOCK ON : LOCKED หรือ ● LOCK
```

สีที่เสนอ

```text
OFF = สีฟ้าโปร่งแบบปุ่มปกติ
ON  = สีทองหรือขอบสว่าง เพื่อให้เห็นชัดว่ากำลังล็อคเป้า
```

### แหล่งอ้างอิงเป้าหมาย

ควรหา Boss จาก group เดิมที่มีอยู่แล้ว

```text
combat_target
```

เพื่อลดการ hardcode ชื่อ node และรองรับศัตรูอื่นในอนาคต

---

## 3.3 ระบบ Movement Deflect

### เปลี่ยนคำเรียกระบบ

คำแนะนำคือใช้ชื่อ

```text
Movement Deflect
```

แทนการเรียกว่า Parry ตรง ๆ เพราะระบบใหม่ไม่ได้ใช้ปุ่ม Parry แล้ว แต่เป็นการเบี่ยงดาบด้วยจังหวะการเคลื่อนที่

### หลักการ

Player จะ Deflect ได้เมื่อโยก joystick ซ้ายหรือขวาในจังหวะที่ Boss โจมตีด้วยท่าที่ Deflect ได้

### เงื่อนไข Deflect สำเร็จที่แนะนำ

Deflect สำเร็จเมื่อครบเงื่อนไขเหล่านี้

1. Boss กำลังโจมตีด้วยท่าที่ `current_attack_can_be_parried == true`
2. Player เพิ่งโยก joystick ซ้ายหรือขวาในช่วงเวลาสั้น ๆ ก่อน hitbox ชน
3. Player ไม่ได้กำลัง Attack
4. Player ไม่ได้กำลัง Dash
5. Player ไม่ได้อยู่ในสถานะ Posture Broken
6. Player ยังมี Posture เพียงพอสำหรับรับแรงปะทะ

### ข้อสำคัญ: ห้ามให้การกดค้างนับเป็น Deflect ตลอดเวลา

ถ้าแค่โยก joystick ค้างไว้แล้ว Deflect ได้ตลอด เกมจะง่ายเกินไป

ดังนั้นควรนับเฉพาะจังหวะเหล่านี้

- เริ่มโยกจากจุดกลางไปซ้ายหรือขวา
- เปลี่ยนทิศจากซ้ายไปขวาหรือขวาไปซ้าย
- ปล่อยแล้วโยกใหม่

ไม่ควรนับกรณีถือ joystick ค้างทิศเดิมเป็นเวลานาน

### ค่าเริ่มต้นที่เสนอ

```gdscript
movement_deflect_window = 0.28
```

หมายความว่า ถ้าผู้เล่นเพิ่งโยก movement ภายใน 0.28 วินาทีก่อนโดน hitbox ของ Boss และท่านั้น Deflect ได้ ให้ถือว่า Deflect สำเร็จ

### วิธีเชื่อมกับระบบเดิมแบบเสี่ยงน้อย

ช่วงแรกไม่ต้องรื้อ Boss มาก ให้คง interface เดิมไว้ก่อน

```gdscript
func is_parry_active() -> bool:
    return is_movement_deflect_active()
```

Boss จะยังเรียก `is_parry_active()` เหมือนเดิม แต่ความหมายภายใน Player เปลี่ยนจากปุ่ม Parry เป็น Movement Deflect

วิธีนี้ช่วยลดความเสี่ยง เพราะ Boss เดิมมี logic ตรวจ Parry สำเร็จอยู่แล้ว

---

## 3.4 ท่า Boss กับวิธีตอบสนองใหม่

### Normal Slash

- Hint ใหม่: `DEFLECT!`
- วิธีรับมือ: โยก joystick ในจังหวะที่ถูกต้อง
- Deflect ได้

### Quick Slash

- Hint ใหม่: `DEFLECT!`
- วิธีรับมือ: ต้องโยกเร็วกว่า Normal
- Deflect ได้
- ควรคุมไม่ให้ออกถี่เกินไปเหมือนระบบปัจจุบัน

### Delayed Slash

- Hint ใหม่ช่วงแรก: `WAIT...`
- Hint ใหม่ช่วงท้าย: `DEFLECT!`
- วิธีรับมือ: ห้ามโยกเร็วเกินไป ต้องรอจังหวะท้าย
- Deflect ได้เฉพาะช่วงท้าย

### Heavy Slash

- Hint ใหม่: `DASH!`
- วิธีรับมือ: Dash หลบเท่านั้น
- Deflect ไม่ได้
- ถ้าผู้เล่นพยายาม Deflect ควรโดนลงโทษด้วย HP damage หรือ Posture damage สูง

---

## 3.5 Player Posture

### เหตุผลที่ต้องเพิ่ม

เมื่อ Deflect ทำได้จาก movement เกมจะง่ายขึ้นมาก ดังนั้นต้องมีทรัพยากรใหม่ที่จำกัดการตั้งรับ

Player Posture จะทำหน้าที่เป็นค่าความมั่นคงของผู้เล่น

### ค่าเริ่มต้นที่เสนอ

```gdscript
max_player_posture = 100.0
current_player_posture = 100.0
player_posture_regen_rate = 16.0
posture_damage_on_deflect = 14.0
posture_damage_on_wrong_deflect = 28.0
posture_damage_from_heavy_hit = 45.0
player_posture_break_time = 0.85
```

### พฤติกรรมของ Player Posture

เมื่อ Deflect สำเร็จ

- Boss เสีย Posture
- Player ได้ Focus เล็กน้อย
- Player เสีย Posture เล็กน้อย

เมื่อพยายาม Deflect ผิดท่า เช่น Heavy

- Player เสีย Posture มาก
- อาจโดน HP damage ตามปกติ
- ขึ้น feedback เช่น `DASH ONLY!`

เมื่อ Player Posture หมด

- Player เข้าสถานะ Posture Broken
- ขยับไม่ได้ชั่วคราว
- Attack / Dash / Deflect ไม่ได้ชั่วคราว
- มี camera shake และ feedback สีแดง/ม่วง
- หลังหมดเวลาจึงฟื้น Posture กลับบางส่วนหรือเต็ม

### แนวทางฟื้น Posture

เสนอ 2 ทางเลือก

ทางเลือก A: ฟื้นเรื่อย ๆ ตามเวลา

```text
เหมาะกับเกมที่ต้องการความลื่นและไม่ลงโทษหนักเกินไป
```

ทางเลือก B: ฟื้นหลังไม่โดนโจมตีระยะหนึ่ง

```text
เหมาะกับเกมที่ต้องการความกดดันมากขึ้น
```

แนะนำให้เริ่มจากทางเลือก A ก่อน เพื่อจูนง่ายกว่า

---

## 3.6 Focus หลังเปลี่ยนระบบ

ปัจจุบัน Focus ได้จาก Parry สำเร็จ และใช้ทำ Focus Finisher

เมื่อ Deflect ง่ายขึ้น ควรลด Focus gain ลง

ค่าที่เสนอ

```gdscript
focus_gain_on_successful_parry = 8.0
```

หรือแยกเป็น 2 ระดับในอนาคต

```text
Normal Deflect  = +6 Focus
Perfect Deflect = +12 Focus
```

Perfect Deflect อาจหมายถึงโยกในช่วง 0.12 วินาทีสุดท้ายก่อนโดน hitbox

---

## 4. แผนพัฒนาเป็น Phase

## Phase A: ปรับ Touch UI

### เป้าหมาย

- เอาปุ่ม Parry ออกจากหน้าจอ
- เพิ่มปุ่ม Lock แทน
- ยังไม่แตะระบบ balance ลึก

### ไฟล์ที่เกี่ยวข้อง

```text
touch_controls.gd
project.godot
```

### งานที่ต้องทำ

- เปลี่ยน `parry_touch_button` เป็น `lock_touch_button`
- เปลี่ยน label ปุ่มจาก `PARRY` เป็น `LOCK`
- เพิ่ม input action ใหม่ชื่อ `lock_on`
- ให้ปุ่ม Lock เป็น toggle ไม่ใช่ tap action แบบ Attack/Dash
- เปลี่ยน visual ของปุ่มเมื่อ Lock ON/OFF

### Acceptance Criteria

- บนมือถือไม่มีปุ่ม Parry แล้ว
- มีปุ่ม Lock แสดงแทน
- กด Lock แล้วสถานะเปิด/ปิดได้
- ปุ่ม Attack และ Dash ยังทำงานเหมือนเดิม

---

## Phase B: เพิ่ม Target Lock-on

### เป้าหมาย

- เปิด Lock แล้ว Player หันหน้าเข้าหา Boss เสมอ
- Dash ข้าม Boss แล้วหันกลับทันที

### ไฟล์ที่เกี่ยวข้อง

```text
player.gd
```

### งานที่ต้องทำ

- เพิ่มตัวแปร `is_target_locked`
- เพิ่มตัวแปร `locked_target`
- หา target จาก group `combat_target`
- เพิ่มฟังก์ชัน `toggle_target_lock()`
- เพิ่มฟังก์ชัน `update_facing_to_locked_target()`
- หลัง Dash จบ ถ้า Lock อยู่ ให้หันหน้าเข้าหา Boss ทันที

### Acceptance Criteria

- Lock OFF: Player หันตามทิศเดินเหมือนเดิม
- Lock ON: Player หันเข้าหา Boss อัตโนมัติ
- Dash ข้าม Boss แล้วหันกลับเข้าหา Boss ทันที
- ถ้า Boss ตายหรือ target หาย Lock ต้องหลุดเองอย่างปลอดภัย

---

## Phase C: เปลี่ยน Parry เป็น Movement Deflect

### เป้าหมาย

- เลิกใช้ปุ่ม Parry ใน gameplay จริง
- Deflect จากการโยก joystick ในจังหวะที่ถูกต้อง

### ไฟล์ที่เกี่ยวข้อง

```text
player.gd
touch_controls.gd
BossBrokenMaster.gd
```

### งานที่ต้องทำ

- ให้ joystick ส่งข้อมูลจังหวะเริ่มโยกหรือเปลี่ยนทิศ
- Player เก็บเวลาที่เกิด movement input ล่าสุด
- เปลี่ยน `is_parry_active()` ให้คืนค่าจาก Movement Deflect window
- ปิดการ Deflect ถ้า Player กำลัง Attack, Dash หรือ Posture Broken
- คง logic ฝั่ง Boss ที่เรียก `is_parry_active()` ไว้ก่อน เพื่อลดความเสี่ยง

### Acceptance Criteria

- ไม่มีปุ่ม Parry แต่ยัง Deflect ท่า Normal/Quick/Delayed ได้
- การโยกค้างนาน ๆ ไม่ทำให้ Deflect สำเร็จฟรี
- Heavy Slash Deflect ไม่ได้
- Boss Posture ยังลดเมื่อ Deflect สำเร็จ

---

## Phase D: เพิ่ม Player Posture

### เป้าหมาย

- ทำให้ Movement Deflect มีต้นทุน
- กันไม่ให้ผู้เล่นโยก Deflect ชนะทุกอย่าง

### ไฟล์ที่เกี่ยวข้อง

```text
player.gd
HUD.gd
scenes/main/BossBrokenMaster.tscn
```

### งานที่ต้องทำ

- เพิ่มค่า `max_player_posture`
- เพิ่มค่า `current_player_posture`
- เพิ่มระบบ regen posture
- เพิ่มฟังก์ชันลด posture
- เพิ่มสถานะ `is_posture_broken`
- เพิ่ม Player Posture Label/Bar ใน HUD
- ขยาย signal `stats_changed` ให้ส่งค่า posture เพิ่ม
- อัปเดต `HUD.gd` ให้รับค่าใหม่

### Acceptance Criteria

- HUD แสดง Player Posture
- Deflect สำเร็จแล้ว Player Posture ลดเล็กน้อย
- Deflect ผิดหรือโดน Heavy ทำให้ Player Posture ลดมาก
- Player Posture หมดแล้วผู้เล่นชะงักชั่วคราว
- หลังฟื้นตัว สามารถกลับมาเล่นต่อได้

---

## Phase E: ปรับ Tutorial และข้อความ Hint

### เป้าหมาย

- ลบคำว่า Parry ออกจากประสบการณ์ผู้เล่น
- เปลี่ยนภาษาเกมให้สอดคล้องกับระบบใหม่

### ไฟล์ที่เกี่ยวข้อง

```text
training_coach_manager.gd
duel_1_intro_manager.gd
duel_1_dummy_manager.gd
BossBrokenMaster.gd
```

### คำที่ควรเปลี่ยน

```text
PARRY!  -> DEFLECT!
Parry   -> Deflect
DASH ONLY! คงไว้หรือปรับเป็น DASH!
```

### Tutorial ใหม่ที่เสนอ

1. เดินด้วย Virtual Joystick
2. กด Attack
3. กด Dash
4. โยก joystick ในจังหวะ Boss ฟันเพื่อ Deflect
5. เห็น Heavy แล้วต้อง Dash เท่านั้น
6. กด Lock-on แล้ว Dash ข้าม Boss เพื่อทดสอบการหันกลับ

### Acceptance Criteria

- ผู้เล่นใหม่ไม่เห็นข้อความให้กดปุ่ม Parry อีก
- Tutorial สอนว่า Deflect เกิดจาก movement
- Heavy สื่อชัดว่า Dash เท่านั้น

---

## 5. ข้อเสนอเพิ่มเติม

## 5.1 เพิ่ม Lock Marker เหนือหัว Boss

เมื่อ Lock-on เปิดอยู่ ควรมีสัญลักษณ์เล็ก ๆ เหนือหัว Boss เช่น

```text
◇
LOCK
```

หรือใช้วงแหวน/เป้าเล็ง placeholder ก่อนมี asset จริง

## 5.2 เพิ่ม Perfect Deflect ในอนาคต

หลังระบบหลักนิ่งแล้ว อาจเพิ่ม Perfect Deflect เพื่อเพิ่ม skill ceiling

```text
Deflect ปกติ = ลด Boss Posture ปานกลาง ได้ Focus น้อย
Perfect Deflect = ลด Boss Posture มาก ได้ Focus มาก และ Hit Stop ชัดขึ้น
```

## 5.3 เพิ่ม Recovery Penalty ตอน Deflect พลาด

ถ้าผู้เล่นโยก Deflect เร็วเกินไปหรือผิดจังหวะ อาจมีช่วง recovery สั้น ๆ เช่น 0.12 วินาที เพื่อไม่ให้ spam movement ได้ง่ายเกินไป

## 5.4 คง Dash ให้เป็นคำตอบของท่าหนัก

ระบบควรรักษาความต่างของปุ่ม Dash ไว้เสมอ

```text
Deflect = ใช้รับท่าที่อ่านจังหวะได้
Dash    = ใช้หลบท่าหนัก / ข้ามตัว Boss / reposition
Attack  = ใช้สวนกลับหลังสร้างช่องว่าง
Lock    = ใช้คุมทิศทางและความอ่านง่ายบนมือถือ
```

---

## 6. ความเสี่ยงและสิ่งที่ต้องระวัง

### ความเสี่ยง 1: เกมง่ายเกินไป

ถ้าโยกค้างแล้ว Deflect ได้ตลอด เกมจะเสียความท้าทายทันที

วิธีลดความเสี่ยง

- นับเฉพาะจังหวะเริ่มโยกหรือเปลี่ยนทิศ
- เพิ่ม Player Posture
- ลด Focus gain จาก Deflect

### ความเสี่ยง 2: Tutorial เก่าขัดกับระบบใหม่

ถ้าหน้าจอยังบอกให้กด Parry แต่ปุ่มถูกลบแล้ว ผู้เล่นจะงงทันที

วิธีลดความเสี่ยง

- เปลี่ยนข้อความจาก `PARRY!` เป็น `DEFLECT!`
- ปรับ Training Coach หลังเปลี่ยน input หลัก

### ความเสี่ยง 3: Signal HUD พังเมื่อเพิ่ม Player Posture

`stats_changed` ปัจจุบันส่งค่าจำนวนจำกัด ถ้าเพิ่ม posture ต้องแก้จุดที่รับ signal ให้ครบ

วิธีลดความเสี่ยง

- ทำ Phase D แยกจาก Phase A/B/C
- ทดสอบ HUD ทุกครั้งหลังแก้ signal

### ความเสี่ยง 4: Lock-on ทำให้การหันหน้าชนกับระบบเดินเดิม

ถ้า Lock-on เปิดอยู่ แต่ movement ยังเปลี่ยน facing direction เอง อาจทำให้ player flip ผิดทิศ

วิธีลดความเสี่ยง

- แยก logic การหันหน้าเป็นฟังก์ชันกลาง
- ถ้า `is_target_locked == true` ให้ Lock-on มีสิทธิ์กำหนด facing สูงกว่า movement

---

## 7. ลำดับที่แนะนำให้ลงมือจริง

ลำดับที่ปลอดภัยที่สุดคือ

1. Phase A: ปรับ Touch UI เป็น Attack / Dash / Lock
2. Phase B: เพิ่ม Lock-on และระบบหันหน้าเข้าหา Boss
3. Phase C: เปลี่ยน Parry เป็น Movement Deflect โดยยังใช้ `is_parry_active()` เป็นสะพาน
4. Phase D: เพิ่ม Player Posture และ HUD
5. Phase E: ปรับ Tutorial / Duel 1 / Hint ทั้งหมด

ไม่ควรทำทุก phase ใน commit เดียว เพราะจะ debug ยาก และมีโอกาสกระทบหลายระบบพร้อมกัน

---

## 8. คำศัพท์มาตรฐานของระบบใหม่

ใช้คำเหล่านี้ให้สม่ำเสมอในโค้ด เอกสาร และ tutorial

```text
Movement Deflect = การเบี่ยงดาบด้วยการโยก movement
Lock-on          = ระบบล็อคเป้า Boss
Player Posture   = ค่าความมั่นคงของผู้เล่น
Boss Posture     = ค่าความมั่นคงของ Boss
Heavy Slash      = ท่าหนักที่ต้อง Dash หลบ
Deflect Window   = ช่วงเวลาที่ movement ยังนับเป็น Deflect ได้
```

---

## 9. สรุป

ระบบใหม่นี้ควรทำให้เกมเหมาะกับมือถือมากขึ้น เพราะลดปุ่มที่ต้องกดตรง ๆ และย้ายการตั้งรับไปผูกกับการเคลื่อนที่ แต่เพื่อไม่ให้เกมง่ายเกินไป จำเป็นต้องเพิ่ม Player Posture และกำหนดว่า Deflect ต้องเกิดจากจังหวะ movement ใหม่ ไม่ใช่การโยกค้าง

เป้าหมายสุดท้ายคือ combat loop แบบนี้

```text
อ่านท่าบอส -> Deflect หรือ Dash -> สวนกลับด้วย Attack -> ทำลาย Boss Posture -> ใช้ Focus Finisher
```

ถ้าทำตาม phase ข้างต้น จะสามารถปรับระบบต่อสู้ทีละชั้นโดยยังควบคุมความเสี่ยงของโปรเจกต์ได้
