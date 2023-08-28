extends Node2D
@onready var FOV=$Area2D
#so this is the Field of view of the turret, which is a sphere area 2d
@onready var LazerRaycast=$LazerRaycast
#this is the raycast that get's the collision point of the lazer
@onready var LazerLine=$LazerRaycast/Lazer
#this is the lazer itself which is a line2d
@onready var lazerBar=$ProgressBar
#this is the progress bar, i used it as a cooldown for shooting the lazer

@onready var FOVshape=$Area2D/CollisionShape2D

@onready var startParticles=$LazerRaycast/StartParticles
#these are the particles at the beginning of the lazer
@onready var endParticles=$LazerRaycast/EndParticles
#these are the particles at the end of the lazer
@onready var lazerParticles=$LazerRaycast/LazerParticles
#these are the particles of the wole lazer

@export var maxLazerValue=100
#this is the lazer cooldown value, you can change it anytime
var ldamage = ManagerGame.weapons_data['lazer']['attack']
var range = ManagerGame.weapons_data['lazer']['range']

var target=null
#this is where the enemy is stored
var apeared=false
#this tells us if the lazer is being shot or no
func _ready():
	_update_stats(ldamage,range)
	$LazerRaycast/Lazer.width=0
#this hide the lazer by setting the width to 0

func _update_stats(dam:int=10,ran:int=500):
	ldamage=dam
	range=ran
	FOVshape.shape.radius=range
#set the shape of the area 2d
	LazerRaycast.target_position=Vector2(range,0)
#set the length of the raycast

func _process(delta):
	_detect_enemy(delta)
#the detect function must be inside the process to be updated each frame

func _detect_enemy(delta):
	if target==null:
#if we don't have a target
		if apeared:
			_lazer_disappear()
#if the lazer is shooting, we hide it
		if lazerBar.value<maxLazerValue:
#if the lazer cooldown is not full, we fill it up by 10 units each second
			lazerBar.value+=delta*10
			if lazerBar.value<maxLazerValue/2:
#if the lazer cooldown is less than half, the turret can't shoot  (remove return to disable this)
				return
		if FOV.has_overlapping_areas():
#if there are areas inside the FOV we do the following
			for i in FOV.get_overlapping_areas():
				if i.get_parent().is_in_group("Enemy"):
#if the parent of the area is Enemy (sprite2d)
					if !i.get_parent().locked:
#if the enemy isn't locked, we take it as a target and we make it locked
						target=i
						target.get_parent().locked=true
						return
	else:
#if the target isn't null (it exists) we shoot the lazer
		_shoot_lazer(delta)

func _shoot_lazer(delta):
	_lazer_appear()
#we first apear the lazer
	if lazerBar.value>delta*5:
#if the lazer cooldown bar isn't close to 0, we remove 50 units from it each second
		lazerBar.value-=delta*50
		target.get_parent()._hurt(delta*ldamage)
#we hurt the target by ldamage hp each second
	else:
#if the lazer cooldown is low
		if target!=null:
			target.get_parent().locked=false
#we check if the target isn't dead yet, if yes, we remove the lock
		target=null
#we make the target null
		_lazer_disappear()
#we hide the lazer
		return
#we skip the rest of the code after return
	LazerRaycast.look_at(target.global_position)
#now this makes the turret cannon look at the target
	if LazerRaycast.is_colliding():
#if the raycast is colliding (we set the same collision mask as the enemy, and check the box for the raycast
#to detect area2d)
		var point=LazerRaycast.to_local(LazerRaycast.get_collision_point())
#we get the collision point
		var distance=LazerLine.points[0].distance_to(point)
#we get the distance
		endParticles.position=point
		LazerLine.points[1]=point
#we set the positions of the begin and end particles
		lazerParticles.set_emission_rect_extents(Vector2(distance/2,0))
#we set the length and the position of the lazer particl
		lazerParticles.position.x=distance/2


func _lazer_appear():
	if !apeared:
#in this script we check if the lazer didn't apear yet
		startParticles.emitting=true
		endParticles.emitting=true
		lazerParticles.emitting=true
#we emit the particles first
		var tween=get_tree().create_tween()
		tween.tween_property(LazerLine,"width",5,0.5)
#we tween the width to make a nice animation, the width will go from 0 to 5
		apeared=true
#we set apear to true

func _lazer_disappear():
	if apeared:
#here we check if the lazer has apeared to hide it
		startParticles.emitting=false
		endParticles.emitting=false
#we stop the particles
		var tween=get_tree().create_tween()
		tween.tween_property(LazerLine,"width",0,0.5)
#we tween the width from 5 to 0, to make a nice hiding animation
		apeared=false
#we set apeared to false, so this code isn't executed more than once


func _on_area_2d_area_entered(area):
	area.get_parent().add_to_group('Enemy')


func _on_area_2d_area_exited(area):
	area.get_parent().remove_from_group('Enemy')
