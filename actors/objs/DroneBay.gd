extends Node2D

var drone_scene = preload("res://actors/entities/Drone.tscn")
var launch_timer = null
var max_drones = 1  # Number of drones to launch
var drone_cost = 100
var spawn_location
var damage = ManagerGame.weapons_data['dronebay']['attack']
var sort = null
var total_drones = 0  #number of present drones (docked or not)
var drones_ready = 0  #number of drones ready to launch
var toggle_drone_launch = false

func _ready():
	# Initialize the launch timer
	launch_timer = $LaunchTimer
	spawn_location = $SpawnMarker.global_position
	print(spawn_location)
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")
	#I need to connect here the signal from the button that controls the dock-undock function of the drone bay
	ManagerGame.connect("toggle_drones", Callable(self, "_on_toggle_drones"))

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

func update_stats(stat_dictionary):
	damage = stat_dictionary["attack"]
	max_drones = stat_dictionary["drones"]
	$LaunchTimer.wait_time = 1/stat_dictionary["rof"]
	#stat_dictionary["replenish"]
