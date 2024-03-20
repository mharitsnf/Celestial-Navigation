class_name State extends Node

var parent: PlayerCharacterController

func _enter_tree() -> void:
    parent = get_parent()

func enter_state() -> void:
    pass

func process(_delta: float) -> void:
    pass

func physics_process(_delta: float) -> void:
    pass

func exit_state() -> void:
    pass