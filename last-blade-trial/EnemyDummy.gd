extends CharacterBody2D

# ส่งสัญญาณไปให้ HUD ทุกครั้งที่ค่า HP หรือ Posture ของศัตรูเปลี่ยน
signal enemy_stats_changed(current_hp: int, max_hp: int, current_posture: float, max_posture: float)

# ส่งสัญญาณเมื่อศัตรูตาย เพื่อให้ HUD หรือ Main แสดง Victory
signal enemy_died

# =========================
# ค่าพื้นฐานของศัตรู
# =========================

# เลือดสูงสุดของศัตรู
@export var max_hp: int = 50

# ความเร็วในการเดินเข้าหาผู้เล่น
@export var move_speed: float = 120.0

# ระยะที่ศัตรูจะหยุดเมื่อเข้าใกล้ผู้เล่น
@export var stop_distance: float = 90.0

# ดาเมจที่ศัตรูทำได้เมื่อโจมตีโดนผู้เล่น
@export var attack_damage: int = 10

# ระยะเวลาที่ Hitbox ของศัตรูเปิดตอนโจมตี
@export var attack_active_time: float = 0.18

# เวลารอระหว่างการโจมตีแต่ละครั้ง
@export var attack_cooldown: float = 1.2

# ระยะเวลาที่ศัตรูชะงักเมื่อถูก Parry
@export var stagger_time: float = 0.45

# เวลาพักหลังชะงัก ก่อนกลับมาโจมตีใหม่ได้
@export var stagger_recover_time: float = 0.25

# Posture สูงสุดของศัตรู
# มองง่าย ๆ คือค่าความสมดุลของศัตรู
@export var max_posture: float = 100.0

# จำนวน Posture ที่ลดลงเมื่อผู้เล่น Parry สำเร็จหนึ่งครั้ง
@export var posture_damage_from_parry: float = 35.0

# เวลาที่ศัตรู Break หรือเสียสมดุลหนัก
@export var posture_break_time: float = 1.2

# ตัวคูณดาเมจเมื่อผู้เล่นโจมตีตอนศัตรู Posture Break
# เช่น 3.0 แปลว่าโจมตีแรงขึ้น 3 เท่า
@export var critical_damage_multiplier: float = 3.0

# =========================
# ตัวแปรอ้างอิง Node
# =========================

# อ้างอิง Player
var player: CharacterBody2D

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

# ใช้เช็กว่าศัตรูกำลังชะงักจาก Parry อยู่หรือไม่
var is_staggered: bool = false

# ใช้ล็อกไม่ให้ศัตรูเริ่มโจมตีรอบใหม่เร็วเกินไป
var can_attack: bool = true

# ใช้เช็กว่าศัตรูโจมตีโดนผู้เล่นไปแล้วหรือยังในจังหวะนี้
# เพื่อป้องกันดาเมจซ้ำจากการโจมตีครั้งเดียว
var has_hit_player: bool = false

# ใช้ยกเลิก attack coroutine เก่าที่ค้างอยู่
# ทุกครั้งที่เริ่ม attack ใหม่หรือถูก parry เราจะเพิ่มค่านี้
var attack_sequence_id: int = 0

# ทิศที่ศัตรูหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = -1

# ระยะห่างของ Hitbox ศัตรูจากตัวศัตรู
var attack_hitbox_offset_x: float = 55.0


func _ready() -> void:
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

	print("Enemy ready. HP =", current_hp)
	
	# ส่งค่าเริ่มต้นให้ HUD แสดง Enemy Posture
	emit_enemy_stats()


func _physics_process(_delta: float) -> void:
	# ถ้าศัตรูตายแล้ว ไม่ต้องทำ AI ต่อ
	if is_dead:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return
		
	# ถ้าผู้เล่นไม่อยู่แล้ว เช่น ตายไป ให้ศัตรูหยุด
	if not is_instance_valid(player):
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return

	# ถ้ากำลังชะงักจาก Parry ให้หยุดนิ่ง
	if is_staggered:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return

	# ถ้ากำลังโจมตี ให้หยุดอยู่กับที่
	if is_attacking:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
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

func emit_enemy_stats() -> void:
	# ส่งค่า HP และ Posture ของศัตรูไปให้ HUD
	enemy_stats_changed.emit(current_hp, max_hp, current_posture, max_posture)

