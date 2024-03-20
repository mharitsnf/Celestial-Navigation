class_name MainCameraController extends Node

var parent: MainCamera
var fpc: FirstPersonCamera
var tpc: ThirdPersonCamera

# ========== Built-in functions ==========
func _ready() -> void:
    parent = get_parent()
    fpc = STUtil.get_node_in_group_by_name("virtual_cameras", "FirstPersonCamera")
    tpc = STUtil.get_node_in_group_by_name("virtual_cameras", "ThirdPersonCamera")

    parent.set_follow_target(tpc)

func _process(_delta: float) -> void:
    _switch_camera()
# ========== ========== ========== ==========

# ========== Switching ==========
func _switch_camera() -> void:
    if Input.is_action_just_pressed("switch_camera"):
        var cur_follow_target: VirtualCamera = parent.get_follow_target()
        if cur_follow_target == fpc:
            parent.set_follow_target(tpc)
        if cur_follow_target == tpc:
            parent.set_follow_target(fpc)
# ========== ========== ========== ==========
