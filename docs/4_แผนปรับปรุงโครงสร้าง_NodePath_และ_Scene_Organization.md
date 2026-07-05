# แผนปรับปรุงโครงสร้าง NodePath และ Scene Organization

โครงการ: **Last Blade Trial / ดาบไร้นาม**  
สถานะเอกสาร: แผนพัฒนาปรับปรุงเชิงโครงสร้าง  
วันที่จัดทำ: 2026-07-06  
เป้าหมายหลัก: ลดความเปราะของ `NodePath` และเตรียมจัดกลุ่ม Node ใน main scene โดยไม่ทำให้ระบบ combat / mobile input / tutorial / game loop พัง

---

## 1. สรุปผู้บริหาร

โปรเจกต์ปัจจุบันมีระบบหลักของ vertical slice แล้ว ได้แก่ Player, BossBrokenMaster, HUD, TouchControls, Training Coach, Duel 1 Guided Training, GameLoopManager, UpgradeRunState และ manager เฉพาะทางหลายตัว

ปัญหาที่เริ่มเห็นชัดคือ **main scene มี Node และ script จำนวนมากวางอยู่ระดับเดียวกัน** ทำให้ดูแลยากและอ่านยาก แต่ปัญหาที่แท้จริงยังไม่ใช่จำนวน Node โดยตรง ปัญหาที่เสี่ยงกว่าคือหลายระบบยังอ้าง Node สำคัญด้วย path แบบสัมพันธ์กับตำแหน่งเดิม เช่น

```text
../Player
../BossBrokenMaster
../GameLoopManager
../TouchControls
../Duel1DummyManager
```

รวมถึงบางไฟล์ยังหา Player ด้วย `get_parent().get_node("Player")` หรือ `get_parent().get_node_or_null("Player")` โดยตรง

ดังนั้นแนวทางที่มีโอกาสสำเร็จสูงที่สุดคือ:

```text
อย่าเริ่มจากการย้าย Node
ให้เริ่มจากการทำให้ระบบหา Node สำคัญได้โดยไม่พึ่งตำแหน่งก่อน
แล้วค่อยย้าย Node ทีละกลุ่ม
```

ชื่อแนวทางหลัก:

```text
Stable Reference Pass → Smoke Test → Small Scene Organization
```

---

## 2. เป้าหมายของแผนนี้

1. ลดความเสี่ยงจากการย้าย Node ใน Godot scene
2. ทำให้ระบบสำคัญหา Player / Boss / GameLoop / TouchControls ได้แม้ตำแหน่ง node เปลี่ยน
3. เตรียม main scene ให้จัดกลุ่มเป็น `World`, `Actors`, `UI`, `GameFlow`, `CombatSystems` ได้ในอนาคต
4. ไม่เปลี่ยน gameplay behavior ในรอบแรก
5. ไม่ refactor ใหญ่ก่อน combat, mobile input และ animation state นิ่ง
6. ให้ผู้พัฒนามือใหม่ยังเปิด Godot แล้วเข้าใจ scene tree ได้ง่ายขึ้น

---

## 3. หลักการสำคัญ

### 3.1 ไม่เริ่มจากการลาก Node เข้า folder

การลาก Node เข้า `World`, `Actors`, `UI`, `GameFlow`, `CombatSystems` ทันทีจะเปลี่ยน path จริงของ Node และทำให้ script ที่อ้าง `../Player` หรือ `../BossBrokenMaster` หา Node ไม่เจอ

ดังนั้นห้ามทำแบบนี้ในรอบแรก:

```text
สร้าง folder node แล้วลากทุกอย่างเข้าไปทันที
จากนั้นค่อยตามแก้ error
```

เพราะถ้าพังพร้อมกันหลายระบบ จะวิเคราะห์ยากมากว่าเกิดจาก path, input, combat, tutorial หรือ game loop

### 3.2 ใช้ Group เป็น identity ถาวรของ Node สำคัญ

แนวคิดที่ปลอดภัยกว่าคือให้ Node สำคัญมี group ประจำตัว เช่น

```text
Player                  → player_actor
BossBrokenMaster         → combat_target
ArenaManager             → arena_manager
GameCamera               → game_camera
TouchControls            → touch_controls
GameLoopManager          → game_loop_manager
TrainingCoachManager     → training_coach_manager
Duel1IntroManager        → duel_1_intro_manager
Duel1DummyManager        → duel_1_manager
```

เมื่อมี group แล้ว ระบบอื่นสามารถหา Node สำคัญได้โดยไม่ต้องรู้ว่า Node นั้นอยู่ที่ตำแหน่งใดใน scene tree

