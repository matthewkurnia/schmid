extends VBoxContainer


const MIN := 0
const MAX := 1
const STEP := 2

const PARAMETER_VALUES := {
	"min_scale": [0.0, 1.0, 0.001],
	"max_scale": [0.0, 1.0, 0.001],
	"min_distorsion": [0.0, 0.1, 0.0001],
	"max_distorsion": [0.0, 0.1, 0.0001],
	"angle_jitter": [0.0, 1.0, 0.01],
	"shadow_threshold": [0.0, 1.0, 0.01],
}

export var particles_path: NodePath
export var distorsion_path: NodePath

onready var particles = get_node_or_null(particles_path)
onready var distorsion = get_node_or_null(distorsion_path)

onready var control_group := $ControlGroup
onready var toggle_button := $Button
onready var spinbox_min_scale := $ControlGroup/MinScale/SpinBox
onready var spinbox_max_scale := $ControlGroup/MaxScale/SpinBox
onready var spinbox_angle_jitter := $ControlGroup/AngleJitter/SpinBox
onready var spinbox_min_distorsion := $ControlGroup/MinDistorsion/SpinBox
onready var spinbox_max_distorsion := $ControlGroup/MaxDistorsion/SpinBox
onready var spinbox_shadow_threshold := $ControlGroup/ShadowThreshold/SpinBox


func _ready():
	toggle_button.connect("pressed", self, "on_controls_toggle_visible")
	
	if not particles or not distorsion:
		return
	
	spinbox_min_scale.connect(
		"value_changed", self, "update_shader_param",
		[particles.process_material, "min_scale"]
	)
	spinbox_max_scale.connect(
		"value_changed", self, "update_shader_param",
		[particles.process_material, "max_scale"]
	)
	spinbox_angle_jitter.connect(
		"value_changed", self, "update_shader_param",
		[particles.process_material, "angle_jitter"]
	)
	spinbox_min_distorsion.connect(
		"value_changed", self, "update_shader_param",
		[distorsion.material, "min_distorsion"])
	spinbox_max_distorsion.connect(
		"value_changed", self, "update_shader_param",
		[distorsion.material, "max_distorsion"]
	)
	spinbox_shadow_threshold.connect(
		"value_changed", self, "update_shader_param",
		[distorsion.material, "shadow_threshold"]
	)
	
	spinbox_min_scale.min_value = PARAMETER_VALUES["min_scale"][MIN]
	spinbox_max_scale.min_value = PARAMETER_VALUES["max_scale"][MIN]
	spinbox_angle_jitter.min_value = PARAMETER_VALUES["angle_jitter"][MIN]
	spinbox_min_distorsion.min_value = PARAMETER_VALUES["min_distorsion"][MIN]
	spinbox_max_distorsion.min_value = PARAMETER_VALUES["max_distorsion"][MIN]
	spinbox_shadow_threshold.min_value = PARAMETER_VALUES["shadow_threshold"][MIN]

	spinbox_min_scale.max_value = PARAMETER_VALUES["min_scale"][MAX]
	spinbox_max_scale.max_value = PARAMETER_VALUES["max_scale"][MAX]
	spinbox_angle_jitter.max_value = PARAMETER_VALUES["angle_jitter"][MAX]
	spinbox_min_distorsion.max_value = PARAMETER_VALUES["min_distorsion"][MAX]
	spinbox_max_distorsion.max_value = PARAMETER_VALUES["max_distorsion"][MAX]
	spinbox_shadow_threshold.max_value = PARAMETER_VALUES["shadow_threshold"][MAX]
	
	spinbox_min_scale.step = PARAMETER_VALUES["min_scale"][STEP]
	spinbox_max_scale.step = PARAMETER_VALUES["max_scale"][STEP]
	spinbox_angle_jitter.step = PARAMETER_VALUES["angle_jitter"][STEP]
	spinbox_min_distorsion.step = PARAMETER_VALUES["min_distorsion"][STEP]
	spinbox_max_distorsion.step = PARAMETER_VALUES["max_distorsion"][STEP]
	spinbox_shadow_threshold.step = PARAMETER_VALUES["shadow_threshold"][STEP]
	
	spinbox_min_scale.value = particles.process_material.get_shader_param("min_scale")
	spinbox_max_scale.value = particles.process_material.get_shader_param("max_scale")
	spinbox_angle_jitter.value = particles.process_material.get_shader_param("angle_jitter")
	spinbox_min_distorsion.value = distorsion.material.get_shader_param("min_distorsion")
	spinbox_max_distorsion.value = distorsion.material.get_shader_param("max_distorsion")
	spinbox_shadow_threshold.value = distorsion.material.get_shader_param("shadow_threshold")


func update_shader_param(value: float, target_material: Material, param_name: String) -> void:
	target_material.set_shader_param(param_name, value)


func on_controls_toggle_visible():
	control_group.visible = not control_group.visible
	if control_group.visible:
		toggle_button.text = "Hide Controls"
	else:
		toggle_button.text = "Show Controls"
