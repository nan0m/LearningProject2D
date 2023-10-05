extends Node2D

var damage = ManagerGame.weapons_data['asm']['attack']
var range = ManagerGame.weapons_data['asm']['range']
var crit_rate =  ManagerGame.weapons_data['asm']['critical']
var crit_damage_modifier = 1.1
var random_generator
var sort = null
var asmmissileahoy := preload("res://actors/objs/ASMMissile.tscn")

func _ready():
	$Range/CollisionShape2D.shape.radius = range
	print($Range/CollisionShape2D.shape.radius)
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if sort != null:
		if e and e.is_in_group("Small_enenies") and global_position.distance_to(e.global_position) <= range:
			var distance = global_position.distance_to(e.global_position)
			if(random_generator.randf_range(0,1) < crit_rate):
				spawn_asmmissile(global_position, e, damage * crit_damage_modifier)
			else:
				spawn_asmmissile(global_position, e, damage)
			$missileSFX.play()

func spawn_asmmissile(g_pos: Vector2, target, damage):
	var b = asmmissileahoy.instantiate()
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
	range = stat_dictionary["range"]
	damage = stat_dictionary["attack"]
	$Timer.wait_time = 1/stat_dictionary["rof"]
	crit_rate = stat_dictionary["critical"]
