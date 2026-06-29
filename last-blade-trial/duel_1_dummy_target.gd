extends CharacterBody2D

# =========================
# Duel1DummyTarget.gd
# หุ่นศัตรูพื้นฐานสำหรับ Phase 9: Duel 1
# เวอร์ชันแรกยังไม่โจมตี ใช้ให้ผู้เล่นฝึกเดินเข้าไปตีเป้าหมายให้ตายก่อนเข้าบอส
# =========================

# ส่งสัญญาณเมื่อ HP เปลี่ยน เพื่อให้ Manager อัปเดตข้อความได้
signal hp_changed(current_hp: int, max_hp: int)

# ส่งสัญญาณเมื่อหุ่นถูกทำลาย
signal dummy_defeated

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

# HP ปัจจุบัน
var current_hp: int = 0

# กันไม่ให้ตายซ้ำ
var is_defeated: bool = false

# อ้างอิงภาพ placeholder
var body_polygon: Polygon2D = null
var rim_polygon: Polygon2D = null

# อ้างอิง Hurtbox
var hurtbox: Area2D = null
var hurtbox_shape: CollisionShape2D = null


func _ready() -> void:
	# ตั้งค่าเริ่มต้น
	current_hp = max_hp

	# สร้างภาพและ hurtbox ด้วยโค้ด เพื่อลดความจำเป็นต้องทำ scene แยกตอนนี้
	create_visual_placeholder()
	create_hurtbox()

	# แจ้งค่า HP เริ่มต้นให้ Manager
	hp_changed.emit(current_hp, max_hp)

	print("Duel 1 Dummy ready. HP =", current_hp)


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
	var tween := create_tween()
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

	if is_instance_valid(body_polygon) and not is_defeated:
		body_polygon.color = body_color


func defeat_dummy() -> void:
	# ทำลายหุ่นและแจ้ง Manager
	if is_defeated:
		return

	is_defeated = true
	print("Duel 1 Dummy defeated")
	dummy_defeated.emit()

	# ทำให้หุ่นจางหาย ไม่ queue_free ทันทีเพื่อให้ผู้เล่นเห็นว่าตายแล้ว
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.82, 0.82), 0.24)
	tween.tween_property(self, "modulate:a", 0.0, 0.24)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
