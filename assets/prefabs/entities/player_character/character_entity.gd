class_name CharacterEntity extends BaseEntity

@export var tpc: ThirdPersonCamera

func move(direction: Vector3) -> void:
	apply_force(direction * move_force)

const VISUAL_CONTAINER_ROTATION_WEIGHT: float = 5.
func rotate_visual_container(look_dir: Vector3, delta: float) -> void:
	visual_container.global_basis = visual_container.global_basis.slerp(Basis.looking_at(look_dir, basis.y), delta * VISUAL_CONTAINER_ROTATION_WEIGHT)