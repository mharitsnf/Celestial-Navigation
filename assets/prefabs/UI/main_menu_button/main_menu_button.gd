extends MarginContainer

@export var button_title: String:
	set(value):
		button_title = value
		if label: label.text = value

@export_group("References")
@export var label: Label
@export var margin_container: MarginContainer
@export var npr: NinePatchRect

var shader: ShaderMaterial
var current_cutoff: float = 0.;

func _ready() -> void:
	shader = npr.material
	await get_tree().create_timer(1.).timeout
	animate_selected()

func _set_shader_cutoff(value: float) -> void:
	if shader:
		shader.set_shader_parameter("cutoff", value)

func animate_selected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(margin_container, "theme_override_constants/margin_left", 16, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 1., .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func animate_unselected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(margin_container, "theme_override_constants/margin_left", 0, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 0., .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
