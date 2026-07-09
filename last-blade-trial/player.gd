extends CharacterBody2D

# ส่งสัญญาณไปให้ HUD ทุกครั้งที่ HP, Stamina, Focus หรือ Player Posture เปลี่ยน
signal stats_changed(
	current_hp: int,
	max_hp: int,
	current_stamina: float,
	max_stamina: float,
	current_focus: float,
	max_focus: float,
	current_player_posture: float,
	max_player_posture: float
)

# ส่งสัญญาณเมื่อ Player ตาย เพื่อให้ HUD หรือ Main แสดง Game Over
signal player_died

# =========================
# ค่าพื้นฐานของผู้เล่น
# =========================

# ความเร็วในการเดินปกติ
@export var speed: float = 150.0

# ความเร็วตอน Dash
@export var dash_speed: float = 500.0

# ระยะเวลาที่ Dash มีผล
@export var dash_time: float = 0.4

# เวลารอหลัง Dash ก่อนจะ Dash ได้อีกครั้ง
@export var dash_cooldown: float = 0.45

# ดาเมจที่ผู้เล่นทำได้เมื่อโจมตีโดนศัตรู
@export var attack_damage: int = 10

# เลือดสูงสุดของผู้เล่น
@export var max_hp: int = 100

# Stamina สูงสุดของผู้เล่น
@export var max_stamina: float = 100.0

# Focus สูงสุดของผู้เล่น
# ใช้สะสมจาก Deflect สำเร็จ เพื่อใช้ Focus Finisher
@export var max_focus: float = 100.0

# ความเร็วในการฟื้น Stamina ต่อวินาที
@export var stamina_regen_rate: float = 20.0

# Stamina ที่ใช้เมื่อโจมตีหนึ่งครั้ง
@export var attack_stamina_cost: float = 18.0

# เปิด/ปิดระบบ 3-hit combo เพื่อ rollback กลับเป็นโจมตีเดี่ยวเดิมได้ทันที
@export var combo_enabled: bool = true

# ค่าบาลานซ์ของแต่ละ hit ในคอมโบ
@export var combo_hit_1_damage: int = 10
@export var combo_hit_2_damage: int = 12
@export var combo_hit_3_damage: int = 18
@export var combo_hit_1_stamina_cost: float = 18.0
@export var combo_hit_2_stamina_cost: float = 18.0
@export var combo_hit_3_stamina_cost: float = 26.0
@export var combo_hit_1_active_time: float = 0.17
@export var combo_hit_2_active_time: float = 0.18
@export var combo_hit_3_active_time: float = 0.22
@export var combo_hit_1_recovery_time: float = 0.22
@export var combo_hit_2_recovery_time: float = 0.28
@export var combo_hit_3_recovery_time: float = 0.78
@export var combo_chain_window: float = 0.35
@export var combo_early_input_buffer_time: float = 0.12
@export var combo_debug_print: bool = true

# =========================
# Player Combat Stance Memory
# =========================

# เปิด/ปิดระบบจำท่าพร้อมสู้ชั่วคราว เพื่อ rollback ได้ง่าย
@export var combat_stance_memory_enabled: bool = true

# เวลาค้างท่าพร้อมสู้หลังจบ Hit 1 / Hit 2 / Hit 3 ตามน้ำหนักของคอมโบ
@export var combat_stance_after_combo_hit_1_time: float = 1.6
@export var combat_stance_after_attack_time: float = 1.8
@export var combat_stance_after_combo_finisher_time: float = 2.4

# เวลาค้างท่าพร้อมสู้หลังเหตุการณ์หนักอื่น ๆ
@export var combat_stance_after_heavy_time: float = 3.0
@export var combat_stance_after_hurt_time: float = 2.5
@export var combat_stance_after_posture_recover_time: float = 3.5

# เปิด/ปิดข้อความ debug ของระบบจำท่าพร้อมสู้
@export var combat_stance_debug_print: bool = false

# Stamina ที่ใช้เมื่อ Dash หนึ่งครั้ง
@export var dash_stamina_cost: float = 30.0

# ค่าเดิมของ Parry ยังเก็บไว้ชั่วคราวเพื่อ compatibility กับระบบเก่า
# ในระบบใหม่ผู้เล่นไม่ได้กดปุ่ม Parry แล้ว แต่ใช้ Movement Deflect / Tap Deflect แทน
@export var parry_stamina_cost: float = 20.0

# จำนวน Focus ที่ได้รับเมื่อ Deflect สำเร็จ
# ลดจากระบบ Parry เดิม เพราะ Deflect จาก joystick ทำได้ง่ายขึ้นบนมือถือ
@export var focus_gain_on_successful_parry: float = 8.0

# Focus ที่ต้องใช้เพื่อทำ Finisher
@export var focus_finisher_cost: float = 100.0

# สัดส่วนดาเมจของ Finisher เทียบกับ HP สูงสุดของศัตรู
# 0.40 = 40% ของ HP สูงสุดศัตรู
@export var focus_finisher_damage_ratio: float = 0.40

# ค่าเดิมของ Parry Active Time เก็บไว้เพื่อ compatibility เท่านั้น
@export var parry_active_time: float = 0.45

# ค่าเดิมของ Parry Recovery Time เก็บไว้เพื่อ compatibility เท่านั้น
@export var parry_recovery_time: float = 0.1

# ระยะเวลาที่ Hitbox ของดาบเปิดตอนโจมตี
@export var attack_active_time: float = 0.18

# เวลาหน่วงหลังโจมตี ก่อนจะขยับหรือโจมตีใหม่ได้
@export var attack_recovery_time: float = 0.3

# ความแรงกล้องสั่นเมื่อ Player โดนโจมตี
@export var player_hit_camera_shake_strength: float = 7.0

# ระยะเวลากล้องสั่นเมื่อ Player โดนโจมตี
@export var player_hit_camera_shake_duration: float = 0.15

# ความแรงที่ Player จะกระเด็นเมื่อโดนศัตรูโจมตี
@export var player_knockback_force: float = 260.0

# ระยะเวลาที่ Player จะถูก Knockback
@export var player_knockback_time: float = 0.14

# ระยะเวลาอมตะหลัง Player โดนโจมตี
# ป้องกันไม่ให้โดนดาเมจซ้ำติด ๆ กัน
@export var hurt_invincible_time: float = 0.65

# =========================
# Lock-on System
# =========================

# เปิด/ปิดระบบ Lock-on
@export var target_lock_enabled: bool = true

# ระยะสูงสุดที่ยังยอมให้ Lock-on ทำงาน ถ้า Boss ไกลเกินไปจะปลดล็อคเอง
@export var target_lock_max_distance: float = 1400.0

# เปิด/ปิดข้อความ debug ของ Lock-on
@export var target_lock_debug_print: bool = true

# =========================
# Movement / Tap Deflect System
# =========================

# เปิด/ปิดระบบ Deflect จาก joystick
@export var movement_deflect_enabled: bool = true

# ช่วงเวลาหลังเริ่มโยกซ้าย/ขวาที่ถือว่ายัง Deflect ได้
@export var movement_deflect_window: float = 0.6

# ช่วงเวลาหลังแตะ joystick ที่ถือว่ายัง Deflect ได้โดยไม่ต้องเดิน
@export var tap_deflect_window: float = 0.4

# ถ้า true จะไม่ให้กด movement ค้างเพื่อ Deflect ฟรี ต้องเป็นจังหวะเริ่มโยกหรือเปลี่ยนทิศเท่านั้น
@export var movement_deflect_requires_new_input: bool = true

# ข้อความ feedback เมื่อ Deflect สำเร็จ
@export var movement_deflect_feedback_text: String = "DEFLECT!"

# ขนาดตัวอักษร feedback เมื่อ Deflect สำเร็จ
@export var movement_deflect_feedback_font_size: int = 28

# ระยะเวลาที่ feedback Deflect ลอยขึ้นและจางหาย
@export var movement_deflect_feedback_duration: float = 0.28

# =========================
# Player Posture System
# =========================

# Posture สูงสุดของผู้เล่น ใช้จำกัดการ Deflect ไม่ให้ฟรีเกินไป
@export var max_player_posture: float = 100.0

