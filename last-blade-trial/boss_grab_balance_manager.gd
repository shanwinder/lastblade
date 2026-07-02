extends Node

# =========================
# BossGrabBalanceManager.gd
# ระบบ Boss Grab แบบแยก manager เพื่อแก้สูตร Lock-on -> Dash -> Attack
# ใช้ลงโทษการอยู่ประชิด Boss หรือ Dash จบใกล้ Boss โดยไม่รื้อ BossBrokenMaster.gd ทั้งไฟล์
# =========================

# เปิด/ปิดระบบ Grab ทั้งหมด
@export var grab_enabled: bool = true

# อ้างอิง Player ในฉาก
@export var player_path: NodePath = NodePath("../Player")

# อ้างอิง Boss หลักในฉาก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง GameLoopManager ถ้ามี เพื่อให้ Grab ทำงานเฉพาะตอน playing
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")

# ระยะประชิดที่ Boss มีสิทธิ์ใช้ Grab
@export var grab_close_range: float = 72.0

# ระยะที่ถือว่า Dash landing ใกล้ Boss และควรเสี่ยงโดน Grab มากขึ้น
@export var grab_dash_landing_range: float = 96.0

# โอกาสพื้นฐานในการออก Grab เมื่อ Player อยู่ประชิด
@export_range(0.0, 1.0, 0.01) var grab_chance: float = 0.18

# โบนัสโอกาส Grab เมื่อ Player เพิ่ง Dash จบใกล้ Boss
@export_range(0.0, 1.0, 0.01) var grab_dash_landing_bonus_chance: float = 0.35

# ระยะเวลาระหว่างการประเมินว่าจะใช้ Grab หรือไม่
# ใช้กันไม่ให้สุ่มทุก physics frame จน Grab ออกถี่เกินไป
@export var grab_evaluation_interval: float = 0.25

# Wind-up ก่อน Grab จะจับจริง
@export var grab_windup_time: float = 0.55

# ช่วง active ที่ถือว่า Boss กำลังจับ
@export var grab_active_time: float = 0.18

# เวลาพักหลัง Grab เพื่อคืนจังหวะให้ Player
@export var grab_cooldown_bonus: float = 0.35

# ดาเมจ HP จาก Grab ไม่ควรสูงมาก เพราะเป้าหมายคือหยุดสูตร ไม่ใช่ฆ่าทันที
@export var grab_damage: int = 12

# Posture damage เพิ่มจาก Grab ใช้ลงโทษการอยู่ประชิดและ Dash spam
@export var grab_posture_damage: float = 42.0

# ข้อความ hint ตอน Boss เตรียม Grab
@export var grab_hint_text: String = "BACK!"

# ข้อความ feedback เมื่อติด Grab
@export var grabbed_feedback_text: String = "GRABBED!"

# ขนาดตัวอักษร feedback เมื่อติด Grab
@export var grabbed_feedback_font_size: int = 26

# =========================
# Anti-Repetition Memory แบบเบา ๆ
# =========================

# เปิด/ปิดระบบจำพฤติกรรมซ้ำของผู้เล่น
@export var anti_repetition_memory_enabled: bool = true

# ช่วงเวลาที่ใช้จำพฤติกรรมซ้ำ
@export var recent_action_memory_window: float = 4.0

# โบนัสโอกาส Grab ต่อจำนวน Dash ในช่วง memory window
@export_range(0.0, 1.0, 0.01) var dash_spam_grab_bonus_per_event: float = 0.08

# โบนัสโอกาส Grab ต่อจำนวน Attack ในช่วง memory window
@export_range(0.0, 1.0, 0.01) var attack_spam_grab_bonus_per_event: float = 0.06

# โบนัสโอกาส Grab ต่อจำนวน Deflect สำเร็จในช่วง memory window
@export_range(0.0, 1.0, 0.01) var deflect_spam_grab_bonus_per_event: float = 0.04

