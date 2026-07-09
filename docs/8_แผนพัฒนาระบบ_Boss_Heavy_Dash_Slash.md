# แผนพัฒนาระบบ Boss Heavy Dash Slash

เกม: **Last Blade Trial / ดาบไร้นาม**  
ระบบที่พัฒนา: **Boss Heavy Dash Slash / ท่าหนักพุ่งฟาดดาบของบอส**  
ตัวละคร: **Broken Master / อาจารย์ดาบผู้แตกสลาย**  
สถานะเอกสาร: แผนออกแบบก่อนลงมือแก้โค้ด  
เป้าหมายหลัก: เพิ่มท่า Heavy Attack 2 ให้บอส โดยใช้ sprite / animation เดียวกับ Heavy Attack 1 แต่เพิ่มการพุ่งตัวไปข้างหน้าในจังหวะฟาดจริง และแบ่งพื้นที่ดาเมจเป็น path zone กับ endpoint zone

---

## 1. เป้าหมายของระบบ

ระบบนี้มีเป้าหมายเพื่อเพิ่มมิติให้บอส Broken Master มีท่าหนักที่ไม่ใช่แค่ฟันอยู่กับที่ แต่เป็นท่าคุมพื้นที่และลงโทษตำแหน่งยืนของผู้เล่น

แนวคิดหลัก:

```text
บอส wind-up ท่าหนัก
→ ถึงจังหวะฟาดจริง
→ บอสพุ่งตัวไปข้างหน้า
→ ถ้า Player อยู่ในเส้นทางพุ่ง จะโดนดาเมจปกติ
→ ถ้า Player อยู่บริเวณปลายทางที่บอสพุ่งไปถึง จะโดนดาเมจทวีคูณ
```

ชื่อท่าที่ใช้ในโค้ดแนะนำ:

```text
heavy_dash_slash
```

ชื่อเชิงออกแบบ:

```text
Heavy Dash Slash
Heavy Lunge Slash
Boss Heavy Attack 2
พุ่งฟาดดาบ
```

เหตุผลเชิงเกมเพลย์:

```text
- เพิ่มท่าลงโทษผู้เล่นที่ถอยเป็นเส้นตรงโดยไม่อ่านจังหวะ
- บังคับให้ผู้เล่นใช้ Dash เพื่อ reposition ไม่ใช่แค่ถอยห่าง
- ทำให้ Player Heavy Attack ต้องใช้หลังอ่านช่องว่างจริง ไม่ใช่กดค้างได้ทุกสถานการณ์
- เพิ่มความแตกต่างระหว่าง Heavy Slash เดิมกับ Heavy Attack 2
- ใช้ asset เดิมได้ก่อน แต่เพิ่มความรู้สึกใหม่ผ่าน movement และ damage zone
```

---

## 2. สภาพระบบบอสปัจจุบันที่เกี่ยวข้อง

### 2.1 ไฟล์หลักของบอส

ไฟล์หลัก:

```text
last-blade-trial/BossBrokenMaster.gd
```

Scene บอสใช้ patch:

```text
last-blade-trial/boss_broken_master_player_lookup_patch.gd
```

โดย patch นี้ `extends "res://BossBrokenMaster.gd"` และเน้นหา Player แบบ robust ไม่ได้เปลี่ยน balance หลักของบอส

### 2.2 ระบบท่าบอสปัจจุบัน

บอสมีระบบเลือกท่าในฟังก์ชัน:

```text
apply_attack_pattern(pattern_name)
choose_attack_pattern()
choose_random_attack_pattern()
```

ท่าที่มีอยู่:

```text
normal_slash
quick_slash
delayed_slash
heavy_slash
```

ท่า Heavy Slash เดิมมีบทบาท:

```text
- เป็นท่าหนัก
- Parry ไม่ได้
- ขึ้น hint DASH!
- มี wind-up นานกว่าท่าปกติ
- มี final frame hold หลังฟัน เพื่อเปิดช่องให้ Player สวนกลับ
```

### 2.3 ระบบ hitbox ปัจจุบัน

ระบบโจมตีปัจจุบันใช้ `AttackHitbox` เดิมของบอส:

```text
BossBrokenMaster/AttackHitbox
BossBrokenMaster/AttackHitbox/CollisionShape2D
```

Flow ปัจจุบันโดยสรุป:

```text
บอสเลือกท่า
→ wind-up
→ เปิด attack_shape
→ รอหนึ่ง physics frame
→ ตรวจ get_overlapping_areas()
→ รอ active time
→ ปิด attack_shape
→ final frame hold เฉพาะ heavy_slash
→ cooldown
```

ข้อจำกัดของระบบเดิม:

```text
- AttackHitbox เหมาะกับท่าฟันอยู่กับที่
- ยังไม่มีระบบตรวจเส้นทางพุ่งผ่าน
- ยังไม่มีระบบแยก damage zone ระหว่าง path กับ endpoint
- ถ้าบอสพุ่งเร็วมากด้วย hitbox เดิมอย่างเดียว อาจเกิดปัญหา Player อยู่ในเส้นทางแต่ hitbox ตรวจไม่ทัน
```

### 2.4 ระบบดาเมจปัจจุบัน

ปัจจุบัน `_try_hit_area(area)` ใช้ `current_attack_damage` เป็นดาเมจหลักของท่าปัจจุบัน และใช้ `has_hit_player` เพื่อกันไม่ให้ท่าเดียวโดนซ้ำหลายครั้ง

แนวคิดนี้ควรรักษาไว้:

```text
หนึ่งท่าโจมตีควรทำดาเมจ Player ได้ครั้งเดียว
```

สำหรับ Heavy Dash Slash ต้องเพิ่ม logic ว่า:

```text
ถ้าโดน endpoint zone → ใช้ดาเมจทวีคูณ
ถ้าโดน path zone → ใช้ดาเมจปกติ
```

แต่ยังคงกฎ:

```text
โดนได้ครั้งเดียวต่อหนึ่งครั้งที่บอสใช้ท่า
```

---

## 3. นิยามท่า Heavy Dash Slash

### 3.1 ความหมายของท่า

`heavy_dash_slash` คือท่าหนักที่บอสพุ่งตัวไปข้างหน้าในจังหวะฟาดดาบจริง

ลำดับภาพรวม:

```text
1. บอสหยุดนิ่งและ wind-up นานพอให้ผู้เล่นอ่านได้
2. ขึ้น hint เตือนว่าเป็นท่าพุ่งที่ต้องหลบออกจากเส้นทาง
3. เมื่อถึงเฟรมฟาดจริง บอสพุ่งไปข้างหน้าอย่างรวดเร็ว
4. ระหว่างพุ่ง มีการตรวจ path zone
5. เมื่อถึงปลายทาง มีการตรวจ endpoint zone
6. หลังจบท่า บอสค้างเฟรมท้าย / recovery เพื่อเปิดช่องให้ Player สวนกลับ
```

### 3.2 ความต่างจาก Heavy Slash เดิม

```text
heavy_slash
= ท่าหนักอยู่กับที่ / โดนถ้ายืนใกล้ / ต้อง Dash หลบจังหวะฟัน

heavy_dash_slash
= ท่าหนักพุ่งกินพื้นที่ / โดนถ้ายืนในเส้นทาง / โดนหนักถ้ายืนตรงปลายทาง
```

### 3.3 บทบาทใน combat loop

ท่านี้ควรมีบทบาทเป็น:

```text
- ท่าลงโทษการถอยหลังเป็นเส้นตรง
- ท่าคุมพื้นที่แนวนอน
- ท่าบังคับให้ Player Dash ข้ามหลังบอสหรือออกจากระยะ endpoint
- ท่าลงโทษ Player ที่พยายามชาร์จ Heavy Attack ผิดจังหวะ
```

บทบาทที่ไม่ควรเป็น:

```text
- ไม่ควรเป็นท่าที่ออกถี่มาก
- ไม่ควรเป็นท่าที่ไม่มีสัญญาณเตือน
- ไม่ควรเร็วเท่า Quick Slash
- ไม่ควรแรงระดับฆ่าผู้เล่นทันทีจาก HP เต็ม
- ไม่ควรทำให้ Heavy Slash เดิมหมดความหมาย
```

---

## 4. Damage Zone Design

ระบบนี้ควรแบ่งพื้นที่อันตรายเป็น 2 โซน

### 4.1 Path Zone

Path Zone คือพื้นที่ตั้งแต่ตำแหน่งเริ่มพุ่งของบอสไปจนถึงตำแหน่งปลายทาง

ถ้า Player อยู่ใน path zone ระหว่างบอสพุ่ง:

```text
โดนดาเมจปกติของท่า
```

ตัวอย่าง:

```text
heavy_dash_attack_damage = 22
```

ความหมายเชิงเกมเพลย์:

```text
ผู้เล่นยืนขวางทางพุ่ง หรือ Dash ไม่พ้นเส้นทางพุ่ง จึงโดนฟาดผ่าน
```

### 4.2 Endpoint Zone

Endpoint Zone คือพื้นที่รอบตำแหน่งปลายทางที่บอสพุ่งไปถึง

ถ้า Player อยู่ใน endpoint zone:

