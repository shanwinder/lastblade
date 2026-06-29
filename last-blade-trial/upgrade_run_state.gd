extends Node

# =========================
# UpgradeRunState.gd
# เก็บค่า upgrade แบบ runtime-only สำหรับ Phase 8
# ยังไม่ทำ save/load ถาวร เพื่อไม่ให้ scope บาน
# =========================

# ตัวคูณดาเมจโจมตีของ Player
var attack_damage_multiplier: float = 1.0

# โบนัส Max Stamina ของ Player
var max_stamina_bonus: float = 0.0

# ตัวคูณ Dash Cooldown ของ Player ยิ่งต่ำยิ่ง dash ได้ถี่ขึ้น
var dash_cooldown_multiplier: float = 1.0

# โบนัสหน้าต่าง Parry ของ Player
var parry_window_bonus: float = 0.0

# โบนัส Focus ที่ได้จากการ Parry สำเร็จ
var focus_gain_bonus: float = 0.0

# โบนัส Max HP สำหรับ prototype แทนผล "ฟื้น HP หลังชนะ" ในเกมที่มีบอสเดียวต่อรอบ
var max_hp_bonus: int = 0

# จำนวน upgrade ที่เลือกมาแล้วใน session นี้
var chosen_upgrade_count: int = 0


func get_all_upgrade_ids() -> Array[String]:
	# รายการ upgrade ชุดแรกตาม Phase 8
	return [
		"sharp_blade",
		"long_breath",
		"shadow_step",
		"calm_mind",
		"focus_training",
		"swordsman_blood"
	]


func get_random_upgrade_choices(choice_count: int = 3) -> Array[String]:
	# สุ่ม upgrade แบบง่าย ยังไม่ทำ rarity หรือ economy
	var pool: Array[String] = get_all_upgrade_ids()
	pool.shuffle()

	var result: Array[String] = []
	var final_count: int = min(choice_count, pool.size())

	for i in range(final_count):
		result.append(pool[i])

	return result


func get_upgrade_title(upgrade_id: String) -> String:
	# ชื่อ upgrade ภาษาไทยสำหรับแสดงบนปุ่ม
	match upgrade_id:
		"sharp_blade":
			return "คมดาบ"
		"long_breath":
			return "ลมหายใจยาว"
		"shadow_step":
			return "เท้าเงา"
		"calm_mind":
			return "ใจนิ่ง"
		"focus_training":
			return "สมาธิ"
		"swordsman_blood":
			return "เลือดนักดาบ"
		_:
			return "Upgrade"


func get_upgrade_description(upgrade_id: String) -> String:
	# คำอธิบายผล upgrade แบบสั้น เพื่อให้อ่านง่ายบนมือถือ
	match upgrade_id:
		"sharp_blade":
			return "+10% Attack Damage"
		"long_breath":
			return "+15 Max Stamina"
		"shadow_step":
			return "Dash Cooldown -10%"
		"calm_mind":
			return "+0.04 sec Parry Window"
		"focus_training":
			return "+5 Focus on Parry"
		"swordsman_blood":
			return "+10 Max HP"
		_:
			return "Unknown upgrade"


func apply_upgrade(upgrade_id: String) -> void:
	# นำผล upgrade ไปสะสมแบบเบา ๆ พร้อม cap กันตัวละครเก่งเร็วเกินไป
	match upgrade_id:
		"sharp_blade":
			attack_damage_multiplier = min(attack_damage_multiplier + 0.10, 1.60)
		"long_breath":
			max_stamina_bonus = min(max_stamina_bonus + 15.0, 60.0)
		"shadow_step":
			dash_cooldown_multiplier = max(dash_cooldown_multiplier * 0.90, 0.65)
		"calm_mind":
			parry_window_bonus = min(parry_window_bonus + 0.04, 0.16)
		"focus_training":
			focus_gain_bonus = min(focus_gain_bonus + 5.0, 25.0)
		"swordsman_blood":
			max_hp_bonus = min(max_hp_bonus + 10, 40)
		_:
			print("UpgradeRunState WARNING: unknown upgrade id =", upgrade_id)
			return

	chosen_upgrade_count += 1
	print("Upgrade selected:", get_upgrade_title(upgrade_id), "Total upgrades =", chosen_upgrade_count)


func apply_upgrades_to_player(player: Node) -> void:
	# นำค่า upgrade ที่สะสมไว้ไปปรับ Player ตอนเริ่มรอบใหม่
	if not is_instance_valid(player):
		return

	# เพิ่ม Attack Damage จาก base ใน scene ปัจจุบัน
	var base_attack_damage = player.get("attack_damage")
	if base_attack_damage != null:
		player.set("attack_damage", max(1, int(round(float(base_attack_damage) * attack_damage_multiplier))))

	# เพิ่ม Max HP และเติม HP ให้เต็มตามค่าใหม่
	var base_max_hp = player.get("max_hp")
	if base_max_hp != null:
		var upgraded_max_hp: int = int(base_max_hp) + max_hp_bonus
		player.set("max_hp", upgraded_max_hp)
		player.set("current_hp", upgraded_max_hp)

	# เพิ่ม Max Stamina และเติม Stamina ให้เต็มตามค่าใหม่
	var base_max_stamina = player.get("max_stamina")
	if base_max_stamina != null:
		var upgraded_max_stamina: float = float(base_max_stamina) + max_stamina_bonus
		player.set("max_stamina", upgraded_max_stamina)
		player.set("current_stamina", upgraded_max_stamina)

	# ลด Dash Cooldown
	var base_dash_cooldown = player.get("dash_cooldown")
	if base_dash_cooldown != null:
		player.set("dash_cooldown", max(0.20, float(base_dash_cooldown) * dash_cooldown_multiplier))

	# เพิ่ม Parry Window
	var base_parry_window = player.get("parry_active_time")
	if base_parry_window != null:
		player.set("parry_active_time", float(base_parry_window) + parry_window_bonus)

	# เพิ่ม Focus Gain จาก Parry
	var base_focus_gain = player.get("focus_gain_on_successful_parry")
	if base_focus_gain != null:
		player.set("focus_gain_on_successful_parry", float(base_focus_gain) + focus_gain_bonus)

	# อัปเดต HUD หลังค่า Player เปลี่ยน
	if player.has_method("emit_stats"):
		player.emit_stats()

	print_upgrade_summary()


func print_upgrade_summary() -> void:
	# แสดงสรุปใน console เพื่อช่วยจูน balance ช่วง prototype
	print(
		"Upgrade summary: atk x", snapped(attack_damage_multiplier, 0.01),
		" stamina +", int(max_stamina_bonus),
		" dash cd x", snapped(dash_cooldown_multiplier, 0.01),
		" parry +", snapped(parry_window_bonus, 0.01),
		" focus +", int(focus_gain_bonus),
		" hp +", max_hp_bonus
	)


func reset_all_upgrades() -> void:
	# ใช้ในอนาคตเมื่อมีปุ่ม New Run / Reset Progress
	attack_damage_multiplier = 1.0
	max_stamina_bonus = 0.0
	dash_cooldown_multiplier = 1.0
	parry_window_bonus = 0.0
	focus_gain_bonus = 0.0
	max_hp_bonus = 0
	chosen_upgrade_count = 0
