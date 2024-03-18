class_name BoatEntity extends BaseEntity

const ROTATION_WEIGHT : float = .01
@export var rotation_speed : float = 1
@export var speed_limit : float = 20
@export var move_force : float = 1

# ========== Built-in functions ==========
func _physics_process(delta: float) -> void:
    super(delta)
    move_boat(1)
    print(linear_velocity.length())

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    super(state)
    _limit_speed(state)
# ========== ========== ========== ==========

# ========== Movement functions ==========
func rotate_boat(amount : float) -> void:
    visual_container.rotate(visual_container.basis.y, ROTATION_WEIGHT * rotation_speed * amount)

func move_boat(amount : float) -> void:
    apply_force(basis.z * move_force * amount)

func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
    var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
    if xz_vel.length() > speed_limit:
        var new_vel : Vector3 = xz_vel.normalized() * speed_limit
        new_vel.y = flat_vel.y
        state.linear_velocity = basis * new_vel
# ========== ========== ========== ==========
