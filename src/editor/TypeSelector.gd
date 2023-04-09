extends OptionButton


const brush_type_names = [
	"Rectangular",
	"Grunge",
	"Thin Line",
	"Arc",
	"Circular",
	"Chaotic",
	"TBD_1",
	"TBD_2",
]


func _ready():
	for i in range(8):
		var image := Image.new()
		image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(BrushType.get_color(i))
		
		var texture := ImageTexture.new()
		texture.create_from_image(image, 0)
		
		self.add_icon_item(texture, brush_type_names[i], i)
