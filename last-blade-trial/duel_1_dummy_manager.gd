extends CanvasLayer

# =========================
# Duel1DummyManager.gd
# ชื่อไฟล์เดิมยังคงไว้เพื่อไม่ต้องรื้อ scene หลัก
# พฤติกรรมจริงตอนนี้คือ Duel 1 Guided Training กับ BossBrokenMaster ตัวจริง
# ระหว่าง Duel 1 บอสจะสู้แบบจำกัด pattern
# เมื่อบอสกำลัง wind-up จะหยุดก่อน hitbox เปิด แล้วกล่องจะบอกให้ผู้เล่นกด Parry หรือ Dash
# เมื่อฝึกครบแล้วจะจัดตำแหน่งใหม่เหมือนเริ่มซีนบอสจริง แล้วค่อยปล่อยบอสเต็มรูปแบบ
# =========================

@export var player_path: NodePath = NodePath("../Player")
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")
@export var duel_intro_manager_path: NodePath = NodePath("../Duel1IntroManager")

# เปิด/ปิดระบบ Duel 1 ฝึกกับบอสจริง
@export var boss_training_enabled: bool = true

# แสดงแค่ครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เปิด/ปิดปุ่ม Skip สำหรับข้ามช่วงฝึกกับบอสจริง
@export var skip_button_enabled: bool = true

# ข้อความบนปุ่ม Skip
@export var skip_button_text: String = "SKIP"

# ถ้า true จะสลับท่าฝึกระหว่าง normal_slash กับ heavy_slash เพื่อสอนทั้ง Parry และ Dash ใน Duel 1
@export var rotate_parry_dash_training_patterns: bool = true

# ถ้าไม่สลับ pattern จะใช้ท่านี้ตลอด Duel 1
@export_enum("normal_slash", "quick_slash", "delayed_slash", "heavy_slash") var training_forced_boss_pattern: String = "normal_slash"

# ผู้เล่นต้องทำดาเมจใส่บอสจริงเท่านี้ จึงถือว่าผ่านช่วงฝึก
@export var required_training_damage: int = 30

# ถ้า true หลังฝึกเสร็จจะรีเซ็ต HP/Posture ของบอสก่อนเข้าของจริง
@export var reset_boss_after_training: bool = true

# ถ้า true หลังจบ Duel 1 จะข้าม Duel1IntroManager และปล่อยบอสจริงเลย
# เพราะคำสอน Parry/Dash ถูกย้ายเข้ามาอยู่ใน Duel 1 แล้ว
@export var start_real_boss_after_duel_1: bool = true

# เปิด/ปิดระบบหยุดบอสกลาง wind-up เพื่อขึ้นกล่องเตือน Parry/Dash
@export var freeze_prompt_enabled: bool = true

# เวลาที่ให้ผู้เล่นตอบสนองตอนบอสถูกหยุดไว้ก่อน hitbox เปิด
@export var freeze_prompt_response_time: float = 3.0

# เวลาค้าง feedback หลังผู้เล่นกดถูก/ผิดใน freeze prompt
@export var freeze_prompt_feedback_time: float = 0.85

# ถ้า true เมื่อ Parry ถูกใน Duel 1 จะเรียก on_successful_parry() เพื่อให้ได้ feedback/focus เดิม
@export var reward_parry_success_during_duel_1: bool = true

# เวลาค้างข้อความหลังผ่านหรือ skip ก่อนจัดตำแหน่งเข้าบอสจริง
@export var training_clear_message_time: float = 0.85

# ถ้า true หลัง Duel 1 จะย้าย Player/Boss กลับจุดเริ่มต้นของไฟต์จริง
@export var reset_positions_after_duel_1: bool = true

# ตำแหน่งเริ่มต้น Player ตอนเข้าไฟต์บอสจริง อ้างอิงตำแหน่งเดิมใน main scene
@export var player_real_fight_start_position: Vector2 = Vector2(576.0, 324.0)

# ตำแหน่งเริ่มต้น Boss ตอนเข้าไฟต์บอสจริง อ้างอิงตำแหน่งเดิมใน main scene
@export var boss_real_fight_start_position: Vector2 = Vector2(780.0, 324.0)

