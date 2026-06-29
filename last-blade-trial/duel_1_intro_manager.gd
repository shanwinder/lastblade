extends CanvasLayer

# =========================
# Duel1IntroManager.gd
# ขั้นกลางของ Phase 9 ก่อนทำศัตรู Duel 1 เต็มตัว
# เวอร์ชันนี้ฝึกจังหวะแบบมีสัญญาณ: เตรียมตัว -> สัญญาณใหญ่ -> กดให้ทัน
# =========================

@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")

# เปิด/ปิด Duel 1 practice gate
@export var duel_intro_enabled: bool = true

# แสดงเฉพาะครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เวลาก่อนขึ้น PARRY! หรือ DASH! ใช้เป็นช่วงอ่าน wind-up
@export var cue_windup_time: float = 0.85

# เวลาที่ให้กดหลังสัญญาณใหญ่ขึ้นจริง
@export var active_response_window: float = 0.55

# ระยะห่างของ beat ระหว่างช่วงเตรียมจังหวะ
@export var rhythm_beat_interval: float = 0.28

# เวลาหน่วงสั้น ๆ หลังทำสำเร็จ ก่อนปล่อยบอส
@export var success_hold_time: float = 0.65

# เวลาค้างข้อความ feedback ตอนกดเร็วไป/ช้าไป
@export var retry_feedback_time: float = 0.55

# ข้อความหัวข้อหลัก
@export var intro_title: String = "Duel 1: อ่านจังหวะ"

# ข้อความอธิบายก่อนฝึก
@export var intro_body: String = "ดูจังหวะเตรียมตัว แล้วกดตอนสัญญาณใหญ่ขึ้น"

# ข้อความตอนฝึก Parry
@export var parry_practice_text: String = "PARRY!"

# ข้อความตอนฝึก Dash
@export var dash_practice_text: String = "DASH!"

var boss: Node = null
var game_loop_manager: Node = null
var training_coach_manager: Node = null

var root_control: Control = null
var panel: PanelContainer = null
var title_label: Label = null
var body_label: Label = null

var has_started_intro: bool = false
var has_completed_intro: bool = false

# current_step มีค่า parry หรือ dash
var current_step: String = "intro"

# current_phase มีค่า windup หรือ active
var current_phase: String = "windup"

# เวลาที่ผ่านไปใน phase ปัจจุบัน
var phase_elapsed_time: float = 0.0

# เวลาที่ผ่านไปของ beat ปัจจุบัน
var beat_elapsed_time: float = 0.0

# จำนวน beat ที่เกิดแล้วในช่วงเตรียมจังหวะ
var beat_count: int = 0

# จำนวนครั้งที่ผู้เล่นพลาดใน practice gate นี้
var miss_count: int = 0

# กันไม่ให้ข้อความ feedback ถูก update_practice_text เขียนทับทันที
var is_showing_feedback: bool = false

# tween สำหรับ pulse ข้อความ
var pulse_tween: Tween = null

static var has_completed_intro_this_session: bool = false


func _ready() -> void:
	# อยู่เหนือ TrainingCoach แต่ต่ำกว่า GameLoopManager
	layer = 36
	create_ui()
	setup_references.call_deferred()


func _physics_process(delta: float) -> void:
	if not duel_intro_enabled:
		return

	if show_only_once_per_session and has_completed_intro_this_session:
		return

	if not are_references_ready():
		setup_references()
		return

	if has_completed_intro:
		return

	if is_showing_feedback:
		return

	if not is_game_playing():
		return

	if not is_training_ready():
		return

	if not has_started_intro:
		start_intro()
		return

	update_practice_step(delta)


func create_ui() -> void:
	# สร้างกล่องข้อความกลางจอแบบเบา ๆ
	root_control = Control.new()
	root_control.name = "Duel1IntroRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520.0, 210.0)
	panel.position = Vector2(316.0, 138.0)
	root_control.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.035, 0.88)
	style.border_color = Color(1.0, 0.78, 0.28, 0.94)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 18.0
	style.content_margin_bottom = 18.0
	panel.add_theme_stylebox_override("panel", style)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 34)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.add_theme_font_size_override("font_size", 21)
	layout.add_child(body_label)

	root_control.visible = false


