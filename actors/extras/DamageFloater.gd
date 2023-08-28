extends Node2D


# this node is simply just the number that would float when we hit an enemy
# to indicate the damage we dealth with each different bullet


var orig_pos # we need to provid an initial position so we can use that in tweening

func _ready():
	global_position = orig_pos
	
	var t = create_tween()
	t.tween_property(self, 'global_position:y', orig_pos.y - 64, .4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await t.finished

	queue_free()
