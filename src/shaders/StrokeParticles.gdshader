shader_type particles;
render_mode keep_data;

uniform int respawn_blend_frames: hint_range(2, 32, 1) = 4;
uniform float velocity_cutoff: hint_range(0.0, 1.0) = 0.2;
uniform float anti_clump_velocity: hint_range(0.0, 1.0) = 0.01;
uniform int amount;
uniform float scale = 1.0;
uniform float scale_random_amount;
uniform vec3 emission_box_extents;
uniform float max_displacement_alowed = 80.0;

uniform sampler2D source;
uniform sampler2D depth_motion;
uniform sampler2D buffered;
uniform sampler2D raw_position_data;

const float PI = 3.14159;
const float EPSILON = 0.1;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}


// CUSTOM.x === angle of particle
// CUSTOM.y === current_transparency
// CUSTOM.z === target_transparency
// CUSTOM.w === 0.0 for uninitialized particle, 1.0 otherwise
// COLOR.r === normalized_position.x
// COLOR.g === normalized_position.y
// COLOR.b === angle (in radians)
// COLOR.a === scale
void vertex() {
	uint alt_seed = hash(uint(INDEX) + RANDOM_SEED);
	
	vec2 normalized_position = texelFetch(raw_position_data, ivec2(INDEX, 0), 0).xy;
	vec2 initial_position = (normalized_position - vec2(0.5)) * 2.0 * vec2(emission_box_extents.x, emission_box_extents.y);
	float depth = texture(depth_motion, normalized_position).z;
	
	normalized_position = (TRANSFORM[3].xy / emission_box_extents.xy) * 0.5 + 0.5;
	
	CUSTOM.x = rand_from_seed(alt_seed) * 2.0 * PI;
	// DEMO CODE START!!!
	vec3 brush_buffer = texture(buffered, normalized_position).rgb;
	CUSTOM.x = brush_buffer.x * 2.0 * PI;
	// DEMO CODE END!!!
	
	// set the transform
	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1]= vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	
	float base_scale = scale;
	TRANSFORM[0].xyz *= base_scale;
	TRANSFORM[1].xyz *= base_scale;
	TRANSFORM[2].xyz *= base_scale;
	
	// To preserve precision, the motion vector is mulltiplied by 64.
	// When decoding, we now multiply by 0.015625 (1/64) to reduce it to the correct size.
	vec2 stroke_velocity = (texture(depth_motion, normalized_position).xy - vec2(0.5))
			* 0.015625 * 2.0 * emission_box_extents.xy * vec2(1.0, -1.0);
	if (length(stroke_velocity) < velocity_cutoff) {
		stroke_velocity = vec2(0);
	}
	vec2 previous_position = TRANSFORM[3].xy;
	TRANSFORM[3].xy += stroke_velocity;
	float displacement = length(TRANSFORM[3].xy - initial_position);
	
	// initializes the stroke
	if (CUSTOM.w <= 0.5 && CUSTOM.y <= 0.0) {
		TRANSFORM[3] = vec4(initial_position, 1.0, 0.0);
		CUSTOM.w = 1.0;
	}
	
	// Moving the strokes back to initial position after enough displacement to
	// keep stroke distribution consistent.
	if (displacement > max_displacement_alowed * (0.5 + 0.5 * rand_from_seed(alt_seed))) {
		CUSTOM.w = 0.0;
	}
	// Resetting strokes that has velocity below a certain threshold so that
	// strokes does not get stuck in one place.
	if (length(stroke_velocity) < anti_clump_velocity && displacement > EPSILON) {
		CUSTOM.w -= 0.005 * (1.0 + rand_from_seed(alt_seed));
	}
	// Controlling overall lifetime of stroke.
	if (displacement > 10.0) {
//		CUSTOM.w -= 0.005 * (1.0 + rand_from_seed(alt_seed));
	}
	
	// Control smooth alpha
	float delta = 1.0 / float(respawn_blend_frames - 1);
	if (CUSTOM.w <= 0.5) {
		CUSTOM.y = max(CUSTOM.y - delta, 0.0);
	} else {
		CUSTOM.y = min(CUSTOM.y + delta, 1.0);
	}
	
	// Pack scale and alpha
	float stride = 1.0 / float(respawn_blend_frames);
	float packed_scale = scale * stride;
	float packed_alpha = CUSTOM.y / delta * stride;
	
	COLOR = vec4(
		normalized_position.x,
		normalized_position.y,
		CUSTOM.x,
		packed_alpha + packed_scale
	);
}
