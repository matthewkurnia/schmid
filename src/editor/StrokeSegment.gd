extends Node2D


var brush_buffer: Array
var brush_type
var brush_size: float
var brush_color: Color


func _draw():
	for location in brush_buffer:
		match brush_type:
			BrushType.CIRCLE:
				draw_circle(location, brush_size, brush_color)
			BrushType.SQUARE:
				var extents := Vector2.ONE * brush_size
				draw_rect(Rect2(location - extents, 2 * extents), brush_color)
