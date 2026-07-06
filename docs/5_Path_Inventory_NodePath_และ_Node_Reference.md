# Path Inventory: NodePath และ Node Reference

โครงการ: **Last Blade Trial / ดาบไร้นาม**  
สถานะเอกสาร: Step 1 เสร็จสมบูรณ์จากแผน `docs/4_แผนปรับปรุงโครงสร้าง_NodePath_และ_Scene_Organization.md`  
วันที่จัดทำ: 2026-07-06  
ประเภทงาน: เอกสาร inventory เพื่อเตรียม `Stable Reference Pass` ก่อน `Scene Organization`

---

## 1. วัตถุประสงค์

เอกสารนี้จัดทำขึ้นเพื่อบันทึกว่าแต่ละระบบใน runtime scene ปัจจุบันอ้างอิง Node ใดบ้าง และอ้างด้วยวิธีใด เช่น

```text
NodePath export
get_parent().get_node_or_null(...)
get_parent().get_node(...)
$ChildPath
get_tree().get_nodes_in_group(...)
/root/Autoload
```

เป้าหมายคือใช้เป็น checklist ก่อนเข้าสู่ Step 2-5 ของแผนปรับปรุงโครงสร้าง:

```text
Path Inventory → Group Identity → Robust Lookup → Smoke Test → Move Nodes ทีละกลุ่ม
```

เอกสารนี้ **ไม่ใช่การ refactor โค้ด** และ **ไม่ใช่การย้าย Node** แต่เป็นฐานข้อมูลความเสี่ยงก่อนทำงานจริง

---

## 2. ขอบเขตการสำรวจ

สำรวจจาก runtime หลักของเกม ณ ปัจจุบัน ได้แก่

```text
last-blade-trial/project.godot
last-blade-trial/scenes/main/BossBrokenMaster.tscn
last-blade-trial/scenes/bosses/BossBrokenMaster.tscn
script ทุกตัวที่ main scene อ้างผ่าน ext_resource
autoload UpgradeRunState
```

ขอบเขตนี้ครอบคลุมระบบที่มีผลโดยตรงกับ main gameplay loop:

```text
Start → Training Coach → Duel 1 Guided Training → Boss Fight → Victory/Defeat → Upgrade/Restart
```

### 2.1 ข้อจำกัดของการสำรวจ

เครื่องมือ GitHub connector ในแชตนี้สามารถ fetch ไฟล์รายตัวได้ แต่ไม่ได้ให้ recursive directory tree ที่เชื่อถือได้ในรอบนี้ ดังนั้นเอกสารนี้จึงเน้น **main runtime dependency** เป็นหลัก

ไฟล์ที่ไม่ได้ถูกอ้างจาก main scene โดยตรงอาจยังไม่ได้อยู่ใน inventory นี้ แต่สำหรับการย้าย Node ใน `BossBrokenMaster.tscn` ขอบเขตนี้ถือว่าเพียงพอสำหรับวางแผนอย่างปลอดภัย

---

## 3. Runtime Entry Points

### 3.1 Main Scene

```text
run/main_scene = res://scenes/main/BossBrokenMaster.tscn
```

Main scene ปัจจุบันคือฉาก `BossBrokenMaster.tscn` ในโฟลเดอร์ `scenes/main`

### 3.2 Autoload

```text
UpgradeRunState = *res://upgrade_run_state.gd
```

Autoload นี้อยู่ที่ `/root/UpgradeRunState` และถูกใช้โดยระบบ GameLoop / Upgrade หลังชนะ

### 3.3 Input Actions ที่เกี่ยวข้องกับ reference / test

```text
attack  → Keyboard A
Dash    → Keyboard S
lock_on → Keyboard L
parry   → Keyboard D
```

หมายเหตุ: `parry` บน keyboard ปัจจุบันถูกใช้เป็น Tap Deflect หลักสำหรับการทดสอบบนคอม ส่วนมือถือใช้ joystick tap / movement deflect

---

## 4. Main Scene Resource Inventory

ไฟล์ main scene อ้าง resource หลักดังนี้

