extends CharacterBody2D

# =========================
# Duel1DummyTarget.gd
# หุ่นศัตรูพื้นฐานสำหรับ Phase 9: Duel 1
# เวอร์ชันนี้เริ่มมี pattern แรก: PARRY! attack แบบเบา ๆ
# ผู้เล่นยังตีหุ่นให้ตายได้ แต่ถ้าเข้าใกล้ต้องเริ่มฝึก Parry ด้วย
# =========================

# ส่งสัญญาณเมื่อ HP เปลี่ยน เพื่อให้ Manager อัปเดตข้อความได้
signal hp_changed(current_hp: int, max_hp: int)

# ส่งสัญญาณเมื่อหุ่นถูกทำลาย
signal dummy_defeated

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# เลือดสูงสุดของหุ่น Duel 1
@export var max_hp: int = 30

# ขนาดตัวหุ่นแบบ placeholder
@export var body_size: Vector2 = Vector2(38.0, 74.0)

# ขนาด Hurtbox ให้ Player ตีโดนง่ายพอสมควร
@export var hurtbox_size: Vector2 = Vector2(72.0, 82.0)

# สีตัวหุ่น
@export var body_color: Color = Color(0.22, 0.25, 0.32, 1.0)

# สีขอบ/ประกายหุ่น
@export var rim_color: Color = Color(1.0, 0.76, 0.24, 1.0)

# ระยะเวลาสีแดงตอนโดนตี
@export var hit_flash_time: float = 0.08

# =========================
# Pattern 1: PARRY! Attack
# =========================

# เปิด/ปิดการโจมตีแบบฝึก Parry
@export var parry_attack_enabled: bool = true

# ระยะที่หุ่นจะเริ่มโจมตีผู้เล่น
@export var parry_attack_range: float = 145.0

# ดาเมจเบา ๆ ของหุ่น ถ้าผู้เล่น Parry ไม่ทัน
@export var parry_attack_damage: int = 6

# เวลารอระหว่างการโจมตีแต่ละครั้ง
@export var parry_attack_interval: float = 2.10

# เวลาที่ขึ้น PARRY! ก่อนเช็กว่า Player กด Parry ทันไหม
@export var parry_attack_windup_time: float = 0.85

# เวลาค้างหลังโจมตี เพื่อไม่ให้ pattern ถี่เกินไป
@export var parry_attack_recover_time: float = 0.45

# ขนาดตัวอักษรสัญญาณ PARRY!
@export var cue_font_size: int = 28

# HP ปัจจุบัน
var current_hp: int = 0

# กันไม่ให้ตายซ้ำ
var is_defeated: bool = false

# อ้างอิง Player
var player: Node = null

# อ้างอิงภาพ placeholder
var body_polygon: Polygon2D = null
var rim_polygon: Polygon2D = null

# อ้างอิง Hurtbox
var hurtbox: Area2D = null
var hurtbox_shape: CollisionShape2D = null

# สถานะการโจมตีของหุ่น
var is_doing_parry_attack: bool = false
var parry_attack_timer: float = 0.0
var cue_label: Label = null


func _ready() -> void:
	# ตั้งค่าเริ่มต้น
	current_hp = max_hp

	# หา Player เพื่อใช้เช็กระยะและเรียก take_damage / on_successful_parry
	setup_player_reference.call_deferred()

	# สร้างภาพและ hurtbox ด้วยโค้ด เพื่อลดความจำเป็นต้องทำ scene แยกตอนนี้
	create_visual_placeholder()
	create_hurtbox()

	# แจ้งค่า HP เริ่มต้นให้ Manager
	hp_changed.emit(current_hp, max_hp)

	print("Duel 1 Dummy ready. HP =", current_hp)


