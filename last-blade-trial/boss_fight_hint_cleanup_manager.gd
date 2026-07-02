extends Node

# =========================
# BossFightHintCleanupManager.gd
# ตัวช่วยล้างข้อความ BOSS FIGHT เหนือหัวบอส หลัง Duel 1 ปล่อยเข้าสู่ไฟต์จริง
# และช่วยแปล hint เก่าจาก PARRY เป็น DEFLECT ระหว่างเปลี่ยนระบบต่อสู้มือถือ
# =========================

# อ้างอิงบอสหลักในฉาก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# อ้างอิง Duel 1 manager ที่คุมการฝึกกับบอสจริง
@export var duel_1_manager_path: NodePath = NodePath("../Duel1DummyManager")

# อ้างอิง GameLoopManager เพื่อให้ทำงานเฉพาะตอนเกมกำลังเล่น
@export var game_loop_manager_path: NodePath = NodePath("../GameLoopManager")

# ข้อความ transition ที่ต้องล้างเมื่อบอสจริงเริ่มสู้แล้ว
@export var boss_fight_hint_text: String = "BOSS FIGHT"

# หน่วงเวลาสั้น ๆ หลังบอสจริงถูกปล่อย เพื่อให้ผู้เล่นเห็นสัญญาณก่อนล้าง
@export var cleanup_delay_after_real_fight_starts: float = 0.08

# เปิด/ปิดการแปลข้อความ Parry เก่าเป็น Deflect
@export var translate_parry_hint_to_deflect: bool = true

# ข้อความใหม่ของระบบ Movement Deflect
@export var deflect_hint_text: String = "DEFLECT!"

# อ้างอิง node จริงหลังหาเจอ
var boss: Node = null
var duel_1_manager: Node = null
var game_loop_manager: Node = null

# เวลาที่ผ่านไปหลังตรวจพบว่าไฟต์จริงเริ่มแล้ว
var real_fight_elapsed_time: float = 0.0

# กันไม่ให้ล้างซ้ำหลายครั้งในรอบเดียว
var has_cleared_boss_fight_hint: bool = false


func _ready() -> void:
	# หา node หลัง scene setup เสร็จ เพื่อกัน node ยังไม่พร้อมตอน _ready
	setup_references.call_deferred()


func _physics_process(delta: float) -> void:
	# ถ้ายังหา node ไม่ครบ ให้ลองหาใหม่
	if not are_references_ready():
		setup_references()
		return

	# แปล hint เก่าจากระบบ Parry ให้เข้ากับระบบ Movement Deflect ใหม่
	translate_legacy_parry_hint_if_needed()

	# ถ้าล้างแล้ว ไม่ต้องตรวจ BOSS FIGHT ซ้ำอีกในรอบนี้
	if has_cleared_boss_fight_hint:
		return

	# ทำงานเฉพาะตอนเกมอยู่ในสถานะ playing เท่านั้น
	if not is_game_playing():
		return

	# รอจน Duel 1 จบ และบอสจริงถูกปล่อยให้สู้แล้ว
	if not has_duel_1_finished_and_real_boss_started():
		real_fight_elapsed_time = 0.0
		return

	# ล้างเฉพาะกรณีข้อความที่ค้างอยู่คือ BOSS FIGHT เท่านั้น
	# ถ้าบอสเปลี่ยนเป็น DEFLECT! / DASH! แล้ว จะไม่ไปล้าง hint โจมตีจริง
	if not is_boss_fight_hint_showing():
		return

	real_fight_elapsed_time += delta
	if real_fight_elapsed_time >= cleanup_delay_after_real_fight_starts:
		clear_boss_fight_hint()


