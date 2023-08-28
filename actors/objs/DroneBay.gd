extends Node2D

var drone_scene = preload("res://actors/entities/Drone.tscn")
var launch_timer = null
var max_drones = 1  # Number of drones to launch
var drone_cost = 100
var spawn_location

func _ready():
	# Initialize the launch timer
	launch_timer = $LaunchTimer
	spawn_location = $SpawnMarker.position

func launch_drone():
	# Instantiate a new drone and set its position to the module's position
	var new_drone = drone_scene.instantiate()
	new_drone.position = spawn_location  # Set the drone's position to the module's position
	add_child(new_drone)  # Add the drone as a child of the module
	ManagerGame.global_player_ref.player_data['gold'] -= drone_cost

func _on_launch_timer_timeout():
	# Launch drones when the timer ticks
	for i in range(max_drones):
		launch_drone()
		print("drone launched")