| Resource ID | Path | บทบาท |
|---|---|---|
| `1_tedvd` | `res://arena_manager.gd` | Arena bounds / arena group / background prototype |
| `2_mknfb` | `res://player_nameless_sprite_patch.gd` | Player script ปัจจุบันที่ extends `player.gd` |
| `4_tedvd` | `res://scenes/bosses/BossBrokenMaster.tscn` | Boss scene instance |
| `5_7w3th` | `res://HUD.gd` | HUD แสดง HP/Stamina/Focus/Posture |
| `6_jpax5` | `res://game_camera.gd` | Camera / camera shake group |
| `7_decay` | `res://combat_decay_manager.gd` | Boss posture recovery / Player focus decay |
| `8_touch` | `res://touch_controls.gd` | Mobile UI input |
| `9_player_vfx` | `res://player_attack_vfx_manager.gd` | Player slash VFX |
| `10_loop` | `res://game_loop_manager.gd` | Start/Victory/Defeat/Upgrade loop |
| `11_curve` | `res://boss_difficulty_curve_manager.gd` | Boss phase / attack chance curve |
| `12_training` | `res://training_coach_manager.gd` | Basic tutorial overlay |
| `13_duel_intro` | `res://duel_1_intro_manager.gd` | Freeze-frame duel intro / legacy practice gate |
| `14_boss_weight` | `res://boss_weight_manager.gd` | Boss weight / recoil control |
| `15_duel_dummy` | `res://duel_1_dummy_manager.gd` | Duel 1 Guided Training with real boss |
| `16_hint_cleanup` | `res://boss_fight_hint_cleanup_manager.gd` | Hint cleanup / PARRY to DEFLECT bridge |
| `17_run_metrics` | `res://run_metrics_manager.gd` | Run metrics / Parry count on result screen |
| `18_arena_visual` | `res://arena_visual_manager.gd` | Arena visual background, fog, embers |
| `19_grab` | `res://boss_grab_balance_manager.gd` | Boss grab / anti-repetition memory |
| `20_deflect_balance` | `res://movement_deflect_balance_manager.gd` | Movement/Tap Deflect balance |
| `21_sprite_orientation` | `res://player_sprite_orientation_manager.gd` | Player Sprite2D orientation compatibility |
| `22_idle_frames` | `res://assets/sprites/player/nameless_blade/player_idle_sprite_frames.tres` | Player idle/run/back SpriteFrames |
| `23_animated_idle` | `res://player_animated_idle_visual_manager.gd` | AnimatedSprite2D visual sync |
| `24_keyboard_deflect` | `res://keyboard_tap_deflect_manager.gd` | Keyboard D → Tap Deflect bridge |

---

## 5. Current Main Scene Node Tree Inventory

### 5.1 Root Level

Current root structure is still flat:

```text
Main
├── ArenaManager
├── ArenaVisualManager
├── Player
├── KeyboardTapDeflectManager
├── MovementDeflectBalanceManager
├── BossBrokenMaster
├── BossGrabBalanceManager
├── CombatDecayManager
├── PlayerAttackVFXManager
├── BossDifficultyCurveManager
├── BossWeightManager
├── Duel1DummyManager
├── HUD
├── TouchControls
├── TrainingCoachManager
├── Duel1IntroManager
├── GameLoopManager
├── BossFightHintCleanupManager
├── RunMetricsManager
└── GameCamera
```

ปัญหาหลักคือหลาย Node อยู่ระดับเดียวกันและอ้างกันด้วย `../...` ทำให้การย้าย Node เข้า folder มีโอกาสทำให้ reference หลุด

### 5.2 Player Subtree

```text
Player
├── Sprite2D
├── AnimatedSprite2D
├── CollisionShape2D
├── AttackHitbox
│   └── CollisionShape2D
├── Hurtbox
│   └── CollisionShape2D
├── PlayerSpriteOrientationManager
└── PlayerAnimatedIdleVisualManager
```

ข้อสรุป:

```text
ย้าย Player ได้เฉพาะแบบย้ายทั้งก้อน
ห้ามแยก Sprite2D / AnimatedSprite2D / AttackHitbox / Hurtbox / visual managers ออกตอนนี้
```

เหตุผล: `PlayerSpriteOrientationManager` และ `PlayerAnimatedIdleVisualManager` อ้าง child ภายใน Player ด้วย relative path เช่น `..`, `../Sprite2D`, `../AnimatedSprite2D`

### 5.3 HUD Subtree

```text
HUD
└── Control
    ├── VBoxContainer
    │   ├── HPLabel
    │   ├── HPBar
    │   ├── StaminaLabel
    │   ├── StaminaBar
    │   ├── EnemyHPLabel
    │   ├── EnemyHPBar
    │   ├── EnemyPostureLabel
    │   ├── EnemyPostureBar
    │   ├── FocusLabel
    │   └── FocusBar
    └── GameResultLabel
```

ข้อสรุป:

```text
ย้าย HUD ได้เฉพาะแบบย้ายทั้งก้อน
ห้ามแยก Control / VBoxContainer / Label / ProgressBar ออกตอนนี้
```

เหตุผล: `HUD.gd` ใช้ `$Control/VBoxContainer/...` และ `$Control/GameResultLabel`

---

## 6. Detailed Script Reference Inventory

## 6.1 `project.godot`

| รายการ | ค่า | ความเสี่ยงเมื่อย้าย Node |
|---|---|---|
| main scene | `res://scenes/main/BossBrokenMaster.tscn` | ไม่กระทบถ้าไม่เปลี่ยน main scene path |
| autoload | `/root/UpgradeRunState` | ไม่กระทบจากการย้าย node ใน main scene |
| input `attack` | Keyboard A | ไม่เกี่ยวกับ NodePath |
| input `dash` | Keyboard S | ไม่เกี่ยวกับ NodePath |
| input `lock_on` | Keyboard L | ไม่เกี่ยวกับ NodePath |
| input `parry` | Keyboard D | ไม่เกี่ยวกับ NodePath แต่เกี่ยวกับ KeyboardTapDeflectManager |

ข้อควรระวัง:

```text
ห้ามเปลี่ยน main_scene ระหว่าง refactor scene organization
ห้ามเปลี่ยน input action ระหว่าง refactor reference
```

---

## 6.2 `scenes/main/BossBrokenMaster.tscn`

ชนิดการอ้างอิงหลัก:

```text
NodePath export override ใน scene
parent="." flat root
parent="Player/..." สำหรับ child ภายใน Player
parent="HUD/..." สำหรับ child ภายใน HUD
```

