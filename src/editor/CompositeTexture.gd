extends Viewport


onready var sprite := $Sprite


func _ready():
	Editor.connect("new_texture", self, "initialize")
	Editor.connect("load_texture", self, "initialize")


func initialize(width: float, height: float) -> void:
	self.size = Vector2(width, height)
	
	var image := Image.new()
	image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.purple)
	var texture := ImageTexture.new()
	texture.create_from_image(image, 0)
	
	sprite.texture = texture
	
	Editor.composite_material = sprite.material
	Editor.composite_sprite = sprite
