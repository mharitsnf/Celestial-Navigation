extends PlayerController

var boat_controller: PlayerBoatEntity
var rotate_input: float

func process(delta: float) -> bool:
    if !super(delta): return false
    _get_switch_to_boat_input()
    _get_rotate_input()
    if parent is SundialManager:
        parent.rotate_latitude_measurement(rotate_input, delta)
    return true

func _ready() -> void:
    super()
    boat_controller = STUtil.get_only_node_in_group("player_boat")

func _get_rotate_input() -> void:
    rotate_input = Input.get_axis("sundial_left", "sundial_right")

func _get_switch_to_boat_input() -> void:
    if manager.is_switchable() and Input.is_action_just_pressed("switch_sundial_controller"):
        var next_controller: PlayerController = boat_controller.get_node("Controller")
        manager.switch_controller(next_controller)