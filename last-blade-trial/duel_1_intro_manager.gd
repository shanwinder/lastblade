extends CanvasLayer

# =========================
# Duel1IntroManager.gd
# ขั้นกลางของ Phase 9 ก่อนทำศัตรู Duel 1 เต็มตัว
# เวอร์ชันนี้เน้นอ่านทัน: อธิบายก่อน -> เตรียมจังหวะ -> สัญญาณใหญ่ -> กดให้ทัน
# =========================

@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")

# เปิด/ปิด Duel 1 practice gate
@export var duel_intro_enabled: bool = true

# แสดงเฉพาะครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เวลาให้อ่านคำอธิบายของแต่ละท่าก่อนเริ่มจับจังหวะจริง
@export var instruction_read_time: float = 2.20

# เวลาก่อนขึ้น PARRY! หรือ DASH! ใช้เป็นช่วงอ่าน wind-up
@export var cue_windup_time: float = 1.25

# เวลาที่ให้กดหลังสัญญาณใหญ่ขึ้นจริง ยาวพอสำหรับผู้เล่นใหม่
@export var active_response_window: float = 0.90

# ระยะห่างของ beat ระหว่างช่วงเตรียมจังหวะ ช้าลงเพื่อให้อ่านทัน
@export var rhythm_beat_interval: float = 0.45

# เวลาค้างข้อความหลังทำ step สำเร็จ ก่อนเปลี่ยนไป step ถัดไป
@export var step_success_message_time: float = 1.20

# เวลาหน่วงสั้น ๆ หลังทำสำเร็จทั้งหมด ก่อนปล่อยบอส
@export var success_hold_time: float = 1.00

# เวลาค้างข้อความ feedback ตอนกดเร็วไป/ช้าไป
@export var retry_feedback_time: float = 1.10

# ข้อความหัวข้อหลัก
@export var intro_title: String = "Duel 1: อ่านจังหวะ"

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

# current_phase มีค่า briefing, windup หรือ active
var current_phase: String = "briefing"

# เวลาที่ผ่านไปใน phase ปัจจุบัน
var phase_elapsed_time: float = 0.0

# เวลาที่ผ่านไปของ beat ปัจจุบัน
var beat_elapsed_time: float = 0.0

# จำนวน beat ที่เกิดแล้วในช่วงเตรียมจังหวะ
var beat_count: int = 0

# จำนวนครั้งที่ผู้เล่นพลาดใน practice gate นี้
var miss_count: int = 0

# กันไม่ให้ข้อความ feedback ถูก phase update เขียนทับทันที
var is_showing_feedback: bool = false

# จำข้อความล่าสุด เพื่อลดการ set text ซ้ำทุกเฟรมจนดูพรึ่บพรั่บ
var last_title_text: String = ""
var last_body_text: String = ""

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
	# สร้างกล่องข้อความกลางจอแบบอ่านง่ายขึ้น
	root_control = Control.new()
	root_control.name = "Duel1IntroRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(580.0, 240.0)
	panel.position = Vector2(286.0, 126.0)
	root_control.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.035, 0.90)
	style.border_color = Color(1.0, 0.78, 0.28, 0.94)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	panel.add_theme_stylebox_override("panel", style)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 34)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	print("Duel 1 readable rhythm practice started")


func start_step(step_name: String) -> void:
	# เริ่ม step ใหม่จากช่วง briefing เพื่อให้ผู้เล่นอ่านทันก่อนฝึกจริง
	current_step = step_name
	current_phase = "briefing"
	phase_elapsed_time = 0.0
	beat_elapsed_time = 0.0
	beat_count = 0
	show_briefing_text()
	pulse_title(1.04)


func update_practice_step(delta: float) -> void:
	# ตรวจจังหวะของ step ปัจจุบัน
	phase_elapsed_time += delta
	beat_elapsed_time += delta

	if current_phase == "briefing":
		update_briefing_phase()
		return

	if current_phase == "windup":
		update_windup_phase()
		return

	if current_phase == "active":
		update_active_phase()
		return


func update_briefing_phase() -> void:
	# ช่วงอ่านคำอธิบาย ไม่ลงโทษการกดปุ่ม เพื่อไม่ให้ผู้เล่นรู้สึกถูกจับผิดเร็วเกินไป
	if phase_elapsed_time >= instruction_read_time:
		enter_windup_phase()


func enter_windup_phase() -> void:
	# เข้าช่วงเตรียมจังหวะ คล้ายเห็นบอสยกดาบก่อนฟัน
	current_phase = "windup"
	phase_elapsed_time = 0.0
	beat_elapsed_time = 0.0
	beat_count = 0
	show_windup_text()
	pulse_title(1.06)


func update_windup_phase() -> void:
	# ช่วงเตรียมจังหวะ: ให้เห็น beat แต่ยังไม่ควรกด
	if expected_action_just_pressed():
		retry_current_step("เร็วไป รอสัญญาณใหญ่ก่อน")
		return

	if beat_elapsed_time >= rhythm_beat_interval:
		beat_elapsed_time = 0.0
		beat_count += 1
		show_windup_text()
		pulse_title(1.08)

	if phase_elapsed_time >= cue_windup_time:
		enter_active_phase()


