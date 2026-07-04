# แผนพัฒนาต่อยอด Last Blade Trial / ดาบไร้นาม สู่ Play Store

วันที่สร้างเอกสารเดิม: 2026-07-04  
วันที่ปรับปรุง: 2026-07-05  
Repo: `shanwinder/lastblade`  
โฟลเดอร์เกม: `last-blade-trial`  
เป้าหมาย: เกมดวลดาบ 2D Mobile Boss Duel ที่ทุนต่ำ แต่คุณภาพพอสำหรับ Android / Google Play Store

---

## 0. สรุปทิศทางหลังการกลั่นกรองล่าสุด

แผนนี้ปรับจากแนวคิดเดิมที่เน้น `Boss 1 + Upgrade + Replay` ให้ชัดขึ้นว่า:

```text
บอสตัวเดียวไม่เพียงพอสำหรับการทำเงินระยะยาว
แต่เพียงพอสำหรับการพิสูจน์แกนเกมช่วงต้น
```

ดังนั้นเป้าหมายปัจจุบันไม่ใช่การทำเกมเต็มทันที แต่คือ:

```text
สร้าง Core Combat Seed ที่แข็งแรงพอ
เพื่อใช้เป็นฐานสำหรับเพิ่ม Boss, Content, Progression และ Monetization ในอนาคต
```

คำจำกัดความของสถานะปัจจุบัน:

```text
Early Vertical Slice Candidate / Core Combat Seed
```

สิ่งที่ต้องยอมรับตรง ๆ:

```text
- ถ้าสู้บอสตัวเดิมซ้ำแบบเดิม เกมจะน่าเบื่อ
- ถ้าเพิ่มแค่ตัวเลขความยาก แต่ไม่มีประสบการณ์ใหม่ ก็ยังไม่พอ
- ถ้าหวัง retention และรายได้ระยะยาว ต้องมี content ใหม่ในอนาคต
- แต่ตอนนี้ยังไม่ควรรีบเพิ่ม Boss 2 ก่อน Boss 1 จะสนุกจริง
```

สรุปแนวทาง:

```text
ตอนนี้: ทำบอสตัวเดียวให้คม อ่านง่าย และอยากลองใหม่
ถัดไป: ทำให้บอสเดิมมีหลายชั้นของบททดสอบผ่าน phase, modifier, asset และ memory upgrade
อนาคต: เพิ่ม Boss 2, arena ใหม่, ระบบ progression ลึกขึ้น และ monetization แบบไม่ทำลายเกม
```

---

## 1. สถานะปัจจุบันหลังเทียบกับแผนเดิม

จากแผนเดิม `docs/2_แผนการพัฒนาเกม_Last_Blade_Trial_ฉบับปรับปรุง.md` โปรเจกต์เดินเลยจุด prototype หลายส่วนแล้ว

สิ่งที่ถือว่าเดินหน้าแล้ว:

```text
- Boss 1 ใช้งานจริงใน main scene แล้ว
- มี GameLoopManager พร้อมหน้า Start / Victory / Defeated / Restart
- มี UpgradeRunState แบบ runtime-only
- มี TouchControls บนมือถือ
- มี TrainingCoachManager / Duel1IntroManager / Duel1DummyManager
- มี BossGrabBalanceManager
- มี MovementDeflectBalanceManager
- มี Player sprite จริงบางท่า: idle / run / back
- มี AnimatedSprite2D transition layer สำหรับ Player
- มี arena visual manager และ visual direction เริ่มชัดขึ้น
```

สถานะโดยรวมตอนนี้จึงไม่ใช่ prototype ต้นทางแล้ว แต่ยังไม่ใช่ product-ready build

สิ่งที่ยังขาดก่อนส่งให้ผู้เล่นทั่วไป:

```text
- ความนิ่งของ animation state
- Player attack / dash / hurt / death visual ที่อ่านชัด
- Boss wind-up visual แยกตามท่า
- VFX/SFX ที่ช่วยอ่าน combat
- Story frame สั้น ๆ ที่ทำให้ผู้เล่นอิน
- Replay loop ที่ไม่ใช่แค่บอสเดิมตัวเลขสูงขึ้น
- Android test build ที่ทดสอบซ้ำได้
```

---

## 2. หลักคิดที่ต้องยึดต่อจากนี้

### 2.1 เกมนี้ควรเล็ก แต่คม

เป้าหมายช่วงนี้ไม่ใช่การเพิ่ม content จำนวนมาก แต่คือทำให้แกนหลักรู้สึกดี:

```text
อ่านท่าบอสได้ → ตัดสินใจถูก → รอด → สวนกลับ → ได้รางวัล → อยากลองใหม่
```

สิ่งที่ต้องชัดก่อนเพิ่มระบบใหญ่:

