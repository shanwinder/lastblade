extends CanvasLayer

# =========================
# TouchControls.gd
# ปุ่มควบคุมมือถือแบบ prototype สำหรับ Phase 6.6
# สร้างด้วยโค้ดทั้งหมด เพื่อยังไม่ต้องใช้ asset ปุ่มจริง
# =========================

# เปิด/ปิด touch controls ทั้งชุด
@export var touch_controls_enabled: bool = true

# เปิดให้ใช้ mouse click ทดสอบบน Mac/PC ได้
@export var allow_mouse_test: bool = true

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

# รายชื่อ action ที่กดค้างอยู่ เพื่อปล่อยตอนปิด scene กัน input ค้าง
var held_actions: Array[String] = []


func _ready() -> void:
	# ถ้าปิด touch controls ไว้ ไม่ต้องสร้าง UI
	if not touch_controls_enabled:
		return

	# สร้าง UI หลัง viewport พร้อม เพื่อให้คำนวณตำแหน่งปุ่มได้ถูกต้อง
	create_touch_ui.call_deferred()


func create_touch_ui() -> void:
	# สร้าง root control สำหรับวางปุ่มทั้งหมด
	root_control = Control.new()
	root_control.name = "TouchControlsRoot"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	# อ่านขนาดจอปัจจุบัน ใช้ได้ทั้ง editor และมือถือ
	var screen_size: Vector2 = get_viewport().get_visible_rect().size

	# ปุ่มเดินฝั่งซ้าย
	var left_button := create_touch_button("◀", move_button_size)
	left_button.position = Vector2(screen_margin, screen_size.y - screen_margin - move_button_size.y)
	root_control.add_child(left_button)
	connect_hold_button(left_button, "ui_left")

	var right_button := create_touch_button("▶", move_button_size)
	right_button.position = Vector2(screen_margin + move_button_size.x + 16.0, screen_size.y - screen_margin - move_button_size.y)
	root_control.add_child(right_button)
	connect_hold_button(right_button, "ui_right")

	# ปุ่ม Attack ฝั่งขวา ใหญ่ที่สุดและอยู่ตำแหน่งนิ้วโป้งกดง่าย
	var attack_button := create_touch_button("ATTACK", attack_button_size)
	attack_button.position = Vector2(screen_size.x - screen_margin - attack_button_size.x, screen_size.y - screen_margin - attack_button_size.y)
	root_control.add_child(attack_button)
	connect_tap_button(attack_button, "attack")

	# ปุ่ม Dash วางเหนือซ้ายของ Attack เพื่อไม่ชิด Parry เกินไป
	var dash_button := create_touch_button("DASH", action_button_size)
	dash_button.position = Vector2(screen_size.x - screen_margin - attack_button_size.x - action_button_size.x - 18.0, screen_size.y - screen_margin - action_button_size.y)
	root_control.add_child(dash_button)
	connect_tap_button(dash_button, "dash")

	# ปุ่ม Parry วางเหนือ Attack เพื่อให้กดตอบสนองเร็ว แต่ไม่บัง Boss hint กลางจอ
	var parry_button := create_touch_button("PARRY", action_button_size)
	parry_button.position = Vector2(screen_size.x - screen_margin - action_button_size.x, screen_size.y - screen_margin - attack_button_size.y - action_button_size.y - 18.0)
	root_control.add_child(parry_button)
	connect_tap_button(parry_button, "parry")

	print("TouchControls ready. Mouse test =", allow_mouse_test)


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
