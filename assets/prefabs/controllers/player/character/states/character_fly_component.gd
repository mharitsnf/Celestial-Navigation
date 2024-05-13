extends PlayerCharacterState

var vertical_move_input: float = 0.

func process(_delta: float) -> void:
    _get_vertical_input()
    if _handle_fall(): return

func _process(_delta: float) -> void:
    if _handle_grounded(): return

func _handle_fall() -> bool:
    if Input.is_action_just_pressed("character_dive"):
        parent.switch_state(parent.States.FALL)
        return true
    return false

func _handle_grounded() -> bool:
    # var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func _get_vertical_input() -> void:
    if Input.is_action_just_pressed("character_flap"):
        character.flap()
        character.boost(h_move_dir)

func enter_state() -> void:
    character.linear_damp = character.air_damping
    character.gravity_scale = 0.5
    character.set_flying(true)

    character.flap()
    character.boost(h_move_dir)

func exit_state() -> void:
    character.gravity_scale = 1
    character.set_flying(false)