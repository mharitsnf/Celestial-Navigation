extends PlayerCharacterState

const IGNORE_FRAME_COUNT: int = 5
var frame_count: int = 0

func process(_delta: float) -> void:
	# if _handle_fly(): return
	frame_count += 1

# Happens regardless the character is active or not
func _process(_delta: float) -> void:
	if _handle_grounded(): return
	if _handle_fall(): return

# func _handle_fly() -> bool:
# 	if !character.is_sprinting(): return false
# 	if frame_count < IGNORE_FRAME_COUNT: return false
	
# 	var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
# 	if flat_vel.y > .02: return false
	
# 	if Input.is_action_pressed("character_jump"):
# 		parent.switch_state(parent.States.FLY)
# 		return true
# 	return false

func _handle_fall() -> bool:
	if parent.get_current_state() != self: return false
	var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
	if flat_vel.y < 0.02 and frame_count > IGNORE_FRAME_COUNT:
		parent.switch_state(parent.States.FALL)
		return true
	return false

func _handle_grounded() -> bool:
	if parent.get_current_state() != self: return false
	var flat_vel: Vector3 = character.basis.inverse() * character.linear_velocity
	if character.is_grounded() and flat_vel.y < 0.02 and frame_count > IGNORE_FRAME_COUNT:
		parent.switch_state(parent.States.GROUNDED)
		return true
	return false

func enter_state() -> void:
	character.linear_damp = character.air_damping
	character.jump()

func exit_state() -> void:
	frame_count = 0