func setup_references() -> void:
	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	boss = get_node_or_null(boss_path)
	if boss == null and get_parent() != null:
		boss = get_parent().get_node_or_null("BossBrokenMaster")

	# หา Duel1DummyManager จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	duel_1_manager = get_node_or_null(duel_1_manager_path)
	if duel_1_manager == null and get_parent() != null:
		duel_1_manager = get_parent().get_node_or_null("Duel1DummyManager")

	# หา GameLoopManager จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	game_loop_manager = get_node_or_null(game_loop_manager_path)
	if game_loop_manager == null and get_parent() != null:
		game_loop_manager = get_parent().get_node_or_null("GameLoopManager")


func are_references_ready() -> bool:
	# ต้องมีทั้ง 3 ตัว เพื่อให้ตรวจ transition ได้แม่นยำ
	return is_instance_valid(boss) and is_instance_valid(duel_1_manager) and is_instance_valid(game_loop_manager)


func is_game_playing() -> bool:
	# อ่านสถานะเกมจาก GameLoopManager แบบปลอดภัย
	var state = game_loop_manager.get("game_state")
	return state == "playing"


func has_duel_1_finished_and_real_boss_started() -> bool:
	# ตรวจว่า Duel 1 จบแล้ว ไม่ได้อยู่ใน prompt/feedback และบอสถูกปล่อยให้โจมตีจริงแล้ว
	var duel_completed: bool = get_bool_value(duel_1_manager, "is_training_boss_completed")
	var duel_active: bool = get_bool_value(duel_1_manager, "is_training_boss_active")
	var prompt_active: bool = get_bool_value(duel_1_manager, "is_freeze_prompt_active")
	var feedback_active: bool = get_bool_value(duel_1_manager, "is_freeze_feedback_active")
	var boss_can_attack: bool = get_bool_value(boss, "can_attack")

	return duel_completed and not duel_active and not prompt_active and not feedback_active and boss_can_attack and boss.is_physics_processing()


func translate_legacy_parry_hint_if_needed() -> void:
	# ระหว่าง transition ไปสู่ Movement Deflect ยังมีบางระบบของ Boss/Tutorial ใช้คำว่า PARRY
	# จึงแปลข้อความที่ผู้เล่นเห็นให้เป็น DEFLECT ก่อน เพื่อไม่ให้ผู้เล่นหา Parry button ที่ถูกลบไปแล้ว
	if not translate_parry_hint_to_deflect:
		return

	if not is_instance_valid(boss):
		return

	var hint_label = boss.get("boss_hint_label")
	if not (hint_label is Label):
		return

	var label := hint_label as Label
	if not label.visible:
		return

	var translated_text := get_translated_hint_text(label.text)
	if translated_text == label.text:
		return

	label.text = translated_text

	# อัปเดตตัวแปร hint ใน boss ด้วย เผื่อระบบอื่นอ่านต่อภายหลัง
	if boss.get("current_attack_hint_text") != null:
		boss.set("current_attack_hint_text", translated_text)


func get_translated_hint_text(original_text: String) -> String:
	# แปลงคำเก่าที่พูดถึง Parry ให้เข้ากับระบบ Movement Deflect
	match original_text:
		"PARRY!":
			return deflect_hint_text
		"PARRY FAST!":
			return deflect_hint_text
		_:
			return original_text


func is_boss_fight_hint_showing() -> bool:
	# อ่าน Label hint จากตัวแปรของ BossBrokenMaster โดยตรง
	var hint_label = boss.get("boss_hint_label")
	if not (hint_label is Label):
		return false

	var label := hint_label as Label
	return label.visible and label.text == boss_fight_hint_text


func clear_boss_fight_hint() -> void:
	# ล้าง hint ผ่านเมธอดของบอส เพื่อให้ signal และสถานะ UI ถูกล้างเหมือนระบบหลัก
	if is_instance_valid(boss) and boss.has_method("clear_attack_hint"):
		boss.call("clear_attack_hint")

	# คืนสีบอสเป็นปกติ เผื่อ transition ก่อนหน้าเปลี่ยนสีไว้ในอนาคต
	var sprite = boss.get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.modulate = Color.WHITE

	has_cleared_boss_fight_hint = true
	print("BossFightHintCleanupManager cleared BOSS FIGHT hint")


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true
