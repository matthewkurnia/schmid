extends ViewportContainer


func _ready():
	$Viewport.size = self.rect_size
