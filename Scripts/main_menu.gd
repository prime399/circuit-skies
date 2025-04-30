extends CanvasLayer

@onready var start_button = $Panel/VBoxContainer/StartButton
@onready var current_level_node = get_node("../CurrentLevel") # Reference to the level node
@onready var hud_node = get_node("../CanvasLayer") # Reference to the HUD CanvasLayer
@onready var tap_sound_player = AudioStreamPlayer.new()
@onready var leader_board: Button = $Panel/VBoxContainer/LeaderBoard



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure nodes are valid before connecting/using
	if not start_button:
		push_error("StartButton node not found at path: Panel/VBoxContainer/StartButton")
		return # Stop if button missing

	if not current_level_node:
		push_error("CurrentLevel node not found at path: ../CurrentLevel")
		# Optionally return here if level is critical

	if not hud_node:
		push_error("HUD node (CanvasLayer) not found at path: ../CanvasLayer")
		# Optionally return here if HUD is critical

	start_button.pressed.connect(_on_start_button_pressed)
	leader_board.pressed.connect(_on_leader_board_pressed)

	# Optional: Ensure game starts paused and level/HUD are hidden
	# get_tree().paused = true
	# if current_level_node: current_level_node.hide()
	# if hud_node: hud_node.hide()

	# Add sound player and load sound
	add_child(tap_sound_player)
	tap_sound_player.stream = load("res://Assets/previous project assest/sounds/tap.wav")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass # Not needed for this functionality


# Function called when the StartButton is pressed
func _on_start_button_pressed():
	tap_sound_player.play() # Play tap sound
	print("Start button pressed. Showing game level.")
	# Hide the main menu itself
	hide()

	# Show the level and HUD
	if current_level_node:
		current_level_node.show()
	if hud_node:
		hud_node.show()

	# Unpause the game if it was paused
	get_tree().paused = false

# Function called when the LeaderBoard button is pressed
func _on_leader_board_pressed():
	tap_sound_player.play() # Play tap sound
	print("Leaderboard button pressed. Changing scene.")
	get_tree().change_scene_to_file("res://Scenes/ui/leaderboard_scene.tscn")