# เวลาค้างสัญญาณก่อนปล่อยบอสจริง
@export var real_boss_start_signal_time: float = 1.35

# ข้อความหัวข้อก่อนเริ่มบอสจริง
@export var real_boss_start_title: String = "BOSS FIGHT"

# ข้อความรายละเอียดก่อนเริ่มบอสจริง
@export var real_boss_start_body: String = "เริ่มสู้กับบอสจริง"

# ขนาดตัวอักษรหัวข้อ
@export var title_font_size: int = 24

# ขนาดตัวอักษรรายละเอียด
@export var body_font_size: int = 17

var player: Node = null
var boss: Node = null
var game_loop_manager: Node = null
var training_coach_manager: Node = null
var duel_intro_manager: Node = null

var root_control: Control = null
var panel: PanelContainer = null
var title_label: Label = null
var body_label: Label = null
var progress_bar: ProgressBar = null
var skip_button: Button = null

var has_started_training_boss: bool = false
var is_training_boss_active: bool = false
var is_training_boss_completed: bool = false

# HP บอสตอนเริ่มฝึก ใช้คำนวณว่าผู้เล่นทำดาเมจไปเท่าไร
var training_start_boss_hp: int = 0

# เก็บค่า debug pattern เดิมของบอสไว้ เพื่อคืนค่าหลังฝึกเสร็จ
var has_saved_original_boss_debug: bool = false
var original_debug_force_attack_pattern_enabled: bool = false
var original_debug_forced_attack_pattern: String = "random"

# ใช้สลับท่า Duel 1 ระหว่าง Parry/Dash
var current_training_pattern_index: int = 0

# สถานะ freeze prompt ระหว่าง Duel 1
var is_freeze_prompt_active: bool = false
var is_freeze_feedback_active: bool = false
var freeze_prompt_elapsed_time: float = 0.0
var freeze_prompt_pattern_name: String = "normal_slash"
var last_frozen_attack_sequence_id: int = -1

static var has_completed_training_boss_this_session: bool = false


func _ready() -> void:
	# อยู่เหนือ TouchControls แต่ต่ำกว่า TrainingCoach และ DuelIntro
	layer = 34
	create_ui()
	setup_references.call_deferred()


func _physics_process(delta: float) -> void:
	if not boss_training_enabled:
		finish_without_boss_training_if_needed()
		return

	if show_only_once_per_session and has_completed_training_boss_this_session:
		finish_without_boss_training_if_needed()
		return

	if not are_references_ready():
		setup_references()
		return

	# ปิด DuelIntro ไว้ เพราะคำสอน Parry/Dash อยู่ใน Duel 1 แล้ว
	if start_real_boss_after_duel_1:
		disable_duel_intro_if_available()
	elif not is_training_boss_completed:
		disable_duel_intro_if_available()

	if is_freeze_prompt_active:
		update_freeze_prompt(delta)
		return

	if is_freeze_feedback_active:
		return

	if is_training_boss_active:
		watch_boss_windup_for_freeze_prompt()
		update_training_boss_progress()
		return

	if has_started_training_boss or is_training_boss_completed:
		return

	if not is_game_playing():
		return

	if not is_training_ready():
		return

	start_training_boss()


func create_ui() -> void:
	# สร้างกล่องสถานะ Duel 1 แบบเล็ก ไม่รบกวนการเล่น
	root_control = Control.new()
	root_control.name = "Duel1BossTrainingRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500.0, 174.0)
	panel.position = Vector2(326.0, 24.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root_control.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.035, 0.88)
	style.border_color = Color(0.95, 0.75, 0.25, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 5)
	panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", title_font_size)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", body_font_size)
	layout.add_child(body_label)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(390.0, 14.0)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	layout.add_child(progress_bar)

	skip_button = Button.new()
	skip_button.custom_minimum_size = Vector2(130.0, 36.0)
	skip_button.focus_mode = Control.FOCUS_NONE
	skip_button.text = skip_button_text
	skip_button.add_theme_font_size_override("font_size", 16)
	skip_button.pressed.connect(on_skip_button_pressed)
	layout.add_child(skip_button)

	root_control.visible = false


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

	duel_intro_manager = get_node_or_null(duel_intro_manager_path)
	if duel_intro_manager == null and get_parent() != null:
		duel_intro_manager = get_parent().get_node_or_null("Duel1IntroManager")


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

	# ถ้า TrainingCoach กำลังทำงานอยู่ ให้รอก่อน
	var active = training_coach_manager.get("is_training_active")
	if active == true:
		return false

	var completed = training_coach_manager.get("is_training_completed")
	return completed == true


