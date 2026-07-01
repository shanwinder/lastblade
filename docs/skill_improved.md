# skill.md
# Last Blade Trial / ดาบไร้นาม
## Production-Ready Image Generation Skill File for AI Art Tools

> เวอร์ชัน 2.1 Production-Ready สำหรับใช้เป็น **Skill / Instruction File / Art Direction Bible / Prompt Control File / Asset Production Bible**  
> สำหรับสั่ง AI สร้างภาพในเครื่องมือต่าง ๆ เช่น ChatGPT Image, Midjourney, Flux, Stable Diffusion, Leonardo, Firefly หรือ AI อื่น ๆ  
> เป้าหมายคือทำให้ภาพทุกชิ้นของเกม **Last Blade Trial / ดาบไร้นาม** มีทิศทางเดียวกัน อ่านง่าย เหมาะกับเกมมือถือ และนำไปต่อยอดใช้งานจริงใน Godot 4 ได้ง่ายขึ้น โดยเน้นการล็อก reference, การตรวจคุณภาพ sprite, และ workflow หลังสร้างภาพจาก AI

---

# 0) HOW TO USE THIS FILE

ใช้ไฟล์นี้เป็น “กติกาหลัก” ทุกครั้งที่สั่ง AI สร้างภาพให้เกม **Last Blade Trial / ดาบไร้นาม**

วิธีใช้ที่แนะนำ:

1. วางไฟล์นี้เป็น instruction / skill / project context ให้ AI
2. เลือก **Output Mode** ที่ต้องการ เช่น Concept, Sprite, VFX, UI, Marketing
3. ใช้ Prompt Template ที่ตรงกับงาน
4. ระบุ asset ที่ต้องการให้ชัด เช่น player idle sprite sheet, boss heavy slash wind-up, parry VFX, arena background
5. ตรวจด้วย Quality Checklist ก่อนนำไปใช้จริง

ภาษาที่แนะนำสำหรับ prompt:

- ใช้ภาษาอังกฤษสำหรับ prompt หลัก เพราะ AI สร้างภาพส่วนใหญ่มักเข้าใจคำอธิบายภาพภาษาอังกฤษได้แม่นกว่า
- คงชื่อไทยของเกมและตัวละครไว้ได้ เช่น **ดาบไร้นาม**, **อาจารย์ดาบผู้แตกสลาย**
- ถ้า AI สร้างตัวหนังสือในภาพผิด ให้หลีกเลี่ยงการใส่ text ในภาพ และนำข้อความไปใส่ภายหลังใน Godot หรือโปรแกรมกราฟิก

---


# 0.1) QUICK START / SHORT SKILL VERSION

ใช้ส่วนนี้เมื่อเครื่องมือ AI มีช่องใส่ instruction สั้น ๆ หรือเมื่อไม่ต้องการแนบไฟล์เต็มทุกครั้ง

```text
Generate art for Last Blade Trial / ดาบไร้นาม in Dark Anime Pixel Duel style: a 2D side-view dark anime pixel art mobile boss-duel game focused on readable combat, parry, dash, and dramatic sword timing. Every asset must prioritize mobile readability, strong silhouette, clean pixel clusters, clear gameplay color language, and consistency with the approved character references.

Player lock: The Nameless Blade is a slim, agile, calm unnamed swordsman in dark blue-black clothing with a cyan-accent katana and a small trailing cloth/scarf/coat element. Not chibi, not bulky, not cute, not generic ninja.

Boss lock: Boss Broken Master is a larger fallen sword master with broken mask, long pale hair, dark purple-black torn robes, old gold accents, corrupted violet aura, and a large broken sword. Not western knight armor, not demon-only monster, not visually noisy.

Arena lock: Moonlit Broken Dojo is a side-view ruined dojo duel stage with broken torii, cracked stone floor, low fog, embers, pale moonlight, and a clean center combat lane.

Gameplay color rules: cyan/white = player, parry, dash, precision; gold/yellow = parryable boss slash or posture opening; crimson/magenta/dark purple = heavy danger attack that should be dashed; background must be darker and lower saturation than characters.

Avoid: cute, chibi, cheerful fantasy, bright pastel, blurry painterly texture, photorealism, low contrast, clutter, inconsistent frames, changing costume, changing weapon, cropped sword, uneven baseline, messy VFX, unreadable silhouettes, text, watermark, logo, signature.
```

## 0.2) WHEN TO USE FULL FILE VS SHORT VERSION

ใช้ไฟล์เต็มนี้เมื่อ:

- ต้องออกแบบ asset ใหม่ที่สำคัญ เช่น player, boss, arena, HUD, VFX
- ต้องตรวจคุณภาพภาพก่อนนำเข้า Godot 4
- ต้องทำ sprite sheet หรือ animation ที่ต้องคุม baseline / pivot / canvas
- ต้องสร้าง prompt หลายชุดให้คงตัวละครเดิม

ใช้ Quick Start เมื่อ:

- ต้องการสร้างภาพ concept เร็ว ๆ
- ต้องใส่ instruction ในเครื่องมือที่จำกัดจำนวนตัวอักษร
- ต้องใช้เป็น negative / style lock สั้น ๆ ก่อนแนบ prompt เฉพาะ asset

---

# 1) PROJECT IDENTITY

## Project Name

**Last Blade Trial / ดาบไร้นาม**

## Genre

- 2D Mobile Action
- Souls-lite
- Boss Rush
- Duel-focused Combat
- Short-session Combat Game
- Android-first / Mobile-first

## Core Fantasy

ผู้เล่นคือ **นักดาบนิรนาม** ที่ต้องดวลกับบอสผู้ทรงพลังในลานประลองอันหม่นมืด  
เกมเน้นการอ่านจังหวะบอส การตัดสินใจในเสี้ยววินาที การ Parry การ Dash และความรู้สึกกดดันแบบ Boss Duel

## Main Art Direction

**Dark Anime Pixel Duel**

นิยามสั้น:

- 2D side-view pixel art
- dark anime action mood
- boss duel tension
- dramatic but readable
- stylish, moody, cool
- strong silhouette
- mobile readability first
- clean combat plane
- not cute, not chibi, not bright fantasy

## One-Sentence Identity

**A dark anime pixel-art sword duel game with memorable bosses, readable combat, and a lonely moonlit atmosphere.**

---

# 2) HIGH-LEVEL VISUAL GOALS

ภาพทุกชิ้นต้องทำให้ผู้เล่นรู้สึกว่า:

- เกมนี้เท่
- เกมนี้น่าเล่น
- เกมนี้มีบอสที่น่าจดจำ
- เกมนี้อ่านการต่อสู้ได้ชัด
- เกมนี้เป็นอนิเมะดาร์กพิกเซลอาร์ต
- เกมนี้เหมาะกับมือถือ ไม่รก ไม่เบลอ ไม่มองยาก

## Priority Order

เรียงลำดับความสำคัญเสมอ:

1. **Readability** — อ่านรูปทรงและท่าทางออกทันที
2. **Strong Silhouette** — เงาตัวละครต้องจำได้แม้ย่อเล็ก
3. **Gameplay Clarity** — สีและท่าทางต้องช่วยบอกผู้เล่นว่าควรทำอะไร
4. **Mood / Atmosphere** — หม่น เท่ กดดัน มี tension
5. **Style Consistency** — ตัวละคร สี และอาวุธต้องไม่เปลี่ยนทุกครั้ง
6. **Detail** — รายละเอียดต้องไม่ทำให้รก

ถ้าต้องเลือกระหว่าง:

- สวยมากแต่รก
- คม ชัด อ่านง่าย

ให้เลือก **คม ชัด อ่านง่าย** เสมอ

---

# 3) CORE STYLE RULES

## 3.1 Style Keywords

ใช้คำเหล่านี้ซ้ำอย่างสม่ำเสมอใน prompt:

- dark anime pixel art
- 2D side-view game art
- boss duel
- dramatic lighting
- sharp silhouette
- moody atmosphere
- readable combat pose
- clean pixel clusters
- limited but impactful animation
- mobile game readability
- elegant sword combat
- mysterious ruins
- moonlit broken dojo
- cool and memorable

## 3.2 The Style Must Feel Like

ภาพต้องให้ความรู้สึก:

- เท่
- หม่น
- คม
- นิ่งแต่กดดัน
- มี tension
- มีอารมณ์ดวลดาบ
- เป็น action anime แบบดาร์ก
- มีความลึกลับและโดดเดี่ยว
- ไม่แฟนตาซีหวาน
- ไม่การ์ตูนน่ารัก

## 3.3 The Style Must Not Become

หลีกเลี่ยงแนวทางเหล่านี้:

- cute pixel RPG
- chibi proportions
- bright cheerful fantasy
- soft pastel anime
- comedic cartoon style
- super deformed body
- generic medieval western RPG
- overly realistic painting
- painterly texture
- airbrush shading
- blurry pseudo-pixel art
- cluttered scene with too much detail
- unreadable sprite silhouettes
- low contrast character blending into background
- excessive VFX hiding the action

---

# 4) PIXEL ART RULES

## 4.1 Pixel Art Principle

ภาพต้องดูเป็น **pixel art จริง**  
ไม่ใช่ภาพวาดธรรมดาที่แค่ใส่ filter ให้คล้ายพิกเซล

## 4.2 Pixel Art Characteristics

ต้องมีลักษณะดังนี้:

- clean pixel clusters
- readable forms
- minimal but deliberate shading
- controlled palette
- clear outlines or value separation
- strong pose language
- hard-edged pixel feel
- no blurry painterly texture
- no soft airbrush rendering
- no photorealism

## 4.3 Anti-Blur Rule

เวลา prompt สำหรับ asset เกม ให้เพิ่มคำเหล่านี้เมื่อเหมาะสม:

