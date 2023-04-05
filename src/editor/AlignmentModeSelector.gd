extends OptionButton


const alignment_modes = [
	"Random",
	"Encoded",
	"Tangential",
]

const colors := [
	Color.red,
	Color.green,
	Color.blue
]


func _ready():
	for i in range(3):
		var image := Image.new()
		image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(colors[i])
		
		var texture := ImageTexture.new()
		texture.create_from_image(image, 0)
		
		self.add_icon_item(texture, alignment_modes[i], i)
