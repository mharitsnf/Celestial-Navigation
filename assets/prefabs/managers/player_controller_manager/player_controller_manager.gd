class_name PlayerControllerManager extends Node

class PlayerObject extends RefCounted:
	var pscn: PackedScene
	var controller: PlayerController
	var instance: Node = null
	func _init(_pscn: PackedScene) -> void:
		pscn = _pscn
	func set_existing_instance(_instance: Node) -> void:
		instance = _instance
		controller = instance.get_node("Controller")
	func create_instance() -> void:
		if get_instance(): return
		instance = pscn.instantiate()
		controller = instance.get_node("Controller")
	func get_controller() -> PlayerController:
		return controller
	func get_instance() -> Node:
		return instance

enum PlayerObjectEnum {
	NONE, BOAT, CHARACTER, SUNDIAL
}
@export var should_instantiate_dict: Dictionary = {
	PlayerObjectEnum.BOAT: false,
	PlayerObjectEnum.CHARACTER: false,
	PlayerObjectEnum.SUNDIAL: false
}
var player_object_dict: Dictionary = {
	PlayerObjectEnum.BOAT: PlayerObject.new(preload("res://assets/prefabs/entities/player_boat/player_boat.tscn")),
	PlayerObjectEnum.CHARACTER: PlayerObject.new(preload("res://assets/prefabs/entities/player_character/player_character_entity.tscn")),
	PlayerObjectEnum.SUNDIAL: PlayerObject.new(preload("res://assets/prefabs/planetary/sundial/sundial_manager.tscn"))

}
var current_player_object: PlayerObject

var ocean: Ocean
var main_camera: MainCamera
var main_camera_controller: MainCameraController
var _transitioning: bool = false
signal transition_finished

# ========== Built in functions ==========
func _ready() -> void:
	await get_tree().process_frame
	_setup_objects()
	ocean = STUtil.get_only_node_in_group("ocean")
	_setup_cameras()
	if !has_current_player_object():
		_init_player_object(PlayerObjectEnum.BOAT)

func _process(delta: float) -> void:
	if has_current_player_object() and get_current_player_controller():
		get_current_player_controller().process(delta)

func _physics_process(delta: float) -> void:
	if has_current_player_object() and get_current_player_controller():
		get_current_player_controller().physics_process(delta)
# =============================================

# ========== Setups ==========
func _init_player_object(po_enum: PlayerObjectEnum) -> void:
	current_player_object = player_object_dict[po_enum]

func _setup_cameras() -> void:
	main_camera = STUtil.get_only_node_in_group("main_camera")
	main_camera_controller = STUtil.get_only_node_in_group("main_camera_controller")

# Instantiate player objects if it should instantiate
func _setup_objects() -> void:
	# Find if we have existing child of player object. If so, add the instance to the dict.
	for child: Node in get_children():
		var existing_po: Array = player_object_dict.values().filter(func(_po: PlayerObject) -> bool: return _po.pscn.resource_path == child.scene_file_path)
		if existing_po.is_empty(): continue
		if existing_po[0] is PlayerObject:
			existing_po[0].set_existing_instance(child)

	for key: PlayerObjectEnum in should_instantiate_dict.keys():
		if should_instantiate_dict[key]: player_object_dict[key].create_instance()
# =============================================

# ========== Setter and getters ==========
func has_current_player_object() -> bool:
	return current_player_object != null

func get_current_player_object_enum() -> PlayerObjectEnum:
	if !has_current_player_object(): return PlayerObjectEnum.NONE
	var items: Array = player_object_dict.values().filter(func(_po: PlayerObject) -> bool: return _po == current_player_object)
	if items.is_empty(): return PlayerObjectEnum.NONE
	return player_object_dict.find_key(items[0])

func get_current_player_object() -> Node:
	return current_player_object.get_instance()

func get_current_player_controller() -> PlayerController:
	return current_player_object.get_controller()
# =============================================

# ========== Switching functions ==========
func is_switchable() -> bool:
	if is_transitioning(): return false
	if !main_camera.get_follow_target().is_entry_camera(): return false
	return true

func is_transitioning() -> bool:
	return _transitioning

func set_transitioning(value: bool) -> void:
	_transitioning = value

func _remove_current_player_object(should_unmount: bool = false) -> void:
	if !current_player_object:
		push_error("There is no current player object.")
		return
	if should_unmount:
		remove_child(current_player_object.get_instance())
	current_player_object = null

var _spawn_position: Vector3
func set_spawn_position(value: Vector3) -> void:
	_spawn_position = value

var _should_unmount: bool
func set_should_unmount(value: bool) -> void:
	_should_unmount = value

func switch_current_player_object(new_enum: PlayerObjectEnum) -> void:
	if new_enum == PlayerObjectEnum.NONE:
		_remove_current_player_object(_should_unmount)
		return # if change to nothing, return early.

	var new_player_object: PlayerObject = player_object_dict[new_enum]
	if !new_player_object.get_instance(): new_player_object.create_instance()
	if new_player_object.get_instance().get_parent() != self:
		add_child(new_player_object.get_instance())
		if new_player_object.get_instance() is Node3D and _spawn_position != Vector3.ZERO:
			new_player_object.get_instance().global_position = _spawn_position

	var available_virtual_cameras: Array[Node] = STUtil.get_nodes_in_group(String(new_player_object.get_instance().get_path()) + "/VCs")
	if available_virtual_cameras.is_empty():
		push_warning("Available virtual camera is empty! Returning...")
		remove_child(new_player_object.get_instance())
		return

	var entry_camera: VirtualCamera
	var vcs: Array = available_virtual_cameras.filter(func (n: Node) -> bool: return n is VirtualCamera and n.is_entry_camera())
	if vcs.is_empty():
		push_warning("Entry camera is not found! Returning...")
		remove_child(new_player_object.get_instance())
		return
	entry_camera = vcs[0]

	set_transitioning(true)
	if get_current_player_controller(): get_current_player_controller().exit_controller()

	main_camera_controller.set_available_virtual_cameras(available_virtual_cameras)
	entry_camera.copy_rotation(main_camera.get_follow_target().get_x_rotation(), main_camera.get_follow_target().get_y_rotation())
	main_camera.set_follow_target(entry_camera)

	if new_player_object.get_instance() is RigidBody3D and ocean.get_target() != new_player_object.get_instance():
		ocean.switch_target(new_player_object.get_instance())

	new_player_object.get_controller().enter_controller()
	
	await main_camera.transition_finished
	
	_remove_current_player_object(_should_unmount)
	current_player_object = new_player_object
	
	set_transitioning(false)
	set_spawn_position(Vector3.ZERO)
	set_should_unmount(false)
# =============================================

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"path": get_path(),
			"parent": get_parent().get_path(),
		},
		"on_init": {
			"current_player_object_enum": get_current_player_object_enum()
		},
		"on_ready": {}
	}

func on_preprocess(data: Dictionary) -> void:
	_init_player_object(data["current_player_object_enum"])

# func on_load_init(data: Dictionary) -> void:
# 	_init_player_object(data["current_player_object_enum"])

func on_load_ready(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========