รายการ NodePath สำคัญใน scene:

| Node | Current NodePath | หมายเหตุ |
|---|---|---|
| `PlayerSpriteOrientationManager.player_path` | `..` | ภายใน Player, ปลอดภัยถ้าย้าย Player ทั้งก้อน |
| `PlayerSpriteOrientationManager.sprite_path` | `../Sprite2D` | ภายใน Player, ห้ามแยก Sprite2D |
| `PlayerAnimatedIdleVisualManager.player_path` | `..` | ภายใน Player |
| `PlayerAnimatedIdleVisualManager.legacy_sprite_path` | `../Sprite2D` | ภายใน Player |
| `PlayerAnimatedIdleVisualManager.animated_sprite_path` | `../AnimatedSprite2D` | ภายใน Player |
| `KeyboardTapDeflectManager.player_path` | `../Player` | จะพังถ้า manager ถูกย้ายเข้า `CombatSystems` หรือ Player ถูกย้ายเข้า `Actors` โดยไม่แก้ |
| `MovementDeflectBalanceManager.player_path` | `../Player` | เช่นเดียวกัน |
| `BossGrabBalanceManager.player_path` | `../Player` | ต้องแก้ก่อน/ระหว่างย้าย CombatSystems |
| `BossGrabBalanceManager.boss_path` | `../BossBrokenMaster` | ต้องแก้ถ้าย้าย Boss เข้า Actors |
| `BossGrabBalanceManager.game_loop_manager_path` | `../GameLoopManager` | ต้องแก้ถ้าย้าย GameLoop เข้า GameFlow |
| `BossGrabBalanceManager.duel_1_manager_path` | `../Duel1DummyManager` | ต้องแก้ถ้าย้าย Duel1DummyManager เข้า UI |

ความเสี่ยง:

```text
สูง หากย้าย node ก่อนทำ robust lookup
ควรใช้ group fallback ก่อนเริ่ม Scene Organization
```

---

## 6.3 `player.gd`

ชนิดการอ้างอิง:

```text
$ChildPath
get_tree().get_nodes_in_group("arena_manager")
Input actions
signals
runtime state read/write by managers
```

อ้างอิงภายใน Player:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| `Sprite2D` | `$Sprite2D` | ปลอดภัยถ้าย้าย Player ทั้งก้อน, พังถ้าแยก Sprite2D |
| `AttackHitbox` | `$AttackHitbox` | ปลอดภัยถ้าย้าย Player ทั้งก้อน |
| `AttackHitbox/CollisionShape2D` | `$AttackHitbox/CollisionShape2D` | ห้ามเปลี่ยน subtree attack hitbox |
| `Hurtbox` | `$Hurtbox` | ปลอดภัยถ้าย้าย Player ทั้งก้อน |
| `Hurtbox/CollisionShape2D` | `$Hurtbox/CollisionShape2D` | ห้ามเปลี่ยน subtree hurtbox |
| `ArenaManager` | group `arena_manager` | ปลอดภัยกับการย้าย ArenaManager |

ข้อสรุป:

```text
Player.gd ค่อนข้างปลอดภัยถ้าย้าย Player ทั้งก้อน
แต่ยังควรเพิ่ม group player_actor ในอนาคตเพื่อให้ระบบอื่นหา Player ได้แบบ robust
```

ข้อห้าม:

```text
ห้ามแยก Sprite2D / AttackHitbox / Hurtbox ออกจาก Player
ห้ามแก้ child path ภายใน Player ระหว่าง Scene Organization รอบแรก
```

---

## 6.4 `player_nameless_sprite_patch.gd`

ชนิดการอ้างอิง:

```text
extends res://player.gd
ใช้ตัวแปร/Node จาก player.gd เช่น sprite_2d, attack_hitbox, facing_direction
```

ความเสี่ยง:

```text
ไม่เกี่ยวกับ external NodePath โดยตรง
แต่ขึ้นกับ subtree เดิมของ Player ผ่าน player.gd
```

ข้อสรุป:

```text
ปลอดภัยถ้าย้าย Player ทั้งก้อน
ไม่ควรแก้พร้อมกับ Scene Organization เพราะเป็น compatibility patch ด้าน sprite/facing
```

---

