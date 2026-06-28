extends CharacterBody2D

# ส่งสัญญาณไปให้ HUD ทุกครั้งที่ค่า HP หรือ Posture ของบอสเปลี่ยน
signal enemy_stats_changed(current_hp: int, max_hp: int, current_posture: float, max_posture: float)

# ส่งสัญญาณเมื่อบอสตาย เพื่อให้ HUD หรือ Main แสดง Victory
signal enemy_died

# ส่งสัญญาณข้อความเตือนท่าโจมตี เผื่อ HUD หรือระบบอื่นใช้ต่อในอนาคต
signal enemy_attack_hint_changed(hint_text: String, hint_color: Color)

# =========================
# ค่าพื้นฐานของบอส
# =========================

# เลือดสูงสุดของบอส
@export var max_hp: int = 150

# ชื่อที่ HUD ใช้แสดงบนหน้าจอ
@export var combat_display_name: String = "Boss"

# ความเร็วเดินเข้าหาผู้เล่น
@export var move_speed: float = 95.0

# ระยะที่บอสจะหยุดและเริ่มโจมตี
@export var stop_distance: float = 105.0

# ดาเมจของท่าปกติ
@export var attack_damage: int = 12

# เวลาก่อนท่าปกติจะฟันจริง
@export var attack_windup_time: float = 0.70

# ระยะเวลาที่ hitbox ท่าปกติเปิดอยู่
@export var attack_active_time: float = 0.18

# เวลารอหลังท่าปกติก่อนโจมตีครั้งถัดไป
@export var attack_cooldown: float = 1.35

# =========================
# ค่าของ Quick Slash
# =========================

# โอกาสที่บอสจะเลือกใช้ Quick Slash ตอนสุ่มท่า
@export var quick_attack_chance: float = 0.20

# ดาเมจของ Quick Slash
@export var quick_attack_damage: int = 8

# Wind-up ของ Quick Slash ต้องสั้นกว่าท่าปกติ
@export var quick_attack_windup_time: float = 0.38

# เวลาที่ hitbox ของ Quick Slash เปิดอยู่
@export var quick_attack_active_time: float = 0.14

# Cooldown เพิ่มหลัง Quick Slash
@export var quick_attack_cooldown_bonus: float = 0.05

# =========================
# ค่าของ Heavy Slash
# =========================

# โอกาสที่บอสจะเลือกใช้ Heavy Slash ตอนสุ่มท่า
@export var heavy_attack_chance: float = 0.30

# ดาเมจของ Heavy Slash
@export var heavy_attack_damage: int = 22

# Wind-up ของ Heavy Slash ต้องนานพอให้ผู้เล่นเห็นแล้ว Dash
@export var heavy_attack_windup_time: float = 1.05

# เวลาที่ hitbox ของ Heavy Slash เปิดอยู่
@export var heavy_attack_active_time: float = 0.26

# Cooldown เพิ่มหลัง Heavy Slash เพื่อเปิดช่องให้ผู้เล่นสวนกลับ
@export var heavy_attack_cooldown_bonus: float = 0.45

# =========================
# ค่าของ Delayed Slash
# =========================

# โอกาสที่บอสจะเลือกใช้ Delayed Slash ตอนสุ่มท่า
@export var delayed_attack_chance: float = 0.25

# ดาเมจของ Delayed Slash
@export var delayed_attack_damage: int = 14

# ช่วง WAIT... เพื่อหลอกให้ผู้เล่นอย่าเพิ่ง Parry
@export var delayed_attack_wait_time: float = 0.70

# ช่วง PARRY! ตอนท้ายที่ผู้เล่นควรกด Parry
@export var delayed_attack_parry_time: float = 0.35

# เวลาที่ hitbox ของ Delayed Slash เปิดอยู่
@export var delayed_attack_active_time: float = 0.18

# Cooldown เพิ่มหลัง Delayed Slash
@export var delayed_attack_cooldown_bonus: float = 0.25

# =========================
# ค่าของระบบ Parry / Posture
# =========================

# ระยะเวลาที่บอสชะงักเมื่อถูก Parry แต่ Posture ยังไม่แตก
@export var stagger_time: float = 0.45

# เวลาพักหลังชะงัก ก่อนบอสกลับมาโจมตีใหม่
@export var stagger_recover_time: float = 0.25

# Posture สูงสุดของบอส
@export var max_posture: float = 120.0

# Posture damage ที่บอสเสียเมื่อผู้เล่น Parry สำเร็จ
@export var posture_damage_from_parry: float = 35.0

# ระยะเวลาที่บอสเสียสมดุลหนักหลัง Posture หมด
@export var posture_break_time: float = 1.35

# ตัวคูณดาเมจเมื่อผู้เล่นโจมตีตอนบอส Posture Broken
@export var critical_damage_multiplier: float = 3.0

# =========================
# ค่าของ Combat Feel
# =========================

# ระยะเวลา Hit Stop เมื่อโจมตีปกติโดนบอส
@export var normal_hit_stop_time: float = 0.06

# ระยะเวลา Hit Stop เมื่อโจมตี Critical หรือ Focus Finisher
@export var critical_hit_stop_time: float = 0.12

# ความเร็วเกมระหว่าง Hit Stop
@export var hit_stop_time_scale: float = 0.08

# แรง Knockback ของบอสเมื่อโดนโจมตี
@export var knockback_force: float = 220.0

# ระยะเวลา Knockback ของบอส
@export var knockback_time: float = 0.12

# ความแรงกล้องสั่นเมื่อโจมตีปกติโดนบอส
@export var normal_hit_camera_shake_strength: float = 4.0

