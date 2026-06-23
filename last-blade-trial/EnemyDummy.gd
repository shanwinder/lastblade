extends CharacterBody2D

@export var max_hp: int = 30
@export var move_speed: float = 120.0
@export var stop_distance: float = 90.0

var current_hp: int
var player: CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	current_hp = max_hp
	player = get_parent().get_node("Player")
	print("Enemy ready. HP =", current_hp)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var distance_to_player: float = player.global_position.x - global_position.x

	if abs(distance_to_player) > stop_distance:
		velocity.x = sign(distance_to_player) * move_speed
	else:
		velocity.x = 0

	velocity.y = 0

	move_and_slide()

	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0


func take_damage(amount: int) -> void:
	current_hp -= amount
	print("Enemy took damage:", amount, "HP left:", current_hp)

	flash_red()

	if current_hp <= 0:
		die()


func flash_red() -> void:
	sprite_2d.modulate = Color.RED

	await get_tree().create_timer(0.1).timeout

	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE


func die() -> void:
	print("Enemy defeated!")
	queue_free()
