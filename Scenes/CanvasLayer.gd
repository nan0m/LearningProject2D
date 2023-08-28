extends CanvasLayer

@onready var new_game = $NewGame
#@onready var quit = $Quit


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Map.tscn")
