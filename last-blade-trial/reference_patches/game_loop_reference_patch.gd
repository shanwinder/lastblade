extends "res://game_loop_manager.gd"

# =========================
# GameLoopReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ GameLoopManager
# ลำดับการหา: exported NodePath → group identity → parent/name fallback
# ไม่เปลี่ยนสถานะเกม Start/Victory/Defeat/Upgrade
# =========================


func find_scene_nodes() -> void:
	# หา Player จาก path ก่อน
	player = get_node_or_null(player_path)

	# ถ้าไม่เจอ ให้หา Player จาก group identity ใหม่
	if player == null:
		var player_nodes := get_tree().get_nodes_in_group("player_actor")
		if player_nodes.size() > 0:
			player = player_nodes[0]

	# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")

	# หา Boss จาก path ก่อน
	boss = get_node_or_null(boss_path)

	# ถ้าไม่เจอ ให้หา Boss จาก group combat_target
	if boss == null:
		var boss_nodes := get_tree().get_nodes_in_group("combat_target")
		if boss_nodes.size() > 0:
			boss = boss_nodes[0]

	# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา TouchControls จาก path ก่อน
	var touch_node = get_node_or_null(touch_controls_path)
	if touch_node is CanvasLayer:
		touch_controls = touch_node as CanvasLayer
	else:
		# ถ้าไม่เจอ ให้หา TouchControls จาก group identity ใหม่
		var touch_nodes := get_tree().get_nodes_in_group("touch_controls")
		for node in touch_nodes:
			if node is CanvasLayer:
				touch_controls = node as CanvasLayer
				break

		# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
		if touch_controls == null and get_parent() != null:
			touch_node = get_parent().get_node_or_null("TouchControls")
			if touch_node is CanvasLayer:
				touch_controls = touch_node as CanvasLayer
