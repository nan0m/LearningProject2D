extends Control

const MainMenuScene = preload("res://Scenes/MainMenu.tscn")
# Called when the node enters the scene tree for the first time.
@onready var faction_selection_box = get_node('%FactionSelectionPanel')
@onready var wiki_page = get_node('%Wikipage')
var faction_wiki = null

func _ready():
	for sp in faction_selection_box.get_children():
		print(sp)
		sp.clicked.connect(faction_select_clicked)
	faction_wiki = %Wikipage

func faction_select_clicked(info):
	print("I_AM_CLICKED_2")
	%FactionSelectionPanel.hide()
	faction_wiki.info = info
	faction_wiki.update_content()
	%Wikipage.show()

func _on_close_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

