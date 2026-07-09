# แผนพัฒนาระบบ Player Combat Stance Memory

เกม: **Last Blade Trial / ดาบไร้นาม**  
ระบบที่พัฒนา: **Player Combat Stance Memory / ระบบจำสถานะพร้อมสู้ชั่วคราวของ Player**  
ตัวละคร: **The Nameless Blade / ดาบไร้นาม**  
สถานะเอกสาร: แผนออกแบบก่อนลงมือแก้โค้ด  
เป้าหมายหลัก: ทำให้ Player เริ่มสู้จริงด้วยท่า idle ปกติ และเข้าสู่ท่าพร้อมสู้เฉพาะหลังเกิดการปะทะ เช่น โจมตีหรือโดนโจมตี

---

## 1. เป้าหมายของระบบ

ระบบนี้มีเป้าหมายเพื่อปรับพฤติกรรม animation ของ Player ให้มีจังหวะทางอารมณ์มากขึ้น

แนวคิดหลัก:

```text
เริ่มสู้จริง → Player อยู่ในท่า idle ปกติ
เดิน / ถอย / dash → ไม่ปลุกท่าพร้อมสู้เอง
กดโจมตี → เข้าท่าพร้อมสู้ชั่วคราวหลังจบท่าโจมตี
โดนโจมตี → เข้าท่าพร้อมสู้ชั่วคราวหลังพ้นจังหวะโดนตี
ครบเวลาที่กำหนด → กลับสู่ idle ปกติ
```

เหตุผลเชิงเกมเพลย์:

```text
- ทำให้ Player ดูนิ่ง สุขุม และเป็นนักดาบที่มีจังหวะหายใจ
- ลดความรู้สึกว่าตัวละครยืนพร้อมบวกตลอดเวลา
- ทำให้ช่วงโจมตี/โดนโจมตีมีน้ำหนักมากขึ้น
- ช่วยแยก mood ระหว่าง “สงบก่อนปะทะ” กับ “พร้อมสู้หลังเกิดการปะทะ”
```

ระบบนี้ไม่ใช่ระบบ combat ใหม่โดยตรง แต่เป็นระบบควบคุม animation state เพื่อเสริมความรู้สึกของตัวละคร

---

## 2. สภาพระบบปัจจุบันที่เกี่ยวข้อง

### 2.1 Player ใช้ visual manager แยกจาก logic หลัก

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

ไฟล์นี้ทำหน้าที่เลือก animation จากสถานะของ Player เช่น:

```text
idle
run
back
attack_1
attack_2
attack_3
heavy_charge_start
heavy_charge_loop
heavy_release
heavy_recovery_hold
```

จุดสำคัญ:

```text
choose_player_animation()
```

เป็นฟังก์ชันหลักที่ตัดสินว่า Player ควรแสดง animation ใดในแต่ละเฟรม

พฤติกรรมปัจจุบันโดยสรุป:

```text
- dead → idle
- posture broken → idle
- knocked back → idle
- dash → idle
- heavy state → heavy animation
- is_attacking → attack animation
- velocity.x มากพอ → run หรือ back
- ไม่เข้าเงื่อนไขใด → idle
```

ดังนั้นระบบ Combat Stance Memory ควรเพิ่มเข้าไปใน visual manager โดยไม่ทำให้ระบบ attack/heavy/run/back เดิมเสีย

### 2.2 Player มีสถานะพื้นฐานที่ใช้ตรวจเหตุการณ์ได้อยู่แล้ว

ไฟล์หลัก:

```text
last-blade-trial/player.gd
```

สถานะที่เกี่ยวข้อง:

```text
is_attacking
is_dashing
is_knocked_back
is_hurt_invincible
is_posture_broken
is_dead
combo_step
current_combo_step_for_damage
```

ฟังก์ชันที่เกี่ยวข้อง:

```text
attack()
perform_combo_hit()
finish_combo()
cancel_combo()
take_damage()
apply_knockback()
start_player_posture_break()
dash()
```

### 2.3 Player Heavy Attack อยู่ใน patch เฉพาะ

ไฟล์หลัก:

```text
last-blade-trial/player_nameless_sprite_patch.gd
```

ไฟล์นี้เพิ่มระบบ Charged Heavy Attack โดยไม่แก้ player.gd ตรง ๆ

สถานะที่เกี่ยวข้อง:

```text
is_charging_heavy_attack
is_releasing_heavy_attack
is_heavy_recovering
heavy_charge_phase
```

ระบบ Combat Stance Memory ต้องไม่ทำให้ Heavy Attack animation ถูกแทรกหรือถูกตัดผิดจังหวะ

---

## 3. นิยาม animation ใหม่

ให้เพิ่ม animation ใหม่ชื่อ:

```text
combat_idle
```

ความหมาย:

```text
idle
= ท่ายืนปกติ สงบ ดาบต่ำ หรือยังไม่เข้าสู่โหมดปะทะเต็มตัว

combat_idle
= ท่าพร้อมสู้หลังเกิดการปะทะ ยกดาบพร้อมตอบโต้ แต่ยังไม่ใช่ท่าโจมตี
```

ห้ามใช้ `combat_idle` แทน `idle` เดิมทั้งหมด เพราะจะทำให้ Player อยู่ในท่าพร้อมสู้ตลอดเวลา

---

## 4. พฤติกรรมเป้าหมายแบบละเอียด

### 4.1 เริ่มสู้จริง

เมื่อ Duel เริ่มและ Player ยังไม่ได้โจมตีหรือโดนโจมตี:

```text
Player animation = idle
```

แม้จะมี Boss อยู่ตรงหน้าแล้วก็ตาม

เป้าหมายทางอารมณ์:

```text
ตัวละครดูนิ่ง เงียบ และรอจังหวะ ไม่ใช่ยืนเกร็งพร้อมฟันตั้งแต่ต้น
```

### 4.2 เดิน / ถอยหลัง

เมื่อผู้เล่นกดเคลื่อนที่:

```text
ถ้ามี run/back animation → ใช้ run/back ตามระบบเดิม
ถ้าหยุดเดินและยังไม่มี combat trigger → กลับ idle
```

Movement ไม่ควรเป็นตัวปลุก `combat_idle`

ตัวอย่าง:

```text
เริ่มสู้ → idle
กดเดินขวา → run
ปล่อยเดิน → idle
กดเดินซ้าย → run หรือ back
ปล่อยเดิน → idle
```

### 4.3 Dash

เมื่อผู้เล่นกด Dash:

```text
ระหว่าง dash → ใช้พฤติกรรมเดิมของ visual manager
หลัง dash จบ → กลับ idle ถ้ายังไม่มี combat trigger
```

Dash ไม่ควรเป็นตัวปลุก `combat_idle`

เหตุผล:

```text
Dash เป็น movement/positioning ไม่ใช่การปะทะโดยตรง
```

### 4.4 โจมตีปกติ

เมื่อผู้เล่นกด Attack:

```text
ระหว่างโจมตี → attack_1 / attack_2 / attack_3 ตาม combo
หลังโจมตีจบ → combat_idle ชั่วคราว
ครบเวลา → idle
```

ระยะเวลาที่แนะนำ:

```text
หลัง Hit 1 → combat_idle 1.6 วินาที
หลัง Hit 2 → combat_idle 1.8 วินาที
หลัง Hit 3 → combat_idle 2.4 วินาที
```

เหตุผล:

```text
Hit 3 เป็นท่าหนักกว่าและ commit มากกว่า จึงควรค้างความพร้อมสู้นานกว่าเล็กน้อย
```

### 4.5 Charged Heavy Attack

เมื่อผู้เล่นใช้ Heavy Attack:

```text
ระหว่างชาร์จ → heavy_charge_start / heavy_charge_loop
ตอนปล่อย → heavy_release
ตอน recovery → heavy_recovery_hold
หลัง heavy จบ → combat_idle ชั่วคราว
ครบเวลา → idle
```

ระยะเวลาที่แนะนำ:

```text
หลัง Heavy Attack จบ → combat_idle 3.0 วินาที
```

เหตุผล:

```text
Heavy Attack เป็นท่าใหญ่ ใช้ resource และมีความเสี่ยงสูง จึงควรให้ Player ดูยังอยู่ในโหมดระวังตัวหลังปล่อยท่า
```

### 4.6 โดนโจมตี

เมื่อ Player โดนโจมตีจริง:

```text
ช่วงโดนตี / knockback → ใช้ hurt หรือ idle fallback ตาม asset ที่มี
หลังพ้นจังหวะโดนตี → combat_idle ชั่วคราว
ครบเวลา → idle
```

ระยะเวลาที่แนะนำ:

```text
หลังโดนโจมตี → combat_idle 2.5 วินาที
```

เหตุผล:

```text
หลังถูกโจมตี Player ควรดูตื่นตัวขึ้น เหมือนเตรียมรับมือการโจมตีถัดไป
```

### 4.7 Posture Broken

เมื่อ Player posture broken:

```text
ระหว่าง posture broken → animation posture/hurt/idle fallback ตามระบบเดิม
เมื่อฟื้นจาก posture broken → combat_idle ชั่วคราว
ครบเวลา → idle
```

ระยะเวลาที่แนะนำ:

```text
หลังฟื้นจาก posture broken → combat_idle 3.5 วินาที
```

เหตุผล:

```text
Posture broken เป็นเหตุการณ์หนักที่สุดฝั่ง Player จึงควรให้ช่วงฟื้นตัวดูระวังตัวมากกว่าปกติ
```

---

## 5. แนวทางสถาปัตยกรรมระบบ

แนะนำให้ใช้แนวคิด:

```text
Combat Stance Memory Timer
```

คือ Player จะมีตัวแปรเก็บเวลาว่า “ควรอยู่ใน combat_idle ถึงเมื่อไหร่”

ตัวแปรที่ควรเพิ่มใน Player หรือ patch:

```gdscript
# เปิด/ปิดระบบจำท่าพร้อมสู้ เพื่อ rollback ได้ง่าย
@export var combat_stance_memory_enabled: bool = true

# เวลาค้างท่าพร้อมสู้หลังเหตุการณ์ต่าง ๆ
@export var combat_stance_after_attack_time: float = 1.8
@export var combat_stance_after_combo_finisher_time: float = 2.4
@export var combat_stance_after_heavy_time: float = 3.0
@export var combat_stance_after_hurt_time: float = 2.5
@export var combat_stance_after_posture_recover_time: float = 3.5

# เวลาสิ้นสุดของสถานะพร้อมสู้ หน่วยเป็น milliseconds
var combat_stance_until_msec: int = -999999
```

ฟังก์ชันแนวคิด:

```gdscript
func enter_combat_stance_for(duration: float, reason: String = "") -> void:
    # ต่อเวลาท่าพร้อมสู้ไปข้างหน้า โดยไม่ลดเวลาที่เหลืออยู่เดิม
    pass

func is_combat_stance_memory_active() -> bool:
    # คืน true ถ้ายังอยู่ในช่วงเวลาที่ควรแสดง combat_idle
    pass

func clear_combat_stance_memory(reason: String = "") -> void:
    # ใช้ล้างสถานะเมื่อเริ่ม Duel ใหม่ / ตาย / reset scene
    pass
```

หมายเหตุ:

```text
ตัวอย่างด้านบนเป็นแนวทางออกแบบ ไม่ใช่ patch สุดท้าย
เมื่อเขียนโค้ดจริงต้องใส่คอมเมนต์ภาษาไทยกำกับทุกส่วน
```

---

## 6. ตำแหน่งที่ควร trigger combat stance

### 6.1 หลังจบ combo ปกติ

จุดที่เหมาะ:

```text
player.gd → finish_combo(sequence_id)
```

เมื่อ combo จบสมบูรณ์ ให้เรียก:

```text
enter_combat_stance_for(...)
```

หลักการ:

```text
ถ้า combo_step สุดท้ายเป็น Hit 3 → ใช้เวลานานกว่า
ถ้าเป็น Hit 1 หรือ Hit 2 → ใช้เวลาปกติ
```

ข้อควรระวัง:

```text
ต้องไม่ trigger ตอน cancel combo เพราะถูก interrupt แบบผิดธรรมชาติ
กรณี cancel จากการโดนตี ให้ใช้ trigger ฝั่ง take_damage() แทน
```

### 6.2 หลัง Heavy Attack จบ

จุดที่เหมาะ:

```text
player_nameless_sprite_patch.gd → finish_heavy_attack(sequence_id)
```

หลังคืนสถานะ Heavy สำเร็จ ให้เข้าสู่ combat stance:

```text
enter_combat_stance_for(combat_stance_after_heavy_time, "heavy_finished")
```

ข้อควรระวัง:

```text
ต้องไม่แทรก animation ระหว่าง heavy_charge / heavy_release / heavy_recovery_hold
combat_idle ต้องเริ่มหลัง Heavy จบจริงเท่านั้น
```

