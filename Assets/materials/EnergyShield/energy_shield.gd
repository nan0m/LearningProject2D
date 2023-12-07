@icon("shield_icon.png")
extends Sprite2D
class_name EnergyShield
## You use this node by calling the add_impact function and giving it the total lifetime of the impact in secondes
## as well as the location in global coordinates of the impact.
##
## The node then keeps track of the current_impacts in an array, meaning the original node that called the add_impact function e.g. your bullet or laser node
## can safely be destroyed as the shield handles the interaction from now on. [br]
## The shield node is part of the process loop and updates the lifetime of all impacts each frame.[br]
## If there are any impacts it creates a texture each frame and feeds it to the shader material[br]
## It also manually tells the shader material the size of the texture.[br]
## Both of these parameters are set under the material group " Set By Script" and are not meant for manual editing.


const _max_16bit_uint: = 65535

class Impact:
	var location := Vector2.ZERO
	var total_lifetime: float = 1.0
	var elapsed_lifetime:float = 0.0
	#	var color := Color.NAVAJO_WHITE
	
var _current_impacts: Array[Impact] = []
## if this is set to true, the impacts pause their processing, you can use this for debugging purposes.
@export var pause_shield: bool = false

## Call this method to add an impact effect at that global position
func add_impact(global_pos: Vector2, total_lifetime: float):
	var im := Impact.new()
	im.location = (global_pos - self.global_position).normalized()
	im.total_lifetime = total_lifetime
	_current_impacts.append(im)

	
	
	
### PRIVATE ####

func _ready():
	pass
	#you can add impacts here for testing.
#	add_impact(Vector2(10,10),100.0)
#	add_impact(Vector2(100,100),10.0)
	add_impact(Vector2(0,-2000),15.0)
#	add_impact(Vector2(800,0),40.0)
#	add_impact(Vector2(600,1230),20.0)


func _process(delta):
	_update_texture(delta)

func _update_texture(delta: float):
	#update seconds how long impact has been alive.
	for impact in _current_impacts:
		if pause_shield: return
		impact.elapsed_lifetime += delta 
		if impact.elapsed_lifetime >= impact.total_lifetime:
			_current_impacts.erase(impact)
	
	#tell shader to not loop over texture if no impacts.
	if _current_impacts.size() <= 0: 
		self.material.set_shader_parameter("impact_texture_size", Vector2(0, 0))
	#create texture containing impact data, and tell texture size to shader
	else:
		var tmp_img = Image.create(1,_current_impacts.size(),false,Image.FORMAT_RGBH) #FORMAT_RGB8 #32,767.

		for i in _current_impacts.size():
			var impact: Impact = _current_impacts[i]
#			var normalized_direction: Vector2 = (impact.location - self.global_position).normalized()
#			var pos_elapsed =  _pack_position_to_color(impact.location)
			var pos_elapsed =  _pack_direction_vec_to_color(impact.location)
			pos_elapsed.b = impact.elapsed_lifetime / impact.total_lifetime
			tmp_img.set_pixel(0, i, pos_elapsed)
			
		var impact_tex = ImageTexture.create_from_image(tmp_img)
		self.material.set_shader_parameter("impact_texture_size", Vector2(1, _current_impacts.size()))
		self.material.set_shader_parameter("_impact_data_texture",impact_tex)

## transform position value into 0 -> 1 range for storing in texture.
func _pack_position_to_color(global_pos: Vector2) -> Color:
	var col := Color()
	col.r = (global_pos.x / _max_16bit_uint) + 0.5
	col.g = (global_pos.y  / _max_16bit_uint) + 0.5
	return col

func _pack_direction_vec_to_color(direction: Vector2) -> Color:
	var col := Color()
	col.r = (direction.x / 2.0) + 0.5
	col.g = (direction.y  / 2.0) + 0.5
	return col

