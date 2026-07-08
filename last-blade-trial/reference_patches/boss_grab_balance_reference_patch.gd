extends "res://boss_grab_balance_manager.gd"

# =========================
# BossGrabBalanceReferencePatch.gd
# Step 4: เพิ่ม group fallback ให้ BossGrabBalanceManager
# Patch ล่าสุด: ทำให้ Grab แน่นอนขึ้นเมื่อ Player ยังอยู่ในระยะหลังครบเวลา wind-up
# =========================

# เปิดระบบ grab แบบแน่นอนเมื่อ Player อยู่ในระยะเริ่ม Grab
# true = ถ้า Player อยู่ในระยะ และ Boss พร้อม จะเริ่ม Grab ทันที ไม่สุ่ม roll
@export var deterministic_grab_start_when_in_range: bool = true

# ระยะเริ่ม Grab ที่ปรับเพิ่มจากค่าเดิม เพื่อให้ Boss ใช้ Grab ได้ทันเมื่อผู้เล่นยืนประชิด
@export var improved_grab_close_range: float = 88.0

# ระยะจับจริงตอนครบเวลา wind-up / active frame
# ค่านี้ทำหน้าที่เหมือน hitbox ของ Grab ที่กว้างกว่าเดิมเล็กน้อย
@export var improved_grab_catch_range: float = 108.0

# ระยะเสี่ยงโดน Grab หลัง Dash landing ที่ปรับเพิ่มเล็กน้อย
@export var improved_grab_dash_landing_range: float = 118.0


func _ready() -> void:
	# ปรับค่า default ของระบบ Grab ให้หนักแน่นขึ้นเฉพาะใน patch ที่ scene หลักใช้อยู่
	# ใช้ maxf เพื่อไม่ลดค่าที่อาจถูกปรับให้สูงกว่าใน Inspector ภายหลัง
	grab_close_range = maxf(grab_close_range, improved_grab_close_range)
	grab_dash_landing_range = maxf(grab_dash_landing_range, improved_grab_dash_landing_range)

	# เรียก _ready() ของ BossGrabBalanceManager เดิม เพื่อคง process_priority และ deferred setup_references
	super._ready()


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


func should_start_grab() -> bool:
	# เงื่อนไขหลักเหมือน base manager แต่เปลี่ยนจากสุ่ม chance เป็น deterministic เมื่ออยู่ในระยะ
	if Time.get_ticks_msec() < next_grab_allowed_msec:
		return false

	if not is_boss_available_for_grab():
		return false

	if not is_player_available_for_grab_check():
		return false

	var distance_to_player := get_distance_to_player()
	var is_close := distance_to_player <= grab_close_range
	var is_dash_landing_close := is_player_dash_landing_risk() and distance_to_player <= grab_dash_landing_range

	# ถ้าไม่ใกล้ และไม่ได้เพิ่ง Dash จบใกล้ Boss ก็ไม่ควร Grab
	if not is_close and not is_dash_landing_close:
		return false

	if deterministic_grab_start_when_in_range:
		if debug_print_grab:
			print(
				"Grab guaranteed start: distance=", int(distance_to_player),
				" close_range=", int(grab_close_range),
				" catch_range=", int(get_effective_grab_catch_range()),
				" dash_risk=", is_dash_landing_close
			)
		return true

	# ถ้าปิด deterministic ให้กลับไปใช้สูตรสุ่มเดิมของ base manager
	return super.should_start_grab()


func try_begin_grab_hold() -> bool:
	# เมื่อครบ wind-up แล้ว ถ้า Player ยังอยู่ใน hitbox Grab ให้จับทันที
	# ยังอนุญาตให้หลบด้วย Dash ถ้าผู้เล่นกำลังอยู่ในสถานะ dash ตอน active frame
	if not is_instance_valid(player):
		return false

	var distance_to_player := get_distance_to_player()
	var catch_range := get_effective_grab_catch_range()
	if distance_to_player > catch_range:
		if debug_print_grab:
			print("Grab missed: player out of catch range distance=", int(distance_to_player), " range=", int(catch_range))
		return false

	var player_is_dashing = player.get("is_dashing")
	if player_is_dashing == true:
		if debug_print_grab:
			print("Grab avoided by dash")
		return false

	# Grab ไม่เช็ก Deflect เพราะออกแบบให้ Deflect ไม่ได้
	if debug_print_grab:
		print("Boss Grab caught player: distance=", int(distance_to_player), " range=", int(catch_range))

	boss.set("has_hit_player", true)
	show_grabbed_feedback()
	get_tree().call_group("game_camera", "shake", 8.0, 0.16)
	enter_player_grab_hold()
	return true


func get_effective_grab_catch_range() -> float:
	# ใช้ค่าที่มากกว่า เพื่อให้ Inspector ปรับ grab_close_range สูงขึ้นแล้วยังมีผลกับระยะจับจริง
	return maxf(grab_close_range, improved_grab_catch_range)
