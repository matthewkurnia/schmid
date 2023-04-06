extends Spatial


export var wireframe_material: Material

onready var mesh_parent = $MeshParent


func _ready():
	Editor.connect("viewed_mesh_updated", self, "generate_wireframe")


func generate_wireframe(mesh: MeshInstance) -> void:
	var wireframe_mesh := mesh.duplicate()
	for child in mesh_parent.get_children():
		child.queue_free()
	mesh_parent.add_child(wireframe_mesh)
	wireframe_mesh.material_override = wireframe_material
