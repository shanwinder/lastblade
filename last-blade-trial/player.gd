extends CharacterBody2D

@export var speed: float = 300.0
@export var attack_active_time: float = 0.18
@export var attack_recovery_time: float = 0.12

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var is_attacking: bool = false
var facing_direction: int = 1
var attack_hitbox_offset_x: float = 55.0


func _ready() -> void:
	attack_shape.disabled = true
	attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if is_attacking:
		velocity.x = 0
	else:
		velocity.x = direction * speed

	velocity.y = 0

	move_and_slide()

	if direction != 0 and not is_attacking:
		facing_direction = sign(direction)
		sprite_2d.flip_h = facing_direction < 0
		attack_hitbox.position.x = attack_hitbox_offset_x * facing_direction

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()


func attack() -> void:
	is_attacking = true
	print("Player Attack! Hitbox ON")

	attack_shape.disabled = false

	await get_tree().create_timer(attack_active_time).timeout

	attack_shape.disabled = true
	print("Hitbox OFF")

	await get_tree().create_timer(attack_recovery_time).timeout

	is_attacking = false
