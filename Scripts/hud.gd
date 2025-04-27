extends Panel

@onready var coin_label: Label = $CoinLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var boost_bar: ProgressBar = $BoostBar

var previous_score = 0

func _ready():
	# Connect to signals
	GameManager.hp_changed.connect(update_hp_bar)
	GameManager.boost_changed.connect(update_boost_bar)

@warning_ignore("unused_parameter")
func _process(delta):
	coin_label.text = str(GameManager.score) + "X"

	if GameManager.score > previous_score:
		bump_coin_label()

	previous_score = GameManager.score

func bump_coin_label():
	var bump_tween = create_tween()
	bump_tween.tween_property(coin_label, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	bump_tween.tween_property(coin_label, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func update_hp_bar(hp_percent):
	hp_bar.value = hp_percent

func update_boost_bar(boost_percent):
	boost_bar.value = boost_percent
