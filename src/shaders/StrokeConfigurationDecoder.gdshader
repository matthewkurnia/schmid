shader_type spatial;
render_mode unshaded;

const float PI = 3.14159;
const int AM_RANDOM = 0;
const int AM_ENCODED = 1;
const int AM_TANGENTIAL = 2;

uniform sampler2D configuration_texture;

void fragment() {
	vec3 config = texture(configuration_texture, UV).rgb;
	
	int blue = int(config.b * 255.0);
	int alignment_mode = blue >> 6;
	
	if (alignment_mode == AM_ENCODED) {
		float normalized_encoded_angle = config.r;
		vec3 world_space_stroke_direction = cos(normalized_encoded_angle * 2.0 * PI) * TANGENT + sin(normalized_encoded_angle * 2.0 * PI) * BINORMAL;
		vec2 view_space_stroke_direction = normalize((PROJECTION_MATRIX * vec4(world_space_stroke_direction, 0)).xy * VIEWPORT_SIZE);
		float angle_normalized = fract(atan(view_space_stroke_direction.y, view_space_stroke_direction.x) / (2.0 * PI));
		ALBEDO.r = angle_normalized;
	}
	
	if (alignment_mode == AM_TANGENTIAL) {
		vec2 view_space_normal = normalize((PROJECTION_MATRIX * vec4(NORMAL, 0)).xy * VIEWPORT_SIZE);
		mat2 tangent_matrix;
		tangent_matrix[0] = vec2(0, -1);
		tangent_matrix[1] = vec2(1, 0);
		vec2 view_space_tangent = tangent_matrix * view_space_normal;
		float angle_normalized = fract(atan(view_space_tangent.y, view_space_tangent.x) / (2.0 * PI));
		ALBEDO.r = angle_normalized;
	}
	
	ALBEDO.gb = config.gb;
}