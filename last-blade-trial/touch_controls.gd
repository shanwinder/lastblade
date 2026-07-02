extends CanvasLayer

# =========================
# TouchControls.gd
# ระบบควบคุมบนมือถือสำหรับ Last Blade Trial / ดาบไร้นาม
# เวอร์ชัน Mobile Combat Rework
# ซ้าย = Virtual Joystick / Movement Deflect / Tap Deflect
# ขวา = Attack / Dash / Lock-on
# =========================

# เปิด/ปิด touch controls ทั้งชุด
@export var touch_controls_enabled: bool = true

# เปิดให้ใช้ mouse click/drag ทดสอบบน Mac/PC ได้
@export var allow_mouse_test: bool = true

# เปิด/ปิดการจัดตำแหน่งใหม่เมื่อขนาดจอเปลี่ยน
@export var responsive_layout_enabled: bool = true

# =========================
# ขนาด UI หลัก
# =========================

# ขนาดพื้นที่รับสัมผัสของ joystick ฝั่งซ้าย
@export var joystick_area_size: Vector2 = Vector2(230.0, 230.0)

# ขนาดวงฐานของ joystick
@export var joystick_base_size: Vector2 = Vector2(174.0, 174.0)

# ขนาดปุ่มแกนกลางของ joystick
@export var joystick_knob_size: Vector2 = Vector2(78.0, 78.0)

# ระยะสูงสุดที่แกนกลาง joystick ขยับออกจากจุดศูนย์กลางได้
@export var joystick_knob_max_distance: float = 56.0

# ระยะ deadzone ถ้านิ้วขยับน้อยกว่านี้จะยังไม่สั่งเดิน
@export var joystick_deadzone: float = 22.0

# ขนาดปุ่ม Attack ซึ่งควรใหญ่และกดง่ายที่สุด
@export var attack_button_size: Vector2 = Vector2(150.0, 150.0)

# ขนาดปุ่ม Dash และ Lock
@export var action_button_size: Vector2 = Vector2(116.0, 116.0)

# ระยะห่างจากขอบจอ
@export var screen_margin: float = 32.0

# ระยะห่างระหว่างปุ่ม action ฝั่งขวา
@export var action_button_gap: float = 20.0

# ระยะเผื่อด้านล่างสำหรับมือถือที่มีแถบนำทางหรือขอบจอหนา
@export var mobile_bottom_safe_margin: float = 0.0

# ขนาดตัวอักษรบนปุ่ม
@export var button_font_size: int = 22

# =========================
# สีและความโปร่งใส
# =========================

# ความโปร่งใสของปุ่มปกติ
@export var button_alpha: float = 0.58

# ความโปร่งใสของปุ่มตอนกด
@export var pressed_button_alpha: float = 0.88

# สีพื้นปุ่ม action ปกติ
@export var button_fill_color: Color = Color(0.07, 0.09, 0.12, 0.58)

# สีพื้นปุ่ม action ตอนกด
@export var button_pressed_fill_color: Color = Color(0.20, 0.42, 0.55, 0.88)

# สีพื้นปุ่ม Lock-on เมื่อเปิดล็อคเป้าแล้ว
@export var lock_on_fill_color: Color = Color(0.95, 0.72, 0.18, 0.88)

# สีเส้นขอบปุ่ม action
@export var button_border_color: Color = Color(0.75, 0.95, 1.0, 0.90)

# สีเส้นขอบปุ่ม Lock-on เมื่อเปิดล็อคเป้าแล้ว
@export var lock_on_border_color: Color = Color(1.0, 0.92, 0.35, 1.0)

# ความหนาเส้นขอบปุ่ม action
@export var button_border_width: int = 3

# สีฐาน joystick
@export var joystick_base_color: Color = Color(0.06, 0.08, 0.11, 0.36)

# สีแกนกลาง joystick ตอนปกติ
@export var joystick_knob_color: Color = Color(0.15, 0.24, 0.30, 0.70)

# สีแกนกลาง joystick ตอนกำลังลาก
@export var joystick_knob_pressed_color: Color = Color(0.28, 0.54, 0.68, 0.86)

# สีเส้นขอบ joystick
@export var joystick_border_color: Color = Color(0.75, 0.95, 1.0, 0.82)

# =========================
# Node UI ที่สร้างด้วยโค้ด
# =========================

