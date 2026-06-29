extends CanvasLayer

# =========================
# TouchControls.gd
# ปุ่มควบคุมมือถือแบบ prototype สำหรับ Phase 6.6
# สร้างด้วยโค้ดทั้งหมด เพื่อยังไม่ต้องใช้ asset ปุ่มจริง
# เวอร์ชันนี้เพิ่ม responsive layout เพื่อเตรียมทดสอบบน Android หลายขนาดจอ
# =========================

# เปิด/ปิด touch controls ทั้งชุด
@export var touch_controls_enabled: bool = true

# เปิดให้ใช้ mouse click ทดสอบบน Mac/PC ได้
@export var allow_mouse_test: bool = true

# เปิด/ปิดการจัดตำแหน่งปุ่มใหม่เมื่อขนาดจอเปลี่ยน
@export var responsive_layout_enabled: bool = true

# ความโปร่งใสของปุ่มปกติ
@export var button_alpha: float = 0.52

# ความโปร่งใสของปุ่มตอนกด
@export var pressed_button_alpha: float = 0.82

# ขนาดปุ่มเดินซ้าย/ขวา
@export var move_button_size: Vector2 = Vector2(96.0, 96.0)

# ขนาดปุ่ม Attack ซึ่งควรใหญ่และกดง่ายที่สุด
@export var attack_button_size: Vector2 = Vector2(124.0, 124.0)

# ขนาดปุ่ม Dash และ Parry
@export var action_button_size: Vector2 = Vector2(96.0, 96.0)

# ระยะห่างจากขอบจอ
@export var screen_margin: float = 28.0

# ระยะห่างระหว่างปุ่มเดินซ้าย/ขวา
@export var move_button_gap: float = 16.0

# ระยะห่างระหว่างปุ่ม action ฝั่งขวา
@export var action_button_gap: float = 18.0

# ระยะเผื่อด้านล่างสำหรับมือถือที่มีแถบนำทางหรือขอบจอหนา
@export var mobile_bottom_safe_margin: float = 0.0

# ขนาดตัวอักษรบนปุ่ม
@export var button_font_size: int = 20

# สีพื้นปุ่มปกติ
@export var button_fill_color: Color = Color(0.07, 0.09, 0.12, 0.52)

# สีพื้นปุ่มตอนกด
@export var button_pressed_fill_color: Color = Color(0.20, 0.42, 0.55, 0.82)

# สีเส้นขอบปุ่ม
@export var button_border_color: Color = Color(0.75, 0.95, 1.0, 0.85)

# ความหนาเส้นขอบปุ่ม
@export var button_border_width: int = 3

# Root control ที่คลุมทั้งจอ
var root_control: Control = null

# ปุ่มควบคุมจริง เก็บไว้เพื่อจัดตำแหน่งใหม่เมื่อขนาดจอเปลี่ยน
var left_move_button: Button = null
var right_move_button: Button = null
var attack_touch_button: Button = null
var dash_touch_button: Button = null
var parry_touch_button: Button = null

# จำขนาดจอล่าสุด เพื่อรู้ว่าควรจัด layout ใหม่หรือไม่
var last_screen_size: Vector2 = Vector2.ZERO

# รายชื่อ action ที่กดค้างอยู่ เพื่อปล่อยตอนปิด scene กัน input ค้าง
var held_actions: Array[String] = []


func _ready() -> void:
	# ถ้าปิด touch controls ไว้ ไม่ต้องสร้าง UI
	if not touch_controls_enabled:
		return

	# สร้าง UI หลัง viewport พร้อม เพื่อให้คำนวณตำแหน่งปุ่มได้ถูกต้อง
	create_touch_ui.call_deferred()


func _process(_delta: float) -> void:
	# ถ้าเปิด responsive layout ให้ตรวจขนาดจอ และจัดปุ่มใหม่เมื่อ viewport เปลี่ยน
	if not responsive_layout_enabled:
		return

	if root_control == null:
		return

	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	if screen_size.distance_squared_to(last_screen_size) > 1.0:
		layout_touch_buttons()


