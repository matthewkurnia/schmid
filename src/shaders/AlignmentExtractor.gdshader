shader_type canvas_item;

const float PI = 3.14159;

void fragment() {
	float angle = texture(TEXTURE, UV).r * (2.0 * PI);
	COLOR.r = 0.5 + 0.5 * cos(angle);
	COLOR.g = 0.5 + 0.5 * sin(angle);
	COLOR.b = 0.0;
}