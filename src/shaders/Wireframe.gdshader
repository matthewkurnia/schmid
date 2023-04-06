shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 wire_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float wire_width: hint_range(0.0, 40.0) = 5.0;
uniform float wire_smoothness: hint_range(0.0, 0.1) = 0.01;

uniform float capture_size = 1;
uniform vec3 unwrap_location = vec3(0, 0, 0);
uniform float unwrap_scale = 1.0;

varying vec3 barys;

void vertex() {
	int index = VERTEX_ID % 3;
	switch (index) {
		case 0:
			barys = vec3(1.0, 0.0, 0.0);
			break;
		case 1:
			barys = vec3(0.0, 1.0, 0.0);
			break;
		case 2:
			barys = vec3(0.0, 0.0, 1.0);
			break;
	}
	
	vec2 step1 = (UV - 0.5) * capture_size;
	vec3 step2 = vec3(step1.x, step1.y, 0);
	vec3 step3 = step2 + unwrap_location; 
	vec3 final_position = step3 * unwrap_scale;
	VERTEX = final_position;
}

void fragment() {
	vec3 deltas = fwidth(barys);
	vec3 barys_s = smoothstep(deltas * wire_width - wire_smoothness, deltas * wire_width + wire_smoothness, barys);
	float wires = min(barys_s.x, min(barys_s.y, barys_s.z));
	ALBEDO = wire_color.rgb;
	ALPHA = mix(1, 0, wires);
}