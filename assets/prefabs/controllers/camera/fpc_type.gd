class_name FPCType extends Node

var parent: FirstPersonCamera
var target_group: Node3D

# ========== Built in functions ==========
func _enter_tree() -> void:
    parent = get_parent()
    target_group = get_parent().get_parent()

    if !is_in_group(target_group.name + "FPCTypes"):
        add_to_group(target_group.name + "FPCTypes")
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(_delta: float) -> void:
    pass
# ========== ========== ========== ==========