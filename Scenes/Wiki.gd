extends Panel

@export var info: ManagerGame.ENCYCLO_PEDIA
# Called when the node enters the scene tree for the first time.
func _ready():
	update_content() # Replace with function body.

func update_content():
	match info:
		ManagerGame.ENCYCLO_PEDIA.DORIA: 
			$Icon.texture = load("res://Assets/icons/220px-Flag-corsairs.png")
		ManagerGame.ENCYCLO_PEDIA.IONIA: 
			$Icon.texture = load("res://Assets/icons/220px-Flag-kusari.png")
		ManagerGame.ENCYCLO_PEDIA.IW: 
			$Icon.texture = load("res://Assets/icons/220px-Flag-outcasts.png")
		ManagerGame.ENCYCLO_PEDIA.STROGG: 
			$Icon.texture = load("res://Assets/icons/strogg.png")
		
	var info_type_str = ManagerGame.ENCYCLO_PEDIA.find_key(info).to_lower()
	var description = ManagerGame.encyclopedia[info_type_str]['description']
	var formatted_descr = ManagerGame.formatted_descr(info_type_str)
	$ScrollContainer/Descriptions.text = description
	$Details.text = formatted_descr
	
