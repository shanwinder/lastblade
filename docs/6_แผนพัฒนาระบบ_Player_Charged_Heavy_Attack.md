# แผนพัฒนาระบบ Player Charged Heavy Attack

เกม: **Last Blade Trial / ดาบไร้นาม**  
ระบบที่พัฒนา: **Player Charged Heavy Attack / ท่าโจมตีหนักแบบกดค้างชาร์จ**  
ตัวละคร: **The Nameless Blade / ดาบไร้นาม**  
สถานะเอกสาร: แผนออกแบบก่อนลงมือแก้โค้ด  

---

## 1. เป้าหมายของระบบ

ระบบนี้มีเป้าหมายเพื่อเพิ่มท่าโจมตีหนักให้ Player โดยใช้ปุ่มโจมตีปุ่มเดิม ไม่เพิ่มปุ่มใหม่

แนวคิดหลัก:

```text
แตะ Attack สั้น ๆ = ใช้ระบบ 3-hit combo เดิม
กด Attack ค้าง = เริ่มชาร์จพลังเพื่อใช้ Heavy Attack
ปล่อย Attack หลังชาร์จถึงขั้นต่ำ = ปล่อยท่า Heavy Attack
ปล่อยเร็วเกินไป = ยกเลิกชาร์จ หรือไม่ออกท่าหนัก
```

ท่านี้ต้องกินทั้ง:

```text
- Stamina
- Focus
- เวลาในการยืนชาร์จ
- recovery หลังปล่อยท่า
```

Heavy Attack ไม่ควรเป็นท่าที่แรงฟรี แต่ต้องเป็นทางเลือกที่ผู้เล่นต้องคิดก่อนใช้

แกนการออกแบบ:

```text
อ่านจังหวะบอสถูก → กล้าชาร์จ → ได้รางวัลสูง
อ่านจังหวะผิด → โดนบอสสวน / โดน Grab / เสีย resource
```

---

## 2. สภาพระบบปัจจุบันที่เกี่ยวข้อง

### 2.1 Player มีระบบ 3-hit combo แล้ว

ไฟล์หลัก:

```text
last-blade-trial/player.gd
```

Player ปัจจุบันมีระบบ 3-hit combo โดยใช้ปุ่ม Attack เดิม

ค่าที่เกี่ยวข้อง:

```text
combo_enabled
combo_hit_1_damage
combo_hit_2_damage
combo_hit_3_damage
combo_hit_1_stamina_cost
combo_hit_2_stamina_cost
combo_hit_3_stamina_cost
combo_hit_1_active_time
combo_hit_2_active_time
combo_hit_3_active_time
combo_hit_1_recovery_time
combo_hit_2_recovery_time
combo_hit_3_recovery_time
combo_chain_window
combo_early_input_buffer_time
```

บทบาทปัจจุบันของ 3-hit combo:

```text
Hit 1 = ปลอดภัย ใช้เช็กระยะ
Hit 2 = กดดันต่อเนื่อง
Hit 3 = แรงขึ้น แต่ recovery ยาวและเสี่ยงกว่า
```

Heavy Attack ใหม่ต้องไม่ทำให้ Hit 3 หมดความหมาย

ดังนั้น Heavy Attack ควรมีบทบาทแยกเป็น:

```text
ท่าที่ใช้เมื่อมีช่องว่างยาวมากพอ ไม่ใช่ท่าที่ใช้ต่อจาก combo ตามปกติ
```

### 2.2 Player มี Focus อยู่แล้ว

ไฟล์หลัก:

```text
last-blade-trial/player.gd
```

Player มีระบบ Focus สำหรับ Focus Finisher อยู่แล้ว

ค่าที่เกี่ยวข้อง:

```text
max_focus
focus_gain_on_successful_parry
focus_finisher_cost
focus_finisher_damage_ratio
```

ปัจจุบัน Focus Finisher ควรยังเป็นท่ารางวัลใหญ่สุดเมื่อเงื่อนไขครบ เช่น Boss posture broken และ Focus เต็ม

ดังนั้น Heavy Attack ไม่ควรกิน Focus เต็ม 100 และไม่ควรแรงจนแทนที่ Focus Finisher

แนวทาง:

```text
Focus Finisher = ใช้ Focus เต็ม เป็นท่าปิดเกม/ลงโทษใหญ่ที่สุด
Charged Heavy Attack = ใช้ Focus บางส่วน เป็นท่าเสี่ยงสูงที่ใช้ได้เมื่อมีช่อง
```

### 2.3 TouchControls ปัจจุบันยังเป็น Tap ไม่ใช่ Hold

ไฟล์หลัก:

```text
last-blade-trial/touch_controls.gd
last-blade-trial/touch_controls_player_lookup_patch.gd
```

ระบบปุ่ม Attack บนมือถือปัจจุบันกดแบบหนึ่งจังหวะผ่าน `trigger_action_once()`

พฤติกรรมปัจจุบัน:

```text
กดปุ่ม Attack
→ Input.action_press("attack")
→ รอหนึ่ง physics frame
→ Input.action_release("attack")
```

แปลว่า TouchControls ปัจจุบันไม่สามารถส่งสัญญาณกดค้างจริงให้ `Input.is_action_pressed("attack")` ได้

ถ้าจะทำระบบ Charged Heavy Attack ให้ใช้ได้จริงบนมือถือ ต้องปรับ TouchControls ด้วย

แนวทางที่ต้องทำ:

```text
Attack button down  = press_action("attack")
Attack button up    = release_action("attack")
```

แต่ต้องระวังไม่ให้ Dash / Lock เสีย behavior เดิม เพราะปุ่มอื่นยังควรทำงานแบบเดิม

### 2.4 Visual manager ปัจจุบันรองรับ attack_1 / attack_2 / attack_3

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

Visual manager ปัจจุบันเลือก animation attack ตาม `combo_step`

แนวปัจจุบัน:

```text
combo_step = 1 → attack_1
combo_step = 2 → attack_2
combo_step = 3 → attack_3
```

ระบบ Heavy Attack ต้องเพิ่มสถานะ animation ใหม่ โดยไม่ทำให้ combo animation เดิมพัง

---

## 3. บทบาทของ Charged Heavy Attack

Heavy Attack ควรเป็นท่าแบบ:

```text
แรงกว่า combo hit 3
ใช้ resource มากกว่า combo hit 3
ต้องยืนชาร์จนานกว่า
พลาดแล้วโดนลงโทษหนักกว่า
```

บทบาทที่ควรเป็น:

```text
- ใช้ลงโทษบอสหลังบอสออกท่าใหญ่แล้วพลาด
- ใช้เมื่อบอสติด recovery นาน
- ใช้เมื่อบอส posture broken แต่ยังไม่อยากใช้ Focus Finisher
- ใช้เพื่อสร้าง posture damage สูง
- ใช้เป็นทางเลือกเสี่ยงสูงแทนการทำ combo 3 hit
```

บทบาทที่ไม่ควรเป็น:

```text
- ไม่ควรใช้แทน combo ปกติทุกครั้ง
- ไม่ควรกดสุ่มกลางการต่อสู้แล้วคุ้ม
- ไม่ควรมี armor มากจนยืนชาร์จฝืนบอสได้เสมอ
- ไม่ควรแรงกว่า Focus Finisher แบบไม่มีเงื่อนไข
```

---

## 4. หลักการแยก Tap กับ Hold

ระบบนี้ต้องแยก input ออกเป็น 2 ประเภท

```text
Tap Attack
= กดแล้วปล่อยเร็ว
= ใช้ combo ปกติ

Hold Attack
= กดค้างเกินเวลาที่กำหนด
= เริ่ม charge heavy
```

แนวคิด timing:

```text
กด Attack ลง
→ เริ่มจับเวลา

ถ้าปล่อยก่อน hold_threshold
→ ถือว่าเป็น Tap
→ ส่งเข้า combo system

ถ้ากดค้างเกิน hold_threshold
→ เข้าสู่สถานะ Heavy Charge

ถ้าปล่อยหลัง charge_min_time
→ ปล่อย Heavy Attack

ถ้าปล่อยก่อน charge_min_time
→ ยกเลิกชาร์จ / ไม่ออกท่าหนัก
```

ค่าที่แนะนำ:

```text
hold_threshold = 0.20 ถึง 0.30 วินาที
heavy_charge_min_time = 2.00 วินาที
heavy_charge_max_time = 3.00 วินาที
```

เหตุผล:

```text
hold_threshold สั้นพอให้ tap combo ยังตอบสนองไว
charge_min_time นานพอให้ผู้เล่นต้องเลือกจังหวะ
charge_max_time ใช้เป็นจุดชาร์จเต็มเพื่อเพิ่มรางวัล
```

---

## 5. ค่าบาลานซ์เริ่มต้นที่แนะนำ

ค่าต่อไปนี้เป็น baseline สำหรับทดลอง ไม่ใช่ค่าสุดท้าย

| ค่า | แนะนำเริ่มต้น | เหตุผล |
|---|---:|---|
| hold_threshold | 0.25 sec | แยก tap กับ hold โดยไม่ทำให้ combo หน่วงเกินไป |
| heavy_charge_min_time | 2.00 sec | ต้องมีช่องจริงจึงใช้ได้ |
| heavy_charge_max_time | 3.00 sec | ให้รางวัลสำหรับการชาร์จเต็ม |
| heavy_start_stamina_cost | 18–20 | กันไม่ให้เริ่มชาร์จฟรี |
| heavy_release_stamina_cost | 20–26 | ค่าใช้จ่ายตอนปล่อยท่า |
| heavy_focus_cost | 35–45 | กิน Focus แต่ไม่แย่งบทบาท Finisher |
| heavy_min_damage | 28–32 | แรงกว่า Hit 3 ชัดเจน |
| heavy_max_damage | 38–45 | รางวัลเมื่อชาร์จเต็ม |
| heavy_posture_damage | สูง | ให้เด่นที่ทำลาย posture มากกว่าเลือด |
| heavy_active_time | 0.20–0.28 sec | hitbox หนักแต่ไม่เปิดนานเกินไป |
| heavy_recovery_time | 0.85–1.10 sec | พลาดแล้วต้องโดนลงโทษได้ |
| heavy_final_frame_hold_time | 0.45–0.65 sec | ค้างเฟรมท้ายเพื่อให้ผู้เล่นต้องรับผลของการ commit |

