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
