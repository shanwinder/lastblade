extends CharacterBody2D

# ส่งสัญญาณไปให้ HUD ทุกครั้งที่ค่า HP หรือ Posture ของศัตรูเปลี่ยน
signal enemy_stats_changed(current_hp: int, max_hp: int, current_posture: float, max_posture: float)

# ส่งสัญญาณเมื่อศัตรูตาย เพื่อให้ HUD หรือ Main แสดง Victory
signal enemy_died

# ส่งสัญญาณไปให้ HUD แสดงคำเตือนท่าโจมตีของศัตรู
# เช่น Normal Slash ให้ Parry / Heavy Slash ให้ Dash
signal enemy_attack_hint_changed(hint_text: String, hint_color: Color)

# =========================
# ค่าพื้นฐานของศัตรู
# =========================

# เลือดสูงสุดของบอส
@export var max_hp: int = 150

# ชื่อที่ HUD ใช้แสดงบนหน้าจอ
# แม้ node ในฉากจะชื่ออะไรก็ตาม ถ้า script นี้เป็นบอส HUD จะใช้คำว่า Boss
@export var combat_display_name: String = "Boss"

# ความเร็วในการเดินเข้าหาผู้เล่น
@export var move_speed: float = 95.0

# ระยะที่บอสจะหยุดเมื่อเข้าใกล้ผู้เล่น
@export var stop_distance: float = 105.0

# ดาเมจท่าปกติ
@export var attack_damage: int = 12

# เวลาก่อนบอสโจมตีจริง
@export var attack_windup_time: float = 0.70

# ระยะเวลาที่ Hitbox ของศัตรูเปิดตอนโจมตี
@export var attack_active_time: float = 0.18

# เวลารอระหว่างโจมตี
@export var attack_cooldown: float = 1.35

# =========================
# ค่าของท่าโจมตีแบบหนัก
# =========================

# โอกาสท่าหนัก
@export var heavy_attack_chance: float = 0.30

# ดาเมจท่าหนัก
@export var heavy_attack_damage: int = 22

# Wind-up ท่าหนัก
@export var heavy_attack_windup_time: float = 1.05

# Hitbox active ท่าหนัก
@export var heavy_attack_active_time: float = 0.26

# Cooldown เพิ่มหลังท่าหนัก
@export var heavy_attack_cooldown_bonus: float = 0.45

# =========================
# ค่าของท่าโจมตีแบบหน่วงจังหวะ
# =========================

# โอกาสท่า Delayed
@export var delayed_attack_chance: float = 0.25

# ดาเมจท่า Delayed
@export var delayed_attack_damage: int = 14

# ช่วง WAIT...
@export var delayed_attack_wait_time: float = 0.70

# ช่วง PARRY!
@export var delayed_attack_parry_time: float = 0.35

# Hitbox active
@export var delayed_attack_active_time: float = 0.18

# Cooldown เพิ่มหลัง Delayed
@export var delayed_attack_cooldown_bonus: float = 0.25

# ระยะเวลาที่ศัตรูชะงักเมื่อถูก Parry
@export var stagger_time: float = 0.45

# เวลาพักหลังชะงัก ก่อนกลับมาโจมตีใหม่ได้
@export var stagger_recover_time: float = 0.25

# Posture สูงสุดของบอส
@export var max_posture: float = 120.0

# Posture damage จาก Parry
@export var posture_damage_from_parry: float = 35.0

# เวลาที่บอสเสียสมดุล
@export var posture_break_time: float = 1.35

# ตัวคูณ Critical
@export var critical_damage_multiplier: float = 3.0

# ระยะเวลา Hit Stop เมื่อโจมตีปกติโดนศัตรู
# ค่านี้สั้นมาก เพื่อให้รู้สึกว่าดาบกระแทกโดนจริง
@export var normal_hit_stop_time: float = 0.06

# ระยะเวลา Hit Stop เมื่อโจมตี Critical
# Critical ควรหน่วงนานกว่านิดหนึ่ง เพื่อให้รู้สึกหนักและสะใจ
@export var critical_hit_stop_time: float = 0.12

# ความเร็วของเกมระหว่าง Hit Stop
# 0.08 แปลว่าเกมช้าลงมาก แต่ไม่หยุดสนิท
@export var hit_stop_time_scale: float = 0.08

# ความแรงที่ศัตรูจะกระเด็นเมื่อโดนผู้เล่นโจมตี
@export var knockback_force: float = 220.0

# ระยะเวลาที่ศัตรูจะถูก Knockback
@export var knockback_time: float = 0.12

# ความแรงกล้องสั่นเมื่อโจมตีปกติโดนศัตรู
@export var normal_hit_camera_shake_strength: float = 4.0

# ระยะเวลากล้องสั่นเมื่อโจมตีปกติโดนศัตรู
@export var normal_hit_camera_shake_duration: float = 0.10

# ความแรงกล้องสั่นเมื่อ Critical Attack
@export var critical_hit_camera_shake_strength: float = 9.0

# ระยะเวลากล้องสั่นเมื่อ Critical Attack
@export var critical_hit_camera_shake_duration: float = 0.18

# =========================
# ตัวแปรอ้างอิง Node
# =========================

# อ้างอิง Player
var player: CharacterBody2D

# =========================
# ระบบ Collision Layer ของศัตรู
# =========================

# Layer 1 ใช้สำหรับพื้น / กำแพง / ขอบสนาม
const WORLD_BODY_LAYER: int = 1

# Layer 2 ใช้สำหรับตัว Player
const PLAYER_BODY_LAYER: int = 2

# Layer 3 ใช้สำหรับตัว Enemy
const ENEMY_BODY_LAYER: int = 4

