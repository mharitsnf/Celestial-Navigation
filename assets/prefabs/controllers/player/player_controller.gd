class_name PlayerController extends Node

# region Variables

# Interactions
@export_group("Interactions")
var interactions: Array
var current_interactable: Interactable
var current_track: InteractionTrack
var interacting: bool
signal interaction_started(owner: Node3D)
signal interaction_finished(owner: Node3D)

var main_camera: MainCamera
var available_virtual_cameras: Array[Node]
var all_virtual_cameras: Array[Node]
var entry_cam: VirtualCamera
var entry_index: int = 0
var camera_index: int = 0

var ui_manager: UIManager
var manager: PlayerControllerManager
var parent: Node

# region Lifecycle
# ========== Built ins ==========
func _enter_tree() -> void:
	parent = get_parent()
	manager = get_parent().get_parent()

func _ready() -> void:
	ui_manager = STUtil.get_only_node_in_group("ui_manager")

	_setup_camera()

func process(_delta: float) -> bool:
	_get_toggle_pause_menu_input()
	_get_start_interact_input()
	_get_switch_camera_input()
	return !(is_interacting() or ui_manager.has_current_ui()) # If interacting or has an active ui from other means (like opening menu), do not proceed

func _process(delta: float) -> void:
	_handle_idle(delta)

func physics_process(_delta: float) -> bool:
	return !(is_interacting() or ui_manager.has_current_ui())
# ========== ========== ========== ==========


# ========== PlayerCharacterState functions ==========
func enter_controller() -> void:
	_reset_camera_index()
	_enter_entry_camera()

func exit_controller() -> void:
	pass

func _handle_idle(_delta: float) -> void:
	pass
# ========== ========== ========== ==========

# region Camera 

# ========== Camera ==========
func _setup_camera() -> void:
	main_camera = STUtil.get_only_node_in_group("main_camera")

	# find all cameras for this controller
	all_virtual_cameras = STUtil.get_nodes_in_group(String(parent.get_path()) + "/VCs")
	available_virtual_cameras = STUtil.get_nodes_in_group(String(parent.get_path()) + "/SwitchableVCs")

	# find the entry camera
	entry_cam = STUtil.get_only_node_in_group(String(parent.get_path()) + "/EntryVC")
	assert(entry_cam)

	# find the entry index
	if entry_cam:
		entry_index = available_virtual_cameras.find(entry_cam, 0)
	
	# init camera indexing based on entry cam
	# 0 if no entry camera is found
	_reset_camera_index()

func _enter_entry_camera() -> void:
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

func _get_switch_camera_input() -> void:
	if !_is_input_allowed(): return
	if ui_manager.has_current_ui(): return

	if Input.is_action_just_pressed("switch_camera"):
		var next_camera: VirtualCamera = _get_next_virtual_camera()
		_switch_camera(next_camera)

func _switch_camera(next_camera: VirtualCamera) -> void:
	if !next_camera:
		push_error("No next camera provided!")
		return
	
	if next_camera == main_camera.get_follow_target():
		push_warning("Switching to the same camera: this camera is already active.")
		return

	var controller: VirtualCameraController = main_camera.get_follow_target_controller()
	if controller:
		controller.exit_camera()

	if next_camera.has_node("Controller"):
		controller = next_camera.get_node("Controller")
		controller.enter_camera()
	
	if next_camera.copy_rotation_on_enter:
		next_camera.copy_rotation(main_camera.get_follow_target().get_x_rotation(), main_camera.get_follow_target().get_y_rotation())
	
	main_camera.set_follow_target(next_camera)

# ========== ========== ========== 

# region State setter and getters

# ========== Setters and getters ==========
## Checks if the player is able to perform inputs.
func _is_input_allowed() -> bool:
	if is_interacting(): return false
	if main_camera.is_transitioning(): return false
	return true

## Checks if the current player controller is active or not.
func is_active() -> bool:
	if is_interacting() or ui_manager.has_current_ui(): return false
	return manager.get_current_controller() == self

func is_interacting() -> bool:
	return interacting

func set_interacting(value: bool) -> void:
	interacting = value
# ========== ========== ========== ==========

# region Interaction

# ========== Interaction functions ==========
func _get_toggle_pause_menu_input() -> void:
	if !_is_input_allowed(): return

	if Input.is_action_just_pressed("toggle_main_menu"):
		match ui_manager.get_current_ui_key():
			ui_manager.UIEnum.NONE:
				var mm_cam: VirtualCamera = STUtil.get_only_node_in_group(String(parent.get_path()) + "/MenuVC")
				_switch_camera(mm_cam)
				ui_manager.switch_current_ui(ui_manager.UIEnum.PAUSE_MENU)
			
			_:
				_switch_camera(entry_cam)
				ui_manager.switch_current_ui(ui_manager.UIEnum.NONE)

func _get_start_interact_input() -> void:
	if !_is_input_allowed(): return
	if ui_manager.has_current_ui(): return
	
	if Input.is_action_just_pressed("interact"):
		if !_setup_interaction(): return
		_interact()

func _setup_interaction() -> bool:
	# See interactions
	if interactions.is_empty():
		push_warning("Nothing to interact to")
		return false
	
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
	interaction_started.emit(current_interactable)

	var chat_cam: VirtualCamera = STUtil.get_only_node_in_group("/ChatVC")
	_switch_camera(chat_cam)

func _finish_interaction() -> void:
	interaction_finished.emit(current_interactable)

	current_interactable = null
	current_track = null
	_switch_camera(entry_cam)

	set_interacting(false)

func _interact() -> void:
	_start_interaction()
	
	for c: InteractionCommand in current_track.commands:
		await c.action(get_tree())
		
		# Continue immediately if the current command is the last one.
		var idx_c: int = current_track.commands.find(c)
		if idx_c > -1 and idx_c == current_track.commands.size()-1:
			continue
		
		# If command has property auto_next and it's inactive, wait for player to press sth.
		if "auto_next" in c and !c.auto_next:
			await ui_manager.get_current_controller().interact_pressed
	
	current_interactable.handle_track_finished()
	_finish_interaction()

func _on_interactable_entered(area: Area3D) -> void:
	interactions.append(area)

func _on_interactable_exited(area: Area3D) -> void:
	interactions.erase(area)
# ========== ========== ========== ==========
