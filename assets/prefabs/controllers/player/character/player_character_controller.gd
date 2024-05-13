class_name PlayerCharacterController extends PlayerController

var _previous_state: PlayerCharacterState
var _current_state: PlayerCharacterState
var player_boat: BoatEntity
var player_boat_in_area: bool = false

enum States {
	GROUNDED, JUMP, FALL
}

var states: Dictionary = {
	States.GROUNDED: null,
	States.JUMP: null,
	States.FALL: null
}

func _ready() -> void:
	super()
	_init_states()

	# For testing
	switch_state(States.GROUNDED)

func _init_states() -> void:
	states[States.GROUNDED] = get_node("Grounded")
	states[States.JUMP] = get_node("Jump")
	states[States.FALL] = get_node("Fall")

func get_state(key: States) -> PlayerCharacterState:
	return states[key]

func get_current_state() -> PlayerCharacterState:
	return _current_state

func get_previous_state() -> PlayerCharacterState:
	return _previous_state

func process(delta: float) -> bool:
	if !super(delta): return false
	_get_move_direction()
	if _current_state:
		_current_state.process(delta)
	_get_enter_ship_input()
	return true

func physics_process(delta: float) -> bool:
	if !super(delta): return false
	if _current_state:
		_current_state.physics_process(delta)
	return true

func switch_state(new_state_key: States) -> void:
	var new_state: PlayerCharacterState = get_state(new_state_key)

	if _current_state:
		_current_state.exit_state()
		_previous_state = _current_state
	
	_current_state = new_state
	_current_state.enter_state()

const STOP_WEIGHT: float = 10.
func _handle_idle(_delta: float) -> void:
	if is_active(): return
	if parent is CharacterEntity:
		parent.set_move_input(Vector2.ZERO)

func _get_move_direction() -> void:
	var move_input: Vector2 = Input.get_vector("character_left", "character_right", "character_forward", "character_backward")
	if parent is CharacterEntity:
		parent.set_move_input(move_input)

# Override from PlayerController
func _get_start_interact_input() -> void:
	super()

func _get_enter_ship_input() -> void:
	if !player_boat_in_area: return
	if manager.is_switchable() and Input.is_action_just_pressed("enter_ship"):
		manager.set_should_unmount(true)
		manager.switch_current_player_object(manager.PlayerObjectEnum.BOAT)

func _on_player_boat_area_entered(area:Area3D) -> void:
	player_boat_in_area = true
	player_boat = area.get_parent().get_parent()

func _on_player_boat_area_exited(_area:Area3D) -> void:
	player_boat_in_area = false
	player_boat = null