# ตอนปกติ Enemy ต้องชน World และ Player
const ENEMY_NORMAL_COLLISION_MASK: int = WORLD_BODY_LAYER | PLAYER_BODY_LAYER

# =========================
# ขอบเขตสนามของศัตรู
# =========================

# ขอบซ้ายของสนาม
# ใช้ค่าเดียวกับ Player เพื่อให้ทั้งสองฝ่ายอยู่ในพื้นที่เดียวกัน
@export var arena_min_x: float = 120.0

# ขอบขวาของสนาม
# ใช้ค่าเดียวกับ Player เพื่อให้ Enemy ไม่เดินหรือถูก Knockback หลุดสนาม
@export var arena_max_x: float = 1030.0

# อ้างอิง ArenaManager ถ้ามีในฉาก
# ถ้าไม่มี จะใช้ arena_min_x / arena_max_x ใน Enemy เป็น fallback
var arena_manager: Node = null

# อ้างอิง Sprite2D เพื่อใช้กลับด้านและเปลี่ยนสี
@onready var sprite_2d: Sprite2D = $Sprite2D

# อ้างอิง AttackHitbox ของศัตรู
@onready var attack_hitbox: Area2D = $AttackHitbox

# อ้างอิง CollisionShape2D ของ AttackHitbox เพื่อเปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

# =========================
# ตัวแปรสถานะ
# =========================

# เลือดปัจจุบันของศัตรู
var current_hp: int

# ใช้เช็กว่าศัตรูตายไปแล้วหรือยัง
# ป้องกันไม่ให้ die() ทำงานซ้ำหลายรอบ
var is_dead: bool = false

# Posture ปัจจุบันของศัตรู
var current_posture: float

# ใช้เช็กว่าศัตรูกำลังอยู่ในสถานะ Posture Break หรือไม่
var is_posture_broken: bool = false

# ใช้เช็กว่าศัตรูกำลังเปิดช่องให้โดน Critical อยู่หรือไม่
# จะเปิดเฉพาะตอน Posture Break และใช้ได้ 1 ครั้งต่อการ Break หนึ่งรอบ
var can_receive_critical: bool = false

# ใช้เช็กว่าศัตรูกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ใช้เช็กว่าศัตรูกำลังเตรียมโจมตีอยู่หรือไม่
# ช่วงนี้ยังไม่เปิด Hitbox แต่เปลี่ยนสีเพื่อเตือนผู้เล่น
var is_winding_up: bool = false

# ใช้เช็กว่าศัตรูกำลังชะงักจาก Parry อยู่หรือไม่
var is_staggered: bool = false

# ใช้เช็กว่าศัตรูกำลังถูก Knockback อยู่หรือไม่
var is_knocked_back: bool = false

# ความเร็ว Knockback ปัจจุบันของศัตรู
var knockback_velocity: Vector2 = Vector2.ZERO

# ใช้ล็อกไม่ให้ศัตรูเริ่มโจมตีรอบใหม่เร็วเกินไป
var can_attack: bool = true

# ใช้เช็กว่าศัตรูโจมตีโดนผู้เล่นไปแล้วหรือยังในจังหวะนี้
# เพื่อป้องกันดาเมจซ้ำจากการโจมตีครั้งเดียว
var has_hit_player: bool = false

# ชื่อท่าที่ศัตรูกำลังใช้ในรอบนี้
# ใช้สำหรับ debug และแยก logic ของท่าโจมตี
var current_attack_name: String = "normal_slash"

# ดาเมจของท่าปัจจุบัน
# จะถูกตั้งค่าทุกครั้งก่อนเริ่มโจมตี
var current_attack_damage: int = 10

# เวลาก่อนโจมตีจริงของท่าปัจจุบัน
var current_attack_windup_time: float = 0.35

# ระยะเวลาที่ Hitbox เปิดของท่าปัจจุบัน
var current_attack_active_time: float = 0.18

# cooldown ของท่าปัจจุบัน
var current_attack_cooldown: float = 1.2

# ท่าปัจจุบันสามารถ Parry ได้หรือไม่
# Normal Slash = true, Heavy Slash = false
var current_attack_can_be_parried: bool = true

# ใช้เช็กว่าท่าปัจจุบันเป็น Delayed Slash หรือไม่
# เพราะ Delayed Slash ต้องมี hint 2 ช่วง คือ WAIT... แล้วค่อย PARRY!
var current_attack_is_delayed: bool = false

# เวลารอก่อนเข้าสู่ช่วง Parry ของท่า Delayed Slash
var current_attack_delay_wait_time: float = 0.0

# ข้อความ hint หลักของท่าปัจจุบัน
var current_attack_hint_text: String = "PARRY!"

# สีของ hint หลักของท่าปัจจุบัน
var current_attack_hint_color: Color = Color.YELLOW

# ใช้ยกเลิก attack coroutine เก่าที่ค้างอยู่
# ทุกครั้งที่เริ่ม attack ใหม่หรือถูก parry เราจะเพิ่มค่านี้
var attack_sequence_id: int = 0

# ใช้กัน Hit Stop ซ้อนกันหลายรอบ
# ถ้ามี Hit Stop ใหม่เข้ามา จะให้รอบล่าสุดเป็นตัวควบคุม
var hit_stop_id: int = 0

# ทิศที่ศัตรูหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = -1

# ระยะห่างของ Hitbox ศัตรูจากตัวศัตรู
var attack_hitbox_offset_x: float = 55.0


