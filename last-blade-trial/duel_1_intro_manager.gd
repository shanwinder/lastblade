extends CanvasLayer

# =========================
# Duel1IntroManager.gd
# ขั้นกลางของ Phase 9 ก่อนปล่อยบอสสู้จริง
# เวอร์ชันนี้ฝึกแบบ Freeze Frame Prompt:
# 1) อ่านคำอธิบาย
# 2) บอสเข้าสู่ท่ากำลังจะโจมตีแบบสั้น ๆ
# 3) หยุดจังหวะนั้นไว้ แล้วมีกล่องบอกให้กด Parry หรือ Dash
# 4) ผู้เล่นกดถูกหรือผิด ระบบให้ feedback แล้วไปต่อ
# =========================

@export var player_path: NodePath = NodePath("../Player")
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")

# เปิด/ปิด Duel 1 controlled practice gate
@export var duel_intro_enabled: bool = true

# แสดงเฉพาะครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เวลาให้อ่านคำอธิบายขั้นต่ำ ก่อนปุ่มต่อไปเปิดให้กด
@export var instruction_read_time: float = 3.00

# ถ้า true ช่วงอ่านคำอธิบายต้องกดปุ่มต่อไปเอง ไม่เปลี่ยนอัตโนมัติทันที
@export var require_continue_for_briefing: bool = true

# เวลาสั้น ๆ ที่ให้เห็นว่าบอสกำลังจะโจมตี ก่อนหยุดภาพเพื่อสอน
@export var attack_preview_time: float = 0.85

# เวลาที่ให้ผู้เล่นตอบสนองหลังเกมหยุดจังหวะโจมตีไว้และขึ้นกล่องเตือน
@export var active_response_window: float = 3.00

# เวลาค้างข้อความ feedback หลังผู้เล่นกดถูก/ผิด
@export var step_feedback_time: float = 1.25

# เวลาหน่วงสั้น ๆ หลังฝึกครบ ก่อนปล่อยบอสจริง
@export var success_hold_time: float = 1.25

# ถ้า true เมื่อ Parry ถูกในช่วงฝึก จะเรียก on_successful_parry() เพื่อให้ผู้เล่นเห็น feedback/focus เดิม
@export var reward_training_parry_success: bool = true

# ข้อความปุ่มต่อไป
@export var continue_button_text: String = "เข้าใจแล้ว / ต่อไป"

# เปิด/ปิดปุ่ม Skip
@export var skip_button_enabled: bool = true

# ข้อความบนปุ่ม Skip
@export var skip_button_text: String = "SKIP"

# ข้อความหัวข้อหลัก
@export var intro_title: String = "Duel 1: ฝึกอ่านท่าบอส"

# ข้อความตอนฝึก Parry
@export var parry_practice_text: String = "PARRY!"

# ข้อความตอนฝึก Dash
@export var dash_practice_text: String = "DASH!"

# ขนาดตัวอักษรหัวข้อปกติ
@export var normal_title_font_size: int = 34

# ขนาดตัวอักษรหัวข้อช่วงสัญญาณจริง ให้เด่นกว่ากล่องอื่นมาก
@export var active_signal_title_font_size: int = 58

# ขนาดตัวอักษรคำอธิบายปกติ
@export var normal_body_font_size: int = 21

# ขนาดตัวอักษรคำอธิบายตอนต้องกดจริง
@export var active_signal_body_font_size: int = 25

var player: Node = null
var boss: Node = null
var game_loop_manager: Node = null
var training_coach_manager: Node = null

var root_control: Control = null
var panel: PanelContainer = null
var title_label: Label = null
var body_label: Label = null
var progress_bar: ProgressBar = null
var continue_button: Button = null
var skip_button: Button = null

# Style ปกติของกล่องข้อความ
var normal_panel_style: StyleBoxFlat = null

# Style ตอนสัญญาณกดจริง ใช้กรอบ/พื้นหลังเด่นขึ้น
var active_panel_style: StyleBoxFlat = null

var has_started_intro: bool = false
var has_completed_intro: bool = false

