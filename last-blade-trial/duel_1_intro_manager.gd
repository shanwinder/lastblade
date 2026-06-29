extends CanvasLayer

# =========================
# Duel1IntroManager.gd
# ขั้นกลางของ Phase 9 ก่อนทำศัตรู Duel 1 เต็มตัว
# เวอร์ชันนี้ให้ผู้เล่นฝึกตอบสนองจริง: PARRY! แล้ว DASH!
# =========================

@export var boss_path: NodePath = NodePath("../BossBrokenMaster")
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")
@export var training_coach_manager_path: NodePath = NodePath("../TrainingCoachManager")

# เปิด/ปิด Duel 1 practice gate
@export var duel_intro_enabled: bool = true

# แสดงเฉพาะครั้งแรกของ session เพื่อไม่รบกวนการเล่นซ้ำ
@export var show_only_once_per_session: bool = true

# เวลาหน่วงสั้น ๆ หลังทำสำเร็จ ก่อนปล่อยบอส
@export var success_hold_time: float = 0.65

# ข้อความหัวข้อหลัก
@export var intro_title: String = "Duel 1: อ่านสัญญาณ"

# ข้อความอธิบายก่อนฝึก
@export var intro_body: String = "ฝึกอ่านสัญญาณก่อนเข้าบอสจริง\nทำตามข้อความที่ขึ้นบนจอ"

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
var current_step: String = "intro"

static var has_completed_intro_this_session: bool = false


func _ready() -> void:
	# อยู่เหนือ TrainingCoach แต่ต่ำกว่า GameLoopManager
	layer = 36
	create_ui()
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	if not duel_intro_enabled:
		return

	if show_only_once_per_session and has_completed_intro_this_session:
		return

	if not are_references_ready():
		setup_references()
		return

	if has_completed_intro:
		return

	if not is_game_playing():
		return

	if not is_training_ready():
		return

	if not has_started_intro:
		start_intro()
		return

	update_practice_step()


func create_ui() -> void:
	# สร้างกล่องข้อความกลางจอแบบเบา ๆ
	root_control = Control.new()
	root_control.name = "Duel1IntroRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500.0, 190.0)
	panel.position = Vector2(326.0, 145.0)
	root_control.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.035, 0.86)
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
	title_label.add_theme_font_size_override("font_size", 30)
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
	current_step = "parry"
	set_boss_hold(true)

	title_label.text = intro_title
	body_label.text = intro_body + "\n\n" + parry_practice_text + " = กด PARRY"
	root_control.visible = true

	print("Duel 1 practice started")


func update_practice_step() -> void:
	# ตรวจ input ของผู้เล่นตามสัญญาณที่กำลังฝึก
	if current_step == "parry":
		if Input.is_action_just_pressed("parry"):
			show_dash_step()
		return

	if current_step == "dash":
		if Input.is_action_just_pressed("dash"):
			complete_intro()
		return


func show_dash_step() -> void:
	# ผู้เล่นกด Parry ถูกแล้ว ต่อไปฝึก Dash
	current_step = "dash"
	title_label.text = "ดีมาก"
	body_label.text = dash_practice_text + " = กด DASH\nท่าหนักห้าม Parry ต้อง Dash หลบ"
	print("Duel 1 practice: parry step completed")


func complete_intro() -> void:
	if has_completed_intro:
		return

	has_completed_intro = true
	has_completed_intro_this_session = true
	title_label.text = "พร้อมเข้าบอส"
	body_label.text = "จำไว้: PARRY! = Parry / DASH! = Dash"

	print("Duel 1 practice completed")

	await get_tree().create_timer(success_hold_time).timeout

	root_control.visible = false
	set_boss_hold(false)


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
