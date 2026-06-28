# แผนการพัฒนาเกม Last Blade Trial / ดาบไร้นาม ฉบับปรับปรุง

**วันที่ปรับปรุง:** 2026-06-28  
**โปรเจกต์:** `shanwinder/lastblade`  
**โฟลเดอร์เกม:** `last-blade-trial`  
**Engine:** Godot 4.7 stable  
**เครื่องพัฒนา:** Mac / Apple M1 / Metal  
**แพลตฟอร์มเป้าหมาย:** Android / Google Play Store  
**แนวเกม:** 2D Mobile Souls-lite Boss Rush  

---

## 1. จุดประสงค์ของเอกสารฉบับนี้

เอกสารฉบับนี้เป็นแผนพัฒนาใหม่ที่ปรับจากแผนเดิม `docs/แผนการพัฒนาเกม_Last_Blade_Trial.md` โดยนำมารวมกับความก้าวหน้าจริงใน repo ปัจจุบัน เพื่อใช้เป็นแผนปฏิบัติการต่อจากนี้

แผนเดิมยังถือเป็นเอกสารวิสัยทัศน์หลัก แต่เอกสารฉบับนี้ทำหน้าที่เป็นแผนที่ละเอียดขึ้นสำหรับช่วงถัดไป โดยเฉพาะช่วงที่โปรเจกต์เข้าสู่การขัดเกลา Boss 1, combat feel, mobile control, visual prototype, game loop และการเตรียม vertical slice

เป้าหมายสำคัญที่สุดของแผนนี้คือ:

> ทำให้ Last Blade Trial กลายเป็นเกมดวลดาบ 2D บนมือถือที่เล่นสั้น ควบคุมง่าย อ่านจังหวะบอสได้ชัด แพรี่แล้วสะใจ และมีคุณภาพพอจะต่อยอดสู่ Google Play Store ได้ด้วยทุนต่ำ

---

## 2. หลักคิดที่ต้องยึดต่อจากนี้

### 2.1 Combat ต้องมาก่อนระบบใหญ่

ตอนนี้โปรเจกต์เดินมาไกลกว่าช่วงเริ่มต้นแล้ว แต่ยังต้องยึดหลักเดิม:

> ห้ามเพิ่มระบบใหญ่จนกว่า Boss 1 จะเล่นสนุกจริง

ระบบที่ยังไม่ควรรีบทำในตอนนี้ ได้แก่:

- ระบบโฆษณาจริง
- ระบบเติมเงินจริง
- Daily Challenge จริง
- Cloud Save
- Online Leaderboard
- ระบบเครื่องรางจำนวนมาก
- บอสหลายตัว
- แผนที่ใหญ่
- NPC จำนวนมาก
- เนื้อเรื่องยาว
- Cutscene ยาว

สิ่งที่ควรโฟกัสก่อนคือ:

- อ่านท่าบอสได้ชัดหรือไม่
- Dash หลบแล้วรู้สึกแม่นหรือไม่
- Parry สำเร็จแล้วรู้สึกสะใจหรือไม่
- โดนตีแล้วรู้สึกว่าเป็นความผิดของผู้เล่นหรือไม่
- ตายแล้วอยากลองใหม่หรือไม่
- เล่นบนมือถือแล้วปุ่มไม่กวนมือหรือไม่

### 2.2 เกมนี้ควรเล็ก แต่คม

ขอบเขตที่เหมาะสมที่สุดสำหรับผู้พัฒนาคนเดียวและงบน้อยคือ:

- ฉาก arena สั้น ๆ
- บอสจำนวนน้อย แต่จังหวะดี
- ปุ่มหลัก 3 ปุ่ม: Attack, Dash, Parry
- ภาพแบบ silhouette / limited animation
- เสียงและ feedback ที่ชัด
- ระบบอัปเกรดพอให้เล่นซ้ำ ไม่ใช่ RPG เต็มระบบ

### 2.3 เป้าหมายแรกไม่ใช่ Play Store ทันที

เป้าหมายลำดับแรกคือ:

> ฉากดวลดาบ 1 ต่อ 1 ที่คนเล่นแล้วพูดว่า “ขออีกตา”

เมื่อถึงจุดนั้นจึงค่อยต่อยอดเป็น game loop, upgrade, save, Android export, closed testing และ Play Store

---

## 3. สถานะ repo ปัจจุบันโดยสรุป

จากการตรวจไฟล์จริงใน repo พบว่าโปรเจกต์อยู่ในสถานะ:

> playable combat prototype / early vertical slice foundation

ยังไม่ใช่ vertical slice เต็ม แต่แกนต่อสู้หลักใช้งานได้แล้ว

### 3.1 ไฟล์หลักที่เกี่ยวข้องในปัจจุบัน

| ไฟล์ | บทบาทปัจจุบัน |
|---|---|
| `last-blade-trial/project.godot` | ตั้งค่าโปรเจกต์, main scene, input action, renderer mobile |
| `last-blade-trial/scenes/main/BossBrokenMaster.tscn` | ฉากหลักปัจจุบัน root ชื่อ `Main` มี Player, Boss, HUD, Camera, ArenaManager |
| `last-blade-trial/scenes/bosses/BossBrokenMaster.tscn` | scene ของบอสหลัก |
| `last-blade-trial/player.gd` | ระบบ Player: movement, attack, dash, parry, stamina, focus, finisher, damage |
| `last-blade-trial/BossBrokenMaster.gd` | ระบบบอสหลัก: AI, 4 attack patterns, posture, hit stop, knockback, SFX placeholder |
| `last-blade-trial/HUD.gd` | แสดง Player HP/Stamina/Focus และ Boss HP/Posture |
| `last-blade-trial/game_camera.gd` | กล้องหลักและ camera shake |
| `last-blade-trial/arena_manager.gd` | คุมขอบเขต arena ซ้าย/ขวา |
| `last-blade-trial/EnemyDummy.gd` | ศัตรูทดลองเดิม ยังมีประโยชน์เป็น reference |

