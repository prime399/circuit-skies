extends CharacterBody2D

@export var speed := 50
@export var dash_speed := 250
@export var gravity := 400
@export var jump_force := -230
@export var dash_duration := 0.2
@export var dash_cooldown := 0.5
@export var max_hp := 100
@export var hp_regen_rate := 5
@export var knockback_horizontal := 150
@export var knockback_vertical := -250
@export var hurt_recovery_time := 0.4
@export var invincible_time := 1.0
@export var blink_speed := 0.1      # (flicker every 0.1s)

@export var max_boost := 100        # <<< NEW Boost System
@export var boost_regen_rate := 20  # <<< NEW Boost recharge per second
@export var dash_boost_cost := 40   # <<< NEW Boost cost per dash

# Node references
@onready var anim_idle = $playerIdle
@onready var anim_run = $playerRun
@onready var anim_jump = $playerJump
@onready var anim_dash = $playerDash
@onready var anim_damage = $playerDamage
@onready var anim_died = $playerDied

@onready var collider_idle = $collisionShapeIdle
@onready var collider_run = $collisionShapeRun
@onready var collider_dash = $collisionShapeDash

@onready var camera = $Camera2D
@onready var dust = $LandingDust
@onready var DashGhost = preload("res://Scenes/entities/player/DashGhost.tscn")

var input_dir = 0.0
var was_in_air = false
var previous_velocity_y = 0.0

var is_dashing = false
var can_dash = true
var is_hurt = false
var is_invincible = false

var hp = 100
var boost = 100 # <<< NEW
var respawn_position = Vector2()

func _ready():
	respawn_position = global_position
	hp = max_hp
	boost = max_boost # <<< NEW
	GameManager.update_hp(hp)
	GameManager.update_boost(boost) # <<< NEW
	switch_to_idle()

func _physics_process(delta):
	apply_gravity(delta)

	if not is_hurt:
		handle_movement(delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)  # Slowly reduce knockback x velocity

	move_and_slide()
	handle_landing()
	handle_regen(delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0


func handle_movement(delta):
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if is_dashing:
		velocity.x = sign(input_dir) * dash_speed
	else:
		velocity.x = input_dir * speed

	# Flip all sprites
	if input_dir != 0:
		var dir = sign(input_dir)
		$playerIdle.scale.x = abs($playerIdle.scale.x) * dir
		$playerRun.scale.x = abs($playerRun.scale.x) * dir
		$playerJump.scale.x = abs($playerJump.scale.x) * dir
		$playerDash.scale.x = abs($playerDash.scale.x) * dir
		$playerDamage.scale.x = abs($playerDamage.scale.x) * dir

	# Jump
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
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and input_dir != 0 and boost >= dash_boost_cost: # <<< NEW Boost Check
		start_dash()

	move_and_slide()

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

	if boost < max_boost: # <<< NEW Boost Regen
		boost += boost_regen_rate * delta
		boost = clamp(boost, 0, max_boost)
		GameManager.update_boost(boost)

# ========================
# DAMAGE + INVINCIBILITY
# ========================

func take_damage(amount, knockback_dir):
	if is_hurt or is_invincible:
		return  # No damage if already hurt or invincible

	hp -= amount
	GameManager.update_hp(hp)

	switch_to_damage()

	# Knockback
	velocity.x = knockback_dir * knockback_horizontal
	velocity.y = knockback_vertical

	is_hurt = true

	if hp <= 0:
		die()
	else:
		start_invincibility()

func start_invincibility():
	is_invincible = true
	await get_tree().create_timer(hurt_recovery_time).timeout
	# is_hurt reset and switch_to_idle moved to _on_player_damage_animation_finished

	# Blinking effect
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
	anim_damage.visible = false

	await get_tree().create_timer(1.0).timeout
	global_position = respawn_position
	hp = max_hp
	GameManager.update_hp(hp)
	boost = max_boost # <<< NEW Reset Boost
	GameManager.update_boost(boost) # <<< NEW Update Boost UI
	is_hurt = false
	is_invincible = false
	switch_to_idle()

# ========================
# DASH STUFF
# ========================

func start_dash():
	is_dashing = true
	can_dash = false
	boost -= dash_boost_cost # <<< NEW Consume Boost
	GameManager.update_boost(boost) # <<< NEW Update Boost UI
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
	ghost.get_node("AnimatedSprite2D").flip_h = ($playerDash.scale.x < 0)
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
	if is_hurt:
		return
	anim_idle.visible = true
	anim_idle.play("idle")
	anim_run.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	anim_damage.visible = false
	anim_died.visible = false
	collider_idle.disabled = false
	collider_run.disabled = true
	collider_dash.disabled = true

func switch_to_run():
	if is_hurt:
		return
	anim_run.visible = true
	anim_run.play("running")
	anim_idle.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	anim_damage.visible = false
	anim_died.visible = false
	collider_run.disabled = false
	collider_idle.disabled = true
	collider_dash.disabled = true

func switch_to_jump():
	if is_hurt:
		return
	anim_jump.visible = true
	anim_jump.play("jump")
	anim_idle.visible = false
	anim_run.visible = false
	anim_dash.visible = false
	anim_damage.visible = false
	anim_died.visible = false

func switch_to_dash():
	if is_hurt:
		return
	anim_dash.visible = true
	anim_dash.play("dash")
	anim_idle.visible = false
	anim_run.visible = false
	anim_jump.visible = false
	anim_damage.visible = false
	anim_died.visible = false
	collider_dash.disabled = false
	collider_idle.disabled = true
	collider_run.disabled = true

func switch_to_damage():
	anim_damage.visible = true
	anim_damage.play("damage")
	anim_idle.visible = false
	anim_run.visible = false
	anim_jump.visible = false
	anim_dash.visible = false
	anim_died.visible = false

# <<< NEW Function to handle end of damage animation
func _on_player_damage_animation_finished():
	is_hurt = false
	# Don't switch if already invincible (blinking)
	if not is_invincible:
		switch_to_idle()
