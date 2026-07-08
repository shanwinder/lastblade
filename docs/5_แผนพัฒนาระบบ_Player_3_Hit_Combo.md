# แผนพัฒนาระบบ Player 3-Hit Combo

เกม: **Last Blade Trial / ดาบไร้นาม**  
ระบบที่พัฒนา: **Player Attack Combo System**  
ตัวละคร: **The Nameless Blade / ดาบไร้นาม**  
สถานะเอกสาร: แผนออกแบบก่อนลงมือแก้โค้ด  

---

## 1. เป้าหมายของระบบ

ระบบเดิมของ Player เป็นการโจมตีแบบกดปุ่ม `attack` หนึ่งครั้งแล้วออกท่าโจมตีจังหวะเดียว หลังจากนั้นต้องรอ recovery ก่อนจึงจะโจมตีใหม่ได้

ระบบใหม่จะเพิ่มการโจมตีแบบ 3-hit combo โดยยังใช้ปุ่มเดิมเพียงปุ่มเดียว:

```text
กด attack 1 ครั้ง  = โจมตีธรรมดา 1 จังหวะ / 1 hit
กด attack 2 ครั้ง  = โจมตีต่อเนื่อง 2 จังหวะ / 2 hit
กด attack 3 ครั้ง  = โจมตีต่อเนื่อง 3 จังหวะ / 3 hit
```

จุดสำคัญคือ Hit 3 ต้องเป็นทางเลือกที่มีความเสี่ยง ไม่ใช่รางวัลฟรี

ดังนั้น Hit 3 จะมี:

```text
- damage หรือ posture pressure สูงกว่า Hit 1 และ Hit 2
- recovery ท้ายท่านานกว่าชัดเจน
- cancel ได้ยากหรือ cancel ไม่ได้
- ถ้าใช้ผิดจังหวะจะเสี่ยงโดน Boss สวนหรือ Grab
```

---

## 2. สภาพระบบปัจจุบันที่เกี่ยวข้อง

### 2.1 Player attack logic ปัจจุบัน

ไฟล์หลัก:

```text
last-blade-trial/player.gd
```

ระบบปัจจุบันมีฟังก์ชัน `attack()` ที่ทำงานเป็นลำดับเดียว:

```text
เช็ก stamina
→ ลด stamina
→ is_attacking = true
→ clear hit_targets
→ เปิด attack hitbox
→ รอ attack_active_time
→ ปิด attack hitbox
→ รอ attack_recovery_time
→ is_attacking = false
```

ปัญหาสำหรับระบบคอมโบคือ logic นี้ออกแบบมาเพื่อโจมตีครั้งเดียว ไม่ได้รองรับการเก็บ input ต่อเนื่องหรือเลือก animation ตามลำดับ hit

### 2.2 Input ปัจจุบัน

ใน `_physics_process()` ตอนนี้ Player โจมตีเมื่อ:

```text
Input.is_action_just_pressed("attack")
และ not is_attacking
และ not is_dashing
และ not is_posture_broken
```

แปลว่าในระบบเดิม ถ้ากด attack ระหว่างกำลังโจมตีอยู่ input จะถูกเมินทันที

ระบบใหม่ต้องเปลี่ยนแนวคิดจาก:

```text
กด attack ได้เฉพาะตอนว่างเท่านั้น
```

เป็น:

```text
ถ้าว่าง → เริ่มคอมโบ
ถ้ากำลังโจมตีและอยู่ในช่วงรับ input → queue hit ถัดไป
```

### 2.3 Visual animation ปัจจุบัน

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

ปัจจุบัน visual manager รองรับ animation โจมตีหลักเพียงชุดเดียว:

```text
attack_animation_name = "attack_1"
attack_frames_folder = "res://assets/sprites/player/nameless_blade/frames/attack_1"
```

และเมื่อ Player อยู่ในสถานะ `is_attacking` จะเลือกเล่น `attack_1` เสมอ

