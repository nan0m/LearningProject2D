shader_type canvas_item;

uniform float fade_start = 0.0; // The start of the fade, in texture space (0.0 to 1.0)
uniform float fade_end = 1.0; // The end of the fade, in texture space (0.0 to 1.0)

void fragment() {
    // Get the current texture color
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate the alpha based on the position using smoothstep
    float alpha = smoothstep(fade_start, fade_end, UV.x);
    
    // Apply the new alpha but keep the original RGB color
    COLOR.rgb = tex_color.rgb;
    COLOR.a = alpha * tex_color.a; // Multiply by tex_color.a to respect the original texture's transparency
}


//shader_type canvas_item;
//uniform float fade_start = 0.0; // The start of the fade, in texture space
//uniform float fade_end = 5; // The end of the fade, in texture space
//void fragment() {
//    float alpha = smoothstep(fade_start, fade_end, UV.x);
//    COLOR = texture(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, alpha);
//}
//float alpha = smoothstep(0.25 * UV_LIMIT.x, 0.5 * UV_LIMIT.x, UV.x);


//shader_type canvas_item;
//uniform float clip_x; // The x-coordinate to clip at
//void fragment() {
//    if (FRAGCOORD.x < clip_x) {
 //       COLOR = vec4(0.0, 0.0, 0.0, 0.0);
//    } else {
//        COLOR = texture(TEXTURE, UV);
//    }
//}