func attack() -> void:
	# ถ้ากำลังโจมตีอยู่ / กำลังชะงัก / ยังไม่พร้อมโจมตี ห้ามเริ่มโจมตีใหม่
	if is_attacking or is_staggered or not can_attack:
		return

	# ล็อกไม่ให้เริ่มโจมตีซ้อน
	is_attacking = true
	can_attack = false

	# รีเซ็ตว่าโจมตีครั้งนี้ยังไม่โดนผู้เล่น
	has_hit_player = false

	# เพิ่มเลข sequence เพื่อระบุว่า attack รอบนี้คือรอบล่าสุด
	attack_sequence_id += 1
	var my_attack_id := attack_sequence_id

	print("Enemy Attack! Hitbox ON")

	# เปิด Hitbox ของศัตรูแบบ deferred เพื่อปลอดภัยกับระบบ physics
	attack_shape.set_deferred("disabled", false)

	# รอหนึ่ง physics frame เพื่อให้ Godot เปิด hitbox จริงก่อน
	await get_tree().physics_frame

	# ถ้าระหว่างรอถูกยกเลิก เช่น ถูก Parry ให้หยุด attack รอบนี้ทันที
	if my_attack_id != attack_sequence_id:
		return

	# สำคัญ:
	# นอกจากรอ area_entered แล้ว เราตรวจพื้นที่ที่ overlap อยู่แล้วด้วย
	# เพื่อแก้ปัญหา Parry ครั้งต่อ ๆ ไปไม่ขึ้นข้อความ เพราะ hurtbox กับ hitbox ซ้อนกันอยู่แล้ว
	for area in attack_hitbox.get_overlapping_areas():
		_try_hit_area(area)

	# รอช่วงที่การโจมตีมีผล
	await get_tree().create_timer(attack_active_time).timeout

	# ถ้า attack รอบนี้ถูกยกเลิกระหว่างทาง เช่น ถูก Parry ให้หยุดทันที
	if my_attack_id != attack_sequence_id:
		return

	# ปิด Hitbox หลังหมดจังหวะโจมตี
	attack_shape.set_deferred("disabled", true)
	print("Enemy Hitbox OFF")

	# จบสถานะโจมตี
	is_attacking = false

	# รอ cooldown ก่อนโจมตีครั้งต่อไป
	await get_tree().create_timer(attack_cooldown).timeout

	# ถ้า attack รอบนี้ถูกยกเลิกไปแล้ว ไม่ต้องเปิด can_attack
	if my_attack_id != attack_sequence_id:
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
		print("Enemy attack ignored own Hurtbox")
		return

	# ถ้าเป้าหมายไม่มีฟังก์ชัน take_damage ก็ไม่ต้องทำอะไร
	if not target.has_method("take_damage"):
		return

	# เช็กก่อนว่าเป้าหมายมีระบบ Parry หรือไม่
	if target.has_method("is_parry_active") and target.is_parry_active():
		# ถ้า Player กำลัง Parry อยู่ ถือว่า Parry สำเร็จ
		has_hit_player = true
		print("Enemy attack was parried!")

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

	# ถ้าไม่ได้ Parry ให้ทำดาเมจตามปกติ
	has_hit_player = true
	target.take_damage(attack_damage)


func stagger() -> void:
	# ถ้ากำลังชะงักอยู่แล้ว ไม่ต้องเริ่มซ้ำ
	if is_staggered:
		return

	print("Enemy staggered!")

	# เพิ่ม sequence เพื่อยกเลิก attack coroutine เก่าที่อาจยัง await ค้างอยู่
	attack_sequence_id += 1

	# ตั้งสถานะศัตรูให้ชะงัก
	is_staggered = true
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

	print("Enemy POSTURE BROKEN!")

	# ตั้งสถานะ Break
	is_posture_broken = true
	
	# เปิดช่องให้ Player โจมตี Critical ได้ 1 ครั้ง
	can_receive_critical = true
	print("Critical chance opened!")

	# เพิ่ม sequence เพื่อยกเลิก attack coroutine เก่าที่อาจยัง await ค้างอยู่
	attack_sequence_id += 1

	# ระหว่าง Break ศัตรูห้ามโจมตีและห้ามขยับ
	is_staggered = true
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

	# ยกเลิก attack coroutine เก่าที่อาจค้างอยู่
	attack_sequence_id += 1

	# ปิดสถานะต่อสู้ทั้งหมด
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
