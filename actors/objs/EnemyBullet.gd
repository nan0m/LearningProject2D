extends Node2D


var speed = 500.0
var dir = Vector2.ZERO
var damage

func _ready():
	look_at(global_position + dir)


func _physics_process(delta):
	global_position += dir * speed * delta

func set_direction(direction: Vector2):
	dir = direction.normalized()

func _on_area_2d_area_entered(_area):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

