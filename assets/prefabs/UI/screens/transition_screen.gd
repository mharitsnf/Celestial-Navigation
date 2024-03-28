class_name TransitionScreen extends ColorRect

@export var anim: AnimationPlayer

func _enter_tree() -> void:
	if !is_in_group("transition_screen"):
		add_to_group("transition_screen")

func show_screen() -> void:
	anim.play("appear")

func hide_screen() -> void:
	anim.play("disappear")
