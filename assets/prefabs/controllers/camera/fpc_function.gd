class_name FPCFunction extends Node

var parent: FirstPersonCamera

# ========== Built in functions ==========
func _enter_tree() -> void:
    parent = get_parent()
    parent.add_function(self)

    if !is_in_group(String(parent.get_path()) + "/FPCFunction"):
        add_to_group(String(parent.get_path()) + "/FPCFunction")
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(_delta: float) -> void:
    pass
# ========== ========== ========== ==========