class_name HUDController extends Node

@export_group("References")
@export var parent: Control

var animating: bool = false

signal animation_finished

func _ready() -> void:
    if !parent.is_node_ready():
        await parent.ready
    reset_animation()

func is_animating() -> bool:
    return animating

func reset_animation() -> void:
    pass

func show_hud() -> void:
    pass

func hide_hud() -> void:
    pass