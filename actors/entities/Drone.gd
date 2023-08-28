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

signal drone_spawned(ally_instance)
func _ready():
	$HP.max_value = hp
	$HP.value = hp
	$AttackTimer1.wait_time = rof
	$AttackTimer5.wait_time = (rof + 3)
	$Range/CollisionShape2D.shape.radius = range
	emit_signal("drone_spawned", self)

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
	var explosion = load("res://actors/objs/Explosion.tscn").instantiate()
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
################################## ALLY-SHOOTING #####################################
######################################################################################
func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')

func shoot():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	
	if e and get_node("W5").global_position.distance_to(e.global_position) <= range:
		var distance = get_node("W5").global_position.distance_to(e.global_position)
		ManagerGame.global_world_ref.spawn_missile(get_node("W5").global_position, e, adamage * 3)

func shootL1():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		ManagerGame.global_world_ref.spawn_bullet(get_node("W1").global_position, get_node("W1").global_position.direction_to(e.global_position), adamage)

func _on_attack_timer_timeout():
	shootL1()

func _on_attack_timer_5_timeout():
	shoot()
