shader_type canvas_item;

void fragment() {
	int green = int(texture(TEXTURE, UV).g * 255.0);
	int pigmentation_mode = green >> 7;
	COLOR.rgb = vec3(float(pigmentation_mode));
}