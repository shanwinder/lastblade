extends "res://keyboard_tap_deflect_manager.gd"

# =========================
# KeyboardTapDeflectReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ KeyboardTapDeflectManager
# ไม่เปลี่ยน input philosophy: D คือ Tap Deflect หลักบนคีย์บอร์ด
# =========================


func setup_references() -> void:
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
