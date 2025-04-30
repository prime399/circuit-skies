extends CanvasLayer

@onready var score_lbl  = $Panel/VBoxContainer/ScoreLabel
@onready var rank_lbl   = $Panel/VBoxContainer/RankLabel
@onready var leader_board_btn = $Panel/VBoxContainer/LeaderBoardButton # Add Leader Board Button reference
@onready var main_menu_btn = $Panel/VBoxContainer/MainMenuButton     # Add Main Menu Button reference
@onready var line_edit: LineEdit = $Panel/HBoxContainer/LineEdit

var score = GameManager.score * 5
var player_name:String

func _ready():
	visible = false
	# Remove Restart Button connection
	# restart_btn.pressed.connect(_on_restart_pressed)
	leader_board_btn.pressed.connect(_on_leader_board_pressed) # Connect Leader Board button
	main_menu_btn.pressed.connect(_on_main_menu_pressed)       # Connect Main Menu button

func show_end(total_score: int) -> void:
	score_lbl.text = "Score: %d"   % total_score
	# rank_lbl is not set here anymore, consider removing if not needed elsewhere
	visible = true
	get_tree().paused = true # Pause when the end screen shows
	# Give focus to one of the buttons (optional, good for UI)
	leader_board_btn.grab_focus()


# Handle Leader Board button press
func _on_leader_board_pressed() -> void:
	get_tree().paused = false # Unpause
	queue_free() # Remove this screen
	# Store the current scene path before changing
	GameManager.previous_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://Scenes/ui/leaderboard_scene.tscn")

# Handle Main Menu button press
func _on_main_menu_pressed() -> void:
	get_tree().paused = false # Unpause
	queue_free() # Remove this screen
	# Reload the main game scene which should show the main menu
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	



func _on_line_edit_text_submitted(new_text: String) -> void:
	player_name = new_text
	GameManager.player_name = player_name
	print(player_name)
	



func _on_submit_button_pressed() -> void:
	player_name = line_edit.text # Get current text from LineEdit
	GameManager.player_name = player_name # Update GameManager too
	await Leaderboards.post_guest_score("circuit-skies-top_players-e6vE", score , player_name)
	line_edit.clear() # Clear the input field
	get_tree().reload_current_scene()