### 3.2 สิ่งที่ทำแล้ว

ระบบที่ทำแล้วระดับ prototype:

- Player เดินซ้าย/ขวาได้
- Player หันตามทิศทางได้
- Player Attack ได้
- Attack ใช้ stamina
- Attack มี hitbox active time และ recovery
- Dash ได้
- Dash ใช้ stamina
- Dash มี cooldown
- Dash มี i-frame และ dash-through enemy ชั่วคราว
- Parry ได้
- Parry ใช้ stamina
- Parry สำเร็จแล้วเพิ่ม Focus
- HP / Stamina / Focus ทำงาน
- Boss HP / Boss Posture ทำงาน
- Posture ลดจากการ Parry สำเร็จ
- Posture Broken เปิดช่อง Critical / Focus Finisher
- Focus Finisher ทำงาน
- Player โดน damage ได้
- Player ตายได้
- Boss ตายได้
- HUD แสดงค่า Player และ Boss ได้
- BossBrokenMaster เป็น combat target หลัก
- Main scene ใช้ BossBrokenMaster แล้ว
- กล้องสั่นได้
- Hit stop ทำงาน
- Knockback ทำงาน
- Damage popup มีแล้ว
- Boss attack hint ย้ายไปอยู่เหนือหัวบอสแล้ว
- HUD hint กลางจอถูกปิดแล้ว
- Boss hint มี animation ขยายขึ้นเล็กน้อย
- Placeholder SFX ด้วย AudioStreamGenerator มีแล้ว

### 3.3 Boss pattern ปัจจุบัน

BossBrokenMaster มี 4 pattern หลัก:

| Pattern | Hint | วิธีรับมือ | สถานะ |
|---|---|---|---|
| `normal_slash` | `PARRY!` | Parry | ใช้งานได้ |
| `heavy_slash` | `DASH!` | Dash หลบ | ใช้งานได้ |
| `delayed_slash` | `WAIT...` แล้ว `PARRY!` | รอจังหวะท้ายแล้ว Parry | ใช้งานได้ |
| `quick_slash` | `PARRY FAST!` | Parry เร็ว | ใช้งานได้ |

นี่ถือว่า Phase 6 Boss 1 ทำไปไกลมากแล้ว แต่ยังต้องจูนให้แฟร์ สนุก และอ่านง่ายขึ้น

### 3.4 จุดที่ยังขาด

สิ่งที่ยังขาดก่อนเป็น vertical slice จริง:

- ยังไม่มี mobile touch controls จริง
- ยังไม่มี virtual joystick หรือปุ่มบนจอสำหรับ Android
- ยังไม่มี restart loop ที่สมบูรณ์หลังแพ้/ชนะ
- ยังไม่มีหน้าเริ่มเกม
- ยังไม่มีหน้า reward
- ยังไม่มี upgrade selection 1 จาก 3
- ยังไม่มี save/load
- ยังไม่มีด่าน Training / Duel / Boss แยกกัน
- ยังไม่มี visual sprite จริง ใช้ `icon.svg` เป็น placeholder
- ยังไม่มี animation จริง
- ยังไม่มี VFX ฟันดาบ / Parry spark / dash trail จริง
- ยังไม่มีเสียงจริง เป็น placeholder SFX
- ยังไม่มี Android export preset
- ยังไม่มี Play Store asset เช่น icon 512, feature graphic, screenshot
- ยังไม่มี Privacy Policy / Data Safety

---

## 4. การประเมินตาม Phase เดิม

| Phase เดิม | สถานะปัจจุบัน | หมายเหตุ |
|---|---|---|
| Phase 0: เตรียมเครื่องมือ | ผ่านบางส่วน | รันโปรเจกต์บน Mac ได้ แต่ Android export ยังไม่ยืนยัน |
| Phase 1: Movement | ผ่าน prototype | ยังไม่มี mobile controls |
| Phase 2: Attack | ผ่าน prototype | ยังไม่มี animation / SFX จริง |
| Phase 3: Enemy AI | ผ่าน prototype | ตอนนี้ใช้ BossBrokenMaster เป็นเป้าหมายหลัก |
| Phase 4: Dash & Stamina | ผ่าน prototype | ต้องจูนบนมือถือจริง |
| Phase 5: Parry & Posture | ผ่าน prototype | ต้องปรับ window และ feedback ให้ชัดขึ้น |
| Phase 6: Boss 1 | ทำแล้วประมาณ 75–85% | มี 4 pattern แล้ว แต่ต้องจูนและเพิ่ม readability |
| Phase 7: Game Loop | ยังไม่เริ่มจริง | ควรทำหลัง Boss 1 สนุกขึ้น |
| Phase 8: Meta Progression | ยังไม่ควรเริ่ม | รอ game loop พื้นฐานก่อน |
| Phase 9: Content 1.0 | ยังไม่ควรเร่ง | ต้องผ่าน vertical slice ก่อน |
| Phase 10: Play Store | ยังไม่เริ่ม | ทำหลัง mobile test และ content พร้อม |

---

## 5. แผนพัฒนาฉบับปรับปรุง

แผนใหม่จะแตกช่วงหลัง Phase 6 ออกเป็น Phase ย่อย เพื่อให้เดินต่อแบบค่อยเป็นค่อยไปและลดความเสี่ยง scope บาน

ลำดับใหม่คือ:

```text
Phase 6.1: Repo Hygiene และโครงสร้างฉาก
→ Phase 6.2: Boss Pattern Debug Mode
→ Phase 6.3: Boss 1 Combat Tuning
→ Phase 6.4: Combat Feedback Polish
→ Phase 6.5: Visual Prototype / Sprite / Limited Animation
→ Phase 6.6: Mobile Touch Control Prototype
→ Phase 7: One-Run Game Loop
→ Phase 8: Upgrade Prototype
→ Phase 9: Vertical Slice
→ Phase 10: Meta Progression Lite
→ Phase 11: Android Production Preparation
→ Phase 12: Play Store Closed Testing
```

