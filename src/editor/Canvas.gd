extends Sprite


const MAX_DISTANCE := 3.0

var curr_mouse_position: Vector2
var prev_mouse_position: Vector2

var brush_type = BrushType.CIRCLE
var brush_size: float = 10
var brush_color: Color = Color.black

var canvas_scale := 1.0

var cursor_wet := false

var stroke_group: Node2D

var brush_buffer := []


func _ready():
	var size := get_viewport().size
	# DEMO CODE BEGIN !!!
	var image = Image.new()
	image.create(size.x, size.y, false, Image.FORMAT_RGBAH)
	image.fill(Color.white)
	Editor.alignment_texture.create_from_image(image, 0);
	image.fill(Color.red)
	Editor.size_texture.create_from_image(image, 0);
	image.fill(Color.green)
	Editor.type_texture.create_from_image(image, 0);
	image.fill(Color.blue)
	Editor.distorsion_texture.create_from_image(image, 0);
	self.texture = Editor.alignment_texture
	# DEMO CODE END !!!


func _draw():
	for location in brush_buffer:
		match brush_type:
			BrushType.CIRCLE:
				draw_circle(location, brush_size, brush_color)
			BrushType.SQUARE:
				var extents := Vector2.ONE * brush_size
				draw_rect(Rect2(location - extents, 2 * extents), brush_color)


func _process(delta):
	if len(brush_buffer) == 0:
		return
	update()
	yield(VisualServer, "frame_post_draw")
	var drawn_image := get_viewport().get_texture().get_data()
	drawn_image.flip_y()
	self.texture.set_data(drawn_image)
	brush_buffer.clear()


func handle_input(event):
	prev_mouse_position = curr_mouse_position
	curr_mouse_position = get_global_mouse_position() / canvas_scale
	
	if event.is_action_pressed("paint") and not event.is_echo():
		cursor_wet = true
		stroke_group = Node2D.new()
		self.add_child(stroke_group)
		return
	
	if not cursor_wet:
		return
	
	var displacement := prev_mouse_position.distance_to(curr_mouse_position)
	var delta := curr_mouse_position - prev_mouse_position
	
	if cursor_wet and displacement > 0:
		var n := int(displacement / MAX_DISTANCE)
		if n > 0:
			var stride := 1 / float(n) * delta
			for i in range(1, n + 1):
				brush_buffer.append(prev_mouse_position + stride * i)
		brush_buffer.append(curr_mouse_position)
	
	if event.is_action_released("paint"):
		cursor_wet = false
		stroke_group.queue_free()


func on_mode_selected(index: int) -> void:
	self.texture = Editor.textures[index]


func on_scale_updated(s: float) -> void:
	canvas_scale = s
