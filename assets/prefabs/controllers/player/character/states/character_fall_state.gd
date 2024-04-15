extends CharacterBaseState

@export var ground_checker: RayCast3D

func process(delta: float) -> void:
    super(delta)
    _handle_grounded()

func _handle_grounded() -> void:
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)

func enter_state() -> void:
    character.linear_damp = character.air_damping