class_name VirtualCamera extends Node3D

class TargetNode extends RefCounted:
	var follow_target : Node3D
	var remote_transform : RemoteTransform3D
	func _init(follower : Node, _follow_target : Node3D) -> void:
		follow_target = _follow_target
		remote_transform = STUtil.create_remote_transform(follower.name)
		follow_target.add_child(remote_transform)

# ===== For other to follow this node =====
@export var remote_transform_parent_for_other : Node3D
# ===== ===== ===== ===== ===== ===== =====

# ===== Rotation settings =====
@export_group("Rotation settings")
@export var rotation_speed : float = .1
@export var max_x_angle : float = 80.
@export var min_x_angle : float = -80.
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

var main_camera : MainCamera
var previous_target : TargetNode
var current_target : TargetNode
# ===== ===== ===== ===== =====

# =============== Built in functions ===============
func _enter_tree() -> void:
	if !is_in_group("virtual_cameras"):
		add_to_group("virtual_cameras")
	
	if !transition_finished.is_connected(_on_transition_finished):
		transition_finished.connect(_on_transition_finished)

func _ready() -> void:
	main_camera = STUtil.get_only_node_in_group("main_camera")

func _process(delta: float) -> void:
	_transition(delta)
	_rotate_joypad()
# =============== ===============  ===============

# =============== Follow and transition functions ===============
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

# =============== Input functions ===============
func is_active() -> bool:
	if !main_camera: return false
	return main_camera.get_follow_target() == self

func _rotate_camera(_direction : Vector2) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate_mouse(event)

func _rotate_mouse(event : InputEventMouseMotion) -> void:
	if !_rotate_mouse_error_checks(): return
	var direction : Vector2 = event.relative * .001
	_rotate_camera(direction)

func _rotate_joypad() -> void:
	if !_rotate_joypad_error_checks(): return
	var direction : Vector2 = Input.get_vector("rotate_camera_left", "rotate_camera_right", "rotate_camera_down", "rotate_camera_up")
	direction *= .01
	_rotate_camera(direction)

## Error checks for mouse input
func _rotate_mouse_error_checks() -> bool:
	if !is_active(): return false
	if !STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
	return true

## Error checks for joypad input
func _rotate_joypad_error_checks() -> bool:
	if !is_active(): return false
	if STUtil.input_device_equals(InputHelper.DEVICE_KEYBOARD): return false
	return true
# =============== =============== ===============