ระบบใหม่ต้องขยาย visual manager ให้รองรับอย่างน้อย 3 animation:

```text
attack_1
attack_2
attack_3
```

หรือมีระบบอ่าน `current_combo_step` จาก Player แล้วเลือก animation ตาม hit ปัจจุบัน

---

## 3. หลักออกแบบสำคัญ

### 3.1 ไม่ทำให้เกมกลายเป็นกดรัว

ระบบนี้ไม่ควรเป็น:

```text
กด attack รัว ๆ แล้วเกมเล่น 3-hit ให้เองเสมอ
```

แต่ควรเป็น:

```text
ผู้เล่นกดต่อในช่วงเวลาที่ระบบเปิดให้ chain เท่านั้น
```

เหตุผลคือ Last Blade Trial เป็นเกมดวลดาบกับบอส ไม่ใช่ hack-and-slash ผู้เล่นควรอ่านจังหวะบอสก่อนตัดสินใจว่าจะโจมตีต่อหรือหยุด

### 3.2 Hit 3 ต้องเป็น commitment

Hit 3 ควรเป็นจังหวะที่ผู้เล่นตั้งใจเสี่ยงเพื่อผลตอบแทนสูงขึ้น

แนวคิด:

```text
Hit 1 = ปลอดภัยที่สุด ใช้เช็กระยะ
Hit 2 = ยืนยันว่าจะกดดันต่อ
Hit 3 = โลภเพื่อรางวัล แต่ recovery ยาวและโดนสวนง่าย
```

### 3.3 ต้องเข้ากับระบบ Boss Grab

ระบบ Grab ปัจจุบันถูกออกแบบมาเพื่อลงโทษผู้เล่นที่อยู่ประชิดบอสหรือ dash/attack ใกล้บอสมากเกินไป

ดังนั้น Hit 3 ควรสร้างสถานการณ์ให้ Boss Grab มีความหมาย เช่น:

```text
ผู้เล่นกด Hit 3 ใกล้บอส
→ ถ้า Hit 3 whiff หรือบอสไม่อยู่ใน recovery
→ ผู้เล่นติด recovery นาน
→ Boss มีโอกาส Grab หรือโจมตีสวน
```

---

## 4. พฤติกรรมเป้าหมายของระบบ Combo

### 4.1 Flow หลัก

```text
สถานะเริ่มต้น: combo_step = 0, is_attacking = false

ผู้เล่นกด attack
→ ถ้าไม่ได้โจมตีอยู่ ให้เริ่ม Hit 1

ระหว่าง Hit 1
→ ถ้ากด attack ในช่วง combo input window ให้ queue Hit 2
→ ถ้าไม่กดต่อ ให้จบคอมโบหลัง recovery ของ Hit 1

ระหว่าง Hit 2
→ ถ้ากด attack ในช่วง combo input window ให้ queue Hit 3
→ ถ้าไม่กดต่อ ให้จบคอมโบหลัง recovery ของ Hit 2

ระหว่าง Hit 3
→ ไม่มี hit ถัดไป
→ เล่น recovery ยาว
→ จบคอมโบและคืน control
```

### 4.2 การกด attack นอกช่วง window

ถ้าผู้เล่นกดเร็วเกินไปหรือช้าเกินไป ไม่ควรให้ combo ต่อแบบอัตโนมัติ

แนวทางที่แนะนำ:

```text
กดเร็วเกินไปก่อนเปิด input window
→ อาจ queue ได้แบบ input buffer สั้น ๆ ถ้าต้องการให้มือถือเล่นง่าย

กดช้าเกินไปหลังปิด input window
→ ไม่ต่อ combo และรอจน Player ว่างก่อนค่อยเริ่ม Hit 1 ใหม่
```

สำหรับมือถือ แนะนำให้มี input buffer เล็กน้อยเพื่อให้ระบบไม่รู้สึกแข็งเกินไป

