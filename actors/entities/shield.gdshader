shader_type canvas_item;

uniform vec2 hit_position = vec2(0.0, 0.0);  // Position of the hit
uniform float frequency = 10.0;  // Frequency of the ripple effect
uniform float amplitude = 0.5;  // Amplitude of the ripple effect

uniform vec4 shield_color = vec4(0.0, 0.5, 1.0, 0.5);  // Shield color
uniform float glow_strength = 1.0;  // Glow strength
uniform float hit_time;  // Time when the hit occurred
uniform float effect_duration = 1.0;  // Duration of the hit effect

void fragment() {
    float distance_from_hit = distance(hit_position, FRAGCOORD.xy);
    float ripple = sin(distance_from_hit * frequency - TIME) * amplitude;
    ripple = clamp(ripple, 0.0, 1.0);
    
    COLOR = vec4(1.0, 1.0, 1.0, ripple);  // White ripple effect with varying alpha
	
	vec2 uv = UV;
    vec3 glow = shield_color.rgb * glow_strength;

    // Calculate time since hit
    float time_since_hit = TIME - hit_time;

    // Check if within effect duration
    if (time_since_hit < effect_duration) {
        // Calculate distance to hit in UV space
        float distance_to_hit = distance(uv, hit_position);
        
        // Simple ripple effect
        float ripple_effect = sin(distance_to_hit * 20.0 - time_since_hit * 5.0);
        ripple_effect = clamp(ripple_effect, 0.0, 1.0);
        
        // Add ripple effect to glow
        glow += ripple_effect * vec3(1.0, 1.0, 1.0);
    }

    COLOR = vec4(glow, shield_color.a);
}


