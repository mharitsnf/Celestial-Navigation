class_name UIController extends Node

@export var animation_speed: float = .2
@export var parent: Control

var animating: bool = false

signal interact_pressed
signal animation_finished

func process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact"):
        interact_pressed.emit()

func is_animating() -> bool:
    return animating

func before_exit_tree() -> STUtil.Promise:
    return STUtil.Promise.new()

func _reset_animation() -> void:
    pass

func show_ui() -> void:
    pass

func hide_ui() -> void:
    pass