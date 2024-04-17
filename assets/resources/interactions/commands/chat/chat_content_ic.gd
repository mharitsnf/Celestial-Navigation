class_name ChatContentIC extends InteractionCommand

@export_multiline var text: String

func action(_tree: SceneTree) -> STUtil.Promise:
    var ui_manager: UIManager = STUtil.get_only_node_in_group("ui_manager")
    var controller: UIController = ui_manager.get_current_controller()
    if controller is ChatBoxController:
        controller.set_chat_text(text)
        controller.show_text()
        await controller.show_text_finished
    return STUtil.Promise.new()