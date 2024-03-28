class_name PlayerCharacterController extends PlayerController

var _current_state: State
var player_boat: BoatEntity
var player_boat_in_area: bool = false

func _ready() -> void:
	super()
	# For testing
	switch_state(get_child(0))

func process(delta: float) -> bool:
	if !super(delta): return false
	if _current_state:
		_current_state.process(delta)
	_get_enter_ship_input()
	return true

func physics_process(delta: float) -> bool:
	if !super(delta): return false
	if _current_state:
		_current_state.physics_process(delta)
	return true

func switch_state(new_state: State) -> void:
	if _current_state:
		_current_state.exit_state()
	
	_current_state = new_state
	_current_state.enter_state()

func _get_enter_ship_input() -> void:
	if !player_boat_in_area: return
	if !manager.is_transitioning() and Input.is_action_just_pressed("enter_ship"):
		var next_controller: PlayerController = player_boat.get_node("Controller")
		manager.switch_controller(next_controller)
		await manager.transition_finished
		manager.remove_child(parent)

func _on_player_boat_area_entered(area:Area3D) -> void:
	if area.get_parent() is BoatEntity:
		player_boat_in_area = true
		player_boat = area.get_parent()

func _on_player_boat_area_exited(area:Area3D) -> void:
	if area.get_parent() is BoatEntity:
		player_boat_in_area = false
		player_boat = null