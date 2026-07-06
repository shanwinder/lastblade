extends "res://player_attack_vfx_manager.gd"

# =========================
# PlayerAttackVFXReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ PlayerAttackVFXManager
# ไม่เปลี่ยนตำแหน่ง/รูปแบบ VFX ในรอบนี้
# หมายเหตุ: VFX ยัง add_child ใต้ parent ปัจจุบันเหมือนเดิม
# =========================


func find_player() -> void:
	# หา Player จาก NodePath ก่อน
	var found_player = get_node_or_null(player_path)
	if found_player is Node2D:
		player = found_player as Node2D
		return

	# ถ้าไม่เจอ ให้หา Player จาก group identity ใหม่
	var player_nodes := get_tree().get_nodes_in_group("player_actor")
	for node in player_nodes:
		if node is Node2D:
			player = node as Node2D
			return

	# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
	if get_parent() == null:
		return

	found_player = get_parent().get_node_or_null("Player")
	if found_player is Node2D:
		player = found_player as Node2D
