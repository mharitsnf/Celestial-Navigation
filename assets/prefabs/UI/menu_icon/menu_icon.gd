class_name MenuIcon extends MarginContainer

@export var animation_duration: float = .25
@export_group("References")
@export var background: NinePatchRect
@export var title_container: Control
@export var title_label: Label
@export var icons_hbox: HBoxContainer

var shader: ShaderMaterial
var current_cutoff: float = 0.
var title_container_x_size: float

func _enter_tree() -> void:
	shader = background.material
	set_defaults()

func set_defaults() -> void:
	title_container_x_size = title_label.size.x

	# Reset properties
	_set_shader_cutoff(0.)
	title_container.custom_minimum_size = Vector2.ZERO
	icons_hbox.add_theme_constant_override("separation", 0)

func enter_selected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 1., animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_container, "custom_minimum_size", Vector2(title_container_x_size, 0.), animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(icons_hbox, "theme_override_constants/separation", 32, animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func exit_selected() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_shader_cutoff, current_cutoff, 0., animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_container, "custom_minimum_size", Vector2.ZERO, animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(icons_hbox, "theme_override_constants/separation", 0, animation_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func _set_shader_cutoff(value: float) -> void:
	current_cutoff = value
	shader.set_shader_parameter("cutoff", current_cutoff)

func _on_focus_exited() -> void:
	exit_selected()

func _on_focus_entered() -> void:
	enter_selected()
