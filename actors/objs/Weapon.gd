extends Node2D

var target = null
var shootingRange = ManagerGame.weapons_data["turret"]["range"]
var damage = ManagerGame.weapons_data["turret"]["attack"] 
var ReloadTime = 1
var crit_rate = ManagerGame.weapons_data["turret"]["critical"] 
var random_generator = null
var crit_damage_modifier = 1.2
var sort = null
var bulletahoy := preload("res://actors/objs/Bullet.tscn")
func _ready():
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")

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
		if(random_generator.randf_range(0, 1) < crit_rate):
			spawn_bullet(global_position, global_position.direction_to(e.global_position), damage * crit_damage_modifier)
		else:
			spawn_bullet(global_position, global_position.direction_to(e.global_position), damage)
		$lazer.play()

func _on_timer_timeout():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		var distance = global_position.distance_to(e.global_position)
		if distance <= shootingRange:
			shoot()
#need to add a movement prediction
func update_stats(stat_dictionary):
	ReloadTime = 1/stat_dictionary["rof"]
	$Timer.wait_time = ReloadTime
	crit_rate = stat_dictionary["critical"]
	damage = stat_dictionary["attack"]
	shootingRange = stat_dictionary["range"]

func spawn_bullet(g_pos: Vector2, dir, damage):
	var b = bulletahoy.instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	b.look_at(get_global_mouse_position())
	sort.add_child(b)
