extends Node2D

#I have copied the script from the DamageFloater. However, the difference is that this appears
#and goes away when the torpedo has found it's target or the target is destroyed (which ever is 1st).

#This will be called when the enemy is Left-Clicked. Right click is the opposite.
var orig_pos # we need to provid an initial position so we can use that in tweening

#func _ready():
#	var t = create_tween()
#	t.tween_property(self, 'global_position:y', orig_pos, 10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#	await t.finished
#	queue_free()
