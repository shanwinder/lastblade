extends "res://training_coach_manager.gd"

# =========================
# TrainingCoachReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ TrainingCoachManager
# ไม่เปลี่ยนลำดับ tutorial หรือข้อความสอน
# =========================


func setup_references() -> void:
	# หา Player: path → group → parent fallback
	player = get_node_or_null(player_path)
	if player == null:
		var player_nodes := get_tree().get_nodes_in_group("player_actor")
		if player_nodes.size() > 0:
			player = player_nodes[0]
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")

	# หา Boss: path → combat_target group → parent fallback
	boss = get_node_or_null(boss_path)
	if boss == null:
		var boss_nodes := get_tree().get_nodes_in_group("combat_target")
		if boss_nodes.size() > 0:
			boss = boss_nodes[0]
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา GameLoopManager: path → group → parent fallback
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null:
		var loop_nodes := get_tree().get_nodes_in_group("game_loop_manager")
		if loop_nodes.size() > 0:
			game_loop_manager = loop_nodes[0]
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")
