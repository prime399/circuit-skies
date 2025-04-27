extends CanvasLayer

# Ensure this path matches the button in your scene structure
@onready var restart_button = $ColorRect/CenterContainer/VBoxContainer/RestartButton 

func _ready():
	# Ensure game isn't paused if it was before death animation
	get_tree().paused = false 
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
		restart_button.grab_focus() # Make button focusable immediately
	else:
		push_error("RestartButton not found in GameOverOverlay scene!")

func _on_restart_button_pressed():
	# Remove the overlay itself
	queue_free()
	# Tell GameManager to restart the game (which changes the scene)
	GameManager.restart_game()