### 6.3 เมื่อ Player โดนโจมตี

จุดที่เหมาะ:

```text
player.gd → take_damage(amount)
```

หลังยืนยันว่าโดนดาเมจจริง ไม่ใช่หลบด้วย dash หรือ hurt invincibility ให้ trigger combat stance

ข้อควรระวัง:

```text
ถ้า is_hurt_invincible แล้ว damage ถูก ignore → ไม่ควร trigger combat stance ซ้ำ
ถ้า is_dashing แล้วหลบได้ → ไม่ควร trigger combat stance
```

### 6.4 หลังฟื้นจาก posture broken

จุดที่เหมาะ:

```text
player.gd → start_player_posture_break()
```

หลังรอ `player_posture_break_time` แล้ว Player กลับมาควบคุมได้ ให้ trigger combat stance

ข้อควรระวัง:

```text
ถ้า Player ตายระหว่าง posture broken → ไม่ควร trigger combat stance
```

### 6.5 เมื่อเริ่ม Duel ใหม่ / reset scene

จุดที่เหมาะ:

```text
_ready()
หรือ manager ที่เริ่ม Duel จริง
```

ควรล้าง combat stance memory เพื่อให้เริ่มด้วย idle เสมอ

```text
clear_combat_stance_memory("ready")
```

---

## 7. การปรับ visual manager

ไฟล์หลัก:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

สิ่งที่ควรเพิ่ม:

```text
@export var combat_idle_animation_name: StringName = &"combat_idle"
@export var combat_idle_frames_folder: String = "res://assets/sprites/player/nameless_blade/frames/combat_idle"
@export var combat_idle_animation_speed: float = 8.0
@export var combat_idle_animation_loop: bool = true
```

แนวทางโหลด asset:

```text
โหลด combat_idle แบบ optional
ถ้าไม่มี asset ให้ fallback เป็น idle
```

ตำแหน่ง priority ใน `choose_player_animation()` ที่แนะนำ:

```text
1. dead
2. posture broken
3. knocked back / hurt
4. dashing
5. heavy attack
6. normal attack
7. movement run/back
8. combat_idle ถ้า combat stance memory active และไม่ได้เคลื่อนที่
9. idle
```

เหตุผลที่ให้ movement มาก่อน combat_idle:

```text
เกมเป็น action บนมือถือ การอ่าน movement ต้องชัดกว่า mood
ถ้าผู้เล่นเดินอยู่ ควรเห็น run/back
ถ้าหยุดเดินในช่วง combat memory ค่อยเห็น combat_idle
```

ตัวอย่างพฤติกรรม:

```text
โจมตี → attack_1 → combat_idle
ระหว่าง combat_idle กดเดิน → run
หยุดเดินก่อน timer หมด → combat_idle
timer หมด → idle
```

---

## 8. Asset ที่ต้องเตรียม

