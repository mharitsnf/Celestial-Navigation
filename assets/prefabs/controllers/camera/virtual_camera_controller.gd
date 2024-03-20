class_name VirtualCameraController extends Node

@export var rotation_speed: float = 1.
@export_group("Joypad direction")
@export var joypad_inverted_x: bool
@export var joypad_inverted_y: bool
@export_group("Mouse direction")
@export var mouse_inverted_x: bool
@export var mouse_inverted_y: bool
var parent: VirtualCamera

# ========== Built-in functions ==========
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    parent = get_parent()

func _process(_delta: float) -> void:
    _rotate_joypad()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _rotate_mouse(event)
# ========== ========== ========== ==========

# ========== Input functions ==========
const MOUSE_ROTATION_WEIGHT: float = .001
func _rotate_mouse(event : InputEventMouseMotion) -> void:
    if !_is_mouse_allowed(): return
    var direction: Vector2 = event.relative * MOUSE_ROTATION_WEIGHT * rotation_speed
    direction.x *= int(mouse_inverted_x) * 2 - 1
    direction.y *= int(mouse_inverted_y) * 2 - 1
    parent.rotate_camera(direction)

const JOYPAD_ROTATION_WEIGHT: float = .01
func _rotate_joypad() -> void:
    if !_is_joypad_allowed(): return
    var direction: Vector2 = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_down", "rotate_camera_up") * JOYPAD_ROTATION_WEIGHT * rotation_speed
    direction.x *= int(joypad_inverted_x) * 2 - 1
    direction.y *= int(joypad_inverted_y) * 2 - 1
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