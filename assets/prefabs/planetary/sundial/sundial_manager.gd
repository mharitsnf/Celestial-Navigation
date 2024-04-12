class_name SundialManager extends Node3D

@export var rotation_speed : float = 1

@export var sundial_center: Marker3D
@export var sundial_pscn: PackedScene
@export var latitude_measure_pscn: PackedScene
var measure_mesh: MeshInstance3D

# ========== Built-in functions ==========
func _ready() -> void:
    # Get containers and references to others
    var sundial_boat_position: Node3D = STUtil.get_only_node_in_group("sundial_boat_position")
    var objects_container: Node = STUtil.get_only_node_in_group("objects_container")

    # Create remote transform to the boat
    var sundial_manager_rt: RemoteTransform3D = STUtil.create_remote_transform("SundialManager")
    sundial_manager_rt.remote_path = get_path()
    sundial_boat_position.add_child(sundial_manager_rt)

    # Add sundial
    var sundial: Node3D = sundial_pscn.instantiate()
    var sundial_rt: RemoteTransform3D = STUtil.create_remote_transform("Sundial", false)
    objects_container.add_child.call_deferred(sundial)
    await sundial.ready
    sundial_rt.remote_path = sundial.get_path()
    sundial_center.add_child.call_deferred(sundial_rt)

    # Add latitude measure
    var latitude_measure: Node3D = latitude_measure_pscn.instantiate()
    measure_mesh = latitude_measure.get_node("LatitudeMeasure")
    var latitude_measure_rt: RemoteTransform3D = STUtil.create_remote_transform("LatitudeMeasure")
    objects_container.add_child.call_deferred(latitude_measure)
    await latitude_measure.ready
    latitude_measure_rt.remote_path = latitude_measure.get_path()
    sundial_center.add_child.call_deferred(latitude_measure_rt)
# ========== ========== ========== ==========

# ========== Save and load state functions ==========
func rotate_latitude_measurement(amount: float, delta: float) -> void:
    var new_rotation: float = measure_mesh.rotation.y + (delta * rotation_speed * amount)
    measure_mesh.rotation.y = lerp(measure_mesh.rotation.y, new_rotation, .8)
# ========== ========== ========== ==========

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
    return {
        "metadata": {
            "filename": scene_file_path,
            "path": get_path(),
            "parent": get_parent().get_path(),
        },
        "on_init": {},
        "on_ready": {}
    }

func on_load_init(_data: Dictionary) -> void:
    pass

func on_load_ready(_data: Dictionary) -> void:
    pass
# ========== ========== ========== ==========