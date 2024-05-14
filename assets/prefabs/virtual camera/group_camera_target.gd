class_name GroupCameraTarget extends Node3D

@export var follow_offset: Vector3 = Vector3.ZERO
@export var x_rotation_amount: float = 0.
@export var targets: Array[Node3D]
@export_group("References")
@export var offset_target: Node3D
@export var rotation_target: Node3D
@export var x_rotation_target: Node3D

var prev_instance: Node3D
var prev_controller: PlayerController
var current_instance: Node3D
var current_controller: PlayerController

var main_camera: MainCamera
var player_controller_manager: PlayerControllerManager

func _ready() -> void:
	if !main_camera:
		main_camera = STUtil.get_only_node_in_group("main_camera")

	if !player_controller_manager:
		player_controller_manager = STUtil.get_only_node_in_group("player_controller_manager")
	
	if !player_controller_manager.player_object_changed.is_connected(_on_player_object_changed):
		player_controller_manager.player_object_changed.connect(_on_player_object_changed)

	current_controller = player_controller_manager.get_current_controller()
	if !current_controller.interaction_started.is_connected(_on_interaction_started):
		current_controller.interaction_started.connect(_on_interaction_started)
	if !current_controller.interaction_finished.is_connected(_on_interaction_finished):
		current_controller.interaction_finished.connect(_on_interaction_finished)

	current_instance = player_controller_manager.get_current_instance()
	add_target(current_instance)

func _process(delta: float) -> void:
	basis = STUtil.recalculate_basis(self)
	_update_position_and_rotation(delta)
	_lerp_offset(delta)
	_lerp_x_rotation(delta)

func _update_position_and_rotation(_delta: float) -> void:
	if targets.size() == 1:
		global_position = targets[0].global_position

	elif targets.size() > 1:
		var bounds: AABB = AABB(targets[0].global_position, Vector3.ZERO)
		for node: Node3D in targets:
			if is_instance_valid(node): bounds = bounds.expand(node.global_position)
		global_position = bounds.get_center()
		
		var look_dir: Vector3 = (bounds.get_center() - targets[0].global_position).rotated(basis.y, deg_to_rad(90)).normalized()
		look_dir = basis.inverse() * look_dir
		look_dir = Vector3(look_dir.x, 0., look_dir.z).normalized()
		var new_basis: Basis = Basis.looking_at(look_dir, rotation_target.basis.y).orthonormalized()
		rotation_target.basis = new_basis

func _lerp_offset(delta: float) -> void:
	offset_target.position = lerp(offset_target.position, follow_offset, delta * 5.)

func _lerp_x_rotation(delta: float) -> void:
	x_rotation_target.rotation_degrees.x = lerp(x_rotation_target.rotation_degrees.x, x_rotation_amount, delta * 5.)

func _interpolate_look_at(target_look_at: Vector3) -> void:
	if global_basis.y != Vector3.ZERO:
		rotation_target.look_at(target_look_at, global_basis.y)

func _get_adjusted_follow_offset() -> Vector3:
	return basis * follow_offset

func _on_player_object_changed(instance: Node3D, controller: PlayerController) -> void:
	# If there's a current controller disconnect signals
	if current_controller:
		if current_controller.interaction_started.is_connected(_on_interaction_started):
			current_controller.interaction_started.disconnect(_on_interaction_started)
		if current_controller.interaction_finished.is_connected(_on_interaction_finished):
			current_controller.interaction_finished.disconnect(_on_interaction_finished)
		prev_controller = current_controller

	# If there's a current instance, remove from target
	if current_instance:
		remove_target(current_instance)
		prev_instance = current_instance

	# Set current instance and controller to new ones and connect to signals
	current_instance = instance
	current_controller = controller
	if !current_controller.interaction_started.is_connected(_on_interaction_started):
		current_controller.interaction_started.connect(_on_interaction_started)
	if !current_controller.interaction_finished.is_connected(_on_interaction_finished):
		current_controller.interaction_finished.connect(_on_interaction_finished)
	add_target(instance)

func _on_interaction_started(target_interaction: Node3D) -> void:
	add_target(target_interaction)

func _on_interaction_finished(target_interaction: Node3D) -> void:
	# Wait for camera to finish transition before removing the target
	await main_camera.transition_finished
	remove_target(target_interaction)

func add_target(new_target: Node3D) -> void:
	targets.append(new_target)

func remove_target(new_target: Node3D) -> void:
	targets.erase(new_target)
