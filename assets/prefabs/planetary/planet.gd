@tool
extends Node3D

func _ready() -> void:
    for c: Node in get_children():
        if c is MeshInstance3D:
            c.create_trimesh_collision()
            var body: Node = c.get_child(0)
            if body is StaticBody3D:
                body.set_collision_layer_value(1, false)
                body.set_collision_layer_value(2, true)
                body.set_collision_mask_value(1, false)
                body.set_collision_mask_value(2, true)

func _get_all_children(out : Array, node : Node, object_type : Variant = null) -> void:
    for child: Node in node.get_children():
        if !object_type:
            out.append(child)
        else:
            if is_instance_of(child, object_type): out.append(child)
        
        if child.get_child_count() > 0:
            _get_all_children(out, child, object_type)