# current_step มีค่า parry หรือ dash
var current_step: String = "intro"

# current_phase มีค่า briefing, attack_preview, frozen_prompt หรือ feedback
var current_phase: String = "briefing"

# เวลาที่ผ่านไปใน phase ปัจจุบัน
var phase_elapsed_time: float = 0.0

# จำนวนครั้งที่ผู้เล่นกดผิดหรือไม่ตอบสนองใน practice gate นี้
var miss_count: int = 0

# กันไม่ให้ข้อความ feedback ถูก phase update เขียนทับทันที
var is_showing_feedback: bool = false

# ปุ่มต่อไปพร้อมกดหรือยังในช่วง briefing
var can_continue_briefing: bool = false

# จำข้อความล่าสุด เพื่อลดการ set text ซ้ำทุกเฟรมจนดูพรึ่บพรั่บ
var last_title_text: String = ""
var last_body_text: String = ""

# จำว่า active visual เปิดอยู่หรือไม่ เพื่อลดการ set style ซ้ำ
var is_active_signal_visual: bool = false

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
	panel.custom_minimum_size = Vector2(600.0, 365.0)
	panel.position = Vector2(276.0, 82.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root_control.add_child(panel)

	normal_panel_style = StyleBoxFlat.new()
	normal_panel_style.bg_color = Color(0.02, 0.025, 0.035, 0.92)
	normal_panel_style.border_color = Color(1.0, 0.78, 0.28, 0.94)
	normal_panel_style.set_border_width_all(3)
	normal_panel_style.set_corner_radius_all(16)
	normal_panel_style.content_margin_left = 24.0
	normal_panel_style.content_margin_right = 24.0
	normal_panel_style.content_margin_top = 20.0
	normal_panel_style.content_margin_bottom = 20.0

	active_panel_style = StyleBoxFlat.new()
	active_panel_style.bg_color = Color(0.10, 0.045, 0.015, 0.96)
	active_panel_style.border_color = Color(1.0, 0.24, 0.10, 1.0)
	active_panel_style.set_border_width_all(6)
	active_panel_style.set_corner_radius_all(18)
	active_panel_style.content_margin_left = 24.0
	active_panel_style.content_margin_right = 24.0
	active_panel_style.content_margin_top = 20.0
	active_panel_style.content_margin_bottom = 20.0

	panel.add_theme_stylebox_override("panel", normal_panel_style)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", normal_title_font_size)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", normal_body_font_size)
	layout.add_child(body_label)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(470.0, 18.0)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	layout.add_child(progress_bar)

	continue_button = Button.new()
	continue_button.custom_minimum_size = Vector2(260.0, 54.0)
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.text = continue_button_text
	continue_button.add_theme_font_size_override("font_size", 20)
	continue_button.pressed.connect(on_continue_button_pressed)
	layout.add_child(continue_button)

	skip_button = Button.new()
	skip_button.custom_minimum_size = Vector2(160.0, 42.0)
	skip_button.focus_mode = Control.FOCUS_NONE
	skip_button.text = skip_button_text
	skip_button.add_theme_font_size_override("font_size", 17)
	skip_button.pressed.connect(on_skip_button_pressed)
	layout.add_child(skip_button)

	root_control.visible = false
	continue_button.visible = false
	skip_button.visible = false


func setup_references() -> void:
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")

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
	return is_instance_valid(player) and is_instance_valid(boss) and is_instance_valid(game_loop_manager)


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
	# เริ่ม controlled practice และแปลงบอสเป็นหุ่นฝึกชั่วคราว
	has_started_intro = true
	miss_count = 0
	prepare_boss_as_training_dummy()
	root_control.visible = true
	set_skip_button_visible(skip_button_enabled)

	start_step("parry")
	print("Duel 1 freeze-frame boss practice started")


func prepare_boss_as_training_dummy() -> void:
	# หยุด AI บอสไว้ก่อน ให้ทำหน้าที่เป็นหุ่นฝึกแบบควบคุมโดย manager นี้
	if not is_instance_valid(boss):
		return

	boss.visible = true
	set_boss_hold(true)
	clear_boss_cue()


