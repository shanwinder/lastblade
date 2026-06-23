extends CharacterBody2D

@export var speed: float = 300.0

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if is_attacking:
		velocity.x = 0
	else:
		velocity.x = direction * speed

	velocity.y = 0

	move_and_slide()

	if direction != 0 and not is_attacking:
		$Sprite2D.flip_h = direction < 0

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()


func attack() -> void:
	is_attacking = true
	print("Player Attack!")

	await get_tree().create_timer(0.3).timeout

	is_attacking = false
