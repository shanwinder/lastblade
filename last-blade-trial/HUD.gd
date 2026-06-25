extends CanvasLayer

# =========================
# HUD.gd
# ใช้แสดงค่า HP, Stamina ของ Player
# และ Posture ของ EnemyDummy
# =========================

# อ้างอิง Label และ ProgressBar ของ Player
@onready var hp_label: Label = $Control/VBoxContainer/HPLabel
@onready var hp_bar: ProgressBar = $Control/VBoxContainer/HPBar
@onready var stamina_label: Label = $Control/VBoxContainer/StaminaLabel
@onready var stamina_bar: ProgressBar = $Control/VBoxContainer/StaminaBar

# อ้างอิง Label และ ProgressBar ของ Enemy Posture
@onready var enemy_posture_label: Label = $Control/VBoxContainer/EnemyPostureLabel
@onready var enemy_posture_bar: ProgressBar = $Control/VBoxContainer/EnemyPostureBar


func _ready() -> void:
	# หา node Player จาก Main
	var player = get_parent().get_node("Player")

	# หา node EnemyDummy จาก Main
	var enemy = get_parent().get_node("EnemyDummy")

	# เชื่อม signal จาก Player มายัง HUD
	# เมื่อ HP หรือ Stamina เปลี่ยน HUD จะอัปเดตทันที
	player.stats_changed.connect(update_player_stats)

	# เชื่อม signal จาก EnemyDummy มายัง HUD
	# เมื่อ HP หรือ Posture ของศัตรูเปลี่ยน HUD จะอัปเดตทันที
	enemy.enemy_stats_changed.connect(update_enemy_stats)

	# อัปเดต HUD ของ Player ครั้งแรกตอนเริ่มเกม
	update_player_stats(player.current_hp, player.max_hp, player.current_stamina, player.max_stamina)

	# อัปเดต HUD ของ Enemy ครั้งแรกตอนเริ่มเกม
	update_enemy_stats(enemy.current_hp, enemy.max_hp, enemy.current_posture, enemy.max_posture)


func update_player_stats(current_hp: int, max_hp: int, current_stamina: float, max_stamina: float) -> void:
	# อัปเดตข้อความ HP
	hp_label.text = "HP: %d / %d" % [current_hp, max_hp]

	# อัปเดตแถบ HP
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

	# อัปเดตข้อความ Stamina
	stamina_label.text = "Stamina: %d / %d" % [int(current_stamina), int(max_stamina)]

	# อัปเดตแถบ Stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina


func update_enemy_stats(_current_hp: int, _max_hp: int, current_posture: float, max_posture: float) -> void:
	# ตอนนี้เรายังไม่แสดง HP ศัตรูบน HUD
	# จึงใส่ _ นำหน้า _current_hp และ _max_hp
	# เพื่อบอก Godot ว่ารับค่าไว้ก่อน แต่ยังไม่ได้นำมาใช้

	# อัปเดตข้อความ Posture ของศัตรู
	enemy_posture_label.text = "Enemy Posture: %d / %d" % [int(current_posture), int(max_posture)]

	# อัปเดตแถบ Posture ของศัตรู
	enemy_posture_bar.max_value = max_posture
	enemy_posture_bar.value = current_posture
