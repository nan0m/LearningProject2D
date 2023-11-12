extends Control

@export var chapterfour : ChapterFour

func _ready():
	hide()
	chapterfour.connect("toggle_game_paused", _on_chapter_four_toggle_game_paused)

func _on_chapter_four_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()

func _on_resume_pressed():
	chapterfour.game_paused = false 

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
