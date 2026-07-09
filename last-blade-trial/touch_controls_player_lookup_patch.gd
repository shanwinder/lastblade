extends "res://touch_controls.gd"

# =========================
# TouchControlsPlayerLookupPatch.gd
# Patch สำหรับ Step 3: ทำให้ TouchControls หา Player แบบ robust
# Patch เพิ่มเติม: ทำให้ปุ่ม Attack รองรับการกดค้างสำหรับ Charged Heavy Attack
# =========================

# อ้างอิง Player จาก Inspector เป็นทางเลือกแรก
@export var player_path: NodePath = NodePath("../Player")


func connect_tap_button(button: Button, action_name: String) -> void:
	# Attack ต้องรองรับ hold เพื่อให้ Player แยก Tap Combo กับ Charged Heavy Attack ได้
	# Dash ยังใช้ tap one-shot เดิม ส่วน Lock ใช้ connect_lock_button() แยกอยู่แล้ว
	if action_name == "attack":
		connect_attack_hold_button(button)
		return

	super.connect_tap_button(button, action_name)


func connect_attack_hold_button(button: Button) -> void:
	# ปุ่ม Attack ต้องส่ง press ตอนแตะลง และ release ตอนปล่อยนิ้วจริง
	button.button_down.connect(_on_attack_hold_button_down.bind(button))
	button.button_up.connect(_on_attack_hold_button_up.bind(button))


func _on_attack_hold_button_down(button: Button) -> void:
	# กัน mouse test หากปิดไว้ แต่บนมือถือยังใช้ touch ได้ผ่าน Button ปกติ
	if not allow_mouse_test and not DisplayServer.is_touchscreen_available():
		return

	button.modulate.a = pressed_button_alpha
	press_action("attack")


func _on_attack_hold_button_up(button: Button) -> void:
	# ปล่อย action attack เมื่อปล่อยนิ้ว เพื่อให้ Player ตรวจ Input.is_action_just_released() ได้
	release_action("attack")
	button.modulate.a = button_alpha


func find_player_node() -> Node:
	# 1) หา Player จาก exported NodePath ก่อน เพื่อให้ปรับใน Inspector ได้
	var found_player = get_node_or_null(player_path)
	if found_player != null:
		return found_player

	# 2) หา Player จาก group identity ใหม่ของ Step 2
	var player_nodes := get_tree().get_nodes_in_group("player_actor")
	if player_nodes.size() > 0:
		return player_nodes[0]

	# 3) fallback แบบเดิม เพื่อให้ scene flat ปัจจุบันยังทำงานเหมือนเดิม
	if get_parent() != null:
		return get_parent().get_node_or_null("Player")

	return null
