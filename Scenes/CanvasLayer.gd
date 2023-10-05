extends CanvasLayer

#@onready var new_game = $VBoxContainer/NewGame
#@onready var quit = $Quit


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Map.tscn") #change to the actual first map of the first chapter. 

func _on_survival_pressed(): 
	get_tree().change_scene_to_file("res://Scenes/Map.tscn") #currently this scene technically is the survival mode. 

#Load

#Data: THis is the encyclopedia of the game. It will showcase the lore of the game. Information on weapons, enemies, characters etc
#The game will this way incorporate steam achievements. The first time you kill that enemy you will unlock that datapoint in the
#encyclopedia. 
func _on_data_pressed():
	get_tree().change_scene_to_file("res://Scenes/Encyclopedia.tscn") # Replace with function body.

#Options

func _on_exit_pressed():
	get_tree().quit() #Quit the game