```text
- Dash หลบแล้วรู้สึกแม่น
- Deflect สำเร็จแล้วสะใจ
- โดนตีแล้วรู้ว่าพลาดอะไร
- ชนะแล้วรู้สึกว่าฝีมือดีขึ้น
- แพ้แล้วอยากลองใหม่
- เล่นบนมือถือแล้วปุ่มไม่ขัดมือ
```

### 2.2 บอสตัวเดียวคือสารตั้งต้น ไม่ใช่คำตอบสุดท้าย

บอสตัวเดียวใช้ได้สำหรับพิสูจน์เกม แต่ไม่ควรหลอกตัวเองว่านี่พอสำหรับเกมทำเงินระยะยาว

บทบาทของ Boss 1 ตอนนี้คือ:

```text
- พิสูจน์ว่า combat loop สนุกหรือไม่
- พิสูจน์ว่า touch controls ใช้งานจริงหรือไม่
- พิสูจน์ว่า visual readability ไปต่อได้หรือไม่
- พิสูจน์ว่า player อยากกด retry หรือไม่
```

บทบาทของ Boss 1 ไม่ใช่:

```text
- เป็น content ทั้งหมดของเกมระยะยาว
- เป็นระบบทำเงินหลัก
- เป็นเหตุผลให้ผู้เล่นอยู่กับเกมเป็นเดือน ๆ
```

### 2.3 ห้ามเพิ่ม Boss 2 เพื่อหนีปัญหา Boss 1

ถ้า Boss 1 ยังไม่สนุก การเพิ่ม Boss 2 จะเพิ่มภาระ asset, animation, balance และ bug โดยไม่ได้แก้รากปัญหา

เงื่อนไขก่อนเริ่ม Boss 2:

```text
- Boss 1 เล่นซ้ำอย่างน้อย 5-10 รอบแล้วไม่รู้สึกพัง
- ผู้เล่นใหม่เข้าใจ Dash / Deflect / Attack ได้โดยไม่ต้องอธิบายยาว
- Animation และ VFX หลักไม่ทำให้เข้าใจผิด
- Touch controls ใช้ได้จริงบนมือถือ
- มี result / reward / restart loop ที่ลื่น
```

### 2.4 Asset จริงคือเครื่องมือสร้างมิติ ไม่ใช่แค่ความสวย

asset ของ Player, Boss, VFX, UI และ Background ไม่ได้มีหน้าที่ทำให้เกมดูดีอย่างเดียว แต่มีหน้าที่:

```text
- ทำให้ผู้เล่นอ่านท่าออก
- ทำให้ตัวละครมีตัวตน
- ทำให้บอสมีน้ำหนัก
- ทำให้การชนะ/แพ้มีอารมณ์
- ทำให้บอสเดิมแต่ละรอบรู้สึกต่างขึ้น
```

หลักการ asset ตอนนี้:

```text
ใช้ working art ก่อน → ทดสอบในเกมจริง → จดปัญหา → generate/วาด/แก้ใหม่ → แทนที่ทีละชุด
```

ไม่ควรรอ final art ครบก่อนเดิน gameplay ต่อ

---

## 3. Story Frame: ไม่เล่ายาว แต่ต้องมีเหตุผลให้สู้

ถ้าเปิดเกมแล้วผู้เล่นถูกโยนเข้าหา Boss ทันทีโดยไม่มีบริบท เกมจะเสี่ยงกลายเป็นแค่ตัวละครสองตัวยืนตี กัน

เกมควรมี story frame สั้นมาก เพื่อบอกว่า:

```text
เราเป็นใคร
บอสคือใคร
ทำไมต้องสู้
ทำไมตายแล้วเริ่มใหม่
ทำไมชนะแล้วได้ upgrade
```

แนวเรื่องหลักที่เหมาะกับชื่อ `ดาบไร้นาม`:

```text
นักดาบไร้นามตื่นขึ้นในลานดวลดาบใต้จันทร์แตก
เขาจำชื่อตัวเองไม่ได้
จำได้เพียงน้ำหนักของดาบในมือ
ตรงหน้าคืออาจารย์ดาบหัก ผู้เคยสอนเขา หรืออาจเป็นเงาความทรงจำของเขาเอง
ทุกการดวลคือบททดสอบเพื่อทวงคืนวิชาดาบและตัวตนที่หายไป
```

ประโยคเปิดเกมตัวอย่าง:

```text
“เจ้าจำชื่อของตนได้หรือไม่?”
“ถ้าจำไม่ได้... จงจำดาบของเจ้าให้ได้ก่อน”
“บททดสอบแรก เริ่มได้”
```

### 3.1 Tutorial ควรเป็น Diegetic Tutorial

