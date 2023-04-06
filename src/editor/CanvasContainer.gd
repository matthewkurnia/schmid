extends ViewportContainer


signal scale_updated(scale)

export var canvas_path: NodePath

var prev_mouse_position: Vector2
var curr_mouse_position: Vector2
var scale := 1.0
var scale_factor := 1.2
var panning := false
var inert_size: Vector2

onready var canvas = get_node_or_null(canvas_path)
onready var editor_viewport = $EditorViewport
onready var wireframe_viewport = $WireframeViewport


func _ready():
	Editor.connect("new_texture", self, "initialize")
	Editor.connect("load_texture", self, "initialize")
	if canvas:
		self.connect("scale_updated", canvas, "on_scale_updated")


func initialize(width: float, height: float):
	var size := Vector2(width, height)
	update_viewport_size(size)
	self.rect_size = size


func update_viewport_size(size: Vector2) -> void:
	print("Canvas size updated to " + str(size))
	inert_size = size
	editor_viewport.size = inert_size
	wireframe_viewport.size = inert_size


func handle_input(event):
	prev_mouse_position = curr_mouse_position
	curr_mouse_position = get_global_mouse_position()
	var mouse_displacement := curr_mouse_position - prev_mouse_position
	
	if event.is_action_pressed("pan") and not event.is_echo():
		panning = true
	if event.is_action_released("pan") and not event.is_echo():
		panning = false
	if panning:
		self.rect_position += mouse_displacement
	
	if event.is_action_released("scroll_up"):
		apply_scale(scale_factor)
	elif event.is_action_released("scroll_down"):
		apply_scale(1/scale_factor)
	
	if canvas:
		canvas.handle_input(event)


func apply_scale(multiplier: float) -> void:
	var displacement := (curr_mouse_position - self.rect_position) * (1 - multiplier)
	self.rect_position += displacement
	scale *= multiplier
	self.rect_scale = scale * Vector2.ONE
	self.rect_size = inert_size
	emit_signal("scale_updated", scale)


func on_load(width: float, height: float) -> void:
	pass
