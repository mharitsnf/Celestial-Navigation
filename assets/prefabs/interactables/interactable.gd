class_name Interactable extends Area3D

@export var interaction: Interaction
var current_track: String = "Start"

func get_track() -> InteractionTrack:
	for t: InteractionTrack in interaction.tracks:
		var res: Resource = load(t.resource_path).duplicate()
		if (res as InteractionTrack).track_name == current_track: return res
		# if res is InteractionTrack and res.track_name == current_track: return res
	return load(interaction.tracks[0].resource_path).duplicate()

func get_current_track() -> String:
	return current_track

func set_current_track(value: String) -> void:
	current_track = value

func handle_track_finished() -> void:
	pass
