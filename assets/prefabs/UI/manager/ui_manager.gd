class_name UIManager extends CanvasLayer

class UserInterface extends RefCounted:
    var pscn: PackedScene
    var controller: UIController
    var instance: Control = null
    func _init(_pscn: PackedScene) -> void:
        pscn = _pscn
    func create_instance() -> void:
        instance = pscn.instantiate()
        controller = instance.get_node("Controller")
    func get_controller() -> UIController:
        return controller
    func get_instance() -> Control:
        return instance

enum UIEnum {
    NONE,
    CHAT_BOX
}
var current_ui: UserInterface
var ui_dict: Dictionary = {
    UIEnum.CHAT_BOX: UserInterface.new(preload("res://assets/prefabs/UI/chat_box/chat_box.tscn"))
}

func _enter_tree() -> void:
    if !is_in_group("ui_manager"):
        add_to_group("ui_manager")

func has_current_ui() -> bool:
    return current_ui != null

func get_current_controller() -> UIController:
    return current_ui.get_controller()

func get_current_instance() -> Control:
    return current_ui.get_instance()

func _remove_current_ui() -> void:
    if !current_ui:
        push_error("There is no current UI.")
        return
    remove_child(current_ui.get_instance())
    current_ui.get_controller().clear()
    current_ui = null

func switch_current_ui(new_ui_enum: UIEnum) -> void:
    if new_ui_enum == UIEnum.NONE:
        _remove_current_ui()
    else:
        if current_ui: _remove_current_ui()
        var new_ui: UserInterface = ui_dict[new_ui_enum]
        if !new_ui.get_instance(): new_ui.create_instance()
        current_ui = new_ui
        add_child(current_ui.get_instance())