โฟลเดอร์ใหม่ที่ควรสร้าง:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/combat_idle
```

ควรมี `.gitkeep` เพื่อให้ Git ติดตามโฟลเดอร์ได้ แม้ยังไม่มี frame จริง

จำนวน frame ที่แนะนำ:

```text
4-6 frames
```

คุณลักษณะของภาพ:

```text
- 2D side-view dark anime pixel art
- ใช้ตัวละคร The Nameless Blade ดีไซน์เดิม
- ท่ายืนพร้อมสู้ แต่ไม่ใช่ท่าโจมตี
- ดาบอยู่ในตำแหน่งพร้อมป้องกัน/ตอบโต้
- ผ้าคลุมหรือ scarf ขยับเล็กน้อย
- silhouette อ่านง่ายบนมือถือ
- ไม่ควรมี slash trail
- ไม่ควรมีเอฟเฟกต์ heavy charge
- ไม่ควรดูเหมือน run/back/attack
```

ชื่อไฟล์ frame ที่แนะนำ:

```text
nameless_combat_idle_0001.png
nameless_combat_idle_0002.png
nameless_combat_idle_0003.png
nameless_combat_idle_0004.png
```

หรือใช้ชื่อที่เรียงลำดับชัดเจนแบบเดียวกับ asset ชุดอื่น ๆ

---

## 9. ค่า balance เริ่มต้นที่แนะนำ

```text
combat_stance_after_attack_time = 1.8
combat_stance_after_combo_finisher_time = 2.4
combat_stance_after_heavy_time = 3.0
combat_stance_after_hurt_time = 2.5
combat_stance_after_posture_recover_time = 3.5
```

แนวทางปรับหลังทดสอบ:

```text
ถ้า Player ดูพร้อมสู้นานเกินไป → ลดทุกค่า 0.3-0.5 วินาที
ถ้า Player กลับ idle เร็วเกินไปหลังโจมตี → เพิ่มค่า after_attack_time
ถ้าหลังโดนตีดูไม่ตื่นตัวพอ → เพิ่มค่า after_hurt_time
ถ้า heavy ดูไม่มีน้ำหนักหลังจบท่า → เพิ่มค่า after_heavy_time
```

---

## 10. ลำดับการพัฒนาแบบปลอดภัย

### Phase 1: เพิ่มเอกสารและออกแบบ

สถานะของไฟล์นี้

```text
ยังไม่แก้โค้ด
ยังไม่เพิ่ม logic
ยังไม่เพิ่ม asset จริง
```

### Phase 2: เพิ่มโฟลเดอร์ asset

เพิ่มโฟลเดอร์:

```text
last-blade-trial/assets/sprites/player/nameless_blade/frames/combat_idle/.gitkeep
```

ยังไม่จำเป็นต้องมีภาพจริง เพราะระบบควร fallback ได้

### Phase 3: เพิ่มตัวแปรและฟังก์ชัน memory ใน Player

ไฟล์ที่เกี่ยวข้อง:

```text
last-blade-trial/player.gd
หรือ
last-blade-trial/player_nameless_sprite_patch.gd
```

ข้อเสนอ:

```text
ถ้าต้องการให้ระบบนี้ใช้กับ Player ทุก version → เพิ่มใน player.gd
ถ้าต้องการรักษา player.gd ให้ปลอดภัยเหมือน Heavy Attack → เพิ่มใน player_nameless_sprite_patch.gd ก่อน
```

ข้อเสนอของแผนนี้:

```text
เพิ่มใน player_nameless_sprite_patch.gd ก่อน
```

เหตุผล:

```text
- ลดความเสี่ยงกับ player.gd หลัก
- สอดคล้องกับแนวทาง Heavy Attack ที่เพิ่มผ่าน patch
- rollback ง่าย
```

### Phase 4: ให้ Player patch trigger memory จากเหตุการณ์สำคัญ

จุด trigger:

```text
- หลัง combo จบ
- หลัง heavy จบ
- หลังโดนดาเมจจริง
- หลังฟื้นจาก posture broken
```

ข้อควรระวัง:

```text
ถ้า override ฟังก์ชันจาก player.gd ต้องเรียก super ให้ถูกลำดับ
ห้ามทำให้ combo coroutine / heavy coroutine ทำงานซ้อนผิดจังหวะ
```

### Phase 5: เพิ่ม combat_idle ใน visual manager

เพิ่มชื่อ animation และ folder path ใน:

```text
last-blade-trial/player_animated_idle_visual_manager.gd
```

ให้โหลดแบบ optional และ fallback เป็น idle ถ้าไม่มี frame จริง

### Phase 6: ทดสอบโดยยังไม่มี asset combat_idle

ผลที่คาดหวัง:

```text
เกมต้อง compile/run ได้
ไม่มี error
ถ้าไม่มี combat_idle asset → animation fallback เป็น idle
ระบบ gameplay ห้ามพัง
```

### Phase 7: ใส่ asset combat_idle จริง

หลัง logic ผ่านแล้ว ค่อยวางภาพจริงใน folder

### Phase 8: ปรับเวลาและ priority จาก gameplay จริง

ทดสอบบน Mac/Godot ก่อน แล้วค่อยทดสอบมือถือ

---

## 11. Test Plan แบบละเอียด

### Test 1: เริ่ม Duel จริง

ขั้นตอน:

```text
1. เปิด Godot
2. Run ฉากหลัก
3. เข้า Duel จริงหลัง tutorial/intro
4. ไม่กดปุ่มใด ๆ
```

ผลที่ควรได้:

```text
Player อยู่ idle ปกติ
ไม่เข้า combat_idle เอง
```

### Test 2: เดินแล้วหยุด

ขั้นตอน:

```text
1. กดซ้ายหรือขวา
2. ปล่อยปุ่มเดิน
```

ผลที่ควรได้:

```text
ตอนเดิน → run/back ตามระบบเดิม
ตอนหยุด → idle
ไม่เข้า combat_idle
```

### Test 3: Dash แล้วหยุด

ขั้นตอน:

```text
1. กด Dash
2. รอ Dash จบ
3. ไม่กดโจมตี
```

ผลที่ควรได้:

```text
หลัง Dash จบ → idle
ไม่เข้า combat_idle
```

### Test 4: โจมตี 1 ครั้ง

ขั้นตอน:

```text
1. กด Attack สั้น ๆ หนึ่งครั้ง
2. รอ animation attack จบ
3. ไม่กดปุ่มต่อ
```

ผลที่ควรได้:

```text
ระหว่างโจมตี → attack_1
หลังโจมตี → combat_idle ประมาณ 1.8 วินาที
ครบเวลา → idle
```

### Test 5: Combo 3 hit

ขั้นตอน:

```text
1. กด Attack ต่อเนื่องจนออก Hit 3
2. รอ combo จบ
```

ผลที่ควรได้:

```text
ระหว่าง combo → attack_1 / attack_2 / attack_3
หลัง Hit 3 จบ → combat_idle ประมาณ 2.4 วินาที
ครบเวลา → idle
```

### Test 6: Heavy Attack

ขั้นตอน:

```text
1. สะสม Focus ให้พอ
2. กด Attack ค้างจน HEAVY READY
3. ปล่อยปุ่ม
4. รอ Heavy จบ
```

ผลที่ควรได้:

```text
ระหว่างชาร์จ → heavy_charge_start / heavy_charge_loop
ตอนปล่อย → heavy_release
ตอน recovery → heavy_recovery_hold
หลังจบ → combat_idle ประมาณ 3.0 วินาที
ครบเวลา → idle
```

### Test 7: โดนบอสโจมตี

ขั้นตอน:

```text
1. ยืนให้บอสโจมตีโดน
2. รอ knockback/hurt จบ
```

ผลที่ควรได้:

```text
หลังโดนตีจริง → combat_idle ประมาณ 2.5 วินาที
ครบเวลา → idle
```

### Test 8: Dash หลบการโจมตี

ขั้นตอน:

```text
1. กด Dash หลบบอสจนไม่โดนดาเมจ
```

ผลที่ควรได้:

```text
ถ้าไม่โดนดาเมจจริง → ไม่ควรเข้า combat_idle จากเหตุการณ์โดนตี
```

### Test 9: Posture Broken แล้วฟื้น

ขั้นตอน:

```text
1. ทำให้ Player posture broken
2. รอจนฟื้น
```

ผลที่ควรได้:

```text
หลังฟื้น → combat_idle ประมาณ 3.5 วินาที
ครบเวลา → idle
```

### Test 10: ยังไม่มี asset combat_idle

ขั้นตอน:

```text
1. ลอง run เกมโดยยังไม่มี png ใน frames/combat_idle
```

ผลที่ควรได้:

```text
ไม่มี error
ระบบ fallback เป็น idle
เกมยังเล่นได้ปกติ
```

---

## 12. Acceptance Criteria

ระบบนี้ถือว่าผ่านเมื่อ:

```text
- เริ่ม Duel จริงแล้ว Player อยู่ idle
- เดิน/หยุดเดินแล้วกลับ idle ถ้าไม่ได้โจมตีหรือโดนโจมตี
- Dash แล้วกลับ idle ถ้าไม่ได้โจมตีหรือโดนโจมตี
- หลังโจมตีจบ Player เข้า combat_idle ชั่วคราว
- หลังโดนโจมตีจริง Player เข้า combat_idle ชั่วคราว
- หลัง Heavy Attack จบ Player เข้า combat_idle ชั่วคราว
- หลังครบเวลา Player กลับ idle
- ถ้ายังไม่มี asset combat_idle เกมไม่ error
- Combo เดิมไม่พัง
- Heavy Attack เดิมไม่พัง
- Focus Finisher เดิมไม่พัง
- TouchControls เดิมไม่พัง
```

---

## 13. Rollback Plan

ต้องมี export flag เพื่อปิดระบบได้ทันที:

```gdscript
@export var combat_stance_memory_enabled: bool = true
```

ถ้าพบปัญหา ให้ตั้งเป็น:

```gdscript
combat_stance_memory_enabled = false
```

ผลที่ควรได้เมื่อปิดระบบ:

```text
visual manager กลับไปเลือก animation ตามระบบเดิม
ไม่มี combat_idle memory
ระบบโจมตี/เดิน/dash/โดนตีทำงานเหมือนก่อนหน้า
```

---

## 14. ความเสี่ยงและข้อควรระวัง

### 14.1 ความเสี่ยง: animation priority ซ้อนกับ attack/heavy

แนวทางป้องกัน:

```text
ให้ attack และ heavy มี priority สูงกว่า combat_idle เสมอ
combat_idle ใช้เฉพาะตอน Player ไม่ได้ทำ action สำคัญ
```

### 14.2 ความเสี่ยง: movement ดูลื่นพื้น

แนวทางป้องกัน:

```text
ถ้า Player มี velocity.x มากพอ ให้ใช้ run/back ก่อน combat_idle
```

### 14.3 ความเสี่ยง: timer ถูกต่อเวลาซ้ำมากเกินไป

แนวทางป้องกัน:

```text
enter_combat_stance_for() ควรใช้ max() ระหว่างเวลาเดิมกับเวลาใหม่
ไม่ควรลดเวลาที่เหลืออยู่โดยไม่ตั้งใจ
```

### 14.4 ความเสี่ยง: trigger ตอน damage ถูก ignore

แนวทางป้องกัน:

```text
ให้ trigger combat stance เฉพาะหลังยืนยันว่า Player โดน damage จริงแล้วเท่านั้น
ถ้า dash หลบได้ หรือ hurt invincible ignore damage ไม่ควร trigger
```

### 14.5 ความเสี่ยง: asset หายแล้ว error

แนวทางป้องกัน:

```text
โหลด combat_idle แบบ optional
ถ้าไม่มี frame ให้ fallback เป็น idle
```

---

## 15. ข้อเสนอด้านอารมณ์และศิลป์

ท่า `idle` ควรสื่อว่า:

```text
นิ่ง เงียบ เยือกเย็น เหมือนนักดาบที่ยังไม่เผยเจตนา
```

ท่า `combat_idle` ควรสื่อว่า:

```text
เพิ่งผ่านการปะทะ กำลังระวังตัว พร้อมตอบโต้ แต่ยังไม่โจมตี
```

ความแตกต่างที่ควรเห็นชัด:

```text
idle:
- ดาบต่ำกว่า
- ไหล่ผ่อนกว่า
- ผ้านิ่งกว่า
- อารมณ์สงบกว่า

