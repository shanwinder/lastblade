extends "res://combat_decay_manager.gd"

# =========================
# CombatDecayReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ CombatDecayManager
# ไม่เปลี่ยนค่า decay/recovery ใด ๆ
# =========================


func find_combat_nodes() -> void:
	# หา Player: path → group → parent fallback
	if not is_instance_valid(player):
		player = get_node_or_null(player_path)
		if player == null:
			var player_nodes := get_tree().get_nodes_in_group("player_actor")
			if player_nodes.size() > 0:
				player = player_nodes[0]
		if player == null and get_parent() != null:
			player = get_parent().get_node_or_null("Player")

	# หา Boss: path → combat_target group → parent fallback
	if not is_instance_valid(boss):
		boss = get_node_or_null(boss_path)
		if boss == null:
			var boss_nodes := get_tree().get_nodes_in_group("combat_target")
			if boss_nodes.size() > 0:
				boss = boss_nodes[0]
		if boss == null and get_parent() != null:
			boss = get_parent().get_node_or_null("BossBrokenMaster")

	# ตั้งค่าเริ่มต้นของตัวแปรจำค่า เพื่อไม่ให้ frame แรกเข้าใจผิดว่าเกิดการเปลี่ยนแปลง
	if is_instance_valid(boss):
		last_boss_posture = get_float_value(boss, "current_posture", last_boss_posture)
		last_boss_hp = get_int_value(boss, "current_hp", last_boss_hp)
		last_emitted_boss_posture_int = int(round(last_boss_posture))

	if is_instance_valid(player):
		last_player_focus = get_float_value(player, "current_focus", last_player_focus)
		last_emitted_player_focus_int = int(round(last_player_focus))
