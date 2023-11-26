extends Panel


signal clicked(weapon_type)
signal rclicked(weapons_dscr)

@export var weapon_type: ManagerGame.WEAPON_TYPE
@export var weapons_dscr: ManagerGame.WEAPON_TYPE
var price
var can_buy = true

func _ready():
	match weapon_type:
		ManagerGame.WEAPON_TYPE.TURRET: 
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile250.png")
		ManagerGame.WEAPON_TYPE.MODULE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile269.png")
		ManagerGame.WEAPON_TYPE.DEFMODULE:
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
		ManagerGame.WEAPON_TYPE.RMODULE:
			$Icon.texture = load("res://Assets/Towers/towerDefense_tile268.png")
	
	var key = ManagerGame.WEAPON_TYPE.find_key(weapon_type).to_lower()
	
	price = ManagerGame.weapons_data[key]['price']
	$Name.text = ManagerGame.WEAPON_TYPE.find_key(weapon_type)
	$Price.text = '%sG' % price

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT && can_buy:
			clicked.emit(weapon_type)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			rclicked.emit(weapon_type)
			$OpenWeaponDescription.play()
#add here the command/function to open the WeaponDescription
