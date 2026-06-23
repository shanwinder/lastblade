extends CharacterBody2D

@export var max_hp: int = 30

var current_hp: int

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	current_hp = max_hp
	print("Enemy ready. HP =", current_hp)


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
