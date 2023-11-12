#This is the players ally that will appear in mission. The player will have drones as personal allies.
#The ally has a few turrets, and a missile launcher. It is able to tank some damage, but cannot survive
#for an extensive ammount of time. Deals very good ammount of damage, and if the player protects them well
#they can have them for a long while. 
#The ally does not extent far from the player, and basically maintains a close distance. If the player is too
#low on HP they will move closer to the front and try to absorb some damage until the player heals up.
#If the ally is on low HP, then hiding behind the player and trying to kite enemies is their task. 
#They can be called upon by the player. The ability becomes available once the Players has fully researched the
#defence module (or the Control Tower?). Very long cooldown. 200seconds. 
#It has a passive ability: 25% to dodge incoming turret fire.  

extends Sprite2D
# Ally properties
var move_speed = 120
var hp = 1800   
var adamage = 15  #enemy damage
var rof = 2   #enemy rate of fire
var weapon_range = 1500 #enemy range
var notu = 4  #number of turret
@export var locked = false
var target_distance = 90
var target_enemy = null
signal ally_spawned(ally_instance)
var sort = null
var missileallyahoy := preload("res://actors/objs/Missile.tscn")
var bulletallyahoy := preload("res://actors/objs/Bullet.tscn")
func _ready():
	$HP.max_value = hp
	$HP.value = hp
	$AttackTimer1.wait_time = rof
	$AttackTimer2.wait_time = rof
	$AttackTimer3.wait_time = rof
	$AttackTimer4.wait_time = rof
	$AttackTimer5.wait_time = (rof + 3)
	$Range/CollisionShape2D.shape.radius = weapon_range
	emit_signal("ally_spawned", self)
	sort = get_parent().get_parent().get_node("Sort")

func _physics_process(delta):
	ally_movement(delta)

func ally_movement(delta):
	global_position += Vector2.RIGHT * int(move_speed) * delta
	var player_position = ManagerGame.global_player_ref.global_position
	var distance_to_player = global_position.distance_to(player_position)
	var deceleration_factor = 0.95
	if distance_to_player < (target_distance):
		move_speed = lerp(move_speed,0,delta*deceleration_factor)
		move_speed = int(move_speed)
	elif distance_to_player < (target_distance + 100):
		move_speed = lerp(move_speed, 10, delta * deceleration_factor)
		move_speed = int(move_speed)

########################################################################################
################################## ALLY GETTING HIT ####################################
########################################################################################
func _on_hurtbox_area_entered(area):
	# this will get the bullet node itself which will contain a "damage" variable
	# this way, we can set a different damage for every bullet that will collide with
	# this enemy
	var damage = area.get_parent().damage
	hit(damage)
	# this will essentially just refresh the hp bar's value
	$HP.value = hp
	if hp <= 0:
		queue_free()

func hit(damage: int = 1):
	hp -= damage
	$HP.value = hp

######################################################################################
################################## ALLY-SHOOTING #####################################
######################################################################################
func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if sort != null:
		if e and get_node("W5").global_position.distance_to(e.global_position) <= weapon_range:
			#var distance = get_node("W5").global_position.distance_to(e.global_position)
			spawn_missile1(get_node("W5").global_position, e, adamage * 3) #ManagerGame.global_world_ref.

func spawn_missile1(g_pos: Vector2, target, damage):
	var b = missileallyahoy.instantiate()
	b.global_position = g_pos
	b.target = target
	b.damage = damage
	sort.add_child(b)

func shootL1():
	if sort != null:
		var e = ManagerGame.global_world_ref.get_closest(global_position)
		if e:
			spawn_bullet1(get_node("W1").global_position, get_node("W1").global_position.direction_to(e.global_position), adamage)
func shootL2():
	if sort != null:
		var e = ManagerGame.global_world_ref.get_closest(global_position)
		if e:
			spawn_bullet1(get_node("W2").global_position, get_node("W2").global_position.direction_to(e.global_position), adamage)
func shootL3():
	if sort != null:
		var e = ManagerGame.global_world_ref.get_closest(global_position)
		if e:
			spawn_bullet1(get_node("W3").global_position, get_node("W3").global_position.direction_to(e.global_position), adamage)
func shootL4():
	if sort != null:
		var e = ManagerGame.global_world_ref.get_closest(global_position)
		if e:
			spawn_bullet1(get_node("W4").global_position, get_node("W4").global_position.direction_to(e.global_position), adamage)

func spawn_bullet1(g_pos: Vector2, dir, damage):
	var b = bulletallyahoy.instantiate()
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	b.global_position = g_pos
	b.dir = global_position.direction_to(e.global_position)
	b.damage = damage
	b.look_at(dir)
	sort.add_child(b)

func _on_attack_timer_timeout():
	shootL1()

func _on_attack_timer_2_timeout():
	shootL2()

func _on_attack_timer_3_timeout():
	shootL3()

func _on_attack_timer_4_timeout():
	shootL4()

func _on_attack_timer_5_timeout():
	shoot()
