shader_type canvas_item;

void fragment() {
	int blue = int(texture(TEXTURE, UV).b * 255.0);
	blue = blue & 63;
	float size = float(blue) / 63.0;
	COLOR.rgb = vec3(size);
}