func create_touch_ui() -> void:
	# สร้าง root control สำหรับวางปุ่มทั้งหมด
	root_control = Control.new()
	root_control.name = "TouchControlsRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	# ปุ่มเดินฝั่งซ้าย
	left_move_button = create_touch_button("◀", move_button_size)
	root_control.add_child(left_move_button)
	connect_hold_button(left_move_button, "ui_left")

	right_move_button = create_touch_button("▶", move_button_size)
	root_control.add_child(right_move_button)
	connect_hold_button(right_move_button, "ui_right")

	# ปุ่ม Attack ฝั่งขวา ใหญ่ที่สุดและอยู่ตำแหน่งนิ้วโป้งกดง่าย
	attack_touch_button = create_touch_button("ATTACK", attack_button_size)
	root_control.add_child(attack_touch_button)
	connect_tap_button(attack_touch_button, "attack")

	# ปุ่ม Dash วางเหนือซ้ายของ Attack เพื่อไม่ชิด Parry เกินไป
	dash_touch_button = create_touch_button("DASH", action_button_size)
	root_control.add_child(dash_touch_button)
	connect_tap_button(dash_touch_button, "dash")

	# ปุ่ม Parry วางเหนือ Attack เพื่อให้กดตอบสนองเร็ว แต่ไม่บัง Boss hint กลางจอ
	parry_touch_button = create_touch_button("PARRY", action_button_size)
	root_control.add_child(parry_touch_button)
	connect_tap_button(parry_touch_button, "parry")

	layout_touch_buttons()
	print("TouchControls ready. Mouse test =", allow_mouse_test, "Responsive =", responsive_layout_enabled)


func layout_touch_buttons() -> void:
	# จัดตำแหน่งปุ่มตามขนาด viewport ปัจจุบัน ใช้ได้ทั้ง editor และ Android
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	last_screen_size = screen_size

	if root_control != null:
		root_control.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bottom_margin: float = screen_margin + mobile_bottom_safe_margin

	# ปุ่มเดินซ้าย/ขวาอยู่มุมซ้ายล่าง
	set_button_rect(
		left_move_button,
		Vector2(screen_margin, screen_size.y - bottom_margin - move_button_size.y),
		move_button_size,
		screen_size
	)

	set_button_rect(
		right_move_button,
		Vector2(screen_margin + move_button_size.x + move_button_gap, screen_size.y - bottom_margin - move_button_size.y),
		move_button_size,
		screen_size
	)

	# ปุ่ม Attack อยู่มุมขวาล่าง และใหญ่สุด
	set_button_rect(
		attack_touch_button,
		Vector2(screen_size.x - screen_margin - attack_button_size.x, screen_size.y - bottom_margin - attack_button_size.y),
		attack_button_size,
		screen_size
	)

	# ปุ่ม Dash อยู่ซ้ายของ Attack เพื่อให้แยกจาก Parry ชัดเจน
	set_button_rect(
		dash_touch_button,
		Vector2(screen_size.x - screen_margin - attack_button_size.x - action_button_size.x - action_button_gap, screen_size.y - bottom_margin - action_button_size.y),
		action_button_size,
		screen_size
	)

	# ปุ่ม Parry อยู่เหนือ Attack เพื่อให้กดสวนจังหวะบอสได้เร็ว
	set_button_rect(
		parry_touch_button,
		Vector2(screen_size.x - screen_margin - action_button_size.x, screen_size.y - bottom_margin - attack_button_size.y - action_button_size.y - action_button_gap),
		action_button_size,
		screen_size
	)


