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

# ให้ manager นี้ประมวลผลหลัง Player เพื่อแก้ flip_h ที่ player.gd อาจตั้งด้วย logic เก่าในเฟรมเดียวกัน
# ค่าใหญ่กว่า 0 ทำให้ทำงานช้ากว่า Player ที่ใช้ค่า default 0
@export var orientation_process_priority: int = 1000

# ถ้า true จะนัดแก้ orientation ซ้ำแบบ deferred อีกครั้งในเฟรมเดียวกัน
# ใช้ดักจังหวะ await timer ของ dash/attack ที่อาจเปลี่ยน facing หลังรอบ _process ปกติ
@export var use_deferred_orientation_fix: bool = true

# เปิด/ปิด debug print ตอน setup
@export var debug_print_orientation: bool = true

var player: Node = null
var sprite_2d: Sprite2D = null
var deferred_orientation_fix_queued: bool = false


func _ready() -> void:
	# ตั้ง priority ให้ตัวจัด orientation ทำงานหลัง player.gd
	# สำคัญมากตอน Dash/Attack จบ เพราะ player.gd อาจ update facing ใน coroutine แล้ว manager ต้องแก้ภาพให้ทันก่อน render
	process_priority = orientation_process_priority

	# หา reference ทันที 1 ครั้ง และเรียกซ้ำแบบ deferred เผื่อ node ยังจัดตัวไม่เสร็จ
	setup_references()
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	# ใช้ใน physics frame เพื่อให้ทิศภาพตรงกับ gameplay direction ระหว่างเดิน/lock-on/dash/attack
	process_orientation_frame()


func _process(_delta: float) -> void:
	# ใช้ใน idle frame เพื่อแก้จังหวะที่ player.gd เปลี่ยน facing หลัง await timer
	# เช่น Dash หรือ Attack จบแล้ว update_facing_to_locked_target() ทำให้เห็นภาพผิดฝั่งเสี้ยววินาที
	process_orientation_frame()


func process_orientation_frame() -> void:
	# จุดรวมการทำงาน เพื่อให้ _physics_process และ _process ใช้ logic เดียวกัน
	if not orientation_enabled:
		return

	if not are_references_ready():
		setup_references()
		return

	apply_sprite_orientation()
	queue_deferred_orientation_fix()


func queue_deferred_orientation_fix() -> void:
	# นัดแก้ซ้ำตอนท้ายเฟรม เพื่อดัก callback จาก await timer ของ player.gd
	# ถ้าไม่ทำแบบนี้ บางจังหวะ attack/dash coroutine อาจตั้ง flip_h ผิดหลัง manager ทำงานไปแล้ว
	if not use_deferred_orientation_fix:
		return

	if deferred_orientation_fix_queued:
		return

	deferred_orientation_fix_queued = true
	apply_deferred_sprite_orientation.call_deferred()


func apply_deferred_sprite_orientation() -> void:
	# แก้ซ้ำแบบ deferred และปลด queue เพื่อให้เฟรมถัดไปนัดใหม่ได้
	deferred_orientation_fix_queued = false

	if not orientation_enabled:
		return

	if not are_references_ready():
		setup_references()
		if not are_references_ready():
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
