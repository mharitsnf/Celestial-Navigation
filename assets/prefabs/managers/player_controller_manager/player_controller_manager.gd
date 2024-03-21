class_name PlayerControllerManager extends Node

var previous_controller: PlayerController
@export var current_controller: PlayerController
var controllers: Array[PlayerController]

@export var player_character_pscn: PackedScene
var player_character: CharacterEntity

var main_camera: MainCamera
var main_camera_controller: MainCameraController

var _transitioning: bool = false
signal transition_finished

# ========== Built-in functions ==========
func _enter_tree() -> void:
	if !is_in_group("player_controller_manager"):
		add_to_group("player_controller_manager")
	main_camera = STUtil.get_only_node_in_group("main_camera")
	main_camera_controller = STUtil.get_only_node_in_group("main_camera_controller")

func _process(delta: float) -> void:
	_get_enter_exit_ship_input()
	
	if current_controller:
		current_controller.process(delta)

func _physics_process(delta: float) -> void:
	if current_controller:
		current_controller.physics_process(delta)
# ========== ========== ========== ==========

# ========== Setter and getters ==========
func add_controller(value: PlayerController) -> void:
	controllers.append(value)

func remove_controller(value: PlayerController) -> void:
	controllers.erase(value)

func get_current_controller() -> PlayerController:
	return current_controller

func set_current_controller(value: PlayerController) -> void:
	current_controller = value

func is_transitioning() -> bool:
	return _transitioning

func set_transitioning(value: bool) -> void:
	_transitioning = value
# ========== ========== ========== ==========

# ========== Enter and exit ship ==========
func _get_next_controller() -> PlayerController:
	if is_transitioning(): return current_controller
	for c: PlayerController in controllers:
		if c == current_controller: continue
		return c
	return current_controller

func _switch_controller(next_controller: PlayerController) -> void:
	if is_transitioning(): return
	if next_controller == current_controller: return
	if !main_camera.get_follow_target() is ThirdPersonCamera: return

	var available_virtual_cameras: Array[Node] = STUtil.get_nodes_in_group(next_controller.parent.name + "VCs")
	if available_virtual_cameras.is_empty(): return

	var third_person_camera: ThirdPersonCamera
	var tpcs: Array = available_virtual_cameras.filter(func (n: Node) -> bool: return n is ThirdPersonCamera)
	if tpcs.is_empty(): return
	third_person_camera = tpcs[0]

	set_transitioning(true)
	set_current_controller(null)

	main_camera_controller.set_available_virtual_cameras(available_virtual_cameras)
	main_camera.set_follow_target(third_person_camera)
	await main_camera.transition_finished

	set_current_controller(next_controller)
	set_transitioning(false)
	transition_finished.emit()
# ========== ========== ========== ==========

# ========== Input functions ==========
func _get_enter_exit_ship_input() -> void:
	if !is_transitioning() and Input.is_action_just_pressed("enter_ship"):
		if current_controller is PlayerBoatController:
			if !player_character: player_character = player_character_pscn.instantiate()
			add_child(player_character)
			player_character.global_position = current_controller.dropoff_point.global_position

		previous_controller = current_controller
		var next_controller: PlayerController = _get_next_controller()
		_switch_controller(next_controller)
		await transition_finished

		if previous_controller is PlayerCharacterController:
			remove_child(player_character)
# ========== ========== ========== ==========
