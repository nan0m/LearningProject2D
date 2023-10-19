extends Node2D


var target = null
var speed = 400
var direction = Vector2.RIGHT  # Initial direction of the missile
var damage

func _physics_process(delta):
	
	if target and is_instance_valid(target):  
		direction = global_position.direction_to(target.global_position)
		look_at(global_position + direction)
	else:
		target = null
	global_position += direction * speed * delta


func _on_area_2d_area_entered(_area):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Replace with function body.