---

# Phase 6.1: Repo Hygiene และโครงสร้างฉาก

## เป้าหมาย

ลดความสับสนของชื่อไฟล์และเตรียมโครงสร้างให้รองรับหลายฉากในอนาคต โดยไม่เปลี่ยน gameplay ใหญ่

## เหตุผล

ตอนนี้ไฟล์ฉากหลักอยู่ที่:

`last-blade-trial/scenes/main/BossBrokenMaster.tscn`

แต่ root node ภายในชื่อ `Main` และ `project.godot` ใช้ UID ของฉากนี้เป็น main scene

สิ่งนี้ยังไม่ใช่บั๊ก แต่ในอนาคตเมื่อมี Training Arena, Duel 1, Boss 1, Main Menu จะทำให้สับสนได้

## งานที่ต้องทำ

1. ตรวจว่าฉากหลักปัจจุบันคือไฟล์ใดแน่นอน
2. พิจารณา rename หรือ duplicate ฉากหลักเป็น:
   - `last-blade-trial/scenes/main/Main.tscn`
3. ให้ `project.godot` ชี้ main scene ไปที่ `Main.tscn`
4. เก็บ `scenes/bosses/BossBrokenMaster.tscn` เป็น scene ของบอสเท่านั้น
5. ไม่แตะ logic การต่อสู้ใน phase นี้ถ้าไม่จำเป็น

## Definition of Done

- กด Play แล้วเข้า scene หลักได้เหมือนเดิม
- Player, Boss, HUD, Camera ยังทำงานเหมือนเดิม
- ไม่มี error เรื่อง path หรือ UID
- โครงสร้างชื่อไฟล์อ่านง่ายขึ้น

## วิธีทดสอบ

1. เปิด Godot
2. กด Play
3. ทดสอบเดินซ้าย/ขวา
4. กด Attack / Dash / Parry
5. สู้ Boss จนชนะหรือแพ้
6. ดู Output ว่าไม่มี error ใหม่

---

# Phase 6.2: Boss Pattern Debug Mode

## เป้าหมาย

ทำระบบ debug เพื่อเลือกท่าบอสได้ทีละท่า ไม่ต้องรอสุ่ม pattern

## เหตุผล

ตอนนี้บอสสุ่ม 4 ท่า ทำให้จูน timing ยาก เพราะถ้าต้องการทดสอบ `delayed_slash` อาจต้องรอสุ่มหลายรอบ

Debug mode จะช่วยให้:

- จูน Parry window ได้ง่าย
- จูน Dash timing ได้ง่าย
- ทดสอบ quick_slash บนมือถือได้จริง
- หาจุดที่ผู้เล่นรู้สึกว่า unfair ได้เร็ว

## แนวทางระบบ

เพิ่ม export variable ใน `BossBrokenMaster.gd` เช่น:

- `debug_force_attack_pattern_enabled`
- `debug_forced_attack_pattern`

ค่าที่เลือกได้:

- `random`
- `normal_slash`
- `heavy_slash`
- `delayed_slash`
- `quick_slash`

## งานที่ต้องทำ

1. เพิ่มตัวแปร debug ใน `BossBrokenMaster.gd`
2. ปรับ `choose_attack_pattern()` ให้ถ้าเปิด debug ให้ใช้ pattern ที่กำหนด
3. เพิ่ม print ชัดเจนว่าอยู่ใน debug mode
4. ทดสอบทีละ pattern

## Definition of Done

- ตั้ง debug เป็น `normal_slash` แล้วบอสออกแต่ Normal Slash
- ตั้ง debug เป็น `heavy_slash` แล้วบอสออกแต่ Heavy Slash
- ตั้ง debug เป็น `delayed_slash` แล้วบอสออกแต่ Delayed Slash
- ตั้ง debug เป็น `quick_slash` แล้วบอสออกแต่ Quick Slash
- ปิด debug แล้วบอสกลับมาสุ่มเหมือนเดิม

## หมายเหตุสำคัญ

ทุกโค้ดที่เพิ่มต้องมีคอมเมนต์ภาษาไทย และใช้ Godot 4 syntax

---

# Phase 6.3: Boss 1 Combat Tuning

## เป้าหมาย

ทำให้ BossBrokenMaster เป็นบอสหนึ่งตัวที่ยากแบบแฟร์ เล่นแล้วเข้าใจว่าตัวเองพลาดตรงไหน และอยากลองใหม่

## สิ่งที่ต้องจูน

### 1. ค่า HP และระยะเวลาการต่อสู้

ตอนนี้ Boss HP อยู่ที่ 150 เหมาะกับการทดสอบเร็ว แต่สำหรับ vertical slice อาจต้องจูนให้ไฟต์อยู่ประมาณ 1–3 นาที

แนวทางเริ่มต้น:

| ค่า | ปัจจุบันโดยประมาณ | ค่าแนะนำช่วงจูน |
|---|---:|---:|
| Boss HP | 150 | 180–300 |
| Boss Posture | 120 | 100–140 |
| Player Attack | 10 | 10–12 |
| Focus Finisher | 40% HP | 25–40% HP |

ไม่ควรเพิ่ม HP จนไฟต์ยืดโดยไม่มีความหมาย ถ้าไฟต์ยาวขึ้น ต้องมีจังหวะให้ผู้เล่นรู้สึกว่าเก่งขึ้นด้วย เช่น Parry แล้วได้ Focus / Break แล้วสวนแรง

### 2. Parry window

ตอนนี้ Parry active time ค่อนข้างกว้างเพื่อ prototype

ควรจูนแยกเป็น 2 ช่วง:

- Desktop test: กว้างพอให้เข้าใจระบบ
- Mobile test: ปรับตาม input delay และขนาดปุ่มจริง

อย่าลด Parry window เร็วเกินไปก่อนมี touch control เพราะมือถือกดยากกว่า keyboard

### 3. Heavy Slash ต้องสื่อสารชัดว่า Dash เท่านั้น

