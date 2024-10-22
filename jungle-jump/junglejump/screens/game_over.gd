extends Control

func _input(event):
	if event.is_action_pressed("ui_select"):
		GameState.restart()

func _ready() -> void:
	$GameoverMusic.play()
