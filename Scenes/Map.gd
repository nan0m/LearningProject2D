class_name Map

extends Node2D


@onready var parallax = $ParallaxBackground
@onready var sort = $Sort
@onready var spawn_point = $SpawnPoint
@onready var speed = 10.0


func _ready():
	ManagerGame.global_world_ref = self
	$UICanvas/UI.refresh_info()
	$GUI/HUD/AbilitiesBar/RailgunCD.max_value = $Sort/Player_New/Timer.wait_time
	$GUI/HUD/AbilitiesBar/TorpedoCD.max_value = $Sort/Player_New/Timer2.wait_time
	$AllySpawnTimer.start()
	
	
	#$GUI/HUD/AbilitiesBar/RailgunCD.max_value = get_node()
	

func _physics_process(delta):
	parallax.scroll_offset.x -= 70 * delta
	var timer = $Sort/Player_New/Timer
	$GUI/HUD/AbilitiesBar/RailgunCD.value = timer.wait_time - timer.time_left#here i need to put the current timer
	if $GUI/HUD/AbilitiesBar/RailgunCD.value == timer.wait_time:
		$GUI/HUD/AbilitiesBar/RailgunCD/RailgunCDlabel.text = str(timer.wait_time)
	else:
		$GUI/HUD/AbilitiesBar/RailgunCD/RailgunCDlabel.text = str(round(timer.time_left)) #the text of current timer
	var timer2 = $Sort/Player_New/Timer2
	$GUI/HUD/AbilitiesBar/TorpedoCD.value = timer2.wait_time - timer2.time_left#here i need to put the current timer
	if $GUI/HUD/AbilitiesBar/TorpedoCD.value == timer2.wait_time:
		$GUI/HUD/AbilitiesBar/TorpedoCD/TorpedoCDlabel.text = str(timer2.wait_time)
	else:
		$GUI/HUD/AbilitiesBar/TorpedoCD/TorpedoCDlabel.text = str(round(timer2.time_left)) #the text of current timer


func spawn_railgun(g_pos: Vector2, dir, damage):
	var b = load("res://actors/objs/Railgun.tscn").instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	sort.add_child(b)


func spawn_bullet(g_pos: Vector2, dir, damage):
	var b = load("res://actors/objs/Bullet.tscn").instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	b.look_at(get_global_mouse_position())
	sort.add_child(b)

func spawn_phalanxbullet(g_pos: Vector2, dir, damage):
	var b = load("res://actors/objs/PhalanxBullet.tscn").instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	sort.add_child(b)

func spawn_missile(g_pos: Vector2, target, damage):
	var b = load("res://actors/objs/Missile.tscn").instantiate()
	b.global_position = g_pos
	b.target = target
	b.damage = damage
	sort.add_child(b)

func spawn_asmmissile(g_pos: Vector2, target, damage):
	var b = load("res://actors/objs/ASMMissile.tscn").instantiate()
	b.global_position = g_pos
	b.target = target
	b.damage = damage
	sort.add_child(b)

func spawn_torpedo(g_pos: Vector2, target, damage):
	var b = load("res://actors/objs/Torpedo.tscn").instantiate()
	b.global_position = g_pos
	b.target = target
	sort.add_child(b)
	b.damage = damage

#func spawn_drone(g_pos = $SpawnMarker.position):
#	var b = load("res://actors/entities/Drone.tscn").instantiate()
#	b.global_position = g_pos
#	sort.add_child(b)


func spawn_enemy(g_pos: Vector2):
	var rand_value = randf()   # Generates a random float between 0 and 1
	var enemy_scene_path: String
	if rand_value < 0.25:
		enemy_scene_path = "res://actors/entities/Destroyer.tscn"
	elif 0.25 <= rand_value and rand_value <0.5:
		enemy_scene_path = "res://actors/entities/Frigate.tscn"
	elif 0.5 <= rand_value and rand_value < 0.75:
		enemy_scene_path = "res://actors/entities/Cruiser.tscn"
	else:
		enemy_scene_path = "res://actors/entities/Battleship.tscn"
	var e = load(enemy_scene_path).instantiate()
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
	
	var e = enemies[0]
	
	var distance = g_pos.distance_to(e.global_position)
	for enemy in enemies:
		var dist = g_pos.distance_to(enemy.global_position)
		e = enemy
		distance = dist
	
	# checks if the latest enemy being referenced matches the filter we are looking for
	# if the enemy type is a fighther, and we are looking for a capital, it is now invalid and thus turn the e = null
	
	
	return e


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
	add_child(ally_instance)
	
