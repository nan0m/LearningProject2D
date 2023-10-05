extends Control

const MainMenuScene = preload("res://Scenes/MainMenu.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#$Panel/DoriaWiki/HBoxContainer/ScrollContainer/Label.text = ManagerGame.encyclopedia["doria"]['description']
	#$Panel/IoniaWiki/HBoxContainer/ScrollContainer/Label.text = ManagerGame.encyclopedia["ionia"]['description']
	#$Panel/IWWiki/HBoxContainer/ScrollContainer/Label.text = ManagerGame.encyclopedia["iw"]['description']
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_close_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_button_pressed():
	$Panel/HBoxContainer.hide()
	%Wiki.show()

func _on_button_2_pressed():
	$Panel/HBoxContainer.hide()
	%Wiki.show()

func _on_button_3_pressed():
	$Panel/HBoxContainer.hide()
	%Wiki.show()

func _on_button_4_pressed():
	$Panel/HBoxContainer.hide()
	%Wiki.show()

func _on_return_pressed():
	%Wiki.hide()
	$Panel/HBoxContainer.show()

