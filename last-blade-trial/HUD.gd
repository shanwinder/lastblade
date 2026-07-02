extends CanvasLayer

# =========================
# HUD.gd
# ใช้แสดงค่า HP, Stamina, Focus และ Posture ของ Player
# รวมถึง HP และ Posture ของ Enemy หรือ Boss
# =========================

# =========================
# อ้างอิง Label และ ProgressBar ของ Player
# =========================

# ข้อความ HP ของผู้เล่น
@onready var hp_label: Label = $Control/VBoxContainer/HPLabel

# หลอด HP ของผู้เล่น
@onready var hp_bar: ProgressBar = $Control/VBoxContainer/HPBar

# ข้อความ Stamina ของผู้เล่น
@onready var stamina_label: Label = $Control/VBoxContainer/StaminaLabel

# หลอด Stamina ของผู้เล่น
@onready var stamina_bar: ProgressBar = $Control/VBoxContainer/StaminaBar

# ข้อความ Focus ของผู้เล่น
@onready var focus_label: Label = $Control/VBoxContainer/FocusLabel

# หลอด Focus ของผู้เล่น
@onready var focus_bar: ProgressBar = $Control/VBoxContainer/FocusBar

# ข้อความ Player Posture สร้างด้วยโค้ด เพื่อไม่ต้องแก้ scene ด้วยมือในรอบนี้
var player_posture_label: Label = null

# หลอด Player Posture สร้างด้วยโค้ด เพื่อไม่ต้องแก้ scene ด้วยมือในรอบนี้
var player_posture_bar: ProgressBar = null

# =========================
# อ้างอิง Label และ ProgressBar ของ Enemy
# =========================

# ข้อความ HP ของศัตรู
@onready var enemy_hp_label: Label = $Control/VBoxContainer/EnemyHPLabel

# หลอด HP ของศัตรู
@onready var enemy_hp_bar: ProgressBar = $Control/VBoxContainer/EnemyHPBar

# ข้อความ Posture ของศัตรู
@onready var enemy_posture_label: Label = $Control/VBoxContainer/EnemyPostureLabel

# หลอด Posture ของศัตรู
@onready var enemy_posture_bar: ProgressBar = $Control/VBoxContainer/EnemyPostureBar

# ข้อความผลลัพธ์ตอนจบเกม ใช้เป็น fallback เท่านั้น
# Flow หลักตอนนี้ให้ GameLoopManager แสดงหน้า Start / Victory / Defeated / Upgrade
@onready var game_result_label: Label = $Control/GameResultLabel

# Label สำหรับแสดงคำเตือนท่าศัตรู เช่น DEFLECT! หรือ DASH!
# ตอนนี้ Boss แสดง hint เหนือหัวตัวเองแล้ว ตัวนี้จึงเป็น fallback เฉย ๆ
var attack_hint_label: Label

# ใช้เช็กว่าเกมจบแล้วหรือยัง สำหรับ fallback display เท่านั้น
var is_game_finished: bool = false

# ชื่อเป้าหมายที่ HUD จะใช้แสดงบนจอ
# ค่าเริ่มต้นเป็น Enemy เผื่อในอนาคตมีศัตรูทั่วไป
var combat_target_display_name: String = "Enemy"


func find_combat_target():
	# หาเป้าหมายต่อสู้หลักจาก group combat_target
	# ตอนนี้ BossBrokenMaster จะ add_to_group("combat_target") ใน _ready()
	var combat_targets := get_tree().get_nodes_in_group("combat_target")

	# ถ้าเจอเป้าหมายใน group ให้ใช้ตัวแรก
	if combat_targets.size() > 0:
		var target = combat_targets[0]
		print("HUD found combat target from group:", target.name)
		return target

	# ถ้ายังไม่เจอจาก group ให้ใช้วิธีสำรอง
	# วนหาจากลูกของ Main ที่มี signal แบบศัตรูหรือบอส
	var main_node = get_parent()

	for child in main_node.get_children():
		# ข้าม HUD ตัวเอง
		if child == self:
			continue

		# ศัตรูหรือบอสต้องมี signal สองตัวนี้
		if child.has_signal("enemy_stats_changed") and child.has_signal("enemy_died"):
			print("HUD found combat target by signal:", child.name)
			return child

	# ถ้าหาไม่เจอ ให้แจ้ง error ใน console
	print("HUD ERROR: combat target not found")
	return null