# ความเร็วในการฟื้น Player Posture ต่อวินาที
@export var player_posture_regen_rate: float = 5.0

# Posture ที่เสียเมื่อ Deflect จากการโยกซ้าย/ขวาสำเร็จ
@export var posture_damage_on_deflect: float = 14.0

# Posture ที่เสียเมื่อ Tap Deflect สำเร็จ
# Tap Deflect ใช้ง่ายกว่า จึงเสีย Posture มากกว่าเล็กน้อย
@export var posture_damage_on_tap_deflect: float = 16.0

# ตัวคูณ Posture damage จากการโดนดาเมจจริง
@export var posture_damage_from_hit_multiplier: float = 1.6

# เวลาที่ Player ชะงักเมื่อ Posture แตก
@export var player_posture_break_time: float = 3.0

# สัดส่วน Posture ที่คืนให้หลังฟื้นจาก Posture Break
@export var posture_recover_ratio_after_break: float = 0.55

# ข้อความ feedback เมื่อ Player Posture แตก
@export var posture_break_feedback_text: String = "POSTURE BROKEN!"

# ขนาดตัวอักษร feedback เมื่อ Player Posture แตก
@export var posture_break_feedback_font_size: int = 28

# =========================
# Dash Landing Risk
# =========================

# ช่วงเวลาหลัง Dash จบที่ Boss สามารถมองว่า Player เสี่ยงโดน Grab ได้
@export var dash_landing_risk_window: float = 0.35

# =========================
# Dash Trail Placeholder
# =========================

# เปิด/ปิดเงาจางตอน Dash
@export var dash_trail_enabled: bool = true

# จำนวนเงาที่จะทิ้งไว้ระหว่าง Dash
@export var dash_trail_count: int = 3

# เวลาห่างระหว่างเงาแต่ละชุด
@export var dash_trail_spawn_interval: float = 0.045

# ระยะเวลาที่เงาแต่ละชุดจางหาย
@export var dash_trail_fade_time: float = 0.18

# ความโปร่งใสเริ่มต้นของเงา Dash
@export var dash_trail_start_alpha: float = 0.35

# =========================
# Stamina Feedback Placeholder
# =========================

# เปิด/ปิดข้อความแจ้งเตือนเมื่อ Stamina ไม่พอ
@export var stamina_feedback_enabled: bool = true

# ข้อความหลักที่แสดงเมื่อ Stamina ไม่พอ
@export var stamina_feedback_text: String = "NO STAMINA!"

# ขนาดตัวอักษรของข้อความ Stamina ไม่พอ
@export var stamina_feedback_font_size: int = 24

# ระยะเวลาที่ข้อความลอยขึ้นและจางหาย
@export var stamina_feedback_duration: float = 0.35

# สีของข้อความ Stamina ไม่พอ
@export var stamina_feedback_color: Color = Color(1.0, 0.35, 0.10, 1.0)

# =========================
# Focus Ready Feedback Placeholder
# =========================

# เปิด/ปิดข้อความแจ้งเตือนเมื่อ Focus เต็มและพร้อมใช้ Finisher
@export var focus_ready_feedback_enabled: bool = true

# ข้อความหลักที่แสดงเมื่อ Focus เต็ม
@export var focus_ready_feedback_text: String = "FINISHER READY!"

# ขนาดตัวอักษรของข้อความ Focus พร้อมใช้
@export var focus_ready_feedback_font_size: int = 28

# ระยะเวลาที่ข้อความ Focus พร้อมใช้ลอยขึ้นและจางหาย
@export var focus_ready_feedback_duration: float = 0.55

# สีของข้อความ Focus พร้อมใช้
@export var focus_ready_feedback_color: Color = Color(1.0, 0.75, 0.15, 1.0)

# =========================
# อ้างอิง Node ต่าง ๆ
# =========================

# Sprite2D ใช้แสดงภาพตัวละคร และใช้ flip ซ้าย/ขวา
@onready var sprite_2d: Sprite2D = $Sprite2D

# AttackHitbox คือพื้นที่โจมตีของผู้เล่น
@onready var attack_hitbox: Area2D = $AttackHitbox

# CollisionShape2D ของ AttackHitbox ใช้เปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

# Hurtbox คือพื้นที่ที่ Player รับดาเมจจากศัตรู
@onready var hurtbox: Area2D = $Hurtbox

# CollisionShape2D ของ Hurtbox ใช้เปิด/ปิดการรับดาเมจ
# ตอน Dash เราจะปิดชั่วคราวเพื่อจำลอง i-frame
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

# =========================
# ตัวแปรสถานะ
# =========================

# เลือดปัจจุบันของผู้เล่น
var current_hp: int

# Stamina ปัจจุบันของผู้เล่น
var current_stamina: float

# Focus ปัจจุบันของผู้เล่น
var current_focus: float

# Player Posture ปัจจุบัน
var current_player_posture: float

# ใช้เช็กว่าผู้เล่นกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ใช้เช็กว่าผู้เล่นกำลัง Dash อยู่หรือไม่
var is_dashing: bool = false

# ใช้เช็กว่า Dash ยังติด cooldown อยู่หรือไม่
var can_dash: bool = true

# ค่าเก่าเก็บไว้เพื่อ compatibility กับ Boss/Tutorial เก่าบางส่วน
var is_parrying: bool = false

# ใช้เช็กว่า Player ตายไปแล้วหรือยัง
var is_dead: bool = false

# ใช้เช็กว่า Player กำลังถูก Knockback อยู่หรือไม่
var is_knocked_back: bool = false

# ใช้เช็กว่า Player กำลังอมตะหลังโดนตีอยู่หรือไม่
var is_hurt_invincible: bool = false

# ใช้เช็กว่า Player กำลัง Posture Broken อยู่หรือไม่
var is_posture_broken: bool = false

# ใช้กันไม่ให้ข้อความ NO STAMINA! ซ้อนกันหลายอันในเวลาเดียวกัน
var is_showing_stamina_feedback: bool = false

# ความเร็ว Knockback ปัจจุบันของ Player
var knockback_velocity: Vector2 = Vector2.ZERO

# ทิศที่ผู้เล่นหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = 1

# ระยะห่างของ Hitbox ดาบจากตัวผู้เล่น
var attack_hitbox_offset_x: float = 55.0

# ใช้เก็บรายชื่อเป้าหมายที่โดนโจมตีไปแล้วในการฟันครั้งนี้
# ป้องกันไม่ให้เป้าหมายตัวเดิมโดนดาเมจซ้ำจากการโจมตีครั้งเดียว
var hit_targets: Array = []

# สถานะของระบบ 3-hit combo
var combo_step: int = 0
var queued_combo_step: int = 0
var combo_input_buffered: bool = false
var combo_input_window_open: bool = false
var is_combo_recovering: bool = false
var combo_sequence_id: int = 0
var current_combo_step_for_damage: int = 0
var last_combo_input_msec: int = -999999

# ใช้เช็กว่าเคยแจ้งเตือน Focus เต็มแล้วหรือยัง
# ป้องกันไม่ให้ print ซ้ำทุกครั้งที่ Focus เปลี่ยน
var has_shown_focus_ready_message: bool = false

# เป้าหมายที่ล็อคอยู่
var locked_target: Node2D = null

# สถานะ Lock-on ปัจจุบัน
var is_target_locked: bool = false

# เวลาที่เกิด movement input ใหม่ล่าสุด ใช้เป็น Movement Deflect window
var last_movement_deflect_msec: int = -999999

# เวลาที่แตะ joystick ล่าสุด ใช้เป็น Tap Deflect window
var last_tap_deflect_msec: int = -999999

# เวลาที่ Dash จบล่าสุด ใช้ให้ Boss อ่าน Dash Landing Risk
var last_dash_end_msec: int = -999999

# เวลาที่ Deflect สำเร็จล่าสุด เผื่อ Boss ใช้ทำ Anti-Repetition Memory ในอนาคต
var last_successful_deflect_msec: int = -999999

# เวลาสิ้นสุดของท่าพร้อมสู้ชั่วคราว หน่วยเป็น milliseconds
var combat_stance_until_msec: int = -999999

# ทิศ movement ล่าสุดที่ใช้ trigger Deflect
var last_movement_deflect_direction: int = 0