```text
โดนดาเมจทวีคูณ
```

ตัวอย่าง:

```text
heavy_dash_endpoint_damage_multiplier = 1.75
```

ถ้าดาเมจพื้นฐานเป็น 22:

```text
22 × 1.75 ≈ 39 damage
```

ความหมายเชิงเกมเพลย์:

```text
ผู้เล่นถอยไปอยู่ตรงจุดที่บอสฟาดลงเต็มแรงพอดี จึงโดนหนักกว่าปกติ
```

### 4.3 ลำดับความสำคัญของการตรวจดาเมจ

ต้องตรวจ Endpoint ก่อน Path

```text
1. ถ้า Player อยู่ endpoint zone → endpoint damage
2. else ถ้า Player อยู่ path zone → normal damage
3. else → ไม่โดน
```

เหตุผล:

```text
Endpoint เป็นจุดอันตรายสูงสุด ถ้า Player อยู่บริเวณนั้นต้องถือว่าโดนทวีคูณ ไม่ใช่ดาเมจปกติ
```

---

## 5. ค่า Balance เริ่มต้นที่แนะนำ

ค่าเริ่มต้นสำหรับทดลอง:

```gdscript
# โอกาสที่บอสจะเลือก Heavy Dash Slash ตอนสุ่มท่า
@export var heavy_dash_attack_chance: float = 0.12

# ดาเมจพื้นฐานของ Heavy Dash Slash เมื่อ Player อยู่ในเส้นทางพุ่ง
@export var heavy_dash_attack_damage: int = 22

# ตัวคูณดาเมจเมื่อ Player อยู่ตรง endpoint zone
@export var heavy_dash_endpoint_damage_multiplier: float = 1.75

# ระยะ wind-up ก่อนบอสพุ่งฟาด ต้องอ่านได้ชัดกว่าท่าปกติ
@export var heavy_dash_attack_windup_time: float = 1.20

# ระยะเวลาที่บอสใช้พุ่งจากจุดเริ่มไปปลายทาง
@export var heavy_dash_attack_dash_time: float = 0.22

# ระยะทางพุ่งของบอส หน่วยเป็น pixel
@export var heavy_dash_attack_distance: float = 210.0

# รัศมีบริเวณปลายทางที่ถือว่าโดนดาเมจทวีคูณ
@export var heavy_dash_endpoint_radius: float = 60.0

# ความกว้างเชิงแกน X สำหรับ path zone เพื่อให้ตรวจโดนง่ายและไม่ pixel-perfect
@export var heavy_dash_path_extra_margin: float = 36.0

# Cooldown เพิ่มหลังท่า เพื่อให้มีช่องสวนกลับ
@export var heavy_dash_attack_cooldown_bonus: float = 0.70

# เวลาค้างเฟรมท้ายหลังพุ่งฟาดจบ เพื่อเปิดช่องให้ Player สวนกลับ
@export var heavy_dash_final_frame_hold_time: float = 0.90
```

แนวทางปรับหลังทดสอบ:

```text
ถ้าท่ายากหลบเกินไป → ลด heavy_dash_attack_distance หรือเพิ่ม wind-up
ถ้าท่าไม่อันตรายพอ → เพิ่ม endpoint multiplier หรือ endpoint radius
ถ้าท่าพุ่งเร็วเกินจนอ่านไม่ทัน → เพิ่ม heavy_dash_attack_dash_time เล็กน้อย
ถ้าผู้เล่นสวนกลับไม่ได้ → เพิ่ม heavy_dash_final_frame_hold_time
ถ้าบอสใช้ท่านี้บ่อยเกินไป → ลด heavy_dash_attack_chance
```

---

## 6. Telegraph / Hint Design

เพราะท่านี้ใช้ sprite เดียวกับ Heavy Slash เดิม จึงต้องมีสัญญาณแยกให้ผู้เล่นอ่านออก

### 6.1 Hint Text

Heavy Slash เดิมใช้:

```text
DASH!
```

Heavy Dash Slash ควรใช้ข้อความที่สื่อว่าไม่ใช่แค่ dash ตามจังหวะ แต่ต้องออกจากเส้นทางพุ่ง

ตัวเลือก:

```text
DASH OUT!
LUNGE!
GET OUT!
```

ข้อเสนอเริ่มต้น:

```text
DASH OUT!
```

### 6.2 สีของ hint / modulate

Heavy Slash เดิมใช้สีส้มแดง

Heavy Dash Slash ควรใช้สีที่ต่างเล็กน้อย เช่น:

```gdscript
Color(1.0, 0.10, 0.25, 1.0)
```

