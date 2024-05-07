extends PlayerCharacterState

func process(_delta: float) -> void:
	_update_linear_damp()
	if _handle_jump(): return
	if _handle_fall(): return

func _handle_fall() -> bool:
	if !character.is_grounded() and !character.is_submerged():
		parent.switch_state(parent.States.FALL)
		return true
	return false

func _handle_jump() -> bool:
	if Input.is_action_just_pressed("character_jump"):
		parent.switch_state(parent.States.JUMP)
		return true
	return false

func _update_linear_damp() -> void:
	character.linear_damp = character.water_damping if character.is_submerged() else character.ground_damping

func enter_state() -> void:
	_update_linear_damp()
