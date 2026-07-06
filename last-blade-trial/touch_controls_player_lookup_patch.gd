extends "res://touch_controls.gd"

# =========================
# TouchControlsPlayerLookupPatch.gd
# Patch สำหรับ Step 3: ทำให้ TouchControls หา Player แบบ robust
# ลำดับการหา: exported NodePath → group player_actor → parent/name fallback
# ไม่เปลี่ยน input behavior ของปุ่มมือถือ
# =========================

# อ้างอิง Player จาก Inspector เป็นทางเลือกแรก
@export var player_path: NodePath = NodePath("../Player")


func find_player_node() -> Node:
	# 1) หา Player จาก exported NodePath ก่อน เพื่อให้ปรับใน Inspector ได้
	var found_player = get_node_or_null(player_path)
	if found_player != null:
		return found_player

	# 2) หา Player จาก group identity ใหม่ของ Step 2
	var player_nodes := get_tree().get_nodes_in_group("player_actor")
	if player_nodes.size() > 0:
		return player_nodes[0]

	# 3) fallback แบบเดิม เพื่อให้ scene flat ปัจจุบันยังทำงานเหมือนเดิม
	if get_parent() != null:
		return get_parent().get_node_or_null("Player")

	return null
