extends Control


signal input_received(event)

var input_handler

var handle_input := false


func _init():
	Editor.viewer = self


func _ready():
	$ViewportContainer/Viewport.set_size(self.rect_size)
	$ViewportContainer/Viewport/Renderer/StrokesContainer/Viewport/Strokes.set_emission_extents()
	self.call_deferred("connect", "mouse_entered", self, "on_mouse_entered")
	self.call_deferred("connect", "mouse_exited", self, "on_mouse_exited")
	
	self.call_deferred("connect", "input_received", input_handler, "handle_input")


func on_mouse_entered():
	print("ENTERED")
	handle_input = true


func on_mouse_exited():
	print("EXITED")
	handle_input = false


func _input(event):
	if handle_input:
		emit_signal("input_received", event)
