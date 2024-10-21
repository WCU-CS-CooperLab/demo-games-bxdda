extends Node

var num_levels = 4
var current_level = 0

var game_scene = "res://main.tscn"
var title_screen = "res://screens/title_screen.tscn"
var game_over = "res://screens/game_over.tscn"

func restart():
	current_level = 0
	get_tree().change_scene_to_file(title_screen)
	

func gameover():
	get_tree().change_scene_to_file(game_over)
	

func next_level():
	current_level += 1
	if current_level < num_levels:
		print(current_level)
		get_tree().change_scene_to_file(game_scene)
	