ตอนนี้ Heavy Slash มี hint `DASH!` แล้ว แต่ถ้าผู้เล่น Parry ผิดควรมี feedback ที่ชัดกว่า console เช่น:

- ข้อความสั้นเหนือหัวผู้เล่น: `DASH ONLY!`
- เสียงทุ้มผิดจังหวะ
- กล้องสั่นตอนโดนลงโทษ

### 4. Delayed Slash ต้องไม่รู้สึกโกง

Delayed Slash เป็นท่าหลอกจังหวะ ควรมีสัญญาณชัดว่า:

- ช่วงแรก: อย่าเพิ่งกด
- ช่วงสอง: ตอนนี้ค่อย Parry

ควรทดสอบกับผู้เล่นใหม่ว่าพอเห็น `WAIT...` แล้วเข้าใจหรือไม่

### 5. Quick Slash ต้องเร็วแต่ไม่มั่ว

Quick Slash เหมาะสำหรับเพิ่มความกดดัน แต่ไม่ควรถี่เกินไปในช่วงแรก เพราะผู้เล่นใหม่จะรู้สึกโดนสุ่มฆ่า

แนวทาง:

- ช่วง tutorial / Training ไม่ควรมี quick_slash
- Boss 1 ช่วงแรกควรใช้โอกาสน้อย
- Challenge mode ค่อยเพิ่มโอกาส quick_slash

## Definition of Done

Boss 1 ผ่านการจูนเมื่อ:

- ผู้เล่นอ่าน Normal Slash ได้
- ผู้เล่นเข้าใจว่า Heavy Slash ต้อง Dash
- ผู้เล่นเข้าใจ Delayed Slash หลังเจอไม่เกิน 2–3 ครั้ง
- Quick Slash ยากแต่ไม่รู้สึกมั่ว
- ชนะได้ด้วยการเรียนรู้ ไม่ใช่สุ่มดวง
- แพ้แล้วรู้ว่าพลาดเพราะอะไร

---

# Phase 6.4: Combat Feedback Polish

## เป้าหมาย

เพิ่มความรู้สึก “ดาบกระทบจริง” โดยยังไม่ต้องใช้ asset จริงจำนวนมาก

## สิ่งที่มีแล้ว

- Hit stop
- Camera shake
- Knockback
- Damage popup
- Color feedback
- Placeholder SFX บางจุด
- Boss hint animation

## สิ่งที่ควรเพิ่มต่อ

### 1. Parry spark placeholder

เพิ่มเอฟเฟกต์ประกายง่าย ๆ ตอน Parry สำเร็จ เช่น:

- สร้าง Label หรือ Sprite2D ชั่วคราว
- สีเหลือง/ขาว
- scale จากเล็กไปใหญ่
- fade out ภายใน 0.15–0.25 วิ

### 2. Slash effect placeholder

ตอน Player Attack หรือ Boss Attack ให้มีเส้นดาบง่าย ๆ เช่น:

- Sprite2D สีขาว/เหลือง
- ขีดโค้งหรือ rectangle บาง ๆ
- หมุนตามทิศทาง
- หายเร็ว

### 3. Dash trail placeholder

ตอน Dash ให้ Player ทิ้งเงาจาง ๆ 2–3 ชุด เพื่อให้รู้ว่าพุ่งหลบจริง

### 4. Stamina insufficient feedback

ตอนกด Attack/Dash/Parry แต่ stamina ไม่พอ ปัจจุบันส่วนใหญ่เป็น print ควรมี feedback บนจอ เช่น:

- Stamina bar กระพริบ
- ข้อความเล็ก ๆ `TIRED`
- เสียงต่ำสั้น

### 5. Focus ready feedback

ตอน Focus เต็ม ปัจจุบันมีข้อความใน console และ HUD แสดง READY ควรเพิ่ม:

- เสียงสั้น
- หลอด Focus กระพริบ
- ข้อความ `FINISHER READY`

## Definition of Done

- ผู้เล่นดูจอแล้วรู้ทันทีว่า Parry สำเร็จ
- ผู้เล่นรู้ว่าโจมตีโดนจริง
- ผู้เล่นรู้ว่า dash เกิดขึ้นจริง
- ผู้เล่นรู้ว่า stamina ไม่พอโดยไม่ต้องดู console
- ผู้เล่นรู้ว่า Focus Finisher พร้อมใช้

---

# Phase 6.5: Visual Prototype / Sprite / Limited Animation

## เป้าหมาย

แทนที่ `icon.svg` ด้วยภาพ silhouette prototype ที่อ่านง่ายบนมือถือ โดยยังไม่ทำ final art รายละเอียดสูง

## หลักการภาพ

สไตล์ที่เหมาะกับเกมนี้:

> Silhouette 2D + Limited Animation + Sword Effects

แนวทาง:

- ตัวละครเป็นเงาหรือสีเข้ม
- ดาบและ effect มีแสงชัด
- ฉากหลังเรียบ แต่มีบรรยากาศ
- ใช้ contrast สูง
- ลดรายละเอียดเพื่อประหยัดเวลา animation

## ลำดับ asset ที่ควรทำ

### ชุดที่ 1: Readability Sprite

ทำก่อน animation จริง:

| Asset | จำนวน | จุดประสงค์ |
|---|---:|---|
| Player silhouette | 1 | แทน icon.svg ของ Player |
| Boss silhouette | 1 | แทน icon.svg ของ Boss |
| Sword slash placeholder | 2 | ฟันซ้าย/ขวาหรือฟันเบา/หนัก |
| Parry spark | 1 | ใช้ตอน Parry สำเร็จ |
| Dash trail | 1 | ใช้ซ้ำหลายครั้ง |
| Arena background simple | 1 | ให้มีพื้นและบรรยากาศ |

### ชุดที่ 2: Player Limited Animation

ลำดับที่ควรทำ:

1. Idle
2. Attack
3. Parry
4. Dash
5. Hurt
6. Death
7. Walk
8. Finisher ภายหลัง

