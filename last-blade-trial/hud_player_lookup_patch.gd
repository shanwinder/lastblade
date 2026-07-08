extends "res://HUD.gd"

# =========================
# HUDPlayerLookupPatch.gd
# Patch สำหรับ Step 3: ทำให้ HUD หา Player แบบ robust
# ลำดับการหา: exported NodePath → group player_actor → parent/name fallback
# ไม่เปลี่ยน logic การแสดงผล HUD และไม่ย้าย Node ใด ๆ
# =========================

# อ้างอิง Player จาก Inspector เป็นทางเลือกแรก
@export var player_path: NodePath = NodePath("../Player")


func _ready() -> void:
	# กันกรณี reload scene ตอนเกมกำลัง Hit Stop
	# ให้เริ่มฉากใหม่ด้วยความเร็วปกติเสมอ
	Engine.time_scale = 1.0

	# สร้าง Player Posture UI เพิ่มด้วยโค้ดเหมือน HUD.gd เดิม
	create_player_posture_widgets()

	# ย้ายหลอด HP/Posture ของบอสไปไว้ด้านขวาบน
	# สำคัญ: scene หลักใช้ patch นี้ ไม่ได้ใช้ _ready() ของ HUD.gd โดยตรง
	create_enemy_hud_top_right()

	# หา Player แบบ robust เพื่อรองรับการจัดกลุ่ม Node ในอนาคต
	var player = find_player_node_robust()
	if player == null:
		print("HUD ERROR: Player node not found by path, group, or fallback")
		return

	# หา Enemy หรือ Boss อัตโนมัติด้วย logic เดิมของ HUD.gd
	var enemy = find_combat_target()
	if enemy == null:
		return

	# ตั้งชื่อที่ HUD จะใช้แสดง เช่น Boss หรือ Enemy
	update_combat_target_display_name(enemy)

	# อ่านชื่อที่ target อยากให้ HUD แสดง
	var display_name = enemy.get("combat_display_name")
	if display_name != null and str(display_name).strip_edges() != "":
		combat_target_display_name = str(display_name).strip_edges()
	elif "Boss" in enemy.name:
		combat_target_display_name = "Boss"
	else:
		combat_target_display_name = "Enemy"

	# เชื่อม signal จาก Player มายัง HUD
	player.stats_changed.connect(update_player_stats)

	# เชื่อม signal จาก Enemy หรือ Boss มายัง HUD
	enemy.enemy_stats_changed.connect(update_enemy_stats)

	# เชื่อม signal คำเตือนท่าศัตรู ถ้ามี
	if enemy.has_signal("enemy_attack_hint_changed"):
		enemy.enemy_attack_hint_changed.connect(update_attack_hint)

	# เชื่อม signal เมื่อตัวละครผู้เล่นตาย
	player.player_died.connect(show_game_over)

	# เชื่อม signal เมื่อศัตรูตาย
	enemy.enemy_died.connect(show_victory)

	# ซ่อนข้อความผลลัพธ์ตอนเริ่มเกม เพราะ GameLoopManager เป็นคนแสดง overlay หลัก
	game_result_label.text = ""

	# สร้าง Label สำหรับคำเตือนท่าศัตรูแบบ fallback
	create_attack_hint_label()

	# อ่านค่า Player Posture แบบปลอดภัย เผื่อเปิด scene เก่าที่ยังไม่มีตัวแปรนี้
	var current_posture := 100.0
	var max_posture := 100.0
	var player_current_posture_value = player.get("current_player_posture")
	var player_max_posture_value = player.get("max_player_posture")

	if player_current_posture_value != null:
		current_posture = float(player_current_posture_value)
	if player_max_posture_value != null:
		max_posture = float(player_max_posture_value)

	update_player_stats(
		player.current_hp,
		player.max_hp,
		player.current_stamina,
		player.max_stamina,
		player.current_focus,
		player.max_focus,
		current_posture,
		max_posture
	)

	# อัปเดต HUD ของ Enemy ครั้งแรกตอนเริ่มเกม
	update_enemy_stats(enemy.current_hp, enemy.max_hp, enemy.current_posture, enemy.max_posture)


func create_enemy_hud_top_right() -> void:
	# สร้างกล่องใหม่สำหรับ Boss HP/Posture ที่มุมขวาบน
	# ใช้ใน patch นี้โดยตรง เพราะ scene หลักผูก script เป็น hud_player_lookup_patch.gd
	if enemy_hud_container != null and is_instance_valid(enemy_hud_container):
		return

	var control_root := get_node_or_null("Control") as Control
	if control_root == null:
		print("HUD ERROR: Control root not found for enemy HUD")
		return

	enemy_hud_container = VBoxContainer.new()
	enemy_hud_container.name = "EnemyHUDTopRight"
	enemy_hud_container.custom_minimum_size = Vector2(280.0, 92.0)
	enemy_hud_container.position = Vector2(660.0, 20.0)
	enemy_hud_container.add_theme_constant_override("separation", 4)
	control_root.add_child(enemy_hud_container)

	# ย้าย node เดิมออกจาก VBoxContainer ซ้าย ไปอยู่กล่องขวาบน
	# ต้อง remove_child ก่อน add_child เพราะ node เดิมมี parent อยู่แล้ว
	reparent_enemy_hud_control(enemy_hp_label)
	reparent_enemy_hud_control(enemy_hp_bar)
	reparent_enemy_hud_control(enemy_posture_label)
	reparent_enemy_hud_control(enemy_posture_bar)

	# ปรับขนาดหลอดบอสให้เหมาะกับมุมขวาบน
	enemy_hp_bar.custom_minimum_size = Vector2(280.0, 18.0)
	enemy_posture_bar.custom_minimum_size = Vector2(280.0, 18.0)

	# จัดข้อความให้อ่านจากขวาบนได้ชัด
	enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_posture_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	print("HUD boss bars moved to top-right")


func reparent_enemy_hud_control(control_node: Control) -> void:
	# ย้าย Control เดิมอย่างปลอดภัย โดยไม่สร้าง node ใหม่
	# ทำให้ signal/update_enemy_stats() ยังอัปเดตหลอดเดิมต่อได้
	if control_node == null:
		return

	if control_node.get_parent() == enemy_hud_container:
		return

	var old_parent := control_node.get_parent()
	if old_parent != null:
		old_parent.remove_child(control_node)

	enemy_hud_container.add_child(control_node)


func find_player_node_robust():
	# 1) หา Player จาก exported NodePath ก่อน เพื่อให้ Inspector override ได้
	var found_player = get_node_or_null(player_path)
	if found_player != null:
		return found_player

	# 2) หา Player จาก group identity ใหม่ของ Step 2
	var player_nodes := get_tree().get_nodes_in_group("player_actor")
	if player_nodes.size() > 0:
		return player_nodes[0]

	# 3) fallback แบบเดิม เพื่อให้ scene ปัจจุบันยังทำงานแม้ยังไม่ได้ย้าย Node
	if get_parent() != null:
		return get_parent().get_node_or_null("Player")

	return null