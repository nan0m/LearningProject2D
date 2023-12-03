extends Area2D
var global_collision_point : Vector2

func _ready():
	connect("area_entered", Callable(self, "_on_Area2D_area_entered"))

func _on_Area2D_area_entered(area: Area2D):
	var global_collision_point = area.global_position
	var closest_point = get_closest_point_on_line(global_collision_point)
	# Do something with the closest_point
	var line = $ShieldOutline #nothing good here...
	if line.material is ShaderMaterial:
		line.material.set_shader_parameter("hit_position", global_collision_point)

func get_closest_point_on_line(global_point: Vector2) -> Vector2:
	var line = $ShieldOutline
	print($ShieldOutline.get_point_count())
	var closest_distance = INF
	var closest_point = Vector2.ZERO
	for i in range(line.get_point_count() - 1):
		var segment_start = line.get_point_position(i)
		var segment_end = line.get_point_position(i + 1)
		var closest_on_segment = get_closest_point_to_segment(global_point, segment_start, segment_end)
		var distance = global_point.distance_to(closest_on_segment)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = closest_on_segment
	print(closest_point)
	return closest_point
	

func get_closest_point_to_segment(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> Vector2:
	var segment = segment_end - segment_start
	var len2 = segment.length_squared()
	if len2 == 0.0:
		return segment_start
	var t = ((point - segment_start).dot(segment)) / len2
	if t < 0.0:
		return segment_start
	elif t > 1.0:
		return segment_end
	return segment_start + segment * t
