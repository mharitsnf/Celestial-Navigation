extends Node

const PLANET_RADIUS : float = 792.0

func _enter_tree() -> void:
    _establish_input_connections()

# func _ready() -> void:
#     Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ===== Input utility =====
func _establish_input_connections() -> void:
    if !InputHelper.device_changed.is_connected(_on_input_device_changed):
        InputHelper.device_changed.connect(_on_input_device_changed)

func _on_input_device_changed(_device: String, _device_index: int) -> void:
    if input_device_equals(InputHelper.DEVICE_XBOX_CONTROLLER):
        InputHelper.rumble_medium()

func input_device_equals(device_name : String) -> bool:
    return InputHelper.guess_device_name() == device_name
# ===== ===== ===== ===== =====

# ===== Remote transform =====
func create_remote_transform(follower_name : String) -> RemoteTransform3D:
    var remote_transform : RemoteTransform3D = RemoteTransform3D.new()
    remote_transform.name = "FollowedBy" + follower_name
    remote_transform.update_scale = false
    return remote_transform
# ===== ===== ===== ===== =====

# ===== Basis recalculation =====
func recalculate_basis(target : Node3D) -> Basis:
    var new_up : Vector3 = target.global_position.normalized()
    var old_basis : Basis = target.basis

    var quat : Quaternion = Quaternion(old_basis.y, new_up).normalized()
    var new_right : Vector3 = quat * old_basis.x
    var new_fwd : Vector3 = quat * old_basis.z

    return Basis(new_right, new_up, new_fwd).orthonormalized()
# ===== ===== ===== ===== ===== =====

# ===== Group nodes accessor =====
func get_nodes_in_group(group_name: String) -> Array:
    return get_tree().get_nodes_in_group(group_name)

## Get node in group by name
func get_node_in_group_by_name(group_name: String, object_name: String) -> Variant:
    var nodes: Array = get_tree().get_nodes_in_group(group_name)
    for n: Variant in nodes:
        if n.name == object_name: return n
    return null

## Get the only/first node in a group.
func get_only_node_in_group(group_name : String) -> Variant:
    return get_tree().get_first_node_in_group(group_name)

## Get the index of a certain node in group.
func get_index_in_group(group_name : String, target : Node) -> int:
    return get_tree().get_nodes_in_group(group_name).find(target, 0)

## Get node by index in group.
func get_node_in_group(group_name : String, object_type : Variant, index : int) -> Variant:
    if index < 0 or index > get_tree().get_nodes_in_group(group_name).size() - 1:
        return null
    var instance : Variant = get_tree().get_nodes_in_group(group_name)[index]
    if !is_instance_of(instance, object_type):
        return null
    return instance
# ===== ===== ===== ===== ===== =====