แนวคิดสำคัญ:

```text
Hit 3 combo = เสี่ยงปานกลาง ใช้จบชุดโจมตี
Heavy Attack = เสี่ยงสูง ต้องมีช่องชาร์จ 2–3 วิ
Focus Finisher = รางวัลใหญ่สุดเมื่อทำเงื่อนไขระบบ posture สำเร็จ
```

---

## 6. Resource Design: Focus และ Stamina

### 6.1 ค่าใช้ Stamina

Heavy Attack ควรใช้ Stamina สองช่วง

```text
ช่วงเริ่มชาร์จ
= จ่าย stamina ทันที เพื่อกันการกดค้างเล่นฟรี

ช่วงปล่อยท่า
= จ่าย stamina เพิ่มเมื่อปล่อยท่าสำเร็จ
```

เหตุผล:

```text
ถ้าชาร์จฟรี ผู้เล่นจะกดค้างบ่อยเกินไป
ถ้าจ่ายทั้งหมดตอนปล่อยอย่างเดียว ผู้เล่นจะทดลองชาร์จได้โดยไม่เสี่ยง resource
```

ตัวอย่าง:

```text
เริ่มชาร์จ: -20 stamina
ปล่อยสำเร็จ: -22 stamina
รวมถ้าปล่อยสำเร็จ: -42 stamina
```

### 6.2 ค่าใช้ Focus

Focus ควรถูกใช้ตอนปล่อยท่าสำเร็จ ไม่ใช่ตอนเริ่มชาร์จ

เหตุผล:

```text
ถ้าผู้เล่นโดนบอสตีจนชาร์จล้มเหลว ไม่ควรเสีย Focus หนักเกินไป
แต่ถ้าปล่อยท่าได้จริง ต้องจ่าย Focus เพื่อแลกกับ damage/posture สูง
```

ตัวอย่าง:

```text
heavy_focus_cost = 40
```

### 6.3 เงื่อนไข Focus ไม่พอ

ถ้า Focus ไม่พอ ควรไม่ให้เริ่ม Heavy Charge หรือให้เริ่มไม่ได้ตั้งแต่ต้น

แนวทางที่แนะนำ:

```text
ต้องมี Focus อย่างน้อย heavy_focus_cost ก่อนเริ่มชาร์จ
```

เหตุผล:

```text
ผู้เล่นควรรู้ตั้งแต่กดค้างว่าใช้ท่านี้ได้หรือไม่
ไม่ควรชาร์จครบแล้วค่อยบอกว่า Focus ไม่พอ
```

---

## 7. State Machine ที่ควรเพิ่มใน player.gd

ควรเพิ่มสถานะแยกจาก combo ดังนี้

```text
heavy_attack_enabled
is_attack_button_held
attack_hold_started_msec
is_charging_heavy_attack
heavy_charge_elapsed
heavy_charge_ready
heavy_charge_full
is_releasing_heavy_attack
is_heavy_recovering
heavy_attack_sequence_id
```

คำอธิบาย:

```text
heavy_attack_enabled
= เปิด/ปิดระบบ heavy เพื่อ rollback ได้ง่าย

is_attack_button_held
= ใช้รู้ว่าปุ่ม Attack ถูกกดค้างอยู่หรือไม่

attack_hold_started_msec
= เวลาที่เริ่มกด attack เพื่อแยก tap กับ hold

is_charging_heavy_attack
= Player อยู่ในท่าชาร์จ

heavy_charge_elapsed
= เวลาที่ชาร์จไปแล้ว

heavy_charge_ready
= ชาร์จถึงขั้นต่ำแล้ว ปล่อยได้

heavy_charge_full
= ชาร์จเต็ม 3 วิ ได้ damage/posture สูงสุด

is_releasing_heavy_attack
= กำลังปล่อยท่า heavy จริง

is_heavy_recovering
= หลังปล่อยท่า กำลังค้างเฟรมท้าย/recovery

heavy_attack_sequence_id
= ใช้ยกเลิก coroutine เก่าเมื่อโดนตี ตาย dash หรือ scene reload
```

---

## 8. Flow ที่ควรเป็น

### 8.1 ตอนกด Attack ลง

```text
ถ้า Player ไม่พร้อม
→ ไม่ทำอะไร

ถ้า Player ว่าง
→ เริ่มจับเวลา hold
→ ยังไม่เริ่ม combo ทันที
```

เหตุผล:

```text
ต้องรอดูก่อนว่าผู้เล่นตั้งใจ tap หรือ hold
```