# ระยะเวลากล้องสั่นเมื่อโจมตีปกติโดนบอส
@export var normal_hit_camera_shake_duration: float = 0.10

# ความแรงกล้องสั่นเมื่อ Critical หรือ Focus Finisher
@export var critical_hit_camera_shake_strength: float = 9.0

# ระยะเวลากล้องสั่นเมื่อ Critical หรือ Focus Finisher
@export var critical_hit_camera_shake_duration: float = 0.18

# ข้อความที่ขึ้นเมื่อผู้เล่นพยายาม Parry ท่าหนักที่ต้อง Dash เท่านั้น
@export var heavy_wrong_parry_feedback_text: String = "DASH ONLY!"

# ขนาดตัวอักษรของ feedback ตอน Parry ท่าหนักผิด
@export var heavy_wrong_parry_feedback_font_size: int = 28

# ระยะเวลาที่ข้อความ feedback ลอยขึ้นและจางหาย
@export var heavy_wrong_parry_feedback_duration: float = 0.45

# ความแรงกล้องสั่นสั้น ๆ ตอนผู้เล่น Parry ท่าหนักผิด
@export var heavy_wrong_parry_camera_shake_strength: float = 5.0

# ระยะเวลากล้องสั่นตอนผู้เล่น Parry ท่าหนักผิด
@export var heavy_wrong_parry_camera_shake_duration: float = 0.12

# เปิดระบบตรวจ Parry ผิดระหว่าง wind-up ของท่าหนัก
# ช่วยแก้กรณีผู้เล่นกด Parry เร็วเกินไปจนหมดช่วง Parry ก่อนโดนฟันจริง
@export var heavy_watch_wrong_parry_during_windup: bool = true

# =========================
# Debug: Boss Pattern Debug Mode
# =========================

# เปิดโหมดบังคับท่าบอส เพื่อใช้จูน timing ทีละท่า
# ปิดไว้เป็นค่าเริ่มต้น เพื่อให้เกมเล่นจริงยังสุ่ม pattern เหมือนเดิม
@export var debug_force_attack_pattern_enabled: bool = false

# เลือกท่าที่ต้องการบังคับให้บอสใช้ตอน debug
# random = กลับไปสุ่มตามโอกาสปกติ
@export_enum("random", "normal_slash", "heavy_slash", "delayed_slash", "quick_slash") var debug_forced_attack_pattern: String = "random"

# เปิด/ปิดข้อความ debug ใน Output เพื่อให้จูนบอสง่ายขึ้น
@export var debug_print_attack_pattern: bool = true

# =========================
# ระบบเสียง Placeholder
# =========================

# เปิด/ปิดเสียง placeholder ที่สร้างด้วยโค้ด
@export var enable_placeholder_sfx: bool = true

# ความดังของเสียง placeholder
@export var placeholder_sfx_volume: float = 0.10

# sample rate สำหรับ AudioStreamGenerator
const PLACEHOLDER_SFX_MIX_RATE: int = 44100

# =========================
# Collision Layer
# =========================

# Layer 1 ใช้สำหรับพื้น / กำแพง / ขอบสนาม
const WORLD_BODY_LAYER: int = 1

# Layer 2 ใช้สำหรับ Player
const PLAYER_BODY_LAYER: int = 2

# Layer 3 ใช้สำหรับ Enemy / Boss
const ENEMY_BODY_LAYER: int = 4

# ตอนปกติบอสต้องชน World และ Player
const ENEMY_NORMAL_COLLISION_MASK: int = WORLD_BODY_LAYER | PLAYER_BODY_LAYER

# =========================
# ขอบเขต Arena
# =========================

# ขอบซ้ายของสนาม
@export var arena_min_x: float = 120.0

# ขอบขวาของสนาม
@export var arena_max_x: float = 1030.0

# อ้างอิง ArenaManager ถ้ามีในฉาก
var arena_manager: Node = null

# =========================
# อ้างอิง Node
# =========================

# อ้างอิง Player ในฉาก
var player: CharacterBody2D = null

# Sprite2D ใช้แสดงบอสและเปลี่ยนสี feedback
@onready var sprite_2d: Sprite2D = $Sprite2D

# AttackHitbox ของบอส
@onready var attack_hitbox: Area2D = $AttackHitbox

# CollisionShape2D ของ AttackHitbox ใช้เปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

# Label สำหรับแสดงคำเตือนเหนือหัวบอส
var boss_hint_label: Label = null

# Tween สำหรับ animation ของข้อความเตือน
var boss_hint_tween: Tween = null

# ตำแหน่งข้อความเหนือหัวบอส
@export var boss_hint_offset: Vector2 = Vector2(-160.0, -110.0)

# ขนาดตัวอักษรข้อความเหนือหัวบอส
@export var boss_hint_font_size: int = 34

# =========================
# ตัวแปรสถานะบอส
# =========================

# เลือดปัจจุบันของบอส
var current_hp: int

# Posture ปัจจุบันของบอส
var current_posture: float

# เช็กว่าบอสตายไปแล้วหรือยัง
var is_dead: bool = false

# เช็กว่าบอสกำลัง Posture Broken อยู่หรือไม่
var is_posture_broken: bool = false

# เช็กว่าบอสเปิดช่องให้ Critical ได้หรือไม่
var can_receive_critical: bool = false

# เช็กว่าบอสกำลังโจมตีจริงอยู่หรือไม่
var is_attacking: bool = false

# เช็กว่าบอสกำลัง wind-up ก่อนโจมตีหรือไม่
var is_winding_up: bool = false

