extends Node

signal weapon_equipped(slot_name)
signal gold_changed
signal weapon_scrapped(slot_name)
signal toggle_drones(toggled)
var testmouse = preload("res://Assets/MouseCursor/mouse2.png")
var testmouse2 = preload("res://Assets/MouseCursor/mouse.png")
func _ready():
	Input.set_custom_mouse_cursor(testmouse,Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(testmouse2,Input.CURSOR_ARROW)

enum WEAPON_TYPE{
	TURRET,   #artillery turret, long range, good damage
	BLASTER,  #lazer blaster shot, short range, good damage, fast bullet.
	MODULE,   #level 1 allows torpedo launcher ability. level 2, unlocks 1 railgun shot. Level 3, unlocks 2nd railgun shot. Lvl 4 unlocks the final 3rd shot.  
	DEFMODULE,#level 1 unlocks the "Damage-Control" Ability (Restore ship HP). Level 2 - 5 increases the effectiveness:  10/15/20/25/30% over 10 seconds.    
	MISSILE,  #turret that launches 1 missile that targets capitals. 
	PHALANX,  #targets enemy missiles, and fighters ONLY. Very short range.  
	ASM,      #targets enemy fighters. Long range.
	LAZER,   #short range lazer weapon. Targets all enemies (no missile). 
	DRONEBAY,  #Launches drones that assist the player with dealing with enemies. 
	RMODULE
}

var global_world_ref = null
var global_player_ref = null

#The number of upgrades is infinite (for future survival mode necessary). 
#The upgrade cost is increasing with every upgrade: 0.5n^3 + 5n^2 + 13.5n + 21 (rounded up), n: is the updrade level 

var weapons_data = {
	'turret': {
		'range': 800,  #+2% per upgrade in range (similar of all other turrets)  
		#'range_upgrades': [820,840,850],
		#'range_upgrade_cost': [100,200,500],
		'rof': 1,      #+5% per upgrade (max 5) #Rate of Fire
		'attack': 10,  #+1 AD per upgrade
		'critical': 0, #for each upgrade (200levels) +0.5 crit-chance: 0/0.5/1/1.5/2/2.5/3/3.5/........
		'price': 200
	},
	'blaster': {
		'range': 500, 
		'rof': 1.5,    #upgrading this ALSO increases the players rof
		'attack': 10,  #upgrading this ALSO increases the players turret damage
		'critical': 0, #for each upgrade (200levels) +0.5 crit-chance: 0/0.5/1/1.5/2/2.5/3/3.5/........
		'price': 200
	},
	'missile': {
		'range': 1000,
		'rof': 15,
		'attack': 25,
		'critical': 0, #for each upgrade (200levels) +0.5 crit-chance: 0/0.5/1/1.5/2/2.5/3/3.5/........
		'price': 800
	},
	'asm': {
		'range': 1200,
		'rof': 8,
		'attack': 5,
		'critical': 0, #for each upgrade (200levels) +0.5 crit-chance: 0/0.5/1/1.5/2/2.5/3/3.5/........
		'price': 1500
	},
	'lazer': {
		'range': 300,
		'rof': 3,
		'attack': 15,
		'critical': 0, #for each upgrade (200levels) +0.5 crit-chance: 0/0.5/1/1.5/2/2.5/3/3.5/........
		'price': 1500
	},#from here below are the modules/turrets that have different upgrade requirements. 
	'phalanx': {
		'range': 150,   #Can't upgrade this
		'rof': 35,      #improves ammobelt reload time (5% per level, max 5levels)
		'attack': 1,    #Can't upgrade this 
		'ammobelt': 100,#increases ammobelt size by 5 per level
		'price': 1000
	},
	'module': {        #Thise module requires different upgrade costs!!!!!
		'hp': 200,     #0.02 * 200 Bonus to Player's HP per level
		'stage': 1,    #level 1 allows torpedo launcher ability. level 2, unlocks 1 railgun shot. Level 3, unlocks 2nd railgun shot. Lvl 4 unlocks the final 3rd shot. Lvl 5 gives + 25% damage to all abilities
		'attack': 5,   #abilities damage + 5% per updrade (max 5)
		'cooldown': 90, #attack abilities cooldown bonus + 2% per upgrade (max 5)
		'price': 4000
	},
	'defmodule': {     #Thise module requires different upgrade costs!!!!!
		'hp': 200,     #0.02 * 200 Bonus to Player's HP per level
		'stage': 1,    #Level 1 unlocks the "Damage-Control" Ability (Restore ship HP). Level 2 - 5 increases the effectiveness:  10/15/20/25/30% of Max HP over 10 seconds. Level 6 unlocks EMP-PULSE (all enemies and your drones can't attack and are slowed 95% for 5 seconds. 
		'restore': 1,  #passive HP restoration. 0.01%/0.02%/0.03%/0.04% .... + 0.01% per level (of MAXHP:0.0001*HP)
		'cooldown': 2, #defense abilities cooldown bonus + 2% per upgrade (max 5)
		'price': 3000
	},
	'rmodule': {     #Thise module requires different upgrade costs!!!!!
		'hp': 200,     #0.02 * 200 Bonus to Player's HP per level
		'stage': 1,    #Level 1 unlocks the "Damage-Control" Ability (Restore ship HP). Level 2 - 5 increases the effectiveness:  10/15/20/25/30% of Max HP over 10 seconds. Level 6 unlocks EMP-PULSE (all enemies and your drones can't attack and are slowed 95% for 5 seconds. 
		'restore': 1,  #passive HP restoration. 0.01%/0.02%/0.03%/0.04% .... + 0.01% per level (of MAXHP:0.0001*HP)
		'cooldown': 2, #defense abilities cooldown bonus + 2% per upgrade (max 5)
		'price': 3500
	},
	'dronebay': {      #Thise module requires different upgrade costs!!!!!
		'drones': 1,   #Number of drones: 1/2/3/4/5/6/7/8/9/10 (max)
		'rof': 8,      #2% increase in rof per level (10 levels max)
		'attack': 10,  #abilities damage + 5% per updrade (max 5): 
		'replenish':30,#frequency at which the destroyed drone gets replenished.  
		'price': 6000
	}
}

func formatted_stats(weapon_type):
	var stats = ""
	var data = weapons_data[weapon_type]
	if data.has('range'):
		stats +=  "Range: " + str(data['range']) + " meters\n"
	if data.has('rof'):
		stats += "RoF: " + str(data['rof']) + " rounds per minute\n"
	if data.has('attack'):
		stats += "Attack Power: " + str(data['attack']) + "\n"
	if data.has('critical'):
		stats += "Critical Hit Chance: " + str(data['critical']) + "%\n"
	if data.has('ammobelt'):
		stats += "Ammo belt capacity:: " + str(data['ammobelt']) + "\n"
	if data.has('stage'):
		stats += "Stage: " + str(data['stage']) + "\n"
	if data.has('hp'):
		stats += "HP: " + str(data['hp']) + "\n"
	if data.has('cooldown'):
		stats += "Cooldown duration: " + str(data['cooldown']) + "s\n"
	if data.has('restore'):
		stats += "Restore amount: " + str(data['restore']) + "\n"
	if data.has('drones'):
		stats += "Drone amount: " + str(data['drones']) + "\n"
	if data.has('replenish'):
		stats += "Replenish amount: " + str(data['replenish']) + "\n"
	return stats
		
func get_upgradeable_fields(weapon_type):
	match weapon_type:
		'turret': 
			return ['range', 'rof', 'attack', 'critical']
		'blaster':
			return ['range', 'rof', 'attack', 'critical']
		'missile': 
			return ['range', 'rof', 'attack', 'critical']
		'asm':
			return ['range', 'rof', 'attack', 'critical']
		'lazer':
			return ['range', 'rof', 'attack', 'critical']
		'phalanx':
			return ['rof', 'ammobelt']
		'module':
			return ['hp', 'stage', 'attack', 'cooldown']
		'defmodule':
			return ['hp', 'stage', 'restore', 'cooldown']
		'dronebay':
			return ['drones', 'rof', 'attack', 'replenish']
		'rmodule':
			return ['hp', 'stage', 'restore', 'cooldown']

var weapons_dscr = {
	'turret': {
		'description': str("The RetrObliterator MkII Artillery Turret (Model RO-MkII) stands as a relic from a bygone era, harkening back to the formidable weapon systems of the early 21st century. While a thousand years have passed since its inception, the RO-MkII remains a testament to the raw, brute force that defined the weaponry of that time. Unapologetically massive and rugged, the RO-MkII's design exudes a utilitarian charm. Its angular, heavily armored chassis speaks of an era when aesthetics took a backseat to sheer functionality. Equipped with a collection of hydraulic stabilizers and retrofitted gyroscopes, the turret's aim is a testament to the engineering prowess of a past age. Though challenging to wield in the complexities of three-dimensional space, the RO-MkII compensates with raw, unrelenting firepower. 
		Utilizing ballistic shells reminiscent of the 21st-century artillery, the RO-MkII hurls explosive ordnance across vast distances with an awe-inspiring trajectory. Its long-range capabilities are unparalleled in the era of futuristic warfare, allowing it to strike targets that might be beyond the line of sight of more advanced weaponry. Each shell is armed with conventional high-explosive warheads, harnessing the immense kinetic energy of impact to devastate both fortified positions and armor. The targeting system, although lacking the sophistication of modern neural networks, relies on an array of optical and radar technologies to calculate trajectories. It requires the expertise of highly trained gunners to account for variables such as wind speed, elevation, and curvature of planetary bodies. This manual targeting process, a stark contrast to the automation of the future, contributes to the RO-MkII's reputation as a challenging but immensely satisfying weapon to operate. 
		While the RetrObliterator MkII Artillery Turret may seem archaic in comparison to the advanced weaponry of its distant future, it serves as a living testament to the tenacity of an earlier era. Its brute force, long-range capability, and the art of skilled manual aiming make it a relic cherished by collectors and a force to be reckoned with on the battlefield. Model RO-MkII stands as a reminder that even in the face of technological leaps, the echoes of the past can still resound with formidable power.")
	},
	'blaster': {
		'description': str('This blast')
	},
	'missile': {
		'description': str('The Quantum-X9 Plasma Annihilator (Model QX9-MA) stands as a pinnacle of destructive innovation in the arsenal of futuristic warfare, set a millennium ahead in time. Born from the convergence of advanced quantum engineering and plasma weaponry, the QX9-MA represents a testament to the unrelenting progress of technology.
		Harnessing the boundless energy of artificial quantum singularities, the QX9-MA is capable of generating and projecting controlled plasma streams with unprecedented precision and power. Its sleek, aerodynamic design minimizes air resistance during launch, ensuring swift deployment both within atmosphere and in the void of space. 
		The weapons advanced targeting system integrates neural network algorithms, allowing for real-time adaptation to enemy tactics and movements. This ensures that the plasma streams discharge with optimal accuracy, obliterating even the most agile and evasive targets. The model QX9-MAs compact fusion reactor serves as its power core, 
		enabling rapid firing sequences without compromising energy efficiency. In a battlefield dominated by energy shields and adaptive defenses, the Quantum-X9 Plasma Annihilator carves a path of devastation. The plasma streams, encased in a potent electromagnetic field, possess the unique capability to destabilize and penetrate the most
		resilient shielding technologies. This makes the QX9-MA an indispensable asset against heavily fortified positions and armored adversaries. As a representation of cutting-edge weaponry, the Quantum-X9 Plasma Annihilator exemplifies the fearsome ingenuity that arises in the distant future. Model QX9-MA serves as a stark reminder of the
		monumental advancements humanity achieves in the realm of warfare, a testament to both its determination and the cost of progress.')
	},
	'asm': {
		'description': str('This asm')
	},
	'lazer': {
		'description': str('This lazer')
	},#from here below are the modules/turrets that have different upgrade requirements. 
	'phalanx': {
		'description': str('This phala')
	},
	'module': {        #Thise module requires different upgrade costs!!!!!
		'description': str('This m')
	},
	'defmodule': {     #Thise module requires different upgrade costs!!!!!
		'description': str('This dm')
	},
	'dronebay': {      #Thise module requires different upgrade costs!!!!!
		'description': str('This drone')
	}
}

###################################################################################################
##################################### ENEMIES #####################################################
###################################################################################################
enum ENEMY_TYPE{
	FIGHTER,
	CAPITAL
}

var enemy_data = {
	'fighter': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'bomber': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'fighter2': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'bomber2': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'fighter3': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'bomber3': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'gunboat': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 2,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 1   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'frigate': {
		'hp': 120,    #the hitpoints
		'attack': 10, #the damage of the enemy
		'rof': 2,   #rate of fire
		'range': 400,#range that shoots
		'speed': 290,#speed it moves
		'not': 3,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'bfrigate': {    #Boarding frigate
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 3,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'destroyer': {
		'hp': 350,    #the hitpoints
		'attack': 25, #the damage of the enemy
		'rof': 6,   #rate of fire
		'range': 400,#range that shoots
		'speed': 150,#speed it moves
		'not': 6,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'cruiser': {
		'hp': 800,    #the hitpoints
		'attack': 15, #the damage of the enemy
		'rof': 8,   #rate of fire
		'range': 700,#range that shoots
		'speed': 115,#speed it moves
		'not': 5,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'battleship': {
		'hp': 1000,    #the hitpoints
		'attack': 50, #the damage of the enemy
		'rof': 10,   #rate of fire
		'range': 1000,#range that shoots
		'speed': 90,#speed it moves
		'not': 4,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'dreadnaught': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 4,    #number of turrets it has
		'craft': 0,  #number of fighters it launches
		'launch': 0, #launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	},
	'carrier': {
		'hp': 20,    #the hitpoints
		'attack': 5, #the damage of the enemy
		'rof': 50,   #rate of fire
		'range': 100,#range that shoots
		'speed': 200,#speed it moves
		'not': 1,    #number of turrets it has
		'craft': 5,  #number of fighters it launches
		'launch': 10,#launch frequency
		'class': 2   #Class 1 refers to a small spacecraft. Class 2 refers to capital ships.  
	}
}

###################################################################################################
##################################### ENCYCLOPEDIA ################################################
###################################################################################################
enum ENCYCLO_PEDIA{
	DORIA,   
	IONIA,  
	IW,   
	STROGG
}


var faction_details = {
	'doria': {
		'Homeworld': 'Doria',  
		'Population': "84.7B",
		'Government': "Militarised Republic",
		'Leader': "Efialtes",
		'Colonies': 8,     
		'Stations': 25 
	},
	'ionia': {
		'Homeworld': 'Ionia',  
		'Population': "211M",
		'Government': "Monarchy",
		'Leader': "Heron",
		'Colonies': 0,     
		'Stations': 2 
	},
	'iw': {
		'Homeworld': 'None',  
		'Population': "Unknown",
		'Government': "Anarchy",
		'Leader': "None",
		'Colonies': "80+",     
		'Stations': "128+" 
	},
	'strogg': {
		'Homeworld': 'Daemon',  
		'Population': "1000T+",
		'Government': "Hive-Collective",
		'Leader': "Strogg",
		'Colonies': "1000+",     
		'Stations': "Unknown" 
	}
	}
#if data.has('range'):
#		stats +=  "Range: " + str(data['range']) + " meters\n"
func formatted_descr(encyclo_pedia):
	var stats = ""
	var data = faction_details[encyclo_pedia]
	if data.has('Homeworld'):
		stats +=  "Homeworld: " + str(data['Homeworld']) + "\n"
	if data.has('Population'):
		stats += "Population: " + str(data['Population']) + " citizens\n"
	if data.has('Government'):
		stats += "Government: " + str(data['Government']) + "\n"
	if data.has('Leader'):
		stats += "Leader: " + str(data['Leader']) + "\n"
	if data.has('Colonies'):
		stats += "Colonies: " + str(data['Colonies']) + " planet(s)\n"
	if data.has('Stations'):
		stats += "Stations: " + str(data['Stations']) + "\n"
	return stats

var encyclopedia = {
	'doria': {
		'description': str("Introduction:
The Dorian League is a prominent interstellar faction originating from the mineral-rich planet of Doria, distinguished by its remarkable journey from a fragmented mining colony to a unified, formidable power within the galaxy. This wiki page delves deeper into the League's history, culture, governance, and recent developments. \n
Dorian leadership has invested a huge amount of resources in establishing a strong military presence, one that would prevent any potential uprising, and also inspire awe to its citizens. One of the latest achievement is the technological marvel of Achilleus. A capital class on its own, it combines the firepower of a Battleship, and
the troop deployment of a carrier.\n [img={300}]res://Assets/Player/BC.png[/img] \n It's hangars are able to house up to ten [url=a11roc]{A1-1:Roc}[/url] Fighter-Bombers. It also contains a manufacturing line that can replenish its destroyed fighters while deployed in the field. The advanced AI system is rendering pilot personell obsolete, thus human resources are reserved for ground missions. Furthermore
Achilleus is boasting a powerfull powercore, one that is able to sustain a plethora of weapons turrets with simultaneous fire.")
	},
	'ionia': {
		'description': str('This blast')
	},
	'iw': {
		'description': str("Doria is a planet that has engaged in conquests and conquered nearby planets and systems. However, the Mycenae after the disaster of project Troy, has been warped in unknown space. Those systems seem to not be following
		any specific centralised law. Anarchy is emminent throughout those systems. Factions have set up a system of city-states in which they constantly constest other settlements for resources, equipement, and slaves. Individual rights are not existent,
		and individuals are used in any way so that the status of that Faction is maintained or enhance. A truly barbaric state. The constant thirst for war, one would expect to have caused a limit to resources and research endeavours. On the contrary, while
		these factions prefer the flexibility of spacecraft, they have devised large vessels that can deploy an immense amount of fighters, and weapon platforms that can dish out an surprising amount of firepower. War is their business.")
	},
	'strogg': {      #Thise module requires different upgrade costs!!!!!
		'description': str('This drone')
	},
	'a11roc': {
		'description': str("Dorian Leadership commissionned the Ishukone corporation with the task of developing a spacecraft that would be able to deliver a message to their targets. The message was best described as: Annihilation. The A1-1 is a vessel that is capable of achieving
		an insane amount of G-Forces in it manouverability, thus only the best and borderline insane pilots can even dream of stepping inside the cockpit of this craft of death. The frame and armor of the Roc are capable of dealing with some of the harshes of space, but it will not survive long
		under fire. It purpose is primarily to outmanouver the enemy capital weaponry and perform a classic torpedo run, releasing its CX-125 Nova Torpedoes. With a total capacity of five torpedoes, no enemy station or ship could continue to pose a threat to the Dorian League.")
	}}

var wiki_entries = { #start
	'a11roc': {
		'description': str("This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description
		This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description 
		This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description 
		 This is the ships description This is the ships description This is the ships description This is the ships descriptionThis is the ships description This is the ships descriptionThis is the ships description
		 This is the ships description This is the ships description This is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships description
		This is the ships descriptionThis is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description")
	},
	
	'achilleus': {
		'description': str("This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description
		This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description 
		This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description 
		 This is the ships description This is the ships description This is the ships description This is the ships descriptionThis is the ships description This is the ships descriptionThis is the ships description
		 This is the ships description This is the ships description This is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships descriptionThis is the ships description
		This is the ships descriptionThis is the ships description This is the ships description This is the ships description This is the ships description This is the ships description This is the ships description")
	}
	} #end


enum wiki_items{
	a11roc,
	bob
}  

var wiki_item_details = {
	'a11roc': {
		'Code-Name': 'Roc',  
		'Production': "Ishucone",
		'Crew': "2",
		'Speed': 300,
		'Effective_Range': "1AU" 
	},
	'bob': {
		'Code-Name': 'Roc',  
		'Production': "Ishucone",
		'Crew': "2",
		'Speed': 300,
		'Effective_Range': "1AU" 
	}
	}
#if data.has('range'):
#		stats +=  "Range: " + str(data['range']) + " meters\n"
func formatted_wiki_item(wiki_items_id):
	var stats = ""
	var data = wiki_item_details[wiki_items_id]
	if data.has('Code-Name'):
		stats +=  "Code-Name: " + str(data['Code-Name']) + "\n"
	if data.has('Production'):
		stats += "Production: " + str(data['Production']) + " Corporation\n"
	if data.has('Crew'):
		stats += "Crew: " + str(data['Crew']) + " \n"
	if data.has('Speed'):
		stats += "Speed: " + str(data['Speed']) + "\n"
	if data.has('Effective_Range'):
		stats += "Effective Range: " + str(data['Effective_Range']) + "\n"
	if data.has('Stations'):
		stats += "Stations: " + str(data['Stations']) + "\n"
	return stats

################################################################################
############################## Dialogue-Box ####################################
################################################################################
var chapter_texts = {
	2: ["Captain of Achilleus, destroy any Ionian vessel on sight. Their navy is inferior to ours,
	and their weapons ancient. They are easy pickings.",
	"Easy enemies, they are not even trying!",
	"Enemy Cruiser is heading our way.",
	"This is a cakewalk"],
	
	3: ["Wave 1 is attacking.", "Wave 2 is engaging us.", "Wave 3 is approaching."],
	
	4: ["Another line for Chapter 3", "Second line for Chapter 3"],
	
	5: ["Another line for Chapter 4", "Second line for Chapter 4"]
	# ... (other chapters)
}
