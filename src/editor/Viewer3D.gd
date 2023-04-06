extends Spatial


onready var scene_root = $SceneRoot


func set_input_origin(input_origin: Node) -> void:
	$Pivot.input_origin = input_origin


func change_scene_to(scene: Node) -> void:
	for child in scene_root.get_children():
		child.queue_free()
	scene_root.add_child(scene)
