extends CanvasLayer

# =========================
# Duel1DummyManager.gd
# ชื่อไฟล์เดิมยังคงไว้เพื่อไม่ต้องรื้อ scene หลัก
# แต่พฤติกรรมใหม่คือใช้ BossBrokenMaster ตัวจริงเป็นหุ่นฝึก
# ระหว่างฝึกจะจำกัด pattern ของบอสไว้ก่อน แล้วค่อยปล่อยบอสเต็มรูปแบบหลังฝึกเสร็จ
# =========================

@export var player_path: NodePath = NodePath("../Player")
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")
@export var duel_intro_manager_path: NodePath = NodePath("../Duel1IntroManager")

# เปิด/ปิดระบบฝึกกับบอสจริงก่อนเข้า Duel Practice
@export var boss_training_enabled: bool = true

# แสดงแค่ครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เปิด/ปิดปุ่ม Skip สำหรับข้ามช่วงฝึกกับบอสจริง
@export var skip_button_enabled: bool = true

# ข้อความบนปุ่ม Skip
@export var skip_button_text: String = "SKIP"

# ระหว่างฝึกจะบังคับให้บอสใช้ pattern ง่ายก่อน
@export_enum("normal_slash", "quick_slash", "delayed_slash", "heavy_slash") var training_forced_boss_pattern: String = "normal_slash"

# ผู้เล่นต้องทำดาเมจใส่บอสจริงเท่านี้ จึงถือว่าผ่านช่วงฝึก
@export var required_training_damage: int = 30

# ถ้า true หลังฝึกเสร็จจะรีเซ็ต HP/Posture ของบอสก่อนเข้าของจริง
@export var reset_boss_after_training: bool = true

# เวลาค้างข้อความหลังผ่านหรือ skip ก่อนเปิด Duel Practice ต่อ
@export var training_clear_message_time: float = 1.20

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

static var has_completed_training_boss_this_session: bool = false


func _ready() -> void:
	# อยู่เหนือ TouchControls แต่ต่ำกว่า TrainingCoach และ DuelIntro
	layer = 34
	create_ui()
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	if not boss_training_enabled:
		enable_duel_intro_if_available()
		return

	if show_only_once_per_session and has_completed_training_boss_this_session:
		enable_duel_intro_if_available()
		return

	if not are_references_ready():
		setup_references()
		return

	# ปิด DuelIntro ไว้ก่อนจนกว่าช่วงฝึกกับบอสจริงจะจบ
	if not is_training_boss_completed:
		disable_duel_intro_if_available()

	if is_training_boss_active:
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
	panel.custom_minimum_size = Vector2(460.0, 162.0)
	panel.position = Vector2(346.0, 24.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root_control.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.035, 0.84)
	style.border_color = Color(0.95, 0.75, 0.25, 0.90)
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
	progress_bar.custom_minimum_size = Vector2(360.0, 14.0)
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
	# เริ่มฝึกกับบอสจริงหลัง Training Coach จบ
	has_started_training_boss = true
	is_training_boss_active = true
	is_training_boss_completed = false

	root_control.visible = true
	set_skip_button_visible(skip_button_enabled)

	prepare_boss_for_limited_training()

	title_label.text = "Duel 1: ฝึกกับบอสจริง"
	body_label.text = "บอสจะใช้ท่าง่ายก่อน\nตีบอสให้ครบ %d ดาเมจ แล้วค่อยเข้าจริง" % required_training_damage
	set_progress_percent(0.0)

	print("Duel 1 Boss Training started")


