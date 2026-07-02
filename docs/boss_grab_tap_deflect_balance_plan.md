# Boss Grab, Tap Deflect, and Anti-Cheese Balance Plan

แผนการปรับปรุงระบบต่อสู้ Phase ถัดไปสำหรับ Last Blade Trial / ดาบไร้นาม

เอกสารนี้ต่อยอดจาก `docs/mobile_combat_rework_plan.md` โดยโฟกัสที่ปัญหาหลังจากเพิ่มระบบ Lock-on, Dash-through, Movement Deflect และ Player Posture แล้ว พบว่าผู้เล่นสามารถใช้สูตร `Lock-on -> Dash -> Attack` ซ้ำ ๆ เพื่อชนะ Boss ได้ง่ายเกินไป จึงต้องเพิ่มระบบตอบโต้จาก Boss และปรับ Virtual Joystick ให้ใช้งาน Deflect ได้เป็นธรรมชาติมากขึ้นบนมือถือ

---

## 1. ปัญหาที่พบจากการทดสอบ

### 1.1 สูตร Lock-on + Dash + Attack แข็งเกินไป

หลังจากเพิ่ม Lock-on แล้ว ผู้เล่นสามารถเปิด Lock-on จากนั้นกด Dash ข้าม Boss และกด Attack ซ้ำ ๆ ได้ง่ายมาก เพราะระบบช่วยให้ Player หันหน้ากลับเข้าหา Boss ทันทีหลัง Dash

ผลที่เกิดขึ้นคือ

```text
Lock-on ช่วยหันหน้า -> Dash ข้าม Boss -> Attack โดนง่าย -> ทำซ้ำจนชนะ
```

ปัญหานี้ทำให้ผู้เล่นไม่จำเป็นต้องอ่านท่า Boss มากนัก และทำให้ Heavy / Delayed / Deflect เสียความสำคัญลง

### 1.2 Boss ยังไม่มีท่าลงโทษการอยู่ประชิดหรือวนหลัง

Boss ปัจจุบันมีท่าหลัก เช่น

- Normal Slash
- Quick Slash
- Delayed Slash
- Heavy Slash

แต่ยังไม่มีท่าเฉพาะสำหรับลงโทษผู้เล่นที่อยู่ประชิดเกินไป หรือ Dash ข้ามไปด้านหลังซ้ำ ๆ

### 1.3 Virtual Joystick ต้องแตะแล้ว Deflect ได้โดยไม่ต้องเดิน

ระบบ Movement Deflect ปัจจุบันเน้นการโยกซ้าย/ขวา แต่บนมือถือ ผู้เล่นอาจต้องการแตะ Virtual Joystick เพื่อ Deflect แบบอยู่กับที่ โดยไม่จำเป็นต้องเคลื่อนที่

สิ่งที่ต้องการคือ

```text
แตะ joystick ตรง ๆ = เปิด Deflect Window
ลาก joystick ซ้าย/ขวา = เดิน + เปิด Deflect Window
แตะค้าง = ไม่ต่ออายุ Deflect Window
```

---

## 2. เป้าหมายของแผนนี้

### เป้าหมายด้าน Gameplay

- ทำให้ Lock-on ยังมีประโยชน์ แต่ไม่ใช่สูตรชนะอัตโนมัติ
- เพิ่ม Boss Grab เพื่อใช้ลงโทษผู้เล่นที่อยู่ประชิดหรือ Dash ข้าม Boss ซ้ำ ๆ
- เพิ่ม Tap Deflect เพื่อให้ Virtual Joystick ใช้ป้องกันได้โดยไม่ต้องเดิน
- รักษาความชัดเจนของ combat loop

### เป้าหมายด้าน Mobile UX

- ลดภาระการกดหลายปุ่มบนมือถือ
- ให้ joystick เป็นศูนย์กลางของการเคลื่อนที่และการตั้งรับ
- ทำให้การ Deflect ด้วยการแตะรู้สึกเป็นธรรมชาติ แต่ยังต้องจับจังหวะ

