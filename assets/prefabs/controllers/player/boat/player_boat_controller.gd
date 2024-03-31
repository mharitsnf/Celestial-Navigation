class_name PlayerBoatController extends PlayerController

@export var dropoff_point: Marker3D
@export var player_character_pscn: PackedScene
var player_character: CharacterEntity

var move_input : float
var brake_input : float
var rotate_input : float

func process(delta: float) -> bool:
    if !super(delta): return false
    _get_gas_input()
    _get_brake_input()
    _get_rotate_input()
    _get_exit_ship_input()
    if parent is BoatEntity:
        parent.rotate_boat(rotate_input)
    return true

func physics_process(delta: float) -> bool:
    if !super(delta): return false
    if parent is BoatEntity:
        parent.gas(move_input)
        parent.brake(brake_input)
    return true

func _get_gas_input() -> void:
    move_input = Input.get_action_strength("boat_forward")

func _get_brake_input() -> void:
    brake_input = Input.get_action_strength("boat_brake")

func _get_rotate_input() -> void:
    rotate_input = Input.get_axis("boat_right", "boat_left")

func _get_exit_ship_input() -> void:
    if manager.can_switch() and Input.is_action_just_pressed("enter_ship"):
        if !player_character: player_character = player_character_pscn.instantiate()
        var next_controller: PlayerController = player_character.get_node("Controller")
        manager.add_child(player_character)
        player_character.global_position = dropoff_point.global_position

        manager.switch_controller(next_controller)