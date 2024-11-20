extends CanvasLayer

signal start_game

@onready var lives_counter = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label = $MarginContainer/HBoxContainer/Score
@onready var message = $Message
@onready var start_button = $StartButton
@onready var settings_button = $SettingsButton
@onready var exit_button = $ExitButton


@onready var shield_bar = $MarginContainer/HBoxContainer/ShieldBar
@onready var health_bar = $MarginContainer/HBoxContainer/HealthBar

var bar_textures = {
"green": preload("res://assets/bar_green_200.png"),
"yellow": preload("res://assets/bar_yellow_200.png"),
"red": preload("res://assets/bar_red_200.png")
}

func update_shield(value):
	shield_bar.texture_progress = bar_textures["green"]
	if value < 0.4:
		shield_bar.texture_progress = bar_textures["red"]
	elif value < 0.7:
		shield_bar.texture_progress = bar_textures["yellow"]
	shield_bar.value = value

func show_message(text):
	message.text = text
	message.show()
	$Timer.start()

func update_score(value):
	score_label.text = str(value)

func update_lives(value):
	for item in 3:
		lives_counter[item].visible = value > item

func game_over():
	$AnimationPlayer.play("RESET")
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()
	settings_button.show()
	exit_button.show()

func _on_start_button_pressed():
	start_button.hide()
	settings_button.hide()
	exit_button.hide()
	start_game.emit()

func _on_timer_timeout():
	$AnimationPlayer.play("title")
	if $AnimationPlayer.animation_finished:
		message.hide()
		message.text = ""


func update_health(value):
	health_bar.value = value


func _on_menu_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