ไม่ควรตัดการสอนเล่นออกทั้งหมด แต่ควรหลีกเลี่ยง tutorial แข็ง ๆ

แนวทางที่เหมาะกว่า:

```text
ให้บอสเป็นผู้สอนผ่านการดวลจริง
```

ตัวอย่าง:

```text
Trial 1: บอสใช้แค่ normal/heavy เพื่อสอน Deflect และ Dash
Trial 2: เพิ่ม delayed เพื่อสอนการรอจังหวะ
Trial 3: เพิ่ม quick/grab เพื่อสอนการอ่านความกดดัน
```

ผู้เล่นจะรู้สึกว่าได้เรียนเองผ่านการลองผิดลองถูก แต่เกมยังควบคุมการเรียนรู้ไม่ให้โหดเกินไป

---

## 4. Replay Loop ระยะสั้น: One Boss, Many Trials

แนวคิดที่ต้องเลี่ยง:

```text
ชนะ → ได้ upgrade → สู้บอสเดิมที่เลือดเยอะขึ้น → วนซ้ำ
```

เพราะนี่จะน่าเบื่อเร็ว

แนวคิดที่ควรใช้:

```text
บอสเดิม แต่แต่ละรอบคือบททดสอบใหม่
```

ชื่อแนวคิด:

```text
One Boss, Many Trials
```

โครงสร้างที่แนะนำ:

```text
เปิดเกม
→ เกริ่นสั้น
→ Trial 1: อาจารย์ยังไม่เอาจริง
→ ชนะ ได้ Memory Upgrade
→ Trial 2: บอสเพิ่ม delayed / pattern ใหม่
→ ชนะ ได้ Memory Upgrade
→ Trial 3: บอสใช้ pattern เต็ม + grab
→ ชนะ ปลด Challenge / Endless Duel
→ แพ้ เริ่มใหม่ แต่ผู้เล่นจำจังหวะได้มากขึ้น
```

แต่ละ Trial ควรเปลี่ยนอย่างน้อย 1 อย่าง:

```text
- ท่าบอสที่อนุญาตให้ใช้
- ความถี่ของท่า
- recovery/cooldown
- ข้อจำกัดของผู้เล่น
- กติกา challenge
- visual state ของบอส/ฉาก
- ข้อความ memory/story หลังชนะ
```

เป้าหมายคือให้ผู้เล่นไม่รู้สึกว่า:

```text
บอสเดิมอีกแล้ว
```

แต่รู้สึกว่า:

```text
บททดสอบลึกขึ้นแล้ว
```

---

## 5. Memory Upgrade: แปลง upgrade จากตัวเลขเป็นตัวตนของ build

Upgrade ตอนนี้ใช้ได้เป็น prototype แต่ระยะต่อไปต้องค่อย ๆ เปลี่ยนจาก `+ตัวเลข` เป็น `เปลี่ยนวิธีเล่น`

แรงบันดาลใจเชิงออกแบบ:

```text
เกม action สั้น ๆ เล่นซ้ำได้ถ้ามี build identity
```

ระบบของ Last Blade Trial ควรใช้ชื่อเชิงเนื้อเรื่องว่า:

```text
Memory Upgrade / เศษความทรงจำของวิชาดาบ
```

สายหลักที่ควรมี:

```text
คมดาบ      = damage / posture damage / counter damage
ลมหายใจ    = stamina / recovery / sustain
เงาก้าว     = dash / backstep / reposition / dash counter
ใจนิ่ง      = deflect / focus / timing reward
เลือดดาบ    = risk-reward เมื่อ HP ต่ำ
```

ตัวอย่าง upgrade ที่เปลี่ยนวิธีเล่น:

```text
เงาก้าว:
Dash ผ่านบอสแล้ว Attack ครั้งถัดไปเป็น Dash Counter

ใจนิ่ง:
Deflect สำเร็จแล้วฟื้น Stamina เล็กน้อย

คมดาบ:
Attack ตอนบอสอยู่ใน recovery ทำ Posture Damage เพิ่ม

ลมหายใจ:
ถอยหลังโดยไม่โดนโจมตีชั่วครู่ จะเร่ง Stamina Regen

เลือดดาบ:
เมื่อ HP ต่ำกว่า 30% ได้ Focus เร็วขึ้น แต่รับดาเมจแรงขึ้นเล็กน้อย
```

ข้อควรระวัง:

```text
- อย่าเพิ่ม upgrade เยอะเกินไปก่อน balance พื้นฐานนิ่ง
- อย่าให้ upgrade ทำให้ Boss 1 กลายเป็นหุ่น
- อย่าเพิ่มปุ่มใหม่ถ้าไม่จำเป็น
- ให้ปุ่มเดิมทำผลต่างกันตามสถานการณ์
```

---

