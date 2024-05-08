class_name VirtualCameraController extends Node

var parent: VirtualCamera

# ========== Built-in functions ==========
func _enter_tree() -> void:
    parent = get_parent()

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(_delta: float) -> void:
    pass

func unhandled_input(_event: InputEvent) -> void:
    pass
# ========== ========== ========== ==========

# ========== Enter and exit functions ==========
func enter_camera() -> void:
    pass

func exit_camera() -> void:
    pass
# ========== ========== ========== ==========
