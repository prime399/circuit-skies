extends CharacterBody2D

@export var speed := 100
@export var dash_speed := 400  # Dash speed
@export var gravity := 800
@export var jump_force := -350
@export var dash_duration := 0.2  # Dash lasts for 0.2 seconds
@export var dash_cooldown := 0.5  # Time before you can dash again

# Node references
@onready var anim_idle = $playerIdle
@onready var anim_run = $playerRun
@onready var anim_jump = $playerJump
@onready var anim_dash = $playerDash
@onready var collider_idle = $collisionShapeIdle
@onready var collider_run = $collisionShapeRun
@onready var collider_dash = $collisionShapeDash
@onready var camera = $Camera2D
@onready var dust = $LandingDust
@onready var DashGhost = preload("res://Scenes/entities/player/DashGhost.tscn")


var input_dir = 0.0
var was_in_air = false
var previous_velocity_y = 0.0
var camera_shake_amount = 8
var camera_shake_duration = 0.1
var fall_speed_threshold = 500
var jump_pressed = false
var slowmo_duration = 0.1
var slowmo_factor = 0.3

var is_dashing = false
var can_dash = true

func _ready():
	switch_to_idle()

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	# Apply gravity
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Handle left/right input
	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if is_dashing:
		velocity.x = sign(input_dir) * dash_speed
	else:
		velocity.x = input_dir * speed

	# Flip ALL animations correctly
	if input_dir != 0:
		var dir = sign(input_dir)
		$playerIdle.scale.x = abs($playerIdle.scale.x) * dir
		$playerRun.scale.x = abs($playerRun.scale.x) * dir
		$playerJump.scale.x = abs($playerJump.scale.x) * dir
		$playerDash.scale.x = abs($playerDash.scale.x) * dir

	# Handle Jump
	if is_on_floor() and not is_dashing:
		if Input.is_action_just_pressed("ui_accept"):  # Space pressed
			velocity.y = jump_force
			jump_pressed = true
			switch_to_jump()
		elif input_dir == 0:
			switch_to_idle()
		else:
			switch_to_run()
	elif not is_on_floor() and not is_dashing:
		if jump_pressed:
			switch_to_jump()

	# Handle Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and input_dir != 0:
		start_dash()


	previous_velocity_y = velocity.y
	move_and_slide()

	handle_landing()

func handle_landing():
	var touching_ground = is_on_floor()

	if not was_in_air and not touching_ground:
		was_in_air = true

	if was_in_air and touching_ground:
		was_in_air = false
		jump_pressed = false
		if previous_velocity_y > fall_speed_threshold:
			do_camera_shake()
			spawn_landing_dust()
			do_slow_motion()

func start_dash():
	is_dashing = true
	can_dash = false
	
	switch_to_dash()
	camera.zoom = Vector2(3.7, 3.5)  # Tiny zoom punch


	var dash_timer = 0.0
	while dash_timer < dash_duration:
		spawn_dash_ghost()
		await get_tree().create_timer(0.05).timeout  # spawn ghost every 0.05s
		dash_timer += 0.05

	await get_tree().create_timer(dash_duration - dash_timer).timeout
	camera.zoom = Vector2(3.5, 3.5)  # Reset zoom
	is_dashing = false
	can_dash = true

	if input_dir == 0:
		switch_to_idle()
	else:
		switch_to_run()


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
	anim_dash.visible = false
	collider_idle.disabled = false
	collider_run.disabled = true
	collider_dash.disabled = true

func switch_to_run():
	anim_run.visible = true
	anim_run.play("running")
	anim_idle.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	collider_run.disabled = false
	collider_idle.disabled = true
	collider_dash.disabled = true

func switch_to_jump():
	anim_jump.visible = true
	anim_jump.play("jump")
	anim_idle.visible = false
	anim_run.visible = false
	anim_dash.visible = false
	# collider: you can keep last active collider

func switch_to_dash():
	anim_dash.visible = true
	anim_dash.play("dash")
	anim_idle.visible = false
	anim_run.visible = false
	anim_jump.visible = false
	collider_dash.disabled = false
	collider_idle.disabled = true
	collider_run.disabled = true
	
func spawn_dash_ghost():
	var ghost = DashGhost.instantiate()
	ghost.position = global_position
	ghost.scale = scale  # Keep size correct
	get_parent().add_child(ghost)

	# Flip ghost direction based on player direction
	ghost.get_node("AnimatedSprite2D").flip_h = ($playerDash.scale.x < 0)

	# Color Tint: Slight Greenish Purple
	ghost.modulate = Color(0.6, 0.4, 0.8, 0.6)  # Light purple-green with transparency

	ghost.z_index = -1  # Behind player

	# Tween for fade out
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0, 0.3).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	ghost.queue_free()
