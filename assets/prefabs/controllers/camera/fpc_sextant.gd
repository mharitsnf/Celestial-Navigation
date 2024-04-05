class_name FPCSextant extends FPCType

var raycast: RayCast3D

func _ready() -> void:
    raycast = STUtil.get_only_node_in_group("first_person_raycast")

