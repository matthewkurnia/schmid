extends Viewport


onready var sprite := $Sprite


func _ready():
	self.size = Editor.size
	# DEBUG CODE BEGIN
	self.size = 200 * Vector2.ONE
	print(self.size)
	# DEBUG CODE END
	
	var image := Image.new()
	image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.purple)
	var texture := ImageTexture.new()
	texture.create_from_image(image, 0)
	
	sprite.texture = texture
	
	Editor.composite_material = sprite.material
