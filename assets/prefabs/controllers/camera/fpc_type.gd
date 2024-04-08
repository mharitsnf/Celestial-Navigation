class_name FPCType extends Node

var parent: FirstPersonCamera

# ========== Built in functions ==========
func _enter_tree() -> void:
    parent = get_parent()

    if !is_in_group(String(parent.get_path()) + "/FPCTypes"):
        add_to_group(String(parent.get_path()) + "/FPCTypes")
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(_delta: float) -> void:
    pass
# ========== ========== ========== ==========