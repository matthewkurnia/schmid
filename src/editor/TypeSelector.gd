extends OptionButton


const brush_type_names = [
	"Brush 1",
	"Brush 2",
	"Brush 3",
	"Brush 4",
	"Brush 5",
	"Brush 6",
	"Brush 7",
	"Brush 8",
]


func _ready():
	for i in range(8):
		var image := Image.new()
		image.create(16, 16, false, Image.FORMAT_RGBA8)
		
		image.fill(BrushType.get_color(i))
		
		var texture := ImageTexture.new()
		texture.create_from_image(image, 0)
		
		self.add_icon_item(texture, brush_type_names[i], i)
