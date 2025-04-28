extends CanvasLayer

@onready var score_lbl  = $Panel/VBoxContainer/ScoreLabel
@onready var rank_lbl   = $Panel/VBoxContainer/RankLabel
@onready var restart_btn= $Panel/VBoxContainer/RestartButton

func _ready():
	visible = false
	# Connect the button's pressed signal (Godot 4 syntax)
	restart_btn.pressed.connect(_on_restart_pressed)

func show_end(total_score: int, player_rank: String) -> void:
	score_lbl.text = "Score: %d"   % total_score
	rank_lbl.text  = "Rank: %s"    % player_rank
	visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	# Change to the main game scene (which includes the main menu)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
