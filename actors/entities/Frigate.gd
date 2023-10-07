extends Sprite2D

var enemy_type = ManagerGame.enemy_data['frigate']['class']
var move_speed = ManagerGame.enemy_data['frigate']['speed']
var hp = ManagerGame.enemy_data['frigate']['hp']   #enemy hitpoints, obviously
var edamage = ManagerGame.enemy_data['frigate']['attack']  #enemy damage
var rof = ManagerGame.enemy_data['frigate']['rof']   #enemy rate of fire
var rng = ManagerGame.enemy_data['frigate']['range'] #enemy range
var notu = ManagerGame.enemy_data['frigate']['not']  #number of turret
@export var locked = false
var target_distance = rng
var mi_damage = edamage*2
 
var screen_size
func _ready():
	$HP.max_value = hp
	$HP.value = hp
	$AttackTimer.wait_time = rof
	screen_size = get_viewport().get_visible_rect().size
	add_to_group("Small_enemies")

func _physics_process(delta):
	global_position += Vector2.LEFT * int(move_speed) * delta
	
	if global_position.x < -100:
		queue_free()
	var player_position = ManagerGame.global_player_ref.global_position
	var distance_to_player = global_position.distance_to(player_position)
	var deceleration_factor = 1.95
	if distance_to_player < (target_distance):
		move_speed = lerp(move_speed,0,delta*deceleration_factor)
		move_speed = int(move_speed)
		
	elif distance_to_player < (target_distance + 100):
		move_speed = lerp(move_speed, 10, delta * deceleration_factor)
		move_speed = int(move_speed)


func _on_hurtbox_area_entered(area):
	var explosion = load("res://actors/objs/Explosion.tscn").instantiate()
	ManagerGame.global_world_ref.spawn_obj(explosion, global_position)
	
	# this will get the bullet node itself which will contain a "damage" variable
	# this way, we can set a different damage for every bullet that will collide with
	# this enemy
	var damage = area.get_parent().damage
	_hurt(damage)
	# this will essentially just refresh the hp bar's value
	$HP.value = hp

func _on_attack_timer_timeout():
	_fire_to_player()
	$AttackTimer.start()

func _fire_to_player():
	var distance_to_player = global_position.distance_to(ManagerGame.global_player_ref.global_position)
	if distance_to_player <= rng:
		for i in range(notu):
			var b = load("res://actors/objs/EnemyBullet.tscn").instantiate()
			ManagerGame.global_world_ref.spawn_obj(b, global_position)
			b.dir = global_position.direction_to(ManagerGame.global_player_ref.global_position)
			b.damage = edamage
			b.look_at(ManagerGame.global_player_ref.global_position)
			await get_tree().create_timer(0.2).timeout


func _hurt(damage):
	#var damage = area.get_parent().damage
	hp -= damage
	$HP.value = hp
	var df1 = load("res://actors/extras/DamageFloater.tscn").instantiate()
	df1.get_node('Label').text = '%s' % damage
	df1.orig_pos = global_position
	ManagerGame.global_world_ref.spawn_obj(df1, global_position)
	if hp <= 0:
		ManagerGame.global_player_ref.player_data['gold'] += 150
#commented this line to test the enemy in a test scene
		queue_free()
		$Enemy_Death.play()

func _on_attack_timer_2_timeout():
	_fire_missile()
	$AttackTimer2.start()

func _fire_missile():
	var m = load("res://actors/objs/EnemyMissile.tscn").instantiate()
	m.dir = global_position.direction_to(ManagerGame.global_player_ref.global_position)
	m.damage = mi_damage
	ManagerGame.global_world_ref.spawn_obj(m, global_position)

