extends OptionButton


const pigmentation_modes = [
	"Transparent",
	"Opaque",
]


func _ready():
	for i in range(2):
		self.add_item(pigmentation_modes[i], i)
