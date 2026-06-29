extends CanvasLayer

# =========================
# GameLoopManager.gd
# คุม loop พื้นฐานของเกมหนึ่งรอบ
# waiting_start -> playing -> victory / game_over -> restart
# =========================

# สถานะของเกมตอนรอกดเริ่ม
const STATE_WAITING_START: String = "waiting_start"

# สถานะของเกมตอนกำลังเล่น
const STATE_PLAYING: String = "playing"

# สถานะของเกมตอนชนะ
const STATE_VICTORY: String = "victory"

# สถานะของเกมตอนแพ้
const STATE_GAME_OVER: String = "game_over"

# อ้างอิง Player ในฉากหลัก
@export var player_path: NodePath = NodePath("../Player")

# อ้างอิง Boss ในฉากหลัก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง TouchControls เพื่อซ่อนปุ่มก่อนเริ่มเกม และตอนจบเกม
@export var touch_controls_path: NodePath = NodePath("../TouchControls")

# เปิด/ปิดหน้าเริ่มเกม
@export var start_screen_enabled: bool = true

# ข้อความชื่อเกมชั่วคราว
@export var game_title_text: String = "LAST BLADE TRIAL"

# ข้อความอธิบาย control สั้น ๆ
@export var control_hint_text: String = "Attack / Dash / Parry\nBreak posture, then use Focus Finisher."

# สถานะเกมปัจจุบัน
var game_state: String = STATE_WAITING_START

# อ้างอิง node สำคัญ
var player: Node = null
var boss: Node = null
var touch_controls: CanvasLayer = null

# Root UI ของ overlay
var overlay_root: Control = null

# Panel กลางจอ
var center_panel: PanelContainer = null

# ข้อความหัวข้อ
var title_label: Label = null

# ข้อความรายละเอียด
var body_label: Label = null

# ปุ่มหลัก ใช้เป็น Start หรือ Restart ตามสถานะ
var primary_button: Button = null

# เวลาเริ่มเล่น ใช้วัดเวลาที่ใช้ในรอบนั้น
var run_start_msec: int = 0


func _ready() -> void:
	# ให้อยู่เหนือ HUD และ TouchControls
	layer = 40

	# กันกรณี reload scene ตอนเกมกำลัง Hit Stop
	Engine.time_scale = 1.0

	# สร้าง UI overlay ก่อน แล้วค่อยหา node หลัง scene พร้อม
	create_overlay_ui()
	setup_game_loop.call_deferred()


func _process(_delta: float) -> void:
	# รองรับ keyboard เพื่อทดสอบเร็วบน Mac
	if game_state == STATE_WAITING_START and Input.is_key_pressed(KEY_ENTER):
		start_game()
		return

	if (game_state == STATE_VICTORY or game_state == STATE_GAME_OVER) and Input.is_key_pressed(KEY_R):
		restart_game()
		return


func setup_game_loop() -> void:
	# หา node หลักในฉาก
	find_scene_nodes()

	# เชื่อม signal จบเกมจาก Player และ Boss
	connect_end_signals()

	# ถ้าเปิดหน้าเริ่มเกม ให้หยุดการเล่นไว้ก่อนจนกด Start
	if start_screen_enabled:
		set_game_state(STATE_WAITING_START)
		set_combat_enabled(false)
		set_touch_controls_visible(false)
		show_start_screen()
	else:
		start_game()


func find_scene_nodes() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	player = get_node_or_null(player_path)
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")

	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา TouchControls เพื่อซ่อน/แสดงปุ่มตามสถานะเกม
	var touch_node := get_node_or_null(touch_controls_path)
	if touch_node is CanvasLayer:
		touch_controls = touch_node as CanvasLayer
	elif get_parent() != null:
		touch_node = get_parent().get_node_or_null("TouchControls")
		if touch_node is CanvasLayer:
			touch_controls = touch_node as CanvasLayer


func connect_end_signals() -> void:
	# เชื่อมสัญญาณ Player ตาย
	if is_instance_valid(player) and player.has_signal("player_died"):
		if not player.player_died.is_connected(on_player_died):
			player.player_died.connect(on_player_died)

	# เชื่อมสัญญาณ Boss ตาย
	if is_instance_valid(boss) and boss.has_signal("enemy_died"):
		if not boss.enemy_died.is_connected(on_boss_died):
			boss.enemy_died.connect(on_boss_died)


