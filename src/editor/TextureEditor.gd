extends Control


signal input_received(event)

export var nested_input_handler_path: NodePath

var handle_input := false


func _ready():
	self.connect("mouse_entered", self, "on_mouse_entered")
	self.connect("mouse_exited", self, "on_mouse_exited")
	var nested_input_handler = get_node_or_null(nested_input_handler_path)
	if nested_input_handler:
		self.connect("input_received", nested_input_handler, "handle_input")


func on_mouse_entered():
	handle_input = true


func on_mouse_exited():
	handle_input = false


func _input(event):
	if handle_input:
		emit_signal("input_received", event)
