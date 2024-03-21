class_name PlayerCharacterController extends PlayerController

var _current_state: State

func _ready() -> void:
	# For testing
	switch_state(get_child(0))

func process(delta: float) -> void:
	if _current_state:
		_current_state.process(delta)

func physics_process(delta: float) -> void:
	if _current_state:
		_current_state.physics_process(delta)

func switch_state(new_state: State) -> void:
	if _current_state:
		_current_state.exit_state()
	
	_current_state = new_state
	_current_state.enter_state()