ตัวอย่างแนวคิด:

```text
Player จะอยู่ที่ Main/Player ก็ได้
หรือ Main/Actors/Player ก็ได้
ถ้า Player อยู่ใน group player_actor
ระบบอื่นก็ยังหาเจอ
```

### 3.3 ลำดับการหา Node ที่ควรใช้

ทุกระบบที่ต้องอ้าง Node สำคัญควรหา Node ตามลำดับนี้:

```text
1. exported NodePath ก่อน
2. group fallback
3. parent/name fallback แบบเดิมเป็นทางสุดท้าย
```

เหตุผลที่ยังเก็บ exported `NodePath` ไว้คือ Godot inspector ยังปรับค่าเฉพาะ scene ได้ง่าย ส่วน group fallback ช่วยให้การย้าย Node ในอนาคตปลอดภัยขึ้น

---

## 4. Inventory เบื้องต้นของ Node / Script ที่เสี่ยง

> หมายเหตุ: เอกสารนี้สำรวจจาก main runtime scene และ script ที่ scene หลักอ้างใช้งานโดยตรง ขอบเขตนี้เพียงพอสำหรับการวางแผน Scene Organization Pass แต่ยังไม่ควรถือว่าแทนการตรวจทุกไฟล์ใน repository แบบ recursive 100%

### 4.1 จุด hardcoded ที่ต้องแก้ก่อนย้าย Node

#### `HUD.gd`

ปัจจุบันหา Player จาก parent โดยตรง:

```gdscript
var player = get_parent().get_node("Player")
```

ถ้าย้าย `HUD` เข้า `UI/HUD` แล้ว Player อยู่ที่ `Actors/Player` ตรงนี้จะพังทันที

#### `TouchControls.gd`

ปัจจุบัน `find_player_node()` หา Player จาก parent:

```gdscript
return get_parent().get_node_or_null("Player")
```

ถ้าย้าย `TouchControls` เข้า `UI/TouchControls` ปุ่ม Lock และการอ่านสถานะ Player จะหา Player ไม่เจอ

#### `BossBrokenMaster.gd`

ปัจจุบัน Boss หา Player จาก parent:

```gdscript
player = get_parent().get_node_or_null("Player") as CharacterBody2D
```

ถ้าย้าย Boss และ Player ไปคนละ parent หรือจัดกลุ่มซับซ้อนขึ้น บอสอาจหา Player ไม่เจอ

### 4.2 กลุ่ม manager ที่ใช้ NodePath แบบสัมพันธ์กับ root เดิม

ตัวอย่างกลุ่มที่อ้าง path จากตำแหน่งเดิม:

```text
KeyboardTapDeflectManager       → ../Player
MovementDeflectBalanceManager   → ../Player
BossGrabBalanceManager          → ../Player, ../BossBrokenMaster, ../GameLoopManager, ../Duel1DummyManager
CombatDecayManager              → ../Player, ../BossBrokenMaster
PlayerAttackVFXManager          → ../Player
BossDifficultyCurveManager      → ../BossBrokenMaster
BossWeightManager               → ../BossBrokenMaster, ../Player
TrainingCoachManager            → ../Player, ../BossBrokenMaster, ../GameLoopManager
Duel1IntroManager               → ../Player, ../BossBrokenMaster, ../GameLoopManager, ../TrainingCoachManager
Duel1DummyManager               → ../Player, ../BossBrokenMaster, ../GameLoopManager, ../TrainingCoachManager, ../Duel1IntroManager
BossFightHintCleanupManager     → ../BossBrokenMaster, ../Duel1DummyManager, ../GameLoopManager
RunMetricsManager               → ../BossBrokenMaster, ../GameLoopManager
GameLoopManager                 → ../Player, ../BossBrokenMaster, ../TouchControls
```

หากย้าย Node เหล่านี้เข้า folder โดยไม่แก้ path ทั้งหมด ระบบจะหา Node ไม่เจอ

---

## 5. วิธีที่มีโอกาสสำเร็จสูงที่สุด

### Step 1: สร้าง Path Inventory Doc

สถานะ: แนะนำให้ทำเป็นขั้นแรก  
ความเสี่ยง: ต่ำมาก  
โอกาสสำเร็จ: 98-100%

งาน:

1. บันทึกว่าแต่ละ script อ้าง Node ใดบ้าง
2. แยกว่าอ้างด้วย `NodePath`, `get_parent()`, group, หรือ `$Child`
3. ระบุว่าถ้าย้าย Node แล้วต้องแก้อะไรบ้าง
4. ใช้เอกสารนี้เป็น checklist ก่อนย้าย scene จริง