func start_training_boss() -> void:
	# เริ่ม Duel 1 หลัง Training Coach จบ
	has_started_training_boss = true
	is_training_boss_active = true
	is_training_boss_completed = false
	is_freeze_prompt_active = false
	is_freeze_feedback_active = false
	freeze_prompt_elapsed_time = 0.0
	last_frozen_attack_sequence_id = -1
	current_training_pattern_index = 0

	root_control.visible = true
	set_skip_button_visible(skip_button_enabled)

	prepare_boss_for_limited_training()
	apply_current_training_pattern_to_boss()

	title_label.text = "Duel 1: ฝึกกับบอสจริง"
	body_label.text = "บอสจะโจมตีแบบจำกัด\nเมื่อบอสกำลังจะตี เกมจะหยุดและบอก Parry/Dash"
	set_progress_percent(0.0)

	print("Duel 1 guided boss training started")


func prepare_boss_for_limited_training() -> void:
	# ให้เห็นบอสตัวจริง และจำกัด pattern เอาไว้ก่อน
	if not is_instance_valid(boss):
		return

	boss.visible = true
	save_original_boss_debug_settings()
	reset_boss_combat_state_for_training()
	training_start_boss_hp = get_int_value(boss, "current_hp", get_int_value(boss, "max_hp", 300))
	boss.set_physics_process(true)
	boss.set("can_attack", true)


func save_original_boss_debug_settings() -> void:
	# เก็บค่าเดิมครั้งเดียว เพื่อคืนค่าหลังจบการฝึก
	if has_saved_original_boss_debug:
		return

	var original_force = boss.get("debug_force_attack_pattern_enabled")
	if original_force != null:
		original_debug_force_attack_pattern_enabled = bool(original_force)

	var original_pattern = boss.get("debug_forced_attack_pattern")
	if original_pattern != null:
		original_debug_forced_attack_pattern = str(original_pattern)

	has_saved_original_boss_debug = true


func reset_boss_combat_state_for_training() -> void:
	# ล้างสถานะโจมตีค้างก่อนเข้าโหมดฝึก เพื่อไม่ให้ hitbox หรือ coroutine เก่าค้าง
	boss.set("is_dead", false)
	boss.set("is_posture_broken", false)
	boss.set("can_receive_critical", false)
	boss.set("is_staggered", false)
	boss.set("is_winding_up", false)
	boss.set("is_attacking", false)
	boss.set("is_knocked_back", false)
	boss.set("knockback_velocity", Vector2.ZERO)
	boss.set("velocity", Vector2.ZERO)
	boss.set("has_hit_player", false)
	boss.set("can_attack", true)

	var attack_id = boss.get("attack_sequence_id")
	if attack_id != null:
		boss.set("attack_sequence_id", int(attack_id) + 1)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)

	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.modulate = Color.WHITE

	if boss.has_method("clear_attack_hint"):
		boss.call("clear_attack_hint")


func apply_current_training_pattern_to_boss() -> void:
	# ตั้ง pattern ที่บอสจะใช้ในการโจมตีครั้งต่อไปของ Duel 1
	if not is_instance_valid(boss):
		return

	var pattern_name: String = get_current_training_pattern_name()
	boss.set("debug_force_attack_pattern_enabled", true)
	boss.set("debug_forced_attack_pattern", pattern_name)


func get_current_training_pattern_name() -> String:
	# สลับ normal_slash เพื่อสอน Parry และ heavy_slash เพื่อสอน Dash
	if rotate_parry_dash_training_patterns:
		if current_training_pattern_index % 2 == 1:
			return "heavy_slash"
		return "normal_slash"

	return training_forced_boss_pattern


