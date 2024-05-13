class_name DuckEntity extends CharacterEntity

@export_group("Horizontal Movement")
@export var sprint_speed_limit: float = 10.
@export var fly_speed_limit: float = 15.
@export var fly_move_force: float = 15.
@export var boost_force: float = 15.
@export_group("Vertical Movement")
@export var boosted_fly_damping: float = .5
@export var flap_force: float = 15.
@export var dive_force: float = 15.
@export var fly_gravity_scale: float = .5
@export var default_gravity_scale: float = .5

const MAX_FLIGHT_ALTITUDE: float = 75.
var altitude_scale: float = 0.
var flying: bool

var diving: bool

var sprinting: bool
var speed_limit_value: float

func _process(_delta: float) -> void:
    _calculate_altitude_scale()

func is_flying() -> bool:
    return flying

func set_flying(value: bool) -> void:
    flying = value

func is_diving() -> bool:
    return diving

func set_diving(value: bool) -> void:
    diving = value

func is_sprinting() -> bool:
    return sprinting

func set_sprinting(value: bool) -> void:
    sprinting = value

func _calculate_altitude_scale() -> void:
    altitude_scale = 1. - remap(get_height_from_ocean_surface(), 0., 75., 0., 1.)
    altitude_scale = STUtil.ease_out_quart(altitude_scale)

func move(direction: Vector3) -> void:
    var force: float = move_force
    if is_flying(): force = fly_move_force
    apply_force(direction * force)

func flap() -> void:
    apply_central_impulse(basis.y * flap_force * altitude_scale)

func boost(direction: Vector3) -> void:
    apply_central_impulse(direction * boost_force)

func dive() -> void:
    apply_force(-basis.y * ProjectSettings.get_setting("physics/3d/default_gravity"))

func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
    if is_diving(): return

    # Determine which speed limit to use
    var current_limit: float = speed_limit
    if is_sprinting(): current_limit = sprint_speed_limit
    if is_flying(): current_limit = fly_speed_limit
    if is_submerged(): current_limit = submerged_speed_limit
    speed_limit_value = lerp(speed_limit_value, current_limit, state.step * 5.)

    # Extract the flat velocities
    var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
    var y_vel: float = flat_vel.y

    if _move_input == Vector2.ZERO:
        xz_vel *= 1. - flat_drag
    else:
        if is_flying():
            if abs(y_vel) > speed_limit: y_vel = sign(y_vel) * speed_limit
        if xz_vel.length() > speed_limit_value:
            xz_vel = xz_vel.normalized() * speed_limit_value
    
    var new_flat_vel: Vector3 = Vector3(xz_vel.x, y_vel, xz_vel.z)

    state.linear_velocity = basis * new_flat_vel

    # print(get_height_from_ocean_surface())
    # print(state.linear_velocity.length())
    # print(y_vel)