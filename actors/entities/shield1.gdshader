shader_type spatial;
render_mode unshaded, cull_back;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float rimWidth : hint_range(1.0, 3.0) = 2.0;
uniform vec4 rimColor : source_color;
uniform vec4 outerRimColor : source_color;
uniform sampler2D normalMap : source_color;
uniform float normalStrength : hint_range(0.0, 1.0);
uniform vec2 normalTiling = vec2(1.0, 1.0);
uniform vec2 normalOffset = vec2(0.0, 0.0);
//uniform float beerFactor : hint_range(3.5, 10.0) = 6.0;
//uniform sampler2D imageTexture;

void fragment() {
    vec2 uvModifier = (texture(normalMap, (UV * normalTiling) + (normalOffset * TIME)).xy * normalStrength) - normalStrength * 0.5;
    vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV + uvModifier).rgb;
    float rim = 1.0 - abs(dot(VIEW, NORMAL));
    float outerRim = pow(rim, 4.0);
    rim = pow(rim, rimWidth);
    color = color + rim * rimColor.rgb;
    color = color + outerRim * outerRimColor.rgb;
    ALBEDO = color;
}