func watch_boss_windup_for_freeze_prompt() -> void:
	# จุดสำคัญของ Duel 1: ถ้าบอสกำลัง wind-up ให้หยุดก่อน hitbox เปิด แล้วขึ้นกล่องเตือน
	if not freeze_prompt_enabled:
		return

	if not is_instance_valid(boss):
		return

	var is_winding_up: bool = get_bool_value(boss, "is_winding_up")
	var is_attacking: bool = get_bool_value(boss, "is_attacking")
	if not is_winding_up or is_attacking:
		return

	var attack_id: int = get_int_value(boss, "attack_sequence_id", -1)
	if attack_id == last_frozen_attack_sequence_id:
		return

	start_freeze_prompt_for_current_attack(attack_id)


func start_freeze_prompt_for_current_attack(attack_id: int) -> void:
	# หยุดบอสในจังหวะก่อน hitbox เปิด แล้วให้ผู้เล่นเลือก Parry หรือ Dash
	last_frozen_attack_sequence_id = attack_id
	is_freeze_prompt_active = true
	freeze_prompt_elapsed_time = 0.0
	freeze_prompt_pattern_name = get_current_boss_attack_name()

	freeze_boss_before_training_hitbox()
	show_freeze_prompt_for_pattern(freeze_prompt_pattern_name)

	print("Duel 1 freeze prompt:", freeze_prompt_pattern_name)


func get_current_boss_attack_name() -> String:
	# อ่านชื่อท่าปัจจุบันจากบอส ถ้าอ่านไม่ได้ให้ fallback จาก pattern ที่เราบังคับไว้
	var current_attack = boss.get("current_attack_name")
	if current_attack != null:
		var current_attack_text: String = str(current_attack)
		if current_attack_text != "":
			return current_attack_text

	return get_current_training_pattern_name()


func freeze_boss_before_training_hitbox() -> void:
	# ยกเลิก coroutine attack() ก่อน active hitbox แล้วหยุดบอสไว้ตรง wind-up
	if not is_instance_valid(boss):
		return

	var attack_id = boss.get("attack_sequence_id")
	if attack_id != null:
		boss.set("attack_sequence_id", int(attack_id) + 1)

	boss.set_physics_process(false)
	boss.set("is_winding_up", true)
	boss.set("is_attacking", false)
	boss.set("is_staggered", false)
	boss.set("is_knocked_back", false)
	boss.set("can_attack", false)
	boss.set("velocity", Vector2.ZERO)
	boss.set("knockback_velocity", Vector2.ZERO)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)


func show_freeze_prompt_for_pattern(pattern_name: String) -> void:
	# กล่องและ hint เหนือหัวบอสตอนหยุดกลาง wind-up
	root_control.visible = true
	set_skip_button_visible(skip_button_enabled)

	if pattern_requires_dash(pattern_name):
		title_label.text = "⏸ DASH!"
		body_label.text = "บอสกำลังใช้ท่าหนัก\nเกมหยุดก่อนโดนตี: กด DASH ตอนนี้"
		show_boss_cue("DASH!", Color(1.0, 0.35, 0.0, 1.0))
		set_boss_sprite_color(Color(1.0, 0.35, 0.0, 1.0))
	else:
		title_label.text = "⏸ PARRY!"
		body_label.text = "บอสกำลังฟันใส่คุณ\nเกมหยุดก่อนโดนตี: กด PARRY ตอนนี้"
		show_boss_cue("PARRY!", Color(0.35, 0.95, 1.0, 1.0))
		set_boss_sprite_color(Color(0.35, 0.95, 1.0, 1.0))

	set_progress_percent(1.0)


func update_freeze_prompt(delta: float) -> void:
	# รับ input ตอนบอสหยุดอยู่ก่อน hitbox เปิด
	freeze_prompt_elapsed_time += delta
	set_progress_percent(1.0 - clamp(freeze_prompt_elapsed_time / max(freeze_prompt_response_time, 0.01), 0.0, 1.0))

	if expected_action_for_pattern_just_pressed(freeze_prompt_pattern_name):
		finish_freeze_prompt(true, "")
		return

	if wrong_action_for_pattern_just_pressed(freeze_prompt_pattern_name):
		finish_freeze_prompt(false, get_wrong_action_message_for_pattern(freeze_prompt_pattern_name))
		return

	if freeze_prompt_elapsed_time >= freeze_prompt_response_time:
		finish_freeze_prompt(false, "ไม่ได้กดตอบสนอง")


