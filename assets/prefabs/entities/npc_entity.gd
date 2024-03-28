class_name NPCEntity extends BaseEntity

@export var interactable: Interactable

func save_state() -> Dictionary:
	var data: Dictionary = super()
	if data.has("on_init"):
		var on_init_dict: Dictionary = data["on_init"]
		on_init_dict.merge({
			"current_track": interactable.current_track
		})
		data['on_init'] = on_init_dict
	return data

func on_load_init(data: Dictionary) -> void:
	interactable.set_current_track(data["current_track"])
