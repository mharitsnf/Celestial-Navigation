class_name UIController extends Node

@export var animation_speed: float = .2
@export var parent: Control

signal animation_finished

func enter_ui() -> void:
    pass

func exit_ui() -> void:
    pass

func show_ui() -> void:
    pass

func hide_ui() -> void:
    pass