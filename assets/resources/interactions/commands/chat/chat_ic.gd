class_name ChatIC extends InteractionCommand

@export var speaker: EntityData
@export var commands: Array[InteractionCommand]

func action(tree: SceneTree) -> STUtil.Promise:
    print("Open chat UI")
    print("Current speaker: ", speaker.name)

    for c: InteractionCommand in commands:
        await c.action(tree)
        await STUtil.interact_pressed

    print("Close chat UI")
    return STUtil.Promise.new()