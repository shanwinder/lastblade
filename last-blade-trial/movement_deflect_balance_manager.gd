extends Node

# =========================
# MovementDeflectBalanceManager.gd
# ตัวจัดสมดุล Movement/Tap Deflect เพื่อกันสูตรโกงกดซ้าย-ขวารัว ๆ หน้า Boss
# แนวคิดหลัก: การเดินยังฟรี แต่การเปิด Deflect window ต้องมีต้นทุนและมี cooldown
# =========================

# เปิด/ปิดระบบคุมสมดุล Deflect ทั้งหมด
@export var balance_enabled: bool = true

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# Stamina ที่ใช้เมื่อเปิด Movement Deflect window จากการเปลี่ยนทิศซ้าย/ขวา
@export var movement_deflect_stamina_cost: float = 8.0

# Stamina ที่ใช้เมื่อเปิด Tap Deflect window จากการแตะ joystick
@export var tap_deflect_stamina_cost: float = 10.0

# ระยะ cooldown หลังเปิด Movement Deflect สำเร็จ
# ระหว่าง cooldown ถ้าส่ายซ้าย/ขวาซ้ำ จะไม่ refresh Deflect window
@export var movement_deflect_input_cooldown: float = 0.30

# ระยะ cooldown หลังเปิด Tap Deflect สำเร็จ
@export var tap_deflect_input_cooldown: float = 0.30

# ช่วงเวลาที่ใช้ตรวจว่าผู้เล่นส่ายซ้าย/ขวารัวเกินไปหรือไม่
@export var direction_spam_check_window: float = 1.0

# จำนวนครั้งที่ยอมให้เปลี่ยนทิศเพื่อ Deflect ภายใน spam window
@export var direction_spam_limit: int = 4

# Posture damage เมื่อผู้เล่นพยายามส่ายซ้าย/ขวาเพื่อโกง Deflect มากเกินไป
@export var direction_spam_posture_damage: float = 6.0

# ระยะเวลาล็อกไม่ให้เปิด Deflect window หลังโดนลงโทษจากการ spam
@export var direction_spam_deflect_lockout: float = 0.45

# ถ้า true จะแสดงข้อความ NO STAMINA! เมื่อพยายามเปิด Deflect แต่ Stamina ไม่พอ
@export var show_no_stamina_feedback: bool = true

# เปิด/ปิด debug print เพื่อใช้จูนบาลานซ์บนมือถือจริง
@export var debug_print_balance: bool = true

# อ้างอิง Player จริงหลัง setup
var player: Node = null

# timestamp ของ movement/tap deflect ล่าสุดที่ manager เห็นแล้ว
var last_seen_movement_deflect_msec: int = -999999
var last_seen_tap_deflect_msec: int = -999999

# เวลาที่อนุญาตให้เปิด movement/tap deflect ครั้งต่อไป
var next_movement_deflect_allowed_msec: int = 0
var next_tap_deflect_allowed_msec: int = 0

# เวลาที่ lockout จากการ spam จะหมด
var spam_lockout_until_msec: int = 0

# เก็บประวัติการพยายาม trigger movement deflect เพื่อจับสูตรซ้าย/ขวารัว
var recent_direction_change_msecs: Array[int] = []


func _ready() -> void:
	# ให้ manager นี้รันหลัง Player แต่ก่อน Boss โดยวาง node ไว้หลัง Player ใน scene
	# ไม่ตั้ง process_priority ต่ำกว่า Player เพราะต้องรอให้ Player บันทึก input ก่อน
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	if not balance_enabled:
		return

	if not is_instance_valid(player):
		setup_references()
		return

	if is_player_unavailable():
		return

	check_new_movement_deflect_input()
	check_new_tap_deflect_input()


func setup_references() -> void:
	# หา Player จาก NodePath ก่อน ถ้าไม่เจอใช้ชื่อ Player เป็น fallback
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")


func is_player_unavailable() -> bool:
	# ถ้า Player อยู่ในสถานะควบคุมไม่ได้ ไม่ต้องประเมิน Deflect balance
	if not is_instance_valid(player):
		return true

	if player.get("is_dead") == true:
		return true

	if player.get("is_posture_broken") == true:
		return true

	if player.get("is_knocked_back") == true:
		return true

	return false


func check_new_movement_deflect_input() -> void:
	# ตรวจว่ามี movement deflect timestamp ใหม่หรือไม่
	var value = player.get("last_movement_deflect_msec")
	if value == null:
		return

	var movement_msec: int = int(value)
	if movement_msec <= 0:
		return

	if movement_msec == last_seen_movement_deflect_msec:
		return

	last_seen_movement_deflect_msec = movement_msec
	handle_movement_deflect_attempt(movement_msec)


func check_new_tap_deflect_input() -> void:
	# ตรวจว่ามี tap deflect timestamp ใหม่หรือไม่
	var value = player.get("last_tap_deflect_msec")
	if value == null:
		return

	var tap_msec: int = int(value)
	if tap_msec <= 0:
		return

	if tap_msec == last_seen_tap_deflect_msec:
		return

	last_seen_tap_deflect_msec = tap_msec
	handle_tap_deflect_attempt(tap_msec)