# เช็กว่าบอสกำลังชะงักจาก Parry หรือ Posture Break หรือไม่
var is_staggered: bool = false

# เช็กว่าบอสกำลังถูก Knockback หรือไม่
var is_knocked_back: bool = false

# ความเร็ว Knockback ปัจจุบัน
var knockback_velocity: Vector2 = Vector2.ZERO

# เช็กว่าบอสพร้อมเริ่มโจมตีรอบใหม่หรือไม่
var can_attack: bool = true

# กันไม่ให้การโจมตีครั้งเดียวโดนผู้เล่นซ้ำหลายรอบ
var has_hit_player: bool = false

# กันไม่ให้ข้อความ DASH ONLY! ขึ้นซ้ำหลายครั้งในการโจมตีท่าเดียว
var has_shown_wrong_parry_feedback_this_attack: bool = false

# ชื่อท่าปัจจุบันของบอส
var current_attack_name: String = "normal_slash"

# ดาเมจของท่าปัจจุบัน
var current_attack_damage: int = 12

# Wind-up ของท่าปัจจุบัน
var current_attack_windup_time: float = 0.70

# Active time ของท่าปัจจุบัน
var current_attack_active_time: float = 0.18

# Cooldown ของท่าปัจจุบัน
var current_attack_cooldown: float = 1.35

# ท่าปัจจุบัน Parry ได้หรือไม่
var current_attack_can_be_parried: bool = true

# เช็กว่าท่าปัจจุบันเป็น Delayed Slash หรือไม่
var current_attack_is_delayed: bool = false

# เวลารอช่วง WAIT... ของ Delayed Slash
var current_attack_delay_wait_time: float = 0.0

# ข้อความ hint ของท่าปัจจุบัน
var current_attack_hint_text: String = "PARRY!"

# สี hint ของท่าปัจจุบัน
var current_attack_hint_color: Color = Color.YELLOW

# ใช้ยกเลิก attack coroutine เก่าที่ค้างอยู่
var attack_sequence_id: int = 0

# ใช้กัน Hit Stop ซ้อนกันแล้ว reset time_scale ผิด
var hit_stop_id: int = 0

# ทิศที่บอสหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = -1

# ระยะห่างของ hitbox จากตัวบอส
var attack_hitbox_offset_x: float = 55.0


func _ready() -> void:
	# สุ่มค่าเริ่มต้น เพื่อให้ pattern ไม่ซ้ำแบบเดิมทุกครั้งที่เปิดเกม
	randomize()

	# เพิ่มบอสเข้า group combat_target เพื่อให้ HUD หาเป้าหมายหลักได้
	add_to_group("combat_target")

	# ตั้ง collision layer/mask ของบอส
	collision_layer = ENEMY_BODY_LAYER
	collision_mask = ENEMY_NORMAL_COLLISION_MASK

	# หา ArenaManager จาก group ถ้ามี
	var arena_nodes := get_tree().get_nodes_in_group("arena_manager")
	if arena_nodes.size() > 0:
		arena_manager = arena_nodes[0]
		print("Boss found ArenaManager")
	else:
		print("Boss using fallback arena bounds")

	# ตั้งค่า HP และ Posture เริ่มต้น
	current_hp = max_hp
	current_posture = max_posture

	# หา Player จาก parent node ชื่อ Player
	player = get_parent().get_node_or_null("Player") as CharacterBody2D
	if player == null:
		print("Boss ERROR: Player node not found")

	# ปิด hitbox ไว้ก่อน เพราะบอสยังไม่โจมตี
	attack_shape.disabled = true

	# วาง hitbox ไว้ด้านหน้าบอสตามทิศเริ่มต้น
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)

	# เชื่อมสัญญาณเมื่อ hitbox บอสชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	# สร้างข้อความเตือนเหนือหัวบอส
	create_boss_hint_label()

	print("Boss Broken Master ready. HP =", current_hp)

	# แจ้ง HUD ให้แสดงค่าบอสเริ่มต้น
	emit_enemy_stats()


func _physics_process(_delta: float) -> void:
	# ถ้าบอสตายแล้ว ไม่ต้องทำ AI ต่อ
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้าบอสกำลังถูก Knockback ให้ขยับตามแรงกระเด็น
	if is_knocked_back:
		velocity = knockback_velocity
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้าไม่มี Player ให้หยุดนิ่งเพื่อกัน error
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้ากำลังชะงัก / wind-up / attacking ให้หยุดนิ่ง
	if is_staggered or is_winding_up or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		clamp_to_arena()
		return

	# คำนวณระยะห่างจาก Player ในแกน X
	var distance_to_player: float = player.global_position.x - global_position.x

	# หันหน้าเข้าหา Player
	if distance_to_player != 0.0:
		facing_direction = int(sign(distance_to_player))
		sprite_2d.flip_h = facing_direction < 0
		attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)

	# ถ้าอยู่ไกล ให้เดินเข้าหา Player
	if abs(distance_to_player) > stop_distance:
		velocity.x = float(facing_direction) * move_speed
	else:
		# ถ้าอยู่ในระยะ ให้หยุดและโจมตีเมื่อ cooldown พร้อม
		velocity.x = 0.0
		if can_attack:
			attack()

	velocity.y = 0.0
	move_and_slide()
	clamp_to_arena()


func clamp_to_arena() -> void:
	# ถ้ามี ArenaManager ให้ใช้ค่ากลางจาก ArenaManager
	if is_instance_valid(arena_manager) and arena_manager.has_method("clamp_node_x"):
		arena_manager.clamp_node_x(self)
		return

	# ถ้าไม่มี ArenaManager ให้ใช้ค่า fallback ในบอส
	global_position.x = clamp(global_position.x, arena_min_x, arena_max_x)


