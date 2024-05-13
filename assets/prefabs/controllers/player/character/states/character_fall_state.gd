extends PlayerCharacterState

@export var coyote_time: float = .25

var fall_duration: float = 0

func process(delta: float) -> void:
    if _handle_jump(): return
    # if _handle_fly(): return
    fall_duration += delta

# Happens regardless the character is active or not
func _process(_delta: float) -> void:
    if _handle_grounded(): return

func _handle_grounded() -> bool:
    if parent.get_current_state() != self: return false
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

# func _handle_fly() -> bool:
#     if fall_duration < coyote_time: return false
#     if character.is_sprinting() and Input.is_action_just_pressed("character_jump"):
#         parent.switch_state(parent.States.FLY)
#         return true
#     return false

func _handle_jump() -> bool:
    # Coyote jump only possible if the previous state is grounded
    if parent.get_previous_state() != parent.get_state(parent.States.GROUNDED): return false
    if fall_duration < coyote_time and Input.is_action_just_pressed("character_jump"):
        parent.switch_state(parent.States.JUMP)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.air_damping

func exit_state() -> void:
    fall_duration = 0