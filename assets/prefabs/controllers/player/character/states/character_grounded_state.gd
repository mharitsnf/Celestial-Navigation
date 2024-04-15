extends CharacterBaseState

func process(delta: float) -> void:
    super(delta)
    _handle_jump()

func _handle_jump() -> void:
    if Input.is_action_just_pressed("character_jump"):
        parent.switch_state(parent.States.JUMP)

func enter_state() -> void:
    character.linear_damp = character.water_damping if character.is_submerged() else character.ground_damping