func update_combat_target_display_name(target) -> void:
	# ตั้งค่าเริ่มต้นไว้ก่อน เผื่อ target ไม่มีข้อมูลชื่อแสดงผล
	combat_target_display_name = "Enemy"

	# ถ้า target ไม่มีจริง ให้หยุด
	if target == null:
		return

	# อ่านค่าชื่อแสดงผลจาก script ของเป้าหมาย
	# BossBrokenMaster.gd จะมี combat_display_name = "Boss"
	var display_name = target.get("combat_display_name")

	# ถ้ามีค่าชื่อแสดงผล และไม่ใช่ข้อความว่าง ให้ใช้ค่านั้น
	if display_name != null and str(display_name).strip_edges() != "":
		combat_target_display_name = str(display_name).strip_edges()
		return

	# วิธีสำรอง ถ้าชื่อ node มีคำว่า Boss ให้แสดงเป็น Boss
	if "Boss" in target.name:
		combat_target_display_name = "Boss"


func _ready() -> void:
	# กันกรณี reload scene ตอนเกมกำลัง Hit Stop
	# ให้เริ่มฉากใหม่ด้วยความเร็วปกติเสมอ
	Engine.time_scale = 1.0

	# สร้าง Player Posture UI เพิ่มด้วยโค้ด เพื่อลดการแก้ BossBrokenMaster.tscn ใน phase นี้
	create_player_posture_widgets()

	# หา node Player จาก Main
	var player = get_parent().get_node("Player")

	# หา Enemy หรือ Boss อัตโนมัติ
	# ไม่ล็อกชื่อว่า EnemyDummy อีกต่อไป
	var enemy = find_combat_target()

	# ถ้าหาศัตรูหรือบอสไม่เจอ ให้หยุดเพื่อกัน error
	if enemy == null:
		return

	# ตั้งชื่อที่ HUD จะใช้แสดง เช่น Boss หรือ Enemy
	update_combat_target_display_name(enemy)

	# อ่านชื่อที่ target อยากให้ HUD แสดง
	# BossBrokenMaster.gd จะมี combat_display_name = "Boss"
	var display_name = enemy.get("combat_display_name")

	if display_name != null and str(display_name).strip_edges() != "":
		combat_target_display_name = str(display_name).strip_edges()
	elif "Boss" in enemy.name:
		combat_target_display_name = "Boss"
	else:
		combat_target_display_name = "Enemy"

	# เชื่อม signal จาก Player มายัง HUD
	# เมื่อ HP, Stamina, Focus หรือ Player Posture เปลี่ยน HUD จะอัปเดตทันที
	player.stats_changed.connect(update_player_stats)

	# เชื่อม signal จาก Enemy หรือ Boss มายัง HUD
	# เมื่อ HP หรือ Posture ของศัตรูเปลี่ยน HUD จะอัปเดตทันที
	enemy.enemy_stats_changed.connect(update_enemy_stats)

	# เชื่อม signal คำเตือนท่าศัตรู
	# ถ้า Boss มี signal นี้ ให้ HUD รับไว้ แต่ปัจจุบัน Boss แสดงเหนือหัวเอง
	if enemy.has_signal("enemy_attack_hint_changed"):
		enemy.enemy_attack_hint_changed.connect(update_attack_hint)

	# เชื่อม signal เมื่อตัวละครผู้เล่นตาย
	player.player_died.connect(show_game_over)

	# เชื่อม signal เมื่อศัตรูตาย
	enemy.enemy_died.connect(show_victory)

	# ซ่อนข้อความผลลัพธ์ตอนเริ่มเกม เพราะ GameLoopManager เป็นคนแสดง overlay หลัก
	game_result_label.text = ""

	# สร้าง Label สำหรับคำเตือนท่าศัตรู
	create_attack_hint_label()

	# อ่านค่า Player Posture แบบปลอดภัย เผื่อเปิด scene เก่าที่ยังไม่มีตัวแปรนี้
	var current_posture := 100.0
	var max_posture := 100.0
	var player_current_posture_value = player.get("current_player_posture")
	var player_max_posture_value = player.get("max_player_posture")

	if player_current_posture_value != null:
		current_posture = float(player_current_posture_value)
	if player_max_posture_value != null:
		max_posture = float(player_max_posture_value)

	update_player_stats(
		player.current_hp,
		player.max_hp,
		player.current_stamina,
		player.max_stamina,
		player.current_focus,
		player.max_focus,
		current_posture,
		max_posture
	)

	# อัปเดต HUD ของ Enemy ครั้งแรกตอนเริ่มเกม
	update_enemy_stats(enemy.current_hp, enemy.max_hp, enemy.current_posture, enemy.max_posture)