func emit_enemy_stats() -> void:
	# ส่งค่า HP และ Posture ปัจจุบันไปให้ HUD
	enemy_stats_changed.emit(current_hp, max_hp, current_posture, max_posture)


func create_boss_hint_label() -> void:
	# สร้าง Label ใหม่สำหรับข้อความเตือนเหนือหัวบอส
	boss_hint_label = Label.new()
	boss_hint_label.text = ""
	boss_hint_label.visible = false
	boss_hint_label.custom_minimum_size = Vector2(320.0, 60.0)
	boss_hint_label.position = boss_hint_offset
	boss_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_hint_label.add_theme_font_size_override("font_size", boss_hint_font_size)
	boss_hint_label.z_index = 200
	add_child(boss_hint_label)


func update_boss_hint_label(hint_text: String, hint_color: Color) -> void:
	# ถ้ายังไม่มี label ให้หยุดเพื่อกัน error
	if boss_hint_label == null:
		return

	# หยุด animation เก่าก่อนเริ่ม animation ใหม่
	if boss_hint_tween != null:
		boss_hint_tween.kill()
		boss_hint_tween = null

	# ถ้าข้อความว่าง แปลว่าซ่อน hint
	if hint_text == "":
		boss_hint_label.text = ""
		boss_hint_label.visible = false
		boss_hint_label.scale = Vector2.ONE
		boss_hint_label.modulate = Color.WHITE
		return

	# อัปเดตข้อความและสี
	boss_hint_label.text = hint_text
	boss_hint_label.modulate = hint_color
	boss_hint_label.visible = true

	# ทำ animation เด้งเล็กน้อยเพื่อให้ผู้เล่นสังเกตเห็น
	boss_hint_label.scale = Vector2(0.75, 0.75)
	boss_hint_tween = create_tween()
	boss_hint_tween.tween_property(boss_hint_label, "scale", Vector2(1.08, 1.08), 0.08)
	boss_hint_tween.tween_property(boss_hint_label, "scale", Vector2.ONE, 0.08)


func emit_attack_hint() -> void:
	# แสดง hint เหนือหัวบอส และยังส่ง signal เผื่อระบบอื่นใช้
	update_boss_hint_label(current_attack_hint_text, current_attack_hint_color)
	enemy_attack_hint_changed.emit(current_attack_hint_text, current_attack_hint_color)


func clear_attack_hint() -> void:
	# ล้าง hint เหนือหัวบอส
	update_boss_hint_label("", Color.WHITE)
	enemy_attack_hint_changed.emit("", Color.WHITE)


func emit_delayed_parry_hint() -> void:
	# ช่วงท้ายของ Delayed Slash ให้เปลี่ยนจาก WAIT... เป็น PARRY!
	update_boss_hint_label("PARRY!", Color.YELLOW)
	enemy_attack_hint_changed.emit("PARRY!", Color.YELLOW)


func apply_attack_pattern(pattern_name: String) -> void:
	# รีเซ็ตค่าของท่าปัจจุบันก่อนตั้งค่าใหม่
	current_attack_is_delayed = false
	current_attack_delay_wait_time = 0.0

	# ตั้งค่าท่าโจมตีตามชื่อ pattern
	match pattern_name:
		"quick_slash":
			current_attack_name = "quick_slash"
			current_attack_can_be_parried = true
			current_attack_damage = quick_attack_damage
			current_attack_windup_time = quick_attack_windup_time
			current_attack_active_time = quick_attack_active_time
			current_attack_cooldown = attack_cooldown + quick_attack_cooldown_bonus
			current_attack_hint_text = "PARRY FAST!"
			current_attack_hint_color = Color(0.35, 0.85, 1.0, 1.0)

		"delayed_slash":
			current_attack_name = "delayed_slash"
			current_attack_can_be_parried = true
			current_attack_damage = delayed_attack_damage
			current_attack_windup_time = delayed_attack_wait_time + delayed_attack_parry_time
			current_attack_active_time = delayed_attack_active_time
			current_attack_cooldown = attack_cooldown + delayed_attack_cooldown_bonus
			current_attack_is_delayed = true
			current_attack_delay_wait_time = delayed_attack_wait_time
			current_attack_hint_text = "WAIT..."
			current_attack_hint_color = Color(0.75, 0.35, 1.0, 1.0)

		"heavy_slash":
			current_attack_name = "heavy_slash"
			current_attack_can_be_parried = false
			current_attack_damage = heavy_attack_damage
			current_attack_windup_time = heavy_attack_windup_time
			current_attack_active_time = heavy_attack_active_time
			current_attack_cooldown = attack_cooldown + heavy_attack_cooldown_bonus
			current_attack_hint_text = "DASH!"
			current_attack_hint_color = Color(1.0, 0.35, 0.0, 1.0)

		"normal_slash":
			current_attack_name = "normal_slash"
			current_attack_can_be_parried = true
			current_attack_damage = attack_damage
			current_attack_windup_time = attack_windup_time
			current_attack_active_time = attack_active_time
			current_attack_cooldown = attack_cooldown
			current_attack_hint_text = "PARRY!"
			current_attack_hint_color = Color.YELLOW

		_:
			# ถ้าชื่อ pattern ผิด ให้ fallback เป็น normal_slash เพื่อกันบอสพัง
			current_attack_name = "normal_slash"
			current_attack_can_be_parried = true
			current_attack_damage = attack_damage
			current_attack_windup_time = attack_windup_time
			current_attack_active_time = attack_active_time
			current_attack_cooldown = attack_cooldown
			current_attack_hint_text = "PARRY!"
			current_attack_hint_color = Color.YELLOW