func set_button_rect(button: Button, desired_position: Vector2, button_size: Vector2, screen_size: Vector2) -> void:
	# ตั้งขนาดและตำแหน่งปุ่ม พร้อม clamp ไม่ให้หลุดออกนอกจอในเครื่องที่ viewport เล็ก
	if button == null:
		return

	button.custom_minimum_size = button_size
	button.size = button_size
	button.position = clamp_button_position(desired_position, button_size, screen_size)


func clamp_button_position(desired_position: Vector2, button_size: Vector2, screen_size: Vector2) -> Vector2:
	# กันปุ่มหลุดขอบจอ โดยยังรักษา margin ให้มากที่สุดเท่าที่ทำได้
	var max_x: float = max(screen_margin, screen_size.x - screen_margin - button_size.x)
	var max_y: float = max(screen_margin, screen_size.y - screen_margin - button_size.y)

	return Vector2(
		clamp(desired_position.x, screen_margin, max_x),
		clamp(desired_position.y, screen_margin, max_y)
	)


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

	var normal_style := create_circle_style(button_fill_color, radius)
	var hover_style := create_circle_style(Color(button_fill_color.r + 0.04, button_fill_color.g + 0.04, button_fill_color.b + 0.04, button_fill_color.a), radius)
	var pressed_style := create_circle_style(button_pressed_fill_color, radius)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)
	tbutton_disabled_style_if_needed(button, radius)


func tbutton_disabled_style_if_needed(button: Button, radius: int) -> void:
	# ใส่ style disabled เผื่ออนาคตมีการปิดปุ่ม จะได้ยังเป็นทรงเดียวกัน
	var disabled_color := Color(button_fill_color.r, button_fill_color.g, button_fill_color.b, 0.22)
	button.add_theme_stylebox_override("disabled", create_circle_style(disabled_color, radius))


func create_circle_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	# สร้าง StyleBoxFlat ทรงวงกลม/โค้งมนสูง
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = button_border_color
	style.set_border_width_all(button_border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func connect_hold_button(button: Button, action_name: String) -> void:
	# ปุ่มเดินต้องกดค้างได้ จึงใช้ button_down/button_up
	button.button_down.connect(_on_hold_button_down.bind(button, action_name))
	button.button_up.connect(_on_hold_button_up.bind(button, action_name))


func connect_tap_button(button: Button, action_name: String) -> void:
	# ปุ่ม action ต้องตอบสนองทันทีเมื่อแตะลง ไม่ต้องรอปล่อยนิ้ว
	button.button_down.connect(_on_tap_button_down.bind(button, action_name))
	button.button_up.connect(_on_visual_button_up.bind(button))


func _on_hold_button_down(button: Button, action_name: String) -> void:
	# กัน mouse test หากปิดไว้ แต่บนมือถือยังใช้ touch ได้ผ่าน Button ปกติ
	if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
		return

	press_action(action_name)
	button.modulate.a = pressed_button_alpha


func _on_hold_button_up(button: Button, action_name: String) -> void:
	# ปล่อย action เมื่อปล่อยปุ่มเดิน
	release_action(action_name)
	button.modulate.a = button_alpha


func _on_tap_button_down(button: Button, action_name: String) -> void:
	# กัน mouse test หากปิดไว้ แต่บนมือถือยังใช้ touch ได้ผ่าน Button ปกติ
	if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
		return

	button.modulate.a = pressed_button_alpha
	trigger_action_once(action_name)


func _on_visual_button_up(button: Button) -> void:
	# คืนความโปร่งใสของปุ่ม action ตอนปล่อยนิ้วหรือปล่อย mouse
	button.modulate.a = button_alpha


func press_action(action_name: String) -> void:
	# กด action เข้าระบบ Input เดิม ทำให้ player.gd ไม่ต้องแก้
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


func _exit_tree() -> void:
	# กัน input ค้าง หากเปลี่ยน scene ระหว่างกดปุ่มอยู่
	for action_name in held_actions:
		if Input.is_action_pressed(action_name):
			Input.action_release(action_name)

	held_actions.clear()
