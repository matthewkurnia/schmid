extends Node


enum {
	SQUARE,
	CIRCLE,
	AIRBRUSH
}


func get_color(i: int) -> Color:
	var r: float = i & 1
	var g: float = (i >> 1) & 1
	var b: float = (i >> 2) & 1
	return Color(r, g, b)
