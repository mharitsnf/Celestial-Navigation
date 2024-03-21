class_name PlayerBoatController extends PlayerController

var move_input : float
var brake_input : float
var rotate_input : float

func process(_delta: float) -> void:
    _get_gas_input()
    _get_brake_input()
    _get_rotate_input()

    if parent is BoatEntity:
        parent.rotate_boat(rotate_input)

func physics_process(_delta: float) -> void:
    if parent is BoatEntity:
        parent.gas(move_input)
        parent.brake(brake_input)

func _get_gas_input() -> void:
    move_input = Input.get_action_strength("boat_forward")

func _get_brake_input() -> void:
    brake_input = Input.get_action_strength("boat_brake")

func _get_rotate_input() -> void:
    rotate_input = Input.get_axis("boat_right", "boat_left")