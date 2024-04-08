class_name MainCameraController extends Node

var available_virtual_camera_index: int = 0
var available_virtual_cameras: Array
var parent: MainCamera
var current_controller: VirtualCameraController

# ========== Built-in functions ==========
func _enter_tree() -> void:
	parent = get_parent()

func _ready() -> void:
	await get_tree().process_frame
	available_virtual_cameras = STUtil.get_nodes_in_group(String(parent.get_follow_target().get_target_group().get_path()) + "/VCs")

func _process(delta: float) -> void:
	if current_controller:
		current_controller.process(delta)
	_switch_camera()

func _unhandled_input(event: InputEvent) -> void:
	if current_controller:
		current_controller.unhandled_input(event)
# ========== ========== ========== ==========

# ========== Available VCs ==========
func set_available_virtual_cameras(value: Array) -> void:
	available_virtual_camera_index = 0
	available_virtual_cameras = value

func get_available_virtual_cameras() -> Array:
	return available_virtual_cameras
# ========== ========== ========== ==========

# ========== Switching ==========
func _get_next_virtual_camera() -> VirtualCamera:
	if parent.is_transitioning(): return parent.get_follow_target()
	if available_virtual_cameras.size() == 0:
		push_warning("available_virtual_camera is empty")
		return parent.get_follow_target()
	available_virtual_camera_index = (available_virtual_camera_index + 1) % available_virtual_cameras.size()
	var next_vc: VirtualCamera = available_virtual_cameras[available_virtual_camera_index]
	return next_vc

func _switch_camera() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		var next_camera: VirtualCamera = _get_next_virtual_camera()
		next_camera.copy_rotation(parent.get_follow_target().get_x_rotation(), parent.get_follow_target().get_y_rotation())
		parent.set_follow_target(next_camera)
# ========== ========== ========== ==========

# ========== Follow target changed ==========
func _on_follow_target_changed(target: VirtualCamera) -> void:
	if !target.has_node("Controller"):
		push_warning("The new virtual camera ", target, " has no controller!")
		current_controller = null
		return
	current_controller = target.get_node("Controller")
# ========== ========== ========== ==========
