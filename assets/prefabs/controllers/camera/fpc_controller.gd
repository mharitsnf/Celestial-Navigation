class_name FPCController extends VirtualCameraController

@export var zoom_speed: float = 1.
var current_fpc_type: FPCType
var zoom_amount: float = 0.
var camera_mask: CameraMask

# ========== Built in functions ==========
func _enter_tree() -> void:
    super()
    current_fpc_type = get_child(0)

func _ready() -> void:
    super()
    camera_mask = STUtil.get_only_node_in_group("camera_mask")
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(delta: float) -> void:
    super(delta)
    _zoom_joypad()
    _handle_change_fpc_type()

    if current_fpc_type:
        current_fpc_type.process(delta)

func unhandled_input(event: InputEvent) -> void:
    super(event)
    if event is InputEventMouseButton:
        _zoom_mouse(event)
# ========== ========== ========== ==========

# ========== FPC Type functions ==========
func _handle_change_fpc_type() -> void:
    if Input.is_action_just_pressed("change_fpc_type"):
        var next_fpc_type: FPCType = _get_next_fpc_type()
        set_current_fpc_type(next_fpc_type)

func get_current_fpc_type() -> FPCType:
    return current_fpc_type

func set_current_fpc_type(value: FPCType) -> void:
    current_fpc_type = value
    
    if current_fpc_type is FPCCamera:
        camera_mask.to_camera_mask()
    elif current_fpc_type is FPCSextant:
        camera_mask.to_sextant_mask()

func _get_next_fpc_type() -> FPCType:
    for fpct: Node in get_children():
        if fpct is FPCType:
            if fpct == get_current_fpc_type(): continue
            return fpct
    return get_current_fpc_type()
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

func _on_main_camera_follow_target_changed(_target: VirtualCamera) -> void:
    camera_mask.to_camera_mask()