- pixel-perfect look
- crisp pixel edges
- no blur
- no painterly texture
- no anti-aliased soft edges
- clean limited palette
- readable at small size

หมายเหตุ: AI บางตัวอาจยังสร้างขอบเบลออยู่ ต้องนำไปปรับภายหลังด้วยโปรแกรม pixel art ได้

## 4.4 Camera Orientation

Primary in-game art ต้องคิดจากมุมกล้องนี้:

- 2D side view
- left/right facing combat
- duel stage framing
- clear combat lane
- player and boss visible from side
- readable wind-up pose

---

# 5) TECHNICAL ART STANDARD FOR GODOT 4

ส่วนนี้ใช้สำหรับ asset ที่จะนำเข้าเกมจริง ไม่ใช่แค่ concept art

## 5.1 Recommended Sprite Scale

| Asset Type | Recommended Canvas | Character Height / Safe Area | Notes |
|---|---:|---:|---|
| Player idle / parry | 64x64 px | 48–56 px | เหมาะกับตัวละครหลัก ถ้าสูงกว่า 56 px ให้ใช้ canvas ใหญ่ขึ้น |
| Player attack / dash | 96x64 px | 48–56 px | เผื่อพื้นที่ดาบและ cyan trail ด้านหน้า/ด้านหลัง |
| Player large action | 96x96 px | 56–72 px | ใช้เมื่ออยากให้ผู้เล่นสูงขึ้นหรือมีท่ากระโดด/ฟันกว้าง |
| Boss idle | 128x128 px | 88–110 px | บอสต้องใหญ่กว่าผู้เล่น แต่ไม่ควรชนขอบบน |
| Boss attack | 160x128 px | 88–110 px | เผื่อดาบใหญ่ wind-up และ VFX cue โดยไม่ crop ดาบ |
| Boss large cinematic pose | 192x128 px | 88–120 px | ใช้เฉพาะท่าใหญ่ เช่น posture break / finisher setup |
| Small VFX | 64x64 px | - | spark, hit flash, small parry cue |
| Medium VFX | 96x96 px | - | slash, dash trail, warning cue |
| Large VFX | 128x128 px | - | posture break, finisher, ground impact |
| UI icons | 16x16 / 24x24 / 32x32 px | - | ทำเป็น base pixel size แล้ว scale ในเกม |
| Touch buttons | 96x96 / 128x128 px | - | รองรับจอมือถือ |

ข้อควรจำ: ถ้า character height สูงกว่า canvas มากเกินไป AI มัก crop ผม ดาบ หรือเอฟเฟกต์ออกนอกกรอบ ให้เพิ่ม canvas ก่อน ไม่ใช่บังคับให้ตัวละครยัดลง canvas เล็กเกินไป

## 5.2 Sprite Sheet Rules

สำหรับ sprite ที่ใช้จริง:

- ใช้พื้นหลังโปร่งใสถ้าเครื่องมือรองรับ
- ถ้าโปร่งใสไม่ได้ ให้ใช้พื้นหลังสีเรียบที่ตัดออกง่าย เช่น pure green หรือ pure magenta
- ตัวละครควรหันขวาเป็น default
- เท้าตัวละครต้องอยู่ baseline เดียวกันทุก frame
- pivot / origin ควรอยู่ที่ bottom center
- อย่าเปลี่ยนขนาดตัวละครระหว่าง animation เว้นแต่เป็นเอฟเฟกต์ตั้งใจ
- หลีกเลี่ยงเงาพื้นที่ bake ติดมากับ sprite ถ้าจะใช้ shadow ใน Godot แยกต่างหาก
- อย่าให้ดาบหรือผ้าหลุดออกนอก canvas

## 5.3 Suggested Animation Specs

| Animation | Frames | FPS | Priority | Notes |
|---|---:|---:|---|---|
| Player idle | 4–6 | 6–8 | High | ขยับน้อย สุขุม |
| Player run | 6–8 | 10–12 | Medium | อ่านทิศทางชัด |
| Player attack | 5–7 | 12–14 | High | ดาบต้องอ่านออก |
| Player dash | 4–5 | 12–16 | High | cyan trail ชัดแต่ไม่บัง |
| Player parry | 4–6 | 12–14 | High | pose ต้องแข็งแรงและแม่น |
| Player hurt | 3–5 | 8–10 | Medium | กระตุกสั้น อ่านง่าย |
| Player death | 6–10 | 8–10 | Low | ใช้ภายหลังได้ |
| Boss idle | 4–6 | 5–8 | High | หนัก นิ่ง น่ากลัว |
| Boss normal slash wind-up | 5–7 | 8–10 | High | ต้องสื่อว่า parry ได้ |
| Boss heavy slash wind-up | 6–8 | 8–10 | High | ต้องสื่อว่า dash |
| Boss delayed slash | 6–8 | 6–8 | High | มีช่วงค้างหลอกจังหวะ |
| Boss quick slash | 4–6 | 12–16 | Medium | ท่าต่ำและพุ่งไว |
| Boss stagger | 4–6 | 8–10 | Medium | อ่านว่าโดนเปิดช่อง |
| Boss posture break | 6–10 | 8–12 | Medium | gold/white burst |

## 5.4 Godot 4 Import Rules

เมื่อเอา pixel art เข้า Godot 4 แนะนำตั้งค่าประมาณนี้:

- Texture Filter: Nearest / Off
- Mipmaps: Off
- Repeat: Disabled
- Compression: Lossless หรือโหมดที่ไม่ทำให้ภาพแตกผิดปกติ
- Scaling: ใช้ integer scale ถ้าเป็นไปได้
- Avoid non-uniform scaling
- ตรวจใน Android preview ทุกครั้ง

## 5.5 Naming Convention

ใช้ชื่อไฟล์แบบอ่านง่ายและไม่ปนภาษาไทยใน path หลัก เพื่อเลี่ยงปัญหาเครื่องมือบางตัว

ตัวอย่าง:

```text
assets/art/player/player_idle_64x64.png
assets/art/player/player_attack_96x64.png
assets/art/player/player_dash_96x64.png
assets/art/player/player_parry_64x64.png
assets/art/boss/broken_master_idle_128x128.png
assets/art/boss/broken_master_heavy_windup_160x128.png
assets/art/vfx/vfx_parry_spark_64x64.png
assets/art/vfx/vfx_dash_trail_96x96.png
assets/art/ui/button_attack_128.png
assets/art/ui/button_dash_96.png
assets/art/ui/button_parry_96.png
assets/art/background/moonlit_broken_dojo_layer_sky.png
assets/art/background/moonlit_broken_dojo_layer_ruins.png
assets/art/background/moonlit_broken_dojo_layer_ground.png
```

---


## 5.6 Godot 4 Import Checklist แบบละเอียดสำหรับมือใหม่

ใช้ขั้นตอนนี้ทุกครั้งหลังนำ PNG เข้า Godot 4 เพื่อให้ pixel art คม ไม่เบลอ และไม่เกิด scaling เพี้ยน

1. เปิด Godot 4 แล้วไปที่แถบ **FileSystem**
2. คลิกเลือกไฟล์ `.png` ที่ต้องการนำเข้าเกม
3. ไปที่แถบ **Import** ด้านบนซ้าย/ขวา แล้วตรวจค่าดังนี้
4. ตั้งค่า **Filter / Texture Filter** เป็น `Nearest` หรือ `Off`
5. ปิด **Mipmaps**
6. ตั้ง **Repeat** เป็น `Disabled`
7. ตั้ง **Compression** เป็น `Lossless` หรือค่าที่ไม่ทำให้ภาพเสียรายละเอียด
8. กด **Reimport**
9. นำ sprite ไปใส่ใน `Sprite2D` หรือ `AnimatedSprite2D`
10. ทดสอบดูที่ scale จริงบนหน้าจอมือถือหรือ Android preview
11. หลีกเลี่ยงการ scale แบบทศนิยม เช่น `1.3x`, `2.7x`
12. ถ้าต้องขยาย ให้ใช้ integer scale เช่น `2x`, `3x`, `4x` เมื่อเป็นไปได้

## 5.7 Sprite Sheet Reality Warning

AI-generated sprite sheet ให้ถือว่าเป็น **visual draft** ไม่ใช่ final production asset ทันที

ปัญหาที่พบบ่อย:

- แต่ละ frame ตัวละครเปลี่ยนชุดหรือเปลี่ยนสัดส่วน
- ดาบยาวไม่เท่ากัน
- baseline เท้าไม่ตรงกัน
- canvas แต่ละช่องไม่เท่ากัน
- มีพื้นหลังปลอมที่ไม่โปร่งใสจริง
- มี stray pixels หรือ noise จำนวนมาก
- animation ดูดีเป็นภาพนิ่ง แต่ตัดเข้า Godot แล้วกระตุก

กฎการใช้งาน:

1. ใช้ AI เพื่อหา pose, silhouette, mood และ timing idea
2. เลือก frame ที่ดีที่สุด
3. นำไป clean ใน Aseprite, Krita, Photoshop, Piskel หรือ pixel editor อื่น
4. ตรวจ baseline, pivot, silhouette, sword length และ transparency ก่อนนำเข้า Godot
5. อย่านำ sprite sheet ที่ยังไม่ clean เข้าเกมจริงโดยตรง

## 5.8 Post-Generation Cleanup Workflow

หลัง AI สร้างภาพ ให้ทำความสะอาดตามลำดับนี้

