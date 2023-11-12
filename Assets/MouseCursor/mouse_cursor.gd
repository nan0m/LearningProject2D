extends Node2D

enum MouseState {
	DEFAULT,
	PRESSED,
	HOVER_ENEMY,
	HOVER_HYPERLINK,
}

var mouse_state = MouseState.DEFAULT
var textures = {
	MouseState.DEFAULT: preload("res://Assets/MouseCursor/mouse.png"),
	MouseState.PRESSED: preload("res://Assets/MouseCursor/mouse.png"),
	MouseState.HOVER_ENEMY: preload("res://Assets/MouseCursor/mouse2.png")
	#MouseState.HOVER_HYPERLINK: preload("res://path/to/mouse4.png")
}
var testmouse = preload("res://Assets/MouseCursor/mouse2.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_custom_mouse_cursor(testmouse,Input.CURSOR_POINTING_HAND)

func _process(delta):
	self.position = self.get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_state = MouseState.PRESSED
	else:
		mouse_state = MouseState.DEFAULT
	update_cursor_texture()

func update_cursor_texture():
	$Sprite2D.texture = textures[mouse_state]

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var hover_enemy = false
		var hover_hyperlink = false
		for area in get_tree().get_nodes_in_group("big_enemies"):
			if area.get_rect().has_point(event.position):
				hover_enemy = true
				break
		for area in get_tree().get_nodes_in_group("hyperlink"):
			if area.get_rect().has_point(event.position):
				hover_hyperlink = true
				break
		if hover_enemy:
			mouse_state = MouseState.HOVER_ENEMY
		elif hover_hyperlink:
			mouse_state = MouseState.HOVER_HYPERLINK
