extends Node

# =========================
# PlayerAttackVFXManager.gd
# แสดงเอฟเฟกต์ฟันของ Player เพื่อให้เห็นระยะโจมตีชัดขึ้น
# ทำเป็น manager แยก เพื่อไม่แตะระบบโจมตีหลักใน player.gd
# =========================

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# เปิด/ปิดเอฟเฟกต์ฟันของ Player
@export var player_attack_vfx_enabled: bool = true

# เปิด/ปิดกรอบแสดงระยะ hitbox แบบจาง ๆ
@export var show_attack_range_box: bool = true

# ระยะเวลาที่เอฟเฟกต์ฟันแสดงบนจอ
# ลดให้สั้นกว่าบอส เพื่อให้เป็นเพียงตัวบอกระยะ ไม่แย่งน้ำหนักจากท่าบอส
@export var slash_duration: float = 0.12

# ระยะเวลาที่กรอบระยะโจมตีแสดงบนจอ
@export var range_box_duration: float = 0.10

# สีเส้นฟันหลัก ลด alpha ลงเพื่อให้ดูเบากว่าบอส
@export var slash_color: Color = Color(0.72, 0.92, 1.0, 0.62)

# สีเส้นฟันรอง/ขอบแสง ลดความสว่างและความทึบลง
@export var slash_core_color: Color = Color(1.0, 1.0, 1.0, 0.55)

# สีกรอบระยะโจมตีแบบโปร่งใส ลด alpha เพื่อไม่ให้ดูเป็นเอฟเฟกต์พลังแรงเกินไป
@export var range_box_color: Color = Color(0.35, 0.85, 1.0, 0.10)

# ความกว้างของเส้นฟันหลัก ลดจาก 12 เหลือ 6 เพื่อให้บางกว่าเอฟเฟกต์บอส
@export var slash_width: float = 6.0

# ความกว้างของเส้นฟันรอง ลดจาก 4 เหลือ 2
@export var slash_core_width: float = 2.0

# ขนาดกล่องระยะโจมตี ลดเล็กน้อยจาก 80x50 ให้ดูไม่ใหญ่เกินตัวละคร
@export var attack_range_box_size: Vector2 = Vector2(70.0, 42.0)

# ตำแหน่งยกเอฟเฟกต์ขึ้นจากเท้าตัวละคร
@export var slash_vertical_offset: float = -46.0

# z_index ของเอฟเฟกต์ ให้สูงกว่าตัวละครและฉากหลัง แต่ต่ำกว่า HUD
@export var slash_z_index: int = 165

# อ้างอิง Player จริงหลังหาเจอ
var player: Node2D = null

# จำสถานะโจมตี frame ก่อน เพื่อจับจังหวะเริ่มโจมตีเพียงครั้งเดียว
var was_attacking: bool = false


func _ready() -> void:
	# หา Player หลัง scene setup เสร็จ เพื่อกันกรณี node ยังไม่พร้อม
	find_player.call_deferred()


func _physics_process(_delta: float) -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องทำอะไร
	if not player_attack_vfx_enabled:
		return

	# ถ้ายังไม่เจอ Player หรือ Player ถูกลบ ให้ลองหาใหม่
	if not is_instance_valid(player):
		find_player()
		return

	# อ่านสถานะ is_attacking จาก player.gd แบบปลอดภัย
	var is_attacking_now: bool = get_bool_value(player, "is_attacking")

	# ถ้าเพิ่งเปลี่ยนจากไม่โจมตี -> โจมตี ให้แสดงเอฟเฟกต์ 1 ครั้ง
	if is_attacking_now and not was_attacking:
		show_player_attack_vfx()

	was_attacking = is_attacking_now


func find_player() -> void:
	# หา Player จาก NodePath ก่อน ถ้าไม่เจอค่อย fallback จาก parent
	var found_player := get_node_or_null(player_path)
	if found_player is Node2D:
		player = found_player as Node2D
		return

	if get_parent() == null:
		return

	found_player = get_parent().get_node_or_null("Player")
	if found_player is Node2D:
		player = found_player as Node2D


