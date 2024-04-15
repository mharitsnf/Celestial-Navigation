class_name CharacterBaseState extends CharacterState

func process(delta: float) -> void:
	_handle_move_and_rotate(delta)

func _handle_move_and_rotate(delta: float) -> void:
	var raw_move_dir: Vector2 = _get_move_direction()
	var ref: Node3D = fpc.gimbal if fpc.is_active() else tpc.gimbal
	
	var move_dir: Vector3
	var used_basis: Basis
	if character.is_on_slope():
		used_basis = STUtil.get_basis_from_normal(ref.global_basis, character.get_ground_checker().get_collision_normal())
		move_dir = used_basis.z * raw_move_dir.y + used_basis.x * raw_move_dir.x
	else:
		used_basis = ref.global_basis
		move_dir = used_basis.z * raw_move_dir.y + used_basis.x * raw_move_dir.x
	move_dir = move_dir.normalized()
	
	character.move(move_dir)

	if raw_move_dir != Vector2.ZERO:
		character.rotate_visual_container(character.basis.inverse() * move_dir, delta)