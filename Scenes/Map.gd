class_name Map
extends Node2D
@onready var parallax = $ParallaxBackground
@onready var sort = $Sort
@onready var spawn_point = $SpawnPoint
@onready var speed = 10.0

func _ready():
	ManagerGame.global_world_ref = self
	$UICanvas/UI.refresh_info()
	#$AllySpawnTimer.start()

func _physics_process(delta):
	parallax.scroll_offset.x -= 70 * delta

#func spawn_railgun(g_pos: Vector2, dir, damage):
#	var b = load("res://actors/objs/Railgun.tscn").instantiate()
#	b.global_position = g_pos
#	b.dir = dir
#	b.damage = damage
#	sort.add_child(b)

#func spawn_bullet(g_pos: Vector2, dir, damage):
#	var b = load("res://actors/objs/Bullet.tscn").instantiate()
#	b.global_position = g_pos
#	b.dir = dir
#	b.damage = damage
#	b.look_at(get_global_mouse_position())
#	sort.add_child(b)

#func spawn_phalanxbullet(g_pos: Vector2, dir, damage):
#	var b = load("res://actors/objs/PhalanxBullet.tscn").instantiate()
#	b.global_position = g_pos
#	b.dir = dir
#	b.damage = damage
#	sort.add_child(b)

#func spawn_missile(g_pos: Vector2, target, damage):
#	var b = load("res://actors/objs/Missile.tscn").instantiate()
#	b.global_position = g_pos
#	b.target = target
#	b.damage = damage
#	sort.add_child(b)

#func spawn_asmmissile(g_pos: Vector2, target, damage):
#	var b = load("res://actors/objs/ASMMissile.tscn").instantiate()
#	b.global_position = g_pos
#	b.target = target
#	b.damage = damage
#	sort.add_child(b)

#func spawn_torpedo(g_pos: Vector2, target, damage):
#	var b = load("res://actors/objs/Torpedo.tscn").instantiate()
#	b.global_position = g_pos
#	b.target = target
#	sort.add_child(b)
#	b.damage = damage

#func spawn_drone(g_pos = $SpawnMarker.position):
#	var b = load("res://actors/entities/Drone.tscn").instantiate()
#	b.global_position = g_pos
#	sort.add_child(b)
var frigate_scene = preload("res://actors/entities/Frigate.tscn")
var destroyer_scene = preload("res://actors/entities/Destroyer.tscn")
var cruiser_scene = preload("res://actors/entities/Cruiser.tscn")
var battleship_scene = preload("res://actors/entities/Battleship.tscn")
func spawn_enemy(g_pos: Vector2):
	var rand_value = randf()   # Generates a random float between 0 and 1
	var enemy_scene: PackedScene
	if rand_value < 0.25:
		enemy_scene = battleship_scene
	elif 0.25 <= rand_value and rand_value <0.5:
		enemy_scene = battleship_scene
	elif 0.5 <= rand_value and rand_value < 0.75:
		enemy_scene = battleship_scene
	else:
		enemy_scene = battleship_scene
	var e = enemy_scene.instantiate()
	e.global_position = g_pos
	sort.add_child(e)
#func spawn_enemy(g_pos: Vector2):
#	var rand_value = randf()   # Generates a random float between 0 and 1
#	var enemy_scene_path: String
#	if rand_value < 0.25:
#		enemy_scene_path = "res://actors/entities/Destroyer.tscn"
#	elif 0.25 <= rand_value and rand_value <0.5:
#		enemy_scene_path = "res://actors/entities/Frigate.tscn"
#	elif 0.5 <= rand_value and rand_value < 0.75:
#		enemy_scene_path = "res://actors/entities/Cruiser.tscn"
#	else:
#		enemy_scene_path = "res://actors/entities/Battleship.tscn"
#	var e = load(enemy_scene_path).instantiate()
#	e.global_position = g_pos
#	sort.add_child(e)

func spawn_obj(i, g_pos):
	# i have used this to spawn the blast animation and the damage floater
	# but you can also use this to spawn any other objects such as enemies, another bullets
	# but you have to pass an already intantiated node (the "i" parameter in here should be a PackedScene)
	# you may see Enemy.tscn for examples on the _on_hurtbox_area_entered function
	sort.add_child(i)
	i.global_position = g_pos

# the new filter parameter is used specifically only return  certain enemy types
# see ManagerGame.ENEMY_TYPE enum
# by default "-1" it just gets the closest enemy regardless of type which means it searches for the closest fighter or capital enemy
# when you pass "1" or ManagerGame.ENEMY_TYPE.CAPITAL it just searches for the nearest capital enemy
func get_closest(g_pos):
	var enemies = get_tree().get_nodes_in_group('Enemy')
	if enemies.is_empty():
		return null
	var closest_enemy = enemies[0]
	var closest_distance = g_pos.distance_to(closest_enemy.global_position)
	for enemy in enemies:
		var dist = g_pos.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_enemy = enemy
			closest_distance = dist
	return closest_enemy
#func get_closest(g_pos):
#	var enemies = get_tree().get_nodes_in_group('Enemy')
#	if enemies.is_empty():
#		return null
#	var e = enemies[0]
#	var distance = g_pos.distance_to(e.global_position)
#	for enemy in enemies:
#		var dist = g_pos.distance_to(enemy.global_position)
#		e = enemy
#		distance = dist

	# checks if the latest enemy being referenced matches the filter we are looking for
	# if the enemy type is a fighther, and we are looking for a capital, it is now invalid and thus turn the e = null
	#return e

func _on_enemy_timer_timeout():
	var pos = Vector2.ZERO
	pos.x = spawn_point.global_position.x
	pos.y = randf_range(spawn_point.global_position.y - 200, spawn_point.global_position.y + 200)
	spawn_enemy(pos)

####################################################################################################
###################################### In-Game-Menu ################################################
####################################################################################################
signal  toggle_game_paused(is_paused : bool)

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused",game_paused)

func _input(event: InputEvent):
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
#######################################################################
#func _on_update_module_d_ui(level, extra_arg_0):
#	pass # Replace with function body.


func _on_check_button_toggled(button_pressed):
	ManagerGame.emit_signal("toggle_drones", button_pressed)
