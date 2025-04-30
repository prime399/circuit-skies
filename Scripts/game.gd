extends Node2D

var current_act = 1
var player_scene = preload("res://Scenes/entities/player/player.tscn")
var player_instance = null

var end_screen_scene = preload("res://Scenes/ui/EndScreen.tscn")
var tutorial_popup_scene = preload("res://Scenes/tutorial_popup.tscn") # Preload tutorial popup

var tutorial_showing = false
var tutorial_shown_this_session = false # Track if tutorial has been shown in this session

# Config file path for saving tutorial state
const SAVE_PATH = "user://game_state.cfg"

func _ready():
	# Load persistent data
	load_game_state()
	
	# Register this scene's path with the GameManager for restarts
	print("[game.gd] _ready: Scene path is: '", self.scene_file_path, "'") # DEBUG
	if self.scene_file_path and not self.scene_file_path.is_empty():
		GameManager.register_level_path(self.scene_file_path)
	else:
		push_warning("[game.gd] Scene does not have a file path, cannot register for restart.") # DEBUG
		

		
	# Create persistent player
	player_instance = player_scene.instantiate()
	player_instance.add_to_group("player")
	add_child(player_instance)
	current_act = 1
	
	# Load first act
	load_act(current_act)

# Save tutorial shown state
func save_game_state():
	var config = ConfigFile.new()
	config.set_value("tutorial", "shown", tutorial_shown_this_session)
	config.save(SAVE_PATH)
	print("[game.gd] Saved tutorial state: shown = ", tutorial_shown_this_session)

# Load tutorial shown state
func load_game_state():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		tutorial_shown_this_session = config.get_value("tutorial", "shown", false)
		print("[game.gd] Loaded tutorial state: shown = ", tutorial_shown_this_session)
	else:
		tutorial_shown_this_session = false
		print("[game.gd] No saved state found, tutorial will be shown")

func load_act(act_number):
	# Clear any existing act
	for child in get_children():
		if child.is_in_group("act"):
			child.queue_free()
	
	# Load new act
	var act_path = "res://Scenes/levels/act" + str(act_number) + "/main.tscn"
	var act = load(act_path).instantiate()
	add_child(act)
	
	# Reset player position to act's start position
	var spawn_point = act.get_node_or_null("PlayerSpawnPoint")
	if spawn_point:
		player_instance.position = spawn_point.position
	else:
		# Default position if no spawn point is defined
		player_instance.position = Vector2(100, 100)

	# Find the ExitPoint in the newly loaded act and connect its signal
	var exit_point = act.find_child("ExitPoint", true, false) # Recursive search
	if exit_point:
		# Check if already connected to prevent duplicate connections on reload?
		# For simplicity, assume it's not connected yet or disconnect first if needed.
		if not exit_point.exit_reached.is_connected(_on_exit_reached):
			exit_point.exit_reached.connect(_on_exit_reached)
			print("[game.gd] Connected exit_reached signal for act ", act_number) # DEBUG
		else:
			print("[game.gd] exit_reached signal already connected for act ", act_number) # DEBUG
	else:
		push_warning("[game.gd] ExitPoint node not found in act: " + act_path)
	
	# Update UI with act information
	#ui_instance.update_act_display(current_act)

	# Show tutorial popup only for Act 1 and if it hasn't been shown yet this session
	if act_number == 1 and not tutorial_showing and not tutorial_shown_this_session:
		tutorial_showing = true
		call_deferred("_show_tutorial")

func _show_tutorial():
	# Use call_deferred to ensure scene is fully loaded
	print("[game.gd] Showing tutorial popup")
	if ResourceLoader.exists("res://Scenes/tutorial_popup.tscn"):
		var tutorial_popup_instance = tutorial_popup_scene.instantiate()
		add_child(tutorial_popup_instance) # Add to the game scene itself
		
		# Create a callback to reset tutorial_showing when done and mark as shown for this session
		var done_callback = func(): 
			tutorial_showing = false
			tutorial_shown_this_session = true
			save_game_state() # Save that tutorial has been shown
		
		tutorial_popup_instance.start([
			"[center]Welcome to [b]Circuit Skies[/b]![/center]",
			"Use [b]← →[/b] to move.",
			"Press [b]Space[/b] to jump.",
			"Press [b]D[/b] to dash with [b]← →[/b] ",
			"Collect coins to increase your score.",
			"Avoid enemies as they will kill you.",
			"[color=orange]Good luck, Navigation Officer![/color]"
		], done_callback)
	else:
		push_error("[game.gd] Tutorial scene not found: res://Scenes/tutorial_popup.tscn")
		tutorial_showing = false
	
func _on_exit_reached(total_score, player_rank):
	print("[game.gd] Exit reached! Score: ", total_score, " Rank: ", player_rank) # DEBUG
	# Instantiate and add the end screen to the root tree when exit is reached
	var end_screen_instance = end_screen_scene.instantiate()
	if end_screen_instance:
		get_tree().root.add_child(end_screen_instance) # Add to root, like GameOverOverlay
		end_screen_instance.show_end(total_score)
	else:
		push_error("[game.gd] Failed to instantiate EndScreen scene!")
func advance_to_next_act():
	current_act += 1
	if current_act <= 3:  # Assuming 3 acts total
		# Save any relevant player stats/progress
		var player_health = player_instance.health
		var unlocked_abilities = player_instance.unlocked_abilities
		
		# Load next act
		load_act(current_act)
		
		# Restore player stats
		player_instance.health = player_health
		player_instance.unlocked_abilities = unlocked_abilities
	else:
		# Game complete - show victory screen
		#ui_instance.show_victory_screen()
		print("Game completed!")
