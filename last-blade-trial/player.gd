extends CharacterBody2D

# =========================
# ค่าพื้นฐานของผู้เล่น
# =========================

# ความเร็วในการเดินปกติ
@export var speed: float = 300.0

# ความเร็วตอน Dash
@export var dash_speed: float = 850.0

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

# ความเร็วในการฟื้น Stamina ต่อวินาที
@export var stamina_regen_rate: float = 0

# Stamina ที่ใช้เมื่อโจมตีหนึ่งครั้ง
@export var attack_stamina_cost: float = 18.0

# Stamina ที่ใช้เมื่อ Dash หนึ่งครั้ง
@export var dash_stamina_cost: float = 30.0

# ระยะเวลาที่ Hitbox ของดาบเปิดตอนโจมตี
@export var attack_active_time: float = 0.18

# เวลาหน่วงหลังโจมตี ก่อนจะขยับหรือโจมตีใหม่ได้
@export var attack_recovery_time: float = 0.12


# =========================
# อ้างอิง Node ต่าง ๆ
# =========================

# Sprite2D ใช้แสดงภาพตัวละคร และใช้ flip ซ้าย/ขวา
@onready var sprite_2d: Sprite2D = $Sprite2D

# AttackHitbox คือพื้นที่โจมตีของผู้เล่น
@onready var attack_hitbox: Area2D = $AttackHitbox

# CollisionShape2D ของ AttackHitbox ใช้เปิด/ปิดพื้นที่โจมตี
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

# Hurtbox คือพื้นที่ที่ player รับดาเมจจากศัตรู
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

# ใช้เช็กว่าผู้เล่นกำลังโจมตีอยู่หรือไม่
var is_attacking: bool = false

# ใช้เช็กว่าผู้เล่นกำลัง Dash อยู่หรือไม่
var is_dashing: bool = false

# ใช้เช็กว่า Dash ยังติด cooldown อยู่หรือไม่
var can_dash: bool = true

# ทิศที่ผู้เล่นหันหน้าอยู่ 1 = ขวา, -1 = ซ้าย
var facing_direction: int = 1

# ระยะห่างของ Hitbox ดาบจากตัวผู้เล่น
var attack_hitbox_offset_x: float = 55.0

# ใช้เก็บรายชื่อเป้าหมายที่โดนโจมตีไปแล้วในการฟันครั้งนี้
# ป้องกันไม่ให้เป้าหมายตัวเดิมโดนดาเมจซ้ำจากการโจมตีครั้งเดียว
var hit_targets: Array = []


func _ready() -> void:
	# ตั้งเลือดเริ่มต้นให้เต็ม
	current_hp = max_hp

	# ตั้ง Stamina เริ่มต้นให้เต็ม
	current_stamina = max_stamina

	# ปิด Hitbox ดาบไว้ก่อน เพราะยังไม่ได้โจมตี
	attack_shape.disabled = true

	# เปิด Hurtbox ไว้ตามปกติ เพื่อให้ player รับดาเมจได้
	hurtbox_shape.disabled = false

	# วาง Hitbox ดาบไว้ด้านหน้าตามทิศที่ผู้เล่นหัน
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	# เชื่อมสัญญาณ เมื่อ AttackHitbox ไปชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	print("Player ready. HP =", current_hp, "Stamina =", current_stamina)


func _physics_process(_delta: float) -> void:
	# ฟื้น Stamina ทุกเฟรม
	regenerate_stamina(_delta)

	# ถ้ากำลัง Dash อยู่ ให้เคลื่อนที่ด้วยความเร็ว Dash
	# และไม่รับ input เดินปกติชั่วคราว
	if is_dashing:
		velocity.x = facing_direction * dash_speed
		velocity.y = 0
		move_and_slide()
		return

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

	# ถ้ากดปุ่ม attack และไม่ได้กำลังโจมตี/แดชอยู่ ให้โจมตี
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		attack()

	# ถ้ากดปุ่ม dash และ Dash ได้ ให้เริ่ม Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_attacking and not is_dashing:
		dash()


func regenerate_stamina(delta: float) -> void:
	# ถ้า Stamina ยังไม่เต็ม ให้ค่อย ๆ ฟื้นตามเวลา
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta

		# clamp คือบังคับไม่ให้ค่าเกิน max_stamina
		current_stamina = clamp(current_stamina, 0.0, max_stamina)


func attack() -> void:
	# ถ้า Stamina ไม่พอ ห้ามโจมตี
	if current_stamina < attack_stamina_cost:
		print("Not enough stamina to attack. Stamina =", int(current_stamina))
		return

	# ใช้ Stamina สำหรับการโจมตี
	current_stamina -= attack_stamina_cost
	print("Attack stamina used. Stamina left =", int(current_stamina))

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


func dash() -> void:
	# ถ้า Stamina ไม่พอ ห้าม Dash
	if current_stamina < dash_stamina_cost:
		print("Not enough stamina to dash. Stamina =", int(current_stamina))
		return

	# ใช้ Stamina สำหรับ Dash
	current_stamina -= dash_stamina_cost
	print("Dash stamina used. Stamina left =", int(current_stamina))

	# เริ่ม Dash
	is_dashing = true

	# ปิดการ Dash ซ้ำจนกว่า cooldown จะหมด
	can_dash = false

	# ปิด Hurtbox ชั่วคราว
	# นี่คือการทำ i-frame แบบง่าย ๆ ทำให้ศัตรูตีไม่โดนตอน Dash
	hurtbox_shape.disabled = true

	print("Player Dash! Invincible ON")

	# รอระยะเวลาที่ Dash มีผล
	await get_tree().create_timer(dash_time).timeout

	# จบ Dash
	is_dashing = false

	# เปิด Hurtbox กลับมา เพื่อให้รับดาเมจได้ตามปกติ
	hurtbox_shape.disabled = false

	print("Dash End. Invincible OFF")

	# รอ cooldown ก่อน Dash ครั้งต่อไป
	await get_tree().create_timer(dash_cooldown).timeout

	can_dash = true
	print("Dash Ready")


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ถ้าไม่ได้อยู่ในจังหวะโจมตี ก็ไม่ทำดาเมจ
	if not is_attacking:
		return

	# ถ้ากำลัง Dash อยู่ ห้ามทำดาเมจ
	# ป้องกันกรณี Hitbox ชนผิดจังหวะระหว่าง Dash
	if is_dashing:
		return

	# ตรวจเฉพาะ Area ที่ชื่อ Hurtbox เท่านั้น
	if area.name != "Hurtbox":
		return

	# หา parent ของ Hurtbox ที่ถูกชน
	var target = area.get_parent()

	# ถ้า target คือตัว player เอง ให้ข้าม
	# ป้องกันผู้เล่นโจมตีโดน Hurtbox ของตัวเอง
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

	# สั่งให้ target รับดาเมจ
	target.take_damage(attack_damage)


func take_damage(amount: int) -> void:
	# ถ้ากำลัง Dash อยู่ ไม่รับดาเมจ
	# เผื่อกรณี Hitbox ศัตรูชนพอดีในจังหวะที่ Hurtbox ยังไม่ถูกปิดทัน
	if is_dashing:
		print("Damage avoided by dash!")
		return

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