### เป้าหมายด้าน Balance

- Dash ต้องยังสำคัญ แต่ไม่ควรปลอดภัยฟรีทุกสถานการณ์
- Attack หลัง Dash ต้องยังใช้ได้ แต่ต้องมีความเสี่ยงเมื่อใช้ซ้ำโดยไม่อ่าน Boss
- Deflect ต้องง่ายพอสำหรับมือถือ แต่ต้องมีต้นทุนจาก Player Posture

---

## 3. ระบบใหม่ที่เสนอ

## 3.1 Boss Grab Pattern

### ชื่อระบบ

ใน code ใช้ชื่อ pattern ว่า

```text
grab
```

หรือ

```text
broken_master_grab
```

ใน UI / hint อาจใช้ข้อความว่า

```text
GRAB!
```

หรือถ้าต้องการบอกวิธีแก้ให้ผู้เล่นชัดขึ้น ใช้

```text
BACK!
```

แนะนำให้เริ่มจาก `BACK!` สำหรับผู้เล่นใหม่ เพราะสื่อชัดว่าต้องถอยออก

### หน้าที่ของ Grab

Grab มีหน้าที่เป็น Anti-Cheese Move สำหรับแก้สูตร

```text
Lock-on -> Dash-through -> Attack spam
```

Grab ไม่ควรเป็นท่าที่สุ่มออกตลอดเวลา แต่ควรออกเมื่อผู้เล่นทำพฤติกรรมเสี่ยง เช่น

- อยู่ประชิด Boss นานเกินไป
- Dash ข้าม Boss แล้วจบใกล้ Boss
- วนหลัง Boss ซ้ำ ๆ
- เปิด Lock-on แล้วใช้ Dash/Attack แบบซ้ำ ๆ

### คุณสมบัติของ Grab

```text
Deflect ไม่ได้
Dash หลบได้ ถ้าออกจากระยะทัน
เดินถอยออกได้ ถ้าอ่าน hint ทัน
สร้าง Player Posture damage สูงกว่าดาเมจ HP
ใช้ลงโทษการอยู่ประชิด ไม่ใช่ฆ่าผู้เล่นทันที
```

### ค่าเริ่มต้นที่เสนอ

```gdscript
grab_chance = 0.18
grab_close_range = 72.0
grab_windup_time = 0.55
grab_active_time = 0.18
grab_damage = 12
grab_posture_damage = 42.0
grab_cooldown_bonus = 0.35
grab_min_attacks_between_uses = 1
```

### เงื่อนไขเลือก Grab

Grab ควรมี 2 แบบการเลือก

#### แบบที่ 1: Close-range Opportunistic Grab

ถ้า Player อยู่ใกล้เกินระยะ `grab_close_range` และ Boss พร้อมโจมตี มีโอกาสเลือก Grab สูงขึ้น

```text
ถ้า distance_to_player <= grab_close_range:
    เพิ่มโอกาสเลือก grab
```

#### แบบที่ 2: Anti-Dash Grab

ถ้า Player เพิ่ง Dash จบภายในช่วงเวลาสั้น ๆ และอยู่ใกล้ Boss ให้เพิ่มโอกาส Grab

```text
ถ้า Player เพิ่ง Dash จบใน 0.35 วินาที
และอยู่ใกล้ Boss
    เพิ่มโอกาสเลือก grab
```

### วิธีรับมือ Grab

ผู้เล่นควรแก้ Grab ด้วย

```text
ถอยออกจากระยะด้วย joystick
Dash ออกห่างก่อน active frame
อย่าอยู่ประชิด Boss หลังโจมตี
```

Grab ไม่ควรถูก Deflect ได้ เพราะถ้า Deflect ได้ ผู้เล่นจะใช้ Tap Deflect แก้ทุกอย่างอีกครั้ง

---

## 3.2 Tap Deflect บน Virtual Joystick

### แนวคิด

