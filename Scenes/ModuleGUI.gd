extends CanvasLayer

signal update_module_UI(level)
signal update_moduleD_UI(level)
var max_timer = 0  #timer for the RG
var max_timer2 = 0 #timer for the Torp
var max_timer3 = 0 #timer for the DamageControl
var max_timer4 = 0 #timer for the Ally-Spawner
var max_timer5 = 0 #timer for the Shield
#var player = null
@onready var player = get_parent().get_node("Sort/Player_New")

func _ready():
	$HUD/AbilitiesBar/TorpedoCD.hide()
	$HUD/AbilitiesBar/RailgunCD.hide()
	$HUD/AbilitiesBar/DamageControl.hide()
	$HUD/AbilitiesBar/Ally.hide()
	$HUD/AbilitiesBar/Shield.hide()
	#$HUD/CheckButton.hide() #this needs to appear when the Dronebay is built. 
	ManagerGame.gold_changed.connect(Callable(self, "_on_gold_changed"))
	#player = get_parent().get_node("Sort/Player_New")
	player.connect("health_changed", Callable(self, "_on_health_changed"))
	player.connect("player_hit", Callable(self, "_on_player_hit"))
	$Resources.text = "RU: " + str(ManagerGame.global_player_ref.player_data['gold'])
	$PLayerHP.max_value = player.player_data['stats']['hp']
	$PLayerHP.value = player.player_data['stats']['hp']

func _process(delta):
	update_player_hp()

func update_player_hp():
	if player != null:  # Check if the player node is valid
		var current_hp = player.player_data['stats']['hp']
		$PLayerHP.value = current_hp
		$PLayerHP/Label.text = str(int(current_hp))

func _on_gold_changed():
	$Resources.text = "RU: " + str(ManagerGame.global_player_ref.player_data['gold'])

func _on_health_changed(new_health):
	# Update HP bar here
	$PLayerHP.value = new_health
	$PLayerHP/Label.text = str(int(new_health))

func _on_update_module_ui(level,timeleftRG,timeleftTP):
	if level > 1:
		$HUD/AbilitiesBar/TorpedoCD.show()
		if max_timer2 == timeleftTP:
			$HUD/AbilitiesBar/TorpedoCD.value = max_timer2
			player.get_node("MissileIndicatorRed").hide()
		else:
			$HUD/AbilitiesBar/TorpedoCD.value = max_timer2 - timeleftTP
			player.get_node("MissileIndicatorRed").show()
		$HUD/AbilitiesBar/TorpedoCD/TorpedoCDlabel.text = str(timeleftTP)
		
	if level > 2: 
		if max_timer == timeleftRG:
			$HUD/AbilitiesBar/RailgunCD.value = max_timer
		else:
			$HUD/AbilitiesBar/RailgunCD.value = max_timer - timeleftRG
		$HUD/AbilitiesBar/RailgunCD.show()
		$HUD/AbilitiesBar/RailgunCD/RailgunCDlabel.text = str(timeleftRG)

func _on_update_module_d_ui(level, timeleftDC, timeleftALLY, timeleftSD):
	if level > 1:
		$HUD/AbilitiesBar/DamageControl.show()
		if max_timer3 == timeleftDC:
			$HUD/AbilitiesBar/DamageControl.value = max_timer3
		else:
			$HUD/AbilitiesBar/DamageControl.value = max_timer3 - timeleftDC
		$HUD/AbilitiesBar/DamageControl/DClabel.text = str(timeleftDC)
	if level > 3:
		$HUD/AbilitiesBar/Ally.show()
		if max_timer4 == timeleftALLY:
			$HUD/AbilitiesBar/Ally.value = max_timer4
		else:
			$HUD/AbilitiesBar/Ally.value = max_timer4 - timeleftALLY
		$HUD/AbilitiesBar/Ally/AllyCDlabel.text = str(timeleftALLY)
	if level > 5:
		$HUD/AbilitiesBar/Shield.show()
		if max_timer5 == timeleftSD:
			$HUD/AbilitiesBar/Shield.value = max_timer5
		else:
			$HUD/AbilitiesBar/Shield.value = max_timer5 - timeleftSD
		$HUD/AbilitiesBar/Shield/ShieldCDlabel.text = str(timeleftSD)

func set_max(seconds):
	max_timer = seconds
	$HUD/AbilitiesBar/RailgunCD.max_value = max_timer

func set_max2(seconds):
	max_timer2 = seconds
	$HUD/AbilitiesBar/TorpedoCD.max_value = max_timer2 

func set_max3(seconds):
	max_timer3 = seconds
	$HUD/AbilitiesBar/DamageControl.max_value = max_timer3 

func set_max4(seconds):
	max_timer4 = seconds
	$HUD/AbilitiesBar/Ally.max_value = max_timer4 

func set_max5(seconds):
	max_timer5 = seconds
	$HUD/AbilitiesBar/Shield.max_value = max_timer5 
