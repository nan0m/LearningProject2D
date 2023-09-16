extends Node2D

var damage = ManagerGame.weapons_data['missile']['attack']
var shootingRange = ManagerGame.weapons_data['missile']['range']
var ReloadTime = 1
var crit_rate = ManagerGame.weapons_data['missile']['critical']
var random_generator = null
var crit_damage_modifier = 1.5
var sort = null

func _ready():
	$Range/CollisionShape2D.shape.radius = shootingRange
	print($Range/CollisionShape2D.shape.radius)
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if sort != null:
		if e and global_position.distance_to(e.global_position) <= shootingRange:
			var distance = global_position.distance_to(e.global_position)
			if(random_generator.randf_range(0,1)<crit_rate):
				spawn_missile(global_position, e, damage * crit_damage_modifier)
			else:
				spawn_missile(global_position, e, damage)
			$missileSFX.play()

func spawn_missile(g_pos: Vector2, target, damage):
	var b = load("res://actors/objs/Missile.tscn").instantiate()
	b.global_position = g_pos
	b.target = target
	b.damage = damage
	sort.add_child(b)

func _on_timer_timeout():
	shoot()

func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')
	
func update_stats(stat_dictionary):
	print("LAUNCHER")
	ReloadTime = 1/stat_dictionary["rof"]
	$Timer.wait_time = ReloadTime
	crit_rate = stat_dictionary["critical"]
	damage = stat_dictionary["attack"]
	shootingRange = stat_dictionary["range"]
	
