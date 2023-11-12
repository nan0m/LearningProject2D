extends Node2D

var range = 2000
var target = null
var max_speed = 170
var arc_speed = 150
var damage = 25
#var upward_time = 0.5
var _current_velocity := Vector2.ZERO
#var current_time = 0.0
#var arch_speed = 150
#var arc_height = 100.0
#var rotation_speed = 2
func _ready():
	#_current_velocity = max_speed * Vector2.RIGHT.rotated(rotation)
	_current_velocity = arc_speed * Vector2.UP.rotated(rotation)*5

func _process(delta):
	if target and is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		var desired_velocity = direction * max_speed
		#var previous_velocity = _current_velocity
		var change = (desired_velocity - _current_velocity)*0.15
		_current_velocity += change
		position += _current_velocity*delta
		look_at(global_position + _current_velocity)
		#	var direction = global_position.direction_to(target.global_position)
		#var distance_to_target = global_position.distance_to(target.global_position)
		#if current_time < upward_time:
		#	var upward_force = Vector2.UP * arc_height
		#	var upward_movement = upward_force * delta
		#	global_position += upward_movement
		#	current_time += delta
		#	rotation = -PI/2
		#else:
			#var arch_movement = direction.normalized() * arch_speed * delta
			#global_position += arch_movement
			#var target_rotation = global_position.angle_to_point(target.global_position)
			#rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
			#look_at(global_position + direction)
			
	else:
		queue_free()

#func lerp_angle(from: float, to: float, weight: float) -> float:
#	var difference = fmod(to - from + PI, 2.0 * PI) - PI
#	return from + difference * weight

#func get_closest_enemy_in_group(group_name):
#	var closest_enemy = null
#	var closest_distance = INF
#	for enemy in get_tree().get_nodes_in_group(group_name):
#		var distance = global_position.distance_to(enemy.global_position)
#		if distance < closest_distance:
#			closest_distance = distance
#			closest_enemy = enemy
#	return closest_enemy
	
func _on_area_2d_area_entered(_area):
	#$AnimationPlayer.play("missilehit")
	$GPUParticles2D.emitting = true
	max_speed = 0
	$Sprite2D.hide() 
	$EngineTrail.hide()
	check_particles_finished()
	#not anything cool in the animation for the torpedo. Needs a cooler explosion.
	#Keep as place holder

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Replace with function body.

func check_particles_finished():
	await get_tree().create_timer($GPUParticles2D.lifetime).timeout
	# Check every frame if there are still particles.
	while $GPUParticles2D.is_emitting or $GPUParticles2D.particle_count > 0:
		await get_tree().process_frame
	# No more particles, we can safely queue_free now.
	queue_free()
#########TESTS
#func _physics_process(delta): #reset this whole shit.
#	if count > 0:
#		count -= 1
#		_current_velocity *= 0.5
#	var direction := Vector2.RIGHT.rotated(rotation).normalized()
#	var desired_velocity = direction * max_speed
#	#var previous_velocity = _current_velocity
#	var change = (desired_velocity - _current_velocity) * drag_factor
#	if target and is_instance_valid(target) and global_position.distance_to(target.global_position) <= range:
#		print("target") 
#		direction = global_position.direction_to(target.global_position)
#		#look_at(global_position + direction)
#		look_at(target.global_position - global_position)
#	else:
#		target = null
#	_current_velocity += change
#	global_position += _current_velocity * delta
#	look_at(global_position + _current_velocity)
#	#Replicating this tutorial: https://www.youtube.com/watch?v=Yg1uacsMSl8

#func _on_animation_player_animation_finished(_anim_name):
#	queue_free() # Replace with function body.
