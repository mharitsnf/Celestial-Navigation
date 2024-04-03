class_name BaseEntity extends RigidBody3D

@export_group("Movement")
@export var speed_limit : float = 20
@export var move_force : float = 1
@export_group("Local References")
@export var normal_container : Node3D
@export var visual_container : Node3D
@export_group("Buoyancy")
## If ticked, the collision shape will follow the ocean's normal, making the object appear to be following the ocean surface.
@export var _update_normal : bool = true
@export_range(0., 1., .01) var water_drag : float = .1
@export var float_force : float = 5.

@export var ocean_surface_offset : float = 0.
var ocean : Ocean
var depth_from_ocean_surface : float = 0.

# ========== Built-in functions ==========
func _ready() -> void:
	ocean = STUtil.get_only_node_in_group("ocean")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.transform.basis = STUtil.recalculate_basis(self)
	_calculate_depth_to_ocean_surface(state)
	_dampen_velocity(state)
	_apply_buoyancy_force()
	_limit_speed(state)
# ========== ========== ========== ==========

# ========== Setters and Getters ==========
func get_visual_container() -> Node3D:
	return visual_container

func get_normal_container() -> Node3D:
	return normal_container
# ========== ========== ========== ==========

# ========== Movement ==========
func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
	var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
	var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
	if xz_vel.length() > speed_limit:
		var new_vel : Vector3 = xz_vel.normalized() * speed_limit
		new_vel.y = flat_vel.y
		state.linear_velocity = basis * new_vel
# ========== ========== ========== ==========

# ========== Buoyancy functions ==========
class GerstnerResult extends RefCounted:
	var vertex : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.UP
	var tangent : Vector3 = Vector3.RIGHT
	var binormal : Vector3 = Vector3.BACK
	func _init(_vertex : Vector3, _normal : Vector3, _tangent : Vector3, _binormal : Vector3) -> void:
		vertex = _vertex
		normal = _normal
		tangent = _tangent
		binormal = _binormal

func is_submerged() -> bool:
	return depth_from_ocean_surface > 0.

func _update_collision_normal(normal : Vector3) -> void:
	if !_update_normal: return

	var new_up : Vector3 = normal
	var old_basis : Basis = normal_container.basis

	var quat : Quaternion = Quaternion(old_basis.y, new_up).normalized()
	var new_right : Vector3 = quat * old_basis.x
	var new_fwd : Vector3 = quat * old_basis.z

	normal_container.basis = Basis(new_right, new_up, new_fwd).orthonormalized()

func _dampen_velocity(state: PhysicsDirectBodyState3D) -> void:
	if depth_from_ocean_surface > 0.:
		var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
		flat_vel.y *= 1. - water_drag
		state.linear_velocity = basis * flat_vel

func _apply_buoyancy_force() -> void:
	if depth_from_ocean_surface > 0.:
		apply_central_force(global_basis.y * float_force * ProjectSettings.get_setting("physics/3d/default_gravity") * depth_from_ocean_surface)

## Calculate depth to ocean surface (linear)
func _calculate_depth_to_ocean_surface(state: PhysicsDirectBodyState3D) -> void:
	if !ocean:
		push_error("Ocean is not defined")
		return
	if !ocean.get_target():
		push_error("Ocean target is not defined")
		return

	var linear_offset : Vector3 = _calculate_offset_to_ocean_target()
	var gerstner_result : GerstnerResult = _calculate_total_gerstner(linear_offset)
	var flat_position : Vector3 = state.transform.basis.inverse() * global_position
	var water_height : float = STUtil.PLANET_RADIUS + ocean_surface_offset + gerstner_result.vertex.y
	depth_from_ocean_surface = water_height - flat_position.y

	_update_collision_normal(gerstner_result.normal)

func _calculate_offset_to_ocean_target() -> Vector3:
	var ocean_target : Node3D = ocean.get_target()
	if ocean_target == self:
		return Vector3.ZERO

	var ocean_target_basis : Basis = ocean_target.basis
	var my_lin_pos : Vector3 = ocean_target_basis.inverse() * global_position
	var ocean_target_lin_pos : Vector3 = ocean_target_basis.inverse() * ocean_target.global_position
	var vertex : Vector3 = my_lin_pos - ocean_target_lin_pos
	return Vector3(vertex.x, 0, vertex.z)

func _calculate_total_gerstner(vertex : Vector3) -> GerstnerResult:
	var tangent : Vector3 = Vector3(1., 0., 0.)
	var binormal : Vector3 = Vector3(0., 0., 1.)
	var gerstner_vertex : Vector3 = ocean.get_offset() + vertex

	var gerstner_res : GerstnerResult = _calculate_gerstner(ocean.wave_data_1, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_res = _calculate_gerstner(ocean.wave_data_2, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_vertex -= ocean.get_offset()
	var normal : Vector3 = binormal.cross(tangent).normalized()
	return GerstnerResult.new(gerstner_vertex, normal, tangent, binormal)

func _calculate_gerstner(wave_data : Vector4, vertex : Vector3) -> GerstnerResult:
	var steepness : float = wave_data.x
	var wavelength : float = wave_data.y
	var direction : Vector2 = Vector2(wave_data.z, wave_data.w)

	var k : float = 2. * PI / wavelength;
	var c : float = sqrt(9.8 / k);
	var d : Vector2 = direction.normalized();
	# var f : float = k * (d.dot(Vector2(vertex.x, vertex.z)) - (ocean_plane.elapsed_time * c * ocean_plane.speed))
	var f : float = k * (d.dot(Vector2(vertex.x, vertex.z)) - (ocean.get_time_elapsed() * c * ocean.get_speed()))
	var a : float = steepness / k

	var d_tangent : Vector3 = Vector3(
		- d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)), 
		- d.x * d.y * (steepness * sin(f))
	)

	var d_binormal : Vector3 = Vector3(
		- d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		- d.y * d.y * (steepness * sin(f))
	)

	var d_vert : Vector3 = Vector3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	)

	return GerstnerResult.new(d_vert, Vector3.UP, d_tangent, d_binormal)
# ========== ========== ========== ==========

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"parent": get_parent().get_path(),
		},
		"on_init": {},
		"on_ready": {
			"gpos_x": global_position.x,
			"gpos_y": global_position.y,
			"gpos_z": global_position.z,
		}
	}

func on_load_ready(data: Dictionary) -> void:
	global_position = Vector3(data["gpos_x"], data["gpos_y"], data["gpos_z"])
	basis = STUtil.recalculate_basis(self)

func on_load_init(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========
