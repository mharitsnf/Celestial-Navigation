extends PlayerCharacterState

@export var flap_cooldown_duration: float = 1.:
    set(value):
        flap_cooldown_duration = value
        if flap_timer: flap_timer.wait_time = value
var flap_timer: Timer

var vertical_move_input: float = 0.

func _ready() -> void:
    super()
    flap_timer = Timer.new()
    flap_timer.wait_time = flap_cooldown_duration
    flap_timer.one_shot = true
    flap_timer.autostart = false
    add_child.call_deferred(flap_timer)

func process(_delta: float) -> void:
    _get_flap_boost_input()
    if _handle_dive(): return

func _process(_delta: float) -> void:
    if _handle_grounded(): return

func _handle_dive() -> bool:
    if Input.is_action_just_pressed("character_dive"):
        parent.switch_state(parent.States.DIVE)
        return true
    return false

func _handle_grounded() -> bool:
    if parent.get_current_state() != self: return false
    if character.is_grounded() or character.is_submerged():
        parent.switch_state(parent.States.GROUNDED)
        return true
    return false

func _get_flap_boost_input() -> void:
    if flap_timer.is_stopped() and Input.is_action_pressed("character_flap"):
        character.flap()
        character.boost(h_move_dir)
        flap_timer.start()

func enter_state() -> void:
    character.linear_damp = character.air_damping
    character.gravity_scale = character.fly_gravity_scale
    character.set_flying(true)

    _calculate_h_move_dir()
    character.flap()
    character.boost(h_move_dir)

func exit_state() -> void:
    character.gravity_scale = character.default_gravity_scale
    character.set_flying(false)