@tool
class_name Ocean extends MeshInstance3D

@export var _target : Node3D:
    set(value):
        _target = value
        _reset_initial_position_and_offset(value)
@export_group("Wave data")
@export var wave_data_1 : Vector4
@export var wave_data_2 : Vector4
@export var speed : float = 1.

var default_initial_position : Vector3 = Vector3(0,STUtil.PLANET_RADIUS,0)
## Flat initial position
var initial_position : Vector3 = default_initial_position
## Flat offset
var offset : Vector3 = Vector3.ZERO
var time_elapsed : float = 0.
var shader : ShaderMaterial

# ========== Built-in functions ==========
func _enter_tree() -> void:
    if !is_in_group("ocean"):
        add_to_group("ocean")

func _ready() -> void:
    shader = get_active_material(0)

func _process(delta: float) -> void:
    time_elapsed += delta
    _calculate_offset()
    _update_shader_params()
# ========== ========== ========== ========== ==========

func get_time_elapsed() -> float:
    return time_elapsed

func get_speed() -> float:
    return speed

# ========== Target and offset functions ==========
func get_target() -> Node3D:
    return _target

func set_target(new_target : Node3D) -> void:
    _target = new_target

func get_offset() -> Vector3:
    return offset

func _reset_initial_position_and_offset(new_target : Node3D) -> void:
    if !is_inside_tree(): return
    if new_target: initial_position = _target.basis.inverse() * _target.global_position
    else: initial_position = default_initial_position
    offset = Vector3.ZERO

func _calculate_offset() -> void:
    if !_target: return
    var current_flat_pos : Vector3 = _target.basis.inverse() * _target.global_position
    offset = current_flat_pos - initial_position
# ========== ========== ========== ========== ==========

# ========== Shader functions ==========
func _update_shader_params() -> void:
    if !shader: return

    shader.set_shader_parameter("cpu_time", time_elapsed)
    shader.set_shader_parameter("movement_offset", offset)
    shader.set_shader_parameter("wave_1", wave_data_1)
    shader.set_shader_parameter("wave_2", wave_data_2)
    shader.set_shader_parameter("speed", speed)
    if mesh is PlaneMesh and mesh.size.x == mesh.size.y:
        shader.set_shader_parameter("plane_size", mesh.size.x)
    if _target:
        shader.set_shader_parameter("target_world_position", _target.global_position)
        shader.set_shader_parameter("target_up", _target.basis.y)
        shader.set_shader_parameter("target_right", _target.basis.x)
        shader.set_shader_parameter("target_fwd", _target.basis.z)
# ========== ========== ========== ========== ==========
    