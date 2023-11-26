shader_type canvas_item;

uniform float time_offset = 0.0;  // Time offset for flicker variation

void fragment() {
    float flicker = abs(sin((TIME + time_offset) * 2.0)) * 0.5 + 0.5;

    vec4 tex_color = texture(TEXTURE, UV);
    vec4 brightened_color = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), flicker * 0.5);

    COLOR = brightened_color;
}