class_name BoatEntity extends BaseEntity

const ROTATION_WEIGHT: float = .01
@export var rotation_speed : float = 1

# ========== Movement functions ==========
func _adjust_damping() -> void:
	if depth_from_ocean_surface > .1:
		linear_damp = .8
	else:
		linear_damp = 0

func rotate_boat(amount : float, delta: float) -> void:
	var new_rotation: float = normal_container.rotation.y + (delta * rotation_speed * amount * ROTATION_WEIGHT)
	normal_container.rotation.y = lerp(normal_container.rotation.y, new_rotation, .75)

func gas(amount : float) -> void:
	apply_force(visual_container.global_basis.z * move_force * amount)

const BRAKE_POWER: float = 2.
func brake(amount : float) -> void:
	var flat_vel : Vector3 = basis.inverse() * linear_velocity
	var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
	if xz_vel.length() < 0.01: return
	var dir: Vector3 = basis * xz_vel
	apply_force(-dir.normalized() * move_force * amount * BRAKE_POWER)
# ========== ========== ========== ==========
