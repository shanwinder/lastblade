extends CharacterBody2D

# ส่งสัญญาณไปให้ HUD ทุกครั้งที่ HP, Stamina หรือ Focus เปลี่ยน
signal stats_changed(
	current_hp: int,
	max_hp: int,
	current_stamina: float,
	max_stamina: float,
	current_focus: float,
	max_focus: float
)

# ส่งสัญญาณเมื่อ Player ตาย เพื่อให้ HUD หรือ Main แสดง Game Over
signal player_died

# =========================
# ค่าพื้นฐานของผู้เล่น
# =========================

# ความเร็วในการเดินปกติ
@export var speed: float = 200.0

# ความเร็วตอน Dash
@export var dash_speed: float = 650.0

# ระยะเวลาที่ Dash มีผล
@export var dash_time: float = 0.18

# เวลารอหลัง Dash ก่อนจะ Dash ได้อีกครั้ง
@export var dash_cooldown: float = 0.45

# ดาเมจที่ผู้เล่นทำได้เมื่อโจมตีโดนศัตรู
@export var attack_damage: int = 10

# เลือดสูงสุดของผู้เล่น
@export var max_hp: int = 100

# Stamina สูงสุดของผู้เล่น
@export var max_stamina: float = 100.0

# Focus สูงสุดของผู้เล่น
# ใช้สะสมจากการ Parry สำเร็จ เพื่อใช้ Focus Finisher
@export var max_focus: float = 100.0

# ความเร็วในการฟื้น Stamina ต่อวินาที
@export var stamina_regen_rate: float = 20.0

# Stamina ที่ใช้เมื่อโจมตีหนึ่งครั้ง
@export var attack_stamina_cost: float = 18.0

# Stamina ที่ใช้เมื่อ Dash หนึ่งครั้ง
@export var dash_stamina_cost: float = 30.0

# Stamina ที่ใช้เมื่อกด Parry หนึ่งครั้ง
@export var parry_stamina_cost: float = 20.0

# จำนวน Focus ที่ได้รับเมื่อ Parry สำเร็จ
@export var focus_gain_on_successful_parry: float = 15.0

# Focus ที่ต้องใช้เพื่อทำ Finisher
@export var focus_finisher_cost: float = 100.0

# สัดส่วนดาเมจของ Finisher เทียบกับ HP สูงสุดของศัตรู
# 0.40 = 40% ของ HP สูงสุดศัตรู
@export var focus_finisher_damage_ratio: float = 0.40

# ระยะเวลาที่ Parry มีผลจริง
# ค่านี้คือหน้าต่างสำเร็จของ Parry
@export var parry_active_time: float = 0.45

# เวลาหน่วงหลัง Parry ก่อนจะทำ action อื่นได้
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

# ใช้เช็กว่าผู้เล่นกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ใช้เช็กว่าผู้เล่นกำลัง Dash อยู่หรือไม่
var is_dashing: bool = false

# ใช้เช็กว่า Dash ยังติด cooldown อยู่หรือไม่
var can_dash: bool = true

# ใช้เช็กว่าผู้เล่นกำลังอยู่ในช่วง Parry หรือไม่
var is_parrying: bool = false

# ใช้เช็กว่า Player ตายไปแล้วหรือยัง
var is_dead: bool = false

# ใช้เช็กว่า Player กำลังถูก Knockback อยู่หรือไม่
var is_knocked_back: bool = false

# ใช้เช็กว่า Player กำลังอมตะหลังโดนตีอยู่หรือไม่
var is_hurt_invincible: bool = false

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

# ใช้เช็กว่าเคยแจ้งเตือน Focus เต็มแล้วหรือยัง
# ป้องกันไม่ให้ print ซ้ำทุกครั้งที่ Focus เปลี่ยน
var has_shown_focus_ready_message: bool = false

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

	# ตั้งเลือด / Stamina / Focus เริ่มต้น
	current_hp = max_hp
	current_stamina = max_stamina
	current_focus = 0.0

	# ปิด Hitbox ดาบไว้ก่อน เพราะยังไม่ได้โจมตี
	attack_shape.disabled = true

	# เปิด Hurtbox ไว้ตามปกติ เพื่อให้ Player รับดาเมจได้
	hurtbox_shape.disabled = false

	# วาง Hitbox ดาบไว้ด้านหน้าตามทิศที่ผู้เล่นหัน
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ไปชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Player ready. HP =", current_hp, "Stamina =", current_stamina)

	# ส่งค่าเริ่มต้นไปให้ HUD แสดงผล
	emit_stats()


