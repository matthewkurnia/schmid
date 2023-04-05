extends Sprite


const MAX_DISTANCE := 3.0
const UNDO_REDO_LIMIT := 32
const ALIGNMENT_SMOOTHING := 5

export var airbrush_texture: Texture

var curr_mouse_position: Vector2
var prev_mouse_position: Vector2
var mouse_deltas: Array

var brush_type = BrushType.AIRBRUSH
var brush_size: float = 1
var brush_color: Color = Color.white

var canvas_scale := 1.0

var cursor_wet := false

var brush_buffer := []

var pre_image: Image
var post_image: Image
var undo_redo := BoundedUndoRedo.new(UNDO_REDO_LIMIT)
var last_edited_texture: Texture

var edit_mode

var size: float
var type: int
var distorsion: float
var pigmentation_mode: int
var alignment_mode: int


func _ready():
	Editor.connect("new_texture", self, "initialize")


func initialize(width: float, height: float) -> void:
	Editor.size = Vector2(width, height)
	var image := Image.new()
	image.create(width, height, false, Image.FORMAT_RGBAH)
	
	image.fill(Color(1, 0.5, 0))
	Editor.alignment_texture.create_from_image(image, 0)
	
	image.fill(Color.black)
	Editor.size_texture.create_from_image(image, 0)
	Editor.type_texture.create_from_image(image, 0)
	Editor.distorsion_texture.create_from_image(image, 0)
	Editor.pm_texture.create_from_image(image, 0)
	
	image.fill(Color.red)
	Editor.am_texture.create_from_image(image, 0)
	
	self.texture = Editor.alignment_texture
	last_edited_texture = self.texture


func _draw():
	for location in brush_buffer:
		match brush_type:
			BrushType.CIRCLE:
				draw_circle(location, brush_size, brush_color)
			BrushType.SQUARE:
				var extents := Vector2.ONE * brush_size
				draw_rect(Rect2(location - extents, 2 * extents), brush_color)
			BrushType.AIRBRUSH:
				var extents := Vector2.ONE * brush_size
				var rect := Rect2(location - extents, 2 * extents)
				draw_texture_rect(airbrush_texture, rect, false, brush_color * Color(1, 1, 1, 0.2))


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
		Editor.dirty = true
		cursor_wet = true
		pre_image = self.texture.get_data()
		mouse_deltas = []
		return
	
	if not cursor_wet:
		return
	
	var displacement := prev_mouse_position.distance_to(curr_mouse_position)
	var delta := curr_mouse_position - prev_mouse_position
	
	mouse_deltas.push_back(delta)
	if (len(mouse_deltas) > ALIGNMENT_SMOOTHING):
		mouse_deltas.pop_front()
	
	if cursor_wet and displacement > 0:
		var n := int(displacement / MAX_DISTANCE)
		if n > 0:
			var stride := 1 / float(n) * delta
			for i in range(1, n + 1):
				brush_buffer.append(prev_mouse_position + stride * i)
		brush_buffer.append(curr_mouse_position)
	
	update_brush_color()
	
	if event.is_action_released("paint"):
		cursor_wet = false
		post_image = self.texture.get_data()
		commit_to_history()
		last_edited_texture = self.texture


func update_brush_color() -> void:
	match edit_mode:
		EditMode.ALIGNMENT:
			var mean_delta := Vector2.ZERO
			for d in mouse_deltas:
				mean_delta += d
			mean_delta /= max(len(mouse_deltas), 1)
			var packed_delta = mean_delta.normalized() * Vector2(1, -1) * 0.5 + Vector2.ONE * 0.5
			brush_color = Color(packed_delta.x, packed_delta.y, 0.0)
		EditMode.SIZE:
			brush_color = Color(size, size, size, 1)
		EditMode.TYPE:
			brush_color = BrushType.get_color(type)
		EditMode.DISTORSION:
			brush_color = Color(distorsion, distorsion, distorsion, 1)
		EditMode.PIGMENTATION_MODE:
			brush_color = Color(pigmentation_mode, pigmentation_mode, pigmentation_mode, 1)
		EditMode.ALIGNMENT_MODE:
			var am_r = float(alignment_mode == 0)
			var am_g = float(alignment_mode == 1)
			var am_b = float(alignment_mode == 2)
			brush_color = Color(am_r, am_g, am_b, 1)


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


func on_mode_selected(mode: int) -> void:
	edit_mode = mode
	self.texture = Editor.textures[edit_mode]
	match edit_mode:
		EditMode.ALIGNMENT:
			brush_type = BrushType.CIRCLE
		EditMode.SIZE:
			brush_type = BrushType.AIRBRUSH
		EditMode.TYPE:
			brush_type = BrushType.CIRCLE
		EditMode.DISTORSION:
			brush_type = BrushType.AIRBRUSH
		EditMode.PIGMENTATION_MODE:
			brush_type = BrushType.CIRCLE
		EditMode.ALIGNMENT_MODE:
			brush_type = BrushType.CIRCLE


func fill() -> void:
	print("FILL!")
	
	Editor.dirty = true
	
	pre_image = self.texture.get_data()
	
	update_brush_color()
	
	post_image = Image.new()
	post_image.create(Editor.size.x, Editor.size.y, false, Image.FORMAT_RGBAH)
	post_image.fill(brush_color)
	
	commit_to_history()
	last_edited_texture = self.texture


func on_load(width: float, height: float) -> void:
	pass


func on_scale_updated(s: float) -> void:
	canvas_scale = s


func set_brush_size(value: float) -> void:
	self.brush_size = value


func set_size(value: float) -> void:
	size = value


func set_type(value: int) -> void:
	type = value


func set_distorsion(value: float) -> void:
	distorsion = value


func set_pigmentation_mode(value: int) -> void:
	pigmentation_mode = value


func set_alignment_mode(value: int) -> void:
	alignment_mode = value
