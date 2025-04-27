extends Node

var score = 0

signal hp_changed(new_hp)

func add_point():
	score += 1
	print(score)

func update_hp(new_hp):
	emit_signal("hp_changed", new_hp)
