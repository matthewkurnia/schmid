shader_type canvas_item;

const vec3 TO_COLOR[] = {
	vec3(1, 0, 0),
	vec3(0, 1, 0),
	vec3(0, 0, 1)
};

void fragment() {
	int blue = int(texture(TEXTURE, UV).b * 255.0);
	int alignment_mode = blue >> 6;
	COLOR.rgb = TO_COLOR[alignment_mode];
}