## 6.5 `player_sprite_orientation_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("..")
@export var sprite_path = NodePath("../Sprite2D")
fallback: get_parent()
fallback: player.get_node_or_null("Sprite2D")
```

ผลกระทบเมื่อย้าย:

```text
ปลอดภัยถ้า manager ยังอยู่ใต้ Player
พังถ้าย้าย manager ออกนอก Player โดยไม่แก้ path
```

ข้อสรุป:

```text
ให้คงไว้ใต้ Player
ย้าย Player ทั้งก้อนเท่านั้น
```

---

## 6.6 `player_animated_idle_visual_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("..")
@export var legacy_sprite_path = NodePath("../Sprite2D")
@export var animated_sprite_path = NodePath("../AnimatedSprite2D")
```

ผลกระทบเมื่อย้าย:

```text
ปลอดภัยถ้า manager ยังอยู่ใต้ Player
พังถ้าย้าย Sprite2D / AnimatedSprite2D ออกจาก Player
```

ข้อสรุป:

```text
ให้คงไว้ใต้ Player
ย้าย Player ทั้งก้อนเท่านั้น
```

---

## 6.7 `BossBrokenMaster.gd`

ชนิดการอ้างอิง:

```text
$Sprite2D
$AttackHitbox
$AttackHitbox/CollisionShape2D
get_tree().get_nodes_in_group("arena_manager")
add_to_group("combat_target")
get_parent().get_node_or_null("Player")
```

อ้างอิงภายใน Boss:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| `Sprite2D` | `$Sprite2D` | ปลอดภัยถ้าย้าย Boss ทั้งก้อน |
| `AttackHitbox` | `$AttackHitbox` | ปลอดภัยถ้าย้าย Boss ทั้งก้อน |
| `AttackHitbox/CollisionShape2D` | `$AttackHitbox/CollisionShape2D` | ห้ามเปลี่ยน subtree Boss hitbox |
| `ArenaManager` | group `arena_manager` | ปลอดภัย |
| `combat_target` | `add_to_group("combat_target")` | ดีแล้ว ใช้เป็น identity ของ Boss |
| `Player` | `get_parent().get_node_or_null("Player")` | เปราะ ต้องแก้ก่อนย้าย Actors/UI/CombatSystems |

ระดับความเสี่ยง:

```text
สูงเฉพาะการหา Player
ต่ำสำหรับ ArenaManager และ combat_target เพราะใช้ group แล้ว
```

ข้อเสนอ Step 2/3:

```text
เพิ่มการหา Player ผ่าน group player_actor ก่อน fallback parent
```

---

## 6.8 `scenes/bosses/BossBrokenMaster.tscn`

โครงภายใน:

```text
BossBrokenMaster
├── Sprite2D
├── CollisionShape2D
├── Hurtbox
│   └── CollisionShape2D
└── AttackHitbox
    └── CollisionShape2D
```

ข้อสรุป:

```text
ย้าย Boss scene instance ได้ทั้งก้อน
ห้ามย้ายลูกภายใน Boss scene ในรอบ Scene Organization นี้
```

---

## 6.9 `HUD.gd`

ชนิดการอ้างอิง:

```text
$Control/VBoxContainer/HPLabel
$Control/VBoxContainer/HPBar
$Control/VBoxContainer/StaminaLabel
$Control/VBoxContainer/StaminaBar
$Control/VBoxContainer/FocusLabel
$Control/VBoxContainer/FocusBar
$Control/VBoxContainer/EnemyHPLabel
$Control/VBoxContainer/EnemyHPBar
$Control/VBoxContainer/EnemyPostureLabel
$Control/VBoxContainer/EnemyPostureBar
$Control/GameResultLabel
get_tree().get_nodes_in_group("combat_target")
get_parent().get_node("Player")
get_parent().get_children() fallback หา enemy จาก signal
```

อ้างอิงภายใน HUD:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| HUD labels/bars | `$Control/...` | ปลอดภัยถ้าย้าย HUD ทั้งก้อน |
| Boss/Enemy | group `combat_target` | ดีแล้ว |
| Player | `get_parent().get_node("Player")` | เสี่ยงสูง |
| Enemy fallback | วน `get_parent().get_children()` | เสี่ยงถ้า Boss ย้ายเข้า Actors และ group ไม่พร้อม |

ข้อเสนอ Step 2/3:

```text
เพิ่ม player_path export หรือ group fallback player_actor
หา Player ผ่าน NodePath → group → parent fallback
คง combat_target group สำหรับ Boss ไว้
```

ข้อห้าม:

```text
ห้ามย้าย HUD เข้า UI ก่อนแก้ Player lookup
ห้ามแยก Control/VBoxContainer/Labels ออกจาก HUD
```

---

## 6.10 `touch_controls.gd`

ชนิดการอ้างอิง:

```text
สร้าง UI ด้วยโค้ดเป็น child ของ TouchControls
Input.action_press / Input.action_release
find_player_node() → get_parent().get_node_or_null("Player")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Touch UI children | สร้าง runtime ด้วยโค้ด | ปลอดภัยถ้าย้าย TouchControls ทั้งก้อน |
| Player | `get_parent().get_node_or_null("Player")` | เสี่ยงสูงถ้าย้าย TouchControls เข้า UI |
| Input actions | `attack`, `dash`, `lock_on`, `ui_left`, `ui_right` | ไม่เกี่ยวกับ NodePath |

ข้อเสนอ Step 2/3:

```text
เพิ่ม player_path export หรือหา group player_actor
find_player_node() ควรใช้ NodePath → group → parent fallback
```

ข้อห้าม:

```text
ห้ามย้าย TouchControls เข้า UI ก่อนแก้ find_player_node()
```

---

