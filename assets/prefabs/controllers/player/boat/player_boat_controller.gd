class_name PlayerBoatController extends PlayerController

@export_group("References")
@export var dropoff_point: Marker3D
@export_group("Packed Scene")
@export var player_character_pscn: PackedScene
var player_character: CharacterEntity

var gas_particles: Array[Node]

var move_input : float
var brake_input : float
var rotate_input : float

func process(delta: float) -> bool:
	if !super(delta): return false
	_get_gas_input()
	_get_brake_input()
	_get_rotate_input()
	_get_exit_ship_input()
	_get_switch_sundial_controller_input()
	if parent is PlayerBoatEntity:
		parent.rotate_boat(rotate_input, delta)
		parent.rotate_propeller(move_input, delta)
	return true

func physics_process(delta: float) -> bool:
	if !super(delta): return false
	if parent is BoatEntity:
		parent.gas(move_input)
		parent.brake(brake_input)
	return true

# =============== Inputs ===============
func _get_gas_input() -> void:
	move_input = Input.get_action_strength("boat_forward")

	if parent is PlayerBoatEntity:
		if move_input > 0 and !parent.is_gas_particles_active():
			parent.show_gas_particles()
		elif move_input <= 0:
			parent.hide_gas_particles()

func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat_brake")

func _get_rotate_input() -> void:
	rotate_input = Input.get_axis("boat_right", "boat_left")

func _get_exit_ship_input() -> void:
	if manager.is_switchable() and Input.is_action_just_pressed("enter_ship"):
		manager.set_spawn_position(dropoff_point.global_position)
		manager.switch_current_player_object(manager.PlayerObjectEnum.CHARACTER)
		# if !player_character: player_character = player_character_pscn.instantiate()
		# var next_controller: PlayerController = player_character.get_node("Controller")
		# manager.add_child(player_character)
		# player_character.global_position = dropoff_point.global_position

		# manager.switch_controller(next_controller)

func _get_switch_sundial_controller_input() -> void:
	if manager.is_switchable() and Input.is_action_just_pressed("switch_sundial_controller"):
		manager.switch_current_player_object(manager.PlayerObjectEnum.SUNDIAL)
		# var sundial_controller: PlayerController = STUtil.get_only_node_in_group("sundial_manager").get_node("Controller")
		# manager.switch_controller(sundial_controller)
# =============== =============== ===============
