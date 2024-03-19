class_name BoatEntity extends BaseEntity

const ROTATION_WEIGHT : float = .0001
@export var rotation_speed : float = 1
@export var speed_limit : float = 20
@export var move_force : float = 1

# ========== Built-in functions ==========
func _process(_delta: float) -> void:
    _adjust_damping()
    # print(basis.inverse() * linear_velocity)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    super(state)
    _limit_speed(state)
# ========== ========== ========== ==========

# ========== Movement functions ==========
func _adjust_damping() -> void:
    if depth_from_ocean_surface > .1:
        linear_damp = .8
    else:
        linear_damp = 0

func rotate_boat(amount : float) -> void:
    visual_container.rotate(visual_container.basis.y, ROTATION_WEIGHT * rotation_speed * amount)

func boat_gas(amount : float) -> void:
    apply_force(visual_container.global_basis.z * move_force * amount)

func boat_brake(amount : float) -> void:
    var flat_vel : Vector3 = basis.inverse() * linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
    if xz_vel.length() < 0.01: return
    apply_force(-xz_vel.normalized() * move_force * amount)

func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
    var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
    if xz_vel.length() > speed_limit:
        var new_vel : Vector3 = xz_vel.normalized() * speed_limit
        new_vel.y = flat_vel.y
        state.linear_velocity = basis * new_vel
# ========== ========== ========== ==========
