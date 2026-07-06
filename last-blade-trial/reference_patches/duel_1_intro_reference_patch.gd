extends "res://duel_1_intro_manager.gd"

# =========================
# Duel1IntroReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ Duel1IntroManager
# ไม่เปลี่ยน logic freeze-frame practice
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

	# หา TrainingCoachManager: path → group → parent fallback
	training_coach_manager = get_node_or_null(training_coach_manager_path)
	if training_coach_manager == null:
		var training_nodes := get_tree().get_nodes_in_group("training_coach_manager")
		if training_nodes.size() > 0:
			training_coach_manager = training_nodes[0]
	if training_coach_manager == null and get_parent() != null:
		training_coach_manager = get_parent().get_node_or_null("TrainingCoachManager")
