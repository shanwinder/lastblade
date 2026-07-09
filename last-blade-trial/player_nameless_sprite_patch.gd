extends "res://player.gd"

# =========================
# PlayerNamelessSpritePatch.gd
# Patch เฉพาะช่วงนำ sprite จริงของ The Nameless Blade มาใช้
# เป้าหมายเดิม: แก้ flip_h ที่ต้นทาง ไม่ให้ player.gd ตั้งภาพผิดฝั่งก่อนแล้วค่อยให้ manager ตามแก้
# Patch เพิ่มเติม: ระบบ Charged Heavy Attack แบบกดปุ่มโจมตีค้าง
# =========================

# true = source sprite ของ Player หันซ้าย
# idle sprite ชุด nameless_blade ปัจจุบันเป็นท่าหันซ้าย จึงต้อง flip เมื่อ gameplay ต้องการหันขวา
@export var sprite_source_faces_left: bool = true

# =========================
# Charged Heavy Attack Balance
# =========================

# เปิด/ปิดระบบ Heavy Attack เพื่อ rollback กลับไปใช้ 3-hit combo เดิมได้ทันที
@export var heavy_attack_enabled: bool = true

# เวลาที่ต้องกด Attack ค้างก่อนจะนับว่าเป็นการชาร์จ ไม่ใช่การแตะโจมตีปกติ
@export var heavy_hold_threshold: float = 0.25

# เวลาชาร์จขั้นต่ำหลังเข้าสถานะชาร์จแล้ว จึงจะปล่อย Heavy Attack ได้
@export var heavy_charge_min_time: float = 2.0

# เวลาชาร์จเต็ม ใช้คำนวณ damage/posture สูงสุด
@export var heavy_charge_max_time: float = 3.0

# ถ้า true เมื่อชาร์จครบ heavy_charge_max_time จะปล่อย Heavy Attack อัตโนมัติ โดยไม่ต้องรอให้ผู้เล่นปล่อยปุ่มเอง
@export var heavy_auto_release_on_full_charge: bool = true

# ถ้า true ยังอนุญาตให้ผู้เล่นปล่อยปุ่มเองหลัง HEAVY READY ได้เหมือนเดิม ก่อนจะชาร์จเต็มอัตโนมัติ
@export var heavy_manual_release_after_ready_enabled: bool = true

# Stamina ที่เสียทันทีตอนเริ่มชาร์จ เพื่อไม่ให้ลองชาร์จฟรี
@export var heavy_start_stamina_cost: float = 20.0

# Stamina ที่เสียเพิ่มตอนปล่อย Heavy Attack สำเร็จ
@export var heavy_release_stamina_cost: float = 22.0

# Focus ที่ใช้ตอนปล่อย Heavy Attack สำเร็จ
@export var heavy_focus_cost: float = 40.0

# Damage ขั้นต่ำ/สูงสุดของ Heavy Attack ตามระดับการชาร์จ
@export var heavy_min_damage: int = 30
@export var heavy_max_damage: int = 42

# Posture damage ขั้นต่ำ/สูงสุดที่ทำกับบอส ถ้าศัตรูมีฟังก์ชัน reduce_posture()
@export var heavy_min_posture_damage: float = 35.0
@export var heavy_max_posture_damage: float = 55.0

# เวลาที่ hitbox ของ Heavy Attack เปิดอยู่ตอนปล่อยท่า
@export var heavy_active_time: float = 0.24

# เวลาค้างเฟรมท้ายหลังปิด hitbox เพื่อให้ผู้เล่นต้องรับผลของการ commit
@export var heavy_final_frame_hold_time: float = 0.55

# Recovery เพิ่มหลังค้างเฟรมท้าย ก่อนคืน control ให้ Player
@export var heavy_recovery_time: float = 0.95

# ตัวคูณความเร็วระหว่างชาร์จ/ปล่อย/พักท่า 0 = ยืนอยู่กับที่
@export var heavy_move_speed_multiplier: float = 0.0

# เปิด/ปิด debug print ของ Heavy Attack
@export var heavy_debug_print: bool = true

# ข้อความ feedback ของ Heavy Attack
@export var heavy_charging_feedback_text: String = "CHARGING..."
@export var heavy_ready_feedback_text: String = "HEAVY READY"
@export var heavy_full_feedback_text: String = "FULL CHARGE"
@export var heavy_no_focus_feedback_text: String = "NO FOCUS!"
@export var heavy_hit_feedback_text: String = "HEAVY HIT!"

