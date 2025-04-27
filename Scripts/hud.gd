extends Panel

@onready var coin_label: Label = $CoinLabel
var previous_score = 0  # New: Track last known score

func _process(delta):
	coin_label.text = str(GameManager.score) + "X"

	# Check if score increased
	if GameManager.score > previous_score:
		bump_coin_label()

	previous_score = GameManager.score  # Update stored score

func bump_coin_label():
	var bump_tween = create_tween()
	bump_tween.tween_property(coin_label, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	bump_tween.tween_property(coin_label, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
