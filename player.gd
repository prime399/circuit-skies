extends CharacterBody2D

@export var speed := 200
@export var jump_velocity := -350
@export var gravity := 800

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Optional: Reset vertical velocity when grounded
		velocity.y = 0

	# Handle horizontal input
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * speed

	# Handle jump
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	# Apply movement
	move_and_slide()
