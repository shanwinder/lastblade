extends CharacterBody2D

# =========================
# ค่าพื้นฐานของศัตรู
# =========================

# เลือดสูงสุดของศัตรู
@export var max_hp: int = 30

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


func _physics_process(_delta: float) -> void:
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

		# ทำให้ศัตรูชะงักสั้น ๆ
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


func take_damage(amount: int) -> void:
	# ลด HP ของศัตรู
	current_hp -= amount
	print("Enemy took damage:", amount, "HP left:", current_hp)

	# กระพริบแดงเมื่อโดนตี
	flash_red()

	# ถ้า HP หมด ให้ตาย
	if current_hp <= 0:
		die()


func flash_red() -> void:
	# เปลี่ยนสีศัตรูเป็นแดงชั่วคราว
	sprite_2d.modulate = Color.RED

	# รอ 0.1 วินาที
	await get_tree().create_timer(0.1).timeout

	# ถ้า sprite ยังอยู่ ให้เปลี่ยนกลับเป็นขาว
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE


func die() -> void:
	# ลบศัตรูออกจากฉาก
	print("Enemy defeated!")
	queue_free()
