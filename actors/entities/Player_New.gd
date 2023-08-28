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


####################################################################################################
############################## Player Turret + Abilities ###########################################
####################################################################################################
var railgun_ready = true
var torpedoL_ready = true
func _unhandled_input(event): #this function allows the player to shoot with either the mouse-click ro touchscreen
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			ManagerGame.global_world_ref.spawn_bullet(global_position, global_position.direction_to(get_global_mouse_position()), 6)
			$RailgunSFX3.play()
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and railgun_ready:
			railgun_burst_fire()
			railgun_ready = false
			$Timer.start()
			if $Timer.time_left == 0:
				_on_timer_timeout()
	if event.is_action_pressed("torpedo"):
		if torpedoL_ready:
			torpedoSalvoLaunch()
			torpedoL_ready = false
			$Timer2.start()
			if $Timer2.time_left == 0:
				_on_timer_2_timeout()
			
	#if event is InputEventScreenTouch and !event.pressed: #when pressed the bullet is spawned. 
	#	ManagerGame.global_world_ref.spawn_bullet(global_position, global_position.direction_to(get_global_mouse_position()))

#Railgun
var railgunCD = 90

func railgun_fire():
	$RailgunSFX2.play()
	var railgunSpawnPosition = global_position + Vector2(195, 0)
	var fixedDirection = Vector2.RIGHT
	ManagerGame.global_world_ref.spawn_railgun(railgunSpawnPosition, fixedDirection, 200) #200 is the damage

func railgun_burst_fire():
	
	for i in range(3):
		railgun_fire()
		await get_tree().create_timer(0.2).timeout #here is the cooldown of the shot interval
	await get_tree().create_timer(railgunCD).timeout  #here is the cooldown of the ability
	
	railgun_ready = true

func _on_timer_ready():
	$Timer.wait_time = railgunCD# Replace with function body.
	

func _on_timer_timeout():
	$Timer.stop() # Replace with function body.


#Torpedo Launcher
var torpedoCD = 90
func torpedolaunch():
	$TorpedoSFX.play()
	var torpedoSpawnPosition = global_position + Vector2(195, 0)
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		ManagerGame.global_world_ref.spawn_torpedo(torpedoSpawnPosition, e, 50) #50 is the damage of the torpedo

func torpedoSalvoLaunch():
	for i in range(6):
		torpedolaunch()
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(torpedoCD).timeout
	torpedoL_ready = true


func _on_timer_2_timeout():
	$Timer2.stop()# # Replace with function body.


func _on_timer_2_ready():
	$Timer2.wait_time = torpedoCD # Replace with function body. # Replace with function body.

##################################################################################
########################### Player getting damaged! ##############################
##################################################################################

func hit(damage: int = 1):
	player_data['stats']['hp'] -= damage
	$HP.value = player_data['stats']['hp']
	var explosion = load("res://actors/objs/Explosion.tscn").instantiate()
	ManagerGame.global_world_ref.spawn_obj(explosion, global_position)
	var impactThresholds = [0.9, 0.85,0.8,0.75,0.7,0.65,0.6,0.55,0.5,0.45,0.4,0.35,0.3,0.25,0.2,0.15,0.1,0.05] #thresholds of damages
	for threshold in impactThresholds:
		if $HP.value/$HP.max_value < threshold:
			impacted()
			break

func _on_player_hurtbox_area_entered(area):
	var damage = area.get_parent().damage
	hit(damage)


var explosion = preload("res://actors/extras/explosion.tscn")
@onready var explosion_area = get_node("Impact") 
func impacted():
	randomize()
	var x_pos = randi() % 409
	randomize()
	var y_pos = randi() % 63
	var explosion_location = Vector2(x_pos,y_pos)
	var new_explosion = explosion.instantiate()
	new_explosion.position = explosion_location
	explosion_area.add_child(new_explosion)




