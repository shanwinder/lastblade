# แผนพัฒนาต่อยอด Last Blade Trial / ดาบไร้นาม สู่ Play Store

วันที่สร้าง: 2026-07-04  
Repo: `shanwinder/lastblade`  
โฟลเดอร์เกม: `last-blade-trial`  
เป้าหมาย: เกมดวลดาบ 2D Mobile Boss Duel ที่ทุนต่ำ แต่คุณภาพพอสำหรับ Android / Google Play Store

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

สถานะโดยรวมตอนนี้จึงไม่ใช่แค่ prototype ต้นทางแล้ว แต่เป็น:

```text
Early Vertical Slice Candidate
```

แต่ยังไม่ใช่เวอร์ชันทดสอบขายหรือ Play Store เพราะยังขาดความนิ่ง ความเข้าใจง่าย และความเป็นผลิตภัณฑ์

---

## 2. หลักคิดใหม่หลังมี sprite จริงแล้ว

### 2.1 อย่าขยายเกมกว้าง ให้ขัดเกมให้คม

เป้าหมายสูงสุดไม่ใช่ทำเกมใหญ่ แต่คือ:

```text
ทำเกมดวลบอส 1 ตัวให้สนุกพอที่ผู้เล่นอยากกดเล่นซ้ำ
```

ดังนั้นก่อนเพิ่ม Boss 2 หรือระบบเยอะ ๆ ให้ยึดกฎนี้:

```text
Boss 1 ต้องสนุกก่อน
Touch controls ต้องไม่ขัดมือ
Animation ต้องอ่านง่ายก่อนสวย
Restart / Upgrade / Result ต้องลื่น
```

### 2.2 Asset จริงตอนนี้ถือเป็น working art ไม่ใช่ final art

sprite ที่มีตอนนี้ถือว่าเพียงพอสำหรับ production direction ระยะแรก แม้ยังไม่เนี๊ยบ เพราะช่วยให้:

```text
- เห็น silhouette จริง
- ทดสอบขนาดตัวละครบนมือถือได้
- เห็นว่า animation ใดอ่านยาก
- รู้ว่าควรแก้ prompt / sprite generation รอบถัดไปอย่างไร
```

หลักการคือ:

```text
เอา sprite เข้าเกมก่อน → ทดสอบ readability → จดปัญหา → generate/ปรับรุ่นใหม่ → แทนที่ทีละชุด
```

ไม่ควรรอ asset สวยครบก่อนทำ gameplay ต่อ

---

## 3. สิ่งที่ยังไม่ควรทำตอนนี้

ยังไม่ควรเร่งทำ:

```text
- Boss 2
- ระบบโฆษณาจริง
- In-app purchase
- Daily reward
- Online leaderboard
- ระบบเครื่องรางเยอะ
- เนื้อเรื่องยาว
- Cutscene
- Cloud save
- ระบบร้านค้าเต็มรูปแบบ
```

เหตุผลคือสิ่งเหล่านี้เพิ่มภาระ แต่ยังไม่ช่วยตอบคำถามหลักว่า:

```text
ผู้เล่นสนุกกับการดวล Boss 1 หรือยัง?
```

---

## 4. Roadmap ต่อจากนี้แบบค่อยเป็นค่อยไป

## Phase A: Stabilize Current Vertical Slice Candidate

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
- ห้ามเพิ่มระบบใหม่
- ห้ามเพิ่ม Boss ใหม่
- ห้าม refactor ใหญ่โดยไม่จำเป็น
```

---

## Phase B: Player Action Readability

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

## Phase C: Boss 1 Visual Readability

เป้าหมาย: ทำให้ BossBrokenMaster อ่านท่าได้จากภาพ ไม่ใช่อ่านแต่ตัวหนังสือ

ลำดับ asset/animation ที่ควรทำ:

```text
1. Boss idle sprite จริง
2. Boss normal wind-up pose
3. Boss heavy wind-up pose
4. Boss delayed wait pose
5. Boss quick wind-up pose
6. Boss attack release pose
7. Boss posture broken pose
8. Boss hurt flash
9. Boss death pose
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
- Delayed Slash ไม่รู้สึกโกง
- Quick Slash เร็วแต่ไม่มั่ว
- ไม่ต้องพึ่งข้อความ hint 100%
```

---

## Phase D: Combat Feel Pass

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

## Phase E: Mobile Control Polish

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

## Phase F: Boss 1 Balance Lock

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

## Phase G: Vertical Slice Packaging

เป้าหมาย: ทำเกมเป็น package ที่ให้คนอื่นทดลองได้

โครงสร้างที่ควรมี:

```text
1. Start screen
2. Training / Duel 1 แบบสั้น
3. Boss 1
4. Victory / Defeated screen
5. Upgrade choice
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

