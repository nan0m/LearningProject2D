class_name ChapterThree

extends Node2D


@onready var parallax = $ParallaxBackground
@onready var sort = $Sort
@onready var spawn_point = $SpawnPoint
@onready var speed = 10.0


func _ready():
	ManagerGame.global_world_ref = self
	$UICanvas/UI.refresh_info()
	$AllySpawnTimer.start()
	

func _physics_process(delta):
	parallax.scroll_offset.x -= 70 * delta


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

####################################################################################################
###################################### Ally-Spawner ################################################
####################################################################################################
@onready var ally_spawn_timer = $AllySpawnTimer
var ally_instance = null # To keep track of the ally instance
func _on_ally_spawn_timer_timeout():
	# Check if there's already an ally present
	if ally_instance != null:
		return
	# Spawn the ally
	# Calculate the spawn position for the ally (at the left of the screen)
	var pos = Vector2.ZERO
	pos.x = -spawn_point.global_position.x +500 # Spawn from the left
	pos.y = randf_range(spawn_point.global_position.y - 200, spawn_point.global_position.y + 200)
	# Spawn the ally
	spawn_ally(pos)

func spawn_ally(position: Vector2):
	# Check if there's already an ally instance, if yes, return
	if ally_instance != null:
		return
	# Load the ally scene and instance it
	var ally_scene = preload("res://actors/entities/Ally.tscn")
	ally_instance = ally_scene.instantiate()
	# Set the ally's initial position
	ally_instance.global_position = position
	# Add the ally to the scene
	sort.add_child(ally_instance)
