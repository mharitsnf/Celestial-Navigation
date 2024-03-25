class_name ChatIC extends InteractionCommand

@export var speaker: EntityData
@export var commands: Array[ChatContentIC]

func action(tree: SceneTree) -> STUtil.Promise:
	var chat_box: ChatBox = STUtil.get_only_node_in_group("chat_box")
	chat_box.set_speaker_text("Speaker name")
	chat_box.show_box()
	await tree.create_timer(.25).timeout

	for c: ChatContentIC in commands:
		await c.action(tree)
		await STUtil.interact_pressed

	chat_box.hide_box()
	await chat_box.anim.animation_finished
	chat_box.set_chat_text("")
	chat_box.set_speaker_text("")
	
	return STUtil.Promise.new()
