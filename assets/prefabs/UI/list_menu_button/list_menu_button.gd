class_name ListMenuButton extends Button

@export var button_title: String = "Placeholder":
	set(value):
		button_title = value
		if label: label.text = value
@export var pressed_command: InteractionCommand

@export_group("References")
@export var label: Label
@export var margin_container: MarginContainer
@export var npr: NinePatchRect

var shader: ShaderMaterial
var current_cutoff: float = 0.;

signal animation_finished

func _ready() -> void:
	shader = npr.material
	label.text = button_title
	focus_entered.connect(animate_selected)
	focus_exited.connect(animate_unselected)

func _set_shader_cutoff(value: float) -> void:
	current_cutoff = value
	if shader:
		shader.set_shader_parameter("cutoff", value)

func _on_focus_entered() -> void:
	animate_selected()

func _on_focus_exited() -> void:
	animate_unselected()

func get_pressed_command() -> InteractionCommand:
	return pressed_command

func animate_selected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(margin_container, "theme_override_constants/margin_left", 16, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 1., .35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	animation_finished.emit()

func animate_unselected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(margin_container, "theme_override_constants/margin_left", 0, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 0., .35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	animation_finished.emit()