func _ready() -> void:
	# สุ่มค่าเริ่มต้น เพื่อให้การเลือกท่าโจมตีไม่ซ้ำแบบเดิมทุกครั้งที่เปิดเกม
	randomize()
	
	# เพิ่มบอสเข้า group combat_target
	# HUD จะใช้ group นี้ในการหาเป้าหมายต่อสู้หลัก
	# ทำให้ไม่ต้องล็อกชื่อ node ว่าต้องเป็น EnemyDummy อีกต่อไป
	add_to_group("combat_target")
	
	# ตั้ง Layer ของศัตรูให้เป็น Layer Enemy
	collision_layer = ENEMY_BODY_LAYER

	# ให้ศัตรูชน World และ Player ตามปกติ
	collision_mask = ENEMY_NORMAL_COLLISION_MASK

	# หา ArenaManager จาก group
	# ถ้ามี จะใช้ขอบสนามจาก ArenaManager แทนค่าที่ตั้งใน Enemy
	var arena_nodes := get_tree().get_nodes_in_group("arena_manager")
	if arena_nodes.size() > 0:
		arena_manager = arena_nodes[0]
		print("Boss found ArenaManager")
	else:
		print("Boss using fallback arena bounds")
		
	# ตั้งเลือดเริ่มต้นของศัตรู
	current_hp = max_hp

	# ตั้งค่า Posture เริ่มต้นให้เต็ม
	current_posture = max_posture

	# หา node Player
	# จาก GitHub ตอนนี้ node ผู้เล่นชื่อ Player ตัว P ใหญ่
	player = get_parent().get_node("Player")

	# ปิด Hitbox ของศัตรูไว้ก่อน
	attack_shape.disabled = true

	# วาง Hitbox ไว้ด้านหน้าศัตรู
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ของศัตรูชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Boss Broken Master ready. HP =", current_hp)

	# ส่งค่าเริ่มต้นให้ HUD แสดง Enemy Posture
	emit_enemy_stats()

func clamp_to_arena() -> void:
	# ถ้ามี ArenaManager ให้ใช้ค่าขอบสนามจาก ArenaManager
	if is_instance_valid(arena_manager) and arena_manager.has_method("clamp_node_x"):
		arena_manager.clamp_node_x(self)
		return

	# ถ้าไม่มี ArenaManager ให้ใช้ค่าที่ตั้งไว้ใน Enemy เป็น fallback
	global_position.x = clamp(global_position.x, arena_min_x, arena_max_x)

func _physics_process(_delta: float) -> void:
	# ถ้าศัตรูตายแล้ว ไม่ต้องทำ AI ต่อ
	if is_dead:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()

		# กันตำแหน่งศัตรูไม่ให้หลุดสนาม แม้ตอนตาย
		clamp_to_arena()

		return

	# ถ้าศัตรูกำลังถูก Knockback ให้ขยับตามแรงกระเด็น
	if is_knocked_back:
		velocity = knockback_velocity
		move_and_slide()

		# กันไม่ให้ Knockback ดันศัตรูออกนอกสนาม
		clamp_to_arena()

		return
		
	# ถ้าผู้เล่นไม่อยู่แล้ว เช่น ตายไป ให้ศัตรูหยุด
	if not is_instance_valid(player):
		velocity.x = 0
		velocity.y = 0
		move_and_slide()

		# กันตำแหน่งศัตรูไม่ให้หลุดสนาม
		clamp_to_arena()

		return

	# ถ้ากำลังชะงักจาก Parry ให้หยุดนิ่ง
	if is_staggered:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()

		# ศัตรูที่ชะงักต้องยังอยู่ในสนาม
		clamp_to_arena()

		return

	# ถ้ากำลังเตรียมโจมตีหรือกำลังโจมตี ให้หยุดอยู่กับที่
	if is_winding_up or is_attacking:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()

		# ระหว่างเตรียมโจมตีหรือโจมตีจริง ศัตรูต้องไม่หลุดสนาม
		clamp_to_arena()

		return

	# คำนวณระยะห่างระหว่างศัตรูกับผู้เล่นในแกน x
	var distance_to_player: float = player.global_position.x - global_position.x

	# กำหนดทิศที่ศัตรูควรหันหน้าไป
	if distance_to_player != 0:
		facing_direction = sign(distance_to_player)
		sprite_2d.flip_h = facing_direction < 0
		attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# ถ้ายังอยู่ไกล ให้เดินเข้าหาผู้เล่น
	if abs(distance_to_player) > stop_distance:
		velocity.x = facing_direction * move_speed
	else:
		# ถ้าอยู่ใกล้พอ ให้หยุดแล้วโจมตีเมื่อ cooldown พร้อม
		velocity.x = 0

		if can_attack:
			attack()

	velocity.y = 0
	move_and_slide()
	
	# จำกัดไม่ให้ศัตรูเดินออกนอกสนาม
	clamp_to_arena()


func emit_enemy_stats() -> void:
	# ส่งค่า HP และ Posture ของศัตรูไปให้ HUD
	enemy_stats_changed.emit(current_hp, max_hp, current_posture, max_posture)
	
func emit_attack_hint() -> void:
	# ส่งข้อความเตือนตามท่าปัจจุบัน
	# Normal = PARRY!, Heavy = DASH!, Delayed ช่วงแรก = WAIT...
	enemy_attack_hint_changed.emit(current_attack_hint_text, current_attack_hint_color)

func clear_attack_hint() -> void:
	# ส่งข้อความว่าง เพื่อให้ HUD ซ่อนคำเตือน
	enemy_attack_hint_changed.emit("", Color.WHITE)

func emit_delayed_parry_hint() -> void:
	# ช่วงท้ายของ Delayed Slash ให้บอกผู้เล่นว่าตอนนี้ค่อย Parry
	enemy_attack_hint_changed.emit("PARRY!", Color.YELLOW)
	