func setup_references() -> void:
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")

	training_coach_manager = get_node_or_null(training_coach_manager_path)
	if training_coach_manager == null and get_parent() != null:
		training_coach_manager = get_parent().get_node_or_null("TrainingCoachManager")


func are_references_ready() -> bool:
	return is_instance_valid(boss) and is_instance_valid(game_loop_manager)


func is_game_playing() -> bool:
	var state = game_loop_manager.get("game_state")
	return state == "playing"


func is_training_ready() -> bool:
	# ถ้าไม่มี TrainingCoach ให้ถือว่าพร้อม
	if not is_instance_valid(training_coach_manager):
		return true

	# ถ้า TrainingCoach ปิดไว้ ให้ถือว่าพร้อม
	var enabled = training_coach_manager.get("training_coach_enabled")
	if enabled == false:
		return true

	# ถ้า tutorial กำลังทำงานอยู่ ให้รอก่อน
	var active = training_coach_manager.get("is_training_active")
	if active == true:
		return false

	# ถ้า tutorial จบแล้ว ให้เริ่ม practice gate ได้
	var completed = training_coach_manager.get("is_training_completed")
	return completed == true


func start_intro() -> void:
	# เริ่ม practice gate และหยุดบอสไว้ก่อน
	has_started_intro = true
	miss_count = 0
	set_boss_hold(true)
	root_control.visible = true

	start_step("parry")
	print("Duel 1 rhythmic practice started")


func start_step(step_name: String) -> void:
	# เริ่ม step ใหม่ โดยเริ่มจากช่วง wind-up เพื่อให้มีจังหวะก่อนกดจริง
	current_step = step_name
	current_phase = "windup"
	phase_elapsed_time = 0.0
	beat_elapsed_time = 0.0
	beat_count = 0
	update_practice_text()
	pulse_title(1.05)


func update_practice_step(delta: float) -> void:
	# ตรวจจังหวะของ step ปัจจุบัน
	phase_elapsed_time += delta
	beat_elapsed_time += delta

	if current_phase == "windup":
		update_windup_phase()
		return

	if current_phase == "active":
		update_active_phase()
		return


func update_windup_phase() -> void:
	# ช่วงเตรียมจังหวะ: ให้เห็น beat แต่ยังไม่ควรกด
	if beat_elapsed_time >= rhythm_beat_interval:
		beat_elapsed_time = 0.0
		beat_count += 1
		pulse_title(1.08)

	update_practice_text()

	if expected_action_just_pressed():
		retry_current_step("เร็วไป รอสัญญาณใหญ่ก่อน")
		return

	if phase_elapsed_time >= cue_windup_time:
		enter_active_phase()


func update_active_phase() -> void:
	# ช่วงสัญญาณจริง: ต้องกดให้ทันใน active_response_window
	update_practice_text()

	if expected_action_just_pressed():
		complete_current_step()
		return

	if phase_elapsed_time >= active_response_window:
		retry_current_step("ช้าไป ลองอ่านจังหวะใหม่")


func enter_active_phase() -> void:
	# เข้าช่วงกดจริง คล้ายจังหวะ hitbox เปิดของบอส
	current_phase = "active"
	phase_elapsed_time = 0.0
	beat_elapsed_time = 0.0
	pulse_title(1.22)
	update_practice_text()


func expected_action_just_pressed() -> bool:
	# ตรวจปุ่มที่ถูกต้องตาม step ปัจจุบัน
	if current_step == "parry":
		return Input.is_action_just_pressed("parry")

	if current_step == "dash":
		return Input.is_action_just_pressed("dash")

	return false


