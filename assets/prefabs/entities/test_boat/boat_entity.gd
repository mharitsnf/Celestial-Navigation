class_name BoatEntity extends BaseEntity

const ROTATION_WEIGHT : float = .0001
@export var rotation_speed : float = 1

# ========== Movement functions ==========
func _adjust_damping() -> void:
    if depth_from_ocean_surface > .1:
        linear_damp = .8
    else:
        linear_damp = 0

func rotate_boat(amount : float) -> void:
    visual_container.rotate(visual_container.basis.y, ROTATION_WEIGHT * rotation_speed * amount)

func gas(amount : float) -> void:
    apply_force(visual_container.global_basis.z * move_force * amount)

func brake(amount : float) -> void:
    var flat_vel : Vector3 = basis.inverse() * linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
    if xz_vel.length() < 0.01: return
    apply_force(-xz_vel.normalized() * move_force * amount)
# ========== ========== ========== ==========
