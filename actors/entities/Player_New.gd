extends CharacterBody2D #changed from extends Node2D

var player_data = {
	'stats': {
		'hp': 5000,
		'crew': 2000,
		'attack': 5,
		'critical': 4
	},
	'gold': 20000
}

################################################################################
######################### Movement on the Y axis ############################### And other crap
################################################################################
const max_speed = 50
const accel = 10
const friction = 600
var input = Vector2.ZERO
var audioPlayed = false

func _physics_process(delta):
	player_movement(delta)
	position.y = clamp(position.y,50,(get_viewport_rect().size.y - 50))
	#print($HP.value)
	if $HP.value < 0.25*$HP.max_value:
		if not audioPlayed:
			audioPlayed = true 
			alarm()

@onready var music = get_node("Alarm")
func alarm():
	music.stream = load("res://Assets/sfx/alarm.mp3")
	music.playing = true
	await music.finished
	audioPlayed = false

func get_input():
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input

func player_movement(delta):
	input = get_input()
	if input == Vector2.ZERO:
		if velocity.length()>(friction*accel):
			velocity -= velocity.normalized()*(friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	move_and_slide()
################################################################################
func _ready():
	ManagerGame.weapon_equipped.connect(on_weapon_equipped) #This function loads the player with the
	#weapons that have been selected
	ManagerGame.global_player_ref = self  
	$HP.max_value = player_data['stats']['hp'] #loads the max HP of the player (in case for healing)
	$HP.value = player_data['stats']['hp']     #loads the current value of stats of the player
	sort = get_parent().get_parent().get_node('Sort')

func on_weapon_equipped(slot_name, icon, weapon_type): #This function loads the respective weapon that has been selected.
	var n = $Slots.get_node('%s' % slot_name)
	n.appear(icon) #not sure though how it works here.
	var weapon = null
	if weapon_type == ManagerGame.WEAPON_TYPE.MISSILE:
		weapon = load('res://actors/objs/MissileLauncher.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.PHALANX:
		weapon = load('res://actors/objs/Phalanx.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.LAZER:
		weapon = load('res://actors/objs/LazerTurret.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.ASM:
		weapon = load('res://actors/objs/ASM.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.MODULE:
		weapon = load('res://actors/objs/Module.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.DEFMODULE:
		weapon = load('res://actors/objs/DModule.tscn').instantiate()
	elif weapon_type == ManagerGame.WEAPON_TYPE.DRONEBAY:
		weapon = load('res://actors/objs/DroneBay.tscn').instantiate()
	else:
		weapon = load('res://actors/objs/Weapon.tscn').instantiate()
	n.get_node('WeaponHolder').add_child(weapon)

func scrap_turret(slot_name):
	var n = $Slots.get_node('%s' % slot_name)
	n.get_node('WeaponHolder').get_child(0).queue_free()

#####################################################################################
############################## Player Turret + Abilities ############################
#####################################################################################
var railgun_ready = true
var torpedoL_ready = true
var damage_control_ready = true
var sort = null
var playerbullet := preload("res://actors/objs/Bullet.tscn")
func _unhandled_input(event): #this function allows the player to shoot with either the mouse-click ro touchscreen
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			spawn_bullet(global_position, global_position.direction_to(get_global_mouse_position()), 6)
			$PlayerTurret.play()
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and railgun_ready:
			railgun_burst_fire()
	if event.is_action_pressed("torpedo"):
		if torpedoL_ready:
			torpedoSalvoLaunch()
	if event.is_action_pressed("damage_control"):
		if damage_control_ready:
			damage_control()

#Player Shooter
func spawn_bullet(g_pos: Vector2, dir, damage):
	var b = playerbullet.instantiate()
	sort.add_child(b)
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	b.look_at(get_global_mouse_position())

#Railgun Shooter
func railgun_burst_fire():
	for child in get_node("Slots").get_children():
		if child.get_node("WeaponHolder").get_child_count() > 0:
			if child.get_node("WeaponHolder").get_child(0) is Module:
				child.get_node("WeaponHolder").get_child(0).rgshoot()
#Torpedo Launch
func torpedoSalvoLaunch():
	for child in get_node("Slots").get_children():
		if child.get_node("WeaponHolder").get_child_count() > 0:
			if child.get_node("WeaponHolder").get_child(0) is Module:
				child.get_node("WeaponHolder").get_child(0).tplaunch()
#Damage Control
func damage_control():
	for child in get_node("Slots").get_children():
		if child.get_node("WeaponHolder").get_child_count() > 0:
			if child.get_node("WeaponHolder").get_child(0) is Module2:
				child.get_node("WeaponHolder").get_child(0).damagecontrol()

##################################################################################
########################### Player getting damaged ###############################
##################################################################################
signal health_changed(new_health)
signal player_hit(damage)

func hit(damage: int = 1):
	player_data['stats']['hp'] -= damage
	$HP.value = player_data['stats']['hp']
	emit_signal("health_changed", player_data['stats']['hp'])
	#emit_signal("player_hit", damage)

func _on_player_hurtbox_area_entered(area):
	var damage = area.get_parent().damage
	hit(damage)