### 8.2 ตอนปล่อย Attack ก่อน hold_threshold

```text
ถือว่าเป็น Tap
→ เรียก try_attack_input() / attack() ของ combo เดิม
```

### 8.3 ตอนกดค้างเกิน hold_threshold

```text
เช็ก stamina และ focus
ถ้าพอ
→ เข้าสู่ heavy charge
ถ้าไม่พอ
→ แสดง feedback เช่น NO FOCUS / NO STAMINA
→ ยกเลิก hold
```

### 8.4 ระหว่างชาร์จ

```text
Player หยุดเดินหรือเดินช้ามาก
ห้าม dash
ห้าม combo
ห้ามเริ่ม action อื่น
แสดง charge visual / aura
ถ้าโดนตีหรือถูก Grab → cancel charge
```

### 8.5 ตอนปล่อยหลัง charge_min_time

```text
คำนวณระดับชาร์จ
จ่าย stamina/focus
เล่น heavy_release animation
เปิด hitbox ตามเวลา heavy_active_time
ปิด hitbox
ค้างเฟรมสุดท้าย heavy_final_frame_hold_time
เข้า recovery heavy_recovery_time
จบสถานะ heavy
```

### 8.6 ตอนปล่อยก่อน charge_min_time

แนวทางที่แนะนำ:

```text
ยกเลิกชาร์จ
ไม่ปล่อยท่า heavy
ไม่คืน stamina cost ตอนเริ่มชาร์จทั้งหมด
```

เพื่อให้ผู้เล่นรู้ว่าการเริ่มชาร์จผิดจังหวะมีต้นทุน

---

## 9. Interaction กับระบบ Combo

Heavy Attack ต้องไม่ชนกับ 3-hit combo

หลักการ:

```text
Tap = combo
Hold = heavy charge
Heavy charge เริ่มจากสถานะว่างเท่านั้น
ไม่เริ่ม heavy ระหว่าง combo
ไม่ต่อ heavy หลัง combo hit 3 โดยอัตโนมัติ
```

เหตุผล:

```text
ถ้าให้ combo ต่อ heavy ได้ จะซับซ้อนเกินไปสำหรับมือถือ
ถ้า hold ระหว่าง combo แปลว่า heavy จะออกโดยไม่ตั้งใจง่าย
```

กรณีที่ Player กำลัง combo อยู่:

```text
กด Attack เพิ่ม = queue combo hit ถัดไปตามระบบเดิม
กดค้าง Attack ระหว่าง combo = ไม่เริ่ม heavy
```

Heavy Attack ควรใช้เมื่อ Player ว่างและตั้งใจเริ่มชาร์จเท่านั้น

---

## 10. Interaction กับ Dash และ Movement

ระหว่างชาร์จควรมีข้อจำกัดชัดเจน

ค่าที่แนะนำ:

```text
ระหว่าง charge_start: เดินไม่ได้
ระหว่าง charge_loop: เดินไม่ได้ หรือเดินช้ามาก 20% ของ speed
ระหว่าง release: เดินไม่ได้
ระหว่าง recovery: เดินไม่ได้
```

Dash:

```text
ก่อนชาร์จครบขั้นต่ำ: Dash เพื่อ cancel ได้หรือไม่ได้ ต้องเลือกชัดเจน
หลังเริ่ม release: Dash ไม่ได้
ระหว่าง final frame hold: Dash ไม่ได้
```

แนวทางเริ่มต้นที่แนะนำ:

```text
ไม่ให้ Dash cancel ระหว่าง Heavy Attack ทั้งหมด
```

เหตุผล:

```text
Heavy Attack ต้องเป็นท่าที่มี commitment สูง
ถ้า dash cancel ได้ง่าย ท่านี้จะกลายเป็นท่าแรงที่ไม่มีความเสี่ยง
```

ภายหลังอาจเพิ่ม upgrade หรือ passive ที่อนุญาตให้ cancel ได้บางช่วง

---

## 11. Interaction กับ Boss

Heavy Attack ควรสัมพันธ์กับจังหวะของ Boss

จังหวะที่เหมาะ:

```text
Boss ใช้ Heavy Slash แล้วพลาด
Boss อยู่ final frame hold หลังท่าใหญ่
Boss staggered
Boss posture broken
Boss เดินไกลและยังไม่พร้อมโจมตี
```

จังหวะที่ไม่เหมาะ:

```text
Boss อยู่ใกล้และพร้อม Grab
Boss กำลังจะใช้ Quick Slash
Boss อยู่ระยะประชิดและ Player ไม่มี stamina เหลือ
Boss ไม่ได้ติด recovery
```

ระบบนี้จะทำให้ Player มีคำถามเชิงตัดสินใจเพิ่มขึ้น:

```text
ช่องนี้พอทำ 3-hit combo หรือพอชาร์จ Heavy Attack?
ควรเก็บ Focus ไว้ทำ Finisher หรือใช้บางส่วนกับ Heavy?
ถ้าชาร์จแล้วบอส Grab จะเสียอะไร?
```

