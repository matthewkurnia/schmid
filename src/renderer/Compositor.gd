extends ViewportContainer


const SCENES = [
	preload("res://src/editor/Viewer3D.tscn")
]

var selected_scene_index := 0
var scene_camera: Camera

onready var depth_motion := $DepthMotion
onready var base := $Base
onready var cameras := [
	$Base/Camera,
	$DepthMotion/Camera,
	$Buffered/Camera
]
onready var viewports := [
	$DepthMotion,
	$Base,
	$Buffered
]


func _ready():
	self.connect("resized", self, "on_resized")
	update_viewport_sizes()
	var scene = SCENES[selected_scene_index].instance()
	self.add_child(scene)
	scene_camera = scene.get_viewport().get_camera()


func _process(delta):
	for camera in cameras:
		camera.set_global_transform(scene_camera.get_global_transform())


func update_viewport_sizes():
	for viewport in viewports:
		viewport.size = self.rect_size


func on_resized():
	update_viewport_sizes()