## 6. Asset Roadmap: เพิ่มมิติให้เกมโดยไม่เพิ่มระบบใหญ่

### 6.1 หลักคิด Asset

Asset ใหม่ควรตอบอย่างน้อยหนึ่งข้อ:

```text
- อ่าน gameplay ชัดขึ้นหรือไม่
- ทำให้ combat มีน้ำหนักขึ้นหรือไม่
- ทำให้ตัวละครมีตัวตนขึ้นหรือไม่
- ทำให้บอสเดิมแต่ละ Trial รู้สึกต่างขึ้นหรือไม่
- ช่วยลดการพึ่งข้อความ hint หรือไม่
```

ถ้า asset สวยแต่ไม่ช่วยข้อใดเลย ให้เลื่อนไปก่อน

### 6.2 Player Asset Priority

ลำดับที่ควรทำ:

```text
1. Attack 1 ท่าให้ชัด
2. Dash pose / dash visual
3. Hurt pose
4. Death pose
5. Deflect / guard response
6. Focus-ready pose หรือ glow
7. Finisher / counter slash
```

เป้าหมาย:

```text
- ผู้เล่นรู้ว่ากำลังทำ action อะไร
- hitbox active ไม่หลอกตา
- dash ดูเร็วและมีแรง
- hurt/death มีอารมณ์
- finisher เป็นจุดพีคของไฟต์
```

### 6.3 Boss Asset Priority

ลำดับที่ควรทำ:

```text
1. Boss idle
2. Normal wind-up
3. Heavy wind-up
4. Delayed wait pose
5. Quick wind-up
6. Grab wind-up
7. Attack release pose
8. Hurt / stagger
9. Posture broken
10. Death
```

หลักสำคัญ:

```text
Boss wind-up สำคัญกว่า full smooth animation
```

เพราะบอสต้องสื่อว่า:

```text
ท่านี้ต้อง Deflect
ท่านี้ต้อง Dash
ท่านี้อย่าเพิ่งกด
ท่านี้ต้องถอย
```

### 6.4 VFX Asset Priority

```text
1. Player slash arc
2. Boss slash arc
3. Deflect spark
4. Hit spark
5. Dash trail
6. Posture break burst
7. Grab impact
8. Focus ready aura
9. Finisher impact
```

หลักการ VFX:

```text
สั้น ชัด ไม่รก ไม่บังปุ่ม ไม่บัง boss hint และไม่หนัก performance
```

### 6.5 UI / Control Button Asset

UI control button ควรเข้าธีมเกม ไม่ใช่ปุ่ม generic

```text
Attack = icon คมดาบ
Dash = icon เงาก้าว / เส้นพุ่ง
Lock = icon เป้าดาบ / ตราล็อกเป้าหมาย
Deflect/Tap = icon ประกายปะทะหรือฝ่ามือรับดาบ
```

เป้าหมาย:

```text
ผู้เล่นเข้าใจปุ่มจากภาพได้เร็วขึ้น และ UI ดูเป็นส่วนหนึ่งของโลกเกม
```

### 6.6 Background Variation แบบประหยัด

ยังไม่ต้องมี arena หลายฉาก แต่ควรมี state variation:

```text
Trial 1: Moonlit calm
Trial 2: Ash / ember เพิ่มเล็กน้อย
Trial 3: Memory crack / fog / moon distortion
Challenge: Darker arena / stronger contrast
```

ใช้ฉากเดิม แต่ปรับ layer/overlay เพื่อให้บอสเดิมรู้สึกไม่ซ้ำเท่าเดิม

---

## 7. Roadmap ต่อจากนี้แบบค่อยเป็นค่อยไป

## Phase A: Stabilize Current Core Combat Seed

เป้าหมาย: ทำให้สิ่งที่มีอยู่ตอนนี้ไม่พังง่าย และทดสอบซ้ำได้

งานที่ต้องทำ:

```text
1. ทดสอบ main scene ตั้งแต่ Start → Boss → Victory / Defeated → Restart
2. ทดสอบเลือก upgrade หลังชนะ 3 รอบติดกัน
3. ทดสอบ TouchControls บนมือถือจริง
4. ทดสอบ lock-on, run, back, dash, attack, grab
5. จด bug เฉพาะที่กระทบการเล่นจริง
6. ปิด debug print ที่รบกวนเฉพาะเมื่อเริ่มทำ build ให้คนอื่นลอง
```

Definition of Done:

```text
- เล่นได้อย่างน้อย 5 รอบติดกันโดยไม่มี error ใหญ่
- Restart แล้วไม่เกิด hitbox ค้าง / coroutine ค้าง
- TouchControls ไม่บังการเล่นหลัก
- Player animation idle/run/back ไม่หันผิดฝั่ง
- Upgrade หลังชนะส่งผลจริงในรอบถัดไป
```

