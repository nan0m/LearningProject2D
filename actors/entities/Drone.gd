#dronebay': {      #Thise module requires different upgrade costs!!!!!
#		'drones': 1,   #Number of drones: 1/2/3/4/5/6/7/8/9/10 (max)
#$		'rof': 8,      #2% increase in rof per level (10 levels max)
#		'attack': 10,  #abilities damage + 5% per updrade (max 5): 
#		'replenish':30,#frequency at which the destroyed drone gets replenished.  

extends Sprite2D
# drone properties
var move_speed = 280
var hp = 100  
var adamage = ManagerGame.weapons_data["dronebay"]["attack"]
var rof = ManagerGame.weapons_data["dronebay"]["rof"]
var range = 300
@export var locked = false
var target_distance = 90
var torpedocapacity = 5
var droneexplosion := preload("res://actors/objs/Explosion.tscn")
signal drone_spawned(ally_instance)
var sort = null
var dronemissileallyahoy := preload("res://actors/objs/Missile.tscn")
var dronebulletallyahoy := preload("res://actors/objs/Bullet.tscn")

func _ready():
	$HP.max_value = hp
	$HP.value = hp
	$AttackTimer1.wait_time = rof
	$AttackTimer5.wait_time = (rof + 3)
	$Range/CollisionShape2D.shape.radius = range
	emit_signal("drone_spawned", self)
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
	var explosion = droneexplosion.instantiate()
	ManagerGame.global_world_ref.spawn_obj(explosion, global_position)
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
################################# DRONE-SHOOTING #####################################
######################################################################################
func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if sort != null:
		if e and get_node("W5").global_position.distance_to(e.global_position) <= range:
			var distance = get_node("W5").global_position.distance_to(e.global_position)
			spawn_missile1a(get_node("W5").global_position, e, adamage * 3)

func spawn_missile1a(g_pos: Vector2, target, damage):
	var b = dronemissileallyahoy.instantiate()
	b.global_position = g_pos
	b.target = target
	b.damage = damage
	sort.add_child(b)

func shootL1():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		spawn_bullet1a(get_node("W1").global_position, get_node("W1").global_position.direction_to(e.global_position), adamage)

func spawn_bullet1a(g_pos: Vector2, dir, damage):
	var b = dronebulletallyahoy.instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	b.look_at(dir)
	sort.add_child(b)

func _on_attack_timer_timeout():
	shootL1()

func _on_attack_timer_5_timeout():
	shoot()
