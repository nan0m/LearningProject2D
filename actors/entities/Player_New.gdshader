shader_type canvas_item;

uniform sampler2D dissolve_texture; // No more type hints like : hint_albedo
uniform float dissolve_value : hint_range(0, 1);

void fragment() {
    vec4 main_texture = texture(TEXTURE, UV);
    vec4 noise_texture = texture(dissolve_texture, UV);
    main_texture.a *= floor(dissolve_value + min(1.0, noise_texture.r)); // Changed noise_texture.x to noise_texture.r
    COLOR = main_texture;
}