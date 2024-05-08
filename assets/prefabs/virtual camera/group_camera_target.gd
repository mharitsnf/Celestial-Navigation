class_name GroupCameraTarget extends Node3D

@export var follow_offset: Vector3 = Vector3.ZERO
@export var look_at_offset: Vector3 = Vector3.ZERO
@export var follow_distance: float = 5.
@export var targets: Array[Node3D]
@export_group("References")
@export var rotation_target: Node3D

var prev_controller: PlayerController
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

    add_target(player_controller_manager.get_current_instance())

func _process(_delta: float) -> void:
    basis = STUtil.recalculate_basis(self)

    if targets.size() == 1:
        _interpolate_position(
            targets[0].global_position +
            _get_adjusted_follow_offset() + 
            basis.z * Vector3(follow_distance, follow_distance, follow_distance)
        )

        _interpolate_rotation(
            targets[0].global_position +
            _get_adjusted_look_at_offset()
        )

    elif targets.size() > 1:
        var bounds: AABB = AABB(targets[0].global_position, Vector3.ZERO)
        for node: Node3D in targets:
            if is_instance_valid(node): bounds = bounds.expand(node.global_position)

        _interpolate_position(
            bounds.get_center() +
            _get_adjusted_follow_offset() +
            basis.z * Vector3(follow_distance, follow_distance, follow_distance)
        )

        _interpolate_rotation(
            bounds.get_center() +
            _get_adjusted_look_at_offset()
        )

func _interpolate_position(target_position: Vector3) -> void:
    global_position = target_position

func _interpolate_rotation(target_trans: Vector3) -> void:
    if global_basis.y != Vector3.ZERO:
        rotation_target.look_at(target_trans, global_basis.y)

func _get_adjusted_follow_offset() -> Vector3:
    return basis * follow_offset

func _get_adjusted_look_at_offset() -> Vector3:
    return basis * look_at_offset

func _on_player_object_changed(instance: Node3D, controller: PlayerController) -> void:
    if current_controller:
        if current_controller.interaction_started.is_connected(_on_interaction_started):
            current_controller.interaction_started.disconnect(_on_interaction_started)
        if current_controller.interaction_finished.is_connected(_on_interaction_finished):
            current_controller.interaction_finished.disconnect(_on_interaction_finished)
        prev_controller = current_controller

    current_controller = controller
    if !current_controller.interaction_started.is_connected(_on_interaction_started):
        current_controller.interaction_started.connect(_on_interaction_started)
    if !current_controller.interaction_finished.is_connected(_on_interaction_finished):
        current_controller.interaction_finished.connect(_on_interaction_finished)

    remove_target(instance)
    add_target(instance)

func _on_interaction_started(target_interaction: Node3D) -> void:
    add_target(target_interaction)

func _on_interaction_finished(target_interaction: Node3D) -> void:
    await main_camera.transition_finished
    remove_target(target_interaction)

func add_target(new_target: Node3D) -> void:
    targets.append(new_target)

func remove_target(new_target: Node3D) -> void:
    targets.erase(new_target)