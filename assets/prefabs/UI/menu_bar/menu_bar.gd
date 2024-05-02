class_name UIMenuBar extends HBoxContainer

func _ready() -> void:
    var fc: MenuIcon = get_child(0)
    fc.grab_focus.call_deferred()