ผลลัพธ์ที่ต้องการ:

```text
ทีมรู้ว่าระบบไหนผูกกับ path ไหน
ก่อนเริ่ม refactor จะไม่ต้องเดาจากความจำ
```

---

### Step 2: เพิ่ม Group Identity ให้ Node สำคัญ โดยยังไม่ย้าย Node

สถานะ: ควรทำก่อนแก้ path ใหญ่  
ความเสี่ยง: ต่ำ  
โอกาสสำเร็จ: 90-95%

เพิ่ม group ให้ Node สำคัญ เช่น:

```text
Player                  → player_actor
TouchControls            → touch_controls
GameLoopManager          → game_loop_manager
TrainingCoachManager     → training_coach_manager
Duel1IntroManager        → duel_1_intro_manager
Duel1DummyManager        → duel_1_manager
```

ของที่มีแนวคิด group อยู่แล้ว:

```text
BossBrokenMaster         → combat_target
ArenaManager             → arena_manager
GameCamera               → game_camera
```

ข้อควรระวัง:

- เพิ่ม group อย่างเดียวก่อน
- ห้ามเปลี่ยน behavior gameplay ใน commit เดียวกัน
- หลังเพิ่ม group ต้องเปิด Godot ทดสอบว่าเกมยังเล่นได้เหมือนเดิม

---

### Step 3: แก้ Boss / HUD / TouchControls ให้หา Player แบบ robust

สถานะ: สำคัญที่สุดก่อนย้าย scene  
ความเสี่ยง: กลางต่ำ  
โอกาสสำเร็จ: 80-90%

ไฟล์เป้าหมาย:

```text
BossBrokenMaster.gd
HUD.gd
TouchControls.gd
```

รูปแบบที่ควรใช้:

```text
1. หา Player จาก exported NodePath ถ้ามี
2. ถ้าไม่เจอ หา node ใน group player_actor
3. ถ้าไม่เจอ ค่อย fallback เป็น get_parent().get_node_or_null("Player")
```

ข้อสำคัญ:

- ไม่เปลี่ยน logic การต่อสู้
- ไม่เปลี่ยน input
- ไม่ย้าย Node
- แก้เฉพาะวิธีหา reference

Smoke test หลังจบ step นี้:

```text
1. HUD ยังแสดง HP / Stamina / Focus / Boss HP
2. TouchControls ยังแสดงและกดได้
3. ปุ่ม Lock ยังอ่านสถานะ Player ได้
4. Boss ยังเดินเข้าหา Player
5. Boss ยังโจมตีได้
6. D Deflect ยังทำงาน
7. Joystick Tap Deflect ยังทำงาน
```

---

### Step 4: แก้ manager อื่นให้มี group fallback

สถานะ: ทำหลัง 3 จุดหลักผ่านแล้ว  
ความเสี่ยง: กลาง  
โอกาสสำเร็จ: 75-85%

ลำดับแนะนำ:

```text
GameLoopManager
TrainingCoachManager
Duel1IntroManager
Duel1DummyManager
KeyboardTapDeflectManager
MovementDeflectBalanceManager
BossGrabBalanceManager
CombatDecayManager
PlayerAttackVFXManager
BossDifficultyCurveManager
BossWeightManager
BossFightHintCleanupManager
RunMetricsManager
```

แนวทาง:

- เพิ่ม fallback ด้วย group
- ยังเก็บ exported NodePath ไว้
- parent/name fallback เป็นทางสุดท้าย
- ไม่ย้าย Node ในขั้นนี้
- ทดสอบหลังแก้ทีละกลุ่มหรือทีละ 2-3 ไฟล์

---

### Step 5: ทดสอบ Flat Scene เดิมก่อนย้าย Node

สถานะ: ต้องทำก่อน Scene Organization  
ความเสี่ยง: ต่ำ  
ความสำคัญ: สูงมาก

Checklist:

```text
1. เปิดเกมแล้วไม่ error
2. กด Start ได้
3. TouchControls แสดง/ซ่อนถูก
4. Player เดิน / Attack / Dash ได้
5. D Tap Deflect ได้
6. Joystick Tap Deflect ได้
7. Movement Deflect ยังทำงาน
8. Boss หา Player เจอและเดินเข้าหา
9. Boss hint ขึ้น
10. TrainingCoachManager ทำงาน
11. Duel 1 Guided Training ทำงาน
12. Boss Grab ยังออกได้
13. HUD อัปเดตค่าถูก
14. แพ้/ชนะแล้ว GameLoop ทำงาน
15. เลือก Upgrade ได้
16. Restart ได้
```

หากไม่ผ่านขั้นนี้ ห้ามย้าย Node ต่อ

