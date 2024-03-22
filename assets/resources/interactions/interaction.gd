class_name Interaction extends Resource

var current_track: String = "Default"
@export var tracks: Array[InteractionTrack] = [
    preload("res://assets/resources/interactions/tracks/fallback.tres")
]