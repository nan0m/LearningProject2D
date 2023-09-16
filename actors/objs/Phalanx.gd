extends Node2D

var target = null
var ammoCount = 0
var maxAmmoCount = 50
var ReloadTime = 10
var isReloading = false
var bulletSpreadAngle = 5.0
var damage = ManagerGame.weapons_data['phalanx']['attack']
var range = ManagerGame.weapons_data['phalanx']['range']
var sort = null

var random_generator = null
var crit_damage_modifier = 2
#func _unhandled_input(event):
#	if event is InputEventScreenTouch and !event.pressed:
#		ManagerGame.global_world_ref.spawn_bullet(global_position)
func _ready():
	$ReloadTimer.wait_time = ReloadTime
	$ReloadTimer.one_shot = true
	$AmmoBelt.max_value = maxAmmoCount
	$Range/CollisionShape2D.shape.radius = range
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	sort = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Sort")
	print($Range/CollisionShape2D.shape.radius)

func _physics_process(_delta):
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		look_at(e.global_position)

func shoot():
	if isReloading:
		return
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		$lazer.play()
		
		spawn_phalanxbullet(global_position, global_position.direction_to(e.global_position),damage)
		var direction = global_position.direction_to(e.global_position)
		direction = applyBulletSpread(direction)
		ammoCount += 1
		$AmmoBelt.value = ammoCount
		print(ammoCount)
		if ammoCount >= maxAmmoCount:
			ammoCount = 0
			start_reload_timer()

func applyBulletSpread(direction):
	var randomAngle = randf_range(-bulletSpreadAngle, bulletSpreadAngle)
	var rotatedDirection = direction.rotated(randomAngle)
	return rotatedDirection

func start_reload_timer():
	isReloading = true
	$ReloadTimer.start()

func _on_reload_timer_timeout():
	isReloading = false

func _on_timer_timeout():
	var e = ManagerGame.global_world_ref.get_closest(global_position)
	if e:
		var distance = global_position.distance_to(e.global_position)
		if distance <= range:
			shoot()

func _on_range_area_entered(area):
	area.get_parent().add_to_group('Enemy')

func _on_range_area_exited(area):
	area.get_parent().remove_from_group('Enemy')

func update_stats(stat_dictionary):
	ReloadTime = 1/stat_dictionary["rof"]
	$ReloadTimer.wait_time = ReloadTime
	maxAmmoCount = stat_dictionary["ammobelt"]

func spawn_phalanxbullet(g_pos: Vector2, dir, damage):
	var b = load("res://actors/objs/PhalanxBullet.tscn").instantiate()
	b.global_position = g_pos
	b.dir = dir
	b.damage = damage
	sort.add_child(b)