หรือแดงเข้ม / ม่วงแดง เพื่อสื่อว่าเป็นท่าหนักพิเศษ

### 6.3 VFX ชั่วคราว

ก่อนมี sprite/VFX จริง ควรใช้ placeholder เช่น:

```text
- เส้น slash effect ยาวกว่าเดิม
- ghost trail หลังบอสพุ่ง
- camera shake ตอนเริ่มพุ่งและตอนถึง endpoint
```

แต่ระยะแรกไม่จำเป็นต้องทำ VFX เต็ม ให้เน้น gameplay ก่อน

---

## 7. Movement Design

### 7.1 ไม่แนะนำให้ใช้ move_and_slide ปกติสำหรับท่านี้

บอสปัจจุบันชนทั้ง World และ Player ตาม collision mask ปกติ

ถ้าพุ่งด้วย `move_and_slide()` โดยตรง อาจเกิดปัญหา:

```text
- บอสชน Player แล้วหยุดก่อนถึง endpoint
- endpoint zone เพี้ยนเพราะบอสไปไม่ถึงตำแหน่งที่คำนวณไว้
- Player อาจดันบอสหรือทำให้ตำแหน่งพุ่งไม่สม่ำเสมอ
- บอสอาจติด collision จนท่าไม่อ่านง่าย
```

### 7.2 แนวทางที่แนะนำ: Controlled Dash Movement

ให้บอสพุ่งด้วยการคำนวณตำแหน่งเอง

หลักการ:

```text
1. บันทึกตำแหน่งเริ่มต้นของบอส
2. คำนวณตำแหน่งปลายทางจาก facing_direction × heavy_dash_attack_distance
3. clamp ตำแหน่งปลายทางให้อยู่ใน arena
4. ระหว่าง dash ค่อย ๆ interpolate global_position.x จาก start ไป end
5. ตรวจ damage zone ระหว่างการพุ่ง
```

เหตุผล:

```text
- บอสไปถึงตำแหน่งปลายทางได้แน่นอน
- Path zone และ endpoint zone คำนวณง่าย
- ท่ามีจังหวะสม่ำเสมอ เหมาะกับ boss pattern
- ลดปัญหา collision ดันกันกับ Player
```

### 7.3 การ clamp ขอบสนาม

ต้องใช้ `arena_manager.clamp_node_x(self)` หรือคำนวณ `clamp()` จาก `arena_min_x` / `arena_max_x`

ถ้า endpoint เกินขอบสนาม:

```text
ให้ endpoint ถูก clamp กลับมาอยู่ในสนาม
Path zone ต้องใช้ endpoint หลัง clamp แล้วเท่านั้น
```

---

## 8. Hit Detection Design

### 8.1 ทำไมไม่ควรใช้ AttackHitbox เดิมอย่างเดียว

ถ้าบอสพุ่งเร็วในเวลา 0.22 วินาที hitbox อาจข้ามผ่าน Player ระหว่าง physics frame ได้

ปัญหาที่อาจเกิด:

```text
Player อยู่ในเส้นทางจริง แต่ไม่เกิด area_entered
```

ดังนั้นควรใช้การคำนวณตำแหน่ง Player เสริมด้วย

### 8.2 วิธีตรวจ Path Zone แบบง่าย

เพราะเกมเป็น side-view แกน X เป็นหลัก ให้ตรวจดังนี้:

```text
start_x = ตำแหน่งเริ่มพุ่งของบอส
end_x = ตำแหน่งปลายทางของบอส
player_x = ตำแหน่ง Player ปัจจุบัน

path_min_x = min(start_x, end_x) - heavy_dash_path_extra_margin
path_max_x = max(start_x, end_x) + heavy_dash_path_extra_margin

ถ้า player_x อยู่ระหว่าง path_min_x ถึง path_max_x
และระยะ Y ใกล้กันพอ
→ ถือว่าอยู่ใน path zone
```

เนื่องจากเกมนี้ตัวละครอยู่บนพื้นเดียวกันเป็นหลัก ค่า Y อาจตรวจแบบง่าย:

```text
abs(player.global_position.y - global_position.y) <= 90
```

หรือถ้าต้องการง่ายกว่านั้น ระยะแรกอาจไม่ตรวจ Y ก็ได้

### 8.3 วิธีตรวจ Endpoint Zone

```text
endpoint_x = ตำแหน่งปลายทางของบอส
player_x = ตำแหน่ง Player

ถ้า abs(player_x - endpoint_x) <= heavy_dash_endpoint_radius
→ ถือว่าอยู่ endpoint zone
```

ควรตรวจ endpoint ก่อน path

### 8.4 กันดาเมจซ้ำ

ใช้ `has_hit_player` เหมือนระบบเดิม

