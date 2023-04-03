extends Node


const IDENTIFIERS := [
	"alignment",
	"size",
	"type",
	"distorsion"
]

onready var viewports := [
	$Alignment,
	$Size,
	$Type,
	$Distorsion
]

onready var sprites := [
	$Alignment/Sprite,
	$Size/Sprite,
	$Type/Sprite,
	$Distorsion/Sprite
]


func _ready():
	load_images("D:/Documents/Uni/2022-2023/Project/src/schmid/editor_files/tests/test.png")


func load_images(path: String) -> Dictionary:
	print(path)
	var image := Image.new()
	var image_texture := ImageTexture.new()
	image.load(path)
	image_texture.create_from_image(image)
	
	for sprite in sprites:
		sprite.texture = image_texture
	
	var size := image.get_size()
	for viewport in viewports:
		viewport.size = size
		viewport.set_update_mode(Viewport.UPDATE_ALWAYS)
	
	yield(VisualServer, "frame_post_draw")
	
	var images := {"composite": image}
	
	for i in range(4):
		var _image = viewports[i].get_texture().get_data()
		_image.flip_y()
		images[IDENTIFIERS[i]] = _image
	
	return images