func expected_action_for_pattern_just_pressed(pattern_name: String) -> bool:
	# ท่าหนักต้อง Dash / ท่าที่ Parry ได้ให้ Parry
	if pattern_requires_dash(pattern_name):
		return Input.is_action_just_pressed("dash")

	return Input.is_action_just_pressed("parry")


func wrong_action_for_pattern_just_pressed(pattern_name: String) -> bool:
	# ใช้ตรวจว่าผู้เล่นกดปุ่มต่อสู้อื่นผิดจังหวะหรือผิดประเภท
	if pattern_requires_dash(pattern_name):
		return Input.is_action_just_pressed("parry") or Input.is_action_just_pressed("attack")

	return Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("attack")


func get_wrong_action_message_for_pattern(pattern_name: String) -> String:
	if pattern_requires_dash(pattern_name):
		return "ท่านี้ต้อง Dash ห้าม Parry/Attack"

	return "ท่านี้ควร Parry ไม่ใช่ Dash/Attack"


func pattern_requires_dash(pattern_name: String) -> bool:
	# ตอนนี้ heavy_slash คือท่าหนักที่ต้อง Dash
	return pattern_name == "heavy_slash"


func finish_freeze_prompt(was_successful: bool, fail_message: String) -> void:
	# จบ freeze prompt แล้วให้ Duel 1 เดินต่อ ไม่ใช่ไป DuelIntroManager
	if not is_freeze_prompt_active:
		return

	is_freeze_prompt_active = false
	is_freeze_feedback_active = true
	clear_boss_cue()
	play_controlled_attack_visual()
	stop_boss_after_freeze_prompt()

	if was_successful:
		show_freeze_prompt_success_feedback()
	else:
		show_freeze_prompt_fail_feedback(fail_message)

	await get_tree().create_timer(freeze_prompt_feedback_time).timeout

	if is_training_boss_completed:
		return

	is_freeze_feedback_active = false
	advance_training_pattern_after_prompt()
	resume_boss_after_freeze_prompt()
	update_training_boss_progress()


func show_freeze_prompt_success_feedback() -> void:
	# แสดง feedback เมื่อกดถูกใน Duel 1
	if pattern_requires_dash(freeze_prompt_pattern_name):
		title_label.text = "หลบทัน"
		body_label.text = "Dash ถูกจังหวะ\nจำไว้: ท่าหนักที่ขึ้น DASH! ต้องหลบ"
	else:
		title_label.text = "Parry สำเร็จ"
		body_label.text = "Parry ถูกจังหวะ\nจำไว้: ท่าที่ขึ้น PARRY! ให้ Parry"

		if reward_parry_success_during_duel_1 and is_instance_valid(player) and player.has_method("on_successful_parry"):
			player.call("on_successful_parry")

	set_progress_percent(1.0)


func show_freeze_prompt_fail_feedback(fail_message: String) -> void:
	# แสดง feedback เมื่อกดผิดหรือไม่กด แต่ยังให้ Duel 1 ดำเนินต่อ
	if fail_message == "":
		fail_message = "ลองจำสัญญาณนี้ไว้สำหรับรอบจริง"

	title_label.text = "ยังไม่ถูก"
	body_label.text = "%s\nไม่เป็นไร Duel 1 จะดำเนินต่อ" % fail_message
	set_progress_percent(0.0)


func stop_boss_after_freeze_prompt() -> void:
	# หยุดบอสหลังจบ prompt เพื่อไม่ให้ coroutine หรือ hitbox เดิมหลุดมาตีผู้เล่น
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(false)
	boss.set("is_winding_up", false)
	boss.set("is_attacking", false)
	boss.set("is_staggered", false)
	boss.set("is_knocked_back", false)
	boss.set("can_attack", false)
	boss.set("velocity", Vector2.ZERO)
	boss.set("knockback_velocity", Vector2.ZERO)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)


func advance_training_pattern_after_prompt() -> void:
	# หลังสอนหนึ่งจังหวะแล้ว ให้สลับไปท่าถัดไป เพื่อให้ Duel 1 ได้ฝึกทั้ง Parry และ Dash
	if rotate_parry_dash_training_patterns:
		current_training_pattern_index += 1

	apply_current_training_pattern_to_boss()


