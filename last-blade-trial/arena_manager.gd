extends Node

# =========================
# ArenaManager.gd
# ใช้เก็บข้อมูลขอบเขตสนามกลาง
# เพื่อให้ Player และ Enemy ใช้ค่าเดียวกัน
# =========================

# ขอบซ้ายของสนาม
@export var arena_min_x: float = 120.0

# ขอบขวาของสนาม
@export var arena_max_x: float = 1030.0

# =========================
# Arena Background Prototype
# =========================

# เปิด/ปิดฉากหลัง prototype แบบสร้างด้วยโค้ด
@export var enable_arena_background: bool = true

# ความกว้างของฉากหลัง prototype ให้ครอบจอหลักตอนนี้
@export var arena_background_width: float = 1152.0

# ความสูงของฉากหลัง prototype ให้ครอบจอหลักตอนนี้
@export var arena_background_height: float = 648.0

# ตำแหน่งพื้นสนามในแกน Y
@export var arena_floor_y: float = 390.0

# z_index ของฉากหลัง ให้ติดลบเพื่อไม่บัง Player / Boss / HUD
@export var arena_background_z_index: int = -200


func _ready() -> void:
	# เพิ่มตัวเองเข้า group เพื่อให้ node อื่นหา ArenaManager ได้ง่าย
	add_to_group("arena_manager")

	# เรียกแบบ deferred เพื่อรอให้ Main scene สร้าง child ทั้งหมดเสร็จก่อน
	# ถ้า add_child ระหว่าง parent กำลัง setup children จะเกิด error data.blocked ใน Godot
	create_arena_background_if_needed.call_deferred()

	print("ArenaManager ready. Bounds =", arena_min_x, "to", arena_max_x)


func create_arena_background_if_needed() -> void:
	# ถ้าปิดฉากหลังไว้ ไม่ต้องสร้างอะไร
	if not enable_arena_background:
		return

	# ต้องมี parent ก่อน เพราะเราจะเพิ่มฉากหลังเข้า Main scene
	var parent_node := get_parent()
	if parent_node == null:
		return

	# ถ้ามี ArenaBackground อยู่แล้ว ไม่สร้างซ้ำ
	if parent_node.get_node_or_null("ArenaBackground") != null:
		return

	# สร้าง root ของฉากหลังเป็น Node2D เพื่อให้ใช้ z_index ได้ในโลก 2D
	var background_root := Node2D.new()
	background_root.name = "ArenaBackground"
	background_root.z_index = arena_background_z_index
	parent_node.add_child(background_root)

	# ไม่จำเป็นต้อง move_child เพราะใช้ z_index ติดลบควบคุมให้ฉากหลังอยู่ด้านหลังแล้ว

	# ชั้นหลังสุด เป็นสีมืดไล่บรรยากาศแบบ arena ร้าง
	var back_wall := create_background_rect(
		Vector2.ZERO,
		Vector2(arena_background_width, arena_background_height),
		Color(0.055, 0.06, 0.085, 1.0)
	)
	background_root.add_child(back_wall)

	# พื้นสนาม ใช้สีเข้มกว่าเล็กน้อยเพื่อแยกพื้นที่ยืนจากฉากหลัง
	var floor_rect := create_background_rect(
		Vector2(0.0, arena_floor_y),
		Vector2(arena_background_width, arena_background_height - arena_floor_y),
		Color(0.075, 0.07, 0.065, 1.0)
	)
	background_root.add_child(floor_rect)

	# แถบแสงกลางฉาก ช่วยนำสายตาไปที่พื้นที่ดวล
	var center_glow := create_background_rect(
		Vector2(360.0, 120.0),
		Vector2(430.0, 270.0),
		Color(0.12, 0.105, 0.16, 0.65)
	)
	background_root.add_child(center_glow)

	# เส้นพื้นสนาม เพื่อให้ผู้เล่นรู้ว่าตัวละครยืนอยู่ตรงไหน
	var floor_line := create_background_line(
		PackedVector2Array([
			Vector2(0.0, arena_floor_y),
			Vector2(arena_background_width, arena_floor_y)
		]),
		Color(0.62, 0.52, 0.28, 0.70),
		4.0
	)
	background_root.add_child(floor_line)

	# เส้นขอบซ้าย/ขวาของ arena ให้ผู้เล่นอ่านขอบสนามได้ง่ายขึ้น
	var left_boundary := create_background_line(
		PackedVector2Array([
			Vector2(arena_min_x, arena_floor_y - 28.0),
			Vector2(arena_min_x, arena_floor_y + 45.0)
		]),
		Color(0.85, 0.65, 0.22, 0.75),
		5.0
	)
	background_root.add_child(left_boundary)

	var right_boundary := create_background_line(
		PackedVector2Array([
			Vector2(arena_max_x, arena_floor_y - 28.0),
			Vector2(arena_max_x, arena_floor_y + 45.0)
		]),
		Color(0.85, 0.65, 0.22, 0.75),
		5.0
	)
	background_root.add_child(right_boundary)

	# เส้นตกแต่งด้านหลังแบบเรียบ ๆ ให้ฉากไม่โล่งเกินไป แต่ไม่บังการต่อสู้
	var back_line_left := create_background_line(
		PackedVector2Array([
			Vector2(160.0, 170.0),
			Vector2(420.0, 145.0),
			Vector2(610.0, 172.0)
		]),
		Color(0.22, 0.21, 0.30, 0.70),
		3.0
	)
	background_root.add_child(back_line_left)

	var back_line_right := create_background_line(
		PackedVector2Array([
			Vector2(540.0, 180.0),
			Vector2(790.0, 150.0),
			Vector2(1010.0, 178.0)
		]),
		Color(0.22, 0.21, 0.30, 0.70),
		3.0
	)
	background_root.add_child(back_line_right)


func create_background_rect(top_left: Vector2, size: Vector2, color: Color) -> Polygon2D:
	# สร้างสี่เหลี่ยมจาก Polygon2D เพื่อใช้เป็นฉากหลังในโลก 2D
	var rect := Polygon2D.new()
	rect.polygon = PackedVector2Array([
		top_left,
		Vector2(top_left.x + size.x, top_left.y),
		Vector2(top_left.x + size.x, top_left.y + size.y),
		Vector2(top_left.x, top_left.y + size.y)
	])
	rect.color = color
	return rect


func create_background_line(points: PackedVector2Array, color: Color, width: float) -> Line2D:
	# สร้างเส้นตกแต่งฉากหลังโดยใช้ Line2D
	var line := Line2D.new()
	line.points = points
	line.default_color = color
	line.width = width
	line.antialiased = true
	return line


func clamp_x(value: float) -> float:
	# จำกัดค่าแกน X ให้อยู่ในขอบสนาม
	return clamp(value, arena_min_x, arena_max_x)


func clamp_node_x(target: Node2D) -> void:
	# ถ้า target ไม่มีจริง ไม่ต้องทำอะไร
	if not is_instance_valid(target):
		return

	# จำกัดตำแหน่งแกน X ของ node ให้อยู่ในขอบสนาม
	target.global_position.x = clamp_x(target.global_position.x)
