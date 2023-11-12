extends Node2D


var target = null
var speed = 400
var direction = Vector2.RIGHT  # Initial direction of the missile
var damage

@onready var missiletrail = $MissileTrail
func _physics_process(delta):
	direction = direction.rotated(randf_range(-0.1,0.1))
	if target and is_instance_valid(target):  
		direction = lerp(direction.rotated(randf_range(-0.1,0.1)),global_position.direction_to(target.global_position),0.1)
		#direction = global_position.direction_to(target.global_position)
		look_at(global_position + direction)
	else:
		target = null
	global_position += direction * speed * delta

func _on_area_2d_area_entered(_area):
	$AnimationPlayer.play("missilehit")
	speed = 0
	missiletrail.stop() 

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Replace with function body.

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
