class_name MainCamera extends Camera3D

class TargetVirtualCamera extends RefCounted:
	var virtual_camera : VirtualCamera
	var controller: VirtualCameraController
	var remote_transform : RemoteTransform3D
	func _init(_virtual_camera : VirtualCamera) -> void:
		virtual_camera = _virtual_camera
		controller = _virtual_camera.get_node("Controller")
		remote_transform = STUtil.create_remote_transform("MainCamera")
		virtual_camera.remote_transform_parent_for_other.add_child(remote_transform)
	func get_controller() -> VirtualCameraController:
		return controller

@export var tween_duration : float = 1.

# ===== Follow settings =====
@export_group("Follow settings")
@export var follow_target : VirtualCamera:
	set(value):
		if !_set_follow_target_error_checks(value): return
		follow_target = value
		_change_target(follow_target)

var trans_fov: float = fov
var transitioning : bool = false
var tween_elapsed_time : float = 0.
signal transition_finished
signal follow_target_changed(target: VirtualCamera)

var previous_target : TargetVirtualCamera = null
var current_target : TargetVirtualCamera = null
# ===== ===== ===== ===== =====

# For testing
var current_vcam_index : int = 0

func _process(delta: float) -> void:
	if current_target and current_target.get_controller():
		current_target.get_controller().process(delta)
	
	_transition(delta)
	
	# Smooth out fov transition
	fov = lerp(fov, trans_fov, delta * .5)

func _unhandled_input(event: InputEvent) -> void:
	if current_target and current_target.get_controller():
		current_target.get_controller().unhandled_input(event)

# ========== Setter and getter functions ==========
## Returns the current follow target.
func get_follow_target() -> VirtualCamera:
	return follow_target

func get_previous_follow_target() -> VirtualCamera:
	return previous_target.virtual_camera

## Sets a new follow target.
func set_follow_target(new_target : VirtualCamera) -> void:
	follow_target = new_target
# ========== ========== ========== ==========

# ========== Transition functions ==========
func _change_target(new_target : VirtualCamera, use_transition : bool = true) -> void:
	if current_target:
		current_target.remote_transform.remote_path = NodePath("")
		previous_target = current_target
	
	current_target = TargetVirtualCamera.new(new_target)
	follow_target_changed.emit(current_target.virtual_camera)

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

		trans_fov = Tween.interpolate_value(
			previous_target.virtual_camera.get_fov(),
			current_target.virtual_camera.get_fov() - previous_target.virtual_camera.get_fov(),
			tween_elapsed_time,
			tween_duration,
			Tween.TRANS_CUBIC,
			Tween.EASE_IN_OUT
		)

		tween_elapsed_time += delta
# ========== ========== ========== ==========

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"path": get_path(),
			"parent": get_parent().get_path(),
		},
		"on_init": {
			# Finds the parent of the current virtual camera, set that to follow target
			"i_follow_target": STUtil.get_index_in_group("persist", get_follow_target().get_parent()),
		},
		"on_ready": {}
	}

func on_preprocess(data: Dictionary) -> void:
	var vcam_parent: Node = data["i_follow_target"]
	var vcams: Array[Node] = vcam_parent.get_children().filter(func (n: Node) -> bool: return n is VirtualCamera and n.is_entry_camera())
	if !vcams.is_empty(): set_follow_target(vcams[0])

func on_load_ready(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========
