class_name ChapterTwo

extends Node2D

@onready var parallax = $ParallaxBackground
@onready var sort = $Sort
@onready var spawn_point = $SpawnPoint
@onready var speed = 10.0
var dialogue_box_scene = preload("res://Scenes/DialogueBox.tscn")
var frigate_scene = preload("res://actors/entities/Frigate.tscn")
var destroyer_scene = preload("res://actors/entities/Destroyer.tscn")
var cruiser_scene = preload("res://actors/entities/Cruiser.tscn")
var battleship_scene = preload("res://actors/entities/Battleship.tscn")

var current_wave =  1

func _ready():
	ManagerGame.global_world_ref = self
	$UICanvas/UI.refresh_info()
	set_wave(current_wave)

func _physics_process(delta):
	parallax.scroll_offset.x -= 70 * delta

func set_wave(wave_number):
	await get_tree().create_timer(5.0).timeout
	if wave_number ==1:
		spawn_wave_enemies(5,frigate_scene)
		spawn_wave_enemies(2,battleship_scene)
		show_wave_text(wave_number)
	elif wave_number ==2:
		spawn_wave_enemies(5,frigate_scene)
		spawn_wave_enemies(1,cruiser_scene)
		show_wave_text(wave_number)
	elif wave_number ==3:
		spawn_wave_enemies(1,cruiser_scene)
		show_wave_text(wave_number)
	elif wave_number ==4:
		spawn_wave_enemies(1,cruiser_scene)
		show_wave_text(wave_number)
	elif wave_number ==5:
		spawn_wave_enemies(1,cruiser_scene)
		show_wave_text(wave_number)
	elif wave_number ==6:
		spawn_wave_enemies(1,cruiser_scene)
	elif wave_number ==7:
		spawn_wave_enemies(1,cruiser_scene)
	elif wave_number ==8:
		spawn_wave_enemies(1,cruiser_scene)
	await get_tree().create_timer(30.0).timeout  # Wait for 30 seconds before starting next wave
	set_wave(wave_number + 1)
	print(wave_number)

func spawn_wave_enemies(enemy_count, enemy_scene):
	for i in range(enemy_count):
		var pos = Vector2.ZERO
		pos.x = spawn_point.global_position.x
		pos.y = randf_range(spawn_point.global_position.y - 200, spawn_point.global_position.y + 200)
		spawn_enemy(pos, enemy_scene)
		await get_tree().create_timer(0.5).timeout

func spawn_enemy(g_pos: Vector2, enemy_scene: PackedScene):
	var e = enemy_scene.instantiate()
	e.global_position = g_pos
	sort.add_child(e)

func show_wave_text(wave_number):
	var dialogue_box = dialogue_box_scene.instantiate()
	add_child(dialogue_box)
	var texts = ManagerGame.chapter_texts[2]  # Assuming ChapterTwo corresponds to chapter number 2
	dialogue_box.get_node("DialogueBox/Text").text = texts[wave_number - 1]
	await get_tree().create_timer(3.0).timeout  # Wait for 3 seconds
	dialogue_box.queue_free()  # Remove the dialogue box

func spawn_obj(i, g_pos):
	sort.add_child(i)
	i.global_position = g_pos

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
