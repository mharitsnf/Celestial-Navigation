class_name PlayerControllerManager extends Node

# class PlayerObject extends RefCounted:
# 	var pscn: PackedScene
# 	var controller: PlayerController
# 	var instance: Control = null
# 	func _init(_pscn: PackedScene) -> void:
# 		pscn = _pscn
# 	func create_instance() -> void:
# 		instance = pscn.instantiate()
# 		controller = instance.get_node("Controller")
# 	func get_controller() -> PlayerController:
# 		return controller
# 	func get_instance() -> Control:
# 		return instance

# enum PlayerObjectEnum {
# 	NONE, BOAT, CHARACTER, SUNDIAL
# }
# var current_player_object: PlayerObject
# var player_object_dict: Dictionary = {
# 	PlayerObjectEnum.BOAT: null,
# 	PlayerObjectEnum.CHARACTER: null,
# 	PlayerObjectEnum.SUNDIAL: null,
# }

var previous_controller: PlayerController
@export var current_controller: PlayerController
var controllers: Array[PlayerController]

var main_camera: MainCamera
var main_camera_controller: MainCameraController

var _transitioning: bool = false
signal transition_finished

# ========== Built-in functions ==========
func _ready() -> void:
	main_camera = STUtil.get_only_node_in_group("main_camera")
	main_camera_controller = STUtil.get_only_node_in_group("main_camera_controller")

func _process(delta: float) -> void:
	if !is_transitioning():
		current_controller.process(delta)

func _physics_process(delta: float) -> void:
	if !is_transitioning():
		current_controller.physics_process(delta)
# ========== ========== ========== ==========

# ========== Setter and getters ==========
func get_current_controller() -> PlayerController:
	return current_controller

func set_current_controller(value: PlayerController) -> void:
	current_controller = value

func is_transitioning() -> bool:
	return _transitioning

func get_player_entity() -> BaseEntity:
	if !current_controller: return null 
	return current_controller.parent

func set_transitioning(value: bool) -> void:
	_transitioning = value
# ========== ========== ========== ==========

# ========== Enter and exit ship ==========
func is_switchable() -> bool:
	if is_transitioning(): return false
	if !main_camera.get_follow_target().is_entry_camera(): return false
	return true

func switch_controller(next_controller: PlayerController) -> void:
	if next_controller == current_controller:
		push_warning("Current controller is the same as the next controller! Returning...")
		return

	var available_virtual_cameras: Array[Node] = STUtil.get_nodes_in_group(String(next_controller.parent.get_path()) + "/VCs")
	if available_virtual_cameras.is_empty():
		push_warning("Available virtual camera is empty! Returning...")
		return

	var entry_camera: VirtualCamera
	var vcs: Array = available_virtual_cameras.filter(func (n: Node) -> bool: return n is VirtualCamera and n.is_entry_camera())
	if vcs.is_empty():
		push_warning("Entry camera is not found! Returning...")
		return
	
	entry_camera = vcs[0]

	set_transitioning(true)
	
	get_current_controller().exit_controller()
	main_camera_controller.set_available_virtual_cameras(available_virtual_cameras)
	main_camera.set_follow_target(entry_camera)
	next_controller.enter_controller()
	await main_camera.transition_finished

	set_current_controller(next_controller)

	set_transitioning(false)
	transition_finished.emit()
# ========== ========== ========== ==========

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"path": get_path(),
			"parent": get_parent().get_path(),
		},
		"on_init": {
			"i_current_controller": STUtil.get_index_in_group("persist", get_current_controller().parent),
		},
		"on_ready": {}
	}

func on_load_init(data: Dictionary) -> void:
	set_current_controller(data["i_current_controller"])

func on_load_ready(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========
