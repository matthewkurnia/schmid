extends ViewportContainer


onready var stroke_particles = $Viewport/Strokes


func _ready():
	self.connect("resized", stroke_particles, "set_emission_extents")
