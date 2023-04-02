extends Node


var pm_default = PigmentationMode.TRANSPARENT
var am_default = AlignmentMode.RANDOM

var alignment_texture := ImageTexture.new()
var size_texture := ImageTexture.new()
var type_texture := ImageTexture.new()
var distorsion_texture := ImageTexture.new()

var textures := [
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
