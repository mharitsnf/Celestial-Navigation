extends PlayerCharacterState

func _process(_delta: float) -> void:
    if _handle_grounded(): return

func _handle_grounded() -> bool:
    if parent.get_current_state() != self: return false
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.boosted_fly_damping
    character.gravity_scale = 0.
    character.set_diving(true)

func exit_state() -> void:
    character.gravity_scale = character.default_gravity_scale
    character.set_diving(false)