func _physics_process(delta: float) -> void:
	# ถ้าหุ่นถูกทำลายแล้ว ไม่ต้องโจมตีต่อ
	if is_defeated:
		return

	# ถ้าปิด pattern ไว้ หุ่นจะกลับไปเป็นเป้านิ่งเหมือนเดิม
	if not parry_attack_enabled:
		return

	# ถ้ายังหา Player ไม่เจอ ให้ลองหาใหม่
	if not is_instance_valid(player):
		setup_player_reference()
		return

	# ถ้ากำลังโจมตีอยู่ ไม่เริ่มซ้อน
	if is_doing_parry_attack:
		return

	# โจมตีเฉพาะตอนผู้เล่นเข้าใกล้พอ เพื่อไม่กดดันตั้งแต่ยังเดินเข้าไม่ถึง
	if not is_player_in_parry_attack_range():
		parry_attack_timer = 0.0
		return

	parry_attack_timer += delta
	if parry_attack_timer >= parry_attack_interval:
		parry_attack_timer = 0.0
		start_parry_attack()


func setup_player_reference() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback ตามชื่อ node
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")


func create_visual_placeholder() -> void:
	# สร้างขอบด้านหลังให้เห็นตัวชัดบนฉากมืด
	rim_polygon = Polygon2D.new()
	rim_polygon.name = "Rim"
	rim_polygon.color = rim_color
	rim_polygon.polygon = PackedVector2Array([
		Vector2(-body_size.x * 0.62, -body_size.y * 0.55),
		Vector2(body_size.x * 0.62, -body_size.y * 0.55),
		Vector2(body_size.x * 0.62, body_size.y * 0.55),
		Vector2(-body_size.x * 0.62, body_size.y * 0.55)
	])
	add_child(rim_polygon)

	# สร้างตัวหุ่นด้านหน้า
	body_polygon = Polygon2D.new()
	body_polygon.name = "Body"
	body_polygon.color = body_color
	body_polygon.polygon = PackedVector2Array([
		Vector2(-body_size.x * 0.50, -body_size.y * 0.50),
		Vector2(body_size.x * 0.50, -body_size.y * 0.50),
		Vector2(body_size.x * 0.50, body_size.y * 0.50),
		Vector2(-body_size.x * 0.50, body_size.y * 0.50)
	])
	add_child(body_polygon)

	# ยกภาพขึ้นเหนือพื้นเล็กน้อย
	rim_polygon.position.y = -body_size.y * 0.45
	body_polygon.position.y = -body_size.y * 0.45


func create_hurtbox() -> void:
	# ต้องชื่อ Hurtbox เพื่อให้ player.gd ตรวจเจอและเรียก take_damage()
	hurtbox = Area2D.new()
	hurtbox.name = "Hurtbox"
	add_child(hurtbox)

	hurtbox_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = hurtbox_size
	hurtbox_shape.shape = shape
	hurtbox_shape.position.y = -body_size.y * 0.45
	hurtbox.add_child(hurtbox_shape)


func is_player_in_parry_attack_range() -> bool:
	# เช็กระยะตามแกน X แบบเกม 2D ด้านข้าง
	if not is_instance_valid(player):
		return false

	if not (player is Node2D):
		return false

	var player_node := player as Node2D
	var distance_x: float = abs(player_node.global_position.x - global_position.x)
	return distance_x <= parry_attack_range


func start_parry_attack() -> void:
	# เริ่มท่าโจมตีแบบฝึก Parry
	if is_doing_parry_attack or is_defeated:
		return

	is_doing_parry_attack = true
	show_attack_cue("PARRY!", Color(0.35, 0.95, 1.0, 1.0))
	flash_windup_color()

	print("Duel 1 Dummy attack cue: PARRY!")

	await get_tree().create_timer(parry_attack_windup_time).timeout

	if is_defeated:
		is_doing_parry_attack = false
		clear_attack_cue()
		return

	resolve_parry_attack()
	clear_attack_cue()

	await get_tree().create_timer(parry_attack_recover_time).timeout

	is_doing_parry_attack = false


func resolve_parry_attack() -> void:
	# ตอนจังหวะปะทะ ถ้า Player อยู่ในระยะและกด Parry อยู่ ถือว่าสำเร็จ
	if not is_instance_valid(player):
		return

	if not is_player_in_parry_attack_range():
		return

	if player.has_method("is_parry_active") and player.is_parry_active():
		print("Duel 1 Dummy attack parried")
		show_attack_cue("GOOD!", Color(1.0, 0.88, 0.20, 1.0))

		# ใช้ระบบ Focus เดิมของ Player เพื่อให้รางวัลกับการ Parry ถูกจังหวะ
		if player.has_method("on_successful_parry"):
			player.on_successful_parry()
		return

	# ถ้า Parry ไม่ทัน ให้โดนดาเมจเบา ๆ เพื่อสอนจังหวะ แต่ไม่โหดเกินไป
	if player.has_method("take_damage"):
		print("Duel 1 Dummy hit player. Damage =", parry_attack_damage)
		player.take_damage(parry_attack_damage)


