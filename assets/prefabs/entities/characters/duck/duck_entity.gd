class_name DuckEntity extends CharacterEntity

@export_group("Horizontal Movement")
@export var sprint_speed_limit: float

var sprinting: bool
var speed_limit_value: float

func is_sprinting() -> bool:
    return sprinting

func set_sprinting(value: bool) -> void:
    sprinting = value

func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
    var current_limit: float = submerged_speed_limit if is_submerged() else (speed_limit if !is_sprinting() else sprint_speed_limit)
    speed_limit_value = lerp(speed_limit_value, current_limit, state.step * 5.)

    var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
    var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)

    var new_vel: Vector3 = flat_vel

    if _move_input == Vector2.ZERO:
        # if !is_on_slope():
        new_vel *= 1. - flat_drag
        new_vel.y = flat_vel.y

    if xz_vel.length() > speed_limit_value:
        new_vel = xz_vel.normalized() * speed_limit_value
        new_vel.y = flat_vel.y

    state.linear_velocity = basis * new_vel