func choose_attack_pattern() -> void:
	# สุ่มเลข 0.0 ถึง 1.0 เพื่อเลือก pattern การโจมตี
	var roll: float = randf()

	# รีเซ็ตค่าเริ่มต้นของท่าปัจจุบันก่อนเลือกท่าใหม่
	current_attack_is_delayed = false
	current_attack_delay_wait_time = 0.0

	# ถ้าสุ่มได้อยู่ในช่วง Delayed Slash ให้ใช้ท่าหน่วงจังหวะ
	if roll < delayed_attack_chance:
		current_attack_name = "delayed_slash"

		# ท่านี้ Parry ได้ แต่ต้องรอจังหวะท้าย
		current_attack_can_be_parried = true

		# ใช้ดาเมจของ Delayed Slash
		current_attack_damage = delayed_attack_damage

		# เวลารวมก่อนฟันจริง = ช่วง WAIT + ช่วง PARRY
		current_attack_windup_time = delayed_attack_wait_time + delayed_attack_parry_time

		# เก็บเวลาช่วง WAIT ไว้ใช้แยก hint
		current_attack_delay_wait_time = delayed_attack_wait_time

		# Hitbox เปิดตามค่าของท่านี้
		current_attack_active_time = delayed_attack_active_time

		# cooldown เพิ่มเล็กน้อย เพราะเป็นท่าหลอกจังหวะ
		current_attack_cooldown = attack_cooldown + delayed_attack_cooldown_bonus

		# ทำเครื่องหมายว่าท่านี้เป็น delayed
		current_attack_is_delayed = true

		# ช่วงแรกให้ HUD บอก WAIT... ไม่ใช่ PARRY! ทันที
		current_attack_hint_text = "WAIT..."
		current_attack_hint_color = Color(0.75, 0.35, 1.0, 1.0)

		print("Boss chose DELAYED SLASH! Wait, then parry.")

	# ถ้าไม่ใช่ Delayed แต่ยังอยู่ในช่วง Heavy ให้ใช้ Heavy Slash
	elif roll < delayed_attack_chance + heavy_attack_chance:
		current_attack_name = "heavy_slash"

		# ท่าหนักแรงกว่า
		current_attack_damage = heavy_attack_damage

		# ท่าหนักมี wind-up นานกว่า เพื่อให้ผู้เล่นอ่านท่า
		current_attack_windup_time = heavy_attack_windup_time

		# ท่าหนักเปิด Hitbox นานกว่านิดหนึ่ง
		current_attack_active_time = heavy_attack_active_time

		# ท่าหนักมี cooldown เพิ่ม เพื่อเปิดช่องให้ผู้เล่นสวนกลับ
		current_attack_cooldown = attack_cooldown + heavy_attack_cooldown_bonus

		# ท่าหนัก Parry ไม่ได้ ผู้เล่นควร Dash หลบ
		current_attack_can_be_parried = false

		# Hint ของ Heavy คือ DASH!
		current_attack_hint_text = "DASH!"
		current_attack_hint_color = Color(1.0, 0.35, 0.0, 1.0)

		print("Boss chose HEAVY SLASH! Dash required.")

	else:
		current_attack_name = "normal_slash"

		# ท่าปกติใช้ดาเมจเดิม
		current_attack_damage = attack_damage

		# ท่าปกติใช้ wind-up เดิม
		current_attack_windup_time = attack_windup_time

		# ท่าปกติใช้ active time เดิม
		current_attack_active_time = attack_active_time

		# ท่าปกติใช้ cooldown เดิม
		current_attack_cooldown = attack_cooldown

		# ท่าปกติ Parry ได้
		current_attack_can_be_parried = true

		# Hint ของ Normal คือ PARRY!
		current_attack_hint_text = "PARRY!"
		current_attack_hint_color = Color.YELLOW

		print("Boss chose NORMAL SLASH! Parry possible.")

