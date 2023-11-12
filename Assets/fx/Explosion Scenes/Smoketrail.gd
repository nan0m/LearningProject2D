extends Line2D
class_name MissileTrail

var queue : Array #store the points so that we remove the ending
@export var MAX_LENGTH : int
var generating: bool = true

func _process(_delta):
	if generating:
		var pos = _get_position()
		queue.push_front(pos)
		if queue.size() > MAX_LENGTH:
			queue.pop_back()
	update_trail()

func _get_position():
	return get_global_mouse_position()

func update_trail():
	clear_points()
	for point in queue:
		add_point(point)

func stop():
	generating = false
	for point in queue:
		queue.pop_back()
