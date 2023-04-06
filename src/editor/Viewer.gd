extends Control


signal input_received(event)

const Viewer3D = preload("res://src/editor/Viewer3D.tscn")

var viewer_3d
var handle_input := false
var meshes := []

onready var load_button := $Menus/LoadButton
onready var mesh_selector := $Menus/MeshSelector
onready var load_dialog := $LoadDialog
onready var compositor := $ViewportContainer/Viewport/Renderer/Compositor


func _init():
	Editor.viewer = self


func _input(event):
	if handle_input:
		emit_signal("input_received", event)


func _ready():
	$ViewportContainer/Viewport.set_size(self.rect_size)
	$ViewportContainer/Viewport/Renderer/StrokesContainer/Viewport/Strokes.set_emission_extents()
	self.call_deferred("connect", "mouse_entered", self, "on_mouse_entered")
	self.call_deferred("connect", "mouse_exited", self, "on_mouse_exited")
	
	load_button.connect("pressed", load_dialog, "popup")
	load_dialog.connect("file_selected", self, "load_model")
	
	viewer_3d = Viewer3D.instance()
	viewer_3d.set_input_origin(self)
	compositor.change_scene_to(viewer_3d)
	
	mesh_selector.connect("item_selected", self, "select_mesh")


func load_model(path: String) -> void:
	var packed_scene_gltf = PackedSceneGLTF.new()
	var model = packed_scene_gltf.import_gltf_scene(path)
	
	viewer_3d.change_scene_to(model)
	
	meshes = get_meshes(model)
	
	mesh_selector.clear()
	for i in range(len(meshes)):
		mesh_selector.add_item(meshes[i].name, i)
	
	if len(meshes) == 0:
		print("ERROR: no mesh instances detected!")
	
	select_mesh(0)


func get_meshes(node: Node) -> Array:
	var result := []
	if node is MeshInstance:
		result = [node]
	for child in node.get_children():
		result.append_array(get_meshes(child))
	return result


func select_mesh(index: int) -> void:
	for i in range(len(meshes)):
		meshes[i].visible = i == index
	Editor.set_viewed_mesh(meshes[index])


func on_mouse_entered():
	print("ENTERED")
	handle_input = true


func on_mouse_exited():
	print("EXITED")
	handle_input = false
