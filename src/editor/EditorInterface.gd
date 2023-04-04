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

onready var mode_selection_button := $BottomPanel/HBoxContainer/ModeSelectionContainer/ModeSelectionButton

onready var size_slider := $BottomPanel/HBoxContainer/SizeSlider/HSlider
onready var type_selector := $BottomPanel/HBoxContainer/TypeSelectorContainer/TypeSelector
onready var distorsion_slider := $BottomPanel/HBoxContainer/DistorsionSlider/HSlider
onready var pm_selector := $BottomPanel/HBoxContainer/PMSelectorContainer/PigmentationModeSelector/OptionButton
onready var am_selector := $BottomPanel/HBoxContainer/AMSelectorContainer/AlignmentModeSelector/OptionButton

onready var size_slider_container := $BottomPanel/HBoxContainer/SizeSlider
onready var distorsion_slider_container := $BottomPanel/HBoxContainer/DistorsionSlider
onready var am_selector_container := $BottomPanel/HBoxContainer/AMSelectorContainer


func _ready():
	Editor.connect("load_texture", self, "on_load")
	
	mode_selection_button.connect("item_selected", self, "on_mode_selected")
	
	self.on_mode_selected(mode_selection_button.selected)
	
	undo_button.connect("pressed", self, "on_action", [UNDO])
	redo_button.connect("pressed", self, "on_action", [REDO])
	
	if not canvas:
		return
	
	mode_selection_button.connect("item_selected", canvas, "on_mode_selected")
	brush_size_spinbox.connect("value_changed", canvas, "set_brush_size")
	size_slider.connect("value_changed", canvas, "set_size")
	type_selector.connect("item_selected", canvas, "set_type")
	distorsion_slider.connect("value_changed", canvas, "set_distorsion")
	pm_selector.connect("item_selected", Editor, "set_pigmentation_mode")
	am_selector.connect("item_selected", Editor, "set_alignment_mode")
	
	canvas.on_mode_selected(mode_selection_button.selected)
	canvas.set_brush_size(brush_size_spinbox.value)
	canvas.set_size(size_slider.value)
	canvas.set_type(type_selector.selected)
	canvas.set_distorsion(distorsion_slider.value)
	
	new_button.connect("pressed", self, "on_canvas_override", [new_dialog])
	new_dialog.connect("new", Editor, "new_texture")
	save_button.connect("pressed", save_dialog, "popup")
	save_dialog.connect("file_selected", Editor, "save_texture")
	load_button.connect("pressed", self, "on_canvas_override", [load_dialog])
	load_dialog.connect("file_selected", Editor, "load_texture")
	
	pm_selector.connect("item_selected", self, "on_am_or_pm_changed")
	am_selector.connect("item_selected", self, "on_am_or_pm_changed")


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
	match mode:
		EditMode.ALIGNMENT:
			size_slider_container.visible = false
			distorsion_slider_container.visible = false
			type_selector.visible = false
			am_selector_container.visible = true
		EditMode.SIZE:
			size_slider_container.visible = true
			distorsion_slider_container.visible = false
			type_selector.visible = false
			am_selector_container.visible = false
		EditMode.TYPE:
			size_slider_container.visible = false
			distorsion_slider_container.visible = false
			type_selector.visible = true
			am_selector_container.visible = false
		EditMode.DISTORSION:
			size_slider_container.visible = false
			distorsion_slider_container.visible = true
			type_selector.visible = false
			am_selector_container.visible = false


func on_load(_width, _height) -> void:
	pm_selector.select(Editor.pigmentation_mode)
	am_selector.select(Editor.alignment_mode)


func on_canvas_override(target_dialog: WindowDialog) -> void:
	if Editor.dirty:
		confirmation_dialog.connect("confirmed", target_dialog, "popup", [], CONNECT_ONESHOT)
		confirmation_dialog.show()
		return
	target_dialog.popup()


func on_am_or_pm_changed(_index: int) -> void:
	Editor.dirty = true
