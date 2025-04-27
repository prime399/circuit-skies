extends CharacterBody2D

@export var speed := 70
@export var dash_speed := 250
@export var gravity := 400
@export var jump_force := -230
@export var dash_duration := 0.3
@export var dash_cooldown := 0.5
@export var max_hp := 100
@export var hp_regen_rate := 5
@export var knockback_horizontal := 150
@export var knockback_vertical := -250
@export var invincible_time := 1.0
@export var blink_speed := 0.1

@export var max_boost := 100
@export var boost_regen_rate := 10
@export var dash_boost_cost := 40

@onready var anim_idle = $playerIdle
@onready var anim_run = $playerRun
@onready var anim_jump = $playerJump
@onready var anim_dash = $playerDash
@onready var anim_died = $playerDied

@onready var collider_idle = $collisionShapeIdle
@onready var collider_run = $collisionShapeRun
@onready var collider_dash = $collisionShapeDash

@onready var camera = $Camera2D
@onready var dust = $LandingDust
@onready var DashGhost = preload("res://Scenes/entities/player/DashGhost.tscn")

var spawn_point: Node2D = null


var input_dir = 0.0
var was_in_air = false
var previous_velocity_y = 0.0

var is_dashing = false
var can_dash = true
var is_invincible = false

var hp = 100
var boost = 100



func _ready():
	await get_tree().process_frame  # wait 1 frame for all children to load

	var current_level = get_node("../CurrentLevel")  # step 1: assign
	if current_level:                                # step 2: check
		spawn_point = current_level.find_node("PlayerSpawnPoint", true, false)  # step 3: assign
		if spawn_point == null:
			push_error("PlayerSpawnPoint not found inside CurrentLevel!")
	else:
		push_error("CurrentLevel node not found!")

	hp = max_hp
	boost = max_boost
	GameManager.update_hp(hp)
	GameManager.update_boost(boost)
	switch_to_idle()
	

	
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	handle_movement(delta)
	move_and_slide()

	handle_landing()
	handle_regen(delta)

func handle_movement(delta):
	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if is_dashing:
		velocity.x = sign(input_dir) * dash_speed
	else:
		velocity.x = input_dir * speed

	# Flip all sprites
	if input_dir != 0:
		var dir = sign(input_dir)
		anim_idle.scale.x = abs(anim_idle.scale.x) * dir
		anim_run.scale.x = abs(anim_run.scale.x) * dir
		anim_jump.scale.x = abs(anim_jump.scale.x) * dir
		anim_dash.scale.x = abs(anim_dash.scale.x) * dir

	# Animation switching
	if is_on_floor() and not is_dashing:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force
			switch_to_jump()
		elif input_dir == 0:
			switch_to_idle()
		else:
			switch_to_run()
	elif not is_on_floor() and not is_dashing:
		switch_to_jump()

	# Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and input_dir != 0 and boost >= dash_boost_cost:
		start_dash()

func handle_landing():
	var touching_ground = is_on_floor()

	if not was_in_air and not touching_ground:
		was_in_air = true
	if was_in_air and touching_ground:
		was_in_air = false
		if previous_velocity_y > 500:
			do_camera_shake()
			spawn_landing_dust()
			do_slow_motion()

	previous_velocity_y = velocity.y

func handle_regen(delta):
	if hp < max_hp:
		hp += hp_regen_rate * delta
		hp = clamp(hp, 0, max_hp)
		GameManager.update_hp(hp)

	if boost < max_boost:
		boost += boost_regen_rate * delta
		boost = clamp(boost, 0, max_boost)
		GameManager.update_boost(boost)

# ========================
# DAMAGE + INVINCIBILITY
# ========================

func take_damage(amount, knockback_dir):
	if is_invincible:
		return

	hp -= amount
	GameManager.update_hp(hp)

	# Knockback
	velocity.x = knockback_dir * knockback_horizontal
	velocity.y = knockback_vertical

	if hp <= 0:
		die()
	else:
		start_invincibility()

func start_invincibility():
	is_invincible = true
	var elapsed = 0.0
	while elapsed < invincible_time:
		visible = false
		await get_tree().create_timer(blink_speed).timeout
		visible = true
		await get_tree().create_timer(blink_speed).timeout
		elapsed += blink_speed * 2

	is_invincible = false
	visible = true


func die():
	anim_died.visible = true
	anim_died.play("death")
	anim_idle.visible = false
	anim_run.visible = false
	anim_jump.visible = false
	anim_dash.visible = false

	await get_tree().create_timer(1.0).timeout

	if spawn_point:
		global_position = spawn_point.global_position
	else:
		print("Warning: spawn_point missing!")

	hp = max_hp
	GameManager.update_hp(hp)
	boost = max_boost
	GameManager.update_boost(boost)
	is_invincible = false
	switch_to_idle()



# ========================
# DASH
# ========================

func start_dash():
	is_dashing = true
	can_dash = false
	boost -= dash_boost_cost
	GameManager.update_boost(boost)
	switch_to_dash()
	camera.zoom = Vector2(3.7, 3.5)

	var dash_timer = 0.0
	while dash_timer < dash_duration:
		spawn_dash_ghost()
		await get_tree().create_timer(0.05).timeout
		dash_timer += 0.05

	await get_tree().create_timer(dash_duration - dash_timer).timeout
	camera.zoom = Vector2(3.5, 3.5)
	is_dashing = false
	can_dash = true

	if input_dir == 0:
		switch_to_idle()
	else:
		switch_to_run()

func spawn_dash_ghost():
	var ghost = DashGhost.instantiate()
	ghost.position = global_position
	ghost.scale = scale
	get_parent().add_child(ghost)
	ghost.get_node("AnimatedSprite2D").flip_h = (anim_dash.scale.x < 0)
	ghost.modulate = Color(0.6, 0.4, 0.8, 0.6)
	ghost.z_index = -1
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0, 0.3).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	ghost.queue_free()

# ========================
# LANDING FX
# ========================

func do_camera_shake():
	camera.offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	await get_tree().create_timer(0.1).timeout
	camera.offset = Vector2.ZERO

func do_slow_motion():
	Engine.time_scale = 0.3
	await get_tree().create_timer(0.1).timeout
	Engine.time_scale = 1.0

func spawn_landing_dust():
	var dust_scale_factor = clamp(previous_velocity_y / 1000.0, 0.5, 2.0)
	dust.emitting = false
	dust.scale = Vector2(dust_scale_factor, dust_scale_factor)
	dust.restart()
	dust.emitting = true

# ========================
# ANIMATION SWITCHING
# ========================

func switch_to_idle():
	anim_idle.visible = true
	anim_idle.play("idle")
	anim_run.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	anim_died.visible = false
	collider_idle.disabled = false
	collider_run.disabled = true
	collider_dash.disabled = true

func switch_to_run():
	anim_run.visible = true
	anim_run.play("running")
	anim_idle.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	anim_died.visible = false
	collider_run.disabled = false
	collider_idle.disabled = true
	collider_dash.disabled = true

func switch_to_jump():
	anim_jump.visible = true
	anim_jump.play("jump")
	anim_idle.visible = false
	anim_run.visible = false
	anim_dash.visible = false
	anim_died.visible = false

func switch_to_dash():
	anim_dash.visible = true
	anim_dash.play("dash")
	anim_idle.visible = false
	anim_run.visible = false
	anim_jump.visible = false
	anim_died.visible = false
	collider_dash.disabled = false
	collider_idle.disabled = true
	collider_run.disabled = true