# Root control ที่คลุมทั้งจอ
var root_control: Control = null

# พื้นที่รับ input ของ joystick
var joystick_area: Control = null

# วงฐาน joystick
var joystick_base_panel: Panel = null

# ปุ่มแกนกลาง joystick
var joystick_knob_panel: Panel = null

# ปุ่ม action ฝั่งขวา
var attack_touch_button: Button = null
var dash_touch_button: Button = null
var lock_touch_button: Button = null

# =========================
# สถานะ joystick / input
# =========================

# จำขนาดจอล่าสุด เพื่อรู้ว่าควรจัด layout ใหม่หรือไม่
var last_screen_size: Vector2 = Vector2.ZERO

# จุดศูนย์กลาง joystick ภายใน joystick_area
var joystick_center: Vector2 = Vector2.ZERO

# ทิศทาง joystick ปัจจุบัน ค่า x อยู่ประมาณ -1 ถึง 1
var joystick_vector: Vector2 = Vector2.ZERO

# touch index ที่กำลังควบคุม joystick อยู่ ใช้กันนิ้วอื่นมาแย่ง joystick
var active_joystick_touch_index: int = -1

# ใช้สำหรับทดสอบด้วย mouse บน Mac/PC
var is_mouse_dragging_joystick: bool = false

# action เดินปัจจุบันที่ joystick กดค้างอยู่
var current_move_action: String = ""

# รายชื่อ action ที่กดค้างอยู่ เพื่อปล่อยตอนปิด scene กัน input ค้าง
var held_actions: Array[String] = []


func _ready() -> void:
	# ถ้าปิด touch controls ไว้ ไม่ต้องสร้าง UI
	if not touch_controls_enabled:
		return

	# สร้าง UI หลัง viewport พร้อม เพื่อให้คำนวณตำแหน่งปุ่มได้ถูกต้อง
	create_touch_ui.call_deferred()


func _process(_delta: float) -> void:
	# ถ้าทั้ง CanvasLayer ถูกซ่อน เช่น ตอนหน้า Start / Victory ให้ปล่อย input ที่ค้างทันที
	if not visible:
		release_all_touch_actions()
		return

	# อัปเดตภาพปุ่ม Lock ให้ตรงกับสถานะจริงของ Player
	update_lock_button_visual()

	# ถ้าเปิด responsive layout ให้ตรวจขนาดจอ และจัดปุ่มใหม่เมื่อ viewport เปลี่ยน
	if not responsive_layout_enabled:
		return

	if root_control == null:
		return

	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	if screen_size.distance_squared_to(last_screen_size) > 1.0:
		layout_touch_controls()


func create_touch_ui() -> void:
	# สร้าง root control สำหรับวางปุ่มทั้งหมด
	root_control = Control.new()
	root_control.name = "TouchControlsRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	# สร้าง joystick ฝั่งซ้าย ใช้ทั้งเดินและกระตุ้น Deflect
	create_virtual_joystick()

	# ปุ่ม Attack ฝั่งขวา ใหญ่ที่สุดและอยู่ตำแหน่งนิ้วโป้งกดง่าย
	attack_touch_button = create_touch_button("ATTACK", attack_button_size)
	root_control.add_child(attack_touch_button)
	connect_tap_button(attack_touch_button, "attack")

	# ปุ่ม Dash วางซ้ายของ Attack
	dash_touch_button = create_touch_button("DASH", action_button_size)
	root_control.add_child(dash_touch_button)
	connect_tap_button(dash_touch_button, "dash")

	# ปุ่ม Lock แทนปุ่ม Parry เดิม ใช้เปิด/ปิดการล็อคเป้า Boss
	lock_touch_button = create_touch_button("LOCK", action_button_size)
	root_control.add_child(lock_touch_button)
	connect_lock_button(lock_touch_button)

	layout_touch_controls()
	print("TouchControls ready. Attack/Dash/Lock + Tap/Movement Deflect enabled. Mouse test =", allow_mouse_test)


