extends OptionButton


const alignment_modes = [
	"Random",
	"Encoded",
	"Tangential",
]


func _ready():
	for i in range(3):
		self.add_item(alignment_modes[i], i)
