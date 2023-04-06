extends Spatial


const CAMERA_SCROLL_STRIDE := 0.25
const CAMERA_MIN_DISTANCE := 0.5
const CAMERA_MAX_DISTANCE := 20.0

var pressed := false
var sensitivity := 0.01
var input_origin: Node

onready var camera = $Camera


func _ready():
	input_origin.connect("input_received", self, "handle_input")


func _unhandled_input(event):
	handle_input(event)


func handle_input(event):
	if event.is_action_pressed("pan") and not event.is_echo():
		pressed = true
	if event.is_action_released("pan") and not event.is_echo():
		pressed = false
	if pressed and event is InputEventMouseMotion:
		self.rotation.x -= event.relative.y * sensitivity
		self.rotation.y -= event.relative.x * sensitivity
	
	if event.is_action_released("scroll_up"):
		camera.translation.z = max(camera.translation.z - CAMERA_SCROLL_STRIDE, CAMERA_MIN_DISTANCE)
	elif event.is_action_released("scroll_down"):
		camera.translation.z = min(camera.translation.z + CAMERA_SCROLL_STRIDE, CAMERA_MAX_DISTANCE)

