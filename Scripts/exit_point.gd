extends Area2D
signal exit_reached(score, rank)

func _ready():
	# Connect the body_entered signal to the _on_body_entered function (Godot 4 syntax)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the owner of the entering body is in the "player" group
	# Check if the entering body itself is in the "player" group
	if body.is_in_group("player"):
		print("[ExitPoint] Player body owner entered!") # DEBUG
		# get the current score and rank (you’ll plug in real logic later)
		var total_score = GameManager.score  
		var player_rank  = "-"              # placeholder
		emit_signal("exit_reached", total_score, player_rank)
		# optionally disable it so it only fires once:
		set_monitorable(false)
