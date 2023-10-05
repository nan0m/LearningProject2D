extends Node2D


var speed = 500.0
var dir = Vector2.ZERO
var damage

func _physics_process(delta):
	global_position += dir * speed * delta

func _ready():
	pass#look_at(get_global_mouse_position())
#func set_direction(direction: Vector2):
#	dir = direction.normalized()
#	print(dir)

func _on_area_2d_area_entered(_area):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

