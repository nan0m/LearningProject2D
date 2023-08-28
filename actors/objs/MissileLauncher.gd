extends Node2D

var damage = ManagerGame.weapons_data['missile']['attack']
var range = ManagerGame.weapons_data['missile']['range']

func _ready():
	$Range/CollisionShape2D.shape.radius = range
	print($Range/CollisionShape2D.shape.radius)

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	
	if e and global_position.distance_to(e.global_position) <= range:
		var distance = global_position.distance_to(e.global_position)
		ManagerGame.global_world_ref.spawn_missile(global_position, e, damage)
		$missileSFX.play()

func _on_timer_timeout():
	shoot()

func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')
