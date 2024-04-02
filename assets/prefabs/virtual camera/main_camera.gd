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
signal follow_target_changed(target: VirtualCamera)

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
	if !is_in_group("persist"):
		add_to_group("persist")

func _process(delta: float) -> void:
	_transition(delta)

# ========== Setter and getter functions ==========
## Returns the current follow target.
func get_follow_target() -> VirtualCamera:
	return follow_target

## Sets a new follow target.
func set_follow_target(new_target : VirtualCamera) -> void:
	follow_target = new_target
# ========== ========== ========== ==========

# ========== Transition functions ==========
func _change_target(new_target : VirtualCamera, use_transition : bool = true) -> void:
	if current_target:
		current_target.virtual_camera.exit_camera()
		current_target.remote_transform.remote_path = NodePath("")
		previous_target = current_target
	
	new_target.enter_camera()
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

	follow_target_changed.emit(current_target.virtual_camera)

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

		fov = Tween.interpolate_value(
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
			"parent": get_parent().get_path(),
		},
		"on_init": {
			"i_follow_target": STUtil.get_index_in_group("persist", get_follow_target().get_parent()),
		},
		"on_ready": {}
	}

func on_load_init(data: Dictionary) -> void:
	set_follow_target(data["i_follow_target"])

func on_load_ready(_data: Dictionary) -> void:
	pass
# ========== ========== ========== ==========