# เพดานโบนัสรวมจาก Anti-Repetition เพื่อไม่ให้ Boss unfair เกินไป
@export_range(0.0, 1.0, 0.01) var anti_repetition_max_bonus: float = 0.30

# เปิด/ปิด debug print
@export var debug_print_grab: bool = true

# อ้างอิง node จริงหลัง setup
var player: Node2D = null
var boss: Node = null
var game_loop_manager: Node = null

# ตัวจับเวลา evaluation
var evaluation_timer: float = 0.0

# ป้องกันไม่ให้ Grab ซ้อนตัวเอง
var is_grabbing: bool = false

# เวลาที่อนุญาตให้ Grab ครั้งต่อไปได้
var next_grab_allowed_msec: int = 0

# จำ timestamp ของ Dash/Attack/Deflect ล่าสุดที่เห็น เพื่อไม่บันทึกซ้ำทุก frame
var last_seen_dash_end_msec: int = -999999
var last_seen_deflect_msec: int = -999999
var was_player_attacking: bool = false

# เก็บ event ย้อนหลังสำหรับ Anti-Repetition
var recent_dash_msecs: Array[int] = []
var recent_attack_msecs: Array[int] = []
var recent_deflect_msecs: Array[int] = []


func _ready() -> void:
	# หา node หลังทุกอย่างใน scene พร้อมแล้ว เพื่อกันกรณี Boss หรือ Player ยังไม่ ready
	setup_references.call_deferred()


func _physics_process(delta: float) -> void:
	# ถ้าปิดระบบ Grab ให้ไม่ทำอะไร
	if not grab_enabled:
		return

	# ถ้ายังหา reference ไม่ครบ ให้ลองหาใหม่
	if not are_references_ready():
		setup_references()
		return

	# ทำงานเฉพาะตอนเกมกำลัง playing ถ้ามี GameLoopManager ให้ตรวจสถานะก่อน
	if not is_game_playing_if_available():
		return

	# อัปเดตความจำพฤติกรรมซ้ำของผู้เล่น
	update_anti_repetition_memory()

	# ถ้ากำลัง Grab อยู่ ไม่ต้องประเมินรอบใหม่
	if is_grabbing:
		return

	# ประเมินเป็นช่วง ๆ ไม่ใช่ทุก frame เพื่อไม่ให้ Grab รัวเกินไป
	evaluation_timer += delta
	if evaluation_timer < grab_evaluation_interval:
		return
	evaluation_timer = 0.0

	if should_start_grab():
		start_grab()


func setup_references() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	player = get_node_or_null(player_path) as Node2D
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player") as Node2D

	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วย group combat_target หรือชื่อ node
	boss = get_node_or_null(boss_path)
	if boss == null:
		var targets := get_tree().get_nodes_in_group("combat_target")
		if targets.size() > 0:
			boss = targets[0]

	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา GameLoopManager แบบ optional
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")


func are_references_ready() -> bool:
	# ต้องมีทั้ง Player และ Boss จึงทำงานได้ ส่วน GameLoopManager เป็น optional
	return is_instance_valid(player) and is_instance_valid(boss)


func is_game_playing_if_available() -> bool:
	# ถ้าไม่มี GameLoopManager ให้ยอมทำงาน เพื่อรองรับ scene test แยก
	if not is_instance_valid(game_loop_manager):
		return true

	var state = game_loop_manager.get("game_state")
	if state == null:
		return true

	return str(state) == "playing"


