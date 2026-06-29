extends Node

# =========================
# CombatDecayManager.gd
# คุมการค่อย ๆ ฟื้น Posture ของบอส และการค่อย ๆ ลด Focus ของผู้เล่น
# เพื่อบังคับให้ผู้เล่นรักษาแรงกดดัน ไม่ปล่อยจังหวะนานเกินไป
# =========================

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# อ้างอิง Boss ในฉากหลัก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# =========================
# Boss Posture Recovery
# =========================

# เปิด/ปิดระบบฟื้น Posture ของบอส
@export var boss_posture_recovery_enabled: bool = true

# เวลารอหลังบอสเสีย Posture หรือโดนโจมตี ก่อน Posture จะเริ่มฟื้น
# ค่า 4.0 ทำให้ผู้เล่นมีเวลาต่อแรงกดดัน ไม่รู้สึกว่าบอสฟื้นเร็วเกินไป
@export var boss_posture_recovery_delay: float = 4.0

# ความเร็วในการฟื้น Posture ต่อวินาที
# max_posture ตอนนี้คือ 120 ดังนั้น 10/s คือฟื้นจาก 0 เป็นเต็มประมาณ 12 วินาทีหลัง delay
@export var boss_posture_recovery_rate: float = 10.0

# =========================
# Player Focus Decay
# =========================

# เปิด/ปิดระบบ Focus ค่อย ๆ ลดลง
@export var player_focus_decay_enabled: bool = true

# เวลารอหลังผู้เล่นได้ Focus หรือกำลังกดโจมตี/Parry ก่อน Focus จะเริ่มลด
# ค่า 8.0 ค่อนข้างใจดี ให้ผู้เล่นมีเวลาหา posture break แล้วรีบใช้ Finisher
@export var player_focus_decay_delay: float = 8.0

# ความเร็วในการลด Focus ต่อวินาที
# ค่า 6/s แปลว่า Focus เต็ม 100 จะค่อย ๆ หมดในประมาณ 16.7 วินาทีหลัง delay
@export var player_focus_decay_rate: float = 6.0

# เปิด debug log สำหรับดูการฟื้น/ลดค่าระหว่างจูน
@export var debug_print_decay: bool = false

# อ้างอิง node จริงหลังหาเจอ
var player: Node = null
var boss: Node = null

# จับเวลาว่าบอสไม่ได้โดนกดดันนานแค่ไหน
var boss_no_pressure_time: float = 0.0

# จับเวลาว่าผู้เล่นไม่ได้สร้างแรงกดดันนานแค่ไหน
var player_no_focus_pressure_time: float = 0.0

# ใช้จำค่ารอบก่อน เพื่อรู้ว่าเพิ่งเสีย Posture / ได้ Focus / โดนโจมตีหรือไม่
var last_boss_posture: float = -1.0
var last_boss_hp: int = -1
var last_player_focus: float = -1.0

# ใช้ลดจำนวนการ emit ไม่ให้ HUD อัปเดตทุกเศษทศนิยมถี่เกินไป
var last_emitted_boss_posture_int: int = -999999
var last_emitted_player_focus_int: int = -999999


func _ready() -> void:
	# หา Player/Boss แบบ deferred เพื่อรอให้ Main scene setup children เสร็จก่อน
	find_combat_nodes.call_deferred()


func _physics_process(delta: float) -> void:
	# ถ้ายังหา node ไม่เจอ ให้ลองหาใหม่เรื่อย ๆ แบบปลอดภัย
	find_combat_nodes_if_needed()

	# คุมการฟื้น Posture ของบอส
	update_boss_posture_recovery(delta)

	# คุมการลด Focus ของผู้เล่น
	update_player_focus_decay(delta)


func find_combat_nodes_if_needed() -> void:
	# ถ้า Player หรือ Boss ยังไม่มี หรือ node ถูกลบไปแล้ว ให้หาใหม่
	if not is_instance_valid(player) or not is_instance_valid(boss):
		find_combat_nodes()


func find_combat_nodes() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback จาก parent
	if not is_instance_valid(player):
		player = get_node_or_null(player_path)
		if player == null and get_parent() != null:
			player = get_parent().get_node_or_null("Player")

	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback จาก parent
	if not is_instance_valid(boss):
		boss = get_node_or_null(boss_path)
		if boss == null and get_parent() != null:
			boss = get_parent().get_node_or_null("BossBrokenMaster")

	# ตั้งค่าเริ่มต้นของตัวแปรจำค่า เพื่อไม่ให้ frame แรกเข้าใจผิดว่าเกิดการเปลี่ยนแปลง
	if is_instance_valid(boss):
		last_boss_posture = get_float_value(boss, "current_posture", last_boss_posture)
		last_boss_hp = get_int_value(boss, "current_hp", last_boss_hp)
		last_emitted_boss_posture_int = int(round(last_boss_posture))

	if is_instance_valid(player):
		last_player_focus = get_float_value(player, "current_focus", last_player_focus)
		last_emitted_player_focus_int = int(round(last_player_focus))


