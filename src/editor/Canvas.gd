extends Sprite


const MAX_DISTANCE := 3.0
const UNDO_REDO_LIMIT := 32

var curr_mouse_position: Vector2
var prev_mouse_position: Vector2

var brush_type = BrushType.CIRCLE
var brush_size: float = 10
var brush_color: Color = Color.black

var canvas_scale := 1.0

var cursor_wet := false

var brush_buffer := []

var pre_image: Image
var post_image: Image
var undo_redo := BoundedUndoRedo.new(UNDO_REDO_LIMIT)
var last_edited_texture: Texture


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
	last_edited_texture = self.texture


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
		pre_image = self.texture.get_data()
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
		post_image = self.texture.get_data()
		commit_to_history()
		last_edited_texture = self.texture


func set_data_and_update_texture(image_data: Image, target_texture: Texture) -> void:
	target_texture.set_data(image_data)
	self.texture = target_texture


func commit_to_history() -> void:
	var action := Action.new(
		self,
		"set_data_and_update_texture",
		[pre_image, self.texture],
		[post_image, self.texture]
	)
	undo_redo.commit_action(action)


func undo() -> void:
	if cursor_wet:
		return
	var undo_successful := undo_redo.undo()
	if undo_successful:
		print("<<< undo")
	else:
		print("<<< nothing to undo")


func redo() -> void:
	if cursor_wet:
		return
	var redo_successful := undo_redo.redo()
	if redo_successful:
		print(">>> redo")
	else:
		print(">>> nothing to redo")


func on_mode_selected(index: int) -> void:
	self.texture = Editor.textures[index]


func on_scale_updated(s: float) -> void:
	canvas_scale = s