---

## 5. ค่าบาลานซ์เริ่มต้นที่แนะนำ

ค่าต่อไปนี้เป็น baseline สำหรับทดลอง ไม่ใช่ค่าสุดท้าย

| Combo Hit | Damage | Stamina Cost | Active Time | Recovery | Chain Window | บทบาท |
|---|---:|---:|---:|---:|---:|---|
| Hit 1 | 10 | 18 | 0.16–0.18 | 0.18–0.22 | 0.35 | ปลอดภัย ใช้เช็กระยะ |
| Hit 2 | 10–12 | 18 | 0.18 | 0.24–0.30 | 0.35 | กดดันต่อเนื่อง |
| Hit 3 | 16–20 | 24–28 | 0.20–0.24 | 0.65–0.85 | 0.00 | ท่าหนัก เสี่ยงสูง |

หลักคิด:

```text
Hit 1 ไม่ควรแรงเกินไป เพราะเป็นท่าปลอดภัย
Hit 2 ควรดีพอให้ผู้เล่นอยากกดต่อ
Hit 3 ควรมีรางวัลชัด แต่ recovery ต้องยาวพอให้บอสลงโทษได้
```

ถ้าภายหลังมีระบบ Player posture damage ต่อ Boss แบบแยกจาก HP damage ควรให้ Hit 3 เด่นที่ posture damage มากกว่า HP damage

---

## 6. โครง asset ที่แนะนำ

ควรแยก asset ตาม hit เพื่อให้ระบบเลือกเล่น animation ได้ชัดเจน

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/attack_1/
last-blade-trial/assets/sprites/player/nameless_blade/frames/attack_2/
last-blade-trial/assets/sprites/player/nameless_blade/frames/attack_3/
```

หลัก naming:

```text
attack_1_0001.png
attack_1_0002.png
attack_1_0003.png

attack_2_0001.png
attack_2_0002.png
attack_2_0003.png

attack_3_0001.png
attack_3_0002.png
attack_3_0003.png
```

ถ้า export เป็น sprite sheet ควรตัดเป็น frame แยกก่อน เพื่อให้ระบบ runtime loader ปัจจุบันต่อยอดง่าย

---

## 7. โครงระบบที่ควรเพิ่มใน player.gd

### 7.1 ตัวแปรสถานะ combo

ควรเพิ่มแนวคิดของ state เหล่านี้:

```text
combo_enabled
combo_step
queued_combo_step
combo_input_buffered
is_combo_recovering
combo_sequence_id
```

คำอธิบาย:

```text
combo_enabled
= เปิด/ปิดระบบ combo เพื่อ rollback ได้ง่าย

combo_step
= hit ปัจจุบัน เช่น 0, 1, 2, 3

queued_combo_step
= hit ถัดไปที่ผู้เล่นกดจองไว้

combo_input_buffered
= บันทึกว่าผู้เล่นกด attack ระหว่างช่วงรับ input หรือไม่

is_combo_recovering
= ใช้แยกระหว่าง active/recovery เฉพาะ combo

combo_sequence_id
= ใช้ยกเลิก coroutine เก่าเวลาตาย โดน posture break หรือถูก interrupt
```

### 7.2 ฟังก์ชันที่ควรแยกใหม่

แทนที่จะให้ `attack()` ทำทุกอย่าง ควรแยกเป็นหลายหน้าที่:

```text
try_attack_input()
start_combo()
queue_next_combo_hit()
perform_combo_hit(step)
open_attack_hitbox_for_combo_step(step)
finish_combo()
cancel_combo(reason)
```

หลักคิด:

```text
attack() เดิมควรถูกลดบทบาทให้เป็น entry point
ส่วน logic จริงของ combo ควรถูกแยกเป็น state machine
```

---

## 8. Input design

### 8.1 ตอน Player ว่าง

```text
กด attack
→ เช็ก stamina ของ Hit 1
→ เริ่ม combo_step 1
```

### 8.2 ตอน Player กำลังโจมตี

```text
กด attack ระหว่าง Hit 1 และอยู่ใน chain window
→ queue Hit 2

