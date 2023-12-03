extends Panel

@export var weapon_type: ManagerGame.WEAPON_TYPE

func _ready():
	update_content()

func update_content():
	match weapon_type:
		ManagerGame.WEAPON_TYPE.TURRET: 
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile250.png")
		ManagerGame.WEAPON_TYPE.MODULE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile269.png")
		ManagerGame.WEAPON_TYPE.DEFMODULE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile268.png")
		ManagerGame.WEAPON_TYPE.RMODULE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile268.png")
		ManagerGame.WEAPON_TYPE.MISSILE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile226.png")
		ManagerGame.WEAPON_TYPE.PHALANX:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile291.png")
		ManagerGame.WEAPON_TYPE.LAZER:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile292.png")
		ManagerGame.WEAPON_TYPE.ASM:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile226.png")
		ManagerGame.WEAPON_TYPE.DRONEBAY:
			$Icon.texture = load("res://Assets/Towers/DroneBay.JPG")
	var weapon_type_str = ManagerGame.WEAPON_TYPE.find_key(weapon_type).to_lower()
	#var stats = ManagerGame.weapons_data[weapon_type_str]
	var description = ManagerGame.weapons_dscr[weapon_type_str]['description']
	var formatted_stats = ManagerGame.formatted_stats(weapon_type_str)
	$ScrollContainer/Description.text = description
	$Stats.text = formatted_stats  # Convert the stats dictionary to string for display (looks horrid)

func _on_button_pressed():
	get_parent().hide() # Replace with function body.
	get_parent().get_parent().get_parent().get_parent().show_build_menu()
	$CloseWeaponDescription.play()
