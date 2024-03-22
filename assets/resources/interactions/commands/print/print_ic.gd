class_name PrintIC extends InteractionCommand

@export_multiline var text_to_print: String

func action(tree: SceneTree) -> STUtil.Promise:
    print(text_to_print)
    await tree.create_timer(.3).timeout
    return STUtil.Promise.new()