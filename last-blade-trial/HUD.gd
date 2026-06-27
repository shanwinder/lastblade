extends CanvasLayer

# =========================
# HUD.gd
# ใช้แสดงค่า HP, Stamina ของ Player
# และ HP, Posture ของ Enemy หรือ Boss
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

# ข้อความผลลัพธ์ตอนจบเกม เช่น Game Over หรือ Victory
@onready var game_result_label: Label = $Control/GameResultLabel

# Label สำหรับแสดงคำเตือนท่าศัตรู เช่น PARRY! หรือ DASH!
# สร้างด้วยโค้ดใน _ready() เพื่อไม่ต้องแก้ Main.tscn ตอนนี้
var attack_hint_label: Label

# ใช้เช็กว่าเกมจบแล้วหรือยัง
var is_game_finished: bool = false

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

func _ready() -> void:
	# กันกรณี reload scene ตอนเกมกำลัง Hit Stop
	# ให้เริ่มฉากใหม่ด้วยความเร็วปกติเสมอ
	Engine.time_scale = 1.0
	
	# หา node Player จาก Main
	var player = get_parent().get_node("Player")

	# หา Enemy หรือ Boss อัตโนมัติ
	# ไม่ล็อกชื่อว่า EnemyDummy อีกต่อไป
	var enemy = find_combat_target()

	# ถ้าหาศัตรูหรือบอสไม่เจอ ให้หยุดเพื่อกัน error
	if enemy == null:
		return

	# เชื่อม signal จาก Player มายัง HUD
	# เมื่อ HP หรือ Stamina เปลี่ยน HUD จะอัปเดตทันที
	player.stats_changed.connect(update_player_stats)

	# เชื่อม signal จาก Enemy หรือ Boss มายัง HUD
	# เมื่อ HP หรือ Posture ของศัตรูเปลี่ยน HUD จะอัปเดตทันที
	enemy.enemy_stats_changed.connect(update_enemy_stats)
	
	# เชื่อม signal คำเตือนท่าศัตรู
	# ถ้า EnemyDummy มี signal นี้ ให้ HUD แสดงข้อความ PARRY! หรือ DASH!
	if enemy.has_signal("enemy_attack_hint_changed"):
		enemy.enemy_attack_hint_changed.connect(update_attack_hint)

	# เชื่อม signal เมื่อตัวละครผู้เล่นตาย
	player.player_died.connect(show_game_over)

	# เชื่อม signal เมื่อศัตรูตาย
	enemy.enemy_died.connect(show_victory)

	# ซ่อนข้อความผลลัพธ์ตอนเริ่มเกม
	game_result_label.text = ""
	
	# สร้าง Label สำหรับคำเตือนท่าศัตรู
	create_attack_hint_label()

	update_player_stats(
	player.current_hp,
	player.max_hp,
	player.current_stamina,
	player.max_stamina,
	player.current_focus,
	player.max_focus
)

	# อัปเดต HUD ของ Enemy ครั้งแรกตอนเริ่มเกม
	update_enemy_stats(enemy.current_hp, enemy.max_hp, enemy.current_posture, enemy.max_posture)

func create_attack_hint_label() -> void:
	# สร้าง Label ใหม่สำหรับบอกผู้เล่นว่าควร Parry หรือ Dash
	attack_hint_label = Label.new()

	# เริ่มต้นให้ไม่มีข้อความ
	attack_hint_label.text = ""

	# ทำให้ตัวอักษรใหญ่พอสำหรับอ่านบนมือถือ
	attack_hint_label.add_theme_font_size_override("font_size", 42)

	# จัดข้อความให้อยู่กึ่งกลาง
	attack_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# ตั้งขนาดพื้นที่ข้อความ
	attack_hint_label.custom_minimum_size = Vector2(500, 80)

	# วางตำแหน่งกลางบนของจอแบบง่าย ๆ ก่อน
	# ภายหลังค่อยปรับให้ responsive กับมือถือจริง
	attack_hint_label.position = Vector2(390, 90)

	# ให้ข้อความอยู่หน้าสุด
	attack_hint_label.z_index = 200

	# เพิ่มเข้าไปใต้ Control ของ HUD
	$Control.add_child(attack_hint_label)


func update_attack_hint(hint_text: String, hint_color: Color) -> void:
	# ถ้ายังไม่ได้สร้าง Label ให้ไม่ทำอะไร เพื่อป้องกัน error
	if attack_hint_label == null:
		return

	# อัปเดตข้อความ เช่น PARRY!, DASH! หรือ WAIT...
	attack_hint_label.text = hint_text

	# อัปเดตสีให้ตรงกับท่าโจมตี
	attack_hint_label.modulate = hint_color

	# ถ้าไม่มีข้อความ ให้ซ่อน Label
	attack_hint_label.visible = hint_text != ""

func update_player_stats(
	current_hp: int,
	max_hp: int,
	current_stamina: float,
	max_stamina: float,
	current_focus: float,
	max_focus: float
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

	# ถ้า Focus เต็ม ให้บอกผู้เล่นว่าพร้อมใช้ท่า Finisher
	if current_focus >= max_focus:
		focus_label.text = "Focus: %d / %d  READY" % [int(current_focus), int(max_focus)]
	else:
		focus_label.text = "Focus: %d / %d" % [int(current_focus), int(max_focus)]
		
	# อัปเดตหลอด Focus ผู้เล่น
	focus_bar.max_value = max_focus
	focus_bar.value = current_focus

func update_enemy_stats(current_hp: int, max_hp: int, current_posture: float, max_posture: float) -> void:
	# อัปเดตข้อความ HP ศัตรู
	enemy_hp_label.text = "Enemy HP: %d / %d" % [current_hp, max_hp]

	# อัปเดตหลอด HP ศัตรู
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = current_hp

	# อัปเดตข้อความ Posture ศัตรู
	enemy_posture_label.text = "Enemy Posture: %d / %d" % [int(current_posture), int(max_posture)]

	# อัปเดตหลอด Posture ศัตรู
	enemy_posture_bar.max_value = max_posture
	enemy_posture_bar.value = current_posture

func _process(_delta: float) -> void:
	# ถ้าเกมยังไม่จบ ไม่ต้องตรวจปุ่ม Restart
	if not is_game_finished:
		return

	# เมื่อเกมจบแล้ว กด R เพื่อเริ่มฉากใหม่
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func show_game_over() -> void:
	# ถ้าเกมจบไปแล้ว ไม่ต้องแสดงซ้ำ
	if is_game_finished:
		return

	is_game_finished = true

	# แสดงข้อความ Game Over
	game_result_label.text = "GAME OVER\nPress R to Restart"

	print("GAME OVER")


func show_victory() -> void:
	# ถ้าเกมจบไปแล้ว ไม่ต้องแสดงซ้ำ
	if is_game_finished:
		return

	is_game_finished = true

	# แสดงข้อความ Victory
	game_result_label.text = "VICTORY!\nPress R to Restart"

	print("VICTORY")
