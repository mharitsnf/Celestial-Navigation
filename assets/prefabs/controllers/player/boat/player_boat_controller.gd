class_name PlayerBoatController extends PlayerController

@export_group("Propeller settings")
@export var propeller_rotation_speed: float
@export_group("References")
@export var dropoff_point: Marker3D
@export var properllers: Array[MeshInstance3D]
@export var gas_particle_parent: Node3D
@export_group("Packed Scene")
@export var player_character_pscn: PackedScene
var player_character: CharacterEntity

var gas_particles: Array[Node]

var move_input : float
var brake_input : float
var rotate_input : float

func _ready() -> void:
	super()
	gas_particles = gas_particle_parent.get_children()

func process(delta: float) -> bool:
	if !super(delta): return false
	_get_gas_input()
	_get_brake_input()
	_get_rotate_input(delta)
	_get_exit_ship_input()
	_update_propeller_rotation(delta)
	if parent is BoatEntity:
		parent.rotate_boat(rotate_input)
	return true

func physics_process(delta: float) -> bool:
	if !super(delta): return false
	if parent is BoatEntity:
		parent.gas(move_input)
		parent.brake(brake_input)
	return true

# =============== Gas Particles ===============
func is_gas_particles_active() -> bool:
	if gas_particles.is_empty(): return false
	return gas_particles[0].emitting

func show_gas_particles() -> void:
	for p: Node in gas_particles:
		if p is GPUParticles3D:
			p.emitting = true

func hide_gas_particles() -> void:
	for p: Node in gas_particles:
		if p is GPUParticles3D:
			p.emitting = false
# =============== =============== ===============

# =============== Propeller ===============
func _ease_in_sine(x: float) -> float:
	return 1. - cos((x * PI) / 2.)

func _update_propeller_rotation(delta: float) -> void:
	var move_input_scale: float = _ease_in_sine(move_input)
	for prop: MeshInstance3D in properllers:
		prop.rotate_object_local(Vector3.FORWARD, delta * propeller_rotation_speed * move_input_scale)

# =============== Inputs ===============
func _get_gas_input() -> void:
	move_input = Input.get_action_strength("boat_forward")
	# Handle particles
	if move_input > 0 and !is_gas_particles_active():
		show_gas_particles()
	elif move_input == 0:
		hide_gas_particles()

func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat_brake")

const ROTATE_TO_ZERO_WEIGHT: float = 2.
func _get_rotate_input(delta: float) -> void:
	if parent.linear_velocity.length() > 0.:
		var value: float = Input.get_axis("boat_right", "boat_left")
		var rotation_scale: float = remap(parent.linear_velocity.length(), 0., parent.speed_limit, 0., 1.)
		rotate_input = value * rotation_scale
	else:
		rotate_input = lerp(rotate_input, 0., delta * ROTATE_TO_ZERO_WEIGHT)

func _get_exit_ship_input() -> void:
	if manager.can_switch() and Input.is_action_just_pressed("enter_ship"):
		if !player_character: player_character = player_character_pscn.instantiate()
		var next_controller: PlayerController = player_character.get_node("Controller")
		manager.add_child(player_character)
		player_character.global_position = dropoff_point.global_position

		manager.switch_controller(next_controller)
# =============== =============== ===============
