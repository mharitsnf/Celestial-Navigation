extends PlayerController

var boat_controller: PlayerBoatEntity
var rotate_input: float

var time_hud: TimeHUD

func process(delta: float) -> bool:
	if !super(delta): return false
	_get_switch_to_boat_input()
	_get_rotate_latitude_measure_input()
	_get_rotate_sundial_input()
	_get_reset_sundial_rotation_input()
	if parent is SundialManager:
		parent.rotate_latitude_measurement(rotate_input, delta)
	return true

func _ready() -> void:
	super()
	boat_controller = STUtil.get_only_node_in_group("player_boat")
	time_hud = STUtil.get_only_node_in_group("time_hud")

# ========== PlayerCharacterState functions ==========
func enter_controller() -> void:
	super()
	time_hud.get_node("Controller").show_hud()

func exit_controller() -> void:
	time_hud.get_node("Controller").hide_hud()
# ========== ========== ========== ==========

# ========== Input functions ==========
func _get_rotate_latitude_measure_input() -> void:
	rotate_input = Input.get_axis("latitude_measure_left", "latitude_measure_right")

func _get_rotate_sundial_input() -> void:
	if Input.is_action_just_pressed("sundial_left"):
		if parent is SundialManager:
			parent.rotate_sundial(-1)
	elif Input.is_action_just_pressed("sundial_right"):
		if parent is SundialManager:
			parent.rotate_sundial(1)

func _get_reset_sundial_rotation_input() -> void:
	if Input.is_action_just_pressed("reset_sundial_rotation"):
		if parent is SundialManager:
			parent.reset_sundial_rotation()

func _get_switch_to_boat_input() -> void:
	if manager.is_switchable() and Input.is_action_just_pressed("switch_sundial_controller"):
		manager.switch_current_player_object(manager.PlayerObjectEnum.BOAT)
# ========== ========== ========== ==========