1. Remove background หรือแยกพื้นหลังออกให้โปร่งใส
2. Crop แต่ละ frame ให้ตรง canvas ที่กำหนด เช่น 64x64, 96x64, 160x128
3. Align เท้าทุก frame ให้อยู่ baseline เดียวกัน
4. ตั้ง pivot logic เป็น bottom center
5. ลด color noise และลบ pixel แปลก ๆ รอบตัวละคร
6. เช็กว่าดาบไม่เปลี่ยนรูปทรงระหว่าง frame
7. เช็กว่า silhouette ยังอ่านออกเมื่อย่อ 50%
8. เช็กว่า VFX ไม่บังหน้า ตัว ดาบ หรือท่าบอส
9. Export เป็น PNG transparency
10. Import เข้า Godot ด้วย Nearest / No Mipmaps / Lossless
11. ทดสอบบน scene จริง ไม่ใช่ดูภาพเดี่ยวเท่านั้น

## 5.9 Asset Folder Recommendation for Current Project

แนะนำจัดโฟลเดอร์ใน Godot แบบนี้เพื่อไม่สับสนภายหลัง

```text
last-blade-trial/
  assets/
    art/
      player/
        canonical_player_ref.png
        player_idle_64x64.png
        player_attack_96x64.png
        player_dash_96x64.png
        player_parry_64x64.png
      boss/
        canonical_broken_master_ref.png
        broken_master_idle_128x128.png
        broken_master_normal_windup_160x128.png
        broken_master_heavy_windup_160x128.png
        broken_master_delayed_windup_160x128.png
        broken_master_quick_slash_160x128.png
        broken_master_posture_break_160x128.png
      vfx/
        vfx_parry_spark_64x64.png
        vfx_heavy_warning_96x96.png
        vfx_dash_trail_96x64.png
        vfx_posture_break_128x128.png
      ui/
        button_attack_128.png
        button_dash_96.png
        button_parry_96.png
        tutorial_coach_box.png
      background/
        moonlit_broken_dojo_sky.png
        moonlit_broken_dojo_ruins.png
        moonlit_broken_dojo_ground.png
```

---

# 6) COLOR LANGUAGE

## 6.1 Global Palette Mood

โลกของเกมใช้โทนสีหลัก:

- dark navy
- midnight blue
- muted purple
- charcoal black
- stone gray
- burnt brown
- old gold
- pale moonlight
- ember orange

## 6.2 Suggested HEX Palette

ใช้เป็นแนวทาง ไม่จำเป็นต้องตรง 100% ทุกภาพ

| Role | Color Name | HEX Suggestion |
|---|---|---:|
| Deep Navy | Player dark base | `#07111F` |
| Black Blue | Player cloth | `#0B1C33` |
| Pale Cyan | Player accent / parry | `#66E6FF` |
| Cool White | Parry flash | `#EFFFFF` |
| Silver | Blade highlight | `#BFD4D8` |
| Dark Purple | Boss base | `#24142F` |
| Corrupted Violet | Boss aura | `#6E35A8` |
| Old Gold | Boss trim / posture | `#B88A3A` |
| Crimson | Danger / HP | `#B3263A` |
| Magenta Red | Heavy warning | `#D83A5C` |
| Charcoal | UI panel | `#101015` |
| Stone Gray | Arena floor | `#4B4E57` |
| Moonlight | Background highlight | `#CBD7E8` |
| Ember Orange | Ambient sparks | `#D9782D` |

## 6.3 Color Role Separation

สีต้องสื่อ gameplay role ให้ผู้เล่นเข้าใจง่าย

### Player

- deep blue
- black-blue
- pale cyan
- silver
- cool white

ความรู้สึก: agile, calm, precise, disciplined

### Boss

- dark purple
- old gold
- crimson accents
- broken white / gray hair
- corrupted violet glow

ความรู้สึก: tragic, corrupted, dominant, dangerous

### Parry

- bright cyan
- white flash
- slight gold spark allowed

ความหมาย: จังหวะป้องกันสำเร็จ / precision clash

### Heavy Attack / Danger

- crimson red
- magenta-red
- dark purple-red

ความหมาย: อันตรายสูง / ห้าม parry / ควร dash

### Focus / Finisher

- white-gold
- cyan-gold
- intense high-value contrast

ความหมาย: จุดพีคของการต่อสู้

### Background

- low saturation
- darker than gameplay subjects
- avoid competing with player and boss

---

# 7) SHAPE LANGUAGE

## 7.1 Player Shape Language

Player should feel:

- agile
- slim
- disciplined
- cool
- heroic but quiet
- sharp

Visual shape cues:

- narrow silhouette
- long sword line
- slight cloth movement
- scarf / short cloak / waist cloth
- clean stance
- clear forward-facing duel posture
- less mass than boss

## 7.2 Boss Shape Language

Boss should feel:

- heavy
- dangerous
- tragic
- dominant
- broken master
- corrupted authority

Visual shape cues:

- broader silhouette
- long hair or torn cloth
- oversized or broken sword
- asymmetry
- imposing stance
- noble but ruined presence
- more mass than player

## 7.3 Arena Shape Language

Arena should feel:

- sacred but ruined
- lonely
- ceremonial duel ground
- moonlit
- ancient
- haunted by history
- clean in the center, detailed at edges

---

# 8) PLAYER DESIGN SPEC

## Character Name

**The Nameless Blade / ดาบไร้นาม**

## Role

Main playable swordsman

## Personality

- silent
- focused
- wounded but determined
- fast and skillful
- anime-cool, but not childish
- calm under pressure

## Visual Summary

A lean unnamed swordsman in dark blue-black attire, carrying a katana with faint cyan glow, cloth elements trailing slightly, designed as a cool dark anime pixel hero.

## Key Features

- slim body
- black or deep navy outfit
- subtle cyan accent
- katana with cool cyan glow
- short cloak / haori / scarf / waist cloth
- readable sword stance
- hair dark or silver-black
- optional small glowing eye highlight

## Must-Have Recognition Points

1. cyan-accent sword
2. trailing cloth / scarf / coat flap
3. dark blue-black silhouette
4. clean duelist stance
5. agile body proportion

## Design Lock Rules

ห้ามเปลี่ยนสิ่งเหล่านี้แบบสุ่มระหว่าง asset:

- สีหลักต้องเป็น dark blue-black
- ดาบต้องมี cyan accent
- รูปร่างต้องเพรียวและว่องไว
- ต้องมี cloth element ที่ช่วยให้จำตัวละครได้
- ห้ามเปลี่ยนเป็นนักรบเกราะหนัก
- ห้ามเปลี่ยนเป็น chibi หรือตัวละครน่ารัก

## Recommended Sprite Set Priority

สร้างตามลำดับนี้:

1. idle
2. attack
3. dash
4. parry
5. hurt
6. run
7. death
8. finisher

## Player Prompt Keywords

- dark anime pixel swordsman
- agile duelist
- cool protagonist
- slim silhouette
- cyan sword glow
- side view combat sprite
- readable action pose
- mobile game readability
- clean pixel clusters

---

# 9) BOSS DESIGN SPEC

## Character Name

**Boss Broken Master / อาจารย์ดาบผู้แตกสลาย**

## Role

Main boss enemy

## Personality

- former sword master
- tragic
- corrupted
- intimidating
- calm but terrifying
- fallen legend
- noble but broken

## Visual Summary

A tall corrupted sword master with broken mask, long pale hair, dark purple-black robes, old gold accents, and a large broken sword. He must feel like a memorable anime boss in pixel art.

## Key Features

- taller and bulkier than player
- broken mask or cracked face covering
- long white / gray hair
- torn robe / cloak
- broken oversized sword
- violet / gold corruption aura
- strong duel posture
- noble but ruined presence

## Must-Have Recognition Points

1. broken mask
2. long pale hair
3. broken great blade
4. purple-gold aura
5. larger silhouette than player
6. torn dark robe

## Design Lock Rules

ห้ามเปลี่ยนสิ่งเหล่านี้แบบสุ่มระหว่าง asset:

- ต้องมี broken mask
- ต้องมี long pale hair
- ต้องถือ broken oversized sword
- ต้องใช้ dark purple-black + old gold accent
- ต้องใหญ่กว่าผู้เล่นชัดเจน
- ห้ามกลายเป็นอัศวินตะวันตกทั่วไป
- ห้ามใช้เกราะเยอะจนอ่าน silhouette ยาก

## Boss Attack Pose Language

ทุกท่าบอสต้องอ่านออกจาก pose ได้ แม้ยังไม่เห็น VFX

### Normal Slash

- sword at chest or ready position
- controlled motion
- gold/yellow cue
- says “parry me”
- pose should look fair and readable

### Heavy Slash

- large overhead or forceful wind-up
- red/purple danger buildup
- says “dash instead of parry”
- bigger anticipation pose
- more weight and danger

### Delayed Slash

- unnaturally still pause
- deceptive hold
- purple waiting tension then gold release
- body feels locked in a disturbing calm

### Quick Slash

- compressed low stance
- fast forward energy
- minimal startup
- says “react fast”
- smaller cue but still readable

## Recommended Sprite Set Priority

1. idle
2. normal slash wind-up
3. heavy slash wind-up
4. delayed slash pose
5. quick slash pose
6. hit / stagger
7. posture break
8. death

## Boss Prompt Keywords

- fallen sword master pixel art
- dark anime boss
- broken mask
- long pale hair
- corrupted purple aura
- broken giant sword
- readable boss attack pose
- side view combat sprite
- tragic anime boss
- mobile readability

---

# 10) BOSS TELEGRAPH VISUAL RULES

ใช้ส่วนนี้เชื่อมภาพกับ gameplay โดยตรง

| Boss Action | Visual Cue | Main Color | Player Response | Pose Language |
|---|---|---|---|---|
| Normal Slash | ดาบตั้งพร้อมฟัน | Gold / Yellow | Parry | ควบคุมได้ อ่านง่าย |
| Heavy Slash | ยกดาบสูง สะสมแรง | Crimson / Purple | Dash | ใหญ่ หนัก อันตราย |
| Delayed Slash | นิ่งค้างผิดธรรมชาติ | Purple hold → Gold release | Wait then Parry | หลอกจังหวะ |
| Quick Slash | ย่อตัวต่ำ พุ่งสั้น | Small white/cyan or gold cue | Fast reaction | เร็ว กระชับ |
| Posture Break | บอสเสียสมดุล | Gold / White burst | Attack / Finisher | เปิดช่องชัดเจน |