เหตุผล: เกมนี้เป็น arena duel การอ่าน action สำคัญกว่า walk animation

### ชุดที่ 3: Boss Limited Animation

ลำดับที่ควรทำ:

1. Idle
2. Normal Slash wind-up
3. Heavy Slash wind-up
4. Delayed Slash wait pose
5. Quick Slash wind-up
6. Attack release
7. Hurt
8. Stunned / Posture Broken
9. Death

## วิธีทำแบบประหยัดแรง

ไม่จำเป็นต้องวาด spritesheet ละเอียดตั้งแต่แรก สามารถใช้:

- Sprite2D + AnimationPlayer
- scale / rotation / position animation
- modulate color
- slash effect แยกจากตัวละคร
- silhouette ตัวเดียว แต่ขยับท่าด้วย AnimationPlayer

## Definition of Done

- มองจอมือถือแล้วรู้ว่าใครคือ Player ใครคือ Boss
- ดูออกว่าบอสกำลังเตรียมท่าเบา/หนัก/หน่วง/เร็ว
- Attack / Dash / Parry ดูออกโดยไม่ต้องอ่าน console
- Visual ไม่บัง hitbox หรือ UI

---

# Phase 6.6: Mobile Touch Control Prototype

## เป้าหมาย

ทำให้เกมเล่นบนมือถือ Android ได้จริงด้วย touch controls ชั่วคราว

## เหตุผล

เกมนี้ออกแบบเพื่อมือถือ ถ้าระบบ Parry / Dash สนุกบน keyboard แต่กดยากบนมือถือ เกมจะไม่ผ่านเป้าหมายหลัก

## Control ที่ต้องมี

ฝั่งซ้าย:

- ปุ่มซ้าย
- ปุ่มขวา

หรือ virtual joystick แบบง่าย

ฝั่งขวา:

- Attack
- Dash
- Parry

## หลักการวางปุ่ม

- ปุ่มต้องใหญ่พอ
- Dash กับ Parry ห้ามชิดกันเกินไป
- Attack ควรกดง่ายที่สุด
- Parry ต้องตอบสนองทันที
- ปุ่มต้องไม่บัง Boss hint
- ปุ่มต้องไม่บัง Player / Boss มากเกินไป

## งานที่ต้องทำ

1. สร้าง UI touch controls ชั่วคราวใน scene หลักหรือแยกเป็น `TouchControls.tscn`
2. ให้ปุ่มเรียก action เดิม `attack`, `dash`, `parry`
3. ให้ปุ่มซ้าย/ขวาควบคุม movement ได้
4. ทดสอบบน Mac ด้วย mouse click ก่อน
5. Export ลง Android test build
6. ทดสอบบนมือถือจริง
7. จดปัญหา input delay / ปุ่มเล็ก / กดผิด

## Definition of Done

- เล่น Boss 1 บนมือถือได้ตั้งแต่ต้นจนจบ
- ผู้เล่น Dash หลบท่าหนักได้จริง
- ผู้เล่น Parry normal/delayed ได้จริง
- ปุ่มไม่บังจังหวะสำคัญ
- FPS ไม่ตกแบบเห็นได้ชัด

---

# Phase 7: One-Run Game Loop

## เป้าหมาย

เปลี่ยน prototype combat ให้เป็นเกมหนึ่งรอบที่เริ่ม เล่น จบ และเริ่มใหม่ได้

## Loop ที่ต้องได้

```text
หน้าเริ่ม
→ เข้า arena
→ สู้ Boss
→ ชนะหรือแพ้
→ แสดงผลลัพธ์
→ กด restart หรือกลับเมนู
```

## งานที่ต้องทำ

### 1. Game State

เพิ่มสถานะเกมพื้นฐาน:

- `waiting_start`
- `playing`
- `victory`
- `game_over`

อาจเริ่มใน script ง่าย ๆ เช่น `GameManager.gd` หรือทำใน Main ก่อน แล้วค่อยแยกภายหลัง

### 2. Start Screen

ทำแบบง่าย:

- ชื่อเกม
- ปุ่ม Start
- ข้อความสั้น ๆ: `Attack / Dash / Parry`

### 3. Result Screen

หลังชนะ:

- `VICTORY`
- เวลาที่ใช้
- จำนวน Parry สำเร็จ ถ้าทำได้
- ปุ่ม Restart

หลังแพ้:

- `DEFEATED`
- ข้อความสั้น ๆ เช่น `อ่านจังหวะ แล้วลองอีกครั้ง`
- ปุ่ม Restart

### 4. Restart

ต้องทำให้ restart สะอาด:

- Time scale กลับเป็น 1.0
- Player HP/Stamina/Focus reset
- Boss HP/Posture reset
- Hint ถูกล้าง
- Hitbox ปิด
- ไม่มี coroutine เก่าทำงานค้าง

## Definition of Done

- เปิดเกมแล้วไม่เริ่มสู้ทันทีจนกด Start
- ชนะแล้วเห็นหน้า Victory
- แพ้แล้วเห็นหน้า Defeated
- กด Restart แล้วเล่นใหม่ได้โดยไม่มี error
- เล่นซ้ำ 5 รอบติดกันได้

---

# Phase 8: Upgrade Prototype

## เป้าหมาย

เพิ่มเหตุผลให้เล่นซ้ำ โดยทำ upgrade แบบเบา ๆ ก่อน ยังไม่ต้องมี save/load

## แนวทาง

หลังชนะ ให้เลือก 1 จาก 3 upgrade แล้วเริ่มรอบถัดไป

Upgrade ชุดแรกควรมีแค่ 6 รายการ:

| Upgrade | ผล |
|---|---|
| คมดาบ | เพิ่ม Attack Damage 10% |
| ลมหายใจยาว | เพิ่ม Max Stamina 15 |
| เท้าเงา | ลด Dash Cooldown 10% |
| ใจนิ่ง | เพิ่ม Parry Window เล็กน้อย |
| สมาธิ | เพิ่ม Focus Gain |
| เลือดนักดาบ | ฟื้น HP หลังชนะ |

