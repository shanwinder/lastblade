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

# ชื่อ animation เดินถอยหลัง / backpedal ใน SpriteFrames resource
@export var back_animation_name: StringName = &"back"

# ชื่อ animation โจมตีหลักของ Player
@export var attack_animation_name: StringName = &"attack_1"

# โฟลเดอร์ที่เก็บ frame โจมตีแบบ .png เรียงตามชื่อไฟล์
@export var attack_frames_folder: String = "res://assets/sprites/player/nameless_blade/frames/attack_1"

# ชื่อ animation โจมตีแยกตาม combo hit
@export var attack_1_animation_name: StringName = &"attack_1"
@export var attack_2_animation_name: StringName = &"attack_2"
@export var attack_3_animation_name: StringName = &"attack_3"

# โฟลเดอร์ frame โจมตีแยกตาม combo hit
@export var attack_1_frames_folder: String = "res://assets/sprites/player/nameless_blade/frames/attack_1"
@export var attack_2_frames_folder: String = "res://assets/sprites/player/nameless_blade/frames/attack_2"
@export var attack_3_frames_folder: String = "res://assets/sprites/player/nameless_blade/frames/attack_3"

# เปิด/ปิดการโหลดและใช้ animation โจมตีจากโฟลเดอร์ attack_1
@export var attack_animation_enabled: bool = true

# ความเร็ว animation โจมตี หน่วยเป็น frames per second
@export var attack_animation_speed: float = 12.0

# ปกติท่าโจมตีไม่ควรวน loop เพราะเป็น action สั้น ๆ หนึ่งครั้ง
@export var attack_animation_loop: bool = false

# ถ้า true จะกลับ flip เฉพาะท่า attack_1
# ใช้เมื่อ source sprite ของ attack_1 หันคนละทิศกับ idle/run
@export var invert_attack_animation_flip: bool = true

# เปิด/ปิดการเลือก run animation จากความเร็วของ Player
@export var run_animation_enabled: bool = true

# เปิด/ปิดการเลือก back animation เมื่อ lock-on แล้วถอยหลัง
@export var back_animation_enabled: bool = true

# ถ้า true จะกลับ flip เฉพาะท่า back เพราะ source sprite ของ back ถูกวาดคนละทิศกับ idle/run
@export var invert_back_animation_flip: bool = true

# ความเร็วแนวนอนขั้นต่ำที่จะถือว่า Player กำลังวิ่งหรือถอยหลัง
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
		# โหลด frame โจมตีจากโฟลเดอร์ attack_1 เข้าสู่ SpriteFrames ตอน runtime
		load_attack_animation_if_needed()

		# ให้ animation เริ่มจาก idle เมื่อพร้อม
		play_animation_safely(idle_animation_name)

	if hide_legacy_sprite and is_instance_valid(legacy_sprite):
		# ซ่อนภาพนิ่งเดิมเพื่อไม่ให้ซ้อนกับ AnimatedSprite2D
		# แต่ยังเก็บ node นี้ไว้ให้ player.gd ใช้ texture, flip_h และ modulate ต่อไป
		legacy_sprite.visible = false

	if debug_print_visual and is_instance_valid(animated_sprite):
		print(
			"PlayerAnimatedIdleVisualManager ready. Idle =", idle_animation_name,
			" Run =", run_animation_name,
			" Back =", back_animation_name,
			" Attack =", attack_animation_name
		)


func load_attack_animation_if_needed() -> void:
	# โหลดเฉพาะไฟล์ .png ที่เป็น frame จริง แล้วสร้าง animation attack_1/2/3 ให้อัตโนมัติ
	# วิธีนี้ไม่ผูกกับชื่อไฟล์ frame ขอแค่ตั้งชื่อเรียงลำดับ เช่น 0001, 0002, 0003
	if not attack_animation_enabled:
		return

	if not is_instance_valid(animated_sprite):
		return

	if animated_sprite.sprite_frames == null:
		return

	load_attack_animation_from_folder(attack_1_animation_name, get_attack_frames_folder_for_step(1), true)
	load_attack_animation_from_folder(attack_2_animation_name, get_attack_frames_folder_for_step(2), false)
	load_attack_animation_from_folder(attack_3_animation_name, get_attack_frames_folder_for_step(3), false)