กฎสำคัญ:

- สีแดง/ม่วงต้องไม่ใช้กับท่าที่ควร parry แบบปกติ เพราะจะทำให้ผู้เล่นสับสน
- สี cyan/white ควรเกี่ยวกับผู้เล่น, parry, dash หรือ focus เป็นหลัก
- ท่า heavy ต้องแตกต่างจาก normal ด้วย silhouette ไม่ใช่แค่สี
- ท่า delayed ต้องมีช่วง “นิ่งผิดธรรมชาติ” ให้ผู้เล่นรู้สึกถูกหลอกจังหวะ

---

# 11) ARENA DESIGN SPEC

## Arena Name

**Moonlit Broken Dojo / ลานดวลดาบใต้จันทร์แตก**

## Role

Primary duel arena

## Narrative Feel

This was once a sacred training ground or dojo. It is now ruined, abandoned, and haunted by the memory of past duels.

## Visual Summary

A side-view pixel art duel arena at night with a broken dojo, moonlit sky, shattered stone floor, torii gate remains, low fog, embers, and a clean combat plane.

## Core Background Elements

- large moon or broken moon
- ruined dojo architecture
- broken torii gate
- stone duel floor
- cracked tiles / rock
- low mist
- embers or drifting ash
- occasional swords stuck in the ground
- distant mountain / shrine silhouette

## Composition Rules

- gameplay plane must be clean
- center combat area must not be cluttered
- heavy detail should stay in background or edges
- contrast must keep player and boss readable
- avoid foreground objects that hide feet, hitboxes, or boss wind-up

## Arena Layers

### Layer 1: Sky

- dark blue / purple night sky
- moon
- faint cloud band

### Layer 2: Distant Background

- ruined structures
- mountains / treeline
- dojo silhouette
- torii silhouette

### Layer 3: Combat Ground

- cracked stone
- subtle texture
- flat readable plane
- a few cracks, not too noisy
- enough contrast with player feet

### Layer 4: Ambient FX

- fog
- drifting embers
- leaf particles
- ash particles
- atmosphere only, not visual clutter

## Arena Prompt Keywords

- dark anime pixel art arena
- side-view duel stage
- moonlit ruined dojo
- broken torii gate
- low fog
- cracked stone floor
- clean combat readability
- moody atmosphere
- mobile game background

---

# 12) UI / HUD STYLE

## UI Direction

Dark anime pixel UI

## Characteristics

- dark semi-transparent panels
- muted gold borders
- readable pixel font
- not overly ornate
- mobile-friendly
- clean hierarchy
- high contrast text
- minimal decoration

## Color Logic

| UI Element | Color Direction |
|---|---|
| Player HP | Red / Crimson |
| Stamina | Teal / Green-Cyan |
| Focus | Cyan-Gold |
| Boss HP | Dark Red / Magenta |
| Boss Posture | Gold or Purple |
| Warning Text | Crimson / White |
| Tutorial Coach Box | Dark panel + gold border + white text |

## Mobile Button Style

สำหรับ Touch Controls:

- Attack button largest
- Dash medium
- Parry medium
- subtle transparency
- not too bright
- visible on dark background
- consistent pixel art visual
- button icons must be readable without text
- icon shape must differ clearly: sword / dash arrow / shield-parry spark

## Suggested Touch Button Sizes

| Button | Suggested Base Size | Visual Priority |
|---|---:|---|
| Attack | 128x128 px | Highest |
| Dash | 96x96 px | Medium |
| Parry | 96x96 px | Medium |
| Pause | 48x48 px | Low |
| Upgrade / Confirm | 96x96 px | Contextual |

## UI Prompt Keywords

- dark anime pixel UI
- mobile game touch button
- semi-transparent dark panel
- muted gold border
- readable pixel icon
- clean hierarchy
- not overly ornate
- suitable for action game HUD

---

# 13) VFX DIRECTION

## VFX Philosophy

Effects should be:

- readable
- impactful
- brief
- stylish
- pixel-based
- role-colored
- never obscure the action too much

## Core VFX Assets

1. slash effect
2. parry spark
3. dash trail
4. hit flash
5. heavy attack warning
6. posture break burst
7. focus finisher flash
8. boss corruption aura
9. ground impact crack
10. small ember / ash particle

## VFX Color Language

| VFX | Colors | Meaning |
|---|---|---|
| Slash | white + cyan | player attack / clean cut |
| Boss slash | gold / pale yellow | parryable boss attack |
| Parry spark | cyan + white + gold spark | perfect clash |
| Dash trail | cyan ghost trail | movement / invincibility feel |
| Hit flash | white / red depending target | damage feedback |
| Heavy warning | red + purple | danger / dash cue |
| Posture break | gold + white burst | opening |
| Finisher | cyan-gold + white impact | high power |

## VFX Technical Rules

- Prefer transparent background
- Keep effect readable at small size
- Do not cover the full character for too long
- Avoid huge decorative swirls
- Avoid messy particles that hide the boss wind-up
- Slash should have a clear arc direction
- Parry spark should feel precise and sharp
- Dash trail should be behind player, not in front of action

## VFX Prompt Keywords

- pixel slash arc
- parry impact spark
- anime action effect
- readable hit flash
- dark fantasy pixel VFX
- brief and impactful
- transparent background
- mobile readability

---

# 14) ASSET GENERATION PRIORITY

## Phase 1: Visual Identity Pack

ใช้ล็อกภาพรวมก่อนผลิต sprite จริง

1. Player concept
2. Boss concept
3. Arena concept
4. Player + Boss size comparison
5. Color palette sheet

## Phase 2: Core Gameplay Art Pack

ใช้กับ Vertical Slice และ Android test

1. Player idle
2. Player attack
3. Player dash
4. Player parry
5. Boss idle
6. Boss normal slash wind-up
7. Boss heavy slash wind-up
8. Boss delayed slash pose
9. Boss quick slash pose
10. Arena gameplay background
11. slash VFX
12. parry VFX
13. dash trail VFX
14. heavy warning VFX

## Phase 3: Support Pack

ใช้เพิ่ม polish หลังระบบหลักเล่นได้

1. hurt poses
2. death poses
3. UI buttons
4. HUD icons
5. focus / finisher effect
6. posture break burst
7. title screen
8. key art
9. promotional art
10. store capsule art

## Current Recommended Priority for Vertical Slice

ถ้าเกมมีระบบต่อสู้พื้นฐานแล้ว ให้ทำ asset ตามลำดับนี้:

1. Boss Broken Master idle + attack telegraph sprites
2. Player parry / dash / attack sprites
3. Parry spark + heavy warning VFX
4. Touch control buttons
5. Arena layered background
6. HUD polish
7. Title / marketing art

---

# 15) CONSISTENCY RULES

ทุกภาพต้องรักษาความสม่ำเสมอของ:

- player outfit
- player silhouette
- player color identity
- player cyan sword
- boss broken mask
- boss long pale hair
- boss robe shape
- boss broken sword shape
- arena mood and palette
- VFX language
- overall dark anime pixel style

## Consistency Priority

1. silhouette
2. color identity
3. weapon identity
4. pose readability
5. detail design

## Consistency Lock Prompt

ใช้ประโยคนี้เพิ่มใน prompt เมื่อต้องการให้ AI ไม่ redesign:

```text
Keep the character design consistent with the established Last Blade Trial reference: same silhouette, same outfit identity, same weapon shape, same color role, and no redesign.
```

## Character Reference Sheet Recommendation

ก่อนทำ sprite หลายท่า ควรสร้าง reference sheet ก่อน:

- front / side / back view ถ้าเป็น concept
- side-view gameplay pose เป็นหลัก
- color palette
- weapon close-up
- silhouette comparison
- player next to boss size comparison

---


## 15.1 Canonical Reference Workflow

ใช้ขั้นตอนนี้เพื่อป้องกันไม่ให้ AI redesign ตัวละครทุกครั้งที่สร้าง sprite ใหม่

1. สร้าง **Player Reference Sheet** ก่อน เช่น idle, side-view, weapon close-up, palette
2. เลือกภาพผู้เล่นที่ผ่านแล้ว 1 ภาพเป็น reference หลัก
3. บันทึกเป็น `canonical_player_ref.png`
4. สร้าง **Boss Broken Master Reference Sheet** เช่น idle, mask, hair, broken sword, robe shape
5. เลือกภาพบอสที่ผ่านแล้ว 1 ภาพเป็น reference หลัก
6. บันทึกเป็น `canonical_broken_master_ref.png`
7. ทุกครั้งที่สร้าง sprite ใหม่ ให้แนบ reference เดิมเสมอถ้าเครื่องมือรองรับ
8. ถ้าเครื่องมือมี seed ให้ล็อก seed ระหว่าง batch ที่ต้องการ consistency
9. ห้ามสร้าง player/boss sprite จาก text-only prompt หลัง design lock เว้นแต่ต้องการ redesign จริง
10. ถ้าภาพใหม่สวยแต่ไม่เหมือน canonical reference ให้ปฏิเสธหรือใช้เป็น concept แยก ไม่ใช้เป็น asset หลัก

## 15.2 Character Lock Acceptance Rules

### Player sprite ผ่านได้เมื่อ:

- ยังเป็นนักดาบรูปร่างเพรียว ไม่เป็นนักรบเกราะหนัก
- ชุดยังเป็น dark blue-black
- ดาบหรือ VFX ยังมี cyan accent
- มี cloth/scarf/coat element ที่ช่วยจำตัวละคร
- silhouette อ่านออกเมื่อย่อภาพ 50%
- ไม่ดู chibi, cute, comedic หรือ fantasy สดใส
- pose เหมาะกับ side-view combat

