extends Node


signal new_texture(width, height)
signal save_texture()
signal load_texture(width, height)

const DEFAULT_WIDTH := 256
const DEFAULT_HEIGHT := 256

var pm_default = PigmentationMode.TRANSPARENT
var am_default = AlignmentMode.RANDOM

var alignment_texture := ImageTexture.new()
var size_texture := ImageTexture.new()
var type_texture := ImageTexture.new()
var distorsion_texture := ImageTexture.new()

var textures = [
	alignment_texture,
	size_texture,
	type_texture,
	distorsion_texture
]

var pigmentation_mode = PigmentationMode.TRANSPARENT setget set_pigmentation_mode
var alignment_mode = AlignmentMode.RANDOM setget set_alignment_mode

var viewer: Control

var size: Vector2

var composite_material: Material setget set_composite_material
var composite_sprite: Sprite

var texture_path: String

var dirty := false


func _ready():
	call_deferred("emit_signal", "new_texture", DEFAULT_WIDTH, DEFAULT_HEIGHT)


func set_composite_material(material: Material) -> void:
	composite_material = material
	
	composite_material.set_shader_param("alignment_texture", alignment_texture)
	composite_material.set_shader_param("size_texture", size_texture)
	composite_material.set_shader_param("type_texture", type_texture)
	composite_material.set_shader_param("distorsion_texture", distorsion_texture)
	composite_material.set_shader_param("pigmentation_mode", pigmentation_mode)
	composite_material.set_shader_param("alignment_mode", alignment_mode)
	
	composite_material = material


func set_pigmentation_mode(pm: int) -> void:
	pigmentation_mode = pm
	composite_material.set_shader_param("pigmentation_mode", pigmentation_mode)


func set_alignment_mode(am: int) -> void:
	alignment_mode = am
	composite_material.set_shader_param("alignment_mode", alignment_mode)


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
	
	var composite_image = images["composite"]
	composite_image.lock()
	var color = composite_image.get_pixel(0, 0)
	set_pigmentation_mode(color.g8 >> 7)
	set_alignment_mode(color.b8 >> 6)
	composite_image.unlock()
	
	var size = composite_image.get_size()
	emit_signal("load_texture", size.x, size.y)
