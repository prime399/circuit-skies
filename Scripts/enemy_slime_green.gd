extends Node2D

const SPEED = 40
const ATTACK_SPEED = 10  # Slow movement when attacking
const DAMAGE = 50

var direction = 1
var is_awake = false
var player_detected = false
var attacking = false
var player_in_body_area = false  # <<< NEW: track if player still nearby

@onready var ray_cast_right: RayCast2D = $CharacterBody2D/RayCastRight
@onready var ray_cast_left: RayCast2D = $CharacterBody2D/RayCastLeft
@onready var anim_sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var player_detector: Area2D = $PlayerDetector
@onready var body_area: Area2D = $BodyArea
@onready var slime_sound_player = AudioStreamPlayer2D.new() # Use 2D player for positional audio
@onready var slime_sound_timer = Timer.new()

func _ready():
	anim_sprite.play("slimeSleep")
	player_detector.body_entered.connect(_on_player_detector_body_entered)
	body_area.body_entered.connect(_on_body_area_entered)
	body_area.body_exited.connect(_on_body_area_exited)

	# Setup sound player (AudioStreamPlayer2D)
	add_child(slime_sound_player)
	slime_sound_player.stream = load("res://Assets/previous project assest/sounds/green_slime.mp3")
	slime_sound_player.volume_db = -8 # Make the slime sound quieter overall
	# Default attenuation settings will make sound quieter with distance.

	# Setup sound timer
	add_child(slime_sound_timer)
	slime_sound_timer.wait_time = 2.0 # 2 second delay
	slime_sound_timer.one_shot = false # Make it loop
	slime_sound_timer.timeout.connect(_on_slime_sound_timer_timeout)

func _process(delta: float) -> void:
	if is_awake:
		handle_movement(delta)

func handle_movement(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1

	anim_sprite.flip_h = (direction == -1)

	var move_speed = ATTACK_SPEED if attacking else SPEED  # <<<<< FIXED

	position.x += direction * move_speed * delta

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not is_awake:
			player_detected = true
			anim_sprite.play("slimeWakeUp")

func _on_body_area_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_awake:
		player_in_body_area = true
		attacking = true
		anim_sprite.play("slimeAttack")
		body.take_damage(DAMAGE, direction)

func _on_body_area_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_body_area = false
		attacking = false
		if is_awake:
			anim_sprite.play("slimeWalk")

func _on_animated_sprite_2d_animation_finished() -> void:
	if player_detected and anim_sprite.animation == "slimeWakeUp":
		is_awake = true
		anim_sprite.play("slimeWalk")
		slime_sound_timer.start() # Start the sound loop when awake
		_on_slime_sound_timer_timeout() # Play the first sound immediately
	elif attacking and anim_sprite.animation == "slimeAttack":
		# After attack animation ends, return to walk if player escaped
		if not player_in_body_area:
			anim_sprite.play("slimeWalk")

func _on_slime_sound_timer_timeout():
	# This function is called every 2 seconds by the timer
	if is_awake: # Double check if still awake before playing
		slime_sound_player.play()