func attack() -> void:
	# ถ้ากำลังเตรียมโจมตี / กำลังโจมตี / กำลังชะงัก / ยังไม่พร้อมโจมตี ห้ามเริ่มโจมตีใหม่
	if is_winding_up or is_attacking or is_staggered or not can_attack:
		return

	# เลือก pattern การโจมตีของรอบนี้ก่อนเริ่มโจมตี
	choose_attack_pattern()

	# ล็อกไม่ให้เริ่มโจมตีซ้อน
	is_winding_up = true
	can_attack = false

	# รีเซ็ตว่าโจมตีครั้งนี้ยังไม่โดนผู้เล่น
	has_hit_player = false

	# เพิ่มเลข sequence เพื่อระบุว่า attack รอบนี้คือรอบล่าสุด
	attack_sequence_id += 1
	var my_attack_id := attack_sequence_id

	print("Boss Wind-up:", current_attack_name)

	# ส่งคำเตือนขึ้น HUD เพื่อให้ผู้เล่นอ่านท่าได้จากจอ ไม่ต้องดู console
	emit_attack_hint()

	# แสดงสีเตือนตามชนิดท่า
	if current_attack_can_be_parried:
		# สีเหลือง = ท่าปกติ Parry ได้
		sprite_2d.modulate = Color.YELLOW
	else:
		# สีส้ม = ท่าหนัก Parry ไม่ได้ ควร Dash หลบ
		sprite_2d.modulate = Color(1.0, 0.35, 0.0, 1.0)

	# ถ้าเป็น Delayed Slash จะมี 2 ช่วง
	# ช่วงแรก HUD ขึ้น WAIT... เพื่อห้ามผู้เล่นรีบ Parry
	# ช่วงท้าย HUD ค่อยเปลี่ยนเป็น PARRY!
	if current_attack_is_delayed:
		# แสดงสีม่วงเพื่อบอกว่านี่คือท่าหน่วงจังหวะ
		if is_instance_valid(sprite_2d):
			sprite_2d.modulate = Color(0.75, 0.35, 1.0, 1.0)

		# รอช่วงหลอกจังหวะ
		await get_tree().create_timer(current_attack_delay_wait_time).timeout

		# ถ้าระหว่างรอถูกยกเลิก เช่น Posture Break หรือตาย ให้หยุดทันที
		if my_attack_id != attack_sequence_id or is_dead:
			return

		# เข้าสู่ช่วงที่ผู้เล่นควรกด Parry
		emit_delayed_parry_hint()

		# เปลี่ยนเป็นสีเหลืองเพื่อบอกว่าช่วงนี้ Parry ได้แล้ว
		if is_instance_valid(sprite_2d):
			sprite_2d.modulate = Color.YELLOW

		# รอช่วงท้ายก่อนฟันจริง
		await get_tree().create_timer(delayed_attack_parry_time).timeout
	else:
		# ท่าปกติและท่าหนักใช้ wind-up แบบเดิม
		await get_tree().create_timer(current_attack_windup_time).timeout

	# ถ้าระหว่าง wind-up ถูกยกเลิก เช่น ถูก Parry/Break/ตาย ให้หยุดทันที
	if my_attack_id != attack_sequence_id or is_dead:
		return

	# จบช่วง wind-up
	is_winding_up = false

	# เริ่มโจมตีจริง
	is_attacking = true

	# ล้างคำเตือนเมื่อเข้าสู่จังหวะโจมตีจริง
	# เพราะผู้เล่นต้องตัดสินใจไปแล้วในช่วง Wind-up
	clear_attack_hint()

	# เปลี่ยนสีกลับก่อนเปิด Hitbox
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	print("Boss Attack! Hitbox ON:", current_attack_name)

	# เปิด Hitbox ของศัตรูแบบ deferred เพื่อปลอดภัยกับระบบ physics
	attack_shape.set_deferred("disabled", false)

	# รอหนึ่ง physics frame เพื่อให้ Godot เปิด hitbox จริงก่อน
	await get_tree().physics_frame

	# ถ้าระหว่างรอถูกยกเลิก เช่น ถูก Parry ให้หยุด attack รอบนี้ทันที
	if my_attack_id != attack_sequence_id or is_dead:
		return

	# ตรวจพื้นที่ที่ overlap อยู่แล้วด้วย
	# เพื่อให้ hitbox โดนได้แม้ Area ซ้อนกันอยู่ตั้งแต่ก่อนเปิด Hitbox
	for area in attack_hitbox.get_overlapping_areas():
		_try_hit_area(area)

	# รอช่วงที่การโจมตีมีผลตามท่าปัจจุบัน
	await get_tree().create_timer(current_attack_active_time).timeout

	# ถ้า attack รอบนี้ถูกยกเลิกระหว่างทาง เช่น ถูก Parry ให้หยุดทันที
	if my_attack_id != attack_sequence_id or is_dead:
		return

	# ปิด Hitbox หลังหมดจังหวะโจมตี
	attack_shape.set_deferred("disabled", true)
	print("Boss Hitbox OFF:", current_attack_name)

	# จบสถานะโจมตี
	is_attacking = false

	# รอ cooldown ตามท่าปัจจุบันก่อนโจมตีครั้งต่อไป
	await get_tree().create_timer(current_attack_cooldown).timeout

	# ถ้า attack รอบนี้ถูกยกเลิกไปแล้ว ไม่ต้องเปิด can_attack
	if my_attack_id != attack_sequence_id or is_dead:
		return

	# อนุญาตให้โจมตีรอบใหม่
	can_attack = true

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# เมื่อ hitbox ชน area อื่น ให้ส่งไปตรวจในฟังก์ชันกลาง
	_try_hit_area(area)


func _try_hit_area(area: Area2D) -> void:
	# ถ้าไม่ได้กำลังโจมตี ก็ไม่ทำดาเมจ
	if not is_attacking:
		return

	# ถ้าศัตรูกำลังชะงักอยู่ ก็ไม่ทำดาเมจ
	if is_staggered:
		return

	# ถ้าโจมตีโดนผู้เล่นไปแล้วในครั้งนี้ ไม่ทำซ้ำ
	if has_hit_player:
		return

	# ตรวจเฉพาะ Area ที่ชื่อ Hurtbox เท่านั้น
	if area.name != "Hurtbox":
		return

	# หา parent ของ Hurtbox ที่ถูกชน
	var target = area.get_parent()

	# ถ้า target คือตัวศัตรูเอง ให้ข้าม
	# ป้องกัน EnemyDummy โจมตีโดน Hurtbox ของตัวเอง
	if target == self:
		print("Boss attack ignored own Hurtbox")
		return

	# ถ้าเป้าหมายไม่มีฟังก์ชัน take_damage ก็ไม่ต้องทำอะไร
	if not target.has_method("take_damage"):
		return

	# เช็กก่อนว่าเป้าหมายมีระบบ Parry หรือไม่
	# แต่ Parry จะสำเร็จเฉพาะท่าที่อนุญาตให้ Parry ได้เท่านั้น
	if current_attack_can_be_parried and target.has_method("is_parry_active") and target.is_parry_active():
		# ถ้า Player กำลัง Parry อยู่ ถือว่า Parry สำเร็จ
		has_hit_player = true
		print("Boss attack was parried!")

		# เรียก feedback ฝั่ง Player
		if target.has_method("on_successful_parry"):
			target.on_successful_parry()

		# ลด Posture ของศัตรูเมื่อ Parry สำเร็จ
		reduce_posture(posture_damage_from_parry)

		# ถ้า Posture ยังไม่แตก ให้ stagger แบบสั้น
		# ถ้า Posture แตกแล้ว posture_break() จะจัดการเอง
		if not is_posture_broken:
			stagger()

		# ไม่ทำดาเมจ เพราะถูก Parry
		return

	# ถ้าผู้เล่นพยายาม Parry ท่าหนัก ให้แจ้งใน console
	# ท่าหนักออกแบบมาให้ Dash หลบ ไม่ใช่ Parry
	if not current_attack_can_be_parried and target.has_method("is_parry_active") and target.is_parry_active():
		print(current_attack_name, " cannot be parried! Player should dash.")

	# ถ้าไม่ได้ Parry สำเร็จ ให้ทำดาเมจตามค่าของท่าปัจจุบัน
	has_hit_player = true
	target.take_damage(current_attack_damage)

