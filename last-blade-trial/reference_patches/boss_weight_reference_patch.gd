extends "res://boss_weight_manager.gd"

# =========================
# BossWeightReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ BossWeightManager
# ไม่เปลี่ยน logic boss weight / recoil / posture response
# =========================


func setup_references() -> void:
	# หา Boss: path → combat_target group → parent fallback
	boss = get_node_or_null(boss_path)
	if boss == null:
		var boss_nodes := get_tree().get_nodes_in_group("combat_target")
		if boss_nodes.size() > 0:
			boss = boss_nodes[0]
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา Player: path → player_actor group → parent fallback
	player = get_node_or_null(player_path) as Node2D
	if player == null:
		var player_nodes := get_tree().get_nodes_in_group("player_actor")
		for node in player_nodes:
			if node is Node2D:
				player = node as Node2D
				break
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player") as Node2D

	# ตั้งค่าเริ่มต้นเมื่อหา boss ได้
	if is_instance_valid(boss) and previous_hp < 0:
		previous_hp = get_int_value(boss, "current_hp", 0)
		was_posture_broken = get_bool_value(boss, "is_posture_broken")
