extends "res://movement_deflect_balance_manager.gd"

# =========================
# MovementDeflectBalanceReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ MovementDeflectBalanceManager
# ไม่เปลี่ยนค่า stamina/cooldown/balance ใด ๆ
# =========================


func setup_references() -> void:
	# หา Player จาก NodePath ก่อน
	player = get_node_or_null(player_path)

	# ถ้าไม่เจอ ให้หา Player จาก group identity ใหม่
	if player == null:
		var player_nodes := get_tree().get_nodes_in_group("player_actor")
		if player_nodes.size() > 0:
			player = player_nodes[0]

	# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
	if player == null and get_parent() != null:
		player = get_parent().get_node_or_null("Player")