### Boss sprite ผ่านได้เมื่อ:

- เห็น broken mask หรือ cracked face covering ชัด
- เห็น long pale hair ชัด
- ถือ broken oversized sword แต่ดาบไม่โดน crop
- ชุดเป็น dark purple-black robe พร้อม old gold accent
- ตัวใหญ่กว่าผู้เล่นชัดเจน
- silhouette หนักและน่ากลัว แต่ไม่รกจนอ่านท่าไม่ออก
- ไม่กลายเป็น western knight, demon monster ทั่วไป หรือชุดเกราะเต็มตัว

## 15.3 Approved Asset Rule

เมื่อ asset ผ่านการเลือกแล้ว ให้ถือว่าเป็น **approved canonical asset** และใช้เป็นตัวอ้างอิงต่อไป

ตัวอย่างชื่อไฟล์:

```text
canonical_player_ref.png
canonical_broken_master_ref.png
approved_player_idle_64x64_v01.png
approved_boss_heavy_windup_160x128_v01.png
approved_arena_moonlit_broken_dojo_v01.png
```

อย่าใช้ชื่อไฟล์ว่า `final_final_new_2.png` เพราะจะทำให้สับสนเมื่อโปรเจกต์ใหญ่ขึ้น

---

# 16) OUTPUT MODES

เลือก mode ให้ตรงกับงาน

## Mode A: Concept Mode

ใช้สำหรับ:

- key visual
- character concept
- moodboard
- scene concept
- title art

Focus:

- style lock
- mood
- identity
- visual direction
- emotional appeal

## Mode B: Sprite Mode

ใช้สำหรับ:

- player sprite
- boss sprite
- pose sheet
- animation frame concept
- VFX
- UI icons

Focus:

- readability
- consistency
- clean pixel art
- side-view compatibility
- in-game usability
- transparent background if possible

## Mode C: Gameplay Background Mode

ใช้สำหรับ:

- arena background
- layered background
- parallax layers
- combat ground

Focus:

- clean center combat plane
- low visual noise
- mood
- depth
- mobile readability

## Mode D: UI Mode

ใช้สำหรับ:

- HUD
- buttons
- icons
- tutorial box
- upgrade screen

Focus:

- readable text area
- dark transparent panels
- simple icon language
- touch-friendly size
- consistent pixel UI

## Mode E: Marketing Mode

ใช้สำหรับ:

- capsule art
- promotional art
- screenshot framing
- store visuals
- poster

Focus:

- strong appeal
- clear hero/boss identity
- emotional impact
- game branding
- dramatic composition

---

# 17) PROMPT TEMPLATE SYSTEM

## 17.1 Universal Prompt Template

```text
[Asset Type], for the game Last Blade Trial / ดาบไร้นาม, in dark anime pixel art style, 2D side-view, mobile game readability, strong silhouette, moody dramatic lighting, clean pixel clusters, readable combat pose, consistent with a dark boss-duel game, [subject description], [pose/action], [palette notes], [usage notes]. Avoid cute, chibi, bright cheerful fantasy, blurry painterly texture, low contrast, cluttered details, and unreadable silhouettes.
```

## 17.2 Player Concept Template

```text
Create a 2D pixel art character concept for The Nameless Blade / ดาบไร้นาม from the game Last Blade Trial. Style: dark anime pixel art, cool protagonist, side-view compatible, strong silhouette, mobile readability, clean pixel clusters.

Design him as a lean unnamed swordsman wearing dark blue-black clothing, with subtle cyan accents, a katana with faint cyan glow, and slight cloth movement such as a scarf, short cloak, or waist cloth. He should feel quiet, skilled, determined, lonely, and stylish, not cute or comedic.

Keep the design clean, readable, memorable, and suitable for a mobile boss-duel game. Avoid chibi proportions, bright fantasy colors, painterly blur, and excessive detail.
```

## 17.3 Boss Concept Template

```text
Create a 2D pixel art boss character concept for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from the game Last Blade Trial. Style: dark anime pixel art, side-view combat readability, strong silhouette, boss duel atmosphere, clean pixel clusters.

Design him as a fallen sword master with a broken mask, long pale hair, dark purple-black torn robes, old gold accents, and a large broken sword. He should feel intimidating, tragic, noble, corrupted, calm, and terrifying, with a subtle purple-gold aura.

Make him clearly larger, heavier, and more dominant than the player. Avoid generic western knight armor, cute style, messy detail, and unreadable silhouette.
```

## 17.4 Arena Template

```text
Create a 2D pixel art side-view arena background for the game Last Blade Trial / ดาบไร้นาม. Style: dark anime pixel art, boss duel stage, mobile readability, moody atmosphere, clean combat plane.

The arena is a moonlit broken dojo with a ruined torii gate, cracked stone duel floor, low fog, embers drifting, distant shrine silhouettes, and a large moon in the background.

Keep the center combat area clean and readable, with heavier details placed in the background and edges. The background should be darker and lower saturation than the characters. Avoid clutter, bright cheerful colors, and foreground objects that hide the combat.
```

## 17.5 Sprite Pose Template

```text
Create a 2D side-view pixel art sprite for [character name] from Last Blade Trial / ดาบไร้นาม.

Pose: [idle / attack / dash / parry / heavy slash wind-up / delayed slash / quick slash].

Style: dark anime pixel art, clean silhouette, readable action pose, mobile readability, clean pixel clusters, limited but expressive animation-ready design.

Technical requirements: transparent background if possible, side-view facing right, consistent baseline, bottom-center pivot logic, readable at small mobile size, no painterly blur, no soft anti-aliased look, no excessive detail.

Keep the character consistent with previous designs: same silhouette, same outfit identity, same weapon shape, same color role, and no redesign.
```

## 17.6 Sprite Sheet Template

```text
Create a sprite sheet for [character name] from Last Blade Trial / ดาบไร้นาม.

Animation: [animation name]
Frame count: [number] frames
Canvas per frame: [width]x[height] pixels
Direction: 2D side-view, facing right
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline
Style: dark anime pixel art, clean pixel clusters, strong silhouette, mobile readability, readable combat pose.

The animation should be limited but expressive, suitable for Godot 4. Keep the design consistent across all frames. Avoid blurry rendering, painterly texture, chibi proportions, excessive particles, and inconsistent costume redesign.
```

## 17.7 VFX Template

```text
Create a pixel art combat VFX asset for Last Blade Trial / ดาบไร้นาม.

Effect type: [slash / parry spark / dash trail / heavy warning / posture break / finisher]
Style: dark anime pixel art, anime action combat effect, clean readable pixels, strong contrast, brief and impactful, suitable for a 2D boss-duel mobile game.
Color palette: [insert colors]
Technical requirements: transparent background if possible, readable at small size, not too large, does not obscure the character or boss wind-up.

Avoid messy particles, painterly blur, soft glow overload, huge decorative effects, and low gameplay readability.
```

## 17.8 UI Template

```text
Create a dark anime pixel UI asset for Last Blade Trial / ดาบไร้นาม.

UI asset type: [attack button / dash button / parry button / HP bar / stamina bar / focus bar / tutorial box / upgrade panel]
Style: dark anime pixel UI, semi-transparent dark panel, muted gold border, readable pixel icon, mobile-friendly, clean hierarchy.

The design should be simple, readable, and suitable for a 2D mobile action boss-duel game. Avoid overly ornate decoration, tiny unreadable details, bright toy-like colors, and soft modern glossy UI.
```

## 17.9 Marketing Art Template

```text
Create promotional key art for Last Blade Trial / ดาบไร้นาม, a dark anime pixel-art mobile boss-duel game.

Show The Nameless Blade facing Boss Broken Master in a moonlit broken dojo, with a large moon, ruined torii gate, cracked stone floor, low fog, and dramatic sword-duel tension.

Style: dark anime pixel art, cinematic composition, strong silhouettes, moody dramatic lighting, cool and memorable, readable hero and boss identities.

Player color identity: dark blue-black with cyan sword accent.
Boss color identity: dark purple-black robes, old gold accents, broken mask, long pale hair, broken giant sword, purple-gold aura.

Avoid cute style, chibi, cheerful fantasy, painterly realism, clutter, and unreadable silhouettes. Do not include text unless specifically requested.
```

---

# 18) READY-TO-USE PRODUCTION PROMPTS

## 18.1 Player Idle Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Animation: idle
Frame count: 6 frames
Canvas per frame: 64x64 pixels
Direction: facing right
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, strong silhouette, mobile readability, subtle breathing animation, calm duelist stance.

Character design: lean unnamed swordsman wearing dark blue-black clothing, subtle cyan accents, faint cyan katana glow, short scarf or cloak cloth movement. He should feel quiet, focused, skilled, and cool.

Avoid chibi style, cute proportions, bright fantasy palette, painterly blur, excessive detail, and inconsistent outfit redesign.
```

## 18.2 Player Attack Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Animation: quick katana attack
Frame count: 6 frames
Canvas per frame: 96x64 pixels
Direction: facing right
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable action pose, mobile readability, elegant sword combat.

The attack should show a sharp cyan-white slash arc, but the VFX must not hide the body pose. Keep the character slim, dark blue-black, with subtle cyan accents and a faint cyan katana glow.

Avoid huge messy effects, blurry painterly rendering, chibi proportions, and redesigning the character.
```

## 18.3 Player Dash Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Animation: dash
Frame count: 5 frames
Canvas per frame: 96x64 pixels
Direction: facing right
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, mobile readability, agile motion, sharp silhouette.

Show a fast low dash with a short cyan ghost trail behind the player. The trail should be readable but not too large. Keep the dark blue-black outfit, cyan sword accent, and trailing cloth consistent.

