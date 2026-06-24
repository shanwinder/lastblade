extends CanvasLayer

# =========================
# HUD.gd
# ใช้แสดงค่า HP และ Stamina บนหน้าจอ
# =========================

# อ้างอิง Label และ ProgressBar ต่าง ๆ
@onready var hp_label: Label = $Control/VBoxContainer/HPLabel
@onready var hp_bar: ProgressBar = $Control/VBoxContainer/HPBar
@onready var stamina_label: Label = $Control/VBoxContainer/StaminaLabel
@onready var stamina_bar: ProgressBar = $Control/VBoxContainer/StaminaBar


func _ready() -> void:
	# หา node Player จาก Main
	# โครงสร้างของเราคือ Main > Player และ Main > HUD
	var player = get_parent().get_node("Player")

	# เชื่อม signal จาก Player มายัง HUD
	# เมื่อ HP หรือ Stamina เปลี่ยน HUD จะอัปเดตทันที
	player.stats_changed.connect(update_stats)

	# อัปเดต HUD ครั้งแรกตอนเริ่มเกม
	update_stats(player.current_hp, player.max_hp, player.current_stamina, player.max_stamina)


func update_stats(current_hp: int, max_hp: int, current_stamina: float, max_stamina: float) -> void:
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
