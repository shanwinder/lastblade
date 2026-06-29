extends Node

# =========================
# RunMetricsManager.gd
# เก็บสถิติเล็ก ๆ ของหนึ่งรอบการเล่น เพื่อช่วยประเมิน vertical slice
# ตอนนี้เริ่มจากจำนวน Parry สำเร็จ แล้วนำไปแสดงในหน้าผลลัพธ์หลังชนะ/แพ้
# =========================

# อ้างอิงบอสหลักในฉาก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง GameLoopManager เพื่ออ่านสถานะเกมและแก้ข้อความผลลัพธ์
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")

# เปิด/ปิดการเพิ่มข้อความสถิติลงในหน้าผลลัพธ์
@export var append_stats_to_result_screen: bool = true

# ค่าลด Posture ขั้นต่ำที่ถือว่าเป็น Parry สำเร็จ 1 ครั้ง
# ใช้กัน noise จาก float และกันการนับผิดจากค่าที่เปลี่ยนน้อยมาก
@export var minimum_posture_drop_to_count_parry: float = 0.5

# อ้างอิง node จริงหลังหาเจอ
var boss: Node = null
var game_loop_manager: Node = null

# จำนวน Parry สำเร็จในรอบปัจจุบัน
var successful_parry_count: int = 0

# Posture ของบอสในเฟรมก่อนหน้า ใช้จับว่ามีการลด Posture จาก Parry หรือไม่
var previous_boss_posture: float = -1.0

# จำสถานะ playing ของเฟรมก่อน เพื่อรู้จังหวะเริ่ม run ใหม่
var was_game_playing: bool = false

# กันไม่ให้เพิ่มข้อความสถิติซ้ำหลายรอบในหน้า result เดียวกัน
var has_appended_result_stats: bool = false


func _ready() -> void:
	# หา node หลัง scene setup เสร็จ เพื่อกัน node ยังไม่พร้อมตอน _ready
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	# ถ้ายังหา node ไม่ครบ ให้ลองหาใหม่
	if not are_references_ready():
		setup_references()
		return

	var is_playing_now: bool = is_game_playing()

	# เมื่อเริ่มรอบใหม่ ให้รีเซ็ตสถิติทั้งหมด
	if is_playing_now and not was_game_playing:
		reset_run_metrics()

	# ระหว่างเล่น ให้ติดตามจำนวน Parry สำเร็จจากการลด Posture ของบอส
	if is_playing_now:
		track_successful_parry_by_posture_drop()
	else:
		append_result_stats_if_needed()

	was_game_playing = is_playing_now


func setup_references() -> void:
	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา GameLoopManager จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")


func are_references_ready() -> bool:
	# ต้องมีบอสและ GameLoopManager จึงจะนับสถิติและแสดงผลได้
	return is_instance_valid(boss) and is_instance_valid(game_loop_manager)


func is_game_playing() -> bool:
	# อ่านสถานะเกมจาก GameLoopManager แบบปลอดภัย
	var state = game_loop_manager.get("game_state")
	return state == "playing"


func is_result_state() -> bool:
	# ตรวจว่าตอนนี้อยู่หน้า Victory หรือ Defeated แล้วหรือยัง
	var state = game_loop_manager.get("game_state")
	return state == "victory" or state == "game_over"


func reset_run_metrics() -> void:
	# เริ่มรอบใหม่ต้องล้างสถิติ เพื่อไม่ให้ค่าจากรอบก่อนติดมา
	successful_parry_count = 0
	has_appended_result_stats = false
	previous_boss_posture = get_boss_current_posture()
	print("RunMetricsManager reset run metrics")


func track_successful_parry_by_posture_drop() -> void:
	# ถ้ายังไม่มีค่าเริ่มต้น ให้ตั้งค่าก่อนแล้วรอเฟรมถัดไป
	var current_posture: float = get_boss_current_posture()
	if previous_boss_posture < 0.0:
		previous_boss_posture = current_posture
		return

	# ในระบบปัจจุบัน Boss Posture ลดจาก Parry สำเร็จเป็นหลัก
	# จึงใช้การลดลงของ Posture เป็นตัวนับ Parry โดยไม่ต้องแก้ combat หลัก
	var posture_drop: float = previous_boss_posture - current_posture
	if posture_drop >= minimum_posture_drop_to_count_parry:
		successful_parry_count += 1
		print("RunMetricsManager parry count =", successful_parry_count)

	previous_boss_posture = current_posture


func append_result_stats_if_needed() -> void:
	# เพิ่มสถิติลงหน้าผลลัพธ์เพียงครั้งเดียว หลังเข้าสู่ victory/game_over
	if not append_stats_to_result_screen:
		return

	if has_appended_result_stats:
		return

	if not is_result_state():
		return

	var body_label = game_loop_manager.get("body_label")
	if not (body_label is Label):
		return

	var label := body_label as Label
	if label.text.contains("Parry สำเร็จ"):
		has_appended_result_stats = true
		return

	label.text += "\nParry สำเร็จ: %d ครั้ง" % successful_parry_count
	has_appended_result_stats = true
	print("RunMetricsManager appended result stats. Parry =", successful_parry_count)


func get_boss_current_posture() -> float:
	# อ่านค่า current_posture จากบอสแบบปลอดภัย
	if not is_instance_valid(boss):
		return 0.0

	var posture_value = boss.get("current_posture")
	if posture_value == null:
		return 0.0

	return float(posture_value)
