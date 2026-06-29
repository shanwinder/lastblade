extends CanvasLayer

# =========================
# TrainingCoachManager.gd
# ระบบสอนผู้เล่นใหม่แบบสั้นสำหรับ Phase 9 Vertical Slice
# สอนเดิน / Attack / Dash / Parry ก่อนปล่อยให้บอสเริ่มสู้จริง
# =========================

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# อ้างอิง Boss ในฉากหลัก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง GameLoopManager เพื่อเริ่มสอนเฉพาะตอนเกมอยู่ในสถานะ playing
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")

# เปิด/ปิดระบบสอนแบบย่อ
@export var training_coach_enabled: bool = true

# ถ้า true จะหยุด AI/physics ของบอสไว้จนผู้เล่นทำ tutorial ครบ
@export var hold_boss_until_training_done: bool = true

# ถ้า true จะแสดง tutorial เฉพาะรอบแรกของ session นี้
@export var show_only_once_per_session: bool = true

# ตำแหน่งกล่องข้อความบนจอ
@export var coach_panel_position: Vector2 = Vector2(320.0, 22.0)

# ขนาดกล่องข้อความ
@export var coach_panel_size: Vector2 = Vector2(520.0, 96.0)

# ขนาดตัวอักษรหัวข้อ
@export var title_font_size: int = 22

# ขนาดตัวอักษรรายละเอียด
@export var body_font_size: int = 16

# ระยะเวลาที่ข้อความจบ tutorial ค้างไว้ก่อนซ่อน
@export var completion_message_time: float = 1.25

# อ้างอิง node สำคัญ
var player: Node = null
var boss: Node = null
var game_loop_manager: Node = null

# Root UI
var root_control: Control = null
var coach_panel: PanelContainer = null
var title_label: Label = null
var body_label: Label = null

# สถานะ tutorial
var is_training_active: bool = false
var is_training_completed: bool = false
var has_started_training_this_scene: bool = false
var current_step_index: int = 0

# จำว่าเคยสอนครบแล้วใน session นี้หรือยัง
static var has_completed_training_this_session: bool = false

# รายการ step แบบสั้น ไม่ใช้ข้อความเยอะ
var training_steps: Array[Dictionary] = [
	{
		"id": "move",
		"title": "1/4 เดินซ้าย-ขวา",
		"body": "กด ◀ / ▶ หรือปุ่มซ้าย-ขวา เพื่อขยับตัว"
	},
	{
		"id": "attack",
		"title": "2/4 Attack",
		"body": "กด ATTACK เพื่อดูระยะฟันของ Player"
	},
	{
		"id": "dash",
		"title": "3/4 Dash",
		"body": "กด DASH เพื่อพุ่งหลบท่าหนักของบอส"
	},
	{
		"id": "parry",
		"title": "4/4 Parry",
		"body": "กด PARRY เมื่อเห็น PARRY! เหนือหัวบอส"
	}
]


func _ready() -> void:
	# วาง layer ให้อยู่เหนือ HUD แต่ต่ำกว่า GameLoopManager
	layer = 35

	# สร้าง UI ก่อน แล้วหา node หลัง scene พร้อม
	create_coach_ui()
	setup_references.call_deferred()


func _physics_process(_delta: float) -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องทำอะไร
	if not training_coach_enabled:
		return

	# ถ้าตั้งให้สอนครั้งเดียว และ session นี้สอนครบแล้ว ให้ไม่ทำงาน
	if show_only_once_per_session and has_completed_training_this_session:
		return

	# ถ้ายังหา node ไม่ครบ ให้ลองหาใหม่
	if not are_references_ready():
		setup_references()
		return

	# รอให้ GameLoopManager เปลี่ยนเป็น playing ก่อนค่อยเริ่มสอน
	if not is_game_playing():
		return

	# เริ่ม tutorial หนึ่งครั้งหลังผู้เล่นกด Start
	if not has_started_training_this_scene:
		start_training()

	# ถ้ากำลังสอนอยู่ ให้ตรวจว่า step ปัจจุบันสำเร็จหรือยัง
	if is_training_active:
		update_current_training_step()


func create_coach_ui() -> void:
	# สร้าง root control สำหรับข้อความสอน
	root_control = Control.new()
	root_control.name = "TrainingCoachRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	coach_panel = PanelContainer.new()
	coach_panel.name = "CoachPanel"
	coach_panel.position = coach_panel_position
	coach_panel.custom_minimum_size = coach_panel_size
	coach_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(coach_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.025, 0.035, 0.78)
	panel_style.border_color = Color(0.75, 0.95, 1.0, 0.80)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 18.0
	panel_style.content_margin_right = 18.0
	panel_style.content_margin_top = 12.0
	panel_style.content_margin_bottom = 12.0
	coach_panel.add_theme_stylebox_override("panel", panel_style)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 4)
	coach_panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", title_font_size)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", body_font_size)
	layout.add_child(body_label)

	root_control.visible = false


func setup_references() -> void:
	# หา Player
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")

	# หา Boss
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา GameLoopManager
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")


func are_references_ready() -> bool:
	# ตรวจว่า node สำคัญพร้อมใช้งานหรือยัง
	return is_instance_valid(player) and is_instance_valid(boss) and is_instance_valid(game_loop_manager)


func is_game_playing() -> bool:
	# อ่านสถานะจาก GameLoopManager แบบปลอดภัย
	if not is_instance_valid(game_loop_manager):
		return false

	var state = game_loop_manager.get("game_state")
	return state == "playing"


func start_training() -> void:
	# เริ่ม tutorial หลังผู้เล่นกด Start
	has_started_training_this_scene = true
	is_training_active = true
	is_training_completed = false
	current_step_index = 0

	# หยุดบอสไว้ก่อน เพื่อให้ผู้เล่นเรียนปุ่มพื้นฐานโดยไม่โดนกดดันทันที
	set_boss_training_hold(true)

	root_control.visible = true
	show_current_step_text()

	print("Training Coach started")


func update_current_training_step() -> void:
	# ถ้าทำครบทุก step แล้ว ให้จบ tutorial
	if current_step_index >= training_steps.size():
		complete_training()
		return

	var current_step := training_steps[current_step_index]
	var step_id: String = str(current_step.get("id", ""))

	if is_step_completed(step_id):
		current_step_index += 1

		if current_step_index >= training_steps.size():
			complete_training()
		else:
			show_current_step_text()


func is_step_completed(step_id: String) -> bool:
	# ตรวจ input ของผู้เล่นตาม step ปัจจุบัน
	match step_id:
		"move":
			return abs(Input.get_axis("ui_left", "ui_right")) > 0.0
		"attack":
			return Input.is_action_just_pressed("attack")
		"dash":
			return Input.is_action_just_pressed("dash")
		"parry":
			return Input.is_action_just_pressed("parry")
		_:
			return false


func show_current_step_text() -> void:
	# แสดงข้อความของ step ปัจจุบัน
	if current_step_index < 0 or current_step_index >= training_steps.size():
		return

	var current_step := training_steps[current_step_index]
	title_label.text = str(current_step.get("title", "Training"))
	body_label.text = str(current_step.get("body", ""))


func complete_training() -> void:
	# จบ tutorial แล้วปล่อยให้บอสเริ่มสู้จริง
	if is_training_completed:
		return

	is_training_active = false
	is_training_completed = true
	has_completed_training_this_session = true

	title_label.text = "พร้อมสู้"
	body_label.text = "อ่านข้อความเหนือหัวบอส: PARRY! ให้ Parry / DASH! ให้ Dash"

	set_boss_training_hold(false)

	print("Training Coach completed")

	await get_tree().create_timer(completion_message_time).timeout

	if is_instance_valid(root_control):
		root_control.visible = false


func set_boss_training_hold(should_hold: bool) -> void:
	# หยุด/ปล่อยบอสระหว่าง tutorial
	if not hold_boss_until_training_done:
		return

	if not is_instance_valid(boss):
		return

	# ปิด physics ของบอสเพื่อไม่ให้เดินเข้ามาตีระหว่างสอนปุ่มพื้นฐาน
	boss.set_physics_process(not should_hold)

	# ปิด hitbox ของบอสด้วย เผื่อมีจังหวะโจมตีค้างจาก coroutine เก่า
	var attack_shape = boss.get_node_or_null("AttackHitbox/CollisionShape2D")
	if attack_shape != null:
		attack_shape.set_deferred("disabled", true)

	# ถ้าปล่อยบอส ให้ reset flag เล็กน้อยเพื่อเริ่มไฟต์สะอาดขึ้น
	if not should_hold:
		boss.set("can_attack", true)
		boss.set("is_winding_up", false)
		boss.set("is_attacking", false)
