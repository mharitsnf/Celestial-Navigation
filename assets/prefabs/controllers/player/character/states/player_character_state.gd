class_name PlayerCharacterState extends Node

var tpc: ThirdPersonCamera
var fpc: FirstPersonCamera
var main_camera: MainCamera

var parent: PlayerCharacterController
var character: CharacterEntity

var raw_move_dir: Vector2

# =============== Lifecycle methods ===============
func _enter_tree() -> void:
	parent = get_parent()
	character = get_parent().get_parent()

func _ready() -> void:
	tpc = STUtil.get_node_in_group_by_name(String(character.get_path()) + "/VCs", "TPC")
	fpc = STUtil.get_node_in_group_by_name(String(character.get_path()) + "/VCs", "FPC")
	main_camera = STUtil.get_only_node_in_group("main_camera")

func enter_state() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	_handle_move_and_rotate(delta)

func exit_state() -> void:
	pass
# ==================================================

func _handle_move_and_rotate(delta: float) -> void:
	var ref: Node3D = fpc.y_gimbal if fpc.is_active() else tpc.y_gimbal

	var move_dir: Vector3
	var used_basis: Basis
	if character.is_on_slope():
		used_basis = STUtil.get_basis_from_normal(ref.global_basis, character.get_ground_normal())
		move_dir = used_basis.z * character.get_move_input().y + used_basis.x * character.get_move_input().x
	else:
		used_basis = ref.global_basis
		move_dir = used_basis.z * character.get_move_input().y + used_basis.x * character.get_move_input().x
	move_dir = move_dir.normalized()

	character.move(move_dir)

	if character.get_move_input() != Vector2.ZERO:
		character.rotate_visual_container(character.basis.inverse() * move_dir, delta)
