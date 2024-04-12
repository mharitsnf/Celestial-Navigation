class_name PlayerBoatEntity extends BoatEntity

@export_group("Propeller settings")
@export var propeller_rotation_speed: float
@export var propeller_start_weight: float
@export var propeller_stop_weight: float
@export_group("References")
@export var propellers: Array[MeshInstance3D]
@export var gas_particles: Array[GPUParticles3D]

var current_propeller_rotation_scale: float = 0

# =============== Propeller ===============
func rotate_propeller(move_input: float, delta: float) -> void:
	if move_input > 0:
		current_propeller_rotation_scale = lerp(current_propeller_rotation_scale, move_input, delta * propeller_start_weight)
	else:
		current_propeller_rotation_scale = lerp(current_propeller_rotation_scale, 0., delta * propeller_stop_weight)
	
	for prop: MeshInstance3D in propellers:
			prop.rotate_object_local(Vector3.FORWARD, delta * propeller_rotation_speed * current_propeller_rotation_scale)
# =============== =============== ===============

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
