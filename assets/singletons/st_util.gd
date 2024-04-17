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

class Promise extends RefCounted:
    signal completed

# ===== Remote transform =====
func create_remote_transform(follower_name : String, use_rotation: bool = true) -> RemoteTransform3D:
    var remote_transform : RemoteTransform3D = RemoteTransform3D.new()
    remote_transform.name = "FollowedBy" + follower_name
    remote_transform.update_scale = false
    remote_transform.update_rotation = use_rotation
    return remote_transform
# ===== ===== ===== ===== =====

# ===== Latitude and longitude =====
class LatLong extends RefCounted:
    var latitude: float
    var longitude: float
    func _init(_latitude: float, _longitude: float) -> void:
        latitude = _latitude
        longitude = _longitude

func get_lat_long(gpos: Vector3) -> LatLong:
    var lat: float = _calculate_latitude(gpos)
    var lng: float = _calculate_longitude(gpos)
    return LatLong.new(lat, lng)

const MERIDIAN_DIR: Vector3 = Vector3.RIGHT
func _calculate_longitude(gpos: Vector3) -> float:
    var xz_dir: Vector3 = Vector3(gpos.x, 0., gpos.z).normalized()
    var angle: float = MERIDIAN_DIR.angle_to(xz_dir)
    var deg_angle: float = rad_to_deg(angle)
    deg_angle = -deg_angle if xz_dir.z < 0. else deg_angle
    return deg_angle

func _calculate_latitude(gpos: Vector3) -> float:
    var xz_pos: Vector3 = Vector3(gpos.x, 0., gpos.z)
    gpos = gpos.normalized()
    xz_pos = xz_pos.normalized()
    var dot_latitude: float = abs(xz_pos.dot(gpos))
    var latitude: float = remap(dot_latitude, 0., 1., 90., 0.)
    latitude = latitude if gpos.y >=0 else -latitude
    return latitude
# ===== ===== ===== ===== =====


# ===== Basis recalculation =====
func get_basis_from_normal(old_basis: Basis, new_normal: Vector3) -> Basis:
    new_normal = new_normal.normalized()

    var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
    var new_right : Vector3 = quat * old_basis.x
    var new_fwd : Vector3 = quat * old_basis.z

    return Basis(new_right, new_normal, new_fwd).orthonormalized()

func recalculate_basis(target : Node3D) -> Basis:
    var new_up : Vector3 = target.global_position.normalized()
    var old_basis : Basis = target.basis

    var quat : Quaternion = Quaternion(old_basis.y, new_up).normalized()
    var new_right : Vector3 = quat * old_basis.x
    var new_fwd : Vector3 = quat * old_basis.z

    return Basis(new_right, new_up, new_fwd).orthonormalized()
# ===== ===== ===== ===== ===== =====

# ===== Group nodes accessor =====
func is_node_in_group(node: Node, group_name: String) -> bool:
    var group: Array = get_tree().get_nodes_in_group(group_name)
    return group.has(node)

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
