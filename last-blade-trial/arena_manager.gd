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


func _ready() -> void:
	# เพิ่มตัวเองเข้า group เพื่อให้ node อื่นหา ArenaManager ได้ง่าย
	add_to_group("arena_manager")

	print("ArenaManager ready. Bounds =", arena_min_x, "to", arena_max_x)


func clamp_x(value: float) -> float:
	# จำกัดค่าแกน X ให้อยู่ในขอบสนาม
	return clamp(value, arena_min_x, arena_max_x)


func clamp_node_x(target: Node2D) -> void:
	# ถ้า target ไม่มีจริง ไม่ต้องทำอะไร
	if not is_instance_valid(target):
		return

	# จำกัดตำแหน่งแกน X ของ node ให้อยู่ในขอบสนาม
	target.global_position.x = clamp_x(target.global_position.x)