func start_step(step_name: String) -> void:
	# เริ่ม step ใหม่จากช่วง briefing เพื่อให้ผู้เล่นเข้าใจว่าจะตอบสนองแบบไหน
	current_step = step_name
	current_phase = "briefing"
	phase_elapsed_time = 0.0
	can_continue_briefing = false
	set_active_signal_visual(false)
	clear_boss_cue()
	show_briefing_text()
	set_continue_button_visible(false)
	set_progress_percent(0.0)
	pulse_title(1.04)


func update_practice_step(delta: float) -> void:
	# ตรวจจังหวะของ step ปัจจุบัน
	phase_elapsed_time += delta

	if current_phase == "briefing":
		update_briefing_phase()
		return

	if current_phase == "attack_preview":
		update_attack_preview_phase()
		return

	if current_phase == "frozen_prompt":
		update_frozen_prompt_phase()
		return


func update_briefing_phase() -> void:
	# ช่วงอ่านคำอธิบาย ให้ progress bar เติมก่อน แล้วค่อยเปิดปุ่มต่อไป
	var progress_percent: float = clamp(phase_elapsed_time / max(instruction_read_time, 0.01), 0.0, 1.0)
	set_progress_percent(progress_percent)

	if phase_elapsed_time < instruction_read_time:
		return

	can_continue_briefing = true
	set_continue_button_visible(true)

	if not require_continue_for_briefing:
		enter_attack_preview_phase()


func enter_attack_preview_phase() -> void:
	# บอสเข้าสู่ท่ากำลังจะโจมตี แต่ยังไม่ขึ้นคำตอบทันที
	# จุดประสงค์คือให้ผู้เล่นเห็นว่า "ตอนนี้บอสกำลังจะตี" ก่อนเกมหยุดเตือน
	current_phase = "attack_preview"
	phase_elapsed_time = 0.0
	can_continue_briefing = false
	set_continue_button_visible(false)
	set_active_signal_visual(false)
	set_progress_percent(0.0)
	show_attack_preview_text()
	show_boss_windup_preview()
	pulse_title(1.08)


func update_attack_preview_phase() -> void:
	# ช่วงเห็นท่าบอสกำลังจะโจมตี ก่อน freeze frame prompt
	var progress_percent: float = clamp(phase_elapsed_time / max(attack_preview_time, 0.01), 0.0, 1.0)
	set_progress_percent(progress_percent)

	if phase_elapsed_time >= attack_preview_time:
		enter_frozen_prompt_phase()


func enter_frozen_prompt_phase() -> void:
	# นี่คือจังหวะ freeze frame: บอสหยุดนิ่งตอนกำลังจะโจมตี แล้วกล่องเตือนให้กด Parry/Dash
	current_phase = "frozen_prompt"
	phase_elapsed_time = 0.0
	set_active_signal_visual(true)
	set_progress_percent(1.0)
	show_frozen_prompt_text()
	show_boss_cue_for_current_step()
	pulse_title(1.28)


func update_frozen_prompt_phase() -> void:
	# ระหว่างหยุดจังหวะโจมตี ให้รับทั้งคำตอบที่ถูกและผิด แล้วค่อยไปต่อ
	set_progress_percent(1.0 - clamp(phase_elapsed_time / max(active_response_window, 0.01), 0.0, 1.0))

	if expected_action_just_pressed():
		finish_current_step(true, "")
		return

	if wrong_action_just_pressed():
		finish_current_step(false, get_wrong_action_message())
		return

	if phase_elapsed_time >= active_response_window:
		finish_current_step(false, "ไม่ได้กดตอบสนอง")


func expected_action_just_pressed() -> bool:
	# ตรวจปุ่มที่ถูกต้องตาม step ปัจจุบัน
	if current_step == "parry":
		return Input.is_action_just_pressed("parry")

	if current_step == "dash":
		return Input.is_action_just_pressed("dash")

	return false


