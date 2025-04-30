extends Node

var score = 0
var player_name: String = ""

# Path to the game over overlay scene
const GAME_OVER_OVERLAY_PATH = "res://Scenes/ui/GameOverOverlay.tscn"
var game_over_overlay_scene = null # To store the loaded scene
var current_level_path: String = "" # Store the path of the currently loaded level
var is_reloading: bool = false # Flag to indicate if a scene reload is in progress
var previous_scene_path: String = "" # Store path to return to from leaderboard

signal hp_changed(new_hp)
signal boost_changed(new_boost)

func add_score(value: int):
	score += value
	print("Score: ", score) # Updated print

func update_hp(new_hp):
	emit_signal("hp_changed", new_hp)

func update_boost(new_boost):
	emit_signal("boost_changed", new_boost)

func register_level_path(path: String):
	print("[GameManager] Received level path to register: '", path, "'") # DEBUG
	current_level_path = path
	print("[GameManager] Stored level path: '", current_level_path, "'") # DEBUG

func handle_game_over():
	# Load the overlay scene if it hasn't been loaded yet
	if game_over_overlay_scene == null:
		game_over_overlay_scene = load(GAME_OVER_OVERLAY_PATH)
		if game_over_overlay_scene == null:
			push_error("Failed to load Game Over Overlay scene at: " + GAME_OVER_OVERLAY_PATH)
			return

	# Instance the overlay
	var overlay_instance = game_over_overlay_scene.instantiate()

	# Add the overlay to the current scene tree
	# Using get_tree().root assumes the overlay should appear above everything
	get_tree().root.add_child(overlay_instance)
	print("Game Over Overlay added.")

func restart_game():
	print("[GameManager] restart_game called.") # DEBUG
	# Reset score
	score = 0
	print("[GameManager] Score reset to: ", score) # DEBUG
	# TODO: Reset any other global state if necessary

	# Reload the stored level scene path
	print("[GameManager] Attempting to load stored path: '", current_level_path, "'") # DEBUG
	if not current_level_path.is_empty():
		var error = get_tree().change_scene_to_file(current_level_path)
		print("[GameManager] change_scene_to_file result: ", error, " (OK is ", OK, ")") # DEBUG
		if error != OK:
			push_error("[GameManager] Failed to change scene to %s: %s" % [current_level_path, str(error)])
	else:
		push_error("[GameManager] No current level path stored to restart the game!") # DEBUG
		# Fallback? Maybe go to main menu?
		# get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn") # Example fallback
