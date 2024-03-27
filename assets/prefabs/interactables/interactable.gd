class_name Interactable extends Area3D

@export var interaction: Interaction
var current_track: String = "Start"

func get_current_track() -> InteractionTrack:
	for t: InteractionTrack in interaction.tracks:
		var res: Resource = load(t.resource_path).duplicate()
		if res is InteractionTrack and res.track_name == current_track: return res
	return load(interaction.tracks[0].resource_path).duplicate()

func save_state() -> void:
	pass

func load_state() -> void:
	pass

func handle_track_finished() -> void:
	pass
