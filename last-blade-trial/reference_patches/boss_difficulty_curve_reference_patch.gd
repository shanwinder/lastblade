extends "res://boss_difficulty_curve_manager.gd"

# =========================
# BossDifficultyCurveReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ BossDifficultyCurveManager
# ไม่เปลี่ยนค่า phase/chance ของบอส
# =========================


func find_boss() -> void:
	# หา Boss จาก path ก่อน
	var found_boss = get_node_or_null(boss_path)
	if found_boss != null:
		boss = found_boss
		return

	# ถ้าไม่เจอ ให้หา Boss จาก group combat_target
	var boss_nodes := get_tree().get_nodes_in_group("combat_target")
	if boss_nodes.size() > 0:
		boss = boss_nodes[0]
		return

	# fallback แบบเดิม สำหรับ scene flat ปัจจุบัน
	if get_parent() == null:
		return

	boss = get_parent().get_node_or_null("BossBrokenMaster")
