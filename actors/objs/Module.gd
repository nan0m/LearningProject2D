#This module basically represents the offensive abilities of the ship. 
#module': {        
#		'scanner': 1,     
#		'stage': 1,    
#		'CT': 5, <-Control Tower former attack   
#		'cooldown': 2, 
#		'price': 4000
#Thise module requires different upgrade costs!!!!!

#The 'stage' has 5 levels total. Expensive upgrade!
#	1. Unlocks the torpedo launch ability
		#this ability launches 6 torpedoes to the enemy. 
#	2. Unlocks the railgun ability.
#		This level unlocks only 1 shot of the railgun
#		Has 5% chance to cause damage of 25% of current HP? 
#	3. Unlocks the 2nd shot of the railgun
#		Has 15% chance to cause damage of 25% of current HP? 
#	4. Unlocks the 3rd and final shot of the railgun (total 3 shots)
#		Has 30% chance to cause damage of 25% of current HP?  
#	5. Level 5 gives a 25% damage increase to all abilities (each torpedo, and railgun shot + 25% each). 
#
#The 'attack' <- renamed maybe to 'control tower', grants damage increase to all turrets additionally to the 
#	individual turrets upgrades. This one increases the Base stat which then the turret upgrades take into account in
#	their calculations.
#	Each level increases base damage by +5. There 10 levels max. (total base damage at last level + 50). 
#	To make this more balanced the price should be VERY high. 
#The cooldown grants -10s per level to torpedo and railgun abilities. Max 5 levels. (-50s at max level). 
#	Slightly an expensive upgrade. 
#The scanner upgrade passively increases the range of all turrets base range +50.
#	Max levels 10. Total max range +500.
extends Node2D
class_name Module

var gui = null
var sort = null
var hp
var stage = 0
var attack
var cooldown

var railgun_ready = true
var cooldownRG = 90
var damageRG = 200
var shotpstage = [0,0,0,1,2,3,3,3]

var torpedo_ready = true
var cooldownTP = 90
var damageTP = 50
var torpshotstage = [0,0,3,3,4,5,5,6]
var railgunbullet := preload("res://actors/objs/Railgun.tscn")
var torpedoahoy := preload("res://actors/objs/Torpedo.tscn")
var rgparticles := preload("res://Assets/fx/Explosion Scenes/RailgunExplosion.tscn")

func update_stats(stat_dictionary):
	stage = int(stat_dictionary["stage"])
	#emit_signal("update_module_UI",stage)
	gui = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GUI")
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")
	#get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GUI").emit_signal("update_module_UI", stage)
	gui._on_update_module_ui(stage,cooldownRG,cooldownTP)
	#cooldownRG = float(stat_dictionary["cooldown"])
	$CDTimerRG.wait_time = cooldownRG
	gui.set_max(cooldownRG)
	$CDTimerTP.wait_time = cooldownTP
	gui.set_max2(cooldownTP)
	#$ShootdelayTimer.wait_time = float(stat_dictionary["delay"])

func _process(_delta):
	if gui != null:
		var rgtime = snapped($CDTimerRG.time_left,1) 
		var tptime = snapped($CDTimerTP.time_left,1)
		if railgun_ready:
			rgtime = cooldownRG
		if torpedo_ready:
			tptime = cooldownTP
		gui._on_update_module_ui(stage,rgtime,tptime)

####################################################################################################
################################## Railgun Functions ###############################################
####################################################################################################
func rgshoot():
	var player = ManagerGame.global_player_ref
	if railgun_ready:
		railgun_ready = false
		spawn_explosion(player.get_node("RG2").global_position)
		railgun_burst_fire()
		$CDTimerRG.start()

func railgun_burst_fire():
	var player = ManagerGame.global_player_ref
	var rg_markers = [player.get_node("RG1"), player.get_node("RG2"), player.get_node("RG3")]
	for i in range(shotpstage[stage]):
		railgun_fire(rg_markers[i].global_position)
		await get_tree().create_timer(0.2).timeout

func railgun_fire(spawn_position):
	$RailgunSFX.play()
	#var railgunSpawnPosition = global_position + Vector2(195, 0)
	var fixedDirection = Vector2.RIGHT
	spawn_railgun(spawn_position, fixedDirection, damageRG)

func spawn_railgun(g_pos: Vector2, dir, damage):
	var b = railgunbullet.instantiate()
	sort.add_child(b)
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage

func _on_cd_timer_rg_timeout():
	railgun_ready = true 

func spawn_explosion(at_position:Vector2):
	var rg_particles = rgparticles.instantiate()
	sort.add_child(rg_particles)
	rg_particles.global_position = at_position 
####################################################################################################
################################## Torpedo Functions ###############################################
####################################################################################################
func tplaunch():
	if torpedo_ready:
		var targets = get_tree().get_nodes_in_group("TorpedoTarget")
		if targets.size() > 0:
			torpedo_ready = false
			torpedoSalvoLaunch()
			$CDTimerTP.start()
		else:
			print("No targets to shoot")

func torpedoSalvoLaunch():
	var player = ManagerGame.global_player_ref
	var torp_markers = [player.get_node("Torp1"), player.get_node("Torp2"), player.get_node("Torp3"), player.get_node("Torp4"), player.get_node("Torp5"), player.get_node("Torp6")]
	#var number_of_torps = min(torpshotstage[stage], torp_markers.size())
	for i in range(torpshotstage[stage]):
		torpedolaunch(torp_markers[i].global_position)
		await get_tree().create_timer(0.5).timeout#torpedolaunch()
		print("TorpAways")
		#$torpedodelay.start()

func torpedolaunch(spawn_position):
	$TorpedoSFX.play()
	#var torpedoSpawnPosition = global_position + Vector2(38, 41)
	#var fixedDirection = Vector2.RIGHT
	var targets = get_tree().get_nodes_in_group("TorpedoTarget")
	print(str("The number of targets is") + str(targets.size()))
	if targets.size() > 0:
		var target = targets[0]  # Choose the first enemy in the group as the target
		spawn_torpedo(spawn_position, target, damageTP )
	else:
		print("No targets available in 'TorpedoTarget' group")
	#spawn_torpedo(torpedoSpawnPosition, fixedDirection, damageTP)
	#var e = ManagerGame.global_world_ref.get_closest(global_position)
	#if e:
	#	ManagerGame.global_world_ref.spawn_torpedo(torpedoSpawnPosition, e, damageTP)

func spawn_torpedo(g_pos, target, damage):
	var b = torpedoahoy.instantiate()
	b.global_position = g_pos
	b.target = target
	sort.add_child(b)
	b.damage = damage

signal torp_targeter(targets)

func _on_torp_targeter(targets):
	if torpedo_ready:
		emit_signal("torpedotargets",targets)
		print("Torp_targeter")

func _on_cd_timer_tp_timeout():
	torpedo_ready = true 
