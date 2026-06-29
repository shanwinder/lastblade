extends Node

# =========================
# BossWeightManager.gd
# ระบบคุมน้ำหนักของบอสให้รู้สึกถึกและนิ่งขึ้น
# ตีธรรมดาไม่ควรดันบอสถอยง่าย ๆ
# ให้บอสถอย/กระเด็นเฉพาะตอน Posture Break, Critical หรือ Finisher
# =========================

# อ้างอิงบอสหลักในฉาก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง Player เพื่อคำนวณทิศ recoil ให้ออกจากผู้เล่น
@export var player_path: NodePath = NodePath("../Player")

# เปิด/ปิดระบบน้ำหนักบอส
@export var boss_weight_enabled: bool = true

# ถ้า true จะยกเลิก knockback ที่เกิดจากการตีธรรมดา
@export var cancel_normal_hit_knockback: bool = true

# ถ้า true บอสจะถอยเล็กน้อยตอน posture แตก
@export var posture_break_recoil_enabled: bool = true

# ถ้า true บอสจะถอยชัดขึ้นเมื่อโดนโจมตีช่วง posture broken เช่น Critical / Finisher
@export var broken_state_damage_recoil_enabled: bool = true

# แรงถอยตอน posture แตก ไม่ควรแรงมาก แค่ให้รู้สึกเสียหลัก
@export var posture_break_recoil_force: float = 120.0

# ระยะเวลาถอยตอน posture แตก
@export var posture_break_recoil_time: float = 0.10

# แรงถอยตอนโดน Critical / Finisher ระหว่าง posture broken
@export var broken_state_damage_recoil_force: float = 230.0

# ระยะเวลาถอยตอนโดน Critical / Finisher
@export var broken_state_damage_recoil_time: float = 0.14

# ถ้า HP ลดน้อยกว่านี้ จะไม่ถือว่าเป็น damage recoil
@export var minimum_hp_drop_for_recoil: int = 1

# เปิด debug print ตอน manager ยกเลิกหรือใส่ recoil
@export var debug_print_boss_weight: bool = false

# อ้างอิง node จริง
var boss: Node = null
var player: Node2D = null

# จำสถานะเฟรมก่อนหน้า
var previous_hp: int = -1
var was_posture_broken: bool = false

# ตัวจับเวลา recoil ที่ manager เป็นคนสร้างเอง
var custom_recoil_time_left: float = 0.0


func _ready() -> void:
	# หา node หลัง scene พร้อม เพื่อกัน node ยังสร้างไม่ครบ
	setup_references.call_deferred()


func _physics_process(delta: float) -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องทำอะไร
	if not boss_weight_enabled:
		return

	# ถ้ายังหา node ไม่ครบ ให้ลองหาใหม่
	if not are_references_ready():
		setup_references()
		return

	# ถ้าบอสตายแล้ว ไม่ต้องจัดการน้ำหนักต่อ
	if get_bool_value(boss, "is_dead"):
		clear_custom_recoil()
		return

	# จัดการ recoil ที่ manager เป็นคนสร้างเอง
	update_custom_recoil(delta)

	# ยกเลิก knockback จาก hit ธรรมดา เพื่อให้บอสยืนหนักขึ้น
	cancel_unwanted_normal_knockback()

	# ตรวจเหตุการณ์ posture break และ damage ตอน posture broken
	watch_boss_state_changes()


func setup_references() -> void:
	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ตามชื่อ node
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback ตามชื่อ node
	player = get_node_or_null(player_path) as Node2D
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player") as Node2D

	# ตั้งค่าเริ่มต้นเมื่อหา boss ได้
	if is_instance_valid(boss) and previous_hp < 0:
		previous_hp = get_int_value(boss, "current_hp", 0)
		was_posture_broken = get_bool_value(boss, "is_posture_broken")


func are_references_ready() -> bool:
	# ต้องมีบอสก่อน ระบบจึงทำงานได้ ส่วน player ถ้าหายไปจะใช้ทิศ fallback
	return is_instance_valid(boss)