func stagger() -> void:
	# ถ้ากำลังชะงักอยู่แล้ว ไม่ต้องเริ่มซ้ำ
	if is_staggered:
		return

	print("Boss staggered!")

	# ล้างคำเตือน เพราะท่าโจมตีถูกยกเลิกแล้ว
	clear_attack_hint()

	# เพิ่ม sequence เพื่อยกเลิก attack coroutine เก่าที่อาจยัง await ค้างอยู่
	attack_sequence_id += 1

	# ตั้งสถานะศัตรูให้ชะงัก
	is_staggered = true
	is_winding_up = false
	is_attacking = false
	can_attack = false
	has_hit_player = true

	# หยุดการเคลื่อนที่ของศัตรู
	velocity.x = 0
	velocity.y = 0

	# ปิด Hitbox แบบ deferred เพื่อหลีกเลี่ยง error flushing queries
	attack_shape.set_deferred("disabled", true)

	# เปลี่ยนสีเป็นฟ้าเพื่อแสดงว่าศัตรูถูก Parry
	sprite_2d.modulate = Color.CYAN

	# หยุดนิ่งสั้น ๆ ให้ผู้เล่นรู้สึกว่า Parry สำเร็จ
	await get_tree().create_timer(stagger_time).timeout

	# ถ้า sprite ยังอยู่ในเกม ให้เปลี่ยนกลับเป็นสีขาว
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	# จบสถานะชะงัก
	is_staggered = false

	# เว้นจังหวะอีกนิดก่อนให้ศัตรูกลับมาโจมตีใหม่
	await get_tree().create_timer(stagger_recover_time).timeout

	# อนุญาตให้โจมตีใหม่
	can_attack = true


func reduce_posture(amount: float) -> void:
	# ถ้าศัตรูกำลัง Posture Break อยู่แล้ว ไม่ต้องลดซ้ำ
	if is_posture_broken:
		return

	# ลด Posture ตามจำนวนที่กำหนด
	current_posture -= amount
	current_posture = clamp(current_posture, 0.0, max_posture)

	print("Enemy posture reduced:", int(current_posture), "/", int(max_posture))

	# แจ้ง HUD ว่า Posture เปลี่ยนแล้ว
	emit_enemy_stats()

	# ถ้า Posture หมด ให้เข้าสถานะ Break
	if current_posture <= 0:
		posture_break()


func posture_break() -> void:
	# ถ้า Break อยู่แล้ว ไม่ต้องเริ่มซ้ำ
	if is_posture_broken:
		return

	print("Boss POSTURE BROKEN!")

	# ล้างคำเตือน เพราะศัตรูเสียสมดุลและหยุดโจมตีแล้ว
	clear_attack_hint()

	# ตั้งสถานะ Break
	is_posture_broken = true

	# เปิดช่องให้ Player โจมตี Critical ได้ 1 ครั้ง
	can_receive_critical = true
	print("Critical chance opened!")

	# เพิ่ม sequence เพื่อยกเลิก attack coroutine เก่าที่อาจยัง await ค้างอยู่
	attack_sequence_id += 1

	# ระหว่าง Break ศัตรูห้ามโจมตีและห้ามขยับ
	is_staggered = true
	is_winding_up = false
	is_attacking = false
	can_attack = false
	has_hit_player = true

	# ปิด Hitbox ศัตรู
	attack_shape.set_deferred("disabled", true)

	# เปลี่ยนสีเป็นม่วง เพื่อให้ต่างจาก stagger ปกติ
	sprite_2d.modulate = Color.PURPLE

	# หยุดนิ่งนานกว่า stagger ปกติ
	await get_tree().create_timer(posture_break_time).timeout

	# รีเซ็ต Posture กลับมาเต็ม
	current_posture = max_posture
	emit_enemy_stats()

	# กลับสีปกติ
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	# ปิดช่อง Critical เมื่อหมดช่วง Posture Break
	can_receive_critical = false

	# จบสถานะ Break
	is_posture_broken = false
	is_staggered = false

	# เว้นจังหวะนิดหนึ่งก่อนกลับมาโจมตี
	await get_tree().create_timer(stagger_recover_time).timeout

	can_attack = true

func can_receive_focus_finisher() -> bool:
	# ศัตรูจะรับ Focus Finisher ได้เฉพาะตอน Posture Break
	# และยังไม่ตายเท่านั้น
	return is_posture_broken and not is_dead

func take_focus_finisher_damage(amount: int) -> void:
	# ถ้าศัตรูตายแล้ว ไม่รับดาเมจซ้ำ
	if is_dead:
		return

	print("ENEMY HIT BY FOCUS FINISHER! Damage =", amount)

	# ปิดช่อง Critical ปกติ เพื่อไม่ให้ซ้อนกับระบบ Critical เดิม
	can_receive_critical = false

	# ลด HP โดยตรง
	current_hp -= amount
	current_hp = max(current_hp, 0)

	# อัปเดต HUD
	emit_enemy_stats()

	print("Enemy HP left:", current_hp)

	# แสดงตัวเลขดาเมจแบบ Critical/Finisher
	show_damage_popup(amount, true, "FINISHER!")

	# Hit Stop แบบ Critical
	apply_hit_stop(true)

	# Camera Shake แบบ Critical
	apply_camera_shake(true)

	# ถ้า HP หมด ให้ตาย
	if current_hp <= 0:
		die()
		return

	# ใช้ flash_critical เพื่อให้เห็นว่าท่านี้เป็นท่าหนัก
	flash_critical()
	