func handle_movement_deflect_attempt(trigger_msec: int) -> void:
	# ทุกครั้งที่เปลี่ยนทิศเพื่อเปิด Movement Deflect จะเข้ามาที่นี่
	record_direction_change_attempt(trigger_msec)

	if Time.get_ticks_msec() < spam_lockout_until_msec:
		clear_movement_deflect_window("movement lockout")
		return

	if is_direction_spam_now(trigger_msec):
		apply_direction_spam_penalty()
		clear_movement_deflect_window("direction spam")
		return

	if trigger_msec < next_movement_deflect_allowed_msec:
		clear_movement_deflect_window("movement cooldown")
		return

	if not spend_stamina_for_deflect(movement_deflect_stamina_cost, "movement"):
		clear_movement_deflect_window("movement no stamina")
		return

	next_movement_deflect_allowed_msec = trigger_msec + int(movement_deflect_input_cooldown * 1000.0)

	if debug_print_balance:
		print("Movement Deflect accepted. Stamina cost =", int(movement_deflect_stamina_cost))


func handle_tap_deflect_attempt(trigger_msec: int) -> void:
	# Tap Deflect ก็มีต้นทุนและ cooldown เพื่อกันการแตะรัว
	if Time.get_ticks_msec() < spam_lockout_until_msec:
		clear_tap_deflect_window("tap lockout")
		return

	if trigger_msec < next_tap_deflect_allowed_msec:
		clear_tap_deflect_window("tap cooldown")
		return

	if not spend_stamina_for_deflect(tap_deflect_stamina_cost, "tap"):
		clear_tap_deflect_window("tap no stamina")
		return

	next_tap_deflect_allowed_msec = trigger_msec + int(tap_deflect_input_cooldown * 1000.0)

	if debug_print_balance:
		print("Tap Deflect accepted. Stamina cost =", int(tap_deflect_stamina_cost))


func spend_stamina_for_deflect(cost: float, deflect_type: String) -> bool:
	# การเดินไม่เสีย Stamina แต่การเปิด Deflect window ต้องเสีย Stamina
	var stamina_value = player.get("current_stamina")
	if stamina_value == null:
		return true

	var current_stamina: float = float(stamina_value)
	if current_stamina < cost:
		if debug_print_balance:
			print("Deflect blocked by low stamina. Type =", deflect_type, "Stamina =", int(current_stamina), "Cost =", int(cost))

		if show_no_stamina_feedback and player.has_method("show_stamina_insufficient_feedback"):
			player.call("show_stamina_insufficient_feedback")

		return false

	player.set("current_stamina", maxf(current_stamina - cost, 0.0))
	if player.has_method("emit_stats"):
		player.call("emit_stats")

	return true


func record_direction_change_attempt(trigger_msec: int) -> void:
	# เก็บประวัติการส่ายซ้าย/ขวาเพื่อจับการ spam
	recent_direction_change_msecs.append(trigger_msec)
	trim_direction_change_history(trigger_msec)


func trim_direction_change_history(now_msec: int) -> void:
	# ลบ event เก่าที่อยู่นอกช่วงตรวจ spam
	var oldest_allowed: int = now_msec - int(direction_spam_check_window * 1000.0)
	var result: Array[int] = []

	for item in recent_direction_change_msecs:
		if item >= oldest_allowed:
			result.append(item)

	recent_direction_change_msecs = result


func is_direction_spam_now(now_msec: int) -> bool:
	# true เมื่อส่ายซ้าย/ขวาเกินจำนวนที่อนุญาตในช่วงเวลาสั้น ๆ
	trim_direction_change_history(now_msec)
	return recent_direction_change_msecs.size() > direction_spam_limit


func apply_direction_spam_penalty() -> void:
	# ลงโทษด้วย Player Posture ไม่ใช่หัก movement ทั่วไป เพื่อให้การเดินปกติยังไม่อึดอัด
	if player.has_method("apply_player_posture_damage"):
		player.call("apply_player_posture_damage", direction_spam_posture_damage)

	spam_lockout_until_msec = Time.get_ticks_msec() + int(direction_spam_deflect_lockout * 1000.0)
	next_movement_deflect_allowed_msec = spam_lockout_until_msec
	next_tap_deflect_allowed_msec = spam_lockout_until_msec
	recent_direction_change_msecs.clear()

	if debug_print_balance:
		print("Direction spam penalty! Posture damage =", int(direction_spam_posture_damage))


func clear_movement_deflect_window(reason: String) -> void:
	# ล้างเฉพาะ movement window เพื่อให้ input ครั้งนี้ไม่กลายเป็น Parry ฟรี
	player.set("last_movement_deflect_msec", -999999)
	if player.get("last_active_deflect_type") == "movement":
		player.set("last_active_deflect_type", "")

	if debug_print_balance:
		print("Movement Deflect blocked:", reason)


func clear_tap_deflect_window(reason: String) -> void:
	# ล้างเฉพาะ tap window เพื่อให้ tap ครั้งนี้ไม่กลายเป็น Parry ฟรี
	player.set("last_tap_deflect_msec", -999999)
	if player.get("last_active_deflect_type") == "tap":
		player.set("last_active_deflect_type", "")

	if debug_print_balance:
		print("Tap Deflect blocked:", reason)
