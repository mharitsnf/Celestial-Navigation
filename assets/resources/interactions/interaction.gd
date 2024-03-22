class_name Interaction extends Resource

var current_track: String = "Default"
@export var tracks: Array[InteractionTrack] = [
	preload("res://assets/resources/interactions/tracks/fallback.tres")
]

func get_current_track_resource() -> InteractionTrack:
    for t: InteractionTrack in tracks:
        var res: Resource = load(t.resource_path)
        if res is InteractionTrack and res.track_name == current_track: return res
    return null