func create_overlay_ui() -> void:
	# สร้าง root UI เต็มจอ
	overlay_root = Control.new()
	overlay_root.name = "GameLoopOverlayRoot"
	overlay_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay_root)

	# สร้าง panel กลางจอแบบง่าย ๆ
	center_panel = PanelContainer.new()
	center_panel.name = "CenterPanel"
	center_panel.custom_minimum_size = Vector2(520.0, 300.0)
	center_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(center_panel)

	# จัด panel ให้อยู่กลางจอหลังรู้ขนาด viewport
	position_center_panel.call_deferred()

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.025, 0.035, 0.88)
	panel_style.border_color = Color(0.85, 0.72, 0.32, 0.95)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(18)
	panel_style.content_margin_left = 26.0
	panel_style.content_margin_right = 26.0
	panel_style.content_margin_top = 24.0
	panel_style.content_margin_bottom = 24.0
	center_panel.add_theme_stylebox_override("panel", panel_style)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 18)
	center_panel.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 36)
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.add_theme_font_size_override("font_size", 20)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(body_label)

	primary_button = Button.new()
	primary_button.custom_minimum_size = Vector2(240.0, 64.0)
	primary_button.focus_mode = Control.FOCUS_NONE
	primary_button.add_theme_font_size_override("font_size", 24)
	primary_button.pressed.connect(on_primary_button_pressed)
	layout.add_child(primary_button)

	# เริ่มต้นซ่อนไว้ก่อน รอ set state เป็นหน้าเริ่มหรือหน้าผลลัพธ์
	overlay_root.visible = false


func position_center_panel() -> void:
	# วาง panel กลางจอ โดยอ่านขนาด viewport ปัจจุบัน
	if center_panel == null:
		return

	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	center_panel.position = (screen_size - center_panel.custom_minimum_size) * 0.5


func set_game_state(new_state: String) -> void:
	# เปลี่ยนสถานะเกมปัจจุบัน
	game_state = new_state
	print("Game state =", game_state)


func set_combat_enabled(enabled: bool) -> void:
	# เปิด/ปิด physics process ของ Player และ Boss เพื่อหยุดเกมก่อนเริ่มหรือหลังจบ
	if is_instance_valid(player):
		player.set_physics_process(enabled)

	if is_instance_valid(boss):
		boss.set_physics_process(enabled)


func set_touch_controls_visible(is_visible: bool) -> void:
	# ซ่อนปุ่มมือถือก่อนเริ่มเกมและหลังจบเกม เพื่อไม่ให้กด action ระหว่างหน้า overlay
	if is_instance_valid(touch_controls):
		touch_controls.visible = is_visible


func show_start_screen() -> void:
	# แสดงหน้าเริ่มแบบเรียบง่าย
	overlay_root.visible = true
	title_label.text = game_title_text
	body_label.text = control_hint_text + "\n\nPress Enter or tap START."
	primary_button.text = "START"


func start_game() -> void:
	# เริ่มเล่นหนึ่งรอบ
	if game_state == STATE_PLAYING:
		return

	set_game_state(STATE_PLAYING)
	Engine.time_scale = 1.0
	run_start_msec = Time.get_ticks_msec()
	overlay_root.visible = false
	set_combat_enabled(true)
	set_touch_controls_visible(true)


func show_result_screen(title_text: String, body_text: String) -> void:
	# แสดงหน้าผลลัพธ์หลังชนะหรือแพ้
	set_combat_enabled(false)
	set_touch_controls_visible(false)
	Engine.time_scale = 1.0

	overlay_root.visible = true
	title_label.text = title_text
	body_label.text = body_text + "\n\nPress R or tap RESTART."
	primary_button.text = "RESTART"


func on_primary_button_pressed() -> void:
	# ปุ่มเดียวใช้ได้ทั้ง Start และ Restart ตามสถานะเกม
	if game_state == STATE_WAITING_START:
		start_game()
		return

	if game_state == STATE_VICTORY or game_state == STATE_GAME_OVER:
		restart_game()


func on_player_died() -> void:
	# เมื่อ Player ตาย ให้เข้าสู่สถานะแพ้
	if game_state == STATE_GAME_OVER or game_state == STATE_VICTORY:
		return

	set_game_state(STATE_GAME_OVER)
	show_result_screen("DEFEATED", "อ่านจังหวะบอส แล้วลองอีกครั้ง")


func on_boss_died() -> void:
	# เมื่อ Boss ตาย ให้เข้าสู่สถานะชนะ
	if game_state == STATE_GAME_OVER or game_state == STATE_VICTORY:
		return

	set_game_state(STATE_VICTORY)

	var elapsed_seconds: float = 0.0
	if run_start_msec > 0:
		elapsed_seconds = float(Time.get_ticks_msec() - run_start_msec) / 1000.0

	show_result_screen("VICTORY", "Time: %.1f sec" % elapsed_seconds)


func restart_game() -> void:
	# Restart แบบสะอาดโดย reload scene ทั้งฉาก
	# วิธีนี้ช่วยเคลียร์ HP/Stamina/Focus, Boss HP/Posture, hitbox และ coroutine เก่าทั้งหมด
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
