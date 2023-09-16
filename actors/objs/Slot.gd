extends TextureButton
signal clicked
#signal turret_is_online

#var weapon_type: ManagerGame.WEAPON_TYPE
var data = {
	'level': 0
}
var corresponding_slot = null
func _ready():
	corresponding_slot = get_node("../../../../Sort/Player_New/Slots/" + name + "/WeaponHolder")
	#NOT IDEAL, but will work with current structure. I didn't know where you had the connection to it, so used this to grab
	pass#get_node(".").turret_is_online.connect(_on_turret_is_online())
	#.connect('turret_is_online',_on_turret_is_online())
	#connect("turret_is_online", self, "_on_turret_is_online")

func display(weapon_type):
	if data.has('weapon_data'):
		$Icon.show()
	else:
		$Icon.hide()
	
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
	
	ManagerGame.weapon_equipped.emit(name, $Icon.texture, weapon_type)

func appear(icon):
	$Icon.texture = icon
	$Icon.show()

func remove():
	$Icon.texture = null
	$Icon.hide()

func _on_gui_input(event):
	if event is InputEventScreenTouch and !event.pressed:
		$clicked.play()
		clicked.emit(self)

func upgrade(stats_dictionary):
	if(corresponding_slot.get_child(0)!=null):
		corresponding_slot.get_child(0).update_stats(stats_dictionary)

#func _on_turret_is_online():
	# Turn off toggle mode here
	# For example, if this button is used to toggle something on/off, you can do:
	#$".".toggle_mode = false

