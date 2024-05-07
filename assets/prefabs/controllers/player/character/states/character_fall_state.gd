extends PlayerCharacterState

@export var coyote_time: float = .25

var fall_duration: float = 0

func process(delta: float) -> void:
    if _handle_jump(): return
    if _handle_grounded(): return
    fall_duration += delta

func _handle_grounded() -> bool:
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func _handle_jump() -> bool:
    if fall_duration < coyote_time and Input.is_action_just_pressed("character_jump"):
        parent.switch_state(parent.States.JUMP)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.air_damping

func exit_state() -> void:
    fall_duration = 0