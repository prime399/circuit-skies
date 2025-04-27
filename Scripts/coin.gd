extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var score_value = 1 # Default score
		if "Big" in self.name: # Check if "Big" is in the node's name
			score_value = 5
			print("Big coin collected!") # Optional debug print
		
		GameManager.add_score(score_value) # Use the new function with the determined value
		animation_player.play("pickup")
		# Disable collision so it can't be picked up again while animating
		$CollisionShape2D.set_deferred("disabled", true)

# Optional: Queue free after pickup animation finishes
# Connect the animation_finished signal from AnimationPlayer in the editor
# or via code in _ready() to this function:
# func _on_animation_player_animation_finished(anim_name):
# 	if anim_name == "pickup":
# 		queue_free()