func resume_boss_after_freeze_prompt() -> void:
	# ปล่อยบอสให้ Duel 1 สู้ต่อแบบจำกัด pattern
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(true)
	boss.set("can_attack", true)
	set_boss_sprite_color(Color.WHITE)


func update_training_boss_progress() -> void:
	# คำนวณว่าผู้เล่นทำดาเมจใส่บอสจริงไปเท่าไรในช่วงฝึก
	if not is_instance_valid(boss):
		return

	var current_hp: int = get_int_value(boss, "current_hp", training_start_boss_hp)
	var damage_dealt: int = max(training_start_boss_hp - current_hp, 0)
	var required_damage: int = max(required_training_damage, 1)
	var ratio: float = clamp(float(damage_dealt) / float(required_damage), 0.0, 1.0)
	set_progress_percent(ratio)

	if not is_freeze_prompt_active and not is_freeze_feedback_active:
		body_label.text = "Duel 1: บอสใช้ pattern จำกัด\nดาเมจฝึก: %d / %d" % [damage_dealt, required_damage]

	if damage_dealt >= required_damage:
		finish_training_boss(false)


func finish_training_boss(was_skipped: bool) -> void:
	# จบช่วง Duel 1 ไม่ว่าจะตีครบหรือกด Skip
	if is_training_boss_completed:
		return

	is_training_boss_active = false
	is_training_boss_completed = true
	is_freeze_prompt_active = false
	is_freeze_feedback_active = false
	has_completed_training_boss_this_session = true
	set_skip_button_visible(false)
	set_boss_hold(true)
	restore_boss_full_pattern()

	if reset_boss_after_training:
		reset_boss_for_real_fight()

	if reset_positions_after_duel_1:
		reset_actor_positions_for_real_fight()

	root_control.visible = true
	if was_skipped:
		title_label.text = "ข้าม Duel 1"
		body_label.text = "กำลังจัดตำแหน่งใหม่เพื่อเริ่มบอสจริง"
	else:
		title_label.text = "ผ่าน Duel 1"
		body_label.text = "กำลังจัดตำแหน่งใหม่เพื่อเริ่มบอสจริง"

	set_progress_percent(1.0)
	print("Duel 1 guided boss training completed. Skipped =", was_skipped)

	await get_tree().create_timer(training_clear_message_time).timeout

	if is_training_boss_completed:
		show_real_boss_start_signal()
		await get_tree().create_timer(real_boss_start_signal_time).timeout

	root_control.visible = false
	show_boss_if_needed()

	if start_real_boss_after_duel_1:
		disable_duel_intro_if_available()
		set_boss_hold(false)
	else:
		enable_duel_intro_if_available()


func reset_actor_positions_for_real_fight() -> void:
	# จัดตำแหน่งเหมือนเริ่มซีนบอสจริงใหม่ หลังจากผ่าน Duel 1
	if is_instance_valid(player) and player is Node2D:
		var player_node := player as Node2D
		player_node.global_position = player_real_fight_start_position
		player.set("velocity", Vector2.ZERO)

	if is_instance_valid(boss) and boss is Node2D:
		var boss_node := boss as Node2D
		boss_node.global_position = boss_real_fight_start_position
		boss.set("velocity", Vector2.ZERO)
		boss.set("knockback_velocity", Vector2.ZERO)


func show_real_boss_start_signal() -> void:
	# สัญญาณบอกผู้เล่นว่าหมดช่วงฝึกแล้ว และกำลังเข้าบอสจริง
	root_control.visible = true
	title_label.text = real_boss_start_title
	body_label.text = real_boss_start_body
	set_progress_percent(1.0)
	set_skip_button_visible(false)

	if is_instance_valid(boss):
		show_boss_cue("BOSS FIGHT", Color(1.0, 0.15, 0.10, 1.0))


func reset_boss_for_real_fight() -> void:
	# รีเซ็ต HP/Posture และสถานะบอส เพื่อให้ไฟต์จริงเริ่มแบบยุติธรรม
	if not is_instance_valid(boss):
		return

	var boss_max_hp: int = get_int_value(boss, "max_hp", 300)
	var boss_max_posture: float = get_float_value(boss, "max_posture", 120.0)

	boss.set("current_hp", boss_max_hp)
	boss.set("current_posture", boss_max_posture)
	reset_boss_combat_state_for_training()
	boss.set("can_attack", false)

	if boss.has_method("emit_enemy_stats"):
		boss.call("emit_enemy_stats")