---

## 12. Damage และ Posture Design

Heavy Attack ควรเด่นที่ posture pressure มากกว่า HP damage

เหตุผล:

```text
เกมนี้มีแกนอ่านจังหวะ / ทำลาย posture / เปิดช่องสวนกลับ
ถ้า Heavy Attack แรงแค่ HP อาจทำให้ระบบ posture และ Finisher ลดความสำคัญ
```

แนวทาง:

```text
ชาร์จขั้นต่ำ:
- HP damage สูงกว่า Hit 3 เล็กน้อย
- posture damage สูงชัดเจน

ชาร์จเต็ม:
- HP damage สูงขึ้น
- posture damage สูงมาก
- camera shake / hit stop หนักขึ้น
```

ตัวอย่างเริ่มต้น:

```text
Heavy min damage = 30
Heavy max damage = 42
Heavy min posture damage = 35
Heavy max posture damage = 55
```

ถ้าภายหลังต้องแยก Boss posture damage จากระบบเดิม ควรเพิ่มฟังก์ชันที่ชัดเจน เช่น:

```text
apply_boss_posture_damage_from_player(amount)
```

โดยไม่เอาไปปนกับ damage HP ตรง ๆ

---

## 13. Animation และ Asset Plan

ควรเตรียม asset แยกเป็น 4 ช่วง

```text
heavy_charge_start
heavy_charge_loop
heavy_release
heavy_recovery_hold
```

โครงโฟลเดอร์ที่แนะนำ:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/heavy_charge_start/
last-blade-trial/assets/sprites/player/nameless_blade/frames/heavy_charge_loop/
last-blade-trial/assets/sprites/player/nameless_blade/frames/heavy_release/
last-blade-trial/assets/sprites/player/nameless_blade/frames/heavy_recovery_hold/
```

ถ้ามี asset เป็น sprite sheet เดียว ให้แตกเป็น frame แยกก่อน เพื่อให้ loader ปัจจุบันต่อยอดง่าย

หลักสำคัญด้านภาพ:

```text
- ต้องใช้ silhouette ของตัวละครเดิม
- ต้องไม่ทำให้ scale เปลี่ยนจาก idle/combo
- pivot ต้อง bottom center
- baseline เท้าต้องไม่ลอย
- เฟรมสุดท้ายของ heavy_recovery_hold ต้องอ่านออกว่าผู้เล่นเปิดช่องอยู่
```

### 13.1 ช่วง heavy_charge_start

หน้าที่:

```text
บอกผู้เล่นว่ากำลังเปลี่ยนจาก neutral เป็นท่าชาร์จ
```

ลักษณะ:

```text
ยกดาบ / ตั้งดาบสองมือ / ก้มศูนย์ถ่วง
```

### 13.2 ช่วง heavy_charge_loop

หน้าที่:

```text
ใช้ค้างระหว่างชาร์จ 2–3 วิ
```

ลักษณะ:

```text
มี aura / แสง cyan / ผ้าขยับเล็กน้อย
ไม่ควรมี motion ใหญ่เกินไป
```

### 13.3 ช่วง heavy_release

หน้าที่:

```text
ปล่อยท่าฟันหนัก
```

ลักษณะ:

```text
ฟันหนักชัดเจน
มี impact frame
มี slash trail ที่อ่านง่ายบนมือถือ
```

### 13.4 ช่วง heavy_recovery_hold

หน้าที่:

```text
ค้างเฟรมท้ายเพื่อให้ผู้เล่นรับผลของการ commit
```

ลักษณะ:

```text
ตัวละครจบแรง / เสียหลักเล็กน้อย / ดาบอยู่ต่ำหรือเลยตัว
ผู้เล่นอ่านออกว่าช่วงนี้ขยับไม่ได้
```

---

## 14. Visual Manager ที่ควรปรับ

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

ควรเพิ่ม animation name และ folder สำหรับ heavy

```text
heavy_charge_start_animation_name
heavy_charge_loop_animation_name
heavy_release_animation_name
heavy_recovery_hold_animation_name

