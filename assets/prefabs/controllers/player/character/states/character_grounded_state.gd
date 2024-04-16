extends CharacterBaseState

func process(delta: float) -> void:
    super(delta)
    if _handle_jump(): return
    if _handle_fall(): return

func _handle_fall() -> bool:
    var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
    if flat_vel.y < 0:
        parent.switch_state(parent.States.FALL)
        return true
    return false

func _handle_jump() -> bool:
    if Input.is_action_just_pressed("character_jump"):
        parent.switch_state(parent.States.JUMP)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.water_damping if character.is_submerged() else character.ground_damping