func _physics_process(delta: float) -> void:
	# ฟื้น Stamina ทุกเฟรม
	regenerate_stamina(delta)

	# ถ้า Player ตายแล้ว ไม่ต้องควบคุมต่อ
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ถ้า Player กำลังถูก Knockback ให้ขยับตามแรงกระเด็น
	if is_knocked_back:
		velocity = knockback_velocity
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้ากำลัง Dash อยู่ ให้เคลื่อนที่ด้วยความเร็ว Dash
	# และไม่รับ input เดินปกติชั่วคราว
	if is_dashing:
		velocity.x = float(facing_direction) * dash_speed
		velocity.y = 0.0
		move_and_slide()
		clamp_to_arena()
		return

	# รับค่าการกดปุ่มซ้าย/ขวา จาก ui_left และ ui_right
	var direction := Input.get_axis("ui_left", "ui_right")

	# ถ้ากำลังโจมตีหรือ Parry ให้หยุดขยับชั่วคราว
	if is_attacking or is_parrying:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	velocity.y = 0.0
	move_and_slide()
	clamp_to_arena()

	# ถ้ามีการเดิน และไม่ได้โจมตี ให้เปลี่ยนทิศหันหน้า
	if direction != 0.0 and not is_attacking:
		facing_direction = int(sign(direction))
		sprite_2d.flip_h = facing_direction < 0
		attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)

	# ถ้ากดปุ่ม attack และตอนนี้ไม่ได้ทำ action อื่น ให้โจมตี
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing and not is_parrying:
		attack()

	# ถ้ากดปุ่ม dash และตอนนี้ไม่ได้ทำ action อื่น ให้ Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_attacking and not is_dashing and not is_parrying:
		dash()

	# ถ้ากดปุ่ม parry และตอนนี้ไม่ได้ทำ action อื่น ให้ Parry
	if Input.is_action_just_pressed("parry") and not is_attacking and not is_dashing and not is_parrying:
		parry()


func emit_stats() -> void:
	# ส่งค่า HP, Stamina และ Focus ปัจจุบันออกไปให้ HUD
	stats_changed.emit(
		current_hp,
		max_hp,
		current_stamina,
		max_stamina,
		current_focus,
		max_focus
	)


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

	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_parrying:
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
	if is_instance_valid(sprite_2d) and not is_hurt_invincible:
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


func attack() -> void:
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

	# จบ Dash
	is_dashing = false

	# ปิดโหมด Dash-through ให้ Player กลับมาชนศัตรูตามปกติ
	end_dash_collision_mode()

	# เปิด Hurtbox กลับมา เพื่อให้รับดาเมจได้ตามปกติ
	hurtbox_shape.disabled = false

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

	if is_instance_valid(sprite_2d) and not is_hurt_invincible and not is_parrying:
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
	# ถ้า Stamina ไม่พอ ห้าม Parry และแจ้งบนจอทันที
	if current_stamina < parry_stamina_cost:
		print("Not enough stamina to parry. Stamina =", int(current_stamina))
		show_stamina_insufficient_feedback()
		return

	# ใช้ Stamina สำหรับ Parry
	current_stamina -= parry_stamina_cost
	print("Parry stamina used. Stamina left =", int(current_stamina))
	emit_stats()

	# เริ่มสถานะ Parry
	is_parrying = true
	print("Player Parry ON")

	# เปลี่ยนสีตัวละครเป็นฟ้าอ่อน เพื่อให้รู้ว่ากำลัง Parry
	sprite_2d.modulate = Color.CYAN

	# รอช่วงเวลาที่ Parry มีผลจริง
	await get_tree().create_timer(parry_active_time).timeout

	# หมดช่วง Parry
	is_parrying = false
	print("Player Parry OFF")

	# เปลี่ยนสีกลับเป็นปกติ
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

	# รอ recovery เล็กน้อย เพื่อไม่ให้กด Parry รัวแบบไม่มีโทษ
	await get_tree().create_timer(parry_recovery_time).timeout


func is_parry_active() -> bool:
	# ฟังก์ชันนี้ให้ศัตรูเรียกถามว่า ตอนนี้ Player อยู่ในช่วง Parry สำเร็จได้หรือไม่
	return is_parrying


func on_successful_parry() -> void:
	# ฟังก์ชันนี้ถูกเรียกเมื่อศัตรูโจมตีเข้ามาในช่วง Parry
	print("Successful Parry!")

	# ได้ Focus เมื่อ Parry สำเร็จ
	gain_focus(focus_gain_on_successful_parry)

	# ให้สีเป็นเหลืองชั่วคราวเพื่อ feedback
	sprite_2d.modulate = Color.YELLOW

	await get_tree().create_timer(0.08).timeout

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE


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

	# ถ้าเงื่อนไขไม่ครบ ให้โจมตีปกติ
	target.take_damage(attack_damage)


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
	get_tree().call_group(
		"game_camera",
		"shake",
		player_hit_camera_shake_strength,
		player_hit_camera_shake_duration
	)

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

	var source := find_knockback_source()

	# ถ้าไม่มีแหล่งดาเมจแล้ว ไม่ต้องทำ Knockback
	if source == null:
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
	if is_instance_valid(sprite_2d):
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

	# ถ้า Sprite ยังอยู่ และไม่ได้อยู่ในช่วงอมตะ ให้เปลี่ยนกลับเป็นสีขาว
	if is_instance_valid(sprite_2d) and not is_hurt_invincible:
		sprite_2d.modulate = Color.WHITE


func die() -> void:
	# ถ้าตายไปแล้ว ไม่ต้องทำซ้ำ
	if is_dead:
		return

	# ตั้งสถานะว่าตายแล้ว
	is_dead = true

	# ปิด action ต่าง ๆ
	is_attacking = false
	is_dashing = false
	is_parrying = false
	is_knocked_back = false

	# ปิด Hitbox และ Hurtbox เพื่อไม่ให้ชนอะไรต่อ
	attack_shape.set_deferred("disabled", true)
	hurtbox_shape.set_deferred("disabled", true)

	print("Player defeated!")

	# ส่งสัญญาณไปให้ HUD แสดง Game Over
	player_died.emit()

	# ซ่อนตัวละครไว้ก่อน แทนการ queue_free ทันที
	# เพื่อหลีกเลี่ยง coroutine เก่าที่ยังทำงานแล้วอ้างอิง node ไม่เจอ
	visible = false
	set_physics_process(false)
