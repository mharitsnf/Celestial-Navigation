class_name UIManager extends CanvasLayer

# UIs are different than HUDs in that they interrupt player controls.
# Examples of UIs are chat boxes, menu (e.g., see quests, settings, etc.) 

class UserInterface extends RefCounted:
    var key: int
    var pscn: PackedScene
    var controller: UIController
    var instance: Control = null
    func _init(_pscn: PackedScene, _key: int) -> void:
        pscn = _pscn
        key = _key
    func create_instance() -> void:
        instance = pscn.instantiate()
        controller = instance.get_node("Controller")
    func get_controller() -> UIController:
        return controller
    func get_instance() -> Control:
        return instance
    func get_key() -> int:
        return key

enum UIEnum {
    NONE,
    CHAT_BOX,
    PAUSE_MENU
}
var current_ui: UserInterface
var ui_dict: Dictionary = {
    UIEnum.CHAT_BOX: UserInterface.new(preload("res://assets/prefabs/UI/chat_box/chat_box.tscn"), UIEnum.CHAT_BOX),
    UIEnum.PAUSE_MENU: UserInterface.new(preload("res://assets/prefabs/UI/pause_menu/pause_menu.tscn"), UIEnum.PAUSE_MENU),
}

func _process(delta: float) -> void:
    if current_ui and get_current_controller():
        get_current_controller().process(delta)

func has_current_ui() -> bool:
    return current_ui != null

func current_ui_key_equals(value: UIEnum) -> bool:
    if !current_ui:
        if value == UIEnum.NONE: return true 
        else: return false
    return current_ui.get_key() == value

func get_current_ui_key() -> UIEnum:
    if !current_ui: return UIEnum.NONE
    return current_ui.get_key() as UIEnum

func get_current_controller() -> UIController:
    return current_ui.get_controller()

func get_current_instance() -> Control:
    return current_ui.get_instance()

func _remove_current_ui() -> void:
    if !current_ui:
        push_error("There is no current UI.")
        return
    await current_ui.get_controller().before_exit_tree()
    remove_child(current_ui.get_instance())
    current_ui = null

func switch_current_ui(new_ui_enum: UIEnum) -> void:
    # If we have another UI, remove
    if current_ui: await _remove_current_ui()
    # If switch to nothing, return
    if new_ui_enum == UIEnum.NONE: return

    # Setup new UI
    var new_ui: UserInterface = ui_dict[new_ui_enum]
    if !new_ui.get_instance(): new_ui.create_instance()
    new_ui.get_controller().reset_animation()
    current_ui = new_ui
    add_child(current_ui.get_instance())