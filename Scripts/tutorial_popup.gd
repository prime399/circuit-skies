extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/tutorial_text
@onready var next_button = $Panel/ButtonNextButton

var tutorial_steps = []
var current_index = 0
var finished_callback: Variant = null # Use Variant type hint

func _ready():
	visible = false # Ensure popup starts hidden
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure UI processes input even when game is paused
	
	# Connect button even if the signal connection is missing in the scene file
	if not next_button.pressed.is_connected(_on_button_next_button_pressed):
		next_button.pressed.connect(_on_button_next_button_pressed)
	
	# Ensure the panel is properly sized and centered
	if panel:
		panel.custom_minimum_size = Vector2(400, 250)
		panel.anchors_preset = 8 # Center
		panel.anchor_left = 0.5
		panel.anchor_top = 0.5
		panel.anchor_right = 0.5
		panel.anchor_bottom = 0.5
		panel.offset_left = -200
		panel.offset_top = -125
		panel.offset_right = 200
		panel.offset_bottom = 125
		
	# Make sure the RichTextLabel has enough space for the content
	if label:
		label.fit_content = true
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.bbcode_enabled = true

func start(steps: Array, on_finish: Variant = null): # Use Variant type hint for parameter
	tutorial_steps = steps
	current_index = 0
	finished_callback = on_finish # Assign the Variant
	show_step()
	visible = true
	# Pause the game while tutorial is shown
	get_tree().paused = true

func show_step():
	if current_index >= tutorial_steps.size():
		visible = false
		# Unpause when finished
		get_tree().paused = false
		if finished_callback is Callable: # Check if it's not null AND a Callable
			finished_callback.call() # Call it
		return
	label.text = tutorial_steps[current_index]
	current_index += 1

# Support both potential signal connection names
func _on_button_next_button_pressed() -> void:
	show_step()
	
func _on_next_button_pressed() -> void:
	show_step()

# Add keyboard support to proceed through tutorial
func _unhandled_input(event):
	if visible and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select") or 
	   (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER))):
		show_step()
		get_viewport().set_input_as_handled()
