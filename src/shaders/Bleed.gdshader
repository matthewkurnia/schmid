shader_type canvas_item;


// constants

const float PI = 3.14159265358979323846;

const vec2 B0 = vec2(0.0, 0.0);
const vec2 B1 = vec2(0.5, 0.0);
const vec2 B2 = vec2(0.5, 1.0);
const vec2 B3 = vec2(1.0, 1.0);


// uniforms

// blur
uniform int buffer_width: hint_range(5, 1000, 1) = 7;
uniform float screen_width = 1024;
uniform float screen_height = 600;

// value grouping
uniform float shadow_threshold: hint_range(0.0, 1.0) = 0.2;
uniform float shadow_fade_distance: hint_range(0.0, 0.2) = 0.05;
uniform float shadow_lod: hint_range(0.0, 10.0, 0.5) = 4.0;
uniform float shadow_cutoff: hint_range(0.0, 1.0) = 0.2;
uniform vec4 shadow_fringe_bias: hint_color;
uniform float shadow_fringe_amount: hint_range(0.0, 1.0) = 0.5;

// watercolor effects
uniform bool watercolor_mode = true;
uniform bool value_based_bleed = true;
uniform float bleed_amount: hint_range(0.0, 10.0, 0.1) = 3.0;

// distorsion
uniform sampler2D noise;
uniform sampler2D config_buffer;
uniform float max_distorsion: hint_range(0.0, 0.1, 0.0001) = 0.05;
uniform float min_distorsion: hint_range(0.0, 0.1, 0.0001) = 0.05;


float trig_interpolate(float x, float a, float b) {
	if (x <= a) return 0.0;
	if (x >= b) return 1.0;
	return 0.5 + 0.5 * cos(PI * x / (b - a) + (1.0 - a / (b - a)) * PI);
}

vec2 bezier_interpolate(vec2 q0, vec2 q1, vec2 q2, vec2 q3, float t) {
	q0 = mix(q0, q1, t);
	q1 = mix(q1, q2, t);
	q2 = mix(q2, q3, t);
	q0 = mix(q0, q1, t);
	q1 = mix(q1, q2, t);
	q0 = mix(q0, q1, t);
	return q0;
}

float sat(vec3 c) {
	return max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
}

vec3 set_sat(vec3 c, float s) {
	float channels[3] = {c.r, c.g, c.b};
	int i = 0;
	int j = 1;
	int k = 2;
	// choose i, j, k such that [channels[i], channels[j], channels[k]] is sorted
	if (channels[i] > channels[j]) {
		i = i ^ j;
		j = i ^ j;
		i = i ^ j;
	}
	if (channels[i] > channels[k]) {
		i = i ^ k;
		k = i ^ k;
		i = i ^ k;
	}
	if (channels[j] > channels[k]) {
		j = j ^ k;
		k = j ^ k;
		j = j ^ k;
	}
	if (channels[k] > channels[i]) {
		channels[j] = (((channels[j] - channels[i]) * s) / (channels[k] - channels[i]));
		channels[k] = s;
	} else {
		channels[j] = 0.0;
		channels[k] = 0.0;
	}
	channels[i] = 0.0;
//	return c;
	return vec3(channels[0], channels[1], channels[2]);
}

float lum(vec3 c) {
	return 0.3 * c.r + 0.59 * c.g + 0.11 * c.b;
}

vec3 clip_color(vec3 c) {
	vec3 _c = c;
	float l = lum(_c);
	float n = min(_c.r, min(_c.g, _c.b));
	float x = max(_c.r, max(_c.g, _c.b));
	if (n < 0.0) {
		_c.r = l + (((_c.r - l) * l) / (l - n));
		_c.g = l + (((_c.g - l) * l) / (l - n));
		_c.b = l + (((_c.b - l) * l) / (l - n));
	}
	if (x > 1.0) {
		_c.r = l + (((_c.r - l) * (1.0 - l)) / (l - n));
		_c.g = l + (((_c.g - l) * (1.0 - l)) / (l - n));
		_c.b = l + (((_c.b - l) * (1.0 - l)) / (l - n));
	}
	return _c;
}

vec3 set_lum(vec3 c, float l) {
	float d = l - lum(c);
	return clip_color(c + vec3(d));
}


void fragment() {
	vec2 offset = texture(noise, UV).xy;
	offset = 2.0 * offset - vec2(1);
	vec2 uv = vec2(0, 1) + UV * vec2(1, -1);
	vec3 stroke_config = texture(config_buffer, UV).rgb;
	float distorsion = float(int(stroke_config.g * 255.0) & 15) / 15.0;
	float distorsion_amount = mix(min_distorsion, max_distorsion, distorsion);
	vec2 uv_with_offset = uv + distorsion_amount * offset;
	
	// value grouping
	vec4 raw_color = texture(SCREEN_TEXTURE, uv_with_offset);
	float raw_value = lum(raw_color.rgb);
	float shadow = 1.0 - trig_interpolate(
		raw_value,
		shadow_threshold - shadow_fade_distance,
		shadow_threshold + shadow_fade_distance
	);
	
	vec2 uv_with_bleed = watercolor_mode ? SCREEN_UV + offset * 0.005 : uv_with_offset;
	vec3 blurred_color = textureLod(SCREEN_TEXTURE, uv_with_offset, bleed_amount * raw_value).rgb;
	
	COLOR.rgb = mix(raw_color.rgb, blurred_color * shadow_fringe_bias.rgb, shadow);
}