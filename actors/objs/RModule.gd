#This research module will be about upgrading the utility aspects of the ship. 
#Passive RU generation
#Increase in number of Drones
#Increase RU from enemies

extends Node2D

func _ready():
	print("I am online")

var time_pass = 0
func _process(delta):
	time_pass += delta
	if time_pass >= 3:
		ManagerGame.global_player_ref.player_data['gold'] += 1
		emit_signal("gold_changed")
		time_pass -= 3
		print("1 RU added")
