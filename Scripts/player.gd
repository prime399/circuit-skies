extends CharacterBody2D

@export var speed := 100
@export var gravity := 800
@export var jump_force := -350

# Node references
@onready var anim_idle = $playerIdle
@onready var anim_run = $playerRun
@onready var anim_jump = $playerJump
@onready var collider_idle = $collisionShapeIdle
@onready var collider_run = $collisionShapeRun
@onready var camera = $Camera2D
@onready var dust = $LandingDust

var input_dir = 0.0
var was_in_air = false
var previous_velocity_y = 0.0
var camera_shake_amount = 8
var camera_shake_duration = 0.1
var fall_speed_threshold = 500  # Minimum fall speed to trigger shake and dust
var jump_pressed = false
var slowmo_duration = 0.1  # 0.1 seconds slow motion
var slowmo_factor = 0.3    # 30% normal speed during slow motion


func _ready():
	switch_to_idle()

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle left/right input
	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_dir * speed

	# Flip ALL animations correctly
	if input_dir != 0:
		var dir = sign(input_dir)
		$playerIdle.scale.x = abs($playerIdle.scale.x) * dir
		$playerRun.scale.x = abs($playerRun.scale.x) * dir
		$playerJump.scale.x = abs($playerJump.scale.x) * dir

	# Handle Jump Input
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):  # Space pressed
			velocity.y = jump_force
			jump_pressed = true
			switch_to_jump()
		elif input_dir == 0:
			switch_to_idle()
		else:
			switch_to_run()
	else:
		# In air
		if jump_pressed:
			switch_to_jump()
		else:
			switch_to_jump()

	previous_velocity_y = velocity.y  # Save for fall speed check
	move_and_slide()

	handle_landing()

func handle_landing():
	var touching_ground = is_on_floor()

	if not was_in_air and not touching_ground:
		was_in_air = true

	if was_in_air and touching_ground:
		# Just landed
		was_in_air = false
		jump_pressed = false  # Reset jump flag
		if previous_velocity_y > fall_speed_threshold:
			do_camera_shake()
			spawn_landing_dust()
			do_slow_motion()  # Slow Mo


func do_camera_shake():
	camera.offset = Vector2(randf_range(-camera_shake_amount, camera_shake_amount), randf_range(-camera_shake_amount, camera_shake_amount))
	await get_tree().create_timer(camera_shake_duration).timeout
	camera.offset = Vector2.ZERO
	
func do_slow_motion():
	Engine.time_scale = slowmo_factor
	await get_tree().create_timer(slowmo_duration).timeout
	Engine.time_scale = 1.0


func spawn_landing_dust():
	var dust_scale_factor = clamp(previous_velocity_y / 1000.0, 0.5, 2.0)
	
	dust.emitting = false
	dust.scale = Vector2(dust_scale_factor, dust_scale_factor)
	dust.restart()
	dust.emitting = true


func switch_to_idle():
	anim_idle.visible = true
	anim_idle.play("idle")
	anim_run.visible = false
	anim_jump.visible = false
	collider_idle.disabled = false
	collider_run.disabled = true

func switch_to_run():
	anim_run.visible = true
	anim_run.play("running")
	anim_idle.visible = false
	anim_jump.visible = false
	collider_run.disabled = false
	collider_idle.disabled = true

func switch_to_jump():
	anim_jump.visible = true
	anim_jump.play("jump")
	anim_idle.visible = false
	anim_run.visible = false
	# collider: you can decide — keep last collider active