combat_idle:
- ดาบยกขึ้นกว่า
- ขายืนแน่นกว่า
- ลำตัวโน้มพร้อมตอบโต้เล็กน้อย
- ผ้าหรือ scarf ขยับมากขึ้นเล็กน้อย
```

ข้อห้าม:

```text
- ห้ามทำ combat_idle ให้ดูเหมือน attack frame
- ห้ามมี slash trail
- ห้ามมี heavy charge aura
- ห้ามทำให้ silhouette เปลี่ยนจนเหมือนคนละตัวละคร
```

---

## 16. ขั้นตอนสำหรับมือใหม่เมื่อถึงเวลาลงโค้ดจริง

เมื่อจะเริ่มทำจริง ให้ทำเป็น commit ย่อย ๆ ตามนี้:

```text
Commit 1: Add combat idle asset folder
Commit 2: Add combat stance memory variables/functions to player patch
Commit 3: Trigger combat stance after attack/heavy/hurt/posture recover
Commit 4: Add combat_idle animation support to visual manager
Commit 5: Tune combat stance timing after smoke test
```

ห้ามรวมทุกอย่างใน commit เดียว เพราะถ้ามี error จะไล่ย้อนยาก

---

## 17. สรุปแนวทางสุดท้าย

ระบบที่ต้องการคือ:

```text
idle = สถานะปกติของนักดาบนิ่ง ๆ
combat_idle = สถานะพร้อมสู้หลังเกิดการปะทะ
movement/dash = ไม่ปลุก combat_idle เอง
attack/take damage/heavy/posture recover = ปลุก combat_idle ด้วย timer
ครบเวลา = กลับ idle
```

แนวทางนี้เหมาะกับ Last Blade Trial / ดาบไร้นาม เพราะช่วยให้ตัวละครมีน้ำหนัก มีจังหวะสงบก่อนปะทะ และทำให้ช่วงต่อสู้จริงรู้สึกมีความหมายมากขึ้น
