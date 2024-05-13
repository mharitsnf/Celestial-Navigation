class_name PlayerVCC extends VirtualCameraController

@export_group("Rotation Settings")
@export var can_rotate: bool = true
@export var rotation_speed: float = 1.
@export_subgroup("Joypad direction")
@export var x_joypad_natural: bool
@export var y_joypad_natural: bool
@export_subgroup("Mouse direction")
@export var x_mouse_natural: bool
@export var y_mouse_natural: bool

func process(delta: float) -> void:
    _rotate_wrapper_joypad(delta)

func unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _rotate_wrapper_mouse(event)

const MOUSE_ROTATION_WEIGHT: float = .001
func _rotate_wrapper_mouse(event : InputEventMouseMotion) -> void:
    if !can_rotate: return
    if !_is_mouse_allowed(): return
    var direction: Vector2 = event.relative * MOUSE_ROTATION_WEIGHT * rotation_speed
    direction.x *= int(x_mouse_natural) * 2 - 1
    direction.y *= int(y_mouse_natural) * 2 - 1
    _rotate(direction)

const JOYPAD_ROTATION_WEIGHT: float = .01
func _rotate_wrapper_joypad(delta: float) -> void:
    if !can_rotate: return
    if !_is_joypad_allowed(): return
    var direction: Vector2 = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_down", "rotate_camera_up") * delta * rotation_speed
    direction.x *= int(x_joypad_natural) * 2 - 1
    direction.y *= int(y_joypad_natural) * 2 - 1
    _rotate(direction)

func _rotate(direction: Vector2) -> void:
    if parent.get_target_group() is BaseEntity:
        parent.set_submerged(parent.get_target_group().is_submerged())
    parent.rotate_camera(direction)

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