# =========================
# Charged Heavy Attack Runtime State
# =========================

var is_attack_button_held: bool = false
var attack_hold_started_msec: int = -999999
var heavy_hold_consumed: bool = false

var is_charging_heavy_attack: bool = false
var heavy_charge_elapsed: float = 0.0
var heavy_charge_ready: bool = false
var heavy_charge_full: bool = false
var heavy_charge_phase: String = ""

var is_releasing_heavy_attack: bool = false
var is_heavy_recovering: bool = false
var heavy_attack_sequence_id: int = 0

var current_heavy_attack_damage: int = 0
var current_heavy_attack_posture_damage: float = 0.0


func _physics_process(delta: float) -> void:
	# ฟื้น Stamina และ Player Posture ทุกเฟรมเหมือน player.gd เดิม
	regenerate_stamina(delta)
	regenerate_player_posture(delta)

	# รองรับปุ่ม Lock-on บน keyboard เช่น L
	if Input.is_action_just_pressed("lock_on"):
		toggle_target_lock()

	# ถ้า Player ตายแล้ว ไม่ต้องควบคุมต่อ และต้องล้าง hold input กันปุ่มค้าง
	if is_dead:
		reset_attack_hold_tracking()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ถ้า Player Posture แตก ให้หยุดควบคุมและยกเลิก Heavy Attack ทันที
	if is_posture_broken:
		cancel_heavy_attack("posture broken")
		velocity = Vector2.ZERO
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้า Player กำลังถูก Knockback ให้ยกเลิก Heavy Attack แล้วขยับตามแรงกระเด็น
	if is_knocked_back:
		cancel_heavy_attack("knockback")
		velocity = knockback_velocity
		move_and_slide()
		clamp_to_arena()
		return

	# ถ้ากำลัง Dash อยู่ ให้เคลื่อนที่ด้วยความเร็ว Dash และไม่ให้ Heavy Attack ทำงานค้าง
	if is_dashing:
		cancel_heavy_attack("dash")
		velocity.x = float(facing_direction) * dash_speed
		velocity.y = 0.0
		move_and_slide()
		clamp_to_arena()
		return

	# รับค่าการกดปุ่มซ้าย/ขวา จาก ui_left และ ui_right
	var direction := Input.get_axis("ui_left", "ui_right")
	var axis_direction := int(sign(direction))
	track_movement_deflect_from_axis(axis_direction)

	# ถ้ากำลังโจมตี/ชาร์จ/พักท่า ให้หยุดหรือชะลอการขยับตามค่าที่กำหนด
	if is_attacking or is_heavy_action_active():
		velocity.x = direction * speed * heavy_move_speed_multiplier
	else:
		velocity.x = direction * speed

	velocity.y = 0.0
	move_and_slide()
	clamp_to_arena()

	# จัดทิศหันหน้าตาม Lock-on หรือ movement ปกติ
	if is_target_locked:
		update_facing_to_locked_target()
	elif direction != 0.0 and not is_attacking and not is_heavy_action_active():
		set_facing_direction(axis_direction)

	# จัดการ Attack แบบ Tap/Hold: Tap = combo, Hold = Charged Heavy Attack
	process_attack_button_input(delta)

	# ถ้ากดปุ่ม dash และตอนนี้ไม่ได้ทำ action อื่น ให้ Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_attacking and not is_dashing and not is_posture_broken and not is_heavy_action_active():
		if is_target_locked:
			update_facing_to_locked_target()
		dash()

	# ไม่รับ input parry โดยตรงแล้ว ระบบใหม่ใช้ Movement/Tap Deflect แทน


func process_attack_button_input(delta: float) -> void:
	# ถ้าระบบ Heavy ปิด ให้ใช้พฤติกรรมเดิมของ combo ทันที
	if not heavy_attack_enabled:
		if Input.is_action_just_pressed("attack") and not is_dashing and not is_posture_broken:
			attack()
		return

	# กด Attack ลงครั้งแรก: แยกเป็นกรณีกำลัง combo กับกรณีว่างเพื่อชาร์จ
	if Input.is_action_just_pressed("attack"):
		on_attack_button_pressed_for_tap_or_hold()

	# ถ้ากดค้างอยู่ ให้ตรวจว่าถึง threshold เพื่อเข้าชาร์จหรือยัง
	if is_attack_button_held and Input.is_action_pressed("attack"):
		update_attack_hold_and_heavy_charge(delta)

	# ปล่อย Attack: ถ้ายังไม่เข้าชาร์จให้เป็น Tap combo ถ้าชาร์จแล้วให้ปล่อย/ยกเลิก Heavy
	if is_attack_button_held and Input.is_action_just_released("attack"):
		on_attack_button_released_for_tap_or_hold()


