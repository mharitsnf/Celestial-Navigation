class_name FPCController extends VirtualCameraController

@export var zoom_speed: float = 1.
var zoom_amount: float = 0.

# ========== Input functions ==========
func zoom_joypad() -> void:
    if !_is_joypad_allowed(): return
    if Input.is_action_pressed("zoom_toggle"):
        zoom_amount = Input.get_axis("zoom_in", "zoom_out") * zoom_speed
        _update_parent_fov()

func zoom_mouse(event: InputEventMouseButton) -> void:
    if !_is_mouse_allowed(): return
    if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        zoom_amount = -1 * zoom_speed
        _update_parent_fov()
    elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        zoom_amount = 1 * zoom_speed
        _update_parent_fov()

func _update_parent_fov() -> void:
    var current_fov: float = parent.get_fov()
    parent.set_fov(current_fov + zoom_amount)
# ========== ========== ========== ==========
