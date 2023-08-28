extends Node2D


var target = null
var speed = 550
var direction = Vector2.RIGHT  # Initial direction of the missile
var damage

func _physics_process(delta):
	
	if target and is_instance_valid(target): # Check if target is valid and not null
		direction = global_position.direction_to(target.global_position)
		look_at(global_position + direction)
	else:
		target = null
	global_position += direction * speed * delta


func _on_area_2d_area_entered(_area):
	queue_free()
