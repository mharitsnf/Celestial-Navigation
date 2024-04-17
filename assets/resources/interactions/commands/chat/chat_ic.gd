class_name ChatIC extends InteractionCommand

@export var speaker: EntityData
@export var commands: Array[ChatContentIC]

func action(tree: SceneTree) -> STUtil.Promise:
	var ui_manager: UIManager = STUtil.get_only_node_in_group("ui_manager")

	ui_manager.switch_current_ui(UIManager.UIEnum.CHAT_BOX)
	var controller: UIController = ui_manager.get_current_controller()
	if controller is ChatBoxController:
		if speaker: controller.set_speaker_text(speaker.name)
		else: controller.set_speaker_text("Speaker Name")
		
		controller.show_ui()
		await controller.animation_finished
		
		for c: ChatContentIC in commands:
			await c.action(tree)
			await controller.interact_pressed

		controller.hide_ui()
		await controller.animation_finished
		ui_manager.switch_current_ui(UIManager.UIEnum.NONE)

	return STUtil.Promise.new()
