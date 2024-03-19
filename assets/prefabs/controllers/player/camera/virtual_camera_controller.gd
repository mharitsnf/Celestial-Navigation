extends Node

@export_group("Joypad direction")
@export var joypad_inverted_x: bool
@export var joypad_inverted_y: bool
@export_group("Mouse direction")
@export var mouse_inverted_x: bool
@export var mouse_inverted_y: bool
var parent: VirtualCamera
var direction: Vector2 = Vector2.ZERO

# ========== Built-in functions ==========
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    parent = get_parent()

func _process(_delta: float) -> void:
    _rotate_joypad()

    parent.rotate_camera(direction)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _rotate_mouse(event)
# ========== ========== ========== ==========

# ========== Input functions ==========
func _rotate_mouse(event : InputEventMouseMotion) -> void:
    if !_is_mouse_allowed(): return
    direction = event.relative * .001
    direction.x *= int(mouse_inverted_x) * 2 - 1
    direction.y *= int(mouse_inverted_y) * 2 - 1

func _rotate_joypad() -> void:
    if !_is_joypad_allowed(): return
    direction = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_down", "rotate_camera_up")
    direction.x *= int(joypad_inverted_x) * 2 - 1
    direction.y *= int(joypad_inverted_y) * 2 - 1
    direction *= .01
# ========== ========== ========== ==========

# ========== Error checks ==========
## Error checks for mouse input
func _is_mouse_allowed() -> bool:
    if !is_parent_active(): return false
    if !STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
    return true

## Error checks for joypad input
func _is_joypad_allowed() -> bool:
    if !is_parent_active(): return false
    if STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
    return true

func is_parent_active() -> bool:
    if !parent.main_camera: return false
    return parent.main_camera.get_follow_target() == parent
# ========== ========== ========== ==========
