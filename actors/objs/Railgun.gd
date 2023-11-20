extends Node2D

var speed = 1000.0
var dir = Vector2.ZERO
var damage = 200

func _physics_process(delta):
	if dir.x <0:
		dir.x = 0
		queue_free()
	dir.y = 0 
	global_position += dir * speed * delta

func set_direction(direction: Vector2):
	dir = direction.normalized()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_2d_area_entered(_area):
	$Collision.show()

func _on_area_2d_area_exited(_area):
	$Collision.hide()
