extends Node2D


var target = null
var max_speed = 500
var _current_velocity := Vector2.ZERO
var drag_factor = 0.2
var damage = 25
var count = 10 
func _ready():
	#_current_velocity = max_speed * Vector2.RIGHT.rotated(rotation)
	_current_velocity = max_speed * Vector2.UP.rotated(rotation)

func _physics_process(delta):
	if count > 0:
		count -= 1
		_current_velocity *= 0.5
	var direction := Vector2.RIGHT.rotated(rotation).normalized()
	var desired_velocity = direction * max_speed
	#var previous_velocity = _current_velocity
	var change = (desired_velocity - _current_velocity) * drag_factor
	if target and is_instance_valid(target):
		direction = global_position.direction_to(target.global_position)
		#look_at(global_position + direction)
		look_at(target.global_position - global_position)
	else:
		target = null
	_current_velocity += change
	global_position += _current_velocity * delta
	look_at(global_position + _current_velocity)
	#Replicating this tutorial: https://www.youtube.com/watch?v=Yg1uacsMSl8



func _on_area_2d_area_entered(_area):
	queue_free()
