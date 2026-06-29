extends CanvasLayer

# =========================
# Duel1DummyManager.gd
# จัดลำดับ Phase 9 หลัง Training Coach
# ให้ผู้เล่นตีหุ่น Duel 1 ให้ตายก่อน แล้วค่อยเปิด Duel Practice / Boss ต่อ
# =========================

const Duel1DummyTargetScript = preload("res://duel_1_dummy_target.gd")

@export var player_path: NodePath = NodePath("../Player")
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")
@export var duel_intro_manager_path: NodePath = NodePath("../Duel1IntroManager")

# เปิด/ปิดระบบหุ่น Duel 1
@export var duel_1_dummy_enabled: bool = true

# แสดงแค่ครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# ตำแหน่ง spawn หุ่น Duel 1
@export var dummy_spawn_position: Vector2 = Vector2(720.0, 324.0)

# HP หุ่น Duel 1 เวอร์ชันแรก ตั้งให้ตีไม่กี่ครั้งตาย
@export var dummy_max_hp: int = 30

# ถ้า true จะซ่อนบอสระหว่างตีหุ่น เพื่อไม่ให้ผู้เล่นสับสนว่าเป้าหมายคือใคร
@export var hide_boss_during_dummy: bool = true

# เวลาค้างข้อความหลังตีหุ่นตาย ก่อนเปิด Duel Practice ต่อ
@export var dummy_clear_message_time: float = 1.20

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
var hp_bar: ProgressBar = null

var dummy_target: Node = null
var has_started_dummy: bool = false
var is_dummy_active: bool = false
var is_dummy_completed: bool = false

static var has_completed_dummy_this_session: bool = false


func _ready() -> void:
	# อยู่เหนือ TouchControls แต่ต่ำกว่า TrainingCoach และ DuelIntro
	layer = 34
	create_ui()
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	if not duel_1_dummy_enabled:
		enable_duel_intro_if_available()
		return

	if show_only_once_per_session and has_completed_dummy_this_session:
		enable_duel_intro_if_available()
		return

	if not are_references_ready():
		setup_references()
		return

	# ปิด DuelIntro ไว้ก่อนจนกว่าหุ่นจะถูกทำลาย
	if not is_dummy_completed:
		disable_duel_intro_if_available()

	if has_started_dummy or is_dummy_completed:
		return

	if not is_game_playing():
		return

	if not is_training_ready():
		return

	start_dummy_duel()


func create_ui() -> void:
	# สร้างกล่องสถานะ Duel 1 แบบเล็ก ไม่รบกวนการเล่น
	root_control = Control.new()
	root_control.name = "Duel1DummyRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 112.0)
	panel.position = Vector2(366.0, 24.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	body_label.add_theme_font_size_override("font_size", body_font_size)
	layout.add_child(body_label)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(340.0, 14.0)
	hp_bar.min_value = 0.0
	hp_bar.max_value = 100.0
	hp_bar.value = 100.0
	hp_bar.show_percentage = false
	layout.add_child(hp_bar)

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


func start_dummy_duel() -> void:
	# เริ่ม Duel 1 Dummy หลัง Training Coach จบ
	has_started_dummy = true
	is_dummy_active = true
	set_boss_hold(true)
	disable_duel_intro_if_available()
	spawn_dummy_target()

	root_control.visible = true
	title_label.text = "Duel 1: ทดลองตีเป้าหมาย"
	body_label.text = "ตีหุ่นให้แตก ก่อนฝึกอ่านจังหวะจริง"
	update_hp_bar(dummy_max_hp, dummy_max_hp)

	print("Duel 1 Dummy started")


func spawn_dummy_target() -> void:
	# สร้างหุ่นเป้าหมายแบบ dynamic เพื่อลดการแก้ scene หลายไฟล์
	if dummy_target != null and is_instance_valid(dummy_target):
		dummy_target.queue_free()

	dummy_target = Duel1DummyTargetScript.new()
	dummy_target.name = "Duel1DummyTarget"
	dummy_target.set("max_hp", dummy_max_hp)
	get_parent().add_child(dummy_target)

	if dummy_target is Node2D:
		var dummy_node := dummy_target as Node2D
		dummy_node.global_position = dummy_spawn_position

	if dummy_target.has_signal("hp_changed"):
		dummy_target.hp_changed.connect(on_dummy_hp_changed)

	if dummy_target.has_signal("dummy_defeated"):
		dummy_target.dummy_defeated.connect(on_dummy_defeated)


func on_dummy_hp_changed(current_hp: int, max_hp: int) -> void:
	# อัปเดต HP bar ของหุ่น Duel 1
	update_hp_bar(current_hp, max_hp)
	body_label.text = "HP หุ่น: %d / %d" % [current_hp, max_hp]


func update_hp_bar(current_hp: int, max_hp: int) -> void:
	if hp_bar == null:
		return

	var ratio: float = 0.0
	if max_hp > 0:
		ratio = clamp(float(current_hp) / float(max_hp), 0.0, 1.0)

	hp_bar.value = ratio * 100.0


func on_dummy_defeated() -> void:
	# หุ่นตายแล้ว เปิดทางไป Duel Practice ต่อ
	if is_dummy_completed:
		return

	is_dummy_active = false
	is_dummy_completed = true
	has_completed_dummy_this_session = true
	root_control.visible = true
	title_label.text = "ผ่าน Duel 1"
	body_label.text = "ต่อไปจะฝึกอ่านสัญญาณ PARRY! / DASH!"
	update_hp_bar(0, dummy_max_hp)

	print("Duel 1 Dummy completed")

	await get_tree().create_timer(dummy_clear_message_time).timeout

	root_control.visible = false
	set_boss_hold(true)
	show_boss_if_needed()
	enable_duel_intro_if_available()


func set_boss_hold(should_hold: bool) -> void:
	# หยุดบอสไว้ระหว่าง Duel 1 Dummy เพื่อไม่ให้บอสจริงเข้ามาตี
	if not is_instance_valid(boss):
		return

	boss.set_physics_process(not should_hold)

	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)

	if hide_boss_during_dummy and not is_dummy_completed:
		boss.visible = false

	if not should_hold:
		boss.visible = true
		boss.set("can_attack", true)
		boss.set("is_winding_up", false)
		boss.set("is_attacking", false)


func show_boss_if_needed() -> void:
	# แสดงบอสกลับมาก่อนเข้า Duel Practice
	if is_instance_valid(boss):
		boss.visible = true


func disable_duel_intro_if_available() -> void:
	# ปิด DuelIntro ไว้ก่อนจนกว่าหุ่น Duel 1 จะถูกทำลาย
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", false)


func enable_duel_intro_if_available() -> void:
	# เปิด DuelIntro หลังผ่านหุ่น Duel 1 แล้ว
	if is_instance_valid(duel_intro_manager):
		duel_intro_manager.set("duel_intro_enabled", true)
