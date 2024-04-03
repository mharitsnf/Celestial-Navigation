class_name TransitionScreen extends ColorRect

@export var anim: AnimationPlayer

func show_screen() -> void:
	anim.play("appear")

func hide_screen() -> void:
	anim.play("disappear")