## 6.11 `game_loop_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
@export var touch_controls_path = NodePath("../TouchControls")
get_parent().get_node_or_null("Player") fallback
get_parent().get_node_or_null("BossBrokenMaster") fallback
get_parent().get_node_or_null("TouchControls") fallback
get_node_or_null("/root/UpgradeRunState")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องแก้ก่อนย้าย GameLoop/Actors |
| Boss | NodePath + parent fallback | ต้องแก้ก่อนย้าย GameLoop/Actors |
| TouchControls | NodePath + parent fallback | ต้องแก้ก่อนย้าย UI/GameFlow |
| UpgradeRunState | `/root/UpgradeRunState` | ปลอดภัยจากการย้าย Node ใน scene |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback: player_actor, combat_target, touch_controls
GameLoopManager เองควร add_to_group("game_loop_manager")
```

---

## 6.12 `training_coach_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
get_parent().get_node_or_null("Player") fallback
get_parent().get_node_or_null("BossBrokenMaster") fallback
get_parent().get_node_or_null("GameLoopManager") fallback
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี group fallback ก่อนย้าย UI/Actors |
| Boss | NodePath + parent fallback | ใช้ combat_target fallback ได้ |
| GameLoopManager | NodePath + parent fallback | ควรใช้ group game_loop_manager |

ข้อเสนอ Step 4:

```text
TrainingCoachManager ควร add_to_group("training_coach_manager")
setup_references() ควรใช้ NodePath → group → parent fallback
```

---

## 6.13 `duel_1_intro_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
@export var training_coach_manager_path = NodePath("../TrainingCoachManager")
parent fallback ทุกตัว
boss.get_node_or_null("AttackHitbox/CollisionShape2D")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี player_actor fallback |
| Boss | NodePath + parent fallback | ใช้ combat_target fallback ได้ |
| GameLoopManager | NodePath + parent fallback | ควรใช้ group game_loop_manager |
| TrainingCoachManager | NodePath + parent fallback | ควรใช้ group training_coach_manager |
| Boss hitbox child | `boss.get_node_or_null("AttackHitbox/CollisionShape2D")` | ปลอดภัยถ้าไม่เปลี่ยน Boss subtree |

ข้อเสนอ Step 4:

```text
Duel1IntroManager ควร add_to_group("duel_1_intro_manager")
เพิ่ม group fallback ให้ทุก reference
```

---

## 6.14 `duel_1_dummy_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
@export var training_coach_manager_path = NodePath("../TrainingCoachManager")
@export var duel_intro_manager_path = NodePath("../Duel1IntroManager")
parent fallback ทุกตัว
boss.get_node_or_null("AttackHitbox/CollisionShape2D")
boss.get_node_or_null("Sprite2D")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี player_actor fallback |
| Boss | NodePath + parent fallback | ใช้ combat_target fallback ได้ |
| GameLoopManager | NodePath + parent fallback | ควรใช้ group game_loop_manager |
| TrainingCoachManager | NodePath + parent fallback | ควรใช้ group training_coach_manager |
| Duel1IntroManager | NodePath + parent fallback | ควรใช้ group duel_1_intro_manager |
| Boss hitbox/sprite child | `boss.get_node_or_null(...)` | ปลอดภัยถ้าไม่เปลี่ยน Boss subtree |

ข้อเสนอ Step 4:

```text
Duel1DummyManager ควร add_to_group("duel_1_manager")
เพิ่ม group fallback ให้ทุก reference
```

---

## 6.15 `keyboard_tap_deflect_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
get_parent().get_node_or_null("Player") fallback
Input.is_action_just_pressed("parry")
player.register_tap_deflect_input()
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องแก้ก่อนย้ายเข้า CombatSystems |
| Input `parry` | action | ไม่เกี่ยวกับ NodePath |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback player_actor
ไม่ควรผูกซ้าย/ขวา keyboard เป็น Tap Deflect ในรอบ refactor นี้
```

---

## 6.16 `movement_deflect_balance_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
get_parent().get_node_or_null("Player") fallback
อ่าน/เขียน property ของ Player เช่น last_movement_deflect_msec, current_stamina, last_active_deflect_type
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องแก้ก่อนย้ายเข้า CombatSystems |
| Player properties | `get()` / `set()` | ไม่ใช่ NodePath แต่ผูกกับ contract ของ Player |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback player_actor
ระวังอย่าเปลี่ยน balance behavior ระหว่าง refactor
```

---

## 6.17 `boss_grab_balance_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
@export var duel_1_manager_path = NodePath("../Duel1DummyManager")
parent fallback ทุกตัว
group fallback combat_target สำหรับ Boss มีอยู่บางส่วน
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี player_actor fallback |
| Boss | NodePath + group combat_target + parent fallback | ค่อนข้างดี แต่ควรจัดรูปแบบให้ชัด |
| GameLoopManager | NodePath + parent fallback | ควรมี group game_loop_manager |
| Duel1DummyManager | NodePath + parent fallback | ควรมี group duel_1_manager |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback ให้ Player/GameLoop/Duel1
คง combat_target fallback สำหรับ Boss
```

---

## 6.18 `combat_decay_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
@export var boss_path = NodePath("../BossBrokenMaster")
parent fallback Player/Boss
อ่าน/เขียน Player Focus และ Boss Posture
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี player_actor fallback |
| Boss | NodePath + parent fallback | ควรมี combat_target fallback |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback player_actor และ combat_target
```

---

## 6.19 `player_attack_vfx_manager.gd`

ชนิดการอ้างอิง:

```text
@export var player_path = NodePath("../Player")
get_parent().get_node_or_null("Player") fallback
get_parent().add_child(slash_root)
อ่าน Player facing_direction และ is_attacking
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Player | NodePath + parent fallback | ต้องมี player_actor fallback |
| VFX parent | `get_parent().add_child(slash_root)` | ถ้าย้ายเข้า CombatSystems เอฟเฟกต์จะถูกสร้างใต้ CombatSystems แทน Main |

