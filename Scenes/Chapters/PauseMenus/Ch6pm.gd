extends Control

@export var chaptersix : ChapterSix

func _ready():
	hide()
	chaptersix.connect("toggle_game_paused", _on_chapter_six_toggle_game_paused)

func _on_chapter_six_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()

func _on_resume_pressed():
	chaptersix.game_paused = false 

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
