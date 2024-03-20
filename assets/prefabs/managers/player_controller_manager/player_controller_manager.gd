class_name PlayerControllerManager extends Node

@export var current_controller: PlayerController

func _enter_tree() -> void:
    if !is_in_group("player_controller_manager"):
        add_to_group("player_controller_manager")

func get_current_controller() -> PlayerController:
    return current_controller

func set_current_controller(value: PlayerController) -> void:
    current_controller = value