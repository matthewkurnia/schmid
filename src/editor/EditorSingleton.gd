extends Node


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

var viewer: Control
