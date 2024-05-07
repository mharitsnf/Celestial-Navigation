class_name TransitionScreen extends ColorRect

@export var anim: AnimationPlayer

func _ready() -> void:
	visible = true

func show_screen() -> void:
	anim.play("appear")

func hide_screen() -> void:
	anim.play("disappear")
