extends Node


signal new_texture(width, height)
signal save_texture()
signal load_texture(width, height)
signal viewed_mesh_updated(mesh)

const DEFAULT_WIDTH := 256
const DEFAULT_HEIGHT := 256

var pm_default = PigmentationMode.TRANSPARENT
var am_default = AlignmentMode.RANDOM

var alignment_texture := ImageTexture.new()
var size_texture := ImageTexture.new()
var type_texture := ImageTexture.new()
var distorsion_texture := ImageTexture.new()
var pm_texture := ImageTexture.new()
var am_texture := ImageTexture.new()

var textures = [
	alignment_texture,
	size_texture,
	type_texture,
	distorsion_texture,
	pm_texture,
	am_texture
]

var viewer: Control

var size: Vector2

var composite_material: Material setget set_composite_material
var composite_sprite: Sprite

var texture_path: String

var dirty := false

var viewed_mesh: MeshInstance


func _ready():
	call_deferred("emit_signal", "new_texture", DEFAULT_WIDTH, DEFAULT_HEIGHT)


func set_composite_material(material: Material) -> void:
	composite_material = material
	
	composite_material.set_shader_param("alignment_texture", alignment_texture)
	composite_material.set_shader_param("size_texture", size_texture)
	composite_material.set_shader_param("type_texture", type_texture)
	composite_material.set_shader_param("distorsion_texture", distorsion_texture)
	composite_material.set_shader_param("pm_texture", pm_texture)
	composite_material.set_shader_param("am_texture", am_texture)
	
	composite_material = material


func new_texture(width: float, height: float) -> void:
	texture_path = ""
	emit_signal("new_texture", width, height)


func save_texture(path: String) -> void:
	texture_path = path
	
	var image = composite_sprite.get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png(path)


func load_texture(path: String) -> void:
	texture_path = path
	
	var y = TextureLoader.load_images(texture_path)
	var images = yield(y, "completed")
	
	alignment_texture.create_from_image(images["alignment"])
	size_texture.create_from_image(images["size"])
	type_texture.create_from_image(images["type"])
	distorsion_texture.create_from_image(images["distorsion"])
	pm_texture.create_from_image(images["pigmentation_mode"])
	am_texture.create_from_image(images["alignment_mode"])
	
	var composite_image = images["composite"]
	var size = composite_image.get_size()
	emit_signal("load_texture", size.x, size.y)


func set_viewed_mesh(mesh: MeshInstance) -> void:
	viewed_mesh = mesh
	emit_signal("viewed_mesh_updated", mesh)