func take_damage(amount: int) -> void:
	# ถ้าศัตรูตายแล้ว ไม่รับดาเมจซ้ำ
	if is_dead:
		return

	# เก็บดาเมจสุดท้ายที่จะนำไปลด HP จริง
	var final_damage: int = amount

	# ใช้เช็กว่าการโจมตีครั้งนี้เป็น Critical หรือไม่
	var is_critical_hit: bool = false

	# ถ้าศัตรูกำลัง Posture Break และยังเปิดช่อง Critical อยู่
	# การโจมตีครั้งนี้จะกลายเป็น Critical Attack
	if is_posture_broken and can_receive_critical:
		is_critical_hit = true

		# คูณดาเมจตามค่า critical_damage_multiplier
		final_damage = int(round(float(amount) * critical_damage_multiplier))

		# ปิด Critical ทันที เพื่อให้ใช้ได้แค่ 1 ครั้งต่อการ Break หนึ่งรอบ
		can_receive_critical = false

		print("CRITICAL ATTACK! Damage =", final_damage)
	else:
		print("Enemy took damage:", final_damage)

	# ลด HP ของศัตรูด้วยดาเมจสุดท้าย
	current_hp -= final_damage

	# กันไม่ให้ HP ติดลบ
	current_hp = max(current_hp, 0)

	# แจ้ง HUD ว่า HP ศัตรูเปลี่ยนแล้ว
	emit_enemy_stats()

	print("Enemy HP left:", current_hp)

	# แสดงตัวเลขดาเมจลอยขึ้นเหนือศัตรู
	show_damage_popup(final_damage, is_critical_hit)

	# ทำ Hit Stop เพื่อให้จังหวะโจมตีรู้สึกมีน้ำหนัก
	apply_hit_stop(is_critical_hit)

	# ทำ Camera Shake เพื่อเพิ่มแรงกระแทกทางภาพ
	apply_camera_shake(is_critical_hit)
	
	# ทำ Knockback ให้ศัตรูถอยหลังเมื่อโดนตี
	apply_knockback()

	# ถ้า HP หมด ให้ตายทันที
	# วางไว้ก่อน flash เพื่อไม่ให้ศัตรูกระพริบแล้วกลับมาขาวหลังตาย
	if current_hp <= 0:
		die()
		return

	# ถ้าเป็น Critical ให้ใช้เอฟเฟกต์สีส้ม
	# ถ้าเป็นการโจมตีปกติ ให้กระพริบแดงแบบเดิม
	if is_critical_hit:
		flash_critical()
	else:
		flash_red()


func flash_red() -> void:
	# เปลี่ยนสีศัตรูเป็นแดงชั่วคราวเมื่อโดนตีปกติ
	sprite_2d.modulate = Color.RED

	# รอ 0.1 วินาที
	await get_tree().create_timer(0.1).timeout

	# ถ้า sprite ยังอยู่ ให้เปลี่ยนกลับตามสถานะปัจจุบัน
	if is_instance_valid(sprite_2d):
		# ถ้ายัง Posture Break อยู่ ให้กลับเป็นสีม่วง
		if is_posture_broken:
			sprite_2d.modulate = Color.PURPLE
		else:
			sprite_2d.modulate = Color.WHITE


func show_damage_popup(amount: int, is_critical_hit: bool, label_text: String = "") -> void:
	# สร้าง Label ใหม่ขึ้นมาเพื่อใช้แสดงตัวเลขดาเมจ
	var popup := Label.new()

	# ถ้าเป็น Critical ให้แสดงข้อความใหญ่และเด่นกว่า
	if is_critical_hit:
		if label_text == "":
			popup.text = "CRITICAL!\n%d" % amount
		else:
			popup.text = "%s\n%d" % [label_text, amount]
		popup.modulate = Color(1.0, 0.65, 0.0, 1.0) # สีส้มทอง
		popup.add_theme_font_size_override("font_size", 26)
	else:
		popup.text = "%d" % amount
		popup.modulate = Color.WHITE
		popup.add_theme_font_size_override("font_size", 22)

	# จัดข้อความให้อยู่กึ่งกลาง
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# ให้ตัวเลขอยู่หน้าสุด
	popup.z_index = 100

	# เพิ่ม popup เข้าไปในฉากเดียวกับศัตรู
	# ใช้ get_parent() เพราะ EnemyDummy อยู่ใต้ Main
	get_parent().add_child(popup)

	# วางตำแหน่ง popup เหนือหัวศัตรูเล็กน้อย
	popup.global_position = global_position + Vector2(-35, -85)

	# จุดปลายทางที่ตัวเลขจะลอยขึ้นไป
	var target_position := popup.global_position + Vector2(0, -45)

	# สร้าง Tween เพื่อให้ตัวเลขลอยขึ้นและค่อย ๆ จางหาย
	var tween := create_tween()

	# ให้ animation หลายอย่างทำพร้อมกัน
	tween.set_parallel(true)

	# ขยับตัวเลขขึ้น
	tween.tween_property(popup, "global_position", target_position, 0.45)

	# ค่อย ๆ ทำให้โปร่งใสจนหายไป
	tween.tween_property(popup, "modulate:a", 0.0, 0.45)

	# หลัง animation จบ ให้ลบ popup ออกจากฉาก
	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)