func wrong_action_just_pressed() -> bool:
	# ถ้ากดปุ่มต่อสู้อื่นที่ไม่ใช่คำตอบที่ถูก ให้ถือว่าผิด แต่ยังไปต่อเพื่อให้ผู้เล่นเรียนรู้จากผลลัพธ์
	if current_step == "parry":
		return Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("attack")

	if current_step == "dash":
		return Input.is_action_just_pressed("parry") or Input.is_action_just_pressed("attack")

	return false


func get_wrong_action_message() -> String:
	# ข้อความสั้น ๆ ตาม step ที่กดผิด
	if current_step == "parry":
		return "ท่านี้ควร Parry ไม่ใช่ Dash/Attack"

	if current_step == "dash":
		return "ท่านี้ควร Dash ไม่ใช่ Parry/Attack"

	return "กดผิดปุ่ม"


func finish_current_step(was_successful: bool, fail_message: String) -> void:
	# เมื่อผู้เล่นกดถูกหรือผิด ให้แสดงผล แล้วไป step ถัดไป ไม่บังคับวนซ้ำ
	if is_showing_feedback:
		return

	current_phase = "feedback"
	is_showing_feedback = true
	set_active_signal_visual(false)
	set_continue_button_visible(false)
	set_progress_percent(1.0 if was_successful else 0.0)
	play_controlled_attack_visual()
	clear_boss_cue()

	if was_successful:
		show_success_feedback()
	else:
		miss_count += 1
		show_fail_feedback(fail_message)

	pulse_title(1.10)

	await get_tree().create_timer(step_feedback_time).timeout

	if has_completed_intro:
		return

	is_showing_feedback = false

	if current_step == "parry":
		start_step("dash")
		return

	if current_step == "dash":
		complete_intro()


func show_success_feedback() -> void:
	# แสดงผลเมื่อผู้เล่นตอบสนองถูก
	if current_step == "parry":
		set_practice_text(
			"สำเร็จ",
			"Parry ถูกจังหวะ\nตอนบอสหยุดเตือนด้วย PARRY! ให้กด Parry"
		)

		# ให้ feedback/focus เดิมของ Player เพื่อให้รู้สึกว่า Parry สำเร็จจริง
		if reward_training_parry_success and is_instance_valid(player) and player.has_method("on_successful_parry"):
			player.on_successful_parry()
		return

	if current_step == "dash":
		set_practice_text(
			"สำเร็จ",
			"Dash ถูกจังหวะ\nตอนบอสหยุดเตือนด้วย DASH! ให้ Dash ออก"
		)
		return


func show_fail_feedback(fail_message: String) -> void:
	# แสดงผลเมื่อผู้เล่นกดผิดหรือไม่ตอบสนอง แต่ยังให้เกมดำเนินต่อ
	if fail_message == "":
		fail_message = "ลองจำสัญญาณนี้ไว้สำหรับรอบจริง"

	set_practice_text(
		"ยังไม่ถูก",
		"%s\nจังหวะนี้เกมหยุดเตือนแล้ว ต้องเลือกปุ่มให้ถูก\nพลาดแล้ว: %d ครั้ง" % [fail_message, miss_count]
	)


func show_briefing_text() -> void:
	# แสดงคำอธิบายก่อนเริ่ม sequence บอสกำลังจะโจมตี -> freeze prompt
	if current_step == "parry":
		set_practice_text(
			"ฝึก Parry",
			"ต่อไปบอสจะทำท่าจะโจมตี\nเกมจะหยุดจังหวะนั้นไว้ แล้วบอกให้กด Parry"
		)
		return

	if current_step == "dash":
		set_practice_text(
			"ฝึก Dash",
			"ต่อไปบอสจะทำท่าหนัก\nเกมจะหยุดจังหวะนั้นไว้ แล้วบอกให้กด Dash"
		)
		return