กฎ:

```text
ถ้า has_hit_player == true → ไม่ทำดาเมจซ้ำ
ถ้า endpoint โดนแล้ว → จบท่าในแง่ดาเมจ
ถ้า path โดนแล้ว → ไม่ควรโดน endpoint ซ้ำในท่าเดียวกัน
```

หมายเหตุ:

```text
ระยะแรกให้โดนได้ครั้งเดียวต่อท่า เพื่อให้ระบบยุติธรรมและอ่านง่าย
```

---

## 9. Flow ที่ควรเป็นในโค้ด

### 9.1 เพิ่ม pattern ใหม่

เพิ่มชื่อ pattern:

```text
heavy_dash_slash
```

เพิ่มใน:

```text
apply_attack_pattern()
choose_random_attack_pattern()
choose_non_quick_attack_pattern()
debug_forced_attack_pattern enum
register_attack_pattern_choice() ถ้าต้องการนับ gap เพิ่มเติม
```

### 9.2 apply_attack_pattern() สำหรับ heavy_dash_slash

แนวคิด:

```gdscript
"heavy_dash_slash":
    current_attack_name = "heavy_dash_slash"
    current_attack_can_be_parried = false
    current_attack_damage = heavy_dash_attack_damage
    current_attack_windup_time = heavy_dash_attack_windup_time
    current_attack_active_time = heavy_dash_attack_dash_time
    current_attack_cooldown = attack_cooldown + heavy_dash_attack_cooldown_bonus
    current_attack_hint_text = "DASH OUT!"
    current_attack_hint_color = Color(1.0, 0.10, 0.25, 1.0)
```

### 9.3 แยก execution ของ heavy_dash_slash

ใน `attack()` หลัง wind-up จบและก่อน flow เปิด hitbox เดิม ควรเช็ก:

```text
ถ้า current_attack_name == "heavy_dash_slash"
→ เรียก perform_heavy_dash_slash(my_attack_id)
→ return
```

เหตุผล:

```text
ท่านี้ไม่เหมือนท่าเดิม เพราะต้องพุ่งตัวและตรวจ path/endpoint เอง
ไม่ควรฝืนยัดลง flow เปิด hitbox เดิมทั้งหมด
```

### 9.4 ฟังก์ชันใหม่ที่ควรมี

```text
perform_heavy_dash_slash(my_attack_id)
get_heavy_dash_start_x()
get_heavy_dash_end_x()
check_heavy_dash_damage_zone(start_x, end_x)
apply_heavy_dash_damage_to_player(is_endpoint_hit)
show_heavy_dash_slash_effect(start_x, end_x)
```

ระยะแรกอาจทำให้น้อยกว่านี้ได้ แต่ควรแยกฟังก์ชันเพื่ออ่านง่ายและ debug ง่าย

---

## 10. Debug Mode

ต้องเพิ่ม `heavy_dash_slash` เข้า enum debug

ปัจจุบัน enum ควรขยายเป็น:

```gdscript
@export_enum("random", "normal_slash", "heavy_slash", "heavy_dash_slash", "delayed_slash", "quick_slash") var debug_forced_attack_pattern: String = "random"
```

วิธีใช้:

```text
เปิด debug_force_attack_pattern_enabled = true
ตั้ง debug_forced_attack_pattern = heavy_dash_slash
Run เกม
บอสจะใช้ท่านี้ซ้ำ ๆ เพื่อจูนระยะและดาเมจ
```

เหตุผล:

```text
ถ้าไม่เพิ่ม debug force จะทดสอบยากมาก เพราะต้องรอสุ่มออก
```

---

## 11. Interaction กับระบบอื่น

### 11.1 Interaction กับ Parry / Deflect

ท่านี้ควร Parry ไม่ได้

```text
current_attack_can_be_parried = false
```

ถ้าผู้เล่นพยายาม Parry ระหว่าง wind-up:

```text
ขึ้น feedback DASH ONLY! หรือ DASH OUT!
```

ควรใช้ระบบตรวจ wrong parry เดิมได้ เพราะระบบเดิมตรวจท่าที่ `current_attack_can_be_parried == false`

### 11.2 Interaction กับ Dash ของ Player

วิธีแก้ท่าที่ควรเป็น:

```text
- Dash ข้ามหลังบอส
- Dash ออกจาก endpoint zone
- Dash ให้หลุด path zone ก่อนบอสพุ่งถึง
```

สิ่งที่ไม่ควรให้ปลอดภัยเสมอ:

```text
- ถอยหลังตรง ๆ แบบไม่อ่านระยะ
- ยืนชาร์จ Heavy กลางทางพุ่ง
```

