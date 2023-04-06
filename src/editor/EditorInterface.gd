extends Control


signal show_new_dialog()
signal show_load_dialog()

enum {
	UNDO,
	REDO,
	FILL
}

export var canvas_path: NodePath
export var canvas_container_path: NodePath
export var wireframe_material: Material

onready var canvas = get_node_or_null(canvas_path)
onready var canvas_container = get_node_or_null(canvas_container_path)

onready var new_button := $TopPanel/HBoxContainer/New/Button
onready var save_button := $TopPanel/HBoxContainer/Save/Button
onready var load_button := $TopPanel/HBoxContainer/Load/Button

onready var save_dialog := $SaveDialog
onready var new_dialog := $NewDialog
onready var load_dialog := $LoadDialog
onready var confirmation_dialog := $ConfirmationDialog

onready var undo_button := $TopPanel/HBoxContainer/Undo/Button
onready var redo_button := $TopPanel/HBoxContainer/Redo/Button

onready var brush_size_spinbox := $TopPanel/HBoxContainer/Size/SpinBox

onready var fill_button := $TopPanel/HBoxContainer/Fill/Button

onready var mode_selection_button := $BottomPanel/HBoxContainer/ModeSelectionContainer/ModeSelectionButton

onready var size_slider := $BottomPanel/HBoxContainer/SizeSlider/HSlider
onready var type_selector := $BottomPanel/HBoxContainer/TypeSelectorContainer/TypeSelector
onready var distorsion_slider := $BottomPanel/HBoxContainer/DistorsionSlider/HSlider
onready var pm_selector := $BottomPanel/HBoxContainer/PMSelectorContainer/PigmentationModeSelector/OptionButton
onready var am_selector := $BottomPanel/HBoxContainer/AMSelectorContainer/AlignmentModeSelector/OptionButton

onready var size_slider_container := $BottomPanel/HBoxContainer/SizeSlider
onready var distorsion_slider_container := $BottomPanel/HBoxContainer/DistorsionSlider
onready var am_selector_container := $BottomPanel/HBoxContainer/AMSelectorContainer
onready var pm_selector_container := $BottomPanel/HBoxContainer/PMSelectorContainer

onready var wireframe_color_picker := $WireframeControls/ColorPickerContainer/HBoxContainer/ColorPickerButton
onready var wireframe_thickness_slider := $WireframeControls/ThicknessSliderContainer/HBoxContainer/HSlider


func _ready():
	mode_selection_button.connect("item_selected", self, "on_mode_selected")
	
	self.on_mode_selected(mode_selection_button.selected)
	
	undo_button.connect("pressed", self, "on_action", [UNDO])
	redo_button.connect("pressed", self, "on_action", [REDO])
	
	wireframe_color_picker.connect("color_changed", self, "change_wireframe_color")
	wireframe_thickness_slider.connect("value_changed", self, "change_wireframe_thickness")
	change_wireframe_thickness(wireframe_thickness_slider.value)
	
	if not canvas:
		return
	
	mode_selection_button.connect("item_selected", canvas, "on_mode_selected")
	brush_size_spinbox.connect("value_changed", canvas, "set_brush_size")
	size_slider.connect("value_changed", canvas, "set_size")
	type_selector.connect("item_selected", canvas, "set_type")
	distorsion_slider.connect("value_changed", canvas, "set_distorsion")
	pm_selector.connect("item_selected", canvas, "set_pigmentation_mode")
	am_selector.connect("item_selected", canvas, "set_alignment_mode")
	
	canvas.on_mode_selected(mode_selection_button.selected)
	canvas.set_brush_size(brush_size_spinbox.value)
	canvas.set_size(size_slider.value)
	canvas.set_type(type_selector.selected)
	canvas.set_distorsion(distorsion_slider.value)
	canvas.set_pigmentation_mode(pm_selector.selected)
	canvas.set_alignment_mode(am_selector.selected)
	
	fill_button.connect("pressed", canvas, "fill")
	
	new_button.connect("pressed", self, "on_canvas_override", [new_dialog])
	new_dialog.connect("new", Editor, "new_texture")
	save_button.connect("pressed", save_dialog, "popup")
	save_dialog.connect("file_selected", Editor, "save_texture")
	load_button.connect("pressed", self, "on_canvas_override", [load_dialog])
	load_dialog.connect("file_selected", Editor, "load_texture")


func _input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("redo"):
		on_action(REDO)
	elif event.is_action_pressed("undo"):
		on_action(UNDO)
	elif event.is_action_pressed("new"):
		on_canvas_override(new_dialog)
	elif event.is_action_pressed("save"):
		save_dialog.popup()
	elif event.is_action_pressed("quick_save"):
		if Editor.texture_path == "":
			save_dialog.popup()
		else:
			Editor.save_texture(Editor.texture_path)
	elif event.is_action_pressed("load"):
		on_canvas_override(load_dialog)


func on_action(action):
	if not canvas:
		return
	match action:
		UNDO:
			canvas.undo()
		REDO:
			canvas.redo()


func on_mode_selected(mode: int) -> void:
	size_slider_container.visible = mode == EditMode.SIZE
	distorsion_slider_container.visible = mode == EditMode.DISTORSION
	type_selector.visible = mode == EditMode.TYPE
	pm_selector_container.visible = mode == EditMode.PIGMENTATION_MODE
	am_selector_container.visible = mode == EditMode.ALIGNMENT_MODE


func on_canvas_override(target_dialog: WindowDialog) -> void:
	if Editor.dirty:
		confirmation_dialog.connect("confirmed", target_dialog, "popup", [], CONNECT_ONESHOT)
		confirmation_dialog.show()
		return
	target_dialog.popup()


func change_wireframe_color(color: Color) -> void:
	wireframe_material.set_shader_param("wire_color", color)


func change_wireframe_thickness(thickness: float) -> void:
	wireframe_material.set_shader_param("wire_width", thickness)
