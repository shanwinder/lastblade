extends "res://BossBrokenMaster.gd"

# =========================
# BossBrokenMasterPlayerLookupPatch.gd
# Patch สำหรับ Step 3: ทำให้ Boss หา Player แบบ robust
# ลำดับการหา: exported NodePath → group player_actor → parent/name fallback
# ไม่เปลี่ยน pattern, timing, damage หรือ balance ของ Boss
# =========================

# อ้างอิง Player จาก Inspector เป็นทางเลือกแรก
@export var player_path: NodePath = NodePath("../Player")


func _ready() -> void:
	# สุ่มค่าเริ่มต้น เพื่อให้ pattern ไม่ซ้ำแบบเดิมทุกครั้งที่เปิดเกม
	randomize()

	# เพิ่มบอสเข้า group combat_target เพื่อให้ HUD หาเป้าหมายหลักได้
	add_to_group("combat_target")

	# ตั้ง collision layer/mask ของบอส
	collision_layer = ENEMY_BODY_LAYER
	collision_mask = ENEMY_NORMAL_COLLISION_MASK

	# หา ArenaManager จาก group ถ้ามี
	var arena_nodes := get_tree().get_nodes_in_group("arena_manager")
	if arena_nodes.size() > 0:
		arena_manager = arena_nodes[0]
		print("Boss found ArenaManager")
	else:
		print("Boss using fallback arena bounds")

	# ตั้งค่า HP และ Posture เริ่มต้น
	current_hp = max_hp
	current_posture = max_posture

	# หา Player แบบ robust เพื่อรองรับการจัดกลุ่ม Node ในอนาคต
	player = find_player_node_robust()
	if player == null:
		print("Boss ERROR: Player node not found by path, group, or fallback")

	# ปิด hitbox ไว้ก่อน เพราะบอสยังไม่โจมตี
	attack_shape.disabled = true

	# วาง hitbox ไว้ด้านหน้าบอสตามทิศเริ่มต้น
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)

	# เชื่อมสัญญาณเมื่อ hitbox บอสชน Area2D อื่น
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)

	# สร้างข้อความเตือนเหนือหัวบอส
	create_boss_hint_label()

	print("Boss Broken Master ready. HP =", current_hp)

	# แจ้ง HUD ให้แสดงค่าบอสเริ่มต้น
	emit_enemy_stats()


func find_player_node_robust() -> CharacterBody2D:
	# 1) หา Player จาก exported NodePath ก่อน เพื่อให้ปรับใน Inspector ได้
	var found_player = get_node_or_null(player_path) as CharacterBody2D
	if found_player != null:
		return found_player

	# 2) หา Player จาก group identity ใหม่ของ Step 2
	var player_nodes := get_tree().get_nodes_in_group("player_actor")
	for node in player_nodes:
		if node is CharacterBody2D:
			return node as CharacterBody2D

	# 3) fallback แบบเดิม เพื่อให้ scene flat ปัจจุบันยังทำงานเหมือนเดิม
	if get_parent() != null:
		return get_parent().get_node_or_null("Player") as CharacterBody2D

	return null
