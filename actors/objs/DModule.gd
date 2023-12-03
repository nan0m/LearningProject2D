#defmodule': {     #Thise module requires different upgrade costs!!!!!
#		'hp': 200,     
#		'stage': 1,    
#		'restore': 1,  
#		'cooldown': 2, 
#		'price': 3000

#This module handles the defensive capabilities of the ship.
#The HP increases the base health per 50hp per level
#
#The 'restore' Unlocks the passive repair ability. 
#		Passively repair the ship per 0.02% per second (i.e.: 0.00002*5000 = 1hp per second). 
#		Each level increases passive repair per 0.000005*HP
#Stage has 5 levels. 
#	1. Unlocks the Damage-Control ability. 
#		This ability allows for quick repairs of the ship.
#		Heals for 15% of Max HP. Costs 100 resources.
#	2. Heals for 20% of Max HP. Costs 110 resources.
#	3. Heals for 25% of Max HP. Costs 125 resources.
#	4. Heals for 30% of Max HP. Costs 150 resources.
#	5. Unlocks the Shielding ability. 
#		This ability provides the ship with a 500hp damage tanking ability that lasts 10 seconds.
#		Cooldown is 30 seconds. 
#		Very Expensive Upgrade.
#  
#The Cooldown upgrade reduces all abilities cooldowns by -2s. (At max level -10s to defensive abilities' cooldowns). 

extends Node2D
class_name Module2

var max_hp := 100  # Set the initial MAX_HP value here
var current_hp := max_hp
var passive_repair_rate := 0.02  # Initial passive repair rate
var passive_repair_upgrade := 0.005  # Increase in repair rate per upgrade
var passive_repair_level := 1  # Initial repair level

var damage_control_levels = [0.15, 0.2, 0.25, 0.3, 0.35,0.37,0.40]  # HP recovery percentages for different levels
var passive_damage_control_levels = [0.0001, 0.0002, 0.0003, 0.0004, 0.0005, 0.00055,0.0006]  # HP recovery percentages for different levels
var damage_control_cooldown = 60  # Cooldown period for the damage control ability
var damage_control_ready = true  # Flag to track if the ability is ready
var damage_control_level = 1

var spawn_ally_cooldown = 150
var spawn_ally_ready = true
#var spawn_ally_level = 1

var shield_cooldown = 90
var shield_ready = true
var shield_length = [5,6,7,8,10]
#var shield_level = 5

var can_repair = false
var gui = null
var sort = null
var DmoduleOnline = false

func _ready():
	DmoduleOnline = true
	print(DmoduleOnline)

func update_stats(stat_dictionary):
	max_hp = stat_dictionary["hp"]
	damage_control_level = int(stat_dictionary["stage"])
	passive_repair_rate = int(stat_dictionary["restore"])
	gui = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GUI")
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")
	gui._on_update_module_d_ui(damage_control_level,damage_control_cooldown,spawn_ally_cooldown,shield_cooldown)
	#damage_control_cooldown = float(stat_dictionary["cooldown"])
	$DamagecontrolCD.wait_time = damage_control_cooldown
	$AllyCD.wait_time = spawn_ally_cooldown
	$ShieldCD.wait_time = shield_cooldown
	gui.set_max3(damage_control_cooldown)
	gui.set_max4(spawn_ally_cooldown)
	gui.set_max5(shield_cooldown)
	#print(damage_control_cooldown)

var time_pass = 0
func _process(delta):
	var currentHP = ManagerGame.global_player_ref.player_data['stats']['hp']
	if currentHP < 5000:
		can_repair = true
		passive_repair(delta)
	else:
		can_repair = false
		#print("No_Repairs_Needed")
	if gui != null:
		var dctime = snapped($DamagecontrolCD.time_left,1) 
		var allytime = snapped($AllyCD.time_left,1) 
		var sdtime = snapped($ShieldCD.time_left,1) 
		if damage_control_ready:
			dctime = damage_control_cooldown
		if spawn_ally_ready:
			allytime = spawn_ally_cooldown
		if shield_ready:
			sdtime = shield_cooldown
		gui._on_update_module_d_ui(damage_control_level,dctime, allytime,sdtime)

func passive_repair(delta):
	#print("Passive_Rep_Online")
	if can_repair == true && DmoduleOnline == true:
		ManagerGame.global_player_ref.player_data['stats']['hp'] += delta*passive_damage_control_levels[damage_control_level-1]*5000
		print("repaired")

################################################################################
################################ Repair ########################################
################################################################################
func damagecontrol():
	if can_repair == true && damage_control_ready:
		damage_control_ready = false
		activate_damage_control()
		$DamagecontrolCD.start()

func activate_damage_control():
	#print("Repairs_Engaged")
	var recovery_percent : float = damage_control_levels[damage_control_level-1]
	for i in range(1,5):
		ManagerGame.global_player_ref.player_data['stats']['hp'] += (recovery_percent*(5000-ManagerGame.global_player_ref.player_data['stats']['hp']))/4
		await get_tree().create_timer(0.4).timeout
		#print(str((recovery_percent*(5000-ManagerGame.global_player_ref.player_data['stats']['hp']))/4)+"REPAIRED")
	#print("Missing_HP" + str(5000-ManagerGame.global_player_ref.player_data['stats']['hp']))
	#print(recovery_percent)
	#print(str(recovery_percent*(5000-ManagerGame.global_player_ref.player_data['stats']['hp'])))
	damage_control_ready = false

func _on_damagecontrol_cd_timeout():
	damage_control_ready = true

################################################################################
################################ Shield ########################################
################################################################################
var shield_duration = 3
func shield_ability_activated():
	var player = ManagerGame.global_player_ref
	if shield_ready == true:
		var shield = player.get_node("Shield")
		shield.show()
		shield.get_node("ShieldCollision").disabled = false
		shield_ready = false
		$ShieldCD.start()
		await get_tree().create_timer(shield_duration).timeout
		shield.hide()
		shield.get_node("ShieldCollision").disabled = true

func _on_shield_cd_timeout():
	shield_ready = true

################################################################################
################################# Ally #########################################
################################################################################
#When the ally spawns we need to have a warp effect to the spawn location. 
var ally_instance = null # To keep track of the ally instance

func spawn_ally(position: Vector2):
	#Check if there's already an ally instance, if yes, return
	if ally_instance != null:
		return
	#Load the ally scene and instance it
	if spawn_ally_ready == true and ally_instance == null:
		var ally_scene = preload("res://actors/entities/Ally.tscn")
		ally_instance = ally_scene.instantiate()
		#Set the ally's initial position
		ally_instance.global_position = position
		#Add the ally to the scene
		sort.add_child(ally_instance)
		spawn_ally_ready = false
		$AllyCD.start()
	else:
		return

func _on_ally_cd_timeout():
	spawn_ally_ready = true

#func _on_ally_spawn_timer_timeout():
#	# Check if there's already an ally present
#	if ally_instance != null:
#		return
#	# Spawn the ally
#	# Calculate the spawn position for the ally (at the left of the screen)
#	var pos = $Marker2D.global_position
#	# Spawn the ally
#	spawn_ally(pos)
