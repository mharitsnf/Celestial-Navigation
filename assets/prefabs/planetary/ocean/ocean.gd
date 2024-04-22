@tool
class_name Ocean extends MeshInstance3D

@export var _target : Node3D
@export_group("Wave data")
@export var wave_data_1 : Vector4
@export var wave_data_2 : Vector4
@export var wave_data_3 : Vector4
@export var wave_data_4 : Vector4
@export var wave_data_5 : Vector4
@export var speed : float = 1.

var target_world_pos: Vector3

var default_initial_position : Vector3 = Vector3(0,STUtil.PLANET_RADIUS,0)
## Flat initial position
var initial_position : Vector3 = default_initial_position
var initial_basis : Basis = Basis.IDENTITY
## Flat offset
var offset : Vector3 = Vector3.ZERO
var time_elapsed : float = 0.
var shader : ShaderMaterial

# ========== Built-in functions ==========
func _ready() -> void:
	shader = get_active_material(0)
	switch_target(_target)

func _process(delta: float) -> void:
	time_elapsed += delta
	_calculate_offset(delta)
	_update_shader_params()
# ========== ========== ========== ========== ==========

# ========== Time and speed functions ==========
func get_time_elapsed() -> float:
	return time_elapsed

func get_speed() -> float:
	return speed
# ========== ========== ========== ========== ==========

# ========== Target and offset functions ==========
func get_target() -> Node3D:
	return _target

func set_target(new_target : Node3D) -> void:
	_target = new_target

func get_offset() -> Vector3:
	return offset

func _update_target_world_position() -> void:
	if _target: target_world_pos = _target.global_position

func switch_target(new_target : Node3D) -> void:
	if !new_target.is_inside_tree():
		await new_target.tree_entered
	
	if new_target:
		if _target:
			pass
			# var target_flat_pos: Vector3 = _target.basis.inverse() * _target.global_position
			# target_flat_pos.y = 0
			# var new_target_flat_pos: Vector3 = new_target.basis.inverse() * new_target.global_position
			# new_target_flat_pos.y = 0
			# var offset_to_new_target: Vector3 = new_target_flat_pos - target_flat_pos
			# var tween: Tween = create_tween()
			# tween.tween_property(self, "offset", offset + offset_to_new_target, .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			# # offset += offset_to_new_target
		else:
			initial_basis = _target.basis.inverse()
			initial_position = initial_basis * _target.global_position
			initial_position.y = 0
			offset = Vector3.ZERO
	else:
		initial_basis = Basis.IDENTITY
		initial_position = default_initial_position

	_target = new_target

	# if new_target:
	# 	initial_basis = _target.basis.inverse()
	# 	initial_position = initial_basis * _target.global_position
	# 	initial_position.y = 0
	# else:
	# 	initial_basis = Basis.IDENTITY
	# 	initial_position = default_initial_position
	
	# offset = Vector3.ZERO

func _calculate_offset(delta: float) -> void:
	if !_target: return
	if _target is RigidBody3D:
		var flat_vel: Vector3 = _target.basis.inverse() * _target.linear_velocity
		var xz_vel: Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
		offset += xz_vel * delta
	else:
		var current_flat_pos : Vector3 = initial_basis * _target.global_position
		current_flat_pos.y = 0
		offset = current_flat_pos - initial_position
# ========== ========== ========== ========== ==========

# ========== Shader functions ==========
func _update_shader_params() -> void:
	if !shader: return

	shader.set_shader_parameter("cpu_time", time_elapsed)
	shader.set_shader_parameter("movement_offset", offset)
	shader.set_shader_parameter("wave_1", wave_data_1)
	shader.set_shader_parameter("wave_2", wave_data_2)
	shader.set_shader_parameter("wave_3", wave_data_3)
	shader.set_shader_parameter("wave_4", wave_data_4)
	shader.set_shader_parameter("wave_5", wave_data_5)
	shader.set_shader_parameter("speed", speed)
	if mesh is PlaneMesh and mesh.size.x == mesh.size.y:
		shader.set_shader_parameter("plane_size", mesh.size.x)
	if _target and is_instance_valid(_target):
		shader.set_shader_parameter("target_world_position", _target.global_position)
		shader.set_shader_parameter("target_up", _target.basis.y)
		shader.set_shader_parameter("target_right", _target.basis.x)
		shader.set_shader_parameter("target_fwd", _target.basis.z)
# ========== ========== ========== ========== ==========
	
# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"path": get_path(),
			"parent": get_parent().get_path(),
		},
		"on_init": {
			"i_target": STUtil.get_index_in_group("persist", get_target()),
		},
		"on_ready": {}
	}

func on_preprocess(data: Dictionary) -> void:
	switch_target(data["i_target"])

func on_load_ready(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========