เพิ่มความสามารถให้ Virtual Joystick โดยให้การแตะลงบน joystick area เปิด Deflect Window ได้ทันที แม้ยังไม่ได้ลากซ้ายหรือขวา

### พฤติกรรมที่ต้องการ

```text
แตะ joystick ลง 1 ครั้ง = เปิด Tap Deflect Window
ลาก joystick ซ้าย/ขวา = เดิน + เปิด Movement Deflect Window
แตะค้างอยู่เฉย ๆ = ไม่ refresh window
ปล่อยแล้วแตะใหม่ = ได้ window ใหม่
```

### เหตุผล

บนมือถือ การบังคับให้ผู้เล่นลากซ้าย/ขวาทุกครั้งเพื่อ Deflect อาจไม่เป็นธรรมชาติ โดยเฉพาะจังหวะที่ผู้เล่นยืนรออ่านท่า Boss อยู่ การแตะ joystick เพื่อ Deflect จะรู้สึกเหมือนการตั้งรับมากกว่า

### ค่าเริ่มต้นที่เสนอ

```gdscript
tap_deflect_window = 0.22
movement_deflect_window = 0.28
posture_damage_on_tap_deflect = 16.0
posture_damage_on_movement_deflect = 14.0
```

Tap Deflect ควรมี window สั้นกว่า Movement Deflect เล็กน้อย เพราะใช้ง่ายกว่าและไม่ต้อง reposition

### ข้อจำกัดสำคัญ

Tap Deflect ต้องไม่กลายเป็นปุ่มกันฟรี

ดังนั้นต้องห้ามพฤติกรรมนี้

```text
แตะ joystick ค้างแล้ว Deflect ได้ตลอดเวลา
```

ระบบต้องนับเฉพาะจังหวะ `touch pressed` หรือ `mouse pressed` เท่านั้น ไม่ใช่ทุก frame ที่นิ้วยังค้างอยู่

---

## 3.3 Dash Landing Risk

### แนวคิด

เพิ่มความเสี่ยงสั้น ๆ หลัง Dash จบ เพื่อไม่ให้ Dash-through เป็นคำตอบฟรีทุกสถานการณ์

### สถานะที่เสนอ

เพิ่มสถานะใน Player

```gdscript
is_dash_landing_recovering
last_dash_end_msec
```

หรือถ้าต้องการไม่เพิ่ม state เยอะ ให้ใช้แค่ timestamp

```gdscript
last_dash_end_msec
```

### พฤติกรรมที่ต้องการ

หลัง Dash จบในช่วงเวลาสั้น ๆ เช่น 0.20–0.35 วินาที Boss จะอ่านว่า Player อยู่ในช่วง Dash Landing Risk

Boss อาจใช้ข้อมูลนี้เพื่อเพิ่มโอกาส Grab

```text
ถ้า Player เพิ่ง Dash จบ และอยู่ใกล้ Boss:
    เพิ่มโอกาสเลือก grab
```

### สิ่งที่ไม่ควรทำในรอบแรก

ยังไม่ควรทำให้ Player โจมตีไม่ได้หลัง Dash ทันที เพราะอาจทำให้เกมรู้สึกหน่วงเกินไป

รอบแรกควรให้ Boss ใช้ข้อมูลนี้ในการเลือก Grab ก่อน ไม่ใช่ nerf input ของ Player โดยตรง

---

## 3.4 Boss Anti-Repetition Memory

### แนวคิด

เพิ่มระบบจำพฤติกรรมผู้เล่นแบบเบา ๆ เพื่อให้ Boss ตอบโต้สูตรซ้ำ ๆ ได้ โดยไม่ต้องทำ AI ซับซ้อน

### พฤติกรรมที่ควรจำ

```text
recent_dash_count
recent_attack_count
recent_deflect_count
last_player_dash_end_msec
last_player_attack_msec
last_player_deflect_msec
```

### การใช้งาน

ถ้า Player Dash บ่อยในช่วง 3–5 วินาที

