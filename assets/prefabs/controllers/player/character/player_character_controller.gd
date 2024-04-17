class_name PlayerCharacterController extends PlayerController

var _previous_state: State
var _current_state: State
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

func _get_state(key: States) -> State:
	return states[key]

func get_current_state() -> State:
	return _current_state

func get_previous_state() -> State:
	return _previous_state

func process(delta: float) -> bool:
	if !super(delta): return false
	if _current_state:
		print(_current_state)
		_current_state.process(delta)
	_get_enter_ship_input()
	return true

func physics_process(delta: float) -> bool:
	if !super(delta): return false
	if _current_state:
		_current_state.physics_process(delta)
	return true

func switch_state(new_state_key: States) -> void:
	var new_state: State = _get_state(new_state_key)

	if _current_state:
		_current_state.exit_state()
		_previous_state = _current_state
	
	_current_state = new_state
	_current_state.enter_state()

func _get_enter_ship_input() -> void:
	if !player_boat_in_area: return
	if manager.is_switchable() and Input.is_action_just_pressed("enter_ship"):
		var next_controller: PlayerController = player_boat.get_node("Controller")
		manager.switch_controller(next_controller)
		await manager.transition_finished
		manager.remove_child(parent)

func _on_player_boat_area_entered(area:Area3D) -> void:
	player_boat_in_area = true
	player_boat = area.get_parent().get_parent()

func _on_player_boat_area_exited(_area:Area3D) -> void:
	player_boat_in_area = false
	player_boat = null