func on_attack_button_pressed_for_tap_or_hold() -> void:
	# ถ้ากำลังโจมตีแบบ combo อยู่ การกดเพิ่มคือการ queue hit ถัดไป ไม่ใช่เริ่ม Heavy
	if is_attacking and not is_heavy_action_active():
		attack()
		return

	# ถ้าสถานะไม่พร้อมโจมตี ไม่ต้องเริ่มจับเวลา hold
	if not can_begin_attack_hold_check():
		return

	is_attack_button_held = true
	heavy_hold_consumed = false
	attack_hold_started_msec = Time.get_ticks_msec()


func update_attack_hold_and_heavy_charge(delta: float) -> void:
	# เมื่อเข้าสถานะชาร์จแล้ว ให้นับเวลา charge loop ต่อเนื่อง
	if is_charging_heavy_attack:
		update_heavy_charge(delta)
		return

	# ถ้ายังไม่ถึง hold threshold ให้รอดูว่าเป็น tap หรือ hold ก่อน
	var held_time := float(Time.get_ticks_msec() - attack_hold_started_msec) / 1000.0
	if held_time < heavy_hold_threshold:
		return

	# ถึง threshold แล้ว ถือว่าผู้เล่นตั้งใจใช้ Heavy Attack
	try_begin_heavy_charge()


func on_attack_button_released_for_tap_or_hold() -> void:
	# ถ้ากำลังชาร์จ Heavy อยู่ ให้ปล่อยท่าหรือยกเลิกตามเวลาที่ชาร์จได้
	if is_charging_heavy_attack:
		if heavy_manual_release_after_ready_enabled and heavy_charge_elapsed >= heavy_charge_min_time:
			release_charged_heavy_attack()
		else:
			cancel_heavy_attack("released before heavy ready")
		reset_attack_hold_tracking()
		return

	# ถ้ายังไม่ถูก consume เป็น Heavy ให้ถือว่าเป็น Tap และส่งเข้าระบบ combo เดิม
	if not heavy_hold_consumed:
		attack()

	reset_attack_hold_tracking()


func can_begin_attack_hold_check() -> bool:
	# ใช้ตรวจเฉพาะตอน Player ว่างพอจะเริ่ม tap/hold attack ได้
	if is_dead or is_dashing or is_posture_broken or is_knocked_back:
		return false

	if is_heavy_action_active():
		return false

	return true


func try_begin_heavy_charge() -> void:
	# เมื่อถึง hold threshold แล้ว ต้องไม่ให้ปล่อยปุ่มกลายเป็น tap อีก
	heavy_hold_consumed = true

	# Heavy ต้องเริ่มจากสถานะว่างเท่านั้น ไม่เริ่มระหว่าง combo/recovery
	if is_attacking or is_dead or is_dashing or is_posture_broken or is_knocked_back:
		reset_attack_hold_tracking()
		return

	# ต้องมี Focus พอตั้งแต่ก่อนเริ่มชาร์จ เพื่อให้ผู้เล่นรู้ว่าท่านี้ใช้ได้หรือไม่
	if current_focus < heavy_focus_cost:
		show_heavy_status_feedback(heavy_no_focus_feedback_text, Color(0.35, 0.95, 1.0, 1.0))
		if heavy_debug_print:
			print("Not enough focus to charge heavy. Focus =", int(current_focus))
		reset_attack_hold_tracking()
		return

	# จ่าย Stamina ตอนเริ่มชาร์จ เพื่อไม่ให้ชาร์จฟรี
	if current_stamina < heavy_start_stamina_cost:
		show_stamina_insufficient_feedback()
		if heavy_debug_print:
			print("Not enough stamina to start heavy charge. Stamina =", int(current_stamina))
		reset_attack_hold_tracking()
		return

	current_stamina -= heavy_start_stamina_cost
	emit_stats()

	# ยกเลิก combo coroutine เก่าที่อาจค้างอยู่ และล็อกสถานะเข้า Heavy Charge
	combo_sequence_id += 1
	combo_step = 0
	queued_combo_step = 0
	combo_input_buffered = false
	combo_input_window_open = false
	is_combo_recovering = false
	current_combo_step_for_damage = 0
	hit_targets.clear()

	heavy_attack_sequence_id += 1
	is_attacking = true
	is_charging_heavy_attack = true
	is_releasing_heavy_attack = false
	is_heavy_recovering = false
	heavy_charge_elapsed = 0.0
	heavy_charge_ready = false
	heavy_charge_full = false
	heavy_charge_phase = "start"
	current_heavy_attack_damage = 0
	current_heavy_attack_posture_damage = 0.0

	show_heavy_status_feedback(heavy_charging_feedback_text, Color(0.35, 0.95, 1.0, 1.0))
	if heavy_debug_print:
		print("Heavy charge started. Stamina left =", int(current_stamina), "Focus =", int(current_focus))


