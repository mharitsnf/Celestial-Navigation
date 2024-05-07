class_name CharacterEntity extends BaseEntity

@export_group("Movement")
@export var water_damping: float 
@export var ground_damping: float 
@export var air_damping: float 
@export_range(0., 1., 0.01) var flat_drag: float = .75
@export var max_slope_angle: float = 50.
@export var submerged_speed_limit: float = 3.
@export_group("References")
@export var ground_checker: RayCast3D

var _move_input: Vector2

func _limit_speed(state: PhysicsDirectBodyState3D) -> void:
	var limit: float = submerged_speed_limit if is_submerged() else speed_limit

	var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
	var xz_vel : Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
	
	var new_vel: Vector3 = flat_vel
	
	if _move_input == Vector2.ZERO:
		if !is_on_slope():
			new_vel *= 1. - flat_drag
			new_vel.y = flat_vel.y

	if xz_vel.length() > limit:
		new_vel = xz_vel.normalized() * limit
		new_vel.y = flat_vel.y
	
	state.linear_velocity = basis * new_vel

func set_move_input(value: Vector2) -> void:
	_move_input = value

func get_move_input() -> Vector2:
	return _move_input

func get_ground_checker() -> RayCast3D:
	return ground_checker

func is_grounded() -> bool:
	return ground_checker.is_colliding()

func get_ground_normal() -> Vector3:
	return ground_checker.get_collision_normal()

func is_on_slope() -> bool:
	if !ground_checker.is_colliding(): return false

	var angle: float = basis.y.dot(ground_checker.get_collision_normal())
	return angle >= max_slope_angle and angle < .95

func move(direction: Vector3) -> void:
	apply_force(direction * move_force)

const VISUAL_CONTAINER_ROTATION_WEIGHT: float = 5.
func rotate_visual_container(look_dir: Vector3, delta: float) -> void:
	look_dir = Vector3(look_dir.x, 0., look_dir.z).normalized()
	visual_container.basis = visual_container.basis.slerp(Basis.looking_at(look_dir, visual_container.basis.y), delta * VISUAL_CONTAINER_ROTATION_WEIGHT)