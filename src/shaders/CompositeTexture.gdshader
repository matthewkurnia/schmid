shader_type canvas_item;

const float PI = 3.14159;

uniform sampler2D alignment_texture;
uniform sampler2D size_texture;
uniform sampler2D type_texture;
uniform sampler2D distorsion_texture;

uniform int pigmentation_mode;
uniform int alignment_mode;

void fragment() {
	vec2 alignment = normalize(texture(alignment_texture, UV).xy - vec2(0.5));
	float angle = fract(atan(alignment.y, alignment.x) / (2.0 * PI));
	
	int pm = pigmentation_mode << 7;
	
	vec3 encoded_type = texture(type_texture, UV).rgb;
	int type = int(encoded_type.r) + (int(encoded_type.g) << 1) + (int(encoded_type.b) << 2);
	type = type << 4;
	
	int distorsion = int(round(texture(distorsion_texture, UV).x * 15.0));
	
	int am = alignment_mode << 6;
	
	int size = int(round(texture(size_texture, UV).x * 63.0));
	
	COLOR.r = angle;
	COLOR.g = float(pm + type + distorsion + 1) / 255.0;
	COLOR.b = float(am + size + 1) / 255.0;
}