func show_player_attack_vfx() -> void:
	# ถ้า Player ไม่มีจริง ไม่ต้องสร้างเอฟเฟกต์
	if not is_instance_valid(player):
		return

	var facing_direction: int = int(get_float_value(player, "facing_direction", 1.0))
	if facing_direction == 0:
		facing_direction = 1

	# วางเอฟเฟกต์ด้านหน้าผู้เล่น ตามทิศที่หันอยู่
	var slash_origin: Vector2 = player.global_position + Vector2(float(facing_direction) * 30.0, slash_vertical_offset)

	# สร้าง root ของเอฟเฟกต์ เพื่อเลื่อน/จางทั้งชุดพร้อมกัน
	var slash_root := Node2D.new()
	slash_root.name = "PlayerSlashVFX"
	slash_root.global_position = slash_origin
	slash_root.scale.x = float(facing_direction)
	slash_root.z_index = slash_z_index
	get_parent().add_child(slash_root)

	# เส้นฟันหลัก เป็นเส้นโค้งเล็ก ๆ เพื่อบอกแนวและระยะฟัน โดยไม่ดูแรงกว่าบอส
	var slash_line := create_slash_line(slash_color, slash_width)
	slash_root.add_child(slash_line)

	# เส้นแกนกลางบาง ๆ ช่วยให้มองเห็นบนฉากมืด แต่ไม่สว่างเกินไป
	var slash_core := create_slash_line(slash_core_color, slash_core_width)
	slash_root.add_child(slash_core)

	# กล่องระยะโจมตีแบบโปร่งใส แสดงพื้นที่คร่าว ๆ ของ hitbox
	if show_attack_range_box:
		var range_box := create_range_box()
		slash_root.add_child(range_box)

	# ทำให้เส้นฟันขยับเล็กน้อยและจางหายเร็ว ไม่ขยายแรงเหมือนเอฟเฟกต์บอส
	var target_position: Vector2 = slash_root.global_position + Vector2(float(facing_direction) * 12.0, 0.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slash_root, "global_position", target_position, slash_duration)
	tween.tween_property(slash_root, "scale", Vector2(float(facing_direction) * 1.03, 1.03), slash_duration)
	tween.tween_property(slash_root, "modulate:a", 0.0, slash_duration)
	tween.set_parallel(false)
	tween.tween_callback(Callable(slash_root, "queue_free"))


func create_slash_line(line_color: Color, line_width: float) -> Line2D:
	# สร้างเส้นฟันแบบ Line2D โดยใช้หลายจุดให้ดูเป็นแนวโค้งเล็ก ๆ
	var line := Line2D.new()
	line.points = PackedVector2Array([
		Vector2(6.0, -16.0),
		Vector2(26.0, -24.0),
		Vector2(54.0, -14.0),
		Vector2(68.0, 2.0)
	])
	line.default_color = line_color
	line.width = line_width
	line.antialiased = true
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	return line


func create_range_box() -> Polygon2D:
	# สร้างกรอบโปร่งใสแทนระยะ hitbox ของ Player
	# จุดนี้ช่วยให้ผู้เล่นเห็นว่าฟันถึงแค่ไหน โดยไม่ต้องเดาจาก console
	var box := Polygon2D.new()
	var half_size: Vector2 = attack_range_box_size * 0.5
	var box_center := Vector2(45.0, -1.0)
	box.polygon = PackedVector2Array([
		box_center + Vector2(-half_size.x, -half_size.y),
		box_center + Vector2(half_size.x, -half_size.y),
		box_center + Vector2(half_size.x, half_size.y),
		box_center + Vector2(-half_size.x, half_size.y)
	])
	box.color = range_box_color
	return box


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true


func get_float_value(target: Node, property_name: String, fallback: float) -> float:
	# อ่านค่า float จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return fallback

	return float(value)