```text
เพิ่มโอกาส grab
```

ถ้า Player Deflect บ่อย

```text
เพิ่มโอกาส delayed_slash หรือ heavy_slash
```

ถ้า Player Attack รัว

```text
เพิ่มโอกาส quick_slash หรือ grab ถ้าอยู่ใกล้
```

### ข้อดี

- ทำให้ Boss ดูเหมือนอ่านผู้เล่นได้
- ไม่ต้องสร้าง AI ซับซ้อน
- ใช้แก้สูตรซ้ำ ๆ ได้ดี

### ข้อควรระวัง

อย่าให้ Boss counter ผู้เล่นแรงเกินไปทุกครั้ง เพราะจะรู้สึกไม่ยุติธรรม ควรใช้เป็นการเพิ่มโอกาส ไม่ใช่บังคับท่าตลอด

---

## 4. Combat Answer Matrix ใหม่

ตารางนี้ใช้กำหนดว่าผู้เล่นควรตอบสนองท่า Boss อย่างไร

| Boss Pattern | Hint | Deflect ได้ไหม | วิธีรับมือหลัก | บทบาทในเกม |
|---|---|---:|---|---|
| Normal Slash | DEFLECT! | ได้ | Tap/Movement Deflect | ท่าพื้นฐานสำหรับสอนจังหวะ |
| Quick Slash | DEFLECT! | ได้ | Deflect เร็ว | ทดสอบ reaction |
| Delayed Slash | WAIT... -> DEFLECT! | ได้เฉพาะช่วงท้าย | รอแล้ว Deflect | หลอกผู้เล่นที่รีบกด |
| Heavy Slash | DASH! | ไม่ได้ | Dash หลบ | บังคับใช้ Dash |
| Grab | BACK! หรือ GRAB! | ไม่ได้ | ถอย / Dash ออกห่าง | ลงโทษการประชิดและ Dash spam |

---

## 5. Phase Plan

## Phase A: เพิ่ม Tap Deflect

### เป้าหมาย

ทำให้ Virtual Joystick แตะตรง ๆ แล้วเปิด Deflect Window ได้ โดยไม่ต้องลากซ้าย/ขวา

### ไฟล์ที่เกี่ยวข้อง

```text
last-blade-trial/touch_controls.gd
last-blade-trial/player.gd
```

### งานที่ต้องทำ

- เพิ่มฟังก์ชันใน Player เช่น `register_tap_deflect_input()`
- เพิ่ม timestamp สำหรับ tap deflect เช่น `last_tap_deflect_msec`
- เพิ่ม export `tap_deflect_window`
- แก้ `is_movement_deflect_active()` หรือแยกเป็น `is_deflect_active()` ให้รองรับทั้ง movement และ tap
- ใน `touch_controls.gd` เมื่อ joystick area รับ `InputEventScreenTouch.pressed` ให้เรียก `register_tap_deflect_input()` ทันที
- ห้าม refresh window ระหว่างนิ้วค้าง ต้อง refresh เฉพาะตอน touch pressed ใหม่

### Acceptance Criteria

- แตะ joystick ตรงกลางแล้ว Deflect ได้ถ้าจังหวะถูก
- แตะค้างไม่ทำให้ Deflect ได้ตลอดเวลา
- ลาก joystick ซ้าย/ขวายังเดินและ Deflect ได้เหมือนเดิม
- Heavy และ Grab ในอนาคต Deflect ไม่ได้

---

## Phase B: เพิ่ม Boss Grab Pattern

### เป้าหมาย

เพิ่มท่า Grab เพื่อแก้สูตร Lock-on + Dash + Attack

### ไฟล์ที่เกี่ยวข้อง

```text
last-blade-trial/BossBrokenMaster.gd
```

### งานที่ต้องทำ

เพิ่ม export variables

```gdscript
grab_chance
grab_close_range
grab_windup_time
grab_active_time
grab_damage
grab_posture_damage
grab_cooldown_bonus
grab_min_attacks_between_uses
```