### 11.3 Interaction กับ Player Heavy Attack

ท่านี้ควรเป็นตัวลงโทษ Player ที่กดค้าง Heavy ผิดจังหวะ

ตัวอย่าง:

```text
Player เริ่มชาร์จ Heavy
บอสเลือก heavy_dash_slash
ถ้า Player ยืนค้างใน path หรือ endpoint
→ โดนลงโทษหนัก
```

แต่ถ้า Player ทำให้บอส Posture Break แล้วค่อยชาร์จ Heavy:

```text
ยังเป็น reward window ที่ปลอดภัยกว่า
```

### 11.4 Interaction กับ Boss Posture Break

ถ้าบอสถูก Posture Break ระหว่าง wind-up หรือ dash:

```text
attack_sequence_id ต้องถูกเพิ่ม / coroutine เก่าต้องหยุด
attack_shape ต้องปิด
is_attacking ต้อง false
บอสต้องหยุดพุ่งทันที
```

ต้องตรวจ `my_attack_id != attack_sequence_id or is_dead or is_posture_broken` ระหว่าง dash loop

### 11.5 Interaction กับ Arena Bounds

ห้ามให้บอสพุ่งหลุดสนาม

```text
end_x ต้อง clamp ด้วย arena bounds
```

ถ้าเริ่มท่าใกล้ขอบสนามมาก:

```text
ระยะพุ่งจริงอาจสั้นลง
endpoint zone ต้องอยู่ที่ตำแหน่งปลายทางหลัง clamp
```

---

## 12. Animation / Sprite Plan

ระยะแรกใช้ sprite เดียวกับ Heavy Attack 1 ได้

แต่ต้องใช้ gameplay cue แยก:

```text
- Hint ต่างกัน
- สีเตือนต่างกัน
- Camera shake ก่อนพุ่งหรือถึงปลายทาง
- Slash placeholder ยาวกว่าเดิม
- อาจมี ghost trail ภายหลัง
```

เมื่อมี asset จริงในอนาคต อาจแยกเป็น:

```text
boss_heavy_dash_slash_start
boss_heavy_dash_slash_dash
boss_heavy_dash_slash_recover
```

แต่ยังไม่จำเป็นในรอบแรก

---

## 13. Suggested Development Phases

### Phase 1: เอกสารแผน

สถานะของไฟล์นี้:

```text
ยังไม่แก้โค้ด
ยังไม่เพิ่มท่าในระบบสุ่ม
ยังไม่เพิ่ม movement ใหม่
```

### Phase 2: เพิ่มค่า export และ debug enum

เพิ่มค่า balance:

```text
heavy_dash_attack_chance
heavy_dash_attack_damage
heavy_dash_endpoint_damage_multiplier
heavy_dash_attack_windup_time
heavy_dash_attack_dash_time
heavy_dash_attack_distance
heavy_dash_endpoint_radius
heavy_dash_path_extra_margin
heavy_dash_attack_cooldown_bonus
heavy_dash_final_frame_hold_time
```

เพิ่ม enum:

```text
heavy_dash_slash
```

### Phase 3: เพิ่ม pattern แต่ยังไม่สุ่มจริง

เพิ่ม `heavy_dash_slash` ใน `apply_attack_pattern()` และ debug force ก่อน

ยังไม่ต้องใส่เข้า `choose_random_attack_pattern()` หรือใส่ chance เป็น 0 ก่อน เพื่อให้ทดสอบแยกได้

### Phase 4: ทำ execution function

เพิ่ม:

```text
perform_heavy_dash_slash(my_attack_id)
```

ให้ flow:

```text
wind-up
→ clear hint
→ พุ่ง
→ ตรวจ zone
→ final hold
→ cooldown
```

### Phase 5: เพิ่ม Path / Endpoint Damage

เพิ่มฟังก์ชันตรวจ:

```text
is_player_in_heavy_dash_endpoint_zone(endpoint_x)
is_player_in_heavy_dash_path_zone(start_x, end_x)
apply_heavy_dash_damage(is_endpoint_hit)
```

### Phase 6: Debug Test

เปิด debug force ให้บอสใช้เฉพาะ heavy_dash_slash

ทดสอบ:

```text
ยืนใกล้บอส
ยืนกลางทางพุ่ง
ยืนตรงปลายทาง
Dash หลบผ่านหลังบอส
Dash ถอยหนี
ยืนชาร์จ Heavy ผิดจังหวะ
```

### Phase 7: ใส่เข้า random pattern

เมื่อทดสอบแล้วค่อยเพิ่มเข้า random ด้วย chance ต่ำ เช่น:

