shader_type canvas_item;

const float zoom = 0.800;
const float tile = 0.850;
const float speed = 0.010;
// ... other constants ...

uniform float u_time : hint_range(0, 1) = 0.5;
uniform vec2 mouse = vec2(0.5, 0.5);
uniform vec2 resolution = vec2(1, 1);

void fragment() {
    vec2 uv = FRAGCOORD.xy / resolution.xy - 0.5;
    uv.y *= resolution.y / resolution.x;
    vec3 dir = vec3(uv * zoom, 1.0);
    float time = TIME * speed + 0.25;

    // ... [rest of your shader code, adapted as necessary] ...
    vec3 v = vec3(0.0);
    COLOR = vec4(v * 0.01, 1.0);
}