## สิ่งที่ยังไม่ต้องทำ

- ยังไม่ต้อง save upgrade ถาวร
- ยังไม่ต้องทำ rarity
- ยังไม่ต้องทำเครื่องราง
- ยังไม่ต้องสุ่มซับซ้อน
- ยังไม่ต้อง balance economy จริง

## Definition of Done

- หลังชนะมี upgrade 3 ตัวเลือก
- เลือกแล้วค่าส่งผลจริงในรอบถัดไป
- เล่น 3 รอบแล้วรู้สึกตัวละครเปลี่ยนเล็กน้อย
- ระบบไม่ทำให้ combat ง่ายเกินไป

---

# Phase 9: Vertical Slice

## เป้าหมาย

สร้างเวอร์ชันทดสอบที่มีเนื้อหาเล็กพอ แต่ให้ผู้เล่นใหม่เข้าใจเกมตั้งแต่ต้นจนสู้บอส

## โครงสร้าง Vertical Slice

| ฉาก | หน้าที่ |
|---|---|
| Training Arena | สอนเดิน, Attack, Dash, Parry |
| Duel 1 | ศัตรูธรรมดา 1 ตัว เพื่อฝึกอ่านจังหวะ |
| Boss 1 | BossBrokenMaster / อาจารย์ดาบหัก |

## รายละเอียด Training Arena

ควรสอนแบบสั้น ไม่ใช้ข้อความเยอะ:

1. เดินซ้าย/ขวา
2. กด Attack ใส่หุ่น
3. Dash ผ่านเส้นอันตราย
4. Parry การโจมตีช้า
5. เข้า Boss

## รายละเอียด Duel 1

ศัตรูธรรมดาควรมีแค่ 1–2 pattern:

- ฟันธรรมดา Parry ได้
- ฟันหนัก Dash ได้

ห้ามทำให้ยากเกิน เพราะเป้าหมายคือสอน

## รายละเอียด Boss 1

BossBrokenMaster ใช้ 4 pattern ปัจจุบัน แต่ควรจัด difficulty curve:

- ช่วงต้น: normal / heavy
- ช่วงกลาง: delayed
- ช่วงท้าย: quick เพิ่มเข้ามา

ถ้ายังไม่ทำ phase system ให้ใช้โอกาสสุ่มที่จูนแล้วก่อน

## Definition of Done

- ผู้เล่นใหม่เข้าใจวิธีเล่นใน 1 นาที
- ผู้เล่นเข้าใจว่า Parry และ Dash ต่างกัน
- ผู้เล่นสู้ Boss แล้วรู้สึกว่าตัวเองเรียนรู้จาก Training
- เล่นจบ vertical slice ได้ใน 5–10 นาที

---

# Phase 10: Meta Progression Lite

## เป้าหมาย

เพิ่มความก้าวหน้าระยะยาวแบบเล็ก ไม่ให้ scope บาน

## ระบบที่ควรทำ

### 1. Coins

ได้จาก:

- ชนะ Duel
- ชนะ Boss
- เล่นจบ run

ใช้กับ:

- เพิ่ม HP ถาวรเล็กน้อย
- เพิ่ม Stamina ถาวรเล็กน้อย
- เพิ่ม Attack เล็กน้อย

### 2. Save / Load

ใช้ Godot `FileAccess` บันทึก local save ง่าย ๆ

ข้อมูลที่ต้อง save ช่วงแรก:

- coins
- permanent_hp_level
- permanent_stamina_level
- permanent_attack_level
- unlocked_challenge_mode

### 3. Upgrade ถาวรชุดแรก

| Upgrade | ระดับสูงสุด | ผล |
|---|---:|---|
| ฝึกกาย | 5 | เพิ่ม Max HP |
| ฝึกลมปราณ | 5 | เพิ่ม Max Stamina |
| ฝึกคมดาบ | 5 | เพิ่ม Attack |
| ฝึกสายตา | 3 | เพิ่ม Parry posture damage |

## สิ่งที่ยังไม่ควรทำ

- เครื่องรางเยอะ
- inventory เต็มระบบ
- daily reward จริง
- ads x2 จริง
- IAP

## Definition of Done

- เล่นแล้วได้ coins
- ออกจากเกมแล้ว coins ไม่หาย
- ซื้อ upgrade แล้วรอบต่อไปค่าส่งผลจริง
- ระบบไม่ทำให้เกมเสีย balance

---

# Phase 11: Android Production Preparation

## เป้าหมาย

ทำให้เกม export และทดสอบบน Android จริงได้อย่างสม่ำเสมอ

## งานที่ต้องทำ

1. ติดตั้ง/ตรวจ Android SDK สำหรับ Godot
2. ตั้งค่า export preset Android
3. ตั้ง package name เช่น `com.shanwinder.lastbladetrial`
4. ตั้ง orientation ที่เหมาะสม เช่น landscape
5. สร้าง debug APK
6. ทดสอบบนมือถือจริง
7. จด FPS / input delay / UI scale
8. สร้าง release AAB ภายหลัง

## Performance Checklist

- ใช้ sprite น้อย
- หลีกเลี่ยง particle หนัก
- ระวัง AudioStreamGenerator จำนวนมากพร้อมกัน
- ลด allocation ซ้ำใน loop ถ้าเริ่มกระตุก
- ทดสอบบนเครื่องจริงเสมอ

## Definition of Done

- Export debug APK ได้
- ติดตั้งบน Android ได้
- เล่น vertical slice ได้
- ปุ่ม touch ใช้งานได้
- FPS ไม่ตกแบบเห็นได้ชัด

---

# Phase 12: Play Store Closed Testing

## เป้าหมาย

เตรียมส่งทดสอบแบบปิดก่อนปล่อยจริง

## สิ่งที่ต้องมี

- App icon 512x512
- Feature graphic
- Screenshot มือถือ
- Short description
- Full description
- Privacy Policy URL
- Data Safety form
- Content rating
- AAB file
- Closed testing group
- แบบฟอร์ม feedback