กด attack ระหว่าง Hit 2 และอยู่ใน chain window
→ queue Hit 3

กด attack ระหว่าง Hit 3
→ ไม่ทำอะไร เพราะไม่มี hit ถัดไป
```

### 8.3 ตอน Player โดนสถานะอื่น

ถ้าเกิดสถานะเหล่านี้ระหว่าง combo ต้องยกเลิก combo ทันที:

```text
Player ตาย
Player posture broken
Player ถูก grab
Player ถูก knockback
Player dash
scene restart
```

---

## 9. Hitbox และ damage design

### 9.1 hit_targets ต้องแยกต่อ hit

ปัจจุบัน `hit_targets` ถูก clear ตอนเริ่ม attack เดี่ยว

ระบบใหม่ต้อง clear ทุกครั้งที่เริ่ม hit ใหม่ ไม่ใช่ clear แค่ตอนเริ่ม combo ทั้งชุด

เหตุผล:

```text
ถ้า Hit 1 โดน Boss แล้วบันทึก Boss ใน hit_targets
และ Hit 2 ไม่ clear hit_targets
Hit 2 จะไม่ทำ damage เพราะ Boss ถูกนับว่าโดนไปแล้ว
```

หลักที่ถูกต้อง:

```text
Hit 1 มี hit_targets ของ Hit 1
Hit 2 มี hit_targets ของ Hit 2
Hit 3 มี hit_targets ของ Hit 3
```

### 9.2 Damage ต้องรู้ว่าอยู่ hit ไหน

ตอน `_on_attack_hitbox_area_entered()` เรียกทำ damage ต้องรู้ว่า currently active combo step คืออะไร

แนวคิด:

```text
current_combo_step_for_damage = 1 / 2 / 3
```

แล้วเลือก damage จากตาราง combo

---

## 10. Visual manager ที่ควรปรับ

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

### 10.1 จาก animation เดียวเป็นหลาย animation

ปัจจุบันมี:

```text
attack_animation_name = "attack_1"
attack_frames_folder = ".../attack_1"
```

ควรปรับเป็นแนวคิด:

```text
attack_1_animation_name = "attack_1"
attack_2_animation_name = "attack_2"
attack_3_animation_name = "attack_3"

attack_1_frames_folder = ".../attack_1"
attack_2_frames_folder = ".../attack_2"
attack_3_frames_folder = ".../attack_3"
```

### 10.2 การเลือก animation

เมื่อ Player กำลังโจมตี ให้ visual manager อ่านค่า `combo_step`

```text
combo_step = 1 → เล่น attack_1
combo_step = 2 → เล่น attack_2
combo_step = 3 → เล่น attack_3
```

ถ้า `combo_step` ไม่มี หรือ asset ยังไม่ครบ ให้ fallback เป็น `attack_1`

### 10.3 การเล่น animation ไม่ควร replay ซ้ำ

ท่าโจมตีทุก hit ควรเป็น non-loop animation

```text
attack_1 loop = false
attack_2 loop = false
attack_3 loop = false
```

เมื่อ animation จบระหว่าง recovery ให้ค้างเฟรมท้ายจนกว่า Player จะจบ recovery เพื่อให้ภาพไม่เด้งกลับ idle เร็วเกินไป

---

## 11. Dash cancel และความเสี่ยง

แนวทางที่แนะนำ:

```text
Hit 1:
- หลัง active frame จบ อาจอนุญาตให้ dash cancel ได้
- ใช้สำหรับโจมตีแล้วถอย

Hit 2:
- หลัง active frame จบ อาจอนุญาตให้ dash cancel ได้แบบจำกัด
- ยังมีความเสี่ยงมากกว่า Hit 1

