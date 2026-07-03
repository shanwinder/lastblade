extends Node

# =========================
# PlayerSpriteOrientationManager.gd
# ตัวช่วยคุมทิศภาพ Player เมื่อ source sprite หันซ้ายหรือขวา
# ใช้แก้ช่วงเปลี่ยนผ่านจาก placeholder ไปเป็น sprite จริง โดยไม่รื้อ player.gd ทั้งไฟล์ทันที
# =========================

# เปิด/ปิดระบบคุมทิศ sprite
@export var orientation_enabled: bool = true

# อ้างอิง Player หลัก ถ้าเว้นไว้จะใช้ parent ของ manager เป็น Player
@export var player_path: NodePath = NodePath("..")

# อ้างอิง Sprite2D ของ Player
@export var sprite_path: NodePath = NodePath("../Sprite2D")

# true = ภาพต้นทางหันซ้าย, false = ภาพต้นทางหันขวา
# idle sprite ชุด nameless_blade ปัจจุบันเป็น source หันซ้าย
@export var sprite_source_faces_left: bool = true

# ถ้า true จะบังคับ scale.x ให้เป็นค่าบวก เพื่อเลิกใช้ negative scale workaround
@export var force_positive_scale_x: bool = true

# เปิด/ปิด debug print ตอน setup
@export var debug_print_orientation: bool = true

var player: Node = null
var sprite_2d: Sprite2D = null


func _ready() -> void:
	# รอให้ Player และ Sprite2D พร้อมก่อนค่อยหา reference
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	if not orientation_enabled:
		return

	if not are_references_ready():
		setup_references()
		return

	apply_sprite_orientation()


func setup_references() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอให้ใช้ parent เป็น fallback
	player = get_node_or_null(player_path)
	if player == null:
		player = get_parent()

	# หา Sprite2D จาก path ก่อน ถ้าไม่เจอให้ลองหาใน Player
	sprite_2d = get_node_or_null(sprite_path) as Sprite2D
	if sprite_2d == null and player != null:
		sprite_2d = player.get_node_or_null("Sprite2D") as Sprite2D

	if debug_print_orientation and are_references_ready():
		print("PlayerSpriteOrientationManager ready. Source faces left =", sprite_source_faces_left)


func are_references_ready() -> bool:
	# ต้องมีทั้ง Player และ Sprite2D จึงจัดทิศภาพได้
	return is_instance_valid(player) and is_instance_valid(sprite_2d)


func apply_sprite_orientation() -> void:
	# อ่าน facing_direction จาก player.gd ซึ่งยังเป็นแหล่งจริงของ gameplay direction
	var facing_value = player.get("facing_direction")
	if facing_value == null:
		return

	var facing_direction: int = int(facing_value)
	if facing_direction == 0:
		return

	# เลิกใช้ negative scale workaround โดยบังคับให้ scale.x เป็นค่าบวก
	# การกลับซ้าย/ขวาจะใช้ flip_h เท่านั้น ทำให้ดูแลง่ายกว่า
	if force_positive_scale_x:
		var current_scale: Vector2 = sprite_2d.scale
		if current_scale.x < 0.0:
			current_scale.x = absf(current_scale.x)
			sprite_2d.scale = current_scale

	# ถ้า source หันซ้าย: gameplay หันขวาต้อง flip
	# ถ้า source หันขวา: gameplay หันซ้ายต้อง flip
	if sprite_source_faces_left:
		sprite_2d.flip_h = facing_direction > 0
	else:
		sprite_2d.flip_h = facing_direction < 0
