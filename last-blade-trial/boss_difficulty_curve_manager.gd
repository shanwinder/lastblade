extends Node

# =========================
# BossDifficultyCurveManager.gd
# จัด difficulty curve ของ Boss 1 สำหรับ Phase 9 Vertical Slice
# ช่วงต้น: normal / heavy
# ช่วงกลาง: เพิ่ม delayed
# ช่วงท้าย: เพิ่ม quick
# =========================

# อ้างอิงบอสหลักในฉาก
@export var boss_path: NodePath = NodePath("../BossBrokenMaster")

# เปิด/ปิดระบบ difficulty curve
@export var difficulty_curve_enabled: bool = true

# HP ratio ที่เข้าสู่ช่วงกลางของไฟต์
@export var mid_phase_hp_ratio: float = 0.70

# HP ratio ที่เข้าสู่ช่วงท้ายของไฟต์
@export var late_phase_hp_ratio: float = 0.35

# =========================
# Early Phase: ผู้เล่นใหม่เรียนรู้ Parry / Dash ก่อน
# =========================

# ช่วงต้นยังไม่ให้ quick ออก เพื่อไม่ลงโทษผู้เล่นใหม่เร็วเกินไป
@export var early_quick_attack_chance: float = 0.0

# ช่วงต้นยังไม่ให้ delayed ออก เพื่อให้ผู้เล่นอ่าน PARRY / DASH ก่อน
@export var early_delayed_attack_chance: float = 0.0

# ช่วงต้นให้ heavy ออกบ้าง เพื่อสอนว่าท่าบางท่าต้อง Dash ไม่ใช่ Parry
@export var early_heavy_attack_chance: float = 0.32

# =========================
# Mid Phase: เริ่มเพิ่ม delayed เพื่อสอนจังหวะรอ
# =========================

@export var mid_quick_attack_chance: float = 0.0
@export var mid_delayed_attack_chance: float = 0.25
@export var mid_heavy_attack_chance: float = 0.30

# =========================
# Late Phase: เพิ่ม quick เพื่อกดดันช่วงท้าย
# =========================

@export var late_quick_attack_chance: float = 0.18
@export var late_delayed_attack_chance: float = 0.25
@export var late_heavy_attack_chance: float = 0.28

# ถ้าเปิด จะ print phase ที่เปลี่ยนใน Output เพื่อช่วยจูน
@export var debug_print_phase_change: bool = true

# อ้างอิงบอสจริงหลังหาเจอ
var boss: Node = null

# จำ phase ปัจจุบันไว้เพื่อไม่ set ค่าซ้ำทุก frame
var current_phase: String = ""


func _ready() -> void:
	# หา Boss หลัง scene setup เสร็จ เพื่อกัน node ยังไม่พร้อม
	find_boss.call_deferred()


func _physics_process(_delta: float) -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องปรับ curve
	if not difficulty_curve_enabled:
		return

	# ถ้ายังไม่เจอบอสหรือบอสถูกลบ ให้ลองหาใหม่
	if not is_instance_valid(boss):
		find_boss()
		return

	# ถ้าบอสตายแล้ว ไม่ต้องปรับ phase ต่อ
	if get_bool_value(boss, "is_dead"):
		return

	update_boss_phase_by_hp()


func find_boss() -> void:
	# หา Boss จาก path ก่อน ถ้าไม่เจอค่อย fallback ด้วยชื่อ node
	var found_boss := get_node_or_null(boss_path)
	if found_boss != null:
		boss = found_boss
		return

	if get_parent() == null:
		return

	boss = get_parent().get_node_or_null("BossBrokenMaster")


func update_boss_phase_by_hp() -> void:
	# อ่าน HP ปัจจุบันและ HP สูงสุดของบอส
	var current_hp: float = get_float_value(boss, "current_hp", 1.0)
	var max_hp: float = max(get_float_value(boss, "max_hp", 1.0), 1.0)
	var hp_ratio: float = clamp(current_hp / max_hp, 0.0, 1.0)

	# เลือก phase จากสัดส่วน HP
	var next_phase: String = "early"
	if hp_ratio <= late_phase_hp_ratio:
		next_phase = "late"
	elif hp_ratio <= mid_phase_hp_ratio:
		next_phase = "mid"

	# ถ้า phase ยังเหมือนเดิม ไม่ต้อง set ค่าใหม่
	if next_phase == current_phase:
		return

	current_phase = next_phase
	apply_phase_settings(current_phase)


func apply_phase_settings(phase_name: String) -> void:
	# ปรับ chance การออกท่าตาม phase ปัจจุบัน
	match phase_name:
		"early":
			apply_attack_chances(
				early_quick_attack_chance,
				early_delayed_attack_chance,
				early_heavy_attack_chance
			)
		"mid":
			apply_attack_chances(
				mid_quick_attack_chance,
				mid_delayed_attack_chance,
				mid_heavy_attack_chance
			)
		"late":
			apply_attack_chances(
				late_quick_attack_chance,
				late_delayed_attack_chance,
				late_heavy_attack_chance
			)
		_:
			apply_attack_chances(
				early_quick_attack_chance,
				early_delayed_attack_chance,
				early_heavy_attack_chance
			)

	if debug_print_phase_change:
		print(
			"Boss difficulty phase =", phase_name,
			" quick=", get_float_value(boss, "quick_attack_chance", 0.0),
			" delayed=", get_float_value(boss, "delayed_attack_chance", 0.0),
			" heavy=", get_float_value(boss, "heavy_attack_chance", 0.0)
		)


func apply_attack_chances(quick_chance: float, delayed_chance: float, heavy_chance: float) -> void:
	# clamp กันค่ารวมไม่ให้แปลกเกินไป
	var safe_quick: float = clamp(quick_chance, 0.0, 0.60)
	var safe_delayed: float = clamp(delayed_chance, 0.0, 0.60)
	var safe_heavy: float = clamp(heavy_chance, 0.0, 0.60)

	# ถ้ารวมเกิน 0.90 ให้ normalize ลง เพื่อเหลือโอกาส normal_slash อย่างน้อย 10%
	var total: float = safe_quick + safe_delayed + safe_heavy
	if total > 0.90:
		var scale: float = 0.90 / total
		safe_quick *= scale
		safe_delayed *= scale
		safe_heavy *= scale

	boss.set("quick_attack_chance", safe_quick)
	boss.set("delayed_attack_chance", safe_delayed)
	boss.set("heavy_attack_chance", safe_heavy)


func get_float_value(target: Node, property_name: String, fallback: float) -> float:
	# อ่านค่า float จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return fallback

	return float(value)


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก node แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true
