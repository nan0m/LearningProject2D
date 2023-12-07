shader_type canvas_item;

group_uniforms base;
uniform float inner_size_rim: hint_range(0.0,1.0) = 0.4;
uniform vec4 shield_base_tint: source_color = vec4(1.0,0.75, 0.33, 0.2);
uniform sampler2D rim_gradient;
uniform float shield_glow_overload: hint_range(1.0,10.0) = 1.0;

group_uniforms distortion;
uniform float time_scale:hint_range(0.0,0.2) = 0.05;
uniform float distort_strength:hint_range(0.0,0.2) = 0.01;
uniform float distort_tiling:hint_range(0.0,10.0) = 1.75;
uniform vec2 distort_scroll_direction = vec2(1.0,0.0);

group_uniforms dissolve;
uniform float dissolve_ratio: hint_range(0.0,1.0) = 0.0;
uniform sampler2D dissolve_texture;

group_uniforms distortion;

uniform sampler2D distortion_texture;
uniform bool use_normal_map_instead = false;
uniform sampler2D normal_distortion_tex:repeat_enable;


group_uniforms impacts;
uniform float impact_width: hint_range(0.01,0.9999) = 1;
uniform float impact_depth: hint_range(-0.5,0.5) = 0.06;
uniform vec4 impact_color: source_color;
uniform float impact_texture_tiling: hint_range(0.0,1000.0) = 7.0; 
uniform sampler2D impact_texture: repeat_enable;
uniform sampler2D impact_intensity_curve;
uniform float impact_glow_overload: hint_range(1.0,10.0) = 1.0;

group_uniforms set_by_script;
uniform sampler2D _impact_data_texture;
uniform ivec2 impact_texture_size;


uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

varying vec2 local_pos;

vec2 unpack_location(vec2 location){
	return (location - 0.5) * 65535.0;
}
vec2 unpack_dir_vec(vec2 color){
	return (color - 0.5) * 2.0;
}

float line(vec2 p1, vec2 p2, float width, vec2 uv)
{
	float dist = distance(p1, p2); // Distance between points
	float dist_uv = distance(p1, uv); // Distance from p1 to current pixel

	// If point is on line, according to dist, it should match current UV
	// Ideally the '0.001' should be SCREEN_PIXEL_SIZE.x, but we can't use that outside of the fragment function.
	return 1.0 - floor(1.0 - (0.001 * width) + distance (mix(p1, p2, clamp(dist_uv / dist, 0.0, 1.0)),  uv));
}

void vertex() {
//	local_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
	local_pos = VERTEX;
}


void fragment() {
// DISTORTION
	vec3 distorted = vec3(0.0);
	if (!use_normal_map_instead){
		float n = texture(distortion_texture, mod(UV * distort_tiling + TIME * time_scale * distort_scroll_direction, 1.0)).r;
		distorted = texture(SCREEN_TEXTURE, mod(SCREEN_UV + distort_scroll_direction *(n * distort_strength - distort_strength / 2.0), 1.0)).rgb;
	}
	else {
		vec2 n = texture(normal_distortion_tex, mod(UV * distort_tiling + TIME * time_scale * normalize(distort_scroll_direction), 1.0)).rg;
		vec2 offset =  n * distort_scroll_direction * (distort_strength)  ;
		distorted = texture(SCREEN_TEXTURE, mod(SCREEN_UV + offset , 1.0)).rgb;
	}

// BASE
	float rim_mask = smoothstep(inner_size_rim,0.5,length(UV - vec2(0.5)));
//	float inside = rim_mask == 0.0 ? 1.0 : 0.0;
	float outside = rim_mask == 1.0 ? 1.0 : 0.0;
	vec4 rim_color = texture(rim_gradient,vec2(rim_mask, 0.0)).rgba;
	distorted = mix(distorted, shield_base_tint.rgb, shield_base_tint.a);
	COLOR.rgb = mix(distorted, rim_color.rgb * shield_glow_overload, rim_mask);

	float dissolve_mask = texture(dissolve_texture,UV).r;
	COLOR.a = (1.0 - outside) *  (  rim_color.a) * step(dissolve_ratio, dissolve_mask);


	float impact_tex = texture(normal_distortion_tex, UV * impact_texture_tiling).b;
	


//IMPACTS
	for (int i = 0; i < impact_texture_size.y; i++) {
		vec3 data = texelFetch(_impact_data_texture, ivec2(0,i),0).rgb;
//		vec2 location = unpack_location(data.rg);
		vec2 impact_dir = normalize(unpack_dir_vec(data.rg) );
		float lifetime_elapsed = data.b;
		float intensity = texture(impact_intensity_curve,vec2(lifetime_elapsed,0.0)).r;
		float edge = smoothstep(inner_size_rim - impact_depth,0.5,length(UV - vec2(0.5)));
//		float dot_to_impact = clamp((dot(normalize(- local_pos +location), normalize(UV - 0.5)) ), 0.0,1.0);
//		dot_to_impact = pow(dot_to_impact, (1.0 - impact_width) * 400.0);
		

		vec2 dir = normalize(UV - vec2(0.5));
		float alignment = dot(impact_dir, dir);
		float impact_line = step(impact_width , alignment);
		COLOR.rgb = mix(COLOR.rgb, impact_color.rgb * impact_glow_overload,impact_line * edge * impact_color.a  *impact_tex *intensity ); //

	}

}


