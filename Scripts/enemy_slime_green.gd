extends Node2D

const SPEED = 40
var direction = 1
var is_awake = false
var player_detected = false

@onready var ray_cast_right: RayCast2D = $CharacterBody2D/RayCastRight
@onready var ray_cast_left: RayCast2D = $CharacterBody2D/RayCastLeft
@onready var anim_sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

func _ready():
	anim_sprite.play("slimeSleep")

func _process(delta: float) -> void:
	if is_awake:
		handle_movement(delta)

func handle_movement(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1
		
	position.x += direction * SPEED * delta



func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_awake:
		player_detected = true
		anim_sprite.play("slimeWakeUp")


func _on_animated_sprite_2d_animation_finished() -> void:
	if player_detected and anim_sprite.animation == "slimeWakeUp":
		is_awake = true
		anim_sprite.play("slimeWalk")
