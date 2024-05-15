class_name SwitchMenuIC extends InteractionCommand

@export var target_menu: UIManager.UIEnum

func action(_tree: SceneTree) -> STUtil.Promise:
    var ui_manager: UIManager = STUtil.get_only_node_in_group("ui_manager")
    if !ui_manager:
        push_error("UI Manager is null.")
        return STUtil.Promise.new()
    
    print("Switching to: ", target_menu)

    return STUtil.Promise.new()