heavy_charge_start_frames_folder
heavy_charge_loop_frames_folder
heavy_release_frames_folder
heavy_recovery_hold_frames_folder
```

การเลือก animation ควรอ่านสถานะจาก Player

```text
is_charging_heavy_attack + charge_start → heavy_charge_start
is_charging_heavy_attack + charge_loop → heavy_charge_loop
is_releasing_heavy_attack → heavy_release
is_heavy_recovering → heavy_recovery_hold
```

ลำดับ priority ใน visual manager ควรเป็น:

```text
dead / posture broken / knockback / dash
→ heavy attack states
→ combo attack states
→ run/back/idle
```

เหตุผล:

```text
ถ้า heavy state อยู่หลัง combo state ระบบอาจเล่น attack_1/2/3 แทน heavy animation เพราะ is_attacking เป็น true เหมือนกัน
```

---

## 15. Feedback / UI / VFX

Heavy Attack ต้องมี feedback ชัด เพราะผู้เล่นต้องรู้ว่า:

```text
กำลังชาร์จอยู่
ชาร์จถึงขั้นต่ำแล้ว
ชาร์จเต็มแล้ว
Focus หรือ Stamina ไม่พอ
ปล่อยท่าหนักสำเร็จ
```

### 15.1 ข้อความ feedback

ตัวอย่าง:

```text
CHARGING...
HEAVY READY
FULL CHARGE
NO FOCUS
NO STAMINA
```

ควรแสดงเป็นข้อความสั้นเหนือหัว Player หรือใกล้ HUD

### 15.2 VFX

ควรใช้ VFX แบบอ่านง่าย ไม่บังตัวละคร

แนวทางสี:

```text
Player heavy charge = cyan / white / pale blue
Focus energy = cyan-white glow
Full charge = brighter cyan + small white spark
```

หลีกเลี่ยง:

```text
เอฟเฟกต์ใหญ่เกินจนบังบอส
แสงฟุ้ง painterly
สีแดง/ม่วงที่ชนกับภาษาของ Boss danger
```

### 15.3 Camera / Hit Stop

ตอน heavy release โดน:

```text
Hit stop หนักกว่า hit ปกติ
Camera shake หนักกว่า combo hit 3
```

แต่ต้องไม่ยาวเกินจนทำให้ mobile feel หน่วง

ค่าเริ่มต้น:

```text
heavy_hit_stop_time = 0.12–0.16
heavy_camera_shake_strength = 9–12
heavy_camera_shake_duration = 0.16–0.22
```

---

## 16. TouchControls Plan

ไฟล์หลัก:

```text
last-blade-trial/touch_controls.gd
last-blade-trial/touch_controls_player_lookup_patch.gd
```

ปัจจุบัน Attack ใช้ tap trigger แบบหนึ่งจังหวะ

ระบบใหม่ต้องเปลี่ยนเฉพาะ Attack button ให้รองรับ hold

แนวทาง:

```text
Attack button_down
→ Input.action_press("attack")
→ เพิ่ม action ลง held_actions
→ เปลี่ยนภาพปุ่มเป็น pressed

Attack button_up
→ Input.action_release("attack")
→ เอา action ออกจาก held_actions
→ คืนภาพปุ่ม
```

Dash และ Lock ควรคง behavior เดิมก่อน

```text
Dash = tap action
Lock = toggle action
Attack = hold-capable action
```

ต้องระวัง:

```text
เมื่อ scene ซ่อน TouchControls ต้อง release attack ด้วย
เมื่อ Game Over / Victory ต้อง release attack ด้วย
เมื่อ player ตายระหว่างกดค้าง ต้อง release attack ด้วย
```

---

## 17. Cancel Conditions

Heavy Attack ต้องถูก cancel เมื่อเกิดสถานะเหล่านี้

```text
Player ตาย
Player dash
Player posture broken
Player knockback
Player ถูก Grab
Boss ตาย
Scene reload
GameLoop ปิด combat
TouchControls ถูกซ่อน
```

เมื่อ cancel ต้องทำสิ่งเหล่านี้:

```text
is_charging_heavy_attack = false
is_releasing_heavy_attack = false
is_heavy_recovering = false
attack_shape.disabled = true
heavy_attack_sequence_id += 1
คืน animation ไป idle/run ตามสถานะ
```

ถ้ามี resource ที่จ่ายไปแล้ว:

```text
stamina ที่จ่ายตอนเริ่มชาร์จ ไม่ควรคืนเต็ม
focus ยังไม่ควรถูกหักจนกว่าจะปล่อยท่าสำเร็จ
```

---

## 18. Integration กับ Focus Finisher

ต้องป้องกันไม่ให้ Heavy Attack แย่ง logic ของ Focus Finisher

แนวทาง:

```text
Focus Finisher ยังใช้เมื่อ:
- Focus เต็ม
- Boss posture broken
- Player โจมตีตามเงื่อนไขเดิม