---

## 6. แผน Scene Organization หลังระบบ reference แข็งแรงแล้ว

เมื่อ Step 1-5 ผ่านแล้ว จึงค่อยเริ่มย้าย Node ทีละกลุ่ม

### Phase A: ย้าย World ก่อน

โครงเป้าหมาย:

```text
Main
└── World
    ├── ArenaManager
    ├── ArenaVisualManager
    └── GameCamera
```

ความเสี่ยง: ต่ำ  
เหตุผล: `GameCamera` ใช้ group, `ArenaManager` ใช้ group, `ArenaVisualManager` ไม่พึ่ง Player/Boss โดยตรง

Test หลังย้าย:

```text
1. ฉากหลังยังขึ้น
2. กล้องยัง current
3. camera shake ยังทำงาน
4. Player/Boss ยังถูก clamp ใน arena
```

---

### Phase B: ย้าย Actors ทั้งก้อน

โครงเป้าหมาย:

```text
Main
└── Actors
    ├── Player
    └── BossBrokenMaster
```

ความเสี่ยง: กลาง

ข้อห้าม:

```text
ห้ามแยกลูกของ Player ออก
ห้ามแยกลูกของ Boss scene ออก
```

ต้องย้ายทั้งก้อนเท่านั้น:

```text
Player + Sprite2D + AnimatedSprite2D + AttackHitbox + Hurtbox + visual managers
BossBrokenMaster instance ทั้งก้อน
```

Test หลังย้าย:

```text
1. Player animation idle/run/back ยังถูก
2. Player hitbox ยังอยู่ด้านหน้า
3. Boss เดินหา Player
4. Boss หันหน้าถูก
5. Attack/Deflect/Dash ยังทำงาน
```

---

### Phase C: ย้าย UI

โครงเป้าหมาย:

```text
Main
└── UI
    ├── HUD
    ├── TouchControls
    ├── TrainingCoachManager
    ├── Duel1IntroManager
    └── Duel1DummyManager
```

ความเสี่ยง: กลางถึงสูง

เงื่อนไขก่อนทำ:

```text
HUD ต้องหา Player ผ่าน group ได้แล้ว
TouchControls ต้องหา Player ผ่าน group ได้แล้ว
Training/Duel managers ต้องมี group fallback แล้ว
```

Test หลังย้าย:

```text
1. HUD อัปเดตครบ
2. TouchControls แสดง/ซ่อนถูก
3. ปุ่ม Attack/Dash/Lock กดได้
4. Training Coach ยังเริ่มหลัง Start
5. Duel 1 Guided Training ยังเริ่มหลัง Training
6. Skip buttons ยังทำงาน
```

---

### Phase D: ย้าย GameFlow

โครงเป้าหมาย:

```text
Main
└── GameFlow
    ├── GameLoopManager
    ├── BossFightHintCleanupManager
    └── RunMetricsManager
```

ความเสี่ยง: กลาง

เงื่อนไขก่อนทำ:

```text
ระบบอื่นต้องหา GameLoopManager ผ่าน group ได้แล้ว
GameLoopManager ต้องหา Player/Boss/TouchControls ผ่าน group ได้แล้ว
```

Test หลังย้าย:

```text
1. หน้า Start ขึ้น
2. กด Start แล้ว combat เริ่ม
3. TouchControls ถูกซ่อน/แสดงตาม state
4. Victory / Defeated ขึ้นถูก
5. Upgrade choice แสดงหลังชนะ
6. Restart / reload scene ทำงาน
7. RunMetrics ต่อข้อความผลลัพธ์ได้
```

---

### Phase E: ย้าย CombatSystems เป็นลำดับสุดท้าย

โครงเป้าหมาย:

```text
Main
└── CombatSystems
    ├── KeyboardTapDeflectManager
    ├── MovementDeflectBalanceManager
    ├── BossGrabBalanceManager
    ├── CombatDecayManager
    ├── PlayerAttackVFXManager
    ├── BossDifficultyCurveManager
    └── BossWeightManager
```

ความเสี่ยง: สูงสุดในกลุ่ม scene organization

เหตุผล:

- กระทบ input
- กระทบ Deflect balance
- กระทบ Boss Grab
- กระทบ Posture/Focus decay
- กระทบ attack VFX
- กระทบ boss difficulty phase
- กระทบ boss weight/recoil

Test หลังย้าย:

```text
1. D Tap Deflect ทำงาน
2. Joystick Tap Deflect ทำงาน
3. Movement Deflect เสีย stamina/cooldown ถูก
4. Boss Grab ยังออกได้
5. Boss Difficulty phase ยังเปลี่ยนตาม HP
6. BossWeight ยังกัน knockback ธรรมดา
7. PlayerAttackVFX ยังขึ้น
8. Focus/Posture decay ยังทำงาน
9. เล่นจนชนะ/แพ้ได้ครบ loop
```

---

## 7. ประเมินโอกาสสำเร็จ

### วิธีที่แนะนำ

```text
Path Inventory → Group Identity → Robust Lookup → Smoke Test → Move Nodes ทีละกลุ่ม
```

โอกาสสำเร็จโดยรวม:

```text
85-90%
```

เงื่อนไข:

- ทำทีละขั้น
- 1 phase = 1 commit
- ทดสอบใน Godot หลังทุก commit
- ไม่ย้าย Player children / Boss children / HUD children แยกจาก parent
- ไม่เปลี่ยน gameplay behavior ระหว่าง refactor reference

### วิธีที่ไม่แนะนำ

```text
ย้าย Node ก่อนทำ Robust Lookup
```

โอกาสสำเร็จ:

```text
40-55%
```

### วิธีที่เสี่ยงมาก

```text
ย้าย scene ทั้งหมดใน commit เดียว
```

โอกาสสำเร็จ:

```text
ต่ำกว่า 40%
```

---

## 8. ข้อจำกัดที่ต้องรับรู้

1. GitHub ตรวจโค้ดได้ แต่ไม่สามารถยืนยัน runtime behavior ใน Godot ได้ 100%
2. ต้องให้ผู้พัฒนาเปิด Godot ทดสอบจริงหลังแต่ละ phase
3. Godot อาจไม่ error ตอนเปิดไฟล์ แต่ error ตอนเริ่ม scene หาก NodePath บางจุดหลุด
4. ไม่ควร refactor พร้อมกับเพิ่ม feature ใหม่
5. ไม่ควรทำพร้อมกับเพิ่ม animation state ใหม่ เช่น attack/dash/hurt/death
6. ไม่ควรทำพร้อมกับปรับ balance Boss หรือ Deflect

---

## 9. เกณฑ์ผ่านของแผนนี้

ถือว่าแผนนี้สำเร็จเมื่อ:

```text
1. เกมยังเล่นได้ครบ Start → Training → Duel 1 → Boss Fight → Victory/Defeat → Upgrade/Restart
2. Player / Boss / HUD / TouchControls ยังทำงานครบ
3. main scene อ่านง่ายขึ้น
4. ระบบอ้างอิง Node สำคัญไม่ผูกกับตำแหน่งเดิมมากเกินไป
5. สามารถย้าย Node ในอนาคตได้โดยไม่ต้องแก้ทุก script ซ้ำจากศูนย์
```

---

## 10. ข้อเสนอแนะลำดับดำเนินการจริง

รอบแรกที่ควรทำจริง:

```text
1. เพิ่ม group identity ให้ Node สำคัญ
2. แก้ BossBrokenMaster.gd ให้หา Player ผ่าน group fallback
3. แก้ HUD.gd ให้หา Player ผ่าน group fallback
4. แก้ TouchControls.gd ให้หา Player ผ่าน group fallback
5. ยังไม่ย้าย Node ใด ๆ
6. ให้ผู้พัฒนาเปิด Godot ทดสอบเต็ม loop
```

ถ้ารอบแรกผ่าน จึงเข้าสู่รอบถัดไป:

```text
1. แก้ manager อื่นให้มี group fallback
2. ทดสอบ flat scene เดิม
3. ย้าย World
4. ทดสอบ
5. ย้าย Actors
6. ทดสอบ
7. ย้าย UI
8. ทดสอบ
9. ย้าย GameFlow
10. ทดสอบ
11. ย้าย CombatSystems
12. ทดสอบเต็ม loop
```

---

## 11. บทสรุป

แผนนี้ไม่ได้เริ่มจากการจัด scene ให้สวย แต่เริ่มจากการทำให้ระบบ reference แข็งแรงก่อน

แนวทางนี้เหมาะกับสถานะปัจจุบันของ Last Blade Trial เพราะเกมมีระบบ core combat แล้ว แต่ยังอยู่ช่วงที่ manager และ patch หลายตัวถูกเพิ่มเพื่อแก้ปัญหาเฉพาะหน้า การย้าย Node โดยไม่เตรียม reference จะเสี่ยงสูงเกินไป

คำตอบเชิงยุทธศาสตร์คือ:

```text
แก้รากของความเปราะก่อน
แล้วค่อยจัดระเบียบความรกทีหลัง
```

หรือสั้นที่สุด:

```text
Stable Reference ก่อน Scene Organization
```
