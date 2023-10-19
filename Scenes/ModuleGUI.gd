extends CanvasLayer

signal update_module_UI(level)
signal update_moduleD_UI(level)
var max_timer = 0  #timer for the RG
var max_timer2 = 0 #timer for the Torp
var max_timer3 = 0 #timer for the DamageControl


func _ready():
	$HUD/AbilitiesBar/TorpedoCD.hide()
	$HUD/AbilitiesBar/RailgunCD.hide()
	$HUD/AbilitiesBar/DamageControl.hide()


func _on_update_module_ui(level,timeleftRG,timeleftTP):
	if level > 1:
		$HUD/AbilitiesBar/TorpedoCD.show()
		if max_timer2 == timeleftTP:
			$HUD/AbilitiesBar/TorpedoCD.value = max_timer2
		else:
			$HUD/AbilitiesBar/TorpedoCD.value = max_timer2 - timeleftTP
		$HUD/AbilitiesBar/TorpedoCD/TorpedoCDlabel.text = str(timeleftTP)
	if level > 2: 
		if max_timer == timeleftRG:
			$HUD/AbilitiesBar/RailgunCD.value = max_timer
		else:
			$HUD/AbilitiesBar/RailgunCD.value = max_timer - timeleftRG
		$HUD/AbilitiesBar/RailgunCD.show()
		$HUD/AbilitiesBar/RailgunCD/RailgunCDlabel.text = str(timeleftRG)

func _on_update_module_d_ui(level, timeleftDC):
	if level > 1:
		$HUD/AbilitiesBar/DamageControl.show()
		if max_timer3 == timeleftDC:
			$HUD/AbilitiesBar/DamageControl.value = max_timer3
		else:
			$HUD/AbilitiesBar/DamageControl.value = max_timer3 - timeleftDC
		$HUD/AbilitiesBar/DamageControl/DClabel.text = str(timeleftDC)
		


func set_max(seconds):
	max_timer = seconds
	$HUD/AbilitiesBar/RailgunCD.max_value = max_timer


func set_max2(seconds):
	max_timer2 = seconds
	$HUD/AbilitiesBar/TorpedoCD.max_value = max_timer2 

func set_max3(seconds):
	max_timer3 = seconds
	$HUD/AbilitiesBar/DamageControl.max_value = max_timer3 