func create_player_posture_widgets() -> void:
	# สร้าง Player Posture Label/Bar ใน VBoxContainer ด้วยโค้ด
	# เพื่อให้เพิ่ม HUD ใหม่ได้โดยไม่ต้องแก้ .tscn ด้วยมือใน phase นี้
	var stats_container := $Control/VBoxContainer

	player_posture_label = Label.new()
	player_posture_label.name = "PlayerPostureLabel"
	player_posture_label.text = "Posture: 100 / 100"
	stats_container.add_child(player_posture_label)

	player_posture_bar = ProgressBar.new()
	player_posture_bar.name = "PlayerPostureBar"
	player_posture_bar.custom_minimum_size = Vector2(220.0, 18.0)
	player_posture_bar.max_value = 100.0
	player_posture_bar.value = 100.0
	stats_container.add_child(player_posture_bar)

	# ย้าย Player Posture ไปไว้หลัง StaminaBar เพื่อให้เรียงเป็น HP / Stamina / Posture / Enemy / Focus
	var stamina_bar_index := stats_container.get_children().find(stamina_bar)
	if stamina_bar_index >= 0:
		stats_container.move_child(player_posture_label, stamina_bar_index + 1)
		stats_container.move_child(player_posture_bar, stamina_bar_index + 2)


func create_attack_hint_label() -> void:
	# ตอนนี้ย้ายข้อความเตือนการโจมตีไปไว้เหนือหัวบอสแล้ว
	# จึงไม่ต้องสร้าง Label กลางจอใน HUD อีก
	attack_hint_label = null


func update_attack_hint(_hint_text: String, _hint_color: Color) -> void:
	# ตอนนี้ BossBrokenMaster.gd แสดง hint เหนือหัวบอสเองแล้ว
	# HUD จึงไม่ต้องอัปเดตข้อความเตือนกลางจอ
	return


func update_player_stats(
	current_hp: int,
	max_hp: int,
	current_stamina: float,
	max_stamina: float,
	current_focus: float,
	max_focus: float,
	current_player_posture: float,
	max_player_posture: float
) -> void:
	# อัปเดตข้อความ HP ผู้เล่น
	hp_label.text = "Player HP: %d / %d" % [current_hp, max_hp]

	# อัปเดตหลอด HP ผู้เล่น
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

	# อัปเดตข้อความ Stamina ผู้เล่น
	stamina_label.text = "Stamina: %d / %d" % [int(current_stamina), int(max_stamina)]

	# อัปเดตหลอด Stamina ผู้เล่น
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

	# อัปเดต Player Posture
	if player_posture_label != null:
		if current_player_posture <= 0.0:
			player_posture_label.text = "Posture: %d / %d  BROKEN" % [int(current_player_posture), int(max_player_posture)]
		else:
			player_posture_label.text = "Posture: %d / %d" % [int(current_player_posture), int(max_player_posture)]

	if player_posture_bar != null:
		player_posture_bar.max_value = max_player_posture
		player_posture_bar.value = current_player_posture

	# ถ้า Focus เต็ม ให้บอกผู้เล่นว่าพร้อมใช้ท่า Finisher
	if current_focus >= max_focus:
		focus_label.text = "Focus: %d / %d  READY" % [int(current_focus), int(max_focus)]
	else:
		focus_label.text = "Focus: %d / %d" % [int(current_focus), int(max_focus)]

	# อัปเดตหลอด Focus ผู้เล่น
	focus_bar.max_value = max_focus
	focus_bar.value = current_focus


func update_enemy_stats(current_hp: int, max_hp: int, current_posture: float, max_posture: float) -> void:
	# อัปเดตข้อความ HP ของเป้าหมายต่อสู้
	# ถ้า target เป็นบอส จะแสดง Boss HP
	# ถ้า target เป็นศัตรูทั่วไป จะแสดง Enemy HP
	enemy_hp_label.text = "%s HP: %d / %d" % [combat_target_display_name, current_hp, max_hp]

	# อัปเดตหลอด HP ของเป้าหมายต่อสู้
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = current_hp

	# อัปเดตข้อความ Posture ของเป้าหมายต่อสู้
	enemy_posture_label.text = "%s Posture: %d / %d" % [combat_target_display_name, int(current_posture), int(max_posture)]

	# อัปเดตหลอด Posture ของเป้าหมายต่อสู้
	enemy_posture_bar.max_value = max_posture
	enemy_posture_bar.value = current_posture


func show_game_over() -> void:
	# Fallback เท่านั้น ตอนนี้ GameLoopManager เป็นคนแสดงหน้าแพ้หลัก
	if is_game_finished:
		return

	is_game_finished = true
	game_result_label.text = ""


func show_victory() -> void:
	# Fallback เท่านั้น ตอนนี้ GameLoopManager เป็นคนแสดงหน้า Victory/Upgrade หลัก
	if is_game_finished:
		return

	is_game_finished = true
	game_result_label.text = ""