func choose_attack_pattern() -> void:
	# ถ้าเปิด Debug Mode และไม่ได้เลือก random ให้บังคับใช้ท่าที่กำหนด
	if debug_force_attack_pattern_enabled and debug_forced_attack_pattern != "random":
		apply_attack_pattern(debug_forced_attack_pattern)

		if debug_print_attack_pattern:
			print("Boss DEBUG forced pattern:", current_attack_name)

		return

	# ถ้าไม่ได้เปิด debug ให้สุ่มท่าตามโอกาสปกติ
	var roll: float = randf()

	if roll < quick_attack_chance:
		apply_attack_pattern("quick_slash")
	elif roll < quick_attack_chance + delayed_attack_chance:
		apply_attack_pattern("delayed_slash")
	elif roll < quick_attack_chance + delayed_attack_chance + heavy_attack_chance:
		apply_attack_pattern("heavy_slash")
	else:
		apply_attack_pattern("normal_slash")

	if debug_print_attack_pattern:
		print("Boss chose pattern:", current_attack_name)


func attack() -> void:
	# กันไม่ให้บอสเริ่มโจมตีซ้อน หรือโจมตีตอนยังไม่พร้อม
	if is_winding_up or is_attacking or is_staggered or not can_attack:
		return

	# เลือกท่าโจมตีของรอบนี้
	choose_attack_pattern()

	# ล็อกสถานะก่อนเริ่ม wind-up
	is_winding_up = true
	can_attack = false
	has_hit_player = false
	has_shown_wrong_parry_feedback_this_attack = false

	# เพิ่ม sequence id เพื่อให้ coroutine เก่าถูกยกเลิกได้
	attack_sequence_id += 1
	var my_attack_id: int = attack_sequence_id

	print("Boss Wind-up:", current_attack_name)

	# แสดง hint เหนือหัวบอส
	emit_attack_hint()

	# เปลี่ยนสีบอสตามประเภทท่า เพื่อช่วยอ่านจังหวะ
	if current_attack_is_delayed:
		sprite_2d.modulate = Color(0.75, 0.35, 1.0, 1.0)
	elif current_attack_can_be_parried:
		sprite_2d.modulate = Color.YELLOW
	else:
		sprite_2d.modulate = Color(1.0, 0.35, 0.0, 1.0)

	# ถ้าเป็น Delayed Slash ต้องมีช่วง WAIT... แล้วค่อย PARRY!
	if current_attack_is_delayed:
		await get_tree().create_timer(current_attack_delay_wait_time).timeout

		# ถ้าถูกยกเลิกระหว่างรอ ให้หยุดทันที
		if my_attack_id != attack_sequence_id or is_dead:
			return

		# เปลี่ยน hint เป็น PARRY! ในช่วงท้าย
		emit_delayed_parry_hint()
		sprite_2d.modulate = Color.YELLOW
		await get_tree().create_timer(delayed_attack_parry_time).timeout
	else:
		if should_watch_wrong_parry_during_windup():
			await watch_wrong_parry_during_windup(my_attack_id, current_attack_windup_time)
		else:
			await get_tree().create_timer(current_attack_windup_time).timeout

	# ถ้าถูกยกเลิกระหว่าง wind-up ให้หยุดทันที
	if my_attack_id != attack_sequence_id or is_dead:
		return

	# จบช่วง wind-up และเริ่มโจมตีจริง
	is_winding_up = false
	is_attacking = true
	clear_attack_hint()
	sprite_2d.modulate = Color.WHITE

	print("Boss Attack! Hitbox ON:", current_attack_name)

	# เปิด hitbox แบบ deferred เพื่อหลีกเลี่ยง physics flush error
	attack_shape.set_deferred("disabled", false)

	# รอหนึ่ง physics frame ให้ hitbox เปิดจริงก่อนตรวจ overlap
	await get_tree().physics_frame

	if my_attack_id != attack_sequence_id or is_dead:
		return

	# ตรวจ area ที่ซ้อนอยู่แล้ว เผื่อ Player อยู่ใน hitbox ตั้งแต่ก่อนเปิด
	for area in attack_hitbox.get_overlapping_areas():
		_try_hit_area(area)

	# รอช่วง active time ของท่าโจมตี
	await get_tree().create_timer(current_attack_active_time).timeout

	if my_attack_id != attack_sequence_id or is_dead:
		return

	# ปิด hitbox หลังหมดจังหวะโจมตี
	attack_shape.set_deferred("disabled", true)
	print("Boss Hitbox OFF:", current_attack_name)

	# จบสถานะโจมตี
	is_attacking = false

	# รอ cooldown ก่อนโจมตีครั้งต่อไป
	await get_tree().create_timer(current_attack_cooldown).timeout

	if my_attack_id != attack_sequence_id or is_dead:
		return

	can_attack = true


func should_watch_wrong_parry_during_windup() -> bool:
	# ตรวจเฉพาะท่าที่ Parry ไม่ได้ เช่น Heavy Slash
	# เพื่อไม่ให้ไปกระทบ Normal / Quick / Delayed ที่ควร Parry ได้
	return heavy_watch_wrong_parry_during_windup and not current_attack_can_be_parried


