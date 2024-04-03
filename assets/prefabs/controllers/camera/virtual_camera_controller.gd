class_name VirtualCameraController extends Node

@export var submerged_min_angle: float = 0
@export var rotation_speed: float = 1.
@export_group("Joypad direction")
@export var joypad_inverted_x: bool
@export var joypad_inverted_y: bool
@export_group("Mouse direction")
@export var mouse_inverted_x: bool
@export var mouse_inverted_y: bool
var parent: VirtualCamera
var target_group: Node3D

# ========== Built-in functions ==========
func _enter_tree() -> void:
    parent = get_parent()
    target_group = get_parent().get_parent()
    if !parent.is_in_group(target_group.name + "VCs"):
        parent.add_to_group(target_group.name + "VCs")

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# ========== ========== ========== ==========

# ========== Target group functions ==========
func get_target_group() -> Node3D:
    return target_group
# ========== ========== ========== ==========

# ========== Input functions ==========
const MOUSE_ROTATION_WEIGHT: float = .001
func rotate_mouse(event : InputEventMouseMotion) -> void:
    if !_is_mouse_allowed(): return
    var direction: Vector2 = event.relative * MOUSE_ROTATION_WEIGHT * rotation_speed
    direction.x *= int(mouse_inverted_x) * 2 - 1
    direction.y *= int(mouse_inverted_y) * 2 - 1
    if get_target_group() is BaseEntity and get_target_group().is_submerged():
        parent.rotate_camera(direction, submerged_min_angle)
    else:
        parent.rotate_camera(direction)

const JOYPAD_ROTATION_WEIGHT: float = .01
func rotate_joypad() -> void:
    if !_is_joypad_allowed(): return
    var direction: Vector2 = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_down", "rotate_camera_up") * JOYPAD_ROTATION_WEIGHT * rotation_speed
    direction.x *= int(joypad_inverted_x) * 2 - 1
    direction.y *= int(joypad_inverted_y) * 2 - 1
    if get_target_group() is BaseEntity and get_target_group().is_submerged():
        parent.rotate_camera(direction, submerged_min_angle)
    else:
        parent.rotate_camera(direction)
# ========== ========== ========== ==========

# ========== Error checks ==========
## Error checks for mouse input
func _is_mouse_allowed() -> bool:
    if !parent.is_active(): return false
    if !STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
    return true

## Error checks for joypad input
func _is_joypad_allowed() -> bool:
    if !parent.is_active(): return false
    if STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
    return true
# ========== ========== ========== ==========