ข้อเสนอ Step 4/Phase E:

```text
เพิ่ม group fallback player_actor
พิจารณา export vfx_parent_path หรือใช้ current_scene/Main fallback ก่อนย้าย CombatSystems
```

หมายเหตุสำคัญ:

```text
ตัวนี้มีความเสี่ยงพิเศษ เพราะไม่ใช่แค่หา Player แต่ยัง add_child VFX ใต้ parent ปัจจุบัน
```

---

## 6.20 `boss_difficulty_curve_manager.gd`

ชนิดการอ้างอิง:

```text
@export var boss_path = NodePath("../BossBrokenMaster")
get_parent().get_node_or_null("BossBrokenMaster") fallback
อ่าน/เขียน boss attack chance
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Boss | NodePath + parent fallback | ควรมี combat_target fallback |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback combat_target
```

---

## 6.21 `boss_weight_manager.gd`

ชนิดการอ้างอิง:

```text
@export var boss_path = NodePath("../BossBrokenMaster")
@export var player_path = NodePath("../Player")
parent fallback Boss/Player
อ่าน/เขียน boss knockback state
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Boss | NodePath + parent fallback | ควรมี combat_target fallback |
| Player | NodePath + parent fallback | ควรมี player_actor fallback |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback combat_target และ player_actor
```

---

## 6.22 `boss_fight_hint_cleanup_manager.gd`

ชนิดการอ้างอิง:

```text
@export var boss_path = NodePath("../BossBrokenMaster")
@export var duel_1_manager_path = NodePath("../Duel1DummyManager")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
parent fallback ทุกตัว
boss.get("boss_hint_label")
boss.get_node_or_null("Sprite2D")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Boss | NodePath + parent fallback | ควรมี combat_target fallback |
| Duel1DummyManager | NodePath + parent fallback | ควรมี duel_1_manager fallback |
| GameLoopManager | NodePath + parent fallback | ควรมี game_loop_manager fallback |
| Boss Sprite2D | `boss.get_node_or_null("Sprite2D")` | ปลอดภัยถ้าไม่เปลี่ยน Boss subtree |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback combat_target, duel_1_manager, game_loop_manager
```

---

## 6.23 `run_metrics_manager.gd`

ชนิดการอ้างอิง:

```text
@export var boss_path = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path = NodePath("../GameLoopManager")
parent fallback Boss/GameLoopManager
อ่าน body_label จาก GameLoopManager ผ่าน get("body_label")
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| Boss | NodePath + parent fallback | ควรมี combat_target fallback |
| GameLoopManager | NodePath + parent fallback | ควรมี game_loop_manager fallback |
| GameLoop body_label | `game_loop_manager.get("body_label")` | ไม่ใช่ NodePath แต่ผูกกับ public variable ของ GameLoopManager |

ข้อเสนอ Step 4:

```text
เพิ่ม group fallback combat_target และ game_loop_manager
```

---

## 6.24 `arena_manager.gd`

ชนิดการอ้างอิง:

```text
add_to_group("arena_manager")
get_parent()
parent_node.get_node_or_null("ArenaBackground")
parent_node.add_child(background_root)
```

Reference สำคัญ:

| Reference | วิธีอ้าง | ความเสี่ยง |
|---|---|---|
| arena identity | group `arena_manager` | ดีแล้ว |
| ArenaBackground | สร้างใต้ parent ปัจจุบัน | ถ้าย้าย ArenaManager เข้า World จะสร้าง Background ใต้ World แทน Main |

ข้อเสนอ Phase A:

```text
ย้ายได้ค่อนข้างปลอดภัย แต่ต้องทดสอบว่า background ยังอยู่หลังตัวละครและไม่ซ้อนผิด
```

---

## 6.25 `arena_visual_manager.gd`

ชนิดการอ้างอิง:

```text
สร้าง visual children ภายในตัวเอง
ไม่อ้าง Player/Boss/GameLoop โดยตรง
```

ความเสี่ยง:

```text
ต่ำมากเมื่อย้ายเข้า World
```

ข้อเสนอ Phase A:

```text
ย้ายเข้า World ได้หลัง smoke test
```

---

## 6.26 `game_camera.gd`

ชนิดการอ้างอิง:

```text
add_to_group("game_camera")
make_current()
```

ความเสี่ยง:

```text
ต่ำมากเมื่อย้ายเข้า World
```

ข้อเสนอ Phase A:

```text
ย้ายเข้า World ได้หลัง smoke test
```

---

## 6.27 `upgrade_run_state.gd`

ชนิดการอ้างอิง:

```text
Autoload ที่ /root/UpgradeRunState
ไม่ขึ้นกับ main scene tree โดยตรง
```

ความเสี่ยง:

```text
ต่ำมากจาก Scene Organization
```

ข้อควรระวัง:

```text
ห้ามเปลี่ยนชื่อ autoload หรือ path ใน project.godot ระหว่าง refactor scene organization
```

---

## 7. Risk Classification

### 7.1 Red Zone: ต้องแก้ก่อนย้าย Node

| File | เหตุผล |
|---|---|
| `HUD.gd` | หา Player ด้วย `get_parent().get_node("Player")` |
| `TouchControls.gd` | หา Player ด้วย `get_parent().get_node_or_null("Player")` |
| `BossBrokenMaster.gd` | หา Player จาก parent โดยตรง |
| `PlayerAttackVFXManager.gd` | add_child VFX ใต้ parent ปัจจุบัน ถ้าย้าย parent จะเปลี่ยนตำแหน่งใน tree |

### 7.2 Yellow Zone: มี exported NodePath แก้ได้ แต่ต้องมี group fallback

| File | Reference สำคัญ |
|---|---|
| `GameLoopManager.gd` | Player, Boss, TouchControls |
| `TrainingCoachManager.gd` | Player, Boss, GameLoopManager |
| `Duel1IntroManager.gd` | Player, Boss, GameLoopManager, TrainingCoachManager |
| `Duel1DummyManager.gd` | Player, Boss, GameLoopManager, TrainingCoachManager, Duel1IntroManager |
| `KeyboardTapDeflectManager.gd` | Player |
| `MovementDeflectBalanceManager.gd` | Player |
| `BossGrabBalanceManager.gd` | Player, Boss, GameLoopManager, Duel1DummyManager |
| `CombatDecayManager.gd` | Player, Boss |
| `BossDifficultyCurveManager.gd` | Boss |
| `BossWeightManager.gd` | Boss, Player |
| `BossFightHintCleanupManager.gd` | Boss, Duel1DummyManager, GameLoopManager |
| `RunMetricsManager.gd` | Boss, GameLoopManager |

### 7.3 Green Zone: ย้ายได้ค่อนข้างปลอดภัยหลัง smoke test

| File / Node | เหตุผล |
|---|---|
| `ArenaVisualManager` | สร้าง visual children ภายในตัวเอง ไม่อ้าง Player/Boss |
| `GameCamera` | ใช้ group `game_camera` |
| `ArenaManager` | ใช้ group `arena_manager` แต่ต้องระวัง background parent |
| `UpgradeRunState` | Autoload ไม่ผูก scene tree |

---

## 8. Proposed Group Identity Map

ควรใช้ group identity ต่อไปนี้ใน Step 2:

| Node | Group ที่ควรมี | สถานะปัจจุบัน |
|---|---|---|
| `Player` | `player_actor` | ยังควรเพิ่ม |
| `BossBrokenMaster` | `combat_target` | มีแล้ว |
| `ArenaManager` | `arena_manager` | มีแล้ว |
| `GameCamera` | `game_camera` | มีแล้ว |
| `TouchControls` | `touch_controls` | ยังควรเพิ่ม |
| `GameLoopManager` | `game_loop_manager` | ยังควรเพิ่ม |
| `TrainingCoachManager` | `training_coach_manager` | ยังควรเพิ่ม |
| `Duel1IntroManager` | `duel_1_intro_manager` | ยังควรเพิ่ม |
| `Duel1DummyManager` | `duel_1_manager` | ยังควรเพิ่ม |
| `HUD` | `hud` | optional แต่แนะนำได้ในอนาคต |

---

## 9. Recommended Lookup Order Template

ทุกไฟล์ที่หา Node ข้ามระบบควรใช้แนวคิดนี้:

```text
1. get_node_or_null(exported_path)
2. get_tree().get_nodes_in_group(group_name)
3. get_parent().get_node_or_null("LegacyName")
```

ตัวอย่างเชิงแนวคิด:

```gdscript
# หา Player จาก path ก่อน ถ้าไม่เจอค่อยหา group แล้วค่อย fallback ด้วยชื่อเดิม
player = get_node_or_null(player_path)
if player == null:
    var players := get_tree().get_nodes_in_group("player_actor")
    if players.size() > 0:
        player = players[0]
if player == null and get_parent() != null:
    player = get_parent().get_node_or_null("Player")