func watch_wrong_parry_during_windup(my_attack_id: int, duration: float) -> void:
	# คอยดูระหว่าง wind-up ว่าผู้เล่นเผลอกด Parry ใส่ท่าที่ต้อง Dash หรือไม่
	# แก้กรณีกด Parry เร็วเกินไป แล้ว Parry หมดก่อน hitbox ชน จนข้อความไม่ขึ้น
	var elapsed_time: float = 0.0

	while elapsed_time < duration:
		await get_tree().physics_frame

		# ถ้า attack รอบนี้ถูกยกเลิก เช่น บอสตายหรือ Posture Break ให้หยุดดูทันที
		if my_attack_id != attack_sequence_id or is_dead or not is_winding_up:
			return

		# ถ้า Player กำลัง Parry ระหว่างท่าหนัก ให้เตือนทันทีว่า Dash เท่านั้น
		if is_instance_valid(player) and player.has_method("is_parry_active") and player.is_parry_active():
			show_wrong_parry_feedback_once(player)

		# ใช้ delta ของ physics process เพื่อให้เวลารวมใกล้เคียง wind-up จริง
		elapsed_time += get_physics_process_delta_time()


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ส่งไปตรวจในฟังก์ชันกลาง เพื่อใช้ร่วมกับ get_overlapping_areas()
	_try_hit_area(area)


func _try_hit_area(area: Area2D) -> void:
	# ถ้าไม่ได้อยู่ในจังหวะโจมตีจริง ไม่ทำดาเมจ
	if not is_attacking:
		return

	# ถ้าบอสกำลังชะงัก ไม่ทำดาเมจ
	if is_staggered:
		return

	# ถ้าการโจมตีครั้งนี้โดนผู้เล่นไปแล้ว ไม่ทำซ้ำ
	if has_hit_player:
		return

	# ตรวจเฉพาะ Area ชื่อ Hurtbox เท่านั้น
	if area.name != "Hurtbox":
		return

	# หา parent ของ Hurtbox ที่ถูกชน
	var target = area.get_parent()

	# กันไม่ให้บอสโจมตีโดน Hurtbox ของตัวเอง
	if target == self:
		return

	# ถ้าเป้าหมายไม่มี take_damage ก็ไม่ต้องทำอะไร
	if not target.has_method("take_damage"):
		return

	# ถ้าท่านี้ Parry ได้ และ Player กำลัง Parry อยู่ ให้ถือว่า Parry สำเร็จ
	if current_attack_can_be_parried and target.has_method("is_parry_active") and target.is_parry_active():
		has_hit_player = true
		print("Boss attack was parried:", current_attack_name)

		# เล่นเสียง placeholder ตอน Parry สำเร็จ
		play_placeholder_sfx(880.0, 0.08, 1.0)

		# เรียก feedback ฝั่ง Player
		if target.has_method("on_successful_parry"):
			target.on_successful_parry()

		# ลด Posture ของบอส
		reduce_posture(posture_damage_from_parry)

		# ถ้า Posture ยังไม่แตก ให้ stagger แบบสั้น
		if not is_posture_broken:
			stagger()

		return

	# ถ้าผู้เล่นพยายาม Parry ท่าหนักตอน hitbox ชน ให้ feedback ชัด ๆ ก่อนโดนลงโทษ
	if not current_attack_can_be_parried and target.has_method("is_parry_active") and target.is_parry_active():
		show_wrong_parry_feedback_once(target)

	# ถ้า Parry ไม่สำเร็จ ให้ทำดาเมจตามท่าปัจจุบัน
	has_hit_player = true
	target.take_damage(current_attack_damage)


func stagger() -> void:
	# ถ้าบอสกำลังชะงักอยู่แล้ว ไม่ต้องเริ่มซ้ำ
	if is_staggered:
		return

	print("Boss staggered!")
	clear_attack_hint()

	# ยกเลิก attack coroutine เก่าที่อาจค้างอยู่
	attack_sequence_id += 1

	# ตั้งสถานะชะงัก
	is_staggered = true
	is_winding_up = false
	is_attacking = false
	can_attack = false
	has_hit_player = true
	velocity = Vector2.ZERO

	# ปิด hitbox เพื่อกันดาเมจค้าง
	attack_shape.set_deferred("disabled", true)

	# เปลี่ยนสีเป็นฟ้าเพื่อบอกว่า Parry สำเร็จ
	sprite_2d.modulate = Color.CYAN

	await get_tree().create_timer(stagger_time).timeout

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	is_staggered = false

	await get_tree().create_timer(stagger_recover_time).timeout

	if not is_dead and not is_posture_broken:
		can_attack = true


func reduce_posture(amount: float) -> void:
	# ถ้าบอสกำลัง Posture Break อยู่แล้ว ไม่ต้องลดซ้ำ
	if is_posture_broken:
		return

	# ลด Posture แล้ว clamp ไม่ให้ต่ำกว่า 0
	current_posture -= amount
	current_posture = clamp(current_posture, 0.0, max_posture)

	print("Boss posture reduced:", int(current_posture), "/", int(max_posture))
	emit_enemy_stats()

	# ถ้า Posture หมด ให้เข้าสู่ Posture Break
	if current_posture <= 0.0:
		posture_break()


func posture_break() -> void:
	# ถ้า Break อยู่แล้ว ไม่ต้องเริ่มซ้ำ
	if is_posture_broken:
		return

	print("Boss POSTURE BROKEN!")
	play_placeholder_sfx(220.0, 0.18, 1.4)
	clear_attack_hint()

	# ตั้งสถานะ Posture Break
	is_posture_broken = true
	can_receive_critical = true
	attack_sequence_id += 1

	is_staggered = true
	is_winding_up = false
	is_attacking = false
	can_attack = false
	has_hit_player = true
	velocity = Vector2.ZERO

	attack_shape.set_deferred("disabled", true)
	sprite_2d.modulate = Color.PURPLE

	await get_tree().create_timer(posture_break_time).timeout

	# รีเซ็ต Posture กลับมาเต็มหลังหมดช่วง Break
	current_posture = max_posture
	emit_enemy_stats()

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	can_receive_critical = false
	is_posture_broken = false
	is_staggered = false

	await get_tree().create_timer(stagger_recover_time).timeout

	if not is_dead:
		can_attack = true