func update_heavy_charge(delta: float) -> void:
	# นับเวลาชาร์จหลังเข้าสถานะ Heavy Charge แล้ว
	heavy_charge_elapsed += delta

	# หลังเริ่มชาร์จสั้น ๆ ให้ visual manager เปลี่ยนจาก start เป็น loop
	if heavy_charge_phase == "start" and heavy_charge_elapsed >= 0.18:
		heavy_charge_phase = "loop"

	# แจ้งเมื่อถึงขั้นต่ำที่ปล่อยท่าได้
	if not heavy_charge_ready and heavy_charge_elapsed >= heavy_charge_min_time:
		heavy_charge_ready = true
		show_heavy_status_feedback(heavy_ready_feedback_text, Color(0.75, 1.0, 1.0, 1.0))
		if heavy_debug_print:
			print("Heavy charge ready")

	# แจ้งเมื่อชาร์จเต็ม และปล่อยท่าอัตโนมัติถ้าเปิดระบบไว้
	if not heavy_charge_full and heavy_charge_elapsed >= heavy_charge_max_time:
		heavy_charge_full = true
		show_heavy_status_feedback(heavy_full_feedback_text, Color(1.0, 1.0, 1.0, 1.0))
		get_tree().call_group("game_camera", "shake", 4.0, 0.10)
		if heavy_debug_print:
			print("Heavy full charge")

		# เมื่อผู้เล่นกดค้างจนชาร์จเต็ม ให้ปล่อย Heavy Attack ทันทีโดยไม่ต้องรอปล่อยนิ้ว
		# reset_attack_hold_tracking() ช่วยกันไม่ให้ตอนผู้เล่นปล่อยนิ้วทีหลัง trigger logic ซ้ำ
		if heavy_auto_release_on_full_charge and heavy_charge_elapsed >= heavy_charge_min_time:
			reset_attack_hold_tracking()
			release_charged_heavy_attack()
			return


func release_charged_heavy_attack() -> void:
	# ปล่อย Heavy Attack หลังชาร์จถึงขั้นต่ำแล้ว
	if not is_charging_heavy_attack:
		return

	var my_heavy_id: int = heavy_attack_sequence_id

	# ตอนปล่อยท่าต้องมี Stamina และ Focus พออีกครั้ง
	if current_stamina < heavy_release_stamina_cost:
		show_stamina_insufficient_feedback()
		cancel_heavy_attack("not enough stamina on release")
		return

	if current_focus < heavy_focus_cost:
		show_heavy_status_feedback(heavy_no_focus_feedback_text, Color(0.35, 0.95, 1.0, 1.0))
		cancel_heavy_attack("not enough focus on release")
		return

	current_heavy_attack_damage = get_current_heavy_damage()
	current_heavy_attack_posture_damage = get_current_heavy_posture_damage()

	current_stamina -= heavy_release_stamina_cost
	spend_focus(heavy_focus_cost)
	emit_stats()

	is_charging_heavy_attack = false
	is_releasing_heavy_attack = true
	is_heavy_recovering = false
	heavy_charge_phase = "release"
	hit_targets.clear()

	if heavy_debug_print:
		print(
			"Heavy release! Damage =", current_heavy_attack_damage,
			" Posture =", int(current_heavy_attack_posture_damage),
			" Stamina =", int(current_stamina),
			" Focus =", int(current_focus)
		)

	# เปิด hitbox ของ Heavy Attack เฉพาะช่วง release
	attack_shape.disabled = false
	get_tree().call_group("game_camera", "shake", 7.0, 0.12)

	await get_tree().create_timer(heavy_active_time).timeout
	if not is_heavy_sequence_current(my_heavy_id):
		return

	attack_shape.set_deferred("disabled", true)
	is_releasing_heavy_attack = false
	is_heavy_recovering = true
	heavy_charge_phase = "recover"

	# ค้างเฟรมท้ายเพื่อให้ผู้เล่นรับผลของการ commit
	if heavy_final_frame_hold_time > 0.0:
		await get_tree().create_timer(heavy_final_frame_hold_time).timeout
		if not is_heavy_sequence_current(my_heavy_id):
			return

	# Recovery เพิ่มหลังค้างเฟรมท้าย ก่อนคืน control
	if heavy_recovery_time > 0.0:
		await get_tree().create_timer(heavy_recovery_time).timeout
		if not is_heavy_sequence_current(my_heavy_id):
			return

	finish_heavy_attack(my_heavy_id)


