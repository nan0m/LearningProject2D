extends Control

@export var map : Map

func _ready():
	hide()
	map.connect("toggle_game_paused", _on_map_toggle_game_paused)

func _on_map_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()
 


func _on_resume_pressed():
	map.game_paused = false 


func _on_exit_pressed():
	get_tree().quit()