ห้ามทำใน Phase นี้:

```text
- ห้ามเพิ่ม Boss ใหม่
- ห้ามใส่ ads จริง
- ห้าม refactor ใหญ่โดยไม่จำเป็น
```

---

## Phase B: Story Hook + Diegetic Tutorial

เป้าหมาย: ทำให้ผู้เล่นไม่รู้สึกว่าถูกโยนเข้าหาบอสโดยไร้เหตุผล

งานที่ต้องทำ:

```text
1. เพิ่มข้อความเกริ่น 2-3 บรรทัดก่อนเริ่มเกม
2. ให้ Boss หรือเสียงความทรงจำพูดสั้น ๆ ระหว่าง Trial แรก
3. ไม่ทำ tutorial ยาว
4. จำกัด pattern ใน Trial แรกเพื่อให้ผู้เล่นเรียนรู้เอง
5. ใช้คำพูดหลังแพ้/ชนะเพื่อเสริม story และแรงจูงใจ
```

Definition of Done:

```text
- ผู้เล่นรู้ว่าเป็นนักดาบไร้นาม
- ผู้เล่นรู้ว่าบอสคืออาจารย์/เงาความทรงจำ
- ผู้เล่นเข้าใจว่าการสู้ซ้ำคือบททดสอบ
- tutorial ไม่รู้สึกเป็นห้องเรียน
```

---

## Phase C: Player Action Readability

เป้าหมาย: ทำให้ผู้เล่นอ่านตัวเองได้ชัดก่อน โดยเฉพาะบนมือถือ

งานที่ต้องทำตามลำดับ:

```text
1. จัด animation state ให้ชัด: idle / run / back / attack / dash / hurt / death
2. เพิ่ม attack animation จริง 1 ท่า
3. เพิ่ม dash visual จริงหรือ dash pose
4. เพิ่ม hurt flash / hurt pose
5. เพิ่ม death pose แบบง่าย
6. ทำให้ dash trail ใช้ frame ปัจจุบันของ AnimatedSprite2D ได้ แทน compatibility Sprite2D
7. ค่อยลดบทบาท Sprite2D compatibility layer เมื่อมั่นใจ
```

แนวทางสำคัญ:

```text
ยังไม่ต้องเพิ่ม combo
ให้โจมตี 1 จังหวะอ่านชัดก่อน
action แต่ละท่าต้องไม่ทำให้ hitbox / hurtbox เข้าใจผิด
```

Definition of Done:

```text
- ยืนเฉย ๆ เห็น idle
- เดินเข้าเห็น run
- lock-on แล้วถอยเห็น back
- กดโจมตีเห็น attack pose ชัด
- dash แล้วรู้ว่าตัวละครพุ่งจริง
- โดนตีแล้วรู้ว่าโดน
- ตายแล้วจบชัด ไม่งง
```

---

## Phase D: Boss 1 Visual Readability

เป้าหมาย: ทำให้ BossBrokenMaster อ่านท่าได้จากภาพ ไม่ใช่อ่านแต่ตัวหนังสือ

ลำดับ asset/animation ที่ควรทำ:

```text
1. Boss idle sprite จริง
2. Boss normal wind-up pose
3. Boss heavy wind-up pose
4. Boss delayed wait pose
5. Boss quick wind-up pose
6. Boss grab wind-up pose
7. Boss attack release pose
8. Boss posture broken pose
9. Boss hurt flash
10. Boss death pose
```

แนวทางทุนต่ำ:

```text
ไม่จำเป็นต้อง full animation ทุกท่า
ใช้ pose สำคัญ 1-3 frame ต่อท่าก่อน
ใช้ VFX slash แยกจากตัวบอส
ใช้สี / scale / shake ช่วยสื่อสาร
```

Definition of Done:

```text
- ผู้เล่นเดาได้ว่าท่าไหนต้อง Dash
- ผู้เล่นเดาได้ว่าท่าไหนต้อง Deflect
- ผู้เล่นเดาได้ว่าท่าไหนต้องถอย
- Delayed Slash ไม่รู้สึกโกง
- Quick Slash เร็วแต่ไม่มั่ว
- ไม่ต้องพึ่งข้อความ hint 100%
```

---

## Phase E: One Boss, Many Trials Prototype

เป้าหมาย: ทำให้บอสตัวเดียวไม่ใช่บอสเดิมซ้ำ ๆ

Trial structure เริ่มต้น:

```text
Trial 1: Normal + Heavy เท่านั้น
Trial 2: เพิ่ม Delayed
Trial 3: เพิ่ม Quick + Grab
Trial 4: Challenge modifier เช่น time limit / damage limit / faster boss
```

งานที่ต้องทำ:

```text
1. กำหนด Trial Level ปัจจุบัน
2. จำกัด pattern ตาม Trial
3. เพิ่มข้อความ memory หลังชนะ
4. ให้ upgrade เป็น Memory Upgrade
5. ปรับ visual state ของ arena/boss ตาม Trial ถ้า asset พร้อม
```

Definition of Done:

```text
- รอบถัดไปไม่รู้สึกเหมือนรอบเดิม 100%
- ผู้เล่นรู้ว่าบททดสอบลึกขึ้น
- Boss 1 ยังเป็นบอสตัวเดิม แต่ความกดดันเปลี่ยน
```

---

## Phase F: Combat Feel Pass

เป้าหมาย: ทำให้การปะทะรู้สึกมีน้ำหนักขึ้นโดยใช้ต้นทุนต่ำ

งานที่ควรทำ:

```text
1. Player slash VFX จริง
2. Boss slash VFX จริง
3. Deflect spark จริง
4. Hit spark ตอนโจมตีโดน
5. Dash trail ที่อ่านง่าย
6. Posture break burst
7. Focus ready glow
8. Finisher impact แบบสั้นแต่หนัก
9. SFX placeholder → SFX ชุดใช้งานจริงรอบแรก
```

หลักการ:

```text
VFX ต้องช่วยอ่าน gameplay ไม่ใช่บังตัวละคร
บนมือถือจอต้องไม่รก
ทุก effect ต้องสั้น ชัด และไม่หนัก performance
```

Definition of Done:

```text
- ตีโดนแล้วรู้สึกโดนจริง
- Deflect สำเร็จแล้วสะใจ
- Dash หลบแล้วเห็นชัด
- Boss posture broken แล้วรู้ทันทีว่าเป็นช่องสวน
- Focus Finisher เป็นจุดพีคของไฟต์
```

---

## Phase G: Mobile Control Polish

เป้าหมาย: ทำให้การเล่นบนมือถือไม่แพ้ keyboard มากเกินไป

งานที่ต้องทำ:

```text
1. ทดสอบปุ่มบน OPPO / Android จริง
2. ปรับขนาดปุ่ม Attack / Dash / Lock / joystick
3. ปรับระยะห่าง Dash กับ Attack ไม่ให้กดผิด
4. ปรับ opacity ปุ่มไม่ให้บังฉาก
5. เพิ่ม option ง่าย ๆ: ปุ่มเล็ก / กลาง / ใหญ่
6. จูน movement deflect และ tap deflect ให้เหมาะกับนิ้วจริง
7. บันทึกปัญหา input delay
```

Definition of Done:

```text
- เล่นด้วยนิ้วโป้งได้จริง
- Dash หลบท่าหนักได้ไม่ยากเกินไป
- Deflect สำเร็จเพราะจังหวะ ไม่ใช่เพราะกดมั่ว
- ปุ่มไม่บัง boss hint / player / boss
```

---

## Phase H: Boss 1 Balance Lock

เป้าหมาย: ล็อกค่าหลักของ Boss 1 ให้เป็นเวอร์ชัน vertical slice

สิ่งที่ต้องวัด:

```text
- เวลาเฉลี่ยต่อไฟต์
- จำนวนครั้งที่ผู้เล่นตายก่อนชนะครั้งแรก
- ท่าที่ทำให้ผู้เล่นบ่นว่าโกง
- ท่าที่ง่ายเกินไปจนไม่ต้องคิด
- Focus Finisher ใช้ได้บ่อยแค่ไหน
- Upgrade ทำให้เกมแตก balance หรือไม่
```

ค่าเป้าหมายเบื้องต้น:

```text
- ไฟต์หนึ่งรอบประมาณ 1-3 นาที
- ผู้เล่นใหม่ควรเริ่มเข้าใจใน 3-5 รอบ
- ชนะครั้งแรกควรรู้สึกว่าเรียนรู้ ไม่ใช่ดวง
- Upgrade ควรช่วยเล็กน้อย ไม่ทำให้บอสกลายเป็นหุ่น
```

Definition of Done:

```text
- Boss 1 เล่นซ้ำแล้วยังรู้สึกแฟร์
- ตายแล้วรู้ว่าเพราะอะไร
- ชนะแล้วอยากลองรอบถัดไป / เลือก upgrade ต่อ
```

---

## Phase I: Vertical Slice Packaging

เป้าหมาย: ทำเกมเป็น package ที่ให้คนอื่นทดลองได้

โครงสร้างที่ควรมี:

```text
1. Story hook สั้น
2. Trial 1 / tutorial แบบแฝง
3. Boss 1 หลาย Trial
4. Victory / Defeated screen
5. Memory Upgrade choice
6. Restart loop
7. Basic settings
8. Credits / feedback link ภายหลัง
```