func finish_heavy_attack(sequence_id: int) -> void:
	# คืนสถานะ Player หลัง Heavy Attack จบสมบูรณ์
	if sequence_id != heavy_attack_sequence_id:
		return

	is_attacking = false
	is_charging_heavy_attack = false
	is_releasing_heavy_attack = false
	is_heavy_recovering = false
	heavy_charge_elapsed = 0.0
	heavy_charge_ready = false
	heavy_charge_full = false
	heavy_charge_phase = ""
	current_heavy_attack_damage = 0
	current_heavy_attack_posture_damage = 0.0
	hit_targets.clear()
	attack_shape.set_deferred("disabled", true)

	if is_target_locked:
		update_facing_to_locked_target()

	enter_combat_stance_for(combat_stance_after_heavy_time, "heavy_finished")

	if heavy_debug_print:
		print("Heavy attack finished")


func cancel_heavy_attack(reason: String = "") -> void:
	# ยกเลิก Heavy Attack อย่างปลอดภัย ใช้เมื่อโดนตี ถูก Grab ตาย หรือถูก interrupt
	var was_heavy_active := is_heavy_action_active()
	var was_holding_attack := is_attack_button_held
	if not was_heavy_active and not was_holding_attack:
		return

	heavy_attack_sequence_id += 1
	reset_attack_hold_tracking()

	is_charging_heavy_attack = false
	is_releasing_heavy_attack = false
	is_heavy_recovering = false
	heavy_charge_elapsed = 0.0
	heavy_charge_ready = false
	heavy_charge_full = false
	heavy_charge_phase = ""
	current_heavy_attack_damage = 0
	current_heavy_attack_posture_damage = 0.0
	attack_shape.set_deferred("disabled", true)

	# ตั้ง is_attacking=false เฉพาะเมื่อเป็น Heavy จริง เพื่อไม่ไปตัด combo ปกติที่กำลังทำงาน
	if was_heavy_active:
		is_attacking = false

	if heavy_debug_print and reason != "":
		print("Heavy attack cancelled:", reason)


func reset_attack_hold_tracking() -> void:
	# ล้างสถานะการจับเวลา Tap/Hold ของปุ่ม Attack
	is_attack_button_held = false
	attack_hold_started_msec = -999999
	heavy_hold_consumed = false


func is_heavy_action_active() -> bool:
	# คืน true เมื่อ Player อยู่ในช่วง charge/release/recovery ของ Heavy Attack
	return is_charging_heavy_attack or is_releasing_heavy_attack or is_heavy_recovering


func is_heavy_sequence_current(sequence_id: int) -> bool:
	# ใช้กัน coroutine เก่าทำงานต่อหลังถูก cancel หรือ Player โดน interrupt
	if sequence_id != heavy_attack_sequence_id:
		return false

	if is_dead or is_dashing or is_posture_broken or is_knocked_back:
		return false

	return true


func get_heavy_charge_ratio() -> float:
	# คำนวณสัดส่วนชาร์จตั้งแต่ขั้นต่ำถึงเต็ม 0.0 - 1.0
	if heavy_charge_max_time <= heavy_charge_min_time:
		return 1.0

	var raw_ratio := (heavy_charge_elapsed - heavy_charge_min_time) / (heavy_charge_max_time - heavy_charge_min_time)
	return clampf(raw_ratio, 0.0, 1.0)


func get_current_heavy_damage() -> int:
	# Damage เพิ่มตามระดับการชาร์จ
	var ratio := get_heavy_charge_ratio()
	return int(round(float(heavy_min_damage) + (float(heavy_max_damage - heavy_min_damage) * ratio)))


func get_current_heavy_posture_damage() -> float:
	# Posture damage เพิ่มตามระดับการชาร์จ
	var ratio := get_heavy_charge_ratio()
	return heavy_min_posture_damage + ((heavy_max_posture_damage - heavy_min_posture_damage) * ratio)


