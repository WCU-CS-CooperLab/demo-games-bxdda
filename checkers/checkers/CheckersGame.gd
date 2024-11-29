extends Node


@onready var hud = $HUD
@onready var winner_label = $HUD/Label


func update_winner(winner):
	winner_label.text = "%s won the match!" % winner
	hud.show()


func rematch():
	get_tree().reload_current_scene()


func _on_rematch_button_pressed():
	rematch()


func _on_checker_board_player_won(winner):
	update_winner(winner)
