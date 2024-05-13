class_name VirtualCamera extends Node3D

## The [MainCamera] will be following this virtual camera through a [RemoteTransform3D] node.
## That [RemoteTransform3D] node will be placed as a children of the node assigned to this property.
@export var remote_transform_parent_for_other : Node3D

# ===== Grouping settings =====
@export_group("Grouping settings")
@export var independent_group: bool = false
@export var target_group: Node
@export var single_group_name: String = ""
@export var switchable_camera: bool = true
@export var entry_camera: bool
# ===== ===== ===== ===== ===== ===== =====

# ===== Rotation settings =====
@export_group("Rotation settings")
@export var copy_rotation_on_enter: bool = true
@export var rotation_speed : float = .1
@export var submerged_angle: Vector2 = Vector2(-80, 0)
@export var default_angle: Vector2 = Vector2(-80, 80)
var submerged: bool = false
# ===== ===== ===== ===== ===== ===== =====

# ===== FoV =====
@export_group("FoV settings")
@export var min_fov: float = 30
@export var max_fov: float = 110
@export var _fov: float = 75

var main_camera : MainCamera
# ===== ===== ===== ===== =====

# =============== Built in functions ===============

func _enter_tree() -> void:
	var group_path: String = String(get_target_group().get_path()) if !independent_group else ""

	if !is_in_group(group_path + "/VCs"): add_to_group(group_path + "/VCs")
	if is_entry_camera() and !is_in_group(group_path + "/EntryVC"): add_to_group(group_path + "/EntryVC")
	if is_switchable_camera() and !is_in_group(group_path + "/SwitchableVCs"): add_to_group(group_path + "/SwitchableVCs")
	if !single_group_name.is_empty() and !is_in_group(group_path + "/" + single_group_name): add_to_group(group_path + "/" + single_group_name)

	main_camera = STUtil.get_only_node_in_group("main_camera")

func _process(delta: float) -> void:
	_lerp_main_camera_fov(delta)
	# _transition(delta)
# =============== ===============  ===============

# =============== Follow and transition functions ===============
func get_target_group() -> BaseEntity:
	return target_group
# =============== =============== ===============

# =============== FoV API ===============
func get_fov() -> float:
	return _fov

func set_fov(value: float) -> void:
	_fov = clamp(value, min_fov, max_fov)

const FOV_LERP_WEIGHT: float = 5.
func _lerp_main_camera_fov(delta: float) -> void:
	if !main_camera or !is_instance_valid(main_camera):
		main_camera = STUtil.get_only_node_in_group("main_camera")
	
	if !is_active(): return
	main_camera.fov = lerp(main_camera.fov, _fov, delta * FOV_LERP_WEIGHT)
# =============== =============== ===============

func is_submerged() -> bool:
	return submerged

func set_submerged(value: bool) -> void:
	submerged = value

func is_switchable_camera() -> bool:
	return switchable_camera

func is_entry_camera() -> bool:
	return entry_camera

func get_x_rotation() -> float:
	return 0.

func get_y_rotation() -> float:
	return 0.

func copy_rotation(_x_rotation: float, _y_rotation: float) -> void:
	pass

func rotate_camera(_direction : Vector2) -> void:
	pass

func set_camera_rotation(_up_rotation: float, _right_rotation: float) -> void:
	pass

func set_camera_look_at(_direction: Vector3) -> void:
	pass

func is_active() -> bool:
	return main_camera.get_follow_target() == self