func create_virtual_joystick() -> void:
	# joystick_area เป็น Control ล่องหนที่รับการแตะ/ลากนิ้ว
	joystick_area = Control.new()
	joystick_area.name = "VirtualJoystickArea"
	joystick_area.custom_minimum_size = joystick_area_size
	joystick_area.size = joystick_area_size
	joystick_area.mouse_filter = Control.MOUSE_FILTER_STOP
	root_control.add_child(joystick_area)
	joystick_area.gui_input.connect(_on_joystick_gui_input)

	# วงฐานของ joystick ใช้ Panel เพื่อวาด StyleBoxFlat ทรงกลม
	joystick_base_panel = create_round_panel("JoystickBase", joystick_base_size, joystick_base_color, joystick_border_color, 3)
	joystick_area.add_child(joystick_base_panel)

	# ปุ่มแกนกลางของ joystick
	joystick_knob_panel = create_round_panel("JoystickKnob", joystick_knob_size, joystick_knob_color, joystick_border_color, 2)
	joystick_area.add_child(joystick_knob_panel)

	reset_virtual_joystick_visual_only()


func layout_touch_controls() -> void:
	# จัดตำแหน่งปุ่มตามขนาด viewport ปัจจุบัน ใช้ได้ทั้ง editor และ Android
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	last_screen_size = screen_size

	if root_control != null:
		root_control.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bottom_margin: float = screen_margin + mobile_bottom_safe_margin

	# joystick อยู่มุมซ้ายล่าง แต่มีพื้นที่รับนิ้วใหญ่กว่าภาพที่เห็น
	set_control_rect(
		joystick_area,
		Vector2(screen_margin, screen_size.y - bottom_margin - joystick_area_size.y),
		joystick_area_size,
		screen_size
	)
	reset_virtual_joystick_visual_only()

	# ปุ่ม Attack อยู่มุมขวาล่าง และใหญ่สุด
	set_button_rect(
		attack_touch_button,
		Vector2(screen_size.x - screen_margin - attack_button_size.x, screen_size.y - bottom_margin - attack_button_size.y),
		attack_button_size,
		screen_size
	)

	# ปุ่ม Dash อยู่ซ้ายของ Attack
	set_button_rect(
		dash_touch_button,
		Vector2(screen_size.x - screen_margin - attack_button_size.x - action_button_size.x - action_button_gap, screen_size.y - bottom_margin - action_button_size.y),
		action_button_size,
		screen_size
	)

	# ปุ่ม Lock อยู่เหนือ Attack แทนตำแหน่ง Parry เดิม
	set_button_rect(
		lock_touch_button,
		Vector2(screen_size.x - screen_margin - action_button_size.x, screen_size.y - bottom_margin - attack_button_size.y - action_button_size.y - action_button_gap),
		action_button_size,
		screen_size
	)


func set_control_rect(control: Control, desired_position: Vector2, control_size: Vector2, screen_size: Vector2) -> void:
	# ตั้งขนาดและตำแหน่ง Control พร้อม clamp ไม่ให้หลุดออกนอกจอ
	if control == null:
		return

	control.custom_minimum_size = control_size
	control.size = control_size
	control.position = clamp_control_position(desired_position, control_size, screen_size)


func set_button_rect(button: Button, desired_position: Vector2, button_size: Vector2, screen_size: Vector2) -> void:
	# ตั้งขนาดและตำแหน่งปุ่ม พร้อม clamp ไม่ให้หลุดออกนอกจอ
	if button == null:
		return

	button.custom_minimum_size = button_size
	button.size = button_size
	button.position = clamp_control_position(desired_position, button_size, screen_size)


func clamp_control_position(desired_position: Vector2, control_size: Vector2, screen_size: Vector2) -> Vector2:
	# กัน UI หลุดขอบจอ โดยยังรักษา margin ให้มากที่สุดเท่าที่ทำได้
	var max_x: float = max(screen_margin, screen_size.x - screen_margin - control_size.x)
	var max_y: float = max(screen_margin, screen_size.y - screen_margin - control_size.y)

	return Vector2(
		clamp(desired_position.x, screen_margin, max_x),
		clamp(desired_position.y, screen_margin, max_y)
	)


func reset_virtual_joystick_visual_only() -> void:
	# วางฐานและแกนกลางกลับกลาง joystick_area โดยไม่แตะ input
	if joystick_area == null:
		return

	joystick_center = joystick_area_size * 0.5

	if joystick_base_panel != null:
		joystick_base_panel.size = joystick_base_size
		joystick_base_panel.position = joystick_center - joystick_base_size * 0.5

	if joystick_knob_panel != null:
		joystick_knob_panel.size = joystick_knob_size
		joystick_knob_panel.position = joystick_center - joystick_knob_size * 0.5
		apply_round_panel_style(joystick_knob_panel, joystick_knob_color, joystick_border_color, 2)


