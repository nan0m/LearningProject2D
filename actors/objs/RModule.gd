#This research module will be about upgrading the utility aspects of the ship. 
#Passive RU generation
#Drone Functionality!
#Increase RU from enemies
extends Node2D
class_name Module3

var RmoduleOnline = false
var time_pass = 0
var passive_ru_timer = 5 #every five seconds add gold/ru 
var passive_ru_ammount = 1

#drone vars
var drone_scene = preload("res://actors/entities/Drone.tscn")
var launch_timer = null
var max_drones = 1  # Number of drones to launch
var drone_cost = 30
var spawn_location
var damage = ManagerGame.weapons_data['dronebay']['attack']
var sort = null
var total_drones = 0  #number of present drones (docked or not)
var drones_ready = 0  #number of drones ready to launch
var toggle_drone_launch = false
var drone_replenish = 15

func _ready():
	RmoduleOnline = true
	#drone ready stuff
	randomize()
	launch_timer = $LaunchTimer
	launch_timer.wait_time = drone_replenish
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")
	#I need to connect here the signal from the button that controls the dock-undock function of the drone bay
	ManagerGame.connect("toggle_drones", Callable(self, "_on_toggle_drones"))
	

func _process(delta):
	passive_ru(delta)

###########################################################################
############################# Passive-RU ##################################
###########################################################################
func passive_ru(deltaticker):
	time_pass += deltaticker
	if time_pass >= passive_ru_timer:
		ManagerGame.global_player_ref.player_data['gold'] += passive_ru_ammount
		ManagerGame.gold_changed.emit()
		#emit_signal("gold_changed")
		time_pass -= passive_ru_timer
		print("1 RU added") #works

###### Extra RU from when an enemy dies
func extra_gold_on_enemy_death(base_gold_amount: int) -> int:
	var increase_factor = 1.1
	return int(base_gold_amount * increase_factor)

func on_enemy_destroyed(base_gold_amount: int):
	if RmoduleOnline:
		base_gold_amount = extra_gold_on_enemy_death(base_gold_amount)
	ManagerGame.global_player_ref.player_data['gold'] += base_gold_amount
	print("Extra RU" + str(base_gold_amount))
	#ManagerGame.connect("enemy_killed", Callable(self, "_on_enemy_killed"))

###########################################################################
############################## Fighters ###################################
###########################################################################

func _on_launch_timer_timeout():
	# Replenish drones when the timer ticks
	if drones_ready < max_drones and total_drones < max_drones:
		drones_ready += 1
		total_drones += 1
		if not toggle_drone_launch:  # Launch immediately if toggle is off
			launch_drone()
			drones_ready -= 1
		else:
			print("Drone ready and docked")

func _on_toggle_drones(toggled):
	toggle_drone_launch = toggled
	if not toggled:
		#Launch all ready drones when toggle is turned off
		while drones_ready > 0:
			launch_drone()
			drones_ready -= 1
			await get_tree().create_timer(0.3).timeout

func launch_drone():
	var player = ManagerGame.global_player_ref
	var drone_spawn_location1 = player.get_node("DroneSpawn1").global_position
	var drone_spawn_location2 = player.get_node("DroneSpawn2").global_position
	if randi() % 2 == 0:
		spawn_location = drone_spawn_location1
	else:
		spawn_location = drone_spawn_location2
	# Instantiate a new drone and set its position
	if total_drones <= max_drones:
		var new_drone = drone_scene.instantiate()
		new_drone.global_position = spawn_location
		print(new_drone.position)
		new_drone.adamage = damage
		sort.add_child(new_drone)
		ManagerGame.global_player_ref.player_data['gold'] -= drone_cost
	else:
		print("MAX DRONES REACHED")

############## Upgrades
func update_stats(stat_dictionary):
	damage = stat_dictionary["attack"]
	max_drones = stat_dictionary["drones"]
	print(stat_dictionary["replenish"])
	var drone_replenisher = max(int(drone_replenish) - int(stat_dictionary["replenish"]),0)
	$LaunchTimer.wait_time = drone_replenisher

