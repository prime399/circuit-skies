extends Node2D

var current_act = 1
var player_scene = preload("res://scenes/entities/player/player.tscn")
var player_instance = null
#var ui_scene = preload("res://scenes/ui/hud.tscn")
#var ui_instance = null

func _ready():
	# Create persistent player
	player_instance = player_scene.instantiate()
	player_instance.add_to_group("player")
	add_child(player_instance)
	
	# Create UI
	#ui_instance = ui_scene.instantiate()
	#add_child(ui_instance)
	
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
	
	# Update UI with act information
	#ui_instance.update_act_display(current_act)
	
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