```

หมายเหตุ: ตัวอย่างนี้เป็นแนวทาง ไม่ใช่โค้ดที่ถูกนำไปใช้แล้วใน Step 1

---

## 10. Move Impact Matrix

### 10.1 ย้าย `World`

| Node | กระทบ | เงื่อนไข |
|---|---|---|
| ArenaManager | ต่ำ-กลาง | ต้องดูว่า `ArenaBackground` ถูกสร้างใต้ parent ใหม่แล้ว layer ยังถูก |
| ArenaVisualManager | ต่ำ | สร้าง visual ภายในตัวเอง |
| GameCamera | ต่ำ | ใช้ group `game_camera` |

### 10.2 ย้าย `Actors`

| Node | กระทบ | เงื่อนไข |
|---|---|---|
| Player ทั้งก้อน | กลาง | ห้ามแยกลูกภายใน Player |
| BossBrokenMaster ทั้งก้อน | กลาง | ต้องแก้ Boss หา Player ผ่าน group ก่อน |

### 10.3 ย้าย `UI`

| Node | กระทบ | เงื่อนไข |
|---|---|---|
| HUD | สูงถ้ายังไม่แก้ Player lookup | ต้องหา Player ผ่าน group ได้ก่อน |
| TouchControls | สูงถ้ายังไม่แก้ Player lookup | ต้องหา Player ผ่าน group ได้ก่อน |
| TrainingCoachManager | กลาง | ต้องมี group fallback สำหรับ Player/Boss/GameLoop |
| Duel1IntroManager | กลาง-สูง | ต้องมี group fallback ครบ |
| Duel1DummyManager | กลาง-สูง | ต้องมี group fallback ครบ |

### 10.4 ย้าย `GameFlow`

| Node | กระทบ | เงื่อนไข |
|---|---|---|
| GameLoopManager | กลาง-สูง | ต้องหา Player/Boss/TouchControls ผ่าน group ได้ |
| BossFightHintCleanupManager | กลาง | ต้องหา Boss/Duel1/GameLoop ผ่าน group ได้ |
| RunMetricsManager | กลาง | ต้องหา Boss/GameLoop ผ่าน group ได้ |

### 10.5 ย้าย `CombatSystems`

| Node | กระทบ | เงื่อนไข |
|---|---|---|
| KeyboardTapDeflectManager | กลาง | ต้องหา Player ผ่าน group ได้ |
| MovementDeflectBalanceManager | กลาง | ต้องหา Player ผ่าน group ได้ |
| BossGrabBalanceManager | สูง | ต้องหา Player/Boss/GameLoop/Duel1 ผ่าน group ได้ |
| CombatDecayManager | กลาง | ต้องหา Player/Boss ผ่าน group ได้ |
| PlayerAttackVFXManager | สูง | ต้องกำหนด VFX parent ให้ชัด ไม่ใช่ get_parent เสมอ |
| BossDifficultyCurveManager | กลาง | ต้องหา Boss ผ่าน group ได้ |
| BossWeightManager | กลาง | ต้องหา Boss/Player ผ่าน group ได้ |

---

## 11. Do Not Move List

ระหว่างการจัด scene รอบแรก ห้ามย้าย Node ต่อไปนี้แยกจาก parent เดิม:

```text
Player/Sprite2D
Player/AnimatedSprite2D
Player/CollisionShape2D
Player/AttackHitbox
Player/AttackHitbox/CollisionShape2D
Player/Hurtbox
Player/Hurtbox/CollisionShape2D
Player/PlayerSpriteOrientationManager
Player/PlayerAnimatedIdleVisualManager
```

```text
BossBrokenMaster/Sprite2D
BossBrokenMaster/CollisionShape2D
BossBrokenMaster/Hurtbox
BossBrokenMaster/Hurtbox/CollisionShape2D
BossBrokenMaster/AttackHitbox
BossBrokenMaster/AttackHitbox/CollisionShape2D
```

```text
HUD/Control
HUD/Control/VBoxContainer
HUD/Control/VBoxContainer/*Label
HUD/Control/VBoxContainer/*Bar
HUD/Control/GameResultLabel
```

---

## 12. Checklist สำหรับ Step 2 ต่อไป

เมื่อต้องเริ่ม Step 2 ให้ทำตามลำดับนี้:

```text
1. เพิ่ม player_actor group ให้ Player
2. เพิ่ม touch_controls group ให้ TouchControls
3. เพิ่ม game_loop_manager group ให้ GameLoopManager
4. เพิ่ม training_coach_manager group ให้ TrainingCoachManager
5. เพิ่ม duel_1_intro_manager group ให้ Duel1IntroManager
6. เพิ่ม duel_1_manager group ให้ Duel1DummyManager
7. ยังไม่ย้าย Node
8. ยังไม่แก้ gameplay behavior
9. ทดสอบเกมใน flat scene เดิม
```

ถัดจากนั้นเข้าสู่ Step 3:

```text
1. แก้ BossBrokenMaster.gd ให้หา Player แบบ NodePath/group/parent fallback
2. แก้ HUD.gd ให้หา Player แบบ NodePath/group/parent fallback
3. แก้ TouchControls.gd ให้หา Player แบบ NodePath/group/parent fallback
4. ทดสอบ full loop
```

---

## 13. Smoke Test หลัง Step 1

เพราะ Step 1 เป็นเอกสารอย่างเดียว จึงไม่ควรกระทบ runtime

Checklist ขั้นต่ำ:

```text
1. เปิด Godot ได้
2. เปิด main scene ได้
3. ไม่มีไฟล์ script หรือ scene ถูกแก้
4. เกมควรทำงานเหมือนเดิม 100%
```

---

## 14. สรุปผล Step 1

Step 1 เสร็จสมบูรณ์เมื่อมีเอกสาร inventory ที่ตอบคำถามต่อไปนี้ได้:

```text
1. main scene อ้าง script อะไรบ้าง
2. script ใดหา Node ด้วย NodePath
3. script ใดหา Node ด้วย get_parent()
4. script ใดหา Node ด้วย group
5. script ใดใช้ $ChildPath ภายใน subtree ของตัวเอง
6. ถ้าย้าย Node ต้องแก้จุดไหนก่อน
7. Node ใดห้ามแยกจาก parent เดิม
8. กลุ่มใดควรย้ายก่อน/หลัง
```

คำตอบเชิงยุทธศาสตร์จาก inventory นี้คือ:

```text
ทำ Group Identity และ Robust Lookup ก่อน
ยังไม่ย้าย Node
และต้องแก้ HUD / TouchControls / BossBrokenMaster ก่อนเริ่ม Scene Organization จริง
```