Avoid blurry motion smear, overlarge effects, cute style, and inconsistent character design.
```

## 18.4 Player Parry Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Animation: parry stance and impact
Frame count: 5 frames
Canvas per frame: 64x64 pixels
Direction: facing right
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, strong silhouette, readable defensive pose, mobile readability.

Show the player raising or angling the katana precisely to parry, with a brief cyan-white spark and tiny gold accent. The pose should feel disciplined, sharp, and intentional.

Avoid messy VFX, huge glow, painterly blur, chibi proportions, and redesigning the player.
```

## 18.5 Boss Idle Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: idle
Frame count: 6 frames
Canvas per frame: 128x128 pixels
Direction: facing left or facing right as requested, side-view combat ready
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, strong silhouette, mobile readability, tragic boss duel atmosphere.

Character design: tall fallen sword master with a broken mask, long pale hair, torn dark purple-black robes, old gold accents, large broken sword, subtle purple-gold corruption aura. He should feel calm, intimidating, noble, and broken.

Avoid generic western knight armor, cute style, chibi proportions, excessive detail, and inconsistent redesign.
```

## 18.6 Boss Normal Slash Wind-Up Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: normal slash wind-up
Frame count: 6 frames
Canvas per frame: 160x128 pixels
Direction: side-view combat pose
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable boss attack pose, mobile readability.

The pose should clearly signal a parryable normal slash. Use a controlled sword-ready stance at chest or shoulder level, with a subtle gold/yellow cue. Keep the broken mask, long pale hair, torn dark purple-black robes, old gold accents, and large broken sword consistent.

Avoid red heavy danger cues for this attack, avoid messy VFX, avoid unreadable silhouette, and do not redesign the boss.
```

## 18.7 Boss Heavy Slash Wind-Up Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: heavy slash wind-up
Frame count: 8 frames
Canvas per frame: 160x128 pixels
Direction: side-view combat pose
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable heavy attack pose, mobile readability, dramatic boss duel tension.

The pose should clearly signal a dangerous heavy attack that should be dashed instead of parried. Show a large overhead or forceful wind-up with red and dark purple danger buildup. The boss should look heavy, dominant, and terrifying.

Keep the broken mask, long pale hair, torn dark purple-black robes, old gold accents, broken giant sword, and purple-gold aura consistent.

Avoid making it look like a normal parryable slash, avoid cyan player colors, avoid clutter, and do not redesign the boss.
```

## 18.8 Boss Delayed Slash Pose Sheet

```text
Create a 2D side-view pixel art pose sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: delayed slash wind-up and hold
Frame count: 8 frames
Canvas per frame: 160x128 pixels
Direction: side-view combat pose
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable deceptive attack pose, mobile readability.

Show the boss holding unnaturally still before releasing the slash, creating a deceptive pause. Use purple waiting tension during the hold, then a subtle gold release cue. The pose should feel calm, disturbing, and hard to read but still fair.

Keep the boss design consistent: broken mask, long pale hair, dark purple-black torn robes, old gold accents, large broken sword.

Avoid messy effects, excessive glow, unclear silhouette, and redesigning the boss.
```

## 18.9 Parry Spark VFX

```text
Create a pixel art parry spark VFX asset for Last Blade Trial / ดาบไร้นาม.

Effect type: parry impact spark
Canvas: 64x64 or 96x96 pixels
Background: transparent if possible
Style: dark anime pixel art, anime sword clash effect, clean readable pixels, brief and impactful, mobile readability.

Use bright cyan, cool white, and a small touch of old gold. The effect should feel like a precise defensive clash, sharp and satisfying, not a huge explosion.

Avoid messy particles, painterly glow, oversized effects, low contrast, and effects that hide the characters.
```

## 18.10 Heavy Warning VFX

```text
Create a pixel art heavy attack warning VFX asset for Last Blade Trial / ดาบไร้นาม.

Effect type: heavy attack danger warning
Canvas: 96x96 or 128x128 pixels
Background: transparent if possible
Style: dark anime pixel art, readable combat warning, brief and impactful, mobile readability.

Use crimson red, magenta-red, and dark purple. The effect should clearly communicate danger and tell the player to dash instead of parry. It should feel threatening but not cover the boss pose.

Avoid cyan parry colors, messy particles, huge explosion, painterly blur, and unclear gameplay meaning.
```

## 18.11 Touch Control Button Set

```text
Create a dark anime pixel UI button set for Last Blade Trial / ดาบไร้นาม.

Buttons: Attack, Dash, Parry, Pause
Style: dark anime pixel UI, semi-transparent dark circular buttons, muted gold border, readable pixel icons, mobile-friendly.

Attack button should be largest and use a sword slash icon.
Dash button should use a sharp movement arrow or cyan dash trail icon.
Parry button should use a guard/parry spark icon with cyan-white accent.
Pause button should be smaller and simple.

Use dark navy, charcoal black, muted gold, cyan accent, and white highlights. Avoid glossy modern UI, cute toy-like style, overly ornate frames, and unreadable tiny detail.
```

## 18.12 Layered Arena Background

```text
Create a layered 2D side-view pixel art arena background for Last Blade Trial / ดาบไร้นาม.

Arena: Moonlit Broken Dojo / ลานดวลดาบใต้จันทร์แตก
Style: dark anime pixel art, boss duel stage, mobile readability, moody atmosphere, clean combat plane.

Create the scene as separate logical layers:
1. dark moonlit sky with large moon
2. distant ruined shrine and mountain silhouettes
3. broken dojo and ruined torii gate
4. cracked stone duel floor with clean center combat area
5. low fog, embers, and ash particles

Keep the center fighting lane clean and readable. Use low saturation dark navy, muted purple, stone gray, pale moonlight, and ember orange. Avoid clutter, bright cheerful colors, and foreground objects that hide the characters.
```

---


## 18.13 Boss Quick Slash Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: quick slash
Frame count: 5 frames
Canvas per frame: 160x128 pixels
Direction: side-view combat pose
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable fast boss attack pose, mobile readability.

The pose should show a compressed low stance and a short sudden forward slash. The startup is smaller than normal slash but must still be fair and readable. Use a small gold or pale white cue, not a huge red heavy warning.

Keep the boss design consistent: broken mask, long pale hair, dark purple-black torn robes, old gold accents, large broken sword, tragic corrupted master identity.

Avoid unreadable blur, overlarge VFX, changing sword shape, cropped weapon, chibi style, and redesigning the boss.
```

## 18.14 Boss Posture Break Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Animation: posture break / stagger opening
Frame count: 8 frames
Canvas per frame: 160x128 pixels or 192x128 pixels
Direction: side-view combat pose
Background: transparent if possible
Pivot logic: bottom center, feet aligned on the same baseline

Style: dark anime pixel art, clean pixel clusters, readable boss vulnerability pose, mobile readability, dramatic duel tension.

Show the boss losing balance after repeated successful parries. The broken sword drops slightly, the body opens up, the mask and pale hair remain visible, and a brief gold-white burst indicates the player can attack or perform a finisher.

The VFX should support the opening but not hide the boss body. Keep the boss design consistent with broken mask, long pale hair, torn purple-black robe, old gold accent, and broken giant sword.

Avoid making the boss look dead, avoid huge explosion, avoid red heavy danger cue, avoid messy particles, and do not redesign the boss.
```

## 18.15 Boss Stagger / Hit Reaction Sprite

```text
Create a 2D side-view pixel art sprite for Boss Broken Master / อาจารย์ดาบผู้แตกสลาย from Last Blade Trial.

Pose: short hit reaction / stagger
Canvas: 160x128 pixels
Background: transparent if possible
Pivot logic: bottom center

Style: dark anime pixel art, clean pixel clusters, readable combat feedback, mobile readability.

Show a brief controlled stagger, as if the boss was struck but is still dangerous. The broken sword remains visible, the body bends slightly back or sideways, and a small white-gold hit flash may appear.

Keep broken mask, long pale hair, dark purple-black torn robes, old gold accents, and broken giant sword consistent.

Avoid cartoon pain expression, excessive knockback, messy VFX, and redesigning the boss.
```

## 18.16 Player Hurt Sprite

```text
Create a 2D side-view pixel art sprite for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Pose: hurt reaction
Canvas: 64x64 or 96x64 pixels
Background: transparent if possible
Pivot logic: bottom center

Style: dark anime pixel art, clean pixel clusters, readable combat feedback, mobile readability.

Show the player briefly recoiling from damage while still holding the katana. The silhouette should remain slim and disciplined, with dark blue-black outfit, cyan sword accent, and trailing cloth consistent.

Avoid comedic pain pose, chibi style, exaggerated cartoon expression, excessive blood, messy effects, and redesigning the player.
```

## 18.17 Player Death Sprite Sheet

```text
Create a 2D side-view pixel art sprite sheet for The Nameless Blade / ดาบไร้นาม from Last Blade Trial.

Animation: death / collapse
Frame count: 8 frames
Canvas per frame: 96x64 pixels or 96x96 pixels
Direction: facing right
Background: transparent if possible
Pivot logic: bottom center, final frame resting on ground baseline

Style: dark anime pixel art, clean pixel clusters, tragic but restrained, mobile readability.

Show the player collapsing after defeat, with minimal dramatic motion. The cyan sword glow fades subtly. Keep the dark blue-black outfit, slim silhouette, katana, and cloth element consistent.

Avoid gore, comedic fall, chibi style, overacting, painterly blur, and inconsistent character redesign.
```

## 18.18 Training Coach Tutorial Box

```text
Create a dark anime pixel UI tutorial coach box for Last Blade Trial / ดาบไร้นาม.

