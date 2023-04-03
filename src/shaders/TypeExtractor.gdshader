shader_type canvas_item;

void fragment() {
	int green = int(texture(TEXTURE, UV).g * 255.0);
	int type = (green >> 4) & 7;
	COLOR.r = float(type & 1);
	COLOR.g = float((type >> 1) & 1);
	COLOR.b = float((type >> 2) & 1);
}