func should_start_grab() -> bool:
	# เงื่อนไขหลักก่อนใช้ Grab ต้องให้ Boss ยังพร้อมและไม่ได้ทำท่าอื่นอยู่
	if Time.get_ticks_msec() < next_grab_allowed_msec:
		return false

	if not is_boss_available_for_grab():
		return false

	if not is_player_available_for_grab_check():
		return false

	var distance_to_player := get_distance_to_player()
	var is_close := distance_to_player <= grab_close_range
	var is_dash_landing_close := is_player_dash_landing_risk() and distance_to_player <= grab_dash_landing_range

	# ถ้าไม่ได้ใกล้ และไม่ได้เพิ่ง Dash จบใกล้ Boss ก็ไม่ควร Grab
	if not is_close and not is_dash_landing_close:
		return false

	var final_chance := grab_chance
	if is_dash_landing_close:
		final_chance += grab_dash_landing_bonus_chance

	# ถ้าอยู่ใกล้ ให้เพิ่มโบนัสจากพฤติกรรมซ้ำ เช่น Dash/Attack/Deflect บ่อย
	if is_close:
		final_chance += get_anti_repetition_grab_bonus()

	final_chance = clamp(final_chance, 0.0, 1.0)
	var roll := randf()

	if debug_print_grab:
		print("Grab check: distance=", int(distance_to_player), "dash_risk=", is_dash_landing_close, "chance=", final_chance, "roll=", roll)

	return roll <= final_chance


func is_boss_available_for_grab() -> bool:
	# อ่านสถานะ Boss ด้วย get() เพื่อไม่ผูกกับ class ภายในมากเกินไป
	if get_bool_value(boss, "is_dead"):
		return false

	if get_bool_value(boss, "is_posture_broken"):
		return false

	if get_bool_value(boss, "is_staggered"):
		return false

	if get_bool_value(boss, "is_winding_up"):
		return false

	if get_bool_value(boss, "is_attacking"):
		return false

	if get_bool_value(boss, "is_knocked_back"):
		return false

	if not get_bool_value(boss, "can_attack"):
		return false

	return true


func is_player_available_for_grab_check() -> bool:
	# ถ้า Player ตาย หรือ Posture Broken อยู่แล้ว ไม่ต้อง Grab ซ้ำ
	if not is_instance_valid(player):
		return false

	var is_player_dead = player.get("is_dead")
	if is_player_dead == true:
		return false

	var is_player_posture_broken = player.get("is_posture_broken")
	if is_player_posture_broken == true:
		return false

	return true


func get_distance_to_player() -> float:
	# ใช้ระยะบนแกน X เพราะเกมเป็น 2D side-view duel
	if not (boss is Node2D):
		return 99999.0

	return abs(player.global_position.x - (boss as Node2D).global_position.x)


func is_player_dash_landing_risk() -> bool:
	# ถ้า Player มี method สำหรับ Dash Landing Risk ให้ใช้ข้อมูลนั้น
	if player.has_method("is_in_dash_landing_risk_window"):
		return player.call("is_in_dash_landing_risk_window") == true

	return false


func update_anti_repetition_memory() -> void:
	# บันทึก Dash จบล่าสุด ถ้า timestamp เปลี่ยน
	var dash_end_value = player.get("last_dash_end_msec")
	if dash_end_value != null:
		var dash_end_msec := int(dash_end_value)
		if dash_end_msec > 0 and dash_end_msec != last_seen_dash_end_msec:
			last_seen_dash_end_msec = dash_end_msec
			recent_dash_msecs.append(dash_end_msec)

	# บันทึก Attack ตอนเริ่ม attack จาก false -> true
	var is_attacking_now = player.get("is_attacking") == true
	if is_attacking_now and not was_player_attacking:
		recent_attack_msecs.append(Time.get_ticks_msec())
	was_player_attacking = is_attacking_now

	# บันทึก Deflect สำเร็จล่าสุด ถ้า timestamp เปลี่ยน
	var deflect_value = player.get("last_successful_deflect_msec")
	if deflect_value != null:
		var deflect_msec := int(deflect_value)
		if deflect_msec > 0 and deflect_msec != last_seen_deflect_msec:
			last_seen_deflect_msec = deflect_msec
			recent_deflect_msecs.append(deflect_msec)

	trim_recent_memory_arrays()


