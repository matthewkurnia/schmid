shader_type canvas_item;

uniform bool debug_view = false;

uniform float screen_height: hint_range(0.0, 2000.0, 1.0) = 600.0;
uniform float screen_width: hint_range(0.0, 2000.0, 1.0) = 1024.0;

uniform float canvas_roughness;
uniform sampler2D canvas_texture;

uniform float pigmentation: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float smudge_amount: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float distorsion_amount: hint_range(0.0, 0.01, 0.0001) = 0.004;
uniform float minimum_distorsion_multiplier: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform int respawn_blend_frames: hint_range(2, 200, 1) = 4;

uniform sampler2D source;
uniform sampler2D depth_motion;
uniform sampler2D config_buffer;
uniform sampler2D debug_stroke;

// stroke textures
uniform sampler2DArray stroke_types;

const float PI = 3.14159;
const float STROKE_BIAS[] = {0.3};

float grainify(float x, float a) {
	x -= 0.5;
	a -= 0.5;
	return max(min(canvas_roughness * (x + a) + 0.5, 1.0), 0.0);
}

vec3 hue_jitter(vec3 c) {
	return vec3(0);
}

void fragment() {
	// Get values from particle shader
	vec2 normalized_position = COLOR.xy;
	float angle = fract(COLOR.z);
	float rand_f = floor(COLOR.z) / 256.0;
	float packed_alpha_scale = COLOR.w;
	
	// Unpack alpha and scale
	float f_respawn_blend_frames = float(respawn_blend_frames);
	float stride = 1.0 / f_respawn_blend_frames;
	float alpha = floor(packed_alpha_scale * f_respawn_blend_frames) / float(respawn_blend_frames - 1);
	float scale = mod(packed_alpha_scale, stride) * f_respawn_blend_frames;
	
	// Convert normalized position to UV
	vec2 uv = vec2(0, 1) + normalized_position * vec2(1, -1);
	
	// Depth
	float depth = texture(depth_motion, normalized_position).z;
	float distorsion_multiplier = (1.0 - depth) * (1.0 - minimum_distorsion_multiplier) + minimum_distorsion_multiplier;
	
	// Sample from source
	vec3 source_color = texture(source, SCREEN_UV + distorsion_amount * distorsion_multiplier * vec2(cos(2.0 * PI * angle), sin(2.0 * PI * angle))).rgb;
	
	// Sample from source with opaque stroke
	float stroke_size = 256.0 / screen_height;
	mat2 rotation;
	rotation[0] = vec2(cos(-angle), -sin(-angle));
	rotation[1] = vec2(sin(-angle), cos(-angle));
	float ratio = screen_height / screen_width;
	vec3 pigment_color;
	vec3 upper_color = texture(
		source,
		uv + rotation * vec2(0.0, 0.5 * STROKE_BIAS[0]) * vec2(ratio, 1.0) * scale * stroke_size
	).rgb;
	vec3 lower_color = texture(
		source,
		uv + rotation * vec2(0.0, -0.5 * STROKE_BIAS[0]) * vec2(ratio, 1.0) * scale * stroke_size
	).rgb;
	vec3 core_color = texture(source, uv).rgb;
	if (UV.y <= 0.5) {
		pigment_color = mix(upper_color, core_color, UV.y * 2.0);
	} else {
		pigment_color = mix(core_color, lower_color, (UV.y - 0.5) * 2.0);
	}
	pigment_color = mix(pigment_color, core_color, (1.0 - smudge_amount));
	
	// Unpack stroke config
	vec3 stroke_config = texture(config_buffer, normalized_position).rgb;
	int green = int(stroke_config.g * 255.0);
	int pigmentation_mode = green >> 7;
	int brush_type = (green >> 4) & 7;
	
	// Combine the two samples
	COLOR.rgb = mix(source_color, pigment_color, float(pigmentation_mode));
	
	// Handle alpha
	int index = brush_type * 4 + (int(rand_f * 4.0) % 4);
	COLOR.a = texture(stroke_types, vec3(UV.x, UV.y, float(index))).a;
	COLOR.a = grainify(texture(canvas_texture, SCREEN_UV).x, COLOR.a);
	
	if (debug_view) {
//		COLOR.a = alpha * texture(debug_stroke, UV).a;
		COLOR.rgb = vec3(normalized_position, packed_alpha_scale);
//		COLOR.rgb = texture(buffered, SCREEN_UV).rgb;
	}
}
