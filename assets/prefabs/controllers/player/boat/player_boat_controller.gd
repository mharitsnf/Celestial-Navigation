class_name PlayerBoatController extends Node

var move_input : float
var brake_input : float
var rotate_input : float
var parent : BoatEntity

func _ready() -> void:
    parent = get_parent()

func _process(_delta: float) -> void:
    _get_gas_input()
    _get_brake_input()
    _get_rotate_input()

    parent.rotate_boat(rotate_input)

func _physics_process(_delta: float) -> void:
    parent.boat_gas(move_input)
    parent.boat_brake(brake_input)

func _get_gas_input() -> void:
    move_input = Input.get_action_strength("boat_forward")

func _get_brake_input() -> void:
    brake_input = Input.get_action_strength("boat_brake")

func _get_rotate_input() -> void:
    rotate_input = Input.get_axis("boat_right", "boat_left")