func trim_recent_memory_arrays() -> void:
	# ลบ event ที่เก่าเกิน memory window ออก
	var oldest_allowed := Time.get_ticks_msec() - int(recent_action_memory_window * 1000.0)
	recent_dash_msecs = filter_recent_msecs(recent_dash_msecs, oldest_allowed)
	recent_attack_msecs = filter_recent_msecs(recent_attack_msecs, oldest_allowed)
	recent_deflect_msecs = filter_recent_msecs(recent_deflect_msecs, oldest_allowed)


func filter_recent_msecs(source: Array[int], oldest_allowed: int) -> Array[int]:
	# คืน array ใหม่ที่มีเฉพาะ timestamp ที่ยังอยู่ในช่วงจำ
	var result: Array[int] = []
	for item in source:
		if item >= oldest_allowed:
			result.append(item)
	return result


func get_anti_repetition_grab_bonus() -> float:
	# คำนวณโบนัส Grab จากพฤติกรรมซ้ำแบบเบา ๆ และมีเพดานกัน unfair
	if not anti_repetition_memory_enabled:
		return 0.0

	var bonus := 0.0
	bonus += float(recent_dash_msecs.size()) * dash_spam_grab_bonus_per_event
	bonus += float(recent_attack_msecs.size()) * attack_spam_grab_bonus_per_event
	bonus += float(recent_deflect_msecs.size()) * deflect_spam_grab_bonus_per_event
	return clamp(bonus, 0.0, anti_repetition_max_bonus)


func start_grab() -> void:
	# เริ่ม Grab แบบ coroutine แยก เพื่อไม่ block physics process
	perform_grab_sequence()


func perform_grab_sequence() -> void:
	# กัน Grab ซ้อน
	if is_grabbing:
		return

	is_grabbing = true

	if debug_print_grab:
		print("Boss Grab started")

	# ล็อก Boss ไม่ให้ AI หลักเริ่มโจมตีซ้อนระหว่าง Grab
	boss.set("can_attack", false)
	boss.set("is_winding_up", true)
	boss.set("is_attacking", false)
	boss.set("has_hit_player", false)

	# หันหน้าเข้าหา Player ก่อนเริ่ม Grab
	face_boss_to_player()

	# แสดง hint ให้ผู้เล่นรู้ว่าต้องถอยหรือ Dash ออก
	show_boss_grab_hint()
	set_boss_color(Color(0.8, 0.2, 1.0, 1.0))

	await get_tree().create_timer(grab_windup_time).timeout

	if not can_continue_grab_sequence():
		finish_grab_sequence()
		return

	# เข้าช่วง active ของ Grab
	boss.set("is_winding_up", false)
	boss.set("is_attacking", true)
	set_boss_color(Color(1.0, 0.15, 0.35, 1.0))

	# ตรวจจับทันทีในช่วง active ถ้า Player ยังใกล้และไม่ได้ Dash อยู่ จะโดน Grab
	try_apply_grab_hit()

	await get_tree().create_timer(grab_active_time).timeout

	finish_grab_sequence()


func can_continue_grab_sequence() -> bool:
	# ถ้าระหว่าง wind-up Boss หรือ Player หายไป ให้หยุดทันที
	if not are_references_ready():
		return false

	if get_bool_value(boss, "is_dead"):
		return false

	if get_bool_value(boss, "is_posture_broken"):
		return false

	return true


func try_apply_grab_hit() -> void:
	# Grab ต้องลงโทษคนที่ยังอยู่ประชิด แต่ต้องให้ Dash หลบได้
	if not is_instance_valid(player):
		return

	var distance_to_player := get_distance_to_player()
	if distance_to_player > grab_close_range:
		if debug_print_grab:
			print("Grab missed: player out of range")
		return

	var player_is_dashing = player.get("is_dashing")
	if player_is_dashing == true:
		if debug_print_grab:
			print("Grab avoided by dash")
		return

	# Grab ไม่เช็ก Deflect เพราะออกแบบให้ Deflect ไม่ได้
	if debug_print_grab:
		print("Boss Grab hit player")

	boss.set("has_hit_player", true)
	show_grabbed_feedback()
	get_tree().call_group("game_camera", "shake", 8.0, 0.16)

	# ลด Posture แยกก่อน แล้วค่อยทำ HP damage เล็กน้อย
	if player.has_method("apply_player_posture_damage"):
		player.call("apply_player_posture_damage", grab_posture_damage)

	if player.has_method("take_damage"):
		player.call("take_damage", grab_damage)