# ทิศ movement ใน physics frame ก่อนหน้า ใช้ตรวจ keyboard และ fallback
var previous_axis_direction: int = 0

# ชนิด Deflect ล่าสุดที่ active อยู่ เช่น movement หรือ tap
var last_active_deflect_type: String = ""

# ใช้กัน Deflect feedback ซ้อนกันมากเกินไป
var is_showing_deflect_feedback: bool = false

# =========================
# ระบบ Collision Layer ของตัวละคร
# =========================

# Layer 1 ใช้สำหรับพื้น / กำแพง / ขอบสนาม
const WORLD_BODY_LAYER: int = 1

# Layer 2 ใช้สำหรับตัว Player
const PLAYER_BODY_LAYER: int = 2

# Layer 3 ใช้สำหรับตัว Enemy / Boss
const ENEMY_BODY_LAYER: int = 4

# ตอนปกติ Player ต้องชน World และ Enemy
const PLAYER_NORMAL_COLLISION_MASK: int = WORLD_BODY_LAYER | ENEMY_BODY_LAYER

# ตอน Dash Player จะชนเฉพาะ World
# ทำให้ Dash ผ่าน Enemy ได้ แต่ยังไม่ทะลุขอบสนามในอนาคต
const PLAYER_DASH_COLLISION_MASK: int = WORLD_BODY_LAYER

# =========================
# ขอบเขตสนามแบบง่าย
# =========================

# ขอบซ้ายของสนาม
@export var arena_min_x: float = 120.0

# ขอบขวาของสนาม
@export var arena_max_x: float = 1030.0

# อ้างอิง ArenaManager ถ้ามีในฉาก
var arena_manager: Node = null


func _ready() -> void:
	# ตั้ง Layer ของ Player ให้เป็น Layer Player
	collision_layer = PLAYER_BODY_LAYER

	# ตอนปกติ Player ต้องชนทั้งขอบสนาม/พื้น และตัวศัตรู
	collision_mask = PLAYER_NORMAL_COLLISION_MASK

	# หา ArenaManager จาก group
	# ถ้ามี จะใช้ขอบสนามจาก ArenaManager แทนค่าที่ตั้งใน Player
	var arena_nodes := get_tree().get_nodes_in_group("arena_manager")
	if arena_nodes.size() > 0:
		arena_manager = arena_nodes[0]
		print("Player found ArenaManager")
	else:
		print("Player using fallback arena bounds")

	# ตั้งเลือด / Stamina / Focus / Posture เริ่มต้น
	current_hp = max_hp
	current_stamina = max_stamina
	current_focus = 0.0
	current_player_posture = max_player_posture
	clear_combat_stance_memory("ready")

	# ปิด Hitbox ดาบไว้ก่อน เพราะยังไม่ได้โจมตี
	attack_shape.disabled = true

	# เปิด Hurtbox ไว้ตามปกติ เพื่อให้ Player รับดาเมจได้
	hurtbox_shape.disabled = false

	# วาง Hitbox ดาบไว้ด้านหน้าตามทิศที่ผู้เล่นหัน
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ไปชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Player ready. HP =", current_hp, "Stamina =", current_stamina, "Posture =", current_player_posture)

	# ส่งค่าเริ่มต้นไปให้ HUD แสดงผล
	emit_stats()


func enter_combat_stance_for(duration: float, reason: String = "") -> void:
	# ต่อเวลาท่าพร้อมสู้ไปข้างหน้า โดยไม่ลดเวลาที่เหลืออยู่เดิม
	if not combat_stance_memory_enabled:
		return

	if duration <= 0.0:
		return

	if is_dead:
		return

	var now_msec := Time.get_ticks_msec()
	var requested_until_msec := now_msec + int(round(duration * 1000.0))
	combat_stance_until_msec = maxi(combat_stance_until_msec, requested_until_msec)

	if combat_stance_debug_print:
		print("Combat stance memory:", reason, "until", combat_stance_until_msec)


func is_combat_stance_memory_active() -> bool:
	# ให้ visual manager ใช้เช็กว่าควรเลือก combat_idle เมื่อ Player หยุดนิ่งหรือไม่
	if not combat_stance_memory_enabled:
		return false

	if is_dead:
		return false

	return Time.get_ticks_msec() <= combat_stance_until_msec


func clear_combat_stance_memory(reason: String = "") -> void:
	# ล้างสถานะเพื่อให้เริ่ม Duel หรือหลังตายกลับไป idle ปกติเสมอ
	combat_stance_until_msec = -999999

	if combat_stance_debug_print and reason != "":
		print("Combat stance memory cleared:", reason)


func get_combat_stance_duration_for_combo_step(step: int) -> float:
	# เลือกระยะเวลาตามน้ำหนักของ hit ที่จบล่าสุด
	match step:
		1:
			return combat_stance_after_combo_hit_1_time
		2:
			return combat_stance_after_attack_time
		3:
			return combat_stance_after_combo_finisher_time
		_:
			return combat_stance_after_attack_time


func _physics_process(delta: float) -> void:
	# ฟื้น Stamina และ Player Posture ทุกเฟรม
	regenerate_stamina(delta)
	regenerate_player_posture(delta)

	# รองรับปุ่ม Lock-on บน keyboard เช่น L
	if Input.is_action_just_pressed("lock_on"):
		toggle_target_lock()

	# ถ้า Player ตายแล้ว ไม่ต้องควบคุมต่อ
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ถ้า Player Posture แตก ให้หยุดควบคุมชั่วคราว
	if is_posture_broken:
		velocity = Vector2.ZERO
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้า Player กำลังถูก Knockback ให้ขยับตามแรงกระเด็น
	if is_knocked_back:
		velocity = knockback_velocity
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้ากำลัง Dash อยู่ ให้เคลื่อนที่ด้วยความเร็ว Dash
	# ระหว่าง Dash ไม่อัปเดต Lock-on facing เพื่อไม่ให้ Dash กลับทิศกลางทาง
	if is_dashing:
		velocity.x = float(facing_direction) * dash_speed
		velocity.y = 0.0
		move_and_slide()
		clamp_to_arena()
		return

	# รับค่าการกดปุ่มซ้าย/ขวา จาก ui_left และ ui_right
	var direction := Input.get_axis("ui_left", "ui_right")
	var axis_direction := int(sign(direction))
	track_movement_deflect_from_axis(axis_direction)

	# ถ้ากำลังโจมตี ให้หยุดขยับชั่วคราว
	if is_attacking:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	velocity.y = 0.0
	move_and_slide()
	clamp_to_arena()

	# จัดทิศหันหน้าตาม Lock-on หรือ movement ปกติ
	if is_target_locked:
		update_facing_to_locked_target()
	elif direction != 0.0 and not is_attacking:
		set_facing_direction(axis_direction)

	# ถ้ากดปุ่ม attack ให้ส่งเข้า entry point ของระบบโจมตี
	# ตอนว่างจะเริ่ม Hit 1 ส่วนตอนกำลังโจมตีจะพยายาม queue hit ถัดไปใน combo window
	if Input.is_action_just_pressed("attack") and not is_dashing and not is_posture_broken:
		attack()

	# ถ้ากดปุ่ม dash และตอนนี้ไม่ได้ทำ action อื่น ให้ Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_attacking and not is_dashing and not is_posture_broken:
		if is_target_locked:
			update_facing_to_locked_target()
		dash()

	# ไม่รับ input parry โดยตรงแล้ว ระบบใหม่ใช้ Movement/Tap Deflect แทน


func emit_stats() -> void:
	# ส่งค่า HP, Stamina, Focus และ Player Posture ปัจจุบันออกไปให้ HUD
	stats_changed.emit(
		current_hp,
		max_hp,
		current_stamina,
		max_stamina,
		current_focus,
		max_focus,
		current_player_posture,
		max_player_posture
	)


func set_facing_direction(new_direction: int) -> void:
	# ตั้งทิศหันหน้าและย้าย hitbox ดาบให้ตรงกับทิศนั้น
	if new_direction == 0:
		return

	facing_direction = new_direction
	if is_instance_valid(sprite_2d):
		sprite_2d.flip_h = facing_direction < 0
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)


