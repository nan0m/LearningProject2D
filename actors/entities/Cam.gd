extends Camera2D


var speed = 600.0


func _ready():
	limit_left = $TL.global_position.x
	limit_right = $BR.global_position.x


func _physics_process(delta):
	if Input.is_action_pressed('ui_right'):
		global_position.x += speed * delta
	elif Input.is_action_pressed('ui_left'):
		global_position.x -= speed * delta

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if $".".zoom > Vector2(0.1,0.1):
					$".".zoom = $".".zoom - Vector2(0.05,0.05)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if $".".zoom < Vector2(0.75,0.75):
					$".".zoom = $".".zoom + Vector2(0.05,0.05)
