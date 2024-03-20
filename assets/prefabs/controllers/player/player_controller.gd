class_name PlayerController extends Node

var manager: PlayerControllerManager
var parent: BaseEntity

func _enter_tree() -> void:
	if !is_in_group("player_controllers"):
		add_to_group("player_controllers")
		
	parent = get_parent()
	manager = STUtil.get_only_node_in_group("player_controller_manager")

func is_active() -> bool:
	return manager.get_current_controller() == self
