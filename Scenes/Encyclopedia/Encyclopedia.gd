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

func _on_button_pressed():
	%FactionSelectionPanel.show()
	%Wikipage.hide()

var history_stack : Array = []
func _on_main_meta_clicked(meta):
	history_stack.append($Wikipage.info)
	print("CHANGING TO ")
	print(meta)
	if ManagerGame.ENCYCLO_PEDIA.find_key(meta) != null:
		$Wikipage.info = meta
		$Wikipage.update_content()
	#Should instead do things properly and send it to the part that fills it, as above, but this is quick fix, as I didn't bother with adding everything
	$Wikipage/ScrollContainer2/Main.text = ManagerGame.encyclopedia[meta]['description']
	#var wiki_info = ManagerGame.wiki_items.find_key(meta)
	$Wikipage/WikiDetails.text = ManagerGame.formatted_wiki_item(meta)
	var iconPath = "res://Assets/icons/" + meta + ".png"
	var newIconTexture = load(iconPath)
	$Wikipage/WikiIcon.texture = newIconTexture
	#var info_type_str = ManagerGame.ENCYCLO_PEDIA.find_key(info).to_lower()
	#var description = ManagerGame.encyclopedia[info_type_str]['description']
	#var formatted_descr = ManagerGame.formatted_descr(info_type_str)


func _on_button_2_pressed():
	# Check if there's anything in the history stack
	if history_stack.size() > 0:
		# Pop the last section from the history stack
		var previous_section = history_stack.pop_back()
		# Update the page content based on the previous section
		$Wikipage.info = previous_section
		$Wikipage.update_content()

