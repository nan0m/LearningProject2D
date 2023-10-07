extends Panel

signal clicked(info)
@export var info: ManagerGame.ENCYCLO_PEDIA
# Called when the node enters the scene tree for the first time.
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