func show_attack_preview_text() -> void:
	# ข้อความตอนบอสเริ่มทำท่าก่อน freeze frame
	if current_step == "parry":
		set_practice_text(
			"บอสกำลังจะโจมตี",
			"ดูท่าทางบอสก่อน\nอีกสักครู่เกมจะหยุดจังหวะสำคัญเพื่อบอกปุ่ม"
		)
		return

	if current_step == "dash":
		set_practice_text(
			"บอสกำลังจะใช้ท่าหนัก",
			"ดูท่าทางบอสก่อน\nอีกสักครู่เกมจะหยุดจังหวะสำคัญเพื่อบอกปุ่ม"
		)
		return


func show_frozen_prompt_text() -> void:
	# กล่องสอนตอน freeze frame ที่ผู้เล่นต้องตอบสนอง
	if current_step == "parry":
		set_practice_text(
			"⏸  %s  ⏸" % parry_practice_text,
			"บอสถูกหยุดไว้ตรงจังหวะกำลังโจมตี\nกด PARRY ตอนนี้"
		)
		return

	if current_step == "dash":
		set_practice_text(
			"⏸  %s  ⏸" % dash_practice_text,
			"บอสถูกหยุดไว้ตรงจังหวะท่าหนัก\nกด DASH ตอนนี้ ห้าม Parry"
		)
		return


func show_boss_windup_preview() -> void:
	# ทำให้บอสเหมือนกำลัง wind-up ก่อน freeze prompt
	if current_step == "parry":
		show_boss_cue("...", Color.YELLOW)
		set_boss_sprite_color(Color.YELLOW)
		return

	if current_step == "dash":
		show_boss_cue("...", Color(1.0, 0.35, 0.0, 1.0))
		set_boss_sprite_color(Color(1.0, 0.35, 0.0, 1.0))
		return


func show_boss_cue_for_current_step() -> void:
	# ใช้ label เหนือหัวบอสจริงในจังหวะ freeze frame เพื่อเชื่อมสัญญาณกับตัวศัตรู
	if current_step == "parry":
		show_boss_cue(parry_practice_text, Color(0.35, 0.95, 1.0, 1.0))
		set_boss_sprite_color(Color(0.35, 0.95, 1.0, 1.0))
		return

	if current_step == "dash":
		show_boss_cue(dash_practice_text, Color(1.0, 0.35, 0.0, 1.0))
		set_boss_sprite_color(Color(1.0, 0.35, 0.0, 1.0))
		return


func show_boss_cue(text: String, color: Color) -> void:
	# เรียกใช้ระบบ hint เหนือหัวบอสเดิม ถ้ามี
	if is_instance_valid(boss) and boss.has_method("update_boss_hint_label"):
		boss.update_boss_hint_label(text, color)


func clear_boss_cue() -> void:
	# ล้าง hint และคืนสีบอสหลังจบ step
	if is_instance_valid(boss) and boss.has_method("clear_attack_hint"):
		boss.clear_attack_hint()

	set_boss_sprite_color(Color.WHITE)


func set_boss_sprite_color(new_color: Color) -> void:
	# เปลี่ยนสีบอสจริงชั่วคราวเพื่อบอกประเภทท่า
	if not is_instance_valid(boss):
		return

	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.modulate = new_color


func play_controlled_attack_visual() -> void:
	# เล่น slash placeholder ของบอสตอนผู้เล่นตอบสนอง เพื่อให้รู้สึกว่าหลังตอบแล้วท่าถูกปล่อยออกจริง
	if is_instance_valid(boss) and boss.has_method("show_boss_slash_effect"):
		boss.show_boss_slash_effect()


func set_practice_text(new_title: String, new_body: String) -> void:
	# ลดการ set ข้อความซ้ำ เพื่อให้กล่องไม่ดูสั่นหรือเปลี่ยนฉับไวเกินไป
	if new_title != last_title_text:
		title_label.text = new_title
		last_title_text = new_title

	if new_body != last_body_text:
		body_label.text = new_body
		last_body_text = new_body