func reset_virtual_joystick() -> void:
	# คืน joystick กลับกลาง และปล่อยปุ่มเดินทั้งหมด
	active_joystick_touch_index = -1
	is_mouse_dragging_joystick = false
	joystick_vector = Vector2.ZERO
	current_move_action = ""
	release_action("ui_left")
	release_action("ui_right")
	reset_virtual_joystick_visual_only()


func update_virtual_joystick(local_position: Vector2) -> void:
	# แปลงตำแหน่งนิ้วภายใน joystick_area เป็นระยะที่แกนกลางควรขยับ
	var raw_offset: Vector2 = local_position - joystick_center
	var clamped_offset: Vector2 = raw_offset.limit_length(joystick_knob_max_distance)

	# อัปเดตภาพแกนกลาง joystick
	if joystick_knob_panel != null:
		joystick_knob_panel.position = joystick_center - joystick_knob_size * 0.5 + clamped_offset
		apply_round_panel_style(joystick_knob_panel, joystick_knob_pressed_color, joystick_border_color, 2)

	# เก็บ vector ไว้ เผื่ออนาคตอยากเปลี่ยนเป็น analog movement จริง
	if joystick_knob_max_distance > 0.0:
		joystick_vector = clamped_offset / joystick_knob_max_distance
	else:
		joystick_vector = Vector2.ZERO

	update_movement_from_joystick(clamped_offset.x)


func update_movement_from_joystick(offset_x: float) -> void:
	# เกมนี้เดินแค่ซ้าย/ขวา จึงใช้แกน X ของ joystick เป็นตัวตัดสิน
	if offset_x < -joystick_deadzone:
		set_current_move_action("ui_left")
	elif offset_x > joystick_deadzone:
		set_current_move_action("ui_right")
	else:
		set_current_move_action("")


func set_current_move_action(action_name: String) -> void:
	# ถ้า action เดิมยังเหมือนเดิม ไม่ต้องกดซ้ำทุกเฟรม
	if current_move_action == action_name:
		return

	# ปล่อย action เดิมก่อน เพื่อไม่ให้ ui_left และ ui_right ค้างพร้อมกัน
	if current_move_action != "":
		release_action(current_move_action)

	current_move_action = action_name

	# กด action ใหม่ตามทิศ joystick
	if current_move_action != "":
		if current_move_action == "ui_left":
			release_action("ui_right")
		elif current_move_action == "ui_right":
			release_action("ui_left")

		press_action(current_move_action)
		notify_player_movement_deflect_input(current_move_action)
	else:
		release_action("ui_left")
		release_action("ui_right")


func notify_player_movement_deflect_input(action_name: String) -> void:
	# แจ้ง Player ว่ามีจังหวะเริ่มโยก movement ใหม่ เพื่อใช้เป็น Movement Deflect
	# Player ยังตรวจ keyboard เองด้วย ฟังก์ชันนี้ช่วยให้ touch joystick แม่นขึ้น
	var player := find_player_node()
	if player != null and player.has_method("register_movement_deflect_input"):
		var direction := 0
		if action_name == "ui_left":
			direction = -1
		elif action_name == "ui_right":
			direction = 1

		if direction != 0:
			player.register_movement_deflect_input(direction)


func notify_player_tap_deflect_input() -> void:
	# แจ้ง Player ว่าแตะ joystick แล้ว เพื่อเปิด Tap Deflect window โดยไม่ต้องเดิน
	# ต้องเรียกเฉพาะตอน touch/mouse pressed ใหม่เท่านั้น เพื่อไม่ให้แตะค้างแล้วกันฟรี
	var player := find_player_node()
	if player != null and player.has_method("register_tap_deflect_input"):
		player.register_tap_deflect_input()