func find_lock_target() -> Node2D:
	# หา Boss หรือศัตรูหลักจาก group combat_target เพื่อลดการ hardcode ชื่อ node
	var targets := get_tree().get_nodes_in_group("combat_target")
	for target in targets:
		if target is Node2D and is_instance_valid(target):
			return target as Node2D

	# fallback เผื่อ scene บางชุดยังใช้ชื่อ node ตรง
	if get_parent() != null:
		var boss := get_parent().get_node_or_null("BossBrokenMaster") as Node2D
		if boss != null:
			return boss

	return null


func toggle_target_lock() -> void:
	# เปิด/ปิด Lock-on ตามสถานะปัจจุบัน
	if not target_lock_enabled:
		return

	if is_target_locked:
		clear_target_lock()
		return

	locked_target = find_lock_target()
	if locked_target == null:
		print("Lock-on failed: no combat target")
		return

	is_target_locked = true
	update_facing_to_locked_target()

	if target_lock_debug_print:
		print("Target Lock ON:", locked_target.name)


func clear_target_lock() -> void:
	# ปลด Lock-on อย่างปลอดภัย
	if target_lock_debug_print and is_target_locked:
		print("Target Lock OFF")

	is_target_locked = false
	locked_target = null


func is_target_lock_active() -> bool:
	# ให้ TouchControls อ่านสถานะไปอัปเดตปุ่ม LOCK/LOCKED
	return is_target_locked


func update_facing_to_locked_target() -> void:
	# ถ้า Lock-on เปิดอยู่ ให้หันหน้าเข้าหาเป้าหมายเสมอ
	if not is_target_locked:
		return

	if not is_instance_valid(locked_target):
		clear_target_lock()
		return

	if global_position.distance_to(locked_target.global_position) > target_lock_max_distance:
		clear_target_lock()
		return

	var target_direction := int(sign(locked_target.global_position.x - global_position.x))
	if target_direction != 0:
		set_facing_direction(target_direction)


func track_movement_deflect_from_axis(axis_direction: int) -> void:
	# ตรวจ movement จาก keyboard หรือ fallback
	# TouchControls จะเรียก register_movement_deflect_input() โดยตรงด้วยเมื่อ joystick เปลี่ยนทิศ
	if axis_direction != 0 and axis_direction != previous_axis_direction:
		register_movement_deflect_input(axis_direction)

	previous_axis_direction = axis_direction


func register_movement_deflect_input(direction: int) -> void:
	# บันทึกจังหวะเริ่มโยกหรือเปลี่ยนทิศ เพื่อใช้เป็น Movement Deflect window
	if not movement_deflect_enabled:
		return

	if direction == 0:
		return

	if movement_deflect_requires_new_input and direction == last_movement_deflect_direction:
		return

	last_movement_deflect_direction = direction
	last_movement_deflect_msec = Time.get_ticks_msec()


func register_tap_deflect_input() -> void:
	# บันทึกจังหวะแตะ joystick 1 ครั้ง เพื่อให้ Deflect ได้โดยไม่ต้องเดิน
	# ฟังก์ชันนี้ต้องถูกเรียกเฉพาะตอน touch pressed / mouse pressed เท่านั้น ห้ามเรียกทุก frame ระหว่างแตะค้าง
	if not movement_deflect_enabled:
		return

	last_tap_deflect_msec = Time.get_ticks_msec()
	last_active_deflect_type = "tap"


func get_active_deflect_type() -> String:
	# คืนชนิด Deflect ที่ยังอยู่ใน window ปัจจุบัน
	# ถ้า Tap และ Movement active พร้อมกัน ให้เลือกอันที่เกิดล่าสุด
	if not movement_deflect_enabled:
		return ""

	if is_dead or is_attacking or is_dashing or is_posture_broken or is_knocked_back:
		return ""

	if current_player_posture <= 0.0:
		return ""

	var now_msec := Time.get_ticks_msec()
	var movement_elapsed_sec := float(now_msec - last_movement_deflect_msec) / 1000.0
	var tap_elapsed_sec := float(now_msec - last_tap_deflect_msec) / 1000.0
	var movement_active := movement_elapsed_sec <= movement_deflect_window
	var tap_active := tap_elapsed_sec <= tap_deflect_window

	if tap_active and movement_active:
		if last_tap_deflect_msec >= last_movement_deflect_msec:
			return "tap"
		return "movement"

	if tap_active:
		return "tap"

	if movement_active:
		return "movement"

	return ""


func is_movement_deflect_active() -> bool:
	# ใช้แทน Parry เดิม: ถ้ามี Tap หรือ Movement Deflect active ให้ถือว่าพร้อม Deflect
	last_active_deflect_type = get_active_deflect_type()
	return last_active_deflect_type != ""


func clear_deflect_windows_after_success() -> void:
	# ล้าง window หลัง Deflect สำเร็จ เพื่อไม่ให้ tap/movement ครั้งเดียวถูกใช้ซ้ำในเหตุการณ์ถัดไป
	last_movement_deflect_msec = -999999
	last_tap_deflect_msec = -999999
	last_active_deflect_type = ""


func get_time_since_last_dash_end() -> float:
	# คืนเวลาหลัง Dash จบล่าสุดเป็นวินาที ถ้ายังไม่เคย Dash จะคืนค่าสูงมาก
	return float(Time.get_ticks_msec() - last_dash_end_msec) / 1000.0


func is_in_dash_landing_risk_window() -> bool:
	# ให้ Boss ใช้ตรวจว่า Player เพิ่ง Dash จบและเสี่ยงโดน Grab หรือไม่
	return get_time_since_last_dash_end() <= dash_landing_risk_window


func get_time_since_last_successful_deflect() -> float:
	# เผื่อ Boss ใช้ทำ Anti-Repetition Memory ในอนาคต
	return float(Time.get_ticks_msec() - last_successful_deflect_msec) / 1000.0


func gain_focus(amount: float) -> void:
	# เก็บค่าเดิมไว้ก่อน เพื่อเช็กว่าค่าเปลี่ยนหรือไม่
	var old_focus: float = current_focus

	# เพิ่ม Focus และไม่ให้เกิน max_focus
	current_focus += amount
	current_focus = clamp(current_focus, 0.0, max_focus)

	# ถ้า Focus เต็มครั้งแรก ให้แจ้งผู้เล่นทั้งใน console และบนจอ
	if current_focus >= max_focus and not has_shown_focus_ready_message:
		has_shown_focus_ready_message = true
		print("FOCUS READY! Break boss posture, then press Attack for Finisher.")
		show_focus_ready_feedback()

	print("Focus gained:", int(amount), "Focus =", int(current_focus), "/", int(max_focus))

	# ถ้า Focus เปลี่ยน ให้แจ้ง HUD
	if int(old_focus) != int(current_focus):
		emit_stats()


func has_enough_focus_for_finisher() -> bool:
	# เช็กว่า Focus มีพอสำหรับใช้ Finisher หรือไม่
	return current_focus >= focus_finisher_cost


func spend_focus(amount: float) -> void:
	# ลด Focus ตามจำนวนที่ใช้
	current_focus -= amount
	current_focus = clamp(current_focus, 0.0, max_focus)

	# เมื่อใช้ Focus ไปแล้ว อนุญาตให้แจ้งเตือน READY ได้อีกครั้งในรอบถัดไป
	if current_focus < max_focus:
		has_shown_focus_ready_message = false

	print("Focus spent:", int(amount), "Focus =", int(current_focus), "/", int(max_focus))
	emit_stats()


