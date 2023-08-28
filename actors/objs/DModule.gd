#defmodule': {     #Thise module requires different upgrade costs!!!!!
#		'hp': 200,     
#		'stage': 1,    
#		'restore': 1,  
#		'cooldown': 2, 
#		'price': 3000

#This module handles the defensive capabilities of the ship.
#The HP increases the base health per 50hp per level
#
#The 'restore' Unlocks the passive repair ability. 
#		Passively repair the ship per 0.02% per second (i.e.: 0.00002*5000 = 1hp per second). 
#		Each level increases passive repair per 0.000005*HP
#Stage has 5 levels. 
#	1. Unlocks the Damage-Control ability. 
#		This ability allows for quick repairs of the ship.
#		Heals for 15% of Max HP. Costs 100 resources.
#	2. Heals for 20% of Max HP. Costs 110 resources.
#	3. Heals for 25% of Max HP. Costs 125 resources.
#	4. Heals for 30% of Max HP. Costs 150 resources.
#	5. Unlocks the Shielding ability. 
#		This ability provides the ship with a 500hp damage tanking ability that lasts 10 seconds.
#		Cooldown is 30 seconds. 
#		Very Expensive Upgrade.
#  
#The Cooldown upgrade reduces all abilities cooldowns by -2s. (At max level -10s to defensive abilities' cooldowns). 

extends Node2D

var max_hp := 100  # Set the initial MAX_HP value here
var current_hp := max_hp
var passive_repair_rate := 0.02  # Initial passive repair rate
var passive_repair_upgrade := 0.005  # Increase in repair rate per upgrade
var passive_repair_level := 1  # Initial repair level

var damage_control_levels := [0.15, 0.2, 0.25, 0.3, 0.35]  # HP recovery percentages for different levels
var damage_control_cooldown := 90  # Cooldown period for the damage control ability
var damage_control_ready := true  # Flag to track if the ability is ready
var damage_control_level := 1

func _ready():
	pass# Your initialization code goes here

func _process(delta):
	var passive_repair_amount : float = max_hp * passive_repair_rate * passive_repair_level * delta
	current_hp = min(current_hp + passive_repair_amount, max_hp)
	# Damage control cooldown logic
	if !damage_control_ready:
		damage_control_cooldown -= delta
		if damage_control_cooldown <= 0:
			damage_control_ready = true

func activate_damage_control():
	if damage_control_ready:
		var recovery_percent : float = damage_control_levels[damage_control_level - 1]
		var recovery_amount := max_hp * recovery_percent
		current_hp = min(current_hp + recovery_amount, max_hp)
		damage_control_ready = false
		damage_control_cooldown = 90  # Reset cooldown timer

# Function to upgrade the passive repair ability
func upgrade_passive_repair():
	if passive_repair_level < 20:
		passive_repair_level += 1
		passive_repair_rate += passive_repair_upgrade

# Function to upgrade the damage control ability
func upgrade_damage_control():
	if damage_control_level < 5:
		damage_control_level += 1

# Handle input, e.g., Q button press to activate damage control ability
func _input(event):
	if event is InputEventKey and event.scancode == KEY_Q and event.is_pressed():
		activate_damage_control()

