extends Node

# =========================
# PlayerAnimatedIdleVisualManager.gd
# ตัวจัดภาพ animation ของ Player ช่วงเปลี่ยนผ่านจาก Sprite2D ไป AnimatedSprite2D
# ใช้ AnimatedSprite2D เป็นภาพที่ผู้เล่นเห็นจริง แต่ยังเก็บ Sprite2D เดิมไว้เป็น compatibility layer
# เพื่อไม่ให้ dash trail / feedback สี / player.gd เดิมพังในช่วงเปลี่ยนผ่าน
# =========================

# เปิด/ปิดระบบภาพ AnimatedSprite2D
@export var animated_idle_enabled: bool = true

# อ้างอิง Player หลัก ถ้าเว้นไว้จะใช้ parent ของ manager เป็น Player
@export var player_path: NodePath = NodePath("..")

# อ้างอิง Sprite2D เดิมที่ player.gd ยังใช้อยู่
@export var legacy_sprite_path: NodePath = NodePath("../Sprite2D")

# อ้างอิง AnimatedSprite2D ใหม่ที่ใช้แสดง animation จริง
@export var animated_sprite_path: NodePath = NodePath("../AnimatedSprite2D")

# ชื่อ animation idle ใน SpriteFrames resource
@export var idle_animation_name: StringName = &"idle"

# ชื่อ animation run ใน SpriteFrames resource
@export var run_animation_name: StringName = &"run"

# เปิด/ปิดการเลือก run animation จากความเร็วของ Player
@export var run_animation_enabled: bool = true

# ความเร็วแนวนอนขั้นต่ำที่จะถือว่า Player กำลังวิ่ง
@export var run_velocity_threshold: float = 8.0

# ถ้า true จะซ่อน Sprite2D เดิม เพื่อไม่ให้ภาพนิ่งซ้อนกับ AnimatedSprite2D
@export var hide_legacy_sprite: bool = true

# ถ้า true จะ sync flip_h จาก Sprite2D เดิมไป AnimatedSprite2D
@export var sync_flip_from_legacy: bool = true

# ถ้า true จะ sync สี/feedback modulate จาก Sprite2D เดิมไป AnimatedSprite2D
@export var sync_modulate_from_legacy: bool = true

# เปิด/ปิด debug print ตอน setup
@export var debug_print_visual: bool = true

var player: Node = null
var legacy_sprite: Sprite2D = null
var animated_sprite: AnimatedSprite2D = null


func _ready() -> void:
	# หา reference ทันที และ deferred อีกครั้งเผื่อ scene ยัง setup ไม่ครบ
	setup_references()
	setup_references.call_deferred()


func _process(_delta: float) -> void:
	# sync ภาพทุก frame เพื่อให้ visual ใหม่ตามระบบเก่าทันที
	process_visual_sync()


func _physics_process(_delta: float) -> void:
	# sync ซ้ำใน physics frame เพื่อให้ทิศ/สีตามทันตอน movement, dash, attack
	process_visual_sync()


func setup_references() -> void:
	# หา Player จาก path ก่อน ถ้าไม่เจอให้ใช้ parent เป็น fallback
	player = get_node_or_null(player_path)
	if player == null:
		player = get_parent()

	# หา Sprite2D เดิมจาก path
	legacy_sprite = get_node_or_null(legacy_sprite_path) as Sprite2D

	# หา AnimatedSprite2D ใหม่จาก path
	animated_sprite = get_node_or_null(animated_sprite_path) as AnimatedSprite2D

	if animated_idle_enabled and is_instance_valid(animated_sprite):
		# ให้ animation เริ่มจาก idle เมื่อพร้อม
		play_animation_safely(idle_animation_name)

	if hide_legacy_sprite and is_instance_valid(legacy_sprite):
		# ซ่อนภาพนิ่งเดิมเพื่อไม่ให้ซ้อนกับ AnimatedSprite2D
		# แต่ยังเก็บ node นี้ไว้ให้ player.gd ใช้ texture, flip_h และ modulate ต่อไป
		legacy_sprite.visible = false

	if debug_print_visual and is_instance_valid(animated_sprite):
		print("PlayerAnimatedIdleVisualManager ready. Idle =", idle_animation_name, " Run =", run_animation_name)


func process_visual_sync() -> void:
	# ถ้าปิดระบบไว้ ไม่ต้องทำอะไร
	if not animated_idle_enabled:
		return

	if not are_references_ready():
		setup_references()
		return

	# ซ่อน legacy sprite ต่อเนื่อง เผื่อ Godot editor หรือ script อื่นเปิดกลับมา
	if hide_legacy_sprite:
		legacy_sprite.visible = false

	# ให้ AnimatedSprite2D แสดงผลเสมอในช่วงที่ใช้ visual ใหม่
	animated_sprite.visible = true

	# เลือก idle/run จากสถานะ Player
	var target_animation: StringName = choose_player_animation()
	play_animation_safely(target_animation)

	# sync การหันซ้าย/ขวาจากระบบเก่า เพื่อให้ไม่แยก logic ซ้ำหลายที่
	if sync_flip_from_legacy:
		animated_sprite.flip_h = legacy_sprite.flip_h

	# sync สี feedback เช่น hurt, no stamina, focus ready, posture broken
	if sync_modulate_from_legacy:
		animated_sprite.modulate = legacy_sprite.modulate


func choose_player_animation() -> StringName:
	# ตอนนี้มีแค่ idle/run เท่านั้น
	# ถ้ากำลังโจมตี dash โดนตี หรือ posture broken ให้ fallback เป็น idle ก่อน
	# เพื่อไม่ให้ run animation เล่นทับ action ที่ยังไม่มี animation ของตัวเอง
	if not run_animation_enabled:
		return idle_animation_name

	if not is_instance_valid(player):
		return idle_animation_name

	if get_bool_value(player, "is_dead"):
		return idle_animation_name

	if get_bool_value(player, "is_posture_broken"):
		return idle_animation_name

	if get_bool_value(player, "is_knocked_back"):
		return idle_animation_name

	if get_bool_value(player, "is_dashing"):
		return idle_animation_name

	if get_bool_value(player, "is_attacking"):
		return idle_animation_name

	var velocity_value = player.get("velocity")
	if velocity_value is Vector2:
		var player_velocity: Vector2 = velocity_value
		if absf(player_velocity.x) > run_velocity_threshold:
			return run_animation_name

	return idle_animation_name


func play_animation_safely(animation_name: StringName) -> void:
	# เล่น animation เฉพาะถ้ามีอยู่จริงใน SpriteFrames
	if not is_instance_valid(animated_sprite):
		return

	if animated_sprite.sprite_frames == null:
		return

	if not animated_sprite.sprite_frames.has_animation(animation_name):
		animation_name = idle_animation_name
		if not animated_sprite.sprite_frames.has_animation(animation_name):
			return

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
		return

	if not animated_sprite.is_playing():
		animated_sprite.play(animation_name)


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก Player แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true


func are_references_ready() -> bool:
	# ต้องมี Player, Sprite2D เดิม และ AnimatedSprite2D ใหม่
	return is_instance_valid(player) and is_instance_valid(legacy_sprite) and is_instance_valid(animated_sprite)
