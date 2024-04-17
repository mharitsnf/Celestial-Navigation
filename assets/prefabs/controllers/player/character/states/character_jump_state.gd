extends CharacterBaseState

@export var jump_force: float = 30

const IGNORE_FRAME_COUNT: int = 5
var frame_count: int = 0

func process(delta: float) -> void:
    super(delta)
    if _handle_grounded(): return
    if _handle_fall(): return
    frame_count += 1

func _handle_fall() -> bool:
    var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
    if flat_vel.y < 0.02 and frame_count > IGNORE_FRAME_COUNT:
        parent.switch_state(parent.States.FALL)
        return true
    return false

func _handle_grounded() -> bool:
    var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
    if character.is_grounded() and flat_vel.y < 0.02 and frame_count > IGNORE_FRAME_COUNT:
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.air_damping
    character.apply_central_impulse(character.basis.y * jump_force)

func exit_state() -> void:
    frame_count = 0