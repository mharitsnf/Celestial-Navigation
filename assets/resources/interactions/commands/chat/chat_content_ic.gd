class_name ChatContentIC extends InteractionCommand

@export_multiline var text: String

func action(_tree: SceneTree) -> STUtil.Promise:
    var chat_box: ChatBox = STUtil.get_only_node_in_group("chat_box")
    chat_box.set_chat_text(text)
    chat_box.show_text()
    await chat_box.show_text_finished
    await STUtil.interact_pressed
    return STUtil.Promise.new()