สิ่งที่ต้องขัด:

```text
- ข้อความทั้งหมดต้องสั้น
- UI ต้องอ่านง่ายบนมือถือ
- ไม่มี console-only feedback ที่สำคัญ
- ไม่มี placeholder ที่ทำให้คนเล่นงง
```

Definition of Done:

```text
- ส่ง APK ให้คนอื่นเล่นได้โดยไม่ต้องอธิบายมาก
- คนเล่นเข้าใจเป้าหมายภายใน 1 นาที
- เล่นจบหนึ่ง loop ได้ภายใน 5-10 นาที
```

---

## Phase J: Android Build Discipline

เป้าหมาย: ทำให้ export/test Android เป็นงานประจำ ไม่ใช่ทำท้ายสุด

งานที่ต้องทำ:

```text
1. ตั้งค่า Android export preset ให้เสถียร
2. สร้าง debug APK ทุกครั้งหลัง milestone สำคัญ
3. ทดสอบ FPS / input / UI scale บนเครื่องจริง
4. จด build version สั้น ๆ เช่น v0.1.0-test
5. เก็บ screenshot จากมือถือจริง
```

Definition of Done:

```text
- สร้าง APK ได้ซ้ำโดยไม่ติด setup
- ติดตั้งบนมือถือจริงได้
- main loop เล่นได้บนมือถือ
- FPS ไม่ตกแบบเห็นได้ชัด
```

---

## Phase K: Soft Closed Test

เป้าหมาย: ให้คนกลุ่มเล็กลองเล่นก่อนคิดเรื่องเงิน

กลุ่มทดสอบแรก:

```text
- 3-5 คนที่ยอมบอกตรง ๆ ว่าเล่นยาก/งงตรงไหน
- ไม่ต้องเป็น gamer ทุกคน
- อย่างน้อย 1 คนควรไม่เคยเล่นเกมแนว Souls-like
```

คำถามที่ต้องเก็บ:

```text
1. เข้าใจปุ่มไหม
2. รู้ไหมว่าต้อง Dash ท่าไหน
3. รู้ไหมว่าต้อง Deflect ท่าไหน
4. ตายแล้วอยากลองใหม่ไหม
5. ภาพอ่านออกไหมบนมือถือ
6. ปุ่มบังไหม
7. เกมยากแบบแฟร์ไหม
8. สู้บอสตัวเดิมแล้วน่าเบื่อเร็วไหม
```

Definition of Done:

```text
- ได้ feedback จริงอย่างน้อย 10 ประเด็น
- แยก bug / balance / readability / art / replay ได้
- เลือกแก้เฉพาะ 5 จุดที่กระทบที่สุดก่อน
```

---

## Phase L: Future Content Expansion

เป้าหมาย: เตรียมทางไปสู่เกมที่มี content พอสำหรับ retention และรายได้จริง

เริ่มคิดเมื่อ Core Combat Seed ผ่านแล้วเท่านั้น

Content ที่ควรเพิ่มตามลำดับ:

```text
1. Boss 2 ที่ใช้ระบบพื้นฐานร่วมกับ Boss 1 แต่มีจังหวะต่างกัน
2. Arena 2 ที่เปลี่ยน mood และ readability
3. Memory Upgrade สายใหม่
4. Challenge mode รายวันแบบ offline/simple ก่อน
5. Cosmetic reward หรือ title reward
6. Boss rush / streak mode
```

สิ่งที่ต้องไม่ลืม:

```text
การเพิ่ม content ใหม่ต้องไม่ทำให้แกน combat หลวม
```

Boss 2 ควรเกิดจากคำถาม:

```text
บอสใหม่นี้บังคับให้ผู้เล่นเรียนรู้ทักษะใหม่อะไร?
```

ไม่ใช่แค่:

```text
บอสใหม่เพราะต้องมี content ใหม่
```

---

## Phase M: Monetization Readiness

เป้าหมาย: เตรียมทำเงินแบบไม่ทำลายเกม

แนวทางรายได้ช่วงแรก:

```text
Free-to-play + Rewarded Ads เท่านั้น
```

ตำแหน่ง ads ที่เหมาะ:

```text
1. ดูโฆษณาเพื่อ revive 1 ครั้งหลังตาย
2. ดูโฆษณาเพื่อรับ coins x2 หลังชนะ
3. ดูโฆษณาเพื่อ reroll upgrade
```

ห้ามทำ:

```text
- ห้าม interstitial ระหว่างสู้บอส
- ห้าม banner บังปุ่มควบคุม
- ห้ามบังคับดูโฆษณาหลังตายทุกครั้ง
- ห้ามใส่ IAP ก่อน gameplay นิ่ง
```

