class_name FirstPersonCamera extends VirtualCamera

@export_group("Positioning")
@export var lerp_weight : float = 10
@export var _offset : Vector3
@export_group("References")
@export var offset_node : Node3D # Offset placement node
@export var gimbal : Node3D # For rotation in local Y
@export var inner_gimbal : Node3D # For rotation in local X

var fpc_functions: Array[FPCFunction]
var current_function: FPCFunction
var current_function_index: int = 0

var camera_mask: CameraMask
var sun_moon_path: SunMoonPath

# ========== Built in functions ==========
func _ready() -> void:
    # super()
    camera_mask = STUtil.get_only_node_in_group("camera_mask")
    sun_moon_path = STUtil.get_only_node_in_group("sun_moon_path")

    if !fpc_functions.is_empty():
        current_function = fpc_functions[current_function_index]

func _process(delta: float) -> void:
    super(delta)
    _lerp_gimbal_position(delta)
# ========== ========== ========== ==========

# ========== FPC function settings ==========
func next_function() -> void:
    current_function_index = (current_function_index + 1) % fpc_functions.size()
    current_function = fpc_functions[current_function_index]

func get_current_function() -> FPCFunction:
    return current_function

func add_function(value: FPCFunction) -> void:
    fpc_functions.append(value)

func remove_function(value: FPCFunction) -> void:
    fpc_functions.erase(value)
# ========== ========== ========== ==========

# ========== Rotation settings ==========
func _lerp_gimbal_position(delta: float) -> void:
    offset_node.position = lerp(offset_node.position, _offset, lerp_weight * delta)

func rotate_camera(direction : Vector2) -> void:
    direction *= -1.
    gimbal.rotate_object_local(Vector3.UP, direction.x * rotation_speed)
    inner_gimbal.rotate_object_local(Vector3.RIGHT, direction.y * rotation_speed)
    var min_angle: float = default_angle.x if !is_submerged() else submerged_angle.x
    var max_angle: float = default_angle.y if !is_submerged() else submerged_angle.y
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
    var min_angle: float = default_angle.x if !is_submerged() else submerged_angle.x
    var max_angle: float = default_angle.y if !is_submerged() else submerged_angle.y
    inner_gimbal.rotation_degrees.x = clamp(
        inner_gimbal.rotation_degrees.x,
        min_angle,
        max_angle
    )
# ========== ========== ========== ==========