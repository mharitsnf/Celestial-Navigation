class_name MainCamera extends Camera3D

class TargetVirtualCamera extends RefCounted:
	var virtual_camera : VirtualCamera
	var remote_transform : RemoteTransform3D
	func _init(_virtual_camera : VirtualCamera) -> void:
		virtual_camera = _virtual_camera
		remote_transform = STUtil.create_remote_transform("MainCamera")
		virtual_camera.remote_transform_parent_for_other.add_child(remote_transform)

@export var tween_duration : float = 1.

# ===== Follow settings =====
@export_group("Follow settings")
@export var follow_target : VirtualCamera:
	set(value):
		if !_set_follow_target_error_checks(value): return
		follow_target = value
		_change_target(follow_target)

var transitioning : bool = false
var tween_elapsed_time : float = 0.
signal transition_finished

var previous_target : TargetVirtualCamera = null
var current_target : TargetVirtualCamera = null
# ===== ===== ===== ===== =====

# For testing
var current_vcam_index : int = 0

func _enter_tree() -> void:
	if !transition_finished.is_connected(_on_transition_finished):
		transition_finished.connect(_on_transition_finished)
	
	if !is_in_group("main_camera"):
		add_to_group("main_camera")

func _ready() -> void:
	# for testing
	set_follow_target(STUtil.get_node_in_group("virtual_cameras", VirtualCamera, current_vcam_index))

func _process(delta: float) -> void:
	_transition(delta)

	# For testing
	if Input.is_action_just_pressed("ui_accept"):
		current_vcam_index += 1
		current_vcam_index = current_vcam_index % get_tree().get_nodes_in_group("virtual_cameras").size()
		set_follow_target(STUtil.get_node_in_group("virtual_cameras", VirtualCamera, current_vcam_index))

## Returns the current follow target.
func get_follow_target() -> VirtualCamera:
	return follow_target

## Sets a new follow target.
func set_follow_target(new_target : VirtualCamera) -> void:
	follow_target = new_target

func _change_target(new_target : VirtualCamera, use_transition : bool = true) -> void:
	if !new_target:
		push_error("Returning: new_target is null")
		return
	if current_target and current_target.virtual_camera == new_target:
		push_warning("Returning: New target is the same as current target.")
		return
	if is_transitioning():
		push_warning("Returning: Main camera is still transitioning.")
		return

	if current_target:
		current_target.remote_transform.remote_path = NodePath("")
		previous_target = current_target
	
	current_target = TargetVirtualCamera.new(new_target)

	if use_transition:
		set_transitioning(true)

func _set_follow_target_error_checks(new_target : VirtualCamera) -> bool:
	if !new_target:
		push_error("Returning: new_target is null")
		return false
	if current_target and current_target.virtual_camera == new_target:
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

func get_virtual_camera(target_name : String) -> VirtualCamera:
	var vcams : Array = get_tree().get_nodes_in_group("virtual_cameras")
	vcams = vcams.filter(
		func(vcam : Node) -> bool:
			return vcam.name == target_name
	)
	if !vcams.is_empty() and vcams[0] is VirtualCamera: return vcams[0]
	else: return null
