extends Node

# =========================
# PlayerAnimatedIdleVisualManager.gd
# ตัวจัดภาพ idle animation ของ Player ช่วงเปลี่ยนผ่านจาก Sprite2D ไป AnimatedSprite2D
# ใช้ AnimatedSprite2D เป็นภาพที่ผู้เล่นเห็นจริง แต่ยังเก็บ Sprite2D เดิมไว้เป็น compatibility layer
# เพื่อไม่ให้ dash trail / feedback สี / player.gd เดิมพังใน Phase 4
# =========================

# เปิด/ปิดระบบภาพ AnimatedSprite2D
@export var animated_idle_enabled: bool = true

# อ้างอิง Sprite2D เดิมที่ player.gd ยังใช้อยู่
@export var legacy_sprite_path: NodePath = NodePath("../Sprite2D")

# อ้างอิง AnimatedSprite2D ใหม่ที่ใช้แสดง idle animation จริง
@export var animated_sprite_path: NodePath = NodePath("../AnimatedSprite2D")

# ชื่อ animation idle ใน SpriteFrames resource
@export var idle_animation_name: StringName = &"idle"

# ถ้า true จะซ่อน Sprite2D เดิม เพื่อไม่ให้ภาพนิ่งซ้อนกับ idle animation
@export var hide_legacy_sprite: bool = true

# ถ้า true จะ sync flip_h จาก Sprite2D เดิมไป AnimatedSprite2D
@export var sync_flip_from_legacy: bool = true

# ถ้า true จะ sync สี/feedback modulate จาก Sprite2D เดิมไป AnimatedSprite2D
@export var sync_modulate_from_legacy: bool = true

# เปิด/ปิด debug print ตอน setup
@export var debug_print_visual: bool = true

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
	# หา Sprite2D เดิมจาก path
	legacy_sprite = get_node_or_null(legacy_sprite_path) as Sprite2D

	# หา AnimatedSprite2D ใหม่จาก path
	animated_sprite = get_node_or_null(animated_sprite_path) as AnimatedSprite2D

	if animated_idle_enabled and is_instance_valid(animated_sprite):
		# ให้ idle animation เล่นวนทันทีเมื่อพร้อม
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(idle_animation_name):
			animated_sprite.animation = idle_animation_name
			animated_sprite.play(idle_animation_name)

	if hide_legacy_sprite and is_instance_valid(legacy_sprite):
		# ซ่อนภาพนิ่งเดิมเพื่อไม่ให้ซ้อนกับ AnimatedSprite2D
		# แต่ยังเก็บ node นี้ไว้ให้ player.gd ใช้ texture, flip_h และ modulate ต่อไป
		legacy_sprite.visible = false

	if debug_print_visual and is_instance_valid(animated_sprite):
		print("PlayerAnimatedIdleVisualManager ready. Animation =", idle_animation_name)


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

	# ให้ AnimatedSprite2D แสดงผลและเล่น idle ต่อเนื่อง
	animated_sprite.visible = true
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(idle_animation_name):
		if animated_sprite.animation != idle_animation_name:
			animated_sprite.animation = idle_animation_name
		if not animated_sprite.is_playing():
			animated_sprite.play(idle_animation_name)

	# sync การหันซ้าย/ขวาจากระบบเก่า เพื่อให้ไม่แยก logic ซ้ำหลายที่
	if sync_flip_from_legacy:
		animated_sprite.flip_h = legacy_sprite.flip_h

	# sync สี feedback เช่น hurt, no stamina, focus ready, posture broken
	if sync_modulate_from_legacy:
		animated_sprite.modulate = legacy_sprite.modulate


func are_references_ready() -> bool:
	# ต้องมีทั้ง Sprite2D เดิมและ AnimatedSprite2D ใหม่
	return is_instance_valid(legacy_sprite) and is_instance_valid(animated_sprite)
