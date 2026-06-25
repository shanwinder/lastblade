extends CharacterBody2D

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

# อ้างอิงผู้เล่น
var player: CharacterBody2D

# เลือดปัจจุบันของศัตรู
var current_hp: int

# ใช้เช็กว่าศัตรูกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ใช้เช็กว่าศัตรูโจมตีโดนผู้เล่นไปแล้วหรือยังในจังหวะนี้
# เพื่อป้องกันโดนดาเมจซ้ำหลายครั้งจากการโจมตีครั้งเดียว
var has_hit_player: bool = false

# ทิศที่ศัตรูหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = -1

# ระยะห่างของ Hitbox ศัตรูจากตัวศัตรู
var attack_hitbox_offset_x: float = 55.0

# อ้างอิง Sprite2D เพื่อใช้กลับด้านและเปลี่ยนสี
@onready var sprite_2d: Sprite2D = $Sprite2D

# อ้างอิง AttackHitbox ของศัตรู
@onready var attack_hitbox: Area2D = $AttackHitbox

# อ้างอิง CollisionShape2D ของ AttackHitbox เพื่อเปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D


func _ready() -> void:
	# ตั้งเลือดเริ่มต้นของศัตรู
	current_hp = max_hp

	# หา node ผู้เล่น
	# สำคัญ: ถ้า node ผู้เล่นของคุณชื่อ Player ตัว P ใหญ่ ให้เปลี่ยน "player" เป็น "Player"
	player = get_parent().get_node("Player")

	# ปิด Hitbox ของศัตรูไว้ก่อน
	attack_shape.disabled = true

	# วาง Hitbox ไว้ด้านหน้าศัตรู
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ของศัตรูชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Enemy ready. HP =", current_hp)


func _physics_process(_delta: float) -> void:
	# ถ้าผู้เล่นไม่อยู่แล้ว เช่น ตายไป ให้ศัตรูไม่ทำอะไร
	if not is_instance_valid(player):
		velocity.x = 0
		move_and_slide()
		return

	# ถ้ากำลังโจมตี ให้หยุดอยู่กับที่
	if is_attacking:
		velocity.x = 0
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
		# ถ้าอยู่ใกล้พอ ให้หยุดแล้วโจมตี
		velocity.x = 0
		attack()

	velocity.y = 0
	move_and_slide()


func attack() -> void:
	# ถ้ากำลังโจมตีอยู่แล้ว ไม่ให้เริ่มโจมตีซ้ำ
	if is_attacking:
		return

	# เริ่มสถานะโจมตี
	is_attacking = true

	# รีเซ็ตว่าโจมตีครั้งนี้ยังไม่โดนผู้เล่น
	has_hit_player = false

	print("Enemy Attack! Hitbox ON")

	# เปิด Hitbox ของศัตรู
	# ใช้ set_deferred เพื่อหลีกเลี่ยงปัญหาเปลี่ยน collision state ระหว่าง physics
	attack_shape.set_deferred("disabled", false)

	# รอช่วงที่การโจมตีมีผล
	await get_tree().create_timer(attack_active_time).timeout

	# ปิด Hitbox หลังหมดจังหวะโจมตี
	# ใช้ set_deferred เพื่อความปลอดภัยกับระบบ physics
	attack_shape.set_deferred("disabled", true)
	print("Enemy Hitbox OFF")

	# รอ cooldown ก่อนโจมตีครั้งต่อไป
	await get_tree().create_timer(attack_cooldown).timeout

	# จบสถานะโจมตี
	is_attacking = false


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ถ้าไม่ได้กำลังโจมตี ก็ไม่ทำดาเมจ
	if not is_attacking:
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


func take_damage(amount: int) -> void:
	# ลด HP ของศัตรู
	current_hp -= amount
	print("Enemy took damage:", amount, "HP left:", current_hp)

	# กระพริบแดงเมื่อโดนตี
	flash_red()

	# ถ้า HP หมด ให้ตาย
	if current_hp <= 0:
		die()

func stagger() -> void:
	# ศัตรูชะงักเมื่อถูก Parry
	print("Enemy staggered!")

	# หยุดสถานะโจมตีทันที
	is_attacking = false

	# หยุดการเคลื่อนที่ของศัตรู
	velocity.x = 0

	# สำคัญ:
	# ห้ามใช้ attack_shape.disabled = true ตรง ๆ ในจังหวะ area_entered
	# เพราะ Godot กำลังประมวลผล collision อยู่
	# ต้องใช้ set_deferred เพื่อสั่งให้ Godot ปิด hitbox หลังจากจบรอบ physics นี้ก่อน
	attack_shape.set_deferred("disabled", true)

	# เปลี่ยนสีเป็นฟ้าเพื่อแสดงว่าศัตรูถูก Parry
	sprite_2d.modulate = Color.CYAN

	# หยุดนิ่งสั้น ๆ ให้ผู้เล่นรู้สึกว่า Parry สำเร็จ
	await get_tree().create_timer(0.35).timeout

	# ถ้า sprite ยังอยู่ในเกม ให้เปลี่ยนกลับเป็นสีขาว
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

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
