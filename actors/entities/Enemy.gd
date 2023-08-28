extends Sprite2D

# ##########################################
# ##########################################
# WE DONT NEED TO CREATE A NEW SCRIPT FOR EACH ENEMY SINCE THEY WILL HAVE SHARED ATTRIBUTES ANYWAY
# WE CAN JUST EXPORT THE VARIABLE SO THEY WOULD HAVE DIFFERENT AMOUNTS OF HP, SPEED, ETC.
# only make separate scripts for each enemy if absolutely neccesary
# ##########################################
# ##########################################

@export var enemy_type = ManagerGame.ENEMY_TYPE
@export var move_speed = 160.0
@export var hp = 30   #enemy hitpoints, obviously
@export var edamage = 20  #enemy damage
@export var rof = 5   #enemy rate of fire
@export var rng = 300 #enemy range
@export var locked = false
var mi_damage = 100

func _ready():
	$HP.max_value = hp
	$HP.value = hp


func _physics_process(delta):
	global_position += Vector2.LEFT * move_speed * delta
	
	if global_position.x < -100:
		queue_free()



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
	var b = load("res://actors/objs/EnemyBullet.tscn").instantiate()
	b.dir = global_position.direction_to(ManagerGame.global_player_ref.global_position)
	b.damage = edamage
	ManagerGame.global_world_ref.spawn_obj(b, global_position)
	

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

func _missile_fire():
	var m = load("res://actors/objs/EnemyMissile.tscn").instantiate()
	m.dir = global_position.direction_to(ManagerGame.global_player_ref.global_position)
	m.damage = mi_damage
	ManagerGame.global_world_ref.spawn_obj(m, global_position)

func _on_attack_timer_2_timeout():
	_missile_fire() # Replace with function body.