func show_focus_ready_feedback() -> void:
	# ถ้าปิด feedback ไว้ หรือตัวละครตายแล้ว ไม่ต้องแสดงข้อความ
	if not focus_ready_feedback_enabled:
		return

	if is_dead:
		return

	# สร้าง Label ชั่วคราวเหนือหัว Player เพื่อบอกว่า Focus พร้อมใช้ Finisher แล้ว
	var popup := Label.new()
	popup.text = focus_ready_feedback_text
	popup.modulate = focus_ready_feedback_color
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 190
	popup.scale = Vector2(0.75, 0.75)
	popup.add_theme_font_size_override("font_size", focus_ready_feedback_font_size)

	# เพิ่ม popup เข้า parent เดียวกับ Player เพื่อใช้ global_position ได้ง่าย
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-115.0, -125.0)

	# เปลี่ยนสี Player เป็นสีทองสั้น ๆ เพื่อให้รู้ว่าเข้าสู่สถานะพร้อมใช้ท่าใหญ่
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color(1.0, 0.75, 0.15, 1.0)

	# สั่นกล้องเบา ๆ เพื่อให้ Focus เต็มรู้สึกมีน้ำหนัก แต่ไม่รบกวนจังหวะต่อสู้
	get_tree().call_group("game_camera", "shake", 4.0, 0.10)

	# ทำให้ข้อความขยายขึ้น ลอยขึ้น และจางหาย
	var target_position: Vector2 = popup.global_position + Vector2(0.0, -36.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "scale", Vector2(1.05, 1.05), focus_ready_feedback_duration)
	tween.tween_property(popup, "global_position", target_position, focus_ready_feedback_duration)
	tween.tween_property(popup, "modulate:a", 0.0, focus_ready_feedback_duration)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))

	# รอให้เห็น feedback ก่อนคืนสี Player ถ้าไม่มีสถานะอื่นครอบอยู่
	await get_tree().create_timer(focus_ready_feedback_duration).timeout

	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE


func play_focus_finisher_feedback() -> void:
	# ถ้า Player ตายแล้ว ไม่ต้องเล่น feedback
	if is_dead:
		return

	# เปลี่ยนสีผู้เล่นเป็นสีส้มทองชั่วคราว เพื่อบอกว่ากำลังใช้ Focus Finisher
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color(1.0, 0.75, 0.15, 1.0)

	# สั่นกล้องแรงกว่าการโจมตีปกติเล็กน้อย
	get_tree().call_group("game_camera", "shake", 10.0, 0.20)

	await get_tree().create_timer(0.12).timeout

	# ถ้ายังอยู่ในเกม ให้คืนสีปกติ
	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE


func regenerate_stamina(delta: float) -> void:
	# เก็บค่าเดิมไว้ก่อน เพื่อเช็กว่าค่าเปลี่ยนหรือไม่
	var old_stamina := current_stamina

	# ถ้า Stamina ยังไม่เต็ม ให้ค่อย ๆ ฟื้นตามเวลา
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta
		current_stamina = clamp(current_stamina, 0.0, max_stamina)

	# ถ้าค่า Stamina เปลี่ยนในระดับจำนวนเต็ม ให้ส่งค่าไปอัปเดต HUD
	if int(old_stamina) != int(current_stamina):
		emit_stats()


func regenerate_player_posture(delta: float) -> void:
	# Posture ไม่ฟื้นระหว่างตายหรือ Posture Broken
	if is_dead or is_posture_broken:
		return

	var old_posture := current_player_posture

	if current_player_posture < max_player_posture:
		current_player_posture += player_posture_regen_rate * delta
		current_player_posture = clamp(current_player_posture, 0.0, max_player_posture)

	if int(old_posture) != int(current_player_posture):
		emit_stats()


func apply_player_posture_damage(amount: float, allow_break: bool = true) -> void:
	# ลด Player Posture และสั่ง Posture Break หากหมด
	if is_dead:
		return

	if amount <= 0.0:
		return

	current_player_posture -= amount
	current_player_posture = clamp(current_player_posture, 0.0, max_player_posture)
	print("Player posture:", int(current_player_posture), "/", int(max_player_posture))
	emit_stats()

	if allow_break and current_player_posture <= 0.0:
		start_player_posture_break()


func start_player_posture_break() -> void:
	# เมื่อ Player Posture หมด ให้ชะงักชั่วคราวเพื่อไม่ให้ Deflect ฟรีเกินไป
	if is_posture_broken or is_dead:
		return

	cancel_combo("posture_break")
	is_posture_broken = true
	is_attacking = false
	is_dashing = false
	is_parrying = false
	velocity = Vector2.ZERO
	attack_shape.set_deferred("disabled", true)

	print("Player POSTURE BROKEN!")
	show_posture_break_feedback()
	get_tree().call_group("game_camera", "shake", 8.0, 0.18)

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color(0.85, 0.25, 1.0, 1.0)

	await get_tree().create_timer(player_posture_break_time).timeout

	if is_dead:
		return

	is_posture_broken = false
	current_player_posture = max_player_posture * posture_recover_ratio_after_break
	emit_stats()

	if is_instance_valid(sprite_2d) and not is_hurt_invincible:
		sprite_2d.modulate = Color.WHITE

	enter_combat_stance_for(combat_stance_after_posture_recover_time, "posture_recovered")


func show_posture_break_feedback() -> void:
	# สร้างข้อความเมื่อ Posture แตก
	var popup := Label.new()
	popup.text = posture_break_feedback_text
	popup.modulate = Color(1.0, 0.35, 0.95, 1.0)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 200
	popup.add_theme_font_size_override("font_size", posture_break_feedback_font_size)
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-125.0, -130.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -34.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, player_posture_break_time)
	tween.tween_property(popup, "modulate:a", 0.0, player_posture_break_time)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))


func attack() -> void:
	# entry point เดียวสำหรับระบบโจมตี เพื่อให้ปุ่มเดิมใช้ได้ทั้งโจมตีเดี่ยวและคอมโบ
	if combo_enabled:
		try_attack_input()
		return

	perform_legacy_attack()


func perform_legacy_attack() -> void:
	# ถ้า Stamina ไม่พอ ห้ามโจมตี และแจ้งบนจอทันที
	if current_stamina < attack_stamina_cost:
		print("Not enough stamina to attack. Stamina =", int(current_stamina))
		show_stamina_insufficient_feedback()
		return

	# ใช้ Stamina สำหรับการโจมตี
	current_stamina -= attack_stamina_cost
	print("Attack stamina used. Stamina left =", int(current_stamina))
	emit_stats()

	# เริ่มสถานะโจมตี
	is_attacking = true

	# ล้างรายชื่อเป้าหมายที่เคยโดนจากการฟันครั้งก่อน
	hit_targets.clear()

	print("Player Attack! Hitbox ON")

	# เปิด CollisionShape ของดาบ เพื่อให้ตรวจจับการชนได้
	attack_shape.disabled = false

	# รอช่วงเวลาที่ดาบมีผลจริง
	await get_tree().create_timer(attack_active_time).timeout

	# ปิด Hitbox ดาบหลังหมดจังหวะโจมตี
	attack_shape.disabled = true
	print("Hitbox OFF")

	# รอ recovery เพื่อให้โจมตีมีจังหวะ ไม่รัวเกินไป
	await get_tree().create_timer(attack_recovery_time).timeout

	# จบสถานะโจมตี
	is_attacking = false
	enter_combat_stance_for(combat_stance_after_attack_time, "legacy_attack_finished")
	if is_target_locked:
		update_facing_to_locked_target()


func try_attack_input() -> void:
	# รับ input โจมตีจากทั้ง keyboard และ touch แล้วเลือกว่าจะเริ่มหรือ queue คอมโบ
	if is_dead or is_dashing or is_posture_broken or is_knocked_back:
		return

	if is_attacking:
		queue_next_combo_hit()
		return

	start_combo()


func start_combo() -> void:
	# เริ่มคอมโบจาก Hit 1 เมื่อ Player ว่างและมี stamina พอ
	if current_stamina < get_combo_stamina_cost(1):
		print("Not enough stamina to start combo. Stamina =", int(current_stamina))
		show_stamina_insufficient_feedback()
		return

	combo_sequence_id += 1
	combo_step = 0
	queued_combo_step = 0
	combo_input_buffered = false
	combo_input_window_open = false
	is_combo_recovering = false
	current_combo_step_for_damage = 0

	perform_combo_sequence(combo_sequence_id)


func queue_next_combo_hit() -> void:
	# Hit 3 ไม่มีท่าถัดไป และไม่รับ cancel ผ่านปุ่มโจมตี
	if combo_step >= 3:
		return

	var next_step := combo_step + 1
	if next_step < 2 or next_step > 3:
		return

	last_combo_input_msec = Time.get_ticks_msec()

	if combo_input_window_open:
		queued_combo_step = next_step
		combo_input_buffered = false
		if combo_debug_print:
			print("Combo queued Hit", next_step)
		return

	# กดเร็วเกิน window ให้ buffer สั้น ๆ เพื่อให้ touch/mobile ไม่แข็งเกินไป
	combo_input_buffered = true
	if combo_debug_print:
		print("Combo input buffered for Hit", next_step)


