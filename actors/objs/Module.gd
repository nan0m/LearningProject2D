#This module basically represents the offensive abilities of the ship. 
#module': {        
#		'scanner': 1,     
#		'stage': 1,    
#		'CT': 5, <-Control Tower former attack   
#		'cooldown': 2, 
#		'price': 4000
#Thise module requires different upgrade costs!!!!!

#The 'stage' has 5 levels total. Expensive upgrade!
#	1. Unlocks the torpedo launch ability
		#this ability launches 6 torpedoes to the enemy. 
#	2. Unlocks the railgun ability.
#		This level unlocks only 1 shot of the railgun
#		Has 5% chance to cause damage of 25% of current HP? 
#	3. Unlocks the 2nd shot of the railgun
#		Has 15% chance to cause damage of 25% of current HP? 
#	4. Unlocks the 3rd and final shot of the railgun (total 3 shots)
#		Has 30% chance to cause damage of 25% of current HP?  
#	5. Level 5 gives a 25% damage increase to all abilities (each torpedo, and railgun shot + 25% each). 
#
#The 'attack' <- renamed maybe to 'control tower', grants damage increase to all turrets additionally to the 
#	individual turrets upgrades. This one increases the Base stat which then the turret upgrades take into account in
#	their calculations.
#	Each level increases base damage by +5. There 10 levels max. (total base damage at last level + 50). 
#	To make this more balanced the price should be VERY high. 
#The cooldown grants -10s per level to torpedo and railgun abilities. Max 5 levels. (-50s at max level). 
#	Slightly an expensive upgrade. 
#The scanner upgrade passively increases the range of all turrets base range +50.
#	Max levels 10. Total max range +500.
extends Node2D