func update_active_phase() -> void:
	# ช่วงสัญญาณจริง: ต้องกดให้ทันใน active_response_window
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
	show_active_text()
	pulse_title(1.24)


func expected_action_just_pressed() -> bool:
	# ตรวจปุ่มที่ถูกต้องตาม step ปัจจุบัน
	if current_step == "parry":
		return Input.is_action_just_pressed("parry")

	if current_step == "dash":
		return Input.is_action_just_pressed("dash")

	return false


func complete_current_step() -> void:
	# เมื่อทำ step ปัจจุบันสำเร็จ ให้ค้างข้อความก่อนเปลี่ยน ไม่เปลี่ยนฉับไวเกินไป
	if current_step == "parry":
		show_feedback_text("ดีมาก", "นี่คือจังหวะ Parry ที่ถูกต้อง\nต่อไปจะฝึก Dash สำหรับท่าหนัก")
		pulse_title(1.12)
		print("Duel 1 practice: parry rhythm completed")
		await get_tree().create_timer(step_success_message_time).timeout
		start_step("dash")
		return

	if current_step == "dash":
		complete_intro()


func show_briefing_text() -> void:
	# แสดงคำอธิบายให้อ่านก่อนเข้าจังหวะจริง
	if current_step == "parry":
		set_practice_text(
			"ฝึก Parry",
			"เมื่อเห็น PARRY! ให้กด Parry\nตอนนี้อ่านก่อน ยังไม่ต้องรีบกด"
		)
		return

	if current_step == "dash":
		set_practice_text(
			"ฝึก Dash",
			"เมื่อเห็น DASH! ให้กด Dash\nท่าหนักห้าม Parry ต้องหลบด้วย Dash"
		)
		return


func show_windup_text() -> void:
	# แสดงช่วงเตรียมจังหวะ ไม่เปลี่ยนทุกเฟรม เปลี่ยนเฉพาะตอน beat เพิ่ม
	if current_step == "parry":
		set_practice_text(
			"เตรียม Parry",
			"ดูจังหวะบอสยกดาบ\n%s\nอย่าเพิ่งกด รอคำว่า PARRY!" % get_beat_text()
		)
		return

	if current_step == "dash":
		set_practice_text(
			"เตรียม Dash",
			"ท่าหนักกำลังมา\n%s\nอย่าเพิ่งกด รอคำว่า DASH!" % get_beat_text()
		)
		return


func show_active_text() -> void:
	# แสดงสัญญาณใหญ่ตอนที่กดได้จริง ข้อความสั้นและชัด
	if current_step == "parry":
		set_practice_text(parry_practice_text, "กด PARRY ตอนนี้!")
		return

	if current_step == "dash":
		set_practice_text(dash_practice_text, "กด DASH ตอนนี้!\nท่าหนักห้าม Parry")
		return


func set_practice_text(new_title: String, new_body: String) -> void:
	# ลดการ set ข้อความซ้ำ เพื่อให้กล่องไม่ดูสั่นหรือเปลี่ยนฉับไวเกินไป
	if new_title != last_title_text:
		title_label.text = new_title
		last_title_text = new_title

	if new_body != last_body_text:
		body_label.text = new_body
		last_body_text = new_body


func show_feedback_text(new_title: String, new_body: String) -> void:
	# แสดง feedback แบบค้างให้อ่านทัน
	set_practice_text(new_title, new_body)


func get_beat_text() -> String:
	# ทำ beat แบบตัวอักษรให้เห็นจังหวะก่อนสัญญาณจริง
	var beat_dots := ""
	var visible_beats: int = clamp(beat_count + 1, 1, 4)

	for i in range(visible_beats):
		beat_dots += "● "

	return beat_dots.strip_edges()


func retry_current_step(message: String) -> void:
	# ถ้ากดเร็วไปหรือช้าไป ให้ค้างข้อความก่อนเริ่ม step เดิมใหม่
	miss_count += 1
	is_showing_feedback = true
	show_feedback_text(
		message,
		"ไม่เป็นไร อ่านจังหวะแล้วลองอีกครั้ง\nพลาดแล้ว: %d ครั้ง" % miss_count
	)
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
	show_feedback_text(
		"พร้อมเข้าบอส",
		"จำไว้: อ่านจังหวะก่อน\nPARRY! = Parry / DASH! = Dash"
	)
	pulse_title(1.16)

	print("Duel 1 readable rhythm practice completed")

	await get_tree().create_timer(success_hold_time).timeout

	root_control.visible = false
	set_boss_hold(false)


func pulse_title(target_scale: float) -> void:
	# pulse ข้อความหัวข้อให้รู้สึกเป็นจังหวะ แต่ไม่ถี่จนอ่านยาก
	if title_label == null:
		return

	if pulse_tween != null:
		pulse_tween.kill()

	title_label.pivot_offset = title_label.size * 0.5
	title_label.scale = Vector2(target_scale, target_scale)
	pulse_tween = create_tween()
	pulse_tween.tween_property(title_label, "scale", Vector2.ONE, 0.18)


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