```text
heavy_dash_attack_chance = 0.12
```

### Phase 8: Tune Balance

จูนจากความรู้สึกจริง:

```text
ระยะพุ่ง
endpoint radius
damage multiplier
wind-up
final frame hold
chance
```

---

## 14. Test Plan แบบละเอียด

### Test 1: บังคับให้บอสใช้ Heavy Dash Slash

ตั้งค่า debug:

```text
debug_force_attack_pattern_enabled = true
debug_forced_attack_pattern = heavy_dash_slash
```

ผลที่ควรได้:

```text
บอสใช้ท่า heavy_dash_slash ซ้ำ ๆ
Output แสดง Boss DEBUG forced pattern: heavy_dash_slash
```

### Test 2: ยืนใน path zone

ขั้นตอน:

```text
1. ยืนระหว่างตำแหน่งเริ่มพุ่งกับตำแหน่งปลายทาง
2. ไม่ Dash
3. รอให้บอสพุ่งฟาด
```

ผลที่ควรได้:

```text
Player โดนดาเมจปกติของท่า เช่น 22
```

### Test 3: ยืนตรง endpoint zone

ขั้นตอน:

```text
1. ยืนใกล้ตำแหน่งที่บอสจะพุ่งไปถึง
2. ไม่ Dash
3. รอให้บอสพุ่งฟาด
```

ผลที่ควรได้:

```text
Player โดนดาเมจทวีคูณ เช่น 38-39
```

### Test 4: Dash ผ่านหลังบอส

ขั้นตอน:

```text
1. รอ hint DASH OUT!
2. Dash ผ่านหลังบอสหรือออกจากเส้นทาง
```

ผลที่ควรได้:

```text
Player ไม่โดนดาเมจ
```

### Test 5: ถอยหนีเป็นเส้นตรง

ขั้นตอน:

```text
1. เห็นบอส wind-up
2. กดถอยหลังตรง ๆ โดยไม่ Dash ออกนอก endpoint
```

ผลที่ควรได้:

```text
ถ้าถอยไปอยู่ endpoint zone → โดนดาเมจทวีคูณ
ถ้าถอยพ้น endpoint zone จริง → ไม่โดน
```

### Test 6: Player กำลังชาร์จ Heavy ผิดจังหวะ

ขั้นตอน:

```text
1. เริ่มกด Attack ค้างเพื่อชาร์จ Heavy
2. ให้บอสใช้ heavy_dash_slash
3. ไม่ Dash ออก
```

ผลที่ควรได้:

```text
Player โดนลงโทษด้วย path หรือ endpoint damage
Heavy Charge ถูก interrupt ตามระบบโดนตีของ Player
```

### Test 7: บอสถูก Posture Break ระหว่างท่า

ขั้นตอน:

```text
1. ทำให้ posture บอสใกล้หมด
2. ให้บอสเริ่ม heavy_dash_slash
3. ทำให้บอส posture break ระหว่าง wind-up หรือช่วงพุ่ง
```

ผลที่ควรได้:

```text
ท่าถูกยกเลิก
บอสหยุดพุ่ง
hitbox/damage zone ไม่ทำงานต่อ
บอสเข้า posture break ตามปกติ
```

### Test 8: ขอบสนาม

ขั้นตอน:

```text
1. ให้บอสอยู่ใกล้ขอบซ้ายหรือขวา
2. บังคับใช้ heavy_dash_slash
```

ผลที่ควรได้:

```text
บอสไม่หลุดขอบสนาม
endpoint ถูก clamp
damage zone อ้างอิง endpoint หลัง clamp
```

---

## 15. Acceptance Criteria

ระบบนี้ถือว่าผ่านเมื่อ:

```text
- มี pattern ใหม่ชื่อ heavy_dash_slash
- สามารถบังคับท่านี้ผ่าน debug_forced_attack_pattern ได้
- บอสใช้ sprite/visual heavy เดิมได้โดยไม่ต้องมี asset ใหม่
- บอส wind-up ชัดเจนก่อนพุ่ง
- บอสพุ่งไปข้างหน้าตาม facing_direction
- Player ใน path zone โดนดาเมจปกติ
- Player ใน endpoint zone โดนดาเมจทวีคูณ
- Player ที่ Dash หลบถูกจังหวะไม่โดนดาเมจ
- ดาเมจเกิดได้ครั้งเดียวต่อหนึ่งท่า
- บอสไม่พุ่งหลุด arena
- ท่าถูกยกเลิกได้ถ้าบอสตาย / posture break / attack_sequence_id เปลี่ยน
- ท่าไม่ทำให้ normal_slash, quick_slash, delayed_slash, heavy_slash เดิมพัง
```

