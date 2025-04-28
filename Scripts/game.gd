extends Node2D

var current_act = 1
var player_scene = preload("res://scenes/entities/player/player.tscn")
var player_instance = null

var end_screen_scene = preload("res://Scenes/ui/EndScreen.tscn")
var end_screen_instance = null

#var ui_scene = preload("res://scenes/ui/hud.tscn")
#var ui_instance = null

func _ready():
	# Register this scene's path with the GameManager for restarts
	print("[game.gd] _ready: Scene path is: '", self.scene_file_path, "'") # DEBUG
	if self.scene_file_path and not self.scene_file_path.is_empty():
		GameManager.register_level_path(self.scene_file_path)
	else:
		push_warning("[game.gd] Scene does not have a file path, cannot register for restart.") # DEBUG
		
	# Explicitly hide the main menu on ready (in case it persists after reload)
	var main_menu_node = find_child("MainMenu", false, false) # Adjust "MainMenu" if node name is different
	if main_menu_node:
		print("[game.gd] Hiding MainMenu node found.") # DEBUG
		main_menu_node.hide()
	else:
		print("[game.gd] MainMenu node not found to hide.") # DEBUG
		
	# Create persistent player
	player_instance = player_scene.instantiate()
	player_instance.add_to_group("player")
	add_child(player_instance)
	
	# Create UI
	#ui_instance = ui_scene.instantiate()
	#add_child(ui_instance)

	# Instance the end screen but keep it hidden initially
	end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	# end_screen_instance.hide() # It should hide itself in its own _ready()
	
	# Reset to Act 1 on ready (ensures fresh start after scene reload)
	current_act = 1
	
	# Load first act
	load_act(current_act)

func load_act(act_number):
	# Clear any existing act
	for child in get_children():
		if child.is_in_group("act"):
			child.queue_free()
	
	# Load new act
	var act_path = "res://scenes/levels/act" + str(act_number) + "/main.tscn"
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
	
func _on_exit_reached(total_score, player_rank):
	print("[game.gd] Exit reached! Score: ", total_score, " Rank: ", player_rank) # DEBUG
	if end_screen_instance:
		end_screen_instance.show_end(total_score, player_rank)
	else:
		push_error("[game.gd] End screen instance is null, cannot show end screen!")

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