## Phase H: Android Build Discipline

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

## Phase I: Soft Closed Test

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
```

Definition of Done:

```text
- ได้ feedback จริงอย่างน้อย 10 ประเด็น
- แยก bug / balance / readability / art ได้
- เลือกแก้เฉพาะ 5 จุดที่กระทบที่สุดก่อน
```

---

## Phase J: Monetization Readiness

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
```

Definition of Done:

```text
- ผู้เล่นไม่รู้สึกว่าโดนบังคับดู ads
- ads ช่วยเพิ่ม replay value ไม่ใช่ขัด flow
- ไม่มี ads ในระหว่าง combat
```

---

## Phase K: Play Store Preparation

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

## 5. ลำดับงานที่แนะนำทันทีหลังเอกสารนี้

ลำดับที่ควรทำก่อนที่สุด:

```text
1. Stabilize animation state ปัจจุบัน: idle / run / back ให้ไม่หันผิด ไม่ลอย ไม่สะดุด
2. เพิ่ม Player attack animation จริง 1 ท่าเข้าระบบ AnimatedSprite2D
3. เพิ่ม Player dash visual / dash pose
4. เพิ่ม Boss idle และ Boss wind-up pose อย่างน้อย normal/heavy
5. ทดสอบมือถือจริง 5 รอบติด
6. จูน Boss 1 จาก feedback ของตัวเองก่อน
7. ทำ APK test build รอบแรกที่มี sprite จริง
```

ยังไม่ควรข้ามไป:

```text
Boss 2
ads จริง
save/load ถาวร
Play Store listing
```

จนกว่า Boss 1 + mobile controls + visual readability จะนิ่ง

---

## 6. ตัวชี้วัดว่าพร้อมไป Play Store หรือยัง

เกมเริ่มพร้อมเข้าสู่ Play Store closed testing เมื่อผ่านเงื่อนไขนี้:

```text
- คนเล่นใหม่เข้าใจวิธีเล่นใน 1 นาที
- เล่นจบหนึ่ง loop ได้ใน 5-10 นาที
- Boss 1 แพ้แล้วอยากลองใหม่
- ปุ่มมือถือไม่ขัดมือ
- ภาพอ่านออกบนจอเล็ก
- ไม่มี crash / hard error ระหว่างเล่น 10 รอบติด
- มี save/load ขั้นต่ำถ้าจะให้รางวัลถาวร
- มี privacy policy และ Play Store asset ขั้นต่ำ
```

ถ้ายังไม่ผ่าน ให้กลับไปแก้ Phase A-F ก่อน

---

## 7. สรุปทิศทาง

แนวทางที่เหมาะกับ Last Blade Trial ตอนนี้คือ:

```text
เล็ก → เล่นซ้ำได้ → อ่านง่าย → feedback หนักแน่น → mobile friendly → ค่อยหารายได้
```

ไม่ใช่:

```text
ใหญ่ → ระบบเยอะ → asset เยอะ → ทำไม่จบ → ยังไม่สนุก
```

เป้าหมายระยะสั้นที่สุด:

```text
ทำ Boss 1 ให้เป็นดวลบอส 1 ตัวที่สนุกจริง
```

เป้าหมายระยะกลาง:

```text
ทำ vertical slice ที่มี Training / Duel 1 / Boss 1 / Upgrade / Restart loop / Android build
```

เป้าหมายระยะยาว:

```text
ส่ง Closed Testing บน Google Play แล้วค่อยเพิ่ม rewarded ads แบบสมัครใจ
```