func show_attack_cue(text: String, color: Color) -> void:
	# แสดงข้อความสัญญาณเหนือหัวหุ่น
	if cue_label == null or not is_instance_valid(cue_label):
		cue_label = Label.new()
		cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cue_label.z_index = 180
		cue_label.add_theme_font_size_override("font_size", cue_font_size)
		get_parent().add_child(cue_label)

	cue_label.text = text
	cue_label.modulate = color
	cue_label.global_position = global_position + Vector2(-56.0, -126.0)
	cue_label.visible = true


func clear_attack_cue() -> void:
	# ซ่อนสัญญาณโจมตีหลังจบจังหวะ
	if cue_label != null and is_instance_valid(cue_label):
		cue_label.visible = false


func free_attack_cue() -> void:
	# ลบ cue label เมื่อหุ่นตาย เพื่อไม่ให้ node ค้างใน scene
	if cue_label != null and is_instance_valid(cue_label):
		cue_label.queue_free()
	cue_label = null


func flash_windup_color() -> void:
	# เปลี่ยนสีหุ่นสั้น ๆ ตอนกำลังเตรียมโจมตี
	if body_polygon != null:
		body_polygon.color = Color(0.20, 0.65, 1.0, 1.0)

	await get_tree().create_timer(0.12).timeout

	if is_instance_valid(body_polygon) and not is_defeated:
		body_polygon.color = body_color


func take_damage(amount: int) -> void:
	# ถ้าถูกทำลายแล้ว ไม่รับดาเมจซ้ำ
	if is_defeated:
		return

	current_hp -= amount
	current_hp = max(current_hp, 0)

	print("Duel 1 Dummy took damage:", amount, "HP left:", current_hp)
	hp_changed.emit(current_hp, max_hp)

	show_damage_popup(amount)
	flash_hit()

	if current_hp <= 0:
		defeat_dummy()


func can_receive_focus_finisher() -> bool:
	# Duel 1 Dummy เวอร์ชันแรกยังไม่ใช้ Finisher เพื่อให้เป็นเป้าหมายฝึกพื้นฐาน
	return false


func show_damage_popup(amount: int) -> void:
	# แสดงเลขดาเมจแบบง่าย ๆ เหนือหุ่น
	var popup := Label.new()
	popup.text = "%d" % amount
	popup.modulate = Color.WHITE
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 150
	popup.add_theme_font_size_override("font_size", 22)

	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-20.0, -95.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -34.0)

	# สำคัญ: ใช้ popup.create_tween() เพื่อให้ tween ผูกกับเลขดาเมจเอง
	# ถ้าใช้ create_tween() ของหุ่น แล้วหุ่นตายก่อน เลข 10 จะค้างบนจอ
	var tween := popup.create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, 0.38)
	tween.tween_property(popup, "modulate:a", 0.0, 0.38)
	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)


func flash_hit() -> void:
	# กระพริบสีแดงสั้น ๆ เพื่อบอกว่าโดนตีจริง
	if body_polygon == null:
		return

	body_polygon.color = Color(1.0, 0.20, 0.12, 1.0)

	await get_tree().create_timer(hit_flash_time).timeout

	if is_instance_valid(body_polygon) and not is_defeated and not is_doing_parry_attack:
		body_polygon.color = body_color


func defeat_dummy() -> void:
	# ทำลายหุ่นและแจ้ง Manager
	if is_defeated:
		return

	is_defeated = true
	free_attack_cue()
	print("Duel 1 Dummy defeated")
	dummy_defeated.emit()

	# ทำให้หุ่นจางหาย ไม่ queue_free ทันทีเพื่อให้ผู้เล่นเห็นว่าตายแล้ว
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.82, 0.82), 0.24)
	tween.tween_property(self, "modulate:a", 0.0, 0.24)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