func can_receive_focus_finisher() -> bool:
	# รับ Focus Finisher ได้เฉพาะตอน Posture Break และยังไม่ตาย
	return is_posture_broken and not is_dead


func take_focus_finisher_damage(amount: int) -> void:
	# ถ้าบอสตายแล้ว ไม่รับดาเมจซ้ำ
	if is_dead:
		return

	print("Boss HIT BY FOCUS FINISHER! Damage =", amount)
	play_placeholder_sfx(330.0, 0.22, 1.6)

	# ปิดช่อง Critical ปกติ เพื่อไม่ให้ซ้อนกับ Finisher
	can_receive_critical = false

	# ลด HP และกันไม่ให้ติดลบ
	current_hp -= amount
	current_hp = max(current_hp, 0)
	emit_enemy_stats()

	print("Boss HP left:", current_hp)

	show_damage_popup(amount, true, "FINISHER!")
	apply_hit_stop(true)
	apply_camera_shake(true)

	if current_hp <= 0:
		die()
		return

	flash_critical()


func take_damage(amount: int) -> void:
	# ถ้าบอสตายแล้ว ไม่รับดาเมจซ้ำ
	if is_dead:
		return

	var final_damage: int = amount
	var is_critical_hit: bool = false

	# ถ้าอยู่ในช่วง Posture Break และยังมีช่อง Critical ให้คูณดาเมจ
	if is_posture_broken and can_receive_critical:
		is_critical_hit = true
		final_damage = int(round(float(amount) * critical_damage_multiplier))
		can_receive_critical = false
		print("CRITICAL ATTACK! Damage =", final_damage)
	else:
		print("Boss took damage:", final_damage)

	# ลด HP และกันไม่ให้ติดลบ
	current_hp -= final_damage
	current_hp = max(current_hp, 0)
	emit_enemy_stats()

	print("Boss HP left:", current_hp)

	show_damage_popup(final_damage, is_critical_hit)
	apply_hit_stop(is_critical_hit)
	apply_camera_shake(is_critical_hit)
	apply_knockback()

	if current_hp <= 0:
		die()
		return

	if is_critical_hit:
		flash_critical()
	else:
		flash_red()


func show_damage_popup(amount: int, is_critical_hit: bool, label_text: String = "") -> void:
	# สร้าง Label สำหรับแสดงตัวเลขดาเมจ
	var popup := Label.new()

	if is_critical_hit:
		if label_text == "":
			popup.text = "CRITICAL!\n%d" % amount
		else:
			popup.text = "%s\n%d" % [label_text, amount]
		popup.modulate = Color(1.0, 0.65, 0.0, 1.0)
		popup.add_theme_font_size_override("font_size", 26)
	else:
		popup.text = "%d" % amount
		popup.modulate = Color.WHITE
		popup.add_theme_font_size_override("font_size", 22)

	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 100

	# เพิ่ม popup เข้า parent เดียวกับบอส เพื่อให้ตำแหน่ง global ทำงานง่าย
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-35.0, -85.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -45.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, 0.45)
	tween.tween_property(popup, "modulate:a", 0.0, 0.45)
	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)


func show_wrong_parry_feedback_once(target: Node) -> void:
	# กันไม่ให้ข้อความ DASH ONLY! ขึ้นซ้ำในการโจมตีท่าเดียว
	if has_shown_wrong_parry_feedback_this_attack:
		return

	has_shown_wrong_parry_feedback_this_attack = true
	print(current_attack_name, "cannot be parried! Player should DASH.")
	show_wrong_parry_feedback(target)


func show_wrong_parry_feedback(target: Node) -> void:
	# แสดงข้อความเตือนเหนือผู้เล่นเมื่อ Parry ท่าหนักผิด
	# จุดประสงค์คือให้ผู้เล่นเข้าใจทันทีว่าท่านี้ต้อง Dash เท่านั้น
	if not target is Node2D:
		return

	var target_node := target as Node2D
	var popup := Label.new()
	popup.text = heavy_wrong_parry_feedback_text
	popup.modulate = Color(1.0, 0.25, 0.05, 1.0)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 150
	popup.add_theme_font_size_override("font_size", heavy_wrong_parry_feedback_font_size)

	# เพิ่ม popup เข้า parent เดียวกับบอส เพื่อใช้ global_position ได้ง่าย
	get_parent().add_child(popup)
	popup.global_position = target_node.global_position + Vector2(-70.0, -95.0)

	# เล่นเสียงทุ้มสั้น ๆ เพื่อบอกว่าการ Parry นี้ผิดจังหวะ/ผิดวิธี
	play_placeholder_sfx(140.0, 0.10, 1.2)

	# สั่นกล้องเล็กน้อย เพื่อย้ำว่าผู้เล่นตอบสนองผิดแบบถูกลงโทษ
	get_tree().call_group(
		"game_camera",
		"shake",
		heavy_wrong_parry_camera_shake_strength,
		heavy_wrong_parry_camera_shake_duration
	)

	# ทำให้ข้อความลอยขึ้นและจางหาย
	var target_position: Vector2 = popup.global_position + Vector2(0.0, -35.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, heavy_wrong_parry_feedback_duration)
	tween.tween_property(popup, "modulate:a", 0.0, heavy_wrong_parry_feedback_duration)
	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)


