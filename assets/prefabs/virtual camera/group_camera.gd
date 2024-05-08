class_name GroupCamera extends VirtualCamera

@export var group_targets: Array[Node3D]

@export_group("References")
@export var offset: Node3D
@export var rotation_node: Node3D

func add_target(new_target: Node3D) -> void:
    group_targets.append(new_target)

func remove_target(new_target: Node3D) -> void:
    group_targets.erase(new_target)