func _on_joystick_gui_input(event: InputEvent) -> void:
	# รับ input จากหน้าจอสัมผัสจริงบน Android
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch

		if touch_event.pressed:
			if active_joystick_touch_index == -1:
				active_joystick_touch_index = touch_event.index
				notify_player_tap_deflect_input()
				update_virtual_joystick(touch_event.position)
				joystick_area.accept_event()
		else:
			if touch_event.index == active_joystick_touch_index:
				reset_virtual_joystick()
				joystick_area.accept_event()
		return

	# รับ input ลากนิ้วบน Android
	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag

		if drag_event.index == active_joystick_touch_index:
			update_virtual_joystick(drag_event.position)
			joystick_area.accept_event()
		return

	# รองรับ mouse สำหรับทดสอบใน editor หรือบน Mac/PC
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton

		if mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
			return

		if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
			return

		if mouse_button_event.pressed:
			is_mouse_dragging_joystick = true
			notify_player_tap_deflect_input()
			update_virtual_joystick(mouse_button_event.position)
			joystick_area.accept_event()
		else:
			if is_mouse_dragging_joystick:
				reset_virtual_joystick()
				joystick_area.accept_event()
		return

	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion

		if is_mouse_dragging_joystick:
			update_virtual_joystick(mouse_motion_event.position)
			joystick_area.accept_event()
		return


func create_touch_button(label_text: String, button_size: Vector2) -> Button:
	# สร้างปุ่มมาตรฐาน ใช้ได้ทั้ง touch และ mouse
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = button_size
	button.size = button_size
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.modulate = Color(1.0, 1.0, 1.0, button_alpha)
	button.add_theme_font_size_override("font_size", button_font_size)

	# ทำให้ปุ่มเป็นวงกลมด้วย StyleBoxFlat โดยตั้ง corner radius ให้มากกว่าครึ่งของขนาดปุ่ม
	apply_circle_button_style(button, button_size)

	return button


func apply_circle_button_style(button: Button, button_size: Vector2) -> void:
	# คำนวณ radius จากปุ่ม เพื่อให้ปุ่มดูเป็นวงกลม/แคปซูลตามขนาดจริง
	var radius: int = int(max(button_size.x, button_size.y))

	var normal_style := create_circle_style(button_fill_color, button_border_color, button_border_width, radius)
	var hover_style := create_circle_style(Color(button_fill_color.r + 0.04, button_fill_color.g + 0.04, button_fill_color.b + 0.04, button_fill_color.a), button_border_color, button_border_width, radius)
	var pressed_style := create_circle_style(button_pressed_fill_color, button_border_color, button_border_width, radius)
	var disabled_style := create_circle_style(Color(button_fill_color.r, button_fill_color.g, button_fill_color.b, 0.22), button_border_color, button_border_width, radius)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)
	button.add_theme_stylebox_override("disabled", disabled_style)


func apply_lock_button_style(is_locked: bool) -> void:
	# เปลี่ยนสีปุ่ม Lock ให้เห็นชัดว่าตอนนี้ล็อคเป้าอยู่หรือไม่
	if lock_touch_button == null:
		return

	var radius: int = int(max(action_button_size.x, action_button_size.y))

	if is_locked:
		lock_touch_button.text = "LOCKED"
		lock_touch_button.modulate.a = pressed_button_alpha
		lock_touch_button.add_theme_stylebox_override("normal", create_circle_style(lock_on_fill_color, lock_on_border_color, button_border_width, radius))
		lock_touch_button.add_theme_stylebox_override("hover", create_circle_style(lock_on_fill_color, lock_on_border_color, button_border_width, radius))
		lock_touch_button.add_theme_stylebox_override("pressed", create_circle_style(lock_on_fill_color, lock_on_border_color, button_border_width, radius))
	else:
		lock_touch_button.text = "LOCK"
		lock_touch_button.modulate.a = button_alpha
		apply_circle_button_style(lock_touch_button, action_button_size)