func update_custom_recoil(delta: float) -> void:
	# ถ้าไม่มี custom recoil ค้างอยู่ ไม่ต้องทำอะไร
	if custom_recoil_time_left <= 0.0:
		return

	custom_recoil_time_left -= delta

	# ถ้าหมดเวลา recoil แล้ว คืนสถานะให้บอสหยุดถอย
	if custom_recoil_time_left <= 0.0:
		clear_custom_recoil()


func cancel_unwanted_normal_knockback() -> void:
	# ตีธรรมดาไม่ควรทำให้บอสถอยง่าย ๆ
	if not cancel_normal_hit_knockback:
		return

	# ถ้า manager กำลังทำ custom recoil อยู่ อย่ายกเลิก recoil ของตัวเอง
	if custom_recoil_time_left > 0.0:
		return

	var is_knocked_back: bool = get_bool_value(boss, "is_knocked_back")
	var is_posture_broken: bool = get_bool_value(boss, "is_posture_broken")

	# ถ้าบอสถูก knockback ทั้งที่ไม่ได้ posture broken ให้ถือว่าเป็น knockback จาก hit ธรรมดา แล้วตัดทิ้ง
	if is_knocked_back and not is_posture_broken:
		boss.set("is_knocked_back", false)
		boss.set("knockback_velocity", Vector2.ZERO)

		if debug_print_boss_weight:
			print("BossWeightManager: canceled normal hit knockback")


func watch_boss_state_changes() -> void:
	# อ่านสถานะปัจจุบัน
	var current_hp: int = get_int_value(boss, "current_hp", previous_hp)
	var is_posture_broken: bool = get_bool_value(boss, "is_posture_broken")

	# ถ้าเพิ่งเข้า posture broken ให้ถอยเล็กน้อยเหมือนเสียหลัก
	if posture_break_recoil_enabled and is_posture_broken and not was_posture_broken:
		start_custom_recoil(posture_break_recoil_force, posture_break_recoil_time, "posture break")

	# ถ้า HP ลดระหว่าง posture broken ให้ถือว่าเป็น critical/finisher recoil
	var hp_drop: int = previous_hp - current_hp
	if broken_state_damage_recoil_enabled and is_posture_broken and hp_drop >= minimum_hp_drop_for_recoil:
		start_custom_recoil(broken_state_damage_recoil_force, broken_state_damage_recoil_time, "broken state damage")

	previous_hp = current_hp
	was_posture_broken = is_posture_broken


func start_custom_recoil(force: float, duration: float, reason: String) -> void:
	# คำนวณทิศ recoil ให้ออกจาก Player
	var direction: float = get_recoil_direction()

	boss.set("knockback_velocity", Vector2(direction * force, 0.0))
	boss.set("is_knocked_back", true)
	custom_recoil_time_left = max(duration, 0.01)

	if debug_print_boss_weight:
		print("BossWeightManager recoil:", reason, "force=", force, "time=", duration)


func clear_custom_recoil() -> void:
	# คืนสถานะ knockback ของบอสเมื่อ manager จัดการเสร็จ
	if not is_instance_valid(boss):
		return

	boss.set("is_knocked_back", false)
	boss.set("knockback_velocity", Vector2.ZERO)
	custom_recoil_time_left = 0.0


func get_recoil_direction() -> float:
	# ทิศหลักคือให้บอสถอยออกจาก Player
	if is_instance_valid(player) and boss is Node2D:
		var boss_node := boss as Node2D
		var direction: float = sign(boss_node.global_position.x - player.global_position.x)
		if direction != 0.0:
			return direction

	# fallback ใช้ทิศที่บอสหันอยู่ ถ้าอ่านได้
	var facing = boss.get("facing_direction")
	if facing != null:
		var fallback_direction: float = float(facing)
		if fallback_direction != 0.0:
			return fallback_direction

	return 1.0


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true


func get_int_value(target: Node, property_name: String, fallback: int) -> int:
	# อ่านค่า int จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return fallback

	return int(value)
