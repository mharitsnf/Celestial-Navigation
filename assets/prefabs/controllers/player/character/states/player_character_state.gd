class_name PlayerCharacterState extends Node

var tpc: ThirdPersonCamera
var fpc: FirstPersonCamera
var main_camera: MainCamera

var parent: PlayerCharacterController
var character: DuckEntity

var h_move_dir: Vector3

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
	_calculate_h_move_dir()
	_handle_move_and_rotate(delta)

func exit_state() -> void:
	pass
# ==================================================
func _calculate_h_move_dir() -> void:
	var vc: VirtualCamera = main_camera.get_follow_target()
	if not "y_gimbal" in vc:
		push_warning("No y_gimbal node in virtual camera.")
		return

	var ref: Node3D = vc['y_gimbal']

	var move_dir: Vector3
	var used_basis: Basis
	if character.is_on_slope():
		used_basis = STUtil.get_basis_from_normal(ref.global_basis, character.get_ground_normal())
		move_dir = used_basis.z * character.get_move_input().y + used_basis.x * character.get_move_input().x
	else:
		used_basis = ref.global_basis
		move_dir = used_basis.z * character.get_move_input().y + used_basis.x * character.get_move_input().x
	
	h_move_dir = move_dir.normalized()

func _handle_move_and_rotate(delta: float) -> void:
	character.move(h_move_dir)

	if character.get_move_input() != Vector2.ZERO:
		character.rotate_visual_container(character.basis.inverse() * h_move_dir, delta)
