class_name FirstPersonCamera extends VirtualCamera

@export_group("Positioning")
@export var lerp_weight : float = 10
@export var _offset : Vector3
@export_group("References")
@export var offset_node : Node3D # Offset placement node
@export var gimbal : Node3D # For rotation in local Y
@export var inner_gimbal : Node3D # For rotation in local X

var type_transitioning: bool = false
var fpc_index: int = 0
var fpc_types: Array[Node]
var current_fpc_type: FPCType
var camera_mask: CameraMask
var sun_moon_path: SunMoonPath

# ========== Built in functions ==========
func _ready() -> void:
    super()
    _init_fpc_type()
    camera_mask = STUtil.get_only_node_in_group("camera_mask")
    sun_moon_path = STUtil.get_only_node_in_group("sun_moon_path")

func _process(delta: float) -> void:
    super(delta)
    _lerp_gimbal_position(delta)
# ========== ========== ========== ==========

# ========== Rotation settings ==========
func _lerp_gimbal_position(delta: float) -> void:
    offset_node.position = lerp(offset_node.position, _offset, lerp_weight * delta)

func rotate_camera(direction : Vector2, min_angle: float = min_x_angle, max_angle: float = max_x_angle) -> void:
    direction *= -1.
    gimbal.rotate_object_local(Vector3.UP, direction.x * rotation_speed)
    inner_gimbal.rotate_object_local(Vector3.RIGHT, direction.y * rotation_speed)
    inner_gimbal.rotation_degrees.x = clamp(
        inner_gimbal.rotation_degrees.x,
        min_angle,
        max_angle
    )

func get_x_rotation() -> float:
    return gimbal.rotation.y

func get_y_rotation() -> float:
    return inner_gimbal.rotation.y

func copy_rotation(x_rotation: float, y_rotation: float) -> void:
    gimbal.rotation.y = x_rotation
    inner_gimbal.rotation.x = y_rotation
# ========== ========== ========== ==========

# ========== FPC type functions ==========
func _init_fpc_type() -> void:
    fpc_types = STUtil.get_nodes_in_group(String(get_path()) + "/FPCTypes")
    if fpc_types.size() == 0:
        push_warning("No FPCTypes are found!")
        return
    current_fpc_type = fpc_types[0]

func is_type_transitioning() -> bool:
    return type_transitioning

func set_type_transitioning(value: bool) -> void:
    type_transitioning = value

func get_current_fpc_type() -> FPCType:
    return current_fpc_type

func set_current_fpc_type(value: FPCType) -> void:
    if value == get_current_fpc_type(): return
    if !value: return
    set_type_transitioning(true)
    current_fpc_type = value
    if value is FPCCamera:
        sun_moon_path.hide_path()
        await camera_mask.to_camera_mask()
    elif value is FPCSextant:
        sun_moon_path.show_path()
        await camera_mask.to_sextant_mask()
    set_type_transitioning(false)

func _reset_fpc_type() -> void:
    fpc_index = 0
    if fpc_types.size() == 0:
        push_warning("fpc_types is empty")
        return
    set_current_fpc_type(fpc_types[0])

func get_next_fpc_type() -> FPCType:
    if fpc_types.size() == 0:
        push_warning("fpc_types is empty")
        return null
    fpc_index = (fpc_index + 1) % fpc_types.size()
    return fpc_types[fpc_index]
# ========== ========== ========== ==========