func prepare_boss_for_limited_training() -> void:
	# ให้เห็นบอสตัวจริง และจำกัด pattern เอาไว้ก่อน
	if not is_instance_valid(boss):
		return

	boss.visible = true
	save_original_boss_debug_settings()
	reset_boss_combat_state_for_training()

	training_start_boss_hp = get_int_value(boss, "current_hp", get_int_value(boss, "max_hp", 300))

	# ใช้ debug pattern เดิมของบอสเป็นตัวบังคับท่าแบบปลอดภัย ไม่ต้องแก้ BossBrokenMaster.gd เพิ่ม
	boss.set("debug_force_attack_pattern_enabled", true)
	boss.set("debug_forced_attack_pattern", training_forced_boss_pattern)

	# เปิด physics ของบอส เพื่อให้บอสเดิน/โจมตีแบบจำกัดได้จริง
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
		boss.clear_attack_hint()


func update_training_boss_progress() -> void:
	# คำนวณว่าผู้เล่นทำดาเมจใส่บอสจริงไปเท่าไรในช่วงฝึก
	if not is_instance_valid(boss):
		return

	var current_hp: int = get_int_value(boss, "current_hp", training_start_boss_hp)
	var damage_dealt: int = max(training_start_boss_hp - current_hp, 0)
	var required_damage: int = max(required_training_damage, 1)
	var ratio: float = clamp(float(damage_dealt) / float(required_damage), 0.0, 1.0)
	set_progress_percent(ratio)

	body_label.text = "บอสใช้ท่า %s แบบจำกัด\nดาเมจฝึก: %d / %d" % [training_forced_boss_pattern, damage_dealt, required_damage]

	if damage_dealt >= required_damage:
		finish_training_boss(false)


func finish_training_boss(was_skipped: bool) -> void:
	# จบช่วงฝึกกับบอสจริง ไม่ว่าจะตีครบหรือกด Skip
	if is_training_boss_completed:
		return

	is_training_boss_active = false
	is_training_boss_completed = true
	has_completed_training_boss_this_session = true
	set_skip_button_visible(false)
	set_boss_hold(true)
	restore_boss_full_pattern()

	if reset_boss_after_training:
		reset_boss_for_real_fight()

	root_control.visible = true
	if was_skipped:
		title_label.text = "ข้ามการฝึกบอส"
		body_label.text = "ต่อไปจะฝึกอ่านสัญญาณ PARRY! / DASH!"
	else:
		title_label.text = "ผ่านการฝึกกับบอส"
		body_label.text = "รีเซ็ตบอสแล้ว ต่อไปจะฝึกอ่านสัญญาณ"

	set_progress_percent(1.0)
	print("Duel 1 Boss Training completed. Skipped =", was_skipped)

	await get_tree().create_timer(training_clear_message_time).timeout

	root_control.visible = false
	show_boss_if_needed()
	enable_duel_intro_if_available()


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
		boss.emit_enemy_stats()


func restore_boss_full_pattern() -> void:
	# คืนค่า pattern ของบอสกลับเหมือนก่อนเข้าโหมดฝึก
	if not is_instance_valid(boss):
		return

	boss.set("debug_force_attack_pattern_enabled", original_debug_force_attack_pattern_enabled)
	boss.set("debug_forced_attack_pattern", original_debug_forced_attack_pattern)


func on_skip_button_pressed() -> void:
	# ข้ามช่วงฝึกกับบอสจริง เพื่อไปยัง Duel Practice ทันที
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


func disable_duel_intro_if_available() -> void:
	# ปิด DuelIntro ไว้ก่อนจนกว่าช่วงฝึกกับบอสจริงจะจบ
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", false)


func enable_duel_intro_if_available() -> void:
	# เปิด DuelIntro หลังผ่านการฝึกกับบอสจริงแล้ว
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", true)


func set_skip_button_visible(is_visible: bool) -> void:
	# ซ่อน/แสดงปุ่ม Skip ของกล่องฝึกกับบอสจริง
	if skip_button == null:
		return

	skip_button.visible = is_visible
	skip_button.disabled = not is_visible


func set_progress_percent(percent: float) -> void:
	# Progress bar แสดงดาเมจที่ทำได้ในช่วงฝึกกับบอสจริง
	if progress_bar == null:
		return

	progress_bar.value = clamp(percent, 0.0, 1.0) * 100.0


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