func apply_hit_stop(is_critical_hit: bool) -> void:
	# เพิ่ม id ทุกครั้งที่เริ่ม Hit Stop
	# เพื่อให้ถ้ามี Hit Stop ใหม่ซ้อนเข้ามา รอบเก่าจะไม่แย่ง reset time_scale
	hit_stop_id += 1
	var my_hit_stop_id := hit_stop_id

	# เลือกระยะเวลาตามประเภทการโจมตี
	var duration := normal_hit_stop_time

	if is_critical_hit:
		duration = critical_hit_stop_time

	# ลดความเร็วเวลาของทั้งเกมชั่วคราว
	# ทำให้การโจมตีรู้สึกกระแทกและมีน้ำหนัก
	Engine.time_scale = hit_stop_time_scale

	# รอด้วย timer ที่ ignore_time_scale = true
	# สำคัญมาก: ถ้าไม่ ignore time scale ตัว timer จะช้าตามเกม ทำให้ Hit Stop ยาวเกินไป
	await get_tree().create_timer(duration, true, false, true).timeout

	# ถ้ามี Hit Stop รอบใหม่เริ่มไปแล้ว ไม่ต้อง reset จากรอบเก่า
	if my_hit_stop_id != hit_stop_id:
		return

	# คืนความเร็วเกมกลับเป็นปกติ
	Engine.time_scale = 1.0

func apply_knockback() -> void:
	# ถ้าศัตรูตายแล้ว ไม่ต้อง Knockback
	if is_dead:
		return

	# ถ้าศัตรูกำลัง Posture Break อยู่ ไม่ต้องผลัก
	# เพราะช่วง Break ต้องการให้ศัตรูหยุดนิ่งเพื่อเปิดช่อง Critical
	if is_posture_broken:
		return

	# ถ้าไม่มี Player แล้ว ไม่ต้องคำนวณทิศ
	if not is_instance_valid(player):
		return

	# คำนวณทิศกระเด็นของศัตรู
	# ถ้าศัตรูอยู่ขวาของ Player ให้กระเด็นไปทางขวา
	# ถ้าศัตรูอยู่ซ้ายของ Player ให้กระเด็นไปทางซ้าย
	var direction: float = sign(global_position.x - player.global_position.x)

	# ถ้าทับตำแหน่งกันพอดี ให้ใช้ทิศที่ศัตรูหันอยู่แทน
	if direction == 0.0:
		direction = float(facing_direction)

	# ตั้งค่าแรง Knockback ของศัตรู
	knockback_velocity = Vector2(direction * knockback_force, 0.0)

	# เริ่มสถานะ Knockback
	is_knocked_back = true

	# รอระยะเวลา Knockback
	await get_tree().create_timer(knockback_time).timeout

	# ถ้าศัตรูยังอยู่ ให้จบ Knockback
	if is_instance_valid(self):
		is_knocked_back = false
		knockback_velocity = Vector2.ZERO

func apply_camera_shake(is_critical_hit: bool) -> void:
	# ตั้งค่ากล้องสั่นเริ่มต้นเป็นแบบโจมตีปกติ
	var strength := normal_hit_camera_shake_strength
	var duration := normal_hit_camera_shake_duration

	# ถ้าเป็น Critical ให้กล้องสั่นแรงและนานขึ้น
	if is_critical_hit:
		strength = critical_hit_camera_shake_strength
		duration = critical_hit_camera_shake_duration

	# เรียกกล้องที่อยู่ใน group game_camera ให้สั่น
	# ถ้าในฉากยังไม่มีกล้อง group นี้ คำสั่งนี้จะไม่ error แค่ไม่มีอะไรเกิดขึ้น
	get_tree().call_group("game_camera", "shake", strength, duration)


func flash_critical() -> void:
	# เปลี่ยนสีศัตรูเป็นสีส้มทอง เพื่อแสดงว่าโดน Critical
	sprite_2d.modulate = Color(1.0, 0.65, 0.0, 1.0)

	# รอสั้น ๆ ให้ผู้เล่นเห็น feedback
	await get_tree().create_timer(0.15).timeout

	# ถ้าศัตรูยังอยู่ ให้ปรับสีกลับ
	if is_instance_valid(sprite_2d):
		# ถ้ายังอยู่ในช่วง Posture Break ให้กลับเป็นสีม่วง
		if is_posture_broken:
			sprite_2d.modulate = Color.PURPLE
		else:
			sprite_2d.modulate = Color.WHITE


func die() -> void:
	# ถ้าตายไปแล้ว ไม่ต้องทำซ้ำ
	if is_dead:
		return

	# ตั้งสถานะว่าตายแล้ว
	is_dead = true

	# ล้างคำเตือนบน HUD เมื่อศัตรูตาย
	clear_attack_hint()

	# คืนความเร็วเกมกลับเป็นปกติ เผื่อศัตรูตายระหว่าง Hit Stop
	Engine.time_scale = 1.0

	# ยกเลิก attack coroutine เก่าที่อาจค้างอยู่
	attack_sequence_id += 1

	# ปิดสถานะต่อสู้ทั้งหมด
	is_winding_up = false
	is_attacking = false
	is_staggered = false
	is_posture_broken = false
	can_attack = false
	can_receive_critical = false
	has_hit_player = true

	# หยุดการเคลื่อนที่
	velocity.x = 0
	velocity.y = 0

	# ปิด Hitbox ของศัตรู
	attack_shape.set_deferred("disabled", true)

	print("Enemy defeated!")

	# ส่งสัญญาณไปให้ HUD แสดง Victory
	enemy_died.emit()

	# ซ่อนศัตรูไว้ก่อน แทนการ queue_free ทันที
	# เพื่อป้องกัน coroutine เก่าที่ยัง await แล้วพยายามเปลี่ยนสี/สถานะ
	visible = false
	set_physics_process(false)
