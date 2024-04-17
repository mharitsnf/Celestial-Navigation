class_name UIController extends Node

@export var animation_speed: float = .2
@export var parent: Control

signal interact_pressed
signal animation_finished

func process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact"):
        interact_pressed.emit()

func enter_ui() -> void:
    pass

func exit_ui() -> void:
    pass

func show_ui() -> void:
    pass

func hide_ui() -> void:
    pass