เพิ่ม state

```gdscript
current_attack_is_grab
attacks_since_last_grab
```

เพิ่ม pattern ใน `apply_attack_pattern()`

```text
grab
```

เพิ่ม logic เลือก Grab ใน `choose_random_attack_pattern()` โดยให้โอกาส Grab สูงขึ้นเมื่อ Player อยู่ใกล้หรือเพิ่ง Dash

เพิ่ม hit resolution ใน `_try_hit_area()`

```text
ถ้า current_attack_is_grab:
    ไม่เช็ก parry/deflect
    ทำ grab damage
    ลด Player Posture หนัก
```

### Acceptance Criteria

- Boss สามารถออกท่า Grab ได้เมื่อ Player อยู่ใกล้
- Grab แสดง hint `BACK!` หรือ `GRAB!`
- Grab Deflect ไม่ได้
- Grab ลงโทษผู้เล่นที่ยืนประชิดหรือ Dash ข้าม Boss ซ้ำ ๆ
- Grab ไม่ออกถี่เกินไปจนรู้สึก unfair

---

## Phase C: เพิ่ม Dash Landing Risk

### เป้าหมาย

ทำให้ Boss รู้ว่า Player เพิ่ง Dash จบ เพื่อเพิ่มโอกาส Grab

### ไฟล์ที่เกี่ยวข้อง

```text
last-blade-trial/player.gd
last-blade-trial/BossBrokenMaster.gd
```

### งานที่ต้องทำ

ใน Player เพิ่ม

```gdscript
last_dash_end_msec
func get_time_since_last_dash_end() -> float
func is_in_dash_landing_risk_window() -> bool
```

ใน Boss เพิ่มเงื่อนไข

```text
ถ้า player.is_in_dash_landing_risk_window() และอยู่ใกล้:
    เพิ่มโอกาส grab
```

### Acceptance Criteria

- Dash ยังคงใช้หลบ Heavy ได้ดี
- Dash ข้าม Boss แล้ว Attack ซ้ำ ๆ มีโอกาสโดน Grab มากขึ้น
- ไม่ทำให้ Player รู้สึกควบคุมหน่วงเกินไป

---

## Phase D: เพิ่ม Anti-Repetition Memory แบบเบา ๆ

### เป้าหมาย

ให้ Boss ตอบโต้พฤติกรรมซ้ำของผู้เล่นแบบไม่ซับซ้อน

### ไฟล์ที่เกี่ยวข้อง

```text
last-blade-trial/player.gd
last-blade-trial/BossBrokenMaster.gd
```

### งานที่ต้องทำ

เพิ่ม timestamp/event counter ใน Player

```gdscript
last_attack_msec
last_deflect_msec
recent_dash_count
recent_attack_count
recent_deflect_count
```

หรือทำแบบง่ายกว่าใน Boss โดยอ่านจาก Player เฉพาะ

```gdscript
last_dash_end_msec
last_successful_deflect_msec
```

ใช้ข้อมูลนี้เพิ่มโอกาส pattern

```text
Dash บ่อย -> Grab
Deflect บ่อย -> Delayed / Heavy
Attack บ่อย -> Quick / Grab
```

### Acceptance Criteria

- Boss ไม่ถูก cheese ด้วยพฤติกรรมเดิมซ้ำ ๆ ง่ายเกินไป
- Boss ยังไม่รู้สึก unfair หรืออ่านใจผู้เล่นเกินไป
- สามารถปิด/เปิดระบบนี้ด้วย export ได้เพื่อ debug

---

## Phase E: Balance Pass หลังทดสอบมือถือจริง

### ค่าที่ต้องทดสอบ

```text
grab_chance
grab_close_range
grab_windup_time
grab_damage
grab_posture_damage
tap_deflect_window
movement_deflect_window
posture_damage_on_tap_deflect
posture_damage_on_movement_deflect
dash_cooldown
attack_stamina_cost
```

