class_name FPCController extends VirtualCameraController

@export var zoom_speed: float = 1.
var zoom_amount: float = 0.
var camera_mask: CameraMask

# ========== Built in functions ==========
func _enter_tree() -> void:
	super()

func _ready() -> void:
	super()
	camera_mask = STUtil.get_only_node_in_group("camera_mask")
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(delta: float) -> void:
	super(delta)
	_zoom_joypad()
	if parent.get_current_function():
		parent.get_current_function().process(delta)

func unhandled_input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseButton:
		_zoom_mouse(event)
# ========== ========== ========== ==========

# ========== Enter and exit functions ==========
func enter_camera() -> void:
	if !camera_mask:
		push_warning("Camera mask is not found") 
		return
	camera_mask.show_mask()

func exit_camera() -> void:
	if !camera_mask:
		push_warning("Camera mask is not found") 
		return
	camera_mask.hide_mask()
# ========== ========== ========== ==========

# ========== Input functions ==========
func _zoom_joypad() -> void:
	if !_is_joypad_allowed(): return
	if Input.is_action_pressed("zoom_toggle"):
		zoom_amount = Input.get_axis("zoom_in", "zoom_out") * zoom_speed
		_update_parent_fov()

func _zoom_mouse(event: InputEventMouseButton) -> void:
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
