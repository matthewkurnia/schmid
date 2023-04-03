extends WindowDialog


signal new(width, height)


var square := false

onready var width_spin_box := $CenterContainer/VBoxContainer/WidthHeightContainer/WidthSpinBox
onready var height_spin_box := $CenterContainer/VBoxContainer/WidthHeightContainer/HeightSpinBox
onready var square_check_box := $CenterContainer/VBoxContainer/SquareAspectRatioContainer/CheckBox
onready var create_button := $CenterContainer/VBoxContainer/Button


func _ready():
	width_spin_box.connect("value_changed", self, "on_width_changed")
	height_spin_box.connect("value_changed", self, "on_height_changed")
	square_check_box.connect("toggled", self, "on_square_toggled")
	create_button.connect("pressed", self, "on_create")


func on_width_changed(width: float) -> void:
	if square:
		height_spin_box.value = width_spin_box.value


func on_height_changed(height: float) -> void:
	if square:
		width_spin_box.value = height_spin_box.value


func on_square_toggled(value: bool) -> void:
	square = value
	if square:
		height_spin_box.value = width_spin_box.value


func on_create() -> void:
	emit_signal("new", width_spin_box.value, height_spin_box.value)
	hide()