func perform_combo_sequence(sequence_id: int) -> void:
	var next_step := 1
	while next_step >= 1 and next_step <= 3:
		var performed_step: int = next_step
		next_step = await perform_combo_hit(performed_step, sequence_id)
		if not is_combo_sequence_current(sequence_id):
			return

	finish_combo(sequence_id)


func perform_combo_hit(step: int, sequence_id: int) -> int:
	if not can_continue_combo_sequence(sequence_id):
		return 0

	var stamina_cost := get_combo_stamina_cost(step)
	if current_stamina < stamina_cost:
		print("Not enough stamina for combo Hit", step, ". Stamina =", int(current_stamina))
		show_stamina_insufficient_feedback()
		return 0

	current_stamina -= stamina_cost
	emit_stats()

	is_attacking = true
	is_combo_recovering = false
	combo_input_window_open = false
	combo_input_buffered = false
	queued_combo_step = 0
	combo_step = step
	current_combo_step_for_damage = step
	hit_targets.clear()

	if combo_debug_print:
		print("Player Combo Hit", step, "Damage =", get_combo_damage(step), "Stamina left =", int(current_stamina))

	attack_shape.disabled = false

	await get_tree().create_timer(get_combo_active_time(step)).timeout
	if not is_combo_sequence_current(sequence_id):
		return 0

	attack_shape.disabled = true
	is_combo_recovering = true

	var next_step := await wait_for_combo_recovery_or_chain(step, sequence_id)
	return next_step


func wait_for_combo_recovery_or_chain(step: int, sequence_id: int) -> int:
	if not is_combo_sequence_current(sequence_id):
		return 0

	var recovery_time := get_combo_recovery_time(step)
	var chain_time := 0.0
	if step < 3:
		chain_time = combo_chain_window
		combo_input_window_open = true
		consume_buffered_combo_input_if_valid(step)

	var wait_time: float = maxf(recovery_time, chain_time)
	if wait_time > 0.0:
		await get_tree().create_timer(wait_time).timeout

	if not is_combo_sequence_current(sequence_id):
		return 0

	combo_input_window_open = false
	is_combo_recovering = false

	if queued_combo_step == step + 1 and queued_combo_step <= 3:
		return queued_combo_step

	return 0


func consume_buffered_combo_input_if_valid(step: int) -> void:
	if not combo_input_buffered:
		return

	var elapsed := float(Time.get_ticks_msec() - last_combo_input_msec) / 1000.0
	if elapsed <= combo_early_input_buffer_time:
		queued_combo_step = step + 1
		if combo_debug_print:
			print("Combo buffered input consumed for Hit", queued_combo_step)

	combo_input_buffered = false


func finish_combo(sequence_id: int) -> void:
	if not is_combo_sequence_current(sequence_id):
		return

	var finished_combo_step := combo_step
	is_attacking = false
	is_combo_recovering = false
	combo_input_window_open = false
	combo_input_buffered = false
	queued_combo_step = 0
	combo_step = 0
	current_combo_step_for_damage = 0
	hit_targets.clear()
	attack_shape.set_deferred("disabled", true)
	enter_combat_stance_for(get_combat_stance_duration_for_combo_step(finished_combo_step), "combo_finished")

	if is_target_locked:
		update_facing_to_locked_target()


func cancel_combo(reason: String = "") -> void:
	# ใช้ตอนตาย โดนตี posture broken หรือถูก grab เพื่อยกเลิก coroutine เดิมไม่ให้ปลุก hitbox กลับมา
	if combo_step == 0 and not is_attacking and not combo_input_window_open:
		return

	combo_sequence_id += 1
	is_attacking = false
	is_combo_recovering = false
	combo_input_window_open = false
	combo_input_buffered = false
	queued_combo_step = 0
	combo_step = 0
	current_combo_step_for_damage = 0
	hit_targets.clear()
	attack_shape.set_deferred("disabled", true)

	if combo_debug_print and reason != "":
		print("Combo cancelled:", reason)


func is_combo_sequence_current(sequence_id: int) -> bool:
	if not can_continue_combo_sequence(sequence_id):
		return false

	if combo_step <= 0:
		return false

	return true


func can_continue_combo_sequence(sequence_id: int) -> bool:
	if sequence_id != combo_sequence_id:
		return false

	if is_dead or is_dashing or is_posture_broken or is_knocked_back:
		return false

	return true


func get_combo_damage(step: int) -> int:
	match step:
		1:
			return combo_hit_1_damage
		2:
			return combo_hit_2_damage
		3:
			return combo_hit_3_damage
		_:
			return attack_damage


func get_combo_stamina_cost(step: int) -> float:
	match step:
		1:
			return combo_hit_1_stamina_cost
		2:
			return combo_hit_2_stamina_cost
		3:
			return combo_hit_3_stamina_cost
		_:
			return attack_stamina_cost


func get_combo_active_time(step: int) -> float:
	match step:
		1:
			return combo_hit_1_active_time
		2:
			return combo_hit_2_active_time
		3:
			return combo_hit_3_active_time
		_:
			return attack_active_time


func get_combo_recovery_time(step: int) -> float:
	match step:
		1:
			return combo_hit_1_recovery_time
		2:
			return combo_hit_2_recovery_time
		3:
			return combo_hit_3_recovery_time
		_:
			return attack_recovery_time


func start_dash_collision_mode() -> void:
	# ตอน Dash ให้ Player ไม่อยู่บน Layer ปกติชั่วคราว
	# เพื่อไม่ให้ Enemy ที่กำลังชน Player ขวางการ Dash
	collision_layer = 0

	# ตอน Dash ให้ Player ชนเฉพาะ World
	# ดังนั้นจะทะลุศัตรูได้ แต่ยังชนกำแพง/ขอบสนามได้ถ้ามี
	collision_mask = PLAYER_DASH_COLLISION_MASK


func end_dash_collision_mode() -> void:
	# เมื่อ Dash จบ ให้ Player กลับมาอยู่บน Layer Player ตามเดิม
	collision_layer = PLAYER_BODY_LAYER

	# กลับมาชน World และ Enemy ตามปกติ
	collision_mask = PLAYER_NORMAL_COLLISION_MASK


func clamp_to_arena() -> void:
	# ถ้ามี ArenaManager ให้ใช้ค่าขอบสนามจาก ArenaManager
	if is_instance_valid(arena_manager) and arena_manager.has_method("clamp_node_x"):
		arena_manager.clamp_node_x(self)
		return

	# ถ้าไม่มี ArenaManager ให้ใช้ค่าที่ตั้งไว้ใน Player เป็น fallback
	global_position.x = clamp(global_position.x, arena_min_x, arena_max_x)


func dash() -> void:
	# ถ้า Stamina ไม่พอ ห้าม Dash และแจ้งบนจอทันที
	if current_stamina < dash_stamina_cost:
		print("Not enough stamina to dash. Stamina =", int(current_stamina))
		show_stamina_insufficient_feedback()
		return

	# ใช้ Stamina สำหรับ Dash
	current_stamina -= dash_stamina_cost
	print("Dash stamina used. Stamina left =", int(current_stamina))
	emit_stats()

	# เริ่ม Dash
	is_dashing = true

	# สร้าง Dash trail แบบ placeholder เพื่อให้เห็นว่าผู้เล่นพุ่งหลบจริง
	spawn_dash_trail()

	# เปิดโหมด Dash-through ระหว่างนี้ Player จะทะลุตัวศัตรูได้
	start_dash_collision_mode()

	# ปิดการ Dash ซ้ำจนกว่า cooldown จะหมด
	can_dash = false

	# ปิด Hurtbox ชั่วคราว นี่คือ i-frame แบบง่าย ๆ
	hurtbox_shape.disabled = true

	print("Player Dash! Invincible ON")

	# รอระยะเวลาที่ Dash มีผล
	await get_tree().create_timer(dash_time).timeout

	# จบ Dash และบันทึกเวลา landing เพื่อให้ Boss ใช้เลือก Grab ได้
	is_dashing = false
	last_dash_end_msec = Time.get_ticks_msec()

	# ปิดโหมด Dash-through ให้ Player กลับมาชนศัตรูตามปกติ
	end_dash_collision_mode()

	# เปิด Hurtbox กลับมา เพื่อให้รับดาเมจได้ตามปกติ
	hurtbox_shape.disabled = false

	# ถ้าเปิด Lock-on อยู่ หลัง Dash ข้าม Boss ให้หันกลับเข้าหา Boss ทันที
	if is_target_locked:
		update_facing_to_locked_target()

	print("Dash End. Invincible OFF")

	# รอ cooldown ก่อน Dash ครั้งต่อไป
	await get_tree().create_timer(dash_cooldown).timeout

	can_dash = true
	print("Dash Ready")