UI asset type: Duel 1 Guided Training coach box
Purpose: show short combat instructions such as PARRY, DASH, WAIT, ATTACK during boss wind-up pauses
Canvas / aspect ratio: wide mobile-friendly rectangle, transparent background if possible
Style: dark anime pixel UI, semi-transparent charcoal panel, muted gold border, high contrast white text area, small cyan/gold combat icon, readable on mobile.

The box should feel like a calm sword master training prompt, not a modern pop-up notification. It must not block the player, boss, hitbox, or combat lane.

Avoid bright toy-like colors, glossy modern UI, overly ornate decoration, tiny unreadable text, and AI-generated gibberish text. If exact text is needed, leave the text area blank and add text later in Godot.
```

## 18.19 Mobile Combat HUD Layout

```text
Create a dark anime pixel UI mockup for the mobile combat HUD of Last Blade Trial / ดาบไร้นาม.

UI elements: player HP bar, stamina bar, focus bar, boss HP bar, boss posture bar, attack button, dash button, parry button, pause button, tutorial coach box area.

Style: dark anime pixel UI, semi-transparent dark panels, muted gold borders, readable pixel icons, mobile-friendly spacing, clean hierarchy, suitable for 2D side-view boss duel gameplay.

Layout: keep the center combat lane clear. Put boss HP/posture at the top, player status at upper left or lower left, touch buttons on lower right, movement controls on lower left if needed, coach box above the lower UI without covering characters.

Color role: HP crimson, stamina teal/green-cyan, focus cyan-gold, boss posture gold/purple, warning crimson/white.

Avoid clutter, tiny text, modern glossy buttons, cute toy style, and UI that blocks boss wind-up poses.
```

## 18.20 Hitbox Debug Overlay Concept

```text
Create a simple pixel-art debug overlay concept for Last Blade Trial / ดาบไร้นาม.

Purpose: visualize gameplay hitboxes during development, not final marketing art.

Elements: player hurtbox, boss hurtbox, boss attack hitbox, parry window indicator, dash invincibility indicator.

Style: clean readable 2D side-view overlay, simple colored rectangles and labels, suitable for debugging in Godot 4.

Color suggestion: player hurtbox cyan outline, enemy hurtbox purple outline, danger hitbox red outline, parry window gold/cyan flash, dash invincibility pale cyan.

Avoid decorative effects, realistic rendering, clutter, and anything that hides the character pose.
```

## 18.21 Title Screen / Main Menu Art

```text
Create a title screen key art concept for Last Blade Trial / ดาบไร้นาม, a dark anime pixel-art mobile boss-duel game.

Show The Nameless Blade standing alone in a moonlit broken dojo, facing the distant silhouette of Boss Broken Master. Include a large moon, broken torii gate, cracked stone floor, low fog, embers, and dramatic sword-duel tension.

Style: dark anime pixel art, cinematic but readable, strong silhouettes, moody dramatic lighting, mobile game title screen composition.

Leave a clean empty area for the game title and menu buttons. Do not generate text unless specifically requested.

Player identity: dark blue-black slim swordsman with cyan sword accent.
Boss identity: broken mask, long pale hair, dark purple-black torn robe, old gold accents, broken giant sword, purple-gold aura.

Avoid cute style, chibi, bright cheerful fantasy, photorealism, painterly blur, clutter, unreadable silhouettes, and AI-generated fake text.
```

## 18.22 Current Vertical Slice Prompt Priority

สำหรับ Phase 9 Vertical Slice ให้สร้าง asset ตามลำดับนี้ก่อน เพราะเกี่ยวกับ gameplay โดยตรงที่สุด

1. Boss Broken Master idle
2. Boss normal slash wind-up
3. Boss heavy slash wind-up
4. Boss delayed slash wind-up
5. Boss quick slash
6. Player parry
7. Player dash
8. Player attack
9. Parry spark VFX
10. Heavy warning VFX
11. Training Coach tutorial box
12. Touch control buttons
13. Clean arena background
14. HUD polish
15. Title / marketing art

---

# 19) NEGATIVE PROMPT / AVOIDANCE RULES

ใช้กฎหลีกเลี่ยงเหล่านี้ทุกครั้งเมื่อเหมาะสม

## Avoid

- cute style
- chibi
- cheerful fantasy
- bright saturated cartoon palette
- over-detailed noisy background
- painterly blur
- realistic rendering
- soft blurry shading
- western knight fantasy armor overload
- tiny unreadable sprite silhouette
- giant decorative effects hiding the character
- low contrast character against background
- inconsistent costume redesigns
- super deformed body proportions
- playful expression
- comedy tone
- generic fantasy hero
- generic demon boss without sword-duel identity
- photorealistic texture
- smooth vector art look
- modern sci-fi UI unless specifically requested

## Negative Prompt Sample

```text
Avoid: cute pixel RPG style, chibi proportions, bright cheerful palette, blurry rendering, painterly texture, airbrush shading, over-detailed clutter, unreadable silhouettes, background that blends with characters, generic fantasy knight look, excessive ornamentation, messy VFX, low gameplay readability, inconsistent costume redesign, photorealism, soft pastel anime, comedy tone.
```

## Stable Diffusion Style Negative Prompt

```text
cute, chibi, super deformed, cheerful, bright pastel, blurry, soft focus, airbrush, painterly, photorealistic, realistic skin, 3d render, low contrast, cluttered background, unreadable silhouette, excessive detail, messy particles, huge glow, western knight armor, comedy, cartoon toy style, inconsistent outfit, text, watermark, logo, signature
```

---


## 19.1 Sprite Sheet Specific Negative Prompt

ใช้เพิ่มทุกครั้งเมื่อสร้าง sprite sheet หรือ pose sheet

```text
Avoid: inconsistent frames, changing costume, changing weapon, different character each frame, changing body size, uneven baseline, cropped sword, cropped hair, cropped VFX, mixed camera angles, front view, three-quarter view, perspective pose, duplicate limbs, broken hands, unreadable weapon, random extra accessories, frame spacing inconsistent, fake transparent background, messy edge pixels, noisy dithering, tiny unreadable details.
```

## 19.2 UI Specific Negative Prompt

ใช้เพิ่มเมื่อสร้าง HUD, touch buttons, tutorial box หรือ menu

```text
Avoid: unreadable text, fake letters, gibberish typography, glossy modern app style, toy-like buttons, overly ornate frames, tiny icons, low contrast text, UI covering gameplay, cluttered layout, inconsistent icon language, random logos, watermark, signature.
```

## 19.3 Background Specific Negative Prompt

ใช้เพิ่มเมื่อสร้าง arena หรือ parallax background

```text
Avoid: cluttered combat center, foreground objects blocking feet, bright cheerful fantasy, high saturation background, character-like shapes in the background, noisy floor texture, perspective floor that breaks side-view gameplay, objects hiding hitboxes, low contrast between characters and floor.
```

---

# 20) MOBILE READABILITY TEST

ก่อนยอมรับ asset ให้ทดสอบด้วยหลักนี้

## 20.1 Small Screen Test

- ย่อภาพเหลือ 50% แล้วยังอ่าน pose ออกหรือไม่
- ถ้ามองบนจอมือถือ 6 นิ้ว ยังแยก player กับ boss ได้หรือไม่
- สี player กับ boss แยกกันชัดหรือไม่
- ดาบมองเห็นหรือไม่
- ท่า wind-up ของบอสเข้าใจได้ใน 1 วินาทีหรือไม่

## 20.2 Combat Clarity Test

- Normal Slash ดูต่างจาก Heavy Slash หรือไม่
- Heavy Slash มีสีแดง/ม่วงและท่าหนักพอหรือไม่
- Parry effect ไม่บังตัวละครเกินไปหรือไม่
- Dash trail ไม่ทำให้ผู้เล่นมองไม่เห็นตัวเองหรือไม่
- ฉากหลังไม่แย่งสายตาจากตัวละครหรือไม่

## 20.3 Reject Conditions

ให้ปฏิเสธภาพถ้า:

- ภาพสวยแต่ท่าต่อสู้อ่านไม่ออก
- sprite silhouette กลืนกับฉาก
- บอสกับผู้เล่นดูขนาดใกล้กันเกินไป
- VFX ใหญ่จนบัง gameplay
- สี danger กับ parry สับสนกัน
- ตัวละครถูก redesign ไปจาก identity หลัก
- ภาพดูเป็น fantasy RPG ทั่วไป ไม่ใช่ Last Blade Trial

---


## 20.4 Asset Scoring Rubric

ใช้ให้คะแนนภาพก่อนตัดสินใจนำเข้าเกมจริง คะแนนเต็ม 100

| Category | Score | What to Check |
|---|---:|---|
| Readability | 30 | อ่าน silhouette, pose, weapon, action direction ได้ทันทีหรือไม่ |
| Style Match | 20 | เข้ากับ Dark Anime Pixel Duel หรือไม่ |
| Character Consistency | 20 | player / boss ยังตรงกับ canonical reference หรือไม่ |
| Gameplay Cue | 20 | สีและท่าสื่อ Parry / Dash / Danger / Opening ชัดหรือไม่ |
| Technical Usability | 10 | canvas, transparency, baseline, crop, noise ใช้งานต่อได้หรือไม่ |

เกณฑ์ตัดสิน:

- **90–100** = ใช้เป็น asset หลักได้หลัง clean เล็กน้อย
- **80–89** = ใช้ได้ แต่ต้องแก้บางจุดก่อนเข้า Godot
- **70–79** = ใช้เป็น concept reference เท่านั้น ยังไม่ควรเข้าเกม
- **ต่ำกว่า 70** = ปฏิเสธหรือ regenerate ใหม่

## 20.5 Acceptance Criteria by Asset Type

### Sprite ผ่านเมื่อ:

- canvas ตรงตามที่กำหนด
- มี transparency หรือแยกพื้นหลังได้ง่าย
- เท้าอยู่ baseline เดียวกัน
- weapon ไม่โดน crop
- silhouette อ่านออกเมื่อย่อ 50%
- ไม่ redesign ตัวละคร
- ใช้กับ side-view combat ได้จริง

### VFX ผ่านเมื่อ:

- สื่อ gameplay role ชัด
- สีตรงกับระบบ gameplay
- ไม่บังตัวละครหรือบอส wind-up
- อ่านได้ในเวลาไม่ถึง 1 วินาที
- ไม่ใหญ่เกิน canvas
- ไม่เป็น soft glow หรือ painterly blur มากเกินไป

### Arena ผ่านเมื่อ:

- center combat plane โล่ง
- foreground ไม่บังเท้า player/boss
- พื้นไม่รกจนมอง hitbox ยาก
- สีพื้นหลังไม่แย่งตัวละคร
- mood ยังเป็น moonlit broken dojo
- ใช้แยกเป็น parallax layers ได้

### UI ผ่านเมื่อ:

- อ่านได้บนจอมือถือ
- icon เข้าใจโดยไม่ต้องอ่านข้อความ
- touch button มีขนาดเหมาะกับนิ้ว
- ไม่บัง gameplay สำคัญ
- style เข้ากับ dark anime pixel UI
- ถ้ามีข้อความ ให้พิจารณาใส่ข้อความจริงใน Godot แทนให้ AI เขียน

---

# 21) QUALITY CHECKLIST

## General

- Does it feel like dark anime pixel art?
- Does it fit Last Blade Trial / ดาบไร้นาม?
- Is it cool and memorable?
- Is it readable on a small mobile screen?
- Is the silhouette strong?
- Is the palette controlled?
- Is there no unnecessary clutter?

## Player

- Is the silhouette clear?
- Does it look agile?
- Are cyan accents visible?
- Is the sword readable?
- Does the player stay slim and disciplined?
- Is the outfit consistent?

## Boss

- Is it clearly more intimidating than the player?
- Are broken mask / pale hair / broken sword visible?
- Is the silhouette distinct?
- Does it feel like a tragic master?
- Does the attack pose communicate gameplay?
- Is the boss not too visually noisy?

## Arena

- Is the center combat plane readable?
- Is the mood dark and moonlit?
- Are details supportive rather than distracting?
- Does the floor show enough contrast with character feet?
- Are foreground elements not blocking gameplay?

## VFX

- Is it readable instantly?
- Is it too noisy?
- Does it support the gameplay cue?
- Does the color match its gameplay role?
- Does it disappear quickly enough conceptually?
- Does it avoid hiding the character?

## UI

- Are buttons readable without text?
- Is attack visually more important than dash/parry?
- Is the UI mobile-friendly?
- Is text area high contrast?
- Does it match dark anime pixel style?

If an image is beautiful but fails readability, **reject it**.

---

# 22) TOOL-SPECIFIC PROMPT NOTES

## 22.1 ChatGPT Image / DALL·E-style Tools

ใช้ prompt แบบบรรยายละเอียดได้ดี  
แนะนำให้ระบุ:

- exact asset type
- side-view
- transparent background if possible
- pixel art, clean pixel clusters
- avoid text unless necessary
- mobile readability

ตัวอย่างคำเสริม:

```text
Please make it suitable as a game asset, not just a concept illustration.
```

## 22.2 Midjourney-style Tools

เหมาะกับ concept, key art, mood, promotional art  
อาจไม่เหมาะกับ sprite sheet ที่ต้องเป๊ะมาก

แนะนำใช้กับ:

- character concept
- arena mood
- key art
- poster
- visual exploration

คำเสริมที่ควรใช้:

```text
dark anime pixel art, 2D side-view, strong silhouette, clean composition, mobile readability, no text
```

## 22.3 Stable Diffusion / Flux / Leonardo-style Tools

เหมาะกับการควบคุม negative prompt และ batch generation  
แนะนำ:

- ใช้ positive prompt จาก template
- ใช้ negative prompt เต็ม
- ล็อก seed เมื่อต้องการ consistency
- ใช้ reference image / control image ถ้ามี
- ใช้ transparent background workflow ถ้าเครื่องมือรองรับ

## 22.4 Firefly / General Design Tools

เหมาะกับ:

- UI mockup
- promotional layout
- moodboard
- clean visual direction

ควรตรวจ text ในภาพอย่างละเอียด เพราะ AI มักสะกดผิด

---

# 23) COMMON REQUEST FORMAT

เมื่อจะสั่ง AI สร้างภาพ ให้ใช้รูปแบบนี้

```text
Asset needed:
Output mode:
Subject:
Pose / action:
Canvas / aspect ratio:
Frame count if sprite sheet:
Background:
Style:
Color role:
Gameplay purpose:
Consistency requirement:
Negative prompt:
```

ตัวอย่าง:

```text
Asset needed: Boss heavy slash wind-up sprite sheet
Output mode: Sprite Mode
Subject: Boss Broken Master / อาจารย์ดาบผู้แตกสลาย
Pose / action: overhead heavy slash wind-up, dangerous, should signal dash
Canvas / aspect ratio: 160x128 per frame
Frame count: 8 frames
Background: transparent
Style: dark anime pixel art, clean pixel clusters, mobile readability
Color role: crimson and dark purple danger cue, old gold robe accents
Gameplay purpose: tells player this attack should be dashed, not parried
Consistency requirement: same broken mask, long pale hair, broken giant sword, dark purple-black torn robes
Negative prompt: cute, chibi, blurry, painterly, cluttered, unreadable silhouette, generic knight, cyan parry cue
```

---

# 24) MASTER SHORT INSTRUCTION

ใช้คำสั่งสั้นนี้เมื่อต้องการให้ AI เข้าใจโปรเจกต์เร็ว ๆ

```text
Generate art for Last Blade Trial / ดาบไร้นาม in Dark Anime Pixel Duel style: a 2D side-view dark anime pixel art mobile game focused on boss duels, parry, dash, and readable combat. All visuals must be cool, moody, sharp, mobile-friendly, and gameplay-readable, with strong silhouettes, clean pixel clusters, dramatic combat poses, and clear role-based color separation.

