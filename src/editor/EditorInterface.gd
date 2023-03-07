extends Control


enum {
	UNDO,
	REDO,
	FILL
}

export var canvas_path: NodePath

onready var undo_button = $TopPanel/HBoxContainer/Undo/Button
onready var redo_button = $TopPanel/HBoxContainer/Redo/Button

onready var mode_selection_button = $BottomPanel/HBoxContainer/ButtonContainer/ModeSelectionButton

onready var canvas = get_node_or_null(canvas_path)


func _ready():
	if canvas:
		mode_selection_button.connect("item_selected", canvas, "on_mode_selected")


func _input(event):
	if event.is_action_pressed("redo") and not event.is_echo():
		on_action(REDO)
	elif event.is_action_pressed("undo") and not event.is_echo():
		on_action(UNDO)


func on_action(action):
	if not canvas:
		return
	match action:
		UNDO:
			canvas.undo()
		REDO:
			canvas.redo()
