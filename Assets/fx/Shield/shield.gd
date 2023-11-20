extends Node2D 

# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_player = $AnimationPlayer  # Adjust the path to your AnimationPlayer
	animation_player.play("spawn")
	animation_player.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))

# Called when the spawn animation is finished
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "spawn":
		queue_free()  # Remove the gate from the scene