func complete_intro() -> void:
	if has_completed_intro:
		return

	has_completed_intro = true
	has_completed_intro_this_session = true
	current_phase = "feedback"
	is_showing_feedback = true
	set_active_signal_visual(false)
	set_continue_button_visible(false)
	set_skip_button_visible(false)
	set_progress_percent(1.0)
	clear_boss_cue()
	set_practice_text(
		"พร้อมเข้าบอสจริง",
		"จากนี้บอสจะไม่หยุดเตือนแล้ว\nอ่านท่าก่อนโจมตี และตอบสนองให้ทันในเวลาจริง"
	)
	pulse_title(1.16)

	print("Duel 1 freeze-frame boss practice completed")

	await get_tree().create_timer(success_hold_time).timeout

	if is_instance_valid(root_control):
		root_control.visible = false
	set_boss_hold(false)


func on_skip_button_pressed() -> void:
	# ข้าม Duel Practice แล้วปล่อยบอสเริ่มสู้ทันที
	if has_completed_intro:
		return

	print("Duel 1 freeze-frame boss practice skipped")
	has_completed_intro = true
	has_completed_intro_this_session = true
	current_phase = "feedback"
	is_showing_feedback = false
	set_active_signal_visual(false)
	set_continue_button_visible(false)
	set_skip_button_visible(false)
	set_progress_percent(1.0)
	clear_boss_cue()

	if is_instance_valid(root_control):
		root_control.visible = false

	set_boss_hold(false)


func set_progress_percent(percent: float) -> void:
	# Progress bar อยู่ในกล่องเดียวกัน ใช้บอกระยะอ่าน/ระยะตอบสนอง
	if progress_bar == null:
		return

	progress_bar.value = clamp(percent, 0.0, 1.0) * 100.0


func set_continue_button_visible(is_visible: bool) -> void:
	# ปุ่มต่อไปใช้เฉพาะช่วงที่ต้องการให้ผู้เล่นอ่านก่อน
	if continue_button == null:
		return

	continue_button.visible = is_visible
	continue_button.disabled = not is_visible


func set_skip_button_visible(is_visible: bool) -> void:
	# ปุ่ม Skip ใช้ข้าม Duel Practice ทั้งชุด
	if skip_button == null:
		return

	skip_button.visible = is_visible
	skip_button.disabled = not is_visible


func on_continue_button_pressed() -> void:
	# ผู้เล่นอ่านแล้วค่อยกดต่อไป เพื่อไม่ให้กล่องเปลี่ยนเร็วเกินไป
	if current_phase != "briefing":
		return

	if not can_continue_briefing:
		return

	enter_attack_preview_phase()


func set_active_signal_visual(is_active: bool) -> void:
	# ปรับภาพรวมของกล่องให้สัญญาณ PARRY!/DASH! เด่นกว่าช่วงอื่น
	if panel == null or title_label == null or body_label == null:
		return

	if is_active_signal_visual == is_active:
		return

	is_active_signal_visual = is_active

	if is_active:
		panel.add_theme_stylebox_override("panel", active_panel_style)
		title_label.add_theme_font_size_override("font_size", active_signal_title_font_size)
		body_label.add_theme_font_size_override("font_size", active_signal_body_font_size)
	else:
		panel.add_theme_stylebox_override("panel", normal_panel_style)
		title_label.add_theme_font_size_override("font_size", normal_title_font_size)
		body_label.add_theme_font_size_override("font_size", normal_body_font_size)


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
	# หยุดหรือปล่อยบอส เพื่อให้ช่วงฝึกกับหุ่นควบคุมได้จริง
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(not should_hold)

	var attack_id = boss.get("attack_sequence_id")
	if attack_id != null:
		boss.set("attack_sequence_id", int(attack_id) + 1)

	boss.set("can_attack", not should_hold)
	boss.set("is_winding_up", false)
	boss.set("is_attacking", false)
	boss.set("is_staggered", false)
	boss.set("is_knocked_back", false)
	boss.set("knockback_velocity", Vector2.ZERO)
	boss.set("velocity", Vector2.ZERO)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)

	if not should_hold:
		boss.visible = true
		boss.set("can_attack", true)