func show_stamina_insufficient_feedback() -> void:
	# ถ้าปิด feedback ไว้ หรือกำลังแสดงอยู่แล้ว ไม่ต้องสร้างซ้ำ
	if not stamina_feedback_enabled:
		return

	if is_showing_stamina_feedback:
		return

	if is_dead:
		return

	is_showing_stamina_feedback = true

	# สร้าง Label ชั่วคราวเหนือหัว Player เพื่อบอกว่า Stamina ไม่พอ
	var popup := Label.new()
	popup.text = stamina_feedback_text
	popup.modulate = stamina_feedback_color
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 180
	popup.add_theme_font_size_override("font_size", stamina_feedback_font_size)

	# เพิ่ม popup เข้า parent เดียวกับ Player เพื่อใช้ global_position ได้ง่าย
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-80.0, -105.0)

	# กระพริบสี Player สั้น ๆ เพื่อให้รู้ว่ากดแล้ว action ไม่ออก
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color(1.0, 0.35, 0.10, 1.0)

	# ทำให้ข้อความลอยขึ้นและจางหาย
	var target_position: Vector2 = popup.global_position + Vector2(0.0, -28.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, stamina_feedback_duration)
	tween.tween_property(popup, "modulate:a", 0.0, stamina_feedback_duration)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))

	# รอให้ feedback จบ แล้วอนุญาตให้แสดงใหม่ได้
	await get_tree().create_timer(stamina_feedback_duration).timeout

	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE

	is_showing_stamina_feedback = false


func spawn_dash_trail() -> void:
	# ถ้าปิด Dash trail ไว้ หรือไม่มี sprite ให้ไม่ต้องสร้างอะไร
	if not dash_trail_enabled:
		return

	if not is_instance_valid(sprite_2d):
		return

	# สร้างเงาจาง ๆ หลายชุดตามจำนวนที่ตั้งไว้
	for i in range(max(dash_trail_count, 0)):
		create_dash_trail_ghost()
		await get_tree().create_timer(dash_trail_spawn_interval).timeout


func create_dash_trail_ghost() -> void:
	# สร้าง Sprite2D ชั่วคราวจาก texture ของ Player ปัจจุบัน
	# ใช้เป็นเงาจางตอน Dash โดยไม่ต้องใช้ asset ใหม่
	if sprite_2d.texture == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = sprite_2d.texture
	ghost.flip_h = sprite_2d.flip_h
	ghost.scale = sprite_2d.scale
	ghost.rotation = sprite_2d.rotation
	ghost.z_index = sprite_2d.z_index - 1
	ghost.modulate = Color(0.35, 0.85, 1.0, dash_trail_start_alpha)

	# เพิ่ม ghost เข้า parent เดียวกับ Player เพื่อใช้ global_position ได้ง่าย
	get_parent().add_child(ghost)
	ghost.global_position = global_position

	# ทำให้เงาค่อย ๆ จางและเล็กลง แล้วลบทิ้ง ไม่ให้ node ค้างใน scene
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ghost, "modulate:a", 0.0, dash_trail_fade_time)
	tween.tween_property(ghost, "scale", ghost.scale * 0.85, dash_trail_fade_time)
	tween.set_parallel(false)
	tween.tween_callback(Callable(ghost, "queue_free"))


func parry() -> void:
	# ปุ่ม Parry ถูกถอดออกจากระบบมือถือแล้ว
	# ฟังก์ชันนี้คงไว้เพื่อไม่ให้ flow เก่าที่อาจยังเรียก parry() พังทันที
	# แต่จะไม่เปิดหน้าต่าง Parry โดยตรงอีกต่อไป
	print("Parry button deprecated. Use Movement/Tap Deflect instead.")


func is_parry_active() -> bool:
	# ให้ Boss เรียกชื่อเดิมได้ แต่ความหมายใหม่คือ Movement/Tap Deflect
	return is_movement_deflect_active()


func on_successful_parry() -> void:
	# ฟังก์ชันนี้ถูกเรียกเมื่อ Boss โจมตีเข้ามาในช่วง Deflect
	print("Successful Deflect!")

	last_successful_deflect_msec = Time.get_ticks_msec()
	var deflect_type := last_active_deflect_type
	if deflect_type == "":
		deflect_type = get_active_deflect_type()

	# Tap Deflect ใช้ง่ายกว่า จึงเสีย Posture มากกว่า Movement Deflect เล็กน้อย
	if deflect_type == "tap":
		apply_player_posture_damage(posture_damage_on_tap_deflect)
	else:
		apply_player_posture_damage(posture_damage_on_deflect)

	# ได้ Focus เมื่อ Deflect สำเร็จ
	gain_focus(focus_gain_on_successful_parry)

	# แสดง feedback ฝั่ง Player
	show_movement_deflect_feedback()

	# ล้าง window เพื่อไม่ให้ touch/movement ครั้งเดียวถูกใช้ซ้ำ
	clear_deflect_windows_after_success()


func show_movement_deflect_feedback() -> void:
	# กัน feedback ซ้อนกันหลายอันเกินไป
	if is_showing_deflect_feedback:
		return

	is_showing_deflect_feedback = true

	var popup := Label.new()
	popup.text = movement_deflect_feedback_text
	popup.modulate = Color(0.35, 0.95, 1.0, 1.0)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 190
	popup.add_theme_font_size_override("font_size", movement_deflect_feedback_font_size)
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-75.0, -115.0)

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color(0.35, 0.95, 1.0, 1.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -28.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, movement_deflect_feedback_duration)
	tween.tween_property(popup, "modulate:a", 0.0, movement_deflect_feedback_duration)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))

	await get_tree().create_timer(movement_deflect_feedback_duration).timeout

	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE

	is_showing_deflect_feedback = false


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ถ้าไม่ได้อยู่ในจังหวะโจมตี ก็ไม่ทำดาเมจ
	if not is_attacking:
		return

	# ถ้ากำลัง Dash อยู่ ห้ามทำดาเมจ
	if is_dashing:
		return

	# ตรวจเฉพาะ Area ที่ชื่อ Hurtbox เท่านั้น
	if area.name != "Hurtbox":
		return

	# หา parent ของ Hurtbox ที่ถูกชน
	var target = area.get_parent()

	# ถ้า target คือตัว Player เอง ให้ข้าม
	if target == self:
		print("Player attack ignored own Hurtbox")
		return

	# ถ้า target เคยโดนแล้วในการฟันครั้งนี้ ไม่ให้โดนซ้ำ
	if target in hit_targets:
		return

	# ถ้า target ไม่มีฟังก์ชัน take_damage ก็ไม่ต้องทำอะไร
	if not target.has_method("take_damage"):
		return

	# บันทึกว่า target ตัวนี้โดนไปแล้ว
	hit_targets.append(target)

	# ถ้า Focus เต็ม และศัตรูเปิดช่องให้ Finisher ให้ใช้ Focus Finisher แทนโจมตีปกติ
	if has_enough_focus_for_finisher() and target.has_method("can_receive_focus_finisher") and target.can_receive_focus_finisher():
		spend_focus(focus_finisher_cost)

		# ตั้งดาเมจเริ่มต้นไว้ก่อน เผื่อเป้าหมายไม่มีค่า max_hp
		var finisher_damage: int = attack_damage * 2

		# อ่านค่า max_hp จากศัตรูแบบปลอดภัย
		var target_max_hp = target.get("max_hp")
		if target_max_hp != null:
			finisher_damage = int(round(float(target_max_hp) * focus_finisher_damage_ratio))

		# กันไว้ว่า Finisher ต้องแรงกว่าโจมตีปกติอย่างน้อย
		finisher_damage = max(finisher_damage, attack_damage * 2)

		print("FOCUS FINISHER! Damage =", finisher_damage)

		# เล่น feedback ฝั่ง Player ให้รู้ว่าท่าใหญ่ทำงานแล้ว
		play_focus_finisher_feedback()

		# สั่งให้ศัตรูรับดาเมจแบบ Finisher
		if target.has_method("take_focus_finisher_damage"):
			target.take_focus_finisher_damage(finisher_damage)
		else:
			target.take_damage(finisher_damage)

		return

	# ถ้าเงื่อนไขไม่ครบ ให้โจมตีปกติ โดยเลือก damage ตาม hit ปัจจุบัน
	var damage_amount := attack_damage
	if combo_enabled and current_combo_step_for_damage > 0:
		damage_amount = get_combo_damage(current_combo_step_for_damage)

	target.take_damage(damage_amount)


