extends Node2D

var target = null
var shootingRange = ManagerGame.weapons_data["turret"]["range"]
var damage = ManagerGame.weapons_data["turret"]["attack"] 

#func _unhandled_input(event):
#	if event is InputEventScreenTouch and !event.pressed:
#		ManagerGame.global_world_ref.spawn_bullet(global_position)
func _physics_process(_delta):
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		look_at(e.global_position)


func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		ManagerGame.global_world_ref.spawn_bullet(global_position, global_position.direction_to(e.global_position), damage)
		$lazer.play()

func _on_timer_timeout():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		var distance = global_position.distance_to(e.global_position)
		if distance <= shootingRange:
			shoot()


#need to add a movement prediction