func load_attack_animation_from_folder(animation_name: StringName, frames_folder: String, is_required: bool) -> void:
	var directory := DirAccess.open(frames_folder)
	if directory == null:
		if debug_print_visual and is_required:
			print("Attack animation folder not found: ", frames_folder)
		return

	var frame_files: Array[String] = []
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and is_valid_attack_frame_file(file_name):
			frame_files.append(file_name)
		elif debug_print_visual and not directory.current_is_dir() and file_name.to_lower().ends_with(".png"):
			print("Skipped non-canonical attack frame: ", file_name)
		file_name = directory.get_next()
	directory.list_dir_end()

	frame_files.sort()
	if frame_files.is_empty():
		if debug_print_visual:
			print("Attack animation folder has no .png frames: ", frames_folder)
		return

	var sprite_frames := animated_sprite.sprite_frames
	if sprite_frames.has_animation(animation_name):
		sprite_frames.remove_animation(animation_name)
	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_speed(animation_name, attack_animation_speed)
	sprite_frames.set_animation_loop(animation_name, attack_animation_loop)

	for frame_file in frame_files:
		var texture_path := frames_folder.path_join(frame_file)
		var texture := load_frame_texture(texture_path)
		if texture != null:
			sprite_frames.add_frame(animation_name, texture)

	if debug_print_visual:
		print("Loaded attack animation frames: ", sprite_frames.get_frame_count(animation_name), " from ", frames_folder)


func is_valid_attack_frame_file(file_name: String) -> bool:
	# กันไฟล์สำเนาจากระบบหรือการ export เช่น atk3 (1).png ไม่ให้หลุดเข้า animation
	var lower_name := file_name.to_lower()
	if not lower_name.ends_with(".png"):
		return false

	var base_name := lower_name.get_basename()
	if lower_name.contains(" (") and base_name.ends_with(")"):
		return false

	return true


func load_frame_texture(texture_path: String) -> Texture2D:
	# ใช้ ResourceLoader ก่อนสำหรับ asset ที่ import แล้ว และ fallback เป็น Image.load สำหรับไฟล์ใหม่/placeholder
	if ResourceLoader.exists(texture_path):
		var imported_texture := load(texture_path)
		if imported_texture is Texture2D:
			return imported_texture

	var image := Image.new()
	var error := image.load(texture_path)
	if error != OK:
		if debug_print_visual:
			print("Failed to load attack frame texture: ", texture_path)
		return null

	return ImageTexture.create_from_image(image)


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

	# เลือก idle/run/back/attack จากสถานะ Player
	var target_animation: StringName = choose_player_animation()
	play_animation_safely(target_animation)

	# sync การหันซ้าย/ขวาจากระบบเก่า เพื่อให้ไม่แยก logic ซ้ำหลายที่
	if sync_flip_from_legacy:
		apply_animation_flip(target_animation)

	# sync สี feedback เช่น hurt, no stamina, focus ready, posture broken
	if sync_modulate_from_legacy:
		animated_sprite.modulate = legacy_sprite.modulate


func apply_animation_flip(target_animation: StringName) -> void:
	# ปกติให้ AnimatedSprite2D ใช้ flip เดียวกับ Sprite2D compatibility layer
	var target_flip_h: bool = legacy_sprite.flip_h

	# เฉพาะท่า back ให้สลับภาพ เพราะชุดภาพ back ถูกวาดกลับฝั่งจาก idle/run
	if invert_back_animation_flip and target_animation == back_animation_name:
		target_flip_h = not target_flip_h

	# เฉพาะท่าโจมตีให้สลับได้ เพราะ asset โจมตีอาจสร้างมาคนละทิศกับ idle
	if invert_attack_animation_flip and is_attack_animation_name(target_animation):
		target_flip_h = not target_flip_h

	animated_sprite.flip_h = target_flip_h