ก่อนใส่ ads จริงต้องมี:

```text
- save/load coins
- privacy policy
- data safety ที่เข้าใจเองได้
- consent / policy ตามข้อกำหนดที่เกี่ยวข้อง
- content มากพอให้ rewarded ads มีความหมาย
```

Definition of Done:

```text
- ผู้เล่นไม่รู้สึกว่าโดนบังคับดู ads
- ads ช่วยเพิ่ม replay value ไม่ใช่ขัด flow
- ไม่มี ads ในระหว่าง combat
```

---

## Phase N: Play Store Preparation

เป้าหมาย: เตรียม asset และเอกสารเพื่อส่งทดสอบแบบปิด

ต้องมี:

```text
- App icon 512x512
- Feature graphic
- Screenshot มือถือจริง
- Short description
- Full description
- Privacy Policy URL
- Data Safety form
- Content rating
- AAB release build
- Closed testing track
- แบบฟอร์ม feedback
```

Definition of Done:

```text
- ส่ง Closed Testing ได้
- มีผู้ทดสอบจริง
- รู้ว่าก่อน public release ต้องแก้อะไร
```

---

## 8. ลำดับงานที่แนะนำทันทีหลังเอกสารนี้

ลำดับที่ควรทำก่อนที่สุด:

```text
1. Stabilize animation state ปัจจุบัน: idle / run / back ให้ไม่หันผิด ไม่ลอย ไม่สะดุด
2. เพิ่ม Player attack animation จริง 1 ท่าเข้าระบบ AnimatedSprite2D
3. เพิ่ม Player dash visual / dash pose
4. เพิ่ม Story Hook สั้นก่อนเริ่มเกม
5. เพิ่ม Boss idle และ Boss wind-up pose อย่างน้อย normal/heavy
6. วาง Trial 1 ให้เหมือน tutorial แฝง ไม่ใช่ห้องสอนเล่น
7. ทดสอบมือถือจริง 5 รอบติด
8. จูน Boss 1 จาก feedback ของตัวเองก่อน
9. ทำ APK test build รอบแรกที่มี sprite จริง
```

ยังไม่ควรข้ามไป:

```text
- Boss 2
- ads จริง
- save/load ถาวร
- Play Store listing
```

จนกว่า Boss 1 + mobile controls + visual readability + basic replay loop จะนิ่ง

---

## 9. ตัวชี้วัดว่าพร้อมไป Play Store หรือยัง

เกมเริ่มพร้อมเข้าสู่ Play Store closed testing เมื่อผ่านเงื่อนไขนี้:

```text
- คนเล่นใหม่เข้าใจวิธีเล่นใน 1 นาที
- เล่นจบหนึ่ง loop ได้ใน 5-10 นาที
- Boss 1 แพ้แล้วอยากลองใหม่
- ปุ่มมือถือไม่ขัดมือ
- ภาพอ่านออกบนจอเล็ก
- มี story hook พอให้ผู้เล่นเข้าใจว่าทำไมต้องสู้
- มี replay variation มากกว่าแค่ตัวเลขบอสสูงขึ้น
- ไม่มี crash / hard error ระหว่างเล่น 10 รอบติด
- มี save/load ขั้นต่ำถ้าจะให้รางวัลถาวร
- มี privacy policy และ Play Store asset ขั้นต่ำ
```

ถ้ายังไม่ผ่าน ให้กลับไปแก้ Phase A-H ก่อน

---

## 10. สรุปทิศทางสุดท้าย

แนวทางที่เหมาะกับ Last Blade Trial ตอนนี้คือ:

```text
เล็ก → คม → อ่านง่าย → มีอารมณ์ → เล่นซ้ำสั้น ๆ ได้ → ค่อยเพิ่ม content → ค่อยทำเงิน
```

ไม่ใช่:

```text
ใหญ่ → ระบบเยอะ → บอสหลายตัวเร็วเกินไป → asset บาน → balance พัง → ทำไม่จบ
```

เป้าหมายระยะสั้นที่สุด:

```text
ทำ Boss 1 ให้เป็นดวลบอส 1 ตัวที่ผู้เล่นอยาก retry
```

เป้าหมายระยะกลาง:

```text
ทำ One Boss, Many Trials ที่มี story hook, memory upgrade, asset readability และ Android build
```

เป้าหมายระยะยาว:

```text
เพิ่ม Boss ใหม่, arena ใหม่, progression ลึกขึ้น และ rewarded monetization แบบสมัครใจ
```

ประโยคกำกับโปรเจกต์:

```text
บอสตัวเดียวคือจุดเริ่มต้น ไม่ใช่จุดจบ
ดาบไร้นามต้องเริ่มจากการทำให้การดวลหนึ่งครั้งมีความหมายก่อน
```
