extends CharacterBody2D

# ความเร็วในการเดินของผู้เล่น
@export var speed: float = 300.0

# ดาเมจที่ผู้เล่นทำได้เมื่อโจมตีโดนศัตรู
@export var attack_damage: int = 10

# เลือดสูงสุดของผู้เล่น
@export var max_hp: int = 100

# ระยะเวลาที่ Hitbox ของดาบเปิดตอนโจมตี
@export var attack_active_time: float = 0.18

# เวลาหน่วงหลังโจมตี ก่อนจะขยับหรือโจมตีใหม่ได้
@export var attack_recovery_time: float = 0.12

# อ้างอิง node Sprite2D เพื่อใช้กลับด้านตัวละคร
@onready var sprite_2d: Sprite2D = $Sprite2D

# อ้างอิง AttackHitbox ของผู้เล่น
@onready var attack_hitbox: Area2D = $AttackHitbox

# อ้างอิง CollisionShape2D ของ AttackHitbox เพื่อเปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

# เลือดปัจจุบันของผู้เล่น
var current_hp: int

# ใช้เช็กว่าตอนนี้ผู้เล่นกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ทิศที่ผู้เล่นหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = 1

# ระยะห่างของ Hitbox ดาบจากตัวผู้เล่น
var attack_hitbox_offset_x: float = 55.0


func _ready() -> void:
	# ตั้งเลือดเริ่มต้นให้เต็ม
	current_hp = max_hp

	# ปิด Hitbox ดาบไว้ก่อน เพราะยังไม่ได้โจมตี
	attack_shape.disabled = true

	# วาง Hitbox ดาบไว้ด้านหน้าตามทิศที่ผู้เล่นหัน
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ไปชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Player ready. HP =", current_hp)


func _physics_process(_delta: float) -> void:
	# รับค่าการกดปุ่มซ้าย/ขวา จาก ui_left และ ui_right
	var direction := Input.get_axis("ui_left", "ui_right")

	# ถ้ากำลังโจมตี ให้หยุดขยับชั่วคราว
	if is_attacking:
		velocity.x = 0
	else:
		velocity.x = direction * speed

	# ตอนนี้ยังไม่มีแรงโน้มถ่วง จึงให้แกน y เป็น 0 ไปก่อน
	velocity.y = 0

	# สั่งให้ CharacterBody2D เคลื่อนที่ตาม velocity
	move_and_slide()

	# ถ้ามีการเดิน และไม่ได้โจมตี ให้เปลี่ยนทิศหันหน้า
	if direction != 0 and not is_attacking:
		facing_direction = sign(direction)
		sprite_2d.flip_h = facing_direction < 0

		# ย้าย Hitbox ดาบไปด้านหน้าของตัวละคร
		attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# ถ้ากดปุ่ม attack และไม่ได้กำลังโจมตีอยู่ ให้เรียกฟังก์ชัน attack()
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()


func attack() -> void:
	# เริ่มสถานะโจมตี
	is_attacking = true
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


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ถ้าไม่ได้อยู่ในจังหวะโจมตี ก็ไม่ทำดาเมจ
	if not is_attacking:
		return

	# ถ้า Hitbox ไปชน Area ที่ชื่อ Hurtbox แปลว่าโดนศัตรู
	if area.name == "Hurtbox":
		var enemy = area.get_parent()

		# เช็กว่า node นั้นมีฟังก์ชัน take_damage หรือไม่
		if enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage)


func take_damage(amount: int) -> void:
	# ลดเลือดผู้เล่นตามจำนวนดาเมจที่ได้รับ
	current_hp -= amount
	print("Player took damage:", amount, "HP left:", current_hp)

	# ทำเอฟเฟกต์กระพริบแดงแบบง่าย ๆ
	flash_red()

	# ถ้าเลือดหมด ให้ตาย
	if current_hp <= 0:
		die()


func flash_red() -> void:
	# เปลี่ยนสีตัวละครเป็นสีแดงชั่วคราว
	sprite_2d.modulate = Color.RED

	# รอ 0.1 วินาที
	await get_tree().create_timer(0.1).timeout

	# ถ้า Sprite ยังอยู่ ให้เปลี่ยนกลับเป็นสีขาว
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE


func die() -> void:
	# ตอนนี้ให้พิมพ์ข้อความก่อน ภายหลังค่อยทำ Game Over
	print("Player defeated!")
	queue_free()