Heavy Attack ใช้เมื่อ:
- Player กด Attack ค้าง
- Focus >= heavy_focus_cost
- Stamina พอ
- Player ว่าง
```

กรณี Boss posture broken:

```text
ถ้า Tap Attack และ Focus เต็ม → ใช้ Finisher ตามระบบเดิม
ถ้า Hold Attack → ใช้ Heavy Attack หากผู้เล่นตั้งใจชาร์จ
```

ต้องระวังไม่ให้ heavy release trigger Finisher ซ้อนโดยไม่ได้ตั้งใจ

---

## 19. Phase การพัฒนา

### Phase 1: วาง Input Hold แบบปลอดภัย

เป้าหมาย:

```text
แยก Tap กับ Hold ได้ โดยยังไม่เพิ่ม damage heavy จริง
```

งาน:

```text
1. เพิ่มตัวแปรจับเวลา attack hold ใน player.gd
2. เปลี่ยน logic input ให้ tap ยังเข้า combo เดิม
3. ให้ hold เกิน threshold เข้า debug state ชั่วคราว
4. แก้ TouchControls ให้ Attack กดค้างจริง
5. ทดสอบ keyboard และ mobile touch
```

ผลลัพธ์:

```text
แตะ Attack ยัง combo ได้
กด Attack ค้างแล้ว Player เข้าสถานะ charge debug ได้
```

### Phase 2: เพิ่ม Heavy Charge State

เป้าหมาย:

```text
ให้ Player เข้าสถานะชาร์จจริงและ cancel ได้ถูกต้อง
```

งาน:

```text
1. เพิ่ม is_charging_heavy_attack
2. เพิ่ม heavy_charge_elapsed
3. เพิ่ม heavy_charge_ready / heavy_charge_full
4. ปิด movement/dash ระหว่าง charge
5. เพิ่ม cancel_heavy_attack(reason)
6. ทดสอบโดนตี / dash / posture broken / death
```

ผลลัพธ์:

```text
ชาร์จแล้วค้างได้
โดน interrupt แล้วไม่เกิด hitbox ค้าง
```

### Phase 3: เพิ่ม Heavy Release และ Resource Cost

เป้าหมาย:

```text
ปล่อยท่า heavy ได้จริงเมื่อชาร์จถึงขั้นต่ำ
```

งาน:

```text
1. เพิ่ม heavy_min_damage / heavy_max_damage
2. เพิ่ม heavy_focus_cost
3. เพิ่ม heavy stamina costs
4. เปิด hitbox เฉพาะช่วง release
5. ใช้ hit_targets แยกจาก combo hit ปกติ
6. เพิ่ม recovery/final frame hold
```

ผลลัพธ์:

```text
ชาร์จถึงขั้นต่ำแล้วปล่อยท่าได้
เสีย Focus/Stamina ถูกต้อง
พลาดแล้วติด recovery
```

### Phase 4: เพิ่ม Animation / VFX / Feedback

เป้าหมาย:

```text
ผู้เล่นอ่านสถานะ heavy ได้ชัดเจน
```

งาน:

```text
1. เพิ่ม animation heavy_charge_start
2. เพิ่ม animation heavy_charge_loop
3. เพิ่ม animation heavy_release
4. เพิ่ม animation heavy_recovery_hold
5. เพิ่ม feedback HEAVY READY / FULL CHARGE
6. เพิ่ม charge glow และ hit impact
```

ผลลัพธ์:

```text
ชาร์จแล้วเห็นชัด
ปล่อยท่าแล้วรู้สึกหนัก
เฟรมท้ายค้างให้รู้ว่าผู้เล่นเปิดช่องอยู่
```

### Phase 5: Balance กับ Boss Pattern

เป้าหมาย:

```text
Heavy Attack ใช้ได้จริงในช่องที่บอสเปิด แต่ไม่ทำให้เกมง่ายเกินไป
```

งาน:

```text
1. ทดสอบหลัง Boss Heavy Slash พลาด
2. ทดสอบกับ Boss Grab
3. ทดสอบกับ Quick Slash
4. ทดสอบตอน Boss posture broken
5. ปรับ charge time / recovery / focus cost
```

ผลลัพธ์:

```text
ผู้เล่นมีทางเลือกชัดระหว่าง combo 3 hit กับ Heavy Attack
Boss ยังลงโทษผู้เล่นที่โลภได้
```

---

## 20. Acceptance Criteria

ระบบถือว่าใช้งานได้เมื่อผ่านเงื่อนไขต่อไปนี้

```text
1. แตะ Attack สั้น ๆ แล้วยังใช้ combo 1/2/3 ได้เหมือนเดิม
2. กด Attack ค้างแล้วไม่เริ่ม combo ทันที
3. กดค้างเกิน hold_threshold แล้วเข้าสู่ heavy charge
4. ปล่อยก่อน charge_min_time แล้วไม่ปล่อย heavy แบบฟรี
5. ปล่อยหลัง charge_min_time แล้วออก Heavy Attack
6. ชาร์จเต็มแล้ว damage/posture สูงกว่าชาร์จขั้นต่ำ
7. ใช้ Focus และ Stamina ถูกต้อง
8. Focus Finisher เดิมไม่พัง
9. TouchControls บนมือถือกดค้างได้จริง
10. โดนตี / Grab / posture broken ระหว่างชาร์จแล้ว cancel ถูกต้อง
11. hitbox ไม่ค้างหลัง cancel หรือ scene reload
12. Heavy Attack มี recovery/final frame hold ชัดเจน
13. Boss สามารถลงโทษ Heavy Attack ที่ใช้ผิดจังหวะได้
```

---

## 21. Test Checklist

### 21.1 Keyboard / Editor

```text
[ ] กด Attack สั้น ๆ → combo Hit 1
[ ] กด Attack สั้น ๆ ต่อ → combo Hit 2 / Hit 3
[ ] กด Attack ค้าง 0.5 วิ → เริ่ม charge
[ ] ปล่อยก่อน 2 วิ → ไม่ออก heavy
[ ] ปล่อยหลัง 2 วิ → ออก heavy
[ ] กดค้าง 3 วิ → full charge
```

### 21.2 TouchControls / Mobile

```text
[ ] แตะ Attack สั้น ๆ บน touch → combo ปกติ
[ ] กด Attack ค้างบน touch → charge ได้จริง
[ ] ปล่อยนิ้ว → release/cancel ตามเวลา
[ ] ซ่อน TouchControls แล้ว action ไม่ค้าง
[ ] Scene restart แล้ว input ไม่ค้าง
```

### 21.3 Resource

```text
[ ] Stamina ไม่พอ → เริ่ม heavy ไม่ได้
[ ] Focus ไม่พอ → เริ่ม heavy ไม่ได้
[ ] เริ่มชาร์จแล้ว stamina ลดตามที่ตั้ง
[ ] ปล่อยสำเร็จแล้ว stamina/focus ลดเพิ่ม
[ ] cancel ก่อนปล่อยแล้ว focus ไม่หาย
```

### 21.4 Combat

```text
[ ] Heavy โดน Boss แล้ว HP ลดถูกต้อง
[ ] Heavy ทำ posture pressure ได้ตามที่ออกแบบ
[ ] Heavy whiff แล้ว Player ติด recovery
[ ] Boss Grab ลงโทษผู้เล่นที่ชาร์จผิดจังหวะได้
[ ] Boss Heavy Slash พลาดแล้ว Player มีโอกาสชาร์จหรืออย่างน้อยเลือก combo 3 hit ได้
```

### 21.5 Interrupt

```text
[ ] Player โดนตีระหว่าง charge → cancel
[ ] Player โดน Grab ระหว่าง charge → cancel
[ ] Player posture broken ระหว่าง charge → cancel
[ ] Player ตายระหว่าง charge/release → ไม่มี hitbox ค้าง
[ ] Boss ตายจาก heavy → flow victory ทำงานถูกต้อง
```

---

## 22. Rollback Plan

ควรมี toggle:

```text
heavy_attack_enabled = true / false
```

ถ้าระบบ heavy ยังไม่พร้อม ให้ปิดแล้วกลับไปใช้ 3-hit combo เดิม

เมื่อปิด heavy:

```text
- Tap Attack ทำ combo ตามเดิม
- Hold Attack ไม่เข้า heavy
- TouchControls ยังไม่ทำ input ค้างผิดปกติ
- Focus Finisher ยังทำงานเดิม
```

การมี rollback สำคัญเพราะระบบนี้แตะ input หลักของเกมและ touch controls โดยตรง

---

## 23. ข้อควรระวังสำหรับ Codex / AI Coding Agent

ห้ามสั่งกว้าง ๆ ว่า:

```text
ทำระบบ heavy attack ให้เสร็จ
```

ควรแบ่ง task เป็นชิ้นเล็ก

ลำดับที่แนะนำ:

```text
Task 1: ปรับ TouchControls ให้ Attack รองรับ hold โดย Dash/Lock ไม่พัง
Task 2: เพิ่ม input state tap/hold ใน player.gd โดยยังไม่ปล่อย heavy จริง
Task 3: เพิ่ม heavy charge state และ cancel conditions
Task 4: เพิ่ม heavy release damage/hitbox/resource cost
Task 5: เพิ่ม visual manager ให้เลือก animation heavy states
Task 6: เพิ่ม feedback/VFX/debug print
Task 7: balance timing กับ Boss Heavy Slash / Grab / Quick Slash
```

ทุก code ที่เพิ่มต้องมีคอมเมนต์ภาษาไทยเพื่อใช้เรียนรู้

---

## 24. สรุปแนวทางสุดท้าย

Charged Heavy Attack ควรเป็นระบบที่เพิ่มการตัดสินใจให้ผู้เล่น ไม่ใช่แค่เพิ่มท่าแรง

แกนของระบบคือ:

```text
Tap = combo
Hold = heavy charge
Focus เต็ม + เงื่อนไข posture = Finisher
```

ภาษาการเล่นที่ต้องการ:

```text
ผู้เล่นเห็นบอสเปิดช่องสั้น → ใช้ combo
ผู้เล่นเห็นบอสเปิดช่องยาว → เสี่ยงชาร์จ Heavy
ผู้เล่นทำระบบ posture สำเร็จ → ใช้ Finisher
```

ท่านี้จะทำให้เกมมีมิติใหม่:

```text
จะใช้ Focus เพื่อ Finisher ในอนาคต?
หรือใช้ Focus บางส่วนตอนนี้กับ Heavy Attack?
ช่องนี้พอชาร์จ 2 วิไหม?
หรือควรเอาแค่ combo 3 hit แล้วถอย?
```

นี่เหมาะกับ Last Blade Trial เพราะยังรักษาแกนหลักของเกมไว้:

```text
อ่านจังหวะ → ตัดสินใจ → commit → รับผลของการเลือก
```
