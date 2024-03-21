class_name PlayerController extends Node

var manager: PlayerControllerManager
var parent: BaseEntity

func _enter_tree() -> void:
	parent = get_parent()
	manager = get_parent().get_parent()
	manager.add_controller(self)

func _exit_tree() -> void:
	manager.remove_controller(self)

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func is_active() -> bool:
	return manager.get_current_controller() == self