func finish_grab_sequence() -> void:
	# คืนสถานะ Boss ให้ AI หลักกลับมาทำงานต่อ
	if is_instance_valid(boss):
		boss.set("is_winding_up", false)
		boss.set("is_attacking", false)
		boss.set("can_attack", false)
		clear_boss_grab_hint()
		set_boss_color(Color.WHITE)

	await get_tree().create_timer(grab_cooldown_bonus).timeout

	if is_instance_valid(boss) and not get_bool_value(boss, "is_dead") and not get_bool_value(boss, "is_posture_broken"):
		boss.set("can_attack", true)

	next_grab_allowed_msec = Time.get_ticks_msec() + int(grab_cooldown_bonus * 1000.0)
	is_grabbing = false

	if debug_print_grab:
		print("Boss Grab finished")


func face_boss_to_player() -> void:
	# หัน Boss เข้าหา Player เพื่อให้ Grab อ่านทิศทางถูก
	if not (boss is Node2D):
		return

	var boss_2d := boss as Node2D
	var direction := int(sign(player.global_position.x - boss_2d.global_position.x))
	if direction == 0:
		return

	boss.set("facing_direction", direction)

	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite is Sprite2D:
		(sprite as Sprite2D).flip_h = direction < 0

	var attack_hitbox = boss.get_node_or_null("AttackHitbox")
	var offset_value = boss.get("attack_hitbox_offset_x")
	if attack_hitbox is Area2D and offset_value != null:
		(attack_hitbox as Area2D).position.x = float(offset_value) * float(direction)


func show_boss_grab_hint() -> void:
	# ใช้ method ของ Boss ถ้ามี เพื่อให้แสดง hint เหนือหัวแบบเดียวกับท่าอื่น
	if boss.has_method("update_boss_hint_label"):
		boss.call("update_boss_hint_label", grab_hint_text, Color(1.0, 0.25, 0.45, 1.0))
		return

	# fallback ถ้า method ไม่มี ให้ลองเข้าถึง label โดยตรง
	var hint_label = boss.get("boss_hint_label")
	if hint_label is Label:
		(hint_label as Label).text = grab_hint_text
		(hint_label as Label).visible = true


func clear_boss_grab_hint() -> void:
	# ล้าง hint หลัง Grab จบ
	if boss.has_method("clear_attack_hint"):
		boss.call("clear_attack_hint")
		return

	var hint_label = boss.get("boss_hint_label")
	if hint_label is Label:
		(hint_label as Label).text = ""
		(hint_label as Label).visible = false


func set_boss_color(color: Color) -> void:
	# เปลี่ยนสี Boss ชั่วคราวเพื่อบอกสถานะ Grab
	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite is Sprite2D:
		(sprite as Sprite2D).modulate = color


func show_grabbed_feedback() -> void:
	# สร้างข้อความ feedback เหนือ Player เมื่อโดน Grab
	if not is_instance_valid(player):
		return

	var popup := Label.new()
	popup.text = grabbed_feedback_text
	popup.modulate = Color(1.0, 0.25, 0.45, 1.0)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 210
	popup.add_theme_font_size_override("font_size", grabbed_feedback_font_size)

	get_parent().add_child(popup)
	popup.global_position = player.global_position + Vector2(-80.0, -120.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -32.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, 0.35)
	tween.tween_property(popup, "modulate:a", 0.0, 0.35)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก Node แบบปลอดภัย เผื่อ property ไม่มี
	if not is_instance_valid(target):
		return false

	var value = target.get(property_name)
	if value == null:
		return false

	return value == true
