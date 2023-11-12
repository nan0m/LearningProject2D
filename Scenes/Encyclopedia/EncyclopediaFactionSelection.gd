extends Panel

signal clicked(info)
@export var info: ManagerGame.ENCYCLO_PEDIA

func _ready():
	match info:
		ManagerGame.ENCYCLO_PEDIA.DORIA: 
			$FactionIcon.texture = load("res://Assets/icons/220px-Flag-corsairs.png")
		ManagerGame.ENCYCLO_PEDIA.IONIA: 
			$FactionIcon.texture = load("res://Assets/icons/220px-Flag-kusari.png")
		ManagerGame.ENCYCLO_PEDIA.IW: 
			$FactionIcon.texture = load("res://Assets/icons/220px-Flag-outcasts.png")
		ManagerGame.ENCYCLO_PEDIA.STROGG: 
			$FactionIcon.texture = load("res://Assets/icons/strogg.png")
		
	$FactionName.text = "[center]" + ManagerGame.ENCYCLO_PEDIA.find_key(info)

func _on_button_3_pressed():
	print("I_AM_CLICKED_1")
	clicked.emit(info)

func _on_clicked(info_id):
	return(info_id)