### วิธีทดสอบ

ทดสอบบนมือถือจริงด้วยสถานการณ์เหล่านี้

1. เปิด Lock-on แล้ว Dash ข้าม Boss รัว ๆ
2. Dash ข้ามแล้ว Attack ทันทีซ้ำ ๆ
3. ยืนประชิด Boss แล้ว Attack รัว
4. แตะ joystick เพื่อ Deflect โดยไม่เดิน
5. แตะค้าง joystick ดูว่าไม่ Deflect ฟรี
6. เจอ Heavy แล้วลอง Tap Deflect เพื่อยืนยันว่าโดนลงโทษ
7. เจอ Grab แล้วลองถอย / Dash ออกห่าง

---

## 6. Design Rules ที่ต้องยึด

### Rule 1: Lock-on ต้องช่วย ไม่ใช่ชนะให้

Lock-on ควรช่วยคุมทิศทางบนมือถือ แต่ไม่ควรทำให้ Dash + Attack กลายเป็นสูตรชนะ

### Rule 2: Deflect ต้องง่ายขึ้น แต่ไม่ฟรี

Tap Deflect ทำให้มือถือเล่นง่ายขึ้น แต่ต้องใช้จังหวะและเสีย Posture เมื่อสำเร็จ

### Rule 3: Grab ต้องลงโทษการประชิด ไม่ใช่ลงโทษผู้เล่นมั่ว ๆ

Grab ควรเกิดบ่อยขึ้นเมื่อผู้เล่นอยู่ใกล้หรือ Dash spam แต่ไม่ควรสุ่มไกล ๆ โดยไม่มีเหตุผล

### Rule 4: Dash ต้องยังเป็นคำตอบของ Heavy

แม้จะเพิ่ม Grab และ Dash Landing Risk แต่ Dash ต้องยังเป็นเครื่องมือสำคัญสำหรับหลบท่าหนัก

### Rule 5: Boss ต้องอ่านพฤติกรรมซ้ำ แต่ไม่อ่านใจ

Anti-Repetition Memory ควรเพิ่มโอกาส counter ไม่ใช่บังคับ counter 100%

---

## 7. ลำดับลงมือที่แนะนำ

ลำดับที่ปลอดภัยที่สุดคือ

```text
1. Phase A: Tap Deflect
2. Phase B: Boss Grab Pattern
3. Phase C: Dash Landing Risk
4. Phase D: Anti-Repetition Memory
5. Phase E: Balance Pass บนมือถือจริง
```

ไม่ควรทำทุก phase ใน commit เดียว เพราะระบบนี้กระทบ combat loop หลัก ถ้าเกิด bug จะหาสาเหตุยาก

---

## 8. สรุป

เป้าหมายของแผนนี้คือแก้ปัญหาที่ Player ใช้ Lock-on, Dash และ Attack ซ้ำ ๆ จนชนะง่ายเกินไป โดยไม่ทำลายความลื่นของระบบมือถือ

ระบบที่ควรเพิ่มคือ

```text
Tap Deflect = แตะ joystick เพื่อ Deflect โดยไม่ต้องเดิน
Boss Grab = ลงโทษการอยู่ประชิดและ Dash spam
Dash Landing Risk = ทำให้ Dash-through มีความเสี่ยงถ้าใช้มั่ว
Anti-Repetition Memory = ทำให้ Boss ตอบโต้สูตรซ้ำได้อย่างเป็นธรรมชาติ
```

Combat loop หลังปรับควรเป็น

```text
อ่านท่า Boss -> Deflect / Dash / ถอยออก -> สวนกลับ -> ระวัง Grab เมื่ออยู่ประชิด -> ทำลาย Posture -> ใช้ Finisher
```

ถ้าทำตามลำดับ phase นี้ เกมจะยังเล่นง่ายขึ้นบนมือถือ แต่จะไม่ง่ายจนกลายเป็นการกดสูตรเดียวชนะ
