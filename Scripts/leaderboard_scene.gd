extends Control

@onready var line_edit: LineEdit = $HBoxContainer/LineEdit


var score = GameManager.score * 5
var player_name:String


func _on_line_edit_text_submitted(new_text: String) -> void:
	player_name = new_text
	GameManager.player_name = player_name
	print(player_name)
	



#func _on_score_button_pressed() -> void:
	#GameManager.score += 5
	#score = GameManager.score
	#print(score)




func _on_submit_button_pressed() -> void:
	player_name = line_edit.text # Get current text from LineEdit
	GameManager.player_name = player_name # Update GameManager too
	await Leaderboards.post_guest_score("circuit-skies-top_players-e6vE", score , player_name)
	line_edit.clear() # Clear the input field
	get_tree().reload_current_scene()



func _on_leaderboard_button_pressed() -> void:
	$LeaderboardUI.show()




func _on_close_pressed() -> void:
	$LeaderboardUI.hide()



func _on_close_scene_button_pressed() -> void:
	var return_path = GameManager.previous_scene_path
	if not return_path.is_empty():
		get_tree().change_scene_to_file(return_path)
	else:
		# Fallback if no previous path is stored (e.g., go to main menu/game scene)
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