## Monetization ช่วงแรก

ยังไม่ควรใส่ ads ถ้า gameplay ยังไม่ผ่าน

เมื่อจะใส่ ads ให้ใช้เฉพาะ rewarded ads แบบสมัครใจ เช่น:

- revive 1 ครั้งหลังตาย
- coins x2 หลังชนะ
- reroll upgrade

ห้าม:

- บังคับดู ads ทุกครั้งที่ตาย
- interstitial ระหว่างสู้บอส
- banner บังปุ่มควบคุม

---

## 6. แผนเนื้อเรื่องฉบับใช้งานจริง

เกมนี้ควรมีเนื้อเรื่อง แต่ต้องเป็น lore สั้น ๆ ไม่ใช่เนื้อเรื่องยาว

### 6.1 แก่นเรื่อง

```text
นักดาบไร้นามตื่นขึ้นในหอประลองร้าง
เขาจำอดีตไม่ได้ เหลือเพียงดาบหนึ่งเล่มและเสียงของอาจารย์เก่า
ทุกการดวลคือบททดสอบ เพื่อเรียกคืนความทรงจำและปลุกพลังของดาบไร้นาม
```

### 6.2 Boss 1

ชื่อ:

> อาจารย์ดาบหัก / BossBrokenMaster

แนวคิด:

> อดีตอาจารย์ที่เหลือเพียงเงาความทรงจำ ใช้ดาบหัก แต่จังหวะฟันยังแม่นยำ หน้าที่ของเขาไม่ใช่แค่ฆ่าผู้เล่น แต่ทดสอบว่าผู้เล่นคู่ควรจะถือดาบไร้นามหรือไม่

### 6.3 ข้อความก่อนสู้ Boss 1

```text
“จำจังหวะดาบของข้าให้ได้...
หากเจ้าพลาด เจ้าจะล้ม
หากเจ้าอ่านข้าออก เจ้าจะตื่นขึ้นอีกครั้ง”
```

### 6.4 ข้อความหลังชนะ Boss 1

```text
“ดี...
ดาบไร้นามยังไม่เลือกเจ้าทั้งหมด
แต่มันเริ่มฟังเสียงเจ้าแล้ว”
```

### 6.5 หลักการใช้เนื้อเรื่อง

ควรทำ:

- ข้อความสั้น 1–3 บรรทัด
- lore ผ่านชื่อด่าน / ชื่อบอส / คำพูดก่อนสู้
- บรรยากาศเงียบ ขรึม กดดัน

ไม่ควรทำตอนนี้:

- Cutscene ยาว
- NPC หลายตัว
- บทสนทนายาว
- เควสต์
- โลกใหญ่

---

## 7. แผนกราฟิก Sprite และ Animation

### 7.1 ทำเมื่อไหร่

ควรเริ่มตอนนี้ในระดับ prototype visual ไม่ใช่ final art

ลำดับที่เหมาะสม:

1. Boss Pattern Debug Mode
2. Combat Tuning
3. Visual Prototype
4. Limited Animation
5. Mobile Test
6. Final art เฉพาะเมื่อ gameplay ผ่าน

### 7.2 หลักการภาพ

- ภาพต้องอ่านง่ายก่อนสวย
- silhouette เหมาะกับทุนน้อย
- ดาบและ effect ต้องเด่น
- ฉากหลังต้องไม่แย่งสายตาจากบอส
- สีของท่าบอสต้องสื่อสารชัด

### 7.3 Minimum Visual Set

| หมวด | Asset |
|---|---|
| Player | silhouette idle, attack pose, parry pose, dash pose |
| Boss | silhouette idle, normal pose, heavy pose, delayed pose, quick pose |
| Effects | slash, parry spark, dash trail, posture break burst |
| UI | ปุ่ม Attack, Dash, Parry, HP/Stamina/Focus/Posture bar |
| Arena | พื้น, background เรียบ, boundary visual |

---

## 8. แผนเสียง

### 8.1 สถานะปัจจุบัน

มี placeholder SFX ด้วย AudioStreamGenerator แล้วในจุดสำคัญ เช่น:

- Parry สำเร็จ
- Boss Posture Broken
- Focus Finisher โดนบอส
- Boss defeated

### 8.2 สิ่งที่ควรเพิ่ม

ลำดับเสียงที่ควรเพิ่ม:

1. Player attack swing
2. Player hit enemy
3. Player hurt
4. Dash
5. Parry fail หรือ stamina ไม่พอ
6. Boss wind-up heavy
7. Victory / Defeat
8. UI click

### 8.3 หลักการเสียง

- Parry ต้องสะใจที่สุด
- Heavy Slash ต้องมีเสียงเตือนต่างจากท่าปกติ
- Stamina ไม่พอต้องมีเสียงสั้นที่เข้าใจทันที
- เสียงไม่ควรดังเกินบนมือถือ

---

## 9. มาตรฐานการเขียนโค้ดต่อจากนี้

ทุกครั้งที่แก้โค้ดต้องยึดกติกานี้:

1. ใช้ Godot 4 syntax
2. ใส่คอมเมนต์ภาษาไทยในโค้ดใหม่ทุกครั้ง
3. ทำทีละไฟล์หรือทีละระบบย่อย
4. หลังแก้ต้องบอกวิธีทดสอบเสมอ
5. หลีกเลี่ยงการเพิ่มระบบใหญ่พร้อมกันหลายระบบ
6. ถ้าเกิด error ให้แก้จากข้อความ error ไม่ต้องขอรูป
7. ระวัง warning-as-error โดยใส่ type ให้ชัดเมื่อจำเป็น
8. ถ้าสร้าง node ด้วยโค้ด ต้องจัดการ queue_free ให้เรียบร้อย
9. ถ้าใช้ await กับ timer ต้องระวัง object ถูกลบกลางทาง
10. ถ้าใช้ Engine.time_scale ต้อง reset กลับเป็น 1.0 เมื่อจบเกมหรือ restart