func choose_player_animation() -> StringName:
	# ตอนนี้รองรับ idle/run/back/attack_1
	# ถ้ากำลัง dash โดนตี หรือ posture broken ให้ fallback เป็น idle ก่อน
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

	# เมื่อ Player อยู่ในช่วงโจมตี ให้ใช้ animation ตาม combo_step และ fallback เป็น attack_1 ถ้า asset ยังไม่ครบ
	if attack_animation_enabled and get_bool_value(player, "is_attacking"):
		return get_attack_animation_for_current_combo_step()

	if get_bool_value(player, "is_attacking"):
		return idle_animation_name

	var player_velocity: Vector2 = get_player_velocity()
	if absf(player_velocity.x) <= run_velocity_threshold:
		return idle_animation_name

	# ถ้า lock-on อยู่และเคลื่อนที่สวนทางกับทิศที่หันหน้า ให้ใช้ท่าถอยหลัง
	# ตัวอย่าง: หันขวาเข้าหา Boss แต่ velocity.x < 0 คือถอยหลัง
	if back_animation_enabled and is_player_backpedaling(player_velocity):
		return back_animation_name

	if run_animation_enabled:
		return run_animation_name

	return idle_animation_name


func get_player_velocity() -> Vector2:
	# อ่าน velocity จาก CharacterBody2D แบบปลอดภัย
	var velocity_value = player.get("velocity")
	if velocity_value is Vector2:
		return velocity_value

	return Vector2.ZERO


func is_player_backpedaling(player_velocity: Vector2) -> bool:
	# Backpedal ใช้เฉพาะตอน lock-on เพื่อแยกจากการเดินซ้าย/ขวาปกติ
	if not get_bool_value(player, "is_target_locked"):
		return false

	var facing_value = player.get("facing_direction")
	if facing_value == null:
		return false

	var facing_direction: int = int(facing_value)
	if facing_direction == 0:
		return false

	var movement_direction: int = int(sign(player_velocity.x))
	if movement_direction == 0:
		return false

	# ถ้า velocity สวนทางกับทิศที่หันหน้า แปลว่าถอยหลัง
	return movement_direction != facing_direction


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
		# ท่าโจมตีเป็น non-loop action ถ้าจบแล้วให้ค้างเฟรมท้ายจน player.gd ปิด is_attacking
		# เพื่อไม่ให้ animation โจมตี replay ซ้ำระหว่าง attack recovery
		if not is_attack_animation_name(animation_name):
			animated_sprite.play(animation_name)


func get_attack_frames_folder_for_step(step: int) -> String:
	match step:
		1:
			if attack_1_frames_folder != "":
				return attack_1_frames_folder
			return attack_frames_folder
		2:
			return attack_2_frames_folder
		3:
			return attack_3_frames_folder
		_:
			return attack_frames_folder


func get_attack_animation_for_current_combo_step() -> StringName:
	var step := get_int_value(player, "combo_step", 1)
	var animation_name := get_attack_animation_name_for_step(step)

	if has_animation(animation_name):
		return animation_name

	if has_animation(attack_1_animation_name):
		return attack_1_animation_name

	if has_animation(attack_animation_name):
		return attack_animation_name

	return idle_animation_name


func get_attack_animation_name_for_step(step: int) -> StringName:
	match step:
		1:
			return attack_1_animation_name
		2:
			return attack_2_animation_name
		3:
			return attack_3_animation_name
		_:
			return attack_1_animation_name


func is_attack_animation_name(animation_name: StringName) -> bool:
	return (
		animation_name == attack_animation_name
		or animation_name == attack_1_animation_name
		or animation_name == attack_2_animation_name
		or animation_name == attack_3_animation_name
	)


func has_animation(animation_name: StringName) -> bool:
	if not is_instance_valid(animated_sprite):
		return false

	if animated_sprite.sprite_frames == null:
		return false

	return animated_sprite.sprite_frames.has_animation(animation_name)


func get_int_value(target: Node, property_name: String, fallback: int) -> int:
	var value = target.get(property_name)
	if value == null:
		return fallback

	return int(value)


func get_bool_value(target: Node, property_name: String) -> bool:
	# อ่านค่า bool จาก Player แบบปลอดภัย เผื่อ property ไม่มีในอนาคต
	var value = target.get(property_name)
	if value == null:
		return false

	return value == true


func are_references_ready() -> bool:
	# ต้องมี Player, Sprite2D เดิม และ AnimatedSprite2D ใหม่
	return is_instance_valid(player) and is_instance_valid(legacy_sprite) and is_instance_valid(animated_sprite)