Hit 3:
- ไม่ควร dash cancel ระหว่าง recovery
- ต้องยอมรับ recovery ยาว
```

เหตุผล:

```text
ถ้า Hit 3 dash cancel ได้ง่าย ข้อเสียของท่าจะหายไป
และผู้เล่นจะกด 3-hit เป็นค่า default โดยไม่ต้องคิด
```

---

## 12. ความสัมพันธ์กับ Boss AI

ระบบ combo ควรทำให้ Boss อ่านและลงโทษผู้เล่นได้มากขึ้น ไม่ใช่น้อยลง

### 12.1 กรณีที่ผู้เล่นควรได้เปรียบ

```text
Boss เพิ่งฟันพลาด
Boss อยู่ recovery
Boss posture broken
Boss staggered
ผู้เล่นอยู่ในระยะพอดีและ stamina พร้อม
```

ในสถานการณ์นี้ Hit 2 หรือ Hit 3 ควรเป็นรางวัลที่สมเหตุสมผล

### 12.2 กรณีที่ผู้เล่นควรถูกลงโทษ

```text
ผู้เล่นกด Hit 3 ตอนบอสยังพร้อมโจมตี
ผู้เล่นกด Hit 3 แล้ว whiff
ผู้เล่นกดคอมโบจน stamina ต่ำ
ผู้เล่นยืนประชิดนานเกินไป
```

ในสถานการณ์นี้ Boss Grab หรือท่าเร็วควรลงโทษได้

---

## 13. Phase การพัฒนา

### Phase 1: เตรียม asset และ loader

เป้าหมาย:

```text
ให้เกมรู้จัก animation attack_1, attack_2, attack_3
```

งานที่ต้องทำ:

```text
1. จัด asset เป็นโฟลเดอร์ attack_1 / attack_2 / attack_3
2. ขยาย visual manager ให้โหลด animation หลายโฟลเดอร์
3. เพิ่ม fallback ถ้า attack_2 หรือ attack_3 ไม่มี asset
4. ทดสอบใน Godot ว่า animation ทั้ง 3 เล่นได้แยกกัน
```

ผลลัพธ์ที่ต้องเห็น:

```text
Player สามารถเล่น attack_1 / attack_2 / attack_3 แยกกันได้ผ่านค่าทดสอบ
```

### Phase 2: เพิ่ม combo state ใน Player

เป้าหมาย:

```text
ให้ Player มี state สำหรับ combo โดยยังไม่เน้น balance
```

งานที่ต้องทำ:

```text
1. เพิ่ม combo_step
2. เพิ่ม queued_combo_step
3. เพิ่ม combo_sequence_id
4. แยก attack() เดิมเป็น entry point
5. เพิ่ม perform_combo_hit(step)
6. clear hit_targets ทุก hit
```

ผลลัพธ์ที่ต้องเห็น:

```text
กด attack 1 ครั้ง → Hit 1
กด attack ต่อใน window → Hit 2
กด attack ต่อใน window → Hit 3
```

### Phase 3: Balance timing และ stamina

เป้าหมาย:

```text
ทำให้ Hit 1/2/3 มีบทบาทต่างกันชัดเจน
```

งานที่ต้องทำ:

```text
1. แยก stamina cost ต่อ hit
2. แยก damage ต่อ hit
3. แยก active time ต่อ hit
4. แยก recovery ต่อ hit
5. ตั้ง Hit 3 ให้ recovery ยาว
6. ทดสอบกับ Boss Grab
```

ผลลัพธ์ที่ต้องเห็น:

```text
Hit 1 ปลอดภัย
Hit 2 กดดันต่อได้
Hit 3 แรงแต่ถ้าใช้ผิดจังหวะโดนสวนง่าย
```

### Phase 4: Integrate กับ Focus Finisher และ Posture

เป้าหมาย:

```text
คอมโบไม่ทำให้ Focus Finisher หรือ posture system พัง
```

งานที่ต้องตรวจ:

```text
1. ถ้า Focus เต็มและ Boss posture broken ระบบ Finisher ยังทำงานถูกต้อง
2. Hit 1/2/3 ไม่ทำให้ Finisher trigger ซ้ำผิดจังหวะ
3. ถ้า Boss ตายจาก Hit 2 หรือ Hit 3 ต้องจบเกมถูกต้อง
4. ถ้า Player ตายระหว่าง combo ต้อง cancel combo ทันที
```

### Phase 5: Polish feedback

เป้าหมาย:

```text
ให้ผู้เล่นอ่านออกว่าตอนนี้อยู่ Hit ไหนและกำลังเสี่ยงอะไร
```

งานที่ทำได้:

```text
1. เสียง hit ต่างกันเล็กน้อย
2. camera shake Hit 3 แรงกว่า
3. slash VFX Hit 3 ชัดกว่าแต่ไม่ใหญ่เกิน mobile readability
4. stamina feedback ชัดเมื่อกดต่อไม่ได้
5. debug print เฉพาะตอนเปิด debug mode
```

---

## 14. Acceptance Criteria

ระบบถือว่าสำเร็จเมื่อผ่านเงื่อนไขเหล่านี้:

```text
1. กด attack 1 ครั้งแล้วออก Hit 1 เท่านั้น
2. กด attack 2 ครั้งในจังหวะที่ถูกต้องแล้วออก Hit 1 → Hit 2
3. กด attack 3 ครั้งในจังหวะที่ถูกต้องแล้วออก Hit 1 → Hit 2 → Hit 3
4. ถ้าไม่กดต่อ combo ต้องหยุดที่ hit ล่าสุด
5. Hit 3 มี recovery ยาวกว่าชัดเจน
6. ระหว่าง recovery ของ Hit 3 ผู้เล่นไม่สามารถหลบหนีได้ง่ายเกินไป
7. Boss สามารถลงโทษ Hit 3 ที่ใช้ผิดจังหวะได้
8. hit_targets ถูก reset ทุก hit ทำให้แต่ละ hit ทำ damage ได้ถูกต้อง
9. Visual animation เปลี่ยนเป็น attack_1 / attack_2 / attack_3 ตาม combo_step
10. ระบบ death, dash, posture break, grab ไม่พังค้างเมื่อเกิดระหว่าง combo
```

---

## 15. Test Checklist

### 15.1 ทดสอบ input

```text
[ ] กด attack 1 ครั้ง → ออก Hit 1
[ ] กด attack 2 ครั้งเร็วเกินไป → ไม่เกิด bug หรือ replay ผิด
[ ] กด attack 2 ครั้งใน window → ออก Hit 2
[ ] กด attack 3 ครั้งใน window → ออก Hit 3
[ ] กด attack หลัง combo จบ → เริ่ม Hit 1 ใหม่
```

### 15.2 ทดสอบ stamina

```text
[ ] stamina ไม่พอ Hit 1 → ไม่เริ่ม combo
[ ] stamina พอ Hit 1 แต่ไม่พอ Hit 2 → ไม่ต่อ Hit 2
[ ] stamina พอ Hit 2 แต่ไม่พอ Hit 3 → ไม่ต่อ Hit 3
[ ] stamina ลดถูกต้องตามแต่ละ hit
```

### 15.3 ทดสอบ hitbox

```text
[ ] Hit 1 ทำ damage ได้
[ ] Hit 2 ทำ damage ได้แม้ Hit 1 โดน target เดิม
[ ] Hit 3 ทำ damage ได้แม้ Hit 1/2 โดน target เดิม
[ ] hitbox ปิดถูกต้องหลัง active time
[ ] ไม่มี damage ซ้ำหลายครั้งใน hit เดียว
```

### 15.4 ทดสอบกับ Boss

```text
[ ] Boss โดน Hit 1/2/3 แล้ว HP ลดถูกต้อง
[ ] Boss posture broken แล้วยังรับ combo ได้ถูกต้อง
[ ] Focus Finisher ยังทำงานเมื่อเงื่อนไขครบ
[ ] Boss Grab ลงโทษผู้เล่นที่ค้าง Hit 3 ใกล้บอสได้
[ ] Boss death หลังโดน Hit 2 หรือ Hit 3 ไม่ทำให้ coroutine พัง
```

### 15.5 ทดสอบ interrupt

```text
[ ] Player โดนโจมตีระหว่าง combo แล้ว combo ถูก cancel
[ ] Player โดน Grab ระหว่าง combo แล้ว combo ถูก cancel
[ ] Player ตายระหว่าง combo แล้วไม่มี hitbox ค้าง
[ ] Player posture broken ระหว่าง combo แล้วไม่มี hitbox ค้าง
[ ] Scene restart แล้วไม่มี coroutine เก่าทำงานต่อ
```

---

## 16. Rollback Plan

เพื่อให้ปลอดภัย ควรมี toggle:

```text
combo_enabled = true / false
```

ถ้า combo system มี bug ให้ปิดกลับเป็นระบบโจมตีเดี่ยวเดิมได้ทันที

แนวทาง rollback:

```text
combo_enabled = false
→ attack() ใช้ logic เดิม
→ visual manager ใช้ attack_1 เท่านั้น
```

สิ่งนี้สำคัญมากเพราะระบบ attack เป็นแกนหลักของเกม ถ้า combo ยังไม่นิ่ง ไม่ควรให้กระทบ build ที่ทดสอบได้อยู่แล้ว

---

## 17. ข้อควรระวังสำหรับ Codex / AI Coding Agent

เมื่อให้ Codex ทำงาน ควรสั่งเป็นลำดับเล็ก ๆ ไม่ให้แก้ทั้งระบบในครั้งเดียว

ลำดับที่แนะนำ:

```text
Task 1: เพิ่ม loader สำหรับ attack_2 และ attack_3 ใน visual manager โดยยังไม่แตะ player.gd
Task 2: เพิ่ม combo state variables ใน player.gd แต่ยังไม่เปลี่ยน balance
Task 3: เปลี่ยน attack() ให้เรียก combo state machine
Task 4: เพิ่ม damage/stamina/timing per combo step
Task 5: เพิ่ม cancel conditions และทดสอบกับ death / grab / posture break
Task 6: polish debug print และ export variables
```

ห้ามสั่งกว้าง ๆ ว่า:

```text
ทำระบบ combo ให้เสร็จ
```

เพราะมีโอกาสสูงที่ Codex จะไปแก้หลายระบบพร้อมกันจน debug ยาก

---

## 18. สรุปแนวทางสุดท้าย

ระบบ 3-hit combo ควรทำให้ Player มีทางเลือกมากขึ้น แต่ต้องไม่ทำให้เกมง่ายลงเกินไป

แกนของระบบคือ:

```text
Hit 1 = แตะทดสอบ
Hit 2 = ยืนยันจะสู้ต่อ
Hit 3 = เสี่ยงเพื่อรางวัล
```

ถ้าระบบนี้ทำสำเร็จ เกมจะมีมิติการตัดสินใจเพิ่มขึ้นทันที เพราะผู้เล่นต้องคิดทุกครั้งว่า:

```text
จะหยุดที่ Hit 1 เพื่อปลอดภัย?
จะต่อ Hit 2 เพื่อกดดัน?
หรือจะเสี่ยง Hit 3 เพื่อ damage/posture สูง แต่เปิดช่องให้ Boss สวน?
```

นี่คือทิศทางที่เหมาะกับ Last Blade Trial มากที่สุด เพราะยังรักษาแกนหลักของเกมไว้:

```text
อ่านจังหวะ → ตัดสินใจ → รับผลของการ commit
```