---

## 10. แผนงาน 14 วันถัดไปจากสถานะปัจจุบัน

### Day 1: จัดระเบียบแผนและ repo

- สร้างเอกสารแผนฉบับปรับปรุง
- ตรวจชื่อ scene หลัก
- ตัดสินใจว่าจะ rename `scenes/main/BossBrokenMaster.tscn` เป็น `Main.tscn` หรือไม่

### Day 2: Boss Pattern Debug Mode

- เพิ่ม debug forced pattern
- ทดสอบ normal/heavy/delayed/quick ทีละท่า

### Day 3: จูน Normal และ Heavy

- ปรับ timing normal_slash
- ปรับ timing heavy_slash
- เพิ่ม feedback กรณี Parry ท่าหนักผิด

### Day 4: จูน Delayed และ Quick

- ทดสอบ delayed_slash ว่า WAIT/PARRY อ่านง่ายไหม
- ทดสอบ quick_slash ว่าเร็วเกินไปไหม

### Day 5: Parry / Dash Feel

- ปรับ parry_active_time
- ปรับ dash_time / dash_cooldown
- เพิ่ม feedback stamina ไม่พอ

### Day 6: Combat VFX Placeholder

- เพิ่ม parry spark
- เพิ่ม slash effect
- เพิ่ม dash trail เบื้องต้น

### Day 7: Visual Prototype Sprite

- สร้าง Player silhouette ชั่วคราว
- สร้าง Boss silhouette ชั่วคราว
- แทน icon.svg เฉพาะใน scene ทดสอบ

### Day 8: Limited Animation ด้วย AnimationPlayer

- Player idle/attack/parry/dash แบบง่าย
- Boss wind-up แบบ scale/rotation/color

### Day 9: Start / Victory / Defeat Loop

- เพิ่มหน้าเริ่ม
- เพิ่มปุ่ม Restart
- ทดสอบ restart หลายรอบ

### Day 10: Touch Controls Prototype

- เพิ่มปุ่ม Attack/Dash/Parry บนจอ
- เพิ่มซ้าย/ขวาบนจอหรือ joystick ชั่วคราว

### Day 11: Android Export Setup

- ตั้งค่า export preset
- export debug APK
- ติดตั้งมือถือจริง

### Day 12: Mobile Test 1

- ทดสอบปุ่ม
- จดปัญหา
- ปรับขนาดปุ่ม / ตำแหน่ง / parry timing

### Day 13: Upgrade Prototype แบบเบา

- หลังชนะ เลือก 1 จาก 3 upgrade
- ยังไม่ต้อง save

### Day 14: Playtest กับคนอื่น 1–3 คน

- ให้ลองโดยไม่อธิบายเยอะ
- จดว่าผู้เล่นเข้าใจ Attack/Dash/Parry ไหม
- จดว่าตายแล้วอยากลองใหม่ไหม

---

## 11. เกณฑ์ตัดสินว่าไปต่อ Phase ถัดไปได้หรือยัง

### ไป Phase 7 ได้เมื่อ

- Boss 1 สู้ได้จนจบ
- ผู้เล่นอ่านท่าได้
- มี feedback ชัดพอ
- restart ไม่พัง

### ไป Phase 8 ได้เมื่อ

- One-run loop เล่นซ้ำได้
- ชนะ/แพ้/เริ่มใหม่ครบ
- ไม่มี error จาก restart

### ไป Phase 9 ได้เมื่อ

- Upgrade prototype ส่งผลจริง
- Mobile controls เล่นได้
- Boss 1 ไม่รู้สึกโกง

### ไป Phase 10 ได้เมื่อ

- Vertical slice มี Training / Duel / Boss
- ผู้เล่นใหม่เข้าใจภายใน 1 นาที
- เล่นบนมือถือได้

### ไป Play Store preparation ได้เมื่อ

- Export Android ได้สม่ำเสมอ
- FPS ผ่าน
- ไม่มี error ร้ายแรง
- มีเกมเล่นได้ 10–15 นาทีขึ้นไป
- มี feedback จาก tester แล้ว

---

## 12. สิ่งที่ควรทำทันทีที่สุด

ลำดับงานที่ควรทำต่อจากเอกสารนี้:

1. เพิ่ม Boss Pattern Debug Mode
2. จูนท่า Boss ทีละท่า
3. เพิ่ม feedback เมื่อทำผิด เช่น Parry ท่าหนัก
4. เพิ่ม VFX placeholder: parry spark / slash / dash trail
5. ทำ visual silhouette ชั่วคราวแทน icon.svg
6. ทำ touch controls
7. ทดสอบบน Android จริง

ห้ามข้ามไปทำระบบ save, ads, shop, daily หรือ boss ตัวที่ 2 จนกว่า Boss 1 จะสนุกและเล่นบนมือถือได้จริง

---

## 13. สรุปแนวทางสุดท้าย

Last Blade Trial / ดาบไร้นาม ไม่ควรถูกพัฒนาแบบเกมใหญ่ แต่ควรถูกพัฒนาเป็นเกมเล็กที่คมมาก

แกนหลักที่ต้องรักษาไว้คือ:

- ดวลสั้น
- ปุ่มน้อย
- อ่านจังหวะ
- Parry สะใจ
- Dash มีความหมาย
- Boss fair
- ตายแล้วอยากลองใหม่
- ภาพอ่านง่ายบนมือถือ
- ระบบไม่บานเกินกำลังผู้พัฒนาคนเดียว

เป้าหมายสูงสุดคือ Play Store แต่เส้นทางที่ปลอดภัยที่สุดคือ:

```text
Boss 1 สนุก
→ เล่นบนมือถือได้
→ มี one-run loop
→ มี upgrade เบา ๆ
→ มี vertical slice
→ มี save/meta progression
→ export Android
→ closed testing
→ Play Store
```

ถ้ายึดลำดับนี้ เกมมีโอกาสสูงที่จะพัฒนาไปถึงผลงานจริงได้โดยไม่หลุด scope
