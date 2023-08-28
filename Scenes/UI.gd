extends Control

#this is for the build menu

@onready var stats_box = get_node('%StatsBox')
@onready var weapons_select_box = get_node('%WeaponsSelectionBox')
@onready var weapon_stats_box = get_node('%WeaponStatsBox')
@onready var weapon_descr_box = get_node('%WeaponDescriptionBox')

var current_selected = null
var selectedSlot = null

func _ready():
	ManagerGame.gold_changed.connect(on_gold_changed)
	
	for slot in $Slots.get_children():
		slot.clicked.connect(on_clicked)
		slot.clicked.connect(slot_button_clicked)
	for slot in weapons_select_box.get_children():
		slot.clicked.connect(on_weapon_select_clicked)
		slot.rclicked.connect(_on_weapon_description_right_click)

func slot_button_clicked(slot):
	if selectedSlot != null:
		selectedSlot.set_pressed(false)  # Turn off the previously selected slot
	selectedSlot = slot
	selectedSlot.set_pressed(true)  # Turn on the newly selected slot
	# Additional code to handle your specific logic for the clicked slot
	on_clicked(slot)  # Call your existing on_clicked function or the necessary logic


func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("space"):
		$Open_build_menu.play()
		for slot in $Slots.get_children():
			slot.self_modulate = Color(1, 1, 1, 1)
		get_tree().paused = true
		
		show()
		


func refresh_info():
	var stats = ManagerGame.global_player_ref.player_data['stats']
	
	var count = 0
	for stat in stats:
		stats_box.get_child(count).get_node('Label2').text = '%s' % stats[stat]
		
		count += 1


func refresh_weapon_info():
	var count = 0
	for stat in current_selected.data['weapon_data']:
		if stat == 'price':
			continue
		weapon_stats_box.get_child(count).get_node('Amount').text = '%s' % current_selected.data['weapon_data'][stat]
		weapon_stats_box.get_child(count).get_node('Label').text = '%s:' % stat
		count += 1


func on_clicked(own):
	var data = own.data
	current_selected = own
	weapon_stats_box.hide()
	$UpgradePanel/WeaponView/Build.hide()
	weapons_select_box.hide()
	if data.has('weapon_data'):
		weapon_stats_box.show()
		refresh_weapon_info()
	else:
		$UpgradePanel/WeaponView/Build.show()
	$UpgradePanel/WeaponView.show()
	


func on_weapon_select_clicked(weapon_type):
	var key = ManagerGame.WEAPON_TYPE.find_key(weapon_type).to_lower()
	$Item_online.play()
	# this creates a new key in our slot's data variable which was a dictionary
	# the key is called "weapon_data" which is going to also contain a dictionary
	# it contains our weapon's stats and price TRY USING print() TO SEE WHAT IT CONTAINS.
	current_selected.data['weapon_data'] = ManagerGame.weapons_data[key].duplicate()
	current_selected.data['upgrade_levels'] = {}
	# here i have created a loop which essentially creates a level for each of the
	# weapon's upgrades; it is just another dictionary
	# this is essential because we need to keep track of how many upgrades we have spent on a stat
	var upgrade_levels = {}
	for stat in current_selected.data['weapon_data']:
		current_selected.data['upgrade_levels'][stat] = 1
	#try this print statement to see the data's dictionary values to see for yourself
	#print(current_selected.data)
	ManagerGame.global_player_ref.player_data['gold'] -= ManagerGame.weapons_data[key]['price']
	ManagerGame.gold_changed.emit()
	current_selected.display(weapon_type)
	weapon_stats_box.show()
	weapons_select_box.hide()
	refresh_weapon_info()
	


func on_gold_changed():
	$UpgradePanel/Gold.text = '%sG' % ManagerGame.global_player_ref.player_data['gold']


func _on_hide_pressed():
	if selectedSlot != null:
		selectedSlot.set_pressed(false)  # Deselect the currently selected slot
		selectedSlot = null
	get_tree().paused = false
	$button_click.play()
	weapon_stats_box.hide()
	$UpgradePanel/WeaponView.hide()
	current_selected = null
	
	hide()

func _on_build_pressed():
	$UpgradePanel/WeaponView/Build.hide()
	$button_click.play()
	for child in weapons_select_box.get_children():
		if child.price > ManagerGame.global_player_ref.player_data['gold']:
			
			child.modulate = Color(1,1,1, .5)
			child.can_buy = false
		else:
			child.can_buy = true
			
			child.modulate = Color.WHITE
			get_node("Slots/Slot").grab_focus()
	
	weapons_select_box.show()
	get_node("Slots/Slot").release_focus()


# connected to all 4 "Upgrade" buttons in weapon view
# stat_name param can be "hp, armor, attack, critical" all String types
func _on_button_pressed(stat_name):
	current_selected.data['weapon_data'][stat_name] += 1
	#ManagerGame.global_player_ref.player_data['stats'][stat_name] += 1
	
	refresh_weapon_info()
	refresh_info()


func _on_visibility_changed():
	if visible:
		on_gold_changed()


func _on_scrap_pressed():
	#$button_click.play()
	$scrap.play()
	# If there was a previously installed turret (current_selected),
	# refund the gold and remove the turret.
	if current_selected:
		var turret_data = current_selected.data['weapon_data']
		var turret_refund = turret_data['price'] * 0.7 #Needs to take into account the upgrade costs!!!
		ManagerGame.global_player_ref.player_data['gold'] += turret_refund
		ManagerGame.gold_changed.emit()
		# Remove the turret
		current_selected.data = {}
		# Hide weapon stats box and show upgrade/build options again
		weapon_stats_box.hide()
		$UpgradePanel/WeaponView/Build.show()
		# Refresh info after removing turret
		refresh_info()
		# this function just removes the icon
		current_selected.remove()
		ManagerGame.global_player_ref.scrap_turret(current_selected.name)

func _on_weapon_description_right_click(weapon_type):
	var weapon_description = preload("res://actors/ui/WeaponDescription.tscn").instantiate()  # Load the WeaponDescription scene
	weapon_description.weapon_type = weapon_type
	add_child(weapon_description)