Player identity: dark blue-black agile swordsman with cyan sword accent, slim silhouette, calm and disciplined.
Boss identity: fallen sword master with broken mask, long pale hair, dark purple-black torn robes, old gold and crimson accents, broken giant sword, tragic and intimidating, larger than the player.
Arena identity: moonlit broken dojo with ruined torii gate, cracked stone floor, low fog, embers, pale moonlight, and a clean combat plane.

Avoid cute, chibi, cheerful, bright, blurry, painterly, generic fantasy, noisy, or unreadable visuals.
```

---

# 25) FINAL DIRECTIVE

Whenever generating images for this project:

- prioritize gameplay readability
- keep the dark anime pixel duel identity
- preserve consistency
- make the game feel cool and attractive
- make boss attacks readable from pose and color
- make mobile screen readability the first rule
- avoid cute, noisy, generic, blurry, painterly, or unreadable outcomes
- think like a visual director for a mobile boss-duel game
- think like a gameplay designer, not only an illustrator
- treat AI output as a draft until it passes cleanup, consistency, and Godot import checks

This is not a generic fantasy project.

This is:

# **Last Blade Trial / ดาบไร้นาม**

### A dark anime pixel-art sword duel game with memorable bosses, strong atmosphere, and readable mobile combat.

---

# 26) CHANGELOG

## Version 2.1 Production-Ready Revision

ปรับปรุงจาก Version 2.0 โดยเพิ่ม:

- Quick Start / Short Skill Version สำหรับใช้กับ AI ที่รับ instruction สั้น
- คำอธิบายว่าเมื่อไรควรใช้ไฟล์เต็ม และเมื่อไรควรใช้เวอร์ชันสั้น
- ปรับตารางขนาด sprite ให้ปลอดภัยขึ้น โดยเฉพาะ player 64x64 ที่ไม่ควรสูงเกิน canvas
- เพิ่ม Godot 4 Import Checklist แบบละเอียดสำหรับมือใหม่
- เพิ่ม Sprite Sheet Reality Warning เพื่อย้ำว่า AI sprite sheet เป็น draft ไม่ใช่ final asset ทันที
- เพิ่ม Post-Generation Cleanup Workflow
- เพิ่ม Asset Folder Recommendation สำหรับโปรเจกต์ `last-blade-trial`
- เพิ่ม Canonical Reference Workflow เพื่อป้องกัน AI redesign player/boss
- เพิ่ม Character Lock Acceptance Rules
- เพิ่ม Approved Asset Rule และแนวทางตั้งชื่อไฟล์ที่ผ่านแล้ว
- เพิ่ม prompt สำหรับ Boss Quick Slash, Boss Posture Break, Boss Stagger, Player Hurt, Player Death
- เพิ่ม prompt สำหรับ Training Coach Tutorial Box, Mobile Combat HUD, Hitbox Debug Overlay และ Title Screen
- เพิ่ม Current Vertical Slice Prompt Priority สำหรับ Phase 9
- เพิ่ม Sprite Sheet Specific Negative Prompt
- เพิ่ม UI และ Background Negative Prompt เฉพาะทาง
- เพิ่ม Asset Scoring Rubric คะแนนเต็ม 100
- เพิ่ม Acceptance Criteria แยกตาม Sprite, VFX, Arena, UI
- ปรับ Final Directive ให้รวมแนวคิด production cleanup และ Godot import check

## Version 2.0 Improved Skill File

ปรับปรุงจากไฟล์เดิมโดยเพิ่ม:

- Godot 4 technical art standard
- sprite sheet rules
- suggested canvas sizes
- suggested animation frames and FPS
- file naming convention
- color HEX suggestions
- boss telegraph visual rules
- mobile UI button rules
- VFX technical rules
- production-ready prompts
- mobile readability test
- tool-specific prompt notes
- common request format