func apply_hit_stop(is_critical_hit: bool) -> void:
	# เพิ่ม id เพื่อกัน Hit Stop ซ้อนกันแล้ว reset time_scale ผิด
	hit_stop_id += 1
	var my_hit_stop_id: int = hit_stop_id

	var duration: float = normal_hit_stop_time
	if is_critical_hit:
		duration = critical_hit_stop_time

	# ลดความเร็วเกมชั่วคราว
	Engine.time_scale = hit_stop_time_scale

	# ใช้ timer ที่ ignore_time_scale เพื่อไม่ให้ Hit Stop ยาวเกินจริง
	await get_tree().create_timer(duration, true, false, true).timeout

	if my_hit_stop_id != hit_stop_id:
		return

	Engine.time_scale = 1.0


func apply_camera_shake(is_critical_hit: bool) -> void:
	# เลือกความแรงกล้องสั่นตามประเภทการโจมตี
	var strength: float = normal_hit_camera_shake_strength
	var duration: float = normal_hit_camera_shake_duration

	if is_critical_hit:
		strength = critical_hit_camera_shake_strength
		duration = critical_hit_camera_shake_duration

	# เรียกกล้องใน group game_camera ให้สั่น
	get_tree().call_group("game_camera", "shake", strength, duration)


func apply_knockback() -> void:
	# ถ้าตายหรือกำลัง Posture Break ไม่ต้อง Knockback
	if is_dead or is_posture_broken:
		return

	if not is_instance_valid(player):
		return

	# คำนวณทิศกระเด็นของบอสให้ออกจาก Player
	var direction: float = sign(global_position.x - player.global_position.x)
	if direction == 0.0:
		direction = float(facing_direction)

	knockback_velocity = Vector2(direction * knockback_force, 0.0)
	is_knocked_back = true

	await get_tree().create_timer(knockback_time).timeout

	if is_instance_valid(self):
		is_knocked_back = false
		knockback_velocity = Vector2.ZERO


func flash_red() -> void:
	# เปลี่ยนสีแดงชั่วคราวเมื่อโดนโจมตีปกติ
	sprite_2d.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout

	if is_instance_valid(sprite_2d):
		if is_posture_broken:
			sprite_2d.modulate = Color.PURPLE
		else:
			sprite_2d.modulate = Color.WHITE


func flash_critical() -> void:
	# เปลี่ยนสีส้มทองชั่วคราวเมื่อโดน Critical หรือ Finisher
	sprite_2d.modulate = Color(1.0, 0.65, 0.0, 1.0)
	await get_tree().create_timer(0.15).timeout

	if is_instance_valid(sprite_2d):
		if is_posture_broken:
			sprite_2d.modulate = Color.PURPLE
		else:
			sprite_2d.modulate = Color.WHITE


func play_placeholder_sfx(frequency: float, duration: float, volume_multiplier: float = 1.0) -> void:
	# ถ้าปิดเสียง placeholder ไว้ ไม่ต้องเล่นเสียง
	if not enable_placeholder_sfx:
		return

	# สร้าง AudioStreamPlayer ชั่วคราวเพื่อเล่นเสียงสั้น ๆ
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = PLACEHOLDER_SFX_MIX_RATE
	generator.buffer_length = duration
	audio_player.stream = generator
	add_child(audio_player)
	audio_player.play()

	# ดึง playback เพื่อใส่ sample เสียงเข้าไป
	var playback: AudioStreamGeneratorPlayback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		audio_player.queue_free()
		return

	var frame_count: int = int(float(PLACEHOLDER_SFX_MIX_RATE) * duration)
	var raw_volume: float = placeholder_sfx_volume * volume_multiplier
	var final_volume: float = clampf(raw_volume, 0.0, 0.5)
	var phase: float = 0.0

	# สร้าง sine wave แบบง่าย พร้อม fade out ท้ายเสียง
	for i in range(frame_count):
		var fade: float = 1.0 - (float(i) / float(frame_count))
		var wave_value: float = sin(phase * TAU)
		var sample: float = wave_value * final_volume * fade
		playback.push_frame(Vector2(sample, sample))
		phase += frequency / float(PLACEHOLDER_SFX_MIX_RATE)

	# รอให้เสียงเล่นจบแล้วลบ player ทิ้ง
	await get_tree().create_timer(duration).timeout

	if is_instance_valid(audio_player):
		audio_player.queue_free()


func die() -> void:
	# ถ้าตายไปแล้ว ไม่ต้องทำซ้ำ
	if is_dead:
		return

	is_dead = true
	clear_attack_hint()

	# คืนความเร็วเกม เผื่อบอสตายระหว่าง Hit Stop
	Engine.time_scale = 1.0

	# ยกเลิก coroutine โจมตีเก่าที่ค้างอยู่
	attack_sequence_id += 1

	# ปิดสถานะ combat ทั้งหมด
	is_winding_up = false
	is_attacking = false
	is_staggered = false
	is_posture_broken = false
	is_knocked_back = false
	can_attack = false
	can_receive_critical = false
	has_hit_player = true
	velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO

	# ปิด hitbox เพื่อไม่ให้บอสที่ตายแล้วทำดาเมจต่อ
	attack_shape.set_deferred("disabled", true)

	print("Boss defeated!")
	play_placeholder_sfx(660.0, 0.25, 1.4)

	# แจ้ง HUD / Main ว่าชนะแล้ว
	enemy_died.emit()

	# ซ่อนบอสแทน queue_free เพื่อกัน coroutine เก่าอ้างอิง node ที่ถูกลบ
	visible = false
	set_physics_process(false)