---

## 16. Rollback Plan

ควรออกแบบให้ rollback ง่ายด้วยค่า export

### 16.1 ปิดจาก random pattern

ตั้ง:

```gdscript
@export var heavy_dash_attack_chance: float = 0.0
```

ผล:

```text
บอสจะไม่สุ่มใช้ heavy_dash_slash ในเกมจริง
```

### 16.2 ปิด debug force

ตั้ง:

```gdscript
@export var debug_force_attack_pattern_enabled: bool = false
```

### 16.3 ลบออกจาก random แต่คงโค้ดไว้

ถ้าท่ายังไม่พร้อม ให้คงฟังก์ชันไว้แต่ไม่เรียกใน `choose_random_attack_pattern()`

ผล:

```text
ระบบเก่ากลับไปเล่น normal / quick / delayed / heavy_slash ตามเดิม
```

---

## 17. ความเสี่ยงและข้อควรระวัง

### 17.1 ท่าอ่านยากเพราะใช้ sprite เดียวกับ Heavy Slash เดิม

แนวทางป้องกัน:

```text
เพิ่ม hint text ที่ต่างกัน
เพิ่มสีเตือนต่างกัน
เพิ่ม camera shake หรือ slash effect ที่ต่างกัน
```

### 17.2 ท่ารุนแรงเกินไป

แนวทางป้องกัน:

```text
เริ่ม endpoint multiplier ที่ 1.5-1.75 ก่อน
อย่าเริ่มที่ 2.5 หรือ 3.0
ตั้ง chance ต่ำในช่วงแรก
```

### 17.3 hit detection ไม่ตรงกับภาพ

แนวทางป้องกัน:

```text
ให้ debug แสดง path/endpoint ด้วย placeholder ในอนาคต
เริ่มจากค่า endpoint radius กว้างพออ่านง่าย
จูนจาก gameplay จริง
```

### 17.4 บอสพุ่งทะลุสนามหรือชน Player แล้วหยุด

แนวทางป้องกัน:

```text
ใช้ controlled dash movement แทน move_and_slide ปกติ
clamp endpoint ก่อนพุ่ง
ไม่ใช้ collision กับ Player เป็นตัวกำหนดว่าพุ่งได้ไกลแค่ไหน
```

### 17.5 ท่าแย่งบทบาท Heavy Slash เดิม

แนวทางป้องกัน:

```text
heavy_slash เดิม = ท่าฟันหนักระยะใกล้
heavy_dash_slash ใหม่ = ท่าพุ่งคุมพื้นที่ระยะกลาง
ให้ chance ของ heavy_dash_slash ต่ำกว่า heavy_slash เดิม
```

---

## 18. ข้อเสนอด้าน Game Feel

ท่านี้ควรให้ความรู้สึกว่า:

```text
บอสกดดันพื้นที่ทั้งเส้น
การถอยหลังอย่างเดียวไม่ปลอดภัย
ผู้เล่นต้องอ่านระยะและเลือก Dash อย่างมีสติ
```

จังหวะที่ควรรู้สึกได้:

```text
wind-up → น่ากลัวและอ่านออก
dash slash → เร็ว หนัก มีแรงปะทะ
endpoint hit → รู้สึกว่าโดนจุดอันตรายเต็ม ๆ
recovery → เปิดช่องให้ Player สวนกลับ
```

Camera / feedback ที่แนะนำภายหลัง:

```text
- shake เบาก่อนพุ่งตอน FULL COMMIT
- shake กลางตอน path hit
- shake หนักตอน endpoint hit
- damage popup endpoint อาจขึ้นคำว่า CRUSH! หรือ IMPACT!
```

---

## 19. สรุปแนวทางสุดท้าย

ระบบที่ต้องการคือ:

```text
heavy_dash_slash = Heavy Attack 2 ของบอส
ใช้ sprite เดียวกับ heavy_slash เดิม
เพิ่มการพุ่งตัวในจังหวะฟาดจริง
แบ่งพื้นที่ดาเมจเป็น path zone และ endpoint zone
path zone = ดาเมจปกติ
endpoint zone = ดาเมจทวีคูณ
Parry ไม่ได้ ต้อง Dash / reposition
ใช้ debug force ทดสอบก่อน แล้วค่อยใส่เข้า random pattern
```

แนวทางนี้เหมาะกับ Last Blade Trial / ดาบไร้นาม เพราะช่วยให้บอสมีท่าคุมพื้นที่มากขึ้น และทำให้การใช้ Player Heavy Attack ต้องอาศัยการอ่านจังหวะ ไม่ใช่แค่กดค้างเมื่อเห็นบอสอยู่ไกล
