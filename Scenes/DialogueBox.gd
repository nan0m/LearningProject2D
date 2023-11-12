extends ColorRect

@export var dialoguePath = ""
@export var textSpeed: float = 0.05
var dialog

func _ready():
	$Timer.wait_time = textSpeed


