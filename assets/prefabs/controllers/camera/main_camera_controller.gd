class_name MainCameraController extends Node

var available_virtual_cameras: Array
var parent: MainCamera

# ========== Built-in functions ==========
func _enter_tree() -> void:
	if !is_in_group("main_camera_controller"):
		add_to_group("main_camera_controller")
	parent = get_parent()

func _ready() -> void:
	available_virtual_cameras = STUtil.get_nodes_in_group(parent.get_follow_target().get_parent().name + "VCs")

func _process(_delta: float) -> void:
	_switch_camera()
# ========== ========== ========== ==========

# ========== Available VCs ==========
func set_available_virtual_cameras(value: Array) -> void:
	available_virtual_cameras = value

func get_available_virtual_cameras() -> Array:
	return available_virtual_cameras
# ========== ========== ========== ==========

# ========== Switching ==========
func _get_next_virtual_camera() -> VirtualCamera:
	if parent.is_transitioning(): return parent.get_follow_target()
	for vc: Node in available_virtual_cameras:
		if vc is VirtualCamera:
			if vc == parent.get_follow_target(): continue
			return vc
	return parent.get_follow_target()

func _switch_camera() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		var next_camera: VirtualCamera = _get_next_virtual_camera()
		parent.set_follow_target(next_camera)
# ========== ========== ========== ==========