func update_boss_posture_recovery(delta: float) -> void:
	# ถ้าปิดระบบ หรือยังไม่มี Boss ให้ไม่ต้องทำอะไร
	if not boss_posture_recovery_enabled:
		return

	if not is_instance_valid(boss):
		return

	# ถ้าบอสตายหรือกำลัง Posture Break ให้หยุดฟื้น Posture ก่อน
	if get_bool_value(boss, "is_dead") or get_bool_value(boss, "is_posture_broken"):
		boss_no_pressure_time = 0.0
		remember_boss_values()
		return

	var current_posture: float = get_float_value(boss, "current_posture", 0.0)
	var max_posture: float = get_float_value(boss, "max_posture", 120.0)
	var current_hp: int = get_int_value(boss, "current_hp", 0)

	# ถ้า Posture เต็มอยู่แล้ว ไม่ต้องฟื้น
	if current_posture >= max_posture:
		boss_no_pressure_time = 0.0
		remember_boss_values()
		return

	# ถ้า Posture ลดลง หรือ HP ลดลง แปลว่าผู้เล่นเพิ่งสร้างแรงกดดัน ให้ reset timer
	var posture_was_reduced: bool = current_posture < last_boss_posture - 0.01
	var boss_was_hit: bool = current_hp < last_boss_hp

	if posture_was_reduced or boss_was_hit:
		boss_no_pressure_time = 0.0
		remember_boss_values()
		return

	boss_no_pressure_time += delta

	# ยังไม่ครบ delay ให้รอก่อน เพื่อให้ผู้เล่นมีจังหวะตามต่อ
	if boss_no_pressure_time < boss_posture_recovery_delay:
		remember_boss_values()
		return

	var new_posture: float = min(current_posture + boss_posture_recovery_rate * delta, max_posture)
	boss.set("current_posture", new_posture)

	# อัปเดต HUD เฉพาะตอนค่าเต็มเปลี่ยน เพื่อไม่ spam signal มากเกินไป
	var new_posture_int: int = int(round(new_posture))
	if new_posture_int != last_emitted_boss_posture_int:
		last_emitted_boss_posture_int = new_posture_int
		if boss.has_method("emit_enemy_stats"):
			boss.emit_enemy_stats()

	if debug_print_decay:
		print("Boss posture recovering:", new_posture_int, "/", int(max_posture))

	remember_boss_values()


func update_player_focus_decay(delta: float) -> void:
	# ถ้าปิดระบบ หรือยังไม่มี Player ให้ไม่ต้องทำอะไร
	if not player_focus_decay_enabled:
		return

	if not is_instance_valid(player):
		return

	# ถ้าผู้เล่นตายแล้ว ไม่ต้องลด Focus ต่อ
	if get_bool_value(player, "is_dead"):
		player_no_focus_pressure_time = 0.0
		remember_player_focus()
		return

	var current_focus: float = get_float_value(player, "current_focus", 0.0)
	var max_focus: float = get_float_value(player, "max_focus", 100.0)

	# ถ้า Focus ไม่มีอยู่แล้ว ไม่ต้องลด
	if current_focus <= 0.0:
		player_no_focus_pressure_time = 0.0
		remember_player_focus()
		return

	# ถ้า Focus เพิ่มขึ้น แปลว่าผู้เล่นเพิ่ง Parry สำเร็จ ให้ reset timer
	var focus_was_gained: bool = current_focus > last_player_focus + 0.01
	if focus_was_gained:
		player_no_focus_pressure_time = 0.0
		remember_player_focus()
		return

	# ถ้าผู้เล่นกำลังโจมตีหรือ Parry ให้ถือว่ายังพยายามกดดันอยู่ จึงยังไม่ลด Focus
	if is_player_creating_focus_pressure():
		player_no_focus_pressure_time = 0.0
		remember_player_focus()
		return

	player_no_focus_pressure_time += delta

	# ยังไม่ครบ delay ให้รอก่อน
	if player_no_focus_pressure_time < player_focus_decay_delay:
		remember_player_focus()
		return

	var new_focus: float = max(current_focus - player_focus_decay_rate * delta, 0.0)
	player.set("current_focus", new_focus)

	# ถ้า Focus ลดต่ำกว่าเต็ม ให้ reset flag เพื่อให้รอบหน้าถ้าเต็มอีกจะขึ้น FINISHER READY! ได้อีกครั้ง
	if new_focus < max_focus:
		player.set("has_shown_focus_ready_message", false)

	# อัปเดต HUD เฉพาะตอนค่าเต็มเปลี่ยน เพื่อไม่ spam signal มากเกินไป
	var new_focus_int: int = int(round(new_focus))
	if new_focus_int != last_emitted_player_focus_int:
		last_emitted_player_focus_int = new_focus_int
		if player.has_method("emit_stats"):
			player.emit_stats()

	if debug_print_decay:
		print("Player focus decaying:", new_focus_int, "/", int(max_focus))

	remember_player_focus()


func is_player_creating_focus_pressure() -> bool:
	# ใช้ Attack หรือ Parry เป็นแรงกดดันหลัก
	# Dash ไม่ reset timer เพื่อไม่ให้ผู้เล่นวิ่งหนีแล้วรักษา Focus ได้ฟรี
	if not is_instance_valid(player):
		return false

	return get_bool_value(player, "is_attacking") or get_bool_value(player, "is_parrying")


func remember_boss_values() -> void:
	# จำค่า Boss รอบล่าสุดไว้เทียบใน frame ถัดไป
	if not is_instance_valid(boss):
		return

	last_boss_posture = get_float_value(boss, "current_posture", last_boss_posture)
	last_boss_hp = get_int_value(boss, "current_hp", last_boss_hp)


func remember_player_focus() -> void:
	# จำค่า Focus รอบล่าสุดไว้เทียบใน frame ถัดไป
	if not is_instance_valid(player):
		return

	last_player_focus = get_float_value(player, "current_focus", last_player_focus)


func get_float_value(target: Node, property_name: String, fallback: float) -> float:
	# อ่านค่า float จาก node แบบปลอดภัย เผื่อ property ยังไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return fallback

	return float(value)


func get_int_value(target: Node, property_name: String, fallback: int) -> int:
	# อ่านค่า int จาก node แบบปลอดภัย เผื่อ property ยังไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return fallback

	return int(value)


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย เผื่อ property ยังไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true
