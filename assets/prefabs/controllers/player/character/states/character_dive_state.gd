extends PlayerCharacterState


func process(_delta: float) -> void:
    if _handle_boosted_fly(): return
    if _handle_fall(): return
    if _handle_grounded(): return

func _process(_delta: float) -> void:
    if _handle_grounded(): return

func physics_process(delta: float) -> void:
    super(delta)
    character.dive()

func _handle_boosted_fly() -> bool:
    if Input.is_action_just_pressed("character_flap"):
        parent.switch_state(parent.States.BOOSTED_FLY)
        return true
    return false

func _handle_fall() -> bool:
    if Input.is_action_just_released("character_dive"):
        parent.switch_state(parent.States.FALL)
        return true
    return false

func _handle_grounded() -> bool:
    if parent.get_current_state() != self: return false
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func enter_state() -> void:
    character.linear_damp = character.air_damping
    character.gravity_scale = character.default_gravity_scale
    character.set_diving(true)

func exit_state() -> void:
    character.set_diving(false)