func restore_boss_full_pattern() -> void:
	# คืนค่า pattern ของบอสกลับเหมือนก่อนเข้าโหมดฝึก
	if not is_instance_valid(boss):
		return

	boss.set("debug_force_attack_pattern_enabled", original_debug_force_attack_pattern_enabled)
	boss.set("debug_forced_attack_pattern", original_debug_forced_attack_pattern)


func on_skip_button_pressed() -> void:
	# ข้าม Duel 1 แล้วเริ่มบอสจริงทันที
	if is_training_boss_completed:
		return

	finish_training_boss(true)


func set_boss_hold(should_hold: bool) -> void:
	# หยุดบอสไว้ระหว่างเปลี่ยนช่วง เพื่อไม่ให้โจมตีค้าง
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(not should_hold)

	var attack_id = boss.get("attack_sequence_id")
	if attack_id != null:
		boss.set("attack_sequence_id", int(attack_id) + 1)

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


func show_boss_if_needed() -> void:
	# ใช้บอสจริงตลอดช่วงฝึก จึงต้องแน่ใจว่าบอสยัง visible ก่อนเข้าช่วงต่อไป
	if is_instance_valid(boss):
		boss.visible = true


func finish_without_boss_training_if_needed() -> void:
	# กรณี Duel 1 ถูกปิด หรือ session นี้ผ่านไปแล้ว ให้จัด flow ให้ไม่ติด DuelIntro ซ้ำ
	if start_real_boss_after_duel_1:
		disable_duel_intro_if_available()
	else:
		enable_duel_intro_if_available()


func disable_duel_intro_if_available() -> void:
	# ปิด DuelIntro เพราะตอนนี้ Parry/Dash prompt อยู่ใน Duel 1 แล้ว
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", false)


func enable_duel_intro_if_available() -> void:
	# เปิด DuelIntro เฉพาะกรณีตั้งใจใช้ flow เก่า
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", true)


func set_skip_button_visible(is_visible: bool) -> void:
	# ซ่อน/แสดงปุ่ม Skip ของกล่องฝึกกับบอสจริง
	if skip_button == null:
		return

	skip_button.visible = is_visible
	skip_button.disabled = not is_visible


func set_progress_percent(percent: float) -> void:
	# Progress bar แสดงดาเมจหรือเวลาตอบสนองใน Duel 1
	if progress_bar == null:
		return

	progress_bar.value = clamp(percent, 0.0, 1.0) * 100.0


func show_boss_cue(text: String, color: Color) -> void:
	# ใช้ระบบ hint เหนือหัวบอสเดิม
	if is_instance_valid(boss) and boss.has_method("update_boss_hint_label"):
		boss.call("update_boss_hint_label", text, color)


func clear_boss_cue() -> void:
	# ล้าง hint เหนือหัวบอส
	if is_instance_valid(boss) and boss.has_method("clear_attack_hint"):
		boss.call("clear_attack_hint")

	set_boss_sprite_color(Color.WHITE)


func set_boss_sprite_color(new_color: Color) -> void:
	# เปลี่ยนสีบอสจริงชั่วคราวเพื่อช่วยอ่านประเภทท่า
	if not is_instance_valid(boss):
		return

	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.modulate = new_color


func play_controlled_attack_visual() -> void:
	# เล่น slash placeholder หลังผู้เล่นตอบ prompt เพื่อให้รู้สึกว่าท่าถูกปล่อยออกแล้ว
	if is_instance_valid(boss) and boss.has_method("show_boss_slash_effect"):
		boss.call("show_boss_slash_effect")


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true


func get_int_value(target: Node, property_name: String, fallback: int) -> int:
	# อ่านค่า int จาก node แบบปลอดภัย
	var value = target.get(property_name)
	if value == null:
		return fallback

	return int(value)


func get_float_value(target: Node, property_name: String, fallback: float) -> float:
	# อ่านค่า float จาก node แบบปลอดภัย
	var value = target.get(property_name)
	if value == null:
		return fallback

	return float(value)
