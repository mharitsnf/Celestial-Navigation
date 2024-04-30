class_name VirtualCamera extends Node3D

# IMPORTANT!
# Remote transform use rotation is set to false, meaning the virtual camera's basis
# will not calibrate to the spherical planet's basis (the up vector will always be (0,1,0)).
# To make the virtual camera's basis calibrate, put this virtual camera as a child
# of the follow target.
# The follow target must be the one that is calibrating the basis.
# For example, this works when the virtual camera's follow target is a BaseEntity, and when the
# virtual camera is a child of the same BaseEntity.
class TargetNode extends RefCounted:
	var follow_target : Node3D
	var remote_transform : RemoteTransform3D
	func _init(follower : Node, _follow_target : Node3D) -> void:
		follow_target = _follow_target
		remote_transform = STUtil.create_remote_transform(follower.name, false)
		follow_target.add_child(remote_transform)

# ===== For other to follow this node =====
@export var switchable_camera: bool = true
@export var entry_camera: bool
@export var target_group: Node
@export var remote_transform_parent_for_other : Node3D
# ===== ===== ===== ===== ===== ===== =====

# ===== Rotation settings =====
@export_group("Rotation settings")
@export var rotation_speed : float = .1
@export var submerged_angle: Vector2 = Vector2(-80, 0)
@export var default_angle: Vector2 = Vector2(-80, 80)
var submerged: bool = false
# ===== ===== ===== ===== ===== ===== =====

# ===== Follow settings =====
@export_group("Follow settings")
@export var follow_target : Node3D:
	set(value):
		# Do not set to new value if does not pass the error checks
		if !_set_follow_target_error_checks(value): return 
		follow_target = value
		_change_target(follow_target)

@export var tween_duration : float = .75
var transitioning : bool = false
var tween_elapsed_time : float = 0.
signal transition_finished

# ===== FoV =====
@export var min_fov: float = 30
@export var max_fov: float = 110
var _fov: float = 75

var main_camera : MainCamera
var previous_target : TargetNode
var current_target : TargetNode
# ===== ===== ===== ===== =====

# =============== Built in functions ===============
func _enter_tree() -> void:
	if !transition_finished.is_connected(_on_transition_finished):
		transition_finished.connect(_on_transition_finished)

	main_camera = STUtil.get_only_node_in_group("main_camera")

func _ready() -> void:
	if main_camera:
		_fov = main_camera.fov

func _process(delta: float) -> void:
	_lerp_main_camera_fov(delta)
	_transition(delta)
# =============== ===============  ===============

# =============== Follow and transition functions ===============
func get_target_group() -> BaseEntity:
	return target_group

## Returns the current follow target.
func get_follow_target() -> Node3D:
	return follow_target

## Sets a new follow target.
func set_follow_target(new_target : Node3D) -> void:
	follow_target = new_target

func _change_target(new_target : Node3D, use_transition : bool = true) -> void:
	if current_target:
		current_target.remote_transform.remote_path = NodePath("")
		previous_target = current_target

	current_target = TargetNode.new(self, new_target)

	if use_transition:
		set_transitioning(true)

func _set_follow_target_error_checks(new_target : Node3D) -> bool:
	if !new_target:
		push_error("Returning: new_target is null")
		return false
	if current_target and current_target.follow_target == new_target:
		push_warning("Returning: New target is the same as current target.")
		return false
	if is_transitioning():
		push_warning("Returning: Main camera is still transitioning.")
		return false
	return true

func is_transitioning() -> bool:
	return transitioning

func set_transitioning(value : bool) -> void:
	transitioning = value

func _on_transition_finished() -> void:
	tween_elapsed_time = 0.

	if previous_target:
		previous_target.remote_transform.queue_free()
		previous_target.remote_transform = null

	current_target.remote_transform.remote_path = get_path()
	set_transitioning(false)

func _transition(delta : float) -> void:
	if is_transitioning():
		# Exit transition
		if tween_elapsed_time > tween_duration or !previous_target or !current_target:
			transition_finished.emit()
			return
		
		global_position = Tween.interpolate_value(
			previous_target.remote_transform.global_position,
			current_target.remote_transform.global_position - previous_target.remote_transform.global_position,
			tween_elapsed_time,
			tween_duration,
			Tween.TRANS_CUBIC,
			Tween.EASE_IN_OUT
		)
		
		var previous_quat : Quaternion = Quaternion(previous_target.remote_transform.global_basis.orthonormalized())
		var current_quat : Quaternion = Quaternion(current_target.remote_transform.global_basis.orthonormalized())
		quaternion = Tween.interpolate_value(
			previous_quat,
			previous_quat.inverse() * current_quat,
			tween_elapsed_time,
			tween_duration,
			Tween.TRANS_CUBIC,
			Tween.EASE_IN_OUT
		)

		tween_elapsed_time += delta
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

func is_active() -> bool:
	return main_camera.get_follow_target() == self
