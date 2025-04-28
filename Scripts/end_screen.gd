extends CanvasLayer

@onready var score_lbl  = $Panel/VBoxContainer/ScoreLabel
@onready var rank_lbl   = $Panel/VBoxContainer/RankLabel
@onready var restart_btn= $Panel/VBoxContainer/RestartButton

func _ready():
	visible = false
	# Connect the button's pressed signal (like GameOverOverlay)
	restart_btn.pressed.connect(_on_restart_pressed)

func show_end(total_score: int, player_rank: String) -> void:
	score_lbl.text = "Score: %d"   % total_score
	rank_lbl.text  = "Rank: %s"    % player_rank
	visible = true
	get_tree().paused = true # Pause when the end screen shows

# Handle restart button press (like GameOverOverlay)
func _on_restart_pressed() -> void:
	# Hide the end screen first
	visible = false
	# Ensure game is unpaused before changing scene via GameManager
	get_tree().paused = false
	# Tell GameManager to handle the restart (resets score, changes scene)
	GameManager.restart_game()
	# Note: We don't queue_free() this overlay like GameOverOverlay does,
	# because this EndScreen is part of the persistent game.tscn,
	# while GameOverOverlay is added dynamically on death.