func complete_current_step() -> void:
	# เมื่อทำ step ปัจจุบันสำเร็จ ให้ไป step ถัดไปหรือจบ practice
	if current_step == "parry":
		title_label.text = "ดีมาก"
		body_label.text = "ต่อไปดูจังหวะ DASH!\nท่าหนักต้อง Dash ไม่ใช่ Parry"
		pulse_title(1.14)
		start_step.call_deferred("dash")
		print("Duel 1 practice: parry rhythm completed")
		return

	if current_step == "dash":
		complete_intro()


func update_practice_text() -> void:
	# อัปเดตข้อความตาม step และ phase เพื่อให้มีจังหวะ ไม่ใช่แค่นับถอยหลัง
	if current_step == "parry":
		if current_phase == "windup":
			title_label.text = "เตรียม Parry"
			body_label.text = "%s\nจังหวะ: %s\nอย่าเพิ่งกด" % [intro_body, get_beat_text()]
		else:
			title_label.text = parry_practice_text
			body_label.text = "กด PARRY ตอนนี้!\nหน้าต่างกด: %.1f" % max(active_response_window - phase_elapsed_time, 0.0)
		return

	if current_step == "dash":
		if current_phase == "windup":
			title_label.text = "เตรียม Dash"
			body_label.text = "ท่าหนักกำลังมา\nจังหวะ: %s\nอย่าเพิ่งกด" % get_beat_text()
		else:
			title_label.text = dash_practice_text
			body_label.text = "กด DASH ตอนนี้!\nท่าหนักห้าม Parry\nหน้าต่างกด: %.1f" % max(active_response_window - phase_elapsed_time, 0.0)
		return


func get_beat_text() -> String:
	# ทำ beat แบบตัวอักษรให้เห็นจังหวะก่อนสัญญาณจริง
	var beat_dots := ""
	var visible_beats: int = clamp(beat_count + 1, 1, 4)

	for i in range(visible_beats):
		beat_dots += "●"

	return beat_dots


func retry_current_step(message: String) -> void:
	# ถ้ากดเร็วไปหรือช้าไป ให้ทำ step เดิมซ้ำแบบไม่ลงโทษหนัก
	miss_count += 1
	is_showing_feedback = true
	title_label.text = message
	body_label.text = "ไม่เป็นไร ดูจังหวะแล้วลองอีกครั้ง\nพลาดแล้ว: %d ครั้ง" % miss_count
	pulse_title(1.10)
	print("Duel 1 practice retry:", message, "miss count =", miss_count)

	await get_tree().create_timer(retry_feedback_time).timeout

	is_showing_feedback = false
	start_step(current_step)


func complete_intro() -> void:
	if has_completed_intro:
		return

	has_completed_intro = true
	has_completed_intro_this_session = true
	title_label.text = "พร้อมเข้าบอส"
	body_label.text = "จำไว้: อ่านจังหวะก่อน\nPARRY! = Parry / DASH! = Dash"
	pulse_title(1.16)

	print("Duel 1 rhythmic practice completed")

	await get_tree().create_timer(success_hold_time).timeout

	root_control.visible = false
	set_boss_hold(false)


func pulse_title(target_scale: float) -> void:
	# pulse ข้อความหัวข้อให้รู้สึกเป็นจังหวะ แทนการนับเวลาลวก ๆ
	if title_label == null:
		return

	if pulse_tween != null:
		pulse_tween.kill()

	title_label.pivot_offset = title_label.size * 0.5
	title_label.scale = Vector2(target_scale, target_scale)
	pulse_tween = create_tween()
	pulse_tween.tween_property(title_label, "scale", Vector2.ONE, 0.16)


func set_boss_hold(should_hold: bool) -> void:
	# หยุดหรือปล่อยบอส เพื่อให้ผู้เล่นฝึกก่อน
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(not should_hold)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)

	if not should_hold:
		boss.set("can_attack", true)
		boss.set("is_winding_up", false)
		boss.set("is_attacking", false)