func create_circle_style(fill_color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	# สร้าง StyleBoxFlat ทรงวงกลม/โค้งมนสูง
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func create_round_panel(panel_name: String, panel_size: Vector2, fill_color: Color, border_color: Color, border_width: int) -> Panel:
	# สร้าง Panel ทรงกลมสำหรับใช้เป็นฐานหรือแกนกลาง joystick
	var panel := Panel.new()
	panel.name = panel_name
	panel.custom_minimum_size = panel_size
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_round_panel_style(panel, fill_color, border_color, border_width)
	return panel


func apply_round_panel_style(panel: Panel, fill_color: Color, border_color: Color, border_width: int) -> void:
	# ใส่ style ทรงกลมให้ Panel
	if panel == null:
		return

	var radius: int = int(max(panel.size.x, panel.size.y))
	panel.add_theme_stylebox_override("panel", create_circle_style(fill_color, border_color, border_width, radius))


func connect_tap_button(button: Button, action_name: String) -> void:
	# ปุ่ม action ต้องตอบสนองทันทีเมื่อแตะลง ไม่ต้องรอปล่อยนิ้ว
	button.button_down.connect(_on_tap_button_down.bind(button, action_name))
	button.button_up.connect(_on_visual_button_up.bind(button))


func connect_lock_button(button: Button) -> void:
	# ปุ่ม Lock เป็น toggle จึงไม่ใช้ trigger_action_once แบบ Attack/Dash
	button.button_down.connect(_on_lock_button_down)
	button.button_up.connect(_on_visual_button_up.bind(button))


func _on_tap_button_down(button: Button, action_name: String) -> void:
	# กัน mouse test หากปิดไว้ แต่บนมือถือยังใช้ touch ได้ผ่าน Button ปกติ
	if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
		return

	button.modulate.a = pressed_button_alpha
	trigger_action_once(action_name)


func _on_lock_button_down() -> void:
	# กดปุ่ม Lock เพื่อเปิด/ปิดการหันหน้าเข้าหา Boss
	if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
		return

	var player := find_player_node()
	if player != null and player.has_method("toggle_target_lock"):
		player.toggle_target_lock()
	else:
		# เผื่อทดสอบผ่าน keyboard หรือระบบ Input ภายนอก
		trigger_action_once("lock_on")

	update_lock_button_visual()


func _on_visual_button_up(button: Button) -> void:
	# คืนความโปร่งใสของปุ่ม action ตอนปล่อยนิ้วหรือปล่อย mouse
	if button == lock_touch_button:
		update_lock_button_visual()
		return

	button.modulate.a = button_alpha


func find_player_node() -> Node:
	# หา Player จาก parent หลักของฉาก เพื่อไม่ hardcode โครงสร้างมากเกินไป
	if get_parent() == null:
		return null

	return get_parent().get_node_or_null("Player")


func is_player_target_locked() -> bool:
	# อ่านสถานะ Lock จาก Player อย่างปลอดภัย
	var player := find_player_node()
	if player == null:
		return false

	if player.has_method("is_target_lock_active"):
		return player.is_target_lock_active()

	return false


func update_lock_button_visual() -> void:
	# อัปเดตปุ่ม Lock ให้ตรงกับสถานะจริงของ Player
	apply_lock_button_style(is_player_target_locked())


func press_action(action_name: String) -> void:
	# กด action เข้าระบบ Input เดิม ทำให้ player.gd ไม่ต้องแก้ input หลักมากเกินไป
	if not Input.is_action_pressed(action_name):
		Input.action_press(action_name)

	if not held_actions.has(action_name):
		held_actions.append(action_name)


func release_action(action_name: String) -> void:
	# ปล่อย action และเอาออกจากรายการที่กดค้าง
	if Input.is_action_pressed(action_name):
		Input.action_release(action_name)

	held_actions.erase(action_name)


func trigger_action_once(action_name: String) -> void:
	# กด action หนึ่งจังหวะ เพื่อให้ Input.is_action_just_pressed() ใน player.gd ทำงาน
	Input.action_press(action_name)
	await get_tree().physics_frame
	Input.action_release(action_name)


func release_all_touch_actions() -> void:
	# ปล่อยทุก action ที่ touch controls เคยกดไว้ กัน input ค้างตอนซ่อน UI หรือเปลี่ยน scene
	reset_virtual_joystick()

	for action_name in held_actions.duplicate():
		if Input.is_action_pressed(action_name):
			Input.action_release(action_name)
		held_actions.erase(action_name)

	if attack_touch_button != null:
		attack_touch_button.modulate.a = button_alpha
	if dash_touch_button != null:
		dash_touch_button.modulate.a = button_alpha
	if lock_touch_button != null:
		update_lock_button_visual()


func _exit_tree() -> void:
	# กัน input ค้าง หากเปลี่ยน scene ระหว่างกดปุ่มอยู่
	release_all_touch_actions()
