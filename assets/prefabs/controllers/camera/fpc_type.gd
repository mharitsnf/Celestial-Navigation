class_name FPCType extends Node

var parent: FPCController

# ========== Built in functions ==========
func _enter_tree() -> void:
    parent = get_parent()
# ========== ========== ========== ==========

# ========== For the manager ==========
func process(_delta: float) -> void:
    pass
# ========== ========== ========== ==========