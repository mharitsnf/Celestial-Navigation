class_name PlayerController extends Node

# Interactions
@export_group("First setup")
@export var should_setup_first_transform: bool = false
@export var first_position: Vector3
@export var first_rotation: Vector3
var first_setup_done: bool = false
@export_group("Interactions")
@export var interaction_scanner: Area3D
var interactions: Array
var current_interactable: Interactable
var current_track: InteractionTrack
var interacting: bool

var main_camera: MainCamera
var available_virtual_cameras: Array[Node]
var entry_cam: VirtualCamera
var entry_index: int = 0
var camera_index: int = 0

var ui_manager: UIManager
var manager: PlayerControllerManager
var parent: Node

# ========== Built ins ==========
func _enter_tree() -> void:
	parent = get_parent()
	manager = get_parent().get_parent()

	if interaction_scanner:
		if !interaction_scanner.area_entered.is_connected(_on_interactable_entered):
			interaction_scanner.area_entered.connect(_on_interactable_entered)
		if !interaction_scanner.area_exited.is_connected(_on_interactable_exited):
			interaction_scanner.area_exited.connect(_on_interactable_exited)

func _ready() -> void:
	ui_manager = STUtil.get_only_node_in_group("ui_manager")

	_setup_camera()

func process(_delta: float) -> bool:
	_get_start_interact_input()
	_switch_camera()
	return !(is_interacting() or ui_manager.has_current_ui()) # If interacting or has an active ui from other means (like opening menu), do not proceed

func physics_process(_delta: float) -> bool:
	return true
# ========== ========== ========== ==========

# ========== State functions ==========
func first_setup() -> void:
	if should_setup_first_transform:
		if parent is Node3D:
			parent.global_position = first_position
			parent.rotation_degrees = first_rotation
	first_setup_done = true

func enter_controller() -> void:
	_enter_entry_camera()

func exit_controller() -> void:
	pass
# ========== ========== ========== ==========

# ========== Camera ==========
func _setup_camera() -> void:
	main_camera = STUtil.get_only_node_in_group("main_camera")

	# find all cameras for this controller
	available_virtual_cameras = STUtil.get_nodes_in_group(String(parent.get_path()) + "/VCs")

	# find the entry camera
	var entry_cameras: Array[Node] = available_virtual_cameras.filter(
		func(c: Node) -> bool:
			if c is VirtualCamera:
				return c.is_entry_camera()
			return false
	)
	# Make sure entry camera is not empty
	assert(!entry_cameras.is_empty())
	if !entry_cameras.is_empty():
		entry_cam = entry_cameras[0]

	# find the entry index
	if entry_cam:
		entry_index = available_virtual_cameras.find(entry_cam, 0)
	
	# init camera indexing based on entry cam
	# 0 if no entry camera is found
	_reset_camera_index()

func _enter_entry_camera() -> void:
	print(entry_cam)
	_reset_camera_index()
	entry_cam.copy_rotation(main_camera.get_follow_target().get_x_rotation(), main_camera.get_follow_target().get_y_rotation())
	main_camera.set_follow_target(entry_cam)

func _reset_camera_index() -> void:
	camera_index = entry_index

func _get_next_virtual_camera() -> VirtualCamera:
	if main_camera.is_transitioning(): return main_camera.get_follow_target()
	if available_virtual_cameras.size() == 0:
		push_warning("available_virtual_camera is empty")
		return main_camera.get_follow_target()
	camera_index = (camera_index + 1) % available_virtual_cameras.size()
	var next_vc: VirtualCamera = available_virtual_cameras[camera_index]
	return next_vc

func _switch_camera() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		var controller: VirtualCameraController
		if main_camera.get_follow_target():
			controller = main_camera.get_follow_target().get_node("Controller")
			controller.exit_camera()

		var next_camera: VirtualCamera = _get_next_virtual_camera()
		controller = next_camera.get_node("Controller")
		controller.enter_camera()
		
		next_camera.copy_rotation(main_camera.get_follow_target().get_x_rotation(), main_camera.get_follow_target().get_y_rotation())
		main_camera.set_follow_target(next_camera)

# ========== ========== ========== 

# ========== Setters and getters ==========
func is_active() -> bool:
	return manager.get_current_controller() == self

func is_interacting() -> bool:
	return interacting

func set_interacting(value: bool) -> void:
	interacting = value
# ========== ========== ========== ==========

# ========== Interaction functions ==========
func _get_start_interact_input() -> void:
	if is_interacting() or interactions.is_empty() or ui_manager.has_current_ui(): return
	if Input.is_action_just_pressed("interact"):		
		if !_setup_interaction(): return
		_interact()

func _setup_interaction() -> bool:
	# Get the top interaction
	var top_node: Area3D = interactions.back()
	if top_node is Interactable:
		if !top_node.interaction:
			push_error("No interaction data was found!")
			return false
		current_interactable = top_node
		current_track = top_node.get_track()
		if !current_track:
			push_error("Interaction track not found!")
			_finish_interaction()
			return false
	return true

func _start_interaction() -> void:
	set_interacting(true)

func _finish_interaction() -> void:
	set_interacting(false)
	current_interactable = null
	current_track = null

func _interact() -> void:
	_start_interaction()
	for c: InteractionCommand in current_track.commands:
		await c.action(get_tree())
		if !c.auto_next:
			await ui_manager.get_current_controller().interact_pressed
			# await STUtil.interact_pressed
	current_interactable.handle_track_finished()
	_finish_interaction()

func _on_interactable_entered(area: Area3D) -> void:
	interactions.append(area)

func _on_interactable_exited(area: Area3D) -> void:
	interactions.erase(area)
# ========== ========== ========== ==========
