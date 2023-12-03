shader_type canvas_item;
//#define USE_NORMAL_MAP

uniform vec4 shield_base_tint: source_color;
uniform float rim_inner: hint_range(0.0,1.0) = 0.1;

uniform float time_scale:hint_range(0.0,0.2) = 0.0;
uniform float distort_strength:hint_range(0.0,0.2) = 0.0;
uniform float distort_tiling:hint_range(0.0,10.0) = 0.0;
uniform vec2 distort_scroll_direction = vec2(1.0,1.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D distortion_texture;
uniform bool use_normal_map_instead = false;
uniform sampler2D hex_normals:repeat_enable;
uniform sampler2D rim_gradient;

float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}


void fragment() {
	vec3 distorted = vec3(0.0);
	if (!use_normal_map_instead){
	float n = texture(distortion_texture, mod(UV * distort_tiling + TIME * time_scale * distort_scroll_direction, 1.0)).r;
	distorted = texture(SCREEN_TEXTURE, mod(SCREEN_UV + distort_scroll_direction *(n * distort_strength - distort_strength / 2.0), 1.0)).rgb;
	}
	else {
	vec2 n = texture(hex_normals, mod(UV * distort_tiling + TIME * time_scale * normalize(distort_scroll_direction), 1.0)).rg;
	vec2 offset =  n * distort_scroll_direction * (distort_strength)  ;
	distorted = texture(SCREEN_TEXTURE, mod(SCREEN_UV + offset , 1.0)).rgb;
	}

	float new = smoothstep(rim_inner,0.5,length(UV - vec2(0.5)));
	float inside = new == 0.0 ? 1.0 : 0.0;
	float outside = new == 1.0 ? 1.0 : 0.0;
	vec4 rim_color = texture(rim_gradient,vec2(new, 0.0)).rgba;
	distorted = mix(distorted, shield_base_tint.rgb, shield_base_tint.a);
	COLOR.rgb = mix(distorted, rim_color.rgb, new) ;
	
	COLOR.a = (1.0 - outside) *  (  rim_color.a);
}