func take_damage(amount: int) -> void:
	# ถ้า Player ตายไปแล้ว ไม่รับดาเมจซ้ำ
	if is_dead:
		return

	# ถ้าอยู่ในช่วงอมตะหลังโดนตี ไม่รับดาเมจซ้ำ
	if is_hurt_invincible:
		print("Damage ignored by hurt invincibility!")
		return

	# ถ้ากำลัง Dash อยู่ ไม่รับดาเมจ
	# เผื่อกรณี Hitbox ศัตรูชนพอดีในจังหวะที่ Hurtbox ยังไม่ถูกปิดทัน
	if is_dashing:
		print("Damage avoided by dash!")
		return

	# โดนโจมตีจริงจะทำให้ Player Posture ลดด้วย
	apply_player_posture_damage(float(amount) * posture_damage_from_hit_multiplier)

	# ลดเลือดผู้เล่นตามจำนวนดาเมจที่ได้รับ
	current_hp -= amount
	current_hp = max(current_hp, 0)
	print("Player took damage:", amount, "HP left:", current_hp)

	# แจ้ง HUD ว่า HP เปลี่ยนแล้ว
	emit_stats()

	# ทำ Knockback ให้ Player กระเด็นเมื่อโดนโจมตี
	apply_knockback()

	# เริ่มช่วงอมตะหลังโดนตี
	start_hurt_invincibility()

	# ทำ Camera Shake เมื่อ Player โดนโจมตี
	get_tree().call_group("game_camera", "shake", player_hit_camera_shake_strength, player_hit_camera_shake_duration)

	# ทำเอฟเฟกต์กระพริบแดงแบบง่าย ๆ
	flash_red()

	# ถ้าเลือดหมด ให้ตาย
	if current_hp <= 0:
		die()


func find_knockback_source() -> Node2D:
	# หา combat_target ก่อน เพราะตอนนี้บอสหลักอยู่ใน group นี้
	var targets := get_tree().get_nodes_in_group("combat_target")
	for target in targets:
		if target is Node2D and is_instance_valid(target):
			return target as Node2D

	# fallback เผื่อ scene เก่ายังใช้ EnemyDummy อยู่
	var enemy_dummy := get_parent().get_node_or_null("EnemyDummy") as Node2D
	if enemy_dummy != null:
		return enemy_dummy

	# fallback สุดท้าย ลองหา BossBrokenMaster ตามชื่อ node
	var boss := get_parent().get_node_or_null("BossBrokenMaster") as Node2D
	return boss


func apply_knockback() -> void:
	# ถ้า Player ตายแล้ว ไม่ต้อง Knockback
	if is_dead:
		return

	cancel_combo("knockback")

	var source := find_knockback_source()

	# ถ้าไม่มีแหล่งดาเมจแล้ว ไม่ต้องทำ Knockback
	if source == null:
		enter_combat_stance_for(combat_stance_after_hurt_time, "hurt_no_knockback_source")
		return

	# คำนวณทิศกระเด็น
	var direction: float = sign(global_position.x - source.global_position.x)

	# ถ้าทับตำแหน่งกันพอดี ให้ถอยไปทิศตรงข้ามกับที่ Player หัน
	if direction == 0.0:
		direction = float(-facing_direction)

	# ตั้งแรง Knockback
	knockback_velocity = Vector2(direction * player_knockback_force, 0.0)

	# เริ่มสถานะ Knockback
	is_knocked_back = true

	# ปิด action ระหว่างกระเด็น
	is_attacking = false
	is_parrying = false

	# รอระยะเวลา Knockback
	await get_tree().create_timer(player_knockback_time).timeout

	# ถ้า Player ยังอยู่ ให้จบ Knockback
	if is_instance_valid(self):
		is_knocked_back = false
		knockback_velocity = Vector2.ZERO
		if not is_dead and not is_posture_broken:
			enter_combat_stance_for(combat_stance_after_hurt_time, "hurt_recovered")
		if is_target_locked:
			update_facing_to_locked_target()


func start_hurt_invincibility() -> void:
	# ถ้า Player ตายแล้ว ไม่ต้องเริ่มอมตะ
	if is_dead:
		return

	# เริ่มสถานะอมตะหลังโดนตี
	is_hurt_invincible = true

	# ปิด Hurtbox ชั่วคราว เพื่อกันการรับดาเมจซ้ำจาก hitbox อื่น
	hurtbox_shape.set_deferred("disabled", true)

	# ทำเอฟเฟกต์กระพริบระหว่างอมตะ
	blink_while_invincible()

	# รอระยะเวลาอมตะ
	await get_tree().create_timer(hurt_invincible_time).timeout

	# ถ้า Player ตายระหว่างนั้น ไม่ต้องเปิด Hurtbox กลับ
	if is_dead:
		return

	# จบสถานะอมตะ
	is_hurt_invincible = false

	# เปิด Hurtbox กลับมา
	hurtbox_shape.set_deferred("disabled", false)

	# คืนสีปกติ
	if is_instance_valid(sprite_2d) and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE


func blink_while_invincible() -> void:
	# กระพริบไปเรื่อย ๆ ตราบใดที่ยังอยู่ในช่วงอมตะ
	while is_hurt_invincible and not is_dead:
		# ทำให้ตัวละครจางลง
		if is_instance_valid(sprite_2d):
			sprite_2d.modulate = Color(1.0, 1.0, 1.0, 0.35)

		await get_tree().create_timer(0.08).timeout

		# ทำให้ตัวละครกลับมาชัด
		if is_instance_valid(sprite_2d):
			sprite_2d.modulate = Color.WHITE

		await get_tree().create_timer(0.08).timeout


func flash_red() -> void:
	# เปลี่ยนสีตัวละครเป็นสีแดงชั่วคราว
	sprite_2d.modulate = Color.RED

	await get_tree().create_timer(0.1).timeout

	# ถ้า Sprite ยังอยู่ และไม่ได้อยู่ในช่วงอมตะ/สะดุด ให้เปลี่ยนกลับเป็นสีขาว
	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_posture_broken:
		sprite_2d.modulate = Color.WHITE


func die() -> void:
	# ถ้าตายไปแล้ว ไม่ต้องทำซ้ำ
	if is_dead:
		return

	cancel_combo("death")
	clear_combat_stance_memory("death")

	# ตั้งสถานะว่าตายแล้ว
	is_dead = true

	# ปิด action ต่าง ๆ
	is_attacking = false
	is_dashing = false
	is_parrying = false
	is_knocked_back = false
	is_posture_broken = false
	clear_target_lock()

	# ปิด Hitbox และ Hurtbox เพื่อไม่ให้ชนอะไรต่อ
	attack_shape.set_deferred("disabled", true)
	hurtbox_shape.set_deferred("disabled", true)

	print("Player defeated!")

	# ส่งสัญญาณไปให้ HUD แสดง Game Over
	player_died.emit()

	# ยังไม่ซ่อน Player ทันที เพื่อให้มีเวลามองเห็น death animation / death pose
	# GameLoopManager จะเป็นคนรอก่อนขึ้นหน้า DEFEATED
	visible = true

	# ปิด physics ของ Player เพื่อไม่ให้รับ input หรือขยับต่อหลังตาย
	set_physics_process(false)
