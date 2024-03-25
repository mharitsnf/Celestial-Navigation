class_name InteractionCommand extends Resource

@export var auto_next: bool = false

func action(_tree: SceneTree) -> STUtil.Promise:
    return STUtil.Promise.new()