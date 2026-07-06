extends "res://boss_grab_balance_manager.gd"

# =========================
# BossGrabBalanceReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ BossGrabBalanceManager
# ไม่เปลี่ยน chance, timing, damage หรือ anti-repetition balance
# =========================


func setup_references() -> void:
	# หา Player: path → group → parent fallback
	player = get_node_or_null(player_path) as Node2D
	if player == null:
		var player_nodes := get_tree().get_nodes_in_group("player_actor")
		for node in player_nodes:
			if node is Node2D:
				player = node as Node2D
				break
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player") as Node2D

	# หา Boss: path → combat_target group → parent fallback
	boss = get_node_or_null(boss_path)
	if boss == null:
		var boss_nodes := get_tree().get_nodes_in_group("combat_target")
		if boss_nodes.size() > 0:
			boss = boss_nodes[0]
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา GameLoopManager แบบ optional: path → group → parent fallback
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null:
		var loop_nodes := get_tree().get_nodes_in_group("game_loop_manager")
		if loop_nodes.size() > 0:
			game_loop_manager = loop_nodes[0]
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")

	# หา Duel1DummyManager แบบ optional: path → group → parent fallback
	duel_1_manager = get_node_or_null(duel_1_manager_path)
	if duel_1_manager == null:
		var duel_nodes := get_tree().get_nodes_in_group("duel_1_manager")
		if duel_nodes.size() > 0:
			duel_1_manager = duel_nodes[0]
	if duel_1_manager == null and get_parent() != null:
		duel_1_manager = get_parent().get_node_or_null("Duel1DummyManager")
