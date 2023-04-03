shader_type canvas_item;
render_mode blend_mul;

uniform float canvas_depth: hint_range(0.0, 1.0, 0.05) = 0.5;
uniform vec4 tint: hint_color;

void fragment() {
	float depth = texture(TEXTURE, UV).x;
	depth = (1.0 - depth) * canvas_depth;
	COLOR = mix(vec4(1), tint, depth);
}
