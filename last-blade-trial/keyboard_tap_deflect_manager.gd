extends Node

# =========================
# KeyboardTapDeflectManager.gd
# ตัวเชื่อมปุ่ม Parry บนคีย์บอร์ดให้ทำงานแบบเดียวกับ Tap Deflect บนมือถือ
# แนวทาง mobile-first:
# - มือถือแตะ joystick เพื่อเปิด Tap Deflect
# - คีย์บอร์ดใช้ปุ่ม D / action parry เป็น Tap Deflect หลัก
# - ปุ่มซ้าย/ขวาบนคีย์บอร์ดยังเป็น Movement Deflect เสริม ไม่ใช่ Parry หลัก
# =========================

# เปิด/ปิดระบบแปลงปุ่มคีย์บอร์ดเป็น Tap Deflect
@export var keyboard_tap_deflect_enabled: bool = true

# action ที่ใช้ทดสอบ Tap Deflect บนคีย์บอร์ด
# project.godot ตอนนี้ผูก parry ไว้กับปุ่ม D
@export var tap_deflect_action_name: StringName = &"parry"

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# เปิด debug print เฉพาะตอนต้องการตรวจ input
@export var debug_print_keyboard_deflect: bool = false

# อ้างอิง Player หลัง setup
var player: Node = null


func _ready() -> void:
	# หา Player หลัง scene พร้อม เพื่อกันกรณีลำดับ node ยังไม่ครบตอน _ready
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องทำอะไร
	if not keyboard_tap_deflect_enabled:
		return

	# ถ้ายังหา Player ไม่เจอ ให้ลองหาใหม่
	if not is_instance_valid(player):
		setup_references()
		return

	# ถ้าผู้เล่นกด action parry บนคีย์บอร์ด ให้เปิด Tap Deflect window เหมือนมือถือ
	if Input.is_action_just_pressed(tap_deflect_action_name):
		trigger_keyboard_tap_deflect()


func setup_references() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")


func trigger_keyboard_tap_deflect() -> void:
	# ตั้งใจเรียก method เดียวกับ TouchControls เพื่อให้ keyboard/mobile ใช้ระบบ Tap Deflect ชุดเดียวกัน
	# ส่วนซ้าย/ขวาคีย์บอร์ดยังเป็น Movement Deflect แยกต่างหาก เพื่อคงความหมายของปุ่มเดินไว้
	if not is_instance_valid(player):
		return

	if not player.has_method("register_tap_deflect_input"):
		return

	player.register_tap_deflect_input()

	if debug_print_keyboard_deflect:
		print("Keyboard Tap Deflect input registered from action:", tap_deflect_action_name)