func show_heavy_status_feedback(text: String, color: Color) -> void:
	# แสดงข้อความสถานะ Heavy Attack แบบสั้น ๆ เหนือหัว Player
	if is_dead:
		return

	if get_parent() == null:
		return

	var popup := Label.new()
	popup.text = text
	popup.modulate = color
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.z_index = 210
	popup.scale = Vector2(0.8, 0.8)
	popup.add_theme_font_size_override("font_size", 24)
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(-95.0, -135.0)

	var target_position: Vector2 = popup.global_position + Vector2(0.0, -32.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "global_position", target_position, 0.42)
	tween.tween_property(popup, "modulate:a", 0.0, 0.42)
	tween.set_parallel(false)
	tween.tween_callback(Callable(popup, "queue_free"))


func apply_charged_heavy_attack_to_target(target: Node) -> void:
	# Heavy Attack ใช้ damage/posture ของตัวเอง และไม่ trigger Focus Finisher ซ้อน
	if target == null:
		return

	# ลด Posture ของบอสถ้าเป้าหมายรองรับฟังก์ชันนี้
	if target.has_method("reduce_posture"):
		target.call("reduce_posture", current_heavy_attack_posture_damage)

	# ทำดาเมจ HP หลังจาก posture pressure
	if target.has_method("take_damage"):
		target.call("take_damage", current_heavy_attack_damage)

	show_heavy_status_feedback(heavy_hit_feedback_text, Color(0.75, 1.0, 1.0, 1.0))
	get_tree().call_group("game_camera", "shake", 11.0, 0.18)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# ถ้าอยู่ในช่วง Heavy Release ให้ใช้ damage/posture ของ Heavy Attack แยกจาก combo/Finisher
	if is_releasing_heavy_attack:
		if area.name != "Hurtbox":
			return

		var target = area.get_parent()
		if target == self:
			return

		if target in hit_targets:
			return

		if not target.has_method("take_damage"):
			return

		hit_targets.append(target)
		apply_charged_heavy_attack_to_target(target)
		return

	# ถ้าไม่ใช่ Heavy ให้ใช้ logic โจมตี/Finisher/Combo เดิมจาก player.gd
	super._on_attack_hitbox_area_entered(area)


func cancel_combo(reason: String = "") -> void:
	# ให้ระบบ Grab หรือ interrupt ที่เรียก cancel_combo ยกเลิก Heavy Attack ด้วย
	cancel_heavy_attack(reason)
	super.cancel_combo(reason)


func start_player_posture_break() -> void:
	# Posture Break ต้องหยุด Heavy Attack ทันที
	cancel_heavy_attack("posture broken")
	super.start_player_posture_break()


func apply_knockback() -> void:
	# Knockback จากการโดนโจมตีต้องหยุด Heavy Attack ทันที
	cancel_heavy_attack("knockback")
	super.apply_knockback()


func dash() -> void:
	# Dash ไม่ควรใช้ยกเลิก Heavy Attack ฟรี จึง cancel ก่อนเข้า dash logic เดิม
	cancel_heavy_attack("dash")
	super.dash()


func die() -> void:
	# ตอนตายต้องปิด hitbox และ coroutine ของ Heavy Attack ทั้งหมด
	cancel_heavy_attack("death")
	super.die()


func set_facing_direction(new_direction: int) -> void:
	# ตั้งทิศหันหน้าและย้าย hitbox ดาบให้ตรงกับทิศนั้น
	# Override ฟังก์ชันเดิมจาก player.gd เพราะของเดิมสมมติว่า source sprite หันขวา
	if new_direction == 0:
		return

	# facing_direction ยังเป็นแหล่งข้อมูลหลักของ gameplay ทั้งหมด
	# 1 = หันขวา, -1 = หันซ้าย
	facing_direction = new_direction

	# แก้ภาพที่ต้นทางทันที ไม่รอให้ manager มาแก้ทีหลัง
	apply_player_sprite_facing()

	# ย้าย hitbox ดาบให้ไปอยู่ด้านหน้าของตัวละครตามทิศ gameplay
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)


func apply_player_sprite_facing() -> void:
	# จัด flip_h ตามทิศของ source sprite จริง
	# ถ้า source หันซ้าย: หันขวาต้อง flip, หันซ้ายไม่ต้อง flip
	# ถ้า source หันขวา: หันซ้ายต้อง flip, หันขวาไม่ต้อง flip
	if not is_instance_valid(sprite_2d):
		return

	if sprite_source_faces_left:
		sprite_2d.flip_h = facing_direction > 0
	else:
		sprite_2d.flip_h = facing_direction < 0
