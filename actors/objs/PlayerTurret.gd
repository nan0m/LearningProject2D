extends Node2D

var rotation_speed = 0.5  #The maximum rotation speed in radians per second
@onready var reticle = $Reticle

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	var current_angle = rotation
	#Calculate the shortest direction to rotate
	var angle_difference = fposmod(target_angle - current_angle + PI, 2 * PI) - PI
	#Determine the rotation amount based on the rotation speed and the frame's delta time
	var rotation_amount = rotation_speed * delta
	rotation_amount = clamp(rotation_amount, -abs(angle_difference), abs(angle_difference))
	#Rotate the turret by the smaller of the two: the desired amount or what's left to the target angle
	if angle_difference < 0:
		rotation -= rotation_amount
	else:
		rotation += rotation_amount
	#Ensure rotation stays within a 0 to 2*PI range
	rotation = fposmod(rotation, 2 * PI)
	#Update the reticle position
	# The aim point is where the turret would be pointing if it turned towards the mouse
	var aim_point = global_position + Vector2(1, 0).rotated(rotation) * (mouse_pos - global_position).length()
	# Position the reticle at the aim point
	reticle.global_position = aim_point

