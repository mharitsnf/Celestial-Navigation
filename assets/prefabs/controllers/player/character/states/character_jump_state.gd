extends CharacterBaseState

@export var jump_force: float = 30
@export var ground_checker: RayCast3D

const IGNORE_FRAME_COUNT: int = 5
var frame_count: int = 0

func process(delta: float) -> void:
    super(delta)
    _handle_grounded()
    _handle_fall()
    frame_count += 1

func _handle_fall() -> void:
    var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
    if flat_vel.y < 0 and frame_count > IGNORE_FRAME_COUNT:
        parent.switch_state(parent.States.FALL)

func _handle_grounded() -> void:
    if character.is_grounded() and frame_count > IGNORE_FRAME_COUNT:
        parent.switch_state(parent.States.GROUNDED)

func enter_state() -> void:
    character.linear_damp = character.air_damping
    character.apply_central_impulse(character.basis.y * jump_force)

func exit_state() -> void:
    frame_count = 0