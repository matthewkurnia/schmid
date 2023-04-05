extends OptionButton


const pigmentation_modes = [
	"Transparent",
	"Opaque",
]

const colors := [
	Color.black,
	Color.white
]


func _ready():
	for i in range(2):
		var image := Image.new()
		image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(colors[i])
		
		var texture := ImageTexture.new()
		texture.create_from_image(image, 0)
		
		